# Importing Data into MongoDB

U know how to get your collection data out of Mdb and into an easy-to-use format on disk -- This situation is where `mongoimport`comes in handy -- 

```sh
mongoimport --db=imports --collection=concats --file=concats.json
# fore
mongoimport --uri=ATLASConnectionString --collection=concats --file=concats.json
```

### Backing up an Entire Database

Using `mongoexport`, could theoretically take an entire mdb server and extract all the data in each dbs and collection -- could have to do this with one collection at a time, ensuring that the files correctly mapped to the original dbs and collection -- doing this manually is possible but just difficult. Along with `mongoimport`and `mongoexport`, the Mdb tolls package also provides a tool for exporting the entire contents of the dbs. This utility is called `mongodump`. And this export creates a binary fiel that can be restored using `mongorestore`.

### The Mdb Architecture -- 

MDB enbles U to meet the demands for modern apps with a developer data platform built on several core architectural fundations.

CURD -- 

```js
db.books.insertOne({ title: 'Mastering MongoDB 7.0', isbn: '101' });
db.books.updateOne({isbn: '101'}, {$set:{price:30}})
db.books.deleteOne({isbn: '101'})
```

And when several documents meet the filter’s criteria, only the first matching document is modified by the `updateOne`-- 

#### Scripting for Mongosh

```js
db.adminCommand('listDatabases')
db.getCollectionNames()
db.getUsers()
db.getRole({showBuiltinRoles: true})
db.adminCommand({'getLog': '<logname>'})

cursor = db.collection.find()
if (cursor.hasNext()) {
    cursor.next();
}
```

#### Batch inserts using `mongosh`

```js
function authorMongoDBFactory() {
    for(let loop=0; loop<1000; loop++) {
        db.books.insertOne({name: 'Mongodb factory'+loop});
    }
}
```

As an alternative, U can use a `bulk`write to issue a single dbs `insert`command with the 1000 documents that you have prepared beforehand -- like:

```js
function fastAuthorMongoDBFactory() {
    let bulk = db.books.initializeUnorderedBulkOp();
    for(let loop=0; loop<1000; loop++) {
        bulk.insert({name: "..."})
    }
    bulk.execute();
}
```

### Schema Design and Data Modeling

In the dynamc world of dbs management - the decisions U make about structing and representing data, significantly impact effecicency -- adaptability and overall system performance.

#### BSON and its data types

BSON forms the bedrock for storing data in MDB. While it shares similarities with JSON, comes equipped with additional data types and optimization for storage and scanning speed. And BSON was designed to have the following 3 characters -- 

- Lightweight -
- Travsable
- Efficient

#### Aggregation framework

The aggregation framework in Mdb is a data processing tool that helps U perform complex data transformation and computation -- you can use the framework to filter, transform, and get insights from data instead of writing scripts outside the dbs to process it.

1. Filter grades -- by using the `$match`strage, can filter only the grades needed from the target
2. Group the grades -- using the `$group`stage can group by `student_id`fore.
3. Compute the averge grade. like:

```js
db.student_grades.aggregate([
    {$match: {semester: "Fall 2023"}},
    {
        $group: {_id: "$strudent_id"}
    },
    {
        $project: {
            // calculate average
            avergeGrade: {$divide: [$"totalGrade", "$totalCourses"]}
        }
    }
])
```

### Updating with Aggregation Pipelines and Arrays

A pipeline is composed of multiple update expressions called stages -- when an update operation containing multiple stages of update expression is executed, each of the matched document is processed and transformed through each stage sequentially. The output of the first is the put the next stage. Fore, in the `updateMany()`just like:

1. `updateMany()`with aggregation pipelines -- 

   The `updateMany()`updates multiple documents in a collection that match a filter fore, since 4.2, `updateMany()`supports aggregation pipelines in the `update`parameter.

   ```js
   db.collection.updateMany(
   	<filter>,
       <update>, // either a replacement or an aggregtion pipeline
       <options> // fore {upsert: true}
   )
   ```

   When using an aggregation pipeline, the `update`parameter is an array of pipeline stages

2. Using aggregation pipelines in `updateMany()`-- Aggregation pipelines in `updateMany()`allow U to perform computations or transformations on matched documents.

   - $set, $unset, 
   - `$addFields`-- adds a new fields based on expression
   - `$replaceRoot`-- replace the document with a new structure

Fore, like:

```js
db.books.insertOne(
    {
        title: "Book 1",
        author: "Author A",
        price: 20,
        stock: 50,
        lastUpdated: null
    }
)

db.books.updateMany(
    {stock: {$gt: 30}},
    [
        {
            $set: {
                price: {$multiply: ["$price", 0.9]},
                lastUpdated: new Date()
            }
        },

        {
            $set: {
                priceCategory: {
                    $switch: {
                        branches: [
                            {case: {$gt: ["$price", 30]}, then: "Premium"},
                            {case: {$gte: ["$price", 15]}, then: 'Standard'}
                        ],
                        default: 'Budget'
                    }
                }
            }
        }
    ]
)
```

1. `filter`-- `{stock: {$gt:30}}`-- selects documents where `stock`is greater 30
2. pipeline -- First `$set`-- multiplies `price`by 1.1
3. Second `$set`-- adds the `priceCategory`using `$switch`expression to categorize prices

Options -- 

- `upsert:true`-- creates a new document if no match is found
- `writeConcern`-- Controls the durability
- `arrayFilters`-- filters elements in arrays for targeted updates

#### The `aggregate()`Function -- 

The `aggregation()`function processes data through a pipeline of stages to perform coplex transformations, filtering, grouping - or computations -- unlike `updateMany()`-- the `aggregate()`doesn’t modiy the collection -- it returns a results for analysis or further processing.

```js
db.collection.aggregate([
    <stage1>
    <stage2>
    //...
], <options>);
```

## Fan-out Fan-in

Sometimes, stges in your pipeline can be particularly computationally expensive -- when this happens -- upstream stages in your pipeline can become blocked while waiting for your expensive stages to complete -- One of the interesting properties of pipelines is the ability they give U to operate on the stream of data using combination of separate, often reorderable stages -- can even reuse stages of the pipeline multiple time.

Fan-out is a term to describe the process of starting multiple goroutines to handle input from the pipeline, and fan-in to describe the process of combining multiple results into one channel.

The property of order-independence is important cuz you have no guarantee in what order occurrence copies of your stge will run, nor in what order they will return -- like:

```go
func repeatFn(done <-chan struct{}, fn func() any) <-chan any {
	valueStream := make(chan any)
	go func() {
		defer close(valueStream)
		for {
			select {
			case <-done:
				return
			case valueStream <- fn(): // core statement
			}
		}
	}()
	return valueStream
}

func randn() any {return rand.Intn(50000000)}
func main() {
    done := make(chan struct{})
    defer close(done)
    start := time.Now()
    randIntStream := toInt(done, repeatFn(done, randn))
    fmt.Println("primes")
    for prime := range take(done, primeFinder(done, randIntStream),10) {
        fmt.Printf("\t%d\n", prime)
    }
    fmt.Printf("Search took: %v", time.Since(start))
}
```

We are just generating stream of random numbers, -- converting the stream into an integer stream, and then passing that into our `primeFinder`stage -- Do like:

```go
func main() {
	done := make(chan struct{})
	defer close(done)

	start := time.Now()

	randIntStream := toInt(done, repeatFn(done, randn))
	numFinders := runtime.NumCPU()
    // fan-out
	finders := make([]<-chan any, numFinders)
	for i := 0; i < numFinders; i++ {
		finders[i] = primeFinder(done, randIntStream)
	}
	for prime := range take(done, fanIn(done, finders...), 10) {
		fmt.Printf("\t%d\n", prime)
	}
	fmt.Printf("Search took: %v", time.Since(start))
}

func fanIn(done <-chan struct{}, channels ...<-chan any) <-chan any {
    var wg sync.WaitGroup
    multiplexedStream := make(chan any)
    multiplex := func(c <-chan any) {
        defer wg.Done()
        for i:= range c {
            select {
            case <-done:
                return
            case multiplexedStream <-i:
            }
        }
    }
    wg.Add(len(channels))
    for _, c := range channels {
        go multiplex(c)
    }
    
    go func() {
        wg.Wait()
        close(multiplexedStream)
    }()
    return multipexedStream
}
```

Created a function `multiplex`-- which passed a channel, will read from the channel, and pass the value read onto the `multiplexStream`channel.

#### The *or-done* channel

At times you will be working with channels from disparate parts of your system -- unlike with pipelines, can’t make an assertions about how a channel will behave when code you are working with is canceled via its `done`channel.

#### Pipelining with channels and goroutines

Look at a pattern of connecting goroutines to form an exuection pipeline -- can demonstrate this with an app that process the text content of web pages -- The first step in our app is to generate URLs of web pages that can download later -- Shows an imp of the `generateUrls()`function -- which creates a goroutine that generates URL strings on an output channel - the output channel is returened by the function -- the function also accepts a quit channel -- which it listens to in case it needs to stop generating URLs eariler.

Adopt a common pattern where we pass the input channel as a function argument and return the output channel just like:

```go
func generateUrls(quit <-chan struct{}) <-chan string {
    urls := make(chan string)
    go func() {
        defer close(urls)
        for i:=100; i<=130; i++ {
            url := fmt.Sprintf("https://..%d.txt", i)
            select {
            case urls<-url:
            case <-quit:
                return
            }
        }
    }()
    return urls
}

func main() {
    quit := make(chan int)
    defer close(quit)
    results := generateUrls(quit)
    for result := range results {
        fmt.Println(result)
    }
}

// then the downloaPages() function -- accepts both the quit and urls
// and returns an output channel contianing the downloaded pages
func downloadPages(quit <-chan struct{}, urls <-chan string) <-chan string {
	pages := make(chan string)
	go func() {
		defer close(pages)
		moreData, url := true, ""
		for moreData {
			select {
			case url, moreData = <-urls:
				if moreData {
					resp, _ := http.Get(url)
					if resp.StatusCode != 200 {
						panic("Server's error:" + resp.Status)
					}
					body, _ := io.ReadAll(resp.Body)
					pages <- string(body)
					resp.Body.Close()
				}
			case <-quit:
				return
			}
		}
	}()
	return pages
}
```

For this problem -- cuz web page are only a few KB size, using message passing for large objects, such as images or videos, in this fashion might have a determental effect on performance. Using memory-sharing maybe better.

Can now connect this new to our pipeline easily since it accepts the same channel datatypes as the output of the `generateUrls()`function -- it also returns the same output channel datatypes as the one that our `main()`goroutine can use.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	results := downloadPages(quit, generateUrls(quit))
	for result := range results {
		fmt.Println(result)
	}
}
```

When run the peceding `main()`, just get the text from the web pages, and they are printed on the console -- Printing out our text pages is now very useful - so instead we can add another goroutine on our pipeline to extract words from the downloaded text -- following the pattern of accepting the input channel as a function input parameter and returning the ourput channel makes building pipelines easy. Shows the imp of the `extractWords()`function -- the same pattern as for `downloadPages()`is used -- the function accepts an input channle containing texts, and it returns an output channel containing all the words found in the received texts -- using `regex`.

```go
func extractWords(quit <-chan int, pages <-chan string) <-chan string {
    words := make(chan string)
    go func() {
        defer close(words)
        wordRegex := regex.MuxtComplie(`[a-zA-Z]+`)
        moreData, pg := true, ""
        for moreData {
            select {
            case pg, moreData = <-pages:
                if moreDtaa {
                    for _, word := range wordRegex.FindAllString(pg -1) {
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

Again, can modify our `main()`function to include this new goroutine in our pipeline, as -- each function in the pipeline is a gorotuine that takes the `quit`channel and an input channel and returns an output channel that returns are sent to. Like:

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    results := extractWords(quit, downloadPages(quit, generateUrl(quit)))
    for result := range results {
        fmt.Println(result)
    }
}
```

This pipeline pattern gives us the ability to easily plug executions together. Each execution is represented by a function that starts a goroutine accepting input channels as arguments and returning the output channels as return values -- 

#### Fanning in and out

In our example -- if want to speed things up - can perform the downloads concurrently by load-balancing the URLs to multiple goroutines -- can create a fixed number of goroutines -- each reading from the same URL input channel.

DEF -- in Go, a fan-out concurrency pattern is when multiple goroutines read from the same channel -- in this way, can distribute the work among a set of goroutines -- 

```go
urls := generateUrls(quit)
pages := make([]<-chan string, downloaders)
for i := 0; i<downloaders; i++ {
    pages[i]= downloadPages(quit, urls)
}
```

The fan-out pattern in our application has created a problem -- the outputs of our download goroutines are in separate channels -- how can we connect them to the single input channel of our next stage for the `extractWords`-- one solution is to change the `downloadPage`goroutines and make them all output on the same channel.

And in go, an *fan-In* concurrency pattern occurs when we merge the content from multiple channels into one. Since goroutines are very lightweight, can implement this fan-in pattern as a single unit by creating a set of goroutines -- one per output channel, and having each goroutine feed a common channel -- and when a message arrives, it simpley forwards it to the common channel like:

Having multiple goroutines all feeding into a single common channel creates a problem -- when we have a one-to-one input -to-input channel goroutine, the channel-closing strategy is simple, close the output after the input has been closed -- When have a many-to-one fan-in scenario,  Must make a decision about when to close the common channel. We might end up closing the channel too soon -- Another goroutine might still be outputting messages -- 

The solutijon is only close the common when *all* have noticed that the channels from which they are consuming have been closed -- Each goroutine in the fan-in group marks the waitgroup as done after it has sent its last message.

```go
func FanIn[K any](quit <-chan struct{}, allChannels ...<-chan K) chan K {
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
    go func() {
        wg.Wait()
        close(output)
    }()
    return output
}
```

Can now connect our *fan-in* pattern to our app and include it in the pipeline -- modifies our `main()`function to include the `fanIn()`function from listing -- the `fanIn()`function accepts the list of channels containing the web pages and returns a common aggregated channel -- like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	results := extractWords(quit, FanIn(quit, pages...))
	for result := range results {
		fmt.Println(result)
	}
}
```

