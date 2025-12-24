# Importing Data into DuckDB

Review -- 

```python
conn = duckdb.connect()
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

Same effect using Pandas like:

```python
merged_df = employees.merge(sales, on='employee_id', how='left')
result = merged_df.groupby('department')['sale_amount'].agg(
    total_sales='sum', # key is column name, value is aggregation function
    average_sales_per_employee='mean'
).reset_index()
```

#### Memory Usage

Demonstrates the significant efficiency of DuckDB compared to pandas when handing large datasets, specifically focusing on memroy consumption.

| Library | Memory Used        | Behavior                                                     |
| ------- | ------------------ | ------------------------------------------------------------ |
| pandas  | ~4,200 MB (4.2 GB) | *Loads the entire dataset into RAM* before any processing can occur. |
| DuckDB  | ~280 MB            | Processes data using *streaming/chunking*; it doesn't need the whole file in memory to run a query. |

### Importing Data into DuckDB

If U wish to create a Duckdb that is persisted on storage, set the *database* argument to the name of a dbs fore

```python
import duckdb
conn = duckdb.connect() # using memory
# if want to create a databse is persisted on storage, set the `database` 
# argument to the name of a database.
conn = duckdb.connect(database='./data/mydb.duckdb', read_only=False)
```

If create an in-memory dbs and set the `read-only`to `True`then the dbs becomes immutable. And you will not be able to attach any tables to it. For the non-in-memory dbs, U can set the `read_only`to `True`only if the dbs file already exists.

#### Loading from different data sources and formats

CSV, Parquet, Excel, and SQL dbs

##### Working with CSV files

The first method will use to load a csv file into a DuckDB dbs is the SQL query method -- use the `CREATE TABLE`statement-- Cuz the CSV file is huge, may want to load only a portion of it -- just like:

```python
conn.execute('''
             DROP TABLE IF EXISTS flights;
             CREATE TABLE flights
             as
             FROM read_csv_auto('../data/flights.csv')
             LIMIT 2000
             ''').df()
```

And to view the content of the flights table, use the `SELECT`statement with the `execute()`method like:

```python
display(conn.execute("SELECT * FROM flights").df())
```

Another way to load a CSV file is by manually creating a table and then using the `COPY`statement to load the data into the table just like:

```python
conn.execute(
    '''
    CREATE TABLE airports(
    IATA_CODE VARCHAR, AIRPORT VARCHAR, CITY VARCHAR,
    STATE VARCHAR, COUNTRY VARCHAR, LATITUDE VARCHAR,
    LONGITUDE VARCHAR);
    
    COPY airports FROM '../data/airports.csv' (AUTO_DETECT TRUE);
    '''
)
display(conn.execute('select * from airports').df())
```

This method is often used when U want to have more control over the data loading process. Fore, might want to define specific data types or constraints for each column in the table.

```python
conn.execute('''
             DROP TABLE IF EXISTS airports;
             CREATE TABLE airports
             AS
             FROM
             read_csv('../data/airports.csv',
                names=['IATA_CODE', 'AIRPORT', 'CITY',
                'STATE', 'COUNTRY', 'LATITUDE',
                'LONGITUDE'])
             ''')
```

Note that if want to check the total number of columns created for a table, you can use the `information_schema.columns`table that contains metadata about columns in all tables.

```python
result = conn.execute('''
                      SELECT COUNT(*) as column_count
                      FROM information_schema.columns
                      WHERE table_name = 'airports';
                      ''').fetchall() # [(7,)] 7 columns
```

And if want to treat all the columns in your CSV file as string types -- Can specify the `all_varchar`parameter in `read_csv`function and set it to `true`like:

```python
conn.execute('''
             DROP TABLE IF EXISTS airports;
             CREATE TABLE airports
             AS
             FROM read_csv('../data/airports.csv', all_varchar=true)
             ''')
display(conn.execute('SHOW TABLES').df())
```

##### Loading using the `register()`method

Another way to load a CSV file into DuckDB is to use the `register()`method of the connection object. The `register()`enables U to load a CSV file or other external data source as an in-memory virtual table without needing to explicitly create or copy data in a DuckDB table, Can:

```python
arilines = conn.execute('''
                        select * from
                        read_csv('../data/airlines.csv',
                        Header=True,
                        Columns = {'IATA_CODE': 'VARCHAR', 'AIRLINE': 'VARCHAR'})
                        ''').df()
```

Once the DF loaded, need to use the `register()`method to associate the table with the DuckDB dbs -- 

```python
conn.register('airlines', arilines)
display(conn.execute('show tables').df())

# also can use pandas directly
import pandas as pd
df_airlines = pd.read_csv('../data/airlines.csv')
conn.register('airlines', df_airlines)
```

##### Exporting a tble to CSV 

Can use the `COPY`statement just like:

```python
conn.execute('''
             COPY
             (SELECT IATA_CODE, LATITUDE, LONGITUDE FROM airports)
             TO
             './data/airports_location.csv' WITH (HEADER 1, DELIMITER ',');
             ''')
```

And if want to copy part of a file to another without loading any data into DuckDB, can read directly from a file and specify the number of rows to copy -- 

```python
conn.execute('''
             COPY
             (SELECT IATA_CODE, LATITUDE, LONGITUDE FROM airports LIMIT 10)
             TO
             './data/airports_location.csv' WITH (HEADER 1, DELIMITER ',');
             ''') # just add LIMIT in the SELECT child query
# when done with connection, close it.
conn.close()
```

## How the Context Cancellation works in Go

The interaction between the `Server`and the `SpyStore`relies on the `select`statement - The key code is just like:

```go
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

func Server(store Store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		data, err := store.Fetch(r.Context())
		if err != nil {
			return
		}
		fmt.Fprint(w, data)
	}
}
```

In the test file when the `time.AfterFunc(5*time.Millisecond, cancel)`trigllers `cancel()`, 

```go
t.Run("tells store to cancel work if request is cancelled", func(t *testing.T) {
    store := &SpyStore{response: data}
    srv := Server(store)
    req := httptest.NewRequest(http.MethodGet, "/", nil)
    cancellingCtx, cancel := context.WithCancel(req.Context())
    time.AfterFunc(5*time.Millisecond, cancel)
    req = req.WithContext(cancellingCtx)
    res := &SpyResponseWriter{}
    srv.ServeHTTP(res, req)
    if res.written {
        t.Error("a response should not have been written")
    }
})
```

##### The `http.ResponseWriter`interface - 

To satisfy this interface -- Must implement these 3 methods -- 

| **Method**          | **Signature**                 | **Purpose**                                                  |
| ------------------- | ----------------------------- | ------------------------------------------------------------ |
| **`Header()`**      | `Header() http.Header`        | Returns the map of headers that will be sent.                |
| **`Write()`**       | `Write([]byte) (int, error)`  | Writes the data to the connection as part of the HTTP body.  |
| **`WriteHeader()`** | `WriteHeader(statusCode int)` | Sends an HTTP response header with the provided status code. |

##### The `http.Request`struct -- 

Unlike the `ResponseWriter`, `Request`is just a concrete struct - access its exported fields or use its methods to inspect the incoming call. So for the `ResponseWriter`just like:

```go
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

### Roman Numerals

As this book stresses, a key skill for software developers is to try and identify *thin vertical slices* of useful functionality and then *iterating*.

Know it feels weird just to hard-code the result but with TDD we want to stay out of *red* for as long as possible. May feel like we haven’t accoplished much but we’ve defined our API and got a test capturing one of our rules.

```go
func TestRomanNumerals(t *testing.T) {
	cases := []struct {
		Description string
		Arabic      int
		Want        string
	}{
		{"1 gets converted to I", 1, "I"},
		{"2 gets converted to II", 2, "II"},
	}

	for _, test := range cases {
		t.Run(test.Description, func(t *testing.T){
			got := ConvertToRoman(test.Arabic)
			if got != test.Want {
				t.Errorf("got %q, want %q", got, want)
			}
		})
		
		t.Run("2 gets converted to II", func(t *testing.T) {
			got := ConvertToRoman(2)
			want := "II"
			if got != want {
				t.Errorf("got %q, want %q", got, want)
			}
		})
	}
}

// Write enough code to make it pass
func ConvertToRoman(arabic int) string {
	if arabic == 2 {
		return "II"
	}
	return "I"
}
```

##### Refactor

Have some repetition in our tests, when are tesing sth which feels like it’s matter of given input X, expect Y, you should probably use table based tests.

```go
func TestRomanNumerals(t *testing.T) {
	// ...
	for _, test := range cases {
		t.Run(test.Description, func(t *testing.T) {
			got := ConvertToRoman(test.Arabic)
			if got != test.Want {
				t.Errorf("got %q, want %q", got, test.Want)
			}
		})
	}
}
```

