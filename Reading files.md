# Reading files

`less`allows you to read a file, one page Running less will open the file and allow you to scroll through it, one line or one page at a time. To search inside the file

```sh
less somefile.txt
```

`touch` -- create an empty file, or update modification time for an existing one -- create a file and therefore require a file path as arg.

`mkdir`-- create a directory, optionally, can feed it additional args if you want to create multile like:

```sh
mkdir foo bar baz
```

And if want to create multiple directories *nested* inside of each other, just can use `-p`flag like:

```sh
mkdir -p /var/log/myapp/error
```

`-p`flag would have ensured that the directory was created.

`rmdir`-- removes empty -- *have to be empty* for this command to work.

`rm`-- remove files and directories -- it works on directories that are *not* empty, need the `-r`to apply the command *recursively* and the `-f`to *force* deletion without a confirmation for each file and directory. like:

```sh
rm -rf /path/to/directory
```

`mv`-- move or rename files and directories -- `mv`is a clever one -- can do two things using the same syntax. like:

```sh
mv foobar.txt foobarbaz.txt # rename the file in place
```

### Getting help

All but the most iminimal environments tend to come with manual pages -- which are documentation that you can use to learn how to use the command-line programs you have available to you.

### Working with Processes

When refer to a *process* in Linux, we are just referring to the OS’ internal model of what exactly a running *program* is. Linux needs a general abstraction that works for all programs -- which can encapsulate the things the Os cares about.

- Memory usage
- Processor time used
- Other system resource usage
- Communication between processes
- related process that a program starts.

```sh
ps aux
```

What is a Linux process made of -- 

- Process ID (PID in the ps output) - PID 1 fore, is the init system, the original parent of all other processes, which bootstrap the system. The kernel starts this as one of the first things it does after starting to execute. When a process is created, it gets the next available process ID, in sequential order. init cannot be killed -- Different unix Os uses different `init`systems -- most distribution use `systemd`-- macOS uses `launchd`.
- parent Process PID (PPID) -- each process is spawned by a parent, note that -- if the parent process dies while the child is alive, and the child becomes an orphan. And Orphaned processes are re-parented to PID 1. -- namely, init process
- *status* -- `man ps`will show an overview, `D`(Uninterruptivle sleep), `I`idle, `R`running or runnable, `S`Sleep, `T`stoped by job control signal, `t`for stoped by debugger, `X`dead(should never be seen) `Z`-- Defunct zombie.
- *priroity*
- A process owner
- Effective GroupID (EDID)
- *address map*
- Resource usage

### Effective User ID (EUID) and (EGID) for group

Together, user and group permisions determine what a process is allowed to do on the system.

Environment variables-- They are alwyas for the OS environment that launches your process to pass in data that the process needs. fore: `LOG_DEBUG=1`and for some secret keys (`ASW_SECRET_KEY`), and every programming language has some way to read fore for python:

```python
import os
home_dir= os.environ['HOME']
```

Working directory -- A process has a current working directory -- just like your shell. `pwd`.

Practical commands -- 

- `ps`shows processes on the system. like: `ps aux | head -n 10`

  ```sh
  ps -eLf # shows thread info
  ps -ejH # shows a useful for seeing relationships between parent and child
  pgrep nginx # find process ids
  top
  iotop
  netlogs # groups network usage by process
  kill # allows uses to send signals to processes, usually stop them or make them re-read their configuration
  ```

### Advanced process concepts and tools -

How does `systemclt`tell your web server to re-read its configuration files -- how can politely ask a process to shutdown cleanly -- In Unix and Linux -- all of this is done with signals. -- are numerical messages that can be snt between programs. There are a way for processes to communicate with each other and with the operating system, allowing processes to send and receive specific messages.

## Duplicate Labels

`Index`objects are not required to be unique -- can have duplicate row or column labels -- this may be a bit confusing -- know that for SQl row labels are similar to a PK.

```python
s1 = pd.Series([0,1,2], index=[*'abb'])
s1.reindex([*'abc']) # error
```

for `reindex()`method, don’t work with duplicates present. Other like indexing, can give very surprising results, typically indexing with a scalar will *reduce dimensionally* -- Slicing a `Dataframe`with a scalar will return a `Series`, slicing a series with a salar will return a scalar.

### Duplicate label detction

Can check whether an `Index`is unique with `Index.is_unique`attribute like:

```python
df2 = pd.DataFrame({'A':[0,1,2]}, index=[*'aab'])
df2.index.is_unique # False
df2.columns.is_unique # True

# duplicated() will return a boolean ndarray indicating whether a label is repeated
df2.index.duplicated() # array([False, True, False])
```

Disallowing duplicate lables -- Handling duplicates is an important feature when reading in raw data. May want to avoid introducing duplicates as part of a data processing pipeline

```python
# DuplicateLabelError raised
pd.Series([0,1,2], index=[*'abb']).set_flags(allows_duplicate_labels=False)
```

Note that this applies to *both* row and column labels for a DF.

### categorical data -- 

This is an introduction to pandas categorical data type -- including a short comparison with R’s Factor -- Categoricals are a pandas data type corresponding to categorical variables in statistics -- A categorical variable takes on a lmited, and usually fixed, number of posible vlaues fore, gender, In contrast to statisitical categorical variables, categorical data might have an order -- but numerical operations are not possible.

All values of categorical data are either in `categories`or `np.nan`-- order is defined by the order of `categorires`. Not lexical order of the values, internally, the data structure consists of a `categories`array and an integer array of codes which point to the real value in the `categories`array.

The categoical data type is useful in the following cases -- 

- A string variable consists of only a few different values
- The lexical order of variable is not the same as the logical order, By converting to a categorical and specifying an oder on the categoreis, sorting and min/max will use the logical instead of the lexical order.
- As a single to other Python libraries that this column should be treated as a categorical variable.

## Practice Concurrency

- preventing common mistakes with goroutines and channels
- Understanding the impacts of using std data structure along side concurrent code
- Using the std lib and some extensions
- Avoiding data races and deadlocks

Fore, expose an HTTP handler that performs some tasks and returns a response -- but just before returning the response, also want to send it to a -- topic , don’t want to penalize the HTTP consumer latency -- want the publish action to be handled async within a new goroutine. like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    response, err := doSomeTask(r.Context(), r)
    if err != nil {
        http.Error(...)
        return
    }
    go func(){
        err := publish(r.Context(), response)
        // do sth with err
    }()
    writeResponse(response)
}
```

First call a `soSomeTask`function to get a `response`variable -- used within the goroutine calling `publish`and to format the HTTP response, also when calling `publish`, propagate the context attached to the HTTP request, have to know that the context attached to an HTTP request can cancel in different conditions -- like:

- When the client’s connection closes
- in the case of an HTTP/2 request, when the request is just canceled
- When the response has been written back to the client

In the first two, probably handle things correctly -- fore -- if get a response from `doSomeTask()`butt he client has closed the connection, it’s probabley OK to call `publish`with a context already canceled so the message isn’t published. when the response has been written to the client, the context assocaited with the request will be canceled.

- If the response is written after the publication, both return a response and publish a message successuflly.
- However, is the response is written before or during the publication, the message shouldn’t be published.

One idea is not propagate the parent conetxt -- instead, would call `publish`with an emtpy context:

`err := publish(context.Background(), response)`

A std package doesn’t provide an immediate solution to this problem -- a possible solution is to implement our won Go similar to the context provided, except that it doesn’t carry the cancellation signal -- like:

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <- chan struct{}
    Err() error
    Value(key any) any
}
```

Just, the context’s deadline is managed by the `Deadline()`method and the cancellation signal is managed via the `Done`and `Err`methods. When a deadline has passes or the context has been canceled, `Done`should return a closed channel, whereas `Err`should return an error. like:

```go
type detach struct{
    ctx context.Context
}
func(d detach) Deadline() (time.Time, bool){
    return time.Time{}, false
}
func(d detach) Done() <-chan struct {} {
    return nil
}
func (d detach) Err() error {
    return nil
}
// bofore all empty implementation

func (d detach) Value(key any) any{
    return d.ctx.Value(key)
}
```

Except for the `Value()`method that calls the parent context to receive a value, the other methods return a default value so that the context is never considered expired or canceled. Just:

`err: = publish(detach{ctx: r.Context()}, response)`

### Starting a goroutine with knowing when to stop it

So easy and cheap that may not necessarily have a plan for when to stop a new goroutine -- which can lead to leaks -- not knowing when to stop a goroutine is a disign issue and a common concurrency mistake in Go.

In terms of memory, a goroutine starts with a minimum stack size of 2K -- which can grow and shrink as needed, memory-wise, a goroutine can also hold variable references allocated to the heap. A goroutine can hold resources such as HTTP or dbs conenctions. 

A parent goroutine calls a function that returns a channel and then creates a new groutine that will keep receiving messages from this channel -- like:

```go
ch := foo()
go func(){
    for v := range ch{}
}()
```

For this, just created a goroutine will exit when ch is just closed. `ch`is just creted by the `foo`function, if the channel is never clsoed, it’s a leak. -- should always be cautous about the exit ponits of a goroutine and make usre one is eventually reached.

```go
func main() {
    newWatcher()
}
type watcher struct{}
func newWatcher() {
    w:= watcher{}
    go w.watch()
}
```

creates a `watcher`and spins up a goroutine in charge of watching the configuration -- The problem with this code is when the main exits - the app is stopped. Hence, the resources created by the `watcher`aren’t closed gracefully. One optional:

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    newWatcher(ctx)
}
func newWatcher(ctx context.Context){
    w := watcher{}
    go w.watch(ctx)
}
```

We just propagate the context created to the `watch`method -- when the context is canceled, the `watcher`struct should `close`its resources -- can we guarantee that `watch`will have time to do..

The problem is that used signaling convey that a goroutine had to be stopped.

```go
func main(){
    w := newWatcher()
    defer w.close()
}
func newWatcher() watcher{
    w:= watcher{}
    go w.watch()
    return w
}
func(w watcher) close {
    // close the resources
}
```

If a goroutine creates resources and its lifetime is bound to the lifetime of the application -- it’s probably safer to wait for this goroutine to complete before exiting the app.

## Context (2)

When developing a large app, especially in server software, sth is’t helpful for a function to know more about the environment it’s being executed in aside from the info needed for a function to work on its own. If a web server function is handling an HTTP request for a speicifc client, the function may only need to know which URL the client is requesting to serve the response. 

Thins always happen when serving a response, such as the client disconnecting before receiving the response. For these, the server software may end up spending more comuting time thatn it needs calcuating a response. In this case, being aware of the context of the reuest, such as the client’s connection status, allows the server to stop procesing the request once the client disconnects -- This saves valuable compute resources on a busy server and frees them up to handle another client’s request.

Using `context`to *gather* additional info about the environment they are being executed in. By using the `context.Context`interface in the `context`packae and passing it from func to func, programs can convey that info from the beginning func of a program, such as `main`, all the way to the deepest func call in the program.

The `Context`function of an `http.Request`, fore will provide a `conetxt.Context`that includes info about the client making the request and will end if the client disconnects before the request is finished.

Need to have a directory like:

```go
func doSomething(ctx context.Context) {
	fmt.Println("Doing sth")
}
func main() {
	ctx := context.TODO()
	doSomething(ctx)
}

```

TODO() is one of two ways to create an emtpy context, can use this as a placeholder when are not sure which context to use -- Also recommended to put the `context.Context`as the first parameter in a function. And the `context.Background()`function creates an emtpy context like `context.TODO`does-- it’s designed to be used where U intend to start a known context.

### Ending a Context

Another powerful tool `context.Context`provides is a way to signal to any functions using it that the context has ended and should be considered complete. By signaling to these functions that the context is done, they know to stop processing any work related to the context that they may still be working on. 

Using this featur of a context allows your programs to be more efficent cuz instead of fully completing every func, even if the result will be throuwn out, that processing time can be used for sth else. Fore, if a web page request somes to your go web server, the user may end up hitting the `STOP`button or closing their browser before the page finishes loading. Your functoins will know that the context is done cuz Go’s web server will cancel it, and that they can skip runing any other dbs queries they haven’t yet run.

The `context.Context`provides a method called `Done`that can be checked to see whther a context has ended or not. This method returns a channel that is closed when the context id done, and any functions watching for it to be closed will know they could consider their execution context completed and should stop any processing related to the context.

The `Done`method works cuz no values are ever written to its channel, and when a channel is clsed that channel will start to return `nil`values for every read attempt. By *periodically* checking whether the `Done`channel has closed and doing processing work in-between, you are able to implement a function that can do work but also knows if it should stop processing early. Combining this work, the periodic check of the `Done`and the `select`statements goes even further by allowing you to send data to ore receive data from other channels simultaneously.

```go
ctx := context.Background()
resultCh := make(chan *WorkResult)
for{
    select{
    case <-ctx.Done():
        return
    case result:= resultsCh:
        
    }
}
```

