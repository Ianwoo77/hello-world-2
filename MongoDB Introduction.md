# MongoDB Introduction

- A `document`is the basic unit of data for Mongo and is roughly equivalent to a row in a dbs
- A `collection`can be though a table
- A single instance of Mongo can host multiple independent dbs, eachi of which contians its own collections.
- Every document has a special key -- `_id`that is just unique within a collection.

### Documents

The keys of document are strings, Any UTF-8 character is allowed in a key, with a few notable exceptions -- 

- Keys must not contain the character `\0`-- sued to signify the end of the key
- `.`and `$`have some special properties and should be used only in certain circumstances.

Collections -- is a group of documents, and if a document is the mongodb analog of a row in a REL dbs, then a collection can be thought of as the analog to a table.

Dynamic Schemas -- Collections have *dynamic* schemas -- this means that the documents within a single collection can have any number of different shapes. fore:

```js
{"greeting":"hello", "views":3}
{"signoff":"good night, and good luck"}
```

For this have different keys, different numbers of keys, and values of different types. Cuz any document can be put into any collection, the question often arises -- 

- Keeping different kinds of documetns in the same collection can be nightmare.
- It’s much faster to get a list of collections than to extract a list of types of documetns in a collection.
- Grouping documents of the same kind together in the same collection allows for data locality.

SubCollections - One convention for organizing collections is to sue namespaced subcollections separated by the `.`character.

Mongodb also collections into databases -- A single instance of MG can host several dbs. A good rule of thumb is to store all data for a single app in the same dbs. Note htere are also some reserved data names -- 

- *admin* -- plays a role in authentication and authorization.
- *local* -- stores data specifiec to a single server
- *config* -- shared mg clusters use the *config* to store info about ecah shared.

### A mongoDB client

The real power of the shell lies in the fact that it is also a standalone Mg client. Basic operations -- can use the four basic operations, CRUD -- to manipulate and view data in the shell.

Update -- If we would like to modify our post, can use the `updateOne.updateOne`takes two parameters: the first is the criteria to find which document to update, and the second is a document describing the updates to make.

```js
db.movies.updateOne(
    { title: 'star wars' },
    {$set: {reviews:[]}}
)
// delete
db.movies.deleteOne({title: 'star wars'})
```

Basic Data Types -- Documents in MG can be thought of as JSON-like -- in that tehy are conceptually similar to objects in js -- JSON is a simple representation of data, the specification can be described in about one p and lists only six data types.

`ObjectID`-- An objectID is a 12-byte ID for documents.
`Code`-- Mongo also makes it possible to store arbitrary Js in queries and documents:
`{"x": function(){...}}`

Embedded Documents -- A document can be used as the value for a key. -- this is called an embedded document.

```js
{
    "name": "john Doe",
        "Address": {
            //..
        }
}
```

Value for the address key in this example is an embedded document with its own k/v pairs for ..

`_id`and `ObjectIds`-- Every document stored in Mg must have an `_id`key -- its value can be any type, it defaults to an `ObjectId`. -- In a single collection, every document must have a unique value for `_id`which ensures that every document in a collection can be uniquely identified. Can just run scripts from within the interactive shell using the `load`function like:

`load("script1.js")`

### CRUD operations

-- Adding , Removing, Updating, Choosing the correct lelel of safety VS. speed for all other operations.
`db.movies.insertOne({"title":'stand by me'})`

For the `insertOne`will add an `_id`key to the document and store the document.

`insertMany`-- if need to insert multiple documents into a collection, use `insertMany`-- 

```js
db.movies.drop()
// ...
items = [
    { title: 'Ghosbusters' },
    { title: 'E.T' },
    { title: 'Blade Runner' }
];
// Search for documents in the current collection.
db.movies.insertMany(
    items
);
```

When performing a bulk insert using `insertMany`-- if a document halfway through the array produces an error of some type, -- what happens depends on whether you have opted for ordered or unordered operations. Fore: cannot insert two documents with just the same `_id`

```js
db.movies.insertMany([
    { _id: 0, 'title': 'Top Gun' },
    { _id: 1, 'title': 'back to the future' },
    { _id: 1, 'title': 'Germlins' },
]);
```

And if specify unordered inserts, the first second, second, and fourth in array are just inserted. like:

```js
db.movies.insertMany([
    { _id: 3, 'title': 'Top Gun' },
    { _id: 4, 'title': 'back to the future' },
    { _id: 4, 'title': 'Germlins' },
    { _id: 5, 'title': 'Scaface' }],
    { ordered: false } // note that
);
```

Insert Validation -- MongoDB does minimal checks on data being inserted -- checks the document’s basic structure and adds an `_id`field if one does not exist. and one of basic structure checks is size -- all documents must be smaller than 16M.

For the `home.page.html`:

```html
{{template "base" .}}
{{define "title"}}Home{{end}}
{{define "main"}}
<h2>
    Latest snippets
</h2>
{{if .snippets}}
<table>
    <tr><th>Title</th><th>Created</th><th>ID</th></tr>
    {{range .Snippets}}
    <tr>
        <td>{{.Title}}</td>
        <td>{{.Created}}</td>
        <td>#{{.ID}}</td>
    </tr>
    {{end}}
</table>
{{end}}
```

### Caching Templates

Before can add more functionality to HTML templates, it’s good time to make some optimizations to codebase, there two main issues at the moment -- 

- Each and everty time render a web page, our app reads and parses the relevant template files using `template.ParseFiles()`function. Could avoid this duplicated work by parsing the files once -- when starting the app, and just storing the parsed template in an in-memory cache.
- There is duplicated code the `home`and `showSnippet`-- reduce that.

Tackle the first -- create an in-memory map with the type `map[string]*template.Template`in go to cache the parsed templates -- like:

```go
func newTemplateCache(dir string) (map[string]*template.Template, error) {
	// initialize a new map to act as the cache
	cache := map[string]*template.Template{}

	// using the filepath.Glob to get a slice of all filepaths with the
	// '.page.html`.
	pages, err := filepath.Glob(filepath.Join(dir, "*.page.html"))
	if err != nil {
		return nil, err
	}

	for _, page := range pages {
		// just extract the file name from the full file path
		// and assign it to the name variable
		name := filepath.Base(page)

		// parse the page template in to a template set
		ts, err := template.ParseFiles(page)
		if err != nil {
			return nil, err
		}

		// then use the `ParseGlob` to add layout templates to set
		ts, err = ts.ParseGlob(filepath.Join(dir, "*.layout.html"))
		if err != nil {
			return nil, err
		}

		ts, err = ts.ParseGlob(filepath.Join(dir, "*.partial.html"))
		if err != nil {
			return nil, err
		}

		// Add the template set to the cache like:
		cache[name] = ts
	}
	return cache, nil
}
```

And the next step is to initialize this cache in the `main`fucntion and make it available to our handlers as dependency via the `application`struct just like:

```go
type application struct {
	errLog        *log.Logger
	infoLog       *log.Logger
	snippets      *mysql.SnippetModel
	templateCache map[string]*template.Template
}
```

```go
templateCache, err := newTemplateCache("./ui/html")
if err != nil {
    errLog.Fatal(err)
}
app := &application{
    errLog:   errLog,
    infoLog:  infoLog,
    snippets: &mysql.SnippetModel{DB: db},
    templateCache: templateCache,
}
```

At this point, got an in-memory cache of the relevant template set for each of our pages, and handlers have access to this cache via the `application`struct. Then just for the second issue of duplicated code, and create a helper method so that can easily render the templates from the cache like:

```go
func (app *application) render(w http.ResponseWriter, r *http.Request,
	name string, td *templateData) {

	// retrieve the appropriate template set from the cache based on the page name
	ts, ok := app.templateCache[name]
	if !ok {
		app.serverError(w, fmt.Errorf("the template %s does not exist", name))
		return
	}

	// execute the template set, passing in any dynamic data
	err := ts.Execute(w, td)
	if err != nil {
		app.serverError(w, err)
	}
}
```

At this point, might -- for the `*http.Request`-- simply to future-proof the method signature.

```go
app.render(w, r, "home.page.html", &templateData{
		Snippets: s,
	})
//...
app.render(w, r, "show.page.html", &templateData{Snippet: s})
```

### Caching Runtime errors -- 

As soon as we begin adding dynamic behavior to our HTML templates, there is a risk of encountering runtime errors. fore, add a deliberate error to the `show.page.html`file like:

`{{len nil}}`-- which should generate an error at runtime cuz in Go the vlaue `nil`does not have a length. This is just pretty bad -- our applicaton has thrown an error, but the user has wrongly been sent a 200 ok response.

To fix this, need to make the template error render a two-stage process, first should make a trial render by writing the template into a buffer. can respond to the user with an error message. But if it works, can then write the contents to the buffer to our `http.ResponseWriter`.

```go
buf := new(bytes.Buffer)

// write the template to the buffer, instead of straight to the
// http.ResponseWriter
err := ts.Execute(buf, td)
if err != nil {
    app.serverError(w, err)
    return
}

// execute the template set, passing in any dynamic data
buf.WriteTo(w)
```

Head back to the `show.page.html`file and remove the error.

### Common Dynamic Data

In some web app there may be common dynamic data that you want to include on more than one webpage. FORE, might want to include the name and profile picture of the current user, or a CSRF token ain all pages with forms. Say, just want to include the current year in the footer on every page -- adding a new `CurrentYear`field to the `templateData`struct like so:

```go
type templateData struct {
	CurrentYear int
	Snippet     *models.Snippet
	Snippets    []*models.Snippet
}
```

Then to create a new `addDefaultData()`helper method to our application -- which will inject the current year into an instance of a `templateData`struct.

```go
func (app *application) addDefaultData(td *templateData, r *http.Request) *templateData {
	if td == nil {
		td = &templateData{}
	}
	
	td.CurrentYear=time.Now().Year()
	return td
}
// ...
err := ts.Execute(buf, app.addDefaultData(td, r))
```

Then modify the view like:

```html
{{define "footer"}}
<footer>Powered by <a href="https://golang.org">Go</a> in {{.CurrentYear}}</footer>
{{end}}
```

### Custom Template Functions

In the last part about templating and dynamic data -- explain how to create your own custom functions to be used in Go templates -- To illustrate -- create a custom `humanDate()`which outputs datetimes in a nice format. Need to note,  there are just two main steps -- 

1. Need to crate a `template.FuncMap`obj containing the custom `humanDate()`func
2. Need to use the `template.Funcs()`to register this before parsing the templates.

```go
func humanDate(t time.Time) string {
	return t.Format("02 Jan 2006 at 15:04")
}

var functions = template.FuncMap{
	"humanDate":humanDate,
}

//...
ts, err := template.New(name).Funcs(functions).ParseFiles(page)
```

For this, can accepts as many parameters as they need to, *must* return one value only.

```html
<div class="metadata">
    <time>Created: {{humanDate .Created}}</time>
    <time>Expires: {{humanDate .Expires}}</time>
</div>
```

Custom template functions like `humanDate()`can accept as many parameters as they needt o.

Pipelining -- In the code -- called our custom template function like this: -- An alternative approach is to use the `|`character to *piepline* values to a function. this works a bit like :

`<time>Created {{.Created | humanDate}}</time>`

And a nice feature of pipelining is that you can make an arbitrarily chain of template functions which use the ouput from one as the input for the next. 

`<time>{{.Created | humanData | printf “created %s”}}</time>`

## Code and Project Organization

- Organizing our code idiomatically
- Dealing efficiently with abstractions -- interfaces and generics
- Best practices regarding how to structure a proj

### Unintended variable shadowing -- 

In Go, a variable name declared in a block can be redeclared in an inner block -- called *variable shadowing*

```go
func main(){
	var client *http.Client
	if tracing {
		client, err := createClientWithTracing()
		if err != nil {
			return err
		}
		log.Println(client)
	}else {
		client, err := createDefaultClient()
		if err != nil {
			return err
		}
		log.Println(client)
	}
}
```

For this, first declare a `client`then use the short declration in both blocks to assign the result of the function call to the inner `client`variables.

So, for this situation-- how can we ensure that a value is assigned to the original `client`variable -- there are two different options -- like:

```go
var client *http.Client
if tracing {
    c, err := createClientWithTracing()
    if err != nil {
        return err
    }
    client = c
}else {
    //.. same logic for this
}
```

And the second option uses the assignment in the inner blocks to directly assign the function results to the `client`variable. This requires creating an `error`variable cuz the assignment operator works only if a variable name has already been declared. just like:

```go
var client *http.Client
var err error
if tracking {
    client, err = createClientWithTracing()
    if err != nil {
        return err
    }
}else {
    // same logic
}
```

### Un-necessary nested

In general, the more nested levels a function requires, the more compelx it is to read and understand. In FP, functions are considered *first-class citizens* -- this means they are treated in a similar way to how objects are treated in a traditional object-oriented language. fore:

```go
type predicate func(int) bool

func main() {
	is := []int{1, 1, 2, 3, 5, 8, 13}
	larger := filter(is, largerThan5)
	fmt.Println(larger)
}

func filter(is []int, condition predicate) []int {
	out := []int{}
	for _, i := range is {
		if condition(i) {
			out = append(out, i)
		}
	}
	return out
}

func largerThan5(i int) bool {
	return i > 5
}
```

`type predicate func(int) bool`-- this tells us that everywhere in our code base where we find the `predicate`type, it expects to see a function that taks an `int`and returns `bool`-- in the `filter`, using this to say we expect a slice of integers as input, as well as a function that matches the `predicate`type.

Waht are the *pure* fuction -- FP is often thought of as a pure.. A pure functional program is a subset of FP -- where each function has to be pure -- cannot mutate the state of a system or produce any side effects. To briefly -- say have a struct of `Person`-- with a `Name`-- two ways implement changing the name -- 

- Can create a func that takes in the object, changes the content of the `name`field
- takes in an obj and returns an new obj

The first way does not create a pure function, it has changed the state of our system. And one is shred between - are declarative rather then imperative.

```go
var a = func() int {
	fmt.Println("Var")
	return 0
}()

func init() {
	fmt.Println("init")
}
```

When a package initialized, all the constant and variable declrations in the package are evaluted then the `init`fnctions are executed. Can just define multiple `init`per package -- when we do, the execution order of the `init`inside the package is just based on the source file’s *alphabeticl order*. Can also define multiple `init`within the same source file. Can also use the `init`for side effects -- 

```go
// define a main package that doesn't have strong dependency on foo
package main
import (
	"fmt"
    _ "foo"
) // means no direct use of a public function
```

And another aspect of an `init`-- is that they cannot be invoked directly. like -- code will just produce the compile-time error.