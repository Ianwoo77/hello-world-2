## Measuring coroutine execution time with decorators

There is a strong relationship between tasks and futures. `task`directly inherits from `future`, A `future`can be thought as representing value that we won't have for a while. A `task`can be thought as a combination of both a *coroutine* and a `future`. When create a `task`, are creating an empty `future`and running the coroutine, then when the coroutine has completed with either an exception or a result, set the result or exception of the `future`.

The common thread between these in the `Awaitable`abc -- this class defines one abs double `__await__`, anything just implements the `__await__`method can be used in an `await`expression. Coroutines inherit directly from `Awaitable`.

The old will get messy quickly when have multiple `await`statements and tasks to keep track of -- A better approach is to come up with a reusable way to keep track of how long any coroutine takes to finish -- can do this by creating a decorator that will run an `await`for us -- like:

```py
def async_timed():
    def wrapper(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapped(*args, **kwargs) -> Any:
            print(f'starting {func} with args {args} {kwargs}')
            start = time.time()
            try:
                return await func(*args, **kwargs)
            finally:
                end = time.time()
                total = end - start
                print(f'finished {func} in {total:.4f} second(s)')

        return wrapped

    return wrapper
```

In this decorator, create a new coroutine called `wrapped`, this is a wrapper around our original coroutine that takes its arguments `*args`and `**kwargs`and calls an `await`statment -- then returns the result. Surround the `await`statment with one message when start running the func and another message when edn running the function, keep track of the start and end time in much the same way that did in our earlier start-time and end-time example.

```py
from util import async_timed
import asyncio
import nest_asyncio

nest_asyncio.apply()


@async_timed()
async def delay(delay_seconds: int) -> int:
    print(f'sleeping for {delay_seconds} second(s)')
    await asyncio.sleep(delay_seconds)
    print(f'finished sleeping for {delay_seconds} second(s)')
    return delay_seconds


@async_timed()
async def main():
    task_one = asyncio.create_task(delay(2))
    task_two = asyncio.create_task(delay(3))
    await task_one;
    await task_two


asyncio.run(main())
```

using this decorator and the resulting output throughout the next -- 

### The Pitfalls of coroutines and tasks

Simply marking functions `async`and wrapping them in tasks may not help app performance -- In certain cases, this may degrade the performance of ur applications. Two main errors occur when trying to turn your app async -- The first is attempting to run CPU-bound code in tasks or coroutines without using multiprocssing, and the second is using blocking `I/O`-bound APIs without using multithreading

### Running CPU-bound code

Where have several of these functions with the potential to run concurrently, may get the idea to run them in separte taksks. -- Remember that the `asyncio`just has a single-threaded concurrency model -- means are still subject to the limitations of a single thread and the GIL. To prove:

```py
import asyncio
from util import delay


@async_timed()
async def cpu_bound_work() -> int:
    counter = 0
    for i in range(100000000):
        counter += 1
    return counter


@async_timed()
async def main():
    task1 = asyncio.create_task(cpu_bound_work())
    task2 = asyncio.create_task(cpu_bound_work())
    await task1;
    await task2


asyncio.run(main())
```

When run this, just despite creating two tasks, our code stil lexecutes sequentially, first, run Task1, then run.. meaning our total runtime will be the suem of the two calls.

### Running blocking APIs

May also be tempted to use existing for I/O-bound operations by wrapping them in coroutines -- however, this will generate the same issues that we saw with CPU-bound operations -- These APIs block the `main`thread, therefore, when we run a blocking API call inside a corutine, are blocking the event loop thread itself. FORE:

```py
import requests


@async_timed()
async def get_example_status() -> int:
    return requests.get('http://www.baidul.com').status_code


@async_timed()
async def main():
    t1 = asyncio.create_task(get_example_status())
    t2 = asyncio.create_task(get_example_status())
    t3 = asyncio.create_task(get_example_status())

    await t1
    await t2
    await t3


asyncio.run(main())
```

This is again cuz the `requesets`just is blocking. meaning it will block whichever thread it is run on. Since asyncio only has one thread, the `requests`lib blocks the event loop from doing anything just concurrently.

And need to use the `requests`library, can still use `async`, but need to explicitly tell `asyncio`to use multithreading with a *thead pool executor*.

### Accessing and Manually managing the event loop

There may be cases in whcih don't want the functionality that `asyncio.run`provides. May want to execute custom logic to stop tasks that differ from the `asyncio.run`does. Also, may want to access methods on the event loop itself.

### Creating an event loop manually

Can create an loop by using the `asyncio.new_event_loop`method -- this will return an event loop instance. With this, have access to all low-level methods that the event lop has to offer. With the event loop have access to a method called `run_until_complete`-- which takes a coroutine and runs it until it finishes. Once we are done with our event loop, just need to close it to free any resources it was using. This could normally be in a `finally`block fore:

```py
import asyncio

async def main():
    await asyncio.sleep(1)
    
loop = asyncio.new_event_loop()

try:
    loop.run_until_complete(main())
finally:
    loop.close()
```

So the code in this listing is similar to what happens when we call `asyncio.run`with the difference being that this does not perform canceling and remaining tasks.

### Accessing the event loop

From time, need to access the currently running event loop -- `asyncio`exposes the `asyncio.get_event_loop`function that allows us to get the current event loop -- As an example, look at the `call_soon()`will schedule a function to run on the next iteration of the event loop.

```py
import asyncio


def call_later():
    print("I'm being called in the future")


async def main():
    loop = asyncio.get_running_loop()
    loop.call_soon(call_later)
    await delay(1)


asyncio.run(main())
```

In this listing, our main coroutine gets the event loop with `asyncio.get_running_loop()`and tells it to run `call_later`, which takes a function and will run it on the next iteration of the event loop, in addition, there is also an `asyncio.get_event_loop`, access the event loop. -- This just can potentially create a new event loop if it is called when one is not already running. May lead to strange behavior -- it is just recommended to just use `get_running_loop`, as this will throw an exception if an event loop isn't running.

### Debug mode

When run in `debug`mode, see a few log messages.

`asyncio.run(coroutine(), debug=True)`

## A first asyncio Application

Learn the basic of how to send and receive data with blocking sockets -- Utilizing asyncio for web requests allows us to make hundreds of them at the same time -- cutting down our app's runtime compared to a async approach. First, the `aiohttp`that enable this -- This lib uses non-blocking sockets to make web requests and returns coroutins for those requests, which we can `await`for a result.

### aiohttp

First is to make a HTTP requst -- first need to learn a bit of new syntax for async context managers. Using this will allow us to acquire and close HTTP sessions cleanly. As an asycio developer, will use this syntax frequently for sync acquiring resourcs, such as dbs connections.

### Async context managers

Py introduced a new lang feature to support this use case, called *async context manager* -- the syntax is almost the same as for sync context managers with `async with`instead of `with`. This py way to manage files is a lot cleaner -- if an exception is thrown in the `with`, will automaitcally be closed.

Async context managers are classes that just implement two special coroutine methods `__aenter__`, which async acquire a resource and `__aexit__`-- thiwh closes that resources . The `__aexit__`coroutine takes several arguments that deal with any exceptions that occur.

Fore, class takes in a server socket, and in the `__aenter__`coroutine wait for a client to connect. This just lets us access that connection in the `as`portion of our `async with`statement.

```sh
pip install -Iv aiohttp
```

`aiohttp`-- and web requests in general, employ the concept of a *session*-- think of a session as opening a new browser window, within a new browwser window, you will make conections to any number of web pages, which may send your cookies tath your browser saves for you. With a sessin, will keep many connections open, which can then be recycled.

This is known a **connection pool**. Is an important ant concept aids the performance of our `aiohttp-based`app. Typically, ant to take advantage of connection pooling, so most aiohttp-based apps run one session for the entire application -- this object is then passed to methods where needed. Such as just `GET PUT POST`.

```py
import asyncio
import aiohttp
from aiohttp import ClientSession
from util import async_timed
import nest_asyncio

nest_asyncio.apply()


@async_timed()
async def fetch_status(session: ClientSession, url: str) -> int:
    async with session.get(url) as result:
        return result.status


@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = 'http://www.baidu.com'
        status = await fetch_status(session, url)
        print(f'Status for {url} was {status}')


asyncio.run(main())
```

Once we have a client session, we are just free to maky any web request desired -- In this case, define a convenience method `fetch_status_code`that will take in a session and a URL that return the status code for the given URL. Just note that a `ClientSession`will create a default maximum of 100 conenctions by default. To change the limit, can create an instance of an aiohttp `TCPConnector`specifying the maximum number of connections and passing that to the `ClientSession`.

## Transposing Arrays and Swapping Axes

Transposing a special form of reshaping that similarly returns a view on the underlying data without copying anything. Arrays actually have a `tranpose`method and the special `T`attribute like:

```py
arr= np.arange(15).reshape(3,5)

arr
Out[3]: 
array([[ 0,  1,  2,  3,  4],
       [ 5,  6,  7,  8,  9],
       [10, 11, 12, 13, 14]])

arr.T
Out[4]: 
array([[ 0,  5, 10],
       [ 1,  6, 11],
       [ 2,  7, 12],
       [ 3,  8, 13],
       [ 4,  9, 14]])
```

When doing matrix computations, U may do this very often -- fore, when computing the inner matrix product using `numpy.dot`-- like: `np.dot(arr.T, arr)`

Simple transposing with `.T`is a special case of swapping axes. ndarray just has the method `swapaxes`which takes a pair of axis numbers and switches the indicated axes to re-arrange the data like:

`arr.swapaxes(0,1)`-- similarly returns a view on the data without making a copy.

### Pseudorandom Number Generation

The `numpy.random`module supplements the built-in Py `random`module with functions for efficiently generating whole arrays of sameple values for many kinds of probability distributions.

### Universal Functions : Fast Element-wise Array functions

A universal function, or `ufunc`, is a function that performs element-wise operations on data in ndarrays -- can think of them as a fast vectorized wrappers for simple functions that take one or more scalar values and produce one or more scalar results. Many ufuncs are just simple element-wise transformations -- like `numpy.sqrt`or `exp`. For this are referred to as *unary ufuncs*, and others such as `numpy.add`, `numpy.maximum`, takes two arrays like:

`np.maximum(x,y)`

Ufuncs accept an optional `out`argument that allows them to assign their results into an exisitng array rather than create a new one like:

```py
out = np.zeros_like(arr)
np.add(arr, 1, out=out)
```

- `sign`-- compute the sign of each element, 1, 0 and -1 just
- `ceil`-- Comute the ceiling of each element
- `rint`-- round elements to the nearest integer, preserving the `dtype`
- `modf`-- return factional and integral parts of array as separate arrays
- `isnan, isfinite,isinf`
- `add, subtract, multipy, divide, power, maximum, fmax, mod, copysign, grater, greater_equal, less...`
- `logical_and, logical_or, logical_xor`

### Array - Oriented Programming with Arrays

Using Numpy arrays enables you to express many kinds of data processing tasks as concise array expressions that might otherwise require writing loops. -- this practice of replacing explicit loops with array expressions is referred to by some people as *vectorization*. like:

`z= np.sqrt(xs**2+ ys**2)`

### expressing Conditional logic as Array operations

The `numpy.where`is vectorized version of the ternary expression like:

```py
result= [(x if c else y) for x, y, c in zip(xarry, yarr, cond)]

result
Out[36]: [1.1, 2.2, 1.3000000000000003, 1.4000000000000004, 2.5000000000000004]

np.where(cond, xarry, yarr)
Out[37]: array([1.1, 2.2, 1.3, 1.4, 2.5])
```

### Mathematical and statistical methods

A set of mathematical functions that compute statistics about an entire array or about the data along an axis are accessible as method of the array class. Can use aggregations, like `sum, mean, std`either by calling the array intance method or using the top-level Numpy function. When use `mean(), sum()`...

Functions like `mean`and `sum`take an optional `axis`arg that computes the statistic over the given axis, resulting an array with one less dimension -- like:

```py
arr.mean(axis=1)
```

The expression `arr.cumsum(axis=0)`computes the cumulative sum along the rows, axis=1 computes the sums along the columns.

### Methods for Boolean Arrays

Boolean values are coerced to 1 and 0 in the mehods. like: `sum()`is foten used as a means of counting `True`values in a `Boolean`array just like:

```py
arr= rng.standard_normal(100)

(arr>0).sum()
Out[63]: 52

(arr<0).sum()
Out[64]: 48
```

Two additional mehods, `any`and `all`are also useful especially for `Boolean`arrays, `any`tests whether one or more values in an array is `True`, while `all` checks if every value is `True`.

### Sorting

Like py's built-in list type, Numpy arrays can be sorted in place with the `sort`method like: The top-level method `numpy.sort`returns a sorted copy of an array.

```py
arr2 = np.array([5,-10, 7, 1, 0, -3])
sorted_arr2= np.sort(arr2)
```

### Unique and other set Logic

Some basic `set`operations for 1d ndarrays, A commonly used one is `numpy.unique`which returns the sorted unique values in an array like:

```py
names = np.array(['Bob', 'Will', 'Joe', 'Bob', 'Will', 'Joe', 'Joe'])

np.unique(names)
Out[79]: array(['Bob', 'Joe', 'Will'], dtype='<U4')
```

In many cases, the `Numpy`version is just faster and returns a numpy array rather than a Python list. Another fucntion, like `numpy.in1d`-- tests membership of the values in one array in another, returning a Boolean array like:

```py
values= np.array([6,0,0,3,2,5,6])

np.in1d(values, [2,3,6])
Out[81]: array([ True, False, False,  True,  True, False,  True])
```

- `intesect1d(x, y)`-- compute the sorted, common elements x and y.
- `union1d(x,y)`-- Compute the sorted union of elements

### File input and output with Arrays

Numpy is just able to save and load data to and from disk in some text or binary formats.`numpy.save`and `numpy.load`are the two workhorse functions for efficiently saving and loading array data on a disk. like:

```py
arr= np.arange(10)
np.save('some_arr', arr)
np.load('some_arr.npy')

# can save multiple arrays in an uncompressed archive like
np.savez('arr_archive.npz', a= arr, b= arr)
arch = np.load('arr_archive.npz')
arch['b']
```

## Getting started with pandas

```py
import pandas as pd

obj = pd.Series([4,7,-5,3])
obj
```

The string represenation of a Series displayed interactively shows the index on the left and the values on the right.

```py
obj.array
obj.index
```

The result of the `.array`attribute is a `PandasArray`which usually wraps a `Numpy`array can also contain extension array types which will be more in . like:

`obj2 = pd.Series([4,7,-5,3], index=list('dbac'))` `obj2.index`

Compared with Numpy arrays, can use just lalbes you can use labels in the index when selecting single values or a set of values like `obj2['a']`, `obj2['d']=6` and can also use like:

`obj2[['c', 'a', 'b']]`And using Numpy functions or Numpy-like operations, such as filtering with a Boolean, scalar multiplication, or applying math functions, will preserve the index-value link like:

`obj2[obj2>0]`, `obj2*2`

```py
import numpy as np
np.exp(obj2)
sdata= {'Ohio': 35000, 'Taxas': 71000, 'Oregon':16000, 'Utah':5000}
obj3 = pd.Series(sdata)
obj3
```

And a Series can be always converted back to a dicationay with its `to_dict`method. Fore:

`obj3.to_dict()` -- when you are only passing a dictionary, the index in the resulting `Series`will respect the order of the keys according to the dictionary's keys method, which depends on the key insertaion order.  Can override this by passing an index with the dictionay kesy in the order you want them to appear in th resulting series.

```py
states = ['California', 'Ohio', 'Oregon', 'Texas']
obj4 = pd.Series(sdata, index=states)
```

Here, three values found in `sdata`were placed in the appropraite locations, but since no value for `California`was found, appears `NaN`, which is considered in pandas to mark missing or NA values.

`pd.isna(obj)`, `pd.notna(obj)`, and can also use this methods like:

`obj.isna()` And a useful Series feature for many appliations is that it automatically aligns by index label in arithmetic operations like: Both the Series object itself and its index have a `name`attribute, which integrates with other areas of pandas functionality. like:

`obj4.name='population'`, `obj.index.name='state'`

And a Series' index can be altered in place by assignment like:

`obj.index='Bob Steve Jeff Ryan'.split()`

## Creating and Applying the Routing Configuration

Now that have a range of components to display, the next step is to create the routing configuration that tells Ng how to map URLs into components. Going to follow a simpler approach and define the routes within the `@NgModule`decorator of the app’s root module like:

```tsx
@NgModule({
    declarations: [AppComponent],
    imports: [BrowserModule, StoreModule,
             RouterModule.forRoot([
                 {path:'store', component: StoreComponent},
                 {path: 'cart', compponent: CartDetailComponent},
                 {path:'checkout', component: CheckoutComponent},
                 {path:'**', redirectTo:'/store'},
             ])],
})
```

The `Routermodule.forRoot()`method is passes a set of routes, each of which maps a URL to a component, the first three routes in the listing matches the URLs from -- the final route is wildcard that redirects any other URL to the `/store`, whcih will display `StoreComponent`.

And, when the routing feaure is used, Angular looks for the `router-outlet`element, which defines the location in which the component that corresponds to the current URL should be displayed.

```tsx
@Component({
    selector: 'app',
    template: '<router-outlet></router-outlet>'
})
export class AppComponent {
  title = 'primer';
}

```

Angular will apply the routing configuration when you save the changes and the browser reloads the HTML document. The content displayed in the browser window hansn’t changed.

### Nav through the Application

With the routing configuration in place, it is time to add support for navigation between components by changing the browser’s URL -- The URL routing feature relies on a Js API provided by the browser, which means that the user can’t simply type the target URL into the browser’s URL bar.

So, when the user clicks one of the `Add to Cart`, the cart detail component should be shown, which means that the application should navigation to the `/cart`URL, like:

```tsx
constructor(private repository: ProductRepository, private cart: Cart, 
            private router: Router) {
}
```

```tsx
addProductToCart(product: Product) {
    this.cart.addLine(product);
    this.router.navigateByUrl("/cart");
}
```

The ctor has a `Router`parameter, which is provided by Ng through the DI feature when a new instance of the component is created -- in the `addProductToCart()`method, the `navigateByUrl`is uesd to navigate. And this can also be done by adding the `routerLink`attribute to element in the template.

```html
<button class="btn btn-sm btn-dark text-white" [disabled]="cart.itemCount==0"
        routerLink="/cart">
```

The value specified by the `routerLink`attribute is the URL that the appliation will navigate to thwne the `button`is clicked.

### Guarding the Routes

Remember that nav can be performed only by the appliation. If you change the URL directly in the browser’s URL bar, the browser will request the URL you enter from the web server. The Ng development server that is responding to HTTP requests will respond to any URL that doesn’t correspond to a file by returning the contents of `index.html`.

As an example, if click one of the `Add to Cart`buttons and then click the reload -- The HTTP server will return the contents of the `index.html`file. For some apps, being able to start using different URLs makes sense, but if that is not the case, Then ng supports *route guards*.

```tsx
@Injectable()
export class StoreFirstGuard {
    private firstNavigation = true;

    constructor(private router: Router) {
    }

    canActivate(route: ActivatedRouteSnapshot,
                state: RouterStateSnapshot): boolean {
        if (this.firstNavigation) {
            this.firstNavigation = false;
            if (route.component != StoreComponent) {
                this.router.navigateByUrl("/");
                return false;
            }
        }
        return true;
    }
}
```

There are just different wys to guard routs and this is an example of a guard that prevents a route from being activated. Which is implemented as a class that defines a `canActivate()`method -- the implementation of this uses the context objects that Ng provides the describe the route that is about to be navigated to and checks to see whether the target component is a `StoreComponent`. And if this is the first time that the `canActivate`method has been called and a different component is about to be used, then the `Router.navigateByUrl`method is used to navigate to the root URL.

And note that the `@Injectable()`has been applied in the listing cuz the route guards are services -- In the app.module.ts file: `providers: [StoreFirstGuard],`

```tsx
RouterModule.forRoot([
    {path: "store", component: StoreComponent},
    {path: "cart", component: CartDetailComponent, 
     canActivate:[StoreFirstGuard]},
    {path: "checkout", component: CheckoutComponent},
    {path: "**", redirectTo: "/store"}
])
```

### Completing the Cart Detail Feature

Now that the appliation has nav support, it is time to complete the view the details of the contents of the user’s cart. Need to remove the inline template from the cart detail component, specifies an external template in the same directory, and adds a `Cart`template to the ctor, which will be accessible in the template through a property called `cart`just like:

```tsx
@Component({
    templateUrl:"cartDetail.component.html"
})export class CartDetailComponent{
    constructor(public cart: Cart) {
    }
}
```

And to complete the cart detail feature, created an html file called `cartDetail.component.html`in the `/store`folder and add:

```html
<div class="container-fluid">
    <div class="row">
        <div class="bg-dark text-white p-2">
            <span class="navbar-brand ml-2">SPORTS STORE</span>
        </div>
    </div>

    <div class="row">
        <div class="col mt-2">
            <h2 class="text-center">Your Cart</h2>
            <table class="table table-bordered table-striped p-2">
                <thead>
                <tr>
                    <th>Quantity</th>
                    <th>Product</th>
                    <th class="text-end">Price</th>
                    <th class="text-end">Subtotal</th>
                </tr>
                </thead>
                <tbody>
                <tr *ngIf="cart.lines.length==0">
                    <td colspan="4" class="text-center">
                        Your cart is empty!
                    </td>
                </tr>
                <tr *ngFor="let line of cart.lines">
                    <td>
                        <input type="number" class="form-control-sm"
                               style="width:5em;" [value]="line.quantity"
                               (change)="cart.updateQuantity(line.product,
                               $any($event).target.value)"/>
                    </td>

                    <td>{{line.product.name}}</td>
                    <td class="text-end">
                        {{line.product.price | currency:"USD":"symbol":"2.2-2 }}
                    </td>
                    <td class="text-center">
                        <button class="btn btn-sm btn-danger"
                                (click)="cart.removeLine(line.product.id??0)">
                            Remove
                        </button>
                    </td>
                </tr>
                </tbody>
                <tfoot>
                <tr>
                    <td colspan="3" class="text-end">Total:</td>
                    <td class="text-end">
                        {{cart.cartPrice | currency:"USD":"symbol":"2.2-2"}}
                    </td>
                </tr>
                </tfoot>
            </table>
        </div>
    </div>
    <div class="row">
        <div class="col">
            <div class="text-center">
                <button class="btn btn-primary m-1" routerLink="/store">
                    Continue Shopping
                </button>
                <button class="btn btn-secondary m-1" routerLink="/checkout"
                        [disabled]="cart.lines.length==0">
                    Checkout
                </button>
            </div>
        </div>
    </div>
</div>
```

And this template displays a table showing the user’s product selectoins -- for each product, there is an `input`element that can be used to change the quantity, and there is a `remove`button that deletes it from the cart. There are also two nav buttons tht allow the user to return the list of products or continue to the checkout process.

### Processing Orders

Being able to receive orders from customers is the most important aspect of an online store, and tin the sections that follow, build on the app to add support for receiving the final details from the user and checking them out -- To keep the process just simple, going to avoid dealing with payment..

Extending the model -- To describe orders placed by users, added a file called `order.model.ts`in the `/model`folder and defined the code like -- 

```tsx
import {Cart} from "../store/cart.model";

@Injectable()
export class Order {
    public id?: number;
    public name?: string;
    public address?: string;
    public city?: string;
    public state?: string;
    public zip?: string;
    public country?: string;

    public shipped: boolean = false;

    constructor(public cart: Cart) {
    }

    clear() {
        this.id = undefined;
        this.name = this.address = this.city = undefined;
        this.state = this.zip = this.country = undefined;

        this.shipped = false;
        this.cart.clear();
    }
}
```

This class will just be another srervice -- means there will be one instance shared throughout the application. When Ng creates the `Order`object, it will detect the `Cart`ctor parameter and provide the same `Cart`object that is used elsewhere in the application.

### Updating the Repository and Data Source

To handle orders in the app, need to extend the repository and the data source so they can receive `Order`objects. Since this is still the dummy data source, the method simply produces a JSON string from the order and writes it to the js console.

```ts
saveOrder(order: Order): Observable<Order> {
    console.log(JSON.stringify(order));
return from([order]);
}
```

To mange orders -- add `order.repository.ts`folder and used it to define the class -- there is only one method in the order repository at the moment, but will add functionlity when create the administration features.

```ts
@Injectable()
export class OrderRepository {
    private orders: Order[] = [];

    constructor(private dataSource: StaticDatasource) {
    }

    getOrders(): Order[] {
        return this.orders;
    }

    saveOrder(order: Order): Observable<Order> {
        return this.dataSource.saveOrder(order);
    }
}
```

### Updating the Features Module

Need to register the `Order`class and the new repository as services using the `providers`prop of the model feature module -- in the `model.Module.ts`file -- 

```tsx
@NgModule({
    providers: [ProductRepository, StaticDatasource, Cart, 
    Order, OrderRepository]
})export class ModelModule{}
```

### Collecting the Order Details

The next step is to gather the details from the user required to complete the order -- Angualr includes built-in directives for working with HTML forms and validating their contents. like:

```ts
@Component({
    templateUrl: "checkout.component.html",
    styleUrls: ["checkout.component.css"]
})
export class CheckoutComponent {
    orderSent: boolean = false;
    submitted: boolean = false;

    constructor(public repository: OrderRepository,
                public order: Order) {
    }

    submitOrder(form: NgForm) {
        this.submitted = true;
        if (form.valid) {
            this.repository.saveOrder(this.order).subscribe(order => {
                this.order.clear();
                this.orderSent = true;
                this.submitted = false;
            })
        }
    }
}
```

The `submitOrder`method will be invoked when the user submits a form, which is represented by an `NgForm`object. If the data that the form contains is valid, then the `order`object will be passed to the repository’s `saveOrder`method, and then the data in the cart and the order will be reset.

And the `@Component`'s `styleUrls`prop is used to specify one more CSS stylesheets that should be applied to the conent in the componnet’s template -- to provide validation feedback for the vlaues that the user enters into the HTML form elements -- created a file called `checkout.component.css`and :

```css
input.ng-dirty.ng-invalid {border: 2px solid #ff0000}
input.ng-dirty.ng-valid {border: 2px solid #6bc502}
```

Ng adds elements to the `ng-dirty`, `ng-valid`.. to indicate their validation status -- the full set of validation classes -- but the effect of the styles is to add .. The final piece of the puzzle is the template for the component like:

```html
<div class="container-fluid">
    <div class="row">
        <div class="bg-dark text-white p-2">
            <span class="navbar-brand ml-2">SPORTS STORE</span>
        </div>
    </div>
</div>

<div *ngIf="orderSent" class="m-2 text-center">
    <h2>Thanks!</h2>
    <p>Thanks for placing your order.</p>
    <p>We will ship your goods as soon as possible</p>
    <button class="btn btn-primary" routerLink="/store">Return to Store</button>
</div>

<form *ngIf="!orderSent" #form="ngForm" novalidate
      (ngSubmit)="submitOrder(form)" class="m-2">
    <div class="mb-3">
        <label>Name</label>
        <input class="form-control" #name="ngModel" name="name"
               [(ngModel)]="order.name" required/>
        <span *ngIf="submitted && name.invalid" class="text-danger">
            Please enter your name
        </span>
    </div>

    <div class="mb-3">
        <label>City</label>
        <input class="form-control" #city="ngModel" name="city"
               [(ngModel)]="order.city" required/>
        <span *ngIf="submitted && city.invalid" class="text-danger">
            Please enter your city
        </span>
    </div>

    <div class="mb-3">
        <label>State</label>
        <input class="form-control" #state="ngModel" name="state"
               [(ngModel)]="order.state" required/>
        <span *ngIf="submitted && state.invalid" class="text-danger">
            Please enter your state
        </span>
    </div>

    <div class="mb-3">
        <label>Zip/Postal Code</label>
        <input class="form-control" #zip="ngModel" name="zip"
               [(ngModel)]="order.zip" required/>
        <span *ngIf="submitted && zip.invalid" class="text-danger">
            Please enter your zip/postal code
        </span>
    </div>
    <div class="mb-3">
        <label>Country</label>
        <input class="form-control" #country="ngModel" name="country"
               [(ngModel)]="order.country" required/>
        <span *ngIf="submitted && country.invalid" class="text-danger">
            Please enter your country
        </span>
    </div>

    <div class="text-center">
        <button class="btn btn-secondary m-1" routerLink="/cart">Back</button>
        <button class="btn btn-primary m-1" type="submit">Complete Order</button>
    </div>
</form>

```

The `form`and `input`elements in the template just use Angular feature that ensure that the user provides values for each field -- and provide visual feedback if the user clicks the complete.

### Using the RESTful web Service

Now that the basic functionality is in place, just time to replace the dummy data source with one that gets its data from the RESTful web service that was created during the project setup like:

```ts
const PROTOCOL = "http";
const PORT = 3500;

@Injectable()
export class RestDatasource {
    baseUrl: string;

    constructor(private http: HttpClient) {
        this.baseUrl = `${PROTOCOL}: //${location.hostname}:${PORT}/`;
    }

    getProducts(): Observable<Product[]> {
        return this.http.get<Product[]>(this.baseUrl + "products");
    }

    saveOrder(order: Order): Observable<Order> {
        return this.http.post<Order>(this.baseUrl + "orders", order);
    }
}
```

ng provides a built-in service called `HttpClient`that is used to make HTTP requests, the `RestDataSource`ctor receives the `HttpClient`service and uses the **global** `location`object provided by the browser to determine the URL that requests will be sent to.

### Applying the Data Source

Just applying the RESTful data source by just re-configuring the app so that the switch from the dummy to the REST data is done with changes to the single file.

```ts
providers: [ProductRepository, StaticDatasource, Cart,
            Order, OrderRepository,
            {provide: StaticDatasource, useClass: RestDatasource}]
```

The imports prop is used to declare a dependency on the `HttpClientModule`feature module, The cahange to the providers property just tells Angular that when it needs to create an instance of a clas with a `StaticDataSource`ctor parameter, should use `ResetDataSource`instead.

## Type Modifiers

By now read all about how the TypScript type system works with existing Js constructor such as arrays, classes, and objects. For this chapter, I’m going to take a step further into the type system itself and show features that focus on writing more precise types, as well as types based on other types.

### Top Types

Mentioned the concept of a *bottom type* back to describe a type that can have no possible values and can’t be reached. It stands to reason that the opposite might also exist in type theory.

A *top type*, or universal type, is a type can represent any possible value in a system. Values of all other type can be provided to a location whose type is a top type.

The `any`type can act as a top type-- in that any type can be provided to a location of type `any`, is generally used when a location is allowed to accept data of any type, such as parameters like:

```tsx
let anyValue: any;
anyValue= 'lucille ball';
anyValue=123;
console.log(anyValue);
```

The problem with `any`is that it explicitly tells Tsc not to perform type checking on that value’s assignability or members.

### `unknown`

The `unknown`type in tsc is its true top type, `unknown`is similar to `any`in that all objects may be passed to locations of type `unknown`-- the key difference with `unknown`is that Tsc is much more restrictive about the values `unknown`.

- Typescript does not allow directly accesing properties of `unknown`typed values
- `unknown`is not assignable to types that are not a top type.

Attempting to access a property of `unknown`typed value, as in the following snippet, will cause TSC to report a type error -- like:

```tsx
function greetComedian(name: unknown){
    console.log(name.toUpperCase()); // error
}
```

And the only way that Ts will allow code to access members on a name of type `unknown`is if the:

```ts
function greetComedianSafety(name: unknown) {
    if (typeof name === 'string') {
        console.log(name.toUpperCase());
    } else {
        console.log("well, i'm off");
    }
}
```

### Type Predicates

```ts
function isNumberOrString(value: unknown) {
    return ['number', 'string'].includes(typeof value);
}

function logValueIfExists(value: number | string | null | undefined) {
    if (isNumberOrString(value)) {
        value.toString(); // error
    }
}
```

Ts just has a special syntax for functions that return a boolean meant to indicate whether an argument is particular type. This is referred to as a *type predicate*. Referred to as a -- user-defined type guard -- you developers -- Type prediate’s return type can be declared as the name of parameter the `is`keyword -- and some type like;

`function typePredicate(input: WideType): input is NarrowType`

Can just change the previous example’s helper function to have an explicit return type that explicitly states `value is number | string`-- 

```tsx
function isNumberOrString(value: unknown): value is number | string {
    return ['number', 'string'].includes(typeof value);
}
```

U can think of a type predicate as returning not just a boolean, but also an indicaiton that the argument was that more specific type.

Type predicates are often used to check whether an object already known to be an instance of one interface is an instance of a more speicifc interface -- like:

```ts
interface Comedian {
    funny: boolean;
}

interface StandupComedian extends Comedian {
    routine: string;
}

function isStandupComedian(value: Comedian): value is StandupComedian {
    return 'routine' in value;
}

function workWithComedian(value: Comedian) {
    if (isStandupComedian(value)) {
        console.log(value.routine);
    }
}
```

The `isLongString`type predicate returns `false`if its `input`parameter is `undefined`or a `string`with length less than 7. As a result, the `else`statement is narrowed to thinking `text`must be type of `undefined`.

```ts
function isLongString(input: string | undefined): input is string {
    return !!(input && input.length >= 7);
}

function workWithText(text: string | undefined) {
    if(isLongString(text)){
        console.log("long text:", text?.length);
    } else {
        console.log('short text:', text?.length); // undefined
    }
}
```

### Type Operators

Not all type can be represented using only a keyword or a name of an existing type. It can sometimes be necessary to create new type that combines both, performing some transfomation on the properties of an existing type.

### `keyof`

Js objects can have members retrieived using dynamic values, which are commonly `string`typed. Representing these keys in the type system can be tricky. Using a catchall primitive such as `string`would allow invalid keys for the container value.

## Error and Testing

To write code is write errors, often, an error can be antipated. Risky activities include actions that interact with outside resources. Information that comes from outside your code -- whether you’re reading it from a web page from or reieiving it from another library -- may arrive with errors, or in a different from than 

Defending against errors is essential practice. But it’s equally important to *prevent* them whenever possible. To that end, there are many testing framworks that work with Js, including Jet.. can write unit tests that guarantee your code is executing as expected.

### Catching and Neturaling an Error

Are performing a task that may succeed, and you don’t want an error to interrupt your code or appear in the developer console.

```js
try {
    const uri = decodeURI('http%test');
    console.log('success!');
} catch(error){
    console.log(error);
}
```

When the `decodeURI()`function fails and an error occurs, execution jumps to the `catch`block. The catch block receives an error object which provides the following properties.

- `name`-- A string that usually reflects the error subtype, but it may just be Error.
- `message`-- a String that gives you a human-language description of the problem.
- `stack`-- A string that lists the currently open functions on the stack, in order, from the most recent calls to earilier ones. Depending on the browser, the `stack`property may include information about the location of the function and the arguments the functions were called with.

The act of catching an error prevents it from being an unhandled error. This means your code can continue. However, should only catch errors that your understand. Should only catch errors that you understand and are prepared to deal with. Althoug a `try...catch`block is the most common structure for `error`handling, you can optional add a `finally`section to the end. The code in the `finally`block always runs. It runs after `try`block if no errors occurred, or after the `catch`block if an error was caught. It’s most commonly used as a place to put cleanup code that should run regardless of wheter your code succeeded or failed.

```js
try {
    const uri = decodeURI('http%test');
    console.log('success!');
} catch(error) {
    console.log(error);
} finally {
    console.log('The operation and any error handling is complete');
}
```

### Catching Different Types of Errors

Want to distinguish between different types of errors and handle them differently, or handle only specific types. Unlike many languages, Js does not allow you to catch errors by type. Instead, must catch all errors, and then investigate the error with the `instanceof`operator.

```js
try {
    // some code that will raise an error
} catch(error) {
    if(error instanceof RangeError) {
        // Do sth about the value being out of range
    } else if(error instanceof TypeError) {
        // Do sth about the value being the wrong type
    } else {
        throw error;
    }
}
```

JavaScript has eight error types, which are represented by different error objects, can check an error’s type to determine the kind of problem that occurred. This may indicate what actions you should take, or if you can carry out alternate code, retry an operation, or recover, it may also provide more information about the exactly what went wrong.

- `RangeError`- Occurs when a numeric value is outside of its allowed range.
- `ReferenceError`- Occurs when trying to assign a non-exiistent object to a variable.
- `SyntaxError`-- Occurs when code has a clear syntactical error, like an extra (or missing).
- `TypeError`-- Occurs when a value is not the right data type for a given operation.
- `URIError`-- Risked by problems escaping URLs with `decordRUI()`and other related functions.
- `AggregateError`-- Is a wrapper for multiple errors, which is useful for errors that occur asynchornously, an array of error objects is provided in the `errors`property.
- `EvalError`-- Meant to represent problems that occur with the built-in `eval()`.
- `InternalError`-- Occurs for a vairety of non-standard cases, andi is browser specific.

