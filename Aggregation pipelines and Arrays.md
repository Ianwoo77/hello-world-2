# Aggregation pipelines and Arrays

How to perform some complex update operations using pipeline support. Will be able to write a multi-step update expression and also refer to the values of other fields. And covers the updating of array fields in documents, involves adding to array..

For more complex update operations using the aggregation pipeline support, and learn how to modify arrays in a documents. A pipeline is composed of multiple update expression called stages -- when an update operating containing multiple stages of update expressions is exuected, each of matched document is processed and transformed through each stage sequentially. The output of the first stage is input for the next stage.

The following code shows the syntax for using aggregation pipelines in `UpdateMany`just like:

```js
db.collection.updateMany(
	<query condition>,
    [<update expression1>, <update expression2>, ...],
    <options>
)
```

The second argument to the function which specifies an update expression, is now an array of multiple update expressions or stages. This synax is valid if mdb is 4.2+. Fore:

```js
db.uses1.insertMany(
    [
        {_id: 1, full_name : "Arya Stark"},
        {_id: 2, full_name : "Khal Drogo"}
    ]
)

db.users1.updateMany(
    {},
    [
        {
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

Here the `updateMany()`operation is updating all the document in the `users`collection -- the second argument to the function ia an array containing 3 stages -- `$set, $set`and `$project`.

`$set: {"name_array": {$split: ["$full_name", " "]}}`-- in this stage, using the `$split`operator to split the full name with a white space,  give us a two-element array containing the first name and last name -- are also creating a new filed of `name_array`using the `$set`operator and assigning the newly created array to. Note that -- `name_array`is a temporary field for us.

Then in the stage 2, refer to the array and create new fields for the first name and last name -- use `$arrayElemAt`on the name array to fetch its element from sepcific index position. A new field called `first_name`created.

`$project`stage project fields explicit include the first_name and `last_name`and rewrite the `full_name`

### Updating Array fields

Will learn about updating array fields from a document -- To try some basic update operation on array fields, will insert the following document into the `movies`like:

```js
db.movies1.insertOne(
    {_id:111, title: 'Macbeth'}
)

db.movies1.find()

db.movies1.findOneAndUpdate(
    {_id:111},
    {$set: {'genre': ['unknown']}},
    {returnNewDocument: true}
)
```

This just uses the `$set`in the `genre`field and the value of `genre`is a single-element array - `[‘unknown’]`. Next, just remove that like:

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$unset: {'genre': ''}},
    {returnNewDocument: true}
)
```

The output just indicates that the field is correctly removed from the document.  From these two examples, it is clear that when an array field is being updated using array as a values, it is treated just like any other field.

#### Adding Elements to Arrays

In this, just add elements to array using:

```js
// 1. to insert a single document, add:
db.movies1.findOneAndUpdate(
    {_id:111},
    {$push: {'genre': 'unknown'}},
    {returnNewDocument: true}
)
// 2. genre array field is created successfully, and the given element is added to the array
{$push:{'genre': 'Drama'}}
```

Adding multiple elems -- `$push`can just add one element at a time -- to add multiple elements to an array in a sinle update command, use `$push`along with `$each`like:

`$push: {<field_name>: {$each: [<elem1, elem2]}}`-- The elements that need to be appended to the array are provided to the `$each`operator in the form of an array. When such an update expression is executed, `$each`iterates through each element, and the element pushed to the array like:

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$push: {'genre': {$each: ['History', 'Action']}}},
    {returnNewDocument: true}
)
```

This preceding update operation finds and updates a document by its `_id`field and use the `$push`to add elements to the `genre`field.

#### `SortArray`-- 

Ordered but *unsorted* collection of elements. The elements of the array will always remain in the order in which they were inserted. While executing an update command with `$push`, can also sort an array. like:

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$push: {'genre': {$each:[], $sort: 1}}},
    {returnNewDocument: true}
)
```

For this, just use the `$push`in the `genre`field, this query is not pushing any element to the array cuz there are no elements provided to the `$each`operator. The new `$sort`operator is assigned the value 1. Can:

```js
db.movies1.findOneAndUpdate(
    {_id:111},
    {$push: {'genre': {$each:['Crime'], $sort: -1}}},
    {returnNewDocument: true}
)
```

As can see from the response, the array is just sorted in descending order and the new element, `Crime`is part of the `genre`array.

```js
db.items.insertOne({_id:11, items: [
        {"name" : "backpack", "price" : 127.59, "quantity" : 3},
        {"name" : "notepad", "price" : 17.6, "quantity" : 4},
        {"name" : "binder", "price" : 18.17, "quantity" : 2},
        {"name" : "pens", "price" : 60.56, "quantity" : 3},
    ]})
```

For this the `items`field is an array of 4 objects. Then:

```js
db.items.findOneAndUpdate(
    {_id:11},
    {$push: {items: {$each:[], $sort: {'price': -1}}}},
    {returnNewDocument: true}
)
```

The update command finds one document and sorts the array field.

## Don’t handle an error twice

Handling an error multiple times is just a mistake made frequently by developers -- 

```go
func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
    err := validateCoordinates(srcLat, srcLng)
    if err != nil {
        log.Println("failed to validate source coordinates")
        return Route{}, err
    }
 
    err = validateCoordinates(dstLat, dstLng)
    if err != nil {
        // log again?
        log.Println("failed to validate target coordinates")
        return Route{}, err
    }
 
    return getRoute(srcLat, srcLng, dstLat, dstLng)
}
func validateCoordinates(lat, lng float32) error {
    if lat > 90.0 || lat < -90.0 {
        log.Printf("invalid latitude: %f", lat)         
        return fmt.Errorf("invalid latitude: %f", lat)
    }
    if lng > 180.0 || lng < -180.0 {
        // already log
        log.Printf("invalid longitude: %f", lng)           
        return fmt.Errorf("invalid longitude: %f", lng)
    }
    return nil
}
```

First, it’s cumbersome to repeat the *invalid ...* error messages in both logging and the error returned. Having two log lines for a single error is a problem -- makes debugging harder -- If this func is called multiple times concurrently, the two messages may not be one after the other in the logs, making the debugging more complex. As a rule of thumb, an error should be handled only once.

### Not handling an error

In some cases, we may want to igore an error returned by a func -- there should be only one way to do in Go. However, from a maintainability respective, the code can lead to some issues -- So:
`_= notify()`
Instead of not assigning the error to a variable, assign it to the `_`identifier. A dommand can also accompany such code.

```go
// Good idea to write a comment that indicates why is ingored

// At-most once delivery
// Hence, it's accepted to miss of them in case of errors
_ = nofify()
```

#### Not Handling `defer`errors

Not handling errors in `defer`statement is a mistake that is frequently made by Go developers -- Fore:

```go
const query = "..."

func getBalance(db *sql.DB, clientID string) (float32, error) {
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer rows.Close()
}
```

For the `Closer`interface -- 

```go
type Closer interface {
    Close() error
}
```

This interface contains a single `Close`method that returns an error -- mentioned in the prevoius section that errors should alway be handled -- but in this, `defer`call is ignored.

Note that discussed -- if don’t want to handle the error, should ignore it explicitly using the `_`.

```go
defer func() {_ = rows.Close()}()
```

This version is more verbose but is better from a maintainability perspective as we explicitly mark that we are ignoring the error. But, in such a case, instead of blindly ignoring all errors from `defer`calls,  For this, calling `Close()`returns an error when it *fails to free a DB connection* from the pool. A better option would be to log a message like:

```go
defer func() {
    err := rows.Close()
    if err != nil {
        log.Printf("failed to close rows: %v", err)
    }
}()
```

If prefer to propagate it into the caller of the calling func -- 

```go
defer func() {
    err := rows.Close()
    if err != nil {
        return err
    }
}() // doesn't compile! the return is associated with the anyonymous func not calling func
```

So, if want to tie the error returned by `getBlance`to the err caught in the `defer`call, **must** use named result parameter.

```go
func getBalance(db *sql.DB, clientID string) (balance float32, err error) {
    //...
    defer func() {
        err = rows.Close()
    }()
    if rows.Next() {
        err := rows.Scan(&balance)
        if err != nil {
            return 0, err
        }
    }
}
```

This func assigns the error to the `err`variable, which is initialized using named result parameters.  For this, if `rows.Scan()`returns an error, `rows.Close()`is executed anyway. May override the error returned by the `getBlance`-- instead of returning an error, may return a `nil`error of `rows.Close()`returns successful. In the other words, if the call to `db.Query()`succeeds, the error returned by `getBalance`will always be one returned by the `rows.Close()`. So in the `defer`logic like:

```go
defer func() {
    closeErr := rows.Close()
    if err != nil {
        if closeErr != nil {
            log.Printf("failed to close")
        }
        return // just return the err, namely Scan error
    }
    err = closeErr
}()
```

### Defer 

When you are done with I/O operations, with a `*File`-- muse close it by using the `Close`method on your file. This way, system resources used by the file are released and U don’t create leaks with your program. If don’t do this -- may exhaust all available file handles of your system, and locking files has some complicated side effects on Windows. Like:

```go
f, err := os.Open(filePath)
if err != nil {
    return nil
}
defer f.Close()
```

#### Parse the JSON

In order to parse some JSON, will use the encoding/json package of Go. The general idea is that Go structure that is used fo decoding must match the JSON structure.

```go
type BookWorm struct {
	Name  string `json:"name"`
	Books []Book `json:"books"`
}

type Book struct {
	Author string `json:"author"`
	Title  string `json:"title"`
}
```

Each Go field is tagged with the name of the JSON field. Note that the name of the field doesn’t have to match the name of the tag.

#### Decode the JSON into a structure -- 

Once the file is opened and fully loaded we can define a variable that will hold the information. This variable must be a slice of `Bookworms`cuz this is what the JSON is giving us, then pass a pointer to that variable to the decoder.

```go
func loadBookworms(filePath string) ([]BookWorm, error) {
	f, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var bookworms []BookWorm

	// decode the file and store the content in the variable
	err = json.NewDecoder(f).Decode(&bookworms)
	if err != nil {
		return nil, err
	}
	return bookworms, nil
}
```

In order to make this whole file compile, need to import the `os`and `encoding/json`package.

#### Test it -- 

How do we make sure this is going to work after future changes -- Just write a test for this function -- the `testdata`folder is the perfect place to load various JSON files with our different test cases.

## Storing the user details

The next stage of our build is to update the `UserModel.Insert()`method so that it creates a new record in our `users`table containing the validted name, email, and hashed password.

```go
type UserModel struct {
    DB *sql.DB
}
func (m *UserModel) Insert(name, email, password string) error {
    // created a brcypt hash of the plain-text password
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
    if err != nil {
        return err
    }
    stmt : = `InserT...`
    _, err = m.DB.Exec(stmt, name, email, string(haspedPassword))
    if err != nil {
        // not that check the duplication
        var mySQLError *mysql.MySQLError
        if errors.As(err, &mySQLError) {
            if mySQLError.Number == 1062 && strings.Contains(mySQLError.Message,
                                                             "users_uc_email") {
                return ErrDuplicateEmail
            }
        }
        return err
    }
    
    // ...
    return nil
}
```

Then finish this by updating the `userSignup`like: -- 

```go
type userSignupForm struct {
	Name                string `form:"name"`
	Email               string `form:"email"`
	Password            string `form:"password"`
	validator.Validator `form:"-"`  // nested field so can use CheckField
}

func (app *application) userSignupPost(w, http.ResponseWriter, r *http.Request) {
    var form userSignupForm
    err := app.decodePostForm(r &form)
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    form.CheckField(validator.NotBlank(form.Name), "name", "some error info")
    
    if !form.Valid() {
        data := app.newTemplateData(r)
        data.Form= form
        app.render(w, http.StatusUnprocessableEntity, "sign.html", data)
        return
    }
    
    err = app.users.Insert(...)
    if err != nil {
        if errors.Is(err, models.ErrDuplicateEmail) {
            fmt.AddFieldError("...")
            data := data.newTemplateData(r)
            data.Form=form
            app.render(...)
        }else{
            app.serverError(w, err)
        }
        return
    }
    
    // note that also use session manager here to add some info
    app.SessionManger.Put(r.Context(), "flash", "your signup was successufl")
    http.Redirect(w, r, "/user/login", http.StatusSeeOther)
}
```

#### Using dbs bcrypt implmentations

Some dbs just provide built-in functions that you ca use for password hashing and verification instead of implementing you won in Go -- But it’s probably a good idea to avoid using these for two reasons.

#### Alternative for checking email duplicates

An alternative way is to add an `UserModel.EmailTaken()`method to our model which checks to see if a user with a specific email already exists. We could call this before we try to insert a new record, and add a validation error message to the form as appropriate.

However, this would introduce a RC to app -- if two users try to sign up with the same email address at *exactly* the same time, both submissions will pass the validtion check but ultimately on one `INSERT`into the dbs will succeed.

### User Login

In this, going to focus on creating the user login page for app -- revisit the `internal/validator`package -- support validation errors which aren’t associated with one specific form field. just like:

```go
// Validator Add a new field which will use to 
// hold any validation errors which are not related to a specific form field
type Validator struct {
	NonFieldErrors []string
	FieldErrors map[string]string
}

// Valid Update this method to also check `NonFiledErrors` slice
func (v *Validator) Valid() bool {
	return len(v.FieldErrors) == 0 && len(v.NonFieldErrors) ==0
}

// AddNonFieldError add error message to the new slice
func (v *Validator) AddNonFieldError(message string) {
	v.NonFieldErrors = append(v.NonFieldErrors, message)
}
```

Create a new `login.html`containing the makrup for login page like:

```html
{{define "title"}}Login {{end}}

{{define "main"}}
    <form action="/user/login" method="post" novalidate>
        {{range .Form.NonFieldErrors}}
            <div class="error">{{.}}</div>
        {{end}}
        <div>
            <label>Email:</label>
            {{with .Form.FieldErrors.email}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="email" name="email" value="{{.Form.Email}}">
        </div>

        <div>
            <label>Password:</label>
            {{with .Form.FieldErrors.password}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="password" name="password">
        </div>
        <div>
            <input type="submit" value="login">
        </div>
    </form>
{{end}}
```

Then in  the `handler`file and create a new `userLoginForm`struct and adapt our `userLogin`handler.

```go
// Create a new userLoginForm struct
type userLoginForm struct {
	Email               string `form:"email"`
	Password            string `form:"password"`
	validator.Validator `form:"-"`
}

func (app *application) userLogin(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userLoginForm{}
	app.render(w, http.StatusOK, "login.html", data)
}
```

#### Verifying the users details

The next step is the interesting part -- how to verify that the email and password submitted by a user are correct -- The core part of this verification logic will take place in the `UserModel.Authenticate()`method of our user model -- Specifically, need to do two things -- 

1. First should retreive the hashed password associated with the email address from our MySQL `users`table, if the email doesn’t exist in the dbs, or it’s for a user that has been deactivated, return the `ErrInvalidCredentials`error that we made eariler.
2. Otherwise, want to compare the hashed password from the `users`table with the plain-text pwd that user provided when logged in -- if don’t match, want to return `ErrInvalidCredentials`again.

So exactly that -- add the following code to the `internal/model/users.go`file like:

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

Next step involves updating the `userLoginPost`handler so that it parses the submitted login form data and calls this `UserModel.Authentiate()`method.