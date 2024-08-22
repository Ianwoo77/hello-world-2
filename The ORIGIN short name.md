# The `ORIGIN` short name

The local repository must have a connection with a shortname to the remote repository stored within it. To work with the remote repostiory, had to explicitly associate its URL with a shortname using the `git remote add <shortname> <URL>`command. This is because created the `rainbow`locally using the `git init`command. This means that the `friend-rainbow`already has the remote repository URL assocaited with the shortname `origin`.

Under `friend-rainbow`, using `git remote`-- saw that you already have the `origin`shortname listed. means that it has remote repository URL -- cuz did not locally for your friend -- It was directly cloned from a remote repository. And `origin`is the deafult shortname Git associates with a remote repository when you clone it.

### Deleting Branches

The main reason to delete branches is to keep a Git project organized and uncluttered. Fore don’t need the `feature`branch for friend. To fully delete a branch, need to delete the remote branch, and the remote-tracking branch, and local branch -- Note to delete a remote branch and a remote-tracking branch, use the:
`git push <shortname> -d <branch_name>`command.

```sh
git branch --all
git push origin -d feature # delete feature remote version
git branch --all # now *feature
git switch main
git branch -d feature # delete local feature
```

### Git Collaboration and Branches

Teams also may have rules about how to manage branches -- 

- Which branches are allowed to be merged into one another
- When branches need to be created
- What the review process for work on a branch should be.

An example of a rule that you may encounter in a Git project is that individuals should work only on their own topic branches and avoid working on other people’s topic branches. Keep in mind that you may set or encounter different branching rules in future Git projects that you work on.

#### Making a Commit in the local repository

Fore, your friend is going to add a note the color green to the `md`file and make a commit on the `main`of their local repository.

```sh
git commit -m "green-main"
```

The origin/main -> yellwo, and the local Head->Main->Green. As can see the green commit doesn’t yet appear in the `rainbow-remote`repository. -- This is just cuz remote repositories does not updte automatically -- work done in local repositories needs to be explicitly pushed to them.

Notice also that `origin/main`remote-tracking branch still points to the yellow commit. This is cuz -- remote-tracking branches represent the state of remote branches Since firend has not yet pushed their changes to the remote repository -- the remote `main`has not updated

At this point there is no way for U to have the new commit in the `rainbow`repostiory. Two steps -- 1, the local with the changes has to explicitly push those changes to a remote repository, 2, then the local repository without changes has to explicitly `fetch`and *integrate* the changes from the remote.

#### Pushing to the remote

Git needs some way to know which remote branch you want to push to. If the local branch has an upstream branch defined for it, can use the `git push`with no arguments and Git will automatically push the work to that branch. And, note that the last time U used the `git push`command in the `rainbow`repository, passed in the shortname and the branch name. This was cuz U had not defined an upstream branch for local branch.

Note -- *When U clone a repository, upstream branches **automatically** set up.*

And the command to use to see whether upstream branches are defined is `git branch`with the `-vv`, for *very verbose* -- For this, there are two main benefits to defining upstream branches -- 

1. If have *fetched* (download) the remote repository commits, U can check if your repository is ahead of or behind the remote repository by using either `git branch -vv`or the `git status`.
2. Can simplify the commands U use with the remote repository cuz U don’t need to specify the branch name and remote repository shortname. Fore, can use the `git push`command on its won without passing any arguments.

Since just cloned repository -- 

`git branch -vv`output shows that the upstream set up for the local is the remote `main`in the remote with shortname `origin`and that the local `main`is already one commit. And the `git status`also indicates that the local `main`is ahead of the `origin/main`upstream branch by one commit.

Then just noticed that the `rainbow`repository does not yet have the green commit.

### Incorporating Changes from the Remote Repository

Fetching changes from the remote -- In Git -- use the term *fetch* or *fetching* to refer to the process of downloading data from a remote repository to a local repository. The `git fetch`command downloads all the necessary commits to update all the remote-tracking branches in the local repository to reflect the state of the remote branches.

```sh
git fetch <shortname>
git featch
git log --all # local main still pointing to the previous commit
```

Now the `main`and `feature`points to last and origin/main points to Green.

Saw how the `git fetch`updated the remote-tracking branches in the local for any remote branches that exist in the remote repository.

#### Integrating Changes into a local branch

For now, to integrate the commits were on the `main`in the remote into your local `main`, will just use the `git merge`.

## Possible side effects with string formatting

Foratting strings is a common operations for developers, whether to return an error or log message. It’s pretty easy to forget the potential side effects of string formatting while working in a concurrent application.

#### etcd data race

etcd is a distributed k-v store implementation in Go -- used in many projects. To store all cluster data. Provides an API to interact wtih a cluster.

#### Deadlock

```go
type Customer struct {
    mutex sync.RWMutex
    id string
    age int
}

func (c *Customer) UpdateAge(age int) error {
    c.mutex.Lock()
    defer c.mutex.Unlock()
    if age<0 {
        return fmt.Errorf("... %v", c)
    }
    c.age= age
    return nil
}

func (c *Customer) String() string {
    c.mutex.RLock()
    defer c.mutex.RUnlock()
    return fmt.Sprintf("id %s, age %s", c.id, c.age)
}
```

#### Thread communication using memory sharing

Communication via memory sharing is like trying to talk to a friend, but instead of exchanging messages, using a whiteboard and exchanging ideas, symbols, and abstractions -- In concurrent programming using memory sharing, allocate a part of the process’s memory -- a shared data structure or a variable.

For this, if the provided `age`is negative -- returns an error. And cuz the error is just formatted, using the `%s`on the receiver, it will call the `String()`method to format `Customer`. But, cuz `UpdateAge`already acquires the mutex lock, the `String()`won’t be able to acquire it.

Hence, if the age < 0, then this leads to a deadlock situation. If all goroutines are also asleep, it leads to a panic. Note that for this - illustrates how unit testing is important -- without proper test *coverage*, we might just miss this issue.

One thing that could be improved here is to restricting the scope of the mutex locking -- in `UpdateAge()`-- we first qcquire the lock and check whether the input is valid -- should do the opposite. First check the input, and if the input is valid, acquire the lock. This has the benefit of reducing the potential side effects but can also have an impact performance. like:

```go
func (c *Customer) UpdateAge(age int) error {
    if age < 0 {
        return fmt....
    }
    c.mutex.Lock()
    defer c.mutex.Unlock()
    c.age= age
    return nil
}
```

In the case, locking the mutex only after the age has been checked avoids the deadlock situation. In these conditions, have to extremely careful with string fomratting.

```go
// For this, no deadlock only log id
func (c *Customer) UpdateAge(age int) error {
    c.mutex.Lock()
    defer c.mutex.Unlock()
    if age <0 {
        return fmt.Errorf("age should be positive for customer id %s", c.id)
    }
}
```

For this, have seen two concrete examples, one formatting a key from a context and another returning an error that formats a struct -- in both cases, formatting a string leads to a problem -- a data race and a deadlock situation, respectively -- therefore, in concurrent apps, should remain cautions about the possible side effects of string formatting.

### Creating data races with `append`

We mentioned earlier what a data race is and what the impacts are -- Look at slices and whether adding an element to a slice using `append`is data-race-free. It depends -- will initialize a slice and create two gorotuines that will use `append`to create a new slice with an additional element -- like:

```go
s := make([]int, 1)
go func() {
    s1 := append(s, 1)
    fmt.Println(s1)
}()
go func() {
    s2 := append(s,1)
    fmt.Println(s2)
}()
```

A slice is just backed by an array and has two properties -- length and capacity. The length is the the number of available elems in the slice, whereas the cap is just the total number of elemetns in the backing array. When using `append`the behavior depends on whether the slice is full fore -- `length==capacity`. If it is, the Go runtime creates a new backing array to add the new element. For this -- `make([]int, 1)`-- one len, one cap. For this, is already full. `append`in each operation returns a `slice`backed by a *new* array. Doesn’t mutate the existing array.

So, for this, It doesn’t mutate the existing array, hence, it doesn’t lead to a data race. If:

`s := make([]int, 0, 1)` -- reduces data race -- therefore, the array isn’t full -- both goroutine attempt to update the same `index`of the backing array -- which is a data race. Can prevent the data race if we want both goroutines to work on a slice containing the initial elements of s plus an extra element -- like:

```go
s := make([]int, 0, 1)
go func(){
    sCopy := make([]int, len(s), cap(s))
    copy(sCopy,s)
    s1 := append(sCopy, 1)
    fmt.Println(s1)
}()
//.. same logic
```

Both goroutines make a copy of the slice -- then they use `append`on the slice copy, not the original slice.

#### Data races with slices and maps

How much do data races impact slices and maps -- when we have multiple goroutines the following is true -- 

- Accessing the same slice index with at least goroutine updting the value
- Accessing different regardless of the op isn’t a data race
- Accessing the same map with at least one goroutine updating it is a data race.

### Using mutexes inaccurately with slices and maps

While working in concurrent contexts where data is both mutable and shared, we often have to implement protected accesses around data structures using mutexes. A common mistake is to use mutexes inaccurately when working with slices and maps. fore, will implement a `Cache`struct used to handle caching for customer balances -- 

```go
type Cache struct {
    mu sync.RWMutex
    balance map[string]float64
}
```

Then add an `AddBalance`method that mutates the `balance`map -- the mutation is done in a critical section like:

```go
func (c *Cache) AddBalance(id string, balance float64) {
    c.mu.Lock()
    c.balance[id]= balance
    c.mu.Unlock()
}
```

Meanwhile, have to implement a method to calcuate the average balance for all the customers.

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock() // handle a minimal cs
    balances := c.balances
    c.mu.RUnlock()
    
    sum := 0
    for _, balance := range balances {
        sum+= balance
    }
    return sm/float64(len(blanances))
}
```

Note that only the copy operation is done in the CS to iterate over each balance and calculate the average outside of the CS -- Here, dta race occurs.

Internally, a map is a `runtime.hmap`structure containing mostly metadata and a pointer referencing data buckets. And a pointer referencing data buckets -- so -- `balances := c.balances`doesn’t copy the actual data, same principle with a slice -- 

If the iteration operation isn’t heavy -- should protect the whole function -- like:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    defer c.mu.RUnlock()
    //...
}
```

The CS now encompasses the whole function, including the iterations.

Another option, if the iteation operation isn’t lightweight, is to work on an actual copy of the data and protect only the copy like:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    m := make(map[string]float64, len(c.balances))
    for k, v := range c.blances {
        m[k]=v
    }
    c.mu.RUnlock()
    //...
}
```

For this, have to iterate twice on the map values. But the CS is only the map copy -- Therefore, this solution can be a bood fit if and only if an operation isn’t *fast*.

## Dispalying errors and repopulating fields

If there are any validation errors want to re-display the HTML form, hightlighting the fields which failed validation and automatically re-populating any previous submitted data.

```go
type templateData struct {
    CurrentYear int
    Snippet *models.Snippet
    Snippets []*models.Snippet
    Form any
}
```

Will use this `Form`field to pass the validation errors and perviously submitted data back to the template when we re-display the form.

```go
// Define a snippetCreateForm struct to represent the form data and validation errors for the form fields.
// All the fields are deliberately exported.
type snippetCreateForm struct {
    Title, Content string
    Expires int
    FieldErrors map[string]string
}

func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    //...
    // Create an instance of the snippetCreateForm
    form := snippetCreateForm {
        Title: r.PostForm.Get("title"),
        Content: r.PostForm.Get("content"),
        Expires : expires,
        FieldErrors : map[string]string{},
    }
    
    //... If there are any validation errors re-display the create template
    // and passing in the instance as dynamic dta in the `Form`field
    if len(form.FieldErrors)>0 {
        data := app.newTempalteData(r)
        data.Form =form
        app.render(..., "create.html", data)
        return
    }
}
```

```go
package main

import (
	"database/sql"
	"flag"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"net/http"
	"os"
	"snippetbox2/internal/models"
)

type application struct {
	errorLog *log.Logger
	infoLog  *log.Logger
	snippets *models.SnippetModel
}

func main() {
	addr := flag.String("addr", ":4000", "HTTP network address")
	dsn := flag.String("dsn", "web:pass@/snippetbox?parseTime=true", "MySQL data source name")

	flag.Parse()
	infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)
	errorLog := log.New(os.Stderr, "ERROR\t", log.Ldate|log.Ltime|log.Lshortfile)

	db, err := openDB(*dsn)
	if err != nil {
		errorLog.Fatal(err)
	}

	defer db.Close()

	app := &application{
		errorLog: errorLog,
		infoLog:  infoLog,
		snippets: &models.SnippetModel{DB:db},
	}

	srv := &http.Server{
		Addr:     *addr,
		ErrorLog: errorLog,
		Handler:  app.routes(),
	}

	infoLog.Printf("Starting server on %s", *addr)
	err = srv.ListenAndServe()
	errorLog.Fatal(err)
}

func openDB(dsn string) (*sql.DB, error) {
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

```go
func (app *application) routes() *http.ServeMux {
	mux := http.NewServeMux()

	fileServer := http.FileServer(http.Dir("./ui/static/"))
	mux.Handle("/static/", http.StripPrefix("/static", fileServer))

	mux.HandleFunc("/", app.home)
	mux.HandleFunc("/snippet/view", app.snippetView)
	mux.HandleFunc("/snippet/create", app.snippetCreate)

	return mux
}
```

```go
func (m *SnippetModel) Get(id int) (*Snippet, error) {
	stmt := `SELECT id, title, content, created, expires FROM snippets
    WHERE expires > UTC_TIMESTAMP() AND id = ?`
	row := m.DB.QueryRow(stmt, id)

	s := &Snippet{}

	err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, models.ErrNoRecord
		} else {
			return nil, err
		}
	}
	return s, nil
}

func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		app.notFound(w) // Use the notFound() helper.
		return
	}

	snippet, err := app.snippets.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w)
		} else {
			app.serverError(w, err)
		}
		return
	}
	fmt.Fprintf(w, "%+v", snippet)
}
```

