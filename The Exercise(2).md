# The Exercise(2)

- Sometimes it’s OK for some columns to have null values, as long as it’s not too many -- how many rows would you eliminate if you required at least 3 non-null values from the 4 column plate ID -- like:

  ```python
  at_least_two_df = df.dropna(subset=['Plate ID', 
                                      'Registration State', 'Vehicle Make', 'Street Name'],
                             thresh=3)
  df.shape[0] - at_least_two_df.shape[0]
  ```

- Which of the columns you have imported has the greatest number of `NaN`values -0- and this is a problem? -- like:

  ```python
  df.isnull().sum()
  ```

- And *null* is bad, but there is plenty of bad non-null data too., may cars with `BLANKPLATE`, so turn these into `NAN`.

  ```python
  no_blankplate_df = df.replace({'Plate ID':'BLANKPLATE'}, np.NaN).dropna(subset=['Plate ID', 
                                        'Registration State', 'Vehicle Make', 'Street Name'],  
                                  thresh=3)
  df.shape[0] - no_blankplate_df.shape[0]
  ```

#### Combining and splitting columns

A common aspect of data cleaning involves creating one new column from several existing columns, -- as well as the reverse, creating multiple columns from a single existing column -- like:

```python
df['current_net']= (df['retail_price']-df['wholesale_price'])*df['sale']
```

Cleaning data involves truning one complex column into one or more simpler columns -- fore, can imagine thaking a column with a `float64`dtype and turning into two `int64`columns -- This is especially true in the case of two complex data structures -- which have much more to say about -- 

Working it out -- in this exercise, create and clean up a two-column data frame. Each column needs to be cleaned differently for us to answer the question -- starting by loading the csv file into a data frame, only interested in two of the columns like:

```python
df = pd.read_csv('celebrity_deaths_2016.csv',
                 usecols=['dateofdeath', 'age'])
```

Cuz only interested in celebrity during particular months -- so: And noticed that aren’t truning the column into an integer, could, but the leading 0 on the two-digit makes it tricker.

```python
df['dateofdeath'].str[5:7]
# can assign that value to a new column, months like:
df['month']=df.dateofdeath.str[5:7]
# then set month column the index
df= df.set_index('month')
```

Now are set to retrieve rows from a single month or a range of months, but we are not done yet, cuz we want ot find the average age at which celebrities died in 2016. To do that, need to turn the `age`column into a numeric value.

`df['age']=df.age.astype(np.int64)`-- however, this will fails for two reasons -- first some values contain characters other than digits -- second, some are `NaN`., as floatint-point, cannot coerced into integers. So, before willy-nilly removing the NaN values, we should probably check to see how many there are -- can do that with the `.isnull().sum()`trick and combine that with the shape method to dinf the percentage of null values like:
`df['age'].isnull().sum()/len(df['age'])`-- we can just sacifice that many rows and not worry about how much data we are losing -- can remove the `NaN`values like:
`df =df.dropna(subset=['age'])`

Notice, here using the `subset`parameter, not that there any rows in the index with `NaN`values. One way to use the `str.isdigit()`-- returns `True`if a string contains only digits.

## Handling `defer`errors

Not handling errors in `defer`statement is a mistake that is frequently made by Go developers -- understand what the problem is and the possible solutions -- In the following -- will implement a function to query a DB to get the balance given a custom ID -- will use `database/sql`and the `Query`method -- like:

```go
const query= "..."

func getBalance(db *sql.DB, clientID string) (float32 error){
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer rows.Close()
}
```

There, `rows` is a `*sql.Rows`type -- it implements the `Closer`interface like:

```go
type Closer interface{
    Close() error
}
```

For this, interface contains a single `Close()`method that returns an error, mentioned in the prevoius that errors should always be handled - but in this, the error returned by the `defer`is just ignored cuz:

`defer rows.Close()`

If we don’t wan to handle the error, we should ignore it explicitly using the `_`identifer fore:

```go
defer func() {_ = rows.Close()}()
```

For this version, is more verbose but is *better* from a maintainability perspecitive as we explicitly mark that we are just ignoring the error -- but in such a case, instead of blindly ignoring all errors from the `defer`calls, should ask whether that is the best approach -- in this case, Calling `Close()`returns an `error`when it fails() to feed a DB connection from the pool -- ignoring this error is probably not what we want to do. Most likely, a better option would be to log:

```go
defer func(){
    err := rows.Close()
    if err != nil {
        log.Printf("failed to close rows: %v", err)
    }
}()
```

Now, if closing `rows`fails, the code will just log a message so, we are aware of it -- and, what if, instead of handling the error, prefer to propagate it to the caller of `getBalance`so that can decide how to handle it -- like:

```go
defer func(){
    err:= rows.Close()
    if err != nil {
        return err
    }
}()
```

For this IMP -- doesn’t compile -- indeed the `return`statement is associated with the anonymous `func()`, not for `getBalance()`. And if want to tie the error returned by the `getBalance()`to the `error`caught in the `defer`call, must use named result parameter -- like:

```go
func getBalance(db *sql.DB, clientID string) (balance float32, err error) {

	rows, err := db.Query(query, clientID)
	if err != nil {
		return 0, err
	}
	defer func() {
		err = rows.Close()
	}()
	if rows.Next() {
		err := rows.Scan(&balance)
		if err != nil {
			return 0, err
		}
		return balance, nil
	}
	//...
}
```

For this, once the `rows`variable has been correctly created, defer the call to `rows.Close()`in an anonymous function, this func assigns the error to the `err`variable, which is initialized using named result parameter. Also, this code may look okay, but here is a problem -- if `rows.Scan()`returns an error, `rows.Close()`is executed anyway, but cuz this call overrides the error returned by `getBalance()`-- instead of returning an error, may return a nil error if `rows.Close()`returns successfully. in the other words, if the call to the `db.Query`succeeds, the error returned by the `getBalance()`will always be the one returned by `rows.Close`-- like:

The logic need to implement isn’t -- 

- If `rows.Scan()`succeeds -- if `rows.Close()`succeeds, return no error, if `rows.Close()`fails, return this error.
- And if `rows.Scan()`fails, the logic is more complex -- have to handle two errors like: -- if `rows.Scan()`fails, if, `rows.Close()`succeeds, return error from the `rows.Scan`and if `rows.Close()`fails, -- like:

```go
defer func(){
    closeErr := rows.Close()
    if err != nil {
        if closeErr != nil {
            log.Printf("failed to clsoe row: %v", err)
        }
        return
    }
    err = closeErr
}()
```

So the `rows.Close()`error is assigned to another variable -- `closeErr`, before assgning it to `err`, check whether the `err`is different from `nil`. Errors should always be handled -- in the case of errors returned by the `defer`, the very least we should do is ignore them explicitly.

## Parsing Form Data

Any `POST /snippets/create`requests are already being dispatched to our `createSnippet()`handler. At a high-level can break this down into two distinct steps -- 

1. First, Need to use the `r.ParseForm()`method to parse the request body, this checks that the request body is well-formed, and then stores the form data in the request’s `r.PostForm`map. If there are any errors encountered when parsing the body -- then it will return an error, the `p.ParseForm()`method is also idemponent; can safely be called multiple times on the same request without any side-effects.
2. Can then get to the form data contained in the `r.PostForm`by using the `r.PostForm.Get()`method. Fore, can retrieve the value of the `title`field with `r.PostForm.Get("title")`-- if there is no matching field name in the form this will return the empty string “” -- similar to the way that query string parameters worked earlier in the book. Just like:

```go 
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
    // first call the `r.ParseForm()` which adds 
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    // use the `r.PostForm.Get()` method to retreive the relevent data fields
    // from the `r.PostForm` map
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    expires := r.PostForm.Get("expires")
    
    // create a new snippet record in the dbs using the form data.
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        app.serveError(w, err)
        return
    }
    http.Redirect(w, r, fmt.Sprintf("/snippet/%d", id), http.StatusSeeOther)
}
```

### The `r.Form`Map

In our code, accessed the form values iva the `r.PostForm`map, but an alternative approach is to sue the `r.Form`map. The `r.PostForm`is populated only for `POST, PATCH, PUT`requests, and contains the form data from the rrequest body, in contrast, the `r.Form`map is populated for all requests ( irrespective of their HTTP method) -- and contains the form data from any request body **and** any query string parameters.

Use the `r.Form`map can be useful if your application sends data in a HTML form and in the URl, or you have an application that is agnostic about how parameters are passed. if form was submitted to `/snippet/create?foo=bar`, could also get the value of the `foo`parameter by calling `r.Form.Get("foo")`-- note that the event of a conflict, the request body value *will take precedent* over the query string parameter.

#### The `FormValue`and `PostFormValue`methods -- 

And the `net/http`package also provides the methods `r.FormValue()`and `r.PostFormValue()`-- These are essentially shortcut functions that *call `r.ParseForm()`for you*, and then fetch the appropriate field value from `r.Form`or `r.PostForm`respectively.

Should avoid these shortcuts cuz they *sliently ignore any errors returned by* `r.ParseForm()`-- not ideal.

#### Multiple-Value fields

Strictly, the `r.PostForm.Get()`method that we have used above only returns the *first* value for a specific form field. This means that you can’t use it with form fields which potentially send multiple values. Fore:

```html
<input type="checkbox" name="items" value= "foo">Foo
<input type="checkbox" name="items" value= "bar">Bar...
```

In this case, need to wrok wth the `r.PostForm`map directly, the underlying type of the `r.PostForm`map is `url.Values`-- which in turn has the underlying type `map[string][]string`. like:

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprintf(w, "%d: Item: %s\n", i, item)
}
```

#### Form size

Unless U are sending multipart data -- then `POST, PUT`and `PATCH`request bodies are limited to 10MB. If this is exceeded then `r.ParseForm()`will return an error. If want to change this limit you can use the `http.MaxBytesReader()`func like -- 

```go
// limit the request body size 
r.Body = http.MaxBytesReader(w, r.Body, 4096)
err := r.ParseForm()
if err != nil {
    http.Error(w, "bad request", http.StatusBadRequest)
    return
}
```

With this code only the first 4096 bytes of the request body will read during `r.ParseForm()`-- trying to read beyond this limit will cause the `MaxBytesReader`to return an error, which will subsequently be surfaced by `r.ParseForm()`. Additionally, if the limits is hit -- `MaxBytesReader`sets a flag on `http.ResponseWriter`which instructs the server to close the underlying TCP connection.

### Data Validation

Right now there is a glaring problem with our code -- not validating the user input from the form in any way -- should do this to ensure that the form data is presnet, of the correct type meets any business rules that we have. Specially for this form want to -- 

- Check that the title, content, and expires fields are not empty
- Check the `title..`not more than 100 characters long.
- Check that the `expires`value matches one of our permitted values.

For this, just using some `if`statements and various functions in `string`and `utf8`packages like:

```go
// initialize a map to hold any validation errors
errors := make(map[string]string)

// check that the title field is not blank and is not more than 100 characters
// if it fails or lose checks
// map using the field name as the key
if strings.TrimSpace(title) == "" {
    errors["title"] = "This field cannot be blank"
} else if utf8.RuneCountInString(title) > 100 {
    errors["title"] = "This field is too long"
}

// check the content isn't blank
if strings.TrimSpace(content) == "" {
    errors["content"] = "This field cannot be blank"
}

// also, check the expires isn't blank and matches one of the permitted
if strings.TrimSpace(expires) == "" {
    errors["expires"] = "This field cannot be blank"
} else if expires != "367" && expires != "7" && expires != "1" {
    errors["expires"] = "this field is invalid"
}

// if there are any errors, dump them in a plain text HTTP response and return
if len(errors) > 0 {
    fmt.Fprint(w, errors)
    return
}
```

When check the length of the `title`field, are using the `utf8.RuneCountInString()`-- no Go’s `len()`function -- this is cuz we want to count the number of characters in the title rather than the number of bytes.

#### Displaying Validation errors and re-populating Fields

Now that the `createSnippet()`handler is validating the data the next stage is to manage these validation errors -- if there are any validation errors want to re-display the form, highlighting the fields which failed validation and automatically re-populating any previous submitted data -- to do this, begin by adding two new fields to our `templateData`struct -- `FormErrors`to hold any validation errors and `FormData`to hold any previously submitted data. like:

```go
type templateData struct {
	CurrentYear int
	FormData    url.Values
	FormErrors  map[string]string
	Snippet     *models.Snippet
	Snippets    []*models.Snippet
}
```

Then need to update the `createSnippet()`handler again, so that if any validation errors are encountered the form is re-displayed with the relevant errors and form data passed to the template like so:

```go
if len(errors) > 0 {
    app.render(w, r, "create.page.html", &templateData{
        FormErrors: errors,
        FormData:   r.PostForm,
    })
    return
}
```



