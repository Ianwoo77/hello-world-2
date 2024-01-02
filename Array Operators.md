# Array Operators

```js
db.blog.posts.updateOne({title: 'A blog post'},
    {$push: {comments:
                {name: 'joe', email: 'joe.example.com',
                content: 'nice post'}}});
```

Now if want to just add another comment, can simply use `$push`again like:

```js
db.blog.posts.updateOne({title: 'A blog post'},
    {$push: {comments:
                {name:'bob', email: 'bob@example.com',
                content:'good post'}}})
```

The Mongodb also provides modifiers for some operators, including `$push`and can push multiple values in one operation using the `$each`modifier for `$push`like:

```js
db.stock.ticker.updateOne({_id: 'google'},
    {$push: {hourly: {$each: [4,5,6]}}})

db.stock.ticker.findOne()['hourly']
```

And want to grow just to a certain length, cna use the `$slice`modifier with `$push`to prevent array from beyond a certain size. Effectively making a topN effect like:

```js
db.movies.updateOne({genre: 'horror'},
    {$push: {top10: {$each: ['Nightmare on Em street', 'saw'], $slice:-10}}})

db.movies.findOne()['top10']
```

And this example jsut limits the array to the last 10 elements pushed. And if an array is samller then 10, all elements will be jsut kept. if is larger then 10, then only the last 10 will be kept. Thus, `$slice`an just be used to create a queue in a document.

Can also apply the `$sort`modifier to `$push`operations before trimming: like:

```js
db.movies.updateOne({genre: 'horror'},
    {$push:{top10:{$each :[{name:'night', rating: 6.6},
                    {name: 'saw', rating: 4.3},
                    {name:'re2', rating: 10.8}],
            $slice:-10, $sort: {rating: -1}}}})
```

### Using arrays as sets

Might want to just treat an array as a set, only adding values if the are not present. This can be done using `$ne`in the query document fore:

```js
db.papers.updateOne({'authors cited': {$ne: 'Richie'}},
    {$push: {'authors cited': 'Richie'}})
```

This is also can be done with the `$addToSet`, which is just useful for cases where `$ne`won’t work or where `$addToSet`describes what is happening better.

```js
db.suers.updateOne({_id: ObjectId('4b2d75476cc613d5ee930164')},
    {$addToSet: {emails: 'joe@gmail.com'}})
```

Can also use the `$addToSet`in conjunction with the `$each`to add multiple unique value, which cannot be done with the `$ne`/`$push`combination. like:

```js
db.suers.updateOne({_id: ObjectId('4b2d75476cc613d5ee930164')},
    {$addToSet: {emails: {$each:
    ['joe@php.het', 'joe@example.com']}}})
```

### Removing elements

There are just a few ways to remove elements from an array, if want to just treat the array like a queue or a stack, cna use `$pop`which can remove elements from either end. like: `{$pop: {key:1}}`removes an element from the end and the `{$pop: {key: -1}}`removes from the beginning.

Sometimes an element should be removed based on specific crtieria, rather than its position in the array. `$pull`is used to remove element of an array that match the given criteria.

```js
db.lists.updateOne({}, {$push: {todo: 'laundry'}})
db.lists.find()
// then just remove the `laundry` like:
db.lists.updateOne({}, {$pull: {todo: 'laundry'}})
```

Need to note that pulling removes **All** matching documents, not just a single match. Array operators can be used only on keys with array values. Fore, cannot push onto integer or pop off a string.

Positional Array modifications -- Array manipulation becomes ticker-- when have multiple values in an array and want to modify some of them. For this, if want to increment the number of votes for the first comment, can say that following like:

```js
db.blog.updateOne({'post': post_id}, {$inc: {'comments.0.votes': 1}})
```

And in many cases, don’t know what index of the array to modify without querying for document first. To get around this, MongoDb has a positional operators -- `$`which figures out which element of the array the query document matched and updates that element. like:

```js
db.blog.posts.findOne()['comments']

db.blog.posts.updateOne({'comments.author': 'John'},
    {$set : {"comments.$.author": 'jim'}})
```

So the positional operator updates only the first match, thus, if `John`had left more than one, his name would be changed for the first comment the left.

#### Updates using array filters -- 

3.6 introduced another option for updating individual array elements -- `arrayFilters`-- this option enables us to modify array elements matching particular criteria. like:

```js
db.blog.updateOne({'post': post_id},
                 {$set: {comments.$[elem].hidden: true}},
                 {arrayFilters: [{'elem.votes': {$lte: 5}}]})
```

For this, defines `elem`as the identifier for each matching element, if votes values for the comment identified by `elem`is less than or equal -5, will add a field called `hidden`to the comments.

### Upserts

An `upsert`is a special type of update, if no document is found that matches the filter, a new document will be created by combining the criteria and updated documents. `upserts`can be just handy cuz they can eliminate the need to seed your collection. like:

```js
const cond = {url: '/blog'}
let blog = db.analytics.findOne(cond)
if (blog) {
    blog.pageviews++;
    db.analytics.updateOne(cond, {$set: {pageviews: blog.pageviews}})
} else {
    db.analytics.insertOne({...cond, ...{pageviews: 1}});
}
```

This means that we are making a round trip to the dbs. can just eliminatet eh race condition and cut down the amount of code by just sending an upsert to the dbs. like:

```js
db.analytics.updateOne({url: '/blog'},
    {$inc: {pageviews: 1}}, {upsert: true})
```

Note that this line does exactly what the previous code block does, except it’s just faster and ***atomic***. The new document is created by using the criteria document as a base and applying any modifier document to it.

FORE, if do an upsert that matches a key and increments to the value of the key, just the increment will be applied:

```js
db.users.updateOne({rep:25}, {$inc:{rep:3}}, {upsert:true})
```

The `upsert`just creates a new document with a rep of 28. And if upsert again, then a new row added cuz there is not any row’s rep is 25.

And, sometimes a field needs to be set when a document is created, but not changed on subsequent updates. This is what `$setonInsert`is for -- is an operator that only sets the value of a field when document is being inserted:

```js
db.users.updateOne({username: 'joe'},
    {$setOnInsert: {createdAt: new Date()}}, {upsert: true})
```

The `save`shell helper - `save`is just a shell function lets u insert a document if it doesn’t exist, and update it if it dows.

```js
let x= db.textcol.findOne();
x.num=24
db.textcol.save(x)
// 
db.textcol.replaceOne({"id": x._id}, x)
```

## Using the functional option pattern 

When designing an API, one question may arise -- how do deal with optional configuration. Solving this problem efficiently can improve how conventient our api wil become. This section goes through a concrete.

For this, design a library that exposes a function to crete an HTTP server. And, this function will accept different inputs, an address and a port. just like:

```go
func NewServer(addr string, port int) (*http.Server, error) {...}
```

The clients of our lib have started to use this func, and everyone is happy. But at some point, our clients begin to .. limited and lacks other parameters -- fore, a write timeout or sth. For now, noticed that adding new parameters breaks the compability. So for this problem:

- If port isn’t set, use default
- if negative, returns an error.
- if 0, use random
- otherwise, uses the port provided by the client

### Config Struct

Note that Go doesn’t support optional parameters in function signature, the first possible approach is to use a configuration struct to convey what’s mandatory and what is optional. Can:

```go
type Config struct {
	Port int
}

func NewServer(addr string, cfg Config) {}
```

This solution just fixes the compatibility issue. If add new options, it will not break on the client side. However, this approach doesn’t solve our requirement related to port management. By the way, should bear in mind that if a struct isn’t provided, it’s just initialized to its zero value.

For this case, just need to find a way to distinguish between a port purposely set to 0 and a missing port. Perhaps one option might to be handle all the parameters of the configuration struct as pointers in this way like:

```go
type Config struct {
    Port *int
}
```

Using an integer, semantially, can highlight the difference between the value 0 and a missing value. This option would work, but it has a couple of downside, it’s not handy for clients to provide an integer pointer like:

```go
port := 0
config := httplib.Config {Port: &port}
```

The second downside is that a client using our library with the default configuration will need to pass an empty struct:

`httplib.NewServer("localhost", httplib.Config{})`

### Builder pattern

The builder pattern provides a flexible solution to various object -- for creation problem.

```go
type Config struct {
	Port int
}

type ConfigBuilder struct {
	port *int
}

func (b *ConfigBuilder) Port(port int) *ConfigBuilder {
	b.port = &port
	return b
}

func (b *ConfigBuilder) Build() (Config, error) {
	cfg := Config{}
	if b.port == nil {
		cfg.Port = 80
	} else {
		if *b.port == 0 {
			cfg.Port = rand.Intn(65536) + 1
		} else if *b.port < 0 {
			return Config{}, errors.New("port should be positive")
		} else {
			cfg.Port = *b.port
		}
	}
	return cfg, nil
}
```

Then a client would use our builder-based API just as:

```go
builder := httplib.ConfigBuilder{}
builder.Port(8080)
cfg, err := builder.Build()
if err != nil {
    return err
}
//...
```

Also, has some downsides.

#### Functional options pattern

Last approach discuss is the functional options pattern -- although there are different implementations with minor variations, the main idea is:

1. An unexported struct just hold the configuration: `options`
2. Each option is a *function* that returns the same type, `type Option func(options *options)`

So just write:

```go
type options struct {
	port *int
}

type Option func(options *options) error

func WithPort(port int) Option {
	return func(options *options) error {
		if port < 0 {
			return errors.New("port should just be positive")
		}
		options.port = &port
		return nil
	}
}
```

So, the last part on provider side, the `NewServer`implementation -- pass the options as variadic parameters:

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil , err
        }
    }
}
```

### Project organization -- 

Note that the Go language maintainer has no strong convention about structing a project in go.

- `/cmd`-- the main source files fore, the `main.go`of a `foo`app should live in `/cmd/foo/main.go`file
- `/internal`-- private code
- `/pkg`-- Public code want to expose to others.
- `/test`-- additional external tests and test data.
- `/configs, /docs, /examples`
- `/web`-- specific assets, static files, fore

## Restful Routing in go

In the next -- going to add a HTML form to our web app so that users can create new snippets. To make this work smoothly, going to update our application routes so that requests to `/snippet/create`are handled differently based on the request method.

- `GET /snippet/create`requests want tho show the user the HTML form for adding a new snippet.
- `POST /snippet/crete`want to process this form data and then insert to the dbs.

### Installing a Router

There are just literally hundreds -- for this now, using the `go get github.bmizerany/pat`... The basic syntax for creating a router and registering a route with the `bmizerany/pat`package just looks like:

```go
mux := pat.New()
mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))
```

- `/snippet/:id`includes a named capture `:id`which acts like a wilcard -- whereas the rest of the pattern matches literally. Pat will add the contents of the named capture to the URL query string at runtime behind the scenes.
- the `mux.Get()`is used to register a URL pattern and handler which wil be called only if the request has a `GET`. Corresponding is `Post, Put, Delete`and other.
- Pat doesn’t allow to register handler directly, so need to convert to `http.HandlerFunc()`adapter

With this, modify to the `routes.go`file like:

```go
func (app *application) routes() http.Handler {

	// create a middleware chain containing our 'standard' middleware
	// will be used for every request our app receives
	standardMiddleware := alice.New(app.recoverPanic, app.logRequest, secureHeaders)

	mux := pat.New()
	mux.Get("/", http.HandlerFunc(app.home))
	mux.Get("/snippet/create", http.HandlerFunc(app.createSnippetForm))
	mux.Post("/snippet/create", http.HandlerFunc(app.createSnippet))
	mux.Get("/snippet/:id", http.HandlerFunc(app.showSnippet))

	fileServer := http.FileServer(http.Dir("./ui/static/"))
	mux.Get("/st/", http.StripPrefix("/st", fileServer))

	return standardMiddleware.Then(mux)
}
```

There are just a few things to point out here - 

- `Pat`matches patterns in the order that they are registered, in app, a HTTP request to `GET /snippet/create`is actually a valid match for two routes -- it’s an extact match for `/snippet/crete`-- and a wildcard match for the `/snippet/:id`
- URL patterns which end in a trailing slash -- `/static/`in the same way as inbuilt servemux.
- and the `/`is a special case, for this, will only match requests where the path is **exactly** `/`.

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	// Pat doesn't strip the colon from the named capture key, so need to 
	// get the value of the `:id` value
	id, err := strconv.Atoi(r.URL.Query().Get(":id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}
    //...
}

func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Create a new snippet..."))
}
```

Also, need to update the table in our `home.page.html`file so that the links in the HTML also use the new URL:
`<td><a href="/snippet/{{.ID}}">{{.Title}}</a></td>`

If : `curl -I -X POST http://localhost:4000/snippet/1`, will get a 405 result.

### Processing Forms

The high-level workflow for processing this form will just follow a std `POST-redirect-Get`pattern -- 

1. The user is shown the blank form when they make a GET to the `/snippet/create`
2. The user completes the form and it’s usbmitted to the server via a `POST`
3. The form data will be valiated by `createSnippet`. If it is passed, then we will be redirected the user to the `/snippet/:id`.

How: 

- parse and access form data sent in a `POST`
- Some tech for performing common validation checks
- A user-friendly pattern for alerting the user to validation failures and re-populating from fileds
- How to scale-up validation and keep your handlers clean by creating a form helper in a separate reusable package.

Setting up a Form -- Just making a new `create.page.html`to hold the HTML for the form like:

```html
{{template "base" .}}
{{define "title"}}Create a New Snippet{{end}}

{{define "main"}}
    <form action="/snippet/create" method="post">
        <div>
            <label>Title:</label>
            <input type="text" name="title"/>
        </div>

        <div>
            <label>Content:</label>
            <textarea name="content"></textarea>
        </div>

        <div>
            <label>Delete in:</label>
            <input type="radio" name="expires" value="365" checked>One year
            <input type="radio" name="expires" value="7">One week
            <input type="radio" name="expires" value="1">One day
        </div>
  
        <div>
            <input type="submit" value="Publish snippet">
        </div>
    </form>
{{end}}
```

Then also need to add link to the navgation bar for our app like: Then update the `createSnippetForm`handler so that it renders our new page like so:

```go
func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "create.page.html", nil)	
}
```

### Parsing Form Data

At a high-level we can just break this down into two distinct steps -- 

1. Use the `r.ParseForm()`to parse the request body, this checks that the request body is well-formed, and then stores the form data in the request’s `r.PostForm`**map**. And if there are any errors encountered when parsing the body, then it will return an error. The `r.ParseForm()`also idempotent.
2. Can get to the form data contained in `r.PostForm`by using the `r.PostForm.Get()`. Can retrieve the value of the `title`with the `r.PostForm.Get("title")`

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// use the r.PostForm.Get() to retrieve the relevant data fields like:
	title := r.PostForm.Get("title")
	content := r.PostForm.Get("content")
	expires := r.PostForm.Get("expires")

	// create a new record in the dbs
	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}
	http.Redirect(w, r, fmt.Sprintf("/snippet/%d", id), http.StatusSeeOther) // 303
}
```

#### The `r.Form`Map

Accessed the form values via the `r.PostForm`map -- but an alternative approach is to use the `r.Form`map. And the `r.PostForm`is populated only for `POST PATCH PUT`requests, and contains the form data from the request **body**.

In contrast, the `r.Form`is populated for all requests. Contains the form data from any request body **and** any query string parameters. If submitted to `/snippet/create?foo=bar`then can call `r.Form.Get("foo")`, note that in the event of a conflict, the request body value will take precedent over the query string parameter.

Using the `r.Form`map can be useful if application sends dat in a HTML form and in the URL.

The `FormValue`and `PostFormValue`methods -- The `net/http`package also provides the methods `r.FormValue()`and `r.PostFormValue()`, these are essentially shortcut functions that call `r.ParseForm()`then fetch the appropriate filed value. Note that should avoiding these -- cuz they *silently ignore any errors retuned by the `r.ParseForm()`.`*.

Multiple-value Fields-- And the `r.PostForm.Get()`will get the *first* value for a specific form field. This means that can’t use this get: 

```html
<input type="checkbox" name="items" value="foo">Foo
<input type="checkbox" name="items" value="bar">Bar
```

In this case, should work with the `r.PostForm`directly -- it’s just a map returns type `map[string][]string`like:

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprintf(w, "%d: Item: %s\n", i, item)
}
```

Form Size -- `enctype="multipart/form-data"`-- then `POST PUT PATCH`are limited to 10M. Change this by:

```go
r.Body = http.MaxBytesReader(w, r.Body, 4096)
```

