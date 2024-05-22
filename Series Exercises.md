# Series Exercises

Create a sereis of 10 elements, random integers from 70 to 100, representing scores on a monthly exam. Set the index to be the month names, starting in Sep. And ending in June.

```python
g= np.random.default_rng(0) # seeds the random_number generator with 0
a = g.integers(0,100,10)
g= np.random.default_rng(0)
b= g.integers(0,100,10)
a==b # True,,...
# get 10 random integers between 70 and 100 with:
g= np.random.default_rng(0)
s= pd.Series(g.integers(70,101,10))
s.index = 'Sep Oct Nov Dec Jan Feb Mar Apr May Jun'.split()
first_half_average= s.loc['Sep':'Jan'].mean()
```

Simply, when use the `.loc`the slice is no longer up to and not including. But rather *up to and including*.

#### Tests

Here are 3 additional exercises -- 

```python
# five highest scores
s.nlargest(n=5)
s.sort_values(ascending=False).head(5)
s.max(), s.idxmax()
s.round(-1)
```

Whether we are using the `mean`or `median`to find the central point in our data set, will almost certainly want to know that the *standard deviation* -- a measurement of how much the values in our data set vary form one another. In a data set with 0 std deviation, the values are all identical. A data set with a very large std deviation has values that vary greatly from the man value.

To calculate the std deviation on series `s`, do the following -- 

- Calculate the diffference between each value in `s`and its `mean`.
- Square each of these values.
- Sum the squares
- Divide by the number of elements in `s`. The `s` is known as the variance.

#### Understanding the dtype -- 

In py, constantly use the built-in core data types, `int float str list tuple`and `dict`-- Pandas is a bit different in that we don’t use those types much. Every series has a `dtype`attribute-- and U can always read from that to know the type of data it contains. 

Several std types of `dtype`values are defined by Numpy and used by pandas. There are also special pandas-specific types, some of which we will discuss later -- Can override thse choices by deefault like:

`s= pd.Series([10,20,30], dtype=np.float16)`

#### Scaling test scores

```python
s1 = pd.Series([10,20,30,40], index=[*'abcd'])
s+3 # broadcast
s1 = pd.Series([10,20,30,40], index=[*'abcd'])
g= np.random.default_rng(0)
months = 'Sep Oct Nov Dec Jan Feb Mar Apr May Jun'.split()
s= pd.Series(g.integers(40,60,10), index=months)
s+(80-s.mean())
```

#### Couting tens digits 

Python’s `//`operator performs integer division -- divide the series by 10 using `//`, still get our `dtype`of `int8`. That is the approach go with because it reduces the number of operations we need to perform.

```python
g = np.random.default_rng(0)
s = pd.Series(g.integers(0, 100, 10))
s.astype(str).str[-2].fillna('0')
```

That is not enough, if have a one-digit number, will `get(-2)`-- `NaN`-- Fortunately, we can use the `fillna`method to repalce `NaN`with any other value.

```python
s.astype(str).str.get(-2).fillna('0').astype(np.int8)
```

Think this is just a clearer way to do things than the int-to-float technique.

## Using Templates to Generate Responses

There is no built-in support for using tempalte as responses for HTTP requests, but it is a simple process to set up a handler the users the features provided by the `html/template`package. Core code like:

```html
<tbody>
	{{range $index, $product := .Data}}
    // ...
</tbody>
```

Then for the source code like:

```go
type Context struct {
    Request *http.Request
    Data []Product
}
var htmlTmeplates *template.Tempalte
func HandleTemplateRequest(writer http.ResponseWriter, request *http.Request) {
    path := request.URL.Path
    if pat == ""{
        path = "products.html"
    }
    t := htmlTemplates.Lookup(path)
    if t == nil {
        http.Notfound(writer, request)
    }else {
        err := t.Execute(writer, Context {request, Products})
        if err != nil {
            http.Error(writer, err.Error(), http.StatusInernalServerError)
        }
    }
}

func init() {
    var err error
    htmlTemplates= template.New("all")
    htmlTemplates.Funcs(map[string]any {
        "intVal": strconv.Atoi,
    })
    htmlTemplates, err = htmlTemplates.ParseGlob("templates/*.html")
    if err == nil {
        http.Handle("/templates/", http.StripPrefix("/templates/",
                                                    http.HandlerFunc(HandleTemplateRequest)))
    }else {
        panic(err)
    }
}
```

Need to note that the initialization function loads all the templates with the `html`extension in the `templates`folder and sets up a route so that requests that start wtih `/templates/`are processed bh the `HandleTemplateRequest`function.

#### Responding with JSON Data

JSON responses are widely used in web services, which provide access to an application’s data for clients that don’t want to receive HTML, such as Angular.. create more complex wb service -- fore:

```go
func HandleJsonRequest(writer http.ResponseWriter, request *http.Request) {
    writer.Header().Set("Content-type", "appliation/json")
    json.NewEncoder(writer).Encode(products)
}
func init(){
    http.HandleFunc("/json", HandleJsonRequest)
}
```

The initialization function creates a route, which means that requests for `/json`will be processed by the `HandleJsonRequest`function. This function uses the JSON feature to encode the slice of `Product`values created.

### Handling Form data

The `net/http`package provides support for easily receiving and processing form data. Add a file named `edit.html`to the `templates`folder like:

```html
<body>
{{ $index := intVal(index(index .Request.URL.Query "index") 0)}}
{{if lt $index (len .Data)}}
    {{with index .Data $index}}
        <h3 class="bg-primary text-white text-center p-2 m-2">Product</h3>
        <form method="post" action="form/edit" class="m-2">
            <div class="mb-3">
                <label>Index</label>
                <input name="index" value="{{$index}}"
                       class="form-control" disabled/>
                <input name="index" value="{{$index}}" type="hidden"/>
            </div>

            <div class="mb-3">
                <label>Name</label>
                <input name="name" value="{{.Name}}" class="form-control"/>
            </div>

            <div class="mb-3">
                <label>Category</label>
                <input name="category" value="{{.Category}}" class="form-control"/>
            </div>

            <div class="mt-2">
                <button type="submit" class="btn btn-primary">Save</button>
                <a href="/templates/" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    {{end}}
{{else}}
    <h3 class="bg-danger text-white text-center p-2">
        No product at specified Index
    </h3>
{{end}}
</body>
```

This template makes use of template variables, expressions, and functions to get the query string from the request and select the first `index`value -- which is converte to an `int`and used to retrieve a `Product`value from the data.

`{{$index := intVal(index(index .Request.URL.Query “index”) 0)}}`

These expressions are more complex than generally like to see in a template, and show you an approach found more robust in part 3.

#### Overusing getters and setters

In programming, data encapsulation refers to hiding the values or state of an object. Getters and setters are means to enable encapsulation by providing exported methods on top of unexported object fields. And in Go, there is no automatic support for getters and setters as we see in some -- it is also considered neigher mandatory nor idiomatic to use getters and setters to access struct fields. FORE, the std lib implements structs in which some fields are accessible directly, such as the `time.Timer`struct -- 

```go
timer := timer.NewTimer(time.Second)
<- timer.C
```

Could even modify `C`directly -- however, this example illustrates that the std Go library doesn’t enforce using getters and/or settters even when we shouldn’t modify a field. On the other hand, using getters and setters presents some advantages -- including -- 

- They encapsulate a behavior associated with getting or setting a field, allowing new functionality to be added later.
- They hide the internal representation, giving us more flexibility in what we expose
- They provide debugging interception point for when the property changes at run time.

If fall into just these cases or foresee a possible use case while guaranteeing forward compatibility, using getters and setters can bring some value. Fore, if we use them with a field called `balance`-- 

- The `getter`method should be named `Balance`(not `GetBalance`)
- The setter method should be named `SetBalance`

Like:

```go
currentBalance := customer.Balance()
if currentBalance<0 {
    customer.SetBalance(0)
}
```

In summary, shouldn’t overwhlem our code with getters and setters on struct if they don’t bring any value.

### Interface Pollution

Interfaces are one of the cornerstones of the Go language when designing and structuring our code. Like many tools or concepts, abusing them is generally not good idea. Interface pollution is about *overwhelming* our code with unncessary abstractions. Making it harder to understand. It’s a common mistake made by developers coming from another language with different habits.

#### Concepts -- 

An interface provides a way to specify the behavior of an object, use interfaces to create common abstractions that multiple objects can implement. What makes Go interfaces so different is that they are satisfied implicitly.

To understand what makes interfaces so powerful, will dig into two popular ones form the stdlib -- `io.Reader`and `io.Writer`-- the `io`package provides abstractions for `I/O`primitives. `io.Reader`just reads from a data source and fills a byte slice, whereas `io.Writer`writes to a target from a byte slice. like:

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

Custom implementations of the `io.Reader`interface should accept a slice of bytes, filling it with its data and returning either the number of bytes read or an error.

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

- `io.Reader`reads data from a source
- `io.Writer`writes data to target

What is the rationale for having these two interfaces in the language -- what is the point of creating these abstractions.

```go
func copySourceToDest(source io.Reader, dest io.Writer) error {}
```

This function would work like `*os.File`parameters -- and any other type that would implement these interfaces -- like:

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    source := strings.NewReader(input)
    dest := bytes.NewBuffer(make([]byte, 0))
    err := copySourceToDest(source, dest)
    if err != nil{
        t.Failnow()
    }
    got := dest.String()
    if got != input {
        t.Errorf("expected: %s, got: %s", input, got)
    }
}
```

So while designing interfaces, the granularity is also sth to keep in mind -- A known -- **The bigger the interface, the weaker the abstraction.**

Indeed, adding methods to an interface can decrease its level of resualbility. `io.Reader`and `io.Writer`are powerful abstractions cuz they cannot get any simpler. Furthermore, can also combine fine-grained interfaces to create higher-level abstractions. This is the case with the `io.ReadWriter`like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

#### When to use Interfaces

When should we create interfaces -- 3 concrete use cses where interfaces are usually considered to bring value. Note that the goal isn’t to be exhaustive cuz the more cases we add, the more they would depend on the context.

Common Behavior -- To use interfaces when just multiple types implement a common behavior -- In such a case, can factor out the behavior inside an interface. Look at the stdlib, can find many examples of such a use case.

- Retrieving the number of elements in the collection
- Reporting whether one element must be sorted before another
- Swapping two elements

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

Throughout the `sort`, can find dozens of implementations. Finding the right abstraction to factor out a behavior can also bring many benefits -- fore, the `sort`provides utility functions that also rely on `sort.Interface`.

```go
func IsSorted(data Interface) bool {
    n := data.Len()
    for i:= n-1; i>0; i-- {
        if data.Less(i, i-1){
            return false
        }
    }
    return true
}
```

#### Decoupling

Another important use case is about decoupling our code from an implementation -- if rely on an abstraction instead of a concrete implementation -- the implementation itself can be replaced with another without even having to change our code. One benefit of decoupling can be related to *unit test* -- assume want to implement a `CreatenewCustomer`method that creates a new customer and stores it.

```go
type CustomerService struct {
    store mysql.Store
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id: id}
    return cs.store.StoreCustomer(customer)
}
```

If want to test this method -- cuz `CustomerService`relies on the actual implemenration to store a `Customer`, are obliged to test through integration tests -- which requries spinning up a `MYSQL`instance. 

```go
type customer
```

