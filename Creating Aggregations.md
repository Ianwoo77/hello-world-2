# Creating Aggregations

Begin to explore the pipeline itself -- the following code, when pasted in the Mdb Shell, just like:

```js
const simpleFind = function() {
    // find command using filter, proj, sort and limit
    print('Find Result:');
    db.theaters.find(
        {'location.address.state': 'MN'},
        {'location.address.city': 1}
    ).sort({'location.address.city': 1})
        .limit(3)
        .forEach(print);
}

simpleFind();
```

For this function, just :

1. Match the theater collection to get a list of all theaters in the state MN
2. Proj just the city located
3. Sort the list by `city`
4. Limit the result to the first three

Rebuild this as an aggregation -- like:

```js
const simpleFind = function() {
    // find command using filter, proj, sort and limit
    print('Find Result:');
    const pipeline = [
        {$match: {'location.address.state': 'MN'}},
        {$project: {'location.address.city': 1}},
        {$sort: {'location.address.city': 1}},
        {$limit: 3}
    ];
    db.theaters.aggregate(pipeline).forEach(print);
}
```

For this, can see two get the same results -- both `find`and `aggregate`commands return a cursor, but using `.forEach`. The only noticeable difference with these is that they are now documents in array instead of functions. The `$match`stage at the very beginning of our pipeline is the equivalent of our filter document.

#### Performing Simple Aggregations

revisit the movie from scenario -- 

```js
const pipeline = [
    {$limit: 3},
    {$sort: {'imdb.rating': -1}},
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lt: new ISODate('2001-01-01')}
        }
    }
];
```

When writing aggregation pipelines, the order of operations matters -- so, rearrange them to make sure that you only limit your docuemnts at the end of your pipeline -- like:

```js
const pipeline = [
    {$sort: {'imdb.rating': -1}},
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lt: new ISODate('2001-01-01')}
        }
    },
    {$limit: 3},
];
```

This is just one of the challenges of writing aggregation pipelines -- it is an iterative process and can be cumbersome when dealing with large numbers of complex documents.

```js
const pipeline = [
    {$sort: {'imdb.rating': -1}},
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lt: new ISODate('2001-01-01')}
        }
    },
    {$limit: 3},
    {$project: {genres:1, released:1, 'imdb.rating': 1}}
];
```

#### Aggregation structures

Think of pipeline as a multi-tiered funnel -- it stars broad at the top and becomes thinner as it approches th bottom. In the pipeline, you will *sort* all the documents in the collection, and discard the ones that don’t match.

```js
const pipeline = [
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lt: new ISODate('2001-01-01')}
        }
    },
    {$sort: {'imdb.rating': -1}},
    {$limit: 3},
    {$project: {genres:1, released:1, 'imdb.rating': 1}}
]; // swap the match and sort stages to improve the efficiency
```

As can see, the aggregation pipeline is just flexible, robust, and easy to manipuilate, indeed, the aggregation pipeline is not needed for every simple query. See what the `aggregation`command provides that the `find`does not.

### Manipulating Data

Most of our activities and examples can be reduced to the following -- there is a document or documents in a collection that should return some or all the document in an easy-to-digest format. At their core, the `find`and aggregation pipeline are just about identifing and fetching correct document. Using some of the more advanced stages and techniques in the pipeline allows us to transform our data, deriving new data, and generate insights across broader scope. This more extensive imp of the aggregate command is more common than merely rewriting find command as pipeline.

#### the Group Stage

The `$group`stage allows to group documents based on a specific condition, although there are many other stages and methods to accomplish various tasks with the `aggregate`command, the `$group`stage serves as the cornerstone of the most powerful queries. Previously, the most significant unit of data we could return was a single document, can sort these documents to gain insight through a direct comparison of the documents.

Once master the `$group`, will be able to increase the scope of our queries to an entire collection by aggregating our documents into large logical units.

The most basic imp of a `$group`accepts only an `_id`, wit the value begain an expression. The expression defines the criteria by which the pipeline groups documents together. Fore:

```js
const pipeline = [
    {$group: {_id: '$title'}}
];
db.movies.aggregate(pipeline).forEach(print);
```

This `_id`becomes the `_id`of the newly outputted document with one document generated for each unique `_id`that the `$group`stage creates.

The first thing may noticed in our `$group`stage is the `$`notation before the `rated`*field* -- as stated -- the value of the `_id`key was an *expression* -- in aggregtion items, an expression can be a literal, an expression object, an operator, or field path. -- for this, are passing in a field path -- which tells the pipeline which field to access in the input documents. In this, `_id: $rated`-- `_id:”$$CURRENT.rated”`-- indicates that for each document, will fit into the group matching the same document with the `rated`key.

#### Accumulator expressions

The `$group`command can accept more than just one argument, can also accept *any number* of additional arguments in the following format like:

```js
field: {accumulator: expression},
```

- `field`will define the key of our newly computed field for each group
- `accumulator`must be supported accumulator operator. For these are group of operators, like other operators u may have worked -- such as `$lte`-- will accumulate their value across multiple documents belonging to the same group.
- `expression`-- will be passed to the `accumulator`operator as the input of what field in each document it should be accumulating.

```js
const pipeline = [
    {
        $group: {
            _id: "$rated",
            "numTitles": {$sum: 1}
        }
    }
]
```

Can see from this, created a new field called `numTitles`-- with the value of this field for each group being the sum of the documents. These newly created fields are often referred to as *computedfields*. And instead of accumulate **1**, can accumulate the value of a given field like:

```js
const pipeline = [
    {
        $group: {
            _id: "$rated",
            "sumRuntime": {$sum: "$runtime"}
        }
    }
]
```

## Using notification channels

Channels are a mechanism for communicating acorss goroutines via signaling -- a singal can be either with or without data -- but for Go -- it’s not always straightforward how to tackle the latter case. Fore:

```go
disconnectCh := make(chan bool)
```

Say want to interact with an API that provides us with such a channel -- cuz it’s a channel of Booleans, we can receive either `true`of `false`messages - In Go, an empty struct is a struct without any fields -- regardless of the architecture, it occupies zero byte of storge -- can verify using `unsafe.Sizeof`like:

```go
var s struct{}
fmt.Println(unsafe.Sizeof(s)) // 0
```

An emtpy struct is a de facto starndard to convey an absence of meaning -- fore, if we need a hash set structure, should use an empty struct as a value -- like `map[K]struct{}`.

### Using `nil`channels

A common mistake while working with Go and channels is forgetting that `nil`channes can sometimes be helpful -- 

```go
var ch chan int
<-ch // block
ch <- 0 // block forever
```

Fore, will implement a `func merge(ch1, ch2 <-chan int) <-chan int`-- function to merge two channels into a single channel -- by merging them, mean each message received in either `ch1`or `ch2`will be sent to the channel returned. First:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for v := range ch1 {
            ch <- v
        }
        for v:= range ch2 {
            ch <- v
        }
        close(ch)
    }()
    return ch
}
```

The main issue with this first version is that we just receive from `ch1`and then we receive from `ch2`-- it means that won’t receive from `ch2`until `ch1`is closed. This doesn’t fit our use case, as `ch1`may be open forever, want to receive from both channels simultaneously.

Then write an improved version with concurrent receivers using `select`like:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for {
            select {
            case v:= ch1:
                ch <- v
            case v:= <-ch2:
                ch <-v
            }
        }
        close(ch)
    }()
    return ch
}
```

For this the `select`statement lets a goroutine wait on multiple operations at the same time, -- One problem is that the `close(ch)`is unreachable -- looping over a channel using the `range`breaks when channel is just closed, but, for the way we implemented the `for/select`doesn’t catch when either `ch1`or 2 is closed. To check whether we receive a message or a closure signal -- must do:

```go
ch1 := make(chan int)
close(ch1)
v, open := <-ch1
```

So just implement this like:

```go
func merge (ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int , 1)
    ch1Closed := false
    ch2Closed := false
    
    go func() {
        for {
            select {
            case v, open := <-ch1:
                if !open {
                    ch1Closed = true
                    // break the case
                    break
                }
                ch <- v
                
            case v, open := <-ch2:
                if !open {
                    ch2Closed = true
                    break
                }
                ch <- v
            }
            
            if ch1Closed && ch2Closed {
                close(ch)
                return
            }
        }
    }()
    return ch
}
```

For this, apart from the fact that it’s starting get complex -- there is one maojr -- when one of the two channels is closed, the `for`will act as *busy-waiting* loop. So:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for ch1 !=nil || ch2 != nil {
            select {
            case v, open := <-ch1:
                if !open{
                    ch1 = nil 
                    break
                }
                ch <- v
                
            case v, open := <-ch2:
                if !open{
                    ch2==nil
                    break
                }
                ch <- v
            }
        }
        close(ch)
    }()
    
    return ch
}
```

### Variadic functions

Sometimes, U just want to pass a variable number of parameters to your function -- the best approach in this case is offered by Go’s variadic function syntax -- the last argument of a function can be of the type `...`

#### The `New()`function -- 

Go does not provide any constructor mechansim -- but can just write a `New()`method that builds a new instance. People can still use the above syntax but they should prefearably not.

```go
// Logger is used to log information
type Logger struct {
	threshold Level
}

// New returns U a logger, ready for log at the required threshold
func New(threshold Level) *Logger {
	return &Logger{
		threshold: threshold,
	}
}
```

And, fore, how can we test this -- have a very clear definition of how the logger should behave from the point of the view of the user. Start by creating a `logger_test.go`-- contrary to the previous chapter’s open-box tests.

```go
func ExampleLogger_Debugf() {
	debugLogger := New(LevelDebug)
	debugLogger.Debugf("Hello %s", "world")	
	// Output:
	// [DEBUG] this is a debug message
}
```

#### Documenting code

An important part of exposing a library is to document it so that other people understand how to use it. Comments on exported functions, methods, structs or interfaces are exteremely important, some IDE will automatically show them.

`doc.go`-- a special file -- there is an unofficial convention to write a specifal file -- in each Go package, that will describe the purpose of this package -- almost like a README -- 

```go
/*
Package pocketlog exposes an API to log your work.

First, instantiate a logger with pocketlog.New, and giving it a threshold level.
Messages of lesser criticality won't be logged.

Sharing the logger is the responsibility of the caller.

The logger can be called to log messages on three levels:
  - Debug: mostly used to debug code, follow step-by-step processes
  - Info: valuable messages providing  insights to the milestones of a process
  - Error: error messages to understand what went wrong
*/
package pocketlog
```

The `go doc`command -- one of the tools Go is shipped with is the `go doc`-- This will give U the documentation of a package or symbol that the `go`command can find in subdirectories.

#### Implement the exported methods

Is to decide where the logger is going to do its deed and finallly log. Fore:

```go
func (l *Logger) Debugf(format string, args ...any) {
	if l.threshold > LevelDebug {
		return
	}
	_, _ = fmt.Printf(format+"\n", args...)
}
```

#### Interfacing

Writing bytes in various places is an extremely common use case in all computer programs -- writing json on an HTTP output, ones and zeros to a network router -- bits into digital port to turn a light on... Go just has a set of std interfaces for the most use cases -- like: 

##### `io.Writer`

Among the most commonly cited interfaces in the stdlib -- the `io`package holds -- `io.Writer`and `io.Reader`.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

##### Implicit interfaces

One major difference between Go and other OOP -- interfaces are implicit, in order to implement an interface -- so:

```go
type Logger struct {
	threshold Level
	output io.Writer
}

// New returns U a logger, ready for log at the required threshold
func New(threshold Level, output io.Writer) *Logger {
	return &Logger{
		threshold: threshold,
		output: output,
	}
}
```

#### Refactoring -- 

For the `Info`and `Error`methods, calling the same function `fmt.Fprintf`as our writing function. And the whole is:

```go
func New(threshold Level, output io.Writer) *Logger {
	return &Logger{
		threshold: threshold,
		output:    output,
	}
}

// Debugf formats and prints a message if the log level is debug or higher.
func (l *Logger) Debugf(format string, args ...any) {
	if l.threshold > LevelDebug {
		return
	}

	l.logf(format, args...)
}

// Infof formats and prints a message if the log level is info or higher.
func (l *Logger) Infof(format string, args ...any) {
	if l.threshold > LevelInfo {
		return
	}

	l.logf(format, args...)
}

// Errorf formats and prints a message if the log level is error or higher.
func (l *Logger) Errorf(format string, args ...any) {
	if l.threshold > LevelError {
		return
	}

	l.logf(format, args...)
}

// logf prints the message to the output.
// Add decorations here, if any.
func (l *Logger) logf(format string, args ...any) {
	_, _ = fmt.Fprintf(l.output, format+"\n", args...)
}
```

## Optional Go Featurs

In this, going to talk about two Go features that are relatively new additions to the language -- *file embedding* and *generics* -- Using these is completely optional -- 

File embedding makes it possible to embed external files into your Go program itself.

### Using embedded files

one of the headline features of the Go release was the `embed`package, which makes it possible to embed external files in our existing `ui`directory -- just like:

```sh
touch ui/efs.go
```

```go
package ui
import "embed"

//go:embed "html" "static"
var Files embed.FS
```

This `//go:embed “html” “static”`-- looks like a comment, but it is actually a special comment directive -- when our app is compiled -- this comment directive instructs Go to store the files from `ui/html`and `ui/static`folders in an `embed.FS`filesystem referenced by the global variable `Files.`

- Can oly use the `go:embed`-- on global variables at the package lvel -- not within functions or methods.
- Paths cannot contain `.`or `..`elements, nor may the begin or end with a `/` -- this essentially restricts U to only embedding files that are contained in the same dirctory as the source code which has the `go:embed`directive.
- If a path is a driectory, then all fiels in that directory are resurively embeded, except for files with names that bein with `.`or `_`.so, if want to also include these files should use the `all:`prefix.
- The embedded file system is *alawys* rooted in the directory which contains the `go:embed`directive, so in the example -- our `Files`variable contains an `embed.FS`and the root of the filesystem is our `ui`.

#### Using the static files

```go
// Take the ui.Files embedded filesystem and convert it to the http.FS type
fileServer := http.FileServer(http.FS(ui.Files))

// serve a specific static file
// no longer need to strip the prefix from the request URL
router.Handler(http.MethodGet, "/static/*filepath", fileServer)
```

#### Embedding HTML templates

Update the `cmd/web/templates.go`file so that our template cache uses the embedded HTML template files from he `ui.Files`-- To help with this need to leverage a couple of the special features that Go 1.16 introduced for working with embedded filesystem -- 

- `fs.Glob()`-- returns a slice of filepaths matching a glob pattern -- it’s effectively the same as the `filepath.Glob()`function that used eariler in the book.
- `Template.ParseFS()`can be used to parse HTML templates from an embedded filesystem

```go
func newTemplateCache() (map[string]*template.Template, error) {
	cache := map[string]*template.Template{}

	// Use fs.Glob() to get a slice of all filepaths in the `ui.Files` embedded
	// filesystem which match the pattern
	pages, err := fs.Glob(ui.Files, "html/pages/*.html")
	if err != nil {
		return nil, err
	}

	// Loop through the page one-by-one
	for _, page := range pages {
		// extract the file name from the full file path
		// and assign it to the name variable
		name := filepath.Base(page)

		// Create a slice containing the filepath patterns for the template
		patterns := []string{
			"html/base.html",
			"html/partials/*.html",
			page,
		}

		// use the ParseFS() instead of ParseFiles() to parse the template files
		// from the ui.Files embedded filesystem.
		ts, err := template.New(name).Funcs(functions).ParseFS(ui.Files, patterns...)
		if err != nil {
			return nil, err
		}
		cache[name] = ts
	}
	return cache, nil
}
```

Now that this is done, when our application is buit into a binary it will contain all the UI files that it needs to run.

using generics -- Go 1.18 is the first version of the language to support *generics* -- The new generic functionlaity allows U to write code that works with different concrete types. In older version of Go, if want to check whether a `[]string`slice and an `[]int`contained a particular vlaue you would need to write two separate function. fore;

```go
func contains[T comparable](v T, s []T) bool {
    for i:= range s {
        if v==s[i]{
            return true
        }
    }
    return false
}
```



