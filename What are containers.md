# What are containers

The industry standard today is to use VMs to run software apps. VMs run apps inside a guest OS, which runs on virtual hardware poweredy by the server’s host OS.

VMs are great at providing full process isolation for apps there are vey few ways a problem in the host os can affect the software running in the guest OS. This isolation comes at great cost -- containers take a different approach, by leveraging the low-level mechanisics of the host os, containers provide most of isolation of virtual machines at a fraction of the computing power.

Whay use that -- Container offers a logical packaing mechanism in which apps can be abstracted from the environment in which they actuall run. This decoupling allows container-based apps to be depolyed easily and consistently.

Fan-out and Fan-in is a powerful concurrency pattern in Go where U distribute work acorss multiple goroutines and then collect the results back into a single channel -- this pattern is useful for parallelizing tasks and improving perforance like:

```go
func fetchData(url string) ([]byte, error) {
    resp, err := http.Get(url)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()
    return io.ReadAll(resp.Body)
}

func main {
    urls := []string {
        "http://..."
        //...
    }
    
    // Fanout - create worker goroutines
    inputChan := make(chan string)
    outputChan := make(chan []byte)
    var wg sync.WaitGroup
    for range urls {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for url := range inputChan {
                data, err := detchData(url)
                if err != nil {
                    //...
                    continue
                }
                outputChan <-data
            }
        }()
    }
    
    // send urls to worker
    go func() {
        for _, url := range urls {
            inputChan <- url
        }
        close(inputChan)
    }
    
    // fan-in collect results
    go func() {
        wg.Wait()
        close(outputChan)
    }
    
    // process
    for data := range outputChan {
        //...
    }
}
```

In Go, a *fan-out* concurrency pattern is when multiple goroutines read rom the same channel, in this way, can distribute the work among a set of goroutines. just Like:

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    
    urls := generateUrls(quit)
    pages := make([]<-chan string, downloaders)
    for i:=0; i<20; i++ {
        pages[i]= downlaodPages(quit,urls)
    }
}
```

Namely, can fan out the URLs to multiple `downloadPage`goroutiens -- each doing a different download, in the example, the concurrent goroutines are load-balancing the URLs sent from the `generateUrls()`goroutine. When a `downloadPage()`is free, will read the next URL from the shared input channel.

The fan-out pattern in the app has created a problem -- the ouputs of our download goroutines are in separate channels, how can we connect them to the single input channel of our next stage -- To keep this pattern, just need a manism that merges the output messages from the different channel into a single output channel. Fan-in concurrency occurs when we merge the content form multiple channels into one.

Since gorutines are just lightweight, can implement this fan-in pattern as a single unit by creating a set of goroutines, one per output channel, and having each goroutien feed a common channel. It simply forwards it to the common channel. When have a many-to-one fan-in scenario, must make a decision about when to lose the common channel. If continue with the same apporach of closing the channel when a goroutine notices that the channel it’s consuming from has been closed, might end up closing the channel too soon. Just like:

```go
func FanIn[K any](quit <-chan int, allChannels ...<-chan K) chan K {
    wg := sync.WaitGroup{}
    wg.Add(len(allChannels))
    output := make(chan K)
    for _, c := range allChannels {
        go func(channel <-chan K) {
            defer wg.Done()
            for i:= range channel {
                select{
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
}
```

### Flushing results on close

Haven’t really done anything interesting with our URL download application -- apart from extracting the words. What if we use the downloaded web pages for something useful -- trying to find 10 longest words fore -- This taks is easy if we continue to follow our pipeline-building pattern -- just need to add a new goroutine that accepts an input channel and returns an outpout one -- called fore `longestWords()`-- 

This new is slightly different from the others -- accumulates a set of unique unique words in its memory -- once read all the words -- will review this set and output. First, need a map to store the set of unique words, since this map is isolated from our concurrent execution and only our `longestWords()`is accessing it, do not need to worry about datarace conditions. FORE:

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
		
		sort.Slice(uniqueWords, func(a,b int) bool {
			return len(uniqueWords[a]) > len(uniqueWords[b])
		})
		longWords <- strings.Join(uniqueWords[:10], ", ")
	}()
	return longWords
}
```

The gorotuine stores all the unique words on a map and a list, once the input channel closes, meaning there are no more messages, the goroutine sorts the list of unqiue words by length. Can now connect this to our pipeline in the `main`function -- in the following like:
`results := longestWords(quit, extractWords(quit, FanIn(quit, pages...)))`

#### Broadcasting to multiple goroutiens -- 

What if want to find out more stats from our download pages -- say in addition to finding the longest words, want to find which words occur most frequently -- For this scenaio, feed the output of `extractWords()`to two goroutines -- the existing `longestWords()`and an additional one may be called `frequentWords()`-- the pattern of the new function will be the same as that of `longestWords`-- and it will store the frequency of each unique word, and when the input channel closes, will output the top 10 most often-occuring words -- 

Should use the `fan-out`when needed to feed the output of one computation to multiple concurrent goroutines -- That pattern will not work here -- since we need to send a copy of each output message to both the `longestWords()`and `frequentWords()`goroutines.

Instead of fan-out, can use a broadcst pattern -- one that replicates messages to a set of output channels -- shows how we can use a separate goroutine that broadcasts to multiple channels.

#### Copying or Broadcasting a channel in Go

While U can’t directly copy a channel in Go -- can achieve smilar behavior by broadcasting its values to multiple consumers -- this allows U to distribute the same data to different parts of your program concurrently. Here are two common approaches to acheieve this -- 

To implement this utility, need to create a list of output channels and then use a gorotuine that writes every received message to each channel like:

```go
func Broadcast[K any](quit <-chan struct{}, input <-chan K, n int) []chan K {
	outputs := createAll[K](n)
	go func() {
		defer closeAll(outputs...)
		var msg K
		moreData := true
		for moreData {
			select {
			case msg, moreData = <-input:
				if moreData {
					for _, output := range outputs {
						output <- msg
					}
				}
			case <-quit:
				return
			}
		}
	}()
	return outputs
}

func createAll[K any](n int) []chan K {
	channels := make([]chan K, n)
	for i, _ := range channels {
		channels[i] = make(chan K)
	}
	return channels
}

func closeAll[K any](channels ...chan K) {
	for _, output := range channels {
		close(output)
	}
}
```

NOTE -- in the broadcast imp -- read the next message only after the current message has been sent to all the channels. A slow consumer from this broadcast would slow all consumers to the same rate. Can now write our `frequentWords()`-- will identify the top 10 most frequently occurring words in our downloaded pages, the implementation shows -- like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	words := extractWords(quit, FanIn(quit, pages...))
	wordsMulti := Broadcast(quit, words, 2)
	longestResults := longestWords(quit, wordsMulti[0])
	frequentResults := frequentWords(quit, wordsMulti[1])
	fmt.Println("Longest words:", <-longestResults)
	fmt.Println("Frequent words:", <-frequentResults)
}
```

Since both the `longestWords`and `frequentWords()`goroutine output only one message containing the results, our `main()`function can just consume one message from each and print it on the console, the following.

### Testing the snippetView handler

With that all now set up, get stuck into writing an end-to-end test for our snippetView handler which uses these mocked dependencies -- like: want to check that the request body *contains* some specific content, rather than being exactly equal to it quickly add a new `StringContains`function to our `assert`package to help with that like:

```go
func StringContains(t *testing.T, actual, expectedSubstring string) {
	t.Helper()
	if !strings.Contains(actual, expectedSubstring) {
		t.Errorf("got: %q; want substring: %q", actual, expectedSubstring)
	}
}
```

Then, in the `handlers_test.go`file, create a new `TestSnippetView`test like -- 

```go
func TestSnippetView(t *testing.T) {
	// create a new instance of our app struct which uses the mocked
	app := newTestApplication(t)

	// Establish a new test server for running end-to-end tests
	ts := newTestServer(t, app.routes())
	defer ts.Close()

	tests := []struct {
		name     string
		urlPath  string
		wantCode int
		wantBody string
	}{
		{
			name:     "Valid ID",
			urlPath:  "/snippet/view/1",
			wantCode: http.StatusOK,
			wantBody: "An old silent pond...",
		},
		{
			name:     "Non-existent ID",
			urlPath:  "/snippet/view/2",
			wantCode: http.StatusNotFound,
		},
		{
			name:     "Negative ID",
			urlPath:  "/snippet/view/-1",
			wantCode: http.StatusNotFound,
		},
		{
			name:     "Decimal ID",
			urlPath:  "/snippet/view/1.23",
			wantCode: http.StatusNotFound,
		},
		{
			name:     "String ID",
			urlPath:  "/snippet/view/foo",
			wantCode: http.StatusNotFound,
		},
		{
			name:     "Empty ID",
			urlPath:  "/snippet/view/",
			wantCode: http.StatusNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			code, _, body := ts.get(t, tt.urlPath)
			assert.Equal(t, code, tt.wantCode)
			assert.Equal(t, code, tt.wantCode)
			if tt.wantBody != "" {
				assert.StringContains(t, body, tt.wantBody)
			}
		})
	}
}
```

