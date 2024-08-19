# Creating the Remote Repository

When create a remote repository on a hosting service, will give it a *remote repository project name* and the hosting service will provide a *remote repository URL*. The remot repository URL will automatically include the remote repostiory project name. 

The process of creating the remote repository is done entirely on the hosting service’s website. A *public* is visible to anyone to theinternet -- and a *private* one is just visible only to the individuals give access to it. In cases, U can contribiute the repository only if you are provided with access.

Create a remote on hosting, but at this it shows, currently empty -- creating a remote repository on a hosting service doesn up upload any data to it.

### Adding a connection to the remote repostiory 

A local repository can communicate with a remote when the local has a connction to the remote repository stored within it. This will have a name -- which refer to as *remote repository shortname* or just *short name*. To add this use the `git remote add`command, like:

```sh
git remote add <shortname> <URL>
```

For the examples -- may choose to use either your SSL URL or HTTPS URL, just depending on which protocol you have chosen to sue. And the Project was initially locally, so are going to have to add a connection to the remote repository in the local repository explicitly.

And, to see the list of connections to remote repositories stored in a local repository by shortname, may use the `git remote`command -- `-v`passed -- to the `git remote`command.

- The repository has a shortname associated with the remote repository URL, called `origin`.
- `rainbow-remote`repostory still does not have any data in it.

Just cuz you added a connection to the remote repository in your local repository does not mean that any data from the local repository was uploaded to the remote repository.

### Introducing Remotes Branches and Remote-Tracking Branches

Branches, which as you saw are movable pointers to commits. When U push a local branch to a remote repository, you will create a *remote branch* -- a remote branch is a branch in a remote repository.

Remote branches do **NOT** *automatically* update when you make more commits on local branches -- have to explicitly push commits from a local branch to a remote branch. Note that every remote branch also has a *remote-tracking* branch. Every remote branch that a local repository knows about -- also has a *remote-tracking branch*. This is a reference in a local repository to the commit a remote branch pointed at the last time any network communicaiton happended with the remote repository.

Can set up a tracking relationship between a local branch and a remote branch by defining which remote branch a local branch should track. This is referred to as the *upstream branch*.

when push work from a local branch to a remote branch, Git needs to know which remote branch you want to push to. If the local branch has an upstream branch defined for it. Can use `git push`with no arguments, and Git will automatically push the work to that branch. However, If no upstream branch is defined for the local branch U’re working on, need to specify which remote to push to when enter the `git push`command.

Will show you how to specify the remote branch you want to push to when using `git push`command.

### Pushing to a Remote repository

To push a local branch to your remote repository, will use the `git push`command and pass in the shortname for the remote repository and the name of the branch that U want to push. Like:

`git push <shortname> <branch_name>`

1. A remote branch will be created in your remote repository
2. A remote-tracking branch will be created either in your local repository

`git branch --all` # list local branches and remote-tracking branches

```sh
git push origin main
```

The output of the `git push`command indicates that U have pushed your branch to the remote repository -- Note that it dosn’t matter if the numbers in your ouput are slightly different. And can see that the `refs`folder has a new directory inside it called `remotes`-- under it, a file called `main`-- this just represents the new `origin/main`remote-tracking branch. And note that there is no `feature`foder in the remote repository. 

Need to note that for commands like `git commit, push, merge`-- it doesn’t matter if your output has slightly different numbers than the outoput in this book.

## Concurrency: Practice

- Preventing common mistakes with goroutines and channels
- Understanding the impacts of using std data structures alongside concurrent code.
- Using the stdlib and some extensions
- Avoiding data races and deadlocks

### Propagating appropriate context

Context propagation can sometimes lead to subtle bugs, preventing subfunctions from being correctly executed. Fore, exposed an HTTP handler that performs some tasks and returns a reposne -- just before returning the response, also want to send it to a topic -- don’t want to penalize the HTTP consumer latency -- so publish action to be handled async within a new goroutine -- assume that we have at our disposal a `publish`func that accepts a context so the action of publishing a message can be interrupted if the contet is canceled -- like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    resp, err := soSomeTask(r.Context(), r)
    if err != nil {
        http.Error(...)
        return
    }
    go func(){
        err := publish(r.Context(), resp)
        // ...
    }()
    WriteRepsonse()
}
```

`resp`will be used within the goroutine calling `publish`and to format the HTTP response. Note that when calling `publish`, propagate the context attached to the HTTP requst -- 

For this situation -- have to know that the context attached to an HTTP request can cancel in different conditions -- 

1. When the client’s connection closes
2. In the case of an HTTP/2 request, when the request is canceled.
3. When the response has been written back to the client.

In the first two cases, probabley handle things correctly. Fore, if we get a response from `doSomeTask`but the client has closed the connection, it’s probabley OK to call `publish`with a context already canceled so the message isn’t published.

When the response has been written to the client, the context associated with the request will be canceled. Therefore, just facing a race condition -- 

- If the resp is written after the publication, both return a resp and publish a mesage successfully
- However, if the resp is written before or during the Kafka publication, the messages shouldn’t be published.

So in the latter case, calling `publish`will return an error cuz we returned the HTTP resp quickly. One idea is to not propagate the parent context -- call `publish`with an empty context like:

`err := publish(context.Background(), resp)`

Regardless of how long it takes to write back the HTTP response, can call `publish`. But-- what if the context contained useful values -- fore, if the context contained the correlation ID used for distributed trcing, we could correlate the HTTP request and the pbulication. Ideally, would like to have a new context that is detched from the potential parent cancellation but still convey the values.

For the `context.Context`-- 

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <- chan struct{}
    Err() error
    Value(key any) any
}
```

So just create a custom context that detaches the cancellation signal from a parent context like:

```go
type detach struct {
    ctx context.Context
}
func (d detch) Deadline() (time.Time, bool) {
    return time.Time{}, false
}
func (d detach) Done() <-chan struct{} {
    return nil
}
func (d detach) Err() error{
    return nil
}
func (d detach) Value)(key any) any {
    return d.ctx.Value(key)
}
```

Except for the `Value`method that just calles the parent context to retrieve a value, the other methods return a default value so the context is never considered expired or canceled.

`err := publish(detach{ctx: r.Context()}, resp)`

### When to stop a goroutine

Goroutines are easy and cheap to start -- so easy and chep that may not necessarily have a plan for when to stop a new goroutine -- which can lead to leaks -- Not knowing when to stop a goroutine is a design issue and a common concurrency mistake -- understand why and how to prevent it.

In terms of memory, a goroutine starts with a minimum stack size of 2K -- grow and shrink as needed.

```go
ch := foo()
go func() {
    for v := range ch {
        //...
    }
}()
```

For this the created goroutine will exit when `ch` closed -- do we know exactly when this channel will be closed -- May not be evident -- `ch`is created by the `foo()`. So if the channel is never closed, it’s a leak. Fore, a concrete example:

```go
func main(){
    newWatcher()
    // run the ap
}
type watcher struct {...}
func newWatcher(){
    w := watcher{}
    go w.watcher()
}
```

The problem with this code is when `main`exits, the app is stopped, the resource created by the `watcher`are not closed gracefully. One option could be pass to the `newWatcher`a context that will be canceled when `main`returns -- 

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    newWatcher(ctx)
}

func newWatcher(ctx cotnext.Context){
    w := watcher{}
    go w.watch(ctx)
}
```

Propagated the context created to the `watch`method -- when the context is canceled, the `watcher`struct should close its resources -- can we guarantee that `watch`will have tome to do so -- no. The problem is that we used signaling to convey the gorouitne had to be stopped -- so:

```go
func main() {
    w := newWatcher{}
    defer w.close()
    // run the app
}

func newWatcher() watcher{
    w := watcher{}
    go w.watch()
    return w
}

func (w watcher) close() {
    // close the resources
}
```

For this, `watcher`has a new method `close`-- insted of signaling `watcher`that it’s time to `close`its resource, now call this `close`method, using `defer`to guarantee that the resoruces are closed before the app exits.

### Being careful with goroutiens and loop variables

Mishandling goroutiens and loop variables is probably one of the most common mistakes made by Go developers when writing concurrent apps.

```go
s := []int {1,2,3}
for _, i := range s{
    go func(){
        print(i)
    }()
}
```

The output of this code isn’t deterministic -- fore sometimes it prints 233 and others 333... Created new goroutine froma closure -- A closure is a function value that references variables *from outsitde* its body. for this, have to know that when a closure goroutine is executed -- doesn’t capture the values when the goroutine is created. Insted all the goroutines refers to the exact same variable. When a goroutine runs prints the value of `i`at the time `fmt.Print`is executed. `i`may have been modified since the goroutine was launched.

```go
for _, i:= range s{
    val := i
    go func(){
        print(val)
    }()
}

// ... no longer reles on a closure instead uses an actual function
for _, i := range s {
    go func(val int) {
        print(val)
    }(i)
}
```

Still execute an anonymous function within a new goroutine -- but this time it isn’t a closure -- the func doesn’t reference `val`as a variable from outside its body. `val`is now part of the function input.

Have to be cautions with goroutines and loop variables. If the goroutine is a closure that accesses an iteration variable declared from the outside its body, that’s a problem.

## Panic Recovery

Go’s HTTP server assumes that the effect of any panic is isolated to the goroutien serving the active HTTP request. Specifically, following a panic our server will log a stack trace to the server error log -- unwind the stack for the affected goroutine (and calling any deferred functions along the way).

Specially, following -- Importantly, any panic in handlers *won’t* bring down your server.

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        app.notFound(w)
        return
    }
    panic("oops! something went wrong")
    
    snippets, err := app.snippets.Latest()
    //...
}
```

For this, all we get is an empty resp due to the Go closing the underlying HTTP connection following the panic. It would be more appropriate and meaningful to send them a proper HTTP response with a *500 internal server error*.

So a neat way of doing this is to create some middleware which *receovers the panic* and calls `app.serverError()`helper method. To do this -- can leverage the fact that deferred functions are always called when the stack is being unwound following a panic -- 

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponeWriter, r *http.Request) {
        // create a deferred function
        defer func(){
            // use the built in `recover` func to check if there has been a panic
            if err := recover(); err != nil {
                // set a `Connection: close` header on the response
                w.Header().Set("Connection", "close")
                // Call the app.serverError() helper method to return a 500
                app.serveError(w, fmt.Errorf("%s", err))
            }
        }()
        next.ServeHTTP(w,r)
    })
}
```

1. Setting the `Connection: Close`header on the resp acts as a trigger to make Go’s HTTP server automatically close the current connection after the response has been sent. It also informs the user that the connection *will be closed* -- note if the protocol being used is HTTP/2, Go will *automatically* strip.
2. The value returned by the builtin `recover()`has the type `any`-- its underlying type could be `string,error`or something else -- whatever the parameter passed to `panic()`was -- 

Now put this use in the `routes.go`file -- that is the *first* thing in our chain to be executed -- 

```go
func (app *application) routes() http.Handler {
    mux := http.NewServeMux()
    //...
    return app.recoverPanic(app.logRequest(secureHeaders(mux)))
}
```

Restart the app and make a request for the homepage should see a nicely formed *500 Internal Server Error*.

#### Panic recovery in other background goroutines

It’s just important to realise that our middleware will only recover panics that happen in the *same goroutine that executes the `recoverPanic()`middleware*.

Fore, have a handler which spins up another goroutine -- then any panics that happen in the second goroutine will not be recovered - not by the `recoverPanic()`middleware.

So, if are spinning up additional goroutines from within your web app and there is any chance of a panic, must make sure that your recover any panics from within those too fore:

```go
func myHandler(w http.ResponseWriter, r *http.Request) {
    // spin up a new goroutine to do some background processing
    go func() {
        defer func() {
            if err := receover(); err!= nil {
                log.Println(fmt.Errorf("%s\n%s", err, debug.Stack()))
            }
        }()
        doSomebackgroundProcessing()
    }()
    w.Write([]byte("OK"))
}
```

### Composable middleware chains

In this -- like to introduce the `justinas/alice`packate go help us manage our middleware/handler chains. It makes it easy to create composable, reusable, middleware chains, and that can be a real help as your app grows and your routes become more complex -- the package itself is also small and lightweight, and the code is clear and well written.

To demonstrate its feature in one example, allows U to rewrite a handler chain like this -- 

`return myMiddleware1(myMiddleware2(myMiddleware3(myHander)))`

Into this, which is a bit clearer to understand a glance -- like:

`return alice.New(middleware, myMiddleware2, myMiddleware3).Then(myHandler)`

But the real power lies in the fact that you can use it to create middleware chains that can be assigned to the variables, appended to and reused -- fore:

```go
myChain := alice.New(myMiddlewareOne, myMiddlewareTwo)
myOtherChain := myChian.Append(myMiddleware3)
return myOtherChain.Then(myHandler)
```

```sh
go get github.com/justins/alice
```

Then update `routes.go`file -- 

```go
func (app *application) routes() http.Handler {
    mux := http.NewMutex()
    fileServer := ...
    //...
    standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
    return standard.Then(mux)
}
```

### Advanced routing

Going to add a HTML form to our app so that uses can create new snippets -- To make this work smoothly, first need to update our app routes so that requests to `/snippet/create`are handled differently based on the request mthod.

- For `Get /snippet/create`want to show the user the HTML form for adding a new snippet
- For `POST /snippet/create`want to prcess this form data and then insert a new `snippet`record into our dbs.

There are couple of other routing -- related improvements that we will also make -- 

1. Fore, only supporting `GET`requests
2. Use the *clean URLs* so that any variables are included in the URL path and not appended as a query strings.

#### Choosing a router

There a literaly hundreds of 3rd-party routers for Go to pick form.

```sh
go get githumb.com/julienschmidt/httprouter
```

Begin with a simple example to help demonstrate and expalin the syntax -- 

```go
router := httprouter.New()
router.HandleFunc(http.MethodGet, "/snippet/view/:id", app.snippetView)
```

- Initialized the `httprouter`and then use the `HandlerFunc()`to add a new route
- 1st arg to the `HandlerFunc()`is the HTTP method that the request needs to have to be considered a matching request.
- 2nd is the patern that the request URL path must match. Patterns can also include a single `catch-all`parameter in the form `*name`-- these match everything and should be used at the end of a pattern. `/static/*filepath`, For this, need to note that the pattern `/`only match requests where the URL path is exactuly `/`.

```go
func (app *application) routes() http.Handler {
	router := httprouter.New()

	fileServer := http.FileServer(http.Dir("./ui/static/"))
	router.Handler(http.MethodGet, "/static/*filepath",
		http.StripPrefix("/static", fileServer))

	// add then create the routes using the appropriate methods
	router.HandlerFunc(http.MethodGet, "/", app.home)
	router.HandlerFunc(http.MethodGet, "/snippet/view/:id", app.showSnippet)
	router.HandlerFunc(http.MethodGet, "/snippet/create", app.createSnippetForm)
	router.HandlerFunc(http.MethodPost, "/snippet/create", app.createSnippet)

	standard := alice.New(app.recoverPanic, app.logRequest, securityHeaders)

	return standard.Then(router)
}
```

- `julienschmidt/httprouter`is the most focused, lightweight and fastest of the 3 packages -- is about as close to perfect as any 3rd-party router gets in terms of its compliance with the HTTP specs. It automaically handles the `OPTIONS`requests and sends 405 responses correctly, and allows U to set custom handlers for 404 and 405 too.