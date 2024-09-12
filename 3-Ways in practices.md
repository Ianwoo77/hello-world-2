# 3-Ways in practices

The development histroies of the local main branch and the remote branch have diverged for these:

```sh
git commit -m "blue" # under friend repository
git push # rejected!
git log
```

Git is not able to merge changes from one into the other with a simple fast-forward merge. In the friend repository, the local `main`branch points to the blue commit, and in the remote repository, the `main`branch points to the brown commit. Updates were rejected cuz the remote contains work that you do not have locally. This is usually caused by another repository pushing to the same ref. May want to first integrate the remote change before pushing again.

Git is telling your friend that there are commits on the remote `main`branch that they have not yet fetched. remote work and integrate it into their local `main`branch before they can pushi to the remote repository. Note that *pulling* is just similar to the *fetching* -- with some differences.

### In Practice

Learned that incorporating changes from a remote repository is a two-step process -- 

1. First, fetch the changes from the remote
2. Second, integrate the changes into the local branch in the local repository.

This time -- for step 2 -- end up carrying out a 3-way merge instead of a fast-forward merge cuz the development histories of the two branches involved in the merge. When performing a 3-way merge, Git will create a merge commit. To do that, it will enter a tet editor in the command line.

If a commit is being made and a commit message is not specified, Git will enter VIM in the command line. When Git enters Vim in the command line, have the choice to enter ... In the case of a 3-way merge, Git will draft a default comit message for the message commit and Vim will present it to you,

#### Executing the 3-way merge

Now is going to fetch the changes from the remote `main`into their local repostiory -- this will update the `origin/main`brnch -- like:

```sh
git fetch # under the firend
git merge origin/main # then write commit message
git log
```

`git merge`output says *merge msde by the ‘ort’ strategy*, means that this was a 3-way merge intread of a fast-forward merge. And Git drafted a default commit message for U which was either.. both correct just. `git log`shows the merge commit lists two parent commits in the merge field. Need to notice -- In the friend repository, illustrate the merge commit as M1 and show how it ties the two development histories together.

```sh
# tree... parent... parent...
git cat-file -p 8be7a6b5cddc6590dc1468ec453a9cf7b9e43b4b
git push
git log
```

Then go to the remote repository can see new page. The M1 merge commit is now in the `friend-rainbow`repository and the remote repository. The next step is for you to sync your rainbow repositoyr with the remote repository, Updating your loal `main`with the merge commit as well. Need learn about pulling in Git.

### Pulling Changes from a Remote repostiory

Up until now, in the `Rainbow`proj, when U wanted to update your local repository with changes from the remote repository you did in two steps -- first U fetched the data from the remote repository -- `git fetch`command, then U merged the data into the local branch -- Pulling data allows U to do both *in one go*.

In Git, use the term *pull* or *pulling* to refer the process of fetching data from a remote repository and integrating into a branch in a local repository in one go, and the command use is `git pull`. And if we don’t have an upstream branch defined for your local branch, then must speicify the shortname of the remote repository and the name of the branch that your want to update.

```sh
git pull <shortname> <branch_name>
git pull # if upstream is defined
```

There is one more thing need to know about the `git pull`-- In Git there are two ways to integrage changes -- merging and *rebasing*. Which method the `git pull`uses will depend on whether the development histories of the branches have diverged and if so, on the option you choose when entering the command.

If development histories of the local and remote in a `git pull`just have diverged, then must tell Git whether U want to integrate the changes by merging or *rebasing*. To tell git to integrate the cahnges by merging, must pass in the `--no-rebase`option -- to tell Git to integrate the changes by rebasing, using `--rebase`

**git fetch + (git merge) OR (git rebase) = git pull**

Now the question is -- When should fetch and integrate changes in two steps by using the `git fetch`command and then either the `git merge`or the `git rebase`command. And when should U carry out both of those steps in one go by just using the `git pull`. It’s just common for Git users to use the `git pull`command when development histories of the local and remote branches have not diverged. 

If the development histories of the local and remote branches have diverged, Git users often prefer to use the `git fetch`command then choose whether to rebase or merge in a separate step. By carrying out process in two steps, they give themselves more time to look what is gonig to change in their local branch and to prepare for the integration process. Generally -- U will use only the `git pull`when just a fast-forward merge will update local branch.

```sh
git pull # under rainbow repository
git log
```

## How defer args and receivers are evaluated

Mentioned that the `defer`statement delays a call’s execution until the surrounding function returns. A common mistake made by Go developers is not understanding how arguments are evaluated -- delve into this problem with two subsections -- one related to function and method arguments and the second related method receivers.

#### Argument evaluateion

```go
const (
	StatusSuccess = "success"
	StatusErrorFoo = "error_foo"
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

Run the func, see that *regardless* of the execution path, `notify()`and `incrementCounter()`are always called with the same status -- *empty string*.

In the `defer`-- the arguments are *evaluated right away*, not once the surrounding function returns. In our example, call `notify(status)`and `incrementCounter(status)`as `defer`functions. Therefore, Go will delay these calls to be executed once `f`returns with the current value of `status`at the stage we used `defer`, hence passing an empty string. So like:

```go
var status string
defer notify(&status)
defer incrementCounter(&status)
```

Keep updating `status`depending on this case, but now `notify`and `incrementCoutner`receive a string pointer. Just note that using `defer`evaluates arguments right away. status’ address remain constant. 

And there is another solution - -call a closure just -- Anonymous function value that references variable from outside its body. The arguments passed to a `defer`function are evaluated right away -- Must know that the variables referenced by a `defer`are evalued *during* the closure execution like:

```go
func f() error {
    var status string
    defer func() {
        notify(status)
        incrementCounter(status)
    }()
    //...
}
```

Here, just wrap the calls to both `notify`and `incrementCounter`within a closure. This closure references the `status`from outside its body.

#### Pointer and value receivers

The same logic related to argument evaluation applies when use the `defer`on a method -- the receiver is also evaluated immediately -- like:

```go
type Struct struct {
	id string
}

func (s Struct) print() {
	fmt.Println(s.id)
}

func main() {
    s := Struct {id: "foo"}
    defer s.print()  // also `foo` printed
    s.id="bar"
}
```

For this, defer the call to the `print`method, as with arguments, calling `defer`makes the receiver be evaluated immediately -- hence, `defer`delays the method’s execution with a struct that contains an `id`field equal to `foo`.

Conversely, if the poitner is a receiver, the potential changes to the recevier after the call to `defer`are visible like:

```go
func main() {
    s := &Struct {id: "foo"} // or not & just good 
    defer s.print()  // bar
    s.id=bar
}
func (s *Struct) print(){
    //...
}
```

For now the `s`recevier is also evaluated immediategly.

### Error Management -- 

- Understanding when to panic
- Knowing when to wrap an error
- Comparing error types and error values efficienty since Go 1.13
- Handling errors idiomatically
- Understanding how to ignore an error
- Handling errors in `defer`.

Error management is a fundamental aspect of building robust and observable applications, and it should be as important as other part of codebase - In Go, error management doesn’t relay on the traditional try/catch as most programming language do.

### Panicking

In Go, errors are usually manged by functions or methods that return an `error`as the last parameter, Refresh our minds about the concept of `panic`and discuss when it’s considered appropratie not to panic.

```go
func main(){
    fmt.Println("a")
    panic("foo")
    fmt.Println("b")
}
```

Once a panic triggered, continues up the call stack until either the current goroutine has returned or `panic`is caught with `recover`.

```go
func main(){
    defer func() {
        if r:= receover(); r!=nil {
            fmt.Println(...)
        }
    }()
    f()
}
func f() {
    //...
    panic("foo")
}
```

Note that *calling `recover()`to capture a goroutine panicking is only useful inside the `defer`*. Otherwise, the func would return `nil`and have no other effect. This is because `defer`are also executed when the surrounding function panics.

In Go, `panic`is used to signal genuinely exceptional conditions -- programmer error -- fore, 

```go
func checkWriteHeaderCode(code int) {
    if code <100 || code>999 {
        panic(...)
    }
}
```

Another based on a programmer error fore `database/sql`package like:

```go
func Register(name string, driver driver.Driver) {
    driverMu.Lock()
    defer driverMu.Unlock()
    if driver == nil {
        panic("sql: Register driver is nil")
    }
    if _, dup := driver[name]; dup {
        panic("sql: Register called twice")
    }
    //...
}
```

And another use case in which to panic is when our app requires a dependency but fails to initialize it. Fore the `regexp`package exposes functions to create a regular expression from a string, `Compile`and `MustCompile`-- the latter returns only the `*regexp.Regexp`but panics in case of an error.

So, Panicking in Go should be used sparingly.

## An HTTP Session Manager-- 

An HTTP session is a way to store data across multiple HTTP requests -- when you browse the web, each request and response from your browser to a server is stateless -- The server does not remember the state of each client between different requests. However, in many applications, it’s crucial to maintain state information acorss requests.

How HTTP sessions work -- 

1. *session creation* -- When a client makes an initial request to a server, the server can create a session to track interactions with that particualr client. The server generates a Session ID for this.
2. *Storing Session ID* -- typically sent to the client’s browser in the form of a cookie.
3. *Ussing Session Data* -- On the server side, session data related to the session ID can stored in various ways.
4. *Session expiration* -- 

### Setting up the session manager -- 

`alexedwards/scs`package -- Just need to create a `sessions`table in the MySQL dbs to hold the session data for our users. Just like:

```sql
create table sessions (
	token CHAR(43) PRIMARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTAMP(6) not NULL
);
CREATE INDEX session_expriy_idx ON session(expiry);
```

The next thing need to do is establish a *session manager* in the `main.go`file and make it available to our handlers via the `appliation`struct -- the session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving of the session data.

```go
type application struct {
    //...
    sessionManager *scs.SessionManager
}
func main(){
    //...
    // Use the scs.New() to initialize a new session manager, then configure that
    sessionManager := scs.New()
    sessionManager.Store= mysqlstore.New(db)
    sessionmanager.Lifetime= 12*time.Hour
    
    // Add to the application dependencies
    app := &application {
        //...
        sessionManager: sessionManager,
    }
}
```

For the session to work, also need to wrap our app routes with the middlewre by the `SessionManager.LoadAndSave()`method. Note that this middleware automatically loads and saves session data with every HTTP request and response.

And note that we don’t need this middleware to act on *all* our app routes. Fore, `/static/*filepath`. So in the routes:

```go
func (app *application) routes() http.Handler {
	router := httprouter.New()
	// ...
	// Create a new middleware chain containing middleware specific to
	// dynamic app routes.
	dynamic := alice.New(app.sessionManager.LoadAndSave)

	// Update these routes to use the new dynamic middleware chain
	// Use ThenFunc() which returns an http.Handler
	router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
	router.Handler(http.MethodGet, "/snippet/view/:id", dynamic.ThenFunc(app.snippetView))
	router.Handler(http.MethodGet, "/snippet/create", dynamic.ThenFunc(app.snippetCreate))
	router.Handler(http.MethodPost, "/snippet/create", dynamic.ThenFunc(app.snippetCreatePost))

	standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)
	return standard.Then(router)
}
```

#### Additional info -- Without using `alice`-- 

If are not using the `justinas/alice`package to help mange your middleware chains, Then you will need to use just the `http.HandleFunc()`adapter to convert your handler functions like the `app.home`... Just like:

```go
router := httprouter.New()
router.Handler(http.MethodGet, "/", app.sessionManager.LoadAndSave(http.HandlerFunc(app.home)))
```

### Working with the session data

Put the session functionality to work and use it to persist the confirmation flash message between HTTP request. need first to update our `snippetCreatePost`so that a flash message is added to the user’s session data.

```go
// Use the Put() method to add a string value and corresponding key
app.sessionManager.Put(r.Context(), "flash", "Snippet successfully created!")
```

- The first parameter pass to the `app.sessionManager.Put()`is the current request context,
- The second `flash`-- is the key for the specific message that we are adding to the session data.
- If there is no existing session for the current user, then a new, empty, session for them will automatically be created by the session middleware.

```go
// use the PopString() method to retrieve the value for the flash key
// PopString() also deletes the key and the value from the session data.
flash := app.sessionManager.PopString(r.Context(), "flash")

data := app.newTemplateData(r)
data.Snippet = snippet
data.Flash = flash
```

Then just add the `Flash`to the `templateData`struct. Now can just update the `base.layout.html`like:

```html
<main>
    {{with .Flash}}
    <div class="flash">{{.}}</div>
    {{end}}
    {{template "main" .}}
</main>
```

Just remember that the `{{with .Flash}}`block will only be executed if the value of the `.Flash`is not the emtpy string. So, if there is no `flash`key in the current user’s session.

#### Auto-displaying flash messages -- 

And a little improvement we can make is to automate the display of flash messags -- so that any message is automatically included the next time *any page is rendered*. Do this by adding any flash message to the template via the `newTempalteData()`like:

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
	return &templateData{
		CurrentYear: time.Now().Year(),
		Flash: app.sessionManager.PopString(r.Context(), "flash"),
	}
}
```

Making that change just means that we no longer need to check for the flash message within `snippetView`handler.

#### Additional info - Behind the scenes of session management

To unpack some behind the session management -- *ession cookie* -- and it will be sent back to the Snippetbox application with every request that your browser makes. And the session cookie contains the *session token* -- also sometimes known as the *Session ID* -- the session token is a high-entropy random string. It’s important to emphasize that the session token is just a random string. In itself, it doesn’t carry or convey any *session data*.

Now in the `sessions`table -- This should return one record -- the `data`value here is the thing that *actually contain* our session data. Each and every time we make a change to our session data, this `data`value will be updated. The final column in the dbs is the `expiry`time - after wihch the session will no longer be considered valid.

So -- what happens in our application is that the `LoadAndSave()`middleware checks each incoming request for a session cookie -- if a session cookie is just present, it reads the session token and retrieves the corresonding session data from the dbs. Any changes that you make to the session data in your handlers are updated in the request context, and then `LoadAndSave()`middleware updates the dbs with any changes to the session data.

Security improvements -- Going to make some improvement to our app so that our data is kept secure during transit and our server is better able to deal with some common types of denial-of-service attacks.

- Quickly and easily create a *self-signed* TLS certificate -- using only Go
- The fundamentals of setting up your app so that all requests and responses are served securely over HTTPs.
- Some sensible tweaks to the default TLS settings to help keep user info secure and performing quickly
- How to set conenction timeouts on the server to mitgate slow-client attacks.

### Self-signed TLS certificate -- 

HTTPs is essentially HTTP sent across a TLS conenction -- For production servers, fore *Let’s Encrypt* to create, but for developement purposes the simplest thing to do is to generate own self-signed certificate.

A self-signed is the same as normal TLS certificate - except that it isn’t cryptographically signed by a trusted certificate authority. This means that your browser will just raise a warnning the first time.