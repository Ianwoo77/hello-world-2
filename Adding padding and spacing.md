# Adding padding and spacing

Menu looks rather scrawny at this point. Flesh it out a bit with some padding. U will add padding to both the container and the menu links. Update the styles to match those in the next listing -- like:

```css
.site-nav {
    display: flex;
    padding: .5rem;
    list-style-type: none; /* Adds padding to menu */
    background-color: #5f4b44;
}

.site-nav > li > a {
    display: block;
    /* makes links block-levle, so it add to the parent's heigth */
    padding: .5em 1em; 
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}
```

Will notice you made the links a display block -- if they were to remain inline, the height they’d contribute to their parent would be dervied from their line height.

For `<a>`-- setting `display:block`makes these `<a>`element block-level -- meaning -- 

- They take up the full width of their parent `<li>`
- They start on a new line *within the `<li>`*
- Their height, including content, padding, borders and margins, contributes to the height of their parent.

Additionally, flexbox allows U to use `margin:auto`to fill all available space between flex items.

```css
.site-nav {
    display: flex;
    gap: var(--gap-size);
}
.site-nav > .nav-rigth {
    margin-inline-start: auto;
}
```

#### Flex item sizes

When it comes to sizing flexbox elements, can use the familar `width`and `height`properties -- but flexbox provides more options for sizing than these properties alone can accomplish.

The `flex`property controls the size of the flex items along the main axis -- Add the styles like:

```css
.tile {
    padding: 1.5em;
    background-color: #fff;
}

.flex {
    display: flex;
    gap: var(--gap-size);
}
```

Now your content is derived into two columns -- one the left is the larger area for the primary content of the page and on the right is a login form and a small pricing box -- haven’t done anything yet specify the width of the two columns.

For the `flex`property, which is applied to *flex items* -- gives U several options -- like:

```css
.column-main {
    flex: 2;
}

.column-sidebar {
    flex: 1;
}
```

The `flex`property is shorthand for 3 different sizing properties -- `size-grow, flex-shrink, flex-basis`, in this listing, will only supply `flex-grow`, and leaving other two default -- like:

`flex-grow:2`
`flex-shrink:1;`
`flex-basis: 0%`

##### `flex-basis`

This defines a sort of starting point for the size of an element -- means *initial main size*.
`flex-grow`-- Once `flex-basis`is computed for each flex item - they will add up to some width -- this width may not necessarily fill the width of the flex container, leaving a remainder. Declaring a higher flex grow value gives the element more weight -- take a larger protion of the remainder.

Flex-shrink -- follows the similar principles as `flex-grow` For the main axis, without `flex-shrink`, may result in overflow. the `flex-shrink`value for each item indicates whether it should shrink to prevent overflow. Items with a value greater than 0 means shrink unitl there is no overflow. Fore:

```css
.column-main {
    flex: 66.67%; /* 1 1 66.67% */
}
```

#### Some practical example

Can make use of the `flex`property in countless ways. Another important option in the flexbox is the ability to shift the direction of the axes -- the `flex-direction`property, applied to the flex container, controls this -- its initial value `row`causes the items to flow in the inline direction, Specifying `flex-direction: column`causes the flex items to stack vertically. Fore `row`, `row-reverse`, `column`and `column-reverse`.

##### Changing the flex direction

What need is for the two column to grow if necessary to fill the container’s height -- to do this, turn the right column into a flex container with `flex-direction: column`-- Then apply a non-zero `flex-grow`to both tiles within.

```css
.column-sidebar {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: var(--gap-size);
}

.column-sidebar>.tile {
    flex: 1;
}
```

Now have nested flexboxes -- The inner flexbox here has a flex direction of `column`-- so the main axis is rorated.

#### Styling the login form -- 

Now applied some -- All that remains is styling the smaller elements in the two tiles on the right -- 

```css
.login-form h3 {
    margin: 0;
    font-size: 0.9em;
    font-weight: bold;
    text-align: end;
    text-transform: uppercase;
}

.login-form input:not([type=checkbox]):not([type=radio]) {
    display: block;
    inline-size: 100%;
}

.login-form button {
    margin-block-start: 1em;
    border: 1px solid #cc6b5a;
    background-color: white;
    padding: 0.5em 1em;
    cursor: pointer;
}
```

Combined the `:not()`pseudo-class with the attribute selectors `[type=checkbox]`and `[type=radio]`-- this target will input elements except checkboxes and radio buttons.

### Alignment, saacing, and other details

- `flex-wrap`: `nowrap, wrap, wrap-reverse`
  - Speciefis wheter flex items will rap onto a new row inside the container.
  - Items will wrap onto a new column if `flex-direction`is `column`.
- `flex-flow`-- shorthand for `<flex-direction> <flex-wrap>`
- `gap`-- Species space between each flex items.
- `justify-content`-- `flex-start, start, left, flex-end, right, center, space-between, space-around, space-evenly`
  - Controls how items are positioned along the *main* axis.
- `align-content`: `flex-start-start, space-between, flex-end-end, center, space-around, space-evenly, stretch`
  - Controls the spacing of the flex row along the cross axis
  - ignored if flex wap is not enabled
  - ignore if items don’t wrap.
- `align-items`-- `flex-start-start, stretch, slef-start, flex-end-end, self-end, baseline`
- `align-self`-- `auto, center, stretch, baseline, flex-start-start, self-end`
  - controls how the item is aligned on the cross axis
- `order`-- An integer that moves a flex itme to a specific position.

## The `Contains`method

The next job is to write `Contains`method -- means, give some value of `E`, should return `true`if the value is in the set, or `false`otherwise.

```go
func (s Set[E]) Contains(v E) bool {
	_, ok := s[v]
	return ok
}
// try
s := NewSet[string]()
s.Add("hello")
fmt.Println(s.Contains("hello"))
```

#### Intialising with multiple values -- 

Modify the `NewSet`function to take any number of `E`values like:

```go
func NewSet[E comparable](vals ...E) Set[E] {
	s := Set[E]{}
	for _, v := range vals {
		s[v] = struct{}{}
	}
	return s
}
```

So, will make the same change to `Add`, so that we can add any number of new members in one go -- like:

```go
func (s Set[E]) Add(vals ...E) {
	for _, v := range vals {
		s[v] = struct{}{}
	}
}
// ready to roll
s := NewSet(true, true, true)
s.Add(true, true)
fmt.Println(s.Contains(false)) // false
```

##### Getting set’s members

```go
func (s Set[E]) All() []E {
	result := make([]E, 0, len(s))
	for v := range s {
		result = append(result, v)
	}
	return result
}
```

##### A `String`method

In fact, add a `String`method too -- can print the set in a nice way fore:

```go
func (s Set[E]) String() string {
	return fmt.Sprintf("%v", s.All())
}
```

#### Logic on sets

But part of the power of sets as a mathematical tool is that we can ask questions about how different sets relate to one another. Fore, which elements do a given pair of have in common -- 

##### union

Start by computing `untion`of two sets -- the set contains all the elements of both sets -- like:

```go
func (s Set[E]) Union(s2 Set[E]) Set[E] {
	result := NewSet(s.All()...)
	result.Add(s2.All()...)
	return result
}

func (s Set[E]) Intersection(s2 Set[E]) Set[E] {
	result := NewSet[E]()
	for v := range s {
		if s2.Contains(v) {
			result.Add(v)
		}
	}
	return result
}
```

##### Real-life example

Fore, suppose there is a job available which requires eiterh go or Java skills -- but like:

```go
func main() {
	jobSkills := set.NewSet("go", "java")
	mySkills := set.NewSet("go", "python")
	matches := jobSkills.Intersection(mySkills)
	if len(matches) > 0 {
		fmt.Println("you are hired")
	}
}
```

#### Exercise Stack overlow

```go
type Stack[E any] struct {
	data []E
}

func (s Stack[E]) Len() int {
	return len(s.data)
}

func (s *Stack[E]) Push(vals ...E) {
	s.data = append(s.data, vals...)
}

func (s *Stack[E]) Pop() (v E, ok bool) {
	if len(s.data) == 0 {
		return v, false
	}
	v = s.data[len(s.data)-1]
	s.data = s.data[:len(s.data)-1]
	return v, true
}
```

Then test that -- like:

```go
func TestPushPushPopPopLeavesStackEmpty(t *testing.T) {
	t.Parallel()
	s := stack.Stack[string]{}
	s.Push("a", "b")
	if s.Len() != 2 {
		t.Fatalf("got: %d; want: %d", s.Len(), 2)
	}
	s.Pop()
	want := "a"
	got, ok := s.Pop()
	if !ok {
		t.Fatal("Pop returned not ok on non-empty stack")
	}
	if want != got {
		t.Errorf("got: %q; want: %q", got, want)
	}
}
```

### Concurrency

Something that the built-in collection types in Go don’t have is concurrency safety -- that is to say, if one goroutine writes to a map, and antoher reads it concurrently, then a *data race* exists, and sth bad will happens. A best way to prevent data races on shared data is not have any mutable shared data.

##### Deadlocks

Another problem with mutexes when there is more than one, a *deadlock* can occur, bringing the program to a halt. Fore, each waiting for the other to go first, deadlocked goroutine will block each other forever -- a deadlock will cause your program to crash.

##### A concurrency-safe set type -- 

Locking -- use the stdlib `sync.RWMutex`type -- which allows us to get either a *read lock* or a *write lock* on the data. Start by writing sth like:

```go
type SetC[E comparable] struct {
	mux *sync.RWMutex
	data map[E] struct{}
}
```

Saying -- for some comparable type `E`, a `setC[E]`is a stuct containing a `*sync.RWMutex`field, and a `map[E]struct{}`field -- need to store a *pointer* to the mutex -- not the mutex value itself.

```go
func NewSetC[E comparable](vals ...E) *SetC[E] {
	s := &SetC[E]{
		mux:  &sync.RWMutex{},
		data: map[E]struct{}{},
	}
	for _, v := range vals {
		s.data[v] = struct{}{}
	}
	return s
}
```

#### A Lcoking `Add`method -- 

The behavior of `Add`on the type will be pretty much the same as before, with one important difference -- needs to lock the mutex before updating the map -- 

```go
func (s *SetC[E]) Add(vals ...E) {
	s.mux.Lock()
	defer s.mux.Unlock()

	for _, v := range vals {
		s.data[v] = struct{}{}
	}
}
```

##### The *read-lock* methods

What about `All`-- that also needs to be lock-aware -- but does it need a write lock -- cuz it doesn’t modify the data.

```go
func (s SetC[E]) All() []E {
	s.mux.RLock()
	defer s.mux.RUnlock()
	result := make([]E, 0, len(s.data))
	for v := range s.data {
		result = append(result, v)
	}
	return result
}
```

And `Contains`is also read-only, so can use the same strategy -- like:

```go
func (s SetC[E]) Contains(v E) bool {
	s.mux.RLock()
	defer s.mux.RUnlock()
	_, ok := s.data[v]
	return ok
}
```

#### Testing concurrency safety -- 

Need to use our new type concurrently-- 

```go
func main() {
	s := set.NewSetC(1, 2, 3)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		for i := range 1000 {
			s.Add(i)
		}
		wg.Done()
	}()
	for _ = range 1000 {
		_ = s.All()
	}
	wg.Wait()
	fmt.Println("we made it")
}
```

##### The race detector -- 

In fact, Go’s built-in data race detector would have caught this problem for us -- 

```sh
go run -race main.go
```

This underlines the importance of using the `-race`flag when testing any code involving concurrency. 

```go
func (s SetC[E]) Interactions(s2 SetC[E]) *SetC[E] {
	result := NewSetC[E]()
	s2.mux.RLock()
	defer s2.mux.RUnlock()
	for _, v := range s.All() {
		_, ok := s.data[v]
		if ok {
			result.Add(v)
		}
	}
	return result
}
```

### Inefficient slice initialization

While initializing a slice using `make`-- Saw that we have to provide a length and a capacity. Fore:

```go
func convert(foos []Foo) []Bar {
    bars := make([]Bar, 0)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

For this, at first `bars`is empty, so adding the first will allocate a backing array, note that every time the backing array is full, go creates another array by *doubling* its capacity. There are two different options for this -- 

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, 0, n)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

Internally, Go preallocates an array of `n`elements -- therefore, adding up to `n`elements means reusing the same backing array and hence reducing the number of allocations drastically. The second optoin is to allocate `bars`with a given length -- 

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, n)
    for i, foo := range foos {
        bars[i] = fooToBar(foo)
    }
    return bars
}
```

### Being confused aboutn `nil`vs. *empty slices*

May want to use one over the other depending on the use case -- 

- A slice is empty if its length is equal to 0
- A slice is `nil`if it equals `nil`

```go
func main() {
    var s []string // 0 value nil and empty
    s = []string(nil) // nil and empty
    s = []string{} // empty
    s = make([]string,0) // emtpy
}
```

In the case where we have to produce a slice with a known length, should use opion 4, `s := make([]string, length)`-- as this example like:

```go
func intsToStrings(ints []int) []string {
    s := make([]string, len(ints))
    for i, v := range ints {
        s[i] = strconv.Itoa(v)
    }
    return s
}
```

Can be helpful as syntactic sugar cuz can pass a `nil`slice in a single line fore using `append`like:

```go
s := append([]int(nil), 42)
```

### Not properly checking if a slice is empty

```go
func handleOperations(id string) {
    operations := getOperation(id)
    if operations != nil {
        handle(operations)
    }
}

func getOperations(id string) []float32 {
    operations := make([]float32, 0)
    if id == "" {
        // return operations // it's not a nil
        // should be
        return nil
    }
    // add elements
    return operations
}
```

### Not making slice copies correctly

The `copy`function allows copying elements from a source slice into a destination slice. Fore:

```go
src := []int {0, 1,2}
var dst []int
copy(dst, src)
```

In this, the `src`is 3L slice, but `dst`is zero-length, therefore, the `copy`copies the *minimum* number of elements 0 in this case. So:

```go
src := []int{0, 1,2 }
dst := make([]int, len(src))
copy(dst, src)
```

## Prepared statements

The `Exec(), Query()`and `QueryRow()`methods all use prepared statements behind the scenes to help prevent SQL injection attacks. In theory, a better approach could be to make use of `DB.prepare()`method to create your own prepared statement once, and reuse that instead.

```go
type ExampleModel struct {
    DB *sql.DB
    insertStmt *sql.Stmt
}

func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    // Use the prepare method to create a new prepared statement for the current conenction pool
    insertStmt, err := db.Prepare("INSERT INTO...")
    if err != nil {
        return nil, err
    }
    return &ExampleModel{db, insertStmt}, nil
}

func (m *ExampleModel) Insert(args...) error {
    // Notice how we call Exec directly against the prepared statement
    _, err := m.InsertStmt.Exec(args...)
    return err
}
```

#### Controlling loop behavior

Within a `{{range}}`action you can use the `{{break}}`command to end the loop early, and `{{continue}}`to immediately start the next loop iteration. Like:

```html
{{range .Foo}}
	{{if eq .ID 99}}
		{{continue}}
	{{end}}
{{end}}
```

#### Running HTTPS Server

```go
func main() {
    //...
    infoLog.Printf("Starting server on %s", addr)
    err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")
    errorLog.Fatal(err)
}
```

In Go, `http.Server`is a struct in `net/http`package used to configure and run an HTTP server, while `http.NewServerMux`creates a new `http.ServeMux`, the default multiplexer for routing HTTP requests to handlers. 

```go
func main() {
	// Create a new ServeMux
	mux := http.NewServeMux()

	// Register routes and handlers
	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Home page")
	})
	mux.HandleFunc("GET /hello", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Hello, world!")
	})

	// Configure the HTTP server
	server := &http.Server{
		Addr:         ":8080",           // Listen on port 8080
		Handler:      mux,              // Use the ServeMux as the handler
		ReadTimeout:  10 * time.Second, // Timeout for reading requests
		WriteTimeout: 10 * time.Second, // Timeout for writing responses
		IdleTimeout:  30 * time.Second, // Timeout for keep-alive connections
	}

	// Start the server
	log.Printf("Server running at http://localhost%s", server.Addr)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
```

#### Parsing form data

1. need to use the `r.ParseForm()`method to parse the request body. This checks that the request body is well-formed, and then stores the form data in the request’s `r.PostForm`map. Note that the `r.ParseForm()`is idempotent -- can safely called multiple times.
2. Then can get the form data using the `r.PostForm.Get()`method.

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {...}
    
    title := r.PostForm("title")
    content := r.PostForm.Get("content")
}
```

#### Middleware

- An idiomatic pattern for building and using custom middleware which is compatible with `net/http`and many 3rd-party packages -- 
- how to create middleware which sets useful security headers on every http response.
- How to create which logs the requests
- Recovers panics
- Middleware chains

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        next.ServeHTTP(w, r)
    })
}
```

In Go, the `http.Handler`interface, defined in the `net/http`, It is used by `http.Server`to process incoming requests, and works seamlessly with a multiplexer like `http.NewServerMux`. For the `http.HandlerFunc()`-- is that adapts a function with the signaure `func(http.ResponseWriter, *http.Request)`to implement the `http.Handler`interface.

`https.NewServeMux`-- 

- Creates a new `http.ServeMux`-- a request multiplexer that routes incoming requests to the appropriate `http.Handler`based on the URL patterns.
- Supports methods like `Handle`and `HandlerFunc`.

For `http.Server`-- A struct that uses an `http.Handler`to handle incoming HTTP requests.

```go
// CustomHandler is a struct that implements http.Handler
type CustomHandler struct {
	name string
}

// ServeHTTP makes CustomHandler satisfy the http.Handler interface
func (h CustomHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello from %s!", h.name)
}

func main() {
	// Create a new ServeMux
	mux := http.NewServeMux()

	// Register a custom handler (implements http.Handler)
	mux.Handle("GET /custom", CustomHandler{name: "Custom Handler"})

	// Register a function-based handler using http.HandlerFunc
    // which routes requests to the appropraite handler based on the URL and HTTP method
	mux.Handle("GET /home", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Welcome to the home page!")
	}))

	// Configure the HTTP server
	server := &http.Server{
		Addr:         ":8080",
		Handler:      mux, // Use ServeMux as the handler
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  30 * time.Second,
	}

	// Start the server
	log.Printf("Server running at http://localhost%s", server.Addr)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
```

Fore, panic recovery -- In a simple Go app, when code panics so:

```go
func (app *application) revcoverPanic(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
        defer func() {
            if err := recover(); err != nil {
                // set the header `Connection: close` on the response
                // automatically close the current conenction after a response has been sent
                w.Header().Set("Connection", "close")
                app.serverError(w, fmt.Errorf("%s", err))
            } 
        }()
    })
    next.ServeHTTP(w, r)
}
```

#### 3rd-party routing

```sh
go get github.com/julienschidt/httprouter@v1
```

Before get into this, begin a simple example to help demonstrate the syntax like;

```go
router := httprouter.New()
router.HandlerFunc(http.MethodGet, "/snippet/view/:id", app.snippetView)
```

For this initialize the `httprouter`router and use the `HandlerFunc()`method to add a new route which dispatches requests to our `snippetView`handler function.

Just note that patterns can include *named paraameters* in the form `:name`. which act like a wildcard for a specific path segment -- a request with a URL path like `/snippet/view/123`.

Patterns can also include a single *catch-all* pattern in form `*name`. like: `/static/*filepath`, also note that the pattern `/`will only match requests where the URL path is *exactly* `/`.

Updat the table in the `home.html`file so that the links the HTML also use the new clean URL style like:

```html
<tr>
	<td><a href="/snippet/view{{.ID}}">{</a></td>
</tr>
```

