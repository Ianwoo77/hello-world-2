# Wrapping callbacks and unwrapping promises

```ts
export const endPromise = promisify(ServerResponse.prototype.end) as
	(data:any)=> Promise<void>;
```

The first step is to use `promisify`to create a function that returns a promise, which I do by passing the `ServerResponse.prototype.end`function to `promisify`-- used the `as`to override the type inferred by the Ts compiler with a description of method parameters and result. Then just like:

```ts
export const handler = async(req: IncomingMessage, res: ServerResponse) => {
    try {
        const data: Buffer = await readFile("data.json");
        await endPromise.bind(res)(data);
        console.log("file sent");
    }catch(err: any) {
        console.log(`Error: ${err?.message ?? err}``);
        res.statusCode = 500;
        res.end();
    }
};
```

Have to use the `bind`method when using the `await`keyword on the function that `promisify`creates.

#### Executing custom code

All Js code is executed by the main thread, which means that any operation that doesn’t use the non-blocking API provided by Node.JS will block the thread.

```ts
const server = createServer();
server.on("request", (req, res) => {
    if (req.url?.endsWith("favicon.ico")) {
        res.statusCode = 404;
        res.end();
    } else {
        handler(req, res);
    }
});
```

Blocking operation in the handler.ts file in the folder -- 

#### Using worker threads

The key limitation of the example is there will still only one main thread, and it still has to do all the work, regardless of how equitably that work is done. Node.Js supports *worker threads* -- which are additional threads of executing Js code, albeit with restrictions. Worker threads run in separate instances of the Node.js engine, executing code in isolation from the main thread. Communication between the main thread and worker threads is done using events. Worker threads are not the solution to every problem cuz there is overhead in creating and managing them, but the provide an effective way to execute Js code without blocking the main thread.

#### Writing the worker code -- 

```ts
console.log(`worker thread ${workerData.request} started`);
for (let iter = 0; iter < workerData.iterations; iter++) {
    for (let count = 0; count < workerData.total; count++) {
        count++;
    }
    parentPort?.postMessage(iter);
}
console.log(`worker thread ${workerData.request} finished`);
```

The `workerData`, is an object or value used to pass configuration data from the main thread to the worker. For this, provides 3 values through `workerData`-- which specify the request ID, the number of iterations, and the target value for each block of counting work. The other is `parentPort`-- used to emit events that will be received by the main thread, like -- `parentPort?.postMessage(iter);`.

## Interface on the producer side

Saw in the previous section when interfaces are considered valuable, but Go developers often misunderstand one question, where should an interface live -- 

- Producer-side -- An interface defined in the same package as the concrete implementation.
- Consumer side -- An interface defined in an external package where it’s used.

It’s common to see developers creating interfaces on the producer side, alongside the concrete implementation. This design is perhaps a habit from developers having a C# or a Js background. But in Go, in most cases this is not what we should do -- fore:

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

Might think we have some excellent reasons to create and expose this interface on the producer side -- perhaps it’s a good way to decouple the client code from the actual imp. Go tends to be a game-changer compared to languages with an explicit implementation. And in most cases, the approach to follow is similar to what we described in the previous section -- *abstraction should be discovered, not created*. Maybe another client wants to decouple its code but is only interested in the `GetAllCustomers`method. Fore:

```go
package client

type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

From package organization, a couple of things to note -- 

- Cuz the `customerGetter`interface is inly used in the `client`package, can just remain unexported
- Visually, in the figure, like circular dependencies, however, there is no dependency from `store`to `client`cuz the interface is satisfied implicitly.

The main point is that the `client`package can now define the most accurate abstraction for its need - it relates to the concept of the interface-Segregation principle, which states that no client should be forced to depend on methods it doesn’t use.

### Returning Interfaces

While designing a function sigature, may have to return an interface or a concrete imp -- understand why returning an interface is in many cases, consdiered a bad practice in Go -- Two packages `client`and `store`-- client contains a `Store`interface and `store`contains an imp of the `Storer`interface. And in the `store`package, define an `InMemoryStore`struct that implements the `Store`interface, meanwhile, create a `NewInMemoryStore`function to return a `Store`interface. Fore, the `client`package can’t call the `NewInMemoryStore`function anymore, otherwise, there would be a cyclic dependency. Furthermore, what happens if another client uses `InMemoryStore`-- in that case, perhaps we would like to move the `Store`interface to another package, or back to the imp package.