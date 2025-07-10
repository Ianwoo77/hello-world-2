# Fixed positioning

Fixed positioning, although not as common as some of the other types of positioning, is probably the simplest to understand -- `position: fixed`to an element lets U position the element arbitrarily within the viewport. Fore the `inset:0`-- property is shorthand for the following -- `inset-block-start`...

#### Creating a modal dialog with the fixed positioning

```html
<div class="modal" id="modal" role="dialog" aria-modal="true">
    <div class="modal-backdrop"></div>
    <div class="modal-body">
        <button class="modal-close" id="close" type="button">
            close
        </button>
        <h2>Wobat Newsletter</h2>
        <p>Sign up for our monthly newsletter. No spam.
            we promise.
        </p>
        <form>
            <p>
                <label for="email">Eamail address</label>
                <input type="text" name="email">
            </p>
            <p>
                <button type="submit">Submit</button>
            </p>
        </form>
    </div>
</div>
```

Typically, you will use a modal dialog to require the user to read sth or to input sth before continuing -- displays a form where a user can sign up for a newletter.

```js
const button = document.getElementById('open');
const close = document.getElementById('close');
const modal = document.getElementById('modal');

button.addEventListener('click', () => {
    modal.classList.add('is-open');
    document.body.classList.add('no-scroll');
});
close.addEventListener('click', () => {
    modal.classList.remove('is-open');
    document.body.classList.remove('no-scroll');
});
```

This overrides user-agent styles that apply some default font settings to form elements -- this is a common step -- to style the modal itself, will use fixed positioning twice -- give it a background color `rgb(0 0 0 / 0.5)`0-- this color notation specifies .. like:

```css
.modal-backdrop {
    position: fixed;
    inset:0;
    background-color: rgb(0 0 0 / 0.5);
}

.modal-body {
    position: fixed;
    inset-block: 3em;
    inlset-inline: 20%;
    padding: 2em 3em;
    background-color: white;
    overflow: auto;
}
```

##### Preventing screen from scolling while the modal dialog is open

Scolling the page while the modal dialog is open is helpful for observing how fixed positioning works -- 

```css
body.no-scroll {
    overflow: hidden;
}
```

#### Controlling the size positioned elements

When positoning an element, you are not required to specify values for all four sides -- U can specify only the sides you need and then use `width`or `height`to help determine its size.  Like:

```css
position: fixed;
top: 1em;
right: 1em;
width: 20%;
```

### Absolute Positioning

Fixed positioning, as you have just seen, lets U position an element relative to the viewport -- Absolute positioning works the same way -- except it has a different containing block -- instead of its position being based on the viewport, its position is based on the closest-positioned ancestor element -- like:

##### Absolutely positioning the Close button

To see how this works -- reposition the Close button on the top right corner of your modal dialog like:

```css
.modal-close {
    position: absolute;
    top: 0.3em;
    right: 0.3em;
    padding: 0.3em;
}
```

##### Positioning a pseudo-element

Have positioned the `Close`button where you want it -- but -- Can use CSS to hide the word `close`and display a X, will accomplish this by doing two things -- first push the button’s text outside the button and hide the overflow, second, use the `content`property to add the X to the button’s `::after`and abosolute the positioning.

```css
.modal-close {
    position: absolute;
    top: 0.3em;
    right: 0.3em;
    padding: 0.3em;
    border: 0;
    font-size: 2em;
    height: 1em;
    width: 1em;
    text-indent: 10em;
    overflow: hidden;
    background-color: transparent;
}

.modal-close::after {
    position: absolute;
    line-height: 0.5;
    top: .2em;
    left: .1em;
    text-indent: 0;
    content: "\00D7"
}
```

This listing explicitly sets the button size to 1 em square, the `text-indent`property then pushes the text to the right, outside the element, the exact value doesn’t matter as long as it’s more than the width of the button. Then cuz `text-indent`is an inherited property, reset to 0 on the pesudo-class.

### Relative positioning

Relative positioning is probably the least understood positioning type. When apply `position: relative`, won’t usually see any visiable change on the page, the relatively positionged elmeent, and all elements on the page around it -- will reaming exactly where they were. 

Then the `inset`properties, if applied, will shift the element from its original position, but they won’t change the position of any elements around it. For, if apply:

```css
position: relative;
top: 1em;
left: 2em;
```

This class shifted the element from its initial position, but the other elements are unaffected, they still follow normal document flow around the initial position of the shifed element.

#### Creating a dropdown menu

```html
<main class="container">
    <nav>
        <div class="dropdown" id="dropdown">
            <button type="button" class="dropdown-toggle" id="dropdown-toggle">
                Main Menu
            </button>
            <div class="dropdown-menu">
                <ul class="submenu">
                    <li><a href="/">Home</a></li>
                    <li><a href="/coffees">Coffees</a></li>
                    <li><a href="/brewers">Brewers</a></li>
                    <li><a href="/specials">Specials</a></li>
                    <li><a href="/about">About us</a></li>
                </ul>
            </div>
            </nav>
        <h1>Wombat Coffee Roasters</h1>
        </main>
```

And the dropdown container includes two children -- toggle button, which is always visible, and the dropdown menu, which will show and hide as the dropdown is opened and closed -- 

```jsx
const dropdownToggle = document.getElementById('dropdown-toggle');
const dropdown = document.getElementById('dropdown');
dropdownToggle.addEventListener('click', () => {
    dropdown.classList.toggle('is-open');
});
```

Similar to the modal U built -- this js adds and removes an `is-open`class on the dropdown -- apply relative positioning to the dropdown container -- this established the containing block for the absolutely poitioned menu within.

```css
dropdown {
    display: inline-block;
    position: relative;
}

.dropdown-toggle {
    padding: 0.5em 1.5em;
    border: 1px solid #ccc;
    background-color: #eee;
    border-radius: 0;
}

.dropdown-menu {
    display: none;
    position: absolute;
    left: 0;
    top: 2.1em;
    inline-size: max-content;
    min-inline-size: 100%;
    background-color: #eee;
}

.dropdown.is-open .dropdown-menu {
    display: block;
}

.submenu {
    padding-inline-start: 0;
    margin: 0;
    list-style-type: none;
    border: 1px solid #999;
}

.submenu>li>a {
    display: block;
    padding: 0.5em 1.5em;
    background-color: #eee;
    color: #369;
    text-decoration: none;
}

.submenu>li>a:hover {
    background-color: #fff;
}
```

Now when you click the main menu toggle button, the dropdown menu pops open beneith it -- clicking the toggle again will close it.

#### Stacking Contexts and z-index

Positioning is useful, but it’s important to know the ramifications involved -- when U remove an element from the document flow, become reposible for all the things the document flow normally does for U. Need to ensure the element doesn’t accidentally overflow outside the browser viewport -- becoming hidden from the user.

Eventually, will encounter problems with stacking -- when positioning multiple elements on the same page, may run into a scenario where two different positioned elements overlap -- may occassionally be surprised to find the wrong one appearing in front of the  other.

##### Understanding the rendering process and stacking order

As the browser parses HTML into the DOM, it also creates another tree structure called *render tree* -- this represents the visual apparance and position of each element. It’s also reposible for determining the order in which the browser will *paint* the elements.

## Constraints

Fore, the `fmt.Stringer`interface like:

```go
type Stringer interface {
    String() string
}

// write a generic func parameterised by some type `T`-- 
func Stringify[T fmt.Stringer] (s T) string {
    return s.String()
}
```

It works the same way as the generic functions we have already written - the only new thing is that we used the constraint `Stringer`instead of `any`-- Now when we actually call this function in a program, only allowed to pass it arguments that implement the `Stringer`. Fore:

```go
func StringifyTo[T fmt.Stringer](w io.Writer, p T) {
    fmt.Fprintln(w, p.String())
}
```

#### Type set constraints

Suppose wanted to write some generic function `Double`that multiples a number by two, and want a type constraint that allows only values of type `int`.

```go
type OnlyInt interface {
    int
}
```

It looks like a regular interface definition, except that instead of method elements, it contains a single *type element*.

##### using a type set constraint

```go
func Doulbe[T OnlyInt](v T) T {
    return v * 2
}
```

#### Unions -- 

What types can satisfy the constraint `OnlyInt`-- only `int`-- to broaden this range, can create a constraint specifying more than one named type like:

```go
type Integer interface {
    int | int8 | int16 | int32 | int64
}
```

#### Intersections

For a basic interface, a type must have *all* of the methods listed in order to implement the interface, and if the interface contains other interfaces, type must implement *all* of those interfaces -- like:

```go
type ReadStringer interface {
    io.Reader
    fmt.Stringer
}
```

For, if were to write this as an *interface literal* would separate the methods with a semicolon instead of a newline like:

```go
interface {io.Reader; fmt.Stringer}
```

Empty type sets -- 

```go
type Unpossible interface {
    int
    string
}
```

##### A struct type literal

```go
type Pointish interface {
    struct {X, Y int}
}

func GetX[T Pointish] (p T) int {
    return p.X // not work.
}
```

#### Approximations -- 

```go
type ApproximatelyInt interface {
    ~int
}
```

Derived types -- Approximations are especially useful with struct type elements -- like;

```go
type Pointish interface {
    struct {x, y int}
}

func Plot[T Pointish] (p T) {}
```

Can pass it values of type `struct{x, y int}` fore:

```go
type Point struct {
    x, y int
}

p := Point{1,2}
Plot(p) // error, Point does notimplement Pointish.
// should be:
type Pointish interface {
    ~struct {x, y int}
}
```

#### Interface literals

An interface literal, consists of the keyword `interface`followed -- Fore 

```go
func Identity[T interface{}](v T) T{}
```

We are not restricted to only *empty* interface literals -- could write an interface literal that contains a method element fore -- like:

```go
[T interface{~int}] // can be
[T ~int]
```

Can only omit the `interface`keyword when the constraint contains exactly **one** element so:

```go
func Increment[T interface{~int; ~float64}](v T) T {}
```

#### Referring to type parameters -- 

In some cases, we can write a constrint directly as an interface literal -- so U might be wondering -- can we refer to `T`inside the interface literal itself. 

```go
func Contains[T interface{Equal(T) bool}](s []T, v T) bool {...} // so only way say T

type Equaler interface {
    Equal(???) bool // can't say T here
}
```

### How `defer`are evaluated

`defer`statement delays a call’s execution until the surrounding function returns -- A common mistake made by Go developers is not understanding how arguments are evaluated -- delve into this with two subsections -- 

```go
const (
    StatusSuccess  = "success"
    StatusErrorFoo = "error_foo"
    StatusErrorBar = "error_bar"
)

func f() error {
    var status string
    defer notify(status)
    defer incrementCounters(status)
    
    if err := foo(); err != nil {
        status = StatusErrorFoo
        return err
    }
    if err := bar(); err != nil {
        status = StatusErrorBar
        return err
    }
    status = StatusSuccess
    return nil
}
```

For this, delcares a `status`variable, then we defer the calls to the `notify`and `incrementCounter`using `defer`. Throughout this func, and depending on the execution path, update `status`accordingly. Need to understand sth crucial about argument evaluation in a `defer`func -- the arguments are evaluated *right away* -- not once the surrounding function returns -- in the example, call `notify(status)`and `incrementCounter(status)`as `defer`functions, Go will delay the calls to be executed once `f`returns with the current value of `status`at the stage we used `defer`-- hence passing an empty string just.

Consider -- 

```go
func f() error {
    var status string
    defer notify(&status)
    defer incrementCounter(&status)
    //...
}
```

Keep updating the `status`depending on the cases, but now `notify`and `incrementCounter`receives a string pointer -- For the address, reamins constant, regardless of the assignment, hence, if `notify`or `incrementCounter`uses the value referened by the string pointer, will work as expected. But this solution requires changing the signature of the two functions -- may not always be possible.

There is another solution -- calling a *closure* as a `defer`statement -- A clousre is just an anonymous function value that references variables from outside its body -- the args passed to the `defer`func are evaluated right away -- but must know that variables *referenced by a `defer`closure are evaluted during the closure execution*. Fore:

```go
func main() {
    i := 0
    j := 0
    defer func(i int) {
        fmt.Println(i, j)
    }(i)
    i++
    j++
}
```

For `i`-- passed as a function argument -- so it’s evaluated immediately, conversely, `j`references a variable outside the closure body, so it’s evaluated when the closure is exected -- print `0 1`.

Therefore, we can use a closure to implement a new version of our function like:

```go
func f() error {
    var status string
    defer func() {
        notify(status)
        incrementCounter(status)
    }()
}
```

Here, wrap the calls both `notify`and `incrementCounter`within a closure -- this closure references the `status`variable from outside its body. Therefore, `status`is evaluted once the closure is executed, not when we call the `defer`-- this solution also workds and doesn’t require `notify`and `incrementCounter`to change their signature.

#### Pointers and Value receviers

If has:

```go
func main() {
    s := Struct{id: "foo"}
    defer s.print()
    s.id = "bar"
}

type Struct struct {
    id string
}

func (s Struct) print() {
    fmt.Print(s.id)
}
```

For this, calling the `defer`makes the receiver be evaluated immediately. So -- `defer`delays the method’s execution with a struct that contains an `id`field equal to `foo`. Therefore, this example just prints `foo`. Conversely, if the pointer is a receiver, the potential changes to the receiver after the call to `defer`are visible -- like:

```go
func main() {
    s := &Struct{id: "foo"}
    defer s.print()
    s.id="bar" // updates and print bar
}
```

The receiver is also evaluated immediately, howver, calling the method leads to copying the pointer receiver, hence, the changes made to the struct referenced by the pointer are visible.

### Verifying the user details

The next step is the interesting part - the core part of this verification logic will take place in the `Authenticate()`method of our use model -

1. First should rtreive the hashed pwd associted with the email address from our MySQL `users`table.
2. Otherwise, want to compare the hashed password from the `users`table with the plain-text.

```go
func (m *UserModel) Authenticate(email, password string) (int, error) {
	// retrieve the id and hashed pwd associated with the given email
	var id int
	var hashedPassword []byte
	stmt := "SELECT id, hashed_password from users where email=?"
	err := m.DB.QueryRow(stmt, email).Scan(&id, &hashedPassword)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, ErrInvalidCredentials
		} else {
			return 0, err
		}
	}

	// Check whether the hashed pwd and plain-text pwd match
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return 0, ErrInvalidCredentials
		} else {
			return 0, err
		}
	}

	// otherwise, the password is correct, return the user id
	return id, nil
}
```

Then use it in the handlers.go file like

```go
func (app *application) userLogin(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userLoginForm{}
	app.render(w, http.StatusOK, "login.html", data)
}

func (app *application) userLoginPost(w http.ResponseWriter, r *http.Request) {
	// Decode the form data into the userLoginForm
	var form userLoginForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// do some validation checks on the form, check both email and password
	// are provided, and also check the email UX-nicely
	form.CheckField(validator.NotBlank(form.Email),
		"email", "This field cannot be blank")
	form.CheckField(validator.Matches(form.Email, validator.EmailRX),
		"email", "This field must be a valid email address")
	form.CheckField(validator.NotBlank(form.Password),
		"password", "This field cannot be blank")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, http.StatusUnprocessableEntity, "login.html", data)
		return
	}

	// Check whether the credentials are valid
	// if not, add a generic non-field errors message
	id, err := app.users.Authenticate(form.Email, form.Password)
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.AddNonFieldError("Email or password is incorrect")
			data := app.newTemplateData(r)
			data.Form = form
			app.render(w, http.StatusUnprocessableEntity, "login.html", data)
		} else {
			app.serverError(w, err)
		}
		return
	}

	// use the RenewToken() on the current session to change the session Id
	// fore, it's a good practice to generate a new session ID when the authentication
	// state or privilege levels changes for the user
	err = app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, err)
		return
	}
	// Add the ID of the current user to the session so they are now "logged in"
	app.sessionManager.Put(r.Context(), "authenticatedUserID", id)
	// redirect
	http.Redirect(w, r, "/snippet/create", http.StatusSeeOther)
}
```

#### User logout

This brings us nicely to logging out a user -- implementing the user logout is straightforward in comparison to the signup and login -- essentially all we need to do is remove the `authenticateionUserID`value from their session:

```go
func (app *application) userLogoutPost(w http.ResponseWriter, r *http.Request) {
	// Use the RenewToken() on the current session to change the session ID
	err := app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, err)
		return
	}

	// Remove the authenticationUserId from the session data so that the user is logged out
	app.sessionManager.Remove(r.Context(), "authenticatedUserID")

	// Add a flash message to the session to confirm to the user that they logged out.
	app.sessionManager.Put(r.Context(), "flash",
		"Your have been logged out successfully!")

	// redirect the user to the app home
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
```

#### UserAuthorization

1. Only authentiated users can create a new snippet
2. The contents of the navigating bar changes depending on whether a user is authentiated or not.

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	isAuthenticated, ok := r.Context().Value(isAuthenticatedContextKey).(bool)
	if !ok {
		return false
	}
	return isAuthenticated
}
```

First, need to add a new `IsAuthenticated`field to our `tempalteData`struct -- like:

```go
type templateData struct {
    //...
    IsAutheticated bool 
}
```

Restircting access -- For this, the simplest way to do this is via some middleware -- like:

```go
func (app *application) requireAuthentication(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !app.isAuthenticated(r) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
			return
		}

		// otherwise, set the `Cache-Control: no-store` header so that pages
		// require authentication are not stored in the browser cache
		w.Header().Add("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}
```

#### Using Request context

At the moment our logic for authenticating a user consists of simply checking whether a `AuthenticatedUserID`value exists in the session data. We could make this check more robust by querying our `users`dbs to make sure that the `authentiatedUserID`value is real, valid, value.