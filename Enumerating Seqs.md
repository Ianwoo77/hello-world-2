## Enumerating Seqs

The `for`keyword can be used with the `range`keyword to create loops that enumerate over seqs. like:

```go
func main() {
	product := "Kayak"

	for index, character := range product {
		fmt.Println("Index:", index, "Character:", string(character))
	}
}
```

### Receiving only indices when enumerating

```go
for index := range product {
    fmt.Println("Index:", index)
}
// The blank identifier can be also used when require only values in the seqs and not the indices
for _, character := range product {
    fmt.Println(...)
}
```

### Enumerating Built-in structures

The `range`can also be used with the built-in data structures that Go provides. like:

```go
func main() {
	products := []string{"Kayak", "Lifejacket", "Soccer Ball"}
	for index, element := range products {
		fmt.Println("Index:", index, "Element", element)
	}
}
```

## Using `switch`Statements

`switch`provides an alternative way to control execution flow.

```go
func main() {
	product := "Kayak"

	for index, character := range product {
		switch(character) {
		case 'K':
			fmt.Println("K at position", index)
		case 'y':
			fmt.Println("y at position:", index)
		}
	}
}
```

### Matching Multiple Values

In some languages, `switch`just “fall through” -- which means that once a match is made by a `case`, until a `break`is reached. Go `switch`do not fall through automatically -- but: like:

```go
case 'K', 'k':
    fmt.Println("K or k at position", index)
```

### Terminate `case`Execution

Although the `break`isn’t required to terminiae every `case`-- can be just used to end the execution before end of the `case`statement is reached. like:

```go
case 'K', 'k':
if character=='k' {
    fmt.Println("Lowercase k at position", index)
    break
}
fmt.Println("Uppercase K at position", index)
```

### Forcing Falling through to the next `case`

Go `switch`don’t automatically fall through, here, the `fallthorugh`keyword like:

```go
case 'K':
fmt.Println(...)
fallthrough
case 'k':
```

### Providing a `default`

The `default`is used to define a clause that will be executed when none of the `case`statements matches the `switch`.

```go
default:
fmt.Println("Character", string(character), "at pos:", index)
```

### Using an Initialization statement

`switch`can be defined with an initialization statement like:

```go
for count:=0; count<20; count++ {
    switch(count/2) {
        case 2, 3, 5, 7:
        fmt.Println("prime value:", counter/2)
    default:
        fmt.Println("non-prime value:", counter/2)
    }
}
// also can be 
func main() {
	for counter := 0; counter < 20; counter++ {
		switch val := counter / 2; val {
		case 2, 3, 5, 7:
			fmt.Println("Prime value", val)
		default:
			fmt.Println("non-prime value", val)
		}
	}
}

```

### Omitting a Comparsion Value

Go offers a different approach, whcih omits the comparsion value and uses expressions in the `case`. like:

```go
func main() {
	for counter := 0; counter < 10; counter++ {
		switch {
		case counter == 0:
			fmt.Println("Zero")
		case counter < 3:
			fmt.Println(counter, "is <3")
		case counter >= 3 && counter < 7:
			fmt.Println(counter, "is >=3 && <7")
		default:
			fmt.Println(counter, "is >= 7")
		}
	}
}
```

## Using Label

Label allow to jump to a different point - like:

```go
func main() {
	counter := 0
target:
	fmt.Println("counter", counter)
	counter++
	if counter < 5 {
		goto target
	}
}
```

# Using Arrays, slices, and Maps

- `range`
- `copy`function
- `append`func with ranges that omit the elements to remove
- `for`loop with `range`
- `reflect`package
- explicit conversion to an array type whose length less than or equal to the number of elements in the slice
- Use a `map`
- `delete`function
- Use a `for`loop with the `range`keyword
- Use a string as an array or perform an explicit conversion to the `[]rune`type.
- Using a `for`loop with the `range`keyword
- Perform an explicit conversion to the `[]byte`type and use a `for`loop with the `range`keyword

```go
func main(){
    var names [3]string
    names[0]="Kayak"
    // ...
    fmt.Println(names)
}
```

`var names [3]string`

### Using the Array Literal Syntax

Arrays can be defined and populated in a single statement. like:

`names := [3]string {“kayak”, “Lifejacket”, “paddle”}`

### Array types

Is the combination of its size and underlying type. like:

`var otherArray [4]string= names`

The underlying types of the two arrays in this example are the same, but the compiler will report an error.

### omitting length

`names := [...]string {"kayak", "lifejacket", "paddle"}`

```go
func main() {
	names := [3]string{"kayak", "lifejacket", "paddle"}
	otherArray := &names
	names[0] = "Canoe"
	fmt.Println(names)
	fmt.Println(*otherArray)
}

```

For this, the type of the `otherArray`is `*[3]string`.

### Comparing Arrays

Using the comparsion operators`==`and `!=`. equal if they are of the same type and contain equal elements in the same order.

## Working with Slices

A variable-length array cuz useful when don’t know how many values need to store. Just like:

`names := []string {"kayak", "...", "..."}`

The slice literal syntax is similar one used for arrays. Note -- the slice is a DS that contains 3 values -- pointer to the array, the length of the slice, and cap of the slice.

### Appending Elements to a Slice

One of the key advantage of slices is that they can be expanded to accommodate additional elements.

`names= append(names, "hat", "gloves")`

`names := make([]string, 3, 6)`

### Appending One slice to Another

`moreNames := []string {"hat gloves"}`

`appendedNames := append(names, moreNames...)`

`someNames := products[1:3]`
`allNames := products[:]`

First call to the `append`func expands the `someNames`slice within the existing backing array. The resizing process **copies** only the array elements that are mapped by the slice, which has the effect of realigning the slice and array indicies.

### Sepcifying cap when creating a slice from an array

`someNames := products[1:3:3]`

### Creating from other Slices

Can also be created from other slices.

```go
allnames := products[1:]
someNames := allNames[1:3]
```

## Input, output and pipes

connect like:

```sh
ls -l /bin | less
```

connect these cuz `ls`writes to stdout and `less`can read from stdin. Just using the pipe to send the output of `ls`to the input of `less`. It puts the first’s stdout to the next command’s stdin.

### Six Commands to Started

`wc, head, cut, grep, sort, uniq`

`man`command to display full documentation.

```sh
wc readme.txt
```

For this, lines, words, and characters showed. so the `-l, -w, -c`, print only the number of lines.

```sh
ls -1 | wc -l
```

```sh
cut -f2-4 animals.txt | head -n3
cut -f1,3 animals.txt | head -n3

# -c option for column
cut -c1-3 animals.txt

# -d to change the separator character to a comma instead of a tab
cut -f4 animals.txt | cut -d, -f1

# grep to match
grep Nutshell animals.txt
# -v for absent
grep -v Nutshell animals.txt
```

```sh
ls -l /usr/lib | cut -c1 | grep d | wc -l
```

The `sort`command reorders the lines of a file into ascending order (the default). -r for descending order.

```sh
# -n for numerically
cut -f3 animals.txt | sort -n
# -r for reverse
cut -f3 animals.txt | sort -nr | head -n1
```

Each line consists of strings separated by colons, like:

```sh
head -n5 /etc/passwd | cut -d: -f1 | sort
```

And the `uniq`command detects repeated -- adjacent lines in a file. removes the repeats.

```sh
cut -f1 grades | sort | uniq -c | sort -nr
```

-c for count, then sort the lines in reverse order. So, sort it first -- 

```sh
cut -f1 grades | sort | uniq -c
cut -f1 grades | sort | uniq -c | sort -nr | head -n1
```

### The `is`operator

The `is`operator just tests whether  variable matches a *pattern*. The C# just supports several kinds of patterns, the most important being a *type pattern*. In this, the `is`just testes whether a reference conversion would succeed. like: 

```cs
if( a is Stock)
    Console.WriteLine(((Stock)a).StockOwed);

// introducing a pattern variable
if(a is Stock s)
    s.SharesOwed;

// note the variable that you introduce is available immediate comsumption
if( a is Stock s && s.SharesOwned>10000)...
    ;
// and it remains in scope outside the is expression
//...
else
    s= new Stock();
Console.WriteLines(s.SharesOwned);
```

## Virtual Function Members

Methods, properties, indexers, and **events** can all be declared `virtual`.

```cs
public class Asset {
    public string Name;
    public virtual decimal Liability => 0;
    // shortcut for {get {return 0;}}
}

// override modifier
public class Stock: Asset {
    public long SharesOwned;
}

public class House: Asset {
    public decimal Mortgage;
    public override decimal Liability=> Mortgage;
}
```

### Covariant return types

From 9, can override a method such that it returns a *more derived* type. 

```cs
public class Asset {
    public string Name;
    public virtual Asset Clone()=> new Asset {Name=Name};
}

public class House : Asset {
    public decimal Mortgage;
    public override House Clone()=> new House {Name=Name, Mortgage=Mortgage};
}
```

### Abs Classes and Members

Abs classes are able to define *abstract member* like – don’t provide default implementation.

```cs
public abstract class Asset {
    public abstract decimal NetValue{get;}
}
```

### Hiding inhertied Members

Occassionally– want to hide a member deliberately. Can apply the `new`modifier – *does nothing more than suppress the compiler warning that would otherwise result*.

```cs
public class A { public int Counter=1;}
public class B : A {public new int Counter=2;}
```

### Sealing Functions and Classes

with the `sealed`keyword to prevent it from being overridden. like:

```cs
public sealed override decimal Liability {get {return Mortgage;}}
```

Just prevents a class that derives `House`class from overriding `Liability`prop.

### `base`keyword

- Accessing an overridden func member from subclass
- Calling a base-class ctor

```cs
public class House : Asset {
    public override decimal Liability => base.Liability+ Mortgage;
}
```

### Ctors and Inheritance

`Subclass`**must** redefine any ctor it wants to expose. So need to use the `base`keyword like:

```cs
public class Subclass : Baseclass {
    public Subclass(int x): base(x) {}
}
```

### implicit calling paramterless base-class ctor

```cs
public class Baseclass {
    public int X;
    public Baseclass(){X=1;}
}

public class Subclass: Baseclass{
    public Subclass(){X /* 1 */}
}
```

## The `object`Type

Is just the utilimate base class for all types. Any type can be upcast to `object`. Fore:

```cs
// works with the object type, can push and pop any type
Stack s = new Stack();
s.Push("Sausage");
string ss = (string)s.Pop();
ss.Dump();

public class Stack
{
	int position;
	object[] data = new object[10];
	public void Push(object obj)
	{
		data[position++] = obj;
	}
	public object Pop()
	{
		return data[--position];
	}
}
```

### Boxing and Unboxing

*Boxing* - Converts a value-type instance to a reference-type instance. *Unboxing* reverses the operation by casting the obj back to the original value type. And unboxing requires an **explicit** cast. The runtime checks the stated value type matches the actual object type. Through `InvalidCastException`if fails.

```cs
object obj = 3.5;
int x = (int)(double)obj;  // x is now 3
// performs an unboxing, then (int)performs a numeric cast.
```

### Copying semantics of boxing and unboxing

Note that boxing *copies* the value-type instance into the new object – and unboxing also *copies* the content of the object back into a value-type instance.

### The `GetType()`and `typeof`operator

All types in C# are just represented at runtime with an instance of `System.Type`. Two ways to get `Sytem.Type`obj:

- Call `GetType()`on the **instance**
- Use the `typeof`on the **type name**

so, `GetType()`works at runtime and `typeof`is evaluated at compile time.

### `ToString()`

returns the default textual representation of a type instance. Can override that like:

```cs
class Panda {
    public string Name;
    public override string ToString()=> Name;
}
```

## Structs

Is similar to a class.

- value type
- does not support inheritance – implicitly deriving from `object`, more precisely, `System.ValueType`

### The default ctor

A struct **always** has an implicit parameterless ctor that performs a bitwise-zeroing of its fields. Even when you define a parameterless ctor of your own – like:

```cs
Point p = new Point();
(p.x, p.y).Dump();

Point p2 = default;
(p2.x, p2.y).Dump(); // 0, 0

struct Point
{
	public int x = 1;
	public int y;
	public Point() => y = 1;
}
```

### Read-only structs and Functions

Can apply `readonly`to a struct to enforce all fields are `readonly`. And if you need to apply at a more granular level  like:

```cs
struct Point {
    public int X, Y;
    public readonly void ResetX()=> x=0; // error
}
```

### `ref`structs

If a value type appears as a field in a class, it will also reside on the heap. So, adding the `ref`modifier to a struct’s declaration ensures that it can only ever reside on the stack. like:

```cs
ref struct Point {public int X, Y;}
class MyClass {Point p;} // error, will not compile
```

## Interfaces

- Can define only functions and not fields.
- Interface members are *implicitly* abstract. – from C# 8, can be non-abstract, special case.

### Explicit implemenation

cuz, Implementing multiple interfaces can sometimes result in a collision between member signatures, can resolve that by *explicitly implementing* an interface member. FORE:

```cs
interface I1 {void Foo();}
interface I2 {int Foo();}

public class Widget: I1, I2 {
    public void Foo(){
        Console.WriteLine("I1.Foo");
    }
    int I2.Foo() {
        Console.WriteLine("I2.Foo");
        return 42;
    }
}
```

The only way to call an explicitly implemented member is to cast to its interface note that – 

```cs
Widget w = new Widget();
w.Foo(); // I1.Foo
((I1)w).Foo(); // I1.Foo
((I2)w).Foo(); // I2.Foo
```

### Implementing Members Virtually

By default, implemented is **sealed** – must be marked `virtual`or `abstract`in order to be overridden. like:

```cs
public interface IUndoable {void Undo();}

public class TextBox: IUndoable {
    public virtual void Undo()=>...;
}
public class RichTextBoxz: TextBox {
    public override void Undo()=> ...;
}
```

### Re-implementing an interface in a Subclass

```cs
public interface IUndoable {void Undo();}
public class TextBox : IUndoable {...}
public class RichTextBox: TextBox, IUndoable {...}
```

Calling the re-implemented member through the interface calls the subclass’s implemenation.

### Alternative to interface re-implementation

To design a base class such that reimplementation will never be required :

- mark it `virtual`
- use the following pattern like:

```cs
public class TextBox : IUndoable {
    void IUndoable.Undo() => Undo(); // calls the method
    protected virtual void Undo()=>...;
}
public class RichText: TextBox {
    protected override void Undo() => ...
}
```

### Interfaces and Boxing

Converting a struct to an interface causing boxing, Calling an implicitly implemented member on a struct does not cause boxing. like:

```cs
interface I {void Foo();}
struct S: I {public void Foo(){}}
S s = new S();
s.Foo();  // no boxing
I i = s;
i.Foo(); // box occurs when casting to interface
```

### Default interface Members

From 8, can add a default implementation to an interface member, making that optional to implement:

```cs
interface ILogger {
    void Log(string text)=> Console.WriteLine(...);
}
```

And note that this is always explicitly.

## Enums

Is special **value** type.

```cs
// underlying values are of type int
// constants 0, 1, 2... are automatically assigned in the declaration order of the enum members.
public enum BorderSide {Left, Right, Top, Bottom}
```

### Conversions

```cs
int i = (int)BorderSide.Left;
BorderSide side = (BorderSide)i;
```

Can also use explicitly cast – like:

```cs
public enum HorizontalAlignment {
    Left = BorderSide.Left,
    Right = BorderSide.Right,
    Center
}
```

### Flags Enums

Can combine enum members, to prevent ambiguities.

```cs
[Flags]
enum BorderSide {None=0, Left=1, Right =2, Top=4, Bottom =8}
// or use Right = 1<<1
```

To work with – use bitwise such as `|`and `&`..

Use this can use:

```cs
[Flags]
enum BorderSides {
    None=0,
    Left =1... Bottom= 1<<3,
    LeftRight=Left | Right,
    //...
    All = LeftRight | TopBottom
}
```

## Generics

C# has two separate mechanisms for writing code that is reusable – placeholder, for generics. like:

Declares *type parameters* FORE:

```cs
var stack = new Stack<int>();
stack.Push(5);
stack.Pop().Dump();

public class Stack<T>
{
	int pos;
	T[] data = new T[100];
	public void Push(T obj) => data[pos++] = obj;
	public T Pop() => data[--pos];
}
```

### Generic Methods

```cs
static void Swap<T> (ref T a, ref T b) {
    (a, b)= (b, a)
}
```

### The default Generic Value

Can use the `default`to get the default value for a generic type. FORE:

```cs
static void Zap<T> (T[] array) {
    for(int i=0; i<array.Length; i++)
        array[i]=default(T);
    // from C# 7, can omit like 
    array[i]=default;
}
```

### Self-referencing Generic Declarations

A type name can *itself* as the concrete type like:

```cs
public interface IEquatable<T> {bool Equals(T obj);}
public class Balloon : IEquatable<Balloon> {
    //...
    public bool Equals (Balloon b) {
        if(b==null) return false;
        return b.Color==Color && b.CC=CC;
    }
}
```

## Middleware and Request Pipeline

Some focus on generating responses for requests, others to provide supporting features.

### Understanding Services

Objects that provide features in a web app. Any class can be used as service, no restrictions on the features that services provide. *dependency injection* makes that possible to easily access services anywhere in the app.

```cs
// set up the basic features of the .NET platform
var builder = WebApplication.CreateBuilder(args);

// finalize initial setup
var app = builder.Build();

// app is a WebApplication object, to setup middleware components
// set up handle HTTP requests with a specified URL path
app.MapGet("/", () => "Hello World");
app.Run();
```

### the Project File

Contains info that .NET Core uses to build the project and keep track of dependencies. LIke:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
<PropertyGroup>
    <TargetFramework>net6.0</TargetFramework>
    </PropertyGroup>
</Project>
```

### Creating Custom Middleware

In the `Program.cs`file just:

```cs
app.Use(async (context, next) =>
{
    if (context.Request.Method == "GET" &&
    context.Request.Query["custom"] == "true")
    {
        context.Response.ContentType = "text/plain";
        await context.Response.WriteAsync("Custom Middleware\n");
    }
    await next();
});
```

The `HttpContext`obj describes the HTTP request and the response and, provides additional context. 

`Connection, Request, RequestServices, Response, Session, User, Features`

And the `Request`is `HttpRequest`class like:

`Body, ContentLength, ContentType, Cookies, Form, Headers, IsHttps, Method, Path, Query`

And the Response is `HttpResponse`class like:

`ContentLength, ContentType, Cookies, HasStarted, Headers, StatusCode, WriteAsync(data), Redirect(url)`

Note that the second arg to the middleware is the function conventionally named `next`tells core to pass the request to the next component in the request pipeline.

### Using Class

```cs
public class QueryStringMiddleware
{
    private RequestDelegate next;

    public QueryStringMiddleware(RequestDelegate next) => this.next = next;

    public async Task Invoke(HttpContext context)
    {
        if (context.Request.Method == "GET" &&
            context.Request.Query["custom"] == "true")
        {
            if (!context.Response.HasStarted)
            {
                context.Response.ContentType = "text/plain";
            }
            await context.Response.WriteAsync("Class-based Middleware\n");
        }
        await next(context);
    }
}

// Then in the program.cs file:
app.UseMiddleware<Platform.QueryStringMIddleware>();
```

### Return Pipeline Path

Middleware components can modify the `HttpResponse`obj after the `next`func has been called. FORE:

```cs
app.Use(async (context, next) =>
{
    await next();
    await context.Response
    .WriteAsync($"\nStatus code: {context.Response.StatusCode}");
});
```

So, Middleware can operate before the request is passed on. It allows middleware to make chages to the response before and **after** it is passed along the request pipeline by defining statements before and after the next function is invoked.

### Short-Circuiting

Can choose not to call the `next()`function.

```cs
app.Use(async (context, next) =>
{
    if (context.Request.Path == "/short")
    {
        await context.Response.WriteAsync("Request short circuited!");
    }
    else
    {
        await next();
    }
});
```

### The `instanceof`operator

Expects a left-side operand that is an obj and right-side identifies a class of objs. so:

### Evaluation Expressions

`eval("3+2")`

A func can declare a local func with code like:

`eval("function f() {return x+1;}")`

The first-defined operator `??`evaluates to first defined, if its left is not `null`and not `undefined`, it returns that value. Otherwise, returns the value of the right. Fore:

```js
// if maxWidth is defined, use that, otherwise, look for a value in the preference
// object, if also not defined, using hardcoded constant like:
let max = maxWidth ?? preference.maxWidth ?? 500;
```

### `typeof`operator

note: `null`=> “object”, any nonfunction object is “object”

### `delete`operator

delete the obj property or array element specified as its operand.

```js
let o = {x:1, y:2};
delete o.x;
"x" in o // false

let a = [1,2,3];
delete a[2];
2 in a; // false
a.length // 3, not change
```

### `void`operator

`void`is just a unary operator that appears before its single operand. Which may be of any type. It evaluates its operand, which may be of any type. It evaluates its operand, then discards the value and returns `undefined`. Like:

```js
let counter= 0;
const increment = ()=> void counter++;
increment(); // => undefined
counter; // 1
```

### `for/in`

a `for/in`works with any object after the `in`, This loops through the property names of a specified object. like:

```js
for(variable in object) statement
```

### yield

is like `return`, but in ES6 generator function to produce the next value in the generated sequence of values without actually returning – like:

```js
function* range(from, to) {
    for (let i = from; i <= to; i++) {
        yield i;
    }
}

[...range(1,5)]
```

```js
function factorial(x) {
    if (x < 0)
        throw new Error("x must not be negative");
    let f;
    for (f = 1; x > 1; f *= x, x--);
    return f;
}

factorial(4)
```

When an EX is thrown, the js interpreter immediately stops normal program and jumps to the nearest exception handler. And expcetion handlers are written using the `catch`of the `try/catch/finally`statement. Like:

```js
try {
    // normally, run from the top to the bottom
    // sometimes throw
}catch(e) {
    // executed if the try throws
}finally {
    // contains statements that are always executed, regardless of what happens in the try
}
```

## Creating Objects

Can be created with object literals, with the `new`, and `Object.create()`func.

### Prototypes

Almost every object has a second Js object assocaited with that. Known as a *prototype*. And all objects created by object literals have the same prototype object, and can refer to this in Js code as `Object.prototype`. Objects using `new`and ctor invocation use the value of the `prototype` of ctor function as their prototype. FORE, `new Array()`using `Array.prototype`as its prototype. Just, almost all objects have a `prototype`, but only relatively small number have a `prototype`property.

For `Object.prototype`, is one of the rare objects that has no prototype, it does not inherit any properties. Others are normal objects do have one.

### `Object.create()`

Creates a new object, using its first arg as the prototype of the object like:

```js
let o1 = Object.create({x:1, y:2})
o1.x+o1.y // 3

// o2 has no props or methods
let o2= Object.create(null);

// o3 is like {} or new Object()
let o3= Object.create(Object.prototype);
```

## Querying and Setting Properties

Js have a set of *own properties* – also inherit a set of properties from their prototype object. ES2020 supports conditional property access with `?.`operator.

### Property Enumeration Order

`Object.keys(), Object.getOwnPropertyNames(), Object.getOwnPropertySymbols(), Reflect.OwnKeys()`

### Extending Objects

Like:

```js
let target = {x:1}, source= {y:2, z:3};
for(let key of Object.keys(source)) {
    target[key]= source[key];
}
```

This is a common operation, define `Object.assign()`function – expects two or more objects as args. modifies and returns the first arg, but not alter the second or any subsequent args. Copies properties with ordinary prop get and set ops. like:

```js
Object.assign(o, defaults); // overwrite everything in o with defaults

// create a new, copy defaults into it, then override those with o
o = Object.assign({}, defaults, o);
// also:
o= {...defaults, ...o};
```

Could also avoid the overhead of the extra object creation and copying by writing like:

```js
function merge(target, ...sourceset) {
    for (let source of sourceset) {
        for (let key of Object.keys(source)) {
            if (!(key in target)) {
                target[key] = source[key];
            }
        }
    }
    return target;
}

merge({ x: 1 }, { x: 1, y: 2 }, { y: 3, z: 4 });
```

## Serializing Objects

Is the process of converting an object’s state to a string from which it can later be restored. The function `JSON.stringify()`and `JSON.parse()`, serialize and restore objects.

```js
let o = { x: 1, y: { z: [false, null, ''] } };
let s = JSON.stringify(o);
let p = JSON.parse(s);
```

JSON is a *subset* of Js syntax. And `JSON.stringfy()`serializes only the **enumerable** own properties of an object.

### Object Methods

`toString(), `define own `toString()`function like this:

```js
let point = {
    x: 1, y: 2,
    toString: function () { return `(${this.x}, ${this.y})` }
};
String(point)
```

The `valueOf()`and `toJSON()`methods like:

```js
let point = {
    x:3, y:4,
    valueOf: function() {return Math.hypot(this.x, this.y)}
}
```

```js
toJSON: function() {return this.toString();}
```

## Extended Object Literal Syntax

In ES6 and later, can just:

```js
let x= 1, y=2;
let o= {x, y};
```

### Symbols as property Names

Property names can be strings or symbols.

```js
const extension = Symbol("my extension symbol");
let o = {
    [extension]: 1
};
o[extension]
```

And after ES2018, can copy the props of existing object into a new object using `...`spread operator like:

```js
let position = {x:0, y: 0};
let dimensions = {width:100, height:75};
let rect = {...position, ...dimensions};
```

When a func is defined as a property of an object, call that function a *method* – like:

```js
let square = {
    area() {return this.side* this.side;},
    side:10
}
```

### Getters and Setters

Introduced in ES5 like:

```js
let o = {
    dataProp: 5,
    get accessorProp() { return this.dataProp; },
    set accessorProp(val) { this.dataProp = val; }
}
o.accessorProp = 10;
console.log(o.accessorProp);
```

## Creating Arrays

- Literals
- `...`on an iterable object
- `Array()`ctor
- `Array.of()`and `Array.from()`factory methods

The spread operator is a convenient way to create a shallow copy of an array like:

```js
let orig = [1,2,3];
let copy= [...orig];
copy[0]=0;
orig[0] // 1 not changed
```

### `Array.of()`and `Array.from()`

```js
Array.of(1,2,3); // [1,2,3]
let copy = Array.from(orig); // works like [...orig]
```

For the `array.from()`it defines a way to make a true-array copy of an array-like object. are non-array objects that have a numeric length prop and have values stored with properties whose names happen to be integers.

```js
a = [1,2,3,4,5];
a.length=3; // now [1,2,3]
a.length=0; // empty , all deleted
a.length =5; // no elements, like new Array(5) called
```

And, just need to note that `delete`doesn’t affect the length of array.
