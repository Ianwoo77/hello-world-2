# Local Repositories (rec)

- A local repository is a repository that is stored on a computer
- A remote repository is a repository that is hosted on a hosting service

```sh
git init
git init -b main # short for --initial-branch
```

Default Git will create a branch called `master`when initialize a new local repository. And inside the `.git`directory are various files and directories -- Some of them represent the areas of Git that you are going to learn about.

### The Areas of Git

- Working directory
- Staging area
- Commit history
- Local repository

#### Staging Area

Is similar to a rough *draft space* -- Where U can add and remove files, when U are preparing what U want to include in the next saved version of your project.

#### Commit

Basically one version of a project. Can think of it as a snapshot of a project, or a standalone version of a project that contains -- Note that every commit has a *commit hash* -- This is a unique 40-character hash composed of letters and numbers that acts like a name for a commit.

#### Commit History

The *commit history* is where U can think of your commits existing -- It is represent by the `objects`directory inside the `.git`directory.

### Making a Commit

Commit is important cuz it allows U to back up your work and avoid the frustration of losing unsaved work. Once U have makde a commit, that wok is saved, adn you will be able to go back and look at that commit to see what your project looked like at that point in time.

#### The Two Steps

1. Add the files U want to include in the next commit to the staging area
2. Making a commit with a commit message.

```sh
git status # No commits yet
git add <filename>
git add <filename> <filename> ...
git add -A # add all the files in the working directory
```

And to make a commit, will use the `git commit`with `-m`option.

### Viewing a List of Commits

To see a list of commits in the commit history, use the `git log`command -- lists the commits in a local repository in *reverse* chronological order. Note that the full commit hash of the red commit in this -- is ... The commit hash is different version.

```sh
git config --global --list
git config --global user.name "<name>"
git config --global user.email "<email>"
```

------

```sh
git log # show a list of commits in reverse chronlogical order
```

### Branches

There are two main reasons to use branches -- 

- To work on the same project in different ways
- To help multiple people work on the same project at the same time.

Making a commits on a Branch

```sh
git commit -m "orange"
git log
```

Made a new commit, the `orange`-- and in the `rainbow` -- Commit hash will be different. `HEAD->main`appears.

- There is a second commit, orange
- orange point back to the red
- The `main`branch points to the orange.

Can see there is a *gray* arrow pointing from the orange commit back to the `red`. Represents the *parent link*. Every commit, other than the very first one in a repository, has a *parent commit*. -- Some commits can have more than one parent.

To check which commit is the parent of given commit, can use the `git cat-file`command with the `-p`and pass a commit hash (first 7 characters). Note may copy and paste the entire commit hash or just enter the first 7.

```sh
git cat-file -p 7acb333
```

#### Creating a Branch

At the moment, `main`jsut -- to list all like:

```sh
git branch
git branch <new_branch_name>
# ...
git branch feature
git branch # *main
git log
```

Can see that there are now two arrows -- representing the `main`and `feature`branches, pointing to the orange commit. A new branch will initially point to the commit that U were on when U made a branch.

#### What is HEAD

At any given point in time, are looking at a particular version of your project. Therefore, U are on a particular branch which is pointing to a commit -- `HEAD`is simply a pointer that tells U which branch U are on. 

```sh
cd .git
cat HEAD # refs/heads/main
```

#### Switching Branches

To just work on another branch in a Git proj, have to switch onto the branch -- Another way of saying this in Git -- *checkout* another branch.

```sh
git switch <branch_name>
git checkout <branch_name>
```

Note that the `checkout`command can do more things.

```sh
git branch
git switch feature
git branch # *feature
git log # HEAD->feature
# note that now red and orange both here.
```

#### Working on a Separate branch

```sh
git add readme.md
git commit -m "yellow"
git log
```

## 100 Go rec

- What makes go an efficient, scalable and productive language
- Exploring why go Is simple to learn and hard to master
- Presenting the common types of mistakes made by developers.

### Variable shadowing

The scope of a variable refers to the places a variable can be referenced. The part of an application where a name binding is valid -- In Go, a variable name declared in a block can be re-declared in an inner bolock.

```go
var client *http.Client
if tracing {
    client, err := createClientWithTracing()
    if err != nil {
        return err
    }
    log.Println(client)
}else {
    client, err := createDefaultClient()
    if err != nil {
        return err
    }
    log.Println(client)
}
// Use client
```

Then use `:=`in both inner blocks to assign the result of the function call to the inner `client`variables. As a result *the outer variable is always `nil`*.

```go
var client *http.Client
if tracing {
    c, err := createClientWithTracing()
    if err != nil {
        return err
    }
    client = c
}else {
    // same logic
}

// Second = in inner directly
var client *http.Client
var err error
if tracing {
    client, err = createClientWithTracing()
    if err != nil {
        return err
    }
}else {..}
```

### Using `init`correctly

The potential consequences are poor error management or a code flow is harder to understand. 

#### Concepts

An `init`is a func used to initialize the state of an app -- takes no args and returns no result -- when a package is initialized -- all the constant and variable declarations in the package are evaluated. like:

```go
var a = func() int {
    fmt.Println("var") // execute first
    return 0
}()
func init() {
    fmt.Println("init") // execute second
}
func main() {
    fmt.Println("main")
}
```

So an `init`function is executed when a package is initialized.

```go
package main
import (
	"fmt"
    "redis"
)
func init() {
    //...
}
func main() {
    err := redis.Store("foo", "bar")
}
////////////////////////////
package redis
func init(){
    //...
}
func Store(key, value string) error {...}
```

Here, Cuz `main`depends on `redis`, and the `redis`'s `init`is executed first, followed by the `init`of the `main`package, and then the `main`function itself.

Can define *multiple* `init`per package, the execution order of the `init`inside the package is based on the source files’ alphabetical order.

Shouldn’t rely on the ordering of `init`functions within a package. Can also define multiple `init`in the same source file -- The first `init`executed in the source order.

Can also use `init`for side effects -- define a `main`that doesn’t have a strong dependency on `foo`. Fore:

```go
package main
import (
	"fmt"
    _ "foo"
)
```

For this the `foo`is initialized before the `main`. Another aspect of an `init`is that it can’t be invoked directly fore:

```go
func init()
func main() {init()} // error
```

1. Dependency management -- 

   - If `init()`in different packages have dependencies on one another, might run into initialization order problems, leading to `nil`pointer dereferences or other initialization errors
   - Design your packges to minimize inter-package `init()`dependencies.

   - Ignoring Errors -- Not handling or checking for errors within an `init()`-- Since `init()`cannot return values, any errors it might produce are typically ignored or require global error handling mechanisms
   - Misuse -- Having `init()`produce side effects can make unit tests unpredictable or hard to mange cuz `init`will run before each test in the package.

2. For testable code, avoid side effects in `init`.

3. Performance impact --

   - Misuse -- Multiple inefficient `init`can degrade the performance
   - Benchmark `init`if suspect they might be impacting performance.

4. Confusion with ctors-- 

   - Expecting `init()`to work like a ctor in OO
   - In Go, if need ctor-like behavior, defined `New...`functions

5. Global State Mutation -- 

   - Using `init()`to mutate global state
   - Should limit state changes in `init()`.

#### When to use `init`functions

Where using an `init`function can be considered inappropriate-- Holding a dbs connection pool fore - in the `init`open a dbs using `sql.Open()`-- make this dbs a global variable that other functions later use fore:

```go
var db *sql.DB
func init(){
    dbSourceName=os.Getenv("...")
    d, err := sql.Open("mysql", dbSourceName)
    if err != nil {
        log.Panic(err)
    }
    err = d.Ping()
    if err != nil {
        log.Panic(err)
    }
    db = d
}
```

In this, open the dbs, check whether we can ping it -- and then assign it to the global variable. What should we think about this imp -- 

1. Error management in an `init`is limited, as an `init`doesn’t return an error -- one of the only ways to signal error is to panic -- leading the app to be stopped. It shouldn’t be necessarily up to the package itself to decide whether to stop the app.
2. Another is related to *testing* -- if add tests to this file, the `init`func will be executed before running the test cases. which isn’t necessarily what we want.
3. Example requires assigning the dbs connection pool to a global variable. Global variables have some severe drawbacks, fore -- 
   - Any functions can alter global variables within the package
   - Unit tests can be more complicated cuz a func that depends on a global variable won’t be isloated any more.

For these reasons, the initialization should probable be handled as part of a plain old func.

```go
func CreateClient(dsn string) (*sql.DB, error) {
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

## Using the model in our handlers

Put the `SnippetModel.Get()`method into action -- like:

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id < 1 {
        app.NotFound(w)
        return
    }
    
    snippet, err := app.snippets.Get(id)
    if err != nil {
        if errors.Is(err, models.ErrNoRecord) {
            app.NotFound(w)
        }else {
            app.serveError(w, err)
        }
        return
    }
    //...
}
```

#### Checking for specific errors

Used the `errors.Is()`func to check whether an error matches a specific value like: 
`if errors.Is(err, models.ErrNoRecord){...}`

Prior to Go 1.13, the idiomatic way to do this was to use the `==`to perform check like:
`if err == models.ErrNoRecord {...}`

Shorthand for single-record queries -- In practice, Can shorten the code slightly by leveraging the fact that errors from `DB.QueryRow()`are deferred until `Scan()`is called -- 

```go
func (m *SnippetModel) Get(id int) (*Snippet, error) {
    s := &Snippet{}
    err := m.DB.QueryRow("select...", id).Scan(&s.ID, &s.Title, &s.Content, &s.Content,
                                              &s.Created, &s.Expires)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrNoRecord
        }else{
            return nil, err
        }
    }
    return s, nil
}
```

### Multiple-record SQL queries

Look at the pattern for executing SQL statements which return rows -- like:

```go
func (m *SnippetModel) Latest() ([]*Snippet, error) {
	// Write the SQL statement want to execute
	stmt := `SELECT id, title, content, created, expires FROM snippets
		where expires> UTC_TIMESTAMP() ORDER BY id DESC LIMIT 10`

	// Use the Query() method on the connection pool to execute our SQL
	// This returns a sql.Rows resultset
	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	// defer rows.Close() to ensure that sql.Rows result set is always
	// properly closed before the `Latest()` method returns
	defer rows.Close()

	snippets := []*Snippet{}

	for rows.Next() {
		s := &Snippet{}
		err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
		if err != nil {
			return nil, err
		}

		// Append it to the slice of snippets
		snippets = append(snippets, s)
	}

	// When the rows.Next() loop has finished call rows.Err() to retrieve
	// any error that was encountered during the iteration
	if err = rows.Err(); err != nil {
		return nil, err
	}

	// If every ok
	return snippets, nil
}
```

#### Using the model in our handlers

Head back to go file and update the `home`handler to use the `SnippetModel.Latest()`method, dumping the snippet contents to a HTTP response. For now just comment out the code relating to template rendering.

```go
snippets, err := app.snippets.Latest()
if err != nil {
    app.serverError(w, err)
    return
}

for _, snippet := range snippets {
    fmt.Fprintf(w, "%+v", snippet)
}
```