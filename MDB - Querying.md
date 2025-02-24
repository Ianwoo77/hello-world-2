# MDB - Querying

This looks at querying in details -- main areas covered as follows -- 

- Can query for ranges, set inclusion, indqualities, and more by using `$`conditions.
- Discusses how to prepare and execute queries in MDB

MDB queries are based on JSON documents in which U write your criteria in the form of valida documents. with the data stored in the form of Json-like documents, the queries seem more natrual and readable. And the following diagram is an example of a simple MDB query that finds all the documents where the `name`like:

```js
db.users.find({name:'David'})
```

```sql
select * from users where name = 'David'
```

```js
use sample_mflix
db.comments.find({'name': 'Lauren Carr'})
```

The `pretty()`function can be used to print a well-formed results. And `findOne()`returns only one matching record -- this is very useful when are looking to isolate a specific record -- the syntax of this func is similar to the syntax of `find()`like: On a Mongo shell, can capture the cursor returned by the `find()`in a variable. By using this variable, can iterate through the elements -- in the following snippet -- executing `find()`query and capturing the resulting cursor in a variable named `comments`like:

```js
let comments = db.comments.find({'name': 'Lauren Carr'});
comments.next()
```

The `next()`function moves the cursor to the first document in the collection, and that document is returend, when called again, the cursor will be moved to the second position and the second will be returned. When reaches the last document in the collection, calling `next()`will result in an error -- to avoid this, the `hasNext()`function can be used before calling next() -- the `hasNext()`returns a `true`if the collection has a document at the next index position.

#### Choosing the Fields for the Output

Can be like:

```js
db.comments.find(
    {name: 'Lauren Carr'},
    {name:1, date:1, _id:0}
)
```

#### Finding the distinct Fields

The `distinct()`function is used to get the distinct or unique values of a field with or without query criteria. For the purpose of this example, will use the `movies`collection -- each movie is assigned an audience of this exmple.

```js
db.movies.distinct('rated')
```

The `distinct()`can also be used along with a query condition. The following finds all the unique ratings the film that were released in 1994 have received:

```js
db.movies.distinct('rated', {year: 1994})
```

Note that the first argument to the function is the name of the required field, while the second is the query expressed in the document format.

#### Counting the Documents

In some cases, MDB collections have 3 functions that return the counnt of the documents in the collection 

- `count()`-- which is used to return the count of document with the collection, or a query expression.

  ```js
  db.movies.countDocuments({num_mflix_comments: 5})
  ```

- after Mdb 4, `count()`is separeted into two different -- `countDocuments()`-- this return the count of the documents are matched by the given condition.

  ```js
  db.movies.countDocuments({year:1999})
  // note that the query expression is mandatory
  db.movies.countDocuments({})
  ```

- `estimatedDocumentCount()`-- this returns the approximate or estimated count  -- The count is always based on the *collection’s metadata*.

### Conditional Operators

Now that have learned how to query -- 

- `$eq`-- just like `db.movies.find({num_mflix_comments: {$eq:5}})`

- `$ne`-- `db.movies.find({num_mflix_comments: {$ne:5}})`

- `$gt`, `$gte`, `$lt`, `$lte`

- `$in`and `$nin`-- What if a user wants a list of all movies have been rated , can use the `$in`operator, along with multiple values given in the form of an array. like:

  ```js
  db.movies.find({rated: {$in: ['G', 'PG', 'PG-13']}})
  ```

#### Querying for Movies of an Actor

Fore, working wor a popular entertainment issue is dedictaed to Leonardo - In this case, you will write queries to count documents by given conditions, find distinct documents, and project different fileds in the documents, query on the `sample_mflix`movies collections for the following like:

```js
// 1. Find the movies which ... appears by using the cast field :
db.movies.countDocuments({cast: 'Leonardo DiCaprio'})
// 2. the genres of the movies in the collection are represtned by the genres field
db.movies.distinct('genres', {cast: 'Leonardo DiCaprio'})
// 3. Using movie titles, can now find the year of release for each the actor's movies
db.movies.find(
    {cast: 'Leonardo DiCaprio'},
    {'title':1, year: 1, _id:0}
)
// 4. find the number of movies has directed -- like:
db.movies.find(
    {directors: 'Leonardo Dicaprio'}
)
// 5. write query that counts the movies that matching: 
```

## Slices and Memory Leaks

This just shows that sliceing an existing slilce or array may lead to memory leaks in some conditions.

#### Leaking capacity

Implementing a custom binary protocol -- A message can contain 1M bytes, and the first 5 represent the message type. In the code, consume these and for auditing purposes like:

```go
func consumeMessages() {
    for {
        msg := receiveMessages()
        storeMessageType(getMessagetType(msg))
    }
}
func getMessageType(msg []byte) []byte {
    return msg[:5]
}
```

The `getMessageType`computes the message type by slicing the input slice. And when deploy this, notice that our app consumes about 1G of memory. The slicing operation `msg`using `msg[:5]`create a 5-length slice, its capacity remains the same as the initial slice -- the remaining elements are still allocated in memory. Even if eventually `msg`is not referenced -- look an example with a large message length of 1M bytes.

```go
func getMessageType(msg []byte) []byte {
    msgType = make([]byte, 5)
    copy (msgType, msg)
    return msgType
}
```

As a rule of thumb, Just remember that slicing a large slice or array can lead to potential high memory consumption.

#### Slice and pointers

Have seen that slicing can cause leak cuz of the slice cap -- elements -- which are still part of the backing array but outside the length range -- fore:

```go
type Foo struct {
    v []byte
}
```

1. want to allocate a slice of 1000 `Foo`
2. Iterate over each `Foo`, and for each one, allocate 1M for the `v`slice
3. Call `KeepFirstTwoElementsOnly`.

```go
func main(){
    foos := make([]Foo, 1000) 
    for i:=0; i<len(foos); i++ {
        foos[i]= Foo{
            v: make([]byte, 1024*1024) // allocates a slice of 1MB
        }
    }
    two := keepFirstTwoElementsOnly(foos)
    runtim.GC()
    runtime.KeepAlive(two)
}
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    return foos[:2]
}
```

In this, allocate the foo slics, allocate a slice of 1M for each element. Note that GC did not collect the remaining 998 elements after the last step.

If the element is a pointer or a struct with pointer fields, the elements won’t be reclaimed by the GC. In our example, cuz `Foo`contains a slice, the remaining 998 elements and their slices aren’t re-claimed. So:

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    res := make([]Foo, 2)
    copy(res, foos)
    return res
}
```

### Map initialization

An issue similar to one we saw with slice initialization -- using maps -- 

Concepts -- A `map`provides an unordered collection of key-value pairs in which all the keys are distinct. A map is based on the hash table data structure, internally, a hash table is just an array of buckets, and each bucket is a pointer to an array of key-value pairs. An array of 4 elements backs the hash table.

Each operation is done by associating a key to an array index -- this step relies on a *hash function*. This func is just stable cuz we want it to return the same bucket, given the same key.

Note that in the case of insertion into a bucket that is already full -- Go creates another bucket of 8 elements and links the prevous to it. Regarding reads, updates... Go must calculate the corresponding array index.

#### Initialization

To understand the problems related to inefficient map initialiation -- create a `map[string]int`type like:

```go
m := map[string]int {
    "1": 1, "2":2, "3":3,
}
```

Internally, this is backed by an array consisting of a single entry -- single bucket here. If add 1M elements -- a single entry won’t be enough. When a map grows, it doubles its number of buckets -- What are the conditions for a map to grow -- 

- The averge number of itmes in the buckets is greater than a constant value.
- Too many buckets have overflowed

In the worst-case scenario, inserting a key can be an O(n) operation, with `n`being the total number in the map. The idea is similar for maps and slices --can use the `make`built-in function to provide an initial size when creating a map.

`m := make(map[string]int, 1000000)`

Note that with a map, can give the built-in function `make`only an initial size and **Not** a capacity. By specifying a size, provide a hint about the number of elements expected to go into the map. Internally, the map is created with an appropraite number of buckets to store 1M elemens.

### Maps and memory leaks

When working with maps in Go -- need to understand some important characteristics of how a map grows and shrinks. 

```go
m := make(map[int][128]byte)
```

Each value of `m`is now an array of 128bytes, If:

```go
n := 1000000
m := make(map[int][128]byte)

for i:=0; i< n; i++ {
    m[i]= randBytes()
}

for i:=0; i<n; i++ {
    delete(m, i)
}
runtime.GC()
```

At first, the heap size is minimal, then it grows significant ly after having added 1M elements to the map. The reason is that the number of buckets in a map **cannot shrink**. Therefore, removing elements from a map doesn’t impact the number of existing buckets. For this: just: `map[int]*[128]byte`.

### Fanning and out

If want to speed things up, can perform the downloads concurrently by load-balancing the URLs to multiple goroutines, can create a *fixed* number of goroutine. In Go -- A fan-out concurrency pattern is when multiple goroutines read from the *same channel*. The concurrent goroutines are just load-balancing the URLs sent from the `generateUrls`goroutine -- when a `downloadPage`is free, will read the *next URL* from the shared channel.

Also note -- since concurrent processing is non-determinstic -- some messages will be processed quicker than others. Resulting in messages being processed in an unpredictable order.

```go
func main(){
    quit:= make(chan int)
    defer close(quit)
    urls := generateUrls(quit)
    pages := make([]<-chan string, downloader)
    for i:=0; i<downloaders; i++ {
        pages[i]= downloadPages(quit, urls)
    }
    // ....
}
```

So the fan-out pattern in the app has created a problem -- the outputs of our download goroutines are in separate channels. How can we connect them to the single input channel -- To keep the pattern, need a mechanism that merges the output messages from the different channels into a single output channel -- 

DEF -- In Go, an *fan-in* concurrency pattern occurs when we merge the content from *multiple* channels into one.

Since goroutines are very lightweight, can implement this fan-in pattern as a single unit by creating a set of goroutines -- one per output channel, and having each goroutine feed a common channel. Each goroutine listens to messages from the output channel, and when a message arrives, it simply forwards it to the common channel.

And, when have a many-to-one fan-in scenario, must make a decision about when to close the common channel. The solution is to only close the common channel when *all* the goroutines have noticed that the channels from which they are consuming have been closed. Like:

```go
func FanIn[K any] (quit <-chan struct{}, allChannels ...<-chan K) chan K {
    wg := sync.WaitGroup{}
    wg.Add(len(allChannels))
    output := make(chan K)
    for _, c := range allChannels {
        // starts a goroutine for every input channel
        go func(channel <-chan K) {
            defer wg.Done()
            for i:= range channel {
                select {
                case output<-i:
                case <-quit:
                    return
                }
            }
        }(c)
    }
    go func() {
        wg.Wait()
        close(output)
    }()
    return output
}

func main() {
    //...
    results := extractWords(quit, FanIn(quit, pages...))
    for results := range results {
        fmt.Println(result)
    }
}
```

#### Flushing results on close

we haven’t really done anything interesting with our URL download app -- apart from extracting the words, what if we use the downloaded web pages for something useufl -- how about trying to find the 10 longest words in the documents for this example -- This task is easy if continue to follow the pipeline-building pattern, need to add a new goroutine that accepts an input channel and returns an output one. Fore `longestWords()`.

It is slightly different fro the other goroutines -- it accumulates a set of unique words in its memory, once it has read all the words from the web pages and receives the close message, it will revies this tset and ouput 10 longest ones. For this, use a `map`to strore the set of unique words. Like:

```go
func longestWords(quit <-chan struct{}, words <-chan string) <-chan string {
	longWords := make(chan string)
	go func() {
		defer close(longWords)
		uniqueWordsMap := make(map[string]bool)
		uniqueWords := make([]string, 0)
		moreData, word := true, ""
		for moreData {
			select {
			case word, moreData = <-words:
				if moreData && !uniqueWordsMap[word] {
					uniqueWordsMap[word] = true
					uniqueWords = append(uniqueWords, word)
				}
			case <-quit:
				return
			}
		}
		sort.Slice(uniqueWords, func(a, b int) bool {
			return len(uniqueWords[a]) > len(uniqueWords[b])
		})
		longWords <- strings.Join(uniqueWords[:10], ", ")
	}()
	return longWords
}
```

The goroutine stores all the unique words on a map and a list. Once the input closes, meaning there are no more messages, the goroutine sorts the list of unique by length.
`results := longestWords(quit, extractWords(quit, FanIn(quit, pages...)))`added to the `main`. When we run the listings  together, the pipeline will find the longest words on the downlaoded documents and ouput them on the console.

## Automatic form parsing

Another thing we can do to simplify our handlers is use a 3rd-party package like `gorilla/schmea`to automatically decode the form data into `createSnippetForm`struct -- using an automtic decoder has lots of forms.

```sh
go get github.com/go-playground/form/v4@v4
```

#### Using the form decoder

To get this working, the first thing need to do is initialize a new `*form.Decoder`instance in our `main.go`file and make it available to our handlers as a dependency like:

```go
type application struct {
	errorLog      *log.Logger
	infoLog       *log.Logger
	snippets      *models.SnippetModel
	templateCache map[string]*template.Template
	formDecoder   *form.Decoder
}

formDecoder := form.NewDecoder()

app := &application{
    errorLog, infoLog,
    &models.SnippetModel{DB: db},
    templateCache,
    formDecoder,
}

srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  app.routes(),
}
```

Next, go to our `handlers.go`file and update it to use this new decoder like:

```go
// Update our struct to include struct tags which tell the decoder how to map HTML form values into the different struct fields.
type snippetCreateForm struct {
	Title               string `form:"title"`
	Content             string `form:"content"`
	Expires             int    `form:"expires"`
	validator.Validator `form:"-"`
}

func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    //...
    // Declare a new empty instance of the snippetCreateForm type
	var form snippetCreateForm
	
	// Call the `Decode()` method of the form, passing in the current request and
	// Pointer to our snippet struct
	err = app.formDecoder.Decode(&form, r.PostForm)
	
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}
    // ...
}
```

We can use simple struct tags to define a mapping between our HTML form and the *destination* data fields, and unpacking the form dta to the destination now only requires us to write a few lines of code.

Importantly, type conversions are handled automatically, Can see that in the code -- where the `expires`value is automatically mapped to an `int`.

#### Creating a `decodePostForm`helper

To assist with this, create a new `decodePostForm()`helper which does 3 things -- 

- Calls `r.ParseForm()`on the current request
- Calls `app.formDecoder.Decode()`to unpack the HTML form data to a target destination.
- Checks for a `form.InvalidDecoderError`and triggers. In the `helpers.go`file:

```go
// Create a new decodePostForm() helper method -- the second parameter, dst,
// is the target dest that we want to decode the form data into.
func (app *application) decodePostForm(r *http.Request, dst any) error {
	// Call ParseForm() on the request
	err := r.ParseForm()
	if err != nil {
		return err
	}

	// call Decode() on our instance, passing the target destination as
	// first parameter.
	err = app.formDecoder.Decode(dst, r.PostForm)
	if err != nil {
		// If try to use an invalid destination, the `Decode()`method will return an error
		// with the type `*form.InvalidDecoderError`, need to use the errors.As()
		//to check for this and raise a panic rather than returning the error
		var invalidDecoderError *form.InvalidDecoderError
		if errors.As(err, &invalidDecoderError) {
			panic(err)
		}

		// for all other errors, just return
		return err
	}
	return nil
}
```

With this done, can make the final simplification to our `createSnippetPost`handler. 

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	var form snippetCreateForm
	err := app.decodePostForm(r, &form)

	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}
    // ...
}
```

### Stateful HTTP

A nice touch to improve our user experience would be to display a one-time confirmation message which the user sees after they have added a new snippet.

A confirmation message like this should only show up for the user once and no other users should see the message. To make this work, need to start *sharing data between HTTP request* for the same user. The most common way to do this is to implement a *session* for the user -- in this:

- What *session managers* are available to help us implement sessions in Go.
- How to *use sessions* to safely and securely share data between requests for a particular user.
- How can customize session behavior.

Choosing a session manager -- There are a lot of *security considerations* when it comes to working with sessions, and proper imp is no trivial. It’s a good idea to use an existing, well-tested 3rd-party package -- recommend using either the `gorilla/sessions`or `alexedwards/scs`

- `gorialla/sessions`is the most established and well-known ones, simple and easy-to-use API. it doesn’t provide a mechanism to renew session IDs -- which is necessary to reduce risks.
- `alexedwards/scs`-- store session data *server-side only*. It supports automatic loading and saving of session data via middleware, has a nice interface for type-safe manipulation of data.

So -- if want to store session data *client-side* in a cookie then `gorilla/sessions`is good, otherwise, `alexwards/scs`is generally the better option due to the ability to renew session IDs.

```sh
go get github.com/alexedwards/scs/v2@v2
go get github.com/alexedwards/scs/mysqlstore
```

### Setting up the session manager

Run through the process of setting up and using the `alexedwards/scs`package -- but if are going to use in a production app The first thing need to do is create a `session`table in the dbs to hold the session data for our users.

```sql
CREATE TABLE sessions
(
    token  CHAR(43) PRIMARY KEY,
    data   BLOB         NOT NULL,
    expiry TIMESTAMP(6) NOT NULL
);

CREATE INDEX sessions_expiry_idx ON sessions (expiry);
```

- The `token`will contain unique, randomly-generated identifier for each session
- The `data`will contain the actual session data that you want to share between HTTP requests.
- The `expiry`will contain an expiry time for the session. The `scs`package will automatically delete expired sessions from the `sessions`table so that it doesn’t grow too large.

Then need to do is to establish a *session manager* in the `main.go`file and make it available to our handlers via the `application`struct. The session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving session data.

