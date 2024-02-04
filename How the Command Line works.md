# How the Command Line works

CLI -- text-based environment for interacting with computer -- 

1. Read some input
2. Evaluates that input
3. Prints some output to the screen in response, then
4. loops back to the beginnig to repeat the process.

### Command-Line syntax

```sh
command [-flags,] [--example=foobar] [even_more_options ...]
```

- Items in the brackets are optional
- -flags means any valid options

Usually by single - vs --, so `-l`and `--long`might do the same thing. Note that it’s not consistent across commands. Not all commands will implement all these ways of passing configuration when invoking them.

Command line vs. shell -- A shell is a specific program that *implements this command-line environment* and lets you just give it text commands.

After *reading* in a command, the shell needs to evaluate it -- by executing a program, fetching some info, or doing sth else that is actually useful to you.

1. If command has a path specified fore, The path may be based on variables and symbols either in -- like: `$HOME/foobar`or `~/foobar`.
2. checks to see whether it knows that `foobar`means built-in or alias
3. generally looks at the `$PATH`environment variable, which contains a few diferent locaitons to check for commands. like `/bin`, `/usr/bin`and `/sbin`.

### ls - list

Lets U list the files in a directory -- `-l `for long and `-h`for human-readable. `find`allows to search for files, fore:

```sh
find / -type d -name home
```

Search `/`for a directory `-typd d`with the name `home`-- keep in mind that when are not executing as the all-power root -- `find`will not have permissions to list the contents of many directories.

```sh
find . -exec echo {} \;
```

This will run echo with any found files in place of {}, the result will be much like invocation of `ls`-- want to pass them as argument to `echo`, can replace + instead of `\`. like:

```sh
find . -exec echo {} +;
```

```sh
# search but icase
find -iname foobar
find -name "foobar*" # start wiht foobar
find -name "*foobar" # end with
```

## Working with missing data

Pandas uses different sentinel values to represent a missing depending on the data type. `numpy.nan`for Numpy data types -- the disadvantage of using Numpy data type is that the original data dtype will be cocreced to `np.float64`or `object`.

```python
pd.Series([1,2], dtype=np.int64).reindex([0,1,2])
```

And `NaT`for numpy `np.datetime64`and `np.timedelta64`just like:

```python
pd.Series([1,2], dtype=np.dtype('timedelta64[ns]')).reindex([0,1,2])
```

`NA`for `stringDtype`, `Int64Dtype`fore:

```python
pd.Series([1,2], dtype='Int64').reindex([0,1,2]) # <NA> output
```

To detect these missing value, use the `isna()`or `notna()`methods.

### NA semantics

Starting from 1.0, an experimental `NA`is available to represent scalar missing values.

```python
pd.Series([1,2,None], dtype="Int64")
```

The pandas `GroupBy`object is a storage container for grouping Df rows into buckets -- It provides a set of methods to aggregate and analyze each independent group in the collection -- It allows us to extract rows at specific index positions within each group -- also offers a convenient way to iterate over the groups of rows.

```python
food_data = {
    "Item": ["Banana", "Cucumber", "Orange", "Tomato", "Watermelon"],
    "Type": ["Fruit", "Vegetable", "Fruit", "Vegetable", "Fruit"],
    "Price": [0.99, 1.25, 0.25, 0.33, 3.00],
}
```

For this, the `Type`column identiries the group to which an Item belongs, there are two groups of items in the supermarket data set - fruits and vegetables. The `GroupBy`object organizes `DataFrame`, for this, if isolate the `Fruit`rows and `Vegetable`into sepearate groups, easier to perform the calculations.

```python
groups= pd.DataFrame(food_data).groupby('Type') # return a `DataFrameGroupBy`
```

The `Type`column has two unique values, so the `GroupBy`object will store two groups -- The `get_group()`method accepts a group name and returns a `DataFrame`with the corresponding rows like:
`groups.get_group('Fruit')`-- Can also pull out th `Vegetable`

The `GroupBy`object excels the aggregate operations, goal was to calcualte the average price of the fruits and vegetables in supermarkets -- can invoke the `mean`method on `groups`to calculate the average price of items within eah group. `groups.mean(numeric_only=True)`

### Creating a GroupBy object from a data set -- 

For this df, a sector can have many companies -- Apple.. both belong to the `Technology`sector, fore -- an industry is a subcategory within a sector, -- the `Sector`column holds 21 unique sectors, Suppose that want to find the average revenue across the companies within each sector.

```python
in_retailing = fortune['Sector']=="Retailing"
retail_companies= fortune[in_retailing]
retail_companies.head()
```

Can also pull the column from the subset by using -- `retail_companies['Revenues']`. Finally, can calculate the Retailing sector’s average revenue by invoking the `mean`method on the `Revenues`. And inovke the `groupby`method on the DF -- the method accepts the column whose values pandas will use to group the rows. A column is a good candidates for a grouping if stores categorical data.

```python
sectors = fortune.groupby('Sector')
```

A `DataFrameGroupBy`is a *bundle* of `DataFrames`. Behind the scenes, pandas repeated the extraction process we used for the `Retailing`sector but for all 21 values in the `Sector`column.

```python
len(sectors) # return 21 for groups number
fortune.Sector.nunique() # also 21 for unique value
sector.size() # return how many companyes from belong
```

### Attributes and methods of the GroupBy object

One way to visualize our object is as a dictionary that maps the 21 sectons to a collection of fortune row belonging to each one. The `groups`attribute stores a dict with these *group-to-row* associations. its keys are sector names, and its values are `Index`objects storing the row index position fro the fortune `DataFrame`.

```python
sectors.groups
```

Output tells us that rows with index position ... and so on have a value of in fortune’s Sector column. Can:

```python
fortune.loc[26, 'Sector']
```

What if want to find the highest-performing company -- like:

```python
sectors.first()
sectors.last() # extracts the last company from group belongs to each sector
```

The `GroupBy`object assigns index position to the rows in each sector group. The `nth()`method extracts the row at a given index position within its group. If invoke the `nth`method with an arg of 0, we get the first company within each sector. `sectors.nth(0)`.. `sectors.nth(3) sectors.get_group('Energy').head()`

## Go contexts

Developers sometimes misunderstand the `context.Context`-- despite being one of the key concepts of the language and a doundation of concurent code in Go.

According to the official documentation -- A Context carries a deadline, a cancellation signal, and other values *across API boundaries*.

### Deadline

A deadline refers to a specific point in time determined with one of the following -- 

- A `time.Duration`from row
- A `time.Time`

The semantics of a deadline convey that an ongoing activity should be stopped if this deadline is met -- An activity is, fore, an `I/O`request or goroutine waiting to receive a message from a channel. Like:

```go
tpye publisher interface{
    Publish(ctx context.Context, position flight.Position) error
}
```

For this, accepts a context and potioin -- assume that the concrete implementation calls a function to publish a message to a broker -- is `context`aware -- meantin it can cancel a request once the context is canceled. like:

```go
type publishHandler struct {
    pub publisher
}
func (h publishHandler) publishPosition(position flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Backgroud(), 4* time.Second)
    defer cancel()
    return h.pub.Publish(ctx, position)
}
```

This code creates a context using `context.WithTimeout()`-- accepts a timeout and a context -- we create one from an *empty* context with `context.Background()`-- meanwhile, `context.WithTimeout()`returns two variables -- the context created and an cancellation `func()`function that will cancel the context once called. Passing the context created to the `Publish`method should make it return in at most 4 seconds. Internally, `context.WithTimeout()`creates a goroutine that will be retained in memory for 4 seconds or until `cancel`is called. Therefore, calling `cancel`is a `defer`means that when exit the parent function, the context is cancleed, and the goroutine created will be stopped.

### Cancellation signals

Another use case for go context is to carry a cancellation signal -- like: `CreateFileWather(ctx context.Context, filename string)`-- within another goroutine -- this creates a specific file wather that keep reading from a file and catches updates. then the provided context expires or is cancled, this function handlers it to close the file descriptor. A possible approch is use `context.WithCancel()`-- which returns a context that will cance once the `cancel`is called:

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    go func(){
        CreateFileWather(ctx, "foo.txt")
    }()
}
```

For this, when `main`returns, it calls the `cancel`function to cancel thecontext passed to the `CreateFileWatcher`so that the file descriptior is closed gracefully.

### Context values

The last use case for Go context is to carray a k-v list -- before understanding the rationale behind it, first see how to use it -- A context conveying values can be created in this way -- 

`ctx := context.WithValue(parentCtx, "key", "value")`

`context.WithValue`is created from a parent -- create  new ctx context contaiing he same characteristics as `parentCtx`but also conveying a key and a value. like:

```go
ctx := context.WithValue(context.Background(), "key", "value")
fmt.Println(ctx.Value("key"))
```

The key and values provided are `any`type.

```go
type key string
const isValidHostKey key ="isValidHost"
func checkValid(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        validHost := r.Host=="Acme"
        ctx := context.WithValue(r.Context(), isValidHostKey, validHost)
    })
}
```

### Catching a context Cancellation

The `context.Context`type exports a `Done`method that returns a receive-only notification `channel <-chan struct{}`-- is closed when the work associated wtih the context should be canceled -- 

- The `Done`channel related to a context created with the `context.WithCancel()`is closed when the `cancel()`is called
- The `Done`channel related to a context related to the `context.WithDeadline`is closed when the deadline has expired.

Furthermore, `context.Context`exports an `Err`method that returns `nil`if the `Done`channel isn’t yet closed.

```go
func main(){
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    urls := []string {...}
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
        results <- "..."
        return
    }
    
    client := http.DefaultClient
    resp, err := client.Do(req)
    if err != nil {
        results <- "...error message ..."
        return
    }
    defer resp.Body.Close()
    //... output
}

// timeout fore:
func main() {
    ctx, cancel:= context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()
    go performTask(ctx)
    select {
        case <-ctx.Done():
        fmt.Println("Time out")
    }
}

func performTask(ctx context.Context){
    select {
        case <-time.After(5*time.Second):
        fmt.Println(...)
    }
}

// with value:
func main(){
    ctx := context.Background()
    ctx = contxt.WithValue(ctx, "UserID", 123)
    go performTask(ctx)
}
func performTask(ctx contxt.Context) {
    userID := ctx.Value("UserID")
    fmt.Println(...)
}

// cancelling context
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    go performTask(ctx)
    time.Sleep(2* time.Second)
    cancel()
    time.Sleep(time.Second)
}
func performTask(ctx context.Context) {
    for {
        select {
        case <- ctx.Done():
            fmt.Println("Canceled")
            return
        default:
            // perform task operation
            fmt.Println("performing task...")
            time.Sleep(500* imte.Millisecond)
        }
    }
}
```

Furthermore, `context.Context`exports an `Err()`method that returns `nil`if the `Done`channel isn’t yet closed, it returns a non-nil error explaining why the `Done`channel was closed.

- A `context.Canceled`error if the channel was canceled
- A `context.DeadlineExceeded`error if the context’s deadline passed see :

```go
func handler(ctx context.Contxt, ch chan Message) error {
    for {
        select{
        case msg:= <-ch:
            
            // Done() channel related to context with `context.WithCancel()`closed when the 
            // `cancel` is called or with `context.WithDeadline`closed wehn the deadline has expired.
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

For this, created a `for`and `select`with two cases -- receiving messages from `ch`or receiving a signal that the context is done and we have to stop our job.

### Implementing a func that receives a context

Within a function that receives a context conveying a possible cancellation or timeout, the action of receiving or sending a message to a channel shouldn’t be done in a blocking way, fore:

```go
func f(ctx context.Context) error {
    // ... 
    select {
        case <- ctx.Done():
        return ctx.Err()
        case ch1<- struct{}{}:
    }
}
```

## Testing HTTP Handlers

Move on and discuss some specific technique for unit tests -- All the handlers that we have written for our proj so far are a bit complex to test -- following -- handlers.go to create a new `ping`handler which just simply returns 200 ok 

```go
func ping(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("OK"))
}
```

For this, create a new `TestPing`for --

- Checks that the response status code written by the `ping`handler is 200
- Checks the response body written by the `ping`is `OK`

Recording Responses -- To assist in testing your HTTP handlers, go provides the `net/http/httptest`package, which contains a suite of useful tools -- like `httptst.ResponseRecorder`type -- essentially an implmementation of the `http.ResponseWriter`which record the response status code, headers and body

```go
func TestPing(t *testing.T) {
    rr := httptest.NewRecorder() // initialize a new httptest.ResponseRecorder
    
    // need to initialize a dummy http.Request like
    r, err := http.NewRequest(http.MethodGet, "/", nil)
    if err != nil {
        t.Fatal(err)
    }
    
    // call the ping 
    ping(rr, r)
    
    // call the Result() on the http.ResponseRecorder to get the 
    // http.Response generated by the ping handler
    rs := rr.Result()
    
    if rs.StatusCode != http.StatusOK{
        t.Errof(...)
    }
    
    defer rs.Body.Close()
    body, err := io.ReadAll(rs.Body)
    if err != nil {
        t.Fatal(err)
    }
    if string(body)!="OK" {
        t.Errorf(...)
    }
}
```

### Testing middleware

Also possible to use the same general technique to unit test your middleware -- demonstrate by creating a `TestSecureHeaders`test for the `secureHeaders`middleware -- 

```go
func TestSecureHeaders(t *testing.T) {
    rr := httptest.NewRecorder()
    r, err := http.NewRequest(http.MethodGet, "/", nil)
    if err != nil {
        t.Fatal(err)
    }
    
    // then create a mock HTTP handler
    next := http.HandlerFunc(func(w httpResponseWriter, r *http.Request) {
        w.Write([]byte("OK"))
    })
    
    secureHeaders(next).serveHTTP(rr, r)
    
    // call the Result() on the `http.ResponseRecorder`to get the results of the test
    rs := rr.Result()
    
    // check the `Result()` method on the http.ResponseRecorder to get the results of the test
    frameOptions := rs.Header.Get("X-Frame-Options")
    if frameOptions != "deny" {
        t.Errorf(...)
    }
    
    xssProtection := rs.Header.Get("X-XSS-Protection")
    if xssProtection != "..." {
        t.Errorf(...)
    }
    
    defer rs.Body.Close()
    body, err := io.ReadAll(rs.Body)
    if err != nil {
        t.Fatal(err)
    }
}
```

### Running specific Tests -- 

It’s possible to only run specific tests by using the `-run`flag, this allows you to pas in a REGEXP like:

```sh
go test -v -run="^TestPing$" ./cmd/web/
```

can use the `-run`to limit testing to some specific sub-tests like:

```sh
go test -v -run="^TestHumanDate$/^UTC|CET$" ./cmd/web
```

### Parallel Testing

By default, the `go test`command executes all tests in a serial manner, one after another when have a small number of tests and the runtime is very fast -- absolutely fine -- if have hundreds of thousands of tests of total run time we can start adding up to something more meaningful -- can indicate that it’s ok for a test to be run in concurrently alongside other tests by calling `t.Parallel()`method at the start of the test.

- Tests marked using the `t.Parallel()`will run in parallel with and only with other parallel tests.
- By default, the maximum number of tests that will be run simultaneously is the current value of `GOMAXPROCS`

Enabling the Race Detector -- The `go test`command includes a `-race`flag which enables Go’s *race detector* when running tests. like `go test -race ./cmd/web/`

### End-To-End Testing

Most of the time, -- your http handlers are not actually used in isolation. so in this going to explain how to run end-to-end tests on your web app that emcompass your routing, middleware and handlers. Adapt the `TestPing`functin so that it runs an *end-to-end* test on your code, specifically, want the test to ensure that a `GET /ping`request to our app calls the `ping`and results in a 200ok.

Using `httptest.Server`-- The key to end-to-end is the `httptest.newTLSServer()`func. which spins up a `httptest.Server`instance can make HTTPs request to. The whole pattern is best to write the ode and then talk through the details afterwards.