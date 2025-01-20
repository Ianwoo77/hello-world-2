# Merge Cloning Fetching (rec1)

```sh
git clone <URL> <directory_name>
git remove -v
git branch --all
git switch feature
git branch --all # *feature, main
```

#### The `Origin`shortname -- 

The local repository must have a connection with a shortname to the remote repository stored within it. To work with the remote repository, had to explicitly associate its URL with a shortname using:

```sh
git remote add <shortname> <URL> # cuz using git init
```

#### Deleting Branches - 

The main reason to delete branches is to keep Git project organized and uncluttered. Before deleting a branch, should always make sure that either you have merged it into another, or don’t want to use that just.

```sh
git push <shortname> -d <branch_name> # delete a remote branch, and remote-tracking branche either
# just like
git branch --all
git push origin -d feature
git branch --all
git switch main
git branch -d feature # delete local branch
```

#### Making a commit in the local repository

```sh
git add rainbowcolors.txt
git commit -m "green"
git log
```

Pushing to the remote repository -- 

```sh
git branch -vv # List the local branch and their upstream branches, if have any
```

1. If have fetched the remote, can check if your repository is *ahead* of or *behind* the remote by using the `git branch -vv`command or the `git status`
2. Simplify the commands, just using `git push`if already specified the remote repository shortname

```sh
git push
git status
git log
```

#### Fetching changes from the remote

```sh
git fetch <short_name>
git feach # from origin
```

Not that the `git fetch`only affects **remote-tracking** branches. It does not affect local branches. So, it only fetches (downloads) data, doesn’t actually integrate the data into any local branches.

```sh
git fetch
git log -all
```

Integrating changes -- To integrate commits that were on the `main`in the remote repository into your local `main`, will use the `git merge`like:

```sh
git switch main
git merge origin/main
git log
```

#### Deleting Branches -- 

In the `rainbow`, still have the local `feature`and the `origin/feature`. Used the `git push <short_name> -d <branch_name>`command to delete the remote `feature`and the `origin/feature`remote-tracking branch. So just delete the **remote-tracking** branch in the repository can just use :

```sh
git fetch -p # remove remote-tracking that correspond to deleted remote branches
git branch -d feature
git branch --all
```

### Three-way Merges

```sh
# in the `rainbow`create new file
git add othercolors.txt
git commit -m "brown"
git log
```

#### Defining upstream branches

To avoid specifying the remote repository shortname and the branch every time you use the `git push`command on the `main`in the repository `-u`option with `git branch`. -- for `--set-upstream-to`.

```sh
git branch -u <shortname>/<branch_name>
git branch -vv
git branch -u origin/main
git branch -vv # can see origin/main ahead 1...
git push
```

#### Editing the same File multiple times between commits

It’s important to understand that if U add a file to the staging area and then make *another change* to the file. Git will interpret this as a new version of the file and it will make the file as modified.

```sh
# edit the rainbowcolors in the friend directory
git status
git add rainbowcolors.txt
git status
# then make some changes
git status
git add rainbowcolors.txt
git status
git commit -m "blue"
git push #rejected
```

Will get an error -- not able to push changes to the remote -- cuz the local `main`and the remote `main`have diverged, and Git is not able to merge chagnes from one into the other with a simple FF merge.

#### Three-way Merge in Practice

Learned that incorporating changes from a remote is a two-step process -- 

1. First, fetch the changes from the remote
2. Second, integrate the changes into the local in the local repository

Git by default, using `vim`to write commit messages.

```sh
# under friend repository directory
git fetch
git merge origin/main
# The command line will enter Vim after the git merge command is executed.
# accept that and :wq enter
# retrieving has for M1 merge commit
git cat-file -p <hash_code> # can see two parents
git push
```

Pulling changes from a remote repository

```sh
git pull # git fetch + git merge (git rebase or)
```

This can be done cuz the `rainbow`repository just add a new file.

### Merge Conflicts

Last chapter just covered what happens when you work on a project at the same time as someone else but you make changes to *different files*. When U want to integrate work where there will be a merge conflict -- When merge two branches where different changes have been made to the same parts in the same file.

Merge conflicts can arise during the process of merging as well as the process of rebasing. When merge conflicts happen, will see a set of special markers in each of the files involved that indicate where the conflicts occur -- these markers -- called *conflict markers* -- consist of `<<<<<<<`, and 7=, and 7>. as well as references to the branches involved in the merge.

1. Decide what to keep, edit the content, and remove the conflict markers
2. Add the file(s) you have edited to the staging area and commit your changes

#### Setting up a Merge conflict scenario

```sh
git add rainbowcolors.txt # under rainbow, in the rainbowcolors.txt
git commit -m "indigo"
git push
git log
# under the friend Add some 
git add rainbowcolors.txt
git commit -m "violet"
git log
# still under the friedn
git fetch
git status
git log --all
```

## When to wrap an error

Since Go 1.13, `%w`directive allows us to wrap errors conveniently, but some developers may be confused about when to wrap an error, or not. Error wrapping is about wrapping or packing an errir inside a wrapper containing that also make the source available. In general, the two main use cases for error wrapping -- 

- Adding additional context
- Marking as a sepecial error

Fore, for debugging purpose, if the error is eventually logged, we want to add extra context, in this case, can wrap the error to indicate who the user is and what resource is being accessed. In both cases, the source error *remains available* -- hence, a caller can also handle an error by unwrapping it and checking the source error.

```go
func Foo() error {
    err := bar()
    if err != nil {
        return // what?
    }
}
```

The first option is to return this error directly, but no helpful context, before go 1.13, just without using an external library was to create a custom error type like:

```go
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return "bar failed:"+ b.Err.Error()
}
```

Then instead of returning `err`directly, wrapped error into a `BarError`like:

```go
if err != nil {
    return BarError{Err: err}
}
```

The benefit of this option is flexibility, cuz `BarError`is a custom struct, can add any additional context if needed. To overcome: like:

```go
if err != nil {
    return fmt.Errorf("bar failed: %w", err)
}
```

This code wraps the source error to add additional context without having to creat another error type. Cuz the source error remains available, a client can unwrap the parent error and then check whether the source error was of a specific type or value. 

And the last option discuss is use the `%v`directive like:

```go
if err != nil {
    return fmt.Errorf("bar failed: %v", err)
}
```

And the difference is that the error itself is not wrapped, just transform it into another error to add context. This time a caller can’t unwrap this error and check whether the source was `bar error`. Wrapping an error makes the source error available for callers. It means introducing potential coupling.

### Checking an error type accurately

When use that approach, it’s also essential to change our way of checking for a specific error type. Fore, write an HTTP handler to return the transaction amount from an ID.

- If the ID is invalid
- If querying the DB fails

Want to return `StatusBadRequeste`or `ServiceUnavailable`. To do that will create a `transientError`type to mark that an error is temporary. Like;

```go
type transientError struct {
    err error
}
func (t transientError) Error() string {
    return fmt.Sprintf("transient error: %v", t.err)
}
func getTransactionAmount(transactionID string) (float32, error ) {
    if len(transactionID)!=5 {
        return 0, fmt.Errorf("id is not valid: %s", transactionID)
    }
    amount, err := getTransientAmountFromDB(transactionID) {
        if err != nil {
            return 0, transientError {err: err}
        }
        return amount, nil
    }
}
```

Then write the HTTP handler that checks the error to return the appropriate HTTP status code like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    transactionID = r.URL.Query().Get("transaction")
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        switch err := err.(type) {
        case transientError:
            http.Error(..., 503)
        default:
            http.Error(..., 400)
        }
        return
    }
}
```

Let’s assume that want to perform a small refactoring of `getTransactionAmount`fore:

```go
func getTransactionAmount(transactionID string) (float32, error) {
    //...
    amount, err := getTransactionAmountFromDB(transactionID)
    if err != nil {
        return 0, fmt.Errorf("failed to get transaction: %s: %w", transactionID, err)
    }
    return amount, nil
}
func getTransactionAmountFromDB(transactionID string)(float32, error) {
    //...
    if err != nil {
        return 0, transactionError{err: err}
    }
}
```

So need to rewrite the imp of the caller using `errors.As`like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        if errors.As(err, &transientError{}){
            http.Error(w, err.Error(), 503)
        }else {
            http.Error(w, err.Error(), 400)
        }
    }
}
```

Got rid of the `switch`case type in this new version, and we now just the `errors.As()`-- requires the second argument to be a pointer.

### Checking an error value accurately

A sentinel error is an error defined as a global variable like:

```go
import "errors"
var ErrFoo = errors.New("foo")
```

In general, the convention is to start with `Err`followed by the error type -- a sentinel error conveys an *expected error* -- Fore, want to design a `Query()`that allows to execute a query to a dbs. This returns a slice of rows -- how should we handle the case when no rows are found -- 

- Return a sentienl value -- `nil`slice
- Return a specific error that a client can check

Fore, take the second approach -- can return a specific error if no rows are found, can classify this as an *expected error*. 

- `sql.ErrNoRows`-- return when a query doesn’t return any rows
- `io.EOF`-- returned by an `io.Reader`when no more input is available.

That is the general principal behind sentinel errors -- they convey an expected error that clients will expect to check:

- Expected errors should be designed as error values -- `var ErrFoo = errors.New(“foo”)`
- Unexpected errors hould be designed as error types `type BarError struct {...}`imp the `error`interface

```go
err := query()
if err != nil {
    if err == sql.ErrNoRows {...}
}
```

For this, call a `query()`and get an error, checking whether the error is an `sql.ErrNoRows`is done using the `==`operator. Just as discussed in the previous section, a sentienel error can also be wrapped. If an `sql.ErrNoRows`is wrapped using `fmt.Errorf`and the `%w`directive, `err == sql.ErrNoRows`will always be false.

```go
err := query()
if err != nil {
    if errors.Is(err, sql.ErrNowRows){}
}
```

### Handking `defer`errors -- 

If want to tie the eror returned by the `getBalance()`to the error caught in the `defer`call, must use named result parameters -- like:

```go
func getBalance(db *sql.DB, clientID string) (balance float32, err error) {
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer func() {
        err = rows.Close()
    }
}
```

But, there is a problem with it -- if `rows.Scan`returns an error, `rows.Close()`is executed anyway. So if both `rows.Scan`and `rows.CLose`fail -- so:

```go
defer func() {
    closeErr := rows.Close()
    if err != nil {
        if closeErr != nil {
            log.Printf("Failed to close the rows: %v", err)
        }
        return
    }
    err = closeErr
}
```

So, if want to tie the error returned by `getBalance()`to the error caught in the `defer`call, must use the named result parameters.

## Single-record SQL Queries

The pattern for `SELECT`ing a single record from the dbs is a little more complicated -- `

```sql
select id, title, content, created, expires from snippets
where expires> UTC_TIMESTAPM() and id= ?
```

For this, cuz our `snippets`table uses the `id`column as its PK this query will only ever return exactly one dbs row, the query also includes a check on the expiry time. In the `snippets.go`file like:

```go
var ErrNoRecord = errors.New("models: no matching record found")

func (m *SnippetModel) Get(id int) (*Snippet, error) {
	stmt := `SELECT id, title, content, created, expires FROM snippets
		WHERE expires > UTC_TIMESTAMP() AND id = ?`

	// then use the `QueryRow()` method on the connection pool to execute sql
	row := m.DB.QueryRow(stmt, id)

	// initialize a pointer to a new zeroed struct
	s := &Snippet{}

	// then use row.Scan() to copy the value from each field in sql.Row to the
	// corresponding filed in the struct. The number of arguments must be
	// exactly the same as the number of columns returned by statement
	err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNoRecord
		} else {
			return nil, err
		}
	}
	return s, nil
}
```

Behind the scenes of `rows.Scan()`your driver will automatically convert the rao output from the dbs to the required native Go types.

- `CHAR VARCHAR`and `TEXT`to `string`
- `BOOLEAND`to `bool`
- `INT`to `int`, `BIGINT`to `int64`
- `DECIMAL`and `NUMERIC`to `float`
- `TIME DATE TIMESTAMP`to `time.Time`

Note htat -- using `ErrNoRecord`is Cuz to help encapsulate the model *completely*.

#### Using the model in our handlers

Then put the `SnippetModel.get()`into action like:

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}
	
	// using the `SnippetModel` Get() method to retrieve the data
	snippet, err := app.snippets.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w)
		}else {
			app.serverError(w, err)
		}
		return
	}
	fmt.Fprintf(w, "%+v", snippet)
}
```

#### Checking for specific errors

A couple of time used the `errors.Is()`function to check whether an error matches a specific value like:

```go
if errors.Is(err, models.ErrNoRecord) {
    app.NotFound(w)
}else {
    app.serverErr(w, err)
}
```

It’s now safer and best pracitce is to use the `errors.Is()`-- cuz 1.13 introduced the ability to add additional information to errors by *wrapping* -- if an error happens to get wrapped, a entirely new error value is created -- a entirely new error value is created -- which in turn means that it’s not possible to check the value of the original underlying error just using the `==`operator.

In contrast, the `errors.Is()`function works by unwrapping errors as necesssary before checking for a match.

##### Shorthand single-record queries

```go
// shorten the code slightly
func (m *SnippetModel) Get(int id) (*Snippet, error) {
    s := &Snippet{}
    err := m.DB.QueryRow("SELECT...").Scan(&s.ID, ...)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrNoRecord
        }else {
            return nil, err
        }
    }
    return s, nil
}
```

### Mulitiple-record SQL queries

Finally, look the pattern for executing SQL statements which return multiple rows -- demonstrate by updating the `SnippetModel.Latest()`method to return the *most recently created* then snippets like:

```sql
SELECT id, title, content, created, expires from Snippets
where expires> UTC_TIMESTAMP() ORDER BY id DESC LIMIT 10
```

Then in the source code `snippet.go`like:

```go
func (m *SnippetModel) Latest() ([]*Snippet, error) {
	// Write the SQL statement want to execute
	stmt := `SELECT id, title, content, created, expires from snippets
		where expires>UTC_TIMESTAMP() ORDER BY id desc LIMIT 10`
	// sue the Query() method on the connection pool to execute our SQL
	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	// defer the rows.Close() to ensure the sql.Rows result set is always
	// closed before the Latest() method returns this defer statement should come
	// after you check for an error from the Query() method
	defer rows.Close() // *Rows struct, should be closed
	snippets := []*Snippet{}

	// then use the rows.Next() to iterate through the rows in the resultset
	// this prepares the first row to be acted on by the `rows.Scan()` method
	for rows.Next() {
		s := &Snippet{}
		// use the rows.Scan() to copy the values from each field in the row
		// the rows.Scan() must be pointers to the place want to copy the data
		err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
		if err != nil {
			return nil, err
		}
		snippets = append(snippets, s)
	}

	// when the rows.Next() loop finished, call the `rows.Err()` to
	// retrieve any error that was encountered during the iteration
	if err = rows.Err(); err != nil {
		return nil, err
	}

	return snippets, nil
}
```

#### Using the model in handlers

then head back to the handlers.go and update the `home`hander to use the `latest()`like:

```go
snippets, err := app.snippets.Latest()
if err != nil {
    app.notFound(w)
    return
}

for _, snippet := range snippets {
    fmt.Fprintf(w, "%+v\n", snippet)
}
```

