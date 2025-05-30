# Parsing URLs

Node.js provides the `URL`class in the `url`module to parse URLs into their parts -- making it easier to inspect URLs to make decisions about what kind of response will be sent. URLs are parsed by creating a new `URL`object and reading the properties -- 

`hostname pathname port protocol search searchParams`

```js
export const handler = async (req: IncomingMessage, resp: ServerResponse) => {
    console.log(`---- HTTP Method: ${req.method}, URL: ${req.url}`);

    const parsedURL = new URL(req.url ?? '', `http://${req.headers.host}`);
                              
    // the URL class parses the query section of the URL and presents it as a set of k/v pairs
    console.log(`protocol: ${parsedURL.protocol}``);
    console.log(`hostname: ${parsedURL.hostname}`);
    console.log(`port: ${parsedURL.port}`);
    console.log(`pathname: ${parsedURL.pathname}`);
    parsedURL.searchParams.forEach((val, key) => {
        console.log(`Search param: ${key}: ${val}`)
    });
    resp.end("Hello, World");
};
```

Creating a `URL`object to parse a URL requires a little work. The `IncomingMessage.url`property returns just a *relative* URL -- which the `URL`class ctor will accept as an argument -- but only if the base part of the URL is specified a second arg like: `http://${req.headers.host}`

The missing piece is the protocol -- the example only accepts regular unsecured HTTP requests so can specify `http`as the protocol -- safe in the knowledge that it will be correct. 

#### Http Responses

The purpose of insepcting an HTTP request is to just determine what kind of response is required, Responses are produced using the features provided by the `ServerResponse`class -- like:

- `sendDatae-- ``boolean`prop determines whether node.js automatically generates the `Date`header.
- `setHeader(name, value)`
- `statusCode`-- number is used to set the response status code
- `statusMessage`-- this is used to set the respones status message
- `writeHeade(code, msg, headers)`-- This method is used to set the status code and optionally, the stauts message 
- `write(data)`-- writes data to the response data, expressed as a `string`or a `Buffer`.
- `end()`-- Tells the response is complete and can be sent to the client.

```ts
export const handler = async (req: IncomingMessage, resp: ServerResponse) => {
    const parsedURL = new URL(req.url ?? "", `http://${req.headers.host}`);
    if (req.method !== "GET" || parsedURL.pathname === '/favicon.ico') {
        resp.writeHead(404, "Not Found");
        resp.end();
        return;
    } else {
        resp.writeHead(200, "OK");
        if (!parsedURL.searchParams.has('keyword')) {
            resp.write('hello HTTP');
        } else {
            resp.write(`hello, ${parsedURL.searchParams.get('keyword')}`);
        }
        resp.end();
        return;
    }
};
```

For this, generates just 3 different resps -- if parsed html has a `keyword`, then just use `parsedURL.searchParams.get(keyword)`to get the resp.

### Supporting https

Using the `TLS/SSL`protocol -- using HTTPs ensures that the request and response cannot be inspected as they traverse public networks -- Supporting SSL requires a certicicate that establishes the identity of the server and is used as the basis for the encryption that secures HTTP requests -- fore

#### Creating the self-signed certificate

The eaiest way to create a self-signed critificate is to use the OpenSSL packge -- just use:

```sh
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes
```

This command just prompts for the details that will be included in the certificate -- and the details don’t matter cuz the certifiate will be used only for development -- 

#### Handling HTTPs requests -- 

The next step is to use the API provided by Node.js to receive HTTPs requests -- just like:

```ts
import {createServer} from "http";
import {createServer as createHttpsServer} from 'https'
import {handler} from "./handler";
import {readFileSync} from "fs";

const port = 5000;
const https_port = 5500;
const server = createServer(handler);

server.listen(port,
    () => console.log(`(Event) server listening on port: ${port}`));

const httpsConfig = {
    key: readFileSync('key.pem'),
    cert: readFileSync('cert.pem')
};
const httpsServer = createHttpsServer(
    httpsConfig, handler
);
httpsServer.listen(https_port,
    () => console.log(`HTTPs server listen on port ${https_port}`));
```

The process for receiving HTTPs requests is similar to regular HTTP -- to the extent that the function for creating an HTTPs server is named `createServer`-- which is just the same name used for HTTP -- to use both versions -- This statement imports the `createServer`function from the `https`module and the `as`keyword is used to assign a name that doesn’t conflict with other imports.

Note that a configuration object is required to specify the cerificate files that were created in the section -- 

```ts
const httpConfit = {
    key: readFileSync('key.pem'),
    cert: readFileSycn('cert.pem')
}
```

The `key`and `cert`properties can be assigned `string`or `Buffer`values -- use the `readFileAsync`function from the `fs`module to read the contents of the `key.pem`and `cert.pem`filed -- which produces `Buffer`values that contain byte arrays. In this case, need to read the contents of `key.pem`and `cert.pem`files as part of the app setup -- there is little benefit to using a callback or a promise cuz need the contents of those files to configure Node.JS to listen for HTTPs requests and using non-blocking operations produces code complexly. The code shows can read files uing the non-blocking `readFile`function -- but the nested callbacks are harder to make sense.

```ts
readFile('key.pem', (err, keyBuffer)=> {
    readFile('cert.pem', (err, certBuffer)=> {
        const server = createServer(handler);
    	server.listen(port, ()=> {...});
                                  //...
    })
})
```

#### Detecting HTTPS requests -- 

The node.js API uses `IncomingMessage`and `ServerResponse`classes for both HTTP and HTTPs requests -- which means that the same handler function can be used for both request types -- can be useful to know which kind of request is being processed to that different responses can be generated.

```ts
export const isHttps = (req: IncomingMessage): boolean => {
    return req.socket instanceof TLSSocket && req.socket.encrypted;
}
export const handler = async (req: IncomingMessage, resp: ServerResponse) => {
    const protocol = isHttps(req) ? "https": "http";

    const parsedURL = new URL(req.url ?? "", `${protocol}://${req.headers.host}`);
    if (req.method !== "GET" || parsedURL.pathname === '/favicon.ico') {
        resp.writeHead(404, "Not Found");
        resp.end();
        return;
    } else {
        resp.writeHead(200, "OK");
        if (!parsedURL.searchParams.has('keyword')) {
            resp.write(`Hello, ${protocol.toUpperCase()}`);
        } else {
            resp.write(`hello, ${parsedURL.searchParams.get('keyword')}`);
        }
        resp.end();
        return;
    }
};
```

Just note that the `socket`property defined by the `IncomingMessage`class will return an instance of the `TLSSocket`class for the secure request and this class defines an `encypted`property that always returns `true`.

#### Redirecting inscure requests

HTTPs has become preferred way to offer web functionality and it is common practice to respond to regular HTTP requests with a response that directs the client to use HTTPs instead -- like:

```ts
export const redirectHandler = (req: IncomingMessage, resp: ServerResponse)=> {
    resp.writeHead(302, {
        'location': 'https://localhost:5500'
    });
    resp.end();
}
```

This new handler uses the `writeHead()`method to set the status code 302, whcih denotes a redirection, and sets the `Location`header -- specifeis the URL the browser should request instead -- Then in the server.ts file just:

```ts
const server = createServer(
    redirectHandler
);
```

For now, if use the browser to request http://localhost:5000, then the response sent by the new handler will cause the browser to request https://localhost:5500.

##### HTTP/2

All the examples in this use Http/1.1 -- which tends to be the default for node.js web app development -- HTTP/2 is an update to the HTTP protocol that is intended to improve performance -- uses a single network connection to interleave multiple requests from the client, sends headers in a compact binary format... But HTTP/2 isn’t an automatic choice for Node.JS projects, even though it is more efficient.

### Using 3rd-party enhancements

The API that Node.JS provides for HTTP and HTTPs is comprehensive but can produce verbose code that is difficult to read and maintain -- one of joys of JS development is huge range of open-source packages that avaiable and there are many packages that are built on the Node.js API to simplify request handling.

The most popular of these packages is `Express`-- Run the commands show in the `webapp`folder to install the Express package and the Ts types for Express in the example projects.

#### Using the Express router

Request handler functions use the API mix the statement that inspect requests with the code that generates responses. A new branch of code is required every time a new URL is supported by the app -- 

```ts
if(parsedURL.pathname == "/newurl") {
    resp.write("hello, new URL");
}else if(!parsedURL.searchParams.has('keywords')) {
    resp.write(`hello ${protocol.toUpperCase()}`);
}
```

Each new addition makes the code more complex and increases the chances of a coding error that either doesn’t match the right requests or generates the wrong response.

## Type Parameters

NOw that’s easier to explain -- means we can write functions like `PrintAnyting`and `AddAnyting`. 

```go
func PrintAnything[T any](v T) {...}
```

Suppose we want to write a function called `Identity`that simply returns whatever value U pass it -- how could we write such a function in Go -- without having to implement a separate version for each possible type of value -- 

```go
func Identity(v any) any {
    return v
}
```

This works -- but isn’t really satisfactory -- with the previous chapter -- 

```go
func Identity[T any](v T) T {
    return v
}
```

#### Composite types -- 

Figured out how to define a generic function that -- `T`takes a parameter of type `T`-- Generic functions are great -- we often deal with *collection* of values in Go -- 

```go
type SliceOfInt []int
```

Already know that -- just as an `int`variable can only hold `int`values -- a `[]int`slice can only hold `int`elements -- we wouldn’t want to have to also define `SliceOfFloat`-- 

```go
type Bunch[E any] []E
```

The elements all have the same type -- it’s very important to understand that, even though a `Bunch`is defined as a slice of `E`for any type `E`-- any particular `Bunch`can’t contain values of a *different* types -- all the elements of a `Bunch[T]`must be of a type -- like:

```go
b := Bunch[int]{1,2,3}
b = append(b, "hello")
```

#### Generic types as function parameters

Can create both generics function and generic types -- 

```go
func PrintBunch[E any](v Bunch[E]) {
    fmt.Println(v)
}
func main() {
    b := Bunch[int]{1,2,3}
    PrintBunch(b)
}
```

#### Constraining type parmeters

Saw in the prevoius chapter that one of the limitations of interface types in Go - is that we can’t use them with operators such as `+`like:

### Constraints

Fore, could write a generic function parameterised by some type -- `T`but this time `T`can’t be just `any`type -- 

```go
func Stringify[T fmt.Stringer](s T) string {
    return s.String()
}
```

It works the same way as the generic functions we have already written -- the only new thing is that we used the constraint `Stringer`instead of `any`.

#### Type set constraints

Fore, suppose want to write some generic function `Double`that multiples a number by two -- want a type constraint that allows only values of type `int`-- we know that `int`has no methods -- can’t use any basic interfaces as a constraint

```go
type OnlyInt interface {
    int
}
func Double[T OnlyInt](v T) T {
    return v*2
}
```

In other words, some `T`that satisfies the constraint `OnlyInt`-- `Double`takes a `T`parameter and returns a `T`result.

#### Unions

```go
type Integer interface {
    int | int8 | int16...
}
```

For the `Number`can be:

```go
type Number interface {
    Integer | Float | Complex
}
```

The set lf all allowed types -- The *type set* of a constraint is the set of all types that satisfy it. -- Probably know that with a basic interface --  a type must have *all* the methods listed in order to implement the interface.

Intersections -- fore:

```go
type ReaderStringer interface {
    io.Reader
    fmt.Stringer
}
```

Note that if were to write this as in *interface literal* -- would separate the methods with a `;`instead of a newline

```go
interface {io.Reader; fmt.Stringer}
```

Empty type sets -- 

```go
type Unpossible interface {
    int
    string
}
```

For this, if try to instantiate a function constrined by `Unpossible`-- can’t.

#### Composite type literals

A *composite* type is one that is built up from other types -- we saw some composite types in the previous -- such as `[]E`-- which is a slice of some element type `E`. Not restricted to define types with names -- also construct new types on the fly, using a *type literal* -- literally writing out the type definition as part of the interface.

A struct type literal -- 

```go
typhe Pointish interface {
    struct {X, Y int}
}
```

While can write a generic function constrained by some struct type such as `Pointish`-- there are limitations on what that function can do with that type -- like:

```go
func GetX[T Pointish](p T) int {
    return p.X
}
```

#### Some limitations of type sets

An interface containing type elements can *only* be used a constraint on a type parameter -- can’t be used as the type of a variable or parameter declaration -- like a basic interface can.

#### Approximations

```go
type ApproximatelyInt interface {
    ~int
}
```

Derived types -- Approximations are especially useful with struct type elements -- like:

```go
type Pointish interface {
    struct {x, y int}
}

func Plot[T Pointish] (p T) {}
```

Can pass it vlues of type `struct{x, y int}`-- like:

```go
p := struct{x, y int}{1,2}
Plot(p)
```

But now, comes a problem -- can’t pass values of any named struct type, even if the struct definintion itself matches the constraint perfectly -- like:

```go
type Point struct {
    x, y int
}
p := Point{1,2}
Plot(p) // for this, Point does not implement Pointish
```

For this, our constrint allows just `struct{x, y int}`, but `Point`is not that type. So just like -- 

```go
type Pointish interface {
    ~struct{x, y int}
}
```

#### Interface literals

Up to now-- used type parameters with a *named* constraint -- such as `Integer`-- and we know that those constraints are defined as interfaces -- so could we use an *interface literal* as a type constraint -- like:

Syntax of an interface literal -- An interface literal, -- consists of keyword `interface`followed by curly braces containing some interface elements -- Fore the simplest interface literal is the empty -- `interface{}`, we should be able to write this empty interface literal whenever `any`is allowed as a type constraint -- like:

```go
func Identity[T interface{}] (v T) T {}
```

As we can, are not restricted to only *empty* interface literals -- could write an interface literal constraints a method element -- fore:

```go
func Stringify[T interface{ String() string}](s T) string {...}
```

Already seen this exact function -- only that case it had *named* constraint `Stringer`-- simply replaced that name with the corresponding interface literal -- 

#### Omitting the `interface`keyword

And are not limited to just method elements in interface literal used as constraints -- can use type element -- 

`[T interface{~int}]`

Fore, can write some function like:

```go
func Increment[T ~int](v T) T {
    return v+1
}
```

Just note that can omit the `interface`keyword when the constraint contains exactly one type element -- multiple elements wouldn’t be allowed -- like:

```go
func Increment[T ~int; ~float64](v T) T {// syntax error}
```

Fore -- 

```go
func IsGreater[T interface{Greater(T) bool}](x, y T) bool {
    return x.Greater(y)
}

type MyInt int

func (m MyInt) Greater(v MyInt) bool {
	return m > v
}

func TestIsGreater_IsTrueFor2And1(t *testing.T) {
	t.Parallel()
	if !identity.IsGreater(MyInt(2), MyInt(1)) {
		t.Errorf("got: %v; want: %v", false, true)
	}
}
```

## Using the Express router

For the previous use case just using the `http`package like:

```js
esp.writeHead(200, "OK");
if(parsedURL.pathname == "/newurl") {
    resp.write("hello, new URL");
}else if(!parsedURL.searchParams.has('keywords')) {
    resp.write(`hello ${protocol.toUpperCase()}`);
}
if (!parsedURL.searchParams.has('keyword')) {
    resp.write(`Hello, ${protocol.toUpperCase()}`);
} else {
    resp.write(`hello, ${parsedURL.searchParams.get('keyword')}`);
}
resp.end(); // ...
```

For this, new addition makes the code more complex and increases the chances of a coding error that either doesn’t match the right requests or generates the wrong response -- The `Express`router solves this problem by separating request matching from generating responses.

```ts
export const notFoundHandler
        = (req: IncomingMessage, resp: ServerResponse) => {
    resp.writeHead(404, "Not Found");
    resp.end();
}
export const newUrlHandler
        = (req: IncomingMessage, resp: ServerResponse) => {
    resp.writeHead(200, "OK");   
    resp.write("Hello, New URL");
    resp.end();
}
export const defaultHandler
        = (req: IncomingMessage, resp: ServerResponse) => {
    resp.writeHead(200, "OK");
    const protocol = isHttps(req) ? "https" : "http";
    const parsedURL = new URL(req.url ?? "",
        `${protocol}://${req.headers.host}`);   
    if (!parsedURL.searchParams.has("keyword")) {
        resp.write(`Hello, ${protocol.toUpperCase()}`);
    } else {
        resp.write(`Hello, ${parsedURL.searchParams.get("keyword")}`);           
    }
    resp.end();
}
// then use the Express like:
const expressApp: Express = express()
expressApp.get('/favicon.ico', notFoundHandler);
expressApp.get('/newurl', newUrlHandler);
expressApp.get(/\.*/, defaultHandler);
const httpServer = createHttpsServer(httpsConfig,
    expressApp);
httpServer.listen(https_port,
    ()=>console.log(`(Event) https server listening on port: ${https_port}`));
```

Note that the import like: `impoert express, {Express} from ‘express’;` The `express`function is invoked to create an `Express`object, which provides methods for mapping requests to handler function. There is a -- 

- `all(path, handler)`-- this routes all requests that match the path to the specific handler function.
- `use(handler)`-- this adds a middleware component, which is able to inspect and intercept all requests.

#### Using the request and response enhancements

In addition to routing, Express provides enhancements to the `IncomingRequest`and `ServerResponse`objects that are passed to handler function -- the object that represents the HTTP request is named `Request`and it extends the `IncomingRequest`type -- the most useful `Request`enhancements -- 

- `hostname`-- this property provides convenient acess to the value of the `hostname`header
- `params`-- This property provides access to route parameters -- which are described in the *using express*.

Other Express enhancement relate to features described in later chapters -- 

```ts
import {Request, Response} from 'express';

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

`Express`automatically parses the request URL and makes its parts accessible through the `Response`properties which means don’t have to parse the URL explicitly.  The convenient secure property means that I can remove the `isHttps`. The `Response`method reduce the number of statements required to produce responses. The `send`method, fore, takes care of setting response status code, set some useful headers and calls the `end`method to tell Node.js that the response is complete -- https://localhost:5500?keyword=express

#### Using Express route parameters

It is important to understand the Express doesn’t do anything magical and its features are built in on those provdied by Node.JS described earlier in the chapter -- the value of Express is that makes the Node.js API easier to consume -- with the result that the code is easier to understand and maintain.

One especially useful feature that Express provides is specifying *route parameters* -- which exact values from URL paths when matching requests and make them easily acceissible through the `Response.params`property.

`expressApp.get(‘/newUrl/:message?’, newUrlHandler);`

The modified route matches requests when the path beings with `/newurl`. The second segement in the URL path is assigned to a route parameter named `message`-- the parameter is donoted by the colon -- For the URL path `/newurl/london`-- fore, the `message`parameter will be assigned to a route parameter named `message`-- the parameter is denoted by the colon. For the URL path `/newrul/london`-- fore, the `message`paramter will be assigned the value `london`-- the question mark the denotes this is an optional parameter, which means the route will match requests even if there is no second URL segment.

## Setting up the session manager

In this run through the process of setting up and using the `alexedwards/scs`package -- but going to use it in a production app i recommend reading the *documentation* and *API reference* to famililarlize yourself with the full range of features.

```sql
CREATE TABLE sessions {
	token CHAR(43) PRIMARY KEY,
	data BLOB NOT NULL,
	expiry TIMESTAMP(6) NOT NULL
);
```

In this table -- 

- The `token`field will contain a unique -- randomly-generated, idenfier for each session.
- The `data`field will contain the actual session data that you want to share between HTTP requests. This is stored as *binary data* in a `BLOB`type.
- The `expiry`field will contain an expiry time for the session -- The `scs`package will automatically delete expired sessions from the `sessions`table so that it doesn’t grow too large.

```go
type application struct {
    //...
    sessionManager *scs.SessionManager
}

func main() {
    //...
    formDecoder := form.NewDecoder()
    sessionManager := scs.New()
    sessionManager.Store = mysqlstore.New(db)
    sessionManager.Lifetime= 12*time.Hour
    
    app := &application {
        //...
        sessionManger: sessionManager,
    }
    srv := &http.Server {
        Add: 	 *addr,
        ErrorLog: errLog,
        Handlers: app.route(),
    }
}
```

For the sessions to work, also need to wrap our application routes with the middleware provided by the `SessionManager.LoadAndSave()`method -- this middleware automatically loads and saves session data with every HTTP request and response.

It’s important  to note that we don’t need this middleware to act on *all* our application routes -- Specifically, don’t need it on the `/static/*filepath`-- cuz all this does is serve static files and there is no need for any stateful behavior. So cuz of that -- it doesn’t make sense to add the session middleware to our existing `standard`middleware chain. Create a new `dynamic`middleware chain containing the middleware appropriate for our dynamic app routes only -- open the `routes.go`file and update it like -- 

```go
func(app *application) routes() http.Handler {
    router := httprouter.New()
    route.NotFound = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        app.NotFound(w)
    })
    fileServer := http.FileServer(http.Dir("./ui/static/"))
    router.Handler(http.MethodGet, "/static/*filepath", http.StripPrefix("/static", fileServer))
    
    dynamic := alice.New(app.sessionManager.LoadAndSave)
    
    router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
    router.Handler(http.MethodGet, "/snippet/view/:id", dyamic.ThenFunc(app.snippetView))
    router.Handler(http.MethodGet, "/snippet/create", dynamic.ThenFunc(app.snippetCreate))
    router.Handler(http.MethodPost, "/snippet/create", dynamic.ThenFunc(app.snippetCreatePost))
    return 
}
```



