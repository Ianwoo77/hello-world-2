# Creating a mobile menu

Functionally, this menu is much like the dropdown menu U built in the last chapter -- Initially, hide the `menu-dropdown`, then had some Js functionality.

TIP -- Screen readers use certain HTML5 element such as `<form>, <main>, <nav>`and `<aside>`as *landmarks.*

```css
.menu {
    position: relative; /* for both absolutely positioned children */
}

.menu-toggle {
    position: absolute;
    //...
    overflow: hidden;
}
```

`position: relative`, it positions the element *relative to its normal position* in the document flow: Note:

- The element still occupies its original space in the layout, even though it appears shifted
- Useful for fine-tuning layout without disrupting surrounding elements
- Often used as a reference point for absolutely positioned child elements.
- The `sticky`acts like `relative`until a scroll threshold is met.
- Note that the `absolute`, removes the elment from the nomal document flow.

So the structure is like:

```html
 <nav class="menu" id="main-menu">  // relative
        <button class="menu-toggle" id="toggle-menu"> // absolute 
            toggle menu
        </button>
        <div class="menu-dropdown">
            //...
```

Them `menu` is relatively positioned to establish a containing block for both its child elements.

Note the Bootstrap provides a set of position utility classes that make it easy to control the positioning of element without writing custom css. Also using the `top-0`... to control the corners or eges.

```jsx
<div class="position-relative">
	<div class="position-absolute" top-0 start-0>Top left</div>
</div>
```

##### Adding the viewport meta tag -- 

There is one important detail messing -- the viewport *meta tag* -- this is an HTML tag that tells devices for small screens. In the `<head>`just like:

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

#### Media queries

The second component of responsive design is the use of media queries --  Can define a set of styles that apply to small devices, another set for medium-sized devices -- and yet a third set for large sreens fore:

```css
@media (min-width: 560px) {
    .title > h1 {
        font-size: 2.25rem;
    }
}
```

The `@media`rule is a conditional check that must be true for any of these styles to be applied to the page. For this, the browser checks for a `min-width:560px`-- 2.25rem will only be applied to the title’s `h`if the user’s device has a viewport width of 560px or *greater*.

##### Types of media queries

Can further refine a media query by joining the two clauses with the keyword `and`just like:

```css
@media (min-width: 320px) and (max-width: 560px) {...}
```

And if want a media query target one of multiple critieral, using a *comma* just like:

```css
@media (max-width: 320px), (min-width: 560px) {...}
```

##### Adding breakpoints to the page

Practically, a mobile-first approch means the type of media query you will use the most should be `min-width`. This follows the general structure like:

```css
.title {} /* mobile first*/, applied to all breakpoints

@media (min-width: 35em) {
    .title {}
}
@media (min-width: 50em) {
    .title{}
}
```

For the coffee structure -- just like:

```css
@media (min-width: 560px) {
    .page-header {
        padding: 1em;
    }
}

@media (min-width: 560px) {
    .hero {
        padding: 5em 3em;
        font-size: 1.2rem;
    }
}

@media (min-width: 560px) {
    main {
        padding: 2em 1em;
    }
}
```

Next, the menu will involve two changes -- first will remove the open and close behaviro of the dropdown, Second, will change the menu from vertically stacked links into horizontal ones. Just like:

```css
@media (min-width: 560px) {
    .menu-toggle {
        display: none;
    }
    .menu-dropdown {
        display: block;
        position: static;
    }
}

@media (min-width: 560px) {
    .nav-menu {
        display: flex;
        border:0;
        padding-inline: 1em;
    }

    .nav-menu > li {
        flex: 1;
    }

    .nav-menu > li + li {
        border: 0;
    }

    .nav-menu > li > a {
        padding: .3em;
        text-align: center;
    }
}
```

##### Adding responsive columns

The final change to make for the medium breakpoint is the introduction of mulitple columns -- 

```css
@media (min-width: 650px) {
    .main{
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 1.5em;
        max-inline-size: 1400px;
        margin-inline: auto;
    }
}
```

## Using a filename as function input

When creating a new function needs to read a file, passing a filename isn’t considered a best practice and can be negative effects -- such as making unit tests harder to write. If:

```go
func countEmptyLinesInFile(filename string) (int, error) {
    file, err := os.Open(filename)
    if err!= nil {
        return 0, err
    }
    defer file.Close()
    // handle the file closure
    emptyLines := 0
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        // Get the current line and trim space
        line := scanner.Text()
        if strings.TrimSpace(line) == "" {
            emptyLines++
        }
    }
    
    // also check for errors may have occurred 
    if err := scanner.Err(); err!= nil {
        return 0, err
    }
    return emptyLines, nil
}
```

For this, will do what we expect it to do -- say want to implement unit tests to cover the following -- 

- Nominal case
- An emtpy file
- A file containing only empty lines

For thses, each unit test will require creating a file in proj. The more complex the function is, the more cases may want to add. Furthermore, this function isn’t reusable -- if had to implement the same logic but count the number of empty lines with an HTTP request, would have to duplicate the main logic like:

```go
func countEmptyLinesInHttpRequest(request http.Request) (int, error) {
    scanner := bufio.NewScanner(request.Body)
    // ... same logic
}
```

In Go, the idiomatic way is to start from the reader’s abstraction -- like:

```go
func countEmptyLines(reader io.Reader) (int, error) {
    scanner := bufio.NewScanner(reader)
    for scanner.Scan() {
        //...
    }
}
```

Cuz `bufio.NewScanner`accepts an `io.Reader`, can directly pass the `reader`variable. For this, function abstracts th data source -- And another benefits is related to testing -- like:

```go
func TestCountEmptyLines(t *testing.T) {
    emptyLines, err := countEmptyLines(strings.NewReader(
    	`foo
    	bar
    	
    	biz
    	`
    ))
    // test logic
}
```

### How `defer`arguments and receivers are evaluated

A common mistake made in Go is not understanding how arguments are evaluated.

```go
const (
	StatusSuccess= "success"
	StatusErrFoo = "error_foo"
	StatusErrorBar = "error_bar"
)

func f() error {
	var status string
	defer notify(status)
	defer incrementCounters(status)

	if err := foo(); err != nil {
		status = StatusErrFoo
		return err
	}

	if err := bar(); err != nil {
		status = StatusErrorBar
		return err
	}

	status = StatusSuccess
	return nil
}
```

Declared a `status`variable, then declare the calls to the `notify`and `incrementCounter`using `defer`. Throughout this function, and depending on the execution path, update the `status`accordingly. Note that for this, `nitify`and `incrementCounter`are always called with the same status -- an emtpy string -- Understand sth curcial about argument evaluation in a `defer`function -- The arguments are evaluated *right away* -- not once the surrounding functon returns. For this, the first solution is to pass address like:

```go
func f() error {
	var status string
	defer notify(&status)
	defer incrementCounter(&status)
	
	if err := foo(); err != nil {
		status = StatusErrorFoo
		return err
	}
	//...
}
```

Using `defer`evaluates the argument *right away* -- here the address of `status`-- Its address remain constant, regardless of the assignments.

And the solution is calling a closure as a `defer`statement -- just like: If has:

```go
func main() {
    i := 0
    j := 0
    defer func(i int) {
        fmt.Println(i, j) // 0, 1, j references a variable outside of the colusre
        				// evaluated when the closure is executed
    }(i) // i as argument evaluted immediately
    i++
    j++
}
```

Therefore, can use a colosure to implement a new version of our function just like:

```go
func f() error {
    var status string
    defer func() {
        notify(status)
        incrementCounters(status)
    }()
}
```

For this, wrap the calls to both `notify`and `incrementCounter`within a closure. Therefore, `status`is evaluated once the closure is executed, not when call `defer`.

### Error Management - Panicking

It’s just pretty common for Go newcomers to be somewhat confused about error handling, In Go -- errors are usually managed by functions or methods that returns an `error`type as the last parameter. But in Go, `panic`is a built-in function that stops the oridinary flow like:

```go
func main() {
    panic("foo")
}
```

Once a panic triggered, it just continues up the *call stack* until either the current goroutine has returned or `panic`is caught with `receover`. fore:

```go
func main() {
    defer func() {
        if r := recover(); r!= nil {
            fmt.Println("recover", r)
        }
    }()
    f()
}

func f() {
    panic("foo")
}
```

In the `f()`, once `panic`is called, it stops the current execution of the function and goes up the call stack -- `main`. Note that calling `recover()`to capture a goroutine panicking is only useful inside a `defer`func.

In Go, `panic`is used to signal genuinely exceptional conditions, such as a programmer error Fore:

```go
func checkWriteHeaderCode(code int) {
    if code < 100 || code > 999 {
        panic(fmt.Sprintf("invalid WriteHeader code: %v", code))
    }
}
```

Another example based on a programmer error can be found in the database/sql package while registering a dbs driver just like:

```go
func Register(name string, driver driver.Driver) {
    driverMu.Lock()
    defer driverMu.Unlock()
    if driver == nil {
        panic("sql: Register driver is null")
    }
    if _, dup := drivers[name]; dup {
        panic("sql: Register called twice for driver "+ name)
    }
    drivers[name] = driver
}
```

For this, func panics if the driver is `nil`or has already been registered.

Another use case in which to panic is when application requires a dependency but fails to initialize. Fore, imagine expose a service to create a new customer accounts. Fore, at some stage, this needs to validate the provided email address. Fore, in Go, the `regexp`exposes two functions to create Regular exprssion from a string: `Compile`and `MustCompile`-- the former -- `*regexp.Regexp`and an error.

### Ignoring when to wrap an error

Since 1.13, the `%w`directive allows us to wrap errors conveniently. But some developers may be confused about when to wrap an error. Error wrapping is about wrapping or packing an error inside a wrapper container that also makes the source error available.

- Adding additional context to an error
- Making an error as a special error

Regarding adding context -- consider the following -- receive a request from a specific users to access a dbs resource -- but get a *permission denied* error during the query. For debugging purposes, if the error ise eventually logged, want to add extra context, in this case, can wrap the error to indicate who the user is and what resource is being accessd.

And, insted of adding a context, want to *mark* the error -- fore, we want to implement an HTTP handler that checks whether all the errors received while calling functions are of a `Forbidden`type so return a 403 code.

In both cases, the source error remains *available* hence, a caller can also handle an error by *unwrapping* it and checking the source error. Also note want to sometings combine both approaches -- adding context and marking.

In Go, wrapping an error with additional context or marking it for later inspection is a common practice to improve error handling and debugging.

```go
if err := dosth(); err != nil {
    return fmt.Errorf("failed to do sth: %w", err)
}

// useing errors.Join() 
err1 := errors.New("network timeout")
err2 := errors.New("retry limit exceeded")
return errors.Join(err1, err2)

// insepcting 
if errors.Is(err, os.ErrNotExist) {}
var pathErr *os.PathError
if errors.As(err, &pathErr) {...}
```

`errors.Is`checks if an err is of specific type, and `As`extracts the underlying error type. In both cases, the source error remains available. Hence, a caller can also handle an error by unwrapping it and checking source error.

### Selecting channels

How can have one goroutine respond to messages coming from different goroutines over multiple channels Using the `select`statement, specify multiple channel operations as separate cases and then execute a case depending on whcih channel is ready. The `select`lets us group read operations on multiple channels together, blocking the goroutine until a message arrives on *any one* of the channel.

Once a message arrives on any of the channels, the goroutine unblocked, and a code handler for that channel is run. How this translates to code -- just like:

```go
func writeEvery(msg string, seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		for {
			time.Sleep(seconds)
			messages <- msg
		}
	}()
	return messages
}
```

Can demonstrate the `select`by calling the `writeEvery()`function twice -- Just like:

```go
func main() {
	messageFromA := writeEvery("Tick", time.Second)
	messageFromB := writeEvery("Tock", 3*time.Second)

	for {
		select {
		case msg1 := <-messageFromA:
			fmt.Println(msg1)
		case msg2 := <-messageFromB:
			fmt.Println(msg2)
		}
	}
}
```

When using `select`, if multiple cases are ready, a case is chosen *at random*.

##### Using a select for non-blocking channel operations

Another use case for `select`when need to use channels in a non-block manner. Try to read a message from a channel, then if no are availble, instead of blocking , have the current execution work on a default set of instructions. So the `select`gives us the *default case* for exactly this scenario.

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		time.Sleep(seconds)
		messages <- "Hello"
	}()
	return messages
}
func main() {
	messages := sendMsgAfter(3 * time.Second)
	for {
		select {
		case msg := <-messages:
			fmt.Println("Message received", msg)
			return
		default:
			fmt.Println("No message waiting")
			time.Sleep(time.Second)
		}
	}
}
```

##### Performing concurrent computation on the default case

A useful scenariois to use the default select case for concurrent computations and then use a channel to signal when need to stop. Fore:

```go
const (
	passwordToGuess = "go far"
	alphabet        = " abcdefghijklmnopqrstuvwxyz"
)

func toBase27(n int) string {
	result := ""
	for n > 0 {
		result = string(alphabet[n%27]) + result
		n /= 27
	}
	return result
}
```

For this brute force approach -- would just create a loop enumerating the strings from a to zzzzz. To find faster, can divide the range of our guesses among several goroutines. Also note that to avoid unnecessary computation, want to stop the execution of each goroutine when any goroutine makes a correct guess.

Note -- can use the `close()`operation on a channel to act like a signal being *broadcast* to all consumers. One solution is to perform the ncessary computation in the `select`statement’s default case and then have another case waiting on the common channel.

