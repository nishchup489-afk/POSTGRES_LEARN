-- =====================================================================
--                     MANY-TO-MANY RELATIONSHIP
-- =====================================================================

/*
A many-to-many relationship means:

    One student can join many courses.

and:

    One course can contain many students.

Example:

    John joins PostgreSQL and Python.

    PostgreSQL contains John and Sara.

Neither the student table nor the course table can store this relationship
with only one foreign key.

We need a third table called a junction table.
*/


-- =====================================================================
--                         STUDENT TABLE
-- =====================================================================

/*
The student table stores each student once.

Primary key:

    student.id
*/

CREATE TABLE student (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(40),
    name VARCHAR(30)
);


-- =====================================================================
--                          COURSE TABLE
-- =====================================================================

/*
The course table stores each course once.

Primary key:

    course.id
*/

CREATE TABLE course (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(30)
);


-- =====================================================================
--                     JUNCTION TABLE: MEMBER
-- =====================================================================

/*
The member table connects students and courses.

Each row represents one membership.

Example:

course_id | student_id
----------+-----------
1         | 1

means:

    Student 1 is enrolled in Course 1.


Foreign keys:

    member.student_id references student.id

    member.course_id references course.id
*/

CREATE TABLE member (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    course_id INTEGER
        REFERENCES course(id)
        ON DELETE CASCADE,

    student_id INTEGER
        REFERENCES student(id)
        ON DELETE CASCADE,

    UNIQUE (course_id, student_id)
);


/*
The UNIQUE constraint prevents the same student from joining the same
course more than once.
*/


-- =====================================================================
--                          INSERT STUDENTS
-- =====================================================================

INSERT INTO student (email, name)
VALUES
    ('john@example.com', 'John'),
    ('sara@example.com', 'Sara'),
    ('mike@example.com', 'Mike');


-- =====================================================================
--                           INSERT COURSES
-- =====================================================================

INSERT INTO course (title)
VALUES
    ('PostgreSQL'),
    ('Python'),
    ('Data Structures');


-- =====================================================================
--                       INSERT RELATIONSHIPS
-- =====================================================================

/*
Assuming:

Students:

1 = John
2 = Sara
3 = Mike


Courses:

1 = PostgreSQL
2 = Python
3 = Data Structures
*/

INSERT INTO member (course_id, student_id)
VALUES
    (1, 1), -- John joins PostgreSQL
    (1, 2), -- Sara joins PostgreSQL
    (2, 1), -- John joins Python
    (2, 3), -- Mike joins Python
    (3, 2); -- Sara joins Data Structures


-- =====================================================================
--                    RECONSTRUCT THE RELATIONSHIP
-- =====================================================================

/*
The member table stores only IDs.

To display student names and course titles, we JOIN all three tables.
*/

SELECT
    student.name AS student,
    course.title AS course
FROM student
JOIN member
    ON student.id = member.student_id
JOIN course
    ON course.id = member.course_id;


/*
How the JOIN works:

1. student.id matches member.student_id

2. course.id matches member.course_id

3. SQL combines the matching rows
*/


-- =====================================================================
--                       RELATIONSHIP DIAGRAM
-- =====================================================================

/*
student
    |
    | one student has many memberships
    v
member
    ^
    | one course has many memberships
    |
course


Together:

    student many <---- member ----> many course
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
MANY-TO-MANY RELATIONSHIP:

    One student can join many courses.

    One course can contain many students.


JUNCTION TABLE:

    member


The junction table contains:

    student_id
    course_id


These foreign keys connect the two main tables.

The member table converts one many-to-many relationship into two
one-to-many relationships.
*/