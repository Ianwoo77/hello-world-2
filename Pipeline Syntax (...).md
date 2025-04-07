# Pipeline Syntax (...)

The sytnex of an aggregation pipeline is very simple, like the `aggregate`command itself. Like:

```js
const pipeline = [
    {$match: {'location.address.state': 'MN'}},
    {$project: {'location.address.city': 1}},
    {$sort: {'location.address.city': 1}},
    {$limit: 3}
];
```

Then the `db.theaters.aggregate(pipeline)`command in the MDB shell will provide the output

### Creating aggreagations

1. First, search the collection, to locate documents that match the state `MN`
   `{$match: {‘location.address.state’: ‘MN’}}`
2. Pass this list of theaters to the second stage, which projects only the clity the theaters exist in for the selected state `{project: {“location.address.city”: 1}}`
3. This list of cities is then passed to a `sort`stage, which sorts the data -- 
   `{$sort: {“location.address.city”: 1}}`

#### Aggreagation structure

Think of the pipeline as a multi-tiered funnel, it starts broad at the top and becomes thinner as it approaches the bottom. Usually the eaiest way to accomplish this is to do your matching first. Fore:

```js
db.getCollection('movies').aggregate(
  [
    {
      $match: {
        genres: { $in: ['Romance'] },
        released: {
          $lte: ISODate(
            '2001-01-01T00:00:00.000Z'
          )
        }
      }
    },
    { $sort: { 'imdb.rating': -1 } },
    { $limit: 3 },
    {
      $project: {
        title: 1,
        genres: 1,
        released: 1,
        'imdb.rating': 1
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

### Manipulating Data

Most of our activities and examples can be just reduced to the following -- there is a document or documents in a collection that should return some or all the documents in an easy-to-digest format. Using some of the more advanced stages and techniques in the pipeline allows us to *transform* our data, derive new data, and generate insights across a broader scope.

#### The `Group`stage

The `$group`stage allows U to group documents based on a speciifc condition -- although there are many other stages and methods to accomplish various tasks with the `aggreagate`command, the `$group`stage serves as the cornerstone of the most powerful queries. However, once master the `$group`stage, will be able to increase the scope of our queries to an entire collection by aggregating our documents in to large logic units.

Fore, the most basic imp of a `$group`accepts only an `_id`-- with the value being an expression -- this expression defines the criteria by which the pipeline groups documents together.

```js
const pipeline= [
    {$group: {_id:"$rated"}}
]
```

The first thing in the `$group`is the `$`notation before the `rated`field. The value of `_id`key was an *expression*. An *expression* can be a *literal, a expression object, an operator, or a field path*.

The `$goup`stage will interpret the `_id: “$rated”`as -- `_id: “$$CURRENT.rated”`, indicates that for each document, will *fit into the group match the same document with `rated`key*.

#### Accumulator Expressions -- 

The `$group`command can accept more than just one argument  -- can also accept any number of additional args in the following format like: `field: {accumulator: expression}`

- `field`will define the key of our newly computed field for each group
- `accumulator`must be supported accummulator operator, group of operators, like other operators may have worked already like `$lte` -- will just accumulate their value across *multiple documents* belonging to the same group.
- `expression`in this will be passed to the accumumlator operator as the input of what field in each document it should be accumulating.

```js
const pipeline = [
    {$group: {_id: '$rated', 'numTitles': {$sum: 1}}}
]
// fore:
/**
 * _id: The id of the group.
 * fieldN: The first field name.
 */
{
  _id: '$rated',
  sumRunTime: {
    $sum: '$runtime'
  }
}
```

With just a single aggregation stage and two parameters, we can begin to transform our data in exciting ways. Can also use several other useful operators to transform data after accumumlating. Can change our `$sum`accumulator to `$avg`-- which will return the average runtime acorss each group, so our pipeline becomes -- 

```js
db.getCollection('movies').aggregate(
  [
    {
      $group: {
        _id: '$rated',
        sumRunTime: { $avg: '$runtime' }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

This average runtime values are not particularly useful in this case, adding another stage to projject the runtime, using the ``$trunc`stage -- to give an integer value like:

```js
/**
 * specifications: The fields to
 *   include or exclude.
 */
{
  'roundAvgRuntime': {$trunc: '$avgRunTime'}
}
```

#### Maninpulating Data

The following steps help U complete this exercise -- 

```js
const pipeline = [
    {$match: {}}, {$group: {}}, {$sort: {}}, {$project:{}}
]
// just like:
db.getCollection('movies').aggregate(
  [
    {
      $group: {
        _id: { $arrayElemAt: ['$genres', 0] },
        popularity: { $avg: '$imdb.rating' },
        top_movie: { $max: '$imdb.rating' },
        longest_runtime: { $max: '$runtime' }
      }
    },
    { $sort: { popularity: -1 } },
    {
      $project: {
        _id: 1,
        popularity: 1,
        top_movie: 1,
        adjusted_runtime: {
          $add: ['$longest_runtime', 12]
        }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

The output shows that films, documentaries, and short filems are the most populare.

## Closing transient resources

#### Http Body

Discuss this problem in the context of HTTP - will write a `getBody`method that akes an HTTP GET request, and returns the HTTP body response -- like:

```go
type handler struct {
    client http.Client
    url string
}

func (h handler) getBody() (string, error) {
    resp, err := h.client.Get(h.url)
    if err != nil {
        return "", err
    }
    body, err := io.ReadAll(resp.Body)
    if err != nil {
        return "", err
    }
    return string(body), nmil
}
```

Use the `http.Get`and parse the resp using `io.ReadAll`-- there is a resource leak -- `resp`is an `*http.Respsonse`and it contins a `Body io.ReadCloser`field -- this body must be closed *if `http.Get()`doesn’t return an error*, otherwise, it’s just a resource leak -- our application will keep some memory allocated that is no longer needed but can’t be reclaimed by the GC and may prevent clients from reusing the TCP connection in the worst cases. 

The most convenient way to deal with the body closure is to handle it as a `defer`statement this way like:

```go
defer func() {
    err := resp.Body.Close()
    if err != nil {
        log.Println(...)
    }
}()
```

In this, properly handle the body resource closure as a `defer`function that will be executed once `getBody`returns. Could also understand that a resp body must be closed regardless of whether we read it. Fore, are only interested in the HTTP status and not in the body -- has to close no matter what -- 

```go
func (h handler) getStatusCode(body io.Reader) (int, error) {
    resp, err := h.client.Post(h.url, "application/json", body)
    if err != nil {
        return 0, err
    }
    defer func() {
        err := resp.Body.Close()
        if err != nil {
            log.Printf("failed to close the resp %v\n", err)
        }
    }()
    return resp.StatusCode, nil
}
```

Another essential thing to remember is that the behavior is different when close the body, depending on whether we have read from it -- 

- If close the body without a read, default http trnsport may close the connection
- if following a read, default http transport won’t close the connection, it may be reused.

So, if `getStatusCode`is called repeatedly and want ot use *keep-alive* connections could:

```go
func (h handler) getStatusCode(body io.Reader) (int, error) {
    resp, err := h.client.Post(h.url, "application/json", body)
    if err != nil {
        return 0, err
    }
    
    // close resp body
    _, _ = io.Copy(io.Discard, resp.Body)
    return resp.StatusCode, nil
}
```

When to close the resp body -- if

```go
resp, err := http.Get(url)
if resp != nil {
    defer resp.Body.Close()
}
if err != nil {
    resp "", err
}
```

Note that this imp is not necessary -- it’s based on the fact that in some condition -- On error, any resp can be ignored, a non-nil resp with an non-nil error only occurs when `CheckRedirect`fails. In general, all structs implementing the `io.Closer`should be clsed at some point.

#### sql.Rows

is a struct used as a result of an SQL query, cuz it implements the `io.Closer`-- 

```go
db, err := sql.Open("postgres", dataSourceName)
if err != nil {
    return err
}
rows, err := db.Query("SELECT * FROM CUSTOMERS")
if err != nil {
    return err
}
// use rows
```

Forgetting to close the rows means a connection leak -- which *prevent the dbs connection from being back into the connection pool.* Can handle the closure as a `defer`function following the `if err != nil `block

```go
rows, err := db.Query("SELECT * FROM CUSTOMERS")
if err != nil {
    return err
}

defer func() {
    if err != rows.Close(); err!= nil {
        //...
    }
}()
```

Following the `Query`call, should eventually close `rows`to prevent a connection itself leak.

#### `os.File`

`os.File`represents an open file descriptor,  Like `sql.Rows`it must be closed eventually -- 

```go
f, err := os.OpenFile(filename, os.O_APPEND | os.O_WRONLY, os.ModeAppend) 
if err != nil {
    return err
}
defer func() {
    if err := f.Close; err!= nil {
        log.Printf("...")
    }
}
```

For this, if don’t eventually close an `os.File`, it will not lead to leak per se -- the file will be closed automatically when `os.File`is *garbage collected*. And there is another benefit of calling `Close`-- to actively monitor the error that is returned, this should be the case with writing fiels.

And, note that writing to a file descriptor isn’t a sync operation. Fore:

```go
defer func() {
    closeErr := f.Close()
    if err == nil {
        err = closeErr // if some err occrured, return named parameter
    }
}()
_, err := f.Write(content)
return
```

Furthermore, success closing a writable `os.File`doesn’t guarantee that the file will be written on disk. This write can still live in a buffer on the filesystem and not be flushed on disk. If durability is a critical factor, an use the `Sync()`method to commit a change.

```go
func WriteToFile(filename string, content []byte) error {
    // open file...
    defer func() {
        _ = f.Close()
    }()
    _, err = f.Write(content)
    if err != nil {
        return err
    }
    // it ensures that the content is written to disk before returning.
    return f.Sync()
}
```

### Providing feedback

And task is now to let him know which characters of that wrod are in correct position, which are in the wrong position, and which simply don’t appera in the solution.

Determined that a feedback will be a list of indicataions that can have 3 values -- correct, misplaced, and absent. Will create the type `hint`to represent these hints.

```go
const (
	absentCharacter hint = iota
	wrongPosition
	correctPosition
)

// String implements the Stringer itnerface
func (h hint) String() string {
	switch h {
	case absentCharacter:
		return "⬜️"
	case wrongPosition:
		return "🟡"
	case correctPosition:
		return "💚"
	default:
		// This should never happen.
		return "💔"
	}
}
```

In Go, the best practice is always to make best use of the zero-value - and to sort the elements of the enum in a logical way -- *from worst to best* -- could have had an `unknownStaus`as the `zero-value`of our enum,  see later, using the zero-value for `absentCharacter`will come in handy.

#### The `Stringer`interface

One of the important interfaces to keep in mind while writing Go code is the `Stringer`interface defined in the `fmt`package. Providing a hint for a single character is good but will need to do so for every character of the word. For the `feedback`is a list of hints -- one per character of the word -- `type feedback []hint`.

Then our first and naive imp of the `String`on the feedback type is to create a `string`and append the status representation as we go through the feedback’s statuses. like:

```go
func (fb feedback) StringConcat() string {
    var output string
    for _, h := range fb {
        output += h.String()
    }
    return output
}
```

In Go, strings are immutable, Constant -- cannot alter them -- can’t ever replace a character in a string -- Sth back to ta string -- this makes string manipulation quite painful. Keep in mind when the numeber of strings to connect exceeds two, there are two quite common alternatives that worth checking -- 

- `strings.Join(elems []string, sep string) string`-- returns a string of the elements separated by the separateor.
- `strings.Builder`-- slightly more complex, -- but also a lot more versatile. 

The `strings`package provdies the type `Builder`that lets U build a `string`by appending pieces of the final string.

```go
func (fb feedback) String() string {
	sb := strings.Builder{}
	for _, h := range fb {
		sb.WriteString(h.String())
	}
	return sb.String()
}
```

This type exposes several methods that can be used to append characters to the string being built. `WriteString, WriteRune, WriteByte`and the basic `Write`.

## Dynamic HTML templates

In this going to concentrate on displaying the dynamic data from our MYSQL dbs in some proper HTML pages -- 

- Pass dynamic data to HTML, in a simple scalable and type-safe way
- Use the various *actions and functions* -- in Go’s `html/template`package to control the display of dynamic data
- Create a *template cache* so that your templates are not being read from disk for each HTTP request
- Gracefully handle template rendering errors at runtime
- Implment a pattern for passing common dynamic data to your web pages without repeating code

Fore

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id <1 {
        app.notFound(w)
        return
    }
    snippet , err := app.snippets.Get(id)
    //... error handling
    
    files := []string {
        "./ui/html/base.html",
        "./ui/html/partial/nav.html",
        "./ui/html/page/view.html",
    }
    
    // Parse the template files
    ts, err := template.ParseFiles(files...)
    if err != nil {
        app.serverError(w, err)
        return
    }
    
    err = ts.ExecuteTemplate(w, "base", snippet)
    if err != nil {
        app.serverError(w, err)
    }
}
```

```html
{{define "base"}}
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <link rel="stylesheet" href="/static/css/main.css">
        <title>{{template  "title" .}} - Snippetbox</title>
    </head>
    <body>
    <header>
        <h1><a href="/">Snippetbox</a></h1>
    </header>
    {{template "nav" .}}
    <main>
        <!-- display the flash message if exists -->
        {{with .Flash}}
            <div class="flash">{{.}}</div>
        {{end}}
        {{template "main" .}}
    </main>
    <footer>Powered by <a href="https://golang.org">Go</a>
        in {{.CurrentYear}}
    </footer>
    </body>
    </html>
{{end}}
```

Then in the `view.html`, defining the `title`, `main`...

```html
{{define "title"}} Snippet $ {{.ID}}{{end}}
{{define "main"}}
<div class="snippet">
    //...
</div>
{{end}}
```

#### Rendering multiple pieces of data-- 

In a real-world app there are often multiple pieces of dynamic data that you want to display in the same page. Fore:

```go
type templateData struct {
    Snippet *models.Snippet
}

// then use it in `snippetView` like:
// create an instance of templateData struct holding the snippet data
data := &templateData {
    Snippet: snippet,
}
```

Then in the view -- 

```html
{{define "main"}}
<div class="snippet">
    <div class="metadata">
        <strong>{{.Snippet.Title}}</strong>
    </div>
</div>
{{end}}
```

Also note that the `html/tempalte`package automatically escapes any data that is yielded between {{}} tags.

#### Calling methods 

If the type that you are yielding between {{}} tags has methods defined against -- you can call these methods -- fore, if the `.Snippet.Created`has the underlying type `time.Time`-- could:

```html
<span>{{.Snippet.Created.Weekday}}</span>
<!-- can also pass parameters -->
<span>{{.Snippet.Created.AddDate 0 6 0 }}</span>
```

Template actions and functions -- Good opportunity to use the `{{with}}`is the `view.html`like:

```html
{{define "main"}}
{{with .Snippet}}
<div class="snippet">
    <div class="metadata">
        <strong>{{.Title}}</strong>
    </div>
</div>
{{end}}
{{end}}
```

So now, between `{{with .Snippet}}`and the corresponding `{{end}}`the value of dot is set to `.Snippet`.

```go
type templateData struct {
    Snippet *models.Snippet
    Snippets []*Models.Snippet
}

// .. in the home() handler
snippets, err := app.snippets.Latest()
// ...
data := &templateData {
    Snippets: snippets,
}
```

```html
{{define "main"}}
{{if .Snippets}}
<table>
   	<tr><th>...</th></tr>
    {{range .Snippets}}
    <tr><td>{{.Title}}</td></tr>
    {{end}}
</table>
{{else}}
<p>
    Nothing here
</p>
{{end}}
{{end}}
```

