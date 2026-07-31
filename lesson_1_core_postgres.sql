-- CREATE TABLE COMMAND

CREATE TABLE users (
    name VARCHAR(128),
    age INTEGER ,
    email VARCHAR(128)
);



-- INSERT COMMAND

-- INSERT INTO table ( columns ) VALUES ( values )

INSERT INTO users ( name , age , email ) VALUES ( 'John' , 32 , 'john.doe@gmail.com');


--MOCK DATA FROM --mockaroo

insert into users (name, age, email) values ('Tonya', 63, 'tbadgers0@homestead.com');
insert into users (name, age, email) values ('Konstance', 50, 'koutlaw1@comsenz.com');
insert into users (name, age, email) values ('Evanne', 60, 'eolagene2@uiuc.edu');
insert into users (name, age, email) values ('Xever', 15, 'xhoofe3@de.vu');
insert into users (name, age, email) values ('Paulita', 25, 'plegier4@aboutads.info');
insert into users (name, age, email) values ('Vittoria', 15, 'vropking5@paginegialle.it');
insert into users (name, age, email) values ('Moses', 35, 'mbellhanger6@youku.com');
insert into users (name, age, email) values ('Nedi', 14, 'nrugge7@newsvine.com');
insert into users (name, age, email) values ('Hazel', 39, 'hminto8@who.int');
insert into users (name, age, email) values ('Noni', 20, 'nboydle9@howstuffworks.com');



-- DELETE COMMAND

-- DELETE FROM table WHERE QUERY;

/* DELETE is a *LOOP* . So if you dont do WHERE after DELETE , it will DELETE your entire rows */

DELETE FROM users WHERE email = 'xhoofe3@de.vu';

-- DELETE FROM users;   NEVER DO THIS




-- UPDATE

-- UPDATE table SET change query WHERE search query ;

UPDATE users SET age = 18 WHERE name = 'Vittoria';



-- SELECT ( READ DATA )

-- SELECT column FROM table WHERE search query;

SELECT * FROM users WHERE age = 14;

SELECT * FROM users;





-- ORDER BY ( sorting )

SELECT * FROM users ORDER BY age DESC;





-- LIKE ( searching by wildcard )     |   NOT RECOMMENDED FOR BIG FILES. BAD FOR INDEXING

SELECT * FROM users WHERE email LIKE '%edu%';




-- LIMIT ( limit read queries )
-- the WHERE and ORDER BY happens BEFORE LIMIT/OFFSET

SELECT * FROM users order by age desc LIMIT 3;



-- OFFSET ( limit starts from row 0)

SELECT * FROM users ORDER BY age desc OFFSET 0 LIMIT 3;




-- COUNT ( efficient , I just want to know type clause )

SELECT COUNT(*) FROM users ;


SELECT COUNT(*) FROM users WHERE email LIKE '%.edu';


/* Time took 1ms for COUNT

   -------------------------------
   [2026-07-28 12:00:29] postgres.public> SELECT COUNT(*) FROM users WHERE email LIKE '%.edu'
[2026-07-28 12:00:29] 1 row retrieved starting from 1 in 330 ms (execution: 1 ms, fetching: 329 ms)
   -------------------------------


   Same thing if you just want to know the numbers by WHERE CLAUSE it takes 5ms and MORE MEMORY

   -----------------------------------
   [2026-07-28 11:54:10] postgres.public> SELECT * FROM users WHERE email LIKE '%edu%'
[2026-07-28 11:54:10] 1 row retrieved starting from 1 in 340 ms (execution: 5 ms, fetching: 335 ms)
   -----------------------------------
 */








