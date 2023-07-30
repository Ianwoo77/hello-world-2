# Defining and Using Interfaces

```go
func main() {
	expenses := []Expense{
		Product{"Kayak", "Watersports", 275},
		Service{"Boat cover", 12, 89.50},
	}

	for _, expense := range expenses {
		fmt.Println("Expense:", expense.getName(), "cost:", expense.getCost(true))
	}
}
```

Note: variables whose type is an interface have two types, *static* and *dynamic* type. static is interface type and the dynamic is the type of value assigned to the variable that implements the interface. the `for`loop deals with the static type and doesn't know -- doesn't need to know the dynamic type of those values.

## Using an interface for struct fields

Interface types can be used for struct fields.

Understanding the Effect of pointer Method Receivers -- For the methods defined by the `Product`and `Service`have value receivers. The `Product`value was copied when it was assigned to the `Expense`variable. A pointer to the struct value can be used when making the assignment to the interface variable like:

```go
func main() {
	product := Product{"Kayak", "Watersports", 275}
	var expense Expense = &product
	product.price=100
	fmt.Println(product.price)
	fmt.Println(expense.getCost(false))
}

//...
func (s *Service) getCost(recur bool) float64 {
	if recur {
		return s.monthlyFee * float64(s.durationMonths)
	}
	return s.monthlyFee
}
```

Can also force the use of references by specifying pointer receivers when implementing the interface methods.

## Comparing Interface Values

For the pinter type like:

```go
var e1 Expense = &Product {...}
var e2 Expense = &Product {...}
e1!=e2 // note
// the pointers are equal only if they just point to the same location.
// but for simple struct and same field values, equal.
```

And note that the interface equality checks can also cause runtime errors if the dynamic type is not comparable.

## Performing Type Assertions

A *type assertion* is just used to access the dynamic type of an interface value like:

```go
func main() {
	expenses := []Expense {
		&Service{"Boat Cover", 12, 89.50, []string{}},
		&Service{"Paddle Protect", 12, 8, []string{}},
	}
	for _, expense := range expenses {
		s := expense.(*Service)
		fmt.Println("Service:", s.description, "Price:", s.monthlyFee*float64(s.durationMonths))
	}
}
```

NOTE: Type assertions can be applied only to interfaces -- used to tell the compiler that an interface value has a specific dynamic type.

```go
for _, expense := range expenses {
    if s, ok := expense.(*Service); ok {
        fmt.Println(s.description, s.monthlyFee)
    } else if p, ok := expense.(*Product); ok {
        fmt.Println(p.name)
    } else {
        fmt.Println("nothing output")
    }
}
```

## Switching on Dynamic Types

Go `switch`can be used to access dynamic types. Just like:

```go
for _, expense := range expenses {
    switch value := expense.(type){
    case *Service:
        fmt.Println("Service: ", value.description)
    case *Product:
        fmt.Println("Product: ", value.name)
    default:
        fmt.Println("Expense", expense.getName())
    }
}
```

## Using the Empty Interface

Just to represent any type.

```go
data := []interface{}{
    expense, 
    Product{...}
}
for _, item := range data {
    switch value := item.(type) {
    case Product:
        //...
    case string, bool, int:
        //...
    default:
    }
}
// using for Function parameters like:
func processItem(item interface{}) {
    switch value := item.(type) {
    case Product:
        //...
    }
}
```

The empty can also be used for variadic parameters like:

```go
func processItem(items ...interface{}) {
    for _ item := range items {
        switch value := item.(type) {
            case...
        }
    }
}
```

## Creating and using Packages

Packages are go feature, grouped together. The `module`statement specifies the name of the module, which was specified by the command like:

```sh
module packages
go 1.20
```

Go just examines the first letter of the name given to the features in a code file. To resolve, can export, or export methods or functions that provide access to the field value. And packages can just contain multiple code files.

### Using a Package Alias

One way to deal with package name conflicts is to use an alias, which allows a package to be accessed using a different name, fore:

```go
import(
    "fmt"
    "package/store"
    currentFmt "package/fmt"
)
```

Using a Dot import -- special alias, allows package's features to be used *without using prefix*.

```go
import(. "package/fmt")
```

## Database-Driven Responses

Create a standalone models package, and use the appropriate functions in Go's database/sql package to execute different types of SQL statements. NOTE: Prevent SQL injection attacks, and use transactions.

```sql
create table snippets
(
    id      bigserial primary key,
    title   varchar(100) not null,
    content text         not null,
    created timestamp,
    expires timestamp
);

create index idx_snippets_created on snippets (created);

insert into snippets(title, content, created, expires)
values ('An old silent pond',
        'An old silent pond...\nA frog jumps into the pond,\nsplash! Silence again.\n\n– Matsuo Bashō',
        now(),
        now() + interval '365' day);

insert into snippets(title, content, created, expires)
values ('Over the wintry forest',
        'Over the wintry\nforest, winds howl in rage\nwith no leaves to blow.\n\n– Natsume Soseki',
        now(),
        now() + interval '365' day);


insert into snippets(title, content, created, expires)
values ('First autumn morning',
        'First autumn morning\nthe mirror I stare into\nshows my father''s face.\n\n– Murakami Kijo',
        now(),
        now() + interval '365' day);


select * from snippets;
```

# Concurrency and Asynchrony

Locking and Thread Safety

```cs
class ThreadSafe{
    static bool _done;
    static readonly object _locker= new object();
    
    static void Main(){
        new Thread(Go).Start();
        Go();
    }
    static void Go(){
        lock(_locker){
            if(!_done){
                Console.WriteLine("Done");
                _done=true;
            }
        }
    }
}
```

Any `try/catch/finally`blocks in effect when a thread is created are of no relevance to the thread.

```cs
try{
    new Thread(Go).Start();
}
catch(Exception ex) {
    //... never execute
}
// do this in respective func.
```

```cs
var signal = new ManualResetEvent(false);
new Thread(() =>
{
	Console.WriteLine("Waiting for signal...");
	signal.WaitOne();
	signal.Dispose();
	Console.WriteLine("Got signal!");
}).Start();

Thread.Sleep(3000);
signal.Set();
```

Unlike with threads, tasks conveniently propagate exceptions.

```cs
Task task = Task.Run(() => throw null);
try
{
	task.Wait();
}
catch (AggregateException aex)
{
	if (aex.InnerException is NullReferenceException)
		Console.WriteLine("null");
	else
		throw;
}
```

Note the CLR just wraps the exception in an `AggregateException`in order to play well with parallel programming.

```cs
Task<int> primeTask= Task.Run(()=>
Enumerable.Range(2, 300000).Count(n=>
Enumerable.Range(2, (int)Math.Sqrt(n)-1).All(i=>n%i>0)));

var awaiter = primeTask.GetAwaiter();
awaiter.OnCompleted(()=>{
	int result= awaiter.GetResult();
	Console.WriteLine(result);
});
```

Calling `GetAwaiter`on the task returns an *awaiter* object whose `OnCompleted()`tells the antecedant task to execute delegate when it finishes.

```cs
primeTask.ContinueWith(ant=>{
	int result = ant.Result;
	Console.WriteLine(result);
});
```

Note that the `ContinueWith`itself returns a `Task`.

## Awaiting

The `await`keyword simplifies the attaching of continuations. like:

```cs
var result= await expression;
statement(s);
//... like:
var awaiter = expression.GetAwaiter();
awaiter.OnCompleted(()=> {
    var result = awaiter.GetResult();
    statement(s);
})
```

## IAsnyncEnumerable<T> in ASP.NET Core

For now can return an `IAsyncEnumerable<T>`like:

```cs
[HttpGet]
public async IAsyncEnumerable<string> Get(){
    using var dbContext= new BookContext();
    await foreach(var title in dbContext.Books
                 .Select(b=>b.Title)
                 .AsAsyncEnumerable())
        yield return title;
}
```

## Async Patterns

```cs
class CancellationToken {
    public bool IsCancellationRequested{get; private set;}
    public bool Cancel() {IsCancellationRequested=true;}
    public void ThrowIfCancellationRequested(){
        if(IsCancellationRequested) {
            throw new OperaitonCanceledExecption();
        }
    }
}
```

`Stream`is the base for all streams. Define methods and properties for 3 fundamental operations -- reading, writing, and seeking. Reading ro Writing async is simply `ReadAsync()/WriteAsync()`.

### FileMode

All of `FileStream`'s ctor accept a file name also require a `FileMode`enum arg.

## StreamReader and StreamWriter

```cs
using(FileStream fs = File.Create("test.txt"))
    using(TextWriter writer = new SteramWriter(fs)){
    writer.WriteLine(...)
}
```

SO common, `File`class provides the static methods like:

```cs
using(TextWriter writer= File.CreateText(...))
    // and File.AppendText(), and File.OpenText()...
```

## HttpClient

The `HttpClient`class exposes a modern API for HTTP client operations, replacing the old `WebClient`and `WebRequest/WebResponse`types. `HttpClient`was written in response to the growth of HTTP-based web APIs and REST services, and provides a good experience when dealing with protocols more elaborate .

# View Components

Which are classes that provide action-style logic to support partial views. Applications commonly need to embed content in views that isn't just related to the main purpose of the application. The data for this type of feature isn't just part of the model data passed from the action method or page model to the view. 

Partial views are a useful feature -- but.. data they operate on is received from the parent view... A view component is a C# class that jsut provides a partial view with the data that it needs, independently from the action or page.

Any class:

1. Name ends with `ViewComponent`and defines `Invoke/InvokeAsync`method
2. or any is derived from the `ViewComponent`base class
3. or has been decorated with the `[ViewComponent]`.

```cs
public class CitySummary:ViewComponent
{
    private CitiesData data;
    public CitySummary(CitiesData cdata)
    {
        data = cdata;
    }

    public string Invoke()
    {
        return $"{data.Cities.Count()}, "
            + $"{data.Cities.Sum(c => c.Population)} people";
    }
}
```

Can be applied in two different ways -- Use the `Component`property. Returns an `IViewComponentHelper`interface.

```cs
@section Summary{
	<div class="bg-info text-white m-2 p-2">
		@await Component.InvokeAsync("CitySummary")
	</div>
}
```

Note, Razor views and Pages can contain tag helpers, which are just custom HTML elements that are managed by C# classes. just:...

## Understanding View Component Results

Fore, just return string... More complex effects can be achieved by having the `Invoke`or `InvokeAsync`method return an object that just implement the `IViewComponentResult`interface.

`ViewViewComponentResult, ContentViewComponentResult, HtmlContentViewComponentResult`

### Returning a Partial View

The most useful response is the named `ViewViewComponentResult`object which tells Razor to render a partial view and include the result in the parent view. The `ViewComponent`base provides the `View`method.

```cs
public IViewComponentResult Invoke()
{
    return View(new CityViewModel
    {
        Cities = data.Cities.Count(),
        Population=data.Cities.Sum(x => x.Population)
    });
}
```

So, need to create a view file -- under the view/shared/component/classname/Default.cshtml.

or: 

```cs
return Content("This is a <h3><i>string</i></h3>")
//...
public IViewComponentResult Invoke(){
    return new HtmlContentViewComponentResult(
    new HtmlString("This is <h3>..."))
}
```

## Using the Built-in Tag helpers

The built-in tag helpers are all defined in the `Microsoft.AspNetCore.Mvc.Taghelpers`namespace and are enabled by adding an `@addTagHelpers`directive to individual views or pages or in the `_ViewImports.cshtml`.

`@addTagHelpers *, Microsoft.AspNetCore.Mvc.TagHelpers`

## Anchor Elements

`asp-action, asp-controller, asp-page, asp-page-handler (specifies the rp handler function)`

`asp-fragment, asp-host, asp-protocol, asp-route, asp-route-*, asp-all-route-data`

```html
<td>
    <a asp-action="Index" asp-controller="Home" asp-route-id="@Model?.ProductId"
       class="btn btn-sm btn-info text-white">Select</a>
</td>
```

```html
<a class="..." href="/home/index/3">Select</a>
```

In this case, the value provirded by the `asp-route-id`attribute means the default URL cannot be used, so the routing system has generated a URL that indicates segments for the controller and action name.

And the `asp-page`attribute is used to specify a Razor Page as the target for an anchor's `href`attribute.

## Generating URLs

The tag helper generates URLs only in anchor elements, if you need to generate a URL, rather than a link, then can use the `Url`property, which is available in controllers, page models, and views. like:

`<div>@Url.Page("/data")</div>`

The same interface is used in controllers or page model classes, such as with:

`string url = Url.Action("List", "Home");`

```html
<script asp-src-include="lib/jquery/**/*.js"></script>
```

### Understanding the Form Handling Pattern

konwn as the `Post/Redirect/Get`pattern, and the redirection is important cuz it means that user can click the browser's reload button without sending another POST request, which can lead to inadvertently repeating an operation.

```cs
public class FormController : Controller
{
    private readonly DataContext context;
    public FormController(DataContext ctx)
    {
        context=ctx;
    }

    public async Task<IActionResult> Index(long id=1)
    {
        return View("Form", await context.Products.FindAsync(id));
    }

    [HttpPost]
    public IActionResult SubmitForm()
    {
        foreach(string key in Request.Form.Keys
            .Where(k => !k.StartsWith("_")))
        {
            TempData[key]=string.Join(", ", Request.Form[key]!);
        } 
        return RedirectToAction(nameof(Results));
    }

    public IActionResult Results()
    {
        return View();
    }
}
```

When the user submits the form, will be received by the `SubmitForm`action, which has been decorated with the `HttpPost`attribute so that it can only receive HTTP POST requests.

# Modules

A callback is a function that you write and then pass to some other function. Client-side Js programs are almost universally event driven. like:

```js
let okay = document.querySelector("#confirmUpdateDialog button.okay");
okay.addEventListener('click', appUpdate);
```

Another common source of async in Js programming is network requests. Js running in the browser can fetch data from a web server with code like this: like:

Client-side js code can use the `XMLHttpRequest`class plus callback functions to make HTTP requests and async handle the server's response when it arrives.

## Promises

Represents the result of an async computation. NOTE that result may or may not be ready yet. U can only ask the Promise to call a callback function when the value is ready. Promises help by standardizing a way to handle errors and providing a way for errors to propagate correctly through a chain of promises.

```js
getJSON(url).then(jsonData=> {})
```

`getJSON()`starts an async HTTP request for the URL you specify and then while that request is pending, it returns a Promise object. Instead pass it to the `then`method. A Promise represents a single computation, and each function registered with `then()`will be invoked only once.

And for Promise, can do this by passing a second function to the `then()`.

```js
getJSON("/api/user/profile").then(displayUserProfile, handleProfileError);
```

Whena sync computation completes normally, simply returns its result to its caller, when a Promise-based async computation completes normally, passes its result to the function that is the first arg to `then()`.

Promise-based computations pass the exception to the second function passed to the `then()`. More idiomatic way to handle errors in the code looks like:

```js
getJSON("/api/user/profile").then(displayUserProfile).catch(handleProfileError);
```

Chaining Promises -- just like:

```js
fetch(documentURL)
.then(response=>response.json()).then(document=>return render(document))
.then(rendered=>cacheInDatabase(rendered))
.catch(error=>handle(error));
```

Remember that the callback you pass to `.catch()`will only be invoked if the callback at a previous stage throws.

### Promises in Parallel

The `Promise.all()`can do this -- takes an *array of Promise objects* as its input and returns a Promise. The returned Promise will be rejected if *any* of the input Promises are rejected.

```js
const urls = [];
promises = urls.map(url=>fetch(url).then(r=>r.text()));
Promise.all(promises)
.then(bodies=>{/*do sth with array of strings */})
.catch(e=>console.error(e));
```

### Promises based on sync values

Sometimes, may need to implement an existing API and returned a Promise from a function.. Even though the .. not async operations. *static methods* `Promise.resolve()`and`Promise.reject()`.

`resolve`takes a value as arg and returns a Promise that will immediately be fulfilled to that value.

```tsx
type RawData= boolean | number | string | null | undefined;
let rawDataFirst: RawData;
let rawDataSecond: RawData;
```

Excess property checks will trigger anywhere a new object is being created in a location that expects it to match an object type.

## Optional Properties

Object type properties don't all have to be required in the object. Can include a ? before the :in the type.

```tsx
type Book = {
    author?: string;
    pages: number;
}

const ok: Book = {
    author: "Rata",
    pages:80,
}

const missing: Book = {
    pages:100
}

type Writers = {
    author: string | undefined;
    editor?: string;
};

const hasRequired: Writers = {
    author: undefined, // ok
}
const missingRequired: Writers= {};
```

# The purpose of floats

A float pulls an element to one side of its container. allowing the document flow to wrap around it.

```css
.clearfix::after {
    display:block;
    content: "";
    clear:both;
}
```

In page, everything inside the main element is floated except for the page title, so only the page title contributes height to the container, leaving all the floated media elements extending below the white background of the main. If you place an element at the end of the main container and use `clear`, it causes the container to expand to the bottom of the floats. The code..

```html
<main class="main">
<!--...-->
    <div style="clear:both">
        null
    </div>
</main>
```

`.clear::after`just insert content to the end of the container.
