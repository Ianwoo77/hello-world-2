# Cancellation Signals

Another use case for Go contexts is to carray a cnacellation signal -- image that we want to create an applicaiton that calls `CreateFileWather(ctx context.Context, filename string)`-- within another goroutine -- This function creates a specific file wather that keeps reading from a file and catches updates. When the provided context expires or is canceled, this func handles it to close the file descriptor. Finally, when `main`returns, we want things to be handled gracefully by closing this file descriptor -- 

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    go func() {
        CreateFileWather(ctx, "foo.txt")
    }()
}
```

When the `main`returns, it calls the `cancel`to cancel the context passed to `CreateFileWatcher()`so that the file descriptor is closed gracefully.

#### Context Values

The last use case for Go context is to carray a key -- value list -- before understanding the see -- like:
`ctx := context.WithValue(parentCtx, "key", "value")`

Just like the `WithTimeout...`, `context.WithValue()`is created from a parent contxt, in this case, create a new `ctx`context containing the same characteristics as a `prentCtx`but also conveying a key and a value. The key and values provided are `any`types -- indeed, for the value, we want to pass `any`types -- For the key -- that could lead to collisions -- two functions from different packages could use the same string value as a key -- so:

```go
package provider
type key string
const myCustomKey key= "key"
func f(ctx context.Context) {
    ctx = context.WithValue(ctx, myCustomKey, "foo")
}
```

For this, the `myCustomKey`constant is unexported, -- hence, there is no risk that another pacakge using the same context could override the value that is already set.

Another example is if we want to implement an HTTP middleware, if -- like:

```go
type key string
const isValidHostKey key = "isValidHost"
func checkValid(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        validHost := r.Host== "acme"
        ctx := context.WithValue(r.Context(), isValidHostKey, validHost)
        next.ServeHTTP(w, r.WithContext(ctx)) // r.WithContext used
    })
}
```

First, define a specific context key called `isValidHostKey`, then the `checkValid`middleware just checks whether the source host is valid, this informatino is conveyed in a new context, passed to the next HTTP setup using the `next.ServeHTTP`.

#### Catching a context Cancellation

And the `context.Context`type expots a `Done()`method that returns a receive-only notification channel: `<-chan struct{}`-- This channel is closed when the network assocaited with the context should be canceled.

- The `Done`channel related to a context created with the `context.WithCancel`is closed when the `cancel()`called
- Releated to a context created with `context.WithdDeadline()`is closed when the deadline has expired.

One thing to note is the the internal channel should be closed when a context is canceled or has met a deadline -- instead of when it receives a specific value -- cuz the closure of a channel is the only channel action that all the consumer goroutines will receive. This way, note that **all the consumers** will be notified once a context is canceled or a deadline is reached.

- `context.Canceled`error if the channel has canceled
- `context.DeadlineExceeded`error if the context’s deadline passed

```go
func handler(ctx context.Context, ch chan message) error {
    for {
        select {
        case msg: <- ch:
            //... do sth
        case <-ctx.Done():
            return ctx.Err()
        }
    }
    return nil
}
```

Using Go 1.23

```go
// Initialize a new logger which writes message to the standard out stream
logger := slog.New(slog.NewTextHandler(os.Stdout, nil))

type application struct {
    config config
    logger *slog.Logger
}
srv := &http.Server{
    Addr:         fmt.Sprintf(":%d", cfg.port),
    Handler:      app.routes(),
    IdleTimeout:  time.Minute,
    ReadTimeout:  10 * time.Second,
    WriteTimeout: 30 * time.Second,
    ErrorLog:     slog.NewLogLogger(logger.Handler(), slog.LevelError),
}
//...
// start the HTTP server
logger.Info("starting server", "addr", srv.Addr,
            "env", cfg.env)
os.Exit(1)
```

### Choosing a router

In this, are just going to use the popular 3rd-party package `httprouter`as the route for our app. Instead of using `http.ServeMux`for the stdlib -- 

- Want the API to consistently send JSON responses wherever possible. Fore `http.ServeMux`-- sends plain-text only 404 and 405 responses with a matching route cannot be found. using some JSON reasons for this job.
- Additionally, `http.ServeMux`does not automatically handles `OPTIONS`.

Both of these things are supported by `httprouter`-- along with providing all the other functionlaity that we need. The package itself is stable and well-tested.

#### Creating a helper to read ID parameters

The code to extract an `id`parameter from a URL like `/v1/movies/:id`is sth like need repeatedly in our app -- so just abstract the logic for this into a small reusable helper method -- like:

```go 
func (app *application) readIDParam(r *http.Request) (int64, error) {
    params := httprouter.ParamsFromContext(r.Context())
    id, err := strconv.ParseInt(params.ByName("id"), 10, 64)
    if err != nil || id<1 {
        return 0, errors.New("Invalid id parameter")
    }
    return id, nil
}
```

The `readIDParam()`here doesn’t use any dependencies from ur `application`struct so it could just be a regular function, rather than a method on `application`. But in general, -- Suggesting settup all your application-speicifc handlers and helpers so that they are methods on `application`. It helps maintain consistency in your code structure, and also furture-proofs your code for when those handlers and helpers change later and they *do* need access to a dependency. When this helper method in place, the code in the code can now be made simpler like:

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Request) {
    id, err := app.readIDParam(r)
    if err!= nil {
        http.NotFound(w,r)
        return
    }
    fmt.Fprintf(w, "Show the details of movie %d\n", id)
}
```

#### Confilicting routes

It’s important to be aware that `httprouter`doesn’t allow *conflicting routes* which potentially matches the same request -- so fore, U cannot register a route like `GET /foo/new`and another like `GET /foo/:id`.

### Sending JSON respononses

Going to update our API handlers so that they return JSON responses instead of jsut plain text --  Fixed-format json -- Can write a JSON responses from your Go handlers in the same way that you could write any other text response. The only speicial thing we need to do is set a `Content-Type: application/json`header on the response. fore;

```go
func (app *application) healthHandler(w http.ResponseWriter, r *http.Request) {
    js := `{"status": "available", "environment":%q, "version":%q}`
    js = fmt.Sprintf(js, app.config.env, version)
    w.Header().Set("Contenty-Type", "application/json")
    // write to the response
    w.Write([]byte(js))
}
```

### JSON Encoding

At a high-level, Go’s `encoding/json`package provides two options for encoding things to JSON, can either call the `json.Marshal()`or use a `json.Encoder`type.

```go
func(app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
    data := map[string]string{
        "status": "avaliable",
        "environment": app.config.env,
        "version": version,
    }
    js, err := json.Marshal(data)
    if err != nil {
        app.logger.Error(err.Error())
        http.Error(w, "The server encountered a problem", http.StatusInternalServerError)
        return
    }
    js = append(js, '\n') // append a newline, just a small nice
    w.Header().Set("Content-type", "application/json")
}
```

#### Creating a `writeJSON()`helper method

As API grows, going to sneding a lot of JSON responses -- so it makes sense to move some of this logic into a reusable `writeJSON()`helper method.

```go
func (app *application) writeJSON(w http.ResponseWriter, status int, data any,
                                  headers http.Header) error {
    js, err := js.Marshal(data)
    if err != nil {
        return err
    }
    js = append(js, '\n')
    
    // safely to add any headers to the header map.
    for key, value := range headers {
        w.Header()[key]=value
    }
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    w.Write(js)
    return nil
}
```

#### how different Go types are encoded

In this - Have been encoding a `map[string]string`type to JSON, which resulted in JSON object with JSON strings as values in the key/value pairs -- but Go supports encoding many other native types too. Just note these:

- Go `time.Time`-- will  be encoded as a JSON string -- in RFC 3339 format.
- `[]byte`slice will be encoded as a *base64-encoded* JSON string.
- Any pointer values will be encodes as the *value pointed to*
- Channles, functions and `compelx`number types canont be encoded.

#### Using `json.Encoder`

As Go’s `json.Encoder`type peforming encoding -- allows to encode an object to JSON and write that to output stream in a single step.

```go
func (app *application) exampleHandler(w http.ResponseWriter, r *http.Request) {
    data := map[string]string{...}
    w.Header().Set("Content-Type", "application/json")
    err := json.NewEncoder(w).Encode(data)
    if err != nil {
        app.logger.Error(err.Error())
        http.Error(...)
    }
}
```

Just calls the `json.NewEnccoder(w).Encode(data)`the JSON is created and writtern to the `http.ResponseWriter`in a single step -- which means there is no opportunity to set HTTP response headers conditionaly based on the `Encode()`method.

Fore, that you want to set a `Cache-Control`header on a successufl response, but not to set `Cache-Control`header if the *JSON encoding fails* and you have to return an *error response*. Implementing that cleanly while using the `json.Encoder`pattern is quite difficult.

#### Perfomrance of `json.Encoder`and `json.Marshal`

You might be wondering if there is any performance difference between using `json.Encoder`and `json.Marshal()`--  Using iterators -- If like could update the `writeJSON()`function to use the `iterator`types and helper functions introduced in Go 1.23 -- Instead of using a regular `range`loop -- could leverge the geneirc `maps.All()`and `maps.Insert()`functions instead like:

```go
func(app *application) writeJSON(w http.ResponseWriter, status int,
                                 data envelope, headers http.Header) error {
    for key, value := range headers {
        w.Header()[key]=value
    }
}
// ... // using iterator maps in Go 1.23
maps.Insert(w.Header(), maps.All(headers))
```

Both the iterator version and the regular `range`will propably compile down to the same assemble code.

### Encoding Structs

Creating a new `internal/data`directory containing a `movies.go`file like:

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Response) {
    id, err := app.readIDParam(r)
    if err != nil {
        http.NotFound(w,r)
        return
    }
    movie := data.Movie {
        //...
        Genres : []string{"drama", "romance", "war"},
        version: 1,
    }
    err := app.writeJSON9w, http.StatusOK, movie, nil)
    if err != nil {
        //...
    }
}
```

#### Changing keys in the JSON Object

One of thenice things about encoding structs in Go is that you can customize the JSON by annotating the fields with `struct tags`. -- Probably the most common use of struct tags is to change the key names that appear  in the JSON object -- like:

```go
type Movie struct {
    ID int64 `json:"id"`
    //...
}
```

For the `-`can be used when you *never* want a particular struct field to appear in the JSON output -- This is useufl for fields that contain internal system information that isn’t revelant to your users. Fore:

```go
type Movie struct {
    ID int64 `json:"id"`
    CreatedAt time.Time `json:"-"`
    //...
    Runtime int32 `json:"runtime,omitempty,string"` // add the string directive
}
```

#### Formatting and enveloping responses -- 

Canmake these easier to read in terminals by using the `json.MarshalIndent()`function to encode our response data -- instead of the regular `json.Marshal()`function -- this automatically adds the whitespace to the JSON output, putting each element on a separaet line and prefixing each line with optional *prefix* indent characters.

```go
func(app *application) writeJSON(...) error {
    js, err := json.MarshalIndent(data, "", "\t")
    if err != nil {
        return err
    }
    js = append(js, '\n')
    for key, value := range headers {
        w.Header()[key]=value
    }
}
```

#### Enveloping responses

Enveloping responses data like this -- is not strictly necessary, and whether U choose to do so is partly a matter of style and taste. Fore -- 

1. Including a key name, fore `movie`at the top-level of the JSON helps make response more self-documenting
2. It reduces the risk of errors on the client side.
3. If we always envelope the data returned by our API, when we mitgate a *security vulenability* in older browser.

There are just couple of techniques -- going to keep thins simple and do it by creating a custom `envelope`map with the underlying the `map[string]any`type -- like:

```go
type envelope map[string]any
func (app *application) writeJSON(w http.ResponseWriter, status int, data envelope, 
                                  headers http.Header) error {
    js, err := json.MarshalIndent(data, "", "\t")
    if err != nil {
        return err
    }
    js = append(js, '\n')
    for key, value := range headers{
        w.Header()[key]=value
    }
    //...
    w.Write(js)
    return nil
}
// in the /api/movies.go file:
err = app.writeJSON(w, http.StatusOK, envelope{"movie": movie}, nil)
```

### Advanced JSON customization

By using struct tags, adding whitespace and enveloping the data, able to add quite a lot of customizaiton to our JSon resposnes -- When Go is encoding a particular type to JSON, it looks to see if the type has a `MarshalJSON()`method implemented on it. Just:

```go
type Marshaler interface{
    MarshalJSON() {[]byte, error}
}
```

Customizing the Runtime field -- like:

```go
type Runtime int32

func (r Runtime) MarshalJSON() ([]byte, error) {
    jsonValue := fmt.Sprintf("%d mins", r)
    quotedJSONValue := strconv.Quote(jsonValue)
    return []byte(quoteJSONValue), nil
}

// in the struct def:
type Movie struct {
    ID int64 `json:"id"`
    //...
    Runtime Runtime `json:"runtime,omitempty"`
}
```

Instead of creating a custom `Runtime`type -- could have implemented a `MarshalJSON()`on the `Movie`and customized the whole thing -- like:

```go
// Note that there are not struct tags for example
type Movie struct {
    Id int64 
    //...
}

func (m Movie) MarshalJSON() ([]byte, error) {
    var runtime string
    if m.Runtime!=0{
        //...
    }
    aux := struct {
        ID int64 `json:"id"`
        //... for DTO
        Runtime string `json:"runtime,omitempty"`
        //...
    }{
        ID: m.ID,
        Title: m.TItle,
        //...
    }
    return json.Marshal(aux)
}
```

#### Embedding an alias

The downside of the approach above that the code feels quite verbose and repetitive. U might -- To reduce dupliation, instead of writing out all the struct fields lone-hand -- it’s possible to embed an alias of the `Movie`struct like so:

```go
type Movie struct {
    ID int64 `json"id"` // not that for tag used
    //...
}
func (m Movie) MarshalJSON() ([]byte, error) {
    var runtime string
    if m.Runtime != 0 {
        runtime = fmt.Sprintf("%d mins", m.Runtime)
    }
    
    type MovieAslias Movie
    aux := struct {
        MovieAlias
        Runtime string `json:"runtime,omitempty"`
    }{
        MovieAlias: MovieAlias(m),
        Runtime: runtime,
    }
    return json.Marshal(aux)
}
```

On one hand, this approach is nice cuz it drastically cuts the number of lines of code and reduces repetition -- and if U have a large struct and only need to customize a couple of fileds it can be a good option -- like note that the `runtime`key will always now be the last item in the JSON object.

### Sending error Messages

At this point, our API is sending nicely formatter JSON responses for successful requests, but if a client makes a bad request -- or sth goes wrong in our app -- are still sending them a plain-text error message from the `http.Error()`and `http.NotFound()`functions.

Creating some additional helpers to manage errors and send the appropriate JSON responses to our clients.

```go
func (app *application) logError(r *http.Request, err error) {
    var (
    	method = r.Method
        uri = r.URL.RequestURI()
    )
    app.logger.Error(err.Error(), "method", method, "uri", uri)
}

func (app *application) errorResponse(w http.ResponseWriter, r *http.Request, status int,
                                      message any) {
    env := envelope{"error": message}
    err := app.writeJSON(w, status, env, nil)
    if err != nil {
        app.logError(r, err)
        w.WriteHeader(500)
    }
}

func (app *application) serverErrorResponse(w http.ResponseWriter, r *http.Request, err error) {
    app.logError(r, err)
    message := "the server encountered a problem"
    app.errorResponse(w, r, http.StatusInternalServerError, mesage)
}
```

And For the `NotFound`and `MethodNotAllowed`message.

#### Routing errors

Any error messages that our own API handlers send will now be well-formed JSON response. But what about the error messages that `httprouter`automatically sends when it can’t find a matching route -- by default, these will still be the same plain-text responses what saw. `httprouter`allows to set our own custom error handlers when we initialize the router. Just in the `routes()`method like:

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    // convert the helper to `http.Handler` using the `http.HandlerFunc()` adpater
    router.NotFound= http.HandlerFunc(app.NotFoundResponse)
    router.MethodNotAllowed = http.HandlerFunc(app.MethodNotAllowedResonse)
    //...
}
```

