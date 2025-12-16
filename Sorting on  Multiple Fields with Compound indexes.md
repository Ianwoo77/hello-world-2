# Sorting on  Multiple Fields with Compound indexes

To efficiency sort MongoDB query results on multiple fields, you should use a compound index -- Key principles of compound index sorting -- 

- Order matters -- Can only sort using the keys in the index if the *sort keys are the same order* as they appear in the index definition - this is based on the concept of index prefixes.
- Fore, `{a:1, b:1}`suports **not** by `{b:1, a:1}`.

#### Example -- sorting Movies -- 

If U want to sort the `movies`collection first by `runtime`and then by `year`-- 

```js
db.movies.createIndex({runtime:1, year:1})
// This query sorts by `runtime` ascending, and then by year ascending 1
db.movies.find().sort({runtime:1, year:1})

// Combine Filter and Sort the same index can optimize a query that filters and sorts, provided the sort fields are a prefix of the index -- 
db.movies.find({runtime: {$gt:40}}).sort({runtime:1, year:1})
```

The index `{runtime:1, year:1}`allows Mdb to efficiently filter documents where `runtime`is greater than 40 and then sort.

##### Sorting Theaters on Nested fields

To sort by `theaterId`-- then by a nested field `locaion.address.city`-- and finally by `location.address.zipcode`.

```js
db.theaters.createIndex({ theaterId: 1, "location.address.city": 1, "location.address.zipcode": 1 })
// then execute like:
db.theaters.find().sort({ theaterId: 1, "location.address.city": 1, "location.address.zipcode": 1 })
```

To maximize query performance, ensure that the order of fields in your `.sort()`operations matches the order of the fields in your compound indexes.

##### Introducing covered queries -- 

A *covered* query in Mdb is one in which all the fields used in the query and the fields returned by the query are included in an index -- this allows Mdb to retreive the results *directly from the index wihtout scanning the documents in the collection* -- leading to more efficient query performance.

If have` { year: 1, title: 1, "imdb.rating": 1 }`

This allows Mdb to use the index to retreive the results directly without scanning the document in the collection.

| Field Usage | Field Name    | Index Inclusion            |
| ----------- | ------------- | -------------------------- |
| Filter      | `year`        | Included                   |
| Filter      | `imdb.rating` | Included                   |
| Projection  | `title`       | Included                   |
| Projection  | `year`        | Included                   |
| Implicit    | `_id`         | Excluded ($\text{_id: 0}$) |

-- **Warning** -- forgetting to execute `_id`is a common failure in creating a covered query, also, multikey indexes cannot provide a covered query plan if any of the returned fields contains arrays.

#### When to not use an index

While indexes are crucial for optimizing dbs performance, there are specific scenairos where using an index can actually be *less efficient* than a simple collection scan.

##### The Index inefficiency Threshold

The primary factor determining whether an index helps or hurts performance is the *size of the resulting database subset* compared to the entire collection.

- Small data subsets -- when a query returns a small portion of the collection, and index is beneficial.
- Large data Subsets -- when a query returns a large portion of the collection, using an index can become inefficient and slow.

##### Why Indexes can slow down large queries -- 

An index query requires two lookups for every document returned -- 

1. Index Lookup -- Finding the entry in the index tree.
2. Document lookup -- Using the index pointer to fetch the actual document from the collection data file.

Typically, an index speeds queries if they return less then 30% of the collection, though this figure can range from 2% to 60%. Suppose that you hve a monitoring system that collects server logs, your application queries the system from all logs from a specific server to analyze activity from the past week -- 

```js
db.logs.find(
    { "server_id": "server123",
    "timestamp": { "$gt": weekAgo } }
)
```

- Initial launch -- index is fast -- when the system is new, the collection is small, the query returns a small fraction of the data quickly using the index -- 
- After weeks/months -- As the system runs for longer time, the collection grows very large, q query for *the last week’s data* now returns a very large percentage of the active data in the collection. Even though the `timestamp`index is uesd, the cumulative overhead of the two-step index-and-document lookup process for thousands or millions of documents makes the query run too slow.

## Write enough code to make it pass

A simple solution is just to add a lock to the counter -- 

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

What this means is any goroutine calling `Inc`will acquire the lock on the `Counter`if they are first.

If -- definite like:

```go
type Counter struct {
    sync.Mutex
    valute int
}
func (c *Counter) Inc() {
    c.Lock()
    defer c.Unlock()
    c.value++
}
```

This hs bad and wrong -- Exposing `Lock`and `Unlock`is at best confusing but at worst potentially very harmful to your softwoare if callers of your type start calling these methods.

#### Copying mutexes -- 

`go vet`command is a powerful and static analysis tool built into the std Go toolchain. Act as a *vetter* for code quality and correctness -- finds and reports -- 

- Likely bugs -- Issues that are not sync errors but could lead to runtime panics or incorrect behavior
- Suspicious constructs -- Abnormal, useless, or non-idiomatic code patterns
- Common mistakes - Errors related to using std packages or language features incorrectly.

```sh
go vet
# vet all packges in the current module/tree
go vet ./...

# vet a specific package path
go vet my_machine/project/

# list available checks
go tool vet help
```

If using `go vet`-- 

```tex
sync/v2/sync_test.go:16: call of assertCounter copies lock value: v1.Counter contains sync.Mutex
sync/v2/sync_test.go:39: assertCounter passes lock by value: v1.Counter contains sync.Mutex
```

When U copy a struct that contains a `sync.Mutex`-- the following occurs -- 

1. Two locks are created -- create a copy of the original lock
2. Lock Failure - Methods on the original struct lock the original lock. If U call methods on the copy, you lock the copied lock. If concurrent operations use the original struct and the copied struct separately, they will not wait for each other, leading to a race condition and completely defeating your concurency protection mechanism.

So, *A mutex must not be copied after use.* -- when we pass our `Counter`-- By value to `assertCounter`-- try and create a copy of the mutex. To sovle this should pass in a pointer to our `counter`instead, so change the signature of `assertCounter`-- just like:

```go
func assertCounter(t testing.TB, got *Counter, want int)
```

Our tests will no longer compile cuz we are trying to pass in a Counter rather than a *Counter* -- to solve this prefer to create a ctor which shows readers of your API that it would be better to not initialise the type yourself.

```go
func NewCounter() *Counter {
	return &Counter{}
}
```

### Context

Fore, a web server retreive an HTTP request, whcih kicks off a potentially long-running processs, if the user cancels the request before the data is received, the server needs a way to stop the ongoing background task immediately. The solution -- the `context`package provides a std mechanims to pass a cancellation signal, deadlines, and requeste-scoped values across API boundaries in Go program.

Core concepts -- 

- Cancellation Signal -- when `context`is canceled, all *goroutines* monitoring that the context are notified and should stop their work and return, cleaning up resources
- Request lifecycle -- The Go STD http package automatically creates a `context.Context`for every incoming `*http.Request`, this context is automatically canceled when the client disocnnected.

##### Code modification steps

The goal is to move the system from a *happy path to  robust one* by integrating `context`-- In this use the package `context`to help us manage long-running process. Going to start with a classic example of a web server that when kicks off a potentially long-running process to fetch some data for it to return in the response.

```go
type StubStore struct {
	response string
}

func (s *StubStore) Fetch() string {
	return s.response
}

func TestServer(t *testing.T) {
	data := "hello world"
	srv := Server(&StubStore{data})
	request := httptest.NewRequest(http.MethodGet, "/", nil)
    
    // return an httptest.ResonseRecorder
	response := httptest.NewRecorder()

	srv.ServeHTTP(response, request)
	if response.Body.String() != data {
		t.Errorf("got %q, want %q", response.Body.String(), data)
	}
}

type Store interface {
	Fetch() string
}

func Server(store Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, store.Fetch())
	}
}
```

Now that we have a happy path, want to make a more realistic scenario where the `Store`can’t finish a `Fetch`before the user cancels the request.

#### Write the test first

Our handler will need a way of telling the `Store`to cancel the work so update the interface -- 

```go
type Store interface {
    Fetch() string
    Cancel()
}

func Server(store Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		data := make(chan string, 1)
		go func() {
			data <- store.Fetch()
		}()

		select {
		case d := <-data:
			fmt.Fprint(w, d)
		case <-ctx.Done():
			store.Cancel()
		}
	}
}
```

For, need will need to adjust our spy so it takes some time to return data and a way of knowing it has been told to cancel -- also rename it to `SpyStore`as we are now observing the way it is called.