## Undersanding Structs and Pointers

Assigning a struct to a new variable or using a struct as a function parameter creates a new value that copies the field values -- as demonstrated -- Accessing struct fields through a pointer is just awkward -- which is cuz structs are commonly used as function arguments and results, and pointers are required to ensure that structs are not needlessly duplicated and that changes made by functions affected the values received as parameters.

```go
func calcTax(product *Product) {
	if (*product).price > 100 {
		(*product).price += (*&product).price * 0.2
	}
}
```

To simply this type of code, go just follow pointers to struct fields without needing an asterisk - just:

```go
func calcTax(product *Product) {
	if product.price > 100 {
		product.price += product.price * 0.2
	}
}
```

### Understanding Pointers to Values

The second step is to use the address operator to create a pointer like:

`calcTax(&kayak)`

There is no need to assign a struct value to a variable before creating a pointer, and the address operator can be used directly with the literal struct syntax. like:

```go
func main(){
    kayak := &Product {...}
    calcTax(kayak)
}

// using pointers directly 
func calcTax(product *Product) *Product {
    //...
    return product
}
func main(){
    kayak := calcTax(&Product {...})
}
```

### Understanding Struct Constructor Function

```go
func newProduct(name, category string, price float64) *Product {
	return &Product{name, category, price}
}
func main() {
	products := [2]*Product{
		newProduct("Kayak", "Watersports", 275),
		newProduct("Hat", "Skiing", 42.50),
	}

	for _, p := range products {
		fmt.Println(p.name, p.category, p.price)
	}
}
```

So, CTOR functions are used to create struct values consistently -- Ctor functions are usually named `new...`or `New...` And the benefit of using ctor functions is consistency -- ensuring that changes to the construction process are reflected in all the struct values created by the function.

### Using Pointer Types for Struct Fields

Prointers can also be used for `struct`fields, including pointers to other struct types. Like:

```go
type Product struct {
    //...
    *Supplier
}
type Supplier struct {
    name, city string
}
func newProduct(name,category string, price float64, supplier *Supplier) *Product {
    return &Product {name, category, price, supplier}
}
func main(){
    acme := &Supplier {...}
    products := []*Product {
        newProduct(..., acme),
        newProduct(..., acme),
    }
}
```

### Understanding pointer Field Copying

Care must be taken when copying structs to consider the effect on pointer fields. The upper example -- just used to create a pointer field. This is often referred to as a *shallow* copy. Note that Go doesn’t have a built-in *deep* copy. but:

```go
func copyProduct(product *Product) Product {
    p := *product
    s := *product.Supplier
    p.Supplier = &s
    return p
}
```

### Zero Value for structs and Pointers

The zero for struct type is a struct value whose fields are assigned their zero type. Like:

```go
type Product struct {
    name, category string
    price float64
}

func main(){
    var prod Product
    var prodPtr *Product  // <nil>
}
```

So, there is a pitfall, which -- when a struct defines a filed with a pointer to another struct type -- 

```go
var prod Product // which has a pointer to Supplier struct
// so just:
var prod Product = Product {Supplier: &Supplier{}}
```

This just avoids the runtime error.

# Using Methods and Interfaces

- Methods are funcs that are invoked on a struct and have acces to all of the fields defined by the value’s type. Interfaces define sets of methods, which can be implemented by struct types.
- These allow types to be mixed and used through common characteristics.

## Defining and using Methods

```go
func newProduct(name, category string, price float64) *Product {
	return &Product{name, category, price}
}

func (product *Product) printDetails() {
	fmt.Println("Name:", product.name, "Category:", product.category,
		"price:", product.price)
}

func main() {
	products := []*Product{
		{"Kayak", "Watersports", 275},
		{"Lifejacket", "Watersports", 48.95},
		{"Soccer Ball", "Soccer", 19.50},
	}

	for _, p := range products {
		p.printDetails()
	}
}
```

The `()`after the keyword `func`is a *receiver* -- which just denotes a special parameter -- is the type on which the method opertes. The type of the receiver for this is `*Product`and is given the name `product`-- which can be used within the method just like any normal function parameter.

### Defning paramters and Results

```go
func (product *Product) printDetails() {
	fmt.Println("Name:", product.name, "Category:", product.category,
		"price:", product.calcTax(0.2, 100))
}

func (product *Product) calcTax(rate, threshold float64) float64 {
	if product.price > threshold {
		return product.price + product.price*rate
	}
	return product.price
}
```

### Understanding overloading

Note that Go **does not** support overloading, where multiple methods can be dfefined with the same name.. instead - each combination must be unique.

Understanding Pointer and Value Receivers -- A method whose receiver is a pointer type can also be invoked through a regular value of the underlying type. Fore:

```go
func (product *Product) printDetails() {...}
func main() {
    kayak := Product {}
    kayak.printDetails() // ok
}
```

Go just takes care of this mismatch and invokes the method **seamlessly**. Note that the opposite process is also **true** so that a method can receives a value can be invoked using a pointer. like:

```go
func (product Product) printDetails() {...}
func main(){
    kayakPtr := &Product {...}
    kayak.printDetails() // ok too
}
```

### Defiining Methods for Type Aliases

Methods can be dfeind for any type defined in the current package - `type`keyword just can be used to create aliases to any type and *methods can be defined for the ailias.* just like:

```go
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

	for cat, total := range products.calcCategoryTotals() {
		fmt.Println("Category:", cat, "Toal", total)
	}
}
```

### Putting Types and methods in separate files

```go
// the contents of the product.go
package main
type Product struct {...}

// the content of service.go
package main 
type Service struct {...}

// content of the main.go
package main
import "fmt"
func main(){...}
```

## Defining and using Interfaces

Defining an interface - which describe a set of methods without specifying the implementation of those methods. To implement an interface, all the methods specified by the interface **must** be defined for a struct type.

```go
type Service struct {
	description    string
	durationMonths int
	monthlyFee     float64
}

type Expense interface {
	getName() string
	getCost(annual bool) float64
}

func (p Product) getName() string {
	return p.name
}

func (p Product) getCost(_ bool) float64 {
	return p.price
}

func (s Service) getName() string {
	return s.description
}

func (s Service) getCost(recur bool) float64 {
	if recur {
		return s.monthlyFee * float64(s.durationMonths)
	}
	return s.monthlyFee
}

func main() {
	kayak := Product{"Kayak", "Watersports", 275}
	insurance := Service{"Boat Cover", 12, 89.50}

	expenses := []Expense{
		kayak, insurance,
	}

	for _, expense := range expenses {
		fmt.Println("Expense", expense.getName(), "Cost:", expense.getCost(true))
	}
}
```

In this, just defined an `Expense`slice and populated it with `Product`and `Service`values created the literal syntax.

NOTE -- variables whose type is an *interface have two types* -- **Static** and **Dynamic** -- The static is the interface type, and the dynamic is the type of value assigned to the variable that implements the interface.

The *static* type never changes, but the dynamic type can change by assigning a new value of a different type that implements the interface.

### Using an interface in a Func

Interface type can be used for variables, function parameters, and function results. FORE:

```go
func calcTotal(expenses []Expense) (total float64) {
	for _, item := range expenses {
		total += item.getCost(true)
	}
	return
}
```

### Using an interface for Struct Fields

Interface types can be used for struct fields, which means that fields can be assigned values of any type that implements the methods. FORE:

```go
type Account struct {
	accountNumber int
	expenses      []Expense
}

func main() {
	account := Account{
		accountNumber: 12345,
		expenses: []Expense{
			Product{"kayak", "watersports", 275},
			Service{"boat cover", 12, 89.50},
		},
	}

	for _, expense := range account.expenses {
		fmt.Println(expense.getName(), expense.getCost(true))
	}
	fmt.Println(calcTotal(account.expenses))
}
```

### Understanding the Effect of Pointer method Receivers

```go
func main() {
    product := Product{...}
    var expense Expense = product
    product.price = 100
    expense.getCost(false) // 275
}
```

So the `Product`value was just copied when it was assigned to the `Expense`variable, which means that the change to the `price`field does not affect the result from the `getCost`method. If:

```go
var expense Expense = &product
```

Using a pointer means that a reference to the `Product`value is assigned to the `Expense`variable. Note that doesn’t change the interface variable -- always `Expense`. This means that you can choose how a value assigned to an interface variable will be used.

NOTE, can **force** the use of the references by specifying pointer receivers when implementing the interface methods:

```go
func(p *Product) getName() string {...}
```

Small change means that the `Product`type no longer implements the `Expense`interface. Instead, it is the `*Product`type that implements the interface.

### Comparing Interface Values

Interface values can be compared using the operators. Note that two are considered as equality if they have the same dynamic type and all of their fields are equal. And note that the pointers are equal only if they same memory location. And interfaces equaility checks can also cause runtime errors if the dynamic type is not comparable. like:

```go
type Service struct {
    //...
    features []string
} // runtime error, comparing uncomparable type
```

### Performing Type Assertions

Interface can be useful but can present problems. A *type assertion* is use dto access the **dynamic** type of an interface value. like:

```go
for _, expense := range expenses {
    s := expense.(Service)
}
```

expense is *target*, (Service) is type.

Testing before Type assertions -- When a type assertion is used, the compiler trusts that programmers has more knowledge and knows more about the dynamic types in the code it can infer. To avoid fail, there is special form:

```go
for _, expense := range expenses {
    if s, ok := expense.(Service); ok {
        // can 
    }else {
        fmt.Println("Something went wrong")
    }
}
```

### Switching on Dynamic Types

`switch`can be used to access dynamic types -- like:

```go
for _, expense := range expenses {
    switch value := expense(type) {
    case Service:
        fmt.Println("Service")
    case *Product:
        fmt.Println("*Product")
    default:
        fmt.Println("Sth went wrong")
    }
}
```

Note that the Go compiler is smart enough to understand the relationship between values evaluated by the `switch`statement and will not allow `case`for types that do not match.

## Empty Interface

Go allows empty interface -- to represent any type. like:

```go
type Person struct {
    name, city string
}

func main(){
    var expense Expense = &Product {...}
    data := []interface {} {
        expense,
        //....
        "this is a string", 
        100, 
        true,
    }
    for _, item := range data {
        switch value := item.(type) {
        case Product:
            fmt.Println(...)
        case Service:
            //...
        case string, bool, int:
            //...
        default:
            fmt.Println("Default")
        }
    }
}
```

### Empty interface for Function Parameters

```go
func processItem(item interface{}) {
    switch value := item.(type) {
        case...
    }
}

func processItems(items ...interface{}) {
    for _, item := range items {
        switch value:= item.(type) {
            case...
        }
    }
}
```

### Creating links between Files with `ln`

Linux just allows to create links between files that look and work like normal files for the most part. inode -- which is the absolute location of a file -- Linux just allows to point more than one filename to a given inode. The result is *hard link* -- two filenames just pointing to the same file. So if edit one, other changes.

And, symlink -- is a redirect to the real file. Just can link to sth that does not exist at all.

Both have uses. Are able to delete the *original* used to create a hard link and the symlinks will still reference the original dat file. Not all file systems permit the use of hard links.

Both are created using the `ln` -- 

```sh
ln -s myfile.txt mylink # soft link
# remove -s create a hard link
# file props with l for link 
```

### Finding from an index with `locate`

`find`recursively each directory each time -- slow. `cron`job -- creates an index of all the files on your system *every night*. Searching this index is just fast.

```sh
locate myfile.txt
```

Listing with `ls`-- 

- `-a`-- hidden includes
- `-h`- human-readable sizes
- `-l`-- long listing
- `-r`Reverse roder
- `-R`Recursively list
- `-s`- shows sizes
- `--sort`-- sorts the listing

### Listing System info with `lsblk, lshw, lsmod, lspci`and `neofetch`

`lsblk`-- list the storage, or *block*, devices attached.

`lshw`-- so details of upper

`lsmod`-- list the status of modules in the kernel.

Printing the Location of a command with `which`-- The purpose of  `which` is to tell exactly which command would be executed if typed. `which mkdir`returns `/bin/mkdir`

### Downloading with `wget`

See a website with useful content that need to download to server -- cuz want to make available .. like: `wget`download files using HTTP, HTTPS, and FTP like:

```sh
wget http://releases.ubuntu.com/22.04/...iso
```

If want to copy all the content files from your existing server onto a new server -- using `-m`or `--mirror`to do:

```sh
wget http://.../files # download all of the directory you speicfy
```

Can use `wget`with and std URL syntax -- including specifying PORTS and usernames and passwords.

## Redirecting Input and Output

The shell controls the input and output of the commands it runs. FORE:

```sh
grep Perl animals
grep perl animals.txt > outfile
grep Perl animals.txt > outfile
echo There was just one match >> outfile # append

# reading from redirected stdin
wc < animals.txt
```

For `wc < animals.txt`, -- `wc`is just invoked with no args -- so reads from `STDIN` -- usually the keyboard. However, redirects stdin to come from the animals.txt file.

### Locating Programs to be Run

For the `ls`-- is an executable file in the directory `/bin`-- can verify its location with:

```sh
ls -l /bin/ls
```

So, how dows locate -- the shell consults a prearranged list of directories holds in memory. Called *search path*. The list is stored as the value of the shell varaible `PATH`.

Separated by `:`. like:

```sh
echo $PATH | tr : "\n"
```

And to locate a program in search path, use the `which`-- 

```sh
which cp
which which
# type also locates alias
type ls
type cp
```

### Environments and Initialization Files

A running shell holds a bunch of important info in variables. FORE, search path, current directory.. It would be extremely tedious to define every shell’s environment by hand. 

Is to define the environment once -- in shell scrpt called `startup`files and *initialization* files, and have every shell execute these scripts on startup.

Note the `$HOME/.bashrc`

### Viewing the Command And History

```sh
history 3 # 3 most recent
history | less # earliest to latest entry
```

Expansion !!...

### Curising the FileSystem

```sh
ps aux --sort=-%cpu
```

## Records

A `record`is a special kind of class **or** struct that is designed to work well with *immutable* data. Most useful feature is just *non-destructive* mutation. Also, useful in creating types just combine or hold data.

### Defining

Just like a class or struct, and can contain the same kinds of members, including fields, properties, methods.. By default, the underlying type of a record is a class From C# 10, can:

```cs
record Point {} // point is a class
record struct Point {} // is a struct
```

Simple can contain some init-only props and ctor perhaps like:

```cs
record Point {
    public Point(double x, double y) => (X,Y)=(x,y);
    public double X{get;init;}
    public double Y{get; init;}
}
```

Need to note that C# add sime steps –

- writes a protected *copy ctor* – nondestructive mutation needed
- Overloads the equality-related functions
- overrides the `ToString`method just like:

```cs
class Point {
    // ...
    // additional steps
    protected Point(Point orig) {
        this.X=orig.X; this.Y=orig.Y;
    }
    
    // This has a name:
    public virtual Point<Clone>$()=> new Point(this); // clone method
    //... others
}
```

### Parameter lists

A record def can also include a parameter list like:

```cs
record Point(double X, double Y) {
    //...
}
```

For this – just not `out`or `ref`.

1. writes an init-only prop per parameter
2. writes a primary ctor to populate props
3. writes a deconstructor.

Another difference, when define a parameter list, is that the compiler also generates a deconstructor like:

```cs
public void Deconstruct(out double X, out double Y) {
    X= this.X; Y=this.Y;
}
// can also be subclassed using the following syntax like:
record Point3D(double X, double Y, double Z): Point(X,Y);
```

For the compiler, emits like:

```cs
class Point3D: Point {
    public double Z{get; init;}
    public Point3D(double X, double Y, double Z): base(X,Y)=>this.Z=Z;
}
```

### Nondestructive Mutation

The most important step that the compiler performs is to write a *copy ctor*. Just using the `with`keyword – 

```cs
Point p1 = new Point(3, 3);
Point p2 = p1 with { Y=4 };
p1.Dump();p2.Dump();

record Point(double X, double Y);
```

1. the *copy ctor* clones the record
2. Then each property in the member initializer list is updated.

NOTE – if necessary, can define your own copy ctor. C# will use your definition.

### Property Validation

With explicit props, you can write validation logic into the `init`accessors –

```cs
record Point {
    CTOR;
    double _x;
    public double X {
        get=> _x;
        init {
            if(double.IsNaN(value))
                throw new ArgumentException("Cannot be NaN");
            _x = value;
        }
    }
}
```

### Primary CTORS

C# also offers a mildly useful intermediate option – if you are willing to deal with the curious semantics of primary ctors 

```cs
record Student(string ID, string LastName, string GivenName) {
    public string ID {get;}=ID;
}
```

In this, get the `ID`prop def, defining it as a read-only (instead of init-only)– preventing it from partaking in non-destructive mutation.

### Records and Equality Comparsion

Just as with the structs, anonymous types, and tuples – records provide structural equality out of the box. Note that the `==`also works with records.

## Patterns

The `is`operator also support other patterns that were introduced in recent versions of C# — like:

```cs
if(obj is string {Length:4})
```

### var pattern

is a variation of the type pattern – replace the type name with the `var` like:

```cs
bool IsJaneOrJohn(string name)=>
    name.ToUpper() is var upper && (upper=="JANET" || upper=="JOHN");
```

Constant pattern – lets you match directly to a constant, need to note that work with the `object`type like:

`if (obj is 3)`

And from 9, can use the <, >, <=… operators in a pattern –

`if(x is >100)`

# .NET 

### StringBuilder

represents a mutable string – can `Append, Insert, Remove, Replace`. Like:

```cs
StringBuilder sb = new();
for(int i=0; i<50; i++) sb.Append(i).Append(",");
```

## LINQ Queries

```cs
string[] names = {"Tom", "Dick", "Harry"};
IEnumerable<string> filteredNames= names.Where(n=>n.Length >= 4);
```

### Fluent Syntax

Is the most flexible and fundamental. like:

```cs
string[] names = { "Tom", "Dick", "Harry", "Mary", "Jay" };

(names.Where(n => n.Contains("a"))
.OrderBy(n => n.Length)
.Select(n => n.ToUpper())).Dump();
```

### Natrual Ordering

`Take, Skip, Reverse`like:

```cs
var firstTrhee = numbers.Take(3);
var lastTwo = numbers.Skip(3);
var reversed = numbers.Reverse();
```

C# also provides a synactic shortcut for writing LINQ queries – like:

```cs
var query = 
    from n in names
    where n.Contains("a")
    orderby n.Length
    select n.ToUpper();
```

Just note that the query expressions always start with a `from`clause, and end with either a `select`or `group`clause…

## Concurrency and Asynchrony

### Thead

```cs
Thread t = new Thread(WriteY);
t.Start();
void WriteY(){
    for...
}
```

Join and Sleep – Can wait for another thread to end by calling its `Join`method like:

```cs
Thread t = new Thread(Go);
t.Start();
t.Join();
```

The remedy is to move the exception handler into the method like:

```cs
new Thread(Go).Start();
void Go(){
    try{
        //...
        throw null;
    }catch(Exception ex){
        // Typically log the exception
    }
}
```

### Signaling

Sometimes, need a thread to wait until receiving notification(s) from other – calling *signaling*. And the Simplest signaling ctor is `ManualResetEvent`, and, calling `WaitOne`on a `ManualResetEvent`just blocks the current thread until another opens the signal by calling `Set()`. like:

```cs
var signal = new ManualResetEvent(false);
new Thread(()=> {
    signal.WaitOne();
    signal.Dispose();
    //...
}).Start();
Thread.Sleep(2000);
signal.Set();
```

## Tasks

For the threads, there has some limitations –

- No easy to get the return value back from a thread that you `Join`. Fore, need to set up some kind of shared field.
- Can’t tell a thread to start sth else when finished.

`Task`is just higher-level abstraction – represents a concurrent operation that *might or might not* be backed by a thread. Tasks are compositional – Can use the *thread pool* to lessen startup latency, and with `TaskCompletionSource`, can employ a callback approach that avoids threads altogether while waiting on I/O -bound operations.

### Starting

`Task.Run(()=>...)`

Just like:

`new Thread(()=>...)).Start()`

Wait – call `Wait`on a `Task`blocks until it completes and is the equivalent of calling `Join`on a thread. like:

```cs
Task task = Task.Run(()=> {
    Thread.Sleep(3000);
    //...
});
//...
task.Wait(); // blocks until task is just complete
```

long-running tasks – just like:

```cs
Task task = Task.Factory.StartNew(()=> ..., TaskCreationOptions.LongRunning);
```

### Returning Values

`Task`has a generic subclass called `Task<TResult>`, which allows a task to emit a return value. Can obtain a `Task<TResult>`by calling `Task.Run()`with a `Func<TResult>`delegate instead of an `Action`. Fore:

`Task<int> task = Task.Run(()=> {…, return 3;})`

Can just obtain the result later by querying the `Result`property – if the task hasn’t yet finished, accessing the property will block the current thread until the task just finishes:

```cs
int result = task.Result; // blocks if not already finished
result; // 3
```

In the following, create a task that uses LINQ to count the number of prime numbers in the first three million like:

```cs
Task<int> primeNumber = Task.Run(() =>
Enumerable.Range(2, 3000000).Count(n =>
Enumerable.Range(2, (int)Math.Sqrt(n) - 1).All(i => n % i > 0)));

primeNumber.Result.Dump();
```

### Exceptions

Unlike with threads, tasks conveniently propagate exceptions – if the code in your task throws an unhandled exception – that is automatically rethrow to whoever calls `Wait()`– or accesses the `Result`prop of a `Task<TResult>`.

```cs
// Start a Task that throws a NullReferenceException:
Task task = Task.Run(()=> {throw null;});
try{
    task.Wait();
}catch (AggregateException aex) {
    if(aex.InnerException is NullReferenceException)
        Console.WriteLine("null!");
    else 
        throw;
}
```

NOTE, the CLR just wraps the exception in an `AggregateException`in order to play well with parallel programming. Note, can test for a faulted without rethrowing via the `IsFaulted`, and `IsCanceled`prop of the `Task`. Note, if both return `false`, no error occurred. If `IsCanceled`is `true`, then `OperationCanceledException`thrown, if `IsFaulted`true, another type of exception thrown.

## Writing and Running unit tests

For this, added a class named `ProductTests.cs`to the test project – contains everything required to get started:

```cs
public class ProductTests
{
    [Fact]
    public void CanChangeProductName()
    {
        // Arrange
        var p = new Product { Name = "Test", Price = 1000M };

        // Act
        p.Name = "New Test Name";

        // Assert
        Assert.Equal("New Test Name", p.Name);
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
```

For this, there are 2 unit tests – The `Fact`attributge is applied to each **method** to indicate it is a test. Within the method body, a unit test follows A/A/A – 

Arrange refers to setting up the conditions for a test, *act* refers to performing test, *assert* refers to verifying that the result was the one that was expected.

For the assert section – is handled by `xUnit.net`which provides a class called `Assert`.

- `Equal(expected, result)`
- `NotEqual(expected, result)`
- `True(result), False(result)`
- `IsType(expected, result), IsNotType(expected, result)`
- `IsNull(result), IsNotNull(result)`
- `InRange(result, low, high), NotInRange(result, low, high)`
- `Throws(exception, expression)`– asserts that the specified expression throws a specific exception type.

### Isolating components for unit tests

Writing unit tests for model classes like `Product` – The situation is more complicated with other components in an Core app cuz there are some dependencies between them. The next set of tests, define will opeate on the controller, examing the sequence of `Product`object that are passed between the controller and the view. And, when comparing objects instantiated from custom classes, will need to use the `xUnit.net``Assert.Equal`method that accept implements the `IEqualityCompare<T>`interface like:

```cs
public class Comparer
{
    public static Comparer<U?> Get<U> (Func<U?, U?, bool> func)
    {
        return new Comparer<U?> (func);
    }
}

public class Comparer<T> : Comparer, IEqualityComparer<T>
{
    private Func<T?, T?, bool> comparisonFunc;

    public Comparer(Func<T?, T?, bool> func)
    {
            comparisonFunc = func;
    }

    public bool Equals(T? x, T? y)
    {
        return comparisonFunc(x, y);
    }

    public int GetHashCode([DisallowNull] T obj)
    {
        return obj?.GetHashCode() ?? 0;
    }
}
```

These will allow to create `IEqualityComparer<T>`obj using lambda rather than define a new class for ecch type of comparison that want to make.

```cs
public class HomeControllerTests
{
    [Fact]
    public void IndexActionModelIsComplete()
    {
        // Arrange
        var controller = new HomeController();
        Product[] products = new Product[]
        {
            new Product{Name="Kayak", Price=275M },
            new Product{Name="Lifejacket", Price=48.95M }
        };

        // Act
        var model = (controller.Index() as ViewResult)?.ViewData.Model
            as IEnumerable<Product>;

        // Assert
        Assert.Equal(products, model,
            Comparer.Get<Product>((p1, p2) => p1?.Name == p2?.Name &&
            p1?.Price == p2?.Price));
    }
}
```

For this, creates an array of `Product`and checks that they correspond to the ones the `Index`action method provides as the view model. This test also passes – but isn’t usful result.

### Isolating a component

The key to isolating components is to use C# interfaces – To separate the controller from the repository, added a new class called `IDataSource.cs`to Models and used it to define the interface like:

```cs
public interface IDataSource
{
    IEnumerable<Product> Products { get; }
}
```

Then modified the `Product`class – 

```cs
public class ProductDataSource : IDataSource
{
    public IEnumerable<Product> Products =>
        new Product[]
        {
            new Product {Name="Kayak", Price=275M},
            new Product{Name="Lifejacket", Price=48.95M }
        };
}
```

Next step is to modify the controller so that it uses the `ProductDataSource`class as the source for its data like:

```cs
public IActionResult Index()
{
    return View(dataSource.Products);
}
```

Then, isolating the controller in the test file like:

```cs
public class HomeControllerTests
{
    class FakeDataSource : IDataSource
    {
        public FakeDataSource(Product[] data) => Products = data;
        public IEnumerable<Product> Products { get; set; }
    }

    [Fact]
    public void IndexActionModelIsComplete()
    {
        // Arrange
        var controller = new HomeController();
        Product[] products = new Product[]
        {
            new Product{Name="Kayak1", Price=275M },
            new Product{Name="Lifejacket", Price=48.95M }
        };
        IDataSource data = new FakeDataSource(products);
        controller.dataSource= data;

        // Act
        var model = (controller.Index() as ViewResult)?.ViewData.Model
            as IEnumerable<Product>;

        // Assert
        Assert.Equal(products, model,
            Comparer.Get<Product>((p1, p2) => p1?.Name == p2?.Name &&
            p1?.Price == p2?.Price));
    }
}
```

### Understanding test-driven development

Have just followed the most commonly used unit testing style in this – in which an app feature is written and then tested to make sure it works as required. This approach is that it tends to produce unit tests that focus only on the parts of the app code that were difficult to write to that need some serious debugging.

An alternative approach is TDD – test-driven development. The core idea is that you write the tests for a feature before implementing the feature itself. This way, writing the tests first, makes you think more carefully about the specification you are implementing and, how you will know a feature has been implemented correctly. Rather than diving into the implementation detail, TDD makes you consider what the measures of success or failure will be in advance.

### Using a mocking package

It just was easy to create a fake implementation for the `IDataSource`, but for more classes for which fake are required and more complex and cannot be handled as easily.

### Creating a mock object

After installation, can use the `Moq`framework to create a fake `IDataSource`object without having to define a custom test class like:

```cs
[Fact]
public void IndexActionModelIsComplete()
{
    // Arrange
    //...

    var mock = new Mock<IDataSource>();
    mock.SetupGet(m => m.Products).Returns(products);

    controller.dataSource = mock.Object;

    // Act
    var model = (controller.Index() as ViewResult)?.ViewData.Model
        as IEnumerable<Product>;

    // Assert
    Assert.Equal(products, model,
        Comparer.Get<Product>((p1, p2) => p1?.Name == p2?.Name &&
        p1?.Price == p2?.Price));
    mock.VerifyGet(m => m.Products, Times.Once);
}
```

The first tep is to create a new instance of the `Mock`object, specifying the interface that should be implemented

`var mock = new Mock<IDataSource>();`

`mock.SetupGet(m=>m.Products).Returns(products);`

`SetupGet`just used to implement the getter for a prop – for this, is the `Products`, and `Returns`is called on the result of the `SetupGet`method to specify the result that will be returned when the prop value is read. And the `Mock`defines an `Object`prop, returns the object that implemnts the specified interface. The final Moq ->

`mock.VerifyGet(m=>m.Products, Timess.Once);`

Inspects the state of the mock object when the test has completed. This method allows to check the number of times that the `Products`prop has been read. For this, if not once, throw.

## Real Application

### Configuring the Razor view engine

```cs
@using SportsStore
@using SportsStore.Models
@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
```

The `@addTagHelpers`statement enables the built-in tag helpers, which use later to just create HTML elements that reflect configuration of the application.

### Starting the data model

Almost all projects have a data model of some sort – just like:

```cs
public class Product
{
    public long? ProductID { get; set; }

    public string Name { get; set; } = string.Empty;
    public string Description { get; set; }= string.Empty;

    [Column(TypeName ="decimal(8,2)")]
    public decimal Price { get; set; }

    public string Category { get; set; } = string.Empty;
}
```

### Installing EF core packages

```sh
install-package Microsoft.EntityFrameworkCore.Design
install-package Microsoft.EntityFrmaeworkCore.SqlServer
```

Creating the dbs context class – EF Core just provides access to the dbs through a context class. just:

```cs
public class StoreDbContext: DbContext
{
    public StoreDbContext(DbContextOptions<StoreDbContext> options) : base(options) { }
    public DbSet<Product> Products => Set<Product>();
}
```

### Configuring EF core

In the `Program.cs`file just:

```cs
builder.Services.AddDbContext<StoreDbContext>(opts =>
{
    opts.UseSqlServer(builder.Configuration["ConnectionStrings:DefaultConnection"]);
});
```

Just note that the `IConfiguration`interface provides access to the ASP.NET core configuration system.

## Classes with the `class`keyword

Classes have been part of JS – but in ES6, The finally got their own syntax with the introduction of the `class`keyword.

```js
class Range {
    constructor(from, to) {
        this.from = from;
        this.to = to;
    }

    includes(x) {
        return this.from <= x && x <= this.to;
    }

    *[Symbol.iterator]() {
        for (let x = Math.ceil(this.from); x <= this.to; x++) yield x;
    }

    toString() {
        return `(${this.from}...${this.to})`;
    }
}

let r = new Range(1, 3);
r.includes(2);
[...r];
```

Just note that the keyword `constructor`, is used to define the ctor function for the class. And the function defined is not actually named `constructor`– the `class`declaration statement defines a new variable `Range`and assigns the value of the special to that variable.

And, if want to define a class that subclasses – *inherits* from can use the `extends`keyword with the `class`like:

```js
class Span extends Range {
    constructor(start, length) {
        if (length >= 0)
            super(start, start + length);
        else
            super(start + length, start);
    }
}
[...new Span(3, 5)]
```

Can also write:

`let Square = class {constructor(x) {this.area=x*x;}};`
`new Square(3).area // 9`

### Static Methods

Can define a static method within a `class`body by prefixing the method declaration with the `static`– like:

```js
static parse(s) {
    let matches = s.match(/^\((\d+)\.\.\.(\d+)\)$/);
    if (!matches) {
        throw new TypeError(`Cannot parse Span from "${s}`);
    }
    return new Span(parseInt(matches[1]), parseInt(matches[2]));
}
```

### Getters, Setters, and other methods forms

Within a `class`body, can define getter and setter methods like that in object literals, In generally, all of the shorthand method definition allowed in object also in class.

### Public, private and static Fields

If, use the instance field initialization syntax – begins with `#`– that field will be usable within the class body but will be invisible and inaccessible to any code outside the class body. like:

```js
class Buffer {
    #size= 0;
    get size() {return this.#size;}
}
```

### Adding methods to existing Classes

Js’ prototype-based inheritance mechanism is just dynamic – an object just inherits properties from its prototype – this means that can augment Js classes simply by adding new methods to their prototype objects. like:

`Complex.prototype.conj = function() {return new Complex(this.r, -this.i);}`

### Subclasses and Prototypes

```js
function Span(start, span) {
    if(span>=0){
        this.from=start;
        this.to=start+span;
    }else{
        this.to=start;
        this.from=start+span;
    }
}

// Ensure the Span prototype inherits from the Range
Span.prototype= Object.create(Range.prototype);
Span.prototype.constructor=Span;
Span.prototype.toString= function() {...}
```

### Subclasses with `extends`and `super`

In ES6 and later, can create a superclass simply by adding an `extends`clause. FORE:

```js
class TypedMap extends Map {
    constructor(keyType, valueType, entries) {
        if (entries) // if specified, check their types
        {
            for (let [k, v] of entries) {
                if (typeof k !== keyType || typeof v != valueType) {
                    throw new TypeError("Wrong type!");
                }
            }
        }
        // initialize the superclass
        super(entries);

        // then add some subclass' types
        this.keyType = keyType;
        this.valueType = valueType;
    }

    // redefine the set() method to add type checking
    set(key, value) {
        if (this.keyType && typeof key !== this.keyType) {
            throw new TypeError("KeyType wrong!");
        }
        if (this.valueType && typeof value !== this.valueType) {
            throw new TypeError("ValueType wrong");
        }

        return super.set(key, value);
    }
}

new TypedMap("string", "number", [['one', 1]]).set("two", 2).set("three", 3);
```

### Delegation instead of inheritance

It is easier and more flexible to get that desired behavior by creating – having your class just create an instance of other classes and simply delegating to that instance as needed.

```js
class Histogram {
    constructor(){
        this.map = new Map();
    }

    count(key) { return this.map.get(key) || 0; }
    has(key) { return this.count(key) > 0; }
    get size() { return this.map.size; }
    add(key) { this.map.set(key, this.count(key) + 1); }

    delete(key) {
        let count = this.count(key);
        if (count === 1)
            this.map.delete(key);
        else if (count > 1)
            this.map.set(key, count - 1);
    }
    [Symbol.iterator]() { return this.map.keys(); }

    // other iterator methods
    keys() { return this.map.keys(); }
    values() { return this.map.values(); }
    entries() { return this.map.entries(); }
}
```

For this, all the `Histogram()`ctor does is create a `Map`object.

### Class Hierarchies and ABCs

There are some circumstances when multiple levels of subclassing are appropriate – however, end this with an extended example that demonstrates a hierarchy of classes representing different kinds of sets. Fore, defines lots of subclasses – Can define ABCs – to serve just as a common superclass for a group of related subclasses. In Js, just like:

```js
// defines a single abs method
class AbstractSet {
    has(x) { throw new Error("Abstract method!"); }
}

class NotSet extends AbstractSet {
    constructor(set) {
        super();
        this.set = set;
    }

    has(x) { return !this.set.has(x); }
    toString() {
        return `{x | x NOT_IN ${this.set.toString()}}`;
    }
}
```

### Modules In Node

In Node programming, it is normal to split programs into as many as files – In Node, *each file is an independent module* with a private namesapce. Constants, variables, functions, and classes defined in one file are private to that file unless the file **exports** them.

Node modules `import`other modules with the `require()`function, and export their public API by setting properties of the `Exports`object or replacing the `module.exports`object entirely.

### Exports in Node

Node defines a global `exports`object that is **always** defined – like:

```js
const sum = (x, y) => x + y;
const square = x => x * x;
exports.mean = data => data.reduce(sum) / data.length;
exports.stddev = function (d) {
    let m = exports.mean(d);
    return Math.sqrt(d.map(x => x - m).map(square).reduce(sum) / (d.length - 1));
}
// or using:
module.exports = {mean, stddev}; // export only the public ones
```

Often, want to define a module exports only a single function or class like:

`module.exports= class extends...`

The default `module.exports`is the same object that `exports`refers to.

```js
const mean = require("../nodeEx/some");
console.log(mean.mean([1, 2, 3, 4, 5]));
```

## Modules in ES6

ES6 add `import`and `export`keywords to js and finally supports real modularity as a core language feature.

```js
export const PI = Math.PI;
export function degreesToradians(d) {
    return d * PI / 180;
}
export class Circle {
    constructor(r) { this.r = r; }
    area() { return PI * this.r * this.r; }
}
// or just write:
export {Circle, degreeToRadians, PI};
```

### imports

just like:

`import BitSet from ‘./bitset.js’`, NOTE, for this, using the *.mjs* extension name.

```js
import { PI, degreesToradians, Circle } from './some.mjs'

let c = new Circle(5);
console.log(c.area());
```

### imports and exports renaming

like:

```js
import {render as renderImage} from './imageutils.mjs'
```

## The JS STDLIB

Some datatypes, such as numbers, strings, objects and arrays but –

- The `Set`and `Map`classes for representing sets of values and mappings from one set of values to another set of values.
- Array-like objects known as `TypedArray`that represent arrays of binary data.
- Regular expressions
- `Date`class
- `Error`class and its various subclasses
- The `JSON`object
- `Intl`obj and the classes it defines that can help localize your js programs
- `URL`-- simplifies the task of parsing and manipulating URLs
- `setTimeout()`and related functions for specifying code to be executed after a specified interval of time.

### Set class

is a collection of values – are not ordered or indexed, and do not allow duplicate. like:

```js
let s = new Set();
let t = new Set([1, s]); // set with two numbers
new Set("Mississippi");
```

And the `size`prop of a set is like the length prop of array. 

`add()`takes single arg, `delete()`only deletes a single set element at a time, returns a boolean. In practice, the most imporant is not to add or delete, but check whether a specified is a member – use `has()`method. And, set are iterable, so can convert them to arrays, and arg list like:

`[...oneDigitPrimes]`

### Map Class

Like:

```js
let n = new Map([
    ["one", 1], 
    ["tow", 2]
])
```

Note that the important methods are: `set(), get(), and has()`, also, there is `delete(), clear(), size`.

## Working with relative Units

Other units, such as `em`and `rem`, are not absolute, but *relative*.

The power of relative values – Brings *late-binding* of styles to the web page. Namely– the content and its styles are not pulled together until after the authoring of both is complete. Cuz Can’t style an element according to an ideal context – just need to specify rules that will work in any context where that element could be placed.

### Ems and rems

In CSS, 1em just means the font size of the current element – its extract value varies depending on the element you are applying it to. Fore, the ruleset specifies a font size of 16px – which just becomes the elem’s local definition for 1 em. like:

```css
.padding {
    font-size: 16px;
    padding: 1em;  /* sets padding on all sides equal to font-size */
}
```

Can define the style for boxes by specifying the padding and border radius using ems. FORE:

```html
<span class="box box-small">Small</span>
<span class="box box-large">Large</span>
```

```css
.box {
    padding: 1em;
    border-radius: 1em;
    background-color: lightgray;
}

.box-small {
    font-size: 12px;
}
.box-large{
    font-size: 18px;
}
```

So, for this, different font sie, which will define the element’s em size. This is just a powerful feature of ems – can deinfe the size of an element and then scale the entire thing up or down with a single declaration that changes the font size.

### Using ems to define font-size

When it comes to the `font-size`, ems a little differently. If declare just like: `font-size: 1.2em`, – A font size can’t equal 1.2 times itself – instead – derived form the *inherited* font size.

```html
<body>
    we love coffee
    <p class="slogan">
        we love coffee
    </p>
</body>
```

The CSS in the next specifies the body’s font size – used pixels for clarity – Like:

```css
body {
    font-size: 12px;
}
.slogan {
    font-size: 1.2em;
}
```

### EMS for Font size together with ems for other properties

What makes `ems`tricky is when use them for both font size and any other props on the same element. When do this, the browser must calculate the font size first, then uses to calcuate the other values. Both properties can have the same declared value, but will have just different computed values. Like:

```css
.slogan {
    font-size: 1.2em;
    padding: 1.2em; /*evaluate to 23.04*/
}
```

### The Shrinking Font problem

For this just like:

`ul {font-size: .8em;}`The selector targets every `<ul>`on the page, so when these lists inherit their font size from other lists, the ems compound.

One way can accomplish this is with the code like – sets the font size of the first to 0.8 – second… and so on just 1.

```css
ul {
    font-size: 0.8em;
}
ul ul {
    font-size: 1em;
}
```

### Using rems for font-size

When the browser parses an HTML, creates a representation in memory of all the elements on the page – DOM. The root node is the ancestor of all – has a special pseduo-class selector `:root`– this is equivalent to using the `html`selector.

`REM`is short for *root em*. So are relative to the root element. Can:

```css
:root {
    font-size: 1em;
}
ul {
    font-size: .8rem;
}
```

Cuz this is just relative to the root, the font size will remain constant. They offers a good middle ground between pixels and ems by providing the benefits of relative units.

### Stop thinking in pixels

When working with ems – it’s easy to get bogged down obessing over exactly how many pixels will evaluate to.

### Setting a sane default font size

`:root {font-size: 0.875em;}`

Now, desired font-size is applied to the whole page, so, only need to change it in places where the design deviates from this. Create a panel like:

```html
<div class="panel">
    <h2>
        Single-origin
    </h2>
    <div class="panel-body">
        Some text
    </div>
</div>
```

```css
.panel {
    padding: 1em;
    border-radius:0.5em;
    border: 1px solid #999;
}
.panel > h2 {
    margin-top:0; /* removes extra space from the panel top */
    font-size: 0.8rem;
}
```

### Making the panel responsive

Can use some *media queries* to change the base font size. An `@media`rule is used to specify style that will be just applied only to *certain screen sizes* or media types. This is a key component of responsive design. like:

```css
:root {
    font-size:0.75em;
}

@media (min-width: 800px) {
    :root {
        font-size: 0.875em; /* applies only to 800 px and wider */
    }
}

@media (min-width: 1200px) {
    :root{
        font-size: 1em;
    }
}
```

### Resizing a single component

Can also use ems to scale an individual component on the page. Like `<div class="panel large">`

## Viewport-relative units

viewport – The framed area in the browser window where the web page is visible. excludes the address bar, tool bar, status bar – if present.

- `vh`-- 1/100 th of **v**iewport **h**eight
- `vw`– 1/100 of width
- `vmin`– 1/100 of the smaller dimension, height or width
- `vmax`– larger dimension.

### Using vw for font size – 

fore, on a desktop monitor at 1200px, 2vw –> 24px like..

Using `calc()`function for font size – lets do basic arithmetic with two or more values. useful for combining values that are just measured in different units. The addition and subtraction operators must be surrounded by whitespaces. Like:

```css
:root {
    font-size: calc(0.5em + 1vw);
}
```

### Unitless numbers and line-height

Like `line-height, z-index, font-weight` can also use the unitless value **0** anywhere a length unit is required. And the `line-height`is unusual in that accepts both units and unitless. Should just use unitless, cuz they are inherited differently.

```css
body {
    line-height: 1.2; /* descendant elems inherit the unitless value. */
}
.about-us {
    font-size: 2em; /* line-height is 38.4 16*2em*1.2 */
}
```

if : `body {line-height: 1.2em;}`– this just calcuated to 19.2px, it’s just constant - so the child overlapped. When use a unitless number, that declared value is inherited.

```powershell
get-childitem -Force  # get all includes hidden
```

## Git Branch

In Git, a `branch`is a new/separate version of the main repository. With Git – 

- with a new branch called new-design, edit the code directly without impacting the main branch
- Create a new branch from the main called small-error-fix
- fix the unrelated error and merge the small-error-fix with the main branch.
- go back to new-design, finish the work
- merge the new-design with main.

```sh
git branch hello-world-images
git branch
git checkout hello-world-images
git add -all
git status
git commit -m "Added image"
git checkout master
```

### Emergency Branch

Now imagine that are not done, fix some error on master. For this sit, don’t want to mess with master directly – 

```sh
git checkout -b emergency-fix
git add ex1.html
git commit -m "updated ex1.html with emergency fix"
```

Now that have a fix already for `master`and need to merge the two.
