# String Processing and Regexp

Describe the stdlib features for processing `string`values, which are needed by almost every project and which many languages provide as method defined on the built-in types. But even though Go defines these features in the stdlib, a complete set of functions is available, along with good support for working with regular expressions.

- String processing includes a wide range of operations, from trimming whitespace to splitting a string into componetns, Regular expressions are patterns that allow string matching rules to be concisely defined.
- These operations are useful when an application needs to process `string`values, a common example is processing HTTP requests.
- These features are contained in the `strings` and `regexp`packages.

## Processing Strings

The `string`package provides a set of functions for processing strings -- in this, describe the most useful features of the `strings`package and demonstrate their use.

### Comparing strings

The `strings`provides comparison functions -- these can be used in addition to the equality operators.

- `Contains(s, substr)` -- returns `true`if the string contains substr
- `ContainsAny(s, substr)`-- `true`if s contains any of characters contained in the string `substr`
- `ContainsRune(s, rune)`
- `EqualFold(s1, s2)`-- performs a case-insensitive comparison and returns `true`of strings
- `HasPrefix(s, prefix)`-- returns `true`if string s begin, and `HasSuffix`, ends with.

### Converting String Case

`ToLower, ToUppser, Title, ToTitle(str)`

```go
func main() {
	desc := "A boat for sailing"
	fmt.Println("Orig:", desc)
	fmt.Println("Title:", strings.Title(desc))  // deprecated
}

```

In some languages, there are characters whose appearance changes when they are used in a title. Unicode defines 3 states for each character -- lowercase, uppercase, and this case and `ToTitle`function returns a string containing only title-case characters.

### Working with Character Case

`IsLower, ToLower, IsUppser, IsTitle, ToTitle`, fore:

```go
product: "Kayak"
for _, char := range product {
    fmt.Println(string(char), "upper case:", uncode.IsUpper(char))
}
```

Inspecting -- `Count(s, sub)`, `Index(s, sub)`, `LastIndex, IndexAny, LastIndexAny, IndexByte, IndexFunc, LastIndexFunc`

```go
fmt.Println(string.LastIndex(desc, "o"))
```

### With custom Functions

The `IndexFunc`and `LastIndexFunc`functions use a custom function to inspect strings, using custom functions like:

```go
func main() {
	desc := "A boat for one person"
	isLetterB := func(r rune) bool {
		return r == 'B' || r == 'b'
	}
	fmt.Println("IndexFunc:", strings.IndexFunc(desc, isLetterB))
}
```

So the custom function receive a `rune`and return a `bool`result that indicates if the character meets the desired condition. The `IndexFunc`invokes the custom function for each character in the string until a `true`result is obtained.

### Manipulating Strings

The `strings`package provide useful functions for editing strings, including support for replacing some or all characters or removing whitespace.

Splitting Strings -- `Fields, FieldsFunc, Split, SplitN(s, sub, max), SplitAfter(s, sub), SplitAfterN(s, sub, max)`

```go
func main() {
	desc := "A boat for one person"
	splits := strings.Split(desc, " ")
	for _, x := range splits {
		fmt.Println("Split >>", x+"<<")
	}
	splitsAfter := strings.SplitAfter(desc, " ")
	for _, x := range splitsAfter {
		fmt.Println("SplitAfter >>" + x + "<<")
	}
}
```

### Restricting the Number of Results

The `SplitN`and `SplitAfterN`functions accept an `int`argument that specifies the maximum number of results that should be included in the result -- 

```go
func main() {
    splits := strings.SplitN(desc, " ", 3) // A, boat, for one person
}
```

To deal with repeated whitespace characters, the `Fields()`function breaks strings on any whitespace character.

```go
func main(){
    desc := "This   is   double   spaced"
    splits := strings.Fields(desc)
}
```

### Splitting using a Custom function to Split Strings

The `FieldFunc`splits a string by passing each character to a custom function and splitting when that func returns `true`. like:

```go
func main(){
    desc := "This is double  spaced"
    splitter := func (r rune) bool {
        return r==' '
    }
    splits := strings.FieledsFunc(desc, splitter)
}
```

### Trimming Spaces

The process of trimming removes leading and trailing characters from a string and is most often used to remove whitespace characters -- just like:

- `TrimSpace(s)`-- returns the string `s`without leading or trailing whitespace characters.
- `Trim(s, set) TrimLeft, TrimRight, TrimPrefix, TrimSuffix, TrimFunc, TrimLeftFunc`

```go
userName := "Alice"
trimmed := strings.TrimSpace(username)
fmt.Println("trimmed", ">>", trimmed + "<<")
```

### Trimming Character Sets

The `Trim, TrimLeft, and TrimRight`functions match any character in a specified string like:

```go
func main() {
	desc := "A boat for one person"
	trimmed := strings.Trim(desc, "Asno")
	fmt.Println("Trimmed", trimmed)
}
```

### Altering Strings

The functions like: 

- `Replace(s, old, new, n)` -- alters the string by replacing occurrences of the string `old`with the `string`new. The maximum number is specified by `n`.
- `ReplaceAll(s, old, new)`-- alters the string s by replacing all occurrences of string `old`with `new`.

```go
func main() {
	desc := "A boat for one person"
	fmt.Println(strings.Replace(desc, "one", "caone", 1))
}
```

### Altering Strings with a Map Func

The `Map`alters strings by invoking a function for every character and combining the results to form a new string.

```go
func main() {
	desc := "It was a boat. A small boat."
	mapper := func(r rune) rune {
		if r == 'b' {
			return 'c'
		}
		return r
	}
	mapped := strings.Map(mapper, desc)
	fmt.Println(mapped)
}
```

### A string Replacer

The `strings`package exports a struct type named `Replacer`that is used to replace strings, providing an alternative to the functions. like:

```go
func main() {
	desc := "It was a boat. A small boat."
	replacer := strings.NewReplacer("boat", "kayak", "small", "huge")
	replaced := replacer.Replace(desc)
	fmt.Println(replaced)
}
```

And note that there is also a `WriteStrings(writer,s)`method -- which is used to perform the replacements specified with the ctor and write the results to an `io.Writer`.

### Building and Generating Strings

The `strings`package provides two functions for generating strings and struct type whose methods can be used to efficiently build strings gradually.

- `Join(slice, rep)`-- combines the elements in the specified string slice, with the specified separator string
- `Repeat(s, count)`..

```go
func main(){
    text := "It was a boat, A small boat."
    elements := strings.Fields(text)
    joined := strings.Join(elements, "--")
    fmt.Prinln("Joined:", joined)
}
```

### Building Strings

- `WriteString(s)`-- append the string s to the string being built
- `WriteRune(r), WriteByte(b)`

```go
func main() {
	desc := "It was a boat. A small boat."
	var builder strings.Builder
	for _, sub := range strings.Fields(desc) {
		if sub == "small" {
			builder.WriteString("very ")
		}
		builder.WriteString(sub)
		builder.WriteRune(' ')
	}
	fmt.Println("String:", builder.String())
}
```

## Regexp

The `regexp`package provides support for regular expressions, which allow complex patterns to be found in strings. Like:

- `Match(pattern, b)`-- returns a `bool`that indicates whether a pattern is matched by the byte slice b.
- `MatchString(pattern, s), Compile(pattern)`
- `MustCompile(pattern)`-- same as `Compile()`but panics.

```go
func main() {
	desc := "A boat for one person"
	match, err := regexp.MatchString("[A-z]oat", desc)
	if err == nil {
		fmt.Println(match)  // true
	} else {
		fmt.Println("Error: ", err)
	}
}
```

### Comiling and reusing Patterns

The `MatchString`is simple and convenient, but the full power of regexp expressions is accessed through the `Compile`function like -- which compiles a regexp pattern so that it can be reused like:

```go
func main() {
	pattern, compileErr := regexp.Compile("[A-z]oat")
	desc := "A boat for one person"
	question := "Is that a goat?"
	preference := "I like oats"

	if compileErr == nil {
		fmt.Println("Desc", pattern.MatchString(desc))
		fmt.Println("Question:", pattern.MatchString(question))
		fmt.Println("Preference", pattern.MatchString(preference))
	} else {
		fmt.Println("Error:", compileErr)  // false
	}
}
```

So, Compiling a pattern also provides access to methods for using regular expression features.

## Manged Heap Basics

Every program uses resources of one sort of another, be they files, memory buffers, screen space, network connecitons, database resources, and so on. In an oo evironment, every type identiifes some resource available for a program's use.

1. Allocate memory for the type that represents the resource (`new`operator)
2. Initialize the memory to set the initial state of the resource and to make the resource usable -- The type's instance ctor is responsible for setting its initial state.
3. Use the resource by accessing the type's member
4. Tear down the state of a resource to clean up.
5. Free the memroy -- garbage collector is solely reponsible for this step.

### Allocating resources from the managed Heap

The CLR requires that all objects to be allocated form the managed heap -- when a process is initialized, the CLR allocates a region of address space for managed heap -- The CLR also maintains a pointer, which call `NextObjPtr`-- 

C#'s `new`causes the CLR to perform the following steps -- 

1. Calculate the number of bytes required for the type's fields
2. Add the bytes required for an object's overhead. Each object just has two overhead fields -- a type object pointer and a sync block index.

### The Garbage Collection Algorithm

For managing the lifetime of objects, some systems uses a reference counting algorithm -- Ms' own `COM`uses referencing counting. But the CLR just uses a referencing tracking algorithm instead. The reference tracking algorithm cares only about reference type variables.

Note - when the CLR starts a GC, the CLR first suspends all threads in the process -- This prevents threads from accessing objects and changing their state while the CLR jsut examines them. Then the CLR performs what is called the *marking* phase of the GC. It walks through all the objects in the heap setting a bit to 0.

### Forcing Garbage collections

The `System.GC`type allows some direct over the garbage collector -- can also force the garbage collector to perform a collection by calling GC class's `Collect()`.

## Creating RESTful Web services

- Using core to create RESTful web services
- Creating web services with the minimal API
- Creating web services with controllers
- Model binding data from web service requests
- Managing the content produced by web services

The nature of web services means that some of the examples in this are tested using command-line tools.

- Web services provide access to an app's data, typically expressed in the JSON.
- Web services are most often to provdie rich client-side applications with data.
- The combination of the URL and HTTP method describes an operation that is handled by an endpoint.

### Understanding RESTful web Services

Data can be consued by clients, such as Js applications. The most common approach is to adopt the REST pattern.

### Understanding Request urls and methods

Is that the web service defines an API through a combination of URLs and HTTP methods such as `GET`and `POST`, which are also known as the HTTP verbs. like:

`/api/products/1`-- This may identify the `Product`object that has a value of 1 for its `ProductId`property. The URL identifies the `Product`, but it is The HTTP method that specifies what should be done with it.

`Patch`-- Used to updae part of existing object.

### Understanding JSON

Most RESTful services format the response data using the JSON format -- has become popular - simple and easily consumed. -- A new alternative is gRPC -- a full remote procedure call framework the focuses on speed and efficiency.

## Creating a web service using the minimal API

As learn about the facilities that ASP.NET core provides for web services -- it can just easy to forget they are built on the features -- to create a simple web service, add the statements just like:

```cs
app.MapGet($"{BASEURL}/{{id}}", async (HttpContext context, DataContext data) =>
{
    string? id = context.Request.RouteValues["id"] as string;
    if (id != null)
    {
        Product? p = data.Products.Find(long.Parse(id));
        if (p == null)
        {
            context.Response.StatusCode = StatusCodes.Status404NotFound;
        }
        else
        {
            context.Response.ContentType = "application/json";
            await context.Response.WriteAsync(JsonSerializer.Serialize(p));
        }
    }
});

app.MapGet(BASEURL, async (HttpContext context, DataContext data) =>
{
    context.Response.ContentType = "application/json";
    await context.Response.WriteAsync(JsonSerializer
        .Serialize<IEnumerable<Product>>(data.Products));
});

app.MapPost(BASEURL, async (HttpContext context, DataContext data) =>
{
    Product? p = await JsonSerializer.DeserializeAsync<Product>(context.Request.Body);
    if (p != null)
    {
        await data.AddAsync(p);
        await data.SaveChangesAsync();
        context.Response.StatusCode = StatusCodes.Status200OK;
    }
});
```

Using the only feautres that you have seen before -- The `MapGet`and `MapPost`methods are just used to create 3 routes, all of which match URLs that start wtih `/api`.

need to note that if post, the JSON's cap sensitve is on.

```json
{
    "Name":"Swimming Goggle",
    "Price":12.75,
    "CategoryId":1,
    "SupplierId":1
}
```

## Creating web service using a Controller

The drawback of using individual endpoints to create a web service that each endpoint has to dupliacate a similar set of steps to produce a response: get the EF core service so that it can query the dbs, set the `Content-Type`header for the response, serialize the objects into JSON, and so on.

A more elegant and robust approach is to use a *controller* -- which allows a web service to be defined in a single class. Controllers are just part of the MVC Framework, The MVC pattern was just an important step in evolution of Core and allowed the platform to break away from the web Forms model that predated it.

### Creating a Controller

*Controllers* are just classes whose methods, known as *actions* can process HTTP requests, Controllers are discovered automatically when the Application is started -- the basic discovery process is just simple, any public class whose name end wtih *Controller* is a controller. like;

```cs
[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    [HttpGet]
    public IEnumerable<Product> GetProducts()
    {
        return new Product[]
        {
            new Product{Name="Product #1"},
            new Product{Name="Product #2"},
        };
    }

    [HttpGet("{id}")]
    public Product GetProduct()
    {
        return new Product { ProductId = 1, Name = "test product" };
    }
}
```

The `ProducesController`class meets the criteria that the MVC freamework looks in a controller -- it just defines public methods named `GetProducts`and `GetProduct`-- which will be treated as actions.

The `ControllerBase`base class provides access to features provided by the MVC Framework and the underlying Core platform. MVC Framework will accept any class whose name ends with `Controller`, that is derived a class whose name just ends with `Controller`. Or just decorated with `[Controller]`.

- `HttpContext`-- returns the `HttpContext`object for the current request
- `ModelState`-- returns details of the data validation process, as demonstrated in the.
- `Request`-- returns the `HttpRequest`
- `Response`-- returns the ..
- `RouteData`-- returns the data extracted from the Request URL by the Routing middleware.
- `User`-- returns an object that describes the user assocaited with the current request.

### Controller Attributes

`[Route("api/[controller]")]`-- `[controller]`just used to derive the URL from the name of the controller class. The `Controller`part of the class name is dropped, so just to `/api/products`as url fragment.

And the attributes applied to actions to specify HTTP methods can also be used to build on the controller's base URL like:

```cs
[HttpGet("{id}")]
public Product GetProduct(){...}
```

When writing a controller, it is just important to ensure that each combination of the HTTP method and URL pattern that the controller supports is mapped only one action method.

### Understanding Action method results

One of the main benefits provided by controllers is that the MVC Framework takes care of setting the response headers and serializing the data objects that are sent to the client. FORE:

```cs
[HttpGet("{id}")]
public Product GetProduct() {...}
```

When used an endpoint, had to work directly with the JSON serializer to create a string that can be written to the response and set the `Content-Type`header to tell the client that the response contained JSON data. The action method just returns a `Product`-- whic his processed automatically.

### Using DI in Controllers

A new instance of the controller class is created each time one of its action is used to handle a request. The app's services are sued to resolve any dependencies the controller declares through its ctor and any dependencies that the action method defines.

```cs
[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    private DataContext context;
    public ProductsController(DataContext ctx)
    {
        context = ctx;
    }

    [HttpGet]
    public IEnumerable<Product> GetProducts()
    {
        return context.Products;
    }

    [HttpGet("{id}")]
    public Product? GetProduct([FromServices]
                               ILogger<ProductsController> logger)
    {
        logger.LogInformation("GetProduct action invoked");
        return context.Products.FirstOrDefault();
    }
}
```

### The EF core context Service LifeCycle

A new EF core context object is created for each controller. Some developers will try to reuse context objects as a perceived performance improvement. And:

`[FromServices] ILogger<ProductsController> logger`-- attempts to find values for action method paramters from the request URL -- by default. And the `FromServices`can often be omitted, and ASP.NET core will try to resovle parameters using dependency injection.

### Using model binding to access the route data

```cs
[HttpGet("{id}")]
public Product? GetProduct(long id, [FromServices]
                           ILogger<ProductsController> logger)
{
    logger.LogInformation("GetProduct action invoked");
    return context.Products.Find(id);
}
```

The listing adds a `long`paramter named `id`to the `GetProduct`method, when the action method is invoked, the MVC framework injects the value with the same name from the routing data, automatically converting it to a `long`vlaue.

### Model binding from the request body

The Model binding feature can also be used on the data in the request body, which allows clients to send dat that is easily received by an action method. like:

```cs
[HttpPost]
public void SaveProduct([FromBody] Product product)
{
    context.Products.Add(product);
    context.SaveChanges();
}
```

The new relies on -- the `HttpPost`is applied to the action method and just tells the MVC framework that the action can process the POST requests. and the `FromBody`attribute is applied to the action's parametr, and it specifies that the value for this paramter should be obtained by parsing the request body.

## Creating the Project

To create -- 

```cs
public class Products
{
    public long Id {get;set;}
    public required string Name { get; set; }
    public required string Category { get; set; }
    public decimal PurchasePrice { get; set; }
    public decimal RetailPrice { get; set; }
}
```

Add repository:

```cs
public class HomeController : Controller
{
    private IRepository repository;
    public HomeController(IRepository repository)=>this.repository = repository;

    public IActionResult Index() => View(repository.Products);

    [HttpPost]
    public IActionResult AddProduct(Product product)
    {
        repository.AddProduct(product);
        return RedirectToAction(nameof(Index));
    }
}
```

```html
@model IEnumerable<Product>

<h3 class="p-2 bg-primary text-white text-center">Products</h3>

<div class="container-fluid mt-3">
    <div class="row">
        <div class="col fw-bold">Name</div>
        <div class="col fw-bold">Category</div>
        <div class="col fw-bold text-end">Purchase Price</div>
        <div class="col fw-bold text-end">Name</div>
    </div>

    <form asp-action="AddProduct" method="post">
        <div class="row">
            <div class="col">
                <input name="Name" class="form-control"/>
            </div>
            <div class="col">
                <input name="Category" class="form-control"/>
            </div>
            <div class="col">
                <input name="PurchasePrice" class="form-control"/>
            </div>
            <div class="col">
                <input name="RetailPrice" class="form-control"/>
            </div>

            <div class="col">
                <button type="submit" class="btn btn-primary">Add</button>
            </div>
        </div>
    </form>

    @if (Model?.Count() == 0)
    {
        <div class="row">
            <div class="col text-center p-2">No data</div>
        </div>
    }
    else
    {
        @foreach (Product p in Model!)
        {
            <div class="col">@p.Name</div>
            <div class="col">@p.Category</div>
            <div class="col text-end">@p.PurchasePrice</div>
            <div class="col text-end">@p.RetailPrice</div>
        }
    }
</div>
```

```cs
public class DataRepository:IRepository
{
    private DataContext context;
    public DataRepository(DataContext ctx)=> this.context = ctx;

    public IEnumerable<Product> Products => context.Products;

    public void AddProduct(Product product)
    {
        context.Products.Add(product);
        context.SaveChanges();
    }
}
```

### Preparing the Database

Go through the process of configuring the `SportStores`app to desire the dbs -- 

```cs
builder.Services.AddScoped<IRepository, DataRepository>();
builder.Services.AddDbContext<DataContext>(opts =>
opts.UseSqlServer(builder.Configuration["ConnectionStrings:DefaultConnection"]));
```

### Avoiding the query Pitfalls

The application is working, and data is being stored in the dbs, but there is still work to be done to get the best from EF core -- There are two common ptifalls to be avoided. FORE: Can see threre will be two logging messages that shows. Cuz the `@if (Model.Count() == 0 ) {//...}`

To just determine how many Product objects have been stored in the dbs, EF core use a SQL `SELECT`statement to get all of the `Product`data that is avaible, uses that data to create a series of `Product`. Can just change to:

`@model IQueryable<Product>`

### Understanding the Duplicate Query Pitfall

By default, EF core doesn't execute the query until the `IQueryable<T>`object is enumerated.  Can use css like:

```html
<style>
    .placeholder {visibility: collapse; display: none;}
    .placeholder:only-child {visibility: visible;display: flex;}
</style>
```

When the HTML elmeent is the only child of its containing element, the property will be changed.

```html
<div>
    <div class="row placeholder">
        <div class="col text-center p-2">No data</div>
    </div>
```

Can also force query execution in the repository -- The problem with working directly with `IQueryable<T>`objects is the details of how data has been implemend have leaked into other parts of the application, which undermines the sense of functional sepraation that the MVC pattern follows.

Just in the Repository class:

`public IEnumerable<Product> Products => context.Products.ToList();`

The LINQ `ToArray`.. trigger the execution of the query and produce an array or a list.

## Events

Client-side js programs use an async event-driven programming model -- in this style of programming, the web browser generates an *event* whenever sth interesting happens to the document or browser or to some element or object associtated with it. If a Js app cares about a particular type of event, can register one or more functions to be invoked when events of the type occur. Note that this is not unique to web programming: all applications with graphical user interfaces are designed this way.

In client-side js, events can occur on any element within an HTML document, and this fact makes the event model of web browsers significantly more complex then Node's event model.

```js
async function getProdcuts(){
    const resp = await fetch("http://localhost:5193/api/products");
    const products = await resp.json();
    console.log(products);
}
```

### Supplying request options

The `fetch`method can optionally accept a second parameter, an `init`object that allows to control a number of different settings -- like:

```js
async function postData(url, data = {}) {
    const resp = await fetch(url, {
        method: "POST",
        mode: "cors", // no-cors, *cors, same-origin
        cache: "no-cache",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
    });
    return resp.json();
}

```

### Same-Origin policy

The same-origin policy is a critical mechanism that restricts how a document or script loaded by one origin can interact wtih a resouce from another origin.

Two URLs ahve the same origin if the `protocol, port, host`are the same for both.

Event -type -- This string specifies what kind of event occurred, The type `mousemove`, fore, means that the user moved th emouse, the type `keydown`.. Event-target -- This is the object on which the event occured or which event is associated. Event handler -- This func handles or responds to an event.

Event Object -- This is assocaited with a particular event and contains details about that event. Event objects are passed as an argument to the event handler function. All event objects have a `type`property that specifies the event type and a `target` property that specifies the event target. And, each event type defines a set of properties for its associated event object -- the object associated with a mouse event just includes the coordinates of the mouse pointer. FORE, and the object associated with a keyboard event contains details about the key was pressed and the modifier keys that were held down.

Event Propagation -- Process by which the browser decides which objects to trigger event handlers on. For events that are specific to a single object -- such as the `load`-- no propagation is required. But when certain kinds of events occur on elements within the HTML document, they propagate or "bubble" up the document tree.

### Categories

Client-side Js supports such a large number of event types that there is no way this -- cover them all -- it can be useful, to group events into some general categories -- to illustrate the scope and wide variety of supported events -- FORE:

```js
window.onload = function() {
    let form = document.querySelector("...");
    form.onsubmit= function(event) {
        if(!isFormValid(this)) {
            event.preventDefault();  // if not valid, prevent submits.
        }
    }
}
```

Any object that can be an event target -- this just includes the `Window`and `Document`objects and all document Elemetns. Defines a method named `addEventListener()`that you can use to register an event handler. like:

```js
<script>
    let b = document.querySelector("#mybutton");
    b.onclick = function () { console.log("Thanks for clicking me!"); };
    b.addEventListener("click", () => console.log("Thanks again"));
</script>
<button id="mybutton">Click me</button>
```

`addEventListener()`is just paired with a `removeEventListener()`method that expects the same two arguments, but removes an event handler function from an object rather than adding it.

## Unions of Object types

It is resonable in Ts code to want to be able to describe a type that can be one or more different object types that have slightly different properties -- 

```sh
git pull origin master --rebase
```

### Inferred Object-type unions

And, if a varaible is given an initial value that could be one of multiple object types, Ts will infer its type to be a union of object types.
