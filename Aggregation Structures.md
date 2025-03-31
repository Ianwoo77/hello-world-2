# Aggregation Structures

Think of the pipeline as a multi-tiered funnel -- it starts broad at the top and becomes thinner as it approaches the bottom -- As you pour documents into the top of the funnel, there are many documents, but as you move further down, this number keeps reducing at every stage, until only the documents that you want to output exit the bottom.

In this pipeline, will sort all the documents in the collection, and *discard* the ones that don’t match. Fore, are currently sorting documents you don’t need, swap those stages around like :

```js
const pipeline = [
    {
        $match: {
            genres: {$in: ['Romance']},
            released: {$lte: new ISODate('2000-01-01')}
        }
    },
    {$sort: {'imdb.rating': -1}},
    {$limit: 3},
    {$project: {genres: 1, released: 1, 'imdb.rating': 1}}
];

db.movies.aggregate(pipeline);
```

Add the movie `title`field to your projection stage -- final aggreation should look like this :

`{$project: {title:1,genres: 1, released: 1, 'imdb.rating': 1}}`

### Manipulating Data

Most of our activities and example can be reduced to the following -- there is a document or documents in a collection that should return some or all the documents in an easy-to-digest format -- at their core, the `find`command and aggregation pipeline are just about identifying and fetching the correct document -- the capability of the aggreation pipeline is much more robust and broader than that of the `find`command.

#### The `group`stage

The `$group`stage allows U to group documents based on a specific condition -- there are many other stages and methods to accomplish various tasks with the `aggregate`command, the `$group`serves as the cornerstone of the most powerful queries. Once master the `$group`stage, will be able to increase the scope of our queries to an entire collection by aggreating your documents into large logical units.

The most basic is `$group`accepts only an `_id`key, with the value being expression. This value becomes the `_id`of the newly outputted document with one document generated for each unique `_id`that the `$group`stage creates.

```js
const pipeline = [
    {$group: {_id: "$rated"}}
];
db.movies.aggregate(pipeline)
```

The first thing you may notice in the `$group`is the `$`notation before the `rated`field -- as -- the value of our `_id`key was an expression -- in aggregation terms, -- an expression can be literal, an expression object, an operator, or a filed path. May be wondering why can’t just pass the field name as we would in a find command -- this is cuz when aggregating -- need to tell the pipeline that we want to access the field of the document that is currently aggregating -- the `$group`will interpret `_id: “$rated”`-- as equivalent to . -- `$$CURRENT.reated`

#### Accumulator Expressions

The `$group`command can accept more than jsut one argument -- it can also accept any number of additional arguments in the following format -- like: `{field: accumulator: expression}`

- `field`will define the key of our newly computed field for *each group*
- `accumulator`-- must be a *supported* accumulator operator, these are a group of operators, like other operators, may have worked with already -- fore `$lte`
- `expression`-- will be passed to the `accumulator`operator as the intput of what field in each document it should be accumulating like:

```js
const pipeline = [
    {$group: {_id:"$rated", 'numTitles': {$sum:1}}}
]
db.movies.aggregate(pipeline)
```

Can see from this that can create a new field called `numTitles`with the value of this field for each group being the sume of the documents -- these newly created field are often referred as *computed fields*.

For the `{$sum:1}`-- this is an accumulator operator, for each document that belones to particular group -- `$sum:1`operator will increment the `numTitles`counter by 1. It counts the number of documents in each group.

Similarly, instead of accumulating 1 on each document, can accumulate the value of a given field, fore, say we want to find the total runtime of every single film in a rating. We group by the `rating`field and accumulate the runtime of each film -- 

```js
const pipeline = [
    {$group: {_id:"$rated", 'numTitles': {$sum:"$runtime"}}}
]
```

Must prefix the runtime field wtih the `$`symbol to tell Mdb we are referring to the runtime value of each document we are accumulating -- new result is as follows -- Instead of simply counting the number of documents in each group, will sum the values of the `runtime`field for all documents within each group -- the `$`prefix before `runtime`indicates that it’s a field in the input documents.

`db.movies.aggregeate(pipeline)`-- this command wen executed on the `movies`collection, will run this modified aggregation pipeline. Can see that with just a single aggreation stage and two parameters, can begin to transform our data in exciting ways -- serverl accumulator operators can be combined and layered to generate much more complex and insightful info about groups.

```js
const pipeline = [
    {$group: {_id:"$rated", 'avgRuntime': {$avg:"$runtime"}}},
    {$project: {
        'roundedAvgRuntime': {$trunc: "$avgRuntime"}
        }}
]
db.movies.aggregate(pipeline)
```

## `time.After`and Memory leaks

`time.After`is a convenient function that returns a channel and waits for a provided duration to elapse before sending a message to this channel -- used in concurrent code -- if want to sleep for a given duration, can use the `time.Sleep(time.Duration)`-- the advantage of `time.after`is that it can be used to implement scenarios such as -- code bases often include calls to `time.After`in a loop -- may a root cause of memory leaks.

```go
func consumer(ch <-chan Event) {
    for {
        select {
        case event := <-ch:
            handle(event)
        // this creates a timer.
        case <-time.After(time.Hour):
            log.Println("...")
        }
    }
}
```

This may lead to memory usage issues -- `time.After`returns a channel -- may expect this channel to be closed during each loop iteration -- this isn’t the case. The resources created by `time.After`are released once the timeout expires and use memory until that happens -- how much -- in Go 200bytes. If we receive a significant volume of messages, such as 5m per hour, our app will consume 1GB of memory to store the `time.After`resources.

In each iteration of the `for`loop where no event is received for an hour, a new `time.After`timer is created, the prevous timer -- didn’t trigger cuz an event arrived earlier, is still alive in the background, waiting to potentially fire after one-hour duration.

For this, if events keep arriving on the `ch`channel before the `time.After`timer expire, these timers will accumulate over time -- each unexpried timer holds onto resources until it fires or the program terminates.  Fix this issue by closing the channel programmatically during each iteration -- 

```go
func consumer(ch <-chan Event) {
    for {
        ctx, cancel := context.WithTimeout(context.Background(), time.Hour)
        select {
        case event := <-ch:
            cancel()
            handle(event)
        case <-ctx.Done():
            log.Println("warning:...")
        }
    }
}
```

And the downside of this approach is that we have to re-create *context* during every single loop iteration.

The second option comes from the `time`package `time.NewTimer`-- this function creates a `time.Timer`struct that exposes the following -- 

- A `C`field, which is the internal timer channel
- A `Reset(time.Duration)`method to reset the duration
- A `Stop()`method to stop the timer

##### `time.After`internal

Should note that `time.After`also relies on the `time.Timer`-- it only returns the `C`field, just like:

```go
package time

func After(d Duration) <-chan Time {
    return NewTimer(d).C
}
```

Then implement a new version using `time.NewTimer`-- like:

```go
func consumer(ch <-chan Event) {
    timeDuration := 1*time.Hour
    timer := time.NewTimer(timeDuration) // not be created new every loop
    for {
        timer.Reset(timeDuration) // reset the duration every loop
        select {
        case event := <-ch:
            handle(event)
        case <-timer.C:
            log.Println("warning...")
        }
    }
}
```

In this imp, keep a recurring action during each loop iteration -- calling the `Reset()`method -- calling `Reset`is less cumbersome than having to create a new context every time -- faster and puts less pressure on the garbage collector cuz it doesn’t require any new heap allocation.

And using the `time.After`in a loop isn’t the only case that may lead to peak in memory consumption.

### Update the test

Now are not forced to check the std output anymore, can just write the `Test***`function -- one that will test all of the logging methods together, sequentially -- can have one test case per required logging level and check that the outputs are different and the `Debugf()`call is mostly ignored.

```go
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

// testWriter is a struct that implements the io.Writer
// use it to validate that we can write to a specific output
type testWriter struct {
    contents string
}

// write imp the io.Writer interface
func(tw *testWriter) Write(p []byte) (n int, err error) {
    tw.contents = tw.contents+ string(p)
    return len(p), nil
}
```

### Gordle -- play a word game in your terminal

Just guess a word of 5 characters in 6 attempts -- The default approach to any coding exercise is always to simplify the problem to its absolute simplest version -- have time to improve it later. Start with a basic version of the main function that will have a hardcoded solution -- allow only one guess -- 

Know that this program will need more than 50 lines of code, so it’s just a good idea to split responsibilities over several files -- anything that relates to the game will be in the `grodle`package --  And there are several ways to create an object -- expose a `New()`method -- which will be the recommended entry point into the library, guaranteeing the creation of the `Game`object with all its dependencies -- By convention, `New()`will return a pointer on `Game`-- 

```go
type Game struct{}

// New returns a Game, which can be used to play
func New() *Game {
	g := &Game{}
	return g
}

func (g *Game) Play() {
	fmt.Println("welcome to Grodle!")
	fmt.Printf("Enter a guess\n")
}

func main() {
	g := gordle.New()
	g.Play()
}
```

#### Read player’s input

Thins this is a game -- There are several ways of reading from the std input, depending mostly on what we want to read-- some functions read a slice of bytes, and some read strings -- in this case, the player will type characters and then press the Return -- therefore, want to read a line until we hit the first end of the line character like:

And the `bufio`package has a useful method to acheive this on its `Reader`structure -- `ReadLine`tries to return a single line, not including the end-of-line bytes. The good thing is that the `bufio.Reader`implements the `io.Reader`interface -- 