# The MultiIndex Object

`Series`and `DataFrame`indices can hold various data types: strings, number, datatimes, and more. Image tuples serving as a `DataFrame`index labels -- hope that the idea -- All opertions remains the same, still be able to reference a row by its index lable, but each index label would be a container holding multiple elements -- That is a good way to start -- Can create a `MultiIndex`object independency of a `Series`or `DataFrame`-- The `MultiIndex`class is available as a top-level attribute on the pandas library -- it includes a `from_tuples`class -- that instantiates a `MultiIndex`from a list of tuples.

`pd.MultiIndex.from_tuples(address)`

In pandas, the collection of tuple values at the same position forms a *level* of the *MultiIndex* -- in the previous, the first level -- Can assign each `MultiIndex`level a name by passing a list to the `from_tuples`method's names parameter. like:

`pd.MultiIndex.from_tuples(address, names='Street City State Zip'.split())`

```py
data = [
    ['A', 'B+'],
    ['C+', 'C'],
    ['D-', 'A']
]
columns = ['Schools', 'Cost of living']
area_grades = pd.DataFrame(data, index=row_index, columns=columns)
```

Pandas stores a `DataFrame`column headers in an index objects as well, can access that index via the `columns`attribute

```py
column_index = pd.MultiIndex.from_tuples([
    ("Culture", "Restaurants"),
    ("Culture", "Museums"),
    ("Services", "Police"),
    ("Services", "Schools"),
])
data = [
    ["C-", "B+", "B-", "A"],
    ["D+", "C", "A", "C+"],
    ["A-", "A", "D+", "F"]
]
pd.DataFrame(data, index=row_index, columns=column_index)
```

For this, successfully created a `DataFrame`with a four-level row `MultiIndex`and two-level column `MultiIndex` -- And a `MultiIndex`is an index that can store multiple levels, multiple tiers.

### MultiIndex DataFrames

Scale things up a bit -- for the csv data set is similar -- First we just have 3 unnamed columns, each one ending in a different number, when importing a CSV, pandas assumes that the file's first row holds the column names, also known as the headers -- if a heder slost does not have a value, pandas assigns a title of `unnamed`-- to the column. Simultaneously, the library tries to avoid duplicate column names -- to distinguish between multiple missing headers, the library adds a numberical index to each.

And the four columns to the right have the same naming issue. The issue that the CSV is trying to model a multilevel row index and a multilevel column index, but the default arguments to the `read_csv`don't recognize it.

Have to tell the pandas that 3 leftmost columns should serve as the index of the `DataFrame`-- can do this by passing the `index_col`parameter a list of numbers, each one reprenting the index of a column that should be in the `DataFrame`'s index -- of a column that should be in the `DataFrame`index.

```py
neighborhoods = pd.read_csv(
    '../pandas-in-action/chapter_07_multiindex_dataFrames/neighborhoods.csv',
    index_col=[0,1,2])
neighborhoods.head()
```

For this -- the first 3 columns will inve index 0, 1, and 2, can just use `index_col=[0,1,2]`do that. And, need to tell pandas which data set rows like to use for our `DataFrame`headers -- The `read_csv`assumes that the only first row will hold the headers. And in this-- can also accept a list of integers representing the *rows* that pandas will assign a `MultiIndex`to the column. like: Using the `read_csv`'s `header`parameter -- accepts a list of integers representing the *rows* that pandas should set as column headers like:

```py
neighborhoods= pd.read_csv(
    '../pandas-in-action/chapter_07_multiindex_dataFrames/neighborhoods.csv',
    index_col=[0,1,2],
    header=[0,1]
)
neighborhoods.head()
```

The data set groups 4 characteristics of livability -- in two categories -- when have a parent category encompassing smaller child categories, creating a `MultiIndex`is optimal way to enable quick slicing.

`neighborhoods.info()`Just notice that pandas prints each column's name as a two-element tuple, such as `(Culture, Restaurants)`-- similary, the library stores each row's label as a three-element tuple.

`neighborhoods.index`

Can access the columns' `MultiIndex`object with the `columns`attribute, which also uses tuples to store the nested column lables -- like: `neighborhoods.columns`-- Under its hood, pandas composes a `MultiIndex`from multiple `Index`objects-- when importing the data set, the library **assigned a name** to each `Index`from a CSV header. Can access the list of index names with the `names`attribute on the `MultiIndex`object like:

`neighborhoods.index.names`

And, note pands assign an order to each nested level within the `MultiIndex`-- in the current neighborhoods `DataFrame`-- The `State`fore, has an index position of 0.

Note that there is a `get_level_values`method extracts the `Index`obj at a given level of the `MultiIndex` like:

```py
neighborhoods.index.get_level_values(1)
neighborhoods.index.get_level_values('City')
```

The columns' `MultiIndex`levels do not have any names cuz the CSV did not provide any like: Can also fix this by accessing the columns' `MultiIndex`with the `columns`attribute -- then can assign a new list of column names to the `names`attribute of the `MultiIndex`object.

`neighborhoods.columns.names=['Category', 'Subcategory']`

Now that just assigned names to the levels, can use the `get_level_values`method to just retrieve any `Index`from the columns' `MultiIndex`like:

`neighborhoods.columns.get_level_values('Category')` # or (0)

So, a `MultiIndex`will carry over to new objects derived from a data set -- the index can switch axes depending on the operaetion -- Considier a `DF``nunique`method -- which just returns a `series`with a count of unique values per column.

`neighborhoods.nunique()` # need to note that is a method

### Sorting a MultiIndex

Pandas can find a value in the ordered collection much quicker than in a jumbled one. When invoke the `sort_index`method on a `MultiIndexDataFrame`-- pandas worts all levels in ascending order and porcessed from the outside in. Fore, pandas sorts the State-level values first, then the City-level values, and finally the street level.

`neighborhoods.sort_index()`

First, pandas target the `State`level and sorts -- Then within the state of .. pandas sorts the city.. .. -- The sort_values method includes an `ascending`parameter, can pass like:

`neighborhoods.sort_index(ascending=False)`

Need to note, suppose that want to vary the sort order for different levels -- can pass the `ascending`a list of Booleans:

`neighborhoods.sort_index(ascending=[True,False,True])`

Can also sort a `MultiIndex`by itself -- means level -- like: can pass the level's index position or its anme to the `level`parameter of that method like:

```py
neighborhoods.sort_index(level=1)
neighborhoods.sort_index(level='Street')
```

And the `level`parameter can also accept a list of levels, the next example sorts the City level's values first, followed by the Street level's values -- the `State`level's values do not influence the sort at all. like:

```py
neighborhoods.sort_index(level= [1,2]).head()
neighborhoods.sort_index(level= ['City', 'Street']).head()
```

Can also combine the `ascending`and `level`parameters -- notice in the preceding that pandas stored the two `Street`values for the city, like:

`neighborhoods.sort_index(level=[0,2], ascending=[True, False])`

Can also sort the column's `MultiIndex`object as well by supplying the `axis`parameter to the `sort_index`method -- this parameter is default 0 -- which repressets the row index, to sort the columns, can pass eigher the number 1 or the `columns`parameter value like:

`neighborhoods.sort_index(axis=1, ascending=False).head()`

Can also combine the `level`and `ascending`parameters. so can do:

`neighborhoods.sort_index(axis=1, level=1, ascending=False).head()`

Have leaned how to extract rows and columns from a `MultiIndex`DataFrame with familar accessor attributes such as `loc`and `iloc`-- it's also optimal to sort our index before we look up any row -- like:

`neighborhoods = neighborhoods.sort_index(ascending=True)`

### Selecting with a MultIndex

Extracting `DataFrame`rows and columns get tricky when multiple levels are involved, the key question to ask before writing any code what we want to pull out. FORE, following like: fore:

```py
data=[
    [1,2],[3,4],
]
df = pd.DataFrame(data, index=['A', 'B'], columns=['X', 'Y'])
```

Suppose that we want to pull out a column from neighborhoods, each of four columns in the `DataFrame`requires a combination of two identifiers -- `Category`and `Subcategory`-- 

### Extracting one or more columns

If pass a single value in `[]`, pandas will look for it in the outmost level of the columns' `MultiIndex`.

`neighborhoods['Services']`

Notice a new `DataFrame`does not have the `Category`level -- it has a plain `Index`with two values, there is no longer a need for a `MultiIndex`, and note that Pandas will raise a `KeyError`if the value does not exist in the outermost level of the column's MultiIndex: `neighborhods['School']` # KeyErrors

## Rxjs

There is a few new concept in the exmaple -- To start there are 6 variables, three elements from the page and three observables -- The first line of business logic is a subscription to `startClick$`-- which creates a **click event** handler on that element. At this point, no one’s clicked the so -- `Rx`hasn’t creted the interval or an event listener for the stop button. When the button clicked, the `subscribe`is triggered. Cuz there is a new event -- The actrual click event is ignored, as this implementation doesn’t care about the specifiecs of the click.

Immediately, `tenSecond$`runs its ctor (creating the interval behind the scenes) -- cuz there is a subscribe call at the end of the inner chain. At that point, no one clicked the start. When new event come, `subscribe`called -- Suddenly, an unexpected operator appears in the form of `tkeUntil`.

Is an operator that attaches itself to an observable stream and takes values from that stream *until* the observable that is passed in as an argument emits a value. So when the `Stop` is clicked, Rx cleans up both the interval and the STOP button handler.

### Drag and Drop

Adding to confusion, just a flick of the user’s wrist can just generate thousans of `mousemove`events, -- so the code must be performant -- Rx’s **lazy** subscription model means that we aren’t tracking any `mousemove`events until the user actually drags the element -- additionally, `mousemove`events are fired sync -- So RX will guarantee that they arrive in order to the next stop in the stream. like: note that the html:

```html
<html>
<head>
  <title>Creating Observables: Drag 'n Drop</title>
  <link rel="stylesheet" href="http://localhost:3000/assets/bootstrap.min.css">
  <style>
    #draggable {
      cursor: move;
      background-color: rgb(175, 49, 49);
      color: white;
      font-size: 35px;
      position: absolute;  /* note that */
    }
  </style>
</head>
<body>
  <div id="draggable">
    Click & Drag Me!
  </div>
  <script src="/creatingObservables/dragdrop.js"></script>
</body>
</html>
```

```ts
import { fromEvent } from "rxjs";
import { map, takeUntil } from "rxjs/operators";

let draggable = document.querySelector<HTMLElement>('#draggable');
let mouseDown$ = fromEvent(draggable, 'mousedown');
let mouseMove$ = fromEvent(document, 'mousemove');
let mouseUp$ = fromEvent(document, 'mouseup');

mouseDown$.subscribe(() => {
    mouseMove$
        .pipe(
            map((event: MouseEvent) => {
                event.preventDefault();
                return {
                    x: event.clientX,
                    y: event.clientY,
                };
            }),
            takeUntil(mouseUp$)
        ).subscribe(pos => {
            draggable.style.left = pos.x + 'px';
            draggable.style.top = pos.y + 'px';
        });
});
```

At the start are the same bunch of variables that you swa in the example -- the code just tracks a few events on the entire HTML document. For the initiating observable, `mouseDown$`is subscribed, in the susscriptin, each `mouseMove$`event is mapped, so taht the only data passed on are the current coordinates of the mouse, and `takeUntil()`is used to that once the mouse button is released -- everything’s cleaned up. Finally, the inner subscribe updates the position of the dragged element across the page.

### Loading Bars

Instead of trying to track lots of global state, Rx do the heavy lifting -- how to aadd a single function there to handle cases when a bit of your app didn’t load. like:

```ts
startLoad$.subscribe(()=> {
    assetPipeline$
    .pipe(
    	takeUntil(stopLoad$)
    ).subscribe(item=> updateLoader(item));
})
```

### Chat Rooms

Both know just how much -- use power of Rx to track only the rooms the user has joined. Use some of these techniques to build an entire chat in multiplexing observables.

```ts
loadRoom$.subscribe(()=> {
    chatStream$
    .pipe(takeUntil(roomLeave$))
    .subscribe(msg=> addMsgToRoom(msg));
});
```

### Using a Sbscription

And, there is one more vocabulary word before -- subscription -- piping through an operator returns an observable. Like: `let someNewObservable$= anObservable$.pipe(map(x=>x*2));`, and a call to `.subscribe()`returns a `Subscription`like:

`let aSubscription = someNewObservable$.subscribe(console.log);`

Note that the `Subscriptions`are not a subclass of observables, so there is no dollar sign at the end of the variable name -- A subscription is used to keep track of a specific subscription to that obersvable. This means that whenever the program no longer needs the values from thep particular observable stream, it can use the subscription to unsubscribe from all future events like:

`aSuscription.unsubscribe()`

Some operators, like `takeUntil`, handle subscriptions internally, most of the time, your code manages subscriptions manually -- Can also merge subscriptions together or even add custom unsubscription logic. Recommended keep all logic related to subscribing and unsuscribing in the ctor function if possible.

### Experimenting with Observables

Covers the `of`, and the `take`, and `delay`operators, they are included in the first, cuz all three are useful for hands-on experimentation with observales.

`of`-- Allows for easy creation of an observable out ot a known data source -- it takes any number of arguments and returns an observable containing each argument as separate event.

```ts
import { of } from 'rxjs';
of('hello', 'world', '!')
    .subscribe(console.log);
```

The `of`ctor can be handy when try to learn a new operator -- it’s the simplest way to create an observable of arbitrary data -- fore, if you with `map`like:

```ts
import { of } from 'rxjs';
import { map } from 'rxjs/operators';

of('foo', 'bar', 'baz')
    .pipe(map(word => word.split('')))
    .subscribe(console.log);
```

### The `take`operator

The `take`operator is related to that, but it just simplifies things -- it’s passed a single integer argument, and take taht many events from the observable before it unsubscribes.

```ts
import { interval } from "rxjs";
import { take } from "rxjs/operators";

interval(1000)
    .pipe(
        take(3)
    ).subscribe(console.log);
```

`take`is just useful when you only want the first slice of an observable’s data. like:

### The `delay`operator

The `delay`opertor is passed an integer argument and delays all events coming through the observable chain by that many ms.

```ts
import { of } from "rxjs";
import { delay } from "rxjs/operators";

of(1, 2, 3)
    .pipe(
        delay(1000)
    ).subscribe(console.log);
```

Like other two, `delay`helps you manipulate your streams to play with observables and their operators.

```ts
import { merge, of } from "rxjs";
import { delay } from "rxjs/operators";

let oneS$ = of('one').pipe(delay(1000));
let oneS2$ = of('two').pipe(delay(2000));
let oneS3$ = of('three').pipe(delay(3000));
let oneS4$ = of('four').pipe(delay(4000));

merge(oneS$, oneS2$, oneS3$, oneS4$)
    .subscribe(console.log);
```

## Creating a simle Attribute Directive

The best place to start is just to create that like:

```ts
@Directive ({
    selector: "[pa-attr]"
})export class PaAttrDirective {
    constructor(element: ElementRef) {
        element.nativeElement.classList.add('table-success', 'fw-bold');
    }
}
```

Note that the Directives are classes which the `@Directive`decorator has been applied. Also requires the `selector`property -- which is used to specify how the directive is applied to elements. Note that it defines a single `ElementRef`parameter -- which Ng provides when it creates a new instance of the directive and which represents the host element -- the `ElementRef`class defines a single property, `nativeElement`represent the obj used just by the browser represents a DOM object.

Applying Custom Directive: just:

`<tr *ngFor="let item of getProducts(); let i = index" pa-attr>`

And note that the directive must be added to the `NgModule`'s `declarations` section.

### Accessing app Data in a directive

The simplest to just make more useful is using applied to the host element. Just like:

`<td pa-attr pa-attr-class="table-warning">{{item.category}}</td>`

```ts
constructor(element: ElementRef, @Attribute("pa-attr-class") bgClass: string) {
    element.nativeElement.classList.add(bgClass | "table-success", 'fw-bold');
}
```

The `@Attribute`decorator specifies the name of the attribute that should be used to provide a value for the ctor parameter when a new instance of the directive class is created.

```ts
export class PaAttrDirective {
  constructor(element: ElementRef, @Attribute("pa-attr") bgClass:string) {
    element.nativeElement.classList.add(bgClass || 'bg-success', 'fw-bold');
  }
}
```

`<td pa-attr pa-attr="table-warning">`

### Creating data-bound input properties

Not that the main limitation of reading attributes with `@Attribute`is that values are static -- the real power in Ng directives come through support for expressions that are updated to reflect changes in the app state that cn respond by changing the host element. like:

```html
<tr *ngFor="let item of getProducts(); let i= index"
    [pa-attr]="getProducts().length<6 ? 'bg-success':'bg-warning'">
    <td>{{i + 1}}</td>
    <td>{{item.name}}</td>
    <td [pa-attr]="item.category=='Soccer'?'bg-info':null">{{item.category}}</td>
    <td [pa-attr]="'bg-info'">{{item.price}}</td>
</tr>
```

Note that there are 3 expressions in the listing -- which is applied to the `td`element for the `Category`column, specifies the `bg-info`. Just noticed that the attribute name is enclosed in square brackets. NOTE-- implementing the other side of data binding means creating an **input property** in the directive class and telling Ng how to manage it’s value like:

```ts
@Directive({
  selector: "[pa-attr]",
})
export class PaAttrDirective implements OnInit{
  constructor(private element: ElementRef) {
  }

  @Input("pa-attr")
  bgClass: string | null = "";

  ngOnInit(): void {
    this.element.nativeElement.classList.add(
      this.bgClass || 'bg-success', 'fw-bold'
    );
  }
}
```

Input properties are defined by applying the `@Input`decorator to a property and using it to specify the name of the attribute that contains the expression. Don’t need to provide an argument to the `@Input`decorator if the name of the property corresponds to the name of the attribute on the host element. So, if apply `@Input`to a properly called `myVal`, then Ng will look for this name on the host element.

The role of the ctor has changed in this example, when Ng creates a new instance of a directive class, the ctor is invoked to create a new directive object, and only then is the value of the input property set. This means that the ctor cannot access the input prop value cuz its value will not be set by Ng until after the ctor has completed and the new directive object has been produced. To address this, directives can just implement *lifecycle hook methods* -- which ng uses to provide directives with useful info after they have been created and whle the app is running, like:

- `ngOnInit`-- called after Ng has set the initial value for all the input properties that the directive has been declared.
- `ngOnChanges`-- called when the value of an input prop has changed and also just before the `ngOnInit`called.
- `ngDoCheck`-- called when Ng runs its change detection process
- `ngAfterContentInit`-- called when the directive’s content has been initialized
- `ngAfterContentChecked`-- called after the directive’s content has been inspected as part of the change detection process.
- `ngonDestroy`-- called immediately before ng destroyes a directive.

For this the `ngOnInit`-- which is called after Ng has set the value of the `bgClass`propety. the ctor is still needed to receive the `ElementRef`object that provides access to the host element -- which is assigned to a property.

### Responding to Input Property Changes

Sth odd happened in the previous example, adding a new item affected the appearance of the new element but not the existing elements. Behind the scenes, Ng has updated the value of the `bgClass`property for each of the dreictive that it created -- one for each `td`element in the table column -- but the diriective didn’t notice cuz -- changing a property value **doesn’t** automatically cause directives to respond.

To handle changes, a directive must implements the **`ngOnChanges`**method to receive notifications when the vlaue of an input property chagnes.

```ts
ngOnChanges(changes: SimpleChanges): void {
    let change = changes['bgClass'];
    let classList = this.element.nativeElement.classList;
    if (!change.isFirstChange() && classList.contains(change.previousValue)) {
        classList.remove(change.previousValue);
    }
    if (!classList.contains(change.currentValue)) 
        classList.add(change.currentValue);
}
```

This method is called once before the `ngOnInit`method and then called again each time there are changes to any of the directive’s input properties. For the `SimpleChanges`-- is a map key refer to each changed input prop and whose value are `SimpleChange`objects. like:

- `previousValue`-- returns the previous value of the input property
- `currentValue`-- returns the current value of the input property
- `isFirstChange()`-- returns `true`if this is the call to the `ngOnChanges()`that occurs before the `ngOnInit()`method.

so, when responding to changes to the input property value, a directive has to make sure to account for the effect of previous updates.

It is just important to use the `isFirstChange()`so that you don’t undo a value that hasn’t actually been applied since the `ngOnChanges`is called the first time a value is just assigned to the input property.

### Creating Custom Events

*output properties* are the Ng features that allow directives to add custom events to their host elements. Defined using the `@Output`decorator -- defined also in the `@angular/core`module.

```ts
@Directive({
  selector: "[pa-attr]",
})
export class PaAttrDirective implements OnChanges {
  constructor(private element: ElementRef) {
    this.element.nativeElement.addEventListener('click', () => {
      if (this.product != null) {
        this.click.emit(this.product.category);
      }
    })
  }

  @Input("pa-product")
  product: Product = new Product();

  @Output("pa-category")
  click = new EventEmitter<string>();
//...
}
```

Just note that the `EventEmitter<T>`interface provides the event mechanism for Ng directives. The listing creates an `EventEmitter<string>`object and assign it to a variable called `click`.

And the `string`indicates that listeners to the event will receive a `string`when the event is triggered. Directives can provide any type of object to their event listener. common are `string, number`, data model and Js `Event`objects. This custom event in the listing is triggered when the mouse button is clicked on the host element, and the event provides its listener with the `Category`of the `Product`object that was used to crete the table row using the `ngFor`directive. The effect is responding to a DOM on the host and generating its own custom event in response. The listener for the DOM is set up in the directive class ctor using the browser’s std `addEventListener()`method.

And the most important statement in the listing is the one that uses the `EventEmitter<string>`to send the event.

- `emit(value)`-- this t*riggers the custom event* assocaited with the `EventEmitter`. Providing the listener with object or value received as the method argument.

