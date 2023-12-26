# Vagrant

It is a wrapper utility that works on top of virtual machine solutions like Virtualbox... and also Docker. It just abstract away all the complex activities involeved in managing a VM through the VM solutions and can automate most of the tasks.

```bash
vargrant init hashicrop/bionic64
```

Before can continue to the next, ensure that Vagrant has created a `Vagrntfile`.

### Start the vritual machine -- 

Now that have a `Vagrantfile`that configures your deployment, can start the vritual machine --

```bash
# start the virtual machine
vagrant up
# destroy the virtual machine
vagrant destroy
```

Docker is a platform for running appliations in lightweight units called *containers*.

##### Migrating apps to the cloud

Docker doesn’t automatically clean up containers or app packages for you when quit, all you container stop and they don’t use any CPU or memory, but if want to, can clean up at the end of every .

### Custom error types and `errors.As()`

Know that `error` is just an interface, so also know that any *user-defined* type can implement `error`, provided it as a suitable `Error`method. like:

```go
type ErrUseNotFound struct {
    User string
}
func (e ErrUserNotFould) Error() string {
    return fmt.Sptinrf("user %q not found", e.User)
}
```

Instantiating an error value like thsi is easy. Can simply return a struct literal of this type, containing the dynamic info we want to include -- like:

```go
func findUser(name string) (*User, error){
    user, ok := userDB[name]
    if !ok {
        return nil, ErrUserNotFound{User:name}
    }
    return user, nil
}
```

And, before the advent of the `errors`package, would have inspected such error values using a *type assertion*-- just as would find out the dynamic type of any interface in go like:

```go
if _, ok := err.(ErrUerNotFound); ok {
    //...
}else{
    //...some other kind of error
}
```

But, the `errors`package now just provides a better way to match the error type we are interested in. This time it’s not `errors`, but `errors.As()`like:

```go
if errors.As(err, &ErrUserNotFOund{}) {
    // this is just a UserNotFound error
}
```

Need to clearly distinguish these two similar-sounding functions. -- `errors.Is()`just tells you whether `err`is some specified error `value`, perhaps wrapped within many layers of info. On the other hand, `errors.As()`tells you whether it’s some specified error *type*. FORE:

```go
func TestFindUser_GivesErrUserNotFoundForBogusUser(t *testing.T){
    t.Parallel()
    -, err := user.FindUser("bogus user")
    if !errors.As(err, &user.ErrUserNotFound{}) {
        t.Errorf("...%v", err)
    }
}
```

Node.js is an async, event-driven Js runtime that offers a powerful but concise stdlib. Manged and supported by the Node.js Foundation, and since Node.js appeared in 2009, Js has gone from a barely tolerated browser-centric lang to one of the most important languages for all kinds of software developmen.

### A typical Node Web App

One of the strengths of Node and Js in general is their single-threaded programming model. Threads are a common source of bugs.

The event loop -- Fore, node’s built-in HTTP server library -- which is a core module called http.Server, handles the request by using a combination of streams, events, and Node’s HTTP request parser, which is native code. This trigers a callback in your application to run. The callback that runs causes a dbs query fore, and eventually the application responds with JSON using HTTP. These whole process uses a minimum of three non-blocking network calls.

And the event loop runs one way and goes through several phases.

### Node’s built-in tools

Comes with a built-in package manager, the core Js modules that support everything from file and network I/O to zlib compression, and a debugger. The `npm`package manager is just a crtical piece of this infrastructure, so just like

```sh
node -v
npm -v
```

npm -- The command-line tool can be invoked -- use it to install packages from the central npm registry. Also use it to find and share you own open and colosed source projects. Every npm package in the regitry has a website and shows the readme file..

When installing packages with the npm install command, have to decide whether you are adding them to your current project or installing globally. Globally installed packages are usually used for tools, typically program u run on the command line -- good example of this is the cli package. To use

```sh
npm init -y
```

See a simple JSON file that describes your proj, if now install a module and use --save option, npm will automatically update your `package.json`file.

### The core modules

Node’s core modules are similar to other language’s stdlib - these are the tools you need to write server-side Js. The Js std themselves don’t include anything for working with the network.

And nod ships with a file system library `fs`path - TCP clients and severs (net), HTTP and domain resultion. Node also has libraires that are unique to Node. The stream module uses the events modules to provide abstract interfaces for working with streams of data. FORE:

```js
const fs = rquire('fs');
const zlib = require('zlib')
const gzip = zlib.createGzip();
const outStream = fs.createWriteStream('output.js.gz');
fs.createReadStream('./node-stream.js')
.pipe(gzip).pipe(outStream);
```

Networking -- Used to say that creating a simple HTTP server was Node’s true -- like:

```js
const http = require('http');
const port=8080;
const server = http.createServer((req, res)=> {
    res.end('hello world');
});
server.listen(port, ()=> {
    console.log(...)
})
```

Debugger -- Node inclues a debugger that supports single- steppinga nd REPL like:

```sh
node debug hello.js
```

### The 3 main types of Node program

Node program can be divided into 3 typical types -- web apps, command line tools and daemons. Node is just server-side js, so it makes sense as a platform for building web apps, by running Js on both the client and the server.

```js
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('hello world');
});

app.listen(3000, () => {
    console.log("express web app on localhost:3000");
});
```

Starting a new Node proj -- create a new Node proj -- create a folder and run `npm init`. -y mean yes--- means npm will create a package.json with diefault values.

To create a typical module, create a file that defines properties on the `exports`object with any kind of the data.

```js
const canadianDollar = 0.91;
function roundTwo(amount) {
    return Math.round(amount * 100) / 100;
}

exports.canadianToUS = can => roundTwo(can * canadianDollar);
exports.USTOCanadian = us => roundTwo(us / canadianDollar);
```

Now that only two props of the `exports`object are set, therefore, only the two function can be accessed by the application including the module.

```js
const currency = require('./currency')
console.log('50 can dollars equas');
console.log(currency.canadianToUS(50));
console.log('30 us');
console.log(currency.USTOCanadian(30));
```

Requiring a module that begins with `./`means that if you were to crate your application script named.

## Prepared statements -- 

As mentioned - the `Exec(), Query()`and `QueryRow()`methods all use prepared stements behind the scenes, to help prevent SQL injection attacks. They set up a prepared statement on the dbs connection, run it with the parameters provided, and then close the prepared statement.

In theory, a better approach could be make use of the `DB.Prepare()`method to just create own prepared statement once, and reuse that instead. This is just particular true for complex SQL statements and are repeated very often.

```go
// need somewhere to store the prepared statement for the liftime of our
// web application
type ExampleModel struct {
    DB *sql.DB
    InsertStmt *sql.Stmt
}

// create a ctor for the model, in which set up the prepared statement
func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    insertStmt, err := db.Prepare("insert into...")
    if err != nil {
        return nil, err
    }
    return &ExampleModel{db, insertStmt}, nil
}

func (m *ExampleModel) Insert(args...) error {
    _, err := m.Insertstmt.Exec(args...)
    return err
}

func main(){
    db, err := sql.Open(...)
    if err != nil {
        errLog.Fatal(err)
    }
    
    defer db.Close()
    
    // create a new ExampleModel
    exampleModel, err := NewExampleModel(db)
    if err!= nil {
        errorLog.Fatal(err)
    }
    
    defer exampleModel.InsertStmt.Close()
}
```

NOTE: Prepared statements exist on dbs connections -- cuz go uses a pool of *many dbs connections*-- what actullaly happens is that the first time a prepared statement is used it gets created on a particular dbs connection. The `sql.Stmt`then remembers which connection in the pool was used. The net time, the sql.Stmt object will attempt to use the same dbs connection again.

Under heavy load, it’s possible that a large amount of prepared statements will be created on multiple connections.

Dynamic HTML templates -- 

- Pass dynamic data to HTML templates in a simple scalable and type-safe way
- Use the various actions and functions in go’s `html/template`package to control the display of dynamic data.
- Create a template cache so that your templates aren’t being read from disk for each HTTP requeste.
- Gracefully handle template rendering errors at runtime
- Implement a pattern for passing common dynamic data to your web pages without repeating code
- Create own *custom functions* to format and display data in your HTML templates.

### Displaying Dynamic data

In this section will update this so that the data is displayed in a proper HTML webpage which looks like just: start in the `showSnippet`handler and add some code to render a new `show.page.html`template file.

```go
s, err := app.snippets.Get(id)
if err != nil {
    if errors.Is(err, models.ErrNoRecord) {
        app.notFound(w)
    } else {
        app.serverError(w, err)
    }
    return
}
files := []string{
    "./ui/html/show.page.html",
    "./ui/html/base.layout.html",
    "./ui/html/footer.partial.html",
}

// parse the template files...
ts, err := template.ParseFiles(files...)
if err != nil {
    app.serverError(w, err)
    return
}

// and then execute them
err = ts.Execute(w, s)
if err != nil {
    app.serverError(w, err)
}
```

So, need to create the `show.page.html`file containing the HTML markup for the page.

```html
{{template "base" .}}

{{define "title"}}Snippet # {{.ID}} {{end}}

{{define "main"}}
    <div class="snippet">
        <div class="metadata">
            <strong>{{.Title}}</strong>
            <span>@{{.ID}}</span>
        </div>

        <pre><code>{{.Content}}</code></pre>
        <div class="metadata">
            <time>Created: {{.Created}}</time>
            <time>Expires: {{.Expires}}</time>
        </div>
    </div>
{{end}}
```

Rendering multiple pieces of data -- An important thing to explain that Go’s `html/template`package allows you to pass in one and only one item of dynamic data when rendering a template -- but in a real-world application there are often multiple pieces of dynamic dta that you want to display in the same page. And a lightweight and type-safe way to acheive this to wrap your dynamic data in a struct which acts like a single *holding structure* for your data.

```go
// define a templateData type to act as the holding structure for any dynamic data that
// we want to pass to our HTML templates.
type templateData struct {
	Snippet *models.Snippet
}
```

Update the handler.go like: For this the snippet data is contained in a `models.Snippet`struct within a `templateData`struct, to yield the data need to chain the approprite filed names together like so:

`#{{.Snippet.ID}}`

Additional -- The `html/template`package automatically escapes any data that is yielded between `{{}}`tags. This behavior is hugely helpful in avoiding cross-site scripting (XSS) attacks, and is the reason that you should use the `html/template`package instead of the more generic `text/template`package that Go also provides.

Nested Templates -- It’s really important to note that when are invoking one template from another template, d*ot needs to be explicitly passed or pipelined to the template being invoked*.

Calling Methods -- If the object that you are yielding has methods defined against it, can call them -- FORE, if `.Snippet.Created`has the underlying type `time.Time`u could render the name of the weekday by calling its `Weekday()`like:

```html
<span>{{.Snippet.Created.Weekday}}</span>
```

Can also pass parameters to methods. like:

```html
<span>{{.Snippet.Created.AddDate 0 6 0 }}</span>
```

### Template Actions and functions

Going to look at the template actions and functions that Go provides -- Already talked about some of the actions, There are three more which U can use to control the display of dynamic data`{{if}} {{with}} {{range}}`

- `{{with .Foo}} C1 {{else}} C2 {{end}}` -- If `.Foo`is not empty, then set dot to the vlaue of `.Foo`and render the content C1, other C2
- `{{range .Foo}} C1 {{else}} C2 {{end}}` -- If the length of `.Foo`is greater then 0 then loop over each element, setting dot to the value of each element and rendering the content C1.
- The *empty* values are false, 0, any nil poitner or interface, and array, slice, map, or string of len is zero.
- It is important to grasp that the `with`and `range`actions change the value of dot. Once you start using thim, what dot represents can be different depending on where you are in the template and what you are doing.

And also note that the `html/template`also provdies some template functions which you can use to add extra logic to your templates and control what is rendered at runtime like:

- `{{eq .Foo .Bar}}`
- `ne, not, or`
- `{{index .Foo i}}`-- yields the value of `.Foo`at index i -- The underlying type of `.Foo`must be a `map slice array`.
- `{{printf "%s-%s" .Foo .Bar}}` -- same way as the `fmt.Sprintf()`
- `{{len .Foo}}`-- yields the length
- `{{$bar:= len .Foo}}` -- assign the length to the variable `$bar`

Using the `with`-- A good to use the `{{with}}`is the `show.page.html`file -- like:

```html
{{with .Snippet}}
<div class="snippet">
    <div class="metadata">
        <strong>{{.Title}}</strong>
        <span>@{{.ID}}</span>
    </div>
<!-- ... -->
```

Between `{{with .Snippet}}`and the corresponding `{{end}}`tag, the value of dot is set to `.Snippet`. Dot essentially becomes the `models.Snippet`struct instead of the parent `templateData`struct.

Using the `if`and `range`-- Firt update the `templateData`struct so that it can contain a `Snippets`filed for holding a slice of snippets like:

```go
type templateData struct {
	Snippet *models.Snippet
	Snippets []*models.Snippet
}
```

Update the `home`so that it fetches the latest snippets from our dbs model and passes them to the template like:

```html
{{define "main"}}
    <h2>Latest Snippet</h2>
    {{if .Snippets}}
        <table>
            <tr>
                <th>Title</th>
                <th>Created</th>
                <th>ID</th>
            </tr>
            {{range .Snippets}}
                <tr>
                    <td><a href="/snippet?id={{.ID}}">{{.Title}}</a></td>
                    <td>{{.Created}}</td>
                    <td>#{{.ID}}</td>
                </tr>
            {{end}}
        </table>
    {{else}}
        <p>There is nothing to see here... yet!</p>
    {{end}}
{{end}}
```

