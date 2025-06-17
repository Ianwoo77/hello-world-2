# Node.JS concurrency

Server-side web development is characterized by processing large volumes of HTTP requests as quickly and efficiently as possible.

```sh
npm i -D typescript
npm i -D tsc-watch
npm i -D @tsconfig/node20
npm i --save @types/node # just older syntax
```

HTTP request is represented by an `IncomingMessage`and the response is created using the `ServerResponse`object. Like -- 

```ts
const port = 5000;
const server = createServer(handler);
server.listen(port, ()=> {console.log("...")})

export const handler = (req: IncomingMessage, res: ServerResponse)=> {
    res.end("...")
}
```

#### Using the Node.JS API

Node.js replaces the API providedy by the browser with one that supports common server-side tasks -- such as processing HTTP requests and reading files -- Behind the scenes, Node,js uses native threads, known as the workder pool, to perform operations asynchronously.

```ts
export const handler = (req: IncomingMessage, res: ServerRespnse)=> {
    readFile("data.json", (err: Error | null, data: Buffer)=> {
        if(err== null) {
            res.end(data, ()=>console.log("file sent"));
        }else {
            console.log(`error: ${err.message}`);
            res.statusCode=500;
            res.end();
        }
    });
}
```

For this, the `readFile`reads the contents of a file, Use a web browser to reuest. The read operation is asynchronous and is implemented using a native thread -- the contents of the file are passed to a callback function.

#### Handling Events

```ts
const port = 5000;
const server = createServer();
server.on("request", handler)
server.listen(port);
server.on("listening", ()=> {console.log("...")})
```

- `on(event, callback)`-- registers a *callback* to be invoked whenever the specified event is emitted
- `off(event, callback)`-- invoking the *callback* when the specieic event is emitted
- `once(event, callback)`-- be invoked the next time the specified event is emitted but *not thereafter*.

#### Working with promises

```ts
import {readFile} from "fs/promises";

export const handler = (req.IncomingMessage, res: ServerResponse)=> {
    const p: Promise<Buffer> = readFile("data.json");
    p.then((data:Buffer)=> res.end(data, ()=>console.log("file sent")));
    p.catch((err: Error)=> {
        console.log(`Error: ${err.message}`);
        res.statusCode=500;
        res.end();
    });
};
```

And, using `async`and `await`keywords flattens the code by remooving the need for the `then`method and its function, and the `async`keyword is applied to the function used to handle requets. Fore:

```ts
export const handler = async(req: IncomingMessage, res: ServerRepsonse) => {
    const data: Buffer= await readFile("data.json");
    res.end(data, ()=>console.log("File sent"));
}
```

For this, using the `async`and `await`-- like: For this, to support error handling -- the `catch`clause used on `Promise`objects is replaced with a `try/catch`block when using the `await`keyword -- 

```ts
export const handler = async(req:IncomingMessage, res: ServerResponse)=> {
    try {
        const data: Buffer = await readFile("data.json");
        res.end(data, ()=> console.log("File sent"));
    }catch (err: any) {
        console.log(`Error: ${err?.message ?? err}``);
        res.statusCode = 500;
        res.end();
    }
}
```

#### Wrapping callbacks and unwrapping promises

Not every part of the Node.JS API supports both promises and callbacks, and that can lead to both approaches being mixed in the same code. Fore:

```ts
const data: Buffer = await readFile("data.json"); // use promise
res.end(data, ()=> console.log("file sent")); // use callback
```

In Node.js, `promisfy`is a utility function from the `util`module that converts a callback-based function into a Promised-based one. Useful for working with older APIs that use callbacks.

```ts
import {promisify} from "util";
import {ServerResponse} from "http";

export const endPromise= promisify(ServerResponse.prototype.end) as
    (data:any)=> Promise<void>;
```

This code you provided uses Node.JS’s promisify from the `util`module to convert the `ServerResponse.prototype.end`method into a *Promise-based* function. Use the `as`keyword to override the type inferred by the Ts compiler with the description of the method.

```ts
export const handler = async(req:IncomingMessage, res: ServerResponse)=> {
    try {
        const data: Buffer = await readFile("data.json");
        await endPromise.bind(res)(data); // the end method is the res instance's method
        console.log("file sent");
    }catch(err:any) {
        //...
    }
}
```

The use of `.bind(res)`in `await endPromise.bind(res)(data)`is necessary to ensure that the promisified `endPromise`function -- wraps the `ServerResponse.prototype.end`is called with the correct `this`context. Cuz -- 

1. The context of the `ServerResponse.prototype.end`-- the `end`method is defined on the `ServerResponse.prototype`-- meaning it’s a method that operates on an instance of the `ServerResponse`.
2. And the methods in Js rely on the `this`to access the instance they’re called on. `this`must refer to the `res`to properly finalize the HTTP response.

```ts
const server = createServer();
server.on("request", handler);
server.listen(port,
    () => console.log(`(Express) server listening on port: ${port}`));
```

## Interface pollution

Fore, the `io`package provides abstractions for I/O primitves -- among these abstractions, `io.Reader`relateds to reading data from a data source and `io.Writer`to writing data to a target.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
type Writer interface {
    Write(p []byte)(n int, err error)
}
```

Fore, Custom imp of the `io.Reader`should accept a slice of bytes, filling it with its data and return the number and error. And custom imp of `io.Writer`should write the data coming from a slice to a target and return either the number of bytes written or an error.

```go
func copySourceToDest(source io.Reader, dest io.Writer) error {...}
```

Writing a unit test for this function like:

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    source := strings.NewReader(input)
    dest := bytes.NewBuffer(make([]byte, 0))
    err := copySourceToDest(source, dest)
    if err != nil {
        t.FatalNow()
    }
    got := dest.String()
    if got != input {
        t.Errorf("...")
    }
}
```

For this, the `source`is a `*string.Reader`and the `dest`is a `*bytes.Buffer`-- test the behavior of `copyToDest`without creating any files. Indeed, adding methods to an interface can decrease its level of reusability. and `io.Reader`and `io.Writer`are powerful abstraction cuz they cannot get any simpler. Furthermore, can also combine fine-grain interfaces to create higher-level abstractions. like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

##### Common Behavior

The first option we will discuss is to use interfaces when multiple types implement a common behavior -- 

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

This interface has a strong potential for reusability cuz it encompasses the common behavior to sort any collection that is index-based. Can find dozens of implementations -- if at some point we compute a collection of integers, fore, and want to sort it, are we necessarily interested in the imp type -- Fore, finding the right abstraction to factor out a behavior can also bring many benefits -- fore:

```go
func IsSorted(data Interface) bool {
    n := data.Len()
    for i:= n-1; i>0; i-- {
        if(data.Less(i, i-1)) {
            return false
        }
    }
    return true
}
```

##### Decoupling

Another important use case is about decoupling our code from an implementation. If rely on an abstraction instead of a concrete imp -- the imp itself can be replaced with another without even having change our code.

```go
type CustomService struct {
    store mysql.Store
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer {id: id}
    return cs.store.StoreCustomer(customer)
}
```

What if we want to test this method -- cuz `customerService`relies on the actual imp to store a `Customer`-- are obliged to test it through integration tests -- which requires spinning up a MySQL instance -- like:

```go
type customerStorer interface {
    StoreCustomer(Customer) error
}
type CustomerService struct {
    store customerStorer
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer {id: id}
    return cs.storer.StoreCustomer(customer)
}
```

Cuz storing a customer is now done via an interface, this gives us more flexibility in how we want to test the method. Can -- 

- Use the concrete via integration tests
- use a mock via unit tests
- or Both

##### Restricting behavior

The last use case will discuss can be pretty counterintuitive -- it’s about restricting a type to specific behavior -- imagine we implement a custom configuration package to deal with dynamic configuration.

```go
type IntConfig struct {}
func (c *IntConfig) Get() int {
    //... Retrieve configuratino
}
func (c *IntConfig) Set(value int) {
    // update the configuration
}
```

For this, suppose receive an `IntConfig`that holds some specific configuration, such as a threshold -- in the code, are only interested in retrieving the configuration value, and want to prevent updating it. So, How can we enforce that -- namely -- this configuration is just *read-only*. Like:

```go
type intConfigGetter interface {
    Get() int
}
type Foo struct {
    threshold intConfigGetter
}
func NewFoo(threshold intConfigGetter) Foo {
    return Foo {threhold: threshold}
}
```

#### Interface on the producer side

When interfaces are considered valuable -- Go developers often misunderstand one question, where should an interface live.