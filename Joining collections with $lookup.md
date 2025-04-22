# Joining collections with `$lookup`

Sampling may assist you when developing queries against extensive collections, but in production queries, may sometimes need to write queries that are operating acorss multiple collections. In Mdb, these collection joins are done using the `$lookup`aggregation step -- like:

```js
db.getCollection('users').aggregate(
  [
    {
      $match: {
        $or: [
          { name: 'Catelyn Stark' },
          { name: 'Ned Stark' }
        ]
      }
    },
    {
      $lookup: {
        from: 'comments',
        localField: 'name',
        foreignField: 'name',
        as: 'comments'
      }
    },
    { $limit: 2 }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

First , runing a `$match`against the `users`collection to get only two users named .. once have these two records, we perform our lookup -- the 4 parameters of `$lookup`are as follow -- like:

- `from`-- The collection we are joining to our current aggregation, joining `comments`to `users`.
- `localField`-- the field name we are going to use to join our documents in the local collection.
- `foreignField`-- links to `localField`in the `from`collection.
- `as`-- how our new joined data will be labeled

For this, the lookup takes the name of our user, seaches the `comments`collection, and adds any comments with the same name into a new array field for the original user document. In this example the lookup takes the name of our users, search the `commetns`collection, and adds any comments with the same name into a new array field for the original user document. Can use the `$unwind`stage like:

```js
db.getCollection('users').aggregate(
  [
    {
      $match: {
        $or: [
          { name: 'Catelyn Stark' },
          { name: 'Ned Stark' }
        ]
      }
    },
    {
      $lookup: {
        from: 'comments',
        localField: 'name',
        foreignField: 'name',
        as: 'comments'
      }
    },
    { $unwind: '$comments' },
    { $limit: 3 }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

`$unwind`deconstructs an array field from an input document to output a new document for each element in the array.

#### Outputting your results with `$out`and `$merge`

We could run the query and export the results into a new format. This would mean re-importing results if we want to run subsequent analysis on the result set.

We could save the output in an array and then re-insert it into Mdb-- There are two new aggregation stages that solve the problem for us - `$out`and `$merge`-- both allow us to take the output from our pipeline and write into a collection for later use. NOTE -- *this while process takes place on the server*. like:

```js
// 2.6
{$out: 'myoutputCollection'}

// 4.2
{$merge: {into: 'myOutputCollection'}} // can accept db:<db>, coll: <coll> to merge into a different db
```

As can see, the syntax without any optional parameter is almost identical. For the `$out`-- the only parameter to specify is the desired output collection. Just using `$out`like;

```js
db.getCollection('movies').aggregate(
  [
    { $sort: { 'imdb.rating': -1 } },
    {
      $match: {
        genres: { $in: ['Romance'] },
        released: {
          $lte: ISODate(
            '2001-01-01T00:00:00.000Z'
          )
        }
      }
    },
    { $limit: 5 },
    {
      $project: {
        title: 1,
        genres: 1,
        released: 1,
        'imdb.rating': 1
      }
    },
      {$out: 'movie_top_romance'} // just the collection name
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

By running this pipeline, you will receive no output, cuz the output has been redriected to our desired collection.

#### Exercise -- listing the most-user commnted Movies

Using `$sampe`, and `$group`the comments by the movie for which they are targeted, `$sort`the result by the number of total comments, `$limit`the result to the top 5, then `$lookup`the movie that matches each document; then `$unwind`the movie array to keep the result documents simple; The `$project`just the movie title and title, then `$merge` the result into a new collection.

Before deciding on sample size, you should get a sense of how large the `comments`collection is -- run the `count`on the `comments`collection like: `db.comments.count()`, then Sample rougly 10% like `{$sample: {size; 5000}}`

Fill in the `$group`statement to group the comments by their associated film -- accumulating the totla number of comments for each film. Now that yo uhave the easier steps out of the way, fill in the `$group`statement to group the comments by their associated film -- accumulating the total number of comments for each:

```js
{
    $group: {
        _id : "movie_id",
        'sumComments': {$sum :1}
    }
}
// then sort like
{$sort: {'sumComments': -1}}
```

When build pipelines, it’s imporant to periodically run them partially completed to make sure you see the results you are expecting. For now will need to perform a look up. the whole just like:

```js
db.getCollection('comments').aggregate(
  [
    { $sample: { size: 5000 } },
    {
      $group: {
        _id: '$movie_id',
        sumComments: { $sum: 1 }
      }
    },
    { $sort: { sumComments: -1 } },
    { $limit: 5 },
    {
      $lookup: {
        from: 'movies',
        localField: '_id',
        foreignField: '_id',
        as: 'movie'
      }
    },
    { $unwind: '$movie' },
    {
      $project: {
        'movie.title': 1,
        'movie.imdb.rating': 1,
        sumComments: 1
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

So with the new phrases we have learned about in this topic, we new possess an excellent foundation for performing aggreggations on more massive, more complex datasets.

## Communication using message passing

Explore using Go’s channels to send and receive messages among our goroutines, this chapter will serve as introduction to programming concurrency using an abstraction that takes ideas from a formal language called CSP.

#### Passing messages

In Go, can open a channel between two or more goroutines and then program the goroutines to send and receive messages among themseleves. The advantage of using message passing is that greatly reduce the risk of causing race condition with our bad programming

Passing messages -- What would happen if a goroutine were to push a message on a channel without there being another goroutine to read that message -- Go’s channels are *sync* by default -- meaning that the sender will block until there is a receiver ready to consume the message -- Go’s channel are sync -- Can try this out by changing the receiver from the following -- 

```go
func receiver(message chan string) {
    time.Sleep(5*time.Second)
    fmt.Println("Receiver slept for 5s")
}

func main() {
    msgChannel := make(chan string)
    go receiver(msgChannel)
}
```

When run this -- the `main()`blocks for 5s, this cuz there is nothing to consume the message that the `main()`is trying to place on the channel. Since our `receiver()`terminates after 5s, no other goroutine is available to consume from the channel. And the same situation occurs if we have a receiver waiting for a message and no sender is available. Fore: Have a `sender`, rather than write message to the channel, the `main()`tries to consume a message from the same channel -- like:

```go
func main(){
    msgChannel := make(chan string)
    go sender(msgChannel)
    msg := <-msgChannel
    //...
}
```

When the `sender()`gorotuine terminates, go’s runtime outputs an error. A sender will block if there isn’t a goroutine consuming its message.

#### Buffering messages with channels

Although channels are sync, can configure them so that they store a number of messages before they block, When use a buffered channel, the sender goroutine will not block as along as there is a space available. Fore, when create a channel, can sepcify its buffer capacity, then whenever a sender writes a mesage, the channel store the message.

```go
func receiver1(message chan int, wGroup *sync.WaitGroup) {
	msg := 0
	for msg != -1 {
		time.Sleep(time.Second)
		msg = <-message
		fmt.Println("received:", msg)
	}
	wGroup.Done()
}
```

Then can use this channel to send 5 messages quickly, each containing the next number in the sequence from 1 to 6.

```go
func main() {
	msgChannel := make(chan int, 3)
	wGroup := sync.WaitGroup{}
	wGroup.Add(1)
	go receiver1(msgChannel, &wGroup)
	for i := 1; i <= 6; i++ {
		size := len(msgChannel)
		fmt.Printf("%s sending: %d. Buffer size: %d\n",
			time.Now().Format("15:04:05"), i, size)
		msgChannel <- i
	}
	msgChannel <- -1
	wGroup.Wait()
}
```

Will get a fast sender that is trying to send 6 messages.

#### Assigning a direction to channels

Go’s channels are bidirectional by default -- this means that a groutine can act as both a receiver and a sender of messages. However, assign a direction to a channel so that the goroutine using the channel can only send or receive messages. When decalre the channel as being `messages <- chan int`, receive -only. fore:

```go
func receiver(messages <-chan int) { // declare a receive-only channel
    for {
        msg := <-messages
        fmt.Println(...)
    }
}

func sender (messages chan<- int) {
    for i:=1; ;; i++ {
        fmt.Println(...)
        messages <- i
        //...
    }
}
```

#### Closing Channels -- 

Using a special value messages to sigal that no more data is available on the channel -- fore, the receiver is waiting for a -1 to appear on the channel -- 

DEF -- In software development -- a sentinel value is a predefined value that signals to an execution, a process, or an algorithm that it should terminate. 

Instead of using this *sentinel value* message -- Go allows us to close a channel, can do this in code by calling the `close(channel)`function --  Can show this by implementing a receiver that continually consumes messages even after we close the channel -- like:

```go
func receiver(messages <-chan int) {
    for {
        msg := <-messages
        fmt.Println(time.Now.Format("15:04:05"), "received", msg)
        time.Sleep(time.Second)
    }
}

func main() {
    msgChannel := make(chan int)
    go receiver(msgChannel)
    for i:=1; i<=3; i++ {
        fmt.Println(...)
        msgChannel <-i
        time.Sleep(time.Second)
    }
    close(msgChannel)
    //...
}
```

Using the default value is not ideal cuz the default value might be a valid value for our use case -- fore, a weather forecasting app sending temperature over a channel -- in this scenario, the receiver would think the channel has been closed whenver drops to 0.

Whenever we consume from a channel, an additional flag is returned -- telling us the status of the channel. This flag is set to `false`when the channel is closed: 

```go
func receiver(messages <-chan int) {
    for {
        msg, more := <-messags
        fmt.Println(...)
        if !more {
            return
        }
    }
}
```

However, can use a cleaner syntax to stop a receiver from reading on a closed channel, if want to read all the messages until close the channel, can use the following `for`like:

`for msg := range messages`

```go
func receiver(messages <-chan int) {
    for msg := range messages {
        fmt.Println(...)
        time.Sleep(time.Second)
    }
    fmt.Println("receiver finished")
}
```

#### Receiving function results with channels

```go
func findFactors(number int) []int {
	result := make([]int, 0)
	for i := 1; i <= number; i++ {
		if number%i == 0 {
			result = append(result, i)
		}
	}
	return result
}
```

if call the `findFactors()`twice for two different numbers -- would have two calls like:

```go
func main() {
	resultCh := make(chan []int)
	go func() {
		resultCh <- findFactors(3419110721)
	}()
	fmt.Println(findFactors(4033836233))
	fmt.Println(<-resultCh)
}
```

For this, use this anonymous goroutine to collect the result of the `findFactors()`function and write them on a channel. Can read those results from the channel -- if the first `findFactors()`call is not yet finished.

### NewAmount

An amount is decimal quantity of a cuncurrency -- as mentioned before, a decimal can be incompatible with a currency -- if its precision is too large -- fore instance, shouldn’t allow for the creation of an Amount of decimal. Building an object that is not valid makes no sense -- it is the role of the `New`function to return either sth valid or an error.

```go
const (
	// ErrTooPrecise is returned if the number is too precise for the currency
	ErrTooPrecise = Error("quantity is too precise")
)

// NewAmount returns an Amount of money
func NewAmount(quantity Decimal, currency Currency) (Amount, error) {
	if quantity.precision > currency.precision {
		return Amount{}, ErrTooPrecise
	}
	return Amount{quantity: quantity, currency: currency}, nil
}
```

The test should be quite straightfoward like:

```go
func TestNewAmount(t *testing.T) {
	tt := map[string]struct {
		quantity Decimal
		currency Currency
		want     Amount
		err      error
	}{
		"1.50 €": {
			quantity: Decimal{subunits: 150, precision: 2},
			currency: Currency{code: "EUR", precision: 2},
			want: Amount{
				quantity: Decimal{subunits: 150, precision: 2},
				currency: Currency{code: "EUR", precision: 2},
			},
		},
		"1.500 €": {
			quantity: Decimal{subunits: 1500, precision: 3},
			currency: Currency{code: "EUR", precision: 2},
			err:      ErrTooPrecise,
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			got, err := NewAmount(tc.quantity, tc.currency)
			if !errors.Is(err, tc.err) {
				t.Errorf("got %v, want %v", err, tc.err)
			}
			if !reflect.DeepEqual(got, tc.want) {
				t.Errorf("got %v, want %v", got, tc.want)
			}
		})
	}
}
```

#### Update the external test

Now the last step before writing actual conversion is to update the test of `Convert`. One option to avoid dealing with these errors would be to write a function that builds the required structures -- without checking anything, because U know that your test cases are valid -- in order to build them -- it needs to live in the `money`package and be exposed to the `money_test`package -- when what would prevent consumers from using the test utility function and send U invalid values -- The `testing.T`boject that we use for unit testing has a `Helper`function -- *Helpers* mark the calling function as a test helper function -- When printing file and line info, that function will be skipped -- it means that you will be able to see which test broke -- rather than this helper function’s line number.

This seemingly small detail has a significant impact on how test failures are reported. When test fails in Go the testing framework typically reports the file name and line number where the failure occurred. 

However, when extract common testing logic into separate helper functions, the reported file and line number will point to the line inside the helper function where `t.Error`or `t.Fatal`was called. This can make it harder to pinpoint the source of the failure in your test logic. When calling `defer t.Helper()`or simply `t.Helper()`at the beginning of your helper function. Signal to the Go testing framewok that the function is a helper. When a failure occurs within a function marked as a helper, the testing framework will *skip* that helper function in the stack trace and report the file and line number of the caller of the helper function.

```go
func mustParseCurrency(t *testing.T, code string) money.Currency {
	t.Helper()
	currency, err := money.ParseCurrency(code)
	if err != nil {
		t.Fatalf("cannot parse currency %s code", code)
	}
	return currency
}

func mustParseAmount(t *testing.T, value string, code string) money.Amount {
	t.Helper()
	n, err := money.ParseDecimal(value)
	if err != nil {
		t.Fatalf("cannot parse decimal %s", value)
	}
	currency, err := money.ParseCurrency(code)
	if err != nil {
		t.Fatalf("invalid currency code: %s", code)
	}
	amount, err := money.NewAmount(n, currency)
	if err != nil {
		t.Fatalf("Cannot create amount with value %v and currency code %s",
			value, code)
	}
	return amount
}
```

As can see using the `t.Fatal`-- which stops the test run immediately. Can now give actual values to the convert.

### Conflicting route patterns

It’s important to be aware that `httprouter`doesn’t allow *conflicting route pattern* which potentially match the same requeset -- so fore, you cannot register a route like `GET /foo/new`another route with a named parameter segement or catch-all parameter that conflicts with it -- like `GET /foo/:name`or `GET /foo/*name`

#### Restful routing

The first reason is that the `GET /snippets/:id`-- and `GET /snippets/new`routes *conflit* with each other - http requeset to `/snippets/new`potentially matches both routes as mentioned above, `httprouter`doesn’t allow conflicting route patterns -- it’s generally good practice to avoid them anyway cuz they are potential source of bugs.

Handling naming -- also like to emphasize that there is no right wrong way to name your handlers in Go.

Handler naming -- Also like to emphasize that there is no right or wrong way to name your handlers in Go.