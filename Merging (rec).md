# Merging (rec)

Created first branch `feature`and started working on that -- How can U then combine the work U have done with the `main`branch once U are ready -- Is one way U an integrate the changes made in one branch into another branch. In any merge, there is one that you are merging, called the *source branch*, and one branch U are merging into, called *target branch* -- the source branch is the branch that contains the changes that will be integrated into the target branch. The target banch is the branch that receives the changes and is therefore the only one that is altered in this operation.

#### Types of merges

1. Fast-forward merges
2. Three-way merges

The facttor that determines which of these types of merges will take place when U merge the source branch into the target branch is whether the development histories of the two branches have diverged. If can reach one branch through the commit history of another branch, say that the development histories of the branches *have not diverged*. If were to now merge the branch into the `main`, a *fast-forward* merge occur. In this, the `chapter_six`is the source branch and the `main`is the target branch.

The commit history of the `main`is made up of commits `FGK`and `L`. There is no way to follow the parent links of the `eight`branch. To describe this, say that the development histories of the branches *have diverged*. Now it can’t be a fast-forwad merge cuz there is no way to just move the branch pointer forward to combine these two development histories. Instead, a *merge commit* will be created to tie the two development histories togehter. *three-way* merge.

#### Doing a Fast-Forward merge

You will mrege the `feature`into the `main`-- the `feature`is the source and the `main`is the target branch. There are two steps involved in doing a merge -- 

1. Switch onto the branch that you want to merge into (the target)
2. Use the `git merge`command and pass in the name of the branch you are merging.

```sh
git merge <branch_name>
```

The first step of doing a merge is to switch onto the target branch. Are just going to merge `feature`into `main`-- need to switch onto the `main`. Using `git switch`or `git checkout`command to switch:

1. Changes the `HEAD`pointer to point to the branch you are switching onto.
2. Populates the staging area with all files and directories that are part of the commit you are switching onto.
3. Copies the contents of the staging area into the working directory.

Git protectes U from losing uncommitted changes -- If Git detects switching branches will cause U to lose uncommitted changes in your working directory, will *stop* U from switching branches and present U with an error message. This happans only if the files that contain uncommitted changes . If Git detects switching branches will cause.

```sh
git status # uncommitted file
git switch main # error
```

If Git had allowed U to switch branches, then the version of the `rainbowcolors.txt`file in the working directory that mentions the colors.

```sh
git switch main # just undo some
git log
```

The version of the `rainbowcolors.txt`file was before U switched onto the `main`branh mentioned the colors.

- U are on the `main`and it points to the orange as v2
- v3 of the txt file has been replaced by v2 of the file in both the staging area and working directory.

Viewing a list of all commits -- `git log --all`-- output shows the `red, orange`and `yellow`commits. Then:

```sh
# make sure editor is open 
git merge feature
git log
```

U just merged `feature`into `main`, but in Git, merging a branch does not delete the branch. U must explicitly delete a branch if u no longer want to use it.

#### Checking Out Commits

Mentioned that the `git checkout`command may be used to switch branches as well as to carry out other actions. One of the other things you can do with the `git checkout`command is check out commits.

```sh
git checkout <commit_hash> # check out a commit
```

Will carry out 3 actions that are similar to the ones -- 

1. It changes the `HEAD`point to the *commit* U are switching onto.
2. It populates the staging area with all the files and directories that are part of the commit U are switching onto.
3. Copies the contents of the staging area into the working directory.

The `HEAD`will point directly to a commit instead of pointing to a branch. This means that you will be in sth that Git calls *detached* HEAD state.

```sh
git checkout 7acb333...
git log --all # HEAD points to commit
```

#### Creating a Branch and Switching onto it in one Go

If want to create a branch to retain commits you create, using `-c`with the switch command.

```sh
git switch -c <new_branch_name> # create a new and switch onto it
git checkout -b <new_branch_name> # //...
```

## Overusing getters and Setters

Getters and setters are means to enable encapsulation by providing exported methods on top of unexported object fileds. It is also considered neither mandatory nor idiomatic to use getters and setters to access struct fields.

```go
timer := time.NewTimer(time.Second)
<- timer.C // C ia s <-chan Time field
```

For this, although it is not recommended, could even modify directly. On the other hand, using getters and setters presents some advantages -- including -- 

- They encapsulate a behavior associated with getting or setting a field, allowing new functionality to be added later
- They hide the internal representation.
- They provide a debugging interception point for when the property changes at run time.

If fall into these, using getters and setters can bring some value. Fore:

- The getter should be named `Balance`
- The setter should be named `SetBalance()`fore:

```go
currentBalance := customer.Balance()
if currentBalance < 0 {
    customer.SetBalance(0)
}
```

### Interface pollution

Interfaces are one of the cornerstones of the Go language when designing and structuing our code. Abusing them is generallt not a good idea. Interface pollution is about overwhelming our code with unnecessary abstractions, making it harder to understand.

An interface provides a way to specify the behavior of an object. Use them to create common abstractoins that multiple objects can implement. What makes Go interfaces so different is that they are satisfied implicitly. Fore: `io.Reader`and `io.Writer`. Like:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

`io.Reader`reads from a data source and fills a byte slice, whereas `io.Writer`writes to a target from a byte slice.

```go
func main() {
    inFile, err := os.Open("input.txt")
    if err != nil {
        return
    }
    defer inFile.Close()
    
    outFile, err := os.Create("output.txt")
    if err != nil {
        return
    }
    defer outFile.Close()
    bytesWritten, err := io.Copy(outFile, inFile)
    
    if err != nil {
        return
    }
    fmt.Println("Copied %d bytes\n", bytesWrittern)
}
```

Custom implementation of the `io.Reader`interface should accept a slice of bytes, filling it with its data and returning either the number of bytes or an error.

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

`io.Writer`should write the data coming from a slice to a target..

- `io.Reader`reads data from a source
- `io.Writer`writes data to a target.

Assume need to implement a func that should copy the content of one file to another. Could create a specific function that would take as input two `*os.File`s. like:

```go
func copySourceToDest(source io.Reader, dest io.Writer) error {...}
```

Fore, could create our own `io.Writer`that writes to a dbs. Furthermore, writing a unit test for this func like:

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    source := strings.NewReader(input)       // create an io.Reader
    dest := bytes.NewBuffer(make([]byte, 0)) // create an io.Writer
    
    err := copySourceToDest(source, dest)
    if err != nil {
        t.FailNow()
    }
    got := dest.String()
    if got != input {
        t.Errorf(...)
    }
}
```

Adding methods to an interface can decrease its level of reusability -- `io.Reader`and `io.Writer`are powerful abstractions cuz they cannot get any simpler. Furthermore, can also combine *fine-grained* to create higher-level like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

#### When to use interfaces

Should we create interfaces -- 

- Common behavior
- Decoupling
- Restricting behavior

##### Common Behavior

In such a case, can factor out the behavior inside an interface. Fore, sorting a collection--

- Retrieving the number of elements in the collection
- Reporting whether one element must be sorted before another
- Swapping two elements

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

Finding the right abstraction to factor out a behavior can also bring some benefits. Like:

```go
func IsSorted(data Interface) bool {
    n := data.Len()
    for i:= n-1; i>0; i-- {
        if data.Less(i, i-1) {
            return false
        }
    }
    return true
}
```

Decoupling -- Another use case about decoupling -- If we rely on an abstraction instead of a concrete imp. The imp itself can be replaced with another without even having to change our code. One benefit of decoupling can be related to unit testing. Like:

```go
type CustomerService struct {
    store mysql.Store // depends on the concrete imp
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.store.StoreCustomer(customer)
}
```

For this, cuz `customerService`relies on the actual imp to store a `Customer`, we are obliged to test it through integration tests. Although integration tests are helpful, not always want. so:

```go
type CustomerStorer interface {
    StoreCustomer(Customer) error // create a storage abstraction
}
type CustomerService struct {
    storer CustomerStorer // decouples from the actual imp
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.storer.Storeustomer(customer)
}
```

Restricting Behavior -- The last use case -- Imagine we implement a custom configuration package to deal with dynamic configuration - Create a specific container for `int`configurations via `IntConfig`struct that also exposes methods -- `Get`and `Set`-- like:

```go
type IntConfig struct {}

func (c *IntConfig) Get() int {}
func (c *IntConfig) Set(value int) {
    // update config
}
```

Suppose receive an `IntConfig`that holds some specific configuration, fore threshold. In the code, just interested in retrieving the configuration value, preventing updating it. By creating an abstraction that restricts the behavior to retrieving only a config value like:

```go
type intConfigGetter interface {
    Get() int
}

// then can rely on intConfigGetter
type Foo struct {
    threshold intConfigGetter
}
func NewFoo(threshold intConfigGetter) Foo {
    return Foo {...}
}
func (f Foo) Bar() {
    threshold := f.threshold.Get()
}
```

In this, the configuration getter is injected into the `NewFoo`factory.

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w,r)
		return
	}
	
	w.Write([]byte("Hello from Snippetbox3"))
}
```

The `DefaultServeMux`-- For the `http.Handle()`and `http.HandleFunc()`functions, these allow U to register routes without declaring a servemux. like:

```go
func main() {
    http.HandleFunc("/", home)
    //...
    err := http.ListenAndServe(":4000", nil)
}
```

Behind the scenes, these functions register their routes with sth called the `DefaultServeMux`-- it’s just regular servemux like already been using. Just cuz `DefaultServeMux`is a global variable, any package can access it and register a route.

#### Host name matching

It’s possible to include host names in your URL patterns -- this can be useful when U want to redirect all HTTP requests to a canonical URL. When it comes to pattern matching, any host-specific patterns will be checked first and if there is a match the request will be dispatched to the corresonding handler.

### Customizing HTTP headers

Requests to the `/snippet/create`route will result in a new snippet being created in a database. Begin by updating our `snippetCreate`handler function so that it sends a 405 unless the request method is `POST`. Then:

```go
func snippetCreate(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.WriteHeader(405)
		w.Write([]byte("Method Not Allowed"))
		return
	}
	w.Write([]byte("Create a new snippet..."))
}
```

Note that:

- It’s only possible to call `w.WriteHeader()`once per response, and after the status code has been written it can’t be changed. If try to call `w.WriteHeader()`a second time Go will warn.
- If don’t call `w.WriteHeader()`explicitly, then the first call to `w.Write()`automatically a 200. So need to re-write.

#### Customizing Headers

Another improvement can make is to include an `Allow`header with the 405. Can do this by using the `w.Header().Set()`method to just add a new header to the response header map like so:

```go
if r.Method != "POST" {
    w.Header().Set("Allow", "POST")
    w.WriteHeader(405)
    w.Write([]byte("Method Not Allowed"))
    return
}
```

#### The `http.Error`shortcut

if want to send a non-200 status code and a plain-text response body then it’s a good opportunity to use the `http.Error()`shortcut. like:

```go
if r.Method != "POST" {
    w.Header().Set("Allow", "POST")
    http.Error(w, "Method not Allowed", 405)
    return
}
```

In terms of functionality this is almost exactly the same -- the difference is that now passing our `http.ResponseWriter`to another function.

Some constants -- like `http.MethodPost`instead of the string `POST`. The `http.DetectContentType()`function generally works quite well, but a common gotcha for web developers new to Go, Can prevent the json from happening by setting the correct header manually like so -- 

```go
w.Header().Set("Content-type", "application/json")
w.Write([]byte(`{"name":"Alex"}`))
```

#### Manipulating the header map

Used the `w.Header().Set()`to add a new header to the response header map. There also `Add(), Del(), get()`and `Values()`can use to read and manipulate the header map too. Like:

```go
// set a new header, if exists, will be overwritten
w.Header().Set("Cache-Control", "public, max-age=...")
// Add() appends a new header
w.Header().Add("Cache-Control", "public")
w.Header().Add("Cache-Control", "max-age=...")

// Delete all values from the header
w.Header().Del("Cache-Control")

// Retreive Just the first value
w.Header().Get("Cache-Control")

// Retrieve a slice of all values
w.Header().Values("Cache-Control")
```

