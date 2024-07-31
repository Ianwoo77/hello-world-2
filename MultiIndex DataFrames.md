# MultiIndex DataFrames

Each address is graded on 4 characteristics of livability, The four grades in two parent categories.

```python
pd.read_csv('neighborhoods.csv')
```

When importing a CSV, pandas assumes that the file’s first row holds the column names, also known as the headers. If a header slot does not have a value, pandas assigns a title of `Unnamed`to the column. And that is not the end of the problems -- In row 0, each of the first 3 columns holds a `NaN`vluae -- And in Row 1, have `NaN`values present in the last 4 columns. The issue is that the CSV is trying to model a multilevel row index and a multilevel column index.

So, first have to tell pands that the 3 leftmost columns should serve as the index of the `DataFrame`. Can do this by passing the `index_col`parameter a list of numbers. Each one representing the index of a column that should be in the `DataFrame`index. 

Also note that the index starts counting from 0, thus, the first three will have index postions 0 1 2.

```python
pd.read_csv('neighborhoods.csv', index_col=[0,1,2])
```

Then also need to tell pandas which data set rows we’d like to use for our DataFrame’s headers. Assumes that only the first row should, so can:

```python
pd.read_csv('neighborhoods.csv', index_col=[0,1,2], header=[0,1])
```

Noticed that pandas prints each column’s name as a two-element tuple, fore `(Culture, Restaurants)`.

```python
neighborhood.index
neighobrhood.columns
```

Under its hood, pandas compose a `MultiIndex`from multiple `Index`objects.

```python
neighborhoods.index.names
```

Note that pandas assigns an order to each nested level within the `MultiIndex`-- For this, `State`has position 0... So, there is the `get_level_values`method extracts the `Index`object at a given level of the `MultiIndex`.

```python
neighborhood.index.get_level_values(1)
neighborhood.index.get_level_values('State')
```

And the column’s `MultiIndex`levels do not have any names cuz the CSV did not provide. For fixing the problem, can access the column’s `MultiIndex`with the `columns`attribute -- can assign a new list of column names to the `names`attribute of the `MultiIndex`object.

```python
neighborhood.columns.names=['Category', 'Subcategory']
neighborhood.columns.names # FrozenList
```

Now that assigned names to the levels, can also sue the `get_level_values()`method to retreive any `Index`from the column’s `MultiIndex`. just like:

```python
neighborhood.columns.get_level_values(0)
neighborhood.columns.get_level_values('Subcategory')
```

And, a `MultiIndex`will carray over to new objects derived from a data set. The index can switch axes depending on the operation. Fore `DataFrame nunique`-- returns a `Series`with a count of unique values per column.
`neighborhood.nunique()`-- call thsi cause the `MultiIndex`swaps axes and serve as the row’s `MultiIndex`in the resulting `Series`. How many unique values pandas found in each of the four *columns*.

### Sorting a MultiIndex

Can find a value in an ordered collection much quciker than in jumbled one. When call the `sort_index`on a `MultiIndex`DF, pandas sorts all levels in ascending order and proceeds from the outside in. like:

```python
neighborhood.sort_index() # also ascending parameter
```

If want to vary the sort order for different levels, can pass the `ascending`a list of Booleans. Each boolean sets the sort order for the next `MultiIndex`level.

```python
neighborhood.sort_index(ascending=[True, False, True])
```

Can also sort a `MultiIndex`level by itself, just send the `level`parameter like:

```python
neighborhood.sort_index(level=1)
neighborhood.sort_index(level='Street')
```

Note that the `level`can also accepts a list of levels. like:

```python
neighborhood.sort_index(level=[1,2])
```

So, also combine the `ascending`and `level`parameter.

Then can sort the columns’ `MultiIndex`as weel by supplying an `axis`parameter to the `sort_index`method.

```python
neighborhood.sort_index(axis=1).head(3)
neighborhood.sort_index(axis='columns')
```

Then can combine the level and ascending parameters with the axis parameter to further customize the columns’ `sort_index`orders.

```python
neighborhood.sort_index(
    axis=1, level='Subcategory', ascending=False
)
```

## Control Structs

Delves into the most common mistakes related to control structures, with a strong focus on the `range`loop -- which is a common source of misunderstanding.

### the fact that elements are copied in range loops

A `range`is a convenient way to iterate over varioud data strucures,  Go developers may forget or be unware of how a `range`loop loop assigns values -- leading to common mistakes. Note that also *Receiving channel* used. Fore:

```go
s := []string {"a", "b", "c"}
for i, v := range s {
    fmt.Printf("index=%d, value=%s\n", i, v)
}
```

Loops over each element of the slice, in each iteration, as itereate over a slice, `range`produces a pair of values: an Index and an element values, assigned to `i`and `v`, respectively. In general, `range`produces two values for each.

#### value copy

Understanding how the value is handled during each iteration is critical for using a `range`loop effectively.

```go
type account struct {
    balance float32
}
// create a slice of count structs and iterate over each element
accounts := []accout {
    {balance: 100.},
    //...
}
for _, a := range counts {
    a.balance+=100
}
```

The answer is still {100}, -- in Go, everything we assign is a copy -- 

- If assign the result of a func returning a `struct`, perfoming a copy of a struct
- If assign the result of a func returning a pointer, perform a copy of the address.

```go
for i := range accounts {
    accounts[i].balance += 100
}

// or using pointers like:
accounts := []*account {
    //...
}
for _, a := range accounts {
    a.balance += 100
}
```

In general, should just rembmer that the value element in a range loop is a copy.

### Arguments evaluating

The `range`requires an expression. If:

```go
s := []int {0, 1, 2}
for range s {
    s= append(s, 10)
}
```

Note that when using a `range`loop, the provided expression is evaluated only once, beforing beginning of the loop. In this context, evaluated means that provided expression is copied to a temporary variable and then `range` iterate over this variable. For this, when `s`expression is evaluted, the result is a slice copy. So the `range`loop uses this temporary variable, the original is **also** updated during each iteration. Indeed -- the temporary slice used by `range`remains a 3-lengh slice -- so the loop completes after 3 loops -- so, the original changed. note that the behavior is different with a classic `for`-- 

```go
s := []int {0, 1, 2}
for i:=0; i<len(s); i++ {
    s = append(s, 10)  // never ends
}// len(s) is evaluted during each iteration
```

Should know that the behavior we described also applies to all data types provided. fore, channels, and arrays

#### Channels

Fore, create two goroutines, both sending elements to two distinct channels, then in the parent goroutine, implement a consumer on one channel using a `range`. In the parent, implement a consumer on one channel using a `range`loop.

```go
ch1 := make(chan int, 3)
go func(){
    ch1<-0
    ch1<-1
    ch1<-2
    close(ch1)
}()
ch2 := make(chan int, 3)
//... like ch1

ch := ch1
for v := range ch {
    fmt.Println(v)
    ch = ch2
}
```

The expression provided to `range`is a ch channel pointing to `ch1`-- `range`evaluates `ch`, performs a copy to temporary variable, and iterates over elements from this channel, despite the `ch=ch2`statement. The `ch=ch2`statement isn’t without effect -- though -- cuz assigned `ch`to the second variable,  if call `close(ch)`, will close the `ch2`.

#### Array

Cuz the `range`expression is evaluated before the beginnign of the loop, what is assigned to the temporary loop variable is a copy of the array. like:

```go
a := [3]int{0,1,2}
for i, v := range a {
    a[2]=10
    if i==2 {
        println(v)
    }
}
```

This code updates the last index to 10, however, if run this code, it does not print 10, prints 2. As mentioned, the `range`operator creates a copy of the array. Meanwhile, the loop doesn’t update the copy, it updates the original array. So if want to print the actual value of the last element, can do so in two ways -- 

```go
for i:= range a {
    a[2]=10
    if i ==2 {
        fmt.Println(a[2])
    }
}
// or using an array pointer
for i, v := range &a {
    a[2]=10
}
```

### The impact of using pointer elements in `range`loops

When using `range`loop with pointer elements -- It can lead us to an issue where we reference the wrong elements. in terms of semantics, storing data using pointers semantics implies sharing the element.

```go
type Store struct {
    m map[string]*Foo
}
func (s Store) Put(id string, foo *Foo) {
    s.m[id]=foo
}
```

Here, using the pointer semantics implies that the `Foo`element is shared. Sometimes already manipulate pointers, can be handy to store pointers directly in collection instead of values. And, if store large structs, and these structs are frequently mutated, we can use pointers instead to avoid a copy and an insertion for each mutation.

```go
func updateMapValue(mapValue map[string]LargeStruct, id string) {
    value := mapValue[id]
    value.foo = "bar"
    mapValue[id]=value // insert
}

func udpateMapPointer(mapPointer map[string]*LargeStruct, id string) {
    mapPointer[id].foo = "bar" // muteate directly
}
```

There some common mistakes with pointer elements in `range`loops -- 

- A `Customer`representing a customer
- A `Store`holds a map of `Customer`pointers.

```go
type Customer struct {
    ID string
    Balance float64
}
type Store struct {
    m map[string]*Customer
}
```

The following method iterates over a slice of `Customer`elements and stores them in `m`-- 

```go
func (s *Store) storeCustomers(customers []Customer) {
    for _, customer := range customers {
        s.m[customer.ID]= &customer
    }
}
```

For this, iterate over the input slice using the `range`and store pointers in the map. If:

```go
s.storeCustomers([]Customer {
    {ID:"1", Balance:10},
    {ID:"2", Balance: -10}
})
```

Note that both is `ID:2, Balance: -10`

Note -- iterate over the `customers`slice using a `range`loop, regardless of the number of elements, created a single `customer`variable with a fixed address, can verify this by printing the pointer address during each iteration.

```go
func (s *Store) StoreCustomer(customers []Customer) {
    for _, customer := range customers {
        fmt.Printf("%p\n", &customer)
        //... so all same address
    }
}
```

Always store a pointer to a `customer`struct -- at the end of the iteariton, store the **same** pointer in the map three times. Two main solutions -- 

```go
func (s *Store) storeCustomers(customers []Customer) {
    for _, customer := range customers {
        current := customer // new var inside loop
        s.m[current.ID]=&current
    }
}

// to store a pointer referencing
func (s *Store) storeCustomers(customers []Customer){
    for i:= range customers {
        customer:= &customers[i]
        //...
    }
}
```

So, when iterating over a data structure using a `range`loop, must recall that all the values are assigned to a unique variable with a single *unique* address. Therefore, if store a pointer referencing this variable during each iteration, will end up in a situation where store the same pointer referencing the same element.

## Using the Convenience Routing Handler

The process of inspecting the URL and selecting a response can produce complex code that is difficult to read and maintain. To simplify the process, the `net/http`package provides a `Handler`implementation that allows matching the URL to be separated form producing a request.

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	Printfln("Request for %v", request.URL.Path)
	io.WriteString(writer, sh.message)
}

func main() {
	http.Handle("/message", StringHandler{"Hello world"})
	http.Handle("/facicon.ico", http.NotFoundHandler())
	http.Handle("/", http.RedirectHandler("/message", http.StatusTemporaryRedirect))
	err := http.ListenAndServe(":5000", nil)
	if err != nil {
		println(err.Error())
	}
}

```

The key feature is using a `nil`for the argument to the `ListenAndServe`. This enables the default handler.

- `Handle(pattern, handler)`-- creates a route that invokes the specified `ServeHTTP`method of the specified `handler`.
- `HandleFunc(pattern, handlerFunc)`-- creates a rule that invokes the specified function for request that match the pattern. The function is invoked with `ResponseWriter`and `Request`args.

And there are also:

- `FileServer(root)`-- creates a `Handler`that produces responses using the `ServeFile`function
- `NotFoundHandler()`-- creates a `Handler`using `NotFound()`function
- `RedirectHandler(url, code)`-- using the `Redirect`func
- `StripPrefix(prefix, handler)`-- removes the specified prefix fromt the request URL and passes on the request to the specified `Handler`.

### Supporting HTTPs Requests

The `net/http`package provides integrated support for HTTPs -- To prepqre for this, need to add two files to the `httpserver`-- a certificate file and private key file. A good way to get started wtih HTTPs with a *self-signed* certificate, which can e used for development and testing. Two files are requried to use HTTPs, regardless of whether your certiiate is self-signed or not.

The `ListenAndServeTLS()`is used to enable HTTPs, where the additional arguments specify the certificate and private key files, which are named *.cer, and *.key files.

```go
go func() {
    err := http.ListenAndServeTLS(":5500", "ian.cer",
                                  "ian.pkey", nil)
    if err != nil {
        Printfln("HTTPS error: %v\n", err.Error())
    }
}()
```

The `ListenAndServeTLS()`and `ListenAndServe()`functions blocks -- so have used a goroutine to support both HTTP and HTTPs request.

#### Redircting HTTP requests to HTTPs

A common requirement when creating web servers to redirect HTTP rquests to HTTPs port. This can be done by creating a custom handler like:

```go
func HTTPSRedirect(writer http.ResponseWriter, request *http.Request) {
	host := strings.Split(request.Host, ":")[0]
	target := "https://" + host + ":5500" + request.URL.Path
	if len(request.URL.RawQuery) > 0 {
		target += "?" + request.URL.RawQuery
	}
	http.Redirect(writer, request, target, http.StatusTemporaryRedirect)
}
```

`err := http.ListenAndServe(":5000", http.HandlerFunc(HTTPSRedirect))`

#### Creating a static HTTP server

The `net/http`package includes built-in support for responding to requests with the content of files. To prepare for the static HTTP server, create `static`folder add `index.html`like:

```html
<div class="m-1 p-2 bg-primary text-white h2">
    Hello world
</div>
```

```html
<body>
<div class="m-1 p-2 bg-primary text-white h2 text-center">
    Products
</div>

<table class="table table-sm table-bordered table-striped">
    <thead>
    <tr><th>Name</th><th>Category</th><th>Price</th></tr>
    </thead>
    <tbody>
    <tr><td>Kayak</td><trd>Watersports</trd><td>$279.00</td></tr>
    <tr><td>Lifejacket</td><td>Watersports</td><td>$49.95</td></tr>
    </tbody>
</table>
</body>
```

The HTML files depend on the bootsrap CSS package to style the HTML content.

#### Creating the static file route -- 

Now that there are HTML and CSS files to work with it, it is time to define the route that will make them available.

```go
fsHandler := http.FileServer(http.Dir("./static"))
http.Handle("/files/", http.StripPrefix("/files", fsHandler))
```

So the `FileServer`function creates a handler that will serve files, and the directory is specified using the `Dir`function. Then going to serve the content in the `static`folder with the URL paths that start wtih the `files`so that a request for `/files/store.html`-- will be handled using the `static/store.html`file. Then have to specified the route like:

`http.Handle("/files/", http.StripPrefix("/fies", fsHandler))`

The support for serving files has some useful features -- first, the *Content-Type* header of the resposne is set *automatically* based on the file extension. Second, requests that don’t sepecify file are handled using `index.html`which you can see by requesting `https://localhost:5500/fiels`-- which produces the response.

### Using Templates to generate responses

There are no built-in support for using templates as responses for HTTP requests, but it is just a simple process to set up a handler that uses features provided by the `html/template`package -- like:

```html
<body>
<h3 class="bg-primary text-white text-center p-2 m-2">Products</h3>
<div class="p-2">
    <table class="table table-sm table-striped table-bordered">
        <thead>
        <tr>
            <th>Index</th>
            <th>Name</th>
            <th>Category</th>
            <th class="text-end">Price</th>
        </tr>
        </thead>

        <tbody>
        {{range $index, $product := .Data}}
        <tr>
            <td>{{$index}}</td>
            <td>{{$product.Name}}</td>
            <td>{{$product.Category}}</td>
            <td class="text-end">
                {{printf "$%.2f" $product.Price}}
            </td>
        </tr>
        </tbody>
    </table>
</div>
</body>
```

Then add a file named `dynamic.go`to the folder.

```go
type Context struct {
	Request *http.Request
	Data    []Product
}

var htmlTemplates *template.Template

func HandleTemplateRequest(writer http.ResponseWriter, request *http.Request) {
	path := request.URL.Path
	if path == "" {
		path = "products.html"
	}
	t := htmlTemplates.Lookup(path)
	if t == nil {
		http.NotFound(writer, request)
	} else {
		err := t.Execute(writer, Context{request, Products})
		if err != nil {
			http.Error(writer, err.Error(), http.StatusInternalServerError)
		}
	}
}

func init() {
	var err error
	htmlTemplates = template.New("all")
	htmlTemplates.Funcs(map[string]any{
		"intVal": strconv.Atoi,
	})
	htmlTemplates, err = htmlTemplates.ParseFiles("templates/products.html")
	if err == nil {
		http.Handle("/templates/", http.StripPrefix("/templates/",
			http.HandlerFunc(HandleTemplateRequest)))
	} else {
		panic(err)
	}
}
```

The initialization function loads all the templates with the html extension in the `templates`folder and sets up a route so that the requests that start with `/templates/`are proessed by the `HandleTemplateRequest`function -- This func looks up the template, falling back to the `products.html`if no file path is found.