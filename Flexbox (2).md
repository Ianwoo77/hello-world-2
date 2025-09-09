# Flexbox (2)

*Flexbox* is a method for laying out elements on the page -- Primiarily used for arranging elements in a row or column. Use `display:inline-flex`, or `display:flex`

```html
<div class="container">
    <header>
    	<h1>
            Ink
        </h1>
    </header>
    <nav>
    	<ul class="site-nav">
            <li><a href="/">Home</a></li>
            //...
        </ul>
    </nav>
    
    <main class="flex">
    	<div class="column-main tie">
            <h1>
                Team collaboration done right
            </h1>
            <p>
                Thousands of teams from all ...
            </p>
        </div>
        
        <div class="column-sidebar">
            <div class="tile">
                <form class="login-form">
                    <h3>
                        Login
                    </h3>
                    <p>
                        <label for="username">Username</label>
                        <input id="username" type="text" name="username" />
                    </p>
                </form>
            </div>
        </div>
    </main>
</div>
```

This HTML includes a link a style.css -- like:

```css
*, 
::before,
::after {
    box-sizing: border-box;
}

body {
    margin: unset;
    background-color: #709b90;
    font-family: Helvetica...
}

.stack > * + * {
    margin-block-start: 1.5em;
}
```

For the `::before`and `::after`, Replaced Element -- do not work on replaced elements like: `<img>, <input>, <textarea>, <video>, <iframe>`-- these get their content from *external* sources.

##### Building a basci flexbox menu

```css
.site-nav {
    display: flex;
    padding: unset; /* remove the left padding */
    list-style-type: none;
    background-color: #5f4b44;
}
.site-nav > li > a {
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}
```

##### Adding padding and spacing

Fore, apply the menu item padding to the internal `<a>`-- not the `<li>`-- need the entire area that looks like a menu link to behave like a link when the use clicks it. So:

```css
.site-nav {  /* ul element */
    display: flex;
    padding: 0.5rem;
}

.site-nav > li > a {
    display: block; /* makes links block-level so can add to the parent's height */
}

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
        .flex{
            display: flex;
            gap: 5em;
        }
    </style>
</head>
<body>
    <main class="flex">
        <p>p1</p>
        <p>p2</p>
        <p>p3</p>
    </main>
</body>
```

Made the links a display block -- Additionally, flexbox allows to use `margin:auto`to fill all available space between flex items -- can also use this to push the final menu all the way to the right side. 

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

.site-nav > .nav-right {
    margin-inline-start: auto; /* auto margins inside a flexbox fill the available space */
}
```

#### Flex item sizes

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

For the `flex`property -- applied to flex items, gives U several options -- 

```css
.column-main {
    flex:2;
}
.column-sidebar {
    flex:1;
}
```

Now the two columns grow to fill the space.

#### Understanding Bootstrap Flex basics

Bootstap provides utility classes for Flexbox, which allow U to control how elements behave in a flexible layout.

- Container -- `d-flex`or `d-inline-flex`to make it a flex container
- Direction, Justification, Alignment, and Flex Grow/shrink

Note that the Bootstrap’s flex utilities are prefixed with class like `flex-`, `justify-content-`, `align-items-`

Example -- 

```jsx
<div class="d-flex big-light p-3">
    <div class="p-2 bg-primary text-white">Item1</div>
    <div class="p-2 bg-secondary text-white">Item2</div>
</div>
```

Vartical layout -- add `.flex-column`like:

```jsx
<div class="d-flex flex-column bg-light p-3">...</div>
```

Justifying content --  Use the `justify-content-*`classes to align items along the main axis

```jsx
<body>
    <div class="d-flex align-items-center bg-light p-3">
        <div class="p-2 bg-primary text-white">Aligned to center</div>
        <div class="p-2 bg-secondary text-white">Aligned to center</div>
    </div>
</body>
```

For individual item alignment, use `align-self-*`on the item like:

```html
<body>
    <div class="d-flex align-items-center bg-light p-3"
        style="height:200px;">
        <div class="p-2 bg-primary text-white align-self-start">Top</div>
        <div class="p-2 bg-secondary text-white align-self-center">Center</div>
    </div>
</body>
```

Flex Grow shrink and Fill -- 

- `flex-grow-1`
- `flex-shrink-1`
- `.flex-fill`-- forces items to equal width

```html
<body>
    <div class="d-flex bg-light p-3">
        <div class="p-2 bg-primary text-white flex-grow-1">Grow to fill</div>
        <div class="p-2 bg-secondary text-white">Fix size</div>
        <div class="p-2 bg-success text-white flex-fill">Fills equal</div>
    </div>
</body>
```

Ordering items -- Reorder items without changing HTML structure using the `.order-*`

```html
<div class="d-flex bg-light p-3">
    <div class="p-2 bg-primary text-white order-3">Third in order</div>
    <div class="p-2 bg-secondary text-white order-1">First in order</div>
    <div class="p-2 bg-success text-white order-2">Second in order</div>
</div>
```

Wrapping and Repsonsive Flex -- 

- Use the `.flex-wrap`to allow items to wrap to new lines.
- Makes it responsive -- add breakpoints like `-sm`..

##### Flex basis

The *flex basis* defines a sort of starting point for the size of an element -- *an initial main size* fore. Fore:

```css
flex: 2 1 0% ==>
flex-grow: 2;
flex-shrink: 1;
flex-basis: 0%
```

## Function options Pattern

- An *unexported* struct holds the configuration: `options`
- Each option is a function that returnes the same type -- `type Option func(options *options) error`

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

For this, the `WithPort`returns a closure. Can:

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
        port = *options.port
    }
}
```

Cuz `NewServer`accepts variadic `Option`arguments, a client can now call this API by passing multiple options following the mandatory address argument like:

```go
server, err := httplib.NewServer("localhost",
                                 httplib.WithPort(8080),
                                 httplib.WithTimeout(time.Second))
```

This is a common idiom in Go for building flexible APIs, especially for ctors or functions that need to accept a variable number of optional parameters. *Flexibility, Extensibiility, For Error Handling* and *Immutability*.

```go
import "errors"

type options struct {
    port *int
}

type Option func(*options) error
```

Adding a ctor -- to use these, need a ctor function that accepts a variadic list of `Option`-- 

```go
type Server struct { // Server is the type that we are configuring
    port int
    timeout time.Duration
    maxRetries int
}
type options struct { // options struct unexported
    port *int
    timeout *time.Duration
    maxRetries *int
}

type Option func(*optinos) error

// WithPort
func WithPort(port int) Option {
    return func(opts *options) error {
        if port < 0 {
            return errors.New("port should be positive")
        }
        opts.port= &port
        return nil
    }
}

func WithTimeout(timeout time.Duration) Option {
    return func(opts *options) error {
        if timeout <= 0 {
            return errors.New("timeout must be positive")
        }
        opts.timeout = &timeout
        return nil
    }
}

func WithMaxRetries(maxRetries int) Option {
    return func(opts *options) error {
        opts.maxRetries = &maxRetries
        return nil
    }
}

// NewServer, the constructor - accepts variadic options
func NewServer(opts ...Option) (*Serer, error) {
    options := &options {
        port: ptrInt(8000),
        timeout: ptrDuration(30*time.Second),
        maxRetires: ptrInt(3),
    }
}
```

### Project organization -- 

Go language provides a lot of freedom in designing packages and modules, the best practices are not quite as ubiquitous as they should be. If proj is small enough, or if our organization has already created its std, may not be worth using or migrations to prject-layout -- 

- `/cmd`-- the main source file
- `/internal` -- private code don’t want others importing for their apps or libs.
- // ... 

#### Package organziation

There is no concept of subpackages -- can decide to organize packages with subdirectories. Fore:

```tex
/net
	/http/client.go
	/smtp/auth.go
	/addrselect.go
```

Note that the `net/http`doesn’t inherit from `net`or have specific access rights to the `net`package.

#### Creating utility packages

About implementing a set data structure -- the idiomatic way to do this in Go is to handle it via a `map[K]struct{}`type with `K`can be any type allowed in a map as a key.

```go
package util
func NewStringSet(...string) map[string]struct{} {
    //...
}
func SortStringSet(map[string]struct{}) []string {}
```

The problem here is that the `util`is meaningless -- could call it `common...`it remains a meaningless name. Instead of utility package, should create an expressive package name -- `stringset`fore.

```go
package stringset
func New(...string) map[string]struct{} {...}
```

##### Ignoring package name collisions

Package collisions occur when a variable name collides with an existing package name -- 

```go
package redis
type Client struct {}
func NewClient() *Client {}
```

```go
redis := redis.NewClient()
v, err := redis.Get("foo")
```

For this, the `redis`name collides with the `redis`package name. Can use package imports, can use an alias to change the qualifier to reference the `redis`package like:

```go
import redisapi "mylib/redis"
redis := redisapi.NewClient()
//...
```

### Code documentation

First, every *exported* element must be documented, whether it is a structure, interface, function or sth else. The convention is to add comments, starting with the *name* of the exported element fore -- 

```go
// Customer is a customer representation
type Customer struct{}

// ID returns the customer identifer
func(c Customer) ID() string {return ""}
```

Each comment should be a *complete sentence* that ends with punctuation.

##### Deprecated elements

It’s possible to deprecate an exported element using the `// Deprecated: comment`like:

```go
// ComputePath returns the fastest path
// Deprecated: This function uses a deprecated way to compute
// the fastest path.
func ComputePath(){}
```

And, Might be interested in conveying two aspects -- purpose and content

- The former should live as code documentation
- The latter shouldn’t necessary be public

```go
// DefaultPermission is the default permission used by the store engine
const DefaultPermission = 0o644 // Need read and write accesses.
```

So the code documentation conveys its purpose, whereas the command alongside the constant describes its actual content.

And, to help clients and maintainers understand a package’s scope, should also document each package -- 

```go
// Package math provides basic constants and mathematical functions. (appear in the package)
//
// This package dows not guarantee bit-identical results across architectures.
package main
```

One last thing to mention regarding package documentation is that *comments not adjacent to the declaration are omitted* -- 

```go
// copyright 2009 The Go Authors....
//
// (empty, previous will not be included in the documentation) 
// This package does not (documentation)
```

### Non-Blocking mutex locks

A goroutine willblcok when it calls the `Lock()`if the mutex is already in use by another exeuction. This is waht’s known as a blocking function -- the execcution of the goroutine stops until `Unlock()`is called by another goroutine. So there is a `TryLock()`

- The lock is avaible, returns Boolean `true`and acquire
- Unavailble, False, return immediately

```go
for i, c := range allLetters {
    if mutex.TryLock() {
        fmt.Printf("%c-%d", c, frequency[i])
        mutex.Unlock()
    }else {
        fmt.Println("mutex already being used")
    }
}
```

#### Improving with readers-writer mutexes

Users are checking updates about a live basketball..

```go
func matchRecorder(matchEvents *[]string, mutex *sync.Mutex) {
	for i := 0; ; i++ {
		mutex.Lock()
		*matchEvents = append(*matchEvents, "Match event "+
			strconv.Itoa(i))
		mutex.Unlock()
		time.Sleep(200 * time.Millisecond)
		fmt.Println("Appended match event")
	}
}

func clientHandler(mEvents *[]string, mutex *sync.Mutex, st time.Time) {
	for i := 0; i < 100; i++ {
		mutex.Lock()
		allEvents := copyAllEvents(mEvents)
		mutex.Unlock()

		timeTaken := time.Since(st)
		fmt.Println(len(allEvents), "Events copied in", timeTaken)
	}
}

func copyAllEvents(matchEvents *[]string) []string {
	allEvents := make([]string, 0, len(*matchEvents))
	for _, e := range *matchEvents {
		allEvents = append(allEvents, e)
	}
	return allEvents
}
```

Then connect everything together and start our goroutines in a `main()`function -- like:

```go
func main() {
	mutex := sync.Mutex{}
	var matchEvents = make([]string, 0, 10000)
	for j := 0; j < 10000; j++ {
		matchEvents = append(matchEvents, "Match event")
	}
	go matchRecorder(&matchEvents, &mutex)
	start := time.Now()
	for j := 0; j < 5000; j++ {
		go clientHandler(&matchEvents, &mutex, start)
	}
	time.Sleep(100 * time.Second)
}
```

The data changes very slowly. So it would be better if all client handler had *non-exclusive* access to the slice so that they could read the list at the same time if needed.

```go
type RWMutex
	// Locks mutex
func (rw *RWMutex) Lock()
func (rw *RWMutex) RLock()

// protects
func clientHandler(mEvents *[]string, mutex *sync.RWMutex, st time.Time) {
	for i := 0; i < 100; i++ {
		mutex.RLock()
		allEvents := copyAllEvents(mEvents)
		mutex.RUnlock()

		timeTaken := time.Since(st)
		fmt.Println(len(allEvents), "Events copied in", timeTaken)
	}
}
```

### Condition variables and Semaphores

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
		*money -= 50
		if *money < 0 {
			fmt.Println("Money is negative!")
			os.Exit(1)
		}
		mutex.Unlock()
	}
	fmt.Println("spendy done")
}
```

For this, is there anything we can do to stop the balance from going into the negative -- 

```go
func spendy(money *int, mutex *sync.Mutex) {
	for i := 0; i < 2000000; i++ {
		mutex.Lock()
		for *money < 50 {
			mutex.Unlock()
			time.Sleep(10*time.Millisecond)
			mutex.Lock()
		}
        //...
```

Work for us, but not ideal. Choose the sleep value of 10ms. There is where condition variables come in -- work together with mutexes and give us the ability to suspend the current execution until have a signal that a particular condition has changed.

1. while holding, A checks for a particular condition on some *shared* state.
2. If not met, `Wait()`called
3. Note that the `Wait()`performs two operations *atomatically*.
   - Release the mutex
   - blocks the current execution, putting the goroutine to sleep.
4. Now available, another goroutine acquires it to update the shared state.
5. After updating the shared state, B call `Signal()`or `Broadcast()`on the condition variable.
6. Upon receiving `Signal()`or `Broadcast()`, A wakes up and automatically re-acquires the mutex. A will re-check the condition on the shared state.
7. The condition is eventually met.

```go
type Cond
func NewCond(l locker) *Cond
func (c *Cond) Broadcast()
func (c *Cond) Signal()
func (c *Cond) Wait()
```

So, for the `main`-- 

```go
func main() {
	mutex := sync.Mutex{}
	money := 10
	cond := sync.NewCond(&mutex)
	go stringy(&money, cond)
	go spendy(&money, cond)
	time.Sleep(2 * time.Second)
	fmt.Println("Money in bank account: ", money)
}
```

Then update the methods like:

```go
func stringy(money *int, cond *sync.Cond) {
	for i := 0; i < 1000000; i++ {
		cond.L.Lock()
		*money += 10
          cond.Signal()
		cond.L.Unlock()
	}
	fmt.Println("stringy done")
}

func spendy(money *int, cond *sync.Cond) {
	for i := 0; i < 2000000; i++ {
		cond.L.Lock()
		for *money < 50 {
			cond.Wait()
		}
		*money -= 50
		if *money < 0 {
			fmt.Println("Money is negative!")
			os.Exit(1)
		}
		cond.L.Unlock()
	}
	fmt.Println("spendy done")
}
```

For this, whenever a waiting goroutine receives a signal or broadcast, will try to re-acquire the mutex.

##### Missing the signal

Namely, what happens if a goroutine calls `Signal()`or `Broadcast()`and there is no execution waiting for it. If there is no goroutine in a waiting state, the `Signal`or `Broadcast`call will be missed. Instead of using sleep. To ensure that we don’t miss any signals and broadcasts, Need to use them in conjunction with mutextes. Should call these functions only when we are holding the associated mutex. Fore:

```go
func doWork(cond *sync.Cond) {
    fmt.Println("Work started")
    fmt.Println("Work finished")
    cond.L.Lock()
    cond.Signal()
    cond.L.Unlock()
}
```

Always use `Signal Broadcast, Wait()`when holding the mutex lock to avoid sync problems.