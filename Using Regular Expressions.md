# Using Regular Expressions

`Match, MatchString(pattern, s), Compile, MustCompile`

## Compiling and Reusing Patterns

The full power of REG is accessed through `Compile`func. Compiles a regex pattern so that can be reused. like:

`fmt**.**Println("Desc:", pattern**.**MatchString(desc))`

`MatchString(s), FindStringIndex(s), FindAllStringIndex(s, max), FindString(s), FindAllString, Split(s, max)`

```go
func main(){
	pattern := regexp.MustCompile("K[a-z]{4}|[A-z]oat")
	desc := "Kayak, A boat for one person"
	firstIndex := pattern.FindStringIndex(desc)
	allIndices := pattern.FindAllStringIndex(desc, -1)

	fmt.Println("First index", firstIndex[0], "-", firstIndex[1], "=", getSubstring(desc, firstIndex))
	for i, idx := range allIndices{
		fmt.Println("Index", i, "=", idx[0], "-", idx[1], "=", getSubstring(desc, idx))
	}
}
```

If don't need to know the location of the matches, the `FindString`and `FindAllString`.

## Splitting strings using Regex:

```go
func main() {
	pattern := regexp.MustCompile(" |boat|one")
	desc := "Kayak. A boat for one person"
	split := pattern.Split(desc, -1)
	for _, s := range split {
		if s != "" {
			fmt.Println("Substring:", s)
		}
	}
}
```

## Using Subexpressions

Allow parts of a regular expression to be accessed.

```go
func main() {
	pattern := regexp.MustCompile("A ([A-z]*) for ([A-z]*) person")
	desc := "Kayak. A boat for one person."
	subs := pattern.FindStringSubmatch(desc)
	for _, s := range subs {
		fmt.Println("Match:", s)
	}
}
```

## Using named Subexpressions

```go
func main() {
	pattern := regexp.MustCompile("A (?P<type>[A-z]*) for (?P<capacity>[A-z]*) person")
	desc := "Kayak. A boat for one person."
	subs := pattern.FindStringSubmatch(desc)
	for _, name := range []string{"type", "capacity"} {
		fmt.Println(name, "=", subs[pattern.SubexpIndex(name)])
	}
}
```

## Replacing Substrings using a regexp

`ReplaceAllString, ReplaceAllLiteralString, ReplaceAllStringFunc`

```go
func main() {
	pattern := regexp.MustCompile("A (?P<type>[A-z]*) for (?P<capacity>[A-z]*) person")
	desc := "Kayak. A boat for one person."
	replaced := pattern.ReplaceAllStringFunc(desc, func(s string) string {
		return "This is the replacement content"
	})
	fmt.Println(replaced)
}
```

## Formatting and Scanning Strings

Formatting is the process of composing a new string from one or more data values.

### Writing Strings

The `fmt`.. fore:

## Using the Formatting Verbs

- %v -- displays the default format for the value., `%+v`includes field names when writing struct
- `%#v`-- display could be used to re-create the value in a go code file
- `%T`-- display Go type of a value

```go
func Printfln(template string, values ...interface{}) {
	fmt.Printf(template+"\n", values...)
}

func main() {
	Printfln("Value: %v", Kayak)
	Printfln("Go syntax: %#v", Kayak)
	Printfln("Type: %T", Kayak)
}

```

## Controlling Struct Formatting

Go has a default format for all data types that the `%v`relies on. The default verb can be modified with a plus sign to include the field names in the output.

And the `String`method by the `Stringer`interface will be used to obtain a string rep of any type that defines it.

```go
func (p Product) String() string {
	return fmt.Sprintf("Product: %v, Price: $%4.2f", p.Name, p.Price)
}
//.. cuz:
type Stringer interface {
    String() string
}
```

The `String()`will be invoked automatically when a string representation of a `Product`value is required.

%b, %d, %o, %O, %x, %X.

%g -- verb adapts to the value it displays. %G -- .

For the `-`, substracts, adds padding to the right of the number.

```go
Printfln("string: %s", name)
Printfln("Character: %c", []rune(name)[0])
Printfln("Unicode: %U", []rune(name)[0])
```

Boolean -- %t, Pointer, %p(note that)

## Scanning Strings

`Scan(...vals), Scanln(...vals), Scanf(template, ...vals), Fscan(reader, ...vals)`

`Fscanln, Fscanf, Sscan, Sscanf, Sscanln`.

```go
var name string
var category string
var price float64

fmt.Print("Enter text to scan...")
n, err := fmt.Scan(&name, &category, &price)
```

The `Scan`function has to convert the substrings it receives into Go values and will report an error.

## Dealing with NewLine Characters

By default, scanning treats newlines in the same way as spaces. So the `Scan`function doesn't stop looking for values until after it has received the number it expects.

`n, err := fmt.Scanln(&name, &category, &price)`In this situation, when first press the Enter, the newline will terminate the input.

## Using Different String Source

```go
source := "Lifejacket Watersports 48.95"
n, err := fmt.Sscan(source, &name, &category, &price)
```

The first arg to the `Sscan`is the string to scan, but in all other respects, the scanning process is the same.

## Request Logging middleware

```go
func (app *application) logRequest(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
        app.infoLog.Printf(...)
        next.ServeHTTP(w,r)
    })
}
// ...
return app.logReqeust(secureHeader(mux))
```

## Panic Recovery

Go's HTTP server assumes that the effect of any panic is isolated to the goroutine serving the active HTTP req. Specially -- following a panic our server will log a stack trace to the server error log. So importantly -- any panic in handlers **won't** bring down your server.

A neat way of doing this is to create some middleware which recovers the panic and just calls our `app.serverError()`method.

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil { // check if there has been a panic
				w.Header().Set("Connection", "close")
				app.serverError(w, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

And it's important to realise this middleware will only recover panics that happen in the *same gorotine* that executed the `recoverPanic()` -- If are spinning up additional goroutines from within your web app -- must make sure that you recover any panics from within those too.

```go
func myHandler(w http.ResponseWriter, r *http.Request) {
    go func() {
        defer func() {
            ... // recover codebase
        }()
        dosthelse()
    }()
    w.Write([]byte("OK"))
}
```

## Composable Middleware Chains// RESTful Routing

* For GET /snippet/create -- requests show the user the HTML form
* For POST /snippet /create -- process this form data and then insert a new snippet into dbs.

Making these changes would give an app routing structure that follows the fundamental principles of `REST`. Go's Servemux doesn't support method based routing or semantic URLs with variables in them.

Fore, `bamizerany/pat`, or `gorilla/mux`

The basic syntax for creating a router and registering a route with the `bmizerany/pat`:

```go
mux := pat.New()
mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))
```

Just note -- Pat doesn't allow to register handler directly, need convert to the `http.HandlerFunc`.

```go
func (app *application) routes() http.Handler {
	standardMiddleware := alice.New(app.recoverPanic, app.logRequest, secureHeaders)

	mux := pat.New()
	mux.Get("/", http.HandlerFunc(app.home))
	mux.Get("/snippet", http.HandlerFunc(app.showSnippet))
	mux.Post("/snippet/create", http.HandlerFunc(app.createSnippet))
	mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))

	fileServer := http.FileServer(http.Dir("./ui/static/"))
	mux.Get("/static/", http.StripPrefix("/static", fileServer))

	return standardMiddleware.Then(mux)
}
```

Note that the URL patterns work in the same way as the Go's inbuilt servermux. And remember that the `/`is a special case.

## Processing Forms

The high-level workflow for processing this form follow a std `post-redirect-Get`pattern. Namely, if it passes validation checks, the data for the new snippet will be added to the dbs and then redirect to `/snippet/:id`.

Just need to send 3 form values, `title, content, expires` Then add to the navigation bar.

## Parsing Form Data

Break this down into two distinct steps --

- Use the `r.ParseForm`to parse the request body. will check the request body is well-formed, then stores the form data in `r.PostForm`**map**. If there any errors when parsing, will return an error. `r.ParseForm()`is just idempotent -- can safely called multiple times on the same request without side-effects.
- Then get the form data contained in the `r.PostForm`by using the `r.PostForm.Get()`.like:

`r.PostForm.Get("title")`and if there no matching will return empty string "".

# Resource Filters

Re executed twice for each request -- before model binding and again before the action result is processed to generate the result. just:

```cs
public interface IResourceFilter: IFilterMetadata {
    void OnResourceExecuting...;
    void OnResourceExecuted...
}
```

ING is called when a request is being processed, and the ED is called after the endpoint has handled the request, but before actoin result is executed. Note that the Async edition -- single method receives a context object and delegate to invoke. FORE: Had... short-circuit, no.. next()...

## Understanding Action Filters

Also executed twice -- are executed after the model binding, (resource executed before mb) Actions are required when MB is required.

Implementing an Action Filter using base class -- Also be implemented by deriving from the `ActionFilterAttribute`class.

## Using the Controller Filter Methods

The `Controller`implements the `IActionFilter`...

```cs
public override void OnActionExecuting(ActionExecutingContext context)
{
    if(context.ActionArguments.ContainsKey("message1")) {
        context.ActionArguments["message1"] = "New Message through overridding";
    }
}
```

## Understanding the Page Filters

Page filters are the RPs equivalment of action filters -- `IPageFilter`interface. But 3:

`OnPageHandlerSelected, OnPageHandlerExecuting, OnPageHandlerExecuted`. Like:

```cs
public void OnPageHandlerExecuting(PageHandlerExecutingContext context) {
    if(context.HandlerArguments.ContainKey("message1")){
        context.HandlerArguments["message1"]="New Message";
    }
}
```

Need to note also, can be overridden directly in the `PageModel`.

## Creating Form Applications

Go through the process of creating controllers, views, and RPs that support an application with create, read, update and delete functionality.

### Creating an MVC Forms Application

```html
<div class="mb-3">
    <label asp-for="Product.SupplierId"></label>
    <div>
        <span asp-validation-for="Product.SupplierId" class="text-danger"></span>
    </div>
    <select class="form-control" asp-for="Product.SupplierId"
            readonly="@Model?.Readonly"
            asp-items="@(new SelectList(Model?.Suppliers, "SupplierId", "Name"))">
        <option value="" disabled selected>Choose a Supplier</option>
    </select>
</div>
```

## Reading Data

Creating the Paginated Collection Class

```cs
public class PagedList<T>: List<T>
{
    public int CurrentPage { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }

    public bool HasPreviousPage => CurrentPage > 1;
    public bool HasNextPage => CurrentPage < TotalPages;

    public PagedList(IQueryable<T> query, QueryOptions? options = null)
    {
        CurrentPage = options!.CurrentPage;
        PageSize = options!.PageSize;

        TotalPages = query.Count() / PageSize;
        AddRange(query.Skip((CurrentPage-1)*PageSize).Take(PageSize));
    }
}
```

For this -- ctor accepts an `IQueryable<T>`represents the query that will provide data to display to the user.

### Updating the Repository

- Worked well - ServiceLayer -- a layer isolated/adapted the lower layers of the application.
- Was repetitious -- Used `ViewModel`classes, *data transfer objects* to represent the data needed to show to the user.
- Had ongoing problems -- 
- table - .NET class
- Table columns -- properties/fields
- Rows - Elements in .NET collections fore, `List`
- Primary key -- unique class instance
- FK -- reference to another class
- SQL -- .NET LINQ.

## Querying the dbs

- one-to-one, fore `PriceOffer`to a `Book`
- one-to-many -- `Book`to `Reviews`
- many-to-many -- `Books`linked to `Authors`

Generating elements in the razor file in the Folder.

## Processing Events without a Handler Method

`<button class="btn btn-info" @onclick="@(() => Counters.Remove(local))">`

## Preventing Default Events and Event Propagation

Blazor provides two attributes that alter the default behavior of events in the browsers.

`@on{event}:preventDefault`-- whether the default event for an element is triggered

`@on{event}:stopPropagation`-- whether an event is propagated to its ancestor elements.

```cs
<form action="/pages/blazor" method="get">
	@for (int i = 0; i < ElementCount; i++)
	{
		int local = i;
		<div class="m-2 p-2 border">
			<button class="btn btn-primary" @onclick="@(() => IncrementCounter(local))"
				@onclick:preventDefault="EnableEventParams">
				Increment Counter #@(i + 1)
			</button>
			<button class="btn btn-info" @onclick="@(() => Counters.Remove(local))">
				Reset
			</button>
			<span class="p-2">Counter Value: @GetCount(@i)</span>
		</div>
	}
</form>

<div class="m-2" @onclick="@(()=>IncrementCounter(1))">
	<button class="btn btn-primary" @onclick="@(()=>IncrementCounter(0))"
			@onclick:stopPropagation="EnableEventParams">
		Propagation test
	</button>
</div>

<div class="form-check m-2">
	<input class="form-check-input" type="checkbox"
		   @onchange="@(()=>EnableEventParams=!EnableEventParams)" />
	<label class="form-check-label">Enable event Parameters</label>
</div>
@code {
	//...
	public bool EnableEventParams { get; set; } = false;
}
```

This creates two situations in which the default behavior of events in the browser can cause problems. First caused by adding a `form`-- note, by default, button contained in a form will **submit** that form when are clicked. Means that when clicked, the browser will send the data to the ASP.NET core server.

Second is demonstrated by the element whose parent also define an event handler. Events go through a well-defined lifecycle in the browser.

## Working with Data Bindings

Event handlers and Razor expressions can be just used to create a two-way relationship between an HTML element and a C# value, which is useful for elements that allow users to make changes. Fore:

So, two-way relationships involving the `change`event can be expressed. Can just:

```html
<div class="mb-3">
    <label>City:</label>
    <input class="form-control" @bind="City" />
</div>
```

The `@bind`attribute is used to specify the property that will be updated when the **change** event is triggered and that will update the `value`attribute when it changes.

## Changing the Binding Event

By default, the `change`is used in bindings, which just provides reasonable reponsiveness for the user. The event used in a binding can be changed by using the attributes -- 

`@bind-value`-- used to select the `property` for data binding.

`@bind-value:event`-- used to select the event for the data binding like:

`<input class="form-control" @bind-value="City" @bind-value:event="oninput" />`

## Creating DateTime Bindings

If have used the `@bind-value`and `@bind-value:event`attribute to select an event, then must use the `@bind-value:culture`and `@bind-value:format`.

## Using Class Files to Define Components

`@code`section is called *code-behind* or *code-behind file*. Can define:

```html
<ul class="list-group">
    @foreach(...)
</ul>
```

```cs
// file name.razor.cs
public partial class Split {
    [Inject]public DataContext? Context{get;set;}
}
```

`<component type="typeof(Advanced.Blazor.Split)" render-mode="Server" />`

## Defining a Razor Component Class

Blazor components can be combined to create more complex features. Show you how multiple components can be used together and how components can communicate.

For this, when a component is added to the content rendered by a controller view -- the `component`element is used, when a component is added to the conent rendered by another component, then the name of the component is used as an element instead.

When combining components, the effect is the one component delegates reponsibility for part of its layout to another.

# Type Predicates

`instanceof`and `typeof`can be used to narrow types. It gets lost if you wrap the logic with function. FORE

```ts
function isNumberOrString(value: unknown) {
    return ['number', 'string'].includes(typeof value);
}

function logValueIfExists(value: number | string | null | undefined) {
    if (isNumberOrString(value))
        value?.toString();
}
```

Type predicate's return types can be decalred as the name of a parameter -- the `is`keyword like:

```ts
function typePredicate(input: WideType): input is NarrowType;
// so can change to:
function isNumberOrString(value: unknown): value is number | string {
    return ['number', 'string'].includes(typeof value);
}
```

FORE:

```ts
interface Comedian{
    funny: boolean;
}

interface StandupComedian extends Comdian{
    routine: string;
}

function isStandupComedian(value: Comedian): value is StartupComedian{
    return 'routine' in value;
}
```

## Type Operators

### keyof

Js objects can have members retrieved using dyanmic values.

```ts
interface Ratings{
    audience: number;
    critics: number;
}

function getRating(ratings: Ratings, key: 'audience' | 'critic'): number {
    return ratings[key];
}
getRating({ audience: 66, critics: 84 }, 'invalid'); // error
```

Ts provides a `keyof`operator that takes in an existing type and gives back a union of all the keys allowed on that type. `keyof Ratings`is just equivalent  to `audience | critic`.

```ts
function getRating(ratings: Ratings, key: keyof Ratings): number {
    return ratings[key];
}
getRating({ audience: 66, critics: 84 }, 'audience'); // ok
```

typeof -- just gives back the type of the provided value.

```ts
const orig = {
    medium: "movie",
    title: "mean girls"
}
let adapation: typeof orig;  // {medium:string, title:string}
```

### keyof typeof

`typeof`just retrieves the type of a value, and `keyof`retrieves the allowed keys on a type.

```ts
const ratings = {
    imdb: 8.4,
    metacritic: 82,
}

function logRating(key: keyof typeof ratings) {
    console.log(ratings[key]);
}

logRating("imdb"); //ok
logRating("invalid"); //error
```

## Type Assertions

Sometimes, it's not 100% accurate. -- FORE, `JSON.parse`intentionally returns the top type `any`. There is no way to safely inform the type system. So, provides a syntax for overridding the type system's understanding of a value's type -- like:

```ts
const rawData = `["grace", "frankie"]`;
JSON.parse(rawData) as string[];
JSON.parse(rawData) as [string, string];
JSON.parse(rawData) as ["grace", "frankie"];
```

Caught error types like:

```ts
try {
    //...
} catch (error) {
    console.warn("no", (error as Error).message);
}
```

## Non-Null Assertions

For a value, it returns a value or an undefined. FORE:

```ts
const seasons = new Map([
    ["I love Lucy", "6"],
    ["The golden girls", "7"],
]);

const maybeValue = seasons.get("I love Lucy")!;
console.log(maybeValue.toUpperCase());
```

## Const Assertions

```ts
[0, ''] as const;  // type : readonly [0, '']

// type: ()=>string
const getName= ()=>"abc";

// type: ()=>"abc"
const getNameConst = ()=>"abc" as const;
```

## Read-only Objects

```ts
function dp(pref: "maybe" | "no" | "yes") {
    switch (pref) {
        case "maybe":
            return "Suppose";
        case "no":
            return "No thanks";
        case "yes":
            return "Yeah";
    }
}

const prefMutble = {
    movie: "maybe",
    standup: "yes",
}
dp(prefMutble.movie); // error
const prefConst = { movie: "maybe", standup: "yes" } as const;
dp(prefConst.movie); //ok
```

## Generics

In TS, constructs such as functions may declare any number of generic *type* parameter.

```ts
function identity<T>(input: T) {
    return input;
}
```

# Starting Development in an Angular Project

Name of the file follows the Angular descriptive naming convension -- `product`and `model`parts of the name tell U that this is the part of the data model that relates to the products.

The final step to complete is to define a repository will provide access to the data.

Creating a Component and Tempalte -- Templates contains the HTML content that a component wants to present to the user.

```html
<div class="bg-info text-white p-2">
	There are {{model.getProducts().length}} products in the model
</div>
```

Most of the template is std HTML, but the part between the {{}} is for data binding. NOTE that the logic and data required to support the template are provided by its component -- is a TS class to which the `@Component`decorator has been applied.

```ts
import {Component} from "@angular/core";
import {Model} from "./repository.model";

@Component({
	selector: "app",
	templateUrl: "template.html"
})
export class ProductComponent {
	model: Model = new Model();
}
```

In the `index.html`, `<app></app>`

Then need to configure the Root Ng Module -- 

```ts
@NgModule({
  declarations: [
    ProductComponent
  ],
  imports: [
    BrowserModule
  ],
  providers: [],
  bootstrap: [ProductComponent]
})
```

## Using Data Bindings

One way -- generate content for the user and basic feature used in Ng. from the component to template just.

`<div class="text-white p-2" [ngClass]="getClasses()">`

`[]`tells that this is a one-way data binding. `ngClass`what the binding will do. The names of the built-in directives starts with `ng`. `ngClass, ngStyle, ngIf, ngFor, ngSwitch, ngSwitchCase, ngSwitchDefault, ngTemplateOutlet`

## Understanding Property Bindings

if doesn't correspond to a directive, Then checks to see whether the target can be used to create a property binding.

`[property], [attr.name], [class.name], [style.name]`

The browser will try to process the classes to which the host element has been assigned.

`(target)="expr"`-- where the data from the target to the dinstination.

`<input class="form-control" [value]="model.getProduct(1)?.name??'None'"/>`

The new binding specifies value property should be bound to the result of an expression that calls a method on the data model to retrieve data object form the repository by specifying a key.

```html
<div [ngClass]="getClasses()+' text-white p-2'"
	[textContent]="'Name: '+ (model.getProduct(1)?.name??'None')">
```

string interpolation binding is denoted using {{}}.

`<td [attr.colspan]="model.getProducts().length">`

`[class.myClass]="expr"`-- evaluates the expression and uses the result to set the element's membership of `myClass`.

```html
<div class="p-2"
     [class.bg-success]="(model.getProduct(2)?.price??0)<50"
     [class.bg-info]="(model.getProduct(2)?.price??0)>=50">
    The second product is {{model.getProduct(2)?.name}}
</div>
```

note that the special if the result of the expression is *truthy*.

`ngClass`supports `String, Array, Object`.

```ts
getClassMap(key: number): Object {
    let product = this.model.getProduct(key);
    return {
        "text-center bg-danger": product?.name == "kayak",
        "bg-info": (product?.price ?? 0) < 50,
    }
}
```

## Adjusting grid tiems to fill the grid track

Stretcing an img is problemiatic. CSS provides a special prop for controlling -- `object-fit`. By default,`<img>`has `fill`meaning image will be resized to fill. accepts the `cover`and `contain`.

```css
.portfolio{
    display:grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    grid-auto-rows: 1fr;
    gap: 1em;
    grid-auto-flow: dense;
}

.portfolio .featured{
    grid-row: span 2;
    grid-column: span 2;
}

.portfolio > figure {
    display:flex;
    flex-direction: column;
    margin:0;  
}
```

## Alignment

`justify`controls horizotal, and `align`controls vertical placement. like:

```css
.grid {
    display: grid;
    height: 1200px;
    grid-template-rows: repeat(4, 200px)
}
```

# Positioning and Stacking contexts

The `position`property, can use to build dropdown menus, modal dialogs...

The initial value of the `position`is `static`. When U change this value to anything else, just means to be *positioned*. static means not positioned.

NOTE: Positioning removes elements from the document flow entirely. So, can place the element somewhere else on the screen.

Applying `position:fixed`just position the element arbitrarily within the viewport. done with TRBL.

## Creating a modal dialog with fixed positioning

will initiallly hide the dialog with `display:none`

```css
.modal-backdrop {
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    background-color: rgba(0, 0, 0, 0.5);
}

.modal-body {
    position: fixed;
    top: 3em;
    bottom: 3em;
    right: 20%;
    left: 20%;
    padding: 2em 3em;
    background-color: white;
    overflow: auto;
    /* allow to scroll */
}

.modal-close {
    cursor: pointer
}
```

Just use the fixed twice. on the `modal-backdrop` When positioning an element, are not required to specify valus for all four. like:

`position: fixed; top:1em; right: 1em; width: 20%`

## Absolute positioning

fixed positioning, called *containing block*. Absolute positioning just same way except has a different containing block. It based on just the *closest positioned ancestor element*.

Do this positioning the `close`button like:

```css
.modal-close {
    position: absolute;
    top: 0.3em;
    right: 0.3em;
    padding: 0.3em;
    cursor: pointer;
    font-size:2em;
    height: 1em;
    width:1em;
    text-indent:10em;
    overflow:hidden; /* make it hidden */
    border:0;
}

.modal-close::after{
    position: absolute;
    line-height: 0.5;
    top: 0.2em;
    left: 0.1em;
    text-indent: 0;
    content: "\00D7";
}
```

## Positioning a psdudo-element

just hide the word `close`and display a x. For `::after`, note that behaves like a child element of the button. The short line-height keeps that from being to