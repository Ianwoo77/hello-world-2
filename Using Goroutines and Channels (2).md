# Using Goroutines and Channels (2)

Go has excellent support for writing concurernt applications, using features that are simpler and more intuitive than other languages -- Use of *goroutines* -- allow functions to be executed concurrently, and *channels*, thorugh which goroutines can produce results asynchronously --

- Goroutines are light-wieght threads created and manged by the Go runtime. Channels are pipes that carry values of a specific type.
- Goroutines allow functions to be executed concurrently, without needing to deal with the complications of OS threads. Channels allow goroutines to produce results async.
- `go`keyword - -and channels are defined as data types.

```go
package main

import "strconv"

type Product struct {
	Name, Category string
	Price          float64
}

var ProductList = []*Product{
	{"Kayak", "Watersport", 279},
	{"Lifejacket", "Watersport", 49.95},
	{"Soccer Ball", "Soccer", 19.50},
	{"Corner Flags", "Soccer", 34.95},
	{"Stadium", "Soccer", 79500},
	{"Thinking Cap", "Chess", 16},
	{"Unsteady Chair", "Chess", 75},
	{"Bling-Bling King", "Chess", 1200},
}

type ProductGroup []*Product

type ProductData = map[string]ProductGroup

var Products = make(ProductData)

func ToCurrency(val float64) string {
	return "$" + strconv.FormatFloat(val, 'f', 2, 64)
}

func init() {
	for _, p := range ProductList {
		if _, ok := Products[p.Category]; ok {
			Products[p.Category] = append(Products[p.Category], p)
		} else {
			Products[p.Category] = ProductGroup{p}
		}
	}
}

```

Then, add a file named to the `concurrency`folder with:

```go
package main

import "fmt"

func CalcStoreTotal(data ProductData) {
	var storeTotal float64
	for category, group := range data {
		storeTotal += group.TotalPrice(category)
	}
	fmt.Println("Total:", ToCurrency(storeTotal))
}

func (group ProductGroup) TotalPrice(category string) (total float64) {
	for _, p := range group {
		total += p.Price
	}
	fmt.Println(category, "subtotoal:", ToCurrency(total))
	return
}
```

## Understanding how Go executes Code

The key building block for executing a Go program is the *goroutine* -- which is a lightweight thread created by the Go runtime -- All go programs just use at least one cuz this is how Go Executes the code in the `main`funcition. The `goroutine`executes each statement in the main function *synchronously*, means that it waits for the statement to complete before moving on to the next statement.

Adding statement in the operations.go file  -- 

### Creating additional Goroutines

Go allows the developer to create additional goroutines which execute code at the same time as the `main`goroutine.

```go
for category, group := range data {
    go group.TotalPrice(category)
}
```

When go runtime encounters the `go`keyword, just creates a new goroutine and uses it to execute the specified function or method. This statement just tells the runtime to execute the statements in the `TotalPrice`method using a new goroutine -- but, the runtime doesn’t wai for the goroutine to execute the method and immediately moves onto the next statement. The result is the program terminates before the goroutines are created to execute the `TotalPrice`method complete, whcih is why there .

```go
CalcStoreTotal(Products)
time.Sleep(5 * time.Second)
```

In this case, will just pause the execution of the `main`, which will give the goroutines created time to execute the `TotalPrice`method.

It is difficult to be sure that the goroutines are working concurrently. This is cuz the example is simple.

### Returning Results from Goroutines

When created goroutines, originally, `storeTotal += group.TotalPrice(category)`, So getting a result from a function that is being executed async can be complicated cuz it requires coordination between the groutines.

To address this issue, just provides *Channels* -- conduits through which data ca be sent and received. Like:

```go
func (group ProductGroup) TotalPrice(category string, resultChannel chan float64) {
	var total float64
	for _, p := range group {
		fmt.Println(category, "product:", p.Name)
		total += p.Price
	}
	fmt.Println(category, "subtotoal:", ToCurrency(total))
	resultChannel <- total
}
```

The other change demonstrates how a result is sent using the channel -- the channel is specified, followed by the direction arrow like: `resultChannel <- total` -- sends the `total`value through the `resultChannel`channel, which makes it available to be received elsewhere in the application.

Receiving a result using a channel -- 

```go
for category, group := range data {
    go group.TotalPrice(category,channel)
}

for i:=0; i<len(data); i++ {
    storeTotal += <-channel
}
```

The arrow is placed like this received value can be used as part of any std go expression. So, channels can be safely shared between multiple goroutines, and the effect of the changes made in this is that the Go routines created to invoke the `TotalPrice`all through the channel.

## Working with Channels

By default, sending and receiving through a channel are **blocking** operations. This means that a goroutine sends a value will not execute any further statements until another goroutine receives the value from the channel -- and if a second goroutine sends a value, it will be block until the channel is cleared, causing a queue of goroutines waiting for values to be received.

```go
for i := 0; i < len(data); i++ {
    fmt.Println("-- channel reading pending --")
    value := <-channel
    fmt.Println("-- channel read complete", value)
    storeTotal+=value
    time.Sleep(time.Second)
}
```

### Using a buffered Channel

The default channel behavior can lead -- followed by a long period waiting for message to be received. In a real project goroutines often have repetitive tasks to perform, and wating for a receiver can cause performance bottleneck. So an alternative approach is to create a channel with a buffer, which is used to accept values from a sender and store them until the receiver becomes available.

`var channel chan float64 = make(chan float64, 2)`

For this, jsut have set the size of the buffer to 2 -- meaning two senders will be able to send value through the channel *without having to wait for them to be received*. Any subsequent senders will have to wait until one of the buffered messages is received. Can see this by compiling and executing the project like: In real projects, a larger buffer is used, chosen so that there is sufficient cap for goroutines to send messages without having to wait. fore, 100 is generally large enough for most projects.

### Inspecting a Channel Buffer

Can determine the size of a channel’s buffer using the built-in `cap`and determine how many values are in the buffer using the `len`like:

```go
fmt.Println(len(channel), cap(channel))
fmt.Println("-- channel read pending,",
            len(channel), "items in buffer, size", cap(channel))
```

Using the `len`and `cap`can give insight into the channel buffer, but the results should not be used to try to avoid blocking when sending a message.

### Sending and receiving an Unknown Number of Values

The `calcStoreTotal`function just uses its knowledge of the data that is being processed to determine how many times it should receive vlaues from the channel. This kind of insight isn’t always available, and the number of values that will be sent to a channel is often not known in advance.

```go
type DispatchNotification struct {
	Customer string
	*Product
	Quantity int
}

var Customers = []string{"Alice", "Bob", "Charlie", "Dora"}

func DispatchOrders(channel chan DispatchNotification) {
	rand.Seed(time.Now().UTC().UnixNano())
	orderCount := rand.Intn(3) + 2
	fmt.Println("Order Count:", orderCount)
	for i := 0; i < orderCount; i++ {
		channel <- DispatchNotification{
			Customer: Customers[rand.Intn(len(Customers)-1)],
			Quantity: rand.Intn(10),
			Product:  ProductList[rand.Intn(len(ProductList)-1)],
		}
	}
}
```

For this, the `DispatchOrders`func creates a random number of `DispatchNotification`values and sends them through the channel. So, there is no way to known in advance how many `DispatchNotification`function will create. Which will present a challenge when writing the code that receives from the channel. In the main():

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)
	for {
		details := <-dispatchChannel
		fmt.Println("Dispatch to", details.Customer, ":", details.Quantity,
			"X", details.Product.Name)
	}
}
```

The `for`doesn’t work cuz the receiving code will try to get values from the channel after the sender has stopped producing them. For this, will see different output -- reflecting the random nature data.

### The `tr`Command

translates one set of characters into another -- like:

```sh
echo $PATH | tr : "\n"  # translate colons into newlines
```

And, also can converting text to upper or lower case like:

```sh
echo efficient | tr a-z A-Z
echo Efficient Linux | tr " " "\n"
# or deleting whitespace 
echo efficient linux | tr -d ' \t' # -d for delete, removes spaces and tabs
```

`rev`command reverses the characters of each line of input like:

```sh
echo Efficient Linux | rev
```

### The `awk`and `sed`Commands

`awk`and `sed`are just general-purpose *supercommands* for processing text -- they can do most everything that other commands can do like:

```sh
sed 1q myfile # print 1 line and quit (q)
awk 'FNR<=10' myfile # print line number <= 10
echo image.jpg | sed 's/\.jpg/.png/' # repalce .jpg by .png
echo "Linux efficient" | awk '{print $2, $1}' # swap two words
```

```sh
git checkout hello-world-images
git add --all
git commit -m "added new image"
git checkout master
```

## Nginx

- open-source, fast, lightweight and high-performance web server that can be used to serve static files
- NGINX has considered as a popular web server behind the Apache web server and IIS.
- In initial release, functioned for HTTP web serving -- also serves as a reverse proxy server.

### Reverse-Proxy server

A proxy server is a go-between or intermediary server that forwards requests for content from multiple clients to different servers across the Internet. A reverse proxy is a type of proxy server that typically sits behind the firewall in a private network and directs client requests to the appropriate backend server. Provides an additional level of abstraction and control to ensure the smooth flow of network traffic between clients and servers.

## Async Patterns

### Cancellation

It’s often important to be able to cancel a concurrent operation after it’s started perhaps in response to a user requrest. A simple way to implement this is with a cancellation flag. like:

```cs
class CancellationToken {
    public bool IsCancellationRequested {get; private set;}
    public void Cancel() {IsCancellationRqueseted=true;}
    public void ThrowIfCancellationRequeted(){
        if(IsCancellationRequested)
            throw new OperationCanceledException();
    }
}
```

When the caller wants to cancel, just call the `Cancel`on the Cancellation token. In the .NET:

```cs
var cancelSource = new CancellationTokenSource();
Task foo = Foo(cancelSource.Token);
//...
cancelSource.Cancel();
```

### Task Combinators

A nice consequence of there being a consistent protocol for async functions is that it’s possible to use and write *task combinators* – functions that usually combine tasks, without regard for what those specific task do. 

The CLR includes two in C# – `Task.WhenAny`and `Task.WhenAll`– 

```cs
var winningTask = await Task.WhenAny(Delay1(), Delay2(), Delay3());
"DONE".Dump();
winningTask.Result.Dump();
```

Cuz `Task.WhenANy`returns a task itself – await it which returns the task that finished first. of course, it’s usually better to await the `winningTask`also – `await winningTask;`

`WhenAll`returns a task that completes when *all of* the tasks that you pass to it ecomplete.

```cs
await Task.WhenAll(Delay1(), Delay2(), Delay3());
// ===>
await task1; await task2; await task3;
```

In contrast, `Task.WhenAll`doesn’t complete until all tasks have completed – even when there is a fault. And if there are multiple faults – their exceptions are combined into the task’s `AggregateException`. like:

```cs
Task task1 = Task.Run(() => { throw null; });
Task task2 = Task.Run(() => { throw null; });

Task all = Task.WhenAll(task1, task2);
try { await all;}
catch(Exception e){
	e.Dump();  // e is a nullexception.
	all.Exception.GetType().Dump();  // AggeregateException
}
```

To give a partical example, the following downloads URLs in parallel and sums like:

```cs
async Task<int> GetTotalSize(string[] uris) {
    var downloadTasks = uris.Select(uri=>
                                   new WebClient().DownloadDataTaskAsync(uri));
    byte[][] contents= await Task.WhenALl(downloadTasks);
    return contents.sum(c=>c.Length);
}
```

## Streams and I/O

- The .NET stream architecture and how it provides a consistent programming interface for reading and writing acorss a variety of I/O types.
- Classes for manipulating files and directories on disk.
- Specialized streams for compression, named pipes, and memory-mapped files.

Stream Architecture – three concepts –*backing stores, decorators, and adapters*. FORE:

A backing store is the endpoint that makes input and output useful – such as a file or network connection.

- A source from which bytes can be sequentially read
- A destination to which bytes can be sequentially written.

A `Stream`is the std .NET class for this – it exposes a std set of methods for reading writing and positioning. A stream deals with data serially – either one byte at a time or in blocks of a managable size.

Backing stroe streams – fore, `FileStream`and `NetworkStream`.
Decorator streams – fore, `DeflateStream`

both deal in bytes – although flexible and efficient, but app often work at higher levels, such as text or XML – *Adapter* bridge this gap by wrapping a stream in a class with specialized methods typed to a particular format.

## Using Streams

`Stream`is the base for all – defines methods and properties for reading, writing, and seeking.

`CanRead, CanWrite, WriteByte(), CanSeek, Position, SetLength, Seek, Close(), Dispose(), Flush()`
`CanTimeout() ReadTimeout(), WriteTimeout()`

There are also async versions of the `Read`and `Write`methods. Fore:

```cs
using Stream s= new FileStream(@"D:\cpp\test2.txt", FileMode.Create);
s.CanRead.Dump();
s.CanWrite.Dump();
s.CanSeek.Dump();

s.WriteByte(101);
s.WriteByte(102);

byte[] block = { 1, 2, 3, 4, 5};
s.Write(block, 0, block.Length);

s.Length.Dump(); //7
s.Position.Dump();  //7
s.Position=0; // move back to the start

s.ReadByte().Dump(); //101
s.ReadByte().Dump(); //102
s.Read(block, 0, block.Length).Dump(); // 5
s.Read(block, 0, block.Length).Dump(); // 0, at the end of the file
```

Reading or writing async is also simple question of calling `ReadAsync/WriteAsync`. like:

```cs
using(Stream s = new FileStream("test.txt", FileMode.Create));
byte[] block = {1,2,3};
await s.WriteAsync(block, 0, block.Length);
```

### Reading and Writing

Using the adapter - like `BinaryReader`provides a simpler way to achieve – like:

`byte[] data = new BinaryReader(stream).ReadBytes(1000);`

For this, if the stream is less than 1000, return value reflects the actual stream size.

### Closing and Flushing

Streams msut be disposed after use of release underlying resources. Note:

- `Dispose`and `Close`are identical in function
- `Disposing`or `closing`a stream repeatedly causes no error.

### Backing store streams

The following return a read-only stream, equivalent to calling `File.OpenRead` like:

`using var fs = new FileStream(“x.bin”, FileMode.Open, FileAccess.Read)`;

### Stream Adapters

`TextReader, TextWriter, StreamReader, StreamWriter, StringReader, StringWriter`

```cs
using(FileStream fs = File.Create("test.txt")){
    using TextWriter writer = new StreamWriter(fs);
    Writer.WriteLine("Line1");
}
```

## Navigation and Cart

### Filtering the product list

Going to start by enchancing the view model class – `ProductListViewModel`– need to communicate the current category to the view to render the sidebar, and this is as good a place to start  like:

`public string? CurrentCategory { get; set; }`

Added a prop – next step to update the `Home`so that the `Index`action method will filter `Product`objects by category and use the property added to the view model to indicate which category has been selected.

```cs
Products = repository.Products
                .Where(p=>category==null || p.Category==category)
    //...
```

http://localhost:5000/?category=soccer

### Then, refining the URL scheme

In the program.cs file:

```cs
app.MapControllerRoute("catpage",
    "{category}/{productPage:int}",
    new { Controller = "Home", action = "Index" , productPage =1});
```

The core routing system handles *incoming* requests from clients, but it also generates outgoing URLs that conform to the URL scheme and that can embedded in web pages.

## The CLR’s Execution Model

In fact, at runtime the CLR has just no idea which programming language the developer used for the source code. Regardless of which compiler use, the result is a *managed module* – is a std 32-bit PE32 executable file or a 64-bit PE32+ file that requires the CLR to execute. And, managed assemblies always take advantage of Data Execution prevention (DEP), and  Address space layout Randomizatoin (ASLR) in windows.

### Combining Managed Modules into Assemblies

Note that the CLR doesn’t actually work with modules – it works with assemblies – is an abstract concept that can be – 

- is a logical grouping of one or more modules or resource files
- Is the smallest unit of reuse, security and versioning.

## All are Derived from `System.Object`

- `Equals`-- Returns `true`if have the same value
- `GetHashCode()`-- A type should override this if its object are to be used as a key in a hash table collection, like `Dictioanry`.
- `GetType()`– Returns an instance of a `Type-derived`object that identities the type of the object used to call `GetType`. Just be used with the reflection classes to obtain metadata info.

Protected Mehods – 

- `MemberwiseClone`– non-virtual – creates a new instance of the type and set the new’s instance fileds to be identical to the `this`instance
- `Finalize`– virtual – when the garbage collector determines that the object is garbage and before the memory for the object is reclaimed.

### Casting with `is`and `as`opertors

`is`checks whether an obj is compatible with a given type, result is `true`or `false`. And the `as`works just as casting does except that the `as`will never throw.

How namespaces and assembilies relate – A namespace and an assembly (the file that implements a type) are not necessarily related – The various types belonging to a single namespace might be implemented in multiple assemblies.

## Understanding the core platform

*dependency injection* is used to create and consume **services**.

- DI makes it easy to create loosely coupled components – typically means that components consume functionality defined by the interface without having any firsthand knowledge of which implementation classes are being used.
- DI makes it easier to change the behavior of an app by changing the components that implement the interfaces that define app features.
- `Program.cs`is used to specify which implementation classes are used to deliver the functionality specified by the interfaces used by the app.

```cs
public interface IResponseFormatter
{
    Task Format(HttpContext context, string content);
}
```

Then create an implementation like:

```cs
public class TextResponseFormatter : IResponseFormatter
{
    private int responseCounter = 0;

    public async Task Format(HttpContext context, string content)
    {
        await context.Response.WriteAsync($"Response {++responseCounter}:\n{content}");
    }
}
```

For this, just implements the interface and writes the content to the response as a simple string.

### Creating middleware component and an endpoint

```cs
public class WeatherMiddleware
{
    private RequestDelegate next;

    public WeatherMiddleware(RequestDelegate next)
    {
        this.next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        if(context.Request.Path=="/middleware/class")
        {
            await context.Response.WriteAsync("Middlware Class: It is raining in London");
        }
        else
        {
            await next(context);
        }
    }
}
```

And to create an endpoint that produces a similar result to the middleware component, add a file called:

```cs
public class WeatherEndpoint
{
    public static async Task Endpoint(HttpContext context)
    {
        await context.Response
            .WriteAsync("Endpoint Class: It's cloudy in Milan");
    }
}
```

Then in the `Program.cs`to configure the pipeline like:

```cs
app.UseMiddleware<WeatherMiddleware>();
app.MapGet("endpoint/class", WeatherEndpoint.Endpoint);

IResponseFormatter formatter = new TextResponseFormatter();
app.MapGet("endpoint/function", async context =>
{
    await formatter.Format(context, "Endpoint function: it is sunny in LA");
});
```

### Understanding Service location and tight coupling

To understand DI – important two problems it solves. 

DI offers limited benefit if you are not doing unit testing – or if are working on a small, self-contained, and stable project. Most projects have features that need to be used in different parts of the application. Each `TextResponseFormatter`object maintains a counter that is included in the resonse sent to the browser – Need to have a way to make a single `TextResponseFormatter`object available in such a way that it can be easily found and consumed at every point where responses are generated.

There are just many wasy to make services locatable, but there are two main – aside from the one that is the main topic of this – first is to create an obj and use it as a ctor or method arg to pass it to the part of the app where it is requried. The other approach is to add a `static`prop to the service class that provides direct access to the shared instance. And the singleton pattern is – but the knowledge of how services are located is spread throughout the application, and all service classes and service consumers need to understand how to access the shared object. like:

```cs
public class HtmlResponseFormatter : IResponseFormatter
{
    public async Task Format(HttpContext context, string content)
    {
        context.Response.ContentType = "text/html";
        await context.Response.WriteAsync($@"
            <!DOCTYPE html>
            <html lang=""en"">
            <head><title>Response</title></head>
            <body>
                <h2>Formatted Response</h2>
                <span>{content}</span>
            </body>
            </html>");
    }
}
```

## Using the DI

Provides a alternative approach to providing services that tidy up the rough edges that arise in the singleton and type broker patterns, and is integrated with other ASP.NET core features.

```cs
builder.Services.AddSingleton<IResponseFormatter, HtmlResponseFormatter>();
```

For this, services are registered using extension methods defined by the `IServiceCollection`interface – an implementation of which is obtained using the `WebApplicationBuilder.Service`property.

### Using a service with a CTOR Dependency

Defining a service and consuming it in the same code file may not seem impressive – once a service is defined, it can be used almost anywhere in an ASP.NET core app. like:

```cs
public class WeatherMiddlware {
    private RequestDelegate next;
    private IResponseFormatter formatter;
    
    public WeatherMiddleware(...) {
        next = nextDelegate;
        formatter= respFormatter;
    }
}
```

### Getting services from the `HttpContext`object

Core does a good job of supporting DI as widely as possible but there will be times – when are not working directly with the ASP.NET core API, and won’t have a way to declare your service dependencies directly. And Services can be accessed through the `HttpContext`object – is used to represent the current request and response, like:

```cs
public class WeatherEndpoint {
    public static async Task Endpoint(HttpContext context) {
        IResponseFormatter formatter = context.RequestServices
            .GetRequiredService<IResponseFormatter>();
        //...
    }
}
```

So, the `HttpContext.RequestServices`prop returns an object that implement the `IServiceProvider`interfaces – which provides access to the services that have been configured in the program.cs file.

- `GetService<T>()`– returns a service for the type specified by the generic type parameter
- `GetRequiredService<T>()`– returns and **throws** exception if isn’t availiable.

Create a file named `EndpointExtensions.cs`:

```cs
public static class EndpointExtensions
{
    public static void MapEndpoint<T>(this IEndpointRouteBuilder app,
        string path, string methodName = "Endpoint")
    {
        MethodInfo? methodInfo= typeof(T).GetMethod(methodName);
        if(methodInfo?.ReturnType!= typeof(Task))
        {
            throw new Exception("Mehtod cannot be used");
        }

        T endpointInstance =
            ActivatorUtilities.CreateInstance<T>(app.ServiceProvider);
        app.MapGet(path, (RequestDelegate)methodInfo.CreateDelegate(typeof(RequestDelegate),
            endpointInstance));
    }
}
```

The `ActivatorUtilities` – provides methods for instantiating classes that have dependencies declared.

## Using the platform features part 1

- Understanding the built-in features provided by Core
- Accessing the app configuration
- Storing secrets outside the project folder
- Logging messages
- Generateing static content and using client-side packages

### Using the Configuration service

One of the built-in features provided by ASP.NET core is access to the app’s configuration settings, which is presented as a service. like: `appsettings.json`file – The configuration service doesn’t understand the meaning of the configuration sections or settings in the `appsettings.json`file and is jsut responsible for processing the JSON data file and merging the configuration settings with the values obtained from other sources.

### Understanding the environment configuration file

Most contain more than one JSON configuration file, allowing different settings to be defined for different parts of the development cycle. There are just 3 predefined environments, `Develpment, staging, Production`.

During startup the configuraiton service looks for a JSON file whose name includes the current environment. The default environment is `Development` – means taht the configuration service will load the `appsettings.Development.json`file and use its contents to supplement the contents of the main `appsettings.json`file.

Where the same setting is defined in both files, the value in the `appsettings.Development.json`file will replace the one in the `appsettigns.json`file, which means that the contents of two JSON files will produce the hierarchy of configuraiton settings.

### Accessing configuration settings

The configuration data is accessed through a service. like:

```cs
app.MapGet("config", async (HttpContext context, IConfiguration config) =>
{
    string? defaultDebug = config["Logging:LogLevel:Default"];
    await context.Response.WriteAsync($"The config setting is {defaultDebug}");
});
```

Using the configuration data in the Program.cs file – and configure the appsettings.json file like:

Understanding the launch settings file – `launchsettings.json`file in the properties folder contains the configuration settings for starting the core platform, including the TCP ports that are sued to listen for HTTP and HTTPs requests and the environment used to select the additional JSON configuration files.

`iisSettings`is used to configure the `HTTP`and `HTTPs`ports used when the Core platform is started through IIS express, which is how older versions of core were deployed.

`profiles`descirbes a series of launch profiles, define configuration settings for different ways of running the appliation. `Platform`defines the configuration used by the `dotnet run`. Can also use Debug->Launch to do that.

### Network Events

Common source of async in Js programming is network requests - js running in the browser can fetch data from a web server with code like FORE:

```js
function getCurrentVersionNumber(versionCallback) {
    let request = new XMLHttpRequest();
    request.open('GET', 'http://www.example.com/api/version');
    request.send();

    // register a callback that will be invoked when the response arrives
    request.onload = function () {
        if (request.status === 200) {
            // if http statis good, get version and call callback
            let currentVersion = parseFloat(request.responseText);
            versionCallback(null, currentVersion);
        } else {
            // other report an error to the callback
            versionCallback(response.statusText, null);
        }
    };
    // register another callback that will be invoked for network errors
    request.onerror = request.ontimeout = function (e) {
        versionCallback(e.type, null);
    }
}
```

## Promises

A `Promise`is an object that represents the result of an async computation. That result may or may not be ready yet, and the Promise API is intentionally vague about this. There is no way to sync get the value of a Promise – can only ask the Promise to call a callback when the value is ready.

At the simplest, Promises are just a different way of working with callbacks. One real problem based async programming is that it is common to end up with callbacks inside callbacks inside callbacks, with lines of code so highly indented that it is difficult to read.

Another with callbacks is they can make handling errors difficult. – namely, if an async throws an exception, there is no way for that excception to propagate back to the initiator of the async operation. Promises help here by standardizing a way to handle errors and providing a way for errors to propagate correctly through a chain of promises.

Promises represent the future results of single async computations - cannot be used to represent repeated async computations. FORE, can use Promise-based to replace `setTimeout()`but not to `setInterval()`. 

### Using Promises

With the advent of Promisees  – web browsers have begun to implement Promises-based APIs, Fore:

```js
getJSON(url).then(jsondata => {
    // this is a callback that will be async
    // invoked with the parsed JSON value when becomes available.
})
```

For this, `getJSON`starts an async HTTP request for the url, then – returns a `Promise`– defines a `then()`instance method – instead of passing our callback directly to `getJSON()`– instead passing it to the `then`method. The body of that response is parsed just as JSON.

Can think of the `then()`as a callback registration method like the `addEventListener()`method used fo registering event handler in client-side – If call the `then()`multiple times – each of the functions you specify will be called when the promised computation is complete.

A Promise just represents a single computation, and each function registered with `then()`will be invoked only once. Note : even if the async computation is already complete – pass to `then()`is invoked asynchronously.

At a simple syntactical level, the `then()` method is the distinctive feature of `Promises`and it is just idiomatic to append `.then()`directly to the function invocation that returns a `Promise`. Is also idiomatic like:

```js
// suppose have a func like this to display a user profile
function displayUserProfile(profile) {...}
getJSON("/api/user/profile").then(displayUserProfile);
```

### Handling errors 

Do this by passing a second function to the `then()`method –

`getJSON(...).then(displayUserProfile, handleProfileError);`

Cuz the computation is performed after the `Promise`object is returned to us – there is no way that the computation can traditionally return a value or throw an exception that can cat.
