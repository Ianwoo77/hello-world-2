# Configure the Nginx Server

Nginx is most commonly run using virtual hosts, like what do with Apache - All configuration files for Nginx are located in `/etc/nginx`. The primary configuration file is just the `/etc/nginx/nginx.conf`like:

- `user`– sets the system user that will be used to run Nginx. `www-data`by default.
- `worker processes`-- set how many processes Nginx may spawn
- `error log`
- `events`and `worker_connections`– adjust how many concurrent connection Nginx will allow per proress.
- `http`– contains the base settings for HTTP access..

Whenever U make a change to the `nginx.conf`, must restart Nginx to reload the configuration. like:

```sh
sudo systemctl start nginx
sudo systemctl stop nginx
```

## Key Files, directories and Commands

`/etc/nginx`is the default configuration root for the Nginx server and the `/etc/nginx/nginx.conf`is the default confgiuration entry point used by the service, and the `/etc/nginx/conf.d/`dir contains the **default** HTTP server configuration file. `/var/log/nginx`is the default log location for NGINX.

## Serving Static content

Overwrite the default HTTP server configuration located in the `/etc/nginx/conf.d/default.conf`

```sh
server {
    listen 80 default_server;
    server_name www.example.com;

    location / {
        root /usr/share/nginx/html;
        # alias /usr/share/nginx/html;
        index index.html;
    };
}
```

This just configuration serves static files over on port 80 from the /usr/share/nginx/html/.

```sh
sudo nginx -t # test and show error log
```

## Virtual hosting

One of the most popular services to provide with a web server is to host a virtual domain. A virtual domain is a complete website with its own domain name. Just create a configuration file for your virtual host, placed in `/etc/nginx/site-enabled`. Prefer to place our files in `/etc/nginx/sites-available`and then create a symlink in `sites-enables`. This is note required.

The configuration files for Nginx tell web server where to find them. FORE, name the file *yourdomain.com* and place it in `sites-enabled`or `sites-available` like:

# Subtests

A subtest is a standalone test similar to a top-level test – subtests allows you to run a test under a top-level test in isolation and choose which ones to run.

- Isolation allows a subsets to fail and others to continue
- It also allows you to run each subset in parallel if wanted.
- Can choose which subtests to run.

### What makes a test a subtest

Can do so by calling the `Run`method of the `*testing.T`wiht a top-level test function like:

```go
t.Run(subtestName string, subtest func(t *testing.T)) bool
```

- Each subtest has a name. When the testing package runs a top-level test function, it automatically uses a test function’s name – when want to run a subtest yourself, might want to give it a name.
- The testing package will run the function using `subset`input value. 

Discuss what happens when you run them under a top-level test – the testing package automaticllay runs two top-level test functions by itself. Cuz the testing package just calls top-level test function as a *subtest* under the hood. Namely:

- There are two top-level test function
- The testing package can just **automatically run the top-level as subsets.**
- The second top-level wants to run three subtests - needs to just tell the testing pakcage to do so. The testing package will run these tests as subtests under the `TestURLPort`test. Like:

```go
func TestURLPort(t *testing.T) {
	t.Run("with port", func(t *testing.T) {
		const in = "foo.com"
		u := &URL{Host: in}
		if got, want := u.Port(), ""; got != want {
			t.Errorf("for host %q; got %q; want %q", in ,got, want)
		}
	})
	t.Run("ip with port", func(t *testing.T) {
		const in = "1.2.3.4:90"
		u:= &URL {Host: in}
		if got, want := u.Port(), "90"; got!=want {
			t.Errorf("For thost %q, got %q; want %q", in , got, want)
		}
	})
}
```

As can see, there is just a duplication problem in subtests.

### The failfast flag

Can use `failfast`flag– it’s for stopping tests in a single package if one of them fails.

```sh
go test -failfast
```

### The `run`flag

Just run a *specific* subset using the run flag like:

```sh
go test -v -run=...
```

## Avoiding duplication

Combining subtests with a test helper:

```go
func TestURLPort (t *testing.T) {
    testProt := func(in, wantPortString){
        t.Healper()
    }
}
```

Or using a higher-order function like:

```go
t.Run("name here", testPort("host", "port"))
```

```go
func TestURLPort(t *testing.T) {
    testPort := func(in, wantPort string) func(*testing.T) {
        return func(t *testing.T){
            //...
        }
    }
    t.Run("name here", testPort("...", "..."))
}
```

### Combining subtests with table-tests

When combining table-driven tests with subtests, can have all of the benefits. Just like:

```go
func TestURLPort(t *testing.T) {
    tests := map[string]struct {
        in string
        port string
    }{
        ...,
        ...,
    }
    for name, tt := range tests {
        t.Run(name, func(t *testing.T) {
            //...
        }
    }
}
```

### Making the failure message concise

```go
for name, tt := range tests {
    t.Run(fmt.Sprintf("%s%s", name, tt.in), func(t *testing.T) {
        //...
        t.Errorf("got %q; want :%q", got, want)
    })
}
```

### Wrap up

- Subtests are test functions that can be programmatically called
- Top-level test functions are also subsets under the hood.
- Subsets allow running table-driven test cases in isloation
- Subtests make failure messages concise and descriptivie
- Subtests help to organize tests in hierarchy.

## Implementing the Parser

```go
func TestURLHost(t *testing.T) {
	tests := map[string]struct {
		in, hostname, port string
	}{
		"with port":       {"foo.com:80", "foo.com", "80"},
		"with empty port": {in: "foo.com", hostname: "foo.com", port: ""},
		"without port":    {in: "foo.com:", hostname: "foo.com", port: ""},
		"ip with port":    {in: "1.2.3.4:90", hostname: "1.2.3.4", port: "90"},
		"ip without port": {in: "1.2.3.4", hostname: "1.2.3.4", port: ""},
	}

	for name, tt := range tests {
		t.Run(fmt.Sprintf("Hostname/%s/%s", name, tt.in), func(t *testing.T) {
			u := &URL{Host: tt.in}
			if got, want := u.Hostname(), tt.hostname; got != want {
				t.Errorf("got %q; want %q", got, want)
			}
		})

		t.Run(fmt.Sprintf("Port/%s/%s", name, tt.in), func(t *testing.T) {
			u := &URL{Host: tt.in}
			if got, want := u.Port(), tt.port; got != want {
				t.Errorf("got %q; want %q", got, want)
			}
		})
	}
}
```

# Setting Security Headers

```go
func securityHeaders(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("X-XSS-Protection", "1; mode=block")
        w.Header().Set("X-Frame-Options", "deny")
        
        next.ServeHTTP(w, r)
    })
}
```

Then to do this need to wrap our serveMux – just:

```go
func(app *application) routes() http.Handler {
    mux := http.NewServeMux()
    //...
    return secureHeaders(mux)
}
```

### Early Returns

Another thing to mention is that if you call `return`in middleware function *before* you call the `next.ServeHTTP()`, then the chain will stop being executed and control will flow back upstream. like:

```go
func middleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w, r) {
        if !isAuthorized(r) {
            w.WriteHeader(http.StatusForibdden)
            return
        }
        
        // otherwise just call the next handler in the chain
        next.ServeHTTP(w, r)
    })
}
```

## Request Logging

Just continue the same vein and add some middleware to log `HTTP`request – Specially, going to use the *info logger* .

```go
func (app *application) logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr, r.Proto, r.Method, r.URL.RequestURI())
		next.ServeHTTP(w, r)
	})
}
```

Then just update `routes.go`fiel – like:

`return *app*.logRequest(secureHeaders(mux))`

## Panic Recovery

in a simple go - when your code panics it will result in the application being terminated straight away. But our web app is a bit more sophisticated – Go’s http server assumes that the effect of any panic is isolated to the goroutine serving the active HTTP request – Specially, following a panic our server just will log a stack trace to the server error log, unwind the stack for the affected goroutine and close the underlying HTTP connection.

A neat way of doing this is to create some middleware whch recovers the panci and calls our `app.serverError()`helper method, to do, can leverage fact that deferred functions are always called when the stack is being unwound following a panic like:

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			// use the deferred func
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				app.serverError(w, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

- Just note setting the `Connection: Close`header on the response acts as a trigger to make Go’s HTTP server automatically *close the current connection* after a response has been sent. It also informs the user that the connection will be closed.
- The value returned by the `recover()`built-in has the type of `interface{}`– and its underlying type could be just `string, error`or sth else – We normally this into an `error`by using the `fmt.Errorf()`to create a new `error`object containing the default textual representation of the `interface{}`vlaue.

`return *app*.recoverPanic(*app*.logRequest(secureHeaders(mux))) `

### Panic recovery in other Background goroutines

It’s important to realise that our middleware will only recover panics that happen in the *same goroutine* that execute the `recoverPanic()`middleware.

## Composable Middleware Chains

Just introduce the `justinas/alice`to help manage our middleware/handler chains. Cuz it makes it easy to create composable, reusable, middleware chains – that can be just real help as your app grows and your routes become more complex – the package itself is also just small. like:

`return myMiddleware(myMiddleware2(...))`

into:

`return alice.New(myMiddleware1, myMiddleware2,...).Then(myHandler)`

But, the real power lies in the fact that you can use it to create middleware chains that cna be assigned to vars.

```go
myChain := alice.New(myMiddleware1, myMiddleware2)
myOtherChain := myChain.Append(myMiddleware3)
return myOtherChain.Then(myHandler)
```

So change it as:

`standardMiddleware :=alice.New(*app*.recoverPanic, *app*.logRequest, secureHeaders)`

# Restful Routing

Going to just add a HTML form to our web app so that the users can create new snippets:

Going to update our app routes so that requests to `/snippet/create`are handled differently based on the request method. like:

- For `/GET/snippet/create`want to show the user the HTML from adding a new snippet
- For `POST /snippet/create` want to process this form data and then insert a new `snippet`

## Installing a Router

`Pat`or **Gorilla Mux** – both have good documenation, decent test coverage, and work well with the std patterns for handlers and middleware that used throughout – 

- `bmizerany/pat`– more focused and just lightweight of the two packages – provides method-based routing and supports for semantics URLs.
- `gorilla/mux`– more full-featured. Can also use it to route based on scheme, host and headers. Regluar expresssion patterns in URLs are also supported.

## Implementing RESTful Routes

The basic syntax for creating a router and registering a route with the `bmizerany/pat`package like:

```go
mux := pat.New()
mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))
```

- `/snippet/:id`pattern includes a named capture `:id`which acts like a wildcard, whereas the rest of the pattern matches literally, Pat will add the contents of the named capture to the URL query string at runtime behind…
- The `mux.Get()`is used to just register a URL pattern and handler which will be called *only* if the request has a `GET`http method.
- Pat doesn’t allow to register handler functions directly. Just like:

```go
//...
mux := pat.New()
mux.Get("/", http.HandlerFunc(app.home))
mux.Get("/snippet/create", http.HandlerFunc(app.createSnippetForm))
mux.Post("/snippet/create", http.HandlerFunc(app.createSnippet))
mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))
fileServer := http.FileServer(http.Dir("./ui/static/"))
mux.Get("/static/", http.StripPrefix("/static", fileServer))
```

Just note that the URL patterns which end in a trailing slash like `/static/`work in the same way as with Go’s inbuilt servemux. And Also note that the `/`is a special in this case – it will only match requests where the URL path is **EXACTLY** `/`.

# Managing Many-to-Many Relationships

The action method queries the ds for the object that the user has selected and passes it to a view.

```cs
public IActionResult EditShipment(long id)
{
    ViewBag.Products = context.Products
        .Include(p => p.ProductShipments);
    return View("ShipmentEditor", context.Set<Shipment>().Find(id));
}
```

To allow the user to edit the relationships for a `Shipment`object, need the object itself and the complete collection of `Product`objects. Just get the `Product`and the `ProductShipmentJunction`objects in a single query. 

The `Shipment`obj is used to display prop values to the user and to provide the value for the hidden `input`.

```cs
public IActionResult UpdateShipment(long id, long[] pids)
{
    Shipment shipment = context.Set<Shipment>()
        .Include(s => s.ProductShipments).First(s => s.Id == id);

    shipment.ProductShipments = pids.Select(pid =>
        new ProductShipmentJunction
        {
            ShipmentId = id,
            ProductId = pid
        }).ToList();
    context.SaveChanges();
    return RedirectToAction("Index");
}
```

The new action method just receives the `Id`value of the `Shipment`object that the user has edited and an array of the `Id`values for the `Product`objects for which relatinships are required. Next is to just replace the collection of junction objects with ones that contain just the relationship that the user has chosen. The LINQ `Select`jsut project a seq of `ProductShipmentJunction`objs whose FK are set to represen one of the relationships that the user has chosen – No explicit action is required to delete the existing that are no longer required.

# Scafflolding an Existing Dbs

A different approach is required for projects that need to use an existing dbs – called **database-first** development. Just to help put the SQL that appears in this part – there are tables in the example:

- `Shoes`– centerpiece of the dbs and will contain details of the products produced by the company.
- `Categories`– set of categories used to describe the running… It has M-t-M REL with `Shoes`throught the `ShoeCategoryJunction`table.
- `Colors`– table that contains the set of color combinations in which shoes are availble and has a one-to-many REL wth the `Shoes`
- `SalesCampaigns`, one-one REL with Shoes.

```sql
create table Colors (
	Id bigint IDENTITY(1,1) NOT NULL,
	Name nvarchar(max) NOT NULL,
	MainColor nvarchar(max) NOT NULL,
	HighlightColor nvarchar(max) NOT NULL,
CONSTRAINT PK_Colors PRIMARY KEY (Id));

SET IDENTITY_INSERT dbo.Colors ON
INSERT dbo.Colors (Id, Name, MainColor, HighlightColor)
	VALUES (1, N'Red Flash', N'Red', N'Yellow'),
	(2, N'Cool Blue', N'Dark Blue', N'Light Blue'),
	(3, N'Midnight', N'Black', N'Black'),
	(4, N'Beacon', N'Yellow', N'Green')

SET IDENTITY_INSERT dbo.Colors OFF
Go
```

And the `Shoes`table contains details of the Products that are produced by the shoe company - like:

```sql
CREATE TABLE Shoes (
	Id bigint IDENTITY(1,1) NOT NULL,
	Name nvarchar(max) NOT NULL,
	ColorId bigint NOT NULL,
	Price decimal(18, 2) NOT NULL,
	CONSTRAINT PK_Shoes PRIMARY KEY (Id ),
CONSTRAINT FK_Shoes_Colors FOREIGN KEY(ColorId) REFERENCES dbo.Colors (Id))
```

Creates a table with .. The `Id`column holds the PKs, and there is a FK REL between the `ColorId`and the `Id`.

And he `SalesCampaigns`table has a one-to-one with the `Shoes`and contains details of the .. associated with each shoe product. Note that it has an index that requires unique values on the `ShoeId`column and enforces the one-to-one REL with the `Shoes`table.

```sql
CREATE TABLE SalesCampaigns(
	Id bigint IDENTITY(1,1) NOT NULL,
	Slogan nvarchar(max) NULL,
	MaxDiscount int NULL,
	LaunchDate date NULL,
	ShoeId bigint NOT NULL,
	CONSTRAINT PK_SalesCampaigns PRIMARY KEY (Id),
	CONSTRAINT FK_SalesCampaigns_Shoes FOREIGN KEY(ShoeId)
	REFERENCES dbo.Shoes (Id),
INDEX IX_SalesCampaigns_ShoeId UNIQUE (ShoeId))  -- for this, one-to-one REL to Shoes table
```

### Creating the *Categories* and *ShoeCategoryJunction* tables

These will allow a many-to-many relationship with the `Shoes`table.

```sql
CREATE TABLE ShoeCategoryJunction(
	Id bigint IDENTITY(1,1) NOT NULL,
	ShoeId bigint NOT NULL,
	CategoryId bigint NOT NULL,
	CONSTRAINT PK_ShoeCategoryJunction PRIMARY KEY (Id),
	CONSTRAINT FK_ShoeCategoryJunction_Categories FOREIGN KEY(CategoryId)
	REFERENCES dbo.Categories (Id),
	CONSTRAINT FK_ShoeCategoryJunction_Shoes FOREIGN KEY(ShoeId)
	REFERENCES dbo.Shoes (Id))
```

The `ShoeCategoryJunction`has `Id, ShoeId, CategoryId`– with `Id`used for pk and other columns just for FK with the `Shoes`and `Categories`tables. 

## Creating the Core MVC proj

The eaiest way to work with an existing dbs is to use EF core scaffolding feature, which inspects a dbs and creates thne context and model classes required to perform queries and other data operations.

### Performing the Scaffold process

```sh
Scaffold-DbContext "Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ZoomShoesDb;Integrated Security=True;Connect Timeout=30;Encrypt=False;Trust Server Certificate=False;Application Intent=ReadWrite;Multi Subnet Failover=False" Microsoft.EntityFrameworkCore.SqlServer -OutputDir Models/Scaffold -Context ScaffoldContext
```

### Updating the Controller and View

ASP.NET core identity provides the `SignInManger<T>`to manage logins – where the generic type argument `T`is jsut the class that represents users in the app.

- `PasswordSignInAsync(name, password, persist, lockout)`
- `SignOutAsync()`

And the result from `PasswordSignInAsync()`is a `SignInResult`obj, which defines a `Succeeded`that is `true`if successes. AuthC is an app is usually triggered when the user tries to acces an endpoint. so use an `ReturnUrl`which also in the view.

For Model’s Cookies :

`Cookie = Request.Cookies[".AspNetCore.Identity.Application"]`

Sign-out page – `await SignInManager.SignOutAsync()`– note the cookie will be deleted so that the browser will not include it in future request.

And the `ClaimsPrincipal`class is part of the .NET core and isn’t directly useful in most app – there are just two nested props are useful – 

- `ClaimsPrincipal.Identity.Name`-- returns the user name
- `ClaimsPrincipal.Identity.IsAuthenticated`– returns `true`if the user authenticated.

# Authorizing Access to Endpoints

Once an app has an authentication features – user identities can be used to restrict access to endpoints.

## Applying the Authorization Attribute

The `Authorize`is used to restrict access to an endpoint and can be applied to individual action or just page handler methods or to controllero or page model clases – in which case the policy applies to all the methods defined by the class. FORE, want to restrict access to the user and role administration tools created in .. And, when there are multiple RPs or controllers for which the same authZ policy is required - good ida to define a just common *base class* to whcih the `Authorize`can be applied – ensures that you won’t accidentally omit the attribute and allow unauthorized operation. Just:

```cs
[Authorize(Roles="Admins")]
public class AdminPageModel:PageModel
{
}
```

The `Authorize`can be applied without args – which just restrict access to any authenticated user. Then just enabling the authorization middleware:

```cs
app.UseAuthentication();
app.UseAuthorization();
```

## Creating the Access Deined Endpoint

The app must deal with two different types of authorization failure – if no user has been authenticated when a restricted endpoints is requested– then returns a *challenge* response, which will trigger a redirection to the login page so the user can present their credentials.

If an authCed user requests a restricted – an access deined response is generated.

### Creating the Seed Data

Could created an admin user and role before applying the `Authorize`-- going to just create seed data for Core Identity to ensure there will always be at least one account that can be used to access the user and role management tools. like:

```cs
public class IdentitySeedData
{
    public static void CreateAdminAccount(IServiceProvider serviceProvider,
        IConfiguration configuration)
    {
        CreateAdminAccountAsync(serviceProvider, configuration).Wait();
    }

    public async static Task CreateAdminAccountAsync(IServiceProvider serviceProvider,
        IConfiguration configuration)
    {
        serviceProvider = serviceProvider.CreateScope().ServiceProvider;
        UserManager<IdentityUser> userManager =
            serviceProvider.GetRequiredService<UserManager<IdentityUser>>();
        RoleManager<IdentityRole> roleManager =
            serviceProvider.GetRequiredService<RoleManager<IdentityRole>>();

        string username = configuration["Data:AdminiUser:Name"] ?? "admin";
        string email =
            configuration["Data:AdminUser:Email"] ?? "admin@example.com";
        string password =
            configuration["Data:AdminUser:Password"] ?? "secret";
        string role = configuration["Data:AdminUser:Role"] ?? "Admins";

        if (await userManager.FindByNameAsync(username) == null)
        {
            if (await roleManager.FindByNameAsync(role) == null)
            {
                await roleManager.CreateAsync(new IdentityRole(role));
            }

            IdentityUser user = new IdentityUser
            {
                UserName = username,
                Email = email,
            };

            IdentityResult result = await userManager.CreateAsync(user, password);
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(user, role);
            }
        }
    }
}
```

The `UserManager<T>`and `RoleManager<T>`services are scoped,which means need to just *create a new scope before requesting* the services since the seeding will be done when the application starts. The seeding code creates a user account that is assigned to a role – the values for the seed data are read from the app’s configuration wtih fallbackvalues. In the `Program.cs`file:

`IdentitySeedData.CreateAdminAccount(app.Services, app.Configuration);`

# Forms and Validation 1

This is the first of - covering forms and valiation in the Blazor. With the ability to create trails via a form, need to make some changes to the architecture of the app.

## Super-charging froms with components

With blazor, possible to work with HTM forms directly – it is not ideal – while collecting the data entered by the user and hanling the data entered by the user and handling the form submit events – there just **validation** – is the main reason for using the form conpnents provided by blazor over a std FORM.

- A model is passed to the `EditForm`-- represents the data in the form, the properties on this model will be bound to individual Input components.
- From the model – the `EditForm`constructs an `EditContext`which keeps track of the state of the form, and coordinates events such as triggering validation.
- When a value on the model is updated, the Validator component runs any validation rules attached to the model.
- And `Input`components are bound to properties on the model – when a value is updated, the `EditContext`is triggers any validation.
- `OnValidSubmit(), OnSubmit() and OnInvalidSubmit()`functions.

Inside the `EditForm`just add a valiator and various input components. Internally, constructs an `EditContext`– This is the brain of the form’s system. Keeps track of all the input components and the state of the model. Blazor ships with a validator called `DataAnnotationsValidator`allows the validataion of models using the Data Annotations.

First, need to create a model- a class that represents the trial data we *need to collect from the form*. Once created, bind the props of this class to the various input componetns allowing us to capture the data entered.

## Adding a .NET class lib to share code between Client and API

The class library will be used to share code between the Client and API objects. In the `Shared`proj, create a new folder called `Features`and inside that, add a new folder called `ManageTrails`– replicating the feature.. There is nothing special about this class right now – will come back and make some modifications when add in validation.

### Basic `EditForm`Configuration

Can add a new feature folder called `ManageTrails`in the `Client`project – mirroring what did in the `Shared`proj. By declaring namespaces in a `_Imports.razor`file, they are automatically added to any files.

```html
<EditForm Model="_trail" OnValidSubmit="SubmitForm">
    <div class="mx-5">
        <div class="row">
            <div class="offset-4 col-8 text-end">
                <button class="btn btn-outline-secondary" type="button"
                        @onclick="@(() => _trail = new TrailDto())">
                    Reset
                </button>
                <button class="btn btn-primary"
                        type="submit">
                    Submit
                </button>
            </div>
        </div>
    </div>
</EditForm>
```

1. The `EditForm`is used to define form – as minimum, a model and a submit action **MUST** be defined.
2. A new instance of the `TrailDto`will be created when the component is just initialized.

The model is used internally to understand what validation rules exist and the current state of the model. This is the basic setup - and - aneed to create a new component in the `ManageTrails`called `FormSection.razor`. Find forms are a prime location for repeated markup that can be just refactored into components. So:

```html
<div class="card card-brand mb-4 shadow">
    <div class="card-body">
        <div class="row">
            <div class="col-4">
                <h4>@Title</h4>
                <p class="text-secondary">@HelpText</p>
            </div>
            <div class="col-8">
                @ChildContent
            </div>
        </div>
    </div>
</div>
```

```cs
@code {
    [Parameter, EditorRequired]
    public string Title { get; set; } = default!;

    [Parameter, EditorRequired]
    public string HelpText { get; set; } = default!;

    [Parameter, EditorRequired]
    public RenderFragment ChildContent { get; set; } = default!;
}
```

By defining this simple component now, we’ve saved a lot of repeated markup on our form.

### Collecting data with `input`components

`InputText, InputTextArea, InputNumber, InputSelect, InputDate, InputCheckbox`
`InputRadio/InputRadioGroup, InputFile`

To just use any of these input components we need to bind them to a prop on the form model using `@bind`. For each `Input`component, can see the `@bind`directive being used   to associate the component with a property on the model – NOTE: Slightly different syntax – as when binding to a compopnent, must specify the parameter we’re binding to. All the input shipped with Blaozr just expose `Value`parameter, hence: **`@bind-Value`**used.

```html
<FormSection Title="Basic Details"
                 HelpText="This info is used to 
                    identify the trail and can be searched to help hikers find it.">
        <div class="row">
            <div class="col-6">
                <div class="mb-3">
                    <label for="trailName"
                           class="fw-bold text-secondary">
                        Name
                    </label>
                    <InputText @bind-Value="_trail.Name"
                               class="form-control" id="trailName"/>
                </div>
            </div>
        </div>
    <!--... -->
</FormSection>
```

Use just a slightly different format when binding on a component – `@bind-Value=...`**NOT a original HTML element**. When binding to a component, must specify the prop on the component we wish to bind to. And we are going to look at the bind directive in detail.

# Rebuilding the Form using the API

The simplest way to get started is with a single form element so can understand the basic building blocks of the API. The reactive form features require a new module, `ReactiveFormsModule`, as shown like. In addition to teh template, using the:

```html
<input ... [formControl]="nameFiled" />
```

`nameFiled : FormControl = new FormControl("Initial Value")`

```ts
handleStateChange(newState: StateUpdaet) {
    //...
    this.nameField.setValue(this.product.name);
}
```

## Responding to Form Control Changes

The `valueChanges`prop returns an *observable* that emits new values from the form control. like:

```ts
ngOnInit() {
    this.nameField.valueChagnes.subscribe(newVlaue=> {
        this.messageService.reportMessage(new Message(newValue || "(empty)"));
    });
}
```

In the `ngOnINit`, the component subscribes the `Observable<any>`returned by the `valueChanges`prop. By default, the observable will emit a new event in response to the HTML element’s `chagne`event.

Can change this using the `FormControl`'s ctor argumetns: like:

```ts
nameField: FormCtrol = new FormControl("Initial value", {
    updateOn: "blur",
});
```

`updateOn`is used to configure when the `valueChanges`observable will emit a new value.

## Managing Control State

`untouched, touched`

`markAsTouched(), markAsUntouched()`

`pristine`-- returns `true`if the element conents have not been edited

`dirty`– return `true`if have been edited.

`markAsPrinsine(), markAsDirty()`

```ts
ngOnInit() {
    this.nameField.valueChanges.subscribe(newValue => {
        this.messageService.reportMessage(new Message(newValue || "(Empty)"));
        if (typeof newValue === "string" && newValue.length % 2 == 0) {
            this.nameField.markAsPristine();
        }
    });
}
```

Changed the `updateOn`prop so that a new value is emitted via the observable after every change. note that the readon of the border color changes is that Ng marks from elements as valid. just for the odd number of characters:

```html
<input name="name" class="form-control ng-valid ng-touched ng-dirty" >
```

This just matched by the selector defined in the `form.component.css`file.

## Managing Control Validation

Applied through the `FormControl`ctor, using the `validators`and `asyncValidators`props of the `AbstractControlOptions`interface.

```ts
nameField: FormControl = new FormControl("Initial Value", {
    validators: [
        Validators.required,
        Validators.minLength(3),
        Validators.pattern("^[A-z ]+$"),
    ],
    updateOn: "change",
});
```

The built-in `validators`are defined as a static props of the `Validators`class.

In addition to the ctor, the validators applied to a form control can be managed through the `FormControl`props and methods.

`validator, hasValidator(v), setValidators(vals), addValidators(v), removeValidator(v)`

```ts
ngOnInit() {
    this.nameField.statusChanges.subscribe(newStatus => {
        if (newStatus === "INVALID" && this.nameField.errors != null) {
            let errs = Object.keys(this.nameField.errors).join(", ");
            this.messageService.reportMessage(new Message(`Invalid: ${errs}`));
        } else {
            this.messageService.reportMessage(new Message(newStatus));
        }
    })
}
```

Just note in response to status changes, a message is sent the details the staus – if `INVALID`. For this, the message isn’t especially useful to the user – but the `formControl`directive uses the `exportAs`prop to provide an identifier named `ngForm`for use in template variables. This can be used to generate more helpful validation messages for a control fore – 

```ts
@Pipe({
    name: "validationFormat"
})
export class ValidationHelper {
    transform(source: any, name: any): string[] {
        if (source instanceof FormControl) {
            return this.formatMessage((source as FormControl).errors, name);
        }
        return this.formatMessage(source as ValidationErrors, name);
    }
    //...
}
```

```html
<input class="form-control" name="name" [formControl]="nameField"
    #name="ngForm">
<ul class="text-danger list-unstyled mt-1" *ngIf="name.dirty && name.invalid">
    <li *ngFor="let err of name.errors | validationFormat:'name'">
        {{err}}
    </li>
</ul>
```

### Adding Additional Controls

The advantage of using the forms API is that you can just customize the way that your forms work. Can:

```ts
this.nameField.statusChanges.subscribe(newStatus=> {
    if(newStatus==="INVALID"){
        this.categoryField.disable();
    }else{
        this.categoryField.enable();
    }
})
```

Working with Multiple Form Controls

## Handling Errors

Errors are handled in the `subscribe()`call– It’s possible to handle all three by passing in each funcs as a separate arg to `subscribe`jsut like:

```ts
.subscribe({
    next: val=>{},
    err: err=> {},
    done: ()=>...
})
```

### Loading with Progress Bar

```ts
let requests = [];
for (let x = 0; x < 10; x++) {
    for (let y = 0; y < 10; y++) {
        let endpoint = `http://localhost:8000/coverpart-${x}-${y}.png`
        let request$ = ajax({
            url: endpoint,
            responseType: 'blob'
        }).pipe(
            map(res => ({
                blob: res.response,
                x, y,
            }))
        );
        requests.push(request$);
    }
}

merge(...requests).pipe(delay(500))
    .subscribe({
        next: val => drawToPage(val as Iconfig),
        error: err => alert(err),
    }
    );
```

## Multiplexing Observables

A hot observable contains a single stream that every subscriber listens in on.

Cold observables’ problem – like:

```ts
let myobj$ = new Observable(o => {
    console.log('Creation Function');
    setInterval(() => o.next('hello'), 1000);
});

myobj$.subscribe(x => console.log('streamA', x));

setTimeout(() => {
    myobj$.subscribe(x => console.log('streamB', x));
}, 500);
```

Can see the *creation function* just logged to the console twice. Cuz observables are “cold” - means each new subscription creates an entire new observable and stream of data – each subscribe makes an *indpendent request* to the backend for the same data.

Rxjs just provides a multitude of options - the simplest one is the `share`, which is called on a single, cold and converts the stream into  a hot stream. – note that this conversion doesn’t happen immediately, `share`waits until there is at least one subscriber and then subscribes to the original. like:

```ts
let myobj$ = new Observable(o => {
    //...
}).pipe(share());
```

So is a good tool to sue when new listeners don’t care about previous data.

### Using `Subject`class

At its core, a `Subject`much like a regular observable – but each subscription is hooked into the same source. And also are observers. like:

```ts
let mySubject= new Subject();
mySubject.subscribe(val=> console.log(...));
mySubject.next(42);
```

Cuz it is observer – can be passed directly into a subscribe call, and all the events from the original will sent through the subject to its subscribers.

```ts
let mySub = new Subject();
mySub.subscribe(console.log);
let myOb = interval(1000);
myOb.subscribe(mySub);
```

So, any `Subject`can *subscribe* to a regular observable and mutlicast the values flowing through it.

### Binding `input`to values

Just create  new component to represent the individual submitted articles.

### Rendering multiple Rows

```html
<div class="d-grid gap-3">
    <app-article *ngFor="let article of articles"
                 [article]="article" />
</div>
```

Angular allows us to do this by using the `Input`decorator on a prop of a `Component`.

### Adding new Articles 

Now need to just change `addArticle`to actually add new articles when the button is pressed.

```ts
addArticle(title: HTMLInputElement, link: HTMLInputElement): boolean {
    this.articles.push(new Article(title.value, link.value, 0));
    title.value = '';
    link.value = '';
    return false;
}
```

## How Angular works

An Angular application is nothing more than a tree of `Components`. At the root – the top level component is the application itself. And that’s waht the browser will render when *botting* the app. One of the great things about the Components is that they are just **composable**.  This means that we can build up larger components from smaller ones.

Cuz Components are structured in parent/child tree, when each component renders, it recursively renders its children components.

### How to use – 

going to explain the fundamental concepts required when building Angular apps by walking through the app that built. Explain – 

- How to break your app into components.
- How to make reusable componnets using `inputs`
- How to handle user interactions

### Product Model

One of the key things to realize about Ng is that it doesn’t prescribe a particular model library. Ng is just flexible enough to support many different kinds of models.

Components – Components are the fundmental building block of Ng apps.

The `@Component`is where you just configure your component. One of the primary roles of the decorator is to configure how the outside world will interact with your component. With the `selector`key, indicate how your component will be just recognized when used in a template. Thje idea is just similar to CSS or XPath.

`template`is the view – by using the `template`option on `@Component`, declare the HTML template… 