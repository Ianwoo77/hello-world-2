# Understanding Docker

Runnig applications in containers. Cover some background that will help understand exactly what a container is, and why contaner are such a lightweight way to run apps.

## Running in a container

```sh
docker container run diamol/ch02-hello-diamol
```

The `docker container run`command tells Docker to run an app in a container. The app has been packaged to run in Docker and has published on a public site that anyone can access. The container package ( *image* ). Docker needs to have a copy of the image locally before it can run a container using the image.

re-run the command – there will be differences – Docker just already has a copy of the image locally so it does not need to download the image first.

## what is a container

Like a box with an app in it. The app seems  to have a computer all to itself. Those things are all virtual resources - hostname, IP, and filesystem are created by Docker. The applications in those boxes have their own separate environments but all share the CPU and memory of the computer.

Density means that running as many apps on pc as possible. Apps really need to be isolated from each other, and that stops you running lots them on a single computer.

## Connecting to a container like a remote computer

Namely, how U run a container and connect to a terminal inside the container. FORE:

```sh
docker container run --interactive --tty diamol/base
```

And the `--interactive`flag tells Docker want to set up a connection to the container, and the `--tty`means want to connect to a terminal session inside the container.

And remember that the container is sharing your computer’s os. Docker itself has the same behavior regardless of which OS or processor you are using.

```sh
docker container ls
```

The `docker container ls --all`shows all containers in any status. Containers in the exited state still exist, which just means you can start them again – check logs, and like:

```sh
docker container inspect containerName
```

So, starting containers that stay in the background and just keep running – like:

```sh
docker container run --detach --publish 8088:80 diamol/ch02-hello-diamol-web
```

This image you’ve jsut used is .. That image includes the **APACHE** web server and a simple HTML page.

- `--detach`– starts the container in the background and shows the container ID.
- `--publish`– publishes a prot from the container to the computer.

Running a detached just puts the container in the background. And, just note that containers aren’t exposed to the outside world by default. Each has its own IP address – but that is an IP that Docker creaates for a network that Docker just manages – the container is not attached to the physical network of the computer. Publishing a container port means docker listnes for network traffic on the computer.

And need to note that the app in this container keeps running indefinitiely.

```sh
docker container stats container_name
```

And, when are done working with a container, you can just remove it with `docker container rm`and the ID, using the –force to force removal if the container is still running. Like:

```sh
docker container rm --force $(docker container ls --all --quiet)
```

The `$()`sends the output from one command into another command.

## Understanding how Docker run containers

- The *Docker Engine* is the management component of Docker – looks after the local image cache, downloading images when need them, reusing them..
- The Docker Engine makes all the features available through the *Docker* API.
- The *Docker command-line interface* is a client of the Docker API.

The only way to interact with the Docker Engine is just through the API.

## Building own Docker images Using from Hub

```sh
docker image pull diamol/ch03-web-ping
```

Stored on Docker Hub – which is the *default location* where Docker looks for images. A Docker image — can think of it as a big zip file that contains the whole app stack. Can see the **image layers** downloaded. A Docker image is physically stored as lots of small files. Can:

```sh
docker container run -d --name web-ping diamol/ch03-web-ping
```

`-d`is for short of `--deach`. and the `--name`give them a friendly name. For now the container named `web-ping`.

```sh
docker rm -f web-ping
docker container run --env TARGET= baidu.com diamol/ch03-web-ping
docker container logs ID
```

First, running interactively cuz didn’t use the `--detach`– Docker images may be packaged with a default set of configuration values for the application.

Environmnet vars are a very simple way to achieve that. For the web-ping app, looks for an environment variable just with the `TARGET`key. Can just provide a different value with the docker container run command.

## Writing Dockerfile

The Docker is just a simple script you write to package up an app – it’s a set of instruction, and a *docker image is the output*. Fore, the full dockerfile to package up the web-ping app like:

```dockerfile
FROM diamol/node
ENV TARGET="blog.sixeyed.com"
ENV METHOD="HEAD"
ENV INTERVAL="3000"

WORKDIR /web-ping
COPY app.js .
CMD ["node", "web-ping/app.js"]
```

# Benchmarks

The url package wrote is jsut a part of the Go stdlib, and you might just expect that millions of Go will use it. Might want to optimize the url package and make.. Benchmarking is the process of running the same code *repeatedly* and measuring how it performs on average cuz it has to be statistically significant.

The difference between tests and benchmarks is that benchmarks measure code performance and tests just verify code correctness. Jsut measure the *average* performance of the `String`method. `*testing.B*`used.

```go
func BenchmarkURLString(b *testing.B) {
	u := &URL{"https", "foo.com", "go"}
	u.String() 
}
// go test -bench .
```

Just like the `run`, the `bench`also accepts regular expressions.

`BenchmarkURLString-24`means that the testing package run the benchmark using 24 CPU cores.

### Running only the benchmarks

The testing package will still run your tests together with benchmarks even with the `bench`flag. Can see that is happening if you had used the verbose flag like: RUN, PASS…

```sh
go test -run=^$ -bench .
```

### Proper benchmarking 

Can print a message in the benchmark function like:

```go
func BenchmarkURLString(b *testing.B) {
    b.log("Called")
    // ...
}
```

### Helping the running adjust itself

A field called `N`in the `*testing.B*`type helps the benchmark runing adjust itself. like:

```go
func BenchmarkURLString(b *testing.B) {
	b.Logf("Loop %d times\n", b.N)
	u := &URL{"https", "foo.com", "go"}
	for i:=0; i<b.N; i++{
		u.String()
	}
}
```

### Measuring memory allocations

Benchmarking is not only about measuring the operations per second - can also measure the memory allocations of your code. Can call `ReportAllocs()`:

```go
func BenchmarkURLString(b *testing.B) {
    b.ReportAllocs()
} // 56B/OP
```

### Comparing benchmarks

Usually need to compare older performance results with the news. FORE:

1. Save the benchmark result of the `String`method
2. Find out how you can optimize it
3. Remeasure it and compare it with the preivous result.

```sh
go test -bench . -count 10 > old.txt # -count 10, run the same bench for 10 times
# change the method just
go test -bench . -count 10 > new.txt
# now compare the old and new
benchstat old.txt new.txt
```

### Sub-benchmarks

Measuring the performance of the `String`method with different URL values can just give you more accurate results, can use the sub-benchmarks to do that. like:

```go
func BenchmarkURLString(b *testing.B) {
	var benchmarks = []*URL {
		{Scheme: "https"},
		{Scheme: "https", Host: "foo.com"},
		{Scheme: "https", Host: "foo.com", Path: "go"},
	}
	for _, u := range benchmarks {
		b.Run(u.String(), func(b *testing.B) {
			for i:=0; i<b.N; i++ {
				u.String()
			}
		})
	}
}
```

## Data Validation

Right now there is a glaring problem with code, not validating the user input from the form in any way. Should do this to ensure that the form data is present, of the correct type and meets any business rules. So, all of checks are straightforward to implement.

```go
// initialize a map to hold validation errors
errors := make(map[string]string)

if strings.TrimSpace(title) == "" {
    errors["title"] = "This field cannot be blank"
} else if utf8.RuneCountInString(title) > 100 {
    errors["title"] = "This field is too long"
}

// check that the content filed isn't blank too
if strings.TrimSpace(content) == "" {
    errors["content"] = "This field cannot be blank"
}

// check the expires isn't blank and matches one of permitted
if strings.TrimSpace(expires) == "" {
    errors["expires"] = "This field cannot be blank"
} else if expires != "365" && expires != "7" && expires != "1" {
    errors["expires"] = "This field is invalid!"
}

if len(errors) > 0 {
    fmt.Fprint(w, errors)
    return
}
```

### Displaying Validation Errors and Repopulating Fields

Now that the `createSnippet()`is validating the data the next is to manage these errors gracefully. For this, if there are any validation errors, want to re-display the form, highlighting the fields which failed . Adding two new fields to our struct - `FormErrors`which hold any validation errors and `FormData`holds previously submitted data.

```go
type templateData struct {
	// ...
	FormData    url.Values // query form values
	FormErrors  map[string]string
}
```

Note – The `url.Values`-- is the same underlying types as the `r.PostForm`map that map that held the data. Then update the `createSnippet()`handler again.

```go
if len(errors) > 0 {
    app.render(w, r, "create.page.html", &templateData{
        FormErrors: errors,
        FormData: r.PostForm,
    })
    return
}
```

For this, there are any valiation errors, we are re-displaying the `create.page.html`. Just need to update the `create.page.html`file to display the data and validation error messages for each field like:

```html
<div>
    <label>Content:</label>
    {{with .FormErrors.content}}
    <label class="error">{{.}}</label>
    {{end}}
    <textarea name="content">{{.FormData.Get "content"}}</textarea>
</div>
```

For:

```html
{{$exp := or (.FormData.Get "expires") "365"}}
```

This is essentially creating a new $exp *template variable* which uses the `or`template function to set the variable to the value yielded by `FormData.Get "expires"`. or if that’s empty then the default vlaue instead.

Then just check :

```html
{{if (eq $exp "365")}}checked{{end}}
```

## Scaling Data Valiation

While the approach taken is fine as a one-off – if app has many forms then can end up with .. a lot of repetition. Address by creating a `forms`package to abstract some of this behavior and reduce the boilerplate code.

In the erros.go file:

```go
// define a new errors map, which will use to hold the validation error messages for forms.
type errors map[string][]string

// Add Implement an Add() to add error messages for a given field to map
func (e errors) Add(field, message string) {
	e[field] = append(e[field], message)
}

// Get retrieve the first error message for a given map
func (e errors) Get(field string) string {
	es := e[field]
	if len(es) == 0 {
		return ""
	}
	return es[0]
}
```

```go
// Form create a custom Form, anonymously embeds a url.Values and an Errors
type Form struct {
	url.Values
	Errors errors
}

func New(data url.Values) *Form {
	return &Form{
		data, errors(map[string][]string{}),
	}
}

func (f *Form) Required(fields ...string) {
	for _, field := range fields {
		value := f.Get(field)
		if strings.TrimSpace(value) == "" {
			f.Errors.Add(field, "This field cannot be blank")
		}
	}
}

func (f *Form) MaxLength(field string, d int) {
	value := f.Get(field)
	if value == "" {
		return
	}
	if utf8.RuneCountInString(value) > d {
		f.Errors.Add(field, fmt.Sprintf("This field is too long (maximum is %d)", d))
	}
}

func (f *Form) permittedValues(field string, opts ...string) {
	value := f.Get(field)
	if value == "" {
		return
	}
	for _, opt := range opts {
		if value == opt {
			return
		}
	}
	f.Errors.Add(field, "this field is invalid")
}

func (f *Form) Valid() bool {
	return len(f.Errors) == 0
}
```

The next is to just update the `templateData`struct so that can pass this new struct to templates.

```go
form := forms.New(r.PostForm) // url.Values == PostForm
form.Required("title", "content", "expires")
form.MaxLength("title", 100)
form.PermittedValues("expires", "365", "7", "1")
if !form.Valid() {
    app.render(w, r, "create.page.html", &templateData{Form: form})
}

id, err := app.snippets.Insert(form.Get("title"), form.Get("content"), form.Get("expires"))
```

Also need to update `create.page.html`file.

# Stateful HTTP

A nice touch to improve our use experience would be to display a one-time confirmation message which the user sees after add a new snippet. A confirmation message liket this should only show up for the user once and no other users should ever see the message.

To make this just work, need to start *sharing data (or state) between HTTP requests* for the same user.

## Installing a Session Manager

For, there is a lot of *security considerations* when it comes to working with sessions, and proper implementaion is non-trivial. like:

- `gorilla/sessions`
- `alexedwards/scs`
- `golangcollege/sessions`

For this, just using the *cookie-based* sessions , using the last one – `golangcollege/sessions`package. And note that the `gloang.org/x/crypto`and `golang.org/x/sys`package – have been automatically downloaded.

# Overriding the Data Model Conventions

EF core conventions are convenient when the design of the dbs aligns with what you need in the app.

- `Table`-- specifies the dbs table and overrides the name of the prop in the context class
- `Column`– specifies the column that provides values for the prop it applied to.
- `key`– used to identify the prop that will be assigned the PK value.

Like:

```cs
[Table("Colors")]
public class Style {
    [Key][Column("Id")]
    public long UniqueIdent {get;set;}
    
    [Column("Name")]
    public string StyleName {get;set;}
}
// in the DbContext:
public DbSet<Style> ShoesStyle=> Set<Style>();
```

## Using the Fluent API to Override Model Conventions

The Fluent API is used to override the data model conventions by describing parts of the data model programmatically – Attributes are suitable for making simple changes – but eventually you will have to deal with a situation for which there is no suitable attribute, and that requires an advanced feature that only the Fluent API supports.

Just going to use the `SheWidth`table to represent the data in the `Fittings`table – the class doesn’t follow the EF core conventions.

```cs
public DbSet<ShoeWidth> ShoeWidths => Set<ShoeWidth>();

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<ShoeWidth>().ToTable("Fittings");
    modelBuilder.Entity<ShoeWidth>().HasKey(t => t.UniqueIdent);

    modelBuilder.Entity<ShoeWidth>()
        .Property(t => t.UniqueIdent)
        .HasColumnName("Id");

    modelBuilder.Entity<ShoeWidth>()
        .Property(t => t.WidthName)
        .HasColumnName("Name");
}
```

So the `OnModelCreating`method receives a `ModelBuilder`obj, on which the Fluent API is used. The most important method defined by the `ModelBuilder`class is the `Entity<T>`which allows an entity class to be described to EF core and overrides the conventions that would be used.

And the `Entity<T>`method just returns an `EntityTypeBuilder<T>`object, which defines a series of methods are used to describe the data model to EF core.

NOTE : – The Fluent API methods that selects an entity class prop, such as `HasKey`and `Property`-- are just overloaded so that props can be specified as strings or using a Lambda expression.

- `ToTable(table)`-- used to specify the table for the entity class, equal to the `[Table]`
- `HasKey(selector)`– used to specify the key prop for an entity class, equal to the `[Key]`
- `Property(selector)`– used to select a property so that it can be described in more details.

The `ToTable`and `HasKey`are used on their own to specify the dbs table and the PK property for the `ShoeWidth`class. And the `Property`method is used to select a prop for further configuration and returns a `PropertyBuilder<T>`object where T is the type returned by the selected property. Defines a number of methods that are used to provide **fine-grained** control over a prop and fore:

- `HasColumnName(name)`-- used to select the column that will provide values for the selected property.

### Using the Customized Data Model

Once have overridden the conventions to create the data that your apps requires, can use the context class and the entity classes as you would normally. Added statements to the `Index`of the `Manual`controller.

```cs
public IActionResult Index()
{
    ViewBag.Styles = context.ShoeStyles;
    ViewBag.Widths = context.ShoeWidths;
    return View(context.Shoes);
}
```

And to display the data to the user, just change the `Index.cshtml`file like:

```html
<div class="row">
    <div class="col">
        <h5 class="bg-primary p-2 text-white">Styles</h5>
        <table class="table table-striped table-sm">
            <tr>
                <th>UniqueIdent</th><th>Style Name</th>
                <th>Main Color</th><th>Highlight Color</th>
            </tr>

            @foreach (Style s in ViewBag.Styles)
            {
                <tr>
                    <td>@s.UniqueIdent</td>
                    <td>@s.StyleName</td>
                    <td>@s.MainColor</td>
                    <td>@s.HighlightColor</td>
                </tr>
            }
        </table>
    </div>

    <div class="col">
        <h5 class="bg-primary p-2 text-white">Widths</h5>
        <table class="table table-striped table-sm">
            <tr><th>UniqueIdent</th><th>Name</th></tr>
            @foreach (ShoeWidth s in ViewBag.Widths)
            {
                <tr><td>@s.UniqueIdent</td><td>@s.WidthName</td></tr>
            }
        </table>
    </div>
</div>
```

# Using Bearer Token Authentication

Not all web services will be able to rely on cookies cuz not all clients can use then – an alternative is to use the bear token, which is just a string that clients are given and is included in the requests they send to the web service. Going to demonstrate authentication using `JWT`which provides the client with an encrypted token that contains the authenticated username.

## Preparing the application 

Need to install:

```sh
Install-Package System.IdentityModel.Token.Jwt
Install-Package Microsoft.AspNetCore.Authentication.JwtBearer -Version 6.0.0
```

And, **JWT** requires a key that is used to encrypt and decrypt tokens – Add the configuration settings in the appsettings.json file. `"jwtSecret": "appress_jwt_secret"` – note that if use JWT in a real app, just ensure change the key.

## Creating Tokens

The Client will send an HTTP *request that contains user credentials and will just receive a JWT in response*. Like:

```cs
[Route("api/account")]
[ApiController]
public class ApiAccountController : ControllerBase
{
    private SignInManager<IdentityUser> signInManager;
    private UserManager<IdentityUser> userManager;
    private IConfiguration configuration;

    public ApiAccountController(SignInManager<IdentityUser> signInManager,
        UserManager<IdentityUser> userManager,
        IConfiguration configuration)
    {
        this.signInManager = signInManager;
        this.userManager = userManager;
        this.configuration = configuration;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] Credentials creds)
    {
        Microsoft.AspNetCore.Identity.SignInResult result =
            await signInManager.PasswordSignInAsync(creds.Username,
            creds.Password, false, false);
        if (result.Succeeded)
        {
            return Ok();
        }
        return Unauthorized();
    }

    [HttpPost("logout")]
    public async Task<IActionResult> Logout()
    {
        await signInManager.SignOutAsync();
        return Ok();
    }

    private async Task<bool> CheckPassword(Credentials creds)
    {
        IdentityUser user= await userManager.FindByNameAsync(creds.Username);
        if (user != null)
        {
            return (await signInManager.CheckPasswordSignInAsync(user,
                creds.Password, true)).Succeeded;
        }
        return false;
    }

    [HttpPost("token")]
    public async Task<IActionResult> Token([FromBody] Credentials creds)
    {
        if(await CheckPassword(creds))
        {
            JwtSecurityTokenHandler handler = new JwtSecurityTokenHandler();
            byte[] secret = Encoding.ASCII.GetBytes(configuration["jwtSecret"]!);
            SecurityTokenDescriptor descriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new Claim[]
                {
                    new Claim(ClaimTypes.Name, creds.Username)
                }),
                Expires = DateTime.UtcNow.AddHours(24),
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(secret),
                    SecurityAlgorithms.HmacSha256Signature)
            };
            SecurityToken token = handler.CreateToken(descriptor);
            return Ok(new
            {
                success = true,
                token = handler.WriteToken(token)
            });
        }

        return Unauthorized();
    }
}

public class Credentials
{
    public string Username { get; set; } = null!;
    public string Password { get; set; } = null!;
}
```

The `UserManager<T>`class defines a `PasswordValidators`prop that returns a sequence of objects that implements the `IPasswordValidator<T>`interface. When the `Token`method invoked, it passes the credentials to the `CheckPassword()`private method,  which enumerates the `IPasswordValiator<T>`objects to invoke the `ValidateAsync`on each of them. If the password is valiated by any of the valiators, then Token created.

The JWT specification defines a general-purpose token that can be used more broadly.

# Validating the model

Is just the most important part of the building forms – without that, the system can just end up containing all kinds of rubbish data. Out of the box, Blazor includes a few components to help us to do this– 

- `DataAnnotationValidator`
- `ValidationSummary`
- `ValidationMessage`

The `DataAonnotationValidator`component allows Blazor forms to work with the Data Annotations validation system – which is just the defautl for the Core applications. This system works by decorating props in a model with attributes that define the validation rules.

`ValidationSummary`displays all validation messages for a model. This can just be useful. And the `ValidationMessage`displays a message for a specific prop on the model.

### Configuring rules with Fluent Validation

Going to set up API and ClassLib to use Fluent Validation. In the API:

```sh
Install-Package FluentValidation.AspNetCore
Install-Package FluentValidation
```

Then set up the `TrailDto`– just for:

```cs
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddFluentValidationClientsideAdapters();
builder.Services.AddValidatorsFromAssemblyContaining<TrailValidator>();
builder.Services.AddValidatorsFromAssemblyContaining<RouteInstructionValidator>();
```

Like:

```cs
public class TrailValidator: AbstractValidator<TrailDto> {
    public TrailValidator(){
        RuleFor(x=>x.Name).NotEmpty()
            .WithMessage("Please enter a name");
        //...
        RuleForEach(x=>x.Route).SetValidator(new RouteInstructionValidator());
    }
}
```

### Configuring Blazor to use Fluent Validation

Need to tell Blazor how to understanding and processing them – `Blazored.FluntValidation`contains one component called `FluentValidationValidator`– when included in an `EditForm`, will allow the form model to be validated according to **any** Fluent Validation rules. Just:

```html
<EditForm Model="..." OnValidSubmit="SubmitForm">
	<FluentValidationValidator />
    <!--... -->
    <FormFieldSet ...>
    <InputText @bind-Value="_trail.Location"
                       class="form-control" id="trailLocation"/>
            <ValidationMessage For="@(()=>_trail.Location)" />
    </FormFieldSet>
</EditForm>
```

The HTML is of the `FormFieldSet`containing the trail name and shows that the input elements has a CSS class named `invalid` applied to it - This was applied cuz of Blazor’s validation system – to help accessibility, an `aria`attribute was also applied – `aria-invalid`

And the `EditContext`will keep track of the state of the form – it knows that the state of each prop on the model *at any given time*. When validation is exuected, the input component bound to a prop is updated with CSS classes that represent that property’s state – `valid invalid modified`, So, Can use these classes to style inputs based on their validation state – like:

```css
.validation-message {
    color:red;
}

input.invalid,
textarea.invalid,
select.invalid {
    border-color: red;
}

input.valid.modified,
text.valid.modified,
select.valid.modified {
    border-color: lawngreen;
}
```

And for now, add in the `ValidationMessage`components to remaining sections of the form.

```html
<div class="row">
    <div class="col">
        <button class="btn btn-outline-primary"
                type="button"
                @onclick="@(() => _trail.Route.Add((new TrailDto.RouteInstruction())))">
            Add Instruction
        </button>
        <ValidationMessage For="@(()=>_trail.Route)"></ValidationMessage>
    </div>
</div>
```

## Submitting data to the Server

Have a form that allows us to capture data from the user – and have validation in place to stop invalid data getting into the system – the lasting thing need to do is to persist that data to our new API. To do this, employ a couple libraries that –  The first is called *MediatR* – Is a in-process messaging library that implements the `mediator`pattern – Essentially, requests are constructed and passes to the mediator, which then passes them to a handler – `MediatR`uses dependency injection to connect requests with handlers. This makes things very flexible and easy to test – The main advantage of using MediatR is the ablitiy to have **loose coupling** between components and server interctions.

The second is called `ApiEndpoints`– For controllers – whether it’s MVC or API controller – Sums it up in by allowing us to *define an endpoint as a class with a single method to handle the incoming request*. This allows us to avoid the issues that surround controllers and build clear and easy-to-maintain endpoints in our APIs.

### In Client

A Request is created – > MediatR (is displatched to MediatR,) where the appropriate handler is found to deal requests< -> Handler . At last MediatR return to calling code.

### In Server

Handler <–> API endpoint (receives the request and processes it)

Taking our form as the example, will create a request to post the dat to the API and pass this requeste to `MediatR`, will route our request to a handler, which will process the request and make the API call. On the server, an API endpoint will receive the requeste and process it – in this case, it will save the data in the dbs, and if there are no issues, it will return a success response – otherwise an error response will be just returned.

# Using a Form Group with Form Element

`reset(val)`-- This method resetst the from to its prinstine and untouched state and uses the specified vlaue to populate the form controls. Used `reset`to populate or clear the form controls when the user just create New or Edit button.

The `FormGroup`and `FormControl`classes share a common base class, which means that many of the properties and methods provided by `FormControl`are also available on a `FormGroup`object – but applied to *all of the controls* in the group. Like:

```ts
this.productForm.statusChanges.subscribe(newStatus=> {
    if(newStatus==="INVALID"){}
})
```

If any of the individual controls ar invalid, then the overall form status will be invalid, which allows me to assess the validation results without needing to inspect controls individually. But access to the individual controls is still available using the `controls`property, which lets me build up a list of invalid controls.

```ts
for (let controlName in this.productForm.controls) {
    if (this.productForm.controls[controlName].invalid)
        invalidControls.push(controlName);
}
```

## Using a Form Group with a Form Element

The `formGroup`directive associates a `FormGroup`object with an element in the template, in the same way the `formControl`directive is used with a `FormControl`object. like:

```html
<form [formGroup]="productForm">
    <div class="form-group">
        <input class="form-control" formControlName="name" />
    </div>
    
    <div class="mb-3">
        <input class="form-control" formControlName="category" />
    </div>
</form>
```

The `formGroup`directive is used to specify the `FormGroup`object, and the individual form elements are associated with their `FormControl`objects using the `formControlName`attribute – Specifying the name used when adding the `FormControl`to the `FormGroup.`

Using the `formControlName`attr means that don’t have to define props for each `FormControl`object in the controller class, allowing to simplify the code just like:

```ts
productForm: FormGroup = new FormGroup ({
    name: /* used in formControlName */ new FormControl("", {
        validators: [
            Validators.required,
            Validators.minLength(3),
            Validators.pattern("^[A-z]+$")
        ],
        updateOn: "change",
    }),
    
    category: new FormControl(),
})
```

There is just no change in the output produced by the app.

## Accessing the Form Group from the Template

In addition to simplifying the application code, the `formGroup`directive defines some useful properties that allow to complete the transition to the reactive forms API – restoring the features that were present when the form was managed solely through a template. FORE:

- `ngSubmit`-- is triggered when the form is submitted.
- `submitted`– returns `true`if the forms has been submitted.
- `control`– returns the `FormControl`that has been associated with the directive.

```ts
// in the FormGroup:
category: new FormControl("", {validators: Validators.required}),
price: new FormControl("", {
    validators: [Validators.required, Validators.pattern("^[0-9\.]+$")]
}),
//...
submitForm() {
    if (this.productForm.valid) {
        Object.assign(this.product, this.productForm.value);
        this.model.saveProduct(this.product);
        this.product= new Product();
        this.productForm.reset();
    }
}

resetForm() {
    this.editing=true;
    this.product=new Product();
    this.productForm.reset();
}
```

## Displaying Validation Messages with a Form Group

The `formControlName`directive doesn’t export an identifier for use a template variable, which complicates the process of displaying validation message.  Instead, errors must be obtained through the `FormGroup`obj – using the optional `path`argument for the error-related methods – just the `FormGroup`'s methods:

- `getError(v, path)`-- this returns the error message and if there is one, for the specified validator, the optional `path` arg is used to identify the control.
- `hasError(v, path)` – return `true`if specified validator has generated an error message. 

These methods require the error to be specified, which means that it is possible to determine if a specific control has a specific error like this – `form.getError("required", "category")`

This expression would return details of errors reproted by the `required`validator on the `category`control, which is just identified by the name used to register the control in the `FormGroup`.  

But, want to display validation messages by getting all of the errors for a single `FormControl`object. For this, an just use the `get`method defined by the `FormGroup`class.

```html
<form #f="ngForm" (ngSubmit)="onSubmit(f.value)"...>
    ...
</form>
```

Just note that the value is an object k-v.

### Using `FormBuilder`

Building implicitly using `ngForm`is convenient, but doesn’t give us a lot of customization options. A more flexible and common way to configure forms is to use a `FormBuilder`. `forms`are just made up of `FormControl`and `FormGroup`, and the `FormBuilder`helps us make them.

- how to use the `FormBuilder`in our component definintion class
- how to use our custom `FormGroup`on a `form`in the view.

### Reactive Forms with `FormBuilder`

```ts
export class DemoFormSkuWithBuilderComponent {
	constructor(public fb: FormBuilder) {
	}

	myForm: FormGroup = this.fb.group({
		'sku': ['ABC123']
	});

	onSubmit(value: string) {
		console.log('you submitted value: ', value);
	}
}
```

There are two main functions we will use on `FormBuilder`object – 

- `control`-- create a new `FormControl`
- `group`-- creates a new `FormGroup`.

Just set up one **Control** `sku`, and the value is `["ABC123"]`– this just says that the *default value* of this control.

### Using `myForm`in the view

Just want to change our `<form>`to use `myForm`– if you recall, in the last we said the `ngForm`is applied for us automatically when use `FormsModule`. Angular also provides a directive – like:

```html
<div class="container">
	<h2>Demo Sku with Builder</h2>
	<form [formGroup]="myForm"
		  (ngSubmit)="onSubmit(myForm.value)">
		<div class="mb-3">
			<label class="form-label" for="skuInput">SKU</label>
			<input type="text" id="skuInput"
				   placeholder="SKU"
				   formControlName="sku"
			class="form-control"/>
		</div>

		<button class="btn btn-primary" type="submit">Submit</button>
	</form>
</div>
```

### Adding Valiators

Validators are just provided by the `Validators`module and the simplest validator is `Validators.required`which says that the designated filed is required. To use validators, we need do two things – 

1. Assign a validator to the `FormControl`object.
2. check the status of the validator in the view and take action accordingly.

And, to assign a validator to a `FormControl`can pass it just as the second arg to our ctor:

`let control = new FormControl('sku', Validators.required);`

```ts
myForm: FormGroup = this.fb.group({
    'sku': ['', Validators.required],
});
```

There are two ays can access the validation value in the view:

1. can explicitly assign the `FormControl`to an instance of the class
2. can lookup the `FormControl` from myForm in the view.

### Form Message

can check the validity of our whole form by looking at `myForm.valid`prop. like:

`<div *ngIf="!myForm.valid"`

### Field message

can also display a message for the specific field if that field’s `FormControl`is invalid – 

### Specific Validation

A form field can be invalid for many reasons – often want to show a different message depending on the reason for a failed validation. like:

```html
<div *ngIf="sku.hasError('required')"
     class=...
```

Note that the `hasError()`is defined on both `FormControl`and `FormGroup`– this means that you can pass a second arg of `path`to lookup a specific field from the `FormGroup`like:

```html
<div *ngIf="myForm.hasError('required', 'sku')" class=...>
```

Like:

```html
<form [formGroup]="myForm"
      (ngSubmit)="onSubmit(myForm.value)"
      [class.text-danger]="!myForm.valid && myForm.touched">
    <div class="mb-3" [class.bg-danger]="myForm.hasError('required', 'sku')"
         [class.text-white]="myForm.hasError('required', 'sku')">...
    </div>
```

Or just using the `myForm.controls['sku'].hasError('rquired')`to just get the single `FormControl`object.

## Custom validations

Often are going to want to write our own custom validations – take a look at thow to do that. The `Validators.required`just like:

```ts
export class Validators {
    static required(c: FormControl): StringMap<string, boolean> {
        return isBlank(c.value) || c.value=="" ? {'required': true}: null;
    }
}
```

So, a validator just takes in a `FormControl`as its input, and returns a `StringMap<string, boolean>`where the key is `error code`and the value is `true`if fails.

Fore, say our `sku`just needs to begin with `123`, just:

```ts
static skuValidator(control: FormControl): { [s: string]: boolean } | null {
    if (!control.value.match(/^123/)) {
        return {'invalidSku': true};
    }
    return null;
}
// ...
myForm: FormGroup = this.fb.group({
    'sku': ['', Validators.compose([  // compose method to compose validators
        Validators.required,
        DemoFormSkuWithBuilderComponent.skuValidator,
    ])],
});
```

```html
<div *ngIf="myForm.controls['sku'].hasError('invalidSku')"
				 class="bg-danger">SKU must begin with 123</div>
```

## Watcing for Changes

only extracted the value from our form by calling `onSubmit()`when the form is submitted. But, often need to watch for any value changes on a control. Note that both `FormGroup`and `FormControl`have an `EventEimitter`that can use to observe changes.

To watch for changes on a control need 

1. Get access to the `EventEimitter`by calling `control.valueChanges`
2. add an *observer* using the `.subscribe()`method.

```ts
export class DemoFormWithEventsComponent implements OnInit {
	constructor(public fb: FormBuilder) {
	}

	myForm: FormGroup = this.fb.group({
		'sku': ['', Validators.required]
	});

	ngOnInit() {
		this.myForm.controls['sku'].valueChanges.subscribe(
			value => console.log('sku changed to: ', value)
		);
		this.myForm.valueChanges.subscribe(form => {
			console.log('form changed to ', form);
		})
	}
}
```

Here, just observing two separate events – changes on the sku and changes on the form as a whole. As can see eac keystroke causes the control to change – so is triggered.

## ngModel

Is a special directive, it binds a model to a form – `ngModel`is special in that it mimics two-way bindings. Two-way data binding is almost always more complicated and difficult to reason about. Angular is built to generally have data flow one-way – top-down – however, when it comes to forms, there are times where it is just easier to opt-in to a two-way bind.

Just change the form a little bit and say we want to input `productName`. Just like:

```html
<label for="productNameInput">Product Name</label>
<input type="text" id="productNameInput"
	   placeholder="Product Name" name="productName"
	   [(ngModel)]="productName" />
```

Forms have a lot of moving pieces – but Angular just makes it fairly straightforward – once you get a handle on how to use `FormGroup`, `FormControls`and `Validation`.

## Dependency Injection

As programs grow in size, parts of the app need to communiate with other modules. When Module A requires Module B to run , say that B is *dependency* of A – One of the most common ways to get access to dependencies is to simply `import`a file. And in many cases, this is sufficient. But other times need to provide dependencies in a more sophisticated way – fore 

- Substitute out the implementation of B for `MockB`.
- Share a *single instance* of the `B`class acorss our whole app. – *singleton* pattern.
- Create a *new instance of* `B`class every time it is used.

`DI`is a system to make parts of our program accesible just to other parts of the program, and we can configure how that happens.
