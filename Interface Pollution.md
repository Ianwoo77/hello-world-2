# Interface Pollution

Interfaces are one of the cornerstones of the Go language when desigining and structuring our code. Abusing them is generally not a good idea -- Interface pollution is about overwhelming our code with unnecessary abstractions, making it harder to understand. Note that it’s a common mistake made by developers coming from other langs.

### Concepts

An interface provide a way to specify the behavior of an object. Ust this to create common abstractions that multiple objects can implement -- what makes Go interfaces so different is that they are satisfied implicitly.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

Custom imps of the `io.Reader`interface should accept a slice of bytes, filling it with its data and returning either the number of bytes read or an error. On the other hand, `io.Writer`defines a single method `Write`, write to a target and return either the number of bytes or an error. Fore:

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    source := strings.NewReader(input)
    dest := bytes.NewBuffer(make([]byte, 0))
    
    err := copySourceToDest(source, dest)
    if err != nil {
        t.FailNow()
    }
    got := dest.String()
    if got != input {
        t.Errorf("expected: %s, got: %s", input, got)
    }
}
```

in this example, `source`is a `*strings.reader`, whereas `dest`is a `*bytes.Buffer`, here just test the behavior of `copySourceToTest()`without creating any files. Indeed, adding methods to an interface can decrease its level of reusability -- `io.reader`and `io.Writer`are powerful abstractions cannot get any simpler. Furthermore, can also combing fine-grained interfaces to create higher-level abstractions.

#### When to use Interfaces

3 concrete cases where interfaces are usually considered to bring value -- 

- Common behavior
- Decoupling
- Rstricting Behavior

Common Behaviro -- The first we will discuss -- multiple types implement a common behavior -- in such case, we can factor out the behavior insdie an interface -- If look at the stdlib -- can find many examles of such use case. fore:

```go
type Interfaec interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

This interface has a strong potential for reusability cuz it encompasses the common behavior to srot any collection that is index-bsed. Finding the right abstraction to factor a behavior can also bring many benefits -- the `sort`package provides utility functions that alsoy rely on `sort.Interface`like:

```go
func IsSorted(data Interface) bool {
    n := data.Len()
    for i:= n-1; i>0; i-- {
        if data.Lenss(i, i-1) {
            return false
        }
    }
    return true
}
```

##### Decoupling -- 

Another important use case is about decoupling our code from an IMP -- If we rely on abstraction instead of a concrete imp, the  imp itself can be replaced with another wihtout even having to change our code. One beneift of decoupling can be related to unit testing -- Fore

```go
type CustomerSerivce struct {
    store mysql.Store // depends on concrete imp
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.store.StoreCustomer(customer)
}
```

Fore, if want to test this method -- cuz `customerSerivce`reles on the actual imp store a `Customer`-- obliged to test it through integration tests,  which requires spinning up a MySQL instance. That is not always want to do -- To give us more flexibility, should decouple `CustomerService`from the actual imp -- which can be done via in interface like:

```go
type CustomerStorer interface {// note the name
    StoreCustomer(Customer) error
}
type CustomerService struct {
    store CustomerStorer
}
func (cs CustomerService) CreatenNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.storer.StoreCustomer(customer)
}
```

Cuz string a customer is now done via an interface, this gives us more flexibility in how we want to test the method. Fore, can -- 

- Use the concrete imp via integration tets
- use a mock

##### Restricting Behavior

The last use case will discuss can be counterintuitive -- It’s about restricting a type to a speicifc behavior. Imagine we implement a custom configuration package to deal with dynamic configuration -- create a specific container for `int`configurations via an `IntConfig`struct that also exposes two methods `Get`and `Set`. like:

```go
type IntConfig struct {}
func (c *IntConfig) Get() int {
    //... retrieve
}
func (c *IntConfig) Save(value int) {
    // ... update
}
```

Fore, want to receive an `IntConfig`that hold some specific configuration -- Yet in the code, only interested in retrieving the configuration value, and want to *prevent* updating it. How can we enfoce that -- semanitcally, this configuraiton is read-only, we don’t want to change our configuration package -- by:

```go
type intConfigGetter interface {
    Get() int
}
// ... then in the code
type Foo struct {
    threhold intConfigGetter // just has a get interface
}
func NewFoo(threshold intConfigGetter) Foo {
    return Foo{threhold}
}
func (f Foo) Bar() {
    threhold := f.threhold.Get()
}
```

Fore, the configuration getter is injected into the `NewFoo`factory method, it doesn’t impact a client of this function cuz it can still pass `IntConfig`struct as it implements `intConfigGetter`interface. Then can only read the configuration in the `Bar`method.

## Condition Variables

```go
func spendy(money *int, mutex *sync.Mutex) {
    for i:=0; i<200000; i++ {
        mutex.Lock()
        *money -= 50
        if *money < 0 {
            fmt.Println("Money is negative")
            os.Exit(1)
        }
        mutex.Unlock()
    }
    //...done
}
```

Is there anything we can do to stop the blance from going into the negative -- Ideally, we 

```go
for i := 0; i < 200000; i++ {
    mutex.Lock()
    for *money < 50 {
        mutex.Unlock()
        time.Sleep(10 * time.Millisecond)
        mutex.Lock()
    }
    *money -=50
    if *money < 0 {
        fmt.Println("Money is negative!")
        os.Exit(1)
    }
    mutex.Unlock()
```

This solution will work, but it’s not ideal -- in the example, choose the arbitrary sleep value of 10m, but -- what should be the optmial number to choose -- at one extreme, we can choose not to sleep at all -- this ends up wasting CPU resources, as the CPU would be cycling needlessly, checking the `money`varible even if it doesn’t change.

This is where condition variable come in. Condition variables *work together* with mutexes and give us the ability to suspend the current execution until have a signal that a particular condition has changed.

- If condition is not met -- A alls `Wait()`on the condition variable.

- The `Wait()`performs two operations *atomically* -- 

  a. It releases the mutex note that

  b. It blocks the current execution, effective putting the goroutien to sleep.

- For now the mutex is available -- another goroutine B acquires it to update the shared bank account variable.

- After updating the shared state, B calls `Signal()`or `Boardcast()`on the condition variable and then unlocks.

- Upon receiving `Signal()`or `Boardcast()`, A wakes up and automatically re-acquires the mutex.

```go
type Cond interface {
    func NewCond(l Locker) *Cond
    func (c *Cond) Broadcast()
    func (c *Cond) Signal()
    func (c *Cond) Wait()
}
```

And creating a Go Condition just need a `Locker`-- 

```go
type Locker interface {
    Lock()
    Unlock()
}
```

```go
func main() {
	cond := sync.NewCond(&sync.Mutex{})
	money := 100
	go spendy(&money, cond)
	go stingy(&money, cond)
	time.Sleep(2*time.Second)
	fmt.Println("Final Money:", money)
}
```

Changing  the `stingy`is simpler -- only need to signal sth.

```go
func stingy(money *int, cond *sync.Cond) {
	for i := 0; i < 1000000; i++ {
		cond.L.Lock()
		*money += 10
		cond.Signal()
		cond.L.Unlock()
	}
	fmt.Println("stringy done")
}
```

Then modify the `spendy()`so that it will wait until have enough funds in our `money`variable like:

```go
func spendy(money *int, cond *sync.Cond) {
	for i := 0; i < 200000; i++ {
		cond.L.Lock()
		for *money < 50 {
			cond.Wait()
		}
		*money -= 50
		if *money < 0 {
			os.Exit(1)
		}
		cond.L.Unlock()
	}
	fmt.Println("Spendy Done")
}
```

So whenever a waiting goroutine *receives a signal or a Boardcast, it will try to reacquire the mutex*. And if another execution is holding on to the mutex, the goroutine will remain supsended until the mutx become avaliable.

#### Missing in the Signal

Note that what happens if goroutine calls `Signal()`or `Broadcast()`and there is no execution waiting for it -- If there is no goroutine is in waiting state, the `Signal()`or `Broadcast()`call will be missed. Fore have our `main()` func wait on a condition variable and then have the child send a signal when it’s ready like:

```go
func doWork(cond *sync.Cond) {
	fmt.Println("Work started")
	fmt.Println("Work finished")
	cond.Signal()
}
func main() {
	cond := sync.NewCond(&sync.Mutex{})
	cond.L.Lock()
	for i := 0; i < 50000; i++ {
		go doWork(cond)
		fmt.Println("Waiting for child goroutine")
		cond.Wait()
		fmt.Println("Child goroutine finished")
	}
	cond.L.Unlock()
}
```

The problem in the preceding ourput is that we might end up signaling when the `main()`is not waiting on the condition vairable. When this happens, we miss the signal. To just ensure that we don’t miss any signals and broadcasts, need to use them in conjunction with mutexes -- That is we should call these functions only when we are holding the associated mutx -- Always use `Signal()`, `Broadast()`and `Wait()`when hilding the mutex lock to avoid problms.

#### Sync multiple goorutines with waits and broadcasts

We have only looked at examples using `Signal()`instead of `Broadcast()`-- When have multiple goroutines suspended on a condition variable’s `Wait()`.. `Signal()`will arbitrarily wake up one of these goroutines. The `Broadcast()`call, on the other hand, will wake up all goroutines that are suspended on a `Wait()`.

```go
func main() {
	cond := sync.NewCond(&sync.Mutex{})
	playersInGame := 4
	for playerId:=0; playerId<4; playerId++ {
		go playerHandler(cond, &playersInGame, playerId)
		time.Sleep(time.Second)
	}
}
```

Can make use of conditiona variables by having more than one goroutine wait on the same condition -- since we have a goroutine handling each player , can have each on e wait on a condition that tells us when all the players have connected. Can then use the same condition variable to check if all the players are conencted, if not, call `Wait()`-- 

```go
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

#### Counting Semaphores

The `semaphore`-- a contruct which can be used to constrain or control access to a shared resource access via mutliple threads or goroutines -- Mutexes just give as a way to allow only one execution to happen at a time -- what if need to allow a variable number of executions to happen concurrently -- is there a mechanism that can allow us to specify how many goroutines can access our resource -- A mechanism that allow us to limit concurrency would enable us to lmiit the load on a syatem. For a slow dbs that only accepts a certain number of simultaneous conenctions. Could limit the number of interactions by allowing a fixed number of goroutines to access the dbs.

This is where *semaphore* come in handy -- allow a fixed number of permits that enable concurrent execution to access the shared resources.

## JSON Charset

If your programming carer -- acorss other JSON APIs which send responses with the header like: `Content-Type: application/json; charset=utf-8`-- including a `charset`parameter like this isn’t normally necessary.

JSON text excahnaged between systems that are not part of a closed ecosystem *MUST* be encoding using UTF-8. Cuz the API will be a public-facing app, it means that our JSON responses must always be UTF8 encoded, and it also means that it’s safe for the client to assume that the responses it gets are always UTF8 encoded.

#### JSON encoding

At a high-level, Go’s `encoding/json`package provides two options for encoding things to JSON, can eigher call the `jaon.Marshal()`func, or can just declare an use `json.Encoder`type -- For the purpose of sending JSON in a HTTP response, using `json.Marshal()`is generally the better choice. The way that `json.Marshal()`just simple.

#### How diffrent Go types are encoded -- 

In this encoding a `map[string]string`type to JSON, which resulted in a JSON object with JSON strings as the values in the k/v pairs, but Go supports encoding many other native types too.

Using `json.Encoder`-- At the start of this -- Go’s `json.Encoder`type to perform the encoding -- this allows you to encode an object to JSON and write that JSON to an output stream in a single step.

```go
func (app *application) exampleHandler(w http.ResponseWriter, r *http.Request) {
    data := map[string]string{
        "hello": "world",
    }
    w.Header().Set("Content-type", "appliation/json")
    
    // Use the json.NewEncoder to initialize a Encoder instance that writes to the 
    // http.ResponseWriter
    // passing in the data that we want to encode the JSON
    err := json.NewEncoder(w).Encode(data)
    if err != nil {
        app.logger.Print(err)
        http.Error(w, "...", http.StatusInternealServerError)
    }
}
```

This pattern works, and it is very neat and elegant, but if you consider it carefully, might notice a slight problem -- When call `json.NewEncoder(w).Encode(data)`the JSON is created and written to the `http.RespnseWriter`in a single step -- which means there is no opportunity to set HTTP response headers conditionally based on whether the `Encode`returns an err or or not.

So, imagine -- fore, that you want to set a `Cache-Control`header on a successufl response, but not set if the JSON encoding fails and you have to return an error response. So Implementing that cleanly while using the `json.Encoder()`patttern is quite difficult.

U could set the `Cache-Control`when delete it from the headermap agin in the even of an error.

#### performance of `json.Encoder`and `json.Marshal`

Talking of speed, might be wondering if there is any performance difference between using `json.Encoder`and `json.Marshal()`-- the different is just small and in most cases you should not worry about it.

### Encoding Structs

In this chapter we are going to headback the method `showMovieHandler`that we made eariler and update it to return a JSON repsonse which represents a single movie in our system -- like: a struct -- instead of encoding a map to create this JSOn object -- this time we are going to encode a custom `Movie`struct -- do this inside the `internal/data`package then:

```go
type Movie struct {
	ID        int64
	CreatedAt time.Time
	Title     string
	Year      int32
	Runtime   int32
	Genres    []string
	Version   int32
}
```

It’s crucial to point out here that all the *fields* in the struct are exported -- which is necessary for them to be visible to Go’s `encoding/json`package. Now this is done, update the `showMovieHandler`to intialize an instance of `Movie`struct containing some dummy data like:

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	// create a new instance of the Movie struct containing the ID from the URL
	// and some dummy data
	movie := data.Movie{
		ID:        id,
		CreatedAt: time.Now(),
		Title:     "Casablanca",
		Runtime:   102,
		Genres:    []string{"drama", "romance", "war"},
		Version:   1,
	}

	// Encode the struct to JSON and send as the HTTP response
	err = app.writeJSON(w, http.StatusOK, movie, nil)
	if err != nil {
		app.logger.Print(err)
		http.Error(w, "The server encounter a problem", http.StatusInternalServerError)
	}
}
```

There are just a few interesting things in this response to point out -- 

- Our `Movie`struct has been encoded into a single JSON object, with the field names and values as the k/v pairs.
- By default, the keys in the JSON object are equal to the field names in the struct.
- If a struct field doesn’t have an explicit value set, then the JSON-encoding of the zero value for the field will appear in the output.

#### Changing keys in the JSON Object

One of the nice things about encoding structs in Go is that you can customize the JSON by annotating the fields with **struct tags**. Probably the most common use of struct tag is to change the key names that appera in the JSON object -- this can be useful when your struct field names aren’t appropratie for public-facing responses. Or you ant to alternative casing style in your JSON output.

```go
type Movie struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	Title     string    `json:"title"`
	Year      int32     `json:"year"`
	Runtime   int32     `json:"runtime"`
	Genres    []string  `json:"genres"`
	Version   int32     `json:"version"`
}
```

#### Hiding struct fields in the JSON object -- 

It’s also possible to control the visibility of individual struct struct fields in the JSON by using the `omitempty`and `-`struct tag directives. the `-`directive can be used when you *never* want a particular struct field to appear in the JSON output, this is useufl for fields that contain internal system information that isn’t relevant to your users, or sensitive information that you don’t want to expose. In contrast `omitempty`directive hides a field in the JSON output if and only if the struct field value is empty -- 

- Equal to `false, 0, ""`
- An empty array slice or map
- A `nil`pointer or a `nil`interface value
