# Exporting a table to CSV

```python
conn = duckdb.connect(database='./data/mydb.duckdb', read_only=False)
conn.execute('''
             DROP TABLE IF EXISTS flights;
             CREATE TABLE flights
             as
             FROM read_csv_auto('../data/flights.csv')
             LIMIT 2000
             ''').df()
# create using fileds types
conn.execute(
    '''
    CREATE TABLE airports(
    IATA_CODE VARCHAR, AIRPORT VARCHAR, CITY VARCHAR,
    STATE VARCHAR, COUNTRY VARCHAR, LATITUDE VARCHAR,
    LONGITUDE VARCHAR);
    
    COPY airports FROM '../data/airports.csv' (AUTO_DETECT TRUE);
    '''
)
# or can use the statements like:
conn.execute(
    '''
    CREATE TABLE airports(
    IATA_CODE VARCHAR, AIRPORT VARCHAR, CITY VARCHAR,
    STATE VARCHAR, COUNTRY VARCHAR, LATITUDE VARCHAR,
    LONGITUDE VARCHAR);
    
    COPY airports FROM '../data/airports.csv' (AUTO_DETECT TRUE);
    '''
)

result = conn.execute('''
                      SELECT COUNT(*) as column_count
                      FROM information_schema.columns
                      WHERE table_name = 'airports';
                      ''').fetchall() # list of tuple

# or can use 
conn.execute('''
             DROP TABLE IF EXISTS airports;
             CREATE TABLE airports
             AS
             FROM read_csv('../data/airports.csv', all_varchar=true)
             ''')# all fields are strings

# using read_csv() methods
airilines = conn.execute('''
                        select * from
                        read_csv('../data/airlines.csv',
                        Header=True,
                        Columns = {'IATA_CODE': 'VARCHAR', 'AIRLINE': 'VARCHAR'})
                        ''').df()

# using register() to add the table to dbs
conn.register('airlines', arilines)
display(conn.execute('show tables').df())

# using pandas to do this:
import pandas as pd
df_airlines = pd.read_csv('../data/airlines.csv')
conn.register('airlines', df_airlines) # the same output 
```

#### Exporting a table to CSV

```python
conn.execute('''
             COPY
             (SELECT IATA_CODE, LATITUDE, LONGITUDE FROM airports)
             TO
             './data/airports_location.csv' WITH (HEADER 1, DELIMITER ',');
             ''')
```

Using the `COPY`statement - the `HEADER 1`arg indicates that the csv should include a header row. This code snippet creates a CSV file named `ariports_location.csv`. And if want to copy a part of a file to another file without loading any data into DuckDB, read the data directly from a file and specify the number of rows to copy -- 

```python
conn.execute(
    """
             COPY
             (SELECT IATA_CODE, LATITUDE, LONGITUDE
             FROM '../data/airports.csv'
             LIMIT 10)
             TO
             './data/airports_location_10.csv' with (HEADER 1, DELIMITER ',')
             """
)
```

For this, just execute the `SELECT ... from ...csv LIMIT 10` statement to a new csv file, not for database tables. So this statement copy 3 columns from the first 10 rows of the csv file to a new file named ..._10.csv.

### Woring with Parquet Files

Another file format that is gaining popularity among data scientists is *Parquet* -- Or Apache Parquet -- is a file format designed to support fast data processing for complex data. It is an open source format under the Apache Hadoop license. Fore when a CSV file is loaded into a DataFrame, each row is loaded one at a time, and each row contains 3 different data types.

Parquet, however, stores your data using column-based storage, ech column of data is organized as a column of a specific data type. In short, when store your data in column-based storge, your file will be more lightweight, since all similar data types are grouped together and you can apply compression to each column, more importantly, using column-based storage makes it really efficient to extract specific columns.

1. Structurual Efficiency -- Parquet organizes data by columns
2. Superios compression -- Cuz each column contains data of the same type, the system can apply hightly efficient, type-speicifc compression algorithms.
3. Optimized for anaytics -- (OLAP) -- Designed for Online Analytical processing (OLAP) workloads. Where users often need to query specific columns rather than entire records.
   - Speed -- only red the columns you need, reduces I/O
   - Compatibitlity -- makes it an ideal comanion for analystical engines like DuckDB.

```sh
pip install fastparquet
```

Can now read the CSV file as a pandas DF and then save it as a Parquet file -- just like:

```python
import pandas as pd
df_airlines = pd.read_csv('../data/airports.csv')
df_airlines.to_parquet('./data/airports.parquet', engine='fastparquet')
```

To load a Parquet file into a DuckDB dbs, use the `read_parquet()`function like -- 

```python
conn = duckdb.connect()
conn.execute('''
             CREATE TABLE airports
             as
             SELECT * FROM read_parquet('./data/airports.parquet')
             LIMIT 100
             ''')
display(conn.execute('select * from airports').df())
```

And if want to load last 100 rows, can use the `ORDER BY 1 DESC` statement to sort the rows. **1** just refers to the first column in your `SELECT`statement.

To *load* a Parquet file into an existing table in DuckDB dbs, use the COPY FROM statement - just like:

```python
conn.execute('''
             COPY airports from './data/airports.parquet' (FORMAT parquet)
             ''')
```

Exporting Parquet files -- to export a table in DuckDB to a Parquet file using the following query -- just like:

```python
conn.execute('''
             COPY
             (SELECT * FROM airports LIMIT 100)
             TO
             './data/airports_100.parquet' (FORMAT PARQUET)
             ''')
```

## Write enough code to make it pass

```go
func TestRomanNumerals(t *testing.T) {
	cases := []struct {
		Description string
		Arabic      int
		Want        string
	}{
		{"1 gets converted to I", 1, "I"},
		{"2 gets converted to II", 2, "II"},
		{"3 gets converted to III", 3, "III"},
		{"4 gets converted to IV (can't repeat more than 3 times)",
			4, "IV"},
	}

	for _, test := range cases {
		t.Run(test.Description, func(t *testing.T) {
			got := ConvertToRoman(test.Arabic)
			if got != test.Want {
				t.Errorf("got %q, want %q", got, test.Want)
			}
		})
	}
}

func ConvertToRoman(arabic int) string {
	var result strings.Builder
	for i := arabic; i > 0; i-- {
		if i == 4 {
			result.WriteString("IV")
			break
		}
		result.WriteString("I")
	}
	return result.String()
}
```

##### Refactor -- 

Repetition in loops like this are usually sign of an abstraction waiting to be called out.

```go
func ConvertToRoman(arabic int) string {
	var result strings.Builder
	for arabic > 0 {
		switch {
		case arabic > 4:
			result.WriteString("V")
			arabic -= 5
		case arabic > 3:
			result.WriteString("IV")
			arabic -= 4
		default:
			result.WriteString("I")
			arabic--
		}
	}
	return result.String()
}
```

Fore, if you have done OO programming, you will know that you should view switch statements with a bit of suspicion, Usually you are capturing a concept or data inside some imperative code when in fact it could be captured in a class structure instead -- Go isn’t strictly OO but that doesn’t mean that we ignore the lessons OO offers entiresly -- 

1. Data-Driven Design vs. Hard-coded Logic -- Current code likely contains numerious repetitive statements such as `case 10: return "X"`..
2. Avoiding Excessive Switch statements -- In OO -- a long or complex `switch`is often code smell suggesting that logic should be extracted into polymorphism or a structured data set.

Using the data-dirve -- 

```go
type RomanNumeral struct {
    Value  int
    Symbol string
}

var RomanNumerals = []RomanNumeral{
    {1000, "M"},
    {900, "CM"},
    {500, "D"},
    {400, "CD"},
    {100, "C"},
    {90, "XC"},
    {50, "L"},
    {40, "XL"},
    {10, "X"},
    {9, "IX"},
    {5, "V"},
    {4, "IV"},
    {1, "I"},
}

func TestRomanNumerals(t *testing.T) {
	cases := []struct {
		Arabic int
		Roman  string
	}{
		{Arabic: 1, Roman: "I"},
		{Arabic: 2, Roman: "II"},
		{Arabic: 3, Roman: "III"},
		{Arabic: 4, Roman: "IV"},
		{Arabic: 5, Roman: "V"},
		{Arabic: 6, Roman: "VI"},
		{Arabic: 7, Roman: "VII"},
		{Arabic: 8, Roman: "VIII"},
		{Arabic: 9, Roman: "IX"},
		{Arabic: 10, Roman: "X"},
		{Arabic: 14, Roman: "XIV"},
		{Arabic: 18, Roman: "XVIII"},
		{Arabic: 20, Roman: "XX"},
		{Arabic: 39, Roman: "XXXIX"},
		{Arabic: 40, Roman: "XL"},
		{Arabic: 47, Roman: "XLVII"},
		{Arabic: 49, Roman: "XLIX"},
		{Arabic: 50, Roman: "L"},
		{Arabic: 100, Roman: "C"},
		{Arabic: 90, Roman: "XC"},
		{Arabic: 400, Roman: "CD"},
		{Arabic: 500, Roman: "D"},
		{Arabic: 900, Roman: "CM"},
		{Arabic: 1000, Roman: "M"},
		{Arabic: 1984, Roman: "MCMLXXXIV"},
		{Arabic: 3999, Roman: "MMMCMXCIX"},
		{Arabic: 2014, Roman: "MMXIV"},
		{Arabic: 1006, Roman: "MVI"},
		{Arabic: 798, Roman: "DCCXCVIII"},
	}

	for _, test := range cases {
		t.Run(fmt.Sprintf("%d gets converted to '%s", test.Arabic, test.Roman), func(t *testing.T) {
			got := ConvertToRoman(test.Arabic)
			if got != test.Roman {
				t.Errorf("got %q, want %q", got, test.Roman)
			}
		})
	}
}
```

##### Refactor -- 

Not done yet -- next, going to write a function that coverts from a Roman Numeral to an `int`.

### Reading files

Going to learn how to read some files, get some data out of them, do sth useful. Pretend you are working with your friend to create some blog software - the idea is an author will write their ports in mardkown, with some metadata at the top of the file -- the web server will read a folder to create some posts, and then a separate `NewHandler`function will use those `post`s As a datasource for the blog’s webserver.

Asked to create a package that converts a given folder of blog post files into a collection of `post`s.

```go
type Post struct {
	Title       string
	Description string
	Tags        []string
	Body        string
}

// Constants -- these defines the prefix for each line of metadata
const (
	titleSeparator       = "Title: "
	descriptionSeparator = "Description: "
	tagsSeparator        = "Tags: "
)

func newPost(postBody io.Reader) (Post, error) {
	scanner := bufio.NewScanner(postBody)
	readMetaLine := func(tagName string) string {
		scanner.Scan()
		return strings.TrimPrefix(scanner.Text(), tagName)
	}
	return Post{
		Title:       readMetaLine(titleSeparator),
		Description: readMetaLine(descriptionSeparator),
		Tags:        strings.Split(readMetaLine(tagsSeparator), ", "),
		Body:        readBody(scanner),
	}, nil
}

func readBody(scanner *bufio.Scanner) string {
	scanner.Scan()
	buf := bytes.Buffer{}
	for scanner.Scan() {
		fmt.Fprintln(&buf, scanner.Text()) // write every line to the buffer
	}
	return strings.TrimSuffix(buf.String(), "\n")
}
```

##### Use of `bufio.Scanner`-- 

The function takes the `io.Reader`and returns a populted `Post`. Ues the `bufio.NewScanner(postBody)`- This is memory-efficient cuz it reads the input line-by-line than loading a massive file into memory all at once. Inside the `newPost`-- there is a local helper function -- 

```go
readMetaLine := func(tagName string) string {
   scanner.Scan() // Advances to the next line
   return strings.TrimPrefix(scanner.Text(), tagName) // Removes the "Title: " prefix
}
```

- This is a *closure* -- it captures the `scanner`varaible from the outer scope.
- Every time it is called, consumes exactly one line from the input.

After the metadata lines are consumed, the remaining text is considered the *Body* -- 

```go
func readBody(scanner *bufio.Scanner) string {
    scanner.Scan() // Skips the potential empty line after tags
    buf := bytes.Buffer{}
    for scanner.Scan() {
       fmt.Fprintln(&buf, scanner.Text())
    }
    return strings.TrimSuffix(buf.String(), "\n")
}
```

Cuz the `scanner`is passed by pointer (`*bufio.Scanner`). `readBody`starts exactly where `newPost`left off. And `bytes.Buffer`- this is a performance cuz practice in Go -- instead of repeatedly creating new strings with `+`, it collects all lines into a buffer and converts them to single string at the very end.