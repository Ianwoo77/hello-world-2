# Optimizing Dockfile to the image layer cache

The Dockerfile is just a simple script you write to package up an application -- it’s a set of instructions, and a Docker image is the output.

```dockerfile
FROM diamol/node

ENV TARGET="baidu.com"
ENV METHOD="HEAD"
ENV INERVAL="3000"

WORKDIR /web-ping
COPY app.js .

CMD ["node", "/web-ping/app.js"]
```

- `FROM`-- every image has to start from another -- in this case, the `web-ping`image will use the `diamol/node`image as its starting point -- that image has `Node.JS`installed.
- `ENV`-- sets the values for *environment variables*. `[key]="[value]"`format .
- `WORKDIR`-- creates a directory in the container image filesystem, and sets that to be the current working directory. The forward `/`works for Linux.
- `COPY`-- Copies files or directoreis from the local filesystem into the container image.
- `CMD`-- Specifies the command to run when Docker starts a container from the image.

For this, should have 3 files, 

- `Dockerfile`-- 
- `app.js`-- which has the Node.JS code
- `README.md`

## Building your own container image

Docker needs to know a few things before it can build an image from a `Dockerfile`-- needs a name for the image, and it needs to know the location for all the files that it’s going to package into the image.

Like:

```sh
docker image build --tag web-ping .
```

The `--tag`jsut is the name for the image -- and the final arg is the directory where the Docker file and related files are. Docker calls this directory the *context*, and the period means *use the current directory*. See output from the build command, executing all the instructions in the Dockerfile.

```sh
docker container run -e TARGET=docker.som -e INERVAL=5000 web-ping
```

That container just is running in the foreground, so need to stop.

## Understanding Docker images and image Layers

The Docker image just contains all the files U packaged -- which become the container’s filesystem -- and it also contains a lot of metadata about the image itself.

```sh
docker image history web-ping
```

Will see an output line for each image layer. NOTE: A docker image is just a logical collection of image layers -- Layers are the files that are physically stored in the Docker Engine’s cache. 

If you have lots of containers all running `Node.js`apps, they will all share the same set of image layers that contain the **Node.js** apps. For the `diamol/node`image, it has a slim operating system layer -- and the the Node.js runtime. Can list image with `docker image ls`command like: It jsut looks like all the Node.js images take up the same amount of space, about 75MB on Ubuntu.

But not exactly -- the size column you see is just the **logical** size of the image -- that is not how much disk space the image would use if you didn’t have any other images on your fsystem.

```sh
docker system df
```

If image layers are shared around -- then can’t be edited -- otherwise a change in one image would cascade to all other images that shares the changed layer.

## Optimizing Dockerfiles to use the image layer cache

And, there is a layer of your `web-ping`image that contains the application’s Js file. If make a change to that file and rebuild your image -- just get a new image layer -- Docker assumes the layers in a Docker image follows a defined sequence -- So, if change a layer in the middle of that sequence -- Docker *doesn’t assume* it can reuse the later layers in the sequence.

like:

```sh
docker image build -t web-ping:v2 .
```

Note, every Dockerfile instruction results in an image layer -- but, if the instruction doesn’t change between builds, and the content going into the instruction is the same -- Docker knows it can use the previous layer in the cache. The input is the same and the output will be the same.

Docker calculates whether the input has a match in the cache by generating a hash. If there is no match for the hash in the existing image layers -- Docker executes the instruction -- breaks the cache. FORE, the `CMD`instruction is the same as the last build -- but cuz the cache was broken so instruction runs as well.

And, there are only 7 instructions in the `web-ping`but, can still be optimized. -- The `CMD`doesn’t need to be at the endo of the Dockerfile -- can be anywhere just after the `FROM`. Can :

```dockerfile
FROM diamol/node

CMD ["node", "/web-ping/app.js"]

ENV TARGET="baidu.com" \
    METHOD="HEAD"  \
    INTERVAL="3000"

WORKDIR /web-ping
COPY app.js .
```

A channel is actually a pointer to a data structure that *contains its internal state.* So the zero-value is `nil`. Cuz of that, channels must be initialized using the `make`keyword.

Closing  a channel is just a *one-time* broadcast to all receiving groutines -- in fact, this is the **only way** to notify multiple goroutines at once.

Receiving from a closed channel is jsut a valid operation -- *a receive* from a *closed channel will always succeed with the zero value of the channel type*. Writing to a closed is a bug. Just **panic.**

So for a receiver, usually important to know whether the channel was closed when the read happended like:

```go
y, ok := <-ch
```

If `ok==false`then the channel was just closed, and the value is simple the zero value. 

For **unbuffered channel**, and behaves in the same way a buffered channel with `len(ch)=0 and cap(ch)=0`. Thus, a send operation will block until another receives from it. Like:

```go
chn := make(chan bool)
go func(){
    ch <- true
}()
go func() {
    var y bool
    y <-ch  // receive block
    fmt.Println(y)
}()
```

And note that an unbuffered channel acts as a sync point between two goroutines. Both goroutines must align for the message transfer to happen.

Transferring a value from one to another *transfers a copy* of the value. So if runs `ch<- x`and sends the value of `x`and another receives it with `y<-ch`, this just equivalent `y=x`with aditional sync guaranteeds. The *crucial point* here is that it *does not transfer the ownership of the value* -- If the transferred value is pointer -- U end up with a shared memory system -- like:

```go
type Data struct {
	Values map[string]interface{}
}

func getInitialValues() map[string]interface{} {
	return map[string]interface{}{
		"one": 1,
		"two": 2,
	}
}

func processData(data Data, pipeline chan Data) {
	data.Values = getInitialValues()
	pipeline <- data
	data.Values["three"] = 3 // possible data race here!
}

func main() {
	ch := make(chan Data)
	data := Data{}
	go processData(data, ch)
	data = <-ch
	fmt.Println(data)
}

```

A map is actaully a pointer to a complex map structure. When data is sent through the channel, the receiver receive a copy of the pointer to the same map structure. 

As a convention, good practice is to assume that if a value is sent via a channel, the ownership of the value is **also** transferred, and *should not use a variable after sending it via a channel*. U can  redeclare it or throw it away.

A channel can be declared with a direction -- such channels are useful as function arguments -- or as function return values like:

```go
var receiveOnly <-chan int // cannot be write or close
var sendOnly chan<- int    // cannot be read or close
```

So the benefit of this is type safety -- a function that takes a send-only as arg -- cannot receive from or close that channel and a function that get a receive-only returned from a function can only receive data but not do sth to it. like:

```go
func streamResults() <-chan Data {
    resultCh := make(chan Data)
    go func() {
        defer close(resultCh)
        resutls := getRsults()
        for _, result := range results {
            resultCh <- result
        }
    }()
    return resultCh
}
```

This is just a  typical way of streaming the results of a query to the caller. Functions start by declaring a bidirectional channel but returns it as a directional one. This just tells the caller that it is only supposed to read from. Channels can be used to communicate with many goroutines -- When multiple goroutines attmept to send to channel or when read from - they are **scheduled randomly**. FORE:

```go
workCh := make(chan Work)
resultCh := make(chan Result)
done := make(chan bool)

// create 10 workers
for i:=0; i<10; i++ {
    go func() {
        for {
            work := <-workCh
            resultCh <-result
        }
    }()
}
results := make([]Result, 0)
go func() {
    ...
}
```

A good way to stop them is to close them once done writing. like:

```go
for _, work := range workQueue {
    workCh<- work
}
close(workCh)
```

And this will just notify the workers that the work queue has been **exhausted** and the work channel is closed. We also changes the workers to check for this like:

```go
go func() {
    for work := range workCh {
        resutlCh <-result
    }
}()
```

With this change, all the running worker goroutines will just terminate once the work channel is closed. But for now, how do we *work with mutliple channels* -- 

```go
select {
case x := ch1:
    // received x from ch1
case y := ch2:
default:...
}
```

Using the `default`option in the `select`statement is useful for non-blocking sends and receives. The default option will only be chosen when all other options are not ready.

In a `select`, all enabled channels have the same likelihood of being chosen. -- there is no channel priority. But, under heavy load, the previous.. may process many.. One way is to *double-check* that:

```go
select {
case req = <-requestCh:
    // received a request to process
    // check if also stop
    select {
    case <-stopCh:
        cleanup()
        return
    default:
    }
case <-stopCh:
    cleanup()
    return
}
```

For this, will re-check the `stop`request after receiving it from the `request`channel.

## Auto-displaying Flash Messages

A little improvement can make is to automate the display of flash messages. Can do this by adding any flash message to the template via the `addDefaultData()`helper method like:

`td.Flash=app.session.PopString(r, "flash")`

And maing that change means that no longer need to check the flash message within the `shoSnippet`handler. Just:

# Security Improvements

Going to make some improvements to our app so our data is kept secure during transit and our server is better able to deal with some common types of *Denial-of-Service* attacks.

- How to quicely and easily **create a self-signed TLS certificate**, using just Go
- The fundamentals of setting up your app so that all requests and responses are **served securely over HTTPs**.
- *Some sensible tweaks* to the default TLS settings to help keep user info secure and performing just quickly.
- How to **set connection timeouts** on server to mitigate Slowloris and other attacks.

## Generating a self Signed TLS Certificate

TLS is essentially the modern version of SSL -- deprecated -- before server can start using HTTPs, need to generate a *TLS certificate* -- for production servers recommend using *Let’s Encrypt* to create your TLS certificates, but for development purposes the simplest thing to do is to generate your won *self-signed certificate*.

Is just the same as a normal TLS -- except it isn’t cryptographically signed by a trusted certificate authority - this means that your web browser will raise a warning for the first time it’s used.

note that the `crypto/tls`package in Go’s stdlib includes a `generate_cert.go`tool that Can use to just easily create our own self-signed certifiate.

Just make a new `tls`dir in the root to just hold the certificate and change into, and to run the `generate_cert.go`tool, need to known the place *where the source code for the go stdlib is installed*.  if under Linux like:

`/usr/local/go/src/crypto/tls`

for my: `sdk/go1.20.3/src/crypto/tls`

just run it as:

```sh
go run ~/sdk/go1.20.3/src/crypto/tls/generate_cert.go -rsa-bits=2048 --host=localhost
```

Behind the scenes, the `generate_cert.go`do two things -- 

1. First generates a 2048-bit RSA key pair, which is a cryptographically seccure public key and private key.
2. It then stores the Private key in a `key.pem`and generates a self-TLS certificate for the `localhost`domain contains the public key -- which it stores in a `cert.pem`file. Both the private and certificate are **PEM encoded**, which is just the std format used by most TLS implementations.

## Running a HTTPs server

Now just have a self-signed TLS certificate and corresponding private key -- starting a HTTPS web server is just need open the go and just:

```go
// use the ListenAndServeTLS() method to start the HTTPs server
// pass in the paths to the TLS certificate and corresponding private key as parameters
err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")
errorLog.Fatal(err)
```

When run this, our server will still be listening on port 4000.

### Additinal information

It’s important to note that our HTTPs server only supports HTTPs. If try making a regular HTTP request to it-- wont work. Http/2 connections -- A big plus of using HTTP2 is -- 

### Certification Permissions

It’s important to note that the user that you r using to run your Go app must have read permissions for both the `cert.pem`and `key.pem`files -- otherwise, `ListenAndServeTLS()`return *permission denied* error.

By default, the `generate_cert.go`file grants read permission to all users for the `cert.pem`but the read permission only the owner of the `key.pem`.

## Configuring HTTP Settings

Go has pretty good default settings for its HTTPs server, but there are a couple improvements and optimizations that need make -- P 233

### How HTTPs works

Can think of a TLS connection  happening in two stages -- (1)Handshake -- client verifies that the server is trusted and genertes some TLS session keys. (2) - actual transmission of the data. data is just encrypted using the TLS session keys. To change the default TLS settings need to do two things:

1. create a `tls.Config`struct which contains the non-default TLS settings 
2. add this to the `http.Server`before start the server.

# Overriding The REL conventions using Fluent API

If prefer using the Fluent API, using the `Entity<T>`to select an entity class, followed by the `Property()`which allows to select and configure individual properties. Fore in the class Shoe:

```cs
public long WidthId {get;set;}
public ShoeWidth? Width {get;set;}
```

Note that to complete the relationship, added the **inverse** nav prop to the `ShoeWidth`class.

`public IEnumerable<Shoe> Products {get; set;}`

In the `DbContext`class:

```cs
builder.Entity<Shoe>()
    .Property(s=>s.WidthId).HasColumnName("FittingId");
builder.Entity<Shoe>()
    .HasOne(s=>s.Width).WithMany(w=>w.Products)
    .HasForeignKey(s=>s.WidthId).IsRequired(true);
```

1. Specify the ForeignKey actually has a name `FittingId`.
2. `HasOne(), HasMany()`methods, also with `WithMany()`and `WithOne()`.

Once have selected the nav props for both ends of the REL, can configure the rel by chaining calls to the methods: Just specify this which is the FK.

## Completing the Data Model

To complete the data model need to define classes to represent the `SalesCompaigns`and `Categories`. 

```cs
[Table("SalesCampaigns")]
public class SalesCampaign
{
    public long Id { get; set; }
    public string? Slogan { get; set; }
    public int? MaxDiscount { get; set; }
    public DateTime? LaunchDate { get; set; }

    public long ShoeId { get; set; }
    public Shoe? Shoe { get; set; }
}
```

Defined in this directly map to the columns - with the excpetion of the `Shoe`prop - which is a nav prop for the one-one REL. And for `Categories`-- mTm rel. need:

```cs
public class Categories
{
    public long Id { get; set; }
    public string? Name { get; set; }

    public ICollection<ShoeCategoryJunction>? Shoes { get; set; }
}
```

And need to represent junction – 

```cs
public class ShoeCategoryJunction
{
    public long Id { get; set; }
    public long ShoeId { get; set; }
    public long CategoryId { get; set; }

    public Category? Category { get; set; }
    public Shoe? Shoe { get; set; }
}
```

Then just adding nav props to the `Shoe`

```cs
public SalesCampaign? Campaign { get; set; }
public IEnumerable<ShoeCategoryJunction>? Categories { get; set; }
```

To provide access – `DbSet<T>`added.

`public DbSet<Category> Categories => Set<Category>();`

### Using the Manually created Data Model

Now that the data model completed, can use the data in the ASP.NET core MVC part, and let the core handle mapping.

```cs
public IActionResult Index()
{
    ViewBag.Styles = context.ShoeStyles
        .Include(s => s.Products);
    ViewBag.Widths = context.ShoeWidths.
        Include(s=>s.Products);
    ViewBag.Categories = context.Categories!
        .Include(c => c.Shoes)!.ThenInclude(j => j.Shoe);

    return View(context.Shoes!
        .Include(s=>s.Style)!
        .Include(s=>s.Width)!
        .Include(s=>s.Categories)!.ThenInclude(j=>j.Category));
}
```

Just error at:

```cs
[Table("Colors")]
public class Style
{
    //... This should be deleted, cuz [InverseProperty(nameof(Shoe.Style))] attr

    // public ICollection<Shoe>? Shoes { get; set; }

    [InverseProperty(nameof(Shoe.Style))]
    public ICollection<Shoe>? Products { get; set; }
}
```

# Redis Cache

### Introduction

There are jsut a lot of users using the internet and if an app has huge network traffic and demand, need to take care of many things which helps us to improve the performance and responsiveness of the application.

### What is Cahing?

Is the memory storage that is used to store the frequent access data into the temporary storage. Just improving and avoid the unnecessary database hit and store frequently used data into the buffer.

### Types of Cache

1. In-Memory
2. Distributed Caching

Distributed caching – there are many third-party mechanisms like Redis and others.

- In the distributed cache, data are stored and shared between multiple servers
- It’s esy to improve scalability and performance of the app after managing the load between multiple severs

**Redis** is the cache which is used by many companies to improve the performance and scalability of the app

## Redis Cache

Implementation of Redis Cache using Core API like:

`Swashbukle.AspNetCore`and `StackExchange.Redis`, and other EF core Nuget packages.

```cs
public class Product
{
    public int ProductId { get; set; }
    public string? ProductName { get; set; }
    public string? ProductDescription { get; set; }
    public int Stock { get; set; }
}
```

Then, just create DbContextClass related operations like: 

```cs
public class DbContextClass : DbContext
{
    public DbContextClass(DbContextOptions <DbContextClass> opts): base(opts) { }
    public DbSet<Product> Products => Set<Product>();
}
```

just create `ICacheService`and `CacheService`class for Redis Cache-related usage like:

```cs
public interface ICacheService
{
    T GetData<T>(string key);
    bool SetData<T>(string key, T value, DateTimeOffset expirationTime);
    object RemoveData(string key);
}
```

And : Some fundation settings:

```cs
public interface ICacheService
{
    T GetData<T>(string key);
    bool SetData<T>(string key, T value, DateTimeOffset expirationTime);
    object RemoveData(string key);
}

public class CacheService: ICacheService
{
    private IDatabase _db;
    public CacheService()
    {
        ConfigureRedis();
    }
    private void ConfigureRedis()
    {
        _db = ConnectionHelper.Connection.GetDatabase();
    }

    public T GetData<T>(string key)
    {
        var value = _db.StringGet(key);
        if(!string.IsNullOrEmpty(value))
        {
            return JsonConvert.DeserializeObject<T>(value!)!;
        }
        return default!;
    }

    public bool SetData<T> (string key, T value, DateTimeOffset expirationTime)
    {
        TimeSpan expiryTime = expirationTime.DateTime.Subtract(DateTime.Now);
        var isSet = _db.StringSet(key, JsonConvert.SerializeObject(value), expiryTime);
        return isSet;
    }

    public object RemoveData(string key)
    {
        bool _isKeyExist= _db.KeyExists(key);
        if (_isKeyExist)
            return _db.KeyDelete(key);
        return false;
    }
}

public class ConfigurationManager
{
    public static IConfiguration AppSetting
    {
        get;
    }
    static ConfigurationManager()
    {
        AppSetting = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json").Build();
    }
}

public class ConnectionHelper
{
    static ConnectionHelper()
    {
        ConnectionHelper.lazyConnection = new Lazy<ConnectionMultiplexer>(() =>
        ConnectionMultiplexer.Connect(ConfigurationManager.AppSetting["RedisURL"]!));
    }

    private static Lazy<ConnectionMultiplexer> lazyConnection;
    public static ConnectionMultiplexer Connection
    {
        get { return lazyConnection.Value; }
    }
}
```

Then, create the `ProductController`class and create the following methods:

```cs
[Route("api/[controller]")]
[ApiController]
public class ProductController : ControllerBase
{
    private readonly DbContextClass _dbContext;
    private readonly ICacheService _cacheService;

    public ProductController(DbContextClass dbContext, ICacheService cacheService)
    {
        _dbContext = dbContext;
        _cacheService = cacheService;
    }

    [HttpGet("products")]
    public IEnumerable<Product> Get()
    {
        var cacheData = _cacheService.GetData<IEnumerable<Product>>("product");
        if(cacheData != null)
        {
            return cacheData;
        }
        var expirationTime = DateTimeOffset.Now.AddMinutes(5.0);
        cacheData = _dbContext.Products.ToList();
        _cacheService.SetData<IEnumerable<Product>>("product", cacheData, expirationTime);
        return cacheData;
    }

    [HttpGet("product")]
    public Product Get(int id)
    {
        Product filteredData;
        var cacheData = _cacheService.GetData<IEnumerable<Product>>("product");
        if(cacheData != null)
        {
            filteredData = cacheData.Where(x => x.ProductId == id).FirstOrDefault()!;
            return filteredData;
        }
        filteredData=_dbContext.Products.Where(x=>x.ProductId==id).FirstOrDefault()!;
        return filteredData;
    }

    [HttpPost("addproduct")]
    public async Task<Product> Post(Product value)
    {
        var obj = await _dbContext.Products.AddAsync(value);
        _cacheService.RemoveData("prodcut");
        await _dbContext.SaveChangesAsync();
        return obj.Entity; 
    }

    [HttpPut("updateproduct")]
    public void Put(Product product)
    {
        _dbContext.Products.Update(product);
        _cacheService.RemoveData("product");
        _dbContext.SaveChanges();
    }

    [HttpDelete("deleteproduct")]
    public void Delete(int id)
    {
        var filteredData= _dbContext.Products.Where(x=>x.ProductId==id).FirstOrDefault();
        _dbContext.Remove(filteredData!);
        _cacheService.RemoveData("product");
        _dbContext.SaveChanges();
    }
}
```

And need to add the SQL server connection string and Redis URL inside appsettings.json.

///////////

And the first thing to note that is the `AddTrailRequest`is not a C# class, but a record – new type in C# 9 and  are considered the **preferable for DTOs**.

`public record AddTrailRequeste(TrailDto Trail)` ===>

```cs
public record AddTrailRequest {
    public TrailDto Trail {get;set;}
}
```

For now , have a request, need to just create a handler for it – going to creat this in the client project.

```cs
public class AddTrailHandler : IRequestHandler<AddTrailRequest,
    AddTrailRequest.Response>
{
    private readonly HttpClient _httpClient;
    public AddTrailHandler(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<AddTrailRequest.Response> Handle(AddTrailRequest request, 
        CancellationToken cancellationToken)
    {
        var response = await _httpClient
            .PostAsJsonAsync(AddTrailRequest.RouteTemplate, request, cancellationToken);

        if(response.IsSuccessStatusCode)
        {
            var trailId = await response.Content
                .ReadFromJsonAsync<int>(cancellationToken: cancellationToken);
            return new AddTrailRequest.Response(trailId);
        }
        else
        {
            return new AddTrailRequest.Response(-1);
        }
    }
}
```

For this, Request handlers implement just the `IRequestHandler<TRequest, TReposne>`interface – `TRequest`is the type of the `IRequest<>`the handler handles, and `TResponse`is the type of response the handler will return. 

The Handler method is specified by the `IRequestHandler`interface is the method called to handle the requeste by the *MediatR*. And the `HttpClient`is used to call the API using the route template defined on the request.

If the request was successful, then the trailId is read from the response and returned using the `AddTrail-Request`. If failed – a response is returned containing a NEG number. just identify a problem.

And, to round out our work on the client, need to hook up our request to the form’s `Submit`event – In the `AddTrailPage.Razor`– going to inject the `MediatR`at the top using the `inject`just like:

`@inject IMediator Mediator`

Then in the page:

```cs
private TrailDto _trail = new TrailDto();
private bool _submitSuccessful;
private string? _errorMessage;

private async Task SubmitForm()
{
    var response = await Mediator.Send(
        new AddTrailRequest(_trail));
    if (response.TrailId == -1)
    {
        _errorMessage = "There was just a problem saving your trail";
        _submitSuccessful = false;
        return;
    }

    _trail = new TrailDto();
    _errorMessage = null;
    _submitSuccessful = true;
}
```

First, added two new fields that are going to be used to show errors to the user. And inside the`SubmitForm`, just using the `Mediator`service supplied by `MediatR`to send the `AddTrailRequset`-- then await the response.

```html
@if (_submitSuccessful)
{
    <div class="alert alert-success" role="alert">
        Your trail has been submitted successfuly!
    </div>
}
else if (_errorMessage is not null)
{
    <div class="alert alert-danger" role="alert">
        @_errorMessage
    </div>
}
```

### Setting up the Endpoint

And in the server proj, first need to set up `ApiEndpoints`– just need to add the `Nuget`package…

```sh
Install-package Ardails.ApiEndpoints
```

Note that, htere is no further configuration required, as the library provides base classes for us to use along with some code analyers – for the dbs,  using SqlServer with EF CORE  – 

### Setting up the dbs – 

First in the API project, create a new folder called `Persistence`is going to complete the setup of our backend by configuring. 

### Configuring the initial entities for the System

Need to create the initial entities for our system – will create two entities called `Trail`and `RouteInsturction`-- Are just **POCOs**, which represent the info want to save to the dbs for each type.

```cs
public class Trail
{
    public int id {  get; set; }
    public string Name { get; set; } = default!;
    public string Description { get; set; } = default!;

    public string? Image { get; set; }
    public string Location { get; set; } = default!;

    public int TimeInMinute { get; set; }
    public int Length { get; set; }

    public ICollection<RouteInstruction> Route { get; set; } = default!;
}

public class RouteInstruction
{
    public int Id { get; set; }
    public int TrailId { get; set; }
    public int Stage { get; set; }
    public string Description { get; set; } = default!;
    public Trail Trail { get; set; } = default!;
}
```

Now that have the entities, need to just configure them for use with EF core. Will allow us to spcify whether a prop should be nullable in the dbs – or whether it should have a character limit… For this proj, need to use the DDD (domain-driven design) in a lot of – but.. start by configuring the `Trail`entity first, inside the `Trail.cs`file, will add an additional class. This will go inside the namespace but outside the existing class.

```cs
public class TrailConfig: IEntityTypeConfiguration<Trail>
{
    public void Configure(EntityTypeBuilder<Trail> builder)
    {
        builder.Property(x => x.Name).IsRequired();
        builder.Property(x=>x.Description).IsRequired();
        builder.Property(x=>x.Location).IsRequired();
        builder.Property(x=>x.TimeInMinute).IsRequired();
        builder.Property(x => x.Length).IsRequired();
    }
}
```

For, this:

1. `IEntityTypeConfiguration<T>`allows us to specify the configuration for the entity defined as `T`. 
2. `IEntityTypeConfiguration<T>`defines the `Configure(EntityTypeBuilder<T>)`method – rules can be specified for each property on the model.

and, doing same for the `RouteInstruction`entity just like:

```cs
public class RouteInstructionConfig : IEntityTypeConfiguration<RouteInstruction>
{
    public void Configure(EntityTypeBuilder<RouteInstruction> builder)
    {
        builder.Property(x => x.TrailId).IsRequired();
        builder.Property(x=>x.Stage).IsRequired();
        builder.Property(x => x.Description).IsRequired();
    }
}
```

# Multiple form Controls

Manipulating individual `FormControl`can be powerful – can be cumbersome. so:

```ts
productForm: FormGroup= new FrormGroup( {
    name:, ... category:...
})
nameField: FormControl = new FormControl("", {
    validators: [...], updateOn: "change",
})
```

```ts
handleStateChanged(newState: SteateUpdate) {
    this.productForm.reset(this.product);
}
```

Has `addControl, setControl, removeControl, controls` and `get(name)` methods for adding or removing controls, and there is methods for managing Control values:

`value, setValue(), patchValue(), reset(val)`

And the `FormGroup`and `FormControl`classes share a common base class, which means that many of the props and methods provided by `FormControl`are also available on a `FormGroup`object, but just applied to all of the controls in the group. like:

```ts
for(let controlName in this.productForm.controls) {
    if(this.productForm.controls[controlName].invalid){
        invalidControls.push(controlName);
    }
}
```

### Using a Form Group with a Form Element

```html
<form [formGroup]="productForm">
    <input class="form-control" formControlName="name" />
</form>
```

So `formGroup`directive is used to specify the `FormGroup`object, and the individual elements are asociated using the `formControlName`attribute. Can directly:

```ts
productForm: FormGroup = new FormGroup({
    name: new FormControl ("", {
        validators: [
            Validators.required,
            Validators.minLength(3),
            Validators.pattern(...);
        ],
        updateOn: "change",
    }),
    
    category: new FormContorl(),
})
```

### Accessing the Form group from the Template

Defines some useful props that allow to complete the transition to the reactive form API – 

`ngSubmit`– event is triggered when the form is submitted.
`submitted`-- returns true if the form has been submitted.
`control`-- returns the `FormControl`has been associated with the directive.

## Displaying Validation Message with a FormGroup

The `formControlName`*directive* doesn’t export an identifer for use in template variable, which complicates the process of displaying validation messages. Instead, errors msut be obtained through the `FormGroup`.

- `getError(v, path)`-- returns the error message, optional `path`is used to identify the control.
- `hasError(v, path)`– returns `true`if has an error message. like:

`form.getError("required", "category")`

```ts
@Directive({
    selector: "[validationErrors]"
})export class ValidationErrorsDirective{
    constructor(private container: ViewContainerRef,
                private template: TemplateRef<Object>) {
    }

    @Input("validationErrorsControl")
    name = "";

    @Input("validationErrorsLabel")
    label?:string;

    @Input("validationErrors")
    formGroup?: FormGroup;

    ngOnInit() {
        let formatter = new ValidationHelper();
        //...
    }
}
```

This new directive obtains a `FormControl`via its `FormGroup`and subscribes to the observable for status changes. Each time the status changes, the validation state is checked.

```html
<ul class="text-danger list-unstyled mt-1">
    <li *validationErrors="productForm; control:'name'; let err">
        {{err}}
    </li>
</ul>
```

## Nesting Form Controls

The `FormGroup`methods accept the `AbstractControl`class, which is the base class for both.. and which allows `FormGroup`object to be just nested – which can be useful way to *group related controls*. Can:

```ts
export class Product {
  constructor(//...
              public details?: Details) {
  }
}

export class Details {
    constructor(public supplier?: string,
                public keyword?:string) {
    }
}

```

The `details`prop will be used to collect additional info about a product – adds values for that:

```ts
new Product(1, "Kayak", "Watersports", 275,
    {supplier: "Acme", keyword:"boat, small"}),
```

For displaying details in the `table.component.html`file:

```html
<td>
    <ng-container *ngIf="item.details else empty">
        {{item.details?.supplier}}, {{item.details?.keyword}}
    </ng-container>
    <ng-template #empty>(None)</ng-template>
</td>
```

Then, for the form partion – a nested `FormGroup`to the form component and pouluates it with `FormControl`objects taht correspond to the new model properties.

```ts
productForm:FormGroup = new FormGroup({
    name: new FormControl("", {
        //...
    }),
    category: new FormControl("", {validators: Validators.required}),
    price: new FormControl("", {
       //...
    }),
    details:new FormGroup({   // note that, new FormGroup
        supplier: new FormControl("", {validators: Validators.required}),
        keywords: new FormControl("", {validators: Validators.required}),
    })
});
```

And to complete the process, adds a new elements to the template like:

```html
<ng-container formGroupName="details">
    <div class="mb-3">
        <label>Supplier</label>
        <input class="form-control" formControlName="supplier" />
    </div>

    <div class="mb-3">
        <label>Keywords</label>
        <input class="form-control" formControlName="keywords" />
    </div>
</ng-container>
```

### Validating Nested Form Controls

Nested form groups can be used to access the status of the elements they contain, which means that the top-level `FormGroup`will report on all the `FormControl`objects, including the nested ones– and the nested `FormGroup`will report on just its controls.

# Dependency Injection

When module A requires module B to run – say B is a *dependency* of A. And one of the most common ways to get access to dependencies is to simply `import`a file. And in many cases, imply importing code is sufficient, but other times we need to provide dependencies in a more sohpisitcated way.

- Substitute out the implementation of `B`for `MockB`during tesing.
- Share a *single* instance of the `B`class acorss whole app.
- Create a new instance of the B every time it is used.

## Injections Example `PriceService`

```ts
export class Product {
	service: ProdcutService;
	basePrice: number;
	
	constructor(basePrice:number) {
		this.service=new ProdcutService();
		this.basePrice=basePrice;
	}
	
	totalPrice(state: string) {
		return this.service.calculateTotalPrice(this.basePrice, state);
	}
}
```

For this, need to write a test for the `Product`class, could write a test like this:.. In this case often *mock* the `PriceService`. Fore, if know the *interface* of a `ProductService`, could write a `MockPriceService`. like:

```ts
export interface IPriceService {
	calculateTotalPrice(basePrice: number, state: string): number;
}

export class MockPriceService implements IPriceService {
	calculateTotalPrice(basePrice: number, state: string): number {
		if (state === "FL") {
			return basePrice + 0.66;
		}
		return basePrice;
	}

}
```

Now, just written a `MockPriceService`– modify the `Product` like:

```ts
import {MockPriceService} from "./price-service.interface";
import {Product} from "./product.model.1";

describe('Product', () => {
	let product: Product;

	beforeEach(() => {
		const service = new MockPriceService();
		product = new Product(service, 11.00);
	});

	describe('price', () => {
		it('is calculated based on the basePrice and the state', () => {
			expect(product.totalPrice('FL')).toBe(11.66);
		})
	})
})
```

But, with Angular’s DI system, instead of directly `import`and creating a `new`instance of a class, instead of:

- register the *dependency* with Angular.
- Describe *how* the dependency will be *injected*
- Inject the DEPT

### Dependency Injection Parts

To register a dependency we have to **bind it** to sth that will identify that denpendency. This identification is called the **dependency token**.

In Angular DI has three pieces: 

- The `Provider`maps a *token* to a list of DEPTs. Tells Angular how to create an object, given a token.
- The `Injector`that holds a set of bindings and is responsible for resolving dependencies and injecting them when creating objects.
- The `Dependency`that is what’s being injected.

### Playing with an Injector

Angular uses an *injector* to `resolve`a dependency and **create the instance**. This is done for us – but an exercise, it’s useful to explore – Fore, *manually use the injector* in own component to resolve and create a service.

One of the common use-case for services is to have a global Singleton object. FORE, might have a `UserService`which contains the info for the currently logged in user. Many different components will want to have logic based on the current user.

```ts
@Injectable()
export class UserService {
	user: any;

	setUser(newUser: any) {
		this.user = newUser;
	}

	getUser(): any {
		return this.user;
	}
}
```

Just want to create a toy sign-in form like:

```html
<div>
	<p *ngIf="userName"
	   class="mb-3">
		Welcome: {{userName}}
	</p>
	<button (click)="signIn()" class="btn btn-primary btn-sm">
		Sign in
	</button>
</div>
```

And create the component like:

```ts
@Component({
	selector: 'app-inject-demo',
	templateUrl: 'user-demo.component.html',
})
export class UserDemoInjectorComponent {
	userName?: string;
	userService: UserService;

	constructor() {
		const injector: any = ReflectiveInjector.resolveAndCreate([UserService]);
		this.userService = injector.get(UserService);
	}

	signIn(): void {
		this.userService.setUser({
			name: 'Nate Murray',
		});

		this.userName = this.userService.getUser().name;
		console.log('user name is ', this.userName);
	}
}
```

This just start as a basic component - have a selector, template and CSS – two properties, manly is the `userService`which holds a reference to the `UserService`class. In this, just using the `constructor`static method from `ReflectiveInjector`called `resolveAndCreate()`-- that method is responsible for creating a new injector.

The parameter psssed in is an array with all the `injectable things`we want this new injector to *know*. just wanted it to know about the `UserService`injectable. Using the *reflection* to look up the proper parameter types.

- Use `NgModule`to register what will inject – called providers and
- Use decorators (generally on a ctor) to specify what we are injecting.

By doing these two steps, `Angular`will manage creating the injector and resolving the dependencies.
