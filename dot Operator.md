# dot Operator

##### `.open`

Say started the DuckDB CLI with no filename specified, and then later U decided that U want to open an existing Duckdb Database -- Can do so by using `.open`command.

```sql
D .open './data3/mydb.duckdb'
```

Can optionally specify an alias for the dbs that you are attaching -- The following example is the same as the previous statement.

##### `.dump`

If U want to render the content of a table as SQL statements, use the `.dump`command -- like:

```sql
.dump arilines
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE arilines(IATA_CODE VARCHAR, AIRLINE VARCHAR);;
COMMIT;
-- ...
```

This command dumps the `airlines`table as a series of SQL statements. This is useful if U need to import the content of a table in DuckDB into a table of another dbs.

##### `.read`

The `.read`in CLI is used to execute SQL commands from a file -- 

```sql
CREATE TABLE airports2 as FROM '../data/airports.csv';
SELECT * FROM airports2;
```

`.read './data3/commands.sql'`

#### Persisting the In-Memory dbs on Disk

Suppose U can in-memory dbs with the DuckDB CLI and load the airports.csv into a table named airports. Remember, in-memory database will be destroyed when U exit the DuckDB CLI -- to save them, need to persist them to disk. 

```sql
D EXPORT DATABASE 'airports_db';
```

This will create a folder named `airports_db`in the current directory, with the files shown in -- .csv file from which U loaded the table, `load.sql`-- the statement to load the CSV file into the table. -- like:

```sql
IMPORT DATABASE './data3/airports_db';
show tables;
```

### DuckDB SQL Primer

```sql
D CREATE TABLE Authors(
    author_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    nationality TEXT,
    birth_year INTEGER
  );
  
D CREATE TABLE Borrowers (
borrower_id INTEGER PRIMARY KEY,
name TEXT NOT NULL,
email TEXT,
member_since DATE
);

D CREATE TABLE Books (
  book_id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  genre TEXT,
  publication_year INTEGER,
  FOREIGN KEY (author_id) REFERENCES Authors(author_id)
  );
  
D CREATE TABLE Borrowings (
    borrowing_id INTEGER PRIMARY KEY,
    book_id INTEGER NOT NULL,
    borrower_id INTEGER NOT NULL,
    borrow_date DATE,
    return_date DATE,
    status TEXT,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id)
    );
```

To create a table in SQL, use the `Create Table`follwed by table name and a list of columns with their data types and optional contraints. The `FOREIGN KEY`and `REFERENCES`keywords are used in SQL to establish relationships between tables. They enforce referential integrity for the data in the tables. Fore:

`FOREIGN KEY (author_id) REFERENCES Authors(author_id)`

##### Viewing the Schemas of Tables

To view the schema of a table, can use the `DESCRIBE`statement, fore, look at the schema of the `Authors`table --

```sql
DESCRIBE Authors;
SHOW Authors;
```

Note that if U want to view the schema of the entire database, use the `.schema`command just  like:

`.schema` -- // *display the course of dbs creating*.

##### Dropping a table -- 

If U need to drop (delete) a table in DuckDB, use the `DROP TABLE`statement -- fore, if have created a table named .. that is no longer needed, can drop it as the following example like:

```sql
DROP TABLE OverudeBorrows;
```

For this, note that if try to drop a table that is referenced by another table, get an error. Fore, If try to drop the `Author`table -- Cuz the `Authors`table contains the `author_id`column that is referenced in the `Books`table.

#### Working with Tables using DuckDB

With the `Authors`created, insert some rows into it with data - like:

```sql
INSERT INTO Authors (author_id, name, nationality, birth_year)
VALUES
(1, 'Jane Austen', 'British', 1775),
(2, 'Charles Dickens', 'British', 1812),
(3, 'Agatha Christie', 'British', 1890),
(4, 'J.K. Rowling', 'British', 1965),
(5, 'Tolkien', 'British', 1892);
# insert only one
INSERT INTO Authors (author_id, name, nationality, birth_year)
VALUES (6, 'Mark Twain', 'American', 1835);
```

Then populate the other tables, Just like:

```sql
INSERT INTO Borrowers (borrower_id, name, email, member_since)
VALUES
(1, 'John Smith', 'john.smith@example.com', '2022-01-01'),
(2, 'Emma Johnson', 'emma.johnson@example.com', '2021-12-15'),
(3, 'Michael Brown', 'michael.brown@example.com', '2022-02-20'),
(4, 'Sophia Wilson', 'sophia.wilson@example.com', '2022-03-10'),
(5, 'William Taylor', 'william.taylor@example.com', '2022-04-05'),
(6, 'Jane Doe', 'jane.doe@example.com', '2022-03-05');

INSERT INTO Books (book_id, title, author_id, genre, publication_year)
VALUES
(1, 'Pride and Prejudice', 1, 'Classic', 1813),
(2, 'Oliver Twist', 2, 'Novel', 1837),
(3, 'Murder on the Orient Express', 3, 'Mystery', 1934),
(4, 'Harry Potter and the Philosopher''s Stone', 4, 'Fantasy', 1997),
(5, 'The Hobbit', 5, 'Fantasy', 1937);
```

Just remember that the `author_id`column in the `Books`table references the `author_id`column in the `Authors`table.  At last, populate the `Borrowing`table:

```sql
INSERT INTO Borrowings (borrowing_id, book_id, borrower_id,
borrow_date, return_date, status)
VALUES
(1, 1, 1, '2022-04-10', '2022-04-25', 'Returned'),
(2, 3, 2, '2022-03-20', NULL, 'On Loan'),
(3, 4, 3, '2022-04-05', NULL, 'On Loan'),
(4, 2, 4, '2022-04-15', NULL, 'On Loan'),
(5, 5, 5, '2022-03-30', '2022-04-20', 'Returned'),
(6, 1, 3, '2022-04-26', NULL, 'On Loan');
```

## HTTP Server

Red, green and refactor -- throughout the book, have emphasised the TDD process of write a test & watch it fail (red), write the minimal amount of code to make it work (green) and then refactor.

#### Solving the Chicken and Egg problem -- 

When building a system, often face a circular dependency -- to build incrementally without getting stuck, the text just suggests -- 

- Interfaces & Mocking -- Instead of building a real dbs immediately, define an inerface
- Stubs for GET -- Use a simple `Stub`to return hardcoded data so that U can test your retreival logic in isolation.
- Spies for Post -- Use a Spy to verify that your storage logic is bing called correctly without needing a real backend.
- In-Memory Start -- implement a simple in-memory storage first to get the software running qucikly.

##### Writing the test first

To create a web server in Go, you will typically call `ListenAndServe`-- just like:

```go
func ListenAndServe(addr string, handler Handler) error
```

For this will start a web server listening on a port, creating a goroutine for every request and running it aginst a `Handler`. Fore:

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

A type implements the handler interface by implementing the `ServeHTTP`method which expects two arguments, first is where we write our response and the second is the HTTP req that was sent to the server.

```go
func TestGetPlayers(t *testing.T) {
	request, _ := http.NewRequest(http.MethodGet, "/", nil)
	response := httptest.NewRecorder()
	PlayerServer(response, request)

	t.Run("Returns Pepper' Score", func(t *testing.T) {
		got := response.Body.String()
		want := "20"
		if got != want {
			t.Errorf("got %q want %q", got, want)
		}
	})
}
```

For this, 

- Use `http.NewRequest`to create a request, the first argument is the request’s method and the second is the request’s path. The `nil`argument refers to the request’s body, which we don’t need to set in this case.
- `net/http/httptest`has a *spy* already made for us called `ResonseRecorder`so can use that.

##### Write enough code to make it pass

From the DI chapter, touched on HTTP servers, with a `Greet`function. We learned that `net/http ResponseWriter`also implements `io`writer so we can use `fmt.Fprint`to send strings as HTTP responses.

```go
func PlayerServer(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "20")
}
```

#### Complete the scaffolding -- 

Want to write this up into an application -- this is important cuz -- 

- Have actual working software, don’t want to write tests for the sake of it -- it’s good to see the code in action.
- As we refactor our code, Likely we will change the structure of the program. Want to make sure this is reflected in our app too as part of the incremental approach.

In the `main.go`need -- 

```go
func main() {
    handler := http.HandlerFunc(PlayerServer)
    log.Fatal(http.ListenAndServe(":5000", handler))
}
```

`http.HandlerFunc()`-- Explored that the `Handler`interface is what we need to implement in order to make a server. Typically we do that by creating a `struct`and make it implement the interface by implementing its own `ServeHTTP`method.

The `HandlerFunc`type is an adapter to allow the use of ordinary functions as HTTP handlers, if `f`is a function with the appropraite signature, `HandlerFunc(f)`is a Handler that calls `f`.

From the documentation, see that the type `HandlerFunc`has already implented the `ServeHTTP`method.

```go
type HandlerFunc func(ResponseWriter, *Request)
```

By type casting our PlayerServer function with it, have now implemented the required handler.

And `ListenAndServe`takes a port to listen on a `Handler`-- if there is a problem the web server will return an error, an example of that might be the port already being listened to.

#### Factor a test first

```go
type StubPlayerStore struct {
	scores map[string]int
}

func (s *StubPlayerStore) GetPlayerScore(name string) int {
	score := s.scores[name]
	return score
}

func TestGetPlayers(t *testing.T) {
	store := StubPlayerStore{
		scores: map[string]int{
			"Pepper": 20,
			"Floyd":  10,
		},
	}
	server := &PlayerServer{&store}

	tests := []struct {
		name               string
		player             string
		expectedHTTPStatus int
		expectedScore      string
	}{
		{
			name:               "Returns Pepper's score",
			player:             "Pepper",
			expectedHTTPStatus: http.StatusOK,
			expectedScore:      "20",
		},
		{
			name:               "Returns Floyd's score",
			player:             "Floyd",
			expectedHTTPStatus: http.StatusOK,
			expectedScore:      "10",
		},
		{
			name:               "Returns 404 on missing players",
			player:             "Apollo",
			expectedHTTPStatus: http.StatusNotFound,
			expectedScore:      "0",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			request := newGetScoreRequest(tt.player)
			response := httptest.NewRecorder()
			server.ServeHTTP(response, request)

			assertStatus(t, response.Code, tt.expectedHTTPStatus)
			assertResponseBody(t, response.Body.String(), tt.expectedScore)
		})
	}
}
```

In the `server.go`file, re-factor to be an interface instead like:

```go
type PlayerStore interface {
	GetPlayerScore(name string) int
}

// PlayerServer is a HTTP interface for player information
type PlayerServer struct {
	store PlayerStore
}

func (p *PlayerServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	player := strings.TrimPrefix(r.URL.Path, "/players/")
	score := p.store.GetPlayerScore(player)
	if score == 0 {
		w.WriteHeader(http.StatusNotFound)
	}
	fmt.Fprint(w, score)
}
```

##### Write the test first 

```go
func TestStoreWins(t *testing.T) {
	store := StubPlayerStore{
		map[string]int{},
	}
	server := &PlayerServer{&store}
	t.Run("it returns accepted on POST", func(t *testing.T) {
		request, _ := http.NewRequest(http.MethodPost, "/players/Pepper", nil)
		response := httptest.NewRecorder()
		server.ServeHTTP(response, request)
		assertStatus(t, response.Code, http.StatusAccepted)
	})
}
```

Just check we get the correct status code if we hit the particular route with POST.

Write enough code to make it pass -- just like:

```go
func (p *PlayerServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		p.showScore(w, r)
	case http.MethodPost:
		p.processWin(w)
	}
}

func (p *PlayerServer) showScore(w http.ResponseWriter, r *http.Request) {
	player := strings.TrimPrefix(r.URL.Path, "/players/")
	score := p.store.GetPlayerScore(player)
	if score == 0 {
		w.WriteHeader(http.StatusNotFound)
	}
	fmt.Fprint(w, score)
}

func (p *PlayerServer) processWin(w http.ResponseWriter) {
	w.WriteHeader(http.StatusAccepted)
}
```

This makes the routing aspect of `ServeHTTP`a bit clearer and means our next interations on storing can just be inside `processWin`. Next, want to check that when we do our `POST /players/{name}`that our `playerStorer`is told to record the win.

```go
type StubPlayerStore struct {
	scores map[string]int
	winCalls []string
}

func (s *StubPlayerStore) GetPlayerScore(name string) int {
	score := s.scores[name]
	return score
}

func (s *StubPlayerStore) RecordWin(name string) {
	s.winCalls = append(s.winCalls, name)
}
```

