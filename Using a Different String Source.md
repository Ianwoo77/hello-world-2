# Using a Different String Source

The functions scan strings from 3 sources -- std input, reader, and a value provided as an argument. Providing a string as the arg is the most flexible like:

```go
source := "Lifejacket Watersports 48.95"
n, err := fmt.Sscan(source, &name, &category, &price)
```

## Using a Scanning Template

```go
source := "Product Lifejacket Watersports 48.95"
template := "Product %s %s %f"
n, err := fmt.Sscanf(source, template, &name, &category, &price)
```

# Math Functions and Data Sorting

`math`package, `math/rand`package, `Shuffle`function, `sort`package, `Search*`functions. In the `math`package, there are:

`Abs, Ceil, Copysign(x,y) `, `Floor, Max, Min, Mod, Pow, Round, RountToEven`

And the provides a set of constants for the limits of numeric data types like:

`MaxInt8, MaxInt64, MaxUint16, MaxFloat64`..

`SmallestNonZeroFloat32`..

## Generating Random Numbers

`Seed, Float32(), Int(), UInt32(), Shuffle(count, func)`

Shuffle:

```go
var names = []string{"Alice", "Bob", "Charlie", "Dora", "Edith"}

func main() {
	rand.NewSource(time.Now().UnixNano())
	rand.Shuffle(len(names), func(first, second int) {
		names[first], names[second] = names[second], names[first]
	})
	for _, name := range names {
		Printfln("%v", name)
	}
}
```

## Sorting Data

`sort`package -- 

`Float64s(slice), Float64sAreSorted(slice), Ints(slice), IntAreSorted(slice), Strings(slice) StringsAreSorted(slice)`

Note that this func sort the elements **in place**. so:

```go
sortInts := make([]int, len(ints))
copy(sortInts, ints)
sort.Ints(sortedInts)
```

## Searching Sorted Data

The `sort`also defines :

`SearchInts(slice, val)`, `SearchFloat64s(slice, val)`

## Sorting Custom Data Types

To sort custom, the `sort`defines an interface named `Interface`.

`len(), Less(i,j), Swap(i,j)` And when the type defines these three, can be sorted using the func.

```go
type Product struct {
	Name  string
	Price float64
}

type ProductSlice []Product

func ProductSlices(p []Product) {
	sort.Sort(ProductSlice(p))
}

func ProductSlicesAreSorted(p []Product) {
	sort.IsSorted(ProductSlice(p))
}

func (products ProductSlice) Len() int {
	return len(products)
}

func (products ProductSlice) Less(i, j int) bool {
	return products[i].Price < products[j].Price
}

func (products ProductSlice) Swap(i, j int) {
	products[i], products[j] = products[j], products[i]
}
```

So the `ProductSlice`is just alias for a `Product`slice and is the type for wihch the interface methods have ben implemented.

## Sorting Using Different Fields

Type composition can be used to support sorting the name strurct type using different fields.

```go
type ProductSliceName struct {
	ProductSlice
}

func ProductSliceByName(p []Product){
	sort.Sort(ProductSliceName{p})
}

func (p ProductSliceName) Less (i,j int) bool {
	return p.ProductSlice[i].Name < p.ProductSlice[j].Name
}
```

For this, A struct type is defined for each struct field for whcih sorting is required like:

`type ProductSliceName struct {ProductSlice}`

Note that the `type composition`feature means that the methods defined for the `ProductSlice`are **promoted to the enclosing type**.

A new `Less`is defined just for enclosing type.

## Specifying the Comparison Function

And, an alternative approach is to specify the expression used to compare elements.

```go
type ProductComparison func(p1, p2 Product) bool

type ProductSliceFlex struct {
	ProductSlice
	ProductComparison
}

func (flex ProductSliceFlex) Less(i, j int) bool {
	return flex.ProductComparison(flex.ProductSlice[i], flex.ProductSlice[j])
}

func SortWith(prods []Product, f ProductComparison) {
	sort.Sort(ProductSliceFlex{prods, f})
}
```

For this, a new created combines the data and the comparison function.

```go
SortWith(products, func(p1, p2 Product) bool {
    return p1.Name > p2.Name
})
```

## Dates, Times, and Durations

`time`package: `Unix(sec, nsec)`-- Creates a Time value from the number of seconds and nanoseconds.

## Formatting Times as Strings

The `Format`is used to create formatted for `Time`values.

```go
func PrintTime(label string, t *time.Time) {
	layout := "Day: 02 Month: Jan Year: 2006"
	fmt.Println(label, t.Format(layout))
}
```

The layout string uses a reference time -- 15:04:05, and Monday, January 2nd 2006, can just use like:

`fmt.Println(label, t.Format(time.RFC822Z))`

## Parsing Time Values from Strings

`Parse(layout, str)`-- parses a string using the specified layout to create a `Time`value.,`ParseInLocation`.

```go
time, err := time.Parse(layout, d)
```

## Creating Durations Relative to a Time

The `time`defines two functions can be used to create `Duration`value that represents the amount of time.

`Since(time)`, `Until(time)` Since(past), until(future).

## Using the Time Features for Goroutines and Channels

The `time`provides a small set of functions.

`Tick(duration)`-- returns a channel that periodically sends a Time value. Fore:

Putting a Goroutine to Sleep, Deferring Execution of a Function -- `AfterFunc`function.

```go
time.AfterFunc(time.Second*5, func() {
    writeToChannel(nameChannel)
})
```

Receiving Timed Notifications -- The `After`func waits for a specified duration and when sends a `Time`value to a channel.

```go
func writeToChannel(channel chan<- string) {
	Printfln("Waiting for initial duration...")
	<-time.After(time.Second * 2)
	Printfln("Initial duration elapsed")
	names := []string{"Alice", "Bob", "Charile", "Dora"}
	for _, name := range names {
		channel <- name
		time.Sleep(time.Second)
	}
	close(channel)
}
```

`<- time.After(time.Second*2)`This use of the `After`introduces an initial delay in the `WriteToChannel`

Using Notifications as Timeouts in Select Statements -- So the `After`can be used with `select`statements.

```go
func main() {
	nameChannel := make(chan string)
	go writeToChannel(nameChannel)

	channelOpen := true
	for channelOpen {
		Printfln("Starting channel read")
		select {
		case name, ok := <-nameChannel:
			if !ok {
				channelOpen = false
				// break

			} else {
				Printfln("Read name %v", name)
			}
		case <-time.After(time.Second * 2):
			Printfln("Timeout")
		}
	}
}
```

The `select`will block until one of the channels is ready or until the timer expires.

## The `r.Form`Map

In the code, accessed the form value via the `r.PostForm`map, but, an alternative approach is to use the (note, differently) `r.Form`*map*.

Note the `r.PostForm`is populated only for `POST, PATCH, and PUT`requests.

In contrast, the `r.Form`is just populated for all requests. and c*ontains the form data from any reuest body*, and any *query string parameters*. if `/snippet/create?foo=bar`, then `r.Form.Get("foo")`. just note, the request body value will just take precedent over the query string parameter.

### The `FormValue`and `PostFormValue`methods

`r.FormValue`and `r.PostFormValue`, essentially shortcut that just call `r.ParseForm()`. These *silently ignore any errors*.

## Multiple-value Fields

`r.PostForm.Get()`just returns the first value for a specific form field.

So need to work with the `r.PostForm`map directly. note that it turns the underlying type `map[string][]string`

```go
for i, item := range r.PostForm["items"]{
    fmt.Fprintf(w, "%d: Item %s\n", i, item)
}
```

### Form Size

fore, sending multipart data -- `enctype="multipart/form-data"`then `POST..`request bodies are limited to 10m.

```go
r.Body=http.MaxBytesReader(w, r.Body, 4096)
```

## Data Validation

Displaying Validation errors and Repopulating Fields -- If there are any validatoin errors want to re-display the form. fore, highlighting the fields...

The underlying type of the `FormErrors`is a `map[string]string`, As map, possible to access the value for a given key by simply postfixing dot with the key name. FORE, to render any error message for the `title`

`{{.FormErrors.title}}`

`FormData`is `url.Values`, can use `Get()`to retrieve the value for the field. can:

`{{.Formdata.Get "title"}}`

`{{$exp := or (.FormData.Get "expires") "356 days"}}` for this -- creating a new `$exp`*template variable* which uses the `or`template function to set the variable to the value yielded by `.FormData.Get "expires"`or empty then default is "365 days"

```html
<input type="radio" name="expires" value="365 days"
       {{if (eq $exp "365 days")}}checked{{end}}> One year
```

`{{if (eq $exp "365 days")}}checked{{end}}`

## Scaling Data Validation

By creating a `forms`package to abstract some of this behavior and reduce the boilerplate code.

# In Action

Blazor server applications run on the server -- Each mouse click or keyboard event is **sent to the server** using **WebSockets**. The server then calculates the changes that should be made to the UI. And, sends the changes required back to the client.

## ASP.NET core and reverse proxies

Can expose directly to the internet. More common to use a reverse proxy -- between the raw network and your application.

They are often reponsible for additional aspects, Kestrel can just remain a simple HTTP server not having to worry about these, when used behind a reverse proxy. FORE: Kestrel is concerned with generating HTTP responses, and the reverse proxy is just concerned with handling the connection to the internet.

Kestrel is responsbile for receiving the request data and constructing a C# representation of the request. But, it doesn' t attempt to generate a response directly. Just hands the `HttpContext`to the middleware pipeline found in every ASP.NET core app.

TIP -- VS and the .NET CLI tools will automatically build your app when run it. Most apps have dependencies on various external libs.

build up the middleware pipeline in core by just calling methods on .. Using extension methods allow to effectively add functionality to the clss.

`app.UseStaticFiles();`

A simple minimal APIs App -- only four pieces of middleware -- routing middleware to choose a minimal API endpoint to execute, endpoint middleware to generate the response.

`app.MapGet("/", ()=>"hello");` 

`app.UseRouting()`needed.

`app.UseExceptionHandler("/error")`

## Creating a JSON API with minimal APIs

mobile app typically communicates with a server app using an HTTP API, receiving data in JSON.

`app.MapGet("/person", ()=> new Person("Andrew", "Lock"));`

`app.MapGet("/person/{name}", name=>_people.Where(p.FirstName.StartsWith(name)));`

## Mapping URLs to endpoints using routing

Routing is just the process of mapping an incoming request to a method that will handle it. To handle more complex application logic, typically use the `EndpointMiddleware`at the end of your middleware pipeline.

Routing in Core is the process of selecting a specific handler for an incoming HTTP request.

DEF -- The query string is part of a URL that contains additional data that doesn't fit in the path. It isn't used by the routing infrastructure for identifying which handler to execute. Core can automatically extract values from the query string in a process -- called model binding.

## Endpoint routing in core

In core 3.0, a new routing system was introduced -- *endpoint routing* -- just makes the routing system a more fundamental feature of core and no longer ties it to the MVC.

Is the fundamental to all but also the simplest core apps.

* `EndpointRoutingMiddleware`-- chooses which of the registered endpoints execute for a given request at runtime.
* `EndpointMiddleware`-- typically placed at the end of your middleware pipeline.

DEF -- An *endpoint* in core is just a handler that returns a response.

## Working with parameters and literal segments

Routing templates have a rich -- like `/product/{category}/{name}`

Segment that use a character..

### Using optional and default values 

`/product/{category}/{name=all}/{id?}`

## Customer Features

### Displaying Products to the Customer

Creating the store controller view and layout... 

## Creating a RESTful Web Service

When adding a web service to an app, it is good idea to just create a separate repository cuz the queries that client side app perform can be different from those of a regular ASP.NET core MVC app.

## Creating the API Controller

Is easy to add web services to an application using std controller features.

```cs
[Route("api/[controller]")]
[ApiController]
public class ProductValuesController : ControllerBase
{
    private IWebServiceRepository repository;
    public ProductValuesController(IWebServiceRepository repo)
    {
        repository = repo;
    }

    [HttpGet("{id}")]
    public object GetProduct(long id)
    {
        return repository.GetProduct(id);
    }
}
```

The most common way to do this is to create a separate part of its clients rather than HTML.

`[HttpGet("{id}")]`-- The attribute's argument extends the URL schema defined by the `Route`. For this, notice that the `category`is set to `null` cuz didn't ask EF core to load the related data for the Product object.

### Projecting a Result to Exclude Null Navigation Properties

```cs
return context.Products
    .Select(p => new
    {
        Id = p.Id,
        Name = p.Name,
        Description = p.Description,
        PurchasePrice = p.PurchasePrice,
        RetailPrice = p.RetailPrice
    }).FirstOrDefault(p => p.Id == id)!;
```

Including Related Data -- 

```cs
return context.Products.Include(p=>p.Category)
    .FirstOrDefault(p=>p.Id==id);
```

Note -- ASP.NET core MVC uses a package called Json.Net to deal with serialization. like:

For simplicity, EF core **by convention** configuration approach to model the dbs. And in the Book App, just navigational properteis that are collections. Use the type `IColletion<T>`.

`context.Books.Where(p=>p.Title.StartsWith("Quantum")).Dump();`

The command shown consists of several methods.. This structure is known a *fluent interface*. the most common way to refer to a dbs table is via a `DbSet<T>`prop.

### The two types of dbs queries

The dbs query called just a normal query -- also known a *read-write* query. This query reads in data from the dbs in such a way that you can just update that data or use it as an existing relationship for new entry.

`context.Books.AsNoTracking().Where(p=>p.Title.StartsWith("Quantum")).Dump();`

Improves the performance of the query by turning off certain EF core features.

When a component is added to the content rendered by a controller view or RPs, the `component`element is used. And , when a component is added to the content rendered by another component, then the name of the component is just used as an element instead.

When combining components, the effect is that one component delegates reponsibility for part of its layout to another.

## Configuring Components with Attributes

```cs
[Parameter]
public string Title { get; set; } = "Placeholder";
```

Components can be selective about the props they allow to be configured.

```cs
[Parameter(CaptureUnmatchedValues =true)]
public Dictionary<string,object>? Attrs { get; set; }
```

This is known as *attribute splatting* -- allows a set of attributes to be applied in one go.

```html
<SelectFilter Values="@Cities" Title="City" autofocus="true" name="city" required="true"/>
```

## Configuring a Component in a Controller View or Razor Page

Attrributes are also used to configure components when they are applied using the `component`element.

```html
<component type="typeof(Advanced.Blazor.PeopleList)" render-mode="Server" 
	param-itemcount="5" param-selecttitle="@("Location")"/>
```

The `param-`provides a value for the property. NOTE: When using the `component`element, attribute values that can be parsed into *numeric* or `bool`are handled as literal values and not Razor expressions. so: other:

`param-selecttitle="@("Location")"`

## Creating Custom Events and bindings

for now the `SelectFilter`component receives its data values from its parent component, but, it has no way to indicate when the user makes a selection. Need to create a custom event for which the parent component can register a handler method.

```html
<select name="select-@Title" class="form-control" 
        @onchange="HandleSelect" value="@SelectedValue">
```

```cs
[Parameter]
public EventCallback<string> CustomEvent{ get; set; }

public async Task HandleSelect(ChangeEventArgs e)
{
    SelectedValue = e.Value as string;
    await CustomEvent.InvokeAsync(SelectedValue);
}
```

This custom event is defined by adding a prop whose type is `EventCallback<T>`-- The generic type arg is the type that will be received by the **Parent**'s handler.

And the `HandleSelect`updates the `SelectedValue`and triggers the custom event by invoking the 

`EventCallback<T>`

```cs
public void HandleCustom(string newValue)
{
    SelectedCity = newValue;
}
```

To set up the event handler, an attribute is added to the element that applies the child component using the name of its `EventCallback<T>`prop.

## Creating a Custom Binding

A parent component can create a binding on a child component if it defines a pair of props. One of which is assigned a data value and the other of which is a custom event.

Note that the **names of the property** is IMPORTANT -- must be the same as the data propperty plus the Word **`Changed`**. Like:

```cs
[Parameter]
public string? SelectedValue{ get; set; }

[Parameter]
public EventCallback<string> SelectedValueChanged{ get; set; }

public async Task HandleSelect(ChangeEventArgs e)
{
    SelectedValue = e.Value as string;
    await SelectedValueChanged.InvokeAsync(SelectedValue);
}
```

In the parent component:

```html
<SelectFilter Values="@Cities" Title="@SelectTitle" 
    @bind-SelectedValue="SelectedCity"/>
```

The parent component binds to the child with the `@bind-<name>`attribute, where `<name>`corresponds to the property is `SelectedValue`

## Displaying Child Content in a Component

Components that display child content act as wrappers around elements provided by parents.

```cs
<div class="p-2 bg-@Theme border text-white">
	<h5 class="text-center">@Title</h5>
	@ChildContent
</div>

@code {
	[Parameter]
	public string? Theme{ get; set; }

	[Parameter]
	public string? Title{ get; set; }

	[Parameter]
	public RenderFragment? ChildContent { get; set; }
}
```

To receive child content, a component defines a property named `ChildContent`whose type is `RenderFragment`and that has been decorated with the `Parameter`. Note that the component in the listing wraps its child content in a `div`that is styled. And Child is defined by adding HTML elements between the start and end tags.

```html
<ThemeWrapper Theme="info" Title="Location Selector">

	<SelectFilter Values="@Cities" Title="@SelectTitle"
				  @bind-SelectedValue="SelectedCity" />

</ThemeWrapper>
```

NOTE: No additional attributes are required to configure the child content.

## Creating Template Components

Template components bring more structure to the presentation of child content, allowing multiple sections of content to be displayed.

And the component defines a `RenderFragment`prop for each region of child content it supports.

```cs
<table class="table table-sm table-bordered table-striped">
	@if (Header != null)
	{
		<thead>@Header</thead>
	}
	<tbody>@Body</tbody>
</table>

@code {
	[Parameter]
	public RenderFragment? Header{ get; set; }

	[Parameter]
	public RenderFragment? Body { get; set; }
}
```

# Generics

```ts
function identity<T>(input: T) {
    return input;
}
```

Arrow functions can also be generic.

`const identity = <T>(input:T)=> input;`

## Explicit Generic Call Types

Note, Ts will default to assuming the `unknown`for any type arg if cannot infer. To avoid defaulting to `unknown`, functions may be called with an explicit generic type arg that explicitly tells Ts what that type arg should be instead.

`logWrapper<string>(input => console.log(input.length));`

## Multiple Function Type parameters

Separated by commas.

```ts
function makeTuple<First, Second>(first: First, second: Second) {
    return [first, second] as const;
}
makeTuple(true, 'abc');
```

## Generic Interfaces

Interfaces may be declared as generic as well. They follow similar generic rules to functions. The built-in `Array`methods are defined in ts are a generic interface.

## Inferred Generic Interface Types

```ts
interface LinkedNode<Value>{
    next?: LinkedNode<Value>;
    value: Value;
}

function getLast<Value>(node: LinkedNode<Value>): Value {
    return node.next ? getLast(node.next) : node.value;
}

let lastDate = getLast({
    value: new Date("09-13-1971"),
});
lastDate;
```

Just note that if an interface declares type parameters, any type annotations referring to that interface must provide corresponding type arguments.

## Generic Classes

```ts
class Secret<Key, Value>{
    key: Key;
    value: Value;

    constructor(key: Key, value: Value) {
        this.key = key; this.value = value;
    }
    getValue(key: Key): Value | undefined {
        return this.key === key
            ? this.value : undefined;
    }
}
```

## Explicit Generic Class Types

`new CurriedCallback<string>((input)=>console.log(input.length))`

Extending Generic Classes

```ts
class Quote<T>{
    lines: T;
    constructor(lines:T){
        this.lines=lines;
    }
}
class SpokenQuoto extends Quoto<string[]> {...}
```

### Implementing Generic Interfaces

```ts
interface ActingCredit<Role>{
    role: Role;
}
class MoviePart implements ActingCredit<string> {...}
```

## Method Generics

```ts
class CreatePairFactory<Key>{
    key: Key;
    //..
    createPair<Value>(value: Value) {
        return {key: this.key, value};
    }
}
```

## Generic Type Aliases

One last in ts that can be made generic with type arg is type aliases.

`type Nullish<T>= T | null | undefined;`

## Generic Modifiers

```ts
interface Quoto<T=string>{value: T}
let expliclit: Quoto<number>...
let implicit: Quoto=...
```

Constrined Generic Types

```ts
function logWithLength<T extends withLength>(input: T) {...}
```

Using `extends`and `keyof`together allows a type parameter to be constrained to the keys of `T`to retrieve from container. like:

```ts
function get<T, Key extends keyof T>(container: T, key: Key) {
    return container[key];
}
```

## Promises

The `Promise`ctor is typed in Ts as taking in a single parameter. like:

```ts
class PromiseLike<Value>{
    constructor(
    	executor: (
        	resolve:(value: Value)=>void,
         	reject: (reason:unknown)=>void,
        )=>void,
    ){...}
}
```

just like:

```ts
const resolveUnknown = new Promise((resolve) => {
    setTimeout(() => {
        resolve('done!')
    }, 1000);
});
resolveUnknown;
```

And its generic `.then`method introduces a new type parameter representing the resovled value.

One quick test that can help show whether a type is necessary for a func is *should be used at least twice*.

## Using Style Bindings

`The <span [style.font-size.px]="fontSizeWithoutUnits">Second</span>`

and the `ngStyle`just allows multiple style prop to be set using a map object.

## Updating the Data in the Application

When Ng performs the bootstrapping, creates an `ApplicationRef`object to represent the app.

# Using the Built-in Directives

`ngIf, ngSwitch, ngFor, ngTemplateOutlet`

Applying a directive without using an HTML element -- use the `ng-container`element. Repeating a block of content -- use the `ngTemplateOutlet`directive.

*ngIf -- * means that this is a micro-template directive.

```html
<div [ngSwitch]="expr">
    <span *ngSwitchCase="expr"></span>
    <span *ngSwitchDefault></span>
</div>

<ng-template
             [ngTemplateOutlet]="myTempl"></ng-template>
```

`ngTemplateOutlet`is used to repeat a block of content in a template.

```html
<!-- behind the scenes, Ng expand like -->
<ng-template ngIf="model.getProductCount()>4">
	<div class="bg-info p-2 mt-1">
		There are more than 4 products.
	</div>
</ng-template>
```

`<span *ngSwitchCase="'Kayak'">There are two</span>`// note that the `''`

## Using the `ngFor`

Providing the template equivalment of a `foreach`loop.

`<tr *ngFor="let item of getProducts()">`denoted by the `let`keyword.

## Using Other Template Variables

The `ngFor`supports a range of other values that can also be assigned to variables.

`index`-- assigned to the position of the current object

`count`-- number of elements in the data source

`odd, even`-- odd or even number position

`first, last`true if first or last.

`<tr *ngFor="let item of getProducts();let i=index; let c=count">`

```html
<tr *ngFor="let item of getProducts();let i=index; let c=count; let first=first; 
            let last=last;
    let odd=odd" class="text-white" [class.bg-primary]="odd" [class.bg-info]="!odd"
[class.bg-warning]="first||last">
```

## Minimizing Element Operations

Note -- when the `ngFor`examines its data source -- two operations to perform to reflect the change to the data. first is to destroy the HTML, second is to create a new set of HTML elements.

To improve, define a component method -- 

`... let odd=odd; trackBy:getKey" `

## Using the `ngTemplateOutlet`

Used to repeat a block of content at a specified location.

First is to define the template that contains the content that you want to repeat using the directive. Done by using the `ng-template`element and assigning a name using for `reference variable`.

```html
<ng-template #titleTemplate let-title="title"></ng-template>
<ng-template [ngTemplateOutlet]="titleTemplate"></ng-template>
```

## Providing Context Data

The `ngTemplateOutlet`can be used to provide the repeated content with a context object.

```html
<ng-template #titleTemplate let-text="title">
	<h4 class="p2 bg-success text-white">{{text}}</h4>
</ng-template>

<ng-template [ngTemplateOutlet]="titleTemplate"
	[ngTemplateOutletContext]="{title:'Header'}"></ng-template>

<div class="bg-info p-2 m-2 text-white">
	There are {{getProductCount()}} products.
</div>

<ng-template [ngTemplateOutlet]="titleTemplate"
	[ngTemplateOutletContext]="{title:'Footer'}"></ng-template>
```

## Using Directives Without an HTML Element

The `ng-container`can be used to apply just directive without using an HTML element. Can be useful when U want to generate content without adding to the structure of the HTML. like:

```html
<ng-container *ngFor="let item of getProducts(); let last=last">
    {{item.name}}<ng-container *ngFor="!last">,</ng-container>
</ng-container>
```

So, the `ng-container`element doesn't appear in the HTML displayed by the browser, which means it can be used to apply the `ngFor`.

# Relative Positioning

The `top, right, bottom left`applied if, will shift the element. won't change the position of any element around it. When positioning, negative values are supported too. And note -- unlike fixed and absolute positioning, Cannot use `top..`to change the size of a relatively positioned element.

## Creating a dropdown Menu

Use relative and absolute positioning to create a dropdown menu.

```css
.container {
    width:80%;
    max-width: 1000px;
    margin: 1em auto;
}

.dropdown{
    display: inline-block;
    position:relative;
}

.dropdown-label {
    padding: .5em 1.5em;
    border: 1px solid #ccc;
    background-color: #eee;
    cursor: pointer;
}

.dropdown-menu{
    display:none; /*initial hide*/
    position: absolute;
    left:0;
    top:2.1em;
    min-width: 100%;
    background-color: #eee;
}

.dropdown:hover .dropdown-menu{
    display: block;
}

.submenu {
    padding-left: 0;
    margin:0;
    list-style-type: none;
    border: 1px solid #999;
}

.submenu> li + li {
    border-top: 1px solid #999;
}

.submenu > li > a {
    display: block;
    padding: .5em 1.5em;
    background-color: #eee;
    color:#369;
    text-decoration: none;
}

.submenu > li > a:hover {
    background-color: #fff;
}
```

`.dropdown:hover .dropdown-menu`-- when move mouse pointer over the Main menu label -- menu pops up. Just use the `:hover`state of the whole container to open the menu. Then used `top:2.1em`to place its top edge.

NOTE that, need to use the js to add and remove a class that controls whether the menu is opened.

## Creating a CSS triangle

Positioning is useful -- important to know the ramifications involved.

Need to ensure elem doesn't accidentally overflow outside the browser. It's important to understand how the browser determines the stacking order. Also creates another tree structure called the *render tree*. The order is determined by the order the elements appear in the HTML.

This changes when start positioning -- The browser first paints **all non-positioned** elements. And by default, any positioned appears in front of any non-positioned.

So on page, this means that both the modal and dropdown appear in front of static. So, one way to fix this would be to move the `<div class="modal">`after..

Relative positioning depends on the document flow, and abs depends on its **positioned** ancestor elements.

## Manipulating Stacking order with Z-index

The Z-index can be set to any integer, and pos, and neg. Z can be  used to fix stacking. like:

```css
.modal-backdrop {
    z-index: 1;  // in front of elements without z-index
}
.modal-body{
    z-index :2 ;// in front of backdrop
}
```

Z-index -- using it two gotchas - *only works on positioned elements*. 

Applying establishes :

## Statcking Contexts

*stacking context* consists of an element or a group of elements that are painted together by the browser. When add z-index to positioned -- become a root of new stacking context -- All of its descendant are then parts of the context.

## Sticky Positioning

sort of hybrid between relative and fixed.

```css
.container {
    display: flex;
    width: 80%;
    max-width: 1000px;
    margin: 1em auto;
    min-height: 100vh;
}

.col-main{
    flex: 1 80%;
}
.col-sidebar{
    flex:20%;
}

.affix{
    position: sticky;
    top: 1em;
}

```

min-height, artifically adds height to the container.

1) A *mobile first approach to design* -- build your the mobile version before desktop.
2) The `@media`at-rule. Can tailor your styles for viewports of different sizes. This (media queries) lets you write styles only apply under certain conditions.
3) The *use of fluid layout* -- allows containers to scale to different sizes based on the width of viewport.

## Mobile First

Build your mobile layout first -- best way to ensure both work.

IMPORTANT -- when writing the HTML for a responsive design, it's important to ensure it has everything you need for each screen size. Can apply different CSS -- but must all share the same HTML..