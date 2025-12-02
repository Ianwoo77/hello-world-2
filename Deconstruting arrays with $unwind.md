# Deconstruting arrays with `$unwind`

Creating separate output documents for each item in the array. The primary difference between the input and outpu documents is that the array field in the output documents contains a single item from the original array. This transformation simplifies complex documents, enhancing readability and understanding. Also, it enables U to perform further operations, such as grouping and sorting, on the resulting documents. `$unwind`does not output a document by default if the field value is `null`or `missing`or the array is empty.

Consider the document from the `customers`collection’s document like:

```json
{
  "_id": ObjectId("5ca4bbcea2dd94ee58162a76"),
  //...
  "accounts": [883283, 980867, 164836, 200611, 528224, 931483],
	//...
  }
// using 
db.customers.aggregate([
    {$match: {_id: ObjectId("...")}},
    {$unwind: "$accounts"},
    {
        $project: {
            _id, 0,
            username:1,
            account: 1
        }
    }
])
```

When this aggregation pipeline is executed, `$match`filters document to include only the one with `_id`equal `ObjectId`-- Consider another eample -- 

```js
db.getCollection('customers').aggregate(
  [
    {
      $group: {
        _id: '$accounts',
        count: { $sum: 1 }
      }
    },
    { $sort: { count: -1 } }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

The aggregation employs `$unwind`to deconstruture the `accounts`array, `$group`to group documents by account number, and `$sum`to `tally`occurrences. Optionally, the results can be sorted count in descending order.

#### Working with accumulators

*Accumulators* in MDB are operators used in aggregation pipelines, mainly within the `$group`and `$project`stages, to calculate data. They aggregate data by summing, averaging, or finding extremes, aiding in statistical analysis.

Fore, `$max`-- returns the highest value by comaring value and type.

```js
db.getCollection('customers').aggregate(
  [
    {
      $group: {
        _id: { username: '$username' },
        maxAccountNumber: { $max: '$accounts' }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

The pipeline starts by grouping the documents by `username`, within each group, it calculates the maximum account number using the `$max`accumulator-- finally, it returns the maximum account number for each unique username. And in the second -- focus on the `$avg`-- starts by `$group`again -- 

```js
db.getCollection('customers').aggregate(
  [
    {
      $group: {
        _id: null,
        averageNumberAccounts: {
          $avg: { $size: '$accounts' }
        }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

### Indexing for query performance

-  Mdb’s query planner and execution plan
- Creating, deleting, and viewing indexes
- index types
- Understanding the Equality, sort, Range rule of thumb
- Measuring mdb index use

Over years of work, Encountered numerous instances in which indexes were not used correctly or at all. This is suboptimal, ias in indexes allow efficient query performance and overll dbs optimization, give you best practices for us indexes -- rules of thumb, and methods for monitoring index use and optimization - 

Indexes are a type of special data structure that stores a small portion of the collection’s data in an easily traversable B-tree form. An index orders the values of specifiec fields, supporting efficient equality matches and range-based queries - MDB can also use the index to return stored results.

Without indexes, Mdb must scan every document in a collection to return query results. This process is very poor in terms of performance. A suitable index limits the number of documents that need to be scanned.

##### Keypoints of Mdb indexes

- Def and structure -- An index is a special data structure that stores part of the collection data and is organized an easily traversable B-tree format
- Functions (pros) -- 
  - Sorts the vlaues of specific fields
  - Supports efficient equality matches and range queries
  - Can be used to return stored results.
  - Crucial performance improvement -- Avoids full collection scans, significantly limiting the number of documents that need to be checked during a query.
- Cost(cons) -- 
  - Negatively affects write operations -- Namely, every insert, update, or delete operation needs to update the relevant indexes
  - Indexes can be costly in collections with a high wirte-to-read ratio.

#### Mdb query planner

Is a component that analyzes various ways to execute a query and selects the *most efficient execution plan*. To determine the most efficient execution strategy, the query planner temporarily tests all available options during what is known as a *trail phase* -- Is part of Mdb’s plan caching mechanism -- the dbs evaluates the efficiency of different execution strategies under autual query conditions. The plan that demonstrates the best balance of speed and resource use during this trail phase is selected and cached.

- Missing -- No cache entry exists, Mdb ealuates plans, selects a winner, and creates a new inactive cache entry with the plan’s work value.
- Inactive - This state is a placeholder. The query shape is reorganized, and the work requried is noted.
- Active - The entry is a winning plan currently used. If performance degrades or work increases, the entry may be reassessed and moved to the Inactive state.

## Dependency Injection

Assumed that you have read stucts section before as some understanding of interfaces will be needed for this.

- Don’t need a framework
- Doesn not overcomplicate your design
- facilitates testing
- Allows U to write great, general-purpose functions.

If have:

```go
func Greet(name string) {
    fmt.Printf("Hello, %s", name)
}
```

Function doesn’t need to care about or how the printing happens, so we should accept an interfact rather than concrete type. Can then change the imp to print to sth we control so that we test it - in `real life`U would inject in sth that writes to stdout.

```go
func TestGreet(t *testing.T) {
	buffer := bytes.Buffer{}
	Greet(&buffer, "Chris")
	got := buffer.String()
	want := "Hello, Chris"
	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}

func Greet(writer io.Writer, name string) {
	fmt.Fprintf(writer, "Hello, %s", name)
}
```

