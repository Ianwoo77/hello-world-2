# Special values (II)

There are some speical values that you can apply to any property to help mainipulate the cascade -- `inherit, initial, unset`and `revert -- 

##### `inherit`keyword

Want inheritance to take place *when a cascaded value is preventing it* -- to do this, can use the keyword `inherit`. Can override another value with this, and will cause the element to inherit that value from its parent. Suppose add a light gray footer -- like:

```html
<footer class="footer">
    &copy; 2023 Wombat Coffee Roster &mdash;
    <a href="/terms-of-use">Terms of use</a>
</footer>
```

Earlier, applied some styles to all links on the page, and they will be applied to the Terms of Use link as well. Just:

```css
.footer {
    color: #666;
    background-color: #ccc;
    padding: 15px 0;
    text-align: center;
    font-size: 14px;
}

.footer a {
    color: inherit;
    background-color: transparent;
    text-decoration: underline;
}
```

For the `background-color:transparent`-- sets the background color of an element to be fully transparent, allowing any underlying content or parent element’s background to show through. And the `color: inherit`, it inheirts the color from its parent, `<footer>`

##### `initial`keyword

Sometimes find have styles applied to an element that you want to undo. Every CSS property has an initial, or default, value -- if U assign the value `initial`to that property, then it effectively resets to its *default value*.

##### The `unset`

The `inherit`and `initial`-- either inherited or non-inherited -- the `unset`is a *combination* of these two -- when applied to an inherited ones, just is `inherit`, and when applied to an non-inherited one, sets to `initial`. Fore, the color is inherited by default.

##### The `revert`-- 

Sometimes what U want is to override your previously set author styles but leave the user-agent styles intact.

```css
.footer a {
    color: unset;
    background-color: unset;
    text-decoration: revert;
}
```

So, CSS `revert`resets a property to the value it would have had if no changes had been made by the current style origin.

- For *inherited properties*, reverts to the parent’s value
- For *non-inherited* ones, reverts to browser’s default -- user-agent stylesheet.

#### Shorthand properties

Are properties that let U set the values of several other properties at one time.

```css
some {
    font: italic bold 18px/1.2 "Heletica"
}
```

##### Beaware shorthands silently overriding other styles

Most shorthand properties let U omit certain values and only specify the bits you are concerned with. It’s important to know -- doing this still sets the omitted values -- they will be set implicitly to their initial value.

```css
h1 {
    font-wight: bold;
}
.title {
    font: 32px Helvetica, Arial, sans-serif;
}
```

These styles are just equivalent the following code like:

```css
.title {
    font-style: normal;
    font-variant: normal;
    //...
}
```

##### TOP, RIGHT, BOTTOM, LEFT

Shorthand property order particularly trips up developers when it comes to properties like `margin`and `padding`or some of the border properties that specify values for each of the four sides of an element.

```css
.nav a {
    color: white;
    background-color: #13a4a4;
    padding: 10px 15px 0 5px;
    border-radius: 2px;
    text-decoration: none;
}
```

Properties whose values follow this pattern also support truncated notations, if the declaration ends before one of the four  sides is given a value, that side takes its value from the opposite side. Specify 3 values, fore, the `left`and `right`sides will both use the second values, and if 2, top and bottom will use the first.

`padding: 1em 2em 1em;`-- the left and right is `2em`.

Fore:

```css
.nav a {
    padding: 5px 15px; /* top/bottom will be 5, and 15px left/rigth */
}
```

#### Progressive enhancement

The simplest way to use progressive enhancement is built into the cascade itself -- like:

```css
aside {
    background-color: #333333; 
    background-color: #333333aa; // override
}
```

##### Enhancing selectors -- 

This approach is not limited to new properties or value syntax -- it can also be applied with new selector syntaxes -- it can also be applied with the new selector syntaxes -- There is an important nuance to be aware of, when a ruleset has multiple selectors, the browser will ignore the entire ruleset if any of the selectors are unsupported or invalid.

```css
input.invalid
input:user-invalid {
    border: 1px solid red;
}
```

For this, `:user-invalid`pseduo-class is a new addition to CSS.

When want to use a new selector like this, the best approach is to separate the two selectors into their own ruleset:

```css
input.invalid {
    border: 1px solid red;
}
input:user-invalid {
    border: 1px solid red;
}
```

##### Future queries using `@supports()`

Relying on the previously mentioned techniques is sufficient when the effect of using a new feature is small and only affects one or two CSS rules, but occasionally you will compared with those that don’t -- in this case, use a *featuure query* to provide a largest set of styles dpending on whether or not the browser supports a given feature.

```css
@support (display:grid) {...}
```

The `@support`rule is followed by a declaration in `()`-- and if the browser understands the declaration, it applies any rulesets that appear between the brackes. This means can provide one set of styles using older layout technologies like floats -- these will not ncessarily be ideal styles -- but will get the job done.

```html
<main>
    <p>Try some of our newest coffees:</p>
    <div class="coffees">
        <a href="/coffees/costa-rica">Costa Rica</a>
        <a href="/coffees/ethiopia">Ethiopia</a>
        <a href="/coffees/guatamala">Guatemala</a>
        <a href="/coffees/kenya">Kenya</a>
        <a href="/coffees/mexico">Mexico</a>
    </div>
</main>
```

Then you can add some styles to lay these links out in a grid -- like:

```css
.coffees {
    margin: 20px 0;
}

.coffees a {
    display: inline-block;
    min-width: 300px;
    padding: 10px 15px;
    color: black;
    background-color: transparent;
    border: 1px solid gray;
    border-radius: 5px;
}

@supports (display:grid) {
    .coffees {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 10px;
    }

    .coffees a {
        margin: unset;
        min-width: unset;
    }
}
```

If in a browser that doesn’t support grid, will see the fallback layout -- which is similar to the grid layout. Can imagine how the styles might apply if the `@supports`block is ignored, or can even momentarily comment it out in your stylesheet to test the fallback in modern browser.

- `@supports not(<declaration>)`-- only apply rules in the feature block if queried declaration is not supported.

- `@supports (<declaration>) or (<declaration>) `-- Apply if either declared is supported

- `@supports (<declaration>) and (<declaration>)`-- apply only if both supported

- `@supports selector(<selector>)`-- apply only if the given selector is understood -- fore:

  `@supports selector(:user-invalid)`

## Operations

Fore, use all 3 type sets together -- like:

```go
type Float interface {
    ~float32 | ~float64
}
type Complex interface {
    ~complex64 | ~complex128
}
type Number interface {
 	Integer | Float | Complex   
}
```

Now we have a number constraint that can use to parameterise any function that operates on numbers -- update the `AddAnything`to take this new constraint -- like:

```go
func AddAnything[T Number] (x, y T) T {
    return x+y
}
```

#### Ordered types

What about finding the greater of two numbers like:

```go
func Greater[T Number] (x, y T) T {
    if x>y {
        return x
    }
    return y
}
```

The `>`operator -- know that at least some of the type in `Number`'s type set support the `>`operator, fore, integers certainly do, and so do floats -- 

##### An `Ordered`interface

Here is one way we can write an interface whose type like:

```go
type Ordered interface {
    Integer | Float | ~string
}
```

##### The `cmp.Ordered`constraint

So useful, in deed -- it’s defined for us in the stdlib -- import the `cmp`package, can refer to this constraint as `cmp.Ordered`like:

```go
func Greater[T cmp.Ordered](x, y T) T {}
```

#### Multiple type parameters

Function on two or more types -- Write a version of our `Identity`function that takes values of *two* arbitrary types -- fore -- 

```go
func Identity [T, U any](x T, y U) (T, U) {
    return x, y
}
```

This hurts the eyes -- Just note that *each type parameter is a distinct type* -- FORE, can’t find which value is greater, using the `>`operator -- Because `T`and `U`are different types, and that operator can only work on values of the *same type*.

##### Functions on slice types

Here is another interesting case where multiple type parameters can be useful -- Consider a generic function that takes a slice of some arbitrary element type -- like:

```go
func Len[E any] (s []E) int {
    return len(s)
}

type StringList []string
```

If there is -- 

```go
func Identity[E any](s []E) []E {
    return s
}
```

##### The problem with derived slice types

But, there is a hidden problem -- Fore, use the `%T`verb with `fmt.Printf`to print out the *type* of the result returned by the `Identity`just like:

```go
result := Identity(StringList{"a", "b", "c"})
fmt.Printf("result is a %T\n", result)
```

We can see why this is happening if we replace the generic type parameter with the specific type involved. Well, `StringList`is *not* the same type as `[]string`-- even though they are mutually convertible. So

```go
func (s StringList) Len() int {
    return len(s)
}
func main() {
    result := Idenitty(StringList{"a", "b", "c"})
    fmt.Println(result.Len()) // error
}
```

##### Parameterizing by slice and element type -- 

Really want any function of this kind to return the exact the same type as it recevies. So:

```go
func Identity[s []E, E any](s S) S {}
```

Saying that the `Identity`just takes a type of `S`where `S`is a slice of any type `E`-- There is no important difference between this and what we had before. The point is that can now declare the function’s result type as `S`, whatever `S`turns out to be. Also need to note that Go is reminding us -- since `StringList`is derived from `[]string`, then need to add a type approximation -- using the `~`-- like:

```go
func Identity[S ~[]E, E any](s S) S {
    return s
}
```

Suffice it to say -- when we are writing functions that take slice types and return either a slice or an element of the same type, need to be a little bit careful -- While might be able to get *away* with a plain old `[E any]`constraint most of the ime -- makes our code less flexible then it should do. Instead, should use this more sophisicated `[S ~[]E, E any]`style to make sure that our function will behave correctly even in this case of derived slice types.

```go
func Clone[S ~[]E, E any](s S) S
```

#### Comparable types -- 

Probably the most common operation we do with two values in Go is *comparable* -- checking whether they are just equal -- how could we do that in generic function -- 

```go
func Equal[T any] (x,y T) bool {
    return x==y // error
}
```

Cuz the operator is not defined on all types -- fore, it’s not defined on slices, maps, channels..

##### Not every comparable type is ordered

```go
func Equal[T cmp.Ordered](x, y T) bool {
    return x==y
}

fmt.Println(Equal(1,2)) // false but function works
```

Have been too restrictive -- the point of generic functions is to accept as wide a range of types as possible -- And there are infinitely many comparable types -- So 

##### The `comparable`constraint

It’s clear very important to be able to compare value using `==`-- do this all the time in Go programs -- so not being able to do it in generic functions would be a severe limitation -- This is why Go just provides a predeclared constraint named `comparable`-- specifies exactly the set of comparable types -- Fore:

```go
func Equal[T comparable](x, y T) bool {
    return x==y
}
```

#### Abstract types

Armed with `comparable`and the `cmp.Ordered`constraint, we feel it should now be possible to write some interesting *non-trivial* generic functions -- Fore a `Greatest`function - Finding biggest element of a slice is a lot like finding the bigger of two values -- start by checking if the slice is empty -- cuz in that case it makes no sense to ask for its biggest element -- compare each element in turn with the biggest value -- use the `>`operator.

```go
func Greatest[S ~[]E, E cmp.Ordered](s S) E {
    if len(s) < 1 {
        panic("Greatest: empty slice")
    }
    var top E
    for _, e := range s {
        top = max(top, e)
    }
    return top
}
```

As with the `Greater`function we wrote - cuz know E is just *ordered*, we can sue `max`to find which of any two values is the greater.

##### The zero value

Sometimes in a Go function we want to return the *zero* value of whatever type we are dealing with. How can we do with an abstract type like `E`-- Well, we already know that all types in Go have a *default* value, which is the value a varialbe has if we haven’t yet assigned anything to it.

That’s just another name for the zero value, so using a `var`statement is one way to get a zero `E`-- 

```go
var top E
return top
```

Another possible way is to explicitly *convert* the constant 0 to `E`
`return E(0)`.

#### Switching on abstract types

Saw in the first chpater that when we have some ordinary parameter `x`of an interface type, can use a type switch to find out exactly what it concrete type is, and take the appropriate action -- 

```go
switch v := x.(type) {
case int:
    return v+y
case float64:
    return v+y
}
```

So might be wondering if we can pull the same switch, so to speak, with a parameter of some abstact type.

```go
func Identity[T any](x T) {
    switch x.(type) {
    case int:
        fmt.Println("looks like an int")
    case float64:
        fmt.Println("looks like a float")
    default:
        fmt.Println("dosn't look like anything to me")
    }
}
```

There is usually no reason to write a type switch in a generic function -- write a diferent version of the function for each specific type that we know how to handle -- `int, float64`...

```go
func Identity[T any](x T) {
    switch any(x).(type) {
        //...
    }
}
```

### Using functional options pattern -- 

When designing an API, one question may arise -- how do we deal with optional configuration -- solving this problem efficiently can improve how convenient our API will become - this section goes through a concrete example and covers different ways to handle optional configurations -- 

For this, say we have to design a library that exposes a function to create an HTTP server -- like:

```go
func NewServer(addr string, port int) (*http.Server, error) {
    //...
}
```

For this, the clients of our library have started to use this function, However, noticed that adding new function parameters breaks the compability -- forcing the clients to modify the way they call `NewServer`-- would like to enrich the logic related to prot management this way -- 

1. If the port isn’t set, use default one
2. negative, returns an error
3. 0 uses random port
4. otherswise, use provided one.

1. When a function or ctor has multiple optional parametrers
2. When want to maintain backward compatibility.
3. Wen want to improve code readability and usability
4. When need flexibility to future extension.
5. Avoid complex structs for configuration
6. Want to enforce immutability or validation

##### Config struct

Cuz Go doesn’t support *optional parameters* in function signatures -- the first possible approach is to use a configuration structure to convey what is mandatory and what’s optional -- like:

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config)
```

This solutin fixes the compability issue, If add new options, it will not break on the client side. For this, need to find a way to distinguish between a port purposely set to 0 and a missing port. So one option might t obe handle all the parameters of the configuration struct as pointers in this way -- like:

```go
type Config struct {
    Port *int
}
```

For using an integer pointer, can highlight the difference between the value 0 and a missing vlaue -- `nil`pointer -- this option would work -- also has a couple of downside -- not handy for clients to provide an integer pointer. First it’s noe handy for clients to provide an integer pointer -- like:

```go
port := 0
config := httplib.Config{
    Port: &port,
}
```

Also, a client using our lib with the default configuration will need to pass an empty structure in the way like:

`httplib.NewServer(“localhost”, httplib.Config{})`

#### Builder pattern

Originally part of the Gang of Four design patterns -- the builder pattern provides a flexible solution to various object-creation problem -- fore, the construction of `Config`is separated from the struct itself. Will require an extra struct:

```go
type Config struct{
    Port int
}
type ConfigBuilder struct {
    port *int
}

func (b *ConfigBuilder) Port(port int) *ConfigBuilder {
    b.port = &port
    return b
}

func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port == nil {
        cfg.Port = defaultHTTPProt
    }else {
        if *b.port==0 {
            cfg.Port = randomPort()
        }else if *b.port<0 {
            return Config{}, errors.New("port should be positive")
        }else {
            cfg.Port= *b.port
        }
    }
    return cfg, nil
}

func NewServer(addr string, config Config) (*http.Server, error) {
    //...
}
```

The `ConfigBuilder`struct holds the client configuration, it exposes a `Port`method to set up the port, usually, such as a configuration method returns builder itself  so that we can use method chaining. It also exposes a `Builder`method that holds the logic on initalizing the port value and returns a `Config`struct once created. Then, a client would use our builder-based API in the following manner -- like:

```go
builder := httplib.ConfigBuilder{}
builder.Port(8080)
cfg.err := builder.Build()
if err != nil {
    return err
}
server, err := httplib.NewServer("localhost", cfg)
if err != nil {
    return err
}
```

First, the client creates a `ConfigBuilder`and uses it to set up an optional field, such as the port. Then it calls the `Build`method and checks for errors -- the configuratrion is passed to `NewServer`. However, still need to pass a config struct that can be empty if a client wants to use the default configuration -- 

```go
server, err := httplib.NewServer("localhost", nil)
```

#### Function options pattern

The last approach will discuss is the functional option pattern. Although three are different implementation with minior variations, the main idea is as follows -- 

- An unexported struct holds the configuration: `options`
- Each option is a function that returns the same type -- `type Opiont func(options *options) error`-- fore, `WithPort`accepts an `int`argument that represents the port and returns an `Option`type that represents how to update the `option`struct.

Here is the Go imp for the `options`struct, the `Option`type, and the `WithPort`option -- like:

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
        options.port = &prot
        return nil
    }
}
```

For this, the `WithPort`returns a closure, a *closure* is an anonymous function that references varaibles from outside its body -- the `port`variable -- the closure respects the `Option`type and implements the port-validation logic -- Each logic field requires creating a public function containing similar logic -- validating inputs if needed and updating the config struct. Look at the last part on the provider side -- the `NewServer`imp -- pass the options as variadic arguments.

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    
    // at this stage, the options struct is built and contains the config -- 
    var port int
    if options.port == nil {
        port= defaultHTTPPort
    }else {
        if *options.port == 0 {
            port = randomPort()
        }else {
            port=*options.port
        }
    }
}
```

Start by creating an emtpy `options`struct -- then iterate over each `Option`argument and execute them to mutate the `options`struct, once the `options`struct is built, can implement the final logic regarding port management. Cuz `NewServer`accepts variadic `Option`arguments -- a client can now call this API by passing multiple options following the mandatory address argument -- like:

```go
server, err := httplib.NewServer("localhost",
                                 httplib.WithPort(8080),
                                 httplib.WitTimeout(time.Second))
```

However, if the lcient needs the default configuration, it doesn’t have to provide an arg -- the client just call

`server, err := httplib.NewServer(“localshot”)`

### Setting up the session manager

In this, run through the process of setting up and using `alexedwards/scs`package, but if you are going to use it in a production application recommend reading the documentation and API reference to famililarize yourself with full range of features. The first thing we need to do is create a `sessions`table in our MySQL dbs to hold the session data for our users.

```sql
CREATE TABLE sessions (
	token CHAR(43) PRIMARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTEAMP(6) NOT NULL
)
CREATE INDEX session_expiry_idx ON sessions (expiry);
```

- `token`field will contain a unique, randomly-generated identifier for each session.
- The `data`field will contain the actual session data that you want to share between HTTP requests. This is stored as *binary data* in a `BLOB`type
- The `expiry`field will contain an expiry time for the session. The `scs`package will automatically delete expired sessions from the `sessions`table so that it doesn’t grow too large.

The next thing we need to do is establish a *session manager* in our handlers via the `application`struct. The session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving of session data.

```go
type application struct {
    // ... 
    sessionManager *scs.SessionManger
}

func main() {
    app := &application {
        // ...
        sessionManager: sessionManger,
    }
    srv := &http.Server {
        //...
    }
    err = srv.ListenAndServe()
    errorLog.Fatal(err)
}
```

For the sessions to work, also need to wrap our application routes with the middleware provided by the `SessionManger.LoadAndSave()`method. This middleware automatically loads and saves session data with every HTTP request and response.

It’s imporant to note that we don’t need this middleware to act on *all* our application routes -- Specially, we don’t need  it on `/static/*filepath`route -- cuz all this does is serve static files and there is no need for any stateful behavior.

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    //...
    // Create a new middleware chain containing the middleware specific to our dynamic
    // application routes.
    dynamic := alice.New(app.sessionManger.LoadAndSave)
    router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
    //...
    standard := alice.New(app.RecoverPanic, app.logRequest, secureHeaders)
    return standard.Then(router)
}
```

