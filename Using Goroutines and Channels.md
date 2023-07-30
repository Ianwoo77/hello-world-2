# Using Goroutines and Channels

*goroutines* allows functions to be executed concurrently, and channels, through which goroutines can produce results asynchronously. Goroutines allow functions to be executed concurrently, without needing to deal with the complications of os threads.

The key building block for executing Go program is *goroutine* which is a lightweight thread created by the Go runtime. The runtime creates a goroutine that start executing the statements in the entry point, which is the `main`function package.

The `goroutine`executes each statement in the main function sync. go allows to create additional goroutines, which execute code at the same time as the `main`goroutine like:

```go
go group.TotalPrice(category)
```

When the Go runtime encounters the `go`keyword, creates a new goroutine and uses it to execute the specified function or method. The runtime doesn't wait for the goroutine to execute the method and immediately moves onto the next statement. Meaning that its statements are being evaluated by one goroutine at the same time that the original goroutine is executing the statements in the main function.

```go
func CalcStoreTotal(data ProductData) {
	var storeTotal float64
	var channel chan float64 = make(chan float64)
	for category, group := range data {
		go group.TotalPrice(category, channel)
	}
	for i := 0; i < len(data); i++ {
		storeTotal += <-channel
	}
	fmt.Println("Total:", ToCurrency(storeTotal))
}

func (group ProductGroup) TotalPrice(category string,
	resultChannel chan float64) {
	var total float64
	for _, p := range group {
		fmt.Println(category, "product:", p.Name)
		total += p.Price
	}
	fmt.Println(category, "subtotal:", ToCurrency(total))
	resultChannel <- total
}

```

Know the number of results that can be received from the channel exactly matches the number of goroutines I created. Channels can be safely shared between multiple goroutines, and the effect of the changes made in this section is that the Go routines created to invoke the `TotalPrice`method all send their results through the channel created by the `CalcStoreTotal`function.

The channel is used to coordinate the goroutines, allowing the `main`to wait for the individual results produced by the goroutines created in the `CalcStoreTotal`function.

## Working with Channels

By default, sending and receiving through a channel are blocking operations. This just means a gorotuine that sends a value will not execute any further statements until another goroutine receives the value from the channel. If a second goroutine sends a value, it will be blocked until the channel is cleared.

## Using a Buffered Channel

The default channel behavior can lead to bursts of activity as goroutines do their job. In a real project goroutines often have repetitive tasks to perform, and waiting for a receiver can cause a performance bottleneck. Allowing a sender to pass its value to the channel and continuing working without having to wait for a receiver.

Can see that the values sent for the `Watersports`and `Chess`categories are accepted by the channel, even though there is no receiver ready.

## Inspecting a Channel Buffer

Can use built-in `cap`function and determine *how many values are in the buffer* using `len`. `cap`always return the buffer size. and `len`returns the pending.

## Sending and Receiving an Unknown Number of Values

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)
	for {
		if details, open := <-dispatchChannel; open {
			fmt.Println("Dispatch to", details.Customer, ":", details.Quantity, "x", details.Product.Name)
		} else {
			fmt.Println("Channel has been closed")
			break
		}
	}
}
```

If the channel is open, then the closed indicator will be `false`.

## Enumerating Channel Values

A `for loop`can be used with the `range`keyword to enumerate the values sent through a channel, allowing the values to be received more easily.

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)
	for details := range dispatchChannel {
		fmt.Println("Dispatch to ", details.Customer, ":", details.Quantity,
			"x", details.Product.Name)
	}
	fmt.Println("Channel has been closed")
}
```

The `range`expression produces one value per iteration, which is the value received from the channel. The `for`will continue to receive values until the channel is closed. If use a `for...range`loop on a channel that isn't closed, in which case the loop will never exit.

## Restricting Channel Direction

By default, channels can be used to send and receive -- can be restricted when using channels as args. 

`func DispatchOrders(channel chan**<-** DispatchNotification)`This allows the `DispatchOrders`function to declare that it needs to only send messages through the channel and not receive them.

```go
func receiveDispatches(channel <-chan DispatchNotification) {
	for details := range channel {
		fmt.Println("Dispatch to:", details.Customer, ":", details.Quantity,
			"x", details.Product.Name)
	}
	fmt.Println("Channel has been closed")
}

func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	var sendOnlyChannel chan<- DispatchNotification = dispatchChannel
	var receiveOnlyChannel <-chan DispatchNotification = dispatchChannel
	go DispatchOrders(sendOnlyChannel)
	receiveDispatches(receiveOnlyChannel)
}

//...
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)
	receiveDispatches(dispatchChannel)
}
```

The `explicit`conversion for the receive-only channel requires partheses around the channel type to prevent the compiler from interpreting a conversion to the type.

## `errors.Is()`

`sql.ErrNoRows`is an example of what is known as a **sentinel error** which can defines as an `error`boj stored in an global variable.

The reason for this is that Go 1.13 introduced the ability to *wrap* errors to add additional info. And if wrapped, the the old style of checking for a match will cease to work.

```go
s := &model.Snippet{}
err := m.DB.QueryRow("SELECT...", id).Scan(&s.ID, &s.Title...)
```

## Multiple-record SQL Queries

```go
func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	stmt := `select id, title, content, created, expires from snippets
		where expires>now() order by created desc limit 10`

	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	// initialize an empty slice to hold the models.Snippets objects
	snippets := []*models.Snippet{}
	for rows.Next() {
		s := &models.Snippet{}
		err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
		if err != nil {
			return nil, err
		}

		snippets = append(snippets, s)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return snippets, nil
}
```

## Transactions and Other Details

One thing that Go doesn't do very well is managing `NULL`. Then `rows.Scan`would return an error. Set just `NOT NULL`constraints on all dbs columns.

Even if you have two calls to `Exec()`immediately to each other. -- There is no guarantee will use the same dbs connection. For the basic pattern for the transactions like:

```go
type ExampleModel struct {
    DB *sql.DB
}

func (m *ExampleModel) ExampleTransaction() error {
    tx, err := m.DB.Begin()
    if err != nil{
        return nil
    }
    
    _, err := tx.Exec("INSERT...")
    if err != nil {
        tx.Rollback()
        return err
    }
    
    _, err := tx.Exec("Update...")
    if err != nil {
        tx.Rollback()
        return err
    }
    ex = tx.Commit()
    return err
}
```

## Managing Connections

The `sql.DB`connection pool is made up of connections which are eighter *idle* or *in-use*. Can change the defaults.

## Prepared statements

The `Exec(), Query(), QueryRow()`all use prepared behind the scenes to help prevent SQL injection attacks. Inefficient -- Better approach is to make use of the `DB.Prepare()`like:

```go
type ExampleModel struct{
    DB *sql.DB
    InsertStmt *sql.Stmt
}

func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    insertStmt, err := db.Prepare("insert into...")
    if err != nil {
        return nil, err
    }
    return &ExampleModel {db, insertStmt}, nil
}

func (m *ExampleModel) Insert(args...) error {
    _, err := m.InsertStmt.Exec(args...)
    return err
}

func main(){
    db, err := sql.Open(...)
    if err!=nil {...}
    defer db.Close()
    
    exampleModel, err := NewExampleModel(db)
    if err!=nil {...}
    defer exampleModel.InsertStmt.Close()
}
```

Prepared statements exist on dbs connections. For most cases, would suggest that using the regular `Query()...`methods.

## Dynamic HTML Templates

A lightweight and type-safe way to achieve -- multiple pieces of dynamic data is to wrap your dynamic data in a struct which acts like a single *holding structure* for you

# Managed thread pool

```cs
Console.WriteLine("hello world");
ThreadPool.QueueUserWorkItem(o =>
{
	for (int i = 0; i < 20; i++)
	{
		bool isNetworkup = System.Net.NetworkInformation
		.NetworkInterface.GetIsNetworkAvailable();
		Console.WriteLine($"Is network available? answer: {isNetworkup}");
		Thread.Sleep(100);
	}
});
for (int i = 0; i < 10; i++)
{
	Console.WriteLine("Main thread working...");
	Task.Delay(500);
}

Console.WriteLine("Done");
```

## Theading and timers

For `System.Timers`namespace, `Timer`object raise an `Elapsed`event on a thread pool thread at the interval specified in the `Interval`prop. If fire only once, `AutoReset`to `true`.

```cs
Parallel.Invoke(() =>
{
	Console.WriteLine($"Hello from function");
},
()=>{
	Console.WriteLine("Hello from lambda");
},
delegate(){
	Console.WriteLine("hello from delegate.");
});
```

```cs
Parallel.ForEach(new List<int>{1, 3, 5, 7, 9}, 
number=>{
	Console.WriteLine(number);
}); // output may be 7, 1, 5, 3, 9
```

```cs
new int[] { 1, 2, 3, 5, 7, 9 }.AsParallel()
.Where(n => n % 2 == 0).ToList().ForEach(Console.WriteLine);
```

### `ConcurrencyBag<T>`

Is just a concurrent collection intended to hold a collection of unordered objects.

`ConcurrentQueue<T>`, and `ConcurrentStack<T>`

## I/O bound operations

When are working with I/O-bound code that is constrainted by file or network operations.

```cs
await GetDataAsync(@"d:\cpp\data.json").Dump();

async Task<List<string>> GetDataAsync(string filePath)
{
	using var file = File.OpenText(filePath);
	var data = await file.ReadToEndAsync();
	return data.Split(new[] { Environment.NewLine },
	StringSplitOptions.RemoveEmptyEntries).ToList();
}
```

Another example of I/O bound is a file download, can take :

```cs
async Task<List<string>> GetOnlineDataAsync(string url)
{
	var httpClient = new HttpClient();
	var data = await httpClient.GetStringAsync(url);
	return data.Split(new[] { Environment.NewLine },
	StringSplitOptions.RemoveEmptyEntries).ToList();
}
```

### CPU-bound Operations

In this case, app is not waiting for an external process to just complete.

```cs
return (await Task.WhenAll(journalTasks)).ToList();
```

## Working with Text Areas

The `textarea`element is used to solicit a large amount of text from the user and is typically used for unstructured data. The `TextAreaTagHelper`is responsible for transforming `textarea`.

`asp-for`-- This is used to specify the view model property that the `textarea`represents.

```html
<textarea class="form-control" asp-for="Supplier!.Name"></textarea>
```

## Anti-forgery Feature

The `_RequestVerificationToken`form value displayed -- is a security feature that is applied by the `FormTagHelper`to guard against cross-site request forgery. Most web apps by taking advantage of the way that user requests are typically authenticated. use cookies to identify which requests are related to a specific session.

## Enabling the Anti-forgery in a Controller

```cs
 [AutoValidateAntiforgeryToken]
    public class FormController : Controller
```

for the Razor Pages - The anti-forgery is enabled by default. `[IgnoreAntiforgeryToken]`just disabled that.

## Using Model Bindings

Is the process of creating the objects that action methods and page handlers require using data values obtained form the HTTP requests.\

is an bridge between HTTP request and action or page handler methods. The default model binders look for data in 4 places --

1. Form data
2. request body
3. routing segment variables
4. query strings

note that these is in order.

```cs
[HttpPost]
public IActionResult SubmitForm(string name, decimal price)
{
    TempData["name param"] = name;
    TempData["price param"] = price.ToString();
    return RedirectToAction(nameof(Results));
}
```

The model binding system will be used to obtain `name`and `price`values when ASP.NET core receives a request that will be processed by the `SubmitForm`method.

## Binding Simple Data Types in Razor Pages

Razor pages can use model binding, but care must be taken to ensure that the value of the form element's `name`attribute matches the name of the handler method parameter.

```html
<div class="mb-3">
    <label asp-for="Product!.Name">Name</label>
    <input asp-for="Product!.Name" class="form-control" name="name"/>
</div>
<div class="mb-3">
    <label>Price</label>
    <input class="form-control" asp-for="Product!.Price" name="price"/>
</div>
```

Note that the tag helper would have set the name attributes of the input elements.

Default Binding Values -- Uses a default value. 

The model binding process inspects the complex type and performs the binding process on each of the `public`properties it defines. Can create complete `Product`objects.

And using parameters for model binding doesn't fit with the RP development style cuz the parameters often duplicate properties defined by the page model class.

`[BindProperty]`attribute.

Bind nested -- During the model binding process, a new `Category`object is created and assigned to the `Category`property of the `Product`object -- The model binder locates the value for the `Category`prop.

## Specifying Custom Prefixes For Nexted Complex Types

```cs
[HttpPost]
public IActionResult SubmitForm(Category category)
{
    TempData["category"]=JsonSerializer.Serialize(category);
    return RedirectToAction(nameof(Results));
}
```

For this, the new parameter is a `Category`, but the model binding process won't be ablt to pick out the data value correctly -- Instead, the model binder will find the `Name`value for the `Product`object and use that instead.

```cs
[HttpPost]
public IActionResult SubmitForm(
    [Bind(Prefix ="Category")] Category category)
```

The problem is solved by applying the `Bind`attribute to the parameter and using `Prefix`arg to specify a prefix.

And for the RPs, just like:

```html
<input class="form-control" asp-for= "Product.Category.Name" />
```

```cs
[BindProperty(Name="Product.Category")]
public Category? Category{get;set;}
```

## Selective Binding Properties

```cs
[HttpPost]
public IActionResult SubmitForm(
    [Bind("Name", "Category")] Product product)
{
    TempData["name"]=product.Name;
    TempData["price"] = product.Price.ToString();  // 0, cuz without binding
    TempData["category name"] = product.Category?.Name;
    return RedirectToAction(nameof(Results));
}
```

## Selectively Binding in the Model Class

```cs
public class Product {
    //...
    [BindNever]
    public decimal Price {get;set;}
}
```

## Binding to Arrays and Collections

```cs
public class BindingsModel : PageModel
{
    [BindProperty(Name = "Data")] 
    public string[] Data { get; set; } = Array.Empty<string>();
}
```

## Modifying Objects

Just changed the `IRepository`interface to add methods. The`DbSet<Product>`returned by the dbs context's `Products`property provides the feature that need to implement the new methods.

So the `Update`method is translated into a `SQL UPDATE`command that stores the form values that have been received from the HTTP request.

## Updating Only Changed Properties

EF core just includes a change-detection feature that can work out which properties have changed. Requires a baseline.

## Performing Bulk Updates

Bulk updates are often required in applications where there are dedicated administration roles that need to make changes to multiple objects in a single operation.

## Using Change Detection for Bulk Updates

```cs
public void UpdateAll(Product[] products)
{
    Dictionary<long, Product> data = products.ToDictionary(p => p.Id);
    var baseline = _context.Products.Where(p => data.Keys.Contains(p.Id));

    foreach(var databaseProduct in baseline)
    {
        Product requestProduct = data[databaseProduct.Id];
        databaseProduct.Name = requestProduct.Name;
        databaseProduct.Category = requestProduct.Category;
        databaseProduct.PurchasePrice = requestProduct.PurchasePrice;
        databaseProduct.RetailPrice = requestProduct.RetailPrice;
    }
    _context.SaveChanges();
}
```

### Deleting Data

Is a simple process -- just..

# Objects

`typeof`checks -- In addition to direct value checking, TSC also recognizes the `typeof`operator in narrowing down variable types. like:

## Truthiness Narrowing

Tsc can also narrow a variable's type from a truthiness check if only some of its potential values may be truthy.

```tsx
type poet={
    born:number;
    name:string;
}

```

Excess property checks - trigger anywhere a new object is being created in a location that expects it to match an object type.

```tsx
type Book = {
    author? : string;
    pages: number;
};
const poem = Math.random() > 0.5
    ? { name: "The double", pages: 7 } :
    { name: "Kind", rhymes: true };
poem.pages // number | undefined
```

## Narrowing Object types

```tsx
if("pages" in poem){
    poem.pages;
}else{
    poem.rhymes;
}
```

## Discriminated Unions

```tsx
type PoemWithPages = {
    name: string;
    pages: number;
    type: "pages";
}

type PoemWithRhymes = {
    name: string;
    rhymes: boolean;
    type: 'rhymes';
}

type Poem = PoemWithPages | PoemWithRhymes;

const poem: Poem = Math.random() > 0.5
    ? { name: 'image', pages: 7, type: 'pages' }
    : { name: 'her', rhymes: true, type: 'rhymes' };
if (poem.type === 'pages')
    poem.pages;
else
    poem.rhymes;
```

Ts' | union represen the type of a value that could be one of two or more different types. Ts allows representing a type that is *multiple types* at the same time -- for `&`intersection type like:

```tsx
type Artwork = {
    genre: string;
    name: string;
}
type Writing = {
    pages: number;
    name: string;
}
type WrittenArt = Artwork & Writing;
const wa: WrittenArt = {
    name: 'abc', pages: 17, genre:'sss'
}
```

## never

Intersection types are also easy to misuse. `type NoPossible=number & string`

As with variables, TS allows you to declare the type of function parameters with a type annotation. Unlike JS, which allows functions to be called with any number of args. TSC assumes that all parameters declared on a function are just required. 

### Optional Parameters 

`?`before `:`. Its type is just `string|undefined`.

```tsx
function announceSong(song:string, singer?:string){}
```

### Default Parameters

```tsx
function rateSong(song:string, rating=0)
```

### rest parameters

```tsx
function singAllTheSongs(singer: string, ...songs: string[]) {
    for (const song of songs) {
        console.log(`${song} by ${singer}`);
    }
}
singAllTheSongs('alica keys'); // ok note
singAllTheSongs('Lady Gaga', 'bad romance', 'Just Dance');
```

### Return Types

If tsc understands all the possible values returned by a func, know it. If a func contains multiple return statements with different values, tsc will infer the return type.

### Explicit Return Types

generally recommend not to explicitly declare the return types. But:

* enforce functions with many possible returned values always return the same type
* for recursive func
* speed up Ts type checking...

```ts
function singSongRecursive(songs: string[], count = 0): number {
    return songs.length ? singSongRecursive(songs.slice(1), count + 1) : count;
}

function getSongRecordingDate(song: string): Date | undefined {
    switch (song) {
        case "Strange Fruit":
            return new Date("April 20, 1939");
        case "GreensLeeves":
            return "unknown"; //error
        default:
            return undefined; //ok
    }
}
```

## Function types

Function types syntax looks like an arrow function. But with a type instead of the body like:

```ts
let nothingInGivesString: ()=>string;
let inputAndOutput: (songs:string[], count?:number)=>number;
```

## Never Returns

Some functions not only don't return a value, but aren't meant to return at all like:

```tsx
function fail(message: string): never {
    throw new Error(message);
}
function workWithUnsafeParam(param: unknown) {
    if (typeof param !== 'string') {
        fail(`param should be string`);
    }
    param.toUpperCase(); //ok
}
```

## Function Overloads

```tsx
function createDate(timestamp: number): Date;
function createDate(month: number, day: number, year: number): Date;

function createDate(monthOrTimestamp: number, day?: number, year?: number) {
    return day === undefined || year === undefined
        ? new Date(monthOrTimestamp)
        : new Date(year, monthOrTimestamp, day);
}

console.log(createDate(7, 27, 1988));
console.log(createDate(554356800));
```

For this, as with other type system syntaxes, are jus erased when compiling Ts to output js.

For the single-page -- The initial HTML document is never reloaded or replaced.

```sh
ng new todo --routing false --style css --skip-git --skip-tests
```

```tsx
export class TodoItem {
  constructor(public task: string, public complete: boolean = false) {
  }
}
```

The `export`relates to js modules. The class defines a ctor that receives two parameters, named `task`and `complete`-- the values of these parameters are assigned to `public`of the same names.

The `flex`property controls the size of the flex items along the main axis.

`flex:2`is equivalment to `flex:2 1 0%`.

`flex-directoin:column`causes the flex items to stack vertically instead. `row, row-reverse`,

```css
.login-form h3 {
    margin: 0;
    font-size: .9em;
    font-weight: bold;
    text-align: right;
    text-transform: uppercase;
}

.login-form input:not([type=checkbox]):not([type=radio]) {
    display: block;
    width: 100%;
    margin-top: 0;
}

.login-form button {
    margin-top: 1em;
    border: 1px solid #cc6b5a;
    background-color: white;
    padding: .5em 1em;
    cursor: pointer;
}
```

```css
.centered {
    text-align: center;
}

.cost {
    display:flex;
    justify-content: center;
    align-items: center;
    line-height: .7;
}

.cost > span {
    margin-top:0;
}

.cost-currency {
    font-size:2rem;
}

.cost-dollars {
    font-size: 4rem;
}

.cost-cents {
    font-size: 1.5rem;
    align-self: flex-start;
}

.cta-button {
    display:block;
    background-color: #cc6b5a;
    color:white;
    padding: .5em 1em;
    text-decoration: none;
}
```

```css
.grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    grid-gap: 0.5em;
}

.grid > * {
    background-color: darkgray;
    color:white;
    padding: 2em;
    border-radius: .5em;
}
```

```html
<div class="inputcontainer">
	<mat-form-field class="fullwidth">
		<mat-label style="padding-left: 5px;">New To Do</mat-label>
		<input matInput placeholder="Enter to-do description" #todoText>
		<button matSuffix mat-raised-button color="accent" class="addButton"
				(click)="addItem(todoText.value); todoText.value=''">
			Add
		</button>
	</mat-form-field>
</div>
```

