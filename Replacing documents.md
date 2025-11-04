# Replacing documents

The `replaceOne()`method in MongoDB replaces a single document within a collection that matches a specified filter with a new document. This method provides a way to replace the existing document with a new one rather than modify specific fields within the document. One common use case for `replaceOne`is when U need to update document with a new set of data, such as when receive fully updated or corrected info or make a major change in the document structure.

Note that the new data must be a full representation of the document. And if U need to preserve existing fields from the original document, is not the right option. In such cases, should use an update operation such as `updateOne()`or `updateMany()`to modify only the necessary fields.

```js
db.routes.replaceOne(
    { "airline.id": 412, "src_airport": "CDG", "dst_airport": "JFK" },
    {
        flight_info: { airline: "Air France", flight_number: "AF 007" },
        route: { from: "CDG", to: "JFK" },
        aircraft: "Boeing 777",
        status: "Scheduled"
    },
    {upsert:true}
)
```

For this the `upsert`is set to `true`and no documents match the filter, `replaceOne()`creates a new document based on the replacement document.

When Uing the `replaceOne`method in the MDB, u just replace the entire document except for `_id`field -- cuz this is just immutable. And note that the replacement document may have different fields from the original document. If the `_id`field is includes in the replace document, it must mtch the current value of the `_id`in the document being replaced and omited. And if a different `_id`is supplied, the replacement operation will fail.

#### Reading documents

The `find()`method in MDB executes queries - retreives a selection of documents from a collection, whcih can change from none to all documents wihtin the collection, it accepts an option filter parameter that specifies with documents to retrieve.

And in version 8.0 and later, Mdb introduces the `defaultMaxTimeMS` -- This parameter enables U to specify a default time limit in ms for individual read operations to complete. Can be:

```js
db.adminCommand(
    {
        setClusterParameter: {
            defaultMaxTimeMS: {readOperations:5000}
        }
    }
)
```

Tip - in mdb, a comma-separated list of expressions implicitly acts as an `AND`operation. Can also use `$or`operator in a compund query to combine conditions with the logicl `OR`-- just like:

```js
db.routes.find({
    $or: [
        { "src_airport": "CDG" },
        { "dst_airport": "JFK" }
    ]
})
```

Can also sue logical operators for more complex queries and combine them with query selectors to refine your searech criteria. In the following query, the `$or`operator specifies conditions on different fields -- 

```js
db.routes.find(
    {
        $or: [
            {"src_airport": "CDG", "airline.name": {$ne: 'American Airlines'}},
            {"dst_airport": "JFK", "airplane": {$ne: '777'}}
        ]
    }
)
```

Just note that the `$nor`operator in Mdb performs a logical `NOR`operation on an array of two or more expression and selects the document that fail to match all the provided expression.

This is just equivalent to `NOT(<ex1> OR <ex2> OR ...)`

```js
db.routes.find(
    {
        $nor:[
            {"src_airport": "CDG"},
            {"dst_airport": "JFK"}
        ]
    }
).count()
```

##### Using comparison operators -- 

And thse -- `$in, $nin, $not`, and the `$eq, $gt...`, fore in a compund query, can establish conditions for several fields in the document of a collection.

```js
{ $nor: [ { category: "Electronics" }, { price: { $lt: 50 } } ] }
```

##### Working with projections -- 

To control which fields are returned in the matching documents from a Mdb query, can use projections to just specify exactly which fields should be included in or excluded from the result set. Projections allows U to tailor the query results by selectively retrieving only the necesary fields.

```js
db.routes.find({},
    {'airline.name':1, 'src_airport': 1, '_id': 0}
    )
```

##### Searching for `null`value and absent fields

Different query operators in Mdb treat `null`values differently, offering various approaches to handle the presence or absence of data in a collection. Understanding these difference is crucial for querying documents effectively.

querying for `null`or MIssing Fields -- to find documents in which a specific field, like `codeShare`, is explicitly `null`or does not exist in the `routes`collection -- run -- 

```js
db.routes.find({
    'codeshare': null
})
```

Returns documents in which the `codeshare`field is present and its value is `null`or `missing.`

##### Querying for non-null and existing fields -- 

To find document in which a `codeshare`exists and is not null`run - 

```js
db.routes.find(
    {codeshare: {$ne: null, $exists: true}}
)
```

##### For fiels that does not exists

To find documents that do not contain a specific field, fore, 

```js
db.routes.find({
    codeshare: {$exists:false}
})
```

##### Using type check for null -- 

To find documents in which a field, like `codeshare`-- contains a `null`value, meaning that its value stored as BSON type `Null`differentating it from non-existence run -- 

```js
db.routes.find({
    'airline.alias': {$type: ['string', 'array']}
}) // find all document where the field either a string or an array
db.routes.find(
    {
        'airline.alias': {$type: ['string']}
    },
    {'airline.alias': 1}
)
```

## Copying a `sync`type

The `sync`package provides basic `sync`synchronization primitives such as  mutexes, condition variables, and wait groups -- for all of these -- there is a hard rule to follow -- they should *never* be copied. Fore create a thread-safe data structure to store counters -- it will contain a `map[string]int`representing the current value for each counter.

```go
type Counter struct {
    mu sync.Mutex
    counters map[string]int
}

func NewCounter() Counter {
    return Counter{counters: map[string]int}
}

func (c Counter) Increment(name string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.counters[name]++
}

// if use -- 
counters := NewCounter()
go func() {
    counter.Increment("foo")
}()
go func() {
    counter.Increment("bar")
}()
```

If run, raises a data race. -- The problem in the `Counter`implementation is that mutex is copied -- cuz the receiver of `Increment`is a value, whenever we call `Increment`-- it performs a copy of the `Counter`struct, whcih *also copies the mutex* -- therefore, the increment isn’t deone in a shared CS.

So, `sync`types shouldn’t be copied -- this rule applies to the following -- 

`Cond, Map, Mutex, RWMutex, Once, Pool`and `WaitGroup`.

For the `sync.Map`is a specialized map type introduced in Go’s `sync`package -- designed for use cases where *keys are mostly read*, and *writes are infrequent*. Therefore, the mutex shouldn’t have been copied -- the first to modify the receiver type for the `Increment`-- like:

```go
func (c *Counter) Increment(name string) {
    //...
}
```

And if want to keep value receiver, the second is to change the type of the `mu`field in `counter`to a pointer like:

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

If `Increment`has a value receiver, it will still copy the `Counter`. And, may face the issue of unintentionally copying a `async`field in the following conditions -- 

- Calling a method with a value receiver
- Calling within a `sync`
- Calling with an arg that contins a `sync`field.

In each case, should remain very cautious.

### Extracting words

For the `extractWords`function, the same pattern as for `downloadPages()`is used -- the function accepts an input channel containing texts, and it returns an output channel containing all the words found in the received texts. It extracts the words from the document by using regular express. Just like:

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
                    for _, word := range wordRegex.FindAllString(pg, -1){
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

In the `main.go`-- just like:

```go
func main() {
    results := extractWords(quit, downloadPages(quit, generateUrls(quit)))
    //...
}
```

#### Fanning in and out

In the exmaple, if want to speed things up, can perform the downloads concurrently by *load-balancing* the URLs to multiple goroutines, can create a fixed number of goroutines, each reading from the same URL input channel, each one of the goroutines will receive a separate URL from the `generateUrls()`goroutine, and they can perform the downloads concurrently -- the downloaded text pages can then be written on each goroutine’s own output channel.

DEF - in Go, a fan-out concurrency pattern is when *multiple goroutines read from the same channel*. And in this way, can distribute the work among a set of gorotuines - In this example, the concurrent goroutines are load-balancing the URLs sent from the `generateUrls()`goroutine - when a downloadPage() is free, will read the next URL from the shared input channel.

Also note that since concurent processing is non-deterministic, some messages will be processed quicker than others. Resulting in messages being processed in an *unpredictable* order. So the fan-out pattern makes sense only if we don’t care about the order of the incoming messages.

And if use the *fan-out pattern* in Go and care about the order of the incoming messages, must *re-sync* and order the messages from the worker stage before they move to the next stage.

##### Define the ordered message structure -- 

Since need to track both the data and its original order, define a struct to carry the sequence number like:

```go
// new type for input to download page
type orderedUrl struct {
	id  int
	URL string
}

// modify generateUrls to produce an ordered URL
func generateUrlsInOrder(quit <-chan struct{}) <-chan orderedUrl {
	urls := make(chan orderedUrl)
	go func() {
		defer close(urls)
		for i := 100; i <= 130; i++ {
			url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
			pageID := i
			select {
			case urls <- orderedUrl{pageID, url}:
			case <-quit:
				return
			}
		}
	}()
	return urls
}
```

##### Modify the `downloadPage`to maintain the ID -- Fan-out stage

This is just the main stage, it accepts the `orderedURL`, and the Ordered-Fan-In stage.

##### Implementing the re-ordering stage -- OrderedFanIn

This is also the crucial stage that collects all results from the workers and delivers them in the correct sequence -- 

```go
func downloadPagesInOrder(quit <-chan struct{}, urls <-chan orderedUrl) <-chan orderedPage {
	pages := make(chan orderedPage)
	go func() {
		defer close(pages)
		for {
			select {
			case orderedURL, ok := <-urls:
				if !ok {
					return
				}

				resp, err := http.Get(orderedURL.URL)
				if err != nil {
					// Handle error or panic
					continue
				}
				if resp.StatusCode != 200 {
					// Handle non-200 status
					resp.Body.Close()
					continue
				}

				body, _ := io.ReadAll(resp.Body)
				resp.Body.Close()

				// Return the result with its original ID
				pages <- orderedPage{id: orderedURL.id, body: string(body)}

			case <-quit:
				return
			}
		}
	}()
	return pages
}
```

##### Reassemble `main`stge -- 

The structured of `main`changes to use the new types and the `OrderedFanIn`-- 

```go
func orderedFanIn(quit <-chan struct{}, firstId int,
	allChannels ...<-chan orderedPage) <-chan string {
	results := make(chan string)
	go func() {
		defer close(results)
		buffer := make(map[int]string)
		nextExpectedID := firstId

		// std Fan in to receive all ordered page results concurrently
		tempOutput := FanIn[orderedPage](quit, allChannels...)
		for ord := range tempOutput {
			buffer[ord.id] = ord.body
			for {
				body, found := buffer[nextExpectedID]
				if !found {
					break
				}
				select {
				case results <- body:
					delete(buffer, nextExpectedID)
					nextExpectedID++
				case <-quit:
					return
				}
			}
		}
	}()
	return results
}
```

Reassemble the main stage just like:

```go
func main() {
	const downloaders = 20
	const firstRFC = 100
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrlsInOrder(quit)
	pages := make([]<-chan orderedPage, downloaders)
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPagesInOrder(quit, urls)
	}

	// Ordered Fan-In
	orderedPages := orderedFanIn(quit, firstRFC, pages...)

	// other stages not matters for order
	results := longestWords(quit, extractWords(quit, orderedPages))
	for result := range results {
		fmt.Println(result)
	}
}
```

Can see, the speed is not changed very hard. For this, by using sequence IDs and `OrderedFanIn`collector, you trade a small amount of memroy for guaranteed message order in a high-concurrency pipeline. For the `Fan-in`stage, just need a mecnanism that merges the output messages from the different channels into a single output channel.