# Using Function Types

- Functions in Go have a data type, describes the combination of parameters the function consumes and the results the function produces.
- Can be assigned to variables and that one function can be subituted for another.
- Function types are defined using the `func`, followed by a signature that describes the parameters and results.
- Advanced uses of function types can become difficult to understand and debug.

## Understanding Function types

Functions have a data type in Go, means they can be assigned to variables and used as function parameters. FORE:

```go
func calcWithTax(price float64) float64 {
	return price + (price * 0.2)
}

func calcWithoutTax(price float64) float64 {
	return price
}

func main() {
	products := map[string]float64{
		"kayak":      275,
		"lifejacket": 48.95,
	}

	for product, price := range products {
		var calcFunc func(float64) float64
		if price > 100 {
			calcFunc = calcWithTax
		} else {
			calcFunc = calcWithoutTax
		}
		totalPrice := calcFunc(price)
		fmt.Println("Product:", product, "price:", totalPrice)
	}
}

```

Specified with the `func`keyword :

`var calcFunc func(float64) float64` known as the *function signature*. And the `calcFunc`variable defined can be assigned any value that matches its type, which means any function has the right number of type of args and results.

### Understanding Function Comparsions and Zero Type

The Go comparsion operators cannot be used to compare functions -- just can be used to determine whether a func has been assigned to a variable.

`calcFunc==nil`

### Functions as Args

Can be used in the same way as any other type, including as args for other functions like:

```go
func printPrice(product string, price float64, calculator func(float64) float64) {
	fmt.Println("Product", product, "Price", calculator(price))
}

func main() {
	products := map[string]float64{
		"kayak":      275,
		"lifejacket": 48.95,
	}

	for product, price := range products {
		if price > 100 {
			printPrice(product, price, calcWithTax)
		} else {
			printPrice(product, price, calcWithoutTax)
		}
	}
}
```

Note that within the function, the `calculator`parameter is used just like any other function.

### Using as Results

Can also be results, meaning that the value returned by a func is another func.

```go
func selectCalculator(price float64) func(float64) float64 {
	if price > 100 {
		return calcWithTax
	} else {
		return calcWithoutTax
	}
}

func main() {
	products := map[string]float64{
		"kayak":      275,
		"lifejacket": 48.95,
	}

	for product, price := range products {
		printPrice(product, price, selectCalculator(price))
	}
}
```

### Creating Function Type Aliases

Go supports type aliases, which can be used to assign a name to a function signature so that the parameter and result types are not specified every time the function type is used. Like:

```go
type calcFunc func(float64) float64
func printPirce(product string, price float64, calculator calcFunc) {}
```

### Using the Literal syntax

```go
func selectCalculator(price float64) calcFunc {
	if price>100 {
		var withTax calcFunc = func(price float64) float64 {
			return price + (price*.2)
		}
		return withTax
	}
	withoutTax := func(price float64) float64 {
		return price
	}
	return withoutTax
}

type calcFunc func(float64) float64
```

The literal syntax just creates a function that can be used like any other value, including assignment the func to a variable, which is have done.

### Understanding Function variable Scope

So, functions are treated as any other value. Fore:

```go
if price > 100 {
    var withTax calcFunc= func(price float64) float64 {
        return price * (price*.2)
    }else if price < 10{
        return withTax // compile error
    }
}
```

### Using Function values directly

Like:

```go
if price > 100 {
    return func(price float64) float64 {
        return price+ price*.2
    }
}
return func(price float64) float64 {...}
```

### Understanding Function Closure

Functions defined using the literal syntax can reference variables from the surrounding code, a feature known as *closure* -- this can be difficult to understand -- like:

```go
func main() {
	watersportsProducts := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}
	soccerProducts := map[string]float64{
		"Soccer Ball": 19.50,
		"Stadium":     79500,
	}

	calc := func(price float64) float64 {
		if price > 100 {
			return price + price*.2
		}
		return price
	}

	for product, price := range watersportsProducts {
		printPrice(product, price, calc)
	}

	calc = func(price float64) float64 {
		if price > 50 {
			return price + price*.1
		}
		return price
	}
	for product, price := range soccerProducts {
		printPrice(product, price, calc)
	}
}
```

But, there is a high degree of duplication -- and if there is a change in the way that prices are calcualted, have to remember to update the calcuator function for each category. Can:

```go
func priceCalcFactory(threshold, rate float64) calcFunc {
	return func(price float64) float64 {
		if price > threshold {
			return price + price*rate
		}
		return price
	}
}
func main(){
    waterCalc := priceCalcFactory(100, 0.2)
	soccerCalc := priceCalcFactory(50, 0.1)
	for product, price := range watersportsProducts {
		printPrice(product, price, waterCalc)
	}
	for product, price := range soccerProducts {
		printPrice(product, price, soccerCalc)
	}
}
```

### Understanding Closure Evaluation

The variables on which a function closure are evaluated each time the function is invoked. FORE:

```go
var prizeGiveaway= false
func priceCalcFactory(threshold, rate float64) calcFunc {
    return func(price float64) float64 {
        if prizeGiveaway {
            return 0
        }else if (price> threshold){
            return price + price*rate
        }
        return price
    }
}
// in the main()
prizeGiveaway = false
waterCalc := priceCalcFactory(100, .2)  // all 0
prizeGiveaway = true
soccerCalc := priceCalcFactory(50, .1)  // all 0 so, logic error!!!
```

### Forcing Early Evaluation

If want to use the value that was current when the function was created like:

```go
func priceCalcFactory(threshold, rate float64) calcFunc {
    // is set when the factory is invoked
    // ensure taht the calculator won't be affected if the 
    // global value is changed
    fixedPrizeGiveaway := prizeGiveaway
    //...
}
```

The same effect can be done by using the paramter like:

```go
func priceCalcFactory(threshold, rate float64, zeroPrices bool) calcFunc {}
// ...
waterCalc := priceCalcFactory(100, 0.2, prizeGiveaway)
```

### Closing on a Pointer to prevent early Evaluation

Most problem with closure are caused by changes made to variables after a function has been created. But on occasion, may find encounter the contary issue -- which is need to avoid early evaluation to ensure that the current value is used by a function. In these situation, just using a pointer will prevent values from being copied.

```go
func prizeCalcFactory(threshold, rate float64, zeroPrices *bool) calcFunc{
    return func(price float64) float64 {
        if(*zeroPrice){
            return 0
        }else if price> threshold {
            return...
        }
        return price
    }
} // using this just cauze prevent early evaluation
```

# Defining Structs

The `type`and `struct`keywords are just used to define a type, allowing filed names and types to be specified.

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}

	kayak := Product{
		name:     "Kayak",
		category: "Watersports",
		price:    275,
	}
	fmt.Println(kayak.name, kayak.category, kayak.price)
	kayak.price = 300
	fmt.Println(kayak)
}
```

Custom data types are known as *struct* -- Values **do not have to** be provided for all fields when creating a struct value. No initial value is just provided assigned 0.

### Defining Embedded Fields

If a field is defined without a name, just is known as an *embedded* field -- as:

```go
type SocketLevel struct {
    Product
    count int
}

sockItem := SocketLevel{
    Product: Product{"kayak", "watersports", 275.00},
    count:   100,
}

fmt.Println("Name:", sockItem.Product.name)
fmt.Println("count:", sockItem.count)
```

Note, embedded fields are accessed using the name of the field type for this example, As noted, field names must be unique with the struct type -- which means that you can define only one embedded for a special type. And if needs to define two fields of the same type, will need to assign a name to one of them. Like:

```go
type StockLevel struct {
    Product
    Alternate Product
    count int
}

stockItem := StockLevel {
    Product: Product {"Kayak", "Watersports", 275.00},
    Alternate : Product {...},
    count: 100,
}
```

### Comparing Struct Values

Are comparable if all their fields can be compared. And, structs cannot be compared if the struct type defines fields with incomparable types. FORE, slices. -- Invliad operation.

### Converting between Struct types

Can be converted into any other struct type that has the same fields. Meaning all the fields have the same name and type and are defined in the same order. FORE:

```go
type Item struct {
    name     string
    category string
    price    float64
}

prod := Product{"kayak", "watersports", 275.00}
item := Item{"kayak", "watersports", 275.00}

fmt.Println("prod==item:", prod == Product(item)) // true
```

### Defining Anonymous Struct types

Are defined without using a name like:

```go
func writeName(val struct {
	name, category string
	price          float64
}) {
	fmt.Println("Name:", val.name)
}
```

Don’t find this useful, but can do like this:

```go
prod := Product{"kayak", "watersports", 275.00}

var builder strings.Builder
json.NewEncoder(&builder).Encode(struct {
    ProductName  string
    ProductPrice float64
}{
    ProductName:  prod.name,
    ProductPrice: prod.price,
})
fmt.Println(builder.String())
```

### Creating Arrays, Slices, and Maps containing struct values

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}

	type SocketLevel struct {
		Product
		Alternate Product
		count     int
	}

	type Item struct {
		name     string
		category string
		price    float64
	}

	array := [1]SocketLevel{
		{
			Product:   Product{"kayak", "watersports", 275.00},
			Alternate: Product{"Lifejacket", "Watersports", 48.95},
			count:     100,
		},
	}
	fmt.Println("Array:", array[0].name) // Product.name

	slice := []SocketLevel{
		{
			Product:   Product{"Kayak", "Watersports", 275.00},
			Alternate: Product{"Lifejacket", "Watersports", 48.95},
			count:     100,
		},
	}

	fmt.Println("Slice:", slice[0].Alternate.name)

	kvp := map[string]SocketLevel{
		"kayak": {
			Product:   Product{"Kayak", "Watersports", 257.00},
			Alternate: Product{"Lifejacket", "Watersports", 48.95},
			count:     100,
		},
	}
	fmt.Println(kvp)
}
```

### Understanding Structs and Pointers

Assigning struct to a new variable or using a struct as a function parameter creates a new value that **copies** the field values as demonstrated:

```go
func main(){
    p1 := Product {"kayak", "water", 275}
    p2 : = p1
    p1.name= "Orig kayak"
    p2 // kayak
}
```

And using pointers like:

```go
p2 := &p1
p1.name = "Oirg kayak"
(*p2).name // orig kayak
```

## File permission with `umask`

When create file, 666, directories has 777. Can view and modify the default permissions for either with `umask`, which works like a filter.

Changing File permission with `chown`--- like:

```sh
chown matthew filename
```

Note always sudo like:

```sh
sudo su
```

### How to create soft link within command

To make links -- a symbolic link consists of a special type of file that serves as a reference to another file or directory.

- symbol links -- soft links or *symlinks* -- refer to a symbolic path indicating the abstract location of another file
- hard links -- refer to the specific location of physical data

```sh
ln -s file1 link1
```

### Creating symlink to a directory

The syntax remains same like:

```sh
ln -s {source-dir-name} {symnbolic-dir-name}
```

`-f`to the ln command to overwrite links like:

```sh
ln -f -s /path/to/file.txt link.txt
```

remove -- `rm`or `unlink`

## Hard Links

The concept of that -- need to note every file on the Linux filesystem starts with a single hard link -- The *link* is between the filename and the actual data stored on the filesystem.

Creating an additional hard link to a file means a few different things.

1. Creating a new filename pointing to the exact same data as the old file name. though different, point to identical data.

```sh
md5sum *.jpg | grep ... | cut -c35-
```

```sh
printenv HOME .. {USER}
```

When the shell evaluates a variable, it replaces the variable name with its value like: Simply, `$`, `$HOME`just `/home/ian`. like: `echo`command simply prints its arguments like:

```sh
echo ch*9
echo My name is $USER and my files are in $HOME
```

where come from -- Variables like `USER`and `HOME`just predefined by the shell. just:

`name=value` define or modify a variable anytime by assigning it a value using this syntax.

```sh
work=$HOME/postman
ls $work
# can supply to any command that expects a directory
cp myfile $work
ls $work
```

### Variables and Superstition

For `echo`, knows nothing about variables, it just prints whatever arguments you hand it. What’s really happening is that the shell evaluates `$HOME`before running the `echo`command. Especially as delve into more complicated commands.

### Patterns vs variables

```sh
FILES="Lizard.txt snake.txt"
mv mammals/$FILES reptiles
```

This uses variables, which just evaluate to their literal value only. Have no special handling for file paths. To just make this work -- use a `for`loop -- like:

```sh
FILES="lizard.txt snake.txt"
for f in $FIELS; do
	mv mammals/$f reptiles
done
```

### Shortening Commands with Aliases

A variable is a name that stands in for a value. The shell also has names that stand in for commands. just like:

```sh
alias g=grep
alias ll= "ls -l"
```

Can define an alias that has the just same name as an existing command, effectively replacing that command in the shell. like:

```sh
alias less="less -c"
# delete alias
unalias ll
```

### Redirecting Input and output

Fore, the pipe syntax `|`is a feature of the shell. Another is redirecting stdout to a file. If use `grep`to print matching lines from the `animals.txt` like:

```sh
grep 'Perl' animals.txt > outfile
```

Have redirected stdout to the file instead of the display. If exist, just overwrite that. If append to the outfile rather overwrite, just using `>>`symbol like:

```sh
echo there was just >> outfile
```

And, many commands that accept filenames as arguments. like:

```sh
wc animals
wc < animals
```

For this *very important* to understand how work -- 

- `wc animals`just receives filename as arg
- 2nd command, `wc`is invoked with no arg -- **so reads from stdin**. redirects stdin to come from stdin -- which is usually the keyboard -- the shell sneakily redirects stdin to come from *animals.txt* instead. Can:

```sh
wc < animals.txt > count
cat count
```

Can even use pipes at the same time -- `grep`reads from redirected stdin and pipes the result to `wc`.

```sh
grep 'Perl' < animals.txt | wc > count
```

Note, single quote tell to treat every in a string literally, and double tell the shell to treat all literally except for certain dollar signs like:

Backslashes act as escape within double, not in single.

And, final backslashes are great for making pipelines more readable. like:

`cut -f1 grades \`
    `| sort \`
    `| uniq -c \`

### Capturing Outer Variables

A Lambda can reference any variables that are accessible where the lambda expression is defined. These are called *outer variables*. like:

```cs
int factor = 2;
Func<int, int> multiplier= n=> n*factor;
```

Outer variables referenced by a lambda expression are called *cpatured variables*.  Just note that Captured are evaluated when the **delegate** is actually *invoked*. not when were catptured.

```cs
//..
factor =10;
Console.WriteLine(multipler(3)); // 30
```

So, for this, a local variable instantiated within a lambda is unique per invocation of the delegate instance. like:

```cs
static Func<int> Natural(){
    return ()=> {int seed= 0; return seed++;}
}
```

### static Lambdas

In some situations where performance is critical – one micro-optimizaiton is to minimize the load on the garbage collector by ensuring that code hot paths incur few or no allocations.

From 9, can ensure that a lambda expression, local function, or anonymous method doesn’t capture state. like:

`Func<int, int> multiplier = static n => n*2;`

if:

```cs
int factor =2;
Func<int, int> multiplier = static n => n*factor; // error
```

### Capturing iteration variables

When capture the iteration via a `for`, treats that variable as though it were declared *outside* the loop. So need:

```cs
Action[] actions = new Action[3];
for(int i=0; i<3; i++) {
    int loopScopedi = i;
    actions[i]=> Console.WriteLine(loopScopei);
}
```

### Anonymous Methods

Just like:

```cs
Transformer sqr = delegate (int x) {return x*x};
```

## `try`and exceptions

Can specify an exception filter in a `catch`clause by adding a `when`clause like:

```cs
catch(WebException ex) when (ex.Status == WebExceptionStatus.Timeout) {//...}
```

### The `finally`block

Always executes – regardless of whether is thrown. Like:

```cs
void ReadFile(){
    StreamReader reader = null;
    try {
        reader = File.OpenText("file.txt");
        if(reader.EndOfStream) return;
        Console.WriteLine(reader.ReadToEnd());
    }finally {
        if(reader!=null) reader.Dispose();
    }
}
```

### The `using`statement

Many encapsulate unmanged resouces – implement `System.IDisposable`interface. The `using`just provides an elegant syntax for calling `Dispose()`on `IDisposable`object within a `finaly`block.

```cs
using(Stream reader = File.OpenText("file.txt")) {...}
```

using declarations -  if omit the brackets and statement block following a using from C# 8 - become *using declaration*. The resource is then disposed when execution falls outside the *enclosing* statement block like:

```cs
if(File.Exists("file.txt")) {
    using var reader = File.OpenText("file.txt");
    Console.WriteLine(...)
}
```

### throw expressions

`throw`can also appar as an expression – like:

`public string Foo() => throw new NotImplementedException();`

Can capture and rethrow an exception as follows – :

```cs
try{...}
catch(Exception e) {
    //...
    throw;  // rethrow same exception
}
```

Rethrowing in this manner lets you **log** an error without *swallowing* that.

### Key properties of `System.Exception`

- `StackTrace`– a `string`representing all the methods that are called from the origin of the exception to the `catch`
- `Message`– description
- `InnerException`– Inner exception caused the outer exception.

### The `TryXXX`pattern 

like:

```cs
public int Parse(string output);
public bool TryParse(string input, out int returnValue);
```

For these, `Parse`throws, `TryParse`returns `false`. Can implement these like:

```cs
public return_type XXX(input_type input) {
    return_type returnValue;
    if(!TryXXX(input, out returnValue))
        throw new YYYException(...);
    return returnValue;
}
```

## Enumeration and Iterators

For an *enumerator* is read-only, forward-only cursor over a sequence of values.

- `MoveNext()`and `Current`
- or, implements `System.Collections.Generic.IEnumerator<T>`
- or, implements `System.Collections.IEnumerator`

And, from C# 9, can bind to an **extension method** just named `GetEnumator()`

The `foreach`iterates over an *enumerable* object. Enumerable is not a cursor, but produces cursors over itself. In a low-level just like:

```cs
using(var enumerator = "beer".GetEnumerator()){
    while(enumerator.MoveNext()){
        var elem= enumerator.Current;
        Console.WriteLine(elem);
    }
}
```

### Collection Initializers

```cs
List<int> list = new List<int> {1,2,3};
var dict = new Dictionary<int, string>() {
    {5, "five"},
    {10, "ten"},
};
// or
var dict = new Dictionary<int, string>() {
    [3]="five",
    [10]="ten",
};
```

### Iterators

```cs
IEnumerable<int> Fibs(int fibCount)
{
	for (int i = 0, prevFib = 1, curFib = 1; i < fibCount; i++)
	{
		yield return prevFib;
		int newFib = prevFib + curFib;
		prevFib = curFib;
		curFib = newFib;
	}
}

Fibs(6).Dump();
```

An iterator has different semantics, depending on whether it returns an *enumerable* interface or an *enumerator* interface.

yield break – a `return`is illegal in an iterator block – instead, must use the `yield break`to just indicate iterator block should exit early. like:

```cs
IEnumerable<string> Foo(bool breakEarly) {
    yield return "One";
    if(breakEarly)
        yield break;
    yield return "Three";
}
```

Note, `yield return`cannot appear in a `try`has a `catch`. These are due to comiler must translate iterators into ordinary classes with `MoveNext`. but for only a `finally`, that is legal.

### Operator Lifting

The `Nullable<T>`struct does not define operators such as <, >, ==, but:

```cs
int? x= 5;
int? y= 10;
bool b = x<y; // good
```

Cuz the compiler lifts the operator from the **underlying value type**.

## Nullable Reference Types

Whereas nullable value types bring nullability to the value types, **nullable reference types** do the opposite, when enabled, they bring *non-nullability* to reference types, with the purpose of helping to avoid `NullReferenceExceptions`.

Nullable reference types introduce a level of safety that’s enforced purely by the compiler. In that form of warning when it detects code that’s at risk of generating `NullReferenceException`.

```xml
<PropertyGroup>
	<Nullable>enable</Nullable>
</PropertyGroup>
```

Note, after being enabled, the compiler makes non-nullablity default if you want a reference type to accept nulls without the compiler generating a warning, must apply `?`suffix to indicate a *nullable* reference type.

```cs
#nullable enable
string s1 = null; // warning
string? s2 = null; // ok
```

### The NULL-Forgiving operator

The compiler also warns you upon dereferencing a nullable reference type, if it thinks a `NullReferenceException`might occur. like:

`void Foo(string? s)=> Console.WriteLine(s!.Length);`

## Extension Methods

Extension methods allow an existing type to be extended with new methods without altering the definition. like:

```cs
public static class StringHelper {
    public static bool IsCapitalized(this string s) {
        if(string.IsNullOrEmpty(s)) return false;
        return char.IsUpper(s[0]);
    }
}
```

### Anonymous Types

To create, use the `new`followed by an object initializer like:

`var dude = new {Name="Bob", Age=23};`

Note that the compiler translates this to an internal class.

### Tuples

Simple way to store a set of values. Main purpose of tuples is to safely return multiple values from a method without needing to use the `out`parameters. like:

```cs
var bob = ("bob", 23);
bob.Item1, bob.Item2;

// can specify tuple type like:
(string,int)bob = ("Bob", 23);
```

Can optionally give meaningful names to elements when creating tuple literals.

```cs
var tuple= (name:"Bob", age: 23);
// or:
(string name, int age)GetPerson()=>("Bob", 23);
```

Can also create tuple using `ValueTuple`type like:

```cs
ValueTuple<string,int> bob1 = ValueTuple.Create("Bob", 23);
```

### Deconstructing – 

```cs
var bob = ("Bob", 23);
string name = bob.Item1;
//... can:
(string name, int age) = bob;
var(name, age, sex)= GetBob();
```

As with anonymous types, the `Equals`performs structural equality comparsion. just:

`t1.Equals(t2)`

```cs
public class HomeController : Controller
{
    public IActionResult Index() => View();
}
```

Defining a single action method that selects the default view for rendering.

```html
@{
    Layout = null;
}

<!DOCTYPE html>

<html>
<head>
    <meta name="viewport" content="width=device-width" />
    <title>Party!</title>
</head>

<body>
    <div>
        <div>
            We're going to have an exciting party. <br />
        </div>
    </div>
</body>
</html>
```

### Adding a data model

The model referred to as a *domain model* – Contains C# objects jsut.

` <a asp-action="RsvpForm">RSVP Now</a>`

This attribute is an example of *tag helper* attribute, which is an instruction for Razor.

### Building the form

```html
<body>
    <form asp-action="RsvpForm" method="post">
        <div>
            <label asp-for="Name">Your name:</label>
            <input asp-for="Name" />
        </div>

        <div>
            <label asp-for="Email">Your email:</label>
            <input asp-for="Email" />
        </div>

        <div>
            <label asp-for="Phone">Your phone:</label>
            <input asp-for="Phone" />
        </div>

        <div>
            <label asp-for="WillAttend">Will you attend?</label>
            <select asp-for="WillAttend">
                <option value="">Choose an option</option>
                <option value="true">Yes, I'll be there</option>
                <option value="false">No, I cannot come</option>
            </select>
        </div>
        <button type="submit">Submit RSVP</button>
    </form>
</body>
```

Just note that the `asp-for`on the `input`element sets the `id`and `name`elements. on the `form`, `asp-action`use the application’s URL routing configuration to set the `action`attribute to a URL that wil target a specific action method. 

`<form method="post" action = "/Home/RsvpForm">`

### Receiving the form data

A method that responds to HTTP POST requests – the form element defined – sets the method attribute to post, which cuz the form data to be sent to the server as a POST request.

```cs
[HttpPost]
public IActionResult RsvpForm(GuestResponse response)
{
    // todo... 
    return View();
}
```

### Model Binding

So, given that the action method will be invoked in response to an HTTP request and the `GuestResponse`type – For this, can define a static class like:

```cs
public static class Repository
{
    private static List<GuestResponse> responses = new();
    public static IEnumerable<GuestResponse> Responses => responses;
    public static void AddResponse(GuestResponse res)
    {
        Console.WriteLine(res);
        responses.Add(res);
    }
}
```

```cs
[HttpPost]
public IActionResult RsvpForm(GuestResponse response)
{
    Repository.AddResponse(response);
    return View("Thanks", response);
}
```

```html
<body>
    <div>
        <h1>Thanks, @Model.Name!</h1>
        @if (Model?.WillAttend == true)
        {
            @: It's great that you are coming.
            @: The drinks are already in the fridge!
        }
        else
        {
            @: Sorry to hear that you cannot make it,
            @: but thanks for letting us know.
        }
    </div>
    Click <a asp-action="ListResponse">Here</a> To see who is coming.
</body>
```

### Displaying responses

```html
<body>
    <h2>Here is the list of people attending the party</h2>
    <table>
        <thead>
            <tr><th>Name</th><th>Email</th><th>Phone</th></tr>
        </thead>
        <tbody>
            @foreach (var r in Model)
            {
                <tr>
                    <td>@r.Name</td>
                    <td>@r.Email</td>
                    <td>@r.Phone</td>
                </tr>
            }
        </tbody>
    </table>
</body>
```

### Adding Validation

Can now add dat validation to the application – Users without that could enter nonsense data or even submit an empty form – In an  ASP.NET Core app, validation rules are defined by applying attributes to model classes like:

```cs
public class GuestResponse
{
    [Required(ErrorMessage ="Please Enter your name")]
    public string? Name { get; set; }

    [Required(ErrorMessage ="Please enter your email")]
    [EmailAddress]
    public string? Email { get; set; }

    [Required(ErrorMessage ="Please enter your phone number")]
    //[Phone]
    public string? Phone { get; set; }

    [Required(ErrorMessage ="Specifying whether you will attend")]
    public bool? WillAttend { get; set; }
}
```

Check to see whether there has been a validation problem using the `ModelState.IsValid`property in the action method that receives the form data.

```cs
[HttpPost]
public IActionResult RsvpForm(GuestResponse response)
{
    if (ModelState.IsValid)
    {
        Repository.AddResponse(response);
        return View("Thanks", response);
    }
    else
    {
        return View();
    }
}
```

When it renders a view, Razor has access to the details of any validation errors associated with the request, and tag helpers can access the details to display validation errors to the user. just:

```html
<form asp-action="RsvpForm" method="post">
        <div asp-validation-summary="All"></div>
    <!-- ... -->
```

### Styling the content

Using Bootstrap, a good CSS framework originally by Twitter.

`table class="table table-bordered table-striped table-sm">`

## Testing ASP.NET Core applications

- Creating unit tets projects 
- Writing and running unit tests
- Isolating app components for testing
- Simplifying component isolation with a mocking package

### Creating the app components

```cs
public class Product
{
    public string Name { get; set; } = string.Empty;
    public decimal? Price { get; set; }

    public static Product[] GetProducts()
    {
        Product kayak = new Product
        {
            Name = "Kayak",
            Price = 275M
        };

        Product lifejacket = new Product
        {
            Name = "Lifejacket",
            Price = 48.95M
        };
        return new Product[] { kayak, lifejacket };
    }
}
```

Then, create the controller and view like: Use a just simple controller class to demonstrate different languate features. And the `Index`action just to render the default view and provides it with the `Product`objects obtained from the static methods. Just like:

```html
@model IEnumerable<Product>
@{ Layout = null; }

<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width"/>
    <title>Simple App</title>
</head>
<body>
<ul>
    @foreach (Product p in Model ?? Enumerable.Empty<Product>())
    {
        <li>Name: @p.Name, Price, @p.Price</li>
    }
</ul>
</body>
</html>
```

Then, need to creating the unit test project – For Core applications, generally create a separate project to hold the unit tests, each of which is defined as a method in a C# class. 

`xunit` – This template creates a project configured for the XUNIT framework. 

`mstest, nunit`.. The convention is to name the unit test project like `<ApplicationName>.Tests.` – just like:

```powershell
dotnet new xunit -o simpleApp.Tests --framework net7.0
```

Writing and running unit tests…

## Function Arguments and Parameters

When a func is invoked with fewer args than declared parameters, the additional set to default – which is normally `undefined`. fore:

```js
function getPropertyName(o, a) {
    if (a === undefined) a = [];
    for (let prop in o) a.push(prop);
    return a;
}
```

Instead of using an `if`statement in the first line of this – can use the `||`operator – idiomatic way –

`a = a || []`

And, in the ES6 and later, can define a default value for each of your function parameters directly in the parameter list of function just:

```js
function getPropertyNames(o, a=[]) {}
```

And, it is probably easiest to reason about – fore:

```js
// note, using (), otherwise, {} considered as func body
const rectangle = (width, height = width * 2) => ({ width, height });
console.log(rectangle(1));
```

### Rest parameters and variable-length argument lists

Parameter defaults enable us to write functions that can be invoked with fewer arguments than parameters. just:

```js
function max(first = -Infinity, ...rest) {
    let maxValue = first;
    for (let n of rest) {
        if (n > maxValue)
            maxValue = n;
    }
    return maxValue
}
```

### `Arguments`object

Rest were introduced into js in ES6, before, using `arguments`object to do this like:

```js
function max(x) {
    let maxValue= -Infinity;
    for (let i =0 ; i<arguments.length; i++) 
        if(arguments[i]>maxValue) maxValue=arguments[i];
    return maxValue;
}
```

### The Spread Operator for Function Calls

In js, when use the same `...`in a function definition rather than a invocation – has the opposite effect.

```js
let numbers = [5,2,10,-1];
Math.min(...numbers);
```

### Destructing Function Arguments into Parameters

If define a func parameter names within `[]`, are telling to expect an error value to be passed for each pair of `[]`. As part of process, the array args will be unpacked into the individually named parameters. Like: To easier to understand code:

```js
function vectorAdd([x1, y1], [x2, y2]) {
    return [x1 + x2, y1 + y2];
}
vectorAdd([1, 2], [3, 4]);
```

If R defining that expects an object argument, can destructure object like:

```js
function vectorMultiply({ x, y }, scalar) {
    return { x: x * scalar, y: y * scalar };
}
vectorMultiply({ x: 1, y: 2 }, 100);
```

### Argument types

Js method parameters have no declared types, and no type checking is performed, but, can help make your code self-documenting that. Js performs liberal type conversion as needed – so, will be simply converted to a string when the func tries to use it as a string. But can:

```js
function sum(a) {
    let total = 0;
    for (let elem of a) {
        if (typeof elem != "number") {
            throw new TypeError("Must be numbers");
        }
        total += elem;
    }
    return total;
}

sum([1, 2, 3]);
sum(['a', 1, 2])
```

## Functions as Values

The name of a func is really immaterial. fore:

```js
let s = square;
square(4), s(4);
```

And funcs can also be assigned to object properties rather than variables.

```js
let o = {squlare: function(x){return x*x;}};
let y= o.square(16);
```

### Defining own function properties

Func is a specialized kind of object – which means that funcs can have properties, fore, when need a *static* variable. fore – keep track of the values it has already returned. like:

```js
uniqueInteger.counter = 0;
function uniqueInteger() {
    return uniqueInteger.counter++;
}
uniqueInteger()
uniqueInteger()
uniqueInteger()  // 2
```

```js
function factorial(n) {
    if (Number.isInteger(n) && n > 0) {
        if (!(n in factorial))
            factorial[n] = n * factorial(n - 1);
        return factorial[n];
    }
    else
        return NaN;
}

factorial[1] = 1;  // initialize the cache to hold this base case.
factorial(6);
factorial(4);  // just use caches this value
```

### Namespaces

The code defines only a single global variable, the – if defining even a single property is too much, can define and invoke an anonymous in a singple expression like:

```js
(function() {
    // some statements.
}());
```

## Function Props, Methods, and Ctor

the `typeof`operator will return the string `function`when applied to a function. Since functions in js are objects, can have props, methods – There is even a `Function()`ctor to create new func objects. follow document the `length, prototype -- call(), bind(), toString()`, and `Function()`ctor.

### The length

*arity* of the function – number of parameters in parameterlist. if a rest, not counted.

read-only `name`specifies the name was used when the function is defined. primarily useful when debugging.

Except the arrow function, have a `prototype`that refer to an object known as *prototype object*.

### The `call()`and `apply()`methods

Indirectly invoke a function as if it were a method of some other object. Frist arg is the obj on which the function is to invoked – this arg is the invocation context and becomes the value of the `this`. And `apply()`just the args to be passed to the func are specified as array

`f.apply(o, [1,2])`

`Math.max.apply(Math, [1,-1,0,2,3,5,10,2,3])`

### The `bind()`method

is to *bind* a func to an object. like:

```js
function f(y) { return this.x + y; }
let o = { x: 1 };
let g = f.bind(o);
g(2); // 3
```

And the `toString()`just returns the complete source code for the function.

The `Function()`ctor – like:

`const f = new Function(“x”, “y”, “return x*y;”)`

Classes – In js, classes use prototype-based inheritance. If two inherit propeties from the same prototype, then say that those objects are instances of the same class. If two inherit from the same – this typically means that they were created and initialized by the same CTOR or factory func.

## Classes and Prototypes

A class is a set of objects that inherit properties from the same prototype object. Fore, a *factory function* like:

```js
function range(from, to) {
    let r = Object.create(range.methods);
    r.from = from;
    r.to = to;
    return r;
}

range.methods = {
    includes(x) { return this.from <= x && x <= this.to; },
    *[Symbol.iterator]() {
        for (let x = Math.ceil(this.from); x <= this.to; x++) yield x;
    },
    toString() {
        return "(" + this.from + "..." + this.to + ")";
    }
};

let r = range(1, 3);
r.includes(2); // true
r.toString(); 
[...r];
```

- defined a factory function `range()`for creating new objects.
- using `methods`prop as a convient place to store the prototype object

## Clases and CTORS

Upper demonstrates a simple way to define a Js class – not the idiomatic way. A ctor is a function designed for the initialization of newly created objects. Note that ctor invocations using `new`automatically create the new object – so the CTOR itself only needs to initialize the sate of that new object. This means that all objects created with the same ctor function just inherit from the same object and are therefore members of the same class. In this:

```js
function Range(from, to) {
    this.from = from;
    this.to = to;
}

Range.prototype = {
    // ... like before
}

let r = new Range(1, 3);
[...r];
```

Cuz the `Range()`CTOR is called with `new`– automatically created before the ctor is called. it is accessible as the `this`value. CTORs do not even return the newly created object.

### CTORs Class Identity and `instanceof`

`r instanceof Range // true`

For this, jsut checking whether r inherits from `Range.prototype`

Any regular Js function can be used as a ctor, and ctor invocation need a `prototype`properly – therefore, every regular Js function automatically has a prototyupe property. like:

```js
let F = function(){}; // just regular func
let p = F.prototype;
let c = p.constructor;  // function associated with the prototype
c === F // true
```

Another common technique that are likely to see in older code – 

```js
Range.prototype.includes = function(x) {};
Range.prototype.toString = function() {...};
```

## Cascade, Specificity and Inheritance

With CSS, it’s not always easy to distill the problem down to a single question. The best way to accomplish sth is often **contingent** on your particular constraints.

### The cascade

There are often several ways to accomplish the same thing in CSS. Create an HTML like:

```html
<body>
    <header class="page-header">
        <h1 id="page-title" class="title">Wombat Coffee Roasters</h1>
        <nav>
            <ul id="main-nav" class="nav">
                <li><a href="/">Home</a></li>
                <li><a href="/coffees">Coffees</a></li>
                <li><a href="/brewers">Brewers</a></li>
                <li><a href="/specials" class="featured">Specials</a></li>
            </ul>
        </nav>
    </header>
</body>
```

```css
h1 {
    font-family: serif;
}

#page-title {
    font-family: sans-serif;
}

.title {
    font-family: monospace;
}
```

The *cascade* is the name for this set of rules – it determines how conflicts are resolved. normally, the cascade considers 3 things to resolve the difference – 

1. Stylesheet origin – where the styles comes from
2. Selector Specificity – which Selectors take precedence over which
3. source order – order in which sytles are declared in the stylesheet.

Yours are called *author styles*. There are also user agent styles – lower priority. After the user agent styles are considered, the browser applies your styles – the author styles. Just like:

```css
h1 {
    color: #2f4f4f;
    margin-bottom: 10px;
    /* reduces the margins */
}

#main-nav {
    margin-top: 10px;
    list-style: none;
    /* remove user agent list style */
    
    padding-left: 0;
}

#main-nav li {
    display: inline-block;
    /* makes items appear side by side */
}

#main-nav a {
    color: white;
    background-color: #13a4a4;
    padding: 5px;
    border-radius: 2px;
    text-decoration: none;
}
```

### IMPORTANT Declarations

There is an exception to the style origin rules – declarations that are just marked as *important*.

`color: red !important;`

Declarations marked `!important`are treated as a higher-priority origin – decreasing order –

1. Author important
2. Author
3. User agent

### Specificity

If conflicting can’t be resolved based on their origin – the browser next tries to resolve them by looking at their *specificity*. FORE:

INLINE styles – use HTML `style`attribute to apply styles. like:

```html
<li>
    <a href="/specials" class="featured"
       style="background-color:orange;">
    Specials
    </a>
</li>
```

Selector – FORE, a selector with two class names has a higher specificity than a selector with only one. like:

```css
#main-nav a {
    color: white;
    background-color: #13a4a4;
    /* ... */
}

.featured {
    background-color: orange;
}
```

For this, all the links remain teal.

Note that the different types of selectors also have different specificities.

- More ids, wins
- in a tie, selector with the most classes
- most tag names

For this, the quickest fix is to add an `!important`to the declartion. This raises the declaration to a higher-priority origin. The better way is to :

```css
#main-nav .featured {
    background-color: orange;
}
```

Fore – `.nav a`and `a.featured`both have (0,1,1) priority, Source order determines which wins – so, 2nd wins.

### Link styles and Source Order

like:

`a:link; a:visited; a:hover; a:active`

## Inheritance

The cascade is frequently conflated with the concept of inheritance. Not all props are inherited. In general, these are the props you will *want* to be inherited. like: `color..`

Special Values – there are two special values that you can apply to **any** property to help manipulate the cascade `inherit`and `initial` – 

### `inherit`keyword

Want inheritance to take palce when a cascaded value is preventing it. Can override another value with this. like:

```html
<footer class="footer">
	&copy; 2016
    <a href="/...">Terms of use</a>
</footer>
```

Typically, have a font color for all links on the page. To make that gray just:

```css
a:link {
    color: blue;
}
.footer {
    color: #666;
    background-color: #ccc;
}
.footer a {
    color: inherit;  /* inherit from the footer override the a:link */
}
```

So the 3rd ruleset overrides the blue link color.

### The `initial`keyword

And sometimes you find you have applied to an element that you want to undo. Can do this by specifying `initial`. FORE:

```css
.footer a {
    color: initial; /* black */
}
```

## Shorthand properties

are properties that let you set the values of several other properties at one time. FORE, `font`– style, weight, size, line-height and family and `background`, `border`, and `border-width`

### Beware silently overriding

FORE:

```css
.title {
    font: 32px Helvetica, Arial, sans-serif;
}
```

This means that applying these to <h1> results in a normal font weight.

padding: 1em 2em; ==> padding: 1em 2em 1em 2em

The order is top right bottom left.

### Horizontal and Vertical

Although it seems counter-intutitive – The two values represents a Cartesian grid.

## Git and GitHub Introduction

- Tracking code changes
- Tracking who made changes
- Coding collaboration

Control and track changes with staging and committing – Branch and merge to allow for work on different parts and versions of a project – pull the latest version of the project to a local copy- Push local updates to the main project.

Fore – 

- Initialize on a folder, making it a Repository
- now creates a hidden folder to keep track of changes
- when changed, deleted, considered *modified*
- select the modified want to *stage*
- The *staged* are *committed*, which promots Git to store a *permanent* snapshot of the files.
- Allows you to see the full history of every commit
- Can revert back to any previous commit
- Git does store a separate copy of every file in every commit – keeps track of changs made in each commit.

### Configuring Git

```sh
git config --global user.name "w3schools-test"
git config --global user.email "test@gmail.com"
```

Change the user name and e-mail address – Note that Probably want to use this when registering to Github later on.

Initialize Git – `git init`

```sh
git status
# git staging Environment
git add index.html
git add -all # add all files in the current directory
git commit -m "First release of Hello world" # -m stands for Message
git status --short # check the status of repository
git commit -a -m "..." # -a stands for automatically stage every changed
git log # view the history of commits for a repository
git command -help # see all options for specific ommand
git help --all -- # see all possible commands
```

