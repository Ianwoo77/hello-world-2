# Responsive design

How do we disign our site so it’s usable and appealing on any device our users might use to access it. The approach began to break down as more and more devices emerged on the maket. A far better approach is to serve the same HTML and CSS to all your users. There are 3 key principles of responsive design -- 

- *mobile-first approach to design* -- have a plan for the mobile version
- The *@media* at-rule -- can tailor your styles for viewports of different sizes
- *use of fluid layouts* -- different sizes based on the width of the viewport.

Note that in Bootstrap, don’t need to write own `@media`queries. Cuz the framework is built with a mobile-first appraoch, it already includes a comprehensive set of media queries and helper classes. Fore:

Extra Small -- <576px, Small, Medium, Large, Extra Large, Extra Extra Large.

```html
<body>
    <header id="header" class="page-header">
        <div class="title">
            <h1>Wombat Coffee Roasters</h1>
            <div class="slogan">We love Coffee</div>
        </div>
    </header>

    <nav class="menu" id="main-menu">
        <button class="menu-toggle" id="toggle-menu">
            toggle menu
        </button>
        <div class="menu-dropdown">
            <ul class="nav-menu">
                <li><a href="/about.html">About</a></li>
                <li><a href="/shop.html">Shop</a></li>
                <li><a href="/menu.html">Menu</a></li>
                <li><a href="/brew.html">Brew</a></li>
            </ul>
        </div>
    </nav>

    <aside id="hero" class="hero">
        Welcome to Wombat Coffee Roasters! We are
        passionate about our craft, striving to bring you
        the best hand-crafted coffee in the city.
    </aside>

    <main class="main">
        <section class="column">
            <h2 class="subtitle">Single-origin</h2>
            <p>We have built partnerships with small farms
                around the world to hand-select beans at the
                peak of season. We then carefully roast in
                <a href="/batch-size.html">small batches</a>
                to maximize their potential.
            </p>
        </section>
        <section class="column">
            <h2 class="subtitle">Blends</h2>
            <p>Our tasters have put together a selection of
                carefully balanced blends. Our famous
                <a href="/house-blend.html">house blend</a>
                is available year round.
            </p>
        </section>
        <section class="column">
            <h2 class="subtitle">Brewing Equipment</h2>
            <p>We offer our favorite kettles, French
                presses, and pour-over cones. Come to one of
                our <a href="/classes.html">brewing
                    classes</a> to learn how to brew the perfect
                pour-over cup.</p>
        </section>
    </main>
</body>
```

The button to toggle the menu for mobile screen is inside the `nav`element. And the `nav-menu`is placed where it can meet your needs for both mobile and desktop design.

```css
*, ::before, ::after {
    box-sizing: border-box;
}

:root {
    font-size: clamp(0.9rem, 0.5svw + 0.6em, 1.125rem);
}

body{
    margin:0;
}

a:link {
    color: #1476b8;
    font-weight: bold;
    text-decoration: none;
}
a:visited {
    color: #1430b8;
}
a:hover{
    text-decoration: underline;
}
a:active{
    color: #b81414;
}

.page-header {
    padding: .4em 1em;
    background-color: #fff;
}

.title > h1 {
    color: #333;
    text-transform: uppercase;
    font-size: 1.5rem;
    margin-block: .2em;
}
.slogan {
    color: #888;
    font-size: 0.875em;
    margin: 0;
}

.hero {
    padding: 2em 1em;
    text-align: center;
    background-image: url(coffee-beans.jpg);
    background-size: 100%;
    color: #fff;
    text-shadow: .1em .1em 0.3em #000;
}

main {
    padding: 1em;
}

.subtitle {
    margin-block: 1.5em;
    font-size: 0.875rem;
    text-transform: uppercase;
}
```

For the `text-shadow`property in the hero image might be new to you -- consists of several values that together define a shadow to add behind the text.

```css
.class {
    text-shadow: offset-x offset-y blur-raduis color;
}
```

#### Creating a mobile menu

In the HTML, just noticd that the `<nav>`appears after the `<header>`as a sibling element.

```css
.menu {
    position: relative;
}

.menu-toggle {
    position: absolute;
    top: -1.2em;
    right: 0.1em;
    border: 0;
    background-color: transparent;
    font-size: 3em;
    width: 1em;
    height: 1em;
    line-height: 0.4;
    text-indent: 5em;
    white-space: nowrap;
    overflow: hidden;
}

.menu-toggle::after {
    position: absolute;
    top: .2em;
    left: .2em;
    display: block;
    content: "\2261";
    text-indent: 0;
}

.menu-dropdown {
    display: none;
    position: absolute;
    right: 0;
    left: 0;
    margin: 0;
}

menu.is-open .menu-dropdown {
    display: block;
}
```

Then the `is-open`class will be added via JS when the menu is open.

```js
const button = document.getElementById('toggle-menu');
button.addEventListener('click', (e) => {
    e.preventDefault();
    const menu = document.getElementById('main-menu');
    menu.classList.toggle('is-open');
});
```

```css
.nav-menu > li > a {
    display: block;
    padding: 0.8em 1em;
    color: #fff;
    font-weight: normal;
}
```

## Functions and methods

Choosing a receiver of type for a method isn’t always straightforward -- when should use value recevier or pointer receivers -- In many contexts, using a value or pointer receiver should be dictated not by performance, but rather by other conditions that will discuss -- With a value receiver, Go makes a copy of the value and passes it to the method.

```go
type customer struct {
    balance float64
}
func (c customer) add(v float64) {
    c.balance += v
}
// on the other hand, with a pointer receiver, Go passes the address of an object to the method
func (c *customer) add(operation float64) {
    c.balance += operation
}
```

But, choosing between value and pointer receivers isn’t always straightforward -- Fore:

##### A receiver *must* be a pointer

- If the method needs to mutate receiver -- note that the rule is also valid if the receiver is even a slice

  ```go
  type slice []int
  func (s *slice) add(element int) {
      *s = append(*s, element)
  }
  ```

- If the method receiver contains a field that **cannot be copied**.

##### A receiver should be a pointer

- If the receiver is a large object

##### *must* be a value -- 

- If have to enforce a recevier’s immutability
- If the receiver is a *map, funciton, or channel*.

##### Should be a value, if the receiver:

- doesn’t have to be mutated
- is a small array or struct that is naturally a value type without mutable fields, `time.Time`fore
- If the receiver is a basic type such as `int, float64...`

### Using named result parameters

Can attach names to these parameters and use them as regular variables, when a result parameter is named, it’s initialized to its zero value when the function/method begins. With named result parameters, can also call *naked* result statement. For some case, should probably use named result parameters to make the code easier to read:

```go
type locator interface {
    getCoordinates(address string) (lat, lng float64, err error) 
}
```

Pursue the question of when to use named result parameters with the method imp -- 

```go
func (l loc) getCoordinates(address string) (lat, lng float32, err error) {}
```

For, not good -- 

```go
func StoreCustomer(customer Customer) (err error) // not useful for readers
```

### Side effects with named result parameters

As these result parameters are initialized to zero value -- using them can sometimes lead to subtle bugs. Fore:

```go
func (l loc) getCoordinates (ctx context.Context, address string) (lat lng float32, err error) {
    isValid := l.validateAddress(address)
    if !isValid {
        return 0, 0, errors.New("Invalid address")
    }
    if ctx.Err() != nil {
        return 0, 0, err
    }
}
```

The error might not be obvious -- The error returned in the `if ctx.Err!=nil`scope is `err`. But we just have not assigned any value to the `err`variable. Still assigned any value to the `err`variable. Still assigned to the zero value of an `error`type, `nil`. One possible fix to assign `ctx.Err()`to `err`like -- 

```go
if err := ctx.Err(); err != nil {
    return 0, 0, err
}
```

### Returning an `nil`receiver -- 

Impact of returning an interface and why doing so may lead to errors in some conditions. Consider the following example -- on a `Customer`struct and implement a `Validate`method to perform sanity checks.

```go
type MultiError struct {
    errs []string
}
func (m *MultiError) Add(err error) {
    m.errs = append(m.errs, err.Error())
}
func (m *MultiError) Error() string {
    return strings.Join(m.errs, ";")
}
```

This satisfies the `error`interface cuz implements the `Error() string`Using this structure, can implement a `Validate`method in the following manner to check the customer’s age and name like:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age < 0 {
        m = &MultiError{}
        m.Add(errors.New("age is negative"))
    }
    if c.Name == "" {
        if m== nil {
            m = &MultiError{}
        }
        m.Add(errors.New("name is nil"))
    }
    return m
}

customer := Customer{Age: 33, Name: "John"}
if err := customer.Validate(); err!=nil {
    log.Fatal...
}
```

In Go, have to know that **a pointer receiver can be `nil`**.If:

```go
type Foo struct{}
func(foo *Foo) Bar() string {
    return "bar"
}
func main() {
    var foo *Foo
    fmt.Println(foo.Bar())
}
```

For this, `foo`is initialized to the zero value of a pointer `nil`-- this code just compiles -- and it prints `bar`. Cuz in Go, a method is just syntacitc sugar for a function whose first parametrer is the reciver like:

```go
func Bar(foo *Foo) string {
    return "bar"
}
```

For the original function -- 

```go
func (c Customer) Validate() error {
    var m *MultiError
    if //...
}
```

`m`is initialized to the zero value of a *pointer `nil`*-- Then if all the checks are valid, the argument provided to the `return`isn’t `nil`directly but a *nil pointer*. So should just: *a `nil`pointer is just a valid receiver*.

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age < 0 {..}
    if c.Name == "" {..}
    if m!=nil {
        return m
    }
    return nil
}
```

### Buffered Channel

```go
func receiver(message chan int, wGroup *sync.WaitGroup) {
    msg := 0
    for msg != -1 {
        time.Sleep(time.Second)
        msg = <-messages
        fmt.Println("Received", msg)
    }
    wGroup.Done()
}
```

Then can write a `main`that creates a *buffered* channel -- like:

```go
func main() {
	msgChannel := make(chan int, 3)
	wGroup := sync.WaitGroup{}
	wGroup.Add(1)
	go receiver(msgChannel, &wGroup)
	for i := 1; i <= 6; i++ {
		size := len(msgChannel) // reads the number of messages on the buffered
		fmt.Printf("sending: %d, size: %d\n", i, size)
		msgChannel <- i
	}
	msgChannel <- -1
	wGroup.Wait()
}
```

Get a fast sender that is trying to send 6 messages.

#### Assigning a direction to a channels

Go’s channels are *bidirectional* by default, this means that goroutine can act as both a receiver and a sender of messages -- can assign a direction to a channel so that the goroutien using the channel can only send or receive messages -- Fore:

```go
func main() {
	msgChannel := make(chan int)
	go receiver(msgChannel)
	go sender(msgChannel)
	time.Sleep(5 * time.Second)
}

func receiver(messages <-chan int) {
	for {
		msg := <-messages
		fmt.Println(time.Now().Format("15:04:05"), "received:", msg)
	}
}

func sender(messages chan<- int) {
	for i := 1; ; i++ {
		fmt.Println(time.Now().Format("15:04:05"), "sending", i)
		messages <- i
		time.Sleep(time.Second)
	}
}
```

#### Closing Channels

For a *sentinel* value is predefined value that signals to an execution, a process, or an algorithm that it should terminate. Go allows us to close a channel -- can do this by calling the `close(channel)`function -- once close a channel, we shouldn’t send any more message to it cuz doing so raises errors.

```go
func receiver(messages <-chan int) {
    for {
        msg := <-messages
        fmt.Println(...)
        time.Sleep(time.Second)
    }
}

func main() {
    msgChannel := make(chan int)
    go receiver(msgChannel)
    for i:=1; i<=3; i++ {
        fmt.Println(...)
        msgChannel <- i
        time.Sleep(time.Second)
    }
    close(msgChannel)
}
```

Go gives us a couple of ways to handle closed channels -- whenever we consume from a channel, an additional flag is returned, telling us the status of the channel. This flag is set to `false`only when the channel has been closed. Like:

```go
func receiver(messages <-chan int) {
	for {
		msg, more := <-messages
		fmt.Println(time.Now().Format("15:04:05"), "received:", msg, more)
		time.Sleep(time.Second)
		if !more {
			return
		}
	}
}

func main() {
	msgChannel := make(chan int)
	go receiver(msgChannel)
	for i := 1; i <= 3; i++ {
		fmt.Println(time.Now().Format("15:04:05"), "Sending", i)
		msgChannel <- i
		time.Sleep(time.Second)
	}
	close(msgChannel)
	time.Sleep(3 * time.Second)
}
```

In this way, can keep on iterating until the sender eventually closes the channel. Like:

```go
func receiver(messages <-chan int) {
	for msg := range messages {
		fmt.Println(time.Now().Format("15:04:05"), "Received", msg)
		time.Sleep(time.Second)
	}
	fmt.Println("receiver finisthed")
}
```

#### Receiving function results with Channels

Can execute functions concurrently in the background and then collect their results via channels once they finish. Typically, in normal sequential programming, call a func and expect it to return a result. Fore:

```go
func findFactors(number int) []int {
	result := make([]int, 0)
	for i := 1; i <= number; i++ {
		if number%i == 0 {
			result = append(result, i)
		}
	}
	return result
}

func main() {
	resultCh := make(chan []int)
	go func() {
		resultCh <- findFactors(34191107021)
	}()
	fmt.Println(findFactors(4033836233))
	fmt.Println(<-resultCh)
}
```

For this, use anonymous goroutine to collect the results of the `findFactor()`function.