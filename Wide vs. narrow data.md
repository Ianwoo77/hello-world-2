# Wide vs. narrow data

A narrow data set grows veritcally -- a narrow format makes it easier to manipulate existing data and to add new records -- each variable is isolated to a single column -- A *pivot table* aggregates a column’s value and groups the results by using other column’s values. The word *aggregate* describes a summary compuation that involves multiple values -- 

1. Select the column(s) whose values we want to aggregate
2. Choose the aggregation operation to apply to the column(s)
3. select the column(s) will will group the aggregated data into categories.
4. Determine whether to place the groups on the row axis.

```python
sales.pivot_table(index="Date", values=['Expenses', 'Revenue'])
sales.pivot_table(index="Date", values=['Expenses', 'Revenue'], aggfunc=np.sum)
sales.pivot_table(
    index="Date",
    values=["Expenses", "Revenue"],
    aggfunc=np.sum,
    columns='Name'
)
```

For this, like to use the `Name`column’s unique values as the column headers in the pivot table. Also notice the precense of `NaNs`in the data set. Can use the `fill_value`parameter to replace all pivot table NaNs with a fixed value like:

```python
sales.pivot_table(
    index="Date",
    values=["Expenses", "Revenue"],
    aggfunc=np.sum,
    columns='Name',
    fill_value=0 # fill the NaNs with 0
)
```

may also want to see the revenue subtotals for each combination of date and salesman, can just like:

```python
sales.pivot_table(index='Date',
                  columns='Name',
                  values='Revenue',
                  aggfunc=np.sum,
                  fill_value=0,
                  margins=True,
                  margins_name="Total")
```

Additional options for pivot tables -- supports a variety of aggregation operations.

### Olympic pivots

In this, examine the Plympic data one more time -- but using pivot tables, so can examine and compare more info at a time than we could before -- Pivot tbles are a popular way to summarize info in a large, more complex table.

```python
df = pd.read_csv(
    "olympic_athlete_events.csv",
    usecols=["Age", "Height", "Team", "Year", "Season", "Sport", "Medal"],
)
```

Notice that don’t set the index -- that cuz we ignore the index in this exercise -- focusing instead on pivot tables, cuze the pivot tables are constructed based on actual columns and not the index.

Now want to remove all the rows that aren’t from the countries we’ve named -- Often keep rows with a particular value, use the `isin`method, which allows us to pass a list  of possibilities and get a `True`whenever the `Team`equals one of those possible strings. like:

```python
df = df.loc[
    df["Team"].isin(
        ["Great Britain", "France", "United States", "Switzerland", "China", "India"]
    )
]
df = df.loc[df['Year']>=1980]
```

with in place, can create pivot tables to examine our data from a new perspective.

```python
df.pivot_table(index='Year', columns='Team', values='Age')
```

These numbers are across all sports, and not every country has entrants in every sport, but if take the numbers at face value, .. Next, want to find the tallest players in each sport from each year -- 

```python
df.pivot_table(index='Sport', columns='Year', values='Height', aggfunc=np.max)
```

Finally, ask to determine how many medals each country received at each game -- 

```python
pd.pivot_table(df.dropna(subset='Medal'),
               index='Year',
               columns='Team',
               values='Medal',
               aggfunc=np.size)
pd.pivot_table(df.dropna(subset='Medal'), 
               index=['Year', 'Season'], 
               columns='Team', 
               values='Medal', 
               aggfunc='size')
```

```python
pd.pivot_table(df, 
               index='Year', 
               columns='Team', 
               values=['Age', 'Height'], 
               aggfunc='max')
```

## When to wrap an error

Since the `%w`directive allows to wrap errors conventiently -- but some developers may be just confused about when to wrap an error or not -- Errors wrapping is about wrapping or packing an error inside a wrapper container that also makes the source error available. In general, the two main use cases for error wrapping are the following -- 

- Adding additional context to an error
- Making an error as a specific error

Fore, regarding adding context, -- receive a request rom a specific user to access a dbs source, but get a `permission denied`error during the query. for debugging purposes, if the error is eventually logged, want to add extra context, in this case, can wrap the error to indicate who the user is and what resouce is being accessed.

And, say insteading adding context, want to mark the error -- want to implement an HTTP handler that checks whether all the errors received while calling functions are of `Forbidden`so can returns a 403.

In both, the source error remains availble -- a caller can also handle an error by unwrapping it and checking the source error -- also note that sometimes we want to combine both approaches -- adding context and marking an error.

See different ways in Go to return an error we receive -- will consider the following like:

```go
func Foo() error {
    err := bar()
    if err != nil {
        //? what to do?
    }
}
```

The first is to return this error directly -- 

```go
if err != nil{
    return err
}

// And, before Go 1.13, to wrap just using external library was to create a custom error type
type BarError struct {
    Err error
}
func (b BarError) Error() string{
    return "bar failed:"+ b.Err.Error()
}
// in the main, instead of returning directly, wrapped into `BarError` like:
if err != nil {
    return BarError{Err: err}
}
```

The benefit of this is its flexibility-- cuz `BarError`is a custom struct, can add any additional context if needed -- however, being obliged to create a specific error type can quickly just cumbersome -- to overcome, After 1.13:

```go
if err != nil {
    return fmt.Errorf("bar failed: %w", err)
}
```

This code wraps the source error and add additional context without having to create another error type. Cuz for this, the source error r*emains available*, a clicent can unwrap the parent error and then check whether the source error was of a specific type or value -- like.

The last option discuss is to use the `%v`directive -- like:

```go
if err != nil {
    return fmt.Errorf("bar failed: %v", err)
}
```

The difference is that the error itself isn’t wrapped -- transform it into just another error to add context, and the source error is no longer available.

Only the information about the source of the problem remains availabe -- however, a caller can’t unwrap this error and check whether the source was `bar error`.

Wrapping an error makes source error -- it means introducing *potential coupling* -- fore, imagine that use wrapping and the caller of `Foo`checks whether the source error is `bar`. What if change our IMP and use another func that will return another type of error?

To make sure our clients don’t rely on sth that we consider imp details, the error returned should be transformed, not wrapped.

To summarize -- when handling an error, can decide to wrap it -- If need to mark an error, should create a custom `error`type-- if just want to add some extra context, using the `fmt.Errorf`with the `%w`directive -- error wrapping creates potential coupling as it makes the source error available for the caller. Yet -- note that -- wrapping creates potential coupling -- as it markes the source error available for the caller. If want to prevent it, shouldn’t use error wrapping transformation, fore, using `fmt.Errorf()`with `%v`just.

### Checking an error type

However, when use the approach `%w`directive -- it is also eseential to change our way of checking for a specific error type, may handle errors inaccurately -- fore -- imp can fail in two cases -- 

- If the ID is invalid
- If query the DB fails

ID problem -- return 400, latter returns 503, for this, will create a `transientError`type to mark that an `error`is temporary, the parent handler will check the error type -- if `error`is a `transientError`, return 503, otherwise 400.

```go
type transientError struct {
	err error
}

func (t transientError) Error() string {
	// creates a custom transient
	return fmt.Sprintf("transient error: %v", t.err)
}

func getTransactionAmount(transactionID string) (float32, error) {
	if len(transactionID)!=5 {
		return 0, fmt.Errorf("id is invalid: %s",transactionID)
	}
	
	amount, err := getTransactionAmountFromDB(transactionID)
	if err != nil {
		// if fail to query the DB
		return 0, transientError{err: err}
	}
	return amount, nil
}
//...
func handler(w http.ResponseWriter, r *http.Request) {
	transactionID := r.URL.Query().Get("transaction")
	amount, err := getTransactionAmount(transactionID)
	if err != nil {
		switch err := err.(type){ // checks for the error type
		case transientError:
			http.Error(w, err.Error(), http.StatusServiceUnavailable)
		default:
			http.Error(w, err.Error(), http.StatusBadRequest)
		}
		return
	}
	// write response
}
```

For this, using `switch`on the error type, we return the appropraite HTTP status 400 in the case of a bad request or 503 for case of a transient error. The code is just valid -- assume that we want to perform a small refactoring of `GetTransactionAmount`-- The `transientError`will be returned by `getTransactionAmountFromDB`instead of `getTransactionAmount`-- for now, using `%w`directive like:

```go
if err != nil {
    // if fail to query the DB
    return 0, fmt.Errorf("falied to get transaction: %s:%w",
                         transactionID, err)
}
return amount, nil

// .. use this:
if err != nil {
    return 0, transientError{err:err}
}
```

If run this, it will always returns a `400`regardless of the error case, so the `case`will never be hit. `transientError`was returned by `getTransactionAmount`-- after refactoring, the `transientError`is now returned by the `getTransactionAmountFromDB` -- It’s an error wrapping `transientError`now, -- therefore, `case transientError`is now false.

For that exact purpose, Go 1.13 came with a directive to wrap an error and a way to check whether the *wrapped error is of certain type* with `errors.As()`. Fore:

```go
if err != nil {
    if errors.As(err, &transientError{}) {
        http.Error(w, err.Error(),
                   http.StatusServiceUnavailable)
    }else{
        http.Error(w, err.Error(), http.StatusBadRequest)
    }
    return
}
```

For this, got rid of the `switch`case type in this new , now use `errors.As`-- this function requires the second argument to be a pointer -- otherwise the func will compile but panic at runtime. Regardless of whether the runtime error is directly a `transientError`type or an error wrapping `transientError`-- As returns `true`.

If rely on error wrapping, must use `errors.As()`to check whether an error is a specific type -- this way, regardloess of whether the error is returned drecly by the function or wrapped in an error, `errors.As()`will be able to *recursively* unwrap our main error and see if one of the errors is a speciifc type.

## Panic Recovery

In a simple Go app, when your code panics it will result in the application being terminated straight away -- but our web app is a bit more sophisticated, go’s http server asumes that the effect of any panic is isolated to the goroutine werving the active http request - specifially, following a panic our server will log a stack trace to the server error log, unwind the stack for the affected goroutine, and close the underlying HTTP connection.  But it won’t terminate the application -- any panic in your handler won’t bring down your server.

`panic("oops, sth went wrong!")`

Will get is an empty resonse due to Go just closing the underlying HTTP connection following the panic. This isn’t a great experience for the user, it would be more appropriate and meaningful to send them a proper HTTP response with a *500 internal server error* status instead.

And a neat way of doing this is to create some middleware which just *recovers* the panic and calls our `app.ServeError()`helper method -- to do so, can leverage the fact that deferred functions are always called when the stck is being unwound following a panic.

```go
func(app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Create a deferred func
		defer func() {
			// use the builtin recover func to check if there has been a 
			// panic or not
			if err := recover() ; err != nil {
				// just set a `Connection: close` header on the response
				w.Header().Set("Connection", "close")
				// also, call the app.serverError helper to return a 500
				app.serverError(w, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

There two details -- 

- Setting the `Connection: Close`header on the response acts as a trigger to make Go’s HTTP server automatically close the current connection after a response has been sent. It also informs the user that the connection after a response has been sent. Also informs the user that the connection *will be closed*.
- The value retruend by the builtin `recover()`has the type `interface{}`-- and its underlying type could be `string, error`or sth else. In the code above -- normalize this into an `error`by using the `fmt.Errorf()`func to create a new `error`object containing the default of the `interface{}`.

`return app.recoverPanic(app.logRequest(securityHeaders(mux)))`

#### Panic receovery in other background goroutines -- 

It’s important to realise that our middleware will only receover panics that happen in the some goroutine that executed the `recoverPanic()`. Fore, have a handler which spins up another goroutine -- then any panics that happens in the second goroutine will not be receovered -- So, if are spinning up additional goroutines from within your web apps and there is any chance of a panic, must make sure that your recover any panic from within those too.

So, if you are spinning up additional goroutiens from witin your web app and there is any chance of a panic, must make sure that your recover any panics from within those like:

```go
func myHandler(w http.ResponseWriter, r *http.Request) {
    // spin up a new goroutine to do some background processing
    go func(){
        defer func() {
            if err := receover(); err != nil {
                ...
            }
        }()
        dosthBackgroundProcessing()
    }
    w.Write([]byte("OK"))
}
```

### Composable Middleware Chains

for the `justinas/alice`packge to help us manage our middleware/handler chains -- don’t need -- cuz it makes it easy to crete composable, reusable, middleware chains -- and that can be a real help as your app grows and your routes become more complex. The package itself also small and lightweight. Instead of:

```go
return alice.New(myMid1, myMid2...).Then(myHandler)
```

And the real power lies in the fact that you can use it to create middleware chains that can be assigned to variables, appended to, and reused -- fore:

```go
myChain := alice.New(myMid1, myMid2)
myOtherChain := myChain.Append(myMid3)
return myOtherChain.Then(myHandler)
```

```go
func (app *application) routes() http.Handler {
	standardMiddleware := alice.New(app.recoverPanic, app.logRequest, securityHeaders)
	mux := http.NewServeMux()
	//...

	return standardMiddleware.Then(mux)
}
```

### Restful Routing

going to add a HTML form to our web application so that users can create new snippets -- to make this work smoothly, going to update our application routes so that requests to `/sippet/create`are handled differently based on the request method -- speciafically -- 

- For `GET /snippet/create`requests to show the user the HTML form for adding a new
- For `POST /snippet/create`want to process this form data and then insert a new `snippet`into dbs.

Making these changes would give us an app routing structure that follows the fundamental principles of REST and which should feel familar and logical to anyone who works on apps.

### Installing a Router

`Pat`and `Gorilla Mux`-- 

- pat is more focused and lightwieight, provides just method-based routing and support for semanitc URLs, and not much else.
- `gorilla/mux`is more full-featured. In addition to method-based routing and support for semantic URLs -- can use it to route based on schema -- host and headers. Regular expression patterns in URLs are also supported. The downaside of the pakage is that it’s comparatively slow and memory hungry.

#### Alternative routers

suggested the two routes -- but if want to expore some more alternatives -- all of which are good -- fore//

### Implementing RESTful routes

The basic syntax for creating a router and registering a route with `pat`package like:

```go
mux := pat.New()
mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))
```

- For this, the `/snippet/:id`pattern includes a named capture `:id`-- the named capture acts like a wildcard, whereas the rest of the pattern matches literally. Pat will add the contents of the named capture to the URL query string at runtime behind the scenes.
- `mux.Get()`is used to register a URL pattern and handler which will be called *only* if the request has a GET mtehod. Also, corresponding `Post(), Put(), Delete()`and other methods
- Pat doesn’t allow us to register handler functions directly, so need to conver them using the `http.HandlerFunc()`adpater.

```go
func (app *application) routes() http.Handler {
	standardMiddleware := alice.New(app.recoverPanic, app.logRequest, securityHeaders)

	mux := pat.New()
	mux.Get("/", http.HandlerFunc(app.home))
	mux.Get("/snippet/create", http.HandlerFunc(app.createSnippetForm))
	mux.Post("/snippet/create", http.HandlerFunc(app.createSnippet))
	mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))
	
	fileServer := http.FileServer(http.Dir("./ui/static/"))
	mux.Get("/static/", http.StripPrefix("/static", fileServer))
	
	return standardMiddleware.Then(mux)
}
```

Note that the URL patterns which end in a trailing slash like `/static/`work in the same way as with Go’s inbuilt servemux.

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	// Pat doesn't strip the colon from the named capture key, so needs to 
	// get the value of the :id from the query instead of id
	id, err := strconv.Atoi(r.URL.Query().Get(":id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}
    //...
}
//... placeholder
// add a new handler, which for now returns a placeholder just
func(app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("create a snippet..."))
}
```

Finally, need to update the tble in our `home.page.html`file that the links in the HTML also use:

```html
<link rel="stylesheet" href="/static/css/main.css" type="text/css">
<link rel="shortcut icon" href="/static/img/favicon.ico" type="image/x-icon">
```

Absolute path needed!