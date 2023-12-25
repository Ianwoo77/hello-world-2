# How To configure SSL and HTTP/2

HTTP/2 Bases on Google’s experimental *SPDY* protocol, provides better performance by introducing features like full request and response multiplexing, better compression of header fileds, server push and request prioritization.

1. Binary protocol -- while HTTP/1.x was just a text based protocol, HTTP/2 is binary protocol resulting in less error during data transfer process.
2. Multiplexed Streams - All HTTP/2 connections are multiplexed streams -- meaning multiple files can be transferred in a single stream of binary data.
3. Compressed header -- HTTP/2 compresses header data in response resulting in fater transfer in data.
4. Server Push -- this capability allows the server to send linked resources to the client automatically, greatly reducing the number of requests to the server.
5. Stream Prioritization -- can prioritize data streams based on theiry type resulting in bettern bandwidth allocation where necessary.

```nginx
server {
	listen 80;
	server_name: whatever;

	root /srv/nginx-handbook-projects/static-demo;
}
```

### How to configure SSL

For those of you who may not know, an SSL certificate is what allows a server to make the move from HTTP to HTTPs. These certificates are issued by a certifiate authority (CA). Most of the authorities such as..

```bash
snap install --classic certbot
```

### Directive blocks

Driectives are brought in by modules, if you activate a new module, a specific set of directives become available Modules may also enable directive blocks, which allow for a logical construction of the configuration. And the `events`block that you can find in the default configuration file is brought in by the events module. And for the most of the part, blocks can be nested into each other, follow a specific logic. like:

```nginx
http {
    server {
        listen 80;
        server_name example.com;
        access_log /var/log/nginx/example.com.log;
        location ^~ /admin/ {
            index index.php;
        }
    }
}
```

The `server`block allows you to configure a virtual host, in other words, a website that is to be hosted on your machine. The `server`block, in this example, contains some configuration that applies to all HTTP requests with a `Host`header exactly matching `example.com`.

### Simulating errors

If a function is *supposed* to return an error in certain situations, then in order to test that behaviour, need to arrange for that error to happen -- Sometimes that is just easy, fore, if the function is supposed to return an error for 

Creat first development environment with Vagrant-- this quick start provides a brief introduction. like:

```go
func ReadAll(r io.Reader) ([]byte, error) {
    data, err := io.ReadAll(r)
    if err != nil {
        return nil, err
    }
    return data, nil
}
```

And if the function enconters a read error, it just returns it. Now probably wouldn’t bother to test this behavior in practice, cuz it’s so straightforward, just pretend we do. like:

```go
func TestReadAll_ReturnsAsReadError(t *testing.T) {
    input:= strings.NewReader("any old data")
    _, err := reader.ReadAll(input)
    if err == nil {
        t.Error("Want eror for broken reader, got nil")
    }
}
```

This will always fail. How can we make the `strings.Reader`return an error when someone calls its `Read`method -- can implement our *own* very trivial reader to do that like:

```go
type errReader struct {}
func(errReader) Read([]byte) (int, error){
    return 0, io.ErrUnexpectedEOF
}
```

This just useless -- but that makes it just the thing to use in our test like:

```go
func TestReadAll_ReturnsAnyReadError(t *testing.T){
    input := errReader{}
    _, err := reader.ReadAll(input)
    if err == nil {
        t.Error(...)
    }
}
```

Testing that an error is not `nil`-- There is another kind of mistake it’s esy to make when testing error results-- and it comes from a perfectly understandable through process.

### Detecting sentinel errors with `errors.Is`

It is ever necessary to distinguish between these different errors and make some specific action -- A Sentinel value would be fine -- doesn’t matter that we can’t inlcude any context-specific info in it.

```go
var ErrRateLimit = errors.New("rate limit")
func Request(URL string) error {
    resp, err := http.Get(URL)
    if err != nil {
        return err
    }
    defer resp.Body.Close()
    if resp.StatusCode == http.StatusTooManyRequests {
        return ErrRateLimit
    }
}
```

For, this need to first create some local HTTP server that just responds to *any* request with the ratelmiit status code.

```go
func newRateLimitingServer() *httptest.Server {
    return httptest.NewServer(http.HandlerFunc(
        func (w http.ResponseWriter, r *http.Request){
            w.WriteHeader(http.StatusTooManyRequests)
        }))
}
```

But -- how can *check* that result in a test -- Know that it’s just safe to compare sentinel errors directly, using the `==`operator, and that would work. like:

```go
func TestReqReturnsErrRateLimitWhenRateLimited(t *testing.T) {
	t.Parallel()
	ts := newRateLimitingServer()
	defer ts.Close()
	err := req.Request(ts.URL)
	if !errors.Is(err, req.ErrRateLimit) {
		t.Errorf("Wrong error %v", err)
	}
}

func newRateLimitingServer() *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusTooManyRequests)
		}))
}

```

For this, use the `errors.Is()`function to make this comparison instead. `errors.Is()`can tell us whether some otherwise unspecifid error is just `ErrRateLimit`.

### Sentinel errors and `errors.Is()`-- 

Using `errors.Is()` is generally preferred over direct equality checks, as it allows for more flexibility and is also capable of handling wrapped errors. -- for the `sql.ErrNoRows`is an example of what is known as a `sentinel error`-- can roughly defined as an error object stored in an global variable -- typically u create them using the `errors.New`function a couple of examples of sentiel errors from the std lib.

The reason for the ability to *wrap* errors to add additional info, -- if an sentinel error is just wrapped, then the old style of checking for a match will cease to work cuz the wrapped error is not equal to the original sentinel error.

In contrast, the `errors.Is()`works by *unwrapping* errors-- if necessary, before checking for a match. So basically, perfer to use `errors.Is()`-- it’s a sensible way to future-proof your code and prevent issues caused by you. And another function `errors.As()`which can use to check if an error has a specific type.

### Multiple-record SQL queries

Look at the pattern for executing SQL statements which return multiple rows -- demonstrate by updating the `SnippetModel.Latest()`method to return the most *recently* created ten snippets. like:

```sql
select id, title, content, created, expires from snippets
where expires > UTC_TIMESTAMP() ORDER BY created DESC LIMIT 10
```

```go
// Get this will return a specific snippet based on its id.
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	stmt := `SELECT id, title, content, created, expires from snippets
				where expires> UTC_TIMESTAMP() and id = ?`

	// Use the QueryRow() method on the connection pool to execute our
	// SQL statement, passing in the untrusted id variable as the value for the
	// placeholder parameter, returns a pointer to a sql.Row object
	row := m.DB.QueryRow(stmt, id)

	// initialize a pointer ot a new zeroed Snippet struct
	s := &models.Snippet{}

	// Use the row.Scan() to copy the values from each filed in the sql.Row to
	// the corresponding filed in the Snippet struct.
	err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
	if err != nil {
		// if the query returns no rows, then will return a sql.ErrNoRows error
		if errors.Is(err, sql.ErrNoRows) {
			return nil, models.ErrNoRecord
		} else {
			return nil, err
		}
	}
	return s, nil
}

// Latest will return the 10 most recently created snippets
func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	stmt := `select id, title, content, created,expires from snippets 
		where expires> UTC_TIMESTAMP() ORDER BY created DESC LIMIT 10`

	// use the Query() on the connection pool to execute our SQL statement.
	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	// Note, defer rows.Close() to ensure the sql.Rows result-set is always
	// properly closed, note that this should come after you check for an error
	// from the Query()
	defer rows.Close()

	// initialize an empty *slice* to hold models.Snippet objects
	snippets := []*models.Snippet{}

	// now use `rows.Next` to iterate through the rows in the resultset, this
	// prepares the first row to acted on by the `rows.Scan()`
	for rows.Next() {
		s := &models.Snippet{}
		// use rows.Scan() to copy the values from each field in the row to the
		// new Snippet object that created.
		err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
		if err != nil {
			return nil, err
		}
		snippets = append(snippets, s)
	}

	// and when the rows.Next() loops has finished, we call the `rows.Err()`to
	// retrieve any error that was encountered.
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return snippets, nil
}
```

### Using the Model in the handlers

In the `handlers.go`file and updte the `home`handler to use the `SnippetModel.Latest()`method.

```go
s, err := app.snippets.Latest()
if err != nil {
    app.serverError(w, err)
}

for _, snippet := range s{
    fmt.Fprintf(w, "%v\n", snippet)
}
```

### Transactions and other Details

The `database/sql`package -- The `database/sql`package essentially provides a std interface between you Go app and the world of SQL dbs -- So long as you use this package, the Go code you write will generally be portable and will work with any kind of SQL dbs -- whether it’s MySQL, PostgreSQL.. This means that your app isn’t to tightly coupled to the dbs that you are currently using, and the theory is that you can swap databases in the future without re-writing all of your code.

Managing NULL values -- One thing that Go doesn’t do very well is managing `NULL`values in the dbs record. Fore: pretned that the `title`column in the table contains a `NULL`value in a particular row, if queried that row, then `row.Scan()`would return an error cuz it can’t convert `NULL`to a string. 

To fix this is to change the field that you are scanning into from a `string`to a `sql.NullString`type -- as a rule, the easiest thing to do is simply aovoid `NULL`values.

#### Working with Transactions -- 

It’s important to reallize that calls to `Exec(), Query(), QueryRow()`can use *any connection from* the `sql.DB`pool -- even if you have two calls to `Exec()`immediately next to each other in your code. For this, sometimes is not acceptable, -- To guarantee that the same conenction is used U can wrap multiple statements in a transaction. like:

```go
type ExampleModel struct {
    DB *sql.DB
}
func (m *ExampleModel) ExampleTransaction() error {
    tx, err := m.DB.Begin() // sql.Tx obj represent the in-progress dbs transaction
    if err != nil {
        return err
    }
    
    // Then call the Exec() -- pass in statement like:
    _, err = tx.Exec("INSERT INTO...")
    if err != nil {
        tx.Rollback() // if any error, call the tx.Rollbck()
        return err
    }
    
    // carry out another
    _, err = tx.Exec("update...")
    if err != nil {
        tx.Rollback()
        return err
    }
    
    // And if there are no errors, the statements in the transaction can be committed to 
    // the dbs
    err = tx.Commit()
    return err
}
```

- All statements are executed successfully, or
- No statements are executed and the dbs remains *unchanged*.

### Managing Connections -- 

The `sql.DB`connection pool is made up of connections which are either *idle* or *in-use*. By default, there is no limit on the maximum number of open connections at one time, but the default maximum number of idle connections in the pool is 2, can change these defaults with the `SetMaxOpenConns()`and `SetmaxIdleConns()`methods like:

```go
db, err := sql.Open("mysql", *dsn)
if err != nil {
    log.Fatal(err)
}

db.SetMaxOpenConns(100)
db.SetMaxIdleConns(5) // 0 for no idle conenctions
```

#### Prepared statements

For the `Exec(), Query(), QueryRow()`methods all use prepared statements behind the scenes, *to help prevent  SQL injection attacks*. They set up a prepared statement on the dbs connection, run it with the parameters provided, and then *close the prepared statement*.

This might feel rather inefficient cuz we are just creating and re-creating the same prepared statemetns every singl etime -- in theory, a better approach could be to make use of the `DB.Prespare()`method to create our won prepared statement once, and re-use that instead. This is particular **true** for complex SQL statements, and are repeated very often, in these instance, the ost of re-preparing statements may have a noticeable effecto on run time.