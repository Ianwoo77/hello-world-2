# Reshaping and pivoting

A data set can arrive in a format unsuited for the analysis that we’d like to perfrom on it. Sometimes, issues are confined to a specific column, row, or cess or cell. A column may have the wrong data type, a row may have missing values, or a cell may have incorrect character casing. At other times, a data set may have larger structural problems that extend beyond the data.

*Reshaping* a data set just means manipulating it into a different shape, one that tells a story that could not be gleaned from its original presenation. Reshaping offers a new view or perspective on the data.

### Wide vs. narrow data

A *narrow* data set is also called a *long* or a tall data set., And a *wide* data set increases in width, and a narrow/long/tall is increases in height. A wide data set is ideal for seeing the aggregate picture. The data set just becomes more difficulat to work with.

And a narrow gorws vertically, makes it easier to manipulate existing data and to add new records. Each variable is isolated to a single column. The optimal storage format for a data set depends on the insight we’re trying to glean from it, pandas offers tools to transform `DataFrame`s from anrrow to wide and vise versa.

Creating a pivot from a DF -- fore a list of business deals at fictional company like: For utility’s sake, convert the strings in the Date column to datetime objects with the `read_csv`function’s `parse_dates`parameter, after the change, the import looks good to go, can assign the df to a seals variable like:

```python
sales = \
pd.read_csv('../pandas-in-action/chapter_08_reshaping_and_pivoting/sales_by_employee.csv',
            parse_dates=['Date'])
```

### The `pivot_table`method

A pivot table aggregates a column‘s values and groups the results by using other column’s values. The word *aggregate* describes a summary computation that involves multiple values. Example aggregtions include average, sum, median, and count. A pivot table in pands is just similar to the pivot table feature in the excel. -- Follow:

1) select the column(s) whose value want to aggregate
2) Choose the aggregation operation to apply to column(s)
3) Select the column whose value will group the aggregated data into categories
4) Determine whether to place the groups on the row axis.

The method `pivot_table`index parameter accepts the column whose values will make up the pivot table’s index labels. Pandas will use the unique values from that column to group the results. Like:

`sales.pivot_table(index='Date', values=['Expenses', 'Revenue'])`

This method returns a regular DF, may be a bit underwhelming -- this DF is a pivot table -- The table shows average expenses and average revenue. Can:
`sales.pivot_table(index='Date', values=['Expenses', 'Revenue'], aggfunc=[np.sum, np.mean])`

For now, care only summing the values in the Revenue .. To aggregate values across multiple columns, can pass `values`a list of columns.

Have a sum of revenue -- final step is communiating how much each salesman conbributed to the daily totoal. fore:

```python
sales.pivot_table(index='Date',
                  columns='Name', 
                  values='Revenue',
                  aggfunc=np.sum)
```

Have aggregated sum of revenue organized by dates on the row axis and salesmen on the column axis. Notice the presence of `NaNs`in the data set. A `NaN`denotes that the salesman did not have a row in sales with a Revenue value for a given date. for this problem, can use the `fill_value`parameter to replace all pivot table’s `NaNs`with a fixed value.

```python
sales.pivot_table(
    index='Date', columns='Name',
    values='Revenue', aggfunc=np.sum,
    fill_value=0
)
```

May also want to see the revenue **subtatals** for each combination of date and salesman. Just like:

```python
sales.pivot_table(
    index='Date', columns='Name', values='Revenue',
    aggfunc=np.sum, fill_value=0,
    # add a margin name using `margins_name`
    margins=True, margins_name='Total' # default to `All`
)
```

Additional options for pivot tables -- a pivot table supports a variety of aggretation operations -- suppose that are interested in the number of business deals closed per day -- can pass `aggfunc`an argument `count`to count the number of `sales`rows for each combination of date and employee like:

```python
sales.pivot_table(
	index='Date', columns='Name', values='Revenue',
    aggfunc= 'count'
)
```

Then the `NaN`value indicates that the salesman did not make a sale on a given day. Can also pass a list of aggregation functions to the `pivot_table`function’s `aggfunc`parameter like:

```python
sales.pivot_table(
    index='Date', columns='Name', values='Revenue',
    aggfunc=[np.sum, np.count_nonzero], fill_value=0
)
```

Note that can apply different aggregations to different columns by passing a *dictionary* to the `aggfunc`parameter, note that using the dict’s keys to identify `DataFrame`columns and the values to set the aggregation.

```python
sales.pivot_table(
    index='Date', columns='Name', values=['Revenue', 'Expenses'],
    aggfunc=dict(zip(['Revenue', 'Expenses'],[np.sum, np.count_nonzero])), fill_value=0
)
```

Can also stack multiple grouping on a single axis by passing the `index`a list of columns. For, aggregates the sum of expenses by salesman and date on the row axis.

```python
sales.pivot_table(
    index=['Name', 'Date'],
    values='Revenue',
    aggfunc=np.sum
) # generate a two-level MultiIndex
```

And switch order of strings in the `index`list to re-arrange the levels in the pivot table’s `MultiIndex`.

```python
sales.pivot_table(
    index=['Date', 'Name'],  # reverse the order
    values='Revenue',
    aggfunc=np.sum
)
```

## Disabling Function Result Encoding

The result produced by functions are encoded for safe inclusion in an HTML document, which can present a problem for functions that generate HTML. If:

`categories=append(categories, "<b>p.Category</b>")`

The func has been modified so that genertes a slice containing HTML srings. The template engine encodes these values, which -- But for this app, not good. The `html/template`package defines a set of `string`type aliases that are used to denote the result from a function requires special handling like:

`CSS HTML HTMLAttr JS JSStr Srcset URL`

`func GetCategoires(products []Product) (categories []template.HTML){...}`

### Providing Access to stdlib Functions

Template functions can also be used to provide access to the features provided by the stdlib. like:

```go
allTemplates := template.New("allTemplates")
allTemplates.Funcs(template.FuncMap{
    "getCats": GetCategories,
    "lower": strings.ToLower,
})
allTemplates, err := allTemplates.ParseGlob("templates/*.html")
//...
```

The new mapping provdies access to `ToLower`function, which just transforms strings to lowercases,  fore:
`<h1>Category: {{lower .}}</h1>`

### Defining Template variables 

Actions can define variables in their expressions, which can be accessed within embedded template content, this feature is useful when you need to produce a value to assess in the expression. fore:

```html
{{define "mainTemplate" -}}
    {{$length := len .}}
    <h1>There are {{ $length }} products in the source data.</h1>
```

Template variable names are prefexed with the `$`character and are created with the short variable declaration syntax. The first action creates a variable named `length`-- which is used in the following like:

```html
{{ if ne ($char := slice (lower .) 0 1) "s" }}
	<h1>{{$char}}: {{.}}</h1>
{{- end}}
```

Using Template variables in Range Actions -- Variables can also be used with the `range`action, which allows maps to be used in templates. modify the `Execute`method like:

```go
func Exec(t *template.Template) error {
	productMap := map[string]Product{}
	for _, p := range Products {
		productMap[p.Name] = p
	}
	return t.Execute(os.Stdout, &productMap)
}
```

```html
{{define "mainTemplate" -}}
    {{range $key, $value := . -}}
        <h1>{{$key}}:{{printf "$%.2f" $value.Price}}</h1>
    {{ end }}
{{- end}}
```

The `text/template`is similar to the `html/template`-- except it doesn’t contain some html element, the template actions, expressions, actions.. are the same.

## Creating HTTP Servers

Describe the stdlib support for creating HTTP servers and processing HTTP and HTTPs requests.

### Creating a simple HTTP Server

The `net/http`package makes it easy to create a simple HTTP server, which can then be extended to add more complex and useful features. FORE:

```go
type StringHandler struct {
	message string
}

func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {
	io.WriteString(writer, sh.message)
}

func main() {
	err := http.ListenAndServe(":5000", StringHandler{message: "Hello"})
	if err != nil {
		Printfln("ERR: %v", err.Error())
	}
}
```

These are only a few lines of code, but they are enought to create an HTTP server that responds to requests with.

Creating the HTTP Listener and Handler -- The `net/http`package provides a set of convenience functions that amke it wasy to create an HTTP server without needing to specify too many details. like:

- `ListenAndServe(addr, handler)`-- this starts listening for HTTP requests on a specified address and passes requests onto the specified handler
- `ListenAndServeTLS(addr, cert, key, handler)`-- This starts listens for HTTPS

The address accepted by the functions can be used to restrict the HTTP server so that it only accepts requsts on a specific interface or to listen for requests on any interface. And, when a request arrives, it is passed onto a handler, whcih is responsible for producing a response. Handlers must implement the `Handler`interface defines the method:

- `ServeHTTP(writer, request)`-- invoked to process a HTTP request, The request is described by a `Request`value, and the responses is written using a `ResponseWriter`, both of which are received as paramters.

So, `ReponseWriter`interface defines the `Write`method equired by the `Writer`interface.

Inspecting the Request -- HTTP requests are represented by the `Requst`struct, defined in the `net/http`package just

- `Method`-- provides the HTTP method as a string , the `net/http`also defines constants for the HTTP methods, such as `MethodGet`..
- `URL`-- returns the requested URL
- `Proto`-- indicates the version of the HTTP used for the request
- `Host`-- returns a `string`containing the request host.
- `Header`-- which is just an alias to `map[string][]string`and contains the request headers. And the map keys are names of the headers, and values are `string`slices containing the header values.
- `Trailer`-- returns a `map[string]string`that contains any additional headers that are included in the request.
- `Body`-- returns a `ReadCloser`.

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {
	Printfln("Method: %v", request.Method)
	Printfln("URL: %v", request.URL)
	Printfln("URL: %v", request.Proto)
	Printfln("URL: %v", request.Host)
	for name, val := range request.Header {
		Printfln("Header: %v, Value: %v", name, val)
	}
	Printfln("---")
	io.WriteString(writer, sh.message)
}
```

### Filtering requests and generates Responses

The HTTP server responds to all requests in the same way, which isn’t ideal -- to produce different responses, Need to inspect the URL to figure out what is being requested and use the functions provided by the `net/http`package to send an appropriate response -- the most useful and methods by the `URL`struct like:

`Scheme, Host, RawQuery, Path, Fragment`
`Hostname(), Port(), Query(), User(), String()`

And the `ResponseWriter`interface also defines the methods that are available when creating a respons. this interface includes the `Writer`so that it can be used as a `Writer`.

- `Header()`-- this returns a `Header`which is alias to `map[string][]string`, that can be used to set the response headers.
- `WriteHeader(code)`-- sets the status code for the response, specified as an `int`.
- `Write(data)`-- writes data to the response body and implements the `Writer`interface. FORE:

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {
	if request.URL.Path == "/favicon.ico" {
		Printfln("request for icon detected - returning 404")
		writer.WriteHeader(http.StatusNotFound)
		return
	}
	Printfln("Request for %v", &request.URL.Path)
	io.WriteString(writer, sh.message)
}
```

## Project Setup and Enabling Modules

The next thing we need to do is let Go know that we just want use *modules functionality* to help manage and 3rd-packages that our project imports. To just avoid potential import conflicts with other people’s packags or the stdlib in the future, want to pick a modulepath that is globally unique and unlikely to be used by anything else. In the Go community, a common convention is to namespace your module paths by basing them on a URL that you own. Like:

```sh
cd snippetbox
go mod init alexdwards.net/snippetbox
```

Web App basics -- 

- Need a handler first, if you are coming from an MVC, can think of handlers as being a bit like a *controller*. They are responsible for executing your app logic and for writing HTTP response headers and bodies.
- Second component is a router, stores a mapping between URL and your app and the corresponding handlers. Usually have one `serveMux`for your app containing all your routes.
- The last thing need a web server. One of the great thing about go is that you can establish a web server and listen for incoming as a aprt of your app itself. Don’t need an external Nginx.

```go
func home(w http.ResponseWriter, response *http.Request) {
	w.Write([]byte("Hello from Snippetbox"))
}

func main() {
	// Use the http.NewServeMux() function to initialize a new `servemux`
	// register the home as the handler for the `/`
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)

	// Use the http.ListenAndServe() to start a new web server
	// two parameters:
	// TCP network address, servemux we created
	log.Println("Starting server on :4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}

```

### Routing Requests

Having a web app with just one route.. just add some more.

```go
func showSnippet(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Display a specific snippet..."))
}

func createSnippet(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Creating a new snippet..."))
}
```

Fixed Path and Subtree Patterns -- Go ‘s servemux supports two different types of URL patterns, *fixed* and *subtree* -- Fixed **dont** end with a trailing slash, and subtree **do** end with a trailing slash. In Go’s servemux, fixed path patterns like `/snippet`are only matched when the requst URL path *exactly* matches the fixed path.

Pattern `/`is an example of a subtree path -- fore, `/static/`-- are matched whenever the *start* of a request URL path matches the subtree path. Can think of as acting a bit like `/**` -- the pattern essentially means that *match a single slash, followed by anything.*

Restricting the Root URL pattern -- What if *don’t* want the `/`to act like a catch all -- FORE, want match and only match the `/`other 404. It’s not possible to change the behavior of Go’s servemux to do this -- but can include a simple check in the `home`handler which ultimately has the same effect. 

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	w.Write([]byte("Hello from Snippetbox"))
}
```

The `DefaultServeMux` -- If have been working with go while -- `http.Handle()`and `http.HandleFunc()`these allow U to register routes without declaring a servemux. Just like:

```go
func main(){
    http.HandleFunc("/", home)
    http.HandleFunc("/snippet", showSnippet)
    //...
    err := http.ListenAndServe(":4000", nil)
}
```

Behind the scenes, these register their routes with sth called *DefaultServeMux*. It’s just regular servemux like we have been useing -- whichi is initialized by default and stored in a `net/http`global varaible. just like:
`var DefaultServeMux= NewServeMux()`
but this is not recommended -- cuz `DefaultServeMux`is just a global object, any package can just access it and register a route -- inclue any 3rd-party packages that yuour app imports.

Additional Info -- 

- In go’s ServeMux, longer URL patterns always take precedence over shorter ones. So, if a servemux contains multiple patterns which match a request, will always dispatch the request to the handler corresponding to the longest one.
- Request URL paths are automatically sanitiazed. fore `/foo/bar/...//baz` will 301 to ``/for/bar`
- If a subtree path has been registered and a request is received fro that subtree path without a trailing slash, then the user will automatically be sent a 301. Fore, if have registered the subtree `/foo/`then request to `/foo`then redirected to the `/foo/`by 301.

Host Name matching -- Only when there is not a host-specific match found will the non-host specific patterns also be checked --  For go’s servemux is pretty lightweight -- doesn’t support routing based on the request method.

### Customizing HTTP Headers

Creating a new snippet in a dbs is a non-idempontent action that changes the state of server. Begin by updating `createSnippet()`so that it will send a 405 (method not allowed) unless the method is *Post*. like:

```go
func createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(405)
		w.Write([]byte("Method not allowed!"))
		return
	}
	w.Write([]byte("Creating a new snippet..."))
}
```

- for this, only possible to call `w.WriteHeader()`once per response - and, after the status code has been writtern it can’t be changed.
- If don’t call `w.WriteHeader()`explicitly, then the first all to `w.Write()`will automatically send a 200ok.

Customizing Headers -- Another improvement can make is to include an `Allow:POST`header with every 405 response to let the user know which requst methods are just supported for the particular URL. Can do this by using the `w.Header().Set()`method to add a new header to response header **map**. Like:
`.Header().Set("Allow", http.*MethodPost*)`

The `http.Error`Shortcut -- If want to send a non-200 status code and a plain-text response body, then it’s a good opportunity to use the `http.Error()`shortcut. This is just a lightweight helper function which takes a given message and status code, then calls the `w.WriteHeader()`and `w.Write()`methods.
`http.Error(w, "Method Not Allowed", 405)    `
We are now passing our `http.ResponseWriter`to another func, which sends a response to the user for us.