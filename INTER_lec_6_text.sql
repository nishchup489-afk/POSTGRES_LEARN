-- =====================================================================
--            ADVANCED TEXT QUERIES & QUERY PERFORMANCE
-- =====================================================================

/*
PostgreSQL provides several ways to search text.

Common techniques:

    =
    LIKE
    ILIKE
    IN
    SIMILAR TO

Performance depends heavily on:

    - Indexes
    - Wildcard position
    - Case sensitivity
    - Query structure
*/


-- =====================================================================
--                         SAMPLE TABLE
-- =====================================================================

CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(100),
    email VARCHAR(200),
    city VARCHAR(100)
);


INSERT INTO users (username, email, city)
VALUES
    ('Alice', 'alice@example.com', 'New York'),
    ('Alex', 'alex@gmail.com', 'Boston'),
    ('Bob', 'bob@example.com', 'Chicago'),
    ('Charlie', 'charlie@gmail.com', 'New York');


-- =====================================================================
--                         EXACT MATCH
-- =====================================================================

/*
The equality operator searches for
one exact value.
*/

SELECT *
FROM users
WHERE username = 'Alice';


/*
Exact searches are usually very fast
when the column has an index.
*/


-- =====================================================================
--                              LIKE
-- =====================================================================

/*
LIKE performs pattern matching.

Wildcards:

    %   -> zero or more characters

    _   -> exactly one character
*/


-- Starts with "Al"

SELECT *
FROM users
WHERE username LIKE 'Al%';


-- Ends with "ice"

SELECT *
FROM users
WHERE username LIKE '%ice';


-- Contains "li"

SELECT *
FROM users
WHERE username LIKE '%li%';


-- Exactly one unknown character

SELECT *
FROM users
WHERE username LIKE 'A_ice';


-- =====================================================================
--                     PREFIX SEARCH PERFORMANCE
-- =====================================================================

/*
This is called a prefix search:
*/

SELECT *
FROM users
WHERE username LIKE 'Al%';


/*
A prefix search can often use a B-tree index.

PostgreSQL knows where values beginning
with "Al" are located.
*/


/*
This query is usually slower:
*/

SELECT *
FROM users
WHERE username LIKE '%ice';


/*
Because the wildcard appears first,
PostgreSQL does not know where the match begins.

It may need to inspect every row.
*/


-- =====================================================================
--                             ILIKE
-- =====================================================================

/*
ILIKE performs case-insensitive matching.

It is a PostgreSQL feature.
*/

SELECT *
FROM users
WHERE username ILIKE 'alice';


/*
These can all match:

    Alice
    ALICE
    alice
*/


SELECT *
FROM users
WHERE username ILIKE 'al%';


/*
ILIKE is convenient,
but it may be slower than LIKE
because PostgreSQL must ignore letter case.
*/


-- =====================================================================
--                              IN
-- =====================================================================

/*
IN checks whether a value matches
one of several values.
*/

SELECT *
FROM users
WHERE city IN (
    'New York',
    'Boston',
    'Chicago'
);


/*
Equivalent idea:

WHERE city = 'New York'
   OR city = 'Boston'
   OR city = 'Chicago'
*/


/*
IN usually performs well
when the searched column is indexed.
*/


-- =====================================================================
--                         SIMILAR TO
-- =====================================================================

/*
SIMILAR TO provides more advanced
pattern matching.

It is similar to regular expressions.
*/

SELECT *
FROM users
WHERE username SIMILAR TO '(Alice|Alex|Bob)';


/*
This matches:

    Alice
    Alex
    Bob
*/


SELECT *
FROM users
WHERE username SIMILAR TO 'A%';


/*
For simple matching,
LIKE is usually easier and more common.
*/


-- =====================================================================
--                         TEXT FUNCTIONS
-- =====================================================================

/*
PostgreSQL includes functions
for modifying and examining text.
*/


-- Convert text to lowercase

SELECT LOWER('PostgreSQL');


/*
Result:

postgresql
*/


-- Convert text to uppercase

SELECT UPPER('PostgreSQL');


/*
Result:

POSTGRESQL
*/


-- Use LOWER() in a query

SELECT *
FROM users
WHERE LOWER(username) = 'alice';


/*
This makes the comparison case-insensitive.

However, applying a function to an indexed column
may prevent normal index usage.
*/


-- =====================================================================
--                          SUBSTRING()
-- =====================================================================

/*
SUBSTRING extracts part of a string.
*/

SELECT SUBSTRING('PostgreSQL' FROM 1 FOR 4);


/*
Result:

Post
*/


SELECT
    username,
    SUBSTRING(username FROM 1 FOR 1) AS first_letter
FROM users;


-- =====================================================================
--                           LENGTH()
-- =====================================================================

/*
LENGTH returns the number of characters.
*/

SELECT LENGTH('PostgreSQL');


/*
Result:

10
*/


SELECT *
FROM users
WHERE LENGTH(username) > 5;


-- =====================================================================
--                           REPLACE()
-- =====================================================================

/*
REPLACE changes matching text.
*/

SELECT REPLACE(
    'hello world',
    'world',
    'PostgreSQL'
);


/*
Result:

hello PostgreSQL
*/


-- =====================================================================
--                          TRANSLATE()
-- =====================================================================

/*
TRANSLATE replaces characters one by one.

It behaves similarly to the Unix tr command.
*/

SELECT TRANSLATE(
    'abc123',
    'abc',
    'xyz'
);


/*
Result:

xyz123


Character mapping:

    a -> x
    b -> y
    c -> z
*/


-- =====================================================================
--                           TRIM()
-- =====================================================================

/*
TRIM removes spaces
from the beginning and end.
*/

SELECT TRIM('   PostgreSQL   ');


/*
Result:

PostgreSQL
*/


-- =====================================================================
--                         CONCATENATION
-- =====================================================================

/*
The || operator joins strings.
*/

SELECT
    username || ' lives in ' || city
FROM users;


/*
Example result:

Alice lives in New York
*/


-- =====================================================================
--                            B-TREE INDEX
-- =====================================================================

/*
B-tree is PostgreSQL's default index type.

Create an index:
*/

CREATE INDEX users_username_idx
ON users(username);


/*
B-tree indexes are useful for:

    Exact matches

        username = 'Alice'

    Prefix searches

        username LIKE 'Al%'

    Sorting

        ORDER BY username

    Range searches

        username >= 'A'
        username < 'M'
*/


-- =====================================================================
--                         INDEX TRADE-OFF
-- =====================================================================

/*
Indexes improve reading speed.

But they also:

    - Use extra disk space
    - Slow down INSERT
    - Slow down UPDATE
    - Slow down DELETE


Why?

Because PostgreSQL must update both:

    The table data

    The index
*/


/*
An index may sometimes be larger
than the actual text data.

That is acceptable when faster searches
are worth the additional storage.
*/


-- =====================================================================
--                       EXPLAIN ANALYZE
-- =====================================================================

/*
EXPLAIN ANALYZE shows how PostgreSQL
actually executes a query.
*/

EXPLAIN ANALYZE
SELECT *
FROM users
WHERE username = 'Alice';


/*
Common execution methods:

    Index Scan

        PostgreSQL uses an index.

    Sequential Scan

        PostgreSQL reads rows
        from the table one by one.
*/


-- =====================================================================
--                         INDEX SCAN
-- =====================================================================

/*
An indexed exact match may produce:

    Index Scan
*/

EXPLAIN ANALYZE
SELECT *
FROM users
WHERE username = 'Alice';


/*
This is usually fast
for large tables.
*/


-- =====================================================================
--                       SEQUENTIAL SCAN
-- =====================================================================

/*
A wildcard at the beginning
often causes a sequential scan.
*/

EXPLAIN ANALYZE
SELECT *
FROM users
WHERE username LIKE '%ice';


/*
PostgreSQL may inspect every username
because it cannot use the normal index efficiently.
*/


-- =====================================================================
--                           LIMIT
-- =====================================================================

/*
LIMIT stops returning rows
after a certain number is found.
*/

SELECT *
FROM users
WHERE username LIKE '%a%'
LIMIT 5;


/*
If PostgreSQL performs a sequential scan,
LIMIT may allow it to stop early
after finding enough matching rows.

However, LIMIT does not automatically
make every query fast.
*/


-- =====================================================================
--                    FUNCTIONS AND INDEXES
-- =====================================================================

/*
Suppose username has a normal index:
*/

CREATE INDEX users_username_normal_idx
ON users(username);


/*
This may not use that normal index efficiently:
*/

SELECT *
FROM users
WHERE LOWER(username) = 'alice';


/*
Why?

The index stores:

    Alice

But the query searches using:

    LOWER(username)
*/


/*
A functional index can help:
*/

CREATE INDEX users_username_lower_idx
ON users(LOWER(username));


/*
Now this query can use the functional index:
*/

SELECT *
FROM users
WHERE LOWER(username) = 'alice';


-- =====================================================================
--                    IN WITH A SUBQUERY
-- =====================================================================

/*
IN can also use a subquery.
*/

SELECT *
FROM users
WHERE city IN (
    SELECT city
    FROM users
    WHERE email LIKE '%gmail.com'
);


/*
This is valid SQL.

However, subquery performance depends on:

    - Indexes
    - Number of returned rows
    - Query structure
    - PostgreSQL's execution plan


Do not assume every subquery is slow.

Check with EXPLAIN ANALYZE.
*/


-- =====================================================================
--                       PERFORMANCE EXAMPLES
-- =====================================================================

/*
Usually fast with an index:
*/

SELECT *
FROM users
WHERE username = 'Alice';


/*
Often fast:
*/

SELECT *
FROM users
WHERE username LIKE 'Al%';


/*
Often slower:
*/

SELECT *
FROM users
WHERE username LIKE '%ice';


/*
May be slower without a functional index:
*/

SELECT *
FROM users
WHERE LOWER(username) = 'alice';


/*
Case-insensitive search:
*/

SELECT *
FROM users
WHERE username ILIKE '%alice%';


-- =====================================================================
--                     PRACTICAL PERFORMANCE RULES
-- =====================================================================

/*
1. Use = for exact matching.

2. Use LIKE 'text%' for prefix matching.

3. Avoid leading wildcards when possible:

       LIKE '%text'

4. Add indexes to columns searched frequently.

5. Do not index every column.

6. Functions on indexed columns may block
   normal index usage.

7. Use EXPLAIN ANALYZE to verify performance.

8. Use LIMIT when only a few results are needed.
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
=

    Exact text match.


LIKE

    Case-sensitive pattern matching.

    'abc%' can often use an index.

    '%abc' usually cannot use
    a normal B-tree index efficiently.


ILIKE

    Case-insensitive matching.

    Convenient but may be slower.


IN

    Match against several values.


SIMILAR TO

    More advanced pattern matching.


Common text functions:

    LOWER()
    UPPER()
    SUBSTRING()
    LENGTH()
    REPLACE()
    TRANSLATE()
    TRIM()


B-tree index:

    Speeds up exact matches,
    sorting, ranges,
    and many prefix searches.


EXPLAIN ANALYZE:

    Shows the actual execution plan
    and query runtime.


Core idea:

Correct SQL is not always efficient SQL.

Indexes, wildcard position,
functions, and query structure
determine how much work PostgreSQL performs.
*/