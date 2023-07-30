# Git Commit

Since have finished work, are ready move from *stage* to *commit* for our repo. Adding commits keep track of our progress and changes a swe work. Git considers each `commit`chagne point or “check point”.

When commit, should always inclues a **message**. By adding clear message to each *commit*, it is just easy for yourself to see what has changed and when -- like:

```sh
git commit -m "first release of ..."
```

`-m`stands for message.

### Git Commot without Stage

```sh
git status --short
# M index.html
```

- ?? -- untracked files
- `A`-- Files added to stage
- `M`-- modified files
- `D`-- deleted

So, can:

```sh
git commit -a -m "updated some file"
```

### Git Commit Log

To just view the history of commits for a repo, use the `log`command like:

```sh
git log
```

## Git Help

If are having trouble for remembering commadns or options for commands, can use git `help`. There are couple of different ways you can use the `help`command in command line. like:

```sh
git command -help # See all available options for the specific command
git help --all # see all possible commands
```

## Git Branch

### Working with Git Branch

In Git, a `branch`just is a new/separate version of the main repository. Fore, have a large project, and need to update the design on it -- Without Git -- need:

- make copies of all the relevant files to just avoid impacting the live version.

- Start working with the design and find that code depend on code in other files.

- Make copies of the dependent files as well. Making sure that every file dependency references the correct name.

- Work on the unrelated error.. and update.

  ...

With Git:

- new branch -- edit he code directly without impacting the main branch.
- Create new branch from the main called small-error-fix fore
- Fix the unrelated error and *merge* the small-error-fix branch with the main.
- Go back to the new-design, and finish the work there
- Merge the new-design branch with main.

So, Branches allow you to work on different parts of a project without impacting the main branch. When the work is complete, a branch can be merged with the main project. Can even switch between branches and work on different projects without them interfering with each other.

### New Git Branch

Fore, add some new features to the page -- now are working in local repo, don’t want to disturb or wreck the main project, so create a new `branch`. fore:

```sh
git branch hello-world-images
git branch # show all branches
```

can see the new branch, but * beside master specifies we just on that `master`branch. -- `checkout`is the command used to check out a branch, moving from the current to one specified like:

```sh
git checkout hello-world-images
```

For now, have moved our current workspace from the master to the new `branch`. Then, just add some new func.

then check the status with `git status` of the current `branch`. Here:

- there are changes to our index.html -- but the file is not staged for `commit`.
- `abc.jpg`is not tracked

So, need to add both files to the Staging Environment for this bracnch like:

```sh
git add --all
```

For there, using `--all`jsut instead of individual filename will **Stage all changes** Then check the status again like:

Then can commit the branch like:

```sh
git commit -m "Added image to Hello world"
```

Now, just have a new branch, that is different from the master branch.

Note: Using the `-b`option on `checkout`command will create a new branch, and move to it, if doesn’t exist.

### Switching between Branches

Now check what happens when change branch to the `master` -- 

```sh
git checkout master
# cuz the new image is not a part of this branch, list files:
ls # no jpg there
```

### Emergency Branch

Now imagine that we are not yet done with .. fix some error , fore creating a new branch to deal with the emergency:

```sh
git checkout -b emergency-fix
```

So, just fix the error... just made some changes in the file, and for now need to get those changes to the master.

```sh
git add index.html
git commit -m "updated index.html with emergency fix"
```

# Not understanding Floating points

In Go, there are just two floating-point types -- `float32`and `float64`-- the concept of a floating point was invented to solve the major problem with integers -- Need to know that floating-point arithmetic is just an approximation of real arithmetic -- like:

```go
var n float32 = 1.0001
fmt.Println(n*n)
```

Go’s `float`just are approximations -- cuz of that, have to bear a few rules:

- When comparing tow numbers, check that their difference is within an acceptable range.

### Not understanding Slice length and capacity

In go, a slice jsut backed by an array.That mans the slice’s data is stored continguously in an array data structure. A slice also handles the logic of adding an element if the backing array is just full or shrinking the backing array if it’s almost empty.

Internally, a slice holds a pointer to the bcking array plus a length and a capacity. The length is jsut the number of elements the slice conains, whereas the capacity is the number of elements in the backing array. like:

`s:= make([]int, 3, 6)`

In the case `make`just creates an array of six elements -- but cuz the `length`is 3, go iniialize only 3 elements to zeroed value of in `int`0.

Accessing an element just outside the length range is forbidden, even though it’s already allocated in memory. And just using the `append`built-in func to use the remaining space.

cuz an array is a fixed-size structure, it can store the new elements until element 4 -- when insert element.. the array full -- go internally creates another array by **doubling** the cap. NOTE: in go, a slice gorws by doubling its size until it contains 1024, after which it grows by 25%.

And, what will happen to the previous backing array -- if it’s no longer referenced, it’s eventually freed by the GC -- if allocated on the heap.

What happens with slice -- is an operation done on an array or a slice -- providing a half-open range -- the first is included whereas the second is exclueded. `[)`. like:

```go
s1 := make([]int, 3, 6)
s2 := s1[1:3]
```

For this, `s1`created as a 3l, 6c -- when `s2`created by slicing s1, both reference the just same backing array - s2’s l and c just differ from s1, for s2, cap is just 5, cuz start from index 1.

Namely, waht happens if append an element to s2 -- like `s2 = append(s2, 2)`-- the shared backing array is just modified -- but only the length of s2 changes. and s1 remain 3, 6, and, the added element is only visible to s2.

It’s just important to understand this behavior so that don’t make wrong assumptions while using `append()`

One last thing to note -- what if keep appending to `s2`until the backing is full -- code leads to creating another backing array. For now, s1 and s2 now reference two different arrays.

## Inefficient slice initialization

While initializing a slice using `make`-- have to provide a length and an optional cap -- forgetting to pass an appropriate value for both of these -- mistake -- If, want to implement a `convert`that maps a slice of  `Foo`into a slice of `Bar`like:

```go
func convert(foos []Foo) []Bar {
    bars := make([]Bar, 0)  // resulting slice
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

initialize an empty using `make([]Bar, 0)`, then use the `append`to add the elements. Every time the backing array is full, Go creates another array of doubling it cap.

There are two different options for this -- first is to reuse the same code but allocate the slice with a given cap:

`bars := make([]Bar, 0, n)` // n:= len(foos)

Internally, Go just preallocates an array of `n`elements -- therefore, adding up to `n`elements means reusiing the same bcking array and hence reducing the number of allocations drastically.

The 2nd option is to allocate `bars`with a given length like:

`bars := make([]Bar, n)`
`//... bars[i]=fooToBar(foo)`

Cuz we just initialize the slice with a length, `n`now are already allocated and initialized to zero value. Which options is best -- run a benchmark like: first is of course slowest. and the third faster than second, cuz avoid calling the `append`. And converting one slice type into another is just a frequent op in go. NOTE:

if the length of the future is already know, it’s not good to allocate an empty. Our options are either a given cap or given length -- using a given len is faster, but using cap is easier to implement.

## Recording Responses

To assist in testing your HTTP handlers, Go just provide the `net/http/httptest`package -- which contains a suite of useful tools -- One of these tools is the `httptest.ResponseRecorder`type -- this is essnetially an implemetnation of the `http.ResponseWriter`which records the response status code, headers and body instead of actually writing them to a HTTP connection -- 

So, an easy way to unit test your handler is to create a new `httptest.ResponseRecorder`object, pass it to the handler func, and then examine it again after the handler returns like:

```go
func TestPing(t *testing.T) {
    // initialize a new httptest.ResponseRecorder
    rr := httptest.NewRecorder()
    
    // initialize a new dummy Requset -- 
    r, err := http.NewRequest(http.MethodGet, "/", nil)
    if err != nil {...}
    
    ping(rr, r)
    
    // call the Result() method to get the http.Response
    rs := rr.Result()
    
    if rs.StatusCode != http.StatusOK {
        t.Errof(...)
    }
    
    // and can ceck the response body 
    defer rs.Body.Close()
    body, err := ioutil.ReadAll(rs.Body)
    if err != nil {
        t.Fatal(err)
    }
    if string(body) != "OK"{
        t.Errorf(...)
    }
}
```

### Testing Middleware

It’s also possible to use the same general tech to unit test your middleware -- demonstrate by creating a `TestSecureHeaders`test for the `secureHeaders`middleware that we made eariler in the book. As part of this test what to check - 

- The middleware sets the `X-Frame-Options: deny`header
- The middleware sets the `X-XSS-Protection: 1; mode=block`
- The middleware correctly calls thenext handler in the chain

```go
func TestSecureHeader(t *testing.T) {
	// Initialize a new httptest.ResponseRecorder and dummy http.Request
	rr := httptest.NewRecorder()

	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(r)
	}

	// create a mock HTTP handler that we pass to our secureHeaders
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})

	// pass the mock handler to our secureHeader
	// call its ServeHTTP(), passing in the http.ResponseRecorder
	secureHeaders(next).ServeHTTP(rr, r)

	// Call the Result() on the http.ResponseRecorder to get the results of the test
	rs := rr.Result()

	// check the middleware has correctly set the header like:
	frameOptions := rs.Header.Get("X-Frame-Options")
	if frameOptions != "deny" {
		t.Errorf("Want %q, got %q", "deny", frameOptions)
	}

	// check that the middleware has correctly set the X-XSS-Protection header on the response.
	xssProtection := rs.Header.Get("X-XSS-Protection")
	if xssProtection != "1; mode=block" {
		t.Errorf("Want %q, got %q", "1; mode=block", xssProtection)
	}

	// check that the middleware has correctly called the next handler in the chain
	if rs.StatusCode != http.StatusOK {
		t.Errorf("Want %d, got %d", http.StatusOK, rs.StatusCode)
	}
	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}

	if string(body) != "OK" {
		t.Errorf("want body to equal %q", "OK")
	}
}
```

So, in summary, a quick and easy way to unit test your HTTP handlers and middleware is to simply call them using the `httptst.ResponseRecorder`type. can then examine the status code.

### Running Specific Test

It’s just possible to run specific tests by using the `-run`flag, this allows you to pass in a regular expression -- and only tests with a name that matches the regular expression will be run. like:

```sh
go test -v -run="^TestPing$" ./cmd/web
```

## Additional Information

### Parallel testing

By default, the `go teset`command executes all tests in just a serial manner, one after another, when you have a small number of tests and the runtime is very fast, this just fine -- but if have 100+ or 1000+... May save some time by running your tests in parallel.

Can just indicate that it’s ok for a test to be run in concurrently alongside other tests by calling `t.Parallel()`at the start of the test like:

```go
func TestPing(t *testing.T) {
    t.Parallel()
}
```

- Tests marked using the `t.Parallel()`will be run in parallel with -- and **only with** other parallel tests.
- By default, the maximum number of tests will be run simultaneously is just the `GOMAXPROCS`, can setting that via the `-parallel`flag like `go test -parallel 4 ./...`
- Not all tests are suitable to be run in parallell -- fore, if you have an integration test which just requires a dbs table to be in a specific known state, then wouldn’t  want to run it in parallel with other tests.

### Enabling the Race Detector

The `go test`command also includes a `-race`flag which enables Go’s **race detector** when running tests. If the code you are testing leverages concurrency -- or are running tests in parallel, enabling this can be a good idea - to flag up race conditions that exists in app. like: `go test -race ./cmd/web`

And it’s just important to point out that the race detector is just a tool that flag the data races if and when they occur at runtime -- it doesn’t carryout static analysis of your codebase. and a clear run doesn’t *ensure* your code is free of race condititons. Enalbing the race detector will also increase the over running time of your tests.

