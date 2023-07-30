# Error Handling

Describe the *interface* that represetns errors, show how to create errors, and explain the different ways then can be handled -- 

- Allows exceptional conditions and failures to be represented and dealt with.
- The `error`interface is used to define error conditions, which are typically returned as function results and the `panic`function is called when an unrecoverable error occurs
- Ensure that errors are communicate to the part of the app that can best decide how serious the situation is.

## Dealing with Recoverable Errors

Go makes it easy to express exceptional conditions, which allows a function or method to indicate to the calling code that sth has gone wrong. fore:

`categories := []string {"Watersports", "Chess", "Running"}`

For this, the response from the `TotalPrice`method for the `Running`category is ambiguous. -- in this, it is easy to understand the result from its context -- Go provides a predefined interface just named `error`that provide one way to resolve this issue -- like:

```go
type error interface {
    Error() string
}
```

### Generating Errors

Functions and mtehods can express exceptional or unexpected outcomes by producing error responses, as shown:

```go
type CategoryError struct {
	requestedCategory string
}

func (e *CategoryError) Error() string {
	return "Category" + e.requestedCategory + "does not exist"
}

func (slice ProductSlice) TotalPrice(category string) (total float64,
	err *CategoryError) {
		
	productCount := 0
	for _, p := range slice {
		if p.Category == category {
			total += p.Price
			productCount++
		}
	}
	if productCount == 0 {
		err = &CategoryError{requestedCategory: category}
	}
	return
}

```

So the `CategoryError`type jsut defines an unexpected requestedCategory field, and there is a method that conforms to the `error`interface -- the signature of the `TotalPrice`method has been updated so that it returns two results -- original and an `error`. so:

```go
func main() {
	categories := []string{"Watersport", "Chess", "Running"}
	for _, cat := range categories {
		total, err := Products.TotalPrice(cat)
		if err == nil {
			fmt.Println(cat, "Total:", ToCurrency(total))
		} else {
			fmt.Println(cat, "(no such category)")
		}
	}
}
```

### Reporting Errors via Channels

If a func is being executed using a goroutine, then the only communication is just through the channel -- which means that details of any problems must be communicated alongside successful operations. It is just important to keep the error handling as simple as possible.

```go
type ChannelMessage struct {
	Category string
	Total    float64
	*CategoryError
}

func (slice ProductSlice) TotalPriceAsync(categories []string,
	channel chan<- ChannelMessage) {
	for _, c := range categories {
		total, err := slice.TotalPrice(c)
		channel <- ChannelMessage{
			c, total, err,
		}
	}
	close(channel)
}

```

So the `ChannelMessage`type just allows to communicate the pair of results required to accurately reflect the outcome from the `TotalPrice`method, which is executed asynchronously by the new method. like:

```go
func main() {
	categories := []string{"Watersport", "Chess", "Running"}

	channel := make(chan ChannelMessage, 10)

	go Products.TotalPriceAsync(categories, channel)
	for message := range channel {
		if message.CategoryError == nil {
			fmt.Println(message.Category, "Total:", ToCurrency(message.Total))
		} else {
			fmt.Println(message.Category, "(no such category)")
		}
	}
}
```

### Using the Error Convenience Functions

Note, it can be awkward to have to define data types for every type of error that an application can encounter. The `errors`package which is part of the stdlib, just provides a `New`func that returns an `error`whose content is just a `string`. And the drawback of this approach is that it creates simple errors, but has the advantage of simplicity.

```go
type ChannelMessage struct {
	Category string
	Total    float64
	CateError error
}
```

## Dealing with Unreoverable Errors

Some errors are so serious should lead to immediate termination of the application, a process known as *panicking*.

```go
if message.CateError == nil {
    //...
}else {
    panic(message.CateError)
}
```

The `panic`is invoked with an arg, can be any value that will help explain the panic. In this, the panic function just is invoked with an `error`.

Note when the `panic`is called, the execution of the enclosing function is halted, and any `defer`are performed. The panic bubbles up through the call stack -- terminating execution fo the calling func and invoking their `defer`functions.

### Recovering from Panics

Go provides the built-in `recover`which can be used to stop a panic from working its way up the call stack and terminating the program. the `recover`func must be called in code that is executed using the `defer`like:

```go
func main() {
	recoverFunc := func() {
		if arg := recover(); arg != nil {
			if err, ok := arg.(error); ok {
				fmt.Println("Error:", err.Error())
			} else if str, ok := arg.(string); ok {
				fmt.Println("message", str)
			} else {
				fmt.Println("panic recovered")
			}
		}
	}
	defer recoverFunc()

	categories := []string{"Watersport", "Chess", "Running"}

	channel := make(chan ChannelMessage, 10)

	go Products.TotalPriceAsync(categories, channel)
	for message := range channel {
		if message.CateError == nil {
			fmt.Println(message.Category, "Total:", ToCurrency(message.Total))
		} else {
			panic(message.CateError)
		}
	}
}
```

This example uses the `defer`to register a function -- which wll be just executed when the `main`has completed, even if there has been no panic. Calling `recover`returns a value if there has been a panic -- Since any value can be passed to the `panic`-- the type of the vlaue returned by the `recover`is emtpy interface -- which requires a type assertion before it can be used. For `error`and `string` just the most common type of panic arg. Can just:

```go
func main(){
    defer func(){
        if arg:= recover(); arg!=nil {
            if err, ok := arg.(error); ok {
                ...
            }else if str, ok := arg.(string); ok {
                //...
            }else{...}
        }
    }()
}
```

### Panicking after a Recovery

May recover from a panic only to realize that the situation is not recoverable after all. When this happens, can start a new panic -- either providing a new argument or reusing the variable receiving when the recover function was called.

#C44192 and code new roman

```go
func main(){
    defer func() {
        if arg:=... {
            fmt.Println("error:", err.Error())
            panic(err)
        }
    }()
}
```

### Recovering from panics in Go Routines

A panic work its way up the stack only to stop the **current** groutine, at whcih point it causes termination of the application. The restrcition means that panics must be recovered *within* the code that a goroutine executes like:

```go
func processCategories(categories []string, outChan chan<- CategoryCountMessage) {
	defer func() {
		if arg := recover(); arg != nil {
			fmt.Println(arg)
		}
	}()

	channel := make(chan ChannelMessage, 10)
	go Products.TotalPriceAsync(categories, channel)
	for message := range channel {
		if message.CateError == nil {
			outChan <- CategoryCountMessage{
				message.Category, int(message.Total),
			}
		} else {
			panic(message.CateError)
		}
	}
	close(outChan)  // if panic, this can't be executed!!!
}

func main() {
	categories := []string{"Watersport", "Chess", "Running"}
	channel := make(chan CategoryCountMessage)
	go processCategories(categories, channel)
	for message := range channel {
		fmt.Println(message.Category, "Total:", message.Count)
	}
}
```

For this, the `main`uses a goroutine to invoke the `processCategories`which panics if the `TotalPriceAsync`sends an error. The `processCategories`recovers from the panic, but it has an unexpected consequence.

For this, the problem is that recovering from an panic doesn’t resume execution of the `processCategoires`func. Means that the `close`is never called on the channel from which `main`is receiving messages. so:

```go
defer func(){
    if arg := recover(); arg!=nil {
        fmt.Println(arg)
        close(outChan)
    }
}()
```

This just prevents the deadlock -- But it does wihtout indicating to the `main`that the `processCategories`func was unalble to complete its work -- which may have some consequences. So, a better approach is to indicate this outcome through the channel before closing it. like:

```go
type CategoryCountMessage struct {
    Category      string
    Count         int
    TerminalError interface{}
}

// ...
if message.TerminalError == nil {
    fmt.Println(message.Category, "total:", message.Count)
} else {
    fmt.Println("A terminal error occurred")
}
```

## Project Setup and Enabling Modules

```sh
mkdir -p $home/code/snippetbox
```

Why is Concurrency hard? -- Concurrent code is difficult to get right. A race condition occurs when two or more operations must execute in the *correct order* -- but, the program has not been written so that this order is guaranteed to be maintained. Most of the time, this shows up in what’s called a *data race*. Where an concurrent operation attempts to read a variable while at some undetermined time, another is attempting to write the same variable like:

```go
var data int
go func() {
    data++
}()
if data==0 {
    fmt.Println(...)
}
```

Most of the time, data races are introuced cuz the developers are thinking about the problem sequentially. They assumne that cuz a line of code falls before another will just run first. Have to meticulously iterate through the possible scenarios. Sometimes find it helpful to imagine a large period of time passing between operation.

### Atomicity

When something is considered atomic -- or to have the property of atomicity -- this means that within the context that it is operating, it is indivisible, or uninterruptible. Operations that are atomic within the context of your process may not be atomic in the context of the OS. -- Operations that are atomic And operations that are atomic within the context of your machine may not be atomic within the context of your app. Namely the atomicity just can change depending on the currently defined scope.

### Memory Access Sync

Say have a data race -- two processes are attempting to acess the same area of memory and the way they are accessing the memory is not atomic. like:

```go
var data int
go func() {data++}()
if data == 0 {
    fmt.Println("0")
}else{
    fmt.Println(data)
}
```

And, there are various ways to guard your program’s critial sections -- And go has some better ideas on how to deal with this -- one way to solve this is to sync access to the memory between your critical sections. just like:

```go
func main() {
	var memoryAccess sync.Mutex
	var value int
	go func() {
		memoryAccess.Lock()
		value++
		memoryAccess.Unlock()
	}()

	memoryAccess.Lock()
	if value == 0 {
		fmt.Printf("The value is %v\n", value)
	} else {
		fmt.Printf("The value is %v\n", value)
	}
	memoryAccess.Unlock()
}

```

Anytime developers want to access the `data`-- must first call `Lock`when they are finished they call `Unlock()`.

### Begin

Docker is a platform for running applications in lightweight units called *containers*.

```sh
docker container run diamol/ch02-hello-diamol
```

The `docker container run`command tells Docker to run an application in a container. This app has already been to run in Docker and has been published on a **public site** that any one can access. And the container package is named `diamol/ch02-hello-diamol`-- Docker need to have a copy of the image locally before it can run a container using the image, And can see that in tirst output line -- `unable to find...` - then Docker just downlaods the image, and you can see downloaded.

For this, is a very simple example application -- shows the core Docker workflow -- Someone packages their app to run in a container, and then publishes it so it’s available to other users. and Docker images can be packaged to run on any computer the just supports Docker, which makes the app completely portable.

### What is a Container

Same ida as a physical container -- think of it like a box wth an application in it. Inside the box, the app seems to have a computer all to itself. The container has its own **virtual** environment, with resouces managed by Docker. And those are all virtual resources, the hostname, ip, address and filesystem are just created by Docker -- They’re logical objects that are just managed by Docker, and they are all joined together to create an environment where an app can run.

The application inside the box can’t see anything outside that box -- but the box is running on a computer, and the computer can also be running lots of other boxes -- the apps in those boxes have their own separate environments, but they all share the CPU and memory of the computer, and they all share the computer’s OS. Each container has its own computer name, IP and disk.

They fixes two conflicting problem in computing - isolation and density -- to utilize all the processor and memory that you have. VM needs to contain its own OS -- doesn’t share the oS of the computer where the VM is running. Every VM needs its own OS -- and that can use GBytes of memory and lots of CPU time -- socking up compute power that should be available for your application.

Containers give you both -- namely, each shares the OS of the computer runing the container, and that makes them extremely lightweight. Containers start qucikly and run lean, so can run many more containers than VMs on the same hardware - typically five or ten times as many -- get density, but each app is in its own container, so get isolatino too -- this is another key feature of Docker -- Efficency.

## Parameters

Sometimes convenient for the developers to define a method that can accept a variable number of arguments. just like:

```cs
static int Add(params int[] values) {}
```

When the C# compiler detects a call to a method, the compiler checks all the methods with the specified name If the compiler can't find a match, it looks for methods that have a `ParamArray`attribute to see whether the call can be satisfied. So the compiler considers this is a match, And generates code that coerces the parametrs into a `int`array.

### Const-ness

FORE in C++, it is possible to declare methods or parametrs as a constant that forbids the code in an instance method from changing any of the object's fields or prevents the code from modifying any of the objects passed into the method. For the CLR, there is not any languages including C# can offer.

## Events

- A method can register its interest in the event
- A method can unregister its interest
- Registered methods will be notified when the event occurs.

The CLR's event model is based on *delegates* -- type-safe way to invoke a callback method -- callback methods are the means by which objects receive the notifications they subscribed to.

### Desigining Type that exposes an Event

Many steps a developer must take in order to define a type that exposes one or more event members -- like:

Defining a type that will hold any additional info that should be sent to receivers of event notification -- When an event raised, - object raising event may want to pass some additional info to the objects that receiving -- This additional info needs to be encapsulated into its won class -- which typically contians a bunch of private fields along with some read-only pulbic props to expose these fields.

By **Convention** -- Classes that hold event info to be passed to the event handler (delegate) shold be derived from the `System.EventArgs`, whcih should suffixed with `EventArgs` fore:

```cs
class NewMailEventArgs : EventArgs
{
	private readonly string m_from, m_to, m_subject;

	public NewMailEventArgs(string from, string to, string subject)
	{
		m_from = from; m_to = to; m_subject = subject;
	}

	public string From => m_from;
	public string To => m_to;
	public string Subject => m_subject;
}
```

For `EventArgs`just simply serves as a base type from which other types can derive.

### Define the event Member

An event member is defined using the C# keyword `event`-- each is given accessiblity (mostly `public`) so that other code can access the event member -- type of `delegate`indicating the prototype of the method(s) that will be called, and a name -- like:

```cs
internal class MailManager {
	// Define the event member
	public event EventHandler<NewMailEventArgs> NewMail;
}
```

`NewMail`just name of this event -- type of member is `EventHandler<NewMailEventArgs>`which means that all receivers of the event notification must supply a callback method whose prototype matches that of the `EventHandler<NewMailArgs>`delegate type. Just:

`public delegate void EventHandler<TEventArgs>(object sender, TEventArgs e)`

Note -- the pattern requires the sender parameter to be of type `Object`mostly cuz of inheritance -- Namely, if `MailManger`were used a base for `SmtpMailMangager`?

Define a method responsible for raising the event to notify registered objects that the event has occurred -- By convention, the class should just define a `protected, virtual`that is called by code internally within the class, and its derived classes when the event is to be raised. this takes one parameter -- `NewMailEventArgs`includes the info passed to the object receiving the notification -- The default just simply checks if any objects have registered interest in the event and if so the event will be raised like:

```cs
protected virtual void OnnewMail(NewMailEventArgs e)
{
    // copy a reference to the delegate field into a temporary field
    EventHandler<NewMailEventArgs> temp = Volatile.Read(ref NewMail);
    // if there any methods registered notify that
    if (temp != null) temp(this, e);
}
```

Define a method that translate the input into the desired event -- Must have some method that takes some input and translate it into the raising of the event -- like:

```cs
public void SimulateNewMail(string from, string to, string subject) {
    NewMailEventArgs e = new NewMailEventArgs(from, to, subject);

    // call virtual protected method
    OnnewMail(e); // will notify all the objects that registered interest in the event
}
```

### Designing a type Listens for an Event

```cs
internal sealed class Fax
{
	// pass the MailManager object to the ctor
	public Fax(MailManager mm)
	{
		mm.NewMail += (s, e) =>
		{
			Console.WriteLine("faxing mail message:");
			Console.WriteLine($"from={e.From}, to={e.To}, subject={e.Subject}");
		}
	}

	public void Unregister(MailManager mm)
	{
		mm.NewMail -= (s, e) => { }
	}
}
```

## The Managed Heap and Garbage Collection

how managed apps construct new objects, how the managed heap controls the lifetime of these objects, and how the memory for these objects gets reclaimed -- Explain how the garbage collector in the common language runtime works.

### Managed Heap

The following steps are required to access a resouce -- 

1. Allocate memory for the type that represent the resource accomplished by using C# new operator.
2. Initialize the memory to set the initial state of the resource and to make the reource usable.
3. Use the resouce by accessing the type's members
4. Tear down the state of a resource to clean up
5. Free the memory -- the garbage collector is solely resposible for this step.

As long as using C# then it is impossible for your app to experience memory corruption -- but, It's still possible for your application to leak memory but it is not the default behavior. **Memory leaks typically occur cuz your app is storing objects in a collection and never removes objects when no longer needed**.

When consuming instances of types that require special cleanup - the programming model remains as simple as jsut described -- sometimes -- you want to clean up a resource as soon as possible.

C# 's `new`operator causes the CLR to perform the following steps -- 

1. Calcalate the number of bytes required for the type's fields
2. Add the bytes required for an object's overhead.
3. The clr then checks the bytes required to allocate the object are available in the region.

## Sessions

When using sessions, decide how to store the associated data. Core provides three options for session data storage. In-memory, SQLServer, and Redis. Note that the cache srevice created by the `AddDistributeCache()`isn't distribute and stores the session data for a single instance of the Core runtime. If scale an app by deploying multiple instances of the runtime, then should use one of the other caches.

```cs
builder.Services.AddSession(opts => {
    opts.IdleTimeout=TimeSpan.FromMinutes(30);
    opts.Cookie.IsEssntial=true;
});
```

- `Cookie`-- used to configure the session cookie.
- `IdleTimeout`-- this is used to configure the time span when expires.

Other configuration properties -- 

- `HttpOnly`-- specifies whether the browser will prevent the cookie from being included in HTTP request sent by Js code. Should be `true`for projects that use a Js app, default is `true`also.
- `SecurityPolicy`-- set security policy for the cookie using `CookieSecurityPolicy`enum.

### Using Session Data

Session data is stored in k-v pairs, where K are strings and values are strings or integers. like:

```cs
app.MapGet("/session", async context =>
{
    int counter1 = (context.Session.GetInt32("counter1") ?? 0) + 1;
    int counter2 = (context.Session.GetInt32("counter2") ?? 0) + 1;
    context.Session.SetInt32("counter1", counter1);
    context.Session.SetInt32("counter2", counter2);

    await context.Session.CommitAsync();

    await context.Response
    .WriteAsync($"Counter1: {counter1}, Counter2: {counter2}");
});
```

Note that the use of the `CommitAsync()`is optional -- but it is just a good practice to use it cuz it will throw an exception if the session data can't be stored in the cache.

## Working with HTTPS connections

Users increasingly expect web app to use HTTPs connections -- even for requests that don't contain or return sensitive data Core supports both.. just provides middleware that can force HTTP clients to use HTTPs. TLS has replaced the obsolete SSL protocol, but the term SSL has become synonymous with secure networking and is often used to refer to TLS.

### Enabling HTTPs connection

The new `applicationUrl`setting sets the URLs to which the app will respond, and HTTPs is enabled by adding the HTTPs URL to the configuration settings. And just execute:

```powershell
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

### Detecting HTTPs Requests

Requests made using HTTPs can be detected through the `HttpRequest.IsHttps`property.

` await context.Response.WriteAsync($"HTTPs request: {context.Request.IsHttps}");`

Enforcing HTTPs requests -- Core provides a middleware component that enforces the use of HTTPs by sending a redirection for requests that arrive over HTTP. Just: `app.UseHttpsRedirction()`-- add the middleware component, which appears at start pipeline so that the redirction to HTTPs occur before other componetn can short-circuit the pipeline and produce a response using regular HTTP.

### Enabling HTTP strict transprot security

One limitation of HTTPs redirection is that the user can make an initial request just using HTTP before being redirected to a secure connection, So the HTTP strict Transport Security (HSTS) protocol is intended to help mitigate this risk and works by including a header in response that tells browser to use HTTPs only. Note that the order:

```cs
builder.Services.AddHsts(opts =>
{
    opts.MaxAge = TimeSpan.FromDays(1);
    opts.IncludeSubDomains = true;
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseHsts();
}
app.UseHttpsRedirection();
```

The middleware is added to the request pipeline using the `UseHsts`. HSTS must be used with care cuz it is easy to create a siguation.

### Handling exceptions and errors

When the request pipeline is created,the `WebApplicationBuilder`obj uses the development environment to enable middleware that handles exceptions by producing HTTP response that are helpful to developers. like:

```cs
if(context.HostingEnvironment.IsDevelopment()){
    app.UseDeveloperExceptionPage();
}
```

## Working with Data

### Caching Data

In most web app, there will be some items of data that are relatively expensive to generate but are just required repeatedly -- the exact nature of the data is specific to each project, but repeatedly performing the same set of calculations can increase the resources required to host the application. To represent an expensive response, like:

```cs
public class SumEndpoint
{
    public async Task Endpoint(HttpContext context)
    {
        int count;
        int.TryParse((string?)context.Request.RouteValues["count"], out count);

        long total = 0;
        for(int i=1; i<=count; i++)
        {
            total += i;
        }

        string totalString = $"({DateTime.Now.ToLongTimeString()}: {total})";
        await context.Response.WriteAsync($"({DateTime.Now.ToLongTimeString()}: {totalString})");
    }
}
```

### Caching the data values

Core provides a service can be used to cache data values through the `IDistributeCache`interface. FORE:

```cs
public async Task Endpoint(HttpContext context, 
                           IDistributedCache cache)
{
    int count;
    int.TryParse((string?)context.Request.RouteValues["count"], out count);

    string cacheString = $"sum_{count}";
    string? totalString= await cache.GetStringAsync(cacheString);

    long total = 0;
    for(int i=1; i<=count; i++)
    {
        total += i;
    }

    totalString = $"({DateTime.Now.ToLongTimeString()}: {total})";
    await cache.SetStringAsync(cacheString, totalString,
                               new DistributedCacheEntryOptions
                               {
                                   AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(2)
                               });
    await context.Response.WriteAsync($"({DateTime.Now.ToLongTimeString()}: {totalString})");
}
```

The cache service can store only byte arrays.

### Creating the example project

```cs
public class Category
{
    public long CategoryId { get; set; }
    public required string Name { get; set; }
    public IEnumerable<Product>? Products { get; set; }
}

public class Supplier
{
    public long SupplierId { get; set; }
    public required string Name { get; set; }
    public required string City { get; set; }

    public IEnumerable<Product>? Products { get; set; }

}

public class Product
{
    public long ProductId { get; set; }
    public required string Name { get; set; }

    [Column(TypeName = "decimal(8,2)")]
    public decimal Price { get; set; }

    public long CategoryId { get; set; }
    public Category? Category { get; set; }

    public long SupplierId { get; set; }
    public Supplier? Supplier { get; set; }
}
```

Just note that the `Price`-- there is not a one-to-one mapping between C# and SQL numeric types, and the Column attribute tells EF core with SQL type should be used in the dbs to store `Price`values. Then create DbContext:

```cs
public class DataContext: DbContext
{
    public DataContext(DbContextOptions<DataContext> options) : base(options) { }

    public DbSet<Product> Products => Set<Product>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Supplier> Suppliers => Set<Supplier>();
}
```

Then Preparing the seed data like: 

```cs
public static void SeedDataBase(DataContext context ) {
    context.Database.Migrate();
    //...
    context.SaveChanges();
}
```

### Configuring Services and Middleware

```cs
builder.Services.AddDbContext<DataContext>(opts =>
{
    opts.UseSqlServer(builder.Configuration["ConnectionStrings:ProductConnection"]);
    opts.EnableSensitiveDataLogging();
});
// ...
var context=app.Services.CreateScope().ServiceProvider
    .GetRequiredService<DataContext>();
SeedData.SeedDatabase(context);
```

### When scripts run : `sync`and `deferred`

When js was fist added to browsers -- The only way that js code could affect the content of a document was to generate that content on the fly while the document was in the process of loading. By default, run the script just to be sure that it doesn't output any HTML before it can resume parsing and rendering the document.

Fortunately, this default sync or blocking execution mode is not only option -- the script can have `defer`and `async`. fore:

`<script defer src= "...js"></script>`

Both these are ways of telling the browser that the linked script do not use `document.write()`to generate HTML output, and that the browser, therefore, can continue to parse and render the document while downloading script -- The `defer`causes the browser to defer execution of script until after the document fully loaded -- The `async`causes the browser to run the script as soon as possible but does not block the document parsing while the script is being downloaded.

### Loading scripts on demand

May have js code that is not used when a document first loads and is only needed if the user takes some action like clicking on a button or opening a menu .

## The DOM

The API for working with HTML documents is known as teh DOM -- The DOM includes methods for creating new Element and Text nodes, and for inserting them into the document as children or other Element objects. There are also methods for moving elements within the document and for remving them entirely. 

Note there is a js class corresponding to each HTML tag type -- and each occurrence of the tag in a document is represented by an instance of the class -- fore, the `<body>`-- represented by `HTMLBodyElement`, and `<table>`is represented by `HTMLTableElement` -- The js element objects just have properties that corrrespond to the HTML attributes of tags. FORE -- `HTMLImageElement`which represent `<img>`tags -- have a `src`property that corresponds to the `src`attriute of the tag.

### The Global object in the Web Browsers

There is one global object per browser window or tab -- all of the js code running in that window shares this single global object -- this is true regardless of how many scripts or modules are in the document. The global is where Js' stdlib is dfined -- for, `parseInt`, `Math`and `Set`class.

In web browsers, the global object does double duty -- it also represents the current web browser window and dines properties like `history`. And `innerWidth`-- holds the window's width in pixels.

### Scripts share Namespace

Single-threaded execution means that web browsers stop responding to user input while scripts and event handlers are executing -- this places a burden on JS programmers. The web platform defines a controlled form of concurrency called a *web woker* -- is a background thread for performing computationally intensive taskes without freezing the uesr interface.

timeline -- Js programs begin in a script-execution phase and then transition to an event-handling phase -- these two can be further broken into:

1. The web browser creates a `Document`object and begins parsing the web page, adding `Element`objects and `Text`nodes to the document as it parses HTML elements and textual content. -- The `document.readyState`has the value of *loading*.
2. When the document is completely parsed, `document.readtState`is *interactive*.
3. The browser fires a `DOMContentLoaded`event on the `Document`object - this marks the transition from sync script-execution phase to the async, event-driven phase of program execution.
4. The document is completely parsed at this point -- but, browser may still be waiting for additional content, such as images, to load.

### Program Input and Output

The URL of the document being displayed is available to client-side js as `document.URL`, if you pass this string to the `URL()`ctor, can easily access thepath, query, and fragment sections of the URL.

The content of the HTTP `cookie`request header is available to client-side code as `document.cookie`-- are usually used by server-side code for maintaining user sessions.

### The web security model

The browser vendors have worked hard to balance two completing goals -- 

- Defining powerful client-side APIs to enable useful web apps
- Preventing malicious code from reading or altering your data.

Web browser's first line of defense against malicious code is that simply do not support -- FORE-- client-side js does not provide any way to write or delete arbitrary files or list arbitrary directories on the client computer. A client-side js program can just make HTTP requests, and another `WebSockets`-- defining socket-like API for communicating with specialized servers.

### Same-origin policy

This is a **sweeping** security restriction on what web content Js code can interact with. It typically comes into play when a web page includes `<iframe>`elements.

Documents loaded form different servres have jsut different origins. It's important to understand that the origin of the script itself is not relevant to the same-origin policy -- what matters is the origin of the documetn in which the script is embedded.

### Cross-site scripting

XSS is a term for category of security issues in which an attacker *injects HTML tags or scripts* into a target website.

### Literal Types

`const p = "hyper"`-- p in ts is not just any old `string`-- it's specfically the value "hyper" -- therefore, p's type is technically the more specific "hyper" just. If declare a variable as `const`and directly give it a literal value, ts will infer the variable to be that literal value as a type.

### Literal Assignability 

```tsx
let special: "Ada";
special= "Ada" //ok
special = "abc" // error
let somestring = ""; // type : string
special= somestring; // error
```

### Strict Null checking

With strict null checking enabled, Ts sees the potential crash in the code snippet like:

```tsx
let nameMaybe = Math.random()>0.5? "Tony": undefined;
nameMaybe.toLowerCase(); // error, may be undefined
```

Truthiness Narrowing -- Ts can also narrow a variable's type from a truthiness check if only some of its potential values may be truthy. like:

```js
let geneticist = Math.random()>0.5? "abc", undefined;
if(geneticist) {
    genticist.toUpperCase() ; // ok
}
```

So can use logical operators the perform truthiness checking work as well namely && and ?. operator like:

```js
geneticist && genticist.toUppercase();
gentticist?.toUppercase(); // ok.
```

### Variables without initial values

Variables declared without an initial value default to `undefined`in js. That presents an edge case in the type system. Ts just is smart enough to understand that the variable is `undefined`until a vlaue is assigned. like:

```js
let math:string;
math?.length; // error, var is used before being assigned

// but:
let math: string | undefined;
math?.length; //ok
```

### Type aliases

Most union types you will see in code will generally only have two or three constituents. May sometimes find a user for longer union types that are inconvenient to type out repeatedly. Ts includes *type* assiging easier names to reused types. like: `type myname = ...`like:

```tsx
type RawData= boolean | number | string | null | undefined;
let rawFirst: RawData;
let rawSecond: RawData;
```

Type aliases are a handy feature to use in ts whenever your types start getting complex.

### Type Aliases are not Js

Type aliases -- are note compiled to the output JS -- they exist purely in the ts type system. For ts, just will let you know with a type error if you are trying to access sth that won't exist at runtime.

### Combining Type Aliases

Type aliases may just reference other type aliases -- can sometimes be useful to have type aliases refer to other, such as when type alias is a union of types that includes the union types within another type aliases. like:

```tsx
type Id = number | string;
type IdMayb = Id | undefined | nul;
```

And also note that type aliases don't have to be declared in order of usage -- can have a type alias declared eariler in a file reference an alias declared later in the file like:

```tsx
type IdMaybe = Id | undefined | null;
type Id = number | string;
```

## Objects

Those primitives only scrach the surface of the complex object shapes Js code commonly uses.

### Object types

The object type will have the same property names and primitive types as the object's values. For the ts:

```tsx
const poet = {
    born : 1935,
    name: "Mary Oliver",
};
poet.end; // error , cuz type : {born: number; name: string;}
```

Object type are a core concept for how TS understands JS code -- every value other then `null`and `undefined`has a set of numbers in its backing type shape.

### Declaring Object types -- 

Inferring types directly from existing objects is all fine and good, but eventually you will want to be able to declare the type of an object explicitly. Object types may be described using a syntax look similar to object literals *but with types instead of values for fields*. It's the same syntax that Ts shows in error messages about type assignability. fore:

```tsx
let poetLater: { born: number; name: string };
poetLater = { born: 1935, name: "Ian" };
```

### Aliased Object types

Constantly writing out object types like -- `{born: number, name:string}`would get tiresome rather than quickly, more common to use type aliases to assign each type shape a name -- like:

```tsx
type Poet = { born: number; name: string };
let poetLater: Poet;
poetLater = { born: 1935, name: "Sara" };
```

### Structural Typing

Ts' type stystem is just *structurally typed* meaning any value that happens to satisfy a type is allowed to be used as a value of that type. In other wods, when you declare that a parameter or variable is of a particular object type, telling TS that whatever objects u use, they need have those properties.

FORE, the following `WithFirstName`and `WithLastName`only decalre a single member, fore:

```tsx
type WithFirstName= {firstName:string;};
type WithLastName = {lastName: string};
const hasBth = {firstName: "lucille", lastName: "Clifton"};
let withFirstName: WithFirstName= hasBoth; // ok
let withLastName: WithLastName= hasBoth; // also ok
```

So, structural typing not the same as `duck typing` - namely, Js is duck typed whereas TypeScript structurally typed. Cuz Duck typing is when nothing checks object types until they are used at runtime.

### Usage Checking

When providing a value to a location annotated with an object type, Ts will check that the value is assignable to that object type. If any member required on the object type is missing the object, ts will issue error. Mismatched type between two are not allowed either. And the following :

```tsx
type TimeRange = {start: Date};
const hasStartString: TimeRange = {start: "1222-02-02"}; // string is not assignable to 'Date'
```

### Excess property checking

if initial has more fields than describes ==> error:

```tsx
type poet = {born: number; name:string;};
const poetMatch: poet= {born:1928, name: "maya"}; // ok
const extra: Poet = {...activity: "walking"}; // error
```

Can :

```tsx
const existingOjbect = {
    activity:"walking",
    born, .. name:..
};
const extrabutok :poet = existingObject;
```

Cuz -- providing an existing object literal bypasses excess property checks.

### Nested object types

As Js objects can be nested as members of other objects, ts' object types must be able represent nested object types in its type system. The syntax to do so is the same as {...} object type just like:

```tsx
type Poem =
    {
        author: {
            firstName: string;
            lastName: string;
        };
        name: string;
    };
    
const poemMatch: Poem = {
    author: {
        firstName: "Sylvia",
        lastName: "Plath",
    },
    name: "Lady",
};
```

Another way of writing the `type Poem`would be extract out the `author`shape into its own aliased object type, Author. like:

```tsx
type Author= {firstName:string; lastName:string;};
type Poem = {author: Author; name:string;};
```

### Optional Properties

Object type properties don't all have to be required in the object, can include a `?`before : in a type property's type annotation to indicate that it's an optional property. like:

```tsx
type Book = {
    author?: string;
    pages: number;
};
```

Just need to keep in mind there is a difference between optional properties and properties whose type happens to include the `undfined`in a type untion. A property declared as optional with `?`just allowed not exist -- a Property declared as required and | undefined must exist. Fore, the `editor`like:

```tsx
type Writers = {
    author: string | undefined;
    editor?: string;
};

const hasRequired: Writers = {author: undefined,};
const missingRequired: Writers = {} // error
```

## Mastering Layout

CSS provides several tools you can use to control the layout of a web page. `float`-- the oldest method for laying out a web page -- and little odd.

### The purpose of floats

A *float* just pulls an element to one side of its container, allowing the document flow to wrap around it. This layout is common in ..  A floated element is removed from the normal document flow and pulled to the edge of the container. A floated element is removed from the normal document flow and pulled to the edgeo of the container. If float multiple elements in the same direction -- they will stack just alongside one another.

Actually, the example html, just includes a main element-- the white box, that contains most of the page, and four `media`object for each the gray boxes. The listing gives U the page structure -- a header and a main element that will contain the rest of the page -- inside the main element is the page title, for now, just start like:

```css
:root {
    box-sizing: border-box;
}

*, ::before, ::after{
    box-sizing: inherit;
}

body {
    background-color: #eee;
    font-family: Arial, Helvetica, sans-serif;
}

body * + * {
    margin-top: 1.5em;
}

header {
    padding: 1em 1.5em;
    color: #fff;
    background-color: #0072b0;
    border-radius: .5em;
    margin-bottom: 1.5em;
}

.main {
    padding: 0 1.5em;
    background-color: #fff;
    border-radius: .5em;
}
```

This sets some base styles for the page, including a box-sizing fix and lobotomized owl . Want to just constrain the width of the page contents. This layout is just common for centering content on a page. Can achieve it by placing your content inside two nested container and then set margins on the inner container to position it within the outer one.

```css
.container {
    max-width: 1080px;
    margin:0 auto;
}
```

Note that using the `max-width`.. Auto left and right margins will fill the available space, centering the element within the outer container.

## Container collapsing and the clearfix

A few behavior of floats still might catch you off guard -- these are not bugs, but rather floats behaving precisely how they are supposed to behave.

### understanding container collapsing

On the page, flat the media boxes to the left just like:

```css
.media {
    float:left;
    width:50%;
    padding:1.5em;
    background-color: #eee;
    border-radius: .5em;
}
```

For this, the white background stopped above the top row of media boxes -- Unlike elements in the normal document flow, floated elements **do not add height** to their parent elements. TGhis goes back to the original purposes of floats.

Floats are just intended to allow text to wrap around them -- when U float an image insdie a paragraph, the P does not grow to contain the image -- if the image is taller than the text of the P, the next P will start immediately below the text of the first. Namely, the float in one container extends into the next container, allowing text in both container to wrap around the floated element.

In page, everything inside the main element is floated except for the page title -- so only the title contributes its height to the container, leaving all the floated elements extending below the white background of the main. The main element should extend down to contain the gray boxes.

Float's companion property - `clear`, namely, if palce an element at the end of the main use `clear`, cause the container to expand to the bottom of the floats. `<div style="clear:both;"></div>` this just causes this element to move below the bottom of floated elements. Cuz this is not floated, the container will extend to encompass it.

```css
.main::after{
    content: "";
    display: block;  /*block and content cause the pseudo element to appear in the document */
    clear:both; /* expand to the bottom of flaots */
}
```

It's just important to know that the clearfix is just applied to the element that contains the floats. A common mistake is to apply it to the wrong element, such as the floats or the container after the one that contains them.
