# Using bulkWrite() 2

Perform operations in bulk -- the `bulkWrite()`allows U to perform bulk insert, update, and delete operations. Are eighter ordered or unordered -- 

- In Ordered operations - Mdb processes the operations sequentially -- So, if an error arises during the execution of any operation, Mdb halts further processing of subsequent write operations in the list.
- Unordered list of operations -- MDB has the potential to execute these operations in parallel, although this behavior isn’t assured. If an error emerges during the processing of a write operation, Mdb perissts in processing the remaining write operations.

And, executing an ordered on a shared colection typically incurs slower performance compared with an unordered. By default, the `bulkWrite()`conducts operations in an ordered manner. To change, can set `ordered: false`in the options document -- `insertOne, updateOne, updateMany, replaceOne, deleteOne, deleteMany`supported.

```js
b.adminCommand({
    // command name value of 1 signifies that U are issuing a bulkWrite operation
    bulkWrite: 1,
    ops: [ // array contains the list of individual *wirte* operation
        // Insert operation for sample_training.routes
        {
            // which is sample_training.routes in the example
            insert: 0, // corresponds to nsInfo[0]
            
            // This BSON is to be inserted into the specified collection
            document: {
                airline: {
                    id: 413, name: 'American Airlines',
                    alias: 'AA', iata: 'AAL'
                },
                src_airport: 'DFW',
                dst_airport: 'LAX',
                codeshare: '',
                stops: 0,
                airplane: '737'
            }
        },
// Insert operation for sample_analytics.customers
        {
            insert: 1,
            document: {
                accounts: [371138, 324287],
                tier_and_details: {
                    '0df078f33aa74a2e9696e0520c1a828a': {
                        tier: 'Bronze',
                        id: '0df078f33aa74a2e9696e0520c1a828a',
                        active: true,
                        benefits: ['sports tickets']
                    },
                    '699456451cc24f028d2aa99d7534c219': {
                        tier: 'Bronze',
                        benefits: ['24 hour dedicated line'],
                        active: true,
                        id: '699456451cc24f028d2aa99d7534c219'
                    }
                }
            }
        }
    ],
    nsInfo: [ // defines the namespaces that the operations in the 
        // ops array will target
        {ns: "sample_training.routes"},  // Namespace for routes collection
        {ns: "sample_analytics.customers"}
// Namespace for customers collection
    ]
})
```

#### Understanding Cursors - 

Read operations that retrieve multiple documents do not directly provide all documents matching the query at the same time -- cuz a query may match a large number of documents, these yields a cursor. Most of these paradigms enable U to access the results of a query one document at a time. Can store like:

```js
const cursorVariable = db.routes.find();

async function manualIteration() {
    const cursorVariable = db.routes.find();
    while (await cursorVariable.hasNext()) {
        const document = await cursorVariable.next();
        console.log(document);
    }
}
```

##### Returning an array of all documents

Using the `toArray()`method, you can fetch all docuemnt matched by a query into a memory at the same time. This method is straightforward, but U should use it with caution on large data sets due to potential memory constraints.

```js
async function fetchAllDocuments() {
    const cursor = db.routes.find({}).limit(10);
    // toArray to convert the cursor to an array of document.
    console.log(await cursor.toArray());
}

fetchAllDocuments()
```

Employing Mdb Stable API -- 

Mdb offers a Stable API version, which ensures that applications maintian consistent behavior despite updates to the MDB server.  By using Stable API, can specify which version of Mdb API your apps are targeting.

- API version specification -- defines the `apiVersion`parameter in dbs connection settings -- the parameter instructs the MDB server to adhere to the specified API version’s protocols and behaviors.
- Backward compatibility -- Maintains backward compatibility by preserving the behavior of older API verions.
- Isolation from deprecations -- targets a specific API version so that apps are insulated from deprecations and removals in newer Mdb verions.

Fore, by explicitly setting the `apiVersion`-- 

```sh
mongosh "mongodb+srv://YOUR_CLUSTER.YOUR_HASH.mongodb.net/" \
--apiVersion API_VERSION --username USERNAME --password PASSWD
```

## Discipline

1. Write a test
2. Make the compiler pass
3. Run the test, see that it fails and check the error messages is meaningful
4. Write enough code to make the test pass
5. Refactor

Not only does it ensure that you have *relevant tests*, it helps ensure U design good software by refactoring wiht the safety of tests. Seeing the test fail is an important check cuz it also lets U see what the error message looks like. By ensuring your tests are *fast* and setting up your tols so that running tests is simple U can get in to a stable of flow when writing your code.

##### More requirements

Just write a test for a user passing in Spanish -- adding to the existing suite -- 

```go
func TestHello(t *testing.T) {
	assertCorrectMessage := func(t testing.TB, got, want string) {
		t.Helper()
		if got != want {
			t.Errorf("got %q want %q", got, want)
		}
	}
	//... passed tests...

	t.Run("in Spanish", func(t *testing.T) {
		got := test1.Hello("Elodie", "Spanish")
		want := "Hola, Elodie"
		assertCorrectMessage(t, got, want)
	})
}
```

Fix the complication problems by adding another string argument to the `Hello`like:

```go
func Hello(name string, language string) string {
	if name == "" {
		name = "World"
	}
	if language == "Spanish" {
		return "Hola, " + name
	}
	return englishHelloPrefix + name
}
```

The tesets should now pass -- now it is time to just refactor -- should see some problems in the code, *magic* strings, some of which are just repeated. So refactor the `Hello`func just like:

```go
const spanish = "Spanish"
const englishHelloPrefix = "Hello, "
const spanishHelloPrefix = "Hola, "
```

##### French

```go
if language== french {
    return "Bonjour, " + name
}
```

Using `switch`-- when have lots of `if`-- can use the `switch`to refactor the code to make it easier to read and more extensible if we wish to add more language support later like:

```go
func Hello(name string, language string) string {
	if name == "" {
		name = "World"
	}
	prefix := englishHelloPrefix
	switch language {
	case french:
		prefix = frenchHelloPrefix
	case spanish:
		prefix = spanishHelloPrefix
	}
	return prefix + name
}

func TestHello(t *testing.T) {
	t.Run("saying hello to people", func(t *testing.T) {
		got := Hello("Chris", "")
		want := "Hello, Chris"
		assertCorrectMessage(t, got, want)
	})

	t.Run("say hello world when an empty string is supplied", func(t *testing.T) {
		got := Hello("", "")
		want := "Hello, World"
		assertCorrectMessage(t, got, want)
	})

	t.Run("say hello in Spanish", func(t *testing.T) {
		got := Hello("Elodie", spanish)
		want := "Hola, Elodie"
		assertCorrectMessage(t, got, want)
	})

	t.Run("say hello in French", func(t *testing.T) {
		got := Hello("Lauren", french)
		want := "Bonjour, Lauren"
		assertCorrectMessage(t, got, want)
	})
}
```

##### One.. last.. refactor

The simplest refactor for this would be to extract out some functionality into another function.

```go
func Hello(name string, language string) string {
	if name == "" {
		name = "World"
	}

	return greetingPrefix(language) + name
}

func greetingPrefix(language string) (prefix string) {
	switch language {
	case french:
		prefix = frenchHelloPrefix
	case spanish:
		prefix = spanishHelloPrefix
	default:
		prefix = englishHelloPrefix
	}
	return
}
```

#### The TDD process and why the steps are important

- Write a failing test and see it fail so we know we have written a relevant test for our requirements and seen that it produces an easy to understand description of the failure
- Writing the smallest amount of code to make it pass so we know we have working software.
- Then refactor, backed with the safety of our tests to ensure we have well-crafted code that is easy to work with.

### Integers

```go
func TestAddr(t *testing.T) {
	sum := Add(2, 2)
	expected := 4
	if sum != expected {
		t.Errorf("expected '%d' but got '%d'", expected, sum)
	}
}
```

Will notice that we are using the %d as our format strings.

#### Write the minimal amount of code for the test to run and check the failing test outout -- 

Write enough code to satisify the compiler and that’s all-- remember we want to check that our tests fail for the correct reason -- like;

```go
package integers
func Add(x, y int) int {
    return x+y
}
```

For this refactor -- there is not a lot in the actual code we can really improve here -- just explored how by naming the return argument 

##### Examples

If U really want to go th extra mile U can make examples, will find a lot of examples in the documentation of stdlib. Often code examles that can be found outside the codebase, such as a readme file often become out of date and incorrect compared to the actual code cuz they don’t get checked.

Go examples are exeuted just like tests so U can be confident examples reflect what the code actually does. As with typical tests, examples are functions that reside in a package’s `_test.go`files, fore: add a normal function like;

```go
func ExampleAdd() {
    sum := add(1, 5)
    fmt.Println(sum)
    // output: 6
}
```

If your code changes so that the example is no longer valid, your build will fail -- running the package’s test suite, can see the example function is executed with no further arrangement from us.

Note that the example function will note be executed if U remove the comment `// output: 6`-- altough the function will be compiled, it won’t be executed.

Cuz, by adding this code the eample will appear in the documentation inside `godoc`, making your code even mre accesible.

Writte the test first - 

```go
func TestRepeat(t *testing.T) {
    repeated := Repeat("a")
    exected := "aaaaa"
    if repeated != expected {
        t.Errorf(...)
    }
}
```

Writeh the minimal amount of code for the test to run and check the failing test output -- 

```go
package iteration
func Repat(character string) string {
    return ""
}
```

Then write enough code to make it pass just like -- 

```go
func Repeat(character string) string {
    var repeated string
    ....
    return repeated
}
```

#### Benchmarking

Writing *benchmarks* in Go is another first-class feature of the language and it is very similar to writing tests.

```go
func BenchmarkRepeat(b *testing.B) {
    for i:=0; i<b.N; i++ {
        Repeat("a")
    }
}
```

The `testing.B`gives U access to the crypitcally named `b.N`. Then run -- 

```sh
go test -bench=.
```

### Fanning in and out

In Go, a *fan-out* concurrency pattern is when multiple gorotuines read from the same channel, in this way, can distribute the work among a set of goroutines. fore:

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    urls := generateUrls(quit)
    pages := make([]<-chan string, downloaders)
    for i:=0; i<downloaders; i++ {
        pages[i]= downloadPages(quit, ruls)
    }
    // ... fan in
}
```

For the Fan-in, the solution is to only close the common channel when *all* the goroutines have noticed that the channels from which they are consuming have been closed -- we have a separate goroutine that calls `wait()`on this waitgroup, which will have the effect of suspending its execution until all the *fan-in* goroutines are done -- once this goroutine resumes, it will close the output channels.

```go
func FanIn[K any](quit <-chan struct{}, allChannels ...chan K) <-chan K {
    wg := sync.WaitGroup{}
    wg.Add(len(allChannels))
    output := make(chan K)
    for _, c := range allChannels {
        go func(channel <-chan K) {
            defer wg.Done()
            for i:= range channel {
                select {
                case output <-i:
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

#### Flushing results on close -- 

Havn’t really done anything interesting with our RUL download app, apart from extracting the words, what if we use the downloaded web pages for sth useful --  Fore, to implement of `longestWords()`-- use a map to store the set of unique words -- since this map is isolated from our concurrent execution and only our `longestWords()`is accessing it -- do not need to worry about data race conditions.

```go
func longestWords(quit <-chan int, words <-chan string) <-chan string {
    longWords := make(chan string)
    go func() {
        defer close(longWords)
        uniqueWordMap := make(map[string]bool)
        uniqueWords := make([]string,0)
        moreData, word := true, ""
        for moreData {
            select {
            case word, moreData = <-words:
                if moreData && !uniqueWordsMap[word] {
                    uniqueWordsMap[word]=true
                    uniquewords = append(uniqueWords, word)
                }
            case <-quit:
                return
            }
        }
        sort.Slice(uniqueWords, func(a,b int) bool {
            return len(uniqueWords[a]> len(uniqueWords[b]))
        })
        longWords <- strings.Join(uniqueWords[:10], ", ")
    }()
    return longWords
}
```

The goroutine stores all the unique words on a map and a list. Once the input channel closes, meaning there are no more messages, the goroutine sorts the list of unique words by length. Can now connect this new component to our pipeline in the `main()`function -- just like:

```go
func main() {
    quit := make(chan struct{})
    //...
    results := longestWord(quit, extractWords(quit, FanIn(quit, pages...)))
    fmt.Println("Longest words: ", <-results)
}
```

#### Broadcasting to multiple goroutines -- 

What if we want to find out more stats from our download pages -- for this scenairo, say that in addition to finding the longest words, want to find which words occur most frequently.

For ths, will feed the outout of `extractWords()`to two gorotuines, the existing `longestWords()`and an additional one called `frequentWords()`-- the pattern of the new func will be the same as that of `longestWords()`-- It will store the frequency of eah unqiue word, and when the input channle closes, it will output the top 10 most often - occurring words -- Used the fan-out pattern when needed to feed the output of one computation to multiple concurrent goroutines -- load-balanced the messages, with each gorotuine receiving a distinct subset of the output data. Instead of fan-out, can use a broadcast pattern -- one that replicates messages to a set of outout channels.

