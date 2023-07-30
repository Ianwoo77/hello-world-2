# Composite types

`func Idenity[T any] (v t)`{}

Fore, wanted to write a function `Len`that returns the length of a given slice -- and its parameter will always be a slice of sth - Can:

`func Len[E any](s []E) int`

Namely -- For any type `E`, `Len[E]`takes a slice of `E`.

`func Drain[E any](ch <-chan E)`

For any type `E`, `Drain[E]`takes a receive-only channel of `E`and returns nothing.

### Generic types

fore, deal with *collections* of values in Go, fore:

`type SliceOfInt []int` -- Can generic with:
`type Bunch[E any] []E` -- means for any type `E`, a `Bunch[E]`is a slice of `E`

Just as with generic functions, a generic type is always instantiated on some specific type when used in a program. Can: `b:= Bunch[int]{1,2,3}`

### There are no generic types

It’s important -- `Bunch`here is defined as a slice of `E`for any type `E`, any particular `Bunch`can’t contain values of different types.

### Generic function types

*functions are values* in Go. There is actually no such function as `Identity[T]`-- only one or more *instantiations* of that function on a specific type. Can just use it as a value:

`f := Identity[string]`

```go
f := Identity[string]
fmt.Printf("%T\n", f) // func(string) string
```

There are no generic functions in Go -- any generic functions may write will in fact be instantiated on some specific type at compile time -- and they will then just be plain old functions. like:

```go
type idFunc func[T any] (T) T // error function type must have no type parameters
// but can write:
type idFunc[T any] func(T) T // it is a func takes a T and returns a T
```

### Generic types as function parameters

Could we write a generic function that takes a *parameter* of a generic type --  like:

```go
func PrintBunch(E any) (v Bunch[E]){}
```

### Constraining type parameters--

## Constraints

### Limitations of `any`constraint

In a generic function parameterized by some type `T`, constrainting `T`to `any`just doesn’t give the compiler any info about it. Indeed, `any`is just *alias* for `interface{}`-- The bigger the interface, the weaker of abstraction. Thus - more types it allows, the less we can guarantee about what operations can do on them.

### Method Sets

In fact, all constraints are interfaces -- fore:

```go
type Stringer interface {
    String() string
}
```

Fore, could write a generic function parameterized by some type `T`that implements the `fmt.Stringer`interface like:

```go
func Stringify[T fmt.Stringer] (s T) string {
    return s.String()
}
```

Just used the constraint `Stringer`insted of `any`. Then, if call this with arg that doesn’t implement `Stinger` --

`fmt.Println(Stringify(1))` // error

### Named types

Another way to constrain type parameters is with an interface containing a *type element* -- this is also specific an allowed range of types -- and one way to do that is by simply naming those type. So just:

```go
type OnlyInt interface {
    int
}
```

It just contains a single type element, consisting of a named type -- could use this like:

```go
func Double[T OnlyInt](v T) T {
    return v*2
}
```

In other words, for some `T`that satisfies the constraint `OnlyInt`, `Double`takes a `T`and return `T`.

### Unions

To broaden the range, can create a constraint specifying more than one named type like:

```go
type Integer interface {
    int | int8 | int16 | int32 | int64
}
```

This kind of interface element is called a *union* -- A union can include any Go types. Including interface types. just like:

```go
type Float interface {
    float32 | float64
}
type Complex interface{
    complex64 | complex128
}
type Number interface{
    Integer | Float | Complex
}
```

### Type Sets

The *type set* of a constraint is the set of all types that satisfy it -- the type set of the empty interface (any) is the set of all types -- like:

### Composite type literals

A *composite* is one that’s built up from other types, not be restricted to define types with names, can also construct new types on the fly -- using a *type literal* -- literally writing out the type definition as part of the interface.

```go
type Pointish interface {
    struct {X, Y int}
}
```

For this, allow any instance of such a struct -- Its type set constrain exactly one type `struct {X, Y int}`

```go
type Pointish interface {
	struct {X, Y int}
}

func GetX[T Pointish] (p T) int {
	return p.X  // p.X just undefined, it is not allowed!, ERROR!!!
}
```

### Constraints vs. interfaces

An interface containing type elements can *only* be used as a constraint on a type parameter.

```go
func Double(p Number) Number {//error!!!}
```

### Constrints are not classes

U can’t instantiate a generic function or type on a constraint interface -- like:

```go
type Cow struct {moo string}
type Chicken struct {cluck string}
type Animal interface {
    Cow | Chicken
}
type Farm[T Animal] []T
//...
dairy := Farm[Cow]{}
mixed := Farm[Animal]{} // error, couldn't use Animal as type of some variable
```

### Limiations of named types

```go
type Integer interface {
    int |...
}
type MyInt int
func Double[T Integer] (v T) T {return v*2 }
fmt.Println(Double(MyInt(1))) // MyInt doesn't implement the `Integer` interface
```

## Type Approximations

Need a new kind of type element -- *type approximation* like:

```go
type ApproximatelyInt interface {
    ~int
}
```

For this, just like:

```go
type Pointish interface {
	~struct{ x, y int }  // note the ~
}

func Plot[T Pointish](p T) {
	//...
}

type Point struct {
	x, y int
}

func main() {
	p := Point{1,2}
	Plot(p)  // good
}
```

### Intersections

Probably know that with a classic interface -- a type must have all of the methods. and if the interface just contains other interfaces, a type **MUST** implement all of those interfaces, not just one of them.

Could we write an interface with *type* elements arranged in a similar way -- Separated by new lines..

```go
type IntStringer interface {
    ~int
    fmt.Stringer
}
```

Note -- The built `int`type doesn’t have a `String`, cuz we used the approximation token -- types derived from `int`would be ok. On the other hand, intersections also make perfectly possible to define..

### The `constraints`package

```go
type Integerish interface {
    ~int | ~int8...
}
```

And, also some other handy constraints defined in the `constraints`package --

- `Signed/Unsigned`
- `Integer/Float`
- `Complex/Ordered`

# User Login

The process for creating the user login page just follows the same general pattern as the user signup, create `login.page.html`template containing the markup below: Just note that the `novalidate`attribute in HTML is used to signify that the form won’t get validated *on submit*. And it is a boolean and useful if you want the user to save the progress of form filling, and if the form validation is disabled, the user can easily save the form and contiune & submit the form later.

```html
{{template "base" .}}

{{define "title"}}Login{{end}}

{{define "main"}}
	<form action="/user/login" method="post" novalidate>
        {{with .Form}}
            {{with .Errors.Get "generic"}}
				<div class="error">{{.}}</div>
            {{end}}
			<div>
				<label>Email:</label>
				<input type="email" name="email" value="{{.Get "email"}}">
			</div>

			<div>
				<label>Password:</label>
				<input type="password" name="password">
			</div>

			<div>
				<input type="submit" value="Login">
			</div>
        {{end}}
	</form>
{{end}}
```

Just notice how included a `{{with .Errors.Get "generic"}}`action at the top of the form -- instead of displaying of error messages for individual field. Just use this to present the user with a generic message if fails.

Then just hook this up so it’s renderd like:

```go
func (app *application) loginUserForm(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "login.page.html", &templateData{Form: forms.New(nil)})
}
```

### Verifying the User Details

And the next is the -- how we verify that the email and password submitted are correct -- The fore part of this logic will take place in the `UserModel.Authenticate()`method -- do two things mainly:

1. Retrieve the hashed pwd associated wiht the email address from table. And if theemail doesn’t exist in the dbs, or it’s for a user that has been deactivated, return `errInvalidCredentials`error.
2. Otherwise, want to compare the hashed pwd from the `users`table with the plain-text pwd that the user provided when logging in. If not match, want to return the `ErrInvalidCredentials`error again. Do match if, want to return the user’s `id`value from the dbs.

```go
func (m *UserModel) Authenticate(email, password string) (int, error) {
	// retrieve the id and hashed pwd associated with the given email
	var id int
	var hashedPwd []byte
	stmt := "select id, hashed_password from users where email=? and activate=TRUE"
	row := m.DB.QueryRow(stmt, email)
	err := row.Scan(&id, &hashedPwd)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, models.ErrInvalidCredentials
		} else {
			return 0, err
		}
	}

	// #2, check whether the hashed pwd and plain-text pwd provided just match.
	// if don't, return ErrInvalidCredentials error like:
	err = bcrypt.CompareHashAndPassword(hashedPwd, []byte(password))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return 0, models.ErrInvalidCredentials
		} else {
			return 0, err
		}
	}
	return id, nil
}
```

And the next step involves updating the `loginUser`handler so that it parses the submitted login from data and calls the `UserModel.Authenticate()`method. If the login details are valid, then want to add the user’s `id`to their session data so that for future requests.

```go
func (app *application) loginUser(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// check whether the credentials are valid
	form := forms.New(r.PostForm)
	id, err := app.users.Authenticate(form.Get("email"), form.Get("password"))
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.Errors.Add("generic", "email or pwd is incorrect")
			app.render(w, r, "login.page.html", &templateData{Form: form})
		} else {
			app.serverError(w, err)
		}
		return
	}

	// add the ID of the current user to the session, so now logged in
	app.session.Put(r, "authenticatedUserID", id)

	// redirect the user to the create page
	http.Redirect(w, r, "/snippet/create", http.StatusSeeOther)
}
```

Namely:

- Users can now register with the siteusing the `GET /user/signup`form, store the details of registered users in the users table of our dbs.
- Registered users can then *authenticate* using the `GET /user/login`form to provide their email address and pwd.

### Session Fixation Attacks

Cuz are using an *encrypted* cookie to store the session data-- an cuz the encrypted cookie value just changes unpredictable every time the underlying session -- don’t need to worry about *session fixation attacks*.

However, if were using a server-side data store for sessions, then to mitigate the risk of session -- it’s important that you change the value of the session ID before making any changes to privilege levels.

## User Logout

implementing the user logout is just straightforward in comparison to the signup and login -- all we need to do is remove the `authenticateUserID`value from the session. Just:

```go
func (app *application) logoutUser(w http.ResponseWriter, r *http.Request) {
	// Remove the authenticationUserID from the session data so that the user is `logged out`
	app.session.Remove(r, "authenticationUserID")

	app.session.Put(r, "flash", "you have been logged out successfully")
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

```

## User Authorization

Being able to authenticate the uses of the app is all well and good - but now we need to do sth useful with that info. In this introduce some *authorization* checks so that:

1. Only authentiated users can create a new snippet
2. The contents of the nav bar changes depending on whether a user is authenticated or not. Unauthenticated just links to Home, Signup and Login...

Can just check whether a request is being made by an authenticated user or not by checking the existence of an `authenticateUserID`value in the session data. So add a helper like:

```go
// return true if the current request is just from authenticated user
func (app *application) isAuthenticated(r *http.Request) bool {
	return app.session.Exists(r, "authenticatedUserID")
}

```

Now, can just check whether or not the request is coming from an authenticated user. -- Next, is to find a way to pass this info to our HTML templates, so can toggle the contents of the navigation bar appropriately.

There is just two parts to this, first, need to add a new `IsAuthenticated`field to our `templateData`struct like:

```go
type templateData struct {
    //...
    IsAuthenticated bool
}
```

The second step is to just update our `addDefaultData()`helper so that this info is automatically added to the `templateData`struct every time we render a template like:

`td.IsAuthenticated = app.isAuthenticated(r)`

Once that is done, can update the `html/base.layout.html`to toggle the nav links like so: Like:

```html
{{if .IsAuthenticated}}
<form action="/user/logout" method="post">
    <button>Logout</button>
</form>
{{else}}
    <a href="/user/signup">Signup</a>
    <a href="/user/login">Login</a>
{{end}}
```

Remember -- the `{{if ...}}`action considers *empty values* interface value, and any array, slice, map, or string to be `false`.

# Restricting Access with Authorization Policy

The final step in this is to apply access restrictions so that Core will only allow users who meet the authorization policy access to protected actions or pages. The changes in this section break the app – Core just provides a complete set of features for enforcing authentication and authZ. The following changes tell core to just restrict access but do not provide the features required to allow requests to be authenticated, or to allow users to sign into the app.

### Applying the Level 2 Authorization policy

The `[Authorize]`is used to restrict access – just like:

```cs
[Authorize]
public class StoreController: Controller {...}
```

Just note when the Attr is applied without any arguments – The effect is to restrict access to any signed-in user. Also in the Rps:

```cs
[Authorize]
public class StoreModel: PageModel {}
```

### Applying Level 3 AuthZ policy

The `[Authorize]`can be used to define more specific access restrictions. The most common approach is to restrict access to uses who has been assigne to a specific *role*. Like:

```cs
[Authorize(Roles ="Admin")]
public class AdminController : Controller
```

And

```cs
[Authorize(Roles ="Admin")]
public class AdminModel : PageModel
```

## Configuring the Application

The remining step is to enable the core features that handle authorization and authentication - These are the features which core identity integers but are provided by Core.

The `UseAuthentication()`and `UseAuthorization()`set up – as their names suggest, the core authentication and AuthZ features. – If this request is handled by the `Store`controller, to which the `Authorize`has been applied. Cannot do this, cuz requried services are missing.

Blazor currently supports two approaches, which are sketched in figure – 

- Sever – Only the UI is sent to the browser, whereas all the C# code resides on the web server. Generated Js code automatically calls the server (using SingalR), which then runs the C# code and sends any changes to the DOM.
- Blazor *webassembly* – every is compild down to WASM – including those parts of .NET that are just used by the app – in this case, may take a few seconds to download the app.

# Cross-site scripting (XSS)

- Understanding how XSS works
- Learning about different types of XSS
- preventing XSS by escaping output
- Using Content security Policy (CSP) against XSS
- Judging other browser features against XSS.

## Anatomy of a XSS

The most common flavor of XSS is just is injecting Js code into a page – although there are also attack vectors that use HTML or css.

- The Identity UI package is a set of RPs and supporting classes provided by Ms to jump-start the use of Core identity in core projects.
- The Identity UI package provides all the workflows required for basic user management – including creating and signing with passwords, authenticators, and 3rd-party services.
- Is just added as a Nuget and enabled just with the `AddDefaultIdentity()`extension.
- The approach that Identity UI takes doesn’t suit all projects - this can be remedied by adapting the features it provides or by working directly with the `Identity API`to create custom alternatives.
- Identity provides API that cna be used to create custom alternatives.

## Adding ASP.NET core identity to the Proj

Need :

```sh
install-package Microsoft.Extensions.Identity.Core 
install-package Microsoft.AspNetCore.Identity.EntityFrameworkCore -Version 6.0.16
```

Then need add:

```sh
Install-Package Microsoft.AspNetCore.Identity.UI
```

### Defining a Dbs connection string

And the easiest to store Identity data is in a dbs – and ms provides just built-in support for doing this with EF core. Although you can use a single dbs for the app’s domain data and the Identity data.

```cs
builder.Services.AddDbContext<IdentityDbContext>(opts =>
{
    opts.UseSqlServer(builder.Configuration.GetConnectionString("IdentityConnection"),
        opts => opts.MigrationsAssembly("IdentityApp"));
});
// must under 6.0.16
builder.Services.AddDefaultIdentity<IdentityUser>().AddEntityFrameworkStores<IdentityDbContext>();
```

### Configuring the Application

The `AddDbContext`is used to just set up an EF core dbs context for Identity. The dbs context class is just the `IdentityDbContext`-- included in Identity packages and includes details of the schema that will be used to store identity data. Can create a custom database context class if prefer.

Cuz the `IdentityDbContext`class is defined in a different assembly – have to tell EF Core to create dbs migrations in the project. like:

```cs
//...
opts.UseSqlServer(
	builder.Configuration.GetConnectionString("..."), 
    opts=> opts.MigrationAssembly("IdentityApp")
	)
```

Then just add the `AddDefaultIdentity<IdentityUser>`– The reason that ASP.NET core threw exceptions for requests to restricted URLs in the – no services had been registered to authentication requests – 

The `AddDefaultIdentity`sets up those services using sensible default values. And the generic type arg specifies the class Identity will use to represent users. `IdentityUser`is the default user class provided by ms in part 2. And the second part of this statement sets up the Identity database.

```cs
builder.Services.AddDefaultIdentity<IdentityUser>()
    .AddEntityFrameworkStores<IdentityDbContext>();
```

For this sets up db stores using EF core, and the generic type arg specifeis the dbs context that will be used. Note that the Identity uses two kinds of datastore, *user store* and *role store*.

The user store just the heart of Identity and is used to store all of the user data, including email, passwords, and so on. Membership of roles is kept in the user store.

The role store contains additional info about roles that are used only in complex applications.

Then, just creating the dbs – EF Core just requires a dbs migration – which will be ued to create the dbs for Identity data. just: 

```sh
add-migration IdentityInitial -Context IdentityDbContext
update-database -Context IdentityDbContext
```

Preparing the Log Partial View – For the UI package requires a partial view named `_LoginPartial`, note that, which is displayed at the top of every page. Note, for some `boolean`exception, and cryption error, **maybe just nuget error**.

The chanllenge response is a redirection to the `Identity/Account/login`url.

# Building custom input components with `InputBase`

While Blazor provides all the basic input components need to build a form – at some point need sth a little complex – or more tailored to needs. Get started with building a custom input component, the Blazor included a base type that is going to do a lot of lifting for us - `InputBase<T>`-- going to handle the integration with `EditContext`.

### Inheriting from `InputBase<T>`

First thing need to do is create a new component in the `ManageTrails`feature called `InputTime.Razor`:

```html
@inherits InputBase<int>
<div class="input-time">
    <div>
        <input class="form-control" type="nubmer" min="0" />
    </div>
    </div>
<!-- .... -->
```

```cs
protected override bool TryParseValueFromString(
string? value, out int result, out string validationErrorMessage) {}
```

For this, just inheriting from `InputBase<T>`using the `inherits`and setting the type parameter to `int`. The type specified should be the type you want to work with on the form model. cuz have a prop like:

`public int TimeInMinutes {get;set;}`

The markup section of the component declares two regular HTML input elements – one for the hours and one for the minutes – their type attributes are set to `number`. The browser will use this to stop `non-number`value from entered by the user.

In the code base, provided an implementation for the `TryParseValueFromString`-- msut be implemented – its job is to convert a string value to the type that the component is bound to on the form model. However, depending on how you build a custom input component – this method may not ever get called – this will be the case witho our custom component – The base class just provides two properties to update the model value:

- `CurrentValueAsString`
- `CurrentValue`

If were writing a component that only *required a single HTML input* element, could bind that input directly to the `CurrentValueAsString`and Blazor would then call the `TryParseValueFromString`method. When a value was entered in the inpout, would set `CurrentValueAsString`and Blazor would then call `TryParseValueFromString`. This is cuz Blazor can’t reliably convert `CurrentValueAsString`to the type we want…

However, we have two input elements – So – can’t bind them both to one prop – need to create our own fields to bind them to. We then need to take those individual values and convert them into a single integer value we can update the model with. This is where the second property comes in – `CurrentValue`is jsut a generic property and will adopt the type specified when inheriting `InputBase<T>`. In our case – would be an `int`. If this property is used to set the model value, then no type conversion is required. Hence `TryParseValueFromString`will not be called.

```html
@inherits InputBase<int>

<div class="input-time">
    <div>
        <input class="form-control"
               type="number"
               @onchange="SetHourValue"
               value="@_hours"
               min="0" />
        <label>Hours</label>
    </div>
    
    <div>
        <input class="form-control"
               type="number"
               @onchange="SetMinuteValue"
               value="@_minutes"
               min="0"
               max="59" />
        <label>Minutes</label>
    </div>
</div>
```

```cs
protected override bool TryParseValueFromString(string? value, 
    out int result, out string? validationErrorMessage)
{
    throw new NotImplementedException();
}

private int _hours;
private int _minutes;

private void SetHourValue(ChangeEventArgs args)
{
    int.TryParse(args.Value?.ToString(), out _hours);
    SetCurrentValue();
}

private void SetMinuteValue(ChangeEventArgs args)
{
    int.TryParse(args.Value?.ToString(), out _minutes);
    SetCurrentValue();
}

// the _hours and _minutes fields are converted to total minutes value
// then the CurrentValue is set to that value
private void SetCurrentValue() => CurrentValue = (_hours * 60) + _minutes;
```

For this, When bound to HTML inputs, used the `bind`– however, this method won’t be optimal in this scenario – need to just perform some actions every time either the hour or minute values change. While could use the `bind`directive with a prop and do the work inside the `setter`method.

Instead, using fields to set the value of the inputs and then handling the `onchange`event of each one so *can perform some logic*. For reference, what doing here is what the bind directive does under the hood.

And, both `SetHourValue`and … methods just do the same thing – extract the value entered in the input and convert it to an integer value setting either the .. field – depending on which method is firing. Must do this conversion – as all html inputs work with strings.

And, the `SetCurrentValue()`works out the total number of minutes based on the values of the `_hours`and `_minutes`fields – it then assigns that value to the `CurrentValue`– this comes from just the base class – by setting this, all the logic for triggering validation and updating the model value will be run.

For the final piece just, involving loading an existing value – just like:

```cs
protected override void OnParametersSet()
{
    if (CurrentValue > 0)
    {
        _hours = CurrentValue / 60;
        _minutes = CurrentValue % 60;
    }
}
```

When the component is used in a form that is editing an existing record, the model property that it is bound to could  have a value – if that is the case – the `CurrentValue`on the base will hold that value.

### Styling the custom Component

To give – need add a little CSS just jusing scss like:

```scss
.input-time {
  display: flex;

  div {
    display: flex;
    align-items: center;
    margin-right: 20px;

    input {
      width: 90px;
      margin-right: 10px;
    }

    label {
      margin-bottom: 0;
    }
  }
}
```

Using the `flex`-- is just going to make all the inputs and labels display in a row. And the last piece of styling we need to just configure is for validation – another nice feature of using `InputBase`is that privdes a property called `CssClass`that outputs the correct validation classes based on our field’s state. FORE, if contained invalid value, based on classes we have configured in the `BootstrapCssClassProvider`, `CssClass`would output the string `is-invalid`.

Then, just references the `CssClass`in the class attribute on both input elements.

`<input class="form-control @CssClass" .....`

### Using the Custom Input Component

Add our new custom component to the `Difficult`section of the form – like:

```html
<FormFieldSet Width="col-5">
    <label for="trailTime" class="fw-bold text-secondary">
        Time
    </label>
    <InputTime @bind-Value="_trail.TimeInMinutes" id="trailTime" />
    <ValidationMessage For="@(()=>_trail.TimeInMinutes)" />
</FormFieldSet>
```

Note that the `InputTime`component just bound to the model property using the same `@bind-Value`syntax. The new component is now integrated into the form.

For now, need to add some valiation for the `TimeInMinutes`prop to our `TrailValidator`class. Also need to update the `AddTrailEndpoint`in the API to use the value from the model. 

First, in the `Shared`proj, need to write the validation rule like:

```cs
RuleFor(x => x.TimeInMinutes).GreaterThan(0)
                .WithMessage("Please enter a time");
```

This rule is going to make sure that the user has entered a positive for the trail time. And, with the validation updated, need to update the endpoint too…

Have just successfully created and integrated a custom input component into the form.

# Routing and Navigation: Part 1

The Ng routing feature just allows apps to change the components and templates that are displayed to the user by responding to changes to the browser’s URL. This allows complex apps to be created that adapt the content the present openly and flexibly, whit minimal coding – To support this, data bindings and services can be used to change the browser’s URL, allowing users to navigate around the appliation.

Routing is useful as the complexity of a probject increases cuz it allows the structure of an app to be defined separately from the components and directives – meaning the changes to the structure can be made in the routing confiuration and do not have to applied to the inidividual components.

- Routing uses the Browser’s URL to mange the content displayed to the user.
- allows the structure of an app to be ketp apart from the components and tempaltes in the app. Changes to the structure of the application are made in the routing configuration rather than in individual componetns and directives.
- The routing configuration is defined as a set of fragments that are used to match the browser’s URL and to select a component whose tempalte is displayed as the content of an HTML element called `router-outlet`.

## Getting started with Routing

URL routing adds structure to an appliation using a natural and well-understood aspect of web applications – the URL in this section, going to introduce URL routing by applying it to the example so either the table or the form is visible - with the active component being chosen based on the user’s actions – This will provide good basis for explaingin how routing works.

### Creating a Routing Configuration

The first step when applying routing is to define the `routes`which are mappings between URLs and the components that will be displayed to the user. Routing configurations are conventionally defined in a file called `app.routing.ts`– in the app folder like:

```ts
const routes: Routes = [
    {path: "form/edit", component: FormComponent},
    {path: "form/create", component: FormComponent},
    {path: "", component: TableComponent}
]

export const routing = RouterModule.forRoot(routes);
```

The `Routes`class defines a collection of routes – each of which just tells Angular how to handle a specific URL – this uses the most basic properties – where the `path`speciffies the URL and the `component`that will be displayed to the user. The `path`just is specified relative to the rest of the appliation – which means that the configuration fore:

`http://localhost:4200/form/edit`: `FormComponent`

The routes are packaged into a module using the `RouterModule.forRoot()`– the `forRoot()`produces a module that includes the routing service. Note that here is also a `forChild()`that doesn’t include the service. And there are also a range of additional props that can be used to define routes with advanced features – these props are:

- `path`-- specifies the path for the route
- `component`– specifies the component will be selected when the active URL match the `path`.
- `pathMatch`– tells how to match the current to `path`. `full`requires the `path`value to completely match, and `prefix`allows the `path`to match the URL – even if the URL contains additional *segments* that are not part of the `path`.
- `redirectTo`– This is used to create a route that redirects the browsers to a different URL when activated.
- `chidlren`-- used to specify child route– display additional components in the nested `router-outlet`elements contained in the template of the active component
- `outlet`– Support multiple `outlet`elements.
- `resolve`- define work that must be completed before a route can be activated.
- `canActivate, canActivateChild, canDeactivate`
- `loadChildren`-- configure a module that is loaded only when it is needed
- `canLoad`– used to control when an on-demand module can be loaded.

### Creating the Routing Component

When using routing, the root component is dedicated to managingi the nav between different parts of the app. This is typically purpose of the `app.component.ts`file – that was added to the project by the `ng new`command. Now, replacing the contents of the `app.component.html`with:

```html
<paMessage></paMessage>
<router-outlet></router-outlet>
```

The `<paMessages>`element display any messages and errors in the application. For the purpose of routing, it is the `router-outlet`element – known as the *outlet* – that is important cuz it tells Ng that this is where the comonent matched by the routing configuration should be displayed. Cuz in the setting, the default URL just the route that shows the table.

### Adding Nav links

The basic routing configuration is in place here is no way to navigate around the app – nothing happens when click the buttons.

```html
<button class="btn btn-primary mt-1" (click)="createProduct()" routerLink="/form/create">
    Create New Product
</button>
```

The `routerLink`attribute applies a directive from the routing package that performs the NAV change. This directive can be applied to any element.

And the routing links added to the table component’s template will allow the user to navigate to the form. Not all the features in the app work yet – but this is just a good time to explore the effect of adding routing to the app. Cuz:

```ts
{path: "form/create", component: FormComponent}, 
{path: "", component: TableComponent}
```

Just note that the `app.routing.ts`is the `imports`in the `app.module.ts`file. This is just the essence of routing – the browser’s URL changes, which causes the routing system to consult its configuration to determine which component should be displayed to the user.

# HTTP

Angular just comes with its Own HTTP library which we can use to call out to external APIs – when make calls to an external server, Want our user to continue to be able to interact with the page. That is, don’t want our page to freeze until the HTTP request returns from the external server.

Dealing with async code is – 

1. Callbacks
2. Promises
3. Observables

In Angular, the preferred method of dealing with async code is using `Observable`.

## Using `@angular/common/http`

`HTTP`has been split into a separate module in Ng – this just menas that to use it you need to import constants from. 

### A basic Request

The first thing going to do is make a simple `GET` to jsonplaceholder.

```html
<h2>Basic request</h2>
<button type="button" (click)="makeRequest()">Make Request</button>
<div *ngIf="loading">loading...</div>
<pre>{{data | json}}</pre>
```

`imports:[..., HttpClientModule]`

### Writing Dockerfile

```dockerfile
FROM diamol/node

ENV TARGET="baidu.com"
ENV METHOD="HEAD"
ENV INTERVAL="3000"

WORKDIR /web-ping
COPY app.js .

CMD [ "node", "/web-ping/app.js" ]
```

For the capitals – is convention, not a requirement.

- `FROM`-- every image has to start from just another image – from just the `diamol/node`image as its starting point, and this just has `Node.js`installed.
- `ENV`– sets values for environment variables. `[key]="[value]"`
- `WORKDIR`– creates a directory *in the container* image filesystem, and sets that to be the **current** working directory.
- `COPY`– copies files or directoires from the local into the container image.
- `CMD`– Run when Docker just *starts* a container from the image.

```sh
import-module DockerCompletion
```

```sh
docker image build --tag web-ping .
```

The `--tag`jsut is the name for the image.

```sh
docker container run -e TARGET=baidu.com -e INTERVAL=5000 web-ping
```

### Understanding Docker images and image layers

Building plenty more images as you work through this book – for this chapter, stick with this simple one and use it to get a better understanding of how images work.

The Docker image contains all the files you packaged – which become the *container’s filesystem* – and it also contains a lot of metadata about the image itself. That will includes a brief history of how the image was built. Can use that to see each layer of the image and the command that built the layer.

```sh
docker image history web-ping
```

See an output line for each image layer – fore, the `CREATED BY`are Dockerfile instructions – one-to-one REL – each line in the `Dockerfile`creates an image layer.

Note: A Docker image is just **a logical collection of image layers**. Layers are the files that are physically stored in the *Docker Engine’s cache*. Image layers can just be *shared between different images and different containers*.

And fore, if have lots of containers all running `node.js`apps, will all share the same set of image layers that just contain the Node.js runtime. In the `diamol/node`there just a `nodejs`and `base os`, The node image just has a minimal os layer and the node.js runtime installed.

And just note that the size column – is the logical size of the image – that is how much disk space the image would use if you didn’t have any other images… if have, the space Docker uses is much smaller just.

### Optmiizing Dockerfile to use the image layer cache

Just make some change to the app.js file – and just using:

```sh
docker image build -t web-ping:v2 .
```

Every Dockerfile instruction results in an image layer – but if the instruction doesn’t change between builds, and the content going into the insturction is the same - Dockerfile knows it can use the previous layers in the cache. Fore: Steps 2 through 5 all comes from the cache cuz the input is unchanged. And step 6 executes cuz the copied file contents have just changed. And step 7 executes even though the input just hasn’t changed, cuz the cache was broken in step 6.

So, there are just only 7 instruction in the web-ping Dockerfile – but can still be optimized – the `CMD`doesn’t need to be at the end of the `Dockerfile`, can be anywhere after the `FROM`and still just have the same result. so:

```dockerfile
FROM diamol/node
CMD [...]
ENV TARGET=...
	METHOD=...
	INTEVERAL = ...

WORKDIR /web-ping
COPY app.js .
```

*container* has become the preferred term for such a runtime environment. The goal has expanded form limiting filesystem scope to isolating a process from all resources except where explicitly allowed. And any software run within Docker is run inside a conainer – Docker uses existing container engines to provide consistent containers built according to best practices.

With Docker, uses get containers at a much lower cost. Containers are not virtualization – Unlike VM, docker containers don’t use any hardware virtualiation – Programs running inside Docker containers directly with the host’s Linux kernel. Many programs can just run isolation without running redundant OS or suffering the delay of full boot sequence. Instead, it helps you use the container technology *already* built into your OS kernel.

VM provide hardware abstractions so can run OS – *Containers are an Operatying System Feature*. Can always run Docker in a vm if that machine is running a modern Linux Kenrel.

### Runing software in containers for isolation

Docker uses Linux namespaces and cgroups, which have been part of Linux since 2007. Docker doesn’t provide the container tech, specifically makes it simpler to use. The command-line interface – CLI, runs in what is called *user space memory* – just like other programs run on top of the OS. The os is the interface between all user programs and the hardware that the computer is running on.

Running Docker just means running two programs in user space. The first is Docker enginge. this just always running. Second is the Docker CLI – the Docker program that uses interact with.

Command line -> Docker CLI -> Docker daemon -> each runing as a child process of the Docker engine, wrapped with a container – and the delegate process is just running in its won memory subspace of the user space. And programs runinng inside a container can access only their own memory and resources as scoped by the container.
