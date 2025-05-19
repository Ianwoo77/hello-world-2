# Partial Indexes

An index can be created to maintain documents that match a *given filter expression*. Such an index is called *partial index* -- As the documents are filtered depending on the input expression, the size of the index is smaller than a normal index -- the syntax to create a partial index is as follows -- 

```js
db.collection.createIndex(
	{field1: type, field2: type2, ...},
     {partialFilterExpression: filterExpression}
);
```

The `{partialFilterExpression: filterExpression}`is used to create a partial index -- `partialFilterExpression`can only accept an expression document that contains operations from the list like:

- `$eq`fore, or `{field:value}`
- The `$exist: true`
- `$gt,...`
- `$type`expressions
- The `$and`operator at the top level only 

Fore, introduce a partial index on the `title`and `type`fields in the `movies`collection, using `partialFilterExpression`-- like:

```js
db.moves.createIndex(
    {title:1, type:1},
    {
        partialFilterExpression: {
            year: {$gt:1950}
        }
    }
)
```

This preceding command creates a partial compound index on the given fields for all the movies released after 1950. Then can check and note down the index size on the collection using the `stats()`function -- like:

```js
db.movies.stats();
// insert a movie that was released before 1950
db.movies.insert(
	{title: "In old", type: 'movie', year: "1910"}
)
```

Can see , introduced a partial index and verified.

#### Case-insensitive indexes

*case-insenstive* indexes allow U to find data using indexes in a case-insensitive manner -- this means that the index will match the documents even if the values of a field are written in a different case from the values in the search expression. This is possible due to the collation feature in the Mdb, which allows the input of language-speciific rules.

```js
db.collection.createIndex(
	{"field": 1},
    {
        collation: {locale: <locale>, strength: <strength>}
    }
)
```

- `locase`-- refers to the language to be sued, fore, `en, fr...`
- `stength`-- A value of 1 or 2 indeciates a case-level collation.

Create a case-insensitive index by connecting the mongo shell to the Atlas cluster.

```js
db.movies.createIndex(
    {title:1},
    {collation: {
        locale: 'en', strength: 2
        }}
)

// the command will return the correct movie
db.movies.find(
    {title:'goodFEllas'},
).collation({locale:'en', strength:2})
```

The `collation`option allows us to perform case-insensitive searches on unindexed fields as well.

### Other Query Optimization Techniques

We have to also explored various types of indexes and their properties and learned how we can use correct index and correct index properties in specific use cases. There are also a few more techniques that are required to *fine-tune* the query performance -- 

#### Fetch only what U need

The performance of a query is also affected by the amount of data it returns -- The dbs server and client communicate over a network --  If a query produces a large amount of data, it will take longer to transfer it over a network. Moreover, to transfer the data over the network -- it needs to be transformed and serialized by the server and deserialized by the receiving client.

#### Sorting using Indexes

Queries often need to return the data in some order -- fore, if the user chooses an option to view the latest movies, the resulting movies can be sorted on the basis of the release date.

### Replication

This will introduce Mdb cluster concepts and administration -- it starts with a discussion on the concept of high availability and the load sharing of a MDB dbs.

So a Mongodb cluster is a distributed dbs archiutecture designed for handling large-scale data -- high availibility, and performance -- it primarily reiles on *sharding* and *replication* -- 

- Replica set -- A group of Mdb servers holding copies of the same data for reduancy and high availibility
  - Indlucdes one *primary* node and multiple *Secondary* nodes
  - If the primary fails, a secondary is automatically selected as the new primary
  - Data backup, failover, and read scaling.
- Sharding -- Splits data horizontally across multiple servers to manage large datasets.
- Cluster componetns -- 
  - Mongod -- core dbs process running on each shard or replica set node
  - Config server -- stores cluster metadata, typically deployed as a replica set
  - Mongos -- Query router -- client connect to mongos.

#### Cluster members

In Altas, can see the cluster member list from the clusters page -- Fore has 3 cluster members, which are naemd with the same *prefix* as the Atlas cluster name. For Mbd clusters thata are installed without using the Altas.

The Election process -- 

#### Backup and restore in MongoDB -- 

Unless U are working on a new project, this is generally the way a dbs will first appear to you -- however, when you hired or moved to a different project with a mdb -- will contain all the data was cretaed before U started there.

Mongodb Utilities -- The mongodb does not include functions for exporting, importing.. However, Mdb has created methods for accomplishing this -- so that no scripting work or complex GUI are needed -- for this, several utility scripts are provided that can be used to get data in or out of the dbs in the bulk. These utility scripts are -- 

- mongoimport
- mongoexport
- mongodump
- mongorestore

#### Exporting MongoDB data -- 

When it comes to moving data in and out of Mongodb in bulk, the most common and generally useful utility is `mongoexport`-- this command is useful cuz it is one of the primary ways to extract large amounts of data from MDB in usable format -- getting your mdb data out into a JSON file allows U to ingest it with other applications or dbs and share data with stakeholders outside of MDB.

It is important to note that mongoexport must run on a single specified dbs and collection. U cannot run it on entire dbs or multiple collections. Will see how to accomplish larger scope backups like these later in the chapter. Fore:

```sh
mongoexport --uri=connectionstring/sample_mflx -quiet --limit=10 --sort="{trailId:1}" --\
	collection=theaters --out=output.json
```

This example is more complex command -- use that -- 

Using mongoexport -- The best way to learn is build up a command parameter by parameter.

## Fan-out, Fan-In

Data is folowing through your systtem -- transforming as it makes its way through the stages U have chained together. It’s like a beautiful stream -- slow stream -- Sometimes, stages in the  pipeline can particualrly computationally expensive, when this happens, upstream stages in your pipeline can become blocked while waiting fro your expensive stages to complete -- Not only that, but the pipeline itsefl can take a long time to execute as a whole -- One of the interesting properties of pipeline is the ability they give U to operate on the stream of data using a combination of separate, often re-orderable stages. Can even reuse stages of the pipeline mutliple times. In fact, it turns out it can, and this pattern has a name -- *fan-out, fan-in*.

Fan-out is a term to describe the process of starting multiple goroutines to handle input from the pipeline, and fan-in is a term to describe the process of combining multiple results into one channel. So what makes a stage of a pipeline suited for utilizing this pattern -- might consider fanning out one of your stages if both of the following apply -- 

- It doesn’t rely on values that the stage had calcuated before.
- Takes a long time to run

```go
func toInt(done <-chan struct{}, valueStream <-chan any) <-chan int {
	intStream := make(chan int)
	go func() {
		defer close(intStream)
		for v := range valueStream {
			select {
			case <-done:
				return
			case intStream <- v.(int):
			}
		}
	}()
	return intStream
}

func randn() any {
	return rand.Intn(50000000)
}

func primeFinder(done <-chan struct{}, valueStream <-chan int) <-chan any {
	primeStream := make(chan any)
	go func() {
		defer close(primeStream)
		for v := range valueStream {
			isPrime := true
			for i := 2; i < v; i++ {
				if v%i == 0 {
					isPrime = false
					break
				}
			}
			if isPrime {
				select {
				case <-done:
					return
				case primeStream <- v:
				}
			}
		}
	}()
	return primeStream
}

func main() {
	done := make(chan struct{})
	defer close(done)

	start := time.Now()

	randIntStream := toInt(done, repeatFn(done, randn))
	fmt.Println("Primes:")
	for prime := range take(done, primeFinder(done, randIntStream), 10) {
		fmt.Printf("\t%d\n", prime)
	}
	fmt.Printf("10 primes in %v\n", time.Since(start))
}
```

For this, we are generating a stream of a random numbers, capped at 5000... converting the stream into an integer, and then passing that into `primeFinder`stage -- naively begins to attempt to divide the number provided on the input stage. For this, is just a relatively simple example, so only have two stages, random number generation and prime sieving -- in a large one, your pipeline might composed of many more stages. Order-independent, but it doesn’t take a particualr long time to run -- the `primeFinder`stage is also order-independent -- numbers are either prime or not -- and cuz of your naive -- 

Fortunately the process of fanning out a stage in a pipeline is easy -- just like:

```go
randIntStream := toInt(done, repeatFn(done, randn))
numFinders := runtime.NumCPU()
finders := make([]<-chan any, numFinders)
for i := 0; i < numFinders; i++ {
    finders[i] = primeFinder(done, randIntStream)
}
```

Here we are starting up as many copies of this stage as have CPUs --  -- continue to use this number in our dicsucssion, We will have a problem --now that we have 4 goroutines,  We still have a problem -- not that we have 4 goroutines, also have 4 channels -- 

```go
func fanIn(done <-chan struct{}, channels ...<-chan any) <-chan any {
	var wg sync.WaitGroup
	multiplexedStream := make(chan any)
	multiplex := func(c <-chan any) {
		defer wg.Done()
		for i := range c {
			select {
			case <-done:
				return
			case multiplexedStream <- i:
			}
		}
	}
	wg.Add(len(channels))
	for _, c := range channels {
		go multiplex(c)
	}

	// wait for all the reads to complete
	go func() {
		wg.Wait()
		close(multiplexedStream)
	}()
	return multiplexedStream
}
```

In a nutshell, fanning in involves creating the multiplexed channel consumers will read from, and then spinning up one goroutine for each incoming channel, and one goroutine to close the multiplexed channel when the incoming channels have all been closed.

### Programming with channels

Working with channels requires a different way of programming than when using memory sharing -- The idea is to have a set of goroutines, each with its own internal state, exchanging info with other goroutines by passing messages on Go’s channels -- In this way, each goroutine’s state is isolated from direct inference by other exuections, reducing the risk of RC -- Go’s own mantra is not to communicate by shared memory but to instead share memory by communicating - since memory is more prone to RC and requires compex sync techniques -- should avoid it when possible and instead use message passing.

Will start by discussing communicating CSP and then move on to look at the common patterns used when using message passing with channels.

#### Communicating sequential processes

In previous chapter -- discussed a model of concurrency using goroutines - shared memory, and primitives -- mutexes, condition variables and semaphores -- this is the classic way to model concurrency -- Programming with a low-level model of concurrency means that as programmers, we need to work harder to manage the complex and reduce bugs in our software -- don’t know when a thread of execution will be scheduled by the OS.

Programming with such low-level tools for concurrency, when combined with modern software development teams and ever-increasing business complity -- 

#### Avoiding interfernce with immutability

One way to greatly reduce the risk of RC is to not allow our programming to modify the same memory from multiple concurrent executions.

DEF -- *Immutabe* literally means unchangeable -- In computer programming, we use immutability when we initialize structures without providing any way to modify them. When the programming requires changes to these structures, we create a new copy of the structure containing the required changes.

#### Concurrent programming with CSP

A different, higher-level model of concurrency was proposed by CSP -- Communicting sequential process is a formal language used to describe concurrent systems. The key difference when using the CSP model is that executions are not sharing memory -- instead, they pass copies of data to each other -- Go implements this model with the user of goroutines and channels -- Just like in the CSP model -- Go’s channels are synchoronized and unbuffered by default.

#### Reusing common patterns with channels

The first pattern we will examine is having a common channel that instructs goroutine to stop processing messages -- saw how we can use Go’s `close(channel)`-- call to notify a goroutine that no more messages are coming. The goroutine can then terminate its execution -- 

One solution is to use a quit channel together with the `select`statement. Fore:

A pattern of this -- like:

```go
func printNumber(numbers <-chan int, quit chan int) {
    go func() {
        for i := 0; i<10; i++ {
            fmt.Println(<-nubmers)
        }
        close(quit)
    }()
}

func main() {
    numbers := make(chan int)
    quit := make(chan int)
    printNumbers(numbers, quit)
    next := 0
    for i:=1; ; i++ {
        next += i
        select {
        case numbers <-next:
        case <-quit:
            //...
        }
    }
}
```

#### Pipelining with channels and goroutines

Look at a pattern of connecting goroutine to form an execution pipeline -- can demonstrate this with an app that processes the next contents of web pages. The first step in our app to generate URLs of web pages that we can download later -- can have a goroutine generate several URLs and send them on a channel to e consumed. Shows an imp of the `generateUrls()`-- creates a goroutine that generates URL strings on an output channel -- The output channel is returned by the function -- the function also accepts a quit channel -- 

```go
func generateUrls(quit <-chan struct{}) <-chan string {
	urls := make(chan string)
	go func() {
		defer close(urls)
		for i := 100; i <= 130; i++ {
			url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
			select {
			case urls <- url:
			case <-quit:
				return
			}
		}
	}()
	return urls
}
```

Then write the logic to download the contents of these pages -- for this task, we just need a goroutine that accepts a stream of URLs and outputs the next contents into another output stream.

```go
func downloadPages(quit <-chan int, urls <-chan string) <-chan string {
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
                        panic("server errro"+ resp.Status)
                    }
                    body, _ := io.ReadAll(resp.Body)
                    pages <-string(body)
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

We are passing a copy of the web document on the channel -- we can do this since the web pages are only a few KB in size -- using message passing for large objects, such as images or video -- in this might have a detrimental effect on performance. Just like:

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    results := downlaodPage(quit, generateUrls(quit))
    for result := range results {
        fmt.Println(result)
    }
}
```

When run the preceding `main()`, get the text from the web pages, and they are printed. Following this pattern of accepting the input channel as a function input parmaeter and returning the output channel makes building pipelines easy.

## Creating a `decodePostForm`helper

To assist with this, create a new `decodePostForm()`helper which does 3 things -- 

- Calls the `r.ParseForm`on the current request
- Calls the `app.formDecoder.Decode()`to unpack the HTML form data to a target destination
- Checks for a `form.InvalidDecoderError`error and triggers a panic if we ever see it.

```go
type application struct {
	errorLog       *log.Logger
	infoLog        *log.Logger
	snippets       *models.SnippetModel
	users          *models.UserModel
	templateCache  map[string]*template.Template
	formDecoder    *form.Decoder
	sessionManager *scs.SessionManager
}

func (app *application) decodePostForm(r *http.Request, dst any) error {
    err := r.ParseForm()
    if err != nil {
        return err
    }
    
    // Call the `Decode()` on our decoder instance, passing the target destination as the first
    err = app.formDecoder.Decode(dst, r.PostForm)
    if err != nil {
        //..
    }
    return nil
}
```

### Stateful HTTP

A nice touch to improve our use experience would be to display a one-time confirmation message which the user sees after they have added a new snippet. A confirm message like this should only show up for the user once and no other users should ever see the message -- 

A confirmation message like this should only show up for user once and no other users should ever see the message. To make this work, need to start sharing data between HTTP requesets for he same user -- The most common way to do this is to implement a *session* for the user.

Choosing a session manager -- fore, `gorilla/sessions`or `alexedwards/scs`-- depending on your project’s needs. An HTTP session is a seq of network request-response transactions between a client and a server, used to maintain state and track user interactions across multiple requests in a stateless protocol like HTTP. Since HTTP itself is stateless -- each request is just independent - sessions provide a way to remember user data -- such as login status or shopping cart contenst -- 

- Begins when a client sends an initial request to a server.
- Server generates a unique session ID to identify the session
- The session ID is typically sent back to the client via a cookie -- fore `Set-Cookie: sessionId=abc123`.

Session storage -- The server stores session data in memroy, a dbs, or a file system, associating it with session ID. The client stores only the session ID and includes it in subsequent requests to identify itself.

Session management -- 

- cookies -- most common method -- automatically sends the session ID in the `Cookie`header wtih each request.
- Session Timeout -- session expire after a peroid of inactivity.
