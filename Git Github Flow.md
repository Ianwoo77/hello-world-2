# Git Github Flow

On this page, will learn how to get the best out of working with Github -- the github workflow designed to wrok well with Git and GitHub. The github flow is workflow designed to work -- it focuses on branching and makes it possible for teams to experiment freely, and make deployments regularly. like:

- Create a new branch
- make chanes and add commits
- open a pull request
- Review
- deploy
- Merge

### Create a new Branch --

Branching is the key concept in git, and it works around the rule that the master branch is **Always** deployable. That means if you want to try sth new or experiment, create a new branch -- branching gives you an envirment where you can make changes without affecting the main branch. When your new is ready, it can be reviewed, discussed, and merged with the main when ready.

When make a new branch, you will want to make it from mastr branch - almost always

### Make changes and add commits

After the new branch is created, it is time to get work. Make changes by adding, editing and deleting files -- whenvever you reach a small milestone, add the changes to your branch by commit. Adding commits keeps track of your work. Each commit should have a message explaining what has changed and why. Each commit becomes a part of the history of the branch, and point you can revert back if you need to.

### Open a Pull request

Pull requests are a key part of Github, a pull requeste notifies people to have changes ready for them to consider or review, can ask others to review your changes or pull your contribuain and merge it.

Review -- When a pull is made, it can be reviewed by whoever has the proper access to the branch. This is where good and review of the changes happen.

Pull requests are designed to allow people to work together easily and produce better results together.

Deploy -- when the pull request has been reviewed and everything good, it is time for the final testing. GitHub allows to deploy from a branch for final testing in productiong before merging with the master.

### Merge

After testing, can merge the code into the master branch.

### Host your page on Github

With Github pages, github allows you to hose a webpage from your repository -- try to use github pages to host our repository -- 

Then add this new repository as a remote for your local repository, calling `gh-page`just like:

```sh
git remote add gh-page https://...
```

Then make sure you are on the master branch, then push master branch to the new remote.

```sh
git push gh-page master
```

## Reading data from MongoDB using Mongoose

To select all documents in collection, pass an empty document as the query fitler parameter to the first arg of the `find`method like:

```js
BlogPost.find().then(console.log).catch(console.error);
```

To just get a single database documents, retrieve single documents with unique _id like:

```js
BlogPost.findById('65b1b3562ca7f8816bccb70e')
    .then(console.log).catch(console.error);
```

Updating records -- To update a record, just using the `findByIdAndUpdate()`where we provide `id`as the firset arg and the field/values to be updated in the second arg like:

```js
const id = '65b1b3562ca7f8816bccb70e';
BlogPost.findByIdAndUpdate(id, {
    title:'Updated title'
}).then(console.log); // display the origin for this

BlogPost.find().then(console.log);
```

Deleting single record -- to delete a record, using the `findAyIdAndDelete()`where provide *id* as the first arg like:

```js
BlogPost.findByIdAndDelete(id).catch(console.error)
```

## Don’t use filename as a function input

When creating a new function that needs to read a file, passing a filename isn’t considered a best practice and can have negative effects, such as making unit test harder to write. Suppose want to implement a function to count the number of empty lines in a file -- one way to implement this function would be to accept a filename and use `bufio.NewScanner`to scan and check every line like:

```go
func countEmptyLinesInFile(filename string)(int, error) {
	file, err := os.Open(filename)
	if err != nil {
		return 0, err
	}
	scanner := bufio.NewScanner(file)
	for scanner.Scan(){
		//...
	}
	//...
}
```

For this, open a file from the filename, then use the `bufio.NewScanner`to scan every line -- this function will do what we expect it to do -- as long as the provided filename is valid, we will read from it and return the number of empty lines. For testing target -- Each unit test will require creating a file in our Go proj, the more complex function is, the more cases we may want to add, and the more files we create.

Furthermore, this function isn’t reusable, fore, if had to implement the same logic but count the number of empty lines with an HTTP request, we would have to duplicate the main logic -- 

```go
func countEmptyLinesInHTTPRequst(request http.Request)(int, err) {
    scanner := bufio.NewScanner(request.Body)
    //...
}
```

So, one way to overcome these limitations might be to make the function accept a `*bufio.Scanner`. Both functions have the same logic from moment create the `scanner`variable, so this approach would work. But in go, the idiomatic way to start form the reader’s abstraction.

Write a new version of the `countEmptyLines()`that receives an `io.Reader`abstrction instead -- like:

```go
func countEmptyLines(reader io.Reader) (int, error) {
    scanner:= bufio.NewScanner(reader)
    for scanner.Scan() {//...
    }
}
```

First, this approach abstracts the data source -- it’s not important for the function, cuz `*os.File`and the `Body`field of `http.Request`implement `io.Reader`-- can reuse the same function regardless of the input type. Another benefit is related to testing, now that `countEmptyLines`accepts an `io.Reader`can implement unit tests by creating an `io.Reader`from a string just like:

```go
func TestCountEmptyLines(t *testing.T) {
    emptyLine, err := countEmptyLines(strings.NewReader(...))
}
```

So, Accepting a filename as a function input to read from a file should -- in most cases, considered a code smell. makes unit tests more complex cuz we may have to create multiple files.

### How defer arguments and receivers are evaluated

We mentioned in a previous that the `defer`delays a call’s execution until the sorrounding function returns. And a common mistake mady by Go developers is not understanding how arguments are evaluated. Will delve into this problem with two subsection -- 

#### Argument evaluation

Mentioned in a previous section that the `defer`steaments delays a call’s execution until the surrounding function returns. A common mistake made by Go developers is not understanding how arguments are evaluated. Meanwhile, it has to handle a status regarding execution.

- `StatusSuccess`if both returns no errors
- `StatusErrorFoo`if returns an err in foo

Will use this for multiple actions, fore, to notify another goroutine and to increment counters -- like:

```go
const (
	StatusSuccess = "success"
	StatusErrFoo  = "error_foo"
	statusErrBar  = "error_bar"
)

func f() error {
	var status string
	defer notify(status)
	defer incrementCounter(status)

	if err := foo(); err != nil {
		status = StatusErrFoo
		return err
	}
	if err := bar(); err != nil {
		status = statusErrBar
		return err
	}

	status = StatusSuccess
	return nil
}
```

First declare a `status`, then defer the calls to defer call. However, if we give this function a try, see that regardless of the execution path, `notify`and `incrementCounter`are always called with the same status, an empty `string`. how is this possible -- need to understand something crucial about the argument evaluation in a defer function -- the arg are evaluated *right away* -- not once the surrounding function returns. Go just delay these calls to be executed once returns with the current value of `status`at the stege used `defer`. First solution like:

```go
func f() error {
    var status string
    defer notify(&status)
    // just passes a string pointer
    defer incrementCounter(&status)
}
```

but, this solution requires changing the signature of the two functions. which may not always possible.

Another solution is good -- just calling a closure as a `defer`statment -- as a reminder, a closure is an anonymous function value that references variables from outside its body. The arguments passed to a `defer`function are evaluated right away -- must know the variables referenced by a `defer`closure are evaluted during the closure execution. like:

```go
func main(){
    i:=0 j:=0
    defer func(i int) {
        fmt.Println(i, j)
    }(i)
    i++ j++
}
```

Here the closure uses `i`and `j`variable -- `i`is passed as a function argument, so it’s evaluated immediately. NOTE THAT-- Conversely-- `j`references a variable outside of the closure body, so it’s evaluated when the closure is executed, if we run this, print 0 1.

Can use a closure to implement a new version of our function like:

```go
func f() error{
    var status string
    defer func() {
        notify(status)
        incrementCounter(status)
    }
    //...
}
```

So, just wrap the calls to both `notify`and `incrementCounter`within a closure-- this closure references the `status`variable from outside its body. Therefore, `status`is evaluted once the closure is exectued.

#### Pointer and value receviers -- 

A receiver can be eigher a value or a pointer -- the same logic related to argument evalution applies when we use `defer`on a method -- the receiver is also evaluted immediately -- understand the impact with both receiver types.

```go
func main(){
    s := Struct{id: "foo"}
    defer s.print()
    s.id= "bar"
}
type Struct struct{
    id string
}
func (s Struct) print(){
    fmt.Prinln(s.id) // foo printed
}
```

For this, just defer the call to the `print`method -- as with arguments, calling `defer`just makes the receiver be evaluated immediately -- hence, `defer`delays the method’s execution with a struct that contains an `id`field equal to `foo` -- therefeore, this example prints `foo`.

```go
func main(){
    s := &Struct{id: "foo"}
    defer s.print()
    s.id="bar"
}
//...
func(s *Struct) print(){
    fmt.Println(s.id) // bar printed
}
```

This reciever also evaluted immediately -- however, calling the method leads to copying the pointer recevier.

## Error Management

Error managment is a fundamental aspect of building robust and observable applications -- and it should be as important as many other of codebase. In Go, error management doesn’t rely on the traditional `try/catch`mechanism as most programming languages do.

### Panicking

It’s just pretty common for newcomers to be somewhat confused about error handling -- In go, errors are usually managed by functions or methods that returns an `error`type as the last parameter. But some developers may find this approach surprising and tempted to reproduce exception handling in languages such as Java or Python using `panic`and `recover`. refresh our minds about the concept of panic and discuss when it’s considered appropriate to not to panic like:

```go
func main(){
    defer func(){
        if r := receover(); r!=nil {
            fmt.Println("recover", r)
        }
    }()
    f()
}
func f(){
    fmt.Println("a")
    panic("foo")
    fmt.Println("b")
}
```

Just print a, and recover foo -- Note that the calling to `recover()`to capture a goroutine panicking is only useful inside a `defer`function -- the function would return `nil`and have no other effect. This is just cuz `defer`functions are also executed when the surrounding function panics.

In Go, `panic`is used to signal genuinely exceptional conditions, such as a programmer error, fore, if look at the `net/http`package, notice that in the `WriterHeader()`, there is a call to a `checkWriteHeaderCode()`.

```go
func checkWriteHeaderCode(code int) {
    if code<100 || code >999 {
        panic(fmt.Sprintf("invalid WriteHeader code %v", code))
    }
}
```

### Ignoring when to wrap an error

Since Go 1.13, The `%w`directive allows us to wrap errors conventiently, but some developers may be confused about when to wrap an error -- remind ourselves what error wrapping is and then when to use it. Error wrapping is about wrapping or packing an error inside wrapper container that also makes the source error avaiable..

The first option is to return this error directly -- like:

```go
if err != nil {
    return err
}
// before 1.13, only option withtou using an external lib was to create a custom error type
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return "bar failed"+ b.Err.Error()
}
if err != nil {
    return BarError{Err: err}
}
```

The benefit of this option is flexibility, cuz `BarError`is a custom struct, we can add any additional context if needed.

```go
if err != nil {
    return fmt.Errorf("bar failed: %w", err)
}
```

The last option is to use the `%v`directive just like:

```go
if err != nil {
    return fmt.Errorf("bar failed: %v", err)
}
```

The difference is that the error itself isn’t wrapped, we transform it into another error to add context -- and the source error is no longer avaiable. The info about the source of the problem remains available. A caller can’t unwrap this error and check whether the source was bar error.

Wrapping an error just makes the source error available for callers, hence, it means introducing potential coupling.

## Restricting Access

As it stands, we are hiding the `create snippet`nav link for any user that isn’t logged -- but an unauthenticated user could still create a new snippet by visiting the http://localhost:4000/snippet/create directly.

Fix this by if an authenticated user tries to visit any routes with the URL path they are redirect to /user/login instead. The simplest way to do this is via some middleware, open the `cmd/web/middleware.go`file and create a new `requireAuthentication()`middleware function, following the same pattern used like:

```go
func (app *application) requireAuthentication(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// if the user is not authenticated, redirect them to the login page and
		// return from the middleware chain so that no subsequent handlers in
		// the chain are executed
		if !app.isAuthenticated(r) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
			return
		}

		// otherwise just set the `Cache-Control: no-store` header to that pages
		// require authentication are not stored in the user browsers cache
		w.Header().Add("Cache-Control", "no-store")

		// add call the next handler in the chain
		next.ServeHTTP(w, r)
	})
}
```

Can now add this middleware to our `cmd/web/routes.go`file to prorect specific routes like: -- and there is not much point logging out a user if they are not logged in, so it makes sense to use it on the `POST /user/logout`routes as well. If are using `justinas/alice`package to mange your middleware chains, you can add the new `requireAuthentication()`middleware to the `dynamicMiddleware`chain on per-route basis byu using the `Append()`method like so:

```go
// Add the requireAuthentication middleware to the chain
mux.Get("/snippet/create", dynamicMiddleware.Append(
    app.requireAuthentication).ThenFunc(app.createSnippetForm))

mux.Post("/snippet/create", dynamicMiddleware.Append(
    app.requireAuthentication).ThenFunc(app.createSnippet))
```

Without using Alice -- If are not using the `jusinas/alice`packge to manage your middleware -- that is ok -- you can manually wrap your handlers like tihs:

`mux.Get("snippet/create", app.session.Enable(app.requireAuthentication(http.HandlerFunc(app.createSnippetForm))))`

CSRF Protection -- In this just look at how to protect our application from `Cross-site`request forgery attacks. It’s just a form of cross-domain attack where a malicious 3rd-party website sends state-changing HTTP requests to your website. A great explanatio of the basic CSRF attack can be :

Risk is this -- 

- A user logs into our app, our session cookie is set to persist for 12 hours, so they will remain logged in if they navigate away
- The user then goes to a malicious website contains some script that sends request to `POST /snippets/create`to add a new snippet to our dbs.
- Since the user is till logged into our app, the request is processed with their privileges.

### SameSite cookies -- 

One mitigation that can take to prevent CSRF attacks is to make sure that the `SameSite`attribute is set on our session cookie - by default the golangcollege/sessions package using always set `SameSite=Lax`on the session cookie -- means that the session cookie *won’t* be sent by the user’s browser for cross-site usage. Thereby cutting down the risk of a CSRF attack.

```go
// then use the sessions.New() to initialize a new session manager.
session := sessions.New([]byte(*secret))
session.Lifetime = 12 * time.Hour
session.Secure = true
session.SameSite = http.SameSiteStrictMode
```

### Token-based Mitigation -- 

To mitigate the risk of CSRF for all uses we will also need to implement some form of token check -- Like session management and pwd hashing, whent it comes to this there is a lot that you can get wront.  The two most popular packages for stopping CSRF attacks in go apps are `gorilla/csrf`and `justinas/nosurf` They both do roughly smae thing -- using the `Double submit cookie pattern`to prevent attacks.

For this use case, just use `justinas/nosurf`in this.

```sh
go get github.com/justinas/nosurf
```

Using this package -- like:

```go
// create a NoSurf middleware function which uses a customized CSRF cookie with
// the secure, path and HttpOnly flags set
func noSurf(next http.Handler) http.Handler {
	csrfHandler := nosurf.New(next)
	csrfHandler.SetBaseCookie(http.Cookie{
		HttpOnly: true,
		Path:     "/",
		Secure:   true,
	})
	return csrfHandler
}
```

One of the forms that we need to protect from CSRF attacks is our logout form, which is included in our `base.layout.html`file and could potentially appear on any page of our app. So, cuz of this, need to use our `noSurf()`middleware on all our app routes. Just like:

```go
dynamicMiddleware := alice.New(app.session.Enable, noSurf) 
```

At this point, migth like to fireup the app and try submitting one of the forms. At this point, might like to fire up the app and try submitting one of the forms, when you do, request should intercepted by the `noSurf()`middleware. need to use the `nosurf.Token()`function to get the CSRF token and add it to a hidden `csrf_token`field in each of our forms.

```go
type templateData struct {
	// ...
	CSRFToken       string
}
```

## Using Request Context

At the moment our logic for authenticating user consists of simply checking whether a `authenticatedUserId`value exists in their sessio data like:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	return app.session.Exists(r, "authenticationUserId")
}
```

Could make this more robust by checking our `users`dbs table to make sure that the `authenticateionUserId` vlaue is just valid. And that the user account it relates to is still active. Our `isAuthenticated()`helper method can be called multiple times in each request cycle -- currently we use it twice -- once for `requireAuthentication()`and again in the `addDefaultData()`helper. So if check the dbs from the `iaAuthenticated()`helper directly, would end up making duplicated round-trips to the dbs during every request.

A better approach would be to carray out this check in some middleware to determine whether the current request is from an *authenticated-and-active* user or not. And then pass this info down to all subsequent handlers in the chain.