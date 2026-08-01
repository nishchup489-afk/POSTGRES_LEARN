-- =====================================================================
--                     POSTGRESQL DATE & TIME
-- =====================================================================

/*
Date & Time Types

DATE         -> Date only
TIME         -> Time only
TIMESTAMP    -> Date + Time (No timezone)
TIMESTAMPTZ  -> Date + Time (With timezone) ⭐ Recommended

In real applications, TIMESTAMPTZ is usually the best choice.
*/


--     Think of the order
-- FROM
--
-- ↓
--
-- WHERE
--
-- ↓
--
-- GROUP BY
--
-- ↓
--
-- HAVING
--
-- ↓
--
-- SELECT

-- =====================================================================
--                              DATE
-- =====================================================================

/*
Stores only the calendar date.
*/
drop table if exists users CASCADE;
CREATE TABLE users (
    birthday DATE
);

INSERT INTO users (birthday)
VALUES ('2007-05-12');


/*
Result

2007-05-12
*/


-- =====================================================================
--                              TIME
-- =====================================================================

/*
Stores only the time.
*/

CREATE TABLE schedule (
    start_time TIME
);

INSERT INTO schedule
VALUES ('09:30:00');


-- =====================================================================
--                           TIMESTAMP
-- =====================================================================

/*
Stores date and time.

No timezone information is stored.
*/

CREATE TABLE orders (
    ordered_at TIMESTAMP
);

INSERT INTO orders
VALUES ('2026-07-31 15:20:00');


-- =====================================================================
--                         TIMESTAMPTZ
-- =====================================================================

/*
Stores date and time with timezone.

Recommended for almost all real-world applications.
*/

CREATE TABLE events (
    starts_at TIMESTAMPTZ
);

INSERT INTO events
VALUES ('2026-07-31 15:20:00-04');


/*
PostgreSQL stores the moment internally
and converts it to the user's timezone.
*/


-- =====================================================================
--                      CURRENT DATE & TIME
-- =====================================================================

/*
NOW() returns

Date
Time
Timezone
*/

SELECT NOW();


/*
CURRENT_DATE returns only today's date.
*/

SELECT CURRENT_DATE;


/*
CURRENT_TIME returns only the current time.
*/

SELECT CURRENT_TIME;


-- =====================================================================
--                     DEFAULT TIMESTAMP
-- =====================================================================

/*
Automatically save when a row is created.
*/

CREATE TABLE products (

    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    created_at TIMESTAMPTZ DEFAULT NOW()

);


/*
No need to manually insert created_at.
*/

INSERT INTO products DEFAULT VALUES;


-- =====================================================================
--                           UPDATED_AT
-- =====================================================================

/*
Common design

created_at
updated_at

Both usually start with NOW().

updated_at is commonly updated
using a PostgreSQL trigger.
*/

CREATE TABLE users (

    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()

);


-- =====================================================================
--                             INTERVAL
-- =====================================================================

/*
INTERVAL represents a duration of time.
*/

INTERVAL '1 day'

INTERVAL '7 days'

INTERVAL '2 hours'

INTERVAL '15 minutes'

INTERVAL '1 month'

INTERVAL '2 years'


-- =====================================================================
--                       DATE ARITHMETIC
-- =====================================================================

/*
Tomorrow
*/

SELECT NOW() + INTERVAL '1 day';


/*
Yesterday
*/

SELECT NOW() - INTERVAL '1 day';


/*
One week ago
*/

SELECT NOW() - INTERVAL '7 days';


/*
One month later
*/

SELECT NOW() + INTERVAL '1 month';


-- =====================================================================
--                     FILTER RECENT RECORDS
-- =====================================================================

/*
Rows created during the last 7 days.
*/

SELECT *
FROM products
WHERE created_at >= NOW() - INTERVAL '7 days';


/*
Rows created during the last hour.
*/

SELECT *
FROM products
WHERE created_at >= NOW() - INTERVAL '1 hour';


-- =====================================================================
--                            CASTING
-- =====================================================================

/*
Convert timestamp into only the date.
*/

SELECT NOW()::DATE;


/*
Convert timestamp into only the time.
*/

SELECT NOW()::TIME;


/*
Equivalent syntax
*/

SELECT CAST(NOW() AS DATE);

SELECT CAST(NOW() AS TIME);


-- =====================================================================
--                          DATE_TRUNC()
-- =====================================================================

/*
DATE_TRUNC() rounds a timestamp
to a specified unit.
*/

SELECT DATE_TRUNC('day', NOW());

SELECT DATE_TRUNC('month', NOW());

SELECT DATE_TRUNC('year', NOW());

SELECT DATE_TRUNC('hour', NOW());


/*
Examples

2026-07-31 18:42:51

↓

DATE_TRUNC('day')

2026-07-31 00:00:00
*/


-- =====================================================================
--                        EXTRACT()
-- =====================================================================

/*
Extract a single part of a date/time.
*/

SELECT EXTRACT(YEAR FROM NOW());

SELECT EXTRACT(MONTH FROM NOW());

SELECT EXTRACT(DAY FROM NOW());

SELECT EXTRACT(HOUR FROM NOW());

SELECT EXTRACT(MINUTE FROM NOW());


-- =====================================================================
--                      PERFORMANCE NOTE
-- =====================================================================

/*
Good

WHERE created_at >= NOW() - INTERVAL '7 days'

Uses indexes efficiently.


Avoid

WHERE created_at::DATE = CURRENT_DATE

May prevent PostgreSQL from using indexes,
leading to slower queries on large tables.
*/


-- =====================================================================
--                             SUMMARY
-- =====================================================================

/*
DATE
    Calendar date only

TIME
    Time only

TIMESTAMP
    Date + Time
    No timezone

TIMESTAMPTZ
    Date + Time
    With timezone ⭐

NOW()
    Current date and time

CURRENT_DATE
    Today's date

CURRENT_TIME
    Current time

INTERVAL
    Time duration

DATE_TRUNC()
    Round timestamps

EXTRACT()
    Get individual date/time parts

Core idea:

Use TIMESTAMPTZ for most applications,
store timestamps automatically with DEFAULT NOW(),
and use INTERVAL for date calculations.
*/




-- # Think of the order
--
-- ```sql
-- FROM
--
-- ↓
--
-- WHERE
--
-- ↓
--
-- GROUP BY
--
-- ↓
--
-- HAVING
--
-- ↓
--
-- SELECT
-- ```
--
-- The important part is
--
-- ```
-- WHERE
-- ```
--
-- works on **rows**
--
-- while
--
-- ```
-- HAVING
-- ```
--
-- works on **groups**.
--
-- ---
--
-- # Example table
--
-- | make  | price |
-- | ----- | ----: |
-- | Mazda |  5000 |
-- | Mazda |  3000 |
-- | Mazda |  2500 |
-- | Ford  |  1000 |
-- | Ford  |  2000 |
-- | Dodge |   800 |
--
-- ---
--
-- # GROUP BY
--
-- ```sql
-- SELECT
--     make,
--     COUNT(*)
-- FROM cars
-- GROUP BY make;
-- ```
--
-- SQL first creates groups
--
-- ```text
-- Mazda
-- ------
-- 5000
-- 3000
-- 2500
--
-- Ford
-- -----
-- 1000
-- 2000
--
-- Dodge
-- ------
-- 800
-- ```
--
-- Then counts them
--
-- | make  | count |
-- | ----- | ----: |
-- | Mazda |     3 |
-- | Ford  |     2 |
-- | Dodge |     1 |
--
-- ---
--
-- # Now suppose I only want companies with at least 2 cars.
--
-- Can I do this?
--
-- ```sql
-- SELECT
--     make,
--     COUNT(*)
-- FROM cars
-- WHERE COUNT(*) >= 2
-- GROUP BY make;
-- ```
--
-- ❌ No.
--
-- Why?
--
-- Because **WHERE happens before GROUP BY.**
--
-- At the WHERE stage,
--
-- there are **no groups yet**.
--
-- SQL only sees individual rows.
--
-- ---
--
-- # That's why HAVING exists.
--
-- ```sql
-- SELECT
--     make,
--     COUNT(*)
-- FROM cars
-- GROUP BY make
-- HAVING COUNT(*) >= 2;
-- ```
--
-- Now SQL says
--
-- ```
-- Step 1
--
-- Create groups
--
-- ↓
--
-- Step 2
--
-- Count each group
--
-- ↓
--
-- Step 3
--
-- Remove groups
-- whose count < 2
-- ```
--
-- Result
--
-- | make  | count |
-- | ----- | ----: |
-- | Mazda |     3 |
-- | Ford  |     2 |
--
-- Dodge disappears because it only has one row.
--
-- ---
--
-- # Another example
--
-- Average price greater than 2500
--
-- ```sql
-- SELECT
--     make,
--     AVG(price)
-- FROM cars
-- GROUP BY make
-- HAVING AVG(price) > 2500;
-- ```
--
-- SQL does
--
-- ```text
-- Mazda
--
-- 5000
-- 3000
-- 2500
--
-- ↓
--
-- Average = 3500 ✅
--
--
-- Ford
--
-- 1000
-- 2000
--
-- ↓
--
-- Average = 1500 ❌
-- ```
--
-- Only Mazda is returned.
--
-- ---
--
-- # WHERE vs HAVING
--
-- Suppose you want
--
-- > Only consider cars made after 2000, then show companies that have at least 2 such cars.
--
-- ```sql
-- SELECT
--     make,
--     COUNT(*)
-- FROM cars
-- WHERE year >= 2000
-- GROUP BY make
-- HAVING COUNT(*) >= 2;
-- ```
--
-- Read it like English:
--
-- ```
-- WHERE
--
-- Throw away old cars.
--
-- ↓
--
-- GROUP BY
--
-- Group remaining cars by make.
--
-- ↓
--
-- HAVING
--
-- Keep only groups with
-- 2 or more cars.
-- ```
--
-- ---
--
-- # The easiest way to remember it
--
-- Imagine you're sorting exam papers.
--
-- ### WHERE 🚪
--
-- Stops students at the door.
--
-- ```
-- Only students older than 18
-- may enter.
-- ```
--
-- Rows are filtered **before** grouping.
--
-- ---
--
-- ### GROUP BY 📁
--
-- Put papers into folders.
--
-- ```
-- Math
--
-- Physics
--
-- Chemistry
-- ```
--
-- ---
--
-- ### HAVING 🗑️
--
-- Now throw away entire folders.
--
-- ```
-- Keep only subjects
-- with at least 20 students.
-- ```
--
-- HAVING never removes **individual rows**.
--
-- It removes **entire groups**.
--
-- ---
--
-- # Rule to memorize ⭐
--
-- * **WHERE** → filters **rows** (before grouping).
-- * **GROUP BY** → creates **groups**.
-- * **HAVING** → filters **groups** (after grouping).
--
-- That's the entire concept. Once you're comfortable with this flow, 90% of `GROUP BY`/`HAVING` interview questions become much easier.
