# String Slicing & Character replacement

Can also use the `slice`method on the `StringMethods`object to extract a substring from a string by index position. The method accepts a starting index and an ending index as arguments.

```python
inspections= inspections.replace(to_replace='All', value='Risk 4 (Extreme)')
inspections= inspections.dropna(subset=['Risk'])
inspections['Risk'].str.slice(5,6).head()
inspections.Risk.str[5:6].head()
```

And, what if we want to extract the categorical ranking from each row -- This challenge is made difficulty by the different lengths of the words.

```python
inspections['Risk'].str.slice(8).head()
inspections.Risk.str[8:].head()
inspections.Risk.str[8:-1].head()
```

Or, cuz each `str`method returns a new `Series`object with its own `str`attribute, this aspect allows us to chain multiple string methods in sequence, just like:

```python
inspections['Risk'].str.slice(8).str.replace(')', '').head()
```

### Boolean methods

Other methods can prove to be particular helpful for filtering a `DataFrame`-- Suppose that we want to isolate all establishments with the `Pizza`-- like: `‘Pizza'in "jets Pizza"’`

```python
inspections.Name.str.lower().str.contains('pizza').head()
```

Have a `Boolean`Series, can use to extract all establishments with `Pizza`in their name.

```python
has_pizza = inspections.Name.str.lower().str.contains('pizza')
inspections[has_pizza]
```

Noticed that pandas preserves the original letter casing of the values in Name.

```python
inspections.Name.str.lower().str.startswith('tacos').head()
```

### Splitting strings

Next data is a collection of fictional customers -- each row includes the customer’s `Name`and `Address`--like:

```python
customers.Name.str.len()
customers.Name.str.split(' ').head()
```

For this, have a small issue, due to suffixes such as -- some Names have more than two words, can see an example at index position 3.

```python
customers.Name.str.split(' ', n=1).str.len()
customers.Name.str.split(' ', n=1).str.get(1) # get(-1) return the last one
```

The `str.split()`method accepts an `expand`parameter, and when pass it an argument of `True`, returns a new `DataFrame`instead of `Series`of lists -- 

```python
customers.Name.str.split(' ', n=1, expand=True).head()
customers[['First Name', 'Last Name']]=customers.Name.str.split(' ', n=1, expand=True)
customers = customers.drop(labels='Name', axis=1)
```

### MultiIndex DataFrames

A `MultiIndex`is an index object that holds multiple levels, each level stores a value for the row, it is just optimal to use a `MultiIndex `when a combination of vlaues provides the best identifier for a row of data. For `Series `and `DataFrame`indices can hold various data types, strings, numbers, datetimes, and more. But all these objects can store only one value per index position.

Can create a `MultiIndex`object independently of a Series or DataFrame. The `MultiIndex`class is available as a top-level attribute on the pandas library. Note that it includes a `from_tuple()`that instantiates a `MultiIndex`from a list of tuples. fore:

```python
pd.MultiIndex.from_tuples(addresses)
row_index = pd.MultiIndex.from_tuples(tuples=addresses, 
                                      names=['Street', 'City', 'State', 'Zip'])
data = [
    ["A", "B+"],
    ["C+", "C"],
    ["D-", "A"],
]
columns = ['Schools', 'Cost of Living']
area_grades = pd.DataFrame(data, index=row_index, columns=columns)
```

We have a `DataFrame`wtih a `MultiIndex`on its row axis, each row’s label holds 4 values.

```python
column_index = pd.MultiIndex.from_tuples(
    [
        ("Culture", "Restaurants"),
        # ...
    ]
)
data = [["C-", "B+", "B-", "A"], ["D+", "C", "A", "C+"], ["A-", "A", "D+", "F"]]
pd.DataFrame(data, index=row_index, columns=column_index)
```

Attched both of our `MultiIndex`es to a `DataFrame`-- The `MultiIndex`for the row axis requires the data set to hold 3 rows. The `MultiIndex`for the column axis requires the data set to hold 4 columns.

## Memory leaks of Maps

When wroking with maps in Go, need to understand some important characteristics of how a map grows and shrinks.

```go
m := make(map[int][128]byte)
```

For this, each value of `m`is an array of 128 bytes, will do the following:

1. Allocate an empty map
2. Add 1M elements
3. Remove all, and run the GC.

```go
n := 1000000
m := make(map[int][128]byte)
for i:=0; i<n; i++ {
    m[i]=randBytes()
}

for i:=0; i<n; i++ {
    delete(m, i)
}

runtime.GC()
runtime.KeepAlive(m) // keeps the references to m so that the map isn't collected
```

At first, the heap size is minimal, then it grows significanty after having added 1M element to the map.and then run the GC, also make sure to keep a reference to the map using `runtime.KeepAlive()`so that the map isn’t collected as well. Discussed in the previous section that a map is composed of 8-element buckets -- A Go map is a pointer to a `runtime.hmap`struct -- this contains multiple fields -- 

```go
type hmap struct {
    B uint8 // log_2 of # buckets
}
```

So, after adding 1M elements the value of B equals 18, 262144 buckets -- and when remove 1M elements -- stil 18 of B -- namely, the map still contains the same number of buckets. *the reason is that the number of buckets in a map cannot shrink* -- fore the `[int][128]byte`-- holds per custom ID, a sequence of 128 bytes, fore, say want to store one hour of data -- meanwhile, our has decided to have a big promotion for Black Friday -- 

Another solution would be to change the map type to store an array pointer -- like: `map[int]*[128]byte`, it doesn’t solve the fact that we will have a significant number of buckets, however, each bucket entry will reserve the size of a pointer for the value instead of 128 bytes.

As have seen, adding `n`elements to a map and then deleting all the elements means keeping the same number of buckets in memory. So must remember that cuz a Go map can only grow in size, so does its memory consumption. Note that here is no automated straegy to shrink it. If this leads to high memory consumption, we can try different options such as forcing Go to re-create the map or using pointers to check.

### Comparing values incorrectly

As will see in this, shouldn’t always be the case, when is it appropraite to use == , and what are the alternatives -- To answer these -- start with a concrete example -- create a basic `customer`struct like:

```go
type customer struct {
    id string
}

func main(){
    cust1 := customer{"x"}
    cust2 := customer{"x"}
    println(cust1==cust2)
}
```

Note that comparing like this is a valid operation in go, will print `true`. But:

```go
type customer struct {
    id string
    operations []float64
}
```

This time, will not be compiled -- The problem relates how the `==`and `!=`operators work -- these operator don’t work with slices or maps, hence, cuz the customer struct contains a slice here, it doesn’t compile.

- *Channels* -- Compare whether two channels were created by the same `make`or both `nil`.
- *Interfaces* -- have identical dynamic types and euqal dynamic values or if both `nil`
- *structs and Arrays* -- whether are comosed of similar types

If stick with the stdlib, one option is to run-time relection with the `reflect`package -- *Reflection* is a form of metaprogramming, and it refers to the ability of an application to introspect and modify its structure and behavior. We can sue the `reflect.DeepEqual()`-- this func reports whether two elements are deeply equal by *recursively* traversing two values.

`fmt.Println(reflect.DeepEqual(cust1, cust2))`

In performance is crucial factor, another option might be to implement our own comparision method.

```go
func (a customer) equal (b customer) bool {
    if a.id != b.id {
        return false
    }
    if len(a.operations) != len(b.operaitons) {
        return false
    }
    for i:=0; i<len(a.operations); i++ {
        if a.operations[i]!=b.operations[i]{
            return false
        }
    }
    return true
}
```

## Providing access to std lib functions

Template functions can be also be used to provide access to the features provided by the stdlib.

```go
allTemplates := template.New("allTemplates")
allTemplates.Funcs(map[string]any{
    "getCats": GetCategories,
    "lower": strings.ToLower,
})
allTemplates, err := allTemplates.ParseGlob("templates/*.html")
```

The new mapping just pvoides access to the `ToLower`. like:

```html
{{range getCats . -}}
<h1>Category: {{lower .}}</h1>
{{end}}
```

#### Defining Template variables

Actions can define variables in their expresions, which can be accesed within embedded template content. This feature is useful when need to produce a value to assess in the expression and -- like:

```html
{{define "mainTemplate" -}}
    {{$length := len .}}
    <h1>There are {{$length}} products in the source data.</h1>
```

Template variables are prefixed with the `$`character and are created wtih the short variable declaration syntax. like:

```html
 {{range getCats . -}}
        {{if ne ($char := slice (lower .) 0 1) "s"}}
        <h1>{{$char}}: {{.}}</h1>
        {{- end}}
    {{end}}
```

#### Using Template variables in Range actions

Variables can also be used with the `range`action, which allows maps to be used in templates.

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
    {{range $key, $val := . -}}
        <h1>{{$key}}: {{printf "$%.2f" $val.Price}}</h1>
    {{end}}
{{- end}}
```

### Creating HTTP servers

Describe the stdlib support for creating HTTP servers and processing HTTP and HTTPs requests. how to create a server and explain the different ways in which requests can be handled.

Creating a simple HTTP server -- The `net/http`package makes it wasy to create a simple HTTP server, which can then be extended to add more complex and useful features -- like:

```go
type StringHandler struct {
	message string
}

func (sh StringHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	io.WriteString(writer, sh.message)
}

func main() {
	err := http.ListenAndServe(":5000", StringHandler{message: "hello world"})
	if err != nil {
		Printfln("Error: %v", err.Error())
	}
}
```

They are enough to create an HTTP server that responds to requst with `hello world`.

### Creating the HTTP listener and Handler

The `net/http`package provides a set of convenience functions that make it easy to create an HTTP server without needing to specify too many details -- like:

- `ListenAndServe(addr, handler)`-- starts listening for HTTP requests on a specified address and passes requests onto the specified handler.
- And the `TLS`, HTTPs requests.

The addresses accepts by the function can be used to restrict the HTTP server so that it only accepts requests on a specified interface or to listen for request on any interface. When a request arrives, it is passed onto a handler, which is responsible for producing a response. Handlers must implement the `Handler`interface, which defines:

- `ServeHTTP(writer, request)`-- This method is invoked to process a HTTP requst, the request is described by a `Request`value, and the response is written using a `ResponseWriter`, both of which are received as parameters.

### Inspecting the Request

HTTP requests are respresented by the `Request`struct -- `net/http`-- 

- `Method`-- GET POST...
- `URL`-- returns requested URL
- `Proto`-- `string`that indicates the version of HTTP used for the request.
- `Host`-- retrurns a string containing the request hos.
- `Header`-- alias to `map[string][]string`and contains the request headers
- `Trailer`-- `map[string]string`contains any additional headers 
- `Body`-- returns a `ReadCloser`-- combines the `Read()`of the `Reader`interface with the `Close`of the `Closer`.

### Fitering Requests and Generating Responses

The HTTP server respond to all requests in the same way -- to produce different responses, Need to inspect the URL to figure out what is being requested and use the functions provdied by the `net/http`package to send an appropriate response -- like: `Scheme, Host, RawQuery, Path, Fragment, Hostname(), Port(), Query(), Uer()`and `String()`., `Query()`returns a `map[string][]string`-- `String()`returns a `string`reprsentation of the URL.

And the `ResponseWriter`interface defines the methods that are available when creating a response. This includes a `Writer`-- and:

`Header()`-- returns a `Header`-- alias to `map[string][]string`-- 
`WriteHeader(code)`-- sets the status code for the response
`Write(data)`-- writes data to the response body and implements the `Writer`interface.

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	if request.URL.Path == "/favicon.ico" {
		Printfln("Request for icon detected - returning 404")
		writer.WriteHeader(http.StatusNotFound)
		return
	}
	Printfln("Request for %v", request.URL.Path)
	io.WriteString(writer, sh.message)
}
```

The request handler checks the `URL.Path`field to detect icon requests and responds by using the `WriteHeader`to set a response using the `StatusNotFound`.

### Using the Response Convenience Functions

The `net/http`package provides a set of convenience functions that can be used to create common responses to `HTTP`requests like:

- `Error(writer, message, code)`-- Sets the `Content-Type`header to `text/plain`-- writes the error messge to the response.
- `NotFound(writer, request)`-- 404 error code
- `Redirect(writer, request, url, code)`
- `ServeFile(writer, request, fileName)`

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	Printfln("Request for %v", request.URL.Path)
	switch request.URL.Path {
	case "/favicon.ico":
		http.NotFound(writer, request)
	case "/message":
		io.WriteString(writer, sh.message)
	default:
		http.Redirect(writer, request, "/message", http.StatusTemporaryRedirect)
	}
}
```

Uses a `switch`to declare how to respond to a request.