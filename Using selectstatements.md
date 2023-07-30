# Using `select`statements

The `select`to group operations that will send or receive from channels. Which allows for complex arrangement of goroutines and channels to be created.

The simplest use for `select`is to receive from a channel without blocking.

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)

	// explicitly conversion of channel
	go DispatchOrders(chan<- DispatchNotification(dispatchChannel))

	for {
		select {
		case details, ok := <-dispatchChannel:
			if ok {
				fmt.Println("Dispatch to", details.Customer, ":",
					details.Quantity, "x", details.Product.Name)
			} else {
				fmt.Println("Channel has been closed")
				goto alldone
			}
		default:
			fmt.Println("-- No message ready to be received")
			time.Sleep(time.Millisecond * 500)
		}
	}
alldone:
	fmt.Println("All values received")
}
```

When the `select`is executed, each channel operation is evaluated until one that can be performed without blocking is reached. The channel operation is performed, and the statements enclosed in the `case`statement are executed.

And the select evaluate its `case`once.

## Receiving from Multiple Channels

```go
for {
    select {
    case details, ok := <-dispatchChannel:
        if ok {
            fmt.Println("Dispatch to", details.Customer, ":",
                details.Quantity, "x", details.Product.Name)
        } else {
            fmt.Println("Channel has been closed")
            dispatchChannel = nil
            openChannels--
        }
    case product, ok := <-productChannel:
        if ok {
            fmt.Println("Product", product.Name)
        } else {
            fmt.Println("Product channel has been closed")
            productChannel = nil
            openChannels--
        }
    default:
        if openChannels == 0 {
            goto alldone
        }
        fmt.Println("-- No message ready to received")
        time.Sleep(time.Millisecond * 500)
    }
}
```

The `select`is used to receive values from two channels. Care must be taken to manage closed channels. Relying on the closed indicator to show the channel is closed -- this means that case statement for closed channels will always be chosen by `select`.

A `nil`channel is never ready and will not be chosen, allowing the `select`to move onto other `case`statement.

## Sending without Blocking

A `select`can also be used to send to a channel without blocking.

```go
func enumerateProducts(channel chan<- *Product) {
	for _, p := range ProductList {
		select {
		case channel <- p:
			fmt.Println("Send product", p.Name)
		default:
			fmt.Println("Discarding product:", p.Name)
			time.Sleep(time.Second)
		}
	}
	close(channel)
}

func main() {
	productChannel := make(chan *Product, 5)
	go enumerateProducts(productChannel)

	time.Sleep(time.Second)

	for p := range productChannel {
		fmt.Println("Received product", p.Name)
	}
}
```

The channel is created with a small buffer -- and values are not received from the channel until after a small delay.

# Error Handling

The way that Go deals with errors -- Describe the interface that represents errors -- The `error`interface is used to define error conditions, which are typically returned as function results. And the `panic`is called when an unrecoverable error occurs.

## Dealing with Recoverable Errors

Go makes it easy to express exceptional conditions, which allows a function or method to indicate to be calling code that sth has gone wrong.

Go provides a predefined interface named `error`that provides one way to resolve this issue.

```go
type error interface {
    Error() string
}
```

```go
type CategoryError struct {
	requestedCategory string
}

func (e *CategoryError) Error() string {
	return "Category " + e.requestedCategory + " does not exist"
}
```

## Escaping

The `html/tempalte`package automatically escapes any data that is yielded between {{ }} tags. This behavior is hugely helpful in avoiding cross-site scripting (XSS) attacks.

## Nested Tempaltes

It's really important to note that when are invoking one template from another template, dot needs to be explicitly passed or pipelined to the template being invoked.

`{{template "base" .}}` `{{block "sidebar" .}}`

### Calling Methods

Fore, if a type has the underlying type `time.Time`, could render the name of the weekday like:

`<span>{{.snippet.Created.Weekday}}</span>`

Can also pass parameters to methods --

`<span>{{.snippet.Created.AddDate 0 6 0}}</span>`

## Template Actions And Functions

1. {{if .Foo}} C1 {{else}} C2 {{end}}
2. {{with .Foo}} C1 {{else}} C2 {{end}}
3. {{range .Foo}} c1 {{else}} C2 {{end}}

for all three, `{{else}}`is just optional. The empty values are false, 0, andnil pointer or interface, length 0.

`with`and `range`change the value of dot.

## Using the `with`action

```html
{{define "main"}}
    <h2>Latest Snippet</h2>
    {{if .Snippets}}
        <table>
            <tr>
                <th>Title</th>
                <th>Created</th>
                <th>ID</th>
            </tr>
            {{range .Snippets}}
                <tr>
                    <td><a href="/snippet?id={{.ID}}">{{.Title}}</a></td>
                    <td>{{.Created}}</td>
                    <td>#{{.ID}}</td>
                </tr>
            {{end}}
        </table>
    {{else}}
        <p>There is nothing to see yet</p>
    {{end}}
{{end}}
```

## Caching Templates

Good time to make some optimizations to our codebase cuz --

1. Each and every time render a web page, our app reads and parses the relevant template using `template.ParseFiles()`func -- could avoid this duplicated work by parsing the file once -- when starting the app -- and storing the the parsed templates in a in-memory cache
2. There is duplicated code in the `home`and `showSnippet`handlers, could reduce this duplication by creating a helper function.

tackle the first -- create an in-memory map with the type `map[string]*template.Template`to cache the parsed templates, in the `templates.go`file:

```go
func newTemplateCache(dir string) (map[string]*template.Template, error) {
	cache := map[string]*template.Template{}

	// get a slice of filepaths with the extension '.page.html'
	// gives us a slice of all page templates for the app
	pages, err := filepath.Glob(filepath.Join(dir, "*.page.html"))
	if err != nil {
		return nil, err
	}

	// loop through the pages one-by-one
	for _, page := range pages {
		// extract the file name
		name := filepath.Base(page)
		ts, err := template.ParseFiles(page)
		if err != nil {
			return nil, err
		}

		ts, err = ts.ParseGlob(filepath.Join(dir, "*.layout.html"))
		if err != nil {
			return nil, err
		}

		ts, err = ts.ParseGlob(filepath.Join(dir, "*.partial.html"))
		if err != nil {
			return nil, err
		}

		cache[name] = ts // add the template set to the cache
	}
	return cache, nil
}
```

Next, is to initialize this cache in the `main()`and make it available to our handlers like:

```go
// initialize a new template cache
templateCache, err := newTemplateCache("./ui/html/")
if err != nil {
    errorLog.Fatal(err)
}
```

# Working with Task Objects

Can instead use `Task`and `Task<TResult>`to wrap the existing methods. U use `Task` when a method would have returned `void`.

* Task.Run -- runs a method on a thread on the thread pool
* `Task.Factory.StartNew`-- Runs a method on a thread on the pool, with `TaskCreationOptions`
* `ContinueWith`-- execute the method provided on the same thread pool thread.
* `Task.WaitAll`-- will block the current thread wait for all tasks in the array.

`Task.WaitAll(new[] {labelTask, sendTask});`-- is the sync equivalent of the `async`. note that it will **block** the current thread until both are complete.

The remaining props of the `Task`fore:

`Exception`-- Returns an `AggregateException`instance containing unhandled exceptions encountered while the task was running. `Wait`or `WaitAll`should be called in a `try/catch`handles the `AggregateException`type.

```cs
try{
    ordersTask.Wait();
}catch(AggregateException) {
    Console.WriteLine(orderTask.Exception.Message);
}
```

Should always use `AggregateException`with blocking `Wait`and `Result`calls, and use `Exception`with `async`and `await`.

1. Alwas prefer `async`and `await`.

If the process is very intensive, but there are very few objects to iterate over, `Parallel.Invoke`, `Parallel.For`and `Parallel.ForEach`.

## Specifying Index Positions for Array Values

By default, arrays are populated in the order in which the form values are received from the browser.

```html
<div class="mb-3">
    <label>Value #1</label>
    <input class="form-control" name="Data[1]" value="Item 1" />
</div>

<div class="mb-3">
    <label>Value #2</label>
    <input class="form-control" name="Data[0]" value="Item 2" />
</div>
```

The `name`attribute can be used to specify the position of values in the array.

## Binding to Simple Collections

Only the type of the prop or parameter that is used by the model binder is changed.

```cs
[BindProperty]
public SortedSet<string> Data {get;set}= new SortedSet<string>();
```

## Binding to Dictionaries

```html
<input class="form-control" name="Data[first]" value="Item 1" />
```

```html
<div class="mb-3">
    <label>Value #2</label>
    <input class="form-control" name="Data[second]" value="Item 2"/>
</div>
```

## Binding to Collections of Complex Types

```html
@for(int i=0; i<2; i++)
{
    <div class="mb-3">
        <label>Name #@i</label>
        <input class="form-control" name="Data[@i].Name"
               value="Product-@i" />
    </div>

    <div class="mb-3">
        <label>Price #@i</label>
        <input class="form-control" name="Data[@i].Price"
               value="@(100+i)" />
    </div>
}
```

## Specifying a Model Binding Source

`FromForm` -- name prop is used to locate a form value

`FromRoute`-- Select the routing system as the source of binding data.

`FromQuery`, `FromHeader`, 

`FromBody`-- which is **required** when you want to receive data from requests that are not `form-encoded`, such as API controller.

```cs
public async Task<IActionResult> Index([FromQuery] long? id) {}
```

The same attributes can be used to model bind properties defined by a page model or a controller. like:

```cs
public class BindingsModel : PageModel {
    [FromQuery(Name="Data")]
    public Product[] Data {get;set;}=Array.Empty<Product>();
}
```

# Model Validation

Model *validation* is the process of ensuring the data received by the app is suitable for binding to the model. Without valiation, an applicatoin will try to operate on any data it receives.

Data provided by the user using the `ModelStateDictionary`object that is returned by the `ModelState`prop inherited from the `ControllerBase`class.

* `AddModelError(prop, message)`-- used to record a model validation error for specified prop.
* `GetValidationState(prop)`-- determine whether there are model validation errors for specific prop.

For the tag helper adds elements whose values have failed validation to the `input-validation-error`class.

To define the js code it can be used both controllers and RPs -- like:

```js
window.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll("input.input-validation-error").forEach(e =>
        e.classList.add("is-invalid"));
});
```

## Displaying Validation Messages

The `ValidationSummaryTagHelper`detects the `asp-validation-summary`attribute on a `div`. The value of the `asp-validation-summary`is a value from the `ValidationSummary`enumeration.

1. `All`-- used to display all the validation errors that have been recorded.
2. `ModeOnly`-- used to display only the validation errors for the entire model.

Implicit validation is simple but effective -- user must provide a value for all props that are defined with non-null, and core must be able to parse the `string`received in the HTTP request into corresponding prop types.

## Performing Explicit Validation

It is done using the `ModelStateDictionary`methods. Fore:

```cs
if(ModelState.GetValidationState(nameof(Product.Price))==
    ModelValidationState.Valid && product.Price<=0)
{
    ModelState.AddModelError(nameof(Product.Price),
        "Enter a positive price");
}

if(ModelState.GetValidationState(nameof(Product.CategoryId))==
    ModelValidationState.Valid && !context.Categories.Any(c=>
    c.CategoryId==product.CategoryId))
{
    ModelState.AddModelError(nameof(Product.CategoryId),
        "Enter an existing category id");
}
```

## Displaying Property-Level Validation Messages

For this kind of error, it is more useful to display the valiation error messages alongside the HTML elements. And the Razor page validation relies on the same feature used in the controller.

## Specifying Validation Rules using Metadata

```cs
[Required(ErrorMessage ="Please enter a value")]
public string Name { get; set; } = string.Empty;

[Range(1,999999, ErrorMessage ="Enter a positive price")]
[Column(TypeName = "decimal(8,2)")]
public decimal Price { get; set; }
```

## Expanding the Model

```cs
[HttpPost]
public IActionResult UpdateProduct(Product product)
{
    if(product.Id==0)
        repository.AddProduct(product);
    else
        repository.UpdateProduct(product);
    return RedirectToAction(nameof(Index));
}
```

## Creating a Data Model Relationship

Adding a Data Model class -- 

```cs
public class Product
{
    public long Id { get; set; }

    public string? Name { get; set; }
    // public string? Category { get; set; }
    public decimal PurchasePrice { get; set; }
    public decimal RetailPrice { get; set; }        

    public long CategoryId { get; set; }
    public Category Category { get; set; } = null!;
}
```

The name of a FK prop is composed of the class name plus the primary key prop name.

## Creating and Applying a Migration

EF core can't store `Category`until the dbs has been updated to match the changes.

## Using a Data Relationship

EF core ignores relationships **unless U explicitly include them in queries**. This means that navigation props such as `Category`defined by the `Product`class will be left `null`by default. The `Include`extension method is used to tell EF core to populate a nav prop.

Just note that the `Find`method cannot be used with the `Include`method. Can see:

```sql
select p.Id, p.CategoryId, ...
FROM Products as p
Inner join
Categories as c
on p.CategoryId=p.Category.Id;
```

So, EF core uses the FK to query for the data it needs to create the `Category`objects.

## Adding Support for Orders

Jujst note the use of the `Include`and `ThenInclude`methods to navigate around the data model and add related data to queries.

UnderPin Rps -- RPS sits at the top of stack that starts with .NET 6.

# Arrays

Ts respects the best practice of keeping to one data type per array by what type of data is initially inside an array. If don't include a type annotation on a variable initially set to an emtpy, treat the array `any[]`. Just note the TSC' s spreading rest is before.

## Tuples

An array of a fixed size -- `tuple`. Just like:

```tsx
let yearAndWarrior: [number, string];
```

Often used in Js destructuring. 

```tsx
let [year, warrior]=Math.random()>.5
?[230, "arch"]: [1828, "rani"];
```

## Interfaces

```tsx
type Poet={
    born: nubmer;
    name:string;
};
interface Poet {
    born: number;
    name:string;
} // almost identical
```

there are a few key differences between interfaces and type aliases-- 

* Interfaces can merge together to be augmented.
* Interfaces can be used to type check the structure of class declaration
* Interfaces are generally speedier for type checker
* error likely to be readable.

```tsx
interface Page{
    readonly text: string;
}

function read(page: Page) {
    console.log(page);
    page.text += "!";  // error
}
```

Ts provides two ways of declaring interface members as functions like:

* Method Syntax -- Declaring a member of the interface is a function intended to be callled as a member of the object like `member():void` or ()=>void.

```ts
interface HasBothFunctionTypes {
    property: ()=>string;
    method(): string;
}
const hasBoth: HasBothFunctionTypes = {
    property: ()=>'',
    method(){
        return '';
    }
};
```

Just note that both forms can receive the `?`.

* Methods cannot be `readonly`, properties can
* Interface merging treats them differently

```ts
type FunctionAlias=(input:string)=> number;
interface CallSignature {
    (input:string):number;
}
```

Call signatures can be used to describe functions that additionally have some user-defined property on them. Ts will recognize a prop added to a function declarations.

```ts
interface FunctionWithCount{
    count: number;
    (): void;
}

let hasCall: FunctionWithCount;

function keepsTrackOfCalls() {
    keepsTrackOfCalls.count += 10;
    console.log(`${keepsTrackOfCalls.count}`);
}

keepsTrackOfCalls.count = 0;
hasCall = keepsTrackOfCalls;
hasCall();
```

## Index Signatures

```ts
interface WordCounts {
    [i: string]: number;
}

const counts: WordCounts = {};
counts.apple = 0;
counts.banana = 1;
counts.cherry = false;  //error
```

So index signatures are convenient for assigning values to an object but aren't completely type safe. They indicate that an object should give a value no matter what property is being accessed. Like:

```ts
interface DatesByName {
    [i:string]:Date;
}
```

## Mixing props and index signatures

```ts
interface HistoricalNovels {
    Oroonoko: number;
    [i: string]: number;
}
```

One common type system trick with mixed props and index signatures is to use a more specific --

```ts
interface ChapterStarts{
    preface: 0;
    [i: string]: number;
}

const correct: ChapterStarts = {
    preface: 0,
    night: 1,
    shopping:5,
}
```

## Numeric Index Signatures

Sometimes use a number type .. order is important. Interface types can also have properties that are themselves interface types.

### Interface Extensions

Ts allows an interface to *extend* another interface, which declares it as copying all members of another.

```ts
interface Writing {
    title: string;
}

interface Novella extends Writing{
    pages: number;
}

let myNovella: Novella = {
    pages: 195,
    title: "Frome",
};
```

One of the important features of interfaces is ability to *merge* with each other.

```ts
interface mergedProp {
    same: (input: boolean) => string;
    default(input: boolean): string;
}

let merged: mergedProp = {
    same(input: boolean) {
        return "abc";
    },
    default(input: boolean) {
        return "abc";
    }
}
```

## Defining and Using Functions

Ts provides support for access controls using the `public`, `private`, and `protected`keywords.

## Working with Reactive Extensions

The key Reactive Extensions building block is an `Observable<T>`, which an observable sequence of events that occur over a period of time. Where the outcome of the request is presented through an `Observable<T>`obj. The generic type arg `<T>`denotes the type of event that the observable produces so that an `Observable<string>`will produce a series of `string`values.

An obj can subscribe to an `Observable`and receive a notification each time an event occurs. Just allowing it to respond only when the event has been observed.

The basic method provided by an `Observable`is `subscribe`, which accepts an object whose properties are set to functions that respond to the sequence of events. If U only need to specify a function that receives events, then you can pass that func as the argument to the subscribe method.

`next, error, complete`

```js
function receiveEvents(observable: Observable<string>) {
	observable.subscribe({
		next: str => {
			console.log(`Event received: ${str}`);
		},
		complete() {
			console.log("Seq ended");
		}
	})
}

function sendEvents(observer: Observer<string>) {
	let count = 5;
	for (let i = 0; i < count; i++) {
		observer.next(`${i + 1} of ${count}`)
	}
	observer.complete();
}

let subject = new Subject<string>();
receiveEvents(subject);
sendEvents(subject);
```

```sh
npm install --save-dev json-server
npm install --save-dev jsonwebtoken
```

Some of the packages are installed using the `--save-dev`argument, which indicates they are used during development and will not be part of the SportsStore application.

The root module only really exists to provide information through the `@NgModule`decorator -- the `imports`property tells Ng that it should load the `BrowserModule`feature module, which contains the core Ng features required for a web app -- the `declarations`should load the root component. `providers`tell about the shared objects...

In `main.ts`file, the development tolls detect the changes to the project's file, compile the code files, and automatically reload the browser.

The `@Injectable`decorator tells Ng that this class will be used as a service.

# grid

Applied `display:grid`to define a grid container.

`grid-template-columns`and `grid-template-rows`-- these define the szie of each of the columns and rows in the grid. `fr`which represents each column's **fraction unit**. `1fr 1fr 1fr`declares three columns with an equal size.

Need to note don't necessarily have to use fraction units. Can use px, em, or percent. Or, can mix and match like:

`grid-template-columns: 300px 1fr`

And, `grid-gap`property defines the amount of space to add to the gutter.

## Anatomy of a grid

* Grid line -- make up the structure of the grid. The `grid-gap`lies atop the grid lines
* Grid track - space between adjacent grid lines.
* Grid cell -- single space on the grid
* Grid area -- rectangle area on the grid made up by one or more grid cells.

To build this layout with grid requires a different HTML structure -- flatten the HTML.

```css
.container {
    display: grid;
    grid-template-columns: 2fr 1fr;

    /* defines 4 horizontal grid tracks of size auto */
    grid-template-rows: repeat(4, auto);
    grid-gap: 1.5em;
    max-width: 1080px;
    margin: 0 auto;
}

header,
nav {
    grid-column: 1/3;
    /* spans from vertical grid line 1 to line 3 */
    grid-row: span 1;
    /* spans exactly one horizontal */
}

.main {
    grid-column: 1/2;
    grid-row: 3/5;
}

.sidebar-top {
    grid-column: 2/3;
    grid-row: 3/4;
}

.sidebar-bottom {
    grid-column: 2/3;
    grid-row: 4/5;
}

.tile {
    padding: 1.5em;
    background-color: #fff;
}

.tile> :first-child {
    margin-top: 0;
}

.tile *+* {
    margin-top: 1.5em;
}
```

Set the grid container and defined its grid tracks using `grid-template-columns`and `grid-template-rows`

`repeat(4, auto)`defines 4 horizontal heigh auto. ==>

`grid-template-rows: auto auto auto auto` fore:

`repeat(3, 2fr 1fr), repeat(3, 3fr) 1fr`

Can use grid numbers to indicate where to place each grid item using the `grid-column`and `grid-row`props. `span 1`tells the browser that the item will *span one grid track*. So the grid item will be placed automatically using the grid item *placement algorithm*. This will position items to fill the first available space on the grid where they fit.

1. Flexbox is bascially 1d, where the grid is 2d
2. Flexbox works from the content out, whereas grid works from the layout in.

Cuz flexbox is 1d, ideal for rows or columns of similar elements. WIth grid, first and foremost desribing a layout.

## Adding Store Features the Product Details

```html
<div class="col-9 text-dark p-2">
    <div *ngFor="let product of products" class="card m-1 p-1 bg-light">
        <h4>
            {{product.name}}
            <span class="badge rounded-pill bg-primary" style="float:right">
                {{product.price | currency: "USD":"symbol":"2.2-2"}}
            </span>
        </h4>
    </div>
</div>
```

It transforms the `div`element by duplicating it for each object returned by the component's `products`prop. Angular includes a feature called *pipes* which are classes used to transform or prepare a data for its 
