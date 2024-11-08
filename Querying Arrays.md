# Querying Arrays

Querying for elements of an array is designed to behave the way querying for scalar does, fore, if the array is a list of fruits -- like:

```js
db.food.insertOne({'fruit': ['apple', 'banana', 'peach']})
db.food.find({'fruit': banana}) // will successfully match
```

Note that can also query for it in much the ways we would if we have a document that lookedl ikt the document:

`{‘fruit’: ‘apple’, ‘fruit’: ‘banana’}`...

#### `$ALL`

If need to match arrays by more than one element, can use the `$all`-- this allows you to match a list of elements. FORE, suppose we create a collection with 3 elements -- like: All have a `apple`element in the array.

```js
db.food.find({fruit: {$all: ['apple', 'banana']}})
```

Order does not matter -- `banana`comes before the `apple`. Can also query by extact match using the entire array. And note that if you want to query for a specific element of an qrray, can specify an index using syntax like `key.index`:

```js
db.food.find({'fruit.2': 'peach'})
```

#### `$size`

A useful conditional for querying arrays is `$size`-- which allows U to query for arrays of given size like:

`db.food.find({‘fruit’: {$size:3}})`-- one common query is to get a range of sizes -- `$size`cannot be combined with another `$`conditions.

#### `$slice`

The optional second argument to `find`-- the `$slice`operator can be used to return a subset of elements for an array key. Fore: 

```js
db.blog.posts.findOne(criteria, {'comments': {$slice: [23,10]}}) // offset and number
```

Skip first 23 and return the 24 through 33. Unless otherwise specified, all keys in a document are returned when `$slice`is used.

#### Array and Range query interactions

Scalars in document must match each clause of a query’s criteria. If you wanted to find all document including x is number or array -- between 10 and 20,  if run:

```js
db.test.find({'x': {$gt: 10, $lt: 20}}) // return 15 and [5, 25]
```

Neither 5 nor 25 between 10 and 20, but docuemnt is just returned because 25 matches the first clause and 5 matches the second clause. That makes range range queries against array essentially useless.

Can use the `$elemMatch`to force MongoDB to compare both clauses with a single array element, however, the catch is that `$elemMatch`won’t match noarray elements. If have index like this:

```js
db.test.find ({x: {$gt: 10, $lt:20}}).min({'x': 10}).max({x: 20})
```

### Queryin gon embedded documents

There are two ways of querying for an embedded document -- querying for the whole document or querying for its individual k/v pairs. Fore:

```json
{
    "name": {
        "first": "Joe",
        "last": "Shmoe"
    },
    "age": 45
}
```

Can query like:

```js
db.people.find({'name': {first: 'Joe', 'last': 'Schmoe'}})
```

For this, a query for a full sub-document must exactly match the subdocument -- if add a middle name - and also this query is order-sensitive. So Just like:

```js
db.people.find({'name.first': "Joe"})
```

This *dot notation* is the main difference between query documents and other document types. Query documents can contain dots -- reach into an embedded document. To correctly group criteria without needing to specify every key, using `$elemMatch`either.

```js
{comments: {$elemMatch: {'body': {$regex: 'dolor'}, 'author': 'Joe'}}}
```

#### `$where`queries -- 

K/V pairs are fairly expressive way to query, but there are some queries that they cannot represent -- there are `$where`claues -- which allow U to execute *arbitrary Js as part of your query*.

The most common case for using `$where`is to compare the values for two keys in a document -- fore, suppose we have documents that look like this: Like to return documents where any two of the fields are equsl, fore in the second document, have the same value for `spinach`and `Waltermelon`.

```js
db.foo.find({'$where': function() {
    for(let current in this) {
        for(var other in this) {
            if(current != other&& this[current]==this[other]){
                return true;
            }
        }
    }
    return false;
}})
```

`$where`queries should not be used unless *strictly necessary* -- they are much slower than regualr queries. Each document has to be converted from BSON to a Js object and then run through the `$where`expression.

## Using `sync.WaitGroup`

`sync.WaitGroup`is a mechanism to wait for `n`operations to complete -- generally, use it to wait for `n`goroutines to complete - Internally, a `sync.WaitGroup`just holds an internal counter initilaized by default to 0, can increment this counter using the `Add(int)`method and decrement it using `Done()`or Add with just *negativae* value. If want to wait for the counter to be equal to 0, have to use the `Wait()`that is blocking. fore:

```go
func main(){
	wg := sync.WaitGroup{}
	var v uint64
	for i:=0; i<3; i++ {
		go func() {
			wg.Add(1)
			atomic.AddUint64(&v, 1)
			wg.Done()
		}()
	}
	wg.Wait()
	fmt.Println(v)
}
```

If run this example, get a non-deterministic value -- the code can print any value from 0 to 3. Also, if enable the `-race`flag, Go will even catch a data race. The problem is that `wg.Add(1)`is called within the newly created goroutine, not in the parent goroutine, hence, there is no guarantee that we have indicated to the wait group that wean to wait for 3 goroutine before calling `wg.Wait()`.

So the parent goroutine is already unblocked - the last goroutine is executed after the two first goroutines have already called `wg.Done()`. When dealing with goroutines, it’s crucial to remember that the execution isn’t deterministic without sync -- fore, the following code could print either `ab`or `ba`. fore:

```go
go func(){fmt.Print("a")}()
go func(){fmt.Print("b")}()
```

Both goroutines can be assigned to different threads, and there is not guarantee wihcih thread will be executed first. For this, the CPU has to use a *Memory fence* to ensure order -- Go provides different sync techniques for implementing memory fences. Fore:

```go
wg := sync.WaitGroup{}
var v uint64
wg.Add(3)
for i:=0; i<3; i++ {
    go func() {}()
}
```

Can call `wg.Add()`during each loop iteration before spinning up the child goroutines.

### About `sync.Cond`

Among the sync primitives in the `sync`-- The example in this implemetns a donation goal -- an app that raises alerts whenever specific goals are reached -- will go through a concrete example to show when `sync.Cond`can be helpful and how to use it -- The example in this implements a goal -- will have one goroutines will receive updates and print a message whenever a specific goal is reached -- fore, one goroutine is waiting for `$10`donation goal, whereas another is waiting for a `$15`denotation goal.

```go
type Donation struct {
	mu      sync.RWMutex
	balance int
}

func main() {
	donation := &Donation{}

	f := func(goal int) {
		donation.mu.RLock()
		for donation.balance < goal {
			donation.mu.RUnlock()
			donation.mu.RLock()
		}
		fmt.Printf("$%d reached \n", donation.balance)
		donation.mu.Unlock()
	}

	go f(10)
	go f(15)

	go func ()  {
		for {
			time.Sleep(time.Second)
			donation.mu.Lock()
			donation.balance++
			donation.mu.Unlock()
		}
	}()
}
```

Protected the access to the shared `donation.balance`variable using the mutex -- if run this, just -- the main issue and what makes this terrible -- it is the busy loop -- each listener goroutine keeps looping until its donation goal is met, which wastes a lot fo CPU cycles and makes the CPU usage gigantic. Fore using Channels like:

```go
type Donation struct {
	ch      chan int
	balance int
}

func main() {
	donation := &Donation{ch: make(chan int)}

	// listener goroutines
	f := func(goal int) {
		for balance := range donation.ch {
			if balance >= goal {
				fmt.Printf("Reached goal of $%d!\n", goal)
				break
			}
		}
	}
	go f(10)
	go f(50)

	// update goroutine
	for {
		time.Sleep(time.Second)
		donation.balance++
		donation.ch <- donation.balance
	}
}

```

## Creting the API handler

Head back to our `cmd/api/movies.go`file and update it to include the brand-new `updateMovieHandler`handler like: Nice thing about this handler is that we’ve already laid all the groundwork for it -- our work here is mainly just a case of linking up the code and helper functions that already written to handle the request.

1. Extract the ID
2. fetch the corresponding movie record fromt he dbs using the `Get()`method that we made in the prevoius chapter.
3. Read the JSON request body containing the updated movie data into an `input`struct
4. Copy the data across from the `input`struct to the movie record
5. Check that the updated movie record is valid using the `data.ValidateMovie()`
6. Call the `Update()`
7. Write the updated movie data in JSON response using the `app.writeJSON()`helper

```go
func (app *application) updateMovieHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	// Fetch the existing movie record from the dbs, sending a 404 if couldn't find
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

	// declare an input struct to hold expected data from the client
	var input struct {
		Title   string       `json:"title""`
		Year    int32        `json:"year"`
		Runtime data.Runtime `json:"runtime"`
		Genres  []string     `json:"genres"`
	}

	// read the JSON request data into the input struct
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	// then copy the values from the request body to the appropriate fields
	movie.Title = input.Title
	movie.Year = input.Year
	movie.Runtime = input.Runtime
	movie.Genres = input.Genres

	// Validate the updated movie record, sending the client a 422
	v := validator.New()
	if data.ValidateMovie(v, movie); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	// pass the updated to our new Update() method
	err = app.models.Movies.Update(movie)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Write the updated in a json response
	err = app.writeJSON(w, http.StatusOK, envelope{"movie": movie}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

At last, to finish off, also need to update our app routes to include the new endpoint like:
`router.HandlerFunc(http.MethodPut, "/v1/movies/:id", app.updateMovieHandler)`

#### Using the new endpoint

And with that, now ready to try -- continue the example gave just like:

```json
{"title":"Black Panther","year":2018,"runtime":"134 mins","genres":["sci-fi","action","adventure"]}
```

Should also be able to verify that the change has been persisted by making a `GET /v1/movies/2`request again like:

### Deleting a Movie

in this chapter, add our final CURD endpoint so that a client can *delete* a specific movie form our system. 
`DELETE /v1/movies/:id`-- `deletemovieHandler`-- 

- If a movie with the `id`provided in the URL exists in the dbs, we want to delete the corresponding record and return a success message to the client.
- If the movie `id`doesn’t exist, want to return a *404 not Found* response to the client.

In this case, the SQL query returns no rows, so it’s appropriate for us to use Go’s `Exec()`method to execute it. One of the nice things about the `Exec()`is that it returns a `sql.Result`object, which contains information about the *number of rows that the query affected*. In our scenario here, this is really useful info -- 

- If the number of rows affected is 1 -- then we know that the movie existed in the table and has now been deleted, can send the client a success message.
- Conversely, if the number of rows affected is 0 -- now that no movie that the `id`existed, 404 returned

#### Adding the new endpoint

Go ahead and update the `Delete()`method in our dbs model, essentailly, we want this to execute the SQL query and return `ErrRecordNotFound`if the number of rows affected is 0 like so:

```go
func (m MovieModel) Delete(id int64) error {
	// return an ErrErrorNotFound if the movie id is less than 1
	if id < 1 {
		return ErrRecordNotFound
	}

	// construct the SQL query statement to delete the record
	query := `delete from movies where id = $1`

	// Execute the SQL query using `Exec()`, passing in the id value as the query
	// for the placeholder parameter like:
	result, err := m.DB.Exec(query, id)
	if err != nil {
		return err
	}

	// call the RowsAffected() method on the sql.Result object like:
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	// if nmo rows affected, know that the movies didn't contain a record
	// with the provided id
	if rowsAffected == 0 {
		return ErrRecordNotFound
	}
	return nil
}
```

Once that is done, go to the `api/movies.go`file and add a new `deleteMovieHandler`-- need to read the movie ID from the request URL, calling the `Delete()`that we just made, based on the return value from `Delete()`.

```go
func (app *application) deleteMovieHandler(w http.ResponseWriter, r *http.Request) {
	// extract the movie ID from the URL
	id, err := app.readIDParam(r)
	if err != nil {
		app.notFoundResponse(w, r)
		return
	}

	// delete the movie from the dbs, sending a 404 if there isn't match
	err = app.models.Movies.Delete(id)
	if err != nil {
		switch {
		case errors.Is(err, data.ErrRecordNotFound):
			app.notFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// return a 200 ok
	err = app.writeJSON(w, http.StatusOK,
		envelope{"message": "movie successfully deleted"}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

At last, need to hook up the new to the routes.go file.
