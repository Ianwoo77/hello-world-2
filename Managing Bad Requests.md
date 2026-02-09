# Managing Bad Requests

Our `CreateMovieHandle`now works well when it receives a valid JSON request body with the appropriate data. But, what if:

- Not JSON
- JSON is malformed or contians an error
- JSON types don’t match the types we are tryuing to decode into
- doesn’t even contain a body.

When it receives an invalid request that can’t be decoded into our `input`struct, no further processing takes place and the client is sent a JSON response containing the error message returned by the `Decode()`method.

Triaging the Decode error -- 

- `json.SyntaxError, io.ErrUnexpectedEOF`-- syntax problem
- `json.UnmarshalTypeError`-- JSON value is not appropraite for dest Go type
- `json.InvalidUnmarshalError`-- decode dest is not valid - usually it is not a pointer
- `io.EOF`- Json being decoded is just empty

```go
func (app *application) readJSON(w http.ResponseWriter, r *http.Request, dst interface{}) error {
	err := json.NewDecoder(r.Body).Decode(dst)
	if err != nil {
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError
		var invalidUnmarshalError *json.InvalidUnmarshalError

		switch {
          // Has a json.SyntaxError?
		case errors.As(err, &syntaxError): // syntaxError already is a pointer
			return fmt.Errorf("body contains badly-formed JSON (at character %d)", 
                              syntaxError.Offset)
		case errors.Is(err, http.ErrBodyReadAfterClose):
			return errors.New("body must not be empty")
		case errors.As(err, &unmarshalTypeError):
			if unmarshalTypeError.Field != "" {
				return fmt.Errorf("body contains incorrect JSON type for field %q", unmarshalTypeError.Field)
			}
			return fmt.Errorf("body contains incorrect JSON type (at character %d)", unmarshalTypeError.Offset)
		case errors.As(err, &invalidUnmarshalError):
			panic(err)
		default:
			return err
		}
	}
	return nil
}
```

1. `errors.Is`-- used to determine whether an error equals a specific *Sentinel* error - Usually a globally defined variable. When U just want to know *what happens to specific error* without needing to know the specific details of the eorr. Typically used to compare predefined global error variables in standard libraries of 3rd-party libs.

2. `errors.As`-- Used to determine if an error *belongs to* a particular type. When Want to read not only the type of the error, but also the data inside the eror, fore:

   ```go
   var syntaxError *json.SyntaxError
   // ...
   case errors.As(err, &syntaxError):
       return fmt.Errorf("body contains badly-formed JSON (at character %d)", 
                         syntaxError.Offset)
   ```

   `As`'s 2nd argument must be a pointer to an interface or implement type pointer.

One-sentence -- 

- If it’s a static error defined globally, use `Is`
- If it’s a struct type and you need to *read the fields inside*, use `As`.

Then with this new helper in place, head back to the `cmd/api/movies.go`file and update `createMovieHandler`. Fore: use this can like:

```go
func (app *application) createmMovieHandler(w http.ResponseWriter, r *http.Request) {
    var input struct {
        title string `json:"title"`
        //...
    }
    err := app.readJSON(w, r, &input)
    if err != nil {
        app.errorResponse(w, r, http.StatusRquest, err.Error())
    }
    //...
}
```

##### Making a bad request helper

In the `createMovieHandler`code-- `app.errorResponse()`helper to send the client a *400 Bad request* response along with the error message. So just change it like:

```go
func (app *application) badRequestResponse(w http.ResponseWriter, r *http.Reqeust, err error) {
    app.errorRepsonse(w, r, http.StatusBadRequest, err.Error())
}

// Using the new helper
if err != nil {
    app.badRequestResponse(w, r, err)
    return
}
```

##### Panicking vs returning errors -- 

The decision to panic in the `readJSON()`if get `json.InvalidUnmarshalError`error -- Cuz doesn’t pass a pointer usually. In some specific cases, using `panic`is acceptable. When using `panic`is logical, U don’t have to be too dogmatic about rejecting it.

1. Expected errors - That can occur in anticipation during normal operation. In the vast majority of cases, returning such errors and handling them gracefully is best practice.
2. Unexpected errors - Due to *developer error* or *logic errors* in the code. this type is truly an **exceptional** condition, and the use of the `panic`is more acceptable in this environment.

Even so, Still recommend trying to go back and handle unexpected errors gracefully in most cases. The only exception is when returining an error adds an *unacceptable error handling cost to rest the codebase*. Fore the `InValidUnmarshalError`-- passed an unsupported value to `Decode()`. If choose to return this error instead of `panic`-- have to introduce additional code in every `API`handler to manage it.

#### Restricting Inputs

The changes that we made in the previous to deal with invalid JSON and other bad requests were a big step in the right direction, there are stil a few things we can do to make our JSON processing even more robust. One such thing is dealing with *unknown* fields -- fore, can try sending a request containing the unknown field `rating`...

For now, this request works wouthout any problems -- there is no error to inform the client tha the `rating`field is not recognized by the app. In certain scenarios, silently ignoring unknown fields may e extractly the behavior you want. Note -- Go’s `json.Decoder`provides a `DisallowUnknownFields()`setting that we can use to generate an error when this happens.

Another problem - `json.Decoder`is just designed to support *streams* of JSON data. When call `Decode()`on request body, it actually reads the first JSON value only from the body and decodes it - if made a second call to `Decode()`then would read and decode second value and so on.

In the `readJSON()`helper, anything after the first JSON value in the request body is ignored. This means that U should send a request body containing multiple JSON values, or garbage content after the first JSON value, and our API handles would not raise an error -- fore:

Finally, there is currently no upper-limit on the maximum size of the request body that we accept. This means that our `createMovieHandler`would be a good target for any malicious clients that wish to perform a *denial-of-service* attck on our API. Can address this by using `http.MaxBytesReader()`. And to ensure there are no additional JSON values.

```go
func (app *application) readJSON(w http.ResponseWriter, r *http.Request, dst interface{}) error {
	// use the http.MaxBytesReader to limit the size of the request body to 1MB.
	maxBytes := 1_048_576
	r.Body = http.MaxBytesReader(w, r.Body, int64(maxBytes))
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	err := dec.Decode(&dst)

	if err != nil {
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError
		var invalidUnmarshalError *json.InvalidUnmarshalError
		var maxBytesError *http.MaxBytesError

		switch {
		case errors.As(err, &syntaxError):
			return fmt.Errorf("body contains badly-formed JSON (at character %d)", syntaxError.Offset)
		case errors.Is(err, http.ErrBodyReadAfterClose):
			return errors.New("body must not be empty")
		case errors.As(err, &unmarshalTypeError):
			if unmarshalTypeError.Field != "" {
				return fmt.Errorf("body contains incorrect JSON type for field %q", unmarshalTypeError.Field)
			}
			return fmt.Errorf("body contains incorrect JSON type (at character %d)", unmarshalTypeError.Offset)
		case errors.Is(err, io.EOF):
			return errors.New("body must not be empty")

		// If the JSON contains a field which cannot be mapped to the target destination,
		// Then Decode() will now return an error message in the format
		// 'json: unknown field "foo"' fore.
		case strings.HasPrefix(err.Error(), "json: unknown filed"):
			fieldName := strings.TrimPrefix(err.Error(), "json: unknown field ")
			return fmt.Errorf("body contains unknown key %s", fieldName)

		case errors.As(err, &maxBytesError):
			return fmt.Errorf("body must not be larger then %b bytes",
				maxBytesError.Limit)
		case errors.As(err, &invalidUnmarshalError):
			panic(err)
		default:
			return err
		}
	}

	// call Decode() again, using a pointer to an empty anonymous struct as the
	// destination. If the request body only contained a single JSON value this will
	// return an io.EOF. So if get anything else, know that there is additional data
	// in the request body  and we return our custom error message
	err = dec.Decode(&struct{}{})
	if !errors.Is(err, io.EOF) {
		return errors.New("body must only contain a single JSON value")
	}
	return nil
}
```

#### Custom JSON Decoding

Going to look at custom format in the other side and update our app so that the `createMovieHandler`accepts runtime info in this format. If U try sending a request with the movie runtime in this format right now, get a *400 request* response -- into an `int32`type like:

```sh
curl -d '{"title": "Moana", "runtime": "107 mins"}' localhost:4000/v1/movies
```

To mke this work, Go’s `Unmarshal`interface -- 

```go
type Unmarshaler interface {
    UnmarshalJSON([]byte) error
}
```

When Go is decoding some JSON -- will check to see if the destination type satisfies the `json.Unmarshaler`interface, it does satisfy the interface, the Go will call it’s `UnmarshalJSON()`method to determine how to decode the provided JSON into the taret type. Just change it to:

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title   string       `json:"title"`
		Year    int32        `json:"year"`
		Runtime data.Runtime `json:"runtime"`
		Genres  []string     `json:"genres"`
	}
    //...
```

It’s actually a little bit intricate, and there are some important details, so probably best to jump into the code and explain things without comments as we go -- like:

```go
func (r *Runtime) UnmarshalJSON(jsonValue []byte) error { // Runtime is `type Runtime int32`
	// Unquote the JSON string value
	unquotedJSONValue, err := strconv.Unquote(string(jsonValue))
	if err != nil {
		return ErrInvalidRuntimeFormat
	}

	// Split the string to separate the number from " mins"
	parts := strings.Fields(unquotedJSONValue)
	if len(parts) != 2 || parts[1] != "mins" {
		return ErrInvalidRuntimeFormat
	}

	// Parse the number part
	i, err := strconv.ParseInt(parts[0], 10, 32)
	if err != nil {
		return ErrInvalidRuntimeFormat
	}

	// Set the value
	*r = Runtime(i)
	return nil
}
```

#### Validating JSON input -- 

In many cases, want to perform additional validation checks on the data from a client to make sure it meets your speicifc business rules before processing it. `internal/validator`package with some simple reusable helper types.

```go
var (
	EmailRX = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
)

type Validator struct {
	Errors map[string]string
}

func New() *Validator {
	return &Validator{Errors: make(map[string]string)}
}

func (v *Validator) Valid() bool {
	return len(v.Errors) == 0
}

func (v *Validator) AddError(key, message string) {
	if _, exists := v.Errors[key]; !exists {
		v.Errors[key] = message
	}
}

func (v *Validator) Check(ok bool, key, message string) {
	if !ok {
		v.AddError(key, message)
	}
}

func PermittedValue[T comparable](value T, permittedValues ...T) bool {
	return slices.Contains(permittedValues, value)
}

func Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}

func Unique[T comparable](values []T) bool {
	uniqueValues := make(map[T]bool)

	for _, value := range values {
		uniqueValues[value] = true
	}

	return len(values) == len(uniqueValues)
}
```

##### Performing validation errors -- 

The first thing need to do is to update `cmd/api/errors.go`file to include a new `failedValidaionResponse()`helper, which writes a 422 *Unprocessable Entity* and the contents of the errors map from our new `Validator`type as a JSON response body.

```go
func (app *application) failedValidationResponse(w http.ResponseWeiter, r *http.Request,
                                                 errors map[string]string) {
    app.errorResponse(w, r, http.StatusUnprocessableEntity, errors)
}
```

##### Making validation rules reusable - 

In large project it’s likely that you will want to reuse some of the same validation checks in multiple places, in the case -- fore -- want to use many of these same checks later when a client *edits* the movie data. To prevent duplication, can collect the validation checks for a movie into a standalone `ValidateMovie()`function.

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

func ValidateMovie(v *validator.Validator, movie *Movie) {
	v.Check(movie.Title != "", "title", "must be provided")
	v.Check(len(movie.Title) <= 500, "title", "must not be more than 500 bytes long")

	v.Check(movie.Year != 0, "year", "must be provided")
	v.Check(movie.Year >= 1888, "year", "must be greater than 1888")
	v.Check(movie.Year <= int32(time.Now().Year()), "year", "must not be in the future")

	// ...
}
```

