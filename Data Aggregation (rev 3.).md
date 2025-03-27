# Data Aggregation (rev 3.)

Can now begin exploring and manipulating our data as we would with any other dbs -- also observed how, but fully leveraging the `find`command options -- can use operators to answer more specific question about our data. To find the correct data, would have to run two queries instead of one, joining the data on the client or applicaiton level.

The *aggregation pipeline* deos preciesely what the name implies, it allows you to define a series of stages that filter, merge, and organize data with much more control than the std `find`command.

### `aggregate`is the new `find`

The `aggregate`command in MDB is similar to the `find`command, can provide the criteria of ryour query in the form of JSON documents, and it outputs a cursor containing the search result - that is cuz s - Aggregations can become very large and complex - at their core, relatively simple - 

#### Syntax

The `aggregate`command operates on a collection like the other `CRUD`commands -- like:

```js
use smaple_mflix;
const pipeline= [];
const options = {}
let cursor = db.movies.aggregate(pipeline, options);
```

The `pipeline`parameter contains all the logic to find, sort, project, limit, transform, and aggregate our data. The `pipeline`parameter itself passed in as an array of JSON documents. can think of this a series of instructions to be sent to the dbs. And then the resulting data after the final stage is stored in a *cursor* to be returned to you. *Each steage in the pipeline is completed indepdnently*. The input to the first stage is the collection, and theinput into each such subsequent stage is the output from the previous stage.

And the `options`parameter -- is optional and allows U to specify the details of the configuration -- such as how the aggregation should exuecte or some flags that are required during debugging and building your pipelines.

Note that the parameter in an `aggregation`command are fewer than those in `find`command, will cover `options`as the final topic of this chapter, so -- can simply our command by excluding `options`completely. like:

```js
let cursor = db.movies.aggregate(pipeline);
const pipeline= [];
const cursor = db.movies.aggregate(pipeline);
cursor.next();
```

Can see this output once the pipeline is defined, we only need to call that function again to see the results of our aggreagation -- can call this function again and again without having to write the entire pipeline every time.

#### pipeline syntax

The syntax of an aggregation pipeline is very simple, much like the `aggregate`command itself, the pipeline is an array, with each item in the array being an object like:

```js
const pipeline = [
    {...}, {...}, ...
]
```

Each of the objects in the array represents a single stage in the overall pipeline, with the stages being executed in their array order -- each stage object takes the form of the following like: `{$stage: parameters}`. The stage represents the action we want to perform on the data and the parameters can be either a single value or another object, depending on the stage.

The pipeline can be passed in two ways -- either as saved variable or directly as a commnd. The following example:

```js
db.movies.aggregate([
    {$match: {'location.address.state': 'MN'}},
    {$project: {'location.address.city': 1}},
    {$sort: {'location.address.city': 1}},
    {$limit: 3},]
)
```

#### Creating Aggregations

Begin to explore the pipeline itself -- the following code, when pasted in the MDB shell -- like:

```js
const simpleFind = function() {
    print('Find result');
    db.theaters.find(
        {'location.address.state': 'MN'},
        {'location.address.city': 1}
    ).sort({'location.address.city': 1}).limit(3).forEach(print)
};
simpleFind();
```

Then just rebuild this command as an aggregation -- just like:

```js
db.theaters.aggregate([
    {$match: {'location.address.state': 'MN'}},
    {$project: {'location.address.city': 1}},
    {$sort: {'location.address.city': 1}},
    {$limit: 3},]
)
```

#### Performing simple Aggregations -- 

```js
const pipeline = [
    {$limit: 3},
    {$sort: {'imdb.rating': -1}},
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lte: new ISODate('2001-01-01')}
        }
    }
]
db.movies.aggregate(pipeline)
```

Then re-order the pipeline like:

```js
const pipeline = [
    {$sort: {'imdb.rating': -1}},
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lte: new ISODate('2001-01-01')}
        }
    },
    {$limit: 3},
]
db.movies.aggregate(pipeline)
```

## The STDLIB

The go Std lib is a set of core packages that enhance and extend the language. Fore, Go developers can write HTTP clients or servers, handle JSON data, or interact with SQL dbs.

### Privding a wrong time duration

The stdlib provides common functions and methods that accept a `time.Duration`-- `time.Duration`is an alias for the `int64`type -- newcomers to the language can get confused and provide wrong duration. Fore, developers with a Java or Js background are used to passing numeric types.

```go
ticker := time.NewTicker(1000)
for {
    select {
    case <-ticker.C: // do sth
    }
}
```

For this, ticks are not delivered every second, they are just delivered every microsecond -- Cuz `time.Duration`is based on the `int64`type and the code is corret since 1000 is a valid `int64`, but `time.Duration`represents the elapsed time between two instants in *nanoseconds* -- provide the `NewTicker()`function with a duration of 1000 ns. 

```go
ticker := time.NewTicker(time.Microsecond)
// or 
ticker := time.NewTicker(1000* time.Nanosecond)
```

#### `time.After`and memory Leaks

`time.After(time.Duration)`is just a convenient function that returns a channel and waits for a provided duration to elapse before sending a message to this channel. Consider the following example -- will implement a function that repeatedly consumers messages from a channel. We also want to a log a warning if we haven’t received any messages for more than 1 hour. like:

```go
func consumer(ch <-chan Event) {
    for {
        select {
        case event := <-ch:
            handle(event)
        case <-time.After(time.Hour):
            log.Println("warning: no messages received")
        }
    }
}
```

Use the `select`in two cases -- receiving a message fro m`ch`and after 1h without messages.