# Merging

Going to learn about integrting changes from one branch into another. In Git, there are two ways to do this merging and *rebasing*, will introduce two types of merges -- and U will carry out a fast-forward merge.

### State of the Local Repository

Should have 3 commits and 2 branches in your `rainbow`repostiory, and U should be on the `feature`branch. Branches are powerful feature of Git, and it’s great that they allow us to work on different parts of a project independently.

Merging git is one way U can integrate the changes made in one branch into another branch -- in any merge, there is one branch that you are merging -- called *source branch*, and one you are merging into, called the *target branch*.

The source is the branch that *contains the changes that will be integrated into the target branch*. And the target is the branch that *receives the changes and is therefore the only one that is **altered***.

Make a secondary branch off the `main`branch, will merge the secondary branch into `main`only after they have reviewed.

#### Types of Merges

There are two types of merges -- 

1. Fast-forward merges
2. Three-way merges

The factor that determines which of these types of merges will take palce when U merge the source branch into the target branch is whether the development histories of the two branches have diverged.

For this example, Can see in the `rainbow`repository, the parent commit of the orange is the red. By the same logic, noted that the orange is the parent of the yellow.

And the development history of a branch begins with the commit it points to, and extens backward through the chain of commits.

First, start by going over an example of a fast-forward merge -- is a type of merge that occurs when the development histories of the branches involved in the merge *have not diverged.* When it is possible to reach the target branch by following the parent links that make up the commit history of the source branch. During a fast-forward merge, Git takes the pointer of the target branch and moves it to the commit of the source branch.

If can reach one branch through the commit history of another branch, say that the development histories of the branches *have not diverged*. Fore, If follow the parent links from one branch -- which pointes to commit FORE E, backward, reach the `main`-- which points to commit `B`...

If were to now merget this branch into the `main`-- a fast-forwad merge would occur. During the fast-forward merge the `main`pointer would move forwoard to point to the commit that the branch points to.

In this merge example, current is the *source* and the `main`is the *target*. The `main`just pointer simply moved **forward** from commit B to Commit E fore.

For a 3-way merge -- is a type of merge that occurs when the development histories of the branches involved in the merge have diverged. -- Development histories *have* diverged with it is *not* possible to reach the target branch by following the commit history of the source branch. In this case, when merge the source into target, Git performs a 3-way merge -- creating a merge commit to tie the two development histories together, it then mvoes the pointer to the target branch to the merge commit.

Suppose that the last two commits on the `main`and in my `book`repository are commits `F`and `G`, Now suppose decide to make a `chatper_eight`branch to work on chapter 8 of book, and make commits `H I J`. -- And at the same time, however, add some ork to the `main`, K and L, now points to commit `L`. Can see, now development history of `chapter_eight`is made up of `F G H I J`, on the other hand, the commit of `main`made up of `F G K L`. There is no way to follow the parent links of the `chapter_eight`branch backward to reach the commit that the `main`points to. In Git, to describe this situation, say the the development histoies of the branches have *diverged*.

For not, if merge the `chapter_eight`into the `main`-- can’t be fast-forward merge cuz there is no way to just move the branch pointer forward to combine these two development histories. Instead, a *merge commit* will be created to tie the two development histories together. For this, `M`points back to both commit `J L`. The reason that this kind of merge is called 3-way merge cuz in order to carry out the mrege, Git will take a look at the two commits tht the branches invovled in the merge are pointing to.

Three-way merges are a more complex type of merge where U may experience *merge conflicts* -- These arise when U merge two branches where different changes have been made to the same parts of the same files, or if in one branch a file was deleted that was just edited in the other branch.

### Doing a Fast-Forward Merge

Just will merge the `feature`branch into the `main`. For this, the `feature`is the source and the `main`is the target. And there are just two steps involved in doing a merge -- 

1. Switch onto the branch that you want to merge into (target), here the `main`
2. Use the `git merge`command and pass in the name of branch you are merging, `source`, fore, `feature`

Will walk U through performing first merge -- in the process, U will learn tow more important lessons, First: Git protects U from losing any work U have done in files that you have not committed, second, that changing branches may cause the contents of the *working directory to change*.

#### Switching onto the branch U are merging to

The first step of doing so is to switch onto the target branch. Fore, going to merge `feature`to `main`. So need to switch onto the `main`branch. `git switch`or `git checkout` At these 3 steps indicate -- if the branches point to different commits, changing branches also changes the contents of your working directory.

If Git detects that switching branches will cause to lose un-committed changs in your working directory, then it will stop U from switching branches and present U with an error message.

## Concurrency Practice

- Preventing common mistakes with goroutines and channels.
- Understanding the impacts of using std data structures alongside concurrent code
- Using the std lib and some extensions
- Avoiding data races and deadlocks

### Propagating an appropriate context

Contexts are omnipresent when working with concurrency in Go -- and in many situations, it may be recommended to propagate them. However, context propagation can sometimes lead to subtle bugs -- preventing subfunctions from being correctly executed.

```go
func handler(w http.ResponseWriter, r *http.Request) {
	// perform some task to compute the HTTP resp
	response, err := doSomeTask(r.Context(), r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	
	go func() {
        // create a goroutine to publish response
		err := publish(r.Context(), response)
		// do sth
	}
    
    // write the http response
	writeResponse(response)
}
```

Have to know that the context attached to an HTTP request can cancel in different conditions -- 

- When client’s connection closes
- HTTP/2, request is canceled
- When response has been written back to the client

But, when the response has been written to the client, the context associated with the request will be canceled, facing race condition -- 

- If the resp is written after the publication, both returna resp and publish a message successfully
- However, if resp is written before or during publication, message shouldn’t be published.

One idea is to not propagate the parent context, instead, call `publish`with an empty context -- 

`err := publish(context.Background(), response)`

But, if the `r.Context()`contained useful values -- fore, if the context contained a correlation ID.. -- Ideally, we would like to have a new context that is detached from the potential parent cancellation but still conveys the values.

For the STDLIB, doesn’t provide an immediate solution to this problem -- hence, a possible solution is to implement our own Go context similar to the context provided, except that it doesn’t carry the cancellation signal.

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key any) any
}
```

So the context’s deadline is mangaged by the `Deadline`and the cancellation signal is managed via the `Done`and `Err`methods. When a deadline has passed or the context has been canceled, `Done`should returna closed channel, whereas `Err`should return an error. Finally, the values are carried via the `Value`method.

Create a *custom* context that detaches the cancellation signal from a parent context like:

```go
type detach struct {
	ctx context.Context
}

func (d detach) DeadLine() (time.Time, bool) {
	return time.Time{}, false
}

func (d detach) Done() <-chan struct{} {
	return nil
}

func (d detach) Err() error {
	return nil
}

func (d detach) Value(key any) any {
    // delegates the get value call to the parent context
	return d.ctx.Value(key)
}
```

For this, except for the `Value()`that calls the parent context to retreive a value, the other methods return just default value so the contxt is *never considered expired or canceled*.

Then use this, can now call `publish`and detach the cancellation signal like:

`err := publish(detach{ctx: r.Context}, response)`

For now the context passed to `publish`will never expire or canceled, but will carry the parent’s values.

### Knowing when to stop a goroutine

Goroutines are easy and cheap to start -- so easy and cheap that may not necessarily have a plan for when to stop a new goroutine, which can lead to leaks. Not knowing when to stop a goroutine is a *disgn issue* and a common concurrency mistake in Go.

In terms of memory, a goroutine starts with a minimum *stack size* of 2K, then grows and shrinks as needed -- and the maximum is 1G on 64-bit. Memory-wise, a goroutine can also hold variable references allocated to the heap. Meanwhile a goroutine can hold resources such as HTTP or Dbs connections, open files, and network sockets... Should eventually be closed gracefully, then if a goroutine is leaked, these kinds of resources will *also be leaked*.

Look at an example in which the point where a goroutine stops is unclear -- a parent goroutine calls a function that returns a channel and then creates a new goroutine that will keep receiving messages from this channel. like:

```go
ch := foo()
go func(){
    for v := range ch {
        //...
    }
}()
```

For the created goroutine, will exit when `ch`is closed, but do we exactly know *when* this channel will be closed -- Maybe not -- cuze `ch`is created by the `foo` function. If the channel is never closed, it’s a leak. So, should always be cautious about the exit points of a goroutine and make sure one is eventually reached.

Fore, will design an app that needs to watch some external configuration -- 

```go
func main(){
    newWatcher()
    // ...
}
type watcher struct{}
func newWatcher(){
    w := wather{}
    go w.Watch()
}
```

For this, call `newWatcher()`, which creates a `watcher`struct and spins up a goroutine in charge of watching the configuration. The problem with this is that when `main`exits, the app is stopped, rources created by `watcher`aren’t closed gracefully. One option could be to pass to `newWatcher`a context that will be canceled when `main`returns like:

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    newWatcher(ctx) // change the signature
}
func newWatcher(ctx context.Context) {
    w := watcher{}
    go w.watch(ctx) // also change the signature
}
```

For this, when the context is canceled, the `watcher`structu should close its resources -- an we guarantee that `watch()`will have time to do so?

The real problem is -- used signals to convey that a goroutine had to be stopped -- didn’t block the parent goroutine until the resources had been closed. So

```go
func main(){
    w := newWatcher()
    defer w.close()
}

func newWatcher() watcher {
    w := watcher{}
    go w.watch()
    return w
}

func (w watcher) Close{
    // close the resources
}
```

Then for this has a new method `close()`-- instead of signaling `watcher`that it’s time to close its resources, now call the `close`method, using the `defer`to guarantee that the resources are closed before the app exits.

Starting a goroutine without knowing when to stop it is a disign issue -- whenever a goroutine is started, we should have a clear plan about when it will stop. If a goroutine creates resources and its lifetime is bound ot the lifetime of the application, it’s probably safer to wait for this to complete before exiting the app.

## Multiple-record SQL queries

Finally look at the pattern for executing SQL statements which return multiple rows. Demonstrate by updating the `snippetModel.Latest()`method to return the *most recently* created then just like:

```go
func (m *SnippetModel) Latest() ([]*Snippet, error) {
    // Write the SQL statement we want to execute
    stmt := `SELECT id, title, content, created, expires from snippets
    	WHERE expires>UTC_TIMESTAMP() ORDER BY id DESC LIMIT 10`
    
    // Use the `Query()`method on the connection pool to execute our SQL statement
    // Returns sql.Rows resultset containing the result of our query
    rows, err := m.DB.Query(stmt)
    if err != nil {
        return nil, err
    }
    
    // defer rows.Close() to ensure the sql.Rows resultset is always properly closed before the `Latest()`
    // method returns. this defer statement should come after you check for an error from the Query()
    // otherwise, returns an error
    defer rows.Close() 
    
    // Initialize an empty slice to hold structs
    snippets := []*Snippet{}
    
    // Then use the `rows.Next()`to iterate through the rows in the resultset. This prepares the first
    // row to be acted on by the rows.Scan() method
    for rows.Next(){
        // create a pointer to a new zeroed Snippet struct
        s := &Snippet{}
        // Then use the rows.Scan() to copy the values from each filed in the row to the new object that 
        // created -- the row.Scan() must be pointers to the place want to copy the data into
        err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
        if err != nil {
            return nil, err
        }
        snippets = append(snippets, s)
    }
    
    // When the rows.Next() loop has finished, call the `rows.Err()` to retreive any error that was 
    // encountered during the iteration. It's important to call this -- don't assume that a success
    if err = rows.Err(); err != nil {
        return nil, err
    }
    
    // if everything ok
    return snippets, nil
}
```

#### Using the model in handlers

Head back to the `handlers.go`file and update the `home`handler to use the `SnippetModel.Latest()`method, dumping the snippet contents to a HTTP response like:

```go
func (app *application) home (w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        app.notFound(w)
        return
    }
    
    snippets, err := app.Snippets.Latest()
    if err != nil {
        app.serveError(w, err)
        return
    }
    
    for _, snippet := range snippets {
        fmt.Fprintf(w, "%+v\n", snippet)
    }
}
```

### Transactions and other details

The `database/sql`package -- Essentially provides a std interface between your Go app and the world of SQL databases. so lang as U use the `database/sql`package, the Go code U write will generally be portable and will work with any kind of SQL dbs.

It’s important to note that while `database/sql`generally does a good job of providing a std interface or working with SQL dbs, there are some idiosyncrasies in the way that different drivers and dbs operate.

#### Working with transactions

It’s important to realize that calls `Exec(), Query(), QueryRow()`can use any connection from the `sql.DB`pool. Note, even if U have two callst to `Exec()`immediately next to each other in your code, there is no guarantee that they will use the same dbs connnection.

Sometimes this isn’t acceptable, fore, if lock a table with MySQL’s `LOCK TABLES` command must call `UNLOCK TABLES`on exactly the same connection to avoid a deadlock.

To guarantee that the same connection is used U can wrap multiple statements in a *transaction* -- like:

```go
type ExampleModel struct {
    DB *sql.DB
}

func (m *ExampleModel) ExampleTransaction() error {
    // Calling the `Begin()` on the connection pool creates a new sql.Tx object
    tx, err := m.DB.Begin()
    if err != nil {
        return err
    }
    
    // defer a call to tx.Rollback() to ensure it is always called from the function returns
    defer tx.Rollback()
    
    // call Exec() on the transaction -- passing in your stmt and any parameters.
    _ , err = tx.Exec("INSERT INTO...")
    if err != nil {
        return err
    }
    
    // carry out another transaction in exactly the same way
    _, err = tx.Exec("update ...")
    if err != nil {
        return err
    }
    
    // if there are no errors using the `tx.Commit()` -- transaction can be committed
    err = tx.Commit()
    return err
}
```

#### Prepared statements

As mentioned, the `Exec(), Query(), QueryRow()`all use prepared statements behind the scenes to help prevent SQL injection attacks. The set up a prepared statement on the database connection, run it the parameters provided, and then close the prepared statement.

This is inefficient cuz we are creating and receating the same prepared statements every single time. In theory, a better approch could be to make use of the `DB.Prepare()`method to create our own prepared statement once, and reuse that instead -- this is particularly true for complex SQL statements and are repeated very often a bulk insert of thens of thousands of records. Basic pattern for using own prepared statement in web app -- 

```go
// need somewhere to store the prepared stmt for the lifetime of our app
type ExampleModel struct {
    DB *sql.DB
    InsertStmt *sql.Stmt
}

// Create a ctor for the model, which set up the prepared statement
func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    // Use the prepare method to create a new prepared stmt for the current connection pool, this
    // returns a sql.Stmt object represents the prepared statement
    insertStmt, err := db.Prepare("Insert Into ...")
    if err != nil {
        return nil, err
    }
    
    // store it in our object
    return &ExampleModel{db, insertStmt}, nil
}

// Any method imp aginst the `ExampleModel` will have access thep prepared statement
func (m *ExampleModel) Insert(...args) error {
    // how call Exec() against the prepared statement, note that
    _, err := m.InsertStmt.Exec(args...)
    return err
}

func main() {
    db, err := sql.Open(...)
    if err != nil {
        errorLog.Fatal(err)
    }
    defer db.Close()
    
    // Create a new ExampleModel obj
    exampleModel, err := NewExampleModel(db)
    if err != nil {
        errorLog.Fatal(err)
    }
    
    // defer a call to `Close()` ensure that is properly closed
    // before our main function terminates
    defer exampleModel.InsertStmt.Close()
}
```

Note that Prepared statement exist on *database connection* -- Cuz Go uses a pool of many database connections -- what actually happens is first time a prepared stmt is used it gets created on a particular dbs connections. The sql.Stmt obj then remembers which connection in the pool was used, the next time the `sql.Stmt`will attempt to use the same dbs conenction again. If that connection is closed or in use, the statement will be re-prepared on another connection.

Under a heavy load, it’s possible that large amount of prepared statements will be created on multiple connections. The code is more complicated than not using prepared statements for this situation.

### Dynamic HTML templates

- Pass dynamic data to HTML templates in a simple scalable and type-safe way
- Use the various actions and functions in Go’s `html/template`package to control the display of dynamic data.
- Create a `template cache`so your templates aren’t being read from disk for each HTTP request.
- Gracefully handle *template rendering errors* at runtime
- Implement a pattern for passing *common dynamic data* to your web pages without repeating code.
- Create own *custom functions* to format and dispaly data in HTML templates

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id <1 {
        app.NotFound(w)
        return
    }
    
    //...
    // Initialize a slice containing the paths to the view.html file
    files := []string {
        "./ui/html/base.html",
        //...
    }
    
    // parse
    ts, err := template.ParseFiles(files...)
    if err != nil {
        app.serveError(w, err) 
        return
    }
    
    // execute them
    err = ts.ExecuteTempalate(w, "base", snippet)
    if err != nil {
        app.serveError(w, err)
    }
}
```

Within this special case, the underlying type of dot will be a `models.Snippet`struct. when the underlying type of dot is a struct, can render the value of any exported field in your templates by postfixing dot with the field name.

```html
{{define "title"}} Snippet #{{.ID}}{{end}}
{{define "main"}}
<div class="...">
	<div class="metadata">
        <strong>{{.Title}}</strong>
        <span>#{{.ID}}</span>
    </div>     
    <div class="metadata">
        <time>Created: {{.Created}}</time>
    </div>
</div>
```

#### Rendering multiple pieces of data

An important thing to explain in Go’s `html/tempalte`allows U to pass in one, and only one - item of dynamic data when rendering a template. But in a real-world app there are often multiple pieces of dynamic data that U want to display in the same page.

A lightweight and type-safe way to achieve this is to wrap your dynamic data in a struct which acts like a single *holding structure* for your data.

```go
type templateData struct {
    Snippet *models.Snippet
}
```

```go
// ...
// Create an instance of a tempalteData struct holding the snippet data.
data := &templateData {
    snippet: snippet
}

err = ts.ExecuteTemplate(w, "base", data)
```

```html
{{define "title"}}Snippet #{{.Snippet.ID}}{{end}}
{{define "main"}}
<div class="..">
    <div class="metadata">
        <strong>{{.Snippet.Title}}</strong>
    </div>
</div>
<!-- ... -->
```

For this `html/template`package, automtically escapes any data that is yielded between `{{}}`tags. Just helpful in avoiding cross-site scripting(XSS) attackes -- and is the reason that you should use the `html/tempate`package instead of the more generic `text/template`package that Go also provides.

Nested templates -- 

It’s really important to note that when are invoking one template from another, dot needs to be explicitly passed or *pipelined* to the template being invoked -- do this by including it at the end of each `{{template}}`or `{{block}}`action. As a general rule, get into the habit of always pipelining dot whenever with the `{{template}}`or `{{block}}`actions.

# Changing custom properties dynamically

They can save U from a lot f repetition in your code. But what makes them particularly interesting is that the declarations of custom properties *cascade and inherit* -- Can define the same variable inside multiple selectors, and the variable will have a different value for various parts of the page.

```html
<aside class="dark">
  <div class="panel">
    <h2>Single-Origin</h2>
    <div class="body">
      We have built partnerships with small farms
      around the world to hand-select beans at the
      peak of season. We then careful roast in
      small batches to maximize their potential.
    </div>
  </div>
</aside>
```

```css
:root{
  --main-bg: #fff;
  --main-color: #000;
}

.panel {
  font-size: 1rem;
  padding: 1em;
  border: 1px solid #999;
  border-radius: 0.5em;
  background-color: var(--main-bg);
  color: var(--main-color);
}

.panel > h2 {
  margin-top: 0;
  font-size: 0.8em;
  font-weight: bold;
  text-transform: uppercase;
}
```

Again, defined the variables inside a ruleset with the `:root`selector. When a descendant element of the root uses the variables, these are the values they will resolve to.

Just define the variables again, this time with a different selector. The next listing provides styles for the dark conainer.

```css
.dark {
  margin-top: 2em;
  padding: 1em;
  background-color: #999;
  --main-bg: #333;
  --main-color: #fff;
}
```

Cuz when the panel uses these custom propperties, they resolve to the values defiend on the dark container. So in this example, defined custom properties twice -- first on the `root`, and then on the `darker`content.

## Document flow and the box model

Normal document flow -- Build a simple page with a header at the top and content beneath it. The width of the content will be restricted to avoid very lone lines of text.

```html
<body>
<header class="page-header">
  <h1>Franklin Running Club</h1>
</header>
<div class="container">
  <main class="main">
    <h2>Come join us!</h2>
    <p>
      The <b>Franklin running club</b> meets at the
      town square. Runs are three to five miles, at your own pace.
    </p>

    <p>
      Join us while we train for the
      <a href="/st-patricks">St. Patrick's Day 5k</a>. Don't forget to wear
      green!
    </p>
  </main>
  
  <aside class="social-links">
    <a href="/mastodon" class="button-link">Follow us on mastodon</a>
    <a href="/facebook" class="button-link">Like us on facebook</a>
  </aside>
</div>
</body>
```

The styles for this are shown in the following like:

```css
:root {
  --brand-color: #0072b0;
}

body{
  margin: unset;
  background-color: #eee;
  font-family: Arial, sans-serif;
}

.page-header {
  color: #fff;
  background-color: var(--brand-color);
}

.main {
  background-color: #fff;
  border-radius: .5em;
}

.social-links {
  background-color: #fff;
  border-right: .5em;
}
```

For, there are 2 basic types of element -- **inline** and **block**.

DEF -- *Normal document flow* refers to the default layout behavior of elements on the page. Inline elements flow along with the text of the page. From left to right, line wrapping when they reach the edge of their container.

The important thing to note is that height and width are *fundamentally different* -- Normal document flow is designed to work with a constrained width and *unlimited* height. Contents fill the width of their container and then line wrap as necessary. This means that the width of a parent element determines the width of its children. For the height, The opposite is true -- *the heights of child elements determine the height of the parent*.

#### Centering content horizontally

Fore, want to constrain the width of the page’s main column. Cuz block-level elements fill the width of their container by default, U generally don’t need to do anything like `width: 100%`or `width: 100svw`.-- U will often want to reduce their width from the deafult.

```css
:root {
  --column-width: 1080px;
}
.container {
  max-width: var(--column-width);
  margin: 0 auto;
}
.page-header h1 {
  max-width: var(--column-width);
  margin: 0 auto;
}
```

By just setting a left and right margin of `auto`-- the margins will automatically expand as much as necessary to fill the remaining width available in the outer container. And using the `max-width`instead of the `width`allows the element to shrink below 1080px if the screeen’s viewport is narrower than that.

#### Using Logical properties

DEF -- Logical properties provide a way to work with elements in terms of their *block* and *inline* directions -- which can change for different writing modes -- rather then explicitly referring to top right, bottom and left or to width and height. And when using logical properties, swap out the concepts of horizontal and vertical for *inline base direction* and *block flow direction* -- Instead of setting `width`, can set the `inline-size`fore. The `inline-size`specify the height when used with vertical writing modes. Likewise, `height`to `block-size`.

And logical properties also replace top, right, bottom and left with `start`and `end`. Thus, `padding-left`and `padding-right`become `padding-inline-start`and `padding-inline-end`. Also, fore, `border-top`and `border-bottom`become `border-block-start`...

Both classic properties and their equivalent logical properties can override each other in the cascade. Fore:

- `width/inline-size`
- `height/block-size`
- `border-top-left-raduis/border-start-start-radius`

#### Adopting useufl shorthand for logical properties

Fore, the `margin-inline`allows to set the start and the end, left and right. Can use this on pge for a slightly cleaner approach to the double-container pattern.

```css
.page-header h1 {
  max-inline-size: var(--column-width);
  margin-inline: auto;
}
```

### The box model

The next to address on the page you are building is some padding in the main container and the `social-links`box.

```css
.main{
  padding: 1em 1.5rem;
}

.social-links {
  padding: 1em 1.5rem;
}

.page-header h1 {
  padding-inline: 1.5rem;
}
```

This is cuz of the default box model -- According to the box model, each element on the page is made up of 4 overlapping rectangles. The content area is the *innermost* rectangle where the contents of the element reside. And the *padding area* contains the content area plus any padding. Likewise, the *border area* is the padding area plus any border. Finally, the *margin area* is the outermost rectangle.

DEF -- the *box model* refers to the parts of an element and the size they contribute to their element. By default, specifying the height or width of an element sets the size of its *content area*. Any padding, border, and margins are added outside that.

Note -- Top and Bottom margins and paddings behave a little unusually on inline elements. They will still increase the height of the element, but not increase the height that the inline element contributes to its container. so, using the `display: inline-block`will change this behavior if necessary.

## Working with Reactive Extensions

Angular has lone relied on a package named RxJS. And the key Reactive Extensions building block is an observable, which is represented by the `Observable<T>`class, and which presents a sequence of values that are produced over time. The basic method provided by an `Observable<T>`is `subscribe`-- which accepts an object whose properties are set to functions that respond to the sequence of values.

```ts
export class Ticker {
    value: Observable<number> = interval(500);
}

export class ProductComponent{
    //...
    private ticker = new Ticker();
    tickerValue=0;
    constructor(){
        this.ticker.value.subscribe(newValue=> this.tickerValue=newValue);
    }
}
```

#### Using observables with signals

Angular provides interoperability functions that allow RxJS observables to be used with signals. note that this is important cuz *computed signals* will only be updated when another signal on which they depend has changed, which means that values taken directly from an observable won’t trigger an update.

Can use the `toSignal`func -- creates a signal from an Observable. This allows to remove the code that processes values produced by the observable and depend on the observed values in a computed signal.

```ts
tickerValue = toSignal(this.ticker.value, {initialValue:0});
message = computed<string>(()=> {
    return `${this.messages[this.index()] $${this.total} ${this.tickerValue()}`
})
```

Note that there is also  `toObservable`that creates an `Observable<T>`from a signal and emits a value each time the signal is changed or re-computed.

### Data bindings

One-way bindings are used to generate content for the user and are the basic feature used in Angular templates. the term *one-way* refers to the fact that the data flows in one direction. Fore:

```ts
classes = computed<string>(()=> 
                          this.count()==5 ? "bg-success":"bg-warning");
```

```html
<div [ngClass]="classes()" ...
```

#### Binding target

When Angualr processes the target of a data binding, it starts by checking to see whether it matches a directive. Most app will rely on a mix of the built-in directives provided by Angular and custom directives that provide app-specific features. The built-in directives can be recognized by the `ng`prefix -- 

- `ngClass`- used to assign host elements to classes
- `ngStyle`...
- `ngTemplateOutlet`-- used to repeat a block of content
- `[property]`-- standard property binding, used to set a property on the Js object of DOM.
- `[attr.name] [class.name], [stylen.name]`

```html
<div [ngClass]="'text-white p-2 '+ classes()">
    Hello
</div>
```

### Using std property and attribute bindings

If the target of binding doesn’t match a directive, Angular will try to apply a property binding.

```ts
export class ProductComponent {
  private model: Model = new Model();
  products = computed<Product[]>(() => this.model.Products());
  count = computed<number>(() => this.products().length);
  classes = computed<string>(() =>
    this.count() == 5 ? "bg-success" : "bg-warning");
}
```

```html
<div [ngClass]="'text-white p-2 '+ classes()">
  Hello
</div>

<div class="mb-3">
  <label>Name:</label>
  <input class="form-control" [value]="products()[1].name" />
</div>
```

#### The attribute binding

The most often used attribute without a corresponding prop is `colspan`fore:

```html
<table class="table mt-2">
  <tr>
    <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>
  </tr>

  <tr>
    <td [attr.colspan]="count()">
      {{products()[1].name}}
    </td>
  </tr>
</table>
```

So the attribute binding is applied by defining a target that prefixes the name of the attribute wtih `attr.`

#### Setting classes and styles

`<div [ngClass]="map"></div>`

```ts
getClasses(key: number) {
    return "p-2 " + (((this.products()[key].price ?? 0) > 50)
      ? "bg-info" : "bg-warning");
  }

getClassMap(key: number): Object {
    let product = this.products()[key];
    return {
      "text-center bg-danger": product.name == 'Kayak',
      'bg-info': (product.price ?? 0) < 50
    }
```

```html
<div class="text-white">
  <div class="p-2" [ngClass]="getClassMap(0)">
    The first product is {{products()[0].name}}
  </div>
  <div class="p-2" [ngClass]="getClassMap(1)">
    The second is {{products()[1].name}}
  </div>
</div>
```

#### The style bindings

And there are 3 different ways in which you can use bindings to set style properties of the host element. Just like [ngClass]. fore:

```html
<div class="p-2 bg-warning">
    The <span [style.fontSize]="fontsizeWithUnits">First</span>
</div>
<div class="p-2 bg-info">
    The <span [style.fontSize.px]="fontSizeWithoutUnits">Second</span>
</div>
```

```ts
getStyles(key: number) {
    return {
      fontSize: "30px",
      "margin.px": 100,
      color: (this.products()[key].price ?? 0) > 50 ? "red" : "green"
    }
  }
```

```html
<div class="text-white">
  <div class="p-2 bg-info">
    The <span [ngStyle]="getStyles(1)">second</span>
  </div>
</div>
```

### Built-in directives

```html
<div class="bg-info p-2 mt-1">
  @switch(count()) {
    @case(5){
      <span>There are 5 products</span>
    }
  }
</div>
```

```html
<div class="text-white">
  <div class="bg-info p-2">
    There are {{count()}} products.
  </div>
  <div class="p-1">
    <table class="table table-sm table-bordered text-dark">
      <tr><th>Name</th><th>Category</th><th>Price</th></tr>
      @for(item of products(); track item.id){
        <tr>
          <td>{{item.name}}</td>
          <td>{{item.category}}</td>
          <td>{{item.price}}</td>
        </tr>
      }
    </table>
  </div>
</div>
```

#### Using directives without an HTML element 

The `ng-container`element can be used to directives without using an HTML element, which can be used when U want to generate content without adding to the structure of the HTML document displayed by the browser. Fore:

```html
<div class="bg-info p-2 text-white">
  Product Names:
  <ng-container *ngFor="let item of products(); let last=last">
    {{item.name}}<ng-container *ngIf="!last">,</ng-container>
  </ng-container>
</div>
```

So the `ng-container`element doesn’t appear in the HTML displayed by the browser, which means that it can be used to generate content with elements.

