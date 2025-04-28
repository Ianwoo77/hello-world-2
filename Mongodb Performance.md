# Mongodb Performance

This introduces U the concept of query optimization and performance improvement in Mdb. Will first explore the internal working of query execution and identify the factors that can affect query performance -- before moving on to dbs indexes and how indexes can reduce query sexecution time -- will also learn how to create, list, and delete indexes, and study the various types of indexes and their benefits.

### Query Analysis

In order to write efficient queries, it is important to analyze them, find any possible performance issues, and fix them. Creating and using indexes on a collection *narrows* down the number of records being scanned and improves the query performance noticeably.

1. Index scan stage -- Scans the available indexes to support the input query
2. Collection scan stage -- Scans the collection to find the documents for the input query
3. Sort stage -- Sorts the results as desired by the input query
4. Prjection stage -- Applies the projects as per the input query

Explaining the query -- 

The `explain()`is extremely useful for exploring the internal working of a query. The function can be used along with a query or a command to print detailed statistics pertinent to their execution.

- Query exeuction time
- Number of documents scanned
- Number of documents returned
- The index that are used

```js
db.movies.find(
    {year: 2015},
    {title:1, 'awards.wins':1}
).sort({'awards.wins': -1})
.explain("executionStats")

db.movies.getIndexes()
```

The `explain`function can also be used with the following commands -- 

`remove, update, count, aggregate, distinct, findAndModify`. And the `explain`function can tkae an optional argument called verbosity mode-- which controls what information is returend by the function.

- `queryPlanner`-- default option and prints query details such as rejected plans, the winning plan, and the execution stages of the winning plan.
- `exeuctionStatus`-- prints all the information provided by the `queryPlanner`along with detailed execution statics for the query exuection.
- `allPlanExecution`-- details provided by the `executionStatus`along with the details of rejected execution plans.

The execution stats provide useful metrics pertinent to each execution phrase -- along with some top-level fields where some metrics are aggregated over the toal execution of the query. The followings -- 

- `exeuctionTimeMillis`-- totol time in ms
- `totalKeysExamined`-- indicates the number of indexed keys that were scanned
- `nReturned`-- returned numbers

#### Linear Search

When execute a `find`query with search criterion on a collection, the dbs search engine picks the first record in the collection and checks whether it matches the given criteria. And if no match found, the search engine moves on to the next record to find a match. These perform better when they are just applied to a small amount of data, or in the best-case scenarios, where the required term is found within the first search.

### Introduction to Indexes

In MongoDB, indexes are created on a field or a cominbation of fields, The dbs maintains a special registry of indexed fields and some of their data. The registry is easily searchable, as it maintains a logic link between the value of an indexed field and the respective documentin the collection. The values in a registry are always *sorted* in ascending or descending order of the values.

To better understand how the index regsitry helps during searches -- like:

```js
db.theaters.find({"theaterId": 1009})
```

- No index -- scanned 1564, returned 1
- Index -- scanned 1 returned 1

Creating and listing indexes

```js
db.collection.createIndex(keys, options)
```

`keys`are just a list of k-v pairs, where each pair consists of a field name and sort order, and the optional second argument is a set of options to control the indexes.

```js
db.movies.createIndex({year:1})
db.movies.getIndexes()
```

Index Names -- Mongodb assigns a default name to an index if a name is not provided explicitly -- the default name of an index consists of the field name and sort order. like:

```js
// can also create an index with a specific name
db.theaters.createIndex(
	{threadId: -1},
    {name: 'myTheaterIdIndex'}
)
```

#### Creating an index using Mondb Altas

For this, have scuccessfully created indexes using the Mdb Atlas portal.

## Programming with channels

Working with channels requires a different way of programming than when using memory sharing. The idea is to have a set of goroutines, each with its own internal state, exchanging information with other goroutines by passing messages on Go’s channel. In this way, each goroutine. 

Channels -- Are one of the sync promitives in Go dervied from CSP. While they can be used to sync access of the memory, they are best used to communicate information between goroutines, 

### `select`statement

The `select`statement is the glue that binds channels together -- it’s how we are able to compose channels togehter in a program to form large abstractios -- A Go program with concurrency can find `select`binding together channels locally, within a single function or type. Fore:

```go
var c1, c2 <-chan interface{}
var c3 chan<- any
select {
case <-c1:
case <-c2:
case c3<-struct{}{}:
}
```

Just like a `switch`, a `select`block encompasses a series of `case`statements that guard a series of statements. Instead, all channel reads and writes are considered simultaneiously to see if any of them are ready -- populated or closed channel in the case of reads. like:

```go
func main() {
	start := time.Now()
	c := make(chan any)
	go func() {
		time.Sleep(5 * time.Second)
		close(c)
	}()
	select {
	case <-c:
		fmt.Printf("unblocking %v later. \n", time.Since(start))
	}
}
```

Note that in this code, don’t require a `select`statement, could simply write `<-c`. As can see, only unblock roughly 5s after entering the `select`block. Need to came up -- 

- What happens when multiple channels have sth to read
- What if there are never any channels that become ready
- What if we want to do sth but no channels are currently ready.

```go
c1 := make(chan any); close(c1)
c2 := make(chan any); close(c2)

var c1Count, c2Count int
for i:=1000; i>=0; i-- {
    select {
    case <-c1:
        c1Count++
    case <-c2:
        c2Count++
    }
}
```

Can see, for this, rougely half the time the `select`statement read from `c1`.. The Go runtime will perform a pseudo-random uniform selection voer the set of case statements. And what happens if there are never any channels that become ready -- if there is nothing useful U can do when all bloced, -- like:

```go
var c <-chan int
select {
    case <-c:
    case <-time.After(time.Second):
    ...
}
```

For this, the `time.After`takes a `time.Duration`argument and returns a channel that will send the current time after the duration U provide it. This leaves us the remaining question -- what happens when no channel is ready, and we need to do sth in the meantime -- like:

```go
start := time.Now()
var c1, c2 <-chan int
select {
case <-c1:
case <-c2:
default:
    fmt.Println(...)
}
```

Can see that it ran the `default`statement almost instantaneously. This allows U to exit a `select`block without blocking, usually see a `default`clause used in cnjunction with a for-select loop like:

```go
done := make(chan any)
go func() {
    time.Sleep(5*time.Second)
    close(done)
}()
workCounter := 0
loop:
for {
    select {
    case <-done:
        break loop
    default:
    }
    workCounter++
    time.Sleep(time.Second)
}
fmt.Println(...)
```

Achieved 5 cycles of work before signalled to stop. In this case, we have a loop that is doing some kind of work and occassionally checking whether it should stop -- Finally, there is a special case for empty `select`statements -- with no `case`clauses - look like -- `select{}`-- will simply block *forever*.

#### The `GOMAXPROCS`Lever

In the `runtime`package, there is a function called `GOMAXPROCS`-- in my opinion, the name is misleading -- people often think this function relates to the number of logical processors on the host machine.

### Concurrency Patterns in Go

Explored the fundamental of Go’s concurrency primitive and discussed how to properly use these primitives -- do a deep-dive into how to compose these primitives into patterns that will help keep your system scalable and maintainable.

#### Confinement

There are a couple of other options that are implicitly safe within multiple concurrent processes -- 

- Immutable data
- Data protected by confinement

A hoc confinement is when U achieve confinement through a convention -- whether it be set by the languages community, the group U work within, or the codebase U work within -- Stacking to convention is difficult to achieve on projects of any size unless U have tools to perform static analysis on your code every time someone commits some code -- there is an example of ad hoc confinement that demonstrates why -- 

```go
func main() {
	data := make([]int, 4)
	loopData := func(handleData chan<- int) {
		defer close(handleData)
		for i := range data {
			handleData <- data[i]
		}
	}

	handleData := make(chan int)
	go loopData(handleData)

	for num := range handleData {
		fmt.Println(num)
	}
}
```

Can see that the data `slice`of integers is available from both the `loopData`a function and the loop over the `handleData`channel -- by convention, we are only accessing it from the `loopData`function -- asi the code is touched by many people, and deadlines loom, And the confinement might break down and cause issues, a static-analyssis tool migth catch these kinds of issues, but static anaysis on a go suggests a level of maturity that not many teams acheive.

Lexical confinement involves using lexical scope to expose only the correct data and concurrency primitives for multiple concurrency processes to use.

```go
func main() {
	chanOwner := func() <-chan int {
		results := make(chan int, 5)
		go func() {
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

## The `r.Form`map

In the code, accessed the form via the `r.PostForm`map, but an alternative approach is to use the `r.Form`map -- the `r.PostForm`map is populated only for `POST, PATCH, PUT`-- and contains the form data from the request body.

In contrast, the `r.Form`map is populated for all requests -- and contains the form data any request body and any query string parameters. fore submit to `/snippet/create?foo=bar`-- could also get the value of the `foo`parameter by calling `r.Form.Get(“foo”)`, note that in the event of conflict, the request body value will take precedent over the query string parameter.

Using `r.Form`can be useful if your app sends data in a HTML form and in the URL -- or you hve an app that is agnostic about how parameters are passed. We expect our form data to be sent in the request body only, if it’s for sensible for us to access it via `r.Postform`.

#### The `FormValue`and `PostFormValue`methods

The `net/http`package also provides the methods `r.FormValue`and `r.PostFormValue`-- these are essentially shortcut functions that call `r.ParseForm()`for U, and then fetch the appropratie field value from `r.Form`and `r.PostForm`respectively.

Need to note recommend avoiding these shortcuts because they silently ignore query returned by `r.ParseForm`.

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    // first we call r.ParseForm() which adds any data in POST requst bodies to the 
    // r.PostForm map, this also works in the same way for PUT and PATCH requests 
    // and if there are any errors, use the app.ClientError() helper to send a 400
    err := r.ParseForm()
    if err != nil {
        app.ClientError(w, http.StatusBadRequest)
        return
    }
    
    // use the `r.PostForm.Get()` method to retreive the title and content
    // from the r.`PostForm` map
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    
    expires, err := strconv.Atoi(r.PostForm.Get("expires"))
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        app.serveError(w, err)
        return
    }
    http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOhter)
}
```

#### Multiple-value fields

Strictly spearking, the `r.PostForm.Get()`method that we’ve used above only returns the *first* value for a specific form field. This means U can’t use it with form fields which potentially send multiple values, such as a group of checkboxes -- like:

```html
<input type="checkbox" name="items" value="foo"> Foo
<input type="checkbox" name="items" value="bar">Bar
<input type="checkbox" name="items" value="baz"> Baz
```

In this case, you will need to work with the `r.PostForm`name directly, the underlying type of the `r.PostForm`map is `urlValues`-- which in turn has the underlying type `map[string][]string`-- so fields with multiple values can loop over the underlying map to access them like so:

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprintf(w, "%d, Item: %s\n", i, item)
}
```

#### Limiting form size -- 

Unless U are sending multipart data -- `enctype=“multipart/form-data”`-- then `POST, PUT, PATCH`request bodies are limited to 10MB, if this is exceeded then `r.ParseForm()`will return an error. If wan to change this limit can use the `http.MaxBytesReader()`function like so -- 

```go
r.Body = http.MaxBytesReader(w, r.Body, 4096)
err := r.ParseForm()
if err != nil {
    http.Error(w, "bad request", http.StatusBadRequest)
}
```

