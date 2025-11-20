# Understanding the aggregation framework

Each stage performs a specific operation, and the output of one stage becomes the input for the next stage. Aggregation operations  handle multiple documents and return computed results -- can use them do the follows:

- Generate business reports - rollups, sums, and averages
- Full-text search and fuzzy search
- Conduct vector search in data sets
- Present up-to-date business dashborads
- Make sensitive data securely
- Joining data from diffenet collection on the server
- Perform data discovery and wrangling
- Conduct large-scale data analysis (Big data)
- Execute complex real-time queries
- Analyze graphs of REL between records
- Perform data transformaiton in extract, load, transform (ELT) processes
- Report data quality and cleansing
- Update materialized views with recent data changes
- Conduct real-time analystics for user insights.

Here is the comparison table aligining SQL terms, functions, and concepts with their corresponding MDB aggregation operations -- 

| **SQL Term, Function, or Concept** | **MongoDB Aggregation Operator** | **Core Functionality**                                       |
| ---------------------------------- | -------------------------------- | ------------------------------------------------------------ |
| `SELECT`                           | `$project, $set, $unset`         | Selects, creates, renames, or excludes fields to shape the structure of the output documents. |
| `WHERE`                            | `$match`                         | Filters the documents based on specified conditions, similar to the SQL `WHERE` clause. Often used early in the pipeline for efficiency. |
| `GROUP BY`                         | `$group`                         | Groups documents by one or more keys and applies aggregate functions (like sum or count) to each group. |
| `HAVING`                           | `match`                          | Used **after** the **$group** stage to filter the aggregated results, matching the function of SQL's `HAVING`. |
| `ORDER BY`                         | `$sort`                          | Sorts the documents in the pipeline.                         |
| `LIMIT`                            | `$limit`                         | Restricts the number of documents passing through the pipeline. |
| `OFFSET`                           | `$skip`                          | Skips a specified number of documents, typically used for pagination. |
| `SUM()`                            | `$sum`                           | Calculates the **sum** of numeric values.                    |
| `COUNT()`                          | **`$count, $sum, $sortByCount`** | **$count** is a simple count; **$sum** can be used for conditional counts; **$sortByCount** groups and counts quickly. |
| `JOIN`                             | **`$lookup`**                    | Performs a **Left Outer Join** to bring in documents from another collection and embed them in the output. |
| **SELECT INTO NEW TABLE**          | **`$out`**                       | Writes the results of the entire aggregation pipeline to a **new collection**. |
| **MERGE INTO TABLE**               | **`$merge`**                     | Writes the results of the pipeline into a specified **collection**, allowing for insert, merge, or replace operations. |
| **UNION ALL**                      | **``$unionWith`**                | Combines documents from the current collection with documents from another collection. |

#### Writing an aggregation pipeline -- 

In MDB, can use the `db.collection.aggregate()`method to execute aggregation pipelines -- the documents in the collection remain unchanged unless the pipeline specifically includes a `$merge`or `$out`stage. These stages are exceptions that can write the results back to the original collection or to a new collection. Fore:

```js
db.getCollection('routes').aggregate(
  [
    { $match: { airplane: 'CR2' } }, // filter document where the airpline is `CR2`
    {
      $group: { // group by source ariport
          // groups the filtered documents based on the source airport, calculating the 
          // total number of routes totalRoutes 
        _id: '$src_airport',
        totalRoutes: { $sum: 1 }  // count the number of routes from each distinct source airport
      }
    },
      
     // $sort stage arranges the grouped data based on the total number of routes
     // in descending order.
    { $sort: { totalRoutes: -1 } },
      
      // $limit stage restricts the number of documents passed to the subsequent
    { $limit: 5 }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

##### Viewing the aggregation pipeline stages -- 

The aggregation pipeline is composed of several *distinct stges* -- each responsible for a specific data processing task. Combined, these stages enable complex transformations and analyses. Certain stages in the pipeline are more frequently used due to hteir versatility and utility in wide ange of data processing tasks.

- `$group`-- Groups documents by a specified key and applies aggregte functions such as `sum, avg, min, max`and `count`.
- `$set, $unset, $project`-- Reshape each document by adding, removing, or modifying fields.
- `$sort`-- Orders documents by specified field(s) in ascending or descending order.
- `$lmit`-- Restricts the number of documents passed to the next stage
- `$skip`-- Skips a specified number of documents.
- `$unwind`-- Deconstructs an array field to output a document for each element of the array.
- `$loopup`-- Perfroms a left outer join with another collection to include related data.

Can combine and customize these stages to create powerful data transformations and aggregations tailored to specfic apps needs.

- Place `$match`early, position the `$match`stage at the beginning of the pipeline to filter out unncessary document early, reducing the workload for subsquent stages and improving performance.
- Prefer using `$set`and `$unset`, rather than using the `$project`for fields inclusion and exclustion, use `$set`and `$unset`. 

## Maps

Saw how to store values in order. Now, we will look at a way to store items by a `key`and look them up quickly. Maps allow you to store items in a manner similar to a dictionary.  Can think of the `key`as the word and the `value`as the definition. And what better way is there to learn about Maps than to build our own dictionary -- Assuming we already have some words with their definitions in the dictionary, if search for a word, should return the definition of it.

##### Write the test first -- 

```go
func TestSearch(t *testing.T) {
	dictionary := Dictionary{"test": "this is just a test"}
	got := dictionary.Search("test")
	want := "this is just a test"
	assertStrings(t, got, want)
}

func assertStrings(t *testing.T, got, want string) {
	t.Helper()
	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}
```

Declaring a Map is somewhat similar to an array, except, it starts wtih the `map`keyword and requires two types -- the first is the key type, which is written inside the `[]`, the second is the vlaue type.

```go
func Search(dictionary map[string]string, word string) string {
	return dictionary[word]
}
```

Refactor the test -- just like -- 

```go
func TestSearch(t *testing.T) {
	dictionary := map[string]string{"test": "this is just a test"}
	got := Search(dictionary, "test")
	want := "this is just a test"
	assertStrings(t, got, want)
}
```

##### Using a custom type -- 

Can improve our dictionary’s usage by creating a new type around map and making `Search`a method. In `_test`file, just like: 

```go
type Dictionary map[string]string
func (d Dictionary) Search(word string) string {
	return d[word]
}
```

Created a `Dictioanry`type which acts as a thin wrapper around `map`-- with the custom type defined, can create the `Search`method.

##### Write the test first -- 

```go
func TestSearch(t *testing.T) {
	dictionary := Dictionary{"test": "this is just a test"}

	t.Run("known word", func(t *testing.T) {
		got, _ := dictionary.Search("test")
		want := "this is just a test"

		assertStrings(t, got, want)
	})

	t.Run("unknown word", func(t *testing.T) {
		_, got := dictionary.Search("unknown")

		assertError(t, got, ErrNotFound)
	})
}

func assertStrings(t testing.TB, got, want string) {
	t.Helper()

	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}

func assertError(t testing.TB, got, want error) {
	t.Helper()

	if got != want {
		t.Errorf("got error %q want %q", got, want)
	}
}
```

The way to handle this section in Go is to return.