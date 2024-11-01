# Create Mongodb

```js
movie = {"title" : "Star Wars: Episode IV - A New Hope",
... "director" : "George Lucas",
... "year" : 1977}
db.movies.insertOne(movie)
db.movies.find().pretty()
```

Read -- `find`and `findOne`can be used to query a collection. If we just want to see one document from a collection, can use the `findOne`like:

```js
db.movies.updateOne({'title':'whatever'}, {$set: {reviews:[]}})
db.movies.deleteOne
```

### Data Types

Documnets in the Mongodb can be thought of as JSON-like in that they are conceptually similar to objects in Js. Json is a simple representation of data -- the specification can be described in about one paragraph -- and lists only six data types -- this is just a good thing in many ways.

Basec Data types -- Document in MongoDB can be thought of as JSON-like in that they are conceputally similar to objects in the js. Note that For integers, use the `NumberInt`or `NumberLong`classes, which represent 4-byt or 8-byte signed integers -- like:

```js
{'x': NumberInt('3')}
{'x': NumberLong('3')}
```

For *regular expression* Queries can use regexp using Js syntax like -- 

```js
{'x': /foobar/i}
```

*Object ID* is a 12-byte ID for documents. And *binary data* is a string of arbitrary bytes. *Code* -- MongoDB makes it possible to store arbitrary Js in queries and documents like :

```js
{'x': function() {...}}
```

#### `_id`and `ObjectIds`

Every document stores in MongoDB must have an `_id`and value can by any type -- note that -- but it defaults to an `ObjectId`-- in a single collection, every document must have unique value for `_id`-- which ensures that every document in a collection can be uniquely identified just.

ObjectIDs -- `ObjectId`is the default type for `_id`, the `ObjectId`class is designed to be lightweight -- while still being easy to generate in a globally unique way acorss different machines. MongoDB’s distributed nature is the main reason why it uses `Objects`as opposed to sth more traditional -- like an auto-incrementing PK. It is difficult and time-consuming to sync auto-incrementing PKs across multiple servers. NOTE -- Cuz MongoDB designed to be a distributed dbs, it was important to be able to generate unique identifers in a shared environment.

And, `ObjectId`uses 12 bytes of storage -- which gives them a string representation that is 24 hexadecimal digits For this -- The first 4 bytes of an `ObjectId`are a timestamp in seconds since epoch. Next 5 bytes of it are a random value, and final 3 are counter that stars with a random value avoiding colliding on different machines.

#### Running scripts with the Shell -- 

In addition to using the shell interactively, can also pass the shell Js files to execute:

```js
mongo script1.js script2.js
// if run a script using a connection to a non-default host/port mongod
mongo server-1: 30000/foo
```

#### Inserting documents

```js
db.movies.insertOne({'title': 'stand by me'}) // add _id automatically, if not supported
db.movies.insertMany([
{"title" : "Ghostbusters"},
{"title" : "E.T."},
{"title" : "Blade Runner"}])
```

When performing a bulk insert using `insertMany`-- if a document halfway through the array produces an error of some type -- what happens depends on whether U have opted for ordered or unordered operations. As the seoncd parameter to `insertMany`you may specify an options document - Specify `true`for key `ordered`in the options document to ensure documents are inserted in the order they are provided.

Note that specifying `false`and MongoDB may reorder the inserts to increase performance. *Ordered inserts is the default* if no ordering is specified. For ordered inserts, the array pased to `insertMany`just defines the insertaion order. Fore:

```js
db.movies.insertMany([
    {"_id":0, "title": "Top gun"}
    {"_id":1, "title" : 'whatever'}
    {"_id":1, "title" : 'whatever'}
])
```

Error occurred -- And if instead we specify unordered inserts, the first, second, and 4th are inserted like:

```js
db.movies.insertMany([
    {_id: 3, 'title': 'whatever'},
    {"_id" : 4, "title" : "The Terminator"},
	{"_id" : 4, "title" : "The Princess Bride"},
	{"_id" : 5, "title" : "Scarface"}
], {'ordered': false})
```

Might note that the output of these two calls to `insertMany()`hints that other opeations supports write.

### Careful with goroutines and loop variables

Mishandling goroutines and loop variables is probably one of the most common mistakes mady by Go developers when writing concurent applications. fore: 

```go
s := []int {1, 2, 3}
for _, i := range s {
    go func() {
        fmt.Print(i)
    }()
}
```

For this, just create new goroutines from a closure -- as a remainder, a closure is a function value that references variable from outsie its body. We have to know that when a closure goroutine is executed, it doesn’t capture the values when the goroutine is created, instead, all the goroutines refer to the value when the goroutine is created. Instead, all the goroutines refer to the exact same variable -- when a goroutine runs, it prints the value of `i`at the time `fmt.Print`executed.

```go
for _, i := range s{
    val : = i
    go func() {
        //...
    }
}
```

In each iteration, created a new local `val`which captures the current value of `i`before the goroutine is created. Hence, when each closure goroutine executes the print statement - it does so with the expected value.

The second option just don’t use a closure and instead uses an actual function like:

```go
for _, i := range s {
    go func(val int) {
        fmt.Print(val)
    }(val)
}
```

Here, still execute an anonymour function within a new goroutine -- this time it isn’t a closure, the func doesn’t reference `val`as a variable from outside its body -- `val`is now part of the function iput.

### Don’t expect deterministic behavior using `select`and channels

One common mistake made by Go developers while working with channel is to make wrong assumptions about how `select`behaves with multiple channels. A false assumption can lead to subtle bugs that may be hard to identify and reporduce -- Want to implement a goroutine that needs to receive from 2 channels -- 

- `messageCh`-- for a new message to be processed
- `disconnectCh`to receive notifications conveying disconnections -

```go
for {
    select {
    case v:= <-messageCh:
        fmt.Println(v)
    case <-disconenctCh:
        fmt.Println("disconnection, return")
        return
    }
}
```

For this, using `select`to receive from multiple channels -- cuz want to prioritize `messageCh`-- we must assume that we should write `messageCh`case first and the `disconnectCh`case next -- but -- not work. -- If one or more of communications can proceed -- a single one that can proceed is chosen *via uniform pseudo - random selection*.

To prevent possible starvation --Suppose the first possible communication chosen is based on the source order, in that case, may fall into a situation where fore, only receive from one channel cuz of a fast sender. There is no guarantee about which case will be chosen.

There are different possibilities if we wan to receive all the messages before returning in case of a disconnection.

```go
for {
    select {
    case v:= <-messageCh:
        fmt.Println(v)
    case <-disconnectCh:
        for {
            select {
            case v:= <-messageCh:
                fmt.Println(v)
            default:
                fmt.Println("disconnection, return")
                return
            }
        }
    }
}
```

This solution uses an inner `for/select`with two cases -- one one `messageCh`and a `default`case -- using `default`in a `select`is chosen only if none of the other cases match -- in this case, it means we will return only after we have received all the remaining messages in `messageCh`.

Once we have received all the messages fomr `messageCh`-- `select`does not block and choose the `default`case. So reveive the disconnection and enter in the inner `select`-- as long as messages remain in `messsageCh`-- *`select`will always prioritize the first case over `default`*.

This is just a way to just ensure that we receive all the remaining messages from a channel with a recevier on multiple channels -- if a `messageCh`is sent after the goroutien has returned, missing this message. When using `select`with multiple channels, must remember that if mutliple options are possible, the first case in the source order doesn’t automatically win. To overcome that -- 

- Unbuffered channel, or single channel
- Or using inner selects and `default`to handle.

## Decoupling the DSN

At the moment the default command-line flag value for our DSN is explicitly included as a string in the `main.go`file - Even though the username and pwd in the DSN are just for development dbs on the local machine -- would be prefearable to not have this info hard-coded into our project files.

```sh
echo $GREEN_LIGHT_DB_DSN
```

Now just update our file to access the environment variable using the `os.Getenv()`func.

```go
flag.StringVar(&cfg.db.dsn, "db-dsn",
		os.Getenv("GREEN_LIGHT_DB_DSN"), "PostgresSQL DSN")
```

Using the DSN with psql -- A nice side effect of storing the DSN in an envionrment variable is that U can use it to easiliy conenct to the `greenlight`dbs as the `greenlight`user. Rather then specifying all the connection option manually when running the `psql`. `psql $GREEN_LIGHT_DB_DSN`

### Configuring the dbs conenction pool

Talked through the `sql.DB`connection pool at a high-level and demonstrated the core principles of how to use it. Going to depth -- explaining  how the connection pool works behind the scenes - and explopring the settings we can use to change and optimize its behavior -- How the `sql.DB`connection pool work - 

The most important thing to understand is that a `sql.DB`contains *two types of* connections -- *in-use* connections and *idle* connections -- A connection is marked as in-use when are using it to perform a dbs task - fore, executing a SQL statement or querying rows, and when the task is complete, the connection is then marked as idle.

And, when instruct Go to perform a dbs task, will first check if any idle connections are available in the pool -- if one is available, then Go will reuse this existing connection and mark it as *in-use* for the duration of the task. Note that if there are no *idle* ones in the pool when needed one, then Go will create a new additional connection. So, when Go reuses an idle connection from the pool, any problems with the connection are handled gracefully, bad connections will automatically be re-tried twice before giving up.

#### Configuring the pool

The connection pool has 4 methods that we can use to configure its behavior -- `SetMaxOpenConns()`-- allows U to set an upper `MaxOpenConns`limit on the number of open connections in the pool. By default, it’s unlimited. Broadly, the higher that you set the `MaxOpenConns`-- the more dbs quereis can be performed concurrently and the lower the risk is that the *connection pool itself* will be a bottleneck in app.

But -- note that leaving it unlimited isn’t ncessarily the best thing -- by default, Psql has a hard limit of 100 open connections and -- It makes sense limit the number of open connections in our pool to comfortably below -- If the `MaxOpenConns`limit is reaced, and all connections are in-use -- then any further dbs tasks will be forced to wait until a conenction become free and marked as idle.

The `SetMaxIdleConns()`-- sets an upper `MaxIdleConns`limit on the number of the idle conenction in the pool - by default, the maximum number of idle conenctions is 2. And in thery, allowing number of idle connections in the pool will improve performance because it makes it less likely that a new connection need to be established from scratch. Also important to relialize that keeping an Idle connection alive comes at a cost -- takes up memory which can otherwise be used for your app and dbs, and it’s also possible that if a connection is idel for two long then it become unusable. 

Potentially, setting `MaxIdleConns`to high may result in more connections become unusable and more resources being used than if you had a smaller idle connection pool. *U only want to keep a connection idle if U are likely to be using it again soon*.

And another thing to note that the `MaxIdleConns`limit should *always be less* then or equal to `MaxOpenConns`-- Go enforeces this and will automatically reduce the `MaxIdleConns`if necessary.

#### The `SetConnMaxLifetime`

sets the `ConnMaxLifetime`-- the maximum lengh of time that a connection can be reused -- Fore set that to an hour -- fore, it means that all connections will be marked as expired one hour after they were first created, and caoont be reused after expired.

- Doesn’t guarantee that a connection will exist in the pool for an hour.
- A connection can still be in use more than one our after being cretaed.
- This isn’t an idle timeout -- will just expire one hour after it was first created -- not one hour after it became idle.
- Once every second Go runs background cleanup operation to remove expired connections from the pool.

And the `SetConnMaxIdleTime()`-- This works in very similar to `ConnMaxLifeTime`.

#### Putting it into practice -- 

1. As a rule of thumb, should explicitly set a `MaxOpenConns`-- should be comfortable below any hard limits on the number of connections imposed by your dbs and infrastructure. Fore, 25 connections -- this is a reasonable starting point for small-to-medium web apps.
2. In general, higher `MaxOpenConns`and `MaxIdleConns`will lead to better performance.
3. Set `ConnMaxIdleTime`15m.
4. It’s probably ok to leave `ConnMaxLifteTime`as unlimited.

#### Configuring the connection pool 

The command-line flag for the `ConnMaxIdleTime`-- `5s`or `10m`-- to assist with this we can use the `flag.DurationVar()`to read in the command-line flag vlaue -- which will automatically convert it to a `time.Duration`type for us -- like:

```go
type config struct {
	port int
	env  string
	db   struct {
		dsn          string
		maxOpenConns int
		maxIdleConns int
		maxIdleTime  time.Duration
	}
}
//...
```

```go
// read the connection pool settings from command-line into the config struct
flag.IntVar(&cfg.db.maxOpenConns, "db-max-open-conns", 25,
            "Psql max open connections")
flag.IntVar(&cfg.db.maxIdleConns, "db-max-idle-conns", 25,
            "Psql max idle connections")
flag.DurationVar(&cfg.db.maxIdleTime, "db-max-idle-time", 15*time.Minute,
                 "Psql max connection idle time")

// in the `openDB()`
// set the maximum number of open connections in the pool
db.SetMaxOpenConns(cfg.db.maxOpenConns)
db.SetMaxIdleConns(cfg.db.maxIdleConns)
```

### SQL Migrations

Get back to sth a bit more concrete and in this of the book -- creates a `movies`table in the dbs -- to do so, could use psql tool again and reun the necesary `CREATE TABLE`statement aginst our dbs - we are going to explore how to use SQL *migrations* to create the table.

- The hight-level principles behind SQL migrations and why they are useful
- How to use command-line `migrate`tool to programmatically mange changes to your dbs schema.

At a very high-level the concept works like this - 

1. Fore every change that you want to make to dbs schema -- U create a *pair of migration files* --  On file is the *up* migration which contains the SQL necessary to implement the change.
2. Each pair of migration files is numbered sequentially, usually 0001... Or with a *Unix timestamp*.
3. Use some kind of tool or script to execute or *rollback* the SQL statement in the sequential migration files against your dbs. The tool keeps track of which migratins have already been applied.

Using migrations to manage your dbs schema, rather than manually executing the sQL statement yourself.

- The database schema is completely described by the `up`and `down`SQL migration files
- It’s possible to replicate the current dbs schema precisely on another machine By running the nesessary `up`migrations -- big help when need to manage and sync dbs schemas in different environments.
- It’s possible to roll-back dbs schema changes if necessary by applying the appropriate `down`migrations.

#### Installing the migrate tool -- 

To manage SQL migrations -- use the `migrate`command-line tool -- On the Linux -- download a *pre-built binary* and move it to a location on your system path like:

### Working with SQL migrations

First crating a new movies table in the dbs -- The first thing need to do is geneate a pair of *migration files* using the `migrate create`command, 

```sh
migrate create -seq -ext=.sql -dir=./ create_movie_table
```

The `-seq`for want to use sequential number , and the `-ext`-- indicates that we want to give the migration files `.sql`-- and the `-dir`-- indicates that want to store the migration files in the `./migration`directory. Should now see a pair of new `up`and `down`migrations files like -- Just need to edit the up migraiton file to contain the necessary `Create table`statement for `movies`table like:

```sql
CREATE TABLE IF NOT EXISTS movie (
    -- bitserial : 64-bit auto-incrementing integer start at 1
    id BIGSERIAL PRIMARY KEY,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    title text NOT NULL,
    year integer NOT NULL,
    runtime integer NOT NULL,
    
    -- text[] which is an array of zero-or-more text values
    genres text[] NOT NULL,
    version integer NOT NULL DEFAULT 1
);
```

This just important it means we will be able to easily map the data in ecah row of our `table`to a single `movie`struct in the Go code. And just note that in the PSQL, text is generally the best characer type to use.

```sql
-- under the down migration file
DROP table IF exists movies;
```

And the `Drop Table`command in the PSQL always removes any indexes and constrains that exist for the target table. While are at it -- also create a second pair of migration file containing `CHECK`constrains to enforce some of our business rules at the dbs-level. Specifially, we want to make sure that the `runtime`values is always greater than 0, and the `year`is between 1888 and the current year, and the genres is always contains between 1 and 5 items.