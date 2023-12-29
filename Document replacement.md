# Document replacement

`replaceOne`fully replaces a matching document with a new one. This can be useful to do a dramatic schema migration. Fore:

```js
db.users.insertOne(
    {
        "_id" : ObjectId("4b2b9f67a1f631733d917a7a"),
        "name" : "joe",
        "friends" : 32,
        "enemies" : 2
    }
    )
```

want to just move the `friends`and `enemies`fields to a `relatinships`subdocument -- can change the structure of the document in the shell and then replace the dbs’ version with a `replaceOne`like:

```js
let joe = db.users.findOne({name: 'joe'});
joe.relationships=
    {
        friends: joe.friends,
        enemies: joe.enemies,
    };
joe.username=joe.name;
delete joe.friends;
delete joe.enemies;
delete joe.name;
db.users.replaceOne({name:'joe'}, joe);
```

And a common mistake is matching more then one document with the criteria and then creating a duplicate `_id`value with the second paramter. fore:

```js
joe= db.peopele.findOne({/*...*/});
joe.age++;
db.people.replaceOne({name: 'joe'}, joe);
```

Cuz it will attempt to replace that document with the one in the `joe`variable, but there is already a document in this collection with the same `_id`-- thus, the update will fail.

Uing the `Update`operators -- Usually certain portions of a document need to be updated, an update specific fields in a document using atomic `update opreators`.

```js
db.people.updateOne({url: 'www.example.com'},
    {$inc: {pageviews:1}})
db.people.findOne()
```

Note that when using operators, the vlaue of the `_id`cannot be changed -- Values for any other key, including other uniquely indexed keys, can be modified.

### Getting started with the `$set`modifier

`$set`sets the value of a field, if the field does not yet exist, it will be **created**. This can be just handy for updating schemas or adding user-defined keys.

```js
db.users.updateOne({"_id" : ObjectId("4b253b067525f35f94b60a31"),},
    {$set: {'favorite book':'war and peace'}});
```

And if the use decides that the actually enjoys a different book, `$set`can be used again to change the value like:

```js
db.users.updateOne({name: 'joe'},
    {$set: {'favorite book': 'Green eggs and ham'}});
```

Note that is the user realizes that he actually doesn’t reading, can remove the key using `$unset`like:

```js
db.users.updateOne({name: 'joe'},
    {$unset: {'favorite book': 1}});
```

Can also use `$set`to reach in and change the embedded documents like:

```js
db.blog.posts.updateOne({'author.name': 'joe'},
    {$set: {'author.name': 'joe schmoe'}})
```

Note that must alays use the `$`modifier for *adding, changing, removing* keys. A common error people make when starting out is to try to set the value of a key to some other vlaue by doing like:

```js
// error code!
db.blog.posts.updateOne({'author.name': 'joe'}, {'author.name': 'joe schmea'})
```

#### Incrementing and decrementing

The `$inc`operator can be used to change the value for an existing key or to create a new key if it does not already exist. It’s useful for updating analytics, karma.. fore, creating a game collectoin where we want to save games and update scores as they change, when a user starts playing -- like:

```js
db.games.insertOne({game: 'pinball', user: 'joe'})

// can just add some to non-exist value:
db.games.updateOne({game:'pinball'},
    {$inc: {score: 50}})
```

For this example, the `score`key did not yet exist, so it was created by `$inc`and set to the increment 50.

```js
db.games.updateOne({game:'pinball'},
    {$inc: {score: 10000}})
```

So, `$inc`is similar to `$set`-- but it is designed for increment, and decrement -- can be used on values of type `integer, long double decimal`.If it is used on any other type of vlaues, will fail -- includes types `boolean`. Also the value of the `$inc`key must be a number.

#### Array operators

An extensive class of update opertors exists for manipulating arrays. Arrays are common and powerful data structures, not only are lists that can be referenced by index, but can also double as sets.

Adding elements -- `$push`adds elements to the end of an array if the array exists and creates a new array if it does not.

```js
db.blog.posts.updateOne({'title': 'A Blog Post'},
    {$push: {comments:
                {name:'joe', email: 'joe@example.com',
                content:'nice post'}}})
```

Now, want to just add another comment, can simply use the `$push`again just like:

```js
db.blog.posts.updateOne({'title': 'A Blog Post'},
    {$push: {comments:
                {name:'bob', email: 'bob@example.com',
                content:'nice post from bob'}}})

db.blog.posts.findOne().comments
```

For this, is just the *simple* form of the `push`-- but can use it for more complex array operations as well, the MongoDB query langauge provides modifiers for some operators -- including `$push`. can push multiple values in one operation using the `$each`modifier for `$push`.

```js
db.stock.ticker.updateOne({_id: 'GOOG'},
    {$push: {hourly: {$each: [562.226,562.790, 559.123]}}})
```

This would push three new elements into the array. And if only want the array to grow to certain length, you can use the `$slice`modifier with `$push`to prevent an array from growing beyond a certain size.

```js
db.movies.updateMany({}, {$set: {genre: 'horror'}})
db.movies.updateOne({genre: 'horror'},
    {$push: {top10: {$each: ['Nightmare on', 'Saw'], $slice: -10}}})
```

This example limits the array to the last 10 element pushed. For this, if the array is smaller then 10 elements, all will kept, and if the array is larger then 10, only the last 10 will be kept.

```js
db.movies.updateOne({_id: 3},
    {$push: {top10: {$each: ['re1', 're2'], $slice: -3}}})
```

And, can apply the `$sort`modifier to `$push`opreations before trimming like:

```js
db.movies.updateOne({_id: 3},
    {$push: {top10: {$each: [
                    {name: 'ngithmare', rating:4.3},
                    {name: 'saw', rating: 5.6},
                    {name: 're2', rating: 9.5}
                ],
            $slice: -10,
            $sort: {rating: -1}}}})
```

#### Using arrays as sets

Might want to treat an array as a set -- only adding values if not present -- this can be done by using `$ne`in the query document like:

```js
db.papers.insertOne({'authors cited': 'Richie'});
db.papers.updateOne(
    {'authors cited': {$ne: 'Richie'}},
    {$push: {'author cited': 'Richie'}})  // no-op
db.papers.find()
```

And can also be done with `$addToSet`-- which is useful for cases where `$ne`won’t work where `$addToSet`describes what is happening better like: When adding another address, can use `$addToSet`to prevent duplicates: like:

```js
db.users.updateOne({
    "_id" : ObjectId("4b2d75476cc613d5ee930164"),
}, {$addToSet: {'emails': 'joe@example.com'}})

db.users.findOne({_id : ObjectId("4b2d75476cc613d5ee930164")}).emails
```

## Interface Pollution

It’s fairly common to see interfaces being over used in Go projects. Perhaps the developer’s background was C# or Java, and they found it natural to create interfaces before concrete types. Main caveat when programming meets abstractions is remembering that abstractions should be discovered, not created.

### Interface on the producer side

Saw in the previous section when interfaces are considered valuable.

- Producer side -- An interface defined in the same package as the concrete implemetnation.
- *Consumer side* -- An interface defined in an external package where it’s used.

It’s common to see developers creating interfaces on the producer side, along aide the concrete implemenation. This design is perhaps a habit from developers having a C# or a Java background.

Returning interfaces -- While designing a function signature, may have to return either an interface or a concrete implemenatation -- understand why returning an interface is -- in many cases, considered a bad practice.

`any`just syas nothing -- In Go, an interface type that specifies zero methods is known as empty -- after 1.18, the predeclared type `any`became an alias for an empty interface hence, all the `interface{}`occurrences can be replaced by `any`-- in many cases, `any`can be considered an overgeneralization, and as mentioned -- it doesn’t convey anthing. In assignment a value to `any`type, lose all type info, which requires a type assertion to get anything useufl out of the `i`.

### When to use gnerics

In a nutshell, this allows writing code with types that can be specified later and instantiated when needed. consider:

```go
func getKeys(m map[string]int) []string {
	var key []string
	for k := range m {
		key = append(key, k)
	}
	return key
}
```

So, what if we just want to use a similar feature for another map type such as a `map[int]string`fore. Before generics, Go developers had a few options, using code generation, reflection, duplicating code. Fore, could write two functions, one for each map type, or even try to extend `getKeys`to accept different map types like:

```go
func getKeys(m any) ([]any, error) {
	switch t := m.(type) {
	default:
		return nil, fmt.Errorf("unknown type: %T", t)
	case map[string]int:
		var keys []any
		for k := range t {
			keys = append(keys, k)
		}
		return keys, nil
	case map[int]string:
		//... like previous logic
	}
	return nil, nil
}

```

It increases boilerplate code -- when want to add a case, just need to duplicate the `range`loop. And lose the go’s static properties. Type parameters are just generic types that we can use with functions and types. fore:

```go
func foo[T any] (t T) {...}
```

When calling `foo`, pass a type argument of `any`type -- Supplying a type argument is called instantiation.

```go
func getKeys[K comparable, V any](m map[K]V) []K {
	var keys []K
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
```

To handle the map, define two kinds of type parameters, In Go, the map keys can’t be of the `any`type. Fore, cannot use slices -- `var m map[[]byte]int` -- Therefore instead of accepting any key type, obliged to restrict type arguments so that key type meets specific requirements. Restricting type arguments to match specific requirements is called *constraint*. Can contain:

- A set of behaviors
- Arbitrary types.

Fore, check out concrete example -- like:

```go
type customContraint interface {
    ~int | ~string
}
func getKeys[K customConstraint, V any](m map[K]V) []K {
    //...
}
```

First, define a `customConstraint`interface to restrict the type to be eigher `int`or `string`using the union operator, K is now a `customConstraint`insted of a *comparable* as before.

However, can also use generics with data structure can create a linked list like:

```go
type Node[T any] struct {
    Val T
    next *Node[T]
}
func (n *Node[T]) Add(next *Node[T]) {n.next=next}
```

Common uses and misuses -- 

- *DS* -- can use generics to factor out the element type if we implement a binary tree...
- Functions working with slices, maps, and channels of any type -- A function to merge two channels would work with any channel type.

```go
func merge[T any](ch1, ch2 <- chan T) <-chan T {...}
```

Factoring out behaviors of types -- like:

```go
type SliceFn[T any] struct {
    S []T
    Compare func(T, T) bool
}

func (s SliceFn[T]) Len() int {return len(s.S)}
func (s SliceFn[T]) Less(i, j int) bool {return s.Compare(s.S[i], s.S[j])}
```

### Possible problems with type embedding

Go just offers the option to embed types -- This can be sometimes lead to unexpected behaviors. FORE:

```go
type Foo struct {Bar}
type Bar struct {Baz int}
```

Here in the `Foo`, the `Bar`is declared without an assicoated name, it’s an embedded field. Use embedding to *promote* the fields and methods of an embedded type, cuz `Bar`contains a `Baz`, this is promoted to `Foo`.

`foo:=Foo{}
foo.Baz=42`

Note that the `Baz`is available from two different paths -- either from the promoted one using `Foo.Baz`or `Foo.Bar.Baz`.

Look an example of a wrong usage -- in the following, implement a structure that holds some in-memory data, and want to protect it against concurrent accessing using a mutex -- like:

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem {
    return &InMem{m: make(map[string]int)}
}
```

For this, decide to make the map just *unexported* so that client can’t interact with it directly but only via exported methods. meanwhile, the mutex field is embedded. Can:

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

for this, cuz the mutex is just embedded, can directly acecss the `Lock`and `Unlock`methods. Both methods become visible to external clients using `InMem`like:

```go
m := inmem.New()
m.Lock()
```

This promotion is probably not desired, -- in most cases, sth that want to encapsulate within a struct and make invisible to external clients. So:

```go
type InMem struct {
    mu sync.Mutex
    m map[string]int
}
```

For this, cuz the mutex isn’t embeeded and is unexported, it can’t be accessed from external code.

Additional -- Flow of control -- important to know that when the last handler in the chain returns, controls is passed back up the chain in the reverse direction. In any middleware handler, code which comes before `next.ServeHTTP()`will be executed on the way down and vice versa.

Early Returns -- Another thing to mention is that if you call `return`in middleware function *before* call `next.ServeHTTP()`, then then chain will stop being executed and control will flow back upstream. As an example, a common use-case for early returns is authentication middleware which only allows execution of the chain to continue if a particular check is passed. Like:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        //...
        if !isAuthorized(r) {
            w.WriteHeader(http.StatusForbidden)
            return
        }
        next.ServeHTTP(w,r)
    })
}
```

## Request Logging 

Specifically, going to use the *information* logger that we created earlier to record the IP address of the user, and which URL and method are being requested. Just like:

```go
func (app *application) logRequest(next http.Handler) http.Handler{
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        app.infoLog.Printf(...)
        next.ServeHTTP(w, r)
    })
}
```

### Panic Recovery

In a simple Go app, when the code panics -- it will result in the application being terminted straight away. But our web app is a bit more sophisticated -- Go’s http server assumes that the effect of any panic is isloated to the goroutine serving the active HTTP requst -- every request is handled in its own goroutine.

Specially, following a panic our server will log a stack trace to the server err log. unwind the stack for the affected goroutine and close the underlying HTTP connection -- but won’t terminate the app, so importantly, any panic in the handler *won’t* bring down the server.

`panic("Oops! sth went wrong")`

For this, isn’t great experience for the user, it would be more appropriate and meaningful to send them a proper HTTP response with a 500 status instead -- so a neat way of doing so is to create some middleware which *receover* the panics and calls `app.serverError()`helper -- can leverage the fact that deferred functions are always called when the stack is being unwound following panic so:

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// note, create a deferred function -- will always be run in the event
		// of a panic as go unwinds the stack
		defer func() {
			// use the builtin recover to check if there has been a panic
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				// then call the app.serverError helper method to return a 500
				app.serverError(w, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

- Settting the `Connection: Close`header on the response acts as a trigger to make Go’s HTTP server automatically close the current connection after a response has been sent. It also informs the user that the connection will be closed. -- NOTE that if the *http/2* -- Go will *automatically* strip this, and send a `GOAWAY`frame.
- The value returned by the builtin `recover()`has the type just `interface{}`underlying type could be `string, error`, just normalize this into an `error`using the `fmt.Errorf()`function to create a new `error`object containing the default textual representation of the `interface{}`.

### Additional info -- 

Panic recovery in other background goroutines -- It’s important to realise that our middleware will only recover panics that happen i*n the same gorutine* that executed the `recoverPanic()`middleware. So if are spinning up additional goroutines from within your web app and there is any chance of a panic, must make sure that your recover any panics from within those too. like:

```go
func myHandler(w http.ResponseWriter, r *http.Requests){
    //...
    go func() {
        defer func() {
            if err != receover(); err!=nil {
                log.Println(...)
            }
        }()
    }
}
```

### Composable Middleware Chains

Introduce the `justinas/alice`package to help us manage our middleware/handler chains. The reasons recommend it is cuz it makes it easy to create composable, reusable, middleware chains, and that can be a real help as your application grows and your routes become more complex. Fore:

```go
return myMiddleware1(myMiddleware2(myMiddleware3(myHandler))) // ===> 
return alice.New(myMiddleare1, myMiddleware2, myMiddleware3).Then(myHandler)
```

But the real power lies in fact that you can use it to create middleware chains that can be assigned to variables, appended to, and reused fore:

```go
myChain := alice.New(myMiddlewareOne, myMIddlewareTwo)
myOtherChain = myChain.Append(myMiddleware3)
return myOhterChain.Then(myHandler)
```

So, update like:

```go
func (app *application) routes() http.Handler {

	// create a middleware chain containing our 'standard' middleware
	// will be used for every request our app receives
	standardMiddleware := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
	mux := http.NewServeMux()
	//...
	return standardMiddleware.Then(mux)
}
```

It’s important to note that when rely on the *automatic* method to download packages like have done here -- go will always retreive the lastest version of the package.

### RESTful Routing -- 

Going to add a HTML form to our web application so that users can create new snippets -- To make the work smoothly, we are going to update our application routes so that requests to /snippet/create are handled differently based on the request method.

- For `GET /snippet/create`requests we want to show the user the HTML form for adding new
- For `POST /snippet/create`to just process this form data and then insert a new `snippet`record.

Another routing-related improvement would be use semantic URLs so that any variables are included in the URL path and not appended as a query string like:

- `GET`-- `/snippet/:id`

Making changes would give us an application routing structure that follows the fundamental principles of `REST`. And which should feel familar and logic to anyone who works on modern web applications.