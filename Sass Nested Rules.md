# Sass Nested Rules

```scss
nav {
    ul {
        margin:0;
        padding:0;
        list-style:none;
    }
    li {
        display: inline-block;
    }
    a {
        display: block;
        padding: 6px 12px;
        text-decoration:none;
    }
}
```

#### Nexted properties

Many CSS properties have the same prefix ... And just like CSS, Sass also supports `@import`directive. 

```scss
a {
    text-decoration: none;
    color: #707070;

    &:hover {
        color: #069c54;
    }
}
```

For this, in SASS `&:hover&`is a nested selector that refers to the parent selector -- `a`. Fore 

#### Parent Selector

In the Sass code -- might notice the `&`used with the over pseudo-class -- Here just refer to the parent which is the anchor tag `a`.

#### Partials in Sass -- 

This is one of the many awesome features of Sass that gives U an advantage -- It gets difficult to maintain them -- As stylesheets grow large over time -- To declare a partial, just start a file name with an underscore `_`, and add it in another `Sass`file using the `@import`directive.

Fore, if have `_globals.scss, _variables.scss`...could:

```scss
@import "globals";
@import "variables";
```

For Sass automatically assumes that you are just referring to the `.sass`or `.scss`file

##### Mixins in Sass

Another major issue with CSS Just use the `@use`directive. Mixins allow you to encapsulate a group of styles, and apply those styles anywhere in your code using the `@include`keyword like:

```scss
@mixin flex-container {
    display: flex;
    justify-content: space-around;
    //...
}

.card {
    @include flex-container
}
.aside {
    @include flex-container
}
```

#### Sass Functions and operators

Sass provides a suite of tools to help write more programmatic code -- Offers built-in functions that enable us to do caulculations and operations that return a specific value -- Also supports for mathematical operators like + - * /...

```scss
@function pxToRem($pxValue) {
    $remValue: calc($pxValue / 16) + rem;
    @return $remValue;
}

div {
    width: pxToRem(480)
}
```

Note that should use `calc`function to do that. Also can:

```scss
@use "sass:math";

@function pxToRem($pxValue) {
    $remValue: math.div($pxValue, 16px) * 1rem;
    @return $remValue;
}

div{
    width: pxToRem(480px);
}
```

And herei s an example of conditional logic in a mixin -- like;

```scss
@mixin body-theme($theme) {
    @if $theme =="light" {
        background-color: $light-bg;
    }

    @else {
        background-color: $dark-bg;
    }
}
div {
    width: pxToRem(480px);
    @include body-theme("light");
}
```

Note that should use the `@include`directive. Note that Sass also provides the `lighten`and `darken`functions to adjust a color by a certain percentage.

```scss
$red: #ff000000;
a:visited {
    color: darken($red, 25%);
}
```

Just install `live sass compiler`in Vsocde, then set the save location.

## Handling `defer`errors

Not handling errors in the `defer`statement ais a mistake that is frequently made by Go developers -- understand what the problem is and the possible solutions -- 

```go
const query= "..."

func getBalance(db *sql.DB, clientID string) (float32, error) {
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer rows.Close()
    
    // use rows
}
```

For this, `rows`is a `*sql.Rows`type implements the `Closer`interface like:

```go
type Closer interface {
    Close() error
}
```

This interface contains a single `Close()`method that returns an error -- mentioned in the prievous -- errors should always be handled -- in this case, the error returned by the `defer`call is just ignored. For this if don’t want to handle the error, should ignore it explicitly using the `_`just like:

```go
defer func() { _ = rows.Close()} ()
```

This version is more verbose, but is better from a maintainability perspective. In some case, instead of blindly ignoring all errors from the `defer`, should ask -- whether that is the best approach -- In this case, calling `Close()`returns an error when it fails to free a DB connection from the pool. Just ignoring this error is probably not what we want to do.

```go
defer func() {
    err := rows.Close()
    if err != nil {
        log.Printf("failed to close rows: %v", err)
    }
}()
```

Or, prefer to propagate it to the caller of `getBalance()`so they can decide how to handle it -- 

```go
defer func() {
    err := rows.Close()
    if err != nil {
		return err
    }
}()
```

Note that this imp doesn’t compile at all -- the `return`statement is associated with the anonymous `func()`function, not `getBalance()`

So, if want to tie the error returned by the `getBalance`to the `error`caught in the `defer `call, then must use named result parametes like:

```go
func getBalance(db *sql.DB, clientID string) (balance float32, err error) {
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer func() {
        err = rows.Close()
    }()
    
    if rows.Next() {
        err := rows.Scan(&balance)
        if err != nil {
            return 0, err
        }
        return balance, nil
    }
}
```

But, there is a problem with it -- if `rows.Scan`returns an error, `rows.Close()`is just executed anyway. But because this call overrides the error returned by `getBalance()`, instead of returning an error, may return a `nil`error if `rows.Close()`returns successfully. If the call to `db.Query`succeeds, the error returned by `getBalance()`will always be the one returned just by `rows.Close`. Namely -- 

- If `rows.Scan`succeeds
  1. If `rows.Close()`succeeds, return no error
  2. If `rows.Close()`fails, return this error
- If `rows.Scan`fails -- 
  1. If `rows.Close()`succeeds, return the error from the `rows.Scan()`
  2. If `rows.Close()`fails, then --- Namely, both `rows.Scan`and `rows.Close`fail

For the latest scenario -- Can return a custom error that conveys two errors, or , Another option, which we will implement is to return the `rows.Scan()`error but log the `rows.Close()`error.

```go
defer func() {
    closeErr := rows.Close()
    if err != nil { // err was alrady returned by getBalance()
        if closeErr != nil {
            log.Printf("failed to close row: %v", err)
        }
        return
    }
    // err is nil but, then just assign it to closeErr
    err = closeErr
}()
```

### Concurrency - Foundations, Concurrency and Parallelism

Can notice sth important -- *concurrency* enables *parallism* -- concurrency provides a structure to solve problem with parts that may be parallelized. Concurrency is about dealing with lots of things at once, and Parallism is about doing lots of things at once.

Concurrency is about structure, can change a sequential imp into a concurrent by intoducing different steps that separate concurrent threads can tackle. Parallelims is about exection -- use it at the step level by adding more parallel threads.

### When to use channels or mutexes

May not always be clear whether we can implement a solution using channels, or mutexes. Go promotes sharing memory by communication, one mistake could be to always force the use of chanels.

Channels are communication mechanism -- internally, a channel is a pipe we can use to send and receive values and that allows us to *connect concurrent* goroutiens -- A channel can be Unbuffered, or Buffered. Fore

`G1`and `G2`are parallel goroutines -- may -- two goroutines executing the same function that keep receiving message form a channel, or executing same HTTP handler.

Fore, `G1`and `G3`are concurrent as `G23`, all the goroutines are part of an overall concurrent structure.

In general, parallel goroutines have to sync -- fore, when they need to access or mutate a shared resource such as a slice -- Sync is enforced with mutexes but no with any channel types. Synchronization is enforced with mutexes but not with any channel types -- in general, sync between parallel goroutines should be achieved via mutexes.

Regarding concurrent goroutines, there is also the case where want to transfer the ownership of a resource from one step to another. Conversely, channels are a mechanic for signaling with or without data.

### Data race vs race conditions

```go
i := 0
go func() {
    i++
}()
go func() {
    i++
}()
```

With `-race`option, warns us that a dta race occurred. So, if two goroutines simultaneously access the same memory location with at least one writing to that memory location. Can do using the `sync/atomic`package -- like:

```go
var i int64

go func() {
    atomic.AddInt64(&i, 1)
}()
go func() {
    atomic.AddInt64(&i, 1)
}()
```

Note that the `sync/atomic`package provides primitives for `int32, int64...`but not for `int`. Another option is to use the `mutex`like:

```go
go func() {
    mutex.Lock()
    i++
    mutex.Unlock()
}() 
```

Another is to prevent sharing the same memory location and instead favor communication across the goroutines. Can create a channel that each goroutine uses to produce the value of the increment

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

Instead of having two goroutines increments a shard variable -- 

```go
i := 0
mutex := sync.Mutex{}

go func() {
    mutex.Lock()
    defer mutex.Unlock()
    i = 1
}()

go func() {
    mutex.Lock()
    defer mutex.Unlock()
    i=2
}()
```

Both goroutines access the ame variable, but not at the same time -- as the mutex protects it -- But is this example deterministric - no -- dpending on the execution order, `i`will eventually equal either 1 or 2 -- this example doesn’t lead to a data race.  It has a *race condition* -- A race condition occurs when the behaviro depends on the *sequence* or the timing of events thatn can’t be controlled.

### Optimizing memory consumption

With message passing, each goroutine has its own isolated state stored in the memory. When pass messages from one to another, each organizes the data in its memory to compute its task. Fore, could change the program to use message passing by having each goroutine build a local instance of a slice with the frequences encountered  while downloading its web page.

```go
func countLettersFunc(url string) <-chan []int {
	result := make(chan []int)
	go func() {
		defer close(result)
		frequency := make([]int, 26)
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
		fmt.Println("Completed:", url)
		result <- frequency
	}()
	return result
}

func main() {
	results := make([]<-chan []int, 0)
	totalFrequencies := make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		results = append(results, countLettersFunc(url))
	}
	for _, c := range results {
		frequencyResult := <-c
		for i := 0; i < 26; i++ {
			totalFrequencies[i] += frequencyResult[i]
		}
	}

	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, totalFrequencies[i])
	}
}
```

In converting our program to use message passing, have avoided using mutexes to control access to shared memory since each goroutine is not only working on its own data.

#### Communicating efficiently -- 

Message passing will degrade the performance of our app if we are spending too much time passing messages aournd. Since pass copies of messages from one goroutin to another, suffer the performance penalty of spending time copying the data in the message.

### Programming with channels

Working with channels requires a different way of programming than when using memory sharing. The idea is to have a set of goroutines, each with its own internal state, exchanging information with other goroutines by passing messages on Go’s channels.

#### Concurrent programming with CSP

A different, higher-level model of concurrency was proposed by CAR 1978 article -- CSP, Process communicate with each other by exchanging copies of values.

The first pattern will examine is having a common channel that instructs goroutines to stop processing messages. In the previous chapter, saw how can use Go’s `close(channel)`call to notify a goroutine that no more messages are coming. The goroutine can then terminate its execution. But what should we do if our goroutine is consuming from more than one channel. Should we terminiate exeution when we receive the first `close()`.

```go
func printNumbers(numbers <-chan int, quit chan int) {
    go func() {
        for i:=0; i<10; i++ {
            fmt.Println(<-numbers)
        }
        close(quit)
    }()
}
```

