# Updating Array Fields

In the previous sections, learned about updating fields in one or more MDB documents -- we also leaned how to write update expressions uing various operators and how to use Mdb pipeline support. Just like:

```js
db.users1.updateMany({},
  {
    [
    {$set: {'name_array': {$split: ['$full_name', ' ']}},
    },
    {$set: {
        'first_name': {$arrayElemAt: ['$name_array', 0]},
        'last_name': {$arrayElemAt: ['$name_array', 1]},
    }},
    {$project: {
        'first_name': 1,
        'last_name': 1,
        'full_name': {$concat: ['$first_name', ' ', '$last_name']}
    }}
    ]
})
```

The document fore, has a `title`field and does not contain an array, try creating one like:

```js
db.moves1.findOneAndUpdate({_id: 111},
                          {$set: {'genre': ['unknown']}},
                          {returnNewDocument: true})
```

#### Adding elements to Arrays

```js
// 1. insert a single document, add the following:
db.movies1.findOneAndUpdate({_id:111},
    {$push: {'genres': 'unknown'}},
    {'returnNewDocument': true, upsert: true})

db.movies1.find()
// After that, the genre array fields is created successfully like:
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$push: {
        'genres': {$each: ['History', 'Action']}
        }},
    {returnNewDocument: true}
)
```

For this, the document in the response indicates that both the elements are correctly appended to the end of the array and are added in the same order.

#### Sort Array

Are ordered but unsorted collection of elements -- in other words, the elements of the array will always remain the oreder in which they were inserted. However, while executing an update command with `$push`, can also sort an array.

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$push: {'genres': {$each:[], $sort:1}}},
    {returnNewDocument: true}
)
```

For this, used the `$push`in the `genre`field. one thing to note is that this query is not pushing any element to the array cuz there are no elements to provides to the `$each`operator. For this, sorted it without adding an element, but can also perform the sort while be sorted on the given sort order. like:

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$push: {'genres': {$each: ['Crime'], $sort: -1}}},
    {returnNewDocument: true}
)
```

For this, passed a new element, and note that the `$sort`operator value of -1. As can see from the response, the array is sorted in descending order and the new lement, `Crime`is part of the `genres`. Then, If have an array of objects that contains multiple fields like: Just like:

```js
db.items.findOneAndUpdate(
    {_id: 11},
    {$push: {
        items: {$each: [], $sort: {'price': -1}}
        }},
    {returnNewDocument: true}
)
```

### As array as a Set

An array is an ordered collection of elements that can be iterated over or accessed using its specific index position. A set is a collection of unique elements whose order is not guaranteed, Mdb supports only plain arrays and no other types of collections. May want your array to contain unique elements only -- Provides a way to do that by using the `$addToSet`operator -- with the only difference with `$push`is that an element will be pushed only if it is not unique elements are pushed into it. like:

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$addToSet: {genres: 'Action'}},
    {returnNewDocument: true}
)
```

As can see in the preceding -- the `Action`element was not pushed to the array cuz the array already contains it. The same behavior is evident even when use `$each`topush like:

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$addToSet: {genres: {$each: ['Action', 'Thriller']}}},
    {returnNewDocument: true}
)
```

The modified document confirms that only the new genre `Thriller has been added to the array.

#### Exercise -- New Category of Classic Movies -- 

Fore, wants to assign all those movies in to dbs to a new genre, called `Classic`-- For the task is to put a filter on the meter field in both like;

```js
db.movies.updateMany(
    {
        'tomatoes.viewer.meter': {$gt: 95},
        'tomatoes.critic.meter': {$gt: 95}
    },
	// create an update expression to add a new genre called `Classic`to all matching movies
    {
        $addToSet: {'genres': 'Classic'}
    }
)
```

Then to verify, write a `find`using the same condition and project the esseitenial fields with the following like:

```js
db.movies.find(
    {
        'tomatoes.viewer.meter': {$gt: 95},
        'tomatoes.critic.meter': {$gt: 95}
    },
    {
        _id:0,
        title:1,
        genres:1
    }
)
```

And the output indicates that all the movies now have the new genre -- `Classic`-- in this used the concept of sets of business use case.

### Removing Array elements

For this, have various means of adding elements to an array and sorting an array using various opertors. Mdb also provides the means of removing elements from arrays -- in this, go though different operators that allow U to remove all or specific elements from an array like:

#### Removing first or last element

The `$pop`operatror -- when used in an update command, allows you to remove the first or last element in an array -- it removes one element at a time and can only be used with the vlaues 1 or -1(1 for last, -1 fir the first).

```js
db.movies1.find();
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$pop: {'genres': 1}},
    {returnNewDocument: true}
)
```

For this makes use of `$pop`on the `genre`field with the value 1, will remove the last element from the array. For use -1 just remove the last element.

#### Removing all Elements

When U only need to remove certain elements from an array, Can use the `$pullAll`operator -- to do so, provide one or more elements to the operator. Just like:

```js
db.movies.findOneAndUpdate(
    {_id:111},
    {$pullAll: {'genre': ['Action', 'Crime']}},
    {returnNewDocument: true}
)
```

Can see that the specified genres, `Action`and `Crime`are now removed from the underlying array.

## When to use Channels or Mutexes

Given a concurrency problem -- may not always be clear whether we can implement a solution using channels or mutexes. Cuz Go promotes sharing memory by communication, one mistake could be always force the use of channels, regardless of the use case. First a brief reminder about channels in Go -- channels are a communication mechansim, internally, a channel is a *pipe* we can use to send and receive values and allows us to connect concurrent goroutines -- a channel can be either of the following -- *unbuffered* and *buffered*. Fore:

- G1 and G2 are parallel goroutines. Fore, two executing the same function that keeps receiving messages from channel, or perpaps two goroutines executing the same HTTP handler at the sam time.
- G1 and G3 as are G2 and G3 -- are concurrent goroutines. G3 does the next step.

In general, parallel goroutines have to *synchroinize*, fore, when need to access or mutate a shared resource fore, slice. Sync is enfored with mutexes but not with any channel types.

Conversely, in general, concurrent goroutines have to *coordinate* and *orchestrate* -- fore, if G3 needs to aggregate results from both G1 and G2, then G1 and 2 need to signal to G3 that a new intermediate result is available.

Regarding concurrent goroutines, there is also the case where we want to transfer the ownership of a resource from one step to another. Should use channels to signal that a specific resource is ready and handle the ownership transfer.

### Understanding race problems

Race problems can be among the hardest and most insidious bugs  -- Must understand crucial aspects such as d*ata races and race conditions*.

#### Data races vs. race conditions

```go
i:=0
go func() {i++}()
go func() {i++}()
```

If run, the Go race detector `-race`option it warns us that the data race has occurred. For this, the first goroutine reads, increments, and writes back, then second performs the same set of actions but starts from 1 -- However, here is no guarantee that the first goroutine will either start or complete before the second one in the previous. This is a possible impact of a data race -- if two goroutines simultaneously access the same memory location with at least one writing to that memory location, the result can be hazardous.

The first option is to make the increment operation atomic -- like:

```go
var i int64
go func() {atomic.AddInt64(&i, 1)}()
go func() {atomic.AddInt64(&i, 1)}()
```

Both goroutines update `i`automatically -- an atomic operation can’t be interrupted, thus preventing two accesses at the same time. Thus preventing two accesses at the same time. Then can use mutex. And another is using channel like:

```go
i := 0
ch := make(chan int)
go func() {
    ch <- 1
}()
go func() {
    ch <- 1
}()
i += <-ch
i += <-ch
```

For this, each goroutine sends a notification via the channel that we should increment i by 1. Cuz it’s the only goroutine writing to `i` -- this solution is also free of data races.

Instead of having two goroutines increment a shared variable, now each one makes a assignment like -- not that will follow the approach of using a mutex to prevent data races -- like:

```go
i := 0
mutex := sync.Mutex{}
go func() {
    mutex.Lock()
    mutex.Unlock()
    i = 1
}()
go func() {
    //...
    i = 2
}()
```

For this, there is not a data race -- both just access the same variable, But this example is not deterministic. But it has a *race condition* -- A race condition occurs when the behavior depends on the sequence or the timing ove events can’t control. for this example, the timing of events is the goroutine’s execution order. So, should find a way to guarantee that the goroutines are executed in order.

A *data race* occurs when multiple goroutines simultaneously access the same memory location and at least one of them is writing, however a data-race-free app doesn’t necessarily mean deterministic results. An app can be free of data races but still have behavior that depends on oncontrolld events - this is a race condition.

#### Go memory model

The Go memory model is a specifiction that defines the conditions under a read from a variable is one groutine can be guaranteed to happen after a write to the same variable in a diffrent goroutine. It provides guarantees that developers should keep in mind to avoid data races and force deterministic output.

```go
// the exit of goroutine isn't guaranteed
i := 0
go func() {i++}()
fmt.Println(i)
```

And a *send on a channel happens before* the corresponding receive from that channel completes. 

```go
// a parent goroutine increments a variable before a send
// while another goroutine reads it after a channel read
i := 0
ch := make(chan struct{})
go func() {
    <-ch // 3
    fmt.Println(i) //4
}()
i++ // 1
ch <- struct{}{} //2
```

And, Closing a channel happens before a receive of this closure -- like:

```go
i := 0
ch := make(chan struct{})
go func() {
    <-ch  // 3
    fmt.Println(i)
}()
i++ //1
close(ch) // 2
// This is also free from data races
```

A receive from an unbuffered happens before send on that channel completes.

```go
i := 0
ch := make(chan struct{}, 1)
go func() {
    i = 1
    <-ch
}()
ch <-struct{}{}
fmt.Println(i) // data race occurred.
```

Changing the channel type to unbuffered, makes this example data-race-free.

### Test it

How do we make sure that this is going to work after future changes -- The `testdata`is a folder is the perfect place to hold various Json files with our different test cases. Are going to test an internal function that lies in the `bookworm.go`file, and for this reason, will call `bookworks_internal_test.go`and write a test for that func. Step is to define the required parameters and returned value for our function. 

And each test case could be the purpose of a different function, but this stragegy is rarely extendable. Use a `map`like:

```go
type testCase struct {
    bookwormsFile string
    want []Bookworm
    wantErr bool
}
tests := map[string] testCase {...}
```

```go
var (
    handmaidsTale = Book{Author: "Margaret Atwood", Title: "The Handmaid's Tale"}
    oryxAndCrake  = Book{Author: "Margaret Atwood", Title: "Oryx and Crake"}
    theBellJar    = Book{Author: "Sylvia Plath", Title: "The Bell Jar"}
    janeEyre      = Book{Author: "Charlotte Brontë", Title: "Jane Eyre"}
)

func TestLoadBookworms_Success(t *testing.T) {
    type testCase struct {
       bookwormsFile string
       want          []BookWorm
       wantErr       bool
    }

    tests := map[string]testCase{
       "file exists": {
          bookwormsFile: "testdata/bookworms.json",
          want: []BookWorm{
             {Name: "Fadi", Books: []Book{handmaidsTale, theBellJar}},
             {Name: "Peggy", Books: []Book{oryxAndCrake, handmaidsTale, janeEyre}},
          },
          wantErr: false,
       },
        // this is the first unhappy path
       "file doesn't exist": {
          bookwormsFile: "testdata/file_does_not_exist.json",
          want:          nil,
          wantErr:       true,
       },
        // a second one
       "Invalid JSON": {
          bookwormsFile: "testdata/invalid.json",
          want:          nil,
          wantErr:       true,
       },
    }

    for name, tc := range tests {
       t.Run(name, func(t *testing.T) {
          got, err := loadBookworms(tc.bookwormsFile)
          if tc.wantErr {
             if err == nil {
                t.Fatal("expected err, got nothing")
             }
             return
          }

          // for this aren't expecting errors
          // should be the happy path
          if err != nil {
             t.Fatalf("expected no error, got %v", err)
          }
          if !equalBookWorms(t, got, tc.want) {
             t.Errorf("got %v, want %v", got, tc.want)
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

func equalBooks(t *testing.T, a, b []Book) bool {
    t.Helper()
    if len(a) != len(b) {
       return false
    }
    for i := range a {
       if a[i] != b[i] {
          return false
       }
    }
    return true
}
```

Go through all the bookworm’s shelves, register books we find there, and then filter on those that appear more than once -- will write a function for that `findCommonBooks`. like:

```go
func findCommonBooks(bookworms []BookWorm) []Book {
    return nil
}
```

So, how do we know that a book appears multiple times on shelves -- need to count the number of occurrences of each book on all the bookworm’s shelves.

## User Login

In this, going to focus on creating the user login page for our app --  Before get into the main part to work -- just for the `internal/validator`package that we made earlier and update it to support validation errors which aren’t associated with one specific form field. Use this later to show the user a geneirc *your email or pwd is wrong* message if login fails.

```go
package validator
type Validator struct {
    NoFieldErrors []string // hold validation errors which are not related to a specific field.
    FieldErrors map[string]string
}

func (v *Validator) Valid() bool {
    return len(v.FieldErrors)==0 && len(v.NonFiledErrors)==0
}

func (v *Validator) AddNonFieldError(message string) {
    v.NonFieldErros = append(v.NonFieldErrors, message)
}
```

Then define the html file contain the login logic.

```html
{{range .Form.NonFieldErrors}}
<div class="error">
    {{.}}
</div>
{{end}}
```

Then need to create a new `userLoginForm`struct just represent and hold the form data. Like:

```go
package main

// create a new userLoginForm struct
type userLoginForm struct {
    Email string `form:"email"`
    Password string `form:"password"`
    validator.Validator `form: "-"`
}

// update the handler so it displays the login page like:
func (app *application) userLogin(w http.ResponseWriter, r *http.Request) {
    data := app.newTemplateData(r)
    data.Form = userLoginForm{}
    app.render(w, http.StatusOk, "login.html", data)
}
```

#### Verifying the user details

The next step is -- how do we verify that the *email* and pwd submitted by a user are correct -- The core part of this verification logic will take place in the `UserModel.Authenticate()`method of our user model -- need to do two things -- 

1. Fist it should retreive the hashed pwd associated with the email address from our `users`table, If the email doesn’t exist in the dbs, or it’s for user that has been deactivated, will return the `ErrInvalidCredentials`error that made earlier.
2. Otherwise, want to compare the hashed from the `users`with the plain-text pwd that the user provdied when logging in. Also want to return the `ErrInvalidCredentials`error -- like:

```go
// Authenticate will use the Authenticate to verify whether a user exists with the
// given email address and password.
func (m *UserModel) Authenticate(email, password string) (int, error) {
	// retrieve the id and hashed pwd associated with the given email
	var id int
	var hashedPassword []byte
	stmt := "SELECT id, hashed_password from users where email=?"
	err := m.DB.QueryRow(stmt, email).Scan(&id, &hashedPassword)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, ErrInvalidCredentials
		} else {
			return 0, err
		}
	}

	// Check whether the hashed pwd and plain-text pwd match
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return 0, ErrInvalidCredentials
		} else {
			return 0, err
		}
	}

	// otherwise, the password is correct, return the user id
	return id, nil
}
```

Our next step involves updating the `userLoginPost`handler so that it parses the submitted login. like:

```go
func (app *application) userLoginPost(w http.ResponseWriter, r *http.Request) {
	// Decode the form data into the userLoginForm
	var form userLoginForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// do some validation checks on the form, check both email and password
	// are provided, and also check the email UX-nicely
	form.CheckField(validator.NotBlank(form.Email),
		"email", "This field cannot be blank")
	form.CheckField(validator.Matches(form.Email, validator.EmailRX),
		"email", "This field must be a valid email address")
	form.CheckField(validator.NotBlank(form.Password),
		"password", "This field cannot be blank")

	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, http.StatusUnprocessableEntity, "login.html", data)
		return
	}

	// Check whether the credentials are valid
	// if not, add a generic non-field errors message
	id, err := app.users.Authenticate(form.Email, form.Password)
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.AddNonFieldError("Email or password is incorrect")
			data := app.newTemplateData(r)
			data.Form = form
			app.render(w, http.StatusUnprocessableEntity, "login.html", data)
		} else {
			app.serverError(w, err)
		}
		return
	}

	// use the RenewToken() on the current session to change the session Id
	// fore, it's a good practice to generate a new session ID when the authentication
	// state or privilege levels changes for the user
	err = app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, err)
		return
	}
	// Add the ID of the current user to the session so they are now "logged in"
	app.sessionManager.Put(r.Context(), "authenticatedUserID", id)
    
	// redirect
	http.Redirect(w, r, "/snippet/create", http.StatusSeeOther)
}
```

For this, but when you input some correct credientials, the application should log in and redirect U to the create snippet page.

We have covered quite a lot of ground -- 

- Users can now *register* with the site using the `GET /user/signup`form, store the details of registered users in the `users`table of our dbs.
- Registered users can then *authenticate* using the `GET /user/login`form to provide their email address and pwd.

#### User logout

This brings nicely to logging out a user -- implementing the user logout is just stragintforward in comparision to the signup and login -- essentially all we need to do is remove the *authenticationUserID* from the session. At the same time -- it’s good practice to renew the session ID again, and will also add a flash message to the session data to confirm to the user that they have been logged out.