# PostgreSQL Inverted Indexes

An **inverted index** is mainly used for searching inside text, such as blog posts, articles, or documents.

Instead of storing:

```text
Document → Words
```

it stores:

```text
Word → Documents containing that word
```

---

## 1. Basic Idea

Suppose we have three documents:

```text
Document 1: PostgreSQL is powerful
Document 2: PostgreSQL supports indexes
Document 3: Indexes improve search
```

A normal representation is:

```text
Document 1 → PostgreSQL, powerful
Document 2 → PostgreSQL, supports, indexes
Document 3 → indexes, improve, search
```

An inverted index flips this relationship:

```text
PostgreSQL → Document 1, Document 2
indexes    → Document 2, Document 3
search     → Document 3
```

Now, when someone searches for `PostgreSQL`, the database already knows which documents contain it.

It does not need to scan every document.

---

## 2. Why It Is Called Inverted

The original direction is:

```text
Document → Words
```

The index reverses it:

```text
Word → Documents
```

That reversal is why it is called an **inverted index**.

This concept existed long before Google. Modern search engines simply built much more advanced ranking and indexing systems on top of it.

---

## 3. `string_to_array()`

PostgreSQL provides:

```sql
string_to_array()
```

It splits text into an array using a delimiter.

Example:

```sql
SELECT string_to_array(
    'postgresql is powerful',
    ' '
);
```

Result:

```text
{postgresql,is,powerful}
```

This is similar to Python:

```python
"postgresql is powerful".split(" ")
```

---

## 4. `unnest()`

The `unnest()` function converts an array into separate rows.

Example:

```sql
SELECT unnest(
    ARRAY['postgresql', 'is', 'powerful']
);
```

Result:

```text
postgresql
is
powerful
```

So `unnest()` converts horizontal array values into vertical rows.

---

## 5. Combining Both Functions

You can split text and turn every word into a row:

```sql
SELECT unnest(
    string_to_array(
        'postgresql supports indexes',
        ' '
    )
);
```

Result:

```text
postgresql
supports
indexes
```

This is the basic step required to manually build an inverted index.

---

## 6. Manual Inverted Index Example

Suppose we have:

```sql
CREATE TABLE documents (
    id INTEGER PRIMARY KEY,
    content TEXT
);
```

Example data:

```sql
INSERT INTO documents VALUES
(1, 'postgresql is powerful'),
(2, 'postgresql supports indexes'),
(3, 'indexes improve search');
```

We can extract every word from every document:

```sql
SELECT
    id AS document_id,
    unnest(string_to_array(content, ' ')) AS keyword
FROM documents;
```

Result:

```text
document_id | keyword
------------+------------
1           | postgresql
1           | is
1           | powerful
2           | postgresql
2           | supports
2           | indexes
3           | indexes
3           | improve
3           | search
```

Now we have the basic mapping:

```text
Keyword → Document ID
```

---

## 7. Searching the Manual Index

You could store these results in another table:

```sql
CREATE TABLE document_keywords (
    keyword TEXT,
    document_id INTEGER
);
```

Then searching becomes:

```sql
SELECT document_id
FROM document_keywords
WHERE keyword = 'postgresql';
```

Result:

```text
1
2
```

This tells us that documents `1` and `2` contain the word `postgresql`.

---

## 8. Manual vs Built-In Full-Text Search

The manual approach is useful for understanding how inverted indexes work.

However, real text search requires more features:

* case normalization
* punctuation removal
* stop-word removal
* stemming
* ranking
* language handling

PostgreSQL already provides these through:

```text
tsvector
tsquery
GIN indexes
```

So in production, you usually use PostgreSQL full-text search rather than manually splitting words.

---

# Final Mental Model

```text
string_to_array()
Text → Array of words

unnest()
Array → Separate rows

Inverted index
Word → Matching document IDs
```

---

# Key Takeaways

* An inverted index maps words to documents.
* It is commonly used for text search.
* `string_to_array()` splits text into an array.
* `unnest()` expands the array into rows.
* These functions can be used to manually understand inverted-index construction.
* PostgreSQL’s built-in full-text search is better for real applications.
