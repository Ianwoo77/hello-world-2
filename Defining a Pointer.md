## Defining a Pointer

```go
func main() {
	first := 100
	second := &first
	first++
	*second++

	fmt.Println("First:", first)
	fmt.Println("Second:", *second)
}
```

Pointers that are defined but not assigned a value have the zero-value `nil`. A runtime error will occur if follow a pointer that has not been assigned a value. Pointers are useful cuz they allow the programmer to choose between passing a value and passing a reference.

```go
func main() {
	names := [3]string{"Alice", "Charlie", "Bob"}
	secondName := &names[1]
	fmt.Println(*secondName)
	sort.Strings(names[:])
	fmt.Println(*secondName)
}

```

When the `secondName`variable is created.. 

The syntax for explicit conversions is `T(x)`.

## Parsing Integers

The `ParseInt`and `ParseUint`functions require the base of the number represented by the string and the szie of the data type will be used to represent the parsed value.

## Formatting Values as Strings

`FormatFloat(val, format, precision, size)`

And Integer convenience Function -- like

```go
base10String := strconv.Itoa(val)
// Formatting Floating-point values
Fstring := strconv.FormatFloat(val, 'f', 2, 64)
Estring := strconv.FormatFloat(val, 'e', -1, 64)
```

## Omitting a Comparison Value

Go offers a different approach for `switch`. like:

```go
func main() {
	for counter := 0; counter < 10; counter++ {
		switch {
		case counter == 0:
			fmt.Println("zero value")
		case counter < 3:
			fmt.Println(counter, "is < 3")
		case counter >= 3 && counter < 7:
			fmt.Println(counter, "is > 3 && < 7")
		default:
			fmt.Println(counter, "is > = 7")
		}
	}
}
```

## Comparing Arrays

The == and != can be applied to arrays. NOTE: Arrays are equal if they are of the same type and contain equal elements in the same order.

```go
func main(){
	products := [4]string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	someNames := products[1:3:4]
	fmt.Println(someNames, len(someNames), cap(someNames))
}
```

## Using the `copy`Function

Be used to duplicate an existing slice.

```go
someNames := make([]string, 2)
copy(someNames, allNames)
// note the uninitialized slice pitfall
var someNames []string // no lenth and no cap, can't be copied
```

## Deleting Slice elements

There is no built-in function for deleting slice elements NOTE. can be performed using ranges and `append`.

```go
products := [4]string{"Kayak", "Life", "Paddle", "Hat"}
deleted := append(products[:2], products[3:])
```

## Comparing Slices

Go restricts the use of comparison operator so that slices can be compared only to the `nil`. However, the `reflect`package is declared, the `DeepEqual`function can do:

```go
func main(){
	p1 := []string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	p2 := make([]string, 4)
	copy(p2, p1)
	
	fmt.Println("Equal: ",reflect.DeepEqual(p1, p2)) // true
}
```

## Determining if a value exists in a Map

```go
value, ok := products["hat"]
if(ok) {
    fmt.Println("stored")
}else{
    fmt.Println("no")
}
// ...
if value, ok := products["hat"];ok {
    //...ok
}else{
    //... no
}
```

## Removing from a Map

for map, there is the built-in support `delete`function like `delete(products, "hat")`

## Enumerating a Map in Order

Note, there are no guarantees that the contents of a map will be enumerated in specific order. So:

```go
func main() {
	products := map[string]float64{
		"Kayak":      279,
		"Lifejacket": 48.95,
		"Hat":        0,
	}
	keys := make([]string, 0, len(products))
	for key, _ := range products {
		keys = append(keys, key)
	}
	sort.Sort(sort.Reverse(sort.StringSlice(keys)))
	for _, key := range keys {
		fmt.Println("key: ", key, "value: ", products[key])
	}
}
```

```go
func main(){
	var price []rune =[]rune("$48.95")
	var currency string = string(price[0])
	var amountString string = string(price[1:])
}
```

## The `io.Writer`interface

The code:

```go
func Fprintf(w io.Writer, format string, a ...interface{}) (n int, err error)
```

`io.Writer`is an interface and the `http.ResponseWriter` *satisfies* the interface. 

As a starting point, the best advice is *don't over-complicate things*. Popular and tried-and-tested appraoch.

## HTML Templating and Inheritance

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	ts, err := template.ParseFiles("./ui/html/home.page.html")
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
		return
	}

	err = ts.Execute(w, nil)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal Server error", 500)
	}
}
```

## Template Composition

To save us typing and prevent duplication, just creating a *layout*

```html
{{define "base"}}
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>{{template "title" .}}</title>
    </head>
    <body>
    <header>
        <h1><a href="/">Snippetbox</a></h1>
    </header>
    <nav>
        <a href="/">Home</a>
    </nav>
    <main>{{template "main" .}}</main>
    </body>
    </html>
{{end}}
```

For the `{{template "title" .}}`... use to denote that we want to invoke other named templates named `title`at a particular point in the HTML.

```html
{{template "base" .}}

{{define "title"}} Home {{end}}

{{define "main"}}
    <h2>Latest Snippet</h2>
    <p>There is nothing to see yet</p>
{{end}}
```

`{{template "base" .}}`just inform Go that when the `home.page.html`is executed, invoke the template base. Then:

```go
files := []string{
    "./ui/html/home.page.html",
    "./ui/html/base.layout.html",
}
ts, err := template.ParseFiles(files...)
```

The big benefit of using this pattern to compose templates is that you're able to cleanly define the page specific content in individual files on disk.

## Embedding Partials

And for some applications you might want to break out certain bits of HTML into partials.

Note that, Go also provides `{{block}}...{{end}}`, allows to specify some default content, if the template being invoked doesn't exist in the current set.

## Serving Static Files

`net/http`with a built-in `http.FileServer`handler which can use to serve files over HTTP from a specific dir. Remember the `/static/`is subtree path pattern.

`fileServer := http.FileServer(http.Dir("./ui/static/"))`

When this receives a request, will remove the leading slash from the URL path.

# .NET Fundamentals

`System.Char`defines a range of *static* methods for working. `Char.ToUpper`, `Char.IsWhiteSpace()`, `IsPunctutaion` `IsSymbol` `IsControl`.

The simplest methods for searching within strings, `StartsWith, EndsWith, Contains`. Collections do not usually implement enumerators, they just provide enumerators, via the interface `IEnumerable`.

```cs
string s = "hello";
IEnumerator<char> rator = s.GetEnumerator();
while (rator.MoveNext())
{
    char c = (char)rator.Current;
    Console.WriteLine(c);
}
```

```cs
string[] names = { "Tom", "Dick", "Harry", "Mary", "Jay" };
IEnumerable<string> query = names
    .Where(n => n.Contains("a"))
    .OrderBy(n => n.Length)
    .Select(n => n.ToUpper());
query.ToList().ForEach(Console.WriteLine);
```

```cs
IEnumerable<string> query =
from n in names
where n.Contains("a")
orderby n.Length
select n.ToUpper();
query.Dump();
```

Query expressions always start with a `from`clause and end with either a `select`or a `group`

```cs
string[] names = { "Tom", "Dick", "Harry", "Mary", "Jay" };
IEnumerable<string> query =
from n in names
where n.Length>2
orderby n
select System.Text.RegularExpressions.Regex.Replace(n, "[aeiou]", "");
query.Dump();
```

`let`keyword introduces a new variable alongside the range variable.

```cs
IEnumerable<string> query =
from n in names
let vowelless= Regex.Replace(n, "[aeiou]", "")
where vowelless.Length>2
orderby vowelless
select vowelless;
query.Dump();
```

## Improving the Web Service

`builder.Service.AddCors();`

## Using Async Actions

The ASP.NET core platform processes each request by assigning a thread from a pool. The number of requests that can be porcessed oncurrently is limited to the zieee of the pool. Just like:

```cs
[HttpGet]
public IAsyncEnumerable<Product> GetProducts()
{
    return _dataContext.Products.AsAsyncEnumerable();
}

[HttpGet("{id}")]
public async Task<Product?> GetProduct(long id,
    [FromServices] ILogger<ProductsController> logger)
{
    logger.LogDebug("GetProduct Action invoked");
    return await _dataContext.Products.FindAsync(id);
}

[HttpPost]
public async Task SaveProduct([FromBody] Product product)
{
    await _dataContext.Products.AddAsync(product);
    await _dataContext.SaveChangesAsync();
}

[HttpPut]
public async Task UpdateProduct([FromBody] Product product)
{
    _dataContext.Update(product);
    await _dataContext.SaveChangesAsync();
}

[HttpDelete("{id}")]
public async Task DeleteProduct(long id) { 
    _dataContext.Products.Remove(new Product { ProductId= id });
    await _dataContext.SaveChangesAsync();
}
```

## Preventing Over-Binding

By default, EF core configures the dbs to assign PK values when new objects are stored. The model binding process doesn't understand the significance of the property and adds any values that the client provides to the objects it creates. To create **separate** data model classes that are sued for receiving data through the model binding process.

```cs
public class ProductBindingTarget
{
    public string? Name { get; set; }
    public decimal Price { get; set; }
    public long CategoryId { get; set; }
    public long SupplierId { get; set; }

    public Product ToProduct() => new Product
    {
        Name = this.Name,
        Price = this.Price,
        CategoryId = this.CategoryId,
        SupplierId = this.SupplierId
    };
}
```

```cs
[HttpPost]
    public async Task SaveProduct([FromBody] ProductBindingTarget target)
    {
        await _dataContext.Products.AddAsync(target.ToProduct());
        await _dataContext.SaveChangesAsync();
    }
```

## Using Action Results

ASP.NET Core.. FORE, Action methods can direct MVC Framework to send a sepcific response by returning an object that implements `IActionResult`interface -- known *action results*. Fore --

`Ok, NoContrent(204), BadRequest(400), File, NotFound(404), Redirect, RedirectPermanent, RedirectToRoute... StatusCode`. Can:

```cs
[HttpGet("{id}")]
public async Task<IActionResult> GetProduct(long id,
    [FromServices] ILogger<ProductsController> logger)
{
    logger.LogDebug("GetProduct Action invoked");
    Product? p = await _dataContext.Products.FindAsync(id);
    if (p == null)
    {
        return NotFound();
    }
    return Ok(p);
}

[HttpPost]
public async Task<IActionResult> SaveProduct([FromBody] ProductBindingTarget target)
{
    Product p = target.ToProduct();
    await _dataContext.Products.AddAsync(target.ToProduct());
    await _dataContext.SaveChangesAsync();
    return Ok(p);
}
```

Can also redirect to another method using the `RedirectToAction`method.

```cs
[HttpGet("redirect")]
public IActionResult Redirect()
{
    return RedirectToAction(nameof(GetProduct), new { Id = 1 });
}
```

## Validating Data

Just note: `return BadRequest(ModelState);`

`[ApiController]`can be applied to web service controller classes to change the behavior of the model binding and validation features. The `FromBody`and `ModelState.IsValid`is not required.

## Omitting Null Properties

The command fore, sends a GET request and displays the body of the response from the web service. For.. Projecting Selected Properties -- 

```cs
return Ok(new
    {
        p.ProductId,
        p.Name,
        p.Price,
        p.CategoryId,
        p.SupplierId
    });
```

## Configuring the JSON Serializer

The JSON serializer can be configured to omit properties when it serializes objects. In the Product class just:

```cs
[JsonIgnore(Condition =JsonIgnoreCondition.WhenWritingNull)]
    public Supplier? Supplier { get; set; }
```

It is just difficult to manage for more complex data model. Just in the program.cs file:

```cs
builder.Services.Configure<JsonOptions>(opts=> {
    opts.JsonSerializerOptions.DefaultIgnoreCondition=
    JsonIgnoreCondition.WhenWritingNull;
});
```

1. Use the `Include`and `ThenInclude`
2. Explicitly set navigation props to null

```cs
[HttpGet("{id}")]
public async Task<Supplier?> GetSupplier(long id)
{
    return await context.Suppliers
        .Include(s=>s.Products)
        .FirstOrDefaultAsync(s=>s.SupplierId == id);
}
```

`Include`follows a relationship in the dbs and load the related data. For this, object cycle occurred.

```cs
[HttpGet("{id}")]
public async Task<Supplier?> GetSupplier(long id)
{
    Supplier? supplier = await context.Suppliers
        .Include(s => s.Products)
        .FirstOrDefaultAsync(s => s.SupplierId == id);
    if (supplier!.Products != null)
    {
        foreach (Product p in supplier.Products)
        {
            p.Supplier = null;
        }
    }
    return supplier;
}
```

## Content Formatting

1. formats the client will accept
2. app produces
3. content policy by action method
4. type returned by the action method.
5. if acton method returns a string, content-type is `text/plain`
6. for all other, application/json

```cs
app.MapConrollerRoute("Default",
                      "{controller=Home}/{action=Index}/{id?}");
```

`@model, @using, @page, @section, @addTagHelper,  @namespace, @functions, @attribute, @implements, @inherits, @inject`

@: This expression denotes a section of contrent that is not enclosed in HTML elements.

```cs
			@switch (Model?.Name)
			{
				case "Kayak":
					<tr><th>Name</th><td>Small Boat</td></tr>
					break;
				case "Lifejacket":
					<tr><th>Name</th><td>Flotation Aid</td></tr>
					break;
				default:
					<tr><th>Name</th><td>@Model?.Name</td></tr>
					break;
			}
```

Enumerating Seqs -- The `@foreach`expression generates content for each object in an array or a collection.

## Using the View Bag

Sometimes additional info is required -- Action methods can use the *view bag* to provide a view with extra data.

```cs
public async Task<IActionResult> Index(long id =1)
{
    ViewBag.AveragePrice =
        await context.Products.AverageAsync(p => p.Price);
    return View(await context.Products.FindAsync(id));
}
```

If the body of arrow func is a single `return` fore:

```js
const f = x => { return { value: x } };
const h = x => { value: x }; //error
//console.log(h(5)); // undefined
console.log(f(5))
```

Another workaround is to invoike the `bind()`method of the nested function to define a new function that is implicitly invoked on a specified object like:

```js
const f = (function() {
    this===o;
}).bind(this);
```

Function as namespace:

```js
(function() {
    // chunk of code goes here
}());
```

`apply()`method is like the `call()`except that the args to be passed to the function are specified as an array.

```js
function Range(from, to) {
    this.from = from;
    this.to = to;
}

Range.prototype = {
    includes(x) {
        return this.from <= x && x <= this.to;
    },
    *[Symbol.iterator]() {
        for (let x = Math.ceil(this.from); x <= this.to; x++) yield x;
    }
}

let r = new Range(1, 5);
r instanceof Range;   // true: r inherits from Range.prototype
```

The constructor Property :

```js
let F = function () { }
let p = F.prototype;
let c = p.constructor;
c === F;  // True
```

The File System module has methods for creating new files like:

* `fs.appendFile()`
* `fs.open()`
* `fs.writeFile()`

```js
const fs = require('fs');
fs.appendFile('mynewfile.txt', 'hello content', err => {
    if (err) throw err;
    console.log('Saved!');
}); // if file does not exist, will be created
```

```js
const fs = require('fs');
fs.unlink('myfile3', err => {
    if (err) throw err;
    console.log('file deleted!');
}); //delete unlink() func
```

```js
const url = require('url');
const adr = 'http://localhost:8080/default.htm?year=2017&month=february';
var q = url.parse(adr, true);
console.log(q.host)
console.log(q.pathname);
console.log(q.search);

var qdata = q.query;
console.log(qdata.month);
```

NPM is a package manager for Node.js package, or modules if you like. A package in Node.js containsl all the files you need for a module. Modules are Js libraries U can include in your project.

NPM creates a folder named `node_modules`where the package will be placed. Every action on a computer is an event. Like when a connection is made or file is opened.

```js
const fs = require('fs');
const path = require('path');

const filename= path.resolve(__dirname, "./demofile1.html")
const rs = fs.createReadStream(filename);
rs.on('open', function () {
    console.log('The file is open');
});
```

## Events Module

Node.js has a built-in module, called "Events", where you can create-, fire-, and listen for- your own events.

`let eventEmitter = new events.EventEmitter();` Can assign event handlers to your own events with the `EventEmitter`object.

```js
const events = require('events')
let eventEmitter = new events.EventEmitter();

// Create an event handler
let myEventHandler = function () {
    console.log('I hear a scream!');
}

// Assign the event handler to an event:
eventEmitter.on('scream', myEventHandler);

// Fire the event
eventEmitter.emit('scream');
```

## Mastering the box Model

document flow and the box model. float-based layout...

Universal border-box sizing -- But you will surely run into other elements with the same problem. Can do this with the universal selector * -- which targets all elements on the page as the --

```css
*, 
::before,
::after {
    box-sizing: border-box;
}
```

* `visible`(default) 
* hidden -- content that overflows the container's padding edge is clipped
* scroll
* auto

table-based, and flexbox. Using flexbox -- 

```css
.container {
    display: flex;
}
```

By applying ... just margin can be negative value.
