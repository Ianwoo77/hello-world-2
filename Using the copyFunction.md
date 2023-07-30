## Using the `copy`Function

The `copy`is used to copy elements between slices. This can be used to ensure that slices have separate arrays and to create slices that combine elements from different sources.

### Using to Ensure Slice Separation

```go
func main() {
	products := [4]string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	allNames := products[1:]
	someNames := make([]string, 2)
	copy(someNames, allNames)

	fmt.Println(someNames)
	fmt.Println(allNames)
}
```

The slices don’t need to have the same length cuz the `copy`func will copy elements only until the end of the destination or source slice is reached.

### the Uninitialized Slice Pitfall

The `copy`doesn’t resize the destination slice. A common is to try to copy into a slice has not been initialized.

```go
allNames := products[1:]
var someNames []string
copy(someNames, allNames) // someNames: []
```

Uninitialized slices have zero len and zero cap.

### Specifying Ranges when copying slices

```go
someNames := []string {"boots", "canoe"}
copy(someNames[1:], allNames[2:3]) // allNames [., ., Hat]
// someNames: [boots, Hat]
```

### Copying with different Sizes

If the dest is larger then the source, then copying will continue until the last in the source has been copied. like:

`copy(products[0:1], replacemantProducts)`

### Deleting Slice elements

Note, for go, there is no built-in function for deleting slice elements, but, this operation can be just performed using the ranges and the `append`func like:

```go
func main(){
	products := [4]string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	deleted := append(products[:2], products[3:]...) // Paddle deleted
	fmt.Println(deleted)
}
```

### Enumerating Slices

```go
for index, value := range products[2:] {
    fmt.Println(index, value)
}
```

### Sorting

Using the `sort`package like:

```go
func main() {
	products := []string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	sort.Strings(products)
	for index, value := range products {
		fmt.Println("Index", index, "value:", value)
	}
}
```

### Comparing Slices

Go restricts the use of the comparison so that slices can be compared only to the `nil`value. And, there is one way to compare slices -- the STDLIB includes a package -- `reflect` like:

```go
func main() {
	p1 := []string{"Kayak", "lifejacket"}
	p2 := p1
	fmt.Println("Equal", reflect.DeepEqual(p1, p2)) // true
}
```

### Getting the Array underlying a slice

If have a slice, but need an array -- requirs one as an argument, then perform an explicit conversion on the slice like:

```go
func main() {
	p1 := []string{"Kayak", "lifejacket", "Paddle", "Hat"}
	arrayPtr := (*[3]string)(p1)
	array := *arrayPtr
	fmt.Println(array)
}
```

First explicit conversion on the `[]string`slice to `*[3]string`. Note, care must be taken when specifying the array cuz an error will occur -- if number exceeds the length of the slice.

## Working with Maps

```go
func main() {
	products := make(map[string]float64, 10) // 10, initial size
	products["kayak"] = 279
	products["Lifejacket"] = 48.95

	fmt.Println("Map size:", len(products))
	fmt.Println("Price:", products["kayak"])
	fmt.Println("Price:", products["Hat"])   // 0
}
```

### Map literal Syntax

```go
products := map[string]float64 {
    "kayak": 279,
    "lifejacket":48.95,
}
```

### Checking for item in a Map

```go
value, ok := products["Hat"]
if ok {
    fmt.Println("Stored value:", value)
}else {
    fmt.Println("no stored value", value)
}

// or using an initialization statment
if value, ok := products["hat"], ok {
    fmt.Println(...)
}else {...}
```

### Removing items from a Map

```go
delete(products, "kayak")
if value, ok := products["kayak"]; ok {
    fmt.Println("stored value", value)
}else {
    fmt.Println("no stored")
}
```

### Enumerating

Like:

```go
for key, value := range products {
    fmt.Println("key:", key, "value:", value)
}
```

### Enumerating in order

Also, using `sort`package fore:

```go
func main() {
	products := make(map[string]float64, 10)
	products["kayak"] = 279
	products["Lifejacket"] = 48.95
	products["hat"] = 0

	keys := make([]string, 0, len(products))
	for key, _ := range products {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	for _, key := range keys {
		fmt.Println(key, products[key])
	}
}
```

### Dual Nature of Strings

Go treats strings as arrays of bytes and supports the array index and slice range notation -- like:

```go
var price string = "$48.95"
var currency byte = price[0] // Currency 36
var amountString string = price[1:]
amount, parseErr := strconv.ParseFloat(amountString, 64)

// can:
var currency string = string(price[0])
```

### Converting a String to `rune`

The `rune`type represents a Unicode code point. Is essentially a single character.

```go
func main() {
	var price []rune = []rune("€48.95")
	var currency string = string(price[0])
	var amountString string = string(price[1:])
	amount, parseErr := strconv.ParseFloat(amountString, 64)

	fmt.Println("length", len(price))
	fmt.Println("Currency", currency)
	if parseErr == nil {
		fmt.Println(amount)
	} else {
		fmt.Println("ParseErr", parseErr)
	}
}
```

### Omitting Parameter Names

The `_`can be used for parameters that are defined by a function but not used in the func’s code.

```go
func printPrice(product string, price, _ float64) {}
```

A variadic parameter accepts a variable number of values like:

```go
func printSuppliers(product string, suppliers ...string) {
	for _, supplier := range suppliers {
		fmt.Println("product:", product, "supplier:", supplier)
	}
}

func main() {
	printSuppliers("kayak", "acme kayaks", "bob's boats")
}
```

And, Go allows args for variadic to be omitted entirely. For this situation:

```go
if len(suppliers)==0 {
    fmt.Println("(none)")
}
// using Slices as value for variadic parameters
names := []string {"..."}
printSuppliers("kayak", names...)
```

### Using Pointer as Function parameters

By default, Go **copies** the values used as argument so that changes are limited to within the function.

```go
func swapValues(first, second *int) {
	fmt.Println("Before swap", *first, *second)
	*first, *second = *second, *first
	fmt.Println("After swap", *first, *second)
}

func main() {
	val1, val2 := 10, 20
	swapValues(&val1, &val2)
	fmt.Println(val1, val2)
}
```

### Defining and using Function Results

Functions define results, which allow functions to provide their callers with the output from operations.

```go
func calcTax(price float64) float64 {
    return price + (price*0.2)
}

for product, price := range products{
    priceWithTax := calcTax(price)
}
```

### Returning Multiple Function Results

```go
func swapValues(first, second int)  (int, int) {
    return second, first
}
```

Named Result -- A function’s results can be given names, which can be assigned values during the function’s execution. like:

```go
func calcTax(price float64) (float64, bool) {
    //...
}

func calcTotalPrice(products map[string]float64, 
                    minSpend float64) (total, tax float64) {
    total = minSpend
    for _, price := range products {
        if taxAmount, due := calcTax(price); due {
            total += taxAmount
            tax += taxAmount
        }else {
            total+=price
        }
    }
    return
}
```

Just note that the `return`is used on its own, allowing the current values assigned to the named result to be returned.

### Using the Blank to Discard Results

```go
_, total := calcTotalPrice(products)
```

`defer`is used to schedule a function call that will be performed immediately before the current function returns.

```go
func calcTotalPrice(products map[string]float64) (count int, total float64) {
    defer fmt.Println("first defer call")
    //...
    defer fmt.Println("Second defer call")
}
```

### `wc, head, cut, grep, sort`commands in the Linux

Note that the `ls -1` -- tells `ls`to print its result in a single column.

```sh
cut -f1 grades | sort | uniq -c | sort -nr
```

Then, do some actual work -- combine what learned with a larger example -- are in a directory foll of JEPG.

```sh
md5sum image001.jpg
```

This given file’s checksum -- for mathmatical reason -- likely to be unique. And, If two files have just the same checksum, like:

```sh
md5sum *.jpg | cut -f1 | sort
md5sum *.jpg | cut -c1-32 | sort | uniq -c
```

If there are no duplicates, all of the counts produced by `uniq`just will be 1.

```sh
md5sum *.jpg | cut -c1-32 | sort | uniq -c | sort -nr
```

## Introducing the Shell

`bash`and other shells do much more than simply run commands. Every time a command runs, some steps are the responsibility of the invoked program fore, `ls`

- pattern matching for filenames
- Variables to store values
- Redirection of input and output
- Quoting and escaping to disable certain shell features.

### Using `Synaptic`for software Management

```sh
whereis fdisk
```

Linux has inherited from UNIX a well-planned hierarchy for organiing things. For these:

- `/`-- The root
- `/bin`-- Essential commands
- `/boot`, boot loader files, Linux kernel
- `/dev`-- device files
- `/etc`-- system configuration files
- `/home`-- user home dir
- `/lib`-- shared libs, kernel modules
- `/mnt`-- Mount point for removable media.
- `/opt`-- add-on software packages
- `/root`-- super user (root) home
- `sbin`-- system commands
- `/sys`-- real-time info on devices used by the kernel
- `/var` -- variable fiels relating to services that run on the system.

### Altering File Permissions with `chmod`

Can just use the `chmod`to alter a file’s permissions. `u, g, o, a, r, w, x`, u for user, g for group, o for others, a for all, r, for read, w, for write, and x for execution like:

```sh
chmod a-w readme.txt  # remove all write permission
chmod u+rw readme.txt # for user
# can also use the octal form of chmod 
chm
```

# Advanced C#

## Delegates

The following defines a delegate type called `Transformer`

```cs
int Square(int x) => x * x;
Transformer t = Square;
int answer = t(3);
answer.Dump();

delegate int Transformer(int x);
```

### Writing Plug-in Methods with Delegates

A delegate variable is assigned a method at runtime. Useful for writing plug-in methods. Can:

```cs
int[] values = { 1, 2, 3 };
Transform(values, (int x) => x * x);
values.Dump();

void Transform(int[] values, Transformer t)
{
	for (int i = 0; i < values.Length; i++)
		values[i] = t(values[i]);
}

delegate int Transformer(int x);
```

### Instance and Static Method Targets

A delegate’s target method can be a local, static or instance method. the following illustrate:

```cs
Transofmer t = Test.Square;
class Test {
    public static int Square(int x)=> x*x;
}
delegate int Transformer(int x);
```

Note that when an *instance* method is assigned to a delegate obj, the latter maintains a reference not only to the method but also to the *instance* to which the method belongs.

### Multicast Delegates

All delegates instances have *multicast* cap. This is a delegate instance can reference not just a single target method but also a list of target methods. like:

```cs
SomeDelegate d = SomeMethod1;
d += SomeMethod2;
```

FORE:

```cs
ProgressReporter p = (int p) => Console.WriteLine(p);
p += (int p) => Console.WriteLine("also " + p.ToString());
Util.HardWork(p);

public delegate void ProgressReporter(int percent);
public class Util
{
	public static void HardWork(ProgressReporter p)
	{
		for (int i = 0; i < 10; i++)
		{
			p(i * 10);
			System.Threading.Thread.Sleep(100);
		}
	}
}
```

## Generic Delegate Types

A delegate type can contain generic type parameters like:

```cs
public delegate T Transformer<T> (T arg);
public class Uitl {
    public static void Transform<T> (T[] values, Transformer<T> t) {
        //...
    }
}
```

### `Func`and `Action`

Are so general they can work for methods of any return type and any (reasonable) number of arguments. These delegates are the `Func`and `Action`delegates. like:

```cs
delegate TResult Func<out TResult>();
delegate TResult Func<in T, out TResult>(T arg);
// and so on, up to T16

delegate void Action();
delegate void Action<in T> (T arg);
// up to T16
```

Are extremely general – The `Transfomer`delegate can be replaced with a `Func`delegate like:

```cs
public static void Transform<T>(T[] values, Func<T, T> transformer){
    //...
    values[i]= transformer(values[i]);
}
```

### Delegates and Interfaces

Note that a problem can solve with a delegate can also be solved with an interface. FORE, can rewrite original like:

```cs
public interface ITransformer {
    int Transformer(int x);
}

public static void TransformAll(int[] values, ITransformer t) {
    for(int i=0; i<values.Length; i++)
        values[i]= t.Transform(values[i]);
}

public class Squarer: ITransformer {
    public int Transform(int x) => x*x;
}
```

### Delegate Compability

Delegate types are all incompatible with one another – even if their signatures are the same.

```cs
D1 d1 = Method1;
D2 d2 = d1; // error
D2 d2 = new D2(d1); //ok
```

And, Delegate instances are considered equal if they have just the same method targets.

### Parameter Compatibility

A delegate can have more specific parameter types than its method target. Like:

```cs
StringAction sa = new StringAction(ActOnObject);
sa ("hello");

void ActOnAction (object o) => Console.WritreLine(o);
delegate void StringAction(string s);
```

## Events

When using delegates, two – broadcaster and subscriber. The *broadcaster* is a type that just contains a delegate filed, and the broadcaster decides when to broadcast, by invoking the delegate. The *subscribers* are method target recipients. A subscriber just decides when to start and stop listening by calling `+=`and `-=`.

```cs
public delegate void PriceChangeHandler(decimal oldPrice, decimal newPrice);

public class Broadcaster {
	// event declaration
	public event PriceChangeHandler PriceChanged;
}
```

Code within the `Broadcaster`has full access to `PriceChanged`and can treat it as a delegate. And code outside of the `Broadcaster`can perform only += and -= op on the `PriceChanged`event.

inside – when:

```cs
public class Broadcaster {
    public event PriceChangedHandler PriceChanged;
}

// translates like:
PriceChangedHandler priceChanged;
public event PriceChangedHandler PriceChanged {
    add {priceChanged+= value;}
    remove {priceChanged-= value;}
}
```

Second, the compiler looks within the class for references to `PriceChanged`that perform ops other then += and -= and redirects them to the underling `priceChanged`delegate field. Just like:

```cs
public delegate void PriceChangedHandler(decimal oldPrice, decimal newPrice);

public class Stock
{
	string symbol;
	decimal price;

	public Stock(string symbol) => this.symbol = symbol;

	public event PriceChangedHandler PriceChanged;

	public decimal Price
	{
		get => price;
		set
		{
			if (price == value) return;
			decimal oldPrice = price;
			price = value;
			if (PriceChanged != null)
				PriceChanged(oldPrice, price);
		}
	}
}
```

Note, if remove the `event`keyword from example – just becomes an ordinary delegate field, our example would give the same results.

### Standard Event Pattern

In almost all cases for which events are defined in the .NET – adheres to a std pattern designed to provide consistency across library and user code. At the core of the std event pattern is `System.EventArgs` – predefined .NET class with no members – is a base class for conveying info for an event. Can:

```cs
public class PriceChangedEventArgs : System.EventArgs
{
	public readonly decimal LastPrice;
	public readonly decimal NewPrice;
	public PriceChangedEventArgs(decimal lastPrice, decimal newPrice)
	{
		LastPrice = lastPrice;
		NewPrice = newPrice;
	}
}
```

The next is to choose or define a delegate for the event - three rules like:

- must have a `void`return type.
- must accept two arguments, first is `object`and second a subclass of `EventArgs`.
- Name must end with `EventHandler`, just represents a delegate.

.NET defines a generic handler – `System.EventHandler<>`like:

`public delegate void EventHandler<TEventArgs>(object source, TEventArgs e)`

And the next step is to just define an event of the chosen delegate type. Can use the generic `EventHandler`delegate. like:

```cs
public class Stock
{
	//...

	public event EventHandler<PriceChangedEventArgs> PriceChanged;

	protected virtual void OnPriceChanged(PriceChangedEventArgs e)
	{
		PriceChanged?.Invoke(this, e);
	}

	public decimal Price
	{
		get => price;
		set
		{
			if (price == value) return;
			decimal oldPrice = price;
			price = value;
			OnPriceChanged(new PriceChangedEventArgs(oldPrice, price));
		}
	}
}

Stock stock = new Stock("THPW");
stock.Price = 27.10M;
stock.PriceChanged += (s, e) =>
{
	if ((e.NewPrice - e.LastPrice) / e.LastPrice > 0.1M)
	{
		Console.WriteLine("10% price increase!");
	}
};
stock.Price = 27.20M;
```

## Using URL Routing

- Consolidates the processing and matching of URLs, allowing components known as *endpoints* to generate responses.
- Obviates the need for each middleware component to process the URL to see whether the request will be handled or passed along the pipeline.
- Routing **middleware** components are added to the request pipeline and configured with a set of routes.

```cs
public class Population
{
    private RequestDelegate? next;

    public Population(RequestDelegate nextDele)
    {
        next = nextDele;
    }

    public async Task Invoke(HttpContext context)
    {
        string[] parts = context.Request.Path.ToString()
            .Split('/', StringSplitOptions.RemoveEmptyEntries);
        if(parts.Length == 2 && parts[0]=="population" )
        {
            string city = parts[1];
            int? pop = city switch
            {
                "london" => 8136000,
                "paris" => 2141000,
                "monaco" => 39000,
                _ => null
            };
            if(pop.HasValue)
            {
                await context.Response.WriteAsync($"City: {city}, Population: {pop}");
                return;
            }
        }
        await next!.Invoke(context);
    }
}

public class Capital
{
    private RequestDelegate? next;
    public Capital() { }

    public Capital(RequestDelegate nextDele)
    {
        next= nextDele;
    }

    public async Task Invoke(HttpContext context)
    {
        string[] parts = context.Request.Path.ToString()
            .Split("/", StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 2 && parts[0] == "capital")
        {
            string country = parts[1];
            string? capital = country switch
            {
                "uk" => "london",
                "france" => "Paris",
                _ => null
            };
            if (capital != null)
            {
                await context.Response
                    .WriteAsync($"{capital} is the capital of {country}");
                return;
            }
        }
        await next!.Invoke(context);
    }

}
```

In the program.cs file just:

```cs
app.UseMiddleware<Population>();
app.UseMiddleware<Capital>();
app.Run(async (context)=> {
    await context.Response.WriteAsync
})
```

### Understanding URL routing

Each middleware component decides whether to act on a request as it passes along the pipeline. For this, each middleware component has to repeat the same set of steps as the request works its way along the pipeline.

### Adding the Routing Middleware and Defining an Endpoint

Note the routing middleware is added using two separate method – `UseRouting`and `UseEndpoints`. Note that the `UseRouting`adds the middleware responsible for processing requests to the pipeline. And the `UseEndpoints`is used to define the routes match URLs to endpoints.

```cs
app.UseRouting();
app.UseEndpoints(endpoints=> {
    endpoints.MapGet("routing", async context => {
        await context.Response.WriteAsync("Request was routed");
    });
});
```

For the `UseEndpoints`, receives a func that accepts an `IEndpointRouteBuilder`obj and uses it to create routes using the extension methods like:

- `MapGet(pattern, endpoint)`– Routes `HTTP GET`
- `MapPost, MapPut, MapDelete, MapMethods(pattern, methods, endpoint)`
- `Map(pattern, endpoint)`– this routes all requests that matches the URL pattern to the endpoint.

So the Endpoints generate response in the same way as the middleware components demonstrated in eariler. They receive an `HttpContext`obj that provides access to the request and response through `HttpRequest`. Can also:

```cs
endpoints.MapGet("capital/uk", new Capital().Invoke);
endpoints.MapGet("population/paris", new Population().Invoke);
```

### Explicitly Specifying Lambda Parameters and Return types

The compiler can usually *infer* the type of lambda parameters contextually, and, when this is not the case, must sepcify the type of each parameter explicitly. FORE:

```cs
void Foo<T>(T x) {}
void Bar<T>(Action<T> a) {}
// need to use
Bar((int x)=> Foo(x));
// from C# 10, can also specify the lambda return type like:
var sqr = int(int x) => x;
```

## Iterating Arrays

```js
let letters = [..."hello world"];
let string = "";
for (let letter of letters) {
    string += letter;
}
letters
```

If want to use a `for/of`loop for an array and need to know the index of each array element, use the `entries()`method of the array, along with **destructing** assignment like this – 

```js
let everyother = '';
for (let [index, letter] of [...'hello world'].entries()) {
    if (index % 2 == 0) everyother += letter;
}
everyother
```

Another good to iterate array is with `forEach()` – not a new of the `for`loop, but an array method that offers a functional approach to array iteration. Like:

```js
let uppercase = "";
[..."Hello, World"].forEach(l => {
    uppercase += l.toUpperCase();
});
uppercase
```

Can also loop through the elements of an array with a good old-fashioned `for`., like:

```js
const letters = [..."hello world"];
let vowels = '';
for (let i = 0; i < letters.length; i++){
    let letter = letters[i];
    if (/[aeiou]/.test(letter)) {
        vowels += letter;
    }
}
vowels  // eoo
```

### `map()`method

The `map()`passes each element of the array on which it is invoked to the function you specify and returns an array containing the values returned by your function. like:

```js
let data = [...new Array(5).keys()].map(x => x + 1);
data = data.map(x => x * x);
data
```

### `filter()`method

Containing a subset of the elements of the array on which it is invoked. like:

```js
let data = [...new Array(5).keys()].map(x => x + 1).reverse();
data.filter(x => x < 3)
data.filter((x, i) => i % 2 == 0)
```

### `find()`and `findIndex()`

These two stop iterating the first time the predicate finds an element. When that happens, `find()`returns the matching, and `findIndex()`returns the index. if not found, `find()`returns `undefined`and `findIndex()`return `-1`.

`every()`and `some()`-- The `every()`for all, returns `true`if and only if for all elements, and `some()`reverse.

`reduce()`and `reduceRight()`-- combine the elements for an array, using the function you specify, to produce a single value. like:

```js
a.reduce((x,y)=> x+y, 0);
a.reduce((x,y)=>x*y, 1);
a.reduce((x,y)=> x>y ? x:y);
// reduceRight() jsut like this, except it processes the array from highest to lowest.
```

`flatMap()`function just like `flat()`=> `a.map(f).flat()`

`concat()`adding array – 

```js
let a= [1,2,3];
a.concat(4,5)
```

### subarrays with `slice(), splice(), fill()`and `copyWithin()`

`slice()`returns a *slice* – or subarray. like:

```js
let a = [1,2,3,4,5];
a.slice(0,3); // [1,2,3]
a.slice(3); // [4,5]
a.slice(1,-1); // 2,3,4, -1 specifies the last pos.. -2, before last
```

`splice()`is just a general-purpose for inserting or removing from an array. `splice()`modifies the array on which it is invoked. `splice()`can delete elements .. perform both operations at the same time.

1st parameter – pos at which the insertion and/or deletion is to begin; 2nd – number of elements should be deleted from. If second omitted, all array elements from the start element to the end of the array are removed. note that it returns an array of the deleted element. like:

```js
let a = Array.from(new Array(8).keys()).map(x => x + 1);
let b = a.splice(4);
[a, b]
```

So the first two to `splice()`specify which array elements are to be deleted. And the first two just specify which array elements are to be deleted. May be followed by any number of additional args that specify elements to be inserted into the array – starting at the position specified by the first argument like:

```js
let a = [1, 2, 3, 4, 5];
a.splice(2, 0, "a", "b") // => []
a.splice(2, 2, [1, 2], 3) // [1,2,[1,2],3,3,4,5]
```

`fill()`method sets the elements of an array, or a slice of an array, to a specified value, mutates the array it is called on, and also returns the modified array like:

```js
let a = new Array(5);
a.fill(0); // => [0,0,0,0,0]
a.fill(9,1); // fill 9 starting with 1
```

`copyWithin()`copies a slice of an array to a new position within the array. Modifies the array in palce and returns the modified array, will not change the length of the array. first is dest index, second is to be copied, 3rd end of the slice…

### Array Searching and Sorting Methods

`indexOf(), lastIndexOf(), includes()`.

`sort((s,t)=> s-t)`

### Array to string

```js
a.join()  // using ,
a.join('')
let b= new array(10);
b.join('-')
```

### static functions

Array.isArray() fore.

## Array-like Objects

Js has some special features that other objects do not have – 

- `lenght`prop is automaitcally updated
- Setting length to smaller truncates the array
- Arrays inherit useful methods from `Array.prototype`.

It is often perfectly reasonable to treat any object with a numeric `length`prop and corresponding non-negative integer properties as a kind of array.

```js
function isArrayLike(o) {
    if (o &&
       typeof o === 'object' &&
       Number.isFinite(o.length) &&
       o.length>=0 &&
       Number.IsInteger(o.length) &&
        o.length<4294967295) {
        return true;
    }
    return false;
}
```

So, most js array methods are purposely defined to be generic so that they work correctly when applied to array-like objects in addition to true arrays. Since array-like do not inherit from `Array.prototype`, cannot invoke any methods on them directly – but can invoke indirectly using the `Function.call()`method like:

```js
let a = { "0": "a", "1": "b", "2": "c", length: 3 };
Array.prototype.join.call(a, '+');
Array.prototype.map.call(a, x => x.toUpperCase());
Array.prototype.slice.call(a, 0); // easier array copy just
Array.from(a)  // [a, b, c]
```

### Strings as Arrays

Js strings behave like read-only arrays of UTF-16 Unicode characters. LIke:

```js
Array.from("JavaScript");
Array.prototype.join.call("JavaScript", "-")
```

### Method Invocation

A *method* is nothing more than a Js function that is stored in a property of an object – fore:

```js
let calculator = {
    operand1: 1,
    operand2: 2,
    add() {
        this.result = this.operand1 + this.operand2;
    }
};
calculator.add();
calculator.result;
```

Methods and the `this`keyword are central to the OOP. Any function that is used as a method is effectively passed an implicit arg – the object through which it is invoked. Typically, a method performs some sort of operation on that object, and the method-invocation syntax is an elegant way to express the fact that a function is operating on an object.

The `this`is not scoped the way variables are, except for arrow func. nested func do not inherit the `this`of the containing func. If a nested func is invoked as a function – then its `this`either global (non-strict), or `undefined`. fore:

```js
let o = {
    m: function () {
        let self = this;
        this === o; // true
        f();

        function f() {
            console.log(this === o); // false
            console.log(self === o); // true, self is the outer "this" value
        }
    }
}
o.m();
```

So, inside the function `f()`, the `this`is not equal to the object o. So in ES6 and later, canuse arrow func. or using the `bind()`method. like:

```js
const f = (function() {
    this===o // true
}).bind(this);
```

### CTOR invocation

In js, if a function or method invocation is preceded by the keyword `new`,then is CTOR invocation. Ctor invoctions differ from regular and method in their handling of arguments. invocation context, and return value.

A ctor invocation creates a new, empty obj that just inherits from the object specified by the `prototype`property of the ctor.

### Indirect Invocation

Js functions are objects, like all other objects in Js. `call()`and `apply()`methods – `apply()`expects an array of values to be used as arguments.

## Cascade, specificity, and inheritance

CSS provides a deceptively simple declaractive syntax – if worked with it on any other projects, grow into unwieldy complexity.
