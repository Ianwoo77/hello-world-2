# Pull Requests (Merge requests)

At the start of this, you should have two local repositories called `rainbow`and `friend-rainbow`and one remote repository called `rainbow-remote`- All three of these repositories should be in sync -- with the same commits and branches.

### Introducing Pull Requests

A *pull request* also referred as a merge request -- is a feature offered by hosting service that allows U to share work U have done on a branch with your collborators -- potentially gather feedback on that work, and finally integrte that work into the project remotely on the hosting service. Although pull requests are not a feature of Git but of the *hosting services* that host projecting using Git.

Pull requests can be integrated by merging or rebasing. The default option is merging. When create a pull request, May say that U *open* a pull request. Once the pull request has been reviewed, approved, and merged, you close it. May also close a pull request if you decide not to merge it and you want to remove it from the list of open pull requests.

1. create a branch in local repo
2. Add work by making commits on the branch
3. Push the branch
4. Create (or open) a pull request in the hosting service.
5. Get the pull request reviewed and potentially incorporate any feedback from other people into the pull request.
6. Get the pull request approved
7. Mrege the pull request
8. if it is topic branch (feature branch), delete the remote branch.
9. Pull the changes to sync your local repo with the remote repository, and clean up by deleting the local branch and remote-tracking branch.

#### Hosting service specifics

The specific steps for creating and managing pull requests with GitHub... are different, Terminology may also differ between hosting services, notably, while GitHub uses the term *pull request*.

When walked through choosing a host service and setting up HTTPs or SSH access, recommended that u use a personal hosting service account rather than a company account. This is cuz it is possible to configure additional settings in a hosting service for the pull request creation and approval process.

Why use Pull requests -- Facilitate communication and collboration on git projects by providing an easy mechanims to review work. They have useful commenting feature that allows U and your collborators to add comments to specific lines in the files of a proj. Respond to these comments, and start disucssion threads. Since pull requests are manged entirely in the hosting service UI, they also allow non-Git users to provide feed back on Git projects.

Fore, make a branch off the `main`called `ch9`to work on ch9 of book, make two commits to that branch, fore, W and X, then push to remote, createing a remote `ch9`. I have agreed with my editor that they must review my work before I merge it into the `main`. One option for them to clone the remote repository on their local computer and check out the branch there, in order to view my updated file - this doesn’t give them a easy way of providing me with feedback and comments. Also, assume that my editor hasn’t yet learned how to use Git.

Just make sure that my editor has access ot the remote repository, then will make a pull request in the remote repository to mrege the remote ch9 branch into the remote `main`branch. Can either send my editor the URL to pull request or simply tell them to go to the remote repository and find the pull request titled *ch9 updated*.

Then editor can then use the commenting feedback to ask questions.. After fixing the issue in the chapter in my local repository, make anothercommit on the local branch and push it to the remote. The fact that I made the pull request makes it easy for my editor to provide me with feedback on my project.

## Communication using mesage passing

- Exchanging messages fro thread communication
- Adopting Go’s channel for message passing
- Collecting async results using channels
- Building our own channels

This will serve as an introduction to programming concurrency using an abstraction that takes ideas from a CSP.

### Passing messages

The advantage of using message passing is that we greatly reduce the risk of causing RC with our bad programming. A Go Channel lets two or more goroutines exchange messages. What would happen if a goroutine were to push a message without there being another goroutine to read the message -- *Go’s channel are sync* by default -- Meaning that the sender will block until there is a receiver.

#### Buffering messages with channels

Although channels are sync, can configure them so that they store a number of messages before they block, when use a buffered channel -- Whenever a sender goroutine writes a message without any receiver consuming the message, the channel will store the mesage. Once the buffer is filled up, the sender will block again. Once the receiver goroutine consumes all the messages and the buffer is empty, the receiver will again block.

```go
func receiver(messages chan int, wGroup *sync.WaitGroup) {
	msg := 0
	for msg != -1 {
		time.Sleep(time.Second)
		msg = <-messages
		fmt.Println("received:", msg)
	}
	wGroup.Done()
}
func main() {
	msgChannel := make(chan int, 3)
	wGroup := sync.WaitGroup{}
	wGroup.Add(1)
	go receiver(msgChannel, &wGroup)
	for i := 1; i <= 6; i++ {
		size := len(msgChannel)
		fmt.Printf("%s sending: %d, Buffer size: %d\n",
			time.Now().Format("15:04:05"), i, size)
		msgChannel <- i
	}
	msgChannel <- -1
	wGroup.Wait()
}
```

Just note that we can check how many messages are on the buffer using `len(buffer)`, for this, just get a faster sender that is trying to send 6 messages, since we have a much slower receiver, the `main`goroutine will fill the channel buffer with three and then block.

#### Assigning a direction to channels

Go’s channels are *bidirectional* by default, this means that a goroutine can act as both a receiver and a sender of messages. Can assign a direction to a channel so that the goroutine using the channel can only send or receive messages -- 

#### Closing Channels

In Software development, a *sentinel* value is a predefined value that signals to an execution, a process, or an algorithm that it should terminate. Once we *close* a channel, we shouldn’t send any more message to it cuz doing so raises. However, using the deafult value is not ideal cuz the default value might be just a valid valud for our use case. Go just gives us a couple of ways to handle closed channels, whenever we consme -- this flag is set to `false`only when the channel has been closed. The following listing shows how can modify the recevier functin like:

```go
func receiver(message <-chan int) //...
func main() {
	msgChannel := make(chan int, 3)
	go receiver(msgChannel)
	for i := 1; i <= 6; i++ {
		size := len(msgChannel)
		fmt.Printf("%s sending: %d, Buffer size: %d\n",
			time.Now().Format("15:04:05"), i, size)
		msgChannel <- i
	}
	close(msgChannel)
}
```

#### Receiving function results with channels

Can execute functions concurrently in the background and then collect their resutls via channels once they finish. Typically, in normal sequential programming, we call a function and expect it to return a result. In concurrent programming, can call functions in separate goroutines and later pick up their return values from the output channel.

### Selecting Channels

How can we have one goroutine respond to messages coming from different goroutines over mutliple channels -- Go’s `select`statement lets us specify mutliple channel operations as separate cases and then execute a case depending on which channel is ready -- 

#### Reading from mutliple channels

Once a message arrives on any of the channels, the goroutine is unblocked, and a code handler for that channel is run, can then decide waht else to do -- either continue with our execution, or go back and wait for the next message by using the `select`statement again.

Channels are just first-class objects, which means that we can store them as variables, pass or return them from fucntions, or evensend them on a channel. Fore:

```go
func main() {
    messageFromA := writeEvery("tick", time.Second)
    messageFromB := writeEvery("tock", 3*time.Second)
    for {
        select {
        case msg1:= messageFromA:
            fmt.Println(msg1)
        case msg2 := messageFromB:
            fmt.Println(msg2)
        }
    }
}
```

#### Using select for non-blocking channel operations

Another use case for `select`is when need to use channels is a non-blocking manner -- The `select`just gives us the *default* case for exactly this scenairo -- the instructions under the default case will be executed if none of the other cases is available.

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		time.Sleep(seconds)
		messages <- "Hello"
	}()
	return messages
}
func main() {
	messages := sendMsgAfter(3 * time.Second)
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

#### Performing concurrent computations on the default case

A useful scenario is to use the default select case for concurrent computations 

```go
const (
	passwordToGuess="go far"
	alphabet = "abcdefghijklmnopqrstuvwxyz"
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

The number of possible strings from a to zzzzzz, including 27^6-1 so just like before. And, to find the pwd faster, can divide the range of our guesses among several goroutines. And to avoid unnecessary computations, we want to stop the execution of each goroutine when any gorutine makes a correct guess.

## Testing HTTP handlers and middlware

Move on and discuss some specific techniques for unit testing your HTTP handlers -- all the handlers that written for this to far -- and to introdcue things -- in the `handlers.go`file and create a new ping handler function that will returns a 200 ok status code and an `OK`response body -- like:

```go
func ping(w http.ResponseWriter, r *http.Requests) {
    w.Write([]byte("OK"))
}
```

For this, create a new `TestPing()`unit test which -- 

- Checks that the response status code written by `ping`handler is 200
- checks that the respons body is OK

#### Recording responses

To assist in testing your HTTP handlers, Go provides the `net/httptest`package, which contains a suite of useful tools -- one of these is the `httptest.ResponseRecorder`type -- This is essentially an implementation of `http.ResponseWriter`which records the response status code, headers and body instead of actually writting them to an HTTP conenction.

So an easy way to unit test your handler is to create a new `httptest.RespsonseRecorder`object, pass it to the handler function, and then examine it again after the handler returns.

```go
func TestPing(t *testing.T) {
    // Initialize a new httptest.ResponseRecorder
    rr := httptst.NewRecorder()
    
    // Initialize a new dummy http.Request
    r, err := http.NewRequest(http.MethodGet, "/", nil)
    if err != nil {
        t.Fatal(err)
    }
    
    ping(rr, r)
    
    // Call the `Result()` on the http.ResponseRecorder to get the result
    rs := rr.Result()
    
    // Check that the status code written by ping handler was 200.
    assert.Equal(t, rs.StatusCode, http.StatusOk)
    
    defer rs.Body.Close()
    body, err := io.ReadAll(rs.Body)
    if err != nil {
        t.Fatal(err)
    }
    bytes.TrimSpace(body)
    assert.Equal(t, string(body), "OK")
}
```

### Testing middleware

It’s also possible to use the sme general pattern to unit test your middleware -- Demonstrate how by creating a new `TestSecureHeaders`test for the `secureHeadlers()`middleware -- 

- The `secureHeaders()`middleware sets all the expected heders on the HTTP response.
- The `secureHeaders()`correctly calls the next handler in the chain.

```go
func TestSecureHeader(t *testing.T) {
	// Initialize a new httptest.ResponseRecorder and dummy http.Request objects.
	rr := httptest.NewRecorder()

	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Create a mock http handler that we can pass to our secureHeaders middleware
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})

	// Pass the mock handler to our secureHeaders middleware, like:
	secureHeaders(next).ServeHTTP(rr, r)

	// Call the Result() method on the http.ResponseRecorder to get the results
	rs := rr.Result()

	// Check that the middleware has correctly set the Content-Security-Policy header
	expectedValue := "default-src 'self'; style-src 'self' fonts.googleapis.com; font-src fonts.gstatic.com"
	assert.Equal(t, rs.Header.Get("Content-Security-Policy"), expectedValue)

	// Check that the middleware has correctly set the Referrer-Policy header
	expectedValue = "origin-when-cross-origin"
	assert.Equal(t, rs.Header.Get("Referrer-Policy"), expectedValue)

	// Check the middleware has correctly set the X-Content-Type-Options
	expectedValue = "nosniff"
	assert.Equal(t, rs.Header.Get("X-Content-Type-Options"), expectedValue)

	// Check that the middleware has correctly set as X-Frame-Options header
	expectedValue = "deny"
	assert.Equal(t, rs.Header.Get("X-Frame-Options"), expectedValue)

	// Check that the middleware has correctly set the X-XSS-Protection header
	expectedValue = "0"
	assert.Equal(t, rs.Header.Get("X-XSS-Protection"), expectedValue)

	// Check the output
	assert.Equal(t, rs.StatusCode, http.StatusOK)

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)
	assert.Equal(t, string(body), "OK")
}
```

### End-to-end testing

Most of the time, your HTTP handlers aren’t actually used in isolation, so in this going to explain how to run the end-to-end tests on your web application that encompass your routing, middleware and handlers. End-to-end testing should give U more confidence that your app is working correctly then unit testing in isolation.

#### Using the `httptest.Server`

The key to end-to-end testing our app is the `httptest.NewTLSServer()`function, which spins up a `httptest.Server`instance that we can make HTTPs requests to. The whole pattern is a bit too complicated to exaplin -- probably best to demonstrate by just writing the code and then details --  Update the `TestPing`like:

```go
func TestPing(t *testing.T) {
	// Create a new instance of our app struct, just contains two mock loggers
	app := &application{
		errorLog: log.New(io.Discard, "", 0),
		infoLog:  log.New(io.Discard, "", 0),
	}

	// then use the httptest.NewTLSServer() to create a new test server
	// this will start up a HTTPs server which listens on random-chosen port of local
	// machine for the duration of the test, also note the defer close
	ts := httptest.NewTLSServer(app.routes())
	defer ts.Close()

	// Then the network address that the test server is listening on is contained in
	// the ts.URL field, can use this along with the ts.Client().Get()
	rs, err := ts.Client().Get(ts.URL + "/ping")
	if err != nil {
		t.Fatal(err)
	}

	assert.Equal(t, rs.StatusCode, http.StatusOK)

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)
	assert.Equal(t, string(body), "OK")
}
```

