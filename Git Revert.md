# Git Revert

`revert`is the command we use when we want to take a previous `commit`and add it as a new `commit`, keeping in the log intact. 

1. Find the previous `commit`
2. Use it to make a new `commit`

### Git revert find commit in log 

First thing, just need to find the point we want to return to -- need to go through the `log`-- To avoid the very long log list, going to use the `--oneline`option -- gives jsut one line per commit showing.

```sh
git log --oneline
```

Git Revert HEAD -- want to revert the last `commit`using `git revert HEAD`(revert the lastest, then commit) -- adding the option `--no-edit`to skep the commit message editor.

```sh
git revert HEAD --no-edit
git log --oneline
```

At last -- `git reset`-- is a command that we use when want to move the repository back to a pervious `commit`, discarding any changes made after the `commit`. First thing, need to find the point want to return to. Need go through the `log`-- to avoid the very long, just use the `--onelone`-- 

```sh
git reset "log number"
# not for undo reset, even though the commits are no longer showing up in the log, 
# not removed from Git
git reset "log number original"
```

## Reshaping and Pivot Tables -- 

Pandas provides methods for manipulating a `Series`and `DataFrame`to alter the representation of the data for further data processing or data summarization.

### `pivot()`

Data is often stored in so-called stacked or record format -- in a record or wide format, typically there is one rwo for each subject, in the stacked or long format there are multiple rows for each subject where application.

```python
data = {
   "value": range(12),
   "variable": ["A"] * 3 + ["B"] * 3 + ["C"] * 3 + ["D"] * 3,
   "date": pd.to_datetime(["2020-01-03", "2020-01-04", "2020-01-05"] * 4)
}
df = pd.DataFrame(data)
df.pivot(columns='variable', values='value', index='date')
```

To perform time series operations with each unique varible, a better representation would be where the columns are the unique variable and an `index`of dates identifies individual observations.

Note that for this, if the `values`argument omitted, and the input DF has more than one column of values which are not used as column or index to `pivot()`-- then the resulting will just have hierarchical columns.

```python
df['value2']=df.value*2
df.pivot(index="date", columns='variable')
```

Can then select subsets from the pivoted DF.

### `pivot_table()`

While `pivot()`provides just general purpose pivoting with various types, pandas also provides `pivot_table()`or method for providing with aggregation of numeric data.

```python
df.pivot_table(values='D', columns='C', index=['A', 'B'], aggfunc='sum')
df.pivot_table(values='E', index=['B', 'C'], columns='A', aggfunc=['mean', 'sum'])
```

The result is a `DataFrame`potentially having a `MultiIndex`on the index or column, if the values column name is not given, the pivot table will include all the data in an additional level of hierarchy in the columns.

And passing `margins=True`to `pivot_table()`will add a row and column with an `All`label with partial group aggregates across the categories on the rows and columns.

```python
table = df.pivot_table(
    index=['A', 'B'],
    columns='C', 
    values=['D', 'E'],
    margins=True, margins_name='total',
    aggfunc='std'
)
table
```

## Context for golang

Concurrency is a fundamental aspect of Go programming, and effectively managing concurrent operations is crucial for building robust and efficient applications -- one of the key features that aids in achieving this is the Context package in Golang -- Context provides a mechanism to control the lifecycle, cancellation, and propagation of requests across multiple goroutines, in this comprehensive guide, will delve into the depths of context in Golang, exploring its purpose, usage, and best practices with real-world exmples from the software industry.

Context is a built-in package in the Go stdlib that provides a powerful toolset for managing concurrent operations. It enables the propagation of cancellation signals, deadlines, and value across goroutines, ensuring that related operations can gracefully terminate when necessary.

```go
func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	urls := []string{
		"https://www.baidu.com",
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

func fetchAPI(ctx context.Context, url string, results chan<- string) {
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		results <- fmt.Sprintf("Error creating request for %s:%s", url,
			err.Error())
		return
	}

	client := http.DefaultClient
	resp, err := client.Do(req)
	if err != nil {
		results <- fmt.Sprintf("Error making request to %s: %s", url,
			err.Error())
		return
	}
	defer resp.Body.Close()
	results <- fmt.Sprintf("Respnose from %s: %d", url, resp.StatusCode)
}
```

In this example, create a context with a timeout of 5, then launch multiple goroutines to fetch data from different APIs concurrently -- used to create an HTTP request with the provided context.

### Creating a Context -- 

To create a context, can use the `context.Background()`function, whcih returns an empty, non-cancelable context as the root of the context tree. U can also create a context with a specific timeout or deadline using `context.withTimeout()`or `context.WithDeadline()`functions.

A *context* carries a deadline, a cancellation signal, and other values across API boundaries. 

#### Deadline

A deadline referes to a specific point in time determined with one of the following -- 

- A `time.Duration`from now
- A `time.Time`

The semantics of a deadline convey that an ongoing activity should be stopped if this deadline is met.

Create a conetxt with Timeout -- create a context with a timeout of 2 seconds and use it to simulate a time-consuming operation -- just like:

```go
func main() {
	// context.Background() returns an empty non-cancelable context
	// as the root of context tree
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

In this example, the `performTask()`simulates a long-running task that take 5 seconds to complete -- however, since the context has a timeout of only 2 seconds, the operation is termitaed prematurely.

### Propagating Context

Once have a context, can propagate it to downstream functions or goroutines by passing it as an argument. like:

```go
func main(){
    ctx := context.Background()
    ctx = context.WithValue(ctx, "userId", 123)
    go performTask(ctx)
}
func performTask(ctx context.Context){
    userId := ctx.Value("userId")
    fmt.Println("user Id:", userId)
}
```

For this, created a parent context using `context.Background()`then use the `context.WithValue`to attach to the context.

### Example: retrieving user info from Context

In this, create a context with user info and retrieve it in a downstream function like:

```go
func main() {
	ctx := context.WithValue(context.Background(), "userID", 123)
	processRequest(ctx)
}

func processRequest(ctx context.Context) {
	userID := ctx.Value("userID").(int)
	fmt.Println("processing request for user id:", userID)
}
```

Created a parent context using the `context.Background()`-- can use the `context.WithValue()`to attach a user ID to the context -- the context is then passed to the `performTask`goroutine, which retrieves the user ID using `ctx.Value()`.

### Retrieving Values from Context

In addition to propagating context, can also retrieve values stored within the context, this allows u to access important data or parameters within the scope of a specific goroutine or function.

Cancelling Context -- Cancellation is an essential aspect of context management - it alows u to gracefully terminiate operations and propagate cancellation signals to relate goroutines. FORE:

```go
func main() {
	ctx, cancel := context.WithCancel(context.Background())
	go performTask(ctx)
	time.Sleep(2 * time.Second)
	cancel()
	time.Sleep(time.Second)
}

func performTask(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			fmt.Println("Task cancelled")
			return
		default:
			// Perform task operation
			fmt.Println("performing task...")
			time.Sleep(500 * time.Millisecond)
		}
	}
}
```

For this, created a context using `context.WithCancel()`and defer the cancellation function, and the `performTask`goroutine continuouly performs a task until the context is canceled, After 2 seconds, call the cancel function to initiate the cancellation process.

### Timeouts and Deadlines

Setting timeouts and deadlines is crucial when working with contxt in Golang. It ensures that operations complete within a specified timeframe and prevents potential bottlenecks or indefinte waits.

```go
func main() {
	ctx, cancel := context.WithDeadline(context.Background(), time.Now().Add(
		2*time.Second))
	defer cancel()
	go performTask(ctx)
	time.Sleep(3 * time.Second)
}

func performTask(ctx context.Context) {
	select {
	case <-ctx.Done():
		fmt.Println("Task completed or deadline exceeded", ctx.Err())
		return
	}
}
```

In this example, create a context with a deadline of 2 seconds using `context.WithDeadline()`. The `performTask`goroutine waits for the context to be canceled or for the deadline to be exceeded. After 3 seconds, we let the program exit, triggering the deadline exceeded error.

## Unit Testing and Sub-tests

Create a unit test to make sure that our `humanDate()`function made back -- is outputting `time.Time`values in the exact format that we want -- like:

```go
func humanDate(t time.Time) string{
    return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

The reason that I want to start by testing this is cuz it’s a simple function. Can explore the basic syntax and patterns for writing tests without getting too caught-up in the functionality that we are testing.

### Creating a unit test -- 

```go
func TestHumanDate(t *testing.T){
    // initialize a new time.Time object and pass it to the humanDate function.
    tm := time.Date(2020, 12, 17, 10, 0,0,0, time.UTC)
    hd := humanDate(tm)
    if hd != "17 Dec 2020 at 10:00" {
        t.Errorf("want %q, got %q", "17 Dec 2020 at 10:00", hd)
    }
}
```

This pattern is the basic one that you will use for nearly all tests that you write in Go, the important thing to take away:

- The test is just regular Go code, which calls the `humanDate`function and checks that the result matches what we expect.
- Your unit tests are contained in a normal Go with a signature `func(*testing.T)`
- Then use the `t.Errorf()`function mark a test as *failed* and log a descriptive message about he failure

### Table-driven tests

Now exapnd the func to cover some additinal test cases -- Specially, we are going to update it also check that -- 

1. If the input to `humanDate()`is the zero time, then it returns the empty string “”.
2. the output from the `humanDate()`func always uses the UTC time zone.

Essentially, the idea behind table-driven tests is to create a *table* of test cases *containing the inputs and expected outputs*, and then loop over these, running each test case in a sub-test -- there are few ways you could set this up, but a common appraoch is to deifne your test cases in an slice of anonymous structs.

```go
func TestHumanDate(t *testing.T){
    tests := []struct {
        name string
        tm time.Time
        want string
    }{
        {
            //...
        },
        //...
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            hd := humanDate(tt.tm)
            if hd!= tt.want {
                t.Errorf("want %q: got %q", tt.want, hd)
            }
        })
    }
}
```

Can see that we get just inidividual output for each of our sub-tests, as u might have guessed, our first test case passed but the `Empty`and `CET`tests both failed, notice -- for the failed test case, get the relevant failure message and filename and line number in the output -- also worth pointing out that when we use the `t.Errorf()`to mark a test failed -- it doesn’t cause `go test`to immediately exit. Just re-write the func like;

```go
func humanDate(t time.Time) string {
    if t.IsZero(){
        return ""
    }
    return t.UTC.Format(...)
}
```

Running all Tests -- to run *all* the tests for a project -- instead of just those in a specific package, can use the `./...`wildcard pattern like:

```sh
go test ./...
```

### Testing HTTP Handlers

Move on and discuss some speicifc techniques for unit testing your Http handlers -- All the handlers written for our proj so far are a bit complex to test, and to introdue things -- prefer to start off with sth a bit simpler.

head over your `handlers.go`file and create a new `ping`handler function which simply returns 200ok response. It’s just the type of handler that U might want to implement for status-checking for uptime nonitoring of your server.

```go
func ping(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK"))
}
```

In this, create a new `TestPing`unit test which -- 

- Checks taht the response status code written by the `ping`handler is 200
- Checks that the response body written by the `ping`handler is `OK`.

Recording Responses -- To assist in testing your HTTP handler Go provides the `net/http/httptest`package -- which contains a suite of useful tools -- one of these is `httptest.ResponseRecorder`-- essentially an implementatio of `http.RespnseWriter`which records the response status code, headers and body instead of actually writing them to a HTTP connection.

So an easy way to unit test your handlers is to create a new `httptest.ResponseRecorder`object, pass it to the handler func and then examine it agin after the handler returns.

```go
func TestPing(t *testing.T) {
	// initialize a new httptest.ResponseRecorder
	rr := httptest.NewRecorder()

	// initialize a new dummy http.Request
	r, err := http.NewRequest(http.MethodGet, "/abc", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Call the ping handler function, passing in the
	// httptest.ResponseRecorder and http.Request
	ping(rr, r)

	// call the Result() method on the http.ResponseRecorder to get the
	// http.Response generated by the ping handler
	rs := rr.Result()

	// can then check the response body written by the ping handler
	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	if string(body) != "OK" {
		t.Errorf("Want body to equal %q", "OK")
	}
}
```

### Testing Middleware

It’s also possible to use the same general technique to unit test your middleware -- demonstrate by creating a `TestSecureHeaders`test for the `secureHeaders`middleware -- 

```go
func TestSecureHeaders(t *testing.T) {
	// Initialize a new httptest.ResponseRecorder and dummy http.Request
	rr := httptest.NewRecorder()

	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Create a mock HTTP handler that can pass to our secureHeaders
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})

	secureHeaders(next).ServeHTTP(rr, r)

	// call the Result() method on the http.ResponseRecorder to get the result
	rs := rr.Result()

	frameOptions := rs.Header.Get("X-Frame-Options")
	if frameOptions != "deny" {
		t.Errorf("Want %q, got %q", "deny", frameOptions)
	}

	// check that the middleware has correctly set the other header like:
	xssProtection := rs.Header.Get("X-XSS-Protection")
	if xssProtection != "1; mode=block" {
		t.Errorf("Want %q, got %q", "1; mode=block", xssProtection)
	}

	// check that the middleware has correctly called the next handler in line
	// and the response status code and body are as expected
	if rs.StatusCode != http.StatusOK {
		t.Errorf("want %d, got %d", http.StatusOK, rs.StatusCode)
	}

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}

	if string(body) != "OK" {
		t.Errorf("want body to equal %q", "OK")
	}
}
```

So, in summary, a quick and easy to unit test your http handlers and middleware is to simly call them using the `httptest.ResponseRecorder`type. U can just then examine the status code, headers and response body of the recorded response to make sure that they are working as expected.

### Running Specific Tests

It’s possible to only run specific tests by using the `-run`flag, this allows you pass in a regular expression, and only tests with a name matches the regular expression will be run -- like:

```sh
go test -v -run="^TestPing$" ./cmd/web/
```

Can even use the `-run`flat to limit testing to some speciifc sub-tests fore:

```sh
go test -v -run="^TestHumanDate$/^UTC|CET$" ./cmd/web
```

Not -- when it comes to running specific sub-tests, the vlaue of the `-run`flag contains multiple regular expressions just separated by `/`character?The first part need to match the name of the test, and the second part needs to match the name of the sub-test.

#### Parallel Testing - 

By default, the `go test`command executes all tests in a serial manner, one after another, when U have a small number of tests and the runtime is fast, this is absolute fine. But fore have .. tests the total run time can start adding up to something more meaningful - and in that scenario, may save yourself some time by running the tests in parallel. Can just indicate a test to run in concurrently alongside other tests by calling the `t.Parallel()`function at the start of the test -- fore:

```go
func TestPing(t *testing.T){
    t.Parallel()
    //...
}
```

- Tests marked using `t.Parallel()`will be run in parallel with and only with other parallel tests.

And the `go test`command  includes a `-race`flag which enables Go’s race detector when running tests. And it’s important to point out that the race detector is just a tool that flags data race if and when they occur at runtime.