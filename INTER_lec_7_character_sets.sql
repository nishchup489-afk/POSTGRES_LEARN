-- =====================================================================
--                CHARACTER SETS, ASCII, UNICODE & UTF-8
-- =====================================================================

/*
Computers do not store letters directly.

They store numbers.

A character set defines which number
represents each character.

Example:

    A
    B
    H
    *
    1

Each character is assigned a numeric code.
*/


-- =====================================================================
--                              ASCII
-- =====================================================================

/*
ASCII is an early standard character set.

ASCII uses 7 bits and defines 128 characters.

It includes:

    Uppercase letters
    Lowercase letters
    Numbers
    Punctuation
    Control characters
*/


/*
Examples:

    'A' = 65
    'H' = 72
    'a' = 97
    '*' = 42
*/


-- =====================================================================
--                 CHARACTER TO NUMERIC CODE
-- =====================================================================

/*
ASCII() returns the numeric code
of the first character.
*/

SELECT ASCII('H');


/*
Result:

72
*/


SELECT ASCII('*');


/*
Result:

42
*/


-- =====================================================================
--                 NUMERIC CODE TO CHARACTER
-- =====================================================================

/*
CHR() returns the character
represented by a numeric code.
*/

SELECT CHR(72);


/*
Result:

H
*/


SELECT CHR(42);


/*
Result:

*
*/


-- =====================================================================
--                      WHY CODES MATTER
-- =====================================================================

/*
Character codes affect:

    Sorting
    Comparisons
    Programming syntax
    Text processing
*/


/*
Uppercase letters have different codes
from lowercase letters.

Example:

    'A' = 65
    'a' = 97
*/


SELECT ASCII('A'), ASCII('a');


-- =====================================================================
--                     EXTENDED CHARACTER SETS
-- =====================================================================

/*
ASCII only supports 128 characters.

That is not enough for:

    Accented letters
    Arabic
    Bengali
    Chinese
    Japanese
    Emojis
    Many other writing systems
*/


/*
Later encodings added more characters.

Examples:

    Latin-1
    Windows-1252
*/


/*
The problem:

Different encodings could assign
different characters to the same byte value.

This caused corrupted text,
often called mojibake.
*/


-- =====================================================================
--                            UNICODE
-- =====================================================================

/*
Unicode was created as one universal
character system.

It assigns a unique code point
to characters from many languages.
*/


/*
Examples of Unicode characters:

    A
    é
    বাংলা
    العربية
    日本語
    🙂
*/


/*
A Unicode code point is commonly written like:

    U+0041

This represents:

    A
*/


-- =====================================================================
--                     UNICODE IS NOT UTF-8
-- =====================================================================

/*
Unicode defines the characters
and their code points.

UTF-8 defines how those code points
are stored as bytes.


Think:

Unicode
    What character is it?

UTF-8
    How is that character stored?
*/


-- =====================================================================
--                              UTF-8
-- =====================================================================

/*
UTF-8 is a Unicode encoding.

It uses between 1 and 4 bytes
for each character.
*/


/*
ASCII characters use 1 byte.

More complex characters may use
2, 3, or 4 bytes.
*/


/*
Examples:

    A       usually 1 byte

    é       usually 2 bytes

    বাংলা   multiple bytes per character

    🙂      usually 4 bytes
*/


-- =====================================================================
--                    ASCII COMPATIBILITY
-- =====================================================================

/*
UTF-8 is compatible with ASCII.

The first 128 UTF-8 values
match ASCII exactly.

This helped UTF-8 become widely adopted.
*/


-- =====================================================================
--                    CHARACTER vs BYTE LENGTH
-- =====================================================================

/*
LENGTH() counts characters.

OCTET_LENGTH() counts bytes.
*/


SELECT LENGTH('A');


/*
Result:

1 character
*/


SELECT OCTET_LENGTH('A');


/*
Result in UTF-8:

1 byte
*/


SELECT LENGTH('🙂');


/*
Result:

1 character
*/


SELECT OCTET_LENGTH('🙂');


/*
Result in UTF-8:

4 bytes
*/


-- =====================================================================
--                  POSTGRESQL DATABASE ENCODING
-- =====================================================================

/*
PostgreSQL databases have an encoding.

UTF8 is the normal modern choice.

Check the current database encoding:
*/

SHOW server_encoding;


/*
Common result:

UTF8
*/


/*
Check the client encoding:
*/

SHOW client_encoding;


/*
The client encoding controls how text
is exchanged between the client
and PostgreSQL.
*/


-- =====================================================================
--                    CREATE DATABASE WITH UTF-8
-- =====================================================================

/*
A database can be created
with UTF-8 encoding.
*/

CREATE DATABASE example_db
WITH ENCODING 'UTF8';


/*
In most modern PostgreSQL installations,
UTF8 is already the default.
*/


-- =====================================================================
--                     TEXT STORAGE TYPES
-- =====================================================================

/*
PostgreSQL text types include:

    CHAR
    VARCHAR
    TEXT

Their encoding comes from
the database encoding.
*/


CREATE TABLE messages (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    content TEXT NOT NULL
);


INSERT INTO messages (content)
VALUES
    ('Hello'),
    ('বাংলা'),
    ('مرحبا'),
    ('こんにちは'),
    ('🙂');


-- =====================================================================
--                        TEXT SORTING
-- =====================================================================

/*
Text sorting depends on:

    Character values
    Database collation
    Locale rules
*/


SELECT content
FROM messages
ORDER BY content;


/*
The result may differ depending
on the database collation.
*/


-- =====================================================================
--                           COLLATION
-- =====================================================================

/*
Encoding answers:

    How is text stored?


Collation answers:

    How is text compared and sorted?
*/


/*
Two databases can both use UTF-8
but sort text differently
because they use different collations.
*/


-- =====================================================================
--                    LEGACY ENCODING PROBLEMS
-- =====================================================================

/*
Old files may use encodings such as:

    LATIN1
    WIN1252
*/


/*
Reading a file with the wrong encoding
can produce broken text.

Example:

    café

may appear as corrupted characters.
*/


-- =====================================================================
--                 COPY WITH A SPECIFIC ENCODING
-- =====================================================================

/*
When importing legacy data,
you may specify its encoding.
*/

COPY messages(content)
FROM '/path/to/file.csv'
WITH (
    FORMAT CSV,
    ENCODING 'WIN1252'
);


/*
PostgreSQL can convert the incoming text
to the database encoding.
*/


-- =====================================================================
--                       WHY UTF-8 IS PREFERRED
-- =====================================================================

/*
UTF-8 is preferred because it:

    Supports many languages

    Supports emojis and symbols

    Preserves ASCII compatibility

    Uses variable-width storage

    Is widely supported by databases,
    programming languages, and the web
*/


-- =====================================================================
--                      UTF-8 vs UTF-32
-- =====================================================================

/*
UTF-32 normally uses 4 bytes
for every character.

UTF-8 uses:

    1 byte for common ASCII characters

    More bytes only when necessary
*/


/*
For mostly English text:

UTF-8 uses much less space
than UTF-32.
*/


-- =====================================================================
--                         PRACTICAL RULES
-- =====================================================================

/*
1. Use UTF-8 for modern applications.

2. Keep application, database,
   files, and APIs on compatible encodings.

3. Do not assume one character
   always equals one byte.

4. Use LENGTH() for characters.

5. Use OCTET_LENGTH() for bytes.

6. Convert legacy encodings
   when importing old data.

7. Remember that collation
   controls sorting behavior.
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
ASCII

    Early character set.

    Defines 128 characters.

    Uses numeric codes.


Unicode

    Universal collection of characters
    and code points.


UTF-8

    A way to encode Unicode characters.

    Uses 1 to 4 bytes.

    Compatible with ASCII.


PostgreSQL

    Supports multiple database encodings.

    UTF8 is the recommended modern choice.


Important functions:

    ASCII()
        Character to numeric code.

    CHR()
        Numeric code to character.

    LENGTH()
        Number of characters.

    OCTET_LENGTH()
        Number of bytes.


Core idea:

Characters are represented by numbers,
and encodings define how those numbers
are stored as bytes.
*/