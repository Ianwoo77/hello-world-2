# Working it out -- 

In this, create a multi-index with 4 levels and then use those levels to ask and answer a variety of questions.

```python
df = pd.read_csv(
    "olympic_athlete_events.csv",
    index_col=["Year", "Season", "Sport", "Event"],
    usecols=[
        "Age",
        "Height",
        "Team",
        "Year",
        "Season",
        "City",
        "Sport",
        "Event",
        "Medal",
    ],
)
```

Then use the `sort_index()`method -- which returns a new data frame containing the same data we read from the csv file but with the rows ordered according to the multi-index.

```python
df.loc[(slice(1936,2000),'Summer'),'Age'].mean()
df.dropna(subset='Medal')\
    .loc[(slice(None), 'Summer', 'Archery'), 'Team'].value_counts()
df.loc[
    (slice(1980, None), "Summer", slice(None), "Table Tennis Women's Team"),
    "Height",
].mean()
```

For the next query, expand our population, looking at not just the women’s team version of table tennis but also the men’s version -- like;

```python
df.loc[
    (
        slice(1980, None),
        "Summer",
        slice(None),
        ["Table Tennis Men's Team", "Table Tennis Women's Team"],
    ),
    "Height",
].mean()
```

- Events occur in either 

```python
df= df.reset_index('Season')
df.loc[(slice(1980,2020),"Tennis"),'Height'].max()
f.loc[1980:].loc[lambda df: df['Medal']=='Gold', 'City'].value_counts()
```

## Don’t use Filename as a function input 

When creating a new function that needs to read a file, passing a filename isn’t considered a best practice and can have negative effects -- such as making unit tests harder to write. Suppose want to implement a function to count the number of empty lines in a file -- one way to implement this func would be accept a filename and use `bufio.NewScanner`to scan and check every line like:

```go
func countEmptyLinesInFile(filename string) (int error) {
    file, err := os.Open(filename)
    if err != nil {
        return 0, err
    }
    // handle file colsure
    scanner := bufio.NewScanner(file)
    for scanner.Scan(){...}
}
```

In go, the `bufio`package provides buffered I/O operations, which can significantly improve performance when reading from or writing to I/O sources -- one of the most commonly used types in the `bufio`package is the `Scanner`. And the `bufio.NewScanner`function creates a new `Scanner`that reads from an `io.Reader`and splits the input just into tokens using a split funciton, whcih defaults to `ScanLines`. Just like:

```go
file, err := os.Open("example.txt")
if err != nil {
    fmt.Println("Error opening file:", err)
    return
}
defer file.Close()

scanner := bufio.NewScanner(file)
for scanner.Scan(){
    fmt.Println(saccner.Text())
}
if err := scanner.Err(); err != nil {
    fmt.Println("Error reading file:", err)
}
```

For this, open a file from the filename. Then use the `bufio.NewScanner`to scan every line -- this function will do what we expect it to do. Indeed, so long as the provided file name is valid, will read from it and return the number of emtpy lines -- But, say, want to implement unit tests to cover the fillowing cases -- 

- nominal case
- An empty file
- File contining only empty lines

Each unit test till require creating a file in Go project -- the more complex the function is, the more cases we may want to add, and the more files we will create. Furthermore, this func isn’t reusable -- fore if had to implement the same logic but count the number of enpty lines with an HTTP request -- would have to duplicate the main logic -- 

```go
func countEmptyLinesInHttpRequest(request http.Request) (int, error) {
    scanner := bufio.NewScanner(request.Body)
}
```

One way to overcome these limitations might be to make the function accept a `*bufio.Scanner`-- both functions have the same logic from the moment we create the `scanner`variable, so this approach would work. But in go, the idiomatic way is to start from the reader’s abstraction -- like:

```go
func countEmptyLines(reader io.Reader) (int, error) {
    scanner := buio.NewScanner(reader)
    for scanner.Scan(){...}
}
```

Cuz `bufio.NewScanner`accpets an `io.Reader`can directly pass the `reader`variable. And, what are the benefits of this apporach -- the function abstracts the data soruce -- fore, file, request, socket input -- it’s not imporant for the funtion -- cuz the `os.File`, `http.Requeste`both implement the `io.Reader`.

Another benefit is related to testing -- mentioned that creating one file per test case could quickly become cumbersome -- now that the `EmptyLines`accepts an `io.Reader`, can implement unit tests by creating an `io.Reader`from a string like:

```go
func TestCountEmptyLines(t *testing.T) {
    emptyLines, err := countemptyLines(strings.NewReader(`
    foo
    	bar
    	
    	baz`))
    // logic
}
```

So, for this, create an `io.Reader`using `strings.NewReader`from a string literal directly. Therefore, we don’t have to create one file per test case -- each test case cna be self-contained, improving the test readability and maintainability as we don’t have to open another file to see the content.

And, accepting a filename as a funciton input to read from a file should -- in most cases, be condsidered a code smell -- Except in specific functions such as `os.Open()`-- As have seen, it makes unit tests more complex cuz we may have to create multiple files -- also reduces the reusability of a function -- Using the `io.Reader`abstracts the data source. Regardless of whether the input is a file, a string, an HTP requset, or a gRPC request.

### How defer args and receviers are evaluated

Mentioned in that the `defer`statement delays a call’s execution until the surrounding function returns. A common mistake made by Go deverloper is not understanding how arguments are evaluated -- well delve into the with the two.
