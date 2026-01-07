# Updating Rows

`UPDATE`with `SET`and `WHERE`, assume U want to modify the return staus of a particular book.

```sql
D UPDATE Borrowings SET return_date= '2022-04-05', status='Returned' WHERE borrowing_id=3;
D select * from borrowings;
```

##### Deleting rows -- 

To delete a record, can use the `DELETE`statement together with the `WHERE`keyword to specify the condition. FORE, the following statement deletes the record from the `Borrowers`table where the borrower name is *Jane Doe*.

```sql
D DELETE FROM Borrowers WHERE name='Jane Doe';
D SELECT * from Borrowers;
```

There are other ways of deleting a record, a more common one is to delete a record baed on its `borrow_id`, like the following example shows -- 

```sql
 DELETE FROM Borrowers
WHERE name LIKE '%Jane%';
```

#### Querying Tables

So far U have seen how to perform queries with your tables using the `SELECT`staement - dive into the `SELECT`statement in more details and use it to perfrom more sophisicated queries.

```sql
D SELECT *
  FROM Authors
  WHERE (YEAR(CURRENT_DATE) - birth_year) > 100;
```

The `CURRENT_DATE`function returns the current date, the `YEAR`function extracts the year from the current date. So the above statement obtains the current year, subtracts the birth year of each author, and then returns all of the rows whose results are greater than 100.

```sql
SELECT *
FROM Borrowers
WHERE member_since >= '2022-01-01';
```

#### Joining Tables

Frequently, when extracting data from your dbs, you will need to fetch information from multiple tables. To do this, you need to perform *joins* -- which allow U to combine data from different tables based on  common columns or relationships between them -- DuckDB supports the following types of joins -- *left, right* ourter join, *inner* join, *full* join, and *cross* join.

##### Left Join

Use an example to demonstrate the use of left join, using the Books and `Authors`table, want to list the title of each book and its associated author.

```sql
D SELECT b.book_id, b.title, a.name
  FROM Books b LEFT JOIN Authors a ON b.author_id=a.author_id;
```

Means that all rows from the `Books`table will be included in the result set, and matching rows from the `Authors`table will be joined based on the condition `b.author_id=a.author_id`.

```sql
D SELECT a.name, b.book_id, b.title
  FROM Authors a
  LEFT JOIN Books b on a.author_id = b.author_id;
```

Observe that -- has 6 rows, the last row contains the author but since has no books listed the value of the `book_id`and `title`columns are both NULL.

##### Right join -- 

similar to the left, except that the right join includes all rows from the right table.

```sql
SELECT b.book_id, b.title, a.name
FROM Books b
RIGHT JOIN Authors a ON b.author_id = a.author_id;
```

For this, the rusult contains all the authors in the `Authors`table.

##### Inner Join

The inner join combines rows from two or more tables based on related columns betweens them, it retries only the rows where there is a match between the columns in the specified join condition.

```sql
SELECT b.book_id, b.title, a.name
FROM Books b
INNER JOIN Authors a ON b.author_id = a.author_id;
```

This query returns the `book_id`, `title`and author’s name for each book, ensuring that only books with corresponding authors are included in the result set.

##### Full Join

The result of a full join will include row from both tables, regardless of whether there is a match in the join condition, fore -- 

```sql
D SELECT b.book_id, b.title, a.name
  FROM Books b
  FULL JOIN Authors a on b.author_id=a.author_id;
```

A full join includes all rows from both tables in the result set, matching rows where they exist and including `NULL`values for unmatched rows.

##### Multiple table joins

Now tht Understand the use of the various joins, let’s use them to join multiple tables so that you can explore complex relationships and retrieve comprehensive data from your database

```sql
D SELECT b.title as book_title
  FROM books b
  INNER JOIN Borrowings br ON b.book_id = br.book_id
  INNER JOIN Borrowers bw ON br.borrower_id=bw.borrower_id
  WHERE bw.name='John Smith';
```

This SQL statement performs two inner joins, one between the Books and `Borrowings`tables based on the `book_id`column, and one between `Borrowings`and `Borrowers`based on the `borrower_id`column. Then can find all books that have been borroed and list the borrower’s name laong with the book titles -- 

```sql
SELECT bw.name AS borrower_name, b.title as book_title
  FROM Borrowings br
  INNER JOIN Books b ON br.book_id=b.book_id
  INNER JOIN Borrowers bw on br.borrower_id= bw.borrower_id;
```

This query is similar to the previous one, except that U also listed the borrower’s name, however, there is no filtering for a particular borrower this time around -- your result may not be in the same order as shown, to display results in the consistent order, and an `ORDER BY`statement to the query -- 

```sql
INNER JOIN Books b ON br.book_id=b.book_id
  INNER JOIN Borrowers bw on br.borrower_id= bw.borrower_id
  ORDER BY bw.name, b.title;
```

To include the author’s name along with the book title in the result, can further join the `Author`table with the `Books`table based on the `author_id`column -- 

```sql
SELECT bw.name AS borrower_name, b.title AS book_title, a.name AS author_name
FROM Borrowings br
INNER JOIN Books b ON br.book_id = b.book_id
INNER JOIN Borrowers bw ON br.borrower_id = bw.borrower_id
INNER JOIN Authors a ON b.author_id = a.author_id;
```

## Write the test first

Can accomplish this by extending our `StubPlayerStore`with a new `RecordWin`method and they spy on its invocations -- just like:

```go
type StubPlayerStore struct {
	scores   map[string]int
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

Need to extend our test to check the number of invocations for a start -- just like:

```go
func TestStoreWins(t *testing.T) {
	store := StubPlayerStore{
		map[string]int{},
		nil,
	}
	server := &PlayerServer{&store}
	t.Run("it records wins on POST", func(t *testing.T) {
		player := "Pepper"
		request, _ := http.NewRequest(http.MethodPost, "/players/Pepper", nil)
		response := httptest.NewRecorder()
		server.ServeHTTP(response, request)
		assertStatus(t, response.Code, http.StatusAccepted)
		if len(store.winCalls) != 1 {
			t.Fatalf("got %d calls to RecordWin want %d", len(store.winCalls), 1)
		}
		if store.winCalls[0] != player {
			t.Errorf("did not store correct winner got %q want %q", store.winCalls[0], player)
		}
	})
}
```

#### Write enough code to make it pass -- 

As we are only asserting the number of calls rather than the sepecifc values it makes our initial iteration a little smaller. Need to update the `PlayerServer`idea of what a `PlayerStore`is by changing the interface if we are going to be able to call `RecordWin`.

```go
type PlayerStore interface {
	GetPlayerScore(name string) int
	RecordWin(name string)
}

// PlayerServer is a HTTP interface for player information
type PlayerServer struct {
	store PlayerStore
}

func (p *PlayerServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	player := strings.TrimPrefix(r.URL.Path, "/players/")
	switch r.Method {
	case http.MethodGet:
		p.showScore(w, player)
	case http.MethodPost:
		p.processWin(w, player)
	}
}

func (p *PlayerServer) showScore(w http.ResponseWriter, player string) {
	score := p.store.GetPlayerScore(player)
	if score == 0 {
		w.WriteHeader(http.StatusNotFound)
	}
	fmt.Fprint(w, score)
}

func (p *PlayerServer) processWin(w http.ResponseWriter, player string) {
	p.store.RecordWin(player)
	w.WriteHeader(http.StatusAccepted)
}
```

For the test logic, just like:

```go
func TestStoreWins(t *testing.T) {
	store := StubPlayerStore{
		map[string]int{},
		nil,
	}
	server := &PlayerServer{&store}
	t.Run("it records wins on POST", func(t *testing.T) {
		player := "Pepper"
		request, _ := http.NewRequest(http.MethodPost,
			fmt.Sprintf("/players/%s", player), nil)
		response := httptest.NewRecorder()
		server.ServeHTTP(response, request)
		assertStatus(t, response.Code, http.StatusAccepted)
		if len(store.winCalls) != 1 {
			t.Fatalf("got %d calls to RecordWin want %d", len(store.winCalls), 1)
		}
		if store.winCalls[0] != player {
			t.Errorf("did not store correct winner got %q want %q", store.winCalls[0], player)
		}
	})
}
```

It looks like your test is cuz `PlayerServer`doesn’t yet hve a route defined to handle the POST req to `/players/{name}`-- the 404 `NOT Found`status status indicates that the server received the request but did not know what to do with it, which consequently meant your `store.RecordWin`method was never called.

And Have successfully moved from a hardcoded stub to a function in-memory imp -- validated both unit tests and integration tests -- this process demonstrates the power of TDD: U used a stub to define the server’s behavior, then swapped in a real storage engine without needing to change the server’s logic.

```go
func NewInMemoryPlayerStore() *InMemoryPlayerStore {
	return &InMemoryPlayerStore{map[string]int{}, sync.RWMutex{}}
}

type InMemoryPlayerStore struct {
	scores map[string]int
	
	// A mutex is used to sync read/write access to the map
	lock   sync.RWMutex
}

// RecordWin will record a player's win
func(i *InMemoryPlayerStore) RecordWin(name string) {
	i.lock.Lock()
	defer i.lock.Unlock()
	i.scores[name]++
}

func (i *InMemoryPlayerStore) GetPlayerScore(name string) int {
	i.lock.RLock()
	defer i.lock.RUnlock()
	return i.scores[name]
}

// then, test this
func TestRecordingWinsAndRetrievingThem(t *testing.T) {
	store := NewInMemoryPlayerStore()
	server := PlayerServer{store}
	player := "Pepper"

	server.ServeHTTP(httptest.NewRecorder(), newPostWinRequest(player))
	server.ServeHTTP(httptest.NewRecorder(), newPostWinRequest(player))
	server.ServeHTTP(httptest.NewRecorder(), newPostWinRequest(player))

	response := httptest.NewRecorder()
	server.ServeHTTP(response, newGetScoreRequest(player))
	assertStatus(t, response.Code, http.StatusOK)
	assertResponseBody(t, response.Body.String(), "3")
}
```

### Categorizing tests

The testing pramid is a model that groups tests into different categories -- Unit tests occupy base of the pyramid. Most tests should be unti tests -- they are just cheap to write, fast to execute, and highly deterministic. Usually, as we go further up the pyrmid, tests become more complex to write and lower to run.

A common technique is to be explicit about which kind of tests to run. Fore, depending on the project lifecycle stge, may want to run only unit tests or run all the tests in the project. Not categorizing tests means potentially wasting time and effort and losing accuracy about the scope of a test.

#### Building tags -- 

The most common way to classify tests is using build tags -- is a special comment at the beginning of a Go file, followed by an empty line -- 

```go
//go:build foo

package bar
```

In most common way to classify tests is using build tags, a build tag is a special comment at the beginning of a Go file, followed by an empty line -- 

```go
//go:build foo

package bar
```

Build tags are used for two primary use cases, first, an use a build tg as a conditional option to build an application, fore, if want a source file to be included only if `cgo`is enable -- *go package call `C`code*. Can add like:

```go
//go:build cgo
```

Second, if want to categorize a test as an integration test, can add a specific build tags, such as `integration`. Fore, `db_test.go`file just like:

```go
//go:build integration

package db

func TestInsert(t *testing.T) {
    //...
}
```

Here, add the `integration`build tg to categorize that his file contains integration tests. The benefit of using build tag is that we can select which kinds of tests to execute. Fore, assume a package contains two test files - `db_test.go`and `contract_test.go`file wihout build tag.

If run `go test`inside this package without any options -- will run only the test files **without** build tags

```sh
go test -v .
# === RUN TestContract
```

However, if provide the *integration* tag, running `go test`will also include the `db_test.go`file -- 

```sh
go test --tags=integration -v .
# === RUN TestInsert
# ---
# === RUN TestContact
# --- 
```

A possible way is to add a negation tag on the unit test files -- fore, using `!integration`means we want to include the test file only if the `integration`flag is not enabled -- `contact_tag.go`-- like:

```go
//go:build !integration

package db

//... func...
```

Want to include the test file only if the `integration`flag is not enabled.

| Command                           | Result for this file | Why?                                                         |
| --------------------------------- | -------------------- | ------------------------------------------------------------ |
| `go test ./...`                   | Included             | By default, the `integration` tag is not set, so `!integration` is true. |
| `go test -tags=integration ./...` | Excluded             | The tag is explicitly set, making `!integration` false.      |

##### Organizing Positive vs. Negative Tags -- 

Usually, developers pair the file above with a sibling file that handles the actual integration logic. This keeps your dbs logic clean and separated. Fore:

- `contract_test.go`-- contains `//go:build !integration`-- used for mock-based tests
- `integration_test.go`-- Contains `//go:build integration`-- used for real dbs connections.

The `//go:build`line must appear before the `package`clause and must be separated by a blank line.

#### Environment variables

Build tags have one main drawback, the absence of signals that a test has been ignored. In the first example, when executed `go test`without build flags -- showed only the tests that we executed. Fore, can implement the `TestInsert`integration test by checking a specific environment variable and potentially skipping the test -- 

```go
func TestInsert(t *testing.T) {
    if os.Getenv("INTEGRATION")!="true" {
        t.Skip("skipping Integration test")
    }
    // ...
}
```

#### Short mode

Another approach to categorize tests is related to their speed, may have to dissociate short-running tests from long-running tests. Suppose have a set of unit tests, one of which is slow -- would like to categorize the slow test wo don’t have to run it every time -- short mode allows make the distinction -- 

```go
func TestLongRunning(t *testing.T) {
    if testing.Short() {
        t.Skip("...")
    }
}
```

Using `testing.Short`, can retrieve whether short mode was enabled while running the test -- then use the `skip`the test -- use the `skip`-- 

```sh
go test -short -v .
# === Run TestLongRunning
# --- Skip TestLongRunning
```

For this, `TestLongRunning`is explicitly skipped when the tests are executed, Note that unlike build tags, this option works per test, not per file.

In summary, categorizing tests is a best practice for a successful testing strategy.

- Using build tags at the test file level
- Using environment variables to mark a specific test
- Based on the test pace using short mode.

Can also combine approaches, fore, using build tags or environment variable to classify a test and short mode if our project contains long-running tests.

##### Fuzz testing

Fuzz testing works by throwing everything at the wall and seeing what stricks. Since overruns are classic example of the kind of bug that bug that busy programmers can easily overlook -- like:

```go
results := SearchProuducts(productID)
return results[0].Name // panics if there are no results.
```

This code might run perfectly well in production for months or even years, and then suddenly break when someone searches for a product that doesn’t exist.

```go
// fore, have a hide bug
func fragile(input string) {
    if input == "secret code" {
        panic("discover Bug！")
    }
    fmt.Println("secure:", input)
}

func FuzzFragile(f *testing.F) {
    // (Seed Corpus)
    // not necessary, but useful
    f.Add("hello")
    f.Add("password")

    // 2. run
    f.Fuzz(func(t *testing.T, input string) {
        fragile(input)
    })
}
```

```sh
go test -fuzz=FuzzFragile
```

