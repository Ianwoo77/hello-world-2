# Don’t use a filename as function Input

When creating a new function that needs to read a file, passing a filename isn’t considered a best practice and can have negative effects -- such as making unit tests harder to write -- Suppose want to implement a function to count the number of empty lines in a file. One way to implement this function would to be accept a file and use `bio.NewScanner`to scan and check every line. 

```go
func countEmptyLinesInFile(filename string) (int, error) {
    file, err := os.Open(filename)
    if err != nil {
        return 0, err
    }
    scanner := buiio.NewScanner(file)
    for scanner.Scan() {
        //...
    }
}
```

For this, open a file from the filename, then use the `bufio.Newscanner`to scan every line -- this function will do what expect it to do -- Want to just implement unit tests to cover the following cases -- 

- A nominal case
- An empty file
- A file contianing only empty lines

Each unit test will require creating a file in Go project - -The more complex the function is -- the more cases we way wna to add -- and the more files we will create. Furthermore -- this function is just not reusable. Fore, if had to implement the same logic but count the number of empty lines with an HTTP requst -- would have to duplicate the man logic like -- 

```go
func countEmptyLinesInHTTPRequest(request http.Request) (int, error) {
    scanner := bufio.NewScanner(request.Body)
}
```

One way to overcome these limiations might be to the func accpet a `*bufio.Scanner`-- But in Go -- the idiomatic way is to start from the reader’s abstraction. like:

```go
func countEmptyLines(reader io.Reader) (int, error) {
    scanner := bufio.NewScanner(reader)
    for scanner.Scan() {
        line := scanner.Text()
        if line="" {
            //...
        }
    }
}
```

1. This function abstracts the data source 

2. For testing - 

   ```go
   func TestCountEmptyLines(t *testing.T) {
       emptyLines, err := countEmptyLines(strings.NewReader(
       	`foo bar
           
       	baz`
       ))
   }
   ```

   In this test, create an `io.Reader`using `strings.NewReader`from a string literal directly.

### Ignoring how `defer`argumnets and receivers are evaluated -- 

A common mistake made by GO developers is not understanding how arguments are evaluated -- 

#### Arg evaluation

Work on a concrete exmaple -- A function that needs to call two functions -- Fore, to notify another goroutine and to increment counters -- to avoid repeating these calls before every `return`statement, will use `defer`like:

```go
const (
	StatusSuccess = "success"
    StatusErrFoo = "..."
    StatusErrBar = "..."
)
func f() error {
    var status string
    defer notify(status)
    defer incrementCounter(status)
    if err := foo(); err!= nil {
        status = statusErrFoo
        return err
    }
    //...
    status = StatusSuccess
    return nil
}
```

However, if give this a try -- see that regardless of the execution path, `notify`and `incrementCounter`using `defer`-- throughout this func -- and depending on the execution path -- update `status`accordingly --  Can see regardless of the execution path -- `nofiy`and `incrementCounter`are always called with the same status -- emtpy string. Sth crucial about argument evaluation in a `defer`func -- the arguments are evaluated *rgith away*, not once the surrounding function returns -- for this, just called `notify(status)`and `incrementCounter(status)`as `defer`, therefore, Go just will delay these calls to be executed once `f`returns with the current value of `status`at the stage we used `defer`-- hence passing an empty string -- 

```go
// the first solution is just to pass a string pointer to the `defer`
func f() error {
    var status string
    defer notify(&status)
    defer incrementCounter(&status)
    // ...
}
```

For this using `defer`just evaluates the arguments right away -- the address of `status`- itself is modified throughout the function -- but the address remains constant.

There is another solution -- Just calling a closure as a `defer`statement -- as a remainder, a closure is an anonymous function value that references varaibles from outside its body -- the arguments passed to a `defer`are evaluated right away -- must know that the variables referenced by a `defer`are evaluated *during* the closure execution. 

For a closure -- referens two like:

```go
func() {
    i, j := 0, 0
    defer func(i, int) {
        fmt.Println(i, j) // 0 1
    }(i)
    i++; j++
}
```

`i`is just passed as a function argumnet -- so it’s *evaluated immediately* -- conversely, `j`references a variable outside of the closure body -- so it’s evaluated when the closure is executed. So

```go
func f() error {
    var status string
    defer func() {
        notify(status)
        incrementCounter(status)
    }()
}
```

Wrap the calls both `notify`and `incrementCounter`within a closure.

#### Pointer and value receivers

The same logic for <u>Not knowing which type of receiver to use</u>-- The same logic related to argument evaluateion applies when use `defer`on a method.

```go
func main(){
    s := Struct {id: "foo"}
    defer s.print()
    s.id= "bar"
}

type Struct struct {id string}

func (s Sturct) point() {
    fmt.Println(id)
}
```

Defer the call to the `print`as with arguments, calling `defer`makes the receiver be evaluated immediately. Hence, `defer`delays the method’s execution with a struct at conains an `id`field equal to `foo`. 

Note that, Conversely-- if a pointer is a receiver, the potential changes to the receiver after the call to `defer`are visible -- like:

```go
func main(){
    s := &Struct {id: "foo"}
    defer s.print()
    s.id="bar"
}
//...
func (s *Struct) print() {...}
```

For this, the `s`receiver is evaluated immediately. The example prints `bar`for now.

### What about configuration -- 

said that pratical programs often need some kind of configuration in order to be flexible. A useful pattern in Go is to have some kind of object -- fore, `struct`. How will would it scale if there were lots of things to configure -- it might be annoying to have to write separate assignment statements, one for every struct field want to set.

#### Config structs don’t solve the problem -- 

A common -- not good pattern -- create some *config struct* type and pass that to the constructor instead like:

```go
type Config struct {
    Input io.Reader
    Output io.Writer
}
func Make(config Config) *conter {
    c := NewCounter()
    c.Input = config.Input
    //...
    return c
}
```

For this, pointless -- *have* already a struct that contains the config information -- the `counter`struct itself. 

#### An elegant option API -- 

```go
c := count.NewCounter(
    count.WithInput(os.Stdin),
    count.WithOUtput(os.Stdout),
    // ... maybe more options here
)
```

So, simply wave a wand and imagine -- that there is a type `option`that will take care of these for us -- like:

```go
func NewCounter(opts ...options) *counter {
    c := &counter {
        input: os.Stdin,
        output: os.Stdout
    }
}
```

For this, can receive any number of such options, so a `range`loop seems appropraite -- for each option, then, we would call it as a function -- passing it the counter. After like:

```go
for _, opt := range opts {
    opt(c)
}
```

#### Options are **functions** 

At the end of our `range`loop, then, we will have applied all the options we received, and the full-configured `counter`will be already to return -- like:

```go
func NewCounter(opts ...option) *counter {
    c := &counter{
        Input: os.Stdin,
        Output: os.Stdout,
    }
    for _, opt := range otps {
        opt(c)
    }
    return c
}
```

The only thing the use is actually *supplying* here are `inputBuf`and `outputBuf`-- the rest is biolperlate -- so:

```go
func WithInput(input io.Reader) option {
    return func(c *counter) {
        c.Input = input
    }
}
c := count.NewCounter(count.WithInput(inputBuf))
```

#### Always “valid” fields

A nice conseuqence of this approach is that -- since users don’t ever need to set the struct fields directly, can make them *unexoported*. Fore, might wane to ensure that the input and output are never `nil` -- which could cause a panic if the program tried to use them. The *Go-like* thing to so -- return an `error`like:

```go
func WithInput(input io.Reader) option {
    return func(c *counter) error {
        if input == nil {
            return errors.New("nil input reader")
        }
        c.input = input
        return nil
    }
}
```

Since the only way uses can set this field is by calling our validating `WithInput`function, can now be sure that the value of `c.Input`is always valid. That is much better than having to check it every time we use it. namely:

`type option func(*counter) error:`since our `option`function now returns `error`-- need to receive and check that error in the apply-optoins loop in `NewCounter`. In turn, means that `NewCounter`also needs to return `error`and that makes sense -- if U supply options that happen to be invlid for some reason, then `NewCounter`should tell it.

```go
func NewCounter(opts ...option) (*counter, error) {
    c := &counter {
        input: os.Stdin,
        output: os.Stdout,
    }
    for _, opt := range opts {
        err := opt(c)
        if err != nil {
            return nil, err
        }
    }
    return c, nil
}

func (c *counter) Lines() int {
	lines := 0
	input := bufio.NewScanner(c.input)
	for input.Scan() {
		lines++
	}
	return lines
}

func Main() {
	c, _ := NewCounter()
	fmt.Println(c.Lines())
}
```

## creating Dbs, user, and extensions

While are connected as superuser -- create a neww dbs for our project called `greenlight`-- 

```sql
create database greenlight;
```

Create a new `greenlight`user, without superuser permissions -- which we can use to execute SQL migrations and connect ot the dbs from our Go application. Want to set up this new user to use *password-based* authentication, instead of peer authentication.

PostgreSQL also has the concept of *extensions* -- which add additional features on top of the std functionality -- a list of extensions that shp PostgreSQL can be found -- there are also some others -- `citext`for - adds a case-insensitive character string type to PSQL -- which will use later -- so.

```sql
create role greenlight with login password 'pa$$word';
create extension if not exists citext;
```

### Connecting to PSQL

```sh
go get github.com/lib/@pq@v1
```

#### Establishing a connection pool

The code we will use for connecting to the greenlight dbs from our Go application is almost exactly the same as is the first book -- won’t dwell on the details -- and hopefully this will a feel very familar --  At a high-lvel -- 

- Want the DSN to be configurable at runtime -- will pass it to the application using a command-line flag rather than hard-coding it -- For simplicity during development, use the DSN above the default value for the flag
- In the `main.go`, will create a new opneDB() helper function. In this helper use the `sql.Open()`to establish a new `sql.DB`connection pool -- then cuz connections to the dbs established lazily as and when needed for the first time -- also need to use the `db.PingContext()`method to *actually* carete a conenction and verify that everything is set up correctly.

```go
type config struct {
	port int
	env  string
	db struct {
		dsn string
	}
}
```

```go
func main() {
	// Declare an instance of the config struct
	var cfg config

	flag.IntVar(&cfg.port, "port", 4000, "API server port")
	// default to development
	flag.StringVar(&cfg.env, "env", "development",
		"Environment (development|staging|production)")

	// read the DSN value from the db-dsn command-line flag into the config struct.
	flag.StringVar(&cfg.db.dsn, "db-dsn",
		"postgres://postgres:south@localhost/greenlight", "PostgresSQL DSN")
	flag.Parse()

	// Initialize a new logger which writes message to the standard out stream
	logger := log.New(os.Stdout, "", log.Ldate|log.Ltime)

	// call the openDB() helper function to create the connection pool
	db, err := openDB(cfg)
	if err != nil {
		logger.Fatal(err)
	}
	
	// defer a call to db.Close() so that the connection pool is closed before 
	// main() function exits
	defer db.Close()

	// Declare an instance of the app struct, containing the config and logger
	app := &application{
		config: cfg,
		logger: logger,
	}

	// Declare an HTTP server with same sensible timout settings
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.port),
		Handler:      app.routes(),
		IdleTimeout:  time.Minute,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}

	// start the http server
	logger.Printf("Starting %s server on %s", cfg.env, srv.Addr)
	err = srv.ListenAndServe()
	logger.Fatal(err)
}

// The openDB() function returns a sql.DB connection pool
func openDB(cfg config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.db.dsn)
	if err != nil {
		return nil, err
	}

	// create a context with a 5-second timeout
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Use the PingContext() to establish a new connection to the dbs, passing in the
	// context we created above as a parameter, if the connection couldn't be
	// established successfully within 5s deadline -- return an error
	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}
	return db, nil
}
```

Talking about using `context`to manage timeouts properly later in the books -- don’t worry about this too much at the moment -- for now, it’s sufficient to know what if the `PingContext()`call could not complete successfully in 5 seconds-- then it will return an error.

