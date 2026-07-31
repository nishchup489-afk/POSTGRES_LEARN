-- https://blog.codinghorror.com/a-visual-explanation-of-sql-joins/

CREATE table left_table (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    customer VARCHAR(30)
);


CREATE TABLE right_table (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    level VARCHAR(30)


);


INSERT INTO left_table (customer) VALUES ('ava');
INSERT INTO left_table (customer) VALUES ('bo');
INSERT INTO left_table (customer) VALUES ('Dee');

INSERT INTO right_table (level) VALUES ('Gold');
INSERT INTO right_table (level) VALUES ('Silver');
INSERT INTO right_table (level) VALUES ('Bronze');

SELECT * FROM left_table;
SELECT * FROM right_table;

SELECT
    left_table.customer_id ,
    left_table.customer,
    right_table.level
FROM left_table JOIN right_table ON left_table.customer_id = right_table.customer_id;



-- Create Table A

CREATE TABLE table_a (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);


-- Create Table B

CREATE TABLE table_b (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);


-- Insert data into Table A

INSERT INTO table_a (id, name)
VALUES
    (1, 'Pirate'),
    (2, 'Monkey'),
    (3, 'Ninja'),
    (4, 'Spaghetti');


-- Insert data into Table B

INSERT INTO table_b (id, name)
VALUES
    (1, 'Rutabaga'),
    (2, 'Pirate'),
    (3, 'Darth Vader'),
    (4, 'Ninja');


-- Check the data

SELECT * FROM table_a;
SELECT * FROM table_b;


-- INNER JOIN - Intersection only common

SELECT table_a.name  FROM table_a
INNER JOIN table_b
ON table_a.name = table_b.name;



-- FULL OUTER JOIN - all joins

SELECT table_a.name , table_b.name FROM table_a
FULL OUTER JOIN table_b ON table_a.name = table_b.name;


-- LEFT OUTER JOIN - take the left circle

SELECT table_a.name , table_b.name FROM table_a
LEFT OUTER JOIN table_b ON table_a.name = table_b.name;


-- RIGHT OUTER JOIN - opposite
SELECT table_a.name , table_b.name FROM table_a
RIGHT OUTER JOIN table_b ON table_a.name = table_b.name;


-- TABLE A excluding match
SELECT table_a.name FROM table_a
LEFT OUTER JOIN table_b ON table_a.name = table_b.name
                    WHERE table_b.name IS NULL;

SELECT table_b.name FROM table_b
LEFT OUTER JOIN table_a ON table_b.name = table_a.name
WHERE table_a.name IS NULL;


SELECT table_a.name FROM table_a CROSS JOIN table_b ;





