# =====================================================================
#                         HASH FUNCTIONS
# =====================================================================

"""
A hash function takes input data
and converts it into a fixed-size output.

Input can be:

    Text
    File
    Password
    Number
    Any sequence of bytes

Output is called:

    Hash
    Hash value
    Digest
"""


# =====================================================================
#                         BASIC IDEA
# =====================================================================

"""
Example:

Input:

    "hello"

Hash output:

    2cf24dba5fb0a30e...

The same input produces
the same hash every time.
"""


# =====================================================================
#                      IMPORTANT PROPERTIES
# =====================================================================

"""
A good hash function should have:

1. Deterministic behavior

    Same input
        ->
    Same hash


2. Sensitivity

    Tiny input changes
        ->
    Very different hash


3. Fixed-size output

    Small or large input
        ->
    Same output length


4. Uniform distribution

    Hash values should spread evenly.


5. One-way behavior

    It should be extremely difficult
    to recover the original input
    from the hash.
"""


# =====================================================================
#                          SIMPLE EXAMPLE
# =====================================================================

"""
This is a simple educational hash function.

It is NOT secure.

It only demonstrates the idea.
"""


def simple_hash(text: str) -> int:
    value = 0

    for character in text:
        value = ((value << 5) ^ ord(character)) & 0xFFFFFFFF

    return value


print(simple_hash("hello"))
print(simple_hash("hello"))
print(simple_hash("Hello"))


"""
"hello" and "hello"
produce the same result.

"hello" and "Hello"
produce different results.
"""


# =====================================================================
#                          ord()
# =====================================================================

"""
ord() converts a character
into its Unicode numeric value.
"""

print(ord("A"))

# Result:
# 65


print(ord("a"))

# Result:
# 97


# =====================================================================
#                    BITWISE OPERATIONS
# =====================================================================

"""
Simple hash functions often use
bitwise operations.

Common operators:

    <<      Left shift

    ^       XOR

    &       AND
"""


number = 5

print(number << 1)


"""
5 in binary:

    0101

Shift left:

    1010

Result:

    10
"""


# =====================================================================
#                              XOR
# =====================================================================

"""
XOR compares bits.

Rules:

    0 XOR 0 = 0
    0 XOR 1 = 1
    1 XOR 0 = 1
    1 XOR 1 = 0
"""


print(5 ^ 3)


# =====================================================================
#                           AND MASKING
# =====================================================================

"""
A mask can limit a number
to a certain number of bits.
"""

value = 5000000000

limited = value & 0xFFFFFFFF

print(limited)


"""
0xFFFFFFFF keeps the result
within 32 bits.
"""


# =====================================================================
#                         HASH SENSITIVITY
# =====================================================================

"""
Character order matters.
"""

print(simple_hash("abc"))
print(simple_hash("acb"))


"""
Character case matters.
"""

print(simple_hash("postgres"))
print(simple_hash("Postgres"))


# =====================================================================
#                         HASH COLLISION
# =====================================================================

"""
A collision happens when two different inputs
produce the same hash.

Example:

Input A
    ->
Hash 12345

Input B
    ->
Hash 12345
"""


"""
Collisions are unavoidable in theory.

Why?

There are unlimited possible inputs,
but only a limited number of hash outputs.
"""


# =====================================================================
#                      CRYPTOGRAPHIC HASHES
# =====================================================================

"""
Cryptographic hash functions are designed
to resist attacks.

Common examples:

    MD5
    SHA-1
    SHA-256
    SHA-3
"""


# =====================================================================
#                              MD5
# =====================================================================

import hashlib


text = "hello"

md5_hash = hashlib.md5(text.encode("utf-8")).hexdigest()

print(md5_hash)


"""
MD5 creates a 128-bit hash.

MD5 is no longer secure
for cryptographic purposes.

Do not use MD5 for:

    Passwords
    Digital signatures
    Security-sensitive verification
"""


"""
MD5 may still appear in:

    File checksums
    Duplicate detection
    Non-security integrity checks
"""


# =====================================================================
#                            SHA-256
# =====================================================================

sha256_hash = hashlib.sha256(
    text.encode("utf-8")
).hexdigest()

print(sha256_hash)


"""
SHA-256 creates a 256-bit hash.

It is part of the SHA-2 family.
"""


# =====================================================================
#                    SAME INPUT, SAME HASH
# =====================================================================

first = hashlib.sha256(
    "hello".encode("utf-8")
).hexdigest()

second = hashlib.sha256(
    "hello".encode("utf-8")
).hexdigest()

print(first == second)

# Result:
# True


# =====================================================================
#                    SMALL CHANGE, LARGE DIFFERENCE
# =====================================================================

first = hashlib.sha256(
    "hello".encode("utf-8")
).hexdigest()

second = hashlib.sha256(
    "Hello".encode("utf-8")
).hexdigest()

print(first)
print(second)


"""
Only one letter changed,
but the hashes are completely different.

This behavior is called
the avalanche effect.
"""


# =====================================================================
#                         FILE CHECKSUM
# =====================================================================

"""
Hashes can verify whether a file changed.

If two files have different hashes,
their contents are different.
"""


def file_sha256(path: str) -> str:
    hasher = hashlib.sha256()

    with open(path, "rb") as file:
        while chunk := file.read(8192):
            hasher.update(chunk)

    return hasher.hexdigest()


# Example:
#
# print(file_sha256("document.pdf"))


# =====================================================================
#                        DATA INTEGRITY
# =====================================================================

"""
Suppose a file is downloaded.

The publisher provides:

    Expected SHA-256 hash

You calculate:

    Actual SHA-256 hash

If both match,
the file probably arrived unchanged.
"""


# =====================================================================
#                      PYTHON DICTIONARIES
# =====================================================================

"""
Python dictionaries use hashing internally.

Example:
"""

student = {
    "name": "Alice",
    "age": 20
}

print(student["name"])


"""
Python hashes the key:

    "name"

Then it uses the hash
to quickly locate the value.
"""


# =====================================================================
#                         PYTHON hash()
# =====================================================================

print(hash("hello"))


"""
Python's built-in hash() is useful
for internal data structures.

Do not use hash() for:

    Passwords
    File checksums
    Permanent stored hashes
"""


"""
Python may change hash() results
between program runs.

Use hashlib for stable hashes.
"""


# =====================================================================
#                     DATABASE HASH INDEXES
# =====================================================================

"""
Databases can use hash-based structures
for fast equality lookups.

Example search:

    WHERE email = 'alice@example.com'
"""


"""
Hash indexes are mainly useful for:

    Exact equality

        =


They are not suitable for:

    Range queries

        >
        <
        BETWEEN

    Sorting

        ORDER BY

    Prefix matching

        LIKE 'abc%'
"""


# =====================================================================
#                  B-TREE vs HASH INDEX
# =====================================================================

"""
B-tree index:

    Exact lookup
    Range lookup
    Sorting
    Prefix lookup


Hash index:

    Exact equality lookup
"""


"""
In PostgreSQL, B-tree is the default
and is usually the more flexible choice.
"""


# =====================================================================
#                    PASSWORD HASHING WARNING
# =====================================================================

"""
Never store plain-text passwords.
"""


password = "secret123"


"""
Also do not use plain SHA-256 directly
for password storage.

This is not enough:

    sha256(password)
"""


"""
Password hashing should use
special slow algorithms such as:

    Argon2
    bcrypt
    scrypt
    PBKDF2
"""


# =====================================================================
#                              SALT
# =====================================================================

"""
A salt is random data added
before hashing a password.

It prevents identical passwords
from producing identical stored hashes.
"""


"""
Without salt:

    password123
        ->
    same hash for every user


With salt:

    password123 + random salt
        ->
    different hash for each user
"""


# =====================================================================
#                       RAINBOW TABLES
# =====================================================================

"""
A rainbow table is a large collection
of precomputed password hashes.

Attackers compare stolen hashes
against known hash values.

Salts make these attacks
far less effective.
"""


# =====================================================================
#                   HASHING IS NOT ENCRYPTION
# =====================================================================

"""
Hashing:

    One-way

    Original data should not be recoverable.


Encryption:

    Reversible with a key.

    Original data can be decrypted.
"""


"""
Hashing:

    password
        ->
    digest


Encryption:

    message
        ->
    encrypted data
        ->
    original message
"""


# =====================================================================
#                    HASHING IS NOT COMPRESSION
# =====================================================================

"""
Compression preserves all original data
and can be reversed.

Hashing produces a fixed-size digest
and cannot restore the original input.
"""


# =====================================================================
#                       COMMON APPLICATIONS
# =====================================================================

"""
Hashes are used for:

    File integrity checks

    Password storage

    Digital signatures

    Python dictionaries

    Database indexes

    Duplicate detection

    Caching

    Version control systems

    Data partitioning
"""


# =====================================================================
#                        PRACTICAL RULES
# =====================================================================

"""
1. Same input gives the same hash.

2. Small input changes should produce
   very different hashes.

3. Collisions are possible.

4. MD5 is not cryptographically secure.

5. SHA-256 is suitable for many
   integrity-checking purposes.

6. Do not use normal SHA-256 alone
   for password storage.

7. Use Argon2, bcrypt, scrypt,
   or PBKDF2 for passwords.

8. Hashing is not encryption.

9. Python dictionaries use hashes internally.

10. Database hash indexes mainly support
    exact equality searches.
"""


# =====================================================================
#                              SUMMARY
# =====================================================================

"""
Hash function:

    Input of any size
        ->
    Fixed-size output


Important properties:

    Deterministic
    Sensitive
    Uniform
    One-way


Collision:

    Different inputs produce
    the same hash.


MD5:

    Old and cryptographically broken.


SHA-256:

    Modern cryptographic hash
    commonly used for integrity checks.


Passwords:

    Use password-specific hashing algorithms,
    not plain MD5 or SHA-256.


Core idea:

A hash is a compact fingerprint of data.

It helps systems compare, locate,
and verify data efficiently.
"""