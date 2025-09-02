# Relative units

CSS brings a late binding of styles to the web page -- The content and its styles aren’t pulled together until after the authoring of both is complete. And the responsive design -- In the web environment -- the user can set their browser window to any number of sizes -- and the CSS has to apply to them.

#### Ems and rems

1 em means the font size of the current element. For `<div class="padded">`

```css
.padded {
    font-size: 16px;
    padding: 1em; /* multiplied by the font size */
}
```

Fore:

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
/* different font sizes, which define the element's size */
.box-small {
    font-size: 12px;
}
.box-lage {
    font-size: 18px;
}
```

##### Using ems to define font-size

`font-size`ems are derived from the *inherited* font size.

```html
<body>
    We love coffee
    <p class="slogan">
        we love coffee
    </p>
</body>
```

```css
.body {
    font-size: 16px;
}

.slogan {
    font-size: 1.2em; /* 1.2 times the element's inherited font size */
}
```

Shrinking Font problem -- If:

```css
ul {
    font-size: .8em;
}
```

```html
<ul>
    <li>Top Level
    	<ul>
            <li>Second level
            	<ul>
                    <li>Third level</li>
                </ul>
            </li>
        </ul>
    </li>
</ul>
```

One way -- 

```css
ul ul {
    font-size: 1em;
}
```

##### Using rems for font-size:

The root node is the ancestor of all other elements in the document. The pseudo-class selector `:root`like:

```css
:root {
    font-size: 1em;
}
ul {
    font-size: 0.8rem;
}
```

`root`font size is the default, 16px fore, 0.8rem is 12.8px.

#### Stop thinking in pixels

```html
<div class="panel">
    <h2>
        Single-origin
    </h2>
    <div class="panel-body">
        Some content
    </div>
</div>
```

##### Combining with pseudo-classes

The child combinator can be combined with pseudo-classes like `:first-child`fore:

```css
div > p:first-child {
    color: red; /* first p that id direct child of div */
}
```

```css
.panel {
    padding: 1em;
    border-radius: 0.5em;
    border: 1px solid #999;
}

.panel > h2 {
    margin-top: 0;
    font-size: 0.8rem;
    font-weight: bold;
    text-transform: uppercase;
}
```

##### Making the panel reponsive

Can use some media queries to change the base font size, depending on the screen size. A media query uses an `@media`rule to specify styles that will be applied only to certain screen size or media types. Like:

```css
:root {
    font-size: 0.85em;
}
```

In CSS, the `:`and `::`notations are used to define *pseudo-class* and *pseudo-element*. For `:`

1. `:`-- Targets specific states or conditions of an element.
   - User Interaction -- `:hover, :active, :focus, :visited`
   - Structural -- `:first-child, :last-child, :not(selector)`
   - Form states -- `:checked, :disabled, :required`
   - Other: `:root, :empty, :lang(en)`
2. `::`-- Targets specific part of an element’s content or structure, Represents a *virtual* part of an element that isn’t in the DOM. Fore, `::first-letter, ::first-line, ::selection, ::before`

```css
:root {
    font-size: 0.85em; /* overridden for larger screens */
}
@media(min-width: 800px) {
    :root {
        font-size: 1em;
    }
}
@media (min-width: 1200px) {
    :root {
        font-size: 1.15em;
    }
}
```

##### Resizing a single component

```css
.panel {
    font-size: 1rem;
}

.panel > h2 {
    font-size: 0.8em;
}
```

#### Viewport-relative units

`vh, vw`, 1/100 viewport height and width, And -- 

`vmin`-- One percent of the smaller dimension, `vmax`, larger ..

```css
.box {
    width: 10vmin;
    height: 10vmin;
}
```

##### Getting Responsive with the `calc()`Function

The `calc`lets U do basic arithmetic with two or more values -- This is particularly useful for combining values that are measured in different units. Fore:

```css
:root {
    font-size: calc(0.5em + 1svw) /* small viewport */
}
```

#### Unitless numbers and `line-height`

Some properties allow for unitless values -- `line-height, z-index, font-weight`. Fore:

```css
body {
    line-height: 1.2;
}

.about-us {
    font-size: 2em;
}
```

#### Custom properties

```css
:root {
    --main-font: Helvetica, Arial, sans-serif;
}

p {
    font-family: var(--main-font)
}
```

##### Changing Custom properties dynamically

```html
<body>
    <div class="panel">
        <h2>
            Single-origin
        </h2>
        <div class="body">
            Some content
        </div>
    </div>
    
    <aside class="dark">
    	<div class="panel">
            <h2>
                Single-Origin
            </h2>
            <div class="body">
                Some content
            </div>
        </div>
    </aside>
</body>
```

```css
:root {
    --main-bg: #fff;
    --main-color: #000;
}

.panel {
    font-size: 1rem;
    background-color: var(--main-bg)
}
.panel > h2 {
    //...
}
```

For this, have two panels,  Define the variables again -- like:

```css
.dark {
    margin-top: 2em;
    padding: 1em;
    background-color: #999;
    --main-bg: #333;  /* in .dark, re-define the variable */
    --main-color: #fff;
}
```

## Don’t returning interfaces

Two packages -- 

- `client`-- contains a `Store`interface
- `store`-- contains imp of `Store`

If apply this to Go -- means just -- 

- Returning structs instead of interfaces
- Accepting interfaces if possible.

For this, there are some exceptions -- like:

```go
func LimitReader(r Reader, n int64) Reader {
    return &LimitedReader{r, n}
}
```

### `any`says nothing

When to use generics -- Fore:

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k := range m {
        keys = append(keys, k)
    }
    return keys
}
```

If Not use the generics -- like:

```go
func getKeys(m any) ([]any, error) {
    switch t := m.(type) {
    default:
        return nil, fmt.Errorf("Unknown type: %T", t)
        
    case map[string]int:
        var keys []any
        for k := range t {
            keys= append(keys, k)
        }
        return keys, nil
    case map[int]string:
        //...
    }
}
```

Type parameters are generic types that can use with functions and types -- the following like:

```go
func foo[T any](t T) {
    // ...
}
```

For this, when calling `foo`, pass a type argument of `any`, Supplying a type argument is called *instantiation*, and the work is done at *compile time*.

```go
func getKeys[K comparable, V any](m map[K]V) []K {
    var keys []K
    for k := range m {
        keys = append(keys, k)
    }
    return keys
}
```

Fore, don’t want to accept any *comparable* type for the `map`key type -- restrict to either `int`or `string`types like:

```go
type customConstraint interface {
   	~int | ~string
}

func getKeys[K customConstraint, V any](m map[K]V) []K {
    // same
}
```

Can also use generics with DS -- 

```go
type Node[T any] struct {
    Val T
    next *Node[T]
}

func (n *Node[T]) Add(next *Node[T]) {
    n.next = next
}
```

Used type parameters to define `T`and use both fields in `Node`.

#### Common uses and misuses

Recommended -- DS and Functions working with slices, maps, and chanells of *any type*. And, For `sort`package:

```go
type SliceFn[T any] struct {
	S       []T
	Compare func(T, T) bool
}

func (s SliceFn[T]) Len() int {
	return len(s.S)
}

func (s SliceFn[T]) Less(i, j int) bool {
	return s.Compare(s.S[i], s.S[j])
}

func (s SliceFn[T]) Swap(i, j int) {
	s.S[i], s.S[j] = s.S[j], s.S[i]
}
func main() {
	s := SliceFn[string]{
		S: []string{"d", "b", "c"},
		Compare: func(a, b string) bool {
			return a > b
		},
	}
	sort.Sort(s)
	fmt.Println(s.S)
}
```

Conversely, when it recommended **NOT** use generics -- 

- When calling a method of type argument Fore:

  ```go
  func foo[T io.Writer] (w T) {
      _, _ = w.Write(b) // won't bring any value to our code
  }
  ```

### Problems with type embedding

```go
type Foo struct {
    Bar
}
type Bar struct {
    Baz int
}
```

In the `Foo`, the `Bar`is declared without an associated name, hence, it’s an embedded field. Use embedding to *promote* the *fields and methods* of an embedded type.

```go
foo : = Foo{}
foo.Baz = 42
```

If:

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}

func New() *InMem {
    return &InMem{m: make(map[string]int)}
}

func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

Cuz the mutex is embedded, can directly access the `Lock`and `Unlock`methods. If:

```go
m := inmem.New()
m.Lock()
```

For this, promotion is probably not desired, A mutex is in most case, sth that want to *encapsulate* within a struct and make invisible to external clients. So

```go
type InMem struct {
    mu sync.Mutex
    m map[string]int
}
```

Also, can be considered a correct approach -- like:

```go
type Logger struct {
    WriteCloser io.WriteCloser
}

func(l logger) Write(p []byte) (int, error) {
    return l.WriteCloser.Write(p)
}

func(l logger) Close() error {
    return l.writeCloser.Close()
}

func main() {
    l := Logger{writerCloser: os.Stdout}
    _, _ = l.Write([]byte("foo"))
    _, _ = l.Close()
}
```

For this, `Logger`-- would *only* forward the call to `io.WriteCloser`.So:

```go
type Logger struct {
	io.WriteCloser
}

func main() {
	l := Logger{WriteCloser: os.Stdout}
	_, _ = l.Write([]byte("hello"))
	_ = l.Close()
}
```

### Thread communication using Memory sharing

Threads of execution working together to solve a common problem require some form of communication -- this is what is known as *inter-thread communication* ITC. Or *inter-process communication* called IPC.

```go
func main() {
    count := 5
    go countdown(&count)
    for count > 0 {
        time.Sleep(500*time.Millisecond)
        fmt.Println(count)
    }
}

func countdown(seconds *int) {
    for *seconds > 0 {
        time.Sleep(1*time.Second)
        *seconds -= 1
    }
}
```

##### Updating shared variables from multiple goroutines -- 

```go
func countLetters(url string, frequency []int) {
	resp, _ := http.Get(url)
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		panic("Server returning error code:" + resp.Status)
	}
	body, _ := io.ReadAll(resp.Body)
	for _, b := range body {
		c := strings.ToLower(string(b))
		cIndex := strings.Index(allLetters, c)
		if cIndex >= 0 {
			frequency[cIndex] += 1
		}
	}
	fmt.Println("Completed", url)
}
```

Run this function using some web pages, want static pages that never change.

```go
func main() {
	var frequency = make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		countLetters(url, frequency)
	}
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, frequency[i])
	}
}
```

Now, try to improve the speed of our program by using concurrent programming. Just use `go countLetters`in the loop.