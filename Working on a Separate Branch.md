# Merging

At the start, should have 3 commits and two branches in your repository. Branches are a powerful feature of Git, it’s great that they allow us to work on different parts of a project independently. Merging git is one way you can integrate the chenges made in one branch into another branch. fore, there is one branch that you are merging, called the *source* branch. Merging into, called *target branch*. 

The source is the branch that *contains the changes* that will be integrated into the target branch. The target branch is the branch that receives the changes and is therefore the only one that is altered in this operation.

### Types of Merges

- Fast-forward merges
- 3-way merges

The development history of a branch begins with the commit it points to, and extends backward through the *chain* of commits. Can see that the development history of the `main`is therefore made up of the `orange`commit and the `red`commit.

A fast-forward merge is a type of merge that occurs when the development histories of the branches involved in the merge have not diverged. If we can reach one branch through the *commit history* of another branch, Can say that the development histories of the branches *have not diverged*.

#### 3-way merges

However, add some work to the `main`branch, it now points to some new commits. If Merge branch into the `main` -- it can’t be a fast-forward merge cuz there is no way to just move the branch pointer forward combine these two histories, Instead, a merge commit will be created to tie the two histories together. The reason that this kind of merge is called a 3-way merge is cuz in order to carry out the merge, git will take a look at the two commits that the branches involved in the merge are pointing to.

And 3-way merges a more complex type of merge where U may experience *merge conflicts*.

#### Doing a Fast-forward merge

Just merge the `feature`branch into the `main`branch, the `feature`is the source, and the `main`is the target. There are two steps involved in doing a merge -- 

1. Switch onto the branch you want to merge into
2. Use the `git merge`and pass in the name of the branch you are merging into

```sh
git merge <branch_name>
```

#### Switching onto the branch You are merging into

U are going to merge `feature`into `main`-- so, need to switch onto the `main`first, using the `git checkout`or `git switch`commands. Reduce:

1. It changes the `HEAD`pointer to point to the branch U are switching onto.
2. It populates the staging area with all the files and directories are part of the commit U are switching onto.
3. It copies the contents of the staging area into the working directory

Namely, changing branches also *changes the contents of your working directory*.

#### Git protects U from losing uncommitted changes

Just mentioned that switching branches changes the contents of your working directory -- what if U have modified files in your working directory that U have not yet committed -- Git protects U from losing uncommitted chanags. Note that if Git detects that switching branches will cause U to lose uncommitted chanages in your working directory, then it will stop U from switching branches and present U with an error message.

```sh
git status # then change the file
git switch main # error -- your local changs to the files will be overwritten -- Aborting
```

`git status`ouput indicates that file is a modified file in the working directory.

```sh
# make sure have file open in edit place code
git switch main
git log # now HEAD point to main
```

#### Viewing a list of all commits

`git log --all # show a list of commits`

```sh
git merge feature
git log
```

- The `git merge`output mentions `Updating <hash>`and just a *Fast-forward*. This tells U that Git updated the commit the `main`points to, and it tells U that this was a fast-forward merge.
- Then `git log`shows that `main`points to the last commit.
- Merged the `feature`into the `main`, but it still exists, *NOT* automatically deleted. 

U must explicitly delete a branch if you no longer want to use that.

#### Checking out Commits

```sh
git checkout <commit_hash> # check out a commit
```

When do this, the `git checkout`will carry 3 actions that are similar to the ones -- NOTE that:

1. It changes the `HEAD`pointer to point to the *commit* U are switching onto
2. It populates the staging area with all the files and directories that are part of the commit U are switching onto.
3. It copies the contents of the staging area into working directory.

The main difference between these steps is that in 1, the `HEAD`will point directly to a commit instead of pointing a branch. This means that U will be in sth that Git Calls *detached* `HEAD`state. This allows U to look at any commit.

```sh
git checkout <commit_hash>
git log --all
git switch main
git log
```

#### Creating a branch and switching onto it on one Go

If want to create a new branch to retain commits U create, may do so by using `-c`with switch commnd, or use `git checkout -b`option like:

```sh
git switch -c <new_branch_name>
git checkout -b <new_branch_name>
```

## Don’t over-using getters and setters in Go

In Go, there is no automatic support for getters and setters. It is also considered neither mandatory nor idiomatic to use getters and setters to access struct fields. Fore, the stdlib implements structs with some fields are accessible directly:

```go
timer := time.NewTimer(time.Second)
<-timer.C
```

Could even modify `C`directly -- Just illustrates that std Go doesn’t enforce using getters and/or setters.

On the other hand, using getters and setters presents some advantages -- including - 

- They encapsulate a behavior asociated with getting or setting a filed, allowing new features added later
- hide internal representation
- Provde a debugging interception point for when the prop changes

And, if fall into these cases, Using getters and setters can bring some value. In Go, should follow these naming conventions -- 

- The getter method should be named fore, `Balance`, *NOT* `GetBlanace`.
- The setter should be named `SetBalance`. FORE:

```go
currentBlance := customer.Balance()
if currentBalance<0 {
    customer.SetBalance(0)
}
```

Go is a unique language designed for many characteristics, including simplicity.

### Interface pollution

Interfaces are one of the cornerstones of the Go language when designing and structuring code.  But, abusing interfaces is generally not a good idea -- Interface pollution is about overwhelming our code with unnecessary abstractions, making it harder to understand -- it’s a common mistake made by developers coming from other languge with different habits.

#### Concepts

Provides a way to specify the behavior of an object, use interfaces to create common abstractions that multiple objects can implement. Different they are satisfied implicitly -- there is no explicit keyword like `implements`to mark that object X implements interface Y.

Fore, the `io`pacakge provides abstractions for I/O primiteives. `io.Reader`relates to reading data from a data source and `io.Writer`to writing data to a target.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}
```

- `io.Reader`reads data from a source
- `io.Writer`writes data to a target 

Fore, need to implement a function that should copy the content of one file to another, could create a specific function that would take as input two `*os.Files`-- or can choose to create a more generic func using `io.Reader`and `io.Writer`abstractions.

`func copySourceToDest(source io.Reader, dest io.Writer) error {`

This would work with `*os.File`cuz `*os.File`implements both and any other type that would implement these interfaces. Furthermore, writing a unit test for this is easier cuz, instead of having to handle files, can just use the `strings`and `bytes`package provide helpful implementations -- 

```go
func TestCopySourceToDest(t *testing.T) {
    const input="foo"
    source := strings.NewReader(input)
    
    // Creates an io.Writer
    dest := bytes.NewBuffer(make([]byte, 0))
    err := copySourceToDest(source, dest)
    if err != nil {
        t.FailNow()
    }
    got := dest.String()
    if got != input {
        t.Errorf("expected: %s, got: %s", input, got)
    }
}
```

While designing interface, the granlarity (namely - how many methods the interface contains) is also sth to keep in mind. The bigger the interface, the weaker the abstraction.

Indeed, adding methods to an interface can *decrease* its level of reusability -- `io.Reader`and `io.Writer`are powerful abstractions cuz they cannot get any simpler. Furthermore, can also combine fine-grained interfaces to create high-level abstractions -- like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

#### When to Use interfaces

When should use -- 3 concrete use cases where interfaces are usually considered to bring value -- 

- Common behavior
- Decoupling
- Restricting behavior

Common behavior -- When multiple types implement a common behavior. If look at the stdlib, can find many examples of such a use case -- fore, sorting -- *number, comparing, swapping*.

```go
type Interface interface {
    Len() int
    Less(i,j) bool
    Swap(i,j int)
}
```

This interface has a strong potential for reusability cuz it encompases the common behavior to sort any collection that is just *index-based*.

Finding the right abstraction to factor out a behavior can also bring many benefits -- fore, the `sort`package provides utility functions that also rely on `sort.Interface`.

```go
func IsSorted(data Interface) bool {
    n := data.Len()
    for i:= n-1; i>0; i-- {
        if data.Less(i, i-1) {
            return false
        }
    }
    return true
}
```

Decoupling -- Another use case is about decoupling our code from an implementation. If we just rely on an abstraction instead of a concrete imp, the imp itself can be replaced with another without even having change our code. FORE:

```go
type CustomerService struct {
    store mysql.Store // Depend on concrete imp
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.store.StoreCustomer(customer)
}
```

Now, what if want to test this method -- cuz `CustomerService`relies on the actual imp to store a `Customer`, we are obliged to test it through integration tests, which requires spinning up a MySQL instance. To give more flexibility, should decouple `CustomerService`from actual imp

```go
type customerStorer interface {
    StoreCustomer(Customer) error
}
type customerService struct {
    storer customerStorer // decouples service from imp
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.storer.StoreCustomer(customer)
}
```

Cuz storing a customer is now done via an interface, this gives us more flexibility in how we want to test the method

- Can use the concrete imp via integration tests
- use mock via unit tests
- or both

#### Restricting Behavior

It’s about restricting a type to a specific behavior -- imagine implement a custom configuration package to deal with dynamic configuration, create a specific container for `int`configurations via an `IngConfig`.

```go
type IntConfig struct {
    //...
}

func (c *IntConfig) Get() int {
    // retrieve
}
func (c *IntConfig) Set(value int) {
    // update
}
```

Suppose receive an `IntConfig`that holds some specific configuration -- Yet in code are only interested in retrieving the configuration value, and want to update that. Namely -- how can enforce that -- semantically, this configuration is read-only -- if don’t want to change configuration package -- For this, by creating an abstraction that restricts the behavior to retrieving only a config value like:

```go
type intConfigGetter interface {
    Get() int
}
// In code can rely on this instead of concrete imp
type Foo struct {
    threshold intConfigGetter
}
func NewFoo(threshold intConfigGetter) Foo {
    return Foo{threshold: threshold}
}
func (f Foo) Bar {
    //...
}
```

In this, the configuration getter is injected into the `NewFoo`factory method -- it doesn’t impact a client of this func cuz it can still pass an `IntConfig`struct as it implements `intConfigGetter`. Then, can only read the configuration in the `Bar`method, not modify it, therefore, can also use interfaces to restrict a type to a specific behavior for various readons.

#### Interface pollution

It’s fairly common to see interfaces being overused in Go projects -- perhaps the developer’s background was C#.. And they found it natural to create interfaces before concrete types. And the main caveat when programming meets abstractions is remembering that abstractions, *should* be discovered, not created. It means that we shouldn’t start creating abstractions in our code if there is no immediate reason to do so. We shouldn’t design with interfaces but wait for a concrete need. Should create an interface when need, not when *foresee* that we could need it.

Namely -- What’s the main problem if we overuse interfaces -- The answer is that they make the code flow more complex -- Adding a useless level of indirection doesn’t bring any value -- creates a wrothless abstraction just making the code more difficult to read, understand, and reason about.

Don’t design with interface in Go, just discover them.

## Transactions and other details

The `database/sql`package essentially provides a std inerface between your Go app and the world of SQL. So long as U use the `database/sql`-- write will generally be portable and will work with any kind of SQL dbs. This just means that your application isn’t so tightly coupled to the dbs that you are currently using, can swap dbs in the future without rewriting all of you code.

Important to note that while `database/sql`generally deos a good job of providing a std interface for working with SQL dbs, there are some idiosyncrasies.

#### Managing null values

One thing to note is that Go doesn’t do very well is managing `NULL`values in the dbs records. Fore, pretend that the `title`in the table contains a `NULL`in a particular row, when queried that row, then `rows.Scan()`would return an error cuz it can’t convert NULL to a string. Very roughly, the fix for this is to change the field that U are scanning into from a `string`to `sql.NullString`type. Or, `NOT NULL`constraints.

### Working with transactions

It’s just important to realize that calls to `Exec(), Query(), QueryRow()`can use any *connection* from `sql.DB`pool. Fore, even if U have two calls to `Exec()`immediately next to each other in code -- there is no guarantee that they will use the *same dbs connection*.

Sometime, if lock the table with MySQL’s `LOCK TABLES`and must then call `UNLOCK TABLES`on exactly the same connction to avoid a deadlock. To guaranteee that the same connection is used when wrap multiple statemens in a *transaction* -- basic pattern fore:

```go
type ExampleModel struct {
    DB *sql.DB
}
func (m *ExampleModel) ExampleTransaction() error {
    // Calling the `Begin()` on the pool creates a new `sql.Tx`
    tx, err := m.DB.Begin()
    if err != nil {
        return err
    }
    
    // defer a call to tx.Rollback() to ensure it is always called before the func returns
    // if transaction succeeds it will be already be committed by the time tx.Rollback() is called
    // now note that making tx.Rollback() a no-op.
    defer tx.Rollback()
    
    // Call Exec() on transaction
    // is called on the tranaction object just crted, not the connection pool
    _, err = tx.Exec("INSERT INTO...")
    
    // carry out another transaction
    _, err = tx.Exec("UPDATE...")
    if err != nil {
        return err
    }
    
    // if there are no errors commit
    err = tx.Commit()
    return err
}
```

IMPORTANT -- U must always call either `Rollback()`or `Commit()`before your function returns, If dont the connection will *stay open* and not be returned to the connection pool. Transactions are also super-useful if want to execute multiple SQL statemens as a single atomic action.

#### Prepared statements

Fore, `Exec(), Query()`and `QueryRow()`all use *prepared* statements behind the scenes to help prevent SQL injection attacks. They set up a prepared statement on the dbs connection, run it with the parameters.. Inefficient cuz we are just creating and recreating the same prepared statements every single time.

In theory, better could be to make use of the `DB.Prepare()`to create our own prepared statement once, and reuse that instead -- particular true for complex SQL statemens and are repeated very often.

```go
// need somewhere to store the prepared statement for the lifetime of our web app 
// neet way to embed in the model alongside the connection pool
type ExampleModel struct {
    DB *sql.DB
    InsertStmt *sql.Stmt
}

func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    insertStmt, err := db.Prepare("INSERT INTO...")
    if err != nil {
        return nil, err
    }
    return &ExampleModel{db, insertStmt}, nil
}

func (m *ExmpleModel) Insert(args...) error {
    _, err := m.InsertStmt.Exec(args...)
    return err
}

func main() {
    db, err := sql.Open(...)
    if err != nil {
        //...
    }
    defer db.Close()
    
    exampleModel, err := NewExampleModel(db)
    if err != nil {
        //...
    }
    defer exampleModel.InsertStmt.Close()
}
```

Prepared statemens just exist on *database connections*. So cuz Go uses a pool of many dbs connections, It gets created on a particular dbs conenction. The `sql.Stmt`object then remembers which connection in the pool was used.

### Dynamic templates

Start in the `snippetView`handler and add some code to render a new `view.html`template file.

```go
// initialize a slice
files := []string{
    "./ui/html/base.layout.html",
    "./ui/html/partials/nav.html",
    "./ui/html/pages/home.html",
}

// parse the template files...
ts, err := template.ParseFiles(files...)
if err != nil {
    app.serverError(w, err)
    return
}

// Then execute them
err = ts.ExecuteTemplate(w, "base", snippet)
if err != nil {
    app.serverError(w, err)
}
```

Within HTML templates, any dynamic data that U pass is represented by the `.`. Fore `{{.Title}}`

```html
{{define "title"}}Snippet # {{.ID}}{{end}}

{{define "main"}}
    <div class="snippet">
        <div class="metadata">
            <strong>{{.Title}}</strong>
            <span>#{{.ID}}</span>
        </div>
        <pre><code>{{.Content}}</code></pre>
        <div class="metadata">
            <time>Created: {{.Created}}</time>
            <time>Expired: {{.Expires}}</time>
        </div>
    </div>
{{end}}
```

#### Rendering multiple pieces of data

An important thing to explain is that Go’s `html/template`package allows U to pass in one -- and only one dynamic data when rendering a template -- but in a real-world app there are often multiple pieces of dynamic data that U want to dispaly in the same page.

A lightweight and type-safe way to achieve this is to wrap your dynamic data in a struct which acts like a single *holding structure* for data. Fore:

```go
type templateData struct {
    Snippet *models.Snippet
}
//...
data := &templateData{
    Snippet: snippet,
}
// Then execute them
err = ts.ExecuteTemplate(w, "base", data)
if err != nil {
    app.serverError(w, err)
}
```

For this, change to:

```html
{{define "title"}}Snippet # {{.Snippet.ID}}{{end}}

{{define "main"}}
    <div class="snippet">
        <div class="metadata">
            <strong>{{.Snippet.Title}}</strong>
            <span>#{{.Snippet.ID}}</span>
        </div>
        <pre><code>{{.Snippet.Content}}</code></pre>
        <div class="metadata">
            <time>Created: {{.Snippet.Created}}</time>
            <time>Expired: {{.Snippet.Expires}}</time>
        </div>
    </div>
{{end}}
```

The `html/template`package just automatically escapes any data that is yielded between `{{}}`tags. This behavior is hugely helpful in avoiding XSS attacks.

Nested templates -- It’s also really important to note that when you are invoking one template from another, dot needs to be explicitly passed or pipelined to the template being invoked, do this by including it at the end of each `{{tempalte}}`or `{{block}}`action -- like so:

```html
{{template "main" .}}
{{block "sidebar" .}}{{end}}
```

As a general rule -- get into the habit of always pipelining dot whenever u invoke template with `{{template}}`or `{{block}}`actions.