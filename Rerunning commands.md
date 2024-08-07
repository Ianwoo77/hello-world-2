# Rerunning commands

```sh
md5sum *.jpg | cut -c1-32 | sort | uniq -c | sort -nr
```

Behind the scenes, the shell keeps a record of the commands U invoke so can easily recall and retun them with a few keystrokes.

### Viewing the Command history

*command history* is a simply a list of previous commands that you’ve executed in an interactive shell. `history`is a shell builtin -- the commands appear in chronological order with ID for easy reference. Can limit it to the most recent commands by adding an integer argument, which specifies the number of lines to print -- like:

```sh
history 3
history | sort -nr | less
history | grep -w cd
# note, to delete this this tory for the current shell, using the -c
history -c
```

#### History expansion

Is a shell feture that accesses the command history using special expression.

```sh
!!
!grep # refer to the most recent command that began with a certain string
```

And to refer to the most recent command that just contained a given string *somewhere* like:

```sh
!?grep?
# Can also retreive a particular command from a shell's history by its absolute position like:
history | grep hosts # if return 2001
!2001
# And a negative value retrieves a command by its relative position in the history
!-3
!4:p # just printed, not executed
```

The shell appends the un-exeucuted command (head) to the history.

#### Never delete the wong File again -- 

Fore,  *.txt, by accidentally mistyped the pattern and wiped out the wrong files. fore:

`rm *.txt`-- danger -- note that the most common solution to this hazard is to alias `rm`to `rm -i`so it promots for confirmation before each deletion. `alias rm= 'rm -i'`

#### History Expansion with Carets

```sh
md5sum *.jg | cut c1-32 | sort ...
# to run properly just can use :
^jg^jpg # replace old with new
```

The caret syntax , which is a type of history expansion, in the previous command instead jg substitute jpg.

## Making a Commit

Committing is important cuz it allows U to back up your work and avoid the frustration of losing unsaved work. Once you ‘ve made a commit, work is saved, and you will be able to go back and look at the commit to see what your proj looked like at the point in time.

In terms of when to make commits, there is no strict rule -- can depend on many factors. If are working in a tem, it may depend on the workflow your team uses and what conventions that team has agreed to.

#### Two Steps to ame a commit

1. Add all the files you want to include in the next commit to the staging area. In Git, staging refers to the process of preparing your changes to be committed to the repository. The staging area, also known as the `index`.
2. Make a commit with a commit message

A useufl command in the commiting process is the `git status`-- it tells U the state of the working directory and the staging area. fore:

- The `git status`tells U there are *No commits yet*.
- The file is an untracked file
- using `git add <filename>`

The file is now bothin the working directory and in the staging area -- this is cuz the `git add`command does not *move* file from the working directory to the staging -- it just *copies* the file. With this in the staging area, u are now ready to move on the second step in the committing process.

#### Making a Commit

It’s important to note that *commit* is both a verb and a noun in Git. verb means to save sth, and `noun`means a verion of our project. To make a commit, just use the `git commit`and pass the `-m`option. Typing a message inside -- the message should usually be a brief description.

`git commit -m "<message>"`

```sh
git commit -m "red" # shows the first 7 characters of the commit hash for the red commit
```

#### Viewing a list of Commits

To see a list of commits in the commit history, use the `git log`command -- lists the commits in a local repository in reverse chronological order. 

1. Commit hash
2. Author name and email addres
3. Date and time commit was made
4. Commit message

`git log`

## Don’t handle an error twice

Handling an error multiple times is a *mistake* made frequently by developers -- not specfically in Go. Fore, the fucn will call an *unexported* `getRoute`func that contains the business logic to calculate the best route, before calling, have to valiate the soruce and target coordintes using `validateCoordinates`. Like

```go
func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
	err := validateCoordinates(dstLat, dstLng)
	if err != nil {
		log.Println("fail to validate")
		return Route{}, err
	}
	err=validateCoordinates(srcLat, srcLng)
	if err != nil {
		//...
		return Route{}, err
	}
	return getRoute(...)
}

func validateCoordinates(lat, lng float32) error {
	if (lat > 90.0) || (lat < -90.0) {
		log.Printf("invalid latitude: %f", lat)
		return fmt.Errorf("invalid latitude: %f", lat)
	}
	//...
	return nil
}
```

Firt in `validateCoordinates`, it is cumbersome to repet the `invalid latitude`or `invalid longitude`error messages in both logging and ethe error returned. For this, having two log lines for a single error is a problem -- cuz it makes debugging harder -- If this func is called multiple times concurrently, the two messages may not be one after the other in the logs. As a rule of thumb, an error should be handled only once.

*Logging an error is handling an error*, and so is returning an error, never both. Like:

```go
func validateCoordinate(lat, lng float32) error {
    if lat>90.0 || lat< -90.0 {
        return fmt.Errorf("...")
    }
    if lng... {
        return fmt.Errorf("...")
    }
    return nil
}
```

### Handling an error always

In some cases, may want to ignore an error returned by a function, there should be only one way do this in Go Fore, consider the following example, like:

```go
func f(){
    //...
    notify()
}
func notify() error {...}
```

Cuz want to ignore the error, in this, just call `notify()`without assigning its output to a classic `err`variable. And there is nothing wrong with the code from *functional* standpoint. However, from a maintainability perspective, the code can lead some issues. Just like : `_ = notify()`-- Instead of not asigning the error to a variable, we assign it to the blank identifier -- in terms of compilation and run time, this approach dosn’t change anything compared to the first piece of code. This version just make explicit that we are not interested in the error.

And also note a Comment can also accompany such code like:

```go
// Ignore the error
_ = notify()
```

### Handling defer errors always

Not handling errors in `defer`statements is a *mistake* that’s fequently made by Go developers. Fore:

```go
const query="..."
func getBalance(db *sql.DB, clientID string) (float32, error){
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer rows.Close()
}
```

Note that `rows`is just a `*sql.Rows`type, it implements the `Closer`:

```go
type Closer interface {
    Close() error
}
```

Mentioned that errors should always be handled. As duscussed in the previous, if don’t want to handle the error, should ignore it explicitly using the blank identifier -- like:

```go
defer func() {_= rows.Close()}()
```

This version is more verbose but is better from an maintinability perspective as we explicitly mark that we are ignoring the error. But in such a case, instead of blindly ignoring all errors from `defer`calls, should ask -- whether that is the best approach -- For this, calling `Close()`returns an error when it fails to free a `DB`connection from the pool. Hence, ignoring this error is probably not what we wnat to do. Hence, ignoring this error is probably not what we want to do.

```go
defer func() {
    err := rows.Close()
    if err != nil {
        log.Printf("...", err)
    }
}()
```

For now, if closing `rows`fails, the code will log a message so aware of it. And, what if instead of handling the error, prefer to propagate it to the caller of `getBalance()`so that they can decide how to handle it -- like:

```go
defer func() {
    err := rows.Close()
    if err != nil {
        // Return statement is associated with the anonymouse func()
        return err  // doesn't compile 
    }
}()
```

If want to tie the error returned by `getBalance()`to the error caught in the `defer`call, must use named result parameter just like:

```go
func getBalance(db *sql.DB, clientID string) (balance float32, err error) {
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer func() {
        err := rows.Close() // assigns the error to the output named parameter
    }()
    
    if rows.Next(){
        err := rows.Scan(&balance)
        if err != nil {
            return 0, err
        }
        return balance, nil
    }
}
```

Once the `rows`variable has been correctly created, we defer the call to `rows.Close()`in an anonymous function. This function assigns the error to the `err`variable, which is initialized using named result parameters.

If `rows.Scan()`returns an error, `rows.Close()`is executed anyway -- cuz this call overrides the error returned by `getBalance`, instead of returing an error : The logic we need to implement isn’t strightforward -- 

- If `rows.Scan`succeeds -- if `rows.Close()`succeeds, return no error, if `rows.Close()`fails, return this error

## Performance

In the code set up ouf file server so that it serves files out of the `.ui/static`directory on your hard disk. It’s important to note that, once the application is up-and-running, `http.FileSever`probably won’t be reading these files from disk. Both OSes cache recently used file in RAM.

#### Serving single files -- 

Sometimes u might want to seve a single file from within a handler -- for this there is the `http.ServeFile()`func:

```go
func downloadHandler(w http.ResponseWriter, r *http.Request) {
    http.ServeFile(w, r, "./ui/static/file.zip")
}
```

#### Dsialbing directory listings

If want to disable directory listings there are a few different approaches you can take -- like: Add a blank `index.html`to the specific directory or a more complicated solution to create a custom imp of the `http.FileSystem`, have it return an `os.ErrNoExists`error.

### `http.Handler`interface

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

In simple terms, this basically means that to be a handler an object must have a `ServeHTTP()`method with the exact signature of this. So in its implest form a handler might look sth like this -- 

```go
type home struct {
}
func(h *home) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte(...))
}
```

Here have an object it’s a `home`struct, but it could equally be a string or function or anything else, and we’ve implemented a method with this signiture on it. Could register this with a servemux using the `Handle`method like:

```go
mux := http.NewServeMux()
mux.Handle("/", &home{})
```

#### Handler functions

Now, creating an object just so we can implement a `ServeHTTP()`method on it is long-winded and a bit confusing. Just:

```go
func home(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("..."))
}
mux := http.NewServeMux()
mux.Handle("/", http.HandlerFunc(home))
```

This `http.HandlerFunc()`adapter works by automatically adding a `ServeHTTP()`to the `home`function. When executed, this `ServeHTP()`method then simply calls the content of the original `home`function.

Throughout this using the `HandleFunc()`method to just register our handler functions with `ServeMux`like:

```go
mux := http.NewServeMux()
mux.HandleFunc("/", home)
```

#### Chaining handlers

The `http.ListenAndServe()`take a `http.Handler`object as the second parameter -- 

`func ListenAndServe(addr string, handler Handler) error`

we were able to do this cuz the servemux also has a `ServeHTTP()`method, meaning that it too satisfies the `http.Handler`interface.

### managing configuration settings

Having these *hard-coded* isn’t ideal, there is no separation between our configuration settings and code, can’t change the settings at runtime -- 

#### command-line flags

In Go, a common and idiomtic way to manage configuration settings is to use *command-line* flags when starting an app. FORE -- The eaiest way to accept and parse a command-line flag from your application is with a line of code like:

`addr := flag.String("addr", ":4000", "HTTP network address")`

This essentially defines a new command-line flag with name `addr`, a default value of `:4000`, and some short help text explaining what the flag controls. Like:

```go
func main(){
    //  $go run ./cmd/web -addr=":80"
    addr := flag.String("addr", ":4000", "HTTP network address")
    
    // Importantly, use the `flag.Parse()`to parse the command-line flag, reads in the command-line flag value
    // and assigns it to the addr variable. Need to call this before use the addr variable
    flag.Parse()
    
    mux := http.NewServeMux()
    //...handler function...
    err := http.ListenAndServe(*addr, mux)
}
```

#### Default values

Command-line flags are completely optional. Fore, if run the app with no `-addr`flag server will just fall back to listening on address `:4000`. There are no rules about what to use as the default values for yuour command-line flags.

#### Type Conversions

In the code used the `flag.String()`to define the command-line flag -- this has the beniefit of converting whatever value the user provides at runtime to a `string` type. If the value can’t be converted to a `string`then the app will log an error and exit. Go also has a rengae of functions including `flag.Int(), flag.Bool(), flag.Float64()`, work in exactly the same way as `flag.String()`.

#### Automated help

Another great feature is that U can use the `-help`flag to list all the available command-lines flags for app and their accompanying help text. fore:

```sh
go run ./cmd/web -help
```

#### Additional Infomation

Environment variables -- If you’ve built and deployed webf app -- If want, can store your configuraiton settings in environment variables and access them directly from your app by using the `os.Getenv()`like:

`addr := os.Getenv("SNIPPETBOX_ADDR")`

#### pre-existing variables

It’s possible to parse command-line flag value into the memory addresses of pre-existing varaibles. this can be useful if you want to store all your configuration settings in a single struct like:

```go
type config struct {
    addr string
    staticDir string
}

var cfg config
flag.StringVar(&cfg.addr, "addr", ":4000", "HTTP network address")
```

### Leveled Logging

For the `log.Fatal()`will also call `os.Exit(1)`after writing the mesage. In app, can break apart our log messages into two distinct types -- or *levels* -- the first type if *informational* messages and the second type is *error messages*.

```go
// Information message
log.Printf("Starting server on %s", addr)
err := http.ListenAndServe(*addr, mux)
log.Fatal(err) // Error message
```

Improve our app by adding some *leveled logging capability* - so that info and error messages are managed slightly differently -- sepcifically -- 

- Will prefix informational messages with `INFO`and output the message to stdout.
- Prefix error messages with `ERROR`and output them so standard error (stderr), along with the relevant file name and line number that called the logger.

There are a couple of different ways to do this -- but a simple and clear approach is to use the `log.New()`function to create two new *Custom* loggers.

```go
//...
// Use the log.New() to create a logger for writing info messages
// three parameters
// #1: destination to write the logs to
// #2: a string prefix for message
// #3: flags to indicate what additional info to include
infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)

// Then create a logger for writing error messages in the same way, use stderr as the 
// destination and use the log.Lshortfile to include the relevant file name and line number
errorLog := log.New(os.Stderr, "ERROR\t", log.Ldate|log.Ltime|log.Lshortfile)
//... some handler
infoLog.Printf("starting serve on %s", *addr)
err := http.ListenAndServe(*addr, mux)
errorLog.Fatal(err)
```

#### decoupled logging

A big benefit of logging your messages to the std streams like we are is that your app and logging are decoupled -- your app itself isn’t concerned with the routing or storage of the logs. During the development, it’s easy to view the log output cuz the std streams are displayed in the terminal.

In staging or production environment, can redirect the streams to a final destination for viewing and archival. Like:

```sh
go run ./cmd/web >> /tmp/info.log 2>>/tmp/error.log
```

#### The `http.Server`error log

There is one more change need to do -- If Go’s HTTP server encounters an error, will log using std log, for consistency it’s be better to use our new `errLog`logger instead -- like:

```go
//...
// Initialize a new http.Server struct, set the `Addr` and `Handler` field so that the server uses the same
// network address and routes as before, and set the ErrorLog field sot that the server now uses the custom 
// errLog logger in the event of any problems
srv := &http.Server {
    Addr: *addr,
    ErrorLog: errorLog,
    Handler: mux,
}
//...
err := srv.ListenAndServe()
errorLog.Fatal(err)
```

Additional Info -- Go provides a *range of other methods* that are wroth with -- As r rule of thumb, should avoid using the `panic()`and `Falta()`variations outside of your `main()`.

#### Concurrent Logging

Custom loggers created by `log.New()`are concurrency -- can share a single logger and use it across multiple goroutines and in your handlers without needing to worry about RC.

#### Logging to a file 

My general recommendation is to log your output to std streams and redirect the ourput to a file at runtime. But if don’t want to do, like:

```go
f, err := os.OpenFile("/tmp/info.log", os.O_RDWR|os.O_CREATE, 0666)
if err != nil {
    log.Fatal(err)
}
defer f.Close()
infoLog := log.New(f, "INFO\t", log.Ldat)
```

