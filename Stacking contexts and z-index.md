# Stacking contexts and z-index

It’s important to know the ramifications involved -- Fore, when remove an element from the document flow, become responsible for all the things the document flow normally does for you. When position multiple elements on the same page, may run into a scenario where two different positioned elements overlap.

##### Rendering process and stacking order

As the browser parses HTML into the DOM -- also creates another tree structure called *render tree* -- Which is *also* responsible for determining the order in which the browser will *paint* the elements. Fore, need a way to control their stacking behavior, done with `z-index`property -- 

##### Manipulating stacking order with `z-index`

Can be any integer -- even *negative*. Apply a `z-index`of 1 to the `modal-backdrop`and `z-index`of 2 the `modal-body`. LIke: Like:

```css
.modal-backdrop {
    position: fixed;
    inset: 0;
    background-color: rgb(0, 0, 0, 0.5);
    z-index: 1;
}
.modal-body {
    // ...
    z-index: 2;
}
```

- `z-index`only works on positioned elements -- `relative, absolute, fixed, stricky`.
- Can override the `auto`.

##### Stacking contexts

One element is the root of the stacking context. When add a z-index to a positioned element, becomes the root of a new stacking context. No elements of the stacking consext can be stacked between any two elements that are inside it.

```html
<div class="box one positioned">
    one
    <div class="absolute">
        nested
    </div>
</div>
<div class="box two positioned">
    two
</div>
//...
```

```css
.positioned {
    position: relative;
    z-index:1;
}
.abosolute {
    position: absolute;
    //...
    z-index:100; /* in context, so after box two */
}
```

#### Sticky positioning

It’s sort of a hybird between relative and fixed positioning. The element scrolls normally with the page until it reaches a *specified point* on the screen.

```html
<main class="container">
    <div class="col-main">
        <nav>
            <div class="dropdown">
                <div class="dropdown-label">Main Menu</div>
                <div class="dropdown-menu">
                    <ul class="submenu">
                        // ...
                    </ul>
                </div>
            </div>
        </nav>
        <h1>Wombat Coffee Roasters</h1>
    </div>
    <aside class="col-sidebar">
        <div class="affix">
            <ul class="submenu">
                <li><a href="/">Home</a></li>
                <li><a href="/coffees">Coffees</a></li>
                <li><a href="/brewers">Brewers</a></li>
                <li><a href="/specials">Specials</a></li>
                <li><a href="/about">About us</a></li>
            </ul>
        </div>
    </aside>
</main>
```

Then update the css like:

```css
.container {
    display: flex;
    width: 80%;
    max-width: 1000px;
    margin: 1em auto;
    min-height: 100vh;
}

.col-main{
    flex: 1 80%;
}

.col-sidebar{
    flex:20%;
}
.affix {
    position: sticky;
    top: 1em;
}
```

For this, a sticky element will always remiain within the bounds of its parent element.

Bootstrap also offers a powerful set of positioning utilities that make it easy to control layout and element placement without writing custom CSS.  Classes like:

- `position-static`
- `position-relative`
- `position-absolute`
- `position-fixed`
- `position-sticky`

Can combine position classes with edge utilities. `top-0`.. for top edge of the element.

## The `rune`concept

Should understand the distinction between a charset and an encoding -- 

- Charset - set of characters -- fore, the Unocide charset contains 2^21 characters
- An encoding is the translation of a character’s list in binary.

```go
type rune = int32
```

### Accurate string iteration

Iterating a string -- like:

```go
s := "hêllo" 
for i:= range s {
    fmt.Printf("position: %d: %c\n", i, s[i])
}
fmt.Printf("len=%d\n", len(s)) // 0, 1, 3, 4, 5 showed. And len = 6
```

Printing `s[i]`doesn’t print the `ith rune`-- just prints the UTF-8 representation of the byte at index `i`. Have to use the value element for the `range`operator like:

```go
s := "hêllo" 
for i, r := range s {
    fmt.Printf("position: %d:%c\n", i, r)
}
```

And, if want to access the `ith`rune of a string -- 

```go
s := "hêllo" 
r := []rune(s)[4] // o
```

### Using `trim`functions

Mix `TrimRight`and `TrimSuffix`functions, both serves a similar purpose -- If

```go
fmt.Println(strings.TrimRight("123oxo", "xo")) // 123
```

For `TrimRight`, removes all the trailing runes contained in a given set. 

```go
fmt.Println(strings.TrimSuffix("123oxo", "xo")) // 123o
```

For this, `TrimSuffix()`just ends with `xo`-- prints `123o`l

### Optimized string Concatenation

```go
func concat(values []string) string {
    s := ""
    for _, value := range values {
        s += value
    }
    return s
}
```

Using the `strings`package and the `Builder`struct just like:

```go
func concat(values []string) string {
    // created a strings.Builder using its zero value
    sb := strings.Builder{}
    for _, value := range values {
        // return (n, err)
        _, _ = sb.WriteString(value) // appends a string
    }
    return sb.String()
}
```

Using `strings.Builder`, can also append -- 

- A byte slice using `Write`
- A single byte using `WriteByte`
- A single Rune using `WriteRune`

Internally, `strings.Builder`holds a byte slice. Note that -- if the future length of a slice is already known, should preallocate it -- `strings.Builder`exposes a method `Grow(n int)`to guarantee space for another `n`bytes.

```go
func concat (values []string) string {
    total := 0
    for i:=0; i<len(values); i++ {
        total += len(values[i])
    }
    sb := strings.Builder{}
    sb.Grow(total)
    for _, value := range values {
        _, _ = sb.WriteString(value)
    }
    return sb.String()
}
```

### String Conversions

When choosing to work with a string or a `[]byte`-- But most I/O is actually done with `[]byte`-- `io.Reader`...and `io.ReadAll`work with `[]byte`. Fore, an example of what we shouldn’t do -- will implement a `getBytes`-- 

```go
func getBytes(reader io.Reader) ([]byte, error) {
    b, err := io.ReadAll(reader)
    if err != nil {
        return nil, err
    }
    // call sanitize
}

func sanitize (s string) string {
    return strings.TrimSpace(s)
}
```

Must first convert it to a string before can call `santize`. If:

```go
return []byte(sanitize(string(b))), nil
```

For this, have to pay the extra price of converting a `[]byte`into a `string`and then converting a string into a `[]byte`. Memory-wise, each of these conversions requires an extra allocation. So, should manipulate a byte slice like:

```go
func sanitize(b []byte) []byte {
    return bytes.TrimSpace(b)
}
```

So the `bytes`package also has a `TrimSpace`function to trim all the leading and trailing white spaces.

```go
return santize(b), nil
```

### Substrings and memory leaks

```go
s1 := "Hello, World!"
s2 := s1[:5]
```

`s2`constructed as a substring of `s1`-- note that creates a string from the first five *bytes*, not *runes*. So, should convert the input string into a `[]rune`first -- 

```go
s1 := "Hello, World"
s2 := string([]rune(s1)[:5])
```

Fore, receive a log message as strings -- 

```go 
func(s store) handleLog(log string) error {
    if len(log) < 36 {
        return errors.New("log is not correctly formatted")
    }
    uuid := log[:36]
    s.store(uuid)
    //...
}
```

When doing substring, the std Go compiler does let them *share the same backing array*, so prevents a new allocation and a copy. So the `.log[:36]`will create a new string referecing the *same* backing array -- each `uuid`string store in memory will contain not just 36 bytes but the number of bytes in the initial `log`string.

Making a deep copy of the substring so that the internal byte slice of `uuid`references a new backing array like:

```go
func(s store) handleLog(log string) error {
    if len(log) < 36 {
        return errors.New("log is not correctly formatted")
    }
    uuid := string([]byte(log[:36]))
    s.store(uuid)
}
```

Note that the copy is just performed by converting the substring into a `[]byte`first and then into a `string`again. By doing so, prevent a memory leak from occurring.

Note taht after Go 1.18, the stdlib also includes a solution with `strings.Clone()`that returns a *fresh copy* of a string

```go
uuid := strings.Clone(log[:36])
```

## Passing messages

```go
func main() {
    msgChannel := make(chan string)
    go receiver(msgChannel)
    fmt.Println("Sending Hello...")
    msgChannel <- "HELLO"
    //...
}

func receiver(message chan string) {
    msg := ""
    for msg != "STOP" {
        msg = <-messages
        fmt.Println("received:", msg)
    }
}
```

If change the receiver like:

```go
func receiver(message chan string) {
    time.Sleep(5*time.Second)
    fmt.Println("Receiver slept for 5s")
}
```

If therei s nothing to consume the message that the `main`is trying to place on the channel, then deadlock. The same situation occurs if have a receiver waiting for a message and no sender is available. Fore:

```go
func main() {
	msgChannel := make(chan string)
	go sender(msgChannel)
	fmt.Println("Reading from channel...")
	msg := <-msgChannel //  blocking
	fmt.Println("Received:", msg)
}

func sender(messages chan string) {
	time.Sleep(5 * time.Second)
	fmt.Println("Sender slept for 5s")
}
```

The key idea is that by default, Go’s Channels are *sync* -- a sender will block if there isn’t goroutine consuming its message -- and a sender will block if there isn’t a goroutine consuming its message, and a receiver will similarly block if there isn’t a goroutine sending a message.

##### Buffering messages with channels

Can specify its buffer capacity -- then whenever a sender writes a message without any receiver consuming the message, the channel will store the message. The channel will keep on storing messages as long as capacity remains in the buffer. Once a receiver is available to consume the messages, the messages are fed to the reciver in the same order they were sent. Once the receiver goroutine consumes all the messages and the buffer is empty, the receiver goroutine will again block.