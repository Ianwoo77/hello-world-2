# Setting up the Rebasing Example

To practice rebasing, you will need to create divergant histories. U are going to make one commit in the `rainbow`repository and push it to the remote repository. Then your friend, without fetching the changes from the remote repository, is going to make two commits in their `friend-rainbow`repository. After they have made their commits, they will fetch the changes from the remote repository and decide to rabase their branch.

```sh
# under rainbow repository
git add othercolors.txt # after add some text
git commit -m "gray"
git push
```

### Unstaging and Staging Files

In the `friend-rainbow`repository add them both to the staging area -- then will realize they want to make two separate commits for the different pieces of work -- will have to *unstage* file. To explore what happens in the upcoming example, will focus on the friend repository in the diagrams -- 

```sh
# modify the `readme.md` and othercolors.txt
git status
git add readme.md rainbowcolors.txt
# restore a file to another version file in the staging area
git restore --staged <filename>
git restore --staged readme.md
git status # modified (Green) othercolors.txt red readme.txt
```

Unstaged the readme.md file, so the version in the staging area went back to vA. And the updted version of `othercolors.txt`is till in the staging area.

```sh
git commit -m "black" # under friend repository
git status
git log
```

Then will add the changes that they made to the `readme.md`file to staging area and make another commit.

```sh
git add readme.md
git commit -m "rainbow"
git log
```

- The version of the `readme.md`file in the staging area is now vB, which is the version that is part of the rainbow commit.

Just saw how your friend was able to add files to and remove them from the staging area in order to craft exactly the commits they wanted. The local `main`branch in the `rainbow`and local `main`branch in the `friend-rainbow`repository now have divergent development histories.

### Preparing to Rebase

To rebase a branch U first have to fetch all the work that has been don on the branch that you want to rebase onto. So, in preparation for rebasing their branch, your friend is going to fetch the last updates from the remote repository.

```sh
git fetch
git log --all
```

The `origin/main`remote-tracking branch in the `friend-rainbow`repository represents the latest version of the remote branch -- your friend is now ready to rebase their local `main`branch onto the `origin/main`remote-tracking.

#### The 5-stage of the Rebase process

1. Find the common ancestor -- Git will identify the common ancestor of the two branches involved in the rebase -- the branch you are on and the branch you are rebasing onto.
2. Store info about the branches involved in the *rebase*. Git will save the changes introduced by each commit of the branch you are on a *temporary* area. Will aslo save additional info in this temporary area. For the example app, in the Rainbow project example, the changes introduced by the black commit and the rainbow commit will be saved in the temporary area along with info about the remote `main`.
3. Reset HEAD -- Will reset `HEAD`to point to the same commit as the branch you are rebasing onto.
4. Applying and comitting the changes -- Git will apply the set of changes from each commit in turn, making a commit after it applies each set. in the example, first it will apply the changes introduced by the black commit and create a new commit, and then it will apply the changes introduced by the rainbow commit.
5. Switch onto the rebased branch.’

Git carries out the entire process itself, all U need to do is initiate it with the `git rebase`command.’

#### Rebasing and Merge Conflicts

Git will carry out the entire rebase process independently, unless it encounters merge conflicts -- in this case, you must step in and resolve them. The process for resolving merge conflicts while rebasing is similar to the process when doing 3-way merge.

Once U are done resolving the merge conflicts, need to **add** the updated files to the *staging area* and then instruct Git to resume the rebase process by entering `git rebase --continue`option -- Git will then continue rebasing the rest of the commits. If at any point during the process of resolving merge conflicts in a rebase you decide you don’t want to contiune the rebase process, can choose to stop or abort the process by using the `git rebase --abort`.

```sh
git rebase origin/main
git status
```

Then, carry out step 1 resovling mrege conficts then:

```sh
git add othercolors.txt
git status
git rebase --continue
git log
```

- We just represent the new black commit and the new rainbow commit as BL’ and RA’.
- In the `friend-rainbow`repository, the gray commit, the new black comit, and the new rainbow commit from a linear proj history.

## Closing transient resources

Pretty frequently, developers work with transient resources that must be closed, fore, to avoid leaks ond disk or in memory. Structs can generally implement the `io.Closer`interface to convey that a transient resource has to be closed -- look at 3 common examples of what happens when resources aren’t correctly closed and how to handle them properly. -- 

#### HTTP body

Discuss this problem in the context of HTTP -- will rite the `getBody()`makes an HTTP GET request and returns the HTTP body repsonse -- like:

```go
type handler struct {
	client http.Client
	url    string
}

func (h handler) getBody() (string, error) {
	resp, err := h.client.Get(h.url)
	if err != nil {
		return "", err
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	return string(body), nil
}
```

Use the `http.Get()`and parse the response using `io.ReadAll`-- this method looks ok , and it correctly returns the HTTP resposne body -- however, there is a resouce leak -- `resp`is `*http.Response`type, contains a `Body io.ReadCloser`field -- must be closed if `http.Get()`doesn’t return an error, otherwie, it’s a resource leak -- Our app will keep some memory allocated that is no longer needed, but can’t be reclaimed by the GC and may prevent clients from reusing the TCP conenction in the worst cases.

And the most convenienting is to handle it as a `defer`statement like:

```go
defer func() {
    err := resp.Body.Close()
    if err != nil {
        log.Println("...", err)
    }
}()
```

On the server side, while implementing an HTTP handler, we aren’t required to close the request body cuz Server will do this automatically. Should also understand that a response body must be closed regardless of whether we read it. Fore, if we are only interested in the HTTP status code and not in the body, has to be closed no matter what -- 

```go
func (h handler) getStatusCode(body io.Reader) (int, error) {
	resp, err := h.client.Post(h.url, "application/json", body)
	if err != nil {
		return 0, err
	}
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			log.Printf("Failed to close response body %v\n", err)
		}
	}()
	return resp.StatusCode, nil
}
```

For this, function closes the body even though we havn’t read it. Another esseitnal thing to remember is that the behavior is different when we clsoe the body, depending on whether we have read from it.

- If close the body without a read, the default HTTP transport may close the connection.
- If close the body following a read, the default HTTP transport won’t close the connection. So, if:

```go
func (h handler) getStatusCode(body io.Reader) (int, error) {
	resp, err := h.client.Post(h.url, "application/json", body)
	if err != nil {
		return 0, err
	}
	// close response body
	_, _ = io.Copy(io.Discard, resp.Body)
	return resp.StatusCode, nil
}
```

In this, just read the body to keep the conenction alive. Using the `io.Copy()`to `io.Discard`-- an `io.Writer`implementation -- this code reads body but discards it without any copy, more efficient. Note that closing a resource to avoid leaks isn’t only related to HTTP body management, in general, all structs implementing the `io.Closer`interface should be closed at some point.

#### `sql.Rows`

Is a struct used as a result of an SQL query -- cuz this struct implements `io.Closer`-- it has to be closed like:

```go
func main() {
	db, err := sql.Open("postgres", dbSourceName)
	if err != nil {
		panic(err)
	}
	rows, err := db.Query("SELECT * FROM CUSTOMERS")
	if err != nil {
		panic(err)
	}
	// use rows
}
```

Note that forgetting to  close the rows means a connection leak -- which prevents the dbs connection from being put back into the connection pool. So:

```go
defer func() {
    if err := rows.Close(); err != nil {
        log.Printf("failed to close rows: %v\n", err)
    }
}()
```

Following the `Query`call, we should eventually close `rows`to prevent a connection leak if it doesn’t return an error.

#### `os.File`

`os.File`represents an open file decriptor, like `sql.Rows`it must be closed eventually like:

```go
func main() {
	f, err := os.OpenFile(filename, os.O_APPEND|os.O_WRONLY, os.ModeAppend)	
	if err != nil {
		panic(err)
	}
	defer func() {
		if err := f.Close(); err != nil {
			log.Printf("Failed to close file %v\n", err)
		}
	}()
}
```

In this, also use the `defer`to defer the call to the `Close()`-- if don’t eventually close an `os.File`-- It will not lead to a leak per se. Note that the file will be just closed automatically when `os.File`is garbage collected, however, it’s better to call `Close()`explicitly cuz we don’t know when the Next GC will be triggered.

And, there is another benefit of calling `Close`explicitly, to actively monitor the error that is returned, this should be the case wtih writable files.

Writing to a file descriptor isn’t sync operation. For some performance concerns, data is buffered. Like:

```go
func writeToFile(filname string, content []byte) (err error) {
	// open file...
	defer func() {
		closeErr := f.Close()
		if err == nil {
			err = closeErr
		}
	}()
	_, err = f.Write(content)
	return
}
```

Furthermore, success while closing a writable `os.File`doesn’t guarantee that the file will be written on disk. The write can still live in a buffer on the filesystem and not be flushed on disk. If durability is a critical factor, can use the `Sync()`method to commit a change. like:

```go
_, err = f.Write(content)
if err != nil {
    return err
}
return f.Sync() // commits write to the disk
```

#### Forgetting the return statement after replying to an HTTP request

While writing an HTTP handler, it’s easy to forget `return`after replying to a HTTP request -- may lead to some odd situation where we should -- fore stop a handler after an error, but not, like:

```go
func handler(w http.ResponseWriter, req *http.Request) {
    err := foo(req)
    if err != nil {
        http.Error(w, "foo", http.StatusInternalServerError)
    }
}
```

For this, `foo()`returns an error, handle it using `http.Error`-- which replies to the request with the `foo`error message and a 500 internal Server Error. The problem with this code is that if enter the `if err != nil`branch, the application will continue its execution, cuz `http.Error`doesn’t stop the handler’s execution.

In terms of executin, the main impact would be to continue the execution of a function that should have been stopped. Fore, if `foo`was returning a pointer in addition to the error,  to fix just like:

```go
// ...
if err != nil {
    http.Error(w, "foo", http.StatusInternalServerError)
    return
}
```

### Don’t use default HTTP client and server

The `http`package provides HTTP client and sever implemetnations -- however, it’s all to easy for developers to make a common mistake -- relying on the default implemetnations in the context of applications that are eventually deployed in production.

#### HTTP client

define what *default client* means -- will use a GET request as an example -- can use the zero value of an `http.CLient`struct like so -- 

```go
client := &http.Client{}
resp, err := client.Get("http://..")
```

Or can use the `http.Get`function like:

`resp, errr := http.Get(“...”)`

In the end, both approaches are the same, the `http.Get`uses `http.DefaultClient`, which is also based on the zero value of `http.Client`like:

`var DefaultClient= &Client{}`

First, the default client doesn’t specify any timeouts -- this absence of timeout is not sth we want for *production-grade* systems -- it can lead to many issues, such as never-ending requsts that could exhaust sytem resources.

1. Dial to establish TCP conn
2. TLS handshake
3. Send req
4. Read the resp
5. Read the resp body

For these, the 4 main timeouts are the following -- 

- `net.Dialer.Timeout`-- specifies the maximum amount of time a dial will wait for a connection to complete.
- `http.Transport.TLSHandShakeTimeout`
- `http.Transport.ResponseHeaderTimeout`
- `http.Client.Timeout`

And there is an example of an HTTP client that overrides these -- 

```go
client := &http.Client {
    Timeout: 5*time.Second,
    Transport: &http.Transport {
        DialContext: (&net.Dialoer{...})
    }
}
```

The second aspect to bear in mind about the default HTTP client is how connections are handled. By default, the HTTP client does connection pooling -- the default client reuses connections.

## Unit testing and sub-tests

Create a unit test to make sure that our `humanDate()`function made back in the ch is outputing `time.Time`vlaues in the exact format that we want. Look like:

```go
func humanDate(t time.Time) string {
    return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

The reason -- simple func just, can explore the basic syntax and patterns for writing tests wthout getting too caught-up

### Creating a unit test

In Go, its standard practice is to create your tests in `_test.go`files which live *directly* along side the code that your are testing.

```go
func TestHumanDate(t *testing.T) {
	// Initialize a new time.Time object and pass it to the humanDate function
	tm := time.Date(2022, 3, 17, 10, 15, 0, 0, time.UTC)
	hd := humanDate(tm)

	// check that the output from the humanDate func is in the format we expect
	if hd != "17 Mar 2022 at 10:15" {
		t.Errorf("got %q; want %q", hd, "17 Mar 2022 at 10:15")
	}
}
```

This pattern is the basic one that  you will for nearly all tests that you write in Go. The imporatant things to note:

- The test is just regular Go code -- which calls the `humanDate()`func and checks that the result matches what we exprect.
- Your unit tests are contained in a normal Go function with signagure like `func(*testing.T)`
- To be valid unit test the name of this function **MUST** begin wtih the word `Test`.
- Can use the `t.Errorf()`to mark a test as failed and log a descriptive message about the failure. It’s important to note that calling `t.Errorf()`doesn’t stop execution of your test. After that executing any remaining code as normal.

Then use the `go test`command to run all the tests in our package. If want more detail, can see exactly which tests are being run by using the `-v`flag to get the *verbose* output.

#### Table-driven tests

Now expand our `TestHumanDate()`function to cover some additional *test cases* specifically, going to update it to also check that -- 

1. If the input to `humanDate`is the zero time, then return emtpy string
2. If output from that always use the UTC time zone

In Go, an idiomatic way to run multiple test cses is to use *table-driven* tests -- Essentially, the idea -- is to create a *table* of test cases containing the inputs and expected outputs, and to then loop over these, running each test case in a *sub-test*. there are a few ways U could set this up -- but a common approach is to define your test cases in an slice of anonymous structs like:

```go
func TestHumanDate(t *testing.T) {
	// Create a slice of anonymous structs containing test case name,
	// input to our humanDate()
	tests := []struct {
		name string
		tm   time.Time
		want string
	}{
		{
			name: "UTC",
			tm:   time.Date(2022, 3, 17, 10, 15, 0, 0, time.UTC),
			want: "17 Mar 2022 at 10:15",
		},
		// ...
	}

	// Then loop over the test cases
	for _, tt := range tests {
		// Use the t.Run() function to run a sub-test for each test case.
		// 1st parameter to this is the name of the test, and 2nd is and
		// anonymous function containing the actual test for each case
		t.Run(tt.name, func(t *testing.T) {
			hd := humanDate(tt.tm)
			if hd != tt.want {
				t.Errorf("got %q; want %q", hd, tt.want)
			}
		})
	}
}
```

Here can see the individual output for each of our sub-tests. So modify like:

```go
func humanDate(t time.Time) string {
	if t.IsZero() {
		return ""
	}
	return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

#### Helpers for test assertions

As mentioned beiefly earlier in the book, over th next few chapters will be writing a lot of *test assertions* that are a variation of this pattern -- like:

```go
if actualValue != expectedValue {
    t.Errorf("get %v; want %v", actualValue, expectedValue)
}
```

For convention, just quickly abstract this code into a helper function like:

```go
func Equal[T comparable](t *testing.T, actual, expected T) {
	t.Helper()
	if actual != expected {
		t.Errorf("got: %v; want: %v", actual, expected)
	}
}
```

Just noticed that we have set this up so that `Equal()`is a generic function -- this means that we will be able to use it irrespective of what the type of the `actual`and `expected`values is. So long as both `actual`and `expected`have the *same* type. Need to note that the `t.Helper()`- indicates the Go test runner that our *`Equal()`is a test helper*. This means that when `t.Errorf()`is called from the `Equal()`-- the go test runner will report the filename and line number of the code *which called* our `Equal()`in the output. Simplify the test like:

```go
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        hd := humanDate(tt.tm)
        assert.Equal(t, hd, tt.want)
    })
}
```

#### Sub-tests without a table of test cases

It’s important to point out that you don’t have to use sub-tests in conjunction with table-driven tests -- it’s perfectly valid to execute sub-tests by calling `t.Run()`consecutively. Just like:

```go
func TestExample(t *testing.T) {
    t.Run("sub-test 1", func(t *testing.T) {...})
}
```

### Testing HTTP handlers and middlewares

All the handlers tha have written for this project are a bit more complex to test, and to introduce things prefer to start off with something more simple -- Fore, create a new `ping`handler function which just return a 200 and an `OK`body.

```go
func ping(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK"))
}
```

Create a new `TestPing`first -- 

- Checks that the response status code written by `ping`handler is 200
- Checks that the response body written by the `ping`handler is `OK`

#### Recording responses

To assist in testing your HTTP handlers Go provides the `net/http/httptest`package -- which contains a suite of useful tools -- one fo them is the `httptest.ResponseRecorder`type -- this is essentially an implementation of the `http.ResponseWriter`which records the resposne status code, headers and body instead of actually writing them to a HTTP connection. So an easy way to unit test handlers is to create a new `http.ResponseRecorder`object, pass it to the handler function, and then examine it again after the handler returns.

```go
func TestPing(t *testing.T) {
	// Initialize a new httptest.ResponseRecorder
	rr := httptest.NewRecorder()

	// Initialize a new dummy http.Request
	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	// call the ping handler func, pass in the httptest.ResponseRecorder and http.Request
	ping(rr, r)

	// Check that the Result() method go get the Response generted by the Ping
	rs := rr.Result()

	// check that the status code is 200
	assert.Equal(t, rs.StatusCode, http.StatusOK)

	// and we can check that the response body written by the ping equals OK
	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	bytes.TrimSpace(body)
	assert.Equal(t, string(body), "OK")
}
```

For this, can see that our new `TestPing`test is being run and passing without any problems. 

And, it’s also possible to use the same general pattern to unit test your middleware -- demonstrate how by creating a new `TestSecureHeaders`test for the `secureHeaders()`middleware that we made.