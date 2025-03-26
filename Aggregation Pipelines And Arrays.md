# Aggregation Pipelines And Arrays

Fore, the following code snippet shows the syntax for using aggregation pipelines in `updateMany()`-- it is the same for all the update fucntions -- like:

```js
db.collection.updateMany(
	<query condition>,
    [
    <update expression 1>, <update expression 2>, ...
    ],
    <options>
)
```

May have noticed that the second argument to the function, which specifies an update expression, is not an array of multiple update expressions or stages -- as stated, the syntax is only valid if the MDB version is 4.2 or later. Instead of passing an array, if a document with a single update expression is provided, it will be executed as a normal update command. like:

```js
db.users.updateMany(
	{},
    [
        {$set: {'name_array': {$split: ['$full_name', ' ']}}},
        {$set: {
            // $arrayElemAt, operator is an array
            'first_name': {'$arrayElemAt': ['$name_array', 0]},
            'last_name': {'$arrayElemAt': ['$name_array', 1]}
        }},
        {$project: {
            'first_name': 1,
            'last_name': 1,
            'full_name': {
                // the operator is an array
                $concat: [{$toUpper: '$firstname'}, ' ', '$lastname']
            }
        }}
    ]
)
```

- Stage1 (`$set`) -- using the `$split`operator to split the full name with a white space.
- Stage2 (`$set`) -- refer to the array stored in `name_array`and create new fields to the first name and last name.
- Stage3 (`$set`)-- explicitly include the the `first_name`and `last_name`fields.

### Updating Array Fields

```js
db.movies.findOneAndUpdate(
	{_id: 111},
    {$set: {'genre': ['unknown']}},
    {returnNewDocument: true}
)
```

Remove the *fields* from the document as follows -- 

```js
db.movie.findOneAndUpdate(
	{_id: 111},
    {$unset: {'genre': ''}},
    {returnNewDocument: true}
)
```

The preceding update command use the `$unset`to remove the `genre`field.

#### Adding Elements to Arrays

```js
db.movies.findOneAndUpdate(
	{_id: 111},
    {$push: {'genre': 'unknown'}},
    {returnNewDocument: true}
)
```

The update operation finds a document by `_id`then push to the `genre`array.

```js
db.movies.findOneAndUpdate(
	{_id: 111},
    {$push: {$genre: 'drama'}}...
)
```

#### Adding multiple elements

And, `$push`can add one element at a time -- to add multiple elements to an array in a single update command, we have to use `$push`-- the following is the syntax for this like:

```js
$push: {<field_name>: {$each: [<elem1>, <elem2>, ...]}}
```

For this the elements need to be appended to the array are provided to the `$each`operato in the form of an array.

```js
db.movies.findOneAndUpdate(
	{_id:111},
    {$push: {
        genre: {$each: ['history', 'action']}
    }},
    {returnNewDocument: true}
)
```

#### Sort Array

Arrays in Mdb, and in general, are an ordered but unsorted collection of elements -- in other words, the elements of the array will always remain in the order which they were inserted. like:

```js
db.movies.findOneAndUpdate(
	{_id: 111},
    {$push: {
        genre: {$each: [], $sort:1} // also sort
    }},
    {returnNewDocument: 1}
)
```

The `genre`array is now sorted in ascending and:

```js
db.movies.findOneAndUpdate(
	{_id:111},
    {$push: {
        'genre': {
            $each: ['Crime'],
            $sort: -1
        }
    }},
    {returnNewDocument: true}
)
```

Can see from the response, the array is sorted in descending order and the new document. And can sort the array of objects like:

```js
db.items.findOneAndUpdate(
	{id:11},
    {$push: {
        'items': {
            $each: [], 
            $sort: {'price': -1}
        }
    }},
    {returnNewDocument: true}
)
```

#### As a set

The `$addToSet`operator is like `$push`, with the only difference being that an element will be pushed only if it is not present already. This operator does not change the underlying array, but it ensurees that only unique elements are pushed into. like:

```js
db.movies.findOneAndUpdate(
	{_id:111},
    {$addToSet: {'genre': 'Action'}},
    {returnNewDocument: true}
)
```

The `Action`element was not pushed to the array, cuz the array already contains it.

```js
db.movies.updateMany(
	{'tomatoes.viewer.meter': {$gt:95},
    	'tomatoes.critic.meter': {$gt:95}},
    {
        $addToSet: {genre: "Classic"}
    }
) 
// then to verify, find:
db.movies.find(
	{'tomatoes.viewer.meter': {$gt: 95},
    'tomatoes.critic.meter': {$gt: 95}},
    {'_id':0, 'title': 1, 'genres': 1}
)
```

#### Removing Array elements

```js
db.movies.findOneAndUpdate(
	{_id: 111},
    {$pop: {genre:1}}, // -1 pop the first elem
    {returnNewDocument: true}
)
```

Remving All - just using the `pullAll`opertor like:

```js
db.movies.findOneAndUpdate(
	{_id:111},
    {$pullAll: {genre: ['Action', 'Crime']}},
    {returnNewDocument: true}
)
```

Removing Matched - How can use the `$pull`to write a query condition, like:

```js
db.items.findOneAndupdate(
	{_id: 11},
    {$pull: {
        'item': {
            'quantity': 3,
            'name': {$regesx: /ck$/}
        }
    }},
    {returnNewDocument: true}
)
```

Updating Array elements -- Note that, in an array, each element is bound to a specific index position, these index positions start at zero, and we can use a pair of `[]`with the respective index position to refer to an element from the array. using such a pair of sequare brackets with `$`allows U to update elements of an array. Fore:

```js
db.movies.findOneAndUpdate(
	{_id:111},
    {$set: {'genre.$[]': 'Action'}},
    {returnNewDocument: true}
)
```

The `$[]`operator refers to just all the elements contained by the given array and the update expression will be applied to all of them. And, using the `update`command, have added a new element to the array, notice that the newly added element does not have like:

```js
db.items.findOneAndUpdate(
	{_id: 11},
    {$set: {
        'items.$[myElement]': {
            //...
        }
    }},
    {returnNewDocument: true,
    'arrayFilters': [{'myElement.quantity': null}]}
)
```

For this, use the `$set`to update the elements o the `items`array - the array element to be updated is referred to by an expression of `$[myElement]`and assigned to a new value -- which is a nested object fore this example. The identifier of `myElements`is defined using `arryFilters`based on a query condition.

```js
// exercise:
db.movies.updateMany(
	{'directors': "H.C. Potter"},
    {$set: {
        'directors.$[hcPotter]': 'H.C. Potter(Henry...)'
    }},
    {'arrayFilters': [{hcPotter: 'H.C. Potter'}]}
)
```

## copying a `sync`type

The `sync`package provides basic sync primitives such as mutexes -- condition variables, and wait groups -- For these types, there is a hard rule to follow -- **They should never be copied**. Fore, will created a thread-safe data structure to store counters -- will contain a `map[string]int`representing the current value for each counter, will also use a `sync.Mutex`cuz the accesses have be protected -- add an `increment`method to increment a given counter name fore -- 

```go
type Counter struct {
    mu sync.Mutex
    counters map[string]int
}

func NewCounter() Counter {
    return Counter{counters: map[string]int{}}
}
func (c Counter) Increment(name string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.counters[name]++
}
```

For this, the increment logic is done in a critical section -- between `c.mu.Lock()`and `c.mu.Unlock()`-- give our method a try by using the `-race`to run the following:

```go
counter := NewCounter()
go func() {
    counter.Increment("foo")
}()
go func() {
    counter.Increment("bar")
}()
```

If run, it raises a data race -- the problem in the imp is that the mutex is copied. Cuz the receiver of `Increment`is a value, whenever we call `Increment`, it performs a copy of the `Counter`struct, which also copies the mutex. The rule that *shouldn’t* be copied -- applies to the following types -- `Cond, Map, Mutex, RWMutex, Once, Pool, Waitgroup`. For this, the first is to modify the receive type fot the `Increment`method like:

```go
func (c *Counter) Increment(name string) {
    // ... same code
}
```

Changing the recevier type avoids copying `Counter`when `Increment`is called, therefore, the internal mutex is not copied -- But, if want to just keep a value recevier, the second option is to change the type of the `mu`field like:

```go
type Counter struct {
    mu *sync.Mutex
    counters map[string]int
}
func NewCounter() Counter {
    return Counter {
        mu: &sync.Mutex{},
        counters: map[string]int{},
    }
}
```

For now the `Increment`has a value receiver, it still copies the `Counter`struct, however, as `mu`is now a poitner, it will perform a pointer copy only, not an actual copy of a `sync.Mutex`. May face the issue of unintentionally copying a `sync`field in the following -- 

- Calling a method with a value receiver
- Calling a function with a `sync`argument
- Calling a function with an argument that contains a `sync`field.

### The function options pattern

Default values are a subject of high debate -- When start developing, a new web service, want to focus on the business logic -- want to make sure our logic works locally before making your service production-ready. In order to decrease the cognitive load, start with the default version of the logger -- architecturing a better logger can come later. Still want to keep this *default imp* -- writing to the std ouput, want to provide the option of writing somewhere else. One common way of doing this is by using the functional options pattern -- like:

Create a new file, `options.go`-- Define a type of functions that can be passed to the `New()`function and that will be applied one after the other.

```go
// option defines a functional option to the logger
type Options func(*Logger)
```

For this, takes a pointer on our logger then can change it directly -- change the default output to whatever the user gave us. -- like:

```go
func WithOutput(option io.Writer) Option {
    return func(lgr *Logger) {
        lgr.output = output
    }
}
```

This type of function can be passed to the `New()`function as variadic parameters.

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

Next time U want to add an option to your logger, just create a new `Option`and you are set. There is an important point to notice here, adding configuraiton functions is quite easy -- and lets the user set specific behaviors without altering the API of our library. 

#### Usage exmaple -- 

Fore, want to know how to use the lib -- there is a documentation file -- but human interaction is always so much more efficient -- like:

```go
func main() {
	lgr := pocketlog.New(pocketlog.LevelInfo, pocketlog.WithOutput(os.Stdout))

	lgr.Infof("A little copying is better than a little dependency")
	lgr.Errorf("Errors are values. Documentation for %s", "users")
	lgr.Debugf("Make the zero (%d) value usefule", 0)
	lgr.Infof("Hallo , %d, %v", 2022, time.Now())
}
```

How to test that thing -- we are already using the logger -- but it is not fully tested -- can use our library, don’t want her to come back with possible bugs -- like: The magic of interfaces means we can write a test helper that implements `io.Writer`, and give it to our `Logger`under test.

```go
func ExampleLogger_Debugf() {
	debugLogger := pocketlog.New(pocketlog.LevelDebug)
	debugLogger.Debugf("Hello %s", "world")
	// Output:
	// [DEBUG] this is a debug message
}

// testWriter is a struct that implements io.Writer
type testWriter struct {
	contents string
}

// Write imp
func (tw *testWriter) Write(p []byte) (n int, err error) {
	tw.contents = tw.contents + string(p)
	return len(p), nil
}

const (
	debugMessage = "Why write I still all one, ever the same,"
	infoMessage  = "And keep invention in a noted weed,"
	errorMessage = "That every word doth almost tell my name,"
)

func TestLogger_DebugfInfofErrorf(t *testing.T) {
	type testCase struct {
		level    pocketlog.Level
		expected string
	}

	tt := map[string]testCase{
		"debug": {
			level:    pocketlog.LevelDebug,
			expected: debugMessage + "\n" + infoMessage + "\n" + errorMessage + "\n",
		},
		"info": {
			level:    pocketlog.LevelInfo,
			expected: infoMessage + "\n" + errorMessage + "\n",
		},
		"error": {
			level:    pocketlog.LevelError,
			expected: errorMessage + "\n",
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			tw := &testWriter{}

			testedLogger := pocketlog.New(tc.level, pocketlog.WithOutput(tw))

			testedLogger.Debugf(debugMessage)
			testedLogger.Infof(infoMessage)
			testedLogger.Errorf(errorMessage)

			if tw.contents != tc.expected {
				t.Errorf("invalid contents, expected %q, got %q", tc.expected, tw.contents)
			}
		})
	}
}
```

This structure can be passed to the functional option higher in our test -- at the end of test, can then check that the writer’s contents are what we expect. In practice, `strings.Builder`or `bytes.Buffer`can be used instead of the `testWriter`-- now you know how to do a mock in case the interface need is not starndard.

#### Further functionalities

This tool offers endless possibilities for optimisations -- will be the amount of time we are alreay to spend on it. Fore, this library is not thread-safe, when multiple goroutines use the same `Writer`without any protections, the outcome can be unexpected -- will explore solutions to that in later chapters.

We chose from the start to export as many functions as there are logging levels.