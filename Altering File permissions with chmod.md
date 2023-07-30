# Altering File permissions with `chmod`

```sh
chmod a-w readme.txt
chmod u+rw readme.txt
# can also use the octal form of the chmod ommand like:
chmod 600 readme.txt
```

### File Permissions with `umask`

When create a file, created with a default set of permissions, `666`. For directories have a default set of permissions, `777`, can view and modify the default permissions for either with `umask`. Fore, when a file is created by a user account, whether that account is owned by a human or a process, if U want all new  dirs to be created with a default 777, type:

```sh
umask 000
```

The default `umask`is `022`, means files are created by default with `644`.

File Permissiongs with `chgrp`– use this to change the group.

Changing File permissions with `chown`– use this to change the owner of a file like:

```sh
chown  ian filename
# can also to change the group of a file
chown ian:sudo filename
```

## Wroking with Files

Managing Files in home dir involves using one or more commands – 

```sh
touch myFile
```

Can also create a file in a different location by changing what is after `touch`

`touch randomdir/newfile # dir already exists`

For `mkdir`, thereis a `-p`option – enables create a dir and its parent at the same time.

### Deleting with `rmdir`

```sh
rmdir directoryname
```

### Deleting with `rm`

```sh
rm filename
```

Note that to delete a directory and all its contents, use the `-r`recursive switch.

### Copying with `cp`and move with `mv`

```sh
cp oldfilename newfilename
```

### Displaying with `cat`, `less`

Can using regexp – each of the commands can be used with pattern-matching strings *wildcards*. like:

```sh
rm abc*
```

## Working as a Root

FORE, when you work in root, can destroy a running system with a simple invocation of the `rm`command like this:

```sh
sudo rm -rf / --no-preserve-root
```

# Command-line Master Class

Assuming that : prints info about your CPU, and stripping out multiple blank lines and numbering the output, for `cat`, `-n	`option numbers the lines in the output, and `-s`prints a maximum of one blank line at a time. -s just combine the blank lines like:

```sh
cat -sn /proc/cpuinfo
```

Can also use `cat`to print the contents of several files at once like:

```sh
cat -s myfile.txt myotherfile.txt
```

`chomd`has a simple option `-c`, instructs `chmod`to print a list of the changes.

du – disk usage…

### Using `echo`

Can do many with `echo`, especially with redirection – `echo`just sends whatever you tell it to send to std output. fore:

```sh
TERM=100
echo $TERM
```

Can redirect the output of the `echo`into a text file, like:

```sh
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
```

Can change or set a kernel setting like:

```sh
sudo sh -c 'echo "1" > /proc/sys/location/of/settings'
```

Finding Files by searching with fore:

```sh
find -name "*.txt"
find /home -name "*.txt"
find /home -name "*.txt" -size 100k # or +100k, or -100k

# -user opt enables to specify the user who owns files looking for
find /home -name "*.txt" -szie -100k -user ian # or -not user ian
# also use -perm to specify which permissions a file should have
find /home -perm -o=r
```

If you use neither + or -, are specifying the exact permissions to search for.

```sh
find /home -perm +o=rw # does not match o=r or o=w
find /home -perm ugo=r # exact macth
```

### Searches for string in Input with `grep`

The `grep`– processes any text like:

```sh
grep "some text" *
```

Searches all files in the current dir for the string specified.

```sh
grep -r "some text" * # search recursively
grep -v "hello" myfile.txt # search all lines NOT contains the hello
# -i for case-insensitivity
# or using regexp like
grep "[cms]at" myfile.txt
grep -i [cms]at myfile.txt
grep -in --color [cms]at readme.txt
```

# Reading and Writing Data

The `Reader`and `Writer`defined by the `io`and provide abstract way to read and write data.

`Read(byteSlice)`– reads data into the specified []byte.

`Write(byteSlice)`– writes data from the specified byte. returns number and error

## Concatenating multiple Readers

The `MultiReader`func concenates the input from multiple readers like:

```go
func ConsumeData(reader io.Reader) {
	data := make([]byte, 0, 10)
	slice := make([]byte, 2)
	for {
		count, err := reader.Read(slice)
		if count > 0 {
			Printfln("Read data %v", string(slice[0:count]))
			data = append(data, slice[0:count]...)
		}
		if err == io.EOF {
			break
		}
	}
	Printfln("Read data: %v", string(data))
}

func main() {
	r1 := strings.NewReader("Kayak")
	r2 := strings.NewReader("Lifejacket")
	concatReader := io.MultiReader(r1, r2)
	ConsumeData(concatReader)
}
```

## Buffering Data

The `bufio`provides support for adding buffers to readers and writers.

```go
reader = bufio.NewReader(reader)
```

The buffered `Reader`fills its buffer and uses the data it contains to respond to calls `Read()`

## Working with JSON Data

Reading and writing – the `encoding/json`pacakge provides support for encoding and decoding. FORE:

- `NewEncoder(writer)`– returns an Encoder, which can be used to encode JSON write to specified writer
- `NewDecoder(reader)`– returns a Decoder, can be used to read json from specified Reader and decode it.
- `Marshal(value)`– encode as json, result is json content in a byte slice and an `error`.
- `Unmarshal(byteSlice, val)`-- parses JSON in slice and assigns the result to value.

```go
var writer strings.Builder
encoder := json.NewEncoder(&writer)
for _, val := range []interface{}{b, str...} {
    encoder.Encode(val)
}
fmt.Print(writer.String()) // no "\n"
```

```go
func main() {
	names := []string{"kayak", "lifejacket", "Soccer ball"}
	numbers := [3]int{10, 20, 30}
	var byteArray [5]byte
	copy(byteArray[:], []byte(names[0]))
	byteSlice := []byte(names[0])

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	encoder.Encode(names)
	encoder.Encode(numbers)
	encoder.Encode(byteArray)
	encoder.Encode(byteSlice)  // expressed as base64-encoded string

	fmt.Print(writer.String())
}
```

### Encoding Maps

Go maps are encoded as JSON **objects**, with the map keys as the object keys. The value contained in the map are encoded based on their type.

```go
func main() {
	m := map[string]float64{
		"Kayak":      279,
		"Lifejacket": 49.95,
	}

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	encoder.Encode(m)
	fmt.Print(writer.String())
}

```

### Encoding Structs

The `Encoder`express struct values as JSON objects, using the **exported** field names as the obj’s keys and the field values as object’s values.

```go
func main(){
    var writer strings.Builder
    encoder := json.NewEncoder(&writer)
    encoder.Encode(Kayak)
    fmt.Print(writer.String())
}
```

### The effect of Promotion in JSOn in Encoding

```go
type DiscountedProduct struct {
	*Product
	Discount float64
}

func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	dp := DiscountedProduct{
		&Kayak, 10.50,
	}
	encoder.Encode(&dp)
	fmt.Print(writer.String())
}
```

notice that encodes a pointer to the `struct`value. The `Encode()`just follows the pointer and encodes the value at its location.

## Customizing the JSON encoding of Structs

How a struct is encoded can be just customized using *struct tags* – are string literals that follow fields. fore:

```go
type DiscountedProduct struct {
	*Product `json:"product"`
	Discount float64
}

```

### Omitting a Field

```go
Discount float64 `json:"-"`
// omit unassigned:
*Product `json:"product,omitempty"`
// skip nil without changing name
*Product `json:",omitempty"`
// forcing fields to be encoded as strings
Dsicount float64 `json:",string"`
// encode to: `{"Discount":"10.5"`}
```

### Ecnoding interfaces

JSON encoder can be used on vlaues assigned to interface variables.

```go
type Named interface{ GetName() string }
type Person struct{ PersonName string }

func (p *Person) GetName() string {
	return p.PersonName
}
func (p *DiscountedProduct) GetName() string {
	return p.Name
}

func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	dp := DiscountedProduct{
		&Kayak, 10.50,
	}
	namedItems := []Named{&dp, &Person{PersonName: "Alice"}}
	encoder.Encode(namedItems)
	fmt.Print(writer.String())
}

```

Note the slice of `Named`values contains different dynamic types, which can be seen by compiling and executing proj.

# The `http.Handler`interface

Creating an obj just can implement a `ServeHTTP()`method on its long-winded and a bit.. like:

```go
func home(w http.ResponseWriter, r *http.Request) {
    w.Write(...)
}
```

For `home`, just a normal func, need *transform* it into a handler using `http.HandlerFunc()`adpater.

```go
mux := http.NewServeMux()
mux.Handle("/", http.HandlerFunc(home))
```

Works by automatically add a `ServeHTTP()`to the home function, when executed, this method then simply calls the content of the original `home`function.

### Chaining Handlers

The `http.ListenAndServe()`jsut takes a `http.Handler`object as the second parameter. Cuz the `servemux`also has a `ServeHTTP()`.

### Requests are handled Concurrently

There – *all incoming http requests are served in their own goroutine*.

## Configuration and Error Handling

- Set configuration settings for app at runtime in a esy and idiomatic way using command-line flags
- Imporving log message
- Make dependencies available to handlers
- Centralize error handling.

```go
func main() {
	// Define a new command-line flag
	addr := flag.String("addr", ":4000", "http network address")

	// then use Parse() func to parse the command flag
	flag.Parse()
	//... other same

	log.Printf("Starting server on : %s", *addr)
	err := http.ListenAndServe(*addr, mux)
	log.Fatal(err)
}
```

Type conversions – In code using the `flag.String()`to define the command-line flag. Also including `flag.Int()`

## Leveled Logging

- will prefix informational messages with `INFO`and output to std out
- Prefix error messages with `ERROR`and output them to std error.

```go
// use log.New() to create a logger for writing info
infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)

// create a logger for writing error message in same way
errorLog := log.New(os.Stderr, "ERROR\t", log.Ldate|log.Ltime|log.Lshortfile)
//...

infoLog.Printf("Starting server on : %s", *addr)
err := http.ListenAndServe(*addr, mux)
errorLog.Fatal(err)
```

## The http.Server Error log

There is one more change need to make to our app – by default, if Go’s HTTP server encounters an error will log it using the std logger. But, for consistency, it’d be better to use new `errorLog`instead - need to initialize a new `http.Server`struct containing the configuration settings for our server. Instead of using `http.ListenAndServe()`

```go
srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  mux,
}
infoLog.Printf("Starting server on : %s", *addr)
err := srv.ListenAndServe()
errorLog.Fatal(err)
```

### Additional info

As a rule of thumb, should avoid using the `Panic()`and `Fatal`method to write log message.

### Concurrent Logging

Custom loggers created by `log.New()`are just concurerncy-safe. Can share a single logger and use it across multiple goroutines and in you handlers without needing to worry about race conditions.

## Dependency Injection

Note – there is one more problem with our logging that need to address – If open – `home`handler is still writing error messages using std logger.

The simplest being to just put the dependencies in global variables. But in general, it is good practice to *inject dependencies* into your handlers.

For applications where all your handlers are the same package – a neat way to inject is to put them into a custom `application`struct, and then define your handler function just as its method.

```go
// in the main.go
// Define an app struct to hold the application-wide dependency for the app
type application struct {
	errorLog *log.Logger
	infoLog  *log.Logger
}
//... 
app := &application{errorLog, infoLog}
mux := http.NewServeMux()
mux.HandleFunc("/", app.home)
mux.HandleFunc("/snippet", app.showSnippet)
mux.HandleFunc("/snippet/create", app.createSnippet)
```

## Understanding the required REL Delete Operation

The FK prop rsulted in two important changes after migration. The first is to prevent `null`from being stored, The second – Before FK prop was defined, FK was created configured the FK like:

`onDelete: ReferentialAction.Restrict`– the restrict is used for optional relationships and configures the dbs, so that a `Supplier`cannot be deleted while there are rwos in the `Products`depend on it.

When created required REL – FK is reconfigured with a different value like:

`onDelete: ReferentialAction.Cascade`– when this is used, deleting a Supplier causes a *cascade deleting*, any other Product objects that depends on this `Supplier`will be deleted.

It is important to understand is the act of deleting the `Supplier`object that triggers the cascade. Bear in mind that it is the just dbs server and not EF core that performs the cascade delete.

### Prin and Dept relationships

- PRIN – contains a PK that the DEPT refer to via a FK
- DEPT – contains the FK refers to PRIN entity’s PK.

So for this `Supplier`and `Product`, the `Supplier`is PRIN, `Product`is just DEPT. `Product`has a FK refers to `Supplier`'s PK.

## Querying for Multiple Relationships

The process for creating, updating, and deleting more complex related data is the same. Add class file: like: then just add new migration. Then, need to drop and update the dbs.

And to ensure that there is some data to query when the dbs is seeded, added the statements:

```cs
ContactLocation hq = new ContactLocation
{
    LocationName = "Corporate HQ",
    Address = "200 Acme Way"
};
ContactDetails bob = new ContactDetails
{
    Name = "Bob Smith",
    Phone = "555-107-1234",
    Location = hq,
};

Supplier acme = new Supplier
{
    Name = "Acme Co",
    City = "New York",
    State = "NY",
    Details = bob
};
```

### Querying the Chain of Navigation Properties

The`ThenInclude`method is used to extend the scope of query to follow navigation properties. just like:

```cs
public Product GetProduct(long id)
{
    return context.Products
        .Include(p=>p.Supplier)
            .ThenInclude(s=>s!.Details)
                .ThenInclude(d=>d!.Location)
        .First(p=>p.Id== id);
}
```

The arg to the `ThenInclude()`method is a labmda function that operates on the type selected by the previous call to `Include`or `ThenInclude`and selects the nav prop want to follow.

```html
@if (Model.Supplier?.Details != null)
{
    <div class="mb-3">
        <label asp-for="Supplier.Details.Name"></label>
        <input asp-for="Supplier.Details.Name" class="form-control" readonly />
    </div>
    
    <div class="mb-3">
        <label asp-for="Supplier.Details.Phone"></label>
        <input asp-for="Supplier.Details.Phone" class="form-control" readonly />
    </div>
    
    <div class="mb-3">
        <label asp-for="Supplier.Details.Location.LocationName"></label>
        <input asp-for="Supplier.Details.Location.LocationName" class="form-control" readonly />
    </div>
}
```

## Scalar props, Value Converters, Shadow Properties, backing fields

Three ways of Configuring EF core – 

- By Convention
- Data Annotations
- Fluent APIs

## RESTFul principles and guidelines

### Client-Server approach

For web api in REST–

- can only respond to request initiated by the clients
- CORs – is a HTTP-header based mechansims..

The whole purpose of CORs is to allow browsers to access resouces using HTTP requests initiated from scripts. If want the browser to perform that call – need use `CORS`to instruct it to relax such policy and allow HTTP requests initiated by external origins.

It’s just important to understand that the *Same-Origin Policy* is ust security mechanism controlled by browser, Not by server – It’s not a HTTP response error sent by server cuz the client is not autorized.. But a block applied by the client after completing a HTTP request, receiving the response, and checking headers returned with it to determine what to do.

And, all modern browsers use two main techniques to check for CORs settings  – 

1. Same HTTP request/response
2. preflight – involves an additional HTTP `OPTIONS`request.

Whenever a client-side script initiate an http request – the browser checks if it meets a certain requirement – if all met, the HTTP request is processed as normal – `CORS`is handled by just checnking the `Access-Control-Allow-Origin`header and ensuring it complies with the origin of the script that issued the call.

And in case of HTTP request doesn’t meet any of the above – the browser will put it on hold and automatically issue a preemptive HTTP `OPTIONS`requrest before it.

The *Preflight* request uses 3 headers to describe the server the characteristics of subsequent request–

- `Acceess-Control-Request-Method:`The HTTP method of the request
- `Access-Control-Request-Headers`-- A list of custom headers that will sent with request
- `Origin`– Origin of the script initiating the Call.

For the server, if properly configured to handle this kind of request, will answer with the following response:

- `Access-Control-Allow-Origin`– Origin allowed to make the request
- `Access-Control-Allow-Headers`-- A comma-separated list of allowed methods
- `Access-Control-Max-Age`-- how long the results hits preflight request can be cached. (Seconds)

Not, when set up server-side – need to know what want to allow and what not.

## Implementing CORs

CORs can be set up using a dedicating service, which gives us the chance to define a default policy and/or various named policies. – as always, such service must be added in the service container.

Different policies can be used to allow `CORs`for specific origins fore, http headers and/or methods fore:

```cs
builder.Services.AddCor(opts=>
                       opts.AddDefaultPolicy(cfg=>{
                           cfg.AllowAnyOrigin();
                           cfg.AllowAnyHeader();
                           cfg.AllowAnyMethod();
                       }));
```

For that very reason, would be safer to define a more restrictive default policy.

- A default policy which accepts every HTTP header and method only from restricted set of known *origins*, can safely set whenever we need it.
- A “AnyOrigin” named policy that accepts everything from everyone – which can use situationally use for a very limited set of endpoints that we wat to make availabvle for any client.

FORE:

```cs
builder.Services.AddCor(opts=>{
    opts.AddDefaultPolicy(cfg=> {
        cfg.WithOrigin(builder.Configuration["AllowedOrigins"]);
        cfg.AllowAnyHeader();
        cfg.AllowAnyMehtod();
    });
    
    opts.AddPolicy(name: "AnyOrigin", 
                  cfg=> {
                      cfg.AllowAnyOrigin();
                      cfg.AllowAnyHeader();
                      cfg.AllowAnyMehtod();
                  });
});
```

The value that we pass to the `WithOrigins()`will be returned by the server with the `Access-Control-Allow-Origin`header, which indicates to the client which origin(s) should be considered valid.

In the appSettings.json, add new `AllowOrigins`key:

fore: 

```json
{
    //...
    "AllowedOrigins" : "*",
    ...
}
```

`*`can be used as wildcard to allow any origin to access the resource when the request has no credentials. So, if request is set to allow credentials, the `*`wildcard can’t be used and would result in an error.

Such behavior, which requires both the server and the client to acknowledge that it is ok to include credentials on requests and to specify a specific origin, Has been enforced to reduce the chance of `Cross-Site Request Forgery`(**CSRF**) in CORS. The reason for that is simple to understand - hence they just require additional security measures.

## Applying CORs

Core give 3 ways to enable CORs – 

- The *CORS* middleware
- Endpoint routing
- The `[EnableCors]`attribute

And the CORS middleware is the simplest tech to use. right before the `app.UseAuthorization`.

```cs
app.UseCors();
app.UseAuthorization();
```

And in the case wanted to apply the `AnyOrigin`named policy to all our endpoints instead of the default, can:

`app.UseCors(“AnyOrigin”)`

Doing so would make no sense – definitely not our case – So can take the chance to apply this named policy to them using the *endpoint routing method*.

```cs
app.MapGet("/errors", ()=>Results.Problem()).RequireCors("AnyOrigin");
app.MapGet("/errors/test", ()=>{throw new ExceptioN("test");})
    .RequireCors("AnyOrigin");
```

Can see, *endpoint routing* allow to enable CORs on a per-endpoint basis using the `RquireCors()`extension method. Such approach is just good for non-default named policies.

However, if want to use it for `Controllers`, like:

`app.MapControllers().RequireCors("AnyOrigin")`-- Won’t have the same level of granularity.

And, enabling CORs using the `RequireCors()`currently doesn’t not support automatic **Preflight** requests. But the same granularity it offers is also granted by the 3rd and last technique – `[EnableCors]`qttribute like:

```cs
app.MapGet("/errors", [EnableCors("AnyOrigin")])()=> {Result.Problem();};
```

Use this, just add: `using Microsfot.AspNetCore.Cors;`namespace. For this, can assigned to any controller and/or action method – thus, allowing us to implement our CORs named policies in a simple and effective way.

# WebAssembly

Is an implemenation of Blazor that runs in the browser using WebAssembly. Allows client-side apps to be written in C# without server-side execution or the persistent HTTP connection required by Server.

Define a web service controller just like:

```cs
[Route("api/people")]
[ApiController]
public class DataController : ControllerBase
{
    private DataContext context;

    public DataController(DataContext ctx)
    {
        context = ctx;
    }

    [HttpGet]
    public IEnumerable<Person> GetAll()
    {
        IEnumerable<Person> people =
            context.People.Include(p => p.Department).Include(p => p.Location);
        foreach (Person p in people)
        {
            if (p.Department?.People != null)
            {
                p.Department.People = null;
            }
            if (p.Location?.People != null)
            {
                p.Location.People = null;
            }
        }
        return people;
    }

    [HttpGet("{id}")]
    public async Task<Person> GetDetails(long id)
    {
        Person p = await context.People.Include(p => p.Department)
            .Include(p => p.Location).FirstAsync(p => p.PersonId == id);
        if (p.Department?.People != null)
        {
            p.Department.People = null;
        }

        if (p.Location?.People != null)
        {
            p.Location.People = null;
        }

        return p;
    }

    [HttpPost]
    public async Task Save([FromBody] Person p)
    {
        await context.People.AddAsync(p);
        await context.SaveChangesAsync();
    }

    [HttpPut]
    public async Task Update([FromBody] Person p)
    {
        context.Update(p);
        await context.SaveChangesAsync();
    }

    [HttpDelete("{id}")]
    public async Task Delete(long id)
    {
        context.People.Remove(new Person { PersonId = id });
        await context.SaveChangesAsync();
    }

    [HttpGet("/api/locations")]
    public IAsyncEnumerable<Location> GetLocations() =>
        context.Locations.AsAsyncEnumerable();

    [HttpGet("/api/departments")]
    public IAsyncEnumerable<Department> GetDepts() =>
        context.Departments.AsAsyncEnumerable();
}
```

This just provides actions that allow `Person`objects to be created… Note that also added actions that return `Location`and `Department`objects.

## Setting up Blazor WebAssembly

Blazor WebAssembly needs a separate proj so that can be compliled ready to be executed by the browser.

```cs
app.UseBlazorFrameworkFiles("/webassembly");
app.MapFallbackToFile("/webassembly/{*path:nonfile}", "/webassembly/index.html");
```

The next is to modify the HTML file that will be used to respond to requests for the `/webassembly`url.

in the .proj:

```xml
<StaticWebAssetBasePath>/webassembly/</StaticWebAssetBasePath>
```

in the wwwroot/index.html:

```html
<base href="/webassembly/" />
```

## Creating a Blazor WebAssembly Component

Uses the just same approach as Blazor Server – relying on components as building blocks for appliations, connected through the routing system, and displaying common content through layouts.

### Creating a Component

Just add a List.razor just like the old list like:

```cs
@code {

    [Inject]public HttpClient? Http { get; set; }

    public Person[] People { get; set; } = Array.Empty<Person>();

    protected async override Task OnInitializedAsync()
    {
        await UpdateData();
    }

    private async Task UpdateData()
    {
        if (Http != null)
            People = await Http.GetFromJsonAsync<Person[]>("/api/people")
                     ?? Array.Empty<Person>();
    }

    string GetEditUrl(long id) => $"forms/edit/{id}";
    string GetDetailsUrl(long id) => $"forms/details/{id}";

    public async Task HandleDelete(Person p)
    {
        if (Http != null)
        {
            HttpResponseMessage resp =
                await Http.DeleteAsync($"/api/people/{p.PersonId}");
            if (resp.IsSuccessStatusCode)
                await UpdateData();
        }
    }

}
```

Notices that the URLs that are use for navigation are expressed without a leading forward-slash. Cuz the root URL for the apps was specified the `base`element, and using relative URLs ensures that navigation is performed relative to the root.

## Getting Data in a Blazor WebAssembly Component

The biggest change is that WebAssembly can’t use EF core – The browser restricts WebAssembly applications to HTTP requests, preventing the user of the SQL.. To get data, Blazor WebAssembly app consume web services, which is this – As part of the Blazor WebAssembly app startup, a service is created for the `HttpClient`class, which components can receive using the std injection features.

- `GetAsync(url)`- sends an HTTP get
- `PostAsync(url, data)`-- post
- `PutAsync, PatchAsync, DeleteAsync, SendAsync(request)`

These methods returns a `Task<HttpResonseMessage>`result which describes the response received from the HTTP server to the async request. Has:

- `Content`– returns the conent returned by the server.
- `HttpResponseHeaders`– this returns the response headers
- `StatusCode`
- `IsSuccessStatusCode`– returns `true`if the response status code is between 200 and 299.

And, the List uses the `DeleteAsync`to ask the web service to delete objects. These is useful wehn you don’t need to work with the data the web service sends back.

For operations where the web service returns data, the extension methods for the `HttpClient`are more useful: – these serialize data into JSON so can be sent to the server and parse JSON responses to C# objects.

- `GetFromJsonAsync<T>(url)`– sends HTTP GET and parses the response to type `T`.
- `PostJsonAsyn<T>(url, data)`– sends HTPT POST with the serialized data value of `T`.
- `PutJsonAsync<T>(url, data)`

### Creating a Layout

Blaozr WebAssembly components just follow the std blazor lifecycle, and the component displays the data it receives from the web service.

# Pipe

```ts
@Pipe({
    name:"addTax"
})export class PaAddTaxPiep {
    defaultRate=10;
    transform(value:any, rate?:any):number{
        let valueNumber= Number.parseFloat(value);
        let rateNumber= rate==undefined?
            this.defaultRate: Number.parseInt(rate);
        return valueNumber+...;
    }
}
```

pure – When `true`- pipe is just re-evaluated only when its input value or its args are changed. `transform`must accept at least one arg, which Ng uses to provide the data value that the pipe formats. Namely, before the `|`.like:

```html
<td>{{item.price | addTax:(taxRate || 0)}}</td>
```

### Combining Pipes

The `addTax`is applying the tax rate– but the factional amount is unsightly. A better is to combine the functionality of the built-in `currency` just like:

```html
<td>{{item.price | addTax:(taxRate || 0) | currency:"USD":"symbol"}}</td>
```

## Creating Impure Pipes

The `pure`tell Ng when to call the pipe’s `transform()`method. pure=true tells Ng that the pipe’s `transform()`will generate a new value only if the input data value – changes or one or more its arg is modified. This is called *pure* cuz it has no independent internel state.

false pure – tells Ng that the pipe has its own state data or it depends on data that may not be picked up in the change detection process.

When Ng preforms its change detection process, it treats impure pipes as a source of data values in their own right and invokes the `transform`even when there has been no data value or arg changes. When process the content of arrays and the elements in the array changes – most common need.

```ts
@Pipe({
	name: "filter",
	pure: true
})
export class PaCategoryFilterPipe {
	transform(products?: Product[], category?: string): Product[] {
		if (products == undefined)
			return [];
		return category == undefined ?
			products : products.filter(p => p.category == category);
	}
}
```

```html
<tr *ngFor="let item of getProducts() | filter:categoryFilter; let i = index; let odd=odd;..
```

For this, the new product won’t be shown in the table. Just change the `pure`to `false`. It’s ok.

## Using the Built-in Pipes

`number, currency, percent, date, uppercase, lowercase, titlecase, json, slice, keyvalue, async`

### Formatting Numbers

```html
<td>{{item.price | number:"3.2-2"}}</td>
```

Accepts a single arg specifies the number of digits are included in the formatted result.

### Formatting Currency Values

can also be used as: 

```html
<td>{{item.price | currency:"USD":"symbol":"2.2-2"}}</td>
```

### Formatting Percentages

```html
<option value="10">{{0.1 | percent}}</option>
```

### Formatting Dates

The `date`pipe performs location-sensitive formatting of dates.

```html
<div class="bg-info p-2 text-white">
	<div>Date formatted from object: {{dateObject | date}}</div>
	<div>Today formatted: {{ today | date:"shortDate"}}</div>
</div>
```

### Change case

```html
<td>{{item.name | uppercase}}</td>
```

### Serializing Data As JSON

The `json`pipe creates a JSON representation of a data value. No arg are accepted by this.

```html
<div>{{getProducts() | json}}</div>
```

### Slicing Data Arrays

The `slice`operates on an array or string and returns a subset of the elements or characters it contains. This is an **impure** pipe– means will reflect any changes.

### Key-Value pairs

This operates on an object or a map and returns a sequence of k-v pairs.

```html
<tr *ngFor="let item of getProducts() | keyvalue">
    <td>{{item.key}}</td>
    <td>{{item.value | json}}</td>
</tr>
```

Values are objects in the array – so need to be formatted using the `json`filter.

### Selecting Values

The `i18nSelect`selects a string based on a value, allowing context-sensitive values to be displayed to the user.

```js
selectMap = {
    Watersports: "stay day",
    Soccer: "core goals",
    other: "have fun"
}
// .... 
```

```html
<tr *ngFor="let item of getProducts()">
    <td>Helps you {{item.category | i18nSelect:selectMap}}</td>
</tr>
```

### Pluralizing Values

```html
<div class="bg-warning text-white p-2">
	<div>There are {{1 | i18nPlural:numberMap}}</div>
	<div>There are {{ 2 | i18nPlural:numberMap}}</div>
	<div>There are {{100 | i18nPlural:numberMap}}</div>
</div>
```

```js
numberMap = {
    '=1': "one product",
    '=2': "two products",
    other: '# products'
} // note that the format
```

## Using the `async`pipe

Ng includes the `async`pipe, can be used to consume `Observable`objects directly in a view. Selecting the last object received from the event sequence. This is an impure of course – meaning its `transform()`will be called often.

For testing, just add a `Subject<number>`prop to the class and uses it to generate a sequence events. Like:

```ts
numbers: Subject<number> = new Subject<number>();

ngOnInit() {
    let counter = 100;
    setInterval(() => {
        this.numbers.next(counter += 10)
    }, 1000);
} // in the component class
```

```html
<div>
     Counter: {{number | async}}
</div>
```

# Using Services

*Services* are objects that provide common functionality to support other building blocks in the app, such as directives, components, and pipes. What is important about services is the way they are used – called DI. What separates services from regular objects is that they are provided to building blocks by an external provider, rather than being created directly.

Classes declare dependencies on services using ctor parameters, which are then resolved using the set of services for which the app has been configured. Services are classes to which the `@Injectable`decorator has been applied.

## Understanding the Object Distributaion Problem

Fore, add a shared object to the proj and two components that rely on it. For the component that makes use of the class, add a file – 

```ts
@Component({
	selector: "paDiscountDisplay",
	template: `
		<div class="bg-info text-white p-2 my-2">
			The discount is {{discounter?.discount}}
		</div>`
})
export class PaDiscountDisplayComponent {
	@Input("discounter")
	discounter?: DiscountService;
}
// ...
@Component({
	selector: "paDiscountEditor",
	template: `
		<div class="mb-3">
			<label>Discount</label>
			<ng-template [ngIf]="discounter?.discount??false">
				<input [(ngModel)]="discounter!.discount"
					   class="form-control" type="number"/>
			</ng-template>
		</div>`
})
export class PaDiscountEditorComponent {
	@Input("discounter")
	discounter?: DiscountService;
}
```

```html
<paDiscountEditor [discounter]="discounter"></paDiscountEditor>
<paDiscountDisplay [discounter]="discounter"></paDiscountDisplay>
```

The process for adding the new components and the shared object – The problem arises in the way that – Had to create and distribute the shared object – the instance of the `DiscountService`class. And cuz Ng just isolates components from one another, had no way to share the `DiscountService`object directly between two components. For this service object, just is a shared object through the product table component’s template. But for the `ProductTableComponent`class – doesn’t actually need or use a `DiscountService`object to deliver its own functionality. If wanted to move one component – have to work my way up the tree of component until find a common ancestor. 

The result is that the components and directives in the app become tightly bound together. A major refactoring is requird if you need to move or reuse a component in a different part of the app and the management of the input props and data bindings becomes unmanageable.

So, there is just a better way to distribute objects to the classes that depend on them – which is to use DI. ng includes a built-in dependency injection system and supplies the external source of ojbects – *providers*.

# Pseudo-Element Selectors

pseudo elemnts insert fictional elements into a document. Employing a double-colon like `::first-line`.

```css
p::first-letter {color: red;}
p:first-of-type::first-lettter{font-size:200%;}
```

Just like:

```html
<p>
    <p-first-letter>T</p-first-letter>his is ....
</p>
```

```css
p::first-line {font-size: 150%; color: purple;}
```

Note, can be applied only to block-display elements. not to inline-display elements like hyperlinks.

```css
input::placeholder {font-style:italic;}
textarea::placeholder {color: cornflowerblue;}
```

Form button – `input::file-selector-button`

Styling content before and after elements

`h2::before{content:"]]"; color: silver;}`

CSS lets you insert *generated content*.

Highlight pseduo-elements – New…

```css
::selection {color: white; backgournd-color: navy;}
```

backdrop pseudo-element – 

## Specificity, Inheritance, and Cascade

A user agent must consider not only inheritance but also the *specificity* of the declarations. As well as the origin of the declarations themselves – this process of consideration is known as *cascade*.

For every rule, the user agent evluates the **specificity** of the selector and attaches the specificity to each declaration in the rule within the cascade layer.

- ID - +100
- class, Pseudo-class, +010
- for element, pseudo-element, +001
- The specificity of an :is(), :not(), :has(), is equal +100

`rem`is shortcut for root em. are relative to the root element.

### Viewport-relative units

viewport – the framed area in the browser window where the web page is visible.

`vh vw vmin vmax` vmin– 1/100th of the smaller dimision, vmax 1/100th of the larger dimension. fore:

```css
:root {
    font-size: calc(0.5em + 1vw);
}
```

## Unitless numbers and line-height

Include like `line-height, z-index, font-weight`.

CSS variables – 

```css
:root {
    --main-font: Helvetica
}
```

Name must begin with `–`to distinguish it from css prop. And a func called `var()`is used like:

```css
p {
    font-family: var(--main-font);
}
```

Just note that the `var()`accepts a second parameter, which specifies a fallback value.

```css
.dark {
    --main-bg: #333;
    --main-color: #fff;
}
```

### Changing with Js

```js
let rootElement= document.documentElement; // get root
let styles = getComputedStyle(rootElement);
let mainColor = styles.getPropertyValue('--main-bg');
console.log(String(main-color).trim());
```

Note that also can set this value like:

`rootElement.style.setProperty('--main-bg', '#cdf')`

```css
:root {
    box-sizing: border-box;
}

*, ::before, ::after{
    box-sizing: inherit;
}
```

```css
.sidebar {
    float:left;
    width: calc(30% - 1.5em);
    margin-left: 1.5em;
    padding: 1.5em;
    background-color: #fff;
    border-radius: .5em;
}
```

### CSS Table Layouts

First, use a CSS-based table layout. Instead of using floats, will make the container `display: table;`and each column a `display: table-cell;`just like: And note that the `margin`no longer works.

So for `table`, just using the `border-spacing`

```css
.container {
    border-spacing: 1.5em 0;
    display: table;
    width:100%; /*makes the table fill its container width*/
}

.wrapper {
    margin-left: -1.5em;
    margin-right: -1.5em;
}
```

Using Flex like: Note that the direct children become the same height by default.

### Negative Margins

Unlike padding and border, can assign a negative to margins.

### Collapsed Margins

Margin collapsing only occurs with top and bottom margins, Left and right don’t collapse.

Sass variable scope – are only available at the level of nesting where they are defined.

### Sass !global

```scss
$myColor: red;
h1 {
    $myColor: green !global;
}
p {
    color: $myColor; // now it's green
}
```

### Nested properties

```scss
font:{
    family: Helvetica;
    size: 18px
}
```

```css
font-family: Helvetica;
font-size: 18px;
```

### Sass Partials

By default, Sass transpiles all the .scss directly, so, `_colors.scss`can be used directly. like:

```scss
@import "colors";
body {
    font-family: Arial, Helvetica, sans-serif;
    font-size: 18px;
    color: $myBlue;
}
```

