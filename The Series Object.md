## The Series Object -- rec

One of the pandas' core data structures, the `Series`is 1d labeled array for *homogenoeous* data -- An *array* is an ordered collection of values comparable to a python list -- The term *homogeneous* means that the values are of the same data type -- Pandas assigns each `Sereis`value a *label* -- an identifier we can just use to locate the value. The orders starts counting from 0 and the first `Series`value occupies position 0.

And a `Series`combines and expands the best featurs of Py's native data structure -- like a list, it hods its value in a sequenced order -- assigns a k/lable to each value.

### Overviews of series

And a ctor is a method that builds an object from a class, when wrote `pd.Series()`used the `Series`ctor to create a new `Series`object -- When create an obj, often want to define its starting state -- can think of an object's starting state as being its initial configuration - settings -- can often set state by passing args.

The first arg to is an iterable object whose values will populate the `Series`. Can just pass various inputs, including lists, dicts, tuples, and Numpy ndarrays. And the `Series`ctor defines 6 parameters -- data, index, dtype, name , copy, and fastpath.

One additional advantge of keyword arg is that they permit us to pass parameters in any order -- seq/pos args require us to pass arguments in the order in which the ctor expects them. like:

`pd.Series(index=days_of_week, data= ice_cream_flavors)` like:

```py
bunch_of_bools = [True, False, True]
stock_prices = [985.32, 950.44]
time_of_day = ["open", "close"]
pd.Series(stock_prices, time_of_day)
lucky_numbers = [4, 8, 15, 16, 23, 42]
pd.Series(lucky_numbers)
```

And just note that `float64`and `int64`data type indites that each floating/integer value in the `Series`occupies 64 bits of your computer's ram.

Pandas can force coercion to a different type via the ctor's `dtype`parameter -- the next example passes an integer list to the ctor but asks for a flaoting-point `Series`like:

`pd.Series(lucky_numbers, dtype="float")`

### With missing values

When pandas sees a missing value durting a file import, the library substitutes Numpy's `nan`object, the `nan`is short for *not a number* and is a catch-all term for the undefined value. like:

```py
tempatures = [94,88,np.nan, 91]
pd.Series(data=tempatures)
```

### Creating from Py object

The `Series`ctor's `data`parameter accept various inputs, including just Py data structures and objects from other libraries. fore, one dict:

```py
cal_info = dict(
    Cereal=125,
    Chocolate=405,
    Ice=342
)
pd.Series(cal_info)
```

And a `tuple`is an immutable, can also pass a tuple. And to create a `Series`stroes tuples, wrap the tuple in a list:

`pd.Series([(120,41), (196, 165)])`

And a `set`can be also used, but if pass a set to the `Series`ctor, pandas raises a `TypeError`exception -- A set has neigher the concept of order nor the concept of associateion. just:

`pd.Series(list(my_set))`

and aslo accepts a Numpy `ndarray`object -- many data science lib uses Numpy arrays -- which are common storage formats for moving data around. Just like:

`pd.Series(np.random.randint(1,101,10))`

### Series attributes

An *attribute* is a piece of data belonging to an object, Attributes revel information about the object's internal state. An attribute's value may be another object.

A `Series`is composed of several smaller objects. Think of thse objects as being puzzle pieces that join to make a greater whole. And uses the Numpy lib's `ndarray`object to store the counts and the pandas library to store the index. Can access these nested objects through `Sereis`attributes. The `values`fore, exposes the `ndarray`object that stores the values. like `diet.values`

Pandas delegates the reponsibility of storing `Series`values to an object from a different library. That is why Numpy is dependency of pandas -- the `ndarray`just optimizes for speed and efficiency.

Also, has its own objects, fore, `index` -- `Index`object are built into pands like:

```py
type(diet.index)
pandas.core.indexes.base.Index

# helpeful detail about the obj
diet.dtype
diet.size
diet.shape # (3, )

# is_unique returns False if sereis contains duplicates
pd.Series(data=[3,3]).is_unique # False
```

### Mathmetical Operations

A `Series`object includes plenty of statistical and mathenmatical methods -- like:

```py
number = pd.Series([1,2,3,np.nan,4,5])
print(number.count(), number.sum(), number.sum(skipna=False))
```

The `sum`method -- if `skipna`is `False`, then returns `nan`. And also has a `min_count`paramter sets the minimum number of valid values a `Series`must hold for pandas to calcuate it sum -- like:

`numbers.sum(min_count=3)`

If `numbers.sum(min_count=6)`then return `nan`.

And also a `product()`method -- and the `cumsum`method returns a new `Series`with a rolling sum of values -- Each index position holds the sum of values up to and including the value at that index.

`number.cumsum()`.. If also pass the `skipna`arg of `False`, then the `Series`will list the cumulative sum up to the index with the first missing value and then `NaN`for the remaining values like:

`numbers.cumsum(skipna=False)`

And the `pct_change`-- means *percent change* method returns the percentage difference from one `Series`value to the next. At each index, pandas adds the last index's vlaue and the current index's value and then divides the sum.

And the `fill_method`customizes the protocol.

And the `mean`returns average of the value -- `number.mean()`, and the `median`returns the middle number in a sorted `Series`of values. `number.median()`-- and `std()`returns the std deviation. And Pandas just sorts a string `Series`alphabetically., and the `describe`method returns a `Series`of statistical evaluations.

The `sample`method selects a random assortment of values from the `Series`, it is possible for the order of values to differ from the new `Series`and the original `Series` -- `number.sample(3)`.

The `unique`returns a Numpy ndarray of unique values from the `Series`. like:

```py
authors = pd.Series(
    ['Hemingway', 'Orwell', 'Dostoevsky', 'Fitzgerald', 'Orwell']
)
authors.unique(), authors.nunique()
```

The complementary `nunique`method returns the number of unique value in the Series like:

`authors.nunique()`.

### Arithmetic Operations

Pandas just gives additional ways to perform arithmetic calcualations with a Series. like: +, -.. If you preer to a method-based approach, and the `add`achieves the same result like: like:

`s1-5, s1.sub(5), s1.subtract(5)`

### Broadcasting

The np uses the term *broadcasting* to describe the derivation of one array of values from another. Note that broadcasting also describe mathmethical operations between multiple `Series`objects.

```py
s1= pd.Series([1,2,3], index=[*'ABC'])
s2= pd.Series([4,5,6], index=[*'ABC'])

s1+s2
```

Here is another example of how pandas uses shared index label to align data like:

```py
s1 = pd.Series(data=[3, 6, np.nan, 12])
s2 = pd.Series(data=[2, 6, np.nan, 12])
print(s1 == s2)
print(s1.eq(s2))
```

```py
s1= pd.Series([5,10,15], [*'ABC'])
s2= pd.Series([4,8,12,14], [*'BCDE'])
s1+ s2
```

### Passing the Series to Py's built-in functions

Py's developer community likes to rally around certain design principles to ensure just consistency across codebases.

```py
type(cities)
dir(cities)
list(cities) 
```

Can also pass to py's `dict`fuction to create a dict. Note that the `Series`'s index labels and values are keys and values. And in py, use the `in`keyword to check for inclusion, in pandas, can use the `in`keyword to check whether a given value exists in the Series' *index*.

Also, to check for inclusion among the Series' values, can pair the `in`keyword in the values attribute like:

`"las vaegas" in cities.values`

## Async Context Managers

Async context managers are classes that just implements two special coroutine methods : `__aenter__`which async acquires a resource and `__aexit__`, which closes the rsource. To fully understand that like:

```py
@async_timed()
async def fetch_status(session: ClientSession, url: str) -> int:
    ayync with session.get(url) as result:
        return result.status
    
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = '...com'
        status = await fetch_status(session,url)
        print(f'state for {url} was {status}')
```

In the preceding listing, first created a client session in `async with`block with `aiohttp.ClientSession()`, once we have a client session, free to make any web request described. In this function have another `async with`block and use the session to run `GET HTTP`request against the URL.

Note that a `ClientSession`will create a default maximum of 100 connections by default, providing an implicit upper limit to the number of concurrent requests we can make.

### Setting the timeouts with aiohttp

By default, aiohttp has a timeout of 5 mins. Can specify `timeouts`using the `ClientTimeout`data structure like:

```py
async def fetch_status(session: ClientSession, url: str) -> int: 
    ten_mills = aiohttp.ClientTimeout(total=.01)
    async with session.get(url, timeout=ten_missils) as result:
        return result.status
    
async def main():
    session_timeout= aiohttp.ClientTimeout(total=1, connect=.1)
    async with aiohttp.ClientSession(timeout= session_timeout) as session:
        await fetch_status(session, ...)
        
```

### Running tasks concurrently

May be tempted to utilize a `for`loop for a list comprehension to make this a little smoother, as demonstrated:

```py
@async_timed()
async def main()-> None:
    delay_times = [3,3,3]
    [await asyncio.create_task(delay(seconds)) for seconds in delay_times]
```

The problem is subtle -- occurs cuz use `await`as soon as we just create the task -- this just means that we pause the exeuction and the main coroutine for every `delay`task, create until that delay task completes. like:

```py
@async_timed()
async def main() -> None:
    delay_times= [3,3,3]
    tasks = [asyncio.create_task(delay(seconds)) for seconds in delay_times]
    [await task for task in tasks]
```

While drawbacks remain -- first is that this consists of multiple lines of code, where must explicitly remember to separate out our task creation from our awaits -- the second is that it is inflexible.

### Running concurrently with `gather`

This func takes in a sequence of awaitbles and lets us run them concurrently -- all in one line of code, if any of awaitables we pass is in a coroutien, `gather`will automatically wrap it in a task to ensure that it runs concurrently. `asyncio.gather`returns an awaitable. like:

```py
async with aiohttp.ClientSession() as session:
    urls= ['https://www.baidu.com' for _ in range(1000)]
    requests = [featch_status(session, url) for url in urls]
    status_code= await asyncio.gather(*requests)
    print(status_code)
```

### Handling exceptions with gather

`asyncio.gather`gives us an optional parameter -- `return_exceptions`which allows us to specify how we want to deal with exceptions from our awaitables. Is a bool value -- 

- `return_exception=False`-- this is the default value for `gather`-- if any of our coroutines throws an exception, our `gather`call will also throw that exception when `await`it. however, even though one of our coroutines failed, our other coroutines are not canceled and will continue to run as long as we handle the exception, or the exception does not result in the event loop stopping and canceling the tasks.
- `return_exception=True`-- `gather`will return any exceptions as part of the result -- when `await`it, the call to `gather`will not throw any exceptions itself.

```py
@async_timed()
async def main() :
    async with aiohttp.ClientSession() as session:
        urls = ['https://example.com', 'bad://bad.com']
        tasks = [fetch_status_code(session, url) for url = urls]
        status_code = await asyncio.gather(*tasks)
```

Will get `AssertionError`exception. `asyncio.gather`won't cancel any other -- that are running if there is a failure note that -- and That may be acceptable for many use cases but is one of the drawbacks of gather. 

And when running -- `await asyncio.gather(*tsks, return_exceptions=True)`-- no exception are thrown, and we get all the exception alongside our successful results. like:

`exceptions = [res for res in results if isinstance(res, Exception)]` 

asyncio provides APIs that will allow us to solve for both issues, start by looking at the problem of handling results-- 

### Processing requests as the complete

While `asyncio.gather`will wrok for many cases -- it has the drawback that is waits for all awaitables to finish before allowing access to any results. Can also be a problem if we have a few awaitable that could complete quickly and a few which could take some time. Since `gather`waits for everything to finish -- can cause our app to become unresponsive -- image a user makes 100 and two of them are very slow, but the rest are just quickly.

To handle this, `ayncio`exposes an API functin named `as_completed`-- this takes a list of awaitables and returns an iterator of futures. Can then iterate over these futures, awaiting each one. like:

```py
nest_asyncio.apply()


@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = 'https://www.baidu.com'
        fetchers = [
            fetch_status(session, url, 1),
            fetch_status(session, url, 1),
            fetch_status(session, url, 10)
        ]
        for finished_task in asyncio.as_completed(fetchers):
            print(await finished_task)


asyncio.run(main())
```

In this listing, create three coroutines -- two that require about 1s to complete and one that will take 10s -- then pass these into `as_completed`-- under the hood, each coroutine is wrapped in a task and starts running concurrently. The routine instantly returned an iterator that starts to loop over. When enter the `for`, pause the execution and wait for our first result to come in -- our first and second 1s -- in total, iterating over result_iterator -- takes about 10 seconds. however, we are able to execute code to just print the result of our first requests as soon as it finishes. This just gives us extra time to process the result of our first successfully finished coroutine while others are still waiting to finish.

### Timeouts with `as_completed`

Any web-based request runs the risk of taking a long time-- a server could be under a heavy resource load, or we could have a poor network connection -- saw hot to add timeouts for a particular request, but what if we wanted to have a timeout for a group of request -- the `as_completed`function supports this use case by supplying an optional timeout parameter, which lets us specify a timeout in a seconds. Like:

```py
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = 'https://www.baidu.com'
        fetchers = [
            fetch_status(session, url, 1),
            fetch_status(session, url, 1),
            fetch_status(session, url, 10)
        ]
        for done_task in asyncio.as_completed(fetchers, timeout=2):
            try:
                result= await done_task
                print(result)
            except asyncio.TimeoutError:
                print('we got a timeout error!')
                
        for task in asyncio.tasks.all_tasks():
            print(task)


asyncio.run(main())
```

Run this, notice the result from .. after 2, see two timeout error -- also see that two fetchers running. -- so, `as_completed`works well for getting results as fast as possible but has drawbacks. The first is that while we get results as they come in, there isn't any way to easily see which coroutine or task we're waiting as the order is completely nondeterministic.

the second is that with timeouts, while we will correctly throw an exception and move on-- any tasks created will still be running in the background -- since it's hard to figure out which tasks still running in the background. -- if want to cancel them -- hard. And, if these are problems we need to del with -- need some finer-grained knowledge of which awaitable are finished, and which are good.

## Extending the data source and Repositories

With the autentication system in place, next is to just extend the data source so that it can send authenticated requests and to expose those features through the roder and product repository classes.

```ts
private getOptions() {
    return {
        headers: new HttpHeaders({
            "Authorization": `Bearer<${this.auth_token})>`
        })
    }
}

saveProduct(product: Product): Observable<Product> {
    return this.http.post<Product>(this.baseUrl + 'products', product, this.getOptions());
}

updateProduct(product: Product): Observable<Product> {
    return this.http.put<Product>(`${this.baseUrl}products/${product.id}`, product, this.getOptions());
}

deleteProduct(id: number): Observable<Product> {
return this.http.delete<Product>(`${this.baseUrl}products/{id}`, this.getOptions());
}

getOrders(): Observable<Order[]> {
return this.http.get<Order[]>(this.baseUrl + "orders", this.getOptions());
}

deleteOrder(id: number): Observable<Order> {
return this.http.delete<Order>(`${this.baseUrl}orders/${id}`, this.getOptions());
}

updateOrder(order: Order): Observable<Order> {
return this.http.put<Order>(`${this.baseUrl}orders/${order.id}`, order, this.getOptions());
}
```

When the RESTful web service authenticates a user, it will return a JSON web token that the app must include in subsequent HTTP rquests to show that authentication has been successfully performed. Can authenticate the user by  sending a POST rquest to the `/login`URL, including a JSON-formatted object n the request body that contains name and pwd properties.

These add  new methods to the product repository class that allow products to be created, updated, and deleted.

```tsx
saveProduct(product: Product) {
    if (product.id == null || product.id == 0) {
        this.dataSource.saveProduct(product)
            .subscribe(p => this.products.push(p));
    } else {
        this.dataSource.updateProduct(product)
            .subscribe(p => {
            this.products.splice(this.products
                                 .findIndex(p => p.id == product.id), 1, product);
        })
    }
}

deleteProduct(id: number) {
    this.dataSource.deleteProduct(id).subscribe(p => {
        this.products.splice(this.products.findIndex(p => p.id == id), 1);
    })
}
```

And, also makes the corresponding changes to the order repository, adding methods that allow orders to be modified and deleted -- 

```tsx
@Injectable()
export class OrderRepository {
    private orders: Order[] = [];
    private loaded: boolean = false;

    constructor(private dataSource: RestDatasource) {
    }

    loadOrders() {
        this.loaded = true;
        this.dataSource.getOrders()
            .subscribe(orders => this.orders = orders);
    }

    getOrders(): Order[] {
        if (!this.loaded) {
            this.loadOrders();
        }
        return this.orders;
    }

    saveOrder(order: Order): Observable<Order> {
        this.loaded = true;
        return this.dataSource.saveOrder(order);
    }

    updateOrder(order: Order) {
        this.dataSource.updateOrder(order)
            .subscribe(order => {
                this.orders.splice(this.orders.findIndex(o => o.id == order.id), 1, order);
            });
    }

    deleteOrder(id: number) {
        this.dataSource.deleteOrder(id).subscribe(order => {
            this.orders.splice(this.orders.findIndex(o => id == o.id), 1);
        })
    }

}
```

The order repository just defines a `loadOrders`method that gets the orders from the repository and that ensure the request isn’t sent to the RESTful web service until authentication has been performed.

```tsx
const features: any[] = [];

@NgModule({
    imports: [features],
    exports: [features[]
})
export class MaterialModule {
}
```

No angular Material features are selected at present -- but add to this file as i work through the administration features.

## Understand Ng projects and Tools

- `--prefix`-- this option applies a prefix to all of the component selectors, and described in the understanding how an Ng application works
- `--routing`-- creates a routing module in the proj
- `--skip-git`-- using the option prevents a Git repository from being created in the project.
- `--skip-install`-- this option prevents the initial operation that downloads and installs the packages just required by Ng apps and project’s development tools
- `--skip-tests`-- this prevents the addition of the initial configuration for testing tools.
- `--style`-- this specifeis how stylesheets are handled.

### The files and folders in a new Ng Project

- `node_modules`-- contains the NPM packages that are required for the appliation and for the Ng development tools.
- `src` - contains the app’s source code, resources, and configuration files
- `.browserslistrc`-- specify the browsers that the app will support.
- `.editorconfig`-- contains settings that configure text editors.
- `angular.json`-- configuration for the Ng development tools.
- `package.json`-- contains details of the NPM packages required by the app and the development tools.
- `tsconfig.json`-- contains the configuration settings for the Tsc compiler

### The files and folder in the `src`

- `app`-- contains an app’s source code and content.
- `assets`-- is used for the sttic resources required by the apps, fore, images
- `environments`-- contains config files that defines settings for different environments.
- `index.html`-- This the the HTML that is sent to the browser during the development
- `main.ts`-- this contains the tsc statement that start the applicatin when they are executed
- `polyfills.ts`-- this used to include polyfills in the proj to provide support for features that are not supported in other browsers.
- `style.css`-- define css style that are applied throughout the app
- `tests.ts`-- config the `karma`test package.

### Understanding the Packages Folder

A lot of packags that are used behind the scenes, during development, Many of these packages are just a few lines of code, but , there is a complex hierarchy of dependencies between them that is too large to manage manully, so a package manger is used. The package manager is given an initial list of packages. All the required packages are downloaded and installed in the `package.json`file.

The initial set of packages is defined in the `package.json`file using the `dependencies`and `devDependenceis`properties. The `dependencie`prop is used to list the packags that the app will require to run.

- `~` -- prefixing a ~ accepts versions to be installed even if the patch level number doesn’t match -- fore
- `^`-- prefixing a version number with a caret will accept versions even if the minor release number or the path number dosn’t match.

And the version fiexibility is more important when it comes to the `devDependencies`section of the file, which contains a list of packags that are required for development but which will not be part of the finished appliation. 

And the packages required for basic development are automatically downloaded and installed into the `node_modules`folder when just create a proj -- lists some commands that you may find useful during development.

- `npm install package@version`-- performs a local install of specific version of a package and updates the `package.json`file to add the package to the `dependencies`section.
- `npm install package@versin --save-dev`-- to add to the `devDependencies`section.
- `npm package@version` -- downloads and executes a package

for the `ng serve; ng build;... ng test` -- are run by using `npm run`followed by the name of the command that you just require -- and this must be done in the folder that contains the `package.json`file -- so, if want to run the test command in the example project -- `npm run test`. can get the same result by using the command `ng test`.

And, note that the `npx`command is useufl for downloading and executing a package in a single command, which use in the section later.

Some Js packages take advantage of the *schematics* API provided by the `@angular/cli`package to automate the integration process. fore, the Angular Material. like: `ng add @angular/material`-- The `ng add`command uses the package manager selected when the Ng project was created to download the package.