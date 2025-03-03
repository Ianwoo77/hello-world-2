# CURD Dcouments

How to insert a single document or a batch of multiple documents into MDB collection -- Add or autogenerate an `_id`field -- replacing existing documents...

#### Inserting Documents

In this, will learn to insert a new documents into a MDB collection. Mdb collections provides a function named `insert()`which is used to create a new document in a collection. `insertMany()`function specifically meant for inserting multiple documents into a collection.

Inserting duplicate keys -- in any dbs system, a PK is always unique in the table -- similarly, Mdb `_id`field is a PK, and so it must be unique too, if try to insert a document whose key is already present, get *Duplicate key error*. And the operation of bulk inssert also fails when one or more of the documents in the given array has duplicate `_id`.

Inserting without `_id`While working on datasets, our documents will have unique fields, that acan be used as primary keys -- pks are the ones that can uniquely identify a record.

#### Deleting documents

```js
db.new_movies.deleteOne({_id:2})
```

Exercise -- Deleting one of many matched documents -- 

```js
db.new_movies.insertMany([
    {"_id" : 9, "title" : "movie_1"},
    {"_id" : 10, "title" : "movie_2"},
    {"title" : "movie_3"},
    {"_id" : 8, "title" : "movie_4"},
])
```

1. Use the Regex expression in the query to match all movies where the `title`starts with `movie`like:

   ```js
   db.new_movies.find({title: {$regex: /^movie/}})
   ```

2. Use the same query condition with `deleteOne`to match all movies with titles starting with the world movie

   ```js
   db.new_movies.deleteOne({title: {$regex: /^movie/}})
   ```

#### Deleting multiple documents using `deleteMany()`-- 

To delete multiple documents that match the given criteria -- can execute the `deleteOne`function multiple times -- however, each document will be deleted in a separate dbs command -- which can slow down the performance. And the `deleteMany`function must be provded with a query condition -- and all the documents that match the given query will be removed like:

```js
db.new_movies.deleteMany({'title': {'$regex': /^movie/}})
```

Note that the *empty* condition provided if -- `.delete*({})`then `deleteOne`will delete the document that is found first, however, the `deleteMany()`will delete all the documents in the collection.

#### Deleting using `findOneAndDelete()`

Apart from the two delete methods, there is another function named `findOneAndDepete()`-- which finds and deletes one document from the collection -- although it behaves similarly to the `deleteOne`, provide more options -

- Finds one and deletes it.
- If more than one found, only the first deleted
- once deleted, it returns the deleted document as a resp
- In the case of multiple documents matches, the `sort`option can be used to influence which gets deleted
- Projection can be used to include or execute fields from the document in response.

```js
db.new_movies.findOneAndDelete({_id: 3})
```

Need to note that the response in the next line shows that the deleted document is returned in the response. It allows U to further process the deleted record.

```js
db.new_movies.insertMany([
    { "_id" : 11, "title" : "movie_11" },
    { "_id" : 12, "title" : "movie_12" },
    { "_id" : 13, "title" : "movie_13" },
    { "_id" : 14, "title" : "movie_14" },
    { "_id" : 15, "title" : "series_15" }
])
```

Using the preceding insert, have inserted new documents into the collection. And in the following -- use the `findOneAndDelete()`which uses a regexp to find those titles in the collection that start with the `movie`.

```js
db.new_movies.findOneAndDelete({title: {$regex: /^movie/}},
    {sort: {_id: -1}})
```

This operation demonstrates how sort option can influence which documents get deleted.

```js
db.new_movies.findOneAndDelete(
    {title: {$regex: /^movie/}},
    {sort: {_id: -1}, projection: {title: 1, _id:0}})
```

#### Deleting a low-rated movie

The movie archives tem --  As U have to delete one movie, you can use either the `deleteOne`or `findOneAndDelete()`function and prepare a query fiter using the IMDB rating and votes. Can be:
`(“imdb.rating”: {$lt:2})`fore:

```js
db.movies.findOneAndDelete(
	{'imdb.rating': {$lt:2}, 'imdb.votes': {$gt:50000}},
    {
        'sort': {'awards.won':1},
        'projection': {'title':1}
    }
)
```

#### Replacing documents

In this, how can complete replace the documents in a collection -- sometimes u want to replace an incorrect inserted document in a collection, or the data stored in documents is changed over time -- or perhaps, to support your product’s new requriements -- many want to alter the way your documents are structured or change the fields in your documents.

```js
db.users.insertMany(
    [
        {"_id": 2, "name": "Jon Snow", "email": "Jon.Snow@got.es"},
        {"_id": 3, "name": "Joffrey Baratheon", "email": "Joffrey.Baratheon@got.es"},
        {"_id": 5, "name": "Margaery Tyrell", "email": "Margaery.Tyrell@got.es"},
        {"_id": 6, "name": "Khal Drogo", "email": "Khal.Drogo@got.es"}
    ]
)
```

To replace a single document in a collection, MDB provides method `replaceOne()`which accepts a query fiter and a replacement document -- like:

```js
db.users1.replaceOne(
    {_id:5},
    {'name': 'Margery Baratheon', email: 'MB@got.es'}
)
```

Here the first arg is the query fitler to identify the document to be replaced, and the second is the new document. And need to note that the `_id`fields are immutable.

## How `defer`arguments work

A common mistake mad by Go developers is not understanding how arguments are evaluated in `defer`. Will delve into this problem with two subsections -- 

#### Argument evaluation

To illustrate how arguments are evaluated -- fore

- `StatusSuccess`if both `foo`and `bar `return no errors
- And `StatusErrorFoo`, `StatusErrorBar`

Use this status for multiple actions -- fore, to notify another goroutine and to increment counters. To avoid repeating these calls before every `return`use the `defer`like:

```go
const (
	StatusSuccess = "success"
    StatusErrorFoo = "err_foo"
    StatusErrorBar = "error_bar"
)
func f() error {
    ver status string
    defer notify(status)
    defer incrementCounter(status)
    
    if err := foo(); err != nil {
        status = StatusErrorFoo
        return err
    }
    if err := bar(); err!= nil {
        status = StatusErrorBar
        return err
    }
    status = StatusSuccess
    return nil
}
```

If give this function a try, see that regardless of execution path, `notify`and `incrementCounter`are always called with the just same status -- an *empty* string -- Need to understand sth about argument evaluateion in a `defer`-- the arguments are evaluated *right away* -- not once the surrounding function returns. Therefore, Go will delay these calls to be exectued once `f`returns with the current value of `status`at the stage we use `defer`. So the first solution is to pass a string pointer to the `defer`function - 

```go
func f() error {
    var status string
    defer notify(&status)
    defer increment(&status)
    // ... same
}
```

For this, keep updating `status`depending on the cases, but now `notify`and `incrementCounter`receives a `string`pointer -- But there is another solution -- can call a *closure* as a `defer`statement.

```go
func main(){
    i, j := 0, 0
    defer func(i int) {
        fmt.Println(i,j) // 0 1
    }(i)
    i ++ 
    j ++
}
```

Cuz `i`is passed as a function argument, so it’s evaluted immediately -- conversely, `j`references a variable outside of the closure body. So it will be *evaluated when the closure is executed*. Fore app:

```go
func f() error {
    var status string
    defer func() {
        notify(status)
        incrementCounter(status)
    }()
    //... same
}
```

#### Pointers and Value Receivers

Said that a receiver can be either a value or pointer, the same logic related to argument evaluation applies when use `defer`on a method -- the receiver is also evaluated immediately.

```go
func main(){
    s := Struct {id: "foo"}
    defer s.print()	// foo 
    s.id= "bar"
}
```

For this, defer the call to the `print`method -- as with arguments, calling `defer`makes the receiver be evaluted immediately -- hence, `defer`delay the method’s execution with a struct that contains an `id`field to `foo`. Like:

```go
func main() {
    s := &Struct {id: "foo"}
    defer s.print()
    s.id = "bar"
}
type Struct struct {
    id string
}
func (s *Struct) print() {
    fmt.Println(s.id)
}
```

Error Management - 

- Understanding when to panic
- Knowing when to wrap an error
- Comparing error types and error values efficiently
- Handling errors idiomatically
- Understanding how to ignore
- Handling errors in `defer`

### Panicking

It’s pretty common for Go newcomers to be somewhat confused about error handling in Go, errors usually managed by functions or methods that return an `error`type as the last parameter -- but some developers may find this approach using `panic`and `recover`. Refresh our minds about the concept of panic and discuss when it’s considered appropriate or not to panic -- 

```go
func main(){
    panic("foo")
}
```

Once `panic`triggered, it continues up the call stack until either the current goroutine has returned or `panic`is caught with `recover`. like:

```go
func main() {
    defer func() {
        if r := receover(); r!= nil { // calling within a defer closure
            fmt.Println(r)
        }
    }()
    f()
}
```

In the `f`, once `panic`is called, it stops the current execution of the function and goes up the call stack -- in `main`, cuz the panic is caught with `recover`it doesn’t stop the goroutine. Also nohte that calling `recoever()`to capture a goroutine panicking is only useful inside a `defer`function -- otherwise, the func would return `nil`and have no other effect -- this is cuz `defer`are also executed when the sorrounding function panics.

In Go, `panic` is used to signal genuinely exceptional conditions -- fore, programmer error -- fore:

```go
func checkWriteHeaderCode(code int) {
    if code <100 || code >999 {
        panic(...)
    }
}
```

So, this func panics if the status code is invalid, which is a pure programmer error. Another example basd on a programmer error can be found in the `database/sql`packae. And another use case in which to panic is when app requires a dependency but fails to initialize.

### The structure of a test

If are not already familar with writing tests -- like:

```go
func TestPrintPrintsHelloMessageToTerminal(t *testing.T) {}
```

This `t`value contains the state of the test during its execution, and use its methods to control the outcomde of the test -- and the call to `t.Parallel()`signals that the test should be run concurrently with other tests.

#### Making package flexible

Mandatory args are annoying -- A struct is the answer -- if a global variable is no good, then it follows elegantly that we need some *local* variable instead -- like:

```go
type Printer struct {
    Output io.Writer
}
```

New each `Printer`could have its own individual `Output`writer, distinct from all others. Need to absorb this paperwork into a *constructor* instead -- that way, set `Output`to the default value when create the `Printer`like:

```go
func NewPrinter() *Printer {
    return &Printer{
        Output: os.Stdout
    }
}
```

We can customise it when necessary - test it like:

```go
func TestMessageToOutput(t *testing.T) {
    t.Parallel()
    buf := new(bytes.Buffer)
    p := hello.NewPrinter()
    p.Output= buf
    p.Print()
    want := "hello world\n"
    got := buf.String()
    if want != got {
        t.Errorf("...")
    }
}
```

#### A convenience wrapper with defaults

Can just provide some trivial wrapper function that absorbs the unncessary paperwork -- `Main()`like:

```go
func Main() {
    NewPrinter().Print()
}
type Printer struct {
    Output io.Writer
}
func NewPrinter() *Printer {
    return &Printer{
        Output: os.Stdout
    }
}
func (p *Printer) Print() {
    fmt.Fprintln(p.Output, "Hello world")
}
```

#### A simple line counter -- 

```go
func main() {
    lines := 0
    inputs := bufio.NewScanner(os.Stdin)
    for inputs.Scan() {
        lines ++
    }
    fmt.Println(lines)
}
```

Forcus on behaviour -- not imp -- For this -- Goal -- design and implement a line-counting package, test-first, in the same way we did -- include `main.go`that uses your package to build a line-counting CLI tool Just like:

```go
func TestPrintPrintsHelloMessageToOutput(t *testing.T) {
    t.Parallel()
    buf := new(bytes.Buffer)
    p := hello.NewPrinter()
    p.Output= buf
    p.Print()
    want := "Hello world"
    got := buf.String()
    if want != got {
        t.Errorf(...)
    }
}

func TestLinesCountsLinesInInput(t *testing.t) {
    t.Parallel()
    c := count.NewCounter()
    c.Input = bytes.NewBufferString("1\n2\n3")
    want :=3
    got := c.Lines()
    if want != got {
        t.Errorf(...)
    }
}
```

Write the corresponding package like:

```go
type counter struct {
    Input io.Reader
}
func NewCounter() *counter {
    return &counter {
        Input: os.Stdin,
    }
}
func (c *counter) Lines() int {
    lines := 0
    input := bufio.NewScanner(c.Input)
    for input.Scan() {
        lines ++
    }
    return lines
}
func Main() {
    fmt.Println(NewCoutner().Lines())
}
```

## Configuring HTTPs Settings

Go has a good default settings for its HTTPs server -- but it’s possible to optimize and customize how the server behaves -- 

```go
// Initialize a tls.Config to hold the non-default TLS
// settings we want the server to use.
tlsConfig := &tls.Config{
    CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
}

srv := &http.Server{
    Addr:      *addr,
    ErrorLog:  errorLog,
    Handler:   app.routes(),
    TLSConfig: tlsConfig,
}

// ... 
err = srv.ListenAndServeTLS("./cert.pem", "./key.pem")
```

TLS versions -- TLS versions are also defined as constants in the `crypto/tls`package, and Go’s HTTPs server. Can configure the minimum and maximum TLS versions via the `tls.Config.MinVersion`and the `MaxVersion`field. like:

```go
tlsConfig := &tls.Config {
    MinVersion: tls.VersionTLS12,...
}
```

#### Restricting cipher suites

For some apps, it may be descirable to limit your HTTPs server to only support some of these cipher suites. May:

```go
tlsConfig := &tls.Config{
    CipherSuites: []uint16 {
        tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
        //...
    },
}
```

#### Connection timeouts

Improve the resiliency of our server by adding some timeout settings -- like:

```go
func main() {
    //...
    srv := &http.Server{
		Addr:      *addr,
		ErrorLog:  errorLog,
		Handler:   app.routes(),
		TLSConfig: tlsConfig,
		
		// Add Idle, Read and write timeouts to the server
		IdleTimeout:  time.Minute,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}
    // ...
    infoLog.Printf("Starting server on %s", *addr)
    err = srv.ListenAndServeTLS(..)
}
```

All three of these -- are just server-wide settings which act on the underlying connection and apply to all requests irrepsectie of their handler or URL.

The `IdleTimeOut`setting -- By default, Go enables keep-alives on all accepted conenctions. This just helps reduce latency (especially for HTTPs connections) -- cuz a client can reuse the same connection for multiple requests without having to repeat the handshake. And keep-alive connections will be *automatically* closed after a couple of minutes -- this helps to clear-up connections where the user has unexpectedly disappeared -- Can reduce it via the `IdleTimeout`settings -- set `IdleTimeout`to 1m. Automatically closed after 1 minute of inactivity.

The `ReadTimeout`setting -- This means that `ReadTimeout`-- if the request headers or body are still being read 5s after the request first accepted, the to will close the underlying connection. Setting this helps to mitigate the risk from slow-client attacks.

The `WriteTimeout`-- will close the underlying connection if our sever attempts to the connection after a given periods.

### User authentication

In this, going to add some user authentication functionality to app -- so that only registered, logged-in users can create new snippets -- 

- register by a form at `/user/signup`and registering their name...
- Log by `/user/login`
- Will then check the dbs to see if the email and pwd they entered match one of the users in the `users`table. If there is a match, user will have *authenticated successfully* and add relevant `id`for the user to their session data, using the `key`-- `authenticatedUserID`.
- When receive any subsequent requests, can check the user’s session for `authentiatedUserID`-- if exists, know that the user has already successfully logged in.

#### Routes setup 

- `GET /user/signup`-- `userSignup()`-- display a HTML form for signing up a new user
- `POST /user/signup`-- `userSignupPost()`-- Create a new user.
- `GET /user/login` -- `userLogin()`-- Display a HTML form for logging in a user
- `POST /user/login` - `userLoginPost`- Authenticate and login the user
- `POST /user/logout`-- `userLogoutPost`-- Logout the user

For this like:

```go
func (app *application) userSignup(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Display a HTML form for signing up a new user...")
}

func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Create a new user account...")
}

func (app *application) userLogin(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Display a HTML form for logging in a user...")
}

func (app *application) userLoginPost(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Authenticate an existing user...")
}

func (app *application) userLogoutPost(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Logout an existing user...")
}
```

When it’s done, create the corresponding routes in the `routes.go`file like:

```go
router.Handler(http.MethodGet, "/user/signup", dynamic.ThenFunc(app.userSignup))
router.Handler(http.MethodPost, "/user/signup", dynamic.ThenFunc(app.userSignupPost))
router.Handler(http.MethodGet, "/user/login", dynamic.ThenFunc(app.userLogin))
router.Handler(http.MethodPost, "/user/login", dynamic.ThenFunc(app.userLoginPost))
router.Handler(http.MethodPost, "/user/logout", dynamic.ThenFunc(app.userLogoutPost))
```

Finally, also need to update the `nav.html`file to include navigation items for the new pages -- like:

```html
{{define "nav"}}
    <nav>
        <div>
            <a href="/">Home</a>
            <a href="/snippet/create">Create a new Snippet</a>
        </div>

        <div>
            <a href="/user/signup">Signup</a>
            <a href="/user/login">Login</a>
            <form action="/user/logout" method="post">
                <button>Logout</button>
            </form>
        </div>
    </nav>
{{end}}
```

