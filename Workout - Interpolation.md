# Workout - Interpolation

When data contains `NaN`values, have a few options -- 

- Remove them
- Leave them
- Replace them with something else

If Choose the option 3 -- Replace them with sth else, that raises another question -- what do you want to replace the `NaN`with -- will fill in missing data from the dataset -- This one has no obvious right or wrong answer -- 

#### Working it out

```python
# also a method run on pd rather than on an individual data frame object
df = pd.read_excel('titanic3.xls')
```

First, use `isnull().sum()`to find out how many `NaN`values are in each column of the data frame. Can then check to see which columns have a non-zero number of `NaN`values, returns a boolean series -- can then apply as a mask.

```python
df.columns[df.isnull().sum()>0] # returns a boolean series, can apply as mask index to df.columns
```

Notice that the column names are stored in an `Index`object, which works similarly to a series object. Can also run `df.isnull().sum()`by itself to see how many `NaN`values are in each column.

Deciding what to do with each `Nan`- containing column just depends on various factors, including the type of data the column contains -- another factor is how many rows have null values -- so:

```python
df= df.dropna(subset=['fare', 'embarked'])
```

And, when it comes to the `age`column, though, want to consider our steps carefully, i’m inclined to use the mean here-- could use the mode -- could also use a more sophisitcated technique -- using the mean from witin a particular cabin. For this, using the mean age has some advantages. like:

```python
df['age']=df.age.fillna(df.age.mean())
```

For this -- Pandas ignores `NaN`values by default, which means this calculation is based on the non-null numeric values in that column. Run `fillna()`on `df.age`. -- Just note that the result of invoking `fillna()`is a new series identical to `df.age`-- except the NaN values are replaced. The result of the `df['age'].fillna()`is a new series.

Finally, want to set the `home.dest`column similar to what did with the age -- use the mode -- like:

```python
# mode() returns series that appear most often
df['home.dest']=df['home.dest'].fillna(df['home.dest'].mode()[0])
```

#### Beyond the exercises

In these tasks, will do sth mentioned earlier -- replace `NaN`values in the `home.dest`column with the most common value from that person’s `embarked`column -- take several steps -- 

1. Create a series in which the index contains the unique values from the `embarked`column and the values are modt common dest for each value of embarked:

```python
most_common_destinations = pd.Series([], dtype=object)

for embarked_value in df["embarked"].dropna().unique():
    most_common_destinations.loc[embarked_value] = (
        df.loc[df["embarked"] == embarked_value, "home.dest"].value_counts().index[0]
    )

most_common_destinations
```

2. Replace `NaN`values in the home.dest with the values from `embarked`like:

```python
f['home.dest'] = df['home.dest'].fillna(df['embarked'])
```

3. Using the `most_common_destination`series to replace values in `home.dest`with the most common values

```python
f['home.dest'] = df['home.dest'].replace(most_common_destinations)
```

#### Inconsistent data

Missing data is a common problem you must deal with when importing data sets -- but equally common is inconsistent data -- when the same value is represented by several different values -- If data is inconsistent, it will be hard for U to analyze it in any sort of serious way - thus, a big part of cleaning real-world data involving making it mroe consistent -- to use term from the world of database -- *normalizing* it.

```python
df = pd.read_csv(
    "nyc-parking-violations-2020.csv",
    usecols=[
        "Plate ID",
        "Registration State",
        "Vehicle Make",
        "Vehicle Color",
        "Street Name",
    ],
)
# can see 1896 different color
len(df['Vehicle Color'].value_counts().index)

# and there can see 30 most common colors:
df['Vehicle Color'].value_counts().head(30)
```

Can already see that there is little or no standardization and the people giving trickets. To clean up, just create a regular Python dict -- could also use a series just like:

```python
colormap = {
    "WH": "WHITE",
    "GY": "GRAY",
    "BK": "BLACK",
    # ...
}
```

By applying the `replace()`method to our series, get back a new series, that new can then be assigned back to the 
`df['Vehicle Color'] = df['Vehicle Color'].replace(colormap``)`

```python
df['Vehicle Color']= df['Vehicle Color'].replace(colormap)
len(df['Vehicle Color'].value_counts().index) # 1880 returned
```

Turns out we made two mistakes -- first said to look for the shortend color .

```python
import string

def clean_name(one_string):

    if not isinstance(one_string, str):
        return one_string

    output = ''
    
    for one_character in one_string.strip().upper():
        if one_character in string.ascii_uppercase:
            output += one_character

    return output

print(len(df['Vehicle Make'].value_counts()))
df['Vehicle Make'] = df['Vehicle Make'].apply(clean_name)
print(len(df['Vehicle Make'].value_counts()))
```

## The Go Memory model

The previous section discussed three main technique to sync goroutines -- Atomic opertions, mutexes, and channels. However, there are some core principles should be aware of as Go developers -- fore, buffered and un-buffered channels offer differ guarantees -- to avoid unexpected race caused by a lack of understanding of the core specification of the language, have to look at the Go memory model -- 

The Go memory model is a specification that defines the conditions under which a read from a variable in one goroutine can be guaranteed to happen after a write to the same variable in a different goroutine. So, provides guarantees that developers should keep in mind to avoid data races and force deterministic output.

Within multiple goroutines -- should bear in mind some of these guarantees -- fore **A<B** denotes that event A happens before event B. for the conditions:

- Creating a goroutine happens before the goroutine’s execution begins

  ```go
  i := 0
  go func(){i++}() // doesn't lead a data race
  ```

- The exit of goroutines isn’t guaranteed to happen before any event

  ```go
  i:=0
  go func() {i++}()
  fmt.Println(i) // isn't guaranteed to happen before data race happened
  ```

- A send on a channel happens before the corresponding from the channel completes.

  ```go
  // parent goroutine increments a variable before a send, while antoher reads after channel read
  i := 0
  ch := make(chan struct{})
  go func(){
      <-ch
      fmt.Println(i)
  }()
  i++
  ch <- struct{}{}
  // variable increment < channel send < channel receive < varable read
  // so can ensure that accesses to `i` are synchoronized
  ```

- Closing a channel happens before a receive this closure. fore:

  ```go
  i :=0
  ch := make(chan struct{})
  go func() {
      <-ch
      fmt.Println(i)
  }()
  i++
  close(ch) // there, this is also free from data races
  ```

- Regarding channels may counter-intuitive -- a receive from an unbuffered channel happens **before** the send on that channel completes.

```go
// example with a buffered channel instead of an unbuffered one
i := 0
ch := make(chan struct{}, 1)
go func(){
    i =1
    <-ch
}()
ch <- struct{}{}
fmt.Println(i)
```

NTOE That this example leads to a data race -- Cuz both the read and write to `i`may occur simultaneously, therefore, itsn’t synchoronzied. But change to unbuffered one like:

```go
i :=0
ch := make(chan struct{})
go func(){
    i =1
    <-ch
}()
ch <- struct{}{}
fmt.Println(i)
```

For this example, makes it data-race-free -- see the main difference -- the *write is guaranteed to happen before the read.* -- Write to `i`will always occur before the read, just note that, only for unbuffered channels.

### Understanding the concurrency impacts of a workload type

Looks at the impact of a workload type in a concurrent implementation -- Depending on whether a workload is CPU-or I/O bound -- may need to tackle the problem differently -- 

1. The speed of the CPU
2. The speed of the I/O
3. The amount of the avialable memory.

For, the following example implements a `read`function that accepts an `io.Reader`and reads 1024 bytes from it repeatedly -- pass these to a `task`function that perform some tasks. This `task`function returns an integer. like:

```go
func read(r io.Reader) (int, error) {
    count :=0
    for {
        b := make([]byte, 1024)
        _, err := r.Read(b)
        if err != nil {
            if err == io.EOF{
                break
            }
            return 0, err
        }
        count += task(b)
    }
    return count, nil
}
```

### Go context

Package context defines the Context type -- which carries deadlines, cancellation signals, and other request-scoped values across API boundaries and between processes -- Incoming requests to a server could create a `Context`-- and outgoing calls to servers should accept a Context. The chain of function calls between must propagate the Context, optionally replacing it with a derived Context created using `WithCancel, WithDeadLine, WithTimeout`or `WithValue`. When a context is canceled, all contexts derived from is are also cancled.

These functions take a *Context* (the parent) and return a dervied context, and a `CancelFunc`-- Calling the `CancelFunc`cancels the child and its children, removes the parent’s reference to the child, and stops any associated timers. Failing to call the `CancelFunc()`leaks the child and its children until the parent is canceld or the timer fires.

#### What is Context? -- 

Is a built-in package in the Go stdlib that provides a powerful toolset for managing concurrent operations -- it enables the propagating of cancellation signals, deadlines, and values across goroutines, ensuring the related operations can gracefully terminate when necessary.

## Scaling Data Validation

Creating the `forms`package to just abstract some of this behavior and reduce the boileplate code in our handler -- 

```go
type errors map[string][]string
func (e errors) Add(field, message string){
    e[field]=append(e[field], message)
}

func (e errors) Get(field string) string {
    es := e[field]
    if len(es)==0 {
        return ""
    }
    return es[0]
}
```

Then the form.go file add the following -- 

```go
type Form struct {
    url.Values
    Errors errors
}

// define a new function to initialize a custom Form struct, notice that
func New(data url.Values) *Form {
    return &Form{data, errors(map[string[]string{}]),
                }
}

func (f *Form) Required(fields ...string) {
    for _, field := range fields {
        value := f.Get(field)
        if strings.TrimSpace(value)=="" {
            f.Errors.Add(field, "this cannot be blank")
        }
    }
}

func (f *Form) MaxLength(field string, d int) {
    value := f.Get(field)
    if value == "" {
        return
    }
    if utf8.RuneCountInString(value) > d {
        f.Errors.Add(field, fmt.Sprintf("...", d))
    }
}
```

Then modifie this:

```go
type templateData struct {
	CurrentYear int
	Form *forms.Form
	Snippet     *models.Snippet
	Snippets    []*models.Snippet
}
```

In the `handler.go`file to update it to use the new `forms.Form`struct and validation methods that just created like:

```go
func (app *application) createSnippetForm(w http.ResponseWriter, r *http.Request) {
	app.render(w, r, "create.page.html", &templateData{
		// pass a new empty forms.Form to the template
		Form: forms.New(nil),
	})
}

func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// Create a new forms.Form struct containing the POSTed data from
	// the form, then use the validation methods to check the content
	form := forms.New(r.PostForm)
	form.Required("title", "content", "expires")
	form.MaxLength("title", 100)
	form.PermittedValues("expires", "356", "7", "1")

	// If the form isn't valid, redisplay the template passing in the form.Form
	if !form.Valid() {
		app.render(w, r, "create.page.html", &templateData{Form: form})
		return
	}

	// cuz the form data has been anonymously embedded
	// url.Values is the type of map[string][]string, has a Get() method
	id, err := app.snippets.Insert(form.Get("title"), form.Get("content"),
		form.Get("expires"))
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet/%d", id), http.StatusSeeOther)
}
```

Then, need to modify the `create.page.html`file to use the data like:

```html
{{define "main"}}
    <form action="/snippet/create" method="post">
        {{with .Form}}
            <div>
                <label>Title:</label>
                {{with .Errors.Get "title"}}
                    <label class="error">{{.}}</label>
                {{end}}
                <input type="text" name="title" value="{{.Get "title"}}">
            </div>

            <div>
                <label>Content:</label>
                {{with .Errors.Get "content"}}
                    <label class="error">{{.}}</label>
                {{end}}
                <textarea name="content">{{.Get "content"}}</textarea>
            </div>
            <div>
                <label>Delete in:</label>
                {{with .Errors.Get "expires"}}
                    <label class="error">{{.}}</label>
                {{end}}
                {{$exp := or (.Get "expires") "365"}}
                <input type="radio" name="expires"
                       value="365" {{if (eq $exp "356")}}checked {{end}}> One year
                <input type="radio" name="expires"
                       value="7" {{if (eq $exp "7")}}checked{{end}}> One week
                <input type="radio" name="expires"
                       value="1" {{if (eq $exp "1")}}checked{{end}}> One Day
            </div>
            <div>
                <input type="submit" value="Publish snippet">
            </div>
        {{end}}
    </form>
{{end}}
```

Now got a `forms`package with validation rules and logic that can be reused across our application, can also easily be extended to include additional rules in the future.

### Stateful HTTP

A nice touch to improve our user experience would be to display a one-time confirmation message which the user sees after the have added a new snippet.

A confirmation message like this should only show up for the user once -- (immediately after creating the snippet) and no other users should ever see the message -- if are coming from .. might know -- *flash message*.

To make this work, need to start sharing data between HTTP requests for the same user -- the most common way to do that is to implement a sessin for the user -- like:

- What *session managers* are available to help implemetns the sessions in Go.
- How U get customize session behavior based on your app’s needs.
- How to use sessions to safely and securely share data between requests for a particular user.

### Installing a Sessin Manager

There is a lot of *security considerations* when it comes working with sessions -- and proper implementation is non-trivial. Unless U really need to roll your own implemernation -- it’s a good idea to use an existing, will -tested package -- There are only a few good for Go which are not framework-specific -- 

- `gorilla/sessions`, simple and easy-to-use API and supports a huge range of 3rd session stores.
- `alexedwards/scs`
- `golangcollege/sessions`-- cookie based session.

```sh
go get github.com/golangcollege/sessions
```

### Setting up the session manager

In this, run through the process of setting up and using the golangcollege/sessions package, but if U are going to use it in a production app I recommended reading the documentation and API reference to familarize yourself with the full range of features.

First thing need to do is estabilish a session manager in our `main.go`file and make it available to our handler via the `applciation`struct -- the session manager holds the configuration settings for our sessions, and also provide some middleware and helper methods to handle the loading and saving of session data.

```go
type application struct {
    errorLog      *log.Logger
    infoLog       *log.Logger
    session       *sessions.Session
    snippets      *mysql.SnippetModel
    templateCache map[string]*template.Template
}
//... in the main() func
secret := flag.String("secret", "s6Ndh+pPbnzHbS*+9Pk8qGWhTzbpa@ge",
                      "Secret Key")
session := sessions.New([]byte(*secret))
app := &application{
    errorLog, infoLog, 
    session,
    &mysql.SnippetModel{db},
    templateCache,
}
```

For the session to work, also need to wrap our appliation routes with the middleware provided by the `Session.Enable()`method -- this loads and saves session data to and from the session cookie with every HTTP request and response as appropraite.

And, it’s important to note that we don’t need this middleware to act on *all* our application routes, don’t need on the `/static/`route.
