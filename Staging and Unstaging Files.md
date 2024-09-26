# Staging and Unstaging Files

Fore, in this, friend is going to make changes to both of the files in the `friend-rainbow`and add them to the staging area -- but then, they just will realize they want to make two separate commits for the different pieces of work. Therefore, they will have to *unstage* files.

```sh
# edit the readme.md and othercolors.txt files
git status
```

- The modified versions of the files tha your friend edited are represented as vB.
- The versions of the files in the staging area are different from the verisons in the working directory

```sh
git add readme.md othercolors.txt
git status
```

Added both the modified files to the staging area. And the versions of files have changed from vA to vB.

Assume that your frend decides they want to make *separate* commits for the work they did adding the color. Staging area is like a rough draft space where U can add and remove modified files to craft what will be included in your next commit. Now you are going to see how to remove a modified file from the staging area -- chagne the version of the file in the staging file from the staging area. Git just provides the instructions for how to *unstage* a file:

```sh
git restore --staged <file>
```

To remove files from the staging are U can use the `git restore`command with the `--staged`option, passing in the names of any files you wan to unstage.

```sh
git restore --staged readme.md
git status # modified othercolors.txt and modified othercolors (red)
```

- The `git status`output shows that the updated version of the `othercolors.txt`file is still in the staging area.
- And your friend unstaged the `readme.md`file, so the version in the staging area just went back to A
- The updated version of `othercolors.txt`is till in the staging area
- The version of `readme.md`'s most chnages is still in the working directory.

```sh
git commit -m "black"
git status # modified readme.md (red)
git log
```

For this, frend made the black commit, and `git status`output mentions that the `readme.md`file is a modified file in the wroking directory.

Now, your friend will add the changes that they made to the `readme.md`file to the staging area and make another commit like: 

```sh
git add readme.md
git commit -m "rainbow"
git log
```

M2 <- BL <- RA --  The version of the `readme.md`file in the staging area is now vB, which is the version that is part of the rainbow commit. Saw how your friend was able to add files to and remove them from the staging area in order to craft exactly the commits they wanted -- the local `main`in the `rainbow`and the local `main`in the `friend-rainbow`now have *divergent* development histories.

Before continues with the rebasing example, need to make sure to fetch all the work U have pushed to the remote `main`branch from the remote repostiroy.

### Preparing to Rebase

To rebase a branch U first have to fetch all the work that has been done on the branch that U want to rebase onto. Fore, friend is going to fetch the latest updates from the remote repository like:

```sh
git fetch 
git log --all # friend fetched the gray from the remote repository
```

The `origin/main`remote-tracking branch in the `friend-rainbow`repostiory represents the latest version of the remote `main`branch. Your friend is now ready to rebase their local `main`onto the `origin/main`.

### The **5** stages of the Rebase Process

When your friend rebases their local `main`in the `friend-rainbow`repository onto the `origin/main`remote-tracking branch -- Use the `git rebase`command to initite the *rebase process*. Git will then carry out the 5 stages of the process itself.

#### Stage 1 -- find the common ancestor

In the first stage of the process, Git will identify the common ancestor of the two branches involved in the rabase. The branch U are on and the branch you are rebasing onto. In the exmaple, the branch your friend will be on is the local `main`branch in the `friend-rainbow`repository and the branch they will be rebasing onto will be the `origin/main`remote-tracking branch. For this, the common ancestor will be the M2 merge commit.

#### Stage2 -- Store information about the branches involved in the rebase

In stage 2, Git will save the changes introduced by each commit of the branch you are on to a temporary area. It will also save additional info in the temporary area. In the Rainbow proj -- the changes introduced by the *black* and *rainbow* commits will be saved in the temporary area along with the info about the remote `main`.

#### Stage3 -- reset HEAD

Git will reset HEAD to point to the same commit as the branch you are rebasing onto. In the proj, will reset `HEAD`to the same commit that the `origin/main`remote-tracking branch is pointing to.

#### Stage4 -- Apply and commit the chagnes

Git will apply the set of changes from each commit in turn, making a commit after it applies each set. In the `Rainbow`proj, first it will apply the cahnges introduced by the black commit and create a new commit, and then it will apply the changes by the `rainbow`commit. M2 <- GR <- BL’ <- Ra’

#### Stage5 -- switch onto the Rebased branch

In stage5, Git will make the branch u rebased point to the last commit it reapplies, and will checkout that branch so that the HEAD points to it.

This concludes our walkthrough of 5 stages of the rebase process. As mentined at the beginning -- Git carries out the entire process itself.

## Standard Library

- Providing a correct time duration
- Understanding potential memory leaks while using `time.After`
- Avoiding common mistakes in the JSON handle and SQL
- Closing transient resources
- Remembering the `resturn`in HTTP handlers
- Why production-grade apps shouldn’t b use default HTTP clients and servers

The Go stdlib is a set of core packages that enhance and extend the language. Fore, Go developers can write HTTP clients or servers, handle JSON dta, or interact with SQL dbs. All of these features are provided by the STDLIB. It can esy to misuse the stdlib, or we may have a limited understanding of its behavior, which can lead to bugs and writing apps that shouldn’t be considered production-grade.

### Providing a wrong time duration

The stdlib provides common functions and methods that accept a `time.Duration`. Cuz `time.Duration`is an alias for the `int64`type, to illustrate this common error, create a new `time.Ticker`will deliver the ticks of a clock every second: fore:

```go
ticker := time.NewTicker(1000)
for{
    select {
        case <-ticker.C:
        //...
    }
}
```

For this, ticks are not delivered every second, delivered every *ms* cuz `time.Duration`is based on the `int64`-- it represents the elapsed time between two instants in *ns*. Furthermore, if want to purposely create `time.Ticker`with an interval of 1 ms, shouldn’t pass in `int64`directly, should instead always use the `time.Duration`API like:

```go
ticker := time.NewTicker(time.Microsecond)
```

### `time.After`and memory leaks

`time.After(time.Duration)`is a convenient function that returns a channel and waits for a provided duration to elapsed before sending a message to this channel. The advantge of `time.After`is that it can be used to implement scenarios such as *if don’t receive any message in this channel for 5s, I will...*-- But note that codebases often include calls to `time.After`in a loop, which as -- may be a root cause of memory leaks -- will implement a func that repeatedly consumes messages from a channel fore, want to log warning if havn’t received any message for 1h, like:

```go
func consumer(ch <-chan Event) {
    for {
        select {
        case event := <-ch:
            handle(event)
        case <-time.After(time.Hour):
            log.Println("warning: no message received")
        }
    }
}
```

It may lead to memory usage issues -- Need to note -- `time.After`returns a channel -- May expect this channel to be closed during each loop iteration -- but this isn’t the case -- The resources created by `time.After`are released once the timeout expires and use memroy until that happens. About 200bytes per call to the `time.After`. For this example, if receive a significant volume of messags, such s 5M per hour, will consume 1GB to store the `time.After`resources. Note that the returned channel is a `<-chan time.Time`-- r*eceive-only channel that can’t be closed*. And, have several options to fix -- like:

```go
func consumer(ch <-chan Event) {
    for {
        ctx, cancel := context.withTimeout(context.Background(), time.Hour)
        select {
        case event := <-ch:
            cancel()
            handle(event)
        case <-ctx.Done():
            log.Println("no messages received")
        }
    }
}
```

The downside of this approach is that we have to re-create a context during every single loop iteration. Note that creating a context isn’t the most lightweight in Go.

The second comes from `time`-- `time.NewTimer`-- this creates a `time.Timer`that exports -- 

- `C`-- internal timer channel
- `Reset(time.Duration)`-- reset the duration
- `Stop()`to stop the timer

```go
func consumer(ch <-chan Event) {
    timeDuration= time.Hour
    timer := time.NewTimer(timerDuration) // Create a new timer
    for {
        timer.Reset(timeDuration) // reset the duration
        select {
        case event := <-ch:
            handle(event)
        case <-time.C:
            log...
        }
    }
}
```

Calling the `timer.Reset()`method -- is less cumbersome than having to create a new context every time. It’s faster and less pressure on the GC cuz it doesn’t require any new heap allocation.

So, in general, we should be cautious when using `time.After`-- remember that the resources created will only be released when the timer expirs. When `time.After`is repeated, it may lead to a peak in memory consumption.

### Common JSON-Handling mistakes

Go has excellent support for JSON with `encoding/json`package -- Covers 3 common mistakes related to encoding and decoding JSON data -- fore:

#### Unexpected behavior dut to type embedding

In the context of JSON handling, discuss another potential impact of type embedding that can lead to unexpected marshaling/unmarshaling results -- like: Create an `Event`struct containing an ID and an embedded timestamp:

```go
type Event struct {
    ID int
    time.Time
}
```

Cuz `time.Time`jsut embedded, in the same way -- can access methods directly at the `Event`level. But - what are the possible impacts of embedded fields with JSON marshaling -- fore, will instantiate an `Event`and marshal it into JSON:

```go
event := Event{
    ID:1234,
    Time: time.Now(), // name of anonymous is name of struct
}
b, err := json.Marshal(event)
if err != nil {
    return err
}
fmt.Println(string(b))
```

like {“ID”: 1234, “Time”: “2021-...”}.. But only the Time part ouptuted -- If an embedded field tyep implements an interface, *the struct containing the embedded filed will also implement this interface*. Second, can change the default marshaling behavior by making a type implement the `json.Marshaler`interface -- contains a single `MarshalJSON`function just like -- 

```go
type Marshaler interface {
    MarshslJSON() ([]byte, error)
}
```

And here is an example with custom marshling -- like:

```go
type foo struct{}

func (foo) MarshalJSON() ([]byte, error) {
	return []byte(`"foo"`), nil
}

func main() {
	b, err := json.Marshal(foo{})
	if err != nil {
		panic(err)
	}
	fmt.Println(string(b))
}
```

Cuz have changed the default JSON marshaling behavior by implementing the `Marshaler`interface -- having clarified these two points -- just look out -- 

```go
type Event struct {
    ID int
    time.Time
}
```

Note that the `time.Time`also implements the `json.Marshaler`interface -- cuz `time.Time`is an embedded field of `Event`, the compiler just promites its methdos, therefire, `Event`also implement the `json.Marhaler`. Consequently, passing an Event to `json.Marshal`uses the marshaling behavior provided by the `time.Time`instead of the default behavior. Just :

```go
type Event struct {
    ID int
    Time time.Time
}
```

And, if want or *have to* keep the `time.Time`embedded, the other is ao make it implement the `json.Marshaler`.

```go
func (e Event) MarshalJSON() ([]byte, error) {
    return json.Marshal (
        struct {
            ID int
            Time time.Time
        }{
            ID: e.ID,
            Time: e.Time
        }
    )
}
```

So, should be careful with embedded fileds, while promoting the fields and methods of an embedded filed type can sometimes be convenient, but it can also lead to subtle bugs cuz it can make the parent struct implement structs without a clear signal.

## The `request`context syntax-- 

The basic code for adding info to a request’s context looks like this - 

```go
ctx := r.Context() // r is a *http.Request
ctx = context.WithValue(ctx, "isAuthenticated", true)
r = r.WithContext(ctx)
```

- First, use the `r.Context()`to retrieve the existing context from a request and assign it to the `ctx`variable.
- Use the `context.WithValue()`method to crete a *new copy* of the existing context, containing the key and value
- use the `r.WithContext(ctx)`method to create a copy of the request containing the new context.

IMPORTANT -- notice that we don’t actually update the context for a request directly -- what we are doing is creating a *new copy* of the `http.Request`object with our new context in it. For clarity -- 

```go
ctx = context.WithValue(r.Context(), "isAuthenticated", true)
r = r.WithContext(ctx)
```

The important thing to explain is -- behind the scenes, requset context values are stored with the type `any`. Fore, to retreive a value like:

```go
isAutnticated, ok := r.Context().Value("isAuthenticated").(bool)
if !ok {
    return errors.New("...")
}
```

#### Avoiding key collisons

In the code -- used the string `isAuthenticated`-- but it isn’t recommended cuz there is a risk that other 3rd-party packages used by your app will also wan to store data using the key `isAuthenticated`-- to avoid this, just like:

```go
type contextKey string
const isAuthentiatedContextKey= contextKey("isAuthenticated")
```

### Request Context for authentication/authorization

Start to use the request context functionality in our app like:

```go
func (m *UserModel) Exists(id int) (bool, error) {
	var exists bool
	stmt := "SELECT EXISTS(select true from users where id=?)"
	err := m.DB.QueryRow(stmt, id).Scan(&exists)
	return exists, err
}
```

Then, create a new `context.go`-- define a custom `contextKey`type and variable like:

```go
type contextKey string
const isAuthenticatedContextKey= contextKey("isAuthenticated")
```

And now for the exicting part, create a new `authenticate()`middleware which -- 

1. Retrieves the User’s ID from the session data
2. Checks the dbs to see if the ID corresponds to a valid user using the `UserModel.Exists()`
3. Update the request context to include an `isAuthentcatedContextKey`with the value `true`like:

```go
func (app *application) authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := app.sessionManager.GetInt(r.Context(), "authenticatedUserID")
		if id == 0 { // id is 0 if no authenticatedUserID in the session
			next.ServeHTTP(w, r)
			return
		}

		// otherwise, check if a user with ID exists
		exists, err := app.users.Exists(id)
		if err != nil {
			app.serverError(w, err)
			return
		}

		// if matching user found, create a new copy of the request
		if exists {
			ctx := context.WithValue(r.Context(), isAuthenticatedContextKey, true)
			r = r.WithContext(ctx)
		}

		// call the next handler in the chain
		next.ServeHTTP(w, r)
	})
}
```

- When don’t have a valid authenticated user, just pass the original and unchanged Request to the next handler in the chain
- When do have a valid authentiated user, create a copy of the request with a `isAuthentiatedContextKey`and `true`value stored in the request context. Then pass a copy of `*http.Request`to the next handler in the chain.

Then need to udpate the routes.go to include the `authenticate()`in the `dynamic`chain like:
`dynamic := alice.New(app.sessionManager.LoadAndSave, noSurf, app.authenticate)`

And need to do is update our `isAuthenticated()`helper, so that insted of checking the session dta it now checks the requeste context to determine if a user is authenticated or not like:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	isAuthenticated, ok := r.Context().Value(isAuthenticatedContextKey).(bool)
	if !ok {
		return false
	}
	return isAuthenticated
}
```

### Optional Go featurs

Two Go features that are just relatively new additions to the language -- *file embedding* and *generics*.

- *File embedding* makes it possible to embed external files into your Go program itself.
- *Generics* reduce the amount of boilerplate code you need to write.

One of the headline features of the Go 1.16 release ws the `embed`package -- which makes it possible to *embed external files into Your Go program itself*.

Illustrate that -- update app to embed and use the files in existing `ui`directory -- like: 

```sh
touch ui/efs.go
```

```go
package ui

import "embed"

//go:embed "html" "static"
var Files embed.FS
```

For the comment line -- `//go:embed "html" "static"`-- This looks like a comment -- but it is actually a special comment *directive* -- When app is compiled, this comment directive instructs Go to store the files from our `ui/html`and the `ui/static`folder in an `embed.FS`embedded filesystem referened by the global variable `Files`.

There are a few important details about whis which we need to explain -- 

- The comment directive must be placed *immediately above the variable* in which u want to store the embedded files
- The directive has the general format `go:embed <paths>`-- and it’s ok to specify multiple paths in one directive. And the paths should be *relative to the source code file* containing the directive.
- U can only use the `go:embed`directove on **global** variables at *package level*, not within functions or methods. If try to use it within a function or method, you will get the error at compile time.
- Paths cannot contain `.`or `..`elements. Nor may they begin with a `/`. This essentially restricts U to only embedding files that are contained in the same directory as the source code which has the `go:embed`directive.
- If a path is a directory, then all files in the directory are **recursively** embedded, except for files names begin with `.`or `_`note that -- if want to include all files, should use the `all:`prefix like: `go:embed "all:static"`
- The path separator should always be a forward slash.
- The embedded file system is *always* rooted in the directory which contains the `go:embed`directive, so in the example, our `Files`variable contains an `embed.FS`embedded filesystem and the root of the filesystme is our `ui`directory.

#### Using the static files -- 

Switch up our app that it serves our static CSS, JS and image files from the embedded system like:

```go
fileServer := http.FileServer(http.FS(ui.Files))
// dispatch a single handler
router.Handler(http.MethodGet, "/static/*filepath", fileServer)
```

