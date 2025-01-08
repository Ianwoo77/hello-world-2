# Branches (rev)

There are two main reasons to use branches -- 

- To work on the same project in different ways
- To help multiple people work on the ame project at the same time.

Each of these branches is a standalone version of the project. One common for working with branches is to have one official primary line of development -- The main or primary branch - And off of that to reate secndonary branches. These topic branches are *short-lived* -- ultimately combined or incorporated back into the primary branch and then deleted. Fore, in the `git log`ouput, next to the commit hash inside the parentheses `HEAD->main`. So the branch or branches that appear inside the `()`.

#### Master and Main

Normally when initialize a local repository using just the `git init`with no options, `master`is created. Can use the `git init -b`option pass the value `main`.

#### Unmodified and modified Files

Git knows about the `rainbowcolors.txt`file cuz it has been included in a commit. Tracked files in the working directory can be in one of two states. For *unmodified* files are files in the working directory that have not been edited since the last commit. `git status`command -- shows U the state of the working directory and the staging area and the difference between the two.

```sh
git add rainbowcolors.txt
git status
```

### Making commits on Branch

Ready to make your second commit in the `rainbow`-- 

```sh
git commit -m "orange"
git log
```

- Made a new commit, the orange, in the `rainbow`-- your commit hash will be different
- The `HEAD->main`appears in `()`next to the orange commit.

Note that to check which commit is the parent of a given commit, Can use the `git cat-file`command with the `-p`option and pass in a commit hash -- like: `git cat-file -p <commit-hash>`like:

```sh
git cat-file -p <hash> # tree ..parent... author.. committer...
```

In this, can see the next to the `parent`it references the commit hash of the red commit in this.

#### Creating a Branch

For now just only have local branch `main`-- To list the branches in a local repository, can use the `git branch`command. like:

```sh
git branch
git branch <new_branch_name>
git branch feature
git log # can see main and feature both point to the orange commit
```

What is Head? -- At any given point in time, you are looking at particular version of your project -- U are on a particular branch which is pointing to a commit -- `HEAD`is simply a ponter that tells U which branch U are on. HEAD->main.

#### Switching Branches

Have two branches, `main`and `feature`. Like:

```sh
git switch <branch_name>
git checkout <branch_name>
```

Note that the only purpose of the `git switch`command is to switch branches, while the `git checkout`command can do more things. The `git switch`does 3 things -- 

1. Changes the `HEAD`pointer to point to the branch U are switching onto.
2. Pupulates the staging area with a *snapshot* of the commit U are switching onto.
3. It *copies* the contents of the staging area into the working directory.

In short, when change branches, U end up changing the commit that you are looking at. Provided at the two branch point to two different commits.

```sh
git switch feature
```

#### Working on a Separate Branch

now on the `feature`-- going to add the color yellow fore like: `git add...`-- As mentioned, when make a comit, it is branch you are currently on that updates to point to the new commit. The `main`and `feature`branches no longer point to the same commit.

## Misusing `init`functions

An `init`is a function used to initialize the state of an application. It takes no arguments and returns no values. And when a package is initialized, all the constant and variable declarations in the package are evaluated. Then the `init`functions are executed. Fore:

```go
package main
var a = func() int {
    fmt.Println("var")
    return 0
}() // executed first

func init() {
    fmt.Println("init")  // second
}
func main() {...}
```

Note that an `init`function is executed when a package is initialized, in the following example -- like:

```go
func init() {...}
func main() {
    err := redis.Store("foo", "bar")
}
```

For this, `main`depends on `redis`-- *the `redis`package’s `init`function is executed first*, followd by the `init`of the `main`package, and then the `main`itself. Can define multiple `init`functions per package. When do, the execution order of the `init`inside the package is based on the source file’s *alphabetical* order. Can also define multiple `init`functions within the same source file.

Can also use the `init`for side effects. Fore: using the `_`opeator this way like:

```go
package main

import (
	"fmt"
    _ "foo"
)
```

`foo`package is initialized before the `main`. Hence, the `init`function of `foo`are executed. And note that the `init`function can’t be invoked directly.

### When to use `init`

Fore, holding a dbs connection pool. In the `init`function, open a dbs using the `sql.Open`like:

```go
var db *sql.DB

func init() {
    dataSourceName := os.Getenv("MYSQL_DATA_SOURCE_NAME")
    d, err := sql.Open("mysql", dataSourceName)
    if err != nil {
        log.Panic(err)
    }
    err = d.Ping()
    if err != nil {
        log.Panic(err)
    }
    // assigns the DB connection to the global db variable
    db = d
}
```

For this, open the dbs, check whether we can ping it, and then assign it to the global variable. For this, 3 main downsides -- 

1. Error management in an `init`function is just limited, as an `init`doesn’t return an error, one of the only ways to signal an error is to panic, leading the app to be stopped.
2. Related to testing. If add tests to this file, the func will be executed before running the test cases, which isn’t necessarily what we want.
3. The example requires assigning the dbs connection pool to a global variable. Have some severe drawbacks like:
   - Any funcs can alter this
   - Unit tests can be more complicated

For these reasons -- like:

```go
func createClient(dsn string) (*sql.DB, error) {
    db, err := sql.Open("mysql", dsn)
    if err != nil {
        return nil, err
    }
    if err = db.Ping(); err != nil {
        return nil, err
    }
    return db, nil
}
```

Using this, tackled the main downsides discussed -- 

- The reponsibility of error handling if left up to the caller
- It’s possible to crate an integration test to check this function works.
- The connection pool is encapsulated within the function.

There are still use cases where `init`function can be helpful -- like:

```go
func init() {
    redirect := func(w http.ResponseWriter, r http.Request) {
        http.Redirect(w, r, "/", http.StatusFound)
    }
    http.HandleFunc("/blog", redirect)
    http.HandleFunc("/blog/", redirect)
    
    static := http.FileServer(http.Dir("static"))
    http.Handle("/favicon.ico", static)
    //...
    http.Handle("/lib/godoc/", http.StripPrefix("/lib/godoc/", 
                                                http.HandlerFunc(staticHandler)))
}
```

`http.HandleFunc`can panic, only if the handler is `nil`.

## Web app -- 

- The first thing need is a *handler* -- Can think of handlers as being bit like controllers. responsible for executing your app logic and for writing HTTP response headers and bodies.
- Router -- stores a mapping between the URL patterns for your application and corresponding handlers.
- web server -- Go can establish a web server and listen for incoming requests as part of your application.

```go
func home(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello from Snippetbox3"))
}
func main() {
	// initialize a new servemux, then register the home functions
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)

	// use the http.ListenAndServe() function to start a new web server.
	log.Println("Starting server on :4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}
```

The `http.ResponseWriter`for assembling a HTTP response and sending it to the user, and the `*http.Request`is a pointer to a struct which holds info about the current requests. When run, start a web server listening on port 4000 of your local machine. Each time the server receives a new HTTP request it will pass the request on to the servemux.

### Routing Requests

Having a web app with just one route is not exicting so like:

```go
func snippetView(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Display a specific snippet..."))
}

func snippetCreate(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Create a new snippet..."))
}

func main() {
	// initialize a new servemux, then register the home functions
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)
	mux.HandleFunc("/snippet/view", snippetView)
	mux.HandleFunc("/snippet/create", snippetCreate)

	// use the http.ListenAndServe() function to start a new web server.
	log.Println("Starting server on :4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}
```

#### Fixed path and subtree patterns

Now that the two new routes are up and running, -- a bit of theory -- Go’s servemux supports two different types of URL patterns -- *fixed paths* and *subtree* paths. Fixeds don’t end with a `/`. Fixed path patterns like these are only matched when the request URL path *extractly* matches the fixed path.

Can think of subtree paths as acting a bit like they have a wildcard at the end like: `/static/`just fore `/static/**`. This helps explain why the `/`pattern is acting like a *catch-all*.

#### Restricting the root URL pattern

So what if don’t want the `/`pattern to act like a *catch-all*. And for this, only if the request URL path exactly matches the `/`-- otherwise, want the user to receive a 404. Fore:

```go
func home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        http.NotFound(w, r)
        return
    }
    //...
}
```

The `DefaultServeMux`-- come across the `http.Handle()`and `http.HandleFunc()`functions, these allow U to register routes *without* declaring a servemux like:

```go
func main() {
    http.HandleFunc("/", home)
    http.HandleFunc("/snippet/view", snippetView)
    //...
    err := http.ListenAndServe(":4000", nil)
    log.Fatal(err)
}
```

Behind the scenes, these register their routes with sth called the `DefaultServeMux`. 
`var DefaultServeMux= NewServeMux()`-- Don’t recommand it for production apps -- cuz -- `DefaultServeMux`is a *global variable* -- any package can access it and register a route.