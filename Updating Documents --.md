# Updating Documents -- 

Can make modifications with various update methods -- These methods include `updateOne()`, `updateMany()`and `replaceOne()`.. And if `upsert:true`is specified and no document matches the filter, `updateOne()`or `updateMany()`creates a new document using the filter criteria and the specificied update modifications. And Tip -- to avoid multiple upserts, make sure that the filter field(s) are just uniquely indexed.

U can use `$set`operator update the field from someone to someone. the `$inc`operator increments the `stops`field from 0 to 1 fore:

```js
db.routes.updateOne(
    {
        'airline.id': 411,
        'src_airport': 'LHR',
        'dst_airport': 'SFO',
        'airplane': 747,
    },
    {$set: {'airplane': 'A380'}}
)
```

The document uses an `updateOne()`with a specific filter to locate the document that needs updating in the mongodb routes collection. Also note that the `updateOne`method in Mdb arbitrarily updates one of the matching documents if multiple documents fit the query critiera, and no specific sot order is applied. And the `$set`allows U to modify the values of any field in a document excepti `_id`.

Another useful operator is `$inc`-- just like:

```js
db.routes.updateOne(
    {
        'airline.id': 413,
        'src_airport': 'DFW',
        'dst_airport': 'LAX',
        'stops': 0
    },
    {$inc: {'stops': 1}}
)
```

Also note when choose beteen `$inc`and `$set`-- select `$inc`for numeric to benefit from its  fast and low-overhead operations. And the `$inc`operator modifies the value of an existing key or *creates* new one if the key does not exist.

- `$currentDate`-- Sets field to the current date as a `Date`or `Timestamp`
- `$rename`-- renames a field
- `$unset`-- Removes the specified field from a document.

#### Updating many documents

Modifies all documents in a collection that meet the specified filter critiera, applying the provided update rules, And the `updateMany()`can be particularly useful for bulk updates across multiple documents. And to ensure the smooth execution of the `updateMany()`operation in the production, thoroughly validate the filter beforehand.

#### Updating arrays -- 

MongoDB provides a variety of array operators that are extensive and powerful for manipulating documents that contain array fields. These operators enable functionalities such as adding elements to an existing array, removing elements from an array, modifying existing elements, and creating a new array. For these, U can use mdb’s `$push`operator to add the prices dynamically.

##### Adding elements to an array

```js
db.routes.updateOne(
    {
        'airline.id': 413,
        'src_airport': 'DFW',
        'dst_airport': 'LAX'
    },
    {
        $push: {
            'prices': {
                class: 'business',
                price: 2500
            }
        }
    }
)
```

This operation adds the price for the business class to the `prices`array for the specified flight, if the `prices`arrray doesn’t exist, Mdb just creates it.

And if want to add more prices for other classes or update eixsting prices, can use the `$push`combined with the `$each`*modifier* to append multiple values to an array field at the same time.

```js
db.routes.updateOne(
    {
        'airline.id': 413,
        'src_airport': 'DFW',
        'dst_airport': 'LAX'
    },
    {
        $push: {
            'prices': {
                $each: [
                    {
                        class: 'economy',
                        price: 800
                    },
                    {
                        class: 'first',
                        price: 2000
                    }
                ]
            }
        }
    }
)
```

This comand appends each of the specificed price entries to the `prices`array for the specified document, efficiently adding multiple prices for different classes in one operation.

Note can also use the `$push`with the `$each`, `$sort`, `$slice`modifiers if U want to add new classes such as .. to the prices array in a Mdb document -- just like:

```js
db.routes.updateOne(
    {
        'airline.id': 413,
        'src_airport': 'DFW',
        'dst_airport': 'LAX'
    },
    {
        $push: {
            'prices': {
                $each: [
                    {
                        class: 'premium economy',
                        price: 1100
                    },
                    {
                        class: 'luxury',
                        price: 3000
                    }
                ],
                $sort: {price: 1}, // sorts the prices in ascending order
                $slice: -3 // keep just last 3 highest price ?entries
            }
        }
    }
)
```

And the following listing shows the content of the document after the update.

```json
{
  "_id": {
    "$oid": "6900070cef732135054652e5"
  },
  // ...
  "prices": [
    {
      "class": "first",
      "price": 2000
    },
    {
      "class": "business",
      "price": 2500
    },
    {
      "class": "luxury",
      "price": 3000
    }
  ]
}
```

The result confirms that the document has been successfully modified to include the new classes and prices. Can also use `$addToSet`-- to ensure unique entires in an array field in Mdb and prevent duplicates in the array like:

```js
db.routes.updateOne(
    {
        'airline.id': 413,
        'src_airport': 'DFW',
        'dst_airport': 'LAX'
    },
    {
        $addToSet :{
            'prices': {
                class: 'economy plus',
                price: 1200
            }
        }
    }
)
```

The `$addToSet`operator attempts to add a new object with class and price to the prices array of the specified document. This object is added only if an identifcal object doesn’t already exist in the array.

## using `nil`channels

Note that one problem is that the `close(ch)`statement is unreachable -- looping over a channel using the `range`breaks when the channel is just closed. To check whether we receive a message or a closure signal, we must do it this way like:

```go
ch1 := make(chan int)
close(ch1)
v, open := <-ch1
v, open // 0 false
```

Fore, in the exmaple like:

```go
go func() {
    for {
        select {          
           case v := <-ch1:
                ch <- v
           case v := <-ch2:
                ch <- v
               }
    }
    close(ch)
}()
```

Cuz the `select`case is `case v:= <-ch1`, will keep entering this case and publising a zero integer to the merged channel. So just need -- 

```go
func merge(ch1, ch2 <- chan int) <-chan int {
    ch := make(chan int, 1)
    ch1Closed := false
    ch2Closed := false
    go func() {
        for {
            select {
            case v, open := <-ch1:
                if !open {
                    ch1Closed=true
                    break
                }
                ch <-v
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

It’s the right time to come back to `nil`channels -- just like:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for ch1!= nil || ch2 != nil {
            select {
            case v, open:= <-ch1:
                if !open {
                    ch1= nil
                    break
                }
                ch <-v
            case v, open:= <-ch2:
                if !open {
                    ch2 = nil
                    break
                }
                ch <-v
            }
        }
        close(ch)
    }()
    return ch
}
```

First, we loop as long as at least one channel is still open. Then, fore, if `ch1`is closed,  assign `ch1`to `nil`, hence, during the next loop iteration, the `select`statement will only wait for two conditions -- 

- `ch2`has a new message
- `ch2`is closed

For this, `ch1`is no longer part of the equation as it’s a `nil`channel -- meanwhile, keep the same logic for `ch2`and assign it to `nil`after it’s closed.

### Channel Buffer

A channel buffer’s appropriate size is highly *context-dependent* and there is no single optimal value. The primary factors driving the size decision are the producer/consumer speed ratio and the latency tolerance of your app.

- An unbuffered channel enables sync, have the guarantee that two goroutines will be in a known state, one receiving and another sending a message
- A buffered channel doesn’t provide any strong sync -- indeed, a producer goroutine can send a message and then continue its execution if the channel isn’t full.

Both channel types enable communication, but only one provides sync, if we need sync, we must use unbuffered channels, unbuffered channels may also be easer to readon about.

There are other cases where unbuffered channels are prefearable, fore, in the case of a notification channel where the notification is handled via a channel closure -- `close(ch)`, here using a buffered channel wouldn’t bring any benefits.

### Data races with `append`

Fore in the following example, will initialize a slice and create two goroutines that will use `append`to create a new slice with an additional element -- 

```go
s := make([]int, 1)

go func() {
    s1 := append(s, 1)
    fmt.Println(s1)
}()

go func() {
    s2 := append(s, 1)
    fmt.Println(s2)
}()
```

A slice is backed by an array and has two properties, `LEN`and `CAP`-- the Length is the number of available elements in the slice, whereas the cap is the total number of elements in the backing array. When we use `append`, the behavior dependson whether the slice is full `len=cap`-- if it is, the Go runtime creates a new backing array to add the new element -- the runtime adds it to the existing backing array.

Fore, create `s := make([]int, 1)`-- The code creates a 1L and 1C slice, thus, cuz the slice is full, using `append`in each goroutine returns a slice backed by a new array. For this situation, it doesn’t mutate existing array, hence, it doesn’t lead to a data race. 

Run the sample with slight change -- `s := make([]int, 0, 1)`-- 0L and 1C. This creates a data race -- cuz the array isn’t full -- both goroutines attempt to update the same index of the backing array, which is a data race. So how can we prevent the data race if want both goroutines to work on a slice containing the initial elements of a plus an extra element -- one solution is to create a copy.

```go
s := make([]int, 0, 1)
go func() {
    sCopy := make([]int, len(s), cap(s))
    copy(sCopy, s)
    s1 := append(sCopy, 1)
    fmt.Println(s1)
}()
// ...
```

### With slices and maps

Fore, implement a `Cache`struct used to handle caching for custom balances -- this struct will contain a map of balances per custom ID and a mutex to protect concurrent accesses - like:

```go
type Cache struct {
    mu sync.RWMutex
    balances map[string]float64
}
```

If add a method -- 

```go
func (c *Cache) AddBalance(id string, balance float64) {
    c.mul.Lock()
    c.balances[id]=balance
    c.mu.Unlock()
}
```

And implement a method -- 

```go
func (c *Cache) AverageBlanace() float64 {
    c.mu.RLock()
    balances := c.balances // create a copy
    c.mu.RUnlock()
    
    sum := 0
    for _, balance := range balances {
        sum += balance
    }
    return sum / float64(len(balances))
}
```

For this, data race occurs -- internally, a map is a `runtime.hmap`struct containing mostly metadata and a pointer referencing data buckets. So the `balances:= c.balances`doesn’t copy the actual data, it’s just the same principle with a slice. For this example, assigned to `balances`a new *name* -- meanwhile, the two goorutines perform operations on the just same data set, and one of them mutates it -- hence it’s a data race.

If the operation isn’t heavy -- 

```go
func (c *Cache) AverageBalance() flaot64 {
    c.mu.RLock()
    defer c.mu.RUnlock()
    //...
}
```

Type: `sync.RWMutex`-- allows multiple readers or one writer -- useful for read-heady workloads. Fore:

```go
var rw sync.RWMutex
rw.RLock()
// read-only section
rw.Runlock()
```

- Multiple goroutines can hold `RLock()`simultaneously
- if calls `Lock()`-- blocks until all `RLock()`are released.
- and wile `Lock()`held,no other `RLock()`or `Lock()`can proceed.

namely:

| Feature           | Lock() (Write Lock)                                          | RLock() (Read Lock)                                          |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| provided by       | `sync.Mutex` and `sync.RWMutex`                              | **Only** `sync.RWMutex`                                      |
| purpuse           | Used when **modifying** a shared resource (Write).           | Used when **only reading** a shared resource (Read).         |
| exclusivity       | **Exclusive**. Only one goroutine can hold a `Lock()` at a time. | **Shared**. Multiple goroutines can hold an `RLock()` simultaneously. |
| Blocking Behaviro | Blocks if: another goroutine holds a `Lock()` **OR** any goroutine holds an `RLock()`. | Blocks if: another goroutine holds a **`Lock()`**.           |
| **Analogy**       | A **private office**. Only one person can be inside at a time. | A **public library**. Multiple people can be inside reading at the books simultaneously. |

Another option, if the iteration operation isn’t lightweight, work on actual copy of the data and protect only the copy:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    m := make(...map...) // make a copy
    for k, v := range c.balancess {
        m[k]=v
    }
    c.mu.RUnlock
    
    sum :=0
    for _, blanace := range m {
        // ...
    }
}
```

## Fanning in and out

For the `extractWords()`func -- just like:

```go
func extractWords(quit <-chan struct{}, pages <-chan string) <-chan string {
    words := make(chan string)
    go func() {
        defer close(words)
        wordRegex := regexp.MustCompile(`[a-zA-Z]+`)
        moreData, pg := true, ""
        for moreData {
            select {
            case pg, moreData = <-pages:
                if moreData {
                    for _, word := range wordRegex.FindAllString(pg , -1) {
                        words <- strings.ToLower(word)
                    }
                }
            case <-quit:
                return
            }
        }
    }()
    return words
}
```

DEF -- in Go, a Fan-out concurency pattern is when multiple goroutines read from the same channel, in this way, can distribute the work among a set of goroutines. Thus, can create a fixed number of goroutines, each reading from the *Same URL input channel.* Each one of the goroutines will receive a separaete URL from the `generateUrls()`goroutine, and they can perform the downloads concurrently.

A fan-out pattern is when multiple goroutines read from the same channel, can distribute the work among a set of goroutines -- In this example, the current goroutines are *load-balancing* the URLs sent from the `generateURLs()`goroutine, when a downloadPage() is free, will read the next URL from the shared input channel.

In the code, can implement this simple fan-out pattern by creating a set of `downloadPages()`goroutines and setting the same channel as input channel parameters -- just like:

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    urls := generateUrls(quit)
    pages := make([]<-chan string, 20)
    for i:=0; i<20; i++ {
        pages[i] = downloadPages(quit, urls)
    }
}
```

For this, the outputs of our download goroutines are in separate channels, how can we connect them to the single input channel of our next stage -- the `extractWords()`--  Fore, on solution is to change the `downloadPages()`, but break our pattern of having easily puggable units where each one accepts input channels as args

To keep this pattern -- need a mechanism that merges the output messages from the different channels into a single output channel -- then plug the single output channel into the `extractWords()`.

DEF -- In Go, a *fan-in* concurrency pattern occurs when the merge the content from multiple channels into one. And, when we have a many-to-one fan-in scenario, must make a decision about when to close the common channel. When a goroutine notices that the channel it’s consuming from has been closed, might end up closing the channel too soon.

The solution is to only close the common channel when *all* the goroutines have noticed that the channels from which they are consuming have been closed. Each goroutine in the fan-in group marks the waitgroup as done after it has sent its last message. Have a separate goroutine that calls `wait()`on this waitgroup, which will have the effect of suspending its execution until all the fan-in are done.

```go
func FanIn[K any](quit <-chan struct{}, allChannels ...<-chan K) <-chan K {
	wg := sync.WaitGroup{}
	wg.Add(len(allChannels))
	output := make(chan K)
	for _, c := range allChannels {
		go func(channel <-chan K) {
			defer wg.Done()
			for i := range channel {
				select {
				case output <- i:
				case <-quit:
					return
				}
			}
		}(c)
	}
	// in another goroutine, wait and close the output channel
	go func() {
		wg.Wait()
		close(output)
	}()
	return output
}
```

For this,  the `wg.Wait()`call is placed in a separate gorotuine cuz it is blocking function. And the `output`channel muse be closed when all data has been merged to signal to the downstream consumer that no more values will arrive.

For this, can now connect our fan-in pattern to our application and include it in the pipeline, modifieis our `main()`function to include the `fanIn()`from listing -- the `fanIn()`accepts the list of channels -- 

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    urls := generateUlrs(quit)
    pages := make([]<-chan string, downloaders)
    for i:=0; i< downloaders; i++ {
        pages[i]= downloadPages(quit, urls)
    }
    results := extractWords(quit, FanIn(quit, pages...))
    // ... Where the main goroutine does block --
    for result := range results {
        //...
        fmt.Println(result)
    }
}
```

The `for range`loop is the *consumer* of your entire piepline. The `main`goroutine blocks here cuz it must wait for the concurrent pipeline to produce the next word. It will remain blocked until the entire pipeline is finished.

