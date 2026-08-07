# Improving Inverted Indexes for Natural Language Search

A basic inverted index maps:

```text
Word → Documents containing that word
```

But natural language is messy.

Words may differ by:

* uppercase and lowercase
* singular and plural forms
* common filler words
* language-specific grammar

To improve search quality, PostgreSQL uses techniques such as:

```text
Case normalization
Stop-word removal
Stemming
Language-specific processing
```

---

## 1. Case Normalization

Search should usually treat these words as equal:

```text
SQL
Sql
sql
```

So text is converted to lowercase before indexing.

Example:

```sql
SELECT LOWER('PostgreSQL Is Powerful');
```

Result:

```text
postgresql is powerful
```

Without normalization, the index might store separate entries:

```text
SQL → Document 1
sql → Document 2
Sql → Document 3
```

After normalization:

```text
sql → Document 1, Document 2, Document 3
```

This makes the index smaller and search results more consistent.

---

## 2. Stop Words

Stop words are very common words that usually contribute little search meaning.

Examples:

```text
the
and
is
but
who
of
a
```

Suppose a document contains:

```text
PostgreSQL is a powerful database
```

A cleaned index might store only:

```text
postgresql
powerful
database
```

Words such as `is` and `a` are ignored.

This reduces:

* index size
* unnecessary matches
* processing work
* noisy search results

---

## 3. Manual Stop-Word Table

A simple manual stop-word table might look like:

```sql
CREATE TABLE stop_words (
    word TEXT PRIMARY KEY
);
```

Example data:

```sql
INSERT INTO stop_words VALUES
('the'),
('and'),
('is'),
('a'),
('but');
```

After splitting document text into words, we can exclude stop words:

```sql
SELECT word
FROM extracted_words
WHERE word NOT IN (
    SELECT word
    FROM stop_words
);
```

In real systems, PostgreSQL already provides language-specific stop-word lists.

---

## 4. Stemming

Stemming converts related word forms into a common root.

For example:

```text
car
cars
```

may become:

```text
car
```

Another example:

```text
connect
connected
connecting
connection
```

may be reduced to a similar searchable form.

This normalized form is often called a:

```text
Lexeme
```

The purpose is not perfect grammar.

The purpose is to make related words searchable through the same index entry.

---

## 5. Why Stemming Helps

Without stemming:

```text
car        → Document 1
cars       → Document 2
```

A search for `car` may miss the document containing `cars`.

With stemming:

```text
car → Document 1, Document 2
```

This improves recall and reduces duplicate index entries.

---

## 6. Apply the Same Rules to Queries

The same processing used when building the index must also be used when searching it.

During indexing:

```text
Original text
→ lowercase
→ split into words
→ remove stop words
→ stem words
→ store lexemes
```

During searching:

```text
User query
→ lowercase
→ remove stop words
→ stem words
→ search lexemes
```

Otherwise, the query and index may not match.

---

## 7. Language-Specific Processing

Stop words and stemming rules depend on the language.

For example, English and Spanish have different:

* stop words
* plural rules
* word endings
* grammatical structures

Therefore, PostgreSQL needs to know the language configuration.

Example:

```sql
SELECT to_tsvector(
    'english',
    'Cars are connecting people'
);
```

PostgreSQL processes the text using English rules.

A different configuration can be used for another language:

```sql
SELECT to_tsvector(
    'spanish',
    'Los coches conectan personas'
);
```

---

## 8. PostgreSQL Full-Text Search Example

```sql
SELECT to_tsvector(
    'english',
    'The cars are connecting people'
);
```

The output may remove stop words and normalize words into lexemes.

Conceptually:

```text
car
connect
peopl
```

Notice that:

* `the` and `are` were removed
* `cars` became a normalized form
* `connecting` became a normalized form
* words were converted into searchable lexemes

---

## 9. Different Languages May Need Different Indexes

If a table contains documents in multiple languages, one English index may not work correctly for every row.

English stemming rules should not be applied blindly to:

* Spanish
* Bengali
* French
* German

A multilingual system may need:

```text
Separate indexes by language
```

or a language column that determines how each document is processed.

Example:

```text
English document → English configuration
Spanish document → Spanish configuration
```

This improves search accuracy.

---

# Final Mental Model

```text
Raw Text
   ↓
Lowercase
   ↓
Remove stop words
   ↓
Stem words
   ↓
Store lexemes
   ↓
Efficient natural-language search
```

---

# Key Takeaways

* Case normalization treats `SQL` and `sql` as the same word.
* Stop words are excluded because they add little search meaning.
* Stemming maps related word forms to a common lexeme.
* Query text must use the same processing rules as indexed text.
* Stop words and stemming depend on the selected language.
* PostgreSQL provides built-in language configurations for full-text search.
