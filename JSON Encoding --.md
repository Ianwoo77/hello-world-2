# JSON Encoding -- 

At a high level, Go’s `encoding/json`package provides two options for encoding things to JSON, can either call the `json.Marshal()`function, or you can declare and use a `json.Encoder`type. The way that `json.Marshal()`works is conceptually quite simple, pass a native Go object to its as parametre -- 

#### Creating a `writeJSON`helper method -- 

As our API grows going to be sending a lot of JSON responses, so it makes sense move some of the logic into a reusable `writeJSON()`helper method- 

```go
func (app *application) writeJSON(w http.ResponseWriter, status int, data envelope,
                                  headers http.Header) error {
	js, err := json.MarshalIndent(data, "", "\t")
	if err != nil {
		return err
	}
	js = append(js, '\n')
	for key, value := range headers {
		w.Header()[key] = value
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	w.Write(js)
	return nil
}
```

Now that the `writeJSON()`in place, can significatnly simplify the code in the `healthcheckHeader()`

```go
func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	env := envelope{
		"status": "available",
		"system_info": map[string]string{
			"environment": app.config.env,
			"version":     version,
		},
	}

	err := app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
```

In this chapter we’ve been encoding a `map[string]string`type to JSON, which resulted in a JSON object with JSON strings as the value in the `key/value`pairs -- But Go supports encoding many other native types too. Just note:

`[]byte -> Base64`, Fore  `[]byte{'h','e','l','l','o'}`would appear as `aGVsbG8=`in the JSON output.

##### Using `json.Encoder`-- 

```go
func (app *application) examplehHandler(w http.ResponseWriter, r *http.Request) {
    data := map[string]string {
        "hello": "world",
    }
    w.Header().Set("Content-Type", "application/json")
    err := json.NewEncoder(w).Encode(data)
    if err != nil {
        app.logger.Error(err.Error())
        http.Error(w, "...", http.StatusInternalServerError)
    }
}
```

When call `json.NewEncoder(w).Encode(data)`the JSON is created and written to the `http.ResponseWriter`in a single step, which means there is no opportunity to set HTTP response headers conditionally based on whether the `Encode()`returns an error or not.

#### Encoding Structs

Create `internal/data`containing a `movies.go`file like, One of the nice things about encoding structs in Go is that you can customize the JSON by annotating the fields with struct tags -- like:

```go
type Movie struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"-"`
	Title     string    `json:"title"`
	Year      int32     `json:"year,omitempty"`
	Runtime   Runtime   `json:"runtime,omitempty"`
	Genres    []string  `json:"genres,omitempty"`
	Version   int32     `json:"version"`
}
```

Using `-`control the visibility of individual struct fields in the JSON by using the `omitempty`and `-`directive can be used when U never want a particualr struct field to appear in the JSON output, this is useful for fields that contain internal system information that isn’t relevant your users - or sensitive info that U don’t want to expose. And the `omitempty`directive hides a field in the JSON output -- 

Fore, if wanted the value of our `Runtime`field to be represented as a JSON string -- could use the `string`directive like this -- 

```go
type Movie struct {
    //...
    Runtime int32 `json:"runtime,omitempty,string"`
    //...
}
```

And the resulting JSON output would look like -- 

```json
{
    //...
    "runtime": "102",
    //...
}
```

#### Formatting and Enveloping Responses -- 

In this book generally been making requests to our API using -- which makes the JSON responses easy-to-read thanks to the pretty printing’s provided by the built-in JSON viewer.

By using struct tags, adding whitespace and enveloping the data, we’ve been able to add quite lot of customization to our JSON responses already. Strictly speaking, when Go is encoding a particular type to JSON it looks to see if the type statisfies the `json.Marshal`interface, which looks just like -- 

```go
type Marshaler interface {
    MarshalJSON() ([]byte, error)
}
```

And the the type does satisfy the interface, then Go will call its `MarshalJSON()`method and use the `[]byte`slice that it returns as the encoded JSON value. And if the type doesn’t have a `MarshalJSON()`method, then Go will fall back to trying to encode it to JSON based on its own internal set of rules. Fore 

```json
{
    "runtime": "102 mins",
}
```

And there are a few ways could achieve this, but a clean and simple approach is to create a custom type specifically for the Runtime field.

```go
func (r Runtime) MarshalJSON() ([]byte, error) {
	// Generate a string containing the movie runtime in the required format
	jsonValue := fmt.Sprintf("%d mins", r)

	// Use the strconv.Quote() on the string to wrap it in double quotes.
	quotedJsonValue := strconv.Quote(jsonValue)
	return []byte(quotedJsonValue), nil
}
```

#### Sending Error Message

At this point our API is sending nicely formatted JSON responses for successful requests, but if a client makes a bad request -- or sth goes wrong in our app -- still sending them a plain-text error message from `http.Error()`and `http.NotFound()`functions.

```go
func (app *application) errorResponse(w http.ResponseWriter, r *http.Request, status int, message interface{}) {
	env := envelope{"error": message}

	err := app.writeJSON(w, status, env, nil)
	if err != nil {
		app.logger.Error(err.Error())
		w.WriteHeader(http.StatusInternalServerError)
	}
}

func (app *application) serverErrorResponse(w http.ResponseWriter, r *http.Request, err error) {
	app.logger.Error(err.Error(), "request_method", r.Method, "request_url", r.URL.String())

	message := "the server encountered a problem and could not process your request"
	app.errorResponse(w, r, http.StatusInternalServerError, message)
}
```

##### Routing errors

Any error messages that our own API handlers send will now be well-formed JSON response -- What about the error message that `httprotuer`automatically sends when it can’t find a matching route -- just like:

```go
func (app *application) routes() http.Handler {
	// Initialize a new httprouter router instance.
	router := httprouter.New()

	router.NotFound = http.HandlerFunc(app.notFoundResponse)
	router.MethodNotAllowed = http.HandlerFunc(app.methodNotAllowedResponse)
    //...
}
```

##### Panic Recovery

Add a new `recoverPanic()`middleware - 

```go
func(app *application) receoverPanic(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if err := recover(); err!=nil {
                // if there was a panic, set a `Connection: close`on the response, this acts as a 
                // trigger to make Go's HTTP server automatically close the current after a resp
                // has been sent.
                w.Header().Set("connection", "close")
                app.serverErrorResponse(w, r, fmt.Errorf("%s", err))
            }
        }()
        next.ServeHttp(w, r)
    })   
}

func (app *application) routes() http.Handler {
    //...
    return app.receoverPanic(router)
}
```

### Parsing JSON requests

Been looking at how to create and send JSON responses from our API, but in this text section of the book we are going to explore things from the other side and discuss how to read and parse JSON requests from clients. When a client calls this endpoint, will expect them to provide a JSON request body containing data for the movie they want to create in our system.

```json
{
    "title": "Moana",
    "year": 2016,
    "runtime": 107,
    "genres": ["animation", "adventure"]
}
```

#### Json Decoding

There are also two approaches that U can take to decode JSON into a native Go object -- using `json.Decoder`type or using the `json.Unmarshal()`function.

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Response) {
    var input struct {
        Title string `json:"title"`
        //...
    }
    // Initialize a new json.Decoder instance which reads from the request body, and then
    // use the Decode() method to decode the body contents
    err := json.NewDecoder(r.Body).Decode(&input)
}
```

There are few important and interesting thing about this code to point out -- 

- When calling `Decode()`, must pass a non-nil pointers as the target decode destination.
- NOTE: if the targt decode destination is a struct, like in our case, then must be exported.
- When decoding a JSON body into a struct, the k/v pairs in the JSON are mapped to the struct fields based on the struct tag names. If there is no matching struct tag, Go will attempt to decode the value into a field that matches the key name.
- And, there is no need to close `r.Body`after it has been read. This will be done automatically by Go’s `http.Server`.

Leads to an interesting question -- how can U tell the difference between a client not providing a k/v pair, and providing a K/V pair but deliberately setting it to its zero value - like -- 

```sh
BODY='{"title":"Moana","year":0,"runtime":107, "genres":["animation","adventure"]}'
curl -d "$BODY" localhost:4000/v1/movies
```

For this, the end result is the same, despite the different HTTP requests, and it’s not immediately obvious how to tell the difference between the two scenairos.

##### Using the `json.Unmarshal`function

It’s also possible to use the `json.Unmarshal()`function to decode an HTTP request body -- like:

```go
func (app *application) exampleHandler(w http.ResonseWriter, r *http.Request) {
    var input string {
        Foo string `json:"foo"`
    }
    
    body, err := io.ReadAll(r.Body)
    if err != nil {
        app.serverErrResponse(w, r, err)
        return
    }
    
    // Use the json.Unmarshal() func to decode the JSON in the `[]byte` slice to the input struct
    err = json.Unmarshal(body, &input)
    if err != nil {
        app.errReponse(...)
        return
    }
}
```

#### Managing Bad Requests

The `Decode()`method potentially return the following five type of error -- 

| **Error Type**                   | **Reason for Occurrence**                                    | **Error Category**  |
| -------------------------------- | ------------------------------------------------------------ | ------------------- |
| **`json.SyntaxError`**           | There is a **syntax problem** with the JSON being decoded (e.g., missing a comma, trailing comma, or unclosed brackets). | Client/Input Error  |
| **`json.UnmarshalTypeError`**    | A JSON value is **not appropriate** for the destination Go type (e.g., trying to decode a JSON string into a Go `int`). | Type Mismatch       |
| **`json.InvalidUnmarshalError`** | The decode destination is **not valid**. This usually happens when you pass a non-pointer or a `nil` value to `json.Unmarshal`. This is an **application code bug**. | Developer Error     |
| **`io.EOF`**                     | The JSON being decoded is **empty**. This often happens when reading from an empty request body or file. | Input Error         |
| **`io.ErrUnexpectedEOF`**        | The input stream **ended abruptly** while the decoder was still expecting more data (e.g., a truncated JSON string). | Network/Input Error |

Triging these potential errors which can do using Go’s `error.Is()`and `errors.As()`is going to make the code in our `createMovieHandler`a lot longer and more complicated.

### Testing the untestable

Most of the testing we’ve done so far in this -- has been of the comare want and got kind -- call some func with prepared inputs, and compare its results to what we expected. First,how do we even start -- begin a new project, we may not even have an clear idea of exactly what it should do and how it should behave.

This articles focuses on a core philophy of modern software enginerring -- building an end-to-end working system as early as possible and deploying it to production as early as possible.

##### What is a *walking skeleton* -- 

- It’s not just code -- it has to be buidlable, deployable and test-end-to-end.
- Mninimalist functionality -- its business logic is simple, it can even be described as boring -- 
- Although the business logic is simple, it must connect all architctural layers.

Core objectives -- 

- Focus on infrastructure rather than business details -- In the early stage of a proj, the hardest part is often not writing business code, but the connection betwen components.
- Expose integration issues early -- The complexity of software engineering lies in the interaction between components. By building the skeleton, can finish the most time-consuming pipe connection work first.
- The basis for rapid iteration -- Once the skeleton is built, the subsequent development is to fill the skeleton with meat, which can be iterated very quickly.

#### Testing Production -- 

This is highly controversial but increasingly accepted view, quoting Charity Majors.

Traditional concepts vs. Modern Realtiy -- 

- Conventional wisdom -- The production environment is sacred and must not be tested on it. All testing must be completed in Staging environment.
- Modern Reality -- A staging environment can never emulate production environment 100%.

##### Why Embrce production Testing -- 

1. Isolation tests have limited value -- unit tests and integration tests can only tell U how your code runs isolation.
2. Complex systems -- Modern systems contains unpredictable factors as user behavior, network fluctutions.

If you are string a new project - this text suggests that your follow these steps -- 

1. Don’t start by designing grandiose architectures or writing complex business logic
2. Building skeleton - Write the simplest *Walking sekleton* that can run through the whole process.
3. Go live now -- Deploy this skeleton to a real production environemnt
4. Continuous integration -- Establish a test system with only minor changes at a time to ensure that system is always is always operational.
5. Confront the truth -- Accept the fact that the test environment if fake and learn to use the production environment to verify the true behavior of the system.

