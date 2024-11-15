# Limiting, Skipping, and Sorting Documents

So far, wirte basic and complex queries and to project fields in the resulting documents -- will learn how to control he number and order of documents returned by a query. Talk about why the amount of data query returns needs to be controlled -- won’t be using all the documents your query matches to.

### Limiting the Result

To limit the number of records a query returns, the resulting cursors provides a function called `limit()`-- accepts an integer and returns the same number of records, if available -- MDB recommends the user of this function as it reduces the number of records that returns from the cursor and improves the speed.

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {title:1, _id:0}
).limit(3)
```

This query is also adding a projection to the `title`, As can seen, there are a limit size is larger then the actual records within the cursor, all the records will be returned, irrespective of the set limit. Note that the setting the limit to 0 is equivalent to not setting any limit at all -- fore:

```js
db.movies.find(...).limit(-2)
```

Equivalent to the limit of size 2. However, the result set’s batchsize can affect this behavior.

#### Limit and Batch Size

When a query is executed in MongoDB, the results are processed and returned in the form of one or more batches. The batches are allotted internally, and the results will be displayed all at once. One of the main purposes of the batching is to avoid high resource utilization -- which may happen while processing a large number of record sets. Also, it keeps the connection between the client and server active, -- cuz of which timeout errors are avoided. After a certain threshold value for waiting is reached, the connection between the client and the server is broken and the query is failed with a timeout exception.

Using batching avoids such timeouts as the server keeps returning the individual batches continuously. Different MongoDB drivers have different batch sizes -- for single query, can be set like:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {title:1, _id:0}
).batchSize(3)
```

The output has no effect on the output, however -- there was a differece in how the results were parepred internally. 

#### Positive limit with Batch Size

When the preceding is executed -- which specifies a batch size of 5 -- the dbs starts finding the documents that match the given condition -- As soon as the first 3 found -- they are returned to the client as the frist batch -- next the remaining are found and returned as the next batch -- however, for the users, the results are printed at once and the change is unnoticeable. Note that the same thing happens when a query is executed when a positive limit that is larger then the batch size and the records are internally fetched in multiple batches like: 

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {title:1, _id:0}
).limit(4).batchSize(3)
```

This query -- batchSize is larger than the provided batch -- Negative Limits and Batch size -- MongoDB uses batches if the total number of records in the result exceeds the batch szie. If:

```js
db.movies.find(...).limit(-7).batchSize(5)
```

#### Skipping Documents

Skipping is used to exclude some documents in the result set and return the rest -- the MongoDB cursor provides the `skip()`function which accepts an integer and skips the specified number of document from the cursor, returning the rest -- prepared queries to find the titles of movies starring. like:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {title:1, _id:0}
).skip(2)
```

Since the `skip()`func has been provided with 2-- the first two document will be excluded. `skip()`*doesn’t allow* the use of negative numbers.

#### Sorting documents

Sorting is used to return doccuments in a specified order -- without using explicit sorting, MongoDB does not guarantee the order in which the documents will be returned, which may very -- even if the same query is executed twice. Havine a specific sort order is important -- especially during pagination -- The MongoDB cursor provides a `sort()`function that accepts argument of the document type - like:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {title:1, _id:0}
).sort({title: 1})
```

Calling the `sort()`function the resulting cursor -- The argument to the function is a document where the `title`field has a value of 1 specifies that the given field should be sorted in ascending order. When the query is executed after it’s been sorted, result are evident. Pass -1 to the `sort`present sorting in descending order. Adn sorting can be performed on multiple fields. like:

```js
db.movies.find().limit(50).sort({'imbd.rating': -1, 'year': 1})
```

It is worth nothing that any number of other than a positive or negative is considered invalid sorting.

## Map of Any

When unmarshaling data, can provide a map instead of a struct -- the rationale is that when the keys and values are uncertain, passing a map gives us some flexibility instead of a static struct -- there is a rule to bear in mind to avoid wrong assumptions and possible goroutine panics. Fore:

```go
b := getMessage()
var m map[string]any
err := json.Unmarshal(b, &m)
if err != nil {
    return err
}
```

Provide the following JSON to the previous code fore: `{“id”: 32, “name”: “foo”}`, cuz use a generic map like `map[string]any`-- it parses all the different fileds automatically like `map[id:32 name:foo]`, However, there is an important gotcha to remember if we use a map of `any`-- any numberic value -- regardless of whether it contains a decimal -- is just converted into a `float64`type. Should be sure we don’t make the wrong assumption and expecte numeric values without decimals to be converted into intergers by default.

### Common SQL mistakes

The `database/sql`package just provides a generic interface around SQL dbs -- it’s also fairly common to see some patterns or mistakes while uing this package.

#### `sql.Open`doesn’t necessarily establish connections to a dbs

When using `sql.Open()`, one common misconception is expecting this function to establish connections to the dbs:

```go
db, err := sql.Open("mysql", dsn)
if err != nil {
    return err
}
```

This isn’t necessarily the case -- According to the documentation -- Open may just validate its arguments without creating a connection to the dbs. The behavior depends on the SQL driver used -- for some cases, want to make a service ready only after we know that all the depednencies are correctly set up and reachable. If we want to ensure that the function that use `sql.Open`also guarantees that the underlying dbs is reachable. should use the `Ping`

```go
db, err := sql.Open("mysql", dsn)
if err != nil {
    return err
}
if err := db.Ping(); err != nil {
    return err
}
```

`Ping`forces the code to establish a connection that *ensures* that the data source name is valid and the dbs is reachable, note that an alternative to `Ping`is `PingContext`-- which asks for an additional context conveying when the ping sould be canceled or timed out.

#### Forgetting about conenctions pooling

Just as the default HTTP client and server provide default behaviors that may not be effictive in production -- it’s essential to understand how dbs conenctions are handled in Go. `sql.Open`returns an `*sql.DB`struct -- doesn’t represent a single dbs connection -- represents a *pool* of conenctions. This is worth nothing -- 

- Already used ( by another goroutine that triggers a query)
- Idle ( already created but not in use for the time being)

It’s also important to remember that creating a pool leads to 4 available config parameters that we may want to override -- Each of these parameters is an exported method of `*sql.DB`

- `SetMaxOpenConns`-- Maximum number of open connections to the dbs.
- `SetMaxIdelConns`-- Maximum number of idle conenctions
- `SetConnMaxIdleTime`-- Maximum amount of time a connection can be idle before it’s closed.
- `SetConnMaxLifetime`-- Maximum amount of time a conenction cab be held open before it’s closed.

## Creating helper functions

To assist with this,  going to create 3 new helper functions -- `readString, readInt, readCSV`-- Use these to extract and parse values from the query string or return a default fallback value if necessary -- like:

```go
func (app *application) redString(qs url.Values, key string, defaultValue string) string {
    s := qs.Get(key)
    if s== "" {
        return defaultValue
    }
    return s
}
// readCSV and readInt, likewise
```

#### Adding the API handler and route

Create a new `listMovieHandler`for the `GET /v1/movies`endpoints -- this handler will simply parse the request query string using the helpers we just made.

```go
func (app *application) listMovieHandler(w http.ResponseWriter, r *http.Request) {
	// to keep things consistent with handlers, define an input struct
	var input struct {
		Title    string
		Genres   []string
		Page     int
		PageSize int
		Sort     string
	}

	// Initialize a new Validator instance
	v := validator.New()

	// call r.URL.Query() to get the url.Values map containing the query string data
	qs := r.URL.Query()

	// Use our helpers to extract the title and genres query string values.
	input.Title = app.readString(qs, "title", "")
	input.Genres = app.readCSV(qs, "genres", []string{})

	// Get the page and page_size as integers
	input.Page = app.readInt(qs, "page", 1, v)
	input.PageSize = app.readInt(qs, "page_size", 20, v)

	// extract the sort query string value, falling back to id if it is not provided
	input.Sort = app.readString(qs, "sort", "id")

	// check the validator instance for any errors and use the failedValidationResponse
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	fmt.Fprintf(w, "%+v\n", input)
}
```

Then need to create `GET /v1/movies`route in the `routes.go`file like:
`router.HandlerFunc(http.MethodGet, "/v1/movies", app.listMovieHandler)`

#### Creating a Filters struct

The `page, page_size`and `sort`query string parameters are things that you will potentially want to use on other endpoints in your API too -- so, to help make this easier, let’s quickly split them out into a reusable `Filters`struct.

```go
type Filters struct {
	Page     int
	PageSize int
	Sort     string
}
```

Once that is done, head back to your `listMoviesHandler`and update it to use the new `Filters`like:

### Validating Query String Parameters

For the `readInt()`helper that we made -- our API should already be returning validatione errors if the `page`and `page_size`query string parametrs don’t contain integer values. But we still need to perform some additional sanity chekcs on the query string values provided by the client -- want to check that -- 

- The `page`value is between 1 and 10,000,000
- The `page_size`is betwen 1 and 100
- The `sort`contains a know and supported value for our movie table, allow just the `id, title, year, runtime...`and their - edition.

tTo fix, just like: in the `internal/data/filters`file and create a new `ValidateFilters()`which conducts these checks on the values like:

```go
type Filters struct {
	Page         int
	PageSize     int
	Sort         string
	SortSafeList []string
}

func ValidateFilters(v *validator.Validator, f Filters) {
	v.Check(f.Page > 0, "page", "must be greater than 0")
	v.Check(f.Page <= 10_000_000, "page", "must be a maximum of 10 million")
	v.Check(f.PageSize > 0, "page_size", "must be greater than 0")
	v.Check(f.PageSize <= 100, "page_size", "must be a maximum of 100")

	// check that the sort parameter matches a value in the safelist.
	v.Check(validator.PermittedValue(f.Sort, f.SortSafeList...), "sort",
		"invalid sort value")
}
```

Also, need to update the `listMovieHandler`to set the supported values in the `SortSafeList`field.

```go
input.Filters.SortSafeList = []string{"id", "title", "year",
                                      "runtime", "-id", "-title", "-year", "-runtime"}

if data.ValidateFilters(v, input.Filters); !v.Valid() {
    app.failedValidationResponse(w, r, v.Errors)
    return
}
fmt.Fprintf(w, "%+v\n", input)
```

#### Listing Data

Move on and get our `GET /v1/movies`endpoint returning some real data -- for now, ignore any query string values provided by the client and return *all* movie records -- stored by Movie ID -- will just give us a solid base from which we can develop the more specilized functionality around filtering, sorting, and pagination. Our aim is will be to get endpoint to return a JSOn response containing an array of all movies.

#### Updating the application

To retrieve this data form our PSQL database, create new `GetAll()`method on the databas model which executes the following SQL query: 

```sql
SELECT id, created_at, title, year, runtime, genres version 
FROM movies
ORDER BY id
```

Cuz wer expecting this SQL query to return multiple records, need to run it using Go’s `QueryContext()`method, already explained how this works in detail in Go. Fore:

```go
func (m MovieModel) GetAll(title string, genres []string, filters Filters) ([]*Movie,
	error) {
	query := `
	SELECT id, created_at, title, year, runtime, genres, version
	FROM movies
	ORDER BY id`

	// create a context with 3s timeout
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	// Use the QueryContext() to execute the query -- returns a sql.Rows
	rows, err := m.DB.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}

	// importantly, defer a call to rows.Close() is to ensure that the result is
	// closed before GetAll() returns
	defer rows.Close()
	movies := []*Movie{}
	for rows.Next() {
		var movie Movie

		// Scan the values from the row into Movie struct
		err := rows.Scan(
			&movie.ID,
			&movie.CreatedAt,
			&movie.Title,
			&movie.Year,
			&movie.Runtime,
			pq.Array(&movie.Genres),
			&movie.Version,
		)
		if err != nil {
			return nil, err
		}
		movies = append(movies, &movie)
	}

	// When the rows.Next() loop has finished, call the rows.Err() to retrieve
	// any error that was encountered during the iteration
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return movies, nil
}
```

Next up, need to adapt the `listMoviesHandler`so that it calls the new `GetAll()`method to retreive the movie data, and then writes this data as a JSON response. Just like:

```go
movies, err := app.models.Movies.GetAll(input.Title, input.Genres, input.Filters)
if err != nil {
    app.serverErrorResponse(w, r, err)
    return
}

// Send a JSON response containing the movie data
err = app.writeJSON(w, http.StatusOK, envelope{"movies": movies}, nil)
if err != nil {
    app.serverErrorResponse(w, r, err)
}
```

Make the `GET /v1/movies`request U should see the slice of movies returned by the `GetAll()`returned as a JSON array.

#### Filtering Lists

In this -- going to start putting our query string parametrers to use -- so that clients can search for movies with a specific title or genres -- build a reductive filter which allows clients to search based on a case-insensitive exact match for movie title and/or one or more movie genres. Specially, build a *reductive filter* which allows clients to search based on a case-insenstive exact match for move title and/or one or more movie genres like:

`/v1/movies?title=black+panther` -- The `+`symbol in the query strings above is a URL-encoded space sharacer. Alternatively, could use `%20`instead.

#### Dynamic filtering in the SQL query -- 

The hardest part of building a dynamic filtering like this is the SQL query to retrieve the data-- need it to work with no filters, filtes on both, or a filter on only one of them. To deal with this, one option is to build up SQL query dynamically at runtime -- with the necessary SQL for each filter concatenated or interpolated into the `WHERE`clause. Cuz this approach can mke your code messay and difficult to understand...