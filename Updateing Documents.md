# Updateing Documents

Once a document is stored in the dbs, it can be changed using one of serveral update methods -- `updateOne`and `updateMany`each take a filter docuemtn as their first parameter and a modifier document, describes chagnes to make. `replaceOne`also take a filter as the first parameter, but as the second parameter, `replaceOne`expects a document with which it will replace the document matching the filter.

Note that the updating a document is just atomic -- if two updates happen at the same time, whichever one reaches the server first will be applied, and then the next one will be applied.

### Document Replacement

`replaceOne`fully replaces a matching document with a new one -- This can be useful to do a dramatic schema migration -- fore : 

```json
{
    "_id": ObjectId("..."),
    "name": "joe",
    "firends": 32,
    "enemies": 2
}
```

want to just move the friedns and enemies to a subdocument named `relationships`.

```js
var joe = db.users.findOne({"name":"joe"});
joe.relationships = {"firends": joe.firends, "emenies": joe.enemies};
joe.username = joe.name;
delete joe.friends;
delete joe.eneimies;
db.users.replaceOne({"name":"joe"}, joe)
```

Just uing the `replaceOne`method like:

```js
db.people.replaceOne({"_id": OjbectId("...")}, joe);
```

### Array Operators

An extensive class of update opeators exists for manipulating arrays -- Arrays are common and powerful data structures, not only are they lists that cna be referenced by index, but can also double as sets.

#### Adding elements

`$push`adds elements to the end of an array if the array exists and creates a new array if does not.

```js
db.collection.find({
    fieldName: { $regex: 'pattern', $options: 'i' }  // case insensitive
});
db.blogs.posts.updateOne({'condition': 'some'},
                        {'$push': {'comments': {'name'}}})
```

For this, if want to add another comment, can simply use `$push`again. So can use the complex array opreations like using `$each`operator like:

```js
{
  $push: {
    'cast': {$each: ['abc', 'def']}
  },
}
```

If U only want the array to grow to certain length,  can use the `$slice`modifier with `$push`to prevent an array from growing beyond a certain size like:

```cs
db.movies.updateOne({...},
                    {"$push": {'top10': {
                        '$each':[...], '$slice': -10
                    }})
```

Thus, `$slice`can be used to create a *queue* in a document.

Finally, can apply the `$sort`modifier to `$push`operations before trimming -- like:

```js
{permalink: {$regex: 'TqgqKUqDbczgNTKXOjeH', $options: 'i'}} // find first
{
  $push: {
    comments: {$each: [{
      
    }], $sort: {'email':-1}}
  },
}
```

This will sort sll of the objects in the array by their `rating`field and then keep the others.

#### Using Arrays as sets -- 

Might want to treat an array as a set, only adding values if they are not present -- can be done using: `$addToSet`operator which is useful for cases where `$ne`won’t work..

```js
db.users.updateOne({...},
                    {$addToSet: {"emails", "joe@gmail.com"}})
// note can also use `$addToSet` with conjunction with `$each`to add multiple unique values.
db.users.updateone({...},
                    {$addToSet: {'emails': {$each: [...]}}})
```

#### Removing elements

There are just a few ways to remove elements from an array -- If you want to treat the array like queue or a stack, cna use `$pop`which can remove elements from either end -- `{$pop: {key: 1}}`, removes an element from the end, -1 removes it from the beginning. like:

```js
db.lists.insertOne({"todo": ['abc','def']})
db.lists.updateOne({}, {$pop: {todo: 1}})
// or can remove using $pull like:
db.lists.updateOne({}, {$pusll: {todo: 'abc'}})
```

Also note that removes all matching document -- not just a single match.

### Using Notification Channels

Channels are mechanism for communicating acorss goroutines via signaling -- A signal can be either with or without data -- but for Go it’s not always strightforwad how to tackle the latter case --  fore:

```go
disconenctCh := make(chan bool)
```

One idea is to handle it as a `chan bool`so -- say we interact with an API that provides us with such a channel. Cuz it’s a channel of Booleans, we can receive either `true`or `false`messages -- it’s probably clear what `true`conveys -- but what does `false`means -- Meaning we don’t need a specific value to convey some information, we need a channel *without* data. Not i nGo, the idiomatica way to handle it is using `chan struct{}`-- in Go, an empty struct is a struct without any fields -- regardless of architecture, it occupies zero bytes of strage -- like;

```go
var s struct{}
fmt.Println(unsafe.SizeOf(s)) // 0
```

An empty struct is a de facto std to convey an absene of meaning -- fore, if we need hash set structure, we should use an empty struct as a value like `map[k]struct{}`-- applied to channels, if we want to create a channel of empty structs comes with Go contexts, a channel can be with or without data. If we want to design an idiomatic API in regard to Go standards -- remember that a channel without data should be expressed with `chan struct{}`

### Not using `nil`channels

A common mistake while w0orking with Go and channels is forgetting that `nil`can sometimes helpful -- 

```go
var ch chan int
<-ch // won't panic, block forever
```

This principle is the same if we send a message to a `nil`channel -- like:

```go
var ch chan int
ch<-0
```

Fore, will implement a `func merge(ch1, ch2 <-chan int)`function to merge two channel into a single channel. By merging them -- mean each message received in either `ch1`or `ch2`will be sent to the channel returned. If:

```go
func merge(ch1, ch2 <- chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for v := range ch1 {
            ch <-v
        }
        for v := range ch2 {
            ch <-v
        }
        close(ch)
    }()
    return ch
}
```

For this the main issue with this is that we receive from `ch1`and *then* we receive from `ch2`-- it means that we won’t receive from `ch2`until `ch1`is closed -- this doesn’t fit our use case -- as `ch1`may be open *forever* -- so want to receive from both channels simultanously. Fore:

```go
func merge(ch1, ch2 <-chan int) <- chan int {
    ch := make(chan int, 1)
    go func() {
        for{
            select {
            case v:= <-ch1:
                ch <-v
            case v:= <-ch2:
                ch <-v
            }
        }
        close(ch)
    }()
    return ch
}
```

For this, the `select`statement lets goroutine wait on multiple operations at the same time -- cuz we wrap it inside a `for`loop, should repeatedly receive message from one or other. Note that loop over a channel using `range`breaks when the channel is closed -- however, the way we implement a `for/select`*doesn’t catch* when either `ch1`or `ch2`is closed -- if at some point `ch1`or 2 is closed, recieved 0 forever.

So a receiver way may expect this code to either panic or block, instead it urns and prints -- so:

```go
ch1 := make(chan int)
close(ch1)

v, open := <-ch1
fmt.Println(v, open)
```

It’s right time to come back to `nil`channels -- receviing from a channel will block forever, how about using this idea in our solution -- instead of setting a Boolean after a channel is closed, also assign this channel to `nil` just like:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for ch1 != nil || ch2 != nil { // at least one isn't nil
            select {
            case v, open := <-ch1:
                if !open {
                    ch1 = nil
                    break
                }
                ch <-v
                
            case v, open := <-ch2:
                if !open {
                    ch2 = nil
                    break
                }
                ch <- v
            }
        }
        close(ch)
    }()
    
   return ch
}
```

Loop as long as at least one channel is still open, then fore, if `ch1`closed, assign to `nil`--  This is the implementation we ahave been waiting for -- cover all the different cases, and it doesn’t require a busy loop that will waste CPU.

## Working with migrations

To manage SQL migirations in the project -- `migrate`command-line tool -- Now that the migrate tool is installed, illustrate how to use it by creating a new `movies`table in the dbs -- The first thing need to do is generate a pair of *migration files* using `migrate create`command like:

```sh
migrate create -seq -ext=.sql -dir=./ create_movies_table
```

- `-seq`indicates that we want to use sequential numbering like 0001.
- `-ext`means that we want to give the migration file ext `.sql`
- The `-dir` indicates what we want to store the migration files
- `create_movies_table`is descriptive lable that we give the migration files to signify their contents.

Then these new two files are completely empty -- edit the `up`migration file to contain the necessary to create statement for the `movies`table like so:

```sql
CREATE TABLE IF NOT EXISTS movies (
    id BIGSERIAL PRIMARY KEY,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    title text NOT NULL,
    year integer NOT NULL,
    runtime integer NOT NULL,
    genres text[] NOT NULL,
    version integer NOT NULL DEFAULT 1
);
```

Notice there how the fileds and types in this table are analogoous to the fields and types in the `Movie`struct that created. This is just important cuz it means we will be able to easily map the data in each row of our `movies`table to a single `Movie`struct in our Go code.

- The `bigserial`-- 64 -bit auto-incrementing integer starting at 1
- `genres`has type `text[]`which is an array of zero-or-more `text`valus -- it’s important to note that the arrays in PSQL are themsevles *queryable and indexable*.
- For storing strings we are using the `text`type -- instead of using `varchar`or `varchar(n)`type.

Just in the `...create_movies_table.down.sql`file like:

```sql
DROP TABLE IF EXISTS movies;
```

Then also create a second pair of migration files contining the `CHECK`containts to enforce some of our business rules at the **dbs-level** -- specifically, we want to make source that the `runtime`value is always greater than 0...

```sql
ALTER table movies ADD CONSTRAINT movies_runtime_check CHECK (runtime>=0);
ALTER TABLE movies ADD CONSTRAINT movies_year_check CHECK (year BETWEEN 1888 AND
    date_part('year', now()));
ALTER TABLE movies ADD CONSTRAINT movies_length_check CHECK (array_length(genres, 1)
    BETWEEN 1 and 5);
```

Then for the down.sql like:

```sql
ALTER TABLE movies DROP CONSTRAINT IF EXISTS movies_runtime_check;
ALTER TABLE movies DROP CONSTRAINT IF EXISTS movies_year_check;
ALTER TABLE movies DROP CONSTRAINT IF EXISTS movies_length_check;
```

### Executing the migirations

Now we are just ready to run the two `up`against our `greenlight`dbs -- if following, go ahead and use the following command to execute the migrations -- passing in the dbs DSN from your environment variable. Just like:

```sh
migrate -path=. -database=$GREEN_LIGHT_DB_DSN up
```

Should see that the movies table has been created, along with a `schema_migrations`table -- The `schema_migrations`table is automatically generated by the `migrate`tool and used to keep track of which migrations have been applied like: `select * from schema_migrations;`

The `version`column here indicates that our migration files up to number 2 in the *seq have been executed against the dbs*. the vlue of the `dirty`is `false`-- indicates that the migration files were clean executed without any errors.

#### Migration to a specific version 

As an alternative to looking at the table, if want to see which migraiton version your dbs is currently on you can run the `migration`tool’s version. Canalso migrate up or down to a specific version by using the `goto`command like:

```sh
migrate -path=. -database=$eample_dsn goto 1
```

#### Executing down migrations -- 

Can use the `down`command to roll-back by a specific number of migrations. Fore, to rollback the most *recent* migration you would run like:

```sh
migrate -path=. -database=$ExAMPLE_DSN down 1
```

#### Fixing errors in migrations

It’s important to talk about what hppens when you make a syntax error in migration files. Note that if the migration file which failed contained multiple SQL statemens - then it’s *possible* that the migration files was *partially* applied before the error was encountered -- in turn, this means taht the dbs in an unknown state as far as the migrate tool is concerned. Accordingly, the version filed in the `schmea_migrations`filed will contain the number for the failed migration and the `dirty`field will be set to `true`. At this point, if u run another migration,will get an error message.

What U need to do is investigate the original error and figure out if the migration file which failed was partially applied. Then u need to manually roll-back the partilly applied migration. Once down, must also force the `version`number in the table to correct value like:

```sh
migrate -path=. -database=$ExAMPLE_DSN force 1
```

If U want, it is posible to use the `golang-migrate/migrate`go package to automatically execute your dbs migrations on appliction start up.

### CRUD operations

In this -- going to focus on building up the functionality for *Createing, reding, upating, deleting* movies in the system -- make quite rapid over the next -- end of this session have the following API endpoins like:

- How to create a *database model* which isolates all the logic for executing SQL queries against the dbs
- How to implement the CRUD operations on a specific resource in the context of an API.

#### Setting up the Movie model -- 

In this going to set up the skeleton code for the dbsmodel - It will encapsulate all the code for reading and writing movie data to and from our dbs. In the `internal/data/movies.go`create a `MovieModel`struct type and some placeholder methods for performing basic CRUD like:

```go
func (m MovieModel) Insert(movie *Movie) error {
	return nil
}

func (m MovieModel) Get(id int64) (*Movie, error) {
	return nil, nil
}

func (m MovieModel) Update(movie *Movie) error {
	return nil
}

func (m MovieModel) Delete(id int64) error {
	return nil
}
```

As an additional step, just going to wrap our `MovieModel`in a parent `Models`struct, doing this totally optionall, has the benefit of giving you a convenient single *container* which can hold and reprsent *all* your dbs model as your app grows -- like:

```go
// Package data under the internal/data package
package data

import (
	"database/sql"
	"errors"
)

var (
	ErrRecordNotFound = errors.New("record not found")
)

type Models struct {
	Movies MovieModel
}

func newModels(db *sql.DB) Models {
	return Models{
		Movies: MovieModel{DB: db},
	}
}
```

Then passed to our handlers as a dependency -- like:

```go
type application struct {
	config config
	logger *slog.Logger
	models data.Models
}
```

### Creating a new Movie

Begin with the `Insert()`method of our dbs model and update this to create a new record in the `movies`table.

```sql
INSERT INTO mvoies(title, year, runtime, generes)
VALUES($1, $2, $3, $4) Returning id, created_at, version
```

For the `Returning`clause -- this is a PSQL-specific clause -- can use to return values from any record that is being manipulated by an `INSERT UPDATE DELETE`statements. Using to returned the the **system-generated** `id, created_at, version`values.

#### Executing the sql Query -- 

For now, rather than using the 3rd-party ORM, talked about how to use the `database/sql`and its various features. Normally, would use Go’s `Exec()`to execute an `INSERT`-- but note that the PSQL and SQLServer is returning a single row of data -- for the `Retunning`, need to use the `QueryRow()`method here instead. Like so:

```go
func (m MovieModel) Insert(movie *Movie) error {
	query := `
	INSERT INTO movies (title, year, runtime, genres)
	values ($s1, $s2, $s3, $s4)
	returning id, created_at, version`

	// check an args slice containing the values for the placeholder parameters from
	// the movie struct, declaring this slice immediately next to our SQL query helps
	// to make it nice and clear
	args := []any{movie.Title, movie.Year, movie.Runtime, pq.Array(movie.Genres)}

	// using the QueryRow() to execute the sql query
	return m.DB.QueryRow(query, args...).Scan(&movie.ID, &movie.CreatedAt, &movie.Version)
}
```

For the paramter inputs, declare in an `args`slice like:

`args := []any{movie.Title, movie.Year...}`