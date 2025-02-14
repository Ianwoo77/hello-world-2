# Creating, Updating and Deleting Documents

- Adding new documents to a collection
- Removing documents from a collection
- Updating existing documents
- Choosing the correct level of safety vs. speed for all these operations.

```js
db.movies.insertOne({title: 'Stand by Me'})
```

`insertOne`will add an `_id`key to the document and store the document. If need to insert multiple documents into a collection, can use `insertMany`-- Enables U to pass an array of documents to the dbs.

```js
db.movies.insertMany([
    {title:'Ghostbusters'},
    {title:'Ghostbusters 2'},
    {title:'Batman'},
])
```

Note that when performing a bulk insert using `insertMany`, and if a document halfway through the array produces an error of some type, what happens depends on whether U have opted for ordered or unordered operations. Fore, specify `true`for the key `ordered`, specify `false`and MDB may re-order the inserts to increase performance. 

```js
// 3, 4, 5 will be inserted
db.movies.insertMany([
        {"_id": 3, "title": "Sixteen Candles"},
        {"_id": 4, "title": "The Terminator"},
        {"_id": 4, "title": "The Princess Bride"}, // will not be inserted
        {"_id": 5, "title": "Scarface"}],
    {"ordered": false})
```

Insert Validation -- MDB will do minimal checks on data being inserted.

### Removing Documents

The CRUD API provides `deleteOne`and `deleteMany`for this purpose -- Both of these takes a filter document as the first parameter.

```js
db.movies.deleteOne({_id:4})
```

For this, used a filter that could only match one document since `_id`values are unqiue in a collection. And to delete all documents that match a filter like:

```js
db.movies.deleteMany({'year': 1984})
```

#### drop

It is possible to use `deleteMany`to remove all documents in a collection -- like:

```js
db.movies.deleteMany({})
// if want to clear an entire collection just
db.movies.drop()
```

### Updating Documents

Once document is stored in the dbs, it can be changed. To seel all available dbs, `show dbs`, and there are 2 ways to create a collectoin like:

```js
db.createCollection("posts")
db.posts.insertOne(object)
db.posts.insertOne({
  title: "Post Title 1",
  body: "Body of post.",
  category: "News",
  likes: 1,
  tags: ["news", "events"],
  date: Date()
})
db.posts.insertMany([  
  {
    title: "Post Title 2",
    body: "Body of post.",
    category: "Event",
    likes: 2,
    tags: ["news", "events"],
    date: Date()
  },
  {
    title: "Post Title 3",
    body: "Body of post.",
    category: "Technology",
    likes: 3,
    tags: ["news", "events"],
    date: Date()
  },
  {
    title: "Post Title 4",
    body: "Body of post.",
    category: "Event",
    likes: 4,
    tags: ["news", "events"],
    date: Date()
  }
])
```

#### Projection

Both `find`methods accept a second parameter called `projection`-- This is an `object`that describes whicih fields to include the results -- like:

```js
db.posts.find({}, {title:1, date:1}) // _id always included unless specifically excluded
db.posts.find({], {_id:0, title:1, date:1}})
```

The `updateOne()`will update the first document that is found matching the provided query like:

```js
db.posts.updateOne({title: 'Post Title 1'},
    {$set: {likes:2}})
// insert if not found
db.posts.updateOne(
    {title: 'Post Title 5'},
    {
        $set: {
            title: 'Post Title 5',
            body: 'Body of post.',
            category: 'Event',
            likes: 5,
            tags: ['news', 'events'],
            date: Date(),
        }
    },
    {upsert: true}
)
```

updateMany -- will update all documents that match the provided query like:

```js
db.posts.updateMany({}, {$inc: {likes: 1}})
```

Delete Documents -- Can delete documents by using the `deleteOne`or `deleteMany` -- like:

```js
db.posts.deleteOne({title:"Post Title 5"})
db.posts.deleteMany({category:'Technology'})
```

### Query operators

There are many query operators that can be used to compare and reference document fields -- `$eq, $ne, $gt, $gte, $in`and logical compare multiple queries -- `$and, $or, $nor, $not`, Evaluation like `$regex, $text, $where`.

Update operators -- like -- 

- `$currentDate`-- Sets the field value to current date
- `$inc`, increment
- `$rename`, renames the field
- `$set, $unset`-- set or remove the field

For array -- the following operators assist with updating arrays like:

- `$addToSet`Adds distinct elements to an array
- `$pop`-- Removes the first or last element of an array
- `$pull`-- Removes all from an array match the query
- `$push`-- Adds an element to an array

## Interface on the producer side

- Producer side -- An interface defined in the same package as concrete
- Consumer side -- an interface defined in the external package where it’s used.

For this, it’s common to see developers creating interfaces on the producer side. The design is perhaps a habit from C# or Java background but in Go -- in most cases is not what we should do. Create a specific package to store and retreive customer data -- 

```go
package store
type CustomerStorage interface {
    StoreCustomer(customer Customer) error
    GetCustomer(id, string) (Customer, error)
    UpdateCustomer(customer Customer) error
    GetAllCustomers() ([]Cusomter, error)
    GetCustomersWithoutContract() ([]Customer, error)
    GetCustomersWithNegativeBalance() ([]Customer, error)
}
```

As mentioned, interfaces are satisfied implicitly in Go -- *abstractions should be discovered, not created*. This means that it’s not up the producer to force a given abstractoin for all the clients. Instead, it’s up to the client to decide whether it needs some form of abstraction and then determine the best abstraction level for its needs.

Fore, Another client wants to just decouple its code but is only interested in the `GetAllCustomers()`-- In this case, this client can create an interface with a single method, referencing the `Customer`struct from the external package:

```go
package client
type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

From a package organization -- 

- Cuz the `customerGetter`interface is only used in the `client`package, remain unexported.
- Visually, in the figure, it looks like circular dependencies. However, there is no dependency from `store`to `client`cuz interfaces is satisfied implicitly. This is why such an app isn’t always possible in languages with an explicit implementation.

The main point is that the `client`package -- can now define the most accurate abstraction for its need -- it relates to teh concept of the interface-Segregation Principle.

### Returning interfaces

While designing function signature, may have not return either an interface or a concrete implementation -- understand why returning an interface, considered a bad practice in Go. Fore:

- `client`-- contains a `Store`interface
- `store`-- contains an implementation of `Store`

For this, in the `store`define an `InMemoryStore`struct that implements the `Store`interface. Create a `NewInMemoryStore`function to return a `Store`interface. There is a dependency from the imp packate to the `client`package in the design. In general, returning an interface restricts flexibility cuz force all the clients to use one particular type of abstraction. In Go -- 

- Should return structs instead of interfaces
- Accepting interfaces if possible.

And there are some exceptions, the most relevant one concerns the `error`type -- an interface returned by many function -- can also examine another in the `io`package.

### `any`says nothing -- 

In Go, an interface type that specifies zero methods is known as the empty interface -- `interface{}`, predeclared `any`became an alias for an empty interface. In assigning a value to an `any`type, lose all type information -- which requires a type assertion to get anything useufl out of the variable.

```go
package store

type Customer struct {}
type Contract struct {}
type Store struct {}
func(s *Store) Get(id string) (any, error) {}
func(s *Store) Set(id string, v any) error {}
```

Although there is nothing wrong with `Store`compilation-wise. Fore, if future developers need to use the `Store`, they will probably have to dig into the documentation or read the code to understand how to use these methods. By using `any`-- lose some of the benefits of Go as a statically typed language.

## Template actions and functions

In Go’s `html/template`, define template blocks using the `{{define “blockname”}}`action with `{{end}}`-- Can then use these blocks within other template using the `{{block “blockname” .}}`action and the `.`within the `block`action represents the data passed to the template.

- `{{if .Foo}} C1 {{else}} C2 {{end}}`
- `{{with .Foo}} C1 {{else}} C2 {{end}}`-- if `Foo`is not empty
- `{{range .Foo}} C1 {{else}} C2 {{end}}`-- If Foo is not zero length

Note that the *empty* values are `false`0, and `nil`pointer or interface value, array, slice... 0 length. And the `html/template`package also provides some template functions which can use to add extra logic to your templates and control what is rendered at runtime -- like:

`{{eq .Foo .Bar}}`, and `ne, not, or, index, len`, and `{{$bar := len .Foo}}`

Using the `with`action -- like:

```html
{{define "title"}}Snippet#{{.Snippet ID}}{{end}}
{{define "main"}}
{{with .Snippet}}
<div class="snippet">
    <strong>{{.Title}}</strong>
</div>
{{end}}
{{end}}
```

#### Using the `if`and `range`actions-- 

```go
type templateData struct {
    Snippet *models.Snippet
    Snippets []*models.Snippet
}

func (app *application) home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        app.notFound(w)
        return
    }
    snippets, err := app.snippets.Latest()
    if err != nil {
        app.serverError(w, err)
        return
    }
    files := []string{
        //...
    }
    ts, err := template.ParseFiles(files...)
    if err != nil {
        app.serverError(w, err)
        return
    }
    date := &templateData {
        Snippets: snippets
    }
    err = ts.ExecuteTemplate(w, "base", data)
    if err!= nil {
        app.serverError(w, err)
    }
}
```

For this, want to use the `{{if}}`action to check whether the slice of snippts is empty or not -- if it’s empty, want to display message -- want to display message -- like:

```html
{{define "title"}}Home {{end}}
{{define "main"}}
{{if .Snippets}}
<table>
    <!--... content -->
    {{range .Snippets}}
    <tr>...</tr>
    {{end}}
</table>
{{else}}
<p>
    There is nothing to see here yet
</p>
{{end}}
{{end}}
```

#### Combining functions

It’s possible to combine multiple functions in your template tags, using `()`to sorround the functions and there arguments as necessary -- fore, the following tag will render the content `C1`if the length is greater then 99

`{{if (gt (len .Foo) 99)}} C1 {{end}}`

Controlling loop behavior -- With a `{{range}}`can use the `{{break}}`command to end the loop early -- and `{{continue}}`to immediately start the next loop iteration like:

```html
{{range .Foo}}
{{if eq .ID 99}}
	{{continue}}
{{end}}
{{end}}
```

### Caching templates

Before adding more functionality -- good time to make saome optimiazation to codebase -- 

- Each and eery time render a web page, app reads and parses the relevant template files using the `template.ParseFiles()`func -- could avoid this duplicated work by parsing the files once, when starting the app, and storing the parsed templates in an in-memory cache.
- There is duplicated code in the `home`and `snippetView`handlers. And could reduce this duplication by creating a helper function like:

```go
func newTemplateCahce() (map[string]*template.Template, error) {
    cache := map[string]*template.Template{}
    
    // Using the filepath.Glob() to get a slice of all filepaths that matching the path
    pages, err := filepath.Glob("./ui/html/pages/*.html")
    if err != nil {
        return nil, err
    }
    
    for _, page := range pages {
        // extract the file name
        name := filepath.Base(page)
        
        // create a slice containing the filepath for our base template
        files := []string {
            "./ui/html/base.html",
            "./ui/html/partials/nav.html",
            page,
        }
        ts, err := template.ParseFiles(files...)
        if err != nil {
            return nil, err
        }
        
        // Add the template set to map
        cache[name]=ts
    }
    return cache, nil
}
```

Then the next step is to initialize this cache in the `main()`and make it available to our handlers as a dependency:

```go
type application struct {
    errorLog *log.Logger
    //...
    templateCache map[string]*template.Template
}

func main() {
    //...
    templateCache, err := newTemplateCache()
    if err != nil {
        errLog.Fatal(err)
    }
    
    // add it to the app dependencies
    app := &application {
        //...
        templateCache: templateCache,
    }
}
```

At this point, got an in-memory cache of the relevant template set for each of our pages. Now tackle the second issue of duplicated code, and create helper method so that we can easily render the template from the cache -- like:

```go
func (app *application) render (w http.ResponseWriter, status int, page string, data *templateData) {
    ts, ok := app.templateCache[page] // retrieve the template set from cache
    if !ok {
        err := fmt.Errorf("the template %s does not exists", page)
        app.serverError(w, err)
        return
    }
    
    // Write out the provided HTTP status code
    w.WriteHeader(status)
    
    err := ts.ExecuteTemplate(w, "base", data)
    if err != nil {
        app.serverError(w, err)
    }
}
```

With that, now get to see the pay-off from these like:

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path!= "/" {
        app.NotFound(w)
        return
    }
    snippets, err := app.snippets.Latest()
    //...
    app.render(w, http.StatusOK, "home.html", &templateData {
        Snippets: snippets,
    })
}
```

#### Automatically parsing partials -- 

Make our `newTemplateCache()`function a bit more flexible so that it automatically parses all *templates* in the `partials`-- 

```go
func newTemplateCache() (map[string]*template.Template, error) {
    cache := map[string] *template.Template{}
    pages, err := filepath.Glob("./ui/html/pages/*.html")
    //...
    for _, page := range pages {
        name := filepath.Base(page)
        ts, err := template.parseFiles("./ui/html/base.html")
        if err != nil {
            return nil, err
        }
        
        // call ts.ParseGlob()
        ts, err = ts.ParseGlob("./ui/html/partial/*.html")
        //...
        ts, err = ts.ParseFiles(page)
        if err != nil {
            return nil, err
        }
        cache[name] = ts
    }
    return cache, nil
}
```

### Catching runtime errors

If added the line `{{len nil}}`-- which should generate an error at runtime cuz `nil`has not length. If only does so, our app has thrown an error -- but the user has wrontly been sent a 200ok. So:

```go
func (app *application) render(w http.ResponseWriter, status int, page string,
                               data *templateData) {
    ts, ok := app.templateCache[page]
    if !ok {
        err := fmt.Errorf("the template %s does not exist", page)
        app.serverError(w, err)
        return
    }
    
    // initialize a new buffer
    buf := new(bytes.Buffer)
    
    // Write the template to the buffer, instead of straight to the respone-writer
    err := ts.ExecuteTemplate(buf, "base", data)
    if err != nil {
        app.serverError(w, err)
        return
    }
    w. WriteHeader(status)
    buf.WriteTo(w)
}
```

#### Common dynamic data

In some web apps there may be common dynamic data that you want to include on more than one -- webpage.

```go
type templateData struct {
    CurrentYear int
    Snippet *models.Snippet
    Snippets []*models.Snippet
}
```

Then to add a `newTemplateData()`helper to app return a `templateData`:

```go
func(app *application) newTemplateData(r *http.Request) *templateData {
    return &templateData{
        CurrentYear: time.Now().Year(),
    }
}
```

Then just add our `hom`and `snippetView`handlers to use the helper function like:

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
    //...
    data := app.newTempalteData(r)
    data.Snippts = snippets
    app.render(w, http.StatusOK, "home.html", data)
}
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    //...
    data := app.newTemplateData(r)
    data.Snippet = snippet
    app.render(w, http.StatusOK, "view.html", data)
}
```

In the template just like:

```html
{{define "base"}}
<!-- -->
<body>
    <footer>
    	Powered by <a href="...">Go</a> in {{.CurrentYear}}
    </footer>
</body>
```

