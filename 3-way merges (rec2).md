# 3-way merges (rec2)

`rainbow`and `friend-rainbow`and one remote repostiory called `rainbow-remote`-- All three of these repositories should be in sync, in other words, they should contain the same commits and branches. Recommend that continue using two separate text editor windows and command line windows for the `rainbow`repostiory.

3-way merges are bit more complicated than fast-forward merges cuz they create merge commits and they may lead to merge conflicts. *Fast-forward* merges and 3-ways merges. 3-ways are a bit more complicated then fast-forward merges cuz they create merge commits and they may lead to merge conflicts -- *merge conflicts* rais when merge two branches where different changes have been made to *the same prats in the same files*.

### Setting up a 3-way merge Scenario 

```sh
# add a new file called othercolors.txt
git add othercolors.txt
git commit -m "brown"
git log
```

#### Defining Upstream Branches

You will need to specify which remote branch to push when you enger the `git push`command -- if a local branch has an upstream branch defined for it, you can use `git push`with no arguments and Git will automatically push the work to that branch.

To set up the upstream branch will use the `git branch`command with the `-u`option, shorter for `--set-upstreame-to`-- pass in the name of the remote branch as an argument, specifying remote repository short name.

```sh
git branch -u <shortname>/<branch_name>
# just like:
git branch -vv # if have upstream
git branch -u origin/main
git branch -vv # ahead...
```

In the last one, output shows that the `main`from the remote repostiory with shortname `origin`has been set as the upstream branch for the local `main`branch.

```sh
git push
git log
```

#### Editing the same file multiple times between commits

```sh
# open the rainbowcolors.txt in the friend-rainbow
git status
git add readme.md
git status
# change the content
git status
git add readme.md
git status
git commit -m "blue"
git push # rejected, error: failed to push some refs to ...
git log
```

The development histories of the local `main`branch and the remote `main`branch have diverged -- And Git is not able to merge chnges from one into other with just a simple fast-forward merge.

Git is telling U.. that three commits on the remote `main`that they have not yet fetched -- It advised U that they have to fetch or pull the remote work and integrate it into their local `main`before they can push to the remote repostiory.

### 3-way in practice

When performing a 3-way merge, Git will create a merge commit -- to do that, it will enter a text editor in the command line -- A 3-way merge happens when Git tries to combine changes from two branches -- (usually current branch and a branch U are merging into) with the common ancestor of those branches.

Git often uses a text editor to help *resovle merge conflicts*.

When git enters editor, have the choice to enter text, edit text, or approve and save text. In the case of a 3-way merge, Git will draft a defualt commit mesage for the merge commit and will present it to you.

#### Executing the 3way merge 

Having read the error message Git presented, your friend is now going to fetch the changes from the remote `main`into their local repository. Will update the `origin/main`remote-tracking branch like:

```sh
git fetch # friend-rainbow directory
git merge origin/main # will enter editor `:wq` then see 1+...
git log
```

`git merge`says *Merge made by the `ort` strategy* -- indicates that this is a 3-way merge instead of a fast-forward one. `git merge origin/main`just merge the main with origin/main

```sh
git cat-file -p <hash> # can see two parents
git push
```

#### Pulling changes from a remote repository -- 

In Git -- *pull* refers to the process of fetching data from a remote and integrting it into a branch in a local repository in one go. 

```sh
git pull <shortname> <branch_name>
```

`git fetch`**+** **`git merge` or `git rebase`* =** `git pull`

```sh
# in the rainbow
git pull
```

## Go Contexts

Developers sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the language and a foundation of concurrent code in Go -- A context carries a deadline, a cancellation signal, and other values acrosss API boundaires.

#### DeadLine

A deadline refers to a specific point in time determined with one of the following -- 

- A `time.Duration`from now
- A `time.Time`.

The semantics of a deadline cnvey that on ongoing activity should be stopped if this deadline is met. An activity is fore -- an I/O request or a goroutine waiting to receive a message from a channel. Consider an app that receives flight position from a radar ever 4s. Once we receive a position, may want to share it with other applications that are only interested in the latest position -- like:

```go
type publisher interface {
    Publish(ctxx context.Context, position flight.Position) error
}
```

This method accepts a context and a position -- assume that the concrete implementation calls a function to publish a message to a broker. This function is *context aware* -- meaning it can cancel a request once the context is canceled. Assuming don’t receive an existing context -- what should provide to the `Publish`for the context argument -- like:

```go
type publishHandler struct {
    pub Publisher
}
func(b publishHandler) publshPosition(position flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
    defer cancel()
    return h.pub.Publish(ctx, position)
}
```

This code creates a context using `context.WithTimeout()`-- this func accepts a timeout and a context. Here, as `PublishPosition`doesn’t receivie an existing context, create one from an empty context with `context.Background()`-- Meanwhile `context.WithTimeout()`returns two variables -- context crated and a cancellation `func()`that will cancel the context once called. Passing the context created to the `Publish()`should make it return in at most 4s.

Internally, `context.WithTimeout()`creates a goroutine that will be retained in memory for 4s **or until `cancel`is called**. Therefore, calling `cancel`as a `defer`means that when we exit the parent function, the context will be canceled. And the goroutine created will be stopped.

#### Cancellation signals

Another usecase for Go contexts is to carry a cancellation signal -- Imagine -- want to create an app that calls `CreatefileWather(ctx context.Context, filename string)`within another goroutine. Func creates a specific file watcher - keeps reading from a file and creates updates. When period expires or canceled, close file.

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    // when main returns, things to be handled gracefully by closing this file
    defer cancel()
    go func() {
        CreateFileWatcher(ctx, "foo.txt")
    }
}
```

Fore how to use `WithCancel()`to close a file when a context is cancellled -- like:

```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    file, err := os.Open("example.txt")
    if err != nil {
        return
    }
    defer file.Close()
    
    go func() {
        <- ctx.Done()
        file.Close()
        fmt.Println("File closed")
    }()
    //...
    cancel()
    select {} // wait for the goroutine to finish
}
```

#### Context Values

The last use case for Go contexts is to carray a k-v list -- before understanding the rationale behind -- first how - 

`ctx:= context.WithValue(parentCtx, "key", "value")`

Just like `context.WithTimeout(...), WithDeadline, WithCancel`-- this is created also from a parent contxt, in this case, create a new `ctx`context containing the same characteristics as `parentCtx`but also conveying a key and a vlaue. -- when access the vlaue using -- 

```go
ctx := context.WithValue(contxt.Background(), "key", "value")
fmt.Println(ctx.Value("key")) // value
```

The key and value provided are `any`type -- indeed, for this value, want to pass `any`. That could lead to colllisions. Two functions from different packages could use the same string value as a key -- Consequently, a *best* practice wihile handling context key is to create an *unexported* custom type like:

```go
type key string
const myCustom key = "key"
func f(ctx context.Context) {
    ctx := context.WithValue(ctx, myCustomKey, "foo")
}
```

For, if use tracing, may want different subfunctions to share the same correlation ID. For this regard, could decide to include it as part of the provided context. Another, fore, implement an HTTP middleware -- fore, have configured two middlewares that must be executed before executing the handler itself. If want the middleware to communiate, have to go through the context handled in the `*http.Request`

```go
type key string
const isValidHostKey key = "isValidHost"
func checkValid(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        validHost := r.HOst == "acme"
        ctx := context.WithValue(r.Context(), isValidHostKey, validHost)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
```

#### Catching a context cancellation

The `context.Context`type exports a `Done()`method that returns a `<-chan struct{}`-- This channel is closed when the work associated with the contxt should be canceled --fore -- 

- The `Done`channel related to a contet created with `context.WithCancel()`is closed when the `cancel()`is called
- The `Done`related to a context created with `context.WithDeadline()`is losed when the deadline expired.

One thing to note that the internal channel should be closed when a context is canceled or has met a deadline. Instead of when it receives a specific value -- cuz the closure of a channel is the only cahnnel action that all the consumer goroutines will receive.

Furthermore, note that the `context.Context`exports an `Err()`returns `nil`if `Done`isn’t yet closed. Otherwise, will return a *non-nil* explaining why `Done`is closed.

- A `Context.Canceled`if canceled
- A `Context.DeadlineExceeded`if passed

```go
func handler(ctx context.Context, ch chan messasge) error {
    for{
        select {
        case msg := <ch:
            do sth with msg
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

## User Authentication

Now that the routes are set up -- need to create a new users database table and dbs model to access it.

```sql
CREATE TABLE users (
	id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL
)
ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE (email);
```

For the type `hased_password`is `CHAR(60)`-- cuz we will be storing hases of the user pwds in the dbs, not the passwords themsevles. Also added a `UNIQUE`constraint on the `email`column and named it `users_uc_email`.

### Building the model in the Go

Next setup a model so that can easily work with the new `users`table -- follow the same pattern that used earlier in the book for modeling access to the `snippets`table.

First, in the `errors.go`file define a coupe of new error types:

```go
var(
	ErrNoRecord = errors.New("models: no matching record found")

	// ErrInvalidCredentials Add a ne ErrInvalidCredentials error use this later if a user
	// tires to log in with an incorrect address or pwd
	ErrInvalidCredentials= errors.New("models: invalid credentials")

	// ErrDuplicateEmail add a new ErrDupliateEmail error
	ErrDuplicateEmail = errors.New("models: dupliate email")
)

// in the users.go
// User Define a new User type
// Noticed how the filed name and types align with the columns in the dbs
type User struct {
	ID             int
	Name, Email    string
	HashedPassword []byte
	Created        time.Time
}

// UserModel Define a new UserModel type which wraps the dbs connection pool
type UserModel struct {
	DB *sql.DB
}

// Insert use the `Insert` to add a new record
func (m *UserModel) Insert(name, email, password string) error {
	return nil
}

// Authenticate Use the `Authenticate` to verify whether a user exists with the provided email
// and pwd -- return the relevant User id
func (m *UserModel) Authenticate(email, password string) (int, error) {
	return 0, nil
}

// Exists method to check a user exists with ID
func (m *UserModel) Exists(id int) (bool, error) {
	return false, nil
}
```

And the final stage is to add a new field to the `application`so that can make this available to our handlers.

```go
type application struct {
    errorLog       *log.Logger
    infoLog        *log.Logger
    snippets       *models.SnippetModel
    users          *models.UserModel
    templateCache  map[string]*template.Template
    formDecoder    *form.Decoder
    sessionManager *scs.SessionManager
}

//... in the main:
app := &application{
    //...
    users: &models.UserModel{DB:db},
    // ...
}
```

### User signup and pwd encryption

First need a way for them to sign up for an account need:

```html
{{define "title"}}Signup{{end}}

{{define "main"}}
    <form action="/user/signup" method="post" novalidate>
        <div>
            <label>Name:</label>
            {{with .Form.FieldErrors.name}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="name" value="{{.Form.Name}}">
        </div>

        <div>
            <label>Email:</label>
            {{with .Form.FieldErrors.email}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="email" name="email" value="{{.Form.Email}}">
        </div>

        <div>
            <div>Password:</div>
            {{with .Form.FieldErrors.password}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="password" name="password">
        </div>

        <div>
            <input type="submit" value="Signup">
        </div>
    </form>
{{end}}
```

For the signup form we are just using exactly the same form structure that used eariler in the book. Then update the `handles.go`file to include a new `userSignupForm`struct that represent and hold the form data. Like:

```go
type userSignupForm struct {
	Name                string `form:"name"`
	Email               string `form:"email"`
	Password            string `form:"password"`
	validator.Validator `form:"-"`
}

// Update the handler so it displays signup page like
func (app *application) userSignup(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userSignupForm{}
	app.render(w, http.StatusOK, "signup.html", data)
}
```

#### Validating the user input

When this form is submitted the data will end up being posted to the `userSignupPost`handler that we made earlier -- The first task of thish handler will be to validate the data to make sure that is sane and sensible before we insert into the dbs -- specifically, want to do 4 things -- 

1. Create that theprovided name, email address and pwd are not blank
2. Sanity check the format of the email address
3. Ensure that the  pwd is at least 8 characters long
4. Make sure that the email isn’t already in use

Can cover first 3 by heading back to the `validator.go`file and creating two helper new methods -- `MinChars()`and `Matches()`along with the REGEXP for sanity checking an email address like:

```go
var EmailRX = regexp.MustCompile(
	"^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")

// MinChars returns true if a value contains at least n characters
func MinChars(value string, n int) bool {
	return utf8.RuneCountInString(value) >= n
}

// Matches returns true if a value matches the provided compiled regular expression
func Matches(value string, rtx *regexp.Regexp) bool {
	return rtx.MatchString(value)
}
```

Then head over to the `handlers.go`file and add some code to process the form and run the validation checks.