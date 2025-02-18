# MDB Array Operators

An extensive classes of update operators exists for manipulating arrays -- Adding elements -- `$push`adds elements to the *end* of an array if the array *exists* and creates a new array if it does not.

```js
db.posts.findOne();

db.posts.updateOne({'title': 'Hello World'},
    {$push: {tags: 'mongodb'}}
    );
// if want another, just simply use $push again
```

This is just the *simple* form of push, can also use it for more complex array operations as well. The MDB query language provides modifiers for some operators,  push multiple values in one operation using the `$each`modifier:

```js
db.posts.updateOne({title:'Hello World'},
    {$push: {tags: {$each: ['news2', 'news3']}}}) // would push 2 elements on to the array
```

And if want to grow to certain langth, can use the `$slice`modifier with `$push`to prevent an array from growing beyond a certain szie: Making a *topN* list of items. like:

```js
db.posts.updateOne({title:'Hello World'},
    {$push: {tags: {$each: ['news4', 'news5'], $slice: -5}}})
```

If array smaller than 5 elements, all will be kept, if larger, last 5 kept.

Can also apply the `$sort`modifier to `$push`operation before trimming like:

```js
db.movies.updateOne({'genre': 'horror'},
                    {$push: {top10: {$each: [{...}], $slice: -10, $sort: {rating: -1}}}})
```

#### Using arrays as sets

Might want to treat an array as set -- only adding values if they are not present -- this can be done using the `$ne`in the query, can like:

```js
db.papers.updateOne({'author cited': {$ne: "Richie"}},
                   {push: {'author cited': 'Richie'}})
```

This can also be done with the `$addToSet`-- which is useful for `$ne`won’t work. like:

```js
db.users.insertOne({
    "username" : "joe",
    "emails" : [
        "joe@example.com",
        "joe@gmail.com",
        "joe@yahoo.com"
    ]
})

db.users.find()

db.users.updateOne({_id: ObjectId('67b3c0e9bd24f73a7af09482')},
    {$addToSet: {emails: 'joe@hotmail.com'}})
```

Can also use `$addToSet`in conjunction with the `$each`to add multiple unique values.

```js
db.users.updateOne({_id: ObjectId('67b3c0e9bd24f73a7af09482')},
    {$addToSet: {emails: {$each: ['joe@hotmail.com',
            'joe@example2.com']}}})
```

#### Removing elements

There are a few ways to remove elements from an array -- if you want to treat the array like queue or a stack, can use the `$pop`, which can remvoe elements from either end like `{$pop: {‘key’: 1}}`removes the element from the end of the array, and `{$pop: {‘key’:-1}}`removes it from the beginning.

Sometimes an element should be removed based on specific criteria, `$pull`is used to remove elements on specific -- 

```js
db.lists.insertOne(
    {'todo': ['dishes', 'laundry', 'dry cleaning']}
)

db.lists.updateOne({}, {$pull: {todo: 'laundry'}})

db.lists.find()
```

Pulling removes all matching documents, not just a single match. Array operators can be used only on keys with array values.

#### Positional array modifications

Array manipulateion becomes a little trickier when have multiple values in an array and want to modify some of them -- Use *0-based* indexing, and elements can be selected as though their index were a document key.

```js
db.posts.updateOne({_id: ObjectId('67b3cb00bd24f73a7af09486')},
    {$inc: {'comments.0.votes': 1}})

db.posts.findOne({_id: ObjectId('67b3cb00bd24f73a7af09486')})
```

In many cases, you don’t know what index of the array of modify without querying for the document first and examining it. Mdb hs a positional operator `$`which figures out which element of the array the query document matched and updates that element like:

```js
db.posts.updateOne({'comments.author': 'John'},
    {$set: {'comments.$.author': "Jim"}})
```

The positional operator updates only the first match.

#### Updating using array filters -- 

Introduced another -- updating individual array elements -- `arrayFilters`-- 

```js
db.posts.updateOne({_id: ObjectId('67b3cb00bd24f73a7af09486')},
    {$set: {'comments.$[elem].hidden': true}},
    {arrayFilters: [{'elem.votes': {$lt: -3}}]})
```

This command defines `elem`as the identifier for each matching element in the `comments`array.

## Functional options pattern

When designing an API, one question may -- how we deal with optional configuration -- Sloving this problem effciently can improve how convenient our API will become. Fore, design a library that exposes a function to create an HTTP server -- would accept different inputs -- fore:

```go
func NewServer(addr string, port int) (*http.Server, error) {}
```

For this -- the client of our library have started to use this func, and everyone ok. Noticed that adding new function parameters just breaks the compatibility -- forcing the clients to modify the way the call `NewServer`.

#### Config Struct

Cuz Go doesn’t support optional parameters -- the first possible approach is to sue a configuration struct to convey what is mandatory and what is optional. The mandatory parameters could live as function parameters, the optoinal ones could be handle in the `Config`struct like:

```go
type Config struct{
    Port int
}
func NewServer(addr string, cfg Config) {...}
```

In the case, need to find a way to distinguish between a port purposely set to 0 and a missing port. So:

```go
type Config struct {
    Port *int
}
```

Using pointer, can highlight the difference between value 0 and a missing value - `nil`pointer. This works, but it has a couple of downsides -- not handy, the client have to:

```go
port := 0
config := httplib.Config{
    Port: &port,
}
```

It’s not good -- And the second downside is tthat a client using lib with the default configuration pass like:

`httplib.NewServer(“localhost”, httplib.Config{})`-- not look good

#### Builder pattern

Gang of Four design patterns -- the builder pattern provides a flexible solution to various object-creation problems. The construction of `Config`is separated from the struct itself, it requires an extra struct -- `ConfigBuilder`, which recieves methods to configure and build a `Config`-- 

```go
type Config int {
    Port int
}
type ConfigBuilder struct {
    port *int
}
func (b *ConfigBuilder) Port(port int) *ConfigBuilder {
    b.port= &port
    return b
}
func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port == nil {
        cfg.Port = defaultHTTPPort
    }else {
        if *b.port == 0 {
            cfg.Port= randomPort()
        }else if *b.port<0 {
            return Config{}, errors.New("Port should be positive")
        }else {
            cfg.Port= &b.port
        }
    }
    return cfg, nil
}
func NewServer(addr string, confg Config) (*http.Server, error) {}
```

For this, the `ConfiguBuilder`struct holds the client configuration -- it exposes a `Port`method to set up the port, usually, such a configuration methods returns the builder itself so taht can use method chaining. Also, exposes a `Build`method that holds the logic on initializing the port value and returns a `Config`struct once created.

Then a client would use API in the following manner like:

```go
builder := http.ConfigBuilder{}
builder.Port(8080)
cfg, err := builer.Build()
if err != nil {
    return err
}
server, err := httplib.NewServer("localhost", cfg)
if err != nil {
    return err
}
```

For this, makes port management handier -- it’s not required to pass integer poitner.

#### Functional options pattern

The main idea is as -- 

- An unexported struct holds the configuration --  `options`
- Each option is a *function* that returns the same type `type Option func(options *options) error`

```go
type options struct  {
    port *int
}
type Option func(options *options) error

func WithPort(port int) Option {
    return func(optiosn *options) error {
        if port <0 {
            return errors.New("port should be positive")
        }
        options.port=&port
        return nil
    }
}
```

There the `WithPort`returns a closure -- is an anonymous function that references variables from outside its body.

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _l, opt:= range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    
    var port int
    if options.port == nil {
        port= defaultHTTPPort
    }else {
        if options.port ==0 {
            port= randomPort()
        }else{
            port= *options.port
        }
    }
}
```

Starting by creating an empty `options`, iterate over each `Option`argument and executed them to mutate the `options`struct -- once the `option`struct built, can implement the final logic regarding port mangaement.

```go
server, err := httplib.NewServer("localhost", httplib.WithPort(8080), 
                                 httplib.WithTimeout(time.Second))
```

### Selecting Channels

The `select`statement lets us group read operations on multiple channels together, blocking the goroutine until a message arrives on any one of the channels. Once a message arrives on any of the channel, the goroutine is unblocked, and a code handler for that channel is run. like:

```go
func writeEvery(msg string, seconds time.Duration) <-chan string {
    messages := make(chan string)
    go func() {
        for {
            time.Sleep(seconds)
            messages <-msg
        }
    }()
    return messages
}
```

Note that Channels are *first-class* objects - means that we can store them as variables, pass or return them from functions, or even send them on a channel.

```go
func main(){
    messageFromA := writeEvery("tick", time.Second)
    messageFromB := writeEvery("tock", 3*time.Second)
    for {
        select {
        case msg1:= <-messageFromA:
            fmt.Println(msg1)
        case msg2:= <-messageFromB:
            fmt.Println(msg2)
        }
    }
}
```

Note -- when using `select`, if multiple cases are ready, a case is chosen *at random*.

#### Using `select`for non-blocking channel operations

Another use case for `select`is when need to use channels in a non-blocking manner. Fore, saw that Go provides a non-blocking `tryLock()`operation -- this call tries to acquire the lock, but if the lock is being used, it will return immediately with a `false`. And the `select`statement gives us the *default case* for exactly this scenario -- The instructions under the default will executed if none of the other cases is available.

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
    messages := make(chan string)
    go func() {
        time.Sleep(seconds)
        messages <- "Hello"
    }()
    return messages
}
func main() {
    messages := sendMsg(3*time.Second)
    for {
        select {
        case msg:= <-messages:
            fmt.Println(msg)
            return
        default:
            fmt.Println("no message waiting")
            time.Sleep(time.Second)
        }
    }
}
```

#### Performing concurrent computations on the default case

```go
func toBase27(n int) string {
	result := ""
	for n > 0 {
		result = string(alphabet[n%27]) + result
		n /= 27
	}
	return result
}
```

For this, if had to use a brute force approach in a sequential program, would just create a loop enumerating all strings. To find pwd faster, can divide the range of our guesses among several goroutines --  And to avoid unnecessary computations, we can use a channel to notify all other when one execution disvovers the pwd. One solution is to perform the necessary computation in the `select`default case.

```go
func guessPassword(from int, upto int, stop chan struct{}, result chan string) {
	for guessN := from; guessN < upto; guessN++ {
		select {
		case <-stop:
			fmt.Printf("Stopped at %d [%d,%d]\n", guessN, from, upto)
			return
		default:
			if toBase27(guessN) == passwordToUse {
				result <- toBase27(guessN)
                   // close the channel so that other stop checking
				close(stop)
				return
			}
		}
	}
	fmt.Printf("Not found between [%d,%d]\n", from, upto)
}
```

Then can create several goroutines executing the previous listing -- each goroutine will try to find the correct pwd within a certain range --like:

```go
func main(){
    finished := make(chan struct{})
    passwordFound := make(chan string)
    for i:=1; i<=...; i+= 10000000 {
        go guessPassword(i, i+1000000, finshed, passwordFound)
    }
    <-passwrodFound
}
```

#### Timing out on channels -- 

Another useful scenariois blocking for only a specified amount of time -- waiting for an operation on a channel -- want to check to see whether a message has arrired on a channel, but want to wait for a few seconds to see if a message arrives -- instead of unblocking immediately and doing sth else.

The `time.Timer`type in Go provdies us with this functionality - Can just create one of these timers by calling the `time.After(duration)`-- will return a channel on which a message is sent after the duration time elapsed.

```go
func main() {
    t, _ := strconv.Atoi(os.Args[1])
    messages := sendMsgAfter(3*time.Second)
    timeoutDuration := time.Duration(t)*time.Second
    fmt.Printf("waiting for message for %d seconds...\n", t)
    select {
    case msg:= <-messages:
        fmt.Println(msg)
    case tNow := time.After(timeoutDuration): // return current timestamp
        fmt.Println(tNow.Foramt("15:04:05"))
    }
}
```

#### Panic recovery in other background goroutines -- 

It’s important to realise that our middleware will only recover panics that happen in the *same goroutine* that executed the `recoverPanic()`middleware. Fore, have a handler which spins up another goroutine, then any panic that happen in the second gorotuine will not be recovered - not by the `recoverPanic()`middleware.

```go
func myHandler(w http.ResponseWriter, r *http.Request) {
    // ...
    // spin up a new goroutine to do some background processing
    go func() {
        defer func() {
            if err := recover(); err != nil {
                log.Println(...)
            }
        }()
        dosomeBackgroundProcessing()
    }()
}
```

## Composable middleware chains

In this, introduce the `justinas/alice`package to help us manage our middleware/handler chains. It makes it easy to create composable, reusable, middleware chains -- and that can be a real help as your application grows and your routes become more complex. 

```go
return myMiddleware(myMiddleware2(myHandler))
return alice.New(myMiddleware, myMiddleware2).Then(myHandler)
```

And the real power lies in the fact that you can use it to create middleware chins that can be assigned to variables, appended to, and reused like:

```go
myChain := alice.New(myMiddlewareOne, myMiddlewareTwo)
myOtherChain := myChain.Append(myMiddleware3)
return myOtherChain.Then(myHandler)
```

```sh
go get github.com/justinas/alice@v1
```

Then update our routes.go file to use this like:

```go
standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
// return the standard middleware chain followed by the servemux
return standard.Then(mux)
```

### Advnaced routing

In the next section of this book going to add a HTML form to our app so that users can create new snippets -- To make this work smoothly, first need to update our application routes so that requests to `/snippet/create`are handled differently based on request method.

There are literally 3rd-parties for Go to pick from.

- `julienschmidt/httprouter`-- is the most focused, lightweight and fastest of the 3 packages. Automatically handles `OPTIONS`and sends `405`responses correctly.
- `go-chi/chi`-- generally similar to `httprouter`in terms of its features. also supports regexp route patterns and grouping of routes which use speific middleware.
- `gorilla/mux`is most *full-featured* of the 3 routers. Main downside of `gorilla/mux`is that it’s comparatively slow and memory hungry.

### Clean URLs and method-bsed routing

```sh
go get github.com/julienschmidt/httprouter@v1
```

```go
router := httprouter.New()
router.HandlerFunc(http.MethodGet, "snippet/view/:id", app.snippetView)
```

Patterns can include *named parameters* in the form `:name`-- which act like a wildcard for a specific path segement. Pattern can also include a single *catch-all* parameter in the form `*name`-- these match everything like: `/static/*filepath`, and the pattern `/`will only match requests where the URL path is exactly `/`.

```go
func (app *application) routes() http.Handler {
	router := httprouter.New()
	
	// update the pattern for the route for the static file
	fileServer := http.FileServer(http.Dir("./ui/static/"))
	
	// serve a specific static file
	router.Handler(http.MethodGet, "/static/*filepath", 
		http.StripPrefix("/static", fileServer))
	router.HandlerFunc(http.MethodGet, "/", app.home)
	router.HandlerFunc(http.MethodGet, "/snippet/view/:id", app.snippetView)
	router.HandlerFunc(http.MethodGet, "/snippet/create", app.snippetCreate)
	router.HandlerFunc(http.MethodPost, "/snippet/create", app.snippetCreatePost)

	standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)

	// return the standard middleware chain followed by the servemux
	return standard.Then(mux)
}
```

And there are a few changes we need to make to our `handlers.go`like:

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
	// when using httprouter, the values of any named parameters will be stored
	//in a request context
	params := httprouter.ParamsFromContext(r.Context())
	
	id, err := strconv.Atoi(params.ByName("id"))
	if err != nil || id<1 {
		app.notFound(w)
		return
	}

	//...
}
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Displaying the form for creating a new snippet..."))
}
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {

	title := "0 snail"
	content := "O snail\nClimb Mount Fuji,\nBut slowly, slowly!\n\n– Kobayashi Issa"
	expires := 7

	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}
	http.Redirect(w, r, fmt.Sprintf("/snippet/view?id=%d", id), http.StatusSeeOther)
}
```

Finally, need to update the table in the `home.html`so that the links in the HTML also use the new clean URL.

`<td><a href="/snippet/view/{{.ID}}">{{.Title}}</a></td>`

Can also see that requests using an unsupported HTTP method are met with a 405 method not allowed response.

#### Custom error handlers

If curl `/snippet/view/99`, return NotFound, and for `/missing`, return 404 page not found. The first one ends up calling out to our `app.notFound()`and the second use `httprouter`when no mathcing route found.

```go
// create a handler func which wraps our notFound() helper
router.NotFound = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    app.notFound(w)
})
```

#### Conflicting route patterns -- 

It’s important to be aware that `httprouter`doesn’t allow *conflicting route patterns* which potentially match the same request. Fore, cannot register a route like `GET /foo/new`and other -- if do need to support conflicting routes, need `chi`or `gorilla/mux`instead.

The `httprouter`also provides a few configuration options that you can use to customize the behavior of your app further, including enabling trailing slash redirects and automatic URL path cleaning.