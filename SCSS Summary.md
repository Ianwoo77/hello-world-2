# SCSS Summary

Sass is a CSS preprocessor that gives your css superpowers-- 

#### Indented Syntax

This is older syntax -- Due to its advanced feature is often termed as Sassy CSS, like:

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
        display:block;
        text-decroation: none;
    }
}
```

Sass works in such a away that when you write your styles in a `.scss`file -- gets complied into a regular CSS file. Can declare variables in Sass -- This is one of Sass’s strengths since we can define variables for various properties and use them in any file. This is done by naming a variable with a `$`and then referencing it elsewhere in your code.

```scss
$primary-color: #24a0ed;

.text {
    color: $primary-color;
}
button {
    color: $primary-color;
    border: 2px solid $primary-color; // when reference, also need $
}
```

#### Nesting in Sass - 

Most of the time, while writing CSS, classes are often duplicated -- can avoid this duplication by nesting styles like:

```scss
nav {
    ...
}
```

With Sass, code like:

```scss
nav {
    width: 10vw;
    heigh: 100%;
    display: flex;
    ul {
        list-style: none;
    }
    a {
        text-decoration: none;
        color: #780070;
        &:hover {
            color: #069c54
        }
    }
}
```

The parent selector `&`is a special selector invented. In the case of the code above, the `&`will refer to the parent which is the achor tag `a`.

#### Partials in Sass -- 

Fore, if have a `_globals.scss`, `_variables.scss`and `_buttons.scss`, then like:

```scss
@use "globals";
@use "variables";
```

#### Mixins in Sass -- 

Another major issue with CSS is that you will often use a similar group o styles -- just like:

```scss
@mixin flex-container {
    display: flex;
    justify-content: space-aound;
    //...
}
.card {
    @include flex-container;
}
```

#### Sass Functions and Operators

Sass also provides a suite of tools to help write more programmaitc code -- offers built-in functions that enables us to do calculations and operations that return a specific value -- just like -- 

```scss
@use "sass:math";

@function pxToRem($pxValue) {
    $remValue: math.div($pxValue, 16px) * 1rem; // or use calc() method
    @return $remValue;
}
```

Also an example of conditional logic in a mixin -- 

```scss
@mixin body-theme($theme) {
    @if $theme == 'light' {
        background-color: $light-bg;
    }@else {
        background-color: $dark-bg;
    }
}
// use this
div {
    width: pxToRem(480px);
    @include body-theme("light");
}

$red: #ff0000;
a:visited {
    color: darken($red, 25%);
}
```

##### Set up Sass for Local development -- 

Watch Scss extension intalled. Just note that the savepath.

## Race problems

### Data races vs. race conditions

```go
var i int64
go func() {
    atomic.AddInt64(&i 1)
}()
go func() {
    atomic.AddInt64(&i, 1)
}()
```

Both goroutines update `i`atomically. Just note that atomic operation can’t be interrupted. Another option is to sync the two goroutines with an ad hoc data structure like a mutx -- like:

```go
i := 0
mutex := sync.Mutex{}
go func() {
    mutex.Lock()
    i++
    mutex.Unlock()
}()
```

Another is to prevent sharing the same location and instead favor communication across goroutines -- fore, can create a channel that each goroutine uses to produce the value of the increment just like:

```go
i := 0
ch := make(chan int)
go func() {
    ch <- 1
}()
go func() {
    ch <- 1
}()
i += <-ch
i += <-ch
```

Fore, Data races occur when multiple goroutines access the same memory location simultaneously and at least one of them is writing. With these 3 approaches, the value of `i`will eventaully be set to 2, regardless of the execution order of the two goroutines. Instead of having two goroutines increment a shared variable, now each one makes an assignemnt just like:

```go
i := 0
mutex := sync.Mutex{}

go func() {
    mutex.Lock()
    defer mutex.Unlock()
    i=1
}()
go func() {
    mutex.Lock()
    defer mutex.Unlock()
    i =2
}()
```

Both goroutines access the same variable, but not at the same time -- as the mutex protects it -- Depending on the execution order, will eventually equal either 1 or 2 -- this example doesn’t lead to data race, but it has a *race condition*. A race condition occurs when the bahavior depends on the sequence or the imte of events that can’t be controlled. And, ensuring a specific execution sequence among goroutines is a question of coordination and orchestration.

#### The Go memory Model

There are some core principles should be aware of as Go developers -- Fore, buffered and unbuffered channels offer differ guarantees -- to avoid unexpected races caused by a lack of understaning of the core specifications of the language, have to look at the Go memory model.

The Go memory model is a specification that defines the conditions under which a read from a vairable is one goroutine can be guaranteed to happen after a write to the same variable in a different goroutine.

Within multiple goroutines, should bear in mind some of these guarantees -- will use the *notation* A<B to denote that event A happens before event B.

- Creating a goroutine happens before goroutin’s execution begins -- 

  ```go
  i := 0
  go func() {i++}()
  ```

- The exit of a goroutine is not guaranteed to happen before any event -- 

  ```go
  i := 0
  go func() {
      i++
  }()
  fmt.Println(i) // has a data race
  ```

- A send on a channel happens before the corresponding receive from that channel completes. In the next,a parent grotuine increments a variable -- like:

  ```go
  i := 0
  ch := make(chan struct{})
  go func() {
      <-ch // third
      fmt.Println(i)
  }()
  i++ // first
  ch <-struct{}{} // second
  ```

  For this, can ensure that accesses to `i`are sync`and hence free from data races

- Closing a channel *happens before* a receive of this closure -- Is similar to the previous -- except that instead of sending a message, close the channel fore:

  ```go
  i := 0
  ch := make(chan struct{})
  go func() {
      <-ch // third block?
      fmt.Println(i)
  }()
  i++ // first
  close(ch) // second
  ```

- The last guarantee regarding channels may be counterintuitive at first -- a receive from an unbuffered channel happens before the send on that channel completes.

  ```go
  i := 0
  ch := make(chan struct{}, 1) // buffered ones
  go func() {
      i=1  // may occur simultaneously
      <-ch
  }()
  ch <- struct{}{}
  fmt.Println(i)
  ```

  This will lead to a data race -- can see that both the read and the write to `i`may occur simultaneously, Fore, changethe channel to an unbuffered one to illustrate the memory model gurantee -- 

  ```go
  i := 0
  ch := make(chan struct{})
  go func() {
      i = 1
      <- ch
  }()
  ch <- struct{}{}
  fmt.Println(i)
  ```

  Changing the channel type makes this example just data-race-free. How we can see the main difference -- the write is guaranteed to happen before the read.

### The concurrency impacts of a workload type

This section looks at the impacts of a workload type in a concurrent implementation. Depending on whether a workload is CPU - or I/O bound, need to tackle the problem differently.

In programming, the exeuction time of a worklod is limited sort algorithm. And the following implements a `Read`that accepts an `io.Reader`and reads 1024 from it repeatedly -- like:

```go
func reader(r io.Reader) (int, error) {
    count := 0
    for {
        b := make([]byte, 1024)
        _, err := r.Read(b)
        if err != nil {
            if err == io.EOF {
                break
            }
            return 0, err
        }
        count += task(b)
    }
    return count, nil
}
```

### Golang context

Is a fundamental aspect of Go progamming -- Context provides a mechanism to control the lifecycle, cancellation, And propagation of requests across multiple goroutines.

Context is a built-in package in Go STDLIB that provides a powerful toolset for managing concurrent operations.

#### Managing Concurrent API requests -- 

Consider a scenario where U need to fetch data from multiple APIs concurrently, by using the context, can enaure that all the API requests are canceled if any of them exceeds a specified timeout.

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
	results <- fmt.Sprintf("Response from :s: %d", url, resp.StatusCode)
}
func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	urls := []string{
		"https://api.example.com/users",
		"https://api.example.com/products",
		"https://api.example.com/orders",
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

Just create a context with a timeout of 5s -- then launch multiple goroutines to fetch data from different APIs concurrently. The `http.NewRequestWithContext()`function is used to create an HTTP request with the provided context.

#### Creating a Context

To create, canuse the `context.Background()`function -- whcih returns an emtpy, non-cancelable contxt as the root of the context tree. U can also create a conetxt with a specific timeout or dealing using `context.WithTimeout()`or `context.WithDeadline()`functions -- 

In this example, create a context with a ttimeout of 2 seconds and use it to simulate a time-consuming operation -- like

```go
func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	go performTask(ctx)

	select {
	case <-ctx.Done():
		fmt.Println("Task timed out")
	}
}
func performTask(ctx context.Context) {
	select {
	case <-time.After(5 * time.Second):
		fmt.Println("Task completed successfully")
	}
}
```

In this example, the `performTask()`function simulates a long-running task that taks 5 seconds to complete. Since the context has a timeout of only 2 seconds.

#### Propagating Context

Once U have a context, U can propagate it to downstream functions or goroutines by passing it as an argument. This allows related operations to share the same context and be aware of its cancellation or other values.

Progagating context to Goroutines -- In this example, create a parent context and propagate it to multiple goroutins to perform concrurrent tasks.

##### Propagating context to Goroutines -- 

```go
func main() {
	ctx := context.Background()
	ctx = context.WithValue(ctx, "UserID", 123)
	go performTask(ctx)
	time.Sleep(time.Second)
}
func performTask(ctx context.Context) {
	userID := ctx.Value("UserID")
	fmt.Println(userID)
}
```

In this, create a parent context using `context.Background()`we then use `context.WithValue()`to attach a user ID to the co