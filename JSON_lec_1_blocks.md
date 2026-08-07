# PostgreSQL Internal Storage: Rows, Pages, and Blocks

PostgreSQL does not store each row as a separate file or read rows individually from disk.

Instead, it organizes table data into **fixed-size blocks**, also called **pages**.

Understanding this internal structure helps explain:

* how PostgreSQL reads data
* how updates work
* why indexes improve performance
* why row size matters
* how disk and memory interact

---

## 1. PostgreSQL Stores Data in Blocks

By default, PostgreSQL divides table files into blocks of:

```text
8 KB
```

Each block can contain multiple rows.

For example, suppose a table contains small user records:

```text
id | name | email
```

Several of these rows may fit inside one 8 KB block.

Conceptually:

```text
Table File
│
├── Block 1
│   ├── Row 1
│   ├── Row 2
│   └── Row 3
│
├── Block 2
│   ├── Row 4
│   ├── Row 5
│   └── Row 6
│
└── Block 3
    └── More rows
```

PostgreSQL generally reads an entire block into memory, even when it only needs one row from that block.

---

## 2. Why PostgreSQL Uses Fixed-Size Blocks

Using fixed-size blocks makes storage management predictable.

PostgreSQL can easily:

* locate data on disk
* load data into memory
* cache frequently used pages
* manage free space
* organize indexes
* coordinate concurrent access

The database does not need to search through an unpredictable stream of raw bytes.

Instead, it works with standardized 8 KB units.

---

## 3. Internal Layout of a PostgreSQL Block

A PostgreSQL block contains several important sections.

A simplified layout looks like this:

```text
+-----------------------------+
| Page Header                 |
+-----------------------------+
| Item Pointer Array          |
| Item Pointer 1              |
| Item Pointer 2              |
| Item Pointer 3              |
+-----------------------------+
| Free Space                  |
+-----------------------------+
| Row Data / Tuples           |
| Tuple 3                     |
| Tuple 2                     |
| Tuple 1                     |
+-----------------------------+
```

The row data is stored near the end of the block.

The item pointers are stored near the beginning.

The unused area between them is called **free space**.

---

## 4. Item Pointers

PostgreSQL does not directly search through every byte in a block to find a row.

Instead, each block contains an array of **item pointers**.

Each item pointer tells PostgreSQL where a particular row starts inside the block.

For example:

```text
Item Pointer 1 → Row 1 location
Item Pointer 2 → Row 2 location
Item Pointer 3 → Row 3 location
```

This gives PostgreSQL fast access to rows inside a page.

A row can therefore be identified using:

```text
Block Number + Item Pointer Number
```

This physical row location is closely related to PostgreSQL’s internal `ctid` value.

For example:

```sql
SELECT ctid, *
FROM users;
```

A result might contain:

```text
ctid
-------
(0,1)
(0,2)
(1,1)
```

Here:

```text
(0,1)
```

means approximately:

```text
Block 0, Item 1
```

However, `ctid` should not be used as a permanent row identifier because it may change when the row is updated or moved.

---

## 5. Rows Have Variable Sizes

Although blocks have a fixed size, rows do not.

Consider this table:

```sql
CREATE TABLE users (
    id INTEGER,
    name VARCHAR(100),
    email VARCHAR(255)
);
```

One row might contain:

```text
1 | Sam | a@b.com
```

Another row might contain:

```text
2 | Christopher Anderson | christopher.anderson@example.com
```

The second row requires more storage.

Therefore, PostgreSQL must fit variable-length rows inside fixed-size blocks.

This is one reason PostgreSQL keeps free space inside pages.

---

## 6. What Happens During an Update?

Suppose a row currently contains:

```text
1 | Sam | a@b.com
```

Then it is updated:

```sql
UPDATE users
SET email = 'samuel.anderson@example.com'
WHERE id = 1;
```

The new row may require more space than the old row.

PostgreSQL usually does not overwrite the old row directly.

Because PostgreSQL uses **MVCC**, it generally creates a new version of the row.

Conceptually:

```text
Old Row Version
1 | Sam | a@b.com

New Row Version
1 | Sam | samuel.anderson@example.com
```

The old version may remain temporarily so that older transactions can still see it.

Later, PostgreSQL can clean up obsolete row versions using:

```text
VACUUM
```

---

## 7. MVCC and Row Versions

MVCC means:

```text
Multi-Version Concurrency Control
```

Instead of locking a row so every other transaction must wait, PostgreSQL may keep multiple versions of that row.

For example:

```text
Transaction A sees the old version.
Transaction B creates a new version.
```

This allows many reads and writes to happen concurrently.

However, it also means updates can create dead row versions, sometimes called:

```text
dead tuples
```

These dead tuples occupy space until PostgreSQL reclaims it.

---

## 8. Updates Inside the Same Block

If the block has enough free space, PostgreSQL may place the new row version in the same block.

This can be especially efficient when PostgreSQL performs a:

```text
HOT update
```

HOT means:

```text
Heap-Only Tuple
```

A HOT update may happen when:

* the updated columns are not indexed
* enough free space exists in the same page

This avoids creating unnecessary new index entries.

Example:

```sql
UPDATE users
SET last_login = NOW()
WHERE id = 10;
```

If `last_login` is not indexed and there is enough space, PostgreSQL may perform a HOT update.

This improves performance and reduces index bloat.

---

## 9. PostgreSQL Reads Entire Blocks

PostgreSQL does not usually ask the storage system:

```text
Give me exactly row 27.
```

Instead, it asks for the block containing that row.

The entire 8 KB block is loaded into memory.

Conceptually:

```text
Disk Block
    ↓
PostgreSQL Shared Buffers
    ↓
Requested Row
```

Once the block is in memory, PostgreSQL can inspect the item pointers and retrieve the required row.

If another row from the same block is needed later, PostgreSQL may already have the block cached.

This reduces additional disk access.

---

## 10. Shared Buffers

PostgreSQL keeps frequently used blocks in an area of memory called:

```text
shared_buffers
```

When PostgreSQL needs a block, it first checks whether that block is already in memory.

### Cache hit

```text
Block already in shared_buffers
→ Read from memory
→ Fast
```

### Cache miss

```text
Block not in shared_buffers
→ Read from disk
→ Place into memory
→ Slower
```

This is why good caching can dramatically improve database performance.

---

## 11. How Indexes Find Rows

An index stores search keys and references to table rows.

For example, an index on email might conceptually contain:

```text
a@b.com → Block 0, Item 1
john@example.com → Block 4, Item 3
sam@example.com → Block 8, Item 2
```

When PostgreSQL executes:

```sql
SELECT *
FROM users
WHERE email = 'sam@example.com';
```

It may:

1. search the index
2. find the row location
3. identify the correct table block
4. load that block into memory
5. retrieve the row using the item pointer

The index does not normally contain the entire table row.

It usually contains:

```text
Indexed Value + Row Location
```

---

## 12. Heap Storage

The main table data in PostgreSQL is called the:

```text
heap
```

The word heap here does not mean a heap data structure like a priority queue.

It means the table rows are not physically stored in sorted order.

Even if you insert rows in this order:

```text
1
2
3
4
5
```

updates and deletions may cause their physical locations to change.

Therefore, without an explicit `ORDER BY`, PostgreSQL does not guarantee row order.

Example:

```sql
SELECT *
FROM users
ORDER BY id;
```

The `ORDER BY` is required when a predictable order matters.

---

## 13. Why 8 KB?

The default PostgreSQL block size is a compromise.

A block must be large enough to hold several rows but small enough to avoid wasting memory and disk I/O.

### If blocks were extremely small

Problems could include:

* too many block reads
* more metadata overhead
* more fragmentation
* fewer rows per page
* larger indexes

### If blocks were extremely large

Problems could include:

* more memory consumed per cached page
* unnecessary data loaded for small queries
* increased I/O for random access
* fewer pages fitting in memory

The default 8 KB size provides a practical balance for many workloads.

---

## 14. SSDs and Hard Drives

Storage hardware also affects page-access performance.

### Spinning hard drives

Traditional hard drives contain mechanical parts.

Random reads are expensive because the disk head must physically move.

Therefore, sequential block access is much faster than random block access.

### SSDs

SSDs do not have a moving disk head.

Random access is much faster.

However, SSD access is still slower than RAM.

So caching, indexing, and efficient block access remain important.

An SSD improves performance, but it does not make poor queries magically efficient. Hardware cannot fully rescue bad database design. Brutal, but true.

---

## 15. Large Values and TOAST

A single row may contain values too large to fit comfortably inside one 8 KB block.

For example:

```sql
CREATE TABLE documents (
    id INTEGER,
    content TEXT
);
```

The `content` column might contain several megabytes of text.

PostgreSQL handles large values using:

```text
TOAST
```

TOAST stands for:

```text
The Oversized-Attribute Storage Technique
```

PostgreSQL may:

* compress the large value
* store it outside the main table row
* keep a pointer to the external value

Conceptually:

```text
Main Row
id | pointer_to_large_content
```

The large content is stored in a separate TOAST table.

---

## 16. Free Space Map

PostgreSQL maintains information about how much free space exists in table pages.

This structure is called the:

```text
Free Space Map
```

When PostgreSQL inserts or updates a row, it can use the free-space map to find a block with enough room.

Without it, PostgreSQL might need to inspect many pages manually.

The free-space map helps answer:

```text
Which block has enough space for this row?
```

---

## 17. Visibility Map

PostgreSQL also maintains a:

```text
Visibility Map
```

It records whether all rows in a page are visible to all active transactions.

This is useful for:

* vacuum operations
* index-only scans
* reducing unnecessary heap access

During an index-only scan, PostgreSQL may return data directly from the index.

However, it may still need to check the visibility map to confirm that the row version is visible.

---

## 18. Sequential Scan vs Index Scan

### Sequential scan

PostgreSQL reads many or all table blocks:

```text
Block 1
Block 2
Block 3
Block 4
...
```

Example:

```sql
SELECT *
FROM users;
```

This is often efficient when a large percentage of the table is needed.

### Index scan

PostgreSQL searches an index and visits specific blocks:

```text
Index Search
→ Block 50
→ Block 932
→ Block 1201
```

Example:

```sql
SELECT *
FROM users
WHERE id = 100;
```

This is usually efficient when only a small number of rows are needed.

An index is not automatically faster in every situation.

If PostgreSQL expects to read most of the table, a sequential scan may be cheaper than jumping between many random blocks.

---

## 19. Block-Level Performance

Since PostgreSQL works with blocks, query performance is strongly affected by the number of blocks read.

A query that retrieves one row but scans 100,000 blocks is inefficient.

A query that retrieves the same row by reading:

```text
2 index pages + 1 table page
```

is usually much faster.

You can inspect this using:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM users
WHERE email = 'sam@example.com';
```

The `BUFFERS` option shows information such as:

* shared buffer hits
* blocks read from disk
* blocks written
* temporary blocks used

This helps measure actual page-level activity.

---

## 20. Fillfactor

PostgreSQL allows you to control how full each block should be when inserting rows.

This setting is called:

```text
fillfactor
```

Example:

```sql
CREATE TABLE users (
    id INTEGER,
    name TEXT
)
WITH (fillfactor = 80);
```

A fillfactor of `80` means PostgreSQL attempts to fill pages to around 80%, leaving approximately 20% free space for future updates.

Lower fillfactor may help tables with frequent updates.

But it also causes the table to consume more disk space.

The trade-off is:

```text
More free space
→ Easier updates
→ Larger table
```

---

## 21. Important Correction About Rewriting Blocks

When a row changes, PostgreSQL modifies a page in memory and records the change in the Write-Ahead Log.

Eventually, the modified page is written back to disk.

PostgreSQL does not permanently shift every row in the entire table.

The changes are managed within individual pages.

Also, because of MVCC, PostgreSQL usually creates a new row version rather than simply rewriting the existing row in place.

---

# Final Mental Model

Think of a PostgreSQL table as a book.

```text
Table      = Book
Block      = Page
Row        = Paragraph
Item Array = Table of paragraph locations
Index      = Index at the back of the book
RAM Cache  = Pages currently open on your desk
Disk       = Book stored on the shelf
```

When PostgreSQL needs one row, it usually loads the whole page containing that row.

An index helps PostgreSQL determine which page it should open.

---

# Key Takeaways

* PostgreSQL stores table data in fixed-size blocks, usually 8 KB.
* Each block may contain multiple variable-sized rows.
* Item pointers locate rows inside each block.
* PostgreSQL reads entire blocks rather than individual rows.
* Frequently accessed blocks are cached in shared buffers.
* Indexes map search keys to physical row locations.
* Updates usually create new row versions because of MVCC.
* Dead row versions are cleaned by VACUUM.
* HOT updates can reduce index work.
* Large column values may be stored using TOAST.
* Block reads are a major factor in query performance.
* `EXPLAIN (ANALYZE, BUFFERS)` reveals block-level behavior.
