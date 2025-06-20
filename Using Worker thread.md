# Using Worker thread

The key limitation of the example still only one main thread, and it still has to do all the work, regardless of how equitably that work is done.

Fundamentally, CSS is about declaring rules -- under various conditions, you want certain things to happen. The first step toward this is understanding how, exactly, the browser makes sense of your rules -- each runle may be straightward on its own.

```html
<body>
    <header class="page-header">
        <h1 id="page-title" class="title">Wombat Coffee Roasters</h1>
        <nav>
            <ul id="main-nav" class="nav">
                <li><a href="/">Home</a></li>
                <li><a href="/coffees">Coffees</a></li>
                <li><a href="/brewers">Brewers</a></li>
                <li><a href="/specials" class="featured">Specials</a></li>
            </ul>
        </nav>
    </header>
</body>
```

```css
h1 {
    font-family: serif;
}

#page-title {
    font-family: sans-serif;
}

.title {
    font-family: monospace;
}
```

For this, all 3 rules attempt to set a different font family to this heading -- which one win -- to determine - the browser follows a set of rules, so the result is predictable. This set of rules is called the *cascade* -- it determines how conflicts are resovled, and it’s a fundamental part of how the language works.

##### User-agent styles

The title is sans serif cuz of the styles you added -- a number of other things are determined by the user-agent styles. *After* user-agent styles are considered, the browser applies your stiles -- the author styles. And the user-agent styles set things you typically want, so they don’t do anything entirely unexpected.

```css
h1 {
    color: #2f4f4f;
    margin-bottom: 10px;
}

#main-nav {
    margin-top: 10px;
    list-style: none;
    padding-left: 0;
}

#main-nav li {
    display: inline-block;
}

#main-nav a {
    color: white;
    background-color: #13a4a4;
    padding: 5px;
    border-radius: 2px;
    text-decoration: none;
}
```

##### Important Declarations

There is an exception to the style origin rules -- declarations that are mared as important -- like:
`color: red !important;`So -- The overall order of preference -- 

- Important user-agent
- Important user
- Important author
- Normal Author
- Normal User
- Normal user-agent

#### Inline Styles -- 

If conflicting declaration can’t be resolved based on their origin, the browser next considers whether they are added to an element via inline style. When using an HTML style attribute to apply styles, the declarations are applied only to that element. Fore:

```html
<a href="..." class="featured" style="background-color: orange;">...</a>
```

Different types of selectors also have different specificities -- and ID selector has a higher specificity than a class selector -- a single ID has a higher specificy than a selector with any number of classes.

Just note that the *Pseudo-class* selectors fore `:hover`and attribute selectors fore `[type=“input”]`each have the same specificity as a class selector. The universal selector and combinators have no effect on specificity.

##### Specificity Considerations

When tried to apply the orange background using the `.featured`selector, it didn’t work,  Using `!important`can solve the problem but find a better way -- just like:

```css
#main-nav .featured {
    background-color: orange;
}
```

Can still make this better -- instead of rasing the specificity of the second selector, can lower the specificty of the first. the element has a class as well. So can change your CSS to target the element by its name rather than its ID. Fore:

```css
.nav {
    margin-top: 10px;
    list-style: none;
    padding-left: 0;
}

.nav li {
    display: inline-block;
}

.nav a {
    color: white;
    background-color: #13a4a4;
    padding: 5px;
    border-radius: 2px;
    text-decoration: none;
}

.nav .featured {
    background-color: orange;
}
```

In this solution, the specificities are equal -- source order determines which delcaration is apllied to your link.

```html
<main>
    <p>
        Be sure to check out
        <a href="/spaecials" class="featured">our specials</a>
    </p>
</main>
```

##### Link styles and source order

When began css, just add this to the stylesheet like:

```css
a:link {
    background-color: blue;
    color: white;
    text-decoration: none;
    padding: 2px;
}

a:visited {
    background-color: purple;
}

a:hover {
    background-color: transparent;
    color: blue;
    text-decoration: underline;
}

a:active {
    color: red;
}
```

For this, the cascade is the reason this order matters -- given the same specificity, later syltes override earlier styles. Namely, the last one can override the others. Note that you can also use `:any-link`to target `:link, :visited`.

### Inheritance

There is one last way that an element can receive styles -- inheritance -- the cascade is frequently conflated with the concept of inheritance. If an element has no cascaded value for a given property, it may inherit one from an ancestor element -- it’s common to apply a `font-family`, note that not all properties are inherited, by default, only certain ones are -- In general, there are the properties you will want to be inherited -- They are *primiarily properties* to **text**-- `color, font, font-family, font-size, font-weight, font-variant, font-style, line-height...`

A few others inherit as well, such as list properties, fore, `list-style, list-style-type, list-style-position`. Fore there was a:

```css
body {
    font-fmaily: sans-serif;
}
```

This is applied to the entire page by adding it to the body. But can also target a speecific element on the page.

## Returning interface

While designing a function signature, may have to return either an interface or a concrete implementation -- fore will consider two packages -- 

- `client`-- which contains a `Store`interface
- `store`-- which contains an implementation of `Store`.

And in the `store`, define an `InMemoryStore`struct that implements the `Store`interface -- create a `NewInMemoryStore`function to return a `Store`interface -- there is a dependency from the imp package to the client in this design -- Fore the `client`can’t call the `NewInMemoryStore`any more, otherwise, would be a cyclic dependency. So, if apply this idiom to Go -- means -- 

- Returning structs insted of interfaces
- Accepting interfaces if possible.

There are some exceptions -- The most relevant one concerns the `error`type -- an interface returned by many functions. Can also examine another just like in `io`package fore:

```go
func LimitReader(r Reader, n int64) Reader {
    return &LimitedReader{r, n}
}
```

### `any`says nothing

In Go, an interface type that specifies zero methods is known as the empty interface -- `interface{}`. If:

```go
type Customer struct {}
type Contract struct {}
type Store struct {}

func (s *Store) Get(id string) (any, error) {}
func (s *Store) Set(id string, v any) error {} // accepts any
```

By using `any`, just lose some of the benefits of Go as a statically typed language. Instead, should avoid `any`types and make our signatures explicit as much as possible.

### When to use generics

In a nutshell, this allows writing code with types that can be specified and instantiated when needed -- it can be confusing about when to use generics and when not to. If:

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k := range m {
        keys= append(keys, k)
    }
    return keys
}
```

Before generics, Go developers had a few options - using code generation, reflection, or duplicating code.

```go
func getKeys(m any)([]any, error) {
    switch t:= m.(type) {
    default:
        return nil, fmt.Errorf("unknown type: %T", t)
    case map[string]int:
        //...
    }
}
```

Note that, checking whether a type is supported is done at *run time* instead of *compile time*. Hence, also need to return an error if the provided type is unknown. Type parameters are generic types that we can use with functions and types -- fore -- 

```go
func foo[T any](t T) {...}
```

Get back to the `getKeys`and use type parameters to write a generic like:

```go
func getKeys[K comparable, V any](m map[K]V) []K {
    var keys []K
    for k := range m {
        keys= append(keys, k)
    }
    return keys
}
```

#### Common use and misuse

When are generics useful -- 

- Data structures - can use generics to factor out the element type if we implement a binary tree..

- Function working with slices, maps, and channels of *any* type.

  ```go
  func merge[T any](ch1, ch2 <-chan T) <-chan T {
      //...
  }
  ```

- Factoring our behaviors instead of types -- the `sort`package, fore, then implement this using generics like:

  ```go
  type SliceFn[T any] struct {
      S []T
      Compare func(T, T) bool
  }
  func (s SliceFn[T]) Len() int {return len(s.S)}
  //...
  ```

Conversely, when is it recommended that we not use generics -- 

- When calling a method of type argument.
- When makes code more complex.

### Not being aware of the possible problems with type embedding -- 

When creating a struct, Go offers the option to embed types -- but this can lead to unexpected behaviors -- In Go, a struct field is called embedded if it’s delcared without a name -- fore:

```go
type Foo struct {
    Bar
}
type Bar struct {
    Baz int
}
```

Fore, look at an example of a wrong usage -- in the following, implement a struct that hold some in-memory data -- 

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem {
    return &InMem {m: make(map[string]int)}
}
```

For this, decided to make the map unexported so that the clients can’t interact with directly but only via exported methods. Fore:

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v.contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

Cuz the mutex is embedded, can directly access the `lock`and `Unlock`from the `i`recevier. For this, the promotion is probably not desired -- a mutex is -- in most cases, sth that we want to encapsulate within a struct and make invisible to external clients.

### The `cmp.Ordered`constraint

It’s become clearer why might want to constrain type parameters in certain ways -- need to restrict the allowed types enough that we can guarantee that they will support the operator we are using. It’s defined for us in stdlib. If we import the `cmp`package, can refer to this contraint as `cmp.Ordered`-- like:

```go
func Greater[T cmp.Ordered](x, y T) T {...}
```

#### Multiple type parameters

```go
func Identity[T, U any](x T, y U) (T, U) {
    return x, y
}
```

##### Functions on slice types

Here is another interesting case where multiple type parameters can be helpful -- consider a generic function that takes a slice of some arbitrary element type -- 

```go
func Len[E any](s []E) int {
    return len(s)
}
```

And suppose we have defined some composite type `StringList`-- fore:

```go
type StringList []string
// can pass a value of that just like
fmt.Println(len(StringList{"a", "b", "c"}))
```

What if want to write some function that takes a slice and returns a slice of same type -- fore:

```go
func Identity[E any](s []E) []E {
    return s
}

// output
fmt.Println(Identity(StringList{"a", "b", "c"}))
```

##### The problem with derived slice types

But -- there is a hidden problem -- use the `%T`verb - like:

```go
result := Identity(StringList{"a", "b", "c"})
fmt.Printf("result is a %T\n", result) // []string not StringList
```

Can see why this is happening -- for the `Identity`function just like:

```go
func Identity(s []string) []string {...}
```

For this, the `StringList`is not the same type as `[]string`, fore, if defined some method on the `StringList`, wouldn’t be able to call it on `result`-- 

```go
func (s StringList) Len() int {
    return len(s)
}

func main() {
    result := Identity(StringList{"a", "b", "c"})
    result.Len() // error, undefined
}
```

#### Parameterizing by slicen and element type

Really want any function of this kind to return the exact same type as it receives -- even if that is a dervied type such as `StringList`-- One way to write that is to add another type parameter `S`-- which is itself defined in terms of `E`.

```go
func Identity[S []E, E any](s S) S {...}
```

Saying that `Identity`takes a parameter of typhe `S`, where `S`is a slice of any type `E`, there is no important difference between this and what we had before. And now it works -- like:

```go
result := Identity(StringList{"a", "b", "c"})
fmt.Println(result.Len()) // good
```

Almost, note that since the `StringList`is dervied from `[]string`, need to add a type appropriximation -- using:

```go
func Identity[S ~[]E, E any](s S) S {
    return s
}
```

For now it works -- like:

```go
result := Idenitty(StringList{"a", "b", "c"})
fmt.Println(result.Len()) // 3
```

#### Comparable types

Not every type is comparable -- If -- 

```go
func Equal[T any](x, y T) bool {
    return x==y
}// invalid operation
```

And there are infinitely many comparable types -- There are many such types. Structs are another example of *comparable* types that neverthless aren’t ordered.

##### The `comparable`constraint

It’s clearly very important to be able to compare values using `==`do this all the time in Go -- This is why Go provides a predeclared constraint named `comparable`-- it specifies exactly the set of comparable types -- 

```go
func Equal[T comparable] (x, y T) bool {
    return x==y
}
```

##### Why is `comparable`predeclared

Cuz the package is written in pure Go, and we already know that we can’t write comparable in Go, it has to be implemented internally by the compiler, which can already type-check expressions using the `==`to make sure allowed.

##### Exercise -- Duplicate keys

```go
func Dups[E comparable](s []E) bool {
	seen := make(map[E]bool)
	for _, v := range s {
		if seen[v] {
			return true
		}
		seen[v] = true
	}
	return false
}

func TestDupsIsTrueGivenNonConsecutieDuplicates(t *testing.T) {
	t.Parallel()
	s := []int{1, 2, 3, 1, 5}
	if !dups.Dups(s) {
		t.Error("got false; want true")
	}
}
```

## Creating validation helpers

Now in the position where our app is validating the form data according to our business rules and gracefully handling any validation errors. That’s great, but it’s taken quite a bit of work to got there -- Fore adding a validator package -- 

```go
type Validators struct {
    FieldErrors map[string]string
}

// Valid() returns true if the FieldErrors map doesn't contain any entries
func (v *Validator) Valid() bool {
    return len(v.FieldErrors) == 0
}

func (v *Validator) AddFieldError(key, message string) {
    if v.FieldErrors == nil {
        v.FieldErros = make(map[string]string)
    }
    if _, exists := v.FieldErrors[key]; !exist {
        v.FieldErrors[key]= message
    }
}

// adds an error message only if a validation check is not ok
func (v *Validator) CheckField(ok bool, key, message string) {
    if !ok {
        v.AddFieldError(key, message)
    }
}

func NotBlank(value string) bool {
	return strings.TrimSpace(value) != ""
}

func MaxChars(value string, n int) bool {
	return utf8.RuneCountInString(value) <= n
}

func PermittedValue[T comparable](value T, permittedValues ...T) bool {
	for i := range permittedValues {
		if value == permittedValues[i] {
			return true
		}
	}
	return false
}
```

Then in the `handlers.go`file just like:

```go
type snippetCreateForm struct {
    Title string
    Content string
    Expires int
    validator.Validator // embedded field
}
// ...
form := snippetCreateForm {
    //...
}
form.CheckField(validators.NotBlank(form.Title), "Title", "this field cannot be blank")
```

### Automatic form parsing

Another thing we can do to simplify our handlers is use a 3rd-party package like `go-playground/form`.. to automatically decode the form data into struct. Using an automatic decoder is just optional:

```sh
go get github.com/go-playground/form/v4@v4
```

In the main.go just like:

```go
type application struct {
    //...
    formDecoder *form.Decoder
}

func main() {
    //...
    // initialize a decoder instance
    formDecoder := form.NewDecoder();
    app := &application {
        //...
        formDecoder: formDecoder,
    }
}

// in the handlers.go file
type snippetCreateForm struct {
    Title string `form:"title"`
    Content string `form:"content"`
    Expires int `form:"expires"`
    validator.Validator `form:"-"`
}

func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    // ...
    // Declare a new empty instance of the snippetCreateForm struct
    var form snippetCreateForm
    
    err = app.formDecoder.Decode(&form, r.PostForm)
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
}
```

#### Creating a `decodePostForm`helper -- 

To assist with this, create a new `decodePostForm`helper with 3 things -- 

- Calls `r.ParseForm()`
- Calls `app.formDecoder.Decode()`to unpack the HTML form data to a target destination
- Checks for a `form.InvalidDecodeError`and triggers a panic if ever see it.

```go
func (app *application) decodePostForm(r *http.Request, dst any) error {
	// Call ParseForm() on the request
	err := r.ParseForm()
	if err != nil {
		return err
	}

	// call Decode() on our instance, passing the target destination as
	// first parameter.
	err = app.formDecoder.Decode(dst, r.PostForm)
	if err != nil {
		var invalidDecoderError *form.InvalidDecoderError
		if errors.As(err, &invalidDecoderError) {
			panic(err)
		}

		// for all other errors, just return
		return err
	}
	return nil
}
```

And with that, can make the final simiplification handler -- like:

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	// Declare a new empty instance of the snippetCreateForm type
	var form snippetCreateForm
	err := app.decodePostForm(r, &form)
    // ...
}
```

### Stateful HTTP

A nice touch to improve our user experience would be to display a one-time confirmation message which the user sees after they have added a new snippet. A confirmation message like this should only show up for the user once -- and no other uses should ever see the message.

To make this work, need to start sharing data -- between HTTP requests for the same user, the most common way to do that is to implement a *session* for the user.

#### Choosing a session manager

There are a lot of security considerations when it comes to working with sessions, and proper implementation is not trivial -- unless U really need to roll your own implementation -- For using the `alexedwards/scs`is generally the better option due to the ability to renew session IDs.

```sh
go get github.com/alexedwards/scs/v2
go get github.com/alexedwards/scs/mysqlstore
```

### Setting up the session manager

The first thing need to do is create a `sessions`table in our MySQL dbs to hold the session data for our users. Start by connecting to MySQL from your ternmial window as the `root`user and executed the following SQL statement to setup: just like:

```sql
USE snippetbox;

CREATE TABLE sessions (
    token CHAR(43) PRIMARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTAMP(6) NOT NULL
);

CREATE INDEX sessions_expiry_idx ON sessions (expiry);
```

- The `token`will contain a unique, randomly-generated, identifier for each session
- The `data`field will contain the actual session data that you want to share between HTTP requests. This is stored as binary data in a `BLOB`-- namely, binary large object type.
- The `expiry`field will contain an expiry time for the session. The `scs`package will automatically delete expired sessions from the `sessions`table so that it doesn’t grow too large.

The next thing we need to do is establish a session manager in our `main.go`file and make it available to our handlers via the `application`struct -- the session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving of session data.

```go
type application struct {
    //...
    sessionManager *scs.SessionManager
}

func main() {
    // ...
    sessionManager := scs.New()
    sessionManager.Store=mysqlstore.New(db)
    sessionManager.lifetime = 12 * time.Hour
    
    app := &application {
        //...
        sessionManager: sessionManager,
    }
    srv := &http.Server {
        //...
    }
    err = srv.ListenAndServe()
}
```

So, for the sessions to work, also need to wrap our application routes with the middleware provided by the `SessionManager.LoadAndSave()`method. This middleware automatically loads and saves session data with every HTTP request and response. It’s important to note that we don’t need this middleware to act on *all* our application routes -- Specifically, don’t need it on the `/static/*filepath`route.

```go
func (app *application) routes() http.Handler {
    //...
    dynamic := alice.New(app.sessionManager.LoadAndSave)
    
    // for get, post... using the dynamic middleware.
    router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
    // ...
    standard := alice.New(app.recoverPanic, app.logRequest, secureHandlers)
    return standard.Then(router)
}
```

It’s important to note that we don’t need this middleaware to act on all our applciation routes. Specifically, don’t need it on the fore `/static/*filepath`route.
