## Closing a Channel

The solution for this problem is the sender to indicate when no further values are coming through the channel -- which is done by closing a channel like:

```go
func DispatchOrders(channel chan DispatchNotification) {
    //...
    close(channel)
}
```

So, the built-in close function just accepts a channel as its argument and is used to indicate that there will be no further values sent through the channel. Receivers can check if a channel is closed when requesting a value.

```go
for {
    if details, open := <-dispatchChannel; open {
        fmt.Println("Dispatch to ", details.Customer, ":", details.Quantity,
                    "x", details.Product.Name)
    } else {
        fmt.Println("Channel has been closed")
        break
    }
}
```

So the receive operator can be used to obtain two values -- first is assigned the value received from the channel, and the second indicates *whether the channel is closed*.

### Enumerating Channel Values

A `for`can be used just with the `range`to enumerate the values set through a channel, allowing the values to be received more easily and terminating the loop when the channel is closed. like:

```go
for details := range dispatchChannel {
    fmt.Println("Dispatch to", details.Customer, ":", details.Quantity,
                "x", details.Product.Name)
}
fmt.Println("Channel has been closed")
```

The `for`will continue to receive values until the channel is closed.

## Restricting Channel Direction

By default, channels can be used to send and receive data, but this can be restricted when using channels as arguments -- such that only send or receive operations can be performed. like:

`func DispatchOrders(channel chan<- DispatchNotification)`

This location of the arrow specifies the direction of the channel -- when the arror follows the `chan`-- then just only for send, also can be receive only like `<-chan`, and attempting to receive from a send-only is compile-error.

### Restricting Channel Argument Direction

Directional channels are types so that the type of the function parameter is `chan<- DispatchNotification`, need to know Go just allows bidirectional channels to be assigned to unidirectional variables.

```go
func receiveDispatches(channel <-chan DispatchNotification) {
	for details := range channel {
		fmt.Println("Dispatch to", details.Customer, ":", details.Quantity,
			"x", details.Product.Name)
	}
	fmt.Println("Channel has been closed")
}

func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	var sendOnly chan<- DispatchNotification = dispatchChannel
	var receiveOnly <-chan DispatchNotification = dispatchChannel
	go DispatchOrders(sendOnly)
	receiveDispatches(receiveOnly)
}
```

Also, just can be used as:

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	
	go DispatchOrders(dispatchChannel)
	receiveDispatches(dispatchChannel)
}
```

The explicit conversion for the receive-only channel requires partheses around..

## Using `select`statement

The `select`keyword is used to group operations that will send or receive from channels, which just allows for complex arrangements of goroutines and channels to be created. There are several uses for `select`statements. Will start the basics and work through the more advanced options.

### Receiving without blocking

The simplest use for the `select`statement is to receive from a channel without blocking, ensuring a goroutine won’t have to wait when the channel is empty.

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)

	// just conversion
	go DispatchOrders(chan<- DispatchNotification(dispatchChannel))
	for {
		select {
		case details, ok := <-dispatchChannel:
			if ok {
				fmt.Println("Dispatch to", details.Customer, ":",
					details.Quantity, "x", details.Product.Name)
			} else {
				fmt.Println("Channel has been closed")
				goto alldone
			}
		default:
			fmt.Println("no message ready to be received")
			time.Sleep(time.Millisecond * 500)
		}
	}
alldone:
	fmt.Println("All values received")
}
```

A `select`has a similar structure to a `switch`statement -- except that the `case`are channel operation -- when `select`is executed, each channel operation is evaluated until one that can be performed without blocking is reached. The channel operation is performed, and the statements enclosed in the case are executed. And, if none of the channel operation can be performed, the statements in the `default`executed.

The delays introduced by the `time.Sleep()`create a small mismatch between the rate at which values are sent through the channel and the rate at which they are received. The result is that the `select`statement is sometimes exxecuted when the channel is empty -- instead block -- the `select`executes the statements in the `default`clause.

### Receiving from Multiple Channels

A `select`can be used to receive without blocking, -- but that feature become more useful when there are multiple channels, through which values are sent at different rates -- A `select`will allow the receiver to obtain values from whichever channel has them --without blocking or any single channel. fore:

```go
func enumerateProducts(channel chan<- *Product) {
	for _, p := range ProductList[:3] {
		channel <- p
		time.Sleep(time.Millisecond * 800)
	}
	close(channel)
}
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)

	// just conversion
	go DispatchOrders(chan<- DispatchNotification(dispatchChannel))

	productChannel := make(chan *Product)
	go enumerateProducts(productChannel)

	openChannels := 2

	for {
		select {
		case details, ok := <-dispatchChannel:
			if ok {
				fmt.Println("Dispatch to", details.Customer, ":",
					details.Quantity, "x", details.Product.Name)
			} else {
				fmt.Println("Dispatch channel has been closed")
				dispatchChannel = nil
				openChannels--
			}

		case product, ok := <-productChannel:
			if ok {
				fmt.Println("Product:", product.Name)
			} else {
				fmt.Println("Product channel has been closed")
				productChannel = nil
				openChannels--
			}
		default:
			if openChannels == 0 {
				goto alldone
			}
			fmt.Println("-- no message ready to be received")
			time.Sleep(time.Millisecond * 500)
		}
	}
alldone:
	fmt.Println("All values received")
}
```

In this, the `select`statement is used to receive values from two channels, one that carries `DispatchNotification`values and one carries `Product`. And, each time the `select`is executed, it works its way trhough the `case`, building up a list of the ones from which a value can be read without blocking.

And, managing closed channels requires two measures, the first is to prevent the `select`statement from choosing a channel once it is closed -- this can be done by assinging `nil`to the channel variable.

`dispatchChannel = nil`

A `nil`channel is never ready and will not been chosen, allowing the `select`statement to move onto other `case`, whose channesl may still open just.

The second measue is to break out of the `for`when all channels are closed, without which the `select`would endless execute the `default`clause.

### Sending without Blocking

`select`can also be used to send a channel without blocking like:

```go
func enumerateProducts(channel chan<- *Product) {
	for _, p := range ProductList {
		select {
		case channel <- p:
			fmt.Println("Sent product:", p.Name)
		default:
			fmt.Println("Discarding product", p.Name)
			time.Sleep(time.Second)
		}
	}
	close(channel)
}

func main() {
	productChannel := make(chan *Product, 5)
	go enumerateProducts(productChannel)

	time.Sleep(time.Second)

	for p := range productChannel {
		fmt.Println("Recevied product:", p.Name)
	}
}
```

For this, the channel is created with a small buffer, and values are not received from the channel until after a small delay. This means that the `enumerateProducts`func can send values through the channel without blocking until the buffer is full. So the `default`discards values that cannot be sent.

The output just shows where the `select`statement determined that the send operaiton would block and invoked the `default`clause instead.

### Sending to Multiple Channels

If there are multiple channels available, a `select`can be used to find a channel for which sending will not block.

```go
func enumerateProducts(channel1, channel2 chan<- *Product) {
	for _, p := range ProductList {
		select {
		case channel1 <- p:
			fmt.Println("Send via channel 1")
		case channel2 <- p:
			fmt.Println("Send via channel 2")
		}
	}
	close(channel1)
	close(channel2)
}

func main() {
	c1 := make(chan *Product, 2)
	c2 := make(chan *Product, 2)
	go enumerateProducts(c1, c2)

	for p := range c1 {
		fmt.Println("Channel 1 received product:", p.Name)
	}
	for p := range c2 {
		fmt.Println("Channel 2 recied product:", p.Name)
	}
}
```

Two channels with small buffers -- the `select`builds a list of the channels through which a value can be sent without blocking and then picks one at random from that list. if none of the channels can be used, then the `default`clause is executed. There is no `default`clause so that the `select`statement will block until one of the channels can receive a value.

The values from the channel are not received until a second after the goroutine that executes the `enumerateProducts`function is created. 210 216 218 need to.

### Why use Nginx

Provides varous services such as reverse proxy, load balancer, A reverse proxy is just a server that sits in front of web servers and forwards client requests to those web servers. Reverse proxies are typically implemented to help increase security performance, and reliabiliity.

### What is proxy server?

A forward proxy, often called a proxy -- is a server that sits in front of a group of client machines. When those computers make requests to the sites and services on the Internet, the proxy server intercepts those requests and then communicates with the web servers on behalf of those clients, like a middleman.

### How is a reverse proxy different

A `reverse proxy`is a server that sits in front one or more web servers, intercepting requests from clients. This is just different from a forward proxy -- where the proxy sits in front of clients -- with a reverse proxy, when clients send requests to the origin server of a website, those requests are intercepted at the **network edge** by reverse server. The reverse proxy server will then send requests to and receive responses from the origin server.

The difference between a forward and reverse -- A simplified -- A forward sits in front of a client and just ensure that no origin server communicates directly with that sepcific client. 

A reverse sits in front of an origin server and just ensures no client ever communicates directly with that origin server.

Below outline some of the benefits of a reverse server proxy -- 

- load balancing -- A popular website that gets millions of users every.. may not be able to just handle all of its cincoming site traffic with a single origin server. -- instead, the site can be just distributed among a pool of different servers, all handling reuests for the same site - in this case, a reverse can provide a load balance solution which will distribute the incoming traffic evenly among the different servers to prevent any single server from becoming overloaded.
- Protection from attacks -- With the reverse, a web site or service n*ever needs to reveal IP* of their origin server. This makes it much harder for attackers to leverage a targeted attack against them.
- Global server load balancing -- a website can be distributed on several servers around global and the reverse proxy will send clients to the server that is geographically closest to them
- Caching -- Can also cache content, resulting in faster performance. A proxy server can tehn just cache the response data. Subsequent users will then get the locally cached version from the reverse proxy server
- SSL encryption -- SSL or TLS communication for each client can be computeationlly expensive for an origin server. So a reverse proxy can be configured to decrypt all incoming requests and encrypt all outgoing responses.

NGINX provides various services -- reverse proxying is useful if have multiple web services listening on varioud ports and we need a single public endpoint to **reroute** requests internally. This would allow us to host multiple domain names on prot 80 using a combination of different NodeJs, Go and Java to power separate web behind the scenes.

Nginx can handle the logging, blacklisting, load balancing and serving static files..

### How Does Nginx work

Traditionally, web servers like Apache create a single thread for every request -- but Nginx does not work that way -- Nginx performs with an *async, event-driven* architecture.

Nginx divided its job into the **worker process** and **worker connections**. worker connections are used to manage the request made and the response obtained by the users on the web server. At the same time, these requests are passed to its parent process which is called the worker process.

Since worker connection can take care up to 1024 similar requests, cuz of that, Nginx can handle thousands of requests without any difficulties.

## Primitive, Reference, and Value Types

In C#, `long`maps to `System.Int64`, but in a different programming, `long`could map to others.

### Checked and unchecked Type operations `checked`

In most programming scenarios the silent overflow is undesirable and if not detected causes the app to behave in strange and unusual ways. By default, overflow checking is turned off. This means that the compiler generates IL code by using the versions of the add.. don't include overflow checking.

In addition to the `checked`and `unchecked`operator in C#, also offers checked and unchecked statements.

like:

```cs
Byte b = 100;
b = checked((Byte)(b+200)); // OverFlowException is thrown.
checked {
    Byte b = 100;
    b = (Byte)(b+200);
}
```

### Reference Type and Value Types

The CLR supports two kinds of types -- Working with reference type:

- The memory must be allocated from the managed heap.
- Each object allocated on the heap has some additional overhead members associated with it must be initialized
- The other bytes in the objects are alwyas set to zero
- Allocating an obj from the managed **force** a garbage collection to occur.

To improve performance for simple, frequently used types, the CLR offers lightweight types called value types.

### Boxing and unboxing 

Value types are lighter weight than reference cuz are not allocated as objects in the managed heap-- not garbage collected, and not referred to by pointers. FORE:

```cs
// declare a value type
struct Point {
    public int x, y;
}
public sealed class Program {
    public static void Main(){
        ArrayList a = new ArrayList();
        Point p ; // allocate a Point (not in heap)
        for (int i =0; i<10; i++) {
            p.x=p.y=i;
            a.Add(p); // box the value type and add the reference to the ArrayList class
        }
    }
}
```

So, what is actually being stored in the `ArrayList`-- for the ArrayList's `Add`method:

`public virtual Int32 Add(Object value)`

So, it's possible to convert a value type to a reference type by using a mechanism called boxing. Internally -- 

1. Memory is allocated from the managed heap -- The amount of memory allocated is the size required by the value types's fields plush the 2 additional overhead members (type pointer and sync block index)
2. The value type's field are copied to the newly allocated heap memory
3. The address of the object is returned

Then say, want to grab the first element of the `ArrayList`by using:

`Point p  = (Point)a[0]`

For this to work, all of the fields contained in the boxed object must be copied into the value type variable p, which is on the thread's stack. The CLR accomplishes this copying in two steps -- 

1. The address of Point fields in the boxed `Point`object obtained -- called *unboxing*.
2. The vlues of these fields are *copied* from the heap.

Unboxing is not exactly opposite of boxing -- the unboxing is much less costly. Internally, Here is what hppens when a boxed type instance is unboxed like:

1. If the variable containing the reference to the boxed is `null`, `NullReferenceException`thrown
2. If the reference doesn't refer to an object that is boxed instance of the desired value type, `InvalidCastException`.

```cs
public static void Main(){
    int x= 5;
    object o = x;
    short y = (short)o ; // InvalidCastException
}
// so need
short y= (short)(int)o; // unbox to the correct type and cast
```

## Object Equality and Identity

The `System.Object`just offers a **virtual** method named `Equals`whose purpose is to return `true`if same value. just:

```cs
public virtual bool Equals(object obj){
    if(this==obj) return true;
    return false;
}
```

So, ms should have implemented the `Equals`like this:

```cs
public virtual bool Equals(object obj){
    // this given object to complare can't be null first
    if (obj==null) return false;
    
    // different type, false
    if(this.GetType()!=obj.GetType()) return false;
    //... like before.
}
```

When a type overrides `Equals`, the override should call its base class's implemenation of `Equals`unless it would be calling `Object`'s implementation.

Object also offers a `static`, `ReferenceEquals`method like:

```cs
public static bool ReferenceEquals(Object objA, Object objB){
    return (objA==objB);
}
```

Internally, `ValueType`'s `Equals`method uses reflection to accomplish. When defining your own type -- if want to override `Equals`must ensure that it adheres to the 4 properties of equality -- 

- `Equals`must be reflexive. namely, `x.Equals(x)`is `true`.
- Symmetric, `x.Equals(y)==y.Equals(x)`
- Transitive
- Consistent

And, when overriding the `Equals`, there are a couple more things should want to do --

- Have the type implement the `IEquatable<T>`'s Equals method-- allows you to define a type-safe `Equals`
- Overload the == and !=.

### Object Hash codes

If you define a type and override the `Equals`, should also override the `GetHashCode()`. If you override the `Equals`, should override this to ensure that the algorithm you use for calculating equality corresponds to the algorithm use for calculating the hash code. like:

```cs
internal sealed class Point{
    private readonly int m_x, m_y;
    public override int GetHashCode(){
        return m_x ^ m_y;
    }
}
```

## Type and Member Basics

- Conversion operators -- is a method that defines how to implicitly or explicitly cast or convert an obj
- Events -- allows a type to send a notificatio to one or more static or instance methods.

### type visibility

`internal`is visibile to all code within the defining assembly .

`protected internal`-- The member is accessible only by nested, and derived type, **or** in the defining assembly.

### Components polymorphism and versioning

Component Software programming (CSP) is OOP brought to this level -- here are some attributes of a component like:

- A component has the feeling of being published
- A component has an identity (name, version, culture, and pub key).
- Forever maintains its identity
- Clearly indicates the components it depends on.
- Security permissions it requires specified.
- Publishes an interface that won't change for any servicing.

## Constants and Fields, Methods

Constants' values are determinable at compile time -- the compiler then saves constant's value in the assembly's metadata. Means that you can define a constant only for types that your compiler considers **primitive** types.

`field`is data member that holds an instance of a value type or a reference to reference type. note:

- `static`-- is part of the type's state.
- instance -- associated with an instance.
- initOnly - readonly- can be written to only by code in ctor method.
- volatile -- is not subject to some thread-unsafe optimiations.

### Operator overload methods

The CLR doesn't know anything about operator overloading cuz it doesn't even know what an operator is. For programming language -- defines each operator symbol means and what code should be generated when these special symbols appears. But, CLR specify how languages should expose operator overloads so they can be readily consumed by code written in different programming language. In addition, C# rquires that *at least one* of the operator method's parameters must be same as the type that the operator method is defined with. like:

```cs
public sealed class Complex {
    public static Complex operator + (Complex c1, Complex c2) {...}
}
```

And the compiler will emit a metadata method definition entry for a method just called `op_Addition`.

### Conversion operator methods

Occassionally, need to convert an object from one type to an object of a different type. If the source type or target is not a primitive, the compiler emits code that has the CLR perform the conversion (cast). In this case, the CLR just checks if the source object's type is the same type as the target (or direved from the target). To make this work, also define public instance Toxxx methos that take no paramters like:

```cs
public sealed class Rational {
    public int ToInt() {...}
    public Single ToSingle() {...}
    
    // ctor a Rational from an int
    public Rational(int num) {...}
}
```

In addition, C# requires that either the parameter or return type must same as the type that the conversion method is defined within. like:

```cs
// implicitly constructs and returns a Rational from an int
public static implicit operator Rational(int num) {
    return new Rational(num);
}

// explicitly returns an int from a Rational
public static explicit operator int(Rational r) {
    return r.ToInt();
}
```

So, for conversion methods, must indicate whether a compiler can emit code to call a conversion operator method implicitly or whether the source code must explicitly indicate when the com=piler is to emit code to call a conversion operator method. In C#, use the `implicit`to indicate to the compiler and the `explicit`keyword allows compiler to call the emthod only when an explicit cast exists in the source code.

## Using the environment Service

The Core platform provides the `IWebHostEnvironment`service for determining the current environment, which avoids the need to get teh configuration setting manually. Defines property and methods like:

- `EnvironmentName`-- returns the current environment
- `IsDevelopment()`-- `true`when `Development`environment has been selected.
- `IsStaging(), IsProduction()`
- `IsEnvironment(env)`-- `true`when the environment specified by the arg has been selected. Like:

```cs
var serviceEnv = builder.Environment;
var app = builder.Build();

// use configuration settings to set up pipeline
var pipeEnv = app.Environment;
```

### Storing user secrets

During development, it is just often necessary to use sensitive data to work with the services that an application depends on. This data can include API keys... And, if the sensitive data is just included in the C# classes or JSON configuration files, it will be checked into the source code . So the user secrets service allows sensitive data to be stored in a file that isn't part of the project, and won't be checked into version controlling.

Storing user secrets -- 

```sh
dotnet user-secrets init
dotnet user-secrets set "WebService:Id" "MyAccount"
dotnet user-secrets set "WebService:Key" "MySecret"
dotnet user-secrets list
```

### Reading user secrets

User secrets are merged with the normal configuration settings and accessed in the same way. just:

```cs
app.MapGet("config", async (HttpContext context, IConfiguration config) =>
{
    string? defaultDebug = config["Logging:LogLevel:Default"];
    await context.Response
        .WriteAsync($"The config setting is {defaultDebug}");
    string? wsID = config["WebService:Id"];
    string? wsKey = config["WebService:Key"];
    await context.Response.WriteAsync($"\nThe secret ID is {wsID}");
    await context.Response.WriteAsync($"\nThe secret key is {wsKey}");
});
```

### Using the logging Services

Core provides a logging service that can be used to record messages that describe the state of the app to track errors, monitor performance, and help diagnose problems like: 3 built-in providers are enabled by default, console, debug and the `EventSource`.

Generating messages -- Configure the `appsettings.json`file like:

```json
{
    "Logging": {
        "LogLevel": {
            "Default":"Debugt",
            //...
        }
    }
}
```

And the `UseStaticFiles()`extension adds the static file middleware to the request pipeline.

### Using Cookies

Core provides supports for working with cookies through `HttpRequest`and `HttpResponse`that are provided to middleware components.

```cs
app.MapGet("/cookie", async context =>
{
    int counter1 =
    int.Parse(context.Request.Cookies["counter1"] ?? "0") + 1;

    context.Response.Cookies.Append("counter1", counter1.ToString(),
        new CookieOptions
        {
            MaxAge = TimeSpan.FromMinutes(10)
        });

    int counter2 =
    int.Parse(context.Request.Cookies["counter2"] ?? "0") + 1;

    context.Response.Cookies.Append("counter2", counter2.ToString(),
        new CookieOptions
        {
            MaxAge = TimeSpan.FromMinutes(10)
        });

    await context.Response.WriteAsync($"Counter1: {counter1}, counter2: {counter2}");
});

app.MapGet("clear", context =>
{
    context.Response.Cookies.Delete("counter1");
    context.Response.Cookies.Delete("counter2");
    context.Response.Redirect("/");
    return Task.CompletedTask;
});

app.MapFallback("/", async context =>
{
    await context.Response.WriteAsync("Hello, world");
});
```

So, when the `/cookie`URL is requested, the middleware looks for the cookies and parses the values to an `int`. Fallback 0 is used. And are accessed through the `HttpRequest.Cookies`prop, where the name of the cookie is used as the key.

### Enabling cookie constant checking

The `EU General Data Protection Regulation`(GDPR) requires the user's consent before nonessential cookies can be used -- Core just provides support for obtaining consent and preventing nonessential cookies from being sent to the browser when consent has not been granted.

`app.UseCookiePolicy();`

```cs
builder.Services.Configure<CookiePolicyOptions>(opts =>
{
    opts.CheckConsentNeeded = context => true;
});
```

To enable consent checking, just assigned a new function to the `CheckConsentNeeded`prop that always return `true`-- is called for every request that Core receives, which means that sophisticated urles can be defined to select the requests for which consent is required.

```cs
context.Response.Cookies.Append("counter2", counter2.ToString(),
        new CookieOptions
        {
            MaxAge = TimeSpan.FromMinutes(10),
            IsEssential = true   // only this can be updated
        });
```

### Managing cookie consent

So, unless the user has given consent, only cookies that are essential to the core features of the web app are allowed. Consent is managed through a *request feature* -- which provides middleware components with access to the implementation details of how requests and responses are handled by core. Features are accessed through the `HttpRequest.Features`property with members, `CanTrack, CreateConsentCookie()`...

in the example, code like:

```cs
public class ConsentMiddleware
{
    private RequestDelegate next;
    public ConsentMiddleware(RequestDelegate next)
    {
        this.next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        if(context.Request.Path=="/consent")
        {
            ITrackingConsentFeature? consentFeature =
                context.Features.Get<ITrackingConsentFeature>();
            if (consentFeature!=null)
            {
                if(!consentFeature.HasConsent)
                {
                    consentFeature.GrantConsent();
                }
                else
                {
                    consentFeature.WithdrawConsent();
                }
                await context.Response.WriteAsync(
                    consentFeature.HasConsent ? "Consent Granted" : "Withdraw!");
            }
        }
        else
        {
            await next(context);
        }
    }
}
```

Request features are obtained using the `Get`method.

### using Sessions

The example in the prievious used cookies to store the app's state data, providing the middleware component with the data required. the problem with this is that the contents of the cookie are stored at the client, where it can be manipulated and used to alter the behavior of the application.

So, a better approach is to use the ASP.NET core session feature -- adds a cookie to responses, which allows related requests to be identified and which is also associated with data stored at the server.

When a request containing the session cookie is received, the session middleware component to request pipeline.

```cs
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(opts =>
{
    opts.IdleTimeout = TimeSpan.FromMinutes(30);
    opts.Cookie.IsEssential = true;
});

var app = builder.Build();

app.UseSession();

app.MapFallback("/", async context =>
{
    await context.Response.WriteAsync("Hello, world");
});

app.Run();
```

- `AddDistributedMemoryCache`-- set up an in-memory cache, the cache is not distributed and is responsible only for storing data for the instance of core runtime where it is created.
- `AddDistributedSqlServerCache`-- sets up a cache that stores data in SQLServer and is available when packages is installed.

For `AddSession()`extension, it's parameter is a `Action<SessionOptions>`, its properties --

- `Cookie`-- used to configure the session cookie
- `IdleTimeout`-- Is used to configure the time span after which a session expires.

## Handling errors with Promises

Async operations, particularly those -- can typically fail in a number of ways, and robust code has to be written to handle the errors that will inevtibly occur.

For `Promises`can do this by passing a second function to the `then`method -- like:

`getJSON("/api/user/profile").then(displayUserProfile, handleProfileError)`

Note that a `Promise`represents the future result of an async computation that occurs after the Promise object is created, the computation is performed after the `Promise`returned to us, there is no way that the computation can traditionally return a value or throw an exception that can catch.

When sth goes wrong ina sync -- throws an exception that propagates up the call stack until there is a `catch`clause to handle it.  When async computation runs, *its caller is no longer on the stack*. So Promise-based async computations pass the exception to the second function passed to the `then()`-- `getJSON()`just runs normally, it passes its result to `displayUserProfile()`.

There is a better and more idiomatic way of handling errors when working with Promises. just like:

`getJSON("...").then(displayUserProfile).catch(handleProfileError)`

### Chaining Promises

One of the most important is they provide a natural way to express a sequence of async opertions like:

```js
fetch(documentUrl)
.then(response=>response.json()) // ask for the json body
.then(document=> {
    return render(document);
})
.then(rendered=> {
    cacheInDatabse(rendered);
})
.catch(error=> handle(error));
```

New HTTP API is just funciton `fetch()`like:

```js
fetch("/api/user/profile")
.then(resp=> {
    // when the promise resolves, have status and headers
    if(response.ok &&
      response.header.get("Content-Type")=="application/json"){
        // can do what?
    }
})
```

need to note when the `Promise`returned by `fetch()`is fulfilled, it passes a Response object to the function you passed to its `then()`-- gives you access to request status and headers, and also defines like `text()`, `json()`-- which give access to the body of the response in ttext and JSON-parsed forms. The preferred idiom is to use `Promises`in a sequential chain with code like this:

```js
fetch("/api/user/profile")
.then(response=> response.json())
.then(profile=>displayUserProfile(profile));
```

Sometimes, when an API is designed to use this kind of method chaining, there is just a single object, and each method of the object returns the object itself in order to facilitate chaining. That is now `Promise`works.

### Resolving Promises

Sometimes, want to execute a number of async operations in parallel -- `Promise.all()`do this -- takes an array of Promise objects as its input and returns a Promise. LIke:

```js
const urls = {};
promises= urls.map(url=>fetch(url).then(r=>r.text()));
Promise.all(promises)
.then(bodies=>...).catch(e=>console.error(e));
```

`Promise.all()`is just slightly more flexible -- The input array can contain both Promise or non-Promise values. Note that if an element of the array is not a Promise, just treated as if it is the vlaue already fulfilled. And the Promise returned by the `Promise.all()`rejects when any of the input Promises is rejected.

### `async`and `await`

ES 2017 introduces `async`and `await`. These just dramatically simplify the use of Promises and allow to write Promise-bsed, async code like sync code that blocks while waiting for network responses or other async events. The value of a fulfilled Promise is like the return value of a sync function.

`await`takes a Promise and truns it back into a return value or a thorown eception. `await p`waits until p settles. If p fulfills, then the value of `await p`is the fulfillment vlaue of `p`. If rejected, then throws the rejection value. Use it before the invocation of a function that just returns a Promise like:

```js
let resp= await fetch("...");
let profile = await resp.json();
```

cuz any code that uses await is just async-- there is one critical rule -- can only use the `await`within functions that have been declared with the `async`keyword -- like:

```js
async function getHighScore(){
    let resp = await fetch("...");
    let profile = await resp.json();
    return profile.highScore;
}
```

NOTE -- Declaring a function `async`just means that the return value of the function will be a `Promise`even if no Promise-related code appears in the body of the function. if an `async`func appears to return normally, then the `Promise`object that is the real return value of the function will resolve to that apparent return value.

for this example, the `getHighScore()`is decalred `async`so returns a `Promise`, and cuz it returns a `Promise`, can use the `await`with that: `displayHighScore(await getHighScore())`. Can:

`getHighScore().then(displayHighScore).catch(console.error)`;

### Awaiting multiple promises

Fore, written like:

```js
async function getJSON(url) {
    let resp= await fetch(url);
    let body = await resp.json();
    return body;
}
```

Now suppose fetch:

```js
let value1= await getJSON(url1);
let value2= await getJSON(url2);
// this is sequential so can:
let [value1, value2]= await Promise.all([getJSON(url1), getJSON(url2)]);
```

### Async Iteration

The `for/await`loop -- like:

```js
async function* clock(interval, max= Infinity) {
    for(let count=1; count<=max; count++) {
        await elapsedTime(interval);
        yield count;
    }
}
```

## TypeScript

Was created internally -- then relesed and open sourced. is 4 things -- 

*programming language* -- includes all the existing Js syntax, plus new syntax

*Type checker* -- takes a set of files written in Js and/or TypeScript, develops an understanding of all constructs.

*Compiler* -- A program that runs the type checker, report any issues, then outputs the equivalent js code.

*Language service* -- use the type checker to tell such as vs code how to provide helpful.

## Type System

The most basic types in Ts correspond to the seven basic kinds in Js -- like:

`null, undefined, boolean, string, number, bigint, symbol`

### Type Annotations

```ts
let rocker; // type any
rocker= "Joe";
rocker.toUpperCase(); //ok
rocker=19.59 // type number
rocker.toPrecision(1); //ok
rocker.toUppercase() // error

let rocker: string;
rocker="joe";
// ->
let rocker;
rocker= "joe"; //js file
```

### Unnecessary Annotations

Type annotations should provide info to Ts that wouldn't have been able to glean on its own. like:

```tsx
let firstName: string ="Tina"; // does not change the type system.
```

Ts does more than check that values assigned to variables match their original types-- also knows what member properties should exist on objects. Can also be more complex shapes, most notably objects.

### Modules

Ts is able to work with those modern module files as well as older files. Like:

`export const shared = "cher"`

`import {shared} from "./a";`

## Unions and Literals

### Union types

```js
let mathmatician = Math.random()>0.5? undefined: "Mark Glodberg";
```

For this -- what is the type of this -- Can be either `undefined`or `string`. This kind of type is called `union`-- Union types are wonderful that let us handle code cases where we don't know exactly which type a value is. Ts uses **`|`**operator between possible values. like:

```tsx
let mathmatican : string | undefined;
```

### Declaring Union types

Union types are an example of a situation when it might be useful to give an explicit type annotation for a variable even though it has an initial value. fore, `thinker`starts off `null`but is known to potentially contain a `string`instead. So:

```js
let thinker : string | null = null;
if(Math.random()>0.5) {
    thinker = "Susan"; // ok
}
```

NOTE: the order of a union type declaration does not matter.

### Union Properties

When a value is known to be a union type, TS will only allow you to access member properties that exist on all possible types in the union. It will give you a type-checking error if you try to access a type that doesn't exist on all possible types. so like:

```tsx
let physicist = Math.random()>0.5 ? "Marie Curie": 84;
physicist.toString(); //ok
physicist.toUpperCase(); // error
```

So, to restrict access to properties that don't exist on all union types a safety measure -- if an obj is not known to definitely be a type that contains a property -- Ts will believe it unsafe to try to use that property.

To use property of a union typed value that only exists on a subset of the potential types, your code will need to indicate to Ts that the value at that location in code is one of those more specific types -- *narrowing*.

### Narrowing

Is when Ts infers from your code that a value is a more specific type than what it was defined, declared, or previously inferred as. Allow you to treat the value like that more specific type. Called a *type guard*. Like:

```tsx
let admiral : number | string;
admiral = "Guard";
admiral.toUpperCase(); //ok
admiral.toFixed(); //error
```

### Conditional Checks

A common way to get Ts to narrow a variable's value is to write an `if`statement just like: `typeof`checks -- In addition to just direct checking, ts recognizes the `typeof`operator in narrowing down variable types like:

```js
let researcher = Math.random() > 0.5
    ? "Rosalind" : 51;
if (typeof researcher === "string") {
    researcher.toUpperCase();
}
```

### Literal Types

`const phisopher= "hyper"`-- is not just any old string -- it's specifically the value `hyper`-- the variable's type is technically more specific `hyper`. This concept is a *literal type*. The literal type just represent just that one string.

Can also think of each primitive type as a *union* of every possible matching literal value. just:

- boolean `true | false`
- number: `0 | 1... 0.1 |..`

Union type annotations can mix and match between literals and primitives. Fore:

```js
let lifespan : number | "ongoing" | "uncertain";
lifespan =80; //ok
lifespan= true; // Error!
```

## Adjusting the box model

Cuz of the problems just encountered, the default box model isn't what you will typically want to use. CSS just allows to adjust the box model behavior with its `box-sizing` property.

`.main {box-sizing: border-box}`

Universal border-box sizing -- like:

```css
*, 
::before,
::after {
    box-sizing : border-box;
}
```

Can make this easier with a slightly modified version of the fix and inheritance -- like:

```css
:root {
    box-sizing: border-box;
}
*, ::before, ::after {
    box-sizing: inherit;
}
.third-party-component {
    box-sizing: content-box;
}

.sidebar {
    float:left;
    width : calc(30% - 1.5em);
}
```

### Controlling overflow behavior

When explicitly set an element's height, run the risk of its contents *overlowing* the container.

`visible, hidden, scroll, auto`

### Applying alternatives to percentage-basd heights

Note that the height of Container is typically determined by the height of its children. this just produces a cricular definition that the browser can't resolve. For percentage heights to work the parent must have an explicit defined height.

### Columns of Equal Height

For earlier, CSS supplanted the use of HTML tables for laying out conent. Could accomplish this by setting an arbitrary height on both columns, but what value choose -- The best solution is for the columns to size themselves naturally, then extend the shorter one.

### CSS table layouts

Just make the container a `display:table`and each column a `display: table-cell`-- like:

```css
.container {
    display:table;
    width:100%;
}

.main{
    display: table-cell;
    width:70%;
    /* ... */
}

.sidebar {
    display: table-cell;
    width:30%;
    margin-left: 1.5em; /* margin no longer work */
    /* ... */
}
```

Can use the `border-spacing`property of the table element -- accepts two length one for horizontal and one for vertical.

```css
.container {
    display:table;
    width:100%;
    border-spacing: 1.5em 0;
    margin-left: -1.5em;
    margin-right:-1.5em;
}
```

Flexbox -- Also can be done with `flexbox`- just like:

```css
.container {
    display: flex;
}
```

By allpying `display:flex`, others not changed - become a *flex container* its children elements will become the *same height by default*. For this, can set widths and margins on the items -- even though this would add up to more than 100% -- the flexbox sorts it out.

### Using `min-height`and `max-height`

Two properties that can be immensely helpful are `min-height`and `max-height`, fore, want to place image behind a larger paragraph of text -- concerned -- instead of setting height, can specify a minimum height and max height.

### Vertically centering content

Here is the simplest way to vertically center in CSS -- give a container equal top and bottom padding.

Negative margins -- Unlike padding and border width, can assign a negative value to margins. When a block element doesn't have a specified width, naturally fills the width of its container.

### Collapsed margins

When top and bottom margins are adjoining, they overlap, combining to form a single margin. The main reason for collapsed margins has to do with the spacing blocks of text. Fore -- `<p>`have 1 em top margin, and 1 em bottom. For `<h2>`element has a bottom margin of .83em, which collapses with the top margin of the following paragraph. And the size of the collapsed margin is just equal to the largest of the joined margins.

### Collapsing multiple margins

Elements don't have to be adjacent siblings for their margins to collapse. In our case, there are 3 different margins collapsing together - the bottom margin of h2, the top of div, and top of p. In short, any adjacent top and bottom margins will collapse together.

NOTE -- Margin collapsing only occurs with top and bottom, left and right don't collapse. Padding just provides another solution -- if add top and bottom padding to the header, the margins inside it won't collapse.

And here are ways to prevent margins from collapsing -- 

- applying overflow: auto prevents margins insdie the container from collapsing
- Adding a border or padding
- Margin won't collapse to the outside of a container that is floated.
- When using flexbox, margin won't collapse between elements that are part of the flex layout.

### Spacing elements within a container

```html
<aside class="sidebar">
    <a href="/twitter" class="button-link">
        Follow us on twitter
    </a>
    <a href="/twitter" class="button-link">
        like us on facebook
    </a>
</aside>
```

```css
.button-link {
    /* fills available space puts each a on own line*/
    display: block;
    padding: 0.5em;
    color: #fff;
    background-color: #0090c9;
    text-align: center;
    text-decoration: none;
    text-transform: uppercase;
}
```

```css
.button-link + .button-link {
    margin-top:1.5em;
}
```

```css
.sponsor-link {
    display: block;
    color:#0072b0;
    font-weight: bold;
    text-decoration: none;
}
```

### Creating a more general sultion -- **lobotomized** owl selector

Instead of fixing margins for the current page contents, fix it in a way that works no matter how the page gets restructured, will do this with * + *. owl selectgor. That is a universal selector that targets all elements, followed by an adjacent sibling combinators. Can: 

```css
body * + * {
    margin-top : 1.5em;
}
```

And cuz the sidebar is an adjancent sibling of the main column, it too receives a top margin -- have to revert that to zero just like:

```css
.sidebar {
    /* ... */
    margin-top : 0;
}
```

Look at the 3 most important methods to alter document flow -- float, flexbox, grid layout. Then lok at positioning, used for stacking elements in front of one another, Note that the flexbox and grid are both new to css and are proving to be essential tools.
