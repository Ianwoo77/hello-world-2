# collapsed margins

Something strange going on with the margins -- Haven’t applied any margin on the header or the container, yet, there is a gap between them. When top and/or bottom margins are *adjoining*, they overlap, combining to form a single margin -- This is referred to as *collapsing* -- the space below the header in figure -- is the result of collapsed margins.

```html
<header class="page-header">
        <h1>Frankln Running club</h1>
    </header>

    <div class="container">
```

This is just the standard CSS behavior for block-level elements in normal flow when there is no padding, border, or content separating them. To prevent -- like:

```css
.page-header {
    margin-bottom: 20px;
    padding-bottom: 1px; /* prevent collapse */
}
.container {
    overflow: auto;
    margin-top: 20px;
}
```

#### Spacing elements with a container

The interplay between the padding of a container and the margins of its contents can be tricky to work with -- add some styles to the social links at the end of your page and work through problems that might arise.

```css
.social-links {
    max-inline-size: 25em;
    padding: 1em 1.5rem;
    background-color: #fff;
    border-radius: .5em;
}

.button-link {
    display: block;
    padding:.5em;
    color: #fff;
    background-color: var(--brand-color);
    text-align: center;
    text-decoration: none;
    text-transform: uppercase;
}
```

Now the links are styled correctly, still need to figure out the spacing between them -- with margins -- U have options, could give them separate top and bottom margins or both. Can:

```css
.button-link + .button-link {
    margin-block-start: 1.5em;
}
```

##### Considering changing content

The spacing problem arises again -- Fore, add:

```html
<a href="/sponsors" class="sponsor-link">
    Become a sponsor
</a>
```

For this, can add css like:

```css
.sponsor-link {
    display: block;
    color: var(--brand-color);
    font-weight: bold;
    text-decoration: none;
}
```

##### Creating a more general solution -- 

Web designer -- Like applying glue to one side of an obj before you have determined whether U actually want to stick it to sth or what that sth might be. It looks like sth called *lobotomized owl selector* -- `*+*`. Like:

```css
.stack > * + * {
    margin-block-start: 1.5em;
}
```

### Mastering layout

CSS provides several tools you can use to control the layout of a web page -- Fore *Flexbox* -- Is a method for laying out elements on the page -- it’s primarily used for arranging elements in a row or column.

#### flexbox principles

Applying `display: flex`to an element turns it into a *flex container* -- and its direct children run into *flex items*. By default, flex items align side by side, left to right, all in one row. The flex container fills the available width like a block element, but the flex may not necessarily fill the width of their container -- the flex containers are all the same height, determined naturally by their contents.

Can also use `display: inline-flex`-- creates a flex container that behaves more like `inline-block`. It flows inline with other inline elements, but it won’t automatically grow to 100% width.

The items are placed along a line called *main axis* -- which goes from the *main start* to the *main end* -- Perpendicular to the main axis is the *cross axis* -- this goes from the *cross start* to the *cross end*. Fore a html like:

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link rel="stylesheet" href="1.css">
</head>

<body>
    <div class="container">
        <header>
            <h1>Ink</h1>
        </header>
        <nav>
            <ul class="site-nav">
                <li><a href="/">Home</a></li>
                <li><a href="/features">Features</a></li>
                <li><a href="/pricing">Pricing</a></li>
                <li><a href="/support">Support</a></li>
                <li class="nav-right">
                    <a href="/about">About</a>
                </li>
            </ul>
        </nav>

        <main class="flex">
            <div class="column-main tile">
                <h1>Team collaboration done right</h1>
                <p>Thousands of teams from all over the
                    world turn to <b>Ink</b> to communicate
                    and get things done.</p>
            </div>

            <div class="column-sidebar">
                <div class="tile">
                    <form class="login-form">
                        <h3>Login</h3>
                        <p>
                            <label for="username">Username</label>
                            <input id="username" type="text" name="username" />
                        </p>
                        <p>
                            <label for="password">Password</label>
                            <input id="password" type="password" name="password" />
                        </p>
                        <button type="submit">Login</button>
                    </form>
                </div>

                <div class="tile centered stack">
                    <small>Starting at</small>
                    <div class="cost">
                        <span class="const-currency">$</span>
                        <span class="cost-dollars">20</span>
                        <span class="const-cents">.00</span>
                    </div>
                    <a class="cta-button" href="/pricing">
                        Sign up
                    </a>
                </div>
            </div>
        </main>
    </div>
</body>

</html>
```

This HTML includes a linke to 1.css so like:

```css
*,
::before,
::after {
    box-sizing: border-box;
}

body {
    margin: unset;
    background-color: #709b90;
    font-family: 'Courier New', Courier, monospace;
}

.stack>*+* {
    margin-block-start: 1.5em;
}

.container {
    max-inline-size: 1080px;
    margin-inline: auto;
}
```

##### Building a basic flexbox menu

For this example, you will wan the navigational menu to look -- build -- should consider which element needs to be the flex container, keep in mind that its child elements will become the flex items -- In the markup, the `<ul>`a `site-nave`class -- use to target it in the style like:

```css
.site-nav {
    display: flex;
    padding: unset;
    list-style-type: none;
    background-color: #5f4b44;
}

.site-nav>li>a {
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}
```

Note what, are working with 3 levels of elements here -- the `site-nav`list, the list items and the achor tags within them -- used direct descendant combinations `>`to ensure you only target direct child elements.

##### Adding padding and spaing -- 

Our menu looks rather scawny at this point, flesh it out a bit with some padding. It’s important to note how to do that -- in this, you will apply the menu item paddint to the internal `<a>`element -- not the `<li>`element. So: Also noteice makde the links a display block -- also need to add space property between the menu items -- you can do this with margins, but flexbox has a special properties called `gap`-- fore, `gap: 1rem`. Additionally, flexbox also allows you to use the `margin: auto`to fill all available space between flex items. Also, applied the `auto`margin to the only one element for (About). Note just for the flexbox allows U to use `margin: auto`to fill all available space between flex items.

```css
:root {
    --gap-size: 1.5rem;
}
.site-nav {
    display: flex;
    gap: var(--gap-size);
    padding: .5em;
    list-style-type: none;
    background-color: #5f4b44;
}

.site-nav>.nav-right {
    margin-inline-start: auto;
}

.site-nav>li>a {
    display: block;
    padding: .5em 1em;
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}
```

For this, you applied the `auto`to only one element -- if were to apply it to -- there are more options for spacing flex items, including the ability to spread them out evenly acorss the entire flex container.

## Filter and reduction

`Filter`is the conventional name for a function that like `Map`-- takes an arbitrary function and applies it to each element of a slice. `Filter`uses it to decide which elements to keep and which to discard. `Filter`will take an arbitrary slice, and also an arbitrary function that decides which elements of the slice to keep -- fore:

```go
type keepFunc[E any] func(E) bool
```

So now can write `Filter`in terms of this `keepFunc`type like:

```go
func Filter[S ~[]E, E any](s S, f keepFunc[E]) S {
    result := S{}
    for _, v := range s {
        if f(v) {
            result = append(result, v)
        }
    }
}
```

##### Fitler functions 

What kind of `keepFunc`could we use in real program -- suppose want to filter a slice of integers to find only even values -- fore -- 

```go
func(v int) bool {
    return v%2 == 0
}
s := []int{1,2,3,4}
fmt.Println(Filter(s, func(v int) bool) {
    return v%2 == 0
})
```

##### Generic filter functions

We could certainly pass some existing *named* function, -- fore, `strings.ToUpper`-- 

```go
func IsEven[T any](v T) bool {
    return v%2 == 0
}
```

Thinking aoubt -- just should be :

```go
func IsEven[T constraints.Integer] (v T) bool {
    return v%2 == 0
}
```

#### Reduce 

This operation is sometimes also called *fold, inject*... In general, the function we pass to `Reduce`needs to take two things, value representing *current result* and the next slice element to combine with that. Like:

```go
type reduceFunc[E any] func(cur, next E) E {}

func Reduce[E any] (s []E, init E, f reduceFunc[E]) E {
    cur := init
    for _, v := range s {
        cur = f(cur, v)
    }
    return cur
}

// fore, try summing a slice for `Reduce` func
func (cur, next int) int {
    return cur + next
}

// use this
s := []int {1,2,3,4}
sum := Reduce(s, 0, func(cur, next int) int {
    return cur+next
})
```

#### Other considerations

Might be wondering why it’s okay to use any constraint in our reduction function -- seen in some previous example that `any`is too broad a constraint for some functions. If:

```go
func sumStructs(cur, next struct{}) struct {} {
    return cur + next // error, invalid operations
}
```

Compose yourself, *Composing* functions means that applying them in a chain, so that each function operates on the result of the previous one -- `outer(inner())`

Fore,  there are *three* type parameters involed here, fore:

```go
func Compose[T, U, V any](f func(U) T, g func(V) U, v V) T {
	return f(g(v))
}

func addOne(x int) int {
	return x + 1
}
func double(x int) int {
	return x * 2
}

func TestComposeAppliesFuncsInReverseOrder(t *testing.T) {
	t.Parallel()
	want := 4
	got := dups.Compose(double, addOne, 1)
	if got != want {
		t.Errorf("Compose(double, addOne, 1): want %d, got %d", want, got)
	}
}
```

### Containers

A `Set`is the sort of thing we’d often like to have available in Go programs - -it’s like a kind of compromise between a slice and a map -- a set is a collection of elements, all of the same type, but they are not in any specific order.

##### Maps as Sets

There are no built-in std set type in Go -- Often use a map type as a quick-and-dirty substitute for a set like:

```go
var validaCategory = map[string]bool {
    "Autobiography": true,
    "Large print"  : true,
    //...
}
```

##### Operations on sets

What kind of things would we like to be able to do with a set -- there are many possibilities -- but perhaps the most basic are adding an element -- like:

```go
s := NewSet[int]()
s.Add(1)
fmt.Println(s.Contains(1))
```

##### Designing -- 

Need sth to keep the actual data in. A map would make sense -- the `struct{}`is better, since they represent the items in our `Set`-- could use `bool`-- can be:

```go
type Set[E comparable] map[E]struct{}
```

For some comparable type `E`-- we are saying -- a `Set[E]`is a map of `E`to empty struct, basically, this is just the same sort of trick as we pulled wihtin the `validCategories`map, except that we are no longer restricted to just strings, can create a `Set`of any `comparable`type.

Since maps in Go need to initialised before can do much with them -- let’salso provide a constructor function `NewSet`-- 

```go
func NewSet[E comparable]() Set[E] {
    return Set[E]{}
}
```

#### Building out the machinery

Add some useful method -- start with a way to add new elements to the set. An `Add`method for sets is fairly simple to design -- should take some value of whatever our element type `E`is, and store it in the set.

```go
func (s Set[E]) Add(v E) {
    s[v] = struct{}{}
}
```

The `Contains`-- the next is to write `Contains`-- given some value of `E`it should return `true`if the value is in the set.

```go
func (s Set[E]) Contains(v E) bool {
	_, ok := s[v]
	return ok
}
func main() {
	s := set.NewSet[string]()
	s.Add("hello")
	fmt.Println(s.Contains("hello"))
}
```

### Funcional options pattern

The last approach we will discuss is the functional options pattern -- although there are different implmentations with minor variations -- the main idea is as follows -- 

- An unexported struct holds the configuration `options`
- Each option is a functoin that returns the same type `type Option func(options *options) error`, fore, `WithPort`accepts an `int`arg that represents the port and returns an `Option`type that represents how to update the `options`struct -- 

```go
type options struct {
    port *int
}
type Option func(options *options) error 
func WithPort(port int) Option {
    return func(options *options) error {
        if port < 0 {
            return errors.New("port should be positive")
        }
        options.port = &port
        return nil
    }
}
```

For this, the `WithPort`returns a closure, a *closure* is an anonymous function that references variables fomr outside its body. The coluse respects the `Option`type and implements the port-validation logic -- each config field requires creating a public function containing similar logic -- validating inputs if needed and updating the config struct.

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    
    // the options struct is built and contains the config
    var port int
    if options.port == nil {
        port = defaultHTTPport
    }else {
        if *options.port == 0 {
            port = randomPort()
        }else {
            port = *options.port
        }
    }
}
```

### Don’t create `utility`packages

This section discusses a common bad practice -- creating shared packages such as `utils common base`fore.

```go
package util 
func NewStringSet(...string) map[string]struct{} {...}
func SortStringSet(map[string]struct{}) []string {...}
```

So a client will use this package like this -- 

```go
set := util.NewStringSet("c", "a", "b")
fmt.Println(util.SortStringSet(set))
```

Fore, instead of utility package should create an expressive package name such as `stringset`fore

```go
package stringset
func New(...string) map[string]struct {} {...}
```

#### Package name collisions

Package collisions occur when a variable name collides with an existing package name -- preventing the package from being used -- look like:

```go
package redis
type Client struct{...}
func NewClient *Client {...}
func (c *Client) Get(key string) (string, error) {...}

// also create a variable named redis fore
redis := redis.NewClient()
v, err := redis.Get("foo")
```

For this, the `redis`variable name collides with the `redis`package name -- can use alias like:

```go
import redisapi "mylib/redis"
redis := resdisapi.NewClient()
v, err := redis.Get("foo")
```

### Code documentation

Documentation is an important aspect of coding -- simlifies how clients can consume an API but can also help in maintaining a proj -- in Go, should follow some rules to make our code idiomatic -- 

First every exported element *must* be documented -- whether it is a structure, an interface .. like;

```go
// Customer is a customer representation
type Customer struct{}

// ID returns the customer identifier
func (c Customer) ID() string {return ""}
```

As a convention, each eomment should be a complete sentence that ends with `.`

##### For Decrecated elements

It’s possible to deprecate an exported element using -- 

```go
// ComputePath returns the fatest path
// Deprecated: this function uses a deprecated way to compute
func ComputePath() {}
```

To help clients and maintainers understand a package’s scope, should also document each package -- the convention is to start the comment with `// Package`followd the name

```go
// Package math provides basic constants and mathmatical functions
//
// This package does not guarantee bit-identical results acorss architectures.
package math
```

Or to:

```go
// Copyright 2009 The go authors.
// use of ...
// Package math provides basic contents and mathematcial functions.
//
// This package does not guarantee bit-identical results across architectures
package math
```

## Using signup and password encryption

```html
{{define "main"}}
    <form action="/user/signup" method="post" novalidate>
        <input type="hidden" name="csrf_token" value="{{.CSRFToken}}">
        <div>
            <label>Name:</label>
            {{with .Form.FieldErrors.name}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="name" value="{{.Form.Name}}">
        </div>

        <div>
            <label>Email:</label>
            {{with .Form.FieldErrors.email}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="email" value="{{.Form.Email}}">
        </div>

        <div>
            <label>Password:</label>
            {{with .Form.FieldErrors.password}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="password">
        </div>

        <div>
            <input type="submit" value="Signup">
        </div>
    </form>
{{end}}
```

```sql
CREATE TABLe users (
	id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL
);
ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE(email);
```

For the type of the `hashed_password`field is `CHAR(60)`-- this is cuz we will be storing hashes of the user passwords in the dbs -- not the pwd themselves. Also added a `UNIQUE`constraint on the `email`column and named it `users_uc_email`-- this constraint ensures that we won’t endu up with two users who have the same email address.

#### Building the model in Go -- 

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

Then for this -- the `Insert, Authenticate, and Exists`methods added. Then add -- 

```go
type application struct {
    users *models.UserModel {DB:db}
}
```

For the dynamic html like:

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id < 1 {
        app.NotFound(w)
        return
    }
    snippet, err := app.snippets.Get(id)
    if err != nil {
        if erros.Is(err, models.ErrNoRecord) {
            app.notFound(w)
        }else {
            app.serverError(w, err)
        }
        return
    }
    
    // Initialize a slice containing the paths to the view file
    files := []string {
        "./ui/html/base.html",
        "./ui/html/partials/nav.html",
        "./ui/html/pages/view.html",
    }
    
    // parse the template files ...
    ts, err := template.ParseFiles(files...)
    if err != nil {
        app.ServerError(w, err)
        return
    }
    
    // then exuecte them
    err = ts.ExecuteTempalte(w, "base", snippet)
    if err != nil {
        app.serverError(w, err)
    }
}
```

Key  concepts -- 

- Define - `{{define “name”}}`action creates a named template block that can be invoked elsewhere using the `{{template “name”}}`
- Template -- `{{template “name”}}`action invokes a previously defined template by its name.
- Block -- similar to the `{{define}}`but can provide a default content like: `{{block “name” .}} default content {{end}}`

```go
type User struct {
	Name string
}

func main() {
	// Template with define and block
	tmpl := `
        {{define "header"}}Welcome, {{.Name}}!{{end}}

        {{block "content" .}}
        Default content for {{.Name}}.
        {{end}}

        Combined Output:
        {{template "header" .}}
        {{template "content" .}}
        `

	// Parse the template
	t, err := template.New("example").Parse(tmpl)
	if err != nil {
		panic(err)
	}

	// Data
	user := User{Name: "Bob"}

	// Execute the template
	err = t.Execute(os.Stdout, user)
	if err != nil {
		panic(err)
	}
}
```

