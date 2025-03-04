# Deleting Using `findOneAndDelete()`

Apart from the two delete methods, there is another function named `findOneAndDelete()`-- although it behaves similarly to the `deleteOne()`function, it provides a few more options -- 

- finds one and deletes it.
- If more than one, only the first will be deleted.
- Once deleted, it returns the deleted document as resp.
- In the case of multiple document matches, the `sort`option can be used to influence which document gets deleted.
- Projection can be used to include or exclude fields from the document in resp.

```js
db.new_movies.findOneAndDelete(
	{title: {$regex: /^movie/}},
    {sort: {_id: -1}, projection: {_id:0, title:1}}
)
```

#### Exercise -- deleting a low rated movie -- 

```js
db.movies.findOneAndDelete(
	{'imdb.rating': {$lt:2}, 'imdb.votes': {$gt:50000}},
    {sort: {'awards.won':1}, projection: {title:1}}
)
```

### Replacing Documents

Sometimes, may want to just replace an incorrect document in a collection, or often, the data stored in documents is changed over time -- or perhaps, to support your product’s new requirements, may want to alter the way your documents are structured or change the fields in your documents.

```js
db.users.replaceOne(
	{_id:5}, {name: "...", "email":...}
)
```

For this, the first arg is the query filter to identify the document to be replaced, and the second arg is the new document. The output just indicates that the gien query matched one document and one was updated. If there is more than one matches the query, then only the first one will be replaced.

#### `_id`Fields are immutable -- 

```js
db.users1.find ({name: "..."}, {_id:5, "name": "...", email:"..."})
```

This indicates that the `_id`of the original document is retained in the new document. This value cannot be changed again once assigned. However, if try modifying the field like this way;

```js
db.users1.replaceOne(
    {name:'Margery Baratheon'},
    {_id:6, name: 'Margery Baratheon', email: 'abc@abc.es'}
)
```

For this, executed a replace -- where the replace document now has an explicit `_id`.

#### Upserting using Replace

There will be times U want to replace an existing with a new one -- if the doc does not already exist, insert the new. In real-world scenarios, will mostly doing so in large numbers --  On a large-scale system, performing a two-step update or insert op for each of the records will be very time-consuming and error prone.

```js
// additional argument of `{upsert:true}`
db.users1.replaceOne(
    {name: 'Jon Snow II'},
    {name: 'Jon Snow', email: 'must_provide@es.es'},
    {upsert: true}
)
```

#### Replacing using `findOneAndReplace`-- 

The `findOneAndReplace`to perform the same operations -- it provides more options, its main features are:

- A `sort`option can be used to influence which document gets replaced if more than one document is matched.
- By default, returns the *original* document
- But, if `{retrunNewDocument:true}`specified, the newly added will be returned
- Field projection cna be used include only speciifc fields in the document.

Say, 5 movies, all having the same title, was released and inserted in different calendar years. And when these reords were originally inserted, the field for the year of release wasn’t added. Can use like:

```js
db.movies1.findOneAndReplace(
    {title: 'Macbeth'},
    {title:'Macbeth', latest: true},
    {
        sort: {_id: -1},
        projection: {_id:0}
    }
) // last _id replaced
```

The preceding confirms that the operation is successufl, and the `title`of the old document is just included in the response -- you can make use of `returnNewDocument`flag in the command like:

```js
db.movies1.findOneAndReplace(
    {title: 'Macbeth'},
    {title:'Macbeth', latest: true},
    {
        sort: {_id: -1},
        projection: {_id:0},
        returnNewDocument: true
    }
)
```

#### Replace vs. Delete and Re-Insert

There are dedicated functions to find and replace documents in a collection -- it is possible to replace a dcoument using a combination of delete and insert.

```js
let deletedDocument = db.movies.findOneAndDelete(...)
db.movies.insertOne(
    {
        _id: deletedDocument._id,
        title: 'Macbeth',
        lastest: true
    }
)
```

This re-inserts the same movie along with the `latest:true`. the two step operation executes two toally different commands.

## When to wrap an error

Since Go 1.13, the `%w`directive allows us to wrap errors conveniently, but some developers may be confused about when to wrap an error or not. Error wrapping is about wrapping or packing an error inside a wrapper container that also makes the source error avaialble... In both cases, the source error remains available -- hence, a caller can also handle an error by just unwrapping it and checking the source error. Also note that sometimes want to combine. Adding context and marking an error. Namely, instead of adding some context, want to mark the error -- want to implement an HTTP handler that checks whether all errors received whil calling func sare of a `Foribdden`type.

```go
func Foo() error {
    err := bar()
    if err != nil {
        //...
    }
}

// before 1.13 like;
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return "bar failed" + b.Err.Error()
}
// then instead of return err
func Foo() error {
    err := bar()
    if err != nil {
        return BarError{Err: err}
    }
}
```

The benefit of this option is flexibility -- cuz `BarError`is a custom struct, can add any additional context. Just like:

```go
if err != nil {
    return fmt.Errorf("bar failed: %w", err)
}
```

This code just wraps the source error to add additional context without having to create another error type. And cuz the source error remains available, a client can unwrap the parent and then check whether the source was of specific type or value. 

The last option is to use the `%v`like:

```go
if err != nil {
    return fmt.Errorf("bar failed: %v", err)
}
```

For this, a caller can’t unwrap this error and check whether the source are `bar error`. So, Wrapping an error makes the source error available for callers.

### Checking an error type accurately

It’s also essential to change our way of checking for a specific error type -- Fore, a DB operation -- our imp can fail in two cases - 

- If the ID is invalid - 400
- if query fails - 503 `ServiceUnavailable`

Create a `transientError`type to mark that error is temporary..

```go
type transientError struct {
    err error
}
func (t transientError) Error() string {
    return fmt.Sprintf("transient error: %v", t.err)
}
func getTransactionAmount(transactionID string) (float32, error) {
    if len(transactionID!=5) {
        return 0, fmt.Errorf("id is invalid: %s", transiactionID)
    }
    amount, err := getTransactionAmountFromDB(transactionID) 
    if err != nil {
        return 0, transientError{err: err}
    }
    return amount, nil
}
```

For this the `getTransactionAmount`returns an error using `fmt.Errorf`if the id is invalid. And if query fails, wraps the error into a `transientError`. Fore, have a handler like:

```go
func handler(h http.ResponseWriter, r *http.Request) {
    transactionID := r.URL.Query().Get("transaction")
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        switch err := err.(type) {
        case transientError:
            httl.Error(w, err.Error(), http.StatusServiceUnavailable)
        default:
            http.Error(w, err.Error(), http.StatusBadRequest)
        }
        return
    }
}
```

For this, using `switch`on the error type, return the appropriate HTTP status code -- This code is perfectly valid -- however, if want to perform a small refactoring of func. For this using `%w`directive.

```go
func getTransactionAmount(transactionID string) (float32, error) {
    // Check transaction ID validity
    amount, err := getTransactionAmountFromDB(transactionID)
    if err != nil {
        return 0, fmt.Errorf("failed to get transaction: %s, %w", 
                            transactionID, err)
    }
    return amount, nil
}

func getTransactionAmountFromDB(transactionID string) (float32, error) {
    if err != nil {
        return 0, transientError{err: err}
    }
}
```

If run the handler again, it always returns a 400 regardless of the error case. What `getTransactionAmount`returns isn’t a `transientError`directly -- it’s an error wrapping `transientError`, therefore `case`is now false. So need to write our imp of the caller using `errors.As`-- like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        if errors.As(err, &transientError{}) {
            http.Error(w, err.Error(), http.StatusServiceUnavailable)
        }else {
            http.error(w, err.Error(), http.StatusBadRequest)
        }
        return
    }
}
```

For this got rid of the `switch`in the new version, now use `errors.As` - its second arg to be a pointer.

### Supporting more language with a phrasebook

```go
type language string

// phrasebook holds greeting for each supported language
var phrasebook = map[language]string{
	"el": "Χαίρετε Κόσμε",     // Greek
	"en": "Hello world",       // English
	"fr": "Bonjour le monde",  // French
	"he": " שלום עולם ",       // Hebrew
	"ur": " ہیلو ",            // Urdu
	"vi": "Xin chào Thế Giới", // Vietnamese
}

func greet(l language) string {
	greeting, ok := phrasebook[l]
	if !ok {
		return fmt.Sprintf("unsupported language :%q", l)
	}
	return greeting
}

func main() {
	greeting := greet("el")
	fmt.Println(greeting)
}
```

Multiple return value -- see many occurrences of multiple value assignment, mostly in 4 common cases -- 

- Whenever want to know whether a key is present in a map, where we retreive the value, and the info of the presence of the key in the map.
- Whenever use the `range`, key-value
- whenever using `<-`operator, returns a value and whether the channel is closed.

#### Writing a table-driven test

Make use of *table-driven* tests to enhance the reusability and clarity of our test file, and the nice side-effect of shrinking it a lot.

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
		"French": {
			lang: "fr",
			want: "Bonjour le monde",
		},
		"Akkadian, not supported": {
			lang: "akk",
			want: `unsupported language: "akk"`,
		},
		"Greek": {
			lang: "el",
			want: "Χαίρετε Κόσμε",
		},
		"Vietnamese": {
			lang: "vi",
			want: "Xin chào Thế Giới",
		},
		"Empty": {
			lang: "",
			want: `unsupported language: ""`,
		},
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

For this, every test we want to run needs two values -- the language of the desired message, and the expected greeting message that iwll be returned by the function. In Go, the common way of writing a list of test cases is to use the `map`structure that will refer to each test case with a specific description key. Remember that this map associates description to a test case, hence the name of the variable like:

```go
for name, tc := range tests {
    t.Run(name, func(t *testing.T) {
        got := greet(tc.language)...
    })
}
```

#### Using the `flag`package to read the user’s language

Then how can se use the input to get the user’s desired language of greeting -- Go provides support for parsing command-line arguments in both the `os`and `flag`packages. For the `os`, is very close to C/C++’s handling of arguments -- got to access them by their position on the line... And the `flag`package offers supports of a variety of types-integers, float, time duration, strings and booleans.

The first we need to do when it comes to exposing a parameter on your command-line executable, is to give it a nice and short name. Here offer the user a choice fore:

```go
func main() {
	var lang string
	flag.StringVar(&lang, "lang", "en", "the required lang")
	flag.Parse()
	greeting := greet(language(lang))
	fmt.Println(greeting)
}
```

The `flag`package offers two very similar functions to read a string from the command-line. like:

```go
var lang string
flag.StringVar(&lang, "lang", "en", "the required language, e.g. en")

// create the pointer and returns it
lang := flag.String("lang", "en", "...")
```

## Creating a users model

Now that the routes are set up, need to create a new `users`dbs table and a dbs model to accessit:

```sql
CREATE TABLE users (
    id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password char(60) NOT NULL,
    created DATETIME NOT NULL
);

ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE (email);
```

There is a couple of things worth pointing out about this -- 

- The `id`is an autoincrementing integer and the PK for the table.
- The type of the `hashed_password`is `CHAR(60)`-- storing hashes of the user pwds in the dbs. Note that the hashed versions will always be exactly 60 characters long.
- Also added a `UNIQUE`constraint on the `email`and named it `users_uc_email`-- this ensures that won’t end up with two users how have the same email address.

#### Building the model in Go

Setup a model so that can easily wrok with the new `users`table -- followin the same pattern that used earlier in the book for modeling access to the `snippets`table. First define some error types -- 

```go
// ErrInvalidCredentials Add a new ErrInvalidCredentials error
// use this if a user tries to login with an incorrect email address or pwd
var ErrInvalidCredentials = errors.New("models: invalid credentials")

// ErrDuplicateEmail Add a new ErrDuplicateEmail error
var ErrDuplicateEmail = errors.New("models: duplicate email")
```

Then a new file like:

```go
// UserModel Also define a new UserModel for DI
type UserModel struct {
	DB *sql.DB
}

// Authenticate will use the Authenticate to verify whether a user exists with the
// given email address and password.
func (m *UserModel) Authenticate(email, password string) (int, error) {
	return 0, nil
}

// Exists will check if a user exists with the given ID.
func (m *UserModel) Exists(id int) (bool, error) {
	return false, nil
}
```

For the final stage is to add a new field in our `application`struct so that can make this model avaialble.

```go
type application struct {
	errorLog       *log.Logger
	infoLog        *log.Logger
	snippets       *models.SnippetModel
	users          *models.UserModel
	templateCache  map[string]*template.Template
	formDecoder    *form.Decoder
	sessionManager *scs.SessionManager
}
```

### User signup and pwd encryption

Can log in any users to our app then just the `signup.html`like:

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

Then update the `handlers.go`file to include a new `userSignupForm`struct.

```go
type userSignupForm struct {
	Name                string `form:"name"`
	Email               string `form:"email"`
	Password            string `form:"password"`
	validator.Validator `form:"-"`
}
func (app *application) userSignup(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userSignupForm{}
	app.render(w, http.StatusOK, "signup.html", data)
}
```

#### Validating the user input

When this form is submitted the data will end up being posted to the handler. And the first task to this handler will be to validate the data to make sure that is sane and sensible before insert it into dbs. Ensure that the pwd is at least 8 characters long. Can just cover the first 3 checks by heading back go the `valiator.go`file and creating two helper new methods -- `MinChars()`nad `Matches()`.

```go
var EmailRX = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")

func MinChars(value string, n int) bool {
	return utf8.RuneCountInString(value) >= n
}

func Matches(value string, rx *regexp.Regexp) bool {
	return rx.MatchString(value)
}
```

