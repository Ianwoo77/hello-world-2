# Interpolation

When data contains missing values, can remove any row containing even one missing vlaue, but that may be too heavy-handed and may also remove useful data. One *alterntive* is interpolation.

```python
s = pd.read_csv('nyc-temps.txt').squeeze()
```

Read the one-column data from txt and then tell pandas we want it back as a series. Cuz The data contains 728 rows and there are just 8 different hours, can take advantge of some core Python functionality -- multiply the 8-element list of integer by 91 and get a list of 728 element. Once we have created our data frame, remove some of the data to simulate out ages.

```python
df.loc[
    df['hour'].isin([3,6], ), 'temp'
]=NaN
```

Notice that this query has several pieces -- 

- Look for `df['hour']`to be either 3 or 6 using `isin`, getting a boolean series back
- After the comma, where choose columns, pass `temp`
- then use `loc`not to retreive rows but rather to assign `NaN`to them en masse.

In pandas, the `DataFrame.interpolate`function is used to fill in missing values (`NaN`) within your DataFrame, here is a breakdown of what it does -- Filling missing vlaues in a DataFrame using various interpolation methods.

- Can specify the interpolation method to be sued, 
  - `linear`-- files by connecting adjacent
  - `pad`replicates the last valid value
  - `ffill`-- forward
  - `time`-- time-based data

By default, `interpolate`fills **any** `NaN`value with the average of the numbers that come before and after it. By passing a vlaue to the `method`parameter, can instruct `interpolate`to use a different system for interpolation. Like if pass `method='nearest'`, NaN values will be replaced by the closest non-NaN value.

```python
df= df.interpolate()
df.temp.describe()
```

And a cheap solution to interpolation is to just replace `NaN`values with the column’s `mean`-- compare the new mean and median -- like:

```python
df.loc[df['temp'] <= -1, 'temp'] = np.nan
df = df.fillna(df.mean())
```

### Selective Updating

In this, want to create the same 2-column data frame as in the last exercise -- Then update the values in the `temp`column so that any value less then 0 is set to 0. can:

1. Get a boolean index for when `df['temp']`is less than 0
2. Apply that boolean index to the dataframe
3. Retrieve the column by using `['temp']`on the data frame.
4. Assigning new value

`df[df['temp']<0]['temp']=0`

Cuz pandas does a lot of internal analysis and optimization when it’s putting together queries. Thus, cannot know whether your assignment will change the `temp`column on the `df`.

1. Should use `df.loc[]`to start
2. Put our boolean index for the rows inside the `[]`as before
3. Put our column selector, which is `temp`in this case, inside the same `[]`brackets, following a comma
4. Assign to the value.

So, should: `df[df['temp']<0', 'temp']=0`-- will never see the warning message cuz using this.

```python
df.loc[df.temp%2==1, 'temp']=df.temp.mean()
# set the even at hours 9 and 18 to 3
df.loc[df['hour'].isin([9, 18]),
    'temp'] = 3
# if the hour is odd, set the temp to 5
df.loc[ df['hour']%2 == 1, 'temp'] = 5
```

## When to use interfaces

When should we create interfaces in Go -- look at 3 concrete use cases where interfaces are usually considered to bring value -- Note that the goal isn’t to be exhaustive cuz the more cases we added, the more they would depend on the context -- 

#### Common behavior

Is to use interfaces when multiple types implement a common behavior -- in such a case, can factor out the behavior inside an interface -- look at th std library, can find many examples of such a use case. Fore, sorting a collection can be just factored out via 3 methods -- like

1. Retrieving the nubmer of elements in the collection
2. Reporting whether one element must be sorted before another
3. Swapping two elements

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

Throughout the `sort`package, can find IMPs. So, fore, is it important whether the sorting algorithm is merge sort of quick-sort -- in many cases, don’t care. Hence, the sorting behavior can be abstracted, can depend on the `sort.Interface`.

Finding the right abstraction to factor out a behavior can also bring many benefits.

#### Decoupling -- 

Another important use case is about decoupling our code from an IMP -- if rely on an abstraction instead of a concrete IMP -- the IMP itself can be repalced with another without even having to change our code -- And one beneift of decoupling cna be related to *unit testing*.

```go
type CustomerService struct {
    store mysql.Store
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.store.StoreCustomer(customer)
}
```

For this, if want to test -- cuz `CustomerSerivce`just relies on the actual IMP to store a `Customer`, are obliged to test it through integration tests -- which may require spinning up a MYSQL instance.

```go
type customerStorer interface {
    StoreCustomer(Customer) error
}

type CustomerService struct {
    storer customerStorer // just IMP this interface, some other type
}

func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.storer.StoreCustomer(customer)
}
```

Cuz storing a customer is now done via interface, this gives us more flexibility in how we wnat to test the method.

- Use the concrete IMP via integration tests
- Use a mock
- Or both

#### Restricting Behavior

It’s just about restricting a type to a specific behavior. Create a specific container for `int`configurations via an `IntConfig`struct that also exposes two methods -- `Get`and `Set`like:

```go
type IntConfig struct{}
func (c *IntConfig) Get() int {}
func (c *IntConfig) Set(value int) {}
```

Fore, now we are only interested in retrieving the configuration value, want to prevent updating it. Just like:

```go
type intConfigGetter interface {
    Get() int
}
```

Then in the code, can rely on `intConfigGetter`instead of the concretet IMP like:

```go
type Foo struct {
    threhold intConfigGetter
}
func NewFoo(threhold intConfigGetter) Foo { // return a Foo
    return Foo {threhold: threhold}
}
func (f Foo) Bar() {
    threhold := f.threhold.Get() // Foo struct can just use `Get()`
}
```

In this example, the configuration getter is injected into the `NewFoo`factory method, it doesn’t impact a client of this func cuz it can still pass an `IntConfig`struct as it  implements `intConfigGetter`.

### Interface Pollution

The main caveat when programming meets abstractions **in go** is remembering that abs should be *discovered*,  *NOTE Created*. We shouldn’t design with interfaces but wait for a concrete need -- we should create an interface when need it, now when foresee that could need it.

The main problem is -- they make the code flow more complex-- adding a useless level of indirection doesn’t bring any vlaue -- creates a worthless abstraction making the code more difficult to read..

### Interface on the Producer side

Misunderstand one question -- where should an interface live -- 

- *Producer side* -- An interface defined in the same package as the concrete IMP.
- *Consume side* -- An interface defined in an external package where it’s used.

And it’s common to see developers creating interfaces on the producer side, alongside the concrete IMP. In Go, in most cases -- *consume side*.

```go
// fore create specific package to store and retrieve customer data
// still in same package, decide taht all the calls have to go through the following interface:
type CustomerStorage interface {
    StoreCustomer(customer Customer) error
    GetCustomer(id string) (Customer, error)
    //...
}
```

Think have some reasons to create and expose this on the producer side -- it’s a good way to decouple the client code form the actual IMP. Interfaces are just satisfied implicitly in Go -- tends to be a game-chaner to languages with an explicit imp. *Abs should be discovered, not created*. this also  means that it’s not up to the producer to force a given abs for all the clients. 

Instead -- it’s up to the client to decide whether it needs some form of abstraction and then determine the best abs level for its needs.

Fore, one client won’t be interested in decoupling its code -- maybe another client wants to decouple its code but is only interested in the `GetAllCustomers()`fore, In this case, this client can create an interface with a single method.

```go
package client
type customerGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

From a package org -- shows the result like:

- Cuz the `customersGetter`interface is only used in the `client`package, remain unexported
- Visually, in the figure, it looks like circular dependencies. There is no dependency from `store`to `client`cuz the interface is satisfied implicitly.

The main point is that the `client`package can now define the most accurate abstraction for its need. It relates to the concept of the Interface-Segretaion Principle -- which states that no clients should be forced to depend on methods. Therefore, in thise case, the best approach is to expose the concrete IMP on the producer side and let the client decide how to use it and whether an abstraction is needed.

And -- interfaces on the producer side -- is sometimes used in the STDLIB. Fore, The `encoding`package defines interfaces implemented by other subpackages such as `encoding/json`or `encodeing/binary`. In this case, the abs defined in the `encoding`are used across the stdlib, and the language designers knew that creating these abs up front was valuable.

An interface should live on the consumer side in most cases -- in particular contexts -- may want to have it on the producer side.

### Returning Interfaces

While designing a func signature, may have to return either an interface or a concrete IMP. And understand why returning an interface is -- note: in many cases, considered a bad practice in Go. Will consider two packages -- 

- `client`-- which contains a `Store`interface
- `store`-- which contains an IMP of `Store`.

If in the `store`package -- create a `NewInMemoryStore`to return a `Store`interface -- There is dependency from the IMP package to the client package in this design. Fore, the `client`can’t call the `NewInMemoryStore`function anymore,  Otherwise, there ould be a cycle dependency.

Furthermore, what happens if another client uses the `InMemoryStore`struct -- in that case, perhaps we would like to more the `Store`to another package...

Hence, in generally, returning an interface restricts flexibility cuz we force all teh clients to use one particular type of abstraction. If apply this idiom in Go -- means:

- Returning structs instead of interfaces
- Accepting interfaces if possible.

And, also some exceptions -- The most relevant one concerns the `error`type -- an interface returned by many functions, can also examine another exception in the stdlib with the `io`package -- like:

```go
func LimitReader(r Reader, n int64) Reader {
    return &LimitReader{r, n}
}
```

The fucntion signature is an interface -- `io.Reader`-- The `io.Reader`is an up-front abstraction -- it’s not one defind by clicents, but it’s one that is forced cuzt he Language designers knew in advacne that this level of abstraction would be helpful.

## Proj Setup And Enabling Modules

The next thing need to do is let Go know that we want to use `modules functionality`to help manage and third-party packages that our project imports.

If Are not already familar with Go’s module functionality, the module path is essentially just the canonical name of identifier for project. Although can use anything as the module path, the improtant thing is uniqueness. To avoid potential import conflicts with other people’s packages or the std lib in the future, want to pick a module path  that is globally unique and unlikely to be used by anything else.

### Web Application Basics

Now that everything is set up correctly let’s make the first iteration of our web app -- begin with the 3 absolute essentials -- 

- The first thing need is a handler -- coming from an MVC-background, can think of handlers as being a bit like controllers, they’re responsbiel for executing your application logic and for writing HTTP response headers and bodies.
- The second component is a router -- This stores a mapping between the URL patterns for your app and the corresponding handlers. Usually you have one servemux for your application containing all your routes.
- The last thing need a web server, one of the great things about Go is that you can establish a web server and listen for incoming requests as part of your app itself.

```go
func home(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello from Snippetbox"))
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)

	log.Println("Starting server on :4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}
```

When run this code, it should start a new server listening on port 4000 of your local machine.

#### Additional Information -- 

The TCP network address that you pass to the `http.ListenAndServe()`should be in thr format `host:port`-- if omit the hsot then the server will listen on all your compouter’s availble network interfaces. Generally, only need to specify a host in the address if your computer has multiple network interfaces and you want to listen on just one of them.

In other Go projects or documentation you might sometimes see network addresses written using named ports like `:http`or `:http-alt`instead of a nubmer.

### Routing Requests

Having a web app with just one route is exciting -- let’s add a couple more routes so that the application starts to shape up like this -- 

```go
// Add a showSnippet handler function.
func showSnippet(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Display a specific snippet..."))
}

func createSnippet(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Creating a new snippet..."))
}
```

#### Fixted Path and Subtree patterns

Go’s servemux supports two different types of URL patterns - *fixed paths* and *subtree paths*. Fixed **don’t** *end* with a trailing slash, whereas subtree paths *do* end with the trailing slash. Fore, `/snippet/craete`is an example of fixed paths -- In go’ servemux, fixed like these are only matched when the request URL path *exactly* matches the fixed path. In contrast, our `/`is an example of a subtree path -- antoher like `/static/`-- subtree path patterns are matched whenever the start of the request URL path matches the subtree  path, just like `/**`.

#### Restricting the Root URL pattern

If don’t want the `/`pattern to act like a catch-all -- Fore, in the application we are building we want the home page to be displayed if and only if the requst URL path exactly math `/`. It’s not posible to change the behavior of Go’s servemux to do this, but *can* include a simple check in the `home`hander which ultimately has the same effect.

```go
func home(w http.ResponseWriter, r *http.Request) {
    // Check if the current request URL path exactly mathes '/', if it doesn't use
    // the http.NoteFound() function to send a 404 response to the celint. we then return from the handler
    // also write the message
    if r.URL.Path != "/" {
        http.NotFound(w,r)
        return
    }
    w.Write([]byte("hello from snippetbox"))
}
```

Go ahead and make that change, then make a request.

#### `DefaultServeMux`-- 

If have been working Go -- might have come across the `http.Handle()`nad `http.HandleFunc()`functions. These allows U to register routes *without* declaring a servemux like this:

```go
http.HandleFunc("/", home)
http.HandleFunc("/snippet", showSnippet)
http.HandleFunc("/snippet/create", createSnippet)

log.Println("Starting server on :4000")
err := http.ListenAndServe(":4000", nil)
```

Behind the scenes, these functions register their routes with sth called `DefaultServeMux`-- there is just nothing special about this -- just regular servemux -- which is initialized by default and stored in the `net/http`global variable. Like: `var DefaultServeMux = NewServeMux()`

Note -- Cuz `DefaultServeMux`is a *global* variable, any package can access it and register a route -- including any 3rd-party packages that your application imports. If one of those 3rd-party packages is compromised, they could use `DefaultServemux`to expose malicious handler to the web.

### Additional Info -- 

`ServeMux`features and Quirks -- 

- In Go’ ServeMux, longer URL patterns always take precedence over shorter ones.
- Request URL paths are automatically sanitized. If request to `/foo/bar/..//baz`they will automatically be sent a 301 permanent redirct ot `/foo/baz`instead.
- If a subtree path has been registered and a requested is received for that subtree wihtout `/`trailing -- will automatically be sent a 301 to the subtree path with the slash added. Fore, if U just have registered the subtree path `/foo/`- then any request to the `/foo`will be redirect to `/foo/`.

#### Host Name matching -- 

It’s just possible to include host names in your URL patterns -- can be useful when U want to redirect all HTTP requests to a canonical URL -- or if your app is acting as the back end for mutliple sites or services. like:

```go
mux := http.NewServeMux()
mux.HandleFunc("foo.example.org/", fooHadnler)
```

#### What about restful routing -- 

It’s important to acknowledge that the routing functionality provided by Go’s servemux is pretty lightweight. It doesn’t support routing based on the Request method, doesn’t support semantic URLs with variables in them. Doesn’t support regexp-based patterns.

### Customizing HTTP Headers

POST -- `/snippet/create`-- Handler -- `createSnippet`-- create a new snippet -- like: Making this change is important cuz later in build -- requests to the `/snippet/create` Http status codes -- just update the `createSnippet()`handler so that it sends a 405 -- method not allowed HTTP stautus.

```go
func createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(405) // status code 405
		w.Write([]byte("Method not allowed"))
		return
	}
	w.Write([]byte("Create a new method"))
}
```

- It’s only possible to call `w.WriteHeadder()`one per response, and after the status code has been written it can’t be changed. If you try to call `w.WriteHeader()`a second time Go will log a warning message
- If don’t call `w.WriteHeader()`explicitly, then the first call to `w.Write()`will automatically send a 200 ok status code to the user. So if want to send a non-200 status code, must call `w.WriteHeader()`before `w.Write()`.

`curl -i -X POST http://localhost:4000/snippet/create`

- `-i`tells `curl`to include the headers in the output, this means will see the request headers.
- `-X POST`tells the http method to be used.

#### Customizing Headers

Another improvement we can make is to include an `Allow: Post`header with every 405 not allowed response to let the user know which request methods are supported for the particular URL -- Can do this by using the `w.Header().Set()`method to add a new header to the response header map like so:

```go
func createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
        w.Header().Set("Allow", http.MethodPost)  // can see `Allow : Post` in the header
		w.WriteHeader(405)
		w.Write([]byte("Method Not Allowed"))
		return
	}
	w.Write([]byte("Create a new method"))
}
```

#### The `http.Error`shortcut

If want to send a non-200 status code and a plain-text response body, then it’s a good opportunity to use the `http.Error()`shortcut, this is a lightweight helper function which takes a given message and status code, then calls the `w.WriteHeader()`and `w.Write()`methods behind-the-scenes for us.

```go
if r.Method != http.MethodPost {
    w.Header().Set("Allow", http.MethodPost)

    // use the http.Error() function to send a 405 code and string
    http.Error(w, "Method Not allowed", 405)
    return
}
```

In terms this is almost exactly the same -- The biggest difference is that we are now passing our `http.ResponseWriter`to another function, which sends a response to the user for us. The pattern of passing `http.ResponseWriter`to other functions is suer-common in Go -- and sth we will d a lot throughout the book.

#### Addiional Info

In the code -- `w.Header().Set()`to add a new header to the response header map -- also `Add(), Del(), Get()`methods that you an use to read and manipulate the header map too. like:

```go
// Set a new cache-control header like:
w.Header().Set("Cache-Control", "public,max-age=...")
w.Header().Add("Cache-Control", "public")
w.Header().Add("Cache-Control", "max-age=")

// Delete all values for the cache-Control header
w.Header().Del("Cache-Control")

// Retrieve the first value for the cache-Control
w.Header().Get("Cache-Control")
```

#### System-generated headers and Content Sniffing

When sending a response Go will automatically set 3 syste-generated headers for you -- `Date, Content-Length`and `Content-Type`-- For the `Content-Type`, Go will attempt to set the correct one for you by content sniffing the resposne body with the `http.DetectContentType()`function. Is this function can’t guess the content type, Go will fall back to setting the header -- `Content-Type: application/octet-stream`.

And the `http.DetectContentType()`function generally works quite well-- but a common for web developers new to Go is it can’t distinguish JSON from plain text. So by default, JSON responses will be sent with `Content-Type text/plain, charset=utf-8`header, can prevent this from happening by setting the correct header like:

```go
w.Header().Set("Content-Type", "application/json")
w.Write([]byte(`{"name": "Alex"}`))
```

#### Header Canonicalization

When using the `Add, Get, Set, Del`methods on the header map, the header name will always be canonicalized using the `textproto.CanonicalMIMEHeaderKey()`function. And if need to avoid this canonicalization behavior you can edit the underlying header map directly like:

`w.Header()["X-XSS-Protection"]= []string {"1;mode=block"}`

Suppressing System-Generated headers -- the `Del()`method **doesn’t** remove system-generated headers, to suppress these, need to access the underlying header map directly to set the value to `nil`. like:
`w.Header()["Date"]=nil`

### URL Query Strings

Can use like: `/snippet?id=1`, And to make this work need to update the `showSnippet`hander to do two things like:

1. Needs to retrieve the value of the `id`parameter from the URL query string, which we can using the `r.URL.Query().Get()`method -- this will always return a string value for a parameter, or the empty `“”`no matching parameters exists
2. Cuz the `id`is ntrusted user input -- should *validate* it to make sure it’s just sane and sensible. For the purpose of our app, went to check that it contains a positive integer value, using the `strconv.Atoi()`to check that.

```go
func showSnippet(w http.ResponseWriter, r *http.Request) {
	// Extract the value of id parameter from the query string and try to
	// convert it to an integer using the strconv.Atoi() function. like:
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	// interpolate the id values with our response like:
	fmt.Fprintf(w, "Display a specific snippet with ID: %d...", id)
}
```

And, might also like to visiting some URLs which have invalid values for the `id`paraemter.

The `io.Writer`interface -- like:

`func Fprintf(w io.Writer, format string, a ...interface{})(n int, err error)`

We are be able to do this cuz the `io.Writer`type is an interface, and the `http.ResponseWriter`object just satisfies the interface has w `w.Write()`method.

### Proj Structure and Organization

It’s important to explain upfront that there is no single riht -- way to structure web applications -- It meanst that you have freedom and flexibility over how you organzie your code, but it’s also easy to et stuck down a rabbit-hole of uncertainty when trying to decide what the best structure should be.

```sh
mkdir -p cmd/web pkg ui/html ui/static
```

- The `cmd`directly will contain the app-specific code for executable apps in the proj
- `pkg`will contain the ancillary non-application-specific code, fore, use it to hold potentially reusable code like validation helpers and the SQL dbs models for the projec
- the `ui`will contain the user-interface assets used by the web application.

And the two benefits -- 

1. Gives a clean separation between Go and non-go assets.
2. It scales really nicely if want to add another executabel applicatio to proj so:

### HTML templating and inheritance

Inject a bito of life into the proj and develop a proper home page for the web app -- 

```html
<body>
<header>
    <h1><a href="/">Snippetbox</a></h1>
</header>
<nav>
    <a href="/">Home</a>
</nav>
<main>
    <h2>Latest snippets</h2>
    <p>There is nothing to see yet</p>
</main>
</body>
```

So now that we have created a template file with the HTML markup for the home page, the next is how do we get our `home`handler to render it.

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	
	// use the template.ParseFiles() to read template file
	ts, err := template.ParseFiles("./ui/html/home.page.html")
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
		return
	}
	
	err = ts.Execute(w, nil)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
	}
}
```

It’s just important to point out that the file path that you pass to the `ParseFiles()`must either be relative to your current working directory, or an absolute path.

#### Template Composition -- 

As add more pages on this web application there will be some shared -- boilerplate, HTML markup that want to include on every page -- like the header, navigation, and metadata insid the `<head>`fore. -- So, to save us typing and prevent duplication, it’s a good idea to create a layout template which contains this shared content. To save us typing and just.
