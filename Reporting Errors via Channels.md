# Reporting Errors via Channels

If a func is being executed using a goroutine, then the only communication is through the channel, which means that details of any problem must be communicated alongside successful operations. It is important to keep the error handling as simple as possible. Avoiding trying to use additional channels.

```go
func (slice ProductSlice) TotalPriceAsync(categories []string, channel chan<- ChannelMessage) {
	for _, c := range categories {
		total, err := slice.TotalPrice(c)
		channel <- ChannelMessage{
			c, total, err,
		}
	}
	close(channel)
}
```

## Using the Error Convenience Functions

The `errors`is part of the stdlib -- provides a `New`that returns an `error`whose content is a `string`. And  one fo the funcs provided by `fmt`is `Errorf`which creates `error`values using a formatted string like:

`err = fmt.Errorf("cannot find catetory: %v", category)`

## Dealing with Unrecoverable Errors

Some errors are so serious they should lead to the immediate termination of the application, a process known as *panicing* like: `panic(message.CategoryError)`

The `panic`is invoked with an arg, which can be any value that will help explain the panic. Enclosing function is halted, and any `defer`funcs are performed.

## Recovering from Panics

Go just provides the built-in `recover`-- to stop a panic from its way up the call stack and terminating the program.

```go
recoveryFunc := func() {
    if arg := recover(); arg != nil {
        if err, ok := arg.(error); ok {
            fmt.Println("Error:", err.Error())
        } else if str, ok := arg.(string); ok {
            fmt.Println("Message:", str)
        } else {
            fmt.Println("Panic receovered")
        }
    }
}
defer recoveryFunc()
```

`defer`will be executed when the `main`func has completed. Since any value can be passed to the `panic`-- so the type of the value returned by the `receover`is the `interface{}`.

And can be awkward. so:

```go
defer func(){...}()
```

Panicking after a Recovery -- may recover from a panic only to realize that the situation is not recoverable. Recovering from Panics in Go goroutines like:

```go
type CategoryCountMessage struct {
	Category string
	Count    int
	TerminalError interface{}
}

func processCategories(categories []string, outChan chan<- CategoryCountMessage) {
	defer func() {
		if arg := recover(); arg != nil {
			fmt.Println(arg)
			outChan <- CategoryCountMessage{TerminalError: arg}
		}
		close(outChan)
	}()

	channel := make(chan ChannelMessage, 10)
	go Products.TotalPriceAsync(categories, channel)
	for message := range channel {
		if message.CategoryError == nil {
			outChan <- CategoryCountMessage{
				Category: message.Category, Count: int(message.Total),
			}
		} else {
			panic(message.CategoryError)
		}
	}
	close(outChan)
}
```

# Go STDLIB

## String Processing and Regular expressions

These features are contained in the `strings`and `regexp`packages.

`Contains, ContainsAny, ContainsRune, EqualFold(i), Hasprefix, HasSuffix`

Converting String Case -- 

`ToLower, ToUpper, Title, ToTitle`

```go
func main() {
	desc := "A boat for sailing"
	fmt.Println(desc)
	caser := cases.Title(language.AmericanEnglish)
	fmt.Println(caser.String(desc))
}
```

The `unicode`package can be used to determine or change the case of individual characters. just for <font color='orange'>rune</font>.

`IsLower, ToLower, IsUpper, ToUpper, IsTitle, ToTitle`

```go
for _, char := range caser.String(desc) {
    fmt.Println(unicode.IsUpper(char))
}
```

## Inspecting Strings with Custom Functions

`IndexFunc`and `LastIndexFunc`functions use a custom function to inspect strings.

```go
func main() {
	desc := "A boat fBor one Person"
	isLetterB := func(r rune) bool {
		return r == 'B' || r == 'b'
	}

	fmt.Println(strings.LastIndexFunc(desc, isLetterB))  // 8
}
```

1. `Fields(s)`-- splits a string on whitespace
2. `FieldsFunc(s, func)` And

`Split, SplitN, SplitAfter, SplitAfterN`

## Alter Strings

The function -- 

`Replace, ReplaceAll, Map(func, s)`

## A string Replacer

The `strings`exports a struct type `Replacer` like:

```go
func main() {
	text := "It was a boat, A small boat."
	replacer := strings.NewReplacer("boat", "kayak", "small", "huge")
	replaced := replacer.Replace(text)
	fmt.Println(replaced)
}
```

## Using Regular Expressions

The `regex`package provides support - -like:

`Match, MatchString, Compile, MustCompile`

```go
func main() {
	desc := "A boat for one person"
	match, err := regexp.MatchString("[A-z]oat", desc)
	if err == nil {
		fmt.Println("Match", match)	//true
	} else {
		fmt.Println(err)
	}
}
```

Compiling and reusing patterns -- Full power of expressions is accessed through the `Compile`function.

## Catching Runtime Errors

Add a deliberate error to the `show.page.html`

`{{len nil}}`cuz should generate an error at runtime cuz in Go the value `nil`does not have a length. To fix this need to make the template render a two-stage process. Make a `trial`by writing the template into a buffer.

```go
// initialize a new buffer
buf := new(bytes.Buffer)

// write the template to the buffer, instead of straight to the
// http.ResponseWriter
err := ts.Execute(buf, td)
if err != nil {
    app.serverError(w, err)
    return
}
buf.WriteTo(w)
```

## Common Dynamic Data

In some web applications there may be common dynamic data that you want to include on more than one.

## Custom Template Functions

How to create your own custom functions to use in Go Templates.

1. Need to create a `template.FuncMap`containing the custom `humanDate()`
2. Need to use the `template.Funcs()`to register this before parsing the templates.

And need to note custom template functions can accept as many as parameters as need to, but must return one value only. Can use in template:

## Pipelining

In the code, called custom template function just like:

```html
<time>created {{humanDate .created}}</time>
<time>created {{.Created | humanDate}}</time>
<time>
	{{.Created | humanDate | printf "created: %s"}}
</time>
```

## Middleware

When are building web app -- some shared functionality want to use for many ... A common way of organizing this shraed is to set up as a middleware. Essential some self-contained code which independently acts on a request before or after your normal app handlers.

*can think of a go web app as a chain of ServeHTTP() methods being called one after another*.

The `http.StripPrefix()`removes a specific prefix from the request's URL path before passing the request .

## Pattern

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

It establishes a function `fn`which closes over the `next`handler to form a closure. When `fn`is run it executes our middleware logic and then transfers control to the `next`.

## Simplifying the pattern

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(...)){
        next.ServeHTTP(w, r)
    })
}
```

It's just important to explain that where you position the middleware in the chain of handlers. Fore, log request.. if after the ServeMux, fore: myMiddleware -> servemux -> app OR serveMux -> myMiddleware->app, fore, the authorization middleware, may only want to run on speicifc routes.

Add two headers to every response -- 

`x-frame-options: deny`and `X-XSS-Protection: 1; mode=block`

Essentially instruct the user's web browser to implement some additional security measures to help prevent XSS and ClickJacking attacks.

```go
func secureHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-XSS-Protection", "1; mode=block")
		w.Header().Set("X-Frame-Options", "deny")

		next.ServeHTTP(w, r)
	})
}
```

Cuz want this to act on every request that is received, need it to be executed *before* a request hits. like:

`return secureHeader(mux)`

## Additional Info

When the last handler in the chain returns, control is passed back up the chain in the reverse direction. Namely:

secureHandlers -> serveMux -> App-> serveMux -> secureHandler so:

```go
// any code here will execute on the way down the chain
next.ServeHTTP(w, r)
// any code will execute on the way back up the chain
```

## Early Returns

Another is that if call `return`in function *before* call `next.ServeHTTP()` like:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.Handler(func(...){
        if !isAuthorized(r){
            w.WriteHeader(http.StatusForbidden)
            return
        }
        // call the next
        next.ServeHTTP(w, r)
    })
}
```

## Request Logging

```go
func (app *application) logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr, r.Proto, r.Method, r.URL.RequestURI())
		next.ServeHTTP(w, r)
	})
}
```

Implementing the middleware as a method on application.

`return app.logRequest(secureHeaders(mux))`

# Using Filters

Filters inject extra logic into request processing. Like middleware that is applied to a single endpoint, which can be an action or a page handler -- provide an elegant way to mangae a specific set of requests.

Authorization, resource, action, page, result, exception. And filter factory, and global filter...

### Enabling HTTPs Connections

Some of the examples require the use of the SSL.

Filters allow logic that would otherwise be applied in a middleware component or action method. FORE: Selectively enforcing HTTPs in the HomeController like:

```cs
public IActionResult Index()
{
    if (Request.IsHttps)
    {
        return View("Message",
            "This is the index action on the Home Controller");
    }else
        return new StatusCodeResult(StatusCodes.Status403Forbidden);
}
```

This approach has problems -- action method contains code more about security doesn't scale well and must be duplicated in every action method. FORE:

```cs
public IActionResult Secure(){
    if (Request.IsHttps)...
}
```

This is the type of problem that filters address Can:

```cs
[RequireHttps]
public IActionResult Index()
```

The `[RequireHttps]`attribute applies one of the built-in filters just provided by core.

Also can: 

```cs
[RequireHttps]
public class HomeController: Controller {...}
```

So, Filters can be applied with different levels of granularity. And in Razor pages like:

```cs
[RequireHttps]
public class MessageModel: PageModel{...}
```

Note, filters can short-circuit the filter pipeline to prevent a request from being forwarded to the next filter. FORE, an authorization filter can short-circuit the pipeline.

Each type implemented using interfaces.

`IAuthorizaionFilter, IResourceFilter, IActionFilter, IPageFilter, IResultFilter, IExceptionFilter`and their `IAsync...`editions.

### Creating a custom Filters 

Filters implement the `IFilterMetadata`-- empty and don't require a filter to implement any speicifc behaviors. And filters are provided with context data in the form of a `FilterContext`object, its properties are:

`ActionDescriptor, HttpContext, ModelState, RouteData, Filters`

## Understanding Authorization Filters

Are used to implement an app's security policy. Are executed before other types of filter and before the endpoint handles the request.

```cs
public interface IAuthorizationFilter : IFilterMetadata {
    void OnAuthorization(AuthorizationFilterContext context);
}
```

The On... method is called so that the filter can authorize the request. `Result`-- This IActionResult prop is set by authorization filters when the request doesn't comply with policy. core will execute the `IActionResult`.

```cs
public class HttpsOnlyAttribute : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        if(!context.HttpContext.Request.IsHttps)
        {
            context.Result = new StatusCodeResult(StatusCodes.Status403Forbidden);
        }
    }
}
```

If there is a problem, the `Result`prop of `FilterContext`object passed to the method. This prevents further execution from hanppening and provides a result to return to the client.

This filter re-creates the functionality that included.

## Understanding Resource Filters...Creating the Repository and DB

To provide consistent access to the new data to the rest of the application, added a file:

For a new order, this means that the `ViewBag.Lines`will be populated with a seq of `OrderLine`objects.

## Storing Order Data

No data is just stored when you click save button.

## Scaling Up

As the app progresses, can be useful to increase the amount of data you are working with so that you can see the impact it has on the operations. Testing data.

Creating Seed data Controller and View just do a prodedure. And to provide the controller with a view:

# Using Blazor Server

There are two varieties of Blazor -- show you how to configure an core app to use Blazor Server and describe the basic feature when using Razor components.

* Blazor server uses Js to receive browser events -- forwarded to Core and evaluated using C# code.
* The building block for BS is Razor component, and similar to RPs.
* Relies on a persistent HTTP connection to the server and cannot function when the connection interrupted.

Use the `AddServerSideBlazor`and `MapBlazorHub`methods to set up the required services and middleware and configure the Js files.

## Understanding Blazor Server

for MVC or RPs -- The action or handler renders its view -- sends a new HTML document that reflect the selection to the browser. Each time submit -- the browser sends a new HTTP request to core. Each request contains a complete set of HTTP headers... In response, the server includes HTTP headers that decribe the response and includes a complete HTML document.

For Blazor, A JS library is included, and when Js code is executed, opens an HTTP connection back to the server and leaves it open -- ready for user interaction. responds with just the change to apply to an existing HTML. The persistent HTTP connection minimizes the delay, and replying with just the differences reduces the amount of data sent between the browser and the server.

In the `program.cs`file:

`builder.Services.AddServerSideBlazor();`

`app.MapBlazorHub()`

Hub in -- relates to `SingalR`, which is the part of core.

## Adding the Blazor Js file to the Layout

Blazor relies on Js code to communicate with the Core server.

```html
<base href="~/" />
<script src="_framework/blazor.server.js"></script>
```

## Blazor Imports File

Requires its own import files to specify the namespaces that it uses. In the Advanced folder like: `_Imports.razor`

```cs
@using Microsoft.AspNetCore.Components
@using Microsoft.AspNetCore.Components.Forms
@using Microsoft.AspNetCore.Components.Routing
@using Microsoft.AspNetCore.Components.Web

@using Microsoft.JSInterop
@using Microsoft.EntityFrameworkCore
@using Advanced.Models
```

For the most significant difference is the use of special attribute `select`for:

`@bind="SelectedCity"` -- This creates a data binding between the value of the `select`element and the `SelectedCity`prop. Using this for:

```html
<component type="typeof(Advanced.Blazor.PeopleList)" render-mode="Server" />
```

Blazor components are just applied using the `component`element, for which there is a tag helper. is configured using the `type`and `render-mode`.

Razor Components can also be used in RPs.

## Understanding the Basic Razor Component Features

Events allow a Razor component to respond to user interaction.

For the `onclick`, the handler method receives a `MouseEventArgs`object, providing additional details.

## Handling Events from Multiple Elements

Cold use the `@for`expression to generate elements and use the loop variable as the argument to the handler method. FORE:

`@onclick="IncrementCounter()"`, warning is void cannot be converted to an `EventCallback`. And within the Razor expression, the Labmda is defined it would be a C# class, like:

`@onclick= @((e)=>HandleEvent(e, local))`

`@onclick=@(()=>IncrementCounter(local))`// if don't need to use `EventArgs`object.

# Classes

Tsc generally understands methods the same way it understands standalone functions. Fore, return types can generally be inferred if the function is not recursive.

And class ctors are treated like typical class methods with regards to their parameters.

## Properties

To read from or write to a property on a class in TSC, it must be explicitly declared in the class.

```tsx
class FieldTrip{
    destination: string;
    constructor(destination: string){
        this.destination= destination;
        this.nonexistent= destination; // error
    }
}
```

## Func props

```tsx
class withMethod{
    mymethod(){}
}
new WithMethod().mymethod===new WithMethod().mymethod; //true, note
```

## Initialization checking

```tsx
class WithValue {
    immediate= 0;
    later:number;
    maybeUndefined: number | undefined; // ok
    constructor(){
        this.later=1; //ok
    }
    unused: number ; // error
}
```

## Definitely assigned props

If are absolutely sure a prop should NOT have strict initialization checking, just:

```tsx
class ActivitiesQueue{
    pending!: string[]; //ok
    initialize(pending: string[]) {
        this.pending=pending;
    }
}
```

## Optional Props 

just like `| undefined`

```ts
class MissingInitializer{
    property?:string;
}
```

## Read-only props

Note declared as `readonly`with an initial value, not annotation, will not be overwritten.

## Class as Types

```ts
class Teacher{
    sayHello() {
        console.log("hello");
    }
}

let teacher: Teacher;
teacher = new Teacher();
```

## Class and Interfaces

TSC allows a class to declare its instances as adhering to an interface by adding `implements`keyword.

```ts
interface Learner {
    name: string;
    study(hours: number): void;
}

class Student implements Learner {
    name: string;
    study(hours: number): void {
        for (let i = 0; i < hours; i += 1) {
            console.log("...study...");
        }
    }
}
```

## Implementing Multiple Interfaces

```ts
interface Graded{
    grades: number[];
}

interface Reporter{
    report: () => string;
}

class ReportCard implements Graded, Reporter{
    grades: number[];
    constructor(grades: number[]) {
        this.grades = grades;
    }
    report() {
        return this.grades.join(", ");
    }
}

new ReportCard([1, 2, 3]).report();
```

Attempting to declare a class implementing two conflicting interfaces will result in at least one type error.

## Extending a Class

`class StudentTeacher extends Teacher{}`

## Overridden ctors

Subclasses are not required by TS to define their own ctor. And in JS, if a subclass does declare its own ctor,  Then must call its base class via `super`. As per Js rules, the ctor of a subclass must call the base ctor before accessing <font color='orange'>`this`or `super`</font>. Ts will report a type error if it sees a `this`or `super`being accessed before `super()`.

## Overridden Methods

Subclasses may redeclare new methods with the same names as the base class. The types of the new methods must be usable in place of the original methods.

## Overridden Properties

As long as the new type is assignable to the type on the base class. As with methods, subclasses must structurally match up with base.

## Abstract

Ts' `abstract`keyword in front of the class name and in front of any method intended to be abstract.

## Member Visibility

For JS, includes the ability to start the name of a class member with `#`to mark it as a `private`.

`public (default)`, protected, and private.

And visibility modifiers may be marked along with `readonly`.

## unknown

The `unknown`in ts is its true top type. The key difference with `unknown`is that TSX is much more restrictive about values of the `unknown`.

* TS doesn't allow directly accessing prop of `unknown`
* `unknown`is not assignable to types that is not top type.

In TS, the only way will allow code to access members on a name of type `unknown`is if the value's type is narrowed.

```ts
function greetComedianSafety(name: unknown){
    if (typeof value ==="string")...
}
```

Those two restrcitions make `unknown`a much safer type to use than `any`.

# Adding Category Selection

Filtering the products by category -- more typical is to break the list into smaller sections and present each of them as a page. Just add some properties.

```ts
get pageNumbers(): number[] {
    return Array(Math.ceil(this.repository
        .getProducts(this.selectedCategory).length / this.productsPerPage))
        .fill(0).map((x, i) => i + 1);
}
changePageSize(newSize: number) { // cuz this parameter is the user's selection, any type
    this.productsPerPage = Number(newSize);
    this.changePage(1);
}
```

### Creating a Custom Directive

```ts
@Directive({
	selector:"[counterOf]"
})export class CounterDirective {
	constructor(private container: ViewContainerRef,
				private template: TemplateRef<Object>) {
	}

	@Input("counterOf")
	counter:number=0;

	ngOnChanges(changes: SimpleChange) {
		this.container.clear();
		for(let i =0; i<this.counter; i++ ){
			this.container.createEmbeddedView(this.template,
				new CounterDirectiveContext(i+1));
		}
	}
}
```

This is an example of a structural directive. Applied to elements through a `counter`prop.

## Understanding Ng projects and Tools

* --skip-install -- prevents the initial operation that downloads and installs the packages.
* --skip-git -- prevents a Git repository
* --skip-tests -- prevents addition of the initial configuration for testing tools.
* --style -- SCSS, SASS...

src -- contains the app's source code, resources, and configuration files. 

.browserslistrc -- specify the browsers that the app will support.

.editorconfig, .gitignore, folders are excluded

angular.json -- this contains the configuration for the Ng development tools.

karma.conf.js -- for unit testing

package.json -- contains details of the NPM package required by the app.

package-lock.json -- contains version info for all the packages installed

tsconfig.json - contains the configuration settings for TSC compiler

tsconfig.app.json -- additional configuration options for tsc compiler related to the locations of the source ifles.

tsconfig.spec.json -- additional configuration for ts compiler,,, for unit testing.

main.ts -- this contains the ts statement that start the app when they are executed.

polyfills.ts -- support for features that are not available in some browsers.

tests.ts -- for Krama test package

~13.0.0 --> may be 13.0.1, or 13.0.2

^13.0.0 -- may be 13.1.0, or 13.2.0...

npm install --save-dev -- add the package to the `devDependencies`section.

The `npx`command is useful for downloading and executing a package in a single command.

`ng add @angular/material`

TypeScript compiler, Angular Compiler, and Webpack.

The `styles.js`bundle is used to add CSS stylesheets to the app. CSS are added to the app using the `styles`section of the `angular.json`file.

bootstrap: [AppComponent], which tells Ng that it should load a component called `AppComponent`as part of the app startup process.

`npx http-server dist/example --port 5000`

# Alternate Syntaxes

There are two other alternate syntaxes for laying out grid -- named grid lines and named grid areas.

## Naming grid lines

`grid-template-columns: [start] 2fr [center] 1fr [end]`

Can then reference these

`grid-column: start / center`

Can also provide multiple names for the same grid lines like:

```css
.? {
    grid-template-columns: [left-start] 2fr
        [left-end right-start] 1fr
        [right-end]
}
```

Named both `left-end`and `right-start`

fore, left-start, left-end, can `grid-column: left`. span from left-start to left-end.

```css
.container {
    display: grid;
    grid-template-columns:  [left-start] 2fr 
                            [left-end right-start] 1fr 
                            [right-end];
    grid-template-rows: repeat(4, [row] auto);
    grid-gap: 1.5em;
    max-width: 1080px;
    margin: 0 auto;
}

header,
nav {
    grid-column: left-start / right-end;
    grid-row: span 1;
    /* spans exactly one horizontal */
}

.main {
    grid-column: left;

    /* begin at row 3 and span 2 grid tracks */
    grid-row: row 3 / span 2;
}
```

for: `repeat(3, [col] 1fr 1fr)`

## Naming grid areas

```css
.container {
    display: grid;
    grid-template-areas: "title title"
    "nav nav" "main aside1" "main aside2";
    grid-template-columns: 2fr 1fr;
    grid-template-rows: repeat(4, auto);
    grid-gap: 1.5em;
    max-width: 1080px;
    margin: 0 auto;
}
header {
    grid-area: title;
}

nav {
    grid-area: nav;
}

.main{
    grid-area: main;
}

.sidebar-top {
    grid-area: aside1;
}

.sidebar-bottom {
    grid-area: aside2;
}
```

So the `grid-template-areas`lets draw a visual represenation of the grid directly into your CSS. Need to note can also leave a cell empty using `.`.

`grid-template-areas: "top top right"
                                      "left .      right"  // an empty grid cell.

## Explicit and implicit grid

When using the `grid-template-*`props to define -- creating an **explicit grid**. grid items can still be placed outside of these explicit tracks -- implicit will be automatically generated.

The `grid-auto-columns`and `grid-auto-rows`can be applied, and specify a differernt size for all implicit tracks:

`grid-auto-columns: 1fr`.

Fore, want to constrain it within certain min and max values. Specifies two a min and a max. The browser will ensure the grid track falls between these values. 

`minmax(200px, 1fr)`just at least 200px wide

`auto-fill`Can be sued in `repeat()`. will place as many tracks onto the grid as it can do.

```css
.portfolio{
    display:grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    grid-auto-rows: 1fr;
    gap: 1em;
}
```

repeat(auto-fill, minmax(200px, 1fr)) -- just means your grid will place as many grid columns as the available space can hold. >200px, and < 1fr.

`grid-auto-flow: dense`-- enables the dense grid placement algorithm

```css
.portfolio .featured {
    grid-row: span 2;
    grid-column : span 2;
}
```

