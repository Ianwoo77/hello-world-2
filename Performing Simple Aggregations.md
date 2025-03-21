# Performing Simple Aggregations

```js
const findTopRomanceMovies = function () {
    print('Finding top classic Romance Movies...');
    const pipeline = [
        {$limit: 3},
        {$sort: {'imdb.rating': -1}},
        {
            $match: {
                genres: {$in: ["Romance"]},
                released: {$lte: new ISODate("2001-01-01")}
            }
        }
    ];
    db.movies.aggregate(pipeline).forEach(print);
};
findTopRomanceMovies();
```

Change the order in the pipeline like:

```js
const findTopRomanceMovies = function () {
    print('Finding top classic Romance Movies...');
    const pipeline = [
        {$sort: {'imdb.rating': -1}}, // first sort
        {
            $match: {
                genres: {$in: ["Romance"]},
                released: {$lte: new ISODate("2001-01-01")}
            }
        }, // then match get the last 3
        {$limit: 3},
        {$project: {genres:1, released:1, 'imdb.rating': 1}}
    ];
    db.movies.aggregate(pipeline).forEach(print);
};
```

#### Aggregation structure

Think of the pipeline as a *multi-tiered* funnel -- it starts broad at the top and becomes thinner as it approaches the bottom -- As your pour documents into the top of the funnel, there are many documents, but as you move further down, this number keep reducing at every stage -- until only the documents that U want as output exit at the bottom.

Fore, will short the documents in the collection, and discard the ones that don’t match first, so:

```js
const pipeline = [
    {
        $match: {
            genres: {$in: ["Romance"]},
            released: {$lte: new ISODate("2001-01-01")}
        }
    },
    {$sort: {'imdb.rating': -1}},
    {$limit: 3},
    {$project: {genres:1, released:1, 'imdb.rating': 1}}
];
```

Another thing to consider is that -- although you do have a list of movies matching the criteria, you want your result to be meaningful to your use case.

### Manipulating Data

Most of our activaites and examples can be reduced to the following -- there is a document or documents in a collection that should return some or all the documents in an easy-to-digest format. At their core, the `find`command and aggregation pipeline are just about identifying and fetching the correct document. However, the capability of the aggregation pipeline is much more robust and broader than that of the `find`.

#### The Group stage

The `$group`stage allows U to group documents based on a specific condition -- Note that although there are many other stages and methods to accomplish various tasks with the `aggregate`command the `$group`stage serve as the cornerstone of the most powerful queries -- Once master the `$group`stage, will be to increase the scope of our queries to an entire collection by aggregating our documents into large logical units. Once we have the larger groups, can just apply our filters, sorts, limits and projections just as we did on per-document basis. Fore:

```js
const pipeline = [
    {$group: {_id: '$rated'}}
];
db.movies.aggregate(pipeline)
```

For this, `$group`is the `$`notation before the `rated`field -- The value of our `_id`key was an *expression* -- in aggregation terms, an expression can be a literal, an expression object, an operator, or a field path.

When aggregating, need to tell the pipeline that we just want to access the field of the document that it is currently aggregating.

#### Accumulator Expressions

The `$group`command can accept more than just one argument -- it can also accept any number of additional arguments in the following format: `field: {accumulator: expression}`

- `field`will define the key of our newly computed field for each group
- `accumulator`must be a supported accumulator operator. As the name suggests, they will accumulate their value across multiple documents belonging to the same group.
- `expression`-- will be passed to the `accumulator`operator as the input of what field in each document it should be accumulating. Like:

```js
const pipeline = [
    {$group: {
        _id: '$rated',
        'numTitles':{$sum:1}}}
];
db.movies.aggregate(pipeline)
```

Can see from this that can create a *new field* named `numTitles`-- with the value of this field for each group being the sum of the documents. Theses newly created fields are often referred as *computed fields* -- for each document in a group, we can sum the literal vlaue 1 with the accumulated result for.

Similarly, instead of accumulating 1 on each document, can accumulate the value of given field -- fore, like:

```js
const pipeline = [
    {$group: {
        _id: '$rated',
        'sumRuntime':{$sum: '$runtime'}}}
];
db.movies.aggregate(pipeline)
```

Although this is just a simple example, can see that with just a single aggregation stage and two parameters, can begin to transform our data in exciting ways. Several accumulator operators can be combined and layered to generate much more complex and insightful info about groups. Just like:

```js
const pipeline = [
    {$group: {
        _id: '$rated',
        'avgRuntime':{$avg: '$runtime'}}}
];
db.movies.aggregate(pipeline)
```

These average runtime values are not particularly useful in this case, just add another stage to project runtime -- using the `$trunc`stage -- like:

```js
const pipeline = [
    {
        $group: {
            _id: '$rated',
            'avgRuntime': {$avg: '$runtime'}
        }
    },
    {
        $project: {
            'roundedAvgRuntime': {$trunc: '$avgRuntime'}
        }
    }
];
db.movies.aggregate(pipeline)
```

This will give us a much more nicely formatted result.

## Using Mutexes accurately with slices and maps

While working in concurrent contexts where data is both mutable and shared, we often have to implement protected accesses around data structures using mutexes -- a common mistake is to use mutexes inaccurately when working with slices and maps. Fore, implement a `Cache`struct used to handle caching for customer balances -- like:

```go
type Cache struct {
    mu sync.RWMutex
    balances map[string]float64
}
```

then, add an `AddBalance`method that mutates the `balance`map -- the mutation is done in a critiral section. Like:

```go
func (c *Cache) AddBalance(id string, balance float64) {
    c.mu.Lock()
    c.balances[id] = balance
    c.mu.Unlock()
}
```

Meanwhile, have to implement a method to calculate the average balance for all the customers -- one idea is to handle a minimal CS in this way -- like;

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    balances := c.balances
    c.mu.RUnlock()
    
    sum := 0
    for _, balance := range balances {
        sum += balance
    }
    return sum/float64(len(balances))
}
```

Frist we just create a copy of the map to local `balances`variable -- only the copy is done in the CS to iterate over each balance and calculate the average outside of the CS -- For this, a data race occurs -- Internally, a map is a `runtime.hmap`struct containing mostly metadata and a pointer referencing data buckets. 

So the `balances := c.balances`doesn’t copy the actual data.  For the app, meanwhile, the two goroutines perform operations on the same data set. Should just protect the whole function like:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    defer c.mu.RUnlock()
    //... sum..and average
}
```

And the CS now encompasses the whole function, including the iterations. This just prevent data races. And another option, if the iteration operation isn’t lightweight, is to wrok on the actual copy of the data and protect only the copy.

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    m := make(map[string]float64, len(c.balances))
    for k, v := c.balances {
        m[k]=v
    }
    c.mu.RLock()
    sum := 0
    for _, balance := range m {
        sum += balance
    }
    return sum/float64(len(m))
}
```

So, in summary, just have to be careful with the boundaries of a mutex lock -- have seen why assigning to a map isn’t enough to protect against data races.

### Using `sync.WaitGroup`

`sync.WaitGroup`is a mechanism to wait for `n`operations to completes, generally, use it to wait for `n`goroutines to complete -- first recall the public API, then will look at a pretty frequent mistake leading to non-deterministic behavior. `wg := sync.WaitGroup{}`-- internally, a `sync.WaitGroup`holds an internal counter initialized by default 0 can increment this counter using the `Add(int)`method and decrement it using `Done()`or `Add`with a *negative value*.

In the following, will initialize a wait group, start 3 goroutines that will update a counter atomically, and then wait for them to complete, want to wait for these 3 goroutine to print the value of the counter -- like:

```go
wg := sync.WaitGroup{}
var v uint64

for i:=0; i<3; i++ {
    go func() {
        wg.Add(1) // must not in the child groutines
        atomic.AddUint64(&v, 1)
        wg.Done()
    }()
}
wg.Wait()
print(v)
```

For this, cuz `wg.Add(1)`is called within the newly created groutine -- not in the parent goroutine -- hence, there is no guarantee that we have indicated to the wait group that we want to wait for 3 before calling `wg.Wait()`. So, first can call the `wg.Add()`just before the loop with 3 like:

```go
wg := sync.WaitGroup{}
var v uint64
wg.Add(3)
for i:=0; i<3; i++ {
    go func() {...}
}
```

Or can call `wg.Add()`during each loop iteration before spinning up the child like:

```go
wg := sync.WaitGroup{}
var v uint64
for i:=0; i<3; i++ {
    wg.Add(1)
    go func() {//...}
}
```

### Using `sync.Cond`

The `sync.Cond`is the least used and understood. The example in this -- implements a donation goal mechanism -- an app that raises alerts whenever specific goals are reached -- will have one goroutine in charge of incrementing a balance -- in contrast, other goroutine will receive updates and print a message whenever a specific goal is reached.

```go
type Donation struct {
    mu sync.RWMutex
    balance int
}
donation := &Donation{}

// listener groutines
f := func(goal int) {
    donation.mu.RLock()
    for donation.balance < goal { // busy loop!
        donation.mu.RUnlock()
        dnnation.mu.RLock()
    }
    print(donation.balance)
    donation.Mu.RUnlock()
}

go f(10)
go f(15)

// update goroutine
go func() {
    for {
        time.Sleep(time.Second)
        donation.mu.Lock()
        donation.balance++
        donation.m.Unlock()
    }
}()
```

This will work as expected - however the main issue -- and what makes this a terrible imp -- is the busy loop -- for each listener goroutine keeps looping until its donation goal is met -- which just waste a lot of CPU cycles and makes the CPU usage giganitc. Fore, using channel like:

```go
type Donation struct {
    balance int
    ch chan int
}

donation := &Donation {ch: make(chan int)}

// listen goroutines -- 
f := func(goal int) {
    for balance := range donation.ch {
        if balance >= goal {
            print(blance)
            return
        }
    }
}
go f(10)
go f(15)

// update that
for {
    time.Sleep(time.Second)
    donation.balance++
    donation.ch <- dnoaion.balance
}
```

For this, the problem -- the default distribution mode with multiple goroutines receiving from a *shared channel* is round-robin -- it can change if one goroutine isn’t ready to receive messages -- Go distributes the message to the next available goroutine. Each message is received by a single goroutine -- therefore, the first goroutine didn’t receive the message in this example, but the second one did. The updater also has to know when all the listner stop receiving messages to the channel.

So a condition variable is a container of threads -- waiting for a certain condition -- like:

```go
type Donation struct {
    cond *sync.Cond
    balance int
}
donation := &Donation {
    cond: sync.NewCond(*sync.Mutex{}),
}
f := func(goal int) {
    donation.cond.L.Lock()
    for donation.balance < goal {
        // acutally, unlock
        donation.cond.Wait() // suspend gorotuine and wait for ..
        // here, unlock
    }
    print(donation.balance)
    donation.cond.L.UnLock()
}

go f(10)
go f(15)
for {
    time.Sleep(time.Second)
    donation.cond.L.Lock()
    donation.balance ++
    donation.cond.L.Unlock()
    donation.cond.Broadcast()
}
```

Just need to note that the call to `Wait()`*must happen within a CS* -- cuz, actually, the imp of `Wait`is like:

1. Unlock the mutex
2. Suspend the goroutine, and wait for a notification
3. Lock the mutex again when notification arrives

Using the `sync.Cond`with the `Broadcast`wakes all goroutines currently waiting on the condition.

### The functional options pattern

Default values are a subject of high debate among the development theorists and theologists -- some people love them cuz it makes everythign discovable and therefore easier to bootstrap. Fore, want to make sure our logic works locally before making your service production-ready -- fore, in order to decresase the cognitive code, we start with the default version of the logger -- architecturing a better logger can come later -- 

#### Creating configurations

New file for `options.go`-- configuration functions will be written here -- like:

```go
type Option func(*Logger)

// WithOutput returns a configuration function that set the output of logs
func WithOutput(output io.Writer) Option {
	return func(l *Logger) {
		l.output = output
	}
}
```

`Option`just defines a functional optoin to our logger -- this func takes a ponter on our logger so that it can change it directly -- in our case, change the default output to whatever the user gave us. This type of function can be passed to the `New()`function as variadic paramters.

```go
func New(threshold Level, opts ...Option) *Logger {
	lgr := &Logger{
		threshold: threshold,
		output:    os.Stdout,
	}
	for _, configFunc := range opts {
		configFunc(lgr)
	}
	return lgr
}
```

Next time U want to add an option to your logger, just create a new `Option`and you are set. there is an important point to notice here -- adding configuration functions is quite easy -- and lets the user set specific behavior without alterting the API of our library. Our `New`function accepts as many configuration functions as the user needs.

#### Usage example

Fore, want to know how to use the library, there is a documentation file -- could write a small example and sent it to her -- outside of the library, init a new module and create a `main.go`file, define a func `main`.

```go
func main() {
	lgr := pocketlog.New(pocketlog.LevelInfo, pocketlog.WithOutput(os.Stdout))

	lgr.Infof("A little copying is better than a little dependency")
	lgr.Errorf("Errors are values. Documentation for %s", "users")
	lgr.Debugf("Make the zero (%d) value usefule", 0)
	lgr.Infof("Hallo , %d, %v", 2022, time.Now())
}
```

#### How to test that thing

We are already using the logger, but it is not fully tested -- Use our library, don’t want her to com back with possible bugs -- the magic of interfaces means that we can write a test helper that implemetns `io.Writer`-- give it our test.

At the end of the test file, write a new `testWriter`struct -- make it implement `io.Writer`-- but instead of writing to a dest, it validates theoutput string -- fore, can keep a field in the struct where U concatenate the output.

```go
// testWriter is a struct that implements io.Writer
type testWriter struct {
	contents string
}

// Write imp
func (tw *testWriter) Write(p []byte) (n int, err error) {
	tw.contents = tw.contents + string(p)
	return len(p), nil
}
```

Then test it...

## Using generics

Very broadly, the new generics functionality allows U to write code that works with *different* concrete types -- 

```go
func containsString(v string, s []string)bool...
```

With generics, it’s possible to write a single `contains`function that will work for string, int... and other *comparable* types like:

```go
func contains[T comparable] (v T, s []T) bool {
    for i := range s {
        if v == s[i] {
            return true
        }
    }
    return false
}
```

#### When to use generics

For now at least, should aim to use generics *judciously and cautiously* -- 

- Find yourself writing repeated boilperlate code for just different data types.
- R writing code and find yourself reaching for the `any`type -- An example of this might be when you are creating a data structure which needs to operate on different types.

In contrast -- probably don’t want to use generics -- 

- If it makes your code harder to understand and less clear
- If all the types that you need to work with have a common set of methods -- in which case it’s brtter to define and use a normal interface type instead.
- Just cuz you can, instead default to writing simple non-generic, and switch to a generic version.

#### Using generics in the app

Perhaps the only thing really suited to being made generic is the `PermittedInt()`function in the validator.go file: Go ahead and change this to be a generic `PermittedValue()`function, which can then use each time that we want to check that a user-provided value is in a set of allowed values -- `string, int, float64`or any other `comparable`types.

```go
func PermittedValue[T comparable](value T, permittedValues ...T) bool {
	for i := range permittedValues {
		if value == permittedValues[i] {
			return true
		}
	}
	return false
}
```

Then need update our `snippetCreatePost`handler to use the new `PermittedValue()`function in the checks fore:

```go
// in the handlers.go
form.CheckField(validator.PermittedValue(form.Expires, 1, 7, 365), 
                "expires", "This field must equal 1, 7 or 365")
```

After making those changes, should find that app just compiles correctly and continues to function the same way.

### Testing -- 

Like structuring and organizing your app code, there is no single *right* way to structure and origanize your tests in Go, but there are just some conventions -- patterns and good-practices that you can follow.

- How to create and run table-driven unit tests and sub-tests in Go
- Unit test your HTTP handlers and middleware
- Perform end-to-end testing of your web app routes, middleware and handlers.
- Create *mocks* of your dbs models and use them in the unit tests
- A pattern for testing CSRF-protected HTML form submissions.
- How to use a test instance of MySQL to perform integration tests
- How to easily calculate and profile code coverage for your tests.

#### Using testing and sub-tests

Create a unit test to make sure that our `humanDate`made back in the -- is ok.