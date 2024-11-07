# MDB Querying

This looks at querying in detail. The main area covered are as follows -- 

- Can query for ranges, set inclusion, inequalities, and more by using `$`conditions.
- Queries return a dbs cursor, which lazily returns batches of document as you need them.
- There are a lot of metaoperations you can perform on a cursor.

The `find`method is used to perform on a cursor, Querying returns a subset of documents in a collection. When start adding k/v pairs to the query document -- begin restricting our search.

```js
db.users.find({'age': 27})
```

#### Specifying whcih keys to Return -- 

Sometimes U do not need all the k/v in a document returned -- can pass a second arg to `find`or `findOne`. Like:

```js
db.users.find({}, {'username':1, 'email': 1})
```

Can see the `_id`just still returned by default, can also use this second parameter to execude sepcific key/value from the results of a query -- like:

```js
db.uers.find({}, {'username': 1, '_id': 0})
```

#### Limitations

There are some restrictions on queries -- the value of the query document must be a constant as far as the dbs concerned - Fore, were keeping inventory and we had both `in_stock`and `num_sold`keys, we couldn’t compare their values by querying the following like:

### Query Criteria

Queries can go beyond the exact maching -- they can match more complex criteria, such as ranges, OR-clauses, and negation -- fore `$lt..$gte`are all comparison operator, also can combine to look for a range of values. Like:

```js
db.users.find({'age': {$gte: 18, $lte:30}})
```

These types of range queries are often useful for dates -- like:

```js
start = new Date("01/01/2007")
db.users.find({'regitered': {'$lte': start}})
```

And depending on how create and store dates. or like:

```js
db.users.find({'username': {$ne: 'joe'}})
```

#### OR queries

There are two ways to do on `OR`query in MongoDB `$in`can be uesd to query for a variety of values for single key, `$or`is more general -- if have more then one possible value to match for a single key, use an array of certeria with `$in`-- Fore, returning a raffle and the winning ticket numbers -- like:

```js
db.raffle.find({'ticket_no': {'$in': [725,490,..]}})
```

`$in`is very flexible and allow you to specify criteria of different types as well as values. FORE, if are gradually migrating our schema to use usernames instead of user ID can query for either by using this:

```js
db.users.find({user_id: {$in: [12345, "joe"]}})
```

This matches documents with a `user_id`equals to 12345 and dodcuments with a `user_id`to `joe`.

And there is an opposite named `$nin`-- which returns documents that don’t match any of criteria in the array.

```js
db.raffle.find({'ticket_no': {$nin: [725, 542, 309]}})
```

`$in`is good for single key -- what if need to find documents where multiple keys -- like:

```js
db.raffle.find({'$or': [{ticketno: 725}, {winner: true}]})
```

`$or`can contain other conditionals -- fore want to match any of 3 `ticket_no`values or the `winner`can just use like:

```js
db.raffle.find({'$or': [{ticket_no: {$in: [735, 523]}}, {winner: true}]})
```

#### $not

Is a metaconditional -- it can be applied on top of any other criteria -- consider the operator -- `$mod`queries for keys whose values when divided by the first value given have a remainder of the second value like:

```js
db.users.find({'id_num': {$mod: [5,1]}}) // means /5 mod 1
```

so can be 1, 6, 11,... if want instead to returns uses with `id_num`of 2345... can use `$not`like:

```js
db.users.find({'id_num': {$not: {$mod: [5,1]}}})
```

### Type-specific queries

As convered -- MDB has a wide variety of types that can be used in a document -- some of these have special behavior when querying -- 

`null`behaves a bit strangely -- it does match itself -- so if we have a collection with the following document like:

```js
db.c.find({'y': null})
```

`null`also matches *does not exist* -- thus, querying for a key with the value `null`return all documents lacking that key: If only want to find keys whose value is `null`then check that the key is `null`and exists using `$exists`condition note:

```js
db.c.find({'z': {$eq: null, $exists: true}})
```

#### Regular Expressions

`$regex`provides regular expression capabilities for pattern matching strings in queries -- Regular expressions are useful for flexible string matching. Fore:

```js
db.users.find({name: {$regex: /joe/i}})
```

Regular expressions are allowed but not required, if we want to match not only various capitalizations of `joe`, but also, like `joey`can contain to improve our regular expressions: Regular expressions can also match themselves. can:

```js
db.foo.insertOne({'bar': /baz/})
```

can math it with itself.

## Data races with `append`

Fore, will initialize a slice and create two goroutines that will use `append`to create a new slice with an additional element like -- 

```go
s := make([]int, 1)
go func() {
    s1 := append(s, 1)
    fmt.Println(s1)
}()
go func() {
    s2 := append(s, 1)
    fmt.Println(s2)
}()
```

A slice is just backed by an array and has two properties -- length and capacity -- the length is the number of available elements in the slice -- whereas the capacity is the total number of elements in the backing array -- when use `append`the behavior depends on whether the slice is full (length==capacity) -- if it is, the Go runtime creates a new backing array to add the new element, otherwise, the runtime adds it to the existing backing array.

In this, create a slice with `make([]int, 1)`-- creates a 1L, and 1C slice -- thus, cuz the slice is already full -- using `append`in ecah goroutine returns a slice backed by a new array -- it doesn’t mutate the existing aray.  If change the slice like `s := make([]int, 0, 1)`, 0L and 1C there is a data race. Therefore, the array is not full -- both goroutines attempt to update the same index of the backing array -- which is the data race. So how can prevent the data race if want the both goroutines to work on a slice containing the initial element of `s`plus an extra element -- 

```go
s := make([]int, 0, 1)
go func() {
    sCopy := make([]int, len(s), cap(s))
    copy(sCopy, s)
    s1 := append(sCopy,1)
    fmt.Println(s1)
}()

go func() {
    //...like
}()
```

For this, both make a copy of the slice, then they use `append`on the slice copy, not the original ones. While working with slices in concurrent contexts, we must recall that using `append`on slice isn’t always race-free.

### Using mutexes accurately with slices and maps

While working in concurrent context where data is both mtable and shared, often have to implement protected accesses around data structures using mutexes. A common mistake is to use mutexes inaccurately when working with slices and maps -- will implement a `Cache`struct used to handle caching for customer balances. fore:

```go
type Cache struct {
    mu       sync.RWMutex
    balances map[string]float64
}
```

Fore, add an `AddBalance()`method that mutates the `balance`map -- the mutation is done in a criteria selection like:

```go
func (c *Cahce) AddBalance(id string, blanace float64) {
    c.mu.Lock()
    c.balances[id]=balance
    c.mu.Unlock()
}
```

Meanwhile have to implement a method to calculate the average blance -- for all the customers -- one idea is to handle a minimal critical section this way just like:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    balances := c.balances
    c.mu.RUnlock()
    
    sum := 0.
    for _, balance := range balances {
        sum += balance
    }
    return sum/float64(len(blanaces))
}
```

Makes a copy to a local `balances`variable, only the copy is done in the CS to iterate over each balance and calculate the average outside of the CS --  Data race occurred!

Only the copy is doen in the critical section to iterate over each balance and calculate the average outside of the CS -- there is a problem - internally, a map is `runtime.hmap`struct contaiing mostly metadata and a pointer referencing data buckets -- so `balances := c.balances`doesn’t copy the actual data -- Assigned to `balances`a new map referencing the same *data buckets* as `c.balances`-- meanwhile - the two goroutines perform operations on the same data set, and one of them mutates. Have two options -- 

If the iteration operation isn’t the heavy, should protect the whole function. Just like:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock
    defer c.mu.RUnlock()
    //...
}
```

Another option -- if the iteration is not cheap -- work on an actual copy so: just protect the actual copy operation:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    m := make(map[string]float64, len(c.balances))
    for k, v := range c.balances {
        m[k]=v
    }
    c.mu.RUnlock()
    sum := 0
    for _, balance := range m {
        sum += balance
    }
    return sum/float64(len(m))
}
```

Firt we create a copy of the map to local `balances`variable -- only the copy is done n the CS to iterate over each balance and calculate the average outside of the CS.

But For this, have to iterate twice on the map values -- once to copy and once to perform the operations -- but the critical section is only the map copy -- therefore, this solution can be a good fit if and only if an operation isn’t *fast*. In summary, have to be careful with the boundaries of a mutex lock.

## CRUD operations

Cuz the `Insert()`method is signature takes a `*Movie`pointer as the parameter, when we call `Scan()`to read in the *system-generted* data we are updating the values at the location the parameter points to. Like:

```go
args := []any {Movie, Title, movie.Year, ...}
```

Storing the inputs in a slice isn’t strictly necessary -- but as mentioned in the code commetns -- it’s a nice pattern can help the clarity of your code -- personally, usually do this for SQL queries with more than 3 placeholder parameters. Note that in order to store our `movie.Genres`value in the dbs, need to pas it through the `pa.Array`adpater function before executing the SQL query.

Behind the scenes, the `pq.Array()`takes our `[]string`slice and converts it to `pa.StringArray`type. Note that the `pq.StringArray`type implements the `driver.Valuer`and the `sql.Scanner`interface necessary to translate our native `[]string`slice to and from a value that PSQL dbs can understand and store in a `text[]`array column.

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
    var input struct {
        //...
    }
    err := app.readJSON(w, r, &input)
    //...
    movie := &data.Movie{...}
    v:= validator.New()
    if data.ValidateMovie(v, movie); !v.Valid() {
        app.failedValidationRepsonse(w, r, v.Errors)
        return
    }
    err = app.models.Movies.Insert(movie)
    if err != nil {
        app.serveErrorResponse(w, r, err)
        return
    }
    // just sending an HTTP response, want to include a location header to let the client
    // know which URL they can find the newly-creted resouce at.
    headers := make(http.Header)
    headers.Set("Location", fmt.Sprintf("v1/movies/%d", movie.ID))
}
```

#### Creating additional Records

While are at it - create a few more record in the system to help us demonstrate different functionality as our build progresses -- Run the following commands to create 3 more movie records in the dbs

#### Additional Information -- 

`$N`notation -- A nice feature of the PSQL placeholder parameter `$N`notation is that you can use the *same parameter value in multiple places* in your SQL statement -- fore, it’s perfectly acceptable to write code like this: like:

```go
stmt := "update foo set bar = $1 + $2 where bar = $1"
err := db.Exec(stmt, 123, 456)
```

#### Executing multiple statements -- 

Occasionally might find youself in the position where U want to execute more than one SQL statement in the same dbs call like:..

```go
stmt := `
	UPDATE foo SET bar = true;
	UPDATE foo SET baz = false;
	`
err := db.Exec(stmt)
//...
```

Having mutliple statements in the same call is supported by the `pq`driver, so long as the statements do not contain any placeholder parameters - if do contain placeholder paraemeters - then will receive the following message. To just work around this, will need to either split out the statements into separate dbs calls, or if not possible, can create custom function in PSQL.

### Fetching a Movie

Now move on the code for *fetching* and displaying the data for a speciifc movie -- Start by updating the `Get()`method to execute the following SQL query like: 

```sql
select id... from movies where id= $1
```

Cuz table uses the `id`as its PK, this query will only ever return exactly one dbs row -- so it’s appropriate for us to execute this query using Go’s `QueryRow()`method again.

```go
func (m MovieModel) Get(id int64) (*Movie, error) {
	// the PSQL bigserial type that we are using for movie ID starts
	// auto-increment at 1 by default.
	if id < 1 {
		return nil, ErrRecordNotFound
	}

	// define the sql query for retrieving the movie data
	query := `
		SELECT id, created_at, title, year, runtime, genres, version
		from movies where id= $1
		`
	var movie Movie

	// Execute the query using the QueryRow() method, passing in the provided id value
	err := m.DB.QueryRow(query, id).Scan(
		&movie.ID,
		&movie.CreatedAt,
		&movie.Title,
		&movie.Year,
		&movie.Runtime,
		pq.Array(&movie.Genres), // not this form
		&movie.Version,
	)

	// Handle any errors, if there was matching movie found, Scan() will return
	// a sql.ErrNoRows error
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	// otherwise just return a pointer to the movie struct
	return &movie, nil
}
```

The only real thing of note is the fact that we just need to use the `pq.Array()`adapter again when scanning in the genres data from the PSQL `text[]`array , if don’t use this, get the error.

#### Updating the API handler

The next thing is update our `showMovieHandler`so that it calls the `Get()`method we just made -- the handler should check to see if `Get()`returns an `ErrRecordNotFound`-- if it dows, the client should be sent a *404 not found*.

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	// call the `Get()` method to fetch the data for a specific movie -- also need to use
	// the errors.Is() to check if it returns a data.ErrRecordNotFound error
	movie, err := app.models.Movies.Get(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	err = app.writeJSON(w, http.StatusOK, envelope{"movie": movie}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

That is succinct -- fore/  Why not use an unsigned integer for the movie id -- There are just two reasons for this -- 

1. Cuz PSQL doesn’t have unsigned integers. It’s best to align the integer types based on the following:

| PostgreSQL type         | Go type |      |      |      |      |
| ----------------------- | ------- | ---- | ---- | ---- | ---- |
| `smallint, smallserial` | `int16` |      |      |      |      |
| `integer, serial`       | `int32` |      |      |      |      |
| `bigint, bigserial`     | `int64` |      |      |      |      |

There is also another more sutble -- go’s `database/sql`doesn’t actually support any integer values.

### Updating a `Movie`

In this, continue building up our app and add a brand-new endpoint which allows clients to *update the data for a specific movie*. `PUT /v1/movies/:id`. We will set up the endpoint so that a client can edit the values for a movie, in our proj the `id`and `created_at`should never change once created, and the `version`also should control.

For now, just configure this endpoint so that it performs a *complete replacement* of the values for a movie -- This need to provide values for *all* editable fields in their JSON request body -- fore, if a client wanted to add the genre to the movie in our dbs, should need to send a JSON request body which look like this -- 

```json
{
    "title": "Black Panther",
    "year" : 2018,
    "runtime": "123 mins",
    "genres": ["action", "adventure", "Sci-fi"]
}
```

#### executing the SQL query

Just like:

```sql
UPDATE movies SET title = $1, .. versoin = version+1
where id = $5
returning version
```

Notice here that we are incrementing the `version`values as part of the query ? and then at the end using the `RETUNNING`clause to return this new incremented, version value. And note that like before, this query returns a single row of data so we will also to use Go’s `QueryRow()`method to execute it -- like:

```go
func (m MovieModel) Update(movie *Movie) error {
	query := `
	UPDATE movies
	set title=$1, year=$2, runtime=$3, genres=$4, version= version+1
	where id = $5 returning version
	`

	// create an args slice containing the values for the placeholder parameters
	args := []any{
		movie.Title,
		movie.Year,
		movie.Runtime,
		pq.Array(movie.Genres),
		movie.ID,
	}

	// use the QueryRow() to execute the query, passing in the args slice as a
	// variadic parameter like:
	return m.DB.QueryRow(query, args...).Scan(&movie.Version)
}
```

It’s important to emphasize that just like the `Insert()`-- the `Update()`takes a pointer to a `Movie`as the input parameter and mutates it in-place again.

#### Creating the API handler -- 

Then in the `movies.go`fiel and update it to include the brand-new method. 

| Method | Url Pattern    | Handler              | Action                |
| ------ | -------------- | -------------------- | --------------------- |
| PUT    | /v1/movies/:id | `updateMovieHandler` | update specific movie |

The nice thing abou this handler is that we have already laid all the groundwork for it -- specifically, need to:

1. Extract the movie ID from the URL using the `app.readIDParam()`helper
2. Fetching the corredponding movie recorde from the dbs using the `Get()`first
3. Read the JON request body continig the updated movie data into an `input`struct
4. Copy the data across from the `input`struct to the movie record
5. Check that the updted movie record is valid using the `data.ValidateMovie()`
6. Call the `Update()`to store the updated movie record in dbs
7. Write the updated movie data in a JSON response using the `app.writeJSON()`helper.