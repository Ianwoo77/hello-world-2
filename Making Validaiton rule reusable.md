# Making Validaiton rule reusable

In large project it’s likely that you will want to reuse some of the same validation checks in multiple places. Fore, want to use many of these same checks later when a client edits the movie data.

```go
type Movie struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"-"`
	Title     string    `json:"title"`
	Year      int32     `json:"year,omitempty"`
	Runtime   Runtime   `json:"runtime,omitempty"`
	Genres    []string  `json:"genres,omitempty"`
	Version   int32     `json:"version"`
}

func ValidateMovie(v *validator.Validator, movie *Movie) {
	v.Check(movie.Title != "", "title", "must be provided")
	v.Check(len(movie.Title) <= 500, "title", "must not be more than 500 bytes long")

	v.Check(movie.Year != 0, "year", "must be provided")
	v.Check(movie.Year >= 1888, "year", "must be greater than 1888")
	v.Check(movie.Year <= int32(time.Now().Year()), "year", "must not be in the future")

	v.Check(movie.Runtime != 0, "runtime", "must be provided")
	v.Check(movie.Runtime > 0, "runtime", "must be a positive integer")

	v.Check(movie.Genres != nil, "genres", "must be provided")
	v.Check(len(movie.Genres) >= 1, "genres", "must contain at least 1 genre")
	v.Check(len(movie.Genres) <= 5, "genres", "must not contain more than 5 genres")
	v.Check(validator.Unique(movie.Genres), "genres", "must not contain duplicate values")
    //...
}
```

Once it’s done, need to back to our `createMovieHandler`and update it to initialize a new `Movie`struct, copy across the data from our `input`struct, and then call this new validation function like - 

```go
func (app *application) createMovieHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title   string       `json:"title"`
		Year    int32        `json:"year"`
		Runtime data.Runtime `json:"runtime"`
		Genres  []string     `json:"genres"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	movie := &data.Movie{
		Title:   input.Title,
		Year:    input.Year,
		Runtime: input.Runtime,
		Genres:  input.Genres,
	}

	v := validator.New()

	data.ValidateMovie(v, movie)

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
    //...
}
```

First, might be wondering why we’re initializing the validator instance.

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
	//...
}

// the openDB() function returns a sql.DB connection pool
func openDB(cfg config) (*sql.DB, error) {
	db, err := sql.Open("postgres",
		"postgresql://neondb_owner:npg_VzvOCEq4Zs1H@ep-calm-block-adfxhwny-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require")
	if err != nil {
		return nil, err
	}

	// create a context with a 5s timeout deadline
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = db.PingContext(ctx)
	if err != nil {
		db.Close()
		return nil, err
	}
	return db, nil
}
```

### Configuring the dbs connection pool

The most important thing to understand is that a `sql.DB`pool contains two types of connections -- *in-use* connections and *idle* connections -- and a connection is marked as *in-use* when you are using it to perform a dbs task, such as executing a SQL statement or querying rows, and when the task is complete the connection is then marked as idle.

When instruct Go to perform a dbs task, will first check if any idle connections are available in the pool. If one available, then Go will reuse this existing connection and mark it as in-use for the duration of the task. And if there is no idle conncctions in the pool when need one, then Go createa a new additional connection.

#### configuring the pool -- 

This article introduces 4 key ways to configure dbs connection pool behavior in the Go lang -- By properly configuring these parameters, can optimize your app’s performance and prevent dbs overload.

1. `SetMaxOpenConns()`-- sets the maximum number of open connections. Unlimited by default
   - Recommendation -- Don’t leave the default unlimited settings -- should be set below the hard limit of the dbs, such as PostgreSQL defaults to 100
   - Risks and countermeasures -- when the number of connections reaches the limit, new tasks wait for idle connections. To prevent requests from *pending* indefinitely, must use context in dbs operations
2. `SetMaxIdleConns()`-- sets the maximum number of idle connections-
   - DEF -- Limits the maximum number of free connections allowed to be reserved in the pool, default is 2
   - Func - Increasing this value improves performance by avoiding frequent new connections.
   - Cost -- Take up memory, Note that if your setting is too high and not used for a long time, the connection may fail due to timeout settings on the dbs server.
   - Rule -- This value must be less than or equal to `MaxOpenConns`.
3. `SetConnMaxLifetime`-- Sets the maximum time of the connection.
   - Def -- limits the maximum time a connetion can be reused from the moment it is created.
   - Mechanism - once the conenction expires - it is removed by the background cleaner.
   - Note -- The time should not be set too short, otherwise the connection will be destroyed and rebuilt frequenty, and performance will be reduced due to the high frequency of the connection handshake.
4. `SetConnMaxIdleTime()`-- sets the maximum idle time of the connection -- 
   - DEF -- Limits the maximum time a connection can be retained in an idle state - unlimited by default.
   - Advantage -- This is a very partical configuration, it allows U to set `MaxIdleConns`higher to handle bursts of traffic, while using this setting to dynamically free up system resources by regularly cleaning up connections that haven’t been used for a long time.

As a best practice, `MaxOpenConns`should generally be throttled to protect the dbs, `MaxIdleConns`should set appropriately based on the load, and `SetConnMaxIdleTime`should be leveraged to enable dynamic resource.

| Method                     | Definition                                                   | Default Value       | Benefit / Purpose                                            | Risks & Caveats                                              | Best Practice / Key Note                                     |
| :------------------------- | :----------------------------------------------------------- | :------------------ | :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| `SetMaxOpenConns()`        | Sets the limit on total open connections (**In-Use + Idle**). | Unlimited           | • Allows more concurrent queries.<br>• Prevents the pool from being a bottleneck.<br>• Acts as a rudimentary throttle to protect the DB. | • **Unlimited:** Can hit the DB's hard limit (e.g., PostgreSQL default 100), causing errors.<br>• **Limited:** If full, requests hang indefinitely waiting for a free connection. | • Set comfortably below the DB's hard limit.<br>• **Crucial:** Always use `context.Context` timeouts to prevent requests from hanging forever. |
| `SetMaxIdleConns()`        | Sets the limit on **idle** connections retained in the pool. | 2                   | • Improves performance by reducing the need to establish new connections from scratch. | • **Too High:** Wastes memory; connections may become stale/unusable (e.g., MySQL closes after 8hrs) before reuse.<br>• **Too Low:** Frequent connection churn. | • Only keep connections idle if they are likely to be used soon.<br>• Must be ≤ `MaxOpenConns`. |
| **`SetConnMaxLifetime()`** | Sets the maximum time a connection can exist **since creation** before expiring. | Unlimited (Forever) | • Useful if the DB enforces a max lifetime.<br>• Helps facilitate graceful swapping behind load balancers. | • **Not an idle timeout:** Expires based on creation time, even if active recently.<br>• **Too Short:** Causes high frequency of killing/recreating connections, hurting performance. | • Do not make the duration too short to avoid overhead.<br>• Connections are removed by a background cleaner every second. |
| `SetConnMaxIdleTime()`     | Sets the maximum time a connection can remain **idle** before expiring. | Unlimited           | • Allows you to set a high `MaxIdleConns` for traffic spikes, but automatically frees up resources when the app is quiet. | • If set too low, legitimate idle connections might be killed just before they are needed. | • Highly recommended for balancing performance (high capacity) with resource efficiency (cleanup). |

#### Configuring the connection pool

Rather than hard-coding these settings, upgrade the `main.go`file to accept them as command line flags. The command-line flag for the `ConnMaxIdleTime`value is particularly interesting, we want to convey a *duration of time*, like 5s or 10m. To assist with this we can use `flag.DurationVar()`to read in the command-line flag value.

```go
flag.IntVar(&cfg.db.maxOpenConns, "db-max-open-conns", 25, "Database max open connections")
flag.IntVar(&cfg.db.maxIdleConns, "db-max-idle-conns", 25, "Database max idle connections")
flag.DurationVar(&cfg.db.maxIdleTime, "db-max-idle-time", 15*time.Minute, 
                 "Database max connection idle time")
db.SetMaxOpenConns(cfg.db.maxOpenConns)
db.SetMaxIdleConns(cfg.db.MaxIdleTime)
```

### SQL Migrations

To do this, could simply use the `psql`tool again and run the necessary `CREATE TABLE`statement against our dbs. At a very high-level concept works like this -- 

1. For every change that U want to make to your dbs schmea.
2. Each pair of migration files is numbered sequentially, usually 0001...

Using migrations to manage your dbs schema, rather than manually executing the SQL steatements yourself -

- The dbs schema is completely described by the `up`and `down`SQL migration files.
- It’s possible to replicate the current dbs schema precisely on another machine by running the necessary `up`migrations.
- It’s possible to *roll-back* dbs schema changes if necessary by applying the appropriate `down`migrations.

```sh
cd /tmp
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz | tar xvz
mv migrate ~/go/bin/
```

#### Working with SQL Migrations

The first we need to do is generate a pair of *migration files* using the `migrate create`command -- 

```sh
migrate create -seq -ext=.sql -dir=./migrations create_movies_table
```

- `-seq`-- indicates that want to use sequential numbering like
- `-ext`-- indicates that want to give the migration files the extension `.sql`.
- `-dir`-- flag indicates that want to store the migration files in the `./migrations`directory.
- `create_movie_table`is descripitve label that give the migration files to signify their contents.

```sql
CREATE TABLE IF NOT EXISTS movies (
    id bigserial PRIMARY KEY, -- bigserial -- 64-bit auto-incrementing integer
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    title text NOT NULL,
    year integer NOT NULL,
    runtime integer NOT NULL,
    genres text[] NOT NULL, -- text[] is an array of zero-or-more text values.
    version integer NOT NULL DEFAULT 1
);

DROP TABLE IF EXISTS movies;
```

Again, following along, run the command belwow to create a second pair of migration files -- like:

```sql
ALTER TABLE movies ADD CONSTRAINT movies_runtime_check CHECK (runtime >= 1);
ALTER TABLE movies ADD CONSTRAINT movies_year_check CHECK (year BETWEEN 1889 AND date_part('year', now()));
ALTER TABLE movies ADD CONSTRAINT genres_length_check CHECK (array_length(genres, 5) BETWEEN 1 AND 5);
```

So, when insert our update data in our `movies`table, if any of these check fails our dbs driver will return an error similar to this - Executing the migrations -- 

Following along -- go ahead and use the following command to execute the migrations, passing the dbs DSN from your environment variable.

```sh
migrate -path=./migrations -database=$GREENLIGHT_DB_DSN up
```

##### Migrating to a specific version -- 

As an alternative to looking at the `schema_migrations`table, if want to see which migration version your dbs is currently can run `migrate`tool’s version command like -- 

```sh
migrate -path=./migrations -database=$EXAMPLE_DSN version
# can also migrate up or down to a specific version by using the `goto` command
migrate -path=./migrations -database=$EXAMPLE_DSN goto 1
```

##### Exeucting down migrations

Can also use `down`command to roll-back by a specific number of migrations -- fore, to rollback the *most recent migration* you would run -- 

```sh
migrate -path=./migration -database=$EXAMPLE_DSN down 1
```

Generally prefer to use the `goto`command to perform *roll-back* and reverse use of the `down`comamnd for rolling-back all migrations. Another variant of this is the `drop`command which will remove all tables from the dbs including `schema_migrations`table.

#### CRUD Operations

```go
// Define a MovieModel struct type chish wraps a sql.DB pool
type MovieModel struct {
    DB *sql.DB
}

// Add a placeholder method for inserting a new record in the movies table
func (m MovieModel) Insert(movie *Movie) error {
    return nil
}
// for Get, Update, and D
```

As an additional step, going to wrap our `MovieModel`in a parent `Models`struct, doing this totally optional, but it has the benefits of giving U a convenient single *container* which can hold  and representa *all your database* models as your application grows.
