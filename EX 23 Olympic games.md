# EX 23 Olympic games

In this, going to build a deep multi-index -- allowing to retreive data from various levels and in several ways -- Create a multi-index with four levels and then use those levels to ask and answer a variety of questions -- 

```python
df = pd.read_csv(
    "olympic_athlete_events.csv",
    index_col=["Year", "Season", "Sport", "Event"],
    usecols=[
        "Age",
        "Height",
        "Team",
        "Year",
        "Season",
        "City",
        "Sport",
        "Event",
        "Medal",
    ],
)
```

By passing a list of column to the `index_col`parameter, just create the multi-index while creating the data frame. Then will, use `sort_index`, which returns a new data frame containing the same data we read from the CSV file but with rows ordered according to the multi-index. Although we just don’t necessarily need to sort our data frame by its index, certain pandas operations will work better. Especially when we are doing operations with a multi-index, it’s good idea to sort by the index at the outset.

```python
df.loc[(slice(1936,2000), 'Summer'),'Age'].mean()
# calculating which team won the most medials
df.loc[(slice(None), 'Summer','Archery'),'Team'].value_counts()
```

This count *all* participants in archery events, we are only interested in the medialists - -can start our query by removing all rows in which `Medal`contains a NaN value.

```python
df.dropna(subset='Medal') \
    .loc[(slice(None),'Summer', 'Archery'), 'Team'].value_counts()
```

For this, cuz `value_counts()`sorts its value in descending order, can see the most medialists. Asked to find the average height -- like:

```python
df.loc[(slice(1980, None),
        'Summer',
        slice(None),
        "Table Tennis Women's Team"),
        'Height'].mean()
```

From 1980, and for the sport is so can specify that if we want to ,given tha all these events fall under the same sport.

Expand our population -- looking at not just the women’s team version of table tennis but also the men’s version like:

```python
df.loc[
    (
        slice(1980, None),
        "Summer",
        slice(None),
        ["Table Tennis Men's Team", "Table Tennis Women's Team"],
    ), 
    'Height'
].mean()
```

Finally, we are looking for the `Height`column, specify that in our query, and want the maximum value for `Height`, so use the `max`method like:

```python
df.loc[(slice(1980, 2016),
       'Summer',
       'Tennis'),
       'Height'].max()
```

Events occur in either summer or winter games, but not both, just like:

```python
df.reset_index('Season').loc[(slice(1980,2020),'Tennis'), 'Height'].max()
```

In which city were the most gold medials from 1980 -- 

```python
df.loc[1980:].loc[lambda data:data['Medal']=='Gold', 'City'].value_counts()
```

How many gold medias were received by the United States since 1980 -- 

```python
df.loc[1980:].loc[lambda df_: (df_['Team'] == 'United States') & (df_['Medal'] == 'Gold'), 'City'].count()
```

So far, have seen how to use indexes to restructure our data, making it easier to retreive different slices of the information it contains and thus answer particular questions more easily, but the questions we have been asking have all had a single answer -- we often want to apply a particular aggregate function to many different combinations of columns and rows -- one of the common and powerful ways to accomplish this is with *pivot* tables.

## Functions and methods

- When to use value or pointers receviers
- When to use named result parameters and their potential side effects
- Avoiding a common mistake while returning a `nil`receiver
- Why using functions that accept a filename isn’t best practice
- Handle `defer`arguments

### Which type of receiver to use

Choosing a receiver type for a method isn’t always straightforward. When should use value receiver, when use pointer receiver - In many contexts, using a value or pointer receiver should be dictated not by performance but rather by other conditions that -- In Go, attach either a value or a pointer receiver to a method. Go just makes a copy of the value and passes it to the method. like:

```go
type customer struct {
    balance float64
}

func (c *customer) add(opeartion float64) {
    c.balance+= operation
}
```

For -- a receiver *must* be a pointer -- 

- If the method needs to *mutate* the receiver, this rule is also valid if the receiver is a slice fore:

  ```go
  type slice []int
  func (s *slice) add(element int) {
      // append elements
      *s = append(*s, element)
  }
  ```

- If the method receiver contains a field that cannot be copied -- fore, a type part of `sync`package

And *must* be a value -- 

- If have to enforce immutability
- If receiver is a map, function, or channel, otherwise, compilation error

A receiver *should* be a pointer -- 

- If the receiver is large object. Using a pointer can make call more efficient, as doing so prevents making an extensive copy.

A receiver *must* be a value--

- If we have to enforce immutability
- If receiver is map, ...

A receiver *should* be a value -- 

- If the recever is a slice that doesn’t have to be mutated.
- If the receiver is a small array or struct is naturally a value type without mutable fields.
- If the receiver is just basic type such as `int, float64`or `string`.

```go
type customer struct {
    data *data 
}
type data struct {
    balance float64
} // balance is not part of the customer directly, is a struct referenced by a pointer field.

func (c customer) add(operation float64) {
    c.data.balance += operation // effective
}

func main(){
    c := customer {data: &data {balance: 100}}
    c.add(50.)
    fmt.Printf..
}
```

### Named result parameters

Named result parameters are an infrequently used option in Go -- this looks -- considered appropriate to use named result parameters to make our API more convenient. When return parameters in a func or a method, can attch names to these parameters and use them as regular variables -- when a result parameter is named -- it’s initialized to its **zero** value when the func/method begins. With named result parameters, can also call a named return statement.

So, when is it recommended that use named result parameters -- fore:

```go
type locator interface {
    getCoordinate(address string) (float32, float32, error)
}
```

For this, not unexported -- Can U guess that these two `float32`are -- Therefore, have to check the implementation to understand the results. In that case, should probably use named result parameters to make the coe easier to read:

```go
type locator interface {
    getCoordinate(address string) (lat, lag float32, err error) 
}
```

But, also, pursue the question of when to use named parameters with the method implementation -- like:

```go
func (l loc) getCoordinates(address string) (
    lat, lng float32, err error) {
    //...
}
```

In this specific case, having a expressive method signature can also help code readers, want to use named result parameters as well.

Consider another function signature that allows us to store a `Customer`type in dbs like:

```go
func StoreCustomer(customer Customer) (err error) {...}
```

for this, naming the `error`isn’t helpful and doesn’t help readers. In that case, should favor not using named result. So, when to use named result parameters depends on the context -- in most cases, if it is not clear using them makes our code more readable, shouldn’t use named result parameters.

But, also note that having the result parameters already initialized can be quite handy in some contexts, even though they don’t necessarily help readibility -- like:

```go
func ReadFull(r io.Reade, buf []byte) (n int, err error) {
    for len(buf)>0 && err == nil {
        var nr int
        nr, err = r.Read(buf)
        n += nr
        buf= buf[nr:]
    }
    return
}
```

For this, having named result doesn’t really increaase readability -- however, cuz both `n`and `err`initialized to their zero value, the implementatio is shorter.

### Side effects with named result parameters

As these result parameters are initialized to their zero value, using them can sometimes lead to subtle bugs. For the lat, cuz return 2 `float32`s, decide to use named result parameter to make the latitude and longitude explicit -- this will first validate the given addess and then get the coordinates. In the between, will perform a check on the input context to make sure it wasn’t canceled and its deadline hasn’t passed -- like:

```go
func (l loc) getCorrdinates(ctx context.Context, address string) (
    lat, lng float32, err error ) {
    isValid := l.validateAddress(address)
    if !isValid {
        return 0, 0, errors.New("invalid address")
    }
    if ctx.Err() != nil {
        return 0, 0, err // here, the problem raised
    }
    //...
}
```

Here, the error might be -- if `ctx.err()!= nil`return is `err`-- we haven’t assigned any value to the `err`variale -- it’s still assigne dto the zero value of an `error`type just `nil`. Furthermore, this code just compiles, cuz `err`was initialized to its zero value due to named result parameters. And one possible fix is to assign `ctx.Err()`to `err`like:

```go
if err := ctx.Err(); err != nil {
    return 0, 0, err
}
```

### Returning a `nil`receiver

In this, just discuss the impact of returning an interface and why doing so may lead to errors in some conditions. this mistake is propbabley one of the most widespread in Go, 

Consider the following example, will work on a `Customer`struct and implement a `Validate`method to perform sanity checks -- instead of returning the first error, want to return a list of errors -- to do that just:

```go
type MultiError struct {
    errs []string
}

func (m *MultiError) Add (err error) {
    m.errs = append(m.errs, err.Error())
}

func (m *Multierror) Error() string {
    return strings.Join(m.errs, ";")
}
```

For this, just satisfies the `error`cuz it implements `Error()`string -- meanwhile, it exposes `Add`method to append an error. Using this struct can implement a `Customer.Validate`method like: to check the age and name -- like:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age<0 {
        m = &MultiError{}
        m.Add(errors.New("age is negative"))
    }
    if c.Name== "" {
        if m== nil {
            m = &MultiError{}
        }
        m.Add(errors.New("name is nil"))
    }
    return m
}
```

For this, `m`is initialized to the zero value of `*MultiError`-- `nil`-- when a santiy checks -- allocate a new `MultiError`if needed and then append an `error`.

In go, have to know that a pointer recei er can be `nil`. Fore:

```go
type Foo struct{}
func (foo *Foo) Bar() string {
    return "bar"
}

func main(){
    var foo *Foo
    fmt.Println(foo.Bar()) // foo is just nil here
}
```

But this code compiles, and it prints `bar`when run. A nil pointer is just a valid receiver. In Go, a method is just syntactic sugar for a fuction whose first parameter is just a receiver. Know that passing a `nil`pointer to a function is correct, thus, using a `nil`pointer as a receiver is also valid.

For the struct of the function -- 

```go
func (c Customer) Valiate() error {
    var m *MultError
    if c.Age<0 {...}
    if c.Name == "" {}
    return m
}
```

Here, m is just initialized to zero `nil` -- then if all the checks are valid -- then just return a nil pointer. And cuz a nil pointer is just a valid receiver, converting the result like: Isn’t a nil directly but a *`nil`pointer*. And nil pointer is a valid receiver. To make it clear -- an interface is a dispatch wrapper -- for this, the wrapper is `nil`where as the wrapper isn’t. -- the error interface.

for this situation, regardless of the `Customer`provided, the caller of this func will alwys receive a non-nil error.

```go
func (c Customer) Valiate() error {
    var m *Multierror
    if c.Age<0 {
        ...
    }
    if c.Name= "" {
        //...
    }
    if m != nil {
        return m
    }
    return nil
}
```

At the end of the method, check whether `m`is not `nil`-- return `nil`directly not a nil pointer. seen in this that in Go, having a `nil`receiver is allowed, and an interface covered from a `nil`isn’t a `nil`interface. When have to return an interface, should return not a `nil`pointer but a `nil`value directly.

## Middleware

When building web app there is probably some shared functionality that want to use for many (even all) HTTP requests. Fore, might want to log every request, compress every response, or check a cache before passing the request to your handlers.

A common way of organizing this shared is to set it up as middleware -- essentially some *self-contained* code which independently acts on a request *before or after* your normal app handlers.

- An idiomatic pattern for *building and using custom middleware* which is compatible with `net/http`and many third-party packages
- How to create middleware which sets useful security headers on every HTTP response.
- How to create middleware which *logs the requests* received by your application
- How to create middlewre which *recovers panics* so that are gracefully handled by your application.
- How to create and use composable *middlew chains* to help manage and organize your middleware.

### How middleware works

A Go web app is a chain of `ServeHTTP()`methods being called one after another -- for app, when receives a new HTTP request, calls the `servemux`'s `ServeHTTP()`method -- looks up the revelant handler based on the request URL path, and in turn calls that handler’s `ServeHTTP()`method.

For the `http.StripPrefix()`func -- which removes a specific prefix from the request’s URL path before passing the request on to the file server.

#### The pattern

The std pattern -- like:

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        //...
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

- The `myMiddleware()`is essentially a wrapper around the `next`handler.
- It establishes a function `fn`which *closes over* the `next`handler to form a closure. When `fn`is run it executes our middleware logic and then transfers control to the `next`handler by calling it’s `ServeHTTP()`
- Regardless of what U do with it always be able to access the variables that are local to the scope created in. -- which in this case that `fn`will always have access to the `next`variable.
- When then convert the closure to a `http.Handler`and return it using the `http.HandlerFunc()`adapter.

#### Simplifying the middleware

A tweak -- just like:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w, r) {
        return next.ServeHTTP(w, r)
    })
}
```

#### Positioning the Middleware

It’s important to explain that where you position the middleware in the chain of the handlers will affect the behavior. If U position your middleware before the `servemux`in the chain, will act on every request. A good example of where this would be useful is middleware to log requests

Alternatively, can position the middleware after the servemux in the chain -- by wrapping a specific app handler.

`servemux-> myMiddleware-> app handler`

### Setting Security Headers

Put the pattern learned in the prevoius to use -- fore:

```sh
X-Frame-Options: deny
X-XSS-Protection: 1; mode=block
```

They essentially instruct the user’s web browser to implement some additional security measures to help prevent XSS and Clickjacking attcks.

```go
func securityHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-XSS-Protection", "1;mode=block")
		w.Header().Set("X-Frame-Options", "deny")
		next.ServeHTTP(w, r)
	})
}
```

Cuz want this middleware to act on every request that is received, need it to be executed *before* a request hits.

```go
func (app *application) routes() http.Handler {
	mux := http.NewServeMux()
	// ....

	return securityHeaders(mux)
}
```

#### Flow of control

It’s just important to know that when the last handler in this chain returns, control is passed back up the chain in the reverse direction -- so when our code is being executed the flow of control actually looks like:

secureHeaders -> serveMux -> application handler -> serveMux -> secureHeaders

In any middleware handler, code which comes before `next.ServeHTTP()`will be executed on the way down the chain, and any code after `next.ServeHTTP()`on in a deferred function will be executed on the way back up. Just:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Rquest){
        // any code here will execute on the way down the chain.
        next.ServeHTTP(w, r)
        // any code here will execute on the way back up the chain
    })
}
```

#### Early returns

Another thing to mention is that if you call `return`in your middleware function *before* you call `next.ServeHTTP()`, then the *chain will stop being executed* and control will flow back upstream.

As an example, a common use-case for early returns is authentication middleware which only allows execution of the chain to continue if a particular check is passed -- 

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        //...
        if !isAuthorized(r) {
            w.WriteHeader(...)
            return
        }
        //otherwise, call next
        next.ServeHTTP(w, r)
    })
}
```

### Request Logging

Going to use the *information logger* that we created earlier to record the IP address of the user, and which URL and method are being requested -- 

```go
func (app *application) logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr, r.Proto,
			r.Method, r.URL.RequestURI())
		next.ServeHTTP(w, r)
	})
}
```

Implementing the middleware as a method -- prefectly valid to do -- our middleware method has the same signature as before, but cuz it is a method against `application`it also has access to the handler dependencies including the info logger. `return app.logRequest(securityHeaders(mux))`

### Panic Recovery

In a simple Go app, when code panics, it will result in the application being terminated straight away -- but our app is a bit more sophisticated - Go’s HTTP server assumes that the effect of any panic is isolated to the goroutine serving the active HTTP request. Specifically, following a panic our server will log a stack trace to the server error log, unwind the stack for the affected gorotuine and close the underlying HTTP connection.