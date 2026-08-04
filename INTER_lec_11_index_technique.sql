-- =====================================================================
--              POSTGRESQL INDEXING FOR URL LOOKUPS
-- =====================================================================

/*
This lecture focuses on improving lookup performance
for a web crawler.

A web crawler visits URLs and must remember:

    - Which URLs have already been seen
    - Which URLs are still waiting to be crawled
    - Which URLs should not be inserted twice

The main challenge:

URLs can be very long.

Example:

    https://example.com/articles/2026/postgresql/indexing/very-long-path

Using a normal index directly on long text values
can consume a lot of storage.
*/


-- =====================================================================
--                         SAMPLE TABLE
-- =====================================================================

CREATE TABLE pages (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    url TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


/*
TEXT is appropriate for URLs because URL length varies.

Avoid choosing a small VARCHAR limit unless
the application has a real business limit.
*/


-- =====================================================================
--                   WHY URL LOOKUPS MATTER
-- =====================================================================

/*
Before inserting a URL, the crawler may ask:

    Have I already seen this URL?
*/

SELECT *
FROM pages
WHERE url = 'https://example.com/docs/postgresql';


/*
Without an index, PostgreSQL may perform
a sequential scan.

That means checking rows one by one.
*/


-- =====================================================================
--                 NORMAL B-TREE INDEX ON URL
-- =====================================================================

CREATE UNIQUE INDEX page_url_btree_idx ON pages(url);

/*
B-tree is PostgreSQL's default index type.

This index supports:

    Exact lookup

        WHERE url = '...'

    Sorting

        ORDER BY url

    Range comparisons

        WHERE url >= 'a'
        WHERE url < 'm'

    Some prefix searches

        WHERE url LIKE 'https://example.com/%'
*/


/*
The UNIQUE keyword also prevents duplicate URLs.
*/


INSERT INTO pages (url)
VALUES ('https://example.com/docs/postgresql');


/*
Trying to insert the same URL again fails:
*/

INSERT INTO pages (url)
VALUES ('https://example.com/docs/postgresql');


/*
Problem:

Long URLs create large B-tree index entries.

On very large crawler tables,
the index may consume substantial disk space.
*/


-- =====================================================================
--                       CHECK INDEX SIZE
-- =====================================================================

/*
Check the size of an index:
*/

SELECT pg_size_pretty(
       pg_relation_size('page_url_btree_idx')
       );

/*
Check the total size of the table,
including indexes:
*/

SELECT pg_size_pretty(
    pg_total_relation_size('pages')
);


/*
Indexes use extra storage in exchange
for faster searches.
*/


-- =====================================================================
--                    MD5 EXPRESSION INDEX
-- =====================================================================

/*
Instead of indexing the entire URL,
we can index a fixed-size MD5 hash.

MD5 returns a 32-character hexadecimal string.
*/

SELECT MD5('https://example.com/docs/postgresql');


/*
Create a unique expression index:
*/

CREATE UNIQUE INDEX pages_url_md5_idx
ON pages(MD5(url));


/*
Advantages:

    - Fixed-size index values
    - Smaller than indexing many long URLs
    - Fast exact lookups
    - Can enforce uniqueness based on the hash
*/


-- =====================================================================
--               QUERY MUST MATCH THE INDEX EXPRESSION
-- =====================================================================

/*
To use this expression index efficiently,
the query should use the same expression.
*/

SELECT *
FROM pages
WHERE MD5(url) = MD5(
    'https://example.com/docs/postgresql'
);


/*
This query may use:

    pages_url_md5_idx
*/


/*
This query does not directly match
the expression index:
*/

SELECT *
FROM pages
WHERE url = 'https://example.com/docs/postgresql';


/*
PostgreSQL cannot usually use an index on MD5(url)
for a plain comparison on url.
*/


-- =====================================================================
--                       MD5 COLLISION WARNING
-- =====================================================================

/*
A hash collision means:

Two different URLs produce the same hash.

MD5 collisions are possible.

Therefore, using only MD5 as the final proof
that two URLs are identical is theoretically unsafe.
*/


/*
A safer lookup pattern:

1. Search using the hash.

2. Confirm using the original URL.
*/

SELECT *
FROM pages
WHERE MD5(url) = MD5(
        'https://example.com/docs/postgresql'
      )
  AND url = 'https://example.com/docs/postgresql';


/*
The hash narrows the search.

The original URL confirms the exact match.
*/


-- =====================================================================
--                 STORE HASH IN A SEPARATE COLUMN
-- =====================================================================

/*
Instead of calculating MD5(url) during every query,
we can store the hash in a column.
*/

CREATE TABLE crawler_pages (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    url TEXT NOT NULL,
    url_hash UUID NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


/*
MD5 returns hexadecimal text.

PostgreSQL can cast a valid MD5 string to UUID.
*/

SELECT MD5(
    'https://example.com/docs/postgresql'
)::UUID;


/*
Insert both URL and hash:
*/

INSERT INTO crawler_pages (url, url_hash)
VALUES (
    'https://example.com/docs/postgresql',
    MD5('https://example.com/docs/postgresql')::UUID
);


/*
Create an index on the UUID hash:
*/

CREATE INDEX crawler_pages_url_hash_idx
ON crawler_pages(url_hash);


/*
Lookup:
*/

SELECT *
FROM crawler_pages
WHERE url_hash = MD5(
    'https://example.com/docs/postgresql'
)::UUID
AND url = 'https://example.com/docs/postgresql';


/*
UUID uses a fixed 16-byte binary value.

This can be more compact than storing
the 32-character MD5 hexadecimal text in the index.
*/


-- =====================================================================
--                   GENERATED HASH COLUMN
-- =====================================================================

/*
PostgreSQL can calculate the hash automatically
using a generated column.
*/

CREATE TABLE url_queue (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    url TEXT NOT NULL,

    url_hash UUID
    GENERATED ALWAYS AS (MD5(url)::UUID) STORED,

    status VARCHAR(20) NOT NULL DEFAULT 'pending',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


/*
PostgreSQL automatically generates url_hash
when a URL is inserted.
*/

INSERT INTO url_queue (url)
VALUES ('https://example.com/docs/indexes');


SELECT *
FROM url_queue;


/*
Create an index:
*/

CREATE INDEX url_queue_hash_idx
ON url_queue(url_hash);


/*
Fast lookup:
*/

SELECT *
FROM url_queue
WHERE url_hash = MD5(
    'https://example.com/docs/indexes'
)::UUID
AND url = 'https://example.com/docs/indexes';


-- =====================================================================
--                  UNIQUE HASH AND URL TOGETHER
-- =====================================================================

/*
Using UNIQUE(url_hash) alone risks a collision.

A safer uniqueness rule can include both columns:
*/

CREATE UNIQUE INDEX url_queue_hash_url_unique
ON url_queue(url_hash, url);


/*
This prevents duplicate URLs while still allowing
two different URLs with the same hash.
*/


-- =====================================================================
--                         HASH INDEX
-- =====================================================================

/*
PostgreSQL also supports a HASH index.
*/

CREATE INDEX pages_url_hash_idx
ON pages
USING HASH (url);


/*
Hash indexes are mainly designed for:

    Exact equality

        WHERE url = '...'
*/


/*
They do not support:

    ORDER BY url

    url > '...'

    url < '...'

    BETWEEN

    Prefix matching

        LIKE 'https://example.com/%'
*/


-- =====================================================================
--                   B-TREE vs HASH INDEX
-- =====================================================================

/*
B-tree index:

    Exact equality
    Range comparisons
    Sorting
    Prefix matching
    UNIQUE constraints
    More flexible


Hash index:

    Exact equality only
    Can use less space in some cases
    Cannot support sorting or ranges
    More specialized
*/


-- =====================================================================
--                         EXPLAIN ANALYZE
-- =====================================================================

/*
Use EXPLAIN ANALYZE to see
how PostgreSQL executes a query.
*/

EXPLAIN ANALYZE
SELECT *
FROM pages
WHERE url = 'https://example.com/docs/postgresql';


/*
Possible plans:

    Index Scan
        PostgreSQL uses an index.

    Bitmap Index Scan
        PostgreSQL gathers matching row locations
        through an index.

    Sequential Scan
        PostgreSQL reads the table row by row.
*/


/*
Test the MD5 expression index:
*/

EXPLAIN ANALYZE
SELECT *
FROM pages
WHERE MD5(url) = MD5(
    'https://example.com/docs/postgresql'
);


/*
Test the hash index:
*/

EXPLAIN ANALYZE
SELECT *
FROM pages
WHERE url = 'https://example.com/docs/postgresql';


-- =====================================================================
--                       INDEX SIZE COMPARISON
-- =====================================================================

/*
Compare index sizes:
*/

SELECT
    indexrelname AS index_name,
    pg_size_pretty(
        pg_relation_size(indexrelid)
    ) AS index_size
FROM pg_stat_user_indexes
WHERE relname = 'pages'
ORDER BY pg_relation_size(indexrelid) DESC;


/*
Possible comparison:

    B-tree on full URL
        Largest and most flexible

    B-tree on MD5(url)
        Smaller fixed-size values

    Hash index on URL
        Equality-focused

Actual results depend on:

    - Number of rows
    - Average URL length
    - Duplicate patterns
    - PostgreSQL version
    - Storage settings
*/


-- =====================================================================
--                  WEB CRAWLER INSERT PATTERN
-- =====================================================================

/*
A crawler often needs:

Insert the URL only if it has not been seen.
*/

INSERT INTO url_queue (url)
VALUES ('https://example.com/new-page')
ON CONFLICT (url_hash, url)
DO NOTHING;


/*
This requires the composite unique index:
*/

CREATE UNIQUE INDEX IF NOT EXISTS
url_queue_hash_url_unique
ON url_queue(url_hash, url);


/*
Meaning:

If the same URL already exists,
do not insert it again.
*/


-- =====================================================================
--                   CLAIM A URL FOR CRAWLING
-- =====================================================================

/*
Multiple crawler workers may request pending URLs
at the same time.

FOR UPDATE SKIP LOCKED allows each worker
to safely claim a different row.
*/

BEGIN;

SELECT id, url
FROM url_queue
WHERE status = 'pending'
ORDER BY id
LIMIT 1
FOR UPDATE SKIP LOCKED;


/*
After selecting the row,
mark it as being processed:
*/

UPDATE url_queue
SET status = 'processing'
WHERE id = 1;

COMMIT;


/*
SKIP LOCKED prevents workers
from waiting on URLs already claimed
by another worker.
*/


-- =====================================================================
--                  PERFORMANCE TRADE-OFFS
-- =====================================================================

/*
Indexing the full URL:

Advantages:

    - Simple queries
    - Supports equality
    - Supports ordering and ranges
    - Can enforce exact uniqueness

Disadvantages:

    - Large index entries
    - More storage
    - More index maintenance
*/


/*
Indexing MD5(url):

Advantages:

    - Fixed-size values
    - Smaller index
    - Fast equality lookup

Disadvantages:

    - Query must use MD5(url)
    - Hash calculation has a CPU cost
    - MD5 collisions are theoretically possible
    - Does not support URL sorting or prefix queries
*/


/*
Stored UUID hash:

Advantages:

    - Fixed-size 16-byte value
    - No repeated hash calculation during lookup
    - Fast equality search
    - Easy to index

Disadvantages:

    - Extra column
    - Extra storage
    - Must keep hash consistent with the URL
      unless using a generated column
*/


/*
Hash index on URL:

Advantages:

    - Exact equality lookup
    - Specialized for equality
    - May save index space in some workloads

Disadvantages:

    - No sorting
    - No ranges
    - No prefix search
    - Less flexible than B-tree
*/


-- =====================================================================
--                    PRACTICAL RECOMMENDATION
-- =====================================================================

/*
For most applications:

Use a normal UNIQUE B-tree index on the URL first.
*/

CREATE UNIQUE INDEX pages_url_unique_idx
ON pages(url);


/*
Only consider MD5 or another fixed-size hash when:

    - URLs are very long
    - The table is extremely large
    - Index storage is a real problem
    - Queries are mainly exact lookups
    - Measurements show the hash strategy is better
*/


/*
Do not optimize only from theory.

Measure using:

    EXPLAIN ANALYZE

    pg_relation_size()

    pg_total_relation_size()
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
Web crawler problem:

    Track URLs efficiently
    and avoid duplicates.


B-tree on URL:

    Flexible
    Supports equality, sorting, ranges,
    prefixes, and uniqueness

    But may be large for long URLs.


B-tree on MD5(url):

    Smaller fixed-size index values
    Fast equality lookup

    Query must use the MD5 expression.


Stored UUID hash:

    Stores MD5 as a compact fixed-size value
    Can provide fast indexed lookups.


Hash index:

    Supports exact equality only
    Does not support sorting or ranges.


Important tools:

    EXPLAIN ANALYZE

    pg_relation_size()

    pg_total_relation_size()


Core idea:

Choose an index based on actual query patterns.

The best index is not always the smallest index
or the fastest index in one isolated test.

It is the index that best supports
the application's real workload.
*/