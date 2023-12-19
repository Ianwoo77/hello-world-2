# Redirect and rewrites

A redirect in Nginx is same as redirects in any other platform. To demonstrate how redirects work, update your configuraiton to look like this:

```nginx
http {
	
	include /etc/nginx/mime.types;

	server {
		listen 80;
		server_name nginx-tests;

		root /srv/nginx-handbook-projects/static-demo;

		location = /index_range {
			return 307 /index.html;
		}

		location = /about_page {
			return 307 /about.html;
		}
	}
}
```

For this, if send a request to http://nginx-handbook.test/about_page you will be redirected to about.html And if visit http://localhost/about_page from the browser.

And a `rewrite`directive, however, works a little differently, it changes the URI internally, without letting the user know. To see like:

```nginx
rewrite /index_page /index.html;
rewrite /about_page /about.html;
```

So, apart from the way the URI change is handled, there is just another difference between a redirect and rewrite, when a rewrite hannpes, the server context gets *re-evaluated* by nginx.

### How to try for multiple Files

The final concept showing in this is the `try_files`directive, instead of responding with a single file, the `try_fiels`directive lets you check for the extenience of multiple files like:

```nginx
try_files /the-nginx-handbook.jpg /not_found;
location /not_found {
    return 404 "sadly, you've hit a brick wall buddy!\n";
}
```

As can see, a new `try_files`directive has been added. by Writing `try_files /the-nginx-handbook.jpg /not_found`-- you are just instructing nginx to look for a file named the the-nginx-handbook.jpg file on the root whever a request is recevied-- and if it doesn’t exist, go to the `/not-found`location. so now the problem with writing `try_files`directive this way is that no matter what URL you visit, as long as a request is received by the server and the-nginx-handbook.jpg file is found on the disk.

And that is why `try_files`is often used with the `$uri`variable.

```nginx
try_files $uri /not_found;
location /not_found {
    return 404 "sadly, you've hit a brick wall buddy!\n";
}
```

Here, by just writing `try_files $uri /not_found;`you are instructing NGINX to try for the URI requested by the client first, if it doesn’t find taht one, then try the next one. For now if you request a file that doesn’t exist, you will get the response from just the `/nout_found`location.

And, one thing that you may have already noticed is that if you visit the server root, get 404 also. This is cuz when are hitting ther server root, the `$uri`variable doesn’t correspond to any existing file so NGINX serves you the fallback location. need to update the configuration like:

```nginx
try_files $uri $uri/ /not_found;
```

By just writing `try_files $uri $uri/ /not_found`, you’re just instructing Nginx to try for the requeted URI first, not that if that doesn’t work then try for the requested URI as a directory, and whatever Nginx ends up into a diectory it *automatically starts looking for an index.html* file.

So the `try_files` is the kind of directive that can be used in a number of variations.

### Logging in Nginx

By default, Nginx’s log files are located inside the `/var/log/nginx`, if you visit the content of this directory, may see somethine as follow like:

```sh
#delete the old
sudo rm /var/log/nginx/access.log /var/log/nginx/error.log

# create new files
sudo touch /var/log/nginx/access.log /var/log/nginx/error.log

# !!! note reopen the log files
sudo nginx -s reopen
```

Note that if do not dispatch a `reopen`signal to NGINX, *it will keep writing logs to prevously open streams* and the new files will remain empty. And now to make an entry in the access log, send a request to the server like:

```sh
sudo cat /var/log/nginx/access.log
```

As can see, a new entry has been added to the access.log file. Any request to the server will be logged to this file by default. But, can change this behavior using the `access_log`directive like:

```nginx
erver {
    listen 80;
    server_name nginx-tests;

    location / {
        return 200 "This will be logged to the default file.\n";
    }

    location /admin {
        access_log /var/logs/nginx/admin.log;
        return 200 "this will be logged in a separate file\n";
    }

    location = /no_logging {
        access_log off;
        return 200 "this will not be logged!\n";
    }
}
```

The first `access_log`directive insdie the `/admin`location block instructs NGINX to write any acces log of this URI to the `/var/logs/nginx/admin.log`file. And the second one inside the `/no_logging`location turns off access logs for this location completely.

The `error.log`file, on the other hand, holds the failure logs, to make an entry to the `error.log`, you have to make Nginx crash.

```sh
sudo cat /var/log/nginx/error.log
```

Error messages have levels -- A `notice`entiry in the error log is harmless, but an `emerg`or emergency entry has to be addressed right away. There are 8 levels of error messages -- 

- `debug`-- useful debugging information to help determine where the problem lies
- `info`-- informational messages that aren‘t necessary to read but may be good to know.
- `notice`-- sth normal happended that is worth nothing
- `warn`-- sth unexpected happended
- `error`- sth was unsuccessul
- `crit`-- problems that need to be critically addressed
- `alert`- prompt action is required
- `emerg`-- The system is an ununsalbe state and requires immediate attention.

And, by default, Nginx records all level of messages, you can just override this behvior using the `erro_log`directive, if you wan to set the *minimum* level of a message to be `warn`fore, then update like:

```nginx
error_log /var/log/error.log warn;
```

Then, validate and reload the configuration, and from now on, only messages with a level of `warn`or **above** will be logged.

### How to use Nginx as a Reverse Proxy

When configured as s reverse proxy, Nginx sits **between** the client and back end server. The client sends requests to Nginx, then Nginx passes the request to the back end.

Once the back end server finishes processing the request, it sends it back to Nginx. In turn, Nginx returns the response to the client. During the whole process, the client doesn’t have any idea about who’s actually processing the request. It sounds complicated in writing.

Fore, a very basic and impractical example of a reverse proxy -- like:

```nginx
server {
    listen 80;
    server_name nginx-tests;

    location / {
        proxy_pass "https//nginx.org/"
    }
}
```

Apart from validating and reloading the configuration, you will also have to add this address. note that, just in the `hosts`file. Should be even able to nav around the site to an extent.

## Writing debug output with `t.Log`-- 

Speaking of useful info, sometimes we’d like the test to be able to ouptut things that aren’t failure messages. like:

```go
want := "right"
got := StageOne()
got = StageTwo(got)
//...
if want != got {
    t.Errorf("want %v, got %v", want, got)
}
```

And if it turns out after `Stage`that have what we want, may be difficult to work out why not. And if we happen to know exactly what the results of `StageOne`and `StageTwo`should be, then we can test fro them in the usual way, and use `Fatal`to fail the test if they’re incorrect. like:

```go
got := StageOne()
t.Log("StageOne result", got)
got= StageTwo(got)
t.Log(got)
```

Supposting the test passes, then we will see no output at all. But when it *does* fail, see the output of these calls to `t.Log`along with the failure message. And why not use `fmt.Println`-- cuz tests should pass sliently and fail loudly. Also, when tests are running in parallel, messges printed by `fmt`can appear confusing out of sequence. It’s hard to tell which test they came from. Convently, only the log messges from failing tests are printed.

### Test flags -- `-v`and `-run`-- 

As seen, the `go test`command can take an arg sepecifying a package, or list of package, to test. Most commonly, want to test all the packages from the current directory downwards -- looks like this:
`go text ./...` And there are some useful switches that alter the behaviro of the `go test`command. Fore, the `-v`flag prints out the nmes of each test as it runs, its results, and any log messages, regardless of failure status.

If a particular package is just unchanged since the last run -- will just see cached results, so:

`go test -count=1` // override the cache

It’s usually a good idea to run *all* your tests, all the time, but sometimes you may want to run a single test in isolation -- while you are in the middle of a big refactoring, this will inevitably cause a few tests to fail. On the CLI, to run a single test in this way, use the `-run`flag with test name:

Assistants: `t.Helper`-- if it’s cuz there is a lot of paperwork involved in calling your function, then the test may be helping you to identify a design smell. If the paperwork can’t be eliminated -- it can always be moved into another function. By creating a new abstraction to take care of this for us, hide the irrelevant mechanics of the test setup. Like:

```go
func TestUserCanLogin(t *testing.T) {
    createTestUser(t, "jo schmo", "dummy password")
    //...
}
```

For this, there are probably many lines of uninteresting setup code concealed behind the call to `createTestUser`, by invoking an abstraction in this way, hide irrelevant detail, and help to focus the reader’s attention on what’s really important in the test. And it seems likely that there could be some error while creating the test user, but, checking and handling a return value from `createTestUser`would add clutter back into the main test -- where we dn’t want it. If don’t want `createTestUser`to return any errors it encounters, -- just like:

```go
func createTestuser(t *testing.T, user, pass string) {
    t.Helper()
    // crate user
    if err != nil {
        t.Fatal(err)
    }
}
```

And, notice that call to `t.Helper`here, -- this marks the function as a test helper, meaning that *any failures will be reported* at the appropraite line in the *test*.

So, calling `t.Helper`effectively makes the helper function invisible to test failures -- this makes sense, since we are usually more interested in knowing which *test* had a problem. Since tests should tell a story, well-named helpers can make that story easier to read like:

```go
user := login(t, "jo Schmo")
defer logout(t, user)
```

### `t.TempDir`and `t.Cleanup`

If the test needs to *create or write data* to files, can use `t.TempDir`to create a temporary directory for them -- like:

`f, err := os.Create(t.TempDir()+"/result.txt")`

This directory is unique to the test, so no other test will interfere with it. When the test ends, this directory and all its contents will alao be automatically cleaned up -- which is just very handy. And when you do need to clean sth up ourselves at the end of a test, can use `t.Cleanup`to register a suitable function. like:

```go
res := someResource()
t.Cleanup(func(){
    res.GracefulShutdown()
    res.Close()
})
```

So, the func registeredy by `Cleanup`will be called once the test has completed, `Cleanup`also works when called from *inside test helpers* -- 

```go
func createTestDB(t *testing.T) *DB {
    db := ...
    t.Cleanup(func(){
        db.Close
    })
    return db
}
```

Here, if had instead written `defer db.Close()`here, then that call would happen just when the *helper* returns, whcih isn’t waht we want. -- need `db`to stay open that the test can use it. -- but when the *test* just done, the cleanup func will be called to close the `db`.

### Tests are for failing -- 

Some tests almost seem determined to overlook any potential problem and merely confirm the prevailing supposition that the system works -- think this is the wrong attituide, -- *want* your tests to fail when the system is incorrect.

```go
func TestNewThing(t *testing.T) {
    t.Parallel()
    _, err := thing.NewThing(1,2,3)
    if err != nil {
        t.Fatal(err)
    }
}
```

However, if the test ignores that value completey, using the `_`-- so it doesn’t really test the `NewThing`does anything at all other than return a `nil`error. -- the purpose of the test is simply to confirm what the developer thinks they already know -- that the function is correct -- *tests are that designed to confirm a prevailing theory and not to reveal new infomation*.

### Detecting Useless implementations

One useful way to think about the value of a given test is to ask -- what incorrect implemeantions would still pass this test -- like: See if we can write a version of `NewThing`that is obviously incorrect -- like:

```go
func NewThing(x, y, z int) (*Thing, error) {
    return nil, nil
}
```

If the result is a pointer to `Thing`, then can at least check that it’s not `nil`. like:

```go
func TestNewThing(t *testing.T) {
    t.Parallel()
    got, err := thing.NewThing(1,2,3)
    if err != nil {
        t.Fatal(err)
    }
    if got== nil {
        t.Error("want no-nil *Thing, got nil")
    }
}
```

## Creating a new User

From a security point of view, it’s not a good idea

```sql
create user 'web'@'localhost';
grant select, insert, update ON snippetbox.* to 'web'@'localhost';
ALTER user 'web'@'localhost' IDENTIFIED By 'pass';
```

```sh
mysql -D snippetbox -u web -p
```

### Installing a dbs driver

To use MYSQL from our go web application we need to install a dbs driver, this essentially acts as a middleman, translating commands between Go and the `MYSQL`dbs itself.

```sh
export https_proxy=http://127.0.0.1:7890
go get github.com/go-sql-driver/mysql
```

Creating a Dbs Connection pool -- Now that the MySQL dbs is all set up and we’ve got a dirver installed, the natural next steop is to connect to the dbs from web application. fore:

```go
db, err := sql.Open("mysql", "web:pass@/snippetbox?parseTime=true")
if err != nil {
    //...
}
```

For this:

- The first parameter to the `sql.Open()`is just the driver name and the second parameter is the *data source name*.
- The format of the data source name will depend on which dbs and driver you’re using. Typcially, can find info and examples in the documentation.
- `parseTime=true`part of the DSN above is a *driver-specific* parameter which instructs our driver to convert SQL TIME and DATE fileds to go `time.Time`objects.
- And the `sql.Open()`just returns a `sql.DB`object -- this isn’t dbs conenction -- it’s a *pool of many connections*. This is an important difference to understand. Go just manages these connections as needed, atuomatically opening and closing connections to the dbs via the driver.
- And the connection pool is safe for concurrent access, so can use it from web application handlers safely.
- NOTE -- the connection pool is intended to be long-lived, in a web app, it’s normal to initialize the connection pool in your `main()`function and then pass the pool to your handlers -- U should just call `sql.Open()`in a short-lived handler itself, would be a waste of memory and network resources.

```go
// for the new import:
import _ "github.com/go-sql-driver/mysql"
//...
dsn := flag.String("dsn", "web:pass@/snippetbox?parseTime=true",
                   "mySQL data source name")
//...
db, err := openDB(*dsn)
if err != nil {
    errLog.Fatal(err)
}
defer db.Close()

//.. for the function like:
func openDB(dsn string) (*sql.DB, error) {
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, err
	}
	if err = db.Ping(); err != nil {
		return nil, err
	}
	return db, nil
}
```

A few things about this code interesting -- 

- Notice how the import path for our driver is prefixed when an underscore -- this is cuz our `main.go`file doesn’t actually use anything in the `mySQL`package.
- the `sql.Open()`actually didn’t create any connection -- all it does is initialize the pool for the later use. Need to note that actual connections to the dbs are established lazily, as and when needed for the first time. So to verify that every is set up just correctly, need to use the `db.Ping()`method to just create a connection and check for any errors.
- Note that the `defer db.Close()`just superfluous.

Testing a connection -- if the application fails, you just will get an `Access deinied...`

### Designing a dbs model

In this, need to sketch out a dbs model for our project -- think of it as a *service layer* or *data access layer* instead. Whatever you prefer to call it, the idea is that we will encapsulate the code for working with mySQL in a separate package to the ret of our application.

Then start by using the `pkg/models/model.go`file to define the top-level data types that our database model will use and return like:

```go
var ErrNoRecord = errors.New("models: no matching record found")

type Snippet struct {
	ID               int
	Title, Content   string
	Created, Expires time.Time
}
```

Just notice how the fields of the `Snippet`struct correspond to the fields in our `MYSQL`table -- ...

