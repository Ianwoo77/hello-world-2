# Executing the 3-way merge

1. First, you fetch the changes from the remote repository
2. Second, integrate the changes into the local branch in the local repository

Friend is going to follow the same steps right now, except 2 -- they will end up carrying out a 3-way merge instead of fast-forward merge cuz the development histories of the two branches involved the merge have diverged. When performing a 3-way merge, git will create a mrege commit, -- it will enter a text editor in the command line.

```sh
git fetch
git merge origin/main
```

Now going to fetch the changes from the remote branch into their local repository, this will update the `origin/main`branch -- then they will merge `origin/main`remote-tracking branch into their local `main`. The command line will enter some editor after the `git merge`command is executed -- the default commit message the Git drafts for you will either be .

In `git merge`step - says merge made by `ort`strategy -- indicates that this was a three-way merge insted of a fast-forward merge. For now, in the `friend-rainbow`repository, will illustarate the merge commit as M1. So for the M1 has two parent commits. Can use the `git cat-file -p <hash>`to view the parent commits of a commit.

After that, your friend will push their changes to the remote repository to make sure it’s updated.

```sh
git push
```

### Pulling changes from a remote repository

When wanted to update your local repository with changes from the remote repository you did in two steps, first fetched from the remote repository, and then U merged the data into the local branch - pullsing data allows U to do both in one go. -- use the term `pull`or `pulling`to refer to the process of fetching data from a remote repository *and* integrating it into a branch in a local repository on one go, and the command use to do it is `git pull`. If don’t have upstream branch defined for your local branch, mush specify the shortname of remote repository and the name of the branch. fore:

```sh
git pull <short_name> <branch_name>
git pull # if an upstream branch is defined for the current branch
```

There is some more things for `git pull`-- Git there are two ways to integrate changes -- *merging and rebasing*. Which method the `git pull`command uses will depend on whether the development histories of the branches have diverged and if so, on the option you choose when entering the command.

1. if just of the local and remote in a `git pull`have *not* diverged, by default a fast-forward merge will occur
2. If have **diverged** -- then must tell Git whether u want to integrate changes by merging or rebasing. (otherwise, get an error) -- to tell git integrte the changes by merging, 

Merging -- Is the process of changes from one branch into another while *preserving the history of both branches*. when Merge, Git generates a new *merge commit* in the target branch that ites together the histories of both branches.This has at lest two parents -- one pointing to the trip of the target and other tip of the branch being merged.

Rebasing -- is process of moving or *replaying* a series of commits from one branch onto the tip of another. During a rebase, Git takes the commits from one and applied them on by one to the tip of another.

```sh
git switch feature-branch
git rebase main
```

namely, **git fetch + (git merge or git rebase)= git pull**, and to tell Git to integrate the changes by merging, must pas in the `--no-reabase`option, if by rebasing, you must pass the `--rebase`option.

```sh
git pull
git log
```

State of the local and remote repository -- shows the state of the local and remote repositories in the Rainbow proj with all the commits that were made from 1.

## Checking an errror accurately

Using the `%w`directive also change our way of checking for a specific error type -- otherwise, may handle errors inaccurately. Fore, write an HTTP handler to return the transaction amount from an ID -- our handler will parse the request to get the ID and retreive a amount from db.

```go
type transientError struct {
	err error
}

func (t transientError) Error() string {
	return fmt.Sprintf("transient error: %v", t.err)
}

func getTransactionAmount(transactionId string) (float32, error) {
	if len(transactionId) != 5 {
		return 0, fmt.Errorf("id is not invalid %s", transactionId)
	}
	amount, err := getTransactionAmountFromDB(transactionId)
	if err != nil {
		return 0, transientError{err: err}
	}
	return amount, nil
}
```

for this `getTransactionAmount()`returns an error using `fmt.Errorf`if the identifiers is invalid- however, if getting the transaction amount from the DB fails, `getTransactionAmount()`wraps the error into the `transientError`type.

```go
func handler(w http.ResponseWriter, r *http.Request) {
	transactionId := r.URL.Query().Get("transactionId")
	amount, err := getTransactionAmount(transactionId)
	if err != nil {
		switch err := err.(type) {
		case transientError:
			http.Error(w, err.Error(), http.StatusServiceUnavailable)
		default:
			http.Error(w, err.Error(), http.StatusBadRequest)
		}
		return
	}
	fmt.Fprintf(w, "Transaction amount: %f", amount)
}
```

Using a `switch`on the error type, return the appropriate status code. Assume that we want to just perform a small refactoring of `getTransactionAmount()`-- the `transientError`will be returned by `getTransactionAmountFromDB`instead like:

```go
amount, err := getTransactionAmountFromDB(transactionId)
if err != nil {
    return 0, fmt.Errorf("failed to get transaction amount from db: %s: %w",
                         transactionId, err)
}
```

If re-run the code, it will always returns a 400 regardless of the error case, so the `case`error will never be hit. What `getTransactionAmount()`returns isn’t a `transientError`directly -- it’s an error wrapping `tansientError`. therefore `case transientError`is now false. So:

```go
amount, err := getTransactionAmount(transactionID)
if err != nil {
    if errors.As(err, &transientError{}) {
        http.Error(w, err.Error(), http.StatusServiceUnavailble)
    }else {...}
}
```

For this, just got rid of the switch case type in this new version, and we use `errors.As`-- this func requries the second argument to be a pointer. Otherwise, the func will compile but *panic*.

### Checking an error value accurately

A sentinel error is an error defined as a global variable -- 

```go
import "errors"
var ErrFoo = errors.New("foo")
```

In general, the convention to start with `Err`followed the error type -- fore: `ErrFoo`, A Sentinel error conveys *expected* error -- but what do we mean by an expected error -- 

Want to design a `Query`method that allows us to execute a query to a dbs. This method returns a slices of rows. How should we handle the case when no rows are found -- have two options -- 

- Return a sentinel value -- a nil slice
- Return a specific error that a client can check.

For the second approach -- can return a specific error if no rows are found -- Can classify this as an *expected* error -- cuz passing a request that returns no row is allowed. Conversely, situations like network issues and connection pooling errors are *unexpected* errors -- it doesn’t mean we don’t want to handle unexpected errors. It just means that semantially, those erros convey a different meaning -- In the Stdlib, can find many examples 

- `sql.ErrNoRows`-- returne when a query doesn’t return any rows
- `io.EOF`-- returned an `io.Reader`when no more input is avaialble

For this, that’s the general principle behind the senientel errors -- they convey an expected error that clients will expect to check -- as general guidelines -- 

- Expected errors should be designed as error values `var ErrFoo= errors.New("foo")`
- Unexpected errors should be designed as error types -- `typeBarError`fore.

```go
err := query()
if err != nil {
    if err == sql.ErrNoRows {
        // ...
    }else {
        // ...
    }
}
```

However, a sentinel error can also be wrapped -- and if an `sql.ErrNoRows`is wrapped using `fmt.Errorf`using the `%w`directive,  == will be false. Can use its counterpart `errors.Is()`.

```go
err := query()
if err != nil {
    if errors.Is(err, sql.ErrNoRows)
    //...
}
```

Using the `errors.Is()`instead of the == operator allows the comparison to work even if the error is wrapped using `%w`. In summary, if use error wrapping in app with the `%w`directive and `fmt.Errorf`checking an error against a specific value should be done using `errors.Is()`instead of ==. Note that `errors.Is()`can recursively unwrap the error.

### Handling an error twice -- don’t

Handling an error multiple times is a mistake made frequently by developers, not specially in Go -- Write a `GetRoute`to get the route from a pair of sources to a pair of target coordinates -- assme this func will call an unexported `getRoute`func that contains the business logic to calculate the best rout fore:

```go
func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
	err := validateCoordinates(srcLat, srcLng)
	if err != nil {
		log.Println("failed to validate coordinates")
		return Route{}, nil
	}
	return getRoute(srcLat, srcLng, dstLat, dstLng)
}

func validateCoordinates(lat, lng float32) error {
	if lat < -90 || lat > 90 {
		log.Printf("invalid latitude: %f", lat)
		return fmt.Errorf("latitude is out of range: %f", lat)
	}
	if lng < -180 || lng > 180 {
		log.Printf("invalid longitude: %f", lng)
		return fmt.Errorf("longitude is out of range: %f", lng)
	}
	return nil
}
```

As a rule of thumb, an error should be handled only once -- *Logging an error is handling an error*, and so it returning an error, hence, just like: Get rid of the `log.Printf()`lines.

```go
func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
	err := validateCoordinates(srcLat, srcLng)
	if err != nil {
		return Route{},
			fmt.Errorf("failed to validate coordinates: %w", err)
	}
    //...
```

Each error returned by the `validateCoordinate`is now wrapped to provide additional context for the error.

### Should handling an error

In some cases, may want to ignore an error returned by a function -- there should be only one way to do this in Go. In this example, just call `notify()`without assigning its output to a classic `err`- there is nothing wrong with this code from a functional standpoint, it compiles and runs as expected.

From a maintainbility perspectice, the code can lead to some issues -- This reader notices that `notify`returns an error but that the error isn’t handled by the parent function. For this reason, when want to ignore an error in Go, only one way to write it -- `_= notify()`-- Instead of not assigning the error to a variable, we assign it to the blank identifier.  And a comment can also accompany such code, but not a comment like the following -- 

```go
// At-most once delivery
// Hence, it's accepted to miss some of them in case of errors
_ = notify()
```

## Self-signed TLS certification

HTTPs is essentially HTTP sent across a TLS connection, cuz it’s sent over a TLS connection the data is encrypted and signed, which helps ensure its privacy and integrity during transit.

For production servers, recommend using *Let’s Encrypt* to create your TLS certificates. but for development purposes the simplest thing to do is to generate your own self-signed certificate -- Except it isn’t cryptographically signed by a trusted certificate authority.

`crypto/tls`package in Go’s stdlib includes a `generate_cert.go`tool -- just like:

```sh
go run ~/sdk/go1.20.3/src/crypto/tls/generate_cert.go -rsa-bits=2048 --host=localhost
```

Behind the scenes, the `generate_cert.go`tool works in two stages -- 

1. First, generates a 2048-bit RSA key pair, which is a cryptographically secure public key and private key
2. It then stores the Private Key in the `key.pem`and genrates a self-signed TLS certifiate for the host localhost contaiing the public key. which is `cert.pem`file.

### Running a HTTPs Server

Now that have a self-signed TLS certificate and corresponding private key -- starting a HTPs web server is simple like:
`err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")`

#### Additional information -- HTTP requests

It’s important to note that our HTTPs server only supports HTTPs. Http/2 -- A big plus of using HTTPs is that, if a client supports HTTP/2 connections, go’s HTTPs server will automatically upgrade the connection to use HTTP/2.

Certificate permissions -- It’s important to note that the user that you are using to run your Go app must have read permissions for both the `cert.pem`and `key.pem`files, otherwise, `ListenAndServeTLS()`will return an permission denied error. By default, the `generate_cert.go`tool grants read permissions to *all* users for `cert.pem`file but read permission only to the *owner* of the `key.pem`file.

### Configuring HTTPs Settings

Go has good default settings for its HTTPs server, but it’s possible to optimize and customize how the server behaves. Go supports a few elliptic curves. To make this tweak, can create a `tls.Config`struct like:

```go
// Initialize a tls.Config to hold the non-default TLS settings we want the server to use.
// only thing we are changing is the curve preferences value
tlsConfig := &tls.Config{
    CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
}

srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  app.routes(),
    TLSConfig: tlsConfig,
}
```

### Connection timeouts

Then to improve the resilincy of our server by adding some timeout settings like:

```go
srv := &http.Server{
    Addr:      *addr,
    ErrorLog:  errorLog,
    Handler:   app.routes(),
    TLSConfig: tlsConfig,

    // add Idle, Read and write timeouts to the server
    // Keep-alive connections will be automatically closed after 1 minute
    IdleTimeout:  time.Minute,
    
    // if the request headers or body are still being read 5 second after the request is first accepted
    // then go will close the underlying connection, helps to mitgate the risk from slow-client attackes
    ReadTimeout:  5 * time.Second,
    
    // close the underlying connection if our server attempts to write to the connectoin after a given period
    WriteTimeout: 10 * time.Second,
}
```

All three of these timeouts -- are server-side settings which act on the underlying conenction and apply to all requests irrespective of their handler of URL.

### User Authentication

In this section of the book we’re going to add some user authentication functionality to our app, so that only registered, logged-in users can create new snippets, Non-logged-in users will still be able to view, but will also be able to sign up for an account.

1. A user will register by visiting a form at `/user/signup`..
2. Log in by visiting the `/user/login`
3. Check the dbs to see if the email and pwd they entered match one of the users in the `users`table, If there is a match, then the user has *authenticated* successfully and we add the releveant `id`for the user to their session data. Using the key `authenticatedUserID`
4. When receive the subsequent requsts, can check the user’s session data for a `authenticatedUserID`value -- if exists know that the user has already successfully logged in -- can keep checking this until the session expires. We can keep checking this until the session expires -- when the user will need to log in again, if there is no `authentiatedUserID`in the session, know that the user is not logged in.

In many ways, a lot of content in this section is just putting together the things that we’ve already learned in a different way -- so it’s a good litmus test of U understanding and a reminder of some key concepts.

- How to implement basic `signup, login, logout`for users
- A secure approach to encrypting and storing user pwd securely in dbs using `Bcrypt`in Go.
- A solid and straightforward approach to verifying that a user is logged in using middleware and sessions.
- How to prevent cross-site request forgery (CSRF) attacks.

Routes setup -- 

- `GET /user/signup`-- `userSignup`-- Display a HTML form for signing up a new user
- `POST /user/signup` -- `userSignupPost`-- create a new user
- `GET /user/login`-- `userLogin`-- Display a html form for logging in a user
- `POST /user/login`-- `userLoginPost`-- Authenticate and login
- `POST /user/logout`-- `userLogoutPost`-- logout the user

```go
func(app *application) userSignup(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Display a HTML for signing up a new user...")
}

func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Create a new user account...")
}

func (app *application) userLogin(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Display a HTML for logging in a user...")
}

func (app *application) userLoginPost(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Log in a user...")
}

func (app *application) userLogoutPost(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "Log out a user...")
}
```

Then create the corresponding routes in the `routes.go`file like:

```go
// Add the five new routes for user signup, login, logout and so on...
router.Handler(http.MethodGet, "/user/signup", dynamic.ThenFunc(app.userSignup))
router.Handler(http.MethodPost, "/user/signup", dynamic.ThenFunc(app.userSignupPost))
router.Handler(http.MethodGet, "/user/login", dynamic.ThenFunc(app.userLogin))
router.Handler(http.MethodPost, "/user/login", dynamic.ThenFunc(app.userLoginPost))
router.Handler(http.MethodPost, "/user/logout", dynamic.ThenFunc(app.userLogoutPost))
```

Then need to update the `nav.html`to include navigation items for the new pages -- like:

```html
{{define "nav"}}
    <nav>
        <div>
            <a href='/'>Home</a>
            <a href="/snippet/create">Create snippet</a>
        </div>
        <div>
            <a href="/user/signup">Signup</a>
            <a href="/user/login">Login</a>
            <form action="/user/logout" method="POST">
                <button>Logout</button>
            </form>
        </div>
    </nav>
{{end}}
```

