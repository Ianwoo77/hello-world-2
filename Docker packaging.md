# Docker packaging

## Using a Container image from Docker Hub

The `docker container run`will download the container image locally. That is because software distribution is built into Docker platform. Can explicitly pull image using the Docker CLI

```sh
docker image pull image diamol/ch03-web-ping
```

And noted that one image is physically stored as many image layers. Image servers are called registries. Can think of it as a big zip file that contains the whole app stack. During the pull don’t see one single file downloaded -- see lots of downalods in progress -- called image layers. Can:

```sh
docker container run -d --name web-ping diamol/ch03-web-ping
```

U know that you can just work with containers using the ID that docker generates -- but also can work with containers using ID that Docker generates give just a friendly name.

```sh
docker container logs web-ping
```

*Environment variables* are just key/value pairs that the operating system provides -- They work in the same way on Win and Linux. And the `web-ping`just has some default variables are populated by Docker -- and that is what the app uses to configure the website’s URL.

```sh
docker rm -f web-ping
docker container run --env TARGET=baidu.com diamol/ch03-web-ping
```

And env variables are very simple way to achieve that. just using `--env`flag.

NOTE: The host computer has its own set of environment variables too -- they are **separate** from the container. Each container only has the environment variables that Docker populates.

## Writing Dockerfile

just a set of instructions -- and a Docker image is the output. Dockerfile syntax is simple to learn -- just like:

```dockerfile
FROM diamol/node

ENV TARGET="blog.sixeyed.com"
ENV METHOD="HEAD"
ENV INTERVAL="3000"
WORKDIR /web-ping
COPY app.js .
CMD ["node", "/web-ping/app.js"]
```

Every image has to start from another. use the `diamol/node`as its starting point -- that has the `node.js`installed, And `ENV`set values for env vriables.

- `WORKDIR`-- creates a directory in the **container** image filesystem, and sets that to be the current working directory.
- `COPY`-- copies files or dirs from the **local into container**, for **.** actually the container’s `/web-ping`dir.
- `CMD`-- specifies the command to run when Docker starts a container from the image.

## Building Container image

```sh
docker image build --tag web-ping .
```

`--tag`just the name for the image. Docker calls this directory the `context`-- period just means *use current*.

```sh
docker image ls 'w*'
```

Can use this image in just exactly the same way as the . like:

```sh
docker container run -e TARGET=... INTERVAL=5000 web-ping
```

### Docker imags and image layers

Docker image just contains all the files you packaged like:

```sh
docker image history web-ping
docker image build -t web-ping:v2 .
```

## Packaging

Commands execute during the build, and any filesytem changes from the command are saved in the image layer.

```dockerfile
FROM diamol/base AS build-stage
RUN echo 'building...' > /build.txt

FROM diamol/base AS test-stage
COPY --from=build-stage /build.txt /build.txt
RUN echo 'Test...' >> build.txt

FROM diamol/base
COPY --from=test-stage /buildtxt /build.txt
CMD cat /build.txt
```

Call a multi-stage Dockerfile. Can *optionally* give stages a name with `AS`. Can copy files from previous stage. Note that using `--from`just tell system not using local filesystem.

`RUN`-- executes a command **inside a container** during the build - and any output from that command insdie a container during a build, and any output from the command is saved in the image layer.

```sh
docker image -t multi-stage .
```

### Node.js source code

```dockerfile
FROM diamol/node AS builder

WORKDIR /src
COPY src/package.json .

RUN npm install

FROM diamol/node

EXPOSE 80
CMD ["node", "server.js"]

WORKDIR /app
COPY --from=builder /src/node_module /app/node_modules/
COPY src/ .
```

The base image for both stage is `diamol/node`which has the Node.js runtime and npm installed. Copies the package.json, describe all the app’s dependencies.

```sh
docker image built -t access-log .
docker container run --name accesslog -d -p 801:80 --network nat access-log
```

### Go source Code

```dockerfile
FROM diamol/golang as builder

COPY main.go .
RUN go build -o /sever

from diamol/base

ENV IMAGE_API url="http://..."
	ACCESS_API_URL= "..."
CMD ["web/server"]

WORKDIR web
COPY index.html .
COPY --from=builder /server .
RUN chmod +x server
```

Go just compiles to native binaries.

## Working with registries, repositories, and image tags

Docker hub is themost popular image registry, hosting hundreds of throusands of images. When want to share them on a registry, need to add some more details.

# Interface on the Producer Side

- *producer side* -- An interface defined in the same package at the concrete implemeantion
- *Consumer side* -- An interface defined in a external package where it’s used.

And common to see developers creating interfaces on the just *producer* side, alongside the concrete implemenation. But in Go, in most cases this is not what we should do.

*abstractions should be discovered, not created* -- this means that it’s not up to the producer to force a given abstraction for all the client. Instead, it’s up to the client to decide whether it needs some form of abstraction and then determine the best abstraction level for its needs.

```go
type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

- remain unexported
- there is no dependnecy from `store`to `client`cuz interface is satisfied implicitly.

## Returning Interfaces

while designing a function signature, may have to return either an interface or a concrete implementation. Return an interface, in go -- bad practice. Should:

- returning structs instead of interfaces
- Accepting interfaces if possible.

## Any says nothing

An interface speicifes zero methods empty `interface{}` With 1.18+, the predeclared type `any`became an alias for an empty interface -- hence, all the `interface{}`occurrences can be replaced by `any`. And an `any`can hold **any** vlaue type like:

```go
func main(){
    var i any
    i = 42
    i = "foo"
    i = struct {}
}
```

In assigning a value to an `any`, lose all type info, which requires a type assertion to get anything useful out of th `i`, if:

```go
func (s *store) Get(id string) (any, error) // returns any
{}
func (s *store) Set(id string, v any) error { // accepts any
}
```

These lack expressiveness. Accepting or returning an `any`type doesn’t convey meaningful info. By using `any`, lose some of the benefits of Go as a statically typed lang.

## Being confused about when to use generics

It can be confusing about when to use generics and when not to do that.

### Interface types

Go has always had a limited kind of support for functions that can taken an arg of more than one specific type, using `interfaces`. 

```go
func PrintTo(w, io.Writer, msg string)
```

Here, don’t know about the precise type of `w`will be at runtime -- don’t need to explicitly declare...

### interface parameters And polymorphism

```go
// invalid
func AddAnything(x, y interface{}) interface{} {
    return x+y
}
```

### Type assertions and switches

```go
switch v:= x.(type) {
case int:...
case float64:...
}
```

We just wanted to avoid writing a separate, essentially identical version of the `Add`function for each concrete type.

### Type Parameters

Can now use the type parameter syntax to write a new version called `PrintAnything`. like:

`func PrintAnything[T any](v T) {}`

For any type `T`, this func just takes a `T`parameter, and returns nothing.

Instantiation -- 

```go
var x int=5
PrintAnything[int] (x)
```

Called *instantiating* the func.

### An `Identity`func

Suppose want to write a func called `Identity`that simply returns whatever value U pass it.. like:

```go
func Identity(v interface{}) interface{} {...}
```

This works, but isn’t really satisfactory. Don’t have any way to tell compiler that the function’s parameter and its result must be the *same* concrete type. Can:

```go
func Identity[T any](v T) T {
    return v
}
```

Namely -- For any type `T`, `Identity[T]` takes a `T`, and returns a `T`result.

Can call like `fmt.Println(Identity("Hello"))`

```go
func Identity[T any](v T) T {
	return v
}

func main(){
	fmt.Println(Identity("hello"))
	fmt.Println(Identity(errors.New("oh no")))
	fmt.Println(Identity(bytes.NewBufferString("Hello")))
}
```

### Composite types

So, are we restricted to declaring only parameters of type `T`itself, or could also take some *composite* type -- Just suppose that wanted to write a function `Len`returns the length of a given slice. just like:

```go
func Len [E any] (s []E) int {
	return len(s)
}
```

Namely, for any type `E`, `len[E]`takes a slice of `E`and returns `int`.

Can also use a type parameter in other kinds of composite type, fore, we can write a generic func on a `channel`of some element type `E`like:

```go
func Drain[E any] (s <-chan E) {
	//...
}
```

For any type `E`, `Drain[E]`takes a receive-only channel of `E`and returns nothing.

We could also write a `variadic`func -- like:

```go
func Merge[E any] (chs ...<-chan E) <-chan E{
	return make(chan E)
}
```

Namely, for any type `E`, `Merge[E]`takes any number of receive-only channels of `E`and returns a receive-only channel of `E`.

### Generic types

Generic functions -- can do more -- also write generic *types* -- like: Often deal with *collections* of values in the Go, fore:

`type SliceOfInt []int`

### A generic slice type

Could we write a *generic* type definition that takes a type parameter -- just like a generic fore:

`type Bunch[E any] []E`

For any type `E`, a `Bunch[E]`is a slice of `E`

For this.. just, `Bunch[int]`will be a slice of `int`. Can:

`b := Bunch[int]{1,2,3}`

If:

```go
b := Bunch[int]{1,2,3}
b = append(b, "hello") // error
```

# Validating the User Input

When this form is submitted the data will end up being posted to the `signupUser`handler. Need cover the checks -- creating two helpers -- along with a regular expression for sanity checking an email address like:

```go
// MinLength to check a specific field in the form contains a minimum number of
// characters, fails then add appropriate messages
func (f *Form) MinLength(field string, d int) {
	value := f.Get(field)
	if value == "" {
		return
	}
	if utf8.RuneCountInString(value) < d {
		f.Errors.Add(field, fmt.Sprintf("This is too short (minimum is %d)", d))
	}
}

// MatchesPattern check that a specific field in the form matches a regular expression
func (f *Form) MatchesPattern(field string, pattern *regexp.Regexp) {
	value := f.Get(field)
	if value == "" {
		return
	}

	if !pattern.MatchString(value) {
		f.Errors.Add(field, "This field is invalid")
	}
}
```

And in the `handlers.go`file and add some code to process the form and run the validation checks like so:

```go
func (app *application) signupUser(w http.ResponseWriter, r *http.Request) {
	// parse the form data first:
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// validate teh from content using the form helper we made earlier
	form := forms.New(r.PostForm)
	form.Required("name", "email", "password")
	form.MaxLength("name", 255)
	form.MaxLength("email", 255)
	form.MatchesPattern("email", forms.EmailRX)
	form.MinLength("password", 5)

	// if there are any errors, redisplay the signup form just
	if !form.Valid() {
		app.render(w, r, "signup.page.html", &templateData{Form: form})
		return
	}

	// otherwise sand a placeholder for now
	fmt.Fprintln(w, "Create a new user...")
}

func (app *application) signupUserForm(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "signup.page.html", &templateData{
		Form: forms.New(nil),
	})
}
```

Cuz we have got a `UNIQUE`constraint on the `email`field of our `users`table, it’s already guaranteed that we won’t end up with two users in dbs who have the same email.

### The Brief introduction of Bcrypt

To store a one-way hash of the password -- derived with a computationally expensive key-derivation function such as .. Go has just good implemenation of all .. 

There are two funcs in the `bcrypt`package that will be used to hash the password -- fore, 

`bcrypt.GenerateFromPassword()`lets us create a hash of a given plain-text password like:

`hash, err := bcrypt.GenerateFromPassword([]byte(“my password”), 12)`

The 12 pass in indicates the **cost**-- which is represented by an integer between **4** and **31**. The code above uses a cost of 12, which just means that 2**12 bcrypt iterations will be used to hash the password. not less than that. This func will return a 60-character long hash. and worth pointing that the `GenerateFromPassword()`also adds a random salt to the password to help avoid rainbow-table attacks.

On the other hand, can check a plain-text pwd matches a particular hash using `bcrypt.CompareHashAndPassword()` func like:

```go
hash := []byte(".....")
err := bcrypt.CompareHashAndPassword(hash, []byte("password"))
```

this func will return `nil`if matches, on an error if don’t match

### Storing the user Details

Next, upate the `UserModel.Insert()`so that it creates a new record in our `users`table containing the validated name, email, and hashed pwd.

All errors returned by dbs have a particular code, which can use to triage what has caused error. Like:

```go
// Insert use the Insert to add a new record to the user table
func (m *UserModel) Insert(name, email, password string) error {
	// create a bcrypt hash of pwd
	hashedPwd, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	if err != nil {
		return err
	}

	stmt := `INSERT INTO users (name, email, hashed_password, created) 
		values (?, ?, ?, UTC_TIMESTAMP())`
	
	// use the Exec to insert:
	_, err = m.DB.Exec(stmt, name, email, string(hashedPwd))
	if err != nil {
		// if this returns an error, use the errors.As() to check whether this error 
		// has type of *mysql.MySQLError, or an error of ErrDuplicateEmail
		var mySQLError *mysql.MySQLError
		if errors.As(err, &mySQLError) { // find first in error tree
			if mySQLError.Number == 1062 && strings.Contains(mySQLError.Message, "users_uc_email") {
				return models.ErrDuplicateEmail
			}
		}
		return err
	}
	return nil
}
```

Can finish this all off by updating the handler like:

```go
// otherwise sand a placeholder for now
err = app.users.Insert(form.Get("name"), form.Get("email"), form.Get("password"))
if err != nil {
    if errors.Is(err, models.ErrDuplicateEmail) {
        form.Errors.Add("email", "Address is already in use")
        app.render(w, r, "signup.page.html", &templateData{Form: form})
    } else {
        app.serverError(w, err)
    }
    return
}

// otherwise, add flash message
app.session.Put(r, "flash", "your signup was successful, please log in")
http.Redirect(w, r, "/user/login", http.StatusSeeOther)
```

### Using dbs Bcrypt implementations

Some dbs provide built-in functions that can use for pwd hashing, but should avoid using these:

- tend to be vulnerble due to string comparison time not being constant.
- Unless u are very careful, sending a plain-text to your dbs risks the pwd being accidentally recorded in one of your dbs logs.

# AuthC and AuthZ

### Exception Handling in the example app:

```cs
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/error");
}
```

- `D`eveloperExceptionPageMiddleware – captures sync and async exceptions from the HTTP pipeline and generate an HTML error page.
- `ExceptionHandlingMiddleware`-- also handles – but suited non-development environment.

### Using a Controller

Just start wtih the `controller-based`approach – add a API Empty – `ErrorController` just like:

```cs
[ApiController]
public class ErrorController : ControllerBase
{
    [Route("/error")]
    [HttpGet]
    public IActionResult Error()
    {
        return Problem();
    }
}
```

For this, the `Prodblem()`is a method of the `ControllerBase`-- produces a `ProblemDetail`response.

### Using minimal API

`app.MapGet("/error", ()=> Results.Problme());`

### Routing conflicts

`Controllers`and `Minimal API`can coexist in the same - without issues – the middleware that comes first in the `program.cs`file will handle the HTTP request first

### Adding the BroadGameController

Just start with a POCO class that will take the place of the previous like:

## Cross-origin-resource Sharing (CORS)

CORS is a HTTP-header based mechanism originally to allow safe cross-origin data requests. The whole purpose of CORS is to allow browsers to access resources using HTTP requests initiated from scripts. In absence of such a mechanism - The browser will block these external requests cuz would break *same-origin policy*.

### Implementing CORs

If want to allow requests for all origins, headers, and methods, could add the service using the following:

```cs
builder.Services.AddCors(opts=> {
    opts.AddDefaultPolicy(cfg => {
        cfg.AllowAnyOrigin();
        cfg.AllowAnyHeader();
        cfg.AllowAnyMethod();
    })
});
```

- Allow-origin – This allow to make the request 
- Allow-Headers – allow http headers
- Allow-Methods – allow HTTP methods.

Can improve the previous snippet in the `program.cs`file just like:

```cs
builder.Services.AddCors(opts=> {
    opts.AddDefaultPolicy(cfg=>{
        cfg.WithOrigins(builder.Configuration["AllowedOrigins"]);
        cfg.AllowAnyHeader();
        cfg.AllowAnyMethod();
    });
    opts.AddPolicy(name:"AnyOrigin", 
                  cfg=> {
                      cfg.AllowAnyOrigin();
                      cfg.AllowAnyHeader();
                      cfg.AllowAnyMethod();
                  });
});
```

The value pass to the `WithOrigins()`will be retuned by the server within the `Access-Control-Allow-Origin`header, which indicates to the client which origins should be considered valid.

Since used a configuration setting to define the origins to allow for the default policy, now also need set them up.

add:

```json
{
    "AllowedOrigins": "*",
}
```

In the above, which can be used as a wildcard to allow any origin to acces the resources when the request has no credentials. Note, if the request is set to allow credentials, fore, *cookies, authorization headers, or TLS client certificates*, the `*`can’t be used and result an error.

### Applying CORS

3 ways to enable CORS – 

- middleware
- endpoing routing
- `[EnableCors]`

1. Right before the **AuthZ middleware**:
   ```cs
   app.UseCors();
   app.UseAuthorization();
   ```

   In case we wanted to apply the `AnyOrigin`named policy Just :
   `app.UseCors("AnyOrigin");`

# Creating the Examle Project

```cs
public class Product
{
    public long Id { get; set; }
    public string Name { get; set; } = default!;

    [Column(TypeName ="decimal(8,2")]
    public decimal Price { get; set; }

    public string? Category { get; set; }
}
```

And create the `DbContext`class add the example data like.

### Then creating MVC Controllers and Views

```html
@model IQueryable<Product>
<h4 class="bg-primary text-white text-center p-2">MVC - level 1 - Anyone</h4>

<div class="text-center">
    <h6 class="p-2">
        The store contains @Model.Count() products.
    </h6>
</div>
```

Then add a class named `StoreController`in the `Controllers`– this will present the second level of access, which is avaible to users who are signed into the app. And provide the content of the product…

At last , add class named `AdminController`to the folder and use – will present the third level of content, which will be available only to administrators.

```cs
public class AdminController : Controller
{
    private ProductDbContext DbContext;
    public AdminController(ProductDbContext dbContext)
    {
        DbContext = dbContext;
    }

    public IActionResult Index() => View(DbContext.Products);

    [HttpGet]
    public IActionResult Create() => View("Edit", new Product());

    [HttpGet]
    public IActionResult Edit(long id)
    {
        Product p = DbContext.Find<Product>(id);
        if (p != null)
        {
            return View("Edit", p);
        }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    public IActionResult Save(Product p )
    {
        DbContext.Update(p);
        DbContext.SaveChanges();
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    public IActionResult Delete(long id)
    {
        Product p = DbContext.Find<Product>(id);
        if (p != null)
        {
            DbContext.Remove(p);
            DbContext.SaveChanges();
        }
        return RedirectToAction(nameof(Index));
    }
}
```

Also, need to create Razor pages – named: `Landing.cshtml`like:

```cs
public class AdminModel : PageModel
{
    public ProductDbContext DbContext { get; set; }
    public AdminModel(ProductDbContext ctx)=> DbContext= ctx;

    public IActionResult OnPost(long id)
    {
        Product p = DbContext.Find<Product>(id);
        if(p!=null)
        {
            DbContext.Remove(p);
            DbContext.SaveChanges();
        }
        return Page();
    }
}
```

### Then, enabling HTTPs conenctions

There is one more set of chanes required to prepare the example application. ASP.NET core relies on cookies and HTTP request headers to authenticate requests – which present the risk that en eavesdropper might intercept the HTTP request and use the cookies or header it contains to send a request that will appear as though it has been sent by the user.

### Generating a Test Cerificate

An important HTTPs feature is the user of a certifiate that allows web browsers to confirm they are communicating with the right web server and not an impersonator. To make app development simpler, the .NET SDK includes a test certificate that can be used for HTTPs. just:

```powershell
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

### Enabling Https

To enable HTTPs, make the change just in the `launchSettings.json`file in the `Properties`folder like:

`"applicationUrl": "http://localhost:5000;https://localhost:44350",`

### Enabling HTTPs Redirection

Asp.net core provides a feature that will redirect HTTP requests to the HTTPs port supported by the app.

```cs
// Add services to the container.
builder.Services.AddControllersWithViews();
//... add Https redirection
builder.Services.AddHttpsRedirection(opts =>
{
    opts.HttpsPort = 44350;
});

var app = builder.Build();

// use this
app.UseHttpsRedirection();
//...
app.Run();
```

# Customizing validation CSS classes

CSS famework such as Bootstrap.. all have predefined classes for valid and invalid input states – Blazor just allows us to use these classes, instead of the default ones it provides – by specifying them in a custom `FieldCssClassProvider`-- like:

### Creating a `FieldCssClassProvider`

To do this, need to create a class derived from `FieldCssClassProvider`– going to create this class in a new folder.

```cs
public class BootstrapCssClassProvider: FieldCssClassProvider {
    public override string GetFieldCssClass(EditContext editContext,
                                           in FieldIdentifier fieldIdentifier){
        var isValid= !editContext
            .GetValidationMessages(fieldIdentifier).Any();
        if(editContext.IsModififed(fieldIdentifier)) {
            return isValid ? "is-valid": "is-invalid";
        }
        return isValid? "":"is-invalid";
    }
}
```

When deriving from this, need to override the `GetFieldCssClass()`.This method takes an `EditContext`and `FieldIdentifier`(represents the field in the form getting CSS classes from).

`EditContext`is the **brain** of the form and just keeps track of the state of each field in the form. Can use the `GetValidationMessages`method on the `EditContext`to check if there are any validation messages for the current field. If there are – know that’s just invalid. Can set the `isValid`variable accordingly.

Next, need to use the `IsModified`method on the `EditContext`to check if the field has been edited by the user. And when have a modified – depending on if it’s valid or not - going to return either the `is-valid`or `is-invalid`css. These classes are part of the `Bootstrap`framework and allow us to remove the custom CSS classes. These are part of the *Bootstrap* and will allow to remove the custom.

### Using custom Providers with EditForm

To use, need to plug it in – to do this, use the `EditContext`. When created a `EditForm`-- passes a model to the `EditForm` – internally, the `EditForm`just creates an `EditContext`instance *using that model*. However, can create an `EditContext`ourselves and pass that to the `EditForm`component instead of the model.

Depending on what your are doing, this can be especially useful – having direct access to the `EditContext`allow us to perform actions such as **manually** triggering validation via the `Validate`method. Or hook onto events such as `OnFieldChanges`or `OnValidationStateChanged`– for this, going to use it to plug in our custom CSS class provider.

To update, use the new `BootstrapCssClassProvider`, will add the code like:

```html
<EditForm EditContext="_editContext" OnValidSubmit="SubmitForm"></EditForm>
```

```cs
private EditContext _editContext = default!;

protected override void OnInitialized()
{
    _editContext = new EditContext(_trail);
    _editContext.SetFieldCssClassProvider(
        new BootstrapCssClassProvider());
}
```

1. Pass the `EditContext`instance create to the `EditForm`rather passing model directly.
2. Create a new private field for instance of `EditContext`.
3. In the `OnInitialized()`,create new instance and configures to the `BootStrapCssClassProvider`

Before, move on, just need to tidy up our CSS. will remove the classes in .. except 

```css
input.invalid,
textarea.invalid,
select.invalid {
    border-color: red;
}

input.is-valid.modified,
text.is-valid.modified,
select.is-valid.modified {
    border-color: green;
}

.validation-message{
    color:red;
}
```

## Building Custom input Components with `InputBase`

While Blazor provides us all the basic input components we need to build a form – at some point we need sth a little more complex– or a little more tailored to needs.

Currently, not exposing this `TimeInMinutes`on the form – cuz it wouldn’t be a nice experience for the user, as they have to work out the total number of minutes – would be much nicer if they could input hours and minutes and the app does the work converting it.

So, to help get started – The Blazor team has included a base type that is going to do a lot of heavy lifting – `InputBase<T>`-- This type is going to handle the integration with `EditContext`– this means that our component will automatically be registered with the validation system and have its state tracked. 

All we need to do is provide the *UI and an implementation for a method called `TryParseValueFromString()`*.

### Inheriting from `InputBase<T>`

The first need to do is create a new component in `ManageTrail`called `InputTime.razor`-- can add the initial code for the component shown in:

```html
@inherits InputBase<int>

<div class="input-time">
    <div>
        <input class="form-control"
               type="number"
               min="0" />
        <label>Hours</label>
    </div>
    
    <div>
        <input class="form-control"
               type="number"
               min="0"
               max="59" />
        <label>Minutes</label>
    </div>
</div>

```

Just note that when using `InputBase<T>`, must provide an implementation for the `TryParseValueFromString`.

We start by inheriting from `InputBase<T>`using the `inherits`and setting the type parameter to `int`– cuz our form model – just cuz the type `Trail`'s property – `public int TimeInMinutes {get;set;}`

The browser will use this to stop non-numeric values from entered by the user.

For the `TryParseValueFromString`method – must be implemented by any component derived from `InputBase<T>`– its job is to convert a string value to the type that the componetn is bound to on the form model. However, depending on how build a custom input component – *this method may not ever get called*.

## The HttpClient methods

`get, post, put, patch, delete, head, options(url)`

```ts
getData(): Observable<Product[]>{
    return this.http.get<Product[]>(this.url);
}
```

### Configuring the data source

Configure a provider for the new data source and to create a value-based provider to configure it with a URL to which requests will be sent like:

```ts
@NgModule({
    imports: [HttpClientModule],
    providers: [Model, RestDataSource,
               {provide: REST_URL, useValue: `http://${location.hostname}:3500/products`}]
})export class ModelModule{}
```

The two providers just enable the `RestDataSource`class as a service and use the `REST_URL`opaque token to configure the URL for the web service.

### Using the REST Data Source

Final step to update the repository class so that it declares a dependency on the new data source. Just like:

```ts
constructor(private datasource: RestDataSource) {
    this.products= new Array<Product>();
    this.dataSource.getData().subscribe(data=>this.products=data);
}
```

### Consolidating HTTP requests

Each of methods in the data source class duplicates the same basic pattern – so can:

```ts
private SendRequest<T>(verb:string, url: string, body?: Product) 
	: Observable<T> {
        return this.http.request<T>(verb, url, {body: body})
    }
```

The `request`method just accepts the `HTTP`verb, the URL for the request, and an optional object that is used to configure the request.

And this method just has some configuration object – 

- `headers`– this returns an `HttpHeaders`object that allows the request headers to be specified.
- `body`-- prop is used to set the request body. The obj assigned to this will be just serialized as JSON.
- `withCredentials`-- boolean, when `true`– this is used to include authentication cookies when making cross-site requests – must be used only with servers that include the `Access-Control-Allow-Credentials`header in responses.
- `responseType`– used to specify the type of response expected from the server. Default is JSON.

## Making Cross-Origin Requests

By default, browsers enforce a security policy that allows Js code to make async HTTP requests only within the same *origin* as the document that contains them – reduce CSS attacks, … For Ng developers, this can be a problem when using web services cuz they are typically outside the origin that contains the app’s Js code.

HTTP requests made using the Ng `HttpClient`class will automatically use *Cross-origin* resource sharing to send requests to different origins. The response from the server includes headers that tell browser whether it is willing to accept the request.

For this example, the `json-server`package that has been providing the RESTful web service for the examples supports CORS and will just accept from any origin. Just made an `OPTIONS`, known as *preflight request* – uses to chck a request made using the POST or PUT request to the server. and the response will contain one or more `access-control-allow`headers.

### Using `JSONP `Requests

CORS ia available only if the server to the HTTP requests are send supports it. For servers that don’t implement CORS - Angular also provides support for JSONP – which allows a more limited form of requests.

**JSONP** works by adding a `scrpt`to the DOM that specifies the cross-origin server in its `src`attribute. Browser sends a `GET`which returns Js code, when executed, provides the app with the data it requires. JSONP is essentially  a hack that works around the browser’s same-origin security policy. And it is used to make `GET`just.

## Configuring Request Headers

If are using a commericial RESTful web service, will often have to set a request headers to provide an API key so that the server can associate the request with your app for access control and billing. Can set this kind of header – by configuring the configuration object that is passed to the `request`method. like:

```ts
private sendRequest<T>(verb: string, url: string, body?: Product)
    : Observable<T> {
    return this.http.request<T>(verb, url, {
        body:body,
        headers: new HttpHeaders({
            "Access-Key": "<secret>",
            "Application-Name":"exampleApp",
        })
    });
}
```

The `headers`prop is set to an `HttpHeaders`obj, which can be created using a map object of properties that correspond to header names and the values that should be used for them. And if has more complex demands for request headers – then can use the methods defined by the `HttpHeaders`class.

`keys(), get(name) <return the first>, getAll(name), has(name), set(header, value)`
`set(header,values), append(name,value), delete(name)`

So, HTTP headers can have multiple values, which is why there are methods that append values for headers. Fore: setting multiple header vlaues in the rest.datasrouce.ts file like:

```ts
private sendRequest<T>(verb: string, url: string, body?: Product)
    : Observable<T> {
    let myHeaders= new HttpHeaders();
    myHeaders= myHeaders.set("Access-key", "<secret>");
    myHeaders=myHeaders.set("Application-Names", ["exampleApp", "proAngular"]);
    return this.http.request<T>(verb, url, {
        body:body,
        headers: myHeaders,
    });
}
```

## Handling Errors

To make it easy to just generate an error, have added a button to the product table that will lead to an HTTP request to delete an object that doesn’t exist at all just like:

```html
<butotn class="btn btn-danger m-1" (click)="deleteProduct(1000000)">
    Generate HTTP error
</butotn>
```

The `button`just invokes the component’s `deleteProduct()`with an argument not exist.

### Generating User-Ready Messages

The first step in handling errors is convert the HTTP exception into sth that can be displayed to the user. And the default error message, which is one written to Js console. And the best way to transform error messages is to use the `catchError()`method – used with the `pipe`to receive any errors that occur with an `Observable`sequence.

```ts
return this.http.request<T>(verb, url, {
    body:body,
    headers: myHeaders,
}).pipe(catchError((error:Response)=> {
    throw (`Network error: ${error.statusText} (${error.status})`)
}));
```

### Handling the Errors

The errors have been transformed but not handled – which  is why still being reported as exceptions in the browser’s Js console. And there are two ways in which the errors can be handled – the first is to provide an error-handling function to subscribe the method for the `Observable`objects created by the `HttpClient`object.

And the second is to replace the built-in Ng error-handling feature – which just responds to any unhandled errors in the app by default, just write them to the console. It is just the feature that writes out – FORE, want to override the default error handler with one that *uses the message service* – 

```ts
@Injectable()
export class MessageErrorHandler implements ErrorHandler {
    constructor(private messageService: MessageService, private ngZone: NgZone) {
    }

    handleError(error: any): void {
        let msg = error instanceof Error ? error.message : error.toString();
        this.ngZone.run(() => this.messageService
            .reportMessage(new Message(msg, true)), 0);
    }

}
```

This `ErrorHandler`interface is just defined and – responds to errors through a `handleError()`method. The class shown in the listing replaces the default implemeantion of this method with one that uses the `MessageService`to report an error.

And, redefining the error handler presents a problem – want to display a message to the user, which requires the ng change detection process to be triggered. Defined `NgZone`and used its `run`to create error message. This `run`executes the function it receives and then *triggers the Angular change detection process*. For this, the result ist that the new message will be displayed to the user. Without the `NgZone`– the error message would be created but, would not be displayed to the user until the next time Ng detection process runs. 

Then need to replace the default `ErrorHandler`– like:

```ts
providers: [MessageService,
    {provide: ErrorHandler, useClass: MessageErrorHandler}]
// in the message.module.ts
```

## Configurable Services

In the case.. no arguments are required for the ctor – but what happens if a service’s ctor requires arguments – Can implement this by using a *factory* which is a function that can return any object when injected.

```ts
export interface Metric {
	eventName: string;
	scope: string;
}
```

When user .. logs in the `eventName`could be loggedIn and scope would be `nate`. FORE:

```ts
let metric: Metric= {
    eventName: "loggedIn",
    scrope: "nate"
};
```

Also define what an analytics implemenation would look like:

```ts
export interface AnalyticsImplementation{
	recordEvent(metric: Metric): void;
}
```

Then define the service like:

```ts
@Injectable()
export class AnalyticsService {
	constructor(private implementation: AnalyticsImplementation) {
	}
	record(metric: Metric) {
		this.implementation.recordEvent(metric);
	}
}
```

Just notice how its ctor takes a phrase as a parameter – if try to use the regular `useClass`to inject – see errors.

### Using a Factory

To use our `AnalyticsService`need to:

- create an implementation that conforms to `AnalyticsImplementation`
- Add it to `providers `use `useFactory`

```ts
@NgModule({
	imports: [CommonModule],
	providers: [
		{
			provide: AnalyticsService,
			useFactory() {
				// create an implementation that will log event.
				const loggingImplementation: AnalyticsImplementation = {
					recordEvent(metric: Metric) {
						console.log("The metric is:", metric);
					}
				};
				return new AnalyticsService(loggingImplementation);
			}
		}
	],
})
export class AnalyticsDemoModule {
}
```

Here in the `providers`we are using the syntax:

```ts
providers: [
    {provide: AnalyticsService, useFactory: ()=>...}
]
```

`useFactory()`takes a function and *whatever this function returns will be just injected*. Also note that .. when provide this way – using the class `AnalyticsService`as the *identifying token*.

### Factory Dependencies

Using a factory is the most powerful way to create injectables, but we can do whatever we want within the factory function – sometimes our factory function will have dependencies of its own. Say wanted to configure our … to make an HTTP request to a particular URL – fore: 

```ts
providers: [
    {provide: "API_URL", useValue: "http://eee.eee"},
    {provide: AnalyticsService,
    	deps: [HttpClient, "API_URL"], 
     // notice that the arguments there, the order is important -- corresponding the deps.
    	useFactory(http: HttpClient, apiUrl: string) {
            //...
        }}
]
```

`deps`is an array of injection tokens and these tokens will be resolved and passed as arg to the factory function.

### Dependency injection in Apps

When writing our apps there are 3 steps need to take in order to perform an injecton – 

1. Create the dependency (e.g. the service class).
2. Configure the injection (register with `NgModule`)
3. Declare the dependencies on the receiving component

A *provider* provides the *injectable*. In Ng when U want to access an *injectable* U *inject*.