# Manipulating Data (2)

```js
/**
 * query: The query in MQL.
 */
{
  released: {$lte: new ISODate("2001-01-01")}
}

// $group stage, first identify your new `id` for each ouptut document

```

And the MDb `$arrayElemAt`aggregation operator is used to return the element at a specific array index just like:

`{$arrayElemAt: [<array>, <index>]}`

```js
/**
 * _id: The id of the group.
 * fieldN: The first field name.
 */
{
  _id: {'arrayElemAt': ['$genres',0]},
  'popularity': {$avg: '$imdb.rating'},
  'top_movie': {$max: '$imdb.rating'},
  'longest_runtime':{$max:'$runtime'}
}
```

Then fill the `sort`field -- now hat defined your computed fields fore:

```js
{ // $sort stage
  popularity: -1
}
```

Then add the project like:

```js
/**
 * specifications: The fields to
 *   include or exclude.
 */
{
  _id:1,
  popularity: 1,
  top_movie:1,
  adjusted_rntime: {$add: ['$longest_runtime', 12]}
}
```

And for the full pipeline like:

```js
const pipeline =
      [
    {
        '$match': {
            'released': {
                '$lte': datetime(2001, 1, 1, 0, 0, 0, tzinfo=timezone.utc)
            }
        }
    }, {
        '$group': {
            '_id': {
                'arrayElemAt': [
                    '$genres', 0
                ]
            }, 
            'popularity': {
                '$avg': '$imdb.rating'
            }, 
            'top_movie': {
                '$max': '$imdb.rating'
            }, 
            'longest_runtime': {
                '$max': '$runtime'
            }
        }
    }, {
        '$sort': {
            'popularity': -1
        }
    }, {
        '$project': {
            '_id': 1, 
            'popularity': 1, 
            'top_movie': 1, 
            'adjusted_rntime': {
                '$add': [
                    '$longest_runtime', 12
                ]
            }
        }
    }
]
```

#### Selecting the Title from each movie category

Have now answered the question posed to you by your client -- this result won’t aid them in picking a specific movie -- must execute a different query to get a list of movies in each genre and pick the best movie to show from the list.

```js
/**
 * query: The query in MQL.
 */
{
  released: {$lte: new ISODate("2001-01-01")},
  runtime: {$lte:218},
  'imdb.rating': {$gte: 7.0}
}
```

Then to get the recommended title for each category, use the `$first`accumulator in group stage to get the top document for each genre. So need to sort first. Just ensure that the first document is also the highest rated just like:

```js
/**
 * _id: The id of the group.
 * fieldN: The first field name.
 */
{
  _id: {'arrayElemAt': ['$genres',0]},
  'recommended_title': {$first: '$title'},
  'recommended_rating': {$first: '$imdb.rating'},
  'recommended_raw_runtime': {$first:'$runtime'},
  'popularity': {$avg: '$imdb.rating'},
  'top_movie': {$max: '$imdb.rating'},
  'longest_runtime':{$max:'$runtime'}
}
```

Then, just ensure that you add this new field to your final projection -- like:

```js
// project stage just like:
/**
 * specifications: The fields to
 *   include or exclude.
 */
{
  _id:1,
  popularity: 1,
  top_movie:1,
  recommended_title:1,
  recommended_rating: 1,
  recommended_raw_runtime: 1,
  adjusted_rntime: {$add: ['$longest_runtime', 12]}
}
```

```js
// then the full query like:
const pipeline = [
    {
        '$match': {
            'released': {
                '$lte': datetime(2001, 1, 1, 0, 0, 0, tzinfo=timezone.utc)
            }, 
            'runtime': {
                '$lte': 218
            }, 
            'imdb.rating': {
                '$gte': 7.0
            }
        }
    }, {
        '$sort': {
            'imdb.rating': -1
        }
    }, {
        '$group': {
            '_id': {
                'arrayElemAt': [
                    '$genres', 0
                ]
            }, 
            'recommended_title': {
                '$first': '$title'
            }, 
            'recommended_rating': {
                '$first': '$imdb.rating'
            }, 
            'recommended_raw_runtime': {
                '$first': '$runtime'
            }, 
            'popularity': {
                '$avg': '$imdb.rating'
            }, 
            'top_movie': {
                '$max': '$imdb.rating'
            }, 
            'longest_runtime': {
                '$max': '$runtime'
            }
        }
    }, {
        '$project': {
            '_id': 1, 
            'popularity': 1, 
            'top_movie': 1, 
            'recommended_title': 1, 
            'recommended_rating': 1, 
            'recommended_raw_runtime': 1, 
            'adjusted_rntime': {
                '$add': [
                    '$longest_runtime', 12
                ]
            }
        }
    }
]
```

### Working with large Datasets

The must execute a different query to get a list of movies in each genre and pick the best movie to show from the list -- Additionally have also learned that the maximum time slot available is 230 minutes.

#### Sampling with `$sample`

The first step in learning how to deal with large datasets is understanding `$sample`-- this stage is simple yet useful -- the only parameter to `$sample`is the desirzed of your sample -- randomly selects documents and passes them through to the next stage -- `{$sample: {size:100}}`-- This will reduce the scope to 100 random docs. By doing this, can significantly reduce the number of documents going through your pipeline.

```js
// sample stage
/**
 * size: The number of documents to sample.
 */
{
  size: 100
}
```

```js
/**
 * query: The query in MQL.
 */
{
  plot: {$regex: /around/}
}
```

May be wondering why wouldn’t just use a `$limit`command to achieve the same result of reducing the number of documents at some stage in your pipeline. The primary reason is that the `$limit`always respects the order of the documents and thus returns the same documents every time.

And here is a query to search all movies for a specific keyword in the `plot`field, implemented both with and without `$sample`.

#### Joining Collections with `$lookup`

Sampling may assist you when developing queries against extensive collections, but in production queries, may sometimes need to write queries that are operating across multiple collections.

```js
const pipeline =
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
            'as': 'comments'
        }
    }, {
        '$limit': 2
    }
]
```

For the `$lookup`just lilke:

```js
{
  $lookup: {
      // name of the collection in the same dbs to perform the join with
    from: "<foreign collection>",
        // name of a field in the input documents
    localField: "<field from the input documents>",
        
        // name of a field in the documents of the foreign collection
    foreignField: "<field from the documents of the 'from' collection>",
        
        // name of the new array field that will be added to the input documents
    as: "<output array field>"
  }
}
```

1. MDB looks at the value of the `localField`
2. It then searches the `foriegn collection`for documents wherer the `foreignField`has a value that matches the `localField`value from the input document
3. All mathcing documents form the `foreign collection`are added to a new array field in the input document, named as feidl.
4. Note that if no matching documents are found in the `foreign collection`, the new array field will be an empty array `[]`.

Dissect this before try to run it -- first are running a `$match`against the `users`collection to get only two users named.

## Common SQL mistakes

The `database/sql`package provides a generic interface around SQL or *SQL-like* dbs -- also fairly common to see some patterns or mistakes while using this packge -- 

#### Forgetting that `sql.Open`-- establish connections to a dbs

When using `sql.Open()`-- one common misconception is expecting this function to establish connections to the dbs:

```go
db, err := sql.Open("mysql", dsn)
if err != nil {
    return err
}
```

According to the documentation -- *Open may just validate its arguments without creating a connection* -- Actually, the behavior depends on the SQL driver used. For some drivers, `sql.Open`**doesn’t** establish a connection -- it’s only a preparation for later use -- therefore, the first connection to the dbs may be established *lazily*.

Fore, in some cases, want to make a service ready only after we know that all the dependencies are collectly set up and reachable. If want to ensure that the function that uses `sql.Open`guarantees that the underlying dbs is reachable -- should use the `Ping()`

```go
db, err := sql.Open("mysql", dsn)
if err != nil {
    return err
}
if err = db.Ping(); err!=nil {
    return err
}
```

`Ping`just forces the code to establish a connection that ensures that the data source name is valid and the dbs is reachable. Should just remember that `sql.Open`doesn’t necessarily establish a connection, and the firset connection can be opened lazily. Can also use the `PintContext()`method

#### Forgetting about connections pooling

Note that just as the default HTTP client and server provdie default behaviors that may not be effective in production -- it’s essential to understand how dbs conenctions are handled in Go. Fore: `sql.Open()`just returns an `*sql.DB`struct -- doesn’t represent a single db conenction -- it represents a *pool of conenctions*. 

Also note that a connection in the pool can have two states -- 

- Already used
- Idle -- already created but not in use for the time being.

It’s important to remember that creating a pool leads to 4 available config parameters that may want to override:

- `SetMaxOpenConns`- Maximum number of open connections to the dbs
- `SetMaxIdleConns`-- Maximum number of idle conns
- `SetConnMaxIdleTime`-- Maximum amount of time a connection *can be idle* before it’s clsoed
- `SetConnMaxLifetime`-- connection can be held open before it’s closed.

For this, if a new query comes in -- it will pick one of the *idle* connections. And, note that if there are no more idle connections -- the pool will create a new conenction if an extra slot is available.

- Setting `SetMaxOpenConns`is important for production. Default is *unlimited*.
- The value of `SetMaxIdleConns(default 2)`-- should be increased if our app generates a signiifcant number of concurrent requests.
- `SetConnMaxIdleTimes`-- important if our app may face a burst of requests.
- Setting `SetConnMaxLifetime`can be helpful -- fore, connect to a load-balanced dbs server.

#### Using prepared statements

There are two main benefits -- 

- *Efficientcy* -- statement doesn’t have to be recomplied
- *security* - reduces the risks of SQL injection attacks.

Therefore -- if repeated, should use prepared statements -- should also use prepared in *untrusted* context. Like:

```go
stmt, err := db.Prepare("SELECT * FROM ORDER WHERE ID=?")
if err != nil {
    return err
}
rows, err := stmt.Query(id)
```

#### Mishandling `null`values

The next mistake is to mishandle null values with queries -- fore:

```go
rows, err := db.Query("SELECT DEP, AGE FROM EMP where ID=?", id)
if err!= nil {
    return err
}
var (
	department string
    age int
)
for rows.Next() {
    err := rwos.Scan(&department, &age)
    if err != nil {
        return err
    }
}
```

If department value is equal to NULL -- if a column can be just nullable, there are two options to prevent `Scan`from returning an error -- like:

```go
var (
	department *string
    age int
)
for rows.Next() {
    err := rows.Scan(&department, &age)
}
```

For this, provide `scan`with the *address of pointer* -- for this if the value `NULL`, then will be `nil`.

And the other approach is to use one of the `sql.NullXXX`types -- like:

```go
var (
	department sql.NullString
    age int
)
for rows.Next() {
    err := rows.Scan(&department, &age)
}
```

There are also `sql.NullBool, NullInt32, NullInt64, NullFloat64, NullTime`.

Note that the best practice with a nullable column is to either handle it as a pointer or use an `sql.NullXXX`type.

#### Not handling row iteration errors

Another common mistake is to miss possible errors from iterating over rows -- like:

```go
func get(ctx context.Context, db *sql.DB, id string) (string, int, error) {
    rows, err := db.QueryContxt(ctx, "SELECT DEP... where ID=?", id)
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
    	department string
        age int
    )
    for rows.Next() {
        err := rows.Scan(&department, &age)
        if err != nil {
            return "", 0, err
        }
    }
    return department, age, nil
}
```

Have to know that the `for rows.Next(){}`loop can break either when therea re no more rows or when an error happens while preparing the next now.  Folllowing a row iteration, should call `rows.Err`to distinguish between the two cases -- like:

```go
func get(ctx context.Context, db *sql.DB, id string) (string, int, error) {
    for rows.Next() {
        //...
    }
    
    // checks rows.Err to determine whether the previous loop stopped cuz of an err
    if err := rows.Err(); err!= nil {
        return "", 0, err
    }
    return departement, age, nil
}
```

This is just the bast practice to keep in mind -- cuz `rows.Next`can stop either when we have iterated over all the rows when an error happens while preparing the next row, should check `rows.Err`following iteration.

### Play

We are now able to read the guess -- make great use of this ability -- and plug it in the `Play()`method -- looks like:

```go
func (g *Game) Play() {
	fmt.Println("Welcome to Gordle!")
	guess := g.ask()
	fmt.Printf("Your guress is %s\n", string(guess))
}

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
func main() {
	g := gordle.New(os.Stdin)
	g.Play()
}
```

#### Isolate the check

There is no specific rule concerning the responsibilities of a method -- but when you start having multiple operations of different natures, it might be best to have one function for one action -- small functions area also easier to test and maintain, where making sure our code is just robust.

So can move the word length validation to another method, adequately named `validateGuess`, this `validateGuess`will have a receiver over the `Game`type - the reason for this won’t be visible here -- but in the next - want to get rid of that `solutionLength`constant -- In favour of a test against the real secret word’s length. this `validateGuess()`is in charge of the validation -- takes the guress as a parameter and returns whether the word is valid. And there are two common ways of informing of the success of a check -- In the case, the `ask`method -- to decide the behavior if there is any error -- 

#### Error Propagation

When retreive an error, the best thing we can do is to handle it as much as we can, and if there is nothing this layer can do about it, then propagate it to the upper layer --nicely wrapped -- Wrapping it will provide context to the layer that can finally decide to handle the error. And the simplest way of wrapping an error call the 

`fmt.Errorf(“... %w”, err)`.

Then the following of code holds the new method and its attached error. Just like:

```go
// errInvalidWordLength is returned when the guess has the wrong number of characters
var errInvalidWordLength = fmt.Errorf(
	"invalid guess, word doesn't have the same number of characters as the solution")

// validateGuess ensures the guess is valid enough.
func validateGuess(guess []rune) error {
	if len(guess) != solutionLength {
		return fmt.Errorf("expected %d, got %d, %w",
			solutionLength, len(guess), errInvalidWordLength)
	}
	return nil
}
```

Decide to keep the validating function simple, every imp of will feature its own validator.

#### Testing `validateGuess()`-- 

Extrcting the validation into a deidcated method is one way to test unitary behavior. Will use Table-Driven test to cover several cases without too much repetition -- test -- new function.

```go
func TestGameValidateGuess(t *testing.T) {
	tt := map[string]struct {
		word     []rune
		expected error
	}{
		"nominal": {
			word:     []rune("GUESS"),
			expected: nil,
		},
		"too long": {
			word:     []rune("POCKET"),
			expected: errInvalidWordLength,
		},
		"empty": {
			word:     []rune(""),
			expected: errInvalidWordLength,
		},
		"nil": {
			word:     nil,
			expected: errInvalidWordLength,
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			g := New(nil)

			err := g.validateGuess(tc.word)
			if !errors.Is(err, tc.expected) {
				t.Errorf("%c, expected %v, got %v", tc.word, tc.expected, err)
			}
		})
	}
}
```

for the Uppercase test like:

```go
func TestSplitToUppercaseCharacters(t *testing.T) {
	tt := map[string]struct {
		input string
		want  []rune
	}{
		"lowercase": {
			input: "pocket",
			want:  []rune("POCKET"),
		},
	}
	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			got := splitToUppercaseCharacters(tc.input)

			if !slices.Equal(tc.want, got) {
				t.Errorf("expected %v, got %v", tc.want, got)
			}
		})
	}
}
```

