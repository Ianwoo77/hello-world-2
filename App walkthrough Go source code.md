# App walkthrough: Go source code

Got one last.. Go has just the widest platform support, and also a very popular lang for cloud-native apps. like:

```dockerfile
FROM diamol/golang as bulder

COPY main.go .
RUN go build -o /server

# app
FROM diamol/base

ENV IMAGE_API URL="http://iotd/image" \
    ACCESS_API_URL="http://accesslog/access-log"

CMD ["/web/server"]

WORKDIR web
COPY index.html .
COPY --from=bulder /server .
RUN chmod +x server
```

Go just compiles to native binaries, so each stage in the Dockerfile uses a different base image. Fore, the builder stage uses `diamol/golang`which has all the Go tools installed. The final stage uses a minimal image, which just has the smallest layer of os, called `diamol/base.`

Note, that each stage runs independently, but can copy files and directories from previous stages. `--from`tells Docker to copy files from an earlier stage in the Dockerfile, rather than from the filesystem of the host computer.

```sh
docker image build -t image-gallery .
```

Then jsut compare Go application image size with Go toolset image:

```sh
docker image ls -f reference=diamol/golang -f reference=image-gallery
```

## Understanding multi-stage Dockerfiles

1. The first point is about standardiation -- All the builds run in Docker containers, and the container images have all the correct versions of the tools -- In real projects -- hugely simplifies on-boarding for new developers.
2. Perfornace -- each stage in a multi-stage build has its won cache -- Docker looks for a match in the image layer cache for each instruction.
3. Multi-stge Dockerfile let you fine-tune your build so the final app image is as lean as possible.

## Overusing getters and Setters

In programming, data encapsulation refers to hiding the values or state of an object -- Getters and Setters are means to enable encapsulation by just providing exported methods or top of unexported object fields.

In Go, here is no automatic support for getters and setters - it is also considered neither mandatory nor idiomatic to use getters and setters to access struct fields. like:

```go
timer := time.NewTimer(time.Second)
<- timer.C
```

Although it’s not recommended, could even modify `C`directly -- if does, could not receive events anymore. However, this example just illustrates that the std Go library doesn’t enforce using getters and/or setters even when we shouldn’t modify a field.

On the other hand, using getters and setters present some advantages -- including:

- They encapsulate a behavior associted with getting or setting a field, allowing new functionality to be added later.
- They hide the internal representaiton, giving more flexibility in what we expose.
- Provide a debugging interception point for when the property change at runtime.

Need to note, if fall into these cases or foresee a possible use case while guaranteeing forward compability. Using getters and setters may bring some vlaue. FORE, if use them with a filed called `balance`, should follow:

- The getter should named `Balance`, (not for `GetBalance`)
- The setter method should be named `SetBalance`

```go
currentBlance := customer.Balance()  // getter
if currentBalance < 0 {
    customer.SetBalance(0)
}
```

And in summary, shouldn’t overwhelm our code with getters and setters on structs if they don’t bring any value.

## Interface Pollution

Interfaces are one of the cornerstones of Go when designing and structuring our code -- Abusing them is generally not a good idea -- Interface pollution is about overwhelming our code with unncessary abstractions, making it hader to understand -- and it’s a common mistake made by developers coming from another lang.

### concepts

An interface provides a way to specify the behavior of an object -- use interfaces to create common abstraction that multiple objects can implement. What makes Go interface so different is that they are satisifed implicitly. There is no explicit keyword like `implements`in TS to make that an object implemetns interface...

To understand -- dig into two popular -- `io.Reader`and `io.Writer` -- The `io`provides abstractions for I/O primitives -- `io.Reader`relates to reading from data source, and `io.Writer`writing. Just:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
type Writer interface{
    Write(p []byte) (n int, err error)
}
```

Custom implentations of the `io.Reader`just accept a slice of bytes, filling it with its data and Custom implementation of `io.Writer`jsut write the data coming from slice to a target.

Assumes need to implement a func that should copy the content of one file to another. Function would work with `*os.File`(implements `io.Reader`and `io.Writer`)-- and any other type that would implement these interfaces. like:

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    source := strings.NewReader(input) // create an io.Reader
    dest := bytes.NewBuffer(make([]byte, 0)) // create an io.Writer
    err := copySourceToDest(source, dest)
    if err != nil{
        t.FailNow()
    }
    got := dest.String()
    if got != input{
        t.Errorf("expected: %s, got: %s", input, got)
    }
}
```

In the example, `source`is just a `*strings.Reader`whereas `dest`is a `*bytes.Buffer`. Here test the behavior of `copySourceToDest`without creating any files. NOTE:

**The bigger the interface, the weaker the abstraction**

Indeed, adding methods to an interface can just decrease its level of reusability -- `io.Reader`and `io.Writer`are powerful abstraction cuz they cannot get any simpler. Can also just combine fine-grained interfaces to create higher-level abstractions -- this is the case with `io.ReadWriter`, which combines the reader and writer behavior like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

### When to use interfaces

When should create interface in go -- Look 3 concrete use cases when interfaces are usually considered to bring value -- note that the goal isn’t to be exhaustive -- cuz more cases add, the more they would depend on the context.

- Common behavior
- Decoupling
- Restricting behavior

#### Common behavior -- 

Fore, sorting a collection can be factored out via 3 methods-- like:

```go
type Interface interface {
    Len() int
    Less(i,j int) bool
    Swap(i,j int)
}
```

So, finding the right abstraction to factor out a behavior can also bring many benefits. Fore, the `sort`provdies utility functions that also rely on `sort.Interface`-- such as checking whether a collection is already sorted like:

```go
func IsSorted(data Interface) bool {
    n:= data.Len()
    for i:=n-1; i>0; i-- {
        if data.Less(i, i-1){
            return false
        }
    }
    return true
}
```

For, this, cuz `sort.Interface`is right level of abs, it makes it highly valuable.

#### Decoupling

Another improtant use case is about decoupling code from an implemenation. If rely on an abstrction instead of a concrete impelmetnation -- the implemenation itself can be replaced with another  -- One benefit of decoupling can be related to **unit testing**. Fore, want to implement a `CreateNewCustomer()`and creates a new .. decide to rely on the concrete implemention directly -- fore:

```go
type CustomerService struct {
    store mySql.Store
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id: id}
    return cs.store.StoreCustomer(customer)
}
```

But -- want to test -- cuz `customerSerice` reles on the actual implemenation to store a `Customer`, we are obliged to test that through integration tests. Which also requires spinning up a MYSQL instance -- although integration tests are helpful -- that is not always what we want to do. So to give us more flexibility, we should decouple `CustomerService`from the actual implemenation, can be done like:

```go
type customerStorer interface{
    StoreCustomer(Custom) error  // create a storage abstraction
}
type CustomerSerivce struct {
    storer CustomerStorer
}

func (cs CustomerService) CreateNewCustomer(id string) error {
    //...
    return cs.storer.StoreCustomer(customer)
}
```

For, this, storing a customer is now done via an interface, this gives us more flexibility in how we want to test.

- use the concrete implementation via integration tests
- use a mock via unit tests
- or Both

#### Restricting Behavior

The last use case -- it’s about restricting a type to a specific behavior. Implementing a custom conf package to deal with dynamic conf -- create a specific container for `int`via an `IntConfig`struct that also exposes two methods:

```go
type IntConfig struct {
    //...
}

func (c *IntConfig) Get() int {
    //...
}

func (c *IntConfig) Set(value int) {}
```

Now suppose receive an `IntConfig`that hilds some speicifc configuration..  Yet, in code, are only interested in retrieving the conf value -- want to just prevent updating that -- So, how can we enforce that, semantically -- is read-only, for this situation, creating an abstraction that restricts the behavior to retrieving only a config value like:

```go
type intConfigGetter interface {
    Get() int
}
```

Then, can rely on this `intConfigGetter`instead of concrete implemenation like:

```go
type Foo struct {
    threshold intConfigGetter
}
func newFoo(thresold intConfigGetter) Foo { // injects the configuration getter
    return Foo{threshold: threshold}
}

func (f Foo) Bar() {
    threshold := f.threshold.Get()
    //...
}
```

In this example, the configuration getter is injectted into the `NewFoo`factory method. It doesn’t impact a client of htis func cuz it can still pass an `IntConfig`struct as it implemetns `intConfigGetter`. Now, can only read the configuration in the `Bar()`, not modifying that -- therefore, can also use interfaces to restrict a type to a specific behavior for various reasons.

### Interface Pollution

It’s fairly common to see interfaces being overused in Go -- Interfaces are just made to create abstraction -- And the main caveat when programming meets abstraction is remembering that abs *should be discovered, not created*. It means that shouldn’t start creating abs in code if there is no immediate reason to do so. Shouldn’t design with interfaces but wait for a concrete need. -- **should create an interface when need it, not when forsee what we could need it.**

For overusing -- make the code flow more complex -- adding a useless level of indirection doesn’t bring any value -- it creates a worthless abs making the code more difficult to read.

In summary, should be cautions when creating abstraction in our code -- abs should be discovered.

# Creating a Users Modle

Now that, the routes are setup, need to create a new users database table and a dbs model to access it. Start by connectt to MySQL form your terminal window as the `root`user and execute the SQL:

```sql
create table users (
    id integer not null primary key AUTO_INCREMENT,
    name varchar(255) not null ,
    email varchar(255) not null ,
    hashed_password char(60) not null ,
    created datetime not null,
    active boolean not null default TRUE
);

alter table users add constraint users_uc_email unique(email)
```

There is pointint out about this table:

- the `id`is an autoincrementing integer field and the PK for the table
- Set the type of the `hashsed_password`to `CHAR(60)`. this is cuz storing hashes of the user password in the dbs, not the passwords themselves
- Also, added a `UNIQUE`constraint on the `email`column and named it `users_uc_email`. This constraint ensures that won’t end up with two same email addresses.
- There is also `active`column use to contain the status of the user account -- when `TRUE`, the user will use to contain the status of the user account - be able to log in and use the app as normal, when `FASLE`just considiered deactived and won’t be able to log in.

## Building the Model in Go

Next, set up a model so that can easily work with the new `users`table -- follow the same pattern what used earlier, need to create and adda new `User`struct to hold the data for each user, plus a couple of new error types:

```go
var (
	ErrNoRecord = errors.New("models: no matching record found")

	// ErrInvalidCredentials add a new ErrInvalidCredentials error, use this if a user tries to login with
	// incorrect email and password
	ErrInvalidCredentials = errors.New("models: invalid credentials")

	// ErrDuplicateEmail use this if a user ties sign up with an email address already exists
	ErrDuplicateEmail = errors.New("models: duplicate email")
)

//... Snippet struct

// User then define a new User type
type User struct {
	ID             int
	Name, Email    string
	HashedPassword []byte
	Created        time.Time
	Active         bool
}
```

Now that the types have been set up, need to make the actual dbs model -- need to create a new go file. The final stage is to add a new field to the `application`struct so that we can make this model available to our handlers.

```go
type application struct {
    //... other
    users *mysql.UserModel
}
// ...
app := &application{errorLog: errorLog, infoLog: infoLog, snippets: &mysql.SnippetModel{db},
                templateCache: templateCache, session: session, users: &mysql.UserModel{DB: db}}
```

## User Signup and Password Encryption

Before can log in any users to our app, first need a way for them to sign up for an account. Need to create a new template file containing:

```html
{{template "base" .}}

{{define "title"}}Signup{{end}}

{{define "main"}}
	<form action="/user/signup" method="post" novalidate>
        {{with .Form}}
			<div>
				<label>Name:</label>
                {{with .Errors.Get "name"}}
					<label class="error">{{.}}</label>
                {{end}}
				<input type="text" name="name" value="{{.Get "name"}}">
			</div>

			<div>
				<label>Email:</label>
                {{with .Errors.Get "email"}}
					<label class="error">{{.}}</label>
                {{end}}
				<input type="email" name="email" value="{{.Get "email"}}">
			</div>

			<div>
				<label>Password:</label>
                {{with .Errors.Get "password"}}
					<label class="error">{{.}}</label>
                {{end}}
				<input type="password" name="password">
			</div>

			<div>
				<input type="submit" value="Signup">
			</div>
        {{end}}
	</form>
{{end}}
```

Then just need to hook this up to the `SignUserForm`handler.

```go
func (app *application) signupUser(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "signup.page.html", &templateData{
		Form: forms.New(nil),
	})
}
```

### Creating Context class:

```cs
public class DbContextClass : DbContext
{
    protected readonly IConfiguration Configuration;
    public DbContextClass(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlServer(Configuration.GetConnectionString("DefaultConnection"));
    }
    public DbSet<Product> Products => Set<Product>();
}
```

And may need to re-migration? Then change the `ProductController`class like:

```cs
// .. note that this Context has attribute [Authorize]!!!
[HttpGet("ProductsList")]
public async Task<ActionResult<IEnumerable<Product>>> Get()
{
    var productCache = new List<Product>();
    productCache = _cacheService.GetData<List<Product>>("Product");
    if (productCache == null)
    {
        var product = await _dbContext.Products.ToListAsync();
        if (product.Count > 0)
        {
            productCache = product;
            var expirationTime = DateTimeOffset.Now.AddMinutes(3);
            _cacheService.SetData("Product", productCache, expirationTime);
        }
    }
    return productCache!;
}

[HttpGet("ProductDetail")]
public async Task<ActionResult<Product>> Get(int id)
{
    var productCache = new Product();
    var productCacheList = new List<Product>();
    productCacheList = _cacheService.GetData<List<Product>>("Product");
    productCache = productCacheList.Find(x => x.ProductId == id);
    if (productCache == null)
    {
        productCache = await _dbContext.Products.FindAsync(id);
    }
    return productCache!;
}

[HttpPost("CreateProduct")]
public async Task<ActionResult<Product>> Post(Product product)
{
    await _dbContext.Products.AddAsync(product);
    await _dbContext.SaveChangesAsync();
    _cacheService.RemoveData("prodcut");

    // produces a 201 response
    return CreatedAtAction(nameof(Get), new
    {
        id = product.ProductId
    }, product);
}

[HttpPost]
[Route("DeleteProduct")]
public async Task<ActionResult<IEnumerable<Product>>> Delete(int id)
{
    var product = await _dbContext.Products.FindAsync(id);
    if (product == null)
    {
        return NotFound();
    }
    _dbContext.Products.Remove(product);
    _cacheService.RemoveData("Product");
    await _dbContext.SaveChangesAsync();
    return await _dbContext.Products.ToListAsync();
}

[HttpPost]
[Route("UpdateProduct")]
public async Task<ActionResult<IEnumerable<Product>>> Update(int id, Product product)
{
    if (id != product.ProductId)
    {
        return BadRequest();
    }
    var productData = await _dbContext.Products.FindAsync(id);
    if (productData == null)
    {
        return NotFound();
    }
    productData.ProductCost = product.ProductCost;
    productData.ProductDescription = product.ProductDescription;
    productData.ProductName = product.ProductName;
    productData.Stock = product.Stock;
    _cacheService.RemoveData("Product");
    await _dbContext.SaveChangesAsync();
    return await _dbContext.Products.ToListAsync();
}
```

And, going to create Login and JWTTokenResponse class for the JWT authentication part like:

```cs
public class Login
{
    public string? UserName
    {
        get;set;
    }

    public string? Password { get;set; }
}

// create JSTTokenResponse for token
public class JWTTokenResponse
{
    public string? Token { get;set; }
}
```

And create `AuthenticationController`inside the `Controllers`for authentication of user just like:

```cs
static class ConfigurationManager
{
    public static IConfiguration AppSetting
    {
        get;
    }
    static ConfigurationManager()
    {
        AppSetting= new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json").Build();
    }
}

[Route("api/[controller]")]
[ApiController]
public class AuthenticationController : ControllerBase
{
    [HttpPost("login")]
    public IActionResult Login([FromBody] Login user)
    {
        if(user is null)
        {
            return BadRequest("Invalid user request!!!");
        }
        if(user.UserName=="Bender" && user.Password == "Pass@777")
        {
            var secretKey = new SymmetricSecurityKey(Encoding
                .UTF8.GetBytes(ConfigurationManager.AppSetting["JWT:Secret"]!));
            var signinCredentials = new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256);
            var tokeOptions = new JwtSecurityToken(issuer: ConfigurationManager
                .AppSetting["JWT:ValidIssuer"], audience: ConfigurationManager
                .AppSetting["JWT:ValidAudience"], claims: new List<Claim>(), 
                expires: DateTime.Now.AddMinutes(6), signingCredentials: signinCredentials);
            var tokenString = new JwtSecurityTokenHandler().WriteToken(tokeOptions);
            return Ok(new JWTTokenResponse
            {
                Token = tokenString
            });
        }
        return Unauthorized();
    }
}
```

As can see – take the Username and password from the User - then take the secret key which we put inside the appsettings.json file – 

- Create signing credentials using a secret key using HMAC SHA256 crypto algorithm for encoded string.
- Put a few attrs while creating tokens like signing credentials…
- Finally, using Token handler create token and which is the encoded form and send to the end-user.

```json
"JWT": {
    "ValidAudience": "http://localhost:5000",
    "ValidIssuer": "http://localhost:5000",
    "Secret": "JWTAuthentication@777"
},
```

Next, need to register all servers related to JWT authentication – FORE, Swagger UI, CORS, and cache services.

```cs
// in the program.cs file:
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

builder.Services.AddScoped<ICacheService, CacheService>();
builder.Services.AddDbContext<DbContextClass>(opts =>
opts.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddAuthentication(opts =>
{
    opts.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    opts.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(opts =>
{
    opts.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = RedisCache.Cache.ConfigurationManager.AppSetting["JWT:ValidIssuer"],
        ValidAudience = RedisCache.Cache.ConfigurationManager.AppSetting["JWT:ValidAudience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8
            .GetBytes(RedisCache.Cache.ConfigurationManager.AppSetting["JWT:Secret"]!))
    };
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

# Configuring ASP.NET Identity

A configuration change is required to prepare ASP.NET core Identity – like:

```cs
builder.Services.AddDefaultIdentity<IdentityUser>(options => 
                                                  options.SignIn.RequireConfirmedAccount = false)
    .AddEntityFrameworkStores<ApplicationDbContext>();
```

Identity here is added to the application just using the `AddDefaultIdentity`extension – and the default configuration created by the project template sets the configuration so that user accounts cannot be used until they are confirmed – which requires the user to click a link the are emailed.

## Creating the Application Content

To prepare the user with list of items just change the `Index.cshtml`file in the `pages`

```cs
public class IndexModel : PageModel
{
    private ApplicationDbContext Context;
    public IndexModel(ApplicationDbContext context)
    {
        Context = context;
    }

    [BindProperty]
    public bool ShowComplete { get; set; }

    public IEnumerable<TodoItem> TodoItems { get; set; }

    public void OnGet()
    {
        TodoItems = Context
            .TodoItems.Where(t => t.Owner == User.Identity!.Name)
            .OrderBy(t => t.Task);
        if (!ShowComplete)
        {
            TodoItems = TodoItems.Where(t => !t.Complete);
        }
        TodoItems = TodoItems.ToList();
    }

    public IActionResult OnPostShowComplete()
    {
        return RedirectToPage(new { ShowComplete });
    }

    public async Task<IActionResult> OnPostAddItemAsync(string task)
    {
        if (!string.IsNullOrEmpty(task))
        {
            TodoItem item = new TodoItem
            {
                Task = task,
                Owner = User.Identity!.Name!,
                Complete = false,
            };
            await Context.AddAsync(item);
            await Context.SaveChangesAsync();
        }
        return RedirectToPage(new { ShowComplete });
    }

    public async Task<IActionResult> OnPostMarkItemAsync(long id)
    {
        TodoItem item = Context.TodoItems.Find(id)!;
        if (item != null)
        {
            item.Complete = !item.Complete;
            await Context.SaveChangesAsync();
        }
        return RedirectToPage(new { ShowComplete });
    }
}
```

Then open a new .. and request – This targets the `index.cshtml`

# Submitting data to the Server (recovery)

Use the `MediatR`– is an in-process messaging library that implements the **mediator pattern** – Rquests are constructed and passed to the mediator which then passes them to a handler – uses DI to connect requests and with handlers like:

```sh
install-package MediatR  # in the Shared proj
```

create a `record`to be inherited from the `IRequest<>`like:

```cs
public record AddTrailRequest(TrailDto Trail) : IRequest<AddTrailRequest.Response> {
    public const string RouteTemplate="/api/trails";
    public record Response(int TrailId);
}
```

The record just implements the `IRequest<T>`interface that is used by `MediatR`*when locating a handler*. For now, have a request, Then need to create a handler for it. For handler, in the Client proj just:

```cs
public class AddTrailHandler: IRequestHandler<AddTrailRequest, AddTrailRequest.Response> {
    //... ctor for DI
    public async Task<AddTrailRequest.Response>
        Handle(AddTrailRequest request, CancellationToken token) {
        var response = await httpClient.PostAsJsonAsync(...);
        if (success) {
            return new ... (trailId);
        }else{
            return new ...(-1);
        }
    }
}
```

Handler just implements the `IRequestHandler<TRequest, TResponse>`– req is the type of request the handler handles, and resp is the type of response the handler will return.

Then use this in the razor component like:

```cs
@inject IMediator Mediator // hook up our request to form's submit event
private async Task SubmitForm() {
    var resp = await Mediator.Send(
    	new AddTrailRequest(_trail)
    ); // dispatch req and await resp
    if (wrong) {
        //... some error messaage
        return;
    }
    // reset the form note that
}
```

## ApiEndpoints

It solves an issue – controllers – whatever MVC or API controllers - ApiEndpoints solves this by allowing to define an endpoint as a class with a just single method to handle the incoming req.

In the server proj: 

```sh
install-package Ardails.ApiEndpoints
```

Note, there is no further configuration required, as the library provides base classes for us to use along with some data analyzers. Just like:

```cs
public class AddTrailEndpoint : EndpointBaseAsync
        .WithRequest<AddTrailRequest>
        .WithResult<int> {//...
}
```

The key is :

`var response = await _httpClient
                .PostAsJsonAsync(AddTrailRequest.RouteTemplate, request, cancellationToken);`

The `SubmitForm()`function call the `Mediator.Send()`method, it calls the `AddTrailHandler.Handle()`, the `Handle()`method calls the `PostAsJsonAsync()`this calls the API just be handled by the endpoint – `ApiEndpoints`, this is responsible to create `DbContext`using EF core and write data to the dbs.

- The primary advantage of using Blazor form components over traditional HTML forms is *validation*.
- The `EditForm`component is a drop-in replacement for the `form`element
- Blazor ships with component versions of **all** std HTML input controls.
- The `EditForm`rquires a model that represents the data the form will collect, as well as a handler for one of the submit events it exposes (`OnSubmit, OnValidSubmit, OnInvalidSubmit`)
- To use Blazor’s input components, bound to a prop on the model passed to the `EditContext`done using the `@bind`directive.
- Blazor also ships with a validation component called `DataAnnotationValidator`

# Forms and Validation Part II

- Customizing validation CSS class names
- Biulding custom input components
- uploading files
- Designing forms to handle adding and editing

Extend Trail form with some more advanced features – For this app, We store that value (time) as the total time in minutes, even though display it as hours and minutes – want the users to be able to enter the time in hours and minutes – shoulnd’t have to wrok out total time in minutes..

The ability to upload fils is a common requirement in apps – and Blazing trails is no different – need to allow the user to upload a trail image if they choose, and Blazor provides us a component for doing just that – however, this `Input`component doesn’t work quite the same..

Then allow the editing of existing trails.

## Customizing Validation CSS classes

Blazor allows to use these classes – instead of the default ones it provides – by specifying them in a custom `FieldCssClassProvider`– modify the app to use the classes provided by *bootstrap* for valid and invalid inputs like:

### Creating a `FieldCssClassProvider`

To do this – going to create this class in a new folder at the root of the ..

```cs
public class BootstrapCssClassProvider: FieldCssClassProvider
{
    public override string GetFieldCssClass(EditContext editContext, 
        in FieldIdentifier fieldIdentifier)
    {
        var isValid= !editContext
            .GetValidationMessages(fieldIdentifier).Any();
        if(editContext.IsModified(fieldIdentifier))
        {
            return isValid ? "is-valid" : "is-invalid";
        }
        return isValid ? "" : "is-invalid";
    }
}
```

Just need to override the `GetFiledCssClass()`– this takes an `EditContext`and a `FieldIdentifier`that represent the *field in the form* we’re getting CSS classes for. The `EditContext`is just the **Brain** of the form and keeps track of the state of each field in the form. Use its `GetValidationMessages()`to check if there are any validation messages for the current field. – if there are, know field is currently not valid and can set `isValid`variable accordingly.

Next, using its `IsModified`to check if the field has been edited by the user in any way. For a field to be modified, the user must have typed sth or changed a selection.

When have a modified field, depending on if it’s valid or not - going to return either the `is-valid`or `is-invalid`class. These classes are part of the Bootstrap framework and will allow us to remove the custom css classes.

# Using a Form Array

`FormArray`stores its children in an array and provides props and methods.

`controls, length, at(index), push(control), insert(index,control), setControl(index,control)`
`removeAt(index), clear()`

Settings the values of the controls it managing:

`setValue(values), patchValue(values), reset(values)`

## Validating Dynamically Created form controls

Is just similar to validating the controls in a `FormGroup`like:

`return new FormControl(“”, {validators:…})` // in the `createKeywordFormControl()`

# Making HTTP Requests

Demonstrate how to use async HTTP rquests, often called Ajax requests, to interct with a web service to get real data into an app –

Rely on a server that responds to http requests with JSON data. just :

```sh
npm install json-server
```

in the package.json scrips field:

```js
"json": "json-server --p 3500 restData.js"
```

### Configuring the model feature module

The `@angular/common/http`js module contains an Angular module called `HttpClientModule`which must be imported into the app in either root module or one of the feature modules before HTTP requests can be created. Imported the module to the `model`module.

```ts
@NgModule({
    imports:[HttpClientModule],
    //...
```

Add:

```js
module.exports= function() {
    var data = {
        products: [...]
    };
    return data;
}
```

The `json-server`package can work with JSON or Js files. using js files means that allows data to be generated programmatically and restarting the process will return to the original data just.

## Understanding RESful web services

The most commaon approach for delivering data to an app is to use the REST – to create data web service. The core premise of a RESTful web service is to embrace the characteristics of HTTP so that request method – *verbs*.

## Replacing the static Data Source

The best place to start with HTTP request is to replace the static data source in the example appliation with one that retrieves data form the Restful web service – this will provide a foundation for describing how Ng supports HTTP requests and how they can be integrated into an application.

### Creating the new Data source service

To create a new data source, added a file called `rest.datasource.ts`in the model folder and added:

```ts
export const REST_URL = new InjectionToken("rest_url");

@Injectable()
export class RestDatasource {
    constructor(private http: HttpClient,
                @Inject(REST_URL) private url: string) {
    }

    getData(): Observable<Product[]> {
        return this.http.get<Product[]>(this.url);
    }
}
```

This is just a somple class – some important feature at work – 

### Setting Up the HTTP request

Ng provides the ability to make async HTTP requests through the `HttpClient`class – provided as a service in the `HttpClientModule`feature module. The other ctor arg is used so that the URL that requests are sent to doesn’t have to be hardwired into the data source. Create a provider using the `REST_URL`opaque token.

And, note that the `HttpClient`class defines a set of methods for making HTTP requests – each of which uses a different verb.

but the normal is:

- `request(method, url, options)`-- can be used to send a request with any verb.

### Processing the Response

The methods accept a type parameter – which the `HttpClient`uses to parse the response received from the server. The RESTful server returns a JSON, which has become the de facto – and the `HttpClient`object will automatically convert the response into an `Observable`that yields an instance of the type parameter when it completes. This means if you call an `get`– then the response from the `get`will be an `Observable<Product[]>`that represents the eventual response from the HTTP request.

### Configuring the Data Source

Next, is to configure a provider for the new data soruce and to create value-based provider to configure it with a URL to which requests will be sent.

```ts
@NgModule({
    imports:[HttpClientModule],
    providers:[Model, RestDatasource,
        {
            provide: REST_URL, useValue: `http://${location.hostname}:3500/products`
        }]
})export class ModelModule{}
```

The two new providers enable the `RestDataSource`class as a service and use the REST_URL token to configure the URL for the web service.

### Using the REST Data Source

The final step is to update the repository class so that it declares a dependncy on the new data source and uses it to get the app data like:

```ts
constructor(private dataSource: RestDatasource) {
    this.products = new Array<Product>();
    this.dataSource.getData().subscribe(data=> this.products=data);
}
```

## Saving and Deleting Data

The data source can get data from the server, but it also needs to send data the other way – persisting changes that the user makes to objects in the model and storing new objects that are created. Just:

```ts
saveProduct(product: Product): Observable<Product> {
    return this.http.post<Product>(this.url, product);
}

updateProduct(product: Product): Observable<Product> {
    return this.http.put<Product>(`${this.url}/${product.id}`, product);`
}

deleteProduct(id: number): Observable<Product> {
    return this.http.delete<Product>(`${this.url}/${id}`);
}
```

These methods follow the same pattern – cal one of the `HttpClient`class methods and return an `Observable`as the result. When saving, What these methods have in common is that the server is the authoritative data store, and the response from the server contains the official version of the object that ahs been saved by the server.

Then using the data source features in the `repository.model.ts`file like:

```ts
saveProduct(product: Product) {
    if (product.id == 0 || product.id == null) {
        this.dataSource.saveProduct(product)
            .subscribe(p => this.products.push(p));
    } else {
        this.dataSource.updateProduct(product)
            .subscribe(p => {
                let index = this.products.findIndex(item => this.locator(item, p.id));
                this.products.splice(index, 1, p);
            })
    }
}

deleteProduct(id: number) {
    this.dataSource.deleteProduct(id).subscribe(() => {
        let index = this.products.findIndex(p => this.locator(p, id));
        if (index > -1)
            this.products.splice(index, 1);
    });
}
```

The changes use the data source to send updates to the server and use the results to update the locally stored data so that it is displayed by the rest of the applciation.

## Consolidating HTTP Requests

Each of the methods in the data source class duplicates the same basic pattern of sending the HTTP request using a verb-specific `HttpClient`method – this means that any change to the way that the HTTP request are made has to be replaced in 4 different places – ensuring that the requests that use the `GET POST PUT DELETE`verbs are correctly updated and performed consistently.

The `HttpClient`also defines the `request`which allows the HTTP verb to be specified as an arg just like:

```ts
private sendRequest<T>(verb: string, url: string, body?: Product)
    : Observable<T> {
    return this.http.request<T>(verb, url, {body: body});
}

getData(): Observable<Product[]> {
    return this.sendRequest<Product[]>("GET", this.url);
}

saveProduct(product: Product): Observable<Product> {
    return this.sendRequest<Product>("POST", this.url, product);
}

updateProduct(product: Product): Observable<Product> {
    return this.sendRequest<Product>("PUT",
        `${this.url}/${product.id}`, product);`
}

deleteProduct(id: number): Observable<Product> {
    return this.sendRequest<Product>("DELETE", `${this.url}/${id}`);
}
```

The `request`method accepts just the HTTP verb, the URL for the request, and an optional object that is used to configure the request. The configuration object is used to set the request body using the `body`prop. And the most useful props that can be specified to configure the HTTP request using the `request`:

- `headers` – returns an `HttpHeaders`object that allows the request headers to be specified.
- `body` – used to set the request body, the obj assigned to this prop will be serialized as JSON when the request is sent.
- `withCredentials`-- when `ture`, this is used to include authentication cookies when making cross-site requests. This settings must be used only with servers that include the `Access-Control-Allow-Credentials`headers in response, as part of the Cross-Origin Resource Sharing (CORS) specification.
- `responseType`– used to sepcify the type of response expected from the server. The default value is `json`.

## Using a value as Provider

Another way can use DI is to provide a value – much like might use a global constant – fore, might configure an API endpoing URL depending on the environment like:

`providers: [{provide: "API_URL", useValue: "http://myapi.com/v1"}]`

This, for the `provide`token, using a *string* of `API_URL`– if we use a string for the `provide`, Ng can’t infer which dependency we are resolving by the type, fore :

`constructor(apiUrl: "API_URL")` // error

So, use the `@Inject()`decorator like:

```ts
constructor(@Inject("API_URL") apiUrl: string) {}
```

### Configurable Services

In the case of `UseService`, no arg are required for the `constructor`– but, what happens if a service’s ctor requires args – can implement this by using *factory* which is a function that can just return **any object** when injected.

FORE, writing a lib for recording user analytics, want to have an `AnalyticsService`with a catch, the service should define the interface for *recording* events- but not the implementation for handling the event.
