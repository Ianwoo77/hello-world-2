# First Go App

`go.mod`file which is used to keep track of the packages a project depends on and can also be used to publish the project...

`main`which is the *entry point* for the application. 

## Defining a Data Type and a Collection

```go
type Rsvp struct {
	Name, Email, Phone string
	WillAttend         bool
}

var responses = make([]*Rsvp, 0, 10)
```

Specified zero for the size argument an empty slice. `[]`denote a slice, `*`denotes a pointer. The `Rsvp`part of the type denotes the struct type defined. The use of pointers in Go determines only whether a value is copied when it is used.

```html
<body>
{{block "body" .}} Content Goes here {{end}}
</body>
```

This will be .. double {{ and }} used to insert dynamic content into the output produced by the template. The `block`expression used here defines placeholder content that will be replaced by another template at runtime.And to create the template that will allow the user to give, form.html:

```html
form-group used mb-3
```

## Loading the Templates

# Advanced C#

A delegate instance literally acts as a delegate for the caller. The

`Transformer t= Square;` ==>

`Transformer t = new Transformer(Square)`
`t(3)`==> `t.Invoke(3)`

```c#
int[] values = { 1, 2, 3 };
Transform(values, Square);
foreach(int i in values){
	Console.WriteLine(i);
}
values.ToList().ForEach(Console.WriteLine);

void Transform(int[] values, Transformer t)
{
	for (int i = 0; i < values.Length; i++)
		values[i] = t(values[i]);
}

int Square(int x) => x * x;
int Cube(int x) => x * x * x;

delegate int Transformer(int x);
```

`Transform`is a *higher-order* function cuz it's a func that takes a func as an arg.

## Instance and Static Targets

```C#
// for static
Transformer t= Test.Square;
class Test {public static int Square(int x)=> x*x;}
delegate int Transformer(int x);
```

Just note,, for instance... maintains a reference not only to the method but also to the *instance*.

## Multicast Delegates

All have *multicast* capability. like:

```c#
SomeDelegate d= SomeMethod1;
d+= SomeMethod2;

ProgressReporter p = pc => Console.WriteLine(pc);
p += pc => System.IO.File.AppendAllText("progress.txt", pc.ToString()+"\n");
Util.HardWork(p);

public delegate void ProgressReporter(int pc);
public class Util
{
    public static void HardWork(ProgressReporter p)
    {
        for(int i = 0; i < 10; i++)
        {
            p(i*10);
            System.Threading.Thread.Sleep(100);
        }
    }
}
```

## Generic Delegate Types

Can contain generic type parameters like:

```C#
public delegate T Transform<T> (T arg);
//........
int[] values = { 1, 2, 3 };
Util.Transform(values, Square);
values.ToList().ForEach(Console.WriteLine);

int Square(int x) => x * x;
public class Util
{
    public static void Transform<T>(T[]values, Transformer<T> t)
    {
        for (int i=0; i<values.Length; i++)
        {
            values[i] = t(values[i]);
        }
    }
}

public delegate T Transformer<T>(T arg);
```

## The `Func`and `Action`

`Func`and `Action`, defined in the `System` like:

```c#
delegate TResult Func<out TResult>();
delegate TResult Func<in T, out TResult>(T arg);
//...
delegate void Action();
delegate void Action<in T>(T arg);
//...
```

So Can:

```cs
static void Transform<T>(T[] values, Func<T, T> transformer)
{
    for (int x = 0; x < values.Length; x++)
    {
        values[x] = transformer(values[x]);
    }
}
```

## Delegates vs interfaces

fore:

```cs
public interface ITransformer{
    int Transform(int x);
}
class Squarer: ITransformer{
    public int Transform(int x)=> x*x;
}
public class Util {
    public static void TransformAll(int[] values, ITransformer t){
        for(int i=0; i<values.Length; i++){
            values[i]=t.Transform(values[i]);
        }
    }
}
```

For this, a delegate design might be a better choice -- 

* The interface for this defines only a single method.
* Multicast capability is needed
* The subscriber needs to implement the interface multiple times.

## Delegate Compatibility

Note Delegate types are all **incompatible** with one another.

```C#
D1 d1= Method1;
D2 d2= d1;  // compile-time error
```

Delegate instances are considered equal if they have the same method targets.. And, Multicast delegates are considered equal if they reference the same methods *in the same order*.

## Parameter compatibility

Can supply args that have *more specific* then what asked for. This is ordinary polymorphic behavior.

# Events

When using delegates, two emergent roles commonly appear, *broadcaster* and *subscriber*. broadcaster type that contains a delegate field. The broadcaster decides when to broadcast, by invoking the delegate. The *subscribers* are the method target recipients. A subscriber decides when to start and stop listening by calling += and -=.

And, events are a language feature that formalizes this pattern. NOTE: The main purpose of events is to *prevent subscribers from interfering with one another*. like:

```C#
// Delegate definition
public delegate void PriceChangedHandler(decimal oldPrice,  decimal newPrice);

public class Broadcaster
{
    // Event declaration
    public event PriceChangedHandler PriceChanged;
}
```

Code within the `Broadcaster`type has full access to `PriceChanged`and can just treat it as a delegate.

```cs
// Delegate definition
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
            if (price == value) return;  // exit if nothing changed
            decimal oldPrice = price;
            price = value;
            if (PriceChanged != null) PriceChanged(oldPrice, price);
        }
    }
}
```

## Standard pattern

```cs
public class PriceChangedEventArgs: System.EventArgs{
    public readonly decimal LastPrice;
    public readonly decimal NewPrice;
    
    public PriceChangedEventArgs(decimal lastPrice, decimal newPrice){
        LastPrice=lastPrice;
        NewPrice=newPrice;
    }
}
```

`EventArgs`is a base class for conveying info for an event. When this in place, the next step is to choose or define a delegate for the event -- there are three rules -- 

1. Must have `void`return type
2. must accept two args, `object`and `EventArgs` -- The first indicates the event broadcaster, and the second contains the extra info to convey.
3. Name MUST end with `EventHandler`

`.NET`defines `System.EventHandler<T>`to help with this:

```cs
public delegate void EventHandler<TEventArgs>(object source, TEventArgs e);
```

Then to deine an event of the chosen delegate type -- like:

```cs
Stock s = new Stock("THPW");
s.Price = 27.10M;
// Register with the event
s.PriceChanged += (s, e) =>
{
    if ((e.NewPrice - e.LastPrice) / e.LastPrice > 0.1M)
        Console.WriteLine("Alert, 10% increase!");
};
s.Price = 31.59m;

public class PriceChangedEventArgs : EventArgs
{
    public readonly decimal LastPrice;
    public readonly decimal NewPrice;

    public PriceChangedEventArgs(decimal lastPrice, decimal newPrice)
    {
        LastPrice = lastPrice;
        NewPrice = newPrice;
    }
}

public class Stock
{
    string symbol;
    decimal price;

    public Stock(string symbol) => this.symbol = symbol;

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
            if (price == value) return;  // exit if nothing changed
            decimal oldPrice = price;
            price = value;
            OnPriceChanged(new PriceChangedEventArgs(oldPrice, price));
        }
    }
}
```

Note that, the predefined non-generic `EventHandler`delegate can be used when an event doesn't carry extra info.

```cs
public class Stock {
    //...
    public event EventHandler PriceChanged;
    protected virtual void OnPriceChanged(EventArgs e) {
        PriceChanged?.Invoke(this, e);
    }
    
    public decimal Price{
        get {return price;}
        set {
            //...
            OnPriceChanged(EventArgs.Empty);
        }
    }
}
```

From C# 10, can also specify the lambda return type like:

```cs
var sqr = int (int x) => x;
```

Note, specifying a return tyupe can improve compiler performance with complex nested lambdas.

# Adding a Data Model

The convention for an ASP.NET core app is that the data model classes are defined in a folder Models.

```cs
namespace PartyInvites.Models
{
    public class GuestResponse
    {
        public string? Name { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public bool? WillAttend { get; set; }
    }
}

```

Noticed that all the properties defined are *nullable*.

Then create a Second -- like: The `asp-for`attribute on the `label`element sets the value of the `for`attribute. Handling `GET`and `POST`request in separate C# methods helps to keep controller code tidy since the two have different responsibilities.

## Understanding Model Binding

A useful Core feature whereby incoming data is parsed and the k/v pairs in the HTTP request are used to populate props of domain model types. The `GuestResponse`object that is passed as the parameter with individual data values sent by the browser. The `GuestResponse`object that is passed as the parameter t othe action method is automatically populated with the data from the form fields.

```cs
namespace PartyInvites.Models
{
	public class DataContext:DbContext
	{
        public DataContext(DbContextOptions<DataContext> options):base(options) { }

		public DbSet<GuestResponse> Responses { get; set; }
    }
}
```

EF core is able to store instances of regular C# classes.

```sh
Install-Package Microsoft.EntityFrameworkCore.Tools
Install-Package Microsoft.EntityFrameworkCore.Design
Install-Package Microsoft.EntityFrameworkCore.SqlServer
```

## Understanding Top-Level Statements

Top-level statements are intended to remove unnecessary code structure from class files.

C# version 10 introduces global `using`. When null state analysis is enabled, C# variables are divided into two groups, nullable and non-nullable. For `string?`can be assigned string value or null. The null-forgiving operator can be used to tell the compiler that a variable isn't `null`. Regardless of what the null state analysis suggests.

## Using String Interpolation

C# supports string interpolation to create formatted strings, which uses templates with variable names that . prefixed with the $ character and contain holes. {}. And the syntax for initializaing this type of collection relies . like

```cs
Dictionary<string, Product> products = new Dictionary<string, Product> {
    ["kayak"]=new Product{Name=..., Pirce=...M},...
}
```

## Pattern Matching

```cs
public IActionResult Index() {
    //...
    for (int i=0; i<data.Length; i++) {
        if(data[i] is decimal d) {
            total+=d;
        }
    }
}
```

The `is`keyword performs a type check and, if a value is of the specified type, will assign the value to a new var.

# Testing ASP.NET core Applications

For core apps, generally create a separate VS project to hold the unit tests, each of which is defined as a method in a C# class.

```cs
namespace SimpleApp.Tests
{
    public class ProductTests
    {
        [Fact]
        public void CanChangeProductName()
        {
            // Arrange
            var p = new Product { Name = "Test", Price = 100M };

            // Act
            p.Name = "New Name";

            // Assert
            Assert.Equal("New Name", p.Name);
        }

        [Fact]
        public void CanChangeProductPrice()
        {
            // Arrange
            var p = new Product { Name = "Test", Price = 100M };

            // Act
            p.Price = 200M;

            // Assert
            Assert.Equal(100M, p.Price);
        }
    }
}

```

Arraynge, Act, Assert (A/A/A)

Js' fundamental *Object type is an unordered collection of properties*.

## The `typeof`Operator

`typeof`is a unary operator that is placed before its single operand. like:

```js
// if the value is a string
(typeof value === 'string')?"'"+value+"'":value.toString();
```

`delete`is a unary attempts to delete the *object property* or *array element* like: `delete a[2];` -- the resulting array is *sparse*.

The `yield`is much like the `return`.. like:

Prototypes -- Each constructor function internally manages a *prototype*, an object that serves as the basis for the objects to be created via ctor function., either through the `__proto__`property or `Object.getPrototypeOf()`method.

Since ECMAScript 5, there is the possibility to create objects via `Object.create()`helper method.

Important Declarations -- There is an exception to the style origin rules, declarations that are marked as *important* like:

```css
color: red !important;
```

Declaations marked `!important`are treated as a higher-priority origin. ID > Class > Tags, And if U make the two conflicting selectors equal ..

Shorthand properties -- are properties that let set the values of several other properties at one time.
