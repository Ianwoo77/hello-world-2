# Key Files, Dirs, and Commands

- `/etc/nginx`– is the default configuration root for the NGINX server.
- `/etc/nginx/nginx.conf`– is the deafult configuration entry point used by the service. Setting global settings for things like worker processes…
- `/etc/nginx/conf.d/` – contains the default HTTP server configuration file. Files in this ending in `.conf`are included in the top-level `http`block from `nginx.conf `file.
- `/var/log/nginx` – for log location.

`nginx -t` – tests the nginx configuration, `-T`– tests the conf and prints the validated configuration.

## Serving static Content

```nginx
server {
    listen 80 default_server;
    server_name www.example.com;
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
}
```

Serves static files over HTTP on port 80 from the directory `/usr/share/nginx/html/`.

1. first line – new `server`block – deinfes a new context for NGINX to listen for.
2. Then, instructs to listen on 80. and `default_server`parameter instructs to use this as the default context for 80.
3. If the conf had not defined this context as the `default_server`- would direct requests to this server only if the http host header matched the value provided to the `server_name`directive.
4. The examples used the `/`to match all requests.
5. `index`provides with a default file.

`nginx -s reload`

## High-performance Load Balancing

Fore – need to distribute load between two or more HTTP servers. Reverse proxying is useful if have multiple web services listning on various ports and we need a single public endpoint to reroute requests internally. Traditionally, web servers like Apache create a single thread for every request – Nginx performs with async and event-driven architecture.

Nginx divided its job into the **worker process** and **worker connections**. Worker connections are used to manage the request made and the response obtained by users on the web server.

```sh
sudo ufw allow 'Nginx Full' # HTTP, HTTPS
```

Before start using Nginx to load balance HTTP traffic to a group of servers– need to define the group with the upstream directive. Servers in the group are configured using the server directive. fore: Defining a group named backend and consists of 3 server configuration that may resolve in more then 3 actual servers.

```nginx
http{
    upstream backend {
        server backend1.example.com weight=5;
        server backend2.exmaple.com;
        server 192.0.0.1 backup;
    }
}
```

To pass the requests to a server group, the group name is specified in the `prox_pass`directive. Fore a virtual server running on passes all requests to the upstream backend group:

```sh
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

# Tidying Up

- writing testable examples
- Producing executable documenation
- Measuring test coverage and bechmarking
- Refactoring the URL parser
- Differences beteen external and internel tests

Since, will be *externally* testing the url package, need to define a new package called `url_test`just in the new file:

`package url_test`

The `_test`has a special meaning in Go – can use it when want to write an *external test*. Since the `url_test`jsut is another package, can only see the exported identifiers of the `url`package. Unlike a test function, a testable example func **doesn’t have any input parameters** – and it doesn’t begin with a `Test`prefix. And the testing package automatically runs testble examples and checks their results but doesn’t let them communicate with it to report success or failure. Just like:

```go
package url_test

import (
// ...
)

func ExmapleURL() {
	u, err := url.Parse("http://foo.com/go")
	if err != nil {
		log.Fatal(err)
	}
	u.Scheme="https"
	fmt.Println(u)
    // Output:
    // https://foo.com/go
}

```

Cuz the sample code is for demonstration purposes only on how to use the URL package. If it just compiles, it’s good to go – that way – the example is never out of date.

Can add a comment to the end of the function and tell the testing package what you expect to see from the example. 

NOTE: the functions must have a prefex *Example*

```go
func ExamplePerm() {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	for _, v := range r.Perm(3) {
		fmt.Println(v)
	}
	// Unordered output:
	// 2
	// 0
	// 1
}

```

### Unordered Output

Say want to write an example function for a function that just returns random number – So every time the testing package ran the example - its output would change and fail.. For these cases, the testing package allows you to add another comment instead of `// output:` like :`// Unordered output:`

## Self-printing URLs

In unit test, it is better to test code in isolation as much as you can. 

```go
func TestURLString(t *testing.T) {
	u := &URL {
		Scheme: "https",
		Host: "foo.com",
		Path: "go",
	}
	got, want := u.String(), "https://foo.com/go"
	if got!=want {
		t.Errorf("%#v.String()\ngot %q\nwant %q", u, got, want)
	}
}
```

For this, the test expects the URL value to produce.. when calls its `String()`method.

## Test Coverage

Some of the members noticed that you had a test for the `Parse`func but didn’t verify all kinds of URLs.

### Measuring test coverage

```sh
go test -coverprofile cover.out
go tool cover -html=cover.out
```

So the test coverage should not be your goal but is a helpful guidance – 80% coverage is usually more than enough.

Pat matches patterns **in the order** that they are registered. In the app, a HTTP `GET /snippet/create`is actually a valid match fro two routs — it’s an exact match for `/snippet/create`and a wildcard match for `/snippet/:id`, so to ensure that the exact match takes preference, need to register the exact match routes *before* any wildcard routes.

And, URL pattens which end in a trailing slash like `/static/`work in the same way as with Go’s inbuilt serveMux. Any request which matches the *start* of the pattern will be dispatched to the corresponding handler.

The pattern `/`is special cse – only match where the URL path is exactly `/`.

With those in – also a few changes in handlers.go file:

```go
// Add a new handler
func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Create a new..."))
}
```

And for the `home`…Checking if the request method is a POST is not required any more. Finally, need to update the home.page.html so that the links in the HTML also use the new semantics of `/snippet/:id`.

```html
<td><a href="/snippet/{{.ID}}">{{.Title}}</a></td>
```

# Processing Forms

In this of the book going to focus on allowing users of web app to create a new snippets via a HTML form. And the high-level workflow for procesing this form will follow a standard **POST-REDIRECT-GET** pattern:

1. The user is shown the blank form when make GET
2. The user completes the form and submitted to the server via a `POST`
3. The form data will be validated by `createSnippet`handler, and if passes, the data for the new snippet will be added to the dbs and then redirect the users to `/snippet/:id`

## Setting up a Form

```html
{{template "base" .}}

{{define "title"}}Create a new Snippet {{end}}

{{define "main"}}
	<form action="/snippet/create" method="post">
		<div>
			<label>Title:</label>
			<input type="text" name="title">
		</div>

		<div>
			<label>Content:</label>
			<textarea name="content"></textarea>
		</div>

		<div>
			<label>Delete in:</label>
			<input type="radio" name="expires" value="365" checked> One Year
			<input type="radio" name="expires" value="7"> One week
			<input type="radio" name="expires" value="1"> One Day
		</div>
		<div>
			<input type="submit" value="Publish snippet">
		</div>
	</form>
{{end}}
```

For the `main`, contains a std web form which sends 3 form values – `title, content, expires`– the only thing point out is the form’s `action`and method attribute. And add in the `base.layout.tmpl`for: And finally, need to update the `createSnippetForm`so can render new page like:

## Parsing Form Data

At a high-level can just break this down into two distinct steps:

1. need to use the `r.ParseForm()`method to parse the request body. This checks that the request body is just *well-formed*, and then stores the form data in the request’s `r.PostForm`map. If there are any errors encountered wehn parsing the body then it will return an error. The `r.ParseForm()`method is also idemponent – Can be safely called multiple times on the same request without any side-effects.
2. Can then get to the form data contained in `r.PostForm`by using the `r.PosteForm.Get()`method – fore, can retrieve the value of the `title`with `r.PostForm.Get("title")`, and if  there is no matching field name in the form this will return the empty string “”.

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	// First, call r.ParseForm() which adds any data in POST bodies
	// if there is any error, use app.ClientError
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest) // 400
		return
	}

	// use the r.PostForm.Get() to retrieve the relevant data filed
	title := r.PostForm.Get("title")
	content := r.PostForm.Get("content")
	expires := r.PostForm.Get("expires")

	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet/%d", id), http.StatusSeeOther) // 303
}
```

## Additional Info

`r.Form`Map – Accessed the form value via the `r.PostForm`map – an alternative approach is to use the `r.Form`map. The `r.PostForm`map is populated only for `POST, PATH, PUT`requests. In contrast, the `r.Form`map is populated for all requests – and contains the form data from any request body **and** any query string parameters. So, need to note if submitted to `/snippet/create?foo=bar`, could also gat the value.

Using the `r.Form`map can be useful if your application sends data in a HTML form and in the URL. Or just for agnostic.

### The `FormValue`and `PostFormValue`methods – 

And the `net/http`package also provides the methods – `r.FormValue()`and `r.PostFormValue()`-- essentailly shortcut functions that call `r.ParseForm()`for you then fetch field value from `r.Form`or `r.PostForm`. – need to note avoiding these cuz *sliently ingore* any errors returned by the `r.ParseForm()`.

### Multiple-Value Fileds

The `r.PostForm.Get()`only returns the first value of a specific form filed. For this case, need to work with the `r.PostForm`map directly. just like:

```go
for i, item := range r.PostForm["item"] {} // cuz  type is just map[string][]string
```

### Form Size

Unless you are sending *multiple data* (`enctype="multipart/form-data"`) then POST, PUT, and PATCH are limited to **10MB**. And in this case, `r.ParseForm()`will return an error. If want to change, using the `http.MaxBytesReader()`

Working with a scaffolding data model is just the same as using one that has been created with a migration.

# Responding to Dbs Changes

May hav to respond to changes that are made for the benefit of their app - FORE, simulate a change to the dbs and demonstrate how to update the scaffolded data model to accomodate the change in the application.

## modifying the dbs

```sql
create table Fittings
(
    Id   bigint IDENTITY (1,1) not null,
    Name nvarchar(max)         not NULL,
    constraint PK_Fittings PRIMARY KEY (Id)
);
Go

Set IDENTITY_INSERT Fittings on
INSERT Fittings(Id, Name)
values (1, N'Narrow'),
       (2, N'Standard'),
       (3, N'Wide'),
       (4, N'Big Foot')
Set identity_insert Fittings off
GO

Alter table Shoes
    ADD FittingId bigint

Alter Table Shoes
    ADD constraint FK_Shoes_Fittings FOREIGN KEY (FittingId) REFERENCES Fittings (Id)
GO

Update Shoes
set Shoes.FittingId=2
go
```

These statements add a `Fittings`table and add a FK prop on the `Shoes`table that references the PK. 

### Updating the Data Model

Updating the data model to reflect the change in the dbs means repeating the scaffolding process. So need to run the command – :

```sh
caffold-DbContext "Connection-string" -OutputDir "Models/Scaffold" -Context ScaffoldContext -Force
Provider: Microsoft.EntityFrameworkCore.SqlServer
```

The `-Force`tells EF core to replace the existing data model classes with new ones.

### Updating the Context Class

The scaffolding process will replace the context class, overwriting the changes required to support an ASP.NET app.

## Adding Persistent Data Model Features

Many data models are just simply classes that act as collections of data and navigation props to represent the data in the database. And fore, create the `Models/Logic`and added to it a class file:

```cs
namespace ExistingDb.Models.Scaffold
{
    public partial class Shoe
    {
        public decimal PriceIncTax => this.Price * 1.2m;
    }
}
// must in the same namespace.
```

# Manually Modeling a Dbs

The scaffolding process is convenient, but doesn’t provide much in the way of find-grained control, and the result can be awkward to use.

## Creating a Manual Data Model

Must understand its schema and know which parts of the dbs you need for the MVC.

### Creating the Context and Entity Classes

The starting point for a manually created data model is to create a context class, Created a Manual folder to do this:

```cs
public class ManualContext: DbContext
{
    public ManualContext(DbContextOptions<ManualContext> options) : base(options) { }
    public DbSet<Shoe> Shoes { get; set; }
}
```

To define the `Shoe`class used by this class, need to define new `Shoe`class like..

### Creating the Controller and View

- The name of the prop in the context class corresponds to the name of the dbs so that `Shoes`prop in the context class just corresonds to the `Shoes`table in the dbs
- The name of the props in the entity class correspond to the name of the columns in the dbs
- The PK will be just represented by a prop called `Id`or `<Type>Id`so that the PK for the `Shoe`class will be a property called `Id`or `ShoeId`.

## Overriding the Data Model Conventions

EF core conventions are convenient when the design of the dbs aligns with what you need in the app. RARE – especially if you are just trying to integrate an existing dbs into a project – EF core provides two different ways in which U can override the conventions so that you can create a data model that suits the CORE MVC part of the project while still providing access to the data in the dbs.

### Attributes to override Data Model Conventions

- `Table`– specifies the dbs table and overrides the name of the prop in the context class.
- `Column` – the column that provides values for the prop it is applied to.
- `Key`-- used to identity the prop that will be assigned the PK value. SO:

```cs
[Table("Colors")]
public class Style
{
    [Key]
    [Column("Id")]
    public long UniqueIdent { get; set; }

    [Column("Name")]
    public string? StyleName { get; set; }

    public string? MainColor { get; set; }
    public string? HighlightColor { get; set; }
}
```

Used the `key`attribute to specify that the `UniqueIdent`prop should be used for PK values, along with the `Column`attribute to ensure that the `Id`will be used as the source for those values. 

Only have to apply attributes for the changes you require, which allows to rely on the conventions for the `MainColor`and properties – . Then just add to the `DbContext`class like:

`public DbSet<Style> ShoeStyles => Set<Style>();`

## Using the Fluent API to override Model Conventions

The Fluent API is used to override data model conventions by – describing parts of the data model programmatically. Attributes are suitable for making simple changes – but eventually you will have to deal with a situation for which there is no suitable attribute – which requires an advanced feature that only the Fluent API supports – Just add a `ShoeWidth`class like:

```cs
public class ShowWidth
{
    public long UniqueIdent { get; set; }

    public string? WidthName { get; set; }
}
```

Going to use the `ShoeWidth`class to represent the data in the `Fittings`table.

# Applying the Authorization Attribute

The `Authorize`attribute is used to just restrict access to an endpoint and can be applied to individual action or page handler methods or to controller or page model classes, in which case the policy applies to all the methods defined by the class – want to just restrict access to the user and role. 

NOTE: When there are multiple RPs or controllers for which the same authorization policy is required, it is just good idea to define a common base class to which the `Authorize`attribute can be applied – cuz it ensures that you won’t accidentally omit the attribute. like:

```cs
[Authorize(Roles="Admins")]
public class AdminPageModel: PageModel{...}
```

### Creating the Access Denied Endpoint

Create an administration user and role before applying the `Authorize`attribute – but that complicates deploying the app, when making code changes should be avoided. The `UserManager<T>`and `RoleManager<T>`services are scoped, which means I need to create a new scope before requesting the services sicne the seeding will be done when the app starts. In the `Program.cs`file:

`IdentitySeedData.CreateAdminAccount(app.Services, app.Configuration);`

## Authorizng Access to Blazor Applications

The simplest way to protect Blazor is to restrict access to the action method or RP that acts as the entry point. Added the `Authorize`to the page model class for the `_Host`page – which is the entry point for the Blazor app.

```cs
[Authorize]
public class _Host : PageModel
{...
```

### Performing Authorization in Components

```html
<Router AppAssembly="typeof(Program).Assembly">
	<Found>
		<AuthorizeRouteView RouteData="@context" DefaultLayout="typeof(NavLayout)">
			<NotAuthorized Context="authContext">
				<h4 class="bg-danger text-white text-center p-2">Not Authoized</h4>
				<div class="text-center">
					U may need to log in as a different user.
				</div>
			</NotAuthorized>
		</AuthorizeRouteView>
	</Found>
<!-- .. ->
```

Then need to restrict access to the `DepartmentList`to users.

```cs
@using Microsoft.AspNetCore.Authorization
@attribute [Authorize(Roles="Admins")]
```

```cs
@page "/"
@{ Layout = null;}
@attribute [Microsoft.AspNetCore.Authorization.Authorize]
// just in the _host.cshtml file
```

### Displaying Content to the Authorized Users

And the `AuthorizeView`component is used to restrict access to sections of content rendered by a component. Fore, in the `DepartmentList.razor`file – like:

```html
<td>
    <AuthorizeView Roles="Admins">
        <Authorized>
            @(string.Join(", ", d.People!.Select(p =>
                p.Location!.City)))
        </Authorized>
        <NotAuthorized>
            (Not Authroized!)
        </NotAuthorized>
    </AuthorizeView>
</td>
```

## Authenticating and Authorizing Web Services

The authorization process in previous section relies on being able to redirect client to URL that allows the user to enter heir credentials – A different approach is just required when adding authentication and authorization to a web service – cuz there is no way to present the user the HTML to collect credentials.

The first step in adding support for web services authentication is to disalbe the redirection so that the client will receive HTTP error responses when attempting to request an endpoint that requires  authentication. Need to add a new class named `CookieAuthenticationExtensions.cs`to the folder and define the extension method like:

```cs
public static class CookieAuthenticationExtensions
{
    public static void DisableRedirectForPath(
        this CookieAuthenticationEvents events,
        Expression<Func<CookieAuthenticationEvents,
            Func<RedirectContext<CookieAuthenticationOptions>, Task>>> expr,
        string path, int statusCode)
    {
        string propertyName = ((MemberExpression)expr.Body).Member.Name;
        var oldHandler = expr.Compile().Invoke(events);

        Func<RedirectContext<CookieAuthenticationOptions>, Task> newHander =
            context =>
            {
                if (context.Request.Path.StartsWithSegments(path))
                {
                    context.Response.StatusCode = statusCode;
                }
                else
                {
                    oldHandler(context);
                }
                return Task.CompletedTask;
            };

        typeof(CookieAuthenticationEvents).GetProperty(propertyName)?.SetValue(events, newHander);
    }
}
```

Then in the Program.cs file, add:

```cs
builder.Services.AddAuthentication(opts =>
{
    opts.DefaultScheme =
    CookieAuthenticationDefaults.AuthenticationScheme;
    opts.DefaultChallengeScheme = CookieAuthenticationDefaults.AuthenticationScheme;
}).AddCookie(opts =>
{
    opts.Events.DisableRedirectForPath(e => e.OnRedirectToLogin,
        "/api", StatusCodes.Status401Unauthorized);
    opts.Events.DisableRedirectForPath(e => e.OnRedirectToAccessDenied,
        "/api", StatusCodes.Status403Forbidden);
});
```

## Using Bear Token Authentication

Not all web services will be able to rely on cookie cuz not all clients can use then. An alternative is to use a bear token – which is just a string that clients are given and is included in the requests they send to the web service. Clients don’t understand the meaning of the token – just *opaque*, and just use whatever token the server provides.

Demonstrate authentiation using the **JSON Web Token** (JWT) – which provides the client with an *encrypted token that contains the authenticated username*.

By using the `FormSection`component, have already saved oursevles a load of markup. Just note that the input components are bound to properties on the model using the `@bind`directive – used previously – Use a slightly different format when binding to input components used the `@bind-Value`– This is just cuz are now performing two-way binding on a component **rather than** an HTML element.

Just looking at the form components just added, there is a lot of repetition again – the markup for the layout of each row is just repeated with only a single difference. just the `col-*`classes.

```cs
<div class="row">
    <div class="@Width">
        <div class="mb-3">
            @ChildContent
        </div>
    </div>
</div>

@code {

    [Parameter, EditorRequired]
    public RenderFragment ChildContent { get; set; } = default!;

    [Parameter]
    public string Width { get; set; } = "col";

}
```

Just allows us to remove the repeated markup from page.  just like:

```html
<FormFieldSet Width="col-6">
    <label for="trailName"
           class="fw-bold text-secondary">
        Name
    </label>
    <InputText @bind-Value="_trail.Name"
               class="form-control" id="trailName"/>
</FormFieldSet>
```

The following is another section, by using the components created – able to create this new section quickly and easily with really clean markup.

### Creating Inputs on demand

At some point, will need to allow the user to create inputs on demand. In the case, this is route instructions – is just a guide, a waypoint that help find… Depending on the length of the trail, there could be any number of route instructions – so, there is no way for us to know up front how many inputs to give the user. So, need to build the form in a way that allows the user to dynamically add route instructions as they are fit.

Will simple `foreach`loop over the collection of route instructions we defined on the form model.

```cs
public List<RouteInstruction> Route {get; set} = new List<...>();
```

```html
@{ int i = 0; }
@foreach (var routeInstruction in _trail.Route)
{
    i++;
    routeInstruction.Stage = i;

    <div class="row">
        <div class="col-2">
            <div class="mb-3">
                <label class="fw-bold text-secondary">
                    Stage
                </label>
                <p>@routeInstruction.Stage</p>
            </div>
        </div>

        <div class="col">
            <div class="mb-3">
                <label for="routeInstructionDesc"
                       class="fw-bold text-secondary">
                    Description
                </label>
                <InputText @bind-Value="routeInstruction.Description"
                           class="form-control" id="routeInstructionDesc"/>
            </div>
        </div>

        <div class="col-2 mt-4">
            <button @onclick="@(() => _trail.Route.Remove(routeInstruction))"
                    class="btn btn-warning" type="button">
                Remove
            </button>
        </div>
    </div>
}
```

## Validating the model

Validation is the most important part of building forms – without validation, the system can end up containing all kinds of rubbish data – out of the box, Blazor includes a few components to help us to do this. And the `DataAnnotationsValidator`component allows Blazor forms to work with the `DataAnnotations`validation system, which is the default for Core applications – this system works by decorating props on a model with attributes that define the validation rules. And the `ValidationSummary`displays all messages for a model – `ValidationMesage`just dispalys a validation message for a specific property on the model.

Generally prefer the fluent syntax for defining validation rules. Also find creating more complex validation logic is much simpler with **Fluent validation** than with Data Annotations.

### Configuring valiation rules with Fluent Validation

Going to set up API and Shared projects to use Fluent Validation – start by setting our API– Need to install a NuGet package in the API project, note that.

```sh
Install-Package FluentValidation.AspNetCore
```

Update call to `  builder.Services.AddControllers`to the like:

```cs
builder.Services.AddControllers().AddFluentValidation(fv =>
fv.RegisterValidatorsFromAssembly(Assembly.Load("BlazingTrails.Shared")));
```

For this, is obsolete. so:

```cs
using BlazingTrails.Shared.Features.ManageTrails;
using FluentValidation;
using FluentValidation.AspNetCore;
//...
builder.Services.AddControllers();

builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddFluentValidationClientsideAdapters();
builder.Services.AddValidatorsFromAssemblyContaining<TrailValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<RouteInstructionValidator>();
```

This will add the necessary services for Fluent Validation to run – To save us manually registering every valiator for our appliation – use these three – lets us specify an assembly…

```cs
public class TrailValidator: AbstractValidator<TrailDto>
{
    public TrailValidator()
    {
        RuleFor(x => x.Name).NotEmpty()
            .WithMessage("Please enter a name");
        RuleFor(x => x.Description).NotEmpty()
            .WithMessage("Please enter a description");
        RuleFor(x => x.Location).NotEmpty()
            .WithMessage("Please enter a location");
        RuleFor(x => x.Length).GreaterThan(0)
            .WithMessage("Please enter a length");
        RuleFor(x => x.Route).NotEmpty()
            .WithMessage("Please add a route instruction");
    }
}
```

Prefer to keep them together, as it amkes maintenance easiler. Defining a validator class means just inheriting from the `AbstractValidator<T>`base class – the type parameter `T`is the class to be validated. For `String`, it will check that null, empty or whitespace.

The rules just defined will make sure that the `TrailDto`is valid, but also need to do the same for the `RuleInstruction`nested class – like:

```cs
public class RouteInstructionValidator: AbstractValidator<TrailDto.RouteInstruction>
{
    public RouteInstructionValidator()
    {
        RuleFor(x => x.Stage).NotEmpty()
            .WithMessage("Please enter a stage");
        RuleFor(x => x.Description).NotEmpty()
            .WithMessage("Please enter a description");
    }
}
```

With the Validators in palce, have one last piece of configuration to do – need to wire up the `RouteInstructionValiator`in the `TrailValidator`just at the end of the previous add:

`RuleForEach(x => x.Route).SetValidator(new RouteInstructionValidator());`

Tells that for each entry in the `Route`collection, it should use the rules defined in the `RouteInstructionValidator`to validate the *model*.

### Configuring Blazor to use Fluent Validation

Just install the author’s source projects. Contains one component called `FluentValiationValidator`, which included in an `EditForm`component, will allow the form model to be validated according any Fluent Validation rules.

```sh
install-package Blazored.FluentValidation
```

# Working with Multiple Form Controls

Manipulating individual `FormControl`objects can be just powerful – can also cumbersome in more complex forms, where there can be many objects to create and manage. The reactive forms API includes the `FormGroup`class, which represents a group of form controls, note that which can be manipulated individually or as a combined group.

```ts
productForm: FormGroup = new FormGroup({
    name: this.nameField, category: this.categoryField,
});
```

```ts
ngOnInit() {
    this.productForm.statusChanges.subscribe(newStatus => {
        if (newStatus === "INVALID") {
            let invalidControls: string[] = [];
            for (let controlName in this.productForm.controls) {
                if (this.productForm.controls[controlName].invalid) {
                    invalidControls.push(controlName);
                }
            }
            this.messageService.reportMessage(
                new Message(`INVALID: ${invalidControls.join(", ")}`))
        } else
            this.messageService.reportMessage(new Message(newStatus));
    })
}
```

For this, is the simplest use of `FormGroup`– where a prop is used to group existing `FormControl`so can be processed *collectively*. The individual `FormControl`objects are passed to the `FormGroup`ctor, in a map that assigns each a key.

`addControl(name, ctrl), setControl(name, ctrl)`, `SetControl`jsut adds a control replacing any existing with this name. `removeControl(name)`, `controls`– returns a map containing the controls in the group. `get(name)`-- returns the control with specified name.

`FormGroup`for managing control values – 

`value`– containing the values of the form controls in the group.

`setValue(val)`– sets the content of the form controls using an object.

`pachValue(val)`– sets the contents of the form controls using an obj. unlike the `setValue()`not required for all controls.

`reset(val)`-- reset the form to its pristine and untouched state anduses the specified value to populate the control. Fore `this.productForm.reset(this.product)`-- looks for props in the object it receive whose name correspond to those used for regular `FormControl`objects with the `FormGroup`.

And, the `FormGroup`and .. share a common base class, which means that many of the properteis and methods provided by `FormControl`are also available on a `FormGroup`object. For its `subscribe()`method – if any of the individual controls are invalid, then the overall form status will be invalid.

### Using a Form Group with a Form Element

The `formGroup`directive associates a `FormGroup`obj with an element in the template, in the just same way the `formcontrol`is used with a `FormControl`object like:

```html
<form [formGroup]="productForm">
    <div class="mb-3">
        <label>Name</label>
        <input class="form-control" formControlName="name" />
    </div>

    <div class="mb-3">
        <label>category</label>
        <input class="form-control" formControlName="category" />
    </div>
    ...
```

The `formGroup`directive is used to specify the `FormGroup`object, and the individual form elements are associated with their `FormControl`objects using the `formControlName`attriute.

```ts
productForm = new FormGroup({
        name: new FormControl("", {
            validators: [
                Validators.required,
                Validators.minLength(3),
                Validators.pattern("%[A-z]+$")
            ],
            updateOn: "change"
        }),
        category: new FormControl()
    });
```

### Accessing the Form group from the template

In addition to simplifying the app code, the `formGroup`directive defines some useful props that allow to complete the transition to the reactive forms API.

### Inputs and Outputs

The [squareBrackets] pass intputs and the (parentheses) handle outputs. Data flow in to your component via input bindings, and event flow out of your componetn through the output bindings.

`$event`is a special variable represents the thing emitted on. (sent to the output)

### The ProductListComponent 

Now that have our top-level application component, write the `component` `Inputs`just sepcify the parameters we expect our component to receive – use the `@Input()`on a class property.

Adn when want to send data from your component to the outside world, use the output bindings. The way to do this by binding the `click`output of the button to a method. The parentheses attribute syntax looks like *(output)=“action”*. the output we are listening for the event …

### Emitting Custom Events

Want to create a component that emits a custom event.. Attach an `EventEmitter`to the output property, Emit an event from the `EventEmitter`. Just like:

```ts
let ee = new EventEmitter();
ee.subscribe(name=> console.log(name));
ee.emit('Nate');
```

If want to use this output in a parent component, could do like this:

```html
<single-component (putRingOnit)="ringWasPlaced($event)"></single-component>
```

```ts
ringWasPlaced(message: string) {
    console.log(`put your hands up ${message}`)
}
```

```html
<div class="container-fluid">
	<app-products-list [productList]="products"
	(onProductSelected)="productWasSelected($event)"></app-products-list>
</div>
```

### The `ProductRowComponent`

Just using the `product-image`and `product-department`and `price-display`.

### The `ProductImageComponent`

```html
<div class="product-department">
	<span *ngFor="let name of product?.department; let i= index">
		<a href="#">{{name}}</a>
		<span>{{i<(product?.department.length-1) ? '>': ''}}</span>
	</span>
</div>
```

## Using HTTP in Angular

Using the Rx-based `HttpClient`to communicate with a backend – routing through a single page app, and listening to routing events to collect analytics data. Build a Pinterest-like application – the user will search through images, collect like – and tag them for easier searching later.

Angular provides its own client for working with AJAX requests - -it provides two such clients – the original one `Http`is deprecated – had a solid core. For the `HttpClient`class, it just assumes that a response will be JSON, saving tedious time – for `map`.

```html
<div class="container" [ngSwitch]="myvar">
    <div *ngSwitchCase = "'a'">
        var is A
    </div>
    <!-- ... -->
    <div *ngSwitchDefault>
        Var is sth
    </div>
</div>
```

### NgStyle

With the `NgStyle`directive, can set a given DOM element CSS properties from Angualr expressions. The simplest way to use this directive is by doing `[style.<cssproperty>]="value"`

```html
<div [style.background-color]="'yellow'">
    yellow background
</div>
```

### NgClass

represented by a `ngClass`attribute in HTML template – allows to dynamically set and change the CSS clases for a givne DOM element – first way to use this is by passing an object literal.

```html
<div [ngClass]="{bordered:false}">This is never bordered</div>
<div [ngClass]="{bordered:true}">this is always bordered</div>
```

And a lot more useufl to use the `NgClass`directive to make class assignments dynamic like:

```html
<div [ngClass]="{bordered: isBordered}">
    ...
</div>
```

```ts
ngOnInit() {
    this.isBordered = true;
    this.classList = ['blue', 'round'];
}
```

Also can define a `classObj`object in the component like:

```ts
//...
classObject?: Object;
tghis.classObj={
	bordered: this.isBordered,
}
```

```html
<div [ngClass]="classObj">
    ...
</div>
```

Can also use a list of class names to specify which class names should be added to the element. like:

```html
<div class="base" [ngClass]="['blue', 'round']" >
    This always a blue and round
</div>
```

```html
<div [ngClass]="['bg-info', 'text-center']">This is bg-info and center text. </div>
```

### NgNonBindable

Can use `ngNonBindable`when want tell Angular **not** to compile or bind a particular section of our page. Say want to render the literal text `{{content}}`in template, normaly that text will be bound to the value of the content variable cuz using the `{{}}`template syntax.

```html
<span class="pre" ngNonBindable>
	this is what {{Content}} rendered
</span>
```

## Forms in Angular

- `FormControl`s encapsulates the inputs in our forms and give us objects to work with them
- `Validator`s give us the ability to validate inputs
- `Observers`watch our form for changes and respond accordingly.

### FormControl

Represents *a single input field* – it is the smallest unit of an Angualr form. `FormControl`s encapsulte the field’s value, and states such as being valid, dirty, or has errors. Like:

```ts
let nameControl = new FormControl("Nate");
let name = nameControl.value; // -> nate
// can just query this control for certain values
nameControl.errors // -> StringMap<string,any> of errors
nameControl.dirty -- 
nameControl.valid
```

Just like many in Angular, have a class `FormControl`and a directive – `formControl`, might:

`<input type="text" [formControl]="name" />`

### FormGroup

Most forms have more than one field, so need a way to manage multiple `FormControl`– if wanted to check the validity of our form– `FormGroup`just solve this issue by providing *a wrapper interface* around a collection of `FormControls`. Like:

```ts
let personInfo = new FormGroup({
    firstName: new FormControl("Nate"),
    lastname: new FormControl("Murry"),
})
```

`FormControl`and `FormGroup`have a common ancestor – `AbstractControl`– means that can check just `status`or `value`of this object .

### First Form

```ts
imports: [FormsModule, ReactiveFormsModule]
```

This ensures that we’re able to use the form directives in our views. This ensures that we’re able to use the form directives in our views.` [FormsModule]`for `ngModel`and `NgForm`, and 

`ReactiveFormsModule`= for `formControl`and `ngFormGroup`.

Note that here are several more.

### Reactive -vs. template-driven forms

Angular allows to defined forms in two different ways – reactive or template driven. To show examples of different ways you can build forms – like: *template driven* forms like:

```html
<div class="mb-3">
    <label for="skuInput">SKU</label>
    <input type="text"
           id="skuInput"
           placeholder="SKU"
           name="sku" ngModel />
</div>
```

There are a couple of different ways to specify `ngModel`in templates and this is the first – when use the `ngModel`with no attribute value, just specifying – 

1. it’s a one way data binding
2. Want to create a `FormControl`on this form with name `sku` (cuz of the name attr on this `input`)

If using `ngModel`in the `input`, must specify the `name`attribute.

```ts
onSubmit(form:any) {
    console.log("you have submitted", form);
} // then f.value is a object like {"sku": "valueOfInput"}
```

