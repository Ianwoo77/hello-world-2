# Pandas Indexes

Don’t necessarily need to use the index to select rows from a data frame but it does make things easiler to understand and yield clearer code. often want to use one of a data frame’s existing columns as an index -- Pandas makes it easy to do this with `set_index()`method - like:

```python
df = pd.read_csv(
    "nyc-parking-violations-2020.csv",
    usecols=[
        "Date First Observed",
        "Registration State",
        "Plate ID",
        "Issue Date",
        "Vehicle Make",
        "Street Name",
        "Vehicle Color",
    ],
)
# set index to Issue Date column
df =df.set_index('Issue Date')
```

Just noticed that `set_index`returns a new data frame based on the original. The core pandas developers have warned that this is a bad idea cuz it makes incorrect assumptions about memory and performance. Say, there is no benefit to using `inplace=True`. like:

```python
df.loc['01/02/2020 12:00:00 AM', 'Vehicle Make']
```

See two-argument form of `loc`means first passing a row selector and then passing a column selector. In this case, only interested in a single column for `Vehicle Make`.

`df.loc['01/02/2020 12:00:00 AM', 'Vehicle Make'].value_counts()`

This just returns a series in which the index contains the different vehicle makes and the values are the counts. Sorted from highest to lowest -- can limit our results to the three most common makes by adding `head(3)`.

Once have this, can also check other columns.

`df.loc['06/01/2020 12:00:00 AM', 'Street Name'].value_counts().head(5)`

Again, select rows via the index and then select a column, pass this to `value_counts()`and get the top 5 results. but now we want to make queries against the `VehicleColor`-- thus need to remove `Issue Date`as the index and put `Vehicle Color`in its place, just like:

```python
df = df.reset_index()
df= df.set_index('Vehicle Color')
```

Thanks to method chaining, can do it in a single line of code like:

`df= df.reset_index().set_index('Vehicle Color')`

First, need to find only those cars that are blue or red like:

```python
df.loc[['BLUE', 'RED'], 'Vehicle Make']
# can use the `value_counts()` to find the most common make and restrict it to the top-ranking brand
(
    df.loc[['BLUE', 'RED'], 'Vehicle Make']
    .value_counts()
    .head(1)
)
```

- What three car makes were most often ticketed from Jan 2 through Jan.10 like:

  ```python
  df = df.set_index('Issue Date')
  df = df.sort_index()
  df.loc['01/02/2020 12:00:00 AM':'01/10/2020 23:59:59 PM', 'Vehicle Make'].value_counts().head(4)
  ```

- How many tickets did the the second-most-ticketed car get in 2020.

  ```python
  (
      df
      .set_index('Issue Date')
      .sort_index()
      .loc['01/02/2020 12:00:00 AM':'01/10/2020 23:59:59 PM', 
           'Vehicle Make']
      .value_counts()
      .head(3)
  )
  ```

### Working with multi-indexes

Every data frame has an index, giving labels to the rows -- have already seen that we can use the `loc`accessor to retreive one or more rows using the index. And to retrieve all the rows with the index value a -- `df.loc['a']`-- just remember that the index doesn’t necessarily contain unique values -- `loc['a']`may returna sereies of values representing a single row.

Cuzt the world just full of hierarchical info, or info that is easiler to process if we nake it hierarchical. Fore, every business wants to know its sales figures -- but getting a single number doesn’t let you analyze the info in useful way. So, want to break ..

```python
filename = "nyc-parking-violations-2020.csv"
total_rows = sum(1 for row in open(filename))
rows_to_read = int(total_rows * 0.2)
df = pd.read_csv(
    "nyc-parking-violations-2020.csv",
    usecols=[
        "Date First Observed",
        "Registration State",
        "Plate ID",
        "Issue Date",
        "Vehicle Make",
        "Street Name",
        "Vehicle Color",
    ],
    nrows=rows_to_read
)
```

## Slice and Pointers

have seen that slicing can cause a leak cuz of the slice capacity -- but -- what about the elements, which are still part of the backing array but outside the length range -- Does the **GC** collect them -- like:

```go
type Foo struct {
    v []byte
}
```

Want to check the memory allocations after each step as follows -- 

1. Allocate a slice of 1000 `Foo`elements
2. Iterate over each `Foo`, and for each one, allocate `1MB`for v slice
3. Call `keepFirstTwoElementOnly`-- which returns only the first two element using slicing, and then call `GC`.

```go
func main(){
    foos := make([]Foo, 1000)
    printAlloc()
    
    for i:=0; i<len(foos); i++ {
        foos[i]= Foo {
            v: make([]byte, 1024*1024),
        }
    }
    printAlloc()
    
    two := keepFirstTwoElementsOnly(foos)
    runtime.GC()
    printAlloc() // also 1024072KB!
    runtime.KeepAlive(two)
}
func keepFirstTwoELementsOnly(foos []Foo) []Foo {
    return foos[:2]
}
```

For this, the first ouput allocates about 83KB of data, indeed, allocated 1000 zero values of `Foo`-- and the second allocates 1MB per slice, which increases memory -- notice that the GC did not collect the remaining 998 elements after the last step-- It’s essential to keep this rule in mind when working with slices -- if the element is a pointer or a struct with pointer fields -- the elements won’t be reclaimed by the GC.

Cuz `Foo`contains a slice and a slice is a pointer on top of a backing array -- the remaining 998 Foo elements and their slice aren’t reclaimed -- Therefore, even though these 998 elements can’t be accessed, they *stay in memory as long as the variable returned* by `keepFirstTwoElementsOnly`is referenced.

So, what are the options to ensure that we don’t leak the remaining `Foo`elements -- the first option -- is to create a copy of the slice -- like:

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    res := make([]Foo, 2)
    copy(res, foos)
    return res
}
```

For this, cuz we just copy the first two elements of the slice, the GC knows that the 998 elements won’t be referenced anymore and can now be collected.

And, there is also a second option if we want to keep the underlying cap of 1000 elements -- like;

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    for i:=2; i<len(foos); i++ {
        for[i].v=nil // set to nil, GC can collect 998 backing arrays
    }
    return foos[:2]
}
```

For these options -- the first creates a copy of `i`elements -- must iterate from element 0 to i. The second option sets the remaining slices to `nil`-- so it must iterate from element i to n.

### map initializaion

A *map* just provides an undordered collection of k-v pairs in which all the keys are distinct. And internally, hash table is an array of buckets, and each bucket is a pointer to an array of k-v pairs. And an array of 4 elements backs the hash table. Each op is done by associating a key to an array index. This step relies on a *hash function*. And this func is stable cuz we want it to return the same bucket.

Note in the case of insertion into a bucket that is already full (bucket overflow) - go just creates another bucket of 8 elements and links the previous bucket to it. Namely -- regarding reads, updates, and deletes, go must calculate the corresponding array index -- then go iterates sequentially over all the keys until it finds the provided one. Therefore, the worst-case time complexity for these 3 operations is O(p) -- p is total number of elements in the bucket.

#### Initialization -- 

```go
m := map[string]int {
    "1":1,
    "2":2,
    "3":3,
}
```

Internally, this map is backed by an array consisting of a single entry -- a single bucket. If add 1M elements -- a single entry won’t be enough cuz finding a key -- *going over thousands of buckets*. And this is why a map should be able to grow automatically to cope with the number of elements.

When a map grows, it doubles its number of buckets -- what are the conditions for a map to grow -- 

- The average number of items in the buckets is greater than a constant value, 6.5 fore
- Too many buckets have overflowed.

So, when a map grows -- all the keys are dispatched again to all the buckets. Could initialze a map with a given size or capacity -- this avoids having to keep repeating the costly slice growth operation. The idea is similar for maps, can use the `make`to provide an initial size when creating. Want to initialze a map that will contain 1M like:
`m := make(map[string]int, 1000000)`

Internally, the map is created with an appropriate number of buckets to store 1M elements. And specifying size `n`does not mean making map with a maximum number of n elements. Can still add more than n elements if needed.

### Maps and memory leaks

```go
m := make(map[int][128]byte)
// 1. Allocate an empty
// 2. Add 1M elements
// 3. Remove all the elements and GC
n := 1000000
m := make(map[int][128]byte)
printAlloc()  // 0

for i:=0; i<n; i++ {
    m[i]=randBytes()
}
printAlloc()  // 461mb
for i:=0; i<n; i++ {
    delete(m, i)
}
runtime.GC()
printAlloc() // also 293MB 
runtime.KeepAlive(m)
```

The reason is that the number of buckets in a map **cannot shrink**. Therefore, reoving elements from a map doesn’t impact the number of existing buckets. -- it just zeroes in the buckets. So a `map`can only grow and have more buckets -- it never shrinks.

What are the solutions if don’t want to *manually* restart our service to clean the amount of memory consumed by the map -- One solution could be to re-create a copy of the current map at a regular pace. FORE-- every hour, can build a new map, copy all the elements, and release the previous one.

And another solution would be change the map type to store an array pointer. like: `map[int]*[128]byte`-- it doesn’t solve the fact have a nubmer of buckets - each bucket entry will reserve the size of poitner for the value instead of 128 bytes.

### Comparing values correctly

When is it appropriate to use `==`and what are the alternatives -- like:

```go
type customer struct {
    id string
}
func main(){
    cust1 := customer{id:"x"}
    cust2 := customer{id:"x"}
    fmt.Println(cust1==cust2)  // valid and return true
}

// but if add like:
type customer struct {
    id string
    operations []float64
}
```

For this, might expect -- doesn’t compile -- invalid operation -- `[]float64`cannot be compared. Namely, These operators don’t work with slices or maps -- 

- *channels* -- tow are equal by the same call to `make`are both `nil`.
- *interfaces* -- identical dynamic types and equal dynamic values or both `nil`.
- *Pionters* -- same value in memory or both are `nil`
- *Struct arrays* -- wheher they are composed of similar types

For thse, `Reflection`is a form of metaprogramming, it refers to the ability of an application to introspect and modify its struct and behavior. Can use the `reflect.DeepEqual`-- reports whether two elements are deeply equal by recursively traversing two values. like:

```go
cus1 = customer{id:"x", operations: []float64{1.}}
cus2 = customer{id:"x", operations: []float64{1.}}
fmt.Println(reflect.DeepEqual(cust1, cust2)) // true
```

For - `DeepEqual()`-- 

1. makes the dinstinction between empty and `nil`.
2. has performance penalty.

```go
func (a customer) equal(b customer) bool {
    if a.id != b.id{
        return false
    }
    if len(a.operations) != len(b.operations) {return false}
    for i:=0; i<len(a.operations); i++ {
        if a.operations[i]!=b.operations[i]{
            return false
        }
    }
    return true
}
```

## Using the Model in handlers

```go
func(app *appliation) createSnippet(w http.ResponseWriter, r *http.Requset) {
    if r.Method != http.MethodPost {
        w.Hader().Set("Allow", http.MethodPost)
        app.clientError(w, http.StatusMethodNotAllowed)
        return
    }
    
    title := "..."
    content := "..."
    expires := "7"
    id, err := app.snippet.Insert(title, content, expires)
    if err != nil {
        app.ServerError(w, err)
        return
    }
    http.Redirect(w, r, fmt.Sprintf("/snippet?id=%d", id), http.StatusSeeOther)
}
```

### Placeholder parameters

In the code constructed our SQL Statement using placeholder parameters - where `?`acted as a placeholder for the data want to insert. The reason of using this placeholder parameters to construct our query is to help avoid SQL injection attacks from any untrusted user-provided input.

1. `DB.Exec()`-- creates a new *prepared statement* on the dbs using the provided SQL -- the dbs parses and comiples the statement -- stores it ready for execution.
2. In the second separate step, `Exec()`passes the parameter values to the dbs. The dbs then executes the prepared statement using these parameters. Cuz the parameters are transimtted later-- after the statement has been compiled, the dbs treats them as pure data. They can’t change the `intent`of the statement.
3. Then closes (or deallocates) the prepared statement on the dbs.

Just note that the placeholder parameter syntax just differ dependin on dbs provider -- MySQL, SQLServer, using `?`and PostgreSQL using `$N`.

### Single-record SQL Queries -- 

The pattern for `SELECT`ing -- a single record from the dbs is just a little more complicated -- how to do it updating our `SnippetModel.Get()`method so that it returns a single specific snippet based on its ID.

```sql
select id, title, content, created, expires from snippets
where expires> UTC_TIMESTAMP() and id = ?
```

For this, cuz `snippets`table uses the `id`column as its PK this query will only ever return exactly one row. So the code:

```go
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	// writes the SQL statement want to execute
	stmt := `SELECT id, title, content, created, expires from snippets
		where expires > UTC_TIMESTAMP() and id= ? `

	// use the QueryRow() method on the connection pool to execute
	// sql statement
	row := m.DB.QueryRow(stmt, id)

	// initialize a pointer to a new zeroed snippet struct
	s := &models.Snippet{}

	// Use the row.Scan() to copy the values from each field in sql.Row to the
	// corresponding filed in the Snippet field.
	err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
	if err != nil {
		// if the query return no rows, will return a sql.ErrNoRows
		if errors.Is(err, sql.ErrNoRows) {
			return nil, models.ErrNoRecord
		} else {
			return nil, err
		}
	}

	// if everything ok
	return s, nil
}
```

### Type Conversions -- 

Behind the scenes of `rows.Scan()`your driver will automatically convert the raw output from the SQL dbs to required native Go types -- Usually:

- `CHAR VARCHAR TEXT`to `string`
- `BOOLEAN`to bool
- `INT`to int, `BIGINT`to `int64`
- `DECIMAL NUMERIC`to `float`
- `TIME DATE TIMESTAMP`to `time.Time`

Note that in the DSN -- MySQL driver is that need to use the `parseTime=true`parameter in our DSN. Force it to convert `TIME`and `DATE`fields to `time.Time`-- otherwise it returns these as `[]byte`objects.

#### Using the model in our handlers

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	// Extract the value of id parameter from the query string and try to
	// convert it to an integer using the strconv.Atoi() function. like:
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}

	// Use the SnippetModel object's Get to retrieve the data for a
	// specific record based on its ID
	s, err := app.snippets.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w)
		} else {
			app.serverError(w, err)
		}
		return
	}
	fmt.Fprintf(w, "%v", s)
}
```

Additional Info for this -- Sentinel errors and `errors.Is()`-- which was introduced in go 1.13 -- to check whether an error matches a specific value. There is a couple of things about this -- The first thing is that `sql.ErrNoRows`is an example of what is known as a sentinel error -- which can roughly deifne as an `error`object stored in an global variable. Typically u create them using the `errors.New()`-- And own `models.ErrNoRecord`error that we just created is also an example of a sentinel error.

```go
// older version of go
if err == sql.ErrNoRows {
    // do sth
}else {
    // do sth
}
// from Go 1.13 like:
if errors.Is(err, sql.ErrNoRows) {
    
}
```

For this, After Go 1.13 introduced the ability to *wrap* errors to additional info -- if an error is wrapped, not work -- `errors.Is()`works by unwrapping errors - if necessary.

Can also:

```go
s := &models.Snippet{}
err := m.DB.QueryRow("Select ...", id).Scan(&s.ID, &s.Ttile, &s.Created, &s.Expires)
```

### Multiple-record SQL Queries -- 

Finally, look at the pattern for executing SQL statements which return mutliple rows. Demonstrates by updating the `SnippetModel.Latest()`method to return the *most recently created* snippets using the following SQL Query like:

```sql
SELECT id, title, content, created, expires FROM snippets
WHERE expires > UTC_TIMESTAMP() ORDER BY created DESC LIMIT 10
```

Then modify the snippets.go file like:

```go
func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	// just write the SQL statement first
	stmt := `SELECT id, title, content, created, expires from snippets
		WHERE expires> UTC_TIMESTAMP() ORDER BY created DESC LIMIT 10`

	// use the Query() method on the connection pool to execute our SQL statement
	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	// defer rows.Close() to ensure that the sql.Rows resultset is always properly
	// closed before the latest() returns.
	defer rows.Close()

	// initialize an empty slice to hold the models.Snippets object
	snippets := []*models.Snippet{}

	// Use rows.Next() to iterate through the rows in the resultset.
	for rows.Next() {
		s := &models.Snippet{}
		// use Scan() to copy the values from each field
		err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
		if err != nil {
			return nil, err
		}
		snippets = append(snippets, s)
	}

	// note, when the rows.Next() loops has finished, we call the rows.Err() to retrieve
	// any error was encountered during the iteration. -- note it's important to
	// call this -- don't assume that a successful iteration
	if err = rows.Err(); err != nil {
		return nil, err
	}

	// every ok
	return snippets, nil
}
```

#### Using the Model in our handlers -- 

For now, head back to `handlers.go`file and update the `home`handler to use the `SnippetModel.Latest()`method, dumping the snippet contents to a http response.

```go
s, err := app.snippets.Latest()
if err != nil {
    app.serverError(w, err)
    return
}
for _, snippet := range s {
    fmt.Fprintf(w, "%v\n", snippet)
}
```

Transactions and other Details -- So long as use the `database/sql`package -- the Go code you write will generally be portable and will work with any kind of SQL dbs. This means that your app isn’t so tightly coupled to the dbs that you are currently using, and the theory is that you can swap dbs in the future without re-writing all of your code.