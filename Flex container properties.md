# Flex container properties

Several properties can be applied to a flex container to control the layout of its flex items. Fore, `flex-direction`. `flex-wrap`can be used to allow flex items to wrap to a new row. This can be set to `nowrap, wrap, wrap-reverse`. When wrapping is *enabled*, the items *don’t* shrink according to their `flex-shrink`.

##### `justify-content`

Controls how the items are spaced along the main axis. `align-content`-- controls the speacing of each row inside the flex container along the *cross-axis*. And `align-items`adjust their alignment along the cross axis. `stretch`, causes all items to fill the container’s height in a row layout or width in a column layout.

#### Understanding flex item properties

Two additional properties for flex items -- `align-self`and `order`. `align-self`controls *a flex item*‘s aligment along its container’s *cross axis*. Does the same thing as the flex container `align-items`, except align just the individual flex items differently, `auto`will defer to the container’s `align-items`value.

`order`can change the order in which the items are stacked.

#### Using aligment properties

Show how to use a few of these properties -- like:

```html
div class="tile centered stack">
<small>Starting at</small>
<div class="cost">
    <span class="const-currency">$</span>
    <span class="cost-dollars">20</span>
    <span class="const-cents">.00</span>
</div>
<a class="cta-button" href="/pricing">
    Sign up
</a>
</div>
```

For the text is wrapped in a `<div class="cost">`which you will use the flex container -- 3 flex items for the 3 different parts of the text you want to align -- like:

```css
.cost {
    display: flex;
    justify-content: center;
    align-items: center;
    line-height: .7;
}

.cost-currency {
    font-size:2rem;
}

.cost-dollars {
    font-size: 4rem;
}

.cost-cents{
    font-size: 1.5rem;
    align-self: flex-start;
}

.cta-button {
    display: block;
    background-color: #cc6b5a;
    color: white;
    padding: .5em 1em;
    text-decoration: none;
}
```

### Building a basic grid

Grid is versatile -- like:

```html
<body>
    <div class="grid">
        <div class="a">a</div>
        <div class="b">b</div>
        <div class="c">c</div>
        <div class="d">d</div>
        <div class="e">e</div>
        <div class="f">f</div>
    </div>
</body>
```

As with a flexbox, 

```css
.grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    gap: .5em;
}

.grid>* {
    background-color: darkgray;
    color: white;
    padding: 2em;
    border-radius: .5em;
}
```

`display: grid`to define a grid container, behave like a block display element, filling 100% of the available width. Can also use the `inline-grid`-- new properties, `grid-template-columns`and `grid-template-rows`-- these define the size of each of the columns and rows in the grid. New unit -- `fr`means *fraction unit*, fore `1fr 1fr`declares 2 rows of equal size. Note that don’t necessary have to use fraction units for each column or row, can also use other measures such as px, em, or percent, or you could mix and match. fore:
`grid-template-columns: 300px 1fr` And the `gap`property defines the amount of space ot add to the gutter between each grid cell.

#### Anatomy of a grid

Important to understand that the various parts of a grid -- grid containers and grid items -- which are the elements that make up the grid -- 

- *Grid line* -- make up the structure of the grid, `gap`lies atop the grid lines
- *grid track* -- is the space between two adjacent grid lines.
- *grid cell* -- single space on the grid, where a horizontal track and vertical track overlap.
- *grid area* -- is a rectangle area on the grid made up of one or more grid cells.

Use the page using grid just like: 

```html
<!doctype html>
<html lang="en-US">
  <head>
    <style>
      /* styles to be added in subsequent listings */
    </style>
  </head>
  <body>
    <div class="container">
      <header>
        <h1 class="page-heading">Ink</h1>
      </header>
      <nav>
        <ul class="site-nav">
          <li><a href="/">Home</a></li>
          <li><a href="/features">Features</a></li>
          <li><a href="/pricing">Pricing</a></li>
          <li><a href="/support">Support</a></li>
          <li class="nav-right">
            <a href="/about">About</a>
          </li>
        </ul>
      </nav>
      <main class="main tile">
        <h1>Team collaboration done right</h1>
        <p>
          Thousands of teams from all over the world turn to <b>Ink</b> to
          communicate and get things done.
        </p>
      </main>
      <div class="sidebar-top tile">
        <form class="login-form">
          <h3>Login</h3>
          <p>
            <label for="username">Username</label>
            <input id="username" type="text" name="username" />
          </p>
          <p>
            <label for="password">Password</label>
            <input id="password" type="password" name="password" />
          </p>
          <button type="submit">Login</button>
        </form>
      </div>
      <div class="sidebar-bottom tile centered stack">
        <small>Starting at</small>
        <div class="cost">
          <span class="cost-currency">$</span>
          <span class="cost-dollars">20</span>
          <span class="cost-cents">.00</span>
        </div>
        <a class="cta-button" href="/pricing"> Sign up </a>
      </div>
    </div>
  </body>
</html>
```

This version of the page has placed each section of the page as a grid item -- Apply a gid layout to the page and put each secion in place -- 

```css
*,
::before,
::after {
    box-sizing: border-box;
}

:root {
    --gap-size: 1.5rem;
}

body {
    background-color: #7090b0;
    font-family: 'Courier New', Courier, monospace;
}

.stack>*+* {
    margin-block-start: 1.5em;
}

.container {
    display: grid;
    grid-template-columns: 2fr 1fr;
    /* defines 4 horizontal lines of size auto*/
    grid-template-rows: repeat(4, auto);
    gap: var(--gap-size);
    max-inline-size: 1080px;
    margin-inline: auto;
}

header,
nav {
    grid-column: 1/3;
    grid-row: span 1;
    /* span exactly one row*/
}

.main {
    grid-column: 1/2;
    grid-row: 3/5;
}

.sidebar-top {
    grid-column: 2/3;
    grid-row: 3/4;
}

.sidebar-bottom {
    grid-column: 2/3;
    grid-row: 4/5;
}

.tile {
    padding: 1.5em;
    background-color: #fff;
}

.tile> :fist-child {
    margin-top: 0;
}
```

## The rece detector

go’s built-in data race detector would have caught this problem for us -- like:

```sh
go run -race main.go
```

When it comes to implementing `Intersection`-- the old code will also be concurrency-safe without modification, cuz it also uses the lock-aware methods -- just like:

```go
func (s SetC[E]) Interactions(s2 SetC[E]) *SetC[E] {
	result := NewSetC[E]()
	s2.mux.RLock()
	defer s2.mux.RUnlock()
	for _, v := range s.All() {
		_, ok := s.data[v]
		if ok {
			result.Add(v)
		}
	}
	return result
}
```

#### Channelling frustration -- 

Can put together everything you have learned -- 

1. Define the `Channel` type,
2. Define a `New`ctor that returns an initialised `Channel`with a specified capacity
3. Define `Send`and `Receive`methods on the `Channel`to allow users to send and receive values of appropraite type
4. Define `Sends`and `Receives`that will report *number* of ends and receives on the channel.

```go
package channel

import "sync"

type Channel[T any] struct {
	lock            *sync.RWMutex
	ch              chan T
	sends, receives int
}

func New[T any](length int) *Channel[T] {
	return &Channel[T]{
		lock: new(sync.RWMutex),
		ch:   make(chan T, length),
	}
}

func (c *Channel[T]) Send(v T) {
	c.ch <- v
	c.lock.Lock()
	defer c.lock.Unlock()
	c.sends++
}

func (c *Channel[T]) Receive() T {
	v := <-c.ch
	c.lock.Lock()
	defer c.lock.Unlock()
	c.receives++
	return v
}

func (c *Channel[T]) Sends() int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.sends
}

func (c *Channel[T]) Receives() int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.receives
}
```

While a mutex is helpful for prevening concurrent access to mutable data in general, there is a shortcut for some specific, commonly-used types. Also can use the `atomic.Uint64`..

```go
type Channel[T any] struct {
    ch              chan T
    sends, receives atomic.Unit64
}

func New[T any](length int) *Channel[T] {
    return &Channel[T] {
        ch: make(chan T, length)
    }
}

func (c *Channel[T]) Send(v T) {
    c.ch <- v
    s.cends.Add(1)
}
```

Then test the concurrency operations like:

```go
func TestChannelHandlesConcurrentSendsAndReceives(t *testing.T) {
	t.Parallel()
	c := channel.New[string](10)
	want := uint64(100)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		for i := uint64(0); i < want; i++ {
			c.Send("Hello")
			_ = c.Receives()
		}
		wg.Done()
	}()
	for i := uint64(0); i < want; i++ {
		_ = c.Receive()
		_ = c.Sends()
	}
	wg.Wait()
	got := uint64(c.Sends())
	if want != got {
		t.Errorf("got %d, want %d", got, want)
	}
	got = uint64(c.Receives())
	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
```

### Packages

The `cmp`package -- the first, smallest, new package is `cmp`-- which met in an earlier chapter -- it defines a useful contraint, `Ordered`-- which includes all built-in types that can be compared for relative magnitude using the `>`operator and friends -- Another meat thing in `cmp`is the `Or`function -- which lets us give a list of values -- and it will pick the first of them that is non-zero -- fore:

```go
x := cmp.Or(userX, "default X value")
```

For this, if `userX`is just an empty string, then `x`will be assigned the default we provided.

##### `slices`package

Slice types in Go don’t support `==`so, `slices.Equal`now provides a std way of checking whether two slices are equal:

```go
s1 := []int {1,2,3}
s2 := []int {1,2,3}
println(slices.Equal(s1, s2))
```

So this is convenient when the element type happens to be comparalbe, but, what if its’ not -- Or what if we want to just compare elements in some special way -- like:

```go
func main() {
	s1 := []string{"a", "b", "c"}
	s2 := []string{"A", "B", "C"}
	fmt.Println(slices.EqualFunc(s1, s2, strings.EqualFold))
}
```

For this, an interesting property of `EqualFunc`is that it’s defined on *two* slice types, not one. So can use it to compare two different kinds of slices.

```go 
func main() {
	s1 := []int{0, 1, 2}
	s2 := []rune{'a', 'b', 'c'}
	equal := func(n int, r rune) bool {
		return n == int(r-'a')
	}
	fmt.Println(slices.EqualFunc(s1, s2, equal))
}
```

Sometimes, it’s not enough just to know whether two slices are equal, might want to ask whether one is greater or lesser then the other. Fore:

```go
func main() {
	smaller := []int{1, 2, 3}
	bigger := []int{1, 2, 3, 4}
	fmt.Println(slices.Compare(bigger, bigger))  //0
	fmt.Println(slices.Compare(smaller, bigger)) // -1
	fmt.Println(slices.Compare(bigger, smaller)) // 1
}
```

As can see, s shorter slice is consider lesser by `Compare`. And if:

```go
[1,2,3] < [2,3,4]
```

And Can compare two slices of integers in a special way that ignore their *sign*. Fore:

```go
func cmp(x, y int) int {
	absX := math.Abs(float64(x))
	absY := math.Abs(float64(y))
	if absX < absY {
		return -1
	} else if absX > absY {
		return 1
	}
	return 0
}
func main() {
	s1 := []int{-1, 2, -3}
	s2 := []int{1, -2, 3}
	fmt.Println(slices.CompareFunc(s1, s2, cmp))  // 0
}
```

#### Finding elements

Another common operation on slices if *finding* a specified element by index, or simply asking whether it’s contained in a slice at all -- `slices.Index`will return index of the first occurrence of a given element, or -1 if it’s not found at all

```go
func main() {
	s := []int{1, 2, 3}
	fmt.Println(slices.Index(s, 2))    // 1
	fmt.Println(slices.Index(s, 9))    // -1
	fmt.Println(slices.Contains(s, 1)) // true

	negative := func(n int) bool {
		return n < 0
	}
	s2 := []int{1, -2, 3}
	if slices.ContainsFunc(s2, negative) {
		fmt.Println("contains negative")
	}
}
```

Also, maximum and minima -- like:

```go
s := []int{1, 3, 2}
println(slices.Max(s))
```

It’s also perfectly natural to want to insert or delete elements of a slice, and accordingly the `slices`package provides `Insert`and `Delete`functions.

Conversely, `Delete`deletes elements from the first ..

```go
s := []string {"a", "c"}
s = slices.Insert(s, 1, "b")

s := []string {"a", "b", "c"}
s = slices.Delete(s, 0, 2)  // c
```

##### Cloning and compacting -- 

To create a *shallow* copy of a slice, can use `slices.Clone`. like:

```go
s := []int {1,2,3}
fmt.Println(slices.Clone(s))
```

For the `slices.Compact`-- it will delete *duplicate* elements from the slice -- like Unix `uniq`command. can use the `slices.Compact`function like:

```go
s := []int {1,1,1,2,3}
fmt.Println(slices.Compact(s))  // [1,2,3]
```

Note that the `Compact`only removes *successive* duplicate elements - if the duplicate elements aren’t next each other, won’t be removed. Again, if want to override the default == comparison for identical elements, supply our own function to `CompactFucn`like:

```go
s := []string {"a", "A"}
fmt.Println(slices.CompactFunc(s, strings.EqualFold)) // [a]
```

#### Growing and shrinking -- 

Slice has length and capacity -- A slice will *automatically* grow its capacity as needed when you add elements to it, which is convenient, but this process involves copying the slice and allocating a new chunk of memory every time it happens, which can result in a lot of unncecessary work. For efficiency, sometimes want to just increase the capacity of a slice by a large amount in one shot. Can use `slice.Grow`to do like:

```go
s := []int{1, 2}
fmt.Println(cap(s)) // 2

s := slice.Grow(s, 10)
fmt.Println(cap(s)) // 12, so grow + 10
```

Conversely, if a slice is not a lot smaller than it used to be, and we’d like reclaim that unused memory, can use the `slices.Clip()`to reduce its capacity -- like:

```go
s := make([]int, 100)
fmt.Println(cap(s))
s = slices.Delete(s, 0, 100)
s = slices.Clip(s)
fmt.Println(cap(s)) // 0
```

##### Sorting 

Saw in the chapter on functions, the introduction of generics means we are no longer requires to use the `sort`package to sort slices -- instead, we get a new familar of sorting functions in the `slices`package -- 

```go
s := []int{3, 1, 2}
slices.Sort(s)
fmt.Println(s)

s := []int{1,2,1,3,1}
slices.Sort(s)
println(slices.Compact(s))
```

Maybe the elements are not one of the ordered types, though, or maybe we just want to customise the sorting for some other reason -- in the case, can pass a comparison function to `SortFunc`-- 

```go
s := []int{3, 1, 2}
slices.SortFunc(s, cmp.Compare)
fmt.Println(s)
```

To detect if a slice is *already* sorted, using:

```go
s := []int{1,2,3}
fmt.Println(slices.IsSorted(s)) // true
```

##### Reversing and replacing 

A common sort of technical interview question is to ask the candidate to write code to *reverse* element in a slice. 

```go
s := []int {1,2,3}
slices.Reverse(s)
println(s)

s := []string{"aardvark", "bear", "cat"}
s = slices.Replce(s, 1, 2, "bat", "bee", "bison")
fmt.Println(s) [aardvark bat, bison, cat]
```

#### Searching

One benefit of having a sorted slice is that we can look for elements using a *binary search* -- this is a common-sense way of looking for things that we all use with sorted data. Fore, imagine you are looking for a certain word in a dictionary. If U open the dictionary roughly in the middle, at some random word.

Given a sorted slice, then, can use `slices.BinarySearch`to quickly find the index of a certain element. It returns two values: the index of the element, if found, and a `bool`indicating whether it was found like:

```go
s := []int{1,2,3}
fmt.Println(slices.BinarySearch(s, 2))
```

Alternatively, can use `BinarySearchFunc`to find the index of the first for which some given function returns true -- 

```go
s := []int{1,2,3}
fmt.Println(slices.BinarySearch(s, 999)) // 3 false
s := []string{"a", "c"}
fmt.Println(slices.BinarySearch(s, "b"))
// 1 false output
```

### Side effects using slice `append`

This discusses a common mistake when using `append`, which may have undexpected side effects in some situation. In the following example, initialize an `s1`slice, create `s2`and `s3`by appending an element to `s2`-- like:

```go
s1 := []int{1,2,3}
s2 := s1[1:2]
s3 := append(s2, 10)
```

We initialize an `s1`and `s2`is created from slicing `s1`, then call `append`on `s3`. For `s2`is a 1L and 2C slice -- both backed by the *same* array we already mentioned -- for this, appending an element using `append`checks whether the slice is full -- `length==capacity`. If it is not full the `append`adds the element by updating the backing array and returning a slice having length incremented by 1.

in the backing array, updated the last element to store 10, therefore, if print all the slices, get this output like:

```go
s1 = [1 2 10] s2 = [2] s3= [2 10]
```

So , `s1`content was modified, even though we did not update `s1[2]`or `s2[1]`directly.

If want to protect the 3rd element for defensive reasons, meaning to ensure that `f`doesn’t update it -- have two options -- like:

```go
func main() {
    s := []int {1,2,3}
    sCopy := make([]int, 2)
    copy(sCopy, s)
    
    f(sCopy)
    result := append(sCopy, s[2])
}
```

The second option can be used to limit the range of potential side effects to the first two elements only, this option involves so-called *full slice expression* -- `s[low:high:max]`

```go
func main() {
    s := []int{1,2,3}
    f (s[:2:2]) // max-low = 2-0 = 2
}
```

Passing `s[:2:2]`can lmit the range of effects to the first two lements, doing so also prevents us from having to perform a slcie copy.

### Slices and memory leaks -- 

For the first, *leaking capacity* - imagine implementing a custom binary protocol -- fore:

```go
func consumeMessages() {
    for {
        msg := receiveMessage()
        // do sth with msg
        storeMessageType(getMeassageType(msg))
    }
}

func getMessageType(msg []byte) []byte {
    return msg[:5]
}
```

For this the `getMessageType`function computes the message type by slicing the input `slice`, test this imp, and everything is fine -- when deploy our app, we notice that our app consumes about 1GB of memory. FORE.

The slicing operaiton on `msg`using `msg[:5]`creates a 5-length slice, however, its capacity *remains the same as the initial slice*. the remaining elements are still allocated in memroy, even if eventually `msg`is not referenced. Can do to solve - like:

```go
func getMessageType(msg []byte) []byte {
    msgType := make([]byte, 5)
    copy(msgType, msg)
    return msgType
}
```

Cuz we perform a copy, `msgType`is a 5L, 5C slice regardless of the size of the message received.

