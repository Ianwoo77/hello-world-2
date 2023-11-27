# Shared and exclusive attributes of Series and DataFrames

A `Series`has a `dtype`attribute that reveals the data type of its valus -- noticed that the `DataFrame`has a `dtypes`attriute -- Heterogenous means mixed or varied.
`nba.dtypes.value_counts()`

Pandas uses a separate index object to store a `DataFrame`'s columns, can access it via the `columns`attribute:
`nba.columns`

This object is another type of index object -- `Index`-- Pandas uses this option when an index consists of text values. And the `index`attribute is an example of an attribute that a `DataFrame`shares with a `Series`.

```python
nba.ndim # 2
nba.shape # (,)
nba.size
nba.count()
nba.count().sum()
```

For the `count()`, it skips NaN.

```python
nba.sample(3)
nba.nunique() # count the number of unique values in a series
nba.sum(numeric_only=True)
nba.mean(numeric_only=True)
```

### Sorting by multiple columns

Can sort multiple columns in a DataFrame by passing a list to the `srot_values()`-- Pandas will sort the `DataFrame`columns consecutively in the order. like:
`nba.sort_values(by=["Team", "Name"])`

note that the `sort_values()`also supports the `inplace`parameter, will be explicit and re-assign the returned `DataFrame`to the `nba`-- like:

```python
nba=nba.sort_values(
    by=['Team', 'Salary'],
    ascending=[True, False]
)
```

Sort by index -- can: `nba.sort_index().head()` ==> `nba.sort_index(ascending=True).head()`, and a DF is a 2D data structure, can sort an additional axis -- To sort DataFrame in order, again rely on `sort_index`method, this time, need to add an `axis`parameter and pass it an argument of `columns`. fore:

```python
nba.sort_index(axis='columns').head()
nba.sort_index(axis=1).head()
```

Setting a new index -- The `set_index`method return a new DF with a given column set as the index:

```python
# the two are eq
nba.set_index(keys="Name")
nba.set_index("Name")
```

As a side note, can set the index when importing a data set -- Pass the column name as a string to the `read_csv`.

```python
nba= pd.read_csv(
    '../pandas-in-action/chapter_04_the_dataframe_object/nba.csv', 
    parse_dates=['Birthday'], index_col='Name'
)
```

### Selecting columns and rows

A DF is a collection of `Series`objects with a common index -- Multiple syntax options are available to extract one or more of these series from the DF. Fore, can extract the `Salary`column with:
`nba.Salary`

Also can extract a column by passing its name in square brackets after the `DataFrame`.
`nba["position"]`

The advantage of the `[]`syntax is that it supports column names with spaces.
`nba["Player Position"]`

Selecting multiple columns -- just like:
`nba[["Salary", "Birthday"]]`

Note, can use the `select_dtypes`method to select columns based on their data types -- like:
`nba.select_dtypes(exclude=['object', 'int'])`

### Selecting rows from a DF

The `loc`attribute extracts a row by label -- can call attributes such as `loc`accessors cuz they access a piece of data. Type a pair after the `loc`and pass in the target index label. like:
`nba.loc['LeBron James']`

Can also pass a list in between the square brackets to extract multiple rows.
`nba.loc[['Kawhi Lenoard', 'Paul Georage']]`

Want to target all players like:
`nba.sort_index().loc['Otto':'Patrick Beverley']`

Just note that the panda’s `loc`acessor has some differences with Py’s list-slicing syntax.

Extracting by index position -- The `iloc`accessor extracts row by index position.
`nba.iloc[300]`
`nba.iloc[[100,200,300,400]]`
`nba.iloc[400:404]`
`nba.iloc[-10:-6]`

Extracting from the specific column

Both the `loc`and `iloc`attributs accept a second argument representing the column(s) to extract. If using `loc`, have to provide the column name -- if `iloc`have to provide the column position. The next example uses `loc`to pull the value at the intersection of the row and the Team column like:
`nba.loc['Giannis Antetokounmpo', 'Team']`

And to specify multiple values, can also pass a list for one or both of the arguments to the `loc`accessor like:
`nba.loc["James Harden", ['Position', 'Birthday']]`

Can also use list-slicing syntax to extrct multiple without explicitly writing names. like:
`nba.loc['Joel Embiid', 'Position':'Salary']`

The next targets the value at the intersection of the row at index 57 and the column at the index 3:
`nba.iloc[57, 3]`

Can use list-slicing -- pulls all rows from index position 100, but not including 104 like:
`nba.iloc[100:104, :3]`

Can also use two alternative *attribute* -- `at`and `iat`-- when know that want to extract a single value from a DF, The two are speedier. note extract a single value -- 
`nba.at['Austin Rivers', 'Birthday']`

Extracting from Series -- the `loc iloc at iat`are availiable on `Series`as well. like:
`nba['Salary'].loc['Damian Lillard']`

Renaming -- can directly call the `columns`attribute like:
`nba.columns= ["Team", 'Position', 'Date of birth', 'Pay']`

or , calling the `rename`method -- accomplishes the same result -- pass its parameter a dictionary in which the keys are existing names and values are new names.
`nba.rename(columns= {'Birthday':'Birth of Date'})`
note can also rename index labels by passing a dictionary to the method’s `index`like:
`nba.rename(index={‘...’:’...’})`

### Resetting an index

Sometimes, want to set another column as the index of `DataFrame`-- Can invoke the `set_index`just with different column but would lose current index of player names. So, to preserve the player’s names, must first re-integrate the existing index as a regular column in the DF. The `reset_index`moves the current index to a `DataFrame`and replaces the former index with pandas’ numeric index like:
`nba.reset_index().set_index('Team').head()`

One advantage of avoiding the `inplace`parameter is that can chain multiple method calls. just like:
`nba=nba.reset_index().set_index("Team")`

Code -- 

```python
nfl= pd.read_csv('../pandas-in-action/chapter_04_the_dataframe_object/nfl.csv',
                 parse_dates=['Birthday'])
# The two lines are eq
nfl.Team.value_counts().head()
nfl["Team"].value_counts().head()

# the 5 highest-paid players like:
nfl.sort_values('Salary', ascending=False).head()

# sort by multiple columns like:
nfl.sort_values(['Team', 'Salary'], ascending=[True, False])
```

The final -- have to find the oldest player on the New York Jets roster -- To preserve player names currently, first use the `reset_index()`to move them back into the DF as a regular column like:

```python
nfl= nfl.reset_index().set_index(keys="Team")
nfl.loc['New York Jets'].head()
# at last to srot the Birthday column and extract the top record like:
nfl.loc['New York Jets'].sort_values('Birthday').head(1)
```

## Working with JSON Data

Reading and Writing JSON data -- The `encoding/json`package support for encoding and decoding JSON data.

- `NewEncoder(writer)`-- returns an `Encoder`which can be used to encode JSON data and write it to the specified `Writer`
- `NewDecoder(reader)`-- Read JSON data from reader and decode it.
- `Marshal(value)`-- encodes the specified value as JSON -- results are the JSON content in a byte and an `error`.
- `Unmarshal(byteSlice, val)`-- parses JSON data contained in the specified slice of bytes and assigns the result to the specified value.

Encoding JSON data -- The `NewEncoder`ctor function is used to create an `Encoder`which can be used to Write JSON data to a writer -- 

- `Encode(val)`-- encodes the specified value as JSON and writes it to the writer.
- `SetEscapeHTML(on)`-- method accepts a `bool`argument that when `true`, encodes characters that would be dangerous in HTML to be escaped, the default behavior is to escape these characters.
- `SetIndent(prefix, indent)`-- specifies a prefix and indentation that is applied to the name of each field in the JSON output.

```go
func main() {
	var b bool = true
	str := "Hello"
	var fval float64 = 99.99
	var ival int = 200
	var pointer *int = &ival

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	for _, val := range []any{b, str, fval, ival, pointer} {
		// pointer just the value
		encoder.Encode(val)
	}
	fmt.Print(writer.String())
}
```

### Encoding Arrays and Slices

Go slices and arrays are encoded as JSON arrays, with the exception that `byte`slices are expressed as *base-64*.

```go
func main() {
	names := []string{"Kayak", "Lifejacket", "Soccer Ball"}
	numbers := [3]int{10, 20, 30}
	var byteArray [5]byte
	copy(byteArray[0:], []byte(names[0]))
	byteSlice := []byte(names[0])

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	encoder.Encode(names)
	encoder.Encode(numbers)
	encoder.Encode(byteArray)
	encoder.Encode(byteSlice) // base-64 coded

	fmt.Print(writer.String())
}
```

Encoding Maps -- Go maps are encded as JSON *objects*-- with the map keys used as object keys. like:

```go
func main() {
	m := map[string]float64{
		"Kayak":      279,
		"Lifejacket": 49.95,
	}
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	encoder.Encode(m)

	fmt.Print(writer.String())
}
```

### Encoding structs

The `Encoder`expresses struct values as JSON objects, using the exported struct field name as the object’s keys and the field values as the object’s values.

```go
func main(){
    var writer strings.Builder
    encoder := json.NewEncoder(&writer)
    encoder.Encode(Kayak)
    fmt.Print(writer.String())
}
```

Understanding the effect of Promotion in JSON in Encoding -- When a struct defines an embedded field is also a struct, the fields of the embedded struct are just promoted and encoded as though they are defined by the enclosing type -- like:

```go
type DiscountProduct struct {
	*Product
	Discount float64
}
func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	dp := DiscountProduct{
		&Kayak, 10.50,
	}
	encoder.Encode(&dp)

	fmt.Print(writer.String())
}
```

The `Encoder`promote the `Product`fields in the JSON output.

### Customizing JSON Encoding of Structs

How a struct is encoded can be just customized using the `struct`tags. which are string literals that follow fields, Struct tags are part of the Go support for reflection -- for this it is enough to know that tags follow fields and can be used to alter two aspects of how a field is encoded in JSON like:

```go
type DiscountProduct struct {
	*Product `json:"product"`
	Discount float64
}
```

tag follows a specific format -- the term `json`is followed by a colon, followed by the name that should be used when the field is encoded.

Omitting a Field -- The `Encoder`skips fields decorated with a tag that specifies a `-`like:

```go
type DiscountedProduct struct {
    *Product `json:"product"`
    Discount float64 `json:"-"`
}
```

Omitting Unassigned -- like:

```go
type DiscountProduct struct {
    *Product `json:"product,omitempty"`
    Discount float64 `json:"-"`
}
```

The `omitempty`keyword is separated from the field name with a comma but without any spaces. like: to skip a `nil`without changing the name or field promotion, specify the `omitempty`keyword without a name like:

```go
type DiscountProduct struct {
    *Product `json:",omitempty"`
}
```

Forcing Fields to be encoded as Strings -- Can be used to force a field value to be encoded as a string. like:

```go
type DiscountedProduct struct {
    *Product `json:",omitempty"`
    Discount float64 `json:",string"`
}
```

Encoding interfaces -- The JSON encoder can be used on values assigned to interface variables, but it is the dynamic type that is encoded.

```go
type Named interface{ GetName() string }

type Person struct{ PersonName string }

func (p *Person) GetName() string { return p.PersonName }

func (p *DiscountProduct) GetName() string { return p.Name }
namedItems := []Named{&dp, &Person{"Alice"}}
encoder.Encode(namedItems)
```

### Creating Completely Custom JSON Encoding

The `Encoder`checks to see whether a structure implements the `Marshaler`interface -- which denotes a type that has a custom encoding and which defines the method -- 

- `MarshalJSON()`-- invoked to create a JSON representatin of a vlaue and returns a byte slice containing JSON and an `error`indicating encoding problems.

```go
func (dp *DiscountProduct) MarshalJSON() (jsn []byte, err error) {
	if dp.Product != nil {
		m := map[string]any{
			"product": dp.Name,
			"cost":    dp.price - dp.Discount,
		}
		jsn, err = json.Marshal(m)
	}
	return
}
```

So the `MarshalJSON()`method can generate JSON in any way that suits the project -- most reliable approach is to use the support for encoding maps -- define a map with `string`keys and use the empty interface for the values -- this allows to build the JSON by adding k-v pairs to the map and then pass the map to the `Marshal`function.

### Decoding JSON data

The `NewDecorder`ctor function creates a `Decoder`which can be used to decode JSON data obtained from a `Reader`, using the methods like:

- `Decode(value)`-- reads and decodes data -- used to create the specified value. The method returns an `error`that indicates problems decoding the data to the required type or `EOF`.
- `DisallowUnknownFields()`-- by default, when decoding `struct`, the `Decoder`ignores any key in the JSON data for which there is no corresponding struct field. Calling this causes the `Decode`to return an error.
- `UseNumber()`-- By default, JSON number values are decoded into `float64`values, calling this uses the `Number`type instead.

```go
func main() {
	reader := strings.NewReader(`true "hello" 99.99 200`)
	vals := []any{}

	decoder := json.NewDecoder(reader)

	for {
		var decodedVal any
		err := decoder.Decode(&decodedVal)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		}
		vals = append(vals, decodedVal)
	}
	for _, val := range vals {
		Printfln("Decoded: (%T): %v", val, val)
	}
}
```

Just created a `Reader`that will produce data from a string containing a sequence of values, separated by space -- note that -- the JSON specification allows values to be separated by spaces on newline characters.

```go
var decodedVal any
err := decoder.Decode(&decodedVal)
```

Note that the `Decode()`returns an `error`-- which can indicate problems but it also be used to signal the end of the data using the `io.EOF`error. A `for`loop repeatedly decodes values until `EOF`-- and then use another for loop to write out each decoded type and value using the formatting verbs described.

Decoding Number Values -- JSON uses a single data type to represent both float and integer -- cuz Js does so. the `Decoder`decodes these numeric values as `float64`values, which can be seen in the output from the previous example. this behavior can be changed by calling `UseNumber()`on the `Decoder`-- which uses JSON number values to be decoded into the `Number`type.

- `Int64()`-- returns the decoded value as a `int64`and an error
- `Float64(), String()`

```go
decoder.UseNumber() // note that
for _, val := range vals {
    if num, ok := val.(json.Number); ok {
        if ival, err := num.Int64(); err == nil {
            Printfln("Decoded Integer: %v", ival)
        } else if fpval, err := num.Float64(); err == nil {
            Printfln("Decoded Floating point: %v", fpval)
        } else {
            Printfln("Decoded String: %v", num.String())
        }
    } else {
        Printfln("Decoded (%T): %v", val, val)
    }
}
```

### Specifying Types for Decoding

The previous exmples just passed an `any`to the `Decode`method:

```go
var decodedVal interface{}
err:= decoder.Decode(&decodedVal)
```

This lets the `Decoder`select the `Go`data type for the JSON value that is decoded, but, if know the structure of the JSON data you are decoding, can direct the `Decoder`to use specific Go types by using variables:

```go
func main(){
    //...
    var bval bool
    var sval string
    //...
    vals := []any {&bval, &sval...}
    for i:=0; i<len(vals); i++ {
        err:= decoder.Decode(vals[i])
        if err != nil {
            ...
        }
    }
    Printfln("Decoded (%T): %v", bval, bval)
}
```

Decoding Arrays -- The `Decoder`processes arrays automatically, but care must be taken cuz JSON allows arrays to contain values of different types.

```go
func main() {
	reader := strings.NewReader(`[10,20,30]["Kayak", "Lifejacket", 279]`)
	vals := []any{}

	decoder := json.NewDecoder(reader)

	for {
		var decodedVal any
		err := decoder.Decode(&decodedVal)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		}
		vals = append(vals, decodedVal)
	}
	for _, val := range vals {
		Printfln("Decoded (%T): %v", val, val)
	}
}
```

Also, If you know the structure of the JSON data in advance:

```go
ints := []int{}
mixed := []any{}
vals := []any {&ints, &mixed}

for i:=0; i<len(vals); i++ {
    err := decoder.Decode(vals[i])
}
```

Decoding Maps -- Js objects are expressed as k-v pairs, which makes it easy to decode them into Go maps like:

```go
func main() {
	reader := strings.NewReader(`{"Kayak":279, "Lifejackets":49.95}`)

	m := map[string]any{}

	decoder := json.NewDecoder(reader)

	err := decoder.Decode(&m)
	if err != nil {
		Printfln("Error: %v", err.Error())
	} else {
		Printfln("Map: %T, %v", m, m)
		for k, v := range m {
			Printfln("Key: %v, value: %v", k, v)
		}
	}
}
```

So the safest approach is to define a map with `string`keys and empty interface values, which ensures that all the k-v pairs in the JSON data can be decoded into the map. And a single JSON object can be used for multiple data types as values. But, also, if know in advance:

`m:= map[string]float64{}`

### Self-Tsting Code

Suppose storing these items as strings, something like this:

```go
func TestListItems(t *testing.T) {
	t.Parallel()
	input := []string{
		" a battery",
		"a key",
		"and a tourist map",
	}
	want := "You can see here a battery, a key, and a tourist map."

	got := ListItems(input)
	if want != got {
		t.Errorf("Want %q, got %q", want, got)
	}
}

```

