-- =====================================================================
--                  DISTINCT, DISTINCT ON & GROUP BY
-- =====================================================================

/*
Sometimes a table contains duplicate values.

SQL provides three common ways to handle them:

1. DISTINCT
    Remove duplicate rows.

2. DISTINCT ON (PostgreSQL only)
    Remove duplicates based on specific columns.

3. GROUP BY
    Group rows together for aggregation.
*/


-- =====================================================================
--                         SAMPLE TABLE
-- =====================================================================

CREATE TABLE cars (
    make VARCHAR(30),
    model VARCHAR(30),
    year INTEGER,
    price INTEGER
);

INSERT INTO cars (make, model, year, price)
VALUES
    ('Nissan', 'Stanza', 1990, 2000),
    ('Dodge', 'Neon', 1995, 800),
    ('Dodge', 'Neon', 1998, 2500),
    ('Dodge', 'Neon', 1999, 3000),
    ('Ford', 'Mustang', 2001, 1000),
    ('Ford', 'Mustang', 2005, 2000),
    ('Subaru', 'Impreza', 1997, 1000),
    ('Mazda', 'Miata', 2001, 5000),
    ('Mazda', 'Miata', 2001, 3000),
    ('Mazda', 'Miata', 2001, 2500),
    ('Mazda', 'Miata', 2002, 5500),
    ('Opel', 'GT', 1972, 1500),
    ('Opel', 'GT', 1969, 7500),
    ('Opel', 'Cadet', 1973, 500);


-- =====================================================================
--                            DISTINCT
-- =====================================================================

/*
DISTINCT removes duplicate rows.

Only the selected columns are considered.
*/

SELECT DISTINCT make
FROM cars;


/*
Result

Dodge
Ford
Mazda
Nissan
Opel
Subaru
*/


/*
Multiple columns
*/

SELECT DISTINCT make, model
FROM cars;


/*
Now uniqueness is determined by BOTH columns.

Mazda Miata

appears once even though it has multiple rows.
*/


-- =====================================================================
--                    DISTINCT DOES NOT MODIFY TABLE
-- =====================================================================

/*
DISTINCT only changes the query result.

It never deletes rows from the table.
*/


-- =====================================================================
--                     DISTINCT ON (PostgreSQL)
-- =====================================================================

/*
DISTINCT ON removes duplicates based
on selected columns.

Syntax

DISTINCT ON (column)
*/

SELECT DISTINCT ON (make)
make, model, year, price
FROM cars;


/*
One row is returned for each make.

Which row?

Without ORDER BY,
PostgreSQL chooses one arbitrarily.
*/


-- =====================================================================
--          DISTINCT ON + ORDER BY ⭐ Most Common Usage
-- =====================================================================

/*
Choose the newest car for each make.
*/

SELECT DISTINCT ON (make)
make,
model,
year,
price
FROM cars
ORDER BY make, year DESC;


/*
Result

Newest Nissan
Newest Dodge
Newest Ford
Newest Mazda
Newest Opel
Newest Subaru
*/


/*
Choose the cheapest car for each make.
*/

SELECT DISTINCT ON (make)
make,
model,
price
FROM cars
ORDER BY make, price;


-- =====================================================================
--                            GROUP BY
-- =====================================================================

/*
GROUP BY combines rows
that have the same value.

Usually used with aggregate functions.
*/

SELECT make
FROM cars
GROUP BY make;


/*
Produces the same result as

SELECT DISTINCT make

but GROUP BY is mainly
used for aggregation.
*/


-- =====================================================================
--                       COUNT()
-- =====================================================================

/*
Count how many cars each make has.
*/

SELECT
    make,
    COUNT(*)
FROM cars
GROUP BY make;


/*
Example

Mazda     4
Dodge     3
Ford      2
...
*/


-- =====================================================================
--                          SUM()
-- =====================================================================

/*
Total price of cars
for each make.
*/

SELECT
    make,
    SUM(price)
FROM cars
GROUP BY make;


-- =====================================================================
--                          AVG()
-- =====================================================================

/*
Average price
for each make.
*/

SELECT
    make,
    AVG(price)
FROM cars
GROUP BY make;


-- =====================================================================
--                          MAX()
-- =====================================================================

/*
Highest price
for each make.
*/

SELECT
    make,
    MAX(price)
FROM cars
GROUP BY make;


-- =====================================================================
--                          MIN()
-- =====================================================================

/*
Lowest price
for each make.
*/

SELECT
    make,
    MIN(price)
FROM cars
GROUP BY make;


-- =====================================================================
--                     GROUP BY MULTIPLE COLUMNS
-- =====================================================================

/*
Group by make and model.
*/

SELECT
    make,
    model,
    COUNT(*)
FROM cars
GROUP BY make, model;


-- =====================================================================
--                          WHERE
-- =====================================================================

/*
WHERE filters rows
BEFORE grouping.
*/

SELECT
    make,
    COUNT(*)
FROM cars
WHERE year >= 2000
GROUP BY make;


-- =====================================================================
--                          HAVING
-- =====================================================================

/*
HAVING filters groups
AFTER grouping.

Cannot use aggregate functions in WHERE.
*/

SELECT
    make,
    COUNT(*)
FROM cars
GROUP BY make
HAVING COUNT(*) > 2;


/*
Returns only makes
having more than 2 cars.
*/


-- =====================================================================
--                  WHERE vs HAVING
-- =====================================================================

/*
WHERE

Filters individual rows
before GROUP BY.


HAVING

Filters grouped results
after GROUP BY.
*/


-- =====================================================================
--                     EXECUTION ORDER
-- =====================================================================

/*
SQL processes a query roughly like this:

FROM

↓

WHERE

↓

GROUP BY

↓

HAVING

↓

SELECT

↓

DISTINCT

↓

ORDER BY

↓

LIMIT
*/


-- =====================================================================
--                          SUMMARY
-- =====================================================================

/*
DISTINCT

    Removes duplicate rows.

DISTINCT ON

    PostgreSQL feature.

    Removes duplicates based
    on specified columns.

    Usually used with ORDER BY.

GROUP BY

    Groups rows together.

    Commonly used with

        COUNT()
        SUM()
        AVG()
        MIN()
        MAX()

WHERE

    Filters rows before grouping.

HAVING

    Filters groups after grouping.


Core idea

DISTINCT
    Unique rows.

DISTINCT ON
    One row per group.

GROUP BY
    Summarize groups with aggregate functions.
*/