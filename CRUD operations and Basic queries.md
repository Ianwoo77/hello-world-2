# CRUD operations and Basic queries

When several documents meet the filter’s criteria, only the first matching document is modified by the `updateOne()`method -- using the `find()`like:

```js
db.books.find({'isbn': "101"});
// to delete document -- multiple approaches
db.books.deleteOne({'isbn': '101'})
```

### Scripting for Mongosh

Adminstering the dbs using built-in commands is helpful -- it is not the main reason for using the shell. The true power of mongosh comes from the fact that it provides a Js REPL environment -- this means that you can perform complex administrative tasks that requires a set of commands to execute as one. Just like:

```js
let title='MongoDB in nutshell';
print(title);
db.books.insertOne({title:title, isbn: 102});

db.books.find({title:title, isbn: 102})
```

Since it is just a JS REPL environment, you can use it for functions and scripts that generate complex results from your dbs -- fore:

```js
queryBookByIsbn = function(isbn) {
    return db.books.find({isbn: isbn});
}
```

Can use the `mongosh`to write and test these scripts like: `monghsh <script_name>.js`

Scripting for mongosh vs direct use. Batch inserts using mongosh -- If want to insert many documents programmatically using the shell, the simplest imp -- just like:

```js
authorMongoDBFactory= function() {
    for(let loop=0; loop<1000; loop++) {
        db.books.insertOne({"name": "..."+loop})
    }
}
```

#### Batch operations using mongosh

In thecse of inserts, the order of operations is negligible, however, note that the `bulk`command can be used with many more operations that just insert -- in the following -- have single book with `isbn: 01`..fore: In a single `bulk`operations, executing the following series of actions will involve adding one book to the inventory and then preeding to purchase 100 books -- like;

```js
let bulk = db.bookOrders.initializeOrderedBulkOp();
bulk.find({ isbn: 101 }).updateOne({ $inc: { available: 1 } });
bulk.find({ isbn: 101 }).updateOne({ $inc: { available: -100 } });
bulk.execute();
```

Using the `initializeOrderBulkOp()`, you can make sure that you add one before ordering 100 books -- on the contrary, if using the `initializeUnorderedBuilOp`-- wouldn’t have such a guarantee, and U might end up with the 100-book order coming before the addition of the new book.

In the following code snippets, for `bulkWrite`include the sequence of operations U wish to execute.

### How `$`operators use Indexes

Some queries can use indexes more efficiently then others, some queries cannot use index at all. This sections covers how various query operators are handled by Mongodb.

#### Inefficient operators -- 

In general, negation is inefficient -- `$ne`queries can use index, but not well. They must look at all the index entries other then the one specified by `$ne`-- so they basically have to scan the *entire* index -- fore:

```js
db.example.find({'i': {$ne: 3}}).explain()
```

This query looks at all index entries less then 3 and all index entries greater than 3. This can be efficient if a large swath of your collection is 3.

`$not`can sometimes use an index but often does not know how -- it can reverse basic range. If you need to perform one of these types of queries quickly, figure out if there is another clause that you could add to the query that could use an index to filter the result set down to a small number of documents before MongoDB attempts to do matching.

#### Ranges

Compound indexes can help MongoDB efficiently execute queries with multiple clauses. When designing an index with multiple fileds, put fields that will be used in exact matches -- like:

```js
db.users.find({'age': 47, username: {$gt: 'user5', '$lt': user8}})
```

This query goes directly to `age:47`and then searches within that for usernames between 5 and 8.

#### Indexing objects and arrays

MongodDB allows U to reach into your documents and create indexes on nested fields and arrays. Embedded object and array fields can be combined with top-level fields in compound indexes. 

Indexing embedded docs -- Indexes can be created on keys in embedded documents in the same way that they are created on normal keys. If we had a collection where each document represented a user, might have an embedded document that described each user’s location. if:

```json
{
    "username": "sid",
    "loc": {
        "ip": "1.2.3.4",
        "city": "Springfield",
        "state": "NY"
    }
}
```

could put an index on one of the subfields of `loc`, fore `loc.city`to speed up queries using that field like:

`db.users.createIndex({‘loc.city’: 1})`

Can go as deep as you’d like to do. Just note that indexing the embeddded document itself `loc`has very different behavior than indexing a field of the embedded document fore `loc.city` -- Indexing the entries subdocument will only help queries that are querying for the entire subdocument. The query optimizier could only use in index on `loc`for queries that described the whole subdocument with fields in the correct order.

## Using `errgroup`

Regardless of the programming language, reinventing the wheel is rarely good idea -- It is also pretty comon for codebases to reimplement how to spin up multiple goroutines and aggregate the errors. the `sync`sub-repository of the `golang.org/x`-- providing extensions to the STDLIB.  Handy package `errgroup`-- Fore, have to handle a function -- and receive an argument some data that we want to use to call an external service -- Want to use to call an external service -- Due to constraints -- can’t make a single call, we make multiple calls with a different subset each time.

In case of one error during a call, want to return it. In case of multiple errors, we want to return only one of them like:

```go
func handler(ctx context.Context, circles []Circle) ([]Result, error) {
    results := make([]Result, len(circles))
    wg := sync.WaitGroup{}
    wg.Add(len(results))
    for i, circle := range circles{
        i := i
        circle := circle
        go func() {
            defer wg.Done()
            result, err := foo(ctx, circle)
            if err != nil {
                //...
            }
            resunts[i]=result
        }()
    }
    wg.Wait()
}
```

For this, decided to use `sync.WaitGroup`to wait until all the goroutines are completed and handle the aggregations in a slice. What if the `foo`returns an error -- 

- Just like the `results`slice, could have a slice of errors shared among the goroutines.
- could have a single error accessed by the goroutines via a shared mutex.
- Could think about sharing a channels of errors, and the parent goroutine would receive an handle these errors.

### NOT Copying a `sync`type

The `sync`package provides a basic sync primitives such as mutexes ... For all these types, there is a hard rule -- they should never be copied -- 

Fore: `Cond, Map, Mutex, RWMutex, Once, Pool`and `WaitGroup`

The Std lib provides a common functions and methods that accept a `time.Duration`-- cuz `time.Duration`is an alias for the `int64`type -- newcomers to the language can get confused and provide a wrong duration. `time.Duration`represents the elapsed time between two instants in `nanoseconds`-- like:

```go
ticker = time.NewTicker(time.Microsecond)
// or
ticker = time.NewTicker(1000*time.Nanosecond)
```

In Go the `time.Ticker`is a powerful tool for creating recurring events at regular intervals -- It’s essentially a channel that sends a signal at speicified time intervals -- 

- Periodic tasks -- executing functions or methods repeatedly
- Rate limiting
- Timeouts -- implementing timeouts for operations that might take too long.

```go
ticker := time.NewTicker(time.Second*5)
for {
    select {
    case <-ticker.C:
        fmt.Println("tick")
    case <-ctx.Done():
        ticker.Stop()
        return
    }
}
```

Key points -- `Ticker.C`is a channel that receives the ticks. `Ticker.Stop()`-- method stop the ticker and *close* the channel -- `Context`-- for terminating the tocker.

```go
func main(){
    tricker := ticker.NewTicker(time.Second*2)
    go func() {
        for range ticker.C {
            fmt.Println("Ticker at", time.Now())
        }
    }()
}
```

### `time.After`and Memory leaks

`time.After(time.Duration`is a convenient that returns a channel and waits for a provided duration to elapse before sending a message to this channel. It’s used in concurrent code -- if want to sleep for a given duration, can use the `time.Sleep(time.Duration)`. Codebases often include calls to `time.After`in a loop, may be a root cause of memory leaks -- like;

```go
func consumer(ch <-chan Event) {
    for {
        select{
        case event:= <-ch:
            handle(event)
        // released once the timeout expires and use memory until that happens
        // not for every loop
        case <-time.After(time.Hour):
            log.Println("no message received")
        }
    }
}
```

`time.After`returns a channel - may expect this channel to be closed during each loop iteration, but this isn’t the case -- the resources created by the `time.After`are released once the timout expires and use memory until that happens.

Have several options to fix our example -- like:

```go
func consumer(ch <-chan Event) {
    for {
        ctx, cancel := context.WithTimeout(context.Background(), time.Hour)
        select {
        case event := <-ch:
            cancel()
            handle(event)
        case <-ctx.Done():
            log.println("warning...")
        }
    }
}
```

And the downside of this approach is that have to re-create a context during every single loop.

The second option comes from the `time`package using `time.NewTimer`-- creates a `time.Timer`struct exports the following like:

- A `C`-- internal timer channel
- `Reset(time.Duration)`reset the duration
- A `Stop`to stop the timer.

So just like:

```go
func consumer(ch <-chan Event) {
    timerDuration := time.Hour
    timer := time.NewTimer(timerDuration)
    for {
        timer.Reset(timerDuataion)
        select {
        case event := <-ch:
            handle(event)
        case <-timer.C:
            log.Println...
        }
    }
}
```

Calling `Reset()`method is less cumbersome than having to create  anew context every time -- it’s faster and puts less pressure on the garbage collector.

`time.After`internals -- also just relies one `time.Timer`-- but it only returns the `C`, so don’t have access to the `Reset`method.

## Preventing the data race

Now just understanding data race exists and why it’s happening, so -- there are couple of options, The simplest and cleanest approach in this case is to sue a form of *optimistic locking* based on the `version`number in our movie record.

The fix works like this -- 

1. A and B goroutines both call `app.models.Movies.Get()`first to retrive a copy of the movie record, both of these records have the verison number N.
2. Alice nad Bob’s goroutines make their respective chagnes to the movie
3. Alice and Bob’sgoroutines call `app.models.Movies.Update()`with their copies of the movie record, but the update is only executed if the verison number in the dbs is till `N`. If that has changed, then we don’t execute the update and send the client an error message instead.

This just means that the first update requeste that reaches our dbs will succeed, and whoever is making the second will reveive an error message instead of having their change applied -- to make this wok,  need to chagne the SQL statement for updating a movie so that it looks like:

```sql
UPDATE movies
set title= $1... , version= version+1
where id = R5 and version = $6
returning version
```

Note that the `WHERE`clause now looking for a record with a specific ID and a sepcific version number -- if no matching record can be found, this query will result in a `sql.ErrNoRows`error and we know that the version number has been changed -- either way, it’s a form of *edit conflict* and we can use this as a trigger to send the client an appropriate error response.

#### Implementing optimistic locking

Start by creating a custom `ErrEditConflict`error that we can return from our dbs models in the event of a conflict -- we will use this later in the book when working with user records too. in the `internal/data/models.go`file like:

```go
var (
	ErrRecordNotFound = errors.New("record not found")
	ErrEditConflict   = errors.New("edit conflict")
)
```

Next, update our dbs model’s `Update()`method to execute the new SQL query and manage the situation where a maching record couldn’t be found.

```go
func (m MovieModel) Update(movie *Movie) error {
	query := `
	UPDATE movies
	set title=$1, year=$2, runtime=$3, genres=$4, version= version+1
	where id = $5 AND version = $6
	returning version
	`

	// create an args slice containing the values for the placeholder parameters
	args := []any{
		movie.Title,
		movie.Year,
		movie.Runtime,
		pq.Array(movie.Genres),
		movie.ID,
		movie.Version,
	}

	// use the QueryRow() to execute the query, passing in the args slice as a
	// variadic parameter like:
	err := m.DB.QueryRow(query, args...).Scan(&movie.Version)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return ErrEditConflict
		default:
			return err
		}
	}
	return nil
}
```

Head to our `errors.go`file and create a new `editConflictResponse()`healper -- want this to send a 409 `Conflict`response -- along with a plain-english error message that explains the problem to the client like:

```go
func(app *application) editConflictResponse(w http.ResponseWriter, r *http.Request) {
	message := "unable to update the record due to an edit conflict, please try again"
	app.errorResponse(w, r, http.StatusConflict, message) // 409
}
```

And then as the finel step, need to change our `updateMovieHandler`so that it checks for an `ErrEditConflict`error and callst he `editConflictResposne()`helper if necessary.

```go
// pass the updated to our new Update() method
err = app.models.Movies.Update(movie)
if err != nil {
    switch {
        case errors.Is(err, data.ErrEditConflict) :
        app.editConflictResponse(w, r)
        default:
        app.serverErrorResponse(w, r, err)
    }
    return
}

// Write the updated in a json response
err = app.writeJSON(w, http.StatusOK, envelope{"movie": movie}, nil)
if err != nil {
    app.serverErrorResponse(w, r, err)
}
```

At this point, our `updateMovieHandler`should now be safe from the race-condition that we have been talking about. If two goroutines are executing the code at the same time, the first update will succeed, and the second will fail cuzt he `version`number in the dbs no longer matches the expected value.

#### Round-trip locking

One of the nice things about the optimistic locking pattern that we have used here is that you can extend it so the client passes the version that they expect in an `IF-NOT-MATCH`or `X-Expected-Version`header. In certain applications, this can be useful to help the client ensure that they are not sending their update request ased on outdated information.

#### Locking on other fields or types

Using an incrementing integer `version`number as the basis for an optimistic lock is safe and computationally cheap -- recommend using this approach useless you have a specific reason not to. As an alternative, you could use a `last_updated`timestamp as the basis for the lock. If it’s important to you that the version identifier isn’t guessable, then a good option is to use a high-entropy random string such as UUID in the `version`like:

```sql
UPDATE movies
SET title=$1, year=$2..., version = uuid_gernate_v4()
where id=$5 AND version=$6
RETRUNING version
```

