# Function optiona pattern

The last approach -- The main idea is as follows -- like:

- An unexported struct holds the configuraiton `options`
- Each option is a function that returns same type `type Option func(option *potions) error`-- `WithPort`accepts an `int`argument that represents the port and returns an `Option`type that represents how to update the `options`struct like:

```go
type options struct {
    port *int
}
type Option func(options *options) error

func WithPort(port int) Option {
    return func(options *options) error {
        if port < 0 {
            return errors.New("Port should be positive")
        }
        options.port=&port
        return nil
    }
}
```

`WithPort`returns a closure. use these just like:

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    
    var port int
    if options.port==nil {
        port = defaultHTTPPort
    }else {
        if *port.port==0 {
            port = randomPort()
        }else {
            port = *options.port
        }
    }
}
```

### Which type of receiver to use

Choosing a reveibver type of a method isn’t always straightforward. When should we use value receivers and pointer receivers -- In many contexts, using a value or pointer receivers should be dictated not by performance but rather by other conditions.

With a value receiver, Go just makes a copy of the value and passes it to the method. WIth a pointer receiver, Go passes the address of an object to the method. Fore:

```go
type customer struct {
    balance float64
}
func (c *customer) add(operation float64) {
    c.balance += operation
}
```

And if the method receiver contains a field that cannot be copied -- fore, a type part of the `sync`package -- And if the reveiver is a *map, function, channle* **must** be a value.

### Side effects with named result parameters

As these result parameters are just initialized to their zero value -- using them can sometimes lead to subtle bugs.

```go
func (l loc) getCoordinates (ctx contxt.Context, address string) (
    lat, lng float32, err error) {
    isValid := l.validateAddress(address)
    if !isValid {
        return 0, 0, errors.New("Invalid address")
    }
    if ctx.Err() != nil {
        return 0, 0, err // havn't assigned any value to the err variable
    }
}
```

One possible fix to assign `ctx.Err()`to err like so -- 

```go
if err := ctx.Err(); err != nil {
    return 0, 0, err
}
```

### Returning a `nil`receiver

Will work on a `Customer`struct and implement a `Validate`method to perform sanity checks -- Instead of returning the first error, want to return a list of errors like:

```go
type MultiError struct {
    errs []string
}
func (m *MultiError) Add(err error) {
    m.errs = append(m.errs, err.Error())
}
func (m *MultiError) Error() string {
    return strings.Join(m.errs, ";")
}
```

So the `MultiError`satisfies the `error`and implements `Error() string`and also exposes an `Add`to append an error. Using this struct, can implement a `Customer.Validate()`in the following manner -- like:

```go
func (c Customer) Valiate() error {
    var m *MultiError
    //...
    if .Age<0 {
        m= &MultiError{}
        m.Add(errors.New("age is negative"))
    }
    //...
    return m
}
```

For this, `m`is initialized to the zero value of `*MultiError`- `nil`--when a sanity check fails, we allocate a new `MultiError`if needed and then append an error. If:

```go
customer := Customer{Age:33, Name:"John"}
if err := customer.Validate(); err != nil {
    log.Fatalf(..., err)
}
```

The `Customer`is just valid, yet the `err != nil`condition was `true`, and logging the error printed `<nil>`. Just need to not that a pointer receiver can be `nil` -- 

```go
type Foo struct {}
foo (foo *Foo) Bar() string {
    return "bar"
}
func main(){
    var foo *Foo 	// foo is nil
    println(foo.Bar())
}
```

`foo`is `nil`but this code complies. In Go, a method just a syntactic sugar for a function whose first parameter is a receiver -- hence, the `Bar`method is similar to -- 

```go
func Bar(foo *Foo) string {
    return "bar"
}
```

Knowing that passing a nil pointer to a function is valid. For the function -- `m`is just initialized to the zero value of a pointer `nil`-- then if all checks are valid, just a `nil`pointer returns. So: should be clear:

```go
func (c Customer) Validte() error {
    var m *MultiError
    //...
    if m != nil {
        return m
    }
    return nil
}
```

At then end of the method, just check whether `m`is not `nil`-- if that is `true`, return `m`-- otherwise, return `nil`explicitly needed.

### Mandatory arguments are annoying

If a global variable is no good then it follows elegantly that need some *local* variable -- 

```go
type Printer struct {
    Output io.Writer
}
// each Printer could have its own individual Output
func (p *Printer) Print() {
    fmt.Fprintln(p.Output, "Hello")
}
// so can :
p := &hello.Printer{Output: os.Stdout}
p.Print
```

#### A convenience wrapper with defaults

We can just provide some trivial wrapper function that absorbs the unncessary paperwork --  fore:

```go
func main() {
    NewPrinter().Print()
}
type Printer struct {
    Output io.Writer
}
func NewPrinter() *Printer {
    return &Printer{
        Output: os.Stdout,
    }
}
func (p *Printer) Print(){
    fmt.Println(p.Output, "hello")
}
```

A simple line counter -- apply one that counts the number of lines in its input and prints the result to its output like:

```go
func main(){
    lines := 0
    input := bufio.NewScanner(os.Stdin)
    for input.Scan() {
        lines++
    }
    fmt.Println(lines)
}
```

For this, Focus on behaviour, not implementation -- Any time U take input, assume that it will be of arbitrary size, larger than avaialble memory -- process it in bite-size chuncks -- rather then all at once. For this -- Design and implement a line-counting package -- test-first, in the same way we did with `hello`. The challenge here is how to turn this behaviro into an importable *package* -- Also need to be able test it -- that suggests we don’t want to read directly from the `os.Stdin`-- think about a counter object that could be configured with some `Input`-- 

One possible first version -- start with a test -- like:

```go
package count

import (
	//...
)

type counter struct {
	Input io.Reader
}

func NewCounter() *counter {
	return &counter{
		Input: os.Stdin,
	}
}

func (c *counter) Lines() int {
	lines := 0
	input := bufio.NewScanner(c.Input)
	for input.Scan() {
		lines++
	}
	return lines
}

func Main() {
	fmt.Println(NewCounter().Lines())
}
```

```go
func TestLinesCountsLinesInInput(t *testing.T) {
	t.Parallel()
	c := count.NewCounter()
	c.Input = bytes.NewBufferString("1\n2\n3")
	wants := 3
	got := c.Lines()
	if got != wants {
		t.Errorf("got %d; want %d", got, wants)
	}
}
```

To recap, we said that paractical programs often need some kind of configuration in order to be flexible. A useful patter in Go is to have some kind of object -- some struct, 

### Config structs don’t solve the problem --

A common, but not very satisfctory pattern -- ist to create some *config struct* type and pass that to the ctor instead:

```go
type Config struct {
    Input io.Reader
    Output io.Writer
}
func MakeCounterWithConfig(confg Config) *conter {
    c := NewCounter()
    c.Input = config.Input
    c.Output= config.Output
    return c
}
```

For this -- pointless -- already have a struct that contains the config information -- the `counter`itself -- Adding another struct type doesn’t help users.

## Validating JSON Input

In many cases, you will want to perform additional validation checks on the data from a client to make sure it seems your specific business rules before processing it. Illustrate how to do that in the context of a JSON API by updating `createMovieHandler`to check -- And if any those checks fail, want to send the client a 422 Unprocessable Entity response along with error messages -- 

### Creating a validator package -- 

To help with validtion throughout this project -- going to creat a small `internal/validator`package with some reusable helper types and functions -- like

```go
var (
	EmailRx = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
)

// Validator Define a new validator type which contains a map of validation errors
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

func permittedValue[T comparable](value T, permittedValues ...T) bool {
	for i := range permittedValues {
		if value == permittedValues[i] {
			return true
		}
	}
	return false
}

// Matches returns true if a string value matches a specific regexp pattern
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

For this, code, defined a custom `Validator`type which contains a map of errors. The `Valiator`type provides a `Check()`for conditionally adding errors to the map -- `Valid()`returns whether the errors map is empty or not. Conceptually this is quite basic.

#### Performing validation checks

The first thing we need to do is update our `errors.go`file to include a new `failedValdationResponse()`-- 

```go
func (app *application) failedValidationResponse(w http.ResponseWriter, r *http.Request,
	errors map[string]string) {
	app.errorResponse(w, r, http.StatusUnprocessableEntity, errors)
}
```

Back to your `createMovieHandler`and update it to perform the necessary validation checks in the `input`like:

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
	// Declare an anonymous struct to hold the info that we expect to be in the HTTP
	// request body
	var input struct {
		Title   string       `json:"title"`
		Year    int32        `json:"year"`
		Runtime data.Runtime `json:"runtime"`
		Genres  []string     `json:"genres"`
	}

	//...
	// initialize a new validator
	v := validator.New()

	// Use the Check() to execute our checks, this will add the provided key and error
	// message to the errors map if the check does not evaluate to true
	v.Check(input.Title != "", "title", "must be provided")
	v.Check(len(input.Title) <= 500, "title", "must not be more than 500 bytes long")

	v.Check(input.Year != 0, "year", "must be provided")
	v.Check(input.Year >= 1888, "year", "must be greater then 1888")
	v.Check(input.Year <= int32(time.Now().Year()), "year",
		"must not be in the future")

	v.Check(input.Runtime != 0, "runtime", "must be provided")
	v.Check(input.Runtime > 0, "runtime", "must be a positive integer")
	v.Check(input.Genres != nil, "genres", "must be provided")
	v.Check(len(input.Genres) >= 1, "genres", "must contain at least 1 genre")
	v.Check(len(input.Genres) <= 5, "genres", "must not contain more than 5 genres")

	v.Check(validator.Unique(input.Genres), "genres", "must contain unique values")

	// Use the Valid() method to see if any of the checks faled
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	fmt.Fprintf(w, "%+v\n", input)
}
```

With that done, should be good to try this out -- Restart the API, then go ahead and issue a request to the `POST /v1/movies`endpoint containing some invlaid data . Our validation checks are working and preventing the request from being executed successfully -- the client getting a nicely formed JSON reponse with clear, informative error messages for each problem.

#### Making validatoin rules reusable

In large projects -- it’s likely that you will want to reuse some of the same validation checks in multiple places -- fore, want to use many of these same checks later when a client *edits* the movie data.

To prevent duplication -- can collect the validation checks for a movie into a standalone `ValidationMovie()`-- In theory -- this func could live almost anywhere in codebase. Should just keep the validation checks close to the relevant domain type in the `internal/data`package like:

```go
func ValidateMovie(v *validator.Validator, movie *Movie) {
	v.Check(movie.Title != "", "title", "must be provided")
	//...
}
```

Head back to our `createMovieHandler()`and update it to initialize a new `Movie`struct.

```go
movie := &data.Movie {
    Title:   input.Title,
    Year:    input.Year,
    Runtime: input.Runtime,
    Genres:  input.Genres,
}

v := validator.New()
if data.ValidateMovie(v, movie); !v.Valid() {
    app.failedValidationResponse(w, r, v.Errors)
    return
}
```

Might be wondering why initializing the `Validator`instance in our handler and passing it to the `ValiateMovie()`-- rather then initializing it in `ValiateMovie()`and pasing it back as a return value -- cuz as our app gets more complex need call *Multiple* validation helpers from our handlers.

And why are decoding the JSON request into the `input`struct first, and then copying the data across, rather then just decoding into the `Movie`struct directly -- For this just like DTO.

### Dbs setup and Configuration

In this next section of the book goint to move forward with our project build and set up a SQL dbs to persistently store our movie data. Using *PostgreSQL* -- including support for array and JSON data types, full-text search, and geospatial queries.

When PostgreSQL is freshly installed -- superuser called `postgres`-- in the first instance need to connect to PostgreSQL at this supersuer to do anything. Also, during installation, an *OS system* user named `postgres`should have been created on the machine like:

```sh
cat /etc/passwd | grep 'postgres'
```

This is just important cuz -- by default, PSQL uses an authentication scheme called *peer authentication* for any connections from the local machine -- For this -- if current OS user’s name matches a valid PostgreSQL user name, can log into PostgreSQL as that user with no further authentication.

```sh
sudo -u postgres psql
```

Then just confirm this by running some query statement like:

```sql
SELECT current_user;
```

Creating dbs, users, and extensions -- 