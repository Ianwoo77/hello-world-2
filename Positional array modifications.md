# Positional array modifications

Array manipulation becomes a little tricker when U have multiple vlaues in an array and want to modify some of them. There are just two ways to manipulate values in arrays -- by position by by using the `$`operator. Arrays use 0-base indexing, and elements can be just selected as though their index were document key. Fore, suppose we have a document containing an array with a few embedded documents like:

```js
db.blog.updateOne({'post': post_id},
                 {$inc: {"comments.0.votes": 1}})
{
  $set: {
		"comments.1.emal": "bender@example.com"
  },
}
```

This positional operator updates only the first match -- thus, If want to get around this, MongodB has optional operator -- that figures out which element of array the query document matched and updates that element fore:

```js
{"comments.email": {"$regex": "bender", "$options": "i"}}
```

```js
db.blog.updateOne({'comments.author': 'john'}.
                 {"$set": {'comments.$.author', "jim"}})
//...
db.posts.updateOne({"comments.emal": {$regex: 'bender', $options: 'i'}},
                   {$set :{'comments.$.emal': '@leela@example.com'}})
```

This positional operator updates only the first match, thus, if had one comment, his name would be changed only for the first comment he left -- 

MongoDB introduced another option for updating individual array -- `arrayFilters`-- this option enables us to modify array elements mathching particular criteria --  Like:

```js
db.blog.updateOne({"post": post_id}.,
                 {$set: {comments.$[elem].hidden: true}},
                 {arrayFilter: [{'elem.votes': {$lte: -5}}]})
```

### Upserts

An *upsert* is a special type of update, if no document is found that matches the filter, a new document will be creted by combining the criteria and udpate the documents. If a matching is found, just updated normally. Upserts can be handy cuz they can eliminate the need to seed your collection -- can often have the same code create and update documents. For, if were to write -- find the URL and increment the number of views or create a new document if the URL doesn’t exist. Fore:

```js
// check if we have an entry for this papge
blog = db.analytics.findOne({ur: '/blog'});
// if do, add one to the nubmer views and save
if(blog) {
    blog.pageViews++;
    db.analystics.save(blog);
}
// othewise, create a new document for this page
else{
    db.analytics.insertOne({url: '/blog', pageviews: 1})
}
```

This just means that we are making a round trip to the dbs, plus sending an update or insert, everytime someone visits a page -- if we are running this code in multiple processes, also ubject to a race condition where more than one document can be inserted to a given URL.

can eliminate the race condition and cut down the amount of code by just sending an upsert to the dbs.

```js
db.users.updateOne({'rep':25}, {$inc:{'rep':3}}, {'upsert': true})
```

The upsert just *creates* a new document with a `rep`of 25 and then increments that by 3, giving us a document where `rep`is just 28 -- if the upsert option were not specified, `{rep:25}`would not match, so nothing would happen. If run again it will create another new document -- this is cuz the criterion does not match the only document in the collection -- rep is 28.

## Puzzled about Chnanel Size

When create a channel using the `make`built-in function, the channel can be either unbuffered or buffered. Related to this -- two mistakes happen fairly frequently -- being confused about when to use one or the other, and if we use a buffered, what size to use -- The core concept -- an unbuffered channel is a channel without any capacity, can be creted by either omitting the size or providing a 0 size like: 

```go
ch1 := make(chan int)
ch2 := make(chan int, 0)
```

Using an unbuffered channel *async* channel the sender will just block until the receiver receives data form the channel. Conversely, a buffered channel has a capacity, and it must be created with a szie greater then or equal 1. With a buffered one, a sender can send messages while the channel isn’t full.

```go
ch3 := make(chan int, 1)
ch3 <- 1
ch3 <- 2 // block
```

Take a step back and discuss the fundamental differences between these channel types -- Channels are concurrency abstraction to enable communication among goroutiens -- but what about sync -- in concurrency, sync means can guarantee that multiple goroutines will be in a known state at some point. Fore, a mutex provides sync cuz it ensures that only one goroutine can be in a critical section at the same time.

- An unbuffered channel enables sync -- have the guarantee that two goroutines will be in a known state, one receiving and another sending a message.
- A buffered one doesn’t provide any strong sync -- indeed, a producer can send a message and then continue its execution if the channel isn’t full. The only guarantee is that a goroutine won’t receive a mesage before it is sent.

Essential to keep in mind this fundamental distinction -- both channel types enable communication, but only one provides sync -- if need sync , must use unbuffered one -- Unbuffered channels may also be easier to reason about -- buffered channels can lead to obscure deadlocks that would be immediately apparent with unbuffered channels.

And there are other cases where unbuffered ones are preferable -- fore, in the case of a notification channel where the notification is handled via channel closure -- `close(ch)`-- using a buffered channel wouldn’t bring any benefits.

So, what if need a buffered one -- what size we provide -- the default value we should use is minimum 1 -- may approach the problem from this standpoint -- is there any good reaspon *not to use value of 1*.

- while using a worker pooling-like pattern -- meaning spinning a fixed number of goroutines that need to send data to a shared channel -- in this case, can tie the channel size to number of goroutines created.
- When using channle for rate-limiting problems.

## Executing the SQL query

Throughout this proj stick with using Go’s `database/sql`package to execute our dbs queries, rather then using a 3rd-party ORM or other tool. Normally, using Go’s `Exec()`method to execute an `INSERT`statement against a dbs table. But cuz our SQL query is returning a single row of data -- using `RETURNING`clause like:

```go
func (m MovieModel) Insert(movie *Movie) error {
    query := `INSERT INTO... RETURNING id, created_at, version`  // version cuz default value set
    args := []any {Movie.Title, movie.Year, ...}
    return m.DB.QueryRow(query, args...).Scan(&movie.ID, ...)
}
```

Cuz the `Insert()`method signature takes a `*Movie`pointer as the parameter, when we call `Scan()`to read in the system-generated data we are updating the values at the location the parameter points to. Essentially, our `Insert()`method mutates the Movie that we passed to, and adds the system-generated values to it.

The next thing -- placeholder parameter inputs -- which declare in an `args`slice like:

```go
args := []any{Movie.Title, ....}
```

Storing the inputs in a slice isn’t strictly necessary, but as mentioned in the code comments above it’s anice pattern thatn can help the clarity of your code, personally, usually do this for SQL queries with more than 3 placeholder parameters. Aslo, notece the final value in the slice -- in order to store our `movie.Genres`-- `[]string`in the dbs, need to pass through via the `pa.Array()`adapter functin before executing SQL query.

`args := []any{..., pq.Array(movie.Genres)}`

Behind the scenes, the `pq.Array()`just adpater takes our `[]string`slice and convert it to a `pq.StringArray`type -- implements the `driver.Valuer`and `sql.Scanner`interfce necessary to translate our native `[]string`slice to an dfrom a value that PSQL can understand and store in a `text[]`array column. Can also use the `pq.Array()`in the same way with the `[]boo....`

#### Hooking it up to our API handler

Now that the exciting -- to the `createMovieHandler`so that our POST works in full.

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
	// ...

	v := validator.New()
	if data.ValidateMovie(v, movie); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}

	// call the Insert() method on our movies model, passing in a pointer to the
	// validated movie struct, create a record in the dbs and update the movie
	err = app.models.Movies.Insert(movie)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// When sending an HTTP response, want to include a location header to let the client
	// know which URL they can find the newly-created resource at.
	headers := make(http.Header) // map[string][]string
	headers.Set("Location", fmt.Sprintf("/v1/movies/%d", movie.ID))

	// then write a json response with a 201
	err = app.writeJSON(w, http.StatusCreated, envelope{"movie": movie}, headers)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

Then restart the API, then open up a second terminal window and make the following request to the post.

```go
func (m MovieModel) Insert(movie *Movie) error {
	query := `
	INSERT INTO movies (title, year, runtime, genres)
	VALUES ($1, $2, $3, $4)
	RETURNING id, created_at, version`
	// check an args slice containing the values for the placeholder parameters from
	// the movie struct, declaring this slice immediately next to our SQL query helps
	// to make it nice and clear
	args := []any{movie.Title, movie.Year, movie.Runtime, pq.Array(movie.Genres)}

	// using the QueryRow() to execute the sql query
	err := m.DB.QueryRow(query, args...).Scan(&movie.ID, &movie.CreatedAt, &movie.Version)
	if err != nil {
		println(err.Error())
		return err
	}
	return nil
}
```

