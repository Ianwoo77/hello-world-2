# Sass recovery

Newer and move popular syntax -- it is essentially a subset of the CSS3 syntax 

```scss
nav {
    ul {
        margin: 0;
        padding: 0;
        list-style: none;
    }
    li {
        display: inline-block;
    }
    
    a {
    	display: block;
        text-decoration: none;
    }
}
```

Works in such a way that when U write your styles in a `.scss`file -- gets complicated into a regular CSS file.

#### Parent selector

In the Sass code -- might notice the ampersand symbol `&`-- used with the hover pseudo-class -- called *parent selector*.

```scss
nav {
    height: 10vh;
    width: 100%;
    display: flex;
    
    ul {
        list-style: none;
        display: flex;
    }
    
    li {
        margin-right 2.5rem;
        a {
            text-decoration: none;
            color: #707070;
            
            &:hover {
                color: #069c54
            }
        }
    }
}
```

#### Partials in Sass -- 

One of the many awesome features of Sass that gives U an advantage -- Using `@import`and `@use`. And with `@use`being the modern, recommended replacement that introduces a module system. The `@use`rule is the rule of the Sass module system, designed to address the issues of global scope and poor maintainability. In `@import`:

```scss
// _settings.scss
$color: blue;
// main.scss
@import 'settings';
.header {color: $color;} // $color is globally available
```

For the `@use`--  the `$color`is just must use the namespace `settings`

```scss
// main.css
@using 'settings';
.header {color: settings.$color;}
```

#### Mixins in Sass

Another major issue with CSS is that you will often use a similar group of styles -- Mixins allow U to encapsulate a group of styules -- and apply those styles anywhere in your code using the `@include`.

```scss
@mixin flex-container {
    display: flex;
    justify-content: space-around;
    aligh-items: center;
    flex-direction: column;
    background: #ccc;
}

.card {
    @include flex-container;
}
.aside {
    @include flex-container;
}
```

#### Functions and Operations

Sass offers built-in functions that enable us to do calculations and operations that return a specific value. They range from color calculations to match operations like getting random numbers and calculation of sizes, and even conditionals. Fore:

```scss
@use "sass:math";

@function pxToRem($pxValue) {
    $remValue: math.div($pxValue, 16px) * 1rem;
    @return $remValue;
}

div {
    width: pxToRem(480px); // gives 30rem
}
```

Also, an example of conditional logic in a mxin -- 

```scss
@mixin body-theme($theme) {
    @if $theme=='light' {
        background-color: $light-bg;
    } @else {
        background-color:$dark-bg;
    }
}
```

## The complete guide to context in Golang

Concurrency is a fundamental aspect of Go programming -- and effectively managing concurrent operations is crucial for building robust and efficient apps. On of the key feature that aids in achieving this is the `context`package in the Golang -- Context provides a mechanism to control the lifecycle, cancellation, and propagation of requests across multiple goroutines -- 

Context is a built-in package in the stdlib and provides a powerful toolset for managing concurrent operations. It enables the propagation of cancellation signals, deadlines, and values across goroutines, ensuring the related operations can gracefully terminiate when necessary.

#### Example: Managing Concurrent API requests

Consider a scenario where U need to fetch data from multiple APIs concurrently -- fore:

```go
func fetchAPI(ctx context.Context, url string, results chan<- string) {
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		results <- fmt.Sprintf("Error creating request: %v", err.Error())
		return
	}
	client := http.DefaultClient
	resp, err := client.Do(req)
	if err != nil {
		results <- fmt.Sprintf("Error making request to %s, %v", url, err.Error())
		return
	}

	defer resp.Body.Close()
	results <- fmt.Sprintf("Response from :%s: %d", url, resp.StatusCode)
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	urls := []string{
		"https://www.baidu.com",
		"https://www.google.com",
		"https://www.bing.com",
	}
	results := make(chan string)
	for _, url := range urls {
		go fetchAPI(ctx, url, results)
	}

	for range urls {
		fmt.Println(<-results)
	}
}
```

For this, create a context with a timeout of 5s -- then launch multiple goroutines to fetch data from different APIs concurrently -- the `http.NewRequestWithContext()`function is used to create an HTTP request with the provided context. If any of the API requests exceed the timeout duration the context’s cancellation signal is propagated.

#### Creating a Context -- 

To create one -- use the `context.Background()`which returns a empty, non-cancelable context just as the root of the context tree. Can also create a context with a specific timeout or deadline using `context.WithTimeout`or `context.WithDeadline()`functions.

#### Creating a context with Timeout -- 

In this, create a context with a timeout of 2s and use it to simulate a time-consuming operation -- just like:

```go
func performTask(ctx context.Context) {
	select {
	case <-time.After(5 * time.Second):
		fmt.Println("Task completed")
	}
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	go performTask(ctx)
	select {
	case <-ctx.Done():
		fmt.Println("Task timed out")
	}
}
```

For this, the `performTask()`simulate 5s to complete, however, since the context has a timout of just 2s -- the operation is terminated prematurely, resulting a timeout.

#### Propagating context

Once have a context, can propagage it to downstream functions or goroutines by passing it as an argument -- this allow related operations to share the same context and be aware of its cancellation or other values.

Propagating context to goroutines -- fore -- 

```go
func performTask(ctx context.Context) {
	userID := ctx.Value("UserID")
	fmt.Println("UserID: ", userID)
}
func main() {
	ctx := context.Background()
	ctx = context.WithValue(ctx, "UserID", 123) // ctx, key, value
	go performTask(ctx)
	time.Sleep(time.Second)
}
```

#### Retriving values from Context -- 

In addition to propagating context, can also retrieve values stored within the context. This allows U to access important data or parameters within the scope of a specific goroutine or function -- Fore, retrieving User Information from Context -- just like:

```go
func processRequest(ctx context.Context) {
	userID := ctx.Value("UserID").(int)
	fmt.Println("Processing request for user ID:", userID)
}
func main() {
	ctx := context.WithValue(context.Background(), "UserID", 123)
	performTask(ctx)
	time.Sleep(time.Second)
}
```

#### Cancalling context

Cancellation is an essential aspect of context management. Allows U to gracefully terminate operations and propagate cancellation signals to related goroutines -- like:

```go
func performTask(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			fmt.Println("Task cancelled")
			return
		default:
			// Perform task operation
			fmt.Println("Performing task")
			time.Sleep(500 * time.Millisecond)
		}
	}
}
func main() {
	ctx, cancel := context.WithCancel(context.Background())
	go performTask(ctx)
	time.Sleep(2 * time.Second)
	cancel()
	time.Sleep(1 * time.Second)
}
```

For this, create a context using `context.WithCancel()`and defer the cancellation function, and the `performTask`gorotuine continuously performs a task until the context is canceled.

#### Timeouts and Deadlines

Setting timeouts and deadlines is crucial when working with context in Golang -- It ensures that operations complete within a specific timeframe and prevents potential bottlenecks or indefninte waits.

```go
func performTask(ctx context.Context) {
	select {
	case <-ctx.Done():
		fmt.Println("Task completed or deadline exceeded:", ctx.Err())
		return
	}
}

func main() {
	ctx, cancel := context.WithDeadline(context.Background(),
		time.Now().Add(time.Second*2))
	defer cancel()
	go performTask(ctx)
	time.Sleep(time.Second * 3)
}
```

In this, create a context with a deadline of 2s using `context.WithDeadline()`-- the `performTask`goroutine waits for the context to be canceled or for the deadline to be exceeded.

#### Context in the HTTP requests

Context plays a vital role in managing HTTP requests in Go -- Allows U to control reuest cancellaion, timeouts, and pass important values to downstream handlers.

```go
func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "GET",
		"https://api.example.com/data", nil)
	if err != nil {
		fmt.Println("Error creating request:", err)
		return
	}
	client := http.DefaultClient
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error making request:", err)
		return
	}
	defer resp.Body.Close()
}
```

For this, create a context with a timeout 2s using `context.WithTimeout()`, then crete an http request with a custom context using `http.NewRequestWithContext()`-- this ensures that if the request takes longer than the specified timeout, it will be canceled.

#### Context in Database opertions

Context is also useful when dealing with dbs operations in Golang -- it allows U to manage query cancellations, timeouts, and pass relevant data within the database transactions.

```go
func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()
    
    db, err := sql.Open("postgres", "dsn")
    if err != nil {
        fmt.Println("Error connecting to the dbs", err)
        return
    }
    defer db.Close()
    
    rows, err := db.QueryContext(ctx, "Select * from users")
    if err != nil {
        fmt.Println("Error executing query", err)
        return
    }
    defer rows.Close()
    
    // process query results
}
```

In this, create a context with a timeout of 2s using `context.WithTimeout()`-- open a connection to a PostgreSQL dbs using the `sql.Open()`function. When executing the dbs query with `db.QueryContext()`, the context ensures that the operation will be canceled if it exceeds the specified timeout.

### Misunderstanding Go contexts

Developers sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the language and a foundation of concurent code in Go -- A context carries a deadline, a cancellation signal, and other values across API boundaries.

#### Deadline

A deadline refers a specific point in time determined with one of the following -- 

- A `time.Duration`from now
- A `time.Time`

The semantics of a deadline convey that an ongoing *activaity should be stopped* if this deadline is met.

```go
// radar 4h receive the flight positions
// once receive a pos, share it with other apps that are only interested in the latest pos
type publisher interface {
    Publish(ctx context.Context, position flight.Position) error
}
```

Accepts a context and a pos. And assume that the concrete imp calls  func to publish a message to a broker. Fore, this func is *context aware* -- it can cancel a request once the context is canceled.

```go
type publishHandler struct {
    pub publisher
}

func (h publishHandler) publishPosition(position flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
    defer cancel()
    return h.hub.Publish(ctx, position)
}
```

For this, creates a context using the `context.WithTimeout`-- this func accepts a timeout and a context -- as `publishPosition`doesn’t receive an existing contxt, create one from an empty context with `context.Background()`. Meanwhile, `context.WithTimeout`func returns two variables -- the context created and a cancellation `func()`function that will cancel the context once called.

Internally, `contxt.WithTimeout`creates a goroutine that will be *retained in memory for 4s or until the `cancel()`called*. Therefore, calling `cancel`as a `defer`func means that when exit the parent func, the context will be canceled, and the goroutine created will be stopped.

#### Cancellation signals

Another use case for Go contexts is to carray a cancellation signal -- Fore, `CreateFileWatcher(ctx, filename)`-- this func creates a specific file watcher that keeps reading from a file and catches updates. When the provided context expires or is canceled, this func handles it to close the file descriptor. Fore, a possible imp -- 

```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    go func() {
        CreateFileWatcher(ctx, "foo.txt")
    }()
    // ...
}
```

For this, when `main`returns, it calls the `cancel`to cancel the context passed to `CreateFileWatcher`so the file descriptor is closed gracefully.

#### Context values -- 

The last use case for Go context is to carry a K-V list -- like:

```go
ctx := context.WithValue(parentCtx, "key", "value")

// access the value using the `Value` method
ctx := context.WithValue(context.Background(), "key", "value")
fmt.Println(ctx.Value("key"))
```

Note that *key and value provided are `any`types*. For the value, want to pass `any`types -- but should be `any`or `string`? Two functions from different packages could use the same string value as a key -- hence, the latter would override the former value -- so

```go
package provider
type key string
const myCustomKey key= "key"
func f(ctx context.Context) {
    ctx = context.WithValue(ctx, myCustomKey, "foo")
}
```

And, another example is if we want to implement an HTTP middleware.

#### Catching a context Cancellation

The `context.Context`type exports a `Done()`that returns a receive-only notification channel `<-chan struct{}`. This channel is closed when the work associated with the context should be canceled. Fore:

- The `Done`related to a context created with `context.WithCancel()`is closed when `cancel()`called
- Or when `WithDeadline()`is closed when the deadline has expired.

Furthermore, `context.Context`exports an `Err`method returns `nil` if the `Done`isn’t yet closed. Otherwise, returns a *non-nil* explaining why the `Done`channel was closed -- 

- A `context.Canceled`error if canceled
- `context.DeadlineExceeded`if deadline passed.

```go
func handler(ctx context.Context, ch chan Message) error {
    for {
        select {
        case msg := <-ch:
            //...
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

Create a `for`and use `select`with two cases -- receiving messags from `ch`or receiving a signal that the context is done and we have to stop our job. A context allows us to carry a deadline, cancellation signal, and/or a list of keys-values. When in doubt about which context to use, can use `context.TODO()`instead of passing an empty context.