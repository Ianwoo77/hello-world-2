# Query Analysis after Indexes

In the Query Analysis -- U analyzed the performance of query that did not have suitable indexes to support its query condition -- cuz of this, the query scanned all documents in the collection.

```js
db.movies.find(
    {year: 2015},
    {title:1, 'awards.wins':1}
).sort({'awards.wins': -1}).explain('executionStats')

db.movies.getIndexes()
```

This means  that first, an index scan stage was performed, and then, based on the received index references, the data was fetched from the collection, also the top-level fields indicates that only documents were examined.

#### Hiding and dropping Indexes -- 

Dropping an index means removing the values of the fields from the index regsitry -- thus, any searches on the related fields will be perfromed in a linear fashion. 

And, it is important to note that *Mdb does not allow updating an existing index* -- to fix an incorrectly created index, Need to drop it recreate it correctly.

```js
db.collection.dropIndex(indexNameOrSpecification)
```

The index specification document is the definition of the index that is used to create it.

```js
db.movies.createIndex({title:1})
db.movies.dropIndex({title:1}) // command drops the index on the `title` from the movie
```

For the `dropIndex`, the output contains `nIndexWas`, which refers to the index count before the command was executed -- the `ok`shows the status as 1, which indicates the command was successful.

#### Dropping multiple Indexes

Can also drop multiple indexes using the `dropIndexes`command -- Can be used to drop all the indexes on a collection expcet the default `_id`index. `db.threaters.dropIndexes()`

#### Hiding an index 

Privdes a way to hide indexes from the query planner -- creating and deleting indexes are expensive operations in terms of time -- for large collections, these operations take longer to finish. Like:

```js
db.collection.hideIndex(indexNameOrSepcification)
```

The argument to the command is similar to that for the `dropIndex()`function -- it takes either the name of the index or an index specification document.

Once hidden, can analyze the impact on the queries and drop the indexes if they are truly unneeded -- However, if hiding an index has an effect performance, you can restore using the `unhideIndex()`.

```js
db.collection.unhideIndex(indexNameOrSpecification)
```

### Type of Indexes -- 

We have seen how indexes help with query performance and how we can create, drop and list indexes in the collection -- Mdb supports different tyhpes of indexes, such as a single key, multi-key, and compound indexes -- each of these indexes has different advantages that you will need to know before deciding which type is suitable for your collection.

#### Default Indexes

As seen in the previous, each documentin a collection has a PK and is indexed by default -- Mdb Uses this index to maintain the uniqueness of the `_id`field, and it is available on all the collections.

single-key indexes -- An index created uing a single field from a collection is called a *single-key* index, used a single-key index earlier in this -- the syntax is as follows -- like:

```js
db.collection.createIndex({field1: type}, {options})
```

#### Compound indexes

Single-key indexes are prefearable when using the key in a search significatntly reduces the number of documents to be scanned. However, in some scenarios, single-key indexes are not sufficient to reduce the collection scans -- Consider the query you wrote to find movies released in 2015, saw -- but if have a query like:

```js
db.movies.find(
	{
        year: 2015,
        rated: "UNRATED"
    },
    //...
)
```

For this, cuz of the indexes, only 484 were scanned, For:

```js
"executionStats": {
      "executionSuccess": true,
      "nReturned": 0,
      "executionTimeMillis": 1,
      "totalKeysExamined": 479,
      "totalDocsExamined": 479,
          //...
}
```

- Cuz of the indexes, only 479 documents were scanned
- Indexhes helped locate the 479 and the second fitler.

For this, the `createIndex`command can be used to create a compound index using the following -- 

```js
db.collections.createIndex({field:type, field2: tpe}, {options})
```

This syntax is just similar to that of a single-field index, except that it accepts multiple paris of fieds and their repestive sort orders -- like:

```js
db.movies.createIndex(
    {
        year: 1,
        rated: 1,
    }
)
```

And the command generates following outtput -- like:

```cs
executionStats: {
      "executionSuccess": true,
      "nReturned": 3,
      "executionTimeMillis": 0,
      "totalKeysExamined": 3,
      "totalDocsExamined": 3,
//...
}
```

For this, now that created an additional index on the two fields, oserve can see the good output.

## Channels

Lexical confinement involves using lexical scope to expose only the correct data and concurerency primiatives for multiple concurrent processes to use.

```go
func main() {
	chanOwner := func() <-chan int {
		results := make(chan int, 5)
		go func() {
            // here close the results deferly
			defer close(results)
			for i := 0; i <= 5; i++ {
				results <- i
			}
		}()
		return results
	}

	consumers := func(results <-chan int) {
		for result := range results {
			fmt.Printf("received %d\n", result)
		}
		fmt.Println("done receiving")
	}

	results := chanOwner()
	consumers(results)
}
```

A data structure which is not concurrent-safe, an instance of `bytes.Buffer`-- 

```go
func main() {
	printData := func(wg *sync.WaitGroup, data []byte) {
		defer wg.Done()
		var buffer bytes.Buffer
		for _, b := range data {
			fmt.Fprintf(&buffer, "%c", b)
		}
		fmt.Println(buffer.String())
	}

	var wg sync.WaitGroup
	wg.Add(2)
	data := []byte("golang")
    go printData(&wg, data[:3]) // here pass in a slice containing the first 3 bytes in data
    go printData(&wg, data[3:])
	wg.Wait()
}
```

In this example, can see that cuz `printData`doesn’t close around the `data`slice, it cannot access it, and need to take in a slice of `byte`to operate on. A `byte.Buffer`is initialized as an empty buffer to store and manipulate byte data.

`bytes.Buffer`implements `io.Reader`, `io.Writer`and other interfaces, making it useful for building strings, buffering data or handling I/O operations. Fore:

```go
var buffer bytes.Buffer // zero-value, empty buffer
buffer := bytes.NewBuffer([]byte("initial data"))
```

### `for-select`loop

It’s nothing more than sth like this -- 

```go
for {
    select{}
}
```

Fore, oftentime you want to convert sth that can be iterated over into values on a channel -- like:

```go
for _, s := range []string{"a", "b", "c"}{
    select {
    case <-done:
        return
    case stringSteam <-s:
        //...
    }
}
```

It’s very common to create goroutines that loop infinitely until they are stopped -- there are a couple variations of this one -- which one you choose is purely a stylistic preference -- like:

```go
for {
    select {
    case <-done:
        return
    default:
    }
    // do sth
}
// or the second variation embeds the work in a `default` clause of select statement
for {
    select {
    case <- done:
        return
    default:
        //... do sth
    }
}
```

#### preventing Goroutine Leaks

The goroutines *do* cost resources, and goroutines are not garbage collected by the runtime, so regardless of how small their memory footprint is -- don’t want to leave them lying about our process. The goroutine has a few paths to termination -- 

- When it has completed its work
- When cannot continue its work due to an unreceoverable error
- When it’s told to stop.

```go
func doWork2(strings <-chan string) <-chan struct{} {
	completed := make(chan struct{})
	go func() {
		defer fmt.Println("doWork exited")
		defer close(completed)
		for s := range strings {
			fmt.Println(s)
		}
	}()
	return completed
}

func main() {
	doWork2(nil)
	fmt.Println("done")
}
```

Here we see that the main goroutine passes a `nil`channel into `doWork`-- therefore the `strings`channel will never actually gets any strings written on it, and the goroutine containing `doWork`will remain in memory for the lifetime of this process. And note that we would even deadlock if we joined the goroutine with `doWork`and the main.

The way to successfully mitigate this is to establish a signal between the parent goroutine and its children that allows the parent to signal cancellation to its children -- Using the `done`like:

```go
func doWork2(done <-chan struct{}, strings <-chan string) <-chan struct{} {
	terminated := make(chan struct{})
	go func() {
		defer fmt.Println("doWork exited")
		defer close(terminated)
		for {
			select {
			case s := <-strings:
				fmt.Println(s)
			case <-done:
				return
			}
		}
	}()
	return terminated
}

func main() {
	done := make(chan struct{})
	doWork2(done, nil)
	go func() {
		time.Sleep(time.Second)
		fmt.Println("Canceling doWork goroutine...")
		close(done)
	}()
    // where we join the goroutine that will cancel the goroutine spawned in doWork
	<-done
	fmt.Println("Done")
}
```

Can see that despite passing in `nil`for our `strings`channel, our goroutine still exists successuflly. In this example we *do* join the two goroutiens, and yet do not receive a deadlock.

Create a 3rd goroutien to cancel the goroutine within `doWork`after a second. But, what if we are dealing with the reverse statuation -- a goroutine blocked on attempting to write a value to a channel -- 

```go
func newRandStream() <-chan int {
	randStream := make(chan int)
	go func() {
		// not executed here...
		defer fmt.Println("newRandStream closure exited")
		defer close(randStream)
		for {
			randStream <- rand.Int()
		}
	}()
	return randStream
}

func main() {
	randStream := newRandStream()
	fmt.Println("3 random ints:")
	for i := 1; i <= 3; i++ {
		fmt.Printf("%d: %d\n", i, <-randStream)
	}
}
```

Can see from the output that the deferred `fmt.Println`statement never gets run -- after the thrid iteration of our loop, our goroutine b*locks trying to send the next random integer* to a channel that is no longer being read from. For now have no way of telling the produce it can stop -- The solution -- just like the revceiving case, is to provide the producer goroutine with a channel informing 

```go
func newRandStream(done <-chan struct{}, done2 chan<- struct{}) <-chan int {
	randStream := make(chan int)
	go func() {
		defer fmt.Println("newRandStream closure exited")
		defer close(randStream)
		defer close(done2)
		for {
			select {
			case randStream <- rand.Int():
			case <-done:
				return
			}
		}
	}()
	return randStream
}

func main() {
	done := make(chan struct{})
	done2 := make(chan struct{})
	randStream := newRandStream(done, done2)
	fmt.Println("3 random ints:")
	for i := 1; i <= 3; i++ {
		fmt.Printf("%d: %d\n", i, <-randStream)
	}
	close(done)
	<-done2
}

```

Now that we know how to ensure goroutine don’t leak -- can stipulate a convetion -- namely -- if goroutine is responsible for creating a goroutine, it is also responsible for ensuring it can stop the groutine.

### Parse into business types

The `Convert`function is taking as parameter values that are already typed for its usage, and the package exposes ways to build them. This strategy optimises flexibility in the consumer’s logic -- as `main`is free to use the type through any other logic that could add, or use its own diferent types and `Parse`at the last minute -- Can:

```go
func main() {
	// read currencies form the input
	from := flag.String("from", "", "source currency, required")
	to := flag.String("to", "EUR", "target currency")
	flag.Parse()

	fromCurrency, err := money.ParseCurrency(*from)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr,
			"unable to parse source currency %q: %s.\n", *from, err.Error())
		os.Exit(1)
	}

	// parse the target currency
	toCurrency, err := money.ParseCurrency(*to)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr,
			"unable to parse target currency %q: %s.\n", *to, err.Error())
		os.Exit(1)
	}

	value := flag.Arg(0)

	if value == "" {
		_, _ = fmt.Fprintf(os.Stderr,
			"no value provided.\n")
		os.Exit(1)
	}

	// ...
	fmt.Println("Amount", amount, "converted to", convertedAmount)
}
```

#### Stringer

Into the `fmt`package, can find a very useful interface that all of the package’s formatting and printing functions understand -- the `Stringer`-- it allows a Go pattern where interfaces with only one method are named with this method followed by `-er`-- `Reader, ...`

```go
type Stringer interface {
    String() string
}
```

`fmt.Stringer`is implemented by any type just has a `String()`method -- which defines the *native* formatting for that value -- the `String`method is used to print values passed as an operand to any format that accepts a string on an unformatted printing function such as `Print`.

```go
// String implements Stringer
func (c Currency) String() string {
	return c.code
}
```

Magically, your `Currency`is now a `Stringer`-- anyone calling a printing function with a currency as a parameter -- 

### Call the bank

Have a working solution, but we are not using the real exchange rates -- need to call an external authority to get them -- here the authors chose to implement a solution based on the API of the ErupoeanCetnralBank. Fetching and using the data are two sparable concerns and any separable logic should be indeed separated in order to make testing and evolving easier -- And the bank is going to be a dependency of our program -- just as an external resource on which it relies in order to work. It is an accepted best practice in software design, whatever the language you use, to use the `inversion of Control`-- IoC -- Inversion of control serves multiple design purposes -- 

- Decoupling the execution of a task from imp
- focusing a module or package on the task it is designed for
- Freeing systems from assumptions about how other systems do what they do and instead rely on contracts
- and finlly preventing side effects when replacing a module.

For this example, the `money`package should not know where the exchange rate is coming from, this is beyond its scope -- another package will be responsible for calling the back when needed, deal with the bank-specific logic and return the required info. This other package is therefore a dependency that the consumer is giving to it, via a contract in the shape of an interface.

While U are writing the tool -- somebody else in another team is writing the banking service, What U can do is create a dependency and `Convert`can understand, where U simply return hard-coded values. This other package is therefore a dependency that the consumer is giving to it. Where U simply return hard-coded values, when the serivce is finally here, just need to replace the plug with a call to the new API.

### Dependency Injection in Go

There are two ways in Go to provide a dependency -- one is more object-oritented, the other looks like functional programming -- 

#### Object -dependency

The first requires the consumers to have in hand a variable of a *type that implements an interface*. If U know, in this version, create a structure with a function `FetcheRates`attached to it, and we pass a variable of this type to `Convert`. Is expecting any variable that implements the expected interface.

```go
type ratesFetcher interface {
    FetchRates(from, to Currency) (ExchangeRate, error) 
}
func Convert(..., rates ratesFetcher) {
    //...
    rate, err := rates.FetchRates(from, to)
}
func main() {
    ratesRepo := newRatesRepository()
    money.Convert(..., ratrsRepo)
}
```

In this imp, the main function is charge of creating the variable that implements the interface.

#### Function dependency

The second option is more verbose but it also works and can be preferred in some cases. The `Convert`function’s last parameter is a function’s definition rather than an object implementation an interface. The rest is similar. Just like:

```go
func Convert(..., rates func(from, to Currnecy)(Exchange, error)) {
    rate, err := rates(from, to)
}
//...
func main() {
    ratesRepo := newRatesRepository()
    money.Convert(..., ratesRepo.FetchRates)
}
```

For this, the main is passing directly the `FetchRates`method that `Convert`will be calling. U can even name the function’s signature by declaring a type: like

```go
type getExchangeRateFunc func(from, to Currency)(...)
func Convert(..., rates, getExchangeRatesFunc) (Amount, error) {...}
```

Alternatively, the conumer is free to create any function on the fly, relying on variables of the outside scope if needed

```go
func main() {
    confit := ...
    fetcher := func(from, to Currncy) (ExchangeRate, error) {
        return config.MockRate, nil
    }
    money.Convert(..., fetcher)
}
```

For the function way, it leaves more freedom for the imp, which means that mistakes are easier to make. Fore, you can have two different methods on one object and pick the one you want to use dpending on the context. Imagine an API where U can have daily exchange rates for free, or rates updated every minute when you are logged in. Both functions have the same signature with different names -- are methods of the same object -- like:

```go
func main(){
    ratesRepo := newRatesRepository()
    apiKey := getAPIKey()
    fetcher := ratesRespo.FreeRates
    if apiKey!= "" {
        fetcher = ratesRepo.WithAPIKey(apiKey).LoggedInRates
    }
    money.Conert(..., fetcher)
}
```

## Validating form Data

- Checking that the `title`and `content`are not emptyu
- Check `title`no more than 100 long
- `expires`matches one of the permitted values.

```go
// handlers.go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    // error
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    expires, err := strconv.Atoi(r.PostForm.Get("expires"))
    if err != nil {
        app.ClientError(w, http.StatusBadRequest)
        return
    }
    fieldErrors := make(map[string]string)
    if strings.TrimSpace(stitle) == "" {
        fieldErrors["title"]="This field cannot be blank"
    }else if utf8.RuneCountInString(title)>100 {
        fieldErrors["title"]="This field cannot be more 100 characters long"
    }
    
    if strings.TrimSpace(content) == "" {
        fieldErrors["content"]="this field cannot be blank"
    }
    
    if expires != 1... && expires !=365 {
        fieldErrors["expires"]= "This field must in scope"
    }
    
    // And if there are any errors, dump them in a plain text HTTP response and return from the 
    // handler
    if len(fieldErrors) > 0 {
        fmt.Fprint(w, fieldErrors)
        return
    }
    id, err := app.snippets.Insert(title, content, expires) 
    //...
}
```

### Approaches to DI in Go

1. Manual DI -- is via constructor functions or struct fields -- this is just the most common and idiomatic approach in Go -- 

   ```go
   type Logger interface {
       Log(message string)
   }
   type ConsoleLogger struct{}
   func (c *ConsoleLogger) Log(message string) {
       fmt.Println("...")
   }
   type Service struct {
       logger Logger
   }
   // NewService is a ctor that injects the logger depedency
   func NewService(logger Logger) *Service {
       return &Service {logger: logger}
   }
   func (c *Service) DoWork() {
       s.logger.Log("doing some work")
   }
   func main() {
       logger := &ConsoleLogger{}
       service := NewService(logger)
       service.DoWork()
   }
   ```

   - The `NewService`ctor function explicitly takes a `Logger`
   - The `Service`holds the dependency as a field
   - This approach is explict, testable, and aligns with Go’s simiplicity

2. Interface-based injection

   Go’s interfaces are a natrual fit for DI cuz they allow you to define constacts and inject any implementation that satsifies the interface -- 

   ```go
   type FilteLogger struct {}
   func (f *FileLogger) Log(message string) {
       fmt.Println(...)
   }
   func main() {
       fileLogger := &FileLogger{}
       service := NewSrevice(fileLogger)
       service.DoWork()
   }
   ```

   For this the `Service`doesn’t care about the concrete type of `Logger`-- only just implements the `Log`method.

#### Displaying errors and repopulating fields

Now that the `snippetCreatePost`handler is validting the data, the next steage is to mangae these validation errors gracefully -- if there are any validtion errors want to re-display the HTML form, highlighting the fields which failed validation and automatically re-populating any prevous submitted data. Begin by adding a new field `Form`-- 

```go
type templateData struct {
    // ...for Snippet and Snippets
    Form any
}
```

We will use this `Form`to pass the validation errors and previously submitted data back to the template when re-display the form. Just like:

```go
type snippetCreateForm struct {
    Title string
    Content string
    //...
    FieldErrors map[string]string
}

func (app *application) snippetCreatePost(w, r) {
    err := r.ParseForm()
    //...
    expires, err := strconv.Atoi(r.PostForm.Get("expires"))
    // ... handle error
    form := snippetCreateForm{
        Title: r.PostForm.Get("title"),
        Content: r.PostForm.Get("content"),
        //...
        FieldErrors: map[string]string{},
    }
    
    // update the validation checks so that they operate on the snippetCreateForm instance
    if strings.TrimSpace(form.Title)=="" {
        form.FieldErrors["title"]= "this field cannot be blank"
    }//...
    
    // .. if there are any validation errors re-display the `create.html` template
    // passing in the snippetCreateForm instance as dynamic data in the Form field
    if len(form.FieldErrors) > 0 {
        data := app.newTemplateData(r)
        data.Form= form
        app.render(w, http.StatusUnprocessableEntity, "create.html", data)
    }
}
```

`http.StatusUnprocessableEntity`-- 

- 422
- Meaning -- the server understands the content type of the req and the syntax is correct -- but cannot process the instructions in the request. This is often used in APIs to indicate validation errors or semantics issues with the req payload.
- Common use case -- when clicent submits a form or API request with valid JSON/XML but invalid data.

#### Updating the HTML template -- 

Update our `create.html`to display the validation errors and re-populate any previous data -- Should be able to render this in the templates using tags like `{{.Form.Title}}`and `{{.Form.Content}}`-- in the same way that we displayed the snippet data earlier in the book. Just like:

```jsx
{{define "title"}} create a new Snippet {{end}}
{{define "main"}}
<form action="/snippet/create" method="post">
	<div>
    	<label>Title:</label>
        {/* if it is empty */}
        {{with .Form.FieldErrors.title}}
        <lable class="error">{{.}}</lable>
    </div>
</form>
```

There is one final thing we need to do -- if tried to run the app, would get a 500 -- cuz our `snippetCreate`handler currently doesn’t set a value for `templateData.Form`field. So in the `snippetCreate`method :

```go
func (app *application) snippetCreate(w, r){
    data := app.newTemplateData(r)
    // ...
    data.Form= snippetCreateForm{
        Expires: 365,
    }
    app.render(w, http.StatusOK, "create.html", data)
}
```