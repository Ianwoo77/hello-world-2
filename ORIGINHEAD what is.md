# `ORIGIN/HEAD`what is

Noticed that there is a pointer called `origin/HEAD`int the `friend-rainbow`repository -- When U clone a repository, Git needs to know which branch is should be on when it’s done cloning -- the `origin/HEAD`pointer determines which branch this is. In the origin `rainbow`project, `origin/HEAD`points to the `main`. 

By contrast, noticed that in the `rainbow`repository you are currently on the `feature`branch -- but the in the `friend-rainbow`, the local `feature`doesn’t even exist.

In the `friend-rainbow`, there is a reference to the `origin/feature`. For your friend on the feature, they must switch onto it like:

```sh
git switch feature
git branch --all # *feature
```

In this step, Can see that there is a new *local* `feature`branch and your friends on it. Learn why the `friend-rainbow`**already** has `ORIGIN`shortname assigned to the connection to the remote repository.

### The `ORIGIN`shortname

Learned that for a local repository to communicate with a remote repostiory, the local repository must have a connection with a shortname to the remote repository stored within it. To work with the remote repository, had to explicitly associate its URL with a short name using the `git remote add <shortname> <URL>`command. And this is cuz U created the `rainbow`repository locally using the `git init -b`.

However, for the step 3, U just saw that you already have the `origin`shortname listed -- this means the `friend-rainbow`repository already has the remote repository URL associated with the short name `origin`. This is just because friend’s local repository did not originate locally -- was directly cloned from a remote repository. At the time of cloning the remote repository URL was associated with a shortname in the local repository, and `origin`is the default shortname Git associates with a remote repository when clone it.

#### Deleting Branches

The main reason to delete branches is to keep Git project  organized and uncluttered. To fully delete a branch, U need to delete the remote branch, the remote-tracking branch, and the local branch. NOTE -- When delete a branch with commits that are not part of any other branch -- don’t delete the commits that are part of the branch -- The commits still exist in your commit history. Just no longer easy to reach. 

To delete a remote branch and a remote-tracking branch, need to use:

```sh
git push <shortname> -d <branch_name>
```

And to delete a local branch, just use the `git branch -d`like 

```sh
git branch -d <branch_name>
git push origin -d feature
git branch --all
git switch main
git branch -d feature
git branch --all
```

In step 2 deleted the remote `feature`and the `origin/feature`remote-tracking branch. Then deleted the local `feature`branch. And can see in the `rainbow`there is still a `feature`and an `origin/feature`. -- The fact that your friend deleted in their repository does not affect your `rainbow`repository. Now need to learn how the collaboration works when your friend starts contributing to the Rainbow project.

### Git Collaboration and Branches

Teams also may have rules about how to manage branches -- fore, there may be convention about -- 

- which branches are allowed to be merged into one another
- when branches need to be created
- what the review process for work on a branch should be.

An example of a rule that U may encounter in a Git proj is that individual should work only on their won topic branches and avoid working on other people’s topic branches. This just helps avoid merge conflicts -- we won’t apply this rule to the rainbow.

#### Making a commit in the local Repository

Fore, friend is going to add a note about the color green to the md of `main`of their local repositor.

```sh
# make some changes in the text, add `green` fore.
git add readme.md
git commit -m "green2"
```

- The local `main`branch has updated to point to the green2 commit
- The `origin/main`remote-tracking branch still ponits to the green commit.

Remote-tracking branches represent the state of remote branches. At this point there is no way for U to have the green2 commit in the `rainbow` there is a two-step process -- 

1. The local with the chagnes has to explicitly *push* those changes to the remote repository
2. The local without changes has to explicitly *fetch* and integrate the changes.

#### Pushing to the Remote repository

If the local branch has an upstream branch defined for it - can use the `git push`with no arguments and Git will automatically push the work to that branch. if no upstream bracnh defined for local branch you are now work on, need to specify which remote branch to bush to when enter the `git push`. An upstream branch is the remote branch that a particular local branch tracks -- when clone a repository, upstream are *automatically* setup for branches.

```sh
git branch -vv # tells u whether a local is a ahead or behind the upstream branch
git status
```

`git branch -vv`output shows that the upstream branch set up for a local `main`is the remote branch in the remote repository with shortname `origin`and that local `main`is ahead one commit.

```sh
git push
git status
git log
```

`git log`output indicates that in the `friend-rainbow`the `origin/main`remote-trcking branch has updated to point to the green2 commit. Next, want to make sure that the local `main`in the `rainbow`is in *sync* with the `main`in the `rainbow-remote`repository.

## Functional options pattern

The main idea is as follows -- 

- An unexported struct holds the configuration `options`.
- Each option is a func that returns the same type `type Option func(options *options) error`.

```go
type options struct {
    port *int
}
type Option func(options *options) error

func WithPort(port int) Option { // return an closure func
    return func(options *options) error {
        if port < 0 {
            return errors.New("port should be positive")
        }
        options.port= &port
        return nil
    }
}
// using these like:
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err = &opt(&options)
        if err != nil {
            return nil, err
        }
    }
    var port int
    if options.port == nil {
        port= defaultHTTPPort
    }else {
        //...
    }
}
```

### Project misorganization

Just shows a common way of structuring a proj and then discusses a few best practices -- For `Foo`proj fore:

- `/cmd`-- main source files, The `main.go`of a `foo`application should live in `/cmd/foo/main.go`.
- `/internal`-- Private code that don’t want others importing for their apps or libs.
- `/pkg`-- Public code that want to exposes to others
- `/test`
- `/configs`
- `/docs, /examples`
- `/api`-- API contact files, fore, Swagger... 
- `/web`-- Web app specific assets -- *static files, etc.*
- `/build`-- Packaging and continuous integration files
- `/scripts`-- Scripts for analysis
- `/vendor`-- application dependencies.

#### Package organization

In Go, note there is no concept of subpackages -- can decide to organize packages with subdirectories. Fore:

/net
	/http
		client.go
		...
	/smtp
		auth.go

`/net`acts both a package and a directory that contains other packages. For `net/http`just doesn’t inherit from `net`or have specific access rights t the `net`package. Elements inside of `net/http`just can only see exported `net`elements.

And, regarding packages, there are multiple practices should follow -- should avoid premature packaging, cuz might cuz us to overcomplicate a proj. Should also having dozens of nano packages containing only one or two files.

#### Don’t create `utility`packages

The section discusses a common bad practice -- creating a shared packages such as `utils, common`, and `base`.

```go
package util
func NewStringSet(...string) map[string]struct{} {
    //...
}
func SortStringSet(map[string]struct{}) []string {
    //...
}
// for client, will use like:
set := util.NewStringSet("c", "b", "a")
fmt.Println(util.SortStringSet(set))
```

For this, the `util`is meaningless -- could call it `common, shared, base`. Remains a meaningless. Instead of this, should create a **expressive package name** such as `stringset`.

We could even go a step further -- instead of exposiing utility functions, could create a specific type and expose `Sort`as a method like:

```go
package stringset
type Set map[string]struct{}
func New(...string) Set {...}
func(s Set) Sort() []string {...}
```

### Don’t ignoring package name collisions

Package collisions occur when a variable name collides with an existing package name -- preventing the package from being used -- like:

```go
package redis
type Client struct {...}
func NewClient() *Client {...}
func (c *Client) Get(key string) (string, error) {...}
//...
redis := redis.NewClient()
v, err := redis.Get("foo")
```

For this, the `redis`variable name collides with the `redis`package name. First option:

```go
redisClient := redis.NewClient()
v, err := redisClient.Get("foo")
```

Can also:

```go
import redisapi "mylib/redis"
//...
redis := redisapi.NewClient()
v, err := redis.Get("foo")
```

And also note that should avoid naming collisions between a variable and a built-in function like:
`copy := copyFile(src, dst)`

### Don’s miss code documentation

Documentation is an important aspect of coding -- it simplifies how clients can consume an API but can also help in maintaining a proj -- In Go, should follow some rules to amke our code idiomatic -- 

First, *every **export** element must be documented*. Whether structure, interface ,function or sth else. like: Convention is to add comments, starting with the name of the exported element

```go
// Customer is a customer representation.
type Customer struct{}

// ID returns the custom identifier.
func (c Customer) ID() string {return ""}
```

Each comment should be a complete sentence ends with `.`.

Deprecated elements -- It’s possible to deprecate an exported element using the `// Deprecated:`like:

```go
// ComputePath returns the fasted path.
// Deprecated: This function uses a deprecated way to compute.
func ComputePath()
```

Might be interested in conveying two aspects -- purpose and content, 

```go
// Purpose: DefaultPermission is the default permission used by the store engine.
const DefaultPermission= 0o644 // Content: need Read and Write access.
```

And, to help clicents and maintainers understand a package’s scope, should also document each packae -- 

```go
// Package math provides basic constants and mathemtical functions.
//
// This package does not guarantee bit-identical results
// across architectures.
package math
```

And documenting a package can be done in any of the Go files -- there is no rule. But in general, should put package documentation in a relevant file with the *same name* as the package or in a specific file such as `doc.go`.

### `nil`and *empty* slices

```go
func main(){
    var s []string // nil empty
    s = []string(nil) // nil empty
    s= []string{} // empty
    s = make([]string, 0) // empty
}
```

- One of the main differences between a `nil`and an emtpy regards allocations
- Regardless of whether `nil`, calling `append`works.

So it can be hepful as syntactic sugar cuz can pass a `nil`slice in a single line like:
`s = append([]int(nil), 42)`

Some libraries distinguish between `nil`and *empty* slices -- fore, `encoding/json`package like:

```go
var s1 []float32
customer1 := customer{
    ID: "Foo",
    Operations: s1,
}
b, _ := json.Marshal(customer1)
fmt.Println(string(b)) // [..., "Operations": null]
s2 := make([]float32, 0)
//...[..., "Operations": []}
```

### Properly checking if a slice is empty -- 

What is the idiomatic way to check if a slice contains elements -- Fore:

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if operations != nil {
        handle(operations)
    }
}
func getOperations(id string) []float32 {
    operations := make([]float32, 0) // not nil
    if id == "" {
        return operations
    }
    return operations
}
```

For this, `getOperations`never returns a `nil`slice, it returns just an empty one. So just:

```go
if id == "" {
    return nil
}
```

How then can we check whether a slice is empty or nil -- check the length -- 

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if len(operations)!=0 { // if nil or empty, false
        ...
    }
}
```

Checking the length is the best option to follow as we can’t always control the approach taken by the functions call.

## Request logging

Add some middleware to *log HTTP* requests -- specifically, going to use the *information logger* that we created to record the IP address of the user, and which URL and method are being requested.

```go
func (app *application) logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.infoLog.Printf("%s - %s %s %s", 
			r.RemoteAddr, r.Proto, r.Method, r.URL.RequestURI())
		next.ServeHTTP(w, r)
	})
}
```

This is prefectly valid to do so -- middleware method now has the same signature as before, but cuz it is a method against `application`, it *also* has access to the handler dependencies including the info logger.
`return app.logRequest(secureHeaders(mux))`

### Panic recovery

In a simple Go app, when code panics it will just result in the application being terminated straight away. Our web app is a bit more sophisticated -- Go’s HTTP server assumes that the effect of any panic is isolated to the goroutine serving the active HTTP request -- Specifically, following a panic our server will log a stack trace to the server error log, unwind the stack for the affected goroutine and close the underlying HTTP connections.

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
	//...	
	panic("oops!, sth went wrong")
    //...
}
```

For this, will get an empty response due to Go closing the underlying HTTP connection following the panic. This is not a great experience for the user -- it would be more appropriate and meaningful to send them a proper HTTP response with a *500 internal server error*.

So a neat way of doing this is to create some middleware which *recovers* the panic and calls our `app.serveError()`.

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// create a deferred func.
		defer func() {
			// use the builtin recover to check if there has been a panic or not.
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				// Call app.serveError returns a 500
				app.serverError(w, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

- Setting the header `Connection: Close`on the response acts as a trigger to make Go’s HTTP server automatially close the current conection after a response has been sent.
- The value returned by the built-in `recover()`has the type of `any`-- its underlying type could be `string, error`mainly -- whatever the parameter passed to the `panic()`.

#### Additional info -- 

Panic receover in other background goroutines -- It’s important to realise that our middleware will only receover panics that executed the `recoverPanic()`middleware -- If fore, have a handler which spins up another goroutine then any pincis that happen in the second goroutine will not be receovered -- not by the `recoverPanic()`middleware.

So is U are spinning up additional goroutines from within your web app and there is any chance of panic, Must make sure that you recover any panics from within those too.

```go
func myHandler(w http.ResponseWriter, r *http.Requeset){
    go func() {
        defer func() {
            if err := recover(); err != nil {
                log.Println(ftm.Errorf("%s\n%s", err, debug.Stack()))
            }
        }()
        dosthbackgroundProcessing()
    }()
    w.Write([]byte("ok"))
}
```

### Composable middleware chains

Introduce the `justinas/alice`package to help us manage our middleare/handler chains -- Don’t *need* to use this package, but the reason recommend it is cuz it make it easy to create composable, reusable, middleware chains -- and can be a real help as your app grows and your routes become more complex -- the package itself small and lightweight -- and the code is clear and well written like:

`return alice.New(middleware1, middleware2, ...).Then(myHandler)` =>
`return middleware1(middleware2(...(myHandler)))`

But the real power lies in the fact that you can use it to create middleware chains that can be assigned to variables, appended to, and reused -- fore:

```go
myChain := alice.New(middleware1, middleware2)
myOtherChain := myChain.Append(middleware3)
return myOtherChain.Then(myHandler)
```

```sh
go get github.com/justinas/alice
```

Then just update the `routes.go`file to use the package -- 

```go
// ...
standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
return standard.Then(mux)
```

### Advanced Routing

In the next section of this book going to add a HTML form to our application so that users can create a new snippets -- To make this work smoothly, First need to update the app routes so that the requests to `/snippet/create`are handled differently based on the request method -- 

- `Get /snippet/create`requests we want to show the user the HTML form for adding a new snippet.
- `POST /snippet/create`want to process this form data and then insert a new `Snippet`record into dbs.

While at it -- there are a couple of other routing - related imporvement that also make -- 

- Restrict all our other routes -- which simply return information -- to only support GET requests
- use clean URLs so that any variables are included in the URL path and not appended as query string.

- `GET /`-- home
- `GET /snippet/view/:id`-- `snippetView`
- `GET /snippet/create` -- `snippetCreate`- display a HTML form
- `POST /snippet/create`-- `snippetCreatePost`-- create a new snippet
- `GET /static/`

### Choosing a router

There a literally hundreds of 3rd-party routers for Go to pick from -- And the all work a bit differently. They have different APIs, different logic for matching routes, and different behavioral quirks.

In our case, our app is fairly small and we don’t need support for anything beyond basic method-based routing and clean URLs -- so for the sake of performance and correctness, opt to use `julienschmidt/httprouter`

#### Clean URLs and method-based routing 

```sh
go get github.com/julienschmidt/httprouter
```

Begin with a simple example to help demonstrate and explain -- 

```go
router := httprouter.New()
router.HandleFunc(http.MethodGet, "/snippet/view/:id", app.snippetView)
```

For this, 

- We initialize the `httprouter`router and then use the `HandlerFunc()`method to add a new route which dispatches requests to our `snippetView`handler function.
- The first arg to `HandlerFunc()`is the HTTP method that the request needs to have to be considered a matching request. using the *Constant* `http.MethodGet`rather than the string `GET`.
- The second arg is the pattern that the request URL path must match. Can include in the form `:name`which act like a wildcrd for a specific path segment -- like `/snippet/view/123`or `/snippet/view/foo`would match our example pattern `/snippet/view/:id`. Patterns can also include a single catch-all fore `*name`fore: `/static/*filepath`. And note that the path `/`will **ONLY** match requests where the URL path is exactly the `/`.

With all that in mind, head over to our `routes.go`file and update it so it uses the `httprouter`like:

```go
func (app *application) routes() http.Handler {
	router := httprouter.New()

	fileServer := http.FileServer(http.Dir("./ui/static/"))

	// dispatch a single handler
	router.Handler(http.MethodGet, "/static/*filepath", http.StripPrefix(
		"/static", fileServer))

	router.HandlerFunc(http.MethodGet, "/", app.home)
	router.HandlerFunc(http.MethodGet, "/snippet/view/:id", app.snippetView)
	router.HandlerFunc(http.MethodGet, "/snippet/create", app.snippetCreate)
	router.HandlerFunc(http.MethodPost, "/snippet/create", app.snippetCreatePost)

	standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
	return standard.Then(router)
}
```

