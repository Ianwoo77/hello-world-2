# Multikey Indexes

An index created on the fields of an array type is called multikey index -- when an index field is passes as an argument to the `createIndex`function, Mdb creates an index entry for each element of the array. The syntax of `createIndex`element is the same as that for creating an index of a regular (non-array) field.

```js
db.collectoinName.createIndex({arrayFieldName: sortOrder});
```

MongoDB inspects the input field, and if it is an array, a multikey index will be created. like:

```js
db.movies.createIndex({languages:1})
```

This query adds an index on the languages field, which is an array, in Mdb, can find documents based on an element of their array fields.

#### Text indexes -- 

An index defined on a string field or an array of string elements is called a text index -- Text indexes are not sorted, meaning that they are faster then normal indexes -- the syntax to create a text index is as :

```js
db.collecitonName.createIndex({fieldName: "text"})
// like:
db.users.createIndex({name: 'text'})
```

#### Indexes on Nested Documetns

A document can contain nested objects group a new attributes. fore, the theaters collection in the `sample_mflix`dbs contains the `location`-- which has a nested object like:

```js
db.theates.createIndex({"location.address.zipcode": 1})
```

Can also create an index on the embedded document. just create an index on the `location`field instead of its attributes -- like:

```js
db.theaters.createIndex({'location': 1})
```

### Wildcard indexes

Mdb supports flexible schema, and so, different documents can have fields of varying types and quantities - it can be difficult to create and maintain indexes on non-uniform fields that are not present in all docs -- Also, when a new fields is introduced into a document, it remains unindexed.

Mdb provides wildcard indexes to resolve this problem, fore:

```js
db.products.createIndex(
	{'specifications.$**': 1}
)
```

Similarly, wildcard indexes can be created on the top-level fields of a collection as well -- 

```js
db.products.createIndex({'$**': 1})
```

This preceding command creates indexes on all fields of all documents. Thus , all the new fields added to the documents will be indexed by default.

Can also select or omit specific fields from the wildcard indexes by passing a `wildcardProjuection`option and one or more field names -- like:

```js
db.products.createIndex(
	{'$**':1},
    // creates wildcards on all excluding the `name` field.
    {wildcardProjection: {'name': 0}}
)
```

### Properties of Indexes - 

Will cover different properties of indexes in Mdb -- an index property can influence the usage of an index and can also enforce some behavior on the collection. Index propertes are passed as an option to the `createIndex`function like:

```js
db.collection.createIndex(
	{field: type},
    {unique: true} // unique indexes
)
```

#### Creating a unique index

```js
db.theaters.findOne();
db.theaters.insertOne({theaterId: 1012}) // here a duplicate item occurred
db.theaters.createIndex(
	{theaterId: 1}
)
```

For this just drop it first:

```js
db.theaters.getIndexes()
db.theaters.dropIndex('theaterId_1')
db.theaters.createIndex({ theaterId: 1}, { unique: true });
// duplicateKey error occurred
db.theaters.insertOne({theaterId: 1002})
```

#### TTL indexes

TTL indexes put an *expiry* on documents - once the documents have expired, they (documents) are deleted. This index can *only be created on a field of the date type* -- just like:

```js
db.collection.createIndex({field: type},
                         {expireAfterSeconds: seconds});
```

Creating using Mongo Shell -- in this, will create TTL index on a collection called `review`-- a field called `reviewDate`will be used to capture the current date and time of the review -- like:

```js
db.reviews.insertMany([
    {"reviewer": "Eliyana A", "movie": "Cast Away", "review": "Interesting plot", "reviewDate": new Date()},
    {"reviewer": "Zaid A", "movie": "Sully", "review": "Captivating", "reviewDate": new Date()}
    ]
);
```

Then just introduce a TTL index to expire documents older than 60s -- using the following command just like:

```js
db.reviews.createIndex(
    {reviewDate: 1},
    {expireAfterSeconds: 60}
)
```

#### Sparse indexes

- *selective indexing* -- only documents with the indexed field are included in the index -- Documents without the field or with a `null`value for the field are excluded
- *smaller size* -- Don’t index every document.
- Ideal for fields are present in only a subset of document, optional fields
- Queries that use the sparse index can be faster.

```js
db.users2.insertMany([
    { name: "Alice", email: "alice@example.com" },
    { name: "Bob", email: "bob@example.com", phone_number: "123-456-7890" },
    { name: "Charlie", email: "charlie@example.com", phone_number: "987-654-3210" }
]);

db.users2.find()
```

For this, if create a sparse index on `phone_number`-- like:

```js
db.users2.createIndex(
    {phone_number:1},
    {sparse: true}
)
```

And If the field does not exist in a document, a `null`value is registered for that document -- conversely, if an index is marked as `sparse`-- then only those documents are registered in which the given field exises with some value including `null`-- A sparse index will not have entries from the collection where the indexed field does not exist, and that is why this type of index is called sparse.

Compound indexes can also be marked as sparse -- for a compound sparse index, only those documetns are registered where the combination of fields exists.

#### Creating a sparse -- 

Will create a sparse index on the `review`field in the `reviews`collection -- 

```js
db.reviews.createIndex(
    {reviewDate: 1},
    {sparse: true}
)
// then insert a new 
db.reviews.insertOne(
    {"reviewer" : "Jamshed A" , "movie" : "Gladiator"}
)
```

Check the size of the index using the `stats()`function -- `db.reviews.stats()`function -- Can see the size of the `review_1`index has not changed -- this is cuz that the last document was not registered in the index.

## The `or`-channel

At times U may find yourself wanting to combine one or more `done`channels into a single `done`channel that closes if any of its component channels close -- it is prefectly acceptable -- albeit verbose, to just write a `select`statement that performs this coupling -- U can combine these channels together using the *or-channel* pattern -- This pattern creates a composite `done`channel through recursion and goroutine -- like:

```go
func or(channels ...<-chan struct{}) <-chan struct{} {
	switch len(channels) {
	case 0:
		// if empty, just simply return nil to terminate the recursive func
		return nil
	case 1:
		// only one, just return
		return channels[0]
	}
	// main logic, for two or more channels, creates a new channel
	// orDone to signal when any input channels closes
	orDone := make(chan struct{})
	go func() {
		defer close(orDone)
		switch len(channels) {
		case 2:
			select {
			case <-channels[0]:
			case <-channels[1]:
			}
		default:
			select {
			case <-channels[0]:
			case <-channels[1]:
			case <-channels[2]:
			case <-or(append(channels[3:], orDone)...):
			}
		}
	}()
	return orDone
}
```

For this, is a farily concise function that enables U to combine any number of channels together into a single channel that will close as soon as any of its component channels are closed.

```go
func sig(after time.Duration) <-chan struct{} {
	c := make(chan struct{})
	go func() {
		defer close(c)
		time.Sleep(after)
	}()
	return c
}

func main() {
	start := time.Now()
	<-or(
		sig(2*time.Hour),
		sig(5*time.Minute),
		sig(time.Second),
		sig(time.Hour),
	)
	fmt.Printf("after %v done", time.Since(start))
}
```

#### Error Handling

in concurrent programs, error handling can be just difficult to get right -- sometimes, we spend so much time thinking about how various processes will be sharing info and coordinating -- they will gracefully handle errored stages -- when Go eschewed the popular exception model of errors, it made a statement that error handling was important.

The most fundamental question -- fore, who should be responsible for handling the error -- at some point, the program needs to stop ferrying the error up the stack and actually do sth with it -- 

With concurrency pocesses, this question a little more complex -- cuz a concurrent process is operating independently of its parent or siblings -- can be difficult for it to reasson about what the right thing to do with the error is.

```go
func checkStatus(done <-chan struct{}, urls ...string) <-chan *http.Response {
    responses := make(chan *http.Response)
    go func() {
        defer close(responses)
        for _, url := range urls {
            resp, err := http.Get(url)
            if err != nil {
                fmt.Println(err)
                continue
            }
            select {
            case <-done:
                return
            case responses<- resp:
            }
        }
    }()
    return responses
}

func main() {
    done := make(chan struct{})
    defer close(done)
    urls := []string{"..."}
    for response := range checkStatus(done, urls...){
        fmt.Printf("Response: %v\n", response.Status)
    }
}
```

Here can see that the goroutine has been given no choice in the matter -- it can’t simply swallow the error, and so it does the onlys sensible thing -- just prints the error and hopes sth is paying attention. Don’t put your goroutines in this awkward postiion -- just suggests separate your concerns -- In generally, your concurrent process should sned their errors to *another part of your program that has complete info about the state* of your program.

```go
type Result struct {
	Error    error
	Response *http.Response
}
func checkStatus(done <-chan struct{}, urls ...string) <-chan Result {
	results := make(chan Result)
	go func() {
		defer close(results)
		for _, url := range urls {
			var result Result
			resp, err := http.Get(url)
			result = Result{err, resp}
			select {
			case <-done:
				return
			case results <- result:
			}
		}
	}()
	return results
}
```

Just create a type that encompasses both the `*http.Response`and the `error`possible from an iteration of the loop within our goroutine --  Create a `Result`instance with the `Error`and `Resposne`field set.

```go
func main() {
	done := make(chan struct{})
	defer close(done)

	urls := []string{"https://baidu.com", "https://badhost"}
	for result := range checkStatus(done, urls...) {
		if result.Error != nil {
			fmt.Printf("errro: %v", result.Error)
			continue
		}
		fmt.Printf("response: %v\n", result.Response.Status)
	}
}
```

The key thing to note is how we have coupled the potential result with the potential error -- this represents the complete set of possible outcomes created from the goroutine `checkStatus`, and allows our main goroutine to make decidsions about what to do when errors occur.

For the previous, simply wrote errors out to `studio`, could do sht else -- alter our program slightly so that it stops trying to check for status if three or more errors occur like:

```go
func main() {
	done := make(chan struct{})
	defer close(done)

	errCount := 0
	urls := []string{"a", "https://baidu.com", "b", "c", "d"}
	for result := range checkStatus(done, urls...) {
		if result.Error != nil {
			fmt.Printf("error: %v\n", result.Error)
			errCount++
			if errCount >= 3 {
				fmt.Println("too many errors, breaking")
				break
			}
			continue
			fmt.Printf("Error: %v", result.Error)
		}
	}
}

```

Can see that cuz errors are returned from `checkStatus`and not handled internally within the goroutine, error handling follows the familar Go pattern.

### Dependency injection -- the theory

Fetching and using the data are two separable concerns and any separable logic should be indeed separated in order to make testing and evolving easier -- The bank is going to be a dependency of our program -- an external resource on whcih it relies in order to work. It is an acceped best practice in software design,  Whatever the language you use, to use the *inversion of control* -- IoC -- Inversion of control servers multiple design purposes -- 

- decoupling the execution of a task from imp
- Focusing a module or package on the task it is designed for
- Freeing systems from assumptions about how other 
- Preventing side effects when replacing a module.

More concretely, the `money`package should not know where the exchange rate is coming from -- this is beyond -- Another package will be responsible for calling the bank when needed -- deal with the bank-specific logic and return the required info -- This other is therefore a dependency that the consumer is giving to it.

#### Dependency injection

There are two ways in Go to provide a dpendency -- one is the more OO, the other like functional programming.

OO -- the first option requires the consumer to have in hand a variable of a type that implements an interface -- if you know any OO -- Fore, create a structure with a function `FetchRates`attached to it, and pass a variable of this type to `Convert`-- is expecting any variable that implemens the expected interface.

```go
// Dependency injection via interface
type ratesFetcher interface {
    FetchRates(from, to Currency) (ExchangeRate, error)
}

func Convert(..., rates ratesFetcher) {
    rete, err := rates.FetchRates(from,to)
}

func main() {
    ratesRepo := newRatesRepository()
    money.Coinvert(... , reatesRepo)
}
```

For this, the main function is just in charge of creating the varaible that implemetns the interface.

Function dependency -- The second option is more verbose but, it also works and can be preferred in some cases.

```go
func Convert(..., rates func(from, to Currency) (ExcehangeRage, error) {...})
func main() {
    rateRepo := newRatesRepository()
    money.Convert(..., ratesRepo.FetchRates)
}
// for this, can even name the function's signature by declaring a type
type getExchangeRatesFunc func(from, to Currency) (ExchangeRate, error)
func Convert(..., rate getExchangeRatesFunc) (Amount, error) {...}
```

Alterntively, the consumer is free to create any function on the fly, relying on variables of the outside scope if needed.

```go
func main() {
    config := ...
    fetcher := func(from, to Currency) (ExchangeRate, error) {
        return config.MockRate, nil
    }
    money.Convert(..., fetcher)
}
```

As can see the function dependency option is a bit less intuitie.

### Approaches to DI in Go

Go typically uses the following methods to achieve DI -- 

- Constructor injection -- via `struct`and `interface`
  - Dependencies are passed to a struct through its ctor
  - Common and idiomatic in Go
- Setter injection
  - Via methods after object creations
  - Useful when are optional or need to be changed dynamically
- Function injection (via high-order functions)
  - Dependencies are passed as function arguments or closures
  - Useful for small
- DI containers -- uing libraries

#### Ctor Injection -- 

This is the most common approach in Go, leveraging structs and interfaces -- like:

```go
type Logger interface {
	Log(message string)
} // defines the dependency contract

// For this, can easily swap this with another imp for testing or different environment
type ConsoleLogger struct{}

func (ConsoleLogger) Log(message string) {
	fmt.Println("log", message)
}

// Service for service depends on a Logger
type Service struct {
	logger Logger
}

// NewService is the ctor that injects the logger dependency
func NewService(logger Logger) *Service {
	return &Service{
		logger: logger,
	}
}

func (s *Service) DoWork() {
	s.logger.Log("Doing work")
}

func main() {
	// create a logger (dependency)
	logger := ConsoleLogger{}

	// inject the logger into the service
	service := NewService(logger)

	service.DoWork()
}
```

#### Mocking for testing

DI makes unit testing easier by allowing you to inject mock dependencies -- 

```go
func TestService_DoWork(t *testing.T) {
	mockLogger := &MockLogger{}

	// Inject the mock logger into the service
	service := NewService(mockLogger)

	// call the method under the test
	service.DoWork()

	if len(mockLogger.loggedMessages) != 1 {
		t.Errorf("Expected 1 log message, got %d", len(mockLogger.loggedMessages))
	}
	if mockLogger.loggedMessages[0] != "Doing some work" {
		t.Errorf("Expected log message %s", mockLogger.loggedMessages[0])
	}
}
type MockLogger struct {
	loggedMessages []string
}

func (m *MockLogger) Log(message string) {
	m.loggedMessages = append(m.loggedMessages, message)
}
```

- The `MockLogger`implements the `Logger`interface, allowing it to be injected into `Service`
- This enables isolated testing of `Service`without relying on a real logger.

#### Function Injection -- 

For smaller components or functional programming -- you can inject dependencies as function arguments -- 

```go
type LoggerFunc func(message string) 

func DoWork(logger LoggerFunc) {
	logger("work completed")
}
func main() {
	logger := func(message string) {
		fmt.Println("Log:", message)
	}
	DoWork(logger) // output: Work completed
}
```

For this -- 

- The `LoggerFunc`type is a function that acts as a dependency
- This approach is lightweight and works for simple use cases

#### Best Practices for DI in Go

- Keep it simple -- prefer ctor injection over DI containers for most projects
- Use Interfaces -- Define dependencies as interfaces to allow flexibility and mocking
- Avoid Global state -- don’t rely on global variables for depdendencies
- Using DI container sparingly

Example -- using DI container (fore google wire) -- For large projects, might use DI containers like Google’s `wire`to automate depdnecny wriing -- `Wire`generates code at compile time -- avoid runtime reflection.

```sh
go get github.com/google/wire/cmd/wire@latest
```

```go
// InitializeService is the injector function
func InitializeService() *Service {
	wire.Build(NewService, wire.InterfaceValue(new(Logger), ConsoleLogger{}))
	return nil // Replaces this with actual imp
}
```

## Adding a validator package -- 

Create the following directory and file on your machine -- like:

```go
// file -- internal/validator/validator.go
package validator
//...
type Validator struct {
    FieldErrors map[string]string
}

func (v *Validator) Valid() bool {
    return len(v.FieldErrors) == 0
}

func (v *Validator) AddFieldError(key, message string) {
    if v.FieldErrors == nil {
        v.FieldErrors= make(map[string]string)
    }
    if _, exists := v.FieldErrors[key]; !exists {
        v.FieldErrors[key]=message
    }
}

func (v *Validtor) CheckField(ok book, key, message string) {
    if !ok {
        v.AddFieldError(key, message)
    }
}

// NotBlank() returns true if a value is not an empty string
func NotBlank(value string) bool {
    return strings.TrimSpace(value) != ""
}

// MaxChars() returns true if a value contains no more than n characters
func MaxChar(value string, n int) bool {
    return utf8.RuneCountInString(value) <= n
}

// Permitted returns true if a value is a list of permitted integers
func PermittedInt(value int, permittedValues ...int) bool {
    for i:= range permittedValues {
        if value == permittedValues[i] {
            return true
        }
    }
    return false
}
```

#### Using the helpers

Alright, let’s start putting the `Validator`type to use -- Head back to the `handler`like:

```go
type snippetCreateForm struct {
    Title string
    Content string
    Expires int
    validator.Validator
}

func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    expires , err := strconv.Atoi(r.PostForm.Get("expires"))
    //...
    form := snippetCreateForm{
        Title: r.PostForm.Get("title")
        Content: r.PostForm.Get("content"),
        Expires: expires,
    }
    
    // Cuz the Validator type is embedded by the struct, 
    // can call `CheckField()` directly on it to execute our validation checks
    form.CheckField(valiator.NotBlank(form.Title), "title", "...");
    // ... just similarily
    
    if !form.Valid() {
        data := app.newTemplateData(r)
        data.Form=form
        app.render(w, http.StatusUnprocessableEnitty, "create.html", data)
        return
    }
    id, err := app.snippets.Insert(form.Ttile, form.Content, form.Expires)
    if err != nil {
        app.serverError(w, err)
        return
    }
    http.Redirect(w, r, fmt.Sprintf(...), http.StatusSeeOther)
}
```

#### Automatic form parsing

Another thing can do to simplify our handlers is us a 3rd-party packge like `gorilla/schema`to automatically decode the form data into the `createSnippetForm`struct -- using an automatic decoder is totally *optional*.

```sh
go get github.com/go-playground/form/v4
```

Using the form decoder -- To get this working the first thing that we need to do is initialize a new `*form.Decoder`instance in the `main`to make it available to our handlers as a dependency like -- 

```go
type application struct {
    //...
    formDecoder *form.Decoder
}

func main() {
    //...
    // initialize a decoder instance
    formDecoder := form.NewDecoder()
    app := &application {
        //...
        formDecoder: formDecoder,
    }
}

// then update to use this like:
// need to update the struct to include struct tags which tell the decoder
```

