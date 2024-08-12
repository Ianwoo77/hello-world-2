# Git Branches

To focus on the commit history, going to introduce a new diagram called *Repository Diagram*. Includes only a representation of the commit history of repository and relevant branches and references.

- To work on the same project in different ways
- To help multiple people work on the same project at the same time.

Can just think of a branch like a line of development. A Git project can have multiple branches -- Each of these is a standalone verion of the project. Different Git project can use branches in different ways.

One common pattern for working with branches is to have one official primary line of development -- the main or primary and off of that to create secondary branches. Called *topic branches* or *feature branches*. Are used to work on just a specific part of the project.

These topic branches are short-lived, they are ultimately combined or incorporated back int the primary branche and then deleted.

#### What are exactly are Branches in Git

Are moveable pointers to *commits*. When list the commits in a local repostiory using `git log`command, can see info about which branches point to which commits.

- In the `git log`output, next to the commit hash inside the `(HEAD-> main)`-- The branch or branches that appear inside the `()`next to a particular commit hash in the `git log`output are the branches that point to that commit.
- In the `.git>refs>heads>main`file, will see the commit hash for the `red`commit in repository.

#### Master and Main

Just `git init`, will create a branch called just `master`-- is not considered inclusive terminology, using `main`. `git init -b`option. The acutal word `main`is not special in anyway.

#### Unmodified and Modified Files

Git knows about the `readme.md`file cuz it has been included in a commit, and there is a tracked file. Tracked file in the working directory can be in one of two states -- *unmodified* in working directory that have not been edited since the last commit, once a file in the working directory has been edited, it becomes a *modified file*. `git status`command shows a list of *modified* files and tells whether or not they have been added to the staging area.

Fore, can see how the file went from being an unmodified file to a modified file when U edit it and saved your changes.

```sh
git add readme.md
git status
```

### Making Commits on a Branch

Are ready to make your second commit in the repostiory.

```sh
git commit -m "orange"
git log
```

What to notice is -- 

- Made a new commit, in the repository in this the commit hash for the orange comit, your commit has will be different.
- The `HEAD-> main`appears in parentheses next to the orange commit.

Notice is

- There is a second commit
- And the second *points back* to the first one.
- And the `main`branch now points to the orange commit

For the gray arrow represents the parent link -- every commit, other than the very first one in a repository, has a parent commit -- the parent commit of the orange commit is the read commit.

To check which commit is the *parent* of a given commit, can use the `git cat-file`comamnd with the `-p`option and pass in a command hash -- like: `git cat-file -p <hash>`.

```sh
git cat-file -p 20e3dff # first 7 character for hash
```

- In the `git cat-file -p`output, can see the next to `parent`it references the commit hash of the red commit in this book.

## Race problems

Race problems can be among the hardest and most insidious bugs as a programmer can face. We must understand crucial aspects such as *data races* and the *race conditions* -- there possible impacts, and how to avoid them.

#### Data race vs Race conditions

First focus on data races -- A data races occurs just when two or more goroutines simultaneously access the same meory location and *at least one is just writing.* fore:

```go
i := 0
go func() {i++}()
go func() {i++}()
```

`go run . -race` then wans. -- What is the issue with this is the `i++`statement can be decomposed into 3 operations: (1) read i, (2) increment, (3) write back. There is no guarantee that the first will either start or complete before the second in the previous example. Can also face the case of an interleaved execution both goroutines run concurrently and complete to access i.

Look at some different techniques -- *Atomic* operations can be done in Go using the `sync/atomic`package fore:

```go
var i int64
go func(){
    atomic.AddInt64(&i, 1)
}
go func() {
    atomic.AddInt64(&i, 1)
}
```

Both goroutines update `i`automatically -- An atomic operation can’t be intrrrupted -- thus preventing two accesses at the same time -- Regardless of the goroutine’s execution order. Another option is to synchronize the two goroutines with an ad hoc data structure like a mutex -- *Mutex* stands for mutual exclusion, A mutex ensures that at most one goroutine accesses a so-called critical section -- 

```go
i :=0
mutex := sync.Mutex{}
go func() {
    mutex.Lock()
    i++
    mutex.Unlock()
}
```

The boundary is pretty straightforward, -- the `sync/atomic`pckage works only with specific types. Another option is to prevent sharing the same memory location and instead favor communication access the goroutines. Fore:

```go
i :=0
ch := make(chan int)
go func() {
    ch<-1
}()
go func() {
    ch<-1
}
i+= <-ch
i+= <-ch
```

For each goroutine sends a notifiction via the channel that we should increment i by 1, the parent goroutine collects the notifications and increment `i`.

Sum up what we have seen so for -- Data Races occur when multiple goroutines access the same memory location simultaneously and at least one of them is writing. But, depending on the operation we want to perform, does a data-race-free app necessarily mean a deterministic result? Instead of having two goroutine increment a shared variable, now each one makes an assignement -- will follow the approach of using a mutex to prevent data races -- 

```go
i := 0
mutex := sync.Mutex{}

go func() {
    mutex.Lock()
    defer mutex.Unlock()
    i =1
}()

go func() {
    mutex.Lock()
    defer mutex.Unlock()
    i=2
}()
```

For this, the first goroutine assigns 1 to i and .. 2 -- There is **NOT** a *data race* here -- both goroutines access the same variable, but not at the same time -- as the mutex protects it. -- but, this example is not deterministic -- Depending on the execution order, will eventually 1 or 2. This example doesn’t lead to data race -- but has a *race condition* -- A race condition occurs when the behavior depends on the sequence or the timing of events that can’t be controlled.

Ensuring a specific execution sequence among goroutine is a question of coordination and orchestration. We should find a way to guarantee that the goroutines are executed in order. Channels can be a way to solve this problem. Coordinating and orchestrating can also ensure that a particular section is accessed by only one goroutine, which can also mean remiving the mutex.

A data race occurs when multiple goroutings simultaneously access the same memory location and at least one of them is writing. A data race means upexpected behavior. 

And a data-race-free app doesn’t necesarily mean deterministric resutls. An app can be free of data races but still have behavior that depends on uncontrolled events -- this is the race condition.

#### The Go Memory Model

There are some core principles we should be aware as Go developers. Fore, buffered and unbuffered channels offer differ guarantees. To avoid unexpeceted races caused by a lack of understanding of the core specifications of the language, have to look at the Go memory model.

Is a specification that defines the conditions under which a read from a variable in one goroutine can be guaranteed to happen after a write to the same variable in a different goroutine. It just provides guarantees that developers should keep in mind to avoid data races and force deterministic output.

Namely, within multiple goroutiens, should bear in mind some of these guarantees.

- Creating a goroutine happens before the goroutin’s execution begins

- The exit of a goroutine isn’t guaranteed to happen before any event.

  ```go
  i :=0
  go func() {i++}()
  fmt.Println(i) // has a data race
  ```

- A send on a channel happens before the corresponding receive from that channel completes. fore:

  ```go
  i :=0
  ch := make(chan struct{})
  go func(){
      <-ch
      fmt.Println(i)
  }()
  i++
  ch <- struct{}{}
  // increment <- ch send <- ch receive <- var read
  ```

- Closing a channel happens before receive of this closure -- similar to previous, except that instead of sending a message close the channel like:

  ```go
  i := 0
  ch := make(chan struct{})
  go func(){
      <-ch
      fmt.Println(i)
  }()
  i++
  close(ch) // also free from data races
  ```

- regarding channels may be counterintuitive -- A receive from an unbuffered happens *before* the send on that channel completes.

  ```go
  // buffereed instead of an unbuffered one
  i :=0
  ch := make(chan struct{},1)
  go func() {
      i=1
      <-ch
  }()
  ch <- struct{}{}
  fmt.println(i)
  ```

  Just need to note this will lead to a data race -- Both read and write to `i`may occur simultaneously.

  ```go
  // make a change
  i := 0
  ch := make(chan struct{})
  go func(){
      i = 1
      <-ch // happen first block
  }()
  ch <- struct{}{}  // send unblock that
  fmt.Println(i) // so i is just 1
  ```

  This is *data-race-free* cuz, can see the main difference -- the write is guaranteed to happen before the read. They represent the ordering guarantees of the Go Memory model. Cuz *a receive from an unbuffered channel happens before a send*, the write to `i`will *always* occur before the read.

### Understanding the concurrency impacts of a workload type

Depending on whether a workload is CPU- or I/O bound, may need to tackle the problem differently.

- *The speed of the CPU* -- CPU bound
- *The speed of the I/O* -- making a REST all or dbs query.
- *The amount of available memory* -- *memory-bound*

It’s just important to classify a workload in the context of a concurrent app -- Understand one concurrency pattern -- worker pooling -- The following implements a `read`func that accepts an `io.Reader`and reads 1024 bytes form it repeatedly. Just like:

```go
func read(r io.Reader) (int, error) {
    count := 0
    for{
        b := make([]byte, 1024)
        _, err := r.Read(b)
        if err != nil {
            if err == io.EOF{
                break
            }
            return 0, err
        }
        count += task(b)
    }
    return count, nil
}
```

Func just creates a `count`variable, reads from the `io.Reader`input call `task`and increments `count`, now what if we want to run all the `task`functions in parallel manner -- One option is to use so-called *worker-polling* pattern - doint so involves creating workers of a fixed size that poll tasks from a common channel.

First, spin up a fixed pool of goroutine. Then create a shared channel to whcih we publish tasks after each red to the `io.Reader`-- Each goroutine from the pool receives from this channel, performs its work, then atomically updates a shared counter.

```go
func read(r io.Reader) (int, error) {
	var count int64
	wg := sync.WaitGroup{}
    
    // use n to define the pool sie
	var n = 10
	ch := make(chan []byte, n)
	wg.Add(n)
    
    // iterate n times to create a new goroutine that receives from the shared channel
    // each received is handled by executing task and incrementing the shard counter atomically
	for i := 0; i < n; i++ {
		go func() {
			defer wg.Done()
			for b := range ch {
				v := task(b)
				atomic.AddInt64(&count, int64(v))
			}
		}()
	}

	for {
		b := make([]byte, 1024)
		// red from r to b
		ch <- b
	}
	close(ch)
	wg.Wait()
	return int(count), nil
}
```

What should be the value of the *pool size -- the answer depends on the workload type*. So, if the workload is I/O bound, the answer mainly depends on the  external system. Namely, how many concurrent accesses can the system cope with if want to *maximize* throughput.

And if is *CPU-bound*, the best practice is to rely on `GOMAXPROCS.GOMAXPROC`is a avaible that sets the number of OS threads allocate to running goroutines. By dfeault, this value is set to the number of logical CPUs.

When implementing the worker-pooling pattern, have seen that the optimal number of goroutines in the pool depends on the workload type.

## Installing a dbs driver

To use MySQL from our Go app need to install a *database driver*. This essentially acts as a middleman, translating commands between Go and MySQL dbs itself.

```sh
go get github.com/go-sql-driver/mysql
```

### Modules and reproducible builds

Take a look at the `go.mod`file, should see a new `require`line containing the package path and exact version number of the driver which was downloaded.

- if run the `go mod verify`command from ternimals, this will verify that the checksums of the downloaded packages on your machine match the entries.
- If someone else needs to download all the dependencies for the proj -- which they can do by running `go mod downloaded`

In summary:

- Can run the `go mod download`to download the exact version of all the packages that your proj needs
- Can run the `go mod verify`to ensure that nothing in those downloaded packages has been changed unexpectedly
- Whenever U run `go run, go test`or `go build`, the exact package versions listed ni `go.mod`will always be used.

#### Additional info

Upgrading packages -- Once a package has been downloaded and added to your `go.mod`file the package and version are *fixed* -- but there are many reasons why U might want to upgrade to use a newer version of a package in the future. Just like:

```sh
go get -u github.com/foo/bar
# can also upgrade to a specific version
go get -u github.com/foo/bar@v2.0.0
```

Removing unused packages -- sometimes might `go get`a package only to realize later that you don’t need it anymore. could either run `go get`nad postfix the package path with `@none`.

```sh
go get github.com/foo/bar@none
```

Or, if you have removed all references to the package in your code, you could run `go mod tidy`-- which will automatically remove any *unused* from your `go.mod`.

```sh
go mod tidy -v
```

### Creating a dbs connection pool

Now that the MYSQL dbs is all set up and we’ve got a diver installed, the natrual next step is to connect to the dbs from our web app -- To do so, need `sql.Open()`function like:

```go
// The sql.Open() function initialize a new sql.DB object, which is essentially a pool of dbs connection
db, err := sql.Open("mysql", "web:pass@/snippetbox?parseTime=true")
if err != nil {...}
```

- The first parameter to the `sql.Open()`is the driver name and the second is the *data source name* which describes how to connect to your dbs
- The format of the data source name will depend on which dbs and driver you are using. Typically, can find info.
- The `parseTime=ture`part of the DSN above is a *driver-specific* parameter which **instructs our driver to convert SQL `Time`and `Date`fileds to Go’s `time.Time`objects**.
- The `sql.Open()`returns a `sql.DB`object -- this isn’t a dbs connection -- **it’s a *pool* of many connections**. This is an important difference to understand. Go manages connections in this pool as needed, automatically opening and closing conenctions to the dbs via the driver.
- The connection pool is *safe* for concurrent access
- The conneciton pool is intended to be long-lived. In a web app it’s normal to initialize the conenction pool in `main`function and then pass the pool to your handlers. U shouldn’t call `sql.Open()`in a short-lived handler.

#### Usage in web app

```go
import (
	//...
    
    _ "github.com/go-sql-driver/mysql"
)

func main(){
    addr := flag.String("addr", ":4000", "HTTP network address")
    dsn := flag.String("dsn", "web:pass@/snippetbox?parseTime=true", "MySQL data source name")
    flag.Parse()
    infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)
    errorLog := log.New(os.Stderr, "ERROR\t", log.Ldate|log.Ltime|log.Lshortfile)
    
    // To keep the main tidy, put this code for creating a connection pool
    // into the separate openDB() function
    db, err := openDB(*dsn)
    if err != nil {
        errorLog.Fatal(err)
    }
    
    // Aslo defer a call to db.Close
    defer db.Close()
    
    app := &application {
        errorLog: errorLog,
        infoLog: infoLog,
    }
    srv := &http.Server {
        Addr: *addr,
        ErrorLog: errorLog,
        Handler: app.routes()
    }
    
    infoLog.Printf(...)
    
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

Noticed how the `import`path for our drivers is prefixed with an underscore -- this is cuz our `main.go`file doesn’t actually use anything in the `mysql`package. We just need the dirver’s `init`func to run so that it can register itself with the `database/sql`package.

And the `sql.Open()`func doesn’t actually create any connections. All it does is initialize the pool to future use. Actual connections to the dbs are established lazily, as and when needed for the first time. So to verify that everything is set up correctly ned to use the `db.Ping()`method to create a connection and check for any errors.

And including the `db.Close()`is just a good habit to get into and it could be beneficial later.

### Designing a dbs model

Going to sketch out a dbs model -- Think of a *service layer* or *data access layer* instead -- the idea is that we will encapsulate the code for working with MySQL in a separate package to the rest of our application. 

```sh
cd $HOME/code/snippetbox
mkdir -p internal/models
touch internal/models/snippets.go
```

Remember that the `internal`directory is being used to hold ancillary non-application-specific code, which could potentially be reused like:

```go
// Define a Snippet type to hold the data for an individual snippet
package models
 
// ...

type Snippet struct {
    ID int
    Title, Content string
    Created, Expires time.Time
}

// Then define a SnippetModel which wraps a sql.DB conenction pool
type SnippetModel struct {
    DB *sql.DB
}

// some op
func(m *SnippetModel) Insert(title, content string, expires int)(int error) {
    //...
}
func (m *SnippetModel) Get(id int) (*Snippet, error) {
    //...
}
func (m *SnippetModel) Latest()([]*Snippet, error) { // for 10 most recently created snippets.
    //...
}
```

#### Using the `SnippetModel`

To use this model in the handlers, need to establish a new `SnippetModel`in the main and then **inject** it as a dependency via the `application`struct.

```go
type application struct {
    //...
    snippets *models.SnippetModel
}

func main(){
    //...
    // initialize a models.SnippetModel and add it to the app
    app := &application {
        //...
        snippets: &models.SnippetModel{DB: db},
    }
}
```

Additinal Info -- benefits of this structure -- 

- There is a clean separation of concerns, Our dbs logic isn’t tied to our handlers which means that handler responsibilities are limited to HTTP stuff. This will make it easier to write tight, focused, unit tests.
- By creating a custom `SnippetModel`type and implementing methods on it we have been able to make our model a single neatly encapsulated object. Can easily initialize and then pass to our handlers as a dependency.
- Cuz the model actions are defined as methods on an object, in our case `SnippetModel`there is the opportunity to create an *interface* and mock it for unit testing purposes.
- Have total control over which dbs is used at runtime. dsn command-line.

# Cascade, Specificity and inheritance

Fundamentally, cSS is about declaring rules, under various conditions, you want certain things to happen. This process is usually straightforward -- As stylesheet grow, or the number of pages U apply it to increases, your code can become complex surprisingly quickly. There are often several ways to accomplish the same thing in CSS. Depending on which solution you use.

```css
h1{
  font-family: Serif;
}

#page-title {
  font-family: sans-serif;
}

.title {
  font-family: monospace;
}
```

```html
<header class="page-header">
    <h1 id="page-title" class="title">Wombat Coffee Roasters</h1>
    <nav>
        <ul id="main-nav" class="nav">
            <li><a href="/">Home</a></li>
            <li><a href="/coffees">Coffees</a></li>
            <li><a href="/brewers">Brewers</a></li>
            <li><a href="/specials" class="featured">Specials</a></li>
        </ul>
    </nav>
</header>
```

Rulesets with conflicting declarations can appear one after the other, or they can be scattered throughout your stylesheet. All three rulesets attempt to set a different font familty to this heading.

This set of rules is called *cascade* -- It determines how conflicts are resovled, and it’s a fundamental part of how the language works. When declarations conflict, the cascade considers 6 criteria in the following order to resolve the difference, will look at each of these -- 

1. *Stylesheet origin* -- where the styles come from, applied in conjunction with the browser’s default styles.
2. *Inline styles* -- whether a declrations is applied to an element via the HTML `style`
3. *Layer* -- can be defined in layers
4. *Selector specificity* -- which selectors take precedence over which
5. *Scope proxmity* -- whether the styles are scoped to portion of the DOM
6. *Source order* -- order in which styles are declared in the stylesheet.

These allow browsers to behave predictably when resolving any ambiguity in the CSS. Fore the `#page-title`selector received precedence over the other selectors due to these rules.

#### Stylesheet Origin

The styles U add to your page are just called *author* styles, and the browser’s default -- *User-agent* -- have lower priority, so author overrides them.

user-agent styles -- A number of other things are determined by the user-agnet styles -- fore, list has a left paddinga and a `list-style-type`of `disc`to produce the bullets. Then in the following, removed the conflicting `font-family`:

```css
h1 {
  color: #2f4f4f;
  margin-bottom: 10px;
}

#main-nav {
  margin-top: 10px;
  list-style: none;
  padding-left: 0;
}

#main-nav li {
  display: inline-block;
}

#main-nav a {
  color: white;
  background-color: #13a4a4;
  padding: 5px;
  border-radius: 2px;
  text-decoration: none;
}
```

#### important declarations

fore `color: red !important;`this is treated as a higher-priority origin, so they will always override normal styles from origin.

#### Inline styles

If conflicting declration can’t be resolved based on their origin, the borwser next considers whether they are added to an element via inline styles.

```html
<li><a href="/specials" class="featured"
          style="background-color: orange;">Specials</a></li>
```

#### Selector Specificity

*Specificity* is a feature of CSS that is often not readily apparent when learning. Fore:

```css
#main-nav a {...} /* higher-specificity selector */
.featured {
    background-color: orange; /* won't override the upper */
}
```

Different types of selectors also have different specificaties. An ID selector has a higher specificty than a class selector, fore, in fact, a single ID has a higher specificity than a selector with any numbe of classes. IDs > Classes > Tags. For this, the quickest fix is to add an `!important`to the declaration you want to favor. fore:

```css
.featured {
    background-color: orange !important;
}
```

Works cuz the `!important`annotation raises the declaration to a higher priority origin. Can find a better way -- instead of trying to get around the rules of selector specificity, try to make them work for us.

```css
#main-nav .featured {
    /* 1,1,0 */
    background-color: orange;
}
```

#### Source order

The final step to resovling the cascade is source order -- *order of appearance*. If all other criteria are the same, then the declaration that appears later in the styles win.

link styles and source order -- Like:

```css
a:link {
  background-color: blue;
  color: white;
  text-decoration: none;
  padding: 2px;
}

a:visited {
  background-color: purple;
}

a:hover {
  background-color: transparent;
  color: blue;
  text-decoration: underline;
}

a:active {
  color: red;
}
```

Just need to remember the order Link- Visited, Hover and active.

### Inheritance

If an element has no cascaded value for a given property, it may inherit one from an ancestor element. Fore, it’s common to apply a `font-family`to the `<body>`. Note that *not all properties are inherited*.

#### Special values

There are some special values that you can apply to any property to help manipulate the cascade -- `inherit, initial, unset`and `revert`.

`inherit`-- Sometimes, You will want inheritance to take place when a cascaded value is preventing it. To do so, can use the `inherit`, can override another value with this. Fore:

```html
<footer class="footer">
    &copy; 2024 Wombat Coffee Roaster &mdash;
    <a href="/terms-of-use">Terms of use</a>
</footer>
```

```css
.footer {
  color: #666;
  background-color: #ccc;
  padding: 15px 0;
  text-align: center;
  font-size: 14px;
}

.footer a {
  color: inherit; /* specifies that color should inherit from the footer */
  background-color: transparent;
  text-decoration: underline;
}
```

The second ruleset here overrides the link color, giving the link in the footer a cascaded value of `inherit`. The benefit here is that the footer link will change along with the rest of the footer should anything alter it.

`initial`-- Find have styles applied to an element that you want to undo -- as you did with the background color. Can do this by specifying the keyword `initial`. If assign the value `initial`to the prop, then it effectively resets to its default value. like:

```css
.footer a {
  background-color: initial;
  text-decoration: underline;
}
```

`unset`-- the `inherit`and `initial`keywords are useful for clearing values you’ve set on properties that are either inherited or non-inherited. And the `unset`is a combination of the two. When applied to an inherited prop, it sets the value to `inherit`, and when applied to a non-inherited , set the `initial`.

```css
.footer a {
  color: unset; /*sets to inherit*/
  background-color: unset;  /* sets to initial */
  text-decoration: underline;
}
```

`revert`-- The `initial`and `unset`essentially override all styles. Sometimes is to override your previously set author styles but leave the user-agent styles agent.

`text-decoration: revert; /* revert to user-agent styles */`

#### Beware shorthands silently overriding other styles

Fore:

```css
.title{
    font: 32px Helvetica, Arial, sans-serif; /* make the font-style: normal*/
}
```

The order of the shorthand values -- Top right bottom right. Fore:

```css
.nav a {
    padding: 10px 15px 0 5px;
}

.nav a {
    padding: 5px 15px; /* top bottom, followed left/right */
}
```

## Angular projects and tools

```sh
ng new example --routing false --style css --skip-git --skip-tests --standalone false
```

And the `app`folder is where U add the custom code and content for your app.

- `index.html`-- HTML file that is sent to the browser during development
- `main.ts`-- Ts statements that start the app when they are executed

## Starting development

Of the all building blocks in an app, the data model is the one for which Angualr is the least prescriptive. At its heart, the model can be broken into 3 parts -- 

- One or more classes that describe the data in the model
- A data source that loads and saves data, typically to a server
- A repository allows the data to be *manipulated*.

```ts
export class Product {
  constructor(
    public id?: number,
    public name?: string,
    public category?: string,
    public price?: number
  ) {}
}
```

Then a data source provides the app with the data. And the most common type of data source uses HTTP to request data from a web service.

```ts
export class SimpleDataSource {
  private data: Product[];

  constructor() {
    this.data = new Array<Product>(
      new Product(1, "Kayak", "Watersports", 275),
      //...
  }

  get Data(): Product[] {
    return this.data;
  }
}
```

Creating the Model Repository -- The final step to complete the simple model is to define a repository that will provide access to the data from the data source and allow it to be manipulated in the application.

```ts
export class Model {
  private dataSource: SimpleDataSource;
  private products: Product[];
  private locator = (p: Product, id: number | any) => p.id === id;

  constructor() {
    this.dataSource = new SimpleDataSource();
    this.products = new Array<Product>();
    this.dataSource.getData().forEach(p => this.products.push(p));
  }

  getProducts(): Product[] {
    return this.products;
  }

  getProduct(id: number): Product | undefined {
    return this.products.find(p => this.locator(p, id));
  }

  saveProduct(product: Product) {
    if (product.id == 0 || product.id == undefined) {
      product.id = this.generateID();
      this.products.push(product);
    } else {
      let index = this.products.findIndex(p =>
        this.locator(p, product.id));
      this.products.splice(index, 1, product);
    }
  }

  deleteProduct(id: number) {
    let index = this.products.findIndex(p => this.locator(p, id));
    if (index > -1) {
      this.products.splice(index, 1);
    }
  }

  private generateID(): number {
    let cand = 100;
    while (this.getProduct(cand) != null) {
      cand++;
    }
    return cand;
  }
}
```

#### Creating a component and template

```ts
export class ProductComponent {
  private model: Model = new Model();

  get count(): number {
    return this.model.getProducts().length;
  }
}
```

```html
<div class="bg-info text-white p-2">
  There are {{count}} products in the model
</div>
```

### Angular reactivity and Signals

- Understanding the way the Angular responds to changes
- Using the new Angular Signals feature to describe data relationships
- Using writable signals and computed signals for efficient change detection
- Using signals with observable sequences of values

Explain how Angular responds to changes in the app state and update the HTML presented to the user.

- Change detection is the process by which Angular identifies changes in app state and reacts by updating the HTML presented to the user.
- Change detection is the basis by which user interaction or data updates are reflected in the HTML content.

### Angualr data flows

Angular is the bridge between a web app’s data and the HTML content that is presented to the user. The key building block is the component -- which allows the developer to use Ts code to select and prepare data -- and a template that tells Angular how to display that data in HTML elements.

```ts
export class ProductComponent {
  private model: Model = new Model();
  private messages = ["Total", "Price"];
  private index = 0;

  get count(): number {
    return this.model.getProducts().length;
  }

  get total(): string {
    return this.model.getProducts()
      .reduce((total, p) => total + (p.price ?? 0), 0).toFixed(2);
  }

  get message(): string {
    return `${this.messages[this.index]} $${this.total}`;
  }
}
```

```html
<div class="bg-primary text-white p-2">
  {{message}}
</div>
```

Angular has processed the template, evaluted the data bindings, read the values from the component, and use the DOM API to create the HTML elements displayed by the browser.

#### Adding user interaction

Almost every Angular app allows the user into interact with the content that is presented by the user.

```ts
toggleMessage() {
    this.index = (this.index + 1) % 2;
}

removeProduct() {
    this.model.deleteProduct(this.model.getProducts()[0].id ?? 0);
                             }
```

```html
<button class="btn btn-primary m-2" (click)="toggleMessage()">
  Toggle
</button>

<button class="btn btn-primary m-2" (click)="removeProduct()">
  Remove
</button>
```

So the `button`elements are configured with an event binding -- the `(click)`attribute, which tells Angualr how to respond when the button is clicked.

