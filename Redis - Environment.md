# Redis - Environment

In Redis, there is a configuraiton file (redis.conf) available at the root directory of Redis -- 

```sh
CONFIG GET loglevel
```

## Data types

Resids supports 5 types of data types just:

### strings

is a sequence of *bytes* -- binary safe meaning they have a known length not determined by any special terminating characters. Thus, can store anything up to 512M in one string --

```sh
set name "turorialsponit"
get name
```

For this, `SET`and `GET`are just redis commands, and `name`is the key used in Redis and `turorialspoint`just the string value that is stored in Redis

Store a serialized JSON string, and set its expire 100 seconds form now:

```sh
set ticket:27 "\"{'username':'priya', 'ticket_id': 321}\"" EX 100
```

`set key value`

### Hashes

A Redis Hash is a collection of k-v pairs -- Redis Hashes are just maps between string fields and string values.

Options -- In `SET`command there are many options available, that modify the behavior of command

- EX seconds -- specified expire time, in seconds
- PX milliseconds -- set specified expire time, in milliseconds
- NX -- only set the key it does not already exist
- XX -- only set the key if it already exist

```sh
SET weresource redis ex 60 nx
```

## Type approximations

Need a new kind of type element, -- *type approximation*, write it using the ~ character like:

```go
type ApproximatelyInt interface {
    ~int
}
```

The type of `~int`includes int itself, but also any type whose underlying type is `int`, fore `MyInt`, which is good, even better, it will accept *any* type, now or in the future.

Note that the type set of `~int`includes `int`itself, but also any type whose underlying type is `int`.

So, Approximations are especially useful with struct type elements, like:

```go
type Pointish interfaec{
    struct {x, y int}
}
```

Fore, write a generic function with this constraint -- 

```go
type Pointish interface {
	~struct{ x, y int }
}

func Plot[T Pointish](p T) {

}
```

If add that like:

` type Pointish interface {~struct {x, y int}}`

### Intersections

with a classic interface, a type must have *all* of the methods listed in order to implement that interface. And if the interface contains other interfaces,  a type must implement *all* of those interfaces. fore:

```go
type IntStringer interface {
    ~int
    fmt.Stringer
}
```

To implement this, a type must implement both `~int`and `Stringer`, For this, just note that the built-in `int`doesn’t have a `String`method, so `int`itself couldn’t satisfy this constraint, but cuz we used the approximation token `~`, types just dervied from `int`would be just ok.

## The `constraints`package

In order to write generic functions using +, fore, now know how to specify appropriate constraints -- fore, could include all the built-in signed and unsigned integer types.. fore:

```go
type Integerish interface {
    ~int | ~int8...
}
```

And, there a just a couple of problems with this -- 

1) wouldn’t want to have to include it in every program..
2) not-ruture-proof -- If a new integer type were introduced to Go..

There is just a new official package called `constraints`which solve this problem. -- It’s not in the Go STDLIB. There are just some other handy constraints defined in the `constraints`pacakge including:

- `Signed/Unsigned`
- `Integer/Float`
- `Complex/Ordered`

### Constraint Literals

An interface literal, just `interface{}`.. empty -- `any`is an alias for `interface{}`, so would be able to use an empty interface literal wherever `any` is just allowed.

Can do more, we are not restricted to *empty* interface literals, can write an interface literal containing some methods like:

```go
func Stringify[T interface{String() string}] (s T) string {
    return s.String()
}
```

### Omitting `interface`

And, we are not limited to just method elements in interface used as constratints -- can use elements too:

`[T interface{~int}]`

And conveniently, in this case, can omit the enclosing `interface{...}`, just write like:

`[T ~int]`

Fore, could write some function `Increment`constrained to types just derived from `int`like:

```go
func Increment[T ~int](v T) T {
    return v+1
}
```

Note, however, we could write some function `Increment`constrined to types derived from .. Exectly contains **one type element** -- multiple elements couldn’t be allowed. so this doesn’t work like:

```go
func Increment [T ~int; ~float64] (v T) T {//... error}
```

And, jsut can’t omit `interface`with method elements either.

## any says nothing

In go, an interface type that specifies zero methods is known as the empty interface. `interface{}` With go 1.18, the predeclared type `any`became an alias for an empty interface - hence, In assigning a value to `any`type, we lose all type info -- which requires a type **assertion** to get anything useful out of the `i`variable. fore, in the following, implement a `Store`struct and the skeleton of two methods. like:

```go
type Customer struct{}'
type Contract struct{}
type Store struct{}
func (s *Store) Get(id string) (any, error) {}
func (s *Store) Set(id string, v any) error {}
```

Note, although there is nothing wrong with `Store`-- should think aoubt the method signatures -- cuz we accept and return `any`args, the methods lack expressiveness. If future developers need to use the `Store`struct, will probably have to dig into the documentation or read the code.

Hence, accepting or returning an `any`type doesn’t convey meaningful info. Also, cuz there is no safeguard at compile time, nothing prevents a caller from calling these methods with whatever type, fore, `int`.

What are the cases when `any`is helpful -- in the STDLIB and see two examples where functions or methods accept `any`args -- fore, `encoding/json`package -- cuz we can **marshal any type**, the `Marshal`accepts `any`like:

`func Marshal(v any) ([]byte, error)`

Another example is the `database/sql`package -- if the query is parameterized -- the parameters could be any kind.

```go
func (c *Conn) QueryContext(ctx context.Context, query string, args ...any) (*Rows, error){}
```

In summary, `any`can be helpful if there is a genuine need for accepting or returning any possible type, in general, we should just avoid overgenerializing the code.

## Being confused about when to use generics

In the nutshell, generics allow writing code with types that can be just specified later and instantiated when needed. However, it can be confusing about when to use generics and when not to.

### Concepts

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k := range m {
        keys= append(keys, k)
    }
    return keys
}
```

So, what if want to use a similar feature for another map type such as a `map[int]string`-- Before generics, Go developers had a few options -- using code generation, reflection, or duplicating code. FOR, could write two functions, one for each map type, or even try to extend the `getKeys()`to accept different map types like:

```go
func getKeys(m any) ([]any, error) {
    switch t := m.(type) {
    default:
        return nil, fmt.Errorf(...)
    case map[string]int:
        var keys []any
        for k := range t {
            keys= append(keys, k)
        }
        return keys, nil
    case map[int]string:
        //...
    }
}
```

With this, start to notice a few issues -- it increases boilerplate code -- It requires duplicating the `range` -- meanwhile, the func now accepts an `any`which means lose some of the benefits of Go as a static lang. Hnce, also need to return an error if the provided type is just unknown. -- cuz the key type can be either `int`or `string`, are obliged to return a slice of `any`to factor out key types.

This approach increases the effort on the caller side, cuz the client may also need to perform a type check. For type parameters - can use with functions and types fore:

`func foo[T any] (t T)`

When just calling `foo`, pass a type arg of `any`-- Supplying a type arg is called instantiation. Just change it to:

```go
func getKeys[K comparable, V any](m map[K]V) []K {
    var keys []K
    for k := range m {
        keys = append(keys, k)
    }
    return keys
}
```

To handle the map, defined two kinds of type parameters -- Just note in Go, the map’s keys can’t be of the `any`type. Insted of accepting `any`key type, obliged to restrict type args so that the key type meets specific requirements -- defined as `comparable`instead of `any`.

Restricting type arg to match specific requirements is called *constraints*, and a constraint is just an `interface`type that can contain - 

- methods
- types

So, check out a concrete example -- can:

```go
type customConstraint interface {
    ~int | ~string
}
func getKeys [K customConstraint, V any] (m map[K]V) []K {
    //...
}
```

For this, defined a `customConstraint`interface to to restrict the types to be eigher `int`or `string`using the union operator. Can:

```go
m = map[string]int {
    "oen": 1,...
}
keys := getKeys(m)
// note go can infer the argument so equal to 
keys := getkeys[string](m)
```

However, can also use generics with data structures, fore, can create a linked list containing values of `any`type. fore:

```go
type Node[T any] struct {
    Val T
    next *Node[T]
}
func (n *Node[T]) Add(next *Node[T]) {
    v.next=next
}
```

# User Authorization

1. Only authenticated users can create new
2. The content of the NAV bar changes depending on whether a user is authenticated (loggd in) or not.

Note, mentioned can, check whether a request is being made by an authenticated user or not by checking the existence of an `authenticatedUserID`value in its session data. check for that:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
    return ap.session.Exists(r, "authenticatedUserID")
}
```

Need to find a way to pass this info to our HTML templates, just:

```go
type templateData struct {
    //...
    IsAuthenticated bool
}
//...
func (app *application) addDefaultData (td *templateData, r *http.Request) *templateData {
    //...
    td.IsAuthenticated = app.isAuthenticated(r)
}
```

Once that is done, can update the template file to toggle the nav links.

## Restricting access

An unauthenticated user could still create a new snippet by visiting the `/create`page directly. Fix that -- just redirect to the `/user/login`instead, if an unauthenticated user visit the route `/create` - The simplest way to do that is via some middelware -- so, in the `middleware.go`file add:

```go
func (app *application) requireAuthentication(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// if the user is not authenticated, redirect to the login page
		// and return from the middleware chain, and no further middleware executed
		if !app.isAuthenticated(r) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
			return
		}

		// otherwise, set the "Cache-Control: no-store"
		// the pages require authentication are not stored in the user browser cache
		w.Header().Add("Cache-Control", "no-store")

		// and call the next handler in the chain
		next.ServeHTTP(w, r)
	})
}
```

The `Cache-control`is just an HTTP header used to specify *browser caching* policies in both client requests, and the server response -- `no-store`means browsers are not allowed cache a response and must pull it from the server each time requested -- this setting is usually used for **sensitive data**.

... 

Can then add the middleware to our `routes.go`file to protected specific routes. In our case, want to just protect the `GET /snippet/create`and `POST /snippet/create`, so makes sense to use it on the `POST /user/logout`as well.

So in the routes.go file:

```go
// add the requireAuthentication middleware to the chain
mux.Get("/snippet/create", dynamicMiddleware.Append(
    app.requireAuthentication).ThenFunc(app.createSnippetForm))
// also add the AuthC middleware to post
mux.Post("/snippet/create", dynamicMiddleware.Append(
    app.requireAuthentication).ThenFunc(app.createSnippet))
```

## CSRF protection

In this, look at how to protect our app from **Cross-Site Request Forgery** attacks. If are not familar -- it is a form of cross-domain attack where a malicious third-party website sends state-changing http requests to your web site.

But in our app, the main risk is this:

- A user logs into our app, our session cookie is set to persist for 12 hours, so they will remain logged in even if away from the app.
- The user then goes to amalicious website -- contains some code that sends to a requst to `/create`page, and a new snippet will be added

### SameSite Cookies

And one mitgation that can take to prevent CSRF attack is to make sure that the `SameSite`attribute is set on our session cookie - By default, the `session`package that we are using always just set the `SameSite=Lax` on the session cookie -- This just means that the session cookie *won’t* be sent by the user’s browser for cross-site usage.

Using the `SameSite=Strict`will block the session cookie being sent by the user’s browser for all cross-site usage. Can’t rely -- cuz 85% browsers... supported.

### Token-based Mitgation

So, to mitigate the risk of CSRF, also need to implement some form of `token check`-- Like session management and password hashing -- using just package -- `gorilla/csrf`and `justinas/nosurf`-- Using the **Double Submit Cookie Pattern** to prevent attacks. In this pattern, a random CSRF token is generated and sent to the user in a CSRF cookie -- This token is then added to a hidden field in each form that is vulnerable to CSRF. And when the form is submitted, both packages use some middleware to check that the hidden f*ield value and cookie value match*.

For this example, just using the `justinas/nosurf`-- cuz it’s just self-contained, doesn’t have any additional dependencies -- So just like:

```sh
go get github.com/justinas/nosurf
```

## Preparing the Login Partial View

The Identity UI package requires a partial view named `_LoginPartial`which is displayed at the top of every page. And in a self-service app, it is just the responsibility of the user to create an account.

### Managing the Account

The basic configuraiton is comlete – several features require just additional work before correctly. Just replace the placeholder content like:

```html
<nav class="nav">
    @if (User.Identity.IsAuthenticated)
    {
        <a asp-area="Identity" asp-page="/Account/Manage/Index"
           class="nav-link bg-secondary text-white">
            @User.Identity.Name
        </a>
        
        <a asp-area="Identity" asp-page="/Account/Logout"
           class="nav-link bg-secondary text-white">
            Logout
        </a>
    }
    else
    {
        <a asp-area="Identity" asp-page="/Account/Login"
           class="nav-link bg-secondary text-white">
            Login/Register
        </a>
    }
</nav>
```

For this, the `@if`expression in the partial view determiens whether there is a signed-in user by reading the `User.Identity.IsAuthenticated`prop. Core represents users with the `ClaimsPrincipal`class and this object for the current user is available through the `User`prop defined by the `Controller`and `RazorPageBase`classes – which – the same feature are available for the MVC and Rps.

The `asp-area`and `asp-page`work together to create link for the Index Rp in the `Account/Manage`folder of the Identity UI package. so need to know the name of the pages that provide key features.

### Creating a Consistent Layout

The Identity UI package is a collection of RPs set up in a separate ASP.NET core area. This also means that a proj can just override individual files from the Identity UI package by just creating RPs with the same names. Show you how this can be used to adapt the Identity UI func in later – simplest use of this feature is to provide a consistent layout will be used *for both content and UI package*.

Create the `_CustomIdentityLayout`view:

```html
<body>
<nav class="navbar navbar-dark bg-secondary">
    <a class="navbar-brand text-white ms-2">IdentityApp</a>
    <div class="text-white"><partial name="_LoginPartial" /></div>
</nav>
<div class="m-2">
    @RenderBody()
    @await RenderSectionAsync("Scripts", required:false)
</div>
</body>
```

For this contains includes content renedered byt the `_LoginPartial`. And to use this, just creates the `Areas/Identity/Pages`folder and add it to the Razor View Start file.

### Configuring Confirmations

And a confirmation is an email message that asks the user to click a link to confirm an action, such as creating an account or just changing a pwd. For this, just provided a simplified confirmation process that requires an implementation of the `IEmailSender`interface just – `SendEmailAsync()`needed. And the Identity UI package just includes an implementation of the interface whose method does nothing.

For now, create the `IdentityApp/Services`and add it a class file `ConsoleEmailSender`.

```cs
public class ConsoleEmailSender : IEmailSender
{
    public Task SendEmailAsync(string email, string subject, string htmlMessage)
    {
        Console.WriteLine("---New Email---");
        Console.WriteLine($"To: {email}");
        Console.WriteLine($"Subject: {subject}");
        Console.WriteLine(HttpUtility.HtmlDecode(htmlMessage));
        return Task.CompletedTask;
    }
}
```

And need to add this service to the program.cs file like:

`builder.Services.AddScoped<IEmailSender, ConsoleEmailSender>();`

To use this to test, just change the email – The message contains a link for the user to click to confirm their new email.

### Displaying QR Codes

Identity provides support for two-factor authentication – where ther user has to present additional credentials to sign into the app – The Identity UI package supports a specific type of additional credential – which is a code generated by an authenticator app. An authenticator app is set up once and then generates authentication codes that can be validated by the app. To complete the set up for authetnicators with Identity UI, a third-party Js lib named `qrcodejs`is requried to generate QR codes that can be scanned by mobile devices to simplify the initial set up process. After installation, adding script in the `_CustomIdentitylayout`

```js
let element = document.getElementById("qrCode");
if (element !==null){
    new QRCode(element, {
        text: document.getElementById("qrCodeData").getAttribute("data-url"),
        width:150, height:150
    });
    element.previousElementSibling?.remove();
}
```

If element exists, it is used to create a QR code image using the `qrcodejs`package.

```cs
public class IndexModel : PageModel
{
    public string Result { get; set; } = string.Empty;

    public void OnGet(string searchTerm)
    {
        Result = string.IsNullOrEmpty(searchTerm)
            ? "" :
            $"Your search for <i>{searchTerm}</i> did not yield results";
    }
}
```

```html
<h1>Search</h1>

<div class="row">
    <div class="col-md-12">
        <form method="get">
            <div class="mb-3">
                <label class="form-label" for="searchTerm"></label>
                <input id="searchTerm" name="searchTerm" class="form-control"/>
            </div>

            <div class="mb-3">
                <input type="submit" id="btn" value="Search" class="btn btn-primary"/>
            </div>
        </form>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        @Html.Raw(Model.Result)
    </div>
</div>
```

The search term appears on the page – if it’s a `<script>`with some code – In this case of this attck, the search term contained angle bracket – The browser did interpret the search term as `HTML`markup. For the attacker, successfully injected Js code, and have cross-site scripting.

And a little more complicated example : 

```html
<div class="row">
    <div class="col-md-4">
        <form>
            <div class="mb-3">
                <label class="form-label" for="searchTerm"></label>
                <input id="searchTerm" class="form-control" />
            </div>

            <div class="mb-3">
                <input type="button" id="btn" value="Search" class="btn btn-primary" />
            </div>
        </form>
    </div>
</div>

<div class="row">
    <div class="col-md-4">
        <ul class="list-group" id="results"></ul>
    </div>
</div>

<script>
    document.getElementById("btn").onclick = () => {
        let list = document.getElementById("results");
        list.innerHTML = "";
        let searchTerm = document.getElementById("searchTerm").value;

        fetch("/Home/SearchAPI?searchTerm=" + encodeURIComponent(searchTerm))
            .then(response => response.json())
            .then(data => data.forEach(item => {
                let li = document.createElement("li");
                li.className = "list-group-item";
                li.innerHTML = item;
                list.appendChild(li);
            }));
    }
</script>
```

For this – even though the search term contains a `<script>`tag – the browser does not execute it after it is dynamically added to the browser by using URL.

`https://localhost:7225/home/SearchApi?searchTerm=%3Cscript%3Ealert(%27hacked!%27)%3C/script%3E`

And the js code is once again executed. In the end, the browser just sends a POST request to page, with XSS payload, and the attack is successful.

### Types of cross-site scripting

The two main ones are as follows:

1. Stored cross-site scripting – called persistent XSS – where the web app stores jsut the malicious Js code – every user is now a potential victim.
2. Reflected cross-site scripting – also called non-persistent XSS, where the malicious Js code is part of the HTTP request and then appears in the HTTP response.

## preventing cross-site scripting

The best way to understand the danger of getting someone else’s Js code injected in your page is to look at the security feature that js has – the **same-origin policy** – SOP.

### Understanding the SOP

SOP dictates that Js code has access only to elements that have the same origin as the code. The term *origin* just is defined by the IEFT - 

- Scheme
- Fully qualified domain name
- and port

If all 3 pieces of info are identical, the origin is the same. And the term *origin* is not always intutive , Fore, a web page residing on `https://example.com`that contains 3 `<script>`

- one just inline
- one referencing a js file on the same server as the current HTML page
- One referencing js lib from CDN, fore.

For the third, the js library would have a different origin than the current HTML page. But if that is the case, the js lib would have a different origin than the current html p

# Getting started with Routing

URL routing adds structure to an app using a natural and well-understood aspect of web apps – the URL.

### Creating a Routing Configuration

The first step when applying routing is to define the *routes* – are mapping between URLs and the component that will be displayed to the suer. like:

```ts
const routes: Routes = [
    {path: "form/edit", component: FormComponent},
    {path: "form/create", component: FormComponent},
    {path: "", component: TableComponent},
];
export const routing = RouterModule.forRoot(routes);
```

The `Routes`class just defines a collection of routes – each of which tells Ng how to handle a specific URL. `path`just specified relative to the rest of the app, which means that the configuration.

Note that the routes are packaged into a module using the `RouterModule.forRoot()`-- the method produces a module that including the routing service.

`path, component, pathMatch [full | prefix], redirectTo, children, outlet, resolve`
`canActivate, canActivateChild, canDeactivate, loadChildren, canLoad`

### Creating the routing Component

When using routing, the root component is just dedicated to managing the nav between different parts of the app. This is the typical purpose of the `app.component.ts`file that was added to the proj by the `ng new`command when it was created. In this:

```html
<paMessages></paMessages>
<router-outlet></router-outlet>
```

So, for the purposes of routing, it is the `router-outlet`element – known as the *outlet*– that is just important cuz it tells Ng that this is where the component *matched by the routing configuraion* should be just displayed.

### Updating the root Module

Next, to update the root module so that the new root component is used to bootstrap the app.

```html
<button class= "..." (click)=... routerLink="/form/edit">
    Edit
</button>
```

The `routerLink`attribute applies a directive from the routing package that perform the navigation change. And the routing links added to the table component’s template, will allow the user to navigate to the form, and For cancel:

```html
<button type="reset" class="..." routerLink= "/">
    Cancel
</button>
```

Need to note in the `core.module.ts`file, add imports:

```ts
imports : [..., RouterModule],
```

## Completing the routing Implementation

Adding routing to the app is good start, but a lot of the app features just don’t work. For now, clicking an edit displays the form, but not work ..

### Handling Route Changes in Components

The form component isn’t work cuz it *isn’t being notified* that the user has clicked a button to edit a product – This occurs cuz the routing system creates new instances of Componetn classes only when it needs them, which means that the `FormComponent`object is created only after the `Edit`is clicked.

This leads to a timing issue in the way that the product component and the table component communicate, via the `Subject`. A `Subject`only passes events to subscribers that arrive after the `subscribe()`has been called. But the introduction of routing means that the `FormComponent`is created after event describing the edit operation already have been sent.

The problem will be solved by replacing the `Subject`with a `BhaviorSubject`– sends the most recent event to subscribers when they call the subscribe method. But – the best way - is to use the URL to collaborate between components.

Angular provides a service that components can *receive to get details of the current route*. The relationship between the service and the types that it provides access to may seem complicated – 

The class on which component declare a dependency is called `ActivateRoute`-- it defines one important prop – 

- `snapshot`– this returns an `ActivateRouteSnapshot`that describes the current route – provides information about the route that lead to the current component being displayed to the user using the properties:

The basic properties – 

- `url`– returns an array of `UrlSegment`– each of which describes a single segment in the URL.
- `params`– returns a `Params`which describes the URL parameters
- `queryParams`-- also a `Params`
- `fragment`– returns a string containing the URL fragment

And the `url`prop is jsut the one important for this cuz it allows the component to inspect the segments of the current URL and extract the info from them that is required to perform an operation. And returns `UrlSegment`provides the properties – 

- `path`– returns a string that contains the segment values
- `parameters`– returns an indexed collection of parameters.

To determine what route has been activated by the user, the form component can just declare a dependency on `ActivateRoute`and then use the object it receives to inspect the segments of the URL.

```ts
constructor(private model: Model, activeRoute: ActivatedRoute) {
    this.editing = activeRoute.snapshot.url[1].path == "edit";
}
```

The component no longer need the shared state service to receive events – instead, it inspects the second segment of the active route’s URL to set the value of the `editing`prop, which just determines whether it should display its create or edit mode.

### Using Route Parameters

When set up the routing configuration for the application, defined two routes that targeted the form component:

`{path: "form/edit", component: FormComponent}`
`{path: "form/create", component: FormComponent}`

When Ng is trying to match a route to a URL, it looks at each segment in turn and checks to see that it matches the URL that is being navigated to. Both of these are made up of *static segments* – which means that they have to match the navigated URL exactly.

Ng routes can just be more flexible and include *route parameters*. Which allows any value for a segment to match the corresponding segment in the URL. LIke:

`{path:"form/:mode", component: FormComponent},`

The second segment of the modified URL defines a route parameter – with colon followed by a name. In this case, the route parameter is just called `mode`-- this route will match any url has two segment where the first is `form`.

And using route parameter make it simpler to handle routes programmatically cuz the value of the parameter can be just obtained using its name. In the ctor:

```ts
constructor(private model: Model, activeRoute: ActivatedRoute) {
    this.editing = activeRoute.snapshot.params["mode"] == "edit";
}
```

For this, the component doesn’t need to know the structure of the URL to get the info it needs. Instead, just can use the `params`prop provided by the `ActivatedRouteSnapshot`class to get a collection of the parameter values.

### Using multiple Route Parameters

To tell form component which product has been selected when the user clicks an **Edit**, need to use a second route parameter – Since, Ng matches URLs based on the number of segmetns – means that ned to split up the routes that target the from component again – This cycle of consolidating and then expanding routes is typical. Just like:

```ts
{path: "form/:mode/:id", component: FormComponent},
{path:"form/:mode", component: FormComponent},
```

And the new route will match any URL that has 3 segments where the first is `form`. To create URLs that target this route, need to use a different approach for the `routerLink`expressions in the template, cuz need to generate the 3rd segment dynamically for each *edit* button fore:

```html
<button class="btn btn-warning btn-sm" (click)="editProduct(item.id)"
    [routerLink]="['/form', 'edit', item.id]">
    Edit
</button>
```

Now, `[routerLink]`– telling ng that should treat the attribute as data binding expression - this is *set out as an array* – which each element containing the value for one segment. The first two segments are literal strings and will be included in the target URL without modification.

And for now, need the form component to get the value of the new route parameter and use it to select the product that is to be edited – like:

```ts
constructor(private model: Model, activeRoute: ActivatedRoute) {
    this.editing = activeRoute.snapshot.params["mode"] == "edit";
    let id = activeRoute.snapshot.params['id'];
    if (id != null) {
        Object.assign(this.product, model.getProduct(id) || new Product());
        this.productForm.patchValue(this.product);  //patchValue...
    }
}
```

### Dealing with Direct Data Access

And the introduction of routing just has revealed a problem with the way that the data is obtained from the web service. But – if the user just navigates directly to the URL for editing a product, type some .. `/form/edit/2`, then the form is never populated with the data. This is cuz the `RestDataSource`class has been written to assume that individual `Product`will be accessed only by clicking an edit. Will just explain how to stop routes… for now – the other approach is to use `observables `to ensure that the data vlaues can be requested directly – like:

```ts
constructor(private dataSource: RestDatasource) {
    this.products = new Array<Product>();
    this.replaySubject= new ReplaySubject<Product[]>(1);
    this.dataSource.getData().subscribe(data=>{
        this.products=data;
        this.replaySubject.next(data);
        this.replaySubject.complete();
    });
}

getProductObservable(id: number): Observable<Product | undefined> {
    let subject = new ReplaySubject<Product | undefined>(1);
    this.replaySubject.subscribe(products => {
        subject.next(products.find(p=>this.locator(p, id)));
        subject.complete();
    });
    return subject;
}
```

The changes rely on the `ReplaySubject`to ensure that individual `Product`objects can be received even if the call to the new `getProductObservable`is made before the data requested by the ctor has arrived. Using `ReplaySubject`cuz – it allows subsequent calls to the `getProductObservable`to benefit from the data already produced.

```ts
constructor(private model: Model, activeRoute: ActivatedRoute) {
    this.editing = activeRoute.snapshot.params["mode"] == "edit";
    let id = activeRoute.snapshot.params['id'];
    if (id != null) {
        model.getProductObservable(id).subscribe(p=>{
            Object.assign(this.product, p || new Product());
            this.productForm.patchValue(this.product);
        });
    }
}
```

## App walkthrough - Node.JS source code

Going to go through another multi-stage Dockerfile – building Docker images is easy – There is one another need to know to package your own packages – 

Commands execute during the build, and any filesystem changes from the command and are saved in the image layer – that makes Dockerfiles about the most flexible packaging format there is fore – can expand zip, run Windows installers, and do pretty much anything else – 

### Who needs a build server when have a Dockerfile?

Building software on is sometimes U do for local development – But when are working in a team – fore, there is a shared source control syste like GitHub where every pushes their code changes there is typically a separate server that builds the software when changes get pushed. Msot programming langs need a lot of tools to build projects.

For this, there is a big maintenance overhead – If a developer just updates their local tools so the builder server is running a different version – the build can fail.

It would be much cleaner to package the build toolset once and share it – which is exactly what you can do with Docker, can write a `Dockerfile`that scripts the deployment of all your tools, and build that into a image – then can sue that image in app Dockerfiles to compile source code, and the final output is your package app.

Shows a Docker with the basic workflow – like:

```dockerfile
FROM diamol/base AS build-stage
RUN echo 'Building...' > /build.txt

FROM diamol/base AS test-stage
COPY --from=build-stage /build.txt /build.txt
RUN echo 'Testing...' >> /build.txt

FROM diamol/base
COPY --from=test-stage /build.txt /build.txt
CMD cat /build.txt
```

This is called a multi-stage Dockerfile – cuz there are several stages to the build.

Each stage runs indepedently. But can copy files and dirs from the previous stages, using the `COPY`with the `--from`argument – which tells Docker to copy files from an eariler stage in the file - rather from the filesystem. The `RUN`instruction executes a command just inside a container *during the build*, and any output from the command is saved in the image layer. Can execute anything in a `RUN`. But the commands you want to run need to just exist in the `Docker`image you are using in the `FROM`instruction. For this:

- Stage 1 is just the build stage, it generates a text file
- State 2 copies the text file from stage 1 adds to it.
- The final stage copies the text file from stage 2.

It is just important to understand that the individual stages are **isoloated**, you can use different base images with different sets of tools installed and run whatever commands you like. The output in the final stage will only contain what you explicitly copy from the eariler stages- can:

```sh
docker image build -t multi-stage .
```

This is just a simple example, but the pattern is just the same for building apps of any complexity.

In the build stage, use a base image that has your app’s build tools installed. U just copy in the source code from you host machine and run the `build`command. Can also add a test stage to urn the unit tests, which use a basic image with the test framework installed – copies the compiled binaries from the build stage, fore.

### Node.js source code

```dockerfile
FROM diamol/node AS builder

WORKDIR /src
COPY src/package.json .

RUN npm install

# app
FROM diamol/node

EXPOSE 80
CMD ["node", "server.js"]

WORKDIR /app
COPY --from=builder /src/node_modules/ /app/node_modules/
COPY src/ .
```

The goal here is the same as for the Java – to package and run the app with only Docker installed, without having to install any other tools. note that the base image for both stage is `diamol/node`which has the Node.js installed and `npm`installed. The builder stage in the Dockerfile copies the `package.json`files, which descrie all the app’s dependencies. Then it runs `npm install`to downlaod the dependencies.

Note that in the final stage – the steps exposes the HTTP port and specify the `node`command line as the startup command.

Just have a different tech stack here – with a different pattern for packaging the application.

```sh
docker image build -t access-log .
docker container run --name accesslog -d -p 801:80 -network nat access-log
```

The log api is running.

Docker builds containers using 10 major system features – 

- `PID`namespace – process id and capabilities
- `UTS`namespace – Host and domain name
- `MNT`namespace – Filesystem access and structure
- `IPC`namesapce – process communication over shared memory
- `NET`namespace – Network access and structure
- `USR`namespace – Usr name and id
- `chroot syscall`-- controls the location of the filesystem root
- `cgroups`– resource protection
- `CAP`drop - OS feature restrictions
- `Security modules`– mandatory access controls.
