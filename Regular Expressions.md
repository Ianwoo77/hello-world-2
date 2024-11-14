# Regular Expressions

In a real-world movie service, will want to provide auto-completion search boxes where -- as soon as user types in a few characters of the mvoie title, the In Mongodb queries, regular expressions can be used with the `$regex`operator.

```js
db.movies.find(
    {'title': {$regex: 'Opera'}},
    {'title':1}
)
// can also use ^ and $ operator
```

case-insensitive search - Search wtih regular expression is case-sensitive by default, the casing of the characters in the provided search pattern is matched exactly. Fore:

```js
db.movies.find(
	{'title': {$regex: 'the', $options: 'i'}}
)
```

### Query Arrays and Nested Documents

Querying over an array is similar to querying and other field, in the `movies`collection, there are several arrays, and the `cast`fore -- Fore:

```js
db.movies.find(
    {$and: [
            {cast: 'Charles Chaplin'},
            {cast:'Henry Bergman'}
        ]}
)
```

Can conclude that when an array field is queried using a value, all those documents are returned where the array contains at lest one element that satisfies the query.

Finding by an Array -- fore:

```js
db.movies.find({'language': ['English', 'German']})
```

Note that when array fields are searched using an array value, the value is just matched using an equality check -- any two arrays only pass the equility check if they have the same elements in the same order.

#### Searching with the `$all`operator

The `$all`operator finds all those documents where the value of the field contains all the elements. like:

```js
db.movies.find(
    {
        'languages': {
            $all: ['English', 'French']
        }
    }
)
```

#### Projecting Array Elements -- 

There are a few ways to limit how many elements of an array are returned in the query output -- Elements is an array can also be projected -- learn how to limit the result set when we search with an array field. using `$`-- Can search an array by an element value and use projection to exclude all but the first matching using the `$`operator like:

```js
db.movies.find(
    {'languages': 'Syriac'},
    {languages:1}
)
```

Although the query is intended to find `Syriac`-- the output contains other languages as well. Now can use the `$`:

```js
db.movies.find(
    {'languages': 'Syriac'},
    {'languages.$':1} // only the Syriac returned
)
```

The most important thing to remember is that iff more than one element is matched -- `$`operator projects only the first matching element.

#### Projecting Matching Elements by thei Index Position (`$slice`)

The `$slice`operator is used to limit the array elements based on their index position. This operator can be used with any array field, irrespective of the field being queried or not.

```js
db.movies.find(
    {title: 'Youth Without Youth'},
    {'languages': {$slice: 3}}
)
```

The output for the query shows that the `languages`field only contains the first 3 elements. So the `$slice`operator can be used in a few more ways -- the following projection expression will return the last two elements like:
`{languages: {$slice: -2}}`-- the following output shows that the array has been sliced down to last two: so the `$slice`operator can also be passed with two arguments -- like: `{$slice: [2,4]}`-- means skip the first two return next four after it.

```js
db.movies.find(
    {title: 'Youth Without Youth'},
    {
     	'languages': {$slice: [2,4]}, 
     	languages:1
    },
)
```

#### Querying Nexted Objects

Similar to arrays, nested or embedded object can also be represented as values of a field -- fields that have other objects as their values can be searched using the complete object as a value. For this, the `awards`whose value is a nested object -- the following shows the `awards`for a random movie in the collection like:

```js
db.movies.find(
    {'awards': {'wins': 1, 'nominations': 0, text: '1 win.'}}
)
```

For this form, when nested object fields are searched with object values, there must be an exact match. 

Querying object fields -- Can just ust the `.`notation -- can be used to search nested objects by providing the values of its fields -- fore, to find movies that have won 4 awards -- you can use dot notation like so:

```js
db.movies.find(
    {'awards.wins':4}
)
```

The preceding output indicates that the filter has been correctly applied to `wins`-- and the nested field search is performed independently on the given fields, so irrespective of the order of the elements -- can search by multiple fields and use any of conditional or logical query operators like:

```js
db.movies.find(
    {
        'awards.wins': {$gt: 5},
        'awards.nominations': 6,
    },
    {title: 1}
)
```

## `time.After`and potential memory leaks

Is a Go function that returns a channel that will receive the current time after a specified duration --  While `time.After`itself doesn’t directly cause memory leaks -- improper usage can lead to resource leaks --  For 

1. Unconsuemd channels -- If the channel returned by `time.After`is not read from, the underlying timer will not be garbage collected
2. Solution -- always ensure that the channel is read form or closed to release the resources

For long lived timers -- 

- If a timer is created for a very long duration and is not explicitly canceled, can hold onto resources for an extended period.
- Consider using the `time.NewTimer`and `time.Stop`to explicitly cancel timers.

```go
func consumer(ch <-chan Event) {
    for {
        select {
        case event := <-ch:
            handle(event)
        case <-time.After(time.Hour):
            log...
        }
    }
}
```

Here use `select`in two cases, receiving a message from `ch`and after 1 hour without messages -- at first sight, this code looks OK -- however, it may lead to memory usage issues. `time.After`just returns a channel -- may expect this channel to be closed during each loop iteration -- isn’t the case -- the resource created by the `time.After`are released once the timeout expires. fore this, if we receive a significant volume of messages fore, 5m per hour, our app will consuem 1GB of memory. Note that the `time.After()`returns an `<-chan time.Time`-- meaning that it is a receive-only channel that can’t be closed.

```go 
func consumer(ch <-chan Event) {
    for {
        ctx, cancel := context.WithTimeout(context.Background(), time.Hour)
        select {
        case event := <-ch:
            cancel()
            hanel(event)
        case <-ctx.Done():
            log.Println(..)
        }
    }
}
```

For this -- the downside of this is that we have to re-create a context during every single loop iteration. Creating a context *isn’t* the most lightweight operation in Go.

The second comes to the `time.NewTimer`-- creates a `time.Timer`struct exports -- `C`for internal timer channel, and `Reset(time.Duration)`to reset the duration and `Stop()`to stop the timer. 

Should alsno note that the `time.After`also reles on `time.Timer`-- only returns the `C`field.

```go
package time
func After(d Duration) <-chan Time {
    return NewTimer(d).C
}
```

So can implement a new version just using the `time.NewTimer()`like:

```go
func consumer(ch <-chan Event) {
    timeDuration := time.Hour
    timer := time.NewTimer(timeDuration)
    for {
        time.Reset(timerDuration) // reset the duration
        select {
        case event := <-ch:
            handle(event)
        case <-timer.C:
            log.print(...)
        }
    }
}
```

For this, keep a recurring action during each loop iteration -- calling the `Reset`during each loop iteration. Calling `Reset`is less cumbersome than having to create a new context every time.

### Common JSON-handling mistakes

#### Unexpected behavior due to type embedding - 

In the context of JSON handling, discuss another potential impact of type embeddeing that can lead to unexpected *marshaling/unmarshaling* results -- fore:

```go
type Event struct {
    ID int
    time.Time
}
```

Here, cuz `time.Time`is embedded, in the same way decieded -- can access the `time.Time`directly If:

```go
event := Envent {
    ID: 1234
    time.Now()
}
b, err := json.Marshal(event)
if err != nil {
    return err
}
fmt.Println(string(b))
```

Cuz this field is exported -- it should have been marshaled -- If an embedded fileld tye implentas an interface, the struct contining the embedded field will also implement this interface -- Can change the default marshaling behavior.

```go
type foo struct{}
func(foo) MarshalJSON([]byte, error) {
    return []byte(`"foo"`), nil
}
func main(){
    b, err := json.Marshal(foo{})
    if err != nil {
        panic(err)
    }
    fmt.Println(string(b))
}
```

For this example, have to know that `time.Time`*implements* the `json.Marshaler`interface -- cuz `time.Time`is an embedded field of `Event`-- the *compiler promotes its methods*. To fix, just:

```go
type Event struct {
    ID int
    Time time.Time
}
```

## Advanced CRUD Operations

- Support *partial* updates to a resource
- Use *optimistic concurrency control* to avoid RC
- Use *context timeout* to terminate long-running dbs queries and prevent unncessary resource use.

### Handling Partial Updates

In this, going to change the behavior of the `updateMovieHandler`so that it support *partial updates* of movie records. It would be nice if could send a JSON request -- like: `{year: 1985}`-- When decoding request body any fields in our `input`struct which don’t have a corresponding JSON k/v pair will retain their zero-value -- So actually -- in the context of partial update this causes a problem -- tell the difference between -- 

- A client providing a k/v pair which has a zero-value like `{title:’’}`
- A client not providing a k/v just.

The key thing to notice there is that pointers have the zero-value `nil`. So in theory -- we could change the fields in our `input`struct to be pointers --  So:

```go
var input struct {
    Title *string `json:"title"`
    Year *int32 //... likewise
    Geners []string `json:"genres"` // don't need to change
}
```

#### Performing the partial update -- 

Put this into the practice -- edit `updateMovieHandler`method so it supports partial updates as follows:

```go
func (app *application) updateMovieHandler(w http.ResponseWrite, r *http.Request) {
    //...
    movie, err := app.models.Moveis.Get(id)
    if err != nil {
        switch {
        case errors.Is(err, data.ErrRecordNotFound):
            app.notFoundResponse(w,r)
        default:
            app.serverErrorResponse(w, r, err)
        }
        return
    }
    
    // use pointers 
    var input struct {
        Title *string `json:"title"`
        //...
        Generes []string `json:"genres"`
    }
    
    // Decode the JSON as normal
    err = app.readJSON(w, r, &input)
    if err != nil {
        app.badReuestResponse(w, r, err)
        return
    }
    
    // For this, if the input.Title` value is nil that we know that no corresponding `title` k/v
    // was provided in the JSON request body, move on and leave the movie record unchanged.
    if input.Title != nil {
        movie.Title= *input.Title
    }
    if input.Year != nil {
        movie.Year= *input.Year
    }
    //..
    if input.Genres != nil {
        movie.Genres= input.Genres
    }
    
    v := validator.New()
    if data.ValidateMovie(v, movie); !v.Valid() {
        app.failedValidationResponse(w, r, v.Errors)
        return
    }
    
    err = app.models.Movies.Update(movie)
    if err != nil {
        //...
        return
    }
    err = app.writeJSON(w, http.StatusOK, envelope{"movie": movie}, nil)
    if err != nil {
        app.serverErrorResponse(w, r, err)
    }
}
```

Just changed our `input`struct so that all the fields now have a zero-value `nil`-- after parsing the JSON, then go through the `input` struct fields and only update the movie record if the new value is not `nil`.

For API endpoints which perform *partial updates* on a resources, it’s appropratie to use the `PATCH`.
`router.HandlerFunc(http.MethodPatch, “/v1/movies/:id”, app.updateMovieHandler)`

### Optimistic Concurrency Control

In the `updateMovieHandler`-- there is a *race condition* if two clients try to update the same movie record at exactly the same time. Despite making two separate updates, only the last update will be reflected in the dbs at the end cuz the two goroutines were *racing* each other to make the change -- Alice’s update to the movie runtime will be lost when Bob’s update overwrites it with the old runtime value.

#### Preventing the data race

There are a couple of options -- but the simplest and cleanest approach in this case is to use an form of *optimistic locking* based on the version number in our movie record.

1. A and B bothj call `app.models.Movies.Get()`to retreive a copy of the movie record. `N`returned
2. Both make some changes
3. Call the `Update()`with their copies of the movie record. For this -- update is only executed if the version number in the dbs is still `N`. if has changed, we don’t execute the update and send an error.

```sql
UPDATE movies SET ... , version= version+1
WHERE id = $5 and version = $6
returning version
```

Notice tht the `WHERE`we are now looking for a record with just a specific ID and number -- for this, if no matching record can be found, the query will result in a `sql.ErrNoRows`error and we know that the version number has been changed .

#### Implementing locking - 

Start by creating a custom `ErrEditConflict`error that we can return from our dbs models in the event of a conflict -- use this later in the book when working with user records too -- it makes sense to define it like:

```go
var (
    ErrEditConflict= errors.New("edit conflict")
)
```

Next, update our dbs model’s `Update()`method to execute the new SQL query and manage the situation where a matching record couldn’t be found.

```go
func (m MovieModel) Update(movie *Movie) error {
    query= `UPDATE movies set .. where id =$5 and version=$6 returning version`
    args := []any {
        movie.Title
        //...
        movie.ID,
        movie.Version,
    }
    err := m.DB.QueryRow(query, args...).Scan(&movie.Version)
    if err != nil {
        switch {
        case errors.Is(err, sql.ErrNoRows):
            return ErrEditConflict
        default: 
            return err
        }
    }
}
```

As the final step -- need to change our `updateMovieHandler`so that it checks for an `ErrEditConflict`error and calls the `editConflictResponse()`if necessary.

```go
func (app *application) updateMovieHandler(w http.ResponseWriter, r *http.Request) {
    err = app.models.Movies.Update(movie)
    if err != nil {
        switch{
            case errors.Is(err, data.ErrEditConflict):
            app.editConflictResponse(w, r)
        default:
            app.serverErrorResponse(w, r)
        }
        return
    }
    //...
}
```

#### Round-trip locking

One of the nice things about the optimistic locking pattern -- can extend it to the client passes the version number that they expect in an `IF-NOT-MATCH`or `X-Expected-Version`header.

### Managing SQL Query Timeouts

Have been using Go’s `Exec()`and `QueryRow`to run our SQL queries. Note that Go also provides *context-aware* variants of those two methods -- `ExecContext()`and `QueryRowContext()`-- these variants accept a `context.Context`instance as the first parameter which you can leverage to *terminate running dbs queries*.

This feature can be useful when you have a *SQL query* that is taking longer to run than expected - when this happens, it suggests a problem - either with that particular query or your dbs or application more generally -- and U probabley want to cancel the query, log an error for further investigation -- and returns a 500 response to the client.

#### Mimicking a long-running query

To help demonstrate how this all works -- start by adpating our dbs model’s `Get()`method so that it mimics a long-runing query. Specifically, update our SQL query to return a `pg_slieep(8)`value -- will make PostgreSQL sleep for 8 seconds before returning its results.

```go
query := `
		SELECT pg_sleep(8), id, created_at, title, year, runtime, genres, version
		from movies where id= $1
		`
var movie Movie

// Execute the query using the QueryRow() method, passing in the provided id value
err := m.DB.QueryRow(query, id).Scan(
    &[]byte{}, // add this line
    //...
)
```

If restart the app and make a request to the `GET /v1/movies/:id`endpoint, U should find that the request hangs for 8 seconds before you finally get a successful response.

#### Adding a query timeout

Now that you have got some code that mimics a long-running query, enforce a timeout so that the SQL query is automatically canceled if it doesn’t complete within 3 seconds -- need to: 

1. Use the `context.WithTimeout()`function to create a `context.Context`instance with a 3s timeout deadlien
2. Execute the SQL query using the `QueryRowContext()`passing the `context.Context`.

```go
ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
defer cancel()
err := m.DB.QueryRowContext(ctx, query, id).Scan(
    &[]byte{}, // add this line
    //...
)
//...
```

- `defer cancel()`line is necessary cuz it ensures that the resources associated with our context will always be released before the `Get()`method returns -- thereby preventing a memory leak. Without it, the resources won’t be released until either the 3 second timeout is hit or parent contet is canceled.
- The timeout countdown begins from the moment that the context is ceated using the `context.WithTimeout()`-- any time spent executing code between creating the context and calling `QueryRowContext()`will count the timeout.

After 3 seconds, the context timeout is reacehd and our `pq`dbs driver sends a cancellation singal to PostgeSQL. Terminates the running query, the corresponding resources are freed-up, and returns the error message that we see -- the client then send a `500 internal server Error`response.

#### Timeouts outside of PostgreSQL -- 

There is another important thing to point out here -- it’s possible that the timeout deadline will be hit before the PSQL query even starts -- If all those connections are  in-use -- then any additional queries will be *queued* by `sql.DB`until a connection becomes available. It’s also possible that the timeout deadline will be hit before a free dbs conenction even becomes available -- if this happens then `QueryRowContext()`will return a `context.DeadlineExceeded`error -- can demonstrate this in app by setting the maximum open conenctions.

#### Updating our Dbs model -- 

Then quicely update our dbs model to use a 3-second timeout deadline for all our operations -- like:

```go
// create a context with a 3s timeout
ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
defer cancel()

return m.DB.QueryRowContext(ctx, query, args...).Scan(
    &movie.ID,
    &movie.CreatedAt,
    &movie.Version,
)
// also for other methods
```

### Filtering, Sorting and pagination

In this section of the book going to focus on building up the functionlity for a new `v1/movies`endpoint, which will return the details of multiple movies in a JSON array. `listMoviesHandler`-- shows the details of all movies. Develop the functinality for this endpint incrementally, starting out by returning data for *all* movies and then gradually making it more useful and useable 

- Returns the details of multiple resources in a single JSON response.
- Accept and apply optinal filter parameters to narrow down the returned data set.
- Implementing full-text search on database fields using PSQL’s inbuilt functionality.
- Accept and safely apply sort parameters to change the order of results in the dataset.
- Develop a pragmatic, reusable, pattern to support pagination on large data sets.

### Parsing query string parameters

Going configure the `GET /v1/movies`so that a client can control which movie records are returned via *query string parameters*. `v1/movies?title=godfather&genres=crime,drama&page=1page_size=5&sort=-year`. So the first thing we are going to look at is *how to parse query string parameters*.

Can retreive the query string data from a request by calling the `r.URL.Query()`method. This returns a `url.Values`type -- which is basically a map holding the query string data. Can then extract values form this `map`using the `Get()`method, whcih will return the value for specific key as a `string`type or `“”`.

Then need to carry out extra post-procesing on some of these query string values too -- 

- The `genres`will potentially contain multiple comma-separated values - `generes=crime,drama`fore, want to just split thse values apart and store them in a `[]string`.
- The `page`and `page_size`will contain numbers, want to convert these query string values into Go `int`type.

In addition -- 

- There are some validation checks that will apply to the query string values
- Want our app to set some sensible *default values* in case parameters like `page`, `page_size`and `sort`.

#### Creating helper functions

To assist with this, going to create 3 new helper functions -- `readString()`, `readInt()`and `readCSV()`. Using these to extract and parse values from the query string.

```go
func (app *application) readString(qs url.Values, key string, defaultValue string) string {
	s := qs.Get(key)
	if s == "" {
		return defaultValue
	}
	return s
}

func (app *application) readCSV(qs url.Values, key string, defaultValue []string) []string {
	csv := qs.Get(key)
	if csv == "" {
		return defaultValue
	}
	return strings.Split(csv, ",")
}

func (app *application) readInt(qs url.Values, key string, defaultValue int,
	v *validator.Validator) int {
	s := qs.Get(key)
	if s == "" {
		return defaultValue
	}
	
	i, err := strconv.Atoi(s)
	if err != nil {
		v.AddError(key, "must be an integer value")
		return defaultValue
	}
	return i
}
```

