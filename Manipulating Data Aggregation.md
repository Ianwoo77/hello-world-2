# Manipulating Data Aggregation

Most of our activities and examples can be reduced to the following -- there is a document or documents is in an collection that should return some or all the documents in an easy-to-digest format. Using some of the more advanced stages and techniques in the pipeline allows us to transform our data, derive new data, and generate insights acorss broader scope.

### The Group stage

The `$group`stage allows U to group documents based on specific condition -- The most basic imp of a `$group`stage accepts only an `_id`key -- with the value being an expression, this expression defines the criteria by which the pipeline groups documents together -- This value becomes the `_id`of the newly outputted document with one document generated for each unique `_id`that the `$group`stage creates.

```js
const pipeline = [
    {$group: {_id:"$rated"}}
]
```

In aggregation terms, an expresson can be a literal, an expression object, or a field path -- are passing a field path, which tells the pipeline which field to access in the input documents.

#### Accumulator Expressions

The `$group`command can accept more than just one argument -- can also accept any numbre of additional args in the following format -- `field: {accumulator: expression}`.

- `field`-- defining the key of our newly computed field for each group
- `accumulator`-- must be a supported accumulator operator.
- `expression`-- will be passed to the `accumulator`operator

```js
db.getCollection('movies').aggregate(
  [
    {
      $group: {
        _id: '$rated',
        numTitles: { $sum: 1 }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

Can see from this that can create a new field called `numTitles`-- with the value of this field for each group being the sum of the documents -- Instead of accumulating 1 on each document, can accumulate the value of a given field. Fore:

```js
db.getCollection('movies').aggregate(
  [
    {
      $group: {
        _id: '$rated',
        numRuntime: { $sum: '$runtime' }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

Remember, must prefix the runtime field with the `$`symbol to tell Mdb we are just referring to the `runtime`field value of each document we are accumulating.

Can add another stage to project the runtime -- using the `$trunc`stage -- to give us an integer value like:

```js
db.getCollection('movies').aggregate(
  [
    {
      $group: {
        _id: '$rated',
        avgRuntime: { $avg: '$runtime' }
      }
    },
    {
      $project: {
        roundedAvgRuntime: {
          $trunc: '$avgRuntime'
        }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

#### Manipulating Data

As part of the lead up to the classic movie marathon, the cinema company has decided to try and run one movie for each genre and they want to run the most popular genres last to biuild hype around the event. Translate the query into sequential stages so that you can map to your aggregation stages -- 

- Match movies that were released before 2001
- Find the average popularity of each genre
- Sort the genres by popularity
- Output the adjusted runtime of each movie

```js
db.getCollection('movies').aggregate(
  [
    {
      $match: {
        released: {
          $lte: ISODate(
            '2001-01-01T00:00:00.000Z'
          )
        }
      }
    },
    {
      $group: {
        _id: { $arrayElemAt: ['$genres', 0] },
        popularity: { $avg: '$imdb.rating' },
        top_movie: { $max: '$imdb.rating' },
        longest_runtime: { $max: '$runtime' }
      }
    },
    { $sort: { popularity: -1 } },
    {
      $project: {
        _id: 1,
        populartiy: 1,
        top_movie: 1,
        adjusted_runtime: {
          $add: ['$longest_runtime', 12]
        }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

The output shows that filems, documentaries and short films are most popular.

#### Selecting Title from each Movie category

This result won’t aid them in picking a specific movie -- they must execute a different query to get a list of movies in each genre and pick the best movie to show form the list -- Additionally, you have also learned -- 

1. Increase the first match to filter out films that aren’t applicable.
2. sort, and project fore:

```js
db.getCollection('movies').aggregate(
  [
    {
      $match: {
        released: {
          $lte: ISODate(
            '2001-01-01T00:00:00.000Z'
          )
        },
        runtime: { $lte: 218 },
        'imdb.rating': { $gte: 7 }
      }
    },
    { $sort: { 'imdb.rating': -1 } },
    {
      $group: {
        _id: { $arrayElemAt: ['$genres', 0] },
        title: { $first: '$title' },
        rating: { $first: '$imdb.rating' },
        raw_runtime: { $first: '$runtime' },
        popularity: { $avg: '$imdb.rating' },
        top_movie: { $max: '$imdb.rating' },
        longest_runtime: { $max: '$runtime' }
      }
    },
    {
      $project: {
        _id: 1,
        populartiy: 1,
        top_movie: 1,
        title: 1,
        rating: 1,
        raw_runtime: 1,
        adjusted_runtime: {
          $add: ['$longest_runtime', 12]
        }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

Can see that with a few additions to your pipeline, have extracted the movies with the highest ratings -- 

#### Working with Large DataSets

Didn’t cover how you can improve performance when working on much much larger dataset -- 

#### `$sample`

The first stp in learning how to deal with large datasets is understanding `$sample`. This stage is simple yet useful -- Only parameter to `$sample`is the desired size of your sample -- this stage randonmly selects documents and passes them through to the next stage. Fore: `{$sample: {size: 100}}`Can significantly reduce the number of documents going through your pipeline.

## Waitgroups in Go

With `watigroups`, can have a goroutine wait for a set of concurrent tasks to complete. Can think of a waitgroup as a project manager managing a set of tasks given to different workers. Set the size of the waitgroup and then use the two operation `Wait()`and `Done`d. For the pattern, typically have multiple goroutines that need to complete a few tasks concurrently. Can create a waitgroup and set its size to be equal to the number of assigned tasks. The main goroutine will hand over the tasks to the newly created goroutines, and its execution will be suspeded after it calls `Wait()`operation. Once finishes -- calls the `Done()`on the waitgroup.

- `Done()`-- Decrements the waitgroup size counter by 1
- `Wait()`-- Blocks until the waitgroup size counter is 0
- `Add(delta int)`-- increments the waitgroup size counter by delta.

For this, have this extra tool at our disposal -- fix the letter-frenquency program so that it uses waitgroups -- just like:

```go
func main() {
	wg := sync.WaitGroup{}
	wg.Add(31)
	frequency := make([]int, 26)
	mutex := sync.Mutex{}
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		go func() {
			countLetters(url, frequency, &mutex)
			wg.Done()
		}()
	}
	wg.Wait()
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, frequency[i])
	}
}
```

For the `conterLetters`just like:

```go
mutex.Lock()
for _, b := range body {
    c := strings.ToLower(string(b))
    cIndex := strings.Index(allLetters, c)
    if cIndex >= 0 {
        frequency[cIndex] += 1
    }
}
mutex.Unlock()
```

#### Changing the size of our waitgroup while waiting

Our waitgroup imp using semaphores is limited cuz we can specify the size of the waitgroup at the first -- this means that cannot change the szie after create the waitgroup. Imagine writing a filename search program, and the program will search recursively for a filename string starting from an input directory.

```go
func fileSearch(dir string, filename string, wg *sync.WaitGroup) {
    // read all files from the directory given to the function
	files, _ := os.ReadDir(dir)
	for _, file := range files {
        
        // join each file to the directory
		fpath := filepath.Join(dir, file.Name())
		if strings.Contains(file.Name(), filename) {
			fmt.Println(fpath)
		}
		if file.IsDir() {
            // if is a directory, adds 1 to the waitgroup before starting a new goroutine
			wg.Add(1)
			go fileSearch(fpath, filename, wg)
		}
	}
	wg.Done()
}
```

Now we just need a `main()`func that creates a waitgroup, adds 1 to it, and then starts a goroutine that calls our `fileSearch`function -- like:

```go
func main() {
	wg := sync.WaitGroup{}
	wg.Add(1) // add 1 to the waitgoroup for starting settings
	go fileSearch(".", "toBase.go", &wg)
	wg.Wait()
}
```

### Barriers -- 

Waitgroups are great for sync after a task has been completed. What if we need to coordinate our goroutines before we start a task -- might also need to align different executions at different points in time. Everyone fore, has to wait funtil every passenger arrives at the barrier.

Thinking of all working together on different parts of the *same computation* -- Before the goroutine start, all need to wait for their input data -- once have completed, again need to wait for another execution to collect and merge the results of their computations.

When thinking about barriers -- can visualize our goroutines as being in one of two possible states -- either executing their task or suspended and waiting for others to catch up. This `Wait()`function would suspend the goroutine’s execution until all the other goroutines participating in this barrier group catch up by also calling `Wait()`. At this point, the barrier releases all the suspeded goroutines together. 

So Barriers are different from waitgroups in that they combine the `Done()`and `Wait()`operations together into one atomic call.

#### Implmenting a barrier in Go

Go does not come with a bundled imp of a barrier -- so if we want to use one, need to implement it ourselves. Can use condition vairable to implement our barrier. Start -- know the size of group of executions that will be using this barrier, in the imp -- call the *barrier size* -- can use this size to know when enough goroutines are at the barrier. Calling `Wait()`function results in an increment of the wait counter. When the number of goroutines waiting is less than the size of the barrier, suspend the goroutine by waiting on a condition variable.

When the wait counter reaches the size of the barrier-- need to rest the counter to 0 and *broadcast* on the condition variable to wake up any suspended goroutines.

```go
type Barrier struct {
	size      int	// total number of participants in the barrier
	waitCount int	// the number of currently suspended executions
	cond      *sync.Cond
}

func NewBarrier(size int) *Barrier {
	condVar := sync.NewCond(&sync.Mutex{})
	return &Barrier{
		size:      size,
		waitCount: 0,
		cond:      condVar,
	}
}

// imp the `Wait()`  -- immediately acquire the mutex lock on the condition variable and then 
// increment the wait count
// when hasn't yet reached the szie, suspend the execution by calling Wait()
// when reach, just broadcast to wake up all
func (b *Barrier) Wait() {
	b.cond.L.Lock()
	b.waitCount += 1

	if b.waitCount == b.size {
		b.waitCount = 0
		b.cond.Broadcast()
	} else {
		b.cond.Wait()
	}
	b.cond.L.Unlock()
}
```

Can test that now -- For different periods of time -- like: Can now start two goroutines that use the `workAndWait()`.

```go
func workAndWait(name string, timeToWork int, barrier *barrier.Barrier) {
	start := time.Now()
	for {
		fmt.Println(time.Since(start), name, "is running")
		time.Sleep(time.Duration(timeToWork) * time.Second)
		fmt.Println(time.Since(start), name, "is waiting on barrier")
		barrier.Wait()
	}
}
func main() {
	barrier := barrier.NewBarrier(2)
	go workAndWait("Red", 4, barrier)
	go workAndWait("Blue", 3, barrier)
	time.Sleep(10 * time.Second)
}
```

### Parse a decimal number

```go
type Decimal struct {
    subunits int64
    precision byte // expressed a power of 10
}

func ParseDecimal(value string) (Decimal error) {
    intPart, fracPart, _ := string.Cut(value, ".")
    subunits, err := strcov.ParseInt(intPart+fracPart, 10, 64)
    // error handling
    if subunits > maxDecimal {
        return Decimal{}, ErrTooLarge
    }
}
```

Before want start writing -- think of errors that consumers will be able to understand. The first would be reutned if the string to parse is not a valid number, second will be raised if try to deal the values that are too big. like:

```go
const (
	// ErrInvalidDecimal is returned if the decimla is malformed
    ErrInvalidDecimal = Error("Unable to convert the decimal")
    
    // ErrTooLarge is returned if the quantity is too large 
    ErrTooLarge = Error("quantity over 10^12 is too large")
)
```

#### Testing `ParseDecimal`

In order to check the results, need to access the unexposed fields of the `Decimal`structure. To acheive this, our test needs to reside in the same package and aware of imp like:

```go
func TestParseDecimal(t *testing.T) {
	tt := map[string]struct {
		decimal  string
		expected Decimal
		err      error
	}{
		"2 decimal digits": {
			decimal: "1.51",
			expected: Decimal{
				subunits:  151,
				precision: 2,
			},
			err: nil,
		},
		"no decimal digits": {
			decimal: "1",
			expected: Decimal{
				subunits:  1,
				precision: 0,
			},
			err: nil,
		},
		"suffix 0 as decimal digits": {
			decimal: "1.50",
			expected: Decimal{
				subunits:  15,
				precision: 1,
			},
			err: nil,
		},
		// ...
		"with underscores for readability": {
			decimal: "12_152.03",
			err:     ErrInvalidDecimal,
		},
		"too large": {
			decimal: "123456780123456",
			err:     ErrorTooLarge,
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			got, err := ParseDecimal(tc.decimal)
			if !errors.Is(err, tc.err) {
				t.Errorf("got %v, want %v", err, tc.err)
			}
			if got != tc.expected {
				t.Errorf("got %v, want %v", got, tc.expected)
			}
		})
	}
}
```

That was an important first step, remember to run the tests and commit - with explicit messags -- regularly, especially upon completion of a piece of the dilverable.

#### Currency value object

In order to understand what this input number means -- need a currency. As mentioned, each currency has a fixed precision and cannot express any value smaller than this precision -- 0.001CAD -- isn’t an amount that we want to represent -- does exist in a real life.

First, add the currency’s precision to the struct, going to be a value between 0 and 3.

```go
type Currency struct {
	code      string // nolint: unused
	precision byte
}

// ErrInvalidCurrencyCode is returned when the currency to parse is not standard
const ErrInvalidCurrencyCode = Error("invalid currency code")

// ParseCurrency returns the currency associated to a name and may return err
func ParseCurrency(code string) (Currency, error) {
	if len(code) != 3 {
		return Currency{}, ErrInvalidCurrencyCode
	}
	switch code {
	case "IRR":
		return Currency{code: code, precision: 0}, nil
	case "MGA", "MRU":
		return Currency{code: code, precision: 1}, nil // the fraction is actually 5
	case "CNY", "VND":
		return Currency{code: code, precision: 1}, nil
	case "BHD", "IQD", "KWD", "LYD", "OMR", "TND":
		return Currency{code: code, precision: 3}, nil
	default:
		// All other circulating currencies use a hundredth division.
		return Currency{code: code, precision: 2}, nil
	}
}

```

Again, don’t trust this tool in production -- Validating the currency in real life should be done against a list that can be updated without touching the code. Also need a test like:

```go
func TestParseCurrency_Success(t *testing.T) {
	t.Parallel()

	tt := map[string]struct {
		in       string
		expected Currency
	}{
		"majority EUR":   {in: "EUR", expected: Currency{code: "EUR", precision: 2}},
		"thousandth BHD": {in: "BHD", expected: Currency{code: "BHD", precision: 3}},
		"tenth VND":      {in: "VND", expected: Currency{code: "VND", precision: 1}},
		"integer IRR":    {in: "IRR", expected: Currency{code: "IRR", precision: 0}},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			got, err := ParseCurrency(tc.in)
			if err != nil {
				t.Errorf("expected no error, got %s", err.Error())
			}
			if got != tc.expected {
				t.Errorf("expected %v, got %v", tc.expected, got)
			}
		})
	}
}

func TestParseCurrency_InvalidCurrencyCode(t *testing.T) {
	_, err := ParseCurrency("INVALID")
	if !errors.Is(err, ErrInvalidCurrencyCode) {
		t.Errorf("expected ErrInvalidCurrencyCode, got %s", err.Error())
	}
}
```

This time we are not using validatoin functions but separating the success case from the one error case -- it is mostly a matter of taste -- the only criteria -- as usual, are whether the next reader will understand what we are testing and find it easy to add or change a test cse.

## Panic recovery in other background goroutines

It’s important to realise that our middleware will only receover panics that happen in the *same goroutine* that executed the `recoverPanic()`middleware.

```go
func myHandler(w http.ResponseWriter, r *http.Request) {
    go func() {
        defer func() {
            if err := receover(); err != nil {
                log.Println(...)
            }
        }()
        dosthbackgroupdProcessing()
    }()
}
```

### Composable middleware chains

Introduces the `jusinas/alice`package to help us manage our middleware/handler chains -- It makes it easy to create *composable, reusable* middleware chains -- that can be a reall help as your app grows and your routes become more complex.

To demonstrate its feature -- allows U to rewrite a handler chain like this -- 

`return myMiddleware(myMiddleware2(myMiddleware3(myHandler)))`

Into -- clearer to understand at a glance 

`return alice.New(myMiddleware1, myMIddleware2, myMiddleware3).Then(myHandler)`

But the real power lies in the fact that you can use it to create middleware chains that can be assigned to variables, appended to, and reused -- fore:

```go
myChain := alice.New(myMiddlewareOne, myMiddlewareTwo)
myOtherChain := myChain.Append(myMiddleware3)
return myOtherChain.Then(myHandler)
```

```sh
go get github.com/justinas/alice@v1
```

```go
func (app *application) routes() http.Handler {
    mux := http.NewServeMux()
    fileServer := http.FileServer(http.Dir("./ui/static"))
    mux.Handle("/static/", http.StripPrefix("/static", fileServer))
    
    mux.HandleFunc("/", app.home)
    //...
    
    // Create a middleware chain containing our standard middleware
    standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
    return standard.then(mux) // followed by the serveMux
}
```

#### Advanced routing

In the next section of this -- going to add a HTML form to the app so that users can create new. They have different APIs -- like: `julienscmidt/httprouter`-- is most focused, lightweight and fastest of the 3 packages.

```sh
go get github.com/julienschmidt/httprouter@v1
```

```go
// a simple example to help demonstrate and exlain the syntax
router := httprouter.New()
router.HandlerFunc(http.MethodGet, "/shippet/view/:id", app.snippetView)
```

For this -- 

- Initialize the `httprouter`router and then use the `HandlerFunc()`method to add a new route which dispatches requests to our `snippetView`handler function.
- first arg `GET`just
- Second is the pattern that the request URL path must match
  - Patterns can also include a single *catch-all* in the form `*name`.
  - Like : `GET /static/*filepath`-- 

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    //...
    router.HandlerFunc(http.MethodPost, "/snippet/create", app.snippetCreatePost)
    // wrap the router with the middleware and return it as normal
    return standard.Then(router)
}
```

need a few changes to make in the `handlers.go`file -- like:

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
    // cuz httprouter matches the / path exactly, can rmove the manually check
    snippets, err := app.snippets.Latest()
    if err != nil {
        //...
    }
    data := app.newTemplateData(r)
    data.Snippets = snippets
    app.render(w, http.StatusOK, "home.html", data)
}

func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    // when using httprouter -- the values of any named parameters will be 
    // stored in the request context
    params := httprouter.ParamsFromContxt(r.Context())
    
    // can tehn use the `ByName()`method to get the value of the id
    id, err := strconv.Atoi(params.ByName("id"))
    if err != nil || id < 1 {
        app.notFound(w)
        return
    }
}

func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    title := "0 snail"
    //...
    id, err := app.snippets.Insert(title, content, expires)
    //...
}
```

Then need to update the table in the `home.html`so that the links in the HTML also use the new URL style like:

```html
<td><a href="/snippet/view/{{.ID}}">{</a></td>
```

