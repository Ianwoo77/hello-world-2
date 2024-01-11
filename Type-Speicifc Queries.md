# Type-Speicifc Queries

Mongodb has a wide variety of types that can be used in a document. some of these types have special behavior-- 

`null`-- behaves does match itself, so if have a collection with the following documents like:

```js
db.c.find() 
// can query for documents whose y key is null in the expected way like:
db.c.find({y:null}) 
// but, null also matches does not exist like:
db.c.find({z: null}) // return all
// so, need to check the key is null and exists using the $exists
db.c.find({z: {$eq: null, $exists: true}}) // nothing returned
```

## Regular Expressions

`$regex`provides regular expression capabilities for pattern matching strings in queries. Regular expressions are useful for flexible string matching. like:

```js
db.users.find({name: {$regex: /joe/}})
```

### Querying Arrays

Querying for elements of an array is designed to behave the way querying for scalars does like:

```js
db.food.find({fruit: 'banana'})
// $ALL -- match arrays by more than one element like:
db.food.find({fruit: {$all: ['apple', 'banana']}}) // : + array
```

For this, order does not matter, notice that the `banana`just comes before `apple`in the second result. Using :

```js
db.food.find({fruit: {$all: ['apple']}}) // --->
db.food.find({fruit: 'apple'})
```

Can also query by exact match using the entire array. However, exact match will not match a document if any elements are missing or superfluous. Fore, this will match the first of our 3 documents -- like:

```js
db.food.find({fruit: ['apple', 'banana', 'peach']})
// will NOT:
db.food.find({fruit: ['apple', 'banana']})
// neight will this:
db.food.find({fruit: ['banana', 'apple', 'peach']})
```

So, if want to query for a specific element of an array, just can specify an index using the syntax, `key.index`like:

```js
db.food.find({'fruit.2': 'peach'})
```

note that arrays are always 0-indexed, so this would match the 3rd array element against the string `peach`.

`$SIZE`-- A useful conditional for query arrays is `$size`, fore:

```js
db.food.find({fruit: {$size: 3}})
```

Every time you add an element to the array, increment like:

```js
db.food.update(criteria, {$push: {furit: strawberry}, $inc: {size :1}})
```

`$SLICE`-- The optional second argument to `find`specifies the keys to be returned, the special `$slice`operator can be used to return a subset of elements for an array key - like:

FORE, suppose we had a blog post document and wanted to return the first 10 comments like:

```js
db.blog.posts.findOne(criteria, {comments: {$slice: 10}}) // first 10
db.food.findOne({}, {fruit: {$slice: 3}})
db.food.findOne({}, {fruit: {$slice: -2}})
db.food.findOne({}, {fruit: {$slice: [1,2]}})
```

For the last one, skip the firt 1 and return 2 and 3.

### Returning a Matching array element

`$slice`is helpful when you know the index of the element, but sometimes you want whichever array element matched your criteria. Can return the matching element with the `$`operator. Given the previous blog example, could get Bob’s comment back with -- like:

```js
db.blog.posts.find({'comments.author': 'Alice'},
    {'comments.$': 1}).forEach(x=>console.log(x.comments))
```

Note that this only returns the first match for each dofument.

ARRAY and RANGE query Interactions -- Scalars in documents must match each clause of query’s criteria. If you queried for `{x: {$gt:10, $lt:20}}`

FORE -- if : `db.test.find({x: {$gt:10, $lt:20}})` will return the array matched -- but the document is returned .. And there are couple of ways to get the expected behavior like:

```js
db.test.find({x: {$elemMatch: {$gt:10, $lt: 20}}})
```

Note that if have an index over the field you are querying, can use `min`and `max`to limit the index range travsersed by the query to your `$gt`and `$lt`values.

### Querying Embedded

`db.people.find({name: {first: 'Joe', 'last': Schmoe}})` For this, the query for full dubdocument must extactly match the subdocument, if Joe decides to add a middle name ... So if possible, it’s usually a good idea to query for just a specific key or keys of an embedded document. Then if your schema changes, all of your queries won’t suddenly break cuz they are no longer exact matches. like:

```js
db.people.find({'name.first': 'Joe', 'name.last': 'Schmoe'})
```

The `dot`notation is the main difference between query documents and other document types. Embedded document matches have to match the whole document. To correctly group criteria wihtout needing to specify every key, need to use `$elemMatch`-- named conditional like:

```js
db.blog.find({comments: {$elemMatch:
            {author: 'joe', score: {$gt: 5}}}})
```

### Cursors

The dbs returns results from `find`using a `cursor`-- the client-side implementations of cursors generally allow you to control a great deal about the enventual output of a query, can limit the number of results, Skip over some number of results, sort results by any combination of keys in any direction, and perform a number of other powerful operations. To create a cursor with the shell, put some documents into a collection, do a query on them, and assign the results to a local variable. FORE:

```js
for(let i=0; i<100; i++) {
    db.collection.insertOne({x:i})
}
let cursor = db.collection.find();
```

The advantage of doing like this is that you can look at one result at a time. If store the results in a global variable or no variable at all the mongodb shell will automatically iterate through and display the first couple of documents. FORE, to iterate through the results, you can use the `next`method on the cursor, also can use the `hasNext()`to check whether there is another result -- a typical loop through result looks like the following like:

```js
while(cursor.hasNext())
    obj = cursor.next();
```

For this, the `cursor`class also implement the Js’ iterator interface can: for of?

```js
let cursor = db.people.find();
for(let x of Array.from(cursor))
    print(x.name)
```

When call `find`, the shell doesn’t query the dbs immediately, it waits until you start requesting results to send the query, which allows you to chain additional options onto a query before it is performed.

```js
db.food.find()
let cursor = db.food.find().limit(1).sort({fruit:1}).skip(1)
```

At this point, the query has not been executed yet -- all of these functions merely build the query. if call: `cursor.hasNext()`-- the query will be sent to the server.

## General Input/Output Recipes

Input and output are how a computer communicates with the external world. Typical input into a computer refers to the keystrokes from a keyboard or clicks from or movement of a mouse.

The `io`package is the base package for input and output in Go and contains interfaces for I/O and a few convenient functions the main and the most ocmmonly used interfaces are `Reader`and `Writer`.

### Reading from an Input

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

// like
bytes = make([]byte, 1024)
reader.Read(bytes)
```

From left to right, pass the slice to the `Read`method. *Actually reading data from reader into bytes.* Read will fill the slice of bytes only to its capacity, want to read everything from the reader, can use the `io.ReadAll`function like:

```go
bytes, err := io.ReadAll(reader)
```

For this, `ReadAll`reads fro the reader passed into the parameter and returns the data into `bytes`. Will often find functions that expect a reader as an input parameter. like:

```go
reader := strings.NewReader("...")
```

#### Writing to an Outupt

```go
type Writer interface{
    Write(p []byte) (n int, err error)
}
```

When call `Write`on an `io.Writer`, U are just writing the bytes to the **underlying data stream**.

```go
bytes := []byte("Hello World")
writer.Write(bytes)
```

A common pattern in Go is for a function to take in a writer as a parameter the function calls the `Write`function on the writer, and later you can extract the data from the writer like:

```go
func main() {
	buf := new(bytes.Buffer)
	fmt.Fprintf(buf, "Hello %s", "World")
	fmt.Println(buf.String())
}
```

For the `bytes.Buffer`is a struct is a `Writer`, so can easily create one and pass it to the `fmt.Fprintf`function. And the following is a handler function named myHandler like:

```go
func myHandler(w http.ResponseWriter, r *http.Request) {
    w.Write([]bytes("Hello World"))
}
```

### Copying from a reader to a Writer

Want to copy from a reader to a writer, use the `io.Copy()`to copy from a reader to writer. Sometimes U read from a reader cuz you want to write it to a writer. The process can take a few steps to read everything from a reader into a buffer and then write to the writer again. like:

```go
var url string := "http://...db"
func readWrite(){
    r, err := http.Get(url)
    if err != nil {
        log.Println("Cannot get from URL", err)
    }
    defer r.Body.Close()
    data, _ := io.ReadAll(r.Body)
    os.WriteFile("rw.data", data, 0755)
}
```

For this, if use the `http.Get`to download a file, get an `http.Response`struct, `r` -- the content of the file is in the `Body`variable of the `http.Response`struct, which is an `io.ReadCloser`-- is an interface that groups a `Reader`and a `Closer`so can treat it just like a reader. For this, it’s quite expensive operation to download a 1MB file. so:

```go
func copy(){
    r, err := http.Get(url)
    if err != nil {
        log.Println("Cannot get from URL", err)
    }
    defer r.Body.Close()
    file, _ := os.Create("copy.data")
    defer file.Close()
    writer := bufio.NewWriter(file)
    io.Copy(writer, r.Body)
    writer.Flush()
}
```

First, create a file for the data, here just using the `os.Create()`-- then create a buffered writer using the `bufio.NewWriter`-- wrapping around the file. This will be used in the `Copy`function.

### Reading from a Text file

Can use the `os.Open`function to just open the file, followed by `Read`on the file, alternatively, can use the simpler `os.ReadFile`to do it in a single step -- reading and writing to the filesystem are just basic things a programming language needs to do. Then can always store data in memory, 

```go
func main() {
	data, err := os.ReadFile("data.txt")
	if err != nil {
		log.Println("Cannot read file: ", err)
	}
	fmt.Println(string(data))
}
```

Opening a file and reading from it -- reading a file by opening it then doing a read on it is more flexible but takes a few more steps first, need to open the file like:

```go
func main() {
	file, err := os.Open("data.txt")
	if err != nil {
		log.Println("Cannot open a file", err)
	}

	// close the file when are done with it
	defer file.Close()

	stat, err := file.Stat()
	if err != nil {
		log.Println("Cannot read file stats", err)
	}

	// create the byte array to store the read data
	data := make([]byte, stat.Size())

	// finally, have the byte array, pass it a parameter
	// to `Read`n the file struct like:
	bytes, err := file.Read(data)
	if err != nil {
		log.Println("Cannot read file:", err)
	}
	fmt.Printf("Read %d from file\n", bytes)
	fmt.Println(string(data))
}
```

Although there are just a few more steps, but have the flexibility of reading parts of the whole document

### Writing to a Text File

Want to write to a text file -- can use the `os.Open`to open, followd by Write on the `file struct.` Alternatively, can use the `os.WriteFile`function to do that directly in one single function call like:

```go
func main() {
	data := []byte("Hello world!\n")
	err := os.WriteFile("data.txt", data, 0644)
	if err != nil {
		log.Println("Cannot write to file", err)
	}
}
```

Creating and writing -- Writing to a file by just creating the file and then writing to it is a bit more involved but it’s also more flexible, need to create or open a file using the `os.Create`function like:

```go
func main() {
	data := []byte("Hello world!\n")
	file, err := os.Create("data.txt")
	if err != nil {
		log.Println("Cannot create file:", err)
	}
	defer file.Close()

	// create a new file with the given name and mode 0666 if doesn't exist
	// then using the `Write`and pass the byte array like:
	bytes, err := file.Write(data)
	if err != nil {
		log.Println("Cannot write to file:", err)
	}
	fmt.Printf("Wrote %d to file\n", bytes)
}

```

This will just return the number of bytes that were written to the file.

### Using a Temporary File 

Want to create a temporay file for use -- use the `os.CreateTemp`function to create a temporary file, and then remove it once don’t need it anymore.

Just note that different OS stores their temporary files in different places. Regardless of where it is, go will let you know where it ussing the `os.TempDir`function like:

```go
func main() {
	fmt.Println(os.TempDir())
}
```

This is the directory that your pc tells Go to use as a temporary directory, can use this directory directly, or can just create a subdirectory here like: `os.MkDirTemp`like:

```go
func main() {
	tmpdir, err := os.MkdirTemp(os.TempDir(), "mydir_*")
	if err != nil {
		log.Println("Cannot create tmep dir", err)
	}

	// also a good practice to defer the cleaning up of the temporary directory
	defer os.RemoveAll(tmpdir)

	// then creating the actual temporary file using os.CreateTemp like:
	tmpFile, err := os.CreateTemp(tmpdir, "mytmp_*")
	if err != nil {
		log.Println("cannot crete file", err)
	}

	data := []byte("Some random stuff for the temp file")
	_, err = tmpFile.Write(data)
	if err != nil {
		log.Println("Cannot write to temp file", err)
	}

	err = tmpFile.Close()
	if err != nil {
		log.Println("Cannot close temp file", err)
	}

}
```

And, if didn’t choose to put temporary files into a separate dir, can also use the `os.Remove()`with the temp file:

`defer os.Remove(tmpfile.Name())`

## Processing Forms

In this -- The high-level workflow for processing form will follow a std `post-redirect-get`pattern and look like: The form data will be validated by our `createSnippet`handler, if there are any validation faitures the form will be re-displayed with the appropritae form fields.

```html
{{template "base" .}}
{{define "title"}}Create a new snippet {{end}}

{{define "main"}}
<from action="/snippet/create" method="post">
	<div>
        <label>Title:</label>
        <input type="text" name="title">
    </div>
    <div>
        <label>Content:</label>
        <textarea name="content"></textarea>
    </div>
    <div>
        <label>Delete in:</label>
        <input type="radio" name="expires" value="365" checked>One year
        <!-- ... -->
    </div>
    <div>
        <input type="submit" value="Publish snippet">
    </div>
</from>
```

Contains a std web form which send form values -- `title content expires`.

Need to update the `createSnippetForm`handler so that it renders our new page like:

```go
func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
    app.render(w, r, "create.page.html", nil)
}
```

### Parsing form data

1. First need to use the `r.ParseForm()`to parse the request body and this checks that the request body is well-formed, and then stores the form data in the reuest’s `r.PostForm`map.
2. Can then get to the form data contained in the `r.PostForm`by using the `r.PostForm.Get()`. fore, can retrieve the value of the `title`with the `r.PostForm.Get("title")`

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Response) {
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    title := r.PostForm.Get("title") // from input's name attribute
    //...
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        app.serverError(w, err)
        return
    }
    http.Redirect(w, r, fmt.Sprintf("/snippet/id", id), http.StatusSeeOther)
}
```

#### `r.Form`

In above, accessed the form value via the form values -- `r.PostForm`, can also use `r.Form`map. Note that the `r.PostForm`is populated only for `POST PATCH PUT`. And the `r.Form`is populated for all requests and contains the form data from any request body and query string parameters.

Especially, `r.Form`is populated for all requests and contains the form data from any request body **and** any query string parameters -- like: `/snippet/create?foo=bar`, could also get the value of the `foo`parameter by calling `r.Form.Get("foo")`. Note that in the event a conflict. The request body value will take precedent over the query string -- note that.

And the `net/http`also provides the methods -- `r.FormValue()`and `r.PostFormValue()`-- essentially shortcut that call `r.ParseForm()`then fetch from `r.Form`or `r.PostForm`repectively.

#### multiple-value Fields

`r.PostForm.Get()`used above only returns the *first* value for a specific form field. Note, if use checkbox like:

```html
<input type="checkbox" name="items" value="foo">Foo
<input type="checkbox" name="items" value="bar">Bar
```

In this case will need to work with the `r.PostForm`-- the underlying type of `r.PostForm`is `url.Values`-- underlying type is just `map[string][]string`-- so:

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprintf(w, "%d: item %s\n", i, item)
}
```

### Data validation

```go
errors := make(map[string]string)
// check that the title...
if strings.TrimSpace(title) == "" {
    errors["title"]="this field cannot be blank"
}else if utf8.RuneCountInString(title)>100 {
    errors["title"]= "this is too large"
}

//...
// if there are any errors, dump in a plain text HTTP response and return
if len(errors)>0 {
    fmt.Fprint(w, errors)
    return
}
id err := app.snippets.Insert(...)
```

Displaying validation errors and populating Fields -- For now, the `creteSnippet`handler is validating the data the next stage is to manage these valiation errors gracefully. To do this, use struct like:

```go
type templateData struct {
    //...
    FormData url.Values // type is just the r.PostForm's type
    FormErrors map[string]string
    //...
}

// Then in the createSnippet func like:
if len(errors)>0 {
    app.render(w, r, "create.page.html", &templateData {
        FormErrors: errors,
        FormData: r.PostForm,
    })
    return
}
//...
```

```html
<div>
    <label>Content:</label>
    {{with .FormErrors.title}}
    <label class="error">{{.}}</label>
    {{end}}
    <input type="text" name="title" vlaue="{{.FormData.Get "title"}}"
</div>
```

```html
<div>
    <label>Delete in:</label>
    {{with .FormErrors.expires}}
    <label class="error">{{.}}</label>
    {{end}}
    {{$exp := or (.FormData.Get "expires") "365"}}
</div>
```

This is essentially create a new `$exp`template variable which uses the `or`template function to set the variable which uses to the value yield by `.FormData.Get "expires"`or if that’s empty using 365 instead.

Then:

```html
<input type="radio" name="exipres" value="356" {{if (eq $exp "356")}}checked{{end}}>One year
```

