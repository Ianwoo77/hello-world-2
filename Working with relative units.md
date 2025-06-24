# Working with relative units

When it comes to specifying *length* values, fore, CSS provides a wide array of options to choose from. Some other units, known as *relative* -- means based on external factors -- the meaning of 2em changes depending on which element you apply to.

##### The rise of responsive design

Fore, if give an element a width of 800px, how will that look in a smaller window -- in CSS, 1 em means just the *font size* of the current element -- exact value varies depending on the element you are applying it to. like:

```html
<span class="box box-small">Small</span>
<span class="box box-large">Large</span>
```

```css
.box {
    padding: 1em;
    border-radius: 1em;
    background-color: lightgray;
}

.box-small {
    font-size: 12px;
}
.box-large {
    font-size: 18px;
}
```

##### Using ems to define font-size

When it comes to the `font-size`prop, ems behave a little differently -- ems are defined by the current element’s font size -- if you declare `font-size: 1.2em`, A font size can’t equal 1.2 times itself, are derived from the inherited font size. If:

```html
<body>
    <p class="slogan">
        some coffee
    </p>
</body>
```

```css
body {
    font-size: 16px;
}
.slogan {
    font-size: 1.2em; /* calculates to 1.2 times the lement's inherited font size */
}
```

What makes ems tricky is when use them for both font size and any other properties on the same element. What is happening here is like:

```css
.slogan {
    font-size: 1.2em; /*19.2 */
    padding: 1.2em; /* 23.04px */
    background-color: #ccc;
}
```

Means that 19.2px is now this element’s value for an em, and that value is used to calculate the padding. The CSS for this -- `padding`has a specified value of 1.2em -- multiplied by 19.2px, produces value of 23.04px. `padding`is just 1.2em relative to the `.slogan`font size.

##### The shrinking font problem

Ems can produce unexpected results when use them to specify the font size of multiple nested elements. Need to know its inherited font size -- which, if defined on the parent element in ems, requires you to know the parent element’s inherited size and so on up the tree.

This become quickly apparent when use ems for font size of lists and then nest lists several levels deep. Like:

```css
body {
    font-size: 16px;
}
ul {
    font-size: .8em;
}
```

One way you can accomplish this is with -- this sets the font size of the first list to .8 em as before but second selector in the listing then targets all unordered within an unordered list -- like:

```css
ul ul {
    font-size: 1em;
}
```

#### Using rems for font-size

When the browser parses an HTML document, creates a representation in memory of all the elements on the page. This representation is called the DOM -- it’s a tree structure, where each element is represented by a node. The root node is the ancestor of all other elements in the document - -has a special pseudo-class selector -- `:root`that you can use to target it -- *rems are relative to the root element* - namely `<html>`element.

```css
:root {
    font-size: 1em;
}
ul {
    font-size: .8rem;
}
```

#### Setting a sane default font size

Say, want your default font size to be 14px -- 

```css
:root {
    font-size: .875em; 
}
```

```html
<div class="panel">
    <h2>Single-origin</h2>
    <div class="panel-body">
        We have built partnerships with small farms around the world to
        hand-select beans at the peak of season. We then carefully roast
        in <a href="/batch-size">small batches</a> to maximize their
        potential.
    </div>
</div>
```

The next listing shows the styles-- use ems for the padding and border radius -- `rem`for the font size of the heading, and `px`for the border like:

```css
.panel {
    padding: 1em;
    border-radius: .5em;
    border: 1px solid #999;
}

.panel > h2 {
    margin-top:0;
    font-size: .8rem;
    font-weight: bold;
    text-transform: uppercase;
}
```

This code puts a thin border around the panel and styles the heading. Opted for a header that is smaller but bold and all caps -- the `>`in the selector is a *direct descendant combinator* -- it indicates a direct parent-child relationship.

##### Making the panel responsive

Can use some media queries to change the base font size, depending on screen size -- a media query ues an `@media`rule to specify styles that will be applied only to certain screen sizes.

```css
:root {
    font-size: .85em;
}

@media(min-width:800px) {
    :root {
        font-size: 1em;
    }
}

@media (min-width:1200px) {
    :root {
        font-size: 1.15em;
    }
}
```

By applying these font-sizes at the root on your page, you have responsively redefined the meaning of em and rem throughout the entire page.

#### Resizing a single component

Can also use ems to scale an individual component on the page. Fore `<div class=“panel large”>`fore:

```css
.panel {
    font-size:1rem;
    ...
}
.panel > h2 {
    ...
    font-size: .8em;
}

.panel.large {
    font-size: 1.2rem;
}
```

#### Viewport-relative units

The *viewport* is the framed area in the browser window where the web page is visible. fore:

- `vh`-- 1% of viewport height
- `vw`- %1 of width
- `vmin`-- %1 for smaller dimension, height or width

##### Selecting from the newer viewport units

To address the problem of layout trashing, -- large and small viewports -- the *large viewport* is the biggest possible viewport when all the browser’s UX elements are hidden, and *small viewport* is the smallest possible one.

#### Unitless numbers and line-height

Some properties allow for unitless values -- `line-height, z-index, font-weight`fore. Can also use the unitless value 0 anywhere a length unit is required. A unitless 0 can be used only for length values and percentages. Note that the `line-height`prop is unusual in that it accepts **both** units and unitless values.

```css
body {
    line-height: 1.2; /* calculated locally to 38.4 cuz 32px * 1.2 */
}
```

#### Custom properties -- 

To define a custom property, declare it much like any other CSS property -- the next snippet is an example of a variable declaration -- fore:

```css
:root {
    --main-font: Helvetica, Arial, sans-serif;
}
```

For this listing, defines a variable named `--main-font`and sets its value to a set of common sans serif fonts. Name must begin with `--`to disntinguish it from other CSS properties.

A function called `var()`allows the use of variables -- you will use this function to reference the `--main-font`variable jsut defined -- add the ruleset shown in the following listing -- like:

```css
p {
    font-family: var(--main-font)
}
```

So, custom properties let U define a value in one palce, as a *single source of truth*. And note that the `var()`function accepts an optional second parameter, which specifies a fallback value -- If the variable specified in the first parameter is not defined, then the second is used instead -- 

```css
p {
    font-family: var(--main-font, sans-serif);
    color: var(--second-color, blue);
}
```

#### Changing custom properties dynamically

In the example so far, custom properties are merely nice convenience -- they can save you from a lot of repetition in your  code, but what makes them particularly interesting is that the declarations of custom proeprties cascade and inherit -- can define the same variable inside multiple selectors, and the variables will have a different value for various part of the page -- like:

```html
<body>
    <div class="panel">
        <h2>Single-origin</h2>
        <div class="body">
            We have built partnerships with small farms
            around the world to hand-select beans at the
            peak of season. We then careful roast in
            small batches to maximize their potential.
        </div>
    </div>
    <aside class="dark">
        <div class="panel">
            <h2>Single-origin</h2>
            <div class="body">
                We have built partnerships with small farms
                around the world to hand-select beans at the
                peak of season. We then careful roast in
                small batches to maximize their potential.
            </div>
        </div>
    </aside>
</body>
```

Then, redefine the panel to use variables for text and background color -- add the following listing to your stylesheet, just like:

```css
:root {
    --main-bg: #fff;
    --main-color: #000;
}

.panel {
    font-size: 1rem;
    padding: 1em;
    border: 1px solid #999;
    border-radius: .5em;
    background-color: var(--main-bg);
    color: var(--main-color);
}

.panel>h2 {
    margin-top: 0;
    font-size: .8em;
    font-weight: bold;
    text-transform: uppercase;
}

.dark {
    margin-top: 2em;
    padding: 1em;
    background-color: #999;
    --main-bg: 333;
    /* redefine the variables */
    --main-color: #fff;
}
```

## Types

Go’s type syatem can help us write correct programs -- by catching situations where we acidentally use a value of the wrong type. Fore, there is a function that takes an `int`parameter, tried to pass it a `float64`-- Go is always at your elbow to point out that kind of thing -- 

##### Named basic types -- 

Can use `int`for both of these fields -- fore;

```go
type (
	Age int
    HeightCM int
)
```

#### Generic basic types

```go
type MyT[T any] T // error
```

On the other hand, defining new composite types, such as slices, is entirely possible -- like:

```go
type Bunch[E any] []E
b := Bunch[int]{1,2,3}
```

And generic types -- are always instantiated -- that is in your compiled program, an abstract type such as `E`becomes some specific type, such as `int`-- that meanst that a generic slice type like `Bunch`fore, cannot contain elements of different types -- 

##### There are no generic types

```go
type Stuff []any
s := Sutff{1,2,3}
s = append(s, "hello")
```

#### Slices of interface types -- 

Just to add to the potential confustion, generic types can be instantiated on interface types, provided always that the interface in question matches the necessary constraint. Fore, instantiated `Bunch`on concrete type like `string`or `int`-- not restricted to only concrete types -- could perfectly well instantiated `Bunch`on some interface type like:

```go
var b Bunch[error]
b = append(b, errors.New("oh no"))
```

Note -- understand why the following two things are fundamentally different -- 

1. A slice of elements of type `any`
2. A slice of elements of type `E`, where `E`is `any`.

##### Generic map types

If parameterised slice types are Okay, what about maps -- should be able to create amp types where either the key type or element type are arbitrary -- Fore :

```go
type Catalog[V any] map[string]V
cat := Catlog[int]{}
cat["bogus"] // 0
```

For this, have instantiated `Catalog[V]`with the type `int`,  Creating a map of `string`to `int`. Fore:

```go
type Index[K, V any] map[K]V // error
```

Think about how map works -- if store a value in the amp with a certain key, expect to be able to retrieve the same key again later -- so:

```go
type Index[K comparable, V any] map[K]V
```

##### instantiating multiple type parameters

How do we explictly instantiate -- like:

```go
age := Index[string,int]{}
```

#### Generic struct types -- 

It seems like type parameters could be useful in defining generic struct types, too -- like:

```go
type NamedThing[T any] struct {
    Name string
    Thing T
}

// instantiate and use it without any difficulty
n := NamedThing[float64] {
    Name: "latitude",
    Thing: 50.46,
}
```

##### Self-reference

What if tried to do sth silly -- fore, instantiate a `NamedThing`on the `NamedThing`type itself -- disappear into a never-ending recursive hall of mirrors -- like:

```go
var n NamedThing[NamedThing] // error
```

Cuz there is really no such type as *NamedThing* -- there are only specific instantiations. To instantiate the outer `NamedThing`-- need to give a specific type in `[]`.

### Methods

Adding methods to generic types -- Take `Bunch`type, based on a slice, could write a `First`like:

```go
type Bunch[E any] []E
func(b Bunch[E]) First() E {
    return b[0]
}
```

Can write it once, and use it on any kind of `Bunch`we choose to instantiate. Fore:

```go
b := Bunch[string]{"a", "b", "c"}
fmt.Println(b.First())
```

Fore:

```go
func (s Sequence[E]) Empty() bool {
	return len(s) == 0
}

func TestEmptyIsTrueForEmptySlice(t *testing.T) {
	t.Parallel()
	s := dups.Sequence[int]{}
	if !s.Empty() {
		t.Fatalf("Empty(%v): want true, got false", s)
	}
}

func TestEmptyIsFalseForNonEmptySlice(t *testing.T) {
	t.Parallel()
	s := dups.Sequence[int]{1, 2, 3}
	if s.Empty() {
		t.Fatalf("Empty(%v): want false, got true", s)
	}
}
```

##### Parameterised methods

If can write methods on generic types, and already know can write generic functions, then could we write a generic method on a generic type -- that is could we write a method on a type as `Bunch[E]`that takes a parameter of some other arbitrary type -- like:

```go
func (b Bunch[E]) Printwith[T any](v T) {...} // error
```

So, methods cannot have type parameters in Go.

#### More generic composite types

```go
func Contains[T interface{Equal(T) bool}](s []T, v T) bool {...}
```

In other words, should be able to write this like:

```go
type Equaler[T any] interface {
    Equal(T) bool
}
```

##### Channels - 

```go
type MyChan[E any] chan E
ch := make(MyChan[error])
go func() {
    ch <-errors.New("oh no")
}()
```

### Function options pattern

The last approach discuss is the functional option pattern -- although there are differernt imps with minor variations, the main idea is as follows -- 

- An unexported struct holds the configuration -- `options`
- Each option is a func that returns just the same type -- `type Option func(options *options) error`

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
        options.port=&port
        return nil
    }
}
```

For this, `Withport`returns a closure, is an anonymous function that references variables from outside its body -- in this case, the `port`variable -- the closure respects the `Option`type and implements the port-variadation logic, each config field requires creating a public function containing similar logic.

```go
func NewServer(addr string, opts ...Options) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    
    var port int
    if options.port == nil {
        port = defaultHTTPPort
    }else{
        if *options.port==0 {
            port=randomPort()
        }else {
            port= *options.port
        }
    }
}
```

### Project organization

The Go language maintainer has no strong convention about structuring a proj in Go, one layout has emerged over the years -- poject-layout -- if our projects is small enough, or if our organization has already created its standard, may not be worth using or migrating to project. Otherwise, it might be wroth considering -- 

- `/cmd`-- main source files, the `main.go`file should live in `/cmd/foo/main.go`
- `/internal`-- private code that we don’t want others importing for their apps or libs.
- `/pkg`-- Public code that we want to expose to others.
- `/test`-- Additional external tests and tests data.
- `/configs`-- configuration files
- `/docs`-- Design and uses documents
- `/examples`
- `/api, /web, /build, /scipts, /vendor`

#### Package organization

In Go, there is no concept of subpackages -- however, can decide to organize packages with subdirectories. Take a look at the stdlib -- the net library is just orgnaized this way like:

`/net`
	`/http`
		`client.go`

For this, the `net/http`actually doesn’t inherit from `net`or have specific access rights to the `net`package. Elements inside of the `net/http`can only see exported `net`elements -- the main benefit of *subdirectories* is to keep packages in a palce where they live lith high cohesion.

### Creating utility packages

This is a common bad practice -- creating shared packages such as `utils...`Fore, an example by the offical Go blog -- about implementing a set data structure -- the idiomatic way to do this in Go is to handle it via `map[K]struct{}`with `K`can be comparable. Fore:

```go
package util
func NewStringSet(...string) map[string]struct{} {...}
func SortStringSet(map[string]struct{}) []string {...}
```

A client will use this package like this -- 

```go
set := util.NewStringSet("c", "a", "b")
fmt.Println(util.SortStringSet(set))
```

The problem here is that the `util`is meaningless - could call it any name. So, instead of a utility package, should create an expressive package name such as `stringset`-- fore:

```go
package stringset
func New(...string) map[string]struct{} {...}
//...
```

In this example, removed the suffixes just like:

```go
set := stringset.New("c", "a", "b")
fmt.Println(stringset.Sort(set))
```

Could even go a step further -- instead of exposing utility functions, create a specific type and exposes `Sort`

```go
package stringset
type Set map[string]struct{}
func New(...string) Set {...}
func (s Set) Sort() []string {...}
```

This change makes the client even simpler, there would only be one reference to the `stringset`pacakge 

```go
set := stringset.New("c", "a", "b")
fmt.Println(set.Sort())
```

With this small refactoring, get rid of a meaningless package name to expose an expressive API.

### Package name collisions

Package collisons occur when a variable name collides with an existing package name -- preventing the package from being reused -- like:

```go
package redis
type Client struct {...}
func NewClient() *Client {...}
func (c *Client) Get(key string) (string, error) {...}
```

Jump on the client side -- despite the package name `redis`-- it’s perfectly valid in Go to also create a variable name `redis`-- like:

```go
redis := redis.NewClient()
v, err := redis.Get("foo")
```

For this, the `redis`variable name collides with the `redis`package name -- even though this is allowed -- it should be avoided. Suppose that a qualifier references both a variable and a package name throughout a function. In that case, it might be ambiguous for a code reader to know what a qualifier refers to.

```go
redisClient := redis.NewClient()
v, err := redisClient.Get("foo")
```

This is probably the most straightforward approach. If for some reason we prefer to keep our variable named `redis`, can play with package imports. Just like:

```go
import redisapi "mylib/redis"
redis := redisapi.NewClient()
v, err := redis.Get("foo")
```

Here, used the `redisapi`import alias to reference the `redis`package so that we can keep our variable name `redis`.

### Working with session data

In this -- put the session functionality to work and use it to persist the confirmation flash message between HTTP request that-- like:

```go
// Use the Put() method to add a string value and the corresponding key
app.sessionManager.Put(r.Context(), "flash", "Snippet successfully created!")

// ... for the application
type application struct {
    //...
    sessionManager *scs.SessionManager
}
```

```sh
go get github.com/alexedwards/scs/v2
go get github.com/alexedwards/scs/mysqlstore
```

```sql
CREATE TABLE sessions (
	token CHAR(43) PRMIARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTAMP(6) NOT NULL
);
CREATE INDEX session_expiry_idx ON sessions (expirty);
```

Establish a sessin manager in our go file and make it available to our handlers via the application struct.

1. `Put()`is the current request context -- talk properly about what the request context is and how to use it later in the book -- for now you can just think of it as somewhere the session manager temporarily stores information while U handlers are dealing with the request.
2. `flash`is the key for the specific message that we are adding to the session data.

```go
// use the PopString() method to retreive the value from the `flash`key
flash := app.sessionManager.PopString(r.Context(), "flash")

data := app.newTemplateData(r)
data.Snippet = snippet

data.Flash= flash
```

```html
{{with .Flash}}
<div class="flash">{{.}}</div>
{{end}}
```

### Security improvements

In this, going to make some improvements to our appliation so that our data is kept secure during transit and our server is better able to deal with some common types of denial-of-service attcks.

- Quickly and easily create a self-signed TLS ceritificate
- The fundamentals of setting up your app so that all requests and responses are served securely over HTTPs
- Some sensible tweaks to the default TLS settings to help keep user info secure and our server performing quickly.
- Setting connection timeouts.

#### Generating self-signed TLS

For production serves -- <a>Let’s Encrypt</a> to create your TLs. But for development purposes the simplest thing to do is to generate your own self-signed certificate. In the `crypto/tls`package in Go’s stdlib includes a `generate_cert.go`tool that we can use to easily create our own self-signed certificate.

To un the `generate_cert.go`tool -- `/usr/local/go/src/crypto/tls`folder. LIke:

```sh
go run /usr/local/go/src/crypto/tls/generate_cert.go --rsa-bits=2048 --host=localhost
```

1. First  generates a 2048-bit RSA key pair, cryptographically secure *public key and private key*.
2. It then stores the private key in a `key.pem`file, and generates a self-signed TLS certificate for the host `localhost`containing the public key. stores in a `cert.pem`. Both private key and critercate are PEM encoded.

#### Running a HTTPs server

```go
err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")
//...
```

When run this, our server will still be listening on port 4000, the only difference is that it will now be talking HTTPs.

##### HTTP requests

It’s important to note that our HTTPs server only supports HTTPs. If U try making a regular HTTP request to it, the server will send the user a 400 bad Request status and the message.

A big plus of using HTTPs is that -- if a client supports `HTTP/2`connections, Go’s HTTPs server will automatically upgrade the connection to use HTTP/2.

##### Certificate permissions

It’s important to note that the user that you are using to run your Go app must have read permissions for both the `cert.pem`and `key.pem`files. Otherwise, `ListenAndServeTLS()`will return a *permission denied* error.

#### Configuring HTTPs Settings -- 

Go has good default settings for its HTTPS server, but it’s possible to optimize and customize how the server behaves -- one change -- which is almost always a good idea is to make.

```go
// Initialize a tls.Config struct to hold the non-default TLS settings we
// want the server to use. In this case the only thing that we're changing
// is the curve preferences value, so that only elliptic curves with
// assembly implementations are used.
tlsConfig := &tls.Config{
    CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
}

srv := &http.Server {
    //...
    TLSConfig: tlsConfig,
}
```

TLS versions are also defined as constants in the `crypto/tls`package, and Go’s HTTPs server supports TLS.