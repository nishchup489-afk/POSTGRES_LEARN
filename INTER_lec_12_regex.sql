-- =====================================================================
--                 REGULAR EXPRESSIONS IN POSTGRESQL
-- =====================================================================

/*
A regular expression, or regex, is a text pattern.

Regex is used to:

    - Search text
    - Match text patterns
    - Validate text
    - Extract parts of text
    - Find complex character combinations


Regex is more powerful than LIKE.

LIKE handles simple patterns.

Regex handles more detailed patterns.
*/


-- =====================================================================
--                         SAMPLE TABLE
-- =====================================================================

DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(30)
);


INSERT INTO users (name, email, phone)
VALUES
    ('Alice', 'alice@example.com', '212-555-1234'),
    ('Bob', 'bob99@gmail.com', '718-555-8888'),
    ('Charlie', 'charlie@test.org', '646-555-9999'),
    ('carol', 'carol@example.com', '917-555-2222'),
    ('David', 'david123@company.net', 'invalid');


-- =====================================================================
--                     POSTGRESQL REGEX OPERATORS
-- =====================================================================

/*
PostgreSQL provides these regex operators:

    ~
        Matches regex, case-sensitive

    ~*
        Matches regex, case-insensitive

    !~
        Does not match regex, case-sensitive

    !~*
        Does not match regex, case-insensitive
*/


-- =====================================================================
--                       BASIC REGEX MATCH
-- =====================================================================

/*
Find names containing the letter "a".

Regex automatically searches anywhere
inside the text unless anchors are used.
*/

SELECT * FROM users WHERE name ~ 'a';


/*
Possible matches:

    Charlie
    carol
    David
*/


-- =====================================================================
--                     CASE-INSENSITIVE MATCH
-- =====================================================================

/*
~* ignores uppercase and lowercase differences.
*/

SELECT *
FROM users
WHERE name ~* 'alice';


/*
Matches:

    Alice
    alice
    ALICE
*/


-- =====================================================================
--                      DOES NOT MATCH
-- =====================================================================

/*
Find emails that do not contain gmail.
*/

SELECT *
FROM users
WHERE email !~ 'gmail';


/*
Case-insensitive version:
*/

SELECT *
FROM users
WHERE email !~* 'gmail';


-- =====================================================================
--                     START OF STRING: ^
-- =====================================================================

/*
^ means:

Start of the string.
*/


/*
Find names starting with A.
*/

SELECT *
FROM users
WHERE name ~ '^A';


/*
Matches:

    Alice
*/


/*
Case-insensitive:
*/

SELECT *
FROM users
WHERE name ~* '^a';


/*
Matches:

    Alice
    carol does not match because it starts with c
*/


-- =====================================================================
--                      END OF STRING: $
-- =====================================================================

/*
$ means:

End of the string.
*/


/*
Find emails ending with .com.
*/

SELECT *
FROM users
WHERE email ~ '\.com$';


/*
The dot is escaped with \.

Without escaping, dot means any character.
*/


-- =====================================================================
--                         DOT WILDCARD: .
-- =====================================================================

/*
. matches any single character.
*/


SELECT *
FROM users
WHERE name ~ '^A...e$';


/*
Pattern:

    ^       Start
    A       Letter A
    ...     Any three characters
    e       Letter e
    $       End


Matches:

    Alice
*/


-- =====================================================================
--                         ASTERISK: *
-- =====================================================================

/*
* means:

Zero or more repetitions
of the previous character or group.
*/


SELECT *
FROM users
WHERE name ~ '^Bo*b$';


/*
Can match:

    Bb
    Bob
    Boob
    Booob
*/


-- =====================================================================
--                           PLUS: +
-- =====================================================================

/*
+ means:

One or more repetitions
of the previous character or group.
*/


SELECT *
FROM users
WHERE email ~ '[0-9]+';


/*
Matches emails containing
one or more digits.

Examples:

    bob99@gmail.com
    david123@company.net
*/


-- =====================================================================
--                      QUESTION MARK: ?
-- =====================================================================

/*
? means:

Zero or one occurrence
of the previous character or group.
*/


SELECT *
FROM users
WHERE name ~ '^Dav?id$';


/*
Can match:

    David
    Davd
*/


-- =====================================================================
--                       CHARACTER SET: []
-- =====================================================================

/*
Square brackets match one character
from a set.
*/


SELECT *
FROM users
WHERE name ~ '^[ABC]';


/*
Matches names starting with:

    A
    B
    C
*/


-- =====================================================================
--                       CHARACTER RANGE
-- =====================================================================

/*
Ranges can be written inside brackets.
*/


-- Any lowercase letter

SELECT *
FROM users
WHERE name ~ '[a-z]';


-- Any uppercase letter

SELECT *
FROM users
WHERE name ~ '[A-Z]';


-- Any digit

SELECT *
FROM users
WHERE email ~ '[0-9]';


-- =====================================================================
--                      NEGATED CHARACTER SET
-- =====================================================================

/*
[^...] means:

Match a character not inside the set.
*/


SELECT *
FROM users
WHERE name ~ '^[^A]';


/*
Matches names that do not start with A.
*/


-- =====================================================================
--                         DIGIT SHORTCUT
-- =====================================================================

/*
PostgreSQL supports POSIX character classes.

Digits:
*/

SELECT *
FROM users
WHERE email ~ '[[:digit:]]';


/*
One or more digits:
*/

SELECT *
FROM users
WHERE email ~ '[[:digit:]]+';


-- =====================================================================
--                       LETTER CHARACTER CLASS
-- =====================================================================

/*
Alphabetic characters:
*/

SELECT *
FROM users
WHERE name ~ '^[[:alpha:]]+$';


/*
Meaning:

    ^                Start
    [[:alpha:]]+     One or more letters
    $                End


Matches names containing only letters.
*/


-- =====================================================================
--                      ALPHANUMERIC CLASS
-- =====================================================================

/*
Letters or numbers:
*/

SELECT *
FROM users
WHERE name ~ '^[[:alnum:]]+$';


-- =====================================================================
--                         GROUPING: ()
-- =====================================================================

/*
Parentheses group parts
of a regular expression.
*/


SELECT *
FROM users
WHERE email ~ '(gmail|example)\.com$';


/*
Matches emails ending with:

    gmail.com

or

    example.com
*/


-- =====================================================================
--                      ALTERNATION: |
-- =====================================================================

/*
| means OR.
*/


SELECT *
FROM users
WHERE name ~ '^(Alice|Bob|Charlie)$';


/*
Matches exactly:

    Alice
    Bob
    Charlie
*/


-- =====================================================================
--                       EXACT FULL MATCH
-- =====================================================================

/*
Use both ^ and $ when the entire string
must match the pattern.
*/


SELECT *
FROM users
WHERE phone ~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$';


/*
Matches phone numbers like:

    212-555-1234
*/


-- =====================================================================
--                       REPETITION COUNTS
-- =====================================================================

/*
{n}

Exactly n repetitions.
*/


SELECT *
FROM users
WHERE phone ~ '[0-9]{3}';


/*
{n,m}

Between n and m repetitions.
*/


SELECT *
FROM users
WHERE email ~ '[0-9]{2,4}';


/*
{n,}

At least n repetitions.
*/

SELECT *
FROM users
WHERE email ~ '[0-9]{2,}';


-- =====================================================================
--                    EMAIL STARTING WITH C
-- =====================================================================

/*
Find emails starting with c.
*/

SELECT *
FROM users
WHERE email ~ '^c';


/*
Case-insensitive:
*/

SELECT *
FROM users
WHERE email ~* '^c';


-- =====================================================================
--                  EMAIL WITH DIGITS BEFORE @
-- =====================================================================

SELECT *
FROM users
WHERE email ~ '^[^@]*[0-9]+[^@]*@';


/*
Meaning:

    ^           Start

    [^@]*       Any number of non-@ characters

    [0-9]+      One or more digits

    [^@]*       More non-@ characters

    @           Must contain @
*/


-- =====================================================================
--                         LIKE vs REGEX
-- =====================================================================

/*
LIKE is simpler.

Regex is more powerful.
*/


/*
LIKE:

    %    Zero or more characters

    _    Exactly one character
*/


SELECT *
FROM users
WHERE name LIKE 'A%';


/*
Equivalent regex:
*/

SELECT *
FROM users
WHERE name ~ '^A';


/*
LIKE search containing "li":
*/

SELECT *
FROM users
WHERE name LIKE '%li%';


/*
Equivalent regex:
*/

SELECT *
FROM users
WHERE name ~ 'li';


-- =====================================================================
--                 IMPORTANT DIFFERENCE FROM LIKE
-- =====================================================================

/*
LIKE normally requires % to search anywhere.

Example:

    LIKE '%li%'


Regex automatically searches anywhere.

Example:

    ~ 'li'
*/


/*
To force regex to match the full string,
use:

    ^pattern$
*/


-- =====================================================================
--                        SUBSTRING WITH REGEX
-- =====================================================================

/*
SUBSTRING can extract text
using a regular expression.
*/


SELECT
    email,
    SUBSTRING(email FROM '@(.+)$') AS domain
FROM users;


/*
Example result:

alice@example.com

↓

example.com
*/


-- =====================================================================
--                         REGEXP_MATCH()
-- =====================================================================

/*
REGEXP_MATCH returns captured groups
from the first match.
*/


SELECT REGEXP_MATCH(
    'alice@example.com',
    '^([^@]+)@(.+)$'
);


/*
Possible result:

{alice,example.com}
*/


/*
Captured groups:

    ([^@]+)
        Username

    (.+)
        Domain
*/


-- =====================================================================
--                        REGEXP_MATCHES()
-- =====================================================================

/*
REGEXP_MATCHES can find regex matches.

The 'g' flag means global:
find every match.
*/


SELECT REGEXP_MATCHES(
    'Order 123 contains 45 items',
    '[0-9]+',
    'g'
);


/*
Returns:

123

45
*/


-- =====================================================================
--                        REGEXP_REPLACE()
-- =====================================================================

/*
REGEXP_REPLACE replaces text
matching a regex pattern.
*/


SELECT REGEXP_REPLACE(
    'Phone: 212-555-1234',
    '[0-9]',
    'X',
    'g'
);


/*
Result:

Phone: XXX-XXX-XXXX
*/


/*
Without 'g',
only the first match is replaced.
*/


-- =====================================================================
--                        REGEXP_SPLIT_TO_TABLE
-- =====================================================================

/*
Split text into multiple rows.
*/

SELECT REGEXP_SPLIT_TO_TABLE(
    'python,sql,postgresql',
    ','
);


/*
Result:

python
sql
postgresql
*/


-- =====================================================================
--                       PRACTICAL EXAMPLES
-- =====================================================================

/*
Names starting with A, B, or C.
*/

SELECT *
FROM users
WHERE name ~ '^[ABC]';


/*
Emails ending in .com or .org.
*/

SELECT *
FROM users
WHERE email ~ '\.(com|org)$';


/*
Emails containing at least one digit.
*/

SELECT *
FROM users
WHERE email ~ '[0-9]';


/*
Names containing only letters.
*/

SELECT *
FROM users
WHERE name ~ '^[[:alpha:]]+$';


/*
Valid simple phone format.
*/

SELECT *
FROM users
WHERE phone ~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$';


-- =====================================================================
--                      PERFORMANCE NOTE
-- =====================================================================

/*
Regex is powerful but can be slower
than simple equality or prefix searches.

Usually faster:

    WHERE email = 'alice@example.com'

    WHERE email LIKE 'alice%'


Potentially slower:

    WHERE email ~ '.*alice.*'

    WHERE email ~* '[complex pattern]'
*/


/*
Use regex when the pattern truly requires it.

Do not replace simple equality
with regex unnecessarily.
*/


-- =====================================================================
--                        PRACTICAL RULES
-- =====================================================================

/*
1. Use = for exact matching.

2. Use LIKE for simple wildcard matching.

3. Use regex for complex patterns.

4. Use ^ to match the beginning.

5. Use $ to match the end.

6. Use [] for character sets.

7. Use + for one or more.

8. Use * for zero or more.

9. Use () to group patterns.

10. Use ~* for case-insensitive regex matching.
*/


-- =====================================================================
--                              SUMMARY
-- =====================================================================

/*
Regex operators:

    ~
        Match, case-sensitive

    ~*
        Match, case-insensitive

    !~
        Does not match

    !~*
        Does not match, case-insensitive


Core symbols:

    ^
        Start of string

    $
        End of string

    .
        Any one character

    *
        Zero or more

    +
        One or more

    ?
        Zero or one

    []
        Character set

    [^]
        Negated character set

    ()
        Group

    |
        OR

    {n}
        Exact repetition count


Core idea:

LIKE is for simple text patterns.

Regular expressions are for complex,
structured text matching and extraction.
*/