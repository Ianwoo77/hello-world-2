# Using the Express Router

Request handler functions that use the Node.js API mix the statements that inpspect requests with the code that greatests responses -- like:

```sh
npm install express
npm install -D @types/express
```

```ts
export const notFoundHandler = (req: Request, resp: Response) => {
    resp.sendStatus(404);
};

export const newUrlHandler = (req: Request, resp: Response) => {
    resp.send("Hello, New URL");
};

export const defaultHandler
    = (req: Request, resp: Response) => {
    if (req.query.keyword) {
        resp.send(`Hello, ${req.query.keyword}`);
    } else {
        resp.send(`hello, ${req.protocol.toUpperCase()}`);
    }
}
```

The responses are generated in the same way as earlier examples -- but each response is creatd by a separate handler function -- without the code that matches requests.

```ts
export const redirectHandler = (req: IncomingMessage, resp: ServerResponse) => {
    resp.writeHead(302, {
        'location': 'https://localhost:5500'
    });
    resp.end();
};
const https_port = 5500;
const server = createServer(redirectHandler);
const expressApp: Express = express();
expressApp.get("/favicon.ico", notFoundHandler);
expressApp.get("/newUrl", newUrlHandler);
expressApp.get(/\.*/, defaultHandler);

const httpsServer = createHttpsServer(httpsConfig, expressApp);
httpsServer.Listen(https_port, ()=>console.log("..."));
```

Just note that -- 

- `all(path, handler)`-- this routes all requests that match the path to the specified handler function
- `use(handler)`-- this adds a middleware component, which is able to inspect and intercept all requests.

#### Using the request and resp enhancements

In addition to routing, Express provides enhancements to the `IncomingRequest`and `ServerResponse`objects that are passed to handler function -- The object that represents the HTTP request is named `Request`and it extends the `IncomingRequest`type -- the most useful `Request`enhancements like:

`hostname, params, path, protocol, query, secure, body`And the object that Express uses to represent the HTTP response is named `Response`and it extends the `ServerResponse`type -- 

- `redirect(code, path)`-- this method sends a redirection response. The `code`arg is used to set the response status code and message.
- `send(data)`-- used to send a resp to the server -- is set to 200.
- `sendStatus(code)`-- used to set a status code response and will automatically set the status message.

```ts
export const notFoundHandler = (req: Request, resp: Response) => {
    resp.sendStatus(404);
}
```

#### Using Express route parameters

It is just important to understand that Express don’t do anything magical and its features are just built on those provided by Node.js described in the chapter -- the vlaue of Express is that it makes the Node.js API easier to conume.

```ts
// in the server.ts file
expressApp.get('/newurl/:message?', newUrlHandler);
```

For this modified route matches requests when path begins with `/newurl`-- the second segment in the URL path is assigned to a route parameter named `message`-- the parameter is denoted by the colon.

```ts
export const newUrlHandler = (req: Request, resp: Response) => {
    const msg = req.params.message ?? "(No message)";
    resp.send(`hello, ${msg}`);`
};
```

note make the express to `4.20.0`.

### Using node.js streams

One of the main tasks required in server-side development is transferring data -- either reading data sent by a client or browser or writing data that must be transmitted or stored in some way - introduce the API for dealing with data sources and data dest.

```ts
expressApp.get("/favicon.ico", (req, resp)=> {
    resp.statusCode=404;
    resp.end();
});
expressApp.get("*", basicHandler);
const server = createServer(expressApp);
server.listen(port, 
    () => console.log(`(Express) server listening on port: ${port}`));
```

For this, the Express router so the `basicHandler`just like:

```ts
export const basicHandler=(req: IncomingMessage, resp: ServerResponse) => {
    resp.end( `Hello, world`);
}
```

For this, just uses the `IncomingMessage`and `ServerResponse`types .

### Understanding Streams

The best way to understand streams is to ignore data and think about water for a moment. What arrangement has two important characteristics -- the first is that the data arrives in the same order in which it is written

#### Using Node.JS streams

The `streams`module contains classes that represent different kinds of streams, and the two most important:

- `Writable`-- provides the API for writing to a stream
- `Readable`-- provides the API for reading from a stream

In Node.js development, one end of a stream is usually connected to sth outside of the JS environment -- such as a network connection for file system -- allows data to be read and written in the same way regardless of where it is going to or coming from. For web development, the most important use of streams is they are used to represent HTTP requests and responses -- 

#### Writing data to a stream

- `write(data, callback)` - Data can be expressed as a `string, buffer, Uint8Array`... and the method returns a `boolean`indicates whether the stream is able to accept further data without exceeding its buffer size.
- `end(data, callback)`-- No further data will be sent.
- `destroy(error)`-- destroys the stream immediately
- `closed`-- returns `true`if the stream has been closed
- `destoryed`-- returns `true`if the `destroy`method has been called
- `writable`-- returns `true`if stream can be written to.
- `writableEnded`-- `true`if `end()`called
- `writableHighWaterMark`-- returns the size of the data buffer in bytes. -- the `write`will return `false`when the amount of buffered data exceeds this amount
- `errored`-- returns `true`if the stream has encountered an error

And the `Writable`class also emits events -- `close, error, finish`, and 

`drain`-- this is emitted when the stream can accept data without buffering. When its internal buffere is emptied after being full-- signaling that it’s just safe to resume writing data.

- The `drain`fires after the `write()`returns `false`and the buffere has been cleared
- It’s used to handle backpressure by pausing writes when the buffer is full and resuming when the drain event is emitted
- Commonly used with streams like `fs.createWriteStream`-- or network streams like `net.Socket`.

The basic approach to using a writable stream is to call the `write`method until all the data has been sent to the stream just like:

```js
export const basicHandler = (req: IncomingMessage, resp: ServerResponse) => {
    for (let i = 0; i < 10; i++) {
        resp.write(`message:${i}\n`);
    }
    resp.end('End');
}
```

It is easy to think of the endpoint of the stream as being a straight pipe to the ultimate recipient of the data -- which is the web browser in thise cse.

#### Stream enhancements

Some streams are just enhanced to case development -- which means that the data U write to the stream won’t always be the data that is received at the other end -- in the case of HTTP responses, fore, the Node.JS http API aids development by ensuring that all responses conform to the basic requirements of the HTTP protocol.

```sh
curl --include http://localhost:5000
```

The `--include`, `-i`just tells `curl`to include the http resposne headers in the output.

And the `ServerResponse`class demonstrates another kind of stream enhancement -- which is methods or properties that write content to the stream for U.

```js
export const basicHandler = (req, resp) => {
    resp.setHeader("Content-Type", "text/plain"); //...
}
```

#### Avoiding excessive data buffering

Writable streams are created with a buffer in which data is stored before it is processed. Each time the stream processes a chunk of data, it is said to have *flushed* the data -- when all data in the stream’s buffer has been processed, the stream buffer is said to have been *drained* -- the amount of data that can be stored the buffer is known as the *high-water* mark. And a writable stream will always accept data -- even if it has no increase the size of its buffer -- but this is undesirable cuz it increase the demand for memory that can be required for an extended period while the stream flushes the data it contains.

The ideal approach is to write data to a stream until its buffer is full and then wait until the data is flushed before further data is written -- the `write`method returns a `boolean`value that indicates whether the stream can receive more data without expanding its buffer byeond its target high-water mark.

```js
export const basicHandler = (req: IncomingMessage, resp: ServerResponse) => {
    resp.setHeader('Content-Type', 'text/plain');
    for (let i = 0; i < 10_000; i++) {
        if(resp.write(`message:${i}\n`)) {
            console.log("Stream buffer is at capacity")
        }
    }
    resp.end('End');
}
```

## Operations

Here is one way to write the function like:

```go
func AddAnything[T Integer] (x, y T) T {
    return x+y
}
```

For the production -- just like:

```go
type Integer interface {
	~int | ~int8 | ~int16 | ~int32 | ~int64 | ~uint | ~uint8 |
		~uint16 | ~uint32 | ~uint64
}

type Float interface {
	~float32 | ~float64
}

type Complex interface {
	~complex64 | ~complex128
}

type Number interface {
	Integer | Float | Complex
}

func Product[T Number](x, y T) T {
	return x * y
}
```

Then test it like:

```go
func TestProductOfInts2And3Is6(t *testing.T) {
	t.Parallel()
	want := 6
	got := Product(2, 3)
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
```

#### Ordered types -- 

So much for -- 

```go
func Greater[T Number](x, y T) T {
    if x>y {
        return x
    }
    return y
}
```

The `>`operator -- know that at least some of the types in Number’s type set support the `>`operator -- fore, integers certainly do -- and so do floats. can:

```go
type Real interface {
    Integer | Float
}
```

Strings -- the `>`operator -- So can make our `Greater`function more widely useful by accepting not only real numbers, but also strings and types derived from `string`-- In other words, all types that support the `>`operator -- 

#### An `Ordered`interface

Here is one way can write an interface whose type set is the ordered types -- like:

```go
type Ordered interface {
    Integer | Float | ~string
}
```

#### The `cmp.Ordered`constraint -- 

It’s becoming clearer why might want to constrain type parameters in certain ways -- need to restrict the allowed types enough that can guarantee that they will support the operator we are using -- such as `+`and `>`-- on the other hand, don’t wan to restrict them *too* much -- to make our function as widely useful as possible, include *all* the types that support the relevant operator.

Our `Ordered`constraint, then expresses precisely the set of types that can be used with `>`just like:

```go
func Greater[T cmp.Ordered](x, y T) T {
	return max(x, y)
}
```

#### Multiple type parameters

Seen generic functions with a single type parameter -- might be wonderingif it’s possible to write functions with *multiple* type parameters -- 

```go
func Identity[T, U any](x T, y U) (T, U) {
    return x,y
}
```

#### Each type parameter is a distinct type

Fore, we can’t find which value is greater, using the `>`operator. Why not `T`and `U`are different types, and that operator can only work on values of the *same* type -- for the same reason, couldn’t add them together, or use any other operators.

Functions on slice types -- Here is another interesting case where multiple type parameters can be helpful -- Consider a generic function that takes a slice of some arbitrary element type, such as the `Len()`function we saw in an earlier chapter -- 

```go
func Len[E any](s []E) int {
    return len(s)
}
```

And defined some composite type - `StringList`-- is just a slice of strings -- 

```go
type StringList []string
// can pass a value of StringList to Len
fmt.Println(StringList{"a", "b", "c"})

func Identity[E any] (s []E) []E {
    return s
}
```

#### The problem with derived slice types -- 

But there is a hidden problem here. Use the `%T`verb with `fmt.Printf`to print out the *type* of the result returned by `Identity`-- 

```go
result := Identity(StringList{"a", "b", "c"})
fmt.Printf("result is a %T\n", result)
```

### Using the functional options pattern

When designing an API, one question may arise -- how do we deal with optional configuration -- Solving this efficiently can improve how convenient our API will become -- This section goes through a concrete example and covers different ways to handle optional configurations.

Fore, say we have to design a library that exposes a function to create an HTTP server. This function would accept different inputs -- an address and a port -- the following shows the skeleton of the function -- 

```go
func NewServer(addr string, port int) (*http.Server, error) {//...}
```

- if the port isn’t set, it uses the default one
- if the port is negative, it returns an error
- if the port is equal to 0, uses a random port
- uses port provided by the client

#### Config struct

Cuz Go doesn’t support optional parameters in function signatures, 

```go
result := Identity(StringList{"a", "b", "c"})
fmt.Printf("result is a %T\n", result)

func Identity[E any](s []E) []E {
    return s
}
```

We *passed* a value of type `StringList`-- and the function returned the exact slice we passed to it -- but now it’s changed type -- can see why this is happening if we replace the generic type parameter with the specific type involved, in this case, it’s a string. So:

```go
func (s StringList) Len() int {
    return Len(s)
}

func main() {
    result := Identity(StringList{"a", "b", "c"})
    fmt.Println(result.Len())
}
```

Saying that the `Identity`takes a parameter of type `S`, where `S`is a slice of any type `E`, there is no important difference between this and what had before.

```go
result := Identity(StringList{"a", "b", "c"})
fmt.Println(result.Len())
```

Go is reminding us that since `StringList`is derived from `[]string`-- need to add a type approximation, using the `~`symbol -- like:

```go
func Identity[S ~[]E, E any](s S) S {
    return s
}
// now it works -- 
result := Identity(StringList{"a", "b", "c"})
fmt.Println(result.Len()) // 3
```

#### Parameterizing by slice and element type

Really want any function of this kind to return the exact same type as it recevies - even if that is derived type such as `StringList`-- one way to write that is to add another type parameters -- which is itself defined in term of `E`.

```go
func Identity[S []E, E any](s S) S
```

Saying that `Identity`takes a parameter of type `S`-- where `S`is slice of any type `E`-- Fair enough, There is no important difference between this and what we had before. The point is that we now declare the function’s result type as `S`, whatever `S`turns out to be.

```go
result := Identity(StringList{"a", "b", "c"})
fmt.Println(result.Len())
```

Almost, Go is reminding us that, since `StringList`is derived from `[]string`, we need to add a type approximation, using the `~`symbol -- For this, really want any function of this kind to return the exact same type as it receives, even if that’s derived type such as `StringList`-- one way to write that is to add another type paraemter `S`-- which is itself defined in terms of `E`-- like:

```go
func Identity[S []E, E any] (s S) S
func Identity[E any](s []E) []E { // if is an []int, just return []int
	return s
}
func Identity[S ~[]E, E any] (s S) S {
    return s
}
```

Go is reminding us that, since `StringList`is derived from `[]string`, need to add a type appropriximation.