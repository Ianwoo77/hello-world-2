# Why use Pull requests

Pull requests facilitate communication and collaboration on Git projects by providing an easy mechanism to review work. They have a useful commenting feature that allows U and your collaboraors to add comments to specific lines in the files of a project, respond to these comments, and start disscussion threads.

This may means they need to review the new Ch9 branch -- one options for them to clone the remote repository on their local computer and check out the branch here, in order to view my updated file. Instead, I will make sure my editor has access to the remote repository, then make a pull request in the remote repository to merge the remote branch into the remote `main`.

My editor can then use the commenting feature to ask questions and provide feedback, suppose they notice an inconsistency in the chapter that need to fix, so they just leave a comment in the *pull request* and let me know that should review their feedback.

### Understanding how pull requests are merged

There are 2 types of merges in git -- FF and 3-way. By default, merging remotely is differen from merging locally. The default setting for most hosting service is that a remote merge with a pull requst happens with a merge option called *non-fast-fowrard* -- even if development histories of the source branch and the target branch *has not* diverged, a merge commit iwll still be made.

Merges made with the non-fast-forward options are ssometimes referred to as *explicit* merge. After my editor reviews the latest work that I pushed to the remote branch -- which is represented by commit Y -- no longer have any more feedback fro me -- this means that I can merge the remote branch into the remote main branch by selecting the button on the merge the pull request. Note that even thouth the development histories of the remote Ch9 and the remote `main`has not diverged, a merge commit will still be made.

Note that the parent commits of the merge commit M are commit V, where the `main`branch was pointing before the mrege, and commit Y, the latest commit on this branch. The final actions need to take are to delete the Ch9 branch and pull the most up-to-date version of the main branch from the remote repository to my local repository.

The parent commits of the mrege commit M are commit V, where the main was pointing before the merge -- 

Preparing to make a Pull request -- to go over an example of a pull request, will start by completing fore:

```sh
git switch -c topic # use the git switch -c
# open the othercolors.txt file add 
git add othercolors.txt
git commit -m "pink"
git log
```

And the topic branch is just a new local branch, does not have an upstream branch defined for it.

```sh
git push
git push --set-upstream origin topic
git branch -vv
git log
```

Just saw how can use the `git push`to easily define an upstream branch while pushing a branch to the remote repository.

#### Creating a Pull request on a hosting service

When create a pull request, you have to define the source branch and the target branch -- in the `Rainbow`, topic is the source branch and the `main`is the target branch. On the web page to create the pull request, you will have the opportunity to enter info about the pull reqeust, the only required field for most hosting services is a title.

#### Reviewing and approving a Pull request -- 

Pull requests provide an opportunity for collaboators on a proj to review your work. Normally  if you had a collaborator reviewing your pull request, they would log into their *own account* on the hosting service, then review and approve it by selecting the *approve* button on the UI.

```sh
git switch main
git pull -p
git branch -d topic
git log
# under the friend repo
git pull
```

## Writing to channels with `select`

Can also use the `select`statement when need to write messages to channel, not just when are reading messages from channels -- `select`statements can combine read or write blocking channel operations together, selecting the cse that unblocks first -- as in the previous -- can use the `select`to implement non-blocking channel sending or sending on a channel with a timeout.

In Programming, can has a primes filter that, given a stream of random number, pick out any prime number it finds and ouputs it on another stream.

```go
func primesOnly(inputs <-chan int) <-chan int {
	results := make(chan int)
	go func() {
		for c := range inputs {
			isPrime := c != 1
			for i := 2; i <= int(math.Sqrt(float64(c))); i++ {
				if c%i == 0 {
					isPrime = false
					break
				}
			}
			if isPrime {
				results <- c
			}
		}
	}()
	return results
}
```

Just noticed that our goroutine outpus a subset of the numbers it receives on the input channel, often, the goroutine receives a non-prime number that is thrown away, meaning no number is output -- how can we feed in a stream of a random numbers while reading the primes returned on another channel in one goroutine -- use the `select`to both feed in the random numbers and read the primes.

```go
func main() {
	numbersChannel := make(chan int)
	primes := primesOnly(numbersChannel)
	for i := 0; i < 100; {
		select {
		case numbersChannel <- rand.Intn(10000000) + 1:
		case p := <-primes:
			fmt.Println("found prime ", p)
			i++
		}
	}
}
```

#### Disabling select cases with `nil`channels

In Go, can assign `nil`values to channles. This has the effect of blocking the channel from sending or receiving anything. Fore:

```go
var ch chan string
ch<- "message" // block forever
```

Go has deadlock detection, so when Go notices that the program is stuck with no hope of recovering, it gives us error messages. Need to note that the same logic applies to the `select`statements -- trying to send or receive from a `nil`channel on a `select`statement has the same effect of blocking the case using that channel.

Using `select`with just one `nil`channel is not that useful, can use the pattern of assigning `nil`to disable a case in the `select`statement. Fore, might be developing accounting software that recevies sales and expense amount from various sources.

To change the channel into a `nil`channel whenever it is closed -- reading from a channel always return two -- the flag telling us if the channel is still open. can read the flag, and if the flag indicates that the channel has been closed, we can set channel reference to nil like: Assigning a `nil`value to the channel variable after the receiver detects that the channel has been closed has the effect of disabling that `case`statement.

```go
func generateAmount(n int) <-chan int {
	amounts := make(chan int)
	go func() {
		defer close(amounts)
		for i := 0; i < n; i++ {
			amounts <- rand.Intn(100) + 1
			time.Sleep(100 * time.Millisecond)
		}
	}()
	return amounts
}
func main() {
	sales := generateAmount(50)
	expenses := generateAmount(40)
	endOfDayAmount := 0

	for sales != nil || expenses != nil {
		select {
		case amt, ok := <-sales:
			if ok {
				fmt.Println("Sale of:", amt)
				endOfDayAmount += amt
			} else {
				sales = nil
			}
		case expense, moreData := <-expenses:
			if moreData {
				fmt.Println("Expense of:", expense)
				endOfDayAmount -= expense
			} else {
				expenses = nil
			}
		}
	}
	fmt.Println("end of day profit and loss:", endOfDayAmount)
}
```

### Choosing between message passing and memory sharing

Can decide whether to use memory sharing or message passing for our concurrent applications depending on the type of solution we are trying to implement.

Concurrent programming using message passing tends to produce code containing well-defined modules, each module runinng its own concurrent execution that pases messages to other executions.

In contrast, memory sharing means that we need to use a more primitive way of managing concurrency.

```go
func countLetters(url string) <-chan []int {
	result := make(chan []int)
	go func() {
		defer close(result)
		frequency := make([]int, 26)
		resp, _ := http.Get(url)
		defer resp.Body.Close()
		if resp.StatusCode != 200 {
			panic("Server returning error code:" + resp.Status)
		}
		body, _ := io.ReadAll(resp.Body)
		for _, b := range body {
			c := strings.ToLower(string(b))
			cIndex := strings.Index(allLetters, c)
			if cIndex >= 0 {
				frequency[cIndex] += 1
			}
		}
		fmt.Println("Completed", url)
		result <- frequency
	}()
	return result
}
```

Can now add a `main`function that starts a goroutine for each web page and waits for messages from each ouput channel. Once we start receiving messages containing the slices, can merge them into a final slice.

```go
func main() {
	results := make([]<-chan []int, 0)
	totalFrequencies := make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		results = append(results, countLetters(url))
	}
	for _, c := range results {
		freqResult := <-c
		for i := 0; i < 26; i++ {
			totalFrequencies[i] += freqResult[i]
		}
	}
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, totalFrequencies[i])
	}
}
```

In converting our program to use message passing, we have avoided using mutexes to control access to share memory since each goroutine is now only working on its own data.

## Using `httptest.Server`

The key to end-to-end testing your app is the `httpetst.NewTLSServer()`function -- which spins up a `httptest.Server`instance that can make HTTPS requests to.

The whole pattern is complicated -- like:

```go
func TestPing(t *testing.T) {
    app := &applicaton {...}
    
    // USe the httptest.NewTLSServer() to create a new test server 
    // passing in the value returned by our app.routes() method as the handler
    ts := httptest.NewTLSServer(app.routes())
    defer ts.Close()
    
    // Thw work address that the test server is listening on is contained in the ts.URL
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
    bytes.TimSpace(body)
    assert.Equal(t, string(body), "OK")
}
```

- When call the `httptest.NewTLSServer()`to initialize the test server we need to pass in `http.Handler`as the parameter -- and *this handler is called each time the test server receives a HTTPs request*. In our case, passed in the return value from our `app.routes()`-- meaning that a request to the test server will use all our real app routes, middleware and handlers. This is a big upside of the work that we did.
- If you are testing a HTTP (not HTTPS) server should use the `httptest.NewServer()`
- The `ts.Client()`method returns the *test server client* -- which has a type `http.Client`, And we should always use this client to send requets to the test server -- it’s possible to configure the client to tweak its behavior.
- For the use of the `errorLog`and `infoLog`fields of `application`, but none of other fields -- the reason for this is that the loggers are needed by the `logRequest`and `recoverPanic`middleware.

Can see from the test ouput that the response from our `GET /ping`requset has a 404 status code, rather than a 200, cuz we haven’t actually registered a `GET /ping`route with our route yet. Fix that like:

```go
// Add a new GET /ping route for testing
router.HandlerFunc(http.MethodGet, "/ping", ping)
```

#### Using test helpers

Our `TestPing`test is now working nicely -- ther is a good opportunity to break out some of this code into helper functions, whch can reuse as we add more end-to-end tests to our project. 

There is no hard-and-fast rules where to put helper methods for tests -- if a helper is only used in a specific `_test.go`file, then it probably makes sense to include it inline in that file alongside your tests. If U are going to use helper in tests acorss multiple packages, then migth want to put it in a reusable package called `internal/testutils`like:

```go
func newTestApplication(t *testing.T) *application {
	return &application{
		errorLog: log.New(io.Discard, "", 0),
		infoLog:  log.New(io.Discard, "", 0),
	}
}

// testServer struct
type testServer struct {
	*httptest.Server
}

// newTestServer initializes and returns a new instance of custom testServer
func newTestServer(t *testing.T, h http.Handler) *testServer {
	ts := httptest.NewTLSServer(h)
	return &testServer{ts}
}

// Implement a get() on custom testServer type
func (ts *testServer) get(t *testing.T, urlPath string) (int, http.Header, string) {
	res, err := ts.Client().Get(ts.URL + urlPath)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	body, err := io.ReadAll(res.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)
	return res.StatusCode, res.Header, string(body)
}
```

Essentially, this is just a generalization of the code we have already written in the chapter.

```go
func TestPing(t *testing.T) {
	app := newTestApplication(t)
	ts := newTestServer(t, app.routes())
	defer ts.Close()

	code, _, body := ts.get(t, "/ping")
	assert.Equal(t, code, http.StatusOK)
	assert.Equal(t, body, "OK")
}
```

For this, is shaping up nicely - have a neat pattern in place for spinning up a test server and making request to it, encompassing our routing, middleware and handlers in an end-to-end test.

#### Cookies and redirections

So far in this have been using the default test server client settings, but there are a couple of changes -- 

- Want the client to automatically store any cookies sent in a HTTPs response, so that we can include them in any subsequent requests back to the test server. This will come in handy later
- Don’t want the client to automatically follow redirects.

To make these changes -- in the `testutil_test.go`update the `newTestServer()`func like:

```go
func newTestServer(t *testing.T, h http.Handler) *testServer {
	// Initialize the test server as normal
	ts := httptest.NewTLSServer(h)

	// initialize a new cookie jar
	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	// Add the cookie jar to the test server client.
	// any cookies will now be stored and sent with subsequent requests
	ts.Client().Jar = jar

	// disable redirect-following
    // for the test server client by setting a custom func -- this func will be called whenever a 3XX
    // response is received by the client, and by always returning a 
    // http.ErrUseLastRepsonse it forces the client to immediately return the t.recivied response
	ts.Client().CheckRedirect = func(req *http.Request, via []*http.Request) error {
		return http.ErrUseLastResponse
	}
	return &testServer{ts}
}
```

#### Customizing how tests run -- 

Take a quick break and about a few of the useful flags and options -- 

```sh
go test ./cmd/web # specific package
go test ./... # run all the tests in your current project

# tests by using the -run to only run specific tests like:
go test -v -run="^TestPing$" ./cmd/web/
```

And can even use the `-run`to limit testing to some specific sub-tests using the format like:

```sh
go test -v -run="^TestHumanData$/^UTC$" ./cmd/web
```

Test caching -- perhaps noticed by now -- In most cases, the caching of test results is useful. It helps reduce the total test runtime -- if you force your tesets to run in full (avoid cache), can use the `-count=1`flag.

`go test -count=1 ./cmd/web`

Alternative, can clear cached results for all tests with the `go clean`like:

`go clean --testcache`

