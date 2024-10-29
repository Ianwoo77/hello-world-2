# Propagating appropriate context

Contexts are omnipresent when working with concurrency in Go, and in many situations, it may be recommended to propagate them -- however, context propagation can sometimes lead to subtle bugs -- fore, exposes an HTTP handler that performs some tasks and returns a response. Just before returning the response, also want to send it an topic, fore, don’t want to penalize the HTTP consumer latency-wise, so want to the publish action to be handled async in a new goroutien.

```go
func handler(w http.ResponseWriter, r *http.Request) {
    resp, err := doSomeTask(r.Context(), r)
    if err != nil {
        http.Errors(w, err.Error(), http.StatusInternalServerError)
        return
    }
    go func() {
        err := publish(r.Context(), resp)
    }()
}
```

First call a `doSomeTask`func to get a resp variable, it’used within the goroutine calling `publish`and to format the HTTP response. Aslo when calling `publish`, propagate context attached to the HTTP request. Have to know that the context attached to an HTTP request can cancel in different conditions -- 

- When the client’s connection closes
- In the case of an HTTP/2 request, when the request is canceled
- When the response has been written back to client.

When the response has been written to the client, the context associated with the request will be canceled -- therefore, facing *a race condition*.

If the response is written after publication, return a response

If the response is witten before during the Kafka pub, the message shouldn’t be published. In this case, publish will return an error cuz we returned the http Response quickly. One idea is not propagate the parent context. insted, would call `publish` with an empty context like:

`err := publish(context.Background(), response)`

But, what if the context contained useful values -- fore, if the context contained a correlation ID used for distributed tracing, would correlate the HTTP request and the publication. The stdlib package doesn’t provide an immediate solution to this problem - implement your own Go context similar to the context provided - except it doesn’t carry the cancellatin signal like:

```go
// A context.Context is just an interface containing four methods
type Context interface {
    Deadline()
    Done() <-chan struct{}
    Err() error
    Value(key any) any
}
```

The context’s deadline is manged by the `Deadline`method and the cancellation signal is manged via the `Done`and `Error`method -- when a deadline has passed or the context hand been just canceled, `Done`should return a closed channel, whereas `Err`should return an error. Finally, the values are carried via tha `Value()`.

```go
type detach struct {
    ctx context.Context
}
func (d detach) Deadline() (time.Time, bool) {
    return time.Time{}, false
}
func (d detach) Done() <-chan struct {} {
    return nil
}
func (d detach) Err() error {
    return nil
}
func (d detach) Value(key any) any {
    return d.ctx.Value(key)
}
```

For this, except the `Value()`method that calls the parent to retrieve a value, the other methods return a default value so the context is never considered expired or canceled. 

## Panic receovery

At the moment any panics in our API handlers will be just recovered automatically by Go’s `http.Server`-- This will unwind the stack for the affected goroutine -- close the underlying HTTP connection, and log an error message and stack trace -- This behavior is OK, but it would be better for the client if we could also send a 500 internal server error response to explain that something has gong wrong, rather than just closing the HTTP connection with no context.

Following along and got ahead and create `middleware.go`file like:

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// create a deferred function
		defer func() {
			// use the built-in function to check if there has been a panic or not
			if err := recover(); err != nil {
				// if there was a panic -- set a `Connection:close` header on the response --
				// this acts as a trigger to make Go's HTTP server automatically close
				// the current connection after a response has been sent.
				w.Header().Set("Connection", "close")

				// Then, the value returned by recover() has the type any
				// so using fmt.Errorf() to normalize it into an error and call our
				// ServerErrorResponse() helper.
				app.serverErrorResponse(w, r, fmt.Errorf("%s", err))
			}
			next.ServeHTTP(w, r)
		}()
	})
}
```

Once that is done, need to update our `cmd/api/routes.go`file so that the `recoverPanci()`middleware wraps our router -- this will ensure that the middleware runs for every one of our API endpoints.
`return app.recoverPanic(router)`

Now that is in place, if there is a panic in one of our API handlers the `recoverPanic()`middlewre will recover it and call our regular `app.serverErrorResponse`.

#### System-generated error responses

While we are on the topic of errors, mention that in certin scenarios Go’s `http.Server`may still automatically generate and send plain-text http responses - these scenarios include when -- 

- The HTTP request specifies an unsupported HTTP protocol version.
- Contains a missing or invalid `Host`header, or mutliple `Host`headers
- A empty `Content-Length`header
- `Transfser-Encoding`header

#### Panic recovery in other goroutines

It’s really important to realize that our middleware will only recover panics that happens in the *same goroutine that executed the `recoverPanic()`*middleware.

So, fore, you have a handler which spins up another goroutine -- then any panics that happen in background goroutine will not be recovered -- not by the `recoverPanic()`middleware... And not by the panic recovery built into `http.Server`-- these panics will cause your application to exit and bring down the server. If you are just spinning up additional goroutine from within your handlers and there is any chance of panic -- must make sure that you receover any panics from within those goroutines too.

### Parsing JSON requests

Going to work on the `POST /v1/movies`endopoint and the `createMovieHandler()`. When a client calls this endpoint, will expect them to provide a JSON request body containing data for movie they want to create in our system. If a client wanted to add a record for the movie to our API, would send a request body simialr to this.

```json
{
    "title": "moana",
    "year": 2016,
    "runtime" : 107,
    "genres": ["animation", "advanture"]
}
```

For now, focus on the reading, parsing and validation aspects of dealing with this JSON request body, specifically:’

- How to read a request body and decode it to an native Go object
- How to deal with bad requests from clients and invlalid json, return clear, actionalble error messages
- how to create reusable helper package for validating data to ensure it meets your business rules.
- Different techniques for controlling and customizing how JSON is decoded.

### JSON decoding

Just like encoding, there are also two approaches that U can take to *decode JSON into* Go object.

```go
func (app *application) createMovieHandler(w http.responseWriter, r *http.Request) {
    var input struct {
        Title string `json:"title"`
        //...
    }
    // initialize a new json.Decoder instance which reads from the request body
    // then use the `Decode()`method to decode the body contents into the 
    err := json.NewDecoder(r.Body).Decode(&input)
    if err != nil {
        app.errorResponse(w, r, http.StatusBadRequest, err.Error())
        return
    }
    // dump the contents of input struct in a HTTP response
    fmt.Fprintf(w, "%+v\n", input)
}
```

For this, there are a few important and interesting things about this code to point out -- 

- when calling `Decode()`U must pass a non-nil pointer as the target decode detination
- If the target decode destination is a struct, -- the struct fields must be exported, just like with encoding. -- they need to be exported so that they are visiable to the `encoding/json`package.
- When decoding a JSON object into a struct the k/v pairs in the JSON are mapped to the struct fields based on the struct *tag names* -- if there is no matching struct tag -- Go will attempt to decode the value into a filed that matches the key name note that any JSON k/v pairs *which cannot be successfully mapped* to the struct fields will be silently ignored.
- There is no need to close `r.Body`after it has been read. This will be done automatically by Go’s `http.Server`.

#### zero values

Take a quick look at what happens if we omit a particular key/value pair in our JSOn request body. fore:

```json
{
    "title": "Monana",
    "runtime": 107,
    //...
}
```

When we do this the `Year`field in the `input`struct left with its zero value. Namely -- how can U tell the difference between a client *not providing a k/v pair* and providing a k/v but deliberately setting it to its zero value like: the end result is just the same.

It’s important to mentaion that certain JSON types can be only be successully decoded to certain Go types. Fore, trying to decode it into Go int or bool will result in an error at runtime.

Using `json.Unmarshal`function -- 

```go
func(app *application) exampleHandler(w http.ResponsWriter, r *http.Request) {
    var input struct {
        Foo string `json:"foo"`
    }
    // use io.ReadAll() to read the entire request body 
    body, err := io.ReadAll(r.Body) // return []byte
    if err != nil {
        app.serverErrorResponse(w, r, err)
        return
    }
    err = json.Unmarshal(body, &input)
    if err != nil {
        app.errorResponse(w, r, http.StatusBadRequest, err.Error())
        return
    }
}
```

### Managing bad Requests

For the `createMovieHandler()`now works well when it receives a valid JSON request body with the appropriate data, but at this point you might wondering for -- 

- If the client sends sth that isn’t JSON
- What if the JSON is malformed or contains an error
- If the types don’t match the type we are trying to decode into
- if the request doesn’t even contain a body

For a public-facing API, the error messages themselves aren’t ideal - some are too detailed and expose info about the underlying API implemenation, other aren’t descriptive enough.

Going to explain how to triage the errors return by the `Decode()`and replace them with clearer, easy-to-action, error messages to help the client debug exactly what is wrong with their JSON.

#### Triaging the Decode error

The `Decode()`could potentially return the following 5 types of error -- like:

- `json.SyntaxError, io.ErrUnexpectedEOF`-- Syntax error
- `json.UnmarshalTypeError`-- A JSON is not appropraite for the destination Go type.
- `json.InvalidUnmarshalError`-- decode destination is not valid -- this is actually a problem with our application code, not the JSON itself. Typically, it is not a pointer.
- `io.EOF`-- the JSON being decoded is empty

Triaging these potential errors -- which can do using Go’s `errors.Is()`and `errors.As()`is going to make the code a lot longer and more complicated -- and the logic is sth that we will need to duplicate in other handlers.

To assist with this, create `readJSON()`helper -- in this decode the JSON form the request body as normal, then triage the errors and replace them with our new custom messages as necessary -- 

```go
func (app *application) readJSON(w http.ResponseWriter, r *http.Request, dst any) error {
    err := json.NewDecoder(r.Body).Decode(dst)
    if err != nil {
        // if there is an error during decoding -- 
        var synaxError *jsonSyntaxError
        var unmarshalTypeError *json.UnmarshalTypeError
        var invalidUnmarshalError *json.InvalidUnmarshalError
        
        switch{
        case errors.As(err, &syntaxError):
            return fmt.Errorf("body contain badly-formed JSON %d", syntaxError.Offset)
        case errors.Is(err, io.ErrUnexpectedEOF):
            return errors.New("body contain badly-formed JSON")
        case errors.As(err, &unmarshalTypeError):
            if unmarshalTypeError.Field != "" {
				return fmt.Errorf("body contains incorrect JSON type for field %q",
                  		unmarshalTypeError.Field)
		   }
			return 
            		fmt.Errorf("body contains incorrect JSON type (at character %d)", 
                               unmarshalTypeError.Offset)
        case errors.Is(err, io.EOF): return errors.New("body must not be empty")
        default: return err
        }
    }
}
```

So can just use this like:

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
    err := app.readJSON(w, r, &input)
    if err != nil {
        app.errorResponse(w, r, http.StatusBadRequest, err.Error())
        return
    }
    fmt.Printf(w, "%+v\n", input)
}
```

#### Making a bad request hepler

In the `createMovieHandler`ode we are using our generic `app.errorResponse()`helper to send a 400 response along with the error message -- quickly replace this with a specialist -- `app.badRequiestResponse()`helper instead like: -- 

```go
func (app *application) badRequestResponse(w http.ResponseWriter, r *http.Request, err error) {
	app.errorResponse(w, r, http.StatusBadRequest, err.Error())
}
```

Then in the main -- 

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
    var input struct {
        //...
    }
    err := app.readJSON(w, r, &input)
    if err != nil {
        // use the new helper
        app.badRequestResponse(w, r, err)
        return
    }
    fmt.Printf(w, "%+v\n", input)
}
```

#### Panicking vs returning errors 

The decision to panic in the `readJSON()`helper if we get `json.InvalidUnmarshalError`error isn’t taken lightly -- it’s generally considered best practice in Go to return your errors and handle them gracefully.

But -- in some specific circumanstances -- it can be just ok to panic -- and you shouldn’t be too dogmatic about not pancking when it makes sense to. Distinguish between the two classes of error what your app might encounter -- the first class of errors are *expected errors* that may occur during normal operation -- Some examples of expected errors are those caused by a dbs query timeout, network resource being unavailale, or bad uer input... These errors don’t necessarily mean there is a problem with you program itself -- they are often caused by things outside the control of your program -- almost all of the time it’s good practice to return these kinds of errors and handle them gracefully.

For the *unexpected errors* -- which should not happen during normal opeation -- if they do it is probably the result of developer mistake or a logic error in your codebase. These errors are truly exceptional, and using panic in these circusmatances is more widely accepted -- the Go stdlib frequently does this when U make a logic error ro try to sue the language features in an uninteded way -- such as when trying to access and out-of-bounds index... 

Even then, -- recommend trying to return and gracefully handle unexpected errors in most cases. The exception to this is when *returning the error* adds an unacceptable amount of error handling to the rest of your codebase.

Fore the `json.InvalidUnmarshalError`fore -- cuz we as the developers have passed an unsupported value to the `Decode()`-- This is firmly an *unexpected* error which we shouldn’t see under normal operation -- is sth that should be picked up in development and tests along before deployment.

If we *did* return this error, rather than panicking, would need to introduce additional code to manage it in each of our API handlers -- which doesn’t seem like a good trade-off for an error that we are unlikely to ever see in production.

So, a panic typically means *sth went unexpectedly wrong*. Mostly we use to to fail fast on errors that shouldn’t occur during normal operation and that we are not prepared to handle gracefully.