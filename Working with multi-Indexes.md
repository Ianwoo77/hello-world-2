# Working with multi-Indexes

Every data frame can has an index, giving labels to the rows -- have already seen taht can use the `loc`accessor to retreive one or more rows using the index -- fore can use: `df.loc['a']`-- may return a series of values representing a single row -- but it also may return a data frame whose rows all have the index value a. The world is just full of hierarchical info -- or info that is easier to process if just make it hierarchical.

Fore, create some random sales data for 3 products cover 36 months from like:

```python
g = np.random.default_rng(0)
df = pd.DataFrame(g.integers(0, 100, [36, 3]), columns=[*"ABC"])
df["year"] = [2018] * 12 + [2019] * 12 + [2020] * 12
df['month']='''Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'''.split()*3
```

For now, could set the index, based on the `year`column as follow like:

`df = df.set_index('year')`

That would not give us any special access to the month data, which would like to have part of our index. Can create a multi-index by passing a list of columns to `set_index`like:

`df = df.set_index(['year', 'month'])`

Remember that when creating a multi-index, want the most general part to be on the outside and thus be mentioned first. If create a multi-index with dates, you use `year...`in that order. If U create a multi-index for your company’s sales data, you might use region.., fore, for this dataframe, can get all sales data for just products A and C in 2018 like:

`df.loc[2018, ['A', 'C']]`

Notice that we are still applying the same rule we’ve always used with `loc`-- the first argument describes the row(s) we want, and the second arg describes the column(s) want.

Note: **Tuples** are typically used in a multi-index situation when want to sepcify a specific combination of index levels and values -- fore, looking for 2018 and June just like:

```python
df.loc[(2018, 'Jun'), ['A', 'C']]
```

And if we want all data for 2018 and 2020, just like: 

`df.loc[[2018,2020], ['B', 'C']]`

What if we want to get all the data from June in both 2018, and 2020 -- just like:

```python
df.loc[[(2018, 'Jun'), (2020, 'Jun')]]
```

And, what if we just want to look at all values from June, July, or August across all three years -- Can use slice.

```python
df.loc[([2018, 2019, 2020], ['Jun', 'Jul', 'Aug'])]  # note, DOES NOT work!!!
df.loc[([2018, 2019, 2020], ['Jun', 'Jul', 'Aug']), 'A':'C'] # work
df.loc[(slice(None), ['Jun', 'Jul', 'Aug']), :] # work
df.loc[(:, ['Jun', 'Jul', 'Aug']), :] # error! cuz pthon syntax error -- only in bracket for :
```

And sure enough, that works -- u can think of `slice(None)`as a way of indicating to pands that you are willing to have all values as a wildcard.

State SAT Scores-- With multi-index, can set the index not just to a single column but rather to multiple columns -- fore, a data frame containing sales data -- we may want sales broken down by year and then further borken down by region -- once use this -- look a summary of sectors frome the SAT..

## Control Structures

- How a `range`loop assigns the element values and evaluates the provided expression
- Dealing with `range`loops and pointers
- Preventing common map iteration and loop -- breaking mistakes
- Using `defer`inside a loop

There is no `do`or `while`loop in Go, only a generalized `for`-- this delves into the most common mistakes related to control structures, with:

### Elements are copied in `range`loops

And a `range`is a convenient way to iterate over various data structurs -- don’t have to handle an index and the termination state -- may forget or be unaware of how a `range`loop assigns values, leading to common mistakes -- 

Concepts -- A `range`loop allows iterating over different data structures -- `string, Array, Pointers to array, slice, map` and `Receiving Channel`. Compared to a classic `for`-- a `range`loop is a convenient way to iterate over all the elements of one of these structures -- its concise syntax -- it’s also less error-prone cuz don’t have to handle the condition expression and iteration variable manully.

In some cases, may only be just interested in the element value, not the index -- 

#### Valure Copy

Understanding how the values is handled during each iteration is critical for using a `range`loop effectively, see how it works with a concrete example -- Create an `account`struct like:

```go
type account struct {
	balance float32
}

func main() {
	accounts := []account{
		{balance: 100.},
		{balance: 200.},
		{balance: 300.},
	}
	for _, a := range accounts {
		a.balance += 100
	}
	fmt.Println(accounts) // 100 200 300 
}
```

In Go, everythin we assign is just a copy -- 

- If assign the result of a function returning a `struct`, it performs a copy of that struct
- If assign the result of a function returning a pointer, it performs a *copy of the memory address*.

It’s just a crucial to keep this in mind to avoid common mistakes, including those releated to `range`loops, indeed, wehn a `ragen`loop iterate over a data structure, it performs a copy of each element to the value varaible. 

there are just two options -- access the elementusing the slice index, can be achieved with either classic `for`or a `range`loop using the index instead of the value variable -- 

```go
for i:= range accounts {
    accounts[i].balance += 1000
}
for i:=0; i<len(accounts); i++ {
    accounts[i].balance+=1000
}
```

Using slice element -- 3rd -- Another option is to keep using the `range`and access values but modify the slice type to a slice of *account pointers*. Just like:

```go
accounts := []*account {
    {...} // same
}
for _, a := range accounts {
    a.balance += 1000  // a.balance += 1000 updates the slice element
}
```

However, this option has two downsides -- it requires updating the slice type may not always be possible, 

### How args are evaluated in `range`

How this expression evaluated -- when using a `range`-- this is an essential point to avoid common mistake. like:

```go
s := []int{0,1,2}
for range s {
    s = append(s, 10)
}
```

Note, the provided expression is evaluated *only once* -- before the beginning of the loop -- in this -- *evaluated* means that provided is copied to a *temporary* variable, and then `range`iterates over this variable. The `range`loop uses this temporary variable -- the original slice `s`is updated during each iteration. For this, each step results in appending a new element -- after 3 steps, have go over all the elements in deed, the temporary `slice`used by `range`remains a 3 length slice. -- so the loop completes after 3 iterations. - note that this behavior is **different** with a classic `for`.

#### Channels

See a concrete example based on iterating over a channel using a `range`- create two groutines, like:

```go
func main() {
	ch1 := make(chan int, 3)
	go func() {
		ch1 <- 0
		ch1 <- 1
		ch1 <- 2
		close(ch1)
	}()

	ch2 := make(chan int, 3)
	go func() {
		ch2 <- 10
		ch2 <- 11
		ch2 <- 12
		close(ch2)
	}()
	ch := ch1
	for v := range ch {
		fmt.Println(v)
		ch = ch2  // 0 1 2 just
	}
}
```

In this example, same logic applies regarding how the `range`expression is evaluated -- the expression is evaluted, the exression provided to `range`is a `ch`channel pointing to `ch1`. range just iterating over ch1 not ch2. The `ch=ch2`statement isn’t without effeciting -- cuz assinged ch to the second, if call `close(ch)`-- will close the second, not the first.

#### Array

Cuz the `range`expression is just evaluated before the begining of the loop what is assigned to the temporary loop is a copy of the array like:

```go
func main() {
	a := [3]int{0, 1, 2}
	for i, v := range a {
		a[2] = 10
		if i == 2 {
			fmt.Println(v)  // run once
		}
	}
}
```

Note that -- the `range`operator creates a copy of the array, meanwhile, the loop doesn’t update the copy, it updates the original array a -- therefore, the value of `v`during the last iteration. If want to print the actual value of the last element, can do -- 

- By accessing the element from its index like:

  ```go
  a := [3]int{0,1,2}
  for i:= range a {
      a[2]=10
      if i==2 {
          fmt.Println(a[2])
      }
  }
  ```

- Using an array pointer like:

  ```go
  a := [3]int{0,1,2}
  for i, v := range &a {
      a[2]=10
      if i==2 {
          fmt.Println(v)
      }
  }
  ```

### Impacting of using pointer elements in `range`loops

Clarify the rationale for using a slice or a map of pointer elements -- 3 main cases -- 

1. in terms of semantics, storing data using pointer semantics implies sharing the element.

   ```go
   type Store struct {
       m map[string]*Foo
   }
   func (s Store) Put(id string, foo *Foo) {
       s.m[id]= foo
   }
   // using the pointer implies that the `Foo`element is sharing by both the caller of Put and Store
   ```

2. Sometimes manipuate, can be handy to store pointers directly in our collection instead of values

3. If store large structs, and these are frequently mutates, we can use pointers intead to avoid a copy and an insertion for each mutation -- like:

   ```go
   func updateMapVal(mapVal map[string]LargeStruct, id string) {
       value := mapValue[id]
       value.foo = "bar"
       mapValue[id]=value
   }
   func updateMapPointer(mapPointer map[string]*LargeStruct, id string) {
       mapPointer[id].foo= "bar" // muteate
   }
   // Cuz the `updateMapPointer` accepts a map of pointers, the mutation of the `foo`field can be done.
   ```

It’s time to discuss the common mistake with pointer elements in `range`loops - will consider the following like:

- A `Customer`struct reprsenting a customer
- A `Store`that holds a map of `Customer`pointers.

```go
type Customer struct {
	ID string
    Balance float64
}
type Store struct {
    m map[string]*Customer
}
```

And the following method just iterates over a slice of `Customer`elements and stores them in the `m`map like:

```go
func (s *Store) storeCustomers(customers []Customer) {
    for _, customer := range customers {
        s.m[customer.ID]= &customer // store the csutomer pointer in the map
    }
}
```

In this, just iterate over the input slice using the `range`opreator and store `Customer`pointers in the map. If:

```go
s.StoreCustomer([]Customer{
    {ID: "1", Balance: 10},
    {ID: "2", Balance: -10},
})
// get both {2, -10}
```

Can see, instead of storing different both same. Note that iterating over the `customers`slice using the `range`- regardless of the number of elements, create a single customer variable with a fixed address. fore:

```go
func (s *Store) storeCustomer(customers []Customer) {
    for _, customer := range customers {
        fmt.Printf("%p\n", &customer) // all same
    }
}
```

At the end of the iterations, have stored the same pointer in the map multiple times. So, how to fix -- just like:

```go
func (s *Store) storeCustomers(customers []Customer){
    for _, customer := range customers {
        // current is variable referencing a unique Customer
        current := customer
        s.m[current.ID]= &current
    }
}
```

The other is just to store a pointer like:

```go
func (s *Store) storeCustomers(customers []Customer) {
    for i:= range customers {
        customer := &customers[i]  // assign a pointer
        s.m[customer.ID]=customer
    }
}
```

In this, the `customer`is now a pointer. initialized during each iteration, has a unique address, so good. So when iterating over a data structure using a `range`-- must recall that al the values are assigned to a unique variable with a single unique address.

## Transactions and Other Details

The `database/sql`package -- essentially provides a std interface between Go app and the world of SQL Dbs. So long as you use the `database/sql`package the go code U write will generally be portable and will work with any kind of SQL dbs-- This means that your app isn’t so tightly coupled to the dbs that U are currently using. It’s important to note that while `database/sql`generally does a good job of proiding a std interface for working with SQL dbs.

#### Verbosity -- 

The upside of the verbosity is that our code is non-magical - can understand and control exactly what is going on. And one thing that Go doesn’t do well is managing `NULL`values in the dbs records. If title in the tble contains a `NULL`in a particular way -- queried that row, the `rows.Scan()`would return an error cuz it can’t conver `NULL`into a string like:

`sql: scan error on column index - unsupported scan`.

The fix for this is to just change the field that U are scanning into from a `string`to a `sql.NullString`type. But, as a rule, the eaiest thing to do is simply avoid `NULL`values altogether -- set `NOT NULL`constraints on all dbs columns.

### Working with Transactions

It’s just important to realize the calls to `Exec, Query, QueryRow`can use *any connection* from the `sql.DB`pool. Even U have just two calls to `Exec()`immediately -- sometimes this is not acceptable. FORE, lock a table..

To guarantee that the same connection is used U can wrap multiple statement in a transaction basic pattern like:

```go
type ExampleModel struct {
    DB *sql.DB
}
func (m *ExampleModel) ExampleTransaction() error {
    // Calling the `Begin()`on the connection creates a new sql.Tx
    // object, which represents the in-progress dbs transaction
    tx, err := m.DB.Begin()
    if err != nil {
        return err
    }
    
    // then call Exec() on the transaction, passingin statement and any parameters. Note that the Exec()
    // is called on the transaction object just created, not the connection pool
    _, err := tx.Exec("INSERT INTO ...")
    if err != nil {
        // if there is any error..
        tx.Rollback()
        return err
    }
    
    // carry out another 
    _, err := tx.Exec("Update ...")
    if err != nil {
        tx.Rollback()
        return err
    }
    
    // If there are no errors, the statements in the trasnaction can be commiteed to the dbs
    // with the tx.Commit() method like:
    err = tx.Commit()
    return err
}
```

Transactions are also super-useful if you want to execte multiple SQL statements as a *single* atomic action. So long as you use the `tx.Rollback()`method in the event of any errors -- the transaction ensures that either -- 

- All statements are executed successfully
- No statements are executed at all.

#### Managing Connections

And the `sql.DB`connection pool is made up of connections which are either idle or *in-use* -- by default, there is no limit on the maximum number of open connections at one time.

#### prepared statemens -- 

As mentioned - the `Exec(), Query(), QueryRow()`methods all use prepared statements behind the scenes to help prevent SQL injection attacks. They just set up prepared statements on the dbs conenction, run it with the parameters provided, and then close the prepared statement.

Rather inefficient cuz we are creating and re-creating the same prepared statements every single time. In theory, a better approach could be to make use of `DB.Prepare()`method to create own prepared statement once, and re-use that instead. And this is particularly true for complex SQL statements, and are repeated very often. fore:

```go
type ExampleModel struct {
    DB *sql.DB
    InsertStmt *sql.Stmt  // embed it alongside the connection pool
}

// create a ctor for the model
func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    // Use the prepare method to create a new statement for the current connection pool. this returns a 
    // sql.Stmt object which represents the prepared statement.
    insertStmt, err := db.Prepare("INSERT INTO...")
    if err != nil {
        return nil, err
    }
    
    // store it in our object
    return &ExampleModel{db, insertStmt}, nil
}

// Any methods that implement against the `ExampleModel`object will have access to the statement
func (m *ExampleModel) Insert(args ...) error {
    // also support the Query() and QueryRow()
    _, err := m.InsertStmt.Exec(args...)
    return err
}

// in the web app's main will need to initialize a new struct using the ctor func
func main(){
    db, err := sql.Open(...)
    if err != nil{
        errLog.Fatal(err)
    }
    defer db.Close()
    
    // then create a new ExampleModel object, includes the prepared statement
    exampleModel, err := NewExampleModel(db)
    if err != nil {
        errLog.Fatal(err)
    }
    
    // defer a call to Close on the prepared statement to ensure that it is 
    // properly closed before the main() terminates
    defer exampleModel.InsertStmt.Close()
}
```

Actually happens is that the first time a prepared statement is used -- gets created on a particular dbs connection. Note that the `sql.Stmt`object then **remembers** which connection in the pool was used. Note, if that connection is closed or in use -- the statement will be re-prepared on another connection.

Note that under heavy load, it’s possible that a large amount of prepared statemens will be created on multiple connections -- This can lead to statements being prepared and re-prepared more often than you would expect. So there is a trade-off to be made between performance and complexity. For most cases, suggest that using the regular `Query()...`without preparing statements youself.

### Dynamic HTML templates -- 

- Pass dynamic data to your HTML templates in a simple, scalable and type-safe way
- Use the various actions and functions in Go’s `html/tempalte`to control the display of dynamic data.
- Create a template cache so that your templates aren’t being read from disk for each HTTP request.
- Gracefully handle template render errors at runtime
- IMP a pattern for passing common dynamic data to web pages without repeating code
- Creating own custom functions to format and display data in HTML templates.

### Displaying Dynamic Data

Currently our `showSnippet`handler function fetches a `models.Snippet`object from the dbs and then dumps the contents out in a plain-text HTTP response. Create a new `show.page.html`template file like:

```go
/ initialize a slice containing the paths to the show.page.html file
// plus the base layout and footer partial we made earlier
files := []string{
    ".ui/html/show.page.html",
    ".ui/html/base.layout.html",
    ".ui/html/footer.partial.html",
}

// parse the template files...
ts, err := template.ParseFiles(files...)
if err != nil {
    app.serverError(w, err)
    return
}

// And then execute them --
err = ts.Execute(w, s)
if err != nil {
    app.serverError(w, err)
}
```

Next up, need to create the show.page.html file to containing the HTML markup for the page just like-- Within HTML templates, the dynamic data that you pass in is represented by the `.`character -- In this specific case, the underlying type of dot will be a `models.Snippet`struct.

```html
{{template "base" .}}
{{define "title"}}Snippet # {{.ID}} {{end}}

{{define "main"}}
    <div class="snippet">
        <div class="metadata">
            <strong>{{.Title}}</strong>
            <span>@{{.ID}}</span>
        </div>

        <pre><code>{{.Content}}</code></pre>
        <div class="metadata">
            <time>Created: {{.Created}}</time>
            <time>Expires: {{.Expires}}</time>
        </div>
    </div>
{{end}}
```

Should find that the relevant snippet is fetched from the dbs.

