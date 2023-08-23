# Counting Values

The `value_counts()`method returns a new `Series`object, the index labels are the pokemon `Series`vlaues, and the values are their respective counts, The length of `value_countss`is equal to the number of unique values in the pokemon Series, as a reminder, the `nunique`method returns this piece of info. `pokemon.nunique()`

And the `value_counts`method's `ascending`parameter just has a default argument of `False`-- Pandas sorts the values in descending order, from most occurrences to least occurrences.

May be more interested in the ratio of a type relative to all the types, set the `value_counts`method's normalize parameter to `True`to return the frequencies of each unique value. like:

`pokemon.vlaue_counts(normalize=True).head()` or:

`(pokemon.value_coutns(normalize=True)*100).round(2)`

```py
buckets= range(0, 1401, 200)
google.values_count(bins=buckets)
google.value_counts(bins=buckets).sort_index()
google.value_counts(bins=buckets, sort=False)
```

Need to note that the `value_counts`method `bins`parameter also accepts in integer argument -- pandas will automatically calculate the difference between the maxi and min values in the `Series`and divide the range into the specified number of bins.

`google.value_counts(bins=6, sort=False)`

Note that Pandas will exclude the `NaN`values from the `value_counts()`by defult, can pass the `dropna`parameter an argument of `False`to count null values as distinct category like:

`battles.value_counts(dropna=False).head()`

`battles.index`, and `battles.index.value_counts()`, so index prop also has `value_counts()`method.

### Invoking a function with the `apply`

A function is a first-class object in py, which means that the language treats it like any other data type, a function may fill like a more abs entity, but as valid a data structure as any other. Here is the simplest way to think about the first-class objects -- anything that you can do with a number, U can do with a fucntion, can do all the following things fore:

- Store a function in a list
- Assign a function as a value for a dict key
- Pass a func into another func as an arg
- return a function from another like:

```py
funcs = [len, max, min]
for f in funcs:
    print(f(google))
```

The output includes the sequential return values of three functions - the length of the `Series`, the maximum value in the `Series`, and the minimum value in the `Series`.

Wouldn't it be great if we could apply this `round`to every value in our `Series`-- The `Series`has a method just alled `apply`that invokes a func once for each `Series`value and returns a new `Series`consisting of the return values of the funciton invocations. The `apply`method expects the function it will invokes as its first parameter like:

`google.apply(func=round)`

Just notice that we are passing the `apply`method the uninvoked `round`function -- passing in the recipe. Somewhere in the internals of pandas -- the `apply`method knows to invoke on every `Series`value.  A func is an ideal container for encapsulating that logic. using Python' s `in`opertor to just check for the inclusion of a forward slash in the argument string -- the `if`statement executes a block only if its condition evaluates to `True`.

```py
def single_or_multi(pokemon_type):
    if '/' in pokemon_type:
        return 'Multi'
    return 'Single'

pokemon.apply(single_or_multi)
```

```py
import datetime as dt
today = dt.datetime(2020, 12, 26)
today.strftime('%A')
```

```py
days_of_war = pd.read_csv(
    '../pandas-in-action/chapter_03_series_methods/revolutionary_war.csv',
    usecols=['Start Date'],
    parse_dates=['Start Date']
).squeeze()
```

Our next challage is extracting the day of the week of each date. One solution is to pass each `Series`value to function that will return that date's day of the week.

```py
def day_of_week(date):
    return date.strftime('%A')
```

```py
def day_of_week(date):
    return date.strftime('%A')
days_of_war.dropna().apply(day_of_week)
```

Also, can use: `days_of_war.dropna().apply(days_of_week).value_counts()`

## The `DataFrame`object

The pandas `DataFrame`is a two-dimensional table of data with rows and columns, as with a `Series`, pandas assigns an index label and an index position to each `DataFrame`row- Pandas also assigns a lable and a position to each column. The `DataFrame`is 2D cuz it requires two points of reference -- a row and a column.

### Creating a DF from a dictionary

The ctor's first parameter, `data`expects the data that will populate the `DF`-- One suitable input is a Python dictionary in which the keys are column names and the values are column values -- the next example passes dict of string keys and list values -- Pandas returns a DF with the 3 columns like:

```py
city_data = {
    "City": ["New York City", "Paris", "Barcelona", "Rome"],
    "Country": ["United States", "France", "Spain", "Italy"],
    "Population": [8600000, 2141000, 5515000, 2873000]
}
cities = pd.DataFrame(city_data)
cities
```

And a DF just holds an index of row labels, did not provide the constructor a cusomt index, so pandas generated a numeric one strating at 0. the logic operates the same way it does on `Series`

A DF can hold multiple columns of data, it's helpful to think of the column headers as second index.. like:

### Creating a DF from a Np ndarray

Try one more example, the DF constructor's `data`parameter also accepts a Numpy `ndarray`-- can generate an `ndarray`of any size with the `randint`function in Numpy's `random`module -- like:

```py
random_data= np.random.randint(1, 101, [3, 5])
pd.DataFrame(random_data)
```

Can just manually set the row labels with the `DataFrame`'s ctor's `index`parameter, which acepts any iterable like:

```py
row_labels= ['Morning', 'Afternoon', 'Evening']
temperatures = pd.DataFrame(random_data, index=row_labels)
temperatures
```

Can set the column names with the ctor's `columns`parameter, the `ndarray`includes 5 columns, so must pass an iterable with 5 items -- the next example passes the column names in a tuple -- like:

```py
row_labels= ['Morning', 'Afternoon', 'Evening']
column_labels = (
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
)
pd.DataFrame(random_data, index=row_labels, columns=column_labels)
```

Pandas permits duplicates in the row and column indices, in the next appears twice in the row's index labels, and: 

### Similarities between Series and DataFrames

Many `Series`attributes and methods are also available on `DF`.

```py
pd.read_csv('../pandas-in-action/chapter_04_the_dataframe_object/nba.csv', 
            parse_dates=['Birthday'])
```

### Shared and exclusive attributes of Sereis and DF

Attributes and methods may differ between `Series`and `DataFrames` -- both in name and implementation. Here is an exmple, a `Series`has a `dtype`attribute that reveals the data type of its values -- notice that the `dtype`attribute is singlualr cuz a `Series`can store only one data type -- fore, a `DataFrame`can hold heterogenous data -- means that mixed and varied.

For the `Name, Team, Position`column list is just `object`as their data type -- the `object`data type is panda's lingo for complex objects including strings.

And a `DataFrame`consists of several smaller objects -- an index that holds the row labels, an index that holds the column labels, and a data container that holds the values.

And Pandas also uses a separate index object to store a `DataFrame`columns, can access it via the `columns`attribute.

`nba.ndim, nba.shape, nba.size, nba.count()`

Note that the `size`prop just including the `NaN`and the `count()`exclude that. By comparision, the `sum()`return 3 cuz the `DataFrame`has three non-null values. 

Suppose that want to find out how many team, slaries, and positions exist in this data set, used the `nunique`method to count the number of unique values in the `Series`-- like: `nba.nunique()`

Can laso use the `max`and `min`methods -- returns for each column -- like:

`nba.max(), nba.min()`

And such as the 4 highest-paid players in the data set -- the `nlargest`method receives a subset of rows in which a given column has the largest values in the `DataFrame`-- pass the number of rows to extract to its `n`parameter and the column to use for sorting to its `columns`parameter like:

`nba.nlargest(n=4, columns='Salary')`

And, to find the 3 oldest players like:

`nba.nsmallest(n=3, columns=['Birthday'])`

`nba.sum(numeric_only=True)`

## Processing all results as they come in

```py
import asyncio
import aiohttp
from util import fetch_status, async_timed
import nest_asyncio

nest_asyncio.apply()


@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = 'https://www.baidu.com'
        pending = [asyncio.create_task(fetch_status(session, url)) for _ in range(3)]

        while pending:
            done, pending = await asyncio.wait(pending,
                                               return_when=asyncio.FIRST_COMPLETED)
            print(f'Done task count : {len(done)}')
            print(f'Pending task count: {len(pending)}')

            for dt in done:
                print(await dt)


asyncio.run(main())
```

In this listing, just create a set named `pending`that we initialize to the coroutines we want to run -- loop while we have items in the `pending`set and call `wait`with that set on each iteration. Once we have a result from `wait`, we just update the `done`and `pending`sets and then print out any `done`tasks -- this will give us behavior similar to `as_completed`with the difference being have better insight into which tasks are done and which tasks are still runinng.

### Handling timeouts

In addition to allowing us finer-grained control on how we wait for coroutines to complete, `wait`also allows to set timeouts to specify how long we want for all awaitables to complete. To enable this, can set the `timeout`parameter with the maximum number of seconds desired. If we've exceeded this timeout, `wait`will return both the `done`and `pending`task set-- there are a scouple of differences in how timeouts behave in `wait`as compared to what we have seen hus far with `wait_for`and `as_completed`.

Coroutines are not canceled -- When use `wait_for`, if our coroutine timed out it would automatically request cancellation for us -- this is not the case with `wait`. it behaves closer to what saw with `gather`and `as_completed`in the case we want to cancel coroutines due to a timeout, must explicitly loop over the tasks and cancel them.

### Timeout errors are not raised

`wait`does not rely on exception in the event of timeouts as to `wait_for`and `as_completed`-- instead, if the timeout occurs the `wait`returns all tasks done and all tasks that are still pending up to that point when the timeout occurred.

Fore, examine a case where two requests complete quickly and one tkes a few seconds, just use a timeout of 1 sec with `wait`to understand what happens when have tasks that take longer then the timeout. For the `return_when`, use the default value of `ALL_COMPLETED` like:

```py
@async_timed()
async def main():
    async with aiohttp.ClientSession() as session:
        url = 'https://www.baidu.com'
        fetchers = [asyncio.create_task(fetch_status(session, url)),
                    asyncio.create_task(fetch_status(session, url)),
                    asyncio.create_task(fetch_status(session, url, delay=3))]
        done, pending= await asyncio.wait(fetchers, timeout=1)
        print(f'done task count: {len(done)}')
        print(f'Pending task count: {len(pending)}')
        for dt in done:
            result = await dt
            print(result)
            
asyncio.run(main())
```

Runing this, our `wait`call will return our `done`and `pending`sets after 1s-- In the `done`set see our two fast requests, as they finished within 1s -- our slow reuest is still running -- in the `pending`set. our tasks in the `pending`are not canceled and will continue to run despite the timeout.

### Why wrap everything in a task - 

Let's see what happens if we implementing this **withoug** wrapping the requests in tasks -- like:

```py
async def main():
    async with aiohttp.ClientSession() as session:
        api_a = fetch_status(session, 'https://www.baidu.com')
        api_b = fetch_status(session, 'https://www.baidu.com', delay=2)

        done, pending = await asyncio.wait([api_a, api_b], timeout=1)
        for task in pending:
            if task is api_b:
                print('API B just too slow, cancelling')
                task.cancel()


```

Expect for this code to print out B is too slow... But this can happen cuz when call `wait`with just coroutines they are just automatically wrapped in tasks. For new pythong, it can't permit directly use `coroutine`.

### Sorting a DataFrame

Can sort a `DataFrame`by one or more columns by using the `sort_values`method.

`nba.sort_values('Name')`, or `nba.sort_values(by='Name')`And the `sort_values`method's `ascending`parameter determine the sort order, it has a default argument of `True`, by defautl pandas will sort a column of numbers in increasing order, a column of strings in alphabetical order. like:

```py
nba.sort_values('Name', ascending=False).head()
```

And here is another -- what if we want to find the 5 youngest players in `nba`without using the `nsmallest`method -- could sort the `Birthday`column in reverse order by  using the `sort_values`method with ascending set to `False`.

`nba.sort_values('Birthday', ascending=False).head()`

## Creating the Data Source

The data source provides the application with the data -- and the most common type of data source uses HTTP to request data from a web service -- Need something simpler that can just reset to a known state each time the application is started to ensure that you get the expected results from the examples.

Then the final step is to complete simle model is to ddfine a repository that will provde access to data from the data source and allow it to be manipuated in the app.

And the `Model`class just defines a ctor that gets the initial data from the data source class and provides access to it through a set of methods -- these methods are typical of those defined by a repository and are described:

There are just two main considerations when writing a repository for model data -- the first is that it should present the data in the model in a form that can be iterated -- this is just important cuz the iteration can happen often. The other operations of the `Model`class are inefficient.

The second consideration is being able to present unchanged data for Ng to work with -- It just means that the `getProducts`method should return the same object when it is called multiple times unless one of the other methods or another part of the application has made a change to a data that the `getProducts()`method provides.

### Creating a Component and template

Templates contain the HTML content that a component wants to present to the user. Templates can range from a single HTML to a complex block of content.

```tsx
@Component({
  selector:"app",
  templateUrl:"template.html"
})export class ProductComponent{
  model:Model= new Model();
}
```

```html
<div class="bg-info text-white p-2">
  There are {{model.getProducts().length}} products in the model
</div>
```

The `@Component`decorator configures the component. The `selector`specifies the HTML element that the directie will be applied to, which is `app`-- the `templateUrl`prop in the `@Component`directive specifies the content that will be used as the contents of the `app`element.

For the component class, `ProductComponent`-- is responsible for providing the template with the data and logic needed for its bindings -- the class defines a single prop, `model`-- provides access to a `Model`object.

Then:

### Configuring the root Module

The component that created in the -- won’t be part of the app until register it with the root Angular module -- used the `import`keyword to import the component, and used the `@ngModule`configuration properties to register the component.

```tsx
@NgModule({
  declarations: [
    ProductComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule
  ],
  providers: [],
  bootstrap: [ProductComponent]
})
export class AppModule { }
```

Used the name `ProductComponent`in the `import`statement, and added this name to the `declarations`array, which configures the set of components and other features in the application, also changed the value of the `bootstrap`prop so that the new component is the one that is used when the applications starts.

## Using Data Bindings

The example contains a simple template that was displayed to the user and that contained a data binding that showed how many objects were in the data model.

- R expressions embedded into templates and are evaluated to produce dynamic content in the HTML.
- Provide link between the HTML elements in the HTML document and in template files with the data and code in the application.
- Data bindings are applied as attribute on HTML elements or as special seqs of characters in strings.
- Data bindings contain simple Js expressions that are evaluated to generate content. The main pitfall is including too much logic in a binding cuz such logic cannot be properly tested or used elsewhere in the app. Data binding expressions should be as imple as possible and rely on components.

```tsx
getClasses(): string {
    return this.model.getProducts().length == 5 ? 'bg-success' : 'bg-warning';
}
```

### Understanding One-way Data Bindings

One-way data bindings are used to generate content for the user and are the basic feature used in Ng templates -- the term *one-way* to the fact the data flows in one direction -- meaning the data flows *from* the component to the data binding so that it can be displayed in a template.

```html
<div class="text-white p-2" [ngClass]="getClasses()">
  Hello
</div>
```

- `div`is the *host element* -- that the binding will affect, by changing its appearance, or behavior.
- The `[]`tell Ng that this is a one-way data binding, when Ng sees `[]`in a data binding, will evaluate the expression and pass the result to the binding’s *target* so that can modify the host element.
- And the `target` in the exmaple, is `ngClass`-- specifies what the binding will do. There are two different types of target a *driective* or *property binding*.
- The *expression* is a fragment of js that is evaluated using the template’s component to provide context, meaning that the componnet’s property and methods can be included in the expression.

For this, the `div`meaning that it’s the element that the binding is intened to modify. The expression invokes the component’s `getClasses()`method, which was defined at the start of the chapter-- this method returns a string containing a Bootstrap class based on the number of objects in the data model.

The target for the data binding is a *directive* -- is just a class that is specially written to support a data binding. Ng comes with some useful built-in directives, and can create your own to provide custom functionality -- the names of the built-in directives start with `ng`tells you that the `ngClass`target target is one of the *built-in* diriectives. And the target usually gives an indication of what the directive does, and as its name suggests, the `ngClass`directive will add or remove the host element from the class or classes whose names are returned when the expression is evaluated.

Putting it all together, the data binding will add the `div`element to the `bg-success`or `bg-warning`classes based on the number of items in the data model.

# Understanding the binding Target

When Ng processes the target of a data binding -- it starts by checking to see whether it matches a directive -- Most applications will rely on a mix of the built-in directives provided by Ng and custom directives that provide app-sepecific features. Can usually tell when a directive is the target of a data binding cuz the name will be distinctive and give some indication of what the directive is for.

The built-in directives can be just recognized by the `ng`prefix -- the binding gives you a hint that the target is a built-in directive that is just related to the class membership of the host element. like:

- `ngClass`-- used to assign host elements to classes
- `ngStyle`-- used to set individual styles 
- `ngIf`-- used to insert content in the HTML document when its expression evalates as `true`.
- `ngFor`-- Inserts the same content into the HTML document for each item in a data source.
- `ngSwitch, ngSwitchCase, ngSwitchDefault`-- swith case
- `ngTemplateOutlet`-- used to repeat a block of content

### Understanding the property Bindings

If the binding target doesn’t correspond to a directive, then Ng checks to see whether the target can be used to create a prop binding -- there are 5 different types of property bindings, which are listed -- 

- `[property]`-- std property binding -- used to set a prop on the Js object that represents the host element in the DOM.
- `[attr.name]`-- which is used to set the value of attributes on the host HTML element for which there are no DOM properties.
- `[class.name]`-- Speical class prop binding, which is used to configure class membership of the host element.
- `[style.name]`-- Speical style prop binding -- used to configure style settings of the host element.

### Understanding the Expression

The expression in a data binding is a fragment of Js code that is evaluated to provide a value for the target -- the expression has access to the properties and methods defined by the component, which is how the binding can invoke the `getClasses()`to provide the `ngClass`directive with the name of the class that the host element should be added to. Can also perform most std Js operations -- like:

```html
<div [ngClass]="'text-white p-2 ' + getClasses()">
  Hello
</div>
```

The expression is just enclosed in double quotes, which means that the string literatl has to be defined using single quotes -- The js concatenation operator is the + character. So it is just easy to get carried away when writing expressions and include complex logic in the template.

### Understanding the brakets

Tell Ng that this is a one-way data binding that has an expression that should be evaluated. Ng will still process the binding if you omit the brackets and the target is directie -- but the expression won’t be evaluated-- and the content between the quote characters will be passed to the directive a literal value.

```html
<div ngClass="'text-white p-2' + getClasses()">
  World
</div>
```

If examine the class -- just like `class="'text-white p-2 '+ getClasses()"`, so the browser will try to just process the classes to which the host element has been assigned -- but the element’s appearance won’t be as expected since the classes won’t correspond to the names used by Bootstrap.

- `[target]="expr"`-- The `[]`indicates a one-way databinding flows from the expression to the target-- the different forms of this type of binding are the topic of this.
- `{{expression}}` -- string interpolation binding -- which is described in the section.
- `(target)="expr"`-- round indicates a onew-way data flows from the target to the destination.
- `[(target)]="expr"`-- banana-in-a box -- indicates a two-way binding, data flows just in both directions.

Understanding the host element -- The host element is the simplest part of the data binding -- just can be applied to any HTML element in a tempalte, and an element can have multiple bindings, each of which can manage a different aspect of the element’s appearnace or behavior.

### Using the Std Property and Attribute bindings

If the target of a binding doesn’t match a directive, Ng will try to apply a property binding -- The browser uses the DOM to represent the HTML -- each in the HTML, including HOST element is represented using a JS object in the DOM. Just like all Js objects, the ones used to represent HTML elements have properties -- These properties are used to manage the state of the element so that the `value`prop-- used to set the contents of the `input`.fore.

```html
<div class="mb-3">
  <label class="form-label">Name:</label>
  <input class="form-control" [value]="model.getProduct(1)?.name ?? 'None'" />
</div>
```

And the new binding in this example specifies that the `value`prop should be bound to the result of an expression that calls a method on the data model to retrieve a data object from the repository by specifying a key. For this, if the result from the method is just `null`, then the `name`property won’t be read, note that.

### Using the string Interpolation binding

Ng provides a special version of the std prop binding -- known *string interpolation binding* -- that is used to include expression results in the text content of the host elements. Just like:

```html
<div [ngClass]="'text-white p-2 ' + getClasses()"
  [textContent]="'Name: ' + (model.getProduct(1)?.name ?? 'None')">
</div>
```

The problem becomes just worse for more complex bindings, where multiple dynamic values are interpersed among blocks of static content.

```html
<div [ngClass]="'text-white p-2 ' + getClasses()">
  Name: {{model.getProduct(1)?.name ?? 'None'}}
</div>
```

So the string interpolation binding is just denoted using pairs of `{{}}`

### Using Attribute Binding

There are some oddities in the HTML and DOM specifications that mean that not all HTML element attributes have equivalent props in the DOM API. For these, Ng provides the *attribute binding* -- which is used to set an attribute on the host element -- For the most use case, like `colspan`, which is used to set the number of columns that a `td`element wil occupy like:

```html
<table class="table mt-2">
  <tr>
    <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>
  </tr>
  <tr>
    <td [attr.colspan]="model.getProducts().length">
      {{model.getProduct(1)?.name ?? 'None'}}
    </td>
  </tr>
</table>
```

### Setting classes and Styles

Ng provides special support in property bindings for assignment the host element to classes and for configuring individual style properties -- like:

There are 3 different ways in which U can use data bindings to manage the class memberships of an element -- The std property binding, the special class binding -- and the `ngClass`directive -- all three are like:

- `<div [class]="expr">`-- evaluates the expression and uses the result to *replace* any existing class memberships.
- `<div [class.myClass]="expr">`-- uses the result to set the membership of `myClass`
- `<div [ngClass]="map">`-- sets class membership of mutiple classes using map object.

### Setting all of the element’s Classes with the STD binding

The STD property binding can be used to set all of the element’s classes in a single step -- which is useufl when you have a method or property in the component that returns all of the classes to which an element should belong in a single string, with the names separated by spaces -- like:

```tsx
getClasses(key: number): string {
    let product = this.model.getProduct(key);
    return "p-2 " + ((product?.price ?? 0) < 50 ? "bg-info" : "bg-warning");
                     }
```

```html
<div class="text-white">
  <div [class]="getClasses(1)">
    The first product is {{model.getProduct(1)?.name}}
  </div>
  <div [class]="getClasses(2)">
    The second product is {{model.getProduct(2)?.name}}
  </div>
</div>
```

When the std property binding is used to set the `class`property, the result of the expression replaces any previous class that an element belonged to, which means that it can be used only when the binding expression returns all the classes that are reqiured.

### Setting Individual Classes using the Speical Class binding

The special class binding provides finer-grained control than the std property binding and allows membership of a single class to be manged using an expression. This is just useful if you want to build on the existing class memberships of an element.

```html
<div class="p-2"
     [class.bg-success]="(model.getProduct(2)?.price??0)<50"
     [class.bg-info]="(model.getProduct(2)?.price??0)>=50">
    The second product is {{model.getProduct(2)?.name}}
</div>
```

So the special class binding is specified with a taret that combines the term `class`-- followed by a period, followed by the name of the class whose membership is being managed.

The special class binding will add the host elemetn to the specified class if the result of the expression is *truthy* -- in this, the host element will be a member of the `bg-success`class if the `price`property is less than 50.

### Setting Classes using the `ngClass`directive

The `ngClass`is a more flexible alternative to the std special prop bindings and behaves differently based on the type of data that is returned by the expression. like:

- `String`-- is added to the classes specified by the string, multiple classes are separated by spaces.
- `Array`-- each object in the array is the name of a class that the host element will be added to
- `Object`-- each of the object is the name of none or more classes separated by spaces. The host will be added to the class if the value of the prop is truthy.

```tsx
getClassMap(key: number): Object {
    let product = this.model.getProduct(key);
    return {
        'text-center bg-danger': product?.name == 'Kayak',
        'bg-info': (product?.price ?? 0) < 50,
                    };
}
```

So the `getClassMap()`returns an `object`with properties whose values are one or more class names, with values based on the property values of `Product`object whose key is specified as the method argument. In the view:

```html
<div class="text-white">
  <div class="p-2" [ngClass]="getClassMap(1)">
    The first product is {{model.getProduct(1)?.name}}
  </div>
  <div class="p-2" [ngClass]="getClassMap(2)">
    The second product is {{model.getProduct(2)?.name}}
  </div>

  <div class="p-2" [ngClass]="{'bg-success': (model.getProduct(3)?.price??0)<50,
  'bg-info': (model.getProduct(3)?.price??0)>=50}">
    The third product is {{model.getProduct(3)?.name}}
  </div>
</div>
```

### Using the Style bindings

There are three different ways in which you can use data bindings to set style properties of the host element , The std property binding, the special style binding, and the `ngStyle`directive -- all three are described like:

- `<div [style.myStyle]="expr">`-- std property binding, which is used to set a single prop to the result of the expression.
- `<div [style.myStyle.units]="expr">`-- this just special style binding, which allows the units for the style value to be speicied as part of the target.
- `<div [ngStyle]="map">`-- sets multiple style props using the data in map object.

Setting the single style property -- the std property binding and the special bindings are used to set the value of a single style property -- the difference between these bindings is that the std property binding must include the units required for the style -- while the special binding allows for the units to be just included in the binding target.

```ts
  fontSizeWithUnits="30px";
  fontSizeWithoutUnits= "30";
```

So can using these in the view like:

```html
<div class="text-white">
  <div class="p-2 bg-warning">
    The <span [style.font-size]="fontSizeWithUnits">First</span>
    product is {{model.getProduct(1)?.name}}
  </div>
  <div class="p-2 bg-info">
    The <span [style.font-size.px]="fontSizeWithoutUnits">Second</span>
    product is {{model.getProduct(2)?.name}}
  </div>
</div>

```

So the target for the binding is `style.fontSize`which sets the size of the font used for the host element’s content, the expression for this binding uses the `fontSizeWithUnits`prop, whose value includes the units, `px`.

### Setting Styles using the `ngStyle`directive

The `ngStyle`allows multiple style properties to be set using a map object.

```ts
getStyles(key: number) {
    let product = this.model.getProduct(key);
    return {
        fontSize: "30px",
        "margin.px": 100,
        color: (product?.price ?? 0) > 50 ? "red" : "green",
                };
}
```

So the object just returned by the `getStyle`method shows the `ngStyle`directive is able to support both the formats that can be used with property bindings, including either the units in the value or the property name.

```html
<div class="p-2 bg-info">
    The <span [ngStyle]="getStyles(2)">Second</span>
    product is {{model.getProduct(2)?.name}}
</div>
```

### Updating the data in the application

When start out with Ng, can seem lke a lot of effort to deal with data bindings, -- remebmering which binding is required in different situations -- Bindings are worth understanding *cuz their expressions are re-evaluated when the data they depend on changes*.

## Discovering Child elments using the Selectors API

There are two selector query API methods -- `querySelectorAll()`, and `querySelector()`-- the difference . Use the `classList`property of an element to add...

```js
const element = document.getElementById('exmaple-element');
element.classList.add('new-class');
element.classList.remove('existing-class');
element.classList.toggle('toggle-me');
```

And using `classList`allows U to easily manipulate the class properties of a slected element -- can come in handy for updating or swapping styles without using inline CSS. like:

```js
if(element.classList.contains('new-class')){
    element.classList.remove('new-class')
}
```

Also possible to add, remove, or toggle multiple classes either by passing them each as individual props or using a spread operator -- like:

`.classList.add('my-class', 'another-class')`

```js
const classes = ['my-class', 'another-class'];
div.classList.remove(...classes);
```

### Setting an element’s Style attribute

Want to directly add or replace an inline style on a specified element -- To change one CSS prop as an inline style, modify the property value via the element’s `sytle`prop -- like:

`elem.style.backgroundColor='red';`

And, to modify one or more CSS properties for a single element, can use `setAttriute()`and create an entire CSS.

```js
elem.setAttribute('style',
    'background-color:red; color:white; border: 1px solid black');
```

These techniques set an inline style value for the HTML element, which will appear within the HTML itself, like:

```js
const card = document.getElementById('card');
card.setAttribute(
    'style',
    'backgournd-color: #ecf0f1, color: #2c3e50'
);
```

So, an element’s CSS properties can be modified in the JS using one of the three apporaches -- as the solution demonstrates, the simplest approach is to set the property’s vlaue directly using the element’s `style`prop just like:

`elem.style.width='500px'`

If contains a hyphen -- just as `font-family`.. use the `camelCase`like:

`elem.style.fontFamily='curier'`

Can also use the `setAttribute()`method.

### Accessing an existing Style setting

For the most part, accesing existing attribute value is as easy as setting them -- just using the `getAttriute()`like:

`const className= elem.getAttribute('class')`

Cuz a speciifc element’s style settings at any one time is composite of all settings merged into a whole -- this *computed style* for an element is what you are most likely interested in when you want to see specific style settings for the element at any point in time.

`const style =window.getComputedStyle(elem);`

### Advanced

Rather then using `setAttribute()`-- can create an attriute and attach it to the element using the `createAttriute()`method to create an **`Attr`node**. like:

```js
const styleAttr = document.createAttribute('style');
styleAttr.nodeValue = 'background-color:red';
element.setAttribute(styleAttr);
```

And, can add any number of attributes to an element using either `createAttribute()`and `setAttriute()`. If the attribute value is going to be another entity reference, as is allowed with XML, you will need to use this.

### Adding Text to new P

Just using the `createTextNode`to add text to an element -- like:

```js
const newP = document.createElement('p');
const text = document.createTextNode('new paragraph content');
newP.appendChild(text);
```

So the text within an element is-- itself, an object within the DOM -- its type is just a `Text`node, created using a specialized method -- `creteTextNode()`-- the method takes one parameter -- contianing text.

### inserting a new Element in a speicifc DOM Location

Want to insert a new p just before the 3rd paragraph in a `div`. to get all the fore use the `createElement`and the `insertBefore`DOM methods to add a new p just before the existing 3rd p.

```js
const div = document.getElementById('target');
const paras = div.getElementsByTagName('p');
const newPara = document.createElement('p');
const text = document.createTextNode('new p');
newPara.appendChild(text);

if (paras[2]) {
    div.insertBefore(newPara, para[2]);
} else {
    div.appendChild(newPara);
}
```

### Checking a Checkbox

need to verify that a user has checked a checkbox in application -- 

Select the checkbox element and validate the status with the `checked`prop. like:

```js
const checkBox = document.getElementById('check');
const validate = () => {
    if (checkBox.checked) {
        console.log('Checkbox is just checked');
    } else {
        console.log('not checked');
    }
}

checkBox.addEventListener('click', validate);
```

As a common pattern is for a user to be presented with a checkbox to make some sort of acknowledgement - such as accepting terms of service. It is common to disable a button unless the user has checked the checkbox, can modify the previous example to add this:

```js
const acceptButton = document.getElementById('accept');
const validate = () => {
    if (checkBox.checked) {
        acceptButton.disabled = false;
    } else {
        acceptButton.disabled = true;
    }
}
```

### Adding up values in HTML table

Just travse the table column containing numeric string values, converts the values to the numbers just like:

```js
let sum = 0;
const cells = document.querySelectorAll('td:nth-of-type(2)'); // all second cells
cells.forEach(cell => {
    sum += parseFloat(cell.firstChild.data);
});
```

The `:nth-of-type(n)`selector matches the specific `child(n)`of an element -- by using this, we are selecting the second `td`child element, in the example HTML markup, the second `td`element in the tble is a numeric value like:

```html
<body>
    <h1>adding up valus in HTML table</h1>
    <table id="table1">
        <tr>
            <td>Washington</td><td>145</td>
        </tr>
        <tr>
            <td>Orgeon</td><td>233</td>
        </tr>
        <tr>
            <td>Missouri</td><td>833</td>
        </tr>
    </table>

    <script>
        let sum =0;
        const cells= document.querySelectorAll('td:nth-of-type(2)');
        
        for(let cell of Array.from(cells)){
            sum+= parseFloat(cell.firstChild.data);
        }

        const newRow = document.createElement('tr');

        const firstCell = document.createElement('td');
        const firstCellText= document.createTextNode('sum:');
        firstCell.appendChild(firstCellText);
        newRow.appendChild(firstCell);

        const secondCell = document.createElement('td');
        const secondCellText= document.createTextNode(sum);
        secondCell.appendChild(secondCellText);
        newRow.appendChild(secondCell);

        document.getElementById('table1').appendChild(newRow);
    </script>
</body>
```

### Deleting rows from an HTML table

Want to remove one or more rows from an HTML table. Using the `removeChild()`method on an HTML table row, and all of the child elements, including the row cells like:

```js
const parent= row.parentNode;
const oldrow= parent.removeChild(parent);
```

Note, when remove an element from a web element, not only removing the element, are removing all of tis child elements like;

```html
<body>
    <h1>Deleting rows from an HTML table</h1>
    <table id="mixed">
        <tr>
            <td>Value One</td>
            <td>Value two</td>
            <td>Value three</td>
        </tr>
    </table>

    <div id="result"></div>

    <script>
        const values = [
            [123.45, 'apple', true],
            [65, 'banana', false],
            [1034.99, 'cherry', false],
        ];
        const mixed = document.getElementById('mixed');
        const tbody = document.createElement('tbody');

        function pruneRow() {
            const parent = this.parentNode;
            const oldRow = parent.removeChild(this);

            let dataString = '';
            oldRow.childNodes.forEach(row => {
                dataString += `${row.firstChild.data}`;
            });

            const msg = document.createTextNode(`rmoved ${dataString}`);
            const p = document.createElement('p');
            p.appendChild(msg);
            document.getElementById('result').appendChild(p);
        }

        values.forEach(value => {
            const tr = document.createElement('tr');
            value.forEach(cell => {
                const td = document.createElement('td');
                const txt = document.createTextNode(cell);
                td.appendChild(txt);
                td.appendChild(txt);
                tr.appendChild(td);
            });

            tr.onclick = pruneRow;

            tbody.appendChild(tr);
            mixed.appendChild(tbody);
        });
    </script>
</body>
```

### Hiding Page sections

Want to hide an existing page element and its children until needed, just can use the CSS `visibility`prop like:

`msg.style.hidden='visible'; msg.style.hidden='hidden'`

Or can just use the CSS `display`like:

`msg.style.display='block'; msg.style.display='none';`

Just note that the `visibiity`prop controls the element’s *visual rendering*. but its presence also affects other elements -- when an element is hidden, still takes up page space. But for the display, removes the element completely from the page layout.

- `block`-- when display is set to this, the element is treated like a `block`element, with a line break before and after
- `inline-block`-- the contents are formatted like a block, but then flowed like inline.

## Generics

All the type syntaxes you’ve learned about so far are meant to be used with types that are just completely known when they are being written, sometimes, however, a piece of code may be intended to work with various different types dpending on how its called -- Take this `identity`function in the js meant to receive an input of any possible type and return that same input as output. 

Given that `input`is allowed to be any input, need a way to say that there is a rel between the `input`type and the type the function returns -- ts captures rels between types using *generics*.

In ts, constructs such as functions may delcare just any number of generic type parameters -- types that are determined for each usage of the generic construct.

### Generic Functions

A function may be made generic by placing an alias for a type parameter, wrapped in angle brackets, immediately before the parameters partheses -- that type parameter will then be available for usage in parameter type annotations, return type annotations, and type annotations inside the function’s body. like:

```tsx
function identity<T>(input: T){
    return input;
}
// Arrow also can be generic like:
const identity = <T>(input: T)=> input;
```

### Explicit generic Call types

Most of the time when calling generic functions, Ts will e able to infer type arguments based on how the function is being called. Tsx’s type checker used an arg provided to `identity`infer the corresponding function parameter’s type argument.

Unfortunately, as with class members and variable types -- sometimes there isn’t just enough info from a function’s call to inform Ts what its type argument should resolve to. This will commonly happen if generic construct is provided another generic construct whose type args aren’t known.

So, TS will default to assuming the `unknown`type for any type arg it cannot infer.

```tsx
function logWrapper<Input>(callback: (input:Input) => void) {
    return (input: Input) => {
        console.log("Input:", input);
        callback(input);
    };
}

logWrapper((input: string) => {
    console.log(input.length); // ok
});

logWrapper(input => {
    console.log(input.length); // error, length does not exist
})
```

So, to avoid defaulting to `unknown`, functions may be called with an explicit generic type arg that explicitly tells Ts what that type arg should be instead. Ts will perform type checking on the generic call to make sure the parameter being requested matchs up what’s provided as a type argument. Can just like:

```tsx
logWrapper < string > (input => {
    console.log(input.length); // ok
});
logWrapper<string>((input: boolean) => {...}) // error
```

So, much like explicit type annotations on variables, explicit type arguments may always be specified on a generic function but often aren’t necessary.

### Multiple Function type Parameters

Functions may define any number of type parmeters -- separted by commas -- Each call of the generic function may resolve its own set of values for each of the type parameters --  fore, 

```tsx
function makeTuple<First, Second>(first: First, second: Second) {
    return [first, second] as const;
}

let tuple = makeTuple(true, 'abc');
```

And, note that if a function declares multipe type parameters, calls to that function must explicitly declare either none of the generic types or all of them. Ts doesn’t yet support inefrring only some of types of generic call like: Here the `makePair`also takes in two type paameters -- like:

```ts
function makePair<Key, Value>(key: Key, value: Value) {
    return { key, value };
}
makePair<string>('abc', 123); // error
```

### Generic Interfaces

Interfaecs may be declared as generic as well. The follow similar generic rules to functions. they may have any number of type parameters declared between a < and > after the name. like:

```ts
interface Box<T> {
    insider: T;
}
let stringBox: Box<string> = {
    insider: 'abc', // ok
};
let incorrectBox: Box<number> = {
    insider: false, // error
}
```

Note that the built-in `Array`methods are defined in Tsx as a generic interface -- `Array`uses a type parameter `T`to respresent the type of data stored within an array. just like:

```ts
interface Array<T> {
    pop(): T | undefined;
    push(...items: T[]):number;
}
```

### Inferred Generic Interface Types

As with generic functions, generic interface type arguments may be inferred from usage. Ts will do its best to infer type arguments from the types of values provided to a location declared as taking a generic type. Fore, the `getLast()`declares a type parameter `Value`that then used for its `node`parameter, Ts can then infer `Value`based on the type of whatever value is passed in as an argument.

```ts
interface LinkedNode<Value> {
    next?: LinkedNode<Value>;
    value: Value;
}

function getLast<Value>(node: LinkedNode<Value>): Value {
    return node.next ? getLast(node.next) : node.value;
}

// inferred value type argument for Date
let lastDate = getLast({
    value: new Date("09-13-1993"),  // for Date
});

let lastFruit = getLast({
    next: {
        value: "banana",   // for string
    },
    value: "apple",
});
```

### Generic Classes

Classes, like interfaces, can also declare any number of type parameters to be later used on members. Each instance of the class may have a different set of type arguments for its type parameter.Fore, the `Secret`:

```ts
class Secret<Key, Value>{
    key: Key;
    value: Value;

    constructor(key: Key, value: Value) {
        this.key = key;
        this.value = value;
    }

    getValue(key: Key): Value | undefined {
        return this.key === key ? this.value : undefined;
    }
}
```

### Explicit Generic Class Types

Instantiating generic classes goes by the same type args inference rules as calling generic functions -- If the type arg can be inferred from the type of a parameter to the class ctor, such as .. -- Ts will use the inferred type. Otherwise, if a class type arg can’t be inferred from the arguments passed to its ctor, the type arg will deault to `unknown`.

```ts
class CurriedCallback<Input> {
    #callback: (input: Input) => void;

    constructor(callback: (input: Input) => void) {
        this.#callback = (input: Input) => {
            console.log("Input", input);
            callback(input);
        };
    }
    call(input: Input) {
        this.#callback(input);
    }
}

new CurriedCallback<string>(input => {
    console.log(input.length); //ok
}).call("abcd");
```

### Extending generic Classes

Generic classes can be also used as the base class following an `extends`keyword - ts wil not attempt to infer type arguments for the base class from the usage. like;

```ts
class Quote<T>{
    lines: T;
    constructor(lines: T) {
        this.lines = lines;
    }
}

class SpokeQuote extends Quote<string[]> {
    speak() {
        console.log(this.lines.join("\n"));
    }
}

new SpokeQuote([
    "grade", "It's good"
]).lines;  // type: string[]
```

And, also, generic derived classes can alternately pass their own type argument through their base class, the type names don’t have to match -- just for fun -- this `AttriuteQuote`passes  differently named `Value`type arg to the base class like:

```ts
class AttributeQuote<Value> extends Quote<Value> {
    speaker: string;
    constructor(value: Value, speaker: string) {
        super(value);
        this.speaker = speaker;
    }
}

new AttributeQuote(
    "I am bender", "please insert the gender"
);
```

