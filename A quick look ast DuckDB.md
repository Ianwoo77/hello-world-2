# A quick look ast DuckDB

- Create dbs
- Create a table
- Insert records into the table
- Retrieve records from the table
- Perform aggregation on the records

To create a DuckDB database, can use the `connect()`function of `duckdb`package. This creates a peristent database file named fore:

```python
conn = duckdb.connect("./data/my_duckdb_database.db")
# alternatively, can create an in-memory copy of the dbs by passing the `:memory:` to the connect()
conn = duckdb.connect(':memory:')
# or 
conn = duckdb.connect()
```

##### Loading Data into DuckDB

Once U have created the dbs, you can create a table by passing the `CREATE TABLE` SQL statement to the connection’s `execute()`method.

```python
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
conn.execute('show tables').df()

# insert a few rows into the table using Insert into statement
conn.execute('''
             INSERT INTO employees VALUES 
             (1, 'Alice', '30', 'HR'),
             (2, 'Bob', '25', 'IT'),
             (3, 'Charlie', '35', 'Marketing'),
             (4, 'David', '28', 'Engineering'),
             ''')
```

Added three rows to the `employees`table, to verify that the records are correctly inserted into the table, we will perform a query, which you will see daemon-strated in the next section.

#### Querying a Table

Now that the records are inserted into the table, we can retreive them by using the `SELECT`statement - 

```python
conn.execute('select * from employees').df()
```

##### Performing Aggregation -- 

A common operation performed on a table is *aggregation*, which involves summarizing data by grouping it based on one ore more columns and then applying functions such as `COUNT, SUM, AVERAGE, MIN`and `MAX`. Aggregation is essential for extracting insights, as it condenses large datasets into meangingful summaries, enabling more straightful insights, as it condenses large datasets into meaningful summaries, enabling more straightforward analysis 

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

### Defining a generic slice type

Could make a slice of any type?  Could use:

```go
type Bunch[E any] []E
b := Bunch[int]{1,2,3} 
```

```go
func TestGroupContainsWhatIsAppendedToIt(t *testing.T) {
	t.Parallel()
	got := group.Group[string]{}
	got = append(got, "hello")
	got = append(got, "world")
	want := group.Group[string]{"hello", "world"}
	if !slices.Equal(want, got) {
		t.Errorf("want %v, got %v", want, got)
	}
}
```

