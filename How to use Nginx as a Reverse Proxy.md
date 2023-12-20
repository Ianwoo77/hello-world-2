# How to use Nginx as a Reverse Proxy

When configured as a reverse proxy, Nginx sits between the client and a back end server. The lcient sends requests to Nginx, then Nginx passes the requests to the back end. Note that once the back end server finishes processing the reuest, it send it back to Nginx, in turn, NGINX returns the response to the client.

During the whole process, the client doesn’t have any idea bout who is actually processing the request, it sounds complicated in writing, but once you do it for yourself, will see how easy Nginx makes it. For this:

```nginx
envents {}
http {
    include /etc/nginx/mime.types;
    
    server {
        listen 80;
        server_name nginx.test;
        
        location / {
            proxy_pass "http://nginx.org/";
        }
    }
}
```

note that should be even able to navigate around the site to an extent. FORE, if visit http://nginx.test/en/docs should get the http://nginx.org/en/docs/ page in response.

So as can see, at a basic level, the `proxy_pass`directive simply passes a client’s reuest to a 3rd party server and reverse proxies to the response to the client.

### Node.js with Nginx

Can serve a Node.js app reverse proxied by Nginx. And just note that for this demo work, will need to install node.js on your server, can do that following... And the demo just is a simple HTTP server that responds with a 200 code and a JSON payload. run:

```sh
pm2 start app.js
```

For this, can start the app by simply executing node app.js, but better way is to use this PM2. Is a daemon process manager widely used in production for Node.js applications. Alternatively can also do `pm2 start /.../app.js`from anywhere on the server. can stop the application by executing `pm2 stop app`command. 

And to just verify the applicaiton is running or not. curl -i localhost:3000, then if get 200, then the server is running fine-- then jsut to configure Nginx as a reverse proxy -- open your configuration file and update its content a follows

```nginx
location / {
    proxy_pass "http://localhost:3000";
}
```

Just passing the received request to the Node.js applicaiton runing at port 3000. then send: 

```sh
curl -i http://localhost
```

Although this works for basic server like this, you may have to add a few more directives to make it work in a real world scenario depending on your application’s requirements. Fore, if your application handles web socket connections, then should update the configuration as follows -- like:

```nginx
http {
    listen 80;
    server_name whatever.tests;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade'
    }
}
```

The `proxy_http_version`directive sets the HTTP version for the server, by default, just 1.0, but web socket requires it to be at least 1.1 -- and the `proxy_set_header`directive is used for setting a header on the back-end server.

`proxy_set_header <header name> <header value>`

And, so, by writing `proxy_set_header Upgrade $http_upgrade`, instructing Nginx to pass the value of the `$http_upgrade`variable as a header named `Upgrade`-- same for the `Connection`header.

### How to use Nginx as a Load Balancer

And just thanks to reverse proxy design of Nginx, you can easily configure it as a load balancer -- Already add a demo to the repository comes with this -- just: In a real life senario, load balancing may be required on large scale projects distributed across multiple servers, but for this simple demo, created just 3 very simple servers responding with a server number and 200 status code.

And note that 3 node.js servers should be running on 3001~3003 respectively. like:

```nginx
http {

	upstream backend_servers {
		server localhost:3001;
		server localhost:3002;
		server localhost:3003;
	}

	# include /etc/nginx/mime.types;

	server {
		listen 80;
		server_name nginx-tests;

		location / {
			proxy_pass "http://backend_servers";
		}
	}
}
```

And the configuration insdie the `server`context is the name as you’ve already seen. The `upstream`context, though, is new -- an upstream in Nginx is *a collection of servers* that can be treated as a single backend.

so the three servers you started using PM2 can be put insdie a single upstream and you let Nginx balance to load between them.

```sh
while sleep 0.5; do curl http://localhost; done
```

Can cancel the loop by hitting ctrl C on your keyborad, as can se from the response from the server, Nginx is load balancing the servers automatically.

## Feeble tests

In the previous, compare each field of some struct `got`with some expected value, For complicated sturcts, though, this explicit field-by-field checking could get quite laborious -- Can make the test shorter, clearer, and more comprenehsive by comparing the *entire* struct against some expected value.

The `go-cmp`package, which we enountered -- its power `cmp.Equal`function will compare any two values for deep equality like:

```go
type Thing struct {
	X, Y, Z int
}

func NewThing(x, y, z int) (*Thing, error) {
	return &Thing{}, nil
}

//.........
func TestNewThing(t *testing.T) {
	t.Parallel()
	x, y, z := 1, 2, 3
	want := &service.Thing{
		x, y, z,
	}
	got, err := service.NewThing(x, y, z)
	if err != nil {
		t.Fatal(err)
	}
	if !cmp.Equal(want, got) {
		t.Error(cmp.Diff(want, got))
	}
}
```

And if the struct are different, `cmp.Diff`will report only those fields that differe, which can be just helpful with big structs containing a lot of info. Just like:

```go
func NewThing(x, y, z int) (*Thing, error) {
	return &Thing{x, y, z}, nil
}
```

Maybe this still isn’t enough for our `Thing`to actually be useful, forced the implementer of `NewThing`to at leat do *some* work. Trun our attention to *why* we write those tests, the answer might seem obvious, to make sure the program is corect, and seen that tests can also help guide the design of the program in fruitful directions.

### Communicating with tests

If don’t like the term *model* -- want to think of it as a *service layer* or *data access layer* instead -- whatever you prefer -- the idea is that we will encapsulate the code for working with dbs in separate package to the rest of the application.

```go
var ErrNoRecord = errors.New("models: no matching record found")

type Snippet struct {
	ID               int
	Title, Content   string
	Created, Expires time.Time
}
```

Just noticed how the fields of the `Snippet`struct correspond to the fields in MySQL snippets table.

```go
type SnippetModel struct {
	DB *sql.DB
}

func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	return 0, nil
}

// Get this will return a specific snippet based on its id.
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	return nil, nil
}

// Latest will return the 10 most recently created snippets
func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	return nil, nil
}
```

### Using the SnippetModel

And to use this model in our handlers we need to establish a new `SnippetModel`struct in the `main()`and then inject it as a dependency via the `application`struct.

```go
type application struct {
	errLog   *log.Logger
	infoLog  *log.Logger
	snippets *mysql.SnippetModel
}
//...
app := &application {
    errLog: errorLog,
    infoLog: infoLog,
    snippets: &mysql.SnippetModel{db},
}
```

Benefits of this structure-- Setting your models up in this way might seem a bit complex and convoluted, espeially if -- as application continues to grow it should start to become clearer why structuring things the way we are.

- There is a clean separation of concerns, our dbs logic isn’t ited to our handlers which means that handler responsibilities are limited to HTTP stuff -- This will make it easier to write tight focused, unit tests in the future.
- By creating a custom `SnippetModel`type and implementing methods on it we’ve been able to make our model a single, neatly encapsulated object, which we can easily initialize and then pass to our handlers as a dependency.
- Cuz the model actions are defined as methods on an object -- in the case - there is the opportunity to create an *interface* and mock it for unit testing purpose.
- Have just total control over which dbs is used at runtime -- just by using the command-line flag.

Executing SQL Statements -- create a new record in the `snippets`table and then returns the integer for the new record just like:

```sql
insert into snippets (title, content, created, expires)
values(?,?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY))
```

Just noticed how in this query using the `?`character to indicate *placeholder* parameters for the data that want to insert in the dbs -- cuz the data we will be using will utilimately be untrusted user input from a form.

Executing the Query -- Go provides 3 different methods for executing dbs queries -- 

- `DB.Query()`is used for SELECT queries which return multiple rows
- `DB.QueryRow()`is for returning a single row.
- `DB.Exec()`is used for statements which don’t return rows.

```go
func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	stmt := `INSERT INTO snippets (title, content, created, expires)
VALUES (?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY ))`
	
	// use the `Exec()` method on the embedded connection pool to execute the 
	// stmt. The first parameter is the SQL statement, followed by the title, content
	// and expiry values for the placeholder parameters
	// And this method returns a sql.Result object, which contains some basic
	// info about what happened when the statement was executed
	result, err := m.DB.Exec(stmt, title, content, expires)
	if err != nil {
		return 0, err
	}
	
	// using the `LastInsertId()` on the result object to get the ID of
	// our newly inserted record in the snippets table.
	id, err := result.LastInsertId()
	if err != nil {
		return 0, err
	}
	
	return int(id), nil
}
```

