# nginx configuration

```sh
nginx -s singal
```

To start nginx, run the executable file, once nginx is started, it can be controlled by invoking the executable with the `-s`parameter. Where the *signal* may be one of the following -- 

- `stop`-- fast shutdown
- `quit`-- graceful shutdown
- `reload`-- reloading configuration file
- `reopen`-- reopening the log files

The need to handle a large number of requests dates back to Nginx’s inception -- it was initially developed to solve the C10K problem -- is the probelm of optimizing netwok sockets to handle a large number of clients at the same time. To do this, Nginx utlizes an event-driven async approach -- which allows it to handle a large number of concurrent requests and still maintain a predictable performance level.

```sh
sudo systemctl start nginx
sudo systemctl status nginx
```

Nginx is a high performance web server developed to facilitate the increasing needs of the modern web. Nginx at its core is a reverse-proxy server. Nginx cames onto the scene after Apache -- with more awareness of concurrency problems that would face sites at scale. Designed form the ground to use an async, non-blocking, event-driven connection handling algorithem.

### The or-channel - 

At times you may find yourself wanting to combine one or more `done`channels into a single `done`chanenl that closes if any of its component close -- it is perfectly accetable, to write a `select`statement that perform this coupling like:

```go
func or(channels ...<-chan any) <-chan any {
	switch len(channels) {
	case 0:
		return nil
	case 1:
		return channels[0]
	}
	orDone := make(chan any)
	go func() {
		defer close(orDone)
		switch len(channels) {
		case 2:
			select {
			case <-channels[0]:
			case <-channels[1]:
			}
		default:
			select {
			case <-channels[0]:
			case <-channels[1]:
			case <-channels[2]:
			case <-or(append(channels[3:], orDone)...):
			}
		}
	}()
	return orDone
}
```

This is a farily concise function that just enables U to combine any number of channels together into a single channel that will close as soon as many of its component channels are closed. just like:

```go
func main() {
	start := time.Now()
	<-or(
		sig(2*time.Hour),
		sig(5*time.Minute),
		sig(time.Second),
	)
	fmt.Printf("done after %v\n", time.Since(start))
}
func sig(after time.Duration) <-chan any {
	c := make(chan any)
	go func() {
		defer close(c)
		time.Sleep(after)
	}()
	return c
}
```

#### Error handling -- 

in concurrent programs -- errorhandling can be difficult to get right -- simetimes, we spend so much time thinking about how our various processes will be sharing info and coordinating - consider how they will gracefully handle errored state. when Go eschewed the poulare exception model of errors, it made a statement that error handling important.

With most fundamental question when thinking about error handling, -- who should be responsible for handling the error. A concurrent process is operating independently of its parent or siblings -- can be difficult for it to reason about what the right thing to do with the error is.

```go
func checkStatus(done <-chan struct{}, urls ...string) <-chan *http.Response {
	response := make(chan *http.Response)
	go func() {
		defer close(response)
		for _, url := range urls {
			resp, err := http.Get(url)
			if err != nil {
				fmt.Println(err)
				continue
			}
			select {
			case <-done:
				return
			case response <- resp:
			}
		}
	}()
	return response
}

func main() {
	done := make(chan struct{})
	defer close(done)
	urls := []string{"https://baidu.com", "https://badhost"}
	for resp := range checkStatus(done, urls...) {
		fmt.Printf("Response: %v\n", resp.Status)
	}
}
```

See that the goroutine has been given no choice in the matter -- can’t simply swallow the error, and so it does the onlysensible thing.. print. Don’t put your goroutines in this awkward position. just like:

```go
func checkStatus(done <-chan struct{}, urls ...string) <-chan Result {
	results := make(chan Result)
	go func() {
		defer close(results)
		for _, url := range urls {
			var result Result
			resp, err := http.Get(url)
			result = Result {err, resp}
			select {
			case <-done:
				return
			case results <- result:
			}
		}
	}()
	return results
}
func main() {
	done := make(chan struct{})
	defer close(done)
	urls := []string{"https://baidu.com", "https://badhost"}
	for result := range checkStatus(done, urls...) {
		if result.Error != nil {
			fmt.Printf("Error: %v\n", result.Error)
			continue
		}
		fmt.Printf("Response: %v\n", result.Response.Status)
	}
}
```

### Best practices for construcing Pipelines

Channels are uniquely suited to constructing pipelines in Go cuz they fulfill of our basic requirements -- they can receive and emit values, can safely be used concurrently, can be ranged over, and are reified by the language.

```go
func generator(done <-chan struct{}, integers ...int) <-chan int {
	intStream := make(chan int)
	go func() {
		defer close(intStream)
		for _, i := range integers {
			select {
			case <-done:
				return
			case intStream <- i:
			}
		}
	}()
	return intStream
}

func multiplier(done <-chan struct{}, intStream <-chan int, factor int) <-chan int {
	multipleStream := make(chan int)
	go func() {
		defer close(multipleStream)
		for {
			select {
			case <-done:
				return
			case i, ok := <-intStream:
				if !ok {
					return
				}
				multipleStream <- i * factor
			}
		}
	}()
	return multipleStream
}

func add(done <-chan struct{}, intStream <-chan int, additive int) <-chan int {
	addedStream := make(chan int)
	go func() {
		defer close(addedStream)
		for i := range intStream {
			select {
			case <-done:
				return
			case addedStream <- i + additive:
			}
		}
	}()
	return addedStream
}
```

```go
func main() {
	done := make(chan struct{})
	defer close(done)
	intStream := generator(done, 1, 2, 3, 4, 5)
	pipeline := multiplier(done,
		add(done, multiplier(done, intStream, 2), 1), 2)
	for v := range pipeline {
		println(v)
	}
}
```

The generator function takes in variadic slice of integers, constructs a buffered channel of integers with a length equal to the incoming integer slice, starts a goroutine, and returns the constructed channel. In a nutshell, the `generator`function converts a discrete set of value into a stream of data on a channel. This pipeline is similar to our pipeline utilizing functions in the prefious -- but it is different in very important ways -- 

- Using channels -- significatn cuz it allows two things -- at the end of our pieplein, can use a range statement to extracts the values, and each stage can safely execute concurently -- cuz our inputs and outputs are safe in concurrent contexts
- Each stage of pipeline is executing concurrently

#### Fanning in and out -- 

In example, if want to speed things up, can perform downloads concurrently by load-balancing the URLs to multiple goroutines, can create a fixed number of goroutines, each reading from the same RUL input channel -- each one of the goroutines will receive a seprate URL from the `generateUrls()`, then can perform the downloads concurrently. just:

```go
func main(){
    quit := make(chan int)
    defer close(quit)
    urls := generateUrls(quit)
    pages := make([]<-chan string, 20) // fore, 20 goroutines
    for i:=0; i<20; i++ {
        pages[i]=downloadPages(quit, urls)
    }
    //...
}
```

For this, the fan-out pattern in our app has created a problem -- the outputs of our download goroutines are in separate channels -- can conenct them to a single input channel of our next stage -- the `extractWords()`-- To just keep the pattern, need a mechanism that merges the output messages from the different channels into a signle output channel.

In Go -- a *fan-in* concurency pattern occurs when we merge the content from multiple channels into one -- since gorotuiens are just very lightweight, can implemen this fan-in pattern as a single unit by creating a set of goroutines -- one per output channel, and having each goroutine feed a common channel like: Having multiple goroutines all feeding into a single common channel creates a problem - *Many-to-one fan-in* scenario -- must make a decision about when to close the common channel. If continue with the same approach of closing the channel when a goroutine notices that the channel it’s consuming from has been closed, we might end up closing the channel too soon.

The solution is to only close the common channel when *all* the goroutines have noteiced that the channels from which they are consuming have been closed. Using `WaitGroup`like:

```go
func FanIn[K any](quit <-chan struct{}, allChannels ...chan K) chan K {
    wg := sync.WaitGroup{}
    wg.Add(len(allChannels))
    output := make(chan K)
    for _, c := range allChannels {
        go func(channel <-chan K) {
            defer wg.Done()
            for i:= range channel {
                select {
                case output <- i:
                case quit:
                    return
                }
            }
        }(c)
    }
    go func(){
        wg.Wait() // truely fanin
        close(quit)
    }
    return output
}
```

### Testing HTML forms

For this, going to add an end-to-end test for `POST /user/signup`route, which is handled by our `userSignupPost`handler -- testing this route is made a bit more complicated by the anti-CSRF check that our application does -- any request that we make to `POST /user/signup`will always receive a 400 response unless the request contains a valid CSRF token and cookie.

