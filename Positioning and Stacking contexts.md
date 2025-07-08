# Positioning and Stacking contexts

Look at one important technique -- `position`prop -- use to build dropdown menus, modal dialogs, and other essential effects for modern web apps -- positioning can get complicated -- it’s a subject of which many developers only have a cursory understanding.

The initial value of the `position`prop is `static`-- When U change this value to anything else, the element is side to be *positioned* -- An element with static positioning is thus *not positioned*.

The layout methods covered -- 

#### Fixed positioning

`position:flxed`-- lets U position the element in arbitrry within the viewport -- done with 4 comanion props -- `top, right, bottom`and `left`-- By setting these 4 values, also implicitly define the width and width of the element -- fore, specifying `left:2em; right: 2em`means the left edge of the element will be 2 em from the left side of the viewport.

Note can also use the shorthand counterpart -- `inset`-- to specify the location of the elements -- this can conveniently specify all 4 sides at once -- fore `inset:0`means 4 props set to 0. Fore `inset-block-start`...

#### Creating a modal dialog with fixed positioning -- 

Use these to build the *modal* dialog box -- this will pop up in front of the page content. Typically, will use a modal dialog to require the user to read sth or to input sth before continuing. Like:

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link href="1.css" rel="stylesheet">
</head>

<body>
    <header class="top-banner">
        <div class="top-banner-inner">
            <p>Find out what's going on at Wombat Coffee each
                month. Sign up for our newsletter:
                <button id="open" type="button">Sign up</button>
            </p>
        </div>
    </header>

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

    <main class="container">
        <h1>Wombat Coffee Roasters</h1>
    </main>

    <script>
        const button = document.getElementById('open');
        const close = document.getElementById('close');
        const modal = document.getElementById('modal');

        button.addEventListener('click', () => {
            modal.classList.add('is-open');
        });
        close.addEventListener('click', () => {
            modal.classList.remove('is-open');
        });
    </script>
</body>

</html>
```

For this -- is a banner across the top of the page -- it contains a button that just opens the modals. The second element is the moal dialog -- includes an empty `modal-backgrop`-- use to obscure the rest of the page. Just add the css like:

```css
body {
    font-family: Arial, Helvetica, sans-serif;
    min-height: 200vh;
    margin: 0;
}

/* overrides the user-agent fonts */
button,
input {
    font: inherit;
}

button {
    padding: 0.5em 0.7em;
    border: 1px solid #8d8d8d;
    background-color: #eee;
    border-radius: 5px;
    cursor: pointer;
}

.top-banner {
    padding: .5em;
    background-color: #ffd698;
    box-shadow: 0 1px 5px rbg(0 0 0 / 0.1)
}

.top-banner-inner {
    width: 80%;
    max-inline-size: 1000px;
    margin-inline: auto;
}

.container {
    width: 80%;
    max-inline-size: 1000px;
    margin: 1em auto
}

.modal {
    display: none;
}

.modal.is-open {
    display: block;
}
```

Have also added `font:inherit`to buttons and input fields -- this just overrides user-agent styles that apply some defult font settings to form elements. This is a common step that recommed adding to your stylesheets. Finally, the modal is removed from the page with `display:none`until the `is-open`class is added.

For now, to style modal itself -- will use fixed positioning twice -- use it on the `modal-backdrop`wiht the `inset`to set to 0.  This makes the backdrop fill the entire viewport. give it a background color of `rgb(0 0 0 / 0.5)`-- , 0 is completely transparent, and 1 is completely opaque. And the second place you will use fixed positioning is the `modal-body`-- will position each of its side inside the viewport: 3em, from the top and bottom edges and 20% from left and right sides. Just like:

```css
.modal-backdrop {
    position: fixed;
    inset: 0;
    background-color: rgb(0, 0, 0, 0.5);
}

.modal-body {
    position: fixed;
    inset-block: 3em;
    inset-inline: 20%;
    padding: 2em 3em;
    background-color: white;
    overflow: auto;
}
```

See a pale yellow banner across the top of the screen with a button.

#### Preventing the screen from scrolling while the modal is open

Scrolling the page while the modal is open is helpful for observing how fixed positioning works. However, it is not a great user experience. when a modal is in front of the main container of the page -- the user usually expects to be able to interact withou only the modal, not the other -- can fix this by applying `overflow:hidden`like:

```css
body.no-scroll {
    overflow: hidden;
}
```

Then add the Js code like:

```js
button.addEventListener('click', () => {
    modal.classList.add('is-open');
    document.body.classList.add('no-scroll');
});
close.addEventListener('click', () => {
    modal.classList.remove('is-open');
    document.body.classList.remove('no-scroll');
});
```

#### Controlling the size of positioned elements

When positioning an element, are not required to specify values for all 4 sides. Can specify only the sides U need and then use `width, height`to help determine its side.

## Inefficient map initialization

This section discusses an issue similar to one we saw with slice initialization, but using maps -- A `map`provides an unordered collection of k-v pairs in which all keys are distinct -- in Go, a map is based on the hash table structure. Internally, a hash table is an array of buckets, and each bucket is a pointer to an array of a key-value pairs. An array of 4 elements backs the hash table.

If want to initialize a map that will contain 1M elements -- like:

```go
m := make(map[string]int, 1000000)
```

With a map, can give the built-in function `make`only an initial size and *not a capacity*. By specify the `size`, provide a hint about the number of elements expected to go into a map -- internally, the map is created with an appropraite number of buckets to stroe 1M elements.

#### Maps and memory leaks

When working with maps in Go, need to understand some important characteristics of how a map grows and shrink -- 

```go
m := make(map[int][128]byte) 
n := 1_000_000
m := make(map[int][128]byte)

for i:=0; i<n; i++ {
    m[i]=randByes()
}
for i:=0; i<n; i++ {
    delete(m, i)
}
runtime.GC()
runtime.KeepAlive(m)
```

For this, we allocate an emtpy map, add 1 million elements, remove 1 m elements, and then run a GC, we also make sure to keep a reference to themap using the `runtime.KeepAlive(m)`so that the `map`isn’t collected as welll.

### Which type of receiver to use

In Go, can attach either a value or a pointer receiver to a method, with a value receiver, Go makes a copy of the value and passes it to the method.

```go
type customer struct {
    balance float64
}
func (c customer) add(v float64) {
    c.balance += v
}
func main() {
    c := customer{balance:100.}
    c.add(50.) // 100 
}
```

Should use:

```go
func (c *customer) add(operation float64) {
    c.balance += operation
}
```

One case needs more discussion -- say that we want design a different `customer`struct, like:

```go
type customer struct {
    data *data
}
type data struct {
    balance float64
}
func (c customer) add(operation float64) {
    c.data.balance += operation // 150
}

func main() {
    c := customer {data : &data {
        balance: 100,
    }}
    c.add(50.)
}
```

### Using named result parameters

And, named result paramters are an infrequently used option in Go -- When a result parameter is named, it’s initialized to its zero value when the function/method begins -- With named result parameters, can call a naked return statement. So, when is it recommended that use named result parameters -- like;

```go
type locator interface {
    getCoordinates(address string) (float32, float32, error)
}
```

Cuz this interface is unexported, documentation isn’t mandatory -- by reading this -- In this case, should probably use named result parameters -- like:

```go
type locator interface {
    getCoordinates(address string)(lat, lng float32, err error)
}
```

When to use named result parameter depends on the context -- in most cases, if it’s no clear whether using them makes our code more readable, shouln’t use named result parameters.

Also note that having the result parameters alredy initialized can be quite handy in some contexts -- like;

```go
func ReadFull(r io.Reader, buf []byte) (n int, err error) {
    for len(buf) > 0 && err == nil {
        var nr int
        nr, err = r.Read(buf)
        n += nr
        buf = buf[nr:]
    }
    return
}
```

In this example, having named result parameters doesn’t really increase readability.

### Unintended side effects with named result parameters

Mentioned why named result parameters can be useful in some situations -- but as these result parameters are initialized to their zero value -- using them can sometimes lead to subtle bugs if not careful enough. Fore:

```go
func (l loc) getCoordinates(ctx context.Context, address string) (
    lat, lng float32, err error) {
    isValid := l.validateAddress(address)
    if !isValid {
        return 0, 0, errors.New("invalid address")
    }
    if ctx.Err() != nil {
        return 0, 0, err
    }
}
```

The error in the `if ctx.Err()!=nil`, scope is `err`-- but havn’t assigned any value to the `err`-- it’s still assigned to the just *zero value* of an `error`type `nil`. So should:

```go
if err := ctx.Err(); err != nil {
    return 0, 0, err
}
```

### Returning a `nil`receiver

Discuss the impact of returning an interface and why doing so may lead to errors in some conditions. Consider the following example, will work on `Consumer`struct and implement a `Validate`method to perform sanity checks.

```go
type MultiError struct {
    errs []string
}
func (m *MultiError) Add(err error) {
    m.errs = append(m.errs, err.Error())
}
func (m *MultiError) Error() string {
    return strings.Join(m.errs, ";")
}
```

For this example, `MultiError`satisfies the `error`interface cuz it implements `Error() string`-- meanwhile, it exposes an `Add`method to append an error. If:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age<0 {
        m = &MultiError{}
        m.Add(errors.New("age is negative"))
    }
    if c.Name == "" {
        if m== nil {
            m = &MultiError{}
        }
        m.Add(errors.New("name is nil"))
    }
    return m
}
```

In this imp, `m`is initialized to the zero value of `*MultiErro`-- `nil`. For this, when a sanity check fails, allocate a new `MultiError`if needed and then append an error -- in the end, return `m`, which can eigher a `nil`pointer to a `MultiError`, depending on the checks.

```go
customer := Customer {Age:33, Name: "John"}
if err := customer.Validate(); err != nil {
    log...
}
```

In Go, have to know that a pointer receiver can be `nil`-- experiment by creating a dummy type and calling a method with a `nil`pointer receiver like:

```go
type Foo struct{}
func(foo *Foo) Bar() string {
    return "bar"
}
func main() {
    var foo *Foo
    fmt.Println(foo.Bar())
}
```

For this, `foo`is just initialized to the zero of a pointer, `nil`-- but this code compiles -- In Go, a method is just a syntactic suar for a function whose first parameter is the receiver, hence -- 

```go
func Bar(foo *Foo) string {
    return "bar"
}
```

So, passing a `nil`prointer to a function is just valid, therefore, using a `nil`pointer as a receiver is also valid. Like:

```go
func (c Customer) Validate() error {
    var m *MultiError
    //...
    if c.Age<0 {}
    if c.Name == "" {}
    return m
}
```

For this `m`is initialized to the zero value of a poitner `nil`-- then if all the checks are valid, the argument provided to the `return`statement *isn’t `nil`directly but a `nil`pointer.* Cuz a `nil`pointer is a valid receiver, converting the result into an interface won’t yield an `nil`value.

Therefore, regardless of the `Customer`provided, the caller of this function will always receives a non-nil error. So:

```go
func (c Customer) Validate() error {
    var m *MultiError
    //...
    if m != nil {
        return m
    }
    return nil
}
```

So at the end of the method, check whether `m`is not `nil`, if that is `true`, return `m`, otherwise, we return a `nil`explicitly.

### Don’t Use a filename as a function input

When creating a new function that needs to read a file, passing a filename isn’t considered a best practice and can have negative effects -- such as making unit tests harder to write -- Fore, suppose want to implement a function to count the number of empty lines in a file -- using the `bufio.NewScanner`to scan and check every line --

```go
func countEmptyLinesInFiles(filename string) (int, error) {
    file, err := os.Open(filename)
    if err != nil {
        return 0, err
    }
    
    // handle the file closure
    defer file.Close()
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        //...
        line := scanner.Text()
        if strings.TrimSpace(line)== "" {
            count++
        }
    }
    if err := scanner.Err(); err!= nil {
        return 0, err
    }
    return count, nil
}
```

For this, open a file from the filename, then use `bufio.NewScanner`to scan every line -- this function will do what we expect it to do -- But, we will read from it and returned the number of empty lines -- 

- A nominal case
- An emtpy file
- A file containing only empty lines

Each unit test will require creating a file in our Go proj -- the more complex the function is -- the more cases we may want to add, and the more files we will create, may have to create dozens of files in some cases -- Furthermore, this func isn’t reusable -- fore, if we had to implement the same logic but count the number of empty lines with an HTTP request, would have to duplicate the main logic -- 

```go
func countEmtpyLinesInHttpRequest(request http.Response) (int, error) {
    scanner := bufio.NewScanner(request.Body)
}
```

One way to overcome these limitations might be to make the function accept a `*bufio.Scanner`. Both functions have the same logic from the moment we create the `scanner`variable, so this approach would work. But in Go, the idiomatic way to start from the reader’s abstraction.

```go
func countEmptyLines(reader io.Reader)(int, error) {
    scanner := bufio.NewScanner(reader)
    for scanner.Scan() {
        //...
    }
}
```

Another benefit is related to testing -- mentioned that creating one file per test case could quickly become cumbersome -- now that `countEmptyLines`accepts an `io.Reader`-- can implement unit tests by creating an `io.Reader`from string -- 

```go
func TestCountEmptyLines(t *testing.T) {
    emptyLines, err := countEmptyLines(strings.NewReder(
    `foo
    	bar
    	
    	baz`
    ))
    // test logic
}
```

In this test, create an `io.Reader`using `strings.NewReader`from string literal directly.

## User authentication

For this -- going to add some user authentication functionality to our app -- so that only registered, logged-in users can create new snippets -- for this -- Will check the dbs to see if the email and pwd they entered match one of the users in the `users`table. If there is a match, the user has *authenticated* successfully and we add the relevant `id`value for the user to their session data -- using the key `authenticatedUserID`.

So when receive any subsequent requests, check just the user’s session data for a `authenticatedUserID`value -- if exists, know that the user has already successfully logged in. Can keep checking this until the session expires, when the user will need to log in again -- 

`userSignup, userSignupPost, userLogin, userLoginPost, userLogoutPost`.

Start by connecting the Dbs at the root suser and execute the statement like:

```sql
use snippetbox;
CREATE TABLE users (
	id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL
);
ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE (email);
```

##### Building the model in go

Next setup a model so that we can easily work with the new `users`table -- Will follow the same pattern that we used eariler in the book for modeling access the `snippets`table -- so just like:

```go
var(
    ErrInvalidCredentials = errors.New("models: invalid credentials")
    ErrDuplicateEmail = errors.New("models: duplicate email")
)
```

Define a new `User`type and a `UserModel`types with some placeholder methods for interacting with our dbs like:

```go
type User struct {
    ID int
    Name string
    Email string
    HashedPassword []byte
    Created time.Time
}

type UserModel struct {
    DB *sql.DB
}
```

#### User signup and pwd encryption -- 

Before can log in any users to the app first need a way to for them to sign up for an account. An HTML just like:

```html
{{define "main"}}
<form action='/user/signup' method='POST' novalidate>
    <div>
        <label>Name:</label>
        {{with .Form.FieldErrors.name}}
            <label class='error'>{{.}}</label>
        {{end}}
        <input type='text' name='name' value='{{.Form.Name}}'>
    </div>
</form>
{{end}}
```

`novalidate`in the `<form>`element disables the browser’s default form validation -- Cuz normally, browsers perform built-in checks on form inputs, ensuring required fields are filled or email contain valid format. When the `novalidate`is present, these checks are *bypassed*, allowing the form to be submitted without client-side validation.

For the signup form, using exactly the same form structure form -- `name, email`and `password`-- then upate the `handlers.go`file to include a new `useFSignupForm`struct that represent and hold the form data like:

```go
type userSignupForm struct {
    Name string `form:"name"`
    Email string `form:"email"`
    validator.Validator `form:"-"`
}

// update the handler so it displays the signup page
func(app *application) userSignup(w http.ResponseWriter, r *http.Request) {
    data := app.NewTemplateData(r)
    data.Form = userSignupForm{}
    app.render(w, http.StatusOK, "signup.html", data)
}
```

#### Validating the user input

When this form is submitted the data will end up being posted to the `userSignupPost`handler that we made -- just like:

```go
var EmailRX = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")

func MinChars(value string, n int) bool {
	return utf8.RuneCountInString(value) >= n
}

func Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}
```

Then head over `handlers.go`file and add some code to process the form and run the validation checks like so:

```go
func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
    // Declare an zero-valued instance of our struct
    var form userSignupForm
    
    err := app.decodePostForm(r, &form)
    //...
    // validate the form content using helper functions
	form.CheckField(validator.NotBlank(form.Name), "name",
		"this field cannot be blank")
	form.CheckField(validator.NotBlank(form.Email), "email",
		"This field cannot be black")
	form.CheckField(validator.Matches(form.Email, validator.EmailRX), "email",
		"This field must be valid format")
	form.CheckField(validator.NotBlank(form.Password), "password",
		"This field cannot be blank")
	form.CheckField(validator.MinChars(form.Password, 8), "password",
		"This field must be at least 8 characters long")
    // ...
}
```

#### Intruction to `bcrypt`

If your dbs is eer compromised by an attacker -- hugely important that it doesn’t contain the plain-text versions of your user’s password. To store a *one-way hash* of the pwd, dervied with a computationally expensive key-derivation function such as .. `bcrypt`, Go has implemented of these in the `golong.org/x/crypto`package -- 

```sh
go get golang.org/x/crypto/bcrypt
```

And there are two functions that we will use in this book -- the first is the `brcypt.GenerateFromPassword()`function which lets us create a hash of given plain-text password like so -- 

```go
hash, err := brcypt.GenerateFromPassword([]byte("my plain text passord"),12)
```

And this func will return a 60-character long hash which looks like base-64. The second parameter indicates the *cost* which is represented by an integer between 4 and 31. Need to note on the flip side, can check that a plain-text pwd matches a particualr hash using the `bcrypt.CompareHashAndPassword()`just like:

```go
hash := []byte("$2a$12$NuTjWXm3KKntReFwyBVHyuf/to.HEwTy.eS206TNfkGfr6GzGJSWG")
err := bcrypt.CompareHashAndPassword(hash, []byte("my plain text password"))
```

The `brypt.CompareHashAndPassword()`will return `nil`if matches.

##### Storing the user details -- 

Update the `UserModel.Insert()`method so that it creates a new record in our `users`table containing the valiated name, email and hashed password. This will be interesting -- want to store the brcypt hash of the pwd and second, also need to manage the potential error caused by a duplicate email -- 

Need to note that all errors returned by MySQL have a particular code, which can use to triage what has caused the error -- in the case, 1062 -- like:

```go
func (m *UserModel) Insert(name, email, password string) error {
	// create a bcrypt hash of the plain-text pwd
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	if err != nil {
		return err
	}
	stmt := `INSERT INTO users (name, email, hashed_password, created) 
		VALUES(?, ?, ?, UTC_TIMESTAMP())`

	// use the `Exec()` method to insert the user details and hashed password
	// into the users table
	_, err = m.DB.Exec(stmt, name, email, string(hashedPassword))
	if err != nil {
		var mySQLError *mysql.MySQLError
		if errors.As(err, &mySQLError) {
			if mySQLError.Number == 1062 && strings.Contains(mySQLError.Message,
				"users_uc_email") {
                // return the custom error
				return ErrDuplicateEmail
			}
		}
		return err
	}
	return nil
}
```

Can then finish this all off by updating the `userSignup`handler like -- 

```go
func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
    var form userSignupForm
    err := app.decodePostForm(r, &form)
    //...
    // check the error with form
    // for, NotBlank.. MinChars...
    if !form.Valid() {
        data := data.newTemplateData(r)
        data.Form = form
        app.render(w, http.StatusUnprocessableEntity, "signup.html", data)
        return
    }
    
    // Try to create a new user record in the dbs
    err = app.users.Insert(form.Name, form.Email, form.Password)
    if err != nil {
        //...
    }
    
    app.sessionManager.Put(r.Context(), "flash", "...please log in")
    app.Redirect(w, r, "/user/login", http.StatusSeeOther)
}
```

#### User Login

Update the `validator.go`file first -- 

```go
type Validator struct {
	NonFieldErrors []string
	FieldErrors    map[string]string
}

// Valid Update this method to also check `NonFiledErrors` slice
func (v *Validator) Valid() bool {
	return len(v.FieldErrors) == 0 && len(v.NonFieldErrors) == 0
}
func (v *Validator) AddNonFiledError(message string) {
    v.NonFiledErrors = append(v.NonFiledErrors, message)
}
```

For the login.html just like:

```html
{{define "title"}}Login {{end}}

{{define "main"}}
    <form action="/user/login" method="post" novalidate>
        <input type="hidden" name="csrf_token" value="{{.CSRFToken}}">
        {{range .Form.NonFieldErrors}}
            <div class="error">{{.}}</div>
        {{end}}
        <div>
            <label>Email:</label>
            {{with .Form.FieldErrors.email}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="email" name="email" value="{{.Form.Email}}">
        </div>
        ...
```

Then need to :

```go
type UserLoginForm struct {
    Email string `form:"email"`
    Password string `form:"password"`
    validator.Validator `form:"-"`
}

func(app *application) userLogin(w http.ResponseWriter, r *http.Request) {
    data := app.newTemplateData(r)
    data.Form= userLoginForm{}
    app.render(w, http.StatusOK, "login.html", data)
}
```

The next step is the interesting -- how we verify that the email and pwd submitted by a user are correct -- the core part of this verification logic will take place in the `UserModel.Authenticate()`method of our user model.

