# Exercise 20 Big cities

There is no doubt that CSV is an important, useful, and polular formt, but in some ways, it has been eclipsed by another format. JSON, allows us to store numbers, text, lists, and dictionaries in a text format that is both readable and writable with various programming languages.

Just as can retreive CSV-formatted data with `pd.read_csv`, can retreive JSON-formatted data with `pd.read_json()`-- fore: When `read_json`sees this file, it sees each dict as a record, using the keys as column names, in many ways, reading this kind of JSON file is similar to creating a data frame with a list of dicts. fore:

```python
df['population'].describe()[['mean', '50%']]
df.loc[50:, 'population'].describe()['mean', '50%']
```

And  a JSON response consists of k-v pairs, in which a key servers as a uninque identifier for a value. And kyes must be strings, value can be of any data type -- including strings, numbers, and booleans.. Just note that JSON can store additinal k-v pairs with nested objects -- JSOn can be stored in a plain-text file with `.json`extension. like format:

```json
{
    "prizes": [
        {
            "year":"2019",
            "category":"chemistry"
            //...
        }
    ]
}
```

For this format, JSON consists of a top-level `prizes`key that maps to an array of dictionaries, one for each combination of year and category.. For a specified key connects to an array of dictionaries, each with .. stores an array to accommodate years in which multiple people were awarded in the same category.

```python
nobel = pd.read_json("nobel.json")
```

Just successuflly imported the file into pandas -- Pandas for this set the JSON’s top-level `prizes`key as the column name and created a Python dictionary for each k-v pair it parsed form the JSON. If:

`nobel.loc[2, "prizes"]`
`type(nobel.loc[2, 'prizes'])` # return a `dict`

Goal is to convert the data to tabular format. To do so, need to extract the JSON’s top-level k-v  piars to separate the `DataFrame`columns, also need to iterate over each dictionary in the list and extract its nested information. The process of moving *nested* records of data into a single, 1D list is called *flattening normalizing* -- the pandas library includes a built-in `json_nromalize`function to take care of the heavy lifting.

```python
chemistry_2019 = nobel.loc[0, 'prizes']
```

Can pass this variable to the `json_normalize`function’s `data`-- pandas extracts the 3 top-level dictionary keys to separate column in a new `DataFrame`-- the library still keeps the nested dictionaries from the `lautreates`list.

The `pandas.json_normalize()`is a powerful tool for flattening semi-structured JSON data into a flat data -- is particularly useful when dealing with deely **nested** json objects just like:

```python
data = [
    {"id": 1, "name": "John", "address": {"city": "New York", "state": "NY"}},
    {"id": 2, "name": "Jane", "address": {"city": "San Francisco", "state": "CA"}}
]
pd.json_normalize(data)
```

Can use the `record_path`to normalize the nested -- specified records.

```python
pd.json_normalize(ch2019, record_path='laureates')
```

Pandas can expand the nested dictionary into a new column -- lost original year and categories columns. So, `meat`parameter -- Fields to extract from the *parent* object -- these fields will be **repeated** for each record.

## Data Types

- Common mistakes related to basic types
- Fundamental concepts for slices and maps to prevent possible bugs, leaks or inaccuracies.
- Comparing valus in Go.

### Creating confusion with octal literals

In go, an integer literal starting with 0 is considered an octal integer -- so 010 base 8 equals 8 in base 10. For this, Octal integers are useful in different scenarios -- Suppose want to open a file using `os.OpenFile()`-- like:

```go
func OpenFile(name string, flag int, perm os.FileMode) (*os.File, error)
```

Use this:

```go
file, err := os.OpenFile("foo", os.O_RDONLY, 0644)
```

- `r`-- read permission 4
- `w`-- write permission 2
- `x`-- execute permission 1

So for `0644`for read/write for the owner, and read-only for groups and others and `0755`for read/write/execute for owner, and read/exectue for group and others.

### Neglecting integer overflows - 

Not understanding how integer overflows are handled in Go can lead to critical bugs -- this delves into this topic -- An integer overflow occurs when an arithmetic operation creates a value outside the range that can be represented with a given number of bytes. In go, an integer overflow can be detected at compile time generates a compliation error.

#### Detecting integer overflow when increment -- 

if want to detect an integer overflow during an increment operation with a type based on a defined size, can check the value against the `math`constants fore with an `int32`

```go
func Inc32(counter int32) int32 {
    if counter == math.MaxInt32 {
        panic("...")
    }
    return counter+1
}
```

Now -- `math.MaxInt, math.MaxUnit`are part of the `math`package.

#### Detecting integer overflows during addition - 

How can detect an integer overflow during an addition -- the answoer is to reuse the `math.MaxInt`like:

```go
func AddInt(a, b int) int {
    if a> math.MaxInt-b {
        panic("...")
    }
    return a+b
}
```

#### Detecting an integer overflow during multiplication

Multiplication is a bit more complex to handle -- have to perform checks against the minimal integer fore:

```go
func MultiplyInt(a, b int) int {
    if a==0 || b==0 {
        return 0
    }
    result := a*b
    if a== math.MinInt || b= math.MinInt {
        panic("integer overflow")
    }
    if result/b != a {
        panic("integer overflow")
    }
    return result
}
```

### Not understanding floating points

In go, there are just two floating-point types -- `float32`and `float64`-- The concept of a floating point was invented to solve the major problem with integers. To avoid bad surprises, need to know that floating-point arithmetic is an **approximation** of real arith. Fore:

```go
var n float32= 1.0001
fmt.Println(n*n)
```

Cuz making infinite values fit into a finite space isn’t possible, have to work with approximations. Once understand the float32 and float64 are just approximations -- The first implication is related to comparisions -- using the `==`to compare two floating-point can lead to inaccuacies. Insted, should compare their difference to see if it is less than some *small error value*. Fore, the `testify`lib -- has an `InDelta`func to assert that two values are within a given delta of each other.

### Understanding slice length and capacity

It’s just pretty common for Go developers to mix slice length and capacity or not understand them thoroughly. For efficiently handling core operations such as slice initialization and adding elements with `append copying slicing`. In go, a slice is backed by an array -- means that slice’s data is stored contiguously in ain data structure.

Internally a slice holds a pointer to the bcking array plus length and a capacity. Fore:

```go
s := make([]int, 3, 6)
```

In the case, `make`creates an array of 6 elements -- but cuz the length was set to 3 -- go initializes only the first three - also, cuz the slice is an `[]int`type, the first 3 elements are initialized to the zeroed value of an `int:0`, however, accessing an element outside the length range is just forbidden.

How can we use the re-maining space of the slice -- using the `append`like `s = append(s,2)`

For this example, the length of the slice is updated from 3 to 4 and if:

```go
s = append(s, 3, 4, 5)
```

Cuz an array is just a fixed-size -- can store the new element until element 4. When insert 5 the array is just already full -- go *internally creates another array* by doubling the capacity -- NOTE -- In go, a slice grows by doubling its size until contains 1024 elements. then grows by 25%.

NOTE-- the slice now references the new bcking array -- so what will happen to the prevous bcking array -- no longer referenced it -- it’s eventually freed by the garbage collector.

Slicing is an operation done on an array or a slice -- providing a half-open range -- the first included, the second is excluded.

```go
s1 := make([]int, 3, 6) // cap 6
s2 := s1[1:3] // cap : 6-1=5, cuz begin with 1
s2 = append(s2, 2) // len of s2 changed and only visible for s2
// if:
s2 = append(s2, 3)
s2 = append(s2, 4)
s2 = append(s2, 5) // this code leads to creating another backing array
```

For now, `s1`and `s2`now reference two different arrays, as `s1`is still a 3L, 6C capacity slice, still has some available buffer, so it keeps referencing the initial array.

### Inefficient slice Initialization

While initializing a slice using `make`, saw that have to provide a length and an optional capacity. Want to implment a `convert`function that maps a slice of `Foo`into a slice of `Bar`. -- like:

```go
func convert(foos []Foo) []Bar {
    bars := make([]Bar, 0)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

This logic of creating another array cuz the current one is full is repeated multiple times when add a 3rd element.. Assuming the input slice has 1000 elements, this algorithm requires allocating 10 backing arrays and copying more than 1000 elements in total from one array to another. Go runtime a helping hand fore:

```go
func convert(foo []Foos) []Bar {
    n := len(foos)
    bars := make([]Bar,0,n)
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

Internally, Go pre-allocates an array of n elements. and for the second approach is 

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, n)
    for i, foo := range foos {
        bars[i]= fooToBar(foo)
    }
    return bars
}
```

## Closures for DI

The pattern that we’re using to inject dependencies won’t work if your handlers are spread acorss multiple packages. in that case, an alternative approach is to create a `config`package, exporting `Appliation`struct and have your handler functions close over this to form a `closure`like

```go
func main(){
    app := &config.Application {
        ErrorLog: log.New(os.stderr, "ERROR\t", log.Ldate|log.Litem|log.Lshortfile)
    }
    mux.Handle("/", handlers.Home(app))
}

func Home(app *config.Application) http.HandleFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        ...
    }
}
```

### Centralized Error Handling

Neaten up our app by moving some of the error handling code just into helper methods -- this will help *separate our concerns* and stop us repeating code as we progress through the build.

```go
// The serveError helper write an error message and stack trace to the errorlog.
// then sends a generic 500 Internal Server Error response to the user.
func (app *application) serverError(w http.ResponseWriter, err error) {
	trace := fmt.Sprintf("%s\n%s", err.Error(), debug.Stack())
	app.errorLog.Println(trace)
	http.Error(w, http.StatusText(http.StatusInternalServerError), 500)
}

// The clientError helper sends a specific status code and corresponding description
// to the user. Use this later in the book to send responses like 400
func (app *application) clientError(w http.ResponseWriter, status int) {
	http.Error(w, http.StatusText(status), status)
}

// just for consistency, also implement a `notFound` helper
// simply a convenience wrapper around clientError
func (app *application) notFound(w http.ResponseWriter) {
	app.clientError(w, http.StatusNotFound)
}
```

For this:

- In the `serverError()`we use the `debug.Stack()`function to get a *stack trace* for the *current goroutine* and append it to the log message. Being able to see the execution path of the application via the stack trace and can be helpful when you are trying to debug errors
- In the `clientError()`-- use the `http.statusText()`to automatically generate a human-friendly text representation of a given HTTP status code.
- started using the `net/http`package’s named constants for HTTP status codes.

Once done, head back to the `handlers.go`file and update it to use the new helpers -- like:

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)

		// use the http.Error() function to send a 405 code and string
		app.clientError(w, http.StatusMethodNotAllowed)
		return
	}
	w.Write([]byte("Create a new method"))
}
```

### Isloating the Application routes

Our `main()`is beginning to get a bit crowded, so to keep it clear and focused like to remove the route declarations fro the application into a standalone `routes.go`file.

```go
func (app *application) routes() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/", app.home)
	mux.HandleFunc("/snippet", app.showSnippet)
	mux.HandleFunc("/snippet/create", app.createSnippet)

	fileServer := http.FileServer(http.Dir("./ui/static/"))
	mux.Handle("/static/", http.StripPrefix("/static", fileServer))

	return mux
}
```

Then, just update the `main.go`like:

```go
srv := &http.Server{
    Addr: *addr,
    ErrorLog: errorLog,
    Handler: app.routes(),
}
```

This is quite a bit neater, the routes for our application are now isolated and encapsulated in the `app.routes()`.

### Database-Driven Responses -- 

For our Snippetbox web app to beomce truly -- the ability to query this data store dynamically at runtime. There are many different data stores we *could* use for our application -- each with different pros and cons -- 

- *Connect to MySQL* -- from web application
- Create a *standalone models package* -- dbs logic is reusable and decoupled from web application.
- Use the appropriate functions in Go’s `database/sql`package to execute different types of SQL statements, and how to avoid common errors that can lead to your server runnig out of resources.
- Prevent SQL injection attackes by correctly using placeholder parameters.
- Use *transactions* can execute multiple SQL statements in one atomic action.

```sql
create table snippets
(
    id      INTEGER      NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title   VARCHAR(100) NOT NULL,
    content TEXT         NOT NULL,
    created DATETIME     NOT NULL,
    expires DATETIME     NOT NULL
);

-- Add an index on created column
create index idx_snippets_created ON snippets(created)

show table status like 'snippets'
```

Each record i this table will have an integer `id`which will act as the unique identifier for the text snippet. Then add some placeholder entires to the snippets table like:

```sql
INSERT INTO snippets (title, content, created, expires) VALUES (
'An old silent pond',
'An old silent pond...\nA frog jumps into the pond,\nsplash! Silence again.\n\n– Matsuo Bashō',
UTC_TIMESTAMP(),
DATE_ADD(UTC_TIMESTAMP(), INTERVAL 365 DAY)
);
```

#### Creating a new User

```sql
create user 'web'@'localhost';
grant select, insert, update on snippets.* to 'web'@'localhost';
-- pass with pasword
alter user 'web'@'localhost' identified by ''
```



