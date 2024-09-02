# Remote Repository (2)

Will look at the different ways you can use either local or remote repositories to start working with Git project and why remote repositories are useful.

### State of the Local Repository

red <- orange <- yellow <=main<-HEAD ,feature

Starting from a local repostiory -- `git push` -- An example of a situation where U would start to work on a Git from a local repository is if U have a project on your computer that you have been working on for a while that is not a repository.

Starting from a remote repostiory -- Then *clone* the remote repository to your local computer.

#### The interaction between Local and Remote Repositories -- 

Local repositoies and remote repositories act separately -- when it come to working with them -- it’s important to understand that no interaction between them happens automatically. No updates from the local to the remote will happen automatically.

When Create a new remote repository on a hosting -- give it a *remote repository project name* and the hosting service will provide a *remote repostiory URL*.

### Adding a connection to the remote Repository

A local repository can communicate with a remote repository when the local repository has a connection to the remote repository stored within it. This connection will have a name -- *remote repository shortname*. To do this, will use the `git remote add`command like;

```sh
git remote add <shortname> <URL>
# to see the list of connections to the remote repository
git remote
git remote -v
```

### Remote Branches and Remote-Tracking Branches

When push a local branch to a remote repository, will create a *remote branch* -- is a branch in a remote repository. Remote branches do not automaticlly update when make more commits on local branches. So, have to explicitly push commits from a local branch to a remote.

Every remote branch( that local knows about) also has a *remote-tracking* branch. -- This is a reference in a local repository to the commit a remote branch pointed at the *last time any network communication happended* with the remote repository. Like a bookmark.

Can set up a tracking relationship between a local and a remote branches by defining which remote branch a local branch should track. When use the `git push`with no arguments, the Git will *automatically* pusth the work to that branch -- upstream branch defined for it. Namely -- by defining which remote branch should track.

```sh
git push <shortname> <branch_name>
# make some change
git push origin main
git branch --all # *main feature remote/origin/main
git log # HEAD-> main, origin/main, feature
```

See `refs`directory has a new directory inside it called `remotes`-- inside the `remotes`is `origin`, `main`. so:

```sh
git switch feature
git push origin feature
git branch --all # *feature, main, remotes/origin/feature, remotes/origin/main
git log
```

For this, has two remote-tracking branches, origin/main and origin/feature, and `rainbow-remote`repository are two remote branches -- `main`and `feature`.

Have now created a remote repository with data -- 

#### Working on a remote repostiory directly on a Hosting service

### Cloning and Fetching

A local repository called `rainbow`and remote one called `rainbow-remote`-- these two should be in *sync* -- should contain the same commits and branches.

#### Cloning a Remote Repository

Created a remote repository on a hosting services so could show your friend has decided they want to help U work on the project. Cloning remote repositories is an essential part of being able to collaborate with other people on a Git project. Since it allows them to work with their own copy of the repository on their computer. 

```sh
git clone <URL> <directory_name>
```

1. Create a proj directory inside the current directory
2. Create the local repository
3. Download all the data from the remote repository
4. Add a connection to the remote repository that was cloned, by default, it will have the shortname `origin` in the new local repository.

```sh
git clone https://github.com/Ianwoo77/rainbow-remote.git friend-rainbow
git remote -v
git branch --all # *main remotes/origin/HEAD remotes/origin/main
git log
```

What is the *Origin/HEAD*-- noticed that there is a pointer called `origin/HEAD`in the `friend-rainbow`. Cuz, when clone a repository, Git needs to know which branch it should be on when it is done cloning. The `origin/HEAD`pointer determines which branch this is. For this, the `origin/HEAD`points to the `main`branch, which is why your friend that cloned the repository is on the `main`. And in the `friend-rainbow`, the local `feature`doesn’t even exist. However, there is a reference to the `origin/feature`-- cuz when U clone a repository the `git clone`will create remote-tracking branches for all the branches currently present in the remote repostiory that is being cloned, but the only local branch that is created is the branch the `origin/HEAD`points to.

```sh
# for feature work, switch to it
# for the rainbow proj, must push from the feature branch
git branch --all
git switch feature # set up to track origin/feature, switched to new branch feature
git branch --all
git log
```

For this can see that there is a new local `feature`branch and you friend on it.

## Aware of the possible problems type embedding

When create a struct, Go offers the option to embed types. But this can sometimes lead to unexpected behaviors if we don’t understand all the implications of type embedding. In Go, a struct field is called *embedded* if it’s declared without a name like:

```go
type Foo struct {
    Bar
}
type Bar struct {
    Baz int
}
```

Use embedding to *promote* the fields and methods of an embedded type. Cuz `Bar`caontains a `Baz`, this field is just promoted to `Foo`, therefore, `Baz`become just available from `Foo`. And note that the `Baz`is available from two differenet paths -- either from *promoted* one using `Foo.Baz`or from the nominal one `Foo.Bar.Baz`.

#### Interfaces and embedding

Embedding is also used within interfaces to compose an interface with others, in the following exmaple like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

For, in the following, implement a struct that holds some in-memory data, and want to protect it against concurrent access using a mutex like:

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem {
    return &InMem {m: make(map[string]int)}
}
```

Decided to make the `map`*unexported* so that clients can’t interact with it directly but only via exported methods.

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

For this, cuz the mutex is embedded, can directly access the `Lock`and `Unlock`-- Such an example is a wrong usage of type embedding -- Since `sync.Mutex`is an embedded type, the `Lock`and `Unlock`will be *promoted*. Therefore, both methods become *visible* to external clients using `InMem`. Fore:

```go
m := inmem.New()
m.Lock() // What for?
```

This promotion is probable not desired -- A mutex is, in most cases, sth that we want to encapsulate within a struct nad make invisible to external clients. Therefore, shouldn’t make it an embedded one:

```go
type InMem struct {
    mu sync.Mutex
    m map[string]int
}
```

For now, isn’t embeeded and is unexported, it can’t be accessed from external clients.

Then, want to write a custom logger that contains an `io.WriteCloser`and exposes two methods, `Write`and `Close`, if `io.WriteCloser`wasn’t embedded, would need to write it like:

```go
type Logger struct {
    writeCloser io.WriteCloser
}
// must provide both `Write`and `Close` method, 
// however, if the field now becomes embedded, can remove these forwarding methods.
type Logger struct {
    io.WriteCloser
}
```

If decide to use type embedding, need to keep two main constraints in mind -- 

1. It shouldn’t be used solely as syntactic sugar to simplify accesing a field. If this is the only rationale, not embed the innter, and use a field.
2. It shouldn’t promote data or a behavior we want to hide fromt he outside.

### Using functional optoins pattern

When designing API, one question may arise -- how do we deal with *optional configuration* --  Solving this efficiently can improve how convenient our API will becomes. Fore, have to design a library that exposes a function to create an HTTP server -- would accept different inputs, address, port, following shows the skeleton -- 

```go
func NewServer(addr string, port int) (*http.Server, error) {...}
```

Note, for this, add new function parameters will break the compatibility -- forcing clients to modify the way they call `NewServer`-- in the meantime, would like to enrich the logic related to port management this way. There are different options -- 

#### `Config`struct

The first possible approach is to use a configuration struct to convey what is mandatory and want is optional. Fore, the mandatory parameters could live as function parameters, and the optional ones could be handled in the `Config`struct.

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config) {...}
```

This solution fixes the compatibility issue. It will not break on the client client -- this approach doesn’t solve our requirement related to port management. 

Should bear in mind that *If a struct field is not provided, it’s initialized to its zero value*. Fore, `nil`for slices, maps...

So, in the case, need to find a way to distinguish between a port purposely set to 0 and a missing port. Fore:

```go
type Config struct {
    Port *int
}
```

Using integer, can highlight the difference between the value 0 and a missing value `nil pointer`. Works -- but it has a couple of downsides. It’s not handy for clients to provide integer pointer like:

```go
port := 0
config := httplib.Config{
    Port : &port,
}
```

The overall API becomes a bit less convenient to use. And the second is that client using this with the default configuration will need to pass an empty struct. `httplib.NewServer("localhost", httplib.Config{})`

#### Builder Pattern

The construction of `Config`is separated from the struct itself -- it requires an extra struct -- `ConfigBuilder`which receives methods to configure and build the `Config`. like:

```go
type Config struct {
    Port int
}
type ConfigBuilder struct {
    port *int
}
func (b *ConfigBuilder) Port(port int) *ConfigBuilder {
    b.port = &port
    return b
}
func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port == nil {
        cfg.Port= defaultHTTPPort
    }else {
        if *b.port==0 {
            cfg.Port= randomPort()
        }else if *b.port<0 {
            return Config{}, errors.New("...")
        }else {
            cfg.Prot=*b.port
        }
    }
    return cfg, nil
}
func NewServer(addr string, config Config) (*http.Server, error ){}
```

Then, a client would use the API like:

```go
builder := httplib.ConfigBuilder{}
builder.Port(8080)
cfg, err := builder.Build()
if err != nil {
    return err
}
server, err := httplib.NewServer("localhost", cfg)
if err != nil {
    return err
}
```

For this pattern, the client creates a `ConfigBuilder`and uses it to set up an optional field, `port`. This approach makes port management handier, not required to pass an integer pointer, as the `Port`method accepts an integer. Still need to pass a config struct that can be empty if a client wants to use the default configuration like:

`server, err := httplib.NewServer(“localhost”, nil)`

And another downside, -- is related to error management. If want to keep the ability to chain the calls, the function can’t return an error.

#### Functional options pattern

The main idea is as - 

- An **unexported** struct holds the configration: `options`. for this, `port *int`
- Each options is a function that returns the same type -- `type Option func(option *options) error`

```go
type options struct {
    port *int
}
type Option func(options *options) error

func WithPort(port int) Option {
    return func(options *options) error {
        if port < 0 {
            return errors.New("Port should be positive")
        }
        options.port= &port
        return nil
    }
}
```

Here the `WithPort`returns a closure, a *closure* is an anonymous function that references variables from outside its body -- the `port`variable here - the closure respects the `Option`type and implements the port-validation logic. And each config field requires creating a public func containing similar logic. So:

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    
    var port int
    if options.port == nil {
        port= defaultHTTPport
    }else {
        //...
    }
}
```

The use case like:

```go
server, err := httplib.NewServer("localhost",
                                 httplib.WithPort(8080),
                                 httplib.WithTimeout(time.Second))
```

Start by creating an empty `options`, then iterate over each `Option`argument and execute them to mutate the `options`struct. However, if the client needs just the default configuration, it dosn’t need have to provide an argument -- this is the functional options pattern -- provides a handy and API-friendly way to handle options.

## Catching runtime errors

Added a deliberate error to the `view.html`file like: `{{len nil}}`, running the app, find everything just comiples OK. For the output, is pretty bad -- our app has thrown an error, but the user has wrongly been sent a 200OK, and even worse, received a half-complete HTML page.

To fix this, need to make the template render a two-stage process. First, should make a *Trail* render by writing the template into a *buffer*. If fails, can respond to the user with an error message, but if works, can then write the contents of the buffer to our `http.ResponseWriter`. Just update the `render`like:

```go
// Initialize a new buffer
buf := bytes.Buffer{}

// Write the template to the buffer, instead of straight to the
// http.ResponseWriter.
err := ts.ExecuteTemplate(&buf, "base", data)
if err != nil {
    app.serverError(w, err)
    return
}

// If is written to the buffer without any errors
w.WriteHeader(status)
buf.WriteTo(w)
```

### Common dynamic data

In some web apps there may be common dynamic data that U want to include on more than one -- or even every webpage. Fore, might want to include the name and profile picture of the current user, or a CSRF token. Fore:

```go
type templateData struct {
	CurrentYear int
	//...
}
```

Next is to add a `newTemplateData()`helper to our app, which will return a `templateData`struct initialized with the current year -- like:

```go
// Create an newTemplateData(), returns a pointer to a tempalteData struct
func (app *application) newTemplateData(r *http.Request) *templateData {
    return &templateData{
        CurrentYear: time.Now().Year(),
    }
}
// ...
data := app.newTemplateData(r)
data.Snippets=snippets
app.render(w, http.StatusOK, "home.html", data)
```

Then need is update the `base.html`file to display the year in the footer like:

```html
<footer>Powered by <a href='https://golang.org/'>Go</a> in {{.CurrentYear}}</footer>
```

### Custom template functions

Create a custom `humanDate()`function which outputs datetimes in a nice format.

1. Need to create a `template.FuncMap`object contianing the custom `humanDate()`
2. need to use the `template.Funcs()`to register this before parsing the templates

```go
func humanDate(t time.Time) string {
    return t.Format("02 Jan 2006 at 15:04:05")
}
// Initialize a template.FuncMap object and store it in a global variable
var functions = template.FuncMap{
    "humanDate": humanDate,
}

// ....
for _, page := range pages {
    // Extract the file name from the full file path
    name := filepath.Base(page)

    // The template.FuncMap{} must be registered with the template set before U
    // call the ParseFiles() method.
    ts, err := template.New(name).Funcs(functions).ParseFiles(
        "./ui/html/base.layout.html")

    if err != nil {
        return nil, err
    }
    // ...
}
```

Note -- custom template functions like `humanDate()`can accept as many parameters as they need to-- but they must return one value only -- the only exception to this is if want to return an error.

`<td>{{humanDate .Created}}</td>`

```html
<time>Created: {{humanDate .Created}}</time>
<time>Expires: {{humanDate .Expires}}</time>
```

### Middleware

When are building a web app there is probably some shared functionality that you want to use for many HTTP requests, fore, might want to log every request, compress every response, or check a cache before passing the request to your handlers -- And a common way of organizing this shared functionality is to set it up as *middleware* --  This is essentially some self-contained code which independently acts on a request before or after your normal app handlers.

- An idiomtic pattern for building and using custom middleware which is compatible with `net/http`and many 3rd-party packages
- How to create middleware which sets useful security headers
- Create middlewares logs the requests
- Recovers panics
- Composable middleware chains.

Can think of a Go web app as a *chain* of `ServeHTTP()`methods being called one after another. Currently, when server receives a new HTTP request it calls the `serveMux's ServeHTTP()`-- looks up the relevant handler based on the request URL path, and in turn call that handler’s `ServeHTTP()`.

The basic idea of middleware is to insert another handler into this chain -- The middleware handler executes some logic, liking logging a request, and then calls the `ServeHTTP()`of the `next`handler in the chain. The `http.StripPrefix()`-- removes a specific prefix.

#### The pattern

The std pattern for creating your own middleware looks likt -- 

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        //... TODO: Execute our middleware logic
        next.ServeHTTP(w,r)
    }
    return http.HandlerFunc(fn)
}
```

#### Positioning the middleware

It’s just important to explain that where U position the middleware in the chain of handlers will affect the behavior of your application -- if U position your middleware before the servemux in the chain then it will act on every request that your app receives. `myMiddleware-> serveMux -> App handler`

Alternatively, can position after the `serveMux`-- by wrapping a specific app handler -- 
`serveMux-> myMiddleware -> app handler`

### Setting security Headers

Put the pattern -- make our own middleware which automatically adds the following HTTP security headers.

- `Content-Security-Policy`-- CSP headers are used to restrict where the resources for your web page can be loaded from Setting a strict CSP policy helps prevent a variety of cross-site scripting.
- `Referrer-Policy`-- used to control what info is included in the `Referer`when user navigates away from your web page. `origin-when-cross-origin`-- full URL will be included for `same-origin-requests`.
- `X-XSS-Protection: 0` -- used to *disable* the blocking of cross-site scripting attacks.

```go
func secureHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Security-Policy",
			"default-src 'self'; style-src 'self' fonts.googleapis.com; font-src fonts.gstatic.com")

		w.Header().Set("Referrer-Policy", "origin-when-cross-origin")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "deny")
		w.Header().Set("X-XSS-Protection", "0")

		next.ServeHTTP(w, r)
	})
}
```

Cuz we want this middleware to act on every request that is received, need it to be executed before a request hits our servemux. `secureHeaders-> servemux-> app headers` so need:

```go
func (app *appliation) routes() http.Handler {
    mux := http.NewServeMux()
    //...
    return secureHeaders(mux)
}
```

#### Additional info -- Flow of control -- 

It’s important to know that when the last handler in the chain returns, control is passed back up the chain in the *reverse direction*. So when the app is being executed, the flow of control actually look like:

secureHeaders -> serveMux -> app handlers ->serveMux-> secureHeaders

So, In any middleware handler, code which comes before the `next.ServeHTTP()`will be executed on the way down the chain, and after the `next.ServeHTTP()`or in a `defer func`will be executed on the way back up.

#### Early returns

Another thing to mention is that you call `return`in middleware func before U call `next.ServeHTTP()`then the chain will stop being executed and control will flow back upstream. Fore:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w, r) {
        if !isAuthorized(r) {
            //...stop the chain
            return
        }
        // otherwise call the handler
    })
}
```

