# Importing data set with `read_csv`function

A csv is just like: Pandas has more than a dozen import functions to load various file formats -- the funcitons are available at the lib's top level and begin with the prefix `read`. To import, `read_csv`function -- `filepath_or_buffer`expects a string with the filename -- Make sure that the string includes the `.csv`extension, by default, pandas looks for the file in the same dir as the notebook like:

`pd.read_csv('../pandas-in-action/chapter_03_series_methods/pokemon.csv')`

But, regardless of the number of column is data set, the `read_csv`function always imports the data into a `DataFrame`-- a two-dimensional pandas data structure that supports multiple rows and columns -- First issue is that the data but -- `Series`supports only one column of data -- simple is just stting one of the data set's columns as the `Series`index, just using the `index_col`parameter to set the index column. like:

`pd.read_csv('...csv', index_col= 'Pokemon')`

For this, just set the Pokemon column as the `Series`index -- but pandas still defaults to importing the data into a `DataFrame`-- after all, a container capable of holding multiple columns of data cn just technically hold one column of data. To force pandas to use a `Series`-- need to add another parameter called `squeeze`and pass into of `True`. Note that the `Squeeze`parameter coerces a one-column `DataFrame`into a `Series`.like:

```py
pd.read_csv('../pandas-in-action/chapter_03_series_methods/pokemon.csv', 
            index_col='Pokemon').squeeze()
pd.read_csv('../pandas-in-action/chapter_03_series_methods/google_stocks.csv').head()
```

And, when importing a data set, pandas just infers the most suitable data type for each column. Sometimes, the lib play it safe and avoids making assumptions about data. Unless we tell pandas to treat the vlaues as datetimes -- The `read_csv`func 's `parse_date`parameter accepts a list of strings denoting the column whose text values pandas should convert to datetime -- like:

```py
pd.read_csv('../pandas-in-action/chapter_03_series_methods/google_stocks.csv', 
            parse_dates=['Date']).head()
```

For this, no visual difference in the output, but pandas is storing a different data type for the `Date`column under the hood -- set the `Date`column as the `Series`index with the `index_col`parameter -- a `Series`works fine with this. like:

```py
pd.read_csv('../pandas-in-action/chapter_03_series_methods/google_stocks.csv', 
            parse_dates=['Date'], index_col='Date').head().squeeze()
```

And , have more data set to import -- like:

```py
pd.read_csv('../pandas-in-action/chapter_03_series_methods/revolutionary_war.csv',
            index_col='Start Date', parse_dates=['Start Date']).tail()
```

By default, the `read_csv`function imports columns from a CSV -- have to limit the import to two columns if we want a `Series`-- one column for the index and the other for the values. like: The `read_csv`function's `usecols`parameter acepts a list of columns that pandas should import like:

```py
pd.read_csv('../pandas-in-action/chapter_03_series_methods/revolutionary_war.csv',
            index_col='Start Date', parse_dates=['Start Date'],
            usecols=['State', 'Start Date']).tail().squeeze()
```

### Sorting a Series

Can sort a `Series`by its values or its index, in ascending or descending order -- Suppose are just curious about the lowest and highest stock prices that Google has had. -- the `sort_values()`returns just a new `Series`with the values sorted in ascending order -- `Ascending`meaning -- in size. like:

`google.sort_values()`

Pandas sorts a `Series`of strings in alphabeitical order. And sort uppercase before. And the `ascending`parameter sets the order. can `google.sort_values(ascending=False).head()`

And a descending sort will arrange a `Series`of strings in reverse order. like:

`pokemon.sort_values(ascending=False).head()`

Note the `na_position`configures the placement of NaN values in the returned `Series`and has default `last`. Can:

```py
battles.sort_values(na_position='first')
```

And, can remove `NaN`values -- the `dropna`method returns a `Series`with all missing values removed. like:

`battles.dropna().sort_values()`

### Sorting by index with the `sort_index`method

Sometimes, our area of focus may lie in the index rather than the values we can sort a `Series`by index as well with the `sort_index`method -- with this option, the values move alongside their index counterparts. like `sort_values`, `sort_index`accepts an `ascending`parameter -- and its default argument is also to `True`.

```py
pokemon.sort_index()
pokemon.srot_index(ascending=True)
battles.sort_index(na_position='first').head()
```

The `sort_index`also includes the `na_position`parameter for altering the placement of `NaN`values. And to sort descending order, can pass the `ascending`parameter an argument of `False`.

### Retrieving smallest and largest with the `nsmallest`and `nlargest`

`sort_values().head()`-- the opertion is common, so pandas offers a helper method to save us -- like:

`google.nlargest(n=5)`

### Overwriting a Series with the inplace parameter

All methods just returns a new `Series`obj -- the original `Series`obj referenced by `pokemon`, `google`.. have remained unaffected throughout our operation thus far. -- note that many methods in pandas just include an `inplace`parameter data -- that passed an arg of `True`-- appears to modify the object on which the method is invalid.

`battles.sort_values(inplace=True)`

The `inplace`is a frequent point of confusion -- name suggests that it modifies or mutates the existing object rather then creating a copy. Technically equivalent -- 

```py
battles.sort_values(inplace=True)
battile = battles.sort_values()
```

### Couting values with the `value_counts()`method -- 

How can find out most common types of `pokemon` -- need to group the values into **buckets** and count the number of elements in each bucket -- the `value_counts()`-- which counts the number of occurrences of each `Series`value like:

`pokemon.value_counts()`

Just returns a new `Series`object, the index labels are the `pokemon`sereis' values -- and the values are their respective counts, and the length of the `value_counts`is equal the number of unique values in the `pokemon`like:

Data integrity is paramount in situations like these -- the presence of an extra space or the different casing of a character will cause pandas to deem two values unequal and count them separately. Note that the `value_counts()`method's ascending parameter has a default value of `False`.

May be more in the ratio of type relative to all the type like:

`pokemon.value_counts(normalize=True)`

Can also multiply the values in the frequency `Series`by 100 to get percentage each pokemon type constributes to the whole. Can just:

`pokemon.value_counts(normalize=True).head()*100`

Can also limit the precision of the percentages -- can just round a `Series`values' digits with the `round`method. The method's like:

`(pokemon.value_counts(normalize=True)*100).round(2)`

The `value_counts`method operates identically on a numeric `Series` -- the next example counts the occurrences of each unique stock price in the *google Series*.

`google.max(), google.min()`

Have a range of ~1250 between the smallest and largest values -- group the stock prices into of 200 -- Can just define these intervals as values in a list and pass the list to the `value_counts`methods ' `bins`parameter -- Pandas will use every two subsequent list vlaues as the lower and upper ends of an interval like:

```py
buckets = list(range(0, 1401, 200))
google.value_counts(bins=buckets)
```

Also note that the `bins`needs just an iterable. And note that the pandas sorted the previous in descending order by the number of values in each buckets. So, what if wanted to sort the results by the intervals instead -- simply have to mix and match a few pandas methods like:

`google.value_counts(bins=range(0,1401,200)).sort_index()`

Can also archieve an identcal result by passing a value of `False`to the `sort`parameter like:

`google.value_counts(bins=range(0,1401,200), sort=False)`

Notice that the `(-0.01, ...)` just equal `(-0.01,200]` so the `value_counts`method with the `bins`parmeter returns a *half-open* intervals -- And this parameter also accepts a integer argument -- Pandas will automatically calculate the difference between the maximum and minimum values in the `Series`and divde the range into the specified number of bins. like:

`google.value_counts(bins=6, sort=False)`

And, also can use the `value_counts`method to see which states had the most battles in the war like: Pandas will exclude `NaN`values from the `value_coutns`by default.

`battles.value_counts(dropna=False).head()`

A `Series`index also supports the `value_counts`method, have to access the index object via the `index`like:

`battles.index.value_counts()`

## Processing requests as they complete

While `asyncio.gather`will work for many cases, it has the drawback that it waits for all awaitable to finish before allowing access to any results. This is just a problem if we'd like to process results as soon as they come in. Can also be a problem if we have a few awaitables that could complete quickly and a few which could take some time.

Note that the `gather`just waits for everything to finish -- this can cause our app to become unresponsive.

To handle -- exposes an API function named `as_completed`takes a list of awaitables and *returns an iterator of futures*. can then iterate over these `futures`. Will retrieve the result of the coroutine that finished first out of all our awaitable. like:

```py
async def fetch_status(session: ClientSession, url: str, delay: int=0)->int:
    await asyncio.sleep(delay)
    async with session.get(url) as result:
        return result.status
```

Then use a `for`loop to iterate over the iterator returned from `as_completed`fore:

```py
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        fetchers= [fetch_status(sessin, .., 1),
                  fetch_status(sessi.., 1)]
        for finished_task in asyncio.as_completed(fetchers):
            print(await finished_task)
```

### Timeouts with `as_completed`

Any web-based request runs the risk of taking a long time -- a server could be under a heavy resource load, or we could have a poor network connection. like:

```py
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        fetcher= [...]
        for done_task in asyncio.as_completed(featcher, timeout=2):
            try:
                result= await done_task
                print(result)
            except asyncio.TimeoutError:
                print(...)
                
        for task in asyncio.tasks.all_tasks():
            print(task)
```

When urn this, notice that the result from our first fetch -- see two timeout error, also see the two fetchers are still running, giving output similar to the following like:

`as_completed`works well for getting results as fast as possible but has drawbacks -- the first is that while get results as they com in -- there isn't any way to easily see which coroutine or task we are awaiting as the order is completely nondeterministric.

The second is that with timeouts, while will correctly throw an exception and move on. And, note that any tasks created will still running if we want to cancel them.

### Finer-grained control with `wait`

So, one of the drawbacks of both `gather`and `as_completed`is that there is no easy way to cancel tasks that we already running when saw an expcetion. This has the potential to cause performance issues -- consume more resources by having more tasks than we need. Another with the `as_completed`which it is iteration order is non-deterministic.

`wait`like gather -- but offers more specific control to handle these situations -- this has several options to choose from depending on when want our results. In addition, this method returns two sets -- a set of tasks that are finished with either a result or an exception, and a set of tasks that are still running. This function aslo allows us to specify a timeout that behaves differently from how other API methods operate.

The basic signature of `wait`is a list of awaitable objects, followed by an optional timeout and an optional `return_when`string -- this string has a few predefined values `ALL_COMPLETED, FIRST_EXCEPTION, FIST_COMPLETED`, and it defaults to `ALL_COMPLETED`-- while as of thiw writing, `wait`takes a list of awaitbles, will change in future.

### Waiting for all tasks to complete

This option is the default behavior if `return_when`is not specified, and it is the closest in behavior to `asyncio.gather`. like:

```py
import asyncio
import aiohttp
from aiohttp import ClientSession
from util import async_timed, fetch_status
import nest_asyncio

nest_asyncio.apply()


@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        fetchers = \
            [
                asyncio.create_task(fetch_status(session, 'https://www.baidu.com')),
                asyncio.create_task(fetch_status(session, 'https://www.baidu.com'))
            ]
        done, pending = await asyncio.wait(fetchers)

        print(f'Done task count: {len(done)}')
        print(f'Pending task count: {len(pending)}')

        for done_task in done:
            result = await done_task
            print(result)


asyncio.run(main())
```

When we `await wait`it will return two sets *once all requests finish*. one set of all tasks are complete and one set of the tasks that are still running -- the `done`set contains all tasks that finished either successfully or with exceptions. and the `pending`set contains all tasks that have not finished yet.

Note that the `done`set contins all tasks that finished either successfully or with exceptions -- the `pending`set contains all tasks that have not finished yet. since are using the `ALL_COMPLETED`option in the `pending`set will always be zero.

And with this paradigm, have a few options on how to handle exceptions -- can use `await`and let the exception thow, can use `await`and wrap it in a `try except`block to handle the exception.

Fore, we don't want to throw an exception and have our app crash -- like:

```py
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        good_request = fetch_status(session, 'https://www.baidu.com')
        bad_request = fetch_status(session, 'python://python')
        fetchers = [asyncio.create_task(t) for t in (good_request, bad_request)]
        done, pending = await asyncio.wait(fetchers)
        print(f'Done task count: {len(done)}')
        print(f'Pending task count: {len(pending)}')

        for dt in done:
            if dt.exception() is None:
                print(dt.result())
            else:
                logging.error('Request got an exception',
                              exc_info=dt.exception())


asyncio.run(main())`
```

### Watching for Exceptions

The drawback of `ALL_COMPLETED`are like the drawbacks we saw with `gather`, could have any number of exceptions while we wait for other coroutines to complete. Won't see until all tasks complete. We just want to immediately handle any errors to just ensure responsiveness and continue waiting for other coroutines to complete.

To support these use cses, `wait`uses `FIRST_EXCEPTION`option like:

```py
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        fetchers = [
            asyncio.create_task(fetch_status(session, 'p://p')),
            asyncio.create_task(fetch_status(session, 'https://www.baidu.com')),
            asyncio.create_task(fetch_status(session, 'https://www.baidu.com', delay=3))
        ]
        done: list[asyncio.Task]
        pending: list[asyncio.Task]
        done, pending = await asyncio.wait(fetchers, return_when=asyncio.FIRST_EXCEPTION)

        print(f'Done task count: {len(done)}')
        print(f'Pending task count: {len(pending)}')

        for dt in done:
            if dt.exception() is None:
                print(dt.result())
            else:
                logging.error('Request got an exception',
                              exc_info=dt.exception())

        for pending_task in pending:
            pending_task.cancel()
            

asyncio.run(main())
```

In this, make one bad reuest and two good -- When await the `wait`-- return almost immediately since our bad request errors out right away -- then loop through the `done`tasks -- In this instance, have only one in the `done`set since our request ended immediately with an exception.

### Processing results as they complete

Both `ALL_COMPLETED`and `FIRST_EXCEPTION`have the drawback that -- in case where coroutines are successufl and don't throw an exception, we must wait for all corotines to complete -- Depending on the use case, this may be acceptable, but if we are in a situation where we just want to respond a coroutine as soon as it complete successfully, are out of luck. The issue with the `as_completed`is there is no easy way to see which tasks are remaining and which tasks have completed -- get them only one at a time through an iterator.

So there for the `return_when`parameter accepts a `FIRST_COMPLETED`option - -this will make the `wait`coroutine return as soon as it has at least one result -- can either be a coroutine that failed or one that ran successuflly.

```py
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = 'https://www.baidu.com'
        fetchers = [asyncio.create_task(fetch_status(session, u))
                    for u in [url] * 3]
        done, pending = await asyncio.wait(fetchers,
                                           return_when=asyncio.FIRST_COMPLETED)

        print(f'Done task count : {len(done)}')
        print(f'Pending task count: {len(pending)}')

        for done_task in done:
            print(await done_task)


asyncio.run(main())
```

For this, we start 3 requests concurrently, our `await`coroutine will return as soon as any of these requests completes -- this means that `done`have one complete request, and `pending`contain anything still running. So, this approach lets us respond right away when our first task completes. This will give us behavior similar to the `as_completed`, with the benefit that at each step know exactly which tasks have finished and which are still running.

```py
while pending:
    done, pending = await asyncio.wait(pending,
                                   return_when=asyncio.FIRST_COMPLETED)
    print(f'Done task count : {len(done)}')
    print(f'Pending task count: {len(pending)}')

    for done_task in done:
        print(await done_task)
```

In this, created a set named `pending`what we initialize to the coroutine we want to run -- loop while we have items the `pending`set and call `wait`with that set on each iteration. Once we have a result from `wait`, we just update the `done`and `pending`sets and then print out any `done`tasks.

## Using the Development Tools

Projects created using the `ng new`command include a complete set of development tools that monitor the app’s files and build the project when a change is detected. fore: `ng serve`- the command starts the build process, which produces message like these at the command prompt:

### Understanding the Development HTTP server

To simiplify the development process, the project just incorporates an HTTP server that is tightly integrated with the build process, and when just run the `ng serve`-- the proj is built so that it can be used by the browser -- this is a process that requires 3 important tools - Ts compiler, Ng compiler, package named webpck.

The ts compiler is responsible for compiling the Ts files into js, and Ng compiler is responsible for transforming templates into JS statements that use the browser APIs to create the HTML elements in the template file and evaluate the expressions they contain.

The build process is managed through webpack -- whichis a module bundler -- meaning that it takes compiled output and consoliates it into a module that can be sent to the browser -- this process is known as bundling, which is a bland description for an important function, and it is one of the key tools that you will rely on while developing an Ng application.

And when run the `ng serve`, will see a series of messages as webpack processes the application. Starts with the code in the `main.ts`file-- which is the entry point for the appliation and follows the `import`statement it contains to discover its discover its dependencies, repeating this proces for each file on which there is a dependency. Webpack works its way through the `import`statements, compiling each Ts and template file on which a dependency is declared to produce Js code for the entire application.

So the output from the `main.ts`process is combined into a single file, known as a *bundle*. The initial buid process can take a while to complete cuz the 5 bundles are produced, as described -- 

- `main.js`-- this contains the compiled output produced from the `src/app`folder
- `polyfills.js`-- this file contains js polyfills required for features used by the app that are not supported by the target browsers.
- `runtime.js`-- this file contains the code that loads the other modules.
- `styles.js`-- this contains js code that adds the app’s g*lobal css stylesheets*.
- `vendor.js`-- this contains the 3rd-party packages the app depends on.

### Understanding the Application Bundle

When saves the changs -- only the affected bundles will be rebuilt-- will see messages at the command prompt.

The `styles.js`bundle is used to add CSS stylesheets to the appliation, the bundle file contains Js code that uses the browser API to define styles, along with the contents of the CSS stylesheets the application requires. And CSS stylesheets ar added to the application using the `styles`section of the `angular.json`file.

### Understanding how an Angular Application works

Angular can seem like magic when U first start using it, and it easy to become wary of making changes to the project files for fear of breaking something.

### Understanding the HTML document

The starting point for running the applicaiton is `index.html`file, which is found in the `src`folder, when the browser sent the request to the development HTTP server, it received this file, which contains the headers `link`for font files.

Browser executes js files in order in the which their `script`elements appear, starting with the `runtime.js`file, which contains the code that processes the contents of the other Js files - next comes the `polyfills.js`which contains code that provides implemetnation of features that the browser doesn’t support, and then `styles.js`-- which contains the CSS styles the app needs. and the `vendor.js`just contains the 3rd-party code the application requires... The final is the `main.js`bundle, which contains the custom app code, the name of the bundle is taken from an entry point for the application, which is the `main.ts`file in the `src`folder.

```tsx
if(environment.production) {
    enableProdMode();
}
platformBrowserDynamic().bootstrapModule(AppModule).catch(err=> console.error(err));
```

Just initializes the ng platform for use in a web browser and is imported from the `@angular/platform-browser-dynamic`module.

### Understanding the Root Ng Module

The term `module`does double duty in an Ng app and refers to both a Js module and an Ng module. Js modules are used to track dependencies in the application and ensure that the browser receives only the code it requires. Every app has a *root* Angular module, which is responsible for describing the app to ng.

And every app has a *root* Ng module - which is responsible for describing the app to Ng. For app created with the `ng new`command, the root module is called `AppModule`, and it is defined in the `app.module.ts`file.

The `AppModule`class doesn’t define any members, but it provides Ng with essential info *through the configuration properties of its `@NgModule`decorator*.

### Ng Component

The component called `AppComponent`-- which is selected by the root Ng module, is defined in the `app.component.ts`file in the `src/app`folder, here are the contents of the `app.component.ts`like: -- the properties for the `@Component`decorator configure its behavior.

### Understanding the Production Build Process

During the development the emphasisi is on fast compilation so that the results can be displayed as quickly as possible in the browser. Before an app is deployed, it is built using an optimizing process, to run the type of build like:

`ng build`

Performs the production compilation process, and the bundles it produces are smaller and contain only the code that is required by the application.

And to test like:

`npx htt-server dist/example --port 5000`

### Starting Development in an Ng project

Of all the building blocks in an app, the data model is the one for which Angular is the least prescriptive -- elsewhere in the app, Ng requires specific decorators to be applied or part of the API to be sued, but the only requirement for the model is that it provides access to the data that app requires.

- One or more classes just describes the data in the model
- A data source that loads and saves data, typically to a server
- A repository that allows the data in themodel to be manipulated.

Descriptive classes, as the name suggests, describe the data in the app, in a real proj, there will usually be a lot of classes to fully describe the data that the app operates on.

```tsx
export class Product {
  constructor(public id?: number,
              public name?: string,
              public category?: string,
              public price?: number) {
  }
}
```

The data source provides the app with the data -- like:

```ts
import {Product} from "./product.model";

export class SimpleDataSource {
  private data: Product[];
  constructor(){
    this.data = new Array<Product>(
      new Product(1, "Kayak", "Watersports", 275),
      //...
}

```

The data in this class is just hardwired.

### Creating the Model Repository

The final step to complete the simple model is to define a repository that will provide access to the data from the data source and allow it to be manipulated in the app.

```ts
import {SimpleDataSource} from "./datasource.model";
import {Product} from "./product.model";

export class Model {
  private dataSource: SimpleDataSource;
  private products: Product[];
  private locator = (p: Product, id: number | any) => p.id == id;

  constructor() {
    this.dataSource = new SimpleDataSource();
    this.products = new Array<Product>();
    this.dataSource.getData().forEach(p => this.products.push(p));
  }

  getProducts(): Product[] {
    return this.products;
  }

  getProduct(id: number): Product | undefined {
    return this.products.find(p => this.locator(p, id));
  }

  saveProduct(product: Product) {
    if (product.id == 0 || product.id == null) {
      product.id = this.generateID();
      this.products.push(product);
    } else {
      let index = this.products.findIndex(p => this.locator(p, product.id));
      this.products.splice(index, 1, product);
    }
  }

  deleteProduct(id: number) {
    let index = this.products.findIndex(p => this.locator(p, id));
    if (index > -1) {
      this.products.splice(index, 1);
    }
  }

  private generateID(): number {
    let candidate = 100;
    while (this.getProduct(100) != null)
      candidate++;
    return candidate;
  }
}
```

