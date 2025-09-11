# Flex basis -- 

An *initial main size* -- Can be set to any value that would apply to `width`, initial is `auto`. `flex-grow`values are always specified as nonnegative integers. 0 means that won’t grow larger than its `flex-basis`. And non-zero value means it will grow until all of the remaining space is *used up*.

And declaring a higher flex grow value gives that more *weight* -- take a larger portion of the remainder. And the `flex-shrink`property follows similar principles as `flex-grow`-- Whether it should shrink to prevent overflow. Fore:

```css
.column-main {
    flex: 66.67%;
}
.column-sidebar {
    flex: 33.33%;
}
```

#### Flex direction

Its initial value causes the items to flow in the inline direction -- and the `flex-direction: column`used. And the `row-reverse`and `column-reverse`to flow bottom to up.

```css
.column-sidebar {
    flex:1;
    display: flex;
    flex-direction: column;
    gap: var(--gap-size);
}

.column-sidebar > .tile {
    flex: 1
}
```

For Bootstram library -- 

- `.flex-row`-- Horizontal layout (default)
- `.flex-row-reverse`-- Horizontal layout in reverse order
- `.flex-column`-- Vertical
- `.flex-column-reverse`

##### Styling the login form

And the `<form>`has the class `login-form`-- 

```css
.login-form h3 {
    margin:0;
    font-size: 0.9em;
    font-weight: bold;
    text-align: end;
    text-transform: uppercase;
}
```

With the bootstrap library like:

```html
<h3 class="m-0 fs-6 fw-bold text-end text-uppercase">
    Login
</h3>
```

```css
.login-form input:not([type=checkbox]):not([type=radio]) {
    display: block;
    inline-size:100%;
}
.login-form button {
    margin-block-start: 1em;
    border: 1px solid #cc6b5a;
    background-color: white;
    padding: 0.5em 1em;
    cursor: pointer;
}
```

```html
<div class="login-form">
    <input type="text" class="form-control w-100 mb-2">
</div>
```

#### Alignment, spacing and other details

- `justify-content`-- `flex-start, start, left, flex-end, space-between` -- this is for horizontal
- `align-content` -- for column alignment -- `felx-start-start`...
- `align-items`-- `flex-start-start`...
- `align-self`-- Control how the item is aligned on the cros axis.

##### Flex container properties

Fore, `align-items`adjusts their alignment along the cross axis. `align-self`controls a flex item’s alignment along its container’s corss axis.

```css
.centered {
    text-align: center;
}
.cost {
    display: flex;
    justify-content: center;
    align-items: center;
    line-height: 0.7;
}
.cost-currency {
    font-size: 2rem;
}
.cost-dollars {
    font-size: 4rem;
}
.cost-cents {
    font-size: 1.5rem;
    align-self: flex-start;
}
.cta-button {
    display: block;
    background-color: #cc6b5a;
    color: white;
    padding: 0.5em 1em;
    text-decoration: none;
}
```

For using the bootstrap library like:

```html
<div class="text-center">
    <small>Starting at</small>
    <div class="d-flex justify-content-center
                align-items-center lh-1">
        <span class="fs-2">$</span>
        <span class="fs-1">20</span>
        <span class="fs-4 align-self-start">.00</span>
    </div>
    <a class="cta-button" href="/pricing">
        Sign up
    </a>
</div>
```

### The `grid`

An element with `display: grid`becomes a *grid container`-- 

```css
.grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gird-template-rows: 1fr 1fr;
    gap: 0.5em;
}

.grid > * {
    background-color: darkgray;
    color: white;
    padding: 2em;
    border-radius: .5em;
}
```

For the grid, bootstrap just use `.row`and `.col-*`class.

## Go-lang function option patterns

```go
type Server struct {
    Host string
    Port int
    TLS bool
}
type Option func(*Server)

func WithHost(host string) Option {
    return func(s *Server) {
        s.Host= host
    }
}
func WithPort(port int) Option {
    return func(s *Server) {
        s.Port=port
    }
}
func WithTLS (enabled bool) Option {
    return func(s *Server) {
        s.TLS = enabled
    }
}
// Now can construct it like:
func NewServer(opts ...Options) *Server {
    s := &Server {
        Host: "localhost",
        Prot: 8080,
        TLS:  false,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// usage 
srv := NewServer(WithHost("Example"), WithPort(443), WithTLS(true))
```

### Slice initialization

```go
func convert(foos []Foo) []Bar {
    bars := make([]Bar, 0)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

Every time the backing array is full, Go creates another array by *doubling* its capacity.

Performance-wise, there is no good reason not to give the Go runtime a helping hand. There are two different options for this -- 

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, 0, n)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

Internally, Go *pre*-allocates an array of `n`elements.

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, n)
    for i, foo := range foos {
        bars[i]= fooToBar(foo)
    }
    return bars
}
```

And, if setting a cpa and using `append`is less efficient than just setting a length, and assignment -- Fore:

```go
func collectAllUserKeys(cmp Compare, tombstones []tombstoneWithLevel) [][]byte {
    keys := make([][]byte, 0, len(tombstone)*2)
    for _, t := range tombstones {
        keys = append(keys, t.Start.UserKey)
        keys = append(keys, t.End)
    }
}
```

The conscious choice is to use a given capacity and `appen`. If used the given length -- 

```go
func collectAllUserKeys(cmp Compare, tombstones []tombstoneWithLevle) [][]byte {
    keys := make([][]byte, len(tombstones)*2)
    for i, t := range tombstones {
        keys[i*2]= t.Start.UserKey
        keys[i*2+1]= t.End
    }
}
```

### `nil`vs. empty slices

- A slice is empty if its length is equal to 0
- nil if it equals `nil`

```go
func main(){
    var s []string
    log(1, s) // true true
    
    s = []string(nil)
    log(2, s) // true true
    
    s = []string{}
    log(3, s) // empty=true, nil false
    
    s= make([]string,0)
    log(4, s) // empty=true, nil false
}

func log(i int, s []string) {
    fmt.Printf("%d: empty=%t\tnil=%t\n", i, len(s)==0, s==nil)
}
```

### Checking if a slice is empty

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if operations != nil {
        handle(operations) // check if nil
    }
}

func getOperations(id string) []float32 {
    operations := make([]float32, 0)
    if id == "" {
        return operations
    }
    // Add elements to operations
    return operations
}
```

For this, determine whether the slice has elements by checking if the `operations`slice isn’t `nil`.

```go
func getOperations(id string) []float32 {
    operations := make([]float32, 0)
    if id == "" {
        return nil
    }
    // ...
}
```

For this insted of returning `opertions`if `id`is empty, return `nil`-- check implement about tesing the slice nullity matches -- this approach doesn’t work in all situations.

```go
func handleOperations(id string) {
    operations := getOperations(id)
    
    // if nil, !=0 is false
    // if isn't nil but empty, !=0 is also false
    if len(operations)!=0 {
        handle(operations)
    }
}
```

### Making Slice copies correctly

The `copy`built-in function allows copying elements from a source slice into a destination slice -- 

```go
src :=- []int {0, 1, 2}
var dst []int
copy(dst, src)
fmt.Println(dst)
```

For this `src`is 3l slice, but `dst`is 0-length. Therefore, the `copy`copies the minimum number of elements.

```go
src := []int{0, 1, 2}
dst := make([]int, len(src))
copy(dst, src)
```

Also mention that using the `copy`to copy slice elements -- There are different alterntives, the best know being probably the following -- uses `append`like:

```go
src := []int{0, 1, 2}
dst := append([]int(nil), src...)
```

We append the elements from the source slice to a `nil`slice.

### Side effects using slice append

```go
// 3L, 3C slice
s1 := []int {1,2,3}

// 1L and 2C slice
s2 := s1[1:2]
s3 := append(s2, 10)
```

Adding an element using `append`checks whether the slice is full. For `s1`'s content was modified, even though we did not update `s1[2]`, or `s2[1]`directly, should keep this in mind.

The first is to pass a copy --

```go
func main() {
    s := []int {1,2,3}
    sCopy := make([]int, 2)
    copy(sCopy, s)
    f(sCopy)
    result := append(sCopy, s[2])
}
func f(s []int) {
    // update s
}
```

The second is use `[low:high:max]`This creates a slice similar to the one created with `s[low:high]`, except that the resulting slice’s capacity is equal to `max-low`. Like:

```go
func main() {
    s := []int{1,2,3}
    f(s[:2:2]) // use s
}
```

When passing `s[:2:2]`limit the range of effects to the first two elements.

### Slices and memory leaks

This shows that slicing an existing slice or array can lead to memory leaks in some conditions.

#### Leaking CAP

Image implementing custom binary protocol -- 

```go
func consumeMessages() {
    for {
        msg := receiveMessage()
        storeMessageType(getMessageType(msg))
    }
}

func getMessageType(msg []byte) []byte {
    return msg[:5]
}
```

For the `getMessageType`computes the message type by slicing the input slice -- test this imp -- and everything is fine -- when `1GB`used -- The slice option on `msg[:5]`creates a 5L slice -- its capacity remains the same as the initial slice. The remaining elements are still allocated in memory. So:

```go
func getMessageType(msg []byte) []byte {
    msgType := make([]byte, 5)
    copy(msgType, msg)
    return msgType
}
```

Perform a copy, is 5L and 5C slice regardless of the size of the message received.

#### Slice and pointers

Have seen that slicing can cause leak cuz of the slice capacity -- for elements which are still part of the backing array but outside the length range -- Fore:

```go
type Foo struct {
    v []byte
}
```

```go
func main() {
    foos := make([]Foo, 1_000)
    printAlloc()
    
    for i:=0; i<len(foos); i++ {
        foos[i]= Foo {
            v: make([]byte, 1024*1024)
        }
    }
    printAlloc()
    two := keepFirstTwoElementsOnly(foos)
    runtime.GC()
    printAlloc()
    runtime.KeepAlive(two)
}

func keepFirstTwoElemetnsOnly(foos []Foo) []Foo {
    return foos[:2]
}
```

What are the options to ensure that we don’t leak the remaining `Foo`elements -- 

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    res := make([]Foo,2)
    copy(res, foos)
    return res
}
```

### Missing the Signal

What happens if a goroutine calls `Signal()`or `Broadcast()`and there is no execution waiting for it. Will it be lost or stored for the next goroutine to call `Wait()`. Instead of using sleep, can have our `main()`function wait on a condition variable and then have child goroutine send a signal when it’s ready.

```go
func doWork(cond *sync.Cond) {
    fmt.Println("work started")
    fmt.Println("work finished")
    cond.Signal()
}

func main() {
    cond := sync.NewCond(&sync.Mutex{})
    cond.L.Lock()
    for i:=0; i<50000; i++ {
        go doWork(cond)
        fmt.Println("Waiting for child goroutine")
        cond.Wait()
        fmt.Println("child goroutine finished")
    }
    cond.L.Unlock()
}
```

The problem in the preceding output is that we might end up signaling when the `main()`goroutine is not waiting on the condition variable. When this happens, miss the signal. To ensure don’t miss signals and broadcasts, need to use them in conjunction with mutexes -- In this way, know for sure that the `main()`is in a waiting state cuz the mutex is only releaseed when the goroutine calls `Wait()`. So:

```go
func doWork(cond *sync.Cond) {
    fmt.Println("Work started")
    fmt.Println("work finished")
    cond.L.Lock()
    cond.Signal()
    cond.L.Unlock()
}
```

#### Sync multiple with waits and broadcasts

Using `Broadcast()`- ensure that all suspended goroutines on the condition are resumed. Like:

```go
func main() {
    cond := sync.NewCond(&sync.Mutex{})
    playerInGame := 4
    for playerId :=0; playerId<4; playerId++ {
        go playHandler(cond, &playersInGame, playerId)
        time.Sleep(time.Second)
    }
}

func playerHandler(cond *sync.Cond, playerRemaining *int, playerId int) {
	cond.L.Lock()
	fmt.Println(playerId, ": connected")
	*playerRemaining--
	 if *playerRemaining == 0 {
		 cond.Broadcast()
	 }
	 for *playerRemaining > 0 {
		 fmt.Println(playerId, ": waiting for more players")
		 cond.Wait()
	 }
	 cond.L.Unlock()
	 fmt.Println("All players connected, ready player", playerId)
}
```

### Counting semaphores

What if we need to allow a variable number of executions to happen concurrently -- is there a mechanism that can allow us to specify *how many* goroutines can access our resource -- Could limit the number of interactions by allowing a fixed number of goroutines to access the dbs -- once the limit is reached, can either make the goroutines wait or return an error message to the client.

A mutex ensures that only a single goroutine has exclusive access, whereas a semaphore ensures that at most `N`gorotuines have access.

- New Semaphore function -- creates a new with X permits
- Acqure permit function - A goroutine will tke one permit from the semaphore
- Release permit function

##### Building a semaphore

https://pkg.go.dev/golang.org/x/sync containing an implementation of a semaphore. But customize like:

```go
type Semaphore struct {
	permits int
	Cond    *sync.Cond
}

func NewSemaphore(permits int) *Semaphore {
	return &Semaphore{
		permits: permits,
		Cond:    sync.NewCond(&sync.Mutex{}),
	}
}

// to implement the `Acquire()`, need to call `Wait()` on a condition variable
func (rw *Semaphore) Acqiure() {
	rw.Cond.L.Lock()
	for rw.permits <= 0 {
		rw.Cond.Wait()
	}
	rw.permits--
	rw.Cond.L.Unlock()
}

func (rw *Semaphore) Release() {
	rw.Cond.L.Lock()
	rw.permits++
	rw.Cond.Signal()
	rw.Cond.L.Unlock()
}
```

##### Never miss a signal with semaphores

Could end up calling the `Signal()`before the `main()`had called `Wait()`. Can solve this by using a semaphore initialized with 0 permits. Cause the `Wait()`called first.

```go
import (
	semLib "ubuntuTest/semaphore"
)
func main() {
	semaphore := semLib.NewSemaphore(0)
	for i := 0; i < 50000; i++ {
		go doWork(semaphore)
		fmt.Println("Waiting for child goroutine")
		semaphore.Acqiure()
		fmt.Println("Child goroutine finished")
	}
}

func doWork(semaphore *semLib.Semaphore) {
	fmt.Println("Starting child goroutine")
	fmt.Println("Work finished")
	semaphore.Release()
}
```

### Sync with `WaitGroup`and barries

Waitgroup and barries are two sync abstractions that work on groups of executions. Typically use *waitgroups* t wait for a group of tasks to complete, use *barries* to sync many execution at a common point. A typical pattern of using waitgroup - set the size of the waitgroup and then use the two operations `Wait()`and `Done()`. Typically have multiple goroutines that need to complete a few tasks concurrently. Create a waitgroup then set its size to be equal to the number of assigned tasks. Once a goroutine finishes, it calls the `Done`.

- `Done()`-- Decrements the waitgroup size counter by 1
- `Wait()`-- Blocks until the waitgroup size counter is 0
- `Add(delta int)`-- Increments the waitgroup size counter by delta.

```go
func main() {
	wg := sync.WaitGroup{}
	wg.Add(4)
	for i := 1; i < 5; i++ {
		go doWork(i, &wg)
	}
	wg.Wait()
	fmt.Println("All complete")
}

func doWork(id int, wg *sync.WaitGroup) {
	i := rand.Intn(5)
	time.Sleep(time.Duration(i) * time.Second)
	fmt.Println(id, "done working after", i, "seconds")
	wg.Done()
}
```

For this, can use an anonymous function running in a separate goroutine -- like:

```go
func main() {
	wg := sync.WaitGroup{}
	wg.Add(31)
	mutex := sync.Mutex{}
	var frequency = make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		go func() {
			countLetters(url, frequency, &mutex)
			wg.Done()
		}()
	}
	wg.Wait()
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, frequency[i])
	}
}
```

