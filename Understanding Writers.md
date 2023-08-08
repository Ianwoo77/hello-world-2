## Understanding Writers

The `Writer`interface just defines the methods like:

`Write(bytslice)`-- this writes the data from the specified `byte`slice. The method returns the number of bytes that were written and an `error`. The `error`will be non-`nil`if the number of bytes written is less than the length of the slice. And the `Writer`interface doesn’t include any details of how the written data is stored.

```go
func processData(reader io.Reader, writer io.Writer) {
    b := make([]byte, 2)
    for{
        count, err := reader.Read(b);
        if count>0 {
            writer.Write(b[:count])
            Printfln(...)
        }
        if err == io.EOF {
            break
        }
    }
}

func main() {
    r := strings.NewReader("kayak")
    var builder strings.Builder
    processData(r, &builder)
    Printfln(builder.String())
}
```

Hence, the `strings.Builder`struct implements the `io.Writer`interface, so can write bytes to a `Builder`and then calls its `String()`method to create a string from those bytes. And Writers will return an `error`if they are just unable to write all the dat in the slice.

Also noticed used the address operator to pass a pointer to the `Builder`to the `processData`function, just like:

`processData(r, &builder)`

As a general rule, the `Reader`and Writer methods are implemented for pointers so that passing a `Reader`or `Writer`to a funciton doesn’t create a copy.

Didn’t have to use the address operator for the `Reader`.

### Using the utility Functions for Readers and Writers

The `io`package contains a set of functions that provide additional ways to read and write data, like:

- `Copy(w,r)`-- this function copies data from a `Reader`to `Writer`until EOF is returned or another error is encountered -- the results are the number of bytes copies, and error used to describe any problems.
- `CopyBuffer(w, r, buffer)`-- This function performs the same task as `Copy`but reds the data into the specified buffer before it is passed.
- `CopyN(w, r, count)`-- copies `count`bytes
- `ReadAll(r)`-- reads data from the specified number of bytes form the reader until the EOF reached. The results are `byte`slice containing the read data and an `error`, which is used to descirbe any problems.
- `ReadAtLeast(r, byteSlice, min)`-- This function reads at least the specified number of bytes from the reader, placing them into the `byte`slice. An errors is reported if fewer bytes than specified are read.
- `ReadFull(r, byteSlice)`-- This function fills the specified `byte`slice with data. The results is the number of `bytes`read and an `error`. An error will be reported if EOF was encountered before enough bytes to fill the slice were read.
- `WriteString(w, str)`-- this function writes the specified `string`to writer.

```go
func processData(reader io.Reader, writer io.Writer) {
	count, err := io.Copy(writer, reader)
	if err == nil {
		Printfln("Read %v bytes", count)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

## Using the Specialized Readers and Writers

In addition to the basic `Reader`and `writer`interfaces, the `io`package provides some specialized implementation taht are described and demonstrated in the sections that follow -- 

- `Pipie()`-- this returns a `Pipereader`
- `MultiReader()`-- defines a variadic parameter that allows arbitrary number of `Reader`values to be specified. The result is a `Reader`that passes on the content from each of its parameters in the sequence they are defined, as described.

### Buffering Data

The `bufio`package provides support for adding buffers to readers and writers -- To see how data is processed without a buffer, add a file named `custom.go`to the read folder like:

```go
type CustomReader struct {
	reader    io.Reader
	readCount int
}

func NewCustomReader(reader io.Reader) *CustomReader {
	return &CustomReader{reader, 0}
}

func (cr *CustomReader) Read(slice []byte) (count int, err error) {
	count, err = cr.reader.Read(slice)
	cr.readCount++
	Printfln("Custom Reader: %v bytes", count)
	if err == io.EOF {
		Printfln("Total reads: %v", cr.readCount)
	}
	return
}
```

Just defined a custom struct type named `CustomReader`that acts as a wrapper around a `Reader`. The implementaiton of the `Read()`method generates output that reports how much data is read and how many read operations are performed overall just like:

```go
func main() {
	text := "It was a boat. A small boat."

	var reader io.Reader = NewCustomReader(strings.NewReader(text))
	var writer strings.Builder
	slice := make([]byte, 5)

	for {
		count, err := reader.Read(slice)
		if count > 0 {
			writer.Write(slice[:count])
		}
		if err != nil {
			break
		}
	}
	Printfln("Read data : %v", writer.String())
}
```

So the `NewCustomerReader`function is uesd to create a `CustomeReader`that reads from a string and uses a `for`loop to consume the data using a `byte`slice.

Just note that the final read returned zero bytes but received the `EOF`error, just indicate that the end of the data has been reached.

Reading small amounts of data can also be problematic when there is a large amount of overhead associated with each operation -- this isn’t an issue when reading a string store in memory -- but reading data form other data sources, such as files -- can be xpensive. so: The `bufio`package create buffered readers -- like:

- `NewReader(r)`-- the function returns a buffered `Reader`with the default buffer size
- `NewReaderSize(r, size)`-- this returns a buffered `Reader`with the specified buffer size.

```go
var reader io.Reader = NewCustomReader(strings.NewReader(text))
reader = bufio.NewReader(reader)
```

Used the `NewReader`- which creates a `Reader`with the default buffer size, the buffered `Reader`fills its buffer and uses the data it contains to respond to calls to the `Read()`.

And the default buffer size is just 4096 bytes, which means that the buffered reader was able to read all the data in a single real operation.

### Using the Additional Buffered Reader Methods

The `NewReader()`and `NewReaderSize()`return `bufio.Reader`values -- which implement the `io.Reader`interface and which can be used as drop-in wrappers for other types of `Reader`methods. The `bufio.Reader`struct defines additional methods to make direct use of the buffer -- 

- `Buffered()`-- returns an `int`that indicates the number of bytes that can be read from the buffer.
- `Discard()`-- Discards the specified number of bytes
- `Peek(count)`-- returns the specified number of bytes without removing them from the buffer
- `Reset(reader)`-- this discards the data in the buffer and performs subsequent reads from the specifeid `Reader`.
- `Size()`-- returns the size of the buffer.

```go
func main() {
	text := "It was a boat. A small boat."

	var reader io.Reader = strings.NewReader(text)
	var writer strings.Builder
	slice := make([]byte, 5)

	buffered := bufio.NewReader(reader)
	for {
		count, err := buffered.Read(slice)
		if count > 0 {
			Printfln("Buffer size : %v, buffered : %v",
				buffered.Size(), buffered.Buffered())
			writer.Write(slice[:count])
		}
		if err != nil {
			break
		}
	}
	Printfln("Read data : %v", writer.String())
}
```

### Performing Buffered Writes

The `bufio`package also provides support for creating writers that use a buffer, using the functions described:

- `NewWriter(w)`-- returns a buffered `Writer`with the default buffer size
- `NewWriterSize(w, size)`-- returns a buffered `Writer`with the specified size.

The methods defined by the `bufio.Writer`struct -- 

- `Available()`-- returns the number of available bytes in the buffer.
- `Buffered()`-- this returns the number of bytes that have been written to the buffer
- `Flush()`-- this writes the contents of the buffer to the underlying `Write`.
- `Reset(writer)`-- discards the data in the buffer and performs subsequent writes to the specified writer.
- `Size()`-- cap.

```go
type CustomWriter struct {
	writer     io.Writer
	writeCount int
}

func NewCustomWriter(writer io.Writer) *CustomWriter {
	return &CustomWriter{writer, 0}
}

func (cw *CustomWriter) Write(slice []byte) (count int, err error) {
	count, err = cw.writer.Write(slice)
	cw.writeCount++
	Printfln("Custom writer: %v bytes", count)
	return
}

func (cw *CustomWriter) Close() (err error) {
	if closer, ok := cw.writer.(io.Closer); ok {
		closer.Close()
	}
	Printfln("Total Writes: %v", cw.writeCount)
	return
}

```

```go
func main() {
	text := "It was a boat. A small boat."

	var builder strings.Builder
	var writer = NewCustomWriter(&builder)
	for i := 0; true; {
		end := i + 5
		if end >= len(text) {
			writer.Write([]byte(text[i:]))
			break
		}
		writer.Write([]byte(text[i:end]))
		i = end
	}
	Printfln("Written data : %v", builder.String())
}
```

`var writer = bufio.NewWriterSize(NewCustomWriter(&builder), 20);`

The transition to a buffered `Writer`isn’t entirely seamless cuz it is important to call the `Flush`method to ensure that all the data is written out. The buffer I selected is 20 bytes, which is much smaller than the default buffer.

Formatting and Scanning with `Readers`and `Writers`-- 

Formatting and scanning features provided by the `fmt`package and demonstrated their use with strings -- The `fmt`package provides support for applying these features to `Readers`and `Wrtiers`.

### Scanning vlaues from a Reader

The `fmt`provides functions for scanning values from a `Reader`and converting them into different types.

```go
func scanFromReader(reader io.Reader, template string,
	vals ...interface{}) (int, error) {
	return fmt.Fscanf(reader, template, vals...)
}

func main() {
	reader := strings.NewReader("Kayak Watersports $279.00")
	var name, category string
	var price float64
	scanTemplate := "%s %s $%f"

	_, err := scanFromReader(reader, scanTemplate, &name, &category, &price)

	if err != nil {
		Printfln("Error: %v", err.Error())
	} else {
		Printfln("Name: %v", name)
		Printfln("Category: %v", category)
		Printfln("Price: %.2f", price)
	}
}
```

The scanning process reads byte from the `Reader`and uses the scanning template to parse the data that is received. The scanning template contains two strings and `float64`

```go
func scanSingle(reader io.Reader, val interface{}) (int, error) {
	return fmt.Fscan(reader, val)
}
```

The `for`loop calls the `scanSingle()`,which uses the `Fscan`function to read a `string`from the `Reader`. Values are read until `EOF`is returned.

### Writing Formatted strings to Writer

the `fmt`package also provides functions for writing formatted strings to a `Writer`-- like:

```go
func writeFormatted(writer io.Writer, template string, vals ...interface{}) {
	fmt.Fprintf(writer, template, vals...)
}

func main() {
	var writer strings.Builder
	template := "Name: %s, Category: %s, Price: $%.2f"
	writeFormatted(&writer, template, "Kayak", "Watersports", float64(279))
	fmt.Println(writer.String())
}

```

### Using a Replacer with a Writer

The `strings.Replacer`struct cna be used to perform replacements on a `string`and output the modified result to a `Writer`, like:

```go
func writeReplaced(writer io.Writer, str string, subs ...string) {
	replacer := strings.NewReplacer(subs...)
	replacer.WriteString(writer, str)
}

func main() {
	text := "It was a boat. A Small boat."
	subs := []string {"boat", "kayak", "Small", "huge"}
	var writer strings.Builder
	writeReplaced(&writer,text, subs...)
	fmt.Println(writer.String())
}
```

### Templat Composition

As add more pages to this web application there will be some shared, boilerplate, HTML markup that want to just include on every page -- like a header, navigation and metadata inside the `<head>`HTML element. To save typing and prevent duplication, good idea to create a *layout* -- tempalte which contains this shared content.

```html
{{define "base"}}
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>{{template "title" .}} - Snippetbox</title>
    </head>
    <body>
    <header>
        <h1><a href="/">Snippetbox</a></h1>
    </header>
    <nav>
        <a href="/">Home</a>
    </nav>
    <main>
        {{template "main" .}}
    </main>
    </body>
    </html>
{{end}}
```

Using the `{{define “base”}}`... `{{end}}`action to define a distinct named template called `base`-- which contains the content we want to appear on every page. Inside this use the `{{template "title" .}}` and `{{template "main" .}}`actions to denote that we want to invoke other named templates at a particular point in the html.

```html
{{template "base" .}}

{{define "title"}}Home {{end}}

{{define "main"}}
    <h2>Latest Snippets</h2>
    <p>There is nothing to see here yet!</p>
{{end}}
```

`{{template "base" .}}` -- this informs Go that when the `home.page.html`is executed, that we want to invoke the named template `base`. In turn, the `base`instructions to invoke the `title`and `main`named templates, know this might fill a bit circular. In the main.go

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	// initialize a slice containing paths to the two files
	// home.page.html file must be **first** file in the slice
	files := []string {
		"./ui/html/home.page.html",
		"./ui/html/base.layout.html",
	}
	
	// use the template.ParseFiles() to read the files and store
	// template in a template set.
	ts, err := template.ParseFiles(files...)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal server error!", 500)
		return
	}
	
	err = ts.Execute(w, nil)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "internal Server Error", http.StatusInternalServerError)
	}
}
```

So now, instead of containing HTML directly, our template set contain 3 named tempaltes and an instruction to invoke the `base`template.

### Embedding Partials

For some apps you might want to break out certain bits of HTML into partials that can be reused in different pages or layouts.

```html
{{define "footer"}}
    <footer>Powered by <a href="https://golang.org">Go</a></footer>
{{end}}
```

Then just updat the base.layout.html -- `{{tempalte "footer" .}}`

Finally, need to update the  `home`handler to include the new file when parsing the template file like

### Additional info

The block action -- In the code above used the `{{template}}`action to invoke one template from another. But Go also provides a `{{block}}...{{end}}`action which you can use instead -- This acts like the `{{template}}`action except it allows you to specify some default content -- if the template being invoked doesn’t exist in the current template set. FORE, in the context of a web app, this is useful when want to provide some default content which individual pages can override on a case-by-case basis if they need to.

```html
{{define "base"}}
<h1>
    tempalte
</h1>
{{block "sidebar"}}
<p>
    my default side bar content
</p>
{{end}}
```

If don’t need to include default content between the `{{block}}`and `{{end}}`actions, For this. The content of your `ui/static`directory should now look like this -- 

### The `http.FileServer`handler

Go’s `net/http`package ships with a built-in `http.FileServer`handler which can use to serve files over HTTP from a specific directory -- add a new route to our app so that all requests which begin with `/static/`are handled using this. To careate a new `http.FileServer`handler, need to use the `http.FileServer()`function like this:

`fileServer := http.FileServer(http.Dir("./ui/static/"))`

When this handler receives a request, it will remove the leading slash from the URL path and then search the `./ui/static `directory for the corresponding file to send to the user. For this work, strip the leading `/static`from the URL path before passing to the `http.FileServer`. Otherwise it will be looking for a file which doesn’t exist and the user will receive response. Just like:

```go
// Create a file server which serves files of the "./ui/static" directory
// note that the path given the http.Dir functions is relative to the project
// directory root
fileServer := http.FileServer(http.Dir("./ui/static/"))

// then use the mux.Handle() to register the server
mux.Handle("/static/", http.StripPrefix("/static", fileServer))
```

## Enumerating Numeric Typs

A `Vector`class implementing the operations just described.. `__repr__`, `__abs__`, `__add__` and `__mul__`

```python
class Vector:
    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

    def __repr__(self):
        return f'Vector({self.x!r}, {self.y!r})'

    def __abs__(self):
        return math.hypot(self.x, self.y)

    def __bool__(self):
        return bool(abs(self))

    def __add__(self, other):
        x = self.x+other.x
        y = self.y+other.y
        return Vector(x, y)

    def __mul__(self, scalar):
        return Vector(self.x*scalar, self.y*scalar)
```

We implemented 5 special methods in addition to the familar `__init__`. Note that none of them is directly called within the class or in the typical usage of the class illustrated by the doctests. As mentioned before, the Python interpreter is the only frequent caller of most special methods.

### String Representation

The `__repr__`special method is called by the `repr`built-in get the string representation of the object for inspection. Without a custom `__repr__`, Python’s console would display a `Vector`instance. The string returned by `__repr__`should be unambiguous and, if possible, match the source code necessary to re-create the represented object. That is why our `Vector`representation looks like calling the ctor of the class.

In contrast, `__str__`is called by `str()`built-in and implicitly used by the `print`function. It should return a string suitable for display to end users.

Sometimes same string returned by `__repr__`is user-friendly, and U don’t need to code `__str__`cuz the implementation inherited from the `object`class calls `__repr__`as a fallback.

### Boolean Value of a Cutom Type

Although Python has a `bool`type, it accepts any object in a `Boolean`context, such as the expression controlling an `if`or `while`statement, or as operands to and, `or`, and `not`. To determine whether a value x is `truthy`, or `falsy`, Python applies `bool(x)`, which return either `True`or `False`.

```python
def __bool__(self):
    return bool(self.x or self.y)
```

### Collection API

Documents the interfaces of the essential collection types in the language. All the classes in the diagram are ABCs -- abs base classes. ABCs and the `collections.abc`module are covered. The goal of this brief section is to give a panormic view of Python’s most important collection interfaces. 

Each of the top ABCs has a single special method -- the Collection ABC unifies the 3 essential interfaces that every collection should implement -- 

- `Iterable`support for unpacking, and other forms of iteration.
- `Sized`to support the `len`bult-in function
- `Container`to support `in`oprator.

And, Py doesn’t rquire concrete classes to acutally inherit from any of these ABCs, any class that implements `__len__`satisfies the `Sized`interface 3 very important specializtions -- 

- `Sequence`-- formazliing the interface of built-ins like `list`and `str`.
- `Mapping`-- implemented by `dict, collections.defaultdict`
- `Set`-- the interface of the `set`and `forzenset`built-in tpys.

Emulating collections -- `__len__`, `__getitem__`, `__setitem__`, `__delitem__`, `__contains__`.

## An  Array of Sequences

```python
from collections import abc
issubclass(tuple, abc.Sequence)
issubclass(list, abc.MutableSequence)
```

Just keep in mind these common traits -- mutable vs immutable, container vs flat. They are just helpful to extrapolate what you know about one sequence type to others.

### List Comp and Generator Expressions 

Listcomps do everything the `map`and `filter`functions do, without the contortions of the functionally challenged Py `lambda`like:

```python
symbols = '$¢£¥€¤'
beyond_ascii= [ord(s) for s in symbols if ord(s)>127]
beyond_ascii = list(filter(lambda c: c>127, map(ord, symbols)))
beyond_ascii
```

```python
colors = ['black', 'white']
sizes = ['S', 'M', 'L']
tshirts=[(color,size) for color in colors for size in sizes]
tshirts
```

## Working with Razor Views

Razor views contain just HTML elements and C# expressions, Expressions are mixed in with the HTML elements and denoted with the `@`character. When the view is used to generate a response, the expressions are evaluated, and the results are included in the content sent to the client. This expression gets the name of the `Product`view model object provided by the action method and produces output.

By default, Razor views are compiled directly int a **DLL**. and the generated C# classes are not written to the disk during the build process, can see the generated classes, by adding the following setting to the `WebApp.csproj`.

### Setting the view model type

The generated class for the `.cshtml`file is derived from the `RazorPage<T>`-- but Razor doesn't know what type will be used by the action method for the view model -- so it has selected `dynamic`as the generic type argument.

### Razor Syntax

The Razor compiler separates the static fragments of HTML from the C# expressions which are then handled separately in the generated class file. Directies are expressions that give instruction to the Razor view engine -- `@model`is just a directive, fore, that tells the view engine to use a specific type for the view model. like:

`@model, @using, @page, @section, @addTagHelper, @namespace, @functions, @attribute, @implements`
`@inherits @inject`.

## Using the View bag

Action methods provdie views with data to display with a veiw model, but sometimes additional info is required. Action methods can use the *view bag* to provide a view with extra data, as shown like:

```cs
public async Task<IActionResult> Index(long id =1)
{
    ViewBag.AveragePrice =
        await context.Products.AverageAsync(p => p.Price);
    return View(await context.Products.FindAsync(id));
}

public IActionResult List()
{
    return View(context.Products);
}
```

So the `ViewBag`property is inherited from the `Controller`base class and returns a `dynamic`object. This allows action methods to create new properties just by assigning values to them -- The values assigned to the `ViewBag`prop by the action method are available to the view through a property also called `ViewBag`.

```html
<td>
    @Model?.Price.ToString("c")
    (@(((Model?.Price/ViewBag.AveragePrice)*100).ToString("F2"))% of average price)
</td>
```

### Using temp data

The temp data feature allows a controller to preserve data from one request to another,which is useful when performing redirections -- Temp data is stored using a cookie unless session state is enabled when it is stored as sessin data. Unlike session data, temp data values are *marked for deletion* when they are read and removed when the request has been processed.

```cs
public class CubeController : Controller
{
    public IActionResult Index()
    {
        return View("Cube");
    }

    public IActionResult Cube(double num)
    {
        TempData["value"] = num.ToString();
        TempData["result"] = Math.Pow(num, 3).ToString();
        return RedirectToAction("Index");
    }
}
```

For this -- Also a `Cube`action -- which relies on the model binding process to obtain a value for its `num`parameter from the request -- the `Cube`action method performs its calculation and stores `num`value and the calculation result just using the `TempData`property, and returns a **dictionary** that is used to store k-v paris.

```html
<h6 class="bg-secondary text-white text-center m-2 p-2">Cubed</h6>
<form method="get" asp-action="Cube" class="m-2">
    <div class="mb-3">
        <label>Value</label>
        <input name="num" class="form-control"
               value="@(TempData["value"])" />
    </div>
    <button class="btn btn-primary mt-1" type="submit">
        Submit
    </button>
</form>

@if (TempData["result"] != null)
{
    <div class="bg-info text-white m-2 p-2">
        The cube of @TempData["value"] is @TempData["result"]
    </div>
}
```

So, the base class used for Razor views provides access to the temp data through a `TempData`property, allowing values to be read within expressions -- in this case, temp data is used to set the content of an `input`element and display a results summary. To see the effect, use a browser to navigate to . And the object returned by the `TempData`property provides a `Peek`method, which allows you to get a data value without makeing it for deletion. And a `Keep`, used to prevent a previously read from being deleted. Note that it doesn't portect a value forever.

And, Controllers can define properties that are decorated with the `TempData`attribute -- which is an alternative to use the `TempData`property like this -- 

```cs
public IActionResult Cube(double num) {
    Value = num.ToString();
    Result = Math.Pow(num, 3).ToString();
    return RedirectToAcition(..);
}
[TempData] public string? Value {get;set;}
[TempData] public string? Result {get;set;}
```

### Working with Layouts

The Razor view engine supports the concept of *sections*-- allow you to provide regions of content within a layout.

```html
@model Product?
@{...}
@section Header {
	Prodcut info
}
<tr><th></th></tr>...
@section Footer {
...
}
<!-- the index.cshtml file -->
```

Sections are defined using the Razor `@section`expression followed by a name for a section. In the `_Layout.cshtml`:

```html
<h6 class="...">
    @RenderSection("Header")
</h6>"
```

### partial Views

Are applied using a feature called *tag helpers* -- are configured in the view imports file, which was added. To enable fature required for partial views -- just like:

```html
@model Product
<tr>
	<td>@Model.Name</td>
    <td>@Model.Price</td>
</tr>
```

Applying a Partial view -- are applied by adding `partial`element in another view or layout just like:

```cs
@foreach(Product p in Model) {
    <partial name="_RowPartial" model="p" />
}
```

## Understanding Content-encoding

Razor views provide two useful features for encoding content - the HTML content-encoding feature ensures that expression responses don't change the structure of the response sent to the browser, which is an important security feature. The JSON encoding feature encodes an object as JSON and inserts it into the response, which can be useful debugging feature and can also be useful when providing data to Js applications.

### Understanding HTML encoding

The Razor view engine just encodes expression results to make them safe to include in an HTML document without changging its structure.

```cs
public IActionResult Html(){
    return View((Object)"This is a <h3><i>string</i></h3>");
}
```

This pass a string that contains HTML elements -- to create the view for the new action method, add a razor view file named `html.cshtml`to the `Views/home` like:

```html
@model string
<!-- ... -->
<body>
    <div class="...">
        @Model
    </div>
</body>
```

The view model string have been escaped so:

```html
<div class="...">
    @Html.Raw(Model)
</div>
```

So, do not disable safe encoding unless you are entirely confident that no malicious content will be passed to the view.

### Understanding JSON encoding

The `Json`prop -- added to the class from the view -- can be used to encode an object as JSON -- the most common use for JSON data is in RESTful web services -- like:

```html
@model Product?
<div class="...">
    @Json.Serialize(Model)
</div>
```

## Modifying and Deleting Data

The `SportsStore`application can store `Product`objects in the dbs and perform queries to read them back again. Most also require the ability to make changes to the data after it has been stored.

1. Core apps can serve browser-based clients, or can provide APIs for mobile and other clients
2. The Framework code handles the raw requests, and calls into Rps and web API controller Handlers.
3. Write these handlers using primitive provided by the framework. Typically invoke methods in your domain logic.
4. Domain can use external services and databases to perform its function and to persist data.

what types of apps can build -- 

- Minimal APIs -- Simple HTTP APIs can be consumed by mobile apps or browser-based single-page applications.
- Web APIs
- gRPC APIs -- used to build efficient binary APIs for server -- to just for server-to-server communication using gRPC
- Razor pages -- build to Razor pages MVC
- Blazor.

### How does ASP.NET core process a request

When build a web application with ASP.NET core, browsers will still be using the same HTTP protocol as before to communicate with your app -- ASP.NET core itself encompasses everything that takes palce on the server to handle a request, including verifying that the request 

Every Core application has a built-in web server Kestrel -- that is just responsible for receiving raw requests and constructing an internal representation of the data, an `HttpContext`object, which the rest of the app can use. Ur applicaiton can use details stored in `HttpContext`to generate an appropriate response to the request, which may be to generate some HTML, or, access denied.

## Brief overview of an ASP.NET core application

1. An http requrest is made to the server for the home page.
2. Request is forwarded by IIS/Nginx/Apache to your core app
3. The Core web server receives the HTTP request and passes it to the middleware
4. Middleware processes the request and passes it to the endpoint
5. Endpoint generates a response, fore, HTML
6. Response passes through middleware back to the web server
7. The response text is sent to the browser.

`HttpContext`object -- constructed by the Core web server is used by the application as a sort of storage box for a single request. Anything that's specific to this particular request and the subsequent response can be associated with it and stored in it -- such as properteis of request, request-specific services, data that's been loaded, or errors that have occurred. The web server fills the initial `HttpContext`with details of the original HTTP requests and other configuraiton details and then passes it to the rest of the application.

Kestrel isn't the only HTTP server available in core -- most performant and is cross-platform. Is responsible for receiving the request data and constructing a C# representation of the request.

### Program.cs file -- defining app

All Core apps start life as a .NET console app -- Before C# 9, .NET program had to include a `static void Main`, typically declared in a class called Program. With top-level statements you can write the body of this method directly in the file, and the compiler generates the `Main`method for you -- when combined with C# 10 features such as implicit `using`statements -- dramatically simplifies the entry-point code.

In .NET 7 all the default templates use top-level statements like: In this simple app -- `WebApplicationBuilder`configures a lot of things by default, including -- 

- *Configuration* -- your app loads values from JSON files and environment variables that you can use to control the app's runtime behavior, such as loading connection strings for a dbs.
- *Logging* -- Includes an extensible logging system for observability and debugging
- *Services* -- Any classes depends on for providing functionality.
- *Hosting* -- uses the Kestrel web server by default to handle requests.

## SportsStore: Modifying and Deleting Data

To provide consistent access to the new data to the rest -- added a file called IOrderRepository to the `Models`like: Then creating Controllers and Views like:

```cs
public class OrdersController : Controller
{
    private IRepository productRepository;
    private IOrderRepository orderRepository;

    public OrdersController(IRepository prodRepo, IOrderRepository orderRepo)
    {
        productRepository = prodRepo;
        orderRepository = orderRepo;
    }

    public IActionResult Index() => View(orderRepository.Orders);

    public IActionResult EditOrder(long id)
    {
        var products = productRepository.Products;
        Order order = id == 0 ? new Order { CustomerName = default! } : orderRepository.GetOrder(id);
        IDictionary<long, OrderLine> linesMap =
            order.Lines?.ToDictionary(l => l.ProductId)
            ?? new Dictionary<long, OrderLine>();
        ViewBag.Lines = products.Select(p => linesMap.ContainsKey(p.Id)
                                        ? linesMap[p.Id]
                                        : new OrderLine { Product = p, ProductId = p.Id, Quantity = 0 });

        return View(order);
    }

    [HttpPost]
    public IActionResult AddOrUpdateOrder(Order order)
    {
        // ... todo
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    public IActionResult DeleteOrder(Order order)
    {
        orderRepository.DeleteOrder(order);
        return RedirectToAction(nameof(Index));
    }
}
```

So the `LINQ`statement in the `EditOrder`action method may look convoluted, but the prepare the `OrderLine`data so that there is one object for every `Product`, even if there has been no previous selection for that product. For a new Order, this means that the `ViewBag.Lines`prop will be populated with a sequence of `OrderLine`objects -- corresponding to each `Product`in the dbs -- with `Id`and `Quantity`prop set to zero.

When the object is stored in the dbs, the zero `Id`value will indicate this is a new object, and the dbs server will assign a new unique PK.

For existing orders, the `ViewBag.Lines`prop will be populated with the `OrderLine`objects read from the dbs, filled out with extra objects with zero `Id`prop for the remaining products.

This structure takes advantage of the way that Core MVC and EF core fit together and simplifies the prodcess of updating the dbs. just like:

```html
@model IEnumerable<Order>

<h3 class="p-2 bg-primary text-white text-center">Orders</h3>

<div class="container-fluid mt-3">
    <div class="row">
        <div class="col-1 fw-bold">Id</div>
        <div class="col fw-bold">Name</div>
        <div class="col fw-bold">Zip</div>
        <div class="col fw-bold">Total</div>
        <div class="col fw-bold">Profit</div>
        <div class="col-1 fw-bold">Status</div>
        <div class="col-3"></div>
    </div>
    
    <div>
        <div class="row placeholder p-2"><div class="col-12 text-center">
            <h5>No Orders</h5>
        </div></div>
        
        @foreach (Order o in Model)
        {
            <div class="row p-2">
                <div class="col-1">@o.Id</div>
                <div class="col">@o.CustomerName</div>
                <div class="col">@o.ZipCode</div>
                <div class="col">@o.Lines?.Sum(l=>l.Quantity
                                                  *(l.Product?.RetailPrice- l.Product?.PurchasePrice))</div>
                <div class="col-1">@(o.Shipped ? "Shipped":"pending")</div>
                <div class="col-3 text-end">
                    <form asp-action="DeleteOrder" method="post">
                        <input type="hidden" name="Id" value="@o.Id" />
                        <a asp-action="EditOrder" asp-route-id="@o.Id"
                           class="btn btn-outline-primary">Edit</a>
                        <button type="submit" class="btn btn-outline-danger">
                            Delete
                        </button>
                    </form>
                </div>
            </div>
        }
    </div>
</div>
<div class="text-center">
    <a asp-action="EditOrder" class="btn btn-primary">Create</a>
</div>
```

This viw just present a summary of the `Order`objects in the dbs and displays both the total price of the products ordered and the amount of profit that will be made. There are buttong to create a new order and to edit an delete an existing one.

And to provide the view for creating or editing an order, added a file called `EditOrder.cshtml`to the `Views/Orders`:

```html
@model Order

<h3 class="p-2 bg-primary text-white text-center">Create/Update Order</h3>

<form asp-action="AddOrUpdateOrder" method="post">
    <div class="mb-3">
        <label asp-for="Id"></label>
        <input asp-for="Id" class="form-control" readonly/>
    </div>

    <div class="mb-3">
        <label asp-for="CustomerName"></label>
        <input asp-for="CustomerName" class="form-control"/>
    </div>

    <div class="mb-3">
        <label asp-for="Address"></label>
        <input asp-for="Address" class="form-control"/>
    </div>

    <div class="mb-3">
        <label asp-for="State"></label>
        <input asp-for="State" class="form-control"/>
    </div>

    <div class="mb-3">
        <label asp-for="State"></label>
        <input asp-for="State" class="form-control"/>
    </div>

    <div class="mb-3">
        <label asp-for="ZipCode"></label>
        <input asp-for="ZipCode" class="form-control"/>
    </div>

    <div class="form-check">
        <label class="form-check-label">
            <input type="checkbox" asp-for="Shipped" class="form-check-input"/>
            Shipped
        </label>
    </div>

    <h6 class="mt-1 p-2 bg-primary text-white text-center">Products Ordered</h6>
    <div class="container-fluid">
        <div class="row">
            <div class="col fw-bold">Product</div>
            <div class="col fw-bold">Category</div>
            <div class="col fw-bold">Quantity</div>
        </div>
        @{ int counter = 0; }

        @foreach (OrderLine line in ViewBag.Lines)
        {
            <input type="hidden" name="lines[@counter].Id" value="@line.Id"/>
            <input type="hidden" name="lines[@counter].ProductId"
                   value="@line.ProductId"/>
            <input type="hidden" name="lines[@counter].OrderId" value="@Model.Id"/>
            <div class="row mt-1">
                <div class="col">@line.Product.Name</div>
                <div class="col">@line.Product?.Category?.Name</div>
                <div class="col">
                    <input type="number" name="lines[@counter].Quantity"
                           value="@line.Quantity"/>
                </div>
            </div>
            counter++;
        }
    </div>

    <div class="text-center m-2">
        <button type="submit" class="btn btn-primary">Save</button>
        <a asp-action="Index" class="btn btn-secondary">Cancel</a>
    </div>
</form>
```

This view provides the user with a form containing `input`for the props defined by the `Order`class. To make that work: NO data is stored when  -- left the `AddOrUpdateOrder`method incomplete and just add like:

```cs
[HttpPost]
public IActionResult AddOrUpdateOrder(Order order)
{
    order.Lines = order.Lines?
        .Where(l => l.Id > 0 || (l.Id == 0 && l.Quantity > 0)).ToArray();
    if(order.Id==0)
    {
        orderRepository.AddOrder(order);
    }
    else
    {
        orderRepository.UpdateOrder(order);
    }
    return RedirectToAction(nameof(Index));
}
```

The code statement used in the action method rely on a useful EF core feature -- when Pass an `Order`object to `AddOrder`or `UpdateOrder`method, the EF core will store not only the Order but also related `OrderLine`. This may not seem important, but it simplifies a process that would otherwise rquire a series of carefully coordinated updates. And the features for creating and working with related data can be awkward, and in the following, describe common problem.

## Converting a Numeric Value to a Formatted String

Want to create a string representation of a number. Js is a loosely typed language -- will automatically convert any value to a string when it needs to -- fore, if compare a number to a string or join a number to a string -- one of the easiest tricks that js developers use to convert number to strings to simply concatenate an empty string:

`someNumber + ''`

Modern practice just favors *explicit* variable conversions -- Every js object has a built-in `toString()`. Often, need to customize the string representaiton of your number -- `Number.toFixed()`..

### Inserting Special Characters

The simplest approach with many special characters is simple -- Case-Insersitive string comparsion -- just use of the `String.toLowerCase()`method on both strings like:

```js
if (a.toLowerCase()===b.toLowerCase()) {...}
```

An alternate, bulleproof approach is to use the `String.localeCompare()`with sensitivity set to *accent*. like:

```js
const a = "hello";
const b = "HELLO";
if (a.localeCompare(b, undefined, { sensitivity: 'accent' }) === 0) {
    console.log("===")
}
```

Otherwise, it just returns a positive or negative integer indicating whether the compared string falls before or after the referenced string in the sort order. Just note that the second of `localeCompare()`just the locale.

### Checking if a String contains a Specific Substring

Simply need -- use the `String.includes()`method. Optionally, can tell the `includes()`where to start its search. The second parameter.

And the search that `includes()`performs is case-sensitive, if .. can call `toLowerCase()`on both strings first.

### Replacing all occurrences of a String

Want to find all occurrences of a specific substring in a string and replace them with something else. Use the `String.replaceAll()`method to make the change in one step.

`String.replaceAll(search, value);`

### Replacing HTML tags wth named Entities

Want to just insert markup into a web page, and escape the markup -- this could be cuz you want to show some example HTML markup in a tutorial article like: -- Use the `String.replaceAll()`to convert angle brackets into the named HTML entities.

### Converting the first letter of a String to Uppercase

Split off the first letter and capitalize it with `String.toUpper()`. Join the uppercase letter to the remainder of the string, which you can get with `String.slice()`. like:

```js
const original = 'if you cut an orange, there is a risk it will orbisulate';
const fixed = original[0].toUpperCase() + original.slice(1);
fixed
```

To get a fragment of a string, use the `slice()`method-- when calling `slice()`, must always specify the index where you want to start your string extraction. FORE, `slice(5)`just starts at index pos 5. And if don't want the `slice()`to continue to the end of the string -- the optional second -- 

`const substring = original.slice(5,10);`

## Numbers 

There are few ingredients more essential to everyday programming than numbers. Js had just a single do-everything numeric data type called `Number`-- the standard `Number`and `BigInt`only consider when need to deal with huge whole numbers -- 

### Generating Random Numbers

`Math.random()`to just generate a floating-point value between 0 and 1. Assuming your range spans from some minimum number `min`to `max`like:

`randomNumber = Math.floor(Math.random()*(max-min+1)+min);`

And the `Math`object is stocked full of static utility methods you can call at any time. This recipe uses `Math.random()`to get a random factional number, and `Math.floor()`to truncate the decimal portion.

### Generating Cryptographically Random Numbers

Use the `window.crypto`property to get an instance of the `Crypto`object. Then use its `getRandomValues()`to generate random values that have more *entropy*. And if want to round a number to a certain precision can use the `Math.round()`method to round a number to the nearest whole number.

### Converting a String to a Number

Want to parse a number in a string like: -- if a conversion just fails, the `Number()`function assigns the value `NaN`to your variable, can test for this failure by calling `Number.isNaN`method immediately. However, the `parseFloat()`is stricter with blank strings.

Using the `Number.toString()`with an arg that specifies the base you are converting to like:

```js
const num =25;
console.log(num.toString(16));
```

## Arrays

Js arrays are wildly flexible can hold any mixture of values inside. In most cases, though, individual Js arrays are intended to hold only one specific type of value. Adding values of a different type may be confusing to readers, or worse, the result of an error that could cuz problems in the program.

Ts just respects the best practice of keeping to one data type per array by remembering what type of data is initially inside an array, and only allowing the array to operate on that kind of data. if in ts:

```tsx
const warrios = ['artem', 'boud'];
warrios.push('zzz');  // ok
warrios.push(true); // error
```

Can think of Ts' inference of an array's type from its initial members as similar to how it understands variable types from their initial values. Ts generally tries to understand the intended types of your code from how values are assigned

### Array Typs

As with other variable declarations, variables meant to store arrays don't need to have an initial value. The variables can start off `undefined`and receive an array value later. Ts wil want you to let it know what typyes of values are meant to go in the array by giving the variable a type annotation -- like:

```tsx
let arrayOfNumbers: number[];
```

### Function Types

Array types are an example of a syntax container where function types may need parentheses to distinguish what is in the function type or not. like:

`let createstrings: ()=>string[];`
`let stringCreators (()=>string)[];`// array of functions

### Union-type Arrays

Can use a union type to indicate that each element of an array can be one of multiple select types. When using array types with unions, parentheses may need to be used to indicate which part of an annotation is the contents of the array or the surrounding unoin type.

```tsx
let stringOrArrayOfNumber : string | number[]; // either a number or strings
let arrayOfStringOrNumber : (string | number)[]; // each either a number or a string
```

Ts will understand from an array's declaration that it is a union type array if it contains more than one type of element. FORE this is a `(string | undefined)[]`type.

```tsx
const namesMaybe = ["Aqualtune", "Blenda", undefined];
```

### Any arrays

If don't include a type annotation on a varaible intially set to an empty array, ts will treat the array as evolving `any[]`, meaning that it can just receive any content. Don't recommand.

### Spreads and Rests

Ts recognizes and will perform type checking on the js practice of `...`spreading an array as a rest parameter. Array used as args for rest parameters must have the same array type as the rest parameter.

```tsx
function logWarrios(greeting: string, ...names: string[]) {
    for (const name of names) {
        console.log(`${greeting}, ${name}!`)
    }
}
const warriors = ['abc', 'def', 'efi'];
logWarrios("hello", ...warriors);
```

### Tuples

It is sometimes useful to use an array of a fixed size - also known as a *tuple* -- Tuple arrays have a specific known type at each index that may be more specific than a union type of all possible members of the array. Tuple arrays have a specific known type at each index that may be more specific than a union type of all possible members of the array. The syntax to declare a tuple type like an array literal. like:

```tsx
let yearAndWarrior: [number, string];
```

Tuples are often ued in js alongside array destructuring -- like:

```tsx
let [year, warrior]= Math.random()>0.5
?[340, "Archidamia"]: [1828, "Rani of Jansi"];
```

### Tuple Assignability

Tuple types are treated by Ts as more specific than variable length array types. That means that variable length array types are not assignable to typle types. And tuple of different lengths are also not assignable to each other. FORE:

```tsx
function logPair(name: string, value: number) {
    console.log(`${name} has ${value}`);
}
const pairArray = ["amage", 1];
logPair(...pairArray); // error
const pairArray2: [string, number] = ['amage', 2];
logPair(...pairArray2); //ok
```

### Inferences

Ts generally treats created arrays as variable length arrays, not tuples. If it sees an array being used as a variable's initial value or the returned value for a function, then it will assume a flexible size array. So:

```tsx
// return type: (string | number)[]
function firstCharAndSize(input:string) {
    return [input[0], input.length];
}
```

### Explicit tuple types

Tuple types may be used in type annotations, such as the return type annotation for a function, if the function is declared as returning a tuple type and returns an array literal, that array literal will be inferred to be a tuple instead of array.

```tsx
function firstCharAndExplicit(input: string): [string, number]{
    return [input[0], input.length];
}
```

### Const asserted tuples

Typing out tuple can be a plain for the same reasons as typing out any explicit type annotations. Ts provides an `as const`operator known as a *const assertion* that can be placed after a value. Const assertions tell ts to use the most literal, read-only possible form of the value when inferring its type. If one is placed after an array literal, it will indicate that the array should be just treated as a tuple like:

```tsx
const unionArray = [1157, "Tomoe"];
const readonlyTuple = [1157, "Tomoe"] as const;
```

In practice, read-only tuples are convenient for function returns -- Returned values from functions that return a tuple are foten destructured immediately anyway, so the tuple being read-only does not get in the way of using func. like:

```tsx
function firstCharAndSizeAsConst(input:string) {
    return [input[0], input.length] as const;
}
```

Before you start floating elements, you will put the outer structure of the page in place. Add the next listing to stylesheet like:

```css
:root {
    box-sizing: border-box;
}
*, ::before, ::after{
    box-sizing: inherit;
}

body {
    background-color: #eee;
}
body *+*{
    margin-top:1.5em;
}
header {
    padding: 1em 1.5em;
}
```

This layout is common for certering content on a page,  can achieve it by placing your content inside two nested containers and then set margins on the inner container to position it within the outer one. Calls it the *double container pattern*. Need to note, in our example, `<body>`jsut serves as the outer container, by default, this is already 100% of the page width, so you won't have to apply any new styles to it. Inside that, you've wrapped the entire contents of the page in a `<div class="container">`which serves as the inner container. just:

```css
.container {
    max-width: 1080px;
    margin: 0 auto /* auto left and right margin */
}
```

Instead of adding an extra `div`to your markup, use a *pseduo-element*, by using the `::after`pseudo-element selector, can effectively insert an element into the DOM at the end of the container. just set the class like:

```css
.clearfix::after {
    display: block; /* non-inline value */
    content: "";
    clear: both;
}
```

And some developers prefer to use a modified version of the clearfix that will conain all margins For the modified version, update the clearfix in your stylesheet to match this listing like:

## Unexpected float catching

Now that the white container contains the floated -- the four media boxes aren't laying out in two even rows. Cuz box 2 is shorter than box 1. The exact nature of this behavior is dependent on the heights of each of the floated blocks If box 1 is shorter than box2, there will be no edge for the 3rd box to catch on.

By floating a series of elements to one side, can end up with a wild array of layouts, depending on the heights of each box. Even changing the browsers width can alter things as this will affect line wrapping and will change the heights of the elements.

The fix for this is simple, namely, the third float needs to clear the floats above it. More generally, the first element of each row needs to clear the float above it.

```css
.media:nth-child(odd){
    clear:left;
}

.media {
    float:left;
    margin: 0 1.5em 1.5em 0;
    width:calc(50% - 1.5em);
    padding:1.5em;
    background-color: #eee;
    border-radius: .5em;
}
```

### Media objects and block formatting contexts

Now that each of the 4 gray boxes is laid out, look at their contents -- have an image on one side and a block of text beside it -- another ommon pattern in page layouts. Just added the classes media-image and media-body to the left and right parts of each media object, which use to position them -- start by floating the image to the left like:

```css
.media-image {
    float:left;
}
.media-body{
    margin-top:0;
}

/* override the top margin applied by
user agent style */
.media-body h4 {
    margin-top:0;
}
```

### Establishing a block formatting context

If examine the media-body class -- see that its box extends all the way to the left, so it envelops the floated image. But once it's clear of the bottom of the image, just moves all the way to the left of the box.

To achieve the layout on the right -- need to establish sth called block formatting context for the meida body -- BFC. This isolation does 3 things for element that establish the BFC -- 

1. Contains the top and bottom margins of all elements within it. Won't collapse with margins of element outside of the block formatting context.
2. It contains all floated elements within it.
3. Doesn't overlap with floated element without BFC.

Can just establish this in sereval ways -- like:

- `float: left | right`
- `overflow: auto hidden scroll`but `visible`
- `display: inline-block table-cell...flex, inline-flex...`
- `position: absolute`

```css
.media-image {
    float:left;
    margin-right: 1.5em;
}
.media-body{
    overflow: auto;
    margin-top:0;
}

```

So, using `overflow:auto`for the BFC is generally the simplest approach. Can use instead the other properties mentioned -- but some have considerations to just take into account -- A float or an inline-block will grow to 100%, so you'd need to restrict the width of the element to preent it from line wrapping below the float. On the contrary, a table-cell element will only grow enough to contain its content  so may need to set large width to force it remaining space.
