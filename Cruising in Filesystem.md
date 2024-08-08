# Cruising in Filesystem

- Moving quickly to a specific directory
- Returning rapidly to a directory U’ve visited before

### Jump to your Home Directory

Begin with the basics -- no matter where you go in the filesystem, can return to your home directory by running `cd`with no arguments -- like:

```sh
pwd
cd # with no arguments then are home again
```

To jump to sub-directories within your home directory from anywhere in the filesystem, refer to your home with a shorthand rather than an absolute path. And to jump back and forth between a pair of directories.

```sh
cd -
```

#### The seq command

prints a sequence of numbers in a range like `seq 1 5`, 

```sh
seq 1 2 10 # step 2
seq 3 -1 0
seq -s/ 1 5
seq -w 8 10 # makes all with the same width
echo {A..z} | tr -d ' ' # delete spaces must use this
echo {A..Z} | tr ' ' '\n'
```

#### The find command

List command lists files in a directory recursively, descending into subdirectories and printing full paths.

```sh
find . -type f -print
find . -type d -print
find . -iname "*.txt" # case insensitive match
```

## Git Branches

A new diagram called the *Repository Diagram*-- includes only a representation of the commit history of a repository and the relevant branches and references. The local repostiory is represented by a rectangle.

### Why uses Branches--

- To work on the same project in just different ways
- To help multiple people work on the same project at the same time.

Can think of a branch like a line of development -- A Git proj can have multiple branches -- each of these is a standalone version of the project. Different git Projects can use branches in different ways, depending on the needs of people working on the project.

One common pattern for working with branches is to have one official primary line of development -- The main or primary branch -- and off of that to create secondary branches, called *topic branches* or *feature branches*, that are used to work on just a specific part of the project. These topic branches are short-lived, ultimately combined or incorporated back into the primary branch and then **deleted**. The two processes U can use to integrate one branch to another are called *mgering* and *rebasing*.

Example commands for `git init`-- 

- Create a bare repository : `git init --bare`
- Create a repository with a custom initial branch -- `git init -b main`

For the example repositiory -- `git log`-- next to the commit hash inside the parentheses you can see `HEAD->main`

SO the branch or branches appear inside the partnese next to particualr commit hash in the `git log`output are branches that point to that commit. `cd /.git/refs/heads`-- *refs* stands for *references* -- and the `heads`directory stores a file for each local branch in your local repository. At the moment, only have one local branch the `main`.

Note that the `master`is not considered inclusive terminology, A large part of the Git community has decided to transition to using `main`or the other names as the default branch name. The actual word `main`is not special in any ay. When made the first commit in the `rainbow`repository, this update the `main`branch to point to the first commit. For the app, note that the `master`branch there is nothing special about this branch.

#### Unmodified and Modified Files

Git knows about the `txt`file cuz it has been included in a commit, and therefore it is a tracked file. Note that the *tracked* in the working directory can be in one of two states.

*Unmodified* are files in the working directory that have not been edited since the last commit. Once a file in the working directory has been edited, it just becomes a *modified* file. Note tht the `git status`command actually shows a list of all *modified* files and tells U whether or not they have been added to the staging area.

Then need to add file to the staging area so that it can be included in your next commit.

```sh
git add readme.md
git status
```

The ifle is staged for commit, in other words, it has been added to the staging area. Next, you will make another commit and see how affects your `main`branch.

```sh
git commit -m "orange"
```

- Made a new commit, the orange commit, in the rainbow repository.
- There is a second commit, the orange commit
- the orange commit points back to red 
- The `main`points to the orange commit now.

Means every commit other than the very first one in a repository, has a parent comit -- the *parent commit* of the orange commit is the red commit. Can visualize the commit history and keep track of what work has been done.

And, to check which comit is the parent of a given comit, can use the `git cat-file`command with -p option and pass in commit hash -- `git cat-file -p <commit-hash>`

```sh
git cat-file op '<first 7 character in log file>'
```

With this output, can see that next to `parent`it refrences the commit hash of the red commit.

## Channels

Are one of the synchronization primitive in Go derived rom CSP. To declare a unidirectional channel, simply include the `<-`operator -- like: `var dataStream <-chan any`.

Fore, can cause deadlocks if don’t structure your program correctly -- take a look fore:

```go
stringStream := make(chan string)
go func() {
    if 0!=1 {
        return
    }
    stringStream <-"hello channels" // never run
}()
fmt.Println(<-stringStream)
```

When then anonymous goroutine exits, Go correctly detects that all goroutines are asleep, and reports a deadlock, explain how to structure our programs as a first step toward preventing deadlocks. Just like:

`sal, ok := <-stringStream`

Boolean just indicate whether the read off the channel was a value generated by a write else in process -- or default value from a closed ones. 

Close -- it’s very usefl to able to indicate that no more values will be sent over a channel, this helps downstream porcesses know when to move on, exit, reopen communications on a new each type. like:

```go
valueStream := make(chan any)
close(valueStream)
// can also read from a closed one
intStream:= make(chan int)
close(intStream)
integer, ok := <-intStream // false 0
```

This just opens up a few new pattern -- *ranging* over a channel -- `range`used:

```go
intStream := make(chan int)
go func() {
    defer close(intStream)
    for i:=1; i<=5; i++ {
        intStream <- i
    }
}()
for integer := range intStream {
    fmt.Printf("%v", integer)
}
```

Note that Closing a channel is also one of the ways you can signal multiple goroutines simultaneously -- If have `n`goroutines waiting on a single channel, instead of writing `n`times to the channel to unblock each goroutine, Can simply close the channel. Since a closed can be read from an infinite number of times -- it doesn’t matter now many goroutiens are waiting on it.

```go
begin := make(chan interface{})
var wg sync.WaitGroup
for i:=0; i<5; i++ {
    wg.Add(1)
    go func(i int) {
        defer wg.Done()
        <-begin
        fmt.Printf("...")
    }(i)
}
close(begin)
wg.Wait()
```

| Operation | Channel State      | Result                   |
| --------- | ------------------ | ------------------------ |
| *Read*    | `nil`              | Block                    |
|           | Open and not Empty | Value                    |
|           | Empty              | Block                    |
|           | Closed             | <Default value>, `false` |
| *Write*   | `nil`              | Block                    |
|           | open and full      | Block                    |
|           | Open not full      | Write                    |
|           | Receive only       | Compile error            |
| *Close*   | `nil`              | panic                    |
|           | Open not empty     | closes channel           |
|           | Open and empty     | Closes                   |
|           | Closed             | panic                    |
|           | Receive ony        | Compile error            |

Just note that `Close(receive_only_channel)`will result compile error.

### Select Statement

The `select`statement is the glue that binds channels together -- it’s how we are able to compose channels together in a program to form larger abstractions. If channels are the glue that binds goroutines together -- what does say about the `select`--  can find `select`statements binding together channels locally, within a single function or type, and also globally, at the intersection of two or more components in a system. 

```go
var c1, c2 <-chan any
var c3 chan<- any
select {
case <-c1:
case <-c2:
case c3<-struct{}{}:
}
```

A `select`block encompasses a series of `case`statements that guard a series of statements. Fore:

```go
c1 := make(chan any); close(c1)
c2 := make(chan any); close(c2)
var c1Count, c2Count int
for i:=1000; i>=0; i-- {
    select {
    case <-c1:
        c1Count++
    case <-c2:
        c2Count++
    }
}
```

And, what happens if there are *never* any channels that become ready - if there is nothing useful U can do when all the channels are blocked. Fore, Go’s `time`package provdies an elegant way to do this with channels that fits nicely within the paradigm of `select`statement -like

```go
var c <-chan int
select {
case <-c:
case <-time.After(1*time.Second):
    ...
}
```

So the `time.After`takes ina `time.Duration`argument and returns a channel that will send the current time after the duration you provide it. This ofers a concise way to time out in `select`statements. Namely-- what happens when no channel is ready, and need to so sth in the meantime -- like the `case`, `select`also allows for a `default`clause:

```go
start := time.Now()
var c1, c2 <-chan int
select {
case <-c1:
case <-c2:
default:
    ...
}
```

Can see that it ran the `default`statement almost instantaneously. This allows to exit a `select`block without blocking. Usually, see a `default`clause used in conjunction with a `for-select`loop. This allows a goroutine to make progress on work while waiting for another goroutine to report a result -- like:

```go
done := make(chan any)
go func() {
    time.Sleep(5*time.Second)
    close(done)
}()
workCounter := 0
loop:
for {
    select {
    case <-done:
        break loop
    default:
    }
    // simulating some work
    workCount++
    time.Sleep(time.Second)
}
```

`select{}`-- this will simply block forever.

### When to use Channels or Mutexes

Given a concurrency problem, may not always be clear whether we can implement a solution using channels or mutexes. Cuz Go promotes sharing memory by communiation, one mistake could be to always force the use of channels, regardless of the use case.

Brief reminder about channels in Go -- Channels are communication mechanims -- internally, a channel is a pipe we can use to send and receive values and that allows us to connect concurrent goroutines.

- *unbuffered* -- The sender blocks until the receiver is ready
- *buffered* -- The sender blocks only when buffer is full

Fore, `G1`and `G2`are parallel -- may be two executing the same function. On the other hand, `G1`and `G3`are concurrent goroutines, as are `G2`and `G3`.

Parallel goroutines have to sync -- when they need to access or mutate a shared resource such as a slice. Conversely, in general, concurrent have to coordinate and orchestrate -- fore, if `G3`needs to aggregate results from both `G1`and `G2`, These two need to signal to `G3`that a new intermediate result is available.

## Dependency Injection

There is one more problem with our logging that we need to address. If open up `handles.go`file notice that the `home`handler function is still writing error messags using `Go`'s std logger. like:

```go
func home(w http.ResponseWriter, r *http.Request) {
    ts, err := template.ParseFiles(fiels...)
    if err != nil {
        log.Println(err.Error()) // isn't using new error logger.
        //...
        return
    }
    
    err = ts.ExecuteTemplate(w, "base", nil)
    if err != nil {
        log.Println(err.Error()) // also not using new logger
        //...
    }
}
```

And this question generalizes further, Most web applications will have multiple dependencies that their handlers need to access, such as dbs connection pool, centralized error handlers, and template caches. Namely *How can we make any dependency available to our handlers?*

The simplest being to just put the dependencies in global variable -- but in general, it’s good practice to *inject dependencies* into handlers. It makes your code more explicit, less error-prone and easier to unit test than if U use global variables.

For applications where all your handlers are in the same package, a neat ay to inject dependencies is to put them into a custom `application`struct, then just define handler functions as methods against `application`.

```go
type application struct{
    errorLog *log.Logger
    infoLog  *log.Logger
}
```

Then in the `handlers.go`update handlers so that they become methods against the `application`struct like:

```go
func (app *application) home(w http.ResponseWriter, request *http.Request) {
    if r.URL.Path != "/" {
        http.NotFound(w,r)
        return
    }
    
    files := []string {
        //...
    }
    ts, err := template.ParseFiles(files...)
    if err != nil {
        app.errorLog.Println(err.Error())
        //...
    }
}

// Also change the signature of the `snippetView` handler so defined as a method
func(app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id < 1 {
        http.NotFound(w,r)
        return
    }
    //...
}

// Also change the signature of the snippetCreate handler
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
    if r.Method!=http.MethodPost {
        //...
        http.Error()
    }
}

// in the main
func main(){
    //...
    app := &application {
        errorLog: errorLog,
        infoLog: infoLog
    }
    //...
    mux.HandleFunc("/", app.home)
    mux.HandleFunc("/...", app.snippetView)
}
```

For this, as the appliation grows, and our handlers start to need more dependencies.

#### Adding a deliberate error

The pattern that using to inject dependencies won’t work if handlers are spread acorss multiple packages. In that case, an alternative approach is to create a `config`package exporting an `Application`struct and have your handler functions close over this to from a *closure* just like:

```go
func main(){
    app := &config.Appliation{
        ErrorLog: log.New(os, Stderr, "ERROR\t", log...)
    }
}

func ExampleHandler(app *config.Appliation) http.HandlerFunc {
    return func(w http.ResposneWriter, r *http.Request) {
        ts, err := template.ParseFiles(files...)
        if err != nil {
            //...
        }
    }
}
```

### Centralized error handling

Neaten up our app by moving some of the error handling code into helper methods. This will help *separate our concerns* and stop us repeating code as we progress through the build.

```go
// The serveError writes an error message and stack trace to the errLog.
func (app *application) serveError(w http.ReponseWriter, err error) {
    trace := fmt.Sprintf(...)
    app.errorLog.Println(trace)
    
    http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

// clientError sends a specific status code and corresponding description to the user
func(app *application) clientError(w http.ResponseWriter, status int) {
    http.Error(w, http.StatusText(stuats), status)
}

// Just for consistency, implement a NotFound
func (app *appliation) notFound(w http.ResponseWriter) {
    app.clientError(w, http.StatusNotFound)
}
```

Then in the `main.go`-- 

```go
ts, err := template.ParseFiles(files...)
if err != nil {
    app.serveError(w, err)
    return
}

err = ts.executeTemplate(w, "base", nil)
if err != nil {
    app.serveError(w, err)
}
```

### Isolating the application routes

For the `main()`is biginning to get a bit crowded, keep it clear and focused like to move the route declarations for the app into a standalone `route.go`file like:

```go
func (app *application) routes() *http.ServeMux {
    mux := http.NewServeMux()
    fileServer := http.FileSerer(http.Dir("./ui/static/"))
    mux.Handle("/static/", http.StripPrefix("/static", fileSever))
    mux.HandleFunc("/", app.home)
    mux.HandleFunc("/snippet/view", app.snipView)
    mux.HandleFunc("/snippet/create", app.snippetCreate)
    return mux
}

// Can updte the main.go like
func main(){
    //...
    srv := &http.Server{
        Addr: *addr, 
        ErrorLog: errorLog,
        Handler: app.routes(),
    }
    //...
    err := srv.ListenAndServe()
}
```

Driven responses

### Setting up MySQL-- 

```sh
mysql -u root -p
```

```sql
-- Create a `snippets` table.
CREATE TABLE snippets (
    id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created DATETIME NOT NULL,
    expires DATETIME NOT NULL
);

-- Add an index on the created column.
CREATE INDEX idx_snippets_created ON snippets(created);
```

For this, each record in this table have an integer id -- short text `title`and the snippet content itself will stored in the `content`field. Also keep some metadata about the imtes that the snippet was created and when it expires. Also adds some placeholder entries to the `snippets`table.

#### Create a new user

```sql
CREATE USER 'web'@'localhost';
grant select, insert, update, delete on snippetbox.* to 'web'@'localhost'
ALTER USER 'web'@'localhost' identified by 'pass';
-- ...
mysql -D snippetbox -u web -p
```

