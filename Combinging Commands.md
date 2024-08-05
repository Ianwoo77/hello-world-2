# Combinging Commands

Can connect these commands `ls`writes to stdout and `less`can read from stdin like:

```sh
ls -l /bin | less
```

### 6 Commands started

Pipes are an essentail part of Linux experties. `wc, head, cut, grep sort`and `uniq`-- have just numerous options and modes of operation -- run the `man`command to display *full documentation*.

```sh
wc animals.txt # print the number lof lines, words, and characters in a file
# 7 lines, 51 words 325 characters
# and the options -l -w and -c instruct wc for lines, words and characters
wc -l animals.txt
ls -1 | wc -l # force display per lines and 
wc animals.txt | wc -w | wc
```

#### Comand head

The `head`prints the first lines of a file

```sh
ls /bin | head -n5
```

#### Command cut

prints one or more columns from a file, fore, print all book titles from animals.txt like:

```sh
cut -f2 animals.txt | head -n3
cut -c1-3 animals.txt
```

#### Command grep

is powerful -- fore, displays lines from animals.txt that contain the string `Nutshell` like:

```sh
grep NutShell animals.txt
# can print lines that don't match with the -v option like:
grep -v Nutshell animals.txt
```

In general, `grep`is useful for fining text in a collection files. Fore, the following command prints lines that conaining the string `Perl`in files:

```sh
grep Perl *.txt
```

`grep`reads stdin and writes stdout, making it great for pipelines so:

```sh
# fore, with pipes, produce how many subdirectories
ls -l /usr/lib | cut -c1 | grep d | wc -l
```

#### Command sort

The `sort`reorders the **lines** of a file into ascending order by default like:

```sh
sort animals.txt
sort -r animals.txt # descending
# Can order the lines alphabetially, or numerically (-n) like:
```

The `-w`option in the `grep`command is used to search for whole words that match the pattern.

#### Command uniq

The `uniq`detects repeated, adjacent lines in a file.

```sh
cat letters
uniq letters -c # count the occurrences
cut -f1 greads | sort | uniq -c | sort -nr
```

### Detecting duplicate Files

Suppose in a directory full of JPEG files, and want to know if any are duplicates -- can anawer this question with a pipeline, need another command, `md5sum`, which examines a file’s contents and compute a 32-charater string called a *checksum* -- like:

```sh
md5sum greads.txt | cut -c1-32 | sort | uniq -c | sort -nr
md5sum *.txt | grep a5ec619fd4d1eb674d3040c5b25ae042
```

### Evaluating Variables

A running shell can define variables and store values in them. A shell variable is lot like a variable in algebra. FORE:

```sh
printenv HOME
printenv USER
```

When the shell evaluates a variable, it replaces the variable name with its value. fore:

```sh
echo $USER
echo lin*count
```

Variables like `USER`and `HOME`are are predefined by the shell. Their values are set automatically when log in. May define or modify a variable anytime by assiging it a value using : name=value

```sh
go=$HOME/go
cd $go
pwd
# may also supply $go to any command that expects a directory
cp myfile $go
ls $go
```

Just note that when defining a variable, no spaces are permitted aournd the equal sign.

## How `defer`arguments and receivers are evaluated

Mentioned in a prevous section that the `defer`statements delays a call’s execution until the surrounding function returns -- a common mistake made by Go developers is not understanding how arguments are evaluated. Delve into this with two subsections -- one related to function and method argumetns and the second related to method receivers.

#### Argument evaluations

To illustrate how arumeng are evaluated with the `defer`-- work on a concrete example -- func needs to call two functions `foo`and `bar`. It has to handle a status regarding execution -- 

- `StatusSuccess`if both return no errors
- `StatusErrorFoo`and `StatusErrorBar` like:

```go
const (
	StatusSuccess = "success"
    StatusErroFoo = "error_foo"
    StatusErrorBar = "error_bar"
)

func f() error {
    var status string
    defer notify(status)
    defer incrementCounter(status)
    
    if err := foo(); err != nil {
        status = StatusErrorFoo
        return err
    }
    if err := bar(); err != nil {
        status = StatusErrorBar
        return err
    }
    status = StatusSuccess
    return nil
}
```

First, declare a `status`variable, then defer the calls to `notify`and `incrementCounter`using `defer`, throughout this func, and depending on the execution path, update `status`accordingly. See that regardless of the execution path, `notify`and `incrementCounter`are always called with the same status -- *empty* string.

So, need to understand sth **Crucial** about argument evaluation in a `defer`function -- the arguments are evaluated *right away* -- not once the surrounding function returns. So in example, call `notify(status)`and `incrementCounter(status)`as `defer`functions. Therefore, go will delay these calls to be executed once returns with the **current** values of `status`at the stage used `defer`. So:

```go
func f() error {
    var status string
    defer notify(&status)
    defer increment(&status)
    //...
}
```

We keep updating the `status`depending on the cases, but now `notify()`and `incrementCounter`receive a string pointer. For now, using `defer`evalutes the arguments right away -- here the address of `status`-- itself is modified throughout the function.

And there is another solution, calling a **closure** as a `defer`statement -- as a remainder, a closure is an anonymous function value that references variables from outside its body. Like:

```go
func main(){
    i:=0
    j:=0
    defer func(i int) {
        fmt.Println(i,j)
    }(i)  // print 0 1
    i++
    j++
}
```

Therefore, can use the closure to implement a new version of our function like:

```go
func f() error {
    var status string
    defer func() {
        notify(status)
        incrementCounter(status)
    }()
}
```

Here, wrap the calls to both `notify`and `incrementCounter`within a closure, this closure references the `status`variable form outside its body. Therefore, `status`is evaluated once the closure is executed, not when call `defer`. This solution also works and doesn’t requrie `nofity`and `incrementCounter`to change their signature.

#### Pointer and value receiver

Said that a receiver can be either a value or a pointer. The same logic related to argument evaluation applies when use `defer`on a method. The receiver is also evaluated immediately. Fore:

```go
func main() {
    s := Struct{id:"foo"}
    defer s.print()
    s.id="bar"
}// just print foo
type Struct struct{
    id string
}
func (s Struct) print() {
    fmt.Println(s.id)
}
```

Calling the `defer`just makes the receiver be evaluted immediately -- hence, `defer`delays the method’s execution with a struct that contains an `id`field equal to `foo`. Conversely, if the pointer is a receiver, the potential changes to the receiver after the call to `defer`are visible. like:

```go
func main(){
    s := &Struct {id: "foo"}
    defer s.print()
    s.id="bar"
} // bar printed
//...
func (s *Struct) print(){
    fmt.Println(s.id)
}
```

So the `s`receiver is also evaluated immediately -- however, calling the method leads to copying the pointer receiver.

## Error Management

- Understanding when to panic
- Knowing when to wrap an error
- Comparing error types and error values efficiently sing Go 1.13
- Handling errors idiomatically
- Understanding how to ignore an error
- Handling errors in `defer`calls

Error management is a fundamental aspect of building robust and observable applications, and it should be as important as any other part of a codebase.

### Panicking

Pretty common for Go newcomers to be somewhat confused about error handling -- In Go, errors are usually managed by functions or methods that return `error`as the last parameter, but, fore, C# or Java, using `panic`... refresh our minds about the concept of panic -- like:

```go
func main(){
    fmt.Println("a")
    panic("foo")
    fmt.Println("b")
}
```

Once a panic is triggered, it continues up the call stack until either the current goroutine has returned or `panic`. So:

```go
func main() {
    defer func() {
        if r := receover(); r != nil {
            fmt.Println("recover", r) // recover foo
        }
    }()
    f()
}
func f(){
    //...
    panic("foo")
}
```

In the `f()`, once `panic`is callled, it stops the current execution of the function and goes up the call stack. Note that the calling `recover()`to capature a goroutine panicking is only useful inside a `defer`function, otherwise, the function would retuern `nil`and have no other effect.

So, When is it appropriate to panic -- in Go, `panic`is used to signal genuinely exceptional conditions -- such as a programmer error. Fore, if look at the `net/http`pacakge -- notice that the `WriteHeader`-- fore:

```go
func checkWriteHeaderCode(code int) {
    if code <100 || code >999 {
        panic(fmt.Sprintf(...))
    }
}
```

So, this func panics if the status code is just invalid, which is a pure programmer error. Another example based on a programmer error can be found in the `database/sql`package while registering a dbs driver like:

```go
func Register(name string, driver driver.Driver) {
    dirversMu.Lock()
    defer driverMu.Unlock()
    if driver == nil {
        panic("sql: Register driver is nil")
    }
    if _, dup := drivers[name]; dup {
        panic("Register called twice")
    }
    //...
}
```

Both cases here would again be considered programmer errors -- In most cases, `Register`is called via an `init`, which limits *error handlings* -- for all these reasons, the designers made the function panic in case of an error.

And, another use case in which to panic is when our app requires a dependency but fails to initialize it. Fore, imagien that we expose a service to create new customer accounts, this service needs to validate the provided email address.

### Ignoring when to wrap an errror

Since Go 1.13 -- the `%w`directive allows us to wrap errors conveniently -- some developers may be confused about when to wrap an error or not. Is about wrapping or packing an error inside a wrapper container that also makes the source error available -- the two main use cases for error wrapping -- 

- adding additional context to an error
- Marking an `error`to a specific `error`.

Fore, consider the following example, receive a request from a specific user to access a dbs resource, but get a permission denied -- error during the query. For debuging purposes, if the error is eventually logged, want to add extra context -- in this case, wrap the error to indicate who the user is. Fore, want to implement an HTTP handler that checks whether all the errors received while calling functions are of a `Forbidden`type, so 403 code.

In both cases, the source error remains available -- hence a caller can also handle an error by unwrapping it and checking the source error. See the different ways in go to return an error we receive like:

```go
func Foo() error {
    err := bar()
    if err != nil {
        // ? here what to do?
    }
}

// before Go 113, wrap an error like:
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return ... + b.Err.Error()
}

// instead returning err directly, wrapped the error
if err != nil {
    return BarError{Err: err}
}
```

Benefit of this option is flexiblity -- Cuz `BarErro` is a custom struct, we can add any additional context if needed. Being obliged to create a specific error type just ..cumbersome...

```go
if err != nil {
    return fmt.Errorf("bar failed: %w", errr)
}
```

This code wraps the source error to add additional context without having to create another error type.

Cuz the source error remains available, a client can unwrap the parent error and then check whether the source error was of a specific type or value. But:

```go
if err != nil {
    return fmt.Errorf("bar failed: %v", err)
}
```

For this, the difference is that the error isn’t wrapped, transform it into antoher error to add context. and the info about the source of the problem remains available, but a caller can’t unwrap this error and check whether the source was.

When handling an error, can decide to wrap it -- Wrapping is aobut adding additional context to an error and/or marking an error as a specific type. If need to *mark* an error, should create custome type. However, if just want to add extra, should use the `fmt.Errorf()`with `%w`directive as it doesn’t require creating a new error type, and error wrapping creates potential coupling as it makes the source available for the caller. if want to prevent it, shouldn’t use error wrapping but error transformation, using `Errorf()`with `%v`directive.

## Web Application basics

- The first thing we need is a *handler* -- coming from an MVC-background, can think of handlers as being a bit like controllers. They are responsible for executing your application logic and for writing HTTP response headers and bodies.
- The second is a router. This stores a mapping between the URL patterns for your app and the corresponding handlers. Usually U have one serveMux for your application and the corresponding handlers.
- The last thing we need a *web server*. One of the great things about Go is that you can establish a web server and listen for incoming requests as part of your application.

```go
func home(w http.ResponseWrite, r *http.Request) {
    w.Write([]byte("Hello from snippetbox"))
}

func main(){
    // Use the http.NewServeMux() to initialize a new servemux
    mux := http.NewServeMux()
    mux.HandleFunc("/", home)
    
    // Then use the http.ListenAndServe() function to start a new web server
    // pass in two -- TCP network address to listen on 
    // and the serveMux just created
    log.Println("Starting server on :4000")
    err := http.ListenAndServe(":4000", mux)
    log.Fatal(err)
}
```

### Routing requests

```go
func snippetView(w http.RsesponseWriter, r *http.Request) {
    w.Write([]byte("Display a specific snippet..."))
}
func snippetCreate(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Create a new snippet..."))
}
func main(){
    mux := http.NewServeMux()
    mux.HandleFunc("/snippet/view", snippetView)
    mux.HandleFunc("/snippet/create", snippetCreate)
    //...
    err := http.ListenAndServe(":4000", mux)
}
```

#### Fixed Path and subtree patterns

Go’s serveMux supports two different types of URL patterns - *fixed paths* and *subtree paths* -- Fixed paths don’t end with a traling slash. Whereas subtree paths do end with a trailing slash. Fore `/snippet/view`-- In Go’s serveMux, fixed path patterns like these are only matched when the request URL path *exactly* matches the fixed path.

In contrast, pattern `/`is an example of a subtree path -- another example wourld be sth like `/static/`-- are matched whenever the *start* of a request URL path matches the subtree path. Just like `/**`or `/static/**`like Angular does.

#### Restricting the root URL pattern

So what if don’t want the `/`to pact like a *catch-all* -- fore, in the app we are building want the home page to be displayed if and only if the request URL path exactly matches the `/`, otherwise, want the user to receive 404 like:

Note that it’s not possible to change the behavior of Go’s servemux to do this, but can include a simple check in the `home`handler like:

```go
func home (w http.ResponseWriter, r *http.Request) {
    // Check if the current requet URL path exactly matches /, 
    // id not, use `http.NotFound`
    if r.URL.Path!= "/" {
        http.NotFound(w,r)
        return
    }
    //...
}
```

#### The `DefaultServeMux`

If using:

```go
func main(){
    http.HandleFunc("/", home)
    //...
    err := http.ListenAndServe(":4000", nil)
}
```

Behind the scenes, these funcs register their routes with sth called `DefaultServeMux`-- There is nothing special about this -- it’s just regular servemux like already seen, which is initialized by default and stored in a `net/http`*global variable* -- like:

`var DefaultServeMux= NewServeMux()`

Not recommend it -- fore -- cuz `DefaultServeMux`is a global variable, any package can access it and register a route -- including any 3rd-party packages that your app imports. If one of those packages is compromised, could use `DefaultServeMux`to expose a malicious handler to the web.

#### Additional information

- In Go’s servemux, longer URL patterns always take precedence over shorter ones.
- Request URL paths are automatically sanitized.
- If subtree path has been registered and request is received for that subtree path without a trailing slash. will automatically be sent a 301 permanent redirect to the subtree path. Fore, if U have registered the subtree path like `/foo/`, then any request to `/foo`will be redirect to `/foo/`

#### Host name matching

It’s also possible to include host names in URL patterns. This can be useful when want to redirect all HTTP requests to a canonical URL, or if app is acting as the back end for multiple sites or services. When it comes to pattern matching, any host-specific patterns will be checked first, and if there is a match the request will be dispatched to the corresponding handler. Only when there isn’t host-specific match found will the non-host specific pattern also be checked.

