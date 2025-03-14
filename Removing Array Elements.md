# Removing Array Elements

The `$pop`operator, when used in an updated command, allows U to remove the first or last element in an array. It removes one element and can only be used with the values 1 or -1.

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$pop: {genres:1}},
    {returnNewDocument:true}
)
```

#### Removing all elements

When only need to remove certain elements from  an array, can use the `$pullAll`operator, like:

```js
db.movies1.findOneAndUpdate(
	{_id:111},
    {$pullAll: {'genres': ['Action', 'Crime']}},
    {returnNewDocument: true}
)
```

REmoving matched element -- `$pull`operator -- for `itmes`collection, just will write a query to update the array with `$pull`, remember that it allows Us to use combinations of logical and conditional operators to prepare a query condition just like `find`like:

```js
db.items.findOneAndUpdate(
    {_id:11},
    {$pull: {
        items: {
            'quantity':4,
            'name': {$regex: /pad$/}
        }
        }},
    {returnNewDocument:true}
)
```

#### Updating array elements

In an array, each element is bound to a specific index position -- these index position start at 0, and we can use a pair of square bracket `[]`with the respective index position to refer an element from th array, using such a pair of square bracket with `$`allows U to update elements of an array -- like:

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$set : {"genres.$[]": 'Action'}},
    {returnNewDocument:true}
)
```

The field is referred to by using the expression `genres.$[]`-- provide with the `Action`value the `$[]`operator refers to all the elements contained by the given array and the update expression will be applied to all of them. For this note that the document in respsonse, indicates the `genres`is still 3 -- all are changed to `Action`. Therefore, can use the `$[]`operator to update all elements in an array with the same value.

So, can also update specific elements from an array -- first need to find such elements and identify them. To deriven, can use the update option of `arrayFilters`to provide a query condition and assign it a variable to the matching elements, use this identifier along with `$[]`to update the values of those specific elements. like:

```js
db.items.findOneAndUpdate(
    {_id:11},
    {$push: {'items': {name: 'it'}}},
    {returnNewDocument:true}
)

// notice tht the newly doesn't have the price and quantity just:
db.items.findOneAndUpdate(
    {_id: 11},
    {
        $set: {
            'items.$[myElements]': {
                quantity: 7,
                price: 4.5,
                name: 'marker'
            }
        }
    },
    {
        returnNewDocument: true,
        arrayFilters: [{'myElements.quantity': null}]
    }
)
```

For this, used the `$set`to update the elements of the `items`array -- the array element to be updated is referred to by an expression of `$[myElement]`and assigned a new value -- which is a nest object. The identifier of `myElement`is defined using `arrayFilters`based on a query condition. All of the elements that match the given condition are identified by `myElements`then just the `itmes.$[myElement]`-- for now, `items`is a column.

#### Updating the Director’s name

On the website, people can find movies by their title or by names of actors or directors. To connecto to update the name of these directors, so the users don’t confuse with another director how has a similar name.

```js
db.movies.find(
    {'directors': 'H.C. Potter'},
    {_id:0, title:1, directors:1}
)
```

This find command finds all the movies by the director’s abbreviated name and prints the movie titile... As all movies to be updated, use the `updateMany()`update function -- like 

```js
db.movies.updateMany(
    {'directors': 'H.C. Potter'},

    // added an update expression uses $set
    {$set: {
        'directors.$[hcPotter]': 'H.C. Potter (Henry Codman Potter)'
        }},

    // Using arrayFilters to filter the array
    // using same condition with condition clause
    {arrayFilters: [{'hcPotter': 'H.C. Potter'}]}
)
```

For this, the output indicates you have correctly updated the director’s name in all the records.

#### Adding an Actor’s name to the Cast

Recently, an error in dbs came to your attention -- the action .. played the character of Zach in the 2015, however the `cast`field in the movie record does not attribute this actor -- like:

```js
db.movies.find(
    {'title': 'Jurassic World'},
    {_id: 0, title: 1, cast: 1}
)
```

## The Go memory model

The previous section just discussed 3 main techniques to synchronize goroutines, atomic operation, mutexes, and channels -- however there are some core principles we should be aware of as Go developers. Fore, buffered and unbuffered channels offer differ guarantees.

The Go memory model is a specification that defines the conditions under which a read from a variable in one goroutine can be guaranteed to happen after a write to the same variable in a different goroutine. Within multiple goroutines, we should bear in mind some of these guarantees -- will use the 

```go
// data race, no guarantee
i := 0
go func() {
    i++
}()
fmt.Println(i)

// send on a channel happens before the corresponding receive from that channel completes
i := 0
ch := make(chan struct{})
go func() {
    <-ch // 3
    fmt.Println(i)  //4
}()
i++ // 1
ch <- struct{}{} // 2

// closing happens before a receive
ch := make(chan struct{})
go func() {
    <-ch 
    fmt.Println(i)
}()
i++ 
close(ch) // 1

// lead to a data race
ch := make(chan struct{}, 1) // buffered one
go func() {
    i=1 
    <-ch //2
}()
ch <- struct{}{} // 1
fmt.Println(i)
```

If change the latest one unbuffered, no data race occurred.

### Concurrency impacts of a workload type

Looks at the impacts of a workload type in a concurrent implementation -- Depending on whether a workload is CPU or I/O bound may need to tackle the problem differently. Fore the following implements a `read`function that accepts an `io.Reader`and reads 1024 bytes from it repeatedly -- like;

```go
func read(r io.Reader) (int, error) {
    count := 0
    for {
        b := make([]byte, 1024)
        _, err := r.Read(b)
        if err != nil {
            if err == io.EOF {
                break
            }
            return 0, err
        }
        count += task(b)
    }
    return count, nil
}
```

Go Context -- Developers sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the language and a foundation of concurrent code in Go -- 

A *Context* carries a deadline, a cancellation signal, and other value across API boundaries.

#### Deadline

A deadline refers to a specific point in time determined with one of the folloing -- 

- `time.Duration`from now
- `time.Time`

The semantics of deadline convey that an ongoing activity should be stopped if this deadline is met. Fore, an I/O requst or a goroutine waiting to receive a message from a channel -- like:

```go
type publisher interface {
    Publish(ctx context.Context, position flight.Position) error
}
```

Just accepts a context and a position, assme that the concrete imp calls a function to publish a message to a broker. This func is just *context aware* -- meaning it can cancel a request once the context is cancled. Have mentioned that the app are interested only in the latest positoin -- the context that we build should convey that after 4s. like:

```go
type publishHandler struct {
    pub pubhlisher
}
func (h publishHandler) publishPosition(position flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
    defer cancel() // defers the cancellation
    return h.hub.Publish(ctx, position)
}
```

This code creates a context using the `context.WithTimout`function -- this function accepts a timeout and a context, as `publishPosition`doesn’t receive an existing context, create one from an empty context with `context.Background`-- And, `context.WithTimeout`returns two variables -- the context created and cancellation `func()`that will cancel the context once called. Passing the context created to the `Publish`method should make it return in at **most** 4s. Internally, `context.WithTimeout`creates a goroutine that will be retained in memory for 4s or until `cancel()`called. Therefore, calling `cancel()`as a `defer`func means that when we exit the parent, the context will be canceled, and the goroutine created will be stopped.

#### Cancellation signals

Another use case fro Go context is to carry a cancellation signal -- imagine that we want to create an app that calls `CreateFileWatcher(ctx context.Context, filename string)`-- This just creates a specific file watcher that keep reading from a file and catches updates -- when the provided context expires or is canceled, this function handles it to close the file descriptor. 

Finally, when `main`returns, want things to be handled gracefully by closing this file descriptor. A possible approach is to use `context.WithCancel()`-- returns a context that will be cancel once the `cancel()`called like:

```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cacnel()
    go func() {
        CreateFileWatcher(ctx, "foo.txt")
    }()
    //...
}
```

For this, when `main`returns, it calls the `cancel`function to cancel the context passed to the `CreateFileWather`.

#### Context Values

The last use cse for Go contexts is to carry a k-v list -- before -- first see -- 

```go
ctx := context.WithValue(parentCtx, "key", "val")
```

Just like `context.WithTimeout`, `context.WithDeadline`and `context.WithCanacel`, `context.WithValue`is created from a parent context, in this case, we created a new `ctx`containing the same characteristics as `parentCtx`also conveying a key and a value.

```go
ctx := context.WithValue(context.Background(), "key", "value")
fmt.Println(ctx.Value("key"))
```

And, the key and values provided are `any`types -- indeed, for the value,  want to pass `any`types -- but why should the key be an empty interfaces as well and not a string, fore -- That could lead to collisions -- two functions from different packages could use the same string key. so:

```go
package provider

type key string

const myCustomKey key = "key"

func f (ctx context.Context) {
    ctx = context.WithValue(ctx, myCustomKey, "foo")
}
```

For this `myCustomKey`constant is unexportd, hence, there is no risk that another package using the same context could orverride the value that is already set.

Fore, if use tracing -- may want different subfunctions to share the same correlation ID.
another fore, HTTP middleware -- If want middlewares to communicate, Have to go through the context handled in the `*http.Request`. like:

```go
type key string

const isValidHostKey key = "isValidHost"

func checkValid(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        validHost := r.Host == "acme"
        ctx := context.WithValue(r.Context(), isValidHostKey, validHost)
        next.ServeHttp(w, r.WithContext(ctx)) // note that
    })
}
```

First, define a specific context key called `isValidHostKey`, then the `checkValid()`middleware checks whether the source host is valid -- this information is conveyed in a new context.

### Count the books

For this task, how do we count all the books -- have access to a slice of bookworm, so will strat 3  -- A `map`in Go is an unordered associative array that contains pairs keys and values. A map’s key can be anything that is *comparable*.

Init counter -- The counter would be saved in a map. Just like:

```go
func findCommonBooks(bookworms []BookWorm) []Book {
	// Register all on shelves
	booksOnShelves := booksCount(bookworms)

	// list containing all the books that we read at least 2
	var commonBooks []Book
	for book, count := range booksOnShelves {
		if count >= 2 {
			commonBooks = append(commonBooks, book)
		}
	}
	return sortBooks(commonBooks)
}

func booksCount(bookworms []BookWorm) map[Book]uint {
	count := make(map[Book]uint)
	for _, bookworm := range bookworms {
		for _, book := range bookworm.Books {
			count[book]++
		}
	}
	return count
}

func sortBooks(books []Book) []Book {
	sort.Slice(books, func(i, j int) bool {
		if books[i].Author != books[j].Author {
			return books[i].Author < books[j].Author
		}
		return books[i].Title < books[j].Title
	})
	return books
}
```

Test it -- Writing the test for this small function is not particularly tricky -- First, can write a helper to compare the equility of two maps of books by verifying first that the keys in the `want`map are present in what we go.

```go
func TestFindCommonBooks(t *testing.T) {
	type testCase struct {
		input []BookWorm
		want  []Book
	}

	tt := map[string]testCase{
		"no common book": {
			input: []BookWorm{
				{Name: "Fadi", Books: []Book{handmaidsTale, theBellJar}},
				{Name: "Peggy", Books: []Book{oryxAndCrake, janeEyre}},
			},
			want: nil,
		},
		"one common book": {
			input: []BookWorm{
				{Name: "Peggy", Books: []Book{oryxAndCrake, janeEyre}},
				{Name: "Did", Books: []Book{janeEyre}},
			},
			want: []Book{janeEyre},
		},
		"three bookworms have the same books on their shelves": {
			input: []BookWorm{
				{Name: "Peggy", Books: []Book{oryxAndCrake, ilPrincipe, janeEyre}},
				{Name: "Did", Books: []Book{janeEyre}},
				{Name: "Ali", Books: []Book{janeEyre, ilPrincipe}},
			},
			want: []Book{janeEyre, ilPrincipe},
		},
		"output is sorted by authors and then title": {
			input: []BookWorm{
				{Name: "Peggy", Books: []Book{ilPrincipe, janeEyre, villette}},
				{Name: "Did", Books: []Book{janeEyre}},
				{Name: "Ali", Books: []Book{villette, ilPrincipe}},
			},
			want: []Book{janeEyre, villette, ilPrincipe},
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			got := findCommonBooks(tc.input)
			if !equalBooks(t, tc.want, got) {
				t.Fatalf("got a different list of books: %v, "+
					"expected %v", got, tc.want)
			}
		})
	}
}

// equalBookWorms checks if two BookWorm slices are equal.
func equalBookWorms(t *testing.T, a, b []BookWorm) bool {
	t.Helper()
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		// verify the name of the bookworm
		if a[i].Name != b[i].Name {
			return false
		}
		// verify the content of the collection
		if !equalBooks(t, a[i].Books, b[i].Books) {
			return false
		}
	}
	return true
}

// helper to test the equality of two maps
func equalBookCount(t *testing.T, got, want map[Book]uint) bool {
	t.Helper()

	if len(got) != len(want) {
		return false
	}

	for book, targetCount := range want {
		count, ok := got[book]
		if !ok || targetCount != count {
			return false
		}
	}
	return true
}
```

Keep higher occurrences -- now that have counted the number of copies of each book on every bookshelf., the next step is to loop over of them and keep those with more than 1 copy. At last just like:

```go
func main() {
	bookworms, err := loadBookworms("testdata/bookworms.json")
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "failed to load bookworms: %s\n", err)
		os.Exit(1)
	}

	commonBooks := findCommonBooks(bookworms)

	fmt.Println("Here are the books in common:")
	displayBooks(commonBooks)
}

// displayBooks prints out the titles and authors of a list of books
func displayBooks(books []Book) {
	for _, book := range books {
		fmt.Println("-", book.Title, "by", book.Author)
	}
}
```

## User logout

This brings us nicely to logging out a user. Implementing the user logout is straightforward in comparison to the signup and login -- essentially all we need to do is remove the `authenticationUserID`value from their session. At the same time it’s good practice to renew the session ID again, also add a flash message to the session data to confirm to the user that hey have been loggout -- like;

```go
func (app *application) userLogoutPost(w http.ResponseWriter, r *http.Request) {
	// Use the RenewToken() on the current session to change the session ID
	err := app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, err)
		return
	}

	// Remove the authenticationUserId from the session data so that the user is logged out
	app.sessionManager.Remove(r.Context(), "authenticatedUserID")

	// Add a flash message to the session to confirm to the user that they logged out.
	app.sessionManager.Put(r.Context(), "flash",
		"Your have been logged out successfully!")

	// redirect the user to the app home
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
```

### User authorization

Being able to authenticate the users of our app is all well and good, but now we need to do something useful with that info -- in this introduce some *authorization* checks so that -- 

1. Only authenticated users can create a new snippet and --
2. The contents of the navigation bar changes depending on whether a user is authticated or not. specially:
   - Authenticated users should see links to Home, Create...
   - Unauthenticated should see links to Home Signup...

Can check whether a request is being made by an authentiated user or not by checking for the existence of an `authentiatedUserID`value in their session data. Open the `helpers.go`file add an `isAuthenticated`helper to return the authentication status like -- 

```go
// Return true if the current request is from an authenticated user
func (app *application) isAuthenticated(r *http.Request) bool {
	return app.sessionManager.Exists(r.Context(), "authenticatedUserID")
}
```

Then can check whether or not the request is coming from an authenticated user by simply calling this `isAuthenticated()`helper -- the next step is to find a way to pass this info to our HTML templates -- so that we can toggle the contents of the navigation bar appropriately.

```go
type templateData struct {
	// ...
	IsAuthenticated bool
}
```

And the second step is to update our `newTemplateData()`helper so that this information is automatically like:

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
	return &templateData{
		CurrentYear: time.Now().Year(),
		Flash:       app.sessionManager.PopString(r.Context(), "flash"),
		// Add the authentication status to the template data
		IsAuthenticated: app.isAuthenticated(r),
	}
}
```

Once that is done, can update the `nav.html`file to toggle the navigation links just using the `{{.if .IsAuthenticated}}`action like:

```html
{{define "nav"}}
    <nav>
        <div>
            <a href="/">Home</a>
            {{if .IsAuthenticated}}
                <a href="/snippet/create">Create a new Snippet</a>
            {{end}}
        </div>

        <div>
            {{if .IsAuthenticated}}
                <form action="/user/logout" method="post">
                    <button>Logout</button>
                </form>
            {{else}}
                <a href="/user/signup">Signup</a>
                <a href="/user/login">Login</a>
            {{end}}
        </div>
    </nav>
{{end}}
```

#### Restricting access

As it stands, we are just hiding the navigation link for any user that isn’t logged in. But an au-authenticated user could still create a new snippet by visiting the `create`page directly.

Fix that -- so that if an unauthenticated user tries to visit any routes with the URL path the are just redirected to `/user/login`instead -- the simplest way to do so is via some middleware. So just like:

```go
func (app *application) requireAuthentication(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !app.isAuthenticated(r) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
			return
		}

		// otherwise, set the `Cache-Control: no-store` header so that pages
		// require authentication are not stored in the browser cache
		w.Header().Add("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}
```

Then add this middleware to our routes.go file to protecte specific routes. In our case, we will want to protect the `GET /snippet/create`and `POST /snippet/create`routes -- and there is no much point logging out a user if they are not logged in, so it makes sense to use it on the `POST /user/logout`as well. So need rearrange it like:

```go
func (app *application) routes() http.Handler {
    //...
    // protected (authenticated-only) app routes using a new protected middleware
	protected := dynamic.Append(app.requireAuthentication)

	router.Handler(http.MethodGet, "/snippet/create", protected.ThenFunc(app.snippetCreate))
	router.Handler(http.MethodPost, "/snippet/create", protected.ThenFunc(app.snippetCreatePost))
	router.Handler(http.MethodPost, "/user/logout", protected.ThenFunc(app.userLogoutPost))

	standard := alice.New(app.recoverPanic, app.logRequest, secureHeaders)

	// return the standard middleware chain followed by the servemux
	return standard.Then(router)
}
```

Without using alice -- If are not using the `justinas/alice`package to manage your middleware -- you can manually wrap your handlers like this old mode.

CSRF protection -- In this -- look at how to protect app from `cross-site`request forgery CSRF attacks. It’s a type of attack where a malicious sends a state-changing HTTP requests to your website. In this app, the main risk are: FORE:

- User logs, our session cookie is 12h, remain...
- The user then goes to a malicious website contain code sends a cross-site request to `/create`, add a new snippet to dbs. The session cookie will be sent along with this request.
- Cuz request includes the session cookie, our app will interpret the request as coming from a logged-user and it will process the request with taht user’s privileges.

As well as traditional CSRF attacks, your app may also be at rsik from *login and logout* CSRF attacks.

