-- =====================================================================
--                    RELATIONAL DATABASE DESIGN
-- =====================================================================

/*
DATABASE DESIGN AS DATA MODELING:

Database design is the process of planning how application data will be
stored, organized, and connected.

Before creating tables, we usually draw a visual data model called an:

    ERD = Entity Relationship Diagram

An ERD shows:

    - Tables
    - Columns
    - Primary keys
    - Foreign keys
    - Relationships between tables

The data model is one of the most important parts of an application because
it defines the structure underneath the user interface, APIs, and services.

SUGGESTED SOFTWARE : https://dbdiagram.io/
*/


-- =====================================================================
--                       EXAMPLE: BAD DESIGN
-- =====================================================================

/*
Imagine a messaging application stores this data:

message_id | sender_name | sender_email   | message
-----------+-------------+----------------+----------------
1          | John        | john@gmail.com | Hello
2          | John        | john@gmail.com | How are you?
3          | John        | john@gmail.com | See you later

The same user information is repeated vertically in multiple rows:

    John
    john@gmail.com

This is called data duplication or vertical replication.

Problems:

    - Wastes storage
    - Makes updates harder
    - Can create inconsistent data
    - If John's email changes, many rows must be updated
*/


-- Bad duplicated design

CREATE TABLE bad_messages (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sender_name TEXT,
    sender_email TEXT,
    message TEXT
);


-- =====================================================================
--                       AVOIDING DUPLICATION
-- =====================================================================

/*
A major relational database design principle is:

Store each important piece of data once, then reference it using a key.

Instead of storing John's name and email in every message row:

    1. Store John once in the users table.
    2. Give John a unique primary key.
    3. Store that key inside the messages table as a foreign key.
*/


-- Users are stored once
DROP TABLE users;

CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);


-- Messages reference users

CREATE TABLE messages (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sender_id INTEGER NOT NULL REFERENCES users(id),
    content TEXT NOT NULL
);


/*
Now the data looks like this:

users:

id | name | email
---+------+----------------
1  | John | john@gmail.com


messages:

id | sender_id | content
---+-----------+----------------
1  | 1         | Hello
2  | 1         | How are you?
3  | 1         | See you later

John's information is stored only once.

The value:

    sender_id = 1

connects each message to John.
*/


-- =====================================================================
--                     PRIMARY AND FOREIGN KEYS
-- =====================================================================

/*
PRIMARY KEY:

    Uniquely identifies one row inside its own table.

Example:

    users.id


FOREIGN KEY:

    Stores the primary key of a row in another table.

Example:

    messages.sender_id references users.id


Relationship:

    users.id <---------------- messages.sender_id
*/


-- Retrieve messages with their user information

SELECT
    messages.id,
    users.name,
    users.email,
    messages.content
FROM messages
JOIN users
    ON users.id = messages.sender_id;


/*
The JOIN reconstructs the information needed by the application.

The database stores normalized data separately, but SQL combines it when
the application needs to display it.
*/


-- =====================================================================
--                 USER INTERFACE VS DATABASE MODEL
-- =====================================================================

/*
A user interface may display repeated information for convenience.

Example:

John | john@gmail.com | Hello
John | john@gmail.com | How are you?
John | john@gmail.com | See you later

That does not mean the database should physically store John's name and
email three times.

The interface and database serve different purposes:

USER INTERFACE:

    - Designed for humans
    - May display repeated information
    - Focuses on usability and appearance

DATABASE MODEL:

    - Designed for correct and efficient storage
    - Avoids unnecessary duplication
    - Uses keys and relationships
    - Supports millions of records efficiently

SQL JOIN queries reconstruct the repeated-looking interface from normalized
tables.
*/


-- =====================================================================
--                          DATA MODELING FLOW
-- =====================================================================

/*
A practical database-design process:

1. Study the application requirements and user interface.

2. Identify the main entities.

Examples:

    User
    Conversation
    Message
    Product
    Order
    Comment

3. Create one table for each major entity.

4. Give every table a primary key.

5. Identify relationships between entities.

Examples:

    One user creates many messages.
    One order contains many products.
    One conversation contains many members.

6. Store relationships using foreign keys.

7. Remove unnecessary duplicated data.

8. Add constraints and indexes where appropriate.
*/


-- =====================================================================
--                         CHAT APPLICATION EXAMPLE
-- =====================================================================

/*
Possible entities:

    User
    Conversation
    ConversationMember
    Message

Relationships:

    A user can join many conversations.
    A conversation can contain many users.
    A conversation can contain many messages.
    A user can send many messages.

Visual model:

users
    |
    | one user has many memberships
    v
conversation_members
    ^
    | one conversation has many memberships
    |
conversations
    |
    | one conversation has many messages
    v
messages
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
RELATIONAL DATABASE DESIGN:

- Represents application data as tables and relationships.
- Uses ER diagrams to visualize the model.
- Stores each important piece of data once where practical.
- Uses primary keys to identify rows.
- Uses foreign keys to connect tables.
- Avoids unnecessary vertical duplication.
- Uses JOIN queries to reconstruct information for the user interface.

The interface shows data.

The relational model defines how that data is correctly stored and connected.
*/