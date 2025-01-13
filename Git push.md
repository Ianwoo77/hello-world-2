# Git push

Adding a connection to the Remote repository -- A local repository can communicate with a remote repostiory when the local repository has a connection to the remote repository stored within it. This connection will have a name -- *remote repository shortname* -- A local repository can have connections to multiple repositories. U must explicitly associate the remote repository URL to the remote repository shortname.

```sh
git remote add <shortname> <URL>
```

Once a connection to a remote repository is stored in a local repository, you are able to connect to the remote repostiory by referring to the shortname rather than the URL in the command line. For this, the `rainbow`repository was just initilized locally, so are going to have to add a connection to the remote repository in the local repository explicitly.

```sh
git remote
git remote -v # for verbose
git remote add origin https://github.com/...
git remote # origin
git remote -v # for fetch and push
```

#### Remote Branches and Remote-Tracking Branches

Remote branches do not automatically update when U make more commits on local branches. Have to explicitly push commits from a local branch to a remote branch. Can set up a tracking relationship between a local branch and a remote branch by defining which remote branch a local branch should track. This is referred to as the *upstream branch*.

```sh
git push <shortname> <branch_name> # upload content from <branch_name> to the <shortname> remote rep
```

After that -- 

1. A remote branch will be created in your remote repository
2. A remote-tracking branch will be created automatically in the local repository

```sh
git branch --all
git push origin main
git branch --all
git log
```

`git push`command indicates that you have pushed your branch to the remote repository, can see the `refs`directory has a new directory insdie it called `remotes`. For now, there is no `feature`branch in the remote repo. If U also want to push your `feature`branch to the remote repositoy, you have to do so explicitly. Can:

```sh
git switch feature
git push origin feature
git branch --all
git log
```

### Cloning and Fetching

Going to start simulating what is would be like to work with a friend on the Rainbow proj -- going to learn about cloning remote repo and how this differs from initializing repostories locally.

Cloning -- Pretend that someone has decided they want to help U work on the proj. Cloning remote repo is an essential part of being able to collaborate with other people on a Git proj.

#### The Collboration simulation

If two people are working on the same proj -- each will have a local repo on their own computer, and each will contribute to one remote repository. Fore, are going to clone the remote repository onto your computer and create a second local repository, which U will call `friend-rainbow`fore.

In Git, use the `clone`to refer to the process of copying a remote onto a computer to create a local repostiory and the comand like `git clone <URL> <directory_name>`

```sh
git clone https://... friend-rainbow
cd friend-rainbow
git remote -v
git branch --all
git log
```

For the `git branch`command output, shows a pointer called `origin/HEAD`that points to the `origin/main`remote-tracking branch. When clone a repository, Git needs to know which branch it should be on when it’s done cloning. The `origin/HEAD`pointer determines which branch this is. For this, point to the `origin/main`tracked branch. By contrast, noticed that in the `rainbow`you are currently on the `feature`branch.

#### Cloning Repositories and Different Types of Branch

In the `git log`-- can see that in the `friend-rainbow`repository there is no reference to the `feature`branch. However, there is a reference to the `origin/feature`remote-tracking branch. This is cuz when clone a repository the `git clone`will create remote-tracking branches for all the branches currently present in the remote repository that is being cloned.

For your firend to work on the `feature`, they must switch onto it. Then Git will create a local `feature`.

```sh
git branch --all
git switch feature
git branch --all # *feature
```

Have jsut learned how to switch onto and create new LOCAL branches based OFF Remote-Tracking branches that you downloaded froma remote repository. -- And, why the new repository already has the `ORIGIN`shortname.

#### The `Origin`shortname

Fore, to work with the remote repository, had to explicitly associate its URL with a shortname using the `git remote add <shortname> <URL>`command -- However, in the cloned `git remote`output, saw that you already have the `origin`shortname listed. -- means that the `friend-rainbow`repository already has the remote repository URL associated with the shortname `origin`. Cuz it was directly cloned from a remote repository. At the time of cloning the remote repository URL was assicated with a shortname in the local repository, and `origin`is the default shortname Git associates with a remote repository when clone it.

#### Deleting Branches

The main reason to delete is to keep a Git proj organized and uncluttered. And, before deleting, you should always make sure that either you have merged it into another, or don’t want to sue any of the work. To fully delete a branch, need to delete the remote branch, the remote-tracking, and the local branch:

```sh
# delete a remote branch and a remote-tracking branch
git push <shortname> -d <branch_name>
# delete a local branch
git branch -d <branch_name>
##
git branch --all
git push origin -d feature # note that the origin shortname
git switch main
git branch -d feature
```

## Data Types

- Common mistakes related to basic types
- Fundamental concepts for slices and maps to prevent possible bugs, leaks, or inaccuracies
- Comparing values

### Creating confusion with octal literals

Octal integers are useful in different scenarios -- like:

```go
file, err := os.OpenFile("foo", os.O_RDONLY, 0644)
```

### Understanding Slice length and capacity

In Go, a slice is backed by an array -- that means that slice’s data is stored contiguously in an array data structure. A slice also handles the logic of adding an element if the backing array is full or shrinking the backing array.

Internally, a slice holds a poitner to the backing array plus length and capacity. The capacity is the *number of elements in the backing array*. `s := make([]int, 3, 6)`, So will initialize only the first 3 elements. Accessing an element outside the length range is forbidden.

```go
s = append(s, 3, 4, 5)
```

For this, an array is a fixed-size structure, it can store the new elements until element 4.  When want to insert element 5, the array is already full. The slice now references the new backing array -- like:

```go
s1 := make([]int, 3, 6)
s2 := s1[1:3] // two len, five cap note 6-1
s2 = append(s2, 2)
```

### Slice initialization effeciently

While initializing a slice using `make`, have to provide a length and an optional capacity. Forgetting to pass an appropriate value for both of these parameters when it makes sense is widespread mistake. Fore, implement a `convert`func that maps a slice of `Foo`into a slice of `Bar`like:

```go
func convert(foos []Foo) []Bar {
    bars := make([]Bar, 0)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

This logic for creating another array -- repteated mutiple times when add a 3rd element.. Assuming the input slice has 1000 element, this algorithm requires allocating 10 backing arrays, and copying more than 1000 elements in total. And this leads to additional effort for the GC to clean all these temporary backing arrays.

And there are two different options for this -- 

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]bar, 0, n)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

Internally, Go preallocates an array of `n`elements. Therefore, adding up to *n* elements means reusing the same backing array and hence reducing the number of allocations drastically, and the second like:

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, n)
    for i, foo := range foos {
        bars[i]= fooToBar(foo)
    }
    return bars
}
```

For this, cuz we initialize the slice with a length, `n`elements are already allocated and initialized to the zero value.

### `nil`vs. *empty* slices

Go developers frequently mix `nil`and *empty* slices -- may want to use one over the other depnding on the use case.

- A slice is empty if its length is equal to 0
- A slice is `nil`if it equals `nil`

```go
func main() {
    var s []string // empty and nil
    s = []string(nil) // empty and nil
    s= []string{} // empty
    s = make([]string, 0) // empty
}
```

There are two things need to note -- 

- One of the main differences between `nil` and an empty slice regards allocations. `nil`doesn’t require any allocation, which isn’t the case of an empty one
- Regardless whether a slice is a `nil`, calling `append`works.

```go
var s1 []string
fmt.Println(append(s1, "foo")) // [foo]
```

Consequently, if a function returns a slice, shouldn’t do in other languages and return a non-nil collection for defensive reasons. Cuz a `nil`slice doesn’t require any allocation, *Should* favor returning a nil slice instead of an empty slice -- fore:

```go
func f() []string {
    var s []string
    if foo() {
        s= append(s, "foo")
    }
    if bar() {
        s= append(s, "bar")
    }
    return s
}
```

In the case we have to produce a slice with a known length, should use `s := make([]string, length)`.

```go
func intsToStrings(ints []int) []string {
    s := make([]string, len(ints))
    for i, v := range ints {
        s[i]= strconv.Itoa(v)
    }
    return s
}
```

### Properly checking if a slice is empty

Fore, call a `getOperations`that returns a slice of `float32`, want to call a `handle`func only if the slice contains elements -- like:

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if operations != nil {
        handle(operations)
    }
}
func getOperations(id string) []float32 {
    // just an empty one
    operations := make([]float32, 0)
    if id == "" {
        return operations
    }
    //...
    return operations
}
```

Should: `if len(operations) != 0`{...}

### Making slice copies correctly

The `copy`built-in function allows copying elements from a source slice into a destination slice. Fore:

```go
src := []int{0,1,2}
var dst []int
copy(dst, src)
fmt.Println(dst)
```

Just return `[]`-- To use `copy`effectively, it’s essential to understand that the number of elements copied to the dest slice corresponds to the mnimum between the source and the dest length. The dst here is zero-length slice cuz it is initialized to its zero value. Just:

```go
src := []int{0, 1, 2}
dst := make([]int, len(src))
copy(dst, src)
```

And, another common mistake to invert the order of the arguments when callin `copy`, also can use:

```go
src := []int {0, 1, 2}
dst := append([]int(nil), src...)
```

For this, append the elements from the source slice to `nil`slice. Hence, this code creats a 3-len, 3-cap slice copy. this alternative has the advantage of being done in a single line.

## Embedding partials

For some applications you might want to break out certain of HTML into *partials* that can be reduced in different pages or layouts. Like:

```html
{{define "nav"}}
<nav>
	<a href="/">Home</a>
</nav>
{{end}}
```

Then update the `base`template so that it invokes the navigation partial using the `{{template “nav” .}}`action. Like: 

```html
{{define "base"}}
<html>
    <head>
        <title>{{template "title" .}} - Snippetbox</title>
    </head>
    
    <body>
        <!-- invoke the navigation template -->
        {{template "nav" .}}
    </body>
</html>
{{end}}
```

#### The `block`action

In the code we have used the `{{template}}`action to invoke one template from another. Go also provides a `{{block}}...{{end}}`action which can use instead. This acts just like the `{{template}}`except it allows U to specify some *default* content if the template being invoked doesn’t exist in the current template set. Fore;

```html
<h1>
    Some template
</h1>
{{block "sidebar" .}}
<p>
    Some default content
</p>
{{end}}
```

### Serving static files

Improve the look and feel of the homepage by adding some static CSS and image files to our project, along with a tiny bit of Js to highlight the active navigation item.

Go’s `net/http`package ships with a built-in `http.FileServer`handler which U can use to serve files over HTTP from a specific directory -- add a new route to our app so that all requests which begin with `/static`are handled using this. The pattern `/static/`is a subtree path pattern, so it acts a bit like there is a wildcard at the end -- To create a new handler, need to use the `http.FileServer()`like:

`fileServer := http.FileServer(http.Dir(“./ui/static/”))`

When this handler receives a request, it will remove the leading slash from the URL path, and then search the `./ui/static`for the corresponding file to send to the user. For this to work correctly, must strip the leading `/static`from the URL path *before* passing it to the `http.FileServer`.

```go
fileServer := http.FileServer(http.Dir("./ui/static/"))
mux.Handle("/static/", http.StripPrefix("/static", fileServer))
```

In Go’s `net/http`package, the `http.StripPrefix`is used to remove a specified prefix from the begining of the request URL’s path, before pass the request to the handler. For our example, if a request comes in for `/static/css/stye.css`file, `http.StripPrefix`will remove the `/static/`and the `http.FileServer`will look for the file in the `static/css/style.css`.

#### Using the static files

With the file server working properly, can now update the `ui/html/base.html`to make use of the static files like:
`<link rel="stylesheet" href="/static/css/main.css">`

### The `http.Handler`interface

Before go any further there is a little theory that should cover -- it is a bit complicated. Thrown around the term *handler* without explaining what it truly means -- Strictly speaking -- Mean by handler is *an object* which satisfies the `http.Handler`interface -- like:

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

In simle tems, this basically means that to be a handler an object must have a `ServeHTTP`method. fore:

```go
type home struct{}
func(h *home) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("..."))
}
```

For this, have an object, and implemented a method with the signature on it. And U could equally be a string or function or anything else. Like:

```go
mux := http.NewServeMux()
mux.Handle("/", &home{})
```

When this servemux receives a HTTP request for `/`, it will then call the `ServeHTTP()`method of the `home`struct.

#### Handler Functions

```go
func home(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("..."))
}
```

This `home`function is just a normal function, Instead can *transform* it into a handler using the `http.HandlerFunc`adapter like:

```go
mux := http.NewServeMux()
mux.Handle("/", http.HandlerFunc(home))
```

The adapter works by automatically adding a `ServeHTTP()`method to the `home`function. When executed, this `ServeHTTP()`then simply *calls* of the original `home`. And can just: `mux.HandeFunc(“/”, home)`some sguar.

#### Chaining Handlers

The `http.ListenAndServe()`also takes a `http.Handler`object as the second parameter -- like:
`func ListenAndServe(addr string, handler Handler) error`

We were able to do this cuz the servemux also has a `ServeHTTP()`.

#### Requests are handled concurrently -- 

There is one more thing that’s really important to point out -- *all incoming HTTP requests* are served in their own goroutine -- for busy servers, this means that it’s very likely that the code. Running concurrently.

### Configuration and error handling

In Go, a common and idiomatic way to manage configuration settings is to use *command-line* flags when starting an application -- fore `go run ./cmd/web -addr=“:80”` And the easiest way to accept and parse a command-line from your app is with a line of code like: `addr := flag.string(“addr”, “:4000”, “HTTP network address”)` This essentially defines a new command-line flag with the name `addr`, default value of `:4000`, and some short text.

```go
func main() {
	addr := flag.String("addr", ":4000", "HTTP network address")
	// Importantly, use the flag.Parse() to parse the command-line flag
	// reads in the command-line flag value and assigns it to the addr variable.
	flag.Parse()
	// 
	//...
	// use the http.ListenAndServe() function to start a new web server.
	log.Printf("Starting server on %s", *addr)
	err := http.ListenAndServe(*addr, mux)
	log.Fatal(err)
}
```

Can also use the `-addr`flag when you start the app like:
`go run  ./cmd/web -addr=“:9999”`

#### Default values

Command-line flags are completely optionally. And in the code used the `flag.String()`to define the command-line -- this has the benefit of converting whatever value the user provides at runtime to a `string`type. Go also has a range of other functions including `flat.Int(), Bool()`and `Float64()`..

Automated help -- and another great feature is that you can use the `-help`flag to list all the available command-line flags.

Environment variables -- `addr := os.Getenv(“SNIPPETBOX_ADDR”)` Fore:

```sh
export SNIPPETBOX_ADDR=":9999"
go run ./cmd/web -addr=$SNIPPETBOX_ADDR
```

#### Leveled logging

Both these functions output messages fore the `log.Printf()`and `log.Fatal()`-- via Go’s *standand logger* -- prefixes messages with the local date and time and writes them to the standard error stream. The `log.Fatal()`functin will also call `os.Exit(1)`after writing the message.

In the app, can break apart our log messages into two distinct types - levels -- Like:

```go
log.Printf("Starting server on %s", *addr)
err := http.ListenAndServe(*addr, mux)
log.Fatal(err)
```

Improve our app by adding some *leveled* logging capability, so that info and error messages are managed slightly differently -- prefix `INFO`and `ERROR`like:

```go
// Create a logger for writing error messages in the same way as:
infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)
errorLog := log.New(os.Stderr, "ERROR\t", log.Ldate|log.Ltime|log.Lshortfile)
// ...
infoLog.Printf("Starting server on %s", *addr)
err := http.ListenAndServe(*addr, mux)
errorLog.Fatal(err)
```

#### Decoupled logging

A big benefit of logging your messages to the std streams like this -- There is one more change we need to make to our app -- by default, if Go’s HTTP server encounters an error it will log it using the std logger.

```go
srv := &http.Server {
    Addr: *addr,
    ErrorLog: errorLog,
    Handler: mux,
}
infoLog.Printf("Starting server on %s", *addr)
err := srv.ListenAndServe()
```

Concurrent logging-- Custom loggers created by `log.New()`are concurency-safe. Can share a single logger and use it across multiple goroutines and in your handlers without needing to worry about race conditions.

Logging to a file -- Gerernal recommendation is to log output to std streams and redirect the output to a file. Also can:

```go
f, err := os.OpenFile("/tmp/info.log", os.O_RDWR|os.O_CREATE, 0666)
if err !=nil {
    log.Fatal(err)
}
defer f.Close()
infoLog := log.New(f, "INFO\t", log.Ldate|log.Ltime)
```

