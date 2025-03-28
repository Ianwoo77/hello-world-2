# Performing Simple Aggregations

1. Translate your query into sequential stages that you can map to your aggregation stages -- limit to three movies, match only romance movies -- sort by IMDB rating -- and match only movies released before 2001.
2. Simplify your stages where possible by merging duplicate stages, in this case, you can mserge the two match stages: limit to 3 movies, sort by IMDB rating, and match romance movies released before 2001.

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

Then add the `$project`stage:

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
    {$project: {genres:1, released:1, 'imdb.rating': 1}}
]
db.movies.aggregate(pipeline)
```

#### Aggregation structure

Think of the pipeline as multi-tiered funnel -- starts broad at the top and becomes thinner as it approaches the bottom -- as you pour documents into the dop of the funnel -- there are many documents, but as you move futher down, this number keeps reducing at every stage.

```js
const pipeline = [
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lte: new ISODate('2001-01-01')}
        }
    },
    {$sort: {'imdb.rating': -1}},
    {$limit: 3},
    {$project: {genres:1, released:1, 'imdb.rating': 1}}
]
db.movies.aggregate(pipeline)
```

Another thing to consider is that, although U do have a list movies matching the criteria, want your result to be meaningful to your use case, in this case, you want your result to meaningful and useful to the movie company looking at this idea. It is likely that they wull care most about the movie title and rating.

Then add the movie `title`field to your projection stage, final aggregation should look like this -- 

```js
{$project: {title: 1, genres:1, released:1, 'imdb.rating': 1}}
```

### Manipulating Data

Most of our activities and examples an be just reduced to the following -- there is a document or documents in a collection that should return some or all documents in an easy-to-digest format -- At their core, the `find`command and aggregation pipeline are just about identifying and fetching the correct document -- the capability of the aggregation pipeline is much more robust and broader than that of the `find`command.

Using some of the more advanced stages and techniques in the pipeline allows us to transform our data, deriven new data, and generate insights across a broader scope.

#### The `Group`stage

The `$group`stage allows U to group documents based on a specific condition -- although there are many other stages and methods to accomplish various tasks with `aggregate`command, the `$group`stage serves as the *cornerstone* of the most powerful queries. Previously, the most significant unit of data we could return was a single document, can sort these documents to gain insight through a direct comparison of documents.

Fore, the most basic imp of a `$grourp`stage accepts only an `_id`key, with the value being an expression. This expression defines the critiera by which the pipeline groups document together -- this value becomes the `_id`of the newly outputted document with one document generated for each unique `_id`that the `$group`stage creates. FORE:

```js
const pipeline = [
    {$group: {_id:'$rated'}}
];
db.movies.aggregate(pipeline)
```

The first thing you may notice in our `$group`stage is the `$`notation before the `rated`fiedl -- Ad stated perviously, the value of the `_id`key was an *expression* -- in aggregation terms, an expression can be a literal, an expression object, an operator, or a field path, in this case, we are passing in a filed path, which tells the pipeline which field to access in the input documents. Cuz when aggregating, we need to tell pipeline that we want to access the field of the document that is currently aggregating -- the `$group`stage will interpret `_id: $rated`-- as equal to `_id: “$$CURRENT.reted”`-- it indicates for each document, it will fit into the group matching the same document with the `rated`key -- this will become clearer with the practice in the next -- 

Fore, the `$group`command can accept more than just one argument. It can also accept any number of additional arguments in the following like: `field: {accumumator: expression}`-- 

- `field`will define the key of the newly computed field for each group
- `accumulator`must be a supported accumulator operator -- these are group of operators, like other operators may have woked with already -- such as `$lte`-- except as the name suggests, they will accumulate their value across multiple documents belonging to the same group.
- `expression`in this context will be passed to the `accumulator`operator as the input of what field in each document it should be accumulating.

```js
const pipeline = [
    {$group: {_id:'$rated', 'numTitles': {$sum:1}}}
];
db.movies.aggregate(pipeline)
```

similarly, instead of accumulating 1 on each document, can accumulate the value of a *given field*, fore, say we want to find the total runtime of every single film in a rating, group the rating field and accumulate the runtime of each film.

```js
const pipeline = [
    {$group: {_id:'$rated', 'numTitles': {$sum:"$runtime"}}}
];
```

Although this is a simple example, can see that with just a single aggregation stage and two parameters -- can begin to transform our data in exciting ways.

And it’s important to note that we can use more than just accumulator operators as our expressions -- can also use several other useful operators to transform data after accumulating it. like:

```js
const pipeline = [
    {$group: {_id:'$rated', 'avgRuntime': {$avg:"$runtime"}}}
];
```

These average runtim values are not particularly useful in this case -- add another stage to project the runtime. 

```js
const pipeline = [
    {$group: {_id:'$rated', 'avgRuntime': {$avg:"$runtime"}}},
    {$project : {
        'roundedAvgRuntime': {$trunc: "$avgRuntime"}
        }}
];
```

And this section demonstrated how combining the group stage with operators, accumulators, and other stages can be manipulate our data to answer a much broader of business questions.

## `time.After`and memory leaks

`time.After`is a convenient function that returns a channel and waits for a provided duration to elapse before sending a message to this channel -- It’s used to concurrent code -- used for if don’t receive any message in this channel for 5s, I will ... But codebases often include calls to `time.After`in a loop -- fore, will implement a function that repeatedly consumes message from a channel, also want to log warning if we haven’t received any messages for more than 1h fore:

```go
func consumer(ch <-chan Event) {
    for {
        select {
        case event := <-ch:
            handle(event)
        case <-time.After(time.Hour):
            log.Println("warning: no message received")
        }
    }
}
```

`time.After`returns a channel, may expect this channel to be closed during each loop iteration, this isn’t the case. The resources created by `time.After`are released once the timeout expires and use memory until that happens, How much memory -- If receive a significant volume of messages -- 5 million per hour.

```go
func consumer (ch <-chan Event) {
    for{
        ctx, cancel := context.WithTimeout(context.Background(), time.Hour)
        select {
        case event := <-ch:
            cancel()
            handle(event)
        case <-ctx.Done():
            log.Println("Warning: no message received")
        }
    }
}
```

The downside of this approach is that we have to re-create a context during every single loop iteration -- creating a context isn’t the most lightweight operation in Go -- fore, it requires creating a channel -- 

The second option comes from the `time`package -- `time.NewTimer`-- This function creates a `time.Timer`struct that exports the following -- 

- A `C`field, which is the internal timer channel
- A `Reset(time.Duration)`method to reset the duration
- A `Stop()`method to stop the imter.

```go
func consumer (ch <-chan Event) {
    timerDuration := 1*time.Hour
    timer := timer.NewTimer(timerDuration)
    for {
        timer.Reset(timerDuration)
        select {
        case event := <-ch:
            handle(event)
        case <-timer.C:
            log.Println("warning: no messages recevied")
        }
    }
}
```

#### Unexpected behavior due to type embedding

Not being aware of the possible problems with type embedding -- looked at issues related to type embedding. In the context of JSON handling -- discuss another potential impact of type embedding that can lead unexpected marshaling/unmarshaling results.

```go
func (e Event) MarshalJSON() ([]byte, error) {
    return json.Marshal(
        struct {
            ID int
            Time time.Time
        }{
            ID: e.ID,
            Time: e.Time
        }
    )
}
```

## Unit testing and sub-tests

In this chapter we will create a unit test to make sure that our `humanDate()`function -- is ouputting `time.Time`values in the exact format that we want. If can’t remember, the `humanDate()`function looks like this -- 

```go
func humanDate(time.Time) string {
    return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

#### Creating a unit test

Jump straight and create a *unit test* for this function -- In Go, its standard practice to create your tests in `*_test.go`files which live directly alongside the code that you’re testing -- so, in this case, the first thing that we are going to do is create a new file to hold the test.

```go
func TestHumanDate(t *testing.T) {
	// Initialize a new time.Time object and pass it to the humanDate function
	tm := time.Date(2022, 3, 17, 10, 15, 0, 0, time.UTC)
	hd := humanDate(tm)
	if hd != "17 Mar 2022 at 10:15" {
		t.Errorf("got %q; want %q", hd, "17 Mar 2022 at 10:15")
	}
}
```

This pattern is the basic one that you will use for nearly all tests that you write in Go -- The important to take away are:

- The test is just regular Go code, which calls the `humanDate()`function and checks that the result matches what we expect
- Unit tests are contained in a normal Go function with the signature `func(*testing.T)`.
- To be valid unit test the name of this function *must* begin with the word `Test`-- typically this is then followed by the name of the function -- method or type that you are testing to help make it obvious at a glance what is being tested.
- Can use the `t.Errorf()`function to mark a test as *failed* and log a descriptive message about the failure. It’s important to note that calling `t.Errof()`doesn’t stop execution of your test -- after U call it Go will continue executing any remaining test code.

Save the file, then use the `go test`command to run all the tests in our `cmd/web`package like so: 

#### Table-driven tests

Now expand our `TestHumandDate()`function to cover some additional *test cases* -- specially, we are going to update it to aslo check tat -- 

1. If the input `humanDate()`is the zero time -- then it returns the emtpy string “”.
2. The output from the `humanDate()`function always uses the UTC time zone.

In Go, an idiomatic way to run multiple test cases is to use *table-driven* tests -- Essentially, the idea behind table-driven tests is to create a *table* of test cases containing the inputs and expected outputs -- and then loop over these, running each test case in a *sub-test* -- there are a few ways could set this up -- but a common appraoch is to define your test cases in an slice of anonymous structs.

```go
func TestHumanDate(t *testing.T) {
	tests := []struct {
		name string
		tm   time.Time
		want string
	}{
		{
			name: "UTC",
			tm:   time.Date(2002, 3, 17, 10, 15, 0, 0, time.UTC),
			want: "17 Mar 2022 at 10:15",
		},
		{
			name: "CET",
			tm:   time.Date(2022, 3, 17, 10, 15, 0, 0, time.FixedZone("CET", 1*60*60)),
			want: "17 Mar 2022 at 09:15",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hd := humanDate(tt.tm)
			if hd != tt.want {
				t.Errorf("got: %q; want: %q", hd, tt.want)
			}
		})
	}
}
```

