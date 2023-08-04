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

