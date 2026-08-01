-- =====================================================================
--              STORED PROCEDURES, FUNCTIONS & TRIGGERS
-- =====================================================================

/*
A stored procedure is reusable logic stored inside PostgreSQL.

Instead of the application sending many SQL statements separately,
it can call one database routine.

PostgreSQL has:

    FUNCTION
        Returns a value or table.
        Can be used inside SELECT statements.

    PROCEDURE
        Performs actions.
        Called using CALL.

    TRIGGER FUNCTION
        Runs automatically when INSERT, UPDATE, or DELETE happens.
*/


-- =====================================================================
--                    WHY STORED ROUTINES EXIST
-- =====================================================================

/*
Without a stored routine:

Application
    ↓
SQL statement 1
    ↓
SQL statement 2
    ↓
SQL statement 3


With a stored routine:

Application
    ↓
Call one database routine
    ↓
PostgreSQL performs all operations
*/


/*
Possible advantages:

    - Reusable database logic
    - Fewer network round trips
    - Can group multiple operations
    - Useful for triggers
    - Logic runs close to the data


Possible disadvantages:

    - Harder to test than normal application code
    - PostgreSQL-specific syntax
    - Harder to migrate to another database
    - Business logic can become hidden inside the database
    - Can make maintenance more complicated


Practical rule:

Do not move everything into stored procedures.

Use them when there is a clear reason.
*/


-- =====================================================================
--                      SIMPLE SQL FUNCTION
-- =====================================================================

/*
This function accepts two integers
and returns their sum.
*/

CREATE OR REPLACE FUNCTION add_numbers(
    first_number INTEGER,
    second_number INTEGER
)
RETURNS INTEGER
LANGUAGE SQL
AS $$

    SELECT first_number + second_number;

$$;


/*
Call the function:
*/

SELECT add_numbers(10, 20);


/*
Result:

30
*/


-- =====================================================================
--                    FUNCTION WITH TABLE DATA
-- =====================================================================

CREATE TABLE employees (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(40),
    salary INTEGER
);

INSERT INTO employees (name, salary)
VALUES
    ('Alice', 80000),
    ('Bob', 60000),
    ('Charlie', 50000);


/*
Function that returns an employee's salary.
*/

CREATE OR REPLACE FUNCTION get_employee_salary(
    employee_id INTEGER
)
RETURNS INTEGER
LANGUAGE SQL
AS $$

    SELECT salary
    FROM employees
    WHERE id = employee_id;

$$;


/*
Call it:
*/

SELECT get_employee_salary(1);


/*
Because a function returns a value,
it can be used inside another query.
*/

SELECT
    name,
    salary,
    get_employee_salary(id)
FROM employees;


-- =====================================================================
--                     SIMPLE STORED PROCEDURE
-- =====================================================================

/*
A procedure performs operations.

Unlike a function, it is called with CALL.
*/

CREATE OR REPLACE PROCEDURE increase_salary(
    employee_id INTEGER,
    amount INTEGER
)
LANGUAGE SQL
AS $$

    UPDATE employees
    SET salary = salary + amount
    WHERE id = employee_id;

$$;


/*
Call the procedure:
*/

CALL increase_salary(1, 5000);


/*
Check the result:
*/

SELECT *
FROM employees
WHERE id = 1;


-- =====================================================================
--                    FUNCTION vs PROCEDURE
-- =====================================================================

/*
FUNCTION

    Called with SELECT

        SELECT function_name(...);

    Usually returns something

    Can be used inside SQL expressions


PROCEDURE

    Called with CALL

        CALL procedure_name(...);

    Usually performs actions

    Not used directly inside SELECT expressions
*/


-- =====================================================================
--                       PL/pgSQL FUNCTION
-- =====================================================================

/*
LANGUAGE SQL is good for simple SQL logic.

LANGUAGE plpgsql supports:

    - Variables
    - IF statements
    - Loops
    - Multiple statements
*/


CREATE OR REPLACE FUNCTION salary_level(
    employee_salary INTEGER
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$

BEGIN

    IF employee_salary >= 80000 THEN
        RETURN 'High';

    ELSIF employee_salary >= 50000 THEN
        RETURN 'Medium';

    ELSE
        RETURN 'Low';

    END IF;

END;

$$;


/*
Call it:
*/

SELECT salary_level(70000);


/*
Result:

Medium
*/


-- =====================================================================
--                     UPDATED_AT EXAMPLE
-- =====================================================================

CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


/*
DEFAULT NOW() sets updated_at during INSERT.

But it does not automatically change updated_at
when the row is updated.

For that, we can create a trigger function.
*/


-- =====================================================================
--                     TRIGGER FUNCTION
-- =====================================================================

/*
A trigger function contains logic
that a trigger will execute.

NEW represents the new version of the row.
*/

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$

BEGIN

    NEW.updated_at = NOW();

    RETURN NEW;

END;

$$;


/*
NEW.updated_at = NOW()

changes updated_at in the new row.


RETURN NEW

returns the modified row
to PostgreSQL.
*/


-- =====================================================================
--                         CREATE TRIGGER
-- =====================================================================

/*
The trigger connects the function
to the users table.
*/

CREATE TRIGGER users_set_updated_at

BEFORE UPDATE
ON users

FOR EACH ROW

EXECUTE FUNCTION set_updated_at();


/*
Meaning:

BEFORE UPDATE
    Run before PostgreSQL updates the row.

ON users
    Trigger belongs to the users table.

FOR EACH ROW
    Run once for every updated row.

EXECUTE FUNCTION
    Run the trigger function.
*/


-- =====================================================================
--                         TEST TRIGGER
-- =====================================================================

INSERT INTO users (name)
VALUES ('Alice');


SELECT *
FROM users;


/*
Later:
*/

UPDATE users
SET name = 'Alice Smith'
WHERE id = 1;


/*
PostgreSQL automatically runs:

set_updated_at()

So updated_at changes automatically.
*/


SELECT *
FROM users
WHERE id = 1;


-- =====================================================================
--                    OLD AND NEW RECORDS
-- =====================================================================

/*
Inside a trigger function:

OLD
    Row before the operation.

NEW
    Row after the new values are applied.


For UPDATE:

    OLD.name
        Previous name

    NEW.name
        New name


For INSERT:

    NEW is available.

For DELETE:

    OLD is available.
*/


-- =====================================================================
--                         DROP ROUTINES
-- =====================================================================

/*
Drop a function:
*/

DROP FUNCTION add_numbers(INTEGER, INTEGER);


/*
PostgreSQL includes parameter types
because multiple functions may have
the same name with different parameters.
*/


/*
Drop a procedure:
*/

DROP PROCEDURE increase_salary(INTEGER, INTEGER);


/*
Drop a trigger:
*/

DROP TRIGGER users_set_updated_at
ON users;


/*
Dropping the trigger does not automatically
drop the trigger function.
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
FUNCTION

    Stored database logic
    Usually returns a result
    Called using SELECT


PROCEDURE

    Stored database operation
    Called using CALL


TRIGGER FUNCTION

    Function executed automatically
    by a trigger


TRIGGER

    Decides when the trigger function runs

    INSERT
    UPDATE
    DELETE


updated_at pattern:

    1. Create updated_at column

    2. Create trigger function

    3. Set NEW.updated_at = NOW()

    4. Create BEFORE UPDATE trigger


Core idea:

Stored routines keep reusable logic inside PostgreSQL.

They can reduce application-to-database communication,
but they also make the system less portable and harder to maintain.

Use them when the database itself
is the best place for the logic.
*/