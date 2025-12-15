# Understanding index builds

Focusing on how it manages concurrency and how the progress has been improved recent versions

#### Concurrency index Build summary -- 

1. Currency and Locking -- 
   - Optimized construction -- Index builds are designed to allow read and write operations to continue throughout most of the build time
   - Exclusive locking -- An exclusive lock is only secured on the collection at two critical points - the beginning and the end of the build process
   - Interleaving operations -- During the bulk of the construction, read and write operations are permitted to interleave wih the index build process.
2. Distribued Builds (Replica sets and sharded Clusters) -- 
   - Simultaneous execution -- Index builds run simultaneously on all data-bearing members in a replica set or sharded cluster
   - Primary Node Mandate -- The primary node will not mark the new index as ready for use until a mimimum required number of data-bearing, voting members have successfully completed the build.

#### Managing Indexes

- Optimization -- proper index handling is crucial for optimizing query performance and ensuring efficient data retreival
- Having too many indexes creates significant overhead
  - Consumes more disk space
  - slow down write operations
- Best practice -- only maintain indexes that are necessary and frequently used.

##### Discovering index usage with `$indexStats`-- 

Since indexes operate behind the scenes, MongoDB provides a mechanism to monitor their activity -- `$indexSttus`aggregation stage -- 

- Purpose -- the `$indexStats`stage retreive usage statistics for each index on a collection
- Basic syntax -- `db.movies.aggregate([{$indexStatus: {}}])`

##### Controlling index use with `hint()`-- 

Sometimes, U want to compel Mdb to use a specific index. To do so for a `db.collection.find()`, use the `hint()`method -- Attach the `hint()`method to the `find()`method to specify the desired index -- like:

```js
db.movies.find(
    { year: 1914, "imdb.rating": { $gte: 7 } }
).sort(
    { title: 1 }
).hint(
    { year: 1, type: 1, "imdb.rating": 1 })
```

The `hint()`method just tells Mdb to use the specific compound index to execute the query. The MDB query optimizer is generally very good at selecting the most efficient index for a given query and sort operation. However, there are two primary reasons why a developer for DBA might use `hint()`.

1. Testing and Bechmarking -- Goal -- To measure the performance of different indexes -- when testing, U might want to compare the execution time via `explain()`of a query using a compound index vs. single-field index.
2. Overriding a suboptimal choice -- In rare cases, the query optimizer might choose an index that is less efficient than another available index.

The js is telling MDB -- Despite the sort on `title`, ignore any other index you might choose and use the index composed of `year, type`, and `imdb.rating`to satisfy the query filters.

#### Using indexes with `$OR`queries -- 

This passage explains the specific rule MDB follows when using indexes with the `$or`logical operator and provides a solution to ensure index usage for optimized performance.

#### 1. The Core Rule

- Index Requirement: For MongoDB to use indexes to evaluate an entire `$or` expression, all individual clauses within the `$or` array must be supported by an index.
- Fallback: If even one clause in the `$or` expression lacks index support, MongoDB will p*erform a slow collection scan to evaluate the entire query*.

```js
db.movies.find({
  $or: [
    { year: 1914 },             // Clause 1
    { "imdb.rating": { $gt: 7 } } // Clause 2
  ]
})
```

Fore, assuming the only existing index is a compound index `{year: 1, type: 1, 'imdb.rating': 1}`. 

NOTE -- Mdb will likely perform a collection scan cuz the existing compound index does not effectively support the second clause. `imdb.rating`is not the leading field in the compound index, which limits its utility for range queries on that field when the leading fields are not used.

To ensure that both conditions in the `$or`cluse are supported by indexes and to optimize query performance, create an additional index for the `imdb.rating`condition.

##### Using indexes with the `$NE, $MIN`and `$NOT`operators

The performnce effect on the `$ne`, `$nin`, and `$not`operators depends on the index structure. Altough single-field indexes may offer limited benefits, the query planner can still use multifield index effectively.

| Operator                      | Primary Mechanism                                      | Index Efficiency                                             |
| ----------------------------- | ------------------------------------------------------ | ------------------------------------------------------------ |
| `$or `(Inclusion)             | Finds documents that match condition 1 OR condition 2. | Very High. Uses indexes to quickly find multiple small result sets and merge them. |
| `$ne, $nin, $not `(Exclusion) | Finds documents that do not match a condition.         | Low for single indexes. Often requires scanning almost the entire index or collection, unless combined with a highly selective leading field in a compound index. |

##### Ensuring that indexes fit in RAM

To follow best practices, ensuring that random-access indexes fit entirely in RAM for faster procesing. This prevents the system for reading the index from disk. The general guideline for achieving the fastest query performance is -- 

- Goal -- Ensure that all *random-access indexes* fits entirely within the system’s RAM
- Why -- When an index is completely in RAM. The operating system’s memory management handles the index data. Avoiding slow disk I/O entirely.
- Tool to Check -- `db.collection.totalIndexSize()`helper method is provided to easily calculate the total memory footprint of all indexes on a collection in bytes.

##### Sorting on multiple fields -- 

For compound indexes for sort optimization -- 

1. Ordering rule -- For compound index to support a sort op, the fields in the sort must be -- A prefix of the index -- namely, using all the keys or a subset starting from the first key
2. In the same order - as they appear in the index definition, for `{a: 1, b:1}`, sorty by `{a:1}`not `{b:1}`

##### Indexing for combined filter and sort -- 

Can also optimize queries that involve both filtering and sorting. Fore 

```js
db.movies.createIndex({runtim:1, year:1})
db.movies.find({ runtime: { $gt: 40 } }).sort({ runtime: 1, year: 1 })
```

1. Filter -- quickly locate documents where `runtime`is greater then 40
2. Sort -- Sort the resulting documents by `runtime`and then by `year`using the ordered index structure, avoiding a blocking in-memory sort operation.

To maximize performancec, developers must ensure that the order of fields in their sort operations matches the order in the compound index prefiexes to allow Mdb to use the index structure for sorting.

## Sync - go test

Write the test first -- we want our API to give us a method to increment the counter and retreive its value.

```go
func TestCounter(t *testing.T) {
	t.Run("incrementing the counter 3 times leaves it at 3", func(t *testing.T) {
		counter := Counter{}
		counter.Inc()
		counter.Inc()
		counter.Inc()

		assert
	})
}

func assertCounter(t testing.TB, got Counter, want int) {
	t.Helper()
	if got.Value() != want {
		t.Errorf("got %d, want %d", got.Value(), want)
	}
}
```

Write the minimal amount of code for the test to run and check the failing - 

```go
type Counter struct {
	value int
}

// Inc inc the count
func (c *Counter) Inc() {
	c.value++
}

func (c *Counter) Value() int {
	return c.value
}
```

Next steps -- That was easy enough but now have a requirement that it must be safe to use in a concurrent environment -- will need to write a failing test to exercise this.

```go
type Counter struct {
	mu    sync.Mutex
	value int
}

func NewCounter() *Counter {
	return &Counter{}
}

// Inc inc the count
func (c *Counter) Inc() {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.value++
}

func (c *Counter) Value() int {
	return c.value
}
```

