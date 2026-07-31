-- =====================================================================
--                 ALTERING TABLE SCHEMAS IN POSTGRESQL
-- =====================================================================

/*
ALTER TABLE:

ALTER TABLE changes the structure of an existing table.

It allows us to:

    - Add columns
    - Remove columns
    - Rename columns
    - Rename tables
    - Change data types
    - Add or remove constraints
    - Add or remove default values

General syntax:

    ALTER TABLE table_name
    action;
*/


-- =====================================================================
--                         EXAMPLE TABLE
-- =====================================================================
DROP TABLE IF EXISTS student CASCADE;

CREATE TABLE student (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(40),
    name VARCHAR(30)
);

SELECT * FROM  student;

-- =====================================================================
--                         ADD A COLUMN
-- =====================================================================

/*
ADD COLUMN adds a new column to an existing table.
*/

ALTER TABLE student
    ADD COLUMN age INTEGER;


/*
A column can also be added with constraints and a default value.
*/

ALTER TABLE student
ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();


-- =====================================================================
--                       RENAME A COLUMN
-- =====================================================================

/*
RENAME COLUMN changes the name of an existing column.
*/

ALTER TABLE student
RENAME COLUMN name TO full_name;


-- =====================================================================
--                        RENAME A TABLE
-- =====================================================================

/*
RENAME TO changes the name of the table.
*/

ALTER TABLE student RENAME TO students;

-- =====================================================================
--                    CHANGE A COLUMN DATA TYPE
-- =====================================================================

/*
ALTER COLUMN ... TYPE changes the data type of a column.
*/

ALTER TABLE students
    ALTER COLUMN full_name TYPE VARCHAR(100);


/*
Sometimes PostgreSQL cannot automatically convert the existing values.

USING tells PostgreSQL how to convert them.
*/

ALTER TABLE students
ALTER COLUMN age TYPE VARCHAR(10)
USING age::VARCHAR;


-- =====================================================================
--                       ADD NOT NULL
-- =====================================================================

/*
NOT NULL prevents a column from containing NULL.

Before adding NOT NULL, existing NULL values must be fixed.
*/

UPDATE students
SET email = 'unknown@example.com'
WHERE email IS NULL;


ALTER TABLE students
ALTER COLUMN email SET NOT NULL;


/*
Remove the NOT NULL constraint:
*/

ALTER TABLE students
ALTER COLUMN email DROP NOT NULL;


-- =====================================================================
--                     ADD A DEFAULT VALUE
-- =====================================================================

/*
A default value is used when a new row is inserted without a value for
the column.
*/

ALTER TABLE students
ALTER COLUMN age SET DEFAULT '18';


/*
Remove the default value:
*/

ALTER TABLE students
ALTER COLUMN age DROP DEFAULT;


/*
A default affects future inserts.

It does not automatically update existing rows.
*/


-- =====================================================================
--                    ADD A UNIQUE CONSTRAINT
-- =====================================================================

/*
UNIQUE prevents duplicate values.
*/

ALTER TABLE students
ADD CONSTRAINT students_email_unique
UNIQUE (email);


/*
A UNIQUE constraint can also use multiple columns.
*/

ALTER TABLE roster
ADD CONSTRAINT roster_student_course_unique
UNIQUE (student_id, course_id);


/*
Remove a constraint:
*/

ALTER TABLE students
DROP CONSTRAINT students_email_unique;


-- =====================================================================
--                    ADD A FOREIGN KEY
-- =====================================================================

/*
A foreign key connects one table to another.
*/

ALTER TABLE roster
ADD CONSTRAINT roster_student_fk
FOREIGN KEY (student_id)
REFERENCES students(id)
ON DELETE CASCADE;


/*
Remove the foreign key constraint:
*/

ALTER TABLE roster
DROP CONSTRAINT roster_student_fk;


-- =====================================================================
--                      ADD A CHECK CONSTRAINT
-- =====================================================================

/*
CHECK limits which values are allowed in a column.
*/

ALTER TABLE roster
ADD CONSTRAINT roster_role_check
CHECK (role IN (0, 1));


/*
Now role can only contain:

    0
    1
*/


-- =====================================================================
--                         DROP A COLUMN
-- =====================================================================

/*
DROP COLUMN permanently removes a column and its data.
*/

ALTER TABLE students
DROP COLUMN age;


/*
CASCADE also removes objects that depend on the column.

Use it carefully.
*/

ALTER TABLE students
DROP COLUMN age CASCADE;


-- =====================================================================
--                       PRACTICAL EXAMPLE
-- =====================================================================

/*
Starting table:

CREATE TABLE student (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(40),
    name VARCHAR(30)
);
*/


ALTER TABLE student
RENAME COLUMN name TO full_name;


ALTER TABLE student
ALTER COLUMN email SET NOT NULL;


ALTER TABLE student
ADD CONSTRAINT student_email_unique
UNIQUE (email);


ALTER TABLE student
ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();


/*
Final structure:

    id
    email
    full_name
    created_at
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
ALTER TABLE changes an existing table.

Common operations:

    ADD COLUMN
    DROP COLUMN
    RENAME COLUMN
    RENAME TO
    ALTER COLUMN ... TYPE
    ALTER COLUMN ... SET NOT NULL
    ALTER COLUMN ... SET DEFAULT
    ADD CONSTRAINT
    DROP CONSTRAINT


Core idea:

ALTER TABLE modifies the schema without recreating the table.
*/