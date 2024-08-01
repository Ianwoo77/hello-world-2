# Selecting with a MultiIndex

Extracting `DataFrame`rows and columns get tricky when multiple levels are involved. If pass a single vlaue in square brackets, pandas will look for it in the outermostt level of the column’s `MultiIndex`, the following example searches for `Services` -- 

```python
neighborhood['Services']
```

Notice that the new `DataFrame`does not have a `Category`level. It has a plain `Index`with two values. And pandas will raise a `KeyError`exception if the value does not exist in the outermost level of `MultiIndex`. `neighborhood['Schools']`-- KeyError raised. So, what if want to target a specific `Category`and then a `Subcategory`within it -- To specify values acorss multiple levels in the column’s justlike:

```python
neighborhood[('Services', 'Schools')] # pass a tuple
```

This method return a `Series`without a column index. We explicitly told pandas what values to target in the Category. So to extract multiple DF columns, need to pass the square brackets a *list of tuples*.

```python
neighborhood.loc[..., [('Services', 'Schools'), ('Culture', 'Museums')]] # with no loc
neighborhood[[(...), (...)]]
```

#### Extracting with one or more with `loc`

MultiIndex has 3 levels, `State, City, Address`-- If know the values to target in each level, can pass them in a tuple within the square brackets.

```python
neighborhood.loc[("TX", "Kingchester", "534 Gordon Falls")]
```

Can pass a single label in the `[]`, pandas will look for it in the outermost `MultiIndex`level.

```python
neighborhood.loc['CA', 'Culture']
```

The syntaxi is more straightforward and more consistent, allows `loc`'s second argument to always represent the column’s `index`labels to target.

```python
neighborhood.loc[('CA', 'Dustinmouth'), ('Services',)]
neighborhood=neighborhood.sort_index()
neighborhood['NE':'NH']
```

Note that can also combine list-slicing syntax with tuple argument -- like:

`neighborhood.loc[('NE', 'Sh'): ('NH', 'No')]`

### Cross-sections -- 

The `xs`method allows us to extract rows by providing a value for one `MultiIndex`level, pas the method `key`parameter wtih the value to look for -- pass the `level`either the numeric position or the name of the index level in which to look for the value. `neighborhood.xs(key='Lake Nicole', level=1)`

Can also apply the same extraction techniques to columns by passing the `axis`parameter an argument of `columns`.

```python
neighborhood.xs(axis=1, key='Museums', level='Subcategory')
```

Just notice that the `Subcategory`level is not present in the returned `DataFrame`.

```python
neighborhood.xs(key=('AK', '238 Andrew Rue'), level=['State', 'Street'])
```

### Manipulating the Index

```python
# resetting the index
# the reorder_levels() arranges the multi-index levels in a specifid order 
# order parameter a list
new_order=['City', 'State', 'Street']
neighborhood.reorder_levels(order=new_order)
# can also use number like:
neighborhood.reorder_level(order=[1,0,2])
```

And what if we want to get rid of the index -- the `reste_index()`method returns a new `DataFrame`that integrates the former `MultiIndex`level as columns. Pandas just repleces the former `MultiIndex`with its std numeric one.

`neighborhoods.reset_index().tail()`

Noticed that the three new columns become values in `Category`, just the outermost level of the columns’ `MultiIndex`. Can add the 3 columns to an alternate `MultiIndex`column level -- pass the desired level’s index position or name to the `reset_index()`like:

```python
neighborhood.reset_index(col_level=1).tail() # or col_level='Subcategory'
```

Now pandas will default to an empty string for `Category`, can replace the empty string with a value of our choice by passing an argument to the `col_fill`parameter.

```python
neighborhood.reset_index(col_fill='Address', col_level='Subcategory')
# can also move a single level by passing to the `levels`parameter
neighborhood.reset_index(level='Street') # or pass ['Street', 'City']
# removing from MultiIndex, `drop`parameter
neighborhood.reset_index(level='Street', drop=True)
```

#### Setting the index

`set_index()`sets one or more `DataFrame`columns as the new index. Can:

```python
neighborhood.set_index(key='City') # or pass list
```

## During Map Iterations

Iterating over a map is a common source of misunderstanding and mistakes -- mostly cuz developers make wrong assumption -- `Ordering`and Map update during iteration.

#### Ordering 

A few fundamental behaviors of the map-- 

- It doesn’t keep the data sorted by key
- It doesn’t preserve the order in which the data was added.

Furthermore, when iterating over a map, shouldn’t make any ordering assumptions at all.

#### Map insert during iteration

In Go, updating a map during an iteration is **allowed**. It doesn’t lead to a compilation error or a run-time error. there is another aspect we should consider when adding an entry in a map during an iteration. Fore:

```go
m := map[int]bool {
    0: true,
    1: false,
    2: true,
}

for k, v := range m{
    if v{
        m[10+k]=true
    }
}

```

If a map entry is created during iteration, it *may be* produced during the iteration or skipped. As Go developers, we don’t have any way to enforce the behavior. It also may vary from one iteration to another. It’s essential to keep this behavior in mind to ensure that our code doesn’t produce unpredictable outputs. fore:

```go
m := map[int]bool {
    //...
}
m2 := copyMap(m)
for k, v := range m{
    m2[k]=v
    if v {
        m2[10+k]=true
    }
}
```

**Shoudn’t** rely on the following -- 

- The data being ordered by keys
- Preservation of the insertion order
- A deterministic iteration order
- An element being produced during the same iteration.

### How break statement works

A `break`is commonly used to terminate the execution of a `loop`. And when loops are used in conjunction with `switch`or `select`, developers frequently make this mistake of breking the wrong statement. Fore:

```go
for i:=0; i<5; i++ {
    fmt.Printf("%d", i)
    switch i {
    default:
    case 2:
        break // break the swtich just
    }
}
```

One essential rule to keep in mind is that a `break`statement termniates the execution of the innermost `for switch select`statement. One essential rule to keep in mind is that a .. Can write:

```go
loop:
for i:=0; i<5; i++ {
   	//...
    switch i {
        //...
    case 2:
        break loop
    }
}
```

Also, breaking the wrong statement occur with a `select`insdie a loop -- like:

```go
for {
    select {
    case <-ch:
        // do sth
    case <-ctx.Done():
        break // break the select 
    }
} // so
loop:
for {
    select {
        //...
    case <-ctx.Done():
        break loop
    }
}
```

So, should remain cautions while using a `switch`or `select`statement inside a loop.

###  `defer`inside a loop

The `defer`delays a call’s execution until the surrounding function returns -- it’s mainly used to reduce boilerplate code. fore, if a resource has to be closed eventually, can use `defer`to avoid repeating the colsoure calls before every single `return`. However, one common mistake is to be unaware of the consequences of using `defer`inside a loop.

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        file, err := os.Open(path)
        if err != nil {
            return err
        }
        defer file.Close()
        // do sth else with file
    }
    return nil
}
```

There is a significant problem with this imp. Have to recall that `defer`schedules a func call when the *surrounding* func returns. So in this cse, the `defer`calls are executed not during each lop iteration but when the `readFiles`func returns. So if `readFiles`doesn’t return, the file descriptors will be kept open forever, causing leaks. Have to create another surrounding function around `defer`that is called during each iteration.

```go
func readFiles(ch <-ch string) error {
    for path := range ch {
        if err := readFile(path) ; err != nil {
            return err
        }
    }
    return nil
}

func readFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return nil
    }
    defer file.Close
    //...
    return nil
}
```

Another approach could be make the `readFile`a closure 

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        err := func() error {
            //...
            defer file.Close()
        }()
        if err != nil {
            return err
        }
    }
    return nil
}
```

### Strings -- 

String is an immutable data structure holding the followings -- 

- A pointer to an immutable byte sequence
- The total number of bytes in this sequence

### Understanding the concept of a `rune`

Need to make sure are aligned about some fundamental programming concepts -- Should understand the distinction between a `charset`and `encoding`.

- Chaset -- is a set of characters
- An encoding is the translation of a character’s list in binary

In Go, a `rune`is an alias of `int32`-- `type rune = int32`, note that using `len`on a string in Go returns the number of bytes, not the numbers of runes.

### String iteration

```go
func concat(values []string) string {
    sb := strings.Builder{}
    for _, value := range values {
        _, _, = sb.WriteString(value)
    }
    return sb.String() 
}
```

Since Go strings are UTF-8 encoded, each character might consist of more than one byte, so to accurately count characters -- should use the `utf8.RuneCountInString()`function.

### string Conversions

The most I/O operations actually done with `[]byte`-- fore, `io.Reader..`-- hence, working with strings means extra conversions -- shouldn’t do like:

```go
func getBytes(reader io.Reader) ([]byte, error) {
    b, err := io.ReadAll(reader)
    if err != nil {
        return nil, err
    }
    // b is a []byte
}
```

Note that the `byte`package also has a `TrimSpace`func to trim all the heading and trailing white space.

### Substrings and memory leaks

To extract a subset of a string, can use the following syntax like:

```go
s1 := "hello world"
s2 := s1[:5]
```

-- Note that shouldn’t use this syntax in the case of runes encoded with multiple bytes. should convert the input string into a `[]rune`type first like:

```go
s1 := "Hello world"
s2 := string([]rune(s1)[:5])
```

Now that we hav refreshed our minds regarding the substring operation, look at a concreate problem -- 

```go
func (s store) handleLog(log string) error {
    if len(log) < 36 {
        return errors.New("...")
    }
    uuid := log[:36]
    s.store(uuid)
}
```

When doing the substring operation, the Go specification doesn’t specify whether the resulting string and the one involved in the substring operation should share the same data. The std Go compiler *does let them share the same backing array*, which is probably the best solution memory.

`log[:36]`will create a new string referencing the same backing array. Therefore, each `uuid`string that we store in memory will contain not just 36 bytes but the number of bytes in the initial `log`string. Can fix this -- by making a *deep copy* of substring so that the internl byte slice of `uuid`references a new backing array -- like:

```go
func (s store) handleLog(log string) error {
    if len(log) < 36 {
        return errors.New("...")
    }
    uuid := string([]byte(log[:36]))
    s.store(uuid)
}
```

So the copy is perforemd by converting the substring into `[]byte`first, and then into a `string`again. By doing so, prevent a memory leak from occurring.

As of Go 1.18, the stdlib also includes a solution with `strings.Clone`that returns a fresh copy of a string.
`uuid := string.Clone(log[:36])`

Calling the `strings.Clone`makes a copy of `log[:36`]`into a new allocation.

## Responding with JSON data

JSON responses are widely used in web services, which provide access to an application’s data for clients that don’t want to receive HTML, 

```go
func HandleJsonRequest(writer http.ResponseWriter, request *http.Request) {
	writer.Header().Set("Content-Type", "application/json")
	json.NewEncoder(writer).Encode(Products)
}

func init() {
	http.HandleFunc("/json", HandleJsonRequest)
}

```

The initialization function creates a route, which means that requests for `/json`will be processed by the `HandleJsonRequest`function. `writer.Header().Set("Content-Type", "application/json")`

### Handling Form data

The `net/http`package provides support for easily receiving and processing form data -- like:

```html
<body>
{{$index := intVal(index(index .Request.URL.Query "index") 0)}}
{{if lt $index (len .Data)}}
    {{with index .Data $index}}
        <h3 class="bg-primary text-white text-center p-2 m-2">Product</h3>
        <form method="post" action="/forms/edit" class="m-2">
            <div class="mb-3">
                <label>Index</label>
                <input name="index" value="{{$index}}"
                       class="form-control" disabled/>
            </div>

            <div class="mb-3">
                <label>Name</label>
                <input name="name" value="{{.Name}}" class="form-control"/>
            </div>

            <div class="mb-3">
                <label>Category</label>
                <input name="category" value="{{.Category}}"
                       class="form-control"/>
            </div>

            <div class="mb-3">
                <label>Price</label>
                <input name="price" value="{{.Price}}" class="form-control"/>
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

This template makes use of template variables, expressions, and functions to get the query string from the requst. And It allows to generate HTML form that presents `input`elements for the fields -- 

`<form method="POST" action="/forms/edit" class="m-2" />`

#### Reading Form data from Requests

Now that have added a `form`to the proj, write the code that receives the data it contains. The `Request`struct just defines the fields and methods -- like:

- `Form`-- returns a `map[string][]string`containing the parsed form data and the query string parameters. Note that the `ParseForm`method must be called before this is read
- `PostForm`-- only data form from the request body is contained in the map.
- `MultipartForm`-- returns a multipart form represented using the `Form`struct defined in the `mime/multipart`package, and the `ParseMultipartForm`must be called before read.
- `FormValue(key)`-- returns the first value for the specified form key and returns the empty string
- `PostFormValue(key)`-- returns the first value for the specified form key and returns the empty string.
- `FormFile(key)`-- provides access to the first file with the specified key in the form.
- `ParseForm()`-- parses a form and populates the `Form`and `PostForm`fields
- `ParseMultipartForm(max)`-- parse a MIME multipart form.

```go
func ProcessFormData(writer http.ResponseWriter, request *http.Request) {
	if request.Method == http.MethodPost {
		index, _ := strconv.Atoi(request.PostFormValue("index"))
		p := Product{}
		p.Name = request.PostFormValue("name")
		p.Category = request.PostFormValue("category")
		p.Price, _ = strconv.ParseFloat(request.PostFormValue("price"), 64)
		Products[index] = p
	}
	http.Redirect(writer, request, "/templates", http.StatusTemporaryRedirect)
}

func init() {
	http.HandleFunc("/forms/edit", ProcessFormData)
}
```

The `init`sets up a new route so that the `ProcessFormData`function handles request whose path `forms/path`within the `ProcessFormData`function. Within the `ProcessFormData()`-- the request method is checked, and the form data in the request is used to create a `Product`struct and replace the existing one.

#### Reading multipart forms -- 

Forms encoded as `multipart/form-data`to allow binary data, such as files, to be safely sent to the server. To be safely sent to the server. 

Regular forms -- `application/x-www-form-urlencoded`-- Sends data to the server in k-v pair format.

Multipart forms -- are used when need to upload files along side other form data. The `enctype`attribute of the `form`tag must be set to `multipart/form-data`.

Key differences -- 

- Usage -- Regulars are used for simple text data submission, while multi are used for file upload
- Encoding -- Regualr are URL encoding, whereas multiple uses `multipart/form-data`
- Content strucure -- regular serialize the data into a single string, multipart separate each part with boundaries.