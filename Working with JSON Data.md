# Working with JSON Data

The `encoding/json`package provides support for encoding and decoding JSON data.

json package -- 

`NewEncoder` -- returns an `Encoder`can be used to encode JSON data and write it to the specified `Writer`

`NewDecorder`-- returns a `Decoder`used to read JSON, read from the `Reader`and decode it.

Also -- 

`Marshal(value)`-- encodes as JSON, results are the JSON content expressed in byte slice and an `error`

`Unmarshal(byteslice, val)`-- parse JSON data

And the `NewEncoder`has:

`Encode(val)`-- encodes the specified as JSON, and write to `Writer`, `SetEscapeHTML(on)`, and `SetIndent(prefix, indent)`. fore:

```go
var writer strings.Builder
encoder := json.NewEncoder(&writer)
for _, val := range []interface{} {b, str, fval...} {
    encoder.Encode(val)
}
fmt.Print(writer.String())
// note that JSON Encoder adds a newline after each value is encoded.
```

## Encoding Array and Slices

Just note that the Byte arrays -- encoded as `base64-encoded`strings.

Maps -- maps are encoded as JSON objects. Structs -- **unexported fields are ignored**. Understanding the Effect -- When a struct defines an embedded field -- promoted like:

```go
type DiscountedProduct struct {
    *Product
    Discount float64
}
//...
dp := DiscountProduct{Product: &Kayak, Discount: 10.50}
encoder.Encode(&dp)
```

## Customizing the JSON Encoding of Structs

```go
type DiscountedProduct struct {
	*Product `json:"product"`
	Discount float64
}
```

Omitting -- `Discount float64 ``json:"-"`

```go
type DiscountProduct struct {
    *Product `json:"product,omitempty"`
}
```

And to skip a `nil`without changing the name , like:

```go
*Product `json:",omitempty"`
```

Forcing fileds to be Encoded as Strings -- fore:

```go
Discount float64 `json:",string"`
// note that the additional string overrides the default encoding.
```

## Encoding Interfaces

The JSON encoder can be used on values assigned to interface variables, it is the dynamic type that the encoded. Add a file named `interface.go`

```go
func main() {
	dp := DiscountedProduct{
		Product:  &Kayak,
		Discount: 10.50,
	}
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	nameItems := []Named{&dp, &Person{PersonName: "Alice"}}
	encoder.Encode(nameItems)
	fmt.Print(writer.String())
}
```

So, The slice of `Named`values contains different dynamic types, which can be seen by compiling and executing.

## Creating Completely Custom JSON Encodings

Note that the `Encoder`checks to see whether a struct implements the `Marshaler`interface, which denotes a type that has a custom encoding and which defines the method.

- MarshalJSON() -- this is invoked to create a JSON representation of a value and returns a byte slice containgin the JSON and an `error`encoding problems.

```go
func (dp *DiscountedProduct) MarshalJSON() (jsn []byte, err error) {
	if dp.Product != nil {
		m := map[string]interface{}{
			"product": dp.Name,
			"cost":    dp.Price - dp.Discount,
		}
		jsn, err = json.Marshal(m)
	}
	return
}
```

So the `MarshalJSON`method can generate JSON in any way that suits the project, and the most reliable approach is to use the support for encoding maps.

## Decodeing JSON Data...

# Performing Data Operations

## Reading data

To understand how EF core works -- best querying the dbs and retrieving the data it contains. The key to the data operations used in this is just the `DbSet<T>`class -- which is used as the result for the properties defined by the dbs context class.

`Find(key)`

```cs
public Product GetProduct(long id)
{
    return context.Products.Find(id)!;
}
```

```html
<div class="m-1 p-2">
	<form asp-action="Index" method="get" class="d-inline">
		<label class="m-1">Category:</label>
		<select name="category" class="form-control">
			<option value="">All</option>
			<option selected="@(ViewBag.category == "Watersports")">
				Watersports
			</option>
			<option selected="@(ViewBag.category == "Soccer")">Soccer</option>
			<option selected="@(ViewBag.category=="Chess")">Chess</option>
		</select>
		
		<label class="m-1">Min Price:</label>
		<input class="form-control" name="price" value="@ViewBag.price" />
		<button class="btn btn-primary m-1">Filter</button>
	</form>
</div>
```

The new elements present the user with a `select`element to pick a category and with an `input`element to specify a minimum price.

```cs
public IEnumerable<Product> GetFilteredProducts(string category=null,
    decimal? price = null)
{
    IQueryable<Product> data = context.Products;
    if (category != null)
    {
        data = data.Where(p=>p.Category== category);
    }
    if (price != null)
    {
        data = data.Where(p => p.Price >= price);
    }
    return data;
}
```

`form-inline` -- 

```html
<form asp-action="Index" method="get" class="d-inline-flex flex-row align-items-center">
```

The query is built up based on whether values have been received for the `category`and `price`parameters.

# Advanced Blazor Features

explain how Blaozr supports URL routing so that multiple components can be displayed through a single request. Showed you how to set up the routing system, how to define routes, and how to create common content in a layout.

This also covers the component lifecycle -- which allows componetns to participate actively in the Blazor environment, which is just especially important once you start using the URL routing features.

* The routing feature allows components to respond to changes in the URL **without** requiring a new HTTP connection -- The lifecycle feature allows component to define methods that are invoked as the app executes, and the interaction features provide useful ways of communicating between componetns and with other Js code.
* URL routing is set up using built-in components and configured using `@page`directives. The lifecycle features is just used by overridding methods in a component's `@code`section.

## Using Component Routing

Blazor includes support for selecting the components to display to the user based on the ASP.NET core routing system so that the app responds to changes in the URL by displaying different Razor components. To get, add a Razor Component named `Routed.razor`to the Blazor:

```xml
<Router AppAssembly="typeof(Program).Assembly">
	<Found>
		<RouteView RouteData="@context" />
	</Found>
	<NotFound>
		<h4 class="bg-danger text-white text-center p-2">
			No matching Route Found
		</h4>
	</NotFound>
</Router>
```

So the `Route`component is included with ASP.NET core and provided the link between Blazor and the Core routing features. `Router`is a generic template component that defines `Found`and `NotFound`sections.

The `Router`component require the `AppAssembly`attriute, which specifies the .NET assembly to sue.

And the type of the `Router`component's `Found`is just the `RenderFragment<RouteData>`, which is passdon to the `RouteView`through its `RouteData`prop.

The `RouteView`is just responsible for displaying the componetn matched by the current route and, as explain shortly, for displaying common content through layouts. The type of the `NotFound`prop is also `RenderFragment`without generic arg, and displays a section of conent when no component cna be found.

## Preparing the RPs

Individual components can be displayed in existing controller views and Rps, But, when using component, it is just preferable to create a set of URLs that are distinct to working with Blazor.

Just add a RP anmed `_Host.cshtml`to the Pages folder like:

```html
@page "/"
@{ Layout = null;}

<!DOCTYPE html>
<html>
<head>
    <title>@ViewBag.Title</title>
    <link href="~/lib/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" />
    <base href="~/" />
</head>

<body>
<div class="m-2">
    <component type="typeof(Advanced.Blazor.Routed)" render-mode="Server" />
</div>
<script src="_framework/blazor.server.js"></script>
</body>
</html>
```

This page just contains a `component`element that applies the `Routed`component and a `script`element for the `Blazor`Js code. There is also a `link`for the css. Need to alter the configuration for the example application to use the `_Host.cshtml`file as a fallback when requests are not matched by existing URL routes in the Program.cs:

`app.MapFallbackToPage("/_Host");`

This method configures the routing system to use the `_Host`page as the last resort for unmatched requests.

## Adding Routes to Components

Components declare the URLs for which they chould be displayed using `@page`directives like:

Setting a Default Component Route -- And the configuration change sets up the fallback route for requests, A corresponding is required -- like:

`@page "/people"`
`@page "/"`

## Navigating Between Routed Components

The basic routing configuration is in place.

`html

`<NavLink class="btn btn-primary" href="/depts">Departments</NavLink>`

Note that unlike anchor elements used in other parts of Core, `NavLink`componetns are configured using URLs and note component, page or action names. Note the `NavLink`in this example navigates to the URL supported by the `@page`directive of the `DepartmentList`component.

```html
<button class="btn btn-primary" @onclick="HandleClick">People</button>
```

`public void HandleClick() => NavManager?.NavigateTo("/people");`

So the `NavigatorManager`class provides programmatic access to navigation -- 

- `NavigateTo(url)`-- navigates to the specified URL
- `ToAbsoluteUri(path)`-- Converts a relative path to a complete URL
- `ToBaseRelativePath(url)`-- gets relative from a complete
- `LocationChanged`-- this event is triggered when the location changes
- `Uri`-- This property returns the current URL.

# Applying a Custom Directive

There are two steps to apply a custom directive. The first is to update the template so that there are one or more elements that match the `selector`that the directive uses.

`<tr *ngFor="let item of getProducts(); let i=index" pa-attr>`

The directive's selector matches any element that has the `pa-attr`attribute, regardless of whether a value has been assigned to it or what that value is. The second step to applying a directive is to change the configuration of the Angular module.

```ts
@NgModule ({
    declaration: [ProductComponent, PaAttrDirective],
    //...
})
```

The `declarations`property of the `NgModule`decorator declares the directives and components that the app will use. Don't worry if the relationship and differences between directives and componetns.

## Accessing Application Data in a Directive

The example in the previous section just shows the basic structure of a directive, but it doesn't do anything that couldn't be performed just by using a `class`property binding on the `tr`element.

```html
<td pa-attr pa-attr-class="table-warning">{{item.category}}</td>
<td pa-attr pa-attr-class="table-info">{{item.price}}</td>
```

The `pa-attr`attribute has been applied to two of the `td`elements, along with a new attribute called just `pa-attr-class`which has been used to specify the class to which the directive should add the host element.

```ts
export class PaAttrDirective {
    constructor(element: ElementRef, @Attribute("pa-attr-class") bgClass:string) {
        element.nativeElement.classList.add(bgClass || "table-success", "fw-bold");
    }
}
```

To receive the value of the `pa-attr-class`attribute, just add a new ctor parameter called `bgClass`to which the `@Attribute`decorator has been applied. This decorator is defined in the `@angular/core`module, and it specifies the name of the attribute that should be used to provide a value for the constructor parameter when a new instance of the directive class is created. Angular creates a new instance of the decoarator for each element that matches the selector and uses that element's attributes to provide the value for the directive constructor arg.

And within the ctor, the vlaue of the attribute is passed to the `classList.add`, with a default value allows the directive to be applied to elements that have the `pa-attr`attribute but note the `pa-attr-class`attribute.

## Using a single HOST Element Attribute

```html
<tr *ngFor="let item of getProducts(); let i = index" pa-attr>
    <td>{{i+1}}</td>
    <td>{{item.name}}</td>
    <td pa-attr="bg-warning">{{item.category}}</td>
    <td pa-attr="bg-info">{{item.price}}</td>
</tr>
```

## Creating Data-Bound Input properties

The main limitation of reading attributes with `@Attriute`is that values are static -- The real power in Angular directives comes through support for expressions that are updated to reflect changes in the app state and that cna respond by changing the host element.

And, Directive receive expressions using *data-bound input properties* -- also known as *input properties*, or inputs.

```html
<tr *ngFor="let item of getProducts(); let i = index"
[pa-attr]="getProducts().length<6?'bg-success':'bg-warning'">
    <td>{{i+1}}</td>
    <td>{{item.name}}</td>
    <td [pa-attr]="item.category=='Soccer'?'bg-info':null">{{item.category}}</td>
    <td [pa-attr]="'bg-info'">{{item.price}}</td>
</tr>
```

```ts
@Directive({
	selector: "[pa-attr]",
})
export class PaAttrDirective implements OnInit {
	constructor(private element: ElementRef) {
	}

	@Input("pa-attr")
	bgClass: string | null = "";

	ngOnInit() {
		this.element.nativeElement.classList.add(this.bgClass || "bg-success",
			'fw-bold');
	}
}
```

So, Input properties are defined by applying the `@Input`decorator to a property and using it to sepcify the name of the attribute that contains the expression -- This listing defines a single input property, which tells Angular to set the value of the directive's `bgClass`prop to the value of the expression contained in the `pa-attr`attribute.

The role of the ctor has changed in this -- When Ng creates a new instance of a directive class, the ctor is invoked to *create a new directive object*, and only when is the value of the input property set. To address this, directives can implement *lifecycle hook* methods -- like:

`ngOnInit`-- called after Ng has set the initial value for all the input props.

`ngOnChanged`-- called when the value of an input prop has changed, and also before `ngOnInit`.

...

`ngOnDestroy`-- called immediately before ng destroys a directive.

To set the class on the host element, the directive implements the `ngOnInit`method, which is called after Angular has set the value of the `bgClass`property, The constructor is still needed to receive the `ElementRef`obj that provides access to the host element.

The result is that Ng will create a directive object for each `tr`.

## Responding to Input Property Changes

Something odd happened -- Adding a new affected the appearance of the new elements but not existing. Behind, Ng has updated the value of the `bgClass`for each of the directives that it created -- one for each `td`in the table -- but  the directives didn't notice -- *changing a prop doesn't automatically cause directive to respond.* just:

```ts
ngOnChanges(changes: SimpleChanges) {
    let change:SimpleChange = changes['bgClass'];
    let classList: DOMTokenList = this.element.nativeElement.classList;
    if (!change.isFirstChange() && classList.contains(change.previousValue)) {
        classList.remove(change.previousValue);
    }
    if (!classList.contains(change.currentValue)) {
        classList.add(change.currentValue);
    }
}
```

 Should note that the `ngOnChanges`is called once before the `ngOnInit`and then called again each time there are cahnges to any of **directive's input properties**. Its parameter is a `SimpleChanges`-- which is a map, whose keys refer to each changed input prop and whose values are `SimpleChange`objects.

- `previousValue`-- returns the previous value of the input prop.
- `currentValue`-- returns the curent value of the input
- `isFirstChange`-- method returns `true`if the call to the `ngOnChanges`occurs before the `ngOnInit`.

When responding to changes to the input prop value, a directive has to make sure to account for the effect of previous updates.

## Creating Custom Events

*output prop* are the Ng feature that allows directives to add custom events to their host elements, through which details of important changes can be sent to the rest of the application.

```ts
constructor(private element: ElementRef) {
    this.element.nativeElement.addEventListener('click', () => {
        if (this.product != null) {
            this.click.emit(this.product.category);
        }
    })
}

@Input("pa-attr")
bgClass: string | null = "";

@Input("pa-product")
product: Product = new Product();

@Output("pa-category")
click = new EventEmitter<string>();
```

The `EventEmitter<T>`interface provides the event mechansim for ng directives. Creates an `EventEmitter<string>`obj and assings a variable called `click`.

`string`indicates that listeners to the event will receive a `string`when event is triggered. Common type is `string`or `number`.

The most important is that uses the `EventEmitter<string>`to send the event. `emit()`method is the value that you want the event listener to receive. -- triggers the custom event assocaited with the `EventEmitter`.

```html
<tr *ngFor="let item of getProducts(); let i = index"
			[pa-attr]="getProducts().length<6?'bg-success':'bg-warning'"
			[pa-product]="item" (pa-category)="newProduct.category=$event">
```

The term `$event`is used to access the value the directive passed to the `EventEmitter<string>.emit()`. namely the `this.product.category`. `this.product`is just the item.. click event on the `tr`element.

Behind the scenes, Ng uses the Rxjs to distributre events.

# Modular CSS

Means breaking the page up into its component parts. These parts should be reusable in multiple contexts, and they should not directly depend upon one another. modular styles allow you to impost order.

With encapsulation in mind, define a module for each discreate component on the page.

## Laying the groundwork

Create a *modifier* by defining a new class name that begins with the module's name. fore: message-error By including the module name, clearly indicate that this class belongs with the Message module.

```css
.message--success {
    color: #2f5926;
    border-color: #2f5926;
    background-color: #cf38c9;
}

.message--warning {
    color: #594826;
    border-color: #594826;
    background-color: #e8dec9;
}

.message--error {
    color:#59262f;
    border-color: #59262f;
    background-color: #e8c9cf;
}
```

## Button Module Variants

like:

```css
.button {
    padding: 0.5em .8em;
    border: 1px solid #265559;
    border-radius: .2em;
    background-color: transparent;
    font-size: 1rem;
}

.button--success {
    border-color: #cfe8c9;
    color: #fff;
    background-color: #2f5926;
}

.button--danger {
    border-color: #e8c9c9;
    color: #fff;
    background-color: #a92323;
}

.button--small {
    font-size: 0.8rem;
}

.button--large {
    font-size: 1.2rem;
}
```

```html
    <button class="button button--large">Read more</button>
    <button class="button button--success">Save</button>
    <button class="button button--danger button--small">Cancel</button>"
```

## Don't write context-dependent Selectors

1. must decide where this code belongs.
2. has incrementally increased the selector specificity.
3. Later, find you need this dark dropdown in another context.

## Modules with multiple elements

Fore, module consists of 4 elements, div includes an image and a body, and inside the body is the title. For the image and the body, will use the class name `media__image`and `media__body`. FORE:

```css
.media {
    padding: 1.5em;
    background-color: #eee;
    border-radius: 0.5em;
}

.media::after {
    /* clear fix */
    content: "";
    display: block;
    clear: both;
}

.media__image {
    float: left;
    margin-right: 1.5em;
}

.media__body {
    overflow: auto;
    margin-top: 0;
}

.media__body>h4 {
    margin-top: 0;
}
```

## Use Variant and Sub-elements together

Can also create variations of the module -- trivial to make a version where the image flots right like:

```css
.media--right>.media__image{
    float:right;
}
```

```html
<div class="media media--right"...>
    ...
</div>
```

This rule overrides the media image's original `float:left`.

## Modules composed into larger structures

For, your modules should each be responsible for one thing.
