# Aggregation Pipelines and Arrays(2)

Convered update functions that are used to modify fields from one or more documents, also wrote a lot of update operations using various operators. Either used hardcoded values or dynamically dervied values using operators such as `$inc`-- in more complex update operations, may need to use dynamically dervied fieleds that are based on values of other fields. The following code snippets shows the syntax for using aggregation pipelines in `updateMany()`-- 

```js
db.collection.updateMany(
	<query condition>,
    [<update expression 1>, <2>, ...],
    <options>
)
```

For the update expression -- now is an array -- just like:

```js
db.users1.updateMany(
    {},
    [
        {
            // note that $split's target is an array
            $set: {"name_array": {$split: ["$full_name", " "]}}
        },
        {
            $set: {
                "first_name": {$arrayElemAt: ["$name_array", 0]},
                "last_name": {$arrayElemAt: ["$name_array", 1]}
            }
        },
        {
            $project: {
                "first_name":1,
                'last_name':1,
                'full_name': {
                    $concat: [
                        {$toUpper: "$first_name"},
                        " ",
                        "$last_name"
                    ]
                }
            }
        }
    ]
)
```

### Updating Array Fields

```js
db.moves1.findOneAndUpdate (
	{_id: 111},
    {$set: {'genre': ['unknown']}},
    {'returnNewDocument': true}
)

// unset, will remove the fields from the document
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$unset: {'genre': ''}},  // remove the whole genre field
    {returnNewDocument: true}
)

// $push, add element to arrays, $each, for every push
db.movies1.findOneAndUpdate(
    {_id:111},
    {$push: {'genre': {$each: ['History', 'Action']}}},
    {returnNewDocument: true}
)

// Sort array like:
db.movies1.findOneAndUpdate(
	{_id: 111},
    {$push: {
        'genre': {
            $each: [],
            $sort: 1
        }
    }},
    {returnNewDocument: true}
)

// also sort array of object like:
db.items.findOneAndUpdate(
	{_id: 11},
    {$push: {
        items: {
            $each: [],
            $sort: {'price': -1}
        }
    }},
    {returnNewDocument: true}
)
```

#### An Array as a Set

An array is an ordered collection of elements that can be iterated over or accessed using its specific index position -- a set is a collection of unique elements whose order is not guaranteed. If may want your array to contain unique elements only -- MDB provides a way to do that by using the `$addToSet`operator like:

```js
db.movies1.findOneAndUpdate(
	{_id: 111},
    {$addToSet: {'genre': 'Action'}},
    {returnNewDocument: true}
)
```

As can been in the preceding screenshot -- `Action`was not pushed to the array cuz the array already contains it.

```js
db.movies1.findOneAndUpdate(
	{_id:111},
    {$addToSet: {
        "genre": {$each: ['History', 'Thrller', 'Drama']}
    }},
    {returnNewDocument: true}
)
```

Here, just using `$each`to add 3 genres to the array, of which only the middle one is new.

Exercise -- 

```js
// first criterion like -- rating from reviews need to be more than 95 like:
db.movies.updateMany(
	{'tomatoes.viewer.meter': {$gt: 95}},
    {$addToSet: {'genres': 'Classic'}}
)
```

### Removing Array elements

The `$pop`operator, when used in an update command, allows U to remove the first or last element in the array, it removes one element at a time and can only be used with the vlaues of 1 or -1(first).

```js
db.movies.findOneAndUpdate(
	{_id: 111},
    {$pop: {'genre': 1}}, // from end, -1 from top
    {returnNewDocument: true}
)
```

#### Removing all

When U only need to remove certain elements from an array, can use `$pullAll`operator -- to do so, provides one or more element to the operator when removes all occurrences of those elements from the array. like:

```js
db.movies.findOneAndUpdate(
	{_id: 111},
    {$pullAll: {'genres': ['Action', 'Crime']}},
    {returnNewDocument: true}
)
```

#### Removing matched elements

Another operator called `$pull`-- which write a query condition, using various logical and condition operators, and the array elements that match the query will then be removed.

```js
db.items.findOneAndUpdate(
	{_id:111},
    {$pull: {
        items: {quantity:3, name: {$regex: /ck$/}}
    }},
    {returnNewDocument: true}
)
```

In this update command the `$pull`operator is provided with query condition in the array field `items`-- the conditions filter the array elements, where the `quantity`is 3 and the name ends with `ck`.

#### Updating Array elements

In an array, each element is boudn to a specific *index position* -- These index positions start at zero, can use a pair of square `[,]`with the respective index position to refer to an element from the array, using such a pair of square brackets with `$`allows to update elements of an array -- like: 

```js
db.movies.findOneAndUpdate (
	{_id: 111},
    {$set: {'genre.$[]': 'Action'}},
    {returnNewDocument: true}
)
```

In this operation, use the `$set`in the `generes`field -- is referred to by using the expression `genres.$[]`expressoin and provide with value `Action`value -- the `$[]`refers to **all** the elements contained by the given array. And the document in response indicates that `grnres`is still a 2-element array -- both elements are now changed to `Action`.

Similarly, can also update specific element from an array. To do so, first need to find such elements nd identify them -- to deriven an element identifier, can use the update option of `arrayFilters`to provide a query and assign it a variable to the matching elements.

```js
db.items.findOneAndUpdate(
	{_id: 11},
    {$set: {
        'items.$[myElement]': {
            quantity: 7,
            price:4.5,
            name: marker
        }
    }},
    {
        returnNewDocument: true,
        'arrayFilters': [{'myElement.quantity': null}]
    }
)
```

In this update operation, use `$set`to update the elements of the items array -- updated is referred to by an expression of `$[myElements]`and assigned a new value, which is a nested object. And the `myElement`is just defining using `arrayFilters`based on a query condition. Also:

```js
db.movies.updateMany(
	{'directors': 'H.C. Potter'},
    {$set: {
        'directors.$[hcPotter]': 'H.C. Potter (Henry Codman Potter)'
    }},
    {
        'arrayFitlers': [
            {
                hcPotter: 'H.C. Potter'
            }
        ]
    }
)
```

## Go Contexts

Developers sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the language and a foundation of concurrent code in Go -- A Context carries a deadline, a cancellation signal, and other values *across API boundaries*.

#### Deadline

A deadline refers a specific point in time determined with one of the following -- 

- A `time.Duration`from now
- A `time.Time`

The semanitics of a deadline convey that an ongoing activity should be stopped if this deadline is met. An activity is fore, an I/O request or a gorotuien waiting to receive a message from a channel.

```go
type publisher interface {
    Publish(ctx context.Context, position flight.Position) error
}
```

For this, just accetps a context and a position, assumet that the concrete imp calls a function to publish a message to a broker -- this is *context aware* -- meaning it can cancel a request once the context is canceled. Also assuming don’t receive an existing context -- what should we provide to the `Publish`method for the context argument -- have mentioned that the applications are interested only in the last position -- Hence, the context that build should convey that after 4s -- like:

```go
type publishHandler struct {
    pub publisher
}
func (h publishHandler) publishPosition(position flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
    defer cancel()
    return h.pub.Publish(ctx, position)
}
```

The code creates a context using the `context.WithTimeout`function -- this accepts a timeout and a context -- here as `publishPosition`doesn’t receive an existing context, create one from an empty context with the `context.Background()`-- and `context.WithTimeout`returns two variables -- context created and cancellation `func()`function will cancel the context once called. So, means that the `Publish()`method should make it return in *at most 4s*. Internally, `context.WithTimeout`creates a gorotuine that will be retained in memory for 4s or until the `cancel()`called.

#### Cancellation signals

And anotehr use case for Go context is to carray a cancellation signal -- Fore, want to create an app that calls `CreateFileWatcher(ctx context.Context, filename string)`within another goroutine -- this func creates a specific file watcher that keeps reading from a file and catches updates. When the provided context expires or is canceled, this function handles it to close the file descriptor. When `main`returns, want things to be handled gracefully by closing this file descriptor -- A possible approach is to use `context.WithCancel`-- 

```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    go func() {
        // when main returns, call the `cancel()` to cancel the contxt passed to this func
        // so the file descriptor is closed gracefully either
        CreateFileWatcher(ctx, "foo.txt")
    }()
}
```

#### Context Values

The last use case for Go context is to carray a k/v pairs -- like:

`ctx := context.WithValue(parentCtx, “key”, “value”)`Just like `context.WithTimeout context.WithDeadline`and `context.WithCancel`, 

For the `context.WithDeadline`like:

```go
func main() {
    deadline := time.Now().Add(2*time.Second)
    ctx, cancel := context.WithDeadline(context.Background(), deadline)
    defer cancel()
    dont := make(chan struct{})
    go func() {
        defer close(done)
        fmt.Println("worker started...")
        select {
        case <- time.After(3*time.Second):
            fmt.Println("worker finished (after deadline)")
        case <- ctx.Done():
            fmt.Println("worker canceled:", ctx.Err())
        }
    }()
    <-done // wait for worker to finish or be canceled
    fmt.Println("main existing.")
}
```

And a context conveying values can be created like: In this case, created a new `ctx`context containing the same characteristics as `parentCtx`but also conveying a key and value. Then can access the value using the `Value()`.

```go
ctx := context.WithValue(context.Background(), "key", "value")
fmt.Println(ctx.Value("key"))
```

Just note that the key and value provided are `any`type -- indeed for the value, want to pass `any`types -- and that should lead to collisions -- fore, two functions from different packages could use the same string values as a key.

```go
package provider
type key string
const myCustomKey key = "key" //...
```

For this the `myCustomKey`unexported, so there is no risk that another package using the same context could override the value that is already set.

Use cases -- fore, if we use trcing, may want different subfunctions to share the same correlation ID -- so developers may consider this ID too invasive to be part of the function signature -- in this, could also decide to include it as part of the provided context.

And the HTTP middleware fore:

```go
type key string
const isValidHostKey key = "isValidHost"

func checkValid(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        validHost := r.Host==="acme"
        ctx := context.WithValue(r.Context(), isValidHostKey, validHost)
        next.serveHTTP(w, r.WithContext(ctx)) // using this new
    })
}
```

#### Catching a context cancellation -- 

The `context.Context`type exports a `Done`method that returns a *receive-only* channel `<-chan struct{}`-- and this channel is closed when the work associated with the context should be canceled.

- The `Done`related to a context created with `context.WithCancel`is closed when the `cancel()`called
- The `Done`related to a context created with `context.WithDeadline`closed when deadline expired.

Note that the internal channel should be closed when a context is canceled or has met deadline -- instead of when it receives a specific value. Cuz the closure of a channel is the only channel action that all the consumer goroutines will receive. Then, `context.Context`exports an `Err()`that returns `nil`if `Done`is not yet closed, otherwise, it returns a `non-nil`error explaining why `Done`was closed.

- A `context.Canceled`error if the channel was canceled
- `context.DeadlineExceeded`if deadline passed.

```go
func handler(ctx context.Context, ch chan Message) error {
    for {
        select {
        case msg := <-ch:
            // do sth with msg
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

For this, creates a `for`and use `select`with two cases.

### Implement `sort.Interface`

In order to sort the books in the output of the main, used the `sort.Slice`, `sort`provides `sort.Interface`that can be implemented to sort slices or user-defined collections -- it becomes very handy when implementing custom sorting, in the case per author and ittle. `sort.Interface`exposes 3 methods where elements are pointed by an integer index. Just like:

```go
// byAuthor is a list of book
type byAuthor []Book

// Len implements the interface sort.Interface
func (b byAuthor) Len() int {
	return len(b)
}

// Swap implements the interface sort.Interface
func (b byAuthor) Swap(i, j int) {
	b[i], b[j] = b[j], b[i]
}

// Less implements and returns sorted
func (b byAuthor) Less(i, j int) bool {
	if b[i].Author != b[j].Author {
		return b[i].Author < b[j].Author
	}
	return b[i].Title < b[j].Title
}

func sortBooks(books []Book) []Book {
	sort.Sort(byAuthor(books)) // convert to sort.Interface
	return books
}
```

#### Use bufio to open a File

The first step we achieved in ths was to read the contents of a file. We first opened the file, which returned a file descriptor, which implements the `io.Reader`. like:

```go
f, err := os.Open(filePath)
if err != nil {}
defer f.Close()
```

When provide this reader to the `jons.NewDecoder`-- from there on, the magic happended in the `Decode`method of the `json`package. like:

```go
book bookworms []Bookworm
err = json.NewDecorder(f).Decode(&bookworms)
//...
```

Accessing files, either for reading or writing, makes system calls, System calls are at the junction between our programand OS -- are expensive, and we usually want to reduce their number.

First, need to understand the problem -- how many system calls do we go through, when reading a file fore, 10MiB wiht our current imp -- the answer is not obvious -- `os.File`type is os-specific. Improve this using the `bufio`package -- provides a `NewReaderSzie()`function that has the following -- `NewReaderSize()`returns a new `Reader`whose buffer has at least the specified size. And if the arg of `io.Reader`is already a `Reader`with large enough size, then returns the underlying reader, Fore, if call `NewReaderSize()`with `io.Reader`and give size of 1M, then are guaranteed that the reading will happen by making system calls with chunks of 1M. For this, are able to tinker our program to have it behave exactly as we want. So:

```go
f, err := os.Open(...)
if err != nil {}
defer f.Close()
bufferedReader := bufio.NewReaderSize(f, 1024*1024) // 1M
decoder := jons.NewDecoder(bufferReader) // new decoder not implement the Closer interface
err := decoder.Decode(&variable)
```

And, the `bufio`also offers an imp of `io.Writer`. There is a very important to *keep in mind* is that the `bufio.Write()`will only write data when its internal buffer is full. So need to call the `writer.Flush()`

```go
f, err := os.Create(...)
if err != nil {}
defer f.Close()
bufferedWriter := bufio.NewWriter(f, 1024*1024)
for _, data := contents {
    _, err = bufferedWriter.Write(data)
    if err != nil {}
}
err = bufferedWriter.Flush() // if buffer not full, so call from the buffer to dest
if err != nil {}
```

## CSRF protection

- User logs into app, session cookie is set to persist for 12h
- User then goes to a malicious website contains some code sends a cors-site request -- the session cookie will be sent along with this request
- Cuz the request includes the session cookie, our app will interpret the request as coming from a logged-in user and will process the request with the user’s privileges.

#### SameSite Cookies

One mitigation -- use the `SameSite`attribute to appropriately set the session cookie -- And, by default the `alexedawards/scs`always sets `SameSite=Lax`on the cookie -- means that the session *won’t* be sent by the user’s browser for any *unsafe* cross-site requests.

However, the `SameSite`is still relatively new and only fully supported by 90% of browsers.

#### Token-based mitigation

Also need some form of *token check*. The two most popular packages for stopping CSRF attackes in Go web apps are `gorilla/csrf`and `justinas/nosurf`. Just using the *double-submit cookies* pattern to pervent attacks -- in this pattern a random CSRF token is generated and sent to the user in a CSRF cookie. This CSRF token is then added to hidden field in each HTML form that is vulnerable to CSRF. When the form is submitted, both pacakges uses some middleware to check that the hidden field value and cookie value match.

For this app, use the `justinas/nosurf`in this -- perfer it primarily *self-contained* and doesn’t ahvae additional dependencies.

```sh
go get github.com/justinas/nosurf@v1
```

#### Using the `nosurf`package -- 

To use this, open file and create a new `noSurf`middleware function like so:

```go
// noSurf creates a function which uses a customized CSRF cookie with the
// secure, path, and HttpOnly attributes set
func noSurf(next http.Handler) http.Handler {
	csrfHandler := nosurf.New(next)
	csrfHandler.SetBaseCookie(http.Cookie{
		HttpOnly: true,
		Path:     "/",
		Secure:   true,
	})
	return csrfHandler
}
```

One for the forms that we need to protected from CSRF attacks is our logout form, which is included in our `nav.html`partial and could potentially appeas on any page of our app, so need to use the `noSurf()`middleware on *all* of our app routes -- apart from the `/static/*filepath`. Then in the routes.go like:

`dynamic := alice.New(app.sessionManager.LoadAndSave, noSurf)`

At this point, if post a login -- the request should be intercepted by the `noSurf()`middleware and you should receive a 400 bad request response. To make the form submission work, need to sue the `nosurf.Token()`function to get the CSRF and add it to a hidden `csrf_token`field in each of our forms.

```go
type templateData struct {
	// ...
	CSRFToken       string // add a CSRFToken field.
}
```

And cuz the logout form can potentially appear on every page, it just makes sense to add the CSRF token to the template data automatically via our `newTemplateData()`helper. This will mean that it is available to our templates each time we render a page.

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
	return &templateData{
		CurrentYear: time.Now().Year(),
		Flash:       app.sessionManager.PopString(r.Context(), "flash"),
		// Add the authentication status to the template data
		IsAuthenticated: app.isAuthenticated(r),
		CSRFToken:       nosurf.Token(r),
	}
}
```

Finally, need to update all the forms in the app to include this CSRF token in a hidden field.

`<input type="hidden" name="csrf_token" value="{{.CSRFToken}}">`

#### SameSite *Strict* setting

If want, can change the session cookie to use the `SameSite=Strict`setting instead of `SameSite=Lax`-- like:

```go
sessionManager := scs.New()
sessionManager.Cookie.SameSite = http.SameSiteStrictMode
```

It’s important to be aware that using `SameSite=Strict`will block the session cookie being sent by the user’s browser for all cross-site usage.

### Using request context

At the moment our logic for authenticating a user consists of simply checking whether a `authenticateUserID`value exists in their session data like:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
    return app.sessionManager.Exists(r.Context(), "authenticatedUserID")
}
```

Could make this check more robust by querying our `users`dbs table to make sure that the `authentiatedUserID`value is a real, valid value. But, the `isAuthenticated()`can potentially be called multiple times in each request cycle -- If query dbs from the `isAuthenticated()`helper directly, would end up making duplicated round-trips to the dbs during every request.

So a better approach would be to carry out this check in some middleware to determine whether the current request is from an authenticated user or not.

- What is request context -- how use it when it is appropriate to use
- How to use request context in practice to pass info about thecurrent user between your handlers.

#### How request context works

Every `http.Request`process has a `context.Context`object embedded in it -- which we can use to store information during the lifetime of the request. In a web app a common use-case for this is to pass info between your pieces of middleware and other handlers -- And in the case, want to use it to check if a user is authenticated once in some middleware -- and if are then make this info available to all our other middleware and handlers. And the basic context syntax fore:

```go
ctx := r.Context()
ctx = context.WithValue(ctx, "isAuthenticated", true)
r = r.WithContext(r)
```

