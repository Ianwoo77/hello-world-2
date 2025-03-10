# Updating with `updateOne`

To update the fields of a single document in a collection, can use the function `updateOne`-- provided by Mdb collections, accepts a query condition to find the record to be updated, and the document that specifies the filed-level expressions.

```js
db.movies.updateOne(
	{title:'Macbeth'},
    {set:{'year:2015'}}
)

// modifying more than one field
// $set is provided with a document that contains the update expression
db.movies.updateOne(
	{title:'Macbeth'},
    {$set: {'type': 'movie', 'num_mflix_comments':1}}
)
```

`updateOne`function always updates only one document in the colleciton -- only the first will be modified.

#### `upsert`with `updateOne`

If the document is not found, a new document is created like:

```js
db.movies.updateOne(
	{'title': 'Sicario'},
    {$set: {'year': 2015}},
    {ussert: true}
)
```

And the `findOneAndUpdate`can use `sort`, `returnNewDocument`to project like:

```js
db.movies.findOneAndUpdate(
	{'title': 'Meacbeth'},
    {$set: {'num_mflix_comments':20}},
    {
        projection: {_id:0, 'num_mflex_commetns':1},
        'returnNewDocument': true
    }
)
db.movies1.findOneAndUpdate(
    {type: 'movie'},
    {$set: {'lastest': true}},
    {
        returnNewDocument: true,
        sort: {_id:-1}
    }
)
```

#### Update Operators

`$set, $inc, $mul`...

- `$rename`-- Is used to rename fields, the operator accepts a document containing pairs of names and their new names -- and if the field is not already present in the document, the opeator ignores and does nothing. Fore:

  ```js
  db.movies.findOneAndUpdate(
  	{'title': 'Macbeth'},
      {$rename: {'num_mflix_comments': 'comments', 'imdb_rating': 'rating'}},
      {'returnNewDocument': true}
  )
  ```

- `$currentDate`-- is used to set the value of a given field as the current date or timestamp -- like:

  ```js
  db.movies.findOneAndUpdate(
  	{'title':'Macbeth'},
      {$currentDate: {
          'created_date': true,
          'last_update.data': {$type: 'date'},
          'last_update.timestamp': {$type: 'timestamp'},
      }},
      {returnNewDocument: true}
  )
  ```

- `$unset`-- removing fields -- the `$unset`operator removes the given fields from a document. The operator accepts a document containing pairs of field names, and values and removes all the given from the matched document.

  ```js
  db.movies1.findOneAndUpdate(
      {title: 'Macbeth'},
      {$unset: {
          imdb_rating:1,
          }}
  )
  ```

- `$setOnInsert`-- similar to the `$set`, however, only sets the given fields when an insert happens during the `upsert`operation. Fore:

  ```js
  db.movies1.findOneAndUpdate(
  	{title:'Macbeth'},
      {
          $rename: {comments:'num_mflix_comments'},
          $setOnInsert: {'created_time': new Date()}
      },
      {
          upsert: true,
          returnNewDocument: true
      }
  )
  ```

### Updating with Aggregation Pipelines and Arrays

Learn how to perform some complex update operations using pipeline support-- using pipeline support, will be able to write a multi-step update expression and also refer to the values of the fields.

Begin this chapter with Mdb pipeline support -- where will brifely introduce the aggregation pipeline and how it helps U to perform more complex update operations.

WIth the release of Mdb 4.2, all of its update functions have started supporting aggregation pipelines -- Composed of multiple update expressions called stages -- when an update operation contianing multiple stages of updated expression is executed,  a pipeline is composed of multiple update expressions called *stages*. Fore the output of the first stage is input for the next stage,until the last stage in the pipeline produces the final output. Fore:

```js
db.collection.updateMany(
	<query condition>,
    [<update expression1, 2...],
    <options>
)
```

Noticed that the second argument to the function which specifies an update expression is now an array of multiple update expressions or stages -- the syntax is only valid if your Mdb version is 4.2 or later. If:

```js
db.users.insertMany([
    {_id:1, full_name: '...'},
    {_id:2, full_name: '...'}
]);
```

For this, both have an `_id`and `full_name`, composed of first and last name.. For this, will write an update command to split the fullname into the respective field of first and last name like:

```js
db.users1.updateMany({},
    [
        {$set: {'name_array': {$split: ['$full_name', ' ']}}},
        {$set: {'first_name': {$arrayElemAt: ['$name_array', 0]}}},
        {$set: {'last_name': {$arrayElemAt: ['$name_array', 1]}}},
        {
            $project: {
                'first_name': 1,
                'last_name': 1,
                'full_name': {
                    $concat: [{$toUpper: '$first_name'}, ' ', '$last_name']
                }
            }
        }
    ]);
```

For this the `updateMany()`operation is updating all the documents in the `users`collection. The second argument to the func is an array containing 3 stages -- `$set, $set, $project`.

Stage 1 -- Using the `$split`to split the full anme. Then gives us a two-element array containing the first name and the last name.

State 2-- refer the array stored in the `name_array`and create new fields for the first name and last name. To do so, use the `$arrayElemAt`on the name array to fetch its element from a specific index position.

Stage 3 -- explictly include the `first_name`and `last_name`fields and rewrite `full_name`by concatnating it in uppercase and `last_name`. The `$toUpper`operator refers to the value of `first_name`and returns the same string in uppercase. the `$concat`then accepts an array of strings and returns a single string by concatenating all the elements in the same order.

## Checking an error type and value accurately

```go
type transientError struct {
    err error
}
func (t transientError) Error() string {
    return fmt.Sprintf("transient error: %v", t.err)
}
func getTransientAmount(transactionID string) (float32, error) {
    if len(transactionID) != 5 {
        return 0, fmt.Errorf("id is invalid: %s", transactionID)
    }
    amount, err := getTransactionAmountFromDB(transacationID)
    if err != nil {
        return 0, transientError{err:err}
    }
    return amount, nil
}
```

Rewrite the HTTP handler that checks the error type to return the appropriate HTTP status code like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    transactionID := r.URL.Query().Get("transaction")
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        switch err := err.(type) {
        case transientError:
            http.Error(w, err.Error(), http.StatusServiceUnavailable)
        default:
            http.Error(w, err.Error(), http.StatusBadRequest)
        }
        return
    }
    // ... write response
}
```

However, assume that we want to perform a small refactoring of `getTransactionAmount`-- the `transientError`will be returned by `getTranactionAmountFromDB`instead of like:

```go
func getTransactionAmount(transactionID string) (float32, error) {
    // check ID
    amount, err := getTransactionAmountFromDB(transactionID)
    if err != nil {
        return -, fmt.Errorf("failed to get transaction %s: %w", transactionID, err)
    }
    return amount,nil
}
```

What `getTransactionAmount`returns isn’t a `transientError`directly -- it’s an error wrapping `transientError`-- therefore `case`is now false. For that purpose, Go 1.13 came with a directive to wrap an error and a way to check whether the wrapped error is of certain type with `errors.As`-- this recursivley unwraps an error and returns `true`if an error in the chain matches the expected type. For this:

```go
amount, err := getTransactionAmount(transactionID)
if err != nil {
    if errors.As(err, &transientError{}) {
        http.Error(w, err.Error(), http.StatusServiceUnavailable)
    }else {
        //...
    }
    return
}
```

Just get rid of the `switch case`type in this new version . And fore, defined a *global* variable like:

```go
import "errors"
var ErrFoo = errors.New("foo")
```

A sentinel error conveys an *expected* error, In SQL library -- want to design a `Query`method fore, allows to execute a query to a dbs. Returns a slice of rows -- When no rows found, have two options -

- Returns a sentinel value, fore `nil`
- A specific error that a client can check

In the STDLIB, there finds many examples -- 

- `sql.ErrNoRows`
- `io.EOF`-- return by an `io.Reader`when no more input is available.

For a general principle -- they convey an expected error that clients will expect check -- 

- Expected errors sohuld be designed as error values like `ver ErrFoo=errors.New(“foo”)`
- Unexpected should be designed as error types -- `type BarError struct {...}`

```go
// by using the ==
err := query()
if err != nil {
    if err == sql.ErrNoRows {
        //...
    }
}
```

However, just discussed, a sentinel error can also be wrapped so if an `sql.ErrNoRows`is wrapped using `fmt.Errorf`and `%w`directive, == will always be false. So just:

```go
err := query()
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {
        //...
    }
}
```

Using the `errors.Is`instead of `== `allows the comparison to work even if the error is wrapped using %w.

### Adapt the test with `Test<Function>`functions

Use a new convention of the testing package -- when testing a function with two or more different scenairos -- can write several functions -- `Test<FunctionName>_<ScenarioName>`-- like:

```go
func TestGeet_English(t *testing.T) {
    lang := language("en")
    want : = "hello"
    got := greet(lang)
    if get != want {
        t.Errorf("...")
    }
}
```

#### Introducing the Go map 

Previous tests were linear -- they just tested every language in a sequential way -- taken an input, call the `greet`and check the gretting for that language is the expected one -- this can be summed up in the following snippet of code that was executed for languages. For this logic:

```go
got := greet(language(lang))
if got != want {
    t.Errorf("...")
}
```

So just like:

```go
func TestGreet(t *testing.T) {
	type testCase struct {
		lang language
		want string
	}
	var tests = map[string]testCase{
		"english": {
			lang: "en",
			want: "Hello, World",
		},
		//.. for other languages
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			got := greet(tc.lang)
			if got != tc.want {
				t.Errorf("got %q, want %q", got, tc.want)
			}
		})
	}
}
```

for this, every test we want to run needs two values -- the language of the desired message, and the expected greeting message that will be returned by the `greet`function.

#### Using the `flag`package to read the user’s language

how can we use the input to get the user’s desired language of greeting -- Go provides support for parsing the command-line arguments in both the `os`and `flag`packages -- the format is like: --key=value, -key value, ...

```go
func main(){
    var lang string
    flag.StringVar(&lang, "lang", "en", "the required language")
    flag.Parse()
    greeting := greet(language(lang))
    fmt.Println(greeting)
}
```

#### Testing the CLI -- 

some examples here is an running of the main in Greek just like:

```sh
go run main.go -lang=el
```

### bookwork’s digest playing with loops and maps

A new chapter, Defining a JSON example -- And just note that there is a convention in Go by which any folder named `testdata`should contain -- data for testing -- the go tool will ignore a directory named `testdata`making it available to hold ancillary data needed by the tests.

Open a file -- 

```go
func loadBookworms(filePath string) ([]BookWorm, error) {
	return nil, nil
}
```

For this, in the case, the zero value of the slice of bookworms is `nil`, as is the zero value of the error interface. Go offers the platform-independent `os`package to operate system functionality, And inside the `os`, there is a `os.File`type providing ways to open a file for reading or writing, changing rights of a file, creating a new file and many other system operations you can perform on a file.

Differences between `os.Create os.Open, os.OpenFile`-- several functions return a file descriptor, and each one has its best usage.

`os.Create`creates a file with both read and write rights for all users 0o666 -- `os.OpenFile`is more generic. There are just two very specific cases in which it is useful -- append without discarding, second parameter is flag. When creating and appending -- `os.O_APPEND | os.O_CREATE|os.O_WRONLY`-- for appending or creating.

`defer`-- When are donw with I/O operations with a `*File`-- must close it by using the `Close`method on your file, this way, system rerources used by the file are released and you don’t create leaks with your program.

## Using signup and Pwd encryption

```html
{{define "title"}}Signup{{end}}

{{define "main"}}
    <form action="/user/signup" method="post" novalidate>
        <div>
            <label>Name:</label>
            {{with .Form.FieldErrors.name}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="name" value="{{.Form.Name}}">
        </div>

        <div>
            <label>Email:</label>
            {{with .Form.FieldErrors.email}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="email" value="{{.Form.Email}}">
        </div>

        <div>
            <label>Password:</label>
            {{with .Form.FieldErrors.password}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="password">
        </div>

        <div>
            <input type="submit" value="Signup">
        </div>
    </form>
{{end}}
```

Then need to update `cmd/web/handlers.go`file to include a new `userSignupForm`struct -- and hook it up to the `useSignup`handler like:

```go
func (app *application) userSignup(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userSignupForm{}
	app.render(w, http.StatusOK, "signup.html", data)
}
```

#### Validating the user input

When this form is submitted the data will end up being posted to the `userSignupPost`handler that we made -- the first task of this handler will be to validate the data to make sure that it is sane and sensible before we insert it into the dbs -- want to do 4 things -- 

- Check that the provided name, email...
- Sanity check the format of the email
- Ensure pwd is at least 8 characters long
- Make sure that the email address isn’t already in use.

Cover the first 3 checks by heading back to our `validator`module and creating two helpers -- `MinChars()`and `Matches()`-- like:

```go
func MinChars(value string, n int) bool {
	return utf8.RuneCountInString(value) >= n
}

func Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}
```

Then head over to `handlers.go`file and add some code to process the form and run the validation checks like So:

```go
func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
	// Declare an zero-based instance of our userSignupForm
	var form userSignupForm

	// parse the form data into the userSignupForm struct
	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// validate the form content using helper functions
	form.CheckField(validator.NotBlank(form.Name), "name",
		"this field cannot be blank")
	form.CheckField(validator.NotBlank(form.Email), "email",
		"This field cannot be black")
	form.CheckField(validator.Matches(form.Email, validator.EmailRX), "email",
		"This field must be valid format")
	form.CheckField(validator.NotBlank(form.Password), "password",
		"This field cannot be blank")
	form.CheckField(validator.MinChars(form.Password, 8), "password",
		"This field must be at least 8 characters long")

	// If there are any errors, redisplay the form along with 422
	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, http.StatusUnprocessableEntity, "signup.html", data)
		return
	}
	// for now, other placeholder
	fmt.Println(w, "Process the form...")
}
```

#### Brief introcuction to bcrypt

It’s just a good practice essential really - to store a one-way hash of pwd, derived wtih a computationally expensive key-derivation function such as Argon2, script or bcrypt. Go has just implemented of all 3 algs in the `golang.org/x/crypto`package.

```sh
go get golang.org/x/crypto/bcrypt@latest
```

There are two functions that use in this -- `bcrypt.GenerateFromPassword()`lets create a hash of a givne plain-text pwd like so -- 

```go
hash, err := bcrypt.GenerateFromPassword([]byte("my plain text password"), 12)
```

This just will return a 60-character long hash which looks like: some characters. The second parameter for this indicates the *cost* -- which is respresented by an integer between 4 and 31. 12 means 2^12= 4096 bcrypt iterations will be used to generate the pwd hash.

On the flip side, can check that a plain-text pwd matches a particular hash using the `bcrypt.CompareHashAndPassword()`function like so:

```go
hash := []byte(".....")
err := bcrypt.CompareHashAndPassword(has, []byte("original passwrod"))
```

So, `bcrypt.CompareHashAndPassword()`function will return `nil`if matches, or an error if don’t match.

#### Storing the user details

The next stage of our build is to update the `UserModel.Insert()`method so that it creates a new record in our `users`table containing the validated name, email, and hashed pwd... This will be interesting for two -- want to store the bcrypt hash of the pwd and also need to manage the potential error caused by duplicate email.

For this, all errors returned by MYSQL have a particular code. In the `users.go`file:

```go
func (m *UserModel) Insert(name, email, password string) error {
	// create a bcrypt hash of the plain-text pwd
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	if err != nil {
		return err
	}
	stmt := `INSERT INTO users (name, email, hashed_password, created) 
		VALUES(?, ?, ?, UTC_TIMESTAMP())`

	// use the `Exec()` method to insert the user details and hashed password
	// into the users table
	_, err = m.DB.Exec(stmt, name, email, string(hashedPassword))
	if err != nil {
		// if this returns an error, we use the errors.As() function to check
		// whether the error has the type *mysql.MySQLError. If does, error will be
		// assigned to the mySQLError, then check whether or not the error number is 1062
		var mySQLError *mysql.MySQLError
		if errors.As(err, &mySQLError) {
			if mySQLError.Number == 1062 && strings.Contains(mySQLError.Message,
				"users_uc_email") {
				return ErrDuplicateEmail
			}
		}
		return err
	}
	return nil
}

```

Then finish this all off by updating the `userSingup`handler like:

```go
func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
	// ... other code
	// Try to create a new user record in the dbs
	err = app.users.Insert(form.Name, form.Email, form.Password)
	if err != nil {
		if errors.Is(err, models.ErrDuplicateEmail) {
			form.AddFieldError("email", "Email address is already in use")
			data := app.newTemplateData(r)
			data.Form = form
			app.render(w, http.StatusUnprocessableEntity, "signup.html", data)
		} else {
			app.serverError(w, err)
		}
		return
	}

	// otherwise add a confirmation flash message and redirect to the login page
	app.sessionManager.Put(r.Context(), "flash",
		"Your signup was successful, Please Log in")
	http.Redirect(w, r, "/user/login", http.StatusSeeOther)
}
```

At this point, just users table -- should see a new record.