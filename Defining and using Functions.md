# Defining and using Functions

Go functions have some unusual characteristics. An underscore `_`can be used for parameters are defined by a func but not used in the function's code statements.

```go
func printSuppliers(product string, suppliers ...string) {
	for _, supplier := range suppliers {
		fmt.Println("Product:", product, "Supplier:", supplier)
	}
}

func main(){
	printSuppliers("Kayak", "Acme Kayaks", "Bob's boats")
}
```

Using slices as values for Variadic Parameters like --

```go
names := []string {"..."}
printSuppliers("Kayak", names...)
```

Using pointers as Function parameters --

```go
func swapValues(first, second *int) {
	fmt.Println(*first, *second)
	*first, *second = *second, *first
	fmt.Println(*first, *second)
}

func main() {
	val1, val2 := 10, 20
	swapValues(&val1, &val2)
}
```

An unusual feature of Go functions is the ability to produce more than one result...

```go
func swapValues2(first, second int) (int, int) {
	return second, first
}

func main() {
	val1, val2 := 10, 20
	val1, val2 = swapValues2(val1, val2)
	fmt.Println(val1, val2)
}
```

Giving multiple meanings to a single result can become a problem as projects evolve. so fore:

```go
func calcTax(price float64) (float64, bool) {
    if(price>100){
        return price*0.2, true
    }
    return 0, false
}
```

Then can use an initialization statement in the main.go like:

```go
if taxAmount, taxDue := calcTax(price), taxDue {
    //...
}else{/*...*/}
```

```go
func calcTotalPrice(products map[string]float64, minSpend float64) (total, tax float64) {
	total = minSpend
	for _, price := range products {
		if taxAmount, due := calcTax(price); due {
			total += taxAmount
			tax += taxAmount
		} else {
			total += price
		}
	}
	return
}
```

## `defer`keyword

used to schedule a function call that will be performed immediately before the current function returns.

Functions have a data type in Go, which means they can be assigned to variables used as function parameters, arguments, and results.

```go
func calcWithTax(price float64) float64 {
	return price + price*0.2
}
func calcWithoutTax(price float64) float64 {
	return price
}

func main() {
	calcFuncs := []func(float64) float64{calcWithTax, calcWithoutTax}
	for _, f := range calcFuncs {
		fmt.Println(f(275))
		fmt.Println(f(48.95))
	}
}
```

```go
var calcFunc func(float64)float64
if(price>100) {
    calcFunc= calcWithTax
}else{
    calcFunc= calcWithoutTax
}
```

```go
func selectCalculator(price float64) func(float64)float64 {
    if(price>100){
        return calcWithTax
    }
    return calcWithoutTax
}
```

## Creating Function Type Aliases

```go
type calcFunc func(float64)float64
func printPrice(product string, price float64, calculator calcFunc) {...}

// using the literal function syntax
if (price>100) {
    var withTax calcFunc = func(price float64) float64 {//...}
}
```

## Converting between Struct types

A stuct type can be converted into any other struct type that has just the same fields. Same name and type and are defined in same order.

Anonymous Struct Types -- like:

```go
func writeName(val struct {
	name, category string
	price          float64
}) {
	fmt.Println("Name: ", val.name)
}

func main() {
	type Product struct {
		name, category string
		price          float64
	}
	type Item struct {
		name, category string
		price          float64
	}

	writeName(Product{"Kayak", "Watersports", 275.00})
	writeName(Item{"Statdium", "Soccer", 75000})
}
```

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}
	
	prod := Product{name: "Kayak", category: "Watersports", price:275.00}

	var builder strings.Builder
	json.NewEncoder(&builder).Encode(struct {
		ProductName string
		ProductPrice float64
	}{
		ProductName: prod.name,
		ProductPrice: prod.price,
	})
	fmt.Println(builder.String())
}
```

## Creating Arrays, Slices, and Maps Containing Struct Values

The `struct`type can be omitted when populating arrays, slices, and maps with struct values.

Understanding Structs and Pointers -- But this has a Convenience Syntax in Go. To simplify this type of code, Go will follow pointers to struct fields without needing an asterisk characters like: like:

```go
func calcTax(product *Product) {
    if(product.price>100)...
}
```

## Understanding Struct Constructor Functions

A constructor function is reponsible for creating struct values using values received through parameters.

```go
func newProduct(name, category string, price float64) *Product {
    return &Product{name, category, price}
}
```

The benefit of using ctor function is consistency - ensuring that changes to the construction process are reflected in all the struct vlaues created by function.

```go
func (p *Product) printDetails(){
	fmt.Println("Name:", p.name, "Category", p.category, "Price:", p.price)
}

func main(){
	products := []*Product {
		{"Kayak", "Watersports", 275},
		{"Lifejacket", "Watersports", 48.95},
		{"Soccer Ball", "Soccer", 19.50},
	}

	for _, p := range products {
		p.printDetails()
	}
}
```

Method Parameters and Results -- Methods can define parameters and results, 

```go
func (p *Product) calcTaxMethod(rate, threshold float64) float64 {
	if p.price > threshold {
		return p.price + p.price*rate
	}
	return p.price
}
```

In go, each combination of method name and receiver type must be unique. A method whose receiver is a pointer type can also be invoked through a regular value of the underlying type. The opposite process is also <font color='red'>true</font>.

Defining Methods for Type Aliases -- Methods can be defined for any type defined in the current package.

```go
type ProductList []Product

func (products *ProductList) calcCategoryTotals() map[string]float64 {
	totals := make(map[string]float64)
	for _, p := range *products {
		totals[p.category] = totals[p.category] + p.price
	}
	return totals
}

func main() {
	products := ProductList{
		{"Kayak", "Watersports", 275},
		{"Lifejacket", "Watersports", 48.95},
		{"Soccer Ball", "Soccer", 19.50},
	}

	for category, total := range products.calcCategoryTotals() {
		fmt.Println("Category: ", category, "Total", total)
	}
}
```

The pattern `"/static/"`is a subtree path pattern, so it acts a bit like threre is a wildcast at the end. if:

```go
fileserver := http.FileServer(http.Dir("./ui/static"))
// when this receives a request, will remove the leading slash from the URL path and
// then search ./ui/static
// then must strip the leading "/static"
mux.Handle("/static", http.StripPrefix("/static", fileServer))
```

## The `http.Handler`Interface

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

Just means that to be a handler an object *must* have a `ServeHTTP()`method with the :

```go
ServeHTTP(http.ResponseWriter, *http.Request)
```

In itssimplest form handler might look something like this:

```go
type home struct {}
func (h *home) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("This is home page"))
}
```

Could then register this wiht a `servemux`using the `Handle`method.

```go
mux := http.NewServerMux()
mux.Handle("/", &home{})
```

## Handler Functions 

Which is why in practice it's far more common to write your handlers as a **normal** function like:

```go
func Home(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("This is my home page"))
}
```

For this function, it is not a handler, instead need to transform it into a handler using:

```go
mux := http.NewServeMux()
mux.Handle("/", http.HandlerFunc(home))
```

This adapter works by automatically adding a ServeHttp() method to the `home`func. servemux also has a `ServeHTTP()`method, meanting that it twoo satisfies the `http.Handler`interface. as just being a *special kind of handler*.. There is one more thing -- *all incoming HTTP requests are served in their own goroutine*.

```go
	addr := flag.String("addr", ":4000", "HTTP network address")
	flag.Parse()
```

## The http.Server Error Log

```go
errorLog := log.New(os.Stderr, "ERROR\t", log.Ldate|log.Ltime|log.Lshortfile)
srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  mux,
}

log.Printf("Starting server on %s", *addr)
err := srv.ListenAndServe()
log.Fatal(err)
```

## Centralized Error Handling

By moving some of the error handling code into helper methods -- separate our concerns and stop us repeating code as we progress through the build.

```go
func (app *application) serverError(w http.ResponseWriter, err error) {
	trace := fmt.Sprintf("%s\n%s", err.Error(), debug.Stack())
	app.errorLog.Println(trace)

	http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

func (app *application) clientError(w http.ResponseWriter, status int) {
	http.Error(w, http.StatusText(status), status)
}

func (app *application) notFound(w http.ResponseWriter) {
	app.clientError(w, http.StatusNotFound)
}
```

* The `debug.Stack()`function to get a stack trace for the *current goroutine* and append it to the log message.
* Then go back to the `handler.go`file like:

## Isolating the App Routes...Linq Operators

`Select, SelectMany, Join, and GroupJoin`operator, Query expression with multiple range variables.

## Filtering

`Where, Take, TakeLast, TakeWhile, Skip, SkipLast, SkipWhile, Distinct, DistinctBy`.

`IEnumerable<TSource> -> IEnumerable<TResult>`, `Select, SelectMany`.

`Join, GroupJoin, Zip`, `OrderBy, OrderByDescending, ThenBy, ThenByDescending, Reverse`

`GroupBy, Chunk`, and `Concat, Union, UnionBy, Intersect, IntersectBy, Except, ExceptBy`

`OfType, Cast`

`ToArray, ToList, ToDictionary, ToLookup, AsEnumerable, AsQueryable`

`First, FirstOrDefault, Last, LastOrDefault, Single, SingleOrDefault, ElementAt...`

`Aggregate, Average, Count, LongCount, Sum, Max, Min`

`All, Any, Contains, SequenceEqual`

`Empty, Range, Repeat`

```cs
(from n in names
where n.Length>3
let u = n.ToUpper()
where u.EndsWith("Y")
select u).Dump();
```

Note that `where`'s predicate optionally accepts a second arg of type `int`-->

```cs
var query = from f in FontFamily.Families select f.Name;
query.Dump();
```

```cs
var query = names.Select((s, i) => i + "=" + s);
query.Dump();
```

## Subqueries and joins in EF core 

Subquery projections work well in EF core, and you can use them to do the work. like:

```cs
(from p in Purchases
 where p.Price > 1000
 select new { p.Description, p.Price }).Dump();
```

## `SelectMany`

Concatnates subsequences into a single flat output sequence.

Can use this to expand child sequences, flatten nested, and join two into a flat one. Like:

```cs
string[] fullNames = { "Anne Williams", "John Fred Smith", "Sue Green" };
fullNames.SelectMany(n=>n.Split(" ")).Dump();
```

Cuz we're mapping each input element to a variable number of output elements.

Joining in fluent Syntax like:

```cs
Customers.Join(
Purchases,
c=>c.ID,
p=>p.CustomerID,
(c,p)=>new {c.Name, p.Description, p.Price}).Dump();
```

zip:

```cs
int[] numbers = { 3, 5, 7 };
string[] words = { "three", "five", "seven" };
numbers.Zip(words, (n, w) => n + "=" + w).Dump();
```

## Generation Methods

`Empty, Repeat, and Range`.

MinBy and MaxBy

`MinBy`and `MaxBy`return the element with the smallest or largest value like:

```cs
string[] names = { "Tom", "Dick", "Harry", "Mary", "Jay" };
names.MaxBy(n=>n.Length).Dump(); // Harry
```

`SequenceEqual`Compares two sequences, To return `true`each must have identical elements.

```cs
foreach(int i in Enumerable.Range(5,3)) // 5 6 7
foreach(bool x in Enumerable.Repeat(true, 3)) // True true true
```

## Working with Layouts

`_Layout.cshtml`file in the `Views/Shared`folder like:

```html
<head>
    <title>@View.Title</title>
</head>
<body>
    <h6 class="bg-primary">
        Shared view
    </h6>
    @RenderBody()
</body>
<!-- in other files -->
@{
ViewBag.Title="Product Table"
}
```

The content that is unique to each view is inserted into the response by calling `RenderBody`

Using Sections -- Optional Layout Sections -- By default, a view must contain all...

```html
@await RenderSectionAsync("Summary", false)
```

The second arg specifies whether a section is required. Or using `IsSectionDefined`.

## Partial Views

Contain fragments of content that will be includedin other views to produce complex response. 

`@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers`

```html
@section Summary{
	<div class="bg-info text-white m-2 p-2">
		@Json.Serialize(Model)
	</div>
}
```

The `Json`property just returns an implementation of the IJsonHelper interface, whose `Serialize`produces a JSON representation of an object.

# Razor Pages

```cs
builder.Services.AddRazorPages();
var app = builder.Build();
//...
app.MapRazorPages();
```

The `AddRazorPages`sets up the service that is required to use RPs, and `MapRazorPages()`creates the routing configuration that matches URL to pages.

When the RP is selected to handle an HTTP request, a new instance of the page model class is created, and DI is used to resolve any dependencies .

```cs
public async Task OnGetAsync(long id = 1) {
    Product=await context.Products.FindAsync(id);
}
```

Rps rely on the location of the CSHTML file for routing so that a request for handled by `pages/index.cshtml`.

The query string provides a parameter named `id`which the model binding process uses to satisfy the id parameter defined by the `OnGetAsync`. Note that the `@page`directive can be used with a routing pattern, allows segment to be defined like: And can be used to override the file-based convention for a RP.

## `PageModel`class

`HttpContext, ModelState, Request, Response, RouteData, TempData`

Action Results in Rps -- like:

```cs
public async Task<IActionResult> OnGetAsync(long id=1)
{
    Suppliers = context.Suppliers.Select(s => s.Name!);
    Product = await context.Products.FindAsync(id);
    return Page();
}
```

Page() method is inherited from the `PageModel`class and creates a `PageResult`object -- tells the framework to render the view part of the page. Doesn't accept args and always renders the view part of the page.

`Page, NotFound, BadRequest(state), File(name, type), Redirect(path), `

`RedirectPermanent(path), RedirectToPage(name), StatusCode(code)`

Fore, instead of using the `NotFound`when requested data cannot be found, fore, a better approach is to redirect the client to another URL that can display an HTML message for the user.

## Handling Multiple HTTP Methods

The most common combination is to support GET and POST.

```html
<form method="post">
    @Html.AntiForgeryToken()
    <div class="mb-3">
        <label>Price</label>
        <input name="price" asp-for="Product!.Price" class="form-control" />
    </div>
    <button class="btn btn-primary mt-2" type="submit">Submit</button>
</form>
```

`@Html.AntiForgeryToken()`adds a hidden form field to the HTML form that ASP.NET core uses to guard cross-site request forgery.

## Selecting a Handler Method

Note, The page model class can define multiple handler methods, allowing the request to select a method using a `handler`query string parameter or routing segment variable.

```html
 <a href="/handlerselector?handler=related" class="btn btn-primary">Related</a>
```

The name of the handler method is specified without the `On[method]`prefix.. using a handler with the `related`.

Razor pages can also use partial views.

# public, private and static fields

```js
class Buffer{
    size = 0;
    capacity = 4096;
    buffer = new Uint8Array(this.capacity);
}
```

if use # private like:

```js
class Buffer{
    #size=0;
    get size(){return this.#size;}
}
```

```js
if(!String.prototype.startsWith) {
    String.prototype.startsWith=function(s) {
        return this.indexOf(s)===0;
    }
}
```

## Subclasses and Prototypes

from the prototype:

```js
Span.prototype=Object.create(Range.prototype);
Span.prototype.consturctor=Span;
```

ES6 solves these problems with the `super`.

```js
class EZArray extends Array{
    get first() { return this[0]; }
    get last() { return this[this.length - 1]; }
}
```

```js
class TypedMap extends Map {
    constructor(keyType, valueType, entries) {
        if (entries) {
            for (let [k, v] of entries) {
                if (typeof k !== keyType || typeof v !== valueType) {
                    throw new TypeError(`Wrong type for entry [${k}, ${v}]`);
                }
            }
        }
        super(entries); // just initialize the superclass

        // and then initialize this subclass by storing the types
        this.keyType = keyType;
        this.valueType = valueType;
    }

    set(k, v) {
        if (this.keyType && typeof k !== this.keyType) {
            throw new TypeError("wrong key type");
        }
        if (this.valueType && typeof v !== this.valueType) {
            throw new TypeError("Wrong value type");
        }

        return super.set(k, v);
    }
}
```

## Delegation instead of Inheritance

```js
class Historgram{
    constructor() {
        this.map = new Map();
    }

    count(key) { return this.map.get(key) || 0; }
    has(key) { return this.count(key) > 0; }
    get size() {
        return this.map.size;
    }
    add(key) {
        this.map.set(key, this.count(key) + 1);
    }
    delete(key) {
        let count = this.count(key);
        if (count === 1) {
            this.map.delete(key);
        } else if (count > 1) {
            this.map.set(key, count - 1);
        }
    }
    [Symbol.iterator]() { return this.map.keys(); }
    keys() { return this.map.keys(); }
    values() { return this.map.values(); }
    entries() { return this.map.entries(); }
}
```

How can define *abstract classes* -- do not include a complete implementation. fore:

```js
class AbstractSet{
    // throw a error here so that subclasses are forced to define
    // their own working version of this method like:
    has(x) { throw new Error("Abstract method!"); }
}
```

```js
class AbstractEnumerableSet extends AbstractSet {
    get size() { throw new Error("Abstract method!"); }
    [Symbol.iterator]() { throw new Error("Abstract method"); }
}

class SingletonSet extends AbstractEnumerableSet {
    constructor(member) {
        super();
        this.member = member;
    }

    has(x) { return x === this.member; }
    get size() { return 1; }
    *[Symbol.iterator]() { yield this.member; }
}

// ...
class BitSet extends AbstractWritableSet{
    constructor(max) {
        super();
        this.max = max;
        this.n = 0;
        //...
    }
}
```

# Standard Library

Js set -- is a collection, and not allow duplicates. Note the `delete()`method just. And cuz Set objects are iterable too, can convert them to arrays and argument lists with ... spread operator too.

Typed Array Types -- Js does not define a `TypedArray`class. Instead, there are 11 kinds of typed arrays. 

`Int8Array(), Uint8Array()`...

```js
let bytes= new Uint8Array(1024);
let matrix = new Float64Array(9);
let point = new Int16Array(3);
let ints = new Int16Array(10);
ints.fill(3).map(x => x * x).join('');
```

```js
let clock = setInterval(() => {
    console.clear();
    console.log(new Date().toLocaleTimeString());
}, 1000);
setTimeout(() => clearInterval(clock), 10000);
```

Iterators can be used with destructing assignment:

```js
let purpleHaze = Uint8Array.of(255, 0, 255, 128);
let [r, g, b, a]= purpleHaze;
let m = new Map([["one", 1], ["two", 2]]);
for(let [k, v] of m) console.log(k,v);
[...m]
```

An *iterable* object is any object with a special iterator method that returns an iterator object. An *iterator* is any object with a `next()`method that returns an iteration result object. just:

```js
let iterable = [99, 100, 101];
let iterator = iterable[Symbol.iterator]();
for (let result = iterator.next(); !result.done; result = iterator.next()){
    console.log(result.value);
}
```

The iterator object of the built-in  iterable datatypes is itself iterable.

```js
let list = [...new Array(5).keys()].map(x => x + 1);
let iter = list[Symbol.iterator]();
let head = iter.next().value;
let tail = [...iter];
tail // [2,3,4,5]  , namely, partially used
```

In order to make a class iterable, just implement a method whose name is `[Symbol.iterator]`. Return an object:

```js
return {
    [Symbol.iterator](){
        return this;
    }, //make the iterator itself iterable.
    next(){
        ...
    }
}
```

```js
function* oneDigitPrims() {
    yield 2; yield 3; yield 5;
    yield 7; yield 11;
}
let prime = oneDigitPrims();
[...oneDigitPrims()]
```

## Node.js upload Files

In Node typically need two arguments, cuz the first to a callback is often an error object. like:

```js
const fs = require('fs');
fs.readFile('package.json', (err, text)=>...)
```

```js
const fs = require('fs');
const zlib = require('zlib');
const gzip = zlib.createGzip();
const path = require('path');

const outStream = fs.createWriteStream('output.js.gz');

filename = path.resolve(__dirname, './example.js');
fs.createReadStream(filename).pipe(gzip).pipe(outStream);
```

And if you want to organize related modules, can put modules into subdirectories. like:

`const currency = require('./lib/currency');`

By default, `box-sizing`is set to the value of `content-box`-- any height or width you specify only sets the size of the content box. Set to `border-box`. 

```css
*, 
::before,
::after {
    box-sizing: border-box;
}
:root{
    box-sizing: border-box;
}
*, ::before, ::after{
    box-sizing: border-box;
}
```

By applying `display:flex`to the container, it becomes a *flex container*. Its child elements will become the same height by default.

## Negative margins

The negative margin moves the element leftward or upward, respectively. Insteading of fixing margins for the current page contents. lobotomized owl selector `* + *`.

