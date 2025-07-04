# Numbering grid lines

With the grid track defined, the next portion of the code places each grid item into a specific location on the grid. Fore: the grid’s definition like:

```css
*,
::before,
::after {
    box-sizing: border-box;
}

:root {
    --gap-size: 1.5rem;
}

body {
    background-color: #7090b0;
    font-family: 'Courier New', Courier, monospace;
}

.stack>*+* {
    margin-block-start: 1.5em;
}

.container {
    display: grid;
    grid-template-columns: 2fr 1fr;
    /* defines 4 horizontal lines of size auto*/
    grid-template-rows: repeat(4, auto);
    gap: var(--gap-size);
    max-inline-size: 1080px;
    margin-inline: auto;
}

header,
nav {
    grid-column: 1/3;
    grid-row: span 1;
    /* span exactly one row*/
}

.main {
    grid-column: 1/2;
    grid-row: 3/5;
}

.sidebar-top {
    grid-column: 2/3;
    grid-row: 3/4;
}

.sidebar-bottom {
    grid-column: 2/3;
    grid-row: 4/5;
}

.tile {
    padding: 1.5em;
    background-color: #fff;
}

.tile> :fist-child {
    margin-top: 0;
}
```

This css code defines a grid layout with some specific properties, including the use of `repeat(4, auto)`-- means that the grid will have 4 rows, and each’s height will set to `auto`. The `auto`means that the row will automatically adjust its size to fit the content of the grid items placed in that row. 

And the `grid-row: span 1;`-- means each occupies exactly one row. Can also define a repeating pattern with the `repeat()`notation, fore, `repeat(3, 2fr, 1fr)`defines 6 six gird tracks by repeating the pattern 3 times. Or can just use `repeat`as aprt of a longer pattern. Fore:

`grid-template-columns: 1fr repeat(3, 3fr) 1fr`, defines a 1fr column followed by 3 fr then another 1fr.

##### Numbering grid lines

With the grid tracks defined, the next portion of the code places each grid item into a specific location on the grid. The browser assigns number to each grid line in a grid. Fore:

```css
.main {
    grid-column: 1/2; /* spanning 1 to 2 */
}
```

Can use the grid numbers to indicate where to place each gird item using the `grid-column`and `grid-row`properties. And the rules that places the `header`and `nav`at the top of the pages is a little bit different -- like:

```css
header,
nav {
    grid-column: 1/3;
    grid-row: span 1;
}
```

`span`tells the brwoser that the item will span one grid track, so the grid item will be placed automatically using the grid item *placement algorithem*.

#### Working with the flexbox

- Flexbox is basically one dimensional, whereas grid is two-D
- Flexbox works from the content out, whereas grid works from the layout in.

Cuz flexbox is just 1-D, so it’s ideal for rows of similar elements. With a grid, you are first and foremost describing a layout, then placing items into that structure. The styles to do this are identical to those from the styles, minus the hgih-level layout, just like:

```css
.page-heading {
    margin: 0;
}

.site-nav {
    display: flex;
    gap: var(--gap-size);
    margin: 0;
    padding: .5em;
    background-color: #5f4b44;
    list-style-type: none;
}

.site-nav>li>a {
    display: block;
    padding: .5em 1em;
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}

.site-nav>.nav-right {
    margin-inline-start: auto;
}

.login-form h3 {
    margin: 0;
    font-size: .9em;
    font-weight: bold;
    text-align: right;
    text-transform: uppercase;
}

.login-form input:not([type="checkbox"]) :not([type="radio"]) {
    display: block;
    width: 100%;
}

.login-form button {
    margin-block-start: 1em;
    border: 1px solid #cc6b5a;
    background-color: white;
    padding: 0.5em 1em;
    cursor: pointer;
}

.centered {
    text-align: center;
}

.cost {
    display: flex;
    justify-content: center;
    align-items: center;
    line-height: 0.7;
}

.cost-currency {
    font-size: 2rem;
}

.cost-dollars {
    font-size: 4rem;
}

.cost-cents {
    font-size: 1.5rem;
    align-self: flex-start;
}

.cta-button {
    display: block;
    background-color: #cc6b5a;
    color: white;
    padding: 0.5em 1em;
    text-decoration: none;
}
```

And in CSS, the selectors `parent:first-child`and `parent> :first-child`are quite different in terms of what they target and how they function. Just like:

```html
<div class="container">
  <div class="parent">First Parent</div>
  <div class="parent">Second Parent</div>
</div>
```

For the `parent > :first-child`just like:

```html
<div class="parent">
  <p>First Child</p>
  <p>Second Child</p>
  <span>Third Child</span>
</div>
```

When you design calls for an alignment of tiems in two dimensions, use grid. When you are only concerned with a 1-D flow, use flexbox. In practice, this will often mean grid makes the most sense for hight-level layout of the page.

## The `maps`package

Like the `slices`package, `maps`is small but purposeful, run through that -- like:

##### Comparing maps

```go
m1 := map[string]bool {
    "generics": true,
}

m2 := map[string]bool {
    "genenric": true,
}

fmt.Println(maps.Equal(m1, m2)) // true
```

##### Deleting map entries -- 

The built-in `delete`already deletes a given key from a map, however, can delete any map entries for which some returns true, by passing it to `DeleteFunc`. Can:

```go
func main() {
	m := map[string]bool{
		"generics": true,
		"classes":  false,
	}
	findFalse := func(key string, v bool) bool {
		return !v
	}

	maps.DeleteFunc(m, findFalse)
	fmt.Println(m)
}
```

#### Clonine and copying

Just with slices, can use the `Clone`function to create a shallow copy of a map -- like:

```go
func main() {
	m1 := map[string]float64{
		"e": 0.5,
		"μ": 105.7,
		"τ": 1776.9,
	}
	m2 := maps.Clone(m1)
	fmt.Println(maps.Equal(m1, m2))
}
```

For `map`, there is no `Compact`function, since there can’t be any duplicate key in a map. But, there is a `Copy`function copies all the *entries* from one map to another like:

```go
func main() {
	m1 := map[int]bool{1: false, 2: true}
	m2 := map[int]bool{1: true}
	
	// first arg to Copy is the dest map
	maps.Copy(m1, m2)
	fmt.Println(m1)
}
```

### new idioms

Now that we have these, they change the way we write idiomatic Go code -- fore:

##### Copying slices

Fore, to create a copy of a slice, Used to have to write like:

```go
b := make([]T, len(a))
copy(b, a)

// instead we can now write just like:
b := slices.Clone(a)
```

##### Deleting slice elements

To delete a number of consecutive elements from a slice, used to 

```go
s := []int {1,2,3,4}
s = append(s[:1], s[3:]...)
println(s) // [1, 4]

// for now, use
s = slices.Delete(s, 1, 3)
```

##### Checking for slices elements

And we will never to write loops like this again -- 

```go
s := []int{1,2,3,4}
for _, v := range s {
    if v == 2 {
        fmt.Println("found it")
    }
}

// instead of
if slices.Contains(s, 2) {
    println("found it")
}
```

#### Merging in turn

This task is about writing a `Merge`function that takes any number of maps and merge them together, returning the result -- the result returned by `Merge`is a map containing all the k-v pairs in all its arguments.

What we’d like there is an easy way to copy elements from one map to another, overwrting any duplicate elements -- if nothing occurs to you, re-read the section of this -- just like:

```go
func Merge[M ~map[K]V, K comparable, V any](ms ...M) M {
	result := M{}
	for _, m := range ms {
		maps.Copy[map[K]V](result, m)
	}
	return result
}
```

Then test that -- 

```go
func TestMergeCorrectlyMergesTwoMapofIntToBool(t *testing.T) {
	t.Parallel()
	inputs := []map[int]bool{
		{
			1: false,
			2: false,
			3: false,
		},
		{
			3: true,
			5: true,
		},
	}
	want := map[int]bool{
		1: false,
		2: false,
		3: true,
		5: true,
	}
	got := dups.Merge(inputs...)
	if !maps.Equal(want, got) {
		t.Errorf("Merge(%v): want %v, got %v", inputs, want, got)
	}
}

func TestMergeCorrectlyMergesThreeMapsOfStringToAny(t *testing.T) {
	t.Parallel()
	inputs := []map[string]any{
		{
			"a": nil,
		},
		{
			"b": "hello, world",
			"c": 0,
		},
		{
			"a": 6 + 2i,
		},
	}

	want := map[string]any{
		"a": 6 + 2i,
		"b": "hello, world",
		"c": 0,
	}

	got := dups.Merge(inputs...)
	if !maps.Equal(want, got) {
		t.Errorf("Merge(%v): want %v, got %v", inputs, want, got)
	}
}

func TestMergeHandlesDerivedTypes(t *testing.T) {
	t.Parallel()
	type menu map[int]string
	m1 := menu{1: "eggs"}
	m2 := menu{2: "beans"}
	want := menu{
		1: "eggs",
		2: "beans",
	}
	got := dups.Merge(m1, m2)
	if !maps.Equal(want, got) {
		t.Errorf("want %v, got %v", want, got)
	}
}
```

### Slices and memory leaks -- 

For this if:

```go
func consumeMessages() {
    for {
        msg := receiveMessage()
        storeMessageType(getMessageType(msg))
    }
}

func getMessageType(msg []byte) []byte {
    return msg[:5]
}
```

For this, the `getMessageType`function computes the message type by slicing the input slice. We test  this. For this, the slicing operation on `msg`using `msg[:5]`creates a 5L slice, however, its capacity remains the same as the initial slice. The remaining elements are still allocated in memory. For this:

```go
func getMessageType(msg []byte) []byte {
    return slices.Clone(msg[:5])
}
```

- The `slices.Clone()`func allocate a new underlying array of exactly 5 bytes and copies the first 5 bytes of `msg`into it.
- The returned slice, is dependent of the original `msg`'s underlying array.

#### Slica and pointer

Have see that slicing cause lead cuz of the slice capacity -- but what about the elemetns which are part of the backing array but outside the length range -- 

```go
type Foo struct {
    v []byte
}
```

For this, want to check the memory allocations after each step as follows -- 

1. Allocated a slice of 1000 `Foo`elements
2. Iterate over each `Foo`element, and for each one, allocate 1MB for the v
3. Call `KeepFirstTwoElementOnly`which returns only the first two using slicing, and then calling `GC`.

```go
func main() {
    foos := make([]Foo, 1_000)
    printAlloc()
    
    for i:=0; i<len(foos); i++ {
        foo[i]= Foo{
            v: make([]byte, 1024*1024)
        }
    }
    
    printAlloc()
    
    two := keepFirstTwoElementsOnly(foos)
    runtime.GC()
    printAlloc()  // 1024072KB either
    runtime.keepAlive(two)
}

func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    return foos[:2]
}
```

It’s essential to keep this rule in mind when working with slices, if the element is a pointer or a struct with pointer fields, the elements won’t be reclaimed by the GC. In the end, we use the `runtime.KeepAlive`to keep a reference to the two variable after the garbage collection, so that it won’t be collected.

Cuz the explicit call to `runtime.GC()`forces a garbage collection cycle right before the `printAlloc()`, without the `runtime.KeepAlive(two)`, the Go runtime might determine that `two`is no longer needed after `printAlloc()`.

If the element is a pointer or a struct with pointer fields, the elements won’t be re-claimed by the `GC`. In the program, cuz `Foo`contains a slice, the remaining 998 `Foo`elements and their slice aren’t reclaimed -- therefore, even though these 998 elements can’t be accessed, they stay in memory as long as the variable returned. So:

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    return slices.Clone(foos[:2])
}
```

## Clean URLs and method-based routing

```sh
go get github.com/julienschmidt/httprouter@v1
```

Before get into the nitty-gitty of actual using `httprouter`--- like:

```go
router := httprouter.New()
router.HandlerFunc(http.MethodGet, "/snippet/view/:id", app.snippetView)
```

Initialize the `httprouter`router and then use the `HandlerFunc()`method to add a new route which dispatches requests to our `snippetView`handler function.

Just like:

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    fileServer := http.FileServer(http.Dir("./ui/static/"))
    router.Handler(http.MethodGet, "/static/*filepath", http.StripPrefix("/static", fileServer))
    
    router.HandlerFunc(http.MethodGet, "/", app.home)
    //...
    standard := alice.New(app.recoverPanic, app.logRequest, secureHeader)
    return standard.Then(router)
}

func (app *application)
```

Go’s stdlib -- the `net/http`package provides `http.Server`and `http.NewServeMux`-- which are related but serve distinct purposes in building HTTP servers.

- `http.Server`-- represents an HTTP server, managing the entire lifecycle of handling HTTP requests, including listening for connections, managing timeouts, and handling TLS. Uses an `http.Handler`like `ServeMux`to route and process requests
- `http.NewServeMux`-- A function that creates a new `http.ServeMux`-- which is an HTTP request multiplexer -- matches incoming request URLs to registered handlers and dispatches requests to them.

For using this -- 

```go
func main() {
    mux := http.NewServeMux()
    mux.HandleFunc("/", func(w, r){...})
    srv := &http.Server {
        Addr: ":8080",
        Handler: mux,
        ReadTimeout: 10*time.Second,
        WriteTimeout: 10*time.Second,
    }
}

// or using http.HandleFunc, and http.ListenAndServe
```

Then for the handler like:

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
    snippets, err := app.snippets.Latest()
    if err != nil {
        app.ServerError(w, err)
        return
    }
    data : = app.newTempalteData(r)
    data.Snippets = snippets
    app.render(w, http.StatusOK, "home.page", data)
}
```

#### Setting up a HTML form -- 

```html
{{define "title"}}Create a New Snippet{{end}}

{{define "main"}}
<form action='/snippet/create' method='POST'>
    <div>
        <label>Title:</label>
        <input type='text' name='title'>
    </div>
    <div>
        <label>Content:</label>
        <textarea name='content'></textarea>
    </div>
    <div>
        <label>Delete in:</label>
        <input type='radio' name='expires' value='365' checked> One Year
        <input type='radio' name='expires' value='7'> One Week
        <input type='radio' name='expires' value='1'> One Day
    </div>
    <div>
        <input type='submit' value='Publish snippet'>
    </div>
</form>
{{end}}
```

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
    data := app.newTemplateData(r)
    app.render(w, http.StatusOK, "create.html", data)
}
```

##### Parsing form data

1. Use the `r.ParseForm()`method to parse the request body, this checks that the request body is just *well-formed*, and then stores the form data in the request’s `r.PostForm`map. If there are any errors encountered when parsing the body, then return that.
2. We can then got to the form data contained in `r.PostForm`by using the `r.PostForm.Get()`method. Fore:
   `r.PostForm.Get(“title”)`

```go
func(app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    
    expires, err := strconv.Atoi(r.PostForm.Get("expires"))
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        //...
    }
    http.Redirect(w, r, fmt.Sprintf("...", id), http.StatusSeeOther)
}

// for the insert method like:
func (m *SnippetModel) Insert(title string, content string, expires int) (int, error) {
	stmt := `INSERT INTO snippets(title, content, created, expires)
		VALUES(?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY))`

	// Use the `Exec()` method on the embedded connection pool to execute the statement
	result, err := m.DB.Exec(stmt, title, content, expires)
	if err != nil {
		return 0, err
	}
	id, err := result.LastInsertId()
	if err != nil {
		return 0, err
	}
	return int(id), nil // cuz returned an int64
}
```

##### The `r.Form`map

In the code, used the `r.PostForm`map, but an alternative approach is to use the `r.Form`map -- the `r.PostForm`map is populated only for `POST, PATCH`-- requests, and contains the form data from the request body.

The `r.Form`map is populated for all requests, and contains the form data from any request body **and** query string parameters. if submit to `/snippet/create?foo=bar`-- could also get the value of the `foo`parameter using:
`r.Form.Get(“foo”)`-- note that in the event of a conflict, the request body value will take *precedent* over the query string parameters. Using the `r.Form`can be useful if your app sends data in a HTML form and in the URL, or have an app that is agnostic about how parameters are passed.

##### The `FormValue`and `PostFormValue`methods

The `net/http`also provides the methods -- `r.FormValue()`and `r.PostFormValue()`-- these are essentially shortcut functions for call `r.ParseForm()`for you and then fetch approriate value from the `r.Form`or `r.PostForm`respectively.

##### Multi-value fields

Strictly -- the `r.PostForm.Get()`used above only returns the *first* value of specific form field. So if:

```html
<input type="checkbox" name="items" value="foo"> Foo
<input type="checkbox" name="items" value="bar"> Bar
<input type="checkbox" name="items" value="baz"> Baz
```

In this case, you will need with the `r.PostForm`directly. The underlying type of the `r.PostForm`map is `url.Values`which in turn has the underlying type `map[string][]string` So just like:

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprint(w, "%d: item: %s\n", i, item)
}
```

#### Automatic form parsing

Using for:

```sh
go get github.com/go-playground/form/v4
```

Using the form decoder -- To get this working, the first thing that need to do is to initialize a new `*form.Decoder`instance in our `main.go`file and make it available to our handlers as a dependency. Fore:

```go
type application struct {
    //...
    formDecoder *form.Decoder
}

func main() {
    //...
    formDecoder := form.NewDecoder()
    app := &application{
        //...
        formDecoder: formDecoder,
    }
}
```

Next, in the `handler`file like:

```go
type snippetCreateForm struct {
    Title string `form:"title"`
    Content string `form:"content"`
    Expires int `form:"expires"`
    validator.Validaor `form:"-"`
}
```

Then -- in the soure code just like:

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        //...
        return
    }
    var form snippetCreateForm
    // Call the Decode() method of the form decoder, passing in the current
    // request and *a pointer* to our snippetCreateForm struct -- this will essentially
    // fill our struct with the revelant values from the HTML form.
    err = app.formDecoder.Decode(&form, r.PostForm)
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
}
```

And there are a lot of *security considerations* when it comes to working with sessions, and proper implementation is not trivial. Unless U really need to to roll your own implementation, it’s good idea to use an existing, well-tested, third-party package here.

Using the `alexedwards/scs`lets U store session data server-side only. It supports automatic loading and saving of session data via middleware.