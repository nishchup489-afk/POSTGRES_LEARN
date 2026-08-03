```python
# =====================================================================
#              CHARACTER ENCODING IN PYTHON 3
# =====================================================================

"""
Computers ultimately store data as bytes.

Python 3 separates:

    str
        Human-readable Unicode text

    bytes
        Raw binary data

Most modern programs use:

    Unicode strings inside Python

    UTF-8 bytes when saving or transmitting data
"""
```

```python
# =====================================================================
#                       STRINGS IN PYTHON 3
# =====================================================================

"""
Python 3 strings use Unicode.

This allows strings to contain characters
from many languages and symbol systems.
"""

message = "Hello"
bangla = "বাংলা"
arabic = "مرحبا"
japanese = "こんにちは"
emoji = "🙂"

print(message)
print(bangla)
print(emoji)
```

```python
# =====================================================================
#                          STR vs BYTES
# =====================================================================

"""
str represents text.

bytes represents encoded binary data.
"""

text = "Hello"

print(type(text))

# Result:
# <class 'str'>
```

```python
data = b"Hello"

print(type(data))

# Result:
# <class 'bytes'>
```

```python
# These may look similar,
# but they are different types.

text = "Hello"      # str
data = b"Hello"     # bytes
```

```python
# =====================================================================
#                             ENCODING
# =====================================================================

"""
Encoding converts:

    str -> bytes

UTF-8 is the normal modern encoding.
"""

text = "Hello 🙂"

encoded_data = text.encode("utf-8")

print(encoded_data)
print(type(encoded_data))
```

Example result:

```text
b'Hello \xf0\x9f\x99\x82'
<class 'bytes'>
```

```python
# The emoji is converted into multiple UTF-8 bytes.
```

```python
# =====================================================================
#                             DECODING
# =====================================================================

"""
Decoding converts:

    bytes -> str
"""

encoded_data = b"Hello"

decoded_text = encoded_data.decode("utf-8")

print(decoded_text)
print(type(decoded_text))
```

Result:

```text
Hello
<class 'str'>
```

```python
# =====================================================================
#                    ENCODE AND DECODE FLOW
# =====================================================================

"""
Python string

    "Hello 🙂"

        ↓ encode("utf-8")

UTF-8 bytes

        ↓ decode("utf-8")

Python string
"""

text = "Hello 🙂"

encoded = text.encode("utf-8")
decoded = encoded.decode("utf-8")

print(encoded)
print(decoded)
```

```python
# =====================================================================
#                     UNICODE vs UTF-8
# =====================================================================

"""
Unicode defines characters and code points.

UTF-8 defines how Unicode characters
are converted into bytes.

Think:

Unicode
    What character is this?

UTF-8
    How should this character be stored?
"""
```

```python
# =====================================================================
#                    CHARACTER AND BYTE LENGTH
# =====================================================================

"""
len() on a string counts characters.

len() on encoded bytes counts bytes.
"""

text = "A"

print(len(text))
print(len(text.encode("utf-8")))

# Result:
# 1 character
# 1 byte
```

```python
text = "🙂"

print(len(text))
print(len(text.encode("utf-8")))

# Result:
# 1 character
# 4 bytes
```

```python
text = "বাংলা"

print(len(text))
print(len(text.encode("utf-8")))

# Character count and byte count
# are not necessarily equal.
```

```python
# =====================================================================
#                       READING TEXT FILES
# =====================================================================

"""
When reading a text file,
Python decodes bytes into Unicode strings.
"""

with open("message.txt", "r", encoding="utf-8") as file:
    content = file.read()

print(content)
print(type(content))
```

```python
# Always specify encoding explicitly
# when practical.

with open("message.txt", "r", encoding="utf-8") as file:
    content = file.read()
```

```python
# =====================================================================
#                       WRITING TEXT FILES
# =====================================================================

"""
When writing text,
Python encodes the string into bytes.
"""

message = "Hello বাংলা 🙂"

with open("message.txt", "w", encoding="utf-8") as file:
    file.write(message)
```

```python
# =====================================================================
#                      READING BINARY FILES
# =====================================================================

"""
Binary mode returns bytes directly.

Use:

    rb
    wb
"""

with open("image.png", "rb") as file:
    data = file.read()

print(type(data))

# Result:
# <class 'bytes'>
```

```python
# Binary files should not usually be decoded as text.

with open("image.png", "rb") as file:
    data = file.read()
```

```python
# =====================================================================
#                    LEGACY FILE ENCODINGS
# =====================================================================

"""
Not every old file uses UTF-8.

Common legacy encodings include:

    latin-1
    cp1252
"""

with open("old_file.txt", "r", encoding="latin-1") as file:
    content = file.read()
```

```python
with open("windows_file.txt", "r", encoding="cp1252") as file:
    content = file.read()
```

```python
# The encoding must match the encoding
# originally used to save the file.
```

```python
# =====================================================================
#                         DECODING ERRORS
# =====================================================================

"""
Using the wrong encoding may raise:

    UnicodeDecodeError
"""

data = b"\xff"

# This may fail because the bytes
# are not valid UTF-8.

# text = data.decode("utf-8")
```

```python
# Decode using the correct encoding:

text = data.decode("latin-1")

print(text)
```

```python
# =====================================================================
#                    ERROR HANDLING OPTIONS
# =====================================================================

"""
Python provides error-handling strategies.

Use carefully because they may hide bad data.
"""

data = b"hello\xffworld"

text = data.decode("utf-8", errors="ignore")

print(text)
```

```python
# errors="ignore"
# removes invalid bytes.
```

```python
text = data.decode("utf-8", errors="replace")

print(text)
```

```python
# errors="replace"
# inserts a replacement character.
```

```python
# Prefer fixing the encoding problem
# instead of silently ignoring it.
```

```python
# =====================================================================
#                         NETWORK DATA
# =====================================================================

"""
Networks transmit bytes.

When using low-level sockets:

    Sending:
        encode text into bytes

    Receiving:
        decode bytes into text
"""

message = "Hello server"

network_data = message.encode("utf-8")
```

```python
received_data = b"Hello client"

message = received_data.decode("utf-8")

print(message)
```

```python
# Many high-level libraries automatically
# handle encoding and decoding.

# Low-level socket code often requires
# explicit encode() and decode().
```

```python
# =====================================================================
#                          HTTP EXAMPLE
# =====================================================================

"""
Libraries such as requests often decode
HTTP response data automatically.
"""

# response.text
#     Usually returns decoded str

# response.content
#     Returns raw bytes
```

```python
# Conceptual example:

response_text = "Decoded Unicode text"   # similar to response.text
response_bytes = b"Raw response bytes"   # similar to response.content
```

```python
# =====================================================================
#                     DATABASE CONNECTIONS
# =====================================================================

"""
Database connectors usually convert automatically:

    PostgreSQL text
        ↔
    Python str
"""

name = "বাংলা"

# Conceptual example:
#
# cursor.execute(
#     "INSERT INTO users (name) VALUES (%s)",
#     (name,)
# )
```

```python
"""
Normally, you do not manually call encode()
before inserting text into PostgreSQL.

The database driver handles conversion
between Python Unicode strings
and the database encoding.
"""
```

```python
# =====================================================================
#                         PYTHON 2 vs 3
# =====================================================================

"""
Python 2 had confusing separation between:

    str
        Usually raw bytes

    unicode
        Unicode text

Python 3 simplified this:

    str
        Unicode text

    bytes
        Raw bytes
"""
```

```python
# Python 3 model:

text = "Hello"      # Unicode str
data = b"Hello"     # bytes
```

```python
# =====================================================================
#                        COMMON MISTAKE
# =====================================================================

"""
You cannot directly combine str and bytes.
"""

text = "Hello"
data = b" World"

# This raises TypeError:
#
# result = text + data
```

```python
# Fix by decoding bytes:

result = text + data.decode("utf-8")

print(result)
```

```python
# Or encode the string:

result = text.encode("utf-8") + data

print(result)
```

```python
# =====================================================================
#                     PRACTICAL BEST PRACTICES
# =====================================================================

"""
1. Use Python 3.

2. Use str for normal application text.

3. Use bytes for files, sockets,
   images, and binary protocols.

4. Use UTF-8 for modern text data.

5. Specify encoding when opening text files.

6. Decode bytes when receiving text data.

7. Encode strings when sending or storing bytes.

8. Do not assume one character equals one byte.

9. Let database drivers handle normal text conversion.

10. Do not hide encoding errors unless necessary.
"""
```

```python
# =====================================================================
#                              SUMMARY
# =====================================================================

"""
str

    Unicode text inside Python.


bytes

    Raw binary data.


encode()

    str -> bytes


decode()

    bytes -> str


UTF-8

    Standard modern encoding
    for Unicode text.


Files and networks

    Usually transfer bytes.


Python application code

    Usually works with str.


Core idea:

Keep text as Unicode strings inside Python.

Encode it when writing or transmitting.

Decode it when reading or receiving.
"""
```

The main rule to burn into memory is:

```text
str.encode()    → bytes
bytes.decode()  → str
```
