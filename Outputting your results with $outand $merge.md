# Outputting your results with `$out`and `$merge`

Imagine that have been woking on a large, multi-stage aggregation pipeline over the last week -- 

```js
// avaiable from v 2.6
{$out: "myOutputCollection"}
// avaiable form 4.2
{$merge:
	{
        // this can also accept {db: <db>, coll: <coll} to merge into a different db
        into: "myOutputCollection"
    }
}
```

`$out`is very simple, the only parameter to specify is the desried output collection -- it will either create a new collection or completely *replace* an existing collection.

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
    }
      {$out: 'movie_top_romance'}
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

By running this pipeline, will receive no output, this is cuz the output just has been redirected to our desired coll.

#### Listing the most user-commented movies

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
    },
      {$out: 'most_commented_movies'}
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

With the `out`stage, can store the result of our aggregations.

### Getting the most from your Aggregations

Can search large multi-collection datasets with given criteria, manipulate that data to create new insights, and output our results into a new or existing collection. These fundamentals will allow U to solve most of the problems. There are also several other stages and patterns for getting the most out of your aggregations.

#### Tuning your pipelines -- 

Each stage of the aggregation pipeline will perform some processing on the input, that means that the mosre significant the input, the larger the processing -- If U have designed your pipeline correctly, this processing is unavoidable for the documents you are trying to return.

The eaiest way to accomplish this is by adding or moving pipeline stages that filter out documents. Already done this in our previous sceaniros with `$match`and `$limit`. A common way to ensure this is to have the very first strage in your pipeline be a `$match`-- which matches only documents you need later in the pipeline. Fore:

```js
const pipeline = [
    {$sort: {'imdb.rating':-1}},
    {$match: {
        genres: {$in: ["Romance"]},
        released: {$lte: new ISODate("2001-01-01")}
    }},
    {$project: {title:1, genres:1, released: 1, 'imdb.rating': 1}},
    {$limit: 1}
]
```

Once U have correctly ordered the pipeline, it will look like the following --

```js
const pipeline = [
    {$match: {/*...*/}},
    {$sort: {}},
    {$limit:1},
    {$project}
]
```

logically, this cahnge means that the first thing we do is to get a list of all our elgible documents before sorting them, and then take the top 5 and project only those.

#### Use your Indexes

Indexes are another critical element in MDB query performance, For now all you need to remember when creating your aggregations is that when utilizing stages such as `$sort`and `$match`, you want to make sure that you are operating on *correctly indexed fields.*

#### Think aobut the desired Output

One of the most important ways to improve your pipelines is to plan and evaluate them to ensure that you are getting the desired output that sovles your business problem -- 

- output all the data to solve the problem
- output only the data required to sovle the problem
- Merge or remove any intermediate step.

### Aggregation options

Altering the pipelines is where U may spend most of your time while working with aggreagtions. `aggregate`command to configure its operation -- won’t delve -- the following is an example of aggregation with some of our options included like:

```js
const options= {
    maxTimeMS: 30000,
    allowDiskUse: true,
}
```

- `maxTimeMS`-- the amount of the time an operation may be processed before MDB kills it.
- `allowDiskUse`-- Stages in the aggregation pipeline may only use up a maximum amount of memory.
- `bypassDocumentValidation`-- Specifically for pipelines that will be writing out to collection using `$out`and `$merge`. If `true`, document validation will not occur on documents being written to the collection from this pipeline.
- `comment`-- this jus just for debugging and allows a string to be specified that helps identify this aggregation when parsing database logs.

Finding award-winning documentary movies -- 

```js
db.getCollection('movies').aggregate(
  [
    {
      $match: {
        'awards.wins': { $gte: 1 },
        genres: { $in: ['Documentary'] }
      }
    },
    { $sort: { 'awards.wins': -1 } },
    { $limit: 20 },
    {
      $project: { title: 1, genres: 1, awards: 1 }
    },
    { $limit: 3 }
  ],
  { maxTimeMS: 30000, allowDiskUse: true } // add this option
);
```

## Selecting Channels

So, how can we have one goroutine respond to messages coming from different goroutines over multiple channels -- Go’s `select`statement lets us specify multiple channel operations as separate cases and then execute a case depending on which channel is ready -- 

#### Reading from multiple channels

Don’t know on which channel the next message will be received. The `select`statement lets us *group* read operations on multiple channels together, blocking the goroutine until a message arrives on any one of the channels. Once a message arrives on any of the channels, the goroutine is unblocked, and a code handler for that channel is run. Fore, have a function that create an anonymous goroutine that periodically sends a message on a channel. The period is specified by the `seconds`input variable. Fore:

```go
func writeEvery(msg string, seconds time.Duration) <-chan string {
    messages := make(chan string)
    go func() {
        for {
            time.Sleep(seconds)
            messages <- msg
        }
    }()
    return messages
}
```

DEF -- Channels are just first-class objects, which means that we can store as variable, pass or return them from functions, or even send them on a channel. Like

```go
func main() {
    messagesFromA := writeEvery("Tick", time.Second)
    messagesFromB := writeEvery("Tock", 3*time.Second)
    
    for {
        select {
            case msg1 := <-messageFromA:
            print(msg1)
        case msg2 := <-messagesFromB:
            print(msg2)
        }
    }
}
```

#### Using select for non-blocking channel operations

Another use case for `select`is when need to use channels in a non-blocking manner. Fore, Go provides a non-blocking `tryLock()` For, can try to read a message from a channel, Then if no messages are available, instead of blocking, can have current execution work on a default set of instructions.

The `select`gives us the *default* case for exactly this scenario -- the instructions under the default case will be executed if none of the other cases is available. Try to access one or more channels.

```go
func sendMsgAfter2(seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		time.Sleep(seconds)
		messages <- "Hello"
	}()
	return messages
}
func main() {
	messages := sendMsgAfter2(3 * time.Second)
	for {
		select {
		case msg := <-messages:
			fmt.Println("Message received", msg)
			return
		default:
			fmt.Println("no messages waiting")
			time.Sleep(time.Second)
		}
	}
}
```

Since we have the `select`in a loop, the default case will be executed over and over again until we receive a message.

#### Performing concurrent computations on default case

A useful scenario is to use the default select case for concurrent computations and when use a channel to signal when we need to stop -- to illustate -- fore discover a forgotten pwd by brute force.

```go
const (
	passwordToUse = "go far"
	alphabet      = " abcdefghijklmnopqrstuvwxyz"
)

func toBase27(n int) string {
	result := ""
	for n > 0 {
		result = string(alphabet[n%27]) + result
		n /= 27
	}
	return result
}
```

For this if had to use a brute force approach in a sequential program, would just create a loop enumerating all strings. To find the pwd faster, can divide the range of our guesses among several goroutines -- And to avoid unncessary computations, want to stop the execution of each goroutine when any goroutine makes a correct guress. Can use a channel to notify all other goroutines when one execution discovers the pwd -- 

One solution is to perform the necessary computation in the `select`'s `default`case and then have another case waiting on the common channel.

```go
func guessPassword(from int, upto int, stop chan struct{}, result chan string) {
	for guessN := from; guessN < upto; guessN++ {
		select {
		case <-stop:
			fmt.Printf("Stopped at %d [%d,%d]\n", guessN, from, upto)
			return
		default:
			if toBase27(guessN) == passwordToUse {
				result <- toBase27(guessN)
                	// close the channel so that other goroutines stop checking the pwd
				close(stop)
				return
			}
		}
	}
	fmt.Printf("Not found between [%d,%d]\n", from, upto)
}
```

In the main():

```go
func main() {
	finished := make(chan struct{})
	passwordToFound := make(chan string)

	for i := 1; i <= 387420488; i += 10000000 {
		go guessPassword(i, i+10000000, finished, passwordToFound)
	}
	fmt.Println("password found:", <-passwordToFound)
	close(passwordToFound)
}
```

After starting up all goroutines, the `main()`function waits for an output message on the `passwordFound`channel.

#### Timing out on channels

Another useful scenario is blocking for only a specificed amount of time - -waiting for an operation on a channel -- Just like in the previous two exampls, -- want to check to see whether a message has arrieved on a channel, but want to wait for a few seconds to see if a message arrives, instead of unblocking immediately and doing sth else. This is just useful in many situations when channel operations are time sensitive.

Can implement this behavior by using a separate goroutine that sends a message on an extra channel after a specified timeout, can use this extra channel in our `select`statement. The `time.Timer`type in Go provides us with this functionality -- don’t have to implement our own timer goroutine -- Can create one of thse timer by calling `time.After(duration)`-- will return a channel on which a mesage is sent after the duration time elapses.

```go
func main() {
	messages := sendMsgAfter2(3 * time.Second)
	timeoutDuration := time.Duration(10) * time.Second
	fmt.Printf("Waiting for messags for %d seconds\n", 10)
	select {
	case msg := <-messages:
		fmt.Println("Message received", msg)
	case <-time.After(timeoutDuration):
		fmt.Println("Timed out waiting for message")
	}
}
```

For this, accepts a timeout value as a program argument, we use this timeout to warit for a message to arrive on the `message`channel.

#### Writing to channels with `select`

Can also use the `select`statement when we need to write messages to channels, not just when we are reading messages from channels. `Select`statements can combine read or write blocking channel operations together, selecting the case that unblocks first. 

Fore, have to com up with 100 random prime -- Could pick a random number from a bag with a large set of numbers and then keep that number only if it is prime.

In programming, can have a primes filter that -- given a stream of random numbers, picks out any prime number it finds and outputs it on another stream. Fore, the `primesOnly()`function does exactly this -- accepts a channel with input numbers and filters for prime numbers -- 

```go
func primesOnly(inputs <-chan int) <-chan int {
    results := make(chan int)
    go func() {
        for c:= range inputs {
            isPrime := c!=1
            for i:=2; i<=int(math.Sqrt(float64(c))); i++ {
                if c%i == 0 {
                    isPrime= false
                    break
                }
            }
            if isPrime {
                result <- c
            }
        }
    }()
    return results
}
```

Our goroutine outputs just a subset of the numbers it receives on the input channel.  The goroutine receives a non-prime number that is thrown away. How can feed in a stream of random numbers while reading the primes returned on another channel in one goroutine -- the answer is to use a `select`case to both feed the random numbers and read the primes.

```go
func main() {
	numbersChannel := make(chan int)
	primes := primesOnly(numbersChannel)
	for i := 0; i < 100; {
		select {
		case numbersChannel <- rand.Intn(10000000) + 1:
		case p := <-primes:
			fmt.Println("found prime", p)
			i++
		}
	}
}
```

### Conversion logic

We are just happy with the API of this package, and the objects that have in hand are guaranteed valid and supported, now have it really convert the mony -- for the first version -- until have actually run the tool will hardcode an exchange rate -- 

#### Applying the change rate

This logic could belong to the `Amount`structure -- It would know how to create a new `Amount`with a new value. And, amounts should be imutable and we need to make sure that the input amount is not modified by the operation.

Implement `applyExchangeRate`-- Don’t want to use `float64`for this piece of the logic -- it’s the most sensitive and want to ensure we exact maths, without losing any precision on the values we handle.

```go
func pow10(power byte) int64 {
	switch power {
	case 0:
		return 1
	case 1:
		return 10
	case 2:
		return 100
	case 3:
		return 1000
	default:
		return int64(math.Pow(10, float64(power)))
	}
}
// in the Amount:
// validate returns an error if and only if an Amount is unsafe to use
func (a Amount) validate() error {
	switch {
	case a.quantity.subunits > maxDecimal:
		return ErrorTooLarge
	case a.quantity.precision > a.currency.precision:
		return ErrTooPrecise
	}
	return nil
}

// Convert applies the change rate to convert an amount to a target currency
func Convert(amount Amount, to Currency) (Amount, error) {
	// convert to the target currency applying the fetched change rate
	convertedValue := applyExchangeRate(amount, to, ExchangeRate{
		subunits:  2,
		precision: 0,
	})
	// validate the converted amount is in the handled bounded range
	if err := convertedValue.validate(); err != nil {
		return Amount{}, err
	}
	return convertedValue, nil
}

// ExchangeRate represents a rate to covert from a currency to another
type ExchangeRate Decimal

// applyExchangeRate returns a new Amount representing the input
// multiplied by the rate
func applyExchangeRate(a Amount, target Currency, rate ExchangeRate) Amount {
	// multiply the input amount
	converted := multiply(a.quantity, rate)

	// adjust precision
	switch {
	case converted.precision > target.precision:
		// the converted value is too precise
		converted.subunits = converted.subunits / pow10(converted.precision-target.precision)
	case converted.precision < target.precision:
		converted.subunits = converted.subunits * pow10(target.precision-converted.precision)
	}
	converted.precision = target.precision
	return Amount{
		currency: target,
		quantity: converted,
	}
}

// multiply a Decimal with an ExchangeRate and return the product
func multiply(d Decimal, r ExchangeRate) Decimal {
	return Decimal{
		subunits:  d.subunits * r.subunits,
		precision: d.precision + r.precision,
	}
}
```

#### Most importantly -- testing it

This is the heart of the logic, requires a lot of testing into make sure that everyting works fine and keeps working fine if we ever decide to change any imp -- like:

```go
func TestApplyExchangeRate(t *testing.T) {
	t.Parallel()

	tt := map[string]struct {
		in             Amount
		rate           ExchangeRate
		targetCurrency Currency
		expected       Amount
	}{
		"Amount(1.52) * rate(1)": {
			in: Amount{
				quantity: Decimal{
					subunits:  152,
					precision: 2,
				},
				currency: Currency{code: "TST", precision: 2},
			},
			rate:           ExchangeRate{subunits: 1, precision: 0},
			targetCurrency: Currency{code: "TRG", precision: 4},
			expected: Amount{
				quantity: Decimal{
					subunits:  15200,
					precision: 4,
				},
				currency: Currency{code: "TRG", precision: 4},
			},
		},
		"Amount(2.50) * rate(4)": {
			in: Amount{
				quantity: Decimal{
					subunits:  250,
					precision: 2,
				}},
			rate:           ExchangeRate{subunits: 4, precision: 0},
			targetCurrency: Currency{code: "TRG", precision: 2},
			expected: Amount{
				quantity: Decimal{
					subunits:  1000,
					precision: 2,
				},
				currency: Currency{code: "TRG", precision: 2},
			},
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			got := applyExchangeRate(tc.in, tc.targetCurrency, tc.rate)
			if !reflect.DeepEqual(got, tc.expected) {
				t.Errorf("got: %v; want: %v", got, tc.expected)
			}
		})
	}
}
```

