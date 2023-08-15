## Is the GIL ever released

Based on the previous -- if concurrency in Py can ever happen with threads, given that the GIL prevents running two lines of Py concurrently -- The GIL -- is not held forever such that we can't use multiple threads to our advantages..

The GIL is released when I/O operations happen -- this lets us employ threads to do concurrent work when it comes to I/O, but not for CPU-bound py code itself like:

```py
thread_1.start()
thread_2.start()
# ...
thread_1.join()
thread_2.join()
```

In this case, the GIL is only re-acquired when the data is translated back into a py object. Then at the os level, the I/O operations execute concurrently.

### asyncio and the GIL

`asyncio`exploits the fact that I/O operations release the GIL to give concurrency, even with only one thread. When utilize async create objects called *coroutines* -- A coroutine can be thought as executing a lightweight thread. Much like we can have multiple threads running at the same time, each with their own concurrent I/O operation, can have many coroutines running alongside one another. It is important to note that asyncio does not circumvent the GIL.

### How single-threaded concurrency works

Don't need multiple threads to achieve this kind of concurrency -- do it all within the confines of one process and one thread. Do this by exploiting the fact -- I/O operations can be completed concurrently.

A *socket* is low-level for sending and receiving data over a network. Supports two main operations -- sending bytes and receiving bytes. 

Just note that sockets are just *blocking* by default, this means that when are waiting for a server to reply wtih data, halt our app or *block* it until get data to read. In non-blocking mode, when writes to a socket can just fire and forget the write or read, and our app can go on to perform other tasks. Later, can have the os tell us that we received bytes and deal it at that time. This lets app do any number of things while wait for bytes to come back to us.

In the background, performed by a few different event notification systems -- depending on which Os we are running. Asyncio is abstracted enough that it switches between the different notification systems.

FORE , **IOCP** on Windows -- keep track of our non-blocking sockets and notify us when they are just ready for us to do sth with them.

### How an event loop works

Note that an event loop is at the heart of every asyncio applicaiton -- *event loops* are a farily common design pattern in many systems and have existed for quite some time. If ever used Js in a browser to make an async web request -- you have created a task on an event loop. For GUI, used that called **messages loop**.

The most basic is simple -- create  a queue that just holds list of events or messages, then loop forever, processing messages one at a time as they come into the queue. just like this in py:

```py
from collections import deque
messages= deque()
while True:
    if messages:
        message=messages.pop()
        process_message(message)
```

In the asyncio, the event loop keeps a queue of tasks instead of messages. Tasks are wrappers around a coroutine - A coroutine can pause execution when it hits an I/O-bound operation and will *let the event loop run other tasks* that are not waiting for I/O operation complete.

When create an event loop, create an empty queue of tasks, can then add tasks into the queue to be run -- each iteration of the event loop checks for tasks that need to be run and will run them one at a time until a task hits an I/O operation. At that time the task will be paused -- and instruct our Os to watch any sockets for I/O to complete. On every iteration of the event loop, check to see if any of our I/O has completed -- if has, wake up any tasks that were paused and let them finishing running.

### Introducing coroutines

Like a regular Py function but with the superpower that it can pause its execution when it encounters an opeation that could take a while to complete -- when that long-running operation is complete, can "wake up" our paused coroutine and finish executing any other ocde in that coroutine. While a paused coroutine is waiting for opreation it paused for to fhinsh, can run other code. This running of other code while waiting is what gives our app concurrency. Can also run several time-consuming operations concurrently, whcih can give app big performance improvements.

To both create and pause a coroutine, need to learn to use Py's `async`and `await`keywrods -- the `async`keyword will let use define a coroutine, the `await`will let pause our coroutine when have a long-running operations.

### Creating with `aysnc`

Creating is straightforward and not much different from creating a normal Py function. The only difference is that, instead of using the `def`just use `async def` like:

```py
async def my_coroutine() -> None:
    print(...)
```

Can creating something very different from a plain py function -- to illustrate this, create a function that adds one to an integer as well as a coroutine that does the same and compare the results of calling each.

```py
async def coroutine_add_one(number: int) -> int:
    return number + 1


def add_one(number: int) -> int:
    return number + 1


function_result = add_one(1)
coro_result = coroutine_add_one(1)
type(coro_result)  # coroutine
```

This is just an important point -- as coroutines aren't executed when we call them dierctly, instead, create a coroutine object that can be run later. To run a coroutine, need to explicitly run it on an event loop. In version of 3.7-, had to create an event loop if one did not already exist -- however, the asyncio library has added several functions that abstract the event loop management. fore `asyncio.run`, can just use that to run the corotuine like:

```py
import asyncio
import nest_asyncio
nest_asyncio.apply()

async def coroutine_add_one(number: int) -> int:
    return number + 1

asyncio.run(coroutine_add_one(2))
```

`asyncio.run`is doing a few important things in this scenario -- 

1. creates a brand-new event, once it successuflly does so, takes whichever corotuine we pass into it and runs it until it completes -- returning the result -- this function will also do some *cleanup of anything that might be left running after the main coroutine finishes*. Once everything has completed, it shuts down and closes the event loop.
2. it is intended to be the main entry point into the async app have created. -- only executes one coroutine, and that corotuine should launch all other aspects of our app. As progress further, use this function as the entry point into nealy all our applications. The coroutine that `asyncio.run`executes will create and run other coroutines that will allow us to utilize the concurrent nature of `asyncio`.

### Pausing execution with the `await`keyword

The real benefit of `asyncio`is being able to pause execution to let the event loop run other tasks during a long-running operation. To pause, use the await, and is usually followed by a call to a coroutine. -- Unlike calling a coroutine directly, which produces a `coroutine`object, the `await`will also pause the coroutine where it is contained in until the coroutine we awaited finishes and returns a result.

Can use the `await`keyword by putting it in front of a coroutine call, expanding on our eariler, can write a program where call the `add_one`inside a main async like:

```py
import asyncio
async def add_one(number: int) -> int:
    return number + 1

async def main() -> None:
    one_plus_one= await add_one(1)
    
    #...
asyncio.run(main())
```

Once have the result, the main function will be *unpaused*, and we will assign the return value from `add_one(1)`to the variable `one_plus_one`..

### long-running corotuiens with sleep

Do this using the `asyncio.sleep()`function -- can use `asyncio.sleep`to make a coroutine *sleep* for a given number of seconds -- this will pause our corotuine for the time we give it, simlulating what would happen if had a long-running call to a dbs or web API.

`asyncio.sleep`is itself a coroutine, so must use it with the `await`, if call it just by itself, just get a coroutine object, since is a coroutine, this means that when a coroutine awaits it, other colde will be able to run.

```py
import asyncio

async def hello_world_message() -> str:
    await asyncio.sleep(1)
    return ...
async def main() -> None:
    message = await hello_world_message()
    print(message)
    
asyncio.run(main())
```

```py
import asyncio


async def delay(delay_seconds:int) -> int:
    print(f'sleeping for {delay_seconds} second(s)')
    await asyncio.sleep(delay_seconds)
    print(f'finished sleeping for {delay_seconds} second(s)')
    return delay_seconds

# then in the `__init__.py` file add:
from util.delay_functions import delay
```

```py
import asyncio
from util import delay


async def add_one(number: int) -> int:
    return number + 1


async def Hello_world_message() -> str:
    await delay(1)
    return 'hello world'


async def main() -> None:
    message = await Hello_world_message()
    one_plus_one = await add_one(1)
    print(one_plus_one)
    print(message)


asyncio.run(main())
```

When run this, 1 second pases before the results of both function calls are printed -- what we really want is the value of `add_one(1)`.

## Arrays and Vectorized Computation

Numpy --

- ndarray, an efficient multidimensional array, just providing fast array-oriented arithmetic operations and flexible broadcsting capabilities.
- Mathematcial functions for fast operations on entire arrays of data wihtout having to write loops
- Tools for reading/writing array data to disk and working with memory-mapped files.
- Linear algebra, random nubmer generation, and Fourier transform
- A C API connecting NumPy with libraries.

For most deta analisys apps, the main areas of functionlity will focus on are:

- Fast array-based operations for data munging and cleaning, subsetting and filtering, transformatin, and any other kind of computation
- Common array algorithms like sorting, unique, and set operations
- Efficient descriptive statisitc and aggregating/summarizing data.
- Data alignment and relational data manipulations for merging and joining heterogeneous datasets.

### A multidimensional Array object

One of the key features of Numpy is its N-D array object, or ndarray, which is a fast, flexible container for large dataset in Py, enable you to perform mathematical operations on whole blocks of data using similar syntax to the equivalent operations between scalar elements.

```py
data= np.array([[1.5, -0.1, 3],[0, 3, 6.5]])

data
Out[12]: 
array([[ 1.5, -0.1,  3. ],
       [ 0. ,  3. ,  6.5]])

data*10
Out[13]: 
array([[15., -1., 30.],
       [ 0., 30., 65.]])

data + data
Out[14]: 
array([[ 3. , -0.2,  6. ],
       [ 0. ,  6. , 13. ]])
```

An ndarray is a generic multidimensional container for homogeneous data -- that is all of the elements must be the same type -- every array has a `shape`, a **tuple** that indicating the size of each dimension, and a `dtype`which is an object describingt the *data type* of the array like:

### Creating ndarrays

The easiest to create is to use the `array`-- this accepts any seq-like object and produces a new Numpy array, contaiing the passed data. fore, a list is a good candidate for conversion -- fore, the data2 is a list of lists. 2d -- with shape inferred from the data - can confirm this by inspecting the `ndim`and `shape`attribute like:

Unless explicit specified, `np.array`tries to infer a tood data type for the array that it creates. the data type is stored in a special `dtype`metadata object, fore:

`arr1.dtype; arr2.dype`

In additoin to `numpy.array`, there are a number of other functions for creating new arrays. like `np.zeros np.ones`and `np.empty`creates an array without initilaizing its values to any particular value. To create a higher array with these, like:

`np.zeros(10)`, np.zeros((3,6)) # to create  higher dimensional array, pass a tuple just. And like: `np.empty((2,3,2))`And `np.arange`is an array-valued version of the built-in py `range`function.

- `asarray`-- convert input to ndarray, but not copy if the inputs is already an ndarray
- `ones_like`-- produces a `ones`of the saame shape and data type
- `full_like`-- takes another array and produces a filed array of the same shape and data type.

### Data Types for ndarrays

The *data type* or `dtype`is a special object containing the info the ndarray needs to interpret a chunk of memory as a particular type of data. like:

```py
arr1 = np.array([1,2,3], dtype=np.float64)
arr2 = np.array([1,2,3], dtype=np.int32)
```

And, data types are a source of Np's flexibility for interacting with data coming from other system.

- `bool`-- boolean type storing `True`..
- `object`-- py object type, a value can be any py object.
- `string_` -- `S`-- Fixed-length ASCII string type
- `unicode_`- `U`-- Fixed unicode type.

Can just explicitly convert or *cast* an array from one data type to another using ndarray's `astype`method:

```py
numeric_strings = np.array(["1.25", "-9.6", "42"], dtype=np.string_)

numeric_strings.astype(float)
Out[37]: array([ 1.25, -9.6 , 42.  ])
```

If casting were to fail for some reason, a `ValueError`will be raised, just wrote the `float`instead of `np.float64`-- Numpy aliases the Py types to its own equivalent data types.

### Arithmetic with Np arrays

Arrays are important cuz they enable you to express batch operations on data without writing any `for`-- *vectorization* -- any arithmetic operations between equal-sized arrays apply the operation element-wise.

Evaluating operations between differently sized array is called *broadcasting* and will be discussed in more details.

### Basic Indexing and Slicing

Numpy array indexing is a deep topic, as there are many ways you may want to select a subset of your data or individual elements -- 1d arrays are simple 

`arr[5:8]`, `arr[5:8]=12` Can see, if assign like this, in arr[5:8]=12 the value is propagated to the entire selection. 

NOTE -- an important first distinction from py's built-in lists is that array slices are views on the original array. And with higher dimensional, have many more options, ain a 2d array, the elements at each index are no longer scalars but rather one-dimensional arrays. fore:

```py
arr2d= np.arange(1,10).reshape((3,3))

arr2d
Out[57]: 
array([[1, 2, 3],
       [4, 5, 6],
       [7, 8, 9]])

arr2d[2]
Out[58]: array([7, 8, 9])

arr2d[0][2]
Out[59]: 3

arr2d[0,2]
Out[60]: 3
arr3d= np.arange(1,13).reshape((2,2,3))

arr3d
Out[66]: 
array([[[ 1,  2,  3],
        [ 4,  5,  6]],

       [[ 7,  8,  9],
        [10, 11, 12]]])

arr3d[0]
Out[67]: 
array([[1, 2, 3],
       [4, 5, 6]])

arr3d[0][1]
Out[68]: array([4, 5, 6])
```

Both scalar values and arrays can be asigned to the `arr3d[0]` like:

`old_values= arr3d[0].copy()`

`arr3d[0]=42; arr3d[0]=old_values`

### Indexing with slices

Can pass multiple slice just like you can pass multiple indexs:

`arr2d[:2, 1:]` When slicing like this, you always obtain array views of the same number of dimensions.

`lower_dim_slice= arr2d[1, :2]` `lower_dim_slice.shape`-- (2,) here, while the `arr2d`is 2d, lower_dim_slice is one-dimensional, and its shape is a tuple with one axis size.

Similarly, can select the 3rd column but only the first two rows like:

`arr2d[:2,2], array[3,6]`

And assigning to a slice expresion assigns just to the whole selection like:

```py
arr2d[:2, 1:]=0
arr2d
```

## Adding Category Selection

Adding support for filtering the list of products by category requires preparing the store component so that it keep tracks of which category the user wants to display and requests changing the way that data is retreived to use that.

```tsx
export class StoreComponent {
    selectedCategory: string | undefined;
    constructor(private repository: ProductRepository){}
    get products(): Product[] {
        return this.repository.getProducts(this.selectedCategory);
    }
    changeCategory(newCategory?: string){
        this.selectedCategory= newCategory;
    }
}
```

The changes are simple cuz they build on the foundation that took so long to create the start of the .. The `selectedCategory`prop is assigned the user’s choice of category and used in the `updateData`method.

```html
<div class="col-3 p2">
    <div class="d-grid gap-2">
        <button class="btn btn-outline-primary" (click)="changeCategory()">
            Home
        </button>
        <button *ngFor="let cat of categories" class="btn btn-outline-primary"
                [class.active]="cat==selectedCategory"
                (click)="changeCategory(cat)">
            {{cat}}
        </button>
    </div>
</div>
```

There are two new `button`elements in the template -- first is a `Home`which has an event binding that invokes the component’s `changeCategory`method when the button is clicked. The `ngFor`just applied to the other `button`element, with an expression that will repeat the element for each value in the array returned byt the component’s `categories`prop.

### Adding Product Pagination

Filtering the products by category has helped -- but more typical approach is to break the list into smaller sections and present each of them as a page, along with navigation buttons that move between the pages.

```tsx
et products(): Product[] {
    let pageIndex = (this.selectedPage - 1) * this.productsPerPage;
    return this.repository.getProducts(this.selectedCategory)
        .slice(pageIndex, pageIndex + this.productsPerPage);
}

changePage(newPage: number) {
    this.selectedPage = newPage;
}

changePageSize(newSize: number) {
    this.productsPerPage = Number(newSize);
    this.changePage(1);
}

getPageNumbers(): number[] {
    return Array(Math.ceil(this.repository.getProducts(this.selectedCategory).length / this.productsPerPage))
        .fill(0).map((x, i) => i + 1);
}
```

`fill(0).map((x,i)=>i+1)` this statement creates a new array, fills it with the 0 and then use the `map`to gnerate a new aray with the number sequence. this works well enough to implement the pagination feaures.

```html
<div class="d-inline float-start mr-1">
    <select class="form-control" [value]="productsPerPage"
            (change)="changePageSize($any($event).target.value)">
        <option vlaue="3">3 per</option>
        <option value="4">4 per</option>
        <option value="6">6 per</option>
        <option value="8">8 per</option>
    </select>
</div>

<div class="btn-group float-end">
    <button *ngFor="let page of pageNumbers" (click)="changePage(page)"
            class="btn btn-outline-primary" [class.active]="page==selectedPage">
        {{page}}
    </button>
</div>
```

The new elements add a `select`allows the szie of the page to be changed and a set of buttons that nav through the product pages. The enw elements have data bindings to write them up to the properteis and methods provided by the component.

### Creating a Custom Directive

In this, going to create a custom directive so don’t have to generate an array full of numbers to create the page nav buttons -- angular proides a good range of built-in directives -- but it is a simple process to create your own directives to solve problems that are specific to you app or to support features that the built-in directives don’t have.

```tsx
@Directive({
    selector: "[counterOf]"
})
export class CounterDirective {
    constructor(private container: ViewContainerRef,
                private template: TemplateRef<Object>) {
    }

    @Input("counterOf")
    counter: number = 0;

    ngOnChanges(changes: SimpleChanges) {
        this.container.clear();
        for (let i = 0; i < this.counter; i++) {
            this.container.createEmbeddedView(this.template,
                new CounterDirectiveContext(i + 1));
        }
    }
}

class CounterDirectiveContext {
    constructor(public $implicit: any) {
    }
}
```

This is just an example of a structural directive, which is -- this just applied to elements through a `counter`prop and relies on special feaures that Ng provides for creating content repeatedly.

And to use this, just added to the modules’ `declarations`section like:

`declarations: [StoreComponent, CounterDirective]`

```tsx
get pageCount(): number {
    return Math.ceil(this.repository
                     .getProducts(this.selectedCategory).length / this.productsPerPage);
}
```

```html
<div class="btn-group float-end">
    <button *counter="let page of pageCount" (click)="changePage(page)"
            class="btn btn-outline-primary" [class.active]="page==selectedPage">
        {{page}}
    </button>
</div>
```

## Orders and Checkout

Just adding features to app that created -- add support for a shopping cart and checkout processes and replace the dummy data with the dat from the RESTful web service.

### Creating a Cart

The users need a cart into which products can be placed and used to start the checkout process. in the section, add a cart to the appliation and integrate it into the store sot that the user can select the products they want.

```tsx
import {Injectable} from "@angular/core";
import {Product} from "./product.model";

@Injectable()
export class Cart {
    public lines: CartLine[] = [];
    public itemCount: number = 0;
    public cartPrice: number = 0;

    addLine(product: Product, quantity: number = 1) {
        let line = this.lines.find(line =>
            line.product.id == product.id);
        if (line) {
            line.quantity += quantity;
        } else {
            this.lines.push(new CartLine(product, quantity));
        }
        this.recalculate();
    }

    private recalculate() {
        this.itemCount = 0;
        this.cartPrice = 0;
    }

    updateQuantity(product: Product, quantity: number) {
        let line = this.lines.find(line =>
            line.product.id == product.id);
        if (line)
            line.quantity = Number(quantity);
        this.recalculate();
    }

    removeLine(id: number) {
        let index = this.lines.findIndex(line => line.product.id = id);
        this.lines.splice(index, 1);
        this.recalculate();
    }

    clear() {
        this.lines = [];
        this.itemCount = 0;
        this.cartPrice = 0;
    }
}

export class CartLine {
    constructor(public product: Product,
                public quantity: number) {
    }

    get lineTotal() {
        return this.quantity * (this.product.price ?? 0);
    }
}

```

For this, individual product selections are represented as an array of `CartLine`objects, each of which contains a `Product`object and a quantity. the `Cart`class just keeps trak of the total numbers of items that have been selected and their total cost.

There should be a single `Cart`object used throughout the entire app -- ensuring that any part of the application can just acces the user’s product selections -- To achieve, going to make the `Cart`a service, which means that Angular will take responsibility for creating an instance of the `Cart`class and will use it needs to create a component that has a `Cart`constructor argument -- this is another use of the Ng DI feature, whcih can be used to share objects throughout an app and which is described. The `@Injectable()`decorator, which has een applied to the `Cart`class.

Then need, to registers the `Cart`class as a service in the providers property of the model feature model class like: Will use it when it needs to create a component that has a `Cart`constuctor argument. In the Module.model.ts file:

### Creating the Cart Summary Components

Components are the essential building blocks for Angualr applications cuz they allow discrete units of code and content to be easily created -- the app will show users a summary of theri product selections in the title area of the page.

```tsx
@Component({
    selector: "cart-summary",
    templateUrl: "cartSummary.component.html"
})
export class CartSummaryComponent {
    constructor(public cart: Cart) {
    }
}
```

When Ng needs to create an instance of this component, will have to provide a `Cart`object as a ctor argument, using the service configured in the section by adding the `Cart`class to the feature module’s `providers`prop. This default behavior for service means that single `Cart`object will be created and shared throughout the application, although there are different service behaviors available.

