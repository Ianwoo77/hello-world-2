# Pipelines Channels

For the `generator`function -- takes in a variadic slice of integers, constructs a buffered channel of channel of integers with a length equal to the incoming integer slice,  like:

```go
func generator(done <-chan any, integers ...int) <-chan int {
    intStream := make(chan int)
    go func() {
        defer close(intStream)
        for _, i := range integers {
            select {
            case <-done:
                return
            case intStream <-i:
            }
        }
    }()
    return inStream
}
```

Note that the send on the channel shares a `select`statement with a selection on the `done`channel. So in the nutshell, the `genertor`function converts a discrete set of values into a stream of data on a channel. It’s the same pipeline working with alone. Which briings second difference -- each stage of the pipeline is executing concurrently -- any stge only need wait for its inputs, and to be able to send its outputs.

Namely -- what would happen if we called `close()`on the `done`channel before the program was finished executing.

```go
func main() {
	done := make(chan struct{})
	defer close(done)
	intStream := generator(done, 1, 2, 3, 4, 5)
	pipeline := multiplier(done,
		add(done, multiplier(done, intStream, 2), 1), 2)
	for v := range pipeline {
		println(v)
	}
}
```

The stages are interconencted in two ways -- by the common `done`channel, and by the channels are passed into subsequent stages of the pipeline. How closing the `done`cascades through the pipeline -- made possible by two things in each stage of the pipleine -- 

- Ranging over the incoming channel -- when the incoming channel is closed, the range exit
- The send sharing a select statement with the `done`channel.

If a stage is just blocked on retrieving a value from the incoming channel, it will become unblocked when the channel is closed - know by induction that the channel will be clsoed cuz it is either a stage written, or beginning of the pipeline that we have established is preetable.

### When to wrap an error

Since 1.13, `%w`directive allows us to wrap errors conveniently -- but some may be confused about when to wrap an error or not -- Error wrapping is aobut wrapping or packing an error inside a wrapper container that also make the source error available.

Befor 1.13, to wrap an error, the only option without using an external lib was to create a custom type. Fore:

```go
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return "bar failed:" + b.Err.Error()
}
```

Then, instead of returning `err`directly, wrapped the error into a `BarError`. The benefit of this option is its flexibility, cuz `BarError`is a custom struct, can add any additional context if it needed. So add `%w`directive like:

```go
if err != nil {
    return fmt.Errorf("bar failed %w", err)
}
// using %v
if err != nil {
    return fmt.Errorf("Bar failed %v", err)
}
```

Using `%v`the info about the source of the problem remains available -- however, a caller can’t unwrap this error and check whether the source was *bar error*. But it’s also useful -- wrapping an error makes the source error available for callers, hence, it means introducing potential coupling -- fore, imagine that we use wrapping and the caller of `Foo`checks whether the source error is bar -- what if change our imp and use another function that will return another type of error -- will break the error check made by the caller.

Wrapping is about adding additioanl context to an error and /or making an error as a specific type. If need mark an error, should create a custom error type -- however, if just want to add extra context, should use `Errorf()`with the `%w`directive as it doesn’t require creating a new error type. Yet, error wrapping creates potential coupling as it makes the source error available for the caller -- prevent, shouldn’t use error wrapping but error transformation.

```go
type transienterror struct {
    err error
}
func (t transientError) Error() string {
    return fmt.Sprintf("transient error: %v", t.err)
}

func getTransactionAmoutn(transactionID string) (float32, error) {
    if len(transactionID)!=5 {
        return 0, fmt.Errorf("id is invlid: %s", transactionID)
    }
    amount, err := getTransactionAmountFromDB(transacitonID)
    if err != nil {
        return 0, transientError{err}
    }
    return amount, nil
}
```

For the `getTransactionAmount`func, returns an error using `fmt.Errorf()`return an error or an `transientError`type so:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    transactionID := r.URL.Query().Get("transaction")
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        switch err:= err.(type) {
        case transientError:
            http.Error(w, err.Error(), http.StatusServiceUnavailable)
        default:
            http.Error(w, err.Error(), http.StatusBadRequest)
        }
        return
    }
}
```

This code just valid, however, assume want to perform a small refactoring of `getTransactionAmount`, And the `transientError`will be returend by `getTransactionAmount`now wraps this error using the `%w`directive. So:

```go
func getTransactionAmount(transactionID string) (float32, error) {
    //...
    amount, err := getTransactionAmountFromDB(transactionID) 
    if err != nil {
        return 0, fmt.Errorf("failed to get transactino: %s, %w", transactionID, err)
    }
    return amount, nil
}
```

Run this, it always returns a 400 regardless of the error case, so: When returned value isn’t a `transientError`directly, it’s an error wrapping `transientError`, therefore, `case transientError`is now false. 

```go
func handler(...) {
    amount, err := getTransactionAmount(transactionID)
    if err!= nil {
        if errors.As(err, &transientError{}) {
            http.Error(w, err.Error(), http.StatusServiceUnavailable)
        }else {
            //...
        }
        return
    }
}
```

Now get rid of the `switch`case type in this new version, now just use `errors.As`. This function just requires the seccond argument to be a pointer.

### Reusing common patterns with Channels

When using message passing channels in Go, there are two main guidelines to follow -- 

- Try to *only* pass copies of data on channels. Implies that U shouldn’t pass *direct pointers* n channels in most cases, passing pointers can result in mulitple goroutines sharing memory, which can create RC.
- Try not mix message passing patterns with memory sharing.

```go
func generateUrls(quit <-chan struct{}) <-chan string {
	urls := make(chan string)
	go func() {
		defer close(urls)
		for i := 100; i <= 130; i++ {
			url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
			select {
			case urls <- url:
			case <-quit:
				return
			}
		}
	}()
	return urls
}
```

Then imp of the `downloadPage()`-- it accepts both the `quit`and urls channels and returns an output channel containing the dlowloaded pages. like:

```go
func downloadPages(quit <-chan struct{}, urls <-chan string) <-chan string {
	pages := make(chan string)
	go func() {
		defer close(pages)
		moreData, url := true, ""
		for moreData {
			select {
			case url, moreData = <-urls:
				if moreData {
					resp, _ := http.Get(url)
					if resp.StatusCode != 200 {
						panic("Server's error:" + resp.Status)
					}
					body, _ := io.ReadAll(resp.Body)
					pages <- string(body)
					resp.Body.Close()
				}
			case <-quit:
				return
			}
		}
	}()
	return pages
}
```

Warning - we are just passing a copy of the web document on the channel -- we can do this since the web pages are only a few KB in size. Note that if for video, this might have a detrimenal effecto on the performance.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	results := downloadPages(quit, generateUrls(quit))
	for result := range results {
		fmt.Println(result)
	}
}
```

Just continue reading from the input channel until we get a close on the input or on the `quit`channel, do this by using the `select`statement and reading the `moreData`flag on the input channel like:

```go
func extractWords(quit <-chan struct{}, pages <-chan string) <-chan string {
	words := make(chan string)
	go func() {
		defer close(words)
		wordRegex := regexp.MustCompile(`[a-zA-Z]+`)
		moreData, pg := true, ""
		for moreData {
			select {
			case pg, moreData = <-pages:
				if moreData {
					for _, word := range wordRegex.FindAllString(pg, -1) {
						words <- strings.ToLower(word)
					}
				}
			case <-quit:
				return
			}
		}
	}()
	return words
}
```

#### Fanning in and out

In the example, want to just speed things up, can perform the downloads concurrenty by load-balancing the URLs. Can create a fixed number of goroutines, each reading from the same URL input channel. DEF -- in Go, a *fan-out* concurrency pattern is when multiple goroutines read from the same channel, in this way, can distribute the work among a set of goroutines -- 

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, 20)
	for i := 0; i < 20; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	//...
}
```

The Fan-out pattern in this hs created a problem - the outputs of our download goroutines are in separate channels, can can connect them to the signal input channel of our next -- To keep to this pattern, need a mechanism that *merges* the output messags from teh different channels into a single output channel. In Go, a fan-in concurrency pattern occurs when we mrege the content from mutliple channels into one.

Since lightweight, can implent this fan-in as a single unit by creating a set of goroutines, one per output channel -- and having each goroutine feed a common channel. For this, have a many-to-one fan-in scenario, make a decision about when to close the common channel -- The soluition is only close the common channel when *all* the goroutines have noticed that the channels from which they are consuming have been closed.

```go
func FanIn[K any](quit <-chan struct{}, allChannels ...<-chan K) chan K {
	wg := sync.WaitGroup{}
	wg.Add(len(allChannels))
	output := make(chan K)
	for _, c := range allChannels {
		go func(channel <-chan K) {
			// once the goroutine terminates, mask the wg done
			defer wg.Done()
			for i := range channel {
				select {
				case output <- i:
				case <-quit:
					return
				}
			}
		}(c)
	}
	go func() { // truly fan-in here
		wg.Wait()
		close(output)
	}()
	return output
}
```

Can now connect our fan-in pattern to our app and include it in the pipeline -- 

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, 20)
	for i := 0; i < 20; i++ {
		pages[i] = downloadPages(quit, urls)
	}

	results := extractWords(quit, FanIn(quit, pages...))
	for result := range results {
		fmt.Println(result)
	}
}
```

When run this, runs a lot faster cuz the main time-consumer job are being performed concurrently.

## Introduction

In this -- going to wrok through the start-to-finish build of an application called `Greenlight`-- A JSON API for retrieving and managing info about movies. like:

- `GET /v1/healthcheck`-- show app helth and version info
- `GET /v1/movies`-- show the deails of all movies
- `POST /v1/movies`-- create a new movie
- `GET /v1/movies/:id`-- show the details of a specific movie

Get started -- In this going to set up a project directory and lay the groundwork for building our API will -- 

- Create a skeleton directory structure for the project and explain a high-level how your code and other assets will be organzied
- Establish a HTTP server to listen for incoming HTTP requests
- A sensible pattern for managing configuration settings, via command-line, and using DI to make dependencies avaiable to our handlers
- Use the `httprouter`package to help implement a standard RESTful structure.

### Project setup and Sekleton Structure

- When ther is a valid `go.mod`file in the root of your project directory, your project is a *module*.
- When you are working insde your project and download dependncy with `go get`-- then the exact version of the dependency will be recored in the `go.mod`file.
- When run or build the code in proj, Go will use the exact dependencies listed in the `go.mod`.
- The `go.mod`define *module path* -- this is essentially the identifier that will be used to as *root import path* for the package in your project.

#### Generating the skeleton -- 

```sh
mkdir -p bin cmd/api internal migrations remote
touch Makefile
touch cmd/api/main.go
```

- `bin`for deployment to a production server
- `cmd/api`contain the app-specific code for apps.
- `internal`-- contain various ancillary package used by our PAI. Will contain the code for interacting our dbs, doing data vlidation, send emails... -- any code **is not application-speicifc** and can potentially be reused will live in here. Our Go code under `cmd/api`will *import* packages in the `internal`directory.
- The `migrations`will contain the SQL migration files for our dbs.
- The `remote`will contain the configuration files and setup scriptis for our production server
- The `Makefile`will contain `recipes`for automating common administrative tasks -- like auditing our Go code, building binaries, and executeing dbs migrations.

It’s important to point out that the directory name `internal`carries a *special meaning* and behavior in Go-- any packages which live under this directory can only be imported by code insid the parent of the `internal`directory, this mans that any packages which live in `internal`can only be imported by code inside our `greenlight`proj directory.

### A basic HTTP server

Now that the skeleton structure for our proj is in place, just focus our attention on getting an HTTP server up and running. To start wtih, configure our server to have just one endpoint -- `v1/healthcheck`. This endpoint will return some basic info about the API, including its current version number and operting environment fore `development...`

```go
// Later will generate this automatically at build time
const version = "1.0.0"

// Define a config struct to hold all the configuration settings for app
type config struct {
	port int
	env  string
}

// Define an app structure to hold the dependencies for HTTP handlers
// helpers, and middleware. At the moment this only contains a copy of the config
// and a logger
type application struct {
	config config
	logger *log.Logger
}

func main() {
	// Declare an instance of the config struct
	var cfg config

	flag.IntVar(&cfg.port, "port", 4000, "API server port")
	// default to development
	flag.StringVar(&cfg.env, "env", "development",
		"Environment (development|staging|production)")
	flag.Parse()

	// Initialize a new logger which writes message to the standard out stream
	logger := log.New(os.Stdout, "", log.Ldate|log.Ltime)

	// Declare an instance of the app struct, containing the config and logger
	app := &application{
		config: cfg,
		logger: logger,
	}

	// Declare a new servemux and add /v1/healthcheck route which dispatches requests
	// to the method
	mux := http.NewServeMux()
	mux.HandleFunc("/v1/healthcheck", app.healthcheckHandler)

	// Declare an HTTP server with same sensible timout settings
	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.port),
		Handler:      mux,
		IdleTimeout:  time.Minute,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 30 * time.Second,
	}
	
	// start the http server
	logger.Printf("Starting %s server on %s", cfg.env, srv.Addr)
	err := srv.ListenAndServe()
	logger.Fatal(err)
}
```

#### Creating the `healthcheck`handler -- 

The next thing we need to do is create the `healthcheckHandler`method for responding to HTTP requests -- for now, keep the logic in this handler realy simple and have it return a plain-text response containing just `env`...

```go
// healthcheckHandler write a plain-text response
func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "status available")
	fmt.Fprintf(w, "environment: %s\n", app.config.env)
	fmt.Fprintf(w, "version: %s\n", version)
}
```

#### API version

API which support real-world business and users often need to change their functionality and endpoints over time -- in backwards-incompatible way -- to avoid problems and confusion for clients. it’s a good idea to always implement som form of API versioning -- like:

there are two common approaches to doing this -- 

- By prefixing all URLs with your API version like `/v1/healthcheck`
- By using custom `Accept`and `Content-Type`on requests and responses to convey the API version like: `Accept : application/vnd.greenlight-v1`

### API endpoints and Restful Routing

Over the next few -- going granually build the API -- The first thing is that requests with the same URL pattern will be routed to different handlers based on the HTTP request method -- 

- PUT -- Use fo *idemotent* actions that modify the state of a resource at a specific URL.
- PATCH -- Use for actions that partially update a resource at a specific URL. It’s ok for the action to be eigher idmpotent or non-idempotent.

#### choosing a router

When are guilding an API with endpoints like this in Go, one of the first hurdles will meet is the fact that `http.ServeMux`-- the router in the Go STDLIB -- limited in terms of its functionality. In particular it doesn’t allow U to route requests to different handlers based on the request method (GET POST) -- For this, going to integrater poular `httprouter`package with our app -- `httprouter`is stable, *well-tested* and provides the functionality we ned -- also extememly fast. Use of `radix`tree for URL matching.

```sh
go get github.com/julienschmidt/httprouter@v1
```

To demonstrate, start by adding the two endpoints for creating a new movie and showing the details of specific movie to our code base. Add:

- `POST /v1/movies`, create a new movie
- `GET /v1/movies/:id`, `showMovieHandler`-- show the details of a specific movie

#### Encapsulating the API routes -- 

To prevent our `main`from being cluttered as the API grows, encapsulate all the routing rules in a new `cmd/api/routes.go`file -- 

```go
func (app *application) routes() *httprouter.Router {
	// Initialize a new httproute rounter instance
	router := httprouter.New()

	// Register the relevant methods and URL patterns with the router
	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)
	router.HandlerFunc(http.MethodPost, "/v1/movies", app.createMovieHandler)
	router.HandlerFunc(http.MethodGet, "/v1/movies/:id", app.showMovieHandler)

	// return the httprouter instance
	return router
}
```

There are couple of benefits to encapsulating our routing rules in this way -- the first benefit is that it keeps our `main`clean and ensure all our routes are defined in one single place. Now easiy access the router in any test code by initializing an `application`instance and alling the `routes()`method on it.

```go
srv := &http.Server{
    Addr:         fmt.Sprintf(":%d", cfg.port),
    Handler:      app.routes(),
    //...
}
```

#### Adding the new handler functions

Now that the routing rules are set up, need to make the `createMovieHandler`and `showMoveHandler`methods for the new endpoints -- the `showMovieHandler`is particularly interesting -- like;

```go
func (app *application) CreateMovieHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "create a new movie")
}

// ShowMovieHandler Add a showMovieHandler for the `GET /v1/movies/:id` endpoint like
func (app *application) ShowMovieHandler(w http.ResponseWriter, r *http.Request) {
	// When httprouter is parsing a request, any URL parameters will be stored
	// in the request context, canuse the `ParamsFromContext()` function to
	// retrieve a slice containing these parameter names and values.
	params := httprouter.ParamsFromContext(r.Context())

	// Can use the `ByName()` go get the teh value of the `id` from the slice
	// ByName() is always a string so:
	id, err := strconv.ParseInt(params.ByName("id"), 10, 64)
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	// otherwise, interpolation the movie ID in a placeholder response
	fmt.Fprintf(w, "Show the details of movie %d\n", id)
}
```

Likewise, can make an `OPTIONs`request to a specific URL and `httprouter`will sand back a response with an `ALLOW`header supported by HTTP methods.

