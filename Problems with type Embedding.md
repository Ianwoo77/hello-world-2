# Problems with type Embedding

When creating a struct, Go offers the option to embeded types -- but this can sometimes lead to unexpected behaviors if don’t understand all the implications of type embedding -- fore:

```go
type Foo struct {
    Bar
}
type Bar struct {
    Baz int
}
```

When use embedding to *promote* the fileds and methods of an embedded type -- Cuz `Bar`contains a `Baz`, this field is promoted to `Foo`-- `Baz`becomes available from `Foo`. 

When implement a struct that holds some in-memory data, and want to protect it against concurent accesses using a mutex -- like:

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem {
    return &InMem{m: make[string]int}
}
```

For this, decided to make the map unexported so that client can’t interact with it directly but only via exported methods -- the mutex field is embedded, therefore, we can implemnt a `Get`method in this way.

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contins := i.m[key]
    i.Unlock()
    return v, contains
}
```

For this, cuz the mutex is embedded, can directly access the `Lock`and `Unlock`methods from the `i`receiver. Mentioned that such an example is a wrong usage of the type embedding -- Since `sync.Mutex`is an embedded, the `Lock`and `Unlock`will be promoted -- so:

```go
m := inmem.New()
m.Lock()
```

Fore, this promotion is probably not desired, a Mutex is in most cases, something that we want to encapsulate within a struct and make invisiable to external clients. Therefore, we shouldn’t make it an embeeded.

```go
type InMem struct {
    mu sync.Mutex
    m map[string]int
}
```

Cuz the mutex isn’t embedded and is unexported, it can’t be accessed from external clients. Also, there are some examples for this is good -- 

```go
type logger struct {
    writeCloser io.WriteCloser
}
func (l logger) Write([]byte) (int, error) {
    return l.writeCloser.Write(p)
}
func (l logger) Close() error {
    return l.writeCloser.Close()
}
```

for this, only just do:

```go
type Logger struct {
    io.WriteCloser
}
```

So if decide to use type embedding, need to keep two main constraints in mind -- 

1. It shouldn’t be used solely as some syntactic sugar to simplify accessing a field.
2. It shouldn’t prmote data (fields) or a behavior (methods) we want to hid from the outside.

### Functional option pattern

When designing an API, one question may arise -- how we deal with optional configurtion -- Solving this problem efficiently can imporve how convenient  our API will beomce -- A concrete example and covers different ways to handle optional configurations -- fore:

```go
func NewServer(addr string, port int) (*http.Server, error) {...}
```

Fore, use default one, handle negative, using random port...

#### Config struct

The first possible approach is to use a configuration struct to convey what is mandatory and what is optional -- fore, the mandatory parameters could live as function parameters -- whereas the optional parameters could handle in the `Config`struct like:

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config) {...}
```

In the case, need to find a way to distinguish between a port purposely set to 0 and a missing port -- one might to handle all the parameters of configuration struct as pointer in this way -- like:

```go
type Config struct {
    Port *int
}
```

Using an integer pointer, can highlight the differecne between the value 0 and missing value -- It has a couple of downsides -- first it’s not handy for clients to provide an integer pointer. Fore:

```go
port := 0
config := httplib.Config{Port: &port}
```

Overall API becomes a bit less convienent to use. Also the more options we add, the more complex code becomes. The second downside is that a client using our library with the default configuration will need to pass an empty struct like this -- `httplib.NewServer("localhost", http.Config{})`

Another option is to use the *classic* builder pattern -- 

#### Builder Pattern

Originally part of the Gang of Four design patterns - The builder pattern provides a flexible solution to various object -- Creation problems. The construction of `Config`is *separated from the struct itself*. -- requires an extra struct, `ConfigBuilder`-- receives methods to configure and build a `Config`. Fore:

```go
type Config struct {
    Port int
}
type ConfigBuilder struct {
    port *int
}
func (b *ConfigBuilder) Port (port int) *ConfigBuilder {
    b.port = &port
    return b
}
func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port == nil {
        cfg.Port= defaultHTTPPort
    }else {
        if *b.port==0 {
            cfg.Port= randomPort()
        }else if *b.port < 0 {
            return Config{}, errors.New("port should be positive")
        }else{
            cfg.Port=*b.port
        }
    }
    return cfg, nil
}
```

For this, the `ConfigBuilder`struct holds the client configuration. It exposes a `Port()`to set up the port. Usually, such a configuration method returns the builder itself so that we can use method chanining. Then a client would use our builder-based API in the following manner like:

```go
builder := httplib.ConfigBuilder{}
builder.Port(8080)
cfg, err := builder.Build()
if err != nil {
    return err
}
server, err := httplib.NewServer("localost", cfg)
```

For this, first the client creates a `ConfigBuilder`and uses it to set up an optional field, such as the port , then it calls the `Build()`method and checks for errors. Then calls the `Build()`and checks for errors.

### Adopting Channels as a first-class objects

In CSP -- The algorithm is based on the sieve of -- which is a simple method for checking whether a number is prime -- Can have a goroutine generate candidate sequential number rating from 2 -- The ouput of this goroutine will feed into a pipeline that consists of a chain of goroutiens -- each filtering out the mutliples of a prime number -- A goroutine in this chain is assigned a prime number `p`and it will discrd number that are just *multiple* of `p`. so recurive -- When a number passes through all the existing goroutines and is not discarded -- it’s a primer.

```go
func primeMultipleFilter(numbers <-chan int, quit chan<- struct{}) {
	var right chan int
	p := <-numbers
	fmt.Println(p) // if passes through all pipes, it's a prime number
	for n := range numbers {
		if n%p != 0 {
			if right == nil { // if current has no right, starts a new goroutine
				right = make(chan int)
				go primeMultipleFilter(right, quit)
			}
			right <- n
		}
	}
	if right == nil {
		close(quit)
	} else {
		close(right)
	}
}

func main() {
	numbers := make(chan int)
	quit := make(chan struct{})
	go primeMultipleFilter(numbers, quit)
	for i := 2; i < 1000; i++ {
		numbers <- i
	}
	close(numbers)
	<-quit
}
```

## Enveloping responses

Work on updating our resposes so that the JSON data is always *enveloped* in a parent JSON Object like:

```go
type envelope map[string]any

func (app *application) writeJSON(w http.ResponseWriter, status int, data envelope, 
                                  headers http.Header) error {
    js, err := json.MarshalIndent(data, "", "\t")
    if err != nil {
        return err
    }
    js = append(js, '\n')
    for key, value := range headers {
        w.Header()[key]= value
    }
    w.Header().Set("Content-type", "application/json")
    w.WriteHeader(status)
    w.Write(js)
    return nil
}
```

Then need to update our `showMovieHandler()`to create an instsnace of the `envelope`map containing the movie data, and pass this onwards to our `writeJSON()`helper instead of passing the movie data directly Like:

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Request) {
    id, err := app.readIDParam(r)
    if err != nil {
        http.NotFound(w,r)
        return
    }
    movie := data.Movie {
        ID: id,
        //...
    }
    // create an envelope instance and pass to writeJSON()
    err = app.writeJSON(w, http.StatusOK, envelope{"movie": movie}, nil)
    if err != nil {
        http.Error(...)
    }
}
```

Also need to update the code in the `healthcheckHandler`so that it apsses an `envelope`type to `writeJSON()`.

```go
func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
    env := envelope {
        "status": "available",
        "system_info": map[string]string{
            "envoronment": app.config.env,
            "version": version,
        },
    }
    err := app.writeJSON(w, http.StatusOK, env, nil)
    if err != nil {
        //...
    }
}
```

#### Response structure

It’s important to emphasize that there is no single *right* or *wrong* way to structure your JSON responses. There are some popular formats like `JSON:API`and `jsend`that U might like to follow or use for inspiration.

### Advanced JSON Customization

To anwser, first need to talk some theory about Go handle JSOn encoding behinding th scenes -- It looks to see if the type has a `MarshalJSON()`method implemented on it -- then go will call this method to deterine how to encode it.

```go
type Marshaler interface {
    MarshalJSON() ([]byte, error)
}
```

If the type doesn’t have a `MarshalJSON()`-- go just will fall back to trying to encode it to json based on its own internal set of rules -- so, if want to customize how sth is encoded, all need to do is implement a `MarshalJSON()`on it which returns a *Custom JSON respresentation of itsle* in a `[]byte`slice.

#### Customizing the Runtime field

To help illustrate -- create in the app - When `Movie`is encoded to JSON, the `Runtime`is currently formatted as a JSON number, -- Change to the `<runtime> mins`instead like: A clean and simple approach is to create a custom type specifically for the `Runtime`field -- implement the `MarshalJSON()`on this custom type like:

```go
type Runtime int32

func (r Runtime) MarshalJSON() ([]byte, error) {
	jsonValue := fmt.Sprintf(`"%d minutes"`, r)
	quotedJSONValue := strconv.Quote(jsonValue) // wrap it in double quotes
	return []byte(quotedJSONValue), nil
}
```

- If want to returns a JSON string value, must wrap the string in *double quotes* before returning it -- otherwise, won’t be interpreted as a JSON string and will receive a runtime error.
- Note that deliberately using a *value receiver* for this -- this gives us more flexibility cuz means that our custom JSON encoding work on both the `Runtime`and `*Runtime`values.

Then modify the `movies.go`like:

```go
type Movie struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"-"`
	Title     string    `json:"title"`
	Year      int32     `json:"year"`
	Runtime   Runtime   `json:"runtime,omitempty"`
	Genres    []string  `json:"genres,omitempty"`
	Version   int32     `json:"version"`
}
```

Alternative #1 -- Cuztomizing the Movie struct -- instead of creating a custom `Runtime`type, could have implemented a `MarshalJSON()`on our `Movie`struct and customized the whole thing like:

```go
type Movie struct {
    //...
}
func (m Movie) MarshalJSON() ([]byte, error) {
    var runtime string
    if m.Runtime!=0 {
        runtime = fmt.Sprintf("%d mins", m.Runtime)
    }
    aux := struct {
        ID int64 `json:"id"`
        Title string `json:"title"`
        //...
    } {
        ID: m.ID,
        Title: m.Title
    }
    return json.Marshal(aux)
}
```

For this, we created a new anonymous struct and assign it to the variable `aux`then is basically identical to our `Movie`struct, except for the fact that the `Runtime`field has the type `string`instead of `int32`-- when then copy all the values from the `Movie`struct directly into the anonymous truct.

#### Alterniative #2 Embedding an alias

The downside of the approach above is that the code feels quite verbose and repetitive -- To reduce duplication, instead of writing out the struct field long-hand it’s possible to embed an alias of the `Movie`struct like:

```go
type Movie struct {
    ID int64      `json:"id"`
    //...
    Year int32    `json:"year,omitempty"`,
    Runtime int32 `json:"-"`
    //...
}

func (m Movie) MarshalJSON() ([]byte, error) {
    var runtime string
    if m.Runtime != 0 {
        runtime = fmt.Sprintf(...)
    }
    // define a type which has underlying type Movie
    // has all of the fields, not that none for methods
    type MovieAlias Movie
    
    // embeded the MovieAlias type insdie the anonymous struct -- 
    // note that it's important that we embed the `MovieAlias` type here, 
    // rather than the movie type directly
    aux := struct {
        MovieAlias
        Runtime string `json:"runtime,omitempty"`
    }{
        MovieAlias: MovieAlias(m),
        Runtime: runtime
    }
    return json.Marshal(aux)
}
```

### Sending Error Messages

At this point our API is sending nicely formatted JSON responses for successful requests -- but if a client make a bad request -- or sth goes wrong in the app -- still sending them a plain-text error messages from the `http.Error()`and fore `http.NotFound()`functions.

Fix that by creating some additional helpers to manage errors and send the appropriate JSON responses to our clients

```go
func (app *application) logError(r *http.Request, err error) {
	app.logger.Print(err)
}

// this is a generic helper for sending JSON-formatted error messages
// to the client with a given status code
func(app *application) errorResponse(w http.ResponseWriter, r *http.Request, 
	status int, message any) {
	env := envelope{"error": message}
	
	// Write the response using the `writeJSON()` -- if this happens to return an
	// error then log
	err := app.writeJSON(w, status, env, nil)
	if err != nil {
		app.logError(r, err)
		w.WriteHeader(500)
	}
}

// The ServerErrorResponse() method will be used when our app encounters an unexpected problem
// at runtime it logs the detailed error message, and then uses the helper to send 500
func (app *application) serverErrorResponse(w http.ResponseWriter, r *http.Request, err error) {
	app.logError(r, err)
	
	message := "the server encountered a problem and could not process your request"
	app.errorResponse(w, r, http.StatusInternalServerError, message)
}

// The notFoundResponse() will be used to send just 404
func (app *application) notFoundResponse(w http.ResponseWriter, r *http.Request) {
	message := "the requested resource could not be found"
	app.errorResponse(w, r, http.StatusNotFound, message)
}

// the methodNotAllowedResponse() will be used to send a 405
func (app *application) methodNotAllowedResponse(w http.ResponseWriter, r *http.Request) {
	message := fmt.Sprintf("the %s method is not supported for this resource", r.Method)
	app.errorResponse(w, r, http.StatusMethodNotAllowed, message)
}
```

Now those in place, update our API handlers to use these helpers instead of the `http.Error()`and `http.NotFOund`like:

```go
err := app.writeJSON(w, http.StatusOK, env, nil)
if err != nil {
    app.serverErrorResponse(w, r, err)
}
//...
if err != nil {
    // use the new helper
    app.serverErrorResponse(w, r, err)
}
```

#### Routing errors

Any error messages that our own API handlers send will now be well-formed JSON response -- but what about the error messages that `httprouter`automatically sends when it can’t find a matching route - by default, Thies will still be same non-JSON responses that - `httprouter`allows us to set our custom error handlers when we initialize the router -- these custom handlers must satisfy the `http.Handler`interface, which is good news for us -- can easily re-use the `notFoundResponse()`.. just like:

```go
// Covert the notFoundResponse() helper to the http.Handler using the 
// http.HandlerFunc() adapter
router.NotFound= http.HandlerFunc(app.notFoundResponse)

// likewise, convert the methodNotAllowedResponse() helper to an http.Handler
router.MethodNotAllowed= http.HandlerFunc(app.methodNotAllowedResponse)
```

#### System-genered error responses

While we are on the topic of errors, like to maintain that in certain scenairos Go’s `http.Server`may stil automatically generate and send plain-text HTTP responses -- these sceanrios include when -- 

- Unsupported HTTP protocol version
- Invliad *Host* header, mutliple Host headers
- HTTP request contains an unsupported `Transfer-Encoding`header
- Size of the HTTP request headers exceeds the server’s `MaxHeaderBytes`settings.

### Parsing JSON requests

So far, have been looking at how to create and send JSON responses from our API, but in this next - going to explore things from the other side and discuss how to *read and parse JSON requests* from clients. For this, when a client calls this endpoint, will expect them to provide a JSON request body containing data for the movie they want to create in our system -- so if a client wanted to add a record for the movie send a request body like -- 

```json
{
    "title": "Moana",
    "year": 2016,
    //...
}
```

For now, just focus on the reading, parsing, and validation accepts of dealing with this JSOn body -- 

- How to read a request body and decode it to a native Go object using the `encoding/json`pacakge
- How to deal with bad requests from clients and invalid JSON, and return clear, actionalble error messages.
- How to create a reusable helper package for vlaidating data to ensure it meets your business rules.
- Different techniques for controlling and customizing how JSON is decoded.

#### Json Decoding -- 

Like encoding, there are two approaches that we can take to *decode* JSON into a native Go object using a `json.Decoder`type or using the `json.Unmarshal()`function. Both approaches have their pros and cons, but for purposes of decoding JSON from a HTTP request body, using `json.Decoder`is just the best choice -- it is more efficient than the `json.Unmarshal()`-- require just less code, and offers some helpful settings that you can use to tweak its behaviors. Update the `createMovieHandler`like so -- 

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
	// Declare an anonymous struct to hold the info that we expect to be in the HTTP
	// request body
	var input struct {
		title   string   `json:"title"`
		Year    int32    `json:"year"`
		Runtime int32    `json:"runtime"`
		Genres  []string `json:"genres"`
	}

	// Initialize a new json.Decoder instance which reads from the requst body, and
	// then use the `Decode()` to decode the body contents into the input struct
	// notice that when call `Decode` we pass a pointer to the input struct
	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		app.errorResponse(w, r, http.StatusBadRequest, err.Error())
		return
	}
	fmt.Printf(w, "%+v\n", input)
}
```

There are just a few important and interesting things about this code to point ou -- 

- When calling `Decode()`you must pass a **non-nil** pointer as the target decode destination.
- If the target decode destination is a struct -- the struct fields must be **exported**.
- When decoding a JSON object into a struct, the K/V pairs in the JSON are mapped to the struct fields based on the struct tag names. And if there is no matching struct tag, Go will attempt to decode the value into a field that matches the key name. NOTE: <u>Any Json k/v pairs which cannot be successfully mapped to the struct fields will be silently ignored</u>.
- There is no need to close `r.Body`after it has been read. - this will be done automatically by Go’s `http.Server`.

That seems have workd well using just the postman.