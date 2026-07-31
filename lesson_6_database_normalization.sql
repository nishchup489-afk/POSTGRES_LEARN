
-- =====================================================================
--              PRIMARY KEYS, LOGICAL KEYS, AND FOREIGN KEYS
-- =====================================================================

/*
RELATIONAL DATABASE KEYS:

Relational databases use keys to:

    - Uniquely identify rows
    - Search for rows efficiently
    - Connect rows across different tables
    - Prevent invalid or duplicated data

The three important key concepts are:

    1. Primary key
    2. Logical key
    3. Foreign key

We will use a music application as the main example.

The application stores:

    - Artists
    - Albums
    - Tracks
    - Genres
*/


-- =====================================================================
--                     EXAMPLE: BAD DATABASE DESIGN
-- =====================================================================

/*
Imagine storing every track in one large table:

track_id | track_name | artist_name   | album_name | genre_name
---------+------------+---------------+------------+-----------
1        | Numb       | Linkin Park   | Meteora    | Rock
2        | Faint      | Linkin Park   | Meteora    | Rock
3        | Breaking   | Linkin Park   | Meteora    | Rock

The following values are repeated:

    Linkin Park
    Meteora
    Rock

This creates data duplication.

The longer the album becomes, the more repeated data the table stores.
*/


CREATE TABLE bad_tracks (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    track_name TEXT NOT NULL,
    artist_name TEXT NOT NULL,
    album_name TEXT NOT NULL,
    genre_name TEXT NOT NULL
);


/*
Example data:
*/

INSERT INTO bad_tracks (
    track_name,
    artist_name,
    album_name,
    genre_name
)
VALUES
    ('Numb', 'Linkin Park', 'Meteora', 'Rock'),
    ('Faint', 'Linkin Park', 'Meteora', 'Rock'),
    ('Breaking the Habit', 'Linkin Park', 'Meteora', 'Rock');


/*
Problems with this design:

    1. Artist data is duplicated.

    2. Album data is duplicated.

    3. Genre data is duplicated.

    4. Updating data becomes difficult.

For example, suppose the album name changes from:

    Meteora

to:

    Meteora Remastered

Every matching track row must be updated.

If one row is missed, the database becomes inconsistent:

    Meteora
    Meteora
    Meteora Remastered

This is called an update anomaly.
*/


-- =====================================================================
--                            PRIMARY KEYS
-- =====================================================================

/*
PRIMARY KEY:

A primary key uniquely identifies one row inside a table.

Example:

    artists.id

Each artist receives a unique integer value.

id | name
---+-------------
1  | Linkin Park
2  | Coldplay
3  | Adele

The primary key value must be:

    - Unique
    - Not NULL
    - Stable
*/


CREATE TABLE artists (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL
);


/*
In PostgreSQL:

    GENERATED ALWAYS AS IDENTITY

automatically generates integer values.

Example:

    First artist  -> id = 1
    Second artist -> id = 2
    Third artist  -> id = 3

The application usually does not manually choose these values.
*/


INSERT INTO artists (name)
VALUES
    ('Linkin Park'),
    ('Coldplay'),
    ('Adele');


SELECT *
FROM artists;


/*
Possible result:

id | name
---+-------------
1  | Linkin Park
2  | Coldplay
3  | Adele
*/


-- =====================================================================
--                WHY INTEGER PRIMARY KEYS ARE COMMON
-- =====================================================================

/*
Instead of using the artist name as the primary key, we use an integer.

Preferred:

    id = 1

Instead of:

    name = 'Linkin Park'


Advantages of integer primary keys:

    - Small storage size
    - Fast comparisons
    - Efficient indexes
    - Easy foreign-key references
    - Usually stable over time
*/


/*
Names are not always stable.

An artist could change their display name.

If the name were used as the primary key, changing it could affect every
table that references it.

The integer ID remains unchanged:

Before:

    id = 1
    name = 'Old Name'

After:

    id = 1
    name = 'New Name'

The identity of the row remains stable.
*/


-- =====================================================================
--                           LOGICAL KEYS
-- =====================================================================

/*
LOGICAL KEY:

A logical key is a meaningful column used by humans or applications to
identify or look up a row.

Examples:

    users.email
    users.username
    products.sku
    countries.country_code
    tracks.slug

A logical key is often a string.

Unlike an internal integer primary key, a logical key has meaning in the
real world or application.
*/


CREATE TABLE application_users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL
);


/*
In this table:

    id       -> primary key
    username -> logical key
    email    -> logical key

Example:

id | username  | email                | display_name
---+-----------+----------------------+-------------
1  | john_dev  | john@example.com     | John
2  | sara_code | sara@example.com     | Sara

The database internally identifies John using:

    id = 1

But the application may search for John using:

    username = 'john_dev'

or:

    email = 'john@example.com'
*/


SELECT *
FROM application_users
WHERE username = 'john_dev';


SELECT *
FROM application_users
WHERE email = 'john@example.com';


/*
The UNIQUE constraint prevents duplicate logical keys.

This is invalid:

    john@example.com
    john@example.com

because two users should not share the same account email.
*/


-- =====================================================================
--                 PRIMARY KEY VS LOGICAL KEY
-- =====================================================================

/*
PRIMARY KEY:

    - Usually an integer
    - Used internally by the database
    - Has no business meaning
    - Stable
    - Uniquely identifies the row

Example:

    users.id = 42


LOGICAL KEY:

    - Usually meaningful
    - Often a string
    - Used by users or applications
    - May change
    - Often protected by UNIQUE

Example:

    users.email = 'john@example.com'
*/


/*
Example user:

id | username | email
---+----------+------------------
42 | john_dev | john@example.com

The primary key is:

    42

The logical keys are:

    john_dev
    john@example.com
*/


-- =====================================================================
--                   INDEXES FOR LOGICAL KEYS
-- =====================================================================

/*
Logical keys are frequently used in WHERE clauses.

Example:

    Find a user by email.
    Find a product by SKU.
    Find an article by slug.

To make these searches efficient, the database uses an index.
*/


CREATE INDEX idx_application_users_display_name
ON application_users(display_name);


/*
A UNIQUE constraint normally creates a unique index automatically.

Therefore:

    username TEXT UNIQUE
    email TEXT UNIQUE

already receive indexes in PostgreSQL.

This makes lookups efficient:

    WHERE username = ...
    WHERE email = ...
*/


-- =====================================================================
--                           FOREIGN KEYS
-- =====================================================================

/*
FOREIGN KEY:

A foreign key is a column that references a row in another table.

It usually stores the primary key of the referenced row.

Example:

    albums.artist_id references artists.id

This means:

    Every album belongs to an artist.
*/


CREATE TABLE albums (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    artist_id INTEGER NOT NULL REFERENCES artists(id),
    title TEXT NOT NULL,
    release_year INTEGER
);


/*
Relationship:

artists.id <---------------- albums.artist_id

Example:

artists:

id | name
---+-------------
1  | Linkin Park


albums:

id | artist_id | title    | release_year
---+-----------+----------+-------------
1  | 1         | Meteora  | 2003
2  | 1         | Hybrid Theory | 2000

The value:

    artist_id = 1

means both albums belong to the artist whose primary key is 1.
*/


INSERT INTO albums (
    artist_id,
    title,
    release_year
)
VALUES
    (1, 'Meteora', 2003),
    (1, 'Hybrid Theory', 2000);


/*
The database does not repeatedly store:

    Linkin Park
    Linkin Park

inside every album row.

Instead, it stores the artist once and references the artist using:

    artist_id = 1
*/


-- =====================================================================
--                    FOREIGN KEY DATA INTEGRITY
-- =====================================================================

/*
A foreign key prevents invalid references.

This insert is valid if artist 1 exists:
*/

INSERT INTO albums (
    artist_id,
    title,
    release_year
)
VALUES
    (1, 'Minutes to Midnight', 2007);


/*
This insert fails if artist 999 does not exist:

INSERT INTO albums (
    artist_id,
    title,
    release_year
)
VALUES
    (999, 'Unknown Album', 2026);

PostgreSQL rejects the row because:

    albums.artist_id = 999

does not match any existing:

    artists.id

This is called referential integrity.
*/


-- =====================================================================
--                       MANY-TO-ONE RELATIONSHIP
-- =====================================================================

/*
A foreign key commonly creates a many-to-one relationship.

Example:

    Many albums belong to one artist.

From the albums side:

    Many albums -> one artist

From the artists side:

    One artist -> many albums
*/


/*
Visual relationship:

artists
    |
    | one artist
    |
    | has many
    v
albums


artists.id <---------------- albums.artist_id
*/


-- =====================================================================
--                    ADDING GENRES AND TRACKS
-- =====================================================================

/*
Now we create separate tables for:

    - Genres
    - Tracks

Each important type of data gets its own table.
*/


CREATE TABLE genres (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);


CREATE TABLE tracks (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    album_id INTEGER NOT NULL REFERENCES albums(id),
    genre_id INTEGER NOT NULL REFERENCES genres(id),
    title TEXT NOT NULL,
    duration_seconds INTEGER CHECK (duration_seconds > 0)
);


/*
Relationships:

albums.id <---------------- tracks.album_id

genres.id <---------------- tracks.genre_id


Meaning:

    Each track belongs to one album.
    Each track belongs to one genre.

An album can contain many tracks.
A genre can contain many tracks.
*/


INSERT INTO genres (name)
VALUES
    ('Rock'),
    ('Pop'),
    ('Hip-Hop');


INSERT INTO tracks (
    album_id,
    genre_id,
    title,
    duration_seconds
)
VALUES
    (1, 1, 'Numb', 185),
    (1, 1, 'Faint', 162),
    (1, 1, 'Breaking the Habit', 196);


/*
Normalized data:

artists:

id | name
---+-------------
1  | Linkin Park


albums:

id | artist_id | title
---+-----------+---------
1  | 1         | Meteora


genres:

id | name
---+------
1  | Rock


tracks:

id | album_id | genre_id | title
---+----------+----------+--------------------
1  | 1        | 1        | Numb
2  | 1        | 1        | Faint
3  | 1        | 1        | Breaking the Habit
*/


-- =====================================================================
--                            NORMALIZATION
-- =====================================================================

/*
NORMALIZATION:

Normalization is the process of organizing data into separate related
tables to reduce duplication and improve data integrity.

Instead of storing everything in one table:

    track_name
    album_name
    artist_name
    genre_name

we separate the data into:

    artists
    albums
    genres
    tracks
*/


/*
Bad duplicated design:

track_name | artist_name | album_name | genre_name
-----------+-------------+------------+-----------
Numb       | Linkin Park | Meteora    | Rock
Faint      | Linkin Park | Meteora    | Rock


Normalized design:

artists:

1 | Linkin Park


albums:

1 | 1 | Meteora


genres:

1 | Rock


tracks:

1 | 1 | 1 | Numb
2 | 1 | 1 | Faint
*/


/*
The normalized model stores each important fact once:

    Artist name -> artists table
    Album title -> albums table
    Genre name  -> genres table
    Track title -> tracks table

Foreign keys connect those facts.
*/


-- =====================================================================
--                          JOINING THE TABLES
-- =====================================================================

/*
The data is stored separately, but applications usually need combined data.

For example, the UI may need to display:

Track                | Album   | Artist       | Genre
---------------------+---------+--------------+------
Numb                 | Meteora | Linkin Park  | Rock
Faint                | Meteora | Linkin Park  | Rock
Breaking the Habit   | Meteora | Linkin Park  | Rock

SQL JOIN operations reconstruct this result.
*/


SELECT
    tracks.id AS track_id,
    tracks.title AS track_title,
    albums.title AS album_title,
    artists.name AS artist_name,
    genres.name AS genre_name,
    tracks.duration_seconds
FROM tracks
JOIN albums
    ON albums.id = tracks.album_id
JOIN artists
    ON artists.id = albums.artist_id
JOIN genres
    ON genres.id = tracks.genre_id
ORDER BY tracks.id;


/*
How the JOIN works:

1. tracks.album_id finds the matching albums.id.

2. albums.artist_id finds the matching artists.id.

3. tracks.genre_id finds the matching genres.id.

The database follows the relationships created by the foreign keys.
*/


-- =====================================================================
--                      STEP-BY-STEP ROW RECONSTRUCTION
-- =====================================================================

/*
Suppose this track row exists:

tracks:

id | album_id | genre_id | title
---+----------+----------+------
1  | 1        | 1        | Numb


Step 1:

    tracks.album_id = 1

Find album:

albums:

id | artist_id | title
---+-----------+--------
1  | 1         | Meteora


Step 2:

    albums.artist_id = 1

Find artist:

artists:

id | name
---+-------------
1  | Linkin Park


Step 3:

    tracks.genre_id = 1

Find genre:

genres:

id | name
---+------
1  | Rock


Final reconstructed result:

Numb | Meteora | Linkin Park | Rock
*/


-- =====================================================================
--                      USER INTERFACE VS STORAGE
-- =====================================================================

/*
The user interface may display repeated information:

Numb   | Linkin Park | Meteora | Rock
Faint  | Linkin Park | Meteora | Rock

This does not mean the database physically stores all those strings in
every track row.

The interface is designed for humans.

The database model is designed for:

    - Correctness
    - Storage efficiency
    - Data integrity
    - Query performance
*/


/*
The database stores:

    artist_id = 1
    album_id = 1
    genre_id = 1

The JOIN query converts those IDs into human-readable values.
*/


-- =====================================================================
--                    REAL EXAMPLE: USER AND MESSAGES
-- =====================================================================

/*
The same principles apply to messaging applications.

Bad design:

message_id | sender_name | sender_email | content
-----------+-------------+--------------+---------
1          | John        | john@mail.com| Hello
2          | John        | john@mail.com| Hi again

John's information is duplicated.
*/


CREATE TABLE chat_users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL
);


CREATE TABLE chat_messages (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sender_id INTEGER NOT NULL REFERENCES chat_users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


/*
Keys:

chat_users.id:

    Primary key

chat_users.username:

    Logical key

chat_users.email:

    Logical key

chat_messages.sender_id:

    Foreign key
*/


INSERT INTO chat_users (
    username,
    email
)
VALUES (
    'john_dev',
    'john@example.com'
);


INSERT INTO chat_messages (
    sender_id,
    content
)
VALUES
    (1, 'Hello'),
    (1, 'How are you?'),
    (1, 'See you later');


SELECT
    chat_messages.id,
    chat_users.username,
    chat_users.email,
    chat_messages.content,
    chat_messages.created_at
FROM chat_messages
JOIN chat_users
    ON chat_users.id = chat_messages.sender_id;


/*
The user is stored once.

The user's primary key is repeated in the message rows:

    sender_id = 1

Repeating small integer foreign keys is intentional.

Repeating complete user information is usually unnecessary.
*/


-- =====================================================================
--                  DUPLICATION IS NOT ALWAYS BAD
-- =====================================================================

/*
Not all repeated values are automatically a design mistake.

Foreign-key values are expected to repeat.

Example:

sender_id
---------
1
1
1

This repetition represents a relationship:

    One user sent many messages.

What should usually be avoided is repeatedly storing dependent data:

    John
    john@example.com

in every message row.
*/


-- =====================================================================
--                      DELETE BEHAVIOR OF FOREIGN KEYS
-- =====================================================================

/*
Consider this relationship:

    artists.id <---- albums.artist_id

What should happen if an artist is deleted?

PostgreSQL supports several behaviors.
*/


/*
1. RESTRICT / NO ACTION

Do not allow the artist to be deleted while albums reference it.
*/


CREATE TABLE restricted_albums (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    artist_id INTEGER NOT NULL REFERENCES artists(id),
    title TEXT NOT NULL
);


/*
2. CASCADE

Deleting the parent automatically deletes related children.

Use carefully.
*/


CREATE TABLE cascading_albums (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    artist_id INTEGER NOT NULL
        REFERENCES artists(id)
        ON DELETE CASCADE,
    title TEXT NOT NULL
);


/*
If artist 1 is deleted, every cascading album with artist_id = 1 is also
deleted.

This may be appropriate when child rows have no meaning without the parent.
*/


/*
3. SET NULL

Deleting the parent sets the foreign key to NULL.

The foreign-key column must allow NULL.
*/


CREATE TABLE nullable_albums (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    artist_id INTEGER
        REFERENCES artists(id)
        ON DELETE SET NULL,
    title TEXT NOT NULL
);


/*
After the artist is deleted:

    artist_id = NULL

The album remains, but it is no longer connected to an artist.
*/


-- =====================================================================
--                 ONE-TO-MANY RELATIONSHIP SUMMARY
-- =====================================================================

/*
One artist can have many albums.

Parent table:

    artists

Child table:

    albums

The foreign key is stored on the many side:

    albums.artist_id
*/


/*
Rule:

For a one-to-many relationship, place the foreign key inside the table
representing the many side.

Examples:

    One user has many messages
        -> messages.sender_id

    One album has many tracks
        -> tracks.album_id

    One category has many products
        -> products.category_id

    One author writes many articles
        -> articles.author_id
*/


-- =====================================================================
--                    MANY-TO-MANY RELATIONSHIPS
-- =====================================================================

/*
Sometimes both sides can have many related rows.

Example:

    A track can belong to many playlists.
    A playlist can contain many tracks.

This is a many-to-many relationship.

A single foreign key cannot represent it correctly.

We use a junction table.
*/


CREATE TABLE playlists (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL
);


CREATE TABLE playlist_tracks (
    playlist_id INTEGER NOT NULL
        REFERENCES playlists(id)
        ON DELETE CASCADE,

    track_id INTEGER NOT NULL
        REFERENCES tracks(id)
        ON DELETE CASCADE,

    position INTEGER CHECK (position > 0),

    PRIMARY KEY (playlist_id, track_id)
);


/*
The playlist_tracks table connects playlists and tracks.

Example:

playlist_id | track_id
------------+---------
1           | 1
1           | 2
1           | 3
2           | 1

Meaning:

    Playlist 1 contains tracks 1, 2, and 3.
    Playlist 2 contains track 1.

Track 1 belongs to multiple playlists.
*/


-- =====================================================================
--                        COMPOSITE PRIMARY KEY
-- =====================================================================

/*
The junction table uses:

    PRIMARY KEY (playlist_id, track_id)

This is called a composite primary key.

The combination must be unique.

Valid:

playlist_id | track_id
------------+---------
1           | 1
1           | 2

Invalid duplicate:

playlist_id | track_id
------------+---------
1           | 1
1           | 1
*/


/*
Neither playlist_id nor track_id is individually unique.

But the pair is unique:

    (playlist_id, track_id)
*/


-- =====================================================================
--                      NATURAL KEYS VS SURROGATE KEYS
-- =====================================================================

/*
NATURAL KEY:

A real-world value that naturally identifies something.

Examples:

    Email address
    ISBN
    Social Security number
    Country code
    Product SKU


SURROGATE KEY:

An artificial identifier created only for the database.

Examples:

    id = 1
    id = 42
    UUID
*/


/*
In this example:

    artists.id

is a surrogate key.

    application_users.email

is a natural or logical key.
*/


/*
A common practical design is:

    - Use a surrogate integer or UUID as the primary key.
    - Protect important natural keys with UNIQUE constraints.

Example:

CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email TEXT UNIQUE NOT NULL
);
*/


-- =====================================================================
--                       WHY NOT USE EMAIL AS ID?
-- =====================================================================

/*
Suppose email is used as the primary key:

users:

email
----------------
john@example.com


messages:

sender_email
----------------
john@example.com
john@example.com
john@example.com

Problems:

    - Strings use more storage than integers.
    - String comparisons are usually more expensive.
    - Every index becomes larger.
    - Email can change.
    - The user's identity becomes tied to a mutable value.
*/


/*
With an integer primary key:

users:

id | email
---+------------------
1  | john@example.com


messages:

sender_id
---------
1
1
1

If John's email changes:

    john@example.com
            |
            v
    john.new@example.com

The messages table does not need to change.
*/


-- =====================================================================
--                        KEY NAMING CONVENTIONS
-- =====================================================================

/*
Common naming convention:

Primary key:

    id

Foreign key:

    referenced_table_singular + _id


Examples:

    users.id
    messages.sender_id

    artists.id
    albums.artist_id

    albums.id
    tracks.album_id

    conversations.id
    conversation_members.conversation_id
*/


/*
A clear foreign-key name should describe the role.

For example, a messages table might contain:

    sender_id
    recipient_id
    reply_to_message_id

All three may reference IDs, but each one has a different purpose.
*/


-- =====================================================================
--                       DATABASE DESIGN PROCESS
-- =====================================================================

/*
A practical relational database modeling process:

1. Identify the main entities.

Example:

    Artist
    Album
    Track
    Genre
    Playlist


2. Create one table for each important entity.


3. Give every table a primary key.


4. Identify meaningful logical keys.

Examples:

    email
    username
    slug
    SKU


5. Add UNIQUE constraints to logical keys where necessary.


6. Identify relationships.

Examples:

    One artist has many albums.
    One album has many tracks.
    Many playlists contain many tracks.


7. Add foreign keys to represent those relationships.


8. Use junction tables for many-to-many relationships.


9. Remove unnecessary duplicated data.


10. Add indexes and constraints based on application queries.
*/


-- =====================================================================
--                         COMPLETE DATA MODEL
-- =====================================================================

/*
Final visual model:

artists
    |
    | one artist has many albums
    v
albums
    |
    | one album has many tracks
    v
tracks
    ^
    | many tracks belong to one genre
    |
genres


playlists
    |
    | one playlist has many playlist-track rows
    v
playlist_tracks
    ^
    | one track has many playlist-track rows
    |
tracks
*/


/*
Key relationships:

artists.id
    <---------------- albums.artist_id

albums.id
    <---------------- tracks.album_id

genres.id
    <---------------- tracks.genre_id

playlists.id
    <---------------- playlist_tracks.playlist_id

tracks.id
    <---------------- playlist_tracks.track_id
*/


-- =====================================================================
--                             FINAL QUERY
-- =====================================================================

/*
Retrieve all tracks with their complete related information.
*/


SELECT
    tracks.id AS track_id,
    tracks.title AS track_name,
    tracks.duration_seconds,
    albums.id AS album_id,
    albums.title AS album_name,
    artists.id AS artist_id,
    artists.name AS artist_name,
    genres.id AS genre_id,
    genres.name AS genre_name
FROM tracks
JOIN albums
    ON albums.id = tracks.album_id
JOIN artists
    ON artists.id = albums.artist_id
JOIN genres
    ON genres.id = tracks.genre_id
ORDER BY
    artists.name,
    albums.title,
    tracks.id;


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
PRIMARY KEY:

    - Uniquely identifies a row in its own table.
    - Usually an integer or UUID.
    - Must be unique and not NULL.

Example:

    users.id


LOGICAL KEY:

    - Meaningful to the application or user.
    - Frequently used for lookups.
    - Often protected by a UNIQUE constraint.
    - Usually supported by an index.

Examples:

    users.email
    users.username
    products.sku


FOREIGN KEY:

    - References a row in another table.
    - Usually stores another table's primary key.
    - Represents relationships.
    - Enforces referential integrity.

Example:

    messages.sender_id references users.id


NORMALIZATION:

    - Separates different entities into different tables.
    - Reduces unnecessary duplication.
    - Prevents inconsistent updates.
    - Connects data through foreign keys.


JOIN:

    - Reconstructs related data from normalized tables.
    - Converts internal IDs into useful application information.
*/


/*
CORE PRINCIPLE:

Store each important fact once where practical.

Use:

    - Primary keys to identify rows
    - Logical keys to find rows
    - Foreign keys to connect rows
    - JOIN queries to reconstruct related information

The application displays connected data.

The relational model defines how that data is correctly stored.
*/
```
