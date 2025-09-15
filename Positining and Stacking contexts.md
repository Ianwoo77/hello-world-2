# Positining and Stacking contexts

Look at one important technique -- `position`property. Fore, build dropdown menus, modal dialogs. Note that the initial value of the `position`is `static`. And when change this else, the element is to be *positioned*.

#### Fixed

Applying `position: fixed`lets U position the element artibitrarily within the *viewport*. Done with 4 companion properties, `top, right bottom`and `left`, note this order. By setting these four, implicitly define the width and height of the element.

And the `inset`prop -- specify the location of the elements. `inset:0`, is equivalent to top:0... Also:

- `inset-block-start`
- `inset-block-end`...
- `inset-block`
- `inset-inline-start`
- `inset-inline-end`
- `inset-inline`

##### Creating a modal dialog -- 

Use a modal dialog to require the user to read sth or to input sth before continuing.

```html
<header class="top-banner">
	<div class="top-banner-inner">
        <p>
            Find out...
            <button id="open" type="button">
                Sign up
            </button>
        </p>
    </div>
</header>

<div class="modal" id="modal" role="dialog" aria-modal="true">
    <div class="modal-backdrop">
        <!-- empty -->
    </div>
    <div class="modal-body">
        <button class="modal-close" id="close" type="button">
            Close
        </button>
    </div>
</div>
```

Note that the Js script like

```js
const button = document.getElementById("open")
const close = document.getElementById("close")
const modal = document.getElementById("modal")
button.addEventListener('click', event=> modal.classList.add('is-open'));
close.addEventListener('click', _=> modal.classList.remove("is-open"))
```

Then add the css like:

```css
body {
    font-family: Helvetica,...
    min-height: 200vh;
    margin: 0;
}
button, input {
    font: inherit; /* overriding user-agenet fonts applied to form elements */
}
button {
    padding: 0.5em 0.7em;
}
.modal {
    display: none;
}
.modal .is-open {
    display: block;
}

.modal-backdrop {
    position: fixed;
    inset: 0;
    background-color: rgb(0 0 0 .5);
}

.modal-body {
    position: fixed;
    inset-block: 3em;
    inset-inline: 20%;
    padding: 2em 3em;
    background-color: white;
    overflow: auto;
}
```

##### Preventing the screen from scrolling while the modal dialog is open -- 

```js
button.addEventListener('click', event=> {
    modal.classList.add("is-open");
    document.body.classList.add('no-scroll');
})
close.addEventListener('click', event=> {
    modal.classList.remove('is-open');
    document.body.classList.remove('no-scroll');
})
```

```css
body.no-scroll {
    overflow: hidden;
}
```

##### Controlling the size of positioned elements

When positioning an element, you are not required to specify values for all four sides. Can specify only the sides you need and then use the `width/height`.

```css
.some {
    position: fixed;
    top: 1em;
    right: 1em;
    width: 20%;
}
```

These would affix the element.

#### Absolute positioning

```css
.modal-close {
    position: absolute;
    top: .3em;
    right: .3em;
    padding: .3em;
    border: 0;
    font-size: 2em;
    text-indent: 10em;
}
.modal-close::after {
    position: absolute;
    line-height: .5;
    top: .2em;
    left: .1em;
    text-indent: 0; /* this is inhertied, so need to change */
    content: "\00D7";
}
```

The pseudo-class is not absolutely positioned, it behaves like a child element of the button, so the button being positioned becomes the containing block for its pseudo-element.

#### Relative positioning

```html
<nav>
	<div class="dropdown" id="dropdown">
        <button type="button" class="dropdown-toggle"
                id="dropdown-toggle">
            Main menu
        </button>
        <div class="drop-menu">
            <ul class="submenu">
                <li><a href="/">Home</a></li>
                //...
            </ul>
        </div>
    </div>
</nav>
```

Need a bit of Js to open and close the menu when the toggle button is pressed -- like:

```js
const dropdownToggle = document.getElementById("dropdown-toggle");
const dropdown = document.getElementById("dropdown");
dropdownToggle.addEventListener("click", e=> {
    dropdown.ClassList.toggle("is-open");
})
```

```css
.dropdown {
    display: inline-block;
    position: relative;
}
.dropdown-toggle {
    padding: .5em 1.5em;
    border: 1px solid #ccc;
    background-color: #eee;
    border-radius: 0;
}
.dropdown-menu {
    display: none;  /* hide initially */
    position: absolute;
    left: 0;
    top: 2.1em;
    inline-size: max-content;
    min-inline-szie: 100%; /* ensures the element is at least wide as its parent container */
    background-color: #eee
}

.dropdown.is-open .drop-menu {
    display:block;
}

.submenu {
    padding-inline-start: 0;
    margin: 0;
    list-style-type: none;
    border: 1px solid #999;
}
.submenu > li+li {
    border-top: 1px solid #999;
}
.submenu > li > a {
    display: block;
    padding: .5em 1.5em;
}
.submenu > li > a: hover {
    background-color: #fff;
}
```

## Inefficient map initialization

Each operation is done by associating a key to an array index -- this step on a hash function -- this is stable cuz want it to return the same bucket. Note that in the case of insertion into a bucket that is already full, Go creates another bucket of 8 elements and links the previous bucket to it.

#### Initialization -- 

```go
m := map[string]int {
    "1": 1,
    "2": 2,
    "3": 3,
}
```

Internally, this map is backed by *an array* consisting of a single entry: a single bucket -- so what happens if add a 1M elements -- When a map grows, it *doubles* its number of buckets -- So, what are the conditions for a map to grow -- 

- When the average number of items in the bucket (*load factor*) is greater than a constant value.
- Too many buckets have overflowed.

### Maps and memory leaks

Need to understand some important characteristics of how a map grows and shrinks -- If:

```go
m := make(map[int][128]byte)
```

```go
n := 1_000_000
m : = make(map[int][128]byte)
for i:=0; i<n; i++ {
    m[i]= randBytes()
}
for i:=0; i<n; i++ {
    delete(m, i)
}
runtime.GC()
runtime.KeepAlive(m)
```

So, should use like `map[int]*[128]byte`

### Comparing values correctly

```go
type customer struct {
    id string
}
func main() {
    cust1 := customer{id: "x"}
    cust2 := customer{id: "x"}
    cust1==cust2 // true
}
```

But, what happens if make a slight modification to the `customer`-- 

```go
type customer struct {
    id string
    operations []float64
}
```

Get *invalid operation* -- just cuz the operators like == and != don’t work with slices or maps.

Booleans, Numerics, Strings.

- *Channels* -- Compare whether two channels were created by the same call to `make`or if both are `nil`.
- *interfaces* -- Compare have *identical dynamic types* and equal dynamic values or both `nil`.
- *Pointers* -- if same value in memory or `nil`
- *structs* and *array* -- Compare they are composed of similar types.

If performance is crucial factor -- another option might to be implement our own comparison method -- like:

```go
func (a customer) equal (b customer) bool {
    if a.id != b.id {
        return false
    }
    if len(a.operations) != len(b.operations) {
        return false
    }
    for i:=0; i<len(a.operations); i++ {
        if a.operations[i] != b.operations[i] {
            return false
        }
    }
    return true
}
```

### Ignoring how the `break`statement works

For a `break`-- used to terminate execution of a loop -- when loops are used in conjunction with `switch`or `select`, developers frequently make the mistake of breaking the wrong statement.

```go
for i:=0; i<5; i++ {
    fmt.Printf("%d", i)
    switch i {
    default:
    case 2:
        break /*doesn't terminate the for , just the switch */
    }
}
```

So, one essential rule to keep in mind is that a `break`terminates the execution of the *innermost* `for, switch, select`statement.

```go
loop:
for i:=0; i<5; i++ {
    //...
    switch {
        //...
    case 2:
        break loop
    }
}
```

Here the innermost -- `for, switch`or `select`is the `select`like:

```go
loop:
for {
    select {
    case <-ch:
        //...
    case <-ctx.Done():
        break loop // terminates the loop attahced to the loop label, not select
    }
}
```

### Using `defer`inside a loop

The `defer`delays a call’s execution until the *surrounding* function returns -- mainly used to reduce boilerplate code. Fore, will implement a function that opens a set of files where the file paths are received via a channel -- 

```go
func readFile(ch <-ch string) error {
    for path := range ch {
        file, err := os.Open(path)
        if err != nil {
            return err
        }
        defer file.Close()
    } 
    return nil
}
```

Have to recall that `defer`schedules a function call when the *surrounding* function returns. In the case, the `defer`calls are executed not during each loop iteration but when the `readFile()`returns. So, if `readFile`doesn’t return at all the file descriptions will be kept open forever.

So what are the options to fix this  -- one might to be get rid of `defer`and handle the file closure manually -- 

```go
func readFile(ch <-chan string) error {
    for path := range ch {
        if err := reandFile(path); err!=nil {
            return err
        }
    }
    return nil
}
func readFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()
    return nil
}
```

In this, the `defer`func is called when `readFile`returns, meaning at the end of each iteration. Therefore, do not keep file descriptors open until the parent `readFiles()`returns. And another approch could be to make the `readFile`a closure like:

```go
func readFiles(ch <-chan string) error {
    for path:= range ch {
        err := func() error {
            //...
            defer file.Close()
            //...
            return nil
        }()
        if err != nil {
            return err
        }
    }
    return nil
}
```

## `Waitgroups`in Go

- `Done()`-- Decrements the waitgroup size counter by 1
- `Wait()`-- Blocks until the waitgourp size counter is 0
- `Add(delta int)`-- increments the waitgroup size counter by delta

```go
func main() {
    wg := sync.WaitGroup{}
    wg.Add(4)
    for i:=1; i<=4; i++ {
        go doWork(i, &wg)
    }
    wg.Wait()
    fmt.Println("All completed")
}
func doWork(id int, wg *sync.WaitGroup) {
    i := rand.Intn(5)
    time.Sleep(time.Duration(i)*time.Second)
    fmt.Println(id, "Done Working after" i, "seconds")
    wg.Done()
}
```

For the `CounterLetters()`function just like:

```go
func main() {
    wg := sync.WaitGroup{}
    wg.Add(31)
    mutex := sync.Mutex{}
    var frequency = make([]int, 26)
    for i:=1000; i<=1030; i++ {
        url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
        go func() {
            CounterLetters(url, frequency, &mutex)
            wg.Done()
        }()
    }
    wg.Wait()
    //...print
}
```

### Barriers

Waitgroups are great for synchronizing after a task has been completed, If need to coordinate our goroutines before start a tak -- might also need to align different executions at different points in time -- Fore, all working together on different parts of the same computation.

- Suspends execution at barrier until all goroutines are at the barrier
- Goroutine at barrier calls `Wait()`and is suspedned until all goroutines call `Wait()`

##### Implementing a barrier in Go

Need to know the size of the group of executions that will be using this barrier. When the `wait`counter reaches the size of the barrier -- need to reset the counter to 0 and *broadcast* on the condition variable to wake up any suspedned goroutines. Implement the struct type and `NewBarrier(size)`ctor function for the barrier. For the Go strut, contains the size of the barrier, wait counter, and a reference to the condition variable.

```go
type Barrier struct {
	size      int
	waitCount int
	cond      *sync.Cond
}

func NewBarrier(size int) *Barrier {
	condVar := sync.NewCond(&sync.Mutex{})
	return &Barrier{size, 0, condVar}
}
```

The execute the `Wait()`method like:

```go
func (b *Barrier) Wait() {
	b.cond.L.Lock()
	b.waitCount += 1

	if b.waitCount == b.size {
		b.waitCount = 0
		b.cond.Broadcast()
	} else {
		b.cond.Wait()
	}
	b.cond.L.Unlock()
}
```

When the counter reaches the barrier’s size -- simply reset the counter to 0 and broadcast on the condition variable. Then test the barrier by having two goroutines simulate executing for different periods of time.

```go
func workAndWait(name string, timeToWork int, barrier *barrier.Barrier) {
	start := time.Now()
	for {
		fmt.Println(time.Since(start), name, "is running")
		time.Sleep(time.Duration(timeToWork) * time.Second)
		fmt.Println(time.Since(start), name, "is waiting on barrier")
		barrier.Wait()
	}
}
```

Can now start two goroutines that use the `WorkAndWait()`function, each with a different `timeToWork`.

```go
func main() {
	barr := barrier.NewBarrier(2)
	go workAndWait("Red", 4, barr)
	go workAndWait("Blue", 10, barr)
	time.Sleep(10 * time.Second)
}
```

After which the `main()`terminates.

#### Message passing -- 

Go takes inspiration from a concurrency model called CSP -- which is a formal language for describing interactions of concurrent programs. In this model, processes connect to each other by communicating via sync message passing.

##### Passing with channels

A Go `channel`lets two or more goroutines exchange messages. Conceptually, can think of a channel as being a direct line between our goroutines. First create one by using the `make()`built-in function, can then pass it onward as an argument whenever we create goroutines.