# How to Optimize nginx for Maximum performance

Some of these methods will be application-specific, which means that they will probably need tweaking considering your application requirements. But some of them will be general optimiazation techniques.

How to configure worker processes and worker connections -- Nginx can spawn multiple worker processes capable of handling thousands of requests each like:

```sh
sudo systemctl status nginx
```

Right nw just one process on the system. This number can be changed by making a small change to the configuration file -- just like:

```nginx
worker_processes 2;
events {}
http{
    server {
        listen 80;
        server_name whatever.tests;
        return 200 "woker processes and worker connections configurations\n";
    }
}
```

The  `worker_process`directive written in the `main`context is responsible for setting the number of worker processes to spawn -- now just check the Nginx service once again and you should see two. a rule of thumb in determining the optimal number of worker processes is *number of worker process= number of CPU cores*.

If are runinng on a server with a dual core CPU, the number of worker processes should be set to 2. Just:

```sh
nproc # 4
ulimit -n # number of files your OS is allowed to pen per core.
```

So, just like:

```nginx
worker_processes auto;
events {
    worker_connections 1024;
}
http{...}
```

So the `worker_connections`directive is responsbile for setting the number of worker connections in a configuration. This is also the first time you are working with the `events`context.

### How to cache static conent

The second technique for optimizing your service is caching static content. And regardless of the application you are serving, there is always a certain amount of static content being served, such as stylesheets, images, and so on. Considerin that this contentis not likely to change very frequently, it’s good idea to cache them for a certain amount of time -- Nginx makes this task easy as well. 

```nginx
http{
    include /etc/nginx/mime.types;
    
    server {
        listen 80;
        server_name ...;
        root /srv/nginx-handbook-demo/static-demo;
        
        location ~* \.(css|js|jpg)$ {
            assess_log off;
            add_header Cache-Control public;
            add_header Pragma public;
            add_header Vary Accept-Encoding;
            expires 1M;
        }
    }
}
```

In most apps, store imags in the `WebP`format even if the user submits  different format. This way, configuring the static cache becomes even easier for this. -- Can use the `add_header`directive to include a header in the response to the client. Previously you’ve seen the `proxy_set_header`directive used for 

```sh
ulimit -n # 1024 fore
```

```sh
curl -I http://localhost/the-nginx-handobok.jpg
```

### How to compress responses

The final optmization technique that going to show is a pretty straightforward one: compressing responses to reduce their size like:

```nginx
include /etc/nginx/mime.types;

gzip on;
gzip_comp_level 3;
gzip_types text/css text/javascript;
```

Gzip is just a popular file format used by applications for file compression and decompresion. Nginx can utlize this format to compress responses using the `gzip`directives.

By writing `gzip on`in the http context, you are instructing NGINX to compres responses, the `gzip_com_level1`directive sets the level of compresion, can set it to a very high number, but that doesn’t guarantee better comparession. Setting nubmer between 1~4 gives you an efficient result.

By default, Nginx just compresses HTML responses, to compress other file formats, you will have to pass them as parameters to the `gzip_types`directive.

NOTE that configuring compression in Nginx is not enough, the client has to ask for the compressed response instead of the uncompressed responses, just cuz `add_header Vary Accept-Encoding`-- line in the previuos section on caching.

```sh
curl -I http://localhost/mini.min.css
```

But for this, here is nothing about compression.  Now if you want to ask for compressed version of the file, have to send an additional header.

```sh
curl -I -H "Accept-Encoding: gzip" http://localhost/mini.min.css
```

As can see in the response headers, the `Content-Encoding`is now set to `gzip`meaning this is the compressed versin of the file.

How to understand the Main Configuration file -- original `nginx.conf`file -- this file is meant to be changed by the Nginx maintainers and not by server administrators -- unless they just know exactly what they are doing -- who U how U should configure your servers without changing the `nginx.conf`file.

## Ignoring errors is a mistake

How exactly should we fail the test if there is an unexpected error -- one idea is to call `t.Error`-- but is that good enough -- like:

```go
func TestCreateUser(t *testing.T) {
    //...
    got, err := CreateUser(tesetUser)
    if err!= nil {
        t.Error(err)
    }
}
```

`t.Error`though it marks the test as failed -- *also continues* -- that is not the right thing to do there, we need to stop the test right away -- If `err`is not `nil`, then we don’t have a valid result, so shouldn’t go on to test anything about it, indeed, even looking at the vlaue of `got`could be dangerous.

```go
func Open(path string) (*Store, error) {
    if err != nil {
        return nil, err
    }
    return &Store {
        Data: data,
    }, nil
}
```

This is just conventional among Gophers that functions like this should return a `nil`pointer in the error case. So any code that tries to deference will panic. like:

```go 
func TestOpen(t *testing.T) {
    s, err := store.Open("testdata/store.bin")
    if err != nil {
        t.Error(err)
    }
    for _, v := range s.Data {
        //.. panics if s is nil
    }
}
```

And, this isn’t a total disaster, cuz the test will still fail, so will at least know that something’s wrong, established in previous chapters -- it’s important to make sure that a test fails for the right reasons.

So the test should call `t.Fatal`to bail out immediately. Or in this case, since we’d like to inlcude some formatted data in the message, `t.Fatalf`just like:

```go
func TestOpen(t *testing.T) {
    s, err := store.open("testdata/store.bin")
    if err != nil {
        t.Fatalf("unexpected error opening test store %v", err)
    }
}
```

`t.Fatal()`is not jsut for unexpected errors from the system under test. Should also use it to report any problems we encounters when setting up the `context`for test. FORE, suppose spell it -- in that event, we’d want to see a test failure that tells us what is wront, and we *wouldn’t* want to continue with the test, so can use `t.Fatalf`--

```go
want, err := os.ReadFile("testdata/gloden.txt")
if err != nil {
    t.Fatalf("unexpected error readong gloden file %v", err)
}
```

### Error behaviour in part of you API

So that is how we deal with unexpected errors, but what about expected errors -- if errors are part of your public API, which they usually are, then need to test them.

For the SnippetModel struct just like:

```go
type SnippetModel struct {
    DB *sql.DB
}
func (m *snippetModel) Insert(title, content, expires string) (int, error) {
    return 0, nil
}
```

To use this model in our handlers we need to establish a new `SnippetModel`struct in `main()`and inject as a dependency via the application struct. 

```go
type application struct {
    //...
    snippets *mysql.SnippetModel
}

// ...
app := &application {
    //...
    snippets: &mysql.SnippetModel{DB:db}
}
```

Benefits of this structure -- Setting your models up in this way might seem a bit complex and convoluted, especially if you are new to Go, but as our application continues to grow it should start to become clearer - 

- There is a clean separation of concerns, our dbs logic is not tied to our handlers which means that handler responsibilities are limited to HTTP stuff -- This will make it easier to write tight, focused, unit tests in the future.
- By creating a custom `SnippetModel`type and implementing methods on it we’ve been able to make our model a single, neatly encapsulated object, which can easiy initialize and then pass to our handlers as a dependency.
- Cuz the model actions are defined as methods on an object, -- in our case `SnippetModel`, there is the opportunity to create an interface and mock it for unit testing purposes.

### Using the model in our handlers

bring this back to sth more concrete and demonstrate how to call this new code from our handlers -- 

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        //...
        return
    }
    title := ...
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        app.serverError(w, err)
        return
    }
}
```

```sh
curl -iL -X POST http://localhost:4000/snippet/create
```

Additional information-- placeholder parameters -- In the code constructed our SQL statment using placeholder paameters, where `?`acted as a placeholder for the data we want to insert. The reason for using placeholder parameters to construct our query is to help avoid **SQL Injection** attacks from any untrusted user-provided input -- behind the scenes, the `DB.Exec()`method works in 3 steps -- 

- Creates a new prepared statement on the dbs using the provided SQL statement. dbs parses and compiles the statement, and then stores it ready for execution.
- `Exec()`passes the parameter values to the dbs, the dbs when executes the prepared statement using these parameters. Cuz the parameters are transmitted later -- *after the statement has been compiled,* the dbs treated them as pure data. They can’t change the *intent* of the statement.
- Then closes (or deallocates) the prepared statementon the dbs.

### Single-record SQL Queries

The pattern for SELECTing a singl record from the dbs is a little -- explain how to do it by updating `SnippetModel.Get()`method so that it returns a single specifc snippet bsed on its id like:

```sql
select id, title, content, created, expires from snippets
where expires> UTC_TIMESTAMP() and id= ?
```

And cuz our `snippets`table uses the `id`column as its PK this query will only ever return exactly one dbs row, the query also includes a check on the expiry time so that don’t return any snippets that have expired.

```go
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	stmt := `SELECT id, title, content, expires from snippets
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
```

For this, just returning the `models.ErrNoRecord`error instead of `sql.ErrNoRows`directly, the reason is to help encapsulate the model completely.

Type Conversions -- Behind the scenes of `rows.Scan()`your driver will automatically convert the row output from the SQL dbs to the required native Go types -- so long as you are sensible with the types that U are mapping between SQL and Go -- these conversions should generally just work usually -- 

- `CHAR VARCHAR TEXT` map to `string`
- `BOOLEAN`to `bool`
- INT int, BIGINT int64
- `DECIMMAL`and `NUMERIC`to `float`
- `TIME DATE TIMESTAMP`map to `time.Time`

Note that quirk of our MySQL driver is that need to use the `parseTime=true`parameter in our DSN force it to convert `TIME`and `DATE`fields to `time.Time`. otherwise, these are `[]byte`objects.

Using the Model in our Handlers -- Put the `SnippetModel.Get()`into action -- 

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	// Extract the value of the id parameter from query string and try to
	// covert to integer.
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}

	// use the fmt.Fprintf() to interpolate the id value with our response
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

Additional Information -- In the code above used the `errors.Is()`function -- which was introduced in go to check whether an error just matches a specific value -- The first thing is that `sql.ErrNoRows`is an example of what is known as a `sentinel erro`which can roughly defines as an `error`object stored in an global variable -- Typically U create them using the `errors.New()`function -- A couple of examples of sentinel errors from the std lib.

In older version like:

```go
if err == sql.ErrNoRows{}
```

From 1.13 it is better to use the `errors.Is()`instead like:

```go
if errors.Is(err, sql.ErrNoRows) {}
```

The rason for this is introduced the ability to *wrap errors* to add additional info. And fore, if the sentinel error is just wrapped, then the old style of checking for match will cease to work cuz the wrapped error is not equal to the original sentinel error. In contrast, the `errors.Is()`function works by *unwrapping errors*. 

And there is also another function -- `errors.As()`which can use to check if an error has a specific *type*.