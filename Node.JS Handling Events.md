# Node.JS Handling Events

Events are used to provide notifications that the state of the app has changed and provide an opportunity to execute a callback func to handle the change -- events are used throughout the Node.JS API -- like:

```js
const port = 5000;
const server = createServer();
server.on("request", handler);
server.listen(port);
server.on("listening", ()=> {
    console.log("...")
})
```

Many of the objects created with the Node.js API extend the `EventEmitter`class -- which denotes souce of envents. The `EventEmitter`class defines the methods -- 

- `on(event, callback)`
- `off(event, callback)`
- `once(event, callback)`

For classes that extend `EventEmitter`define events and specify when they will be emitted -- The `Server`class returned by the `createServer()`method extends `EventEmitter`and defines two events that are used.

#### Working with promises

Are an alternative to callbacks and some parts of the Node.JS API provides features using both callbacks and promises. A promise serves the sme puprose as a callblac,

```js
export const handler = (req, res) => {
    const p: Promise<Buffer>= readFile('data.json'); // import {readFile} from "fs/promise"
    p.then((data:Buffer)=> read.end(data, ()=> console.log("file sent")));
    p.catch((err:Error)=> {
        //..
    })
}
```

Promises are either *resolved* or *rejected*. So just like:

```js
readFile('...').then().catch();
```

Using the `async`and `await`keywords flattens the code by removing the need for `then`method and its function.

```js
export const handler = async(req, res)=> {}
const data Buffer = await readFile('data.json')
```

So can use `try/catch`block when using the `await`keyword -- like:

```js
try {
    const data: Buffer = await readFile("...");
    res.end(data, ()=> console.log("..."))
}catch(err: any) {
    //...
}
```

#### Wrapping callbacks and unwrapping promises

Not every part of the API supports both promises and callbacks, and that can lead to both approaches being mixed in the same code fore:

```ts
const data: Buffer = await readFile("data.json");
res.end(data, ()=> console.log("file sent"));
```

For this, the promise and callback APIs can be mixed without any problems -- but the result can be awkward code -- to help ensure consistency -- like:

`promixify`and `Callbackify`-- These functions creates a `Promise`object from a function or accepts a `Promise`object and returns a function that will accept a conventional callback. Not that the `promisify`function doesn’t work seamlessly on class methods unless -- with the `this`keyword note that.

```ts
import {promisify} from "util";
import {ServerResponse} from "http";

export const endPromise= promisify(ServerResponse.prototype.end) as
    (data:any)=> Promise<void>;
```

Use the `promisify`to create a function that returns a promise -- which do by passing the `ServerResponse.prototype.end`function to promisfy.

### Handling HTTP requests

The foundation of server-side web is the ability to receive HTTP requests from clients and generate responses -- 

- The `http`and `https`modules contain the functions and classes required to create HTTP and HTTPs servers, requests, and generate responses.
- Receiving and responding to HTTP requests is the core feature of server-side web app development
- Servers are created with the `createServer`-- which emits events when request are received. And callback functions are just invoked to handle the request and generate a response.
- Handler functions can become complex and mix the statements that matches requests

```js
export const handler = async (req: IncomingMessage, res: ServerResponse) => {
    res.end("hello world");
};

// in the server.ts just like:
const port= 5000;
const server = createServer();
server.on('request', handler);
// ... same as before
```

#### Listening for HTTP requests

The `createServer`function in the `http`module is used to create a `Server`object that can be used to listen for and process HTTP requests -- the `Server`object requires configuration before it starts listening for requests and most useful methods and properties defined by the `Server`.

- `listen(port)`
- `close()`-- stops listening for requests
- `requestTimeout`-- this gets or sets the request timout period.

And once the `Server`object has been configured, it emits events that denote important changes in state -- the most useful useful events are - 

- `listening`-- triggered when the server starts listening for requests.
- The event is triggered when a new request is received `request`event
- `error`-- when there is a network error.

The use of events to invoke callback functions is typical of the JS code execution model described -- the `request`event will be triggered each time an HTTP request is received, and the Js execution model means that only one HTTP request will be handled at a time. 

The convenience features can be used to combine the statements that create and configure the HTTP server -- 

```js
server.listen(port,
    ()=> console.log(`(Event) server listening on port: ${port}`));
```

This code has the same effect  -- but is more concise and easier to read -- 

#### Understanding the server configuration object

The arguments for the `createServer`function are a configuration object and a request-handling function.

- `IncomingMessage`-- this spcifies the class used to represent requests -- the `default`is the `IncomingMessage`, defined in the `http`module
- `ServerResponse`-- Specifies the class used to represent response. The default is `ServerResponse`class.
- and, `requestTimeout`-- sepcifies the amount of time -- ms, allowed for a client to send requests.

#### Understanding HTTP requests

Node.js represents HTTP requests using the `IncomingMessage`class -- which is defined in the `http`module.

- The HTTP method -- describes the operations
- URL -- identifies the resouce the request should be applied to
- The headers -- provide additional info about the request and capabilities of the client.
- request body -- provides the data required for the requested operation.

HTTP headers can be difficult to work with and the `headers`and `headersDistinct`props. Fore, some HTTP headers shold only appear once in a request, so Node.JS removes the duplicate values.

```js
export const handler = async (req: IncomingMessage, res: ServerResponse) => {
    console.log(`---- HTTP Method: ${req.method}, URL: ${req.url}`);
    console.log(`host: ${req.headers.host}`);
    console.log(`accept: ${req.headers.accept}`);
    console.log(`user-agent: ${req.headers["user-agent"]}`)
    res.end("hello world");
};

const port= 5000;
const server = createServer(handler);

server.listen(port,
    ()=> console.log(`(Event) server listening on port: ${port}`));
```

#### Parsing URLs -- 

Node.js provides the URL class in the `url`module to parse URLs into their parts -- making it easier to inspect URLs to make decistions about what kind of response will be sent. `pathname`-- returns a string containing the URL pathname component -- 

```ts
export const handler = async (req: IncomingMessage, resp: ServerResponse) => {
    console.log(`---- HTTP Method: ${req.method}, URL: ${req.url}`);

    const parsedURL = new URL(req.url ?? '', `http://${req.headers.host}`);
    console.log(`protocol: ${parsedURL.protocol}`);
    console.log(`hostname: ${parsedURL.hostname}`);
    console.log(`port: ${parsedURL.port}`);
    console.log(`pathname: ${parsedURL.pathname}`);
    parsedURL.searchParams.forEach((val, key) => {
        console.log(`Search param: ${key}: ${val}`)
    });
    resp.end("Hello, World");
};
```

For this, note that create a `URL`object to parse a URL requires a little work -- the `IncomingMessage.url`property returns a relative URL -- which the `URL`class ctor will accept an argument -- but only if the base part of the URL. For this the `URL`ctor in this code is a standard Js PAI used to parse and manipulate URLs -- takes two arguments -- 

- `req.url?? ‘’`-- first is the URL string to parse, and there the `req.url`provides the URL path and the query string. 
- `req.headers.host`-- is the base URL -- resolved to relative URLs -- constructs the base URL using the `host`header from the request -- prefixed with `http://`

## Common uses and misuses for generics

When are generics useful -- where generics are recommended -- 

- *Data Structures* -- can use generics to factor out the element type if we implment a binary tree...

- *Functions working with slices, maps and channels of any type* -- A function to merge two channels would work with any channel type -- fore:

  ```go
  func merge[T any](ch1, ch2 <-chan T) <-chan T {
      //...
  }
  ```

- Factoring out behaviors instead of types -- fore the `sort`package -- 

  ```go
  type Interface interface {
      Len() int
      Less(i, j int) bool
      Swap(i, j int)
  }
  
  // Using type parameters can - 
  type SliceFn[T any] struct {
      S []T
      Compare func(T, T) bool
  }
  
  func (s SliceFn[T]) Len() int
  func (s SliceFn[T]) Less(i,j int) bool {return s.Compare(s.S[i], s.S[j])}
  func (s Slicefn[T]) Swap(i, j int) {s.S[i], s.S[j] = s.S[j], s.S[i]}
  ```

   The, cuz the `sliceFn`struct implements `sort.Interface`-- can sort the provided slice using the `sort.Sort()`function like -- 

  ```go
  s := SliceFn[int] {
      s: []int {3,2,1}
      Compare: func(a, b int) bool {
          return a<b
      },
  }
  sort.Sort(s)
  ```

Conversely, when is it recommended that **NOT** use generics -- 

- When calling a method of the type argument -- consider a function that receives an `io.Writer`and calls the `Write`method -- like:

  ```go
  func foo[T io.Writer] (w T) {
      b := getBytes()
      _, _ = w.Write(b)
  }
  ```

- Also, when makes our code more complex just.

### Possible problems with type embedding

Note that `Baz`actually available from two different paths -- either from the promoted one using `Foo.Baz`or from the nominal one via `Foo.Bar.Baz`.

Interfaces and embedding -- Embedding is also used within interfaces to compose an interface with others -- like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

We are reminded -- What mebedded types are -- like;

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}

func New() *InMem {
    return &InMem {m: make(map[string]int)}
}
```

For this, decided to make the map unexported so that client can’t interact with it directly but only via exported methods -- meanwhile, the mutex field is mebedded -- therefore, can implement a `GET`just like:

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

For this, cuz the mutex is just embedded, can directly access the `Lock`and `Unlock`methods from the `i`receiver -- mentioned that such an example is a wrong usage of type embedding. Since `Lock`and `Unlock`methods will be *promoted* -- therefore, both methods become visible to external clients using `InMem`. Fore:

```go
m := inmem.New()
m.Lock() // ?? what meaning 
```

This problem is probably not desired -- a mutex is in most cases, something we want to encapsulate within a struct and make invisible to external clients -- like:

```go
type InMem struct {
    my sync.Mutex
    m map[string]int
}
```

This time cuz the mutex isn’t embedded and is unexpected -- can’t be accessed from the exteranl clients -- want to write a custom logger that contains an `io.WriteCloser`and exposes two methods. fore:

```go
type Logger struct {
    writeCloser io.WriteCloser
}

func (l Logger) Write(p []byte) (int, error) {
    return l.writeCloser.Write(p)
}
//...
```

For this example, `Logger`would have to provide both a `Write`and `Close`that would Only forward the call to the `io.WriteCloser`-- however, if the field now becomes embedded, can remove these methods like:

```go
type Logger struct {
    io.WriteCloser
}
```

It remains the same for clients with two exported `Write`and `Close`-- but the example prevents implementing these additional methods simply to forward that like:

```go
func main() {
    l := logger{WriteCloser: os.Stdout}
    _, _ = l.Write([]byte("foo"))
    _ = l.Close()
}
```

For this, it remains the same for clients with two exported `Write`and `Close`methods -- but the example prevents implementing these additional methods simply to forward a call.

What should we conclude about type embedding -- it means that whatever the user case, can probably solve it as well without type embedding -- *Type embedding is mainly used for convenience*.