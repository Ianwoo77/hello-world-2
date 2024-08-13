# Creating a Branch

At the moment, only have one local branch, called `main`-- in `rainbow`repository, to list the branches in a local repository, can just use the `git branch`command, create a new branch, pass the name of a branch that doesn’t exist yet to this command.

```sh
git branch
git branch <new_branch_name> # create a new branch
git branch feature
git log
```

In the step 2, made a new branch called `feature`that points to the orange commit. Representing the `main`and `feature`branches, pointing to the orange commit. So a new branch will initially point to the commit that you were on when U made the branch. in this case, an say that you *made the feature branch off the main branch*. That is why the `feature`and `main`now point to the same commit.

#### What is HEAD

At any given point in time, are looking at a particular version of your porject. Therefore, you are on a particular branch which is pointing to a commit. `HEAD`is simply a pointer that tells U which branch you are on.

```sh
cd .git
cat HEAD # ref: refs/heads/main
```

The `HEAD`file contains .. which is a reference to the `main`file that represents the `main`branch. So `HEAD`now is pointing to the `main`-- this indicates you are currently on the `main`branch. NOTE that the `heads`directory stores a file for every local branch in local repository, while `HEAD`indicates which branch you are on referencing one of the files inside the `heads`directory.

And another way of knowing which branch you are currently on is to look at the output of either `git branch`or the `git log`command, in the `git branch`, the branch you are currently on will have an `*`next to it.

### Switching Branches

To work on another branch, or line of development, have to switch onto that branch. Means *Check out* another branch. U make a branch in Git not mean that you automatically switch onto that. Must explicitly instruct Git that U want to switch onto a branch. Can do this using either `git switch`or the `git checkout`command. Note that for `git switch`, git version > 2.23 needed.

Using just the `git switch`-- as this is the specialized command included in the last versions of Git for this purpose. However, can always choose to use the `git checkout`instead.

Then the `git switch`or `git checkout`command does 3 things when used to switch branches -- like:

1. It changes the `HEAD`pointer to point to the branch U are switching onto.
2. It populates the staging area with a snapshot of the commit u are switching onto
3. It copies the conent of the staging area into working directory

#### The Areas of Git

There are four important areas to be aware of when you are working with Git -- 

- Working directory
- Staging area
- Commit history
- Local repository

The *Staging area* is similar to a rough draft space. It is where U can add and remove files, when are preparing what you want to include in the next saved version of your proj. The staging is represented by a file in the `.git`directory called `index`.

In short, when change branches you end up changing the commit that you are looking at. Provided that the two branches point to two different commits. At the moment, both of the branches u have in the `rainbow`repository point to the same commit, and only the first action will take place, and the commit you are on will not change.

```sh
# for now returns `refs/head/feature`
cat HEAD
```

As can see, switching branches changed the contents of the `HEAD`file in the `.git`directory.

### Wroking on a Separate Branch

```sh
# first, append to the file
git add readme.md
git commit -m "yellow"
git log
# The feature points to the latest commit
# the main still points to orange commit note that
```

As mentioned, when make a commit, it is the branch you’re curerently on that updates to point to the new commit. The `main`and `feature`no longer to the same cuz `feature`has updted to the point to the new comit.

## Understanding Go Contexts

Developers sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the language and a foundation of concurrent code in Go. *A context carries a deadline, a cancellation signal, and other values across API boundaries*.

#### Deadline

A deadline refers to a specific point in time determined with one of the following -- 

- A `time.Duration`from now
- A `time.Time`

So the semantics of a deadline convey that an ongoing activity should be stopped if this deadline is met. Fore, have at our disposal a `publisher`interface containing a single method like:

```go
type publisher interface {
    Publish(ctx context.Context, position flight.Position) error
}
```

For this, accepts a context and a position. Assume tht the concrete imp calls a func to publish a message to a borker. This func is *context aware* -- meaning it can cancel a request once the context is just canceled. And assuming don’t receive an existing context, namely, what should we provide to the `Publish`method the context argument. like:

```go
type publishHandler struct {
    pub publisher
}

func (h publishHandler) publishPosition(postion flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Background(), 4*time.second)
    defer cancel()
    return h.pub.Publish(ctx, position)
}
```

For this, creates a context using the `context.WithTimeout`func, this func accepts a timeout and a context, create one from an empty with `context.Background()`. Then the `context.WithTimeout()`returns two variables - the context created and an cancellation `func()`function that will cancel the context once called. Passing the context created to the `Publish`method should make it return in at most 4s.

So what’s rationale for calling the `cancel()`function as a `defer`-- internally, `context.withTimeout`creates a goroutine that will be retained in memory for 4s for until `cancel`is called -- Therefore, calling `cancel`as `defer`means that **when** we exit the parent function, the context will be canceled, and the context will be canceled, and the goroutine created will be stopped.

#### Cancellation signals

Another use case for Go contexts is to carry a cancellation signal -- fore, want to create an app that calls `CreateFileWatcher(ctx context.Context, filename string)`within another goroutine. This function creates a specific file watcher that keeps reading from a sifle and catches updates. When the provided context expires or is canceled, this func handles it to close the file descriptor. Finally, when the `main`returns, want things to be handled gracefully by closing this file descriptor. Fore:

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    go func() {
        createFileWatcher(ctx, "foo.txt")
    }()
    // ...
}
```

For this, when the `main`returns, it calls the `cancel()`to cancel the context passed to `CreateFileWatcher`so that the file descriptor is closed gracefully.

#### Context Values

Is to carry a K-V list -- Before understanding the rationale -- first see how to use -- like:

`ctx := context.WithValue(parentCtx, "key", "value")`

Just like the `WithTimeout, WithDeadline`and `WithCancel`, `context.WithValue()`is created from a parent context, in this case, we just create a new `ctx`context containing the same characteristics as `parentCtx`but also conveying a key and a value. Like:

```go
ctx := context.WithValue(context.Background(), "key", "value")
fmt.Println(ctx.Value("key"))
```

And, the key and values provided are `any`types -- Consequentaly, a best practice while handling context keys is to create an *unexported* custom type. like:

```go
type key string
const myCustomKey key = "key"
func f(ctx context.Context) {
    ctx = contet.WithValue(ctx, myCustomKey, "foo")
}
```

For this, the `myCustomKey`constant is unexported, hence, there is no risk at another package using the same context could override the value that is aleady set. Even if another package creates the same custom type. Cuz Go contexts are generic and mainstream.

fore, if want to implement an HTTP middleware -- we have configured two middlewares that must be executed before executing the handler itself. If want middlewares to communicate, they have to go through the context handled in the `*http.Request`.

```go
type key string
const isValidHostKey key= "isValidHost"

func checkValid(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        validHost := r.Host=="acme"
        ctx := context.WithValue(r.Context(), isValidHostKey, validHost)
        next.ServeHttp(w, r.WithContext(ctx))
    })
}
```

This shows how context with values can be used in concrete Go applications.

#### Catching a context cancellation

The `context.Context`type exports a `Done`method that returns a receive-only notification channel -- `<-chan struct{}`-- this channel is closed when the work associated with the context should be canceled.

- The `Done`channel related to a context created with the `WithCancel()`is closed when the `cancel()`is called.
- The `Done`related to a context created with `context.WithDeadline()`is closed when the deadline expired.

One thing to note is that the internal channel should be closed when a context is cancled or has met a deadline, instead of when it receive a specific value, cuz the closure of a channel is the only channel action thatall conumer goroutines will receive. This way, all the consumers will be just notified once a context is canceled or deadline is reached.

Furthermore, `context.Context`exports an `Err`method that returns `nil`if the `Done`channel isn’t yet closed. Otherwise, returns a *non-nil* error explaining why the `Done`was closed. fore:

- A `context.Canceled`error if channel was cancled
- A `contxt.DeadlineExceeded`if the `context`'s deadline passed

```go
func handler(ctx context.Context, ch chan Message) error {
    for {
        select {
        case msg := <-ch:
            // do sth with msg
        case <-ctx.Done():
            return ctx.Err() // if the context is done, returns the error associated with it
        }
    }
}
```

So, create a `for`loop and use the `select`with two cases -- receiving messages from `ch`or receiving a signal that the context is done and we have to stop our job.

#### Implementing a func that receives a context

Within a func that receives a context conveying a possible cancellation or timeout, the action of receiving or sending a message to a channel shouldn’t be done in a blocking way.

```go
func f(ctx context.Context) error {
    //...
    ch1 <- struct{}{}
    v := <-ch2
}
```

The problem with this function is that the context is canceled or times out, may have to wait untial a message is sent or received, without benefit. We should use `select`to either wait for the channel actions to complete or wait context cancellation -- like:

```go
func f(ctx context.Context) error {
    //...
    select {
    case <-ctx.Done():
        return ctx.Err()
    case ch<-struct{}{}:
    }
}
```

In summary, to be a proficient Go developer, have to understand what a context is and how to use it. In Go, context.Context is everywhere in the stdlib and external libraries.

## Executing SQL Statements

Update the `SnippetModel.Insert()`-- which like:

```sql
INSERT INTO snippets(title, content, created, expires)
VALUES(?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERNAL ? DAY))
```

In mysql, using the `?`character to indicate *placeholder parameters* for the data that we want to insert in the dbs.

#### Executing the query

Go provides 3 different methods executing dbs queries -- 

- `DB.Quer()`is used for `SELECT`queries which return multiple rows
- `DB.QueryRow()`-- returns a single row
- `DB.Exec()`-- used fore `INSERT DELETE`...

So, in the case, the most appropriate tool for the job is `DB.Exec()`-- like:

```go
func (m *SnippetModel) Insert(title, content string, expires int) (int, error) {
    stmt:= `INSERT INTO snippets (title, content, created, expires)
    VALUES(?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TEIMSTAMP(), INTERNAL ? DAY))`
    
    // Use the Exec() method on the embedded connection pool to execute the statement
    result, err := m.DB.Exec(stmt, title, content, expires)
    if err != nil {
        return 0, err
    }
    
    // Use the `LastInserteId()` on the result to get the ID of our newly inserted data
    if, err := result.LastInsertId()
    if err != nil {
        return 0, err
    }
    
    // The ID returned has the type of int64
    return int(id), nil
}
```

And just note that the `DB.Exec()`provides two method -- 

- `LastInsertId()`-- returns the integer `int64`generated by the dbs in response to a command.  Typically this will be from an *auto increment* column when inserting a new row, which is exactly what is happening in the case
- `RowsAffected()`-- returns the number of rows affected by the statement.

Also, it is perfectly acceptable to ignore the `sql.Result`return value if U don’t need it. like:
`_, err := m.DB.Exec("...")`

#### Using the model in handlers

Bring this back to sth more concrete and demonstrate how to call this new code from our handlers. like:

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
    if r.Method!= http.MethodPost{
        //...
        return
    }
    
    // Create some variables holding dummy data
    title := "0 snail"
    content := "...."
    expires := 7
    
    // Pass the data to the `Insert()` method
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        app.serverError(w, err)
        return
    }
    // redirect the user to relevant page for the snippet
    http.Redirect(w, r, fmt.Sprintf("/snippet/view?id=%d", id), http.StatusSeeOther)
}
```

#### Placeholder parameters

In the code just constructed SQL statement using placeholder parameters -- where `?`acted as a placehilder for the data we want to insert. The reason for using placeholder to construct our query is to help avoid SQL injection attacks from any untrusted user -- behind the scenes, the `sql.DB.Exec()`works in 3 steps -- 

1. It creates a new *prepared statement* on the dbs using the provided SQL statement. The dbs parses and compiles the statement, then stores it ready to execute.
2. In a second separate step, `Exec()`passes the parameter values to the dbs. Cuz the parameters are transmitted later, after the statement has been compiled, the dbs treats them as pure data. They can’t change the intent of the statement.
3. It then closes the prepared statement on the dbs.

#### Single-Record SQL queries

The pattern for `SELECT`a signle record from the dbs is a little more compiled -- how to do it by updating our `SnippetModel.Get()`method so that it returns a single specific snippet based on its ID. for the SQL:

```sql
select id, title, content, created, expires from snippets
WHERE expires > UTC_TIMESTAMP() and id= ?
```

```go
func (m *SnippetModel) Get(id int) (*Snippet, error) {
    stmt := `SELECT id, ... from snippets WHERE expires > UTC_TIMESTAMP() AND id = ?`
    
    // Use the `QueryRow()`on the connection pool to execute our SQL statement
    // pass in the untrusted id variable
    row := m.DB.QueryRow(stmt, id)
    
    // initialize a poitner to a new zeroed Snippet struct
    s := &Snippet{}
    
    // Use the row.Scan() to copy the values from each field in sql.Row to the corresponding field in the 
    // Snippet struct.
    err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
    if err != nil {
        // if the query returns no rows, then row.Scan() will return a sql.ErrNoRows error
        // use errors.Is() check for that error specifically
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrNoRecord
        }else {
            return nil, err
        }
    }
    
    // if everything went ok
    return s, nil
}
```

Behind the scenes of `rows.Scan()`your dirver will automatically convert the raw output from the SQL dbs to the required native Go types. So long as U are sensible with the types that you are mapping between SQL and Go, these conversions should generally just work -- like:

- `CHAR, VARHAR, TEXT`map to `string`
- `BOOLEAN`to `bool`
- `INT`int, `BIGINT`to `int64`
- `DECIMAL`and `NUMERIC`to `float`
- `TIME, DATE`and `TIMESTAMP`to `time.Time`

If try to run the app, should get a compile-error cuz `ErrNoRecord`is not defiend -- Just:

```go
// models/errors.go
package models
var ErrNoRecord = errors.New("models: no matching record found")
```

as an aside, might wonder why just return the `ErrNoRecord`-- instead of `sql.ErrNoRows`-- to help encapsulate the model completely -- so that our app isn’t concerned with the underlying dbs or reliant on data store.

#### Using the model in our handlers

Then put the `SnippetModel.Get()`into action in the `handlers.go`file:

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id <1 {
        app.NotFound(w)
        return
    }
    
    // Use the `SnippetModel` Get() to retrieve the data for a specific record
    snippet, err := app.snippets.Get(id)
    if err != nil {
        if errors.Is(err, models.ErrNorecord) {
            app.NotFound(w)
        }else {
            app.serveError(w, err)
        }
    }
    
    fmt.Fprintf(w, "%+v", snippet)
}
```

#### Checking for specific errors

A couple of times in this -- used the `errors.Is()`to check whether an error matches a specific value, prior to Go 1.13, the idiomatic way to do this was to use `==`to perform the check like:

```go
if err == models.ErrNoRecord {//...
}
```

For this, still compiles, now safer and best practice to use the `errors.Is()`function instead. Cuz Go 1.13 introduced the ability to add additional info to errors by wrapping them. The `errors.Is()`works by *unwrapping* errors as necessary cuz checking for a match.

#### Shorthand single-record queries -- 

In practice can shorten the code slightly by leveraging the fact that the errors from `DB.QueryRow()`are deferred until `Scan()`is called. just:

```go
err := m.DB.QueryRow("SELECT ...", id).Scan(&s.ID...)
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {
        return nil, ErrNoRecord
    }else{
        return nil ,err
 	}
}
return s, nil
```

# Working with relative units

When it comes to specifying *length* values, CSS provides a wide array of options to choose from.

### Power of relative units

CSS brings a *late binding* of styles to the web page -- the content and its styles aren’t pulled together until after the authoring of both is complete. Adds a level of complexity to the design process that doesn’t in other types of graph design, also provides more power -- one stylesheet can be applied to .. of pages.

#### The rise of reponsive design

In the web environment, the user can set their browser window to any number of sizes. This means that styles can’t be applied when create page, the browser must calculate those when the page rendered on screen. Adds a layer of abstraction to CSS, can’t style an element according to an ideal context, need to specify rules that will work in any context where that element could be placed.

With such a vaied array of user devices and screen sizes, have to constantly be aware of *reponsive design*. **Repositive design** is a term which refers to styles that respond differently, based on the size of the browser window.

### Ems and rems

`1em`means that fontsize of the current element. So, its exact value varies depending on the element you are applying it to. Fore:

```css
.padded {
    font-size: 16px;
    padding: 1em;
}
```

Using ems can be convenient when setting properties like `padding height...`

```css
.box {
    padding: 1em;
    border-radius: 1em;
}

.box-small {
    font-size: 12px;
}
.box-large {
    font-size: 18px;
}
```

This is a powerful feature of ems -- can define the size of an element and then scale the entire thing up or down with a single declaration that changes the font size.

#### Using ems to define font-size

When it comes to the `font-size`prop, ems behave a little differently -- ems are defined by the curerent element’s font size -- but, if `font-size: 1.2em`-- can’t equal 1.2 times itself -- instead *font-size are derived from the inherited font-size*.

#### ems for Font-size together with ems for other properties

What makes ems tricky is when use them for both font-size and any other properties on the same element. When do this, *the browser must calculate the font size first, then it uses that value to calculate the other values*.

```css
body {
    font-size: 16px;
}
.slogan {
    font-size: 1.2em; /* 19.2px*/
    padding: 1.2em;  /*23.04 */
}
```

For this, `padding`has a specified of 1.2em, even though `font-size`and `padding`have the same specified value, their calculted values are different.

#### The shrinking problem

So, ems can produce unexpected results when use them to specify the font sizes of multiple *nested* elements. so, to know the exact value for each element, need to know its inherited font size. fore:

```css
body{
    font-size: 16px;
}
ul {
    font-size: 0.8em;
}
```

If U were to apply these styles to a page with multiple nested lists, would see the problem. So sone way U can accomplish this is with the code -- this sets the font size of the first list as before -- the second selector in the listing then targets all unordered lists within an unordered list -- all of them except the top level like:

```css
ul {
    font-size: .8em
}
ul ul {
    font-size: 1em; /* lists within lists should have the same font size as parent */
}
```

### Using rems for font-size

When the browser parses an HTML, it creates a representation in memory of all the elements on the page. This is just called DOM -- it’s a tree structure, where each element is represented by a node.

The root node is the ancestor of all other elements in the document. it has a special *pseudo-class* `(:root)`that you can use to target it. and, This is **equivalent** to using the type selector `html`with the specificty.

And `rem`is short for *root em* -- Instead of being relative to the current element, rems are relative to the root element. No matter where U apply in the document, fore, `1.2rem`has the same computed value.

```css
:root {
    font-size: 1em;
}
ul {
    font-size: 0.8rem;
}
```

 For this, the root font size is the browser’s default of 16px. And unordered lists have a specified font-size of .8rem.

### Stop thinking in pixels

This takes the browser’s default font size fore, 16px and scales it down to 10px -- this practices simplifies the math. When working with ems, it’s just easy to get bogged down obsessing over exactly how many pixels things will evaluate to. especially font sizes. Converting to rems involves arithmetic -- so keep a calculator handy.

#### Setting a sane default font-size

```css
:root {
    font-size: 0.875em;  /* 14/16 */
}
```

```html
<body>
<div class="panel">
  <h2>Single-Origin</h2>
  <div class="panel-body">
    We have built partnerships with small farms around the world to
    hand-select beans at the peak of season. We then carefully roast
    in <a href="/batch-size">small batches</a> to maximize their
    potential.
  </div>
</div>
</body>
```

Then listing shows the styles -- uses `ems`for the padding and border radius..

```css
.panel {
  padding: 1em;
  border-radius: .5em;
  border: 1px solid #999;
}

.panel > h2 {
  margin-top: 0; /* remove extra spaces from the panel top */
  font-size: .8rem;
  font-weight: bold;
  text-transform: uppercase;
}
```

#### Making the panel responsive

Take this a bit further -- can use some media queries to change the base font size. A `@media`rule to specify styles that will be applied only to certain screen size or media types. This is a key component of responsive design.

```css
:root {
  font-size: .85em;
}

@media (min-width: 800px) {
  :root {
    font-size: 1em;
  }
}

@media (min-width: 1200px) {
  :root {
    font-size: 1.15em;
  }
}
```

This first ruleset specifeis a small default font size, this is the font size that want to apply on smaller screens. Then U used media queries to override that value with incrementally larger font sizes on screens. By applying these font sizes at the root on page, responsively redefined the meaning of em and rem throughout the entire page.

#### Resizing a single component

Can also use ems to scale an individual component on the page. Fore, might need a larger versin of the same part of interface on certain parts of the page. fore: `<div class="panel large">`

```css
.panel {
  font-size: 1rem;
}

.panel >h2 {
  font-size: .8em;
}

.panel.large {
  font-size: 1.2rem;
}
```

### Viewport relative units

The *viewport* is the frramed area in the browser window where the web page is visible. so:

- `vh`-- 1% of viewport height
- `vw`-- 1% of width
- `vmin`-- 1% of the smaller deminsion, height or width
- `vmax`-- 1% of larger ones.

### Unitless numbers and line-height

Some properties allow for unitless values -- and note that a unitless 0 can used only for length values and percentages. Can’t be used for angular values. And the `line-height`prop is unusual in that it accepts **both** units and unitless values.

```css
body {
    line-height: 1.2; /*descendant elements inherit the unitless value */
}
body{
    line-height: 1.2em; /* inherits the calculated value */
}
```

These results are due to a peculiar quirk of inheritance -- when an element has a value defined using a length, its computed value is inherited by child elements. And when units such as ems are specified for a line height, their value is calculated, and that calculated value is passed down to any inheriting children.

### Custom properties

```css
:root {
    --main-font: Helvetica;
}
```

This just defines a variable named `--main-font`. The `--`to distinguish it from other CSS properties.

```css
p{
    font-family: var(--main-font); 
}
/* fore */
:root {
    --main-font: Arial;
    --brand-color: #369;
}
p {
    font-family: var(--main-font);
    color: var(--brand-color);
}
```

Also, the `var()`accepts an optional second parameter -- which specifies a *fallback* value like:

```css
p {
    font-family: var(--main-font, sens-serif);
}
```

## Understanding Angular Change detection

Angular automatically reflects changes in the app state in the HTML presented to the user. Modern browsers are excellent at dealing with the complexities of displaying HTMlL, but opeations using the browser’s DOM API are still relatively slow and expensive to perform and Angualr is careful to change as little content as possible when reflecting a state change.

```ts
get count(): number {
    let result = this.model.getProducts().length;
    console.log(`count value read: ${result}`)
    return result
  }

  get total(): string {
    let result = this.model.getProducts()
      .reduce((total, p) => total + (p.price ?? 0), 0).toFixed(2);
    console.log(`Total value read : $ {result}`);
    return result;
  }

  get message(): string {
    let result =`${this.messages[this.index]} $${this.total}`;
    console.log(`Message value read: ${result}`);
    return result;
  }

  toggleMessage() {
    console.clear();
    console.log("toggleMessage method invoked");
    this.index = (this.index + 1) % 2;
  }
  removeProduct() {
    console.clear();
    console.log("removeProduct method invoked");
    this.model.deleteProduct(this.model.getProducts()[0].id ?? 0);
  }
```

By default, Angular uses a library called `zone.js`, which modifies the std browser Js API so that operations that are likely to indicate a change in app state -- such as using an event handler.

During the change detection process, Angular works its way through the components in the app and evaluates the data binding expressions in their templates.

#### The advantage and disvantage of change detection

Advantage of that way deals with changes is simplifity for the developer. The `zone.js`package seamlessly modifies the JS API to trigger change detection and the entire process happens smoothly.

And the main problem with change detection is that Angular doesn’t have any insight into the relationship between dta values or impact of a change on those values. For some, Angular has no way of knowing what the fore `toggleMessage`method does -- it just knows that an event has been dispatched -- which means that change detection is required. A new `index`value leads to a new value for the `message`prop, but Angular *has to* evaluate **all** of the template expressions to figure that out. This just means that any change will trigger the same detection process, which U can confirm by clicking the `Remove`button.

Angular has to evaluate all of the template expression regardless of what change. And, once Angular has evaluated all of the template expressions, it can discard any values that have not changed and efficiently update the HTML displayed to the user. But this means that template expressions are evaluated even when the data they rely on hasn’t changed. And that can be a problem for expensive or time-consuming operations. fore:

```ts
get count(): number {
    let result = this.model.getProducts().length;
    let total=0;
    for(let i=0; i<1000000000; i++) {
        total ++
    }
    //...
}
```

The changes use a `for`to sum to simulate a complex operation required to produce a value. May need to adjust the maximum value in the loop for your system, but the vlaue in the listing takes a few seconds to complete on your development PC.

### Understanding Angular Signals

Angular is going through a period of transformation that affects how change detection is performed. And the key feature is called *signals* -- and they change how data is prepared for use in a template to capture the relationships between values. Singals require the developer to describe the conenctions between data values, which undercuts the simplicity of approach conventionally used by Angular.

- `signal`-- creates a *writeable* signal, which has a value that *can be changed*. Implements the `WritableSignal<T>`interface.
- `computed`-- creates a *read-only* signal, whose value is derived from one or more other signals. The result of this implements the `Signal<T>`interface, where `T`represents the type of the data value computed by the signal
- `effect`-- creates an effect, which is a function that is executed when *one or more specified writable or computed signals changes*. The result is an `EffectRef`object.

#### Using writable signals

Writable signals are created with an initial value that can be modified to reflect changes in the app state.

```ts
private index= signal<number>(0);
toggleMessage() {
    console.clear();
    console.log("toggleMessage method invoked");
    this.index.update(currentVal => (currentVal + 1) % 2);
  }
```

So the writable signals are created with the `signal`function -- The type can be omitted. And the methods like:

- `set`-- accepts a new value for the signal
- `update`-- accept a function that receives the current signal value and return  new value.
- `asReadonly`-- returns a `Signal<T>`which provides a *read-only* version of the signal.

#### Using computed signals

A computed signal produces a value that is based - computed -from other signals. Computed signals are read-only and will be *recombuted when the value is read after one of the signals used to produce a value changes*.

```ts
message = computed<string>(() => {
    let result = `${this.messages[this.index()]} $${this.total}`;
    console.log(`Message value read: ${result}`);
    return result;
  })
```

So, computed signals are created using the `computed()`function, which accepts a func that produces a value. When the func is invoked, Angular keeps track of the signals whose values are read in order to understand the relationship between the data values. For the app, the `message`computed signal reads the value of the `index`signal, which tells Angular that it should only invoke the `message`signal’s function when a change is made to the `index`signal’s value.

CAUTION -- it is important ony to rely on *other signals* when computing a value, otherwise, Angular won’t realize that a change requries a new value to be produced.

For now the method invoked by the button click doesn’t alter the value of the `index`signal, which means that Angular knows the value of the message signal can’t have changed and doesn’t need to be re-calculated.

#### Using effects

Effects are used to execute statements when the value of another signal changes. Effects are less useful than writable or computed cuz the code they execute occurs outside of the change detection process.

```ts
message = computed<string>(() =>
    `${this.messages[this.index()]} $${this.total}`);

  messageEffect = effect(() =>
    console.log(`message value computed: ${this.message()}`));
```

#### Using signals outside of components

Signals can be sued anywhere in an Angular app and shared resources can implement signals to ensure that changes made by one part of the app result in updates elsewhere.

```ts
export class Model {
  private dataSource: SimpleDataSource;
  private products: WritableSignal<Product[]>;
  private locator = (p: Product, id: number | any) => p.id === id;

  constructor() {
    this.dataSource = new SimpleDataSource();
    this.products = signal(new Array<Product>());
    this.products.update(prods => {
      let data = this.dataSource.getData();
      return [...data, ...prods];
    })
  }

  getProducts(): Signal<Product[]> {
    return this.products.asReadonly();
  }

  getProduct(id: number): Product | undefined {
    return this.products().find(p => this.locator(p, id));
  }

  saveProduct(product: Product) {
    if (product.id == 0 || product.id == undefined) {
      product.id = this.generateID();
      this.products.update(prods => [...prods, product]);
    } else {
      this.products.update(prods => {
        let index = prods.findIndex(p => this.locator(p, product.id));
        let copyProds = [...prods];
        copyProds.splice(index, 1, product);
        return copyProds;
      })
    }
  }

  deleteProduct(id: number) {
    this.products.update(prods => {
      let index = prods.findIndex(p => this.locator(p, id));
      if (index > -1) {
        let copyProds = [...prods];
        copyProds.splice(index, 1);
        return copyProds;
      }
      return prods;
    })
  }
 //...
    
}
```

For this, want to expose a signal from the repository so that other parts of the app can compute values. To provide access to the signal without allowing the value to be changed directly, use the `WritableSignal<T>.asReadonly`.

```ts
count = computed(() => this.model.Products().length);
  countEffect = effect(() =>
    console.log(`count value computed: ${this.count()}`));

  get total(): string {
    let result = this.model.Products()
      .reduce((total, p) => total + (p.price ?? 0), 0).toFixed(2);
    console.log(`Total value read : $ {result}`);
    return result;
  }
```

```html
<div class="bg-info text-white p-2">
  There are {{count()}} products in the model
</div>
```

The repository uses signals but ensures that changes are carefully managed. The change to signals means that only the values that have been affected by the `toggleMessage`are recomputed.