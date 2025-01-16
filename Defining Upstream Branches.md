# Defining Upstream Branches

If no upstream branch is defined for the local branch you are working on -- you will need to specify which remote branch to push to when you enter the `git push`command. Learned that upstream branches are automatically set up when you clone a repository, but *not* when a repository is initialized locally. The `rainbow`repository was initialized locally, and you have not defined any upstream branches yet.

```sh
git branch -u <shortname>/<branch_name>
git branch -vv
git branch -u origin/main
git branch -vv
```

#### editing the same file multiple times between Commits -- 

It’s important to understand that if you add a file to the staging area and then make *another change* to the file. Git will interpret that as a new version of the file and it will mark the file as modified.

For now,  The version of the `rainbowcolors.txt`file in the staging area has changed from B to C. Then your friend is going to finish making the blue commit and attempt to push their work to the remote repository. However, since their local `main`is out of sync with the remote `main`branch, will come across an error.

#### Working at the same Time as others on Different Files

The local `main`in the `friend-branch`is out of sync with the remote `main`. Your friend is ready to make their blue commit and try to share their work.

```sh
git commit -m "blue"
git push # rejected
```

The output of the `git push`command shows that your friend gets an error. They are just not able to push their changes to the remote repository. The development histories of the local `main`and the remote `main`have diverged, and Git is not able to merge changes from one into the other with a simple FF merge.

- In the `friend-rainbow`the local main bracnh points to the blue
- in the `rainbow-remote`, the main just points to the brown commit.

Git just is telling your friend that there are commits on the remote `main`that they have not yet fetched, it advices to fetch or pull the remote work and integrate it into their local `main`.

### 3-way Merge in practice -- 

1. First, fetch the changed
2. Second, integrage the changes into the local branch

But, when performing the 3-way merge, Git will create a merge commit -- to do that, it will enter a text editor the command line. Git by default, under the linux, open `vim`to do that. Vim may appear..

#### Executing the 3-way merge

Having read the error message Git presented, your friend is now going to fetch the changes from the remote `main`into their local repository. Like:

```sh
git fetch
git merge origin/main
git push
```

The `git merge origin/main`command line will enter vim after `git merge`command is exuected. The default commit message that Git drafts for wyou will be... To accept the default message just `:wq`. Then `git log`. 

`git merge`output says that `Merge made by the ‘ort’`stategy -- this indicates that this was a 3-way merge. For now the `M1`merge commit has two parent commits. Can use command like:

```sh
git cat-file -p <commit_hash>
```

To vieww the parent commits of a commit, recv. To retreive the commit hash of the M1 merge commit, you can use the output of the `git log`command.

The `M1`commit is now in the friend-rainbow repository and the rainbow-remote repository.

#### Pulling changes from a Remote repository

Up until now, in the Rainbow proj, when you want to update your local repository with changes from the remote repository you did it in two steps -- first, you fetch the data from the remote repository, and then mreged the data into the local branch.

In Git, U use the term *pull* to refer the process of fetching data and integrating into a branch in a local repository in one go. And the command is `git pull`. Also, if don’t have an upstream branch defined for your local branch, then you  must specify the shortname of the remote repository and the name of the branch.

```sh
git pull <shortname> <branch_name>
git pull # if an upstream branch is just defined
```

There is one more thing you need to know about the `git pull`command -- in Git there are two ways to integrate changes -- `merging`and `rebasing`. Which method the `git pull`uses will depend on whehter the development histories of the branches have diverged and -- 

- If the development histories of the local branch and remote branch in a `git pull` have *Not* diverged, ff
- If diverged, then you must tell Git whether U want to integrate the change by merging or rebasing. To tell Git to integrate the changes just by merging, pass `--no-rebase`option. And to tell Git to integrate the changes by rebasing, using `--rebase`.

For now, when should you fetch and integrage changes in two steps by using the `git fetch`, then either the `git merge`or `git rebase`-- 

It is common for Git users to use the `git pull`*when the development histories of the local and remote branches have not diverged.* And therefore a simple FF merge will happen.

And when diverged, Git suers often perfer to use the `git fetch`then choose whether to rebase or merge.

```sh
git pull
git log
```

## Functions and Methods

- When to use value or pointer receivers
- When to use named result parameters and their potential side effects
- Avoiding a common mistake while returning a `nil`receiver
- Why using functions that accepts a filename isn’t best practice
- Handle `defer`arguments

### Which type of receiver to use

Choosing a receiver type for a method isn’t always straightforward, when should we use value receiver, when should use pointer receiver -- In Go, can attach either a value or a pointer receiver to a method. With a value receiver, Go makes a copy of the value and passes it to the method fore:

```go
type customer struct {
    balance float64
}
func (c customer) add (v float64) {
    c.balance+=v
}
func main(){
    c := customer{balance:100.}
    c.add(50.) // 100.00
}
```

If: `func (c *customer) add(operation float64)`then 150 returned. Choosing between value and pointer receiver isn’t always straightforward. Fore:

A receiver must be a pointer -- If method needs to mutate the receiver. And If the method receiver contains a field that cannot be copied.

A receiver *should* be a pointer -- If the receiver is a large object, using a pointer can make the call more efficient.

A receiver *must* be a value -- if enforce a receiver’s immutability, if the receiver is a map, funciton or channel.

A receiver *should* be a value -- If doesn’t have to be mutated, or, small array, if fore `time.Time`struct, if the receiver is basic type such as `int`.

### Using named result parameters

Named result parameters are infrequently used option in Go. When must return parameters in a func or method, can attach names to these parameters and use them as regular variables. When is it recommded that we use named result -- like:

```go
type locator interface {
    getCoordinate(address string) (float32, float32, error)
}
```

Cuz this interface is not unexported, Can U guess what these two `float32`mean -- in the case, should probably use named result parameters to make the code easier to read like:

```go
type locator interface {
    getCoordinates(address string) (lat, lng float32, err error)
}
```

### Unintended side effects with named result parameters

As these result parameters are initialized to their zero value, using them can sometimes lead to subtle bugs.

```go
func (l loc) getCoordinates(ctx context.Context, address string) (
    lat lng float32, err error) {
    isValid := l.validateAddress(address)
    if !isValid {
        return 0, 0, errors.New("invalid address")
    }
    if ctx.Err()!= nil {
        // here, return nil error
        return 0, 0, err
    }
}
```

One possible fix to this just like:

```go
if err := ctx.Err(); err != nil {
    return 0, 0, err
}
```

### Don’t return a `nil`receiver

In this, discuss the impact of returinng an interface and why doing so may lead to errors in some conditions. Fore:

```go
type MultiError struct {
    errs []string
}
func (m *MultiError) Add(err error) {
    m.errs = append(m.errs, err.Error())
}
func (m *MultiError) Error() string {
    return strings.Join(m.errs, ";")
}
```

For this, the `MultiError`satisfies the `error`interface cuz it just implements `Error() string`. Meanwhile it just exposes an `Add`to append an error. Using this, can implement a `Customer.Validate()`in the following manner:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age<0 {
        m = &MultiError{}
        m.Add(errors.New("age is negative"))
    }
    ///... for nil condition
    return m
}

customer := Customer {Age:33, Name:"John"}
if err := customer.Validate(); err != nil {
    log.Fatal("customer is invalid: %v", err)
}
```

This will result in `customer is invalid` -- In Go, have to known that a pointer receiver can be `nil`. Fore:

```go
type Foo struct{}
func(foo *Foo) Bar() string {
    return "bar"
}
func main(){
    var foo *Foo
    foo.Bar() // foo is nil
}
```

Cuz, `foo`is initialized to the zero value of a pointer -`nil`-- but this code just compiles, and it prints `bar`if we run. Cuz a method is just syntactic sugar for a fucnction whose first parameter is the receiver. For the method, `m`is initialized to the zero value of a pointer, then -- `nil`pointer is just a valid receiver, converting the result into a interface (here, the `error`) won’t yield a `nil`value. The caller of `Validate`will always get a **non-nil** error.

In Go, an interface is a dispatch wrapper - The wrappee here is `nil`and wrapper isn’t `nil`here, just the `error`interface here. So:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age < 0 {
        //...
    }
    if c.Name == ""{
        //...
    }
    if m != nil {
        return m
    }
    return nil // otherwise just returns a nil
}
```

### Don’t use a filename as a function input

When creating a new function that needs to read a fle, passing a filename isn’t considered a best practice and can have negative effects, such as making unit tests harder to write. Fore, want to implement a functoin to count the number of empty lines in a file.

```go
func countEmptyLinesInFile(filename string) (int, error) {
    file, err := os.Open(filename)
    if err != nil {
        return 0, err
    }
    // handle file closure
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        //...
    }
}
```

However, if want to implement unit tests to cover the following cases -- 

- A nominal case
- an empty file
- file containing only empty lines

For this, each unit test will require creating a file in our Go project -- the more complex the function is, the more cases we may want to add, and the more files we will create. Fore, may have to create dozens of files in some cases. Furthermore, this function isn’t reusable.

One way to overcome these limitations might be to make the func accept `bufio.Scanner`. But functions have the same logic from the moment. -- But in Go, the idiomatic way to do is to fromt the reader’s abstraction. 

```go
func countEmptyLines(reader io.Reader) (int, error) {
    scanner := bufio.NewScanner(reader)
    for scanner.Scan() {
        //...
    }
}
```

Can test it like:

```go
func TestCountEmptyLines(t *testing.T) {
    emptyLines, err := countEmptyLines(strings.NewReader(
    	`foo
    	   bar
    	   
    	   baz`
    ))
}
```

In this test, create an `io.Reader`using the `strings.NewReader`directly. Therefore, don’t have to create one file per test case. Each test case can be self-contained.

## Testing a Connection

```go
func openDB(dsn string)(*sql.DB, error) {
    db, err := sql.Open("mysql", dsn)
    if err != nil {
        return nil, err
    }
    if err = db.Ping(); err != nil {
        return nil, err
    }
    return db, nil
}
```

### Designing a dbs model

In this case, are going to sketch out a dbs model for our project -- might think of it as a *service layer*.. The idea is just will encapsulate the code for working with MYSQL in a separate package to the rest of the application. `internal/models`directory containing a `snippets.go`file. Remember -- the `internal`directory is being used to handle ancillary non-application-specific code, which could potentially be reused. A new `Snippet`struct to represent the data for an individual snippet -- along with a `SnippetModel`type.

```go
// Snippet Define a Snippet type to hold the data for an individual snippet.
type Snippet struct {
	ID      int
	Title   string
	Content string
	Created time.Time
	Expires time.Time
}

// SnippetModel Define a SnippetModel type which wraps a sql.DB connection pool.
type SnippetModel struct {
	DB *sql.DB
}

// Insert This will insert a new snippet into the dbs
func(m *SnippetModel) Insert(title string, content string, expires int) (int, error) {
	return 0, nil
}

func (m *SnippetModel) Get(id int) (*Snippet, error ) {
	return nil, nil
}

// Latest returns 10 most recently created snippets
func (m *SnippetModel) Latest() ([]*Snippet, error) {
	return nil, nil
}
```

#### Using the `SnippetModel`-- 

To use this model in our handlers we need to establish a new `SnippetModel`struct in our `main()`function and then inject it as a dependency via the `application`struct.

```go
db, err := openDB(*dsn)
if err != nil {
    errorLog.Fatal(err)
}
defer db.Close()

app := &application{
    errorLog, infoLog,
    &models.SnippetModel{DB: db},
}
```

#### Benifits of this structure

If take a step back, might be able to see a few benefits of setting up our project in this way -- 

- There is clean separation of concerns.
- By creating a custom `SnippetModel`type and implementing methods on it we have been able to make our model a single, neatly encapsulated object.

### Executing SQL Statements

Update the `SnippetModel.Insert`method -- which have jsut made -- so that it creates a new record in our `snippets`table and then returns the integer `id`for the new record. Like:

```sql
INSERT INTO snippets(title, content, created, expires)
VALUES (?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESPTAM(), INTERVAL ? DAY))
```

In MySQL, just using the `?`character to indicate *placeholder* parameters for the data that we want to insert in the database ? Because the data we will be using will ultimately be untrusted user input from a form.

#### Executing the query

Go provides 3 different methods for exacuting dbs queries -- 

- `DB.Query()`for `SELECT`
- `DB.QueryRow()`-- for `SELECT`which return a single row.
- `DB.Exec()`-- for don’t returing rows (INSERT and DELETE)

So, in the case, the most appropraite tool for the job is `DB.Exec()`-- jump in the deep and demonstrate how to use this in our `SnippetModel.Insert()`.

```go
func (m *SnippetModel) Insert(title string, content string, expires int) (int, error) {
	stmt := `INSERT INTO snippets(title, content, created, expires)
		VALUES(?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY))`
	
	// Use the `Exec()` method on the embedded connection pool to execute the statement
	result, err := m.DB.Exec(stmt, title, content, expires)
	if err != nil{
		return 0, err
	}
	id, err := result.LastInsertId()
	if err != nil {
		return 0, err
	}
	return int(id), nil // cuz returned an int64
}
```

This provides two methods -- 

- `LastInsertId()`-- which returns the integer generated by the dbs in response to a command. Typically this will be from an auto increment column when inserting a new row.
- `RowsAffected()`-- which returns the number of rows affected by the statement.

#### Using the model in our handlers

Bring this back to sth more concrete and demonstrate how to call this new code from our handlers -- open:

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		w.Header().Set("Allow", "POST")
		app.clientError(w, http.StatusMethodNotAllowed)
		return
	}

	title := "0 snail"
	content := "O snail\nClimb Mount Fuji,\nBut slowly, slowly!\n\n– Kobayashi Issa"
	expires := 7

	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}
	http.Redirect(w, r, fmt.Sprintf("/snippet/view?id=%d", id), http.StatusSeeOther)
}
```

This inserted a new record in the dbs and returned the ID of this new record.

#### Placeholder parameters

The reason for using placeholder parameters to construct our query is to help avoid SQL injection attacks from any untrusted user-provided input -- Behind the scenes, `Db.Exec()`method work in three steps -- 

1. Creates a new *prepared statement* on the dbs using the provided SQL statement. The dbs parases and compiles the statement, then stores it ready for execution.
2. Then `Exec()`passes the parameter values to the dbs, the dbs then executes the prepared statement using these parameters, cuz the parameters are transimtted later, after the statement has been compiled, the dbs treats them as pure data.
3. It then closes (or deallocates) the prepared statement on the dbs.

Note that the placeholder parameter syntax differs depending on your dbs, MySQL, SQLServer and SQLite use the `?`notation, but PostgreSQL uses the `$N`notation. Like:

`_, err := m.DB.Exec(“INSERT INTO ... VALUES($1, $2, $3)”, ...)`

#### Single-record SQL queries -- 

The pattern for SELECT a single record from the dbs is a little more complicated. Explain how to do it updating your `SnippetModel.Get()`method so that it returns a single specific snippet based on its ID. Like:

```sql
SELECT id, title, content, created, expires FROM snippets
WHERE expires > UTC_TIMESTAMP() AND id= ?
```

