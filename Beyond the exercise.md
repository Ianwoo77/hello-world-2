# Beyond the exercise

1. Events occur in either summer or winter Olympic gams, but not both. As a result, the `Season`level in our multi-index is often unnecessary -- like:

   ```python
   df = pd.read_csv('olympic_athlete_events.csv',
                   index_col=['Year', 'Season', 'Sport', 'Event'],
                   usecols=['Age', 'Height', 'Team', 'Year', 'Season', 'City', 'Sport', 'Event', 'Medal'])
   df = df.sort_index()
   df = df.reset_index("Season")
   df.loc[(slice(1980,2020), 'Tennis'), 'Height'].max()
   ```

2. In which city were the most gold medals awarded from 1980 onward -- 

   ```python
   df.loc[1980:].loc[lambda df: df['Medal']=='Gold', 'City'].value_counts()
   ```

3. How many glod medals were received by the US. since 1980 -- 

   ```python
   df.loc[1980:].loc[
       lambda df: (df['Team']=='United States') & (df['Medal']=='Gold'), 'City'
   ].count()
   ```

#### Pivot tables

Have seen how to use indexes to restructure our data, making it easier to retrieve different slices of the information it contains and hus answer particular questions more easily, but the questions we have been asking have all had a single answer -- often want to apply a particular aggregate function to many different combinations of columns and rows, one of the most common and powerful ways to accomplish this is with `pivot`table.

A pivot table allows us to create a new table from a subset of an existing data frame -- basic idea -- 

- Data frame contains two columns with categorical, repeating, no-hierarchical data
- data has a thrid column that is numeric
- Create a new data frame from those 3 columns

```python
g = np.random.default_rng(0)
df = pd.DataFrame(g.integers(0, 100, [8, 3]), columns=[*"ABC"])
df["year"] = [2018] * 4 + [2019] * 4
df["quarter"] = "Q1 Q2 Q3 Q4".split() * 2
```

So this table shows the sales of each product per year and quarter -- and you can just certainly understand the data if you look at it a certain way. But, what if we were interested in seeing sales figures for product A.

```python
df.pivot(index='quarter', columns='year', values='A')
```

1. `index`are unique values from quarter
2. `columns`are unque from year
3. `Values`are the mean of each year.

Here, the quarters are sorted -- in some cases, such as using month naems for your index, pass `sort=False`. What if more then one row has the same values for year and month-- by default, `pivot_table()`runs the `mean`on all values. Note that the `pivot`just cannot handle duplicate values for `index-column`combinations.

```python
df.pivot_table(index="quarter", columns="year", values="A", sort=False, aggfunc="sum")
```

#### Wide vs. narrow data

Talk briefly about data structure -- a data set can store its values in wide or narrow format -- A *narrow* is also called `long`or `tall`. These names reflect the dirction in which data set expands as we add more values to it. And a *wide* data set increases in width, it grows out, a narrow/long/tall increases in height, grows down.

#### Creating a pivot tble from a DF 

```python
pd.read_csv('sales_by_employee.csv').head()
```

For utility’s shake, convert the strings in the `Date`column to datetime objects with the `read_csv`'s `parse_date`paramter, after the change this important like:

```python
sales = pd.read_csv('sales_by_employee.csv', parse_dates=['Date'])
```

### The `pivot_table`method

Aggregates a column’s values and groups the results by using other column’s values. The word *aggregate* describes a summary computation that involves multiple values.

## How defer args and receivers are evaluated

A common mistake made by Go developers is not understanding how args are evaluated -- 

### Argument evaluation

To illustrate how args are evaluated with `defer` - work on a concrete example, a Func needs to call two functions `foo`and `bar`, meanwhile, has to handle a status regarding execution - fore:

- `StatusSuccess`if both no errors
- `StatusErrorFoo`if `foo`returns an error
- `StatusErrorBar`if `bar`returns an error

```go
const (
	StatusSuccess= "success"
	StatusErrorFoo="error_foo"
	StatusErrorBar="error_bar"
)

func f() error {
	var status string
	defer notify(status)
	defer incrementCounters(status)
	
	if err := foo(); err != nil {
		status = StatusErrorFoo
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

Here defer the calls to `notify`and `incrementCounter`using `defer`-- throughout this func, and depending on the execution path, update `status`accordingly. Note that -- however, if give this a try, see the regardless the execution path, `notify`and `incrementCount`are always be called with the same *empty* string -- 

NOTE -- the arguments are evaluated *right away* -- not once the surrounding function returns -- fore, called `notify(status)`and `incrementCounter(status)`as `defer`functions -- therefore, Go will delay these calls to be executed once once `f`returns with the current value of `status`at the stage we used `defer`, hence, at that moment, passing just a empty string. 

The first solution is to pass a pointer -- 

```go
defer notify(&status)
defer incrementCounters(&status)
```

Keep updating `status`depending on the cases, but now `notify`and `incrementCounter`just receiving a string pointer, using `defer`evaluates the args right away -- the address of the `status`-- if is modified throughout the func, but its address remains constant. Hence, if `notify`and `incrementCounter`uses the value referenced by the string pointer, it will work as expected.

There is another solution -- calling a closure as a `defer`statement -- fore:

```go
func main(){
    i := 0
    j := 0
    defer func (i int) {
        fmt.Println(i,j) // 0 1 cuz i evaluated immediately
    }(i)
    i++
    j++
}
```

Therefore, can use a closure to implement a new version of our function like:

```go
func f() error {
    var status string
    defer func(){
        notify(status)
        increment(status)
    }()
}
```

Here, wraps the calls to both `notify`and `incrementCounter`within a closure -- this closure references the `status`variable from the outside its body -- therefore, status is evaluted once the closure is executed, not when call `defer`. This solution also works and doesn’t require to change its signature. Just remember *args* passed to a `defer`function are evaluated right away -- but not the outside variables

#### Pointers and value receiver

A receiver can be either a value or a pointer, the same logic related to arg evaluaion applies when use the `defer`on a method -- the receiver is also evaluated immediately. here is an example that calls a method on a value receiver using `defer`but mutate this receiver afterward like:

```go
type Struct struct {
    id string
}

func (s Struct) print(){
    fmt.Println(s.id)
}

func main(){
    s := Struct {id: "foo"}
    defer s.print()
    s.id="bar"
}
```

For this, calling `defer`makes the receiver be evaluated immediately -- hence, `defer`delays the method’s execution with a struct contains an `id`field equal to `foo`. 

if the pointer is a recevier like:

```go
func (s *Struct) print(){
    fmt.Println(s.id)
}

func main(){
    s := &Struct {id: "foo"}
    defer s.print()
    s.id="bar"  // bar printed
}
```

So for this the receiver is also evaluated immediately, however, calling the method leads to copying the pointer receiver, hence, the changes made to the struct referenced by the pointer are visible.

## Error Management

- Understanding when to panic
- Knowing when to wrap an error
- Comparing error types and error values efficiently since Go
- Handling erros idiomatically
- Understanding now to ignore an error
- Handling errors in `defer`calls.

Error management is a fundamental aspect of building robust and observable applications -- and it should be as important as any other part of codebase. In Go, error management doesn’t rely on the traidtional `try/catch`mechanims as most programming languages -- 

### Panicking

In go, errors are usually managed by functions or methods that return an `error`type as the last parameter -- but some developers may find this approach surprising and be tempted to re-produce exception handling using `panic`and `receover`. Refresh about the concept of `panic`and when it’s considered appropriate or not to panic.

In Go, `panic`is just a built-in function that stops the ordinary flow:

```go
func main(){
    fmt.Println("a")
    panic("foo")
}
```

Once a panic triggered -- it continues up the call stack until either current has returned or caught with `recover`.

```go
func main(){
    defer func(){
        if r:= receover(); r != nil {
            fmt.Println("receover", r)
        }
    }()
    f()
}
func f(){
    fmt.Println("a")
    panic("foo")
    fmt.Println("b")
}
```

note that calling `recover()`to capture a goroutine panicking is only useful inside a `defer`function -- the function would return `nil`and have no other effect. This is cuz `defer`functions are also executed when the surrounding function panics.

Also note that calling `recover()`to capture a goroutine panicking is only useful inside a `defer func()`-- otherwise, the function would return a `nil`and have no other effect. This is cuz `defer`are also executed when the surrounding function panics.

tackle this question -- when is it appropriate to panic -- in go, `panic`is used to signal genuinely exceptional conditions, such as a programmer error. Fore, if we look at the `net/http`-- notice -- `WriteHeader()`-- like:

```go
func checkWriteHeaderCode(code int) {
    if code <100 || code >999 {
        panic(fmt.Sprintf("Invalid writerheader code %v", code))
    }
}
```

So, this func panics if the status code is just invalid, which is a pure programmer error.

Another based on a programmer error can be found in the `database/sql`-- like:

```go
func Register(name string, driver direver.Driver) {
    driverMu.Lock()
    defer driverMu.Unlock()
    if driver == nil {
        panic("sql: register dirver is nil")
    }
    if _, dup := drivers[name]; dup {
        panic("sql: register called twice for driver"+name)
    }
    dirver[name]=driver
}
```

for this, the function pancis if the driver is `nil`or has already been registered.

And, another use case in which to panic is when our application reuires a dependency but fails to initialize it. And in go, fore the `regexp`package exposes two functions to create a regular expcession from a string -- `Compile`and `MustCompile`-- the former returns a `*regexp`and an `error`, whereas the latter returns only a `*regexp`-- but panics in case of an error.

And panicking in go should be used sparingly, When have seen two prominent cases, one to signal a programmer error and another where our app fails to create a mandatory dependency. Hence , there are exceptional conditions that lead us to stop the application, in most other cases, error management should be done with a function that returns a proper `error`type as the last return argument.

## How Middleware works

can think of a Go web application as a chain of `ServeHTTP()`method being called one after another. Currently, when server receives a new HTTP request it calls the `ServeHTTP`-- this look up the relevant handler based on the request URL path -- and in turn calls the handler’s `ServeHTTP`method. The basic idea of middleware is to *insert* another handler into this chain. Fore the `http.StripPrefix()`func from *serving static files* -- which remove a specific prefix from the request’s URL path -- 

#### Pattern 

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        // todo. execute our middleware logic 
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

- The `myMiddlewware()`is essentially a wrapper around the `next`handler.
- Establishes a func `fn`closes over the `next`handler to form a closure -- when `fn` is run it executes our middleware logic and then transfers control to the `next`handler by calling it’s `ServeHTTP()`.
- regardless of what you do with a closure it will always be able to access the variables that are local to the scope it was created in.
- Can convert this to a `http.Handler`and return it using the `http.HandlerFunc()`adapter.

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        //.. TODO:
        next.ServeHTTP(w, r)
    })
}
```

Note that this pattern is very common in the wild.

#### Positioning the Middleware

It’s important to explain that where u position the middleware in the chain of handlers will affect the behavior -- like:

myMiddleware() => ServeMux => App handler

Typically sth you would want to do for *all* requests.

Alternatively, can position the middleware after the servemux -- like:

servemux -> myMiddlewre -> application handler

### Setting security headers

like:

```go
func secureHeaders(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
        w.Header().Set("X-XSS-Protection", "1; mode=block")
        w.Header().Set("X-Frame-Options", "deny")
        next.ServeHTTP(w, r)
    })
}
```

Then in the `routes.go`file -- 

```go
func(app *application) routes() http.Handler {
    mux := http.NewServeMux()
    mux.HandleFunc("/", app.home)
    //...
    fileServer := http.FileServer(http.Dir("./ui/static"))
    mux.Handle("/static/", http.StripPrefix("/static", fileServer))
    
    // Pass the servemux as the next parameter to the secureHeaders middleware
    // cuz the secureHeaders is just afunc
    return secureHeaders(mux)
}
```

#### Flow of control

It’s important to know that when the last handler in the chain returns -- *control is passed back up the chain in the reverse direction*.
secureHeaders -> serveMux -> app handler -> serveMux -> secureHeaders

In many middleware handler, code which comes before the `next.ServeHTTP()`will be executed on the wy down the chain -- and any code after the `next.ServeHTTP()`-- on a deferred, will be executed on the way up. like:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // any code here will execute on the way down the chain
        next.ServeHTTP(w, r)
        // any code here will execute on the way back up the chain
    })
}
```

#### Early returns

Another thing to mentaion is that if you call `return`in your middleware function *before* U call `next.ServeHTTP()`, then the chain will stop being executed to control will flow back upstream. As an example, a common use -case for early return is authentication middelware which only allows execution of the chain to continue if a particlar check is passed. Fore:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // if the suer isn't authorized 
        if !isAuthorized(r) {
            w.WriteHeader(http.StatusForibdden)
            return
        }
        return ServeHttp(w,r)
    })
}
```

### Request logging

Continue in the same vein and add some middleware to *log HTTP requests* -- specially, going to use the information logger that created to record the IP address of the user like:

```go
func (app *application) logRequest(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr, r.Photo...)
        next.ServeHTTP(w,r)
    })
}
```

This is perfectly valid to do -- our middleware method has the same signature as before, but cuz it is a method against the `applitcation`it also has to access to the handler . Just:

`return app.logRequest(secureHandlers(mux))`

### Panic Receovery -- 

In the simple go app, when your code panics it will result in the application being terminated straight away -- before our web app is bit more sophisticated -- Go’s HTTP server assumes that the effect of any panics is isolated to the goroutine serving the active HTTP request -- every reque