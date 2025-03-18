# Data Aggregation

This introduces to the concept of aggregation and its implementation in Mdb -- will learn how to identify the parameters and structures of the aggregate command, combined and manipulate data using the primary aggregation stage, work with large dataset using advanced aggregation stages, and optimize and configure your aggregation to get the best performance our of your queries.

The basic limitation is where U have data contained in two fore, separate collections -- to find the correct data, would have to run two queries instead of one, joining the data on the client or app level -- may not seem like a big problem -- but as app or dataset increases in scale, performance and complexity also grow. Wherever possible, it is ideal for the server to do all the heavy lifting, returning only the data we are looking for in a single query.

Aggregation pipeline does precisely what the name implies. Allows to define a series of stages that filter, merge, and organize data with much more control than the std `find`. Also allows developers and dbs analysts to easily, interactively, and quickly build queries on ever- changing and growing datasets.

### Aggregate is the New find

The `aggregate`command in Mdb is similar to the `find`-- can provide the criteria for your query in the form of JSON documents, and it outputs a *cursor* containing the search result. The key element in aggregation is called the pipeline -- will cover it in details shortly.

The `aggregate`command operates on a collection like the other `CREATE, READ, UPDATE, DELETE`commands fore:

```js
use sample_mflix;
var pipeline = []; // is an array of stages
var options = {}; 
var cursor = db.moveis.aggregate(pipeline, options);
```

For the `pipeline`parameter contains all the logic to find, sort, project, limit, transform, and aggregate data. And the `pipeline`itself is passed in an array of JSON documents. Can think of this as a series of instructions to be sent to the dbs, and then the resulting data after the final stage is stored in a `cursor`to be returned to you. And each stage in the pipeline is completed indepdnednetly, one after another, until one are remaininig.

For the `options`-- to specify the details of the configuration, fore some flags, how to execute... Can also be ignored.

`var cursor = db.movies.aggregate(pipeline)`

Fore, can create a file called `aggregation.js`with the following content:

```js
var MyAggregation_A = function() {
    print("running...");
    var pipeline= [];
    var cursor = db.movies.aggregate(pipeline);
    printjson(cursor.next())
}
```

#### Aggregation pipeline

Fore : *Collection* -> **$sort->$match->$limit** -> *Result*

The syntax of an aggregation pipeline is simple -- like:

```js
const pipeline = [{}...{}...{}]
```

Each of the objects in the array represents a single stage in the overall pipeline. And the stage represents the action we want to perform on the data and the parameters can be either a single value or another object.

```js
const pipeline=[
    { $match: { "location.address.state": "MN"} },
    { $project: { "location.address.city": 1 } },
    { $sort: { "location.address.city": 1 } },
    { $limit: 3 }
];

db.theaters.aggregate(pipeline)
```

#### Creating Aggregations

Begin to explore the pipeline itself -- 

```js
const simpleFind = function () {
    // using filter, project, sort and limit
    print('Find result:');
    db.theaters.find(
        {'location.address.state': 'MN'},
        {'location.address.city': 1}
    ).sort({'location.address.city': 1})
        .limit(3)
        .forEach(print)
}

simpleFind()
```

Just rebuild this command as an aggregation just like:

```js
const simpleFind = function () {
    // using filter, project, sort and limit
    print('Find result:');
    const pipeline = [
        {$match: {"location.address.state": "MN"}},
        {$project: {"location.address.city": 1}},
        {$sort: {"location.address.city": 1}},
        {$limit: 3}
    ];
    db.theaters.aggregate(pipeline).forEach(print);
}
```

Just remember both `find`and `aggregate`command return a cursor. The only noticeable difference with these is that they are now documents in an array instaed of functions, the `$match`stage at the very beginning of our pipeline is the equivalent of our filter document.  One of its strengths is the ability to break down large pipelines into smaller subsections or individual stages. It’s also important to note that the order of the steps is just as important as the stage themsevles. -- *not just logically but also to increase performance*. Cuz the `$match`and `$project`stages execute first -- reduce the size of the result set at each stage.

#### Performing a simple aggregations

Return the top 3 movies in the romance genre sorted by IMDB.

```js
// findOne-- 
const findTopRomanceMovies = function () {
    print("Find top classic Romance Movies...");
    const pipeline = [
        {$limit: 3},
        {$sort: {"imdb.rating": -1}},
        {
            $match: {
                'genres': {$in: ["Romance"]},
                'released': {$lte: new ISODate("2000-01-01")}
            }
        }
    ];
    db.movies.aggregate(pipeline).forEach(print);
}
```

Noted that there no documents satisfy this query -- Cuz -- *when writing aggregation pipelines, the order of operations matters* -- so, rearrange them tom make sure that you only limit your documents at the end of your pipeline -- 

```js
// reorder this like:
const findTopRomanceMovies = function () {
    print("Find top classic Romance Movies...");
    const pipeline = [
        {$sort: {"imdb.rating": -1}},
        {
            $match: {
                'genres': {$in: ["Romance"]},
                'released': {$lte: new ISODate("2000-01-01")}
            }
        },
        {$limit: 3},
         {$project: {genres:1, released:1, 'imdb.rating': 1}}
    ];
    db.movies.aggregate(pipeline).forEach(print);
}
```

One way to relieve this pain point is to just add stages during development that simplify the data, and then to remove these stages in your final query.

## Concurrency Practice

- Preventing common mistake with goroutines and channels
- Understanding the impacts of using std data structure alongside concurrent code
- using the stdlib and some extensions
- Avoiding data races and dead locks

### Propagating appropriate context

Contexts are just omnipresent when working with concurrency in Go, and in many situations, it may be recommended to propagate thenm -- context propagation can sometimes lead to subtle bug, preventing subfunctions from being correctly executed. Fore, exposes an HTTP handler -- send it to a Kafka topic -- and don’t want to penalize the HTTP consumer latency, so publish action to be handled async within a new goroutine. like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    resp, err := doSomeTask(r.Context(), r)
    if err != nil {
        http.Error(...)
        return
    }
    go func() {
        // creates a goroutine to publish resp to Kafka fore
        err := publish(r.Context(), resp)
        // ...
    }()
    writeResp(resp) // if this occurred before publish, then RC ...
}
```

For this call a `doSomeTask`to get a `resp`-- it’s used within the goroutine calling `publish`and to format the HTTP response. -- fore this, have to know that the context attached to an HTTP request can cancel in different conditions -- 

- When the client’s connection closes
- In the case of an HTTP/2, when the request is canceled.
- When the response has been written back to the client.

For the 3rd, when the response has been written to the client, the context associated with the request will be *canceled* -- therefore, facing a race condition. If the response is written before or during the Kafka publication, the message shouldn’t be published. Fix this just `err := publish(context.Background(), response)`

Here, that works -- Regardless of how long it takes to write back the HTTP response. But -- what if the context just contained useful values -- fore, if the context contained a correlation ID used for distributed tracing, we could correlate the HTTP request and the publication. Would like to have a new context that is detached from the potential parent callation but sitll conveys the values.

For stdlib doesn’t provide an immediate solution. A possible solution is to implement our own Go context -- for a `context.Context`just is an interface containing 4 methods like:

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key any) any
}
```

For the context’s `deadline`is just managed by the `Deadline`method and the cancellation signal is managed via the `Done`and `Err`methods. when a deadline has passed or the context has been canceled, `Done`should return a closed channel, whereas `Err`should return an `error`.

```go
type detach struct {
    ctx context.Context // custom just wrapping on top of the initial context
}

func (d detach) Deadline() (time.Time, bool) {
    return time.Time{}, false
}

func (d detach) Done <-chan struct{} {
    return nil
}

func(d detach) Err() error() {
    return nil
}

func (d detach) Value(key any) any {
    return d.ctx.Value(key)
}
```

For this, except for the `Value`method that calls the parent context to retreive a value, the other return just the default value to the context is never considered expired or canceled. Then just like:

`err := publish(detach{ctx: r.Context()}, resp)`

### Starting a goroutine and knowing when to stop it

Not knowing when to stop a goroutine is a design issue and a common concurrency mistake in Go -- In terms of memory, a goroutine starts with a minimum stack size of 2K, A goroutine can also hold variable references allocated to the heap. Meanwhile, a goroutine can hold resources like HTTP or dbs connections, open files, and network sockets... 

```go
ch := foo()
go func() {
    for v := range ch {
        //...
    }
}()
```

For the created goroutine, will exit when `ch`closed, Do we know exactly when this channel will be closed -- fore:

```go
func main() {
    w := newWatcher()
    defer w.close()
}
func newWatcher() watcher {
    w := watcher{}
    go w.watch()
    return w
}
func (w watcher) close() {
    // close the resources
}
```

`watcher`has a new method `close`-- instead of signaling, it’s time to close its resources, new call this `close`method, using the `defer`to guarantee that the resources are closed before the app exits.

### Non-deterministic behavior using `select`and channels

One common mistake made by Go developers while working with channels is to make wrong assumptions about how `select`behaves with multiple channels. A false assumption can lead to subtle bugs that may be hard to identify and reproduce -- fore:

```go
for {
    select {
    case v := <-messageCh:
        fmt.Println(v)
    case <-disconnectCh:
        fmt.Println("disconnected, return")
        return
    }
}
```

Used the `select`to receive from multiple channels - cuz want to prioritize `messageCh`-- might assume that we should write the `messageCh`case first and the `disconenctCh`case next -- not work. Fore:

```go
for i:=0; i<10; i++ {
    messageCh <- i
}
disconnectCh <- struct{}{}
```

If one or more of the communications can proceed, a single one that can proceed is chosen via a uniform pseudo-random selection.

- Make `messageCh`an unbuffered channel instead of a buffered channel -- cuz the sender goroutine blocks until the receiver is ready -- this approach guarantees that ll the messages from `messageCh`are received before the disconnection from `disconnectCh`.
- Using a single channel instead of two channels.

If we fall into these two -- Hence, whether we have an unbuffered or a single channel -- it will lead to a RC among the producer -- so:

```go
for {
    select {
    case v := <-messageCh:
        fmt.Println(v)
    case <-disconnectCh:
        for {
            select {
            case v:= <-messageCh:
                fmt.Println(v)
            default:
                fmt.Println("disconnect")
                return
            }
        }
    }
}
```

This solution uses an inner `for/select`with two cases -- one on `messageCh`and a `default`case. -- using a `default`ase is chosen onlyu if none of other cases match. This is just a way to ensure that we receive all the remaining messages from a channel with a receiver on multiple channels.

### Creating a logging library

- Understanding the need for a logger
- Implementing a 3-level logger
- Using an integer-based new type to create an enum
- Publishing a library with a stable exported API
- Implementing external and internal testing
- Understanding package-level expostion

Keeping track of the current state or events via readable messages is called logging. Every piece of tracked info is a log -- and to log is the associated action.

##### What is a logger - 

Is in charge of noting down a log messages. Task is to write messages at specific moments in its execution so that they could be read and analysed later. Not all messages carry the same amount of information -- Might want to emphasise critical messages -- or discard those lf lesser matter. -- Acknowledging that there are different degrees of importance was already performed by scribes.

#### Define the API

Defining the way a caller interacts with a library is essential in making it stable and easy to use. Go apps are organized in packages -- collections of source fiels located in the same directory -- each declaring the same package name. Packages are the way we isolate the scope of functions and types.

##### Rules of Go package

- Is a collection of files located *in the same folder* that all share the same package name. Each Go file starts with the package declaration
- It is just customary to name the package
- Avoid overly long names if possible, also prefer a lowercase signle word.
- Any symbols starting with a captial letter will be exported outside the package can be used by other packages.

##### Go modules

A module is a collection of Go packages in a file tree with a `go.mod`file at its root. The `go.mod`file defines the module’s module path, which is also the import path used for the root directory.

```go
package pocketlog

// Logger is used to log information
type Logger struct{ 
}
```

#### Exporting the supported levels

It is mandatory, when using a logger, to assign an importance level to a message -- this is the task of the user, who has to think about the criticalness of the information that is about to be recorded. These 3 are quite common -- 

- *Debug* -- Used by developers to help monitor any info
- *info* -- used to track meaningful info
- *error* -- goes wrong.

##### A matter of the file size

Note that  -- don’t be afrid to keep your files small -- when a type is starting to support more and more methods -- thinking about splitting them just into multiple files. And the scope for declaring methods on a type or accessing its unexported fields is the package in which this type is declared.

```go
// Level represents one available logging level
type Level byte

const (
	// LevelDebug represents the lowest level of log, mostly used for debugging purposes.
	LevelDebug Level = iota
	// LevelInfo represents a logging level that contains information deemed valuable.
	LevelInfo
	// LevelError represents the highest logging level, only to be used to trace errors.
	LevelError
)
```

##### Enumerations

The syntax here is to use the `=iota`-- to let the compiler know that we are starting an enumeration. Allows us to create a squence of numbers incremented on each line.

## How Request context works

Every `http.Request`that our middleware and handlers process has a `context.Context`object embedded in it, which we can use to store information during the lifetime of the request. In a web app a common use-case for this is to pass info between your pieces of middleware and other handlers.

Start with some theory and explain the syntax for working with request context. Then in the -- 

```go
ctx := r.Context()
ctx = context.WithValue(ctx, "isAuthenticcated", true)
r = r.WithContext(ctx)
```

The important thing to explain here is behind the scenes, request context values are stored with the type `any`-- and that means that after retreiving them from the context, need to assert them to their original type before use them -- 

```go
isAuthenticated, ok := r.Context().Value("isAuthenticated").(bool) 
if !ok {
    return errors.New("could not covert value to bool")
}
```

#### Avoiding Key collisions

Have used the string `isAuthenticated`as the key for storing and retrieving the data from a request’s context, but this isn’t recommended cuz there is a risk that other 3rd-party packages used by your app will also want to store data using the key `isAuthenticated`-- to avoid -- it’s just a good practice to create you own *custom type* which U can use for your context keys -- 

```go
// Declare a custom contextKey type for context keys
type contextKey string
const isAuthenticatedContextKey= contextKey("isAuthenticated")
ctx := r.Context()
ctx = context.WithValue(ctx, isAuthenticatedContextKey, true)
r = r.WithContext(ctx)

// then retreive the value from the request context using our constant
isAuthenticated, ok := r.Context().Value(isAuthenticatedContextKey).(bool)
if !ok {...}
```

### Request context for authentication/authorization

Begin by heading back to the `internal/models/users.go`and updating the `Exists()`method -- like:

```go
func (m *UserModel) Exists(id int) (bool, error) {
	var exists bool
	stmt := "SELECT EXISTS(select true from users where id=?)"
	err := m.DB.QueryRow(stmt, id).Scan(&exists)
	return exists, err
}
```

Then create a new `cmd/web/context.go`-- 

```go
package main

type contextKey string
const isAuthenticated = contextKey("isAuthenticated")
```

Then create a new `authenticate()`middleware --

1. Retrieves the user’s ID from their session data
2. Checks the dbs to see if the ID corresponds to a valid user using the `UserModel.Exists()`method.
3. Updates the request context to include the `isAuthenticatedContextKey`with the value `true`.

```go
func (app *application) authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// retrieve the authenticatedUserID value from the session using the GetInt()
		// will return the zero value if no value is in the session.
		id := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")
		if id==0 {
			next.ServeHTTP(w, r)
			return
		}
		
		// otherwise, check to see if a user with ID eixsts
		exists, err := app.users.Exists(id)
		if err != nil {
			app.serverError(w, err)
			return
		}
		
		// if matching user is found, know we know that the request is coming 
		// from an authenticated user
		if exists {
			ctx := context.WithValue(r.Context(), isAuthenticatedContextKey, true)
			r = r.WithContext(ctx)
		}
		next.ServeHTTP(w, r)
	})
}
```

- When don’t have a valid authenticated user, pass the original and unchanged `*http.Request`to the next handler in the chain
- When do have a valid authenticated user, create a copy of the request with key and `true`value stored in the request context, then pass this copy of the `*http.Request`to the next handler in the chain.

```go
dynamic := alice.New(app.sessionManager.LoadAndSave, noSurf, app.authenticate)
```

And the last thing that we need to do is update our `isAuthenticated()`-- like:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	isAuthenticated, ok := r.Context().Value(isAuthenticatedContextKey).(bool)
	if !ok {
		return false
	}
	return isAuthenticated
}
```

It’s important to point out here that if there isn’t a value in the request context with the `isAuthenticatedContextKey`key, or the underlying value isn’t a `bool`, then this type assertion will fail.

### Optional Go features -- 

In this, we are going to talk about two Go features that are relatively new additions to the language -- *file embedding* and *generics* -- Fore -- 

- File embedding makes it possible to *embed external files* into your Go program itself.
- Generics can help to reduce the amount of biolerplate code you need to write.

Using embedded fields -- Go. 1.16 release was the `embed`package -- whcih makes it possible to *embed external files into your Go program itself*.

This is really nice cuz it makes it possible to create -- (distribute) Go programs that are completely self -- contained and have everything that they need to run as part of the *binary* executable.

Fore, update our app to embed and use the files in our existing `ui`directory -- 

```go
package ui

import "embed"

//go:embed "html" "static"
var Files embed.FS
```

The important line is `//go:embed “html” “static”`-- It is actually a special *comment directive* -- When app is compiled, this comment directive instructs Go to store the files from our `ui/html`and `ui/static`folder in an `embed.FS`e*mbedded filesystem* referenced by the global variable `Files`.

- The comment directive must be placed *immediately above the variable*.
- directive has the general format `go:embed <paths>`
- Can only use the `go:embed`on **global variables** at the package level, not within functions or methods.
- Paths cannot contain `.`or `..`elements, nor may the begin or end with a `./`. Just restricts U to only embedding files that are contained in the same directory
- If a path is to a directory, then all files in that diretory are recursively embedded, except for with names that begin with `.`or `_`. If want to include these, should use the `all:`fore: `go:embed “all:static”`
- The embedded file system is *always* rooted in the directory which contains the `go:embed`directive. For this the root of the filesystem is our `ui`directory.

