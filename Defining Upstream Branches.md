# Defining Upstream Branches

When push work from a local branch to a remote, Git needs a way to know which remote branch you want to push the work to -- If no upstream branch is defined for the local branch -- need to specify which remote branch to push to when you enter the `git push`command. If a local branch has an upstream branch defined for it, can use `git push`with no aruments and Git will automatically push the work to that branch. Learned that upstream branches are automatically set up when U clone a repository -- but *not* when a repository is initialized locally.

To set up the upstream branch will use the `git branch`command with `-u`option -- which is short for `--set-upstream-to`.

```sh
git branch -vv
git branch -u origin/main
git branch -vv
```

In the step 3-- `-vv`outputs shows the `main`branch from the remote repository with shortname `origin`has been set as the upstream branch for the local main.

To end up in a situation where you will have to carry out a 3-way merge -- there must be divergent histories between two branches. Friend will continue working on locl `main`in their *local* repository *without* fetching the changes U pushed to the remote `main`, which will cause the local `main`in the `friend-rainbow`repositoyr and the `main`branch in the `rainbow-remote`to diverge.

### Editing the same File multiple times between commits

It’s important to understand if U add a file to the staging area and then make another *change* to the file, Git will interpret that as a new version of the file to be included in your next commit, you will have to add the updated version of the file to the staging area *again*.

Fore, under friend directory, `git status`-- working tree clean -- which indicates that the state of the working directoy and staging area are the same. There are no modified files in the working directory and there are no newly files in the staging area. Edit the readme.md file then --

- The version of the file in the staging are is not changed
- working directory file has changed, it mentioned the colors..

```sh
git add readme.md
git status
```

`git status`output indicates that there is now one modified file in the working directory that is also staged for commit.

- The version of the `readme.md`file in the staging area has changed from vA to vB.
- The version of the `readme`in the staging is same as the one in the working directory.

Friend has added the updated verion of the file to the staging area -- and it is ready to be committed. `git status`-- one version of the file is listed as a modified file that is staged for commit and another verion file is listed as modified has not staged for commit.

- The version of the file in the staging is vB, version of file typo
- The version of the file in the working has changed from vB to vC.

From these observations, can see that just cuz a file with a particular name is staged for commit doesn’t mean it is automatically updated with any other change you make to it. U just need to explicitly *add each updated* version of a file to the staging area to include the latest changes in your next commit.

```sh
git add readme.md
git status
```

The version of the readme.md file in the staging area has changed form vB to vC, indicating that the latest version of the readme has been added to the staging area.

Since their local main branch is out of sync with the *remote main* -- will come acorss an error.

### Working at the same time as other on Different Files

Need to note that the local `main`in the friend repository is out of sync with the remote `main`branch. friend is ready to make their blue commit and to try to share their work -- try to push their work to the remote repository will get an error.

```sh
git commit -m "blue"
git push # rejected error -- failed to push some refs to origin.
```

For this the output of the `git push`shows that your friend gets an error. The development histories of the local `main`and the remote `main`branch have diverged -- and git is not able to merge changes from one into the other with a simple *fast-forward* merge.

- In the friend-rainbow, the local `main`points to the `blue`commit
- in the remote the `main`now points to the `brown`commit

For the error output -- Thi is usually caused by another repository pushing to the same `ref`. Git is just telling U that there are commits on the remote `main`that they have not yet *fetched* or *pulled*. And it advises your friend that they have to featch or pull the remote work and integrate it into their local `main`before they can push to the remote.

## Side effects with named result parameters

For the named result parameters -- As these result parameters are initialized to their 0 value, using them can sometimes lead to subtle bugs -- fore:

```go
func (l loc) getCoordinates(ctx context.Context, address string) (lat, lng float32, err error) {
	isValid:= l.validateAddress(address)
	if !isValid {
		return 0, 0, errors.New("invalid address")
	}
	if ctx.Err() != nil { // checks whether the context was canceled or deadline has passed
		return 0, 0, err
	}
	//... other code
}
```

The error returned in the `if ctx.Err()!=nil`-- we havn’t assigned any value to the `err`variable. It’s still assigned to the 0 valu of an `error`type -- `nil`-- hence, this code will always return a `nil`error. Furthermore, this code compile cuz `err`was initialized to its zero. One possible fix to assign `ctx.Err()`to `err`. 

```go
if err := ctx.Err(); err!= nil {// err in this shadows the result variables
    return 0, 0, err
}

// another option:
if err = ctx.Err(); err != nil {
    return
}
```

### Don’t return a `nil`receiver

Discuss the impact of returning an interface and why doing so may lead to errors -- this mistake is probably one of the most widespread in Go -- fore:

```go
type MultiError struct {
    errs []string
}

func (m *MultiError) Add(err error) {
    m.errs = append(m.errs, err.Error())
}
func (m *MultiError) Error() string {
    return stings.Join(m.errs, ";")
}
```

Fore, using this structure, can implement a `Customer.Validate()`method in the following -- check the customer.

```go
func (c Customer) Valiate() error {
    var m *MultiError
    if c.Age < 0 {
        m = &MultiError{}
        m.Add(errs.New("..."))
    }
    if c.Name=="" {
        if m== nil {
            m = &MultiError{}
        }
        m.Add(errors.New("..."))
    }
    return m
}
```

In this IMP, `m`is just initialized to the zero value of the `*MultiError`-- `nil`when a sanity check fails, we allocate a new `MultiError`if needed and then append an error.

Just note that the **`nil`pointer** is a valida receiver -- In Go, a method is jsut syntactic sugar for a function -- whose first paramter is just the receiver so fore:

```go
type Foo struct{}
func(foo *Foo) Bar() string {
    return "bar"
}
func main(){
    var foo *Foo
    fmt.Println(foo.Bar()) // ==> func Bar(foo *Foo) string {return "bar"}
}
```

We just know that passing a `nil`pointer to a function is just valid -- therefore, using a `nil`pointer as a receiver is also valid. For the example -- `var m *MultiError`-- `m`is just initialized to the zero value of a pointer `nil` -- Then if all the checks are valid the argument provided to the `return`isn’t a `nil`directly, but a `nil`pointer.

In Go, understanding `nil`pointers and `nil`values is crucial -- as they are a fundamental aspect of the language’s type stystem -- here is a breakdown of how `nil`can be used in Go --  `nil`poitners -- means that it does not refer to any memory location. Cuz a `nil`pointer is just a valid recevier -- *converting the result into an interface won’t yield a `nil`value*.

#### Understanding interface values

In Go, an interface value is representd internally by a tuple `(type, value)`-- the `type`part of the tuple describes the type of the value the interface holds.

- If both `type`and `value`are `nil`-- then int interface is considered `nil`.
- If `type`is not `nil`-- then the interface valud is considered **non `nil`**, even if the `value`part is `nil`.

So when u convert a `nil`pointer of a specific type to an interace, the interface will have its type part set to `*T`and its value is set to `nil`. In Go, an interface is a dipatch wrapper -- there the wrappee is `nil`whereas the wrapper isn’t. Therefore, regardless of `Customer`provided, the caller of this func will always receive a non-nil error -- Cuz `error`is an *interface*. So, if there is no error occur, just `return nil`.

### Don’t use filename as a function input

When creating a new func that needs to read a file, passing a filename isn’t considered a best practice and can have nagative effects, such as making unit tests harder.. Imp this func like:

```go
func countEmptylinesInFile(filename string)(int, error) {
    file, err := os.Open(filename)
    if err != nil {
        return 0, err
    }
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        //...
    }
}
```

For this, just open a file from name -- then use the `bufio.NewScanner()`to scan every line. but, want to implement unit tests to cover the following cases -- 

- A nominal case
- an empty file
- or a file containing only empty lines

For these, each test will requrie creating a file in Go proj -- The more complex the function is, the more cases may want to add, and more files will create. Furthermore, this function isn’t reusable. Fore, if had to imp the same logic but count the number of empty lines with an HTTP request, would have to duplicate the same logic. One way to overcome these limitations might be to make the function accept a `*bufio.Sanner`. But in Go, the idiomatic way is to start the reader’s abstraction -- like:

```go
func countEmptyLines(reader io.Reader)(int, error) {
    scanner := bufio.Scanner(reader)
    for scanner.Scan() {
        //...
    }
}
```

Cuz `bufio.NewScanner`accepts an `io.Reader`, can directly pass the `reader`variable. First, this func abstracts the data soruce -- And another benefit is related to testing -- Mentioned that creating one file per test case could quickly beome cumbersome -- now that `countEmptyLines`accepts an `io.Reader`then can imp unit tests by creating an `io.Reader`from a string. Like:

```go 
func TestCountEmptyLines(t *testing.T) {
    emptyLins, err := countEmptyLines(strings.NewReader(
    	`foo
    		bar
    		
    		baz`
    ))
}
```

Create an `io.Reader`using the `strings.NewReader()`from a string literal directly. Therefore, we don’t have to create one file per test case -- each test case can be self-contained, improving the test readabilyt and maintainabilty. And accepting a filename as a function input to read from a file should -- in most case, be considered a code smell. It just makes the unit tests more complex cuz we may have to create multiple files.

## Automatic form parsing

Another thing can do to simplify the handlers is use a 3rd-party package like:

```sh
go get github.com/go-playgournd/form/v4
```

To get this working the first thing that we need to do it initialize a new `*form.Decoder`instance in our `main.go`. Like:

```go
// make it available to our handlers as dependency
// Add a formDecoder field to hold a poitner to `form.Decoder` instance
type application struct {
    //...
    formDecoder *from.Decoder
}

func main(){
    //...
    // Initialize a decoder instance
    formDecoder := form.NewDecoder()
    app := &application{
        //...
        formDecoder: formDecoder,
    }
}
```

Then go to the `handler.go`file update it to use the new decoder just like:

```go
type snippetCreateForm struct {
    Title   string `form:"title"`
    Content string `form:"content"`
    Expires int `form:"expires"`
    validator.Validtor `form:"-"`
}
```

The struct tag for the `form:"-"`tells the decoder to completely ignore a field during docoding.

```go
form.CheckField(validator.NotBlank(form.Title)...)
```

```go
var form snippetCreateForm
err = app.formDecoder.Decode(&form, r.PostForm)
```

#### Creating a `decodePostForm`helper 

To assist this, create a new `decodePostForm()`helper which does 3 things -- 

- Call `r.ParseForm()`on the current requst
- Call `app.formDecoder.Decode()`to unpack the HTML form data to target.
- Checks for a `form.InvalidDecodeError`error and triggers an panic if ever see it.

```go
// Create a new decodePostForm()
func(app *application) decodePostForm(r *http.Request, dst any) error {
	err := r.ParseForm()
	if err != nil {
		return err
	}
	err = app.formDecoder.Decode(dst, r.PostForm)
	if err != nil {
		// if try to use an invalid target the Decode() will return an error
		// use the errors.As() to check for this and raise a panic
		var invalidDecoderError *form.InvalidDecoderError
		if errors.As(err, &invalidDecoderError) {
			panic(err)
		}
		// for all other errors
		return err
	}
	return nil
}
```

As with that done, can make the final simplicification to our `createSnippetPost()`handler like:

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	var form snippetCreateForm
	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}
    //...
}
```

### Stateful HTTP

A nice touch to improve our user experience would be to display a one-time confirmation message which the user sees after they have added a new snippet like: A confirmation message like this should only show up for user once and no other users should ever see the message. U might know this type of functionality as a *flash* message or a *toast*. To make this work, need to start sharing data between HTTP requests for the same user. -- 

- What *session managers* are available to help us implement sessions in Go.
- How to use sessions to safely and securely share data between requests for a particular user
- How U can customize session behavior based on your app’s needs.

### Choosing a session manager

Here are a lot of security considerations when it comes to working with sessions, and a proper imp is not trivial. Using either the `gorilla/sessions`or `alexedwards/scs`-- depending on your project’s needs.

- `gorilla/sessions`is jsut the most established and well-known session management package for Go, has a simple and easy-to-use API. It doesn’t privde a meshanism to renew session IDs.
- `alexedwards/scs`-- store session data server-side only -- suports automatic loading and saving of session data via middleware, has a nice interface for type-safe manipulation of data.

For the reasons using the `MySQL`dbs set up -- opt to use the `alexedwards/scs`and store the session data server-side in MySQL.

```sh
go get github.com/alexedwards/scs/v2
go get github.com/alexedwards/scs/mysqlstore
```

### Setting up the session manager -- 

Run through the process of settingup and using `alexedwards/scs`package -- if you are going to use it in a production app. The first thing we need to do is create a `sessions`table in the MySQL dbs to hold the session data for our users.

```sql
use snippetbox;

CREATE TABLE sessions
(
    token  CHAR(43) PRIMARY KEY,
    data   BLOB         NOT NULL,
    expiry TIMESTAMP(6) NOT NULL
);

CREATE index sessions_expiry_idx ON sessions (expiry);
```

The token will contain a unique *random-generated* identifier for each session. And the `data`will contain a actual session data that you want to share between HTTP requests -- as *binary data* in a `BLOB`(binary large object) type.

The `expiry`-- will contain an expiry time for session - the `scs`package will automatically delete expired sessions from the sessions table so that it doesn’t gorw too large. 

Then need to do is establish *session manager* in our `main.go`file and make it available to our handlers via the `application`struct. The session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving of session data.

```go
type application struct {
    //...
    sessionManager *scs.SessionManager
}
//...
// use the scs.New() to initialize a new session manager.
// configure it to use our dbs as the session store
sessionManager := scs.New()
sessionManager.Store=mysqlstore.New(db)
sessionManager.Lifetime= 12*time.Hour

app := &application{
    //...
    sessionManager: sessionManager,
}
```

