# Updating Array Elements (II)

In an array, each element is bound to a specific index position -- these index positions start at zero, and can use a pair of square brackets -- with the respective index position to refer to an element from the array. Using such a pair of `[]`with `$`allows U to update elements of an array -- consider the following snippet -- shows how the `genres`array.

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$set: {'genre.$[]': 'Action'}},
    {returnNewDocument: true}
)
```

For this, `$set`in the `genres`-- is referred to using the expression like `genre.$[]`expression and provided with the value `Action`value. And the `$[]`operator just refers to all the elements contained by the given array and the update expression will be applied to all of them. Is used to update operations to all elements in an array field that match -- act as *positional all* operator. Like:

```js
db.students.updateOne(
	{_id: 1},
    {$inc: {'grades.$[]': 5}}
)
```

Update fields in Array of objects like:

```js
db.students.insertMany([
        {
            _id: 1,
            students: [
                {name: "Alice", score: 85},
                {name: "Bob", score: 90}
            ]
        }
    ]
)
db.students.updateOne(
    {_id: 1},
    {$set: {'students.$[].passed': true}},
);

db.students.find()
```

#### Nested Arrays

For nested arrays, can use the `$[]`multiple times -- like:

```js
db.students.updateOne(
	{_id: 1},
    {$inc: {'departents.$[].employees.$[].salary': 1000}}
)

// then update with arrayFilters
db.items.findOneAndUpdate(
    {_id: 11},
    {$push: {items: {'name': 'it'}}},
    {returnNewDocument: true}
)
```

The `arrayFilters`option in the Mdb, combined with the filtered positional operator like `$[<identifier]`-- allows U to update the specific elements in an array that match defined conditions during an update operation. Just like:

```js
db.collection.updateOne(
	{<query>},
    {$updateOperator: {"<arrayfield>"}}....,
    {
    'arrayFitlers': ...some condition
    }
)
```

Just like:

```js
db.items.findOneAndUpdate(
    {_id: 11},
    {
        $set: {
            'items.$[myElements]': {
                'quantity': 7,
                price: 4.5,
                name: 'marker'
            }
        }
    },
    {
        arrayFilters: [{'myElements.quantity': null}],
        returnNewDocument: true
    }
)
```

For this, the query condition of `{quantity: null}`is matched by the last element of the array and has been updated with the new document.

For the `students`collection just like:

```js
// rename the fields
db.students.updateMany(
    {},
    {$rename: {'students': 'grades'}}
)
db.students.updateOne(
    {_id: 1},
    {$set: {'grades.$[elem]': 90}},
    {
        arrayFilters: [{'elem.score': {$lt: 90}}], // note, arrayFitlers is an array
    }
);
```

#### Exercise -- updating the director’s Name

```js
db.movies.find(
    {'directors': {$regex: /^H.C. Potter/}}
)

// can use an element identifier in the update expression just like:
db.movies.updateMany(
	{'directors': 'H.C. Potter'},
    {$set: {
        "directors.$[hcPotter]": "H.C. Potter (...)"
    }},
    {
        'arrayFilters': [{hcPotter: 'H.C. Potter'}]
    }
)
```

In Mdb, `updateOne`and `findOneAndUpdate()`are both used to update a single document in a collection, they differ in functionality -- 

- `updateOne()`-- Updates the first document that matches the query criteria but does not return the document itself. It returns metadata about the update operation
- `findOneAndUpdate`-- update the first matches the query and returnes either original, or updated one.

### Data Aggregation

Now begin exploring and manipulating our data as we would with any other dbs -- In more straightforward situations, these result sets may be enough to answer your desried business question or satisfy a use case. However, more complex problems require more complex queries to answer. Fore the basic limitation is where U have data contained in two separate collections -- to find the correct data, would have to run two queries instead of one, joining the data on the client or app level.

The aggregation pipeline does precisely what the name implies -- it allows U to define a series of stages that filter, merge, and organize data with much more control than the std `find`command. The key element in aggregation is called the pipeline -- will cover it in detail shortly -- 

```js
const pipeline = [];
var options = {} // will explore the options
var cursor = db.movies.aggregate(pipeline, options);
```

The `pipeline`parameter contains all the logic to find, sort, project, limit, transform, and aggregate our data. The `pipeline`itself is passed in an array of JSON, Can just think of this as a series of instructions to be sent to the dbs, adnd then the resulting data after the final stge is stored in a `cursor`to be returned to you.

And the `options`-- allows U to specify the details of configuration, such as how the aggregation should execute or some flags that are required during degugging and building your pipelines. Like:

```js
const MyAggregation_A = function() {
    print("...");
    const pipeline = [];
    // the next stores our result in a cursor
    const cursor= db.movies.aggregate(pipeline);
    // this will print the next iteration of our cursor
    printjson(cursor.next());
}
```

## Sync multiple goroutines with waits and broadcasts

When have multiple goroutines suspended on a condition `Wait`, `Signal()`will arbitrarily wake up one of these goroutines. Note -- when a group of goroutines is suspedned on the `Wait()`and call `Signal`, only wake one of the goroutines, **have no control** over which the system will resume.

```go
func main() {
	cond := sync.NewCond(&sync.Mutex{})
	playersInGame := 4
	for i := 0; i < playersInGame; i++ {
		go playerHandler(cond, &playersInGame, i)
		time.Sleep(time.Second)
	}
}
```

Can make use of condition variables by having more then one goroutine wait on the same condition. Each goroutine follows the same condition variable pattern -- hold the mutex lock while substracting a count from the `playersRemaining`variable and checking to see if more players need to connect.

```go
func playerHandler(cond *sync.Cond, playerRemaining *int, playerId int) {
    // lock the mutex on the condition variable to avoid RC
	cond.L.Lock()
	fmt.Println(playerId, ": connected")
	*playerRemaining--
	if *playerRemaining == 0 {
		cond.Broadcast()
	}
	for *playerRemaining > 0 {
		fmt.Println(playerId, ": waiting for more players")
		cond.Wait()
	}
	cond.L.Unlock()
	fmt.Println("All players connected, ready player", playerId)
    // Game started
}
```

### Counting Samphores

How mutexes allow only one goroutine to have access to a shared resource -- while a readers-writer mutex allows us to specify multiple concurrent reads -- but exclusive writes. Samphores gives us a different type of concurrency control. They allow fixed number of permits that enable concurrent executions to access shared resources. Once all permits are used, further requests for access will have to wait until a permit is free again.

DEF -- a semphore with only one permit is sometimes called a *binary samphore*. And to understand how can use samphores, first have a look at the 3 functions it provdies -- 

- Creates a new one with X permits
- Acquire permit function -- A goroutine will take one permit from the samphore. And if none are available, will suspend and wait until one becomes available.
- Release permit functions -- releases one permit so a goroutine can use it again with the acquire function.

```go
type Semaphore struct {
	permits int
	cond *sync.Cond
}

func NewSemaphore(permits int) *Semaphore {
	return &Semaphore{
		permits: permits,
		cond: sync.NewCond(&sync.Mutex{}),
	}
}
```

Then implement the `Acquire()`function, need to call the `wait()`on a condition variable whenever the permits are 0 or less -- if there are enough permits, simply subtract 1 from the permit count. And the `Release()`function just does the opposite.

```go
func (rw *Semaphore) Acquire() {
	rw.cond.L.Lock() // Acquires mutex to protect permits variable
	for rw.permits <= 0 {
		rw.cond.Wait()
	}
	rw.permits--
	rw.cond.L.Unlock()
}

func (rw *Semaphore) Release() {
	rw.cond.L.Lock()
	rw.permits++
	rw.cond.Signal() // signals condition variable permits by 1
	rw.cond.L.Unlock()
}
```

#### Never miss a signal with semaphores

The problem we had was that we could end up calling the `Signal()`function before `main()`goroutine had called `Wait()`. Can solve this by using a semaphore initialized with 0 permits -- this gives us a system which calling `Release()`acts as our signal of work complete. In this system, it doesn’t matter if we call `Acquire()`before or after the work is complete.

```go
func doWorkSem(sem *samphore.Semaphore) {
	fmt.Println("Work started")
	fmt.Println("Work finished")
	sem.Release()
}

func main() {
	sam := samphore.NewSemaphore(0)
	for i:=0; i<50000; i++ {
		go doWorkSem(sam)
		fmt.Println("waiting for child goroutine")
		sam.Acquire()
		fmt.Println("child goroutine finished")
	}
}
```

#### Sync with waitgroups and barriers

`Waitgroups`and `barriers`are two sync abstractions that work on groups of execution. Typically use *waitgroups* to wait for a group of tasks to complete - use barriers to sync many execution at a common point.

#### Waitgroups in Go

With waitgroups, can have a goroutine wait for a set of concurrent tasks to complete. Can think of a waitgroup as a project manager manging a set of tasks given to different workers. In the first imp, used a `sleep()`to wait for some seconds until all the goroutines completed their downloads.

Set the size of the waitgroup and then use the two operations `Wait()`and `Done()`-- in this pattern, typically have multiple goroutines that need to coplete a few tasks concurrently. And its execution will be suspended after it calls `Wait()`operation -- once a goroutine finishes its task it calls the `Done()`op on the waitgroup when all goroutines have called the `Done()`operation for all their assigned tasks, the main unblock.

- `Done()`-- Decrements the waitgroup size counter by 1
- `Wait()`-- Blocks until the waitgroup size conter is 0
- `Add(delta int)`-- increments the waitgroup size counter by delta

```go
func doWork1(id int, wg *sync.WaitGroup) {
	i := rand.Intn(5)
	time.Sleep(time.Duration(i) * time.Second)
	fmt.Println(id, "done working after", i, "seconds")
	wg.Done()
}

func main() {
	wg := sync.WaitGroup{}
	wg.Add(4)
	for i := 0; i < 4; i++ {
		go doWork1(i, &wg)
	}
	wg.Wait()
	fmt.Println("All done")
}
```

Then we have this extra tool at our disposal, fix the letter-frequency progam so that it uses waitgroups -- in the `main()`goroutine, instead of calling the `sleep`create a goroutine that calls our existing `CountLetters()`func and then calls the `Done()`on the waitgroup.

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

### How to represent money

How should we represent a given amount of money -- A first idea could be simply use a float -- but there are just two problems in this navie approach like:

1. The rounded problem.
2. The precision of the floating-point numbers is worth diving into -- 

#### Floating-point numbers

Fore, `float32`guarantees a precision of only 6 digits -- this means anything farther down the line from the first non-zero digit, in a `float32`-- can safely be considered gibberish. Fore 123_456_789 -- if `Printf`this, just lose the correctness ofafter `7`.

When using `float64`variables, the precision is 15 guaranteed digits -- which would be aound a few seconds. And sometimes, a precision of 7 significant digits will be enough -- when averaging grades, using `float32`works perfectly, an error of a millonth of a dollar would seem tolerable.

#### Back to money

In order to represent an amount of money, it is therefore always preferable to default to fixed precision -- unless U know for certain that the floating point will not cuz any harm.

One of the most common mistakes programmers do when using float is using the `==`as a comparator. The safe way of comparing floating-point number is to take into account the precision -- if two numbers are within the precision range of the largest -- considered equal.

#### Decimal imp

That was a lot of theory -- knowing all this -- there are a number of different possibilities for implementing this `Decimal`struct. Fore:

```go
// Decimal is capable of string a decimal value
// such as 30 or 1543.243
type Decimal struct {
	// subunits is the amount of subunits
	subunits  int64
	precision byte
}
```

#### Constructing the Decimal

The fields of the structs are not exposed, and we really want to keep it that way. Needing to build function for `Decmial`and `Amount`.

One common way of creating a struct in Go is the `New`-- like: Then write a `ParseDecimal`function in the `decimal.go`file that returns a `Decimal`or an `error`-- like:

```go
type Error string

func (e Error) Error() string {
	return string(e)
}

const (
	// ErrInvalidDecimal is returned when decimal is malformed.
	ErrInvalidDecimal = Error("unable to convert the decimal")

	// ErrorTooLarge is returned the quantity is too large
	ErrorTooLarge = Error("quantity over 10^12 is too large")

	// maxDecimal value is 1000B
	maxDecimal = 1e12
)
```

#### parse a decimal number -- 

Write a `ParseDecimal`function in the `decimal.go`file that returns a `Decimal`or an error -- don’t forget to write a test -- you will need `strconv.ParseInt`to convert strings to integers, and `strings.Cut`to split a string on a separator -- in a terminal, can run fore `go doc strconv.ParseInt`and `go doc strings.Cut`for some inspiration. So for the `ParseDecimal(string)`jut like:

```go
func ParseDecimal(string) (Decimal, error) {
    // 1 - find the position of the . and split on it.
    // 2 - convert the string without the . to an integer.
    // 3 - add some consistency check
    // 4 - return the result.
}
```

`Cut`will break the string into two parts, right after the first instance of the given separator, and return a boolean telling whether the separator was found. And `Split()`breaks the string into substrings, delimited by separators.

#### Error types

It is nearly part of the definition of parsing -- there mgiht be problems -- if the user sends us letters -- return an error:

```go
errors.As(err error, target any) bool
```

It reports whether err’s concrete value is assignable to the value pointed to by the target -- it becomes very handy when U are using a library and want to compare the type of error with the domain error -- fore, is this error coming from the money package -- 

```go
type Error string
func (e Error) Error() string {
    return string(e)
}

// using this
var moneyErr money.Error
if errors.As(err, &moneyErr) {...}
```

```go
// ParseDecimal converts a string into its Decimal representation
// It assumes there is up to one decimal separator fore .
func ParseDecimal(value string) (Decimal, error) {
	intPart, fracPart, _ := strings.Cut(value, ".")
	subunits, err := strconv.ParseInt(intPart+fracPart, 10, 64)
	if err != nil {
		return Decimal{}, fmt.Errorf("%w: %s", ErrInvalidDecimal, err.Error())
	}
	if subunits > maxDecimal {
		return Decimal{}, ErrorTooLarge
	}
	precision := byte(len(fracPart))
	dec := Decimal{
		subunits:  subunits,
		precision: precision,
	}

	// clean the representation a bit
	dec.simplify()
	return dec, nil
}

// simplify removes trailing zeros from the decimal representation
func (d *Decimal) simplify() {
	// using %10 returns the last digit in base 10 of a number
	for d.subunits%10 == 0 && d.precision > 0 {
		d.precision--
		d.subunits /= 10
	}
}
```

## Early returns

Another thing to mention is that if you call `return`in your middleware function *before* you call `next.ServeHTTP()`, the the chain will stop being executed and control will flow back upstream like:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // if the user isn't authorized send a 403
        if !isAuthorized(r) {
            w.WriteHeader(http.StatusForbidden)
            return
        }
        // otherwise, call the next handler
        next.ServeHTTP(w,r)
    })
}
```

#### Debugging CSP issues

While CSP headers are *great* and you should definitely use them -- worth saying that spent hours trying to debug why sth isn’t working as expected.

### Request Logging

Continue in the same vein and add some middleware to log HTTP requests, Specially, going to use the *information* logger that created eariler to record the IP address of the user, which URL and method are being requested. In the `middleware.go`file and create a `logRequest()`method using the std middleware pattern like:

```go
func (app *application) logRequest(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr, r.Proto, r.Method, r.URL.RequestURI())
        next.ServeHTTP(w, r)
    })
}
```

Then just like:

```go
func (app *application) routes() http.Handler {
    mux := http.NewServeMux()
    fileServer := http.FileServer(http.Dir("./ui/static/"))
    mux.Handle("/static/", http.StripPrefix("/static/", fileServer))
    //...
    return app.logRequest(secureHeaders(mx))
}
```

#### Panic Receovery

In a simple Go, when your code panics - will return in the app being terminated straight away -- Go’s HTTP server assumes that the effect of any panic is isolated to the goroutine serving the active HTTP request -- Specifically, following an panic our server will log a stack trace to the server error log. Just like:

```go
func (app *application) home(w http.ResponsWriter, r *http.Request) {
    if r.URL.Path != "/" {
        app.notFound(w)
        return
    }
    panic("oops! sth went wrong") // deliberate panic
    //...
}
```

For this, all we will get is just an empty response due to Go closing the underlying HTTP connection following the panic. This isn’t a great experience for the user -- would be a more appropriate and meaningful to send them a proper HTTP response with a 500 status.

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// create a deferred function -- 
		// always be run in the event of a panic as Go unwinds the stack
		defer func() {
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				app.serverError(w, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

There are two details about this which are worth explaining -- 

- Setting the `Connection: Close`-- trigger to make Go’s HTTP server automatically close the current connection after a response has been sent. It also informs the user that the connection *will be closed*.
- The value returned by the builtin `recover`has the type `any`-- its underlying type could be `string, error`.. or sth else - whatever the parameter passes to the `panic`was.

#### Panic recovery in other background goroutines -- 

Realise that our middleware will only recover panics that happen in the *same goroutine* that executed the `receoverPanic`middleware. Fore, have a handler which spins up another goroutine then any panics that happen in the second goroutine will not be recovered -- not by the `recoverPanic()`.

So if spinning up additional goroutines from within your web app and there is any chance of a panic must make sure that you recover any panics from within those too like:

```go
func myHandler(w http.ResponseWriter, r *http.Request) {
    // spin up a new gorouine to do some background processing
    go func() {
        defer func() {
            if err != recover(); err != nil {
                log.Println(...)
            }
        }()
        dosthesle()
    }()
    //...
}
```

