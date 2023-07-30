## Using the Go Command

The `go`command provides access to all the features needed to compile and execute Go code and is used throughout. The `go clean`command removes the output produced by the `go build`. executable and any temporary. `go doc`generates documenation from source code. `go fmt`ensures consistent indentation and alignment in source code files. `go get`downloads and installs external packages. `go install`downloads packages and is usually used to install tool packages. `go mod`create and manage a Go modules. `go run`builds and executes the source code in a specified folder. `go vet`detects common problems in Go code.

### Defining a Module

`go mod init tools` -- adds a file named `go.mod`to the `tools`folder.

`rune`-- this type represents a single Unicode code point.

### Converting Floating-Point values to Integers

`Ceil(value)`, `Floor(value)`, `Round(value)`, `RoundToEven(value)`.

```go
func main() {
	kayak := 275
	soccerBall := 19.50

	total := kayak + int(math.Round(soccerBall))
	fmt.Println(total)
}
```

### Parsing from strings

Note that the `strconv`package, which provides functions for converting `string`values to other basic data types. like:

`ParseBool(str)`, `ParseFloat(str, size)`, `ParseInt(str, base, size)`, `ParseUint(str, base, size)` `Atoi(str)`

```go
func main(){
	val1 := "0"
	if bool1, b1err := strconv.ParseBool(val1); b1err==nil {
		fmt.Println("Parsed value:", bool1)
	}else{
		fmt.Println("Cannot parse", val1)
	}
}
```

### Parsing Integers

The `ParseInt`and `ParseUint`, requires the base of number represented by the string and the size of the data.

```go
func main() {
	val1 := "100"

	// 0 represent base number, zero to let the function detect the base from the string
	// prefix -- final arg is the size of the data type
	int1, int1err := strconv.ParseInt(val1, 0, 8)
	if int1err == nil {
		fmt.Println("Parsed value:", int1)
	} else {
		fmt.Println("Cannot parse", val1)
	}
}
```

and:

```go
val1 := "500"
int1, int1err := strconv.ParseInt(val1, 0, 8)
if int1err == nil {
    fmt.Println(...)
}else{
    fmt.Println("Cannot parse", val1, int1err)
}
```

For this, the string `500`cannot be parsed -- is to larger to represent as an 8-bit.

parsing binary, octal, and hexadecimal integers -- 

`int1, int1err := strconv.ParseInt(val1,2,8)` or Like:

```go
func main() {
	val1 := "0b1100100"
	int1, int1err := strconv.ParseInt(val1, 0, 8)
	if int1err == nil {
		smallInt := int8(int1)
		fmt.Println("Parsed value:", smallInt)
	} else {
		fmt.Println("Cannot parse", val1, int1err)
	}
}
```

Such a common task that the `strconv`package provides the `Atio`func -- which handles the parsing and explicit conversion in a single step.

```go
func main() {
	val1 := "100"
	int1, int1err := strconv.Atoi(val1)
	if int1err == nil {
		var intResult int = int1
		fmt.Println("Parsed value:", intResult)
	} else {
		fmt.Println("Cannot parse", val1, int1err)
	}
}
```

Just note that the `Atoi`doesn’t support parsing non-decimal values. likewise, Parsing Floating-point numbers like:

```go
// also can use like this
val1 := "4.895e+01"
float1, float1err := strconv.ParseFloat(val1,64)
```

### Formatting Values as Strings

Just -- 

`FormatBool(val)`, `FormatInt(val, base)`, `FormatFloat`and `Itoa`

```go
func main() {
	val := 49.95

	Fstring := strconv.FormatFloat(val, 'f', 2, 64) // 2 prec number
	Estring := strconv.FormatFloat(val, 'e', -1, 64)

	fmt.Println("Format F:", Fstring) // 49.95
	fmt.Println("Format E:", Estring) // 4.995e+01
}
```

Known -- the 3rd arg to the `FormatFloat`function just specifies the number of digits will follow the decimal point.

And the `else/if`combination can be repeated to create a sequence of claues. like:

```go
if kayakPrice>500 {
    fmt.Println("Price is greater than 500")
}else if kayakPrice <100 {
    fmt.Println("Price is less than 100")
}else if kayakPrice
```

In Go, also `continue`keyword, can be used to terminate the execution of the `for`loop’s statements for the current value and move to the next iteration.

### The `readonly`modifier

prevents a field from being modified after construction. only in its declaration or within the enclosing type’s ctor.

### Constants

Is evaluated stactically at compile time. A constant can serve a simlar to a `static readonly`field, but is much more restrictive. A constant also differs from a `static readony`in that evaluation of the constant occurs at compile time. In constrast, a `static readonly`field’s value can potentially differ each time the program is run like:

```cs
static readonly DateTime StartupTime= DateTime.Now;
```

Note – A `static readonly`is also advantageous when exposing to other assemblies a value that might change in a later version. And constants can also be declared local to a method like:

```cs
const double twoPI= 2*System.Math.PI;
```

### Overloading

The return type and the `params`modifier are not part of a method’s signature.

```cs
void Goo(int [] x) {...}
void Goo(params int[] x) {...} // compile-time error
```

Pass-by-value or pass-by-reference is also part of the signature.

### Overloading ctors

```cs
public class Wine {
    public decimal Price;
    public int Year;
    public Wine(decimal price) {Price=price;}
    public Wine(decimal price, int year): this(price) {Year=year;}
}
```

And note that when one ctor calls another, the *called* ctor executes first. Can also pass an expression into another like:

`public Wine(decimal price, DateTime year): this(price, year.Year) {}`

and note that the parameterless ctor is no longer automatically generated as soon as you define at least one.

### Nonpublic ctors

Ctors do not need to be public. A common to have a nonpublic is to control instance creation just via a static method call. like:

```cs
public class Class1 {
    Class1(){}
    public static Class1 Create(...) {
        // perform custom logic here to return an instance of Class1
    }
}
```

### Dtors

A deconstruction method must be called `Deconstruct`and have one or more `out`parameter(s). Like:

```cs
var rect = new Rectangle(3, 4);
var (width, height) = rect;
(width, height).Dump();

class Rectangle
{
	public readonly float Width, Height;

	public Rectangle(float width, float height)
	{
		Width = width;
		Height = height;
	}

	public void Deconstruct(out float width, out float height)
	{
		width = Width;
		height = Height;
	}
}
```

For this, our deconstructing call is equivalent to the following:

```cs
float width, height;
rect.Deconstruct(out width, out height);
```

### The `this`Reference

Refers to the instance itself – like:

```cs
public class Panda {
    public Panda Mate;
    public void Marry(Panda partner) {
        Mate= partner;
        partner.Mate = this;
    }
}
```

### Properties

Is declared like a field but with `get/set`block added like:

```cs
public class Stock {
    decimal currentPrice;
    public decimal CurrentPrice {
        get {return currentPrice;}
        set {currentPrice=value;}
    }
}
```

The `get`runs when the prop is read and `set`runs when is assigned. It has an *implicit* parameter named `value`of the property’s type that you typically assigned to a private field. The fields and properties differ in that they give the implementer complete control over getting and setting its values. This control enables the implementer to choose whatever internal representation is needed without exposing the internal details to the user of the property.

### `Read-only`and calculated properties

read-only if it specifies only a `get`accessor. And write-only if specifies only a `set`like:

```cs
decimal currentPrice, sharesOwed;
public decimal Worth {
    get {return currentPrice* sharesOwed;}
}
```

### Expression-bodied properties

Can declare a read-only property, such as the one in the preceding example – like:

```cs
public decimal Worth => currentPrice * shareOwed;

// for set
public decimal Worth {
    get => currentPrice * sharesOwed;
    set => shareOwned = value/currentPrice;
} // just note that the value is the Worth itself
```

### Automatic properties

The most common implementation for a property is a getter and/or setter that simply reads and writes to a private field as the property. A fat arrow replaces all braces like:

```cs
public class Stock {
    public decimal CurrentPrice {get; set;}
}
```

For this, the compiler automatically generates a private backing field of a compiler-generated name that cannot be referred to. And the `set`accessor can be marked `private`or `protected`.

### Property initializers

Can add a *property initializer* to automatic properties like:

`public decimal CurrentPrice {get;set;}= 123;`

also, can be read-only like:

`public int Maximum {get;}=899;`

### get and set accessibility

The `get`and `set`accessors can have different access levels. The typical use case for this is to have a `public`property with an `internal`or `private`modifier on the setter like:

```cs
public class Foo {
    private decimal x;
    public decimal X {
        get {return x;}
        private set {x= Math.Round(value,2);}
    }
}
```

### Init-only setters

From 9, like:

```cs
public class Note {
    public int Pitch {get; init;} =20;
    public int Duration {get; init;} = 100;
}
```

Acts like read-only, except that they can also be set via an object initializer like:

`var note = new Note {Pitch =50};`

And after that, the property cannot be alterted.

Init-only properties cannot even be set from inside their class, except via their prop initializer. And, the alternative way:

```cs
public class Note {
    public int Pitch {get;}
    public Note(int pitch=20) {
        Pitch = pitch;
    }
}
```

Note, as with ordinary `set`accessors, init-only can provide an implementation like:

```cs
public class Note {
    readonly int _pitch;
    public int Pitch {get => _pitch; init => _pitch = value; }
}
```

### CLR Property implementation

C# property accessors internally compile to methods called `get_XXX`and `set_XXX`. fore:

```cs
public decimal get_CurrentPrice {...}
public void set_CurrentPrice(decimal value) {...}
```

And `init`accessor is processed like a `set`accessor, but just with extra flag encoded into the `set`accessor’s modreq metadata.

### Indexers

**Indexers** provide a natural syntax for accessing elements in a class or struct that encapsulate a list or dictionary of values. like: Specifying the args in square brackets. like:

```cs
Sentence s = new Sentence();
s[3].Dump();

class Sentence
{
	string[] words = "The quick brown fox".Split();
	public string this[int num]
	{
		get => words[num];
		set => words[num] = value;
	}
}

```

And a type can declare multiple indexers, each with parameters of different types. And an indexer can also take more than one parameters like:

```cs
public string this [int arg1, string arg2] {
    get{...} set {...}
}
```

For the CLR, internally compile to methods called `get_Item`and `set_Item`

Could extend our example by adding the following indexers to the `Sentence`class like:

```cs
public string this [Index index]=> words[index];
public string[] this [Range range]=> words[range];
```

### Static Ctors

A static ctor executes onece per type rather than per *instance*.

```cs
class Test {
    static Test() {Console.WriteLine("Type initialized");}
}
```

And static field initializers run just *before* the static ctor is called.

### Finalizers

Are class-only methods that execute before the garbage collector reclaims the memroy for an unreferenced object. The compiler expands into:

```cs
class Class1 {
    ~Class1(){...}
}

// compiler's work
protected override void Finalize() {
    //...
    base.Finalize();
}
```

### Polymorphism

References are *polymorphic* – means a variable of type *x* can refer to an object that subclasses of *x*. This works on the basis that subclasses have all the features of their base class. The converse, is not true.

Upcasting – An upcast operation creates a base class refrence from a subclass reference. And a downcast operation creates a subclass from a base class reference. Only references are affected – not the underlying object. note that.

### as operator

`as`performs a **downcast** that evaluates to `null`if fails. Like:

```cs
Asset a = new Asset();
Stock s = a as Stock; // s is null, no exception thrown
```

Note that `as`operator cannot perform *custom* conversions and cannot do numeric conversions.

### `is`operator

Whether an object derives from a specified class, or implements an interface like:

```cs
if ( a is Stock ) ...
```

`is`also evaluates to `true`if an *unboxing* conversion would succeed.

Introducing a pattern –

```cs
if( a is Stock s ) ...
    // equ:
```

```cs
Stock s;
if (a is Stock){
    s = (Stock)a;
}
```

An obj is a collection of *properties* where each property has a name and a value. An ordinary obj is an unordered collection of named values. Js supports an obj-oriented Programming style – object types are *mutable* and its primitive types are *immutable*.

Note that :

```js
let zero= 0;
let negz=-0;
zero === negz; // true
1/zero === 1/negz; //false
```

If floating-point approximations are problematic for programs, consider using scaled integers.

### Arbitrary Precision Integers with BigInt

BigInt literals are just written as a string of digits followed by a lowercase letter `n`. Can also use `BigInt()`func for converting Js numbers or strings to BigInt values like:

`BigInt(Number.MAX_SAFE_INTEGER)`

```js
let string = '1'+'0'.repeat(100)
BigInt(string)
```

### Dates and Times

Just note also have a numeric representation as a *timestamp* that specifies the number of elapsed m-seconds since 1970-1-1.

### strings

Js provides a rich API for working with strings –

```js
let s = "Hello, World";
s.substring(1,4)
s.slice(1,4)  // same as before
s.slice(-3) // rld, last 3 chars
s.split(", ") // [Hello, World]
s.indexOf("l")
s.lastIndexOf("l") // 10
s.startsWith, endsWidth, includes
s.replace, s.toLowerCase, s.toUppercase
```

### Symbols

ES6 to serve as non-string property names. Need to know that Js’ fundmental obj is an unordered collection of properties, where each prop has a name and a value. typically strings, but in ES6 and later, just also serve this purpose like:

```js
let strname= "string name";
let syname= Symbol("propname")
typeof synbame // symbol
let o = {};
o[syname]=2;
```

Note that the `Symbol()`function never returns the same value twice – even when called with the same argument. Can safely use that value as a prop name to add a new property to an object and do not need to worry that you might overwirting an existing prop.

serve as a language extension mechanism. `for/of`loops. `Symbol.iterator`is a Symbol value that can be used as a method name to make an object iterable.

Certain js operators perform implicit conversions and are sometimes used explicitly for the purpose of type conversion.

The `toString()`defined by the `Numbe`class accepts an optional argument that specifies a radix, or base.

```js
let n = 17;
let binary = "0b"+n.toString(2); // also, n.toString(8)...16
```

And `Number`also defines `toFixed()`and `toExpontential()`do that.

### `toString()`and `valueOf()`

ES6 implements a kind of cmpound declaration and assignment syntax *destructing assignment*. like:

```js
let [x,y]=[1,2];
[x,y]=[x+1, y+1];
[x,y]=[y,x];
```

Note that the number of variables on the left of a destructing assignment does not have to match the number of **array** elements on the right.

```js
let [x,y]=[1]; // x==1, y==undefined
[,x,,y]=[1,2,3,4]; // x==2; y==4
```

And, if want to collect all unused or remaining values:

```js
let [x,...y]=[1,2,3,4]; // x=1, y=[2,3,4]
```

Es2020 adds two new kinds of property access expressions – 

```js
expression?.identifier
expression?.[expression]
```

In a regular property access expression using . or [], get a `TypeError`if expression on the left evulates to `null`or `undefined`.

And this condition invocation syntax of Es2020, can simply write the function invocation using ?.(), knowing that invocation will only happen if there is actually a value to be invoked.

```js
function square(x,log) {
    log?.(x); // call the func if there is one
    return x*x;
}
```

and note the ?.() only checks whether lefthand side is `null`or `undefined`. just:

```js
let a;
let index=0;
try {
    a[index++];
}catch(e){
    index
}
// and for this case:
let f= null, x=0;
try {
    f(x++);
}catch(e){
    x
}
```

And, if no args are passed to the ctor function in an obj creation expression, the empty pair of parentheses can be just omited.

### The `in`operator

expects a left-side operand that is a string, or value that can be converted to a string. It expects a right-side operand is an object. It expects a right-side operand that is an obj.

```js
let point = {x:1, y:1};
"x" in point
"z" in point
"toString" in point // true, obj inherits toString method.

let data= [7,8,9];
"0" in data // true 
1 in data // true
```

