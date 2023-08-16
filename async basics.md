## async basics

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

Since `hello_world_message`is a coroutine and pause it for 1 second with `asyncio.sleep`, now have 1 second where could be running other code concurrently.

```py
import asyncio
async def delay(delay_seconds: int) -> int:
    print(f'Sleeping for {delay_seconds} second(s)')
    await asyncio.sleep(delay_seconds)
    print...
    return delay_seconds
```

Just create a module that import in the remainder. just when needed -- 

`from util.delay_functions import delay` #` __init__.py`file

### Running concurrently with tasks

Tasks are wrappers around a coroutine that schedule a coroutine to run on the event loop as soon as possible. This scheduling and execution happen in a non-blocking fashion, meaning that, once create a task, can execute other code instantly while the task is running. This contrasts with using the `await`keyword that acts in a blocking manner, meaning we pause the entire coroutine until the result of the `await`expression comes back.

The fact that can create tasks and schedule them to run instantly on the event loop means can execute multiple tasks at roughly the same time.

### The basics of creating tasks

Creating a task is achieved by using the `asyncio.create_task`function, when call this func, give it a coroutine to run, and it just returns a task object instantly, once we have a task obj, can put it in an `await`expression that will extract the return value once it complete.

```py
import asyncio
import nest_asyncio
nest_asyncio.apply()

from util import delay


async def main():
    sleep_for_three = asyncio.create_task(delay(3))
    print(type(sleep_for_three))
    result = await sleep_for_three
    print(result)


asyncio.run(main())
```

In the preceding, create a task that require 3 seconds to complete. aslo just print out the type of the task-- One to note is that our `print`statement is executed immediately after run the task -- if had simply used await on the delay coroutine we could have waited 3 seconds before outputting the message.

Once, printed our message, apply an `await`expression to the task. Will suspend `main`until have a result from our task. And it is just important to know that we should usually use an `await`keyword on our tasks at some point in app. If didn't, our task would be scheudled to run -- but would almost immediately be stopped and cleaned up when `asyncio.run()`just shut down the event loop. And using `await`on the tasks in app also has implications for how exceptions are handled.

### Running multiple tasks concurrently

Given that tasks are created instantly and are scheduled to run as soon as possible, this allows us to run many long-running tasks concurrently -- can do this by sequentially starting multiple tasks with our long-running coroutine.

Executing these long-running operations concurrently is where asyncio really shines and delivers drastic improvements in our app's performance, but the benefits don't stop. like:

```py
import asyncio
from util import delay


async def hello_every_second():
    for i in range(2):
        await asyncio.sleep(1)
        print("I'm running other code while waiting")


async def main():
    first_delay = asyncio.create_task(delay(3))
    second_delay = asyncio.create_task(delay(3))
    await hello_every_second()
    await first_delay
    await second_delay


asyncio.run(main())
```

In the preceding, create two tasks, each of which just take 3 seconds to complete -- while these tasks are waiting, our app is idle, which gives us the opportunity to run other code. First, start two tasks that sleep for 3 s, then while our two tasks are idel, start to see -- being printed every second. This means that even when are running time-intensive operations, our app can still be performing other tasks.

### Canceling tasks and setting timeouts

When making one of network requests, need to be careful that we don't wait indefinitiely-- Doing so could lead to our app hanging -- if also lead to a experience.

### Canceling tasks

Canceling a task is -- each task object has a method just named `cancel`, whcih can call whenever we'd like to stop a task, Cancelling a task will cause that task to raise a `CancelledError`when `await`it -- which we can then handle as needed.

```py
from asyncio import CancelledError


async def main():
    long_task = asyncio.create_task(delay(10))
    second_elapsed = 0
    while not long_task.done():
        print('Task not finished, checking again')
        await asyncio.sleep(1)
        second_elapsed += 1
        if second_elapsed == 5:
            long_task.cancel()

    try:
        await long_task
    except CancelledError:
        print('our tasks was just cancelled')


asyncio.run(main())
```

Just note the `done`method on the task returns `True`if a task is finished and `False`otherwise. Every second, check to see if the task has finished, keeping track of how many seconds we've checked so far.

Something important to note -- `CancelledError`can only be thrown from an `await` statement -- this means that if we call cancel on a tak when it is executing plain Py code, that code will run until completion until we hit the next await statement.

### Setting a timeout and canceling with `wait_for`

Checking every second or at some other time interval, and then canceling a task -- as we did in the previous example just esn't the eaiest way to handle a timeout. Ideally, have a helper function that would allow us to specify this timeout and handle cancellation for us.

`asyncio`provides this functionality through a function called `asyncio.wait_for`. This function takes in a coroutine or task object, and a timeout specified in seconds. Then returns a corotuine that can `await`. If the task takes more time to complete than the timeout we give, A `TimeoutException`will be raised -- once have reached the timeout threshold, the task will automatically be cancelled. Like:

```py
import asyncio


async def main():
    delay_task = asyncio.create_task(delay(2))
    try:
        result = await asyncio.wait_for(delay_task, timeout=1)
        print(result)
    except asyncio.exceptions.TimeoutError:
        print('Got a timeout!')
        print(f'Was the task cancelled {delay_task.cancelled()}')


asyncio.run(main())
```

After second, `wait_for`statement will raise a `TimeoutError`whcih we then handle -- then see that our original `delay`task was canceled. Cancelling tasks automatically if they take longer than expected is normally a good idea. Otherwise, may have a coroutine waiting indefinitely, taking up resources that may never be released.

However, may want to inform a user that something is taking longer than just expected after a certain amount of time but not cancel the task when the timeout is exceeded. Can wrap our task with the `asyncio.shield`function -- will prevent cancellation of the coroutine, which cancellation requests then ignore.

```py
async def main():
    delay_task = asyncio.create_task(delay(10))
    try:
        result = await asyncio.wait_for(asyncio.shield(delay_task), timeout=5)
        print(result)
    except asyncio.exceptions.TimeoutError:
        print('task took longer than 5 seconds')
        result = await delay_task
        print(result)
```

This differs from our first cancellation example cuz need to access that task in the `except`block -- if had passed in a coroutine, `wait_for`would have wrapped it in a task, but wouldn't be able to reference it, as it is internal to the function. Inside a `try`, call the `wait_for`and wrap the task in `shield`, which will prevent the task from being canceled.

Cancellation and shiedling are somewhat tricky with several cases that are notworthy.

### Tasks, Coroutines, futures, and awaitables

Coroutines and tasks can both be used in `await`expressions -- so, what is the common threawd between -- need to know about a `future`as well as an `awaitable`

### futures-- 

`future`is a py object that contains a single value that you expect get at some point in the future but may not yet have. Usually, when create a future, it does not have any value it wraps around cuz it doesn't yet exist. In this state, it is considered **incomplet**, unresolved, or simply not done -- Then once get a result, U can set the value of the `future`, this will complete the `future`, can consider it just finished and extract the result from the `future`. like:

```py
from asyncio import Future

my_furatur= Future()
print(f'Is done? {my_furatur.done()}')
my_furatur.set_result(42)
print(f'Is doen? {my_furatur.done()}')
print(f'what is the result of {my_furatur.result()}')
```

Futures can also be used in `await`expression, if we `awat`a `future`, saying Psuse until the `future`has a value st i can work with. To understand that -- consider an example of making a web request that returns a `future`. Making a request that returns a `future`should complete instantly.

```py
from asyncio import Future
import asyncio


def make_request() -> Future:
    future = Future()
    asyncio.create_task(set_future_value(future))
    return future

async def set_future_value(future: Future) -> None:
    await asyncio.sleep(1)
    future.set_result(42)


async def main():
    future = make_request()
    print(f'Is the future deon? {future.done()}')
    value = await future
    print(f'Is the future done? {future.done()}')
    print(value)


asyncio.run(main())
```

In this, define a fucntion `make_request`-- in that func we create a `future`and create a `task`that will async set the result of the `future`aafter 1 second. Then in the main, call `make_request`, when call this, just get a `future`with no result. And in the asyncio, just should rarely need to deal with futures.

### The relatinship between futures, tasks and coroutines

There is a strong relationship between tasks and futures -- `task`directly inherits from `future`-- a `future`can be thought as a combination of both a coroutine and a `future`. When create a `task`, just creating an empty `future`and running the coroutine. Then when the coroutine has completed with either an exception or a result, set the result or exception of the `future`. A common thread between these is the `Awaitable`abc -- this defines one abs double `__await__`, won't going to define -- but, anything that implements the `__await__`method can be used in an `await`expression. Coroutines inherit directly from `awaitable`.

Start to refer to objects that can be used in await expresions as *awaitables*.

## Indexing with Slices

Like 1d objects such as Python lists, ndarrays can be sliced with the `arr[1:6]`.. and consider the 2d array from before, `arr2d`slicing this array is a bit different -- 

```py
arr2d[:2]
Out[4]: 
array([[1, 2, 3],
       [4, 5, 6]])

arr2d[:2, 1:]
Out[5]: 
array([[2, 3],
       [5, 6]])
```

When slicing like this, U always obtain array views of same number of dimensions. 

`lower_dim_slice=arr2d[1, :2]` here whie `arr2d`is 2d, but `lower_dim_slice`is 1d. Similary, Can select the 3rd column but only the first two rows like: `arr2d[:2, 2]`

### Boolean Indexing

Consider an example where we have some data in an array and an array of names with duplicates -- like:

```py
names= np.array(['Bob', 'Joe', 'Will', 'Bob', 'Will', 'Joe', 'Joe'])

data = np.array([[4, 7], [0, 2], [-5, 6], [0, 0], [1, 2],
[-12, -4], [3, 4]])

names=='Bob'
Out[12]: array([ True, False, False,  True, False, False, False])

data[names=='Bob']
Out[13]: 
array([[4, 7],
       [0, 0]])
```

Suppose each name just correponds to a row in the data array. `data[names=='Bob']`-- the Boolean array must be of the same length as the array axis it's indexing. Can even mix and match Boolean arrays wtih slices or integers. like:

`data[names=='Bob', 1:]` or `data[names='Bob', 1]`, just 1d. And to select but Bob can either use != or ~. like:

```py
names != "Bob"
~(names=="Bob")
data[~(name=="Bob")]
```

So the ~ operator can be useful when you want to invert a boolean array referenced by a variable. like:

```py
cond = names=='Bob'
data[~cond]
```

To select two of the three names to combine multiple Boolean conditions, use arithmetic operators like & and | like:

```py
mask = (names=='Bob') | (names=='Will')

mask
Out[16]: array([ True, False,  True,  True,  True, False, False])

data[mask]
```

Selecting data from an array by Boolean indexing and assigning the result to  new varaible *always* creates a copy of the data, even if the returned array is unchanged.

And setting values with Boolean arrays works by substituting the value or values on the righthand side into the locations where the Boolean array's values are `True`. To set all of the negative values in data to 0. just like:

`data[data<0]=0`

Can also set whole rows or columns using the one-dimenational boolean array -- 

`data[names!='Joe']=7`-- As see later, these types of operations on 2d data are convenient to do with pandas.

### Fancy Indexing

*Fancy indexing* is a term adopted by Numpy to describe indexing using integer arrays -- like: To select a subset of rows in a particular order, can simply pass a list or ndarray of integers specifying the disired order.

`arr[[4,3,0,6]]`-- this code did what you expected-- using negative indices selects rows from the end like:

`arr[[-3,-5.-7]]`-- Passing multiple index arrays does sth slightly different -- it selects a one-dimensional array of elements corresponding to each tuple of indices.

```py
arr = np.arange(32).reshape((8,4))

arr
Out[32]: 
array([[ 0,  1,  2,  3],
       [ 4,  5,  6,  7],
       [ 8,  9, 10, 11],
       [12, 13, 14, 15],
       [16, 17, 18, 19],
       [20, 21, 22, 23],
       [24, 25, 26, 27],
       [28, 29, 30, 31]])

arr[[1,5,7,2], [0,3,1,2]]
Out[33]: array([ 4, 23, 29, 10])
```

Here the elements (1,0)... were selected, the result of fancy indexing with as many integer arrays as there are axes always 1d -- the behavior of fancy indexing in this case is a bit different from what some users might have expected, which is the rectangular region formed by selecting a subset of the matrix's rows and columns.

```py
arr[[1,5,7,2]][:,[0,3,1,2]]
Out[35]: 
array([[ 4,  7,  5,  6],
       [20, 23, 21, 22],
       [28, 31, 29, 30],
       [ 8, 11,  9, 10]])
```

This form, just re-arrange the order of the column data. Keep in mind that fancy indexing, unlike slicing, always copies the data into a new array when assigning the result to a new variable. If assign values with fancy indexing, the indexed values will be modified.

`arr[[1,4,7,2], [0,3,1,2]]=0`.

## Creating the Cart Summary Components

Components are the essential building blocks for Ng applications cuz they allow discrete units of code and conetnt to be easily created. The app will show users a summary of their product selections in the title area of the page, going to implement by creating a componnet -- add called `cartSummary.component.ts`file to the `store`folder add:

```tsx
@Component({
	selector: "cart-summary",
    templateUrl: "cartSummary.component.html"
})export class CartSummaryCOmponent{
    constructor(public cart: Cart) {}
}
```

When Ng needs to create an instance of this component, will have to provide a `Cart`object as a ctor arg -- using the servce configured in the section by just adding the `Cart`class to the feture module’s `providers`property. The default behavior for services means that a single `Cart`object will be created and shared throughout the app,

```html
<div class="float-end">
    <small class="fs-6">
        Your cart:
        <span *ngIf="cart.itemCount>0">
            {{cart.itemCount}} item(s)
            {{cart.cartPrice | currency:"USD":"symbol":"2.2-2"}}
        </span>
        <span *ngIf="cart.itemCount==0">
            (Empty)
        </span>
    </small>
    <button class="btn btn-sm btn-dark text-white" [disabled]="cart.itemCount==0">
        <i class="fa fa-shopping-cart"></i>
    </button>
</div>

```

This tempalte just uses the `Cart`object provided by its component to display the number of items in the cart and the total cost. there is also a button that will start the checkout process when add it to the application.

### Intregating the Cart into the Store

The store component is just the kwy to integrating the cart widget into the application -- updates the store component so that its ctor has a `Cart`parameter and defins a method that will add a product to the cart.

```tsx
addProductToCart(product: Product) {
    this.cart.addLine(product);
}
```

To complete the integaration of the cart into the store component, just adds the element that will apply the cart summary component to the store component’s template and adds a button to each description like:

```html
<div class="bg-dark text-white p-2">
    <span class="navbar-brand ml-2">SPORTS STORE</span>
    <cart-summary></cart-summary>
</div>
```

```html
<div class="card-text bg-white p-1">
    {{product.description}}
    <button class="btn btn-success btn-sm float-end"
            (click)="addProductToCart(product)">
        Add to Cart
    </button>
</div>
```

```tsx
private recalculate() {
    this.itemCount = 0;
    this.cartPrice = 0;
    for (let l of this.lines) {
        this.itemCount += l.quantity;
        this.cartPrice += l.lineTotal;
    }
}
```

### Adding URL routing

Most app need to show different content to the user at different times -- in the case of the SS app, when the user clicks one of the Add to Cart, should be shown a detailed view of their selected products and given the chance to start the checkout proces.

Ng just supports a feature called *URL routing* -- which uses the current URL displayed by the browser to select the components that are displayed to the user. This is an approach that makes it easy to create apps whose componetns are loosely coupled and easy to change without needing corresponding modifications elsewhere in the app. URL routing also makes it wasy to change the path that a user follows through an app.

- `/store`-- display a list of products
- `/cart`/-- display user’s cart in detial
- `/checkout'`-- will display the checkout process.

### Creating the Cart detail and checkout components

Before adding URL routing to the app, first need to create the components that will be displayed by the `/cart`and `/checkout`URLs. Start by adding a `cartDetail.component.ts`in the `/store`:

```tsx
import {Component} from "@angular/core";

@Component({
    template: `<div><h3 class="bg-info p-1 text-white">
        Cart Detail Component
    </h3></div>`
})export class CartDetailComponent{}
```

Then just the `checkout.component.ts`file:

```tsx
import {Component} from "@angular/core";

@Component({
    template:`<div><h3 class="bg-info p-1 text-white">
        Checkout Component
    </h3></div>`
})export class CheckoutComponent{}
```

This components follow the same pattern.

### Creating and Applying the Routing Configuration

Now that have a range of components to display-- the next is to create just the routing configuraiont that tells Ng how to map URLs into components -- each mapping of a URL to a component is known as a URL route or a route. Goging to just follow a simpler approach and define the routes within the `@NgModule`decorator of app’s root module like:

```tsx
imports: [
    BrowserModule,
    StoreModule,
    RouterModule.forRoot([
        {path: "store", component: StoreComponent},
        {path: "cart", component: CartDetailComponent},
        {path: "checkout", component: CheckoutComponent},
        {path: "", redirectTo: "/store"}
    ])
],
```

The `RouterModule.forRoot`method is passed a set of routes, each of which maps a URL to a component. The first three routes in the listing match the URLs from ..