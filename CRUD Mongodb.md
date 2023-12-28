# CRUD Mongodb

This covers the basic of moving data into and out of the dbs, including the following - 

- Adding new documents to a collection
- Removing documents from a collection
- Updating existing documents
- Choose the correct levels of safety vs. speed for all of these operations

### Insert Dcouments

```js
db.movies.insertOne({title:'stand by me'});
```

need to note the `inserOne()`will add an `_id`key to the document, and store the document in the mongodb.

`insertMany()`-- if need to insert multiple documents into a collection, can use `insertMany()`-- enables you to pass an array of documents to the dbs.

```js
db.movies.insertMany([
    {title:'Ghostbusters'},
    {title: 'E.T'},
    {title:'Blade Runner'},
]);
```

note that sending dozens, hundreds, or even thousands of documents at a time can make inserts faster. And `insertMany`is useful if are inserting multiple documents into a single collection. If are just importing raw data, fore from a data feed or SQL dbs, there are command-line tolls like *mongoimport* that can be used insted of a batch inserter. On the other hand, it is often handy to munge data before saving into the MongodB.

When performing a bulk insert using `insertMany`, if a document *halfway* through the array produces an error of some type -- what happens depends on whether you have opted for ordered or unordered operations. As the second paraemter to `insertMany`you may specify an options document. fore:

Specify `true`for the key `ordered`in the options document to ensure documents are inserted in the order they are just provided. Need to note specify `false`and Mongodb may reorder the inserts to increase performance. And *ordered inserts* is the default. For ordered, the array passed to the `insertMany`just defines the insertion order. And if document just produces an insertion error, no documents beyond that point in the array will be inserted. fore:

```js
db.movies.insertMany([
    {_id: 3, 'title': 'Sixteen Candles'},
    {_id: 4, 'title': 'The terminator'},
    {_id: 4, 'title': 'the princess'},
    {_id: 5, title: 'Scarface'}
], {ordered: false}); // will just insert 3, 4, 5
```

#### Insert validation

MongoDB does minimal checks on data being inserted, just checks the document’s basic structure and adds an `_id`field if one does not exist. One of the basic is size -- all documents must be smaller then 16M. These minimal checks also mean that is fairly easy to insert invalid data -- should only allow trusted sources.

insert -- `insert`are still supported for just backward compability.

### Removing Documents

The CRUD API provides `deleteOne`and `deleteMany`for this purpose, Both of these methods take a filter document as their first parameter. the filter just specifies a set of criteria to match against in remving documents. To delete the document with the `_id`vlaue of 4, use the `deleteOne`in the *mongo* shell fore:

```js
db.movies.deleteOne({_id:4});
```

For this, used a filter that could only match one document since `_id`values are just unique in a collection. However, can also specify a filter that matches multiple documents in a collection. In this case, `deleteOne`will delete the first document fond that matches the filter. And, which document is found first depends on several factors, including the order in which the documents were inserted, what updates were made to the documents.

```js
db.movies.deleteMany({'year': 1984})
```

drop -- It is possible to use the `deleteMany`to remove all in a collection -- just:
`db.movies.deleteMany({})`

And removing documetns is usually a fairly quick options, however, if want to clear an entire collection, just:
`db.movies.drop()`

### Updating Docments --

`updateOne, updateMany, replaceOne`-- update* each take a filter document as their first parameter and a modifier document, which describes changes to make, as the second parameter and the `replaceOne`-- also takes a filter -- but the second expeects a document with which it will replace the document matching the filter.

And, updating document is atomic -- if two updates happen at the same time, whichever one reaces the server first will be applied, and then the next one will be applied -- thus, conflicting updates can safely be sent in rapid. The last update will win.

Document replacement -- `replaceOne`fully replaces a matching document just with a new one -- can be useful to do a dramatic schema migration. FORE:

```js
let joe = db.test.findOne({name: 'joe'});
joe.relationships= {firends: joe.friends.value,
    enemies: joe.enemies.value};
joe.username=joe.name;
delete joe.friends;
delete joe.enemies;
delete joe.name;
db.test.replaceOne({name:'joe'}, joe);
```

A common mistake is matching more then one document with the criteria and then create a duplicate `_id`with the second parameter. The dbs will just throw an error.

```js
let joe = db.people.findOne({'name': 'joe', age: 20});
joe.age++;
db.people.replaceOne({'name': 'joe'}, joe); // error E11001
```

When do the update, the dbs will look for a document matching -- `{name: 'joe'}`-- the first one is 65.. will then:
`db.people.replaceOne({_id: joe._id, 'name': 'joe'}, joe);`

Just using `_id`for the filter will also be efficient since `_id`values from the basis for the primary index of a collection.

#### Using update Operators

Usually, certain portions of a document need to be updated - can update specific fields in a document using atomic *update operators*. Update operators are special keys that can be used to specify complex update operations. Update oprators are special keys that can be used to specify complex update operations -- altering, adding, removing keys.

Fore, keeping website analystics in a collection and want to just increment a counter each time someone visites a page. Then can use update operators to do this increment automatically like:

```js
db.people.insertOne(
    {
        "_id" : ObjectId("4b253b067525f35f94b60a31"),
        "url" : "www.example.com",
        "pageviews" : 52
    }
    )
db.people.updateOne({url: 'www.example.com'},
    {$inc: {pageviews:1}});
```

When using operators, the value of `_id`cannot be changed -- Note that the `_id`can be changed by using just the whole-document *replacement* -- values for any other key, including other uniquely indexed keys, can e modified.

Start with the `$set`modifier -- `$set`sets the value of a field, note that if that field does not yet exist, *it will be created.* -- This can be handy for updating schemas or adding user -- defined keys. FORE, suppore have a simple user profile stored as a document that looks something like following -- 

```js
db.people.updateOne({
    "_id" : ObjectId("4b253b067525f35f94b60a31"),
},
    {$set: {'favorite book': 'War and Peace'}});
```

And if the user decides that he actually enjoys d different, can:

```js
db.people.updateOne({
    "_id" : ObjectId("4b253b067525f35f94b60a31"),
},
    {$set: {'favorite book': 'Green Eggs and Ham'}});
```

If the user realizes that he actually doesn’t like reading, can just remove the key altogether with `$unset`:

```js
db.people.updateOne(
    {name: 'joe'},
    {$unset: {'favorite book': 1}
});
```

Note can also use `$set`to reach in and change embedded documents like:

```js
db.blog.posts.updateOne(
    {'author.name': 'joe'}, // must be string for key
    {$set: {'author.name':'joe schmoe'}}
    )
```

Note that must always use `$`-- modifier for adding, changing, or removing keys. A common error people make when starting out is to try to set the value of key to some other value by doing update. like:

```js
db.blog.posts.updateOne({'author.name', 'joe'}, {'author.name': 'joe schemo'}) // error
```

The update document must contain operators.

## Treating Functions as First-class Citizens

When to use `init`-- Fore, holding a dbs conenction pool -- in the `init`function in the example, like:

```go
var db *sql.DB

func init() {
	dataSourceName := os.Getenv("MYSQL_DATA_SOURCE_NAME")
	d, err := sql.Open("mysql", dataSourceName)
	if err != nil {
		log.Panic(err)
	}
	err = d.Ping()
	if err != nil {
		log.Panic(err)
	}
	db = b
}
```

In this example, open the dbs, check whether we ping it, and then assign it to the global variable. first -- error management in an `init`is limited -- as an `init`doesn’t return an error, one of the ways to signal an error is to panic, leading the app to be stopped -- It shouldn’t necessarily be up to the package itself to decide whether to stop the app. In this case, opening the dbs within an `init`just prevent from error-handling logic.

And another important downside is related to testing - if add tests to this file, the `init`function will be executed before runing the test cases -- which isn’t necessarily what we want. And the last downside is that the example requires assigning the dbs connection pool to a global variable. 

For -- Global variables have some severe drawbacks -- 

- Any functions can alter global variables within the package.
- Unit tests can be more complicated cuz a function that depends on a global variable.

For these reasons, should be just handled as part of plain old function.

But, there are still use cases where `init`can be helpful. Can just set up static HTTP configuration like:

```go
func init() {
	redirect := func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/", http.StatusFound)
	}
	
	http.HandleFunc("/blog", redirect)
	http.HandleFunc("/blog/", redirect)
	
	static := http.FileServer(http.Dir("static"))
	http.Handle("favicon.ico", static)
	//...
	http.Handle("/lib/godoc/", http.StripPrefix("lib/godoc/",
		http.HandlerFunc(static)))
}
```

In summary, saw that `init`function can lead some issues -- 

- Can limit error management
- Can complicate thow to implements tests
- If the initialization requires us to set a steate, has to be done through glboal variables.

### Overusing getters and setters

For Go, *Getters* and *Setters* are means to enable encapsulation by providing exported methods on top of unexported object fields. In go, just also considered netiher mandatory nor idiomatic to use. like:

```go
timer := time.NewTimer(time.Second)
<-timer.C
```

Could even modify the `C`directly. Using these presents some advantages -- 

- Encapsulate a behavior associated wtih getting or setting a field.
- They hide the internal representation.
- Provide a debugging interception point.

And if fall into these -- just:

- The gettter method should be named `Balance`(not `GetBalance`)
- The setter should be named `SetBalance`

```go
currentBalance := customer.Balance()
if currentBalance<0 {
    customer.SetBalance(0)
}
```

### Interface pullution -- 

Use interfaces to create common abstractions that multiple objects can implement. Makes Go interfaces so different -- they just are satisfied implicitly. To understand, - will dig into two populare ones from the stdlib. `io.Reader`and `io.Writer`. Fore, need to implement a function that should copy the content of one file to another.

```go
func copySourcetoDest(source io.Reader, dest io.Writer) error {//...}
```

And this func would work with `*os.File`paameters. and write a test function like:

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    source := strings.NewReader(input)
    dest := bytes.NewBuffer(make([]byte, 0))
    err := copySourceToDest(source, dest)
    if err != nil {
        t.FailNow()
    }
    got := dest.String()
    if got != input {
        t.Errorf("...")
    }
}
```

While designing interfaces, the granularity is also -- keep in mind -- The bigger the itnerface, the weaker the abstrction -- indeed, adding methods to an interface can decrease its level of reusability.

#### When to use interfaces -- 

When create -- 3 concrete use cases -- 

- Common behavior
- Decoupling
- Restricting behavior

Common bevhavior -- like `sort`package like:

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

Hence, the sorting behavior can be just abstracted, can just depend on the `sort.Interface`. And finding the right abstraction to factor out a behavior can also bring many benefits -- fore the `sort`provides utility functions that also rely on `sort.Interface`-- like:

```go
func IsSorted(data Interface) bool {
    n := data.Len()
    for i:= n-1; i>0; i-- {
        if data.Less(i, i-1){
        	return false
        }
    }
    return true
}
```

#### Decoupling

Another important use case is about decoupling our code from an implemenation -- If rely on an abstraction instead of a concrete imp -- the imp itself can e replaced with another without having change our code. Just fore, implement a `CreateNewCustomer`method that creates a new customers and stores it. 

FORE, should decouple `CustomerService`from the actual implementation, whcih can be done via an interface like:

```go
type customerStorer interface {
    StoreCustomer(Customer) error
}
type CustomerService struct {
    storer customerStorer
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer:= Customer{id}
    return cs.storer.StoreCustomer(customer)
}
```

Restricting some behavior -- The abstractions *should be discovered, not created*. Means that sholdn’t start creating abs in our code if there is no immediate reason to do so. We shouldn’t design with interfaces but wait for a concrete need.

## Middleware

When building a web app there is probably some shared fucntionality that you want to use for many HTTP requests. Fore, might want to log every request, compress every response, or check a cache before passing the request to your handlers -- A common way of organzing this shared is to set it as middleware. This is essentially some self-contained code which independently acts on a request before or after your normal app handlers.

- An idiomatic pattern for middleware which is compatible with `net/http`and may 3rd-party packages.
- how to create and which *sets userufl security headers* on every HTTP response.
- how to create which *logs the requests* received by application
- create *recovers panics*
- create and use composable middleware chains 

### How middleware works in go

Can just hink of a Go web app as a chain of `ServeHTTP()`methods being called one after another. When server receives a new HTP request it calls the servemux’s `ServeHTTP()`, looks up the relevant handler based on the request URL path -- and in turn calls the handler’s `ServeHTTP()`.

The basic idea of middleware is to insert another handler into this chain -- The middleware handler executes some logic, like loging a request, and then calls the `ServeHTTP()`of the *next* handler in the chain.

#### The pattern

The std pattern for creating your own middleware looks like:

```go
func myMiddlewre(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        // TODO: execute middleware logic
        next.ServeHTTP(w,r)
    }
    return http.HandlerFunc(fn)
}
```

- The `myMiddleware()`func is essentially a wrapper around the `next`
- It establishes a function `fn`which closes over the `next`handler to form a closure. And when fn is run it executes our middleware logic and then transfers control to the `next`
- Regardless of what you do with a closure it will always be able to access the variables that are local to the scope it was created in. `fn`always have access to the `next`.
- We then convert this closure to a `http.Handler`and return it using the `http.HandlerFunc()`.

Positioning the Middleware -- It is important -- where you position the middleware in the chain of handlers will affect the behavior of your application. Fore, if position before the `servemux`in the chain, then it will act on every request that your app receives. Fore, log. 

Or, after the servemux in the chain -- cause your middleware to only be eecuted for specific route.

### Setting Secrutiy Headers

Make our own middleware which automatically adds the following headers to every response like:

```sh
X-Frame-Options: deny
X-XSS-Protection: 1; mode=block;
```

Just instrcut the user’s web browser to implement some additional security measures to help prevent XSS and ClickJacking attacks -- create `middlewares.go`like:

```go
func secureHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-XSS-Protection", "1; mode=block")
		w.Header().Set("X-Frame-Options", "deny")
		next.ServeHTTP(w, r)
	})
}
```

And, cuz want this to act on every req -- need it to be executed *before* a request hits our servemux. To do this need the `secureHeaders`middleware to wrap our servemux like:

```go
func (app *application) routes() http.Handler {
	mux := http.NewServeMux()
	//...
	// Pass the serveMux as the next to the middleware
    // cuz of secureHeaders is just a func
    // return http.Handler
	return secureHeaders(mux)
}
```

Additional info -- Flow of control -- It’s important to know that when the last handler in the chain returns, control is passed back up the chain in the *reverse* direction. So when the code is being executed the flow of control actually looks like this:

*secureHeaders -> serveMux -> App Handler -> serveMux -> secureHeader*

so, in any middleware handler, code which comes before the `next.ServeHTTP()`will be executed on the way down the chain, fore:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(...) {
        // any code here will execute on the way down the chain
        next.ServeHTTP(w, r)
        // any code will execute on the back up the chain
    })
}
```

Early return -- Another is that if call `return` in middlewrae before call `next.ServeHTTP()`-- then the chain will stop being executed and control will flow back upstream. FORE:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w, r) {
        if !isAuthorized(r) {
            w.WriteHeader(http.StatusForbidden)
            return // note that
        }
        next.ServeHTTP(w, r)
    })
}
```

### Request Logging

Specifically, going to use the *information logger* created eariler to record the IP address of the user.

```go
func (app *application) logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr,
			r.Proto, r.Method, r.URL.RequestURI())
		next.ServeHTTP(w, r)
	})
}
```

Just noticed that this time are implementing the middleware as a method on `application`. This is just perfectly valid -- our middleware method has the same signature as before, cuz it is a method -- against `applciation`it also has access to the handler dependencies including the information logger.

```go
return app.logRequest(secureHeaders(mux))
```

