-- =====================================================================
--                  KEYS IN RELATIONAL DATABASES
--                  THEORY + PRACTICE EXAMPLES
-- =====================================================================


/*
A key is a column, or group of columns, used to identify rows
or connect rows between tables.

The three important key concepts are:

1. Primary key
2. Logical key
3. Foreign key
*/


-- =====================================================================
--                          PRIMARY KEY
-- =====================================================================

/*
PRIMARY KEY:

- Uniquely identifies each row in a table.
- Cannot contain NULL.
- Cannot contain duplicate values.
- A table can have only one primary key constraint.
- PostgreSQL automatically creates a unique index for the primary key.

Primary keys are commonly:

- INTEGER
- BIGINT
- UUID

Example:

    id = 1

The number 1 uniquely identifies one specific user.
*/


DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL
);


INSERT INTO users (name, email)
VALUES
    ('John Doe', 'john@example.com'),
    ('Maria Smith', 'maria@example.com'),
    ('Zhang Wei', 'zhang@example.com');


SELECT *
FROM users;


/*
Expected result:

id | name        | email
---+-------------+-------------------
1  | John Doe    | john@example.com
2  | Maria Smith | maria@example.com
3  | Zhang Wei   | zhang@example.com
*/


-- Find one row using its primary key.

SELECT *
FROM users
WHERE id = 2;


/*
This would fail because primary-key values must be unique:

INSERT INTO users (id, name, email)
VALUES (1, 'Another User', 'another@example.com');

The ID is also GENERATED ALWAYS, so PostgreSQL normally prevents
manual insertion into the identity column.
*/


-- =====================================================================
--                          LOGICAL KEY
-- =====================================================================

/*
LOGICAL KEY:

- A meaningful real-world value used to find a row.
- Also called a business key or natural key in many contexts.
- Examples include:

    email
    username
    product SKU
    employee number
    ISBN
    passport number

Logical keys are meaningful to users or external systems.

Example:

    john@example.com

The application may use this email to look up John.
*/


SELECT *
FROM users
WHERE email = 'john@example.com';


/*
A logical key should often be protected with a UNIQUE constraint.

Why?

Because two users should not normally have the same email address.
*/


ALTER TABLE users
ADD CONSTRAINT uq_users_email UNIQUE (email);


/*
Now PostgreSQL prevents duplicate emails.

This would fail:

INSERT INTO users (name, email)
VALUES ('Fake John', 'john@example.com');
*/


-- =====================================================================
--              WHY NOT USE EMAIL AS THE PRIMARY KEY?
-- =====================================================================

/*
Logical keys can change.

Example:

    john@example.com

may later become:

    john.doe@example.com

If the email were used as the primary key, every related table
might also need that string updated.

Instead:

    id remains 1
    email changes

The relationship remains stable because other tables reference id,
not the email string.
*/


UPDATE users
SET email = 'john.doe@example.com'
WHERE id = 1;


SELECT *
FROM users
WHERE id = 1;


/*
The primary key stayed the same:

    id = 1

Only the logical key changed:

    john@example.com
        became
    john.doe@example.com
*/


-- =====================================================================
--                          FOREIGN KEY
-- =====================================================================

/*
FOREIGN KEY:

- A column in one table that references a key in another table.
- Usually references the primary key of the parent table.
- Creates a relationship between tables.
- Prevents references to rows that do not exist.

Naming convention:

Primary key:

    users.id

Foreign key:

    messages.user_id

General pattern:

    table_name_id
*/


DROP TABLE IF EXISTS messages;

CREATE  TABLE messages (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    sender_id BIGINT NOT NULL REFERENCES users(id) ,
    content TEXT NOT NULL ,
    created_at timestamptz NOT NULL DEFAULT now()
);


/*
Relationship:

users.id
    |
    | referenced by
    v
messages.user_id

One user can have many messages.
Each message belongs to one user.
*/


INSERT INTO messages (sender_id, content)
VALUES
    (1, 'Hello from John'),
    (1, 'John sent another message'),
    (2, 'Hello from Maria'),
    (3, 'Hello from Zhang');


SELECT *
FROM messages;


/*
This would fail:

INSERT INTO messages (user_id, content)
VALUES (999, 'Invalid message');

Why?

There is no user with:

    users.id = 999

The foreign-key constraint protects database integrity.
*/


-- =====================================================================
--                    JOINING RELATED TABLES
-- =====================================================================

/*
The messages table stores only user_id.

It does not repeat:

- user name
- user email

A JOIN combines the related rows when the application needs them.
*/


SELECT
    messages.id AS message_id,
    users.id AS user_id,
    users.name,
    users.email,
    messages.content,
    messages.created_at
FROM messages
JOIN users
    ON users.id = messages.sender_id
ORDER BY messages.id;


/*
The database stores normalized data:

users:
    id, name, email

messages:
    id, user_id, content

The JOIN reconstructs the human-readable result.
*/


-- =====================================================================
--                    BAD DUPLICATED DESIGN
-- =====================================================================

/*
BAD DESIGN:

Storing user details directly inside every message row.

Example:

message_id | sender_name | sender_email      | content
-----------+-------------+-------------------+----------------
1          | John Doe    | john@example.com  | Hello
2          | John Doe    | john@example.com  | Another message
3          | John Doe    | john@example.com  | Goodbye

Problems:

- The same name is repeated.
- The same email is repeated.
- Changing the email requires many updates.
- Different rows can accidentally contain inconsistent values.
*/


DROP TABLE IF EXISTS bad_messages;

CREATE TABLE bad_messages (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sender_name TEXT,
    sender_email TEXT,
    content TEXT
);


INSERT INTO bad_messages (
    sender_name,
    sender_email,
    content
)
VALUES
    ('John Doe', 'john@example.com', 'Hello'),
    ('John Doe', 'john@example.com', 'Another message'),
    ('John Doe', 'john@example.com', 'Goodbye');


SELECT *
FROM bad_messages;


/*
BETTER DESIGN:

users:
    id
    name
    email

messages:
    id
    user_id
    content

The user's information is stored once.
Messages reference the user through user_id.
*/


-- =====================================================================
--                        KEY NAMING CONVENTIONS
-- =====================================================================

/*
Common naming conventions:

PRIMARY KEY:

    id

FOREIGN KEY:

    user_id
    product_id
    order_id
    conversation_id

Examples:

users.id
messages.user_id

products.id
order_items.product_id

conversations.id
messages.conversation_id

Clear naming conventions make relationships easier to understand.
*/


-- =====================================================================
--                     INTEGER VS UUID PRIMARY KEYS
-- =====================================================================

/*
INTEGER / BIGINT PRIMARY KEYS:

Advantages:

- Small storage size.
- Fast indexes.
- Easy to read.
- Simple auto-increment behavior.
- Good default for many applications.

Example:

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY


UUID PRIMARY KEYS:

Advantages:

- Globally unique.
- Can be generated before inserting into the database.
- Useful in distributed systems.
- Harder to guess than sequential public IDs.

Example:

    id UUID PRIMARY KEY DEFAULT gen_random_uuid()


Important:

UUID is not bad.

The real rule is:

Do not use unstable logical values, such as email or username,
as the primary key.

Both BIGINT and UUID are valid surrogate primary keys.
*/


-- UUID example table

DROP TABLE IF EXISTS api_tokens;

CREATE TABLE api_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token_name TEXT NOT NULL
);


INSERT INTO api_tokens (token_name)
VALUES
    ('Development token'),
    ('Production token');


SELECT *
FROM api_tokens;


-- =====================================================================
--                        SURROGATE KEY
-- =====================================================================

/*
SURROGATE KEY:

- A generated identifier with no business meaning.
- Used only to identify a row.

Examples:

    1
    92841
    550e8400-e29b-41d4-a716-446655440000

Typical surrogate keys:

- Identity integer
- BIGINT identity
- UUID

Example:

    users.id

The user does not care that John's ID is 1.
The database uses it internally.
*/


-- =====================================================================
--                        NATURAL / LOGICAL KEY
-- =====================================================================

/*
NATURAL OR LOGICAL KEY:

- Comes from real-world data.
- Has business meaning.

Examples:

    email
    username
    ISBN
    employee_number

Natural keys are often given UNIQUE constraints,
but they do not always make good primary keys because they may change.
*/


-- =====================================================================
--                         COMPOSITE KEY
-- =====================================================================

/*
COMPOSITE KEY:

- A key made from multiple columns.
- Useful when the combination must be unique.

Example:

A user should join a conversation only once.

The combination:

    conversation_id + user_id

must be unique.
*/


DROP TABLE IF EXISTS conversation_members;
DROP TABLE IF EXISTS conversations;

CREATE TABLE conversations (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL
);


CREATE TABLE conversation_members (
    conversation_id BIGINT NOT NULL
        REFERENCES conversations(id),

    user_id BIGINT NOT NULL
        REFERENCES users(id),

    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (conversation_id, user_id)
);


/*
The composite primary key prevents duplicate memberships.

Valid:

    conversation_id = 1, user_id = 1
    conversation_id = 1, user_id = 2

Invalid duplicate:

    conversation_id = 1, user_id = 1
    conversation_id = 1, user_id = 1
*/


INSERT INTO conversations (title)
VALUES ('Backend Developers');


INSERT INTO conversation_members (
    conversation_id,
    user_id
)
VALUES
    (1, 1),
    (1, 2),
    (1, 3);


SELECT *
FROM conversation_members;


/*
This would fail because the same membership already exists:

INSERT INTO conversation_members (
    conversation_id,
    user_id
)
VALUES (1, 1);
*/


-- =====================================================================
--                      FOREIGN-KEY DELETE RULES
-- =====================================================================

/*
A foreign key can define what happens when the parent row is deleted.

Common options:

ON DELETE RESTRICT
    - Prevent deletion if child rows still reference the parent.

ON DELETE CASCADE
    - Automatically delete related child rows.

ON DELETE SET NULL
    - Keep child rows but set the foreign key to NULL.

Choose carefully.
*/


DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS authors CASCADE;


CREATE TABLE authors (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL
);


CREATE TABLE posts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    author_id BIGINT NOT NULL
        REFERENCES authors(id)
        ON DELETE CASCADE,

    title TEXT NOT NULL
);


INSERT INTO authors (name)
VALUES ('Alice');


INSERT INTO posts (author_id, title)
VALUES
    (1, 'Post One'),
    (1, 'Post Two');


SELECT * FROM posts;


/*
Because the foreign key uses ON DELETE CASCADE:

Deleting Alice also deletes Alice's posts.
*/


DELETE FROM authors
WHERE id = 1;


SELECT * FROM posts;


-- =====================================================================
--                         PRACTICE EXERCISE 1
-- =====================================================================

/*
TASK:

Create a products table with:

- id as a generated primary key
- sku as a unique logical key
- name
- price
*/

DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY ,
    sku VARCHAR(30) NOT NULL UNIQUE ,
    name VARCHAR(30) ,
    price DOUBLE PRECISION
);



INSERT INTO products (sku, name, price)
VALUES
    ('LAPTOP-001', 'Laptop', 1299.99),
    ('PHONE-001', 'Smartphone', 799.99),
    ('TABLET-001', 'Tablet', 499.99),
    ('MONITOR-001', '24-inch Monitor', 189.99),
    ('MONITOR-002', '27-inch Monitor', 279.99),
    ('KEYBOARD-001', 'Mechanical Keyboard', 89.99),
    ('KEYBOARD-002', 'Wireless Keyboard', 49.99),
    ('MOUSE-001', 'Gaming Mouse', 59.99),
    ('MOUSE-002', 'Wireless Mouse', 34.99),
    ('HEADSET-001', 'Gaming Headset', 79.99),
    ('EARBUDS-001', 'Wireless Earbuds', 99.99),
    ('SPEAKER-001', 'Bluetooth Speaker', 69.99),
    ('WEBCAM-001', '1080p Webcam', 54.99),
    ('MIC-001', 'USB Microphone', 119.99),
    ('CHAIR-001', 'Ergonomic Office Chair', 249.99),
    ('DESK-001', 'Standing Desk', 399.99),
    ('SSD-001', '500GB SSD', 59.99),
    ('SSD-002', '1TB SSD', 99.99),
    ('SSD-003', '2TB SSD', 179.99),
    ('HDD-001', '1TB Hard Drive', 49.99),
    ('HDD-002', '4TB Hard Drive', 109.99),
    ('RAM-001', '8GB DDR4 RAM', 29.99),
    ('RAM-002', '16GB DDR4 RAM', 54.99),
    ('RAM-003', '32GB DDR5 RAM', 119.99),
    ('GPU-001', 'Entry-Level Graphics Card', 249.99),
    ('GPU-002', 'Mid-Range Graphics Card', 499.99),
    ('GPU-003', 'High-End Graphics Card', 999.99),
    ('CPU-001', 'Quad-Core Processor', 149.99),
    ('CPU-002', 'Eight-Core Processor', 299.99),
    ('CPU-003', 'Sixteen-Core Processor', 599.99),
    ('MOTHERBOARD-001', 'Micro-ATX Motherboard', 109.99),
    ('MOTHERBOARD-002', 'ATX Motherboard', 189.99),
    ('PSU-001', '500W Power Supply', 59.99),
    ('PSU-002', '750W Power Supply', 109.99),
    ('CASE-001', 'Mid-Tower PC Case', 79.99),
    ('CASE-002', 'Full-Tower PC Case', 139.99),
    ('COOLER-001', 'CPU Air Cooler', 44.99),
    ('COOLER-002', 'Liquid CPU Cooler', 129.99),
    ('ROUTER-001', 'Wi-Fi 6 Router', 119.99),
    ('SWITCH-001', '8-Port Network Switch', 39.99),
    ('CABLE-001', 'Ethernet Cable', 9.99),
    ('CABLE-002', 'USB-C Cable', 14.99),
    ('CABLE-003', 'HDMI Cable', 12.99),
    ('CHARGER-001', 'USB-C Wall Charger', 29.99),
    ('CHARGER-002', 'Wireless Charger', 39.99),
    ('POWERBANK-001', '10000mAh Power Bank', 34.99),
    ('POWERBANK-002', '20000mAh Power Bank', 59.99),
    ('HUB-001', 'USB-C Hub', 49.99),
    ('DOCK-001', 'Laptop Docking Station', 139.99),
    ('ADAPTER-001', 'USB-C to HDMI Adapter', 24.99),
    ('PRINTER-001', 'Inkjet Printer', 129.99),
    ('PRINTER-002', 'Laser Printer', 249.99),
    ('SCANNER-001', 'Document Scanner', 179.99),
    ('CAMERA-001', 'Digital Camera', 699.99),
    ('TRIPOD-001', 'Camera Tripod', 59.99),
    ('LENS-001', '50mm Camera Lens', 249.99),
    ('WATCH-001', 'Smartwatch', 229.99),
    ('TRACKER-001', 'Fitness Tracker', 89.99),
    ('CONSOLE-001', 'Gaming Console', 499.99),
    ('CONTROLLER-001', 'Wireless Controller', 69.99),
    ('GAME-001', 'Adventure Game', 59.99),
    ('GAME-002', 'Racing Game', 49.99),
    ('VR-001', 'Virtual Reality Headset', 399.99),
    ('DRONE-001', 'Camera Drone', 599.99),
    ('PROJECTOR-001', 'Portable Projector', 299.99),
    ('TV-001', '43-inch Smart TV', 349.99),
    ('TV-002', '55-inch Smart TV', 549.99),
    ('REMOTE-001', 'Universal Remote', 19.99),
    ('STREAM-001', 'Streaming Device', 49.99),
    ('BOOK-001', 'PostgreSQL Fundamentals', 39.99),
    ('BOOK-002', 'Python Programming Guide', 44.99),
    ('BOOK-003', 'Data Structures Handbook', 49.99),
    ('NOTEBOOK-001', 'Spiral Notebook', 5.99),
    ('PEN-001', 'Ballpoint Pen Set', 7.99),
    ('BACKPACK-001', 'Laptop Backpack', 69.99),
    ('SLEEVE-001', 'Laptop Sleeve', 29.99),
    ('STAND-001', 'Laptop Stand', 39.99),
    ('PAD-001', 'Large Mouse Pad', 19.99),
    ('LIGHT-001', 'LED Desk Lamp', 34.99),
    ('CLOCK-001', 'Digital Alarm Clock', 24.99),
    ('FAN-001', 'USB Desk Fan', 19.99),
    ('VACUUM-001', 'Keyboard Vacuum', 22.99),
    ('CLEANER-001', 'Screen Cleaning Kit', 12.99),
    ('THERMAL-001', 'Thermal Paste', 8.99),
    ('TOOLKIT-001', 'Computer Repair Toolkit', 39.99),
    ('UPS-001', 'Battery Backup UPS', 149.99),
    ('SURGE-001', 'Surge Protector', 24.99),
    ('NAS-001', 'Two-Bay NAS', 299.99),
    ('FLASH-001', '64GB USB Flash Drive', 14.99),
    ('FLASH-002', '128GB USB Flash Drive', 24.99),
    ('MEMORY-001', '128GB Memory Card', 21.99),
    ('READER-001', 'Memory Card Reader', 16.99),
    ('LABEL-001', 'Label Printer', 79.99),
    ('CALCULATOR-001', 'Scientific Calculator', 29.99),
    ('BATTERY-001', 'Rechargeable Battery Pack', 24.99),
    ('SMARTPLUG-001', 'Wi-Fi Smart Plug', 19.99),
    ('BULB-001', 'Smart LED Bulb', 14.99),
    ('SENSOR-001', 'Smart Motion Sensor', 29.99),
    ('LOCK-001', 'Smart Door Lock', 179.99),
    ('CAMERA-002', 'Indoor Security Camera', 49.99);

SELECT * FROM products;

-- Lookup using the logical key.
SELECT * FROM products WHERE sku = 'PHONE-001';

/*
 [2026-07-28 18:35:45] postgres.public> SELECT * FROM products WHERE sku = 'PHONE-001'
[2026-07-28 18:35:45] 1 row retrieved starting from 1 in 330 ms (execution: 2 ms, fetching: 328 ms)


 EXECUTION TIME : 2ms
 */



-- Lookup using the primary key.
SELECT * FROM products WHERE id = 2;


/*
 [2026-07-28 18:35:49] postgres.public> SELECT * FROM products WHERE id = 2
[2026-07-28 18:35:50] 1 row retrieved starting from 1 in 347 ms (execution: 0 ms, fetching: 347 ms)

 EXECUTION TIME : 0ms
 */


-- =====================================================================
--                         PRACTICE EXERCISE 2
-- =====================================================================

/*
TASK:

Create an orders table that references users.
*/


DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_id BIGINT NOT NULL
        REFERENCES users(id),

    total NUMERIC(10, 2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


INSERT INTO orders (user_id, total)
VALUES
    (1, 149.99),
    (2, 899.50),
    (1, 49.00);


SELECT
    orders.id,
    users.name,
    orders.total,
    orders.created_at
FROM orders
JOIN users
    ON users.id = orders.user_id
ORDER BY orders.id;


-- =====================================================================
--                         PRACTICE EXERCISE 3
-- =====================================================================

/*
TASK:

Create an order_items table connecting orders and products.

Each row means:

    one product appears inside one order
*/


DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    order_id BIGINT NOT NULL
        REFERENCES orders(id)
        ON DELETE CASCADE,

    product_id BIGINT NOT NULL
        REFERENCES products(id),

    quantity INTEGER NOT NULL CHECK (quantity > 0),

    unit_price NUMERIC(10, 2) NOT NULL,

    UNIQUE (order_id, product_id)
);


INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price
)
VALUES
    (1, 1, 1, 1299.99),
    (1, 2, 2, 799.99);


SELECT
    orders.id AS order_id,
    users.name AS customer,
    products.name AS product,
    order_items.quantity,
    order_items.unit_price
FROM order_items
JOIN orders
    ON orders.id = order_items.order_id
JOIN users
    ON users.id = orders.user_id
JOIN products
    ON products.id = order_items.product_id;


-- =====================================================================
--                            SUMMARY
-- =====================================================================

/*
PRIMARY KEY:

- Uniquely identifies a row.
- Cannot be NULL.
- Cannot be duplicated.
- Usually uses BIGINT, INTEGER, or UUID.

LOGICAL KEY:

- Meaningful real-world lookup value.
- Examples: email, username, SKU.
- Often should be UNIQUE.
- May change over time.

FOREIGN KEY:

- References a row in another table.
- Creates relationships.
- Protects referential integrity.

NAMING:

Primary key:

    id

Foreign key:

    table_name_id

Examples:

    users.id
    messages.user_id

BEST PRACTICE:

Use a stable generated ID as the primary key.

Use logical values for lookup and protect them with UNIQUE constraints.

Use foreign keys to connect tables.
*/