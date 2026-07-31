-- =====================================================================
--                    POSTGRESQL DATA TYPES
--                    THEORY + DEMO QUERIES
-- =====================================================================



-- =====================================================================
--                       CHAR(n) VS VARCHAR(n)
-- =====================================================================

/*
CHAR(n):
    - Stores fixed-length text.
    - PostgreSQL pads shorter values with spaces.
    - Rarely needed.
    - Possible use case: truly fixed-length codes.

VARCHAR(n):
    - Stores variable-length text.
    - Accepts at most n characters.
    - Does not pad shorter values.

Examples:
    CHAR(5):    'AB' is internally padded to 'AB   '
    VARCHAR(5): 'AB' remains 'AB'

In PostgreSQL, VARCHAR or TEXT is generally preferred over CHAR.
*/


-- CHAR demo

SELECT
    'AB'::CHAR(5) AS char_value,
    LENGTH('AB'::CHAR(5)) AS character_length,
    OCTET_LENGTH('AB'::CHAR(5)) AS storage_bytes;


-- VARCHAR demo

SELECT
    'AB'::VARCHAR(5) AS char_value,
    LENGTH('AB'::VARCHAR(5)) AS char_length,
    OCTET_LENGTH('AB'::VARCHAR(5)) AS storage_bytes;


-- Temporary table demo

CREATE TEMP TABLE string_demo (
    country_code CHAR(2),
    username VARCHAR(20)
);

INSERT INTO string_demo (country_code, username)
VALUES
    ('US', 'John'),
    ('BD', 'Nishat'),
    ('ES', 'Alejandro');

SELECT * FROM string_demo;


-- VARCHAR limit error:
-- This fails because the value contains more than 5 characters.

-- SELECT 'PostgreSQL'::VARCHAR(5);



-- =====================================================================
--                              TEXT
-- =====================================================================

/*
TEXT:
    - Stores variable-length text.
    - Has no declared character limit.
    - Supports Unicode and multilingual text.
    - Can store English, Spanish, Bengali, Chinese, Arabic and emoji.

Common uses:
    - Names
    - Bios
    - Descriptions
    - Messages
    - Articles
    - Comments
    - Multilingual content

TEXT and VARCHAR have essentially the same performance in PostgreSQL.
Use VARCHAR(n) when a maximum length is an actual business rule.
*/


SELECT
    'PostgreSQL can store long text.'::TEXT AS text_value;


-- Multilingual Unicode text

SELECT
    'English | Español | বাংলা | 中文 | العربية | 🚀'::TEXT
    AS multilingual_text;


CREATE TEMP TABLE text_demo (
    name TEXT,
    bio TEXT,
    message TEXT
);

INSERT INTO text_demo (name, bio, message)
VALUES (
    '张伟',
    'Backend developer learning PostgreSQL.',
    'Hola, 你好, আসসালামু আলাইকুম 🚀'
);

SELECT * FROM text_demo;



-- =====================================================================
--                         BYTEA — BINARY DATA
-- =====================================================================

/*
BYTEA:
    - Stores raw binary bytes instead of readable text.
    - BYTEA means "byte array."
    - The stored value may represent file content or encoded information.

Possible uses:
    - Small images
    - Small PDFs
    - Encrypted bytes
    - Binary files
    - Cryptographic hashes

For large files:
    - Store the actual file in cloud/object storage.
    - Store only its URL or object key in PostgreSQL.

Examples of external storage:
    - Amazon S3
    - Cloudinary
    - Google Cloud Storage
*/


-- Convert readable text into UTF-8 bytes

SELECT
    CONVERT_TO('Hello PostgreSQL', 'UTF8') AS binary_data;


-- Convert binary bytes back into readable text

SELECT
    CONVERT_FROM(
        CONVERT_TO('Hello PostgreSQL', 'UTF8'),
        'UTF8'
    ) AS decoded_text;


-- Hexadecimal bytes representing the word "Hello"

SELECT
    '\x48656c6c6f'::BYTEA AS hexadecimal_bytes;


-- Decode those hexadecimal bytes

SELECT
    CONVERT_FROM(
        '\x48656c6c6f'::BYTEA,
        'UTF8'
    ) AS decoded_value;


CREATE TEMP TABLE bytea_demo (
    file_name TEXT,
    file_data BYTEA
);

INSERT INTO bytea_demo (file_name, file_data)
VALUES (
    'lesson.txt',
    CONVERT_TO('This is the file content.', 'UTF8')
);

SELECT
    file_name,
    file_data,
    CONVERT_FROM(file_data, 'UTF8') AS readable_content
FROM bytea_demo;



-- =====================================================================
--                        INTEGER NUMBER TYPES
-- =====================================================================

/*
PostgreSQL integer types store signed whole numbers.

"Signed" means they can store:
    - Negative numbers
    - Zero
    - Positive numbers

SMALLINT:
    - 2 bytes
    - Range: -32,768 to 32,767

INTEGER:
    - 4 bytes
    - Range: approximately -2.1 billion to +2.1 billion
    - Most commonly used integer type

BIGINT:
    - 8 bytes
    - Range: approximately -9.2 × 10^18 to +9.2 × 10^18

Common uses:
    SMALLINT → ratings, small counters, limited quantities
    INTEGER  → age, quantity, ordinary counters
    BIGINT   → huge counters, large identifiers, view counts
*/


SELECT
    32767::SMALLINT AS smallint_max,
    2147483647::INTEGER AS integer_max,
    9223372036854775807::BIGINT AS bigint_max;


SELECT
    -32766::SMALLINT AS smallint_min,
    -2147483648::INTEGER AS integer_min,
    -9223372036854775808::BIGINT AS bigint_min;


CREATE TEMP TABLE integer_demo (
    rating SMALLINT,
    quantity INTEGER,
    total_views BIGINT
);

INSERT INTO integer_demo (rating, quantity, total_views)
VALUES
    (5, 2500, 8000000000),
    (-2, 100, 12000000000);

SELECT * FROM integer_demo;


-- Overflow demo:
-- This fails because 32,768 is outside the SMALLINT range.

-- SELECT 32768::SMALLINT;



-- =====================================================================
--                       DECIMAL / FLOATING NUMBERS
-- =====================================================================

/*
REAL:
    - 4 bytes / 32-bit floating point
    - Approximately 6–7 significant digits
    - Approximate, not exact
    - Less commonly used

DOUBLE PRECISION:
    - 8 bytes / 64-bit floating point
    - Approximately 15 significant digits
    - Approximate, not exact
    - Common for measurements, coordinates and scientific values

NUMERIC(p, s):
    - Exact decimal type
    - p = precision: total number of digits
    - s = scale: number of digits after the decimal point

Example:
    NUMERIC(10, 2)

    Maximum total digits: 10
    Digits after decimal: 2

    Example valid value:
    12345678.90

Typical choices:
    Money and prices       → NUMERIC
    Measurements           → DOUBLE PRECISION
    Scientific calculations → DOUBLE PRECISION
*/


-- Compare their precision

SELECT
    12345.67890123456789::REAL AS real_value,
    12345.67890123456789::DOUBLE PRECISION AS double_value,
    12345.67890123456789::NUMERIC AS numeric_value;


-- Floating-point arithmetic is approximate

SELECT
    0.1::DOUBLE PRECISION + 0.2::DOUBLE PRECISION
    AS approximate_result;


-- NUMERIC arithmetic is exact

SELECT
    0.1::NUMERIC + 0.2::NUMERIC
    AS exact_result;


-- NUMERIC(10, 2): 10 total digits and 2 after the decimal

SELECT
    12345678.90::NUMERIC(10, 2) AS exact_price;


-- Extra decimal places are rounded to the specified scale

SELECT
    19.999::NUMERIC(5, 2) AS rounded_value;


CREATE TEMP TABLE decimal_demo (
    temperature DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    price NUMERIC(10, 2)
);

INSERT INTO decimal_demo (temperature, latitude, price)
VALUES
    (98.7654321, 40.7128, 1299.99),
    (-5.5234567, 23.8103, 49.50);

SELECT * FROM decimal_demo;



-- =====================================================================
--                         DATE AND TIME TYPES
-- =====================================================================

/*
DATE:
    - Stores a calendar date only.
    - Example: '2026-07-28'

TIME:
    - Stores a time of day without a date.
    - Example: '11:30:00'

TIMESTAMP:
    - Stores a date and time.
    - Does not perform timezone conversion.

TIMESTAMPTZ:
    - Means TIMESTAMP WITH TIME ZONE.
    - Stores an exact moment in time.
    - PostgreSQL displays it using the current session timezone.
    - Usually preferred for created_at, updated_at and event timestamps.

NOW():
    - Returns the current transaction timestamp.
    - Its result is TIMESTAMPTZ.

Recommended backend default:
    created_at TIMESTAMPTZ DEFAULT NOW()
*/


-- Current date and time with timezone handling

SELECT NOW();


-- SQL-standard equivalent commonly used for the current timestamp

SELECT CURRENT_TIMESTAMP;


-- Current date only

SELECT CURRENT_DATE;


-- Current time with timezone information

SELECT CURRENT_TIME;


-- Local time without timezone information

SELECT LOCALTIME;


-- Local date and time without timezone information

SELECT LOCALTIMESTAMP;


-- Display the current PostgreSQL session timezone

SHOW TIMEZONE;



-- =====================================================================
--                    MANUAL DATE AND TIME VALUES
-- =====================================================================

-- DATE value

SELECT
    '2026-07-28'::DATE AS date_value;


-- TIME value

SELECT
    '11:30:45'::TIME AS time_value;


-- TIMESTAMP without timezone

SELECT
    '2026-07-28 11:30:45'::TIMESTAMP
    AS timestamp_value;


-- TIMESTAMPTZ with an explicit UTC offset

SELECT
    '2026-07-28 11:30:45-04'::TIMESTAMPTZ
    AS timestamptz_value;



-- =====================================================================
--                     DATE AND TIME TABLE DEMO
-- =====================================================================

CREATE TEMP TABLE date_demo (
    event_name TEXT,
    event_date DATE,
    event_time TIME,
    local_timestamp TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- created_at is omitted because DEFAULT NOW() fills it automatically

INSERT INTO date_demo (
    event_name,
    event_date,
    event_time,
    local_timestamp
)
VALUES (
    'PostgreSQL lesson',
    CURRENT_DATE,
    LOCALTIME,
    LOCALTIMESTAMP
);

SELECT * FROM date_demo;



-- =====================================================================
--                     EXTRACT DATE/TIME PARTS
-- =====================================================================

/*
EXTRACT:
    Pulls one specific part from a date or timestamp.

Possible parts:
    - YEAR
    - MONTH
    - DAY
    - HOUR
    - MINUTE
    - SECOND
*/


SELECT
    NOW() AS complete_timestamp,
    EXTRACT(YEAR FROM NOW()) AS current_year,
    EXTRACT(MONTH FROM NOW()) AS current_month,
    EXTRACT(DAY FROM NOW()) AS current_day,
    EXTRACT(HOUR FROM NOW()) AS current_hour,
    EXTRACT(MINUTE FROM NOW()) AS current_minute,
    EXTRACT(SECOND FROM NOW()) AS current_second;



-- =====================================================================
--                        FORMAT A TIMESTAMP
-- =====================================================================

/*
TO_CHAR:
    Converts a date or timestamp into formatted text.

Important format patterns:
    YYYY → four-digit year
    MM   → month
    DD   → day
    HH24 → hour using 24-hour format
    MI   → minute
    SS   → second
*/


SELECT
    TO_CHAR(
        NOW(),
        'YYYY-MM-DD HH24:MI:SS'
    ) AS formatted_timestamp;



-- =====================================================================
--                         DATE ARITHMETIC
-- =====================================================================

/*
PostgreSQL can add or subtract values from dates and timestamps.

DATE + integer:
    Adds that number of days.

INTERVAL:
    Represents a duration such as:
    - 2 hours
    - 7 days
    - 1 month
*/


SELECT
    CURRENT_DATE AS today,
    CURRENT_DATE + 7 AS seven_days_later,
    CURRENT_DATE - 7 AS seven_days_ago;


SELECT
    NOW() AS current_time,
    NOW() + INTERVAL '2 hours' AS two_hours_later,
    NOW() - INTERVAL '30 minutes' AS thirty_minutes_ago,
    NOW() + INTERVAL '1 month' AS one_month_later;



-- =====================================================================
--                           TIMEZONE DEMO
-- =====================================================================

/*
AT TIME ZONE:
    Displays a timestamp using a selected timezone.

TIMESTAMPTZ represents one exact moment.
That same moment can appear differently in different timezones.
*/


SELECT
    NOW() AS session_time,
    NOW() AT TIME ZONE 'UTC' AS utc_time,
    NOW() AT TIME ZONE 'America/New_York' AS new_york_time,
    NOW() AT TIME ZONE 'Asia/Dhaka' AS dhaka_time;



-- =====================================================================
--                  OPTIONAL: REMOVE TEMPORARY TABLES
-- =====================================================================

/*
Temporary tables disappear automatically when the database session ends.

These DROP statements remove them manually.
Run these only after completing all the demos.
*/

DROP TABLE string_demo;
DROP TABLE text_demo;
DROP TABLE bytea_demo;
DROP TABLE integer_demo;
DROP TABLE decimal_demo;
DROP TABLE date_demo;