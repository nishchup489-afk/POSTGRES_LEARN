-- =====================================================================
--                          SUBQUERIES
-- =====================================================================

/*
A subquery is simply

a query inside another query.

The inner query executes first.

Its result is then used by the outer query.

Think:

First find X.

Then use X to find Y.
*/


-- =====================================================================
--                         SAMPLE TABLE
-- =====================================================================

CREATE TABLE employees (

    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name VARCHAR(30),

    department VARCHAR(30),

    salary INTEGER

);

INSERT INTO employees (name, department, salary)
VALUES
('Alice', 'Engineering', 90000),
('Bob', 'Engineering', 70000),
('Charlie', 'Marketing', 60000),
('David', 'Marketing', 50000),
('Eva', 'HR', 55000);


-- =====================================================================
--                     SIMPLE SUBQUERY
-- =====================================================================

/*
Question

Who earns the highest salary?
*/

SELECT *
FROM employees
WHERE salary =

(
    SELECT MAX(salary)
    FROM employees
);


/*
Execution

Step 1

SELECT MAX(salary)
FROM employees;

↓

90000


Step 2

Outer query becomes

WHERE salary = 90000
*/


-- =====================================================================
--                  SUBQUERY RETURNING ONE VALUE
-- =====================================================================

/*
Find employees earning more
than the average salary.
*/

SELECT *
FROM employees
WHERE salary >

(
    SELECT AVG(salary)
    FROM employees
);


/*
Inner query

AVG(salary)

↓

65000


Outer query

WHERE salary > 65000
*/


-- =====================================================================
--                  SUBQUERY WITH IN
-- =====================================================================

/*
When a subquery returns
multiple rows,

use IN instead of =.
*/


/*
Find employees who belong
to departments having
someone earning above 80000.
*/

SELECT *
FROM employees
WHERE department IN

(
    SELECT department
    FROM employees
    WHERE salary > 80000
);


/*
Inner query

Engineering


Outer query

WHERE department IN ('Engineering')
*/


-- =====================================================================
--                  SUBQUERY IN SELECT
-- =====================================================================

/*
A subquery can appear
inside SELECT.
*/

SELECT

    name,

    salary,

    (

        SELECT AVG(salary)
        FROM employees

    ) AS average_salary

FROM employees;


/*
Result

Alice     90000     65000

Bob       70000     65000

Charlie   60000     65000
*/


-- =====================================================================
--                   SUBQUERY IN FROM
-- =====================================================================

/*
A subquery can act
like a temporary table.
*/

SELECT *

FROM

(

    SELECT
        name,
        salary
    FROM employees

) AS emp;


/*
The subquery creates
a temporary table.

The outer query
uses that table.
*/


-- =====================================================================
--                     EXISTS
-- =====================================================================

/*
EXISTS checks whether
the subquery returns
at least one row.
*/

SELECT *
FROM employees e

WHERE EXISTS

(

    SELECT 1
    FROM employees
    WHERE department = e.department
      AND salary > 80000

);


/*
Returns employees belonging
to departments where
someone earns above 80000.
*/


-- =====================================================================
--                      NOT EXISTS
-- =====================================================================

/*
NOT EXISTS is the opposite.

The subquery must return
no rows.
*/

SELECT *
FROM employees e

WHERE NOT EXISTS

(

    SELECT 1
    FROM employees
    WHERE department = e.department
      AND salary > 80000

);


-- =====================================================================
--                     ANY / SOME
-- =====================================================================

/*
ANY means

compare against
at least one value.
*/

SELECT *
FROM employees
WHERE salary >

ANY

(

    SELECT salary
    FROM employees
    WHERE department = 'HR'

);


/*
Equivalent idea

salary is greater than
at least one HR salary.
*/


-- =====================================================================
--                           ALL
-- =====================================================================

/*
ALL means

compare against
every value.
*/

SELECT *
FROM employees
WHERE salary >

ALL

(

    SELECT salary
    FROM employees
    WHERE department = 'Marketing'

);


/*
Salary must be greater than
every Marketing salary.
*/


-- =====================================================================
--                     WHERE TO USE THEM
-- =====================================================================

/*
Subqueries commonly appear in

WHERE

SELECT

FROM

HAVING
*/


-- =====================================================================
--                      EXECUTION ORDER
-- =====================================================================

/*
Outer Query

↓

Needs a value

↓

Runs subquery

↓

Gets result

↓

Continues execution
*/


-- =====================================================================
--                      SINGLE vs MULTIPLE
-- =====================================================================

/*
One value

=

>

<

>=

<=


Multiple values

IN

ANY

ALL


Existence check

EXISTS

NOT EXISTS
*/


-- =====================================================================
--                         SUMMARY
-- =====================================================================

/*
A subquery is

a query inside another query.


Common uses

WHERE

SELECT

FROM

HAVING


Returns one value

MAX()

MIN()

AVG()

COUNT()

SUM()


Returns multiple values

IN

ANY

ALL


Checks existence

EXISTS

NOT EXISTS


Core idea

First solve a smaller query.

Then use its result
to solve the main query.
*/