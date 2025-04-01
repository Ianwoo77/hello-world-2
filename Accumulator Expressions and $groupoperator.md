# Accumulator Expressions and `$group`operator

The `$group`stage allows U to group documents based on a specific condition -- although there are many other stages and methods to accomplish various tasks with the `aggregate`command, the `$group`stage serves as the cornerstone of the most powerful queries -- The most significant unit of data we could return was a single document. Can sort these documents to gain insight through a direct comparison of the documents -- 

The most basic imp of a `$group`stage accepts only an `_id`key, with the value being an expression -- this expression defines the criteria by which the pipeline groups document together. This value becomes the `_id`of the newly outputted document with one document generated for each unique `_id`that the `$group`stage creates. Like:

```js
const pipeline= [
    {$group: {_id:"$raged"}}
];
db.movies.aggregate(pipeline)
```

The `_id: $rated`is actually the `_id: $$CURRENT.reated`-- this may seem complicated, but it indicates tht for each document will fit into the group matching the same document with the `rated`key.

And the `$group`command can accept most than just one argumnet, it can also accept any number of additional argument in the following format -- like: `field: {accumulator: expression}`

```js
const pipeline= [
    {$group: {_id:"$rated", 'numTitles': {$sum: 1}}}
];
db.movies.aggregate(pipeline)
```

Can see from this can create a new field called `numTitles`with the value of this field for each group being the sum of the documents -- these newly created fields are often referred to as *computed fields* -- for each document in a group, can sum the literal value 1 with the accumulated result so far.

```js
const pipeline= [
    {$group: {_id:"$rated", 'numTitles': {$sum: '$runtime'}}}
];
db.movies.aggregate(pipeline)
```

A single aggregation stage and two parameters, can begin to transform our data in exciting ways -- several accumulator operators can be combined and layered to generate much more complex and insightful info about the groups -- will see some of these operators in the upcoming examples.

```js
{
  'roundedAvgRuntime': {$trunc: '$avgRuntime'}
}
```

### Manipulating Data

In the previous scenario, became accustomed to the shape of the data and recreated one of the client’s manual processes as an aggreation pipeline -- as part of the lead up to the classic movie marathon, the cinema and run one movie for each genre and they want to run the most popular genres last to build hype around the event.

Translate the query into squential stges so that you can map to your aggreation stages -- 

- Match movies that were released before 2001
- find avg of each genre
- Sort the genres by poularity
- Output adjusted runtime of each movie.

Since you are learned more about the group stage, elaborate on the step just using your new -- 

- Matching movies before 2001
- Groups all by their first genre and accumulate the average and maximum IMDB
- Sort the average popularity of each genre
- Project the adjusted runtiime as `total_runtime`.

```js
const pipeline = [
    {$match: {}},
    {$group: {}},
    {$sort: {}},
    {$project: {}}
];
```

For the `$match`stage just like;

```js
{
  released: { $lte: new ISODate("2001-01-01") }
}
```

Then for the `$group`stage, first identify your new `_id`for each output document just like:

```js
{
  _id: {'$arrayElemAt': ['$genres',0]}
}
```

For this the `$arrayElemAt`takes an element from an array at the specified index. For this scenairo, assume that the first genre in the array is the primary genre of a film.

Specify the new computed fields you require in the result -- remember to use the accumulator operators including `$avg`and `$max`-- just like:

```js
{
  _id: { $arrayElemAt: ["$genres", 0] },
  popularity: { $avg: "$imdb.rating" },
  top_movie: { $max: "$imdb.rating" },
  longest_runtime: { $max: "$runtime" }
}
```

Fill the `sort`field, now that you have defined your computed fields -- this is just simple like: 

```js
// for ths $sort
{
	popularity: -1
}
```

Then to get the adjusted runtime, use the `$add`operator and add 12 minutes -- cuz the client has informed you that this is the length of the trailers running before each movie like:

```js
{
  _id:1,
  popularity: 1,
  top_movie:1,
  adjusted_runtime:
    {$add:['$longest_runtime', 12]}
}
```

The output shows that noir film, documentaries and short films are the most popular, and we can see the average runtime for each category.

#### Selecting the title from each movie category

Have now answered the question posed to you by your client, this result won’t adi time in picking a specific movie -- they must execute a different query to get a list of movies in each genre and pick the best movie.

```js
// $match stage
{
  released: { $lte: new ISODate("2001-01-01") },
  runtime: {$lte: 218},
  'imdb.rating': {$gte:7.0}
}

// then the $sort stage
{
	'imdb.rating': -1
}
```

Add the `$first`accumulator to your group stage, adding your new fields, also add `recommended_rating`:

```js
// $group stage
{
  _id: { $arrayElemAt: ["$genres", 0] },
  'recommended_title': {$first: "$title"},
  'recommended_rating': {$first: '$imdb.rating'},
  'recommended_raw_runtime': {$first: '$runtime'},
  popularity: { $avg: "$imdb.rating" },
  top_movie: { $max: "$imdb.rating" },
  longest_runtime: { $max: "$runtime" }
}

// $project stage like:
{
  _id:1,
  popularity: 1,
  top_movie:1,
  recommended_title:1,
  recommended_rating:1,
  recommended_raw_runtime:1,
  adjusted_runtime:
    {$add:['$longest_runtime', 12]}
}
```

And the `$first`accumulator operator is used within the `$group`stage to retreive the first document encountered within each group according to the ordering of the documnets as they pass through the pipeline. `$first`evaluates the `<expression>`for the first document that ensures that the `$group`stage within that group and assigns the result to the `<outputFieldName>`

## Common JSON-handling mistakes

Go has excellent support for JSON with the `encoding/json`package -- this section covers 3 common mistakes related to encoding and decoding JSON data. 

#### Unexpected behavior due to type embedding

In the context of JSON handling, discuss another potential impact of type embedding that can lead to unexpected marshaling/unmarshaling results -- create an `Event`struct containing an ID and an embedded timestamp -- like:

```go
type Event struct {
    ID int
    time.Time
}
```

For this, cuz `time.Time`is embedded, in the same way we descrbed previously, can access the `time.Time`methods dreictly at the `Event`level -- fore -- `.Second()`directly -- 

```go
event := Event {
    ID: 1234,
    Time: time.Now(),
}
b. err := json.Marshal(event)
if err != nil {
    return err
}
fmt.Println(string(b))
```

And for this, may expect the `ID: 1234`also prints, but it just prints the time json.

First as discuss-- if an embedded field type implements an interface, the struct containing the embedded field will also implement this interface -- second, can change the default marshaling behavior by making a type imp the `json.Marshaler`interface -- like:

```go
type Marshaler interface {
    MarshalJSON() ([]byte, error)
}

// fore
type foo struct{}
func (foo) MarshalJSON() ([]byte, error) {
    return []byte(`"foo"`), nil
}

func main() {
    b, err := json.Marshal(foo{})
    if err != nil {
        panic(err)
    }
    fmt.Println(string(b))
}
```

For this, cuz we have chagned the default JSON marshaling, by implementing the `Marshaler`interface, the code just prints `foo`. And for the struct:

```go
type Event struct {
    ID int
    time.Time
}
```

Have to know that `time.Time`implements the `json.Marshaler`interface -- cuz `time.Time`is an embedded field of `Event`, the compiler promotes its method -- *`Event`also implements `json.Marshaler`*.

Consequently, passing an `Event`to `json.Marshaler`uses the marshaling behavior provided by the `time.Time`instead of default behavior. To fix this, just:

```go
type Event struct {
    ID int
    Time time.Time
}
```

And if want or *have to* keep the `time.Time`field embedded, the other option is to make `Event`imp the `json.Marshaler`interface like:

```go
func (e Event) MarshalJSON() ([]byte, error) {
    return json.Marshal (
        struct {
            ID int
            Time time.Time
        }{
            ID: e.ID,
            Time: e.Time,
        }
    )
}
```

And in this solution, we implement a custom `MarshalJSON`method while defining an anonymous struct reflecting the struct of `Event`

#### Map of any

When unmarshaling data, can provide a map instead of a struct -- the retionale is that when the keys and values are uncertain, passing a map gives us some flexibility instead of a static struct. Just like:

```go
b := getMessage()
var m map[string]any
err := json.Unmarshal(b, &m)
if err != nil {
    return err
}
```

If provide the JSON like:

```json
{
    "Id": 32,
    "name": "foo"
}
```

For this, cuz we just use the generic `map[string]any`type -- parse all the different field automatically like: However, there is an important gotcha to remember if we use a map of `any`-- any numeric value, regardless of whether it contains a decimal -- is converted into a `float64`type. like:

```go
fmt.Printf("%T\n", m["id"]) // float64
```

Should be sure we don’t amke the wrong assumption and expect numeric values without decimals to be converted into integers by default.

### Read player’s input using `bufio`

And there are several ways of reading from the std input, depending mostly on what we wat to read. And the `bufio`package has a useful method to acheive this on its `Reader`structure -- *Readline tries to return a single line, not including the end-of-line bytes*. The good thing is that the `bufiio.Reader`also implements the `io.Reader`interface -- 

```go
type Game struct {
    reader *bufio.Reader
}
```

Also should do it as part of the `New()`function -- just like:

```go
func New(playerInput io.Reader) *Game {
    g := &Game {
        reader: bufio.NewReader(playerInput),
    }
    return g
}
```

How does Go deal with characters -- If want to paly using another -- Go natively uses Unicode -- all the source files need to be encoded in UTF and it even has a specific primitive type called rune that serves to encode a Unicode codepoint.

#### The `ask`method

We have a variable that allows us to read from the std input conce the game is set -- politely Since the feature of retrieving an attempt provided by the player through the reader is sth we can summarise in a sentence without having to explain how it works -- it’s a great candidate for a function. Just like:

```go
func (g *Game) ask() []rune {...}
```

There are two reasons for using the `*Game`instead of `Game`-- 

1. We will be modifying the state of our `Game`structure via many of its methods. And it is a good Go practic to avoid having both pointer and non-pointer receiver methods on a type.
2. `Game`struct has a field that is a pointer.

And inside the method, read the line using the reader. Can add an easy check on the length of the word -- for the moment, we play with the same parameters as the oroginal -- with 5-character long words. 

Using the `ReadLine()`method will give us the user’s input as a slice of bytes - -we will then need to convert this byte slice into a rune slice. Converting each byte into the rune representing that byte would be a very bad mistake. So to properly convert a slice of bytes that we know represents a string to a slice of runes, we need to first convert the byte slice into a string and then into a rune slice.

And the built-in method `len()`returns the length of a slice -- can then use it to compare the length of word against the constant.

```go
func (g *Game) ask() []rune {
	fmt.Printf("Enter a %d-character guress:\n", solutionLength)
	for {
		playerInput, _, err := g.reader.ReadLine()
		if err != nil {
			_, _ = fmt.Fprintf(os.Stderr,
				"Gordle failed to read your guess: %s\n", err.Error())
			continue
		}
		guess := []rune(string(playerInput)) // playerInput is a byte slice
		// then TODO...
		if len(guess) != solutionLength {
			_, _ = fmt.Fprintf(os.Stderr,
				"Your attempt is invalid with Gordle's solution! Expected %d characters, got %d.\n",
				solutionLength, len(guess))
		} else {
			return guess
		}
	}
}

```

As we are using the stdlib’s `bufio.Reader`, can use a reader to any stub mimicking the player’s input -- a stub is simple way of implementing a dependency over a 3rd party -- like: think of a few original test cases that use your favorite alphabet -- like:

```go
func TestGameAsk(t *testing.T) {
	tt := map[string]struct {
		input string
		want  []rune
	}{
		"5 characters in english": {
			input: "HELLO",
			want:  []rune("HELLO"),
		},
		"5 characters in arabic": {
			input: "مرحبا",
			want:  []rune("مرحبا"),
		},
		"5 characters in japanese": {
			input: "こんにちは",
			want:  []rune("こんにちは"),
		},
		"3 characters in japanese": {
			input: "こんに\nこんにちは",
			want:  []rune("こんにちは"),
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			g := New(strings.NewReader(tc.input))
			got := g.ask()
			if !slices.Equal(got, tc.want) {
				t.Errorf("got: %q; want: %q", string(got), string(tc.want))
			}
		})
	}
}
```

Might have noticed that the first line of our test function is somewhat different from those in the previous chapters -- used to declare a `testCase`structure.

Just remember that slices hold a pointer to their underlying array -- Array values are comparable if values of the array element type are comparable -- two array values are equal if their corresponding elements are equal. But when it comes to slices, structs and maps -- `==`will simply not work -- it’s not that it will produce random result. Go will simply not let you compare two slices.

This -- in tests, to use the method `reflect.DeepEqual`-- it was not designed for performance, should avoid it in production code -- write a simple loop just. Added a dependency on an external library -- the developers of the Go language will typically write their new libraries in golang.org/x/ in roder to let the community test them out.

## Setting up MySQL

Then just create the following SQL statement to create a new `snippets`table to hold the text like:

```sql
CREATE TABLE snippets (
	id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created DATETIME NOT NULL,
    expires DATETIME NOT NULL
);
CREATE INDEX idx_snippets_created ON snippets(created);

-- then just add some placeholder entries to the snippets table like:
INSERT INTO snippets(title, content, created expires) VALUES (
	"an old slient pond",
    "An old slient...", 
    UTC_TIMESTAMP(),
    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 365 DAY)
)
```

#### Modules and reproducible builds

The natural next step is to connect to the dbs from our web application.

```go
db, err := sql.Open("mysql", "web:pass@/snippetbox?parsetime=true")
// fore
dsn := flag.String("dsn", "root:root@/snippetbox2?parseTime=true",
		"MySQL data source name")
```

Note that the `parseTime=true`part of the DSN above is a driver-specific parameter which instructs our driver to convert SQL `TIME`and `DATE`fields to Go `time.Time`objects.

Note that the `sql.Open()`returns a `sql.DB`object -- this isn’t a dbs connection -- it’s just a *pool of many connections*. Go just manages the conenctions in this pool as needed, automatically opening and closing connections to the dbs via the driver. And the connection pool is safe for concurrent access, so can use it from web app handles safely.

```go
func main() {
    // ...
    srv := &http.Server{
		Addr:      *addr,
		ErrorLog:  errorLog,
		Handler:   app.routes(),
    }
    //...
}

func openDB(dsn string) (*sql.DB, error ) {
    db, err := sql.Open("mysql", dsn)
    if err != nil {
        return nil, err
    }
    if err = db.Ping(); err!= nil {
        return nil, err
    }
    return db, nil
}
```

#### Designing a dbs model

Might want to think of it as a *service* layer or *data access* layer intead -- whatwever you prefer to call it the idea is that we will encapsulate the code for working with MySQL in a separeate package to the rest of our application.

```go
type Snippet struct {
    ID int
    Title string
    Content string
    Created time.Time
    Expires time.Time
}

type SnippetModel struct {
    DB *sql.DB
}

func (m *SnippetModel) Insert( title string, ...) (int, error) {...}
```

#### Using the `SnippetModel`

To use this model in our handlers we need to establish a new `SnippetModel`struct in the `main()`and then inject it as dependency via the `application`struct like:

```go
type application struct {
    errorLog *log.Logger
    infoLog *log.Logger
    snippets *models.SnippetModel
}
```

Benefits fo this structure -- 

- There is a clean separation of concerns, our database logic isn’t tied to our handlers which means that handler reponsibilities are limited to HTTP stuff -- this will make it easier to write tight, focused, unit tests in the future
- By creating a custom `SnippetModel`type and implementing methods on it we have been able to make our model a single, neatly encapsulated object.
- Note that cuz the model actions are defined as methods on an object -- in the case `SnippetCModel`-- there is the opportunity to create an *interface* and mock it for unit testing purposes.

#### Executing SQL statements

`SnippetModel.Insert()`method -- creates a new record in our `snippets`table and then returns the integer `id`:

```sql
INSERT INTO snippets (title, content, created, expires)
VALUES(?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY))
```

In the MySQL -- `?`character to just indicate *placeholder* paramters for the data that we went to insert in the dbs.

Go just provides 3 different methods for executing dbs quereis -- In this case, cuz using the MySQL, then the most appropriate tool for the job is `DB.Exec()`-- jump in the deep end and demonstrate how to use this in the `Insert()`:

```go
func (m *SnippetModel) Insert(title string, content string, expires int) (int, error) {
    stmt := `... // last senstence`
    
    // use the `Exec()` method 
    // in the PostgreSQL using QueryRow cuz the returning clause
    result, err := m.DB.Exec(stmt, title, content, expires)
    if err != nil {
        return 0, err
    }
    
    // use the `LastInsertedId()`method on the result to get the ID of our newly inserted record
    // typically for auto-incremented column when inserting a new row.
    id, err := result.LastInsertId()
    if err!= nil {
        return 0, err 
    }
    return int(id), nil
}
```

#### Using the model in the handlers

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        w.Header().Set("Allow", http.MethodPost)
        app.clientError(w, http.StatusMethodNotAllowed)
        return
    }
    
    // create some variables holding dummy data 
    title := "0 snail"
    content := "0 snail\nClimb mount..."
    expires := 7
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        //...
        return
    }
}
```

```sh
curl -iL -X POST http://localhost:4000/snippet/create
```

#### Placeholder parameters

In the code above constructed our SQL statement using placeholder parameters -- where `?`acted as a placeholder for the data we want to insert.

The reason for using placeholder parameters to construct our query is to help avoid SQL Injection attacks from any untrusted user-provided input -- behind the scenes, the `DB.Exec()`method works in 3 steps -- 

1. Create a new prepared statement on the dbs using the provided SQL statement
2. In the second step, Exec passes the paramter values to the dbs, the dbs then executes the prepared statement using these parameters. Cuz the parameters are transimitted later, after the statement has been compiled, the dbs treats them as pure data.
3. It then closes the prepared statement on the dbs. *deallocate*.

#### Single-record SQL queries

```sql
SELECT id, title, content, created, expires FROM snippets
WHERE expires> UTC_TIMESTAMP() AND id= ?
```

```go
func (m *SnippetModel) Get(id int) (*Snippet, error) {
    stmt := `select id, title, ... from snippets where exprirs>UTC_TIMESTAMP() and id=?`
    row := m.DB.QueryRow(stmt, id)
    s := &Snippet{}
    err := row.Scan(&s.ID, ...)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrNoRecord
        }else {
            return nil, err
        }
    }
    return s, nil
}
```