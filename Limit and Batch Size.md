# Limit and Batch Size

When a query is executed in Mdb, the results are processed and returned in the form of one or more batches. One of the main purposes of batching is to avoid high resource utilization, which may happen while processing a large number of record sets.

Different mdb drivers can have different batch sizes -- for a single query, the batch size can be set.

```js
db.movies.find(
	{cast: "Charles Chaplin"},
    {"title": 1, _id:0}
).batchSize(5)
```

This query uses the `batchSize()`func on the cursor to provide a batch size of 5. The output is the same, however, there was a difference in how the results were prepared internally -- 

As soon as the first 5 documents are found, they are just retuned to the client as the first batch. Next, the remaining 3 records are found and returned as the next batch. And the same thing happens when a query is exectued with a positive limit that is larger then the batch size. For negative limit -- 

```js
db.movies.find(/*...*/)
.limit(-7).batchSize(5); 
```

And the output indicates that the query returned only the first 5 records instead the 7.

##### Skipping Documents

Skipping is used to exclude some documents in the result set and return the rest. Note that the `skip()`operation does not make use of indexes.

#### Sorting Documents -- 

Mdb *cursor* provides `sort()`function that accepts an argument of the document type, where the document defines a sort order for specific fields. Like:

```js
db.movies.find(
    {"cast" : "Charles Chaplin"},
    {"title" : 1, "_id" :0}
).sort({"title" : 1})
```

Pass -1 to the `sort`arg, which represents sorting in the descending order, Also sorting can be performed on multiple fields, and each cna have a different sorting order. Fore:

```js
db.movies.find().limit(50)
.sort({'imdb.rating': -1, year: 1})
```

### Inserting, updating, and deleting Documents

`db.movies.insertMany(<Array of one or more documents>)`

```js
db.new_movies.insertMany([
    {"_id" : 2, "title": "Baby Driver"},
    {"_id" : 3, "title": "Logan"},
    {"_id" : 4, "title": "John Wick: Chapter 2"},
    {"_id" : 5, "title": "A Ghost Story"}
])
```

#### Inserting Duplicate keys

In many system, a PK is always unique in the table, similarly, in Mdb collections, the value expressed by the `_id`field is a PK, and so it must be unique. If try to insert one whose key is already present in the collection, *Duplicate Key error* occurred.

`db.new_movies.insertOne({"_id" : 2, "title" : "Some other movie"})`11000 code

Similarly, the operation of a bulk insert fails when one or more of the document in the given array has a duplicate `_id`. Fore:

```js
db.new_movies.insertMany([
    {"_id" : 6, "title" : "some movie 1"},
    {"_id" : 7, "title" : "some movie 2"},
    {"_id" : 2, "title" : "Movie with duplicate _id"}, // error
    {"_id" : 8, "title" : "some movie 3"},
])
```

Ntoe that for the output, the value of `nInserted`indicates that two documents have been inserted succesfully.

## Deterministic behavior not used for `select`and Channels

One common mistake made by Go developers while working with channels is to make wrong assumption about how `select`behaves with multiple channels -- A false assumption can lead to subtle bugs.

```go
for {
    select {
    case v := messageCh:
        fmt.Println(v)
    case <-disconnectCh:
        fmt.Println("disconenction, return")
        return
    }
}
```

For this, use `select`to receive from multiple channels -- cuz want to prioritize `messageCh`-- fore this is:

```go
for i:=0; i<10; i++ {
    messageCh <- i
}
disconnectCh <-struct{}{}
```

If `messageCh`is buffered -- only fore, recieved 5 of them. So, if one or more of the communication can proceed, a single one that can proceed is chosen via a uniform pseudo-random selection.

```go
func main() {
	messageCh := make(chan int, 5)
	disconnectCh := make(chan struct{})
	go func() {
		for {
			select {
			case v := <-messageCh:
				fmt.Println(v)
			case <-disconnectCh:
				return
			}
		}
	}()
	for i := 0; i < 10; i++ {
		messageCh <- i
	}
	disconnectCh <- struct{}{}
	time.Sleep(time.Second)
}
```

For the buffered channel -- even though `case v:= <-messageCh`is first in source order, if tehre is a message in both `messageCh`and `disconnectCh`-- there is no guarantee about which case will be chosen.

```go
func main() {
	messageCh := make(chan int, 2)
	disconnectCh := make(chan struct{})
	go func() {
		for {
			select {
			case v := <-messageCh:
				fmt.Println(v)
			case <-disconnectCh:
				for {
					select {
					case v := <-messageCh:
						fmt.Println(v)
					default:
						return
					}
				}
			}
		}
	}()
	for i := 0; i < 10; i++ {
		messageCh <- i
	}
	disconnectCh <- struct{}{}
	time.Sleep(time.Second)
}
```

For this, while there is no *data race* - -the code has a logical flaw that could lead to values being lost or the program exiting abruptly. The send loop is not blocked until the 3rd send. Since the receiver goroutine’s execution is concurrent and non-deterministic, the `main`goroutine might finish sending all 10 message and immediately send the signal on `disconnectCh`.

This is a way to ensure that we receive all the remaining messages from a channel with a receiver on multiple channels.

### Not using notification channels

Channels are a mechanism for communicating across goroutines via signaling. A signal can be either with or without data -- but for Go programmers -- If `disconnectCh := make(chan bool)`-- So the idiomatic way to handle it is a channel of empty structs -- `chan struct{}`-- In Go, an empty struct is a struct without any fileds -- just like:

```go
var s struct{}
fmt.Println(unsafe.Sizeof(s)) // 0
```

An emtpy struct is a de facto standard to convey an absence of of meaning, Fore, if need hash set structure, should use an empty struct as value: `map[K]struct{}`

### Using `nil`channels

A common mistake while working with Go and channels is forgetting that `nil`chanenls can sometimes be helpful -- 

```go
var ch chan int
<-ch // block
```

Note that the goroutine won’t panic, block forever.

Principle is the same if we send a message to a `nil`channel -- 

```go
var ch chan int
ch <- 0
```

Fore, will implement a `func merge(ch1, ch2 <- chan int)`-- fore:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for v := range ch1 {
            ch <-v
        }
        for v := range ch2 {
            ch <-v
        }
        close(v)
    }()
    return ch
}
```

The main issue with the first version is that we just receive from `ch1`and then receive from `ch2`-- it means taht we on’t receive `ch2`until `ch1`is *closed*. Doesn’t fit our use case -- as `ch1`may ben open forever, so want to receive from the both channels imultaneously. When use the `select`just like:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for {
            select {
            case v := ch1:
                ch <-v
            case v:= ch2:
                ch <-v
            }
        }
        close(ch)
    }()
    return ch
}
```

For this, the `select`statement lets wait on multiple operations at the same time. For this one problem is the the `close(ch)`may be unreachable. The way we implemented a `for/select`doesn’t catch when either `ch1`or `ch2`is closed. Even worse -- if at some point `ch1`or `ch2`is closed, receiver of the merged channel will receive the default value forever. Cuz -- receiving from a closed channel is a non-lbocking opreation.

```go
ch1 := make(chan int)
close(ch1)
v, open := <-ch1
fmt.Println(v, open) // 0 false
```

For this, get back to our second solution -- 

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    ch1Closed := false
    ch2Closed := false
    
    go func() {
        for {
            select {
            case v, open := <-ch1:
                if !open {
                    ch1Closed = true
                    break
                }
                ch <-v
            case v, open := <-ch2:
                if !open {
                    ch2Closed = true
                    break
                }
                ch <-v
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

For this, when one of the two channels is closed, the `for`loop will act as a busy-waiting loop.

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for ch1 != nil || ch2 != nil {
            select {
            case v, open := <-ch1:
                if !open{
                    ch1=nil 
                    break
                }
                ch <-v
            case v, open := <-ch2:
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

In summary, have seen that waiting or sending to a `nil`channel is a blocking action, this isn’t useless -- throughout the example of merging two channels.

### Fanning in and out

The Fan-out/Fan -in pattern is fumdamental concurrency design pattern in Go used for paralelizing work and then aggregating the results -- typically implemented using goroutines and channels.

#### Fan-out pattern -- 

Is the process of distributing work from single input source to multiple worker goroutines. It achieves parallelism by allowing several goroutines to process items from the same channel concurrently.

- Mechanism -- Multiple goroutines read from the same input channel.
- Goal -- Distribue a heavy workload across availabe CPU cores to speed up processing.

IMP -- 

1. Create an input channel containing the tasks to be done
2. Start N worker goroutines
3. Each worker goroutine receives an item from the input channel.

Fan -in -- is the process of combining the results from multiple independent worker goroutines back into a single output channel.

- Create a single results channel
- For each worker’s output channel, launch a merger goroutine that reads from that worker’s channel and forwards the values to the central results channel.
- Use a `sync.WaitGroup`to wait for all the merge goroutines to finish forwarding their data
- Once the `WaitGroup`is done, the central results chnnel can be closed.

DEF -- in Go, an `fan-out`concurrency pattern is when multiple goroutines read from the same channel, in this way, can distribute the work among a set of goroutines. Fan out the URLs to multiple `downloadPage()`goroutines -- each doing a different download -- the concurrent goroutins are load-balancing the URLs sent from the `generateUrls()`goroutine when a `downloadPage()`is free, will read the next URL from the shared input channel.

In the code, can implement this simle fan-out by creating a set of `downloadPages()`goroutines and setting the ame channel as an input channel parameter -- like:

```go
func main() {
	const downloaders = 20
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
	for i:= 0; i< downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	// ...
}
```

The fan-out pattern in the app has created a problem -- the outputs of our download goroutines are in separate channels -- how can we connect them to a single input channel of our next stage -- the `extractWords()`goroutine -- one solution is to change the `downlaodPages()`and make them all output on the same channel. Need a mechanism that merges the output messages from the different channels into a single output channel. Can then plug the single output channel into the `extractWords()`goroutine.

DEF -- a *fan-in* concurrency pattern occurs when we merge the content from multiple channels into one. Having multiple goroutines all feeding into a single common creates a problem -- Close the output after the input channels has been closed. The solution is to only close the common channel when *all* the goroutines have noticed that the channels from which they are conumuing have been closed.

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

Now can connect our fan-in pattern to our application and include it in the pipeline.

```go
func main() {
	const downloaders = 20
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
    
    // fan-out
	for i := 0; i < downloaders; i++ {
        // cuz urls is also a channel
		pages[i] = downloadPages(quit, urls)
	}
    // fan-in
	results := extractWords(quit, FanIn(quit, pages...))
	for result := range results {
		fmt.Println(result)
	}
}
```

When run our new imp, it runs a lot faster cuz the downloads are being performed concurrently.

#### Flushing results on close

Havn’t really done anything interesting with our URL download application -- apart from extracting the words. This new longestWords() is slightly different from the other goroutines we have developed in the pipeline. The implementation of `longestWords()`is -- use a map to store the set of unique words -- Can:

```go
func longestWords(quit <-chan struct{}, words <-chan string) <-chan string {
	longWords := make(chan string)
	go func() {
		defer close(longWords)
		uniqueWordsMap := make(map[string]bool)
		uniqueWords := make([]string, 0)
		moreData, word := true, ""
		for moreData {
			select {
			case word, moreData = <-words:
				if moreData && !uniqueWordsMap[word] {
					uniqueWordsMap[word] = true
					uniqueWords = append(uniqueWords, word)
				}
			case <-quit:
				return
			}
		}
		sort.Slice(uniqueWords, func(a, b int) bool {
			return len(uniqueWords[a]) > len(uniqueWords[b])
		})
		longWords <- strings.Join(uniqueWords[10:], ", ")
	}()
	return longWords
}
func main() {
	const downloaders = 20
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	results := longestWords(quit, extractWords(quit, FanIn[string](quit, pages...)))
	for result := range results {
		fmt.Println(result)
	}
}
```

#### Broadcasting to multiple goroutines -- 

What if want to find out more stats from our download pages -- fore this -- say that in addition to finding the longest words, want to find which words occur most frequently. For this scenario, feed the output of `extractWords()`to two goroutines, the existing `longestWords()`and an additional one called `frequentWords()` -- the pattern of the new function will be the same as that of `longestWords()`. It will store the frequency of each unique word.

