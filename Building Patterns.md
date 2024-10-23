# Building Patterns

Cuz Go *does not support optional parameters* in function signatures -- the first possible approach is to use a configuration struct to coney what is mandatory and what is optional -- Fore, the mandatory parameters could live as function parameters -- whereas the optional parameters could be handled in the `Config`struct fore:

Optionally part of the builer pattern provides a flexible solution to various object -- creation problems -- `Config`is separated from the struct itself -- it requires an extra struct, `ConfigBuilder`which recives methods to configure and build a `Confg`-- 

```go
type Config struct {
    Port int
}

// holds the client configuration
type ConfigBuilder struct {
    port *int
}

// exposes Port() to set the port
func (b *ConfiguBuilder) Port (port int) *ConfigBuilder {
    b.port= &port
    return b
}

// Build() to return Config struct
// hold the logic on initializing the port value
func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port == nil {
        cfg.Port = defaultHTTPPort
    }else {
        if *b.port==0 {
            cft.Port= randomPort()
        }else if *b.port < 0 {
            return Config{}, errors.New(...)
        }else{
            cfg.port= *port
        }
    }
    return cfg, nil
}
```

Then a client would use our builder-based API in the following manner like:

```go
builder := httplib.ConfigBuilder{}
builder.Port(8080)
cfg, err := builder.Build()
if err != nil {
    return err
}
```

### Functional options pattern

The approach discuss is the functional options pattern -- there are different implementations with minor variations, the main idea is as follows -- 

- An unexported struct holds the configuration -- `options`
- Each option is a function that returns the same type -- `type Option func(options *options) error`. Fore, `WithPort`accpets an argument that represents the port and returns an `Option`type that represents the port and returns an `Option`type that represents how to update the `Option`struct.

`WithPort(port int) Option`-> returns -> Option type -> Option struct

```go
type options struct { // an unexported struct holds the configuration
	port *int
}

type Option func(options *options) error

func WithPort(port int) Option {
	return func(options *options) error {
		if port <0 {
			return errors.New("Port should be positive")
		}
		options.port = &port // change the config
		return nil
	}
}
```

Here the `WithPort`returns a closure -- A *closure* is an anonymous function that references variables from outside its body -- in this case, the `port`vairable -- the Closure represents the `Option`type and implements the port-validation logic. Just look at the last part on the provider side -- the `NewServer`imp -- 

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    
    // at this stage, the struct is built and contains the config
    var port int
    if options.port == nil {
        port = defaultHTTPPort
    }else {
        if *options.port==0 {
            port = randomPort()
        }else {
            port = *options.port
        }
    }
}
```

For this, start by creating an empty `options`, then iterate over each `Option`argument and execute them to mutate the `Options`struct - once the `options`struct is built, can implement the final logic regarding port management. And, cuz `NewServer`just accepts variadic `Option`arguments, a client can now call this API by passing multiple options following the mandatory address argument fore -- 

```go
server, err := httplib.NewServer("localhost", httplib.WithPort(8080),
                                 http.WithTimeout(time.Second))
```

However, if the client needs the default configuraiton, doesn’t have to provide an argument. This pattern is the functional option pattern -- it provides a handy and API-firendly way to handle options.

## JSON Decoding

Just like Json encoding, there are two approaches that you can take *decode* JSON into a native Go object, using `jsong.Decoder`or using the `json.Unmarshal()`-- Both approches have their pros and cons.

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
    var input struct {
        Title string `json:"title"`
        //...
    }
    
    // Initialize a new json.Decoder instance which reads from the request body
    // using the `Decode()` method to decode the body contents into the input struct.
    // Note that when we call `Decode()`pass a *pointer to the input
    err := json.NewDecoder(r.Body).Decode(&input)
    if err != nil {
        app.errorResponse(...)
        return
    }
}
```

- When calloing `Decode()`must pass a *non-nil* pointer as the target decode destination -- If U don’t use a pointer, will return `json.InvalidUnmarshalError`error at runtime
- If the target decode destination is a struct, like our case, the struct fileds must be exported.
- When decoding a JSON object into a struct, the k/v pairs in the JSON are mapped to the struct fields based on the struct tag names -- and if there is no matching struct tag, Go will attempt to decode the value into the field that matches the key name.
- Note that there is no need to close `r.Body`.

#### Zero Values

Take a quick look at what happens if we omit particular k/v pair in the JSON request, 

```json
{
    "title":"Moana", "runtime":107, "genres":["animation","adventure"]
}
```

If do this the `Year`filed in our `input`struct is left with its zero value -- this leads to an interesting question - how can U tell the difference betweeen a client not providing, and but *deliberately* setting it to its zero value?

#### Supported destination types

It’s important to mention that certain JSON types can be only be successful decoded to certain Go types. 

Using the `json.Unmarshal`-- It’s also possible to use the `json.Unmarshal()`to decode a HTTP request body.

```go
func (app *application) exampleHandler(w http.ResponseWriter, r *http.Request) {
    var input struct {
        Foo string `json:"foo"`
    }
    
    // using the `ReadAll` to read the entire request body into []byte first
    body , err := io.ReadAll(r.Body)
    if err != nil {
        app.serverErrorResponse(w, r, err)
        return
    }
    // using the json.Unmarshal() func to decode the JSON in the []byte slice
    err = json.Unmarshal(body, &input)
    if err != nil {
        app.errResponse(w, r, http.StatusBadRequest, err.Error())
        return
    }
    fmt.Fprintf(w, "%+v\n", input)
}
```

Using this approach is just fine -- the code works, and it’s also clear and simple -- but it doesn’t offer any benefits over and above the `json.Decoder`. Not only is thd code marginally more verbose, less efficient.

### Managing Bad Requests

Our `createMovieHandler`now works well when it recieves a valid JSON request body with the appropriate data, but at this point you might be wondering -- 

- What if the client sends sth that isn’t JSON, like XML or sth else
- What happens if the JSON is malformed or contains error
- What if the JSON type dosn’t match the types we are typing to decoded into.
- What if the request doesn’t even contain a body.

For this example, can see our `createMovieHandler()`is doing the right thing. For private API which won’t be uesd by members of public, then this behavior is propably fine and you needn’t do anything else. 

But, for a public-facing API, the error messages themselves aren’t ideal -- some are too detailed and expose info about the underlying API implementation -- others aren’t descriptive enough, and some are just plain confusing and difficult to understand. Just -- there isn’t consistency in the formatting or language used either -- 

Are going to explain how to *triage* the errors returned by the `Decode()`and replace them with clearer, easy-to-action, error messages to help the client debug exactly what wrong with their JSON.

#### Triaging the Decode error 

The `Decode()`method could potentially return the following 5 types of errors -- 

- `json.SyntaxError, io.ErrUnexpectedEOF`-- thereis a syntax problem
- `json.UnmarshalTypeError`-- JSON value is not appropriate
- `json.InvalidUnmarshalError`-- destination is not valid, not a pointer 
- `io.EOF`-- JSON being decoded is empty

Triaging these potential errors , can using the `errors.Is()`and `errors.As()`is going to make the code in our code in the `createMovieHandler`*a lot* and more complicted. -- And the logic is sth that we will need to duplicate in other handlers throughout this project too.

So to assist with this, create a new `readJSON()`helper in the `cmd/api/helpers.go`file -- in this helper, decode the JSON from the request body as normal, then triage the errors and replace them with our won custom message as necessary -- like:

```go
func (app *application) readJSON(w http.ResponseWriter, r *http.Request, dst any) error {
	// Decode the request body into the target destination
	err := json.NewDecoder(r.Body).Decode(dst)

	if err != nil {
		// if there is an error during decoding, start the triage...
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError
		var invalidUnmarshalError *json.InvalidUnmarshalError

		switch {
		// Using the errors.As() to check whether the error has type
		case errors.As(err, &syntaxError):
			return fmt.Errorf("body contains badly-formed JSON %d", syntaxError.Offset)
		// in some case may also return io.ErrUnexpectedEOF
		// for syntax errors in the json, check for this using errors.Is() and return
		// a generic error mesage
		case errors.Is(err, io.ErrUnexpectedEOF):
			return errors.New("body contains badly-formed JSON")

		// likewise, catch *json.UnmarshalTypeError`, occurs when the JSON value is the
		// wrong type for the target dest like:
		case errors.As(err, &unmarshalTypeError):
			if unmarshalTypeError.Field != "" {
				return fmt.Errorf("body contains incorrect json type %q",
					unmarshalTypeError.Field)
			}
			return fmt.Errorf("body contains incorrect JSON %d",
				unmarshalTypeError.Offset)

		// io.EOF will be returned by Decode() if the request body is empty
		case errors.Is(err, io.EOF):
			return errors.New("body must not be empty")

		// A json.InvalidUnmarshalError error will be returned if we pass sth
		// that is a non-nil pointer to Decode(), catch and panic
		case errors.As(err, &invalidUnmarshalError):
			panic(err)

		default:
			return err
		}
	}
	return nil
}
```

With this new helper in place, head back to the `cmd/api/movies.go`file and update our `createMovieHandler`like:

```go
err := app.readJSON(w, r, &input)
if err != nil {
    app.errorResponse(w, r, http.StatusBadRequest, err.Error())
    return
}
fmt.Fprintf(w, "%+v\n", input)
```

#### Making a bad request helper

In the `createMovieHandler`code above using our generic `app.errorResponse()`helper to send the client 400 response along with the error message -- quickly replace with a specialist `app.badRequestResponse()`helper function instead - like:

```go
func (app *application) badRequestResponse(w http.ResponseWriter, r *http.Request, err error) {
    app.errorResponse(w, r, http.StatusBadRequest, err.Error())
}
err := app.readJSON(w, r, &input)
if err != nil {
    app.badRequestResponse(w, r, err)
    return
}
```

This is just a small change, but a useful one.

#### Panicking vs. returning errors

The decision to panic in the `readJSON()`helper if we get `json.InvalidUnmsrshalError`error isn’t take lightly -- as are probably aware -- it’s generally considered best practice in Go to return your errors and handle them gracefully. In some specific circumstances -- it can be OK to panic -- U shouldn’t be too dogmatic about *not panicking* when it makes sense to.  It’s just helpful here to distinguish between the two classes of error that your app might encounter -- 

1. The first class of errors are *expected errors* that may occuring during normal operation. Some of expected are those caused by the dbs query timeout, network resource being unavailable, or bad user input -- these errors don’t necessarily mean there is a problem with your program itself, in fact they are often caused by things outisde the control of your prgram.
2. *unexpected errors* -- are errors which should not happen during normal operation -- the result of a developer mistake or a logic error in the codebase. These are truly exceptional, and using panic in these is more widely acceptable. In fact, the Go stdlib frequently does this when make a logic error or try to use the language features in a unintended way.

Fore, if get a `json.InvalidUnmarshalError`at runtime it’s cuz we as the developers have passed an unsupported value to the `Decode()`-- is is firmly an unexpected error which shouldn’t see under normal operation.

### Retricting Inputs

The changes that we made in the previous to deal with the invlid JSON and other bad requests were big step in the right direction -- but there are still a few things we can do to make our JSON processing even more robust -- One uch thing is dealing with *unknown* fields -- fore, can try sending a request containing the unknown field rating to our `createMovieHandler`like -- Notice fore *PG* without any problems -- there is no error to inform the client that the `rating`field is not recognized by the app.

Fortunately, Go’s `json.Decoder`provides a `DisallowUnknownFields()`setting that we use to generate an error when this happens -- Another problem have is the fact that `json.Decoder`is designed to support *Streams* of JSON data. When call `Decode()`on our request body, it actually reads the *first JSON value* from the body and decodes it. If we made a second call to `Decode()`-- it would read and decode the second value and so on.

For this, want requests to our `createMovieHandler`to contain only one single JSON object in the request body, with info about the movie to be created in our system.

To ensure that there are no additional JSON values in the request body, need to call the `Decode()`as a second time in the `readJSON()`helper and check that it returns an `io.EOF`error.

```go
func (app *application) readJSON(w http.ResponseWriter, r *http.Request, dst any) error {
	// Use the http.MaxBytesReader() to limit the zie of the request body
	maxBytes := 1_048_576
	r.Body = http.MaxBytesReader(w, r.Body, int64(maxBytes))

	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	// Decode the request body into the target destination
	err := dec.Decode(dst)

	if err != nil {
		// if there is an error during decoding, start the triage...
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError
		var invalidUnmarshalError *json.InvalidUnmarshalError

		// add a new variable
		var maxBytesError *http.MaxBytesError

		switch {
		//... other cases

		// if the json contains a field which cannot be mapped to the target
		// then will now return an error message in the format "json:unknown"
		case strings.HasPrefix(err.Error(), "json: unknown filed "):
			fieldname := strings.TrimPrefix(err.Error(), "json: unknown field ")
			return fmt.Errorf("body contains unknown key %s", fieldname)

		// use the errors.As() to check whether the error has the type
		// *http.MaxByteError
		case errors.As(err, &maxBytesError):
			return fmt.Errorf("body must not be larger than %d bytes", maxBytesError)

		// A json.InvalidUnmarshalError error will be returned if we pass sth
		// that is a non-nil pointer to Decode(), catch and panic
		case errors.As(err, &invalidUnmarshalError):
			panic(err)

		default:
			return err
		}
	}
	
	// Call the Decode() again using a pointer to an empty anonymous as the dest
	// if the request body only contained a single JSON will return an io.EOF error
	err = dec.Decode(&struct{}{})
	if err != io.EOF {
		return errors.New("body must only contain a single JSON value")
	}
	return nil
}
```

Those are working better, processing of the request is terminated and the client recieves a clear error message explaining exactly what the problem is.

### Custom JSON decoding

Earlier  in the book added some custom JSON encoding behavior to our API so that movie runtime information was displayed in the format `<runtime> mins`in our JSON. In this, Just going to look at this from the other side and update our app so that the `createMovieHelper`*accetps* this runtime information in this format.

If try to send a request with the movie runtime in this format right now, get a *400 bad request* response like, to make this work, need to do is *intercept the decoding process* and manually convert that to the `int32`instead -- 

#### The `json.Unmarshaler`interface

The key thing there is knowing about Go’s `json.Unmarshaler`interface -- whcih like:

```go
type Unmarshaler interface {
    UnmarshalJSON([]byte) error
}
```

The key thing there is knowing about the Go’s `json.Unmarshaler`- when decoding some JSON, will check if the *destination* type satisifies the `json.Unmarshaler`interface -- If it does satisfy the interface, then Go will call its `UnmarshalJSON()`to determine how to decode the provided JSON into the target type.

The first need to do is update our `createMovieHandler()`so that the `input`struct uses our custom `Runtime`type, instead of a regular `int32`-- remember from eariler that our `Runtime`type still has the *underlying type* `int32`-- but by making this a custom tyhpe we are free to implement an `UnmarshalJSON()`method on it.

```go
var input struct {
    Title   string       `json:"title"`
    Year    int32        `json:"year"`
    Runtime data.Runtime `json:"runtime"`
    Genres  []string     `json:"genres"`
}
```

Then head to the `internal/data/runtime.go`file and add `UnmarshalJSON()`method to the `Runtime`type -- in this method we need to parse the JSON string in the format `<runtime> mins`-- convert the runtime number to `int32`.

```go
var ErrInvalidRuntimeFormat = errors.New("invalid runtime format")

func (r *Runtime) UnmarshalJSON(jsonValue []byte) error {
	// we expect that the incoming json value will be a string <runtime> mins
	unquotedJSONValue, err := strconv.Unquote(string(jsonValue))
	if err != nil {
		return ErrInvalidRuntimeFormat
	}

	// split the string to the number
	parts := strings.Split(unquotedJSONValue, " ")
	if len(parts) != 2 || parts[1] != "mins" {
		return ErrInvalidRuntimeFormat
	}

	i, err := strconv.ParseInt(parts[0], 10, 32)
	if err != nil {
		return ErrInvalidRuntimeFormat
	}
	*r = Runtime(i)
	return nil
}
```

Whereas if just make using JSON numbers, or any other format, should now get an error response containing the message from the `ErrInavlidRuntimeFormat`.