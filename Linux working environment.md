# Linux working environment

Virtualization is the single most important tech beind almost all recent improvements in the way services and products are delivered. – Made entire industries from ..

```sh
cat < file.txt
sudo dpkg --get-selection > pkg.list
```

## `stdin stdout stderr`and Redirection

When program runs, it automatically has 3 input/output streams opened for it. one for input, output, and error messages. These are attached to the user’s terminal, can be directed elsewhere.

```sh
ps aux --sort=-%cpu
```

### The `localhost`interface

Called *loopback interface*. commonly referenced as `lo`.

```sh
ip address show
ifconfig # sudo apt install net-tools
```

And, this command is just deprecated.

### Configuring the loopback interface Manually

```sh
ping -c localhost # -c numbers
```

`traceroute`-- tracks the route that packets take on an IP network from the local computer to the network host specified. And the `traceroute6`tool is intended for use with IPv6.

```sh
traceroute google.com
```

`mtr`combines the `ping`and the `traceroute`.

Networking with TCP/IP

## SSH and VNC

A web server stack is a set of software installed and configured to work together to serve content over a network – there are many stacks of software that are common enough to be referred to using acronyms.

## LAMP

Was one of the first stacks to become popular – composed of Linux, Apache, MySQL and PPP.

1. Install OpenSSH and configure the machine for SSH access. This is vital if intend to eventually serve content via HTTPs.
2. Apache 2 and set it up for the sites U intend to host.

### LEMP

Main difference is LEMP uses `Nginx`.

# Nginx

Is a lightweight and extremely fast web server – it is free and open source – It is just stable and fast under high-traffic conditions while using few resources.

What makes Nginx different is that it uses an event-driven architecture to handle requests – instead of starting a new process or a new thread for each request, in an event-driven - the flow of the program is controlled by events, some form of message sent from another process or thread. Here, have a process that runs as a listener, or event detector. that waits for a request to come in to the server. When the request arrives, instead of a new process starting, the listener sends a message to a different part of the server – called *event handler*, which then performs a task.

And Nginx is designed to scale well from one small, low-powered server up to large network involving many servers.

### Installing the Nginx Server

If are about to just install a new version of Nginx – shut down the old server. Can install `nginx`package from Ubuntu software repositories.

```sh
sudo apt-get update
sudo apt install -y nginx
```

## Configuring the Nginx Server

Can configure the server – Nginx is most commonly running  using just virtual hosts. Nginx are located in the `/etc/nginx`-- and the primary configuration file is in `/etc/nginx/nginx.conf`

And for the `nginx.conf`file, contains these parts:

- `user`-- sets the system user that will be used to run `Nginx`. `www-data`by default, can add a group by inserting a second entry.
- `worker processes`-- allow to set how many processes Nginx may spawn on your server.

# Fighting with complexity

- Reduce repetitive tests using table-dirven testing
- Run tests in isolation using subsets
- Learn the tricks of writing maintainable tests
- Learn to shuffle the execution order of tests
- Parse port numbers from the host

Fore, receiving web requests with port numbers and need to get the *hostname and port number* from a URL to deny access to some hostnames and ports.

## Table-driven Testing

Data tables are everywhere in lives and make .. 

### Parsing port numbers

```go
type URL struct {
	Scheme string
	Host string
	Path string
}

func (u *URL) Port() string {
	return ""
}
```

To test all the different variations of the `Host`field – have to test any input. fore, will create a test function and provide the input value for the `Host`column, and check if the actual port number matches the number.

### Testing helpers

using a *test helper function* that only takes input data for the changing parts of the tests and bails out if sth goes wrong. like:

```go
func testPort(t *testing.T, in, wantport string) {
	u := &URL{Host: in}
	if got := u.Port(); got != wantport {
		t.Errorf("For host %q; got %q; want %q", in, got, wantport)
	}
}
```

`*testing.T`type is jsut a pointer to a struct, so can pass it to other functions. Now the helper becomes a reusable function with these two paramters. So test functions can call this function when testing for different `Host`values.

It’s a convention to write single-line function on the same line insted of adding the code after the curly braces.

Ideally, should expect to get extactly where an error occurs in a test function rather than in some random place. A test helper is not an actual test function but a helper.

### Table-driven testing

The idiomatic solution to the duplicate test problem is just *table-driven* testing. Table tests are all about finding repeatable patterns in your test code and identifying different use-case combinations. Fore, instead of creating separate test functions to verify the same code with different inputs, could put the *inputs* and *outputs* in a table and write the test code in a loop.

First of all, need to express the table – using anonymous struct – 

```go
struct {
    in string
    port string
}
// add the input data to a slice of the structs you defined
tests := []struct{in string, port string} {
    {"foo.com", ""},
    {"foo.com:80", port: "80"}
}
```

```go
func TestURLPort(t *testing.T) {
	tests := []struct {
		in   string
		port string
	}{
		{"foo.com:80", "80"},
		{"foo.com", ""},
		{"foo.com", ""},
		{"1.2.3.4:90", "90"},
		{"1.2.3.4", ""},
	}
	for _, tt := range tests {
		u := &URL{Host: tt.in}
		if got, want := u.Port(), tt.port; got != want {
			t.Errorf("for host %q, got %q, want %q", tt.in, got, want)
		}
	}
}
```

### Naming test cases

The table test will fail when run – but at least it will give you descriptive error messages.

```go
func TestURLPort(t *testing.T) {
	tests := []struct {
		in   string
		port string
	}{
		1: {"foo.com:80", "80"},
		2: {"foo.com", ""},
		3: {"foo.com", ""},
		4: {"1.2.3.4:90", "90"},
		5: {"1.2.3.4", ""},
	}

	for i := 1; i < len(tests); i++ {
		tt := tests[i]
		u:= &URL{Host: tt.in}
		if got, want := u.Port(), tt.port; got != want {
			t.Errorf("test: %d, for host %q, got %q, want %q", i, tt.in, got, want)
		}
	}
}
```

## Subtests

A subtest is a standalone test similar to a top-level test. Subtests allows you to run a test under a top-level in isolation choose which ones to run. And subtest is a test what you can run wtihin a top-level test function in isolation.

- Isolation allows a subsets to fail and others to continue (even if one of them fails with `Fatal`)
- Also allows to run each subtest in parallel if wanted.
- One more advantage is that you can choose which subtests to run.

On the other hand, table-driven testing can help you up to a point – run the tests using a data tble under the same top-level test – not isolated from each other.

### Isolation problem 

fore, want to focus on one test case and fix it without running the other test cases – Table-driven tests are useful enough in most cases – but the problem here is that you can’t debug for that case.

## Catching Runtime errors

There is a risk of encountering runtime errors - fore, add some deliberate error to the template. This is – our app has thrown an error, but the user has wrongly been sent a 200. To fix this need to make the template render a two-stge process – should make a *trail* render by writing template into a buffer – if fails, can respond to the user with an error message – works, then write the conents of the buffer to `http.ResponseWriter`.

```go
func (app *application) render(w http.ResponseWriter, r *http.Request, name string, 
                               td *templateData) {
	//...
	buf := new(bytes.Buffer)

	// write the template to the buffer, instead of straight to the writer
	err := ts.Execute(buf, td)
	if err != nil {
		app.serverError(w, err)
		return
	}

	// if all ok, write the contents of the buffer to the writer
	buf.WriteTo(w)
}

```

## Common Dynamic Data

And in some web applications there may be common dynamic data that you want to include on more than one. Just add a new `CurrentYear`field to the `templateData`, like:

Next is to create a new `addDefaultData()`helper to app, which will inject the current year into an instance of a `templateData`struct.

```go
func (app *application) addDefaultData(td *templateData, r *http.Request) *templateData {
	if td==nil {
		td= &templateData{}
	}
	td.CurrentYear=time.Now().Year()
	return td
}
```

## Custom Template Functions

How to create own custom functions to use in Go templates. Create a custom `humanDate()`function which outputs datetimes in a nice – instead of outputting dates. note, there are just two main steps to doing this:

1. need to create a `template.FuncMap`object containing the custom `humanDate()`function.
2. need to use the `template.Funcs()`method to register this before parsing the templates.

```go
func humanDate(t time.Time) string {
	return t.Format("02 Jan 2006 at 15:04")
}

// initialize a template.FuncMap object and store it in a global variable
// essentially a string-keyed map which acts as a lookup between the names
// of our custom template functions and the functions themselves
var functions = template.FuncMap{
	"humanDate": humanDate,
}
```

In the `newTemplateCache`func:

```go
// the FuncMap must be registered with template set before call 
// the ParseFiles() func
ts, err := template.New(name).Funcs(functions).ParseFiles(page)
if err != nil {
    return nil, err
}
```

Then can use this function in the template:

```html
<td>{{.Created | humanDate}}</td>
```

A nice feature of pipelining is that can make an arbitrary long chain of template functons which use the output from one as the input for the next. Like:

```html
<time>{{.Created | humanDate | printf "Created %s" }}</time>
```

# Middleware

When building a web application there is probably some shared functinality that you want to use for many HTTP requests. Fore, might want to log..

A common way of organizing this shared functionality is to set it up as middleware – this is essentially some self-contained code which indepedently acts on a request before or after your normal app handlers.

- An idiomatic pattern for building and using custom middleware which is compatible with `net/http`.
- How to create middleware which sets useful security headers on every HTTP response
- How to create middleware logs the requests received by app
- How to create middleware which **recovers panics** so that are gracefully handled by app.
- How to create and use composable **middleware chains** to help manage and organize middlewares.

## How Middleware works in go

Can just think Go web app as a chain of `ServeHTTP()`methods being called one after another. The basic idea of middleware is to insert another handler into this chain – The middleware handler execute some logic, like logging a request, and then calls the `ServeHTTP`of the *next* handler in the chain.

In fact, are actually already using some middleware – like `http.StripPrefix()`.

### The Pattern

The std pattern for creating your own middleware looks like this:

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResonseWriter, r *http.Request) {
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

- In this func – essentially is a wrapper around the `next`handler.
- It establishes a function `fn`which closes over the `next`to form a closure, and when `fn`is run it executes our middleware logic and then transfers control to the `next`by calling `ServeHTTP`.
- At last, convert this closure to a `http.Handler`and return it using the `http.HandlerFunc()`adapter.

### Simplifying the Middleware

Use an anonymous function to rewrite like:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(...) {
        next.ServeHTTP(w, r)
    })
}
```

Just note that this pattern is very common.

### Positioning the Middleware

And, it’s important to explain – where position the middleware in the chain of handlers will affect the behavior of app. FORE, if before the serveMux in the chain then will act on every request that app receives. A good example for this situation is to log.

Can also position after – by wrapping a specific application handler. cuz your middleware to only the executed for specific routes.

## Setting Security Headers

Put the pattern – make our middleware which automatically adds the following tow headers to every response:

`X-Frame-Options: deny`
`X-XSS-Protection: 1; mode=block`

They essentially instruct user’s *web browser* to implement some additional secruity measures to prevent XSS.

```go
func secureHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-XSS-Protection", "1: mode=block")
		w.Header().Set("X-Frame-Options", "deny")
		next.ServeHTTP(w, r)
	})
}
```

Cuz want this middleware to act on every request that is received, need it to be executed *before* a request hits just like:

`return secureHeaders(mux) // update the signature, func returns a http.Handler`

# Changing a Required One-to-One Relationship

The challenge with a required REL is that you must avoid storing and DEP entity that i not related to a PRIN. And, a required REL is applied in only one direction – the DEPT entity must be related to a PRIN, But, PRIN does not have to be related to a DEPT.

1. When want to change a REL so that a DEPT entity will be related to a PRIN that is not currently in a REL – At the end of the OP, the `Supplier`that the `ContactDetails`was **originally** related to become one of the spares.
2. When want to create a REL to a `Supplier`that is already related to another object. – fore this, can’t leave the existing `ContactDetails`unattached without violating the dbs constraints – so must create a REL with another.

```cs
ViewBag.Suppliers = context.Suppliers.Include(s=> s.Details);
```

This will ensure that a partial view is included in the output when the user edits an obj. Which just provides with the opportunity to present a list of existing `Supplier`object with which a REL can be established.

Using a partial view – Enumerates a seq of `Supplier`objects to present a list to the user - Allowing a `Supplier`to be chosen usnig a radio button that includes a form data value called `targetSupplierId`in the `HTTP POST`request that will be sent to the app – there is also a collection of values, containt the PK of the `Supplier`that are free.

```cs
[HttpPost]
public IActionResult Update(ContactDetails details, 
    long? targetSupplierId, long[] spares)
{
    if(details.Id==0)
    {
        context.Add<ContactDetails>(details);
    }
    else
    {
        context.Update<ContactDetails>(details);
        if (targetSupplierId.HasValue)
        {
            if (spares.Contains(targetSupplierId.Value))
            {
                details.SupplierId=targetSupplierId.Value;
            }
        }
    }
    context.SaveChanges();
    return RedirectToAction("Index");
}
```

## Changing an Optional One-to-One REL

The process is simpler when are working with an optional One-to-One. Don’t have to worry about ensuring that every `ContactDetails`object related to a `Supplier`. Change the entity like:

```cs
public class ContactDetails {
    //...
    public long? SupplierId {get;set;}
}
```

Note that must re-run the migration and update the dbs.

## Defining Many-to-Many Relationships

EF core can be used to create and mange Many-to-Many relationships, where each object of one type can have nonexcluseive relationships within mutliple objects of another type. Add model like:

```cs
public class Shipment
{
    public long Id { get; set; }
    public string? ShipperName { get; set; }
    public string? StartCity { get; set; }
    public string? EndCity { get; set;}
}
```

To keep track of which products have been shipped – going to just create a many-to-many relationship with the `Product`class.

Before Core 5, creating the Junction Class

EF core can represents a mTm by combining two one-many and using a *junction* class to join them together.

```cs
public class ProductShipmentJunction
{
    public long Id { get; set; }

    public long ProductId { get; set; }
    public Product? Product { get; set; }

    public long ShipmentId { get; set; }
    public Shipment? Shipment { get; set; }
}
```

For this, the sole purpose is to acta as a container for two one-many RELs.

### Completing this REL

Means adding NAV props to both the `Product`and `Shipment`just add:

```cs
public class Product {
    //...
    public ICollection<ProductShipmentJunction>? ProductShipments {get; set;}
}

public class Shipment {
    //...
    public ICollection<ProductShipmentJunction>? ProductShipments {get;set;}
}
```

Both of which define NAV props that return `ICollection<ProductShipmentJunction>?`. This already makes nav and data operations more complicated but build on just foundation … then just run re-migration and update-database. Note that will see that two new tables have been added – EF core has detected the new NAV prop on the `Product`class and determined that it needs to store the `ProductShipmentJunction`and `Shipment`objects. The `ProductShipmentJunction`class is the DEPT in both of its relationships.

Each `ProductShipmentJunction`object act as a junction between a `Product`and `Shipment`obj. And the collection of `ProductShipmentJunction`objects returned by the NAV props will provide access to the complete set of related objects, albeit indirectly.

And, to have some data to work with, just added some objects to seed data class.

## Querying for MtM Data

The approach requried for many-to-many RELs has an effect on the way that queries are performed. Like:

```cs
public class Many2ManyController : Controller
{
    private EFDatabaseContext context;
    public Many2ManyController(EFDatabaseContext context)
    {
        this.context = context;
    }

    public IActionResult Index()
    {
        return View(new ProductShipmentViewModel
        {
            Products = context.Products!.Include(p => p.ProductShipments!)
            .ThenInclude(ps => ps.Shipment).ToArray(),
            Shipments = context.Set<Shipment>().Include(s => s.ProductShipments!)
            .ThenInclude(ps => ps.Product).ToArray()
        }); ;
    }
}

public class ProductShipmentViewModel
{
    public ICollection<Product>? Products { get; set;}
    public ICollection<Shipment>? Shipments { get; set;}
}
```

The `Many2ManyController`just defines an Index action – passes a `ProductShipmentViewModel`object to the default view. And write the view just.

# Applying ASP.NET Core Identity

Explain how Core Identity is applied to authenticate users and authorize acces to app features – create the features required for users to just establish their identity, explain how access to endpoints can be controlled, and demonstrate *the security features that Blazor provides*. There are also two different ways to authenticate web service clients – like;

- Using the `SignInManger<T>`class to just validate the credentials users provide and use the built-in middleware to trigger authentication.
- Using the `[Authorize]`attribute and the built-in middleware to control access.
- Use the `[Authorize]`and the built-in Razor componenets to control access.
- Use cookie authentication or bearer tokens.

## Authenticating Users

In the section – show how to add authentication features to the example project so that users can present their credentials and establish their identity to the application.

**AuthN** – Authentication – is the process of establishing the identity of a user – which the user does by presenting their credentials to the application. And **AuthZ** – Authorization – is the process of granting access to the app features based on a user’s identity.

### Creating the Login Feature

To enforce a security policy, the application must allow users to authenticate themselves – which is done using the *Core Identity API* – Create Like:

```cs
public class LoginModel : PageModel
{
    private SignInManager<IdentityUser> signInManager;
    public LoginModel(SignInManager<IdentityUser> signInManager)
    {
        this.signInManager = signInManager;
    }

    [BindProperty]
    public string UserName { get; set; } = string.Empty;

    [BindProperty]
    public string Password { get; set; } = string.Empty;

    [BindProperty(SupportsGet = true)]
    public string? ReturnUrl { get; set; }

    public async Task<IActionResult> OnPostAsync()
    {
        if (ModelState.IsValid)
        {
            Microsoft.AspNetCore.Identity.SignInResult result = await signInManager
                .PasswordSignInAsync(UserName, Password, false, false);
            if (result.Succeeded)
            {
                return Redirect(ReturnUrl ?? "/");
            }
            ModelState.AddModelError("", "Invalid username or password");
        }
        return Page();
    }
}
```

So, Core provides the `SignInManager<T>`class to manage logins, where the generic type argument `T`is the class that presents users in the app. has:

- `PasswordSignInAsync(name, password, persist, lockout)`– attempts authenticate using the specified username and password – `persist`determines whether a successufl auth produces a **cookie** that persists after the browser closed, and the `lockout`determines whether the account should be locked if fails.
- `SignOutAsync()`– 

The RPs presents the user with a form.

The result from the `PasswordSignInAsync()`is a `SignInResult`– defines a `Succeed`that is `true`if authentication is successful, and if just failed, the page is redisplayed.

## Inspecting the ASP.NET Core Identity Cookie

When a user is authenticated, a cookie is added to the *repsonse so that subsequent requests* can be identified as being already authenticated. Just add a Page `Details`displays the cookie – 

```cs
public class DetailsModel : PageModel
{
    public string? Cookie { get; set; }
    public void OnGet()
    {
        Cookie = Request.Cookies[".AspNetCore.Identity.Application"];
    }
}
```

### Creating a Sign-out Page

It is just important to give users the ability to sign out so they can *explicitly delete the cookie*, especially if public machines may be used to access the app. just like:

```cs
public class LogoutModel : PageModel
{
    private SignInManager<IdentityUser> SignInManager;
    public LogoutModel(SignInManager<IdentityUser> signInManager)
    {
        SignInManager = signInManager;
    }
    public async Task OnGetAsync()
    {
        await SignInManager.SignOutAsync();
    }
}
```

Just note that when logout, the cookies are deleted.

## Enabling the Identity Authentication Middleware

Core Identity provides a middleware component that detects the cookie created by the `SignInManager<T>`class and populates the `HttpContext`object with details of the authenticated user. This just provides endpoints with details about the user without needing to be aware of the authentication process or having to deal directly with the cookie created by the authentication process.

`app.UseAuthentication();`

The middleware sets the value of the `HttpContext.User`prop to a `ClaimsPrincipal`object. *Claims* are pieces of info about a user and details source of that info – providing a general-purpose approach to describing the info known about that user.

The `ClaimsPrincipal`class is part of the Core and note that isn’t directly useful in the Core applications – but there are two nested properties that are useful in most apps – 

- `ClaimsPrincipal.Idenity.Name`– This prop returns the username, will be `null`if there is no user associated to the current request.
- `ClaimsPrincipal.Identity.IsAuthenticated`-- return `true`if the user associated with the current request has been authenticated.

So edit the `Details`RP:

```cs
public class DetailsModel : PageModel
{
    private UserManager<IdentityUser> _userManager;
    public DetailsModel(UserManager<IdentityUser> userManager)
    {
        _userManager = userManager;
    }

    public IdentityUser? IdentityUser { get; set; }

    public async Task OnGetAsync()
    {
        if (User.Identity != null && User.Identity.IsAuthenticated)
        {
            IdentityUser = await _userManager.FindByNameAsync(User.Identity.Name);
        }
    }
}
```

So the `HttpContext.User`prop can be accessed through the `User`*convenience prop* defined by the `PageModel`and `ControllerBase`classes. This RP confirms that there is an authenticated user assocaited with the request and gets the `IdentityUser`object that describes the user.

Just in the `OnInitializedAsync()`– added a fair amount of code. One extra feature is the breadCrumb section at the top of the page. This is to allow easy navi. like:

```html
<nav aria-label="breadcrumb">
	<ol class="breadcrumb-item">
        <a href=...>Home</a>
    </ol>...
</nav>
```

## Handling multiple routes with a single Component

It’s just possible to have a single component be responsible for mutliple routes – this can be useful for several.. Going to just add a max length filter to page. This will allow the user to limit search restuls to trails that have a length less then or equal to its value. Add some addition directive to the `SearchPage`.

`@page "/search/{searchTerm}/maxlength/{MaxLength:int}"` This is called a *route constraint*. Are important when dealing with route parameteters that need to be worked with as a nonstring type. Can tell Blazor that the value in that route parameter must be converted to an integer by using the `:int`route constraint.

Just create a new Component named `SearchFilter`like:

```cs
@code {
    private int _maxLength;

    [Parameter, EditorRequired]
    public string SearchTerm { get; set; } = default!;

    private void FilterSearchResults()
        => NavManager.NavigateTo(
            $"/search/{SearchTerm}/maxlength/{_maxLength}");

    private void ClearSearchFilter()
    {
        _maxLength = 0;
        NavManager.NavigateTo($"/search/{SearchTerm}");
    }

}
```

```scss
.filters{
  display:flex;
  margin-bottom: 20px;
  align-items: baseline;
  justify-content: flex-end;
  
  label{
    text-transform: uppercase;
    margin-left: 10px;
  }
  
  input{
    margin-right: 20px;
    width:100px;
  }
  
  button:first-of-type{
   margin-right:10px; 
  }
}
```

And the last is to implement the filtering functionality – just as:

```cs
[Parameter]
public int? MaxLength { get; set; }

private IEnumerable<Trail> _cachedSearchResults = Array.Empty<Trail>();

protected override void OnParametersSet()
{
    if (_cachedSearchResults.Any() && MaxLength.HasValue)
    {
        _searchResults = _cachedSearchResults
            .Where(x => x.Length <= MaxLength.Value);
    }else if (_cachedSearchResults.Any() && MaxLength == null)
    {
        _searchResults = _cachedSearchResults;
    }
}
```

When enter a filter, the URL is updated but the `SearchPage`component is **not** destroyed and re-created. When changing routes, Blazor performs a diff just like it would with any other UI update. In our case, navigating to the same component that is already rendered. the `OnInitialized`life cycle – executes only once in a component’s life cycle.

## Working with query strings

For route matching, only works when all segments are present – so if th user just selects only .. With query strings, can just include as many as few k-v pairs as wish. Note:  Before .NET 6, working with query string in Blazor is completely manual process. With .NET 6, two important features were added that make working with query string a breeze – `SupplyParameterFromQuery`attribute and the query-string helper methods.

```html
<label for="maxTime">Max Time (hours)</label>
<input id="maxTime" type="number" class="form-control"
       @bind="_maxTime" />
```

With the ability to record the max time from the user, can update the `FilterSearchResults`to add query-string values instead of parameters. like:

```cs
private void FilterSearchResults()
{
    var uiWithQueryString =
        NavManager.GetUriWithQueryParameters(
            new Dictionary<string, object?>()
            {
                [nameof(SearchPage.MaxLength)] =
                    _maxLength == 0 ? null : _maxLength,
                [nameof(SearchPage.MaxTime)] =
                    _maxTime == 0 ? null : _maxTime
            });
    NavManager.NavigateTo(uiWithQueryString);
}
```

Using the `GetUriWithQUeryParameters`method to consturct a new URI, containing a query string. This one will return the current URI with the supplied k-v pairs attached as a query string. By setting value to `null`, will be ignored when the query string is built.

### Retrieving query-string values using `SupplyParameterFromQuery`

In the `SearchPage.razor`:

```cs
[Parameter, SupplyParameterFromQuery]
public int? MaxLength { get; set; }
[Parameter, SupplyParameterFromQuery]
public int? MaxTime { get; set; }
```

```cs
private void UpdateFilters()
{
    var filters = new List<Func<Trail, bool>>();
    if (MaxLength is not null && MaxLength > 0)
    {
        filters.Add(x=>x.Length<=MaxLength);
    }

    if (MaxTime is not null && MaxTime > 0)
    {
        filters.Add(x=>x.TimeInMinutes<= MaxTime*60);
    }

    if (filters.Any())
    {
        _searchResults = _cachedSearchResults
            .Where(trail => filters.All(filter => filter(trail)));
    }
    else
    {
        _searchResults = _cachedSearchResults;
    }
}
```

Just need call this method at the appropriate time. **A query-string values are handled just in the same way as any other parameters**. So `OnParametgersSet`used. Just:

```cs
protected override void OnParametersSet()
    => UpdateFilters();
```

Also, need to pass in any existing search filters from the `SearchPage`to the `SearchFilter`. Add new parameter for each of the filters to the `SearchFilter`. just: 

1. define `[Parameter]`for `SearchPage`as parameters
2. write the `OnInitialized()`set the `_maxLength`to the parameters.
3.  `<SearchFilter SearchTerm="@SearchTerm" MaxLength="MaxLength" MaxTime="MaxTime"/>`

# Higher-order Observables

It is necessary to handle Observable *of* Observables – so-called higher-order-Observables. like:

```ts
const fileObservable = urlObservable.pipe(map(url=>http.get(url)));
```

For this, `http.get()`return an observable for each individual URL, typically, by *flattening* – converting a high-order into an ordinary Observable like:

```ts
const fileObservable = urlObservable.pipe(
map(url=>http.get(url)), concatAll() );
```

For this, the `concatAll()`operator subscribes to each inner that comes out of the outer `Observable`, and copies all the emitted values until Observable completes. Others:

- `mergeAll()`– subscribes to each inner, then emits each value as it arrives.
- `switchAll()`-- subscribes to the first inner, and emits each value as it arrives, when next arrives, unsubscribe to previous.

A subscription essentially just has an `unsubscribe()`to release resources or *cancel* observable executions.

## Subject

An RxJS `Subject`is a special type of `Observable`that allows values to be multicasted to many observers. A `Subject`is just like an `Observable`, can multicst to many observers, and like `EventEmitter`s, they maintain a regstry of many listners.

Every Subject is an Observable – Can `subscribe`to it – providing an `Observer`, which will start receiving values normally, From the perspective of the `Observer`it cannot tell whether the `Observable `execution is coming from a plain unicast `Observable`or a Subject. FORE:

```ts
const subject = new Subject<number>();

subject.subscribe({
    next: v => console.log(v),
});
subject.subscribe({
    next: v=>console.log('another', v),
})

subject.next(1);
subject.next(2);
```

Since a `Subject`is just an `Observer`, it is an object with `next(v), error(e)`and `complete()`. fore:

```ts
from([1, 2, 3])
    .subscribe(subject);
```

# Using the Forms API Part 1

The forms API is a more complicated way of creating forms, it allows fine-grained control over how forms behave, how they respond to user interaction, and how they are validated.

`FormControl`and `FormGroup`objects are created by component class and associated with elements in the template using directives.

- Creating a reactive form – `FormControl`object in the component class and associate it with a form element in the template using the `formControl`directive.
- Responding to element value changes – Use the observable `valueChanges`prop defined by the `FormControl`
- Responding to validation changes – `statusChanges`prop
- Defining related form elements – Use a `FormGroup`
- Displaying validation messages – obtain a `FormControl`through enclosing `FormGroup`.

## Understanding the Reactive Forms API

For more complex forms, Ng provides a complete API that exposes the state of the HTML forms and allows their data and structure to be managed.

```html
<form #form="ngForm" (ngSubmit)="submitForm(form)" (reset)="form.resetForm()">
    ...
</form>
```

For `ngForm`which is a directive that acts as a wrapper around a `FormGroup`object, just exposing its capabilities using the directive features. The `FormGroup`– provides an API for working with a form and can be used directly in a componetn class, allowing forms to be manipulated in code and not just through HTML in a template. In turn, the `FormGroup`is just a container for `FormControl`objects, each of which represents an element in the form.

## Rebuilding the Form Using the API

```html
<input class="form-control" name="name" [formControl]="nameField">
```

The `formControl`directive creates the relationship between HTML in the template and the component. Individual form controls are representd by `FormControl`props , in the component defined a prop `formControl`. named `nameFiled`. For the `Initial Value`string – jsut presented to the user.

`this.nameField.setValue(this.product.name)`.

`value, setValue, enabled, disabled`

`valueChanges`– returns an `Observable<any>`, through changes can be observed

`enable(), disable(), reset(value)`

### Responding to Form Control Changes

The `valueChanges`prop returns an observable that emtis new values from the form control. Like:

```ts
ngOnInit() {
    this.nameField.valueChanges.subscribe(newValue => {
        this.messageService.reportMessage(new Message(newValue || "(Empty)"));
    });
}
```

In the `ngOnInit`method, the component just subscribes to the `Observable<any>`returned by the `valueChanges`prop and passes on the values it receives to the message service. And, by default, the observable will emit a new event in response to the HTML element’s `change`event, but can also be altered, by configuring the `FormControl`with ctor arg like:

```ts
nameField: FormControl = new FormControl("Initial Value", {
    updateOn: "blur",
});
```

This new arg to the `FormControl`ctor implements the `AbstractControlOptions`interface – defines the props:

- `validators`-- used to configure the validation for the form control
- `asyncValidators`– async valiation
- `updateOn`– configure when the `valueChanges`observable will emit a new value.

Producers - are the sources of data, A stream must always have a producer of data, which will be the starting point for any logic that you will perform in RxJS.

Consumers – When the consumer begins listening to the producer for events to consume – U now have a stream.

## Managing Async Events

```ts
.subscribe(
	function next(val) {...},
    function error(err) {...},
    function done() {...}
)
```

Observer Patterns – based on two main roles – a publisher, and a subscriber. And a publisher just maintains a list of subscribers and notifies them or propagates a change.

RxJS combines the *observer pattern with the iterator pattern and functional programming* to process and handle async events. It is just crucial to understand when to put a reactive implemenation in place and when to avoid it.

The event emitter, which is part of the core package, is used to emit data from a child to a parent through the `@output()`decorator. like:

```ts
// in the child component
export class RecipesComponent {
    @Output() updateRating= new EventEmitter();
    updateRecipe(vlaue:string){
        this.updateRating.emit(value);
    }
}
```

## Managing Async Events

`ajax`is another helper ctor, – this one performs an AJAX request – it returns an observable for a single value – whatever the AJAX request returns – fore:

### Managing Control State

### Accepting Inputs

ng will look at the file `angular.json`to find the entry point to our app. At a high level – looks just like:

- `angular.json`just specifies the `main`file, which in the case is `main.ts`
- `main.ts`is the entry point for app and *bootstrap* our application
- The bootstrap process boots an Angular module
- Use the `AppModule`to bootstrap the app
- `AppModule`specifies which *component* to use as the top-level component, this case, `AppComponent`

declarations – specifies the components that are defined in this module. This is an important idea in Angular – Have to declare components in `NgModule`before U can use them in templates. Can also think of an `NgModule`a bit like a *package* and declarations state what components are owned by this module.

### imports

Describes which *dependencies* this module has. Fore, creating a browser app, so need to import the `BrowserModule`.

### bootstrap

tells that when this module is used to bootstrap an app, need to load the `AppComponent`as top-level component.

```html
<div class="mb-3">
    <label class="form-label" for="title">Title</label>
    <input name="title" id="title" class="form-control" #newtitle/>
</div>

<div class="mb-3">
    <label for="link">Link:</label>
    <input name="link" id="link" class="form-control" #newlink/>
</div>

<button class="btn btn-primary btn-sm" (click)="addArticle(newtitle, newlink)">
    Submit link
</button>
```

Notice that in the `input`, used the `#`to just tell Ng to assign this tgs to a *local* variable. Can pass them as *variable* into the function. `newtitle`now is an object that represents this `input`DOM element. so can get its `value`. So for now its type is just `HTMLInputElement`.

`<p>{{newtitle.value}} {{newlink.value}}</p>`
