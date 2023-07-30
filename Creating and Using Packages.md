# Creating and Using Packages

Packages are the Go feature that allows projects to be structured so that related functionality can be grouped together.

- Packages are how Go implements access controls so that the implementation of a feature can be hidden from the code that consumes it.
- Defined by creating code files in folders and using the `package`keyword to denote which package belong to.
- Only so many meaningful names, and conflicts between package names are common, requiring the use of **aliases** to avoid errors.

Understanding the Module File -- original purpose of a module file was to enable code to be published so that it can be used in other prjects like:

```sh
module packages
go 1.20
```

## Creating a custom Package

Packages make it possible to add structure to a project so that related features are grouped together. like:

```go
package store

type Product struct {
	Name, Category string
	price          float64
}
```

The name specified by the `package`should match the name of the folder -- in which the code files are created. For the `Product`type has some important differences.

### Using that

```go
import (
	"fmt"
	"packages/store"
)

func main() {
	product := store.Product{
		Name:     "Kayak",
		Category: "Watersports",
	}
	fmt.Println("Name:", product.Name)
	fmt.Println("Category:", product.Category)
}
```

`import`specifies the package as path, comprised of the name of the module created by the command. Just note the **exported** features provided by the package are accessed using the package name as a prefix like:

`var product *store.Product = &store.Product{}`

### Package Access Control

`Name`and `Category`jsut have an initial cap letter. Go just examine the first letter of the names given to the features in a code file. Fore, types, functions, methods. Lowercase can be used only within the package defines it. So -- means that an error will be generated if the `price`field is accessed outside of the `store`package.

To resolve, either export that, or just in the `store`package, provides `NewProduct()`to initialize that like:

```go
func NewProduct(name, category string, price float64) *Product {
	return &Product{name, category, price}
}

func (p *Product) Price() float64 {
	return p.price
}

func (p *Product) SetPrice(newPrice float64) {
	p.price = newPrice
}
// in the store package

// in the main
func main() {
	product := store.NewProduct("Kayak", "Watersports", 279)
	fmt.Println("Price:", product.Price())
}

```

### Adding Code files to Packages

Can just contain multiple code files.

```go
package store

const defaultTaxRate float64 = 0.2
const minThreshold = 10

type taxRate struct {
	rate, threshold float64
}

func newTaxRate(rate, threshold float64) *taxRate {
	if rate == 0 {
		rate = defaultTaxRate
	}
	if threshold < minThreshold {
		threshold = minThreshold
	}
	return &taxRate{rate, threshold}
}

func (taxRate *taxRate) calcTax(product *Product) float64 {
	if product.price > taxRate.threshold {
		return product.price + product.price*taxRate.rate
	}
	return product.price
}
```

Note all of that are unexported. Then modified the method -- like:

```go
var standardTax = newTaxRate(0.25, 20)

func (p *Product) Price() float64 {
	return standardTax.calcTax(p)
}
```

### Dealing with Name Conflicits

When package is imported, the combination of the module name and package name ensures that the package is uniquely identified. One way fore :

```go
import (
	"fmt"
    "packages/store"
    currentfmt "packages/fmt"
)
```

### A dot Import

There is a special -- *dot import* which allows a package’s features to be used *without using a prefix*. Like:

```go
import (
	//...
    . "packages/fmt"
)
func main(){
    fmt.Println(ToCurrency(...))
}
```

### Nested Packages

Packages can be defined witin others. Just like:

```go
package cart

import "packages/store"

type Cart struct {
	CustomerName string
	Products     []store.Product
}

func (cart *Cart) GetTotal() (total float64) {
	for _, p := range cart.Products {
		total += p.Price()
	}
	return
}
```

The `package`is used as within any other package. In the main.go like:

```go
func main() {
	product := store.NewProduct("Kayak", "Watersports", 279)
	cart := cart.Cart{
		CustomerName: "Alice",
		Products:     []store.Product{*product},
	}
	fmt.Println(cart.CustomerName)
	fmt.Println(cart.GetTotal())
}
```

### Package Initialization Functions

The most common use fot initialization functions is to perform calculations that are difficult to perform or that require duplication to perform like so:

```go
var categoryMaxPrices = map[string]float64{
	"Watersports": 250,
	"Soccer":      150,
	"Chess":       50,
}

func init() {
	for category, price := range categoryMaxPrices {
		categoryMaxPrices[category] = price + price*defaultTaxRate
	}
}
```

To use an initialization func -- is invoked automatically when the package is loaded and where `for`used.

### Importing a Package only for Initialization effects

Go prevent package from being imported but not used, fore, create `packages/data` like:

`import _ "packages/data"`

## Extenal Packages

Projects can be extended using packages developed by 3rd parties -- using the `go get`command like:

```sh
go get github.com/faith/color@v1.10.0
```

Then the go.mod file changed like:

```sh
module packages
go 1.20
require (
	github.com/...
)
```

## Type and Interface composition

Defining the Base Type -- The starting point is to define a struct type and a method like:

```go
package store

type Product struct {
	Name, Category string
	price          float64
}

func (p *Product) Price(taxRate float64) float64 {
	return p.price + p.price*taxRate
}

```

And cuz Go doesn’t support classes, it doesn’t support class ctor either. So a common convention is to define a ctor whose name is `New<Type>`. In the file:

```go
func main() {
	kayak := store.NewProduct("Kayak", "Watersports", 275)
	Lifejacket := &store.Product{Name: "Lifejacket", Category: "Watersports"}

	for _, p := range []*store.Product{kayak, Lifejacket} {
		fmt.Println(p.Name, p.Category, p.Price(0.2))
	}
}
```

### Composing Types

Go supports composition - rather than inheritance -- which is done by combining struct types. Just in the `store`:

```go
package store

type Boat struct {
	*Product
	Capacity  int
	Motorized bool
}

func NewBoat(name string, price float64, capacity int, motorized bool) *Boat {
	return &Boat{
		NewProduct(name, "Watersports", price), capacity, motorized,
	}
}
```

So a struct can mix regular and embedded filed types, but the embedded fields are an imporatnt part of the composition feature -- the `NewBoat`is ctor func.

```go
func main() {
	boats := []*store.Boat{
		store.NewBoat("Kayak", 275, 1, false),
		store.NewBoat("Canoe", 400, 3, false),
		store.NewBoat("Tender", 650.25, 2, true),
	}
	for _, b := range boats {
		fmt.Println("Conventional", b.Product.Name, "Direct", b.Name)
	}
}
```

Go just allows the fields of the nested type to be accessed in two ways -- conventional of nav the hierarchy of types to reach the value is required.

### Chain of Nested Types

The composition feature can be used to create complex chains of nested types -- like:

```go
package store

type RentalBoat struct {
	*Boat
	IncludeCrew bool
}

func NewRentalBoat(name string, price float64, capacity int,
	motorized, crewed bool) *RentalBoat {
	return &RentalBoat{NewBoat(name, price, capacity, motorized), crewed}
}

func main() {
	rentals := []*store.RentalBoat{
		store.NewRentalBoat("Rubber ring", 10, 1, false, false),
		store.NewRentalBoat("Yacht", 50000, 5, true, true),
	}
	for _, r := range rentals {
		fmt.Println(r.Name, r.Price(0.2))
	}
}
```

## Understanding Composition and Interfaces

Composing types make it easy to build up specilized functionality without having to dupliate the code required by a more general so that the `Boat`type in this -- can build on the functionality provided by the `Product`.

The Go compiler will not allow a `Boat`to be used as a value in a slice where `Product`values are needed. Go just takes promoted methods into account determining whehter a type conforms to an interface. FORE:

```go
type ItemForSale interface {
	Price(taxRate float64) float64
}
func main() {
	products := map[string]store.ItemForSale{
		"Kayak": store.NewBoat("Kayak", 279, 1, false), // cuz Product has a Price method
		"Ball":  store.NewProduct("Soccer Ball", "Soccer", 19.50),
	}
	for key, p := range products {
		fmt.Println(key, p.Price(0.2))
	}
}
```

Cuz the `Product`type conforms to the `ItemForSale`interface directly cuz there is a `Price`method that matches the signature specified by the interface and that has a `*Product`receiver.

### Understanding the Type Switch Limitation

Interfaces can specify only methods -- but:

```go
for k, p := range products {
    switch item := p.(type) {
    case *store.Product, *store.Boat:...
    default:...
    }
}
```

Error cuz -- item for now is just `store.ItemForSale`interface. Need:

```go
switch item:= p.(type) {
    case *store.Product:
    item.Name...
case *store.Boat:
    ...
}
```

Just, a type assertion is performed by the `case`statement when a **single** type is specified. And an alternative way to define an interface like:

```go
type Describable interface {
    GetName() string
    GetCategory() string
}

func (p *Product) GetName() string {
    return p.Name
}
func (p *Product) GetCategory() string {
    return p.Category
}
```

Then in the loop just:

```go
for key, p := range products {
    switch item := p.(type) {
        case store.Describable:
        fmt.Println(item.GetName(), item.GetCategory(), item.(store.ItemForSale).Price(0.2))
        default:
        fmt.Println(key)
    }
}
```

Just note the useness of `item.(store.ItemForSale).Price()`

### Composing Interfaces

Go allows interfaces to be composed from other interfaces like:

```go
type Descriable interface {
    GetName() string
    //...
    ItemForSale
}
```

## Expanding Your ToolBox

- *producing text* -- printing date, times, seqs of numbers, and leters, file paths, repeated strings, and other text
- *isolating text* -- extracting any part of a text file with a combination of `grep, cut, head, tail, awk`.
- *Combining text* -- with `cat, tac`, and `echo, paste`..
- *Transforming text* -- converting text into other text using simple commands, `tr, rev, awk, sed`...

### Producing Text

Every pipeline begin with a simple command that prints to stdout like:

```sh
cut -d: -f1 /etc/passwd | sort # d for delimiter
cat *.txt | wc -l  # total the number of lines
```

`date`-- prints dates and times in various formats

`seq`-- prints a sequence of numbers

*brace expansion* -- shell feature prints a seq of number or char

`find`-- prints file paths

`yes`-- prints the same line repeatedly

```sh
date
date +%Y-%m-%d
date +%H:%M:%S
date +"I cannot believe that it's already %A"

seq <start> <step> <stop>
seq -s/ 1 5 #default is newline
```

### Brace Expansion

The shell provides its own way to print a sequence of numbers, known as *brace expansion* -- like:

```sh
echo {1..10}
echo {01..10}
echo {1..1000..100} # count by 100 from 1
```

`find`command lists files in a directory recursively, descending into subdirectories and printing full paths.

```sh
find /etc -print
find . -type f -print # files only
find . -type d -print # directory only

find /etc -type f -name '*.conf' -print
find . -iname '*.txt' -print
```

`yes`command prints the same string over and over until terminated -- 

`grep`also has some hightly useful option like `-w`match whole word only. `-i`for ignore case, `-l`for names of the files.

`tail`prints the last lines of a file.

### The `awk`Command

Is a general-purpose text processor. like;

```sh
awk '{print $2}' /etc/hosts
```

Just isolate hostnames by printing the second word -- `awk`refers to any column by a `$`folowed by column number. And if more than 9, just `$(25)`, to refer entire just `$0`, note that. like:

```sh
echo Efficient fun Linux | awk '{print $1 $3}' # no wihtespace
echo Efficient fun Linux | awk "{print $1, $3}" # with space
```

```sh
df / /data | awk '{print $4}'
```

`tac`-- reverses a file line by line

```sh
cat poem1 poem2 poem3 | tac
```

`paste`combines files side by side in columns separated by a single tab character.

```sh
paste title-words1 title-words2
```

`diff`command compares two files line by line and prints a terse report like:

```sh
diff file1 file2
```

### Transforming Text

`tr`just translates one set of characters into another. like:

```sh
echo $PATH | tr : "\n" #translates colons into newlines
```

And it takes two sets of characters as arguments -- it translates members of the first set into the corresponding members of the second.

### Git staging Environment

One of the core functions of GITs is the concepts of the staging environment, and the Commit. **Staged** files are files that are ready to be **committed** to the repository you are working on. 

```sh
git add index.html
git status
git add --all  # or git add -A
```

### Git Commit

Since have finished, ready to move from `stage`to `commit`for repo.

```sh
git commit -m "First release of Hello world"
```

Commit without stage -- sometimes, make small changes, using the staging environment seems like a wate of time. possible to commit changes, skipping the staging environment.

```sh
git status --short # ?? for untracked A for added to stage, M for modified, D for deleted
git status 
git commit -a -m "updated with a new line"
git log
git commit -help
git help --all
```

### Git branch

A `branch`is a new/separate version of the main repository.

- With a new branch -- edit the code directly without impacting the main branch
- Create a new branch from the main project called small-error-fix.
- Merge the new-design branch.

```sh
git branch hello-world-images
git checkout hello-world-images
# then modify or add some files.
git status
git add --all
git commit -m "added image to hello world"

git checkout master
git merge emergency-fix
```

Since, the emergency-fix branch came directly from the master, Git sees this as a continuation of master.

## Continutations

A continuation says to a task – When finished, continue by doing sth else – is usually implemented by a callback that executes once upon completion of an operation. like:

```cs
Task<int> prime = Task.Run(() =>
 Enumerable.Range(2, 3000000).Count(n =>
 Enumerable.Range(2, (int)Math.Sqrt(n) - 1).All(i => n % i > 0)));

var awaiter = prime.GetAwaiter();
awaiter.OnCompleted(() =>
{
	int result = awaiter.GetResult();
	result.Dump();
});
```

so, Calling `GetAwaiter()`on the task returns a *awaiter* object whose `OnCompleted()`method tells the antecendent task to execute a delegate when it finishes – it’s valid to attach a continuation to an already-completed task. And also a Boolean prop called `IsCompleted`.

And, if an antecedent task faults, the exception is rethrown when the continuation code calls `awaiter.GetResult()`. There is the other way to attach a continuation is calling `ContinueWith()`method like:

```cs
prime.ContinueWith(ant=> {
	int result = ant.Result;
	result.Dump();
});
```

### TaskCompletionSource

`TaskCompletionSource`lets you create a task our of any operation that completes in the future. Works by giving a *Slave* task that you manually drive – indicating when the operation finishes or faults. It exposes a `Task`prop that returns a task upon which U can wait and attach continuations. like:

```cs
public class TaskCompletionSource<TResult> {
    public void SetResult(TResult result);
    public void SetException(Expcption ex);
    public void SetCanceled();
    //...
    public bool TrySetResult(TResult result);
    public bool TrySetException(Expception ex);
    public bool TrySetCanceled();
}
```

Calling any of these *signals* the task, putting it to a **completed, faulted, or canceled** state. like:

```cs
var tcs = new TaskCompletionSource<int>();
Task<int> task = tcs.Task;
tcs.SetResult(42);
task.Result.Dump(); //42
```

The real power of `TaskCompletionSource`is in creating tasks that don’t **tie up** threads. fore:

```cs
Task<int> GetAnswerToLife()
{
	var tcs = new TaskCompletionSource<int>();

	// create a timer 
	var timer = new System.Timers.Timer(5000) { AutoReset = false };
	timer.Elapsed += (_, _) => { timer.Dispose(); tcs.SetResult(42); };
	timer.Start();
	return tcs.Task;
}

var awaiter = GetAnswerToLife().GetAwaiter();
awaiter.OnCompleted(() => awaiter.GetResult().Dump());
```

Can also use this to write our general-purpose `Delay`method like:

```cs
Task Delay(int ms) {
    var tcs = new TaskCompletionSource<object>();
    var timer = new System.Timers.Timer(ms) {AutoReset = false;};
    timer.Elapsed += delegate {timer.Dispose(); tcs.SetResult(null);};
    timer.Start();
    return tcs.Task;
}
```

### Task.Delay

`Task.Delay(5000).GetAwaiter().OnCompleted(()=> Console.WriteLine(...))`

## Asynchrony

An *asynchronous* operation can do work after returning to the caller – 

- I/O bound concurrency
- Rich-client applications

Tasks are ideally suited to async programming.

### Async Functions in C#

The `async`and `await`keyword let you write async code that the same structure and just simplicity.

Awaiting – simplifies the attaching of continuations – like:

```cs
var result = await expression;
statement(s);
// ===>
var awaiter = expression.GetAwaiter();
awaiter.OnCompleted(()=>{
    var result = awaiter.GetResult();
    statement(s);
});

// FORE:
Task<int> GetPrimesCountAsync(int start, int count){...}
int result = await GetPrimesCountAsync(2,1000);
result.Dump();

// compile -- need add the async cuz using the await
async void DisplayPrimesCount(){
    int result = await...;
    //...
}
```

### Writing Async Functions

With any asyunc function, can replace the `void`with a `Task`to make the method itself usefully async and *awaitable*.

```cs
async Task PrintAnswerToLife(){
    await Task.Delay(5000);
    int answer = 3;
    //...
}
```

note, don’t explicitly return a task in the method body. The compiler manufactures the task, which it signals upon completion of the method. Can:

```cs
async Task Go(){
    await PrintAnswerToLife();
    //...
}
```

### Returning `Task<TResult>`

Can return this if the method body just returns sth like:

```cs
async Task<int> GetAnswerToLife(){
    await Task.Delay(5000);
    return 31;
}
```

### Parallelism

Calling an async method without awaiting it allows the code that follows to execute in parallel. Can use same principle to run two async operation in parallel like:

```cs
var task1 = Print();
var task2 = Print();
await task1; await task2;
```

So, awaiting both operations afterward, end the parallelism at that point.

### Async Lambda

Just as oridinary named methods – Can unnamed methods – like:

```cs
Func<Task> unnamed = async()=> {
    await...
};
```

### Async Streams

From C# 8 – just:

```cs
public interface IAsyncEnumerable<out T> {
    IAsyncEnumerator<T> GetAsyncEnumerator(...);
}
public interface IAsyncEnumerator<out T> : IAsyncDisposable {
    T Current {get;}
    ValueTask<bool> MoveNextAsync();
}
```

`ValueTask<T>`is a **struct** that wraps `Task<T>`and behaviorally similar to `Task<T>`while enabling more efficient execution when the task completes **synchronously**.

To generate an async stream, write a method that just combines the principles of iterators and async methods like:

```cs
async IAsyncEnumerable<int> RangeAsync (int start, int count, int delay) {
    for(int i = start; i<start+count; i++){
        await Task.Delay(delay);
        yield return i;
    }
}
```

And to consume an async stream, use the `await foreach`statement like:

`await foreach(…) Console.WriteLine…`

### IAsyncEnumerable<T> in Asp.Net Core

Controller actions can now return an `IAsyncEnumerable<T>`like:

```cs
[HttpGet]
public async IAsyncEnumerable<string> Get(){
    using var dbContext = new BookContext();
    await foreach(var title in dbContext.Books.Select(b=>b.Title).AsAsyncEnumerable())
        yield return title;
}
```

## Async and Sync Contexts

There are a couple of other more subtle ways in which such sync contexts come into play with void-returning async functions.

### Exception posting

An async function can return *before* awaiting – Consider the following – like:

```cs
static Dictionary<string, string> _cache = new();
async Task<string> GetWebPageAsync(string uri) {
    string html;
    if(_cache.TryGetValue(uri, out html)) return html;
    return _cache[uri]=
        await new WebClient().DownloadStringTaskAsync(uri);
}
```

Should a URI already exist in the cache, execution returns to the caller with no awaiting having occurred. And the method may return an **already-signaled** task.

When await a sync completed task, execution does not return to the caller and bounce back via a continuation – instead, it proceeds immediately to the next statement. And, the compiler implements this optmization by checking the `IsCompleted`prop on the awaiter – whenever u await `await GetWebPageAsync(...)`The comipler emits code to short-circuit the continuation in case of sync completion like:

```cs
var awaiter = GetWebPageAsync().GetAwaiter();
if(awaiter.IsCompleted) //...
    ;
else
    awaiter.OnCompleted(()=>);
```

Legal to write async methods that *never* await – 

`async Task<string> Foo() {return "abc";}`

Such can be useful when overriding some `virtual/abstract`methods. And, If your implementation doesn’t happen to need async. Another just using:

`Task<string> Foo() {return Task.FromResult("abc");}`

### ValueTask<T>

Is intended for micro-optimization scenarios, and U might never need to write methods that return this type – If the sync completion is due to caching .. To cache the task in all sync completion scenarios – a **fresh** task may be instantiated – this creates a potential inefficiency. Reference types may require a heap-based memory allocation and subsequent collection. That does not instantiate any reference types – adding just no burden to garbage collection – to support that pattern - the `ValueTask<T>`struct have been introduced like:

`async ValueTask<int> Foo(){…}`

Awaiting a `ValueTask<T>`is just allocation-free, if completes sync – like:

`int answer = await Foo();` // potential allocation-free

And if the operation doesn’t complete sync, the `ValueTask<T>`creates an oridinary `Task<T>`behind the scenes.

NOTE, don’t:

- Awaiting the same `ValueTask<T>`multiple times
- Calling `GetAwaiter().GetResult()`when the operation hasn’t completed.

## Async Patterns

### Cancellation

It’s often important to be able to cancel a concurrent operation after it’s started. Like:

```cs
class CancellationToken {
    public bool IsCancellationRequested{get; private set;}
    public void Cancel() {IsCancellationRequested=true;}
    public void ThrowIfCancellationRequested(){
        if(IsCancellationRequested)
            throw new OperationCanceledException();
    }
}

// Then, could write a cancellable async method as follows:
async Task Foo (CancellationToken token) {
    //...
    token.ThrowIfCancellationRequested();
}
```

When the caller want to cancel – calls the `Cancel()`method on the token – sets the `IsCancellationRequested`to true, then causes `Foo`to fault a short time later with an `OperationCanceledException`thrown.

To get a cancellation token, first, instantiate a `CancellationTokenSource`–

`var cancelSource = new CancellationTokenSource();`

For this, exposes a `Token`prop, which returns a `CancellationToken`object, LIke:

```cs
var cancelSource = new CancellationTokenSource();
Task foo = Foo(cancelSource.Token);
//...
cancelSource.Cancel();
```

And, most async methods in the CLR just support cancellation tokens, including `Delay`like:

```cs
async Task Foo(CancellationToken token) {
    //...
    await Task.Delay(5000, token);
}
```

And, sync methods can support cancellation, too, in such case, the instruction to cancel will need to come async like:

```cs
var cancelSource = new CancellationTokenSource();
Task.Delay(500).ContinueWith(ant=> cancelSource.Cancel());

try {await Foo(token);}
catch(OperationCanceledException ex) {"Canceled".Dump();}
```

### The Task-Based Async Pattern

.NET exposes async methods that can `await`. Most of these follow a pattern called `Task-based`async Pattern (TAP)

- Returns a HOT `Task`
- Has an *Async* suffix
- Is overloaded to accept a cancellation token
- Returns quickly to the caller
- Dos not ite up a thread if I/O-bound.

## Creating a Repository

The next is to create a repository interface and implementation class. It provides a consistent way to access the features presented by the dbs context class.

```cs
public interface IStoreRepository
{
    IQueryable<Product> Products { get; }
}
```

`IQueryable`is derived form the `IEnumerable`and represents a collection of objects that can be queired. And, a class that depends on the `IStoreRepository`interface can obtain `Product`objects without needing to know the details.

### Understanding the `IEnumerable`and `IQueryable`

`IQueryable<T>`allows a collection of objects to be queried **efficiently**. Using this interface allows to ask the dbs for just the objects that require using the std LINQ statements and without needing to know what dbs server stores the data or how it processes the query. Without that, have to retrieve all the `Product`objects from the dbs and then discard the ones don’t want. Care must be taken with `IQueryable`– each time the objects is enumerated, the query will be evaluated again. So, can convert that to `IEnumerable`using `ToArray`, `ToList`.

Then create repository’s class like:

```cs
public class EFStoreRepository : IStoreRepository
{
    private StoreDbContext context;
    public EFStoreRepository(StoreDbContext ctx)
    {
        context = ctx;
    }
    public IQueryable<Product> Products => context.Products;
}
```

The `Products`prop returns a `DbSet<T>`object implements the `IQueryable<T>`interface and makes it easy to implement the repository interface when using EF core. Using this Service like:

`builder.Services.AddScoped<IStoreRepository, EFStoreRepository>();`

`AddScoped()`-- Each HTTP request gets its own repository object.

### Creating the dbs migration

EF core just can generate the schema for the dbs using the data model classes through the feature named *migration*. When U prepare a migration, EF core creates a C# class that contains the SQL commands required to prepare the dbs.

```sh
add-migration Initial
```

When has finished, The project will contain a `Migrations`folder. This is where the EF core stores its migration classes.

### Creating seed data

```cs
public static class SeedData
{
    public static void EnsurePopulated(IApplicationBuilder app)
    {
        StoreDbContext context = app.ApplicationServices
            .CreateScope().ServiceProvider
            .GetRequiredService<StoreDbContext>();

        if (context.Database.GetPendingMigrations().Any())
        {
            context.Database.Migrate();
        }

        if (!context.Products.Any())
        {
            context.Products.AddRange(
                new Product
                {
                    Name = "Kayak",
                    Description =
                        "A boat for one person",
                    Category = "Watersports",
                    Price = 275
                },
                // ... other new Product...
                );
            context.SaveChanges();
        }
    }
}
```

This static `EnsurePopulated`receives an `IApplicationBuilder`arg, which is the interface used in the `Program.cs`file to just register middleware components to handle HTTP requests. The `IApplicationBuilder`just provides access to the app’s services, including EF core dbs context service. And if there are any pending migrations, call `Database.Migrate()`.

And, the final change is to seed the dbs when the app starts, which have done by adding a call to Program.cs file like:

## Displaying a list of products

The initial preparation work for an ASP.NET core can take some time – 

### Preparing the Controller

```cs
public class HomeController : Controller
{
    private IStoreRepository repository;
    public HomeController(IStoreRepository repository)
    {
        this.repository=repository;
    }

    public IActionResult Index() => View(repository.Products);
}
```

When Core needs to create a new instance of the `HomeController`class to handle an HTTP request, will inspect the ctor and see that it requires an object that implements the `IStoreRepository`interface. – This is just known as `DI`.

### Unit tests  – repository access

Can unit test that controller is accessing the repository correctly by just creating a mock repository, injecting it into constructor of the `HomeController`class, and then calling the `Index`method to get the response that contains the list of products. Then just compare the `Product`objects get to what would expect from the test data in the Mock implementation. So:

```cs
public class HomeControllerTests
{
    [Fact]
    public void Can_Use_Repository()
    {
        // Arrange
        Mock<IStoreRepository> mock = new Mock<IStoreRepository>();
        mock.Setup(m => m.Products).Returns((new Product[]
        {
            new Product {ProductID=1, Name="P1" },
            new Product {ProductID=2,Name="P2" }
        }).AsQueryable());

        HomeController controller = new HomeController(mock.Object);

        // Act
        IEnumerable<Product>? result = 
            (controller.Index() as ViewResult)?.ViewData.Model
            as IEnumerable<Product>;

        // Assert
        Product[] prodArray= result?.ToArray() ?? Array.Empty<Product>();
        Assert.True(prodArray.Length == 2);
        Assert.Equal("P1", prodArray[0].Name);
        Assert.Equal("P2", prodArray[1].Name);
    }
}
```

### Updating the View

The `Index`action method passs the collection of `Product`objects from the repository to the `View`method – which means these objects will be the view model that Razor uses when it generates HTML content from the view.

```html
@model IQueryable<Product>

@foreach (var p in Model ?? Enumerable.Empty<Product>())
{
    <div>
        <h3>@p.Name</h3>
        @p.Description
        <h4>@p.Price.ToString("c")</h4>
    </div>
}
```

### Adding Pagination

Will add some supports for pagination so that the view displays a smaller number like:

```cs
public IActionResult Index(int productPage = 1)
        => View(repository.Products
            .OrderBy(p => p.ProductID)
            .Skip((productPage - 1) * PageSize)
            .Take(PageSize));
```

Using these query string like http://localhost:5000/?productpage=2 can navigate through the catalog of products. Note there is no way for to figure out that these query string parameters exist.

### Adding the view model

To support the tag helper, going to pass info to the view about the number of pages available. The eaiest way to do this is to create a **view model** class – used to specially to pass data between a controller and a view. like:

```cs
public class PagingInfo
{
    public int TotalItems { get; set; }
    public int ItemsPerPage { get; set; }
    public int CurrentPage { get; set; }
    public int TotalPages =>
        (int)Math.Ceiling((decimal)TotalItems / ItemsPerPage);
}
```

### Adding the tag helper class

Now have a model – it’s time to create a tag helper class. like:

```cs
[HtmlTargetElement("div", Attributes ="page-model")]
public class PageLinkTagHelper:TagHelper
{
    private IUrlHelperFactory urlHelperFactory;
    public PageLinkTagHelper(IUrlHelperFactory helperFactory)
    {
        urlHelperFactory = helperFactory;
    }

    [ViewContext]
    [HtmlAttributeNotBound]
    public ViewContext? ViewContext { get; set; }

    public PagingInfo? PageModel { get; set; }

    public string? PageAction { get; set; }

    public override void Process(TagHelperContext context, TagHelperOutput output)
    {
        if(ViewContext != null && PageModel!= null)
        {
            IUrlHelper urlHelper =
                urlHelperFactory.GetUrlHelper(ViewContext);
            TagBuilder result = new TagBuilder("div");
            for (int i = 1; i <= PageModel.TotalPages; i++)
            {
                TagBuilder tag = new TagBuilder("a");
                tag.Attributes["href"] = urlHelper.Action(PageAction,
                   new { productPage = i });
                tag.InnerHtml.Append(i.ToString());
                result.InnerHtml.AppendHtml(tag);
            }
            output.Content.AppendHtml(result.InnerHtml);
        }
    }
}
```

For this, just populates a `div`element with `a`that correspond to pages of products. It’s just useful ways that can introduce C# logic into views.

### Adding the view model data

```cs
public class ProductsListViewModel
{
    public IEnumerable<Product> Products { get; set; } = Enumerable.Empty<Product>();
    public PagingInfo PagingInfo { get; set; } = new();
}
```

Then update the `Index`method – like:

```cs
public IActionResult Index(int productPage = 1)
        => View(new ProductsListViewModel
        {
            Products = repository.Products
            .OrderBy(p => p.ProductID)
            .Skip((productPage - 1) * PageSize)
            .Take(PageSize),

            PagingInfo = new PagingInfo
            {
                CurrentPage = productPage,
                ItemsPerPage = PageSize,
                TotalItems = repository.Products.Count()
            }
        });
```

```html
@model SportsStore.Models.ViewModels.ProductsListViewModel

@foreach (var p in Model.Products ?? Enumerable.Empty<Product>())
{
    <div>
        <h3>@p.Name</h3>
        @p.Description
        <h4>@p.Price.ToString("c")</h4>
    </div>
}

<div page-model="@Model.PagingInfo" page-action="Index"></div>
```

### Improving the URLs

Can create URLs that are more appealing by creating a scheme that follows the pattern of URLs. Using the Core routing systgem – like:

```cs
app.MapControllerRoute("pagination", 
    "Products/Page{productPage}", 
    new { controller ="Home", action= "Index" });

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");
```

This is the only alteration required to change the URL scheme for product pagination.

## Styling the Content

### Applying styles

```html
<div class="container">
    <div class="bg-dark text-white p-2">
        <span class="navbar-brand m-lg-2">Sports Store</span>
    </div>
    <div class="row m-1 p-1">
        <div id="categories" class="col-3">
            Put sth useful here later
        </div>

        <div class="col-9">
            @RenderBody()
        </div>
    </div>
</div>
```

Then in the index.cshtml file:.. using some tag helpers…

### Creating a partial view

*partial view* is a fragment of content that you can just embed into another view. create like:

```html
@model SportsStore.Models.ViewModels.ProductsListViewModel

@foreach (var p in Model.Products ?? Enumerable.Empty<Product>())
{
    <partial name="ProductSummary" model="p" />
}
<!-- the ProductSummary.cshtml file -->
@model Product

<div class="card card-header m-1 p-1">
    <div class="bg-gradient p-1">
        <h4>
            @Model.Name
            <span class="badge rounded-pill bg-primary text-white"
                  style="float:right;">
                <small>@Model.Price.ToString("c")</small>
            </span>
        </h4>
    </div>
    <div class="card-body p-1">@Model.Description</div>
</div>
```

## Typed Arrays and Binary Data

Typed arrays new in ES6 are much closer to lower-level arrays of those languages. – Note that they are not array – `Array.isArray()`just returns `false`for them.

- typed array are all numbers
- Must specify the length of typed array when create it, and that length can never change
- elements of those are always initialized to 0.

`Int8Array, Uint8Array, Uint8ClampedArray, Float32Array, Float64Array` fore:

```js
let bytes = new Uint8Array(1024);
let matrix = new Float64Array(9);
let point = new Int16Array(3);
let rgba = new Uint8ClampedArray(4);
```

```js
function sieve(n) {
    let a = new Uint8Array(n + 1);
    let max = Math.floor(Math.sqrt(n));
    let p = 2;
    while (p <= max) {
        for (let i = 2 * p; i <= n; i += p)
            a[i] = 1;
        while (a[++p]);
    }
    while (a[n]) n--;
    return n;
}
```

## Error classes

Js `throw`and `catch`can throw and catch any Js value, including Primtive values. Error objects have two properties – `message`and `name`and a `toString()`. Value of the `message` is the value passed to the `Error()`ctor. For `Error`, the `name`is always `Error`.

In addition, subclasses are `EvalError, RangeError, ReferenceError, SyntaxError, TypeError`and `URIError`.

Can subclass yourself like:

```js
class HTTPError extends Error {
    constructor(status, statusText, url) {
        super(`${status} ${statusText}: ${url}`);
        this.status = status;
        this.statusText = statusText;
        this.url = url;
    }
    get name() { return "HTTPError"; }
}

let error = new HTTPError(404, "Not Found", "http://notfound.com");
console.log(error.status, error.message, error.name);
```

## JSON serialization and Parsing

JS supports JSON serialization and deserialization with the two primary functions – `JSON.stringify()`and `JSON.parse()`, which – given an object or array – that doesn’t contain any non-serializable values like `RegExp`object sor typed arrays, can just serialize the object simply by passing to `JSON.stringify()` fore:

```js
let o = { s: '', n: 0, a: [true, false, null] };
let s = JSON.stringify(o);
JSON.parse(s);
```

For this, leave out the part where seriazlied data is svaed to a file or sent over network .. Can use as a deepcopy like:

```js
function deepcopy(o) {
    return JSON.parse(JSON.stringify(o));
}
```

### JSON Customizations

If need to re-create .. can pass a reviver function as the 2nd arg to `JSON.parse()`. Formatting, `Intl`object. The URL APIs – Using `URL()`ctor, passing absolute URL string as the arg. Then just various properties – `href, origin, protocol`…

### Timers

Web browsers have defined two functions – `setTimeout()`and `setInterval()`-- allow program to ask the browser to invoke a function aftger a specified amount of time has elapsed or to invoke the function repeatedly at a specified interval.

`setTimeout()`– second is a number specifies how many ms should elapse before func is invoked. like:

```js
setTimeout(()=> {console.log("ready...");}, 1000);
```

both return a value – if save this value in a variable, can use it later to **cancel** the execution of the function by passing it to `clearTimeout()`or `clearInterval()`. like:

```js
let clock = setInterval(() => {
    console.clear();
    console.log(new Date().toLocaleTimeString());
}, 1000);
setTimeout(() => { clearInterval(clock); }, 10000);
```

## Iterators and Generators

In Js, Iterable objects and their associated iterators are a feature in ES6, FORE, Arrays are iterable, so can be used in `for/of`loop. Iterators can also be used with `...`operator to expand or *spread* an iterable object into an array initializor or function invocation. And when iterate a `Map`, returned are `[key, value]`pairs.

### How Iterators Work

1. there are the iterable objects
2. there is the *iterator* object itself, which performs the iteration.
3. there is the iteration *result* that holds the result of each step of the iteration.

iterable is any obj with special iterator method that returns an iterator, and iterator is any object with a `next()`, and an iterator result is an obj with props named `value`and `done`. To iterate, first call its iterator method to get an iterator obj, then call iterator’s `next()`repeatedly until the returned value has its `done`set to `true`.

The tricky thing about this is that the iterator method of an iteratable obj does not have conventional name. but uses the `Symbol.iterator`as its names. like:

```js
let iterable = [99];
let iterator = iterable[Symbol.iterator]();
for (let result = iterator.next(); !result.done; result = iterator.next()) {
    console.log(result.value);
}
```

So, the iterator object of the built-in iterable datatypes is itself iterable. like:

```js
let list = [1, 2, 3, 4, 5];
let iter = list[Symbol.iterator]();
let head = iter.next().value;
let tail = [...iter];
console.log(head, "tail is ", tail);
```

### Implementing Iterable Objects

In order to make a class iterable, implemen a method whose name is the `Symbol.iterator` – and must return an iterator object that has a `next()`, and `next()`must return iteration result object that has a `value`and/or `done`. like:

```js
class Range {
    constructor(from, to) {
        this.from = from;
        this.to = to;
    }

    has(x) { return typeof x === "number" && this.from <= x && x <= this.to; }

    toString() { return `{x | ${this.from} <= x <= ${this.to}` };

    [Symbol.iterator]() {
        let next = Math.ceil(this.from);
        let last = this.to;
        return {
            next() {
                return (next <= last)
                    ? { value: next++ }
                    : { done: true };
            },
            [Symbol.iterator]() { return this; }
        };
    }
}

for (let x of new Range(1, 10)) console.log(x);
[...new Range(-2,2)]
```

## Generators

A *generator* is **a kind of iterator** defined with powerful new ES6 syntax. And, to create a generator, define a *generator function* – defined with the keyword `function*` – when invoke a generator function, doesn’t actually exeute the function body, but instead returns a generator object. – this generator object is just an iterator. like:

```js
function* oneDigitPrimes(){
    yield 2;
    yield 3;
    yield 5;
}
let primes = oneDigitPrimes();
primes[Symbol.iterator](); // primes
```

and the `yield*` operator , = Python’s `yield from`

## Async Javascript

Programs often have to stop computing for waiting. `Promise`new in ES6, are objects that represent the *not-yet-available* result of an async operation. `async`and `await`in ES2017 and provide new syntax that simplifies async programming by allowing to structure your Promise-based code.

### Async programming with callbacks

At its most fundamental level, async programming in Js is done with *callbacks*. Just a function that write and then pass to some other functions. That other is called when some condition is met or some event occurs. The invocation of the callback function you provide notifies you of the condition or event, and sometimes, the invocation will include function arguments that provide additional details.

### Timers

`setTimeout()`calls the specified callback one time. Can use `setInterval()`instead of `setTimeout()`. like:

```js
let updateIntervalId= setInterval(checkForUpdate, 65000);
function stopCheckingForUpdates(){
    clearInterval(updateIntervalId);
}
```

### Network Events

Client-side js programs – rather than runing some kind of predetermined computation – they typically wait for user to do sth and then respond to actions. like:

```js
let okay = document.querySelector('#confirm button.okay');
okey.addEventListener('click', applyUpdate);
```

Another common source of async in Js programming is network requests. Js running in the browser can **fetch** data from a web server with code like:

```js
function getCurrentVersionNumber(versionCallback) {
    let request = new XMLHttpRequest();
    request.open("GET", "http://www.example.com/api/version");
    request.send();
    
    // register a callback that will be invoked when the response arrives.
    request.onload = function(){
        if(request.status ===200) {
            // if http status good, get version number and call callback
            let currentVersion= parseFloat(request.responsesText);
            versionCallback(null, currentVersion);
        }else {
            // error occurred
            versionCallack(...);
        }
    };
    // register another callback that will be invoked for network errors
    request.onerror = request.ontimeout=function(e) {...}
}
```

## Custom Properties (CSS variable)

The specification introduced the concept of variables to the language, which enabled a new level of dynamic, context-based styles. Then can reference this value throughout your stylesheet.

To define, declare it much like any other CSS property – like:

```css
:root {
    --main-font: Helvetica, Arial;
}
```

This just defined a variable named `--main-font`, and sets its value – note that the name must be begin with `--`to distinguish it from CSS properties.

A function called `var()`allows the use of variables, will use this function to reference the `--main-font`varaiable just defined. Add the ruleset like:

```css
p {
    font-family: var(--main-font); /* sets the font family for paragraphs */
}
```

Custom properties let you define a value in one place – as a single source of truth. The `var()`accepts a second parameter, which sepcifies a fallback value. like:

```css
p {
    font-family: var(--main-font, sans-serif);
}
```

### Changing custom properties dynamically

Makes them interesting is that the declarations of custom properties cascade and inherit – Can define the same variable inside multiple selectors. FORE:

```html
<body>
    <div class="panel">
        <h2>Single-origin</h2>
        <div class="body">
            Some text
        </div>
    </div>

    <aside class="dark">
        <div class="panel">
            <h2>Single-origin</h2>
            <div class="body">
                some text.
            </div>
        </div>
    </aside>
</body>
```

Redefine the panel to use variables for the text and background color. Like:

```css
:root {
    --main-bg: #fff;
    --main-color: #000;
}

.panel {
    font-size: 1rem;
    padding: 1em;
    border: 1px solid #999;
    border-radius: 0.5em;
    background-color: var(--main-bg);
    color: var(--main-color);
}

.panel > h2 {
    margin-top:0;
    font-size:0.8em;
    font-weight: bold;
    text-transform: uppercase;
}
```

So, define the variables again – dark class like:

```css
.dark {
    margin-top: 2em;
    padding: 1em;
    background-color: #999;
    --main-bg: #333;
    --main-color: #eee;
}
```

In this, just defined custom properties twice – first on the `:root`and then on the `dark`container.

### Changing custom properties with JS

Custom properties can also be accessed and manipulated live in the browser using js. like:

```js
<script>
    let rootElement = document.documentElement;
    const styles = getComputedStyle(rootElement);
    const mainColor = styles.getPropertyValue('--main-bg');
    console.log(String(mainColor).trim());
</script>
```

## Mastering the box model

It’s just important to have a solid grasp on the fundamentals of how the browser sizes and positions elements.

### Difficulities with element width

```css
body {
    background-color: #eee;
    font-family: Arial, Helvetica, sans-serif;
}

header {
    color: #fff;
    background-color: #0072b0;
    border-radius: .5em;
}

main{
    display: block;  /* just for IE bug */
}

.main{
    background-color: #fff;
    border-radius: .5em;
}

.sidebar {
    padding: 1.5em;
    background-color: #fff;
    border-radius: .5em;
}
```

Next, need to put two columns in place. Just use a *float-based* layout.

```css
.main{
    float: left;
    width: 70%;
}
.sidebar {
    float: left;
    width: 30%;
}
```

Instead of the two columns sitting side by side – line wrapped. Cuz of the default behavior of the box model – when set the width or height of an element, specifying the width or height of its content – padding, border, or margins **then** added to that width. so more than 100%.

In the example, sidebar 30% plus 1.5em left and right padding.

### Avoiding magic numbers

One alternative for this to the magic number is to let the browser do the math. like: `calc(30%-3em)`

### Adjusting the box model

Instead, want your specified widths to include the padding and borders for this example. CSS allows U to adjust the box model behavior with its `box-sizing`property.

By default, `box-sizing`is set to the value of `content-box`means that any height or width you specify **only** sets the size of the content box. Can assign `border-box`instead. Using this, the two elements add up to an even 100% width.

### Using universal border-box sizing

Have made box sizing more – surely run into other elements with the same problem – It would be nice to fix once, universally for all elements. Can do this with the universal selector `*`– like:

```css
*, 
::before,
::after {
    box-sizing: border-box;
}
```

However, add 3rd-party componnents with their own CSS to your page, you may see some broken layouts. Can make this easier to do – like:

```css
:root {
    box-sizing: border-box;
}
*, 
::before,
::after {
    box-sizing: inherit;
}
```

Box sizing is not normally an inherited prop, but can use the `inherit`keyword. Then:

`.third-party-component{box-sizing: content-box;}`

### Adding a gutter between columns

If just add:

```css
.sidebar {
    width: 29%;
    margin-left: 1%;
}
```

Adds a gutter – its width is based on the outer container’s width Can also use the `calc()`function to do that like:

```css
.sidebar {
    width: calc(30% - 1.5em);
    margin-left: 1.5em;
}
```

## Difficulties with element Height

Working with element height is different – `border-box`is best to avoid setting explicit heights on elements. Normal document flow is designed to work with a constrained width and an unlimited height. Contents fill the width of the viewport and then line wraps as necessary.

*Normal document flow* refers to the default layout behavior of elements on the page – Inline flows along with the text of the page, from left to right, and line wrapping when they reach the edge of their container.

### Controlling overflow behavior

So, when explicitly set an element’s height, run the risk of its contents overflowing the container. This happens when the content doesn’t fit the specified constraint and renders outside the parent element. Document flow doesn’t account for overflow – and any content below the container will render over the top of the overflowing content.

Can control the exact behavior of the overflowing content with the `overflow`property, supports 4 values:

`visible`, `hidden`– clipped and not visible.`scroll` – added scollbar and `auto`– Scrollbars are added to only if the contents overflow.
