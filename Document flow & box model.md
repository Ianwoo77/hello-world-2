# Document flow & box model

```css
:root {
    --brand-color: #0072b0;
}
body {
    margin: unset;
    background-color: #eee;
    font-family: Helvetica,...
}
.page-header {
    color: #fff;
    background-color: var(--brand-color);
}
.main {
    background-color: #fff;
    border-radius: 0.5em;
}
.social-links {
    background-color: #fff;
    border-radius: .5em;
}
```

##### Centering content horizontally

Should usually start with the higher-level DOM element first. And in the page, `<body>`serves as the outer container, By default, this is already 100% of the page width.

```css
.page-header h1 {
    max-width: var(--column-width);
    margin: 0 auto;
}
.container {
    max-width: var(--column-width);
    margin: 0 auto;
}
```

`auto`left and right margins will grow to fill the available space, centering the element within the outer container. This is often the simplest way to fill the remaining width available in the outer container.

##### Logical properties

Note that the *Logical properties* provide a way to work with elements in terms of their block and inline directions. Fore: `width -- inline-size`, for `height -- block-size`, And logical properties also replace top, right, bottom and left with *start* and *end*. Fore, `padding-left`and `padding-right` -- `padding-inline-start`and `padding-inline-end`.fore. Fore:

```css
.page-header h1 {
    max-inline-size: var(--column-width);
    margin-inline: auto;
}
.container {
    max-inline-size : var(--column-width);
    margin-inline: auto;
}
```

#### The box model

```css
.main {
    padding: 1em 1.5rem;
}
.social-links {
    padding: 1em 1.5rem;
}
```

The default behavior of the *box model* -- The *content area* is the inner-most reactangle where the content of the element reside. The padding area contains the content area plus any padding. Adjust the box model -- the default model tends to cauze problem with the sizing and alignment of elements on the page. Using the `box-sizing`property -- defaultis `content-box`. Can:

```css
.page-header h1 {
    box-sizing: border-box;
    max-inline-size: var(--column-width);
    margin-inline: auto;
    padding-inline: 1.5rem;
}
```

##### Universal border box sizing-- 

Using the universal selector `*`-- which targets all elements on the page -- like:

```css
*, 
::before,
::after {
    box-sizing: border-box;
}
```

#### Element height

Normal document flow is designed to work with constrained width and unlimited height. And when explicitly set an element’s height, run the risk of its contents *overflowing* the container. Happens when the container doesn’t fit the specified constraint and renders outside the parent element. `visible, hidden`.

- `clip`- Similar to `hidden`but programmic scrolling is also disabled.
- `scroll`- Scrollbars are added to the container
- `auto`-- Scrollbars are added only if the content overflow.

##### `min-height`and `max-height`

Use these to specify a minimum or maximum value, allowing the element to size naturally within those bounds.

#### Collapsed margins

```html
<main class="main">
	<h2>
        Come join us
    </h2>
    <div>
        <p>
            //...
        </p>
    </div>
</main>
```

For this, 3 different margins are collapsing together. h2, div and p.

##### Collapsing outside a container

The way 3 consecutive margins collapse might catch U off guard. An element’s margin collapsing outside its container typically produces an undesriable effect if the container has a background.

```html
<body>
    <header class="page-header">
        <h1>Frankln Running club</h1>
    </header>

    <div class="container">
```

For this, the page title is an `h1`with 0.67em 21.44 px bottom applied by the user-agent styles. Title is inside a `header`with no margins. The bottom margins of both elements are adjacent. So resulting 21.44px bottom margin on the header. 

If add top and bottom padding to the header, the margin inside it won’t collapse to the outside. Can also update the stylesheet to match:

```css
.page-header h1 {
    margin: 0 auto;
}
```

1. Applying `overflow:auto`or any value other than `visible`
2. Adding border or padding
3. Margin won’t collapse to the outside of a container that is an inline block.
4. When using a flexobx or grid layout
5. Elements with a `table-cell`.

#### Spacing elements within a container

```css
.social-links {
    max-inline-size: 25em;
    padding: 1em 1.5rem;
    background-color: #fff;
    border-radius: .5em;
}
.button-link {
    display: block;
    padding: .5em;
    color: #fff;
    background-color: var(--brand-color);
    text-align: center;
    text-decoration: none;
    text-transform: uppercase;
}
```

For this, Margin plus padding creates too much space -- Can fix that like:

```css
.button-link + .button-link {
    margin-block-start: 1.5em;
}
```

##### More generic solution -- 

```css
.stack > * + * {
    margin-block-start: 1.5em;
}

*, 
*::before,
*::after {
    box-sizing: border-box;
}
```

## Not using the functional options pattern

When designing an API, one question may arise -- how do we deal with optional configuration namely -- If:

```go
func NewServer(addr string, port int) (*http.Server, error) {...}
```

#### Config struct

Cuz Go doesn’t support optional parameters in function signatures -- the first possible approach is to use a configuration struct to convey -- like:

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config) {
    //...
}
```

Bear in mind that a struct field isn’t provided, it’s initialized to its zero value like --

```go
c1 := httplib.Config {
    Port:0
}
```

Perhaps one option might be to handle all the parameters of the configuration struct as pointers in this way like:

```go
type Config struct {
    Port *int
}
```

Has a couple of downsides -- it’s not handy for clients to provide an integer pointer like:

```go
port := 0
Config := httplib.Config {
    Port: &port,
}
```

The second is that a client using our library with the default configuration will need to pass an empty struct:

```go
httplib.NewServer("localhost", http.Config{})
```

#### Using builder pattern

The builder pattern provides a flexible solution to various object-creation problems -- like:

```go
type Config struct {
    Port int
}
type ConfigBuilder struct {
    port *int
}
func (b *ConfigBuilder) Port(port int) *ConfigBuilder {
    b.port = &port
    return b
}

func(b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port == nil {
        cfg.Port = defaultHTTPPort
    }else {
        if *b.port == 0 {
            //...
        }else if *b.port < 0 {
            return Config{}, errors.New("port should be positive")
        }else {
            cfg.Port=*b.port
        }
    }
    return cfg, nil
}
```

#### Functional options pattern

The last is the functional options pattern -- The main idea is as follows -- 

- An unexported struct holds the configuration: `options`
- Each option is a function that returns the same type. `type Option func(options *options) error`

```go
type options struct {  // unexported
    port *int
}
type Option func(options *options) error
func WithPort(port int) Option {
    return func(options *options) error {
        if port <0 {
            return errors.New(...)
        }
        options.port = &port
        return nil
    }
}

func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options  // creates an empty argument
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
        if *options.port == 0 {
            port = randomPort()
        } else {
            port = *options.port
        }
    }
}

// use this
server, err := httplib.NewServer("localhost", httplib.WithPort(8080), 
                                 httplib.WithTimeout(time.second))

// if the client needs the default configuration
server, err := httplib.NewServer("localhost")
```

### Race conditions

Trying to do many things at the same time. Fore:

```go
func stringy(money *int) {
	for i := 0; i < 1000000; i++ {
		*money += 10
	}
	fmt.Println("stringy done")
}

func spendy(money *int) {
	for i := 0; i < 1000000; i++ {
		*money -= 10
	}
	fmt.Println("spendy done")
}

func main() {
	money := 100
	go stringy(&money)
	go spendy(&money)
	time.Sleep(2 * time.Second)
	fmt.Println("final money:", money)
}
```

Having this cuz the operations `*money += 10`fore, are not atomic.

DEF -- a *critical section* in the code is a set of instructions that should be executed without interference from other executions affecting the state used in that section. Note that even if the instructions were atomic, might still run into issues -- Each processor core has a local cache and registers to store the variables that are used frequently. The compiler sometimes applies optimizations to keep the variables on the CPU registers or caches before giving instructions to flush them back to memory.

##### Yielding execution does not help with RCs -- 

```go
func stingy(money *int) {
    for i := 0; i<10000000; i++ {
        *money += 10
        runtime.Gosched()
    }
    fmt.Println("Stringy Done")
}
```

RC is happening less frequently -- still occuring.

##### Proper sync and communication eliminate race conditions

```sh
go run -race stingyspendy.go # adds special code to all memory accesses to track
```

### Sync with mutexes

Readers-writer mutexes give us performance optimization in situations where we need to block concurrency only when modifying the shared resource.

```go
func stringy(money *int, mutex *sync.Mutex) {
	for i := 0; i < 1000000; i++ {
		mutex.Lock()
		*money += 10
		mutex.Unlock()
	}
	fmt.Println("stringy done")
}

func spendy(money *int, mutex *sync.Mutex) {
	for i := 0; i < 1000000; i++ {
		mutex.Lock()
		*money -= 10
		mutex.Unlock()
	}
	fmt.Println("spendy done")
}

func main() {
	money := 100
	mutex := sync.Mutex{}
	go stringy(&money, &mutex)
	go spendy(&money, &mutex)
	time.Sleep(2 * time.Second)
	fmt.Println("final money:", money)
}
```

##### Sequential processing

Can also use mutexes when have more than two goroutines.

```go
func main() {
	mutex := sync.Mutex{}
	var frequency = make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		go countLetters(url, frequency, &mutex)
	}
	time.Sleep(20 * time.Second)
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, frequency[i])
	}
}

func countLetters(url string, frequency []int, mutex *sync.Mutex) {
	mutex.Lock()
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
	mutex.Unlock()
}
```

By using mutexes in this manner, have changed our concurrent program into a sequential one.