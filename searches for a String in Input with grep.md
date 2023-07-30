# searches for a String in Input with `grep`

The `grep`command, like `find`. processes any text, whether in files or just in std input.

```sh
grep "some text"
```

This just searches all files in the current directory (not sub) for the string.

`grep -r "some text"`

Can invert the serach by specifying the `-v`paramemter.

## Less command

Enables to view large amounts of text. Fore

```sh
less +/hello myfile.txt # load file and place the cursor at the first match for hello
```

Creating links between files with `ln`

Allows you to make two types of links, known as hard links and symbolic links.

```sh
ln -s myfile.txt mylink
```

creates the symlink `mylink`points to `myfile.txt`. -s, soft link.

Finding from an index with `locate`– ubuntu ships with a `cron`job that creates an index of all the files.

## Listing System info with `lsblk, lshw, lsmod, lspci, neofetch`

```sh
# lshw run s root for full listing
sudo lshw
```

### Reading Manul pages with `man`

Downloading Files with `wget`- see a website with useful content that you need to download to your server.

# Command-line 2

## Redirecting output and input

To redirect, use > on the command list, sometimes people read this as `in to`.

```sh
cat < readme.txt
```

This just display the content.

And Ubuntu uses a software packaging system called `atp`– By using command from the `apt`stable, `dpkg`, can quickly list all software that has been installed using `apt`on a system and record that info into a file by using a redirect like:

```sh
sudo dpkg --get-selections > pkg.list
```

## stdin, stdout, stderr, and Redirection

Whan a program runs, automatically has 3 i/o streams opened for it. They can be directed elsewhere.

### Comparing Files

`diff file1 file2`

Finding similarities in file with `comm`

`comm file1 file2`

Listing Porcesses with `ps`

Lists processes and gives you an extraordinary amount of control over its operation. Note in **Unix/Linux** , a process has the ability to create another process that executes some given code independently.

Ask it to list all your processes attached to any terminal – `x`, all for `a`, `u`for user-oriented output, `sort`for sort. like:

```sh
ps aux --sort=-%cpu
```

Listing Jobs with `jobs`

A `job`is just any program you interactively start that doesn’t then detach from the user and run on its own.

## Using Environment Variables

A number of in-memory variables are assigned and loaded by default when you just log in. Following includes a number of environment variables – like:

`PWD, USER, LANG, SHELL, PATH, TERM`

# Creating Completely Custom JSON Encodings

The `Encoder`checks to see whether a struct implement the `Marshaler`interface, which denotes a type that has a custom encoding and which defines the method.

`MarshalJSON()`– this invoked to create a JSON representation of a value and returns a byte slice containing JSON and `error`indicating encoding problems.

```go
func (dp *DiscountedProduct) MarshalJSON() (jsn []byte, err error) {
	if dp.Product != nil {
		m := map[string]interface{}{
			"product": dp.Name,
			"cost":    dp.Price - dp.Discount,
		}
		jsn, err = json.Marshal(m)
	}
	return
}
```

The `MarshalJSON`can just generate JSON in any way that suits the project. The most reliable approach is to use the support for encoding `map`.

## Decoding JSON data

The `NewDecoder`ctor creates a `Decoder`, which can be used to decode JSON data obtained from a `Reader`.

- `Decode(value)`– reads and decodes data, which is used to create the specified value. Note that the method returns an `error`that indicates problems decoding the data to the requried type of `EOF`
- `DisallowUnknownFileds()`-- when decoding a struct, the `Decoder`ignores any key in json no corresponding struct field., Call this causes the `Decode`return an error.
- `UseNumber()`– By default, JSON values R decoded into `float64`, calling this uses `Number`type instead.

```go
func main() {
	reader := strings.NewReader(`true "hello" 99.99 200`)
	vals := []interface{}{}
	decoder := json.NewDecoder(reader)

	for {
		var decodeVal interface{}
		err := decoder.Decode(&decodeVal)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		}
		vals = append(vals, decodeVal)
	}

	for _, val := range vals {
		Printfln("Decoded (%T): %v", val, val)
	}
}
```

Create a `Reader`that will produce data from a string contianing a sequence of values. 

### Decoding Number Values

JSON uses a single data type to represent both floating-point and integer values. The `Decoder`decodes these numeric values as `float64`, which… Can be changed by calling `UseNumber`on the Decoder. Which causes JSON number values to the decoded into the `Number`type. `Int64(), Float64(), String()`

```go
ecoder := json.NewDecoder(reader)
decoder.UseNumber()  // note this!!!
for {
    //...
}

for _, val := range vals {
    if num, ok := val.(json.Number); ok {
        if ival, err := num.Int64(); err == nil {
            Printfln("Decode integer %v", ival)
        } else if fpval, err := num.Float64(); err == nil {
            Printfln("Decode Floating point: %v", fpval)
        } else {
            Printfln("Decode just string %s", num.String())
        }
    } else {
        Printfln("Decode (%T): %v", val, val)
    }
}
```

If want to uset this `val.(json.Number)`, should use the `**decoder.UseNumber()**`func.

## Specifying Types for Decoding

The previous examples passed an empty interfaca var to the `Decode`just like:

`var decodeVal interface{}... err := decoder.Decode(&decodeVal)`

This lets the `Decoder`select the Go data type for the JSON value that is decoded. And, if just know the structure of the JSON data you are decoding, can direct the `Decoder`to use specific Go types:

```go
func main(){
	reader := strings.NewReader(`true "hello" 99.99 200`)

	var bval bool
	var sval string
	var fval float64
	var ival int

	vals := []interface{} {&bval,&sval, &fval, &ival}

	decoder := json.NewDecoder(reader)

	for i:=0; i<len(vals); i++ {
		err := decoder.Decode(vals[i])
		if err != nil {
			Printfln("Error: %v", err.Error())
			break
		}
	}

	for _, v := range vals {
		switch rv := v.(type) {
		case *int:
			Printfln("Decode (%T): %v", *rv, *rv)
		case *float64:
			Printfln("Decode (%T): %v", *rv, *rv)
		case *bool:
			Printfln("Decode (%T): %v", *rv, *rv)
		case *string:
			Printfln("Decode (%T): %v", *rv, *rv)
		default:
			Printfln("ERROR")
		}
	}
}
```

## Decoding Arrays

The `Decoder`processes arrays automatically – but care must be taken cuz JSON allows arrays to contain values of different types. FORE:

```go
func main() {
	reader := strings.NewReader(`[10,20,30]["kayak","lifejacket",279]`)
	vals := []interface{}{}
	decoder := json.NewDecoder(reader)

	for {
		var decodedVal interface{}
		err := decoder.Decode(&decodedVal)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		}
		vals = append(vals, decodedVal)
	}

	for _, val := range vals {
		Printfln("Decoded: (%T): %v", val, val)
	}
}

```

The source JSON just contains two arrays, one of which contains only numbers, and other contain mixes. And, if you just know the type, also.

### Decoding Maps

Js objects are expressed as k-v pairs which makes it easy to decode them into Go maps, as shown like:

```go
func main() {
	reader := strings.NewReader(`{"Kayak":279, "LifeJacket": 49.95}`)
	m := map[string]float64{}
	decoder := json.NewDecoder(reader)
	err := decoder.Decode(&m)
	if err != nil {
		Printfln("Error : %v", err.Error())
	} else {
		Printfln("Map: %T, %v", m, m)
		for k, v := range m {
			Printfln("Key: %v, Value: %v", k, v)
		}
	}
}
```

### Decoding Structs

The k-v pair of JSON objects can be decoded into Go struct values. Disallowing unused keys – By default, the `Decoder`will ignore keys for which is no corresponding struct field. This can be changed by calling the `DisallowUnknownFields()`. like

### Creating Completely Custom JSON Decoders

The `Decoder`checks to see whether a struct implements the `Unmarshaler`interface just :

`UnmarshalJSON(byteSlice)`– return an error. Also use a map to implements it.

## Adding Deliberate Error

## Centralized Error Handling

neaten up app by moving some of the error handling code into helper methods.

```go
func (app *application) serverError(w http.ResponseWriter, err error) {
	trace := fmt.Sprintf("%s\n%s", err.Error(), debug.Stack())
	app.errorLog.Println(trace)

	http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

func (app *application) clientError(w http.ResponseWriter, status int) {
	http.Error(w, http.StatusText(status), status)
}

func (app *application) notFound(w http.ResponseWriter) {
	app.clientError(w, http.StatusNotFound)
}
```

Uses the `debug.Stack()`function to get a *stack trace* for the current goroutine and append it to the log message. Being able to see the execution path of the application via the stack trace can be helpful when u’r  trying to debug.

And use the `http.StatusText()`func to automatically generate a human-read text. Then add it to the proj: fore:

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)
		app.clientError(w, http.StatusMethodNotAllowed)  // add this
		return
	}
	w.Write([]byte("Create a new snippet..."))
}
```

## Isolating the Application Routes

for the `main`is beginning to get a bit crowded. So move it into a standalone file like:

```go
func (app *application) routes() *http.ServeMux {
    mux := http.NewServeMux()
    mux.HandleFunc("/", app.home)
    mux.HandleFunc("/snippet", app.showSnippet)
    mux.HandleFunc("/snippet/create", app.createSnippet)

    fileServer := http.FileServer(http.Dir("./ui/static/"))
    mux.Handle("/static/", http.StripPrefix("/static", fileServer))
    return mux
}
//...
srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  app.routes(),  // calling the new method
}
```

# Database-Driven Responses

- Connecto to MySQL from web app
- Create a standalone models package.
- Use the appropriate functions in Go’s database/sql package to execute different types of SQL
- Prevent SQL injection attacks
- Use transactions.

## Scaffolding the dbs

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;
```

# Working with Relationships

Show how to access the related data directly and  – once have done – how can complete a relationship so that nav can be performed in both directions between the objects in the relationship.

- Add a `DbSet<T>`to the context then create and apply a migration.
- Use the `DbContext.Set<T>()`method.

## Directly Accessing Related Data

In most apps, some of the related data has its won lifecycle and workflows that users need to perform… To avoid issue, can access related data directly–

### Promoting Related Data

For data that just plays an important role in the app, such that it has its own management tools and lifecycle - the best is to promote the data so it can be accessed directly through a `DbSet<T>`. just add:

`public DbSet<Supplier> Suppliers => Set<Supplier>();`

Can be used to query and operate on the `Supplier`object  in the dbs.

For this, need a new migration, need to note. Namely **A new migration is required when you define `DbSet<T>`operations**.

If examine the `Up`method – just like:

`migrationBuilder.RenameTable(name:”Supplier”, newName: “Suppliers”)`

The name change is caused by the switch from one ef core convention to another. EF core will use as the name of the table store the Supplier objects in the dbs.

## Consuming the Promoted Data

Once have promoted, can access it using the techniques – fore:

## Accessing Related Data using a Type Parameter

The alternative to promoting data is to use a set of methods that are provided by the dbs context class and that allow the data type to be specified as a type parameter. This is a useful feature for dealing with data for which U require occasional or limited access for specific operations and for which promotion to a `DbSet<T>`is not warranted.

- `Set<T>()`-- returns a `DbSet<T>`object that can be used to query the dbs
- `Find<T>(key)`– queries the dbs for the object of type T that has the specified key
- `Add<T>(newObject)`– adds a new object of type `T`to the dbs
- `Update<T>(changedObjec)` – updates an object of type `T`
- `Remove<T>(dataObject)` – removes an obj of type `T`for the dbs.

One advantage of these methods is that they can be used to create a generic repository that can be used to provide access to a specific type when it is configured as a service in the `Startup`class. So can:

```cs
public interface IGenericRepository<T> where T: class
{
    T Get(long id);
    IEnumerable<T> GetAll();
    void Create(T entity);
    void Update(T entity);
    void Delete(long id);
}

public class GenericRepository<T> : IGenericRepository<T> where T : class
{
    protected EFDatabaseContext context;
    public GenericRepository(EFDatabaseContext context)
    {
        this.context = context;
    }

    public void Create(T entity)
    {
        context.Add<T>(entity);
        context.SaveChanges();
    }

    public void Delete(long id)
    {
        context.Remove<T>(Get(id));
        context.SaveChanges();
    }

    public virtual T Get(long id)
    {
        return context.Set<T>().Find(id)!;
    }

    public IEnumerable<T> GetAll()
    {
        return context.Set<T>();
    }

    public void Update(T entity)
    {
        context.Update<T>(entity);
        context.SaveChanges();
    }
}
```

The `IGenericRepository<T>`interface defines the operations that a repository must provide to work with the typ `T` – The `where`restrictst the type. The specific type that the interface and implementations class will be used for are configured when the DI service is created in the `Program.cs`like:

```cs
builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
```

## Completing a Data Relationship

Promoting the related data has made it easier to access, but working with it can be improved further. Can start with a `Product`– and follow a nav to get the related `Supplier`-- EF core allows to define props that allow NAV in the other direction – *Completing the relationship*.

There is a range of different types of rel that you can create between classes – but define a nav – EF core assumes that you want to create a one-to-many rel and that the nav prophas been added to the class at the *many* end of the rel. Namely, each `Supplier`just be related to many `Product`objects.

In the `Supplier`class:

```cs
public ICollection<Product>? Products { get; set; }
```

The nav returns an enumeration of the other class in the rel. This just reflects the fact that each `Supplier`just can be related to many `Product`.

## Query in an One-to-Many rel

Once have completed – can start with an object of either type in the REL and navigate in both direction. If want the complete set of related data, can use just the `Include`or `ThenInclude`to extend the query by selecting the nav. For this, just the `INNER JOIN`query.

### Querying using the Explicit Loading

Using the `Include`to follow a .. *doesn’t any way to just fileter* the related data. Which means that it is all retrieved from the dbs. So, if want to be more selective, can execute an **explicit loading**.

```cs
public IEnumerable<Supplier> GetAll()
{
    IEnumerable<Supplier> data = context.Suppliers.ToArray();

    foreach(Supplier s in data)
    {
        context.Entry(s).Collection(e => e.Products!)
            .Query()
            .Where(p => p.Price > 50)
            .Load();
    }
    return data;
}
```

Explicit loading relies on the `DbContext.Entry()`.

- `Reference(name)`– used for nav prop that target a single object
- `Collection(name)`– used target a collection.

Once U used the .. to select the nav prop, the query method is used to get an `IQueryable`object that can be used with LINQ to filter data that will be loaded.

The `Load()`method is used to **force execution** of the query. That isn’t usually required cuz the query will be executed automatically when the `IQueryable<T>`is enumerated by the Razor view or by LINQ. here, it’s needed cuz this will not be enumerated. Without this, just not execution.

And the drawback of using explicit loading is that it generates many queries for the dbs.

### Querying using the Fixing up Feature

EF core supports a feature called *Fixing up*– The data retrieved by a dbs context object is cached and used to populate the nav prop of objects that are created for subsequent queries. Used carefully like: FORE:

```cs
public IEnumerable<Supplier> GetAll(){
    context.Products.Where(p=>p.Supplier!=null && p.Price>50).load();
    return context.Suppliers;
}
```

For line 1 – the sole purpose of this query is to populate the EF Core cache with data objects. use `Load()`force evaluation of the query. When the second is executed, EF core will automatically examine the data cache from the first and use the data to populate the `Supplier.Products`nav.

For all of the reasons – *endpoint routing* is currently not the suggested approach – The same granularity offers is also – just `[EnableCors]`attribute – like:

```cs
app.MagGet("/error", [EnableCors("AnyOrigin")]()=> Results.Problem());
app.MapGet("/error/test", [EnableCors("AnyOrigin")] ()=>...);
```

And, in order to use the attr, also need to add a reference to the Program.cs:

`using Microsoft.AspNetCore.Cors;`

# Statelessness

The `Statelessness`constraint is particularly important in RESTful APIs – prevents our Web API from doing sth that most web app do – store some of the client’s info on the server and retreive them upon subsequent calls. Namely, restrain ourselves from using some convenient built-in core features.

### Cacheablity 

Cache when used in an **IT-related** context – refers to a system, component, or module to store data to make it available for further requests with less effort.

- Server-side caching – application caching
- Client-side Caching – browser caching or response caching.
- Intermediate caching – proxy caching – reverse-proxy caching or CDN caching.

## Completing the Blazor WebAssembly Form application

Creating the Details Conmponent – just like:

```cs
public async TaskHandleValidSubmit() {
    if (Http!=null) {
        if(Mode=="Create")
            await Http.PostAsJsonAsync("/api/people", PersonData);
        else 
            await Http.PutAsJsonAsync("/api/people", PersonData);
        NavManager?.NavigateTo("forms");
    }
}
```

# Using ASP.NET Core Identity

Core Identity is an API from Ms to manage users in the ASP.NET core apps and includes support for integrating authentication and authorization into the request pipeline.

There are endless integration options for features such as two-factor, federation, signle sign-on…

Core Identity has evolved into its won framework and is too large .. focused on the parts of API..

## Preparing the Proj for the Identity

The process for setting Core identity requires adding a package to the proj, configuring the app, and preparing the dbs.

```sh
Install-Package Microsoft.AspNetCore.Identity.EntityFrameworkCore -Version 6.0.0
```

### Preparing the core Identity Dbs

Requires a dbs, which is managed through EF core. To create the EF core context class that will provide access to the Identity data. So in the Models folder add:

```cs
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

public class IdentityContext: IdentityDbContext<IdentityUser>
{
    public IdentityContext(DbContextOptions<IdentityContext> options) : base(options) { }
}

```

So, Core Identity package includes the `IdentityDbContext<T>`class – which is used to create an EF core context class – the generic type arg *T is used to specify the class that will represent users* in the dbs. Can just create custom user classes, here have used the basic class – `IdentityUser`, which provides the core features.

And, also need add the connection string like:..

## Configuring the Application 

To configure ASP.NET core so that the `Identity`dbs context is set up as a service like:

```cs
builder.Services.AddDbContext<IdentityContext>(opts =>
opts.UseSqlServer(builder.Configuration["ConnectionStrings:IdentityConnection"]));

builder.Services.AddIdentity<IdentityUser, IdentityRole>()
    .AddEntityFrameworkStores<IdentityContext>();
```

Then need a migration to apply it to create the dbs just.

## Creating User Management Tools

Going to create the tools that manage users through Core Identity. Users are managed through the `UserManger<T>`class – where `T`is the class chosen to represent users in the dbs. When created context, just specified `IdentityUser`as the class to represent users in the dbs. Note that this is the built-in class provided by the `ASP.NET core`identity.

# Understanding hosting Models

Hosting modles are where a Blazor app is run. two -specific hosting models, server and WebAssembly. But, the component model is just the same, meaning components are written the same way and can be interchanged between either hosting model.

WebAssembly allows to run entirely inside the client’s browser, making it a direct alternative to Js SPA framework. The process begins when a request is made by the browser to the web server – the web server will return a set of files needed to load the app. These include the host page for the app, usually called `index.html`. Any static assets required by the app, such as images, css and js.

In the blazor web assembly hosting model, part of the framework resides in js and is contained in the `blazor.webassembly.js`file. 3 main things to do :

- Loads and initializes the Blazor app in the browser
- Provides direct DOM manipulation so Blazor can perform UI updates.
- provides APIs for js interop scenarios.

Files returned from the server are **all** static files – havn’t required any server-side compilation or manipulation. Just menas that can be hosted on any service that offers static hosting.

Once the browser has received all the initial files from the web server, can process them and construct the DOM. Next, `blazor.webassembly.js`run – performs many actions – for the start up. Once the `blazor.boot.json`has been downloaded and the files listed it have been downloaded, time to run.

## Calculating UI Updates

1. App run on the clients
2. Can work in offline
3. Deployed as just static files.
4. Code sharing

And tradeoffs:

- payload
- Load time
- Rstricted run time.
- Code security

Start the app.

## Key Components of a app

**index.html** – is one of the most important component of app – can be found in the `wwwroot`folder.

`<base href = "/" />`– the base tag is used by router to understand which route it should handle

`<script src="_framework/blazor.webassembly.js"></script>`-- Js runtime.

When app runs, its content needs to be outputted somewhere on the page – by default, this is just outputted to a `div` with id=`app`. `id=app`that is important – this is configurable and is set up in the Program.cs file. Any default content that exists in the tag will be just replaced at run time with the output from the app.

If an unhandled expcetion is .. then Blazor will display a special UI that signals to the user that sth has gone wrong. This is also defined in the `index.html`can be customized – but the containing element must have an `id`attr with the value `blazor-error-ui`.

for the `base`tag – is an important tag when comes to the client-side routing – is important cuz it tells Blazor’s router which URLs, or routes – are in scope for it to handle. for now `/.`means that the app is running at the root of the domain. However, if the app is runing as just a subapplication – fore – then the base tag needs to reflect this with a value of `/blazortrails/`. This means the router will handle only nav requests that starts with `/blaortraisl/`. It’s important to make sure the value you enter for the base tag ends with a `/`, if missed will remove any value until it find this `/`.

### Program.cs in WebAssebmly

- Creates an instance of WebAssembly, Defines the root components for app –>

```cs
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");
builder.Services.AddScoped(sp=>new HttpClient..);
await builder.Build().RunAsync();
```

`AddScoped(sp=> new HttpClient {…})`just making it available to classes and components via `DI`.

### App.razor

Root component for Blazor app. You can configure a different component to be the root. For this contains a vital component for building multiplage app – the `Router`component. responsible for managing all aspects of client-side routing.

### _Imports.razor

is one componetn not required to run – optional have at least one of these – to store `using`statements just. 

And need a way of representing a trail, just add a class.

Now that have somewhere to store test data, can make the call to retreive it. A great place to do this kind of thing is the `OnInitialized`-- provided by `ComponentBase`– which `component`inherits from – one of the 3 primary life cycle methods. – other are `OnParametersSet`and `OnAfterRender`.

To retrieve the data from the JSON, need to make a `GET`jsut like for API – instead of passing the address of the API in the call, pass the relative location of the JSON file. `/trails/trail-data.json`file. 3 methods primarily:

- `GetFromJsonAsync<T>`
- `PostAsJsonAsync<T>`
- `PutAsJsonAsync<T>`

Under the hood, these are using the `System.Text.Json`lib – When using these, be aware that when a nonsuccess code is returned from the server, they will throw an exception of type `HttpRequestException`. So, this means that it’s just generally a good practice to wrap these calls in a `try catch`.

```cs
@code {

    private IEnumerable<Trail>? _trails;

    protected async override Task OnInitializedAsync()
    {
        try
        {
            _trails = await Http
                .GetFromJsonAsync<IEnumerable<Trail>>("trails/trail-data.json");
        }
        catch (HttpRequestException e)
        {
            Console.WriteLine($"There is a problem loading data {e.Message}");
        }
    }

}
```

Can use a simple just like:

```css
.grid {
    display: grid;
    grid-template-columns: repeat(3, 288px);
    column-gap: 123px;
    row-gap: 75px;
}
```

`PageTitle`component – it’s used to change the title of the page in the browser tab. It’s just good to encapsulate it all in a component instead for the card element – 

```html
<div class="card shadow" style="width:18rem">
    <img src="@Trail.Image" class="card-img-top"
         alt="@Trail.Name">
    <div class="card-body">
        <h5 class="card-title">@Trail.Name</h5>
        <h6 class="card-subtitle mb-3 text-muted">
            <span class="oi oi-map-marker"></span>
            @Trail.Location
        </h6>

        <div class="d-flex justify-content-between">
            <span>
                <span class="oi oi-clock mr-2"></span>
                @Trail.TimeFormatted
            </span>
            <span>
                <span class="oi oi-infinity mr-2"></span>
                @Trail.Length km
            </span>
        </div>
    </div>
</div>
```

```cs
@code {
    [Parameter, EditorRequired]
    public Trail Trail { get; set; } = default!;
}
```

In addition to using the `Parameter`attribute. Also another called `EditorRequired`which can  be used to indicate that a **parameter is required**. The null forgiving operator allow us to tell compiler that a value isn’t null or won’t be null.

`<TrailCard Trail="trail"/>`

# Angular DI

Angular isloates components from one another. There is a better way to distribute objects to the classes that depend on them –which is to sue DI – where objects are provided to classes from an external source. Angular includes a built-in dependency injection system and supplies the external source of objects – known as a `provider`. Ng denotes service classes using the `@Injectable`decorator.

```ts
@Injectable()
export class DiscountService {
    //...
}
```

A class declares dependencies using its ctor. When ng need to create an instance of the class – such as.. **its ctor is inspected**. And the type of each arg is examined – Angular then uses the services that have been defined to try to satisfy the dependencies. The term *DI* arises cuz each dependency is injected into the ctor to create a new instance.

```ts
export class PaDiscountDisplayComponent {
	constructor(public discount: DiscountService) {
	}
}
export class PaDiscountEditorComponent {
	constructor(public discounter: DiscountService) {
	}
}
```

Then can change the template as:..

NOTE:

### Registering the Service

The final change is to configure the DI feature so that it can provdie `DiscountService`objects to the components. Also in the app.module.ts file.

`providers: [DiscountService],`

The `NgModule`decorator’s `providers`property is set to an array of the classes that will be used as services.

### Reviewing the DI changes

Each time Ng encounters an element that requires a new building block, such as a component or a pipe, it examines the class ctor to check what dependencies have been declared and uses its services to try to resovle them. There is a profound difference in the way that the app is put together that makes it more flexible and fluid.

## Declaring DI in other building blocks

It isn’t jsut component that can declare ctor dependencies – once you have defined a service, you can use it more widely, including other building blocks in the apps. fore in pipe – can declare like:

```ts
@Pipe({
	name: "discount",
	pure: false
})
export class PaDiscountPipe {
	constructor(private discounter: DiscountService) {
	}

	transform(price: number): number {
		return this.discounter.applyDiscount(price);
	}
}
```

```html
<td>{{item.price! | discount | currency:"USD":"symbol"}}</td>
```

### Declaring Dependencies in Directives

Directives can also sue services.

## Understanding the Test Isolation problem

The example – contains a related problem that services and DI can be used to solve. In our `ProductComponent`-- the root component is defined as the `ProductComponent`, and it set up a value for its model by creating a new instance of the `Model`class. – Unit testing works best when you can isolate one small part of the app and focus on it to perform tests. But when U create an instance of the `ProductComponent`, are implicitly creating an instance of the `Model`class as well.

### Isolating componetns using services and DI

The underlying pro is that the `ProductComponent`is tightly bound to the `Model`class. in turn, tightly bound to `SimpleDataSource`class. So: The `@Injectable`is used to denote services – just:

```ts
constructor(private dataSource: SimpleDataSource) {
    //this.dataSource = new SimpleDataSource();
    this.products = [];
    this.dataSource.getData().forEach(p => this.products.push(p));
}
```

The important point to note in this listing is that services can declare dependencies on other services.

`providers: [DiscountService, SimpleDataSource, Model],`

## Completing the Adoption of Services

So, once start using services in an app – the process generally takes on a life of its own. On the other hand, the more you use services, the more the building blocks in proj become self-contained and reusable.

at last just:

`<paProductTable></paProductTable>`

# RxJS

It’s defined as a library for composing async and event-based program by using observable sequences. It provides one core type – `Observable`, statellite (`Observer, Scheduler, Subject`) and operators..

- `Observable`-- is a function that creates an observer and attaches it to the source where values are expected. Fore, clicks.. or an HTTP request.
- `Observer`– with `next(), error(), completes()`get called when there is interaction to the with the `Observable`the source interacts for an example button click…
- `Subscription`– when the observable is created, to execute the observable need to subscribe to it.
- `Operators`– is a pure func that takes in observable
- `Subject`-- is an observable can multicast i.e. talk to many observers.
- `Schedulers`– controls the execution of when the subscription has to start and be notified.

```js
import { of } from 'rxjs';
import { map } from 'rxjs/operators';
// "type":"module" in the package.json file, note that
map(x => x * x)(of(1, 2, 3)).subscribe(v => console.log(v));
```

## Introducing Rx Concepts

Where observables stand in the greater context of Js land. Like a var, `userRequest`contains a single value, but it doesn’t immediately have that value. To do anything with that data, need to *unwrap* the promise using the `.then`.

The `Observable`are like arrays in that they represent a *collection* of events, but are also like promises in that they are just asynchronous – each event in the collecion arrives at some indeterminate point in the future. This is just distinct from a collection of promisses – like `Promise.all`in that an `observable`can handle an arbitrary number of events, and a promise can only track one thing. An observable can be used to model clicks of a button. Can represents all clicks that will happen over the lifetime of the app. fore:

`let myobs$= clickonButton(myButton)`

`$`just represent an observable obj.

And much like a promise, need to unwrap our observable to access the value it contains. The observable unwrapping method is called `subscribe`.  The func passed into subscribe is called every time the observable emits a value. The func passed into subscribe is called every time the observable emits a value. like:

```js
let myobs$ = clickOnButton(myButton);
myObs$.subscribe(clickEvent=>console.log("..."));
```

Note that observables under Rxjs are *lazy* – if there is no subscribe call on myObs$, then no handler called. Observables only run when they know some’s listening in to the data they are emitting.

## Stopwatch

has two different categories of observables. And the interval timer has its own internal state and outputs to the DOM. The two-click streams will be attached to the buttons and won’t have any kind of internal state.

```ts
import { Observable } from "rxjs";

let tenthSecond$ = new Observable(observer => {
    let counter = 0;
    observer.next(counter);
    let interv = setInterval(() => {
        observer.next(++counter);
    }, 100);
    return function unsubscribe() {
        clearInterval(interv);
    }
});
```

Rx ctor for `Observable`-- takes a single arg func – an `observer`– an observer is any object that has the following methods – `next()`, `error(someError)`, `next()`called to pass the latest value to the `Observable stream`and `error()`called once the data source goes wrong, and `complete()`called once the datasource has no more info.

And the `.next`on the observer is how an observable announces to the subscriber that it just has a new value for consumption. For this – the ctor never actually run – lazy observable at work. In Rx land **this ctor function will only run when someone subscribes to it.** And if there is a second subscriber  – all of this will run a second time, and creating an entirely separate stream.

Finally, this returns yet another func – unsubscribe func. If the ctor just return another func – then this inner func runs whenever a listener unsubscribes from the source. Remember that each subscriber just gets their own instance of the ctor.

All of this work has already been implemented in Rx library – like:

```ts
let tenthSecond$ = interval(100);
tenthSecond$.subscribe(console.log);
```

When there’s a subscribe call, numbers start being to logged to the console.

Observables are just such a collection and Rx provides a `map`operator of tis own – piped through a source observable, takes a func, and returns a new reservable that emits the result of the passed in func.

```ts
interval(100).pipe(
    map(num => num / 10)
).subscribe(console.log);
```

### Handling Uer Input

Next, manage clicks on the start and stop buttons – grab the elements off the pate with querySelector like:

```ts
function trackClickEvents(elem: HTMLElement) {
    return new Observable(observer => {
        let emitClickEvent = event => observer.next(event);
        elem.addEventListener('click', emitClickEvent);
        return () => elem.removeEventListener('click', emitClickEvent);
    })
}
```

But , can let the library to do all the works – Rx also provides a `fromEvent`creatoin operator for exactly this case. Takes a DOM element and an event name as parameters and returns a stream that fires whenever the event fires on the element– using like:

```sh
npm install rxjs webpack webpack-dev-server typescript ts-loader
```

