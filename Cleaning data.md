# Cleaning data

All this assumes there was data to begin with -- have mising data cuz there wasnt’ any data to record. This is why there was data to begin with -- have missing data cuz there wasn’t any data to record fore.

This is why data scientists say that 80% of their job involvles cleaning data -- 

- Renaming columns
- Renaming the index
- Removing irrelvant columns
- Split one column
- Combining two or more columns into one
- Removing no-data rows
- Removing repeated rows
- Remove rows with missing data
- Replace `NaN`data with a single value
- Replace `NaN`data via interpolation
- Standardize strings
- Removing whitespace from strings
- Correct the types used for columns
- Identify and remove outliers

For some methods -- 

- `df.replace()`-- replaces values in one or more columns with other values\
- `s.map`-- applies a func to each element of `Series`, returning the result of that app on each element
- `str.isdigit`
- `pd.to_numeric`-- returns a series of integer or floats based on a series of strings
- `s.mode`-- returns a `series`with the most commonly found values in s

Fore -- How much is missing -- On several occasions, that data frames can contain `NaN`values, one question we often want to answer is how many `NaN`values are in a given column -- one solution is to calculate things -- there is a `count`method can run on a series, which returns the number of non-null values in the series. Can:

`s.shape[0]-s.count()`-- returns an integer, the number of null elements

for this, is tedious and annoying -- so, there are `isnull()`method -- can call `isnul`lon a column, returns a boolean series with `True`where there is a `NaN`value and `False`in other place. so:

`s.isnull().sum()`-- calculate the number of `NaN`values in s

The, if run `isnull()` on a data frame, get a new data frame back, the the `True`and `False`values indicating whether here is a null value in that particulr row-column combination. Fore:

`df.info(show_counts=True)`-- Gets full info about the data frame df, including number of null values in each column.

### Parking cleanup

In this, will identify missing values, one of hte most common problems -- how often values are missing and what effect they may have -- 

1. Create a data frame from the file -- only interested in a handful of the columns
2. Remove rows with any mising data
3. Remive rows that are missing one or more of those...
4. Remove rows that are missing one or more repetetion.

```python
df = pd.read_csv(
    "nyc-parking-violations-2020.csv",
    usecols=[
        "Plate ID",
        "Registration State",
        "Vehicle Make",
        "Vehicle Color",
        "Violation Time",
        "Street Name",
    ],
)
```

Can determine the number of rows in our data frame by getting the first element like: 

```python
df.shape[0]
len(df) #  
len(df.index) # 45% faster then len(df) and 65% faster then shape[0]
```

#### counting values

The `count`method often seems like the most natural, obvious way to count rows, but there several problems -- 

- ignores `NaN`
- On a large data frame, takes long time to run

So, if U want to know the number of all values, including `NaN`, should use the `szie`-- which works on both series and data frames. `np.size`like `np.size(s)`

Should call `len(df.index)`-- which gives me the total length and seems to run faster. FORE:

```python
all_good_df= df.dropna()
```

This means that if every row in a data frame contains a single `NaN`value, the result calling `df.dropna()`will be an empty data frame.

```python
len(df.index)-len(all_good_df.index)
```

Represent about 3.5% of the data in the original data -- 

## Checnking an error value accurately

This is similar to the previous one but with sential errors -- first, define what a sentienl error conveys, then will see how to compare an error to a value -- fore a sentinel error is an error defined as a global variable like;

```go
import "errors"
var ErrFoo = errors.New("foo")
```

In general, the convention is to start with `Err`followed by the error type -- fore `ErrFoo`-- A sentinel error conveys an *expected error* -- fore, want to design a `Query`method that allows us to execute a query to dbs. This method will return a slice of rows.

- Return a sentinel value, a `nil`slice
- Return a specific error that a client can check.

Take second approach - for this, method can return a specific error if no rows are found. Can classify this as an expected error, cuz passing a request that returns now rows is allowed. Conversely, situations like network issues and connection polling errors are *unexpected* errors. Note -- it doesn’t mean we don’t want to handle unexpected errors, it just means that semantically, those errors convey a different meaning. fore:

- `sql.ErrNoRows`-- doesn’t return any rows
- `io.EOF`-- Returned by an `io.Reader`when no more input is available.

Namely, they convey an expected error that clients will expect to check -- as general guidelines -- 

- Expected errors should be designed as error values like `var ErrFoo= errors.New("foo")`
- Unexpected should be designed as error types -- like: `type BarError struct {...}`

```go
err := query()
if err != nil {
    if err == sql.ErrNowRows {
        //...
    }else {...}
}
```

Note that a sentinel error can also be wrapped -- namely, if an `sql.ErrNoRows`is wrapped using `fmt.Errorf`and the `%w`directive, `err==sql.ErrNoRows`will always be `false`. so again, Go 1.13 provides an answer -- `errors.As()`is used to check an error against a type, with error values, can use its counterpart -- `errors.Is()`-- like:

```go
err := query()
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {...}
}
```

Using `errors.Is()`instead the `==`allows the comparision to work even if the error is wrapped. And the `errors.As`function checks if an error can be cast to a specific type -- it attempts to find the first error in the chain.

1. Purpose:
   - `errors.Is`is used to check if an error matches a speicifc error value
   - `errors.As`is used to check if can be **cast** to a specific type.
2. Comparison Mechanism:
   - `errors.Is`compares error values and supports unwrappeing to find a specific target error.
   - `As`attempts to **type-assert** the error
3. Use Scenarios -- 
   - Use `errors.Is`when need to compare an error directly to a known error value
   - Use `errors.As`when need to handle an error based on its type, allowing for type-specific operation or actions.

So -- `errors.Is`use when you have a specific error value to check against an error, and `error.As`use when you need to determine if an error belongs to a certain type and possibly its fields.

In  summary, if we use error wrapping in our application with the `%w`directive and `fmt.Errorf`, checking an error against a specific value should be done using `errors.Is`instead of `==`, thus, even if the sentinel error is wrapped, errors. 

### Handling an error twice

Handling an error multipe times is a mistake made frequently by developers, not specifically in Go. Understand why this is a problem and how to handle errors efficiently. 

Write a `GetRoute`function to get the route from a pair of sources to a pair of target coordinates. Let’s assme this function will call an unexported `getRoute`function that contains the business logic to calcualate the best route.

```go
func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
	err := validateCoordinates(srcLat, srcLng)
	if err != nil {
		log.Println("failed to validate source coordinates")
		return Route{}, err
	}
	err = validateCoordinates(dstLat, dstLng)
	if err != nil {
		log.Println("failed to validate target coordinates")
		return Route{}, err
	}
	return getRoute(srcLat, srcLng, dstLat, dstLng)
}

func validateCoordinates(lat, lng float32) error {
	if lat > 90.0 || lat < -90.0 {
		log.Printf("Invalid latitude: %f", lat)
		return fmt.Errorf("invalid latitued:%f", lat)
	}
	if lng > 180.0 || lng < -180.0 {
		log.Printf("invalid longtide : %f", lat)
		return fmt.Errorf("invalid latitude: %f", lat)
	}
	return nil
}
```

First, the `valiateCoordinates`-- it is cumbersome to repeat the `invalid`latitude or `invalide`longitude `error`messages in both logging, and error returned, also, if run the code with an invalid latitude, fore, will log -- Having two log lines for a single error is a problem -- cuz it makes debugging harder. As a urle of thumb, an error should be handled only once, logging an error is handling an error, and so is returning an error, hece, should either log or return an error never both. Re-write like:

```go
func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route, error) {
    err := ValiateCoordinates(srcLat, srcLng)
    if err != nil {
        return Route{}, err
    }
    err = validateCoordinate(dstLat, dstLng)
    if err != nil {
        return Route{}, err
    }
    return getRoute(...)
}

func validateCoordinate(lat, lng float32) error {
    if ... {
        return fmt.Errorf()
    }
    if ...{
        return fmt.Errorf(...)
    }
    return nil
}
```

In this version, each error is handled only once by being returned directly. Then assuming the caller of `GetRoute`is handling the possible errors with logging, the code will output the following message in case of an invalid latitude. Also, rewrite the latest version of our code using Go 1.13 -- like:

```go
func GetRoute(src..., float32) (Route, error) {
    err := validateCoordinate(srcLat, srcLng)
    if err != nil {
        return Route{}, fmt.Errorf("...%w", err)
    }
    err = validateCoordinates(dstLat, dstLng)
    if err != nil {
        return Route{}, fmt.Errorf("...%w", err)
    }
}
```

for this, each error returned by `validateCoordinates`is now wrapped to provide additional context for the error.

### Handling an error

In some cases, we may want to ignore an error returned by a function -- there should be only one way to do this in Go.

```go
func f(){
    notify()
}
func notify() error {...}
```

From an maintainability perspective, the code can lead to some issues -- consider a new reader looking at it. This reader notices that `notify`returns an error but that error isn’t handled by the parent function. So, how can they guess whether or not handling the error was intentional -- like `_=notify()` -- insted of not assigning the error to a variable, jsut assign to the `_`-- but new version makes explicit that we aren’t interested in the error.

## Processing Forms

In this we are going to focus on allowing users of our web app to create a new snippet via a HTML form which looks like: The high-level workflow for processing this form will follow a std `post-redirect-get`pattern and look like:

1. The user is shown the blank from when they make a `GET`request to `/snippet/create`.
2. The user completes the form and it’s usbmitted to the server via a `POST`request to `/snippet/create`.
3. The form data will be validated by our `createSnippet`handler. And if there are any vlidation failures the form will be re-displayed with the appropriate form field highlighted. `/snippet/:id`

namely -- 

- how to parse and access form data sent in a `POST`request
- some techniques for performing common *validateion checks* on the form data
- A user-friendly pattern for altering the user to validation failures and re-popupateing form field with submitted data.
- How to scale-up validatoin and keep your handlers clean by creating a form helper in a spearte re-usable package.

### Setting up a Form

```html
{{template "base" .}}
{{define "title"}}Create a new Snippet {{end}}

{{define "main"}}
    <form action="/snippet/create" method="post">
        <div>
            <label>Title:</label>
            <input type="text" name="title">
        </div>

        <div>
            <label>Content:</label>
            <textarea name="content"></textarea>
        </div>
        <div>
            <label>Delete in:</label>
            <input type="radio" name="expires" value="365" checked>One year
            <input type="radio" name="expires" value="7">One week
            <input type="radio" name="expires" value="1">One Day
        </div>
        <div>
            <input type="submit" value="Publish snippet">
        </div>
    </form>
{{end}}
```

There is nothing particularly special about this so for -- our main template contains a std web form which sends 3 form vlaues - `title content expires`-- the only thing to really point out is the form’s `action`and `method`-- 

`<a href="/snippet/create">Create snippet</a>`

And finally, need to update the `createSnippetForm`handler so that it renders our new page like:

```go
func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "create.page.html", nil)
}
```

At this point can fire up and check.

### Parsing Form data

Any `POST /Snippets/create`requests are already being dispatched to our `createSnippet`handler. At a hight-level we can break this down into two distinct steps -- 

1. First, need to use the `r.ParseForm()`method to parse the request body -- this checks that the request body is well-formed -- and the stores the form data in the requst’s `r.PostForm`map. If there are any errors encountered when parsing the body then it will return an error. The `r.ParseForm()`method is also idempotent. Can safely called multiple times on the same request without side-effects.
2. Can then get to the form data contained in `r.PostForm`by using the `r.PostForm.Get()`method -- fore, can retreive the value of the `title`field with `r.PostForm.Get("title")`-- if there is no matching field name in the form this will return the empty string -- similar to the way that the query string parameters worked eariler in the book.

```go
func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	// First call r.ParseForm() which adds any data in POST request bodies
	// to the r.PostForm map. This also works in the same way for PUT and PATCH
	// requests -- If there are any error, use our `app.ClientError`helper to send
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// use the r.PostForm.Get() method to retrieve the relevant data
	title := r.PostForm.Get("title")
	content := r.PostForm.Get("Content")
	expires := r.PostForm.Get("expires")
	
	// create a new snippet 
	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}
	
	http.Redirect(w, r, fmt.Sprintf("/snippet/%d", id), http.StatusSeeOther)
}
```

