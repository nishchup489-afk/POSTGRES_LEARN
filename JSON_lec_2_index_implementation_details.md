# PostgreSQL Indexes: B-tree, BRIN, GIN, GiST, and More

Indexes are one of the most important tools for improving database performance.

Without an index, PostgreSQL may need to scan every row in a table to find the requested data.

With an index, PostgreSQL can often jump directly to the relevant rows while reading far fewer disk blocks.

The central goal of an index is simple:

```text
Reduce the amount of data PostgreSQL must read.
```

---

## 1. What Is an Index?

An index is a separate data structure that helps PostgreSQL locate rows quickly.

It stores a relationship between:

```text
Search Key → Row Location
```

For example, suppose we have this table:

```sql
CREATE TABLE users (
    id INTEGER,
    name VARCHAR(100),
    email VARCHAR(255)
);
```

The table might contain millions of rows.

Without an index, this query may require scanning the whole table:

```sql
SELECT *
FROM users
WHERE email = 'sam@example.com';
```

Conceptually:

```text
Check Row 1
Check Row 2
Check Row 3
Check Row 4
...
Check Row 5,000,000
```

This is called a:

```text
Sequential Scan
```

After creating an index:

```sql
CREATE INDEX idx_users_email
ON users(email);
```

PostgreSQL can search the index first:

```text
sam@example.com
        ↓
Block 912, Item 4
```

Then it can jump to the block containing the matching row.

---

## 2. Index as a Cheat Sheet

An index works like the index section at the back of a textbook.

Suppose you want to find information about PostgreSQL indexes.

Without a book index, you might read every page.

With an index, you look up:

```text
Indexes → Page 214
```

A database index works similarly:

```text
Logical Value → Physical Row Location
```

For example:

```text
john@example.com → Block 20, Item 3
sam@example.com  → Block 85, Item 7
zoe@example.com  → Block 92, Item 1
```

The index helps PostgreSQL avoid searching unrelated blocks.

---

## 3. Why Disk Block Reads Matter

PostgreSQL stores data in blocks, usually 8 KB each.

When PostgreSQL needs a row, it generally reads the entire block containing that row.

Suppose a table occupies:

```text
100,000 blocks
```

A sequential scan may need to inspect most or all of them.

An index scan might only require:

```text
3 index blocks
+
1 table block
```

That difference can be enormous.

The performance benefit of an index mainly comes from reducing:

```text
Disk I/O
```

Disk access is much slower than accessing data already stored in memory.

Even with SSDs, reading fewer blocks is usually better.

---

# Forward Indexes and Inverted Indexes

Indexes can be broadly understood using two categories:

```text
Forward Indexes
Inverted Indexes
```

This is a conceptual distinction rather than a strict PostgreSQL classification.

---

## 4. Forward Indexes

A forward index maps one key value to one or a small number of rows.

Conceptually:

```text
Key → Row Location
```

Example:

```text
101 → Row containing user 101
102 → Row containing user 102
103 → Row containing user 103
```

Forward-style indexes are useful for columns such as:

* IDs
* usernames
* email addresses
* timestamps
* prices
* dates
* status values

Examples of PostgreSQL index types commonly used this way include:

```text
B-tree
Hash
BRIN
```

---

## 5. Inverted Indexes

An inverted index is useful when one row contains many searchable pieces.

Examples include:

* arrays
* JSON documents
* text documents
* full-text search vectors
* geographic values

Instead of mapping:

```text
Row → Words
```

it maps:

```text
Word → Rows containing that word
```

Suppose we have these documents:

```text
Document 1: PostgreSQL indexes improve queries
Document 2: PostgreSQL supports full-text search
Document 3: Indexes reduce disk reads
```

An inverted index might look like this:

```text
PostgreSQL → Document 1, Document 2
indexes    → Document 1, Document 3
search     → Document 2
disk       → Document 3
```

This makes it much easier to search for words inside documents.

PostgreSQL index types often used for these complex searches include:

```text
GIN
GiST
SP-GiST
```

However, these index types are not identical. Each one uses a different internal strategy and supports different data types and operators.

---

# B-tree Indexes

## 6. What Is a B-tree Index?

B-tree stands for:

```text
Balanced Tree
```

B-tree is PostgreSQL’s default index type.

If you create an index without specifying a type:

```sql
CREATE INDEX idx_users_email
ON users(email);
```

PostgreSQL creates a B-tree index.

This is equivalent to:

```sql
CREATE INDEX idx_users_email
ON users
USING BTREE(email);
```

B-tree indexes are useful for most common comparisons.

They support operators such as:

```text
=
<
<=
>
>=
BETWEEN
IN
ORDER BY
```

---

## 7. B-tree Structure

A B-tree stores keys in sorted order inside a balanced tree.

A simplified structure looks like this:

```text
                 [50]
               /      \
         [10, 20]      [70, 90]
         /   |   \      /   |   \
       rows rows rows  rows rows rows
```

The top block is called the:

```text
Root Page
```

The middle blocks are called:

```text
Internal Pages
```

The lowest blocks are called:

```text
Leaf Pages
```

The leaf pages contain indexed values and row references.

---

## 8. Why the Tree Is Balanced

A balanced tree keeps all leaf pages at approximately the same depth.

That means PostgreSQL does not need to follow a very long chain to find some values.

For example, a lookup may require:

```text
Root Page
→ Internal Page
→ Leaf Page
→ Table Row
```

Even when the index contains millions of entries, the tree may only be a few levels deep.

This keeps the number of block reads low.

---

## 9. B-tree Lookup Example

Suppose PostgreSQL executes:

```sql
SELECT *
FROM users
WHERE id = 5000;
```

The B-tree search might work like this:

```text
1. Read root index page
2. Determine which branch contains 5000
3. Read internal page
4. Read leaf page
5. Find row pointer
6. Read corresponding table block
```

Instead of scanning the entire table, PostgreSQL follows a short path through the index.

---

## 10. B-tree and Sorted Data

B-tree indexes maintain keys in sorted order.

This makes them useful for queries such as:

```sql
SELECT *
FROM products
WHERE price > 500;
```

They can also help with sorting:

```sql
SELECT *
FROM products
ORDER BY price;
```

If PostgreSQL can read rows in index order, it may avoid a separate sorting operation.

B-tree indexes are also useful for range searches:

```sql
SELECT *
FROM orders
WHERE created_at BETWEEN
      '2026-01-01' AND '2026-01-31';
```

---

## 11. B-tree Insertions and Updates

When a new indexed value is inserted, PostgreSQL must place it in the correct sorted position.

For example:

```text
10, 20, 30, 40
```

If the value `25` is inserted:

```text
10, 20, 25, 30, 40
```

If an index page becomes full, PostgreSQL may split it into multiple pages.

This keeps the tree balanced.

However, indexes create extra work during:

* `INSERT`
* `UPDATE`
* `DELETE`

PostgreSQL must update both:

```text
The table
The index
```

Therefore, indexes improve reads but add overhead to writes.

---

# BRIN Indexes

## 12. What Is a BRIN Index?

BRIN stands for:

```text
Block Range Index
```

A BRIN index does not store an entry for every row.

Instead, it stores summary information for ranges of table blocks.

For example:

```text
Blocks 0–127:
Minimum timestamp = January 1
Maximum timestamp = January 5

Blocks 128–255:
Minimum timestamp = January 5
Maximum timestamp = January 10
```

This makes BRIN indexes extremely small compared with B-tree indexes.

---

## 13. BRIN Index Example

Suppose we have a massive event table:

```sql
CREATE TABLE events (
    id BIGINT,
    created_at TIMESTAMP,
    message TEXT
);
```

Rows are inserted in chronological order.

The physical table might look like:

```text
Early blocks  → Older timestamps
Middle blocks → Middle timestamps
Later blocks  → Newer timestamps
```

We can create a BRIN index:

```sql
CREATE INDEX idx_events_created_at_brin
ON events
USING BRIN(created_at);
```

Now consider:

```sql
SELECT *
FROM events
WHERE created_at >= '2026-08-01';
```

The BRIN index can identify which block ranges may contain those dates.

PostgreSQL can skip many older blocks.

---

## 14. BRIN Stores Summaries

A simplified BRIN index might contain:

```text
Block Range 1:
min = 1
max = 1000

Block Range 2:
min = 1001
max = 2000

Block Range 3:
min = 2001
max = 3000
```

For this query:

```sql
SELECT *
FROM measurements
WHERE value = 2500;
```

PostgreSQL knows that `2500` may exist in Block Range 3.

It can skip Block Ranges 1 and 2.

However, it still needs to scan the relevant table blocks because BRIN does not normally point to one exact row.

---

## 15. BRIN Is a Lossy Index

A BRIN index is often described as:

```text
Lossy
```

This means it may identify blocks that could contain matching rows rather than proving that every row in those blocks matches.

For example:

```text
Block Range:
Minimum = 100
Maximum = 1000
```

A query searches for:

```text
value = 500
```

The BRIN index says:

```text
500 could be inside this block range.
```

PostgreSQL then reads those blocks and checks the actual rows.

Therefore, BRIN narrows the search area but may still require scanning several blocks.

---

## 16. When BRIN Works Best

BRIN works best when column values are strongly correlated with physical row order.

Good examples include:

* timestamps inserted chronologically
* auto-incrementing IDs
* sequential event logs
* sensor measurements
* time-series data
* append-only tables

Example:

```text
Older rows → Older dates
Newer rows → Newer dates
```

This physical ordering allows BRIN to skip large portions of the table.

---

## 17. When BRIN Performs Poorly

Suppose values are randomly distributed:

```text
Block 1: 5, 9000, 200, 7500
Block 2: 10, 8000, 300, 9900
Block 3: 1, 7000, 500, 9500
```

Each block range may have:

```text
Very low minimum
Very high maximum
```

Almost every search value could fall between those minimum and maximum values.

The BRIN index would not be able to exclude many blocks.

In that case, a B-tree index may perform much better.

---

## 18. B-tree vs BRIN

| Feature          | B-tree                            | BRIN                            |
| ---------------- | --------------------------------- | ------------------------------- |
| Size             | Larger                            | Very small                      |
| Entry storage    | Usually one entry per indexed row | One summary per block range     |
| Lookup precision | High                              | Approximate block ranges        |
| Best for         | General-purpose queries           | Huge, physically ordered tables |
| Write overhead   | Higher                            | Lower                           |
| Equality search  | Excellent                         | Usually less precise            |
| Range search     | Excellent                         | Excellent when data is ordered  |

A simple rule:

```text
Use B-tree by default.
Consider BRIN for enormous, naturally ordered tables.
```

---

# Hash Indexes

## 19. What Is a Hash Index?

A hash index applies a hash function to indexed values.

Conceptually:

```text
Value → Hash Value → Row Location
```

Example:

```text
sam@example.com
       ↓
Hash: 839201
       ↓
Row Location
```

A hash index is mainly useful for equality comparisons:

```sql
WHERE column = value
```

Example:

```sql
CREATE INDEX idx_users_email_hash
ON users
USING HASH(email);
```

---

## 20. Hash Index Limitations

Hash indexes are not useful for range comparisons such as:

```sql
WHERE price > 100;
```

or:

```sql
WHERE created_at BETWEEN date1 AND date2;
```

A hash function does not preserve sorted order.

For example:

```text
10 → hash 900
11 → hash 102
12 → hash 701
```

The hash values do not maintain the original numeric order.

Because B-tree also handles equality searches efficiently, B-tree is usually preferred unless testing proves that a hash index is better for a specific workload.

---

# GIN Indexes

## 21. What Is a GIN Index?

GIN stands for:

```text
Generalized Inverted Index
```

GIN is designed for values that contain multiple searchable elements.

Examples include:

* arrays
* JSONB
* full-text search vectors

Suppose a row contains:

```text
['python', 'postgresql', 'fastapi']
```

A GIN index may create entries like:

```text
python     → Row 1
postgresql → Row 1
fastapi    → Row 1
```

Another row might contain:

```text
['javascript', 'postgresql', 'react']
```

Then the index becomes:

```text
python     → Row 1
postgresql → Row 1, Row 2
fastapi    → Row 1
javascript → Row 2
react      → Row 2
```

---

## 22. GIN with Arrays

Example table:

```sql
CREATE TABLE developers (
    id INTEGER,
    skills TEXT[]
);
```

Create a GIN index:

```sql
CREATE INDEX idx_developers_skills
ON developers
USING GIN(skills);
```

Then PostgreSQL can efficiently search for rows containing a value:

```sql
SELECT *
FROM developers
WHERE skills @> ARRAY['PostgreSQL'];
```

The GIN index can identify rows containing the requested array element.

---

## 23. GIN with JSONB

Example table:

```sql
CREATE TABLE products (
    id INTEGER,
    attributes JSONB
);
```

Example JSON value:

```json
{
  "brand": "Apple",
  "color": "Silver",
  "storage": "256GB"
}
```

Create the index:

```sql
CREATE INDEX idx_products_attributes
ON products
USING GIN(attributes);
```

Then query:

```sql
SELECT *
FROM products
WHERE attributes @> '{"brand": "Apple"}';
```

GIN can index keys and values inside JSONB documents.

---

## 24. GIN for Full-Text Search

Suppose we have:

```sql
CREATE TABLE articles (
    id INTEGER,
    title TEXT,
    body TEXT
);
```

We can create a full-text GIN index:

```sql
CREATE INDEX idx_articles_search
ON articles
USING GIN(
    to_tsvector('english', title || ' ' || body)
);
```

Then search:

```sql
SELECT *
FROM articles
WHERE to_tsvector('english', title || ' ' || body)
      @@ plainto_tsquery('english', 'PostgreSQL indexes');
```

The GIN index stores searchable text tokens and tracks which rows contain them.

---

## 25. GIN Trade-offs

GIN indexes are powerful for multi-valued data, but they have costs.

Advantages:

* excellent search performance
* effective for arrays
* effective for JSONB
* effective for full-text search

Disadvantages:

* can be large
* slower to build
* inserts and updates can be expensive
* more complex than B-tree

GIN is specialized. It should not replace B-tree for normal scalar columns such as IDs or timestamps.

---

# GiST Indexes

## 26. What Is a GiST Index?

GiST stands for:

```text
Generalized Search Tree
```

GiST is a framework for building different kinds of tree-based indexes.

It is commonly used for:

* geometric data
* ranges
* nearest-neighbor searches
* geographic data
* certain text-search cases
* exclusion constraints

Example:

```sql
CREATE INDEX idx_locations_point
ON locations
USING GIST(coordinates);
```

GiST is especially useful when queries involve ideas such as:

```text
overlaps
contains
is near
intersects
```

---

## 27. GiST with Range Types

PostgreSQL supports range data types such as:

```text
int4range
daterange
tsrange
tstzrange
```

Example:

```sql
CREATE TABLE reservations (
    id INTEGER,
    reserved_period TSRANGE
);
```

Create a GiST index:

```sql
CREATE INDEX idx_reservations_period
ON reservations
USING GIST(reserved_period);
```

Then search for overlapping reservations:

```sql
SELECT *
FROM reservations
WHERE reserved_period &&
      '[2026-08-10 10:00, 2026-08-10 12:00)'::tsrange;
```

The `&&` operator checks whether two ranges overlap.

---

# SP-GiST Indexes

## 28. What Is SP-GiST?

SP-GiST stands for:

```text
Space-Partitioned Generalized Search Tree
```

SP-GiST supports data structures that divide data into separate regions.

Examples include:

* quadtrees
* k-d trees
* radix trees
* prefix trees

SP-GiST can be useful for:

* spatial data
* IP address searches
* prefix-based text patterns
* naturally partitioned data

It is more specialized than B-tree and is not commonly needed for ordinary application tables.

---

# Choosing the Correct Index

## 29. PostgreSQL Index Type Summary

| Index Type | Best Use Case                             |
| ---------- | ----------------------------------------- |
| B-tree     | Equality, ranges, sorting, general use    |
| Hash       | Equality-only comparisons                 |
| BRIN       | Huge tables with physically ordered data  |
| GIN        | Arrays, JSONB, full-text search           |
| GiST       | Ranges, geometry, nearest-neighbor search |
| SP-GiST    | Partitioned spatial or prefix data        |

---

## 30. Default Decision Rule

Start with:

```text
B-tree
```

B-tree is the correct choice for most normal columns.

Use specialized indexes only when the data type and query operators justify them.

Examples:

```text
Email lookup       → B-tree
Timestamp range    → B-tree
Massive event log  → BRIN
JSONB containment  → GIN
Array membership   → GIN
Text search        → GIN
Date-range overlap → GiST
Geographic search  → GiST or SP-GiST
```

---

# Index Scans in PostgreSQL

## 31. Sequential Scan

A sequential scan reads table blocks directly.

Example:

```sql
SELECT *
FROM users;
```

Execution plan:

```text
Seq Scan on users
```

This is often correct when PostgreSQL expects to return a large portion of the table.

---

## 32. Index Scan

An index scan uses an index to find row locations, then reads the table rows.

Example:

```sql
SELECT *
FROM users
WHERE email = 'sam@example.com';
```

Possible plan:

```text
Index Scan using idx_users_email on users
```

Conceptually:

```text
Search Index
→ Find Row Pointer
→ Read Table Block
→ Return Row
```

---

## 33. Index-Only Scan

Sometimes PostgreSQL can answer a query entirely from the index.

Example:

```sql
CREATE INDEX idx_users_email
ON users(email);
```

Query:

```sql
SELECT email
FROM users
WHERE email = 'sam@example.com';
```

Since the requested column is already stored in the index, PostgreSQL may use:

```text
Index Only Scan
```

However, PostgreSQL may still consult the visibility map to verify whether the row is visible to the current transaction.

---

## 34. Bitmap Index Scan

When many rows match a condition, PostgreSQL may use a bitmap scan.

Conceptually:

```text
Index identifies matching row locations
        ↓
PostgreSQL groups them by table block
        ↓
Each table block is read once
```

Possible execution plan:

```text
Bitmap Index Scan
→ Bitmap Heap Scan
```

This avoids repeatedly jumping back and forth between table blocks.

Bitmap scans are often useful when a query matches more than a few rows but not enough to justify scanning the entire table.

---

# Index Costs and Trade-offs

## 35. Indexes Are Not Free

Every index consumes:

* disk space
* memory when cached
* CPU during maintenance
* time during inserts
* time during updates
* time during deletes

Suppose a table has five indexes.

When a row is inserted, PostgreSQL may need to update:

```text
1 table
+
5 indexes
```

Too many indexes can damage write performance.

The goal is not:

```text
Index every column.
```

The goal is:

```text
Create indexes that support important queries.
```

---

## 36. Unused Indexes

An unused index still consumes storage and slows writes.

PostgreSQL provides statistics that can help identify index usage:

```sql
SELECT
    schemaname,
    relname,
    indexrelname,
    idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan;
```

A low `idx_scan` count may indicate that an index is rarely used.

However, do not immediately delete an index based only on this number.

Statistics may have been reset, and some indexes exist to enforce constraints rather than serve frequent queries.

---

## 37. Indexes and Selectivity

Selectivity describes how narrowly a condition filters rows.

A highly selective query returns very few rows:

```sql
WHERE email = 'unique@example.com'
```

An index is often useful here.

A low-selectivity query returns many rows:

```sql
WHERE active = true
```

If 95% of users are active, PostgreSQL may prefer a sequential scan.

Reading the index and then visiting almost every table block could be slower than scanning the table directly.

---

## 38. Composite Indexes

An index can contain multiple columns.

Example:

```sql
CREATE INDEX idx_orders_user_date
ON orders(user_id, created_at);
```

This index may help:

```sql
SELECT *
FROM orders
WHERE user_id = 10
  AND created_at >= '2026-01-01';
```

It may also help:

```sql
SELECT *
FROM orders
WHERE user_id = 10;
```

But it may not efficiently support:

```sql
SELECT *
FROM orders
WHERE created_at >= '2026-01-01';
```

The order of columns matters.

This is related to the:

```text
Leftmost Prefix Rule
```

For an index:

```text
(a, b, c)
```

PostgreSQL can generally use the ordered structure effectively for:

```text
a
a, b
a, b, c
```

But not always for:

```text
b only
c only
```

---

## 39. Partial Indexes

A partial index indexes only rows matching a condition.

Example:

```sql
CREATE INDEX idx_users_active_email
ON users(email)
WHERE active = true;
```

This index contains only active users.

It can be useful for:

```sql
SELECT *
FROM users
WHERE active = true
  AND email = 'sam@example.com';
```

Advantages include:

* smaller index
* faster maintenance
* reduced storage
* better performance for targeted queries

---

## 40. Expression Indexes

PostgreSQL can index the result of an expression.

Example:

```sql
CREATE INDEX idx_users_lower_email
ON users(LOWER(email));
```

Then this query can use the index:

```sql
SELECT *
FROM users
WHERE LOWER(email) = 'sam@example.com';
```

Without the expression index, a normal index on `email` may not help because the query applies `LOWER()` to the column.

---

## 41. Unique Indexes

A unique index ensures indexed values do not repeat.

Example:

```sql
CREATE UNIQUE INDEX idx_users_email_unique
ON users(email);
```

This provides two benefits:

```text
Fast lookup
+
Uniqueness enforcement
```

A unique constraint usually creates a unique B-tree index automatically:

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email TEXT UNIQUE
);
```

PostgreSQL creates indexes to support both the primary key and unique constraint.

---

# Checking Whether an Index Is Used

## 42. EXPLAIN

Use `EXPLAIN` to see PostgreSQL’s planned execution strategy.

```sql
EXPLAIN
SELECT *
FROM users
WHERE email = 'sam@example.com';
```

Possible output:

```text
Index Scan using idx_users_email on users
```

---

## 43. EXPLAIN ANALYZE

Use:

```sql
EXPLAIN ANALYZE
SELECT *
FROM users
WHERE email = 'sam@example.com';
```

This actually executes the query and reports real timing and row counts.

Be careful when using it with queries that modify data, because the query will really run.

---

## 44. EXPLAIN with BUFFERS

For block-level information:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM users
WHERE email = 'sam@example.com';
```

This can show:

```text
shared hit
shared read
shared dirtied
shared written
```

### Shared hit

The requested block was already in memory.

### Shared read

The block had to be read from storage.

This helps reveal whether the index is actually reducing block access.

---

# Final Mental Model

Think of the table as a huge library.

```text
Table Rows     = Books
Disk Blocks    = Shelves
B-tree Index   = Sorted library catalog
BRIN Index     = Summary of which shelves contain which ranges
GIN Index      = Word-to-book lookup system
GiST Index     = Spatial or relationship-based catalog
Sequential Scan = Checking every shelf
Index Scan      = Using the catalog to find the correct shelf
```

The index does not eliminate all work.

It helps PostgreSQL answer:

```text
Which blocks should I read?
```

The fewer unnecessary blocks PostgreSQL reads, the faster many queries become.

---

# Key Takeaways

* Indexes reduce unnecessary table scans and disk-block reads.
* B-tree is PostgreSQL’s default and most versatile index type.
* B-tree supports equality, ranges, ordering, and comparisons.
* BRIN summarizes block ranges instead of indexing every row.
* BRIN works best for enormous tables with physically ordered data.
* Hash indexes mainly support equality comparisons.
* GIN is designed for arrays, JSONB, and full-text search.
* GiST supports ranges, geometry, and specialized search operators.
* SP-GiST supports partitioned and spatial data structures.
* Indexes improve reads but increase storage and write costs.
* PostgreSQL may choose a sequential scan even when an index exists.
* Composite-index column order matters.
* Partial and expression indexes can optimize specialized queries.
* `EXPLAIN (ANALYZE, BUFFERS)` reveals how indexes affect real execution.
