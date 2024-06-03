# Password to df

As we’ve seen, CSV is a very flexible format, many files that you wouldn’t necessarily think of as being CSV files can be imported into pandas with `read_csv`-- Want U to create a data frame from a file that you won’t normally think of as CSV but that **fits** the format fine -- Unix `passwd`file -- which is just a standard on Unix and Linux systems, contains usernames and passwords.

1. Create the data frame based on `linux-etc-passwd.txt`-- The file contains comment lines and blank lines
2. Add column names -- 
3. Make the `username`the index

### Working it out

For this, pull out all the stops -- passing more argument to `read_csv`file than ever before -- Each is necessary to parse the `passwd`file correctly -- For starters, CSV files are named for the default field separator, comma, by default, pandas assumes that we have comma-separated vlaues -- fine if want to use another character. fore this, jsut using:
`sep=':'`to the `read_csv`.

Comments all start with `#`characters and the `header`, If a file contains headers but not on its first line, can set header to an integer value, if None, just like `header=None`, and for the *blank_lines*, just like:
`skip_blank_lines=False`rather than accepting the default value of `True`. And the final keyword arg pass is `names`-- if don’t given any `names`-- the data frame’s columns will be labeled with integers starting with 0.

```python
f= pd.read_csv('linux-etc-passwd.txt',
                sep=':',
                comment='#',
                header=None,
                names='username password userid groupid name homedir shell'.split())
```

#### Beyond the exercise -- 

```python
names = np.array('username password userid groupid name homedir shell'.split())
cols = np.delete(names, np.where(np.isin(names, ['password', 'groupid'])))
df= pd.read_csv('linux-etc-passwd.txt',
                sep=':',
                comment='#',
                header=None,
                usecols=cols,
                names=names)
```

- Immediately after logging into a Unix system, a command interpreter like:
  `df['shell'].drop_duplicates()`

### Bitcion vlaues

And, when we think about CSV files, it’s often in the context of data that has been collected once and that we now want to examine and analyze. But, there are numerous examples of computer sytems that publish updated data regularly and make their findings known via CSV files.

- Strings containing filenames
- Readable file-like objects, typically the result of calling `open`, also `StringIO`objects
- Path objects, such as instances of `pathlib.Path`
- Strings containing URLs

Can pass a URL to `read_csv`, and assuming the URL returns a CSV file, pandas will return a new data frame. The rest of the parameters are the same as any other calle to `read_csv`. The only difference is that we are reading from a URL rather then from a file on a filesystem.

#### Using requests

In many cases, CSV files published to a URL require authentication.. Can’t retrieve via `read_csv`, need to retrieve the data separately, perhaps using the `requests` like:

```python
import requests
from io import StringIO
r = requests.get('http://...csv')
s = StringIO(r.content.decode())
df = read_csv(s)
```

```python
import requests
from io import StringIO

r = requests.get('https://finance.yahoo.com/quote/%5EGSPC/history?p=%5EGSPC', 
                headers={'User-Agent': 'Mozilla/5.0'})

df = pd.read_html(StringIO(r.content.decode()))[0].set_index('Date').iloc[:-1]
f['Close*'] = df['Close*'].astype(np.float64)
# create two-row data frame with the highest and lowest closing prices for the `S&P 500`
print(df.loc[df['Close*'].agg(['idxmin', 'idxmax']), 'Close*'].to_csv())
```

## Function Options Pattern

The last approach we will discuss is the functional option pattern -- although there are different IMPs with minor variations, the main idea is as follows -- 

- An unexported struct holds the configuration: options.
- Each option is a *function* that returns the same type: `type Option func(options *options) error`-- fore, `WithPort`accepts an `int`argument that represents the port and returns an `Option`type that represents how to udpate the `options`struct.

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
		options.port = &port
		return nil
	}
}
```

Here, `WithPort`returns a closure, a *closure* is an anonymous function that references variables from outside its body, in this case, the `port`variable, The closure repects the `Option`type and implements the port - validation logic. Each config field requires creting a public function containing similar logic.

```go
func NewServer(addr string, opts ...Option) (
	*http.Server, error) {
	var options options
	for _, opt := range opts {
		err := opt(&options)
		if err != nil {
			return nil, err
		}
	}
	
	// at this stage, the options struct is built and contains the config
	// therefore, can imp our logic related to port configuration
	var port int
	if options.port == nil {
		port = defaultHTTPPort
	}else {
		if *options.port==0 {
			port= randomPort()
		}else{
			port = *options.port
		}
	}
}
```

For this, cuz `NewServer()`accepts variadic `Option`arguments, a client can now call this API by passing multiple options following the mandatory address argument fore -- 

```go
server, err := httplib.NewServer("localhost",
                                 httplib.WithPort(8080),
                                 httplib.WithTimeout(time.Second))
```

### Project Organization

If proj is small enough -- not good -- otherwise, it might be worth considering -- like:

- `/cmd`- the main source files -- the `main.go`file of an app should live in like: `/cmd/foo/main.go`
- `/internal`-- Private code **DON’T** want others importing for their apps or libraries.
- `/pkg`-- Public code that want to expose to others
- `/test`-- Additional external tests and test data. Unit test in Go live in the same package as the source files.
- `/configs`-- configuration files
- `/docs`-- Design and user documents
- `/example`-- 
- `/api`-- API contract files, fore, Swpagger, Protocol Buffer...
- `/web`-- web app-specific assets
- `/build`-- Packaging and continuous integrations file
- `/scripts`- Scripts for analysis
- `/vendor`-- app dependencies

### Creating utility Packages Don’t do this

Bad practice, creating shared packages such as `utils, common`or `base`. Fore, about implementing a set data structure -- the idiomatic way to do this in Go is to handle it via a `map[K]struct{}`type with `K`that can be any type allowed in a map as a key, whereas the value is a `struct{}`type.

```go
package util
func NewStringSet(...string) map[string]struct{} {
    //...
}
func SortStringSet(map[string]struct{}) []string {
    //...
}
```

And a client will use this package like this:

```go
set := util.NewStringSet("c", "a", "b")
fmt.Println(util.SortStringSet(set))
```

Here the problem here is that `util`is meaningless -- could it `common shared base`but it remains a meaningless name that doesn’t provide any insight about what the package provides.

So, instead of a utility package, should create an expressiv package name such as `Stringset`. Then, could go a step further -- instead of exposing utility functions, could create a specific type and expose `Sort`as a emthod this way -- 

```go
package stringset
type Set map[string]struct{}
func New(...string) Set {...}
func (s Set) Sort() []string{...}
```

This change makes the client even simpler. like:

```go
set := stringset.New("c", "b", "a")
fmt.Println(set.Sort())
```

### Don’t ignore package name collisions

Package collisions occur when a variable name collides with an existing package name, preventing the package from being reused -- like:

```go
package redis
type Client struct {...}
func NewClient() *Client {...}
func (c *Client) Get(key string) (string, error) {...}
// fore:
redis := redis.NewClient()
v, err := redis.Get("foo")
```

For this, the `redis`variable name collides with the `redis`package name -- for this is allowed-- *should be avoided*. Throughout the scope of the `redis`variable, the `redis`package won’t be accessible.

In that case, it might be ambiguous for a code reader to know what a qualifier refers to -- what are the options to avoid such a collision -- the first option is to use a different variable name fore -- 

```go
redisClient := redis.NewClient()
v, err := redisClient.Get("foo")
```

Or, using package imports -- can use *alias* to change the qualifier to reference the `redis`packagel ike:

```go
import redisapi "mylib/redis"
redis := redisapi.NewClient()
v, err := redis.Get("foo")
```

### DON’T : Missing code documentation

Docmentation is an important aspect of coding. And in go, should follow some rules to make our code idiomatic. The convention is to add comments, starting with the name of the exported element.

#### Deprecated elements

It’s possible to deprecate an exported element using the `// Deprecated`fore:

```go
// ComputePath returns the fastest path
// Deprecated: This func use a deprecated way to compute
func ComputePath(){}
```

## `http.Handler`interface

Before go any further there is a little theory that we should cover -- it’s bit complicated -- so if find -- like:

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

Basically meanst that to be a handler an object *must* have a `ServeHTTP()`method with exact signature.

#### Handler Functions -- 

Creating an object just so we can implement a `ServeHTTP()`method on its long-winded and a bit confusing. Which is why it’s far common to write as a normal functin just like:

```go
func home(w http.ResponseWriter, *http.Request) {
    w.Write([]byte("This is my home page"))
}
```

But this is just a normal -- have a `ServeHTTP()`method -- so can *transform* it into a handler using the `http.HandlerFunc()`adapter -- like so:

```go
mux := http.NewServerMux()
mux.Handle("/", http.HandlerFunc(home))
```

For now the `http.HandlerFunc()`adapter works by automatically adding a `ServeHTTP()`method to the `home`function, when executed, this `ServeHTTP()`method then simply calls the content of the original `home`function.

Throughout using the `HandleFunc`to register with the servermux. This is just some syntactic sugar that transforms a function to a handler and registers it in one step. like:

```go
mux := http.NewServeMux()
mux.HandleFunc("/", home)
```

### Chaining Handlers

The `http.ListenAndServe()`func takes a `http.Handler`object as the second parameter like:
`func ListenAndServe(addr string, handler Handler) error`

Can do this cuz the `servemux`has has a `ServeHTTP()`method. For it simplifies things to think of the servemux is just being a *special kind of handler*, which instead of providing a response itself passes the request on to a second handler.

In fact -- what exactly is happening is -- when our server receives a new HTTP, it calls the `ServeHTTP()`-- looks up the relevant handler based on the request URL path, and it *turn calls that handler’s `ServeHTTP()`*-- can think of a Go web app as a chain of `ServeHTTP()`methods being called after another.

#### Requests Are handled Concurrently

There is one more -- all *incoming HTTP requests are served in their own goroutine* -- This means that it’s very likely that the code in or called by our handlers will be running concurrently.

### Configuration and Error Handling

For this, won’t actually add much new functionality to our app, but instead focus on making improvements that will make it easier to manage as it grows -- like:

- Set configuraiton settings for your app at runtime in an easy and idiomatic way using command-line flags
- Imporve your app log messages to include more info, and manage them differently depending on the type of log message
- make dependencies available to your handlers in a way that is extensible, type-safe, and doesn’t get in the way when it comes to writing tests.
- *Centralize error handling* don’t need to repeat yourself when writing code.

Managing configuraiton settings -- 

Hard-coded such as network address.. There is no separation between our configuration settings and code, and we can’t change the setting at runtime -- 

#### Command-line Flags

In go, a common and idiomatic way to manage configuration settings is to use command-line flags when starting an application -- like: `go run ./cmd/web -addr=:80`and the easiest way to accept and parse a command-line like:

`addr := flag.String("addr", ":4000", "HTTP network address")`

```go
// Define a new command-line flag with the name addr, a default value of :4000
// and some short help text explaining the flag controls.
addr := flag.String("addr", ":4000", "HTTP network address")

// Importantly, we use the `flag.Parse()`to parse the command-line flag
// note that it reads in the command-line flag value and assigns it to the addr 
// variable. need to call that before U use the addr variable
flag.Parse()
```

Using the `-addr`flag when you start the application. Should find that the server now listens on whatever address like:

`go run ./cmd/web -addr=":9999"`

Default Values -- Command-line flags are completely optional -- fore, if run without `-addr`, just 4000 used

#### Type conversions

In the code -- used the `flag.String()`func to define the command-line flag. This has the benefit of converting whatever value the user provides at runtime to a `string`type. If the value can’t be converted to a `string`then the app will log an error and exit

Go also has a range of other functions including `flag.Int(), flag.Bool()`and `flag.Float64()`, these work in exactly the same way as `flag.String()`.

Another great feature is that you can use the `-help`to list all the available command-line flags for an application and their accompanying help text.

#### Environment Variables

If want, can store your configuration settings in environment variables and access them directly from your application by using the `os.Getenv()`func like -- `addr := os.Getenv("SNIPPETBOX_ADDR")`

Pre-existing variables -- It’s also possible to parse command-line flag values into the memory address of pre-existing variables -- using the `flag.StringVar(), flag.IntVar(), flag.BoolVar()`and other functions. Fore:

```go
type Config struct {
    Addr string
    StaticDir string
}
//...
cfg := new(Config)
flag.StringVar(&cfg.Addr, "addr", ":4000", "HTTP network address")
```

### Leveled Logging

For now the `log.Printf()`and `log.Fatal()`functions output messages via Go’s STD logger, which - by default - prefixes messages with the local date and time and writes them to the std error stream. And, `log.Fatal()`will also call `os.Exit(1)`after writing the message, causing the app to immediately exit.

Can break apart our log messages into two distinct types or levels -- the first is info messages and the second is error messages -- like:

```go
log.Printf("Starting server on %s", *addr)
err := http.ListenAndServe(*addr, mux)
log.Fatal(err)
```

If want to improve our app by addings ome capability, 

- Will prefix info messages with `INFO`to stdout
- WIll prefix error messages with `ERROR`to stderr

For this, There are couple of different ways to do this, but a simple and clean approach is to use the `log.New()`function to create two new custom loggers like:

```go
// Create a logger for writing info messages
infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)

// Create a logger for writing error message in the same way, but use the stderr as
// destination and use the log.lshortfile flag to include the relevant file name and line
errorLog := log.New(os.Stderr, "ERROR\t",
                    log.Ldate|log.Ltime|log.Lshortfile)

//...
infoLog.Printf("Starting server on %s", *addr)
err := http.ListenAndServe(*addr, mux)
errorLog.Fatal(err)
```

#### The `http.Server`Error Log

There is one more change we need to make to our app. Fore, for consistency it’d be better to use our new `errorLog`logger instead the std logger for HTTP server. So, to make this happen, need to *initialize* a new `http.Server`struct containing the configuration settings for our server, using the `http.ListenAndServe()`.

```go
// Initialize a new http.Server struct
srv := &http.Server{
    Addr: *addr,
    ErrorLog: errorLog,
    Handler: mux,
}

infoLog.Printf("Starting server on %s", *addr)
err := srv.ListenAndServe()
```

#### Concurrent Logging 

Custom loggers created by `log.New()`are concurrency-safe -- can share a single logger and use it across multiple goroutiens and in your handlers without needing to worry about race conditions.

Log to File -- can:

```go
f, err := os.OpenFile("/temp/info.log", os.O_RDWR|os.O_CREATE, 0666)
if err != nl {
    log.Fatal(err)
}
defer f.Close()
infoLog := log.New(f, "INFO\t", log.Ldate|log.Ltime)
```

### Dependency Injection

Noticed the the `home`handler function is still writing error messages using Go’s std logger, not the `errLog`logger. Namely, *How can we make our new `errorLog`logger available to `home`from `main`*.

Most web apps will have multiple dependencies that their handlers need to access -- such as dbs connection pool, centralized error handlers, and template caches. How can we make any Deendency available to our handlers -- 

*few different ways* to do this - simplest being to just put the dependencies in global variables. Just a good practice to *inject dependencies* into your handlers. A neat way to inject dependencies is to put them into a custom `application`struct and then define your handler functions as methods against the `application`.

```go
// Define an application struct to hold the application-wide dependencies for the
// web app. just two custom loggers for now
type application struct {
	errorLog *log.Logger
	infoLog *log.Logger
}
```

Then, in the `handlers.go`file update the handler fucntions so that they become methods against the `applications`.

```go
func(app *application) home(w http.ResponseWriter, r *http.Request) {
    //...
    if err != nil {
        app.errorLog.Println(...)
    }
    //...
}
// in the main.go file
// Create a logger for writing error message in the same way, but use the stderr as
// destination and use the log.lshortfile flag to include the relevant file name and line
app := &application{
    errorLog, infoLog,
}
mux := http.NewServeMux()
mux.HandleFunc("/", app.home)
mux.HandleFunc("/snippet", app.showSnippet)
mux.HandleFunc("/snippet/create", app.createSnippet)
```

As the application grows, and our handlers start to need more dependencies.

#### Additional info -- cloures for DI -- 

The pattern that we are using to inject dependencies won’t work if your handlers are spread across multiple packages. In that case, an alternative approach is to create a `config`package exporting an `Application`struct and have your handler functions close over this to form a *closure*.

```go
func main(){
    app := &config.Application {...}
    mux.Handle("/", handlers.Home(app))
}

func home(app *config.Application) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        //... 
        return
    }
}
```

