# Multi-key Indexes(II)

An index created on the fields of an array type is called a multikey index -- when an array field is passed as an argument to the `createIndex`function, Mdb creates an index entry for each element of the array. The syntax of the `createIndex`element is the same as the for creating an index of a regular field -- 

```js
db.collectionName.createIndex({arrayFieldName: sortOrder})
```

MDB inspects the input field, and if it is an array, a multi-key index will be created, fore, consider the following:

```js
db.movies.createIndex({'languages':1})
```

This query adds an index on the `languages`field, which is an array, in mdb, you can find documents based on an element of their array fields -- multikey indexes help accelerate such queries -- 

```js
db.movies.explain("executionStats").find({languages: "Cantonese"})
```

#### Text indexes

An index defined on a string field or an array of string elements is called a text index -- Text indexes are not sorted, meaning that they are faster then normal indexes -- the syntax to create a text index is as follows -- 

```js
db.collectionName.createIndex({fieldName: "text"})
```

The following is an example of a text index to be created on the `users`collection on the `name `field like:

```js
db.users.createIndex({name: 'text'})
db.users.getIndexes()
```

#### Indexes on Nested Documents

A document can contain nested objects to group a few attributes, fore the theaters collection contains the `location`field, which has a nested object like:

```json
"location": {
    "address": {
        "street1" : "340 w Market",
        "city": "Bloomington",
        //...
    }, 
    "geo": {
        "type": "point"
        //...
    }
}
```

For this, using a dot notation -- can create an index on any of the nested document fields, just like any other field in the collections -- as the following like:

```js
db.theaters.createIndex({"location.address.zipcode": 1})
```

can also create an index on the embedded document - fore, can create an index on the `location`field in stead of its attributes -- like:

```js
db.theaters.createIndex("location": 1)
```

Such indexes can be used when searching for a location by passing the entire nested documents.

#### Wildcard indexes

Mdb support flexible schema, and different documents can have fields of varying types and quantities -- It can be difficult to create and maintain indexes on non-uniform fields that are not present in all documents. As can see, the fields under `specification`are dynamic in nature, different products can have different specifications -- like:

```js
db.products.createIndex({"specifications.$**": 1})
```

For the json like:

```json
{
    "_id": 11111,
    //...
    "speicifcations": {
        "quantity": "300ml",
        //...
    }
}
// and another like:
{
    "_id": 2222,
   	//...
    "specifications": {
        "color": "white"
    }
}
```

#### JSONPath -- 

Is a query language for JSON, similar to XPath for XML -- allows U to select and extract data from a JSON structure using a path-like syntax -- 

- `$`-- Root of the JSON structure
- `.`- - Child operator
- `[]`-- Array subscript operator
- `..`Recursive descent
- `*`-- WildCard

```js
db.products.createIndex(
	{"$**": 1},
    {
        "wildcardProjection": {"name":0}
    }
)
```

### Properties of Indexes

In this, just cover different properties of indexes in the MDB, an index property can influence the usage of an index and can also enforce some behavior on the collection. Index properties are passed as option to the `createIndex`function will be looking at unique indexes -- TTL (time to live) -- 

#### unique Indexes

A unique index property restricts the duplication of the index key -- this is just useful if you want to maintain the uniqueness of a field in a collection -- the unique fields are useful for avoiding any ambiguity in identifying documents precisely -- fore, a `license`collection. 

```js
db.collection.createIndex(
	{field: type},
    {unique: true},
)
```

The `{unique: true}`option is used to create a unique index.

And in some case, wan a combination of fields to be unique  -- fore, you can define a unique compund index by passing `unique:true`flag while creating an compound index like:

```js
db.collection.createIndex(
	{field1: type, field2: type2, ...},
     {unique: true}
)
```

Then insert a record with the same `threadId`-- like:

```js
db.theaters.insertOne({theaterId: 1012})
```

The document is inserted successfully -- 

```js
db.theaters.createIndex(
    {theaterId: 1},
    {unique: true}
)
```

The preceding command will return an error response as it is prerequsitie that there should no duplicate records in the collection. Like: Now remove the duplicate reocrd that was inserted using the `_id`value -- 

```js
db.theaters.createIndex(
    {theaterId: 1},
    {unique: true}
)

db.theaters.findOneAndDelete(
    {theaterId: 1012},
    {sort: {_id: -1}}
)

db.theaters.find({theaterId: 1012})
```

## The `or`Channel

At times you may find yourself wanting to combining one or more `done`channels into a single `done`channel that closes if *any* of its component channels close -- it is prefectly acceptable, to write a `write`statement that performs this coupling -- can write:

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

The provided Go function implements a *fan-in* pattern for multiple channels -- returning a single channel that closes *as soon as* any of the input channels closes -- 

- If no channels are provided -- it just returns `nil`-- this terminates the recursion and indicates no signal to wait for.
- And if only one channel is provided -- `len(channels)==1`then it returns that channel directly, as no aggregation is needed.

Then the main logic -- for two or more channels -- 

- Create a new channel `orDone`to signal when any input channel closes 
- Uses a `switch`to optimize for the case of exactly two channels -- 
  - For two, it uses a `select`to wait to either `channels[0]`or `channels[1]`to close.
  - For 3 or more, it uses a `select`with -- 
    - channels[0], 1, 2, directly
    - And a recursive call to `or `when the remaining channels `channels[3:]`and `orDone`itself -- allowing the function to handle an arbitrary number of channels
  - the goroutine exits when any closes.
- Just need to note the recursive call `or(append(channels[3:], onDone)...)`, reduces the problem size by processing the remaining channesl.
- Cuz of how we are recursing, every recursive call to `or`will at least have two channels -- as an optimization to keep the nubmer of goroutines contained, place a special `case`here for calls to `or`with only two channels.

Fore, can be used like:

```go
func sig(after time.Duration) <-chan struct{} {
    c := make(chan struct{})
    go func() {
        defer close(c)
        time.Sleep(after)
    }()
    return c
}
start := time.Now()
<-or (
    sig(2*time.Hour),
    sig(5*time.Minue),...
)
```

#### Error handling -- 

In concurrent programs, error handling can be difficult to get right -- sometimes -- we sends so much time thinking about how our various processes will be sharing info and coordinates --  And when go eschewed the popular exception model of errors, it made a statement that error handling was important, and that as we develop our programs.

```go
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

type Result struct {
	Error    error
	Response *http.Response
}

func main(){
    urls := []string{"..."}
    for result := range checkStatus(done, urls...) {
        if result.Error != nil {
            fmt.Printf("error: %v", result.Error)
            continue
        }
        fmt.Printf(...)
    }
}
```

#### Best pracitce for constucting Pipelines

Channels are uniquely suited to constructing pipelines in Go cuz they fulfill all of our basic requirements -- they can receive and emit vlaues, can safely be used concurrently, they can ben raned over, and are reified by the language.

```go
func generator(done <-chan struct{}, integers ...int) <-chan int {
	intStream := make(chan int)
	go func() {
		defer close(intStream)
		for _, i := range integers {
			select {
			case <-done:
				return
			case intStream <- i:
			}
		}
	}()
	return intStream
}

func multiply(done <-chan struct{}, intStream <-chan int, multiplier int) <-chan int {
	multipliedStream := make(chan int)
	go func() {
		defer close(multipliedStream)
		for i := range intStream {
			select {
			case <-done:
				return
			case multipliedStream <- i * multiplier:
			}
		}
	}()
	return multipliedStream
}

func add(done <-chan struct{}, intStream <-chan int, adder int) <-chan int {
	addedStream := make(chan int)
	go func() {
		defer close(addedStream)
		for i := range intStream {
			select {
			case <-done:
				return
			case addedStream <- i + adder:
			}
		}
	}()
	return addedStream
}

func main() {
	done := make(chan struct{})
	intStream := generator(done, 1, 2, 3, 4)
	pipeline := multiply(done, add(done, multiply(done, intStream, 2), 1), 2)
	for v := range pipeline {
		fmt.Println(v)
	}
}
```

#### Some handy Generators

```go
func repeat(done <-chan struct{}, values ...any) <-chan any {
	valueStream := make(chan any)
	go func() {
		defer close(valueStream)
		for {
			for _, v := range values {
				select {
				case <-done:
					return
				case valueStream <- v:
				}
			}
		}
	}()
	return valueStream
}
```

This function will just repeat the values you pass to infinitely until U tell it to stop fore:

```go
func take(done <-chan struct{}, valueStream <-chan any, num int) <-chan any {
	takeStream := make(chan any)
	go func() {
		defer close(takeStream)
		for i := 0; i < num; i++ {
			select {
			case <-done:
				return
			case takeStream <- <-valueStream:
			}
		}
	}()
	return takeStream
}
```

This pipeline stage will only take the first `num`items of its incoming `valueStream`and then exit -- together, the two can be very powerful just like:

```go
func main() {
	done := make(chan struct{})
	defer close(done)
	for num := range take(done, repeat(done, 1), 10) {
		fmt.Printf("%v ", num)
	}
}
```

In this basic, create a `repeat`generator to generate an infinite number of ones, but then only take the first 10. Cuz the `repeat`'s send blocks on the `take`-- the `repeat`generator is very efficient. Can also expand this -- create another repeating generator -- like:

```go
func repeatFn(done <-chan struct{}, fn func() any) <-chan any {
	valueStream := make(chan any)
	go func() {
		defer close(valueStream)
		for {
			select {
			case <-done:
				return
			case valueStream <- fn():
			}
		}
	}()
	return valueStream
}
```

Use it to generate 10 random numbers like;

```go
func main() {
	done := make(chan struct{})
	defer close(done)
	rand := func() any { return rand.Int() }
	for num := range take(done, repeatFn(done, rand), 10) {
		fmt.Println(num)
	}
}
```

When need to deal in speific types, you can place a stage that performs the type assertion for you the peroformance overhead of having an extra pipeline stage and the type assertion are negligible -- like:

```go
func toString(done <-chan struct{}, valueStream <-chan any) <-chan string {
	stringStream := make(chan string)
	go func() {
		defer close(stringStream)
		for v := range valueStream {
			select {
			case <-done:
				return
			case stringStream <- fmt.Sprintf("%v", v):
			}
		}
	}()
	return stringStream
}
func main() {
	done := make(chan struct{})
	defer close(done)
	var message string
	for token := range toString(done, take(done, repeat(done, "I", "am"), 5)) {
		message += token
	}
	fmt.Println(message)
}
```

## Call the bank

We have a woking solution -- are not using the real exchange rates -- need to call external authority to get hem - the authors chose to implement a solution baesd on the API of the  Bank - cuz it is freee of charge -- does not need any identification protocol - it is very likely to still be running with the same API in a year -- 

Fetching and using the data are two separable concerns and any separable logic should be indeed spearated in order to make testing and envolving easier -- For this, the bank is going to be a *dependency* of our program -- an external resource on which it relies in order to work -- it is an acceptable best practice in software design -- Use `inversion of control` -- IOC

- Decoupling the external of a task from implementation
- Focusing a module or package on the task it is designed for
- Freeing systems from assumptinos about how other systems do what they do and instead rely on contracts.
- And finally preventing side effects when replacing a module.

More concretely, the `money`package should not know where the exchange rate is coming from -- this is beyond its scope -- another package will be responsible for calling the bank when just needed, deal with the bank-specific logic and return the required info. This other package is therefor a dependency that the consumer is giving to it.

What U can do is create a dependency that `Convert`can understand, Somebody else in another team is writing the banking service -- cannot access yet -- What you can do is create a dependency that `Convert`can understand, where U simply return hard-coded values -- And when the service is finally here, U just need to replace the plug with a call to the new API. The dependency’s role is to fetch the exchange rate between two currencies.

#### Ojbect depednency -- 

Requires the consumers to have in hand a variable of a type that implements an `interface`-- in such case -- 

```go
type ratesFetcher interface {
    FetchRates(from, to Currency) (ExchangeRate, error)
}
func Convert(..., rates ratesFetcher) {
    rate, err := rates.FetchRates(from, to)
}

// for the main
func main() {
    ratesRepo := newRatesRepository()
    money.Convert(..., ratesRepo)
}
```

#### Function dependency 

just write a `Convert`'s last parameter is another function’s definition -- 

```go
func Convert(..., rates func(from, to Currency) {...}) {
    rate, err := rates(from, to)
}
```

#### ECB Package

Create a new package that will be responsible for the call to the bank’s API -- And the new package should expose a struct with one method attached -- and probably a way to build it. 

```go
// ecb.go -- 
type EruoCentralBank struct {
}
func (ecb EruoCentralBank) FetchExchagneRate(source, target money) {
    return 0, nil
}
```

Arbuably, could build completely independent packages and not rely on `money`type -- But the architectural decision instead is to base everything on the autonomous `money`package -- others are allowed to rely on it -- but it needs to rely on nothing else. For this -- In Go, if package A relies B, and B on A also, the compiler will stop U right there.

#### HTTP call easy version -- 

The Bank exposes an endpoint that lists daily exchange rates -- can first try calling API in your favoruite terminal to see what it looks like -- For the `ecb.go`like:

```go
// ecbankError defines an error
type ecbankError string

func (e ecbankError) Error() string {
	return string(e)
}

// ...
type Client struct {
	url string
}

func (c Client) FetchExchangeRate(source, target money.Currency) (money.ExchangeRate, error) {
	const euroxrefURL = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
	if c.url == "" {
		c.url = euroxrefURL
	}

	resp, err := http.Get(c.url)
	if err != nil {
		return money.ExchangeRate{}, fmt.Errorf("%w: %s", ErrCallingServer, err.Error())
	}
	// close the resp's body
	defer resp.Body.Close()

	if err = checkStatusCode(resp.StatusCode); err != nil {
		return money.ExchangeRate{}, err
	}

	rate, err := readRateFromResponse(source.Code(), target.Code(), resp.Body)
	if err != nil {
		return money.ExchangeRate{}, err
	}

	return rate, nil
}

const (
	clientErrorClass = 4
	serverErrorClass = 5
)

func checkStatusCode(statusCode int) error {
	switch {
	case statusCode == http.StatusOK:
		return nil
	case httpStatusClass(statusCode) == clientErrorClass:
		// errors 4xx
		return fmt.Errorf("%w: %d", ErrClientSide, statusCode)
	case httpStatusClass(statusCode) == serverErrorClass:
		// errors 5xx
		return fmt.Errorf("%w: %d", ErrServerSide, statusCode)
	default:
		// any other usecases
		return fmt.Errorf("%w: %d", ErrUnknownStatusCode, statusCode)
	}
}

// httpStatusClass returns the class of a http status code.
func httpStatusClass(statusCode int) int {
	const httpErrorClassSize = 100
	return statusCode / httpErrorClassSize
}
```

### Automatic form parsing

Another thing can do to simplify our handlers is use a 3rd-party package like `go-playground`or `gorilla/schmea`to automatically decode the form data into the `createSnippetForm`struct -- using an automatic decoder is totally optional, but it can help to save your time and typing -- 

```sh
go get github.com/go-playground/form/v4
```

#### Using the form decoder -- 

To get this working, the first thing that we need to do is initialize a new `*form.Decoder`instance in our `main.go`file and make it available to our handlers as a dependency.

```go
// Add a formDecoder field to hold a pointer to a form.Decoder instance -- 
type application struct {
    //...
    formDecoder *form.Decoder
}

func main() {
    //... other code
    // initialize a decoder instance...
    formDecoder := form.NewDecoder()
    app := &application {
        //...
        formDecoder: formDecoder,
    }
   // ...
}
```

Then in the `handlers.go`file and update it to use this new decoder -- like so:

```go
type snippetCreateForm struct {
    Title string `form:"title"`
    Content string `form:"content"`
    Expires int `form:"expires"`
    validator.Validator `form: "-"`
}

func (app *application) snippetCreatePost(w, r) {
    err := r.ParseForm()
    //...
    // Declare a new empty instance of the `snippetCreateForm`struct
    var form snippetCreateForm
    
    // Call the Decode() method of the form decoder, passing in the current request
    // and a pointer to the `snippetCreateForm` struct.
    err = app.formDecoder.Decode(&form, r.PostForm)
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    // also check
    form.CheckField(validator.NotBlank(form.Title), "title", "this field cannot be blank")
    //...
    if !form.Valid() {
        data := app.newTemplateData(r)
        data.Form= form
        app.render(w, http.StatusUnprocessableEntity, "create.html", data)
        return
    }
}
```

#### Creating a `decodePostForm`helper

To assist with this, create a new `decodePostForm()`helper which does 3 things -- 

- Calls `r.ParseForm`on the current request
- Calls `app.formDecoder.Decode()`to unpack the HTML form data to a target destination.
- Checks for a `form.InvalidDecoderError`error and triggers a panic if we ever see it.

```go
func(app *application) decodePostForm(r *http.Request, dst any) error {
    err := r.ParseForm()
    if err != nil {
        return err
    }
    
    // call `Decode()` on our decoder instance -- 
    err = app.formDecoder.Decode(dst, r.PostForm)
    if err != nil {
        var invalidDecoderError *form.InvalidDecorderError
        if errors.Ad(err, &invlidaDecoderError) {
            panic(err)
        }
        // for all other
        return err
    }
    return nil
}
```

With that, we can make final simplification to our `createSnippetPost`handler, go ahead and update it to use `decodePostForm()`helper and remove the `r.ParseForm()`call, so that the code looks like -- 

```go
func (app *application) snippetCreatePost(w, r) {
    var form snippetCreateForm
    err := app.decodePostForm(r, &form)
    if err != nil {
        //...
        return
    }
    if !form.Valid() {
        data := app.newTemplateData(r)
        data.Form= form
        app.render(...)
        return
    }
    //...
}
```

