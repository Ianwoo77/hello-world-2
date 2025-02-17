# MongoDB aggregtion pipelines

Aggregation operations allow U to group, sort, perform calculations, analyze data, and much more. Aggregation pipelines can have one or more stages -- the order of the starge are important, each stage acts upon the results of the previous stage.

```js
db.posts.aggregate([
    {
        $match: {likes: {$gt:3}}
    },
    // stage 2
    {
        $group: {_id:"$category", totallikes: {$sum: "$likes"}}
    }
])
```

### Updating Documents

Once a documents is stored in the dbs, can be changed using one of several update methods. `updateOne, updateMany`and `replaceOne`. Note that the updating is atomic -- if two updates happen at the same time, whichever one reaches the server first will be applied, and then the next one will be applied. Thus, conflicting updates can safely be sent in rapid-fire succession without any documents being currupted.

#### Document Replacement

`replaceOne`fully replaces a matching document with a new one. This can be useful to do dramatic schema migration -- fore, suppose are making major changes to a user document -- 

```json
{
    "_id": ObjectId("..."),
    "name":"Joe",
    "friends:": 32,
    "enemies":2
}
```

Say, want to move the `firends`and `enemies`to a `relationships`*subdocument*. Can change the structure of the document in the shell and then replace the dbs’ version with a `replaceOne`like:

```js
var joe = db.users.findOne({name: 'joe'});
joe.relationships= {firend: joe.friends, enemies: joe.enemies};
joe.username = joe.name;
delete joe.friends;
delete joe.enemies;
delete joe.name;
db.users.replaceOne({'name', 'joe'}, joe);
```

For this method, a common mistake is matching more than one document with the criteria.

#### Using Update operators

Usually only certain portion of a document need to be updated -- You can update speical fields in a document using atomic *update operators* -- Are special keys that can be used to specify complex update operations, such as altering, adding, or removing keys, and even manipulating arrays and embedded documents. Fore: have doc like:

```json
{
    "id": ObjectId("..."),
    "url": "www...";,
    "pageviews": 52
}
```

For this, every time someone visists a page, can find the page by its URL and use the `$inc`operator to increment the value of the `pageviews`key like:

```js
db.users.insertOne(
    {url: 'www.example.com', pageviews: 52}
)

db.users.updateOne({url: 'www.example.com'},
    {$inc: {pageviews: 1}})

db.users.find()
```

#### Getting started with `$set`

`$set`sets the value of a field. If the field does not exist, created. This can be handy fo updating schemas or adding user-defined keys.

```js
db.users.insertOne( {
    "name" : "joe",
    "age" : 30,
    "sex" : "male",
    "location" : "Wisconsin"
});

db.users.updateOne({_id: ObjectId('67b278540d15314f3d3462f3')},
    {$set: {'favorite book': 'War and peace'}})
```

And, if the users decides that he actually enjoys a different book `$set`can be used again to change the value like:

```js
db.users.updateOne({_id: ObjectId('67b278540d15314f3d3462f3')},
    {$set: {'favorite book': 'Green Eggs and Ham'}})
```

`$set`can even change the type of the key it modifies, note that like:

```js
db.users.updateOne({_id: ObjectId('67b278540d15314f3d3462f3')},
    {$set: {'favorite book': ['Green Eggs and Ham',
        'Peace and War']}});
```

If the user realizes that he actually doesn’t like reading, just remove the key altotegher with `$unset`operator like:

```js
db.users.updateOne({_id: ObjectId('67b278540d15314f3d3462f3')},
    {$unset: {'favorite book': 1}});
```

Can also use `$set`to reach and change embedded documents like:

```js
db.posts.posts.insertOne (
    {
        "title" : "A Blog Post",
        "content" : "...",
        "author" : {
            "name" : "joe",
            "email" : "joe@example.com"
        }
    }
)

db.posts.posts.find()

db.posts.posts.updateOne({ "author.name" : "joe"},
    {$set: {"author.name" : "Joe Schome"}})
```

Note that must always use a `$`modifier for adding, changing, or removing keys -- A common error people make when starting do like: 

```js
db.blog.posts.updateOne({'author.name': 'joe'}, {'author.name': 'joe schome'});
```

This will result in an error. The udpate document must contain *update operators*.

### Increment and decrement

The `$inc`operator can be used change the value for an existing key *or to create a new key* if it does not already exist.

```js
db.games.insertOne({"game" : "pinball", "user" : "joe"})
db.games.updateOne({game: 'pinball'}, {$inc: {score: 50}})
```

For now the `score`key did not already exist, so was create by the `$inc`and set to the increment amount: 50. Then:

```js
db.games.updateOne({game: 'pinball'}, {$inc: {score: 1000}})
```

For now the score is 1050. And the `$inc`is similar to `$set`, but it designed for incrementing and decrementing nubmers. And `$inc`can be used only on values of type integer, long... or decimal.

## When to use generics

Go 1.18 adds generics to the language, in a nutshell, this allows writing code with types that can be specified later and instantiated when needed. However, it can be confusing about when to use generics and when not to. Fore:

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k:= range m {
        keys= append(keys, k)
    }
    return keys
}
```

What if want to use a similar feature for another map type such as `map[int]string`-- Before generics, Using code generation, reflection, or duplicating code. like:

```go
func getKey(m any) ([]any, error) {
    switch t := m.(type) {
    default:
        return nil, fmt.Errorf("unknown type: %T", t)
    case map[string]int:
        var keys []any
        for k := range t {
            keys = append(keys, k)
        }
        return keys, nil
    }
    case map[int]string:
    	//... same logic
}
```

With this, start to nitice a few issues -- it increases boilerplate code. The function now accepts an `any`type -- whcih means that we lose some of the benefits of Go as a typed language. Checking whether a type is supported is done at run time instead of compile time.

Type parameters are generic types that can use with functions and types. Fore

```go
func foo[T any] (t T) {
    //...
}
```

When calling `foo`, pass a type argument of `any`type, supplying a type arg is called *instantiation*, and the work is done at *compile time*. This keeps type safety as part of the core language features and avoids run-time overhead.

```go
func getKeys[K comparable, V any](m map[K]V) []K {
    var keys []K
    for k := range m {
        keys = append(keys, k)
    }
    return keys
}
```

To handle the map, defined two kinds of type parameters, first the values can be of the any type `V`, the map’s keys can’t be of the `any`, so, restricting type arguments to match specific requirements is called a *constraint* -- A constraint is an interface type that can contain -- 

- A set of behaviors
- Arbitrary types

```go
type customConstratin interface {
    ~int | ~string
}
func getKeys[K customConstraint, V any](m map[K]V) []K {
    // same
}
```

#### Common uses and misuses

When are generics useufl -- discuss a few common uses where generics are recommended -- 

- *data Structures* -- can use generics to factor out the element type if we implement a binary tree, linked list...

- *functions working with slices, maps, and channesl of **any** type*. -- A function to merge two channels would work with any channel type fore. like:

  ```go
  func merge[T any](ch1, ch2 <-chan T) <-chan T{...}
  ```

- Factoring out behaviors instead of types -- for the `sort`

  ```go
  type SliceFn[T any] struct {
  	S       []T
  	Compare func(T, T) bool
  }
  
  func (s SliceFn[T]) Len() int {
  	return len(s.S)
  }
  
  func (s SliceFn[T]) Less(i, j int) bool {
  	return s.Compare(s.S[i], s.S[j])
  }
  
  func (s SliceFn[T]) Swap(i, j int) {
  	s.S[i], s.S[j] = s.S[j], s.S[i]
  }
  
  func main() {
  	s := SliceFn[int]{
  		S: []int{2, 3, 1},
  		Compare: func(a, b int) bool {
  			return a < b
  		},
  	}
  
  	sort.Sort(s)
  	fmt.Println(s.S)
  }
  ```

And, conversely, when is it recommended that we should **NOT** use generics -- 

- When calling a method of the type argument -- consider a function that receives an `io.Writer`and calls the `Write`method like: `func foo[T io.Writer](w T) {}`
- When it makes the code more complex.

### Type embedding

When creating a struct, Go offers the option to embed types. This can sometimes lead to unexpected behavior. Remind -- For an example of a *wrong usage* -- implement a struct that holds some in-memory data, and want to protect it against concurrent accessing using mutex like:

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem {
    return &InMem{m: make(map[string]int)}
}
```

Decide to make the map *unexported* so that client can’t interact with it directly but only exported methods.

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

Since, `sync.Mutex`is embedded, the `Lock()`and `Unlock()`will be promoted. Therefore, both methods become visiable to external clients using `InMem`like: This promotion is not desired -- A mutex is in most cases, sth that we want to encapsulate within a struct and make invisible to external clients. Therefore, shouldn’t make it an embedded field:

```go
type InMem struct {
    mu sync.Mutex
    m map[string]int
}
```

## Communicating using message passing

Message passing is another way to enable *inter-thread communication (ITC)*. Which is when goroutines send messages to or wait for messages from other goroutines.

#### Passing messages with Channels

A Go channel lets two or more goroutines exchange messages. Conceptually, can thinks of a channel as being a direct link between our goroutines. What would happen if a goroutine were to push a message on a channel without there being another goroutine to read that message -- Go’s channel are synchronous by default, sender will block until there ia s recevier ready to consume the message.

```go
func receiver(messages chan string) {
    time.Sleep(5*time.Second)
    fmt.Println("receive... 5 seconds")
}
```

Since no other goroutine is available to consume `messages`from the channel - Go’s runtime realizes this and raises the fatal error -- without this error, our program would stay blcoked until we manually terminate it and the same situation occurs if have a receiver for a message and no sender is available.

#### Buffering messages with channels

Although are sync, can configure them so that they store a number of messages before block. The channel will keep on storing messages as capacity remains in the buffer. Once buffer if filled up, then sender will block again. Note that once a receiver is available to consume the messages, the messages are fed to the receiver in the same order they were sent. This happens even if the sender goroutine is no longer sending any new messages.

Once the receiver goroutines consumes all the messages and the buffer is empty - the reciever will again block. When the buffer is empty, a receiver will block if we don’t have a sender or if the sender is producing messages at a slower rate than the receiver can read them.

```go
func receiver(messages chan int, wGroup *sync.WaitGroup) {
    msg := 0
    for msg != -1 {
        time.Sleep(time.Second)
        msg <- message
        fmt.Println("Received:", msg)
    }
    wGroup.Done()
}

// Write a main that creates a buffered and feeds messages into at a *fatser* rate
func main() {
    msgChannel := make(chan int, 3)
    wGroup := sync.WaitGroup{}
    wGroup.Add(1)
    go receiver(msgChannel, &wGroup)
    for i:=1; i<=6; i++ {
        size := len(msgChanenl) // read the number of messages on the buffered channel
        fmt.Printf("sending...%d, %d", i, size)
        msgChanenl <- i
    }
    msgChannel <- -1
    wGroup.Wait()
}
```

#### Assigning a direction to channels -- 

Go’s channels are *bidirectional* by default, This means that a goroutine can act as both a receiver and a sender of messages -- however, can assign a direction to a channel so that the goroutine using the channel only send or receive messages -- when declare a function parameters -- can specify the direction of the channel.

```go
func receiver(messages <-chan int) {
    for {
        msg := <-messages
        //...
    }
}
func sender(messages chan<- int) {
    for i:=1;; i++ {
        messages <-i
    }
}
```

#### Closing Channels

Instead of using *sentinel value* message, Go allowss us to close a channel -- can do this in code by calling the `close(channel)`function. Once close a channel, shouldn’t send any more. Fore:

```go
func receiver(message <-chan int) {
    for {
        msg: <-messages
        //...
    }
}

func main() {
    msgChannel := make(chan int)
    go reciever(msgChannel)
    //...
    close(msgChannel)
}

// jus using range operator like:
func receiver (messages <-chan int) {
    for msg := range messages {
        fmt.Println(time.Now().Format("15:04:05"), "received", msg)
        time.Sleep(time.Second)
    }
    fmt.Println("receiver finished")
}
```

## Custom template functions

Explain how to create your own custom functions to use in Go templates -- To issulate -- create a `humanDate()`which outputs datetimes in a nice format. Two main steps to doing this like:

- Need to create a `template.FuncMap`object containing the custom `humanDate()`function
- Need to use the `template.Funcs()`method to register this before parsing templates.

```go
func humanDate(t time.Time) string {
    return t.Format("02 Jan 2006 at 15:04")
}

// Initialize a template.FuncMap object and store it in a *global* variable
var functions = template.FuncMap{
    "humanDate": humanDate,
}

func newTemplateCache() (map[string]*template.Template, error) {
    cache := map[string] *template.Template{}
    pages, err := filepath.Glob("./ui/html/pages/*.html")
    if err != nil {
        return nil, err
    }
    
    for _, page := range pages {
        name := filepath.Base(page)
        
        // The template.FuncMap must be registered with the template set before you call
        // ParseFiles() -- so have to use the template.New() to create an empty one
        ts, err := template.New(name).Funcs(functions).ParseFiles("./ui/html/base.html")
        if err != nil {
            return nil, err
        }
        ts, err = ts.ParseGlob("./ui/html/partials/*.html")
        if err != nil {
            return nil, err
        }
        ts, err = ts.ParseFiles(page)
        if err != nil {
            return nil, err
        }
        cache[name]=ts
    }
    return cache, nil
}
```

Custom template functions can accept any number parameters as they need to , but *must* return one value only. Can return an error as the second value. like: `{{humanDate .Created}}`

#### Pipelining

An alternative approach is to use the `|`character to *pipeline* values to a function like:

```html
<time>Created {{.Created | humanDate}}</time>
<time>{{.Created | humanDate | printf "Created:%s"}}</time>
```

Middleware -- A common way of organizing shared functionality is to set it up as *middleware*.

- An idiomatic pattern for *building and using custom middleware* which is compatible with `net/http`
- How to create middleware which sets useful security headers on every HTTP response.
- How to create middleware which logs the requests received by your app.
- How to create middleware which *recovers panics* so that they are gracefully handled by your app.
- How to create and use composable middleware chains to help manage and organize your middleware.

### How Middleware works

The basic idea of middleware is to insert another handler into this chain. -- Chain -- When our server receives a new HTTP request it calls the servemux’s `ServeHTTP`method -- this looks up the relevant handler based on the request URL path, and in turn calls the handler’s `ServeHTTP()`method -- the basic idea of middleware is insert another handler into this chian. The middleware handler executes some logic, like logging...And then calls the `ServeHTTP()`of the `next`handler in the chain.

#### The pattern

```go
func MyMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

#### Positioning the middleware

It’s important to explain that where you position the middleware in the chain of handlers will affect the behavior of your application. If U position your middleware before the `serveMux`in the chain -- it will act on every request.

### Setting security headers

```go
func secureHeader(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header.Set("Content-Secuirty-Policy",
                    "default-src 'self' ...")
        //...
        w.Header().Set("X-XSS-Protection", 0)
        next.ServeHTTP(w, r)
    })
}
```

And, cuz Want this middleware to act on every request that is received, need it to be executed *before* a request hits our servemux. so: `secureHeaders-> serveMux -> app handler`

```go
func (app *application) routes() http.Handler {
    mux := http.NewServeMux()
    //...
    return secureHeaders(mux)
}
```

#### Flow of control -- 

It’s important to know that when the last handler in the chain returns, control is passed back up the chain in the reverse direction.

```go
func MyMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Requst)) {
        // any code here will execute on the way down the chain
        next.ServeHTTP(w, r)
        // code will execute on the way up the chain.
    }
}
```

#### Early returns -- 

Another to mention -- If call `return`in your middleware function *before* call `next.ServeHTTP`, then the chain will stop being executed and control will flow back upstream. As an example, a common use-case fo early returns is authentication middlewaer which only allows execution of the chain to continue -- fore:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Requst) {
        if !isAuthorized(r) {
            w.WriteHeader(http.StatusForbidden)
            return // early return
        }
        next.ServeHTTP(w,r)
    })
}
```

#### Request logging

Continue in the same vien and add some middleware to log HTTP requests -- Specifically, we are going to use the *information logger* that created earlier to record the IP address of the user.

```go
func (app *application) logRequest(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Requset) {
        app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr, r.Proto, r.Method, r.URL.RequestURI())
        next.ServeHTTP(w,r)
    })
}
```

Just noticed that this time implementing the middleware as a method on `application`. The middleware method has the same signature as before, but cuz it is a method against `application`it also has access to the handler dependencies including the information logger.

```go
func (app *application) routes() http.Handler{
    //...
    // wrap the existing chain with the logRequest middleware
    return app.logRequest(secureHeaders(mux))
}
```

#### Panic recovery

In a simple Go application, When code panics, it will result in the app being terminated straight away. But our web app is a bit more sophisticated -- Just log, unwind the stack, and close the underlying http connection. It would be more appropriate and meaning ful to send them a proper HTTP response with a 500 code.

A neat way of doing this is to create some middleware which recovers the panic and calls our `app.serverError()`.

```go
func (app *application) receoverPanic(next http.Handler) http.Handler {
    return http.HandlerFunc(func (w http.ResponseWriter, r *http.Request) {
        defer func() {
            if err := recover(); err != nil {
                // setting the `Connection: Close`
                // automatically close the current connection
                w.Header.Set("Connection", "close")
                app.serverError(w, fmt.Errorf("%s", err))
            }
        }()
    })
    next.ServeHTTP(w,r)
}

//...
func (app *application) routes() http.Handler {
    //...
    return app.reoverPanic(app.logRequest(secureHaders(mux)))
}
```

It’s just important to realise that our middleware will only recover panics that happens in the *same* goroutine that executed the `reoverPanic()`middleware. If are spinning up additional goroutines from within your web apps and there is any chance of a panic -- 

```go
func myHandler(...) {
    go func() {
        defer func() {
            if err := recover(); err != nil {
                //...
            }
        }()
        sosthPackgroundProcessing()
    }()
    w.Write([]byte("OK"))
}
```

