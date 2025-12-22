# DuckdB Inserting a Record

Can insert a few rows into the table using the `INSERT INTO`statement -- like:

```python
conn = duckdb.connect("./data/my_duckdb_database.db")

conn.execute(
    """
             create table employees (
                 id INTEGER primary key,
                 name VARCHAR,
                 age INTEGER,
                 department VARCHAR
             )
             """
)

conn.execute('''
             INSERT INTO employees VALUES 
             (1, 'Alice', '30', 'HR'),
             (2, 'Bob', '25', 'IT'),
             (3, 'Charlie', '35', 'Marketing'),
             (4, 'David', '28', 'Engineering'),
             ''')

# executing query:
conn.execute('show tables').df()
```

##### Performing Aggregation

A common operation performed on a table is *agregation*, which involves summarizing data by grouping it based on one or more columns.

```python
conn.execute('''
             SELECT
            department,
            AVG(age) AS average_age
            FROM
            employees
            GROUP BY
            department
             ''').df()
```

Can calculate the average of age of employees in the company using the `AVG()`

```python
conn.execute('''
             SELECT AVG(age) as average_age from employees
             ''').df()
```

If to find the oldest employee in each department, can use the `MAX`function in SQL -- 

```python
conn.execute('''
             Select department, max(age) as oldest_age 
             from employees
             GROUP BY department
             ''').df()
```

#### Joining Tables -- 

In addition to working with single tables, DuckDB enables U to perform joins on multiple tables - just like:

```python
conn = duckdb.connect()
# create first table - orders
conn.execute(
    """
CREATE TABLE orders (
order_id INTEGER,
customer_id INTEGER,
amount FLOAT)
"""
)
# add some records to the orders table
conn.execute(
    """
INSERT INTO orders
VALUES (1, 1, 100.0),
(2, 2, 200.0),
(3, 1, 150.0)
"""
)
# create second table - customers
conn.execute(
    """
CREATE TABLE customers (
customer_id INTEGER,
name VARCHAR)
"""
)
conn.execute(
    """
INSERT INTO customers
VALUES (1, 'Alice'),
(2, 'Bob')
"""
)
# display that like:
display(conn.execute('''
    SELECT * FROM orders
    ''').df()
)
```

Want a list of amount spent by each customer -- can achieve this by joining the `orders`and `customers`tables based on the `customer_id`field in each table.

```python
conn.execute('''
             SELECT
             customers.customer_id,
             customers.name,
             orders.amount
             FROM
             orders
             JOIN
             customers
             ON
             orders.customer_id = customers.customer_id
             ORDER by
             customers.customer_id
             ''').df()
```

And suppose U now want to know the total amount spent by each customer -- can achieve this by aggregating the amount spent using the `SUM`function in SQL -- 

```python
conn.execute('''
             SELECT
             customers.customer_id,
             customers.name,
             SUM(orders.amount) AS total_spent
             FROM 
             orders
             JOIN
             customers
             ON
             orders.customer_id = customers.customer_id
             GROUP BY
             customers.customer_id,
             customers.name
             ORDER BY
             customers.customer_id
             ''').df()
```

The *Non-Aggregated* rule -- In STD SQL, every column listed in your `SELECT`statement must fall into of two categories - `SUM(), COUNT(), AVG()`-- it is part of the `GROUP BY`clause. Cuz the `customers.name`is splitting in your `SELECT`clist but isn’t wrapped in an aggregated function like `MAX()`or `MIN()`-- SQL queries it to be in the `GROUP BY`-- if leave it out, most SQL eneinges will throw.

#### Reading data from pandas

DuckDB can work directly with the pandas DF that you already have in memory -- 

```python
employees = pd.DataFrame(
    {
        "employee_id": [1, 2, 3, 4],
        "name": ["Alice", "Bob", "Charlie", "David"],
        "age": [30, 35, 28, 40],
        "department": ["HR", "Engineering", "Marketing", "Engineering"],
    }
)
sales = pd.DataFrame(
    {
        "sale_id": [101, 102, 103, 104, 105],
        "employee_id": [1, 2, 1, 3, 4],
        "sale_amount": [200, 500, 150, 300, 700],
        "sale_date": [
            "2023-01-01",
            "2023-01-03",
            "2023-01-04",
            "2023-01-05",
            "2023-01-07",
        ],
    }
)
```

Can join the two DF and perform some aggregations -- Most importantly, in DuckDB you simply refer to the DataFrames by their names.

Can use Pandas Equivalent like -- 

```python
merged_df = employees.merge(sales, on='employee_id', how='left')
result = merged_df.groupby('department')['sale_amount'].agg(
    total_sales='sum',
    average_sales_per_employee='mean'
).reset_index()
result
```

Again notes - `join()`-- in pandas, `employees.join(sales)`expects the `emloyee_id`to be the *index* of the dataframes. `merge()`is generally preferred cuz U can specify columns.

##### Why DuckDB is more Efficient -- 

When working with CSV files, fore, it does not need to load the entire csv file into memory before it can process it. Rather, DuckDB can reand and process data from the file on the fly.

And there are two aspects tht will examine in this - 

- Speed of execution of DuckDB
- memory usge of DuckDB

## Context

Software often kicks off long-running, resoruce-intensive processes -- if the action the caused this gets cancelled for fails for some reason you need to stop this processes in a consistent way through your app.

In this chapter, use the package `context`to help us manage long-running processes. Just like:

```go
func Server(store Store) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, store.Fetch())
    }
}
```

For this, the function `Server`takes a `Store`and returns us a `http.HandlerFunc`, `Store`is defined as -- 

```go
type Store interface {
    Fetch() string
}
```

Then can have a corresponding stub for `Store`which use in a test just like --

```go
type StubStore struct {
    response string
}
func (s *StubStore) Fetch() string {
    return s.response
}

func TestServer (t *testing.T) {
    data := "hello world"
    srv := Server(&StubStore{data})
    request := httptest.NewRequest(http.MethodGet, "/", nil)
    response := httptest.NeRecorder()
    srv.ServeHTTP(response, request)
    if response.Body().String != data {
        t.Errorf(...)
    }
}
```

Add a new test where we cancel the request before 100ms and check the store to see if it gets cancelled -- 

Will need to adjust our spy so it tkes some time to return `data`and a way of knowning it has been told to cancel. Will also rename it to `SpyStore`as we are now observing the way it is called. It will have to add `Cancel`as a method to implement the `Store`interface.

```go
type SpyStore struct {
    response string
    cancelled bool
}
func (s *SpyStore) Fetch() string {
    time.Sleep(100* time.Millisecond)
    return s.response
}
func (s *SpyStore) Cancel() {
    s.cancelled = true
}
```

```go
t.Run("tells store to cancel work if request is cancelled", func(t *testing.T) {
    data := "hello, world"
    store := &SpyStore{response: data}
    svr := Server(store)
    request := httptest.NewRequest(http.MethodGet, "/", nil)

    cancellingCtx, cancel := context.WithCancel(request.Context())
    time.AfterFunc(5*time.Millisecond, cancel)
    request = request.WithContext(cancellingCtx)

    response := httptest.NewRecorder()

    svr.ServeHTTP(response, request)

    if !store.cancelled {
        t.Error("store was not told to cancel")
    }
})
```

##### Write the test first - 

Need to test that we do not write any kind of response on the error case -- `context`has a method `Done()`which returns a channel which gets sent a signal when the context is *done* or *cancelled* -- we want to listen to that signal and call `store.Cancel`if we get it but we want to ignore it if our `Store`manages to `fetch`bofore it.

To manage this we run `Fetch()`in a goroutine and it will write the result into a new channel `data`. Can then use `select`to effectively race to the two async processes and then we either write a resp or `Cancel`.

```go
type SpyStore struct {
	response  string
	cancelled bool
	t         *testing.T
}

func (s *SpyStore) Fetch() string{
	time.Sleep(100*time.Millisecond)
	return s.response
}

// Cancel will record the call
func (s *SpyStore) Cancel() {
	s.cancelled= true
}

func (s *SpyStore) assertWasCancelled() {
	s.t.Helper()
	if !s.cancelled {
		s.t.Errorf("store was not cancelled")
	}
}

func (s *SpyStore) assertWasNotCancelled() {
	s.t.Helper()
	if s.cancelled {
		s.t.Errorf("store was told to cancel")
	}
}
```

Then just re-write the test file like:

```go
func TestServer(t *testing.T) {
	data := "hello, world"

	t.Run("returns data from store", func(t *testing.T) {
		store := &SpyStore{response: data, t: t}
		srv := Server(store)
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		res := httptest.NewRecorder()
		srv.ServeHTTP(res, req)

		if res.Body.String() != data {
			t.Errorf("got %q, want %q", res.Body.String(), data)
		}
		store.assertWasNotCancelled()
	})

	t.Run("tells store to cancel work if request is cancelled", func(t *testing.T) {
		store := &SpyStore{response: data, t: t}
		srv := Server(store)
		req := httptest.NewRequest(http.MethodGet, "/", nil)
		cancellingCtx, cancel := context.WithCancel(req.Context())
		time.AfterFunc(5*time.Millisecond, cancel)
		req = req.WithContext(cancellingCtx)
		res := httptest.NewRecorder()
		srv.ServeHTTP(res, req)
		store.assertWasCancelled()
	})
}
```

##### The Ripple effect of Context --

As the Go documentation states, Context forms a `tree`, when a web server receives a request, it creates a root Context -- 

- If the user closes the browser -- The web server automatically tirggers the cancellation signal for that root Context.
- Automatic Propagation -- If your `Store`receives this Context and passes it down to a dbs driver, the driver will immediately receive the signal and stop the ongoing query.
- No manual Intervention -- Don’t need to write `Store.StopAllDependencies()`-- Once the root context is canceled, and child Contexts derived from it are canceled simultaneously.

##### An improved architecture Approach -- 

Instead of having the web server worry about how to cancel the Store -- follow the Go convention and modify the `Store`inteface -- 

```go
// BEFORE (manual control)
type Store interface {
    Save(data string)
    Cancel()
}

// AFTER
type Store interface {
    // Pass context as the first argument
    Save(ctx context.Context, data string) error
}
```

```go
type SpyStore struct {
	response string
}

func (s *SpyStore) Fetch(ctx context.Context) (string, error) {
	data := make(chan string, 1)
	go func() {
		var result string
		for _, c := range s.response {
			select {
			case <-ctx.Done():
				log.Println("spy store got cancelled")
				return
			default:
				time.Sleep(10 * time.Millisecond)
				result += string(c)
			}
		}
		data <- result
	}()

	select {
	case <-ctx.Done():
		return "", ctx.Err()
	case res := <-data:
		return res, nil
	}
}

// SpyResponseWriter checks whether a response has been written.
type SpyResponseWriter struct {
	written bool
}

// Header will mark written to true.
func (s *SpyResponseWriter) Header() http.Header {
	s.written = true
	return nil
}

// Write will mark written to true.
func (s *SpyResponseWriter) Write([]byte) (int, error) {
	s.written = true
	return 0, errors.New("not implemented")
}

// WriteHeader will mark written to true.
func (s *SpyResponseWriter) WriteHeader(statusCode int) {
	s.written = true
}
```

