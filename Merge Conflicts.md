# Merge Conflicts

Now all three of these repositories should be in sync, with the same commits and branches. Fore, edited the `othercolors.txt`while your friend edited the `rainbowcolors.txt`-- This meant were able to do a 3-way merge without any merge conflicts -- however, When U merge two branches where different changes have been made to the same parts in the same file(s). In these cases Git is unable to automatically merge the files.

Can arise during the process of merging as well as the process of *rebasing*.

#### How to resolve Merge conflicts

Will see a set of special markers in each of the files involved that indicate where the conflicts occur -- called *conflict markers* -- <<<< ==== >>>>.

```sh
<<<<<<<HEAD
{Content of the target branch}
=======
{Content of the source branch}
>>>>>>> refs/remote/origin/main
```

#### Setting up a Merge Conflict Scenario

To set up 3-way merge with merge conflicts, have to make different changes to the same part in the same file.

```sh
# in rainbow, edit rainbowcolors.txt 
git add rainbowcolors.txt
git commit -m "indigo"
git push
git log
```

So in the `rainbow`repository and in the `rainbow-remote`repository. Create a situation where you will have a merge conflict, your friend will add the color violet to the same line in the `rainbowcolors.txt`file and make a commit without first pulling the changes.

```sh
git add rainbowcolors.txt # under the friend-rainbow repo
git commit -m "violet"
```

- In the friend repository, the local `main`proints to the violet
- In the `rainbow`, the local `main`points to the indigo

At this point, your friend will need to fetch your changes from the remote and integrate them beofore can push.

```sh
# under the friend-rainbow repo:
git fetch
git status
git log --all
```

Next, you friend is going to carry out a 3-way merge to integrate the latest changes on the remote `main`branch into their local branch so they can push the updated `main`to the remote repository.

#### The Merge Conflict resolution Process

There are two steps to resolving merge conflicts -- walk through them in more detail. First step is to decide what to keep, edit the content, and remove the conflict markers, and the second is to add all the changes to the staging area and commit it.

Step 1 -- After execute the `git merge` -- Git will identify the conflict and will insert markers indication locations. To resolve the merge conflict in the `Rainbow`project, will keep both. 

Next, will need to remove the conflict markders from the file.

Step2 -- After finished editing, then also need to adding the updated file to the staging area and making a commit.

#### Aborting a Merge

If at any point during a merge with conflicts you decide that you don’t want to continue integrating two branches, you can choose to stop or *abort* the merge by using the `git merge`with `--abort`like 

```sh
git merge --abort # stop the merge process and go back to the state before the merge
```

#### Resovling Merge conflicts in practice

```sh
git merge origin/main
git status # both modified
# both accepted
git add rainbowcolors.txt
git status # modified
git commit -m "merge commit 2"
git log
```

For this, successfully carried out the 3-way merge and resolved the merge conflicts.

#### Staying up to Date with a remote Repository

It is a more time-consuming to integrate changes from one branch into another when there are merge conflicts. In real-world projects there may be many fore files with way more complicated merge conflcts to resovle. Staying up to date with changes made. Whenever you create a new branch, it is recommended that you base it off the most up-to-date verison of the relevant remote branch in the remote repository.

If you are working on an existing branch on your own, it is recommended to update your branch with the changes made to the relevant remote branch in the remote repostiory by merging.

#### Syncing the Repositories

For all the repositories to be in sync, your friend will need to push the new commits on their local `main`to the remote repository. And you will need to pull down all the changes into your local `main`in the `rainbow`.

```sh
# under the friend repo
git push
git log

# under the rainbow repo
git pull
git log
```

For now, all three repositories in the `Rainbow`project in sync.

- In the `rainbow-remote`the remote `main`branch points to the M2
- In the `rainbow`, the local `main`and the `origin/main`points M2, firend-rainbow either

## How defer argumnets and receivers are evaluated

The `defer`statement delays a call’s execution until the surrounding function returns. A common mistake made by Go developers is not understanding how arguments are evaluated. Will delve into this problem with two subsections:

#### Argument evaluation

To illustrate how argumnets are evaluated with `defer`-- work on a concrete example -- A func needs to call two functions `foo`and `bar`-- fore: Will use this status for multiple actions -- FORE, to notify another goroutine and to increment counters, to avoid repeating these calls before every `return`, use the `defer`like:

```go
const (
	StatusSuccess="success"
    StatusErrorFoo="err_foo"
    StatusErrorBar="err_bar"
)

func f() error {
    var status string
    defer notify(status)
    defer incrementCounter(status)
    
    if err := foo(); err != nil {
        status = StatusErrorFoo
        return err
    }
    //... for bar()
    status = StatusSuccess
    return nil
}
```

Regardless of the execution path, `nitify`and `incrementCounter`are always called with the same status -- *empty string* -- Cuz -- `defer`function -- the arguments are evaluated *right away*, not once the surrounding function returns. In the example, call `notify(status)`, and `incrementCounter(status)`as `defer`, therefore, Go will delay these calls to be executed once `f`retruns with the current value of `status`at the stage used `defer`.

The first solution is to pass a string pointer to the `defer`function just like:

```go
func f() error {
    var status string
    defer notify(&status)
    defer incrementCounter(&status)
    // ... unchanged
}
```

But, this solution requires changing the signature of the two functions.

There is another solution -- calling a closure as a `defer`statement. A closure in Go is an anonymous function value that references variable from outside its body. The arguments passed to a `defer`function are evaluated right away. Must know that the variables referenced by a `defer`closure are evaluted *during* the closure execution.

```go
func main(){
    j:=0; j:=0
    defer func(i int) {
        fmt.Println(i,j)
    }(i)
    i++ // 0
    j++ // 1
}
```

Therefore, can just use a closure to implement a new version of our function like:

```go
func f() error {
    var status string
    defer func() {
        notify(status)
        incrementCounter(status)
    }()
}
```

#### Pointer and value receivers

Said that a receiver can be either value or pointer, and the same logic related to argument evaluation applies when we use `defer`on a method -- the receiver is also evaluted immediately. like:

```go
func main(){
    s := Struct{id: "foo"}
    defer s.print()  // still foo printed
    s.id= "bar"
}
type Struct struct {id string}
func (s Struct) print() {
    fmt.Println(s.id)
}
```

Conversely, if the pointer is a receiver, the potential changes to the receiver after the call to `defer`like:

```go
func main(){
    s := &Struct {id: "foo"}
    defer s.print()
}
func (s *Struct) print() {}
```

### Error management - Panicking

It’s pretty common for Go newcomers to be somewhat confused about error handling. In Go, errors are usually managed by functions or methods that return an `error`type as the last argument. Refresh the minds about the concept of panic and discuss when it’s considered appropriate or not to `panic`.

In Go, `panic`is a built-in function that *stops the oridinary* flow like:

```go
func main(){
    fmt.Println("a")
    panic("foo")
    fmt.Println("b")
}
```

Once a panic is triggered, it continues up the *call stack* until either the current goroutine has returned or `panic`is caught with `recover`.

```go
func main(){
    defer func() {
        if r:= recover(); r!=nil {
            fmt.Println("recover", r)
        }
    }()
    f()
}
```

In the `f`once `panic`called, it stops the current execution of the function and goes up the call stack -- `main`, and in `main`, cuz the `panic`is caught with `recover`,  doesn’t stop. Also note that calling `recover()`to capture a goroutine panicking only useful inside a `defer`function, otherwise, the function would return `nil`and have no effect.

In Go, `panic`is used to signal genuinely exceptional conditions-- fore, programmer error like:

```go
func checkWriteHeaderCode(code int) {
    if code < 100 || code > 999 {
        panic(fmt.Sprintf("Invalid writeHeader code: %v", code))
    }
}
```

For this, the func panics if the status code is just invalid, which is a *pure* programmer error.

Another example based on a programmer error can be cound in the `database/sql`package while registering a dbs driver like:

```go
func Register(name string, driver driver.Driver) {
    driversMu.Lock()
    defer driversMu.Unlock()
    if driver == nil {
        panic("sql: Register driver is nil")
    }
    if _, dup := drivers[name]; dup {
        panic("sql: Register called twice")
    }
    //...
}
```

Another use case in which to panic is when app requires a dependency but fails to initialize it. Panicking in go should be used sparingly.

### when to wrap an error

The `%w`directive allows us to wrap errors conveniently, but some developers may be confused about when to wrap an error -- remind ouselves what error wrapping is then when to use it. Error Wrapping is about wrapping to packing an error inside a wrapper container that also makes the source avaialble. In general, the two main use cases for error wrapping are the following like:

- Adding additional context to an error
- Making an error as a specific error

Fore, receive a request from a specific user to access a dbs resource, but get a *permission denied* error during the query. For debugging purposes, if the error is eventually logged, we want to add extra context. Can wrap the error to indicate who the user is and what resource is being accessed.

Say that instead of adding context, want to mark the error -- fore, want to implement an HTTP handler that checks whether all the errors received while calling functions are a `Forbidden`type, so can return 403 status code.

In both cases, the source error remains available, hence, a caller can also handle an error by unwrapping it and checking the source error. Also note that sometimes we want to combine both approaches -- adding context and marking an error.

See different ways in Go to return an error receive. Will consider the following piece of code and explore different options inside the `if err != nil`block like:

```go
func Foo() error {
    err := bar()
    if err != nil {
        //...
    }
}
```

The first option is to return this code directly, don’t want to mark the error and there is no helpful context we want to add -- like; `return err`directly.

Before Go 1.13, wrap an error, the only option without using an extenal library was to create a custom error type -- 

```go
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return "bar failed:"+ b.Err.Error()
}
```

Then instead of returning `err`directly, wrapped the error into a `BarError`like:

```go
if err != nil {
    return BarError{Err: err}
}
```

The benefit of this option is its flexibility -- cuz `BarError`is a custom struct, can add any additional context if needed. However, being obliged to create a specificc error type can quickly become cumbersome if want to repeat the op. To overcome -- Go 1.13 introduced the `%w`directive like:

```go 
if err != nil {
    return fmt.Errorf("bar failed: %w", err)
}
```

Note that cuz the source error remains available, a client can unwrap the parent error and then check whether the source error was of specific type or value -- 

```go
if err != nil {
    return fmt.Errorf("bar failed:%v", err)
}
```

The source error is no longer available.

Single-record SQL queries -- The pattern for `SELECT`ing a single record from the dbs is a little more complicated -- explain how to do it by updating our `SnippetModel.Get()`so that it returns a single specific based on the ID. Cuz our `snippets`table uses the `id`column as its primary key this query will only ever return exactly one dbs. The query also includes a check on the expiry time so that don’t return any snippets that have expired. Noticed too that we are using a placeholder parameter agina to the `id`.