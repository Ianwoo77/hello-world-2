# Checking an error value

This is similar to previous -- with sentinel errors -- first, we will define what a sentinel error conveys -- then will see how to comare an error to a value -- A sentienl is an error defined as a *global* variable like:

```go
import "errors"
var ErrFoo = errors.New("foo")
```

In general, the convention is start with `Err`followed by the error type -- `ErrFoo`-- A sentinel error conveys an *expected* error -- but what do we mean by an expected error -- Fore, want to design `Query`method that allow us to execute a query to a dbs -- returns a slice of rows fore, how should we handle the case when no rows are found -- We have two options -- 

- Return a sentinel value, fore, a `nil`slice
- Return a specific error that a client chan check -- 

Fore, second - return a specific error if no rows are found -- can classify this as *expected error*. Cuz passing a request that returns no rows is allowed. Conversely, situations like network issues and connection polling errors are *unexpected errors*. doen’t mean we don’t want to handle unexecpted errors - means that semantically, those errors convey different meaning -- 

- `sql.ErrNoRows`-- returned when a query doesn’t return any rows
- `io.EOF`-- returned by `io.Reader`when no more input is available.

That is the general principal -- they convey an **expected** error that clients will expect to check.

- Expected error should be designed as error values - - `var ErrFoo= Errors.New("foo")`

- Unexpected errors should be desigend as error types  like:

  ```go
  type BarError struct {...} // implement the error interface
  ```

Can compare an error to a specific value by using the `==`like:

```go
err := query()
if err != nil {
    //...
}else {...}
```

Note that here call a `query`function and get an error -- checking whether the error is an `sql.ErrNoRows`is done using the `==`operator -- If an `sql.ErrNoRows`is wrapped using `fmt.Errorf`and the `%w`directive, will be false.

For these **expected** error -- for `errors.As`is used to check an error against the type, with error values, can use its counterpart `errors.Is()`-- like:

```go
err := query()
if err != nil {
    if errors.Is(err, sql.ErrNoRows)
    //...
}
```

For this, using `errors.Is`instead of the `==`allows the comparison to work even if the error wrapped.

### Handling an error twice

Fore, rewrite a `GetRoute`function to get the route from a pair of source to a pair of target coordinates.

```go
type Route struct{}

func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
	err := validateCoordinates(srcLat, srcLng)
	if err != nil {
		log.Println("error validating coordinates", err)
		return Route{}, err
	}

	err = validateCoordinates(dstLat, dstLng)
	if err != nil {
		log.Println("error validating coordinates", err)
		return Route{}, err
	}

	return getRoute(srcLat, srcLng, dstLat, dstLng)
}

func validateCoordinates(lat, lng float32) error {
	if lat > 90 || lat < -90 {
		log.Println("latitude out of range")
		return fmt.Errorf("latitude out of range")
	}
	if lng > 180 || lng < -180 {
		log.Println("longitude out of range")
		return fmt.Errorf("longitude out of range")
	}
	return nil
}
```

With the code, it is cumbersuome to repeat the *invalid...* error messages in both logging and the error returned. Having two log lins for a single error is a problem -- cuz it makes debugging harder. Fore if this function is called multiple times concurrently, the two messages may not be one after the other in the logs.  Should using wrapping like:

```go
func getRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
	err := validateCoordinates(srcLat, srcLng)
	if err != nil {
		return Route{}, 
		fmt.Errorf("error validating coordinates: %w", err)
	}

	err = validateCoordinates(dstLat, dstLng)
	if err != nil {
		return Route{}, fmt.Errorf("error validating coordinates: %w", err)
	}

	return getRoute(srcLat, srcLng, dstLat, dstLng)
}
```

Each error returned by `validateCoordinate`is now wrapped to provide additional context for the error: whether it is related to the source or target coordinates. With this versoin, have covered the different case.

With this version, have covered all the different cases - a single log, without losing any valuable information.

### Knowing which type of receiver to use

Choosing a receiver type of a method isn’t always straightforward - when should we use value receiver -- or pointer receiver - for this look at the conditions to make the right decision.

In Go, can attach either a value or a pointer receiver to a method-- which a value receiver, Go makes a copy of the value and passes it to the method. Any changes to the object remain local to the method. like:

```go
type customer struct {
    balance float64
}

func (c customer) add(v float64) {
    c.balance += v
}

func main(){
    c := customer{balance:100}
    c.add(50.)
    fmt.Printf("balance: %.2f\n", c.balance)
}
```

If using: 

```go
func (c *customer) add(operation float64) {
    c.balance += operation
}
```

## Updating shared variables from multiple goroutines

```go
const allLetters = "abcdefghijklmnopqrstuvwxyz"

func countLetters(url string, frequency []int) {
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
}

func main() {
	var frequency = make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		countLetters(url, frequency)
	}
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, frequency[i])
	}
}
```

In the `main`, create a new slice that will store the results, containing the letter frequency table. Fore, try to improve the speed of our program by using concurrent programming -- shows how we can use multiple goroutines to download and process each web page concurrently instead of one after the other.

If `go countLettters(...) time.Sleep(10*Second)`-- the goroutiens all share the same data structure in memory -- when initialize the Go slice in the `main()`-- allocate space for it on the heap. When create the goroutiens, pass them all the same reference to the memory location containing the Go slice. The 31 goroutines then go about reading and writing to the same frequency slice concurrently. In this way, the threads are cooperating and working totegher to update the same memory space.

### Race Conditions

RCs are what happens when your program is trying to do many things at the same time -- and its behavior is dependent on the exact timing of independent unpredictable events.

```go
func main() {
    money := 100
    go stingy(&money)
    go spendy(&meoney)
    time.Sleep(2*time.Second)
    // print
}
```

DEF -- A *Critical section* is our code is a set of instructions that should be executed without interference from other executions affecting the state used in that section. 

Note hat even if the instructions were atomic, we might still up into issues -- Each processor core has a local cache and regieters to store the variables that are used frequently -- when we compile our code, the compiler sometimes applies optimizations to keep the variables on the CPU registers or caches before giving instructions to flush them back to memory.

`go run -race spendy.go`

### Sync with Mutexes

DEF -- is a form of concurrency control with the purpose of preventing race conditions -- allows only one execution to enter a CS. Fore, if two executions request acces to the mutex at the same time, the semantics of the mutex guarantee that only one goroutine will acquire access to the mutex. Fore:

```go
func stingy(money *int, mutex *sync.Mutex) {
    for i:=0; i<10000; i++ {
        mutex.Lock()
        *money+= 10
        mutex.Unlock()
    }
    fmt.Println("stingy done")
}
```

#### Sequential processing

Using mutexes has the effect of limiting concurrency. The code in between locking and unlocking a mutex is executed by one goroutine at any time -- effectively returning that part of the code into sequential execution. 

```go
func countLetters(url string, frequency []int, mutex *sync.Mutex) {
	mutex.Lock()
	//...
	mutex.Unlock()
}
```

However, this means that we will be calling these two operations for every letter in the Downloaded document. Since procesing the entire is a very operation - just:

```go
mutex.Lock()
for _, b := range body {
    c := strings.ToLower(string(b))
    cIndex := strings.Index(allLetters, c)
    if cIndex >= 0 {
        frequency[cIndex] += 1
    }
}
mutex.Unlock()
```

In this version of the code, the download part -- which is the length part of the function will execute concurrently. 

#### Non-blocking mutex locks

A goroutine will block when it calls `Lock()`operation if the mutex is already in use by another execution. In some apps, we might want to block the goroutine, but instead perform some other work before attempting again to lock. `TryLock()`-- call this :

- The lock is available, in which case acquire it, and the func will return `true`
- The lock is not available, and the function will return immediately with a Boolean value of `false`.

One example of using `TryLock()`is a monitor goroutine that checs the progress of a certain task without warning to acquire the lock, are putting extra contention on the mutex just for monitoring purposes -- when we use `TryLock()`, if another goroutine is busy holding a lock on the mutex, the monitor goroutine can decide to try again later when the system is not so busy.

```go
func main() {
    mutx := sync.Mutex{}
    for i:=2000; i<=2200 ; i++ {
        url := fmt.Sprintf(...)
        go CounterLetters(url, frequency, &mutex)
    }
    for i:=0; i<100; i++ {
        time.Sleep(100*time.Missisecond)
        if mutex.TryLock() {
            for i, c := range AllLetters {
                //...
            }
        }
        mutex.Unlock()
    }
}
```

### Improving performance with readers-writer mutexes

```go
func matchRecorder(matchEvents *[]string, mutex *sync.Mutex) {
	for i := 0; ; i++ {
		mutex.Lock()
		*matchEvents = append(*matchEvents,
			"Match event "+strconv.Itoa(i))
		mutex.Unlock()
		time.Sleep(200 * time.Millisecond)
		fmt.Println("append match event")
	}
}
```

This shows a client handler function together with a function that copies all the events in the shared slice. For the func simulates building a response to send to the user. Fore, in the real world, could send this response formatted in sth like JSON. like:

```go
func clientHandler(mEvents *[]string, mutex *sync.Mutex, st time.Time) {
	for i := 0; i < 100; i++ {
		mutex.Lock()
		allEvents := copyAllEvents(mEvents)
		mutex.Unlock()

		timeTaken := time.Since(st)
		fmt.Println(len(allEvents), "events copied in", timeTaken)
	}
}

func copyAllEvents(matchEvents *[]string) []string {
	allEvents := make([]string, 0, len(*matchEvents))
	for _, e := range *matchEvents {
		allEvents = append(allEvents, e)
	}
	return allEvents
}
```

Then just conenct everything together and start goroutines in the `main()`

```go
func main() {
	mutex := sync.Mutex{}
	var matchEvents = make([]string, 0, 10000)
	for j := 0; j < 10; j++ {
		matchEvents = append(matchEvents, "Match event")
	}
	go matchRecorder(&matchEvents, &mutex)
	start := time.Now()
	for j := 0; j < 5000; j++ {
		go clientHandler(&matchEvents, &mutex, start)
	}
	time.Sleep(100 * time.Second)
}
```

### Condition variables and semaphores

What if we try to create an imbalance where Spendy is spending at a faster rate than Stingy is earning - prevoulsy we had the total earnings and expenditure balanced at $10m. In this example, will keep the same total amount balanced at $10m.

```go
func stingy(money *int, mutex *sync.Mutex) {
	for i := 0; i < 1000000; i++ {
		mutex.Lock()
		*money += 10
		mutex.Unlock()
	}
	fmt.Println("stingy done")
}

func spendy(money *int, mutex *sync.Mutex) {
	for i := 0; i < 200000; i++ {
		mutex.Lock()
		for *money<50 {
			mutex.Unlock() // unlock allowing other goroutines access to the variable
			time.Sleep(10*time.Millisecond) // sleep for a short while
			mutex.Lock() // locks again to ensure we access the latest money value
		}
		*money -= 50
		if *money < 0 {
			fmt.Println("Money is negative!")
			os.Exit(1)
		}
		mutex.Unlock()
	}
	fmt.Println("Spendy Done")
}
```

This is not an ideal solution, in the example, choose the arbitrary sleep value of 10ms.

```go
func main() {
	mutex := sync.Mutex{}
	money := 100
	go spendy(&money, &mutex)
	go stingy(&money, &mutex)
	time.Sleep(10 * time.Second)
	fmt.Println("Final Money:", money)
}
```

This solution will work for our use case, but it is not ideal, in our example, we choose the arbitrary sleep value of 10ms, but what would be the optimial number to choose -- At one extreme, can choose not to sleep at all. This is where condition variables come in. Condition variables work together with mutexes and give us the ability to suspend the current execution until have a signal that a particular condition has changed. Note that:

`params := httprouter.ParamsFromContext(r.Context())`

## Creating a helper to read ID parameters

The code to extract an `id`prameter from a URL like `/v1/movies/:id`is sth that we will need repeatedly in our application, so abstract logic for this into a small resuable helper method.

```go
// retrieve the `id` URL parameter from the current request context, then convert it to
// in integer and return it
func (app *application) readIDParam(r *http.Request) (int64, error) {
	params := httprouter.ParamsFromContext(r.Context())

	id, err := strconv.ParseInt(params.ByName("id"), 10, 64)
	if err != nil || id < 1 {
		return 0, errors.New("invalid id parameter")
	}

	return id, nil
}
```

Note that the `readIDParam()`method doesn’t use any dependencies from our applicatin struct so it could just be a regular function, rather then a method on `application`.

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Request) {
	id, err := app.readIDParam(r)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	// otherwise, interpolation the movie ID in a placeholder response
	fmt.Fprintf(w, "Show the details of movie %d\n", id)
}
```

It’s just important to be aware that the `httprouter`doesn’t allow *conflicting routes* which potentially match the same request -- so fore, you cannot register a route like `GET /foo/new`to another route like `GET /foo/:id`.

If you are using a std REST structure for your API endpoints, like then this restriction is unliely to cause you many problems. In fact, arguably a positive thing -- cuz Conflicting routes aren’t allowed -- there are no routing-priority rules that you need to worry about. And it reduces the risk of bugs and unintended behavior.

#### Customizing httprouter behavior

The `httprouter`package provides a few configuration options that you can use to customize the behavior of your application further -- including enabling trailing slash redirects and enabling *automatic* URL path cleaning.

### Sending JSON responses

In this -- are going to update our API handlers so that they return JSON response instead of a plain text -- 

- How to send JSON responses from your REST API
- How to encode natvie Go objects in to JSON using `encoding/json`package
- Different techniques for customizing how Go objects are encoded to JSON
- Create reusable helper for sending JSON responses.

#### Fixed-format JSON

Begin by updating our `healthcheckHandler`to send a well-formed JSON response which like:
`{"status":"avaliable", "environment":"development", "version": "1.0.0"}`

So that means can write a JSON response from your Go handlers in the same way that you would write any other text response -- the only special thing need to do is set a `Content-Type: application/json`.

```go
func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	// create a fixed-format JSON resp from a string
	js := `{"status": "available", "environment": %q "version": %q}`
	js = fmt.Sprintf(js, app.config.env, version)
	
	// set the content type header to indicate that the response body contains
	w.Header().Set("Content-Type", "application/json")
	
	// write a json as http response body
	w.Write([]byte(js))
}
```

### JSON Encoding

Move on to sth a bit more exciting and llok at how encode native Go objects to JSON -- At a hgih-level,  Go’s `encoding/json`package provides two options for encding things to JSON, `json.Marshal`and the `json.Encoder`type -- but -- for the purpose of sending JSON in HTTP response, using the `json.Marshal()`is generally a better choice -- The wy that `json.Marshal()`works is conceptually quite simple, you pass a native Go object to it as a parameter - and it returns a JSON respresention of the object in a `[]byte`slice. like:

`func Marshal(v any) ([]byte, error)`

Jump in and update our `healthcheckHandler`so that it uses `json.Marshal()`to generate a JSON response directly form a Go map.

```go
func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	// create a map which holds the info that we want to send in the response.
	data := map[string]string{
		"status":      "available",
		"environment": app.config.env,
		"version":     version,
	}

	// Pass the map to the json.Marshal() func -- returns a []byte slice
	// containing the encoded JSON, if there is an error, we log it and send the client
	// a generic error message
	js, err := json.Marshal(data)
	if err != nil {
		app.logger.Print(err)
		http.Error(w, "The server encounter a problem and could not process request",
			http.StatusInternalServerError)
		return
	}

	// Append a newline to the JSON, just a small nicety to make it easier to view
	js = append(js, '\n')

	// At this point we know that encoding the data worked without any problems.
	w.Header().Set("Content-Type", "application/json")

	// use Write() to send the []byte slice
	w.Write(js)
}

```

#### Creating a `writeJSON()`helper method -- 

As our API grows, we are going to be sending a lot of JSON responses, so it makes sense to move some of this logic int a reusable helper method like: As well as creating and sending the JSON, want to design this helper so that can include *arbitrary headers* in successful responses later -- fore, `location`.

```go
func (app *application) writeJSON(w http.ResponseWriter, status int, data any,
	headers http.Header) error {
	js, err := json.Marshal(data)
	if err != nil {
		return err
	}

	// Append a newline to make it easier to view in terminal application.
	js = append(js, '\n')

	// know that we won't encounter any more errors before writing the resp.
	for key, value := range headers {
		w.Header()[key] = value
	}

	// Add the content-type
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	w.Write(js)
	return nil
}
```

Now that the `writeJSON()`helper is in place, can significantly simplify the code in this like:

```go
func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	data := map[string]string{
		"status":      "available",
		"environment": app.config.env,
		"version":     version,
	}
	err := app.writeJSON(w, http.StatusOK, data, nil)
	if err != nil {
		app.logger.Print(err)
		http.Error(w, "The server is currently unavailable", http.StatusInternalServerError)
	}
}
```

The last two of these are special cases deserve a bit more explanation -- like:

- Go `time.Time`values will be encoded as JSON string RFC3339.
- A `[]byte`will be encoded as a base64-encoded JSON string, rathe than a JSON array.

And a few other important things to mention -- 

- Encoding of nested objects is supported, if slice or structs, will encoded to an *array*
- Channels, functions and complex nubmer tytes cannot be encoded.
- A pointer values will encodesd as *value pointed to*.

