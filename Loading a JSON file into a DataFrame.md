# Loading a JSON file into a DataFrame

JSON can just be stored in a plain-text file with a `.json`-- And a JSON consists of a top-level `prizes`key that maps to an array of dictionaries -- for the DF, the `laureates`key conencts to an array of dictionaries -- each with its own `id`...like:

```json
{
    year: "2019",
    cateogry: "literature",
    laureates: [
        {
            id:...
        }, 
        {
            id:...
        }
    ]
}
```

Import functions in pandas have a consistent naming scheme -- each one consists of a `read`prefix -- used `read_csv()`function .. directly read is not ideal for analysis. and:

```python
type(nobel.loc[2, 'prizes'])
```

Goal is to convert the data to tabular format - need to extract the Json’s top-level k-v pairs to separate DF columns, also need to iterate over each dictionary in the list and extract its nested info. And the process of moving nested records of data into a single, one-dimensional list is called `flattening normalizing`-- The pandas library includes a built-in `json_normalize`func to take DF. just like:

```python
d.json_normalize(ch2019, record_path='laureates')
# to preserve the top-level k-v pairs, can pass a list with their names to parameters like:
pd.json_normalize(ch2019, record_path='laureates',
                  meta='year category'.split())
```

That just exactly `DataFrame`we want -- our normazliation strategy has worked successfully on a single dictionary from the prizes column, The `json_normalize()`function is smart enough to accept a `Series`of dictionaries and repeat the extraction logic for each entry -- like:

```python
data = nobel['prizes'] # return a series of dicts
# note that in the dict, there will be null laureates so:
data.apply(lambda dt: dt.setdefault('laureates', [])) # mutate in-place
json.normalize(data, record_path="laureates", meta=['year', 'category'])
```

#### Exporting a DF to a JSON file -- 

The `to_json()`just creates a JSOn string from a pandas returns the data. like:
`winners.to_json(orient=‘split’)`

### Reading from and writing Excel -- 

Note that:

```python
conda install xlrd openpyxl
```

And `pd.read_excel()`just supports many of the same parameters as `read_csv`. Including `index_col`to set the index column, `usecols`to select the columns, and `squeeze`to coerce a one-column `DF`into a `Series`object. like:

```python
pd.read_excel(
	io = "single.xlsx",
    usecols= [...],
    index_col="City"
)
# read multiple worksheets fore:
pd.read_excel("multiple.xlsx", sheet_name=0) # default, the first
pd.read_excel("multiple.xlsx", sheet_name='Date 1')

# note, to import all -- just pass an argument of `None` to the sheet_name, then 
# returns a dict with the workseet's names as keys.
workbook = pd.read_excel("multiple.xlsx", sheet_name=None)
workbook['Data 2']

# also, to specify a subset of worksheets to improve, can pass the `sheet_name` parameter a list of index
# position or worksheet names just like:
pd.read_excel(
	'mutliple.xlsx',
    sheet_name = ['data 1', 'data 3']
)
# or:
pd.read_excel("multiple.xlsx", sheet_name=[1,2]) # second and third
```

And to write to an Excel workbook requires a few more step then writing a CSV -- first, need to create an `ExcelWriter`object -- servers as the fundation of the workbook. like:

```python
excel_file = pd.ExcelWriter("baby_name.xlsx")
girls.to_excel(excel_writer=excel_file, sheet_name='Gris', index=False)
# ...
excel_file.close() # or just use the with block
# create a pandas excel writer using xlsWriter as the engine
with pd.ExcelWriter('output.xlsx', engine='xlsxwriter') as writer:
    df1.to_excel(writer, sheet_name='sheet1', index=False)
    df2.to_excel(writer, sheet_name='sheet2', index=False)
```

## about `nil`vs. empty slices

Go developers frequently mix `nil`and empty slices, may want to use one over the other depending on the use case. Meanwhile, some libraries make a distinction between the two.

- A slice is empty if lengh is 0
- A slice is nil if it equals to `nil`.

```go
func main(){
    var s []string // empty =true nil=true
    s=[]string(nil) // true true
    s= []string{} // nil false
    s= make([]string,0) // nil false
}
```

One of the main differences between a `nil`and an empty slice regards allocations -- initializing `nil`doesn’t require any allocation, which isn’t the case for an empty slice, and regardless of whether a slice is nil -- calling `append()`built-in function works. note that:

```go
var s1 []string
append(s1, "foo") // [foo]
```

Consequently, if a function returns a slice, shouldn’t do as in other languages and retur a non-nil for defensive reasons. And cuz `nil`just doesn’t requrie any allocation, should favor returning a `nil`instead of an empty slice. fore:

```go
func f() []string {
    var s []string
    if foo() {
        s= append(s, "foo")
    }
    if bar() {
        s= append(s, "bar")
    }
    return s
}
```

However, in the case where we have to produce a slice with known length, we should use `s:= make([]string, length)`-- like:

```go
func intsToStrings(ints []int) []string {
    s := make([]string, len(ints))
    for i, v := range ints {
        s[i]= strconv.Itoa(v)
    }
    return s
}
```

For -- `s:=[]string(nil)`-- this isn’t most widely used, but can be helpful as syntactic like:
`s := append([]int(nil), 42)`

Should also mention that some libraries distinguish between `nil`and empty slices. like;

```go
var s1 []float32
customer1 := customer{
    operations: s1,
}
b, _ := json.Marshal(customer1) // nil like: {"operations": null}
```

### Properly checking if a slice is empty

Namely, what is the idiomatic way to check if a slice contains elements -- in the example, call a `getOperations`func that returns a slice of `float32`- want to call a `handle`func only if the slice contains elements -- like:

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if operations != nil {
        handle(operations)
    }
}

func getOperations(id string) []float32 {
    operations := make([]float32, 0)
    if id == "" {
        return opertions
    }
    // some op
    return operations
}
```

For this the `getOperations()`never returns a `nil`slice -- returns an empty one -- therefore, the `operations!=nil`check will always be `true`. So:

```go
func getOperations(id string) []float32 {
    operations := make([]float32, 0)
    if id == "" {
        return nil
    }
    // some...
    return opreations
}
```

However, this also doesn’t work in all situations -- we’re not always in a context where we change the callee. Fore, if use an external library, won’t create a pull request jsut to change empty into `nil`slices. namely, how can check whether a slice is empty or nil -- solution is to check the length -- like:

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if len(operations)!=0 {
        hanlde(operations)
    }
}
```

`nil` and empty both return `false`for this.

### Making slice copies correctly

The `copy`built-in allows copying elements from a source slice into a destination slice -- Although it is a handy bulit-in functin, go developers sometimes misunderstand it. fore;

```go
src := []int{0, 1, 2}
var dst []int
copy(dst, src) // error!
```

To use `copy`effectively -- essential to understand that the number of elements copied to the dest corresponding the minimum *between* -- The source’s length and the dest’s length.

If want to perform a complete copy, the destination slice must have a length greater then or equal to the source slice’s length -- set up a length based on the source slice. `dst := make([]int, len(src))`, and there are different alternatives -- like: 

```go
src := []int{0,1,2}
dst := appedn([]int(nil), src...)
```

For this, append the elements from the source to a nil slice. Use `copy`is favor.

### Side effects using slice append

The `append`-- may have unexpected side effects in some situations -- in the following -- like:

```go
s1 := []int{1,2,3}
s2 := s1[1:2]
s3 := append(s2, 10)
```

For this, initialize an `s1`slice containing 3 elements, and `s2`is created from slicing s1 -- then we call `append`on `s3`. `s1`3l and 3p, and s2 is 1l and 2p. So, adding an element using `append()`checks whether the slice is full (length==cap) if it is not -- the `append()`adds the element by updating the backing array and returning a slice having a length. Therefore, if print -- 

```sh
s1=[1,2,10] s2= [2], s3=[2,10]
```

Should keep this in mind to avoid unintended consequences. If want to *protect* the 3rd for defensive reasons, meaning that dosn’t update like:

```go
func main(){
    s : = []int {1,2,3}
    sCopy := make([]int, 2)
    copy(sCopy, s)
    f(sCopy)
    result := append(sCopy, s[2])
}
```

And the second option can be used to limit the range of potential side effects to the first two elements only -- The option involves the `so-called`*full slice expression* -- `s[low:high:max]`-- creates a slice similar t the one created with the s[low:hight]-- fore:

```go
func main(){
    s := []int{1,2,3}
    f(s[:2:2]) // cap is 2
}
```

### Slices and memory Leaks

This section shows that slicing an existing slice or array can lead to memory leaks in some conditions. Image implementing a custom binary protocol -- A message can contain 1 M bytes, and the first 5 bytes just represent the message type -- consume these messages, and for auditing purposes, want to store the latest 1000 message types in the memory -- skeleton of our function like -- 

```go
func consumeMessages() {
    for {
        msg := receiveMessage()
        // do sth
        storeMessageType(getMessageType(msg))
    }
}

func getMessageType(msg []byte) []byte {
    return msg [:5]
}
```

For the `getMessage()`-- computes the message type by slicing the input slice -- test this IMP. we notice that app consumes about 1GB of memory fore -- `msg[:5]`creates a 5-length slice, its cap remains the same as the initial slice. The remaining elements are still allocated in the memory -- even if eventually `msg`is not referenced. And the backing array of the slice still contains 1M bytes after the slicing operation. Can do:

```go
func getMessageType(msg []byte) []byte {
    msgType := make([]byte, 5)
    copy(msgType, msg)
    return msgType
}
// ful expressions if:
func getMessageType(msg []byte) []byte {
    return msg[:5:5]  // not, go doesn't specify the behavior, for GC
} // so not recommended
```

## Installing a Dbs Driver

To use MySQL from Go web app need to install a dbs driver -- this essentially acts as a middleman -- translating commands between Go and the MySQL dbs itself. like:

```sh
go get github.com/go-sql-driver/mysql
```

### Creating a dbs connection pool

To so this, need Go’s `sql.Open()`func which like:

```go
db, err := sql.Open("mysql", "web:pass@snippetbox?parseTime=true")
```

The `parseTime=true`part of the DSN -- is a driever-specific parameters which instructs our driver to convert SQL `TIME`and `DATE`to go `time.Time`. And the `sql.Open()`returns a `sql.DB`object -- note that isn’t a database connection -- it’s a *pool of many connections*.

#### usage in web app -- 

How to sue `sql.Open()`-- in the `main.go` like:

```go
import (_ "github.com/go-sql-driver/mysql")

func openDB(dsn string) (*sql.DB, error) {
    db, err := sql.Open("mysql", dsn)
    if err != nil {
        return nil, err
    }
    if err = db.Ping(); err != nil {
        return nil, err
    }
    return db, nil
}
// ... in the main() func
// To keep the main() tidy, put the code for creating a conneciton pool into the
// separate below like
db, err := openDB(*dsn)
if err != nil {
    errorLog.Fatal(err)
}

// also defer a call to db.Close(), so that the connection pool is closed
defer db.Close()
```

- Cuz `main.go`file doesn’t actually use anything in the `mysql`package - so if try to import it normally the Go just compile error -- need the `init()`func to run so that it can register itself with the `database/sql`package.
- The `sql.Open()`dosn’t actually create any connections -- all it does is initialize the pool for future use. Actual connections to the dbs are established lazily -- and needed for the first time -- so just verify everything is set up correctly need to use the `db.Ping()`method to create a connection and check for any errors.
- Then call to the `defer db.Close()`is bit -- if `ctrl+c`or `errorLog.Fatal()`-- in both -- the program exits immediately and deferred function are never run. note that

### Designing a Dbs Model

Might want to think of a *service layer* or *data access layer*. The idea is that will encapsulate the code for working with MySQL in a separate packate to the rest of our application.

Start by using the `pkg/models/models.go`file to define the top-level data types that our dbs will use and return like

```go
var ErrNoRecord = errors.New("models: no matching record found")

type Snippet struct {
	ID             int
	Title, Content string
	Created        time.Time
	Expires        time.Time
}
```

noticed how the fileds of the `Snippet`struct correspond to the fields in the snippets table.

```go
type SnippetModel struct {
	DB *sql.DB
}

// Insert this will insert a new
func (m *SnippetModel) Insert(title, content string) (int, error) {
	return 0, nil
}

// Get return a specific snippet
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	return nil, nil
}

// Latest return the 10 most recent created
func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	return nil, nil
}
```

To use this model in the handlers we want to establish a new `SnippetModel`in the `main()`then inject it as a DI.

```go
type application struct {
    errorLog *log.Logger
    infoLog  *log.Logger
    snippets *mysql.SnippetModel
}
//...
app := &application{
    errorLog, infoLog, &mysql.SnippetModel{db},
}
```

#### Benefits of this structure

Setting your models up in this way might seem -- app grows it should start to become clearer -- 

- There is clean separation of concerns -- dbs logic isn’t tied to our handlers which means that handler responsibilities are limited to HTTP stuff.
- By creating a custom `SnippetModel`type and implementing methods -- single, neatly encapsulated object.
- cuz the model are defined as methods on an object -- there is the opportunity to create an interface and mock it
- have total convrol over which dbs is used at runtime
- And the directory structure scales nicely if your proj has multiple back ends. fore: *models/redis* package.

### Executing SQL statements

Update the `Snippet.Insert()`-- which:

```sql
INSERT INTO snippets (title, content, created, expires) 
VALUES(?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERNAL ? DAY))
```

In MySQL, using the `?`to indicate *placeholder parameter* for the data that want to insert in the dbs.

#### Executing the Query -- 

- `DB.Query()`-- for the `SELECT`
- `DB.QueryRow()`-- for `SELECT`that return a single row.
- `DB.Exec()`-- like `INSERT`and `DELETE`

So for this using the `Db.Exec()`method just like;

```go
func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	// write the sql statement -- split it over two lines for readability
	stmt := `INSERT INTO snippets (title, content, created, expires)
		VALUES(?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY))`

	// use the Exec() on the embedded connection pool to execute the statement
	result, err := m.DB.Exec(stmt, title, content, expires)
	if err != nil {
		return 0, err
	}

	// use the LastInsertId()
	id, err := result.LastInsertId()
	if err != nil {
		return 0, err
	}

	// id returned is the type of `Int64`
	return int(id), nil
}
```

Discuss the `sql.Result`interface returned by `Db.Exec()`-- this provides two methods like:

- `LastInsertId()`-- returns the integer (`int64`) generated by the dbs in response to a command
- `RowsAffected()`-- whcih returns the number of rows `int64`-- affected by the stmt.

#### Using the model in our Handlers

Bring this back to sth more concreted and demonstrate how to call this new code from the handlers like:

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)

		// use the http.Error() function to send a 405 code and string
		app.clientError(w, http.StatusMethodNotAllowed)
		return
	}
	// Create some variables holding dummy data --
	title := "0 snail"
	content := "0 snail\nClimb Mount Fuji,\nBut slowly!\n\n- Kobayashi Issa"
	expires := "7"

	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet?id=%d", id), http.StatusSeeOther)
}
```

