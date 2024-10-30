# The MongoDB Architecture

Enables U to meet the demands of modern apps with a developer data platform built on severl core architectural foundations-- Lets U access the best ways to innovate in building transactional, operational, and analytical applications.

Is a *document-oriented dbs*, not relational one. the primary reason for moving away from the relatinal model is to make scaling out easier -- but there are some other advantages as well -- a document-oriented dbs replaces the concept of a row with more flex model -- `document`-- by allowing embedded documents and arrays, the document-oriented approach makes it possible to represent complex hierarchical relationships with a single record.

There are also no predefined schemas -- a document’s keys and values are not fixed types or sizes. MongoDB was designed to scale out, the document-oriented data model makes it easier to split data across multiple servers. MongoDB automatically takes care of balancing data and load across a cluster -- redistributing documents automatically and routing reads and writes to the correct machines -- 

- A *document* is a basic unit of data for MongoDB and is ourgly equivalent to a row.
- A *collection* can be thought of a table
- A single instance of MongoDB can host multiple independent *database*, each of which has its own collections.
- Every document has a special key -- `_id`, that is unique within a collection.
- MongoDB is distributed wtih a simple but powerful tool called the mongo shell.

#### Docments

At the heart of MDB is *document* -- an ordered set of keys with associated values -- the representation of a document varies by programming language. documents are just represented as objects. Fore just like a json. As can see, values in documents are not just blobs, they can be one of several different data types.

- Key must not contain the character `\0`
- The `. and $`characters have some special properties and should be used only in certain circumanstances.

MongoDB is type-sensitive and case-sensitive -- fore `{"count": 5}`and `{"count": 5}`

#### Collections -- 

A collection is a group of documents, if document is the MongoDB analog of a row in a REL database, then a collection can be thought of as the analog to a table. Collections have dynamic schemas -- this means that the documents within a singl ecolleciton can have any number of different shapes -- fore: both of the following could be stored in a single colelction like:

```json
{"greeting":"hello", "views": 3} {"signoff":"Good night"}
```

Just note that the previous documents have different keys, different numbers of keys, and values of different types. Cuz any document can be put into any collection -- With no need for separate schemas for different kinds of document -- why *should* we use more than one collection -- there are just several good reasons -- 

- Keeping different kinds of documents in the same collection can be a nightmare
- It’s much faster to get a list of collection than to extract a list of types of documents in a collection.
- Grouping documents of the same kind together in the same collection allows for data locality.

#### Subcolletions

One convention for organizing collections is to use namespaced subcollections separated by the `.`character. Fore, an app containing a blog might have a collection named `blog.posts`and separate collection named `blog.authors`

### Databases

In addition to grouping documents by collection, MDB groups collections into *database*. A single instance of MDB can host several dbs -- each grouping togehter zero or more collections. And there are some reserved database names -- 

- *admin* -- plays a role in authentication and authorization
- *local* -- Stores data specific to a single server, replica sets, local stores data used. The local dbs itself is never replicated.
- *config* -- Shared MongoDB clusters use the *config* database to store information about each shard.

Note that by concatenating a dbs name with a collection in that dbs you can get fully qualified collection name, which is called a *namespace*. Fore, if you are using the *blog.posts* collection the *cms* dbs, the namespace of that collection would be `cms.blog.posts`. Namesapces are limited to 120 bytes in length.

### Knowing when to stop a goroutine

Goroutine are easy and cheap to start -- Not knowing when to stop a goroutine is a design issue and a common concrurency mistake in Go - understand why and how to prevent it -- First, quantify what a goroutine leak means -- in terms of memory -- a goroutine starts with a minimum stack leak means. A goroutine starts with a minimum stack size of 2K -- which can grow and shrink as needed -- memory-wise, a goroutine can also hold variable refrences allocated to the heap -- meanwhile, a goroutine can hold resources such as HTP or dbs connection, open files, and network sockets that should eventually be closed gracefully. If a goroutine is leaked, these kinds of resources will also be leaked.

```go
ch := foo()
go func() {
    for v := range ch {
        //...
    }
}()
```

The created goroutine will exit when `ch`is just closed -- but do we know exactly when this channel will be closed? `ch`is just created by the `foo`function -- if the channel is never closed, it’s a leak. So should always be cautions about the exit points of a goroutine and make sure one is eventually reached. Discuss a concrete example, will design an application that needs to watch some external configuration -- like:

```go
func main() {
    newWatcher()
    // run the app
}
type watcher struct {...}
func newWatcher() {
    w := watcher{}
    go w.watch()
}
```

The problem with this code is that when the main goroutine eixts -- the application is stopped-- the resources created by watcher aren’t closed gracefully -- 

One option could be to pass to `newWatcher`a context that will be canceled when `main`returns. Fore:

```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    newWatcher(ctx)
}
func newWatcher(ctx context.Context) {
    w := watcher{}
    go w.watch(ctx)
}
```

We just propagate the context created to the `watch()`method -- when the context is canceled, the `watcher`struct should close its resources -- however, can guaratnee that the `watch`will have time to do so?

The problem is that we used signaling to convey that goroutine had to be stopped -- didn’t block the parent goroutine until the reousces had been closed so just like:

```go
func main(){
    w := newWatcher()
    defer w.close()
    // ... run the application
}
func newWatcher() watcher {
    w := watcher{}
    go w.watch()
    return w
}
func (w watcher) close() {
    // close the resource
}
```

For this, has new method `close()`instead of signaling `watcher`it’s time to close, now just call this `close()`-- using `defer`to guarantee that the resources are closed before the application exits.

## Panicking vs. returning Errors

The decision to panic in the `readJSON()`helper if get `json.InvalidUnmarshalError`erorr -- It’s generally considered best practice in Go to return your errors and handle them gracefully. In some specific circumstance, it can be ok to panic -- shouldn’t be too dogmatic about not panicking when it makes sense to. It’s helpful to distinguish betwee the two classes of error that your application might encounter.

The first class of errors are *expected errors* that may occur during normal opeation -- some examples of expected erros are those caused by dbs query timeout, a network resource being unavailable, or bad user input. These errors don’t ncessarily mean there is problem with your program -- almost of all the time it’s good practice to return these kinds of erors.

The others are *unexpected errors* -- these are errors which should not happen during normal operation -- and if they do it is probably the result of a developer mistake or a logical error in your codebase. These errors are truly exceptional, and using panic in these is more widely accepted. In fact, the Go stdlib frequetly does this when make a logical error or type to use the language features in an unintended way.

Even then, recommend trying to return and gracefully handle unexpected errors in most cases. Fore the `readJSON()`helper, if get a `json.InvalidUnmarshalError`at runtime it’s cuz we as the developers have passed an unsupported value to the `Decode()`-- this is firmly an unexpected error which shouldn’t see under normal opration.

### Restricting inputs

The changes that we made -- to deal with invalid JSON and other bad requests were a big steps in the right direction. There is no error inform the client that the `rating`field is not recognized by our app - in certain scenarios, silently ignoring unknown fields may be exactly the behavior you want -- 

go’s `json.Decoder`provides a `DisallowUnknownFileds()`setting that we can use to generate an error when this happens -- another problem we have is the fact that `jons.Decoder`is designed to support *streams* of JSON data. When cal `Decode()`on our request body, it actaully reds the *first JSOn value* only from the body and decodes it. Only once needed -- anything after the first JSON value in the request body should be ingored.

```go
func (app *application) readJSON(w http.ResponsWriter, r *http.Request, dst any) error {
    maxBytes := ...
    r.Body = http.MaxBytesReader(w, r.Body, int64(maxBytes))
    dec := json.NewDecoder(r.Body)
    dec.DisallowUnknownFields() // if cannot be mapped to traget, decoder will return an error
    err := dec.Decode(dst) 
    if err != nil {
        var syntaxError *json.SyntaxError
        //...
        switch {
            case errors.As(err, &syntaxError):
            return fmt.Errorf(...)
        default:
            return err
        }
    }
    
    // Call `Decode()` again, using a pointer to an empy struct as dest
    err = dec.Decode(&struct{}{}) 
    if !erros.Is(err, io.EOF) {
        return errors.New...  // if not, so get anything else
        	// there is a error
    }
    return nil
}
```

### Custom JSON Decoding

In this, going to look at this form the other side and update our app so that the `createMovieHelper`accepts info in this format -- like:

```go
type Unmarshaler interface {
    UnmarshalJson([]byte) error
}
```

Add a `UnmarshalJSON()`method to our `Runtime`type -- in this method we need to parse the JSON string in the format convert the runtime number to `int32`and then assign this to the `Runtime`value itself.

```go
var ErrInvalidRunttimeFormat = errors.New("invlaid runtime format")
type Runtime int32
func (r *Runtime) UnmarshalJSON9(jsonValue []byte) error {
    parts := strings.Split(string(jsonValue))
    if len(parts)!=2 || parts[1]!= "mins" {
        return ErrInvalidRuntimeFormats
    }
    i, err := strconv.ParseInt(parts[0], 10, 32)
    if err != nil {
        return ErrInvalidRuntimeFormats
    }
    // convert the int32 to Runtime type
    *r = Runtime(i)
    return nil
}
```

### Validating JSON input

In many cases, you will want to perform additional validation checks on the data from a client to make sure it meets your speicifc business rules before processing it.

#### Creating a validator package -- 

To help with validation throughout -- going to create a small `internal/validator`package with some simple reusable helper types and functions -- like:

```go
var EmailRx = ...
type Validator struct {
    Errors map[string]string
}

func New() *Validator {
    return &Validator{Errors: make(map[string]string)}
}

func (v *Validator) Valid() bool {
    return len(v.Errors)==0
}

func (v *Validator) AddError(key, message string) {
    if _, exists := v.Errors[key]; !exists {
        v.Errors[key]= message
    }
}

func (v *Validator) Check(ok bool, key, message string) {
    if !ok {
        v.AddError(key, message)
    }
}

func PermittedValue[T comparable] (value T, permittedValues ...T) bool {
    return slices.Contains(permittedValues, value)
}

func Matches(value string, rx *regexp.Regexp) bool {
    return rx.MatchString(value)
}

func unique[T comparable](values []T) bool {
    uniqueValues := make(map[T]bool)
    for _, value := range values {
        uniqueValues[value]= true
    }
    return len(values)== len(uniqueValues)
}
```

In the code, defined a custom `Validator`type which contains a map of errors. The `Validator`type provides a `Check()`method for conditionally adding errors to the map, and `Valid()`method which returns whether the errors map is empty or not.

#### Performing validation checks -- 

The first thing we need to do is update the `erros.go`include a new `failedValidationResponse()`helper -- like:

```go
func (app *application) failedValidateResponse(w http.ResponseWriter, r *http.Requst,
                                               errors map[string]string) {
    app.errorResponse(w, r, http.StatusUnprocessableEntity, errors)
}
```

Making validation rules reusable -- In large project it’s likely that you will want to reuse some fo the same validation checks in multiple places, -- want to use many of these same checks later -- to prevent duplication -- collect the validation checks for a movie into a stanalone function like:

```go
func ValidateMovie(v *validateor.Validator, movie *Movie) {
    v.Check(movie.Title!= "", "title", "must be provded")
    v.Check(len(movie.Title)<=500, "title", "must not be more than 500 bytes lone")
    //...
}
//...
movie := &data.Movie {
    Title: input.Title, // copy the values form the input to new Movie struct
}
v := validator.New()
if data.ValidateMovie(v, movie); !v.Valid() {
    app.failedValidateResponse(w, r, v.Errors)
    return
}
//...
```

Might just wondering why are decoding the JSON request into the `input`, and then copy the data across. -- with decoding directy into a `Movie`struct is that a client could provide the keys `id`and `verion`in ther JSON, and the corresponding vlaues would be decoded without any error into the `ID`and `Version`of the movie.

### DBS setup and configuration

To work with SQL dbs need to use a *database driver* to act a middleman between the Go and dbs itself. Can find a lost if available -- fore:

```sh
go get github.com/lib/pq@v1
```

#### Establishing a conenction pool

The code that we will use for connecting to the `greenlight`dbs from our Go application is almost exactly the same as the first edition -- so, dwell on the details - At high level -- 

- Want the DNS to be configureable at runtime. So, will pass it to the application using a command-line flag
- In the `cmd/api/main.go` -- create an new `openDB()`.

```go
// Add a db struct field hold the configuration settings for our dbs connection pool
type config struct {
    port int
    env string
    db struct {
        dsn string
    }
}
// ...
func main() {
    var cfg config
    flag.StringVar(&cfg.db.dsn, "db-dsn",
		"postgres://postgres:south@localhost/greenlight", "PostgresSQL DSN")
    //...
    flag.Parse()
    logger := slog.New(Slog.NewTextHandler(os.Stdout, nil))
    
    // Call the openDB() func to crete the conenction pool
    db, err := openDB(cfg)
    if err != nil{
        logger.Error(err.Error())
        os.Exit(1)
    }
    defer db.Close()
    logger.Info("database connection pool established")
    //...
}

func openDB(cfg config) (*sql.DB, error) {
    // Open() to create an empty connection pool 
    // using the DSN from the config struct
    db, err := sql.Open("postgres", cfg.db.dsn)
    if err != nil {
        return nil, err
    }
    
    // if 5 second deadline passes, just cancel.
    ctx, cancel := context.WithTimout(context.Background(), 5*time.Second)
    defer cancel()
    
    // Using `PingContext()` to establish a new connection to the dbs, passing in the 
    // context we created above as a parameter -- if the connection couldn't be established
    // successuflly within the 5 second deadline, then this will return an error.
    err := db.PingContext(ctx)
    if err != nil {
        db.Close()
        return nil, err
    }
    return db, nil
}
```

#### Decoupling the DSN

At the moment the default command-line flag value for our DSN is explicitly included as a string in the `cmd/api/main.go`file -- even though the username and pwd in the DSV are just for the development dbs on the lcoal machine -- would be preferable to not have this info hard-coded into our project files.

So, take some steps to decouple the DSN from our project code and instead store it as an environment variable on your local machine -- Can create a new `GREENLIGHT_DB_DSN`environment variable by adding the following line to either the `$HOME/.profile`or `$HOME/.bashrc`files like:

```sh
export GREEN_LIGHT_DB_DSN='postgres://postgres:south@localhost/greenlight'
```

Once that is done, need to reboot the Ubuntu. either way, once you’ve rebooted or run `source`, should be able to see the value for the `GREENLIGHT_DB_DSN`environment vairable.