# MDB query Planner -- Index

The query planner in MDB is a component that analyzes various ways to execute a query and selects the most efficient execution plan. It uses indexes and other available data to mainimize response times and resource case. If no index is availabe for a given query, the query planner performs a *full collection scan*.

#### Viewing query plan cache info

To access the query plan details in the Shell for a specific query, use the `db.collection.explain()`or `cursor.explain()`. `db.collection.explain()`accepts the `verbosity`parameter -- sets the level of detail provided by the `explain`output. And the `verbosity`mode affects how `explain()`operates and dictates the extent of info returned.

`queryPlanner(default)`-- details about the chosen plan
`executionStats`-- Includes all data from `queryPlanner`plus statistics
`allPlansExecution`-- offers comprehensive info, all possible query plans and their execution statistics. fore:

```js
db.collection.find({...}).explain('executionStats');
```

For the results -- like:

```json
{
  "winningPlan": {
    "stage": "FETCH",  // fetching document
    "inputStage": {
      "stage": "IXSCAN", // scanning for index keys
      "indexName": "yourField_1",
      "keyPattern": {
        "yourField": 1
      },
      "indexBounds": {
        "yourField": [
          "[\"value\", \"value\"]"
        ]
      }
    }
  },
  "executionStats": {
    "nReturned": 1,
    "executionTimeMillis": 3,
    "totalKeysExamined": 1,
    "totalDocsExamined": 1
  }
}
```

Mdb uses two query engines to find and return results -- the classic query engine and the slot-based query engine. U can’t select it manually -- The *slot-based* engine usually offers better performance and lower CPU and memory use. If a query doesn’t meet the criteria for the slot-based engine, MDB uses the classic engine instead. Two common pipelines that use the slot-based execution engine are aggregations with the `$group`or `$lookup`stages.

##### Mdb plan cache Purges

The query plan cache is purged if a mongod process restart or shuts down. Also -- 

- Catalog operations such as dropping indexes or collections reset the plan cache.
- The least recently used replacement method removes the least accessed cache entry.

Also can -- 

- Clear the plan cache for the collection manually via the `PlanCache.clear()`
- Selectively clear specific entires in the plan cache using the `PlanCache.clearPlansByQuery()`.

#### Supported index types -- 

A dbs index is a specific type of data structure that enables quicker data retrieval, contributing to app efficiency. Typically, an index includes two components -- the search key and the data pointer -- the search key holds the value being searched, and the pointer indicates the location of the data within the dbs.

Fore, allowing the system to skip entire blocks of data that don’t meet the search criteria and examine only blocks that potentially contain relevant data.

##### Creating single field indexes

Fore, if app frequently execute queries on specific fields, establishing an index in these fields can enhance performance. Several types of indexes cater to different data types and query requirements -- This section examines the choices in detail.

Single-field indexes store and order data from a single field across each document in a collection. You can create a single-field index on any document field, such as top-level document fields, embedded documents, and fields within those embedded documents. When set up an index, define the field for the index and the direction of sorting for the index values.

When set up an index, define the field for the index and the direction of sorting for the indexed values. A sort order of `1`indicates ascending order, and `-1`for descending order. Like:

```js
db.movies.createIndex({'runtime': 1})
```

```js
db.movies.getIndexes()
[
  { v: 2, key: { _id: 1 }, name: '_id_' },
  { v: 2, key: { runtime: 1 }, name: 'runtime_1' }
] // the most user-created indexes in current versions will default to v: 2

// if execute-- 
db.movies.find({'runtime':100}).explain('executionStats');
/* 
winningPlan: {
      isCached: false,
      stage: 'FETCH',
      inputStage: {
        stage: 'IXSCAN',
        //....
*/
```

Can even create index in a field within an *embedded* document by using dot notation, to index the `wins`field inside the `awards`embeded document, using the following -- 

```js
db.movies.createIndex({'awards.wins': 1})
```

An index fully supports a query when it includes all the fields that the query needs to scan -- insted of scanning the entire collection, the query scans the index, by creating indexes that align with your queries -- U significantly enhance query performance. If the index does not include al the fields the query needs, the query scans the index and then accesses the collectionfor the remaining fields, which can still improve performances.

```go
func Greet(writer io.Writer, name string) {
	fmt.Fprintf(writer, "Hello, %s", name)
}

func MyGreetHandler(w http.ResponseWriter, r *http.Request) {
	Greet(w, "world")
}

func main() {
    Greet(os.Stdout, "Elodie")
}
```

##### More on `io.Writer`

What other places can we write data to using `io.Writer`, just how general purpose is our `Greet`functions .

### Mocking

Have been asked to write a program which counts down from 3, printing each number on a new line and when it reaches zero it will print `Go!`and exit.

```go
func TestCountdown(t *testing.T) {
	buffer := &bytes.Buffer{}
	Countdown(buffer)
	
	got := buffer.String()
	want := "3"
	
	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}

func Countdown(out io.Writer) {
	fmt.Fprintf(out, "3")
}
```

Know tht the `*bytes.Buffer`works, would be better to use a general purpose interface instead -- To complete matters, now wire up our function into a `main`so we have some working software to reassure ourselvels we are maing progress.

```go
func TestCountdown(t *testing.T) {
	buffer := &bytes.Buffer{}
	Countdown(buffer)

	got := buffer.String()
	want := `3
2
1
Go!`

	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}

// Write enough code to make it pass

```

