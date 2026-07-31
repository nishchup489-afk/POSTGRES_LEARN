-- =====================================================================
--                           AUTO INCREMENT
-- =====================================================================

/*
AUTO INCREMENT:

- Automatically generates a new numeric ID for each inserted row.
- IDs usually increase like: 1, 2, 3, 4...
- Commonly used for primary keys.
- PostgreSQL supports both the old SERIAL syntax and modern IDENTITY syntax.
*/


DROP TABLE IF EXISTS users;


/*
MODERN POSTGRESQL APPROACH:

GENERATED ALWAYS AS IDENTITY:

- PostgreSQL automatically generates the ID.
- The application normally does not provide the ID manually.
- Recommended for new PostgreSQL projects.

PRIMARY KEY:

- Uniquely identifies each row.
- Must be unique.
- Cannot be NULL.
- A table can have only one primary key constraint.
*/


CREATE TABLE users
(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(128),
    email VARCHAR(128) UNIQUE
);


/*
Important:

Do not define PRIMARY KEY twice.

Wrong:

    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PRIMARY KEY (id)

Both lines declare the same primary key.

Use only one of these styles:

Style 1:

    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY

Style 2:

    id INTEGER GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY (id)
*/


-- Insert rows without manually providing the ID.

INSERT INTO users (name, email)
VALUES
    ('John', 'john@gmail.com'),
    ('Maria', 'maria@gmail.com'),
    ('Zhang', 'zhang@gmail.com');


-- PostgreSQL generates the IDs automatically.

SELECT *
FROM users;


/*
Expected result:

id | name  | email
---+-------+------------------
1  | John  | john@gmail.com
2  | Maria | maria@gmail.com
3  | Zhang | zhang@gmail.com
*/


-- =====================================================================
--                              SERIAL
-- =====================================================================

/*
SERIAL:

- Old PostgreSQL shortcut for auto-generating increasing integer IDs.
- Generates IDs like: 1, 2, 3...
- SERIAL is not a real PostgreSQL data type.
- Internally, PostgreSQL creates an integer column and a sequence.
- Still supported because a lot of older PostgreSQL code uses it.
*/


-- Old syntax:

-- CREATE TABLE users (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(128),
--     email VARCHAR(128) UNIQUE
-- );


/*
SERIAL roughly performs these operations internally:

CREATE SEQUENCE users_id_seq;

CREATE TABLE users (
    id INTEGER DEFAULT 487('users_id_seq'),
    name VARCHAR(128),
    email VARCHAR(128)
);

A sequence is a PostgreSQL object that generates increasing numbers.

Example:

    nextval('users_id_seq')

Possible results:

    1
    2
    3
    4
*/


-- MODERN POSTGRESQL RECOMMENDATION:

-- id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY


/*
SERIAL vs IDENTITY:

SERIAL:
    - Older PostgreSQL-specific shortcut.
    - Uses a sequence internally.
    - Still valid, but less explicit.

IDENTITY:
    - Modern SQL-standard syntax.
    - Better integrated with the table definition.
    - Recommended for new PostgreSQL projects.
*/


-- =====================================================================
--                           PRIMARY KEY
-- =====================================================================

/*
PRIMARY KEY:

- Uniquely identifies each row.
- Must be unique.
- Cannot be NULL.
- A table can have only one primary key constraint.

Primary key = identity of a row.
Foreign key = reference to another row.
*/


-- Valid primary key lookup:

SELECT *
FROM users
WHERE id = 1;


/*
The following insert would fail because ID values are generated automatically:

INSERT INTO users (id, name, email)
VALUES (100, 'Ahmed', 'ahmed@gmail.com');

GENERATED ALWAYS prevents manually inserting an ID unless PostgreSQL is
explicitly told to override the identity behavior.
*/


-- =====================================================================
--                              INDEXES
-- =====================================================================

/*
INDEXES:

- As a table grows, scanning all rows to find one row becomes expensive.
- Example: finding one user's login data among hundreds of millions of users.
- Indexes create and maintain shortcut data structures to reduce scanning.
- Common index structures include B-trees and hash indexes.
*/


/*
Without an index, PostgreSQL may perform a sequential scan:

row 1
row 2
row 3
row 4
...
row 500,000,000

It checks rows until it finds matching data.

With an index, PostgreSQL can use a shortcut to locate matching rows.
*/


-- Create an index on the name column.

CREATE INDEX idx_users_name
ON users (name);


-- This query may use the name index.

SELECT *
FROM users
WHERE name = 'Maria';


/*
Important:

The users table already has indexes automatically created for:

- id, because it is a PRIMARY KEY.
- email, because it has a UNIQUE constraint.

PRIMARY KEY and UNIQUE constraints automatically create unique B-tree indexes.
*/


-- View indexes created for the users table.

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'users';


-- =====================================================================
--                              B-TREES
-- =====================================================================

/*
B-TREE INDEX:

- PostgreSQL's default and most common index type.
- Stores sorted values in a balanced tree.
- Fast for =, <, >, <=, >=, BETWEEN, ORDER BY, and prefix lookups.
- Keeps searches efficient even as the table grows.
*/


/*
A B-tree is a sorted tree PostgreSQL uses to find values quickly
without checking every row.

Think:

                 50
              /      \
           20          80
         /   \        /   \
       10    30      60    90

Looking for 60:

50 -> go right
80 -> go left
60 -> found

So instead of scanning:

row 1
row 2
row 3
...
row 1,000,000

PostgreSQL jumps through only a few tree levels.
*/


/*
B-tree indexes are useful for queries such as:

WHERE age = 25
WHERE age > 25
WHERE age BETWEEN 20 AND 30
ORDER BY age
*/


-- Add an age column for testing.

ALTER TABLE users
ADD COLUMN age INTEGER;


UPDATE users
SET age =
    CASE id
        WHEN 1 THEN 25
        WHEN 2 THEN 32
        WHEN 3 THEN 29
    END;


-- Create a B-tree index.
-- USING BTREE is optional because B-tree is the default.

CREATE INDEX idx_users_age
ON users USING BTREE (age);


-- Equality lookup.

SELECT *
FROM users
WHERE age = 25;


-- Range lookup.

SELECT *
FROM users
WHERE age > 25;


-- BETWEEN lookup.

SELECT *
FROM users
WHERE age BETWEEN 20 AND 30;


-- Sorting.

SELECT *
FROM users
ORDER BY age;


/*
B-tree means:

A sorted shortcut tree used for fast searching, ranges and sorting.
*/


-- =====================================================================
--                              HASHES
-- =====================================================================

/*
A hash index turns a value into a hash code, then uses that code
to jump directly to a bucket containing possible matching rows.

Think:

email = 'john@gmail.com'
        |
        v
    hash function
        |
        v
      847291
        |
        v
   bucket 847291
        |
        v
   matching row
*/


/*
Hash indexes are mainly useful for exact equality:

WHERE email = 'john@gmail.com'

Hash indexes are not useful for:

WHERE age > 25
ORDER BY age
WHERE age BETWEEN 20 AND 30

Why?

Hash indexes do not store values in sorted order.
They only map a value to a hash bucket.
*/


-- Create a hash index.

CREATE INDEX idx_users_name_hash
ON users USING HASH (name);


-- Exact equality query.

SELECT *
FROM users
WHERE name = 'John';


/*
In PostgreSQL, B-tree is usually preferred because it supports:

- Equality
- Range comparisons
- BETWEEN
- ORDER BY
- Prefix matching in some cases

Hash indexes mainly support equality comparisons using =.
*/


-- =====================================================================
--                         B-TREE VS HASH
-- =====================================================================

/*
B-TREE:

- Default PostgreSQL index.
- Stores values in sorted order.
- Supports equality searches.
- Supports range searches.
- Supports sorting.
- Best general-purpose choice.

HASH:

- Converts values into hash codes.
- Best suited for exact equality searches.
- Does not support range searches.
- Does not help with sorting.
- More specialized and less commonly used.
*/


-- =====================================================================
--                         INDEX TRADE-OFFS
-- =====================================================================

/*
Indexes improve reads, but they are not free.

Benefits:

- Faster SELECT queries.
- Faster WHERE lookups.
- Faster JOIN operations.
- Faster sorting in some cases.

Costs:

- Extra disk storage.
- Slower INSERT operations.
- Slower UPDATE operations.
- Slower DELETE operations.
- PostgreSQL must update indexes whenever indexed data changes.

Do not create indexes on every column.

Good index candidates:

- Columns frequently used in WHERE.
- Columns frequently used in JOIN.
- Foreign-key columns.
- Columns frequently used in ORDER BY.
- Columns that must be unique.
*/


-- =====================================================================
--                         EXPLAIN QUERY PLAN
-- =====================================================================

/*
EXPLAIN:

- Shows how PostgreSQL plans to execute a query.
- Does not execute the query.

EXPLAIN ANALYZE:

- Executes the query.
- Shows the actual execution time and row counts.

For tiny tables, PostgreSQL may ignore an index and use a sequential scan.
That is normal because scanning three rows can be cheaper than using an index.
*/


EXPLAIN
SELECT *
FROM users
WHERE age = 25;


EXPLAIN ANALYZE
SELECT *
FROM users
WHERE age = 25;