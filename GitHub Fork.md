# GitHub Fork

Github fork -- lets contributors copy the source code repository locally and make any changes they would like. Once U get the local copy of the code, you can make the revelant changes and ask the React community to review your changes -- After reviewing your code changes, the React community may approve them or as you more changes.

### Programming with Channels

- Introducing communicating sequential processes
- Reusing common channel patterns
- Taking advantage of channel being first-class objects

Working with channels just requires a different way of programming than when using memory sharing. The idea is to have a set of goroutines, each with it own internal state, exchanging info with other goroutines by passing messages on Go’s channels. Since memory sharing is more prone to race conditions and requires complex sync techniques, should avoid it when possible and intend use message passing.

### Communication sequential processes

Programming with a low level mdoel of concurrncy means that as programmers, we need to work harder to manage the complexity and reduce bugs in our software -- don’t know when a thread of execution will be scheuled by the OS, and this creates a non-deterministic environment -- instructions are interleaved without us knowing behorehand the order of execution. This non-determinism -- combined with memory sharing, creates the potential for race conditions.

#### Avoiding interference with immutability -- 

One way to greatly reduce the risk of RC is not allow our programming to modify the same memory from multiple concurrent executions. Immutable literally means unchangeable. If our threads of execution only share memory containing data that is never updated, can rest assured that there are no data race conditions. After all, most race conditions happen cuz multiple executions write to the same memory locations at the same time.

#### Concurrent programming with CSP

A different, higher-level model of cncurrency was proposed by CAR -- CSP -- Instead of using nemory sharing, it is based on message passing via channels. In CSP, processs communicate with each other by exchanging copies of values -- communiation is done through named *unbuffered* channel. The key difference when using the CSP model is that executions are not sharing memory -- instead, they pass copies of data to each other.

### Reusing common patterns with channels

- Try not only pas copie of data on channels. This implies that you shouldnt’ direct pointers on channels in most cases, Passing pointers can result in multiple goroutines sharing memory, which can create RC.
- As much as possible try not to mix message passing patterns with memory sharing.

#### Quitting Channels

The first pattern examine is having a common channel that instructs goroutines to stop processing mesages. using `close(channel)`call to notify a goroutine that no more messages are coming. But what should we do if our goroutine is consuming from more than one channel -- One solution is to use quit channel together with the `select`statement. 

NOTE -- are just passing *Cipies* of the numbers on the channel, not sharing any memory cuz the goroutiens has its own isolated memory space.

#### Pipelining with channels and goroutines

Generate URLs of web pages that can download later -- Can have a goroutine generate several URLs and send them on a channel to be consumed -- can simply print out the URLs on the console from the `main`, once done, the groutine generating the URLs will close the output channel to notify the `main()`that there aren’t any more web pages to process. `generateUrls()`-- creates a gorotuine that generates URL strings on an output channel. The ouput channel is returned by the function. The function also accepts a quit channel -- which it listens to in case it needs to stop generating ULRs earlier.

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

next, complete this by writing the `main`-- like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	
	results := generateUrls(quit)
	for result:= range results {
		fmt.Println(result)
	}
}
```

Next, just write the logic to download the content of these pages -- just need a goroutine that accepts a stream of URLs and output the text content into another output stream -- this goroutine can be plugged into the output of the `generteUrls()`goroutine and the input of the `main()`like: The gorutine checks to see whether the input channel is still open by reading the `moreData`boolean flag like:

```go
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

Are passing a copy of the web document on the channel. Can do this since the web pages are only a few KB in size. Using message passing for large objects, such as images or video, in this fashion might have a detrimental effect on performance. So, using a memory-sharing architecture might be more suitable.

Can now connect this new goroutine to our pipeline easily since it accepts the same channel datatype as the output of the `generateUrls()`function. It also returns the same output channel datatypes as the one `main`can use.

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

When use the preceding `main`-- Following this pattern of accepting the input channel as a function input parameter and returning the ouput channel makes building pipelines easy -- just need to create a new goroutine that extracts the words and then connect it to our pipeline.

Then implement the `extractWords()`function -- the same pattern as for `downloadPages()`used -- accepts an nput channel containing texts, and it returns an output channel containing all the words found in the received texts.

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
					for _, word := range wordRegex.FindAllString(pg, -1) {
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

Again, just modify our `main`to include this new goroutine in our pipeline, Each function in the pipeline is a goroutine that takes the `quit`channel and an input channel and returns an output channel that results are sent to. Using the `quit`channel will later allow us to control the flow of different parts of the pipeline.
`results := extractWords(quit, downloadPages(quit, generateUrls(quit)))`

#### Fanning In and out

In the app, if we want to speed things up, can perform the downloads concurrently by load-balancing the URLs to multiple goroutiens -- can create a fxied number of goroutines, each reading from the same URL input channel, each one of the goroutines will receive a separate URL from the `generateUrls()`goroutine, and they can perform the downloads concurrently -- 

In Go -- Fan-out -- means when multiple goroutines read from the same channel, can distribute the work among a set of goroutines. When multiple goroutines read from just one channel -- In this situation -- the concurrent gorouines are *load-balancing* the URLs sent from the `generateUrls()`goroutine -- when a `downloadPage()`goroutine is free, it will read the next URL from the shared input channel. This is similar to having multiple baristas.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
    
    // create a slice to store output channels from the download goroutines
	pages := make([]<-chan string, downloaders)
    
    // creates 20 goroutines download web pages and stores the output channels.
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}
    // ...
}

```

So the  fan-out pattern in our app has created a problem -- the outputs of our download goroutines are in separate channel -- how can we connect them to the single input channel of our next stage -- for `extractWords()`goroutine -- to keep the pattern, Just need a mechanism that merges the output messages from the different channels into a single output channel -- Can plug the single output channel into the `extractWords()`called *fan-in* pattern like -- occurs when we merge the content from multiple channels into one.

Since goroutines are very lightweight, can implement this fan-in pattern as a single unit by creating a set of goroutines, one per output channel, and having each gorouine feed a common channel.

For this, having multiple goroutines all feeding into a single common channel creates a problem -- when have a one-to-one -- simply -- when many-to-one -- must make a dicision about just *when to close the common channel*.

The solution is to only close the common when *all* the goroutines have noticed that the channel from which they are consuming have been closed. Each goroutine in the fan-in group marks the waitgroup as done after it has sent its last mesage.

```go
func FanIn[K any](quit <-chan struct{}, allChannels ...<-chan K) chan K {
	wg := sync.WaitGroup{}
	wg.Add(len(allChannels))
	output := make(chan K)
	for _, c := range allChannels {
		go func(channel <-chan K) {
			// once the goroutine terminates, mask the wg done
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

	go func() { // in other goroutine
		wg.Wait()
		close(output) // wait for all goroutines to finish then close output
	}()
	return output
}
//...
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
		println(result)
	}
}
```

When run this new, it runs a lot faster cuz the downlods are being performed just concurrently.

#### Flushing results on close

We haven’t really done anything interesting with our URL download application -- apart from extracting the words. For Fan-out -- involves distributing a single input to multiple worker goroutiens to parallel processing, imagine a fan spreading air outwards -- Fan-out involves distributing a single input to multiple worker goroutins for parallel procesing -- 

- Create mutiple channels one for each worker gorouine
- send the input data to each
- Each receives data from its dedicated channel, processes and sends the result like:

```go
func fanOut(input []int, numWorkers int) <-chan int {
	output := make(chan int)
	go func() {
		defer close(output)
		for _, n := range input {
			for j := 0; j < numWorkers; j++ {
				go func (num int) {
					out <- process(num)
				}(n)
			}
		}
	}()
	return output
}
func process(num int) int{
    return num*2
}
```

## Parallel testing

By default, `go test`command executes all tests in a serial manner, one after another, when U have a small number of test and the runtime is very fast, this is absolutely fine -- but if U have many tests the total run time start adding up to sth more meaningful -- may save yourself some time by running your tests in parallel.

```go
func TestPing(t* testing.T) {
    t.Parallel()
}
```

- Tests markedusing `t.Parallel()`will be run in parallel with -- and only with - other parallel tests

- By default, the maximum number of tests that will be run simultaneously is the current value of `GOMAXPROCS`.

  ```sh
  go test -parallel 4 ./...
  ```

#### Enabling the race detector

The `go test`command incldues a `-race`flag which enables Go’s *race detector* when running tests. And if the code you are testing leverages concurrency, or you are running tests in parallel -- enabling this can be a good idea to help to flag up race conditions that exist in app -- `go test -race ./cmd/web`

### Mocking dependencies

In this we are going to get a bit more serious and write some tests for our `snippetView`handler and `GET /snippet/view/:id`route -- Throughout this proj, injected dependencies into our handlers via the `application`struct -- when testing, it sometimes makes sense to *mock* these dependencies instead of using *exactly* the sme ones that you do in your app.

The reason for mocking thse and writing to `io.Discard`is to avoid clogging up our test output with unnecessary log messages when run `go test -v`-- The other two dependencies that it makes sense for us to mock are the `models.SnippetModel`and `models.UserModel`dbs models. By creating mocks of these it’s possible for us to test the behavior of our handlers without needing to set up an entire test instance of SQL dbs.

#### Mocking the dbs models

Create a new internal/models/mocks containing `snippets.go`and `user.go`files to hold the dbs model mocks like:

```go
var mockSnippet = &models.Snippet{
	ID:      1,
	Title:   "An old silent pond",
	Content: "An old silent pond...",
	Created: time.Now(),
	Expires: time.Now(),
}

type SnippetModel struct{}

func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	return 2, nil
}
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	switch id {
	case 1:
		return mockSnippet, nil
	default:
		return nil, models.ErrNoRecord
	}
}

func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	return []*models.Snippet{mockSnippet}, nil
}
```

Create a struct which implements the same methods as our production, but have the methods return some fixed dummy data instead.

```go
type UserModel struct{}

func (m *UserModel) Insert(name, email, password string) error {
	switch email {
	case "dupe@example.com":
		return models.ErrDuplicateEmail
	default:
		return nil
	}
}

func (m *UserModel) Authenticate(email, password string) (int, error) {
	if email == "alice@example.com" && password == "pa$$word" {
		return 1, nil
	}
	return 0, models.ErrInvalidCredentials
}

func (m *UserModel) Exists(id int) (bool, error) {
	switch id {
	case 1:
		return true, nil
	default:
		return false, nil
	}
}
```

#### Initializing the mocks 

For the next step in the build, head back to the `testutils_test.go`and update the `newTestAppliation()`function so that it creates an application struct with all the ncessary dependencies for testing -- like:

```go
type SnippetModelInterface interface {
	Insert(title, content string, expires int) (int, error)
	Get(id int) (*Snippet, error)
	Latest() ([]*Snippet, error)
}

type UserModelInterface interface {
	Insert(name, email, password string) error
	Authenticate(email, password string) (int, error)
	Exists(id int) (bool, error)
}

// in the main.go
type application struct {
	errorLog       *log.Logger
	infoLog        *log.Logger
	snippets       models.SnippetModelInterface
	users          models.UserModelInterface
	templateCache  map[string]*template.Template
	formDecoder    *form.Decoder
	sessionManager *scs.SessionManager
}
```

We have updated the `application`struct so that instead of the `snippets`and `users`fields hving the concrete types `*models.SnippetModel`and `*Model.UserModel`they are interfaces instead.
