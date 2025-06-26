# Document flow and the box model

When it comes to laying out elements on the page, you will find a lot of things going on. On a complex site, you may have grids, abosolutely positioned elements, and other elements of various sizes -- you have a lot of things to keep track of, and learning everything involved with layout can be overwhelming. It’s important to have a solid grasp on the fundamentals of how the browser sizes and places elements -- the more advanced topics of layout are built atop concepts like document flow and box model.

#### Normal document flow -- 

Build simple with a header fore:

```html
<body>
    <header class="page-header">
        <h1>Frankln Running club</h1>
    </header>

    <div class="container">
        <main class="main">
            <h2>Come join us!</h2>
            <p>
                The <b>Franklin Running Club</b> meets at 6:00pm every Thursday at the
                town square. Runs are three to five miles, at your own pace.
            </p>
            <p>
                Join us while we train for the
                <a href="/st-patricks">St. Patrick's Day 5k</a>. Don't forget to wear
                green!
            </p>
        </main>

        <aside class="social-links">
            <a href="/mastodon" class="button-link">follow us on Mastodon</a>
            <a href="/facebook" class="button-link">like us on Facebook</a>
        </aside>
    </div>
</body>
```

For this, beginning with some of the obvious styles -- set the front for the page and then background colors for the page and each of the main containers -- 

```css
:root {
    --brand-color: #0072b0;
}

body {
    margin: unset;
    background-color: #eee;
    font-family: Arial, Helvetica, sans-serif;
}

.page-header {
    color: #fff;
    background-color: var(--brand-color);
}

.main {
    background-color: #fff;
    border-radius: .5em;
}

.social-links {
    background-color: #fff;
    border-radius: .5em;
}
```

Before begin adjusting the size of layout of these element, it’s worth talking note of how the page’s default layout behaves -- there are two basic types of element -- `inline`and `block`.

Inline flows along with the text of the page -- from left to right, note that will line wrap if they reach the edge of their container. Inline elements in our page including the `<b>`, and block elements appear on their own individual lines. They automatically fill with width of their container.

DEF -- Normal document flow refers to the default layout behavior of elements on the page -- Inline elements flow along with the text of the page, from left to right, line wrapping when they reach the edge of their container.

The important thing to note is that height and width are fundamentally different.

##### Centering content horizontally

Fore, want to constrain the width of the page’s main column -- cuz block-level elements fill the width of their container by default, generally don’t need to do anything like `width:100%`, So fore:

```css
:root {
    --brand-color: #0072b0;
    --column-width: 1080px;
}
.page-header h1 {
    max-width: var(--column-width);

    /* auto left and right margins will grow to fill the available space */
    margin: 0 auto;
}

.container {
    max-width: var(--column-width);
    margin: 0 auto;
}
```

For this, by setting a left and right margin of `auto`, the margins will automatically expand as much as necessary to fill the remaining width available in the ounter continer.

Using the `max-width`inside of `width`allows the element to shrink below 1080px if narrow than that.

##### Using logical properties

Normal document flow goes from left to right, top to bottom -- this is cuz most languages, including.. If right-to-left -- the W3C has done a lot fo work to introduce the concept of *logical properties* to CSS -- 

DEF -- *logical properties* provide a way to work with elements in terms of their block and inline directions -- which can change for different writing modes.

When using logical properties, swap out the concepts of horizontal and vertical for *inline base direction* and *block flow direction*, instead of setting `width`... can set the `inline-size`, the `inline-size`adapts to specify the height when sued with vertical writing modes. 

And, logical properties also replace top, right, bottom and left with `start`and `end`, thus, `padding-left`and `padding-right`-- `padding-inline-start`and `padding-inline-end`respectively. Or `border-top`and `border-bottom` become `border-block-start`and `border-block-end`.

Adapting to use logical properties is primarily a matter of becoming familar with these new names. Don’t need to change how you are laying out the page, just some of the terminology that you have become accustomed to.

| original                 | logical Properties          |
| ------------------------ | --------------------------- |
| `width`                  | `inline-size`               |
| `height`                 | `block-size`                |
| `margin-top`             | `margin-block-start`        |
| `text-align:left`        | `text-align:start`          |
| `border-top-left-radius` | `border-start-start-radius` |

##### Adopting useful shorthand logical properties

Some logical properties happen to provide shorthand approaches to common patterns. FORE, `margin-inline`allows U to set the start and the end margin at once without setting the other two margins. Can do sth like `margin-inline:2rem`to set start and end margins to 2rem or `margin-inline:2rem 4em`to set both start and end margins to 2 rem or `margin-inline: 2rem 4em`to set the start to 2rem and the end 4em.

So, can use this on your page for a slightly cleaner approach to the double-container pattern you are built. Update the stylesheet to this -- like:

```css
.page-header h1 {
    max-inline-size: var(--column-width);

    /* auto left and right margins will grow to fill the available space */
    margin-inline: auto;
}

.container {
    max-inline-size: var(--column-width);
    margin-inline: auto;
}
```

#### The box model

The next thing to address on the page you are rebuilding is some padding in the main container and the `social-links`box -- Currently, the text in these area is right up against the edges of the white background. Adding a little space there will make it look less crowded and more readable.

```css
.main {
    padding: 1em 1.5rem;
    background-color: #fff;
    border-radius: .5em;
}

.social-links {
    padding: 1em 1.5rem;
    background-color: #fff;
    border-radius: .5em;
}
```

However, by doing so, the left side of the text is no longer horizontally aligned with the text. This is cuz of the default behavior of the *box model* - -accoding to the box model, each element on the page is made up of 4 overlapping reactangels -- The *content area* is the innermost rectangle where the contents of the element reside. The *padding area* contains the current area plus any padding.

DEF -- the *box model* refers to the parts of an element and the size they contribute to their element. Fore, The behavior means that an element with 300px width, 10px padding, 1px border, so 322px, fore, `<h1>`had width 1080px, has its padding 24 and the content is now 706px fore. So the main content stayed 720px wide.

##### Avoiding magic numbers

Sometimes when encounter problems like this, the temptation can be fiddle with the values until it works. Imagine if, instead of 1080px width, your layout used 70% -- a navie fix might be reduce that .

##### Adjusting the box model

The default box model tends to cause problem, CSS allows you to adjust the box model with `box-sizing`prop, by default is `content-box`-- means that any height or width you specify sets the size of the only the content box. Can set to `border-box`-- with this, padding doesn’t make an element wider.

```css
.page-header h1 {
    box-sizing: border-box;
    max-inline-size: var(--column-width);

    /* auto left and right margins will grow to fill the available space */
    margin-inline: auto;
    padding-inline: 1.5rem;
}
```

Using the `box-sizing: border-box`, the padding is now counted within the 720px width.

##### Using universal border box sizing

Have made box sizing more intuitive for this element -- just do this with the universal selector `*`, which target all elements on the page -- like:

```css
*,
::after,
::before {
    box-sizing: border-box;
}
```

After applying this to the page, `height`and `width`will always specify the actual height and width of an element.

## Functions

One important consequence of generics -- then is the ability to write *utility* packages providing functions on arbitrary container types, such as slices.  A function that checks if the slice contains a certain element. Instead, everybody who wanted to do that operation in their programs just had to write it anew each time, for the specific slice type using. It’s not hard to implement `Contains`-- it’s hard to write a single version of `Contains`that works with multiple slice types.

```go
func Contains[E comparable](s []E, v E) bool {
    for _, vs := range s {
        if v == vs {
            return true
        }
    }
    return false
}
```

##### Reverse -- 

What about other operations on geneic -- 

```go
func Reverse[S ~[]E, E any](s S) S {
    result := make(S, 0, len(s))
    for i:= len(s)-1; i>0; i-- {
        result = append(result, s[i])
    }
    return result
}
```

For this time, don’t need `comparable`, cuz we won’t be doing any comparisons, All we need to do is loop over the input slice backwards, appending each element to the result slice.

##### Sort

Sorting a slice is another example of sth which can be a bit laborious without generics -- 

```go
sort.Slice(s, func(i, j int) bool {
    return s[i]<s[j]
})
```

Go knows perfectly will how to compare two integers with `<`, so why should we have to write a function to do -- 

```go
func Sort[S ~[]E, E cmp.Ordered](s S) S {
    result := make(S, len(s))
    copy(result, s)
    sort.Slice(result, func(i,j int) bool {
        return result[i] < result[j]
    })
    return result
}
```

#### First-class Functions

Go lets us use functions in the just the same way as many other kind of value. Functions can be passed as the parameters to other functions, or returned as results -- the technical way to say this is that Go has *first-class* functions -- before generics, the use of first-class functions in Go were rather limited by the need to always specify the type of thier parameters and results.

One common example of such a feature is *mapping* some function over a collection of elements. Applying the function to each element, with the final result being the transformed collection.

##### Map

Saying that the `Map`function takes some arbitrary function as parameter, along with a slice -- and applies the function to each element, returning the resulting slice. What does that look like -- first of all work out what the type of the arbitrary function needs to be.

Well, cuz it transforms an element of type `E`to another element of type `E`-- given this type a name, then, to make it easier to think about:

`type mapFunc[E any] func(E) E`
Now we can write a generic function that takes a `mapFunc[E]`and applies it to every element of a slice of `E`.

```go
type mapFunc[E any] func(E) E

func Map[S ~[]E, E any](s S, f mapFunc[E]) S {
	result := make(S, len(s))
	for i := range s {
		result[i] = f(s[i])
	}
	return result
}
```

Note that, like the `Identity`function in a previous chapter -- `Map`takes two type parameters -- the slice type *and* element type -- that is cuz like `Identity`-- it needs to returna result of the same type as whatever it was passed.

### Builder pattern

Originally part of the Gang of Four design pattterns -- The builder pattern provides a flexible solution to various object - creation problems. The construction of `Config`is separated from the struct itself. It requires an extra struct, `ConfigBuilder`-- which receives methods to configure and build a `Config`.

```go
tpye Config struct {
    Port int
}
type ConfigBuilder struct {
    port *int
}
func (b *ConfigBuilder) Port (port int) *ConfigBuilder {
    b.port= &port
    return b
}
func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port == nil {
        cfg.Port = defaultHTTPPort
    }else {
        if *b.port == 0 {
            cfg.Port= randomPort()
        }else if *b.port < 0 {
            return Config{}, errors.New("Port should be positive")
        }else {
            cfg.Port=*b.port
        }
    }
    return cfg.nil
}

func NewServer(addr string, config Config) (*http.Server, error) {
    //...
}
```

The `ConfigBuilder`struct holds the client configuration. It exposes a `Port`method to set up the port. Usually, such a configuration method returns the builder itself so that we can use method chaining. 

#### Functional options pattern

The last approach we still discuss is the functional options pattern -- there are different implemetations with minor variations, the main idea is as -- 

- An unexporteed struct hods the configuration
- Each option is a function that returns the same type `type Option func(options *options) error`. Fore, `WithPort`accepts an `int`argument that represents the port and returns an `Option`type that represents how to update the `option`struct.

```go
type options struct {
    port *int
}
type Option func(port int) error

func WithPort(port int) Optoin {
    return func (option *options) error {
        if port < 0 {
            return errors.New("port should be positive")
        }
        options.port = &port
        return nil
    }
}
```

Here, `WithPort`returns a closure. A *closure* is an anonymous function that references variables from outside its body. In this case, the `port`variable. The colusure respects the `Option`type and implements the port-validation logic. Each config field requires creating a public function containing smilar logic -- validating inputs if needed and updating the config struct.

Look at the last part on the provider side: The `NewServer`imp -- pass the options as variadic arguments -- hence, must iterate over these options to mutate the `Options`config struct.

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
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
    }else {
        if *options.port == nil {
            port = randomPort()
        } else {
            port = *options.port
        }
    }
}
```

Start by creating an empty `options`struct, then iterate over each `Option`argument and execute them to mutate the `options`struct -- once the `options`struct is built -- we can implement the final logic regarding port management. Because `NewServer`accepts variadic `Option`arguments, a client can now call this API by passing multiple options following the mandatory address argument -- fore:

```go
server, err := httplib.NewServer("localhost", httplib.WithPort(8080), httplib.WithTimeout(time.second))
```

## Connection timeouts

Take a moment improve the resilency of our server by adding some timeout settings -- like:

```go
srv := &http.Server{
    Addr:      *addr,
    ErrorLog:  errorLog,
    Handler:   app.routes(),
    TLSConfig: tlsConfig,

    // Add Idle, Read and write timeouts to the server
    IdleTimeout:  time.Minute,
    ReadTimeout:  5 * time.Second,
    WriteTimeout: 10 * time.Second,
}
```

All three of these timeouts - `IdleTimeout, ReadTimeout`and `WriteTimeout`are server-side settings which act on the underlying connection and apply to all requests irrespective of their handler or URL.

##### The `IdleTimeout`setting

By default, Go enables `keep-alive`on all accepted connections -- this helps reducy latency cuz a client can reuse the same connection for multipe requests without having to repeat the handshake. By default, keep-alive connections will be automatically closed after a couple of minutes -- this helps to clear-up connections where the users has unexpectedly disappeared -- due to a power cut client-side.

### User authentication

In this, add some user authentication functionality to our app -- registered, logged-in users can create new snippets, non-logged-in users will still be able to view, and will also be able up for an account.

1. A user will register by visiting a form at `/user/signup`and entering their name, email address and pwd, store this information in a new `users`dbs table
2. A user will log in by visiting a form at /user/login and entering their email address and pwd
3. Will then check the dbs to see if the email and pwd they entered match one of the users in the `users`table. If there is a match, the user has authenticated successfully and add the revelent `id`value for the user to their session data, using the key `authenticatedUserId`
4. When we receive any subseuqnet requests, we can check the user’s session data for a `authenticationUserID`value -- if exists, know that the user has already successfully logged in. If it exists, know that the user has already successfully logged in -- can keep checking this until the session expires, when the user will need to log in again. If there is no `authenticatedID`in the session, know that the user is not logged in.

#### Routes setup

Begin this section by adding five new routes to our application, so that it looks like this -- 

| METHOD | Pattern        | handler        | Action          |
| ------ | -------------- | -------------- | --------------- |
| GET    | `/user/login`  | userLogin      | display HTML    |
| POST   | `/user/login`  | userLoginPost  | Authenticated   |
| POST   | `/user/logout` | userLogoutPost | Logout the user |

Open up your handlers.go file and add placeholders for the five new handler functions as follows.

```go
func (app *application) userSignup(w http.RespsonseWriter, r *http.Request) {
    fmt.Fprintln(w, "Dispaly a HTML form for signing up a new user...")
}

func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Create a new user...")
}
// ...
router.Handler(http.MethodGet, "/user/signup", dynamic.ThenFunc(app.userSignup))
router.Handler(http.MethodPost, "/user/signup", dynamic.ThenFunc(app.userSignupPost))
router.Handler(http.MethodGet, "/user/login", dynamic.ThenFunc(app.userLogin))
router.Handler(http.MethodPost, "/user/login", dynamic.ThenFunc(app.userLoginPost))
router.Handler(http.MethodPost, "/user/logout", dynamic.ThenFunc(app.userLogoutPost))
```

```html
{{define "nav"}}
    <nav>
        <div>
            <a href="/">Home</a>
            {{if .IsAuthenticated}}
                <a href="/snippet/create">Create a new Snippet</a>
            {{end}}
        </div>

        <div>
            {{if .IsAuthenticated}}
                <form action="/user/logout" method="post">
                    <input type="hidden" name="csrf_token" value="{{.CSRFToken}}">
                    <button>Logout</button>
                </form>
            {{else}}
                <a href="/user/signup">Signup</a>
                <a href="/user/login">Login</a>
            {{end}}
        </div>
    </nav>
{{end}}
```

### Creating a users model

now that the routes are set up, need to create a new `users`dbs table and a dbs model to access it -- Start by connecting to MySQL from your terminal window as the `root`user and execute the following SQL -- 

```sql
CREATE TABLE users (
    id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL
);
ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE (email);
```

There is a couple of things worth pointing out about this table -- 

- The `id`field is an autoincrementing integer field and and the primary key for the table.
- The type of the `hashed_password`is `CHAR(60)`-- this is cuz we will be storing hashes of the user 
- Also added a `UNQUE`contraint on the `email`column and named it `user_uc_email`this contraint ensures that won’t end up with two users who have the same email address.