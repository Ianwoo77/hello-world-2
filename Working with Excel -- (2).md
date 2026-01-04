# Working with Excel -- (2)

To ensure that your table has custom column names, can first create a table with the desired column names and data types, and then use the `INSERT`statement to load the data from the `Excel`spreadsheet.

```python
conn.execute('INSTALL spatial')
conn.execute('LOAD spatial')
conn.execute('''
             CREATE TABLE airlines (
                IATA_CODE STRING,
                AIRLINES STRING);

            INSERT INTO airlines
            select * from st_read('../data/airports_and_airlines.xlsx', 
                layer='airlines')
             ''')
```

Or let’s load an Excel worksheet into a DuckDB dbs, the following code snippet loads the `airports`worksheet into a DuckDB table named airports -- 

```python
conn.execute('''
    CREATE TABLE airports
    	as
    SELECT * FROM st_read('airports_and_airlines.xlsx', layer='airports');
''')
display(conn.execute('SELECT * FROM airports').df())
```

Note that the `spatial`extension must be installed and loaded before importing the Excel data. This needs to be done only once -- the extension will be remembered until DuckDB is uninstalled.

And the `st_read()`function reads from the Excel spreadsheet. The worksheet to load is specified through the `layer`argument.

##### Exporting tables to Excel

Just like with the other file formats, you can export a DuckDB table to Excel format -- like:

```python
conn.execute('''
             COPY airlines
             to './data/airlines.xlsx' WITH (FORMAT GDAL, DRIVER 'xlsx');
             ''')
```

In the code snippet, the `airlines`table is sved to the `airlines.xlsx`file. And the `FORMAT GDAL`option enables U to export data to a file with a file format that is supported by GDAL, For Geospatial Data Abstraction Library.

### Working with SQL

```sh
pip install psycopg2-binary
```

The efficient way -- Using the postgres Extension -- just like -- DuckDB can attach to a Postgres database as if it were a local schema.

```python
#1. Connecto DuckDB
con = duckdb.connect('my_duckdb.db')
con.execute("INSTALL postgres; LOAD postgres")

# Connect to your instance
pg_conn_str = "host=localhost user=postgres password=password dbname=my_db"
con.execute(f"ATTACH '{pg_conn_str}' AS pg_db (TYPE POSTGRES);")

# Copy the table directly
con.execute("Create table local_table as SELECT * FROM pg_db.remote_table.name")
```

Or using curosr like:

```python
import psycopg2

try:
    connection = psycopg2.connect(
        user="postgres",
        password="south",
        host="127.0.0.1",
        port="5432",
        database="greenlight",
    )

    # 1. Create a cusor object to interact with the DB
    cursor = connection.cursor()
    query = "SELECT * FROM public.movies"
    cursor.execute(query)
    rows = cursor.fetchall()
    print(f"Total rows retreived {len(rows)}")
    for row in rows:
        print(row)
except Exception as error:
    print(f"Error: {error}")
finally:
    # Close the cursor and connection if they were successfully created
    if cursor:
        cursor.close()
    if connection:
        connection.close()
    print("PostgreSQL connection is closed")
```

### A Primer on SQL

DuckDB CLI is a tool that allow users to intersact with DuckDB directly from the command line. 

```sql
duckdb
D create TABLE arilines as FROM '../data/airlines.csv';
show tables;
select * from arilines;
```

Dot Commands -- with the DuckDB CLI, can execute commands that are specified to the DuckDB CLI environment using the `.`command -- fore, if want to view the list of *dot* commands -- 

```sh
.help
```

##### `.database`

To view the current dbs in use, use the `.database`command -- This command shows that the current dbs in use in `mydb.duckdb`with the alias `mydb`.

`.open`-- Started the `DuckDB CLI`with no filename specified, and then later you decided that you want to open an existing DuckDB database, can do: If U want to keep the current dbs open and work with and additional one, use the `ATTACH`statement.

`.read`-- the `.read`command in the DuckDB CLI is used to execute SQL commands from a file.

```sql
CREATE TABLE airports2 as FROM '../data/airports.csv';
SELECT * FROM airports2; -- named commands.sql
```

`.read './data3/commands.sql'`

## File system abstraction introduced in Go 1.16

Go 1.16 introduced an abstraction for file systems - `io/fs`package -- Package `fs`defines basic interfaces to a file system. A file system can be provided by the host operating system but also by other packages.

#### Write the test first

Should keep scopes as small and useful as possible, prove that we can read all files in a directory, that ill be a good start -- give us in the software writing.

```go
func TestNewBlogPostLen(t *testing.T) {
	fs := fstest.MapFS{
		"hello-world.md":  {Data: []byte("Title: Post 1")},
		"hello-world2.md": {Data: []byte("Title: Post 2")},
	}
	posts := blogposts.NewPostsFromFS(fs)
	if len(posts) != len(fs) {
		t.Errorf("got %d posts, wanted %d posts", len(posts), len(fs))
	}
}
```

We have imported `testing/fstest`which gives us access to the `fstest.MapFS`type. -- a `MapFS`is just a simple in-memory fiel system for use in tests -- representeed as a map from path names to information about the files or directories they represent.

```go
func NewPostsFromFS(fileSystem fs.FS) []Post {
	// fore, if use os.DirFS("home/user/blog", "."), . refers blog folder
	dir, _ := fs.ReadDir(fileSystem, ".")
	var posts []Post
	for range dir {
		posts = append(posts, Post{})
	}
	return posts
}
```

#### Error handling -- 

We parked error handling eariler when we focused on making the happy-path work.  Before continuing to iterate on the functionlity, we should acknowledge that errors can happen when working with files.

```go
func TestNewBlogPostLen(t *testing.T) {
	fs := fstest.MapFS{
		"hello-world.md":  {Data: []byte("hi")},
		"hello-world2.md": {Data: []byte("hola")},
	}
	posts, err := blogposts.NewPostsFromFS(fs)
	if err != nil {
		t.Fatal(err)
	}
	if len(posts) != len(fs) {
		t.Errorf("got %d posts, wanted %d posts", len(posts), len(fs))
	}
}
```

Then fixing the code is just like:

```go
func NewPostsFromFS(fileSystem fs.FS) ([]Post, error) {
	// fore, if use os.DirFS("home/user/blog", "."), . refers blog folder
	dir, err := fs.ReadDir(fileSystem, ".")
	if err != nil {
		return nil, err
	}
	var posts []Post
	for range dir {
		posts = append(posts, Post{})
	}
	return posts, nil
}
```

This will make the test pass, the TDD practitioner in you might be annoyed we didn’t see a failing test before writing the code to propagate the error from `fs.readDir`.

##### Write the test first -- 

Start with the first line in the proposed blog post schema, the title field -- 

```go
func TestNewBlogPosts(t *testing.T) {
	const (
		firstBody = `Title: Post 1
Description: Description 1
Tags: tdd, go
---
Hello
World`
		secondBody = `Title: Post 2
Description: Description 2
Tags: rust, borrow-checker
---
B
L
M`
	)
	fs := fstest.MapFS{
		"hello world.md": {Data: []byte(firstBody)},
		"hello-world2.md": {Data: []byte(secondBody)},
	}
	posts, err := blogposts.NewPostsFromFS(fs)

	assertNoError(t, err)
	assertPostsLength(t, posts, fs)

	assertPost(t, posts[0], blogposts.Post{
		Title:       "Post 1",
		Description: "Description 1",
		Tags:        []string{"tdd", "go"},
		Body: `Hello
	World`,
	})
}

func assertNoError(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}

func assertPostsLength(t *testing.T, posts []blogposts.Post, fs fstest.MapFS) {
	t.Helper()
	if len(posts) != len(fs) {
		t.Errorf("got %d posts, wanted %d posts", len(posts), len(fs))
	}
}

func assertPost(t *testing.T, got blogposts.Post, want blogposts.Post) {
	t.Helper()
	if !reflect.DeepEqual(got, want) {
		t.Errorf("got %+v, want %+v", got, want)
	}
}

func NewPostsFromFS(fileSystem fs.FS) ([]Post, error) {
	// fore, if use os.DirFS("home/user/blog", "."), . refers blog folder
	dir, err := fs.ReadDir(fileSystem, ".")
	if err != nil {
		return nil, err
	}
	var posts []Post
	for _, f := range dir {
		post, err := getPost(fileSystem, f)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}

func getPost(fileSystem fs.FS, f fs.DirEntry) (Post, error) {
	postFile, err := fileSystem.Open(f.Name())
	if err != nil {
		return Post{}, err
	}
	defer postFile.Close()
	return newPost(postFile)
}
```

### HTTP Server

Fore, have been asked to create a web server where users can track how many games players have won -- 

- `GET /players/{name}`should return a number indicating the total number of wins
- `POST /platyers/{name}`should record a win for that name, incrementing for every susequent `POST`.

##### The TDD Philsophy: *RED, GREEN, Refactor* -- 

The goal is to keep the problem space small and avoid ribbit holes by following a strict disipline -- 

- `Red`-- Writing a failing test first
- `Green`-- Write minimal code necessary to pass the test -- even if the code is `sinful`or hardcoded
- `Refactor`-- Clean up the code once you are safely back in passing state.

##### Solving the Chicken and Egg problem -- 

When building a system where one feature depends on another -- the text suggests using interface and mocking -- 

|     Technique     | Purpose                                                      |
| :---------------: | ------------------------------------------------------------ |
|    Interfaces     | Define a `PlayerStore` interface so the server doesn't care *how* data is saved, only that it *can* be saved. |
|    Stubs/Mocks    | Use a "stub" (a fake data source) to test the `GET` endpoint without a real database. |
|       Spies       | Use a "spy" to verify that the `POST` endpoint is actually calling the save function. |
| Iterative Storage | Start with a simple in-memory store to get the app running quickly, then swap it for a real database later without changing the server logic. |

The purpuse of a stub is to mimic the behavior of the storage layer, allowing us to focus on testing the HTTP handler logic to mimic the behavior of the storge layer, allowing us to focus on testing the HTTP handler logic without worrying about whether a real dbs has been built yet.

Defining the interface -- 

```go
type PlayerStore interface {
    GetPlayerScore(name string) int
}
```

Create the stub -- implements the interface -- Doesn’t involve a real dbs, instead, it uses a hardcoded `map`to return values we pre-define for the test -- like:

```go
// StubPlayerStore implements the PlayerStore interface
type StubPlayerStore struct {
    scores map[string]int
}

// GetPlayerScore is the stubbed implementation of the interface method
func (s *StubPlayerStore) GetPlayerScore(name string) int {
    score := s.scores[name]
    return score
}
```

##### Using the Stub in a Test -- TDD process -- 

When writing the test, inject this stub into the server -- 

```go
func TestGETPlayers(t *testing.T) {
    // Setup: Manually create a stub with predefined data
    store := &StubPlayerStore{
        map[string]int{
            "Pepper": 20,
            "Floyd":  10,
        },
    }
    
    // Inject the stub into your Server
    server := &PlayerServer{store}

    t.Run("returns Pepper's score", func(t *testing.T) {
        request, _ := http.NewRequest(http.MethodGet, "/players/Pepper", nil)
        response := httptest.NewRecorder()

        server.ServeHTTP(response, request)

        assertStatus(t, response.Code, http.StatusOK)
        assertResponseBody(t, response.Body.String(), "20")
    })
}
```

##### Why is this effective -- 

1. Decoupling -- your `PlayerServer`doesn’t care if the data comes from memory, file, or MySQL
2. Speed -- tests run extremely fast -- cuz don’t involve network or disk I/O
3. Determinism -- Since the data in the stub is manually defined within the test, the results are predictable and won’t be affected by external environments.