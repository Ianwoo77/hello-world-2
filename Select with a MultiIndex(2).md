# Select with a MultiIndex(2)

To extract mulitile `DataFrame`columns, need to pas the square brackets a list of tuples, each tuple should specify the level values for one column. The order of tuples within the list sets the order of columns in the resulting `DataFrame`.

`neighborhoods[[('Services', 'Schools'), ('Culture', 'Museums')]]`

This syntax tends to become confusing and error-prone when it involves multiple parentheses and brackets. We can just simplify like:

```py
columns = [('Services', 'Schools'), ('Culture', 'Museums')]
neighborhoods[columns]
```

### Extracting one or more with `loc`and `iloc`

`neighborhoods.loc[('TX', 'Kingchester', '534 Gordon Falls')]`

Returns a `Series` if: `neighborhoods.loc['CA']`-- returns a DF with the two level of `MultiIndex`object. And usually the second argument to the square brackets denotes the columns we'd like to extact, can also provide the value to look for in the next `MultiIndex`level. like: `neighborhoods.loc[('CA', 'Dustinmouth')]`, And can still use the second arg to `loc`to declare the column(s) to extract. just like: `neighborhoods.loc['CA', 'Culture']`

The next pulls out the `Services`columns for the same state of `CA`and services like:

`neighborhoods.loc[('CA', 'Dustinmouth'), 'Services']`

And the placement of `Services`and `Schools`in a single tuple tells pandas to view them as component that makeup a single lable. like: `neighborhoods.loc[('CA', 'Dustinmouth'), ('Services', 'Schools')]`

When select seq row -- can use py's slicing syntax -- place a colon between the starting and ending point like:

`neighborhoods.loc['NE':'NH']`, or not loc used.

Can combine list-slicing syntax with tuple arguments like:

`neighborhoods.loc[('NE', 'Shawnchester'):('NH', 'North Latoya')]`

Can do not have to provide each tuple values for each level. like: `neighborhoods.loc[('NE', 'Shawnchester'):'NH']`

Can pull out multiple rows by wrapping their index positions in a list like:

```py
neighborhoods.loc[['NE', 'NH']]
neighborhoods.iloc[[25,30]]
```

Column slicing follows the same principles, the next example pulls the columns rom index position 1 to 3. like:

`neighborhoods.iloc[25:30, 1:3]`

### Cross-Sections

The `xs`method allows us to extract rows by providing a value for one `MultiIndex`level. Pass the method a `key`paameter with the value to look frol. pass level either the numeric or the name of the index level in whcih to look for the value. like:

`neighborhoods.xs(key='OR', level=0)` # or level='State'

Can also apply the same extraction techniques to columns by passing the `axis`parameter an argument of *columns*.

`neighborhoods.xs(axis='columns', key='Museums', level='Subcategory').head()`

Can also procide with nonconsecutive `MultiIndex`lelvels like:

```py
neighborhoods.xs(
    key=('AK', '238 Andrew Rue'), level=['State', 'Street']
)
```

### Manipulating the Index

The `reorder_levels()`method arranges the `MultiIndex`levels in a specified order.  We pass its `order`parameter a list of levels in a desired order like:

```py
new_order=['City', 'State', 'Street']
neighborhoods.reorder_levels(order=new_order).head()
```

Can also pass the `order`parameter in a list of integers. like:

`neighborhoods.reorder_levels(order=[0,1,2]).head()`

The `reset_index()`returns a new `DataFrame`that integrates the former `MultiIndex`levels **as columns**. like:

`neighborhoods.reset_index()` -- notice that the 3 new columns become values in Category. Can add the 3 columns to an alternate `MultiIndex`level -- pass the desired level's index positoin or name to the `reset_index`method's `col_level`parameter like:

`neighborhoods.reset_index(col_level=1).tail()`

Can fill the primary column name like: `neighborhoods.reset_index(col_level=1, col_fill='Address').tail()`

And the std invocation of `reset_index`transforms all index levels into regular columns, can also move a single index level by passing its name to the `levels`parameter. `neighborhoods.reset_index(level='Street').head()` Then can move multiple index levels by passing them in a list like:

`neighborhoods.reset_index(level=['Street', 'City']).head()`

And can remove a level from the `MultiIndex`, if pass the `reset_index`'s `drop`parameter a value of `True`, pandas will delete the specified level instead of adding it to the column.

`neighborhoods.reset_index(level='Street', drop=True)`

### Setting the index

`neighborhoods.set_index(keys='City').head()`

Can also provide a list of keys like:

`neighborhoods.set_index(keys=('Culture', 'Museums')).head()` # must be a tuple need to note. To create a `MultiIndex`on the row axis, can pass a list with multiple columns to the keys parameter like:

`neighborhoods.set_index(keys=['State', 'City']).head()`

### Coding challenge

Just add a `MultiIndex`to the new DF, can begin by identifying the number of unique values like: Can use the `investments.nunique()`method to find good candidates for index levels -- fore, 3-level with the :

```py
investments =\
    investments.set_index(keys=['Status', 'Funding Rounds', 'State']).sort_index()
```

1. Extract all rows with a status of `closed`, can use the `loc`accessors like:
   `investments.loc[('Closed')].head()`

2. pull out rows that fit two conditions -- a status value of `Acquired`and a value of 10 like:
   `investments.loc[('Acquired', 10)]`

3. same solution that used for preceding two problems -- like:
   `investments.loc[('Operating', 6, 'NJ')]`

4. To extract DF columns, pass a second argument to the `loc`accessor like:
   `investments.loc[('Closed', 8), 'Name']`

5. Extracting rows with a value of `NJ`in the State level like:
   `investments.xs(key='NJ', level=2).head()` # or level='State'

6. Finally, want to add the `MultiIndex`levels back to the DF as columns like:

   `investments.reset_index(inplace=True)`

## Reshaping and pivoting

Sometimes, issues are confined to a specific column, row, or cess. Fore, a Column may have the wrong data type, mising valus, or a cell may have incorrect character casing.. So *Reshaping* a data set means manipulaing it into a different shape, one that tells a story that could not be gleaned from its original presentation. Reshaping offers a new view or perspective on the data. This skill in DF is critical -- 80% of data analysis consists of cleaning up data and controting it into the proper shape.

1. how to summarize a larger data set in a concise pivot table.
2. Proceed in the opposite direction, how to spit an aggregated data set.

### Wide vs narrow

A narrow is also called a *long* or a *tall* data set. These names refelect the direction in which the data set expands as we add more values to it. A *wide* increases in width, it grows out. A wide data set expanda horizontally. A wide data is ideal for seeing the aggregate picture -- the complete story. Suppose that wrote code to calculate the average temperature across all days.

And a narrow data set grows veritcally, a narrow format makes it easier to manipulate existing data and add new recordes. Each variable is isolated to a single column. The optimal storage format for a data set depends on the insight we are trying to glean from it.

### Creating a pivot table from a DataFrame

Convert the strings in the data column to datetime objects with the `parse_dates`parameter like:

```py
sales= pd.read_csv(
    '../pandas-in-action/chapter_08_reshaping_and_pivoting/sales_by_employee.csv',
    parse_dates=['Date']
)
```

### The pivot_table method

Th pivot table aggregates a column's values and groups the results by *using other column's values*. The word *aggregate* describes a summary computation that involves multiple values -- include average, sum, median, and count.

As always, an example proves to the most helpful -- tackle challenge -- Multiple salesmen closed deals on the same date -- the same salesman closed multiple deals on the same date. -- follow 4 steps to create a pivot table like:

1. Select the column(s) whose vlaues we want to aggregate
2. Choose the aggreation operation to apply the columns
3. Select the column whose value will group the aggregated data into categories.
4. Determine whether to place the groups on the row axis, column axis, or both axes.

First, want to invoke the `pivot_table`method on the DataFrame -- the methos's `index`parameter accepts the column whose values will make up the pivot table's index labels. Uses the `Date`Column's avlues for the index labels of the pivot table. The Date column contains just 5 unique -- pandas will applies its default aggregation operation -- average.

`pd.pivot_table(sales, index='Date', values=['Expenses', 'Revenue'])`

The method returns a regular `DF`object, may be a bit -- but this DF is a pivot tble -- shows just the average expenses and average revenu organized by the 5 unique dates in the Date Columns.

`pd.pivot_table(sales, index='Date', values=['Expenses', 'Revenue'], aggfunc='mean')`

## When Good Ajax goes bad

parepared a slightly different observable you in `errors.js`-- this new observable still has all the requests, but they hit a different endpoint on the node server.

```ts
loadingRequestsBad$
    .pipe(
        scan(prev => prev + (100 / arrayOfRequests.length), 0)
    ).subscribe(
    percentDone => {
        progressBar.style.width = percentDone + '%';
        progressBar.innerText = Math.round(percentDone) + '%';
    },
    err => {
        console.log(err);
        msgArea.innerText = 'something went wrong, please try again';
        msgArea.style.display = 'block';
    }
)
```

Advanced Async -- In this, learn how Rx use can prevent race conditions before they have a chance to happen, the previous chapters covered areas where observables are helpful.

### The `spec`

Are to build a search box that automatically searches for the user without them needing to press the enter key. In addition, you need to avoid overloading the backend servers -- this means that the code needs to prevent unncessary requests -- 

### Preventing Race Conditions with `switchMap`

Back in the days -- a sultion might have started off based on an event listener like:

```ts
let lastestQuery;
searchBar.addEventListener('keyup', event=> {
    let searchVal= lastQuery= event.target.value;
    fetch(endpoint+searchVal)
    .then(results=>{
        if(searchVal===lasestQuery) {
            updatePage(results);
        }
    });
})
```

For the observable solution -- 

```ts
fromEvent(searchBar, 'keyup')
.pipe(
	pluck('target', 'value'),
    switchMap(query=> ajax(endpoint+searchVal))
).subscribe(results=> updatePage(results));
```

`switchMap`-- for every item, runs the inner observable witing for it to complete before sending the results downstream. There is one big exception -- if a new value arrives *before* the inner observable initiated by the preiouvs values completes, switchMap just unsubscribes from the observable request and *fires off a new one*. This means that you can implement custom unsubscribe logic for your own observables.

In the `switchMap`example -- fore, `abc`would be passed to before the `ab`is finished -- `ab`result would be thrown away with nary a care -- one way to think about this is that `switchMap`switches to the new request -- the Rx version of the typeahead has each step wrapped up in its own functional package.

Note that both the `addEventListener`and `fromEvent`snippets are missing part of the requirements -- they don’t wait for the user to stop typing before making a request -- leading a lot of unneeded request -- this is a great way to amke the backend enginerrs angry -- 

### Debounding Events

There comes a time when several events fire in a row -- don’t want to do sth on every event, when the events *stop* firing for a specified period, only want to make requests when the user stops typing. a function set up in this way is known as a *debounced* function -- to create pass a function into `debounce`, which then returns another function that just wraps the original like:

```ts
let logPause = ()=> console.log('There are a pause in the typing');
let logPauseDebounced=debouce(logPause);
input.addEventListener('keydown', logPauseDebounced);
```

```js
function debounce(fn, delay=333) {
    let time;
    return function(...args) {
        if(time){
            clearTimeout(time);
        }
        time= setTimeout(()=>fn(...args), delay);
    }
}
```

Debounce can be a bit confusing -- Throttling events -- Sometimes a debounce is more complicated than really need. The `throttle `opreator acts like a time-based filter. after it allows a value through -- it won’t allow a new value, until a present amount of time has passed, all other values are thrown away. Fore, might be building a dashboard to keep the ops folks informed about all of their systems, and the monitoring backend sends updates on CPU usage several times a second -- DOM updates a slow, update the page every .5 second like:

```ts
cpuStatusWebsocket$ 
.pipe(throttle(500))
.subscribe(...)
```

## Creating a Two-way binding on the Host element

Directives can support 2-way bindings, which means that they can use the banana-in-a-box bracket style the `ngModel`uses and can bind to a model property in both directions.

The 2-way binding features relies on a naming convention -- to demonstrate how, like:

```html
<input class="..."
       [paModel]="newProduct.name"
       (paModelChange)="newProduct.name=$event">
```

The binding whose target is `paModel`will be updated when the value of the `newProduct.name`changes, which provides a flow of data from the app to the diriective and will be used to update the content of the `input`element. and the custom event, `paModelChange`will be triggered when the user changes the content of the name `input`element and will provide a flow of data from the direction to the rest of the application.

To implement, added a file `twoway.directive.ts`to the `src/app`folder and used it to define:

```ts
export class PaModel {
    @Input("paModel")
    modelProperty : string | undefined= "";
    
    @HostBinding("value")
    fieldValue: string= "";
    
    ngOnchanges(changes: SimpleChanges) {
        let change= changes["modelProperty"];
        if(change.currentValue != this.fieldValue) {
            this.fieldValue= changes['modelProperty'].currentValue || "";
        }
    }
    
    @Output("paModelChange")
    update= new EventEmitter<string>();
    
    // first arg name of the event that will be handled by the listener
    // second arg is an array that will be used to provide the decorated methods
    // with arguments, when updateValue called, the newValue is set to the `target.value`
    @HostListener("input", ["$event.target.value"])
    updateValue(newValue: string) {
        this.fieldValue=newValue;
        this.update.emit(newValue);
    }
}
```

So the `paModelChange`event is implemented using a host listener on the `input`, which then sends an update through an output property. And the final step is to simplify the bindings and applying the banana lke:

```html
<input class="..." [(paModel)]="newProduct.name" />
```

### Exploring a Directive for use in a Template variable

Fore, used template variables to access fucntionality provided by built-in directives like:

`<form #form="ngForm" (ngSubmit)="submitForm(form)">`

Can modifies the directive from the previous section so that provides details of whether it has expanded:

```ts
@Directive({
  selector: "input[paModel]",
  exportAs:'paModel'
})
export class PaModel implements OnChanges {...
```

The `exportAs`of the `@Directive`decorator specifies a name that will be used to refer to the directive in template variables.

```html
<input class="bg-primary text-white form-control"
       [(paModel)]="newProduct.name" #paModel="paModel"/>
<div class="bg-info text-white p-1">Direction: {{paModel.direction}}</div>
```

## Creating Structural Directives

Structural directives change the layout of the HTML document by adding and removing elements. They build on the core features available fro attribute directives. With additional support for *micro-templates* -- which are just small fragments of contents defined within the templates used by components. Can recognize when a structural directives is being used cuz its name will be prefixed with an `*`.-- 

- Uses micro-templates to add content to the HTML document.
- Structural directives allow content to be added conditionally based on the result of an expression or for the same content to be repeated for each object in the data source
- Structural directives are applied to an `ng-template`element, which contains the conent and bindins that compries its micro-template. The template class ues objects provided by the ng to control the inculusion of the content or to repeat the content.
- Unless care is taken, structural diriectives can make a lot of unnecessary changes to the HTML document, whcih can ruin the performance of a web application.

Preparing the Example -- 

```html
<div class="row p-2">
  <table class="table table-sm table-bordered table-striped">
    <tr>
      <th></th>
      <th>Name</th>
      <th>Category</th>
      <th>Price</th>
    </tr>
    <tr *ngFor="let item of getProducts(); let i= index"
        [pa-attr]="getProducts().length<6 ? 'bg-success':'bg-warning'"
        [pa-product]="item" (pa-category)="newProduct.category=$event">
      <td>{{i + 1}}</td>
      <td>{{item.name}}</td>
      <td [pa-attr]="item.category=='Soccer'?'bg-info':null">{{item.category}}</td>
      <td [pa-attr]="'bg-info'">{{item.price}}</td>
    </tr>
  </table>
</div>
```

### Creating a simple structural Directive

A good place to start with structural directives to re-create the functionaliy provided by the `ngIf`direcitve, which is relatively simple is easy to understand, and provides a good fundation for explaining how structural directives work.

```html
<div class="form-check m-2">
    <input type="checkbox" class="form-check-input" [(ngModel)]="showTable"/>
    <label class="form-check-label">Show Table</label>
</div>
```

And the `ng-template`elements has a std one-way data binding, which targets a directive called `paIf`.

### Implementing the structural Directive class

Know from the template the directive should do - to implement the driective, added a file called `structure.directive.ts`in the `src/app`folder andadded the code like:

```ts
import {Directive, Input, SimpleChanges, TemplateRef, ViewContainerRef} from "@angular/core";

@Directive({
  selector: "[paIf]"
})
export class PaStructureDirective {
  constructor(private container: ViewContainerRef,
              private template: TemplateRef<Object>) {
  }

  @Input("paIf")
  expressionResult: boolean | undefined;

  ngOnChanges(changes: SimpleChanges) {
    let change = changes['expressionResult'];
    if (!change.isFirstChange() && !change.currentValue) {
      this.container.clear();
    } else if (change.currentValue) {
      this.container.createEmbeddedView(this.template);
    }
  }
}

```

The selector proprety of the `@Directive`decorator is used to match host elements that have the `paIf`attribute, this corresponds to the template additions. There is an input proprety called `expressionResult`-- which the directive uses to receive the results of the expression from the template. The directive implements the `ngOnChanges`method to receive change notifications so that it can respond to changes in the data model.