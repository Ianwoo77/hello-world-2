# Pipeline Syntax (III)

The syntax of an aggregation pipeline is very simple, much like the `aggregate`command itself. Server-side web development is characterized by processing large volumes of HTTP requests as quickly and efficiently as possible. Js is different from other languages and platforms cuz has a single thread of execution.

```sh
npm i -D typescript
npm i -D tsc-watch
npm i -D @tsconfig
npm i -D @types/node
```

Teh cconfigure the Ts compiler -- create a file named `tsconfig.json`in the folder like:

```json
{
  "extends": "@tsconfig/node20/tsconfig.json",
  "compilerOptions": {
    "rootDir": "src",
    "outDir": "dist",
  }
}
```

The configuration file extends the one provided by the Ts developers for working with Node.js -- the Ts files will be created in the `src`folder, and the compiled Js will be written to the `dist`folder -- in the `package.json`file and add the command shown in -- like:

```json
"scripts": {
    "start": "tsc-watch --onsuccess \"node dist/server.js\""
},
```

#### Creating a simple web app -- 

With the packages and build tools in place, it is time to create a simple web app -- create the `/src`folder and add like:

```ts
import {IncomingMessage, ServerResponse} from 'http';
export const handler= (req: IncomingMessage, res: ServerResponse) => {
    res.end("Hello worlds");
}
```

then add the file named `server.ts`to the `src`like:

```ts
import {createServer} from "http";
import {handler} from "./handler";

const port= 5000;
const server = createServer(handler);
server.listen(port, function() {
    console.log(`server listening on port ${port}`);
});
```

Then add some data file to the app like.

#### Understanding server code execution -- 

A disclaimer required -- this chapter omits some details -- is a little loose with some explanations, and blurs the lines between some fine detaisl -- The topics -- Server-side web apps need to be able process many HTTP requests simulaneously to scale up economically so that a small amount of server capacity can be used to support a large number of clients. And the conventional approach is to take advantage of the multi-threaded features.

This approach makes full use of the server hardware, but it requires developers to consider how requests might interfere with each other -- a common problem is that one handler thread modifies data as it being ready for another thread -- producing an unexpected result.

One solution is to use *non-blocking* operations -- also just known as *asynchrononous* operations -- there can be confusing -- Just -- instead of waiting for an operation to complete, handler threads rely on a monitor thread while they continue to process requests from the queue. When blocking operation has finished, the monitor thread puts the request back in the queue so that a handler can continue processing the request.

#### Understanding Js code execution

Writes Js fucntions, known as *callbacks* -- use API to asociate those functions with specific events on elemetns -- whe the browser detects an event, it adds the callback to a queue so it can be executed by the JS runtime. The JS runtime has a single thred - called 

#### Node.js code execution

Node.js retrains the main thread and the event loop -- which means that server-side code is executed in the same way as client-side js -- for HTTP servers, the *main thread is the only request handler* -- and callbacks are used to handle incoming HTTP connections -- 

```js
const server= createServer(handler);
```

For this, the callback function passed to the `createServer`will be invoked when Node.Js receives an http connection. And the function defines parameters that represent the request that has been received and the response that will be returned to the client.

```ts
export const handler = (req: IncomingMessage, res: ServerResponse)=> {
    res.end('hello')
};
```

### Using API

Node.js replaces the API provided by the browser with one that supports common sever-side tasks, such as processing HTTP requests and reading files -- behind the scenes, Node.js usea native threads -- like:

```ts
export const handler = (req: IncomingMessage, res: ServerResponse) => {
    readFile("data.json", (err: Error | null, data: Buffer) => {
        if (err === null) {
            res.end(data, () => console.log("file sent"));
        } else {
            console.log(`Err: ${err.message}`);
            res.statusCode = 500;
            res.end();
        }
    })
};
```

For this the `readFile`operation is async and is implemented using a native thread -- the contents of the file are passed to a callback function, which sends them  to the HTTP client.

Here, for the `res.end(data, ()=>console.log(“file sent”))`-- the callback is invoked when the data read from the file has been sent to the client.

Breaking up the process of producing HTTP response with callbacks means that the JS main thread doesn’t have to wait for the file system to read the contents of the file, and this allows requests from other clients to be processed.

#### Handling events -- 

Events are used to provide notification that the state of the app has changed and provide an opportunity to execute a callback function to handle the chagne -- Events are used throughout the Node.js API, although there are often convenience features that hide away the details. Like:

```ts
const port= 5000;
const server = createServer();
server.on('request', handler);

server.listen(port);
server.on('listening', ()=> {
    console.log(`(Event) server listening or port ${port}`);
})
```

Many of the objects created with the Node.js API extends the `EventEmitter`class, which denotes a source of events -- the `EventEmitter`class defines the methods -- 

- `on(event, callback)`-- registers a `callback`to be invoked whenever the specified event is emitted
- `off(event, callback)`-- this method stops invoking `callback`when the specific event emitted
- `once(event, callback)`-- registers a callback to be invoked the next time not for thereafter.

#### Working with promises

Are an alternative to callbacks and some parts of the Node.js API provide features using both callbacks and promises -- A Promise servers the same purpose as a callback so just like: Note that use the new import status

```ts
import {readFile} from "fs/promises";

export const handler = (req: IncomingMessage, res: ServerResponse) => {
    const p : Promise<Buffer> = readFile('data.json');
    p.then((data:Buffer)=> res.end(data, ()=>console.log("File sent")));
    p.catch((err: Error)=> {
        console.error(`${err.message}`);
        res.statusCode=500;
        res.end();
    })
};
```

This isn’t how promises are usually used, which is. just like -- the `readFile()`function has the same name as the function used for callbacks but is defined in the `fs/promises`module -- the result returned by the `readFile`funciton is just a `Promise<Buffer>`which is a promise that will produce a `Buffer`object when its async op is complete.

For this, need to know `Promises`are either *resovled* or *rejected* -- a Promise that complete successfully and produces its result is resovled - the `then`method is used to register the function that will be invoked if the promise is resovled -- meaning that the file has been read successfully. And a rejected is one where an error occurred -- The `catch`method is used to register a function that handles the error produced by the rejected promise -- like:

```js
p.catch((err: Error)=> {
    console.log(`Error: ${err.message}`);
})
```

This is a little neater -- but the real improvement comes with the use of the `async`and `await`keywords -- which allows asynchronous operations to be performed using syntax that doesn’t require nested functions or chained methods.

```ts
export const handler = async(req: IncomingMessage, res: ServerResponse) => {
    const data: Buffer = await readFile('data.json');
    res.end(data, ()=> console.log("File Sent"));
};
```

To support error handling, the `catch`used on `Promise`objects is replaced with the `try/catch`block when using the `await`keyword -- just like -- 

```ts
try {
    const data: Buffer = await readFile('data.json');
    res.end(data, () => console.log("File Sent"));
} catch (err: any) {
    console.log(`Error: ${err?.message ?? err}`);
    res.statusCode = 500;
    res.end();
}
```

#### Wrapping callbacks and unwrapping promises -- 

Not every port of Node.JS API supports both promises and callbacks -- and can lead to both approaches being mxied in the same code. Can see this problem -- where the `readFile`function returns a promise, but the `end`method -- whcih sends data to the client and finishes the HTTP response, uses a callback -- like; The promise and callback APIs can be mixed without problems - but the result can be awkward -- Fore, add `promises.ts`to the `src`like:

```ts
export const endPromise= promisify(ServerResponse.prototype.end) as
    (data:any)=> Promise<void>;
```

This is to create a function that returns a promise.

## Interface on the producer side

Saw in the previous section when interfaces are considered valuable - but Go developers often misunderstand one question -- where should an interface live -- Before -- make sure we use throughout this are clear -- 

- *Producer side* -- An interface defined in the same package as the concrete imp
- *Consumer side* -- an interface defined in an external package where it’s used.

It’s common to see developers creating interfaces on the producer side -- alongside the concrete imp -- this design is perhaps a habit from developers having a C# or Java background. Fore have:

```go
package store

type CustomerStorage interface {
    StoreCustomer(customer Customer) error
    GetCustomer(id string) (Customer, error)
    UpdateCustomer(customer Customer) error
    GetAllCustomers() ([]Customer, error)
    GetCustomersWithoutContract() ([]Customer, error)
    GetCustomersWithNegativeBalance() ([]Customer, error)
}
```

Might think we have some excellent reasons to create and expose this interface on the producer side -- As mentioned, inerfaces are satisfied implicitly in Go, which tends to be a game-changer -- In most cases, the approach to follow is similar to what we described. *abstactions should be discovered* -- not creates -- 

In the previous, perhaps one client won’t be interested in decoupling its code, maybe another wants to decouple its code but is only interested in the `GetAllCustomers`method -- in this -- just create one interface like:

```go
package client

type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

- Cuz the `customerGetter`interface is only used in the `client`, it can remain *unexported*
- There is no dependency from `store`to `client`cuz the interfce satsified *implicitly*.

Let’s mention that this approach -- interfaces on the producer side -- is sometimes used in the stdlib -- fore, the `encoding`package defines interfaces implemented by other subpackages such as `encoding/json`or `encoding/binary`.

### Returning interfaces

While desigining a function signature, may have to return either an interface on a concrete implemention -- understand why returning an interface in many cases, considered a bad practice in Go -- just pretend why interfaces live -- Will consider two packages -- 

- `client`-- which contains a `Store`interface
- `store`-- which contains an imp of `Store`.

In the `store`package, deine an `InMemoryStore`struct that implements the `store`interface -- create a `NewInMemoryStore`to return a `Store`interface. There is a dependency from their imp pakcage to the client package. There would be a cyclic dependency, a possible soution -- furthermore, what happens if another client uses the `InMmeoryStore`.

Here -- in general, returning an interface restricts flexibility cuz we force all the cleints to use one particular type of abstraction - in most cases, can get inspiration from .. If apply this -- means -- 

- Returning structs instead of interfaces
- Accepting interfaces if possible.

### `any`says nothing

In Go, an interface type that specfies zero methods known empty interfce -- `interface{}`-- Predeclared type `any`became an alias for an empty interface -- all the `interface{}`occurrences can be replaced by `any`-- in many cases, `any`can be considered an overgeneralization -- if:

```go
func main() {
    var i any
    i = 42
    i = "foo"
    //...
}
```

In assigning a value to an `any`type, just lose all type information -- which requires a type assertaion to get anythign useful out of the `i`variable. If

```go
type store
type Customer struct {
    //...
}
type Contract struct {
    //...
}
type Store struct {}
func (s *Store) Get(id string) (any, error) {}
func (s *Store) SEt(id string, v any) error {}
```

For this, cuz we accept and return `any`arguments, the method lack expressiveness -- if future developers need to use the `Store`struct, they will probably have to dig into the documentation or read the code to understand how to use these methods. Hence, accepting or returning `any`type doesn’t convey meaningful information, also cuz there is no safeguard at compile time -- nothing preents a caller from calling these methods with data types like:

```go
s := store.Store{}
s.Set("foo", 42)
```

For this, by using `any`, lose some of the benefits of Go as a statically typed language. So just like:

```go
func (s *Store) GetCustomer(id string) (Customer, error) {...}
```

In the new version, the methods are expressive, reducing the risk of incomprehension. Fore, if a client is interested only in the `Contract`method, can write:

```go
type ContractStorer interface {
    GetContract(id string) (store.Contract, error)
    SetContract(id string, contract store.Contract) error
}
```

Then, what are the cases when `any`is just helpful -- For the two exmples where functions or methods accept `any`arguments -- the first is in the `encoding/json`-- like:

```go
func Marshal(v any) ([]byte, error)
```

And another example in the `database/sql`-- if the query is parameterized the parameters should be `any`kind:

```go
func (c *Conn) QueryContext(ctx context.Context, query string, args ...any) (*Rows, error) {}
```

### When to use generics

Go 1.18 adds generics to the language -- in a nutshell -- this allows writing code with types that can be specified later and instantiated when needed -- it can be confusing about when to use generics and when not to.

```go
func getKeys(m map[string]int) []string {
    //...
}
```

So, what if want to use a similar feature for another `map`type such as `map[int]string`before generics should be:

```go
func getKeys(m any) ([]any, error) {
    switch t := m.(type){
    default:
        return nil, fmt.Errorf("unknown type: %T", t)
    case map[string]int:
        //...
    case map[int]string:
        //...
    }
}
```

With this, start to notice a few issues, first, it increases boilerplate code, when need to add a `case`, it requires duplicating the `range`loop -- meanwhile, the function now accepts an `any`type -- which means lose some of the benefits of Go static lang. So:

```go
func getKeys[K comparable, V any](m map[K]V) []K {
    var keys []K
    for k := range m {
        keys = append(keys, k)
    }
    return keys
}
```

So, to handle the map, define two kinds of type parameters, first the values can be of `any`type, however, inGo, the map keys can’t be of the `any`type, fore, cannot use the slices -- `var m map[[byte]] int`, so leads to a compliation error -- therefore -- just use the `comparable`.

Restricting type arguments to match specific requirements is called a *constratint* -- a constraint is an interface type thatn can contina -- 

- A set of behaviors
- Arbitrary types

```go
type customConstraint interface {
    ~int | ~string
}
func getKeys[K customConstaint, V any](m map[K]V) []K {
    //...
}
```

Fore, can also use generics with data structures -- fore, can create a linked list containing values of any types like:

```go
type Node[T any] struct {
    Val T
    next *Node[T]
}
func (n *Node[T])Add(next *Node[T]) {
    n.next = next
}
```

For this, use type parameters to define `T`and use both fields in Node. One last thing to note about type parameters is that they can’t be used with method arguments -- only with function arguments or method receivers.

## Working with session data

In this -- put the sessin functionality to work and use it to persist the confirmatino flash message -- Using the `alexedwards/scs`-- store session data server-side only -- supports automatic loading and saving of session data via middleware has a nice interface for type-safe manipulation of data, and does allow renewal of session IDs -- like `gorilla/sessions`-- also supports a variety of dbs.

In summary, want to store session data client-side in a cookie then `gorialla/sessions`is good choice, but `alexdwards/scs`is generally the better option due to the ability to renew session IDs.

#### Setting up the session manager

I’ll run through the proess of setting up and using the package -- but going to use it in production application I recommend reading the documentation and API reference to familiarize yourself with the full range of features -- the first thing we need to do is create a *sessions* table in our MySQL dbs to hold the session data for our users.

```sql
CREATE TABLE sessions (
	token CHAR(43) PRIMARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTAMP(6) NOT NULL,
);
CREATE INDEX session_expiry_idx ON sessions (expiry);
```

- The `token`field will contain a unique, readomly-generated, idenfier for each session.
- The `data`field will contain the actual session data that U want to share between HTTP requests. This is stored as *binary data* in a `BLOB`type.
- The `expiry`field will contain an expiry time for the session -- the `scs`package will automatically delete expired sessions from the `sessions`table so that it doesn’t grow too large.

```go
type application struct {
    //...
    sessionManager *scs.SessionManager
}
```

```sh
go get github.com/alexedwards/scs/v2
go get github.com/alexedwards/scs/mysqlstore
```

##### Setting up the session manager

- The `token`field will contain a unique, randomly-generated, identfier for each session.
- The `data`filed will contain the actual session data that U want to share between HTTP requests.
- The `expiry`field will contain an expiry time for the session. the `scs`package will automatically delete expired sessions from the `seessions`table so that it doesn’t grow too large.

Then need to do is establish a *session manager* in our `main.go`file and make it available to our handlers via the `application`struct -- the session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving of session data like -- 

```go
func main() {
    addr := flag.String("addr", ":4000", "HTTP network address")
    dsn := flag.String("dsn", "web:pass@/snippetbox?parseTime=true"...)
    flag.Parse()
    
    templateCache, err := newTemplateCache()
    if err != nil {
        errorLog.Fatal(err)
    }
    
    formDecoder := form.NewDecoder()
    sessionManager := scs.New()
    sessionManager.Store = mysqlstore.New(db)
    sessionManager.Lifetime = 12 * time.Hour
    
    app := &application {
        //...
        sessionManager: sessionManager,
    }
}
```

For the sessions to work, also need to wrap our application routes with the middleware provides by the `SessionManager.LoadAndSave()`method -- This middleware automatically loads and saves session data with every HTTP request and response -- It’s important to note we don’t need this middleware to act on *all* our application routes. Specifially, don’t need it on `/static/*filepath`route -- cuz all this does is serve static files and there is no need for any stateful behavior.

So because of that, it doesn’t make sense to add the session middleware to our existing `standard`middleware chain. instead, let’s create a new `dynamic`middleware chain containing the middleware appropriate for our dynamic app routes only.

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    router.NotFound = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        app.notFound(w)
    })
    fileServer := http.FileServer(http.Dir("./ui/static/"))
    router.Handler(http.MethodGet, "/static/*filepath", http.StripPrefix("/static", fileServer))
    
    dynamic := alice.New(app.sessionManger.LoadAndSave)
    
    router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
    // ...
    standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
    return standard.Then(router)
}
```

