# Clone a Fork from Github

A `clone`is jsut a full copy of a repository, including all logging and versions of file, after cloning -- then configue remotes, basically, have a full copy of a repository, whose `origin`are not allowed to makes changes to.

```sh
git remote -v
# see that the origin is set up to the original repository, also want to add our own fork
git remote rename origin upstream # rename remote to upstream
# then add a new origin like
git remote add origin "our-git"
```

Now for this git, have 2 remotes -- 

- `origin`-- owr own fork, where we have read and write access
- `upstream`-- the original, where we have just read-only access

### Git github send pull request

push changes to our github fork -- we have made a lot of changes to our local git -- new `push`them to `fork`.

```sh
git config --global credential.helper store
git push origin
```

## stack() and unstack()

Closely related to the `pivot()`method are the methods `stack()`and `unstack()`methods available on `Series`and `DataFrame`-- These methods are designed to just work together with `MultiIndex`object.

- `stack()`-- pivot a level of column labels, returning a `DataFrame`with in index with a new inner-most level of row labels.
- `unstack()`-- inverse of `stack`just producing a reshaped with a new inner-most level of column labels

Namely, `statk()`move column to index, and unstack move index to row.

```python
tuples = [
   ["bar", "bar", "baz", "baz", "foo", "foo", "qux", "qux"],
   ["one", "two", "one", "two", "one", "two", "one", "two"],
]
index = pd.MultiIndex.from_arrays(tuples, names=['first', 'second'])
df = pd.DataFrame(np.random.randn(8,2), index=index, columns=['A', 'B'])

# the stack() compresses a level in the df columns to produce a series, or a dataframe
df.stack().unstack()
stacked= df.stack()
stacked.unstack('second') # or just unstack(1)
```

Noticed that the `stack()`and `unstack()`methods implicitly sort the index levels involved.

```python
index = pd.MultiIndex.from_product([[2,1], ['a', 'b']])
df= pd.DataFrame(np.random.randn(4), index=index, columns=['A'])
# notice that the stack() and unstack() implicitly sort the index like:
all(df.unstack().stack()==df.sort_index()) # return True
```

### Multiple levels

May also stack or unstack more than one level at a time by *passing a list of levels*, in which case the end result is as if each level in the list were processed individually.

```python
columns = pd.MultiIndex.from_tuples(
    [
    ("A", "cat", "long"),
        ("B", "cat", "long"),
        ("A", "dog", "short"),
        ("B", "dog", "short"),
    ],
    names = ["exp", "animal", "hair_length"]
)
df = pd.DataFrame(np.random.randn(4,4), columns=columns)
df.stack(level=['animal', 'hair_length'])
```

And the list of levels can contain either level names or level numbers but not mixture of the two.

### Missing data

Unstacking can result missing values if subgroups do not have the same set of labels, by default, missing values will be replaced with the default fill value for that data type. And the missing values can be filled with a specified value with the `fill_value`argument.

```python
columns = pd.MultiIndex.from_tuples(
    [
        ("A", "cat"),
        ("B", "dog"),
        ("B", "cat"),
        ("A", "dog"),
    ],
    names=["exp", "animal"],
)

index = pd.MultiIndex.from_product(
    [("bar", "baz", "foo", "qux"), ("one", "two")], names=["first", "second"]
)

df = pd.DataFrame(np.random.randn(8,4), index=index, columns=columns)
df3 = df.iloc[[0,1,4,7], [1,2]]
df3.unstack(fill_value=-1e9)
```

### melt() and wide_to_long()

Are useful to massage a DF into a formt where one or more columns are identifier variables. While all other columns considered measured variables, are unpivoted to the row axis, leaving just two non-identifier columns, just `variable `and `value`-- the names of those columns can be customized by supplying `var_name`and `value_name`parameters like:

```python
cheese = pd.DataFrame(
    {
        "first": ["John", "Mary"],
        "last": ["Doe", "Bo"],
        "height": [5.5, 6.0],
        "weight": [130, 150],
    }, 
    index=pd.MultiIndex.from_tuples([("person", "A"), ("person", "B")])
)
cheese.melt(id_vars=['first', 'last'])
```

And, `wide_to_long()`is just similar to `melt()`wtih more customization for column matching -- like:

```python
dft = pd.DataFrame({
        "A1970": {0: "a", 1: "b", 2: "c"},
        "A1980": {0: "d", 1: "e", 2: "f"},
        "B1970": {0: 2.5, 1: 1.2, 2: 0.7},
        "B1980": {0: 3.2, 1: 1.3, 2: 0.1},
        "X": dict(zip(range(3), np.random.randn(3))),
}
)
dft['id']=dft.index
pd.wide_to_long(dft, ['A', 'B'], i= 'id', j='year') # A B for columns, and i j for index
```

### explode()

FOr a DF column with nested, list-like valus, `explode()`will transform each list-like vlaue to be a separate row. The resulting `Index`will be duplicated corresponding to the index lable from the original row.

```python
df[['value1', 'value2']]=pd.DataFrame(df['values'].to_list(), index=df.index)
```

## Using Request Context

At the moment our logic for authenticating a user consists of simple check whether a `authenticationUserId`value exists in their session data just like:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
    return app.session.Exists(r, "authenticationUserId")
}
```

could make this more robust by checking our users dbs table to make sure that the `authenticationUserId`value is valid, and that the user account it relates to is still active, there is a slight problem with this addition check -- The helper can be called multiple times in each request cycle -- currently use twice, once in the `requireAuthentication()`and in the `addDefaultData()`helper.

A better approach would be to carry out this check in just some middleware t determine whether the current request is from an `authenticated-and-active`user or not. And then pass this info down to all subsequent handlers in the action. 

- What request context is, how to use, and when to appropraite to use that
- how to use request context in practice to pass info about the current user between your handlers.

### How Request Context Works

Every `http.Request`that our handlers process has a `context.Context`object embedded in it. Which can use to just store info during the lifetime of the request. In a web app a common use-case for this is to pass info between your pieces of middleware and other handlers. Just want to use it to check if a user is *authenticated-and-active* once in some middleware, and if they are, then make this info available to all our other middleware and handlers.

The request Context syntax-- The basic code for adding info to a request’s context looks like:

```go
// Where r is a *httpRequest
ctx := r.Context()
ctx = context.WithValue(ctx, "isAuthenticated", true)
r = r.WithContext(ctx)
```

- First, just use the `r.Context()`to retrieve the *existing context* for a request and assign it to the `ctx`variable.
- Then use the `context.WithValue()`method to create a new copy of the existing context, containing the key `isAuthenticated`and a value of `true`.
- Finaly use the `r.WithContext()`to create a `copy`of the request contiaing our new context.

IMPORTANT -- Note that we don’t actually update the context for a request directly -- what doing is just creating a *copy* of the `http.Request`object with our new context in it.

Should also point out -- for clairty, made that code snippet a bit more verbose just like:

```go
ctx = context.withValue(r.Context(), "isAuthenticated", true)
r = r.WithContext(ctx)
```

The important thing to explain here is that -- behind the scenes, request context values are stored with the type `interface{}`-- and that means that after retrieving them from the context, you will need assert them to their original type before U use them. like:

```go
isAuthenticated, ok := r.Context().Value("isAuthenticated").(bool)
if !ok {
    return errors.New("Could not convert value to bool")
}
```

### Avoiding key collisions

In the code, used the `isAuthenticated`as the key for storing and retrieving the data from a request contxt, but this isn’t recommended -- cuz there is a risk that other 3rd-party packages used by your application will also want to store data using the key `isAuthenticated`. and that would cause a naming collision and bugginess. To avoid this, it’s good practice to create your own custom type which can use for your context keys -- extending your sample code like:

```go
type contextKey string
const contextKeyIsAuthenticated = contextKey("isAuthenticated")

ctx := r.Context()
ctx = context.WithValue(ctx, contextKeyIsAuthentiated, true)
r = r.WithContext(ctx)

isAuthenticated, ok := r.Context().Value(contextKeyIsAuthenticated).(bool)
if !ok {
    return errors.New("could not covert the value to bool")
}
```

### Request for Context for Authentication/Authorization

So with those epanations out of the way use the request context functiaonlity in app -- begin at:

```go
func (m *UserModel) Get(id int) (*models.User, error) {
	u := &models.User{}
	stmt := `SELECT id, name, email,created, active from users where id=?`
	err := m.DB.QueryRow(stmt, id).Scan(
		&u.ID, &u.Name, &u.Email, &u.Created, &u.Active)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, models.ErrNoRecord
		} else {
			return nil, err
		}
	}
	return u, nil
}
```

Then `cmd/web/main`file and define your own custom `contxtKey`type and contextKeyIsAuthenticated variable.

```go
type contextKey string
const contextKeyIsAuthenticated=contextKey("isAuthenticated")
```

And now for the exxicting -- create a new `authenticate()`middleware which fetches the user’s ID from their session data -- checks the dbs to see if the ID is valid and for an active user, then updates the request context to include this info just like:

```go
func (app *application) authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// check if an authenticatedUserId value exists in the session
		exists := app.session.Exists(r, "authenticationUserId")
		if !exists {
			next.ServeHTTP(w, r)
			return
		}

		// Fetch the details of the current user from the dbs if no matching, or
		// current is has been deactivated, remove the value from their session
		user, err := app.users.Get(app.session.GetInt(r, "authenticationUserId"))
		if errors.Is(err, models.ErrNoRecord) || !user.Active {
			app.session.Remove(r, "authenticationUserId")
			next.ServeHTTP(w, r)
			return
		}

		// otherwise, we know the request is coming from a active, authenticated
		// user -- create a new copy of the request, with a true boolean value
		// added to the request context to indicate this.
		ctx := context.WithValue(r.Context(), contextKeyIsAuthenticated, true)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
```

For this middleware, the important thing to emphasize here is the following difference -- 

- When we don’t have an authenticated-and-active user, pass the original and unchanged `http.Request`to the next handler in the chain.
- When do have an authenticated-and-active user, create a copy of the request with a `contextKeyIsAuthenticated`key and `true`value stroed in the request context, then pass this copy of the `*http.Request`to the next handler in the chain.

Need to update routes.go file to include the `authenticate()`middleware in our dynamic middleware chain like:
`	dynamicMiddleware := alice.New(app.session.Enable, app.authenticate)`

The last need to do is just update our `isAuthenticated()`helper, so that instead of checking the session data it now checks the request context to determine if a user is authenticated or not.

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	isAuthenticated, ok := r.Context().Value(contextKeyIsAuthenticated).(bool)
	if !ok {
		return false
	} else {
		return isAuthenticated
	}
}
```

It’s just important to point out here that there isn’t a value in the context with the key, or the underlying vlaue isn’t `bool`then this type assertion will fail.

## When to use Channels or mutexes

Given a concurrency problem, it may not always be clear whether we can implement a solution using channels or mutexes -- Cuz Go promotes sharing memory by communication -- one mistake could be always for the user of channels, regardless of the use case. However, we should see the two options as complementary -- this session clarifies when we should favor one optoin over the other. The goal is not to discuss every possible use case. But just give general guidelines that can help use decide.

First, a brief remainder about channels in Go -- channels are a communication mechanism -- internally, a channel is a pipe can use to send and recevie values and that allows us to conenct concurrent goroutines -- a channel can be either of the following -- 

- unbufferred -- blocks untile the receiver is ready
- Buffered -- The sender blocks only when the buffer is full.

In general, parallel have to sync -- fore, when need to access or mutate a shared resource such as a slice. In general, synchornization between parallel goroutines should be achieved via mutexes. Concurrent goroutines have to coordinate and orchestrate.

### Race Conditions

data races occur when two or more goroutines simultaneously access the same memory location and at least one is writing -- an example where two goroutines increment a shared variable like:

```go
i := 0
go func() {i++}()
go func() {i++}()
```

if run : go run -race -- warns us that a data race has occurred.

For this, Atomic operations can be done in go using `sync/atomic`package -- an example of how we can increment atomically an `int64`like:

```go
var i int64
go func(){atomic.AddInt64(&i, 1)}()
go func(){atomic.AddInt64(&i, 1)}()
```

Both goroutines update `i`automatically. And there is anothe option is to sync the two goroutines with an `ad hoc`data structure like a mutex -- stands for *mutual exclustion* -- a mutex ensures that at most one goroutine accesses a so-called critical section -- in go `sync`provkdes a `Mutex`type like:

```go
i:=0
mutex := sync.Mutex{}
go func() {
    mutex.Lock()
    i++
    mutex.Unlock()
}()
```

Incrementing `i`is the criterial section -- regardless of the goroutine’s ordering, this example also produces a deterministic value.

Which approach -- the boundary is pretty straightforward -- the `sync/atomic`works only with specific types. Another possible option is to prevent sharing the same memory location and instead favor communication acorss the goroutines. Like create a channel like:

```go
i := 0
ch := make(chan int)
go func() {
    ch <- 1
}()
go func(){
    ch <- 1
}()
i += <-ch
i += <-ch
```

For this, each goroutine sends a notification via the channel that we should increment i by 1. The parent collects the notifications and increments i.