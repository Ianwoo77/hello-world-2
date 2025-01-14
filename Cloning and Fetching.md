# Cloning and Fetching

After clones the remote repository, you will be working with two local repositories:

```sh
git clone <URL> <directory_name>
git clone https://github.com/...gif friend-rainbow
```

Then can explore its contents and setup like:

```sh
cd friend-rainbow
git remote -v
git branch --all
git log
```

`git branch`shows a pointer called `origin/HEAD`that points to the `origin/main`remote-tracking branch, and that you have an `origin/feature`remote-tracking branch. The `origin/HEAD`pointer determines which branch this is. In the `Rainbow`the `origin/HEAD`points to the `main`, which is why cloned the repository is on the `main`in the `friend-rainbow`repository.

By contrast, just noticed that the `feature`just not existed so:

```sh
git branch --all
git switch feature #branch `feature`set up to track `origin/feature`
```

Discuss why the `friend-rainbow`repostiory already has the `origin`shortname assigned to the connection. -- The local repository must have a connection with a shortname to the remote repository stored within it. For the local, must use `git remote add <shortname> <URL>`. And in the `git remote`command on the `friend-rainbow`, already has the remote repostory URL associated with the shortname `origin`.

#### Deleting Branches

U need to delete the remote, remote-tracking, and local branches like:

```sh
git push <shortname> -d <branch_name>
git branch --all
git push origin -d feature # delete the remote and remote-track
git branch --all
git switch main
git branch -d feature # delete the local branch
git branch --all
```

### Git Collaboration and Branches

may want to discuss what some of your Git conventions should be -- Want to discuss what some of your Git conventions should be. Teams also may have rules about how to manage branches.

- Which branches are allowed to be merged into one another
- When branches need to be created
- What the review process for work on a branch should be.

#### Making a Commit in the local repository

Fore, friend is going to add a note about the color green to the txt file and make a commit on the `main`branch of their local repository.

```sh
# in the friend-rainbow edit rainbowcolors.txt file
git add rainbowcolors.txt
git commit -m "green"
git log # show HEAD->main to green
```

- The local `main`branch has updated to point to the green commit
- The `origin/main`still point to the yellow

As can see the green commit does not yet appear in the `rainbow-remote`repository. Work done in local repositories needs to be explicitly pushed to them.  remote-tracking branches represent the state of remote branches. Since has not yet pushed their changes to the remote, the remote has not updated.

#### Pushing to the remote repository

Git need s some way to know which remote branch you wan to push to. If the local branch has an upstream branch defined for it, can use `git push`with no arguments and Git will *automatically* push the work to that branch. The last time used the `git push <short_name> <branch_name>`cuz had not yet defined an upstream branch for your local branch. `git branch -vv`-- list local and their upstream branches. 

Next, can simply use the `git push`without any arguments like:

```sh
git push
git status
git log # HEAD -> main, origin/main and origin/HEAD
```

### Incorporating Changes from Remote Repository

Noticed that the `rainbow`repository does not yet have the green commit. The reason is cuz local repository do not automatically update with new data from remote repositories.

#### Fetching changes -- 

Term `fetch`refer to the proces of downloading data from a remote repository to a local repository. `git fetch <shortname>`or `git fetch`just fetch data from a remote repository. The `git fetch`affects *only* remote-tracking branches -- does not affect local branches. In other words, only fetches data -- doesn’t actually integrate the data into any local branches.

```sh
git log --all
git fetch
git log --all
```

For this the `git log`ouput shows -- the `origin/main`remote-tracking branch is pointing to the green commit, and the local main branch is still pointing to the yellow commit. Just saw how the `git fetch`comman updated the remote-tracking branch in the local repository for any remote branches.

#### Integrating Changes to a Local Branch

Once you have fetched the changes from a remote repository and updated the remote-trcking branches in a local repository. You are ready to update the local branch. Learned the `FF merges`-- Both `feature`and `main`were local branches in the `rainbow`repo. Going to merge the `origin/main`remote-tracking branch into the local `main`in the `rainbow`. To integrate the commits that were on the `main`in the remote into your local main, just use the `git merge`command like:

```sh
git switch main
git merge origin/main
git log
```

Deleting branches -- In the `rainbow`still have the local `feature`and the `origin/feature`remote-tracking. Used the `git push <shortname> -d <branch_name>`command to delete the remote and remote-tracking. But for now there is no remote `feature`branch any more, so to delete the `origin/feature`just. To delete the local `feature`that corresponding to deleted remote branches and downloaed data from the remote repository using:

```sh
git fetch -p # [deleted] (none)-> origin/feature
git branch -d feature
git branch --all
```

Deleted the `origin/feature`remote-tracking branch, and then delete the local feature.

## Unexpected side effects using slice `append`

Discusses a common mistake when using `append`-- which may have unexpeceted side effects in some situation. Fore:

```go
s1 := []int{1,2,3}
s2 := s1[1:2]
s3 := append(s2, 10)
```

For this, when initialize an `s1`slice containing 3 elements, and s2 is created from slicing s1. Following the second line, after `s2`is created, shows the state of both slices in memory. 

### Slice and Memory leaks

Shows that the slicing an exsiting slice or array can lead to memory leaks in some conditions. Discuss two cases, one where the capacity is leaking and another that’s related to pointers.

#### Leaking Capacity

For the first case, leaking capacity, imagine implementing a custom binary protocol -- a message can contain 1m bytes, and the first 5 represent the message type. In the code, consume these, and 4 auditing purposes like:

```go
func consumeMessage() {
    for {
        msg := receiveMessage()
        storeMessageType(getMessageType(msg))
    }
}
func getMessageType(msg []byte) []byte {
    return msg[:5]
}
```

For this the `getMessageType()`computes the message type by slicing the input slice, however, when deploy our app, noticed that our app consumes about 1GB of memory -- The slicing operation on `msg`using `msg[:5]`creates  5-length slice, its capacity remains the same as the initial slice. The remaining elements are still allocated in memory. The backing array of the slice still contains 1m bytes after the slicing operation. Can:

```go
func getMessageType(msg []byte) []byte {
    msgType := make([]byte, 5)
    copy(msgType, msg)
    return msgType
}
```

Cuz perform a copy, `msgType`is a 5l and 5c slice regardless of the size of the message received.

#### Slice and pointers

Have seen that slicing can cause a leak cuz of the slice capacity -- but what about the elements -- which are still part of the backing array but outside the length range -- 

```go
type Foo struct {
    v []byte
}
```

Want to check the memory allocations after each step as  follows -- 

1. Allocate a slice of 1000 `Foo`elements
2. Iterate over each `Foo`and foreach allocate 1M
3. Call `keepFirstTwoElementsOnly`-- which returns only the first two elements using slicing, and then call `GC`

Want to see how memory behaves following the call to `keepFirstTwoElementsOnly`and a garbage collection.

```go
func main(){
    foos := make([]Foo, 1000)
    printAlloc()
    for i:=0; i<len(foos); i++ {
        foos[i]= Foo {v: make([]byte, 1024*1024)}
    }
    printAlloc()
    two := keepFirstTwoElementsOnly(foos)
    runtime.GC()
    printAlloc()
    runtime.KeepAlive(two)
}

func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    return foos[:2]
}
```

For this, allocate the `foos`slice, allocate a slice of 1MB for each element, and then call `keepFirstTwoElementsOnly`and a `GC`, in the end, use `runtime.KeepAlive`to keep reference to the `two`variable after the GC.

It’s essential to keep the rule in mind when working with slices -- if the element is a pointer or a struct with pointer fields, the elements won’t be reclaimed by the GC. `Foo`contains a slice, the remaining 998 `Foo`and their slice aren’t reclaimed. Also, using the `copy`method like:

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    res := make([]Foo, 2)
    copy(res, foos)
    return res
}
```

### Ineffcient map initialization

A `map`provides an unordered collection of k-v pairs in which all the keys are distinct. In Go, a map is based on the hash table data structure, internally, a hash table is an array of buckets, and each bucket is a pointer to an array of k-v pairs.

Each operations -- CRUD -- is done by associating key to an array index. This step relies on a *hash function*. This func is stable cuz we want to return the same bucket, given the same key, consistently.

Note that in the case of insertion into a bucket that is already full, Go creates another bucket of 8 elements and links the previous bucket to it. Regarding reads, updates, and deletes, Go must calculate the corresponding array index. Then Go iterates sequentially over all the keys until it finds the provided one. Therefore, the worst-case time complexity for these 3 operations is *O(p)*.

#### Initialization

To understand the problems related to inefficient map initialization, create a `map[string]int`fore:

```go
m := map[string]int {
    "1":1,
    "2":2,
    "3":3,
}
```

Internally, this map is backed by an array consisiting of a single entry. If add 1M elements -- a single entry won’t be enough cuz finding a key would mean -- going over thousands of buckets. This is why a map should be able to grow automatically to cope with the number of elements.

When a map grows, it doubles its number of buckets - For the conditions for a map to grow -- 

- The average number of items in the buckets is greater than a constant value, 6.5 for now.
- Too many buckets have overflowed.

Saw when using slices, would initialize it with a given size or capacity -- avoids having to keep repeating costly slice growth operation. Can `make`built-in function to provide an initialz size when creating a map like:
`m := make(map[string]int, 1000000)`Note that there is not a cap.

### maps and memory leaks

When working with maps in Go, need to understand some important characteristics of how a map grows and shrinks. To view a concrete example of this problem, design a scenario where we will work with the following map -- 
`m := make(map[int][128]byte)`So, each value of `m`is an array of 128 bytes, will do the following like:

1. Allocate an empty map
2. Add 1M elements
3. Remove all the elements, and run `GC`.

```go
n:= 1_000_000
m:= make(map[int][128]byte)
printAlloc()

for i:=0; i<n; i++ {
    m[i] = randBytes()
}
printAlloc()
for i:=0; i<n; i++ {
    delete(m, i)
}
runtime.GC()
printAlloc()
runtime.KeepAlive(m)
```

As can see, after removing all the elements, the amount of is significantly less with a `map[int]*[128]`byte type.

## Dependency Injection

There is some more problem with our logging that we need to address. Open up `handlers.go`file, you will notice that the `home`handler function is still writing error messages using Go’s std logger. just like:

```go
func home(w http.ResponseWriter, r *http.Request) {
    ts, err := template.ParseFiles(files...)
    if err != nil {
        log.Println(err.Error())
        http.Error(w, "internal server error", 500)
        return
    }
    //...
}
```

For this, raises a good question -- how can make our new `errorLog`looger available to our `home`function from` main`. Most web apps will have multiple dependencies that their handlers need to access, fore, dbs connection pool, centralized error handlers, and template caches.

For Go, there are a few different ways to do this, the simplest being to just put the dependencies in *global* variables, in  general but, it is a good practice to *inject dependencies* into your handlers -- it makes your code more explicit, less error-prone and easier to unit test if use global variables.

For applications where all your handlers are in the same package, like -- a neat way to inject dependencies is to put them into a custom application struct, and then define your handler functions as methods against the `application`.

In the `main.go`create a new `application`struct like:

```go
// Define to hold the application-wide dependencies for the web app
type application struct {
	errorLog *log.Logger
	infoLog  *log.Logger
}
```

Then in the `handlers.go`file update the handler functions so that they become *methods*.

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
	// ...
	if err != nil {
		app.errorLog.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
		return
	}

	// use the ExecuteTemplate method to dynamically
	// insert the snippetView template into the base template.
	err = ts.ExecuteTemplate(w, "base", nil)
	if err != nil {
		app.errorLog.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
	}
}
```

Finally, need to wrie things together in the main.go file like:

```go
app := &application{
    errorLog, infoLog,
}
// initialize a new servemux, then register the home functions
mux := http.NewServeMux()
fileServer := http.FileServer(http.Dir("./ui/static/"))
mux.Handle("/static/", http.StripPrefix("/static", fileServer))
mux.HandleFunc("/", app.home)
mux.HandleFunc("/snippet/view", app.snippetView)
mux.HandleFunc("/snippet/create", app.snippetCreate)
```

#### Adding a deliberate error

Try this out by quickly adding a deliberate error to the application -- Open the ternimal and rename the `ui/html/pages/home.html`.

### Centralized Error Handling

neaten up our app by moving some of the error handling code into helper methods. `helpers.go`file like:

```go
func (app *application) serverError(w http.ResponseWriter, err error) {
	trace := fmt.Sprintf("%s\n%s", err.Error(), debug.Stack())
	app.errorLog.Println(trace)
	http.Error(w, http.StatusText(http.StatusInternalServerError),
		http.StatusInternalServerError)
}

func (app *application) clientError(w http.ResponseWriter, status int) {
	http.Error(w, http.StatusText(status), status)
}

func (app *application) notFound(w http.ResponseWriter) {
	app.clientError(w, http.StatusNotFound)
}
```

It does introduce a couple of features which are worth discussing -- 

- In the `serverError()`use the `debug.Stack()`to get a *stack trace* for the *current goroutine* and append it to the log message.
- In the `clientError()`, use the `http.StatusText()`to automatically generate a human-friendly text representation.

In the `handlers.go`and update it to use the new helpers like: Fore:

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.Header().Set("Allow", "POST")
		app.clientError(w, http.StatusMethodNotAllowed)
		return
	}
	w.Write([]byte("Create a new snippet..."))
}
```

### Isolating the application routes

For now, `main`function is beginning to get a bit crowded, keep it clear and focused, like to move the route declarations for the app into a standalone `routes.go`file like:

```go
func (app *application) routes() *http.ServeMux {
	mux := http.NewServeMux()
	fileServer := http.FileServer(http.Dir("./ui/static/"))
	mux.Handle("/static/", http.StripPrefix("/static", fileServer))
	mux.HandleFunc("/", app.home)
	mux.HandleFunc("/snippet/view", app.snippetView)
	mux.HandleFunc("/snippet/create", app.snippetCreate)
	return mux
}
```

Then can update the `main.go`file to use this instead -- like:

```go
srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  app.routes(),
}
```

This is quite a bit neater, the routes for the app is now isolated and encapsulated in the `app.routes()`method, and tehresponsibilities of our `main()`function are limited to:

- Parsing the runtime configuration settings for the application.
- Establishing the dppendencies for the handlers
- Running the HTTP server.

#### Dbs -driven responses -- 

For web app to become truly useful we need somewhere to store the data entered by users, and the ability to query this data store dynamically at runtime. There are many differerent ddata stores we could use.

- Install a dbs driver
- Connect to the MySQL
- Create a standalone models `package`-- so that your dbs logic is just reusable and decoupled from the app
- Using the appropriate functions in Go’s `database/sql`package to execute different types of SQL statements, and how to avoid common errors that can lead to your server running out of the resources.
- Prevent SQL injection by correctly using placeholder parameters
- Use transactions.

```sh
sudo apt install mysql-server
```

```sql
create table snippets (
    id integer not null primary key auto_increment,
    title varchar(100) not null,
    content text not null,
    created datetime not null,
    expires datetime not null
);

-- Add an index on the created column.
create index idx_snippets_created on snippets(created);
```

Each record in this table will have an integer `id`field which will act as the unique identifier for the text snippet. Will also have a short text `title`and the snippet content itself will be stored in the `content`. Also, add some placeholder entries to the `snippets`table like:

Creating a new user -- From a security point of view it’s not good idea to connect to MySQL as the `root`user from a web app, instead it is better to create a dbs user with restricted permissions on the dbs. Like:

```sql
CREATE USER 'web'@'localhost'
GRANT SELECT, INSERT, UPDATE, DELETE on snippetbox.* To 'web'@'localhost';
ALTER USER 'web'@'localhost' IDENTIFIED BY 'pass';
```

