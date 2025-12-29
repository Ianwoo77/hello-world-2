# Exporting Parquet Files

```python
conn.execute('''
             COPY airports from './data/airports.parquet' (FORMAT parquet)
             ''')
conn.execute('''
             COPY
             (SELECT * FROM airports LIMIT 100)
             TO
             './data/airports_100.parquet' (FORMAT PARQUET)
             ''')
```

#### Working with Excel Files

To load data from an Excel, you need to us the `spatial`extension, which provides support for geospatial data processing in DuckDB -- 

- `httpfs`enables reading and writing files over HTTP or cloud storage.
- `icu`- advanced string processing and internationalization feature via the ICU
- `sqlite`- provides the ability to read and query SQlite dbs files
- `inet`adds support for working with IP addresses and network data.

And to load Excel worksheet into a DuckDB dbs, the following code snippet loads the worksheet into a DuckDB table named airports -- just like:

```python
conn.execute('INSTALL spatial')
conn.execute('LOAD spatial')
```

There are a few points worith explaining -- 

- The `spatial`extension must be installed and loaded before importing the excel data. this needs to be done only once, the extension will be remembered until DuckDB is uninstalled.
- Then use the `st_read()`to read from the Excel spreadsheet.

```python
conn.execute('''
             create table airports
             AS
             select * from st_read('../data/airports_and_airlines.xlsx',
                layer='airports');
             ''') # layer for worksheet's name
conn.execute('select * from airports').df()
```

As can see, the values in the first row of the workseet are automatically detected and used as the column names for the table. This behavior can be actually controlled through the use of the environment variable `ORG_XLSX_HEADERS`, which is part of the `GDAL/ORG`library, which DuckDB uses to read Excel files. So if don’t want this -- 

```python
import os
os.environ['ORG_XLSX_HEADERS']="DISABLE"
```

Once do this, the default names will be `Field1...2`and so on.

However, if you want to force the fields in the first row to be used as the column names for your tble, set the environment variable to `FORCE`-- 

```python
os.environ['ORG_XLSX_HEADERS']= 'FORCE'
```

And note tha the envionment variable is `AUTO`-- which means that the behavior is automatic -- allowing ORG driver for Excel file to decide whether or not to treat the first row as column headers based on its content.

Then try loading the arilines into DuckDB like -- 

```python
conn.execute('''
             create table airlines
             AS
             select * from st_read('../data/airports_and_airlines.xlsx',
                layer='airlines');
             ''')
```

This time, observe that the `st_read()`just has detected that there are no fieldnames that can be used as column names for your table.

So, To ensure that your table has custom column names, can first create a table with the desired column names and data tyeps, and then use the `INSERT`statement to load the data.

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

Note -- Beware of the performance implication of using the `INSERT`statement. In general, try to *avoid using INSERT* to insert rows in DuckDB, especially if your dataset is large.

And another environmnet variable that you can use when loading Excel data is `ORG_XLSX_FIELD_TYPES`-- by default, when parsing Excel spread sheets, DuckDB will automatically detect the data types in the file, if Want to force all the data types to string, set this environment to `STRING`. just like:

```python
os.environ['ORG_XSLX_FIELD_TYPES']= "STRING"
```

##### Exporting tables to Excel

Just like with the other file formats, you can export a DuckDB table to Excel format -- like:

```python
conn.execute('''
             COPY airlines
             to './data/airlines.xlsx' WITH (FORMAT GDAL, DRIVER 'xlsx');
             ''')
```

The `FORMAT GDAL`option enables U to export data to a file format that is support by GDAL library.

#### Working with SQL

The last file format that we will discuss in the chapter is MySQL. Very often, your rouce data might be stored in database sever. Such as MySQL. Hence, it would be useful to be load your data stored in MySQL into DuckDB.

1. Create a DuckDB connection
2. Create a MySQL connection
3. Retreive the data from the MySQL server
4. Create a table in the DuckDB database with the same schema as that of the table in MySQL.
5. Iterate through each row obtained from MySQL and insert it into the DuckDB table.
6. Close the conenctions to MySQL and DuckDB.

For the PostgreSQL -- just like:

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
    
    #1. Create a cusor object to interact with the DB
    cursor = connection.cursor()
    query = "SELECT * FROM public.movies"
    cursor.execute(query)
    rows = cursor.fetchall()
    print(f"Total rows retreived {len(rows)}")
    for row in rows:
        print(row)
except Exception as error:
    print(f"Error: {error}")
```

For the mysql -- need to:

```sh
pip install mysql-connector-python
```

```python
import mysql.connector
import duckdb

# MySQL connection information
mysql_host = 'localhost'
mysql_user = 'user1'
mysql_password = 'password'
mysql_database = 'My_DB'
mysql_table = 'airlines'

# 1. Connect to MySQL
mysql_conn = mysql.connector.connect(
    host=mysql_host,
    user=mysql_user,
    password=mysql_password,
    database=mysql_database
)
mysql_cursor = mysql_conn.cursor()

# 2. Query data from MySQL
mysql_query = f'SELECT * FROM {mysql_table}'
mysql_cursor.execute(mysql_query)
rows = mysql_cursor.fetchall()

# 3. Create a DuckDB connection (In-memory)
duckdb_conn = duckdb.connect() # then query...
```

## Reading files

In this, are going to learn how to read some fles, get some data out of them, and do sth useful.

```tex
Title: Hello, TDD world!
Description: First post on our wonderful blog
Tags: tdd, go
---
Hello world!

The body of posts starts after the `---`
```

Expected data -- like:

```go
type Post struct {
    Title, Description, Body string
    Tags []string
}
```

#### Iteratvie, test-driven development -- 

We will take an iterative approach where we’re always taking siple, safe steps toward our goal. This requires us to break up our work -- careful not to fail into the trap of *bottom up* approach. Once we have delivered a small amount of consumer value end-to-end, further iteration of the rest of the requirement is usually straightforward.

##### Thinking about the kind of test we want to see - 

- Write the test we want to see -- Thinking about we’d like to use the code we are going to write from a consumer’s point of view.
- Focus on what and why, but don’t get distracted by now.

Package just needs to offer a function that can be pointed at folder, and return us some posts. Like:

```go
var posts []blogposts.Post
posts = blogposts.NewPostFormFS("some-folder")
```

To test this, need some kind of test folder with some example in it -- but making some trade-offs.

- For each test U may need to create new files to test a particular behavior
- Some behaviro will be challenging to test, such as failing to load files
- the tests run a little slower cuz need to access the file system.

##### File system abstraction from Go 1.16

Go 1.16 introduced an abstraction for file systems -- `io/fs`package. Package `fs`defines a basic interface to a file system, a file system can be provided by the host operating system but also by other packages.

On the producer side of the interface, the new `embed.FS`type implements `fs.FS`-- as does, `zip.Reader`-- the new `os.DirFS`function provides an imp of `fs.FS`backed by a tree of operating system files. New `NewPostsFromFS`function becomes a black box that doesn’t care where the bytes are actually stored -- 

- Local development -- use the `os.DirFS(".")`to read files directly from your hard drive.
- Production -- use `//go:embed`to embed blog posts directonly into the compiled binary.
- Cloud/remote -- could even write a custom wrapper to interface with an S3 Bucket or a dbs.

Implmentation -- using the `testing/fstest`is a major upgrade for unit test -- you no longer need to create a temporary directories on your machine and clean them up after tests. Fore:

```go
fs := fstest.MapFS{
    "hello-world.md": {Data: []byte("Title: Hello")},
}
// No disk I/O required, extremely fast!
posts := blogposts.NewPostsFromFS(fs)
```

And when implementing `NewPostsFromFS()`-- keep in mind that `fs.FS`is a very minimal interface -- it only has an `Open(name string)`method -- if need to traverse a directory tree to find all posts, can use the helper function providedy by the STDLIB, like `fs.ReadDir(someFS, ".")`or `fs.WalkDir()`.

#### Write the test first -- 

Should keep scopes as small and useful as possible. The good start is to read all the files in a directory -- that will be a good start - this will give us confidence in the software we are writing. Can check that the count of the `[]Post`returned is the same as the number of files in our fake file sytem. Just like:

```go
func testNewBlogPostLen(t *testing.T) {
	fs := fstest.MapFS{
		"hello-world.md":  {Data: []byte("Title: Post 1")},
		"hello-world2.md":  {Data: []byte("Title: Post 2")},
	}
	posts := blogposts.NewPostsFromFS(fs)
	if len( posts) != len(fs) {
		t.Errorf("got %d posts, wanted %d posts", len( posts), len(fs))
	}
}
```

Noticed the package name the postfix with `_test`-- when TDD is practiced well, we take a *consumer-dirven* approach -- don’t want to test internal details cuz consumer don’t care about them. By append `_test`to our intended package name, only access *exported members* from our package -- just like a real user of our package.

A `MapFS` is just a simple *in-memory* file system for use in tests, represented as a map from path names to information about the fiels or directories they represent. This feels simpler than maintining a folder to test files, and will just execute quicker.

```go
// write a minimum imp
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

Already our idealised view of the world has been foiled cuz errors an happen, but remember now our focus is making test pass, not changing design. The rest of code is straightforward -- iterate over the entires, create a `Post`for each one and return the slice.

