# Joining Collections with `$lookup`

Sampling may assist you when developing queries against extensive collections, but in production queries, you may sometimes need to write queries that are operating across multiple collections. Done using the `$lookup`aggreagation step -- 

```js
/**
 * query: The query in MQL.
 */
{
  $or: [{"name": "Catelyn Stark"}, {"name": "Ned Stark"}]
}

// $lookup stage
/**
 * from: The target collection.
 * localField: The local join field.
 * foreignField: The target join field.
 * as: The name for the results.
 * pipeline: Optional pipeline to run on the foreign collection.
 * let: Optional variables to use in the pipeline field stages.
 */
{
  from: 'comments',
  localField: 'name',
  foreignField: 'name'
  as: 'commentes'
}
```

Just `{$limit:2}`. First we are running a `$match`against the `users`collection to get only two users named.. once have these two records, perform our lookup -- the four parameters of `$lookup`are the follows -- 

- `from`-- the collection we are joining to our current aggreation -- in this case, are joining `comments`to `users`collection.
- `localField`-- fieldn name that are we are going to use to join our documents in the local collection -- the name of our user
- `foreignField`-- The field that links to `localField`in the `from`-- may have different names
- `as` -- this is how our new joined data will be labeled.

For this, the `lookup`takes the name of our user, searches the `comments`collection, and adds any comments with the ssame name into a new array field for the original user document.

just like:

```js
const pipeline= 
      [
    {
        '$match': {
            '$or': [
                {
                    'name': 'Catelyn Stark'
                }, {
                    'name': 'Ned Stark'
                }
            ]
        }
    }, {
        '$lookup': {
            'from': 'comments', 
            'localField': 'name', 
            'foreignField': 'name', 
            'as': 'commentes'
        }
    }, {
        '$limit': 2
    }
]
```

In this example, users have made many comments, so the embedded array becomes quite substantial and challenging to view -- this issue presents an excellent place to introduce the `$unwind`operator -- as these joins can often result in large arrays of related document. It deconstructs an array field from an input document to ouput a new document for each element in the array -- if unwind this document fore:

```js
{a:1, b:2, c:[1,2,3,4]}
// the output will be the following documents like:
{a:1, ... c:1}  // or 2, ...
```

Can add this new stage to our join and try running it like: `{$unwind: “$comments”}`

For now, can see multiple documents per user with a single document for each comment instead of one ebemdded array, with this new format, can add more stages to operate on our new set of documetns.

#### Outputting your results with `$out`and `$merge`

Could run the query and export the results into a new format -- Could save the output in an array and then re-insert it into Mdb -- but that would mean transferring all the data from the server to the client -- and then back from the client to the server. From v 4.2, are provided with two aggregation stages that solve this `$out`and `$merge`-- Stages allow us to take the ouput from our pipeline and write into a collection for late use. 

Importantly, this whole process takes place on the srever, meaning that all the data never needs to be transeferred to the client acorss the network. It’s not hard to imagine that after creating a complicated aggregation query, U may want to run it once a week and create a snapsnot of your result by writing that data into a collection. Fore:

```js
// available from v 2.6
{$out: "myOUtputCollection"}

// available from v 4.2
{
    $merge {
        // this can also to merge into a different db
        into: "myOutputCollection",
    }
}
```

`$out`is very simple, the only parameter to specify is the desired output collection, will either create a new collection or completely replace an existing collection, -- `$out`also has several constraints not shared with `$merge`. `$out`must output to the same dbs as the aggregation target.

So when running after 4.2 server, `$merge`will be the better option -- And the `$out`is just simple -- the only parameter is the collection to which we want to output our result -- `$out`-- 

```js
const pipeline = 
      [
    {
        '$sort': {
            'imdb.rating': -1
        }
    }, {
        '$match': {
            'genres': {
                '$in': [
                    'Romance'
                ]
            }, 
            'released': {
                '$lte': datetime(2001, 1, 1, 0, 0, 0, tzinfo=timezone.utc)
            }
        }
    }, {
        '$limit': 5
    }, {
        '$project': {
            'title': 1, 
            'genres': 1, 
            'released': 1, 
            'imdb.rating': 1
        }
    }, {
        '$out': 'movie_top_romance'
    }
]
```

By running this pipeline, will receive no output -- cuz the `output`has been redirected to our desired collection. By placing our results into a collection, can store, share, and update new complex aggregation results.

## Mishandling `null`values

The next mistake is to mishandle null values with queries-- write an example where we retreive the deparatment and age of an employee-- like:

```go
rows, err := db.Query("SELECT DEP, ... WHERE ID=?", id)
if err != nil {
    return err
}
ver (
	department string
    age int
)
for rows.Next() {
    err := rows.Scan(&departemnt, &age)
    if err != nil {
        return err
    }
    //...
}
```

For this, using `Query`for execute query, then iterate over the rows and use `Scan`to copy the column into the values pointed to by the `department`and `age`pointers. If run this example get the following error while calling `Scan`. Here, the SQL driver raises an error cuz the department value is equal to `NULL`.  if a column can be just nullable, there two options to prevents `Scan`from returning an error like;

```go
var (
	departemnt *string
    age int
)
for rows.Next() {
    err := rows.Scan(&department, &age)
}
```

Just provide `scan`with the address of a pointer, not the address of a string type directly -- by doing so, if the value is `NULl`, department will be `nil`.

The other apporach is to use one of the `sql.NullXXX`types, such as `sql.NullString`-- like:

```go
var(
	department sql.NullString
    age int
)
for rows.Next() {
    err := rows.Scan(&department, &age)
}
```

For this, the `sql.NullString`is a wrapper on top of a string, contains two exported fields, `String`contains the string value, and `Valid`conveys whether a string isn’t `NULL`.

#### Handling row iteration errors

Another common mistake is to miss possible errors from iterating over rows -- like:

```go
func get(ctx context.Context, db *sql.DB, id string) (string, int, error) {
    rows, err := db.QueryContext(ctx,"SELECT... WHERE ID=?", id)
    if err != nil {
        return "", 0, err
    }
    defer func() {
        err := rows.Close()
        if err != nil {
            log.Printf("failed to close rows: %v\n", err)
        }
    }()
    
    var (
    	departement string
        age int
    )
    for rows.Next() {
        err := rows.Scan(&department, &age)
        if err != nil {
            return "", 0, err
        }
    }
    return departemnt, age, nil
}
```

For this, Handle 3 errors -- while executing the query, closing the rows, and scanning a row -- have to know that the for `rows.Next(){}`loop can break either when *there are no more rows or when an error happens* while preparing the next row -- So need to do:

```go
func get(ctx context.Context, db *sql.DB, id string) (string, int, error) {
    // ...
    for rows.Next() {
        //...
    }
    if err := rows.Err(); err!= nil {
        return "", 0, err
    }
    return department, age, nil
}
```

This is the best practice to keep in mind -- cuz `rows.Next()`can stop either when we have iterated over all the rows or when an error happens while preparing the next row -- should check `rows.Err`.

### Closing transient resources

Developers work with transient resources that must be closed at some point in the code -- fore, to avoid leaks on disk or in memory -- Structs can generally implement the `io.Closer`interface to convey that a transient resource has to be closed -- fore -- 

#### HTTP body

Discuss this -- write a `getBody`fore - that makes an HTTP Get request and returns the HTTP body response like:

```go
type handler struct {
    client http.Client
    url string
}

func (h handler) getBody() (string, error) {
    resp, err := h.client.Get(h.url)
    if err != nil {
        return "", err
    }
    body, err := io.ReadAll(resp.Body)
    if err != nil {
        return "", err
    }
    return string(body), nil
}
```

For this, used `http.Get`and parse the response using `io.ReadAll`-- this method ok -- however, there is a resource leak -- for this, `resp`is an `http.Response`-- contains a `Body io.ReadCloser`field. This body must be closed if `http.Get`doesn’t return an error -- otherwise, it’s a resource leak -- in this case -- will keep some memroy allocated that is no longer needed but can’t be reclaimed by the GC and may prevent clients from reusing the TCP connection in the worst cases. And the most convenient way to deal with the body closure is to handle it as a `defer`like:

```go
defer func() {
    err := resp.Body.Close()
    if err != nil {
        log.Printf(...)
    }
}
```

In this imp, we properly handle the body resource closure as a `defer`function that ill be executed once `getBody`returns.

Should also understand that a resp body must be closed regardless of whether we read it. Fore, if are only interested in the HTTP status code and not in the body, it has to be closed no matter what -- to avoid a leak.

```go
func(h handler) getStatusCode(body io.Reader) (int, error) {
    resp, err := h.client.Post(h.url, "application/json", body)
    if err != nil {
        return 0, err
    }
    defer func() {
        err := resp.Body.Clsoe()
        if err != nil {
            log.Printf("...", err)
        }
    }()
    return resp.StatusCode, nil
}
```

And this function closes the body even though we haven’t read it -- Another essential thing to remember is that the behavior is different when we close the body, depending on whether we have read from it.

- If close the body without a read, the default HTTP transport may close the connection.
- If we close the body following a read, the default HTTP transport won’t close the connection. -- NOTE: it may be reused.

Therefore, if `getStatusCode`func is called repeatedly and we want to use kee-alive connections -- *should read the body aren’t intereted in it*.  Fore:

```go
func (h handler) getStatusCode(body io.Reader) (int, error) {
    resp, err := h.client.Post(h.url, "application/json", body)
    if err != nil {
        return 0, err
    }
    // close the resp body
    // note: preventing closing the connection
    _, _ = io.Copy(io.Discard, resp.Body) // reads the resp body
    return resp.StatusCode, nil
}
```

In this, read the body to keep the connection alive -- note that instead of using `io.ReadAll`, used `io.Coy`to `io.Discard`-- and `io.Writer`implmentation -- this code reads the body but discards it without any copy.

##### When to close the response body

Fairly frequently, implementations close the body if the resp isn’t empty. not if the error is `nil`. Note that on error, any response can be ignored, a `non-nil`response with a non-nil error only occurs when `checkRedirect`fails.

And note that closing a resource to avoid leaks **isn’t** only related to HTTP body management - -in general, all struct implements the `io.Closer`interface should be closed at some point. This interface contains a single `Close()`

```go
type Closer interface {
    Close() error
}
```

#### `sql.Rows`

`sql.Rows`is a struct used as a result of an SQL query -- Cuz this struct implements `io.Closer`, it also has to be closed. The following like:

```go
db, err := sql.Open("postgres", dataSourceName)
if err != nil {
    return err
}
rows, err := db.Query("SELECT * FROM CUSTOMERS") 
if err != nil {
    return err
}
// use rows
return nil
```

For this, forgetting to close the rows means a connection leak -- which prevents the dbs connection from being put back into the connection pool. Can handle the closure as a `defer`function following the `if err!= nil`block -- 

```go
// open connection
rows, err := db.Query("SELECT * from CUSTOMERS")
if err != nil {
    return err
}
defer func() {
    if err := rows.Close(); err != nil {
        log.Printf("Failed to close rows %v\n", err)
    }
}()
// use rows
```

Following the `Query`call, should eventually close `rows`to prevent leak if it doesn’t return an error.

### Input normalisiation

There is a line left in the ask method that could be reused later -- `guess := []rune(string(suggestion))`we accept all kinds of upper and lowercase mixes and it will later be simple to take care of the not-yet-supported writing system if we put this into a small function. Just like:

```go
func splitToUpperCaseCharacters(input string) []rune {
    return []rune(strings.ToUpper(input))
}
```

#### Check for victory

have built the fundations of your game -- next step is to verify if attempt is the solution --  need to enrich the `Game`structure -- as it holds all the info required to play a game. For the structure, need to store the maximum number of attempts in a variable somewhere.

```go
type Game struct {
	reader      *bufio.Reader
	solution    []rune
	maxAttempts int
}

// New returns a Game, which can be used to play
func New(playerInput io.Reader, solution string, maxAttempts int) *Game {
	g := &Game{
		reader:      bufio.NewReader(playerInput),
		solution:    splitToUppercaseCharacters(solution),
		maxAttempts: maxAttempts,
	}
	return g
}
```

For this, take the solution as a string, which is easier to use, and reuse the function we just wrote before -- are also normalising the solution given to our package by setting all letters to uppercase -- something which again only makes sense in a limited number of alphebets.

And in the `Play`method, can add a loop to let suggest a second word -- and so on.

```go
func (g *Game) Play() {
	fmt.Println("Welcome to Gordle")
	for currentAttempt := 1; currentAttempt <= g.maxAttempts; currentAttempt++ {
		guess := g.ask()
		if slices.Equal(guess, g.solution) {
			fmt.Printf("🎉 You won! You found it in %d guess(es)! The word was: %s.\n", 
                       currentAttempt, string(g.solution))
			return
		}
	}
	fmt.Printf("😞 You've lost! The solution was: %s. \n", string(g.solution))
}
```

```go
func main() {
	solution := "hello"
	g := gordle.New(os.Stdin, solution, 5)
	g.Play()
}
```

#### Providing feedback

Just submitted a word, and our task is now to let him know which characters of that word are in the correct position. For this a good feedback should return a clear hint for every character of the input word, explicit about the correctness of the character i this or that position.

#### Define character status

For this, in order to easily manipulate the feedback for a character, create the type `hint`to represent these hints -- of the type `byte`-- the smallest type Go offers, regarding memory usage. And the `iota`keyword allows us to automatically number them from 0 to 2.

## Single-record SQL queries

The pattern for SELECTING a single record from the dbs is a little more complicated -- explain how to do it by updating our `SnippetModel.Get()`method so that it returns a single specific snippet based on its ID. To do so:

```sql
SELECT id, title, content, created, expries FROM snippets
WHERE expires > UTC_TIMESTAMP() and id = ?
```

```go
func (m *SnippetModel) Get(id int) (*Snippet, error) {
	stmt := `SELECT id, title, content, created, expires FROM snippets
		WHERE expires > UTC_TIMESTAMP() AND id = ?`

	row := m.DB.QueryRow(stmt, id)

	// initialize a pointer to a new zeroed struct
	s := &Snippet{}

	err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrNoRecord
		} else {
			return nil, err
		}
	}
	return s, nil
}
```

For this, behind the scenes of `rows.Scan()`your driver will automatically convert the raw output from the SQL dbs to the required native Go types. So long as you are sensible with the types that you are mapping between SQL and Go. Note that the `TIME, DATE`and `TIMESTAMP`map to `time.Time`.

For this , if try to run the app at this point, should get a compile-time error saying that the `ErrNoRecord`is undefined.

`var ErrNoRecord= errors.New(“Models: no matching record found”)`

#### Using the model in our handlers

Alright, put the `SnippetModel.Get()`method into action -- like:

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strcov.Atoi(r.URL.Query().Get("id"))
    if err != nil || id < 1 {
        app.notFound(w)
        return
    }
    
    snippet, err := app.snippets.Get(id)
    if err != nil {
        if erros.Is(err, models.ErrNoRecord) {
            app.notFound(w)
        }else {
            app.serverError(w, err)
        }
        return
    }
    //...
}
```

Checking for specific errors -- Using the `errors.Is()`function to check whether an error matches a specific value:

```go
if errors.Is(err, models.ErrNoRecord) {
    app.notFound(w)
}else {
    app.serverError(w, err)
}
```

The `errors.Is()`works by unwrapping erros as necessary before checking for a match.

Shortand -- like:

```go
err := m.DB.QueryRow("SELECT...").Scan(&s.ID, &s.Title, ....)
```

#### Multiple- Record SQL queries

Finally look at the pattern for executing SQL statements which return multiple rows -- demonstrate by updating the `SnippetModel.Latest()`method to return the most recently created using the following like:

```sql
SELECT id, title, ... FROM snippets WHERE expires> UTC_TIMESTAMP() ORDER BY id DESC LIMIT 10
```

```go
func (m *SnippetModel) Latest()([]*Snippet, error) {
    // write the SQL auery to execute:
    stmt := "... DESC limit 10";
    rows, err := m.DB.Query(stmt)
    if err != nil {
        return nil, err
    }
    
    defer rows.Close() // Resultet is always properly closed before the Latest() returns
    
    snippets := []*Snippet{}
    for rows.Next() {
        s := &Snippet{}
        err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
        if err != nil {
            return nil, err
        }
        snippets = append(snippets, s)
    }
    
    // note that rows.Next() loop has finished we call `rows.Err()`to retrieve any error that was 
    // encountered during the iteration -- it's important to call this
    if err = rows.Err(); err != nil {
        return nil, err
    }
    return snippets, nil
}
```

#### Using the model in handlers

The `database/sql`package essentially provides a std interface between your Go app and the world of SQL dbs. It’s important to note that while `database/sql`does a good job of providing a standard interface for working with SQL dbs, there are some in the way that different dirvers and dbs operate.

#### Working with transactions

It’s important to realize that calls to the `Exec()`.. can use any connection from the `sql.DB`-- even if you have two calls to `Exec()`immediately next to each other in your code. To guarantee that the same connection is used you can wrap multiple statements in a *transaction* -- like:

```go
type ExampleModel struct {
    DB *sql.DB
}

func (m *ExmaleModel) ExampleTransaction() error {
    tx, err := m.DB.Begin()
    if err != nil {
        return err
    }
    
    // Defer a call to `tx.Rollback()` to ensure it is always called before the function returns
    // if the transaction succeeds it will be already be committed by the time `tx.Rollback()` is 
    // called.
    defer tx.Rollback()
    
    // Call the `Exec()`on the transaction, passing in your statement and any parameter like:
    _, err = tx.Exec("INSERT INTO ...")
    if err != nil {
        return err
    }
    _, err = tx.Exec("UPDATE...")
    if err != nil {
        return err
    }
    
    // If for now there are no errors, the statements in the transaction can be committed
    err = tx.Commit()
    return err
}
```

#### Prepared statements

`Exec(), Query, QueryRow()`all use prepared statements beind the scenes to help prevent SQL injection attacks. They set up a prepared statement on the dbs connection -- run it with the parameters provides and then close the prepared statement.

So in theory, a better approach could be make use of the `DB.Prepare()`method to create our own prepared statement once, and reuse that instead. Fore:

```go
type ExampleModel struct {
    DB *sql.DB
    InsertStmt *sql.Stmt
}

// create a ctor for the model
func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    insertStmt, err := db.Prepare("INSERT INTO...")
    if err != nil {
        return nil, err
    }
    return &ExampleModel{db, insertStmt}, nil
}

func (m *ExampleModel) Insert(...args) error {
    _, err := m.InsertStmt.Exec(args...)
}

func main() {
    db, err := sql.Open(...)
    if err != nil {
        errorLog.Fatal(err)
    }
    defer db.Close()
    
    exampleModel, err := NewExampleModel(db)
    if err != nil {
        errorLog.Fatal(err)
    }
    defer exampleModel.InsertStmt.Close()
}
```

