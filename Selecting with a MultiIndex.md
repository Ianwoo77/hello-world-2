# Selecting with a MultiIndex

Extracting `DataFrame`rows and columns gets tricky when multiple levels are invovled. Extracting one or more columns -- If pass a single value in square brackets, pandas will look for in the outermost level of columns' `MultiIndex`.

`neighborhoods['Service']` Notice that new `DataFrame`does not have a `Category`level, just has plain `Index`with two values -- `Police`and `Schools`. 

Pandas will raise a `KeyError`exception if the value does not exist in the outermost level of the column's `MultiIndex`. And to specify values across multiple levels in the column's `MultiIndex`-- pass them inside a **tuple** -- like:

`neighborhoods[('Services', 'Schools')]`

Note that the method returns a `Series`just without a column index -- once again, when provide a value for a `MultIndex`level, remove the need fro the level to exist. To extract multiple `DataFrame`columns, need to pass the `[]`in a list of tuples. just like:

`neighborhoods[[('Services', 'Schools'), ('Culture', 'Museums')]]`

For this, syntax tends to become just confusing and error-prone when it involves multiple parentheses and brackets. can simplify the preceding code by passing the list to a variable and breaking its tuples across several lines like:

```py
columns= [('Services', 'Schools'), ('Culture', 'Museums')]
neighborhoods[columns]
```

### Extracting one or more rows with `loc`

The `loc`accessor extracts by index lable, and the `iloc`extracts by index position. for our example has 3 levels, `State, City, Address`-- if know the values to target in each level, can pass them in a tuple within the `[]`-- when provide a value for a level, remove the need for level to exist in the result. like:

`neighborhoods.loc[('TX', 'Kingchester', '534 Gordon Falls')]`

And, if pass a single label in the `[]`, pandas looks for it in the outermost `MultiIndex`level like:

`neighborhoods.loc['CA']` for this, Pandas just returns a `DataFrame`with a two-level `MultiIndex`-- just notice that the State level is not present. 

Need to note -- the second arg to the `[]`denotes the columns like to extract -- can also provide the value to look for in the next `MultiIndex`level. Once again, returns a `DataFrame`also. like:

`neighborhoods.loc['CA', 'Dustinmouth']`

Note that can still use the second argument to `loc`to declare the `column(s)`to extract -- the next extracts rows with State value of `CA`in the row and a `Culture`column value:

`neighborhoods.loc['CA', 'Culture']`

Note that this syntax in the previous two examples is not ideal cuz of its ambiguity -- The second argument to `loc`can represent either a value from the second level of the row's `MultiIndex`or a value from the column.

So the pandas documentation recommends the following indexing strategy to avoid uncertainty. Namely, -- use the first arg to `loc`for row index and second for column -- Wrap all args for a given index insdie a tuple. Following this std, could place our row levels' vlaues inside a tuple and our column level's values inside a tuple as well like:

`neighborhoods.loc[('CA', 'Dustinmouth')]`

The syntax is just more straightforward and more consistent -- it allows `loc`'s second arg to always represent the columns' index lables to target. So one common use:

`neighborhoods.loc[('CA', 'Dustinmouth'), ('Services',)]`
`neighborhoods.loc[('CA', 'Dustinmouth'), ('Services', 'Schools')]`

So, what about selecting sequential row - can use Py's list-slicing syntax -- liek:

`neighborhoods['NE':'NH']` note that must call the `sort_index(inplace=True)`first.

`neighborhoods.loc[('NE', 'Shawnchester'): ('NH', 'North Latoya')]`

Be careful with this syntax -- a single missing parthesis or comma can just raise an exception. So can:

```py
start = ('NE', 'Shawnchester')
end = ('NH', 'North Latoya')
neighborhoods.loc[start: end]
```

Do not have to provide each tuple values for each level -- the next example does not include a City-level value like:

`neighborhoods.loc[('NE', 'Shawnchester'): ('NH')]`

### Extracting one or more rows with iloc

The `iloc`just extracts rows and columns by index position -- the following examples should be like: Can pull out multiple rows by wrapping their index positions in a list like:

`neighborhoods.iloc[[25,30]]`

And, there is just a big difference between `loc`and `iloc`, iloc's endpoint is exclusive. And columns slicing like:

`neighborhoods.iloc[25:30, 1:3] # 3 is exclusive`

### Cross-Sections

The `xs`method allow to extract rows by just providing a value for *one* multiindex level, pass the method the `key`parameter with the level to look for -- pass the `level`parameter either the numeric position or the name of the index level in whcih to look for the value. Fore:

`neighborhoods.xs(key='Lake Nicole', level=1)` # or level= 'City'

There are three .. So, pands removes the City level from the new `DataFrame`. Can apply the same techniques to columns by passing the `axis`parameter an argument of `columns`. Just like:

`neighborhoods.xs(axis='columns', key='Museums', level='Subcategory').head()` or:
`neighborhoods.xs(axis=1, key='Museums', level=1).head()`

Notice that the `Subcategory`level is not present any more.

Can also provide the `xs`method with keys across nonconseutive levels like:

```py
neighborhoods.xs(
    key=('AK', '238 Andrew Rue'), level=['State', 'Street']
)
```

### Manipulting the Index

At the start, contorted our data set into its current shape by altering the parameters to the `read_csv`function, pandas also allows to manipulate the index on an existing `DataFrame`.

The `reorder_levels`method arranges the `MultiIndex`levels in a specified order. Pass `order`parameter a list of levels in a desired order. The next example swaps the positions of the City and State levels. just like:

```py
new_order=['City', 'State', 'Street']
neighborhoods.reorder_levels(order=new_order).head()
```

Can also pass the `order`a list of integers. The numbers must represent the current index positions of the `MultiIndex`levels. like: `neighborhoods.reorder_levels(order=[1,0,2]).head()`

What if want to get rid of the index -- perhaps want to set a different combination of columns as the index labels. Pandas replaces the former with its std numeric one. like:

`neighborhoods.reset_index().head()`

Notice that the tree new columns -- becomes values in `Category`, the outermost level of the column's `MultiIndex`. Can add the 3 columns to an alternate `MultiIndex`level -- pass the desired level's index pos or name to the `reset_index`'s `col_level`parameter. like:

`neighborhoods.reset_index(col_level=1).tail()`

Now pandas will default to an empty string for `Category`, the parent level that holds the `Subcategory`level under which `State, City`and `Street`fall. Can also replace the empty string with a value of our choice by passing an arg to the `col_fill`parameter.

```py
neighborhoods.reset_index(
    col_fill='Address', col_level=1
).tail() # group the 3 new columns under an Address parent level
```

The std invocation of `reset_index`transforms all index levels into regular columns, can also more a single index level by passing its name to the `levels`parameter. just like:

`neighborhoods.reset_index(level='Street').tail()` # just move `street`to column

`neighborhoods.reset_index(level=['Street', 'City']).tail()`

What about removing a leel from the `multiinex`-- pass the `reset_index` drop boolean parameter like:

`neighborhoods.reset_index(level='Street', drop=True).tail()`

### Setting the index

```py
neighborhoods.set_index(keys='City')
neighborhoods.set_index(keys=('Culture', 'Museums')).head()
```

To create a `MultiIndex`on the row axis, can pass a list with multiple columns to the `keys`like:

`neighborhoods.set_index(keys=['State', 'City']).head()`

## Typeahead

```ts
fromEvent<any>(typeaheadInput, 'keyup')
    .pipe(
        map((e): string => e.target.value.toLowerCase()),
        tap(() => typeaheadContainer.innerHTML = ''),
        filter(val => val.length > 1),
        mergeMap(val =>
            from(usStates)
                .pipe(
                    filter(state => state.includes(val)),
                    map(state => state.split(val).join('<b>' + val + '</b>')),
                    reduce((prev: any, state) => prev.contact(state), []),
                )
        )
    ).subscribe(
        (stateList: string[]) => typeaheadContainer.innerHTML += '<br>'
            + stateList.join('<br>')
    )
```

Every `keyup`event emitted the `myInput`element a new event object down the steam. The `map`operator takes the event object and plucks out the current *value* of the input. This string is passed to new operator `filter`-- works just like also take a predicate. note that using the `tap`operator to clear the output area.

Final outer operator follows the `mergeMap`pattern. The inner observable is made of the list of states.

```ts
import { ajax } from "rxjs/ajax";

ajax('/api/managingAsync/ajaxExample')
    .subscribe(console.log);
```

Running this code does not log data about the Ajax request to the console. Instead, a big fat error message appear, told this request doesn’t exist.

### Handling Errors

As powerful as observables are, the can’t prevent errors from happening -- instead, they just provide a concrete way to gracefully handles errors as they arise.

```ts
subscribe(
	function next(val) { /* new value has arrived */}
    function error(err) { /* an error occurred */}
	function done() {// done
    }
)
```

For the `next`is called on every new value passed down the observable -- this is the option you’ve been using, error, is called when an error occurs at some point in the stream -- once an error happens, no further data is sent down the observable and the root unsubscribe functions are called.

## Building Custom Events

*Output properteis* are the Ng feature that allows directives to add custome events to their host elements, through which details of important changes can be sent to the rest of the application. Output properties are defined using the `@Output`decorator, which is defined in the `@angular/core`module, as shown as:

```ts
export class PaAttrDirective {
    constructor(private element: ElementRef) {
        this.element.nativeElement.addEventListener('click', ()=> {
            if(this.product != null) {
                this.click.emit(this.product.category);
            }
        });
    }
    
    @Input("pa-attr")
    bgClass: string|null = "";
    
    @Input("pa-product")
    product: Product = new Product();
    
    @Output("pa-category")
    click = new EventEimitter<string>();
    
    ngOnChanges(changes: SimpleChanges) {
        let change = changes['bgClass'];
        let classList= this.element.nativeElement.classList;
        if(!change.isFirstChange() && classList.contains(change.previousValue)){
            classList.remove(change.previousValue);
        }
        if(!classList.contains(change.currentValue)){
            classList.add(change.currentValue);
        }
    }
}
```

The `ngOnChanges`is called **once** before the `ngOnInit`method and then called again each time there are changes to any of a directive’s input properties -- is a `SimpleChanges`object -- is a map whose *keys referst to each changed input prop*, and values are `SimpleChange`objects.

- `previousValue`-- returns the prevous of input property
- `currentValue`-- returns the vlaue of the input property

And for the `EventEmitter<T>`**interface**, just provides the event mechanism for Ng directives -- the listing just creates an `EventEmitter<string>`and assigns it to a variable called `click`like:

```ts
@Output("pa-category")
click = new EventEmitter<string>();
```

The `string`indicates that the listeners to the event will receive a `string`when the event is triggered. Note that the directives can provide any type of object to their event listeners, but comon choices are `string`and `number`, and data model objects, and Js `Event`objects.

For this, the custom event is triggered when the mouse button is clicked on the host element, and the event provides its listeners with the `category`of the `product`object that was used to create table row just using in the `ngFor`directive. The effect is that the directive is responding to a DOM event on the host element and generating its own custom event in response. The listener for the DOM event is set up in the directive class ctor using the browser’s std `addEventListener`method like: The directive defines an input property to receive the `Product`object whose category will be sent in the event.

The most important statement in the listing is one that use the `EventEmitter<string>`object to send the event. Which is done using the `emit()`-- which is: *triggers* the custom event assocaited wtih the the `EventEmitter`-- providding the listeners with the object or value received as the method argument.

Trying everyting together -- is the `@Output`decorator -- which creates a mapping between the directive’s `EventEmitter<T>`prop and the name that will be used to bind the event in the template like:

```ts
@Output("pa-category")
click = new EventEmitter<string>();
```

Note that the decroator just specifies the attribute name that will be used in event bindings applies to the host element.

### Binding to the Custom Event

```html
<tr *ngFor="let item of getProducts(); let i= index"
    [pa-attr]="getProducts().length<6 ? 'bg-success':'bg-warning'"
    [pa-product]="item" (pa-category)="newProduct.category=$event">
```

Note that the term `$event`is used to *access the value* the directive passed to the `EventEmitter<string>.emit`method -- that means that `$event`is used to sent the value of the category input element. Here, just the `string`.

### Creating Host Element Bindings

Working with the DOM api in the Ng is useful -- but does mean that your directive can be used only in apps that are run in a web browser. Ng is just intended to be run in a range of different execution environments. The same results can be achieved in a more elegant way using std Angualr directive features -- property and event bindings. A class binding can be used on the host element, and rather then use the `addEventListener`. -- an event bindings can be used to deal with the click.

Ng implements this also use the DOM api when the directive is used in web browser -- or some equal mechanism. Note, bindings on the host elemenet are defined using the two decorator: `@HostBinding`and `@HostListener`.

```ts
@Input("pa-attr")
@HostBinding("class")
bgClass: string | null = "";

@HostListener("click")
triggerCustomEvent() {
    if (this.product != null) {
        this.click.emit(this.product.category);
    }
}
```

The `@HostBinding`decorator is sued to set up a property binding on the host element, is applied to a directive prop, and the listing sets up a binding between the `class`prop on the host element and the decorator’s `bgClass`prop.

And the `@HostListener`decorator is used to set up an event binding on the host element and is applied to a method. This creates an event binding for the `click`event that invokes the `emit`method when the mouse button is pressed and released.

Using the host element bindings means that the element’s class membership through the property binding.

### Creating a Two-way binding on the Host Element

The two-way feature reles on a naming convention. like:

```html
<div class="mb-3 bg-info text-white p-2">
    <label>Name:</label>
    <input class="bg-primary text-white form-control"
           [paModel]="newProduct.name"
           (paModelChange)="newProduct.name=$event" />
</div>
```

The binding whose target is just `paModel`will be updated when the value of the `newProduct.name`property changes, which provides a flow of data from the app to the directive and will be used to update the content of the `input`element. The custom event -- `paModelChange`-- will be triggered when user changes the contents.

So add new directive like:

```ts
import {
  Directive,
  EventEmitter,
  HostBinding,
  HostListener,
  Input,
  OnChanges,
  Output,
  SimpleChanges
} from "@angular/core";

@Directive({
  selector:"input[paModel]"
})export class PaModel implements OnChanges{

  @Input("paModel")
  modelProperty: string| undefined="";

  @HostBinding("value")
  fieldValue: string = "";

  ngOnChanges(changes: SimpleChanges): void {
    let change= changes['modelProperty'];
    if(change.currentValue != this.fieldValue) {
      this.fieldValue=changes['modelProperty'].currentValue || '';
    }
  }

  @Output('paModelChange')
  update=new EventEmitter<string>();

  // newValue is set by the $event.target.value
  @HostListener('input', ["$event.target.value"])
  updateValue(newValue: string){
    this.fieldValue=newValue;
    this.update.emit(newValue);
  }

}
```

This directive uses features that have been described. -- For the `input`element’s `paModel`attribute. And the `paModel`binding is implemented using an input property and the `ngOnChanges`. And the `paModelChange`event is just implemented using a host listener on the `input`event, which then sends an uppdate through an output prop.

`@HostListener('input', ['$event.target.value'])`-- for this, the first arg is name of the event -- and the second is an array that will be used to provide the decorated methods with arguments. When `updateValue`invoked the `newValue`will be set to the `target.value`prop of `event`.

And the final step is to simplify the binding and applying the [()] style like:

```html
<input class="bg-primary text-white form-control"
       [(paModel)]="newProduct.name" />
```

So, when Ng encounters the `[()]`brackets, it expands the binding to match the format used -- targeting the `paModel`input prop and setting up the `paModelChange`event.