# pivot() --

Note that `pivot()`can only handle *unique rows* specified by `index`and `columns`. If data contains any duplicates, use `pivot_table()`. While `pivot()`provide general purpose pivoting with various data types. pandas also provide `pivot_table()`just, with aggregating of numberic data.

```python
import datetime
df = pd.DataFrame(
    {
        "A": ["one", "one", "two", "three"] * 6,
        "B": ["A", "B", "C"] * 8,
        "C": ["foo", "foo", "foo", "bar", "bar", "bar"] * 4,
        "D": np.random.randn(24),
        "E": np.random.randn(24),
        "F": [datetime.datetime(2013, i, 1) for i in range(1, 13)]
        + [datetime.datetime(2013, i, 15) for i in range(1, 13)],
    }
)
df.pivot_table(values='D', index=['A', 'B'], columns='C')
df.pivot_table(values=['D', 'E'], index='B', columns=['A', 'C'], aggfunc=np.sum)
```

The result is a `DataFrame`potentially having a `MultiIndex`on the index or column. 

Following 4 steps to create a pivot table -- 

1. Select the column(s) whose value we just want to aggregate.
2. Choose the aggretaion operation to apply to the column(s).
3. Select the column(s) whose value will group the aggregated data into categories.
4. Determine whether to place the groups on the row axis, the column axis, or both.

```python
sales.pivot_table(index='Date', values=['Expenses', 'Revenue'])
```

Note just shows average expenses and average revenue organized by the 5 unique dates in the `Date`.

```python
sales.pivot_table(index='Date', values='Expenses Revenue'.split(), aggfunc=np.sum)
# also, pass the columns parameter like:
sales.pivot_table(index='Date', 
                  values='Revenue',
                  columns='Name',
                  aggfunc=np.sum)
# Notice NaNs in the data set, so can use `fill_value` parameter to replace all NaNs
sales.pivot_table(index='Date', 
                  values='Revenue',
                  columns='Name',
                  aggfunc=np.sum,
                  fill_value=0,
                  margins=True,
                  margins_name="Total")
```

### Additional options

And supports a variety of aggregation operations, suppose that are interested in the number of business deals closed per day, can also pass `aggfunc`an argument of `np.count`like:

```python
sales.pivot_table(index='Date',
                  columns='Name',
                  values='Revenue',
                  aggfunc='count')
```

`NaN`indiceates the salesman did not make a sale on a given day. Can apply different aggregations to different columns by passing a dictionary to the `aggfunc`parameter just like:

```python
sales.pivot_table(index='Date',
                  columns='Name',
                  values=['Revenue', 'Expenses'],
                  fill_value=0,
                  aggfunc=dict(Revenue='min', Expenses=np.max))
# can stack multiple grouping on a single axis by passing index parameter a list of columns.
# multiindex DF so:
sales.pivot_table(index=['Name', 'Date'], values='Revenue', aggfunc=np.sum)
# switch the order of strings in the index list can rearrange the levels in the pivot table's MultiIndex
```

### Stacking and unstacking index levels-- 

Closely related to the `pivot()`are the `stack()`and `unstack()`methods available on `Series`and `DataFrame`. These methods are designed to work together with `MultiIndex`.

- `stack()`-- pivot a level of the column labels, returning a DF with an index with a new inner-most level of the row labels. Just, from columns to the index
- `unstack()`-- reverse `stack`.

The `stack`method moves an index level from the column axis to the row axis. Note that pandas returns a ***`Series`***.

```python
by_name_and_date=sales.pivot_table(
    index='Name',
    columns='Date',
    values='Revenue',
    aggfunc=np.sum
)
by_name_and_date.stack()
```

Also noticed that the DF’s `NaNs`are absent from the `Series`, pandas kept cells with `NaNs`in the pivot table to maintain the structural integrity of the rows and columns. The shape of the `MultiIndex Series`just allows pandas to discard the `NaNs`. 

Then the complementary `unstack`method moves an index level from the row axis to the column axis.

```python
sales_by_customer = sales.pivot_table(
    index=['Customer', 'Name'],
    values='Revenue',
    aggfunc=np.sum
)
print(type(sales_by_customer)) # actually also a DF
sales_by_customer.unstack()
```

In the new DF, the column axis now has a two-level MultiIndex.

## Buffering Data

The `bufio`package provides support for adding buffers to readers and writers. To see how -- like:

```go
type CustomReader struct {
	reader    io.Reader
	readCount int
}

func NewCustomReader(reader io.Reader) *CustomReader {
	return &CustomReader{reader, 0}
}

func (cr *CustomReader) Read(slice []byte) (count int, err error) {
	count, err = cr.reader.Read(slice)
	cr.readCount++
	Printfln("Custom reader: %v bytes", count)
	if err == io.EOF {
		Printfln("Total Reads: %v", cr.readCount)
	}
	return 
}
// ...
func main() {
	text := "It was a boat, A small boat."
	var reader io.Reader = NewCustomReader(strings.NewReader(text))
	var writer strings.Builder
	slice := make([]byte, 5)
	for {
		count, err := reader.Read(slice)
		if count > 0 {
			writer.Write(slice[0:count])
		}
		if err != nil {
			break
		}
	}
	Printfln("Read data: %v", writer.String())
}
```

Reading small amounts of data can be problematic when there is a large amount of overhead associated with each opreation -- this isn’t an issue when reading a string stored in memory, but reading data from other data souces, files, network connection, may be a problem. In the `bufio`package like:

- `NewReader(r)`-- returns a buffered `Reader`with the default buffer size, 4k
- `Newreader(r, size)`-- buffered with the specified buffer size.

Just : `reader = bufio.NewReader(reader)`

#### Using the additional Buffered Reader Methods

The `NewReader`and `Size`funcs return `bufio.Reader`values. The `bufio.Reader`struct defines additional methods. Also the `bufio.Writer`defines additional func -- 

- `Available()`-- returns the number of available bytes
- `Buffered(), Flush(), Reset(writer), Size()`

### Formatting and Scanning with Readers and Writers

The `fmt`package also provides functions for scanning values from a `Reader`and converting them into different types.

```go
func scanFromReader(reader io.Reader, template string,
	vals ...any) (int, error) {
	return fmt.Fscanf(reader, template, vals...)
}

func main() {
	reader := strings.NewReader("Kayak Watersports $279.00")
	var name, category string
	var price float64
	scanTemplate := "%s %s $%f"
	_, err := scanFromReader(reader, scanTemplate, &name, &category, &price)
	if err != nil {
		Printfln("Error: %v", err.Error())
	} else {
		Printfln("Name: %v", name)
		Printfln("Category: %v", category)
		Printfln("Price: %.2f", price)
	}
}
```

The scanning process reads from bytes from the `Reader`and uses the scanning template to parse the data that is received, the scanning template contains two strings and a `float64`

And a useful technique when reading a `Reader`is to scan data gradually using a loop.

```go
func scanSingle(reader io.Reader, val any) (int, error) {
	return fmt.Fscan(reader, val)
}

func main() {
	reader := strings.NewReader("Kayak Watersports $279.00")
	for {
		var str string
		_, err := scanSingle(reader, &str)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		}
		Printfln("Value: %v", str)
	}
}
```

### Writing Formatted strings to a writer

The `fmt`also provides functions for writing formatted strings to a `Writer`-- 

```go
func writeFormatted(writer io.Writer, template string, values ...any) {
	fmt.Fprintf(writer, template, values...)
}

func main() {
	var writer strings.Builder
	template := "Name: %s, Category: %s, Price: $%.2f"
	writeFormatted(&writer, template, "Kayak", "watersports", 279.00)
	fmt.Println(writer.String())
}
```

The `writeFormatted`uses the `fmt.Fprintf`func to write a string formatted with a template to a `writer`.

#### Using a `Replacer`with a Writer -- 

The `strings.Replacer`struct can be used to perform replacement on a `string`and output the modified result to a `Writer` just like:

```go
func writeFormatted(writer io.Writer, template string, values ...any) {
	fmt.Fprintf(writer, template, values...)
}

func main() {
	text := "It was a boat. A small boat."
	subs := []string{"boat", "kayak", "small", "huge"}
	var writer strings.Builder
	writeReplaced(&writer, text, subs...)
	fmt.Println(writer.String())
}
```

### Working with JSON -- 

In this, describe the Go std lib support for the JSON. The `encoding/json`package provides support for encoding and decoding JSON data, as demonstrated -- 

- `NewEncoder(writer)`-- returns an `Encoder`, can be used to encode JSON data **and** write it to the `Writer`.
- `NewDecoder(reader)`-- returns a `Decoder`, which can be used to read JSON from the specified `Reader`**and** decode it.

Also provides convenient functions for JSON without using `Reader`and `Writer`like:

- `Marshal(value)`-- encodes the specified value as JSON, results are JSON content(byte slice) and `error`
- `Unmarshal(byteSlice, val)`-- parses JSON data contained in the specified slice of bytes and assigns the result to the specified value.

Encoding JSON -- The `NewEncoder()`is used to create an `Encoder`and, which can be used to write JSON to a `Writer`-- `Encode(val)`, `SetEscapeHTML(on)`, `SetIndent(prefix, indent)`-- specifies a prefix and indentation that is applied to the name of each field in the JSON output.

```go
func main() {
	var b bool = true
	var str string = "hello"
	var fval float64 = 99.99
	var ival int = 200
	var pointer *int = &ival	// just print the value of pointer point

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	for _, val := range []any{b, str, fval, ival, pointer} {
		encoder.Encode(val)
	}
	fmt.Println(writer.String())
}
```

#### Encoding Arrays and Slices -- 

Slices and arrays as JSON arrays. just like:

```go
func main() {
	names := []string{"Kayak", "Lifejacket", "Soccer Ball"}
	numbers := [3]int{10, 20, 30}
	var byteArray [5]byte
	copy(byteArray[0:], []byte(names[0]))
	byteSlice := []byte(names[0]) // to base-64 encoded string

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	encoder.Encode(names)
	encoder.Encode(numbers)
	encoder.Encode(byteArray)
	encoder.Encode(byteArray)
	encoder.Encode(byteSlice)

	fmt.Println(writer.String())
}
```

#### Encoding Maps 

Go maps are encoded as *Json objects*, with the map keys used as the object keys. The values contained in the map are encoded based on their type. Like:

```go
func main() {
	m := map[string]float64{
		"kayak":      279,
		"lifejacekt": 49.95,
	}
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	encoder.Encode(m)
	fmt.Print(writer.String())
}
```

## Improving Performance with reades-writer mutexes

What if we had an application serving mostly static data to many concurrent clients. We outlined one such app when we had a web server app serving sports information. Just write two different types of goroutines, And then appends them to a shared data structure. Shared data structure is a Go slice of `string`type. 

```go
func matchRecorder(matchEvents *[]string, mutex *sync.Mutex) {
	for i := 0; ; i++ {
		mutex.Lock()
		*matchEvents = append(*matchEvents,
			"Match event "+strconv.Itoa(i))
		mutex.Unlock()
		time.Sleep(200 * time.Millisecond)
		fmt.Println("append match event")
	}
}
func clientHandler(mEvents *[]string, mutex *sync.Mutex, st time.Time) {
	for i := 0; i < 100; i++ {
		mutex.Lock()
		allEvents := copyAllEvents(mEvents)
		mutex.Unlock()

		timeTaken := time.Since(st)
		fmt.Println(len(allEvents), "events copied in", timeTaken)
	}
}

func copyAllEvents(matchEvents *[]string) []string {
	allEvents := make([]string, 0, len(*matchEvents))
	for _, e := range *matchEvents {
		allEvents = append(allEvents, e)
	}
	return allEvents
}
```

Then, connect everything together and start our goroutines in a `main()`function. After we create a normal mutex, we prepopulate the match event slice with many match events. This simulates a game that has been going on for a while. 

In the `main()`, then start a match-recorder goroutine and 5000 client handler goroutines, we are simulating a game that is ongoing and that has a large number users making simultaneous requests to get game updates.

Go comes with its own implemenation of a reader-writer lock. In addition to offering the normal execlusive locking and unlocking functions. `sync.RWMuxtex`gives us extra methods to use the reader’s side of the mutex. The locking and unlocking functions.