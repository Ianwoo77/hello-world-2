# Text data Coding Challenge

Customers data set includes an Address column -- Each address consists of a street, city, state and zip code -- challenge is to separate these four values -- assign them to new columns, and remove the Address, like:

`customers['Address'].str.split(',').head()`

For this, the split keeps the spaces after the commas, could perform additional cleanup by using a method such as `strip` -- but a better solution is avaialble, each portion of the address is separated by a comma, and a space -- therefore, can pass the `split`method just a delimiter of both characters -- like:

`customers['Address'].str.split(', ').head()`

And by default, the `split()`returns a `Series`of a lists, can make the method return a `DataFrame`by passing the `expand`parameter an argument of `True`like:

`customers['Address'].str.split(', ', expand=True).head()`
`customers['Address'].str.split(', ', *expand*=True).head()`

Have a souple more steps left -- add a new 4-column `DataFrame`to our existing customers `DataFrame`-- define a list with the new column names -- this time around, assign the list to a variable to simplify readability -- pass the list in square brckets befor a equal sign -- on the right side of the `=`, use the preceding code to create the new `DataFrame`.

```python
customers['Street City State zip'.split()]=\
    customers['Address'].str.split(', ', expand=True)
```

The last step is deleting the original `Address`column, the `drop`method is a good solution here -- to alter the `DataFrame`permantenly, make sure overwirte the customers the returned DF like:

`customers.drop('Address', axis='columns', inplace=True)`

Another option is use Py’s built-in `del`keyword before the target column just like:

`del customers['Address']`

### A note on regular expressions

Any discussion of working with text data is incomplete without mentioning regular expressions -- `RegEx`-- *regular expression* ia a search pattern -- 

Declare RE expressions with a special syntax consisting of symbols and characters -- `\d`-- fore, matches any numberic digit between 0 and 9.

## MultiIndex DataFrames

A `MultiIndex`is an index object that holds multiple levels -- each level stores a value for a row. It is just optimal to use a `MultiIndex`when a combination of values provdies the best identifier for a row of data -- And a `MultiIndex`is also ideal for *hierarchical data* -- data in which one column’s values are subcategory of another columns’s values.

`address = ("8809 Flair Square", "Toddside", "IL", "37206")`

Can create a `MultiIndex`object independently of a `Series`or `DataFrame`-- the `MultiIndex`class is available as a top-level attribute on the pandas library, it includes a `from_tuples`class method that instantiates a `MultiIndex`from a list of tuples, - A class *method* is a method invoke on a class -- like:

```python
addresses = [
("8809 Flair Square", "Toddside", "IL", "37206"),
("9901 Austin Street", "Toddside", "IL", "37206"),
("905 Hogan Quarter", "Franklin", "IL", "37206"),
]
pd.MultiIndex.from_tuples(addresses)  # tuple
```

For this, have 4 `MultiIndex`-- which stores three tuples of four elements each -- there is a consistent pattern to each tuple’s elements.

In pandas terminology, the collection of tuple values at the same position forms a `level`of the `MultiIndex`object -- Can assign each `MultiIndex`level a name by passing a list to the `from_tuples`method’s `names`parameter.

```python
row_index= pd.MultiIndex.from_tuples(
    tuples=addresses, names='Street City State Zip'.split()
)
```

For this, a `MultiIndex`is a storage container in which each label holds multiple values -- a level consists of the values at the same position across the labels. The easiest way is to use the `DataFrame`ctor’s `index`parameter, passed this parameter a list of strings in  -- also accepts any valid index object -- pass it the `MultiIndex`like:

```python
data = [
    ['A', 'B'],
    ['C+', 'C'],
    ['D-', 'A'],
]
columns= ["Schools", 'Cost of Living']
area_grades= pd.DataFrame(
    data, index=row_index, columns=columns
)
area_grades
```

Have a `DataFrame`with a `MultiIndex`on its row axis. Each row’s label holds 4 values, city, state, zip ...

Pandas currently stores the 2 column names in a single-level `Index`object fore:
`area_grades.columns`

Pandas currently stores the 2 column names in a single-level `Index`object, just create a second MultiIndex and attach it to the column axis -- like:

```python
column_index = pd.MultiIndex.from_tuples(
    [
        ("Culture", "Restaurants"),
        ("Culture", "Museums"),
        ("Services", "Police"),
        ("Services", "Schools"),
    ]
)
```

Attach both of our `MultiIndexes`to a `DataFrame`-- the `MultiIndex`for the row axis requires the data set to hold 3 rows - the `MultiIndex`for the column axis, requires the data set to hold 4 columns. Therefore, our data set must have 3*4 shape. like:

```python
data=[
    'C- B+ B- A'.split(),
    'D+ C A C+'.split(),
    'A- A D+ F'.split(),
]
```

for this, ready to put the pieces together and create a `DataFrame`with a `MultiIndex`on both the row and columns axes. In the `DataFrame`constructor, pass our respective `MultiIndex`variable to the `Index`and `Columns`parameters like:

`pd.DataFrame(data, index=row_index, columns=column_index)`

### MultiIndex DataFrames

The neighborhoods.csv -- is similar to the one create -- Here is a preview of the first couple of rows of the raw CSV File -- in a CSV, a comma separates every two subsequent values in a row of data -- the presence of a sequential commas with nothing between them indicates missing values -- like:

Have three unnamed columns, each one just ending in a different number, when importing CSV, pandas assumes that the file’s row holds the colmn names -- Also known as headers -- And if a header slot does not have a value, Pandas just assigns a titile of `Unnamed`to the coolumn -- the library tries to avoiid duplicate columns, just automatically `Unnamed 0...`

Each of the first three columns holds an `NaN`.. The issue is that the CSV is trying to model a multilevel row index and a multilevel column index -- but the default arguments to the `read_csv`function’s parameters doesn’t recognize it -- can solve this problem by just altering the arguments to coupld of `read_csv`parameters like:

Tell Pandas that the 3 leftmost columns should serve as the index of the `DataFrame`-- can do this by passing the `index_col`parameter a list of numbers like:

```python
neighborhoods= pd.read_csv(
    "./chapter_07_multiindex_dataFrames/neighborhoods.csv",
    index_col=[0,1,2]
)
```

Next, need to tell pandas which data set rows we’d like to use for our `DataFrame`'s headers like: The `read_csv`assumes that only the first row will hold the headers, can just set the `header`parameter like:

```python
neighborhoods= pd.read_csv(
    "./chapter_07_multiindex_dataFrames/neighborhoods.csv",
    header=[0,1],
    index_col=[0,1,2]
)
```

## Working with JSON Data

In this, describe the Go stdlib support for the JSON format -- 

- is the de facto std for exchanging data
- Simple enough to supported by any language but can represent realitvely complex data.
- note that the `encode/json`package provides support for encoding and decoding JSON data.
- And not all Go data types can be represented in JSON, which requires the developer to be mindful of how Go data types will be expressed.

### Reading and Writing JSON data

The `encoding/json`package provides support for each encoding and decoding JSON data, as demonstrated in the following, for quick reference, describe the ctor functions that are used to create the structs and decode JSON data.

- `NewEncoder(writer)`-- This function returns an `Encoder`, which can be used to encode JSON data and write it to the specified `Writer`.
- `NewDecoder(reader)`-- this returns a `Decoder`, can be used to read JSON data from the specified `Reader`and decode it.

And the `encoding/json`also provides for encoding and decoding `JSON`without using the `Reader`and `Writer`, fore:

- `Marshal(value)`-- encodes the specified value as JSON, result are the JSON content expressed in a byte slice and an `error`- indicates any encoding problem.
- `Unmarshal(byteSlice, val)`-- parses `JSON`data contained in the specified slice of bytes and assigns the result to the specified value.

### Encoding Json Data

And the `NewEncoder`ctor function is used to create an `Encoder`which can be used to write JSON data to a `Writer`:

- `Encode(val)`-- this encodes the specified value as JSON and writes it to the `Writer`
- `SetEscapeHTML(on)`-- this accepts a `bool`, when `true`, encodes characters that would be dangerous in HTML to be escaped. -- note that the defalut is escape these characters.
- `SetIndent(prefix, indent)`-- this specifies a prefix and indentation that is applied to the name of each field in JSON output.

```go
func main() {
	var b bool = true
	var str string = "Hello"
	var fval float64 = 99.99
	var ival int = 200
	var pointer *int = &ival   // note that just encode to its value and not pointer

	var writer strings.Builder          // A Writer
	encoder := json.NewEncoder(&writer) // note that the &

	for _, val := range []any{b, str, fval, ival, pointer} {
		encoder.Encode(val)
	}
	fmt.Println(writer.String())
}

```

### Encoding Arrays and Slices

Go slices and array are encoded as JSON array, with the exception that `byte`slices are expressed as base-64 encoded strings, byte arrays, however, are encoded as an array of JSON number like:

```go
func main() {
	names := []string{"Kayak", "LifeJacket", "Soccer Ball"}
	numbers := [3]int{10, 20, 30}
	var byteArray [5]byte
	copy(byteArray[0:], []byte(names[0])) // convert to []byte, encoded to base-64 strings
	byteSlice := []byte(names[0])

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	for _, val := range []any{names, numbers, byteArray, byteSlice} {
		encoder.Encode(val)
		fmt.Println(writer.String())
	}
}

```

### Encoding Maps

Go maps are encoded as JSON objects, with the map keys used as object keys, the values contained in the map are just encoded base on their type. like:

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

### Encoding Structs

The `Encoder`expresses struct values as JSON objects, using the exported struct field names as the object’s keys and field values as the object’s values just like:

```go
func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	encoder.Encode(Kayak)
	fmt.Printf(writer.String())
}
```

### Understanding the Effect of Promotion in JSON in Encoding

When a struct defines an embedded field that is also a struct, the fields of the embedded struct are promoted and encoded as though they are defined by the enclosing type.

```go
func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	dp := DiscountedProduct{
		&Kayak, 10.50,
	}
	encoder.Encode(dp) // value, just copy, better to use pointer
	fmt.Printf(writer.String())
}

```

### Customizing the JSON Encoding of Structs

How a struct is encoded can be customized using the *struct tags* which are string literals that follow fields. Sturct tags are just part of the Go support for reflection -- whcih -- but for this it is just enough to know that tags follow fields. Struct tags are part of the Go support for reflection.

```go
type DiscountedProduct struct {
	*Product `json:"product"`
	Discount float64
}
```

The tag specifies the name `product`for the embedded field.

### Omitting a Field

The `Encoder`skips fields decorated with a tag that specifies a hypen `-`for the name like:

```go
type DiscountProduct struct {
    *Product `json:"product"`
    Discount float64 `json:"-"`
}
```

### Omitting Unassigned Fields

By default, the `JSON`encoder includes struct fields, even when they have not been assigned a value like:

```go
dps := DiscountedProduct{Discount: 10.50}
```

For, this, the output is : `{"product":null}`

To omit a `nil`field, the `omitempty`keyword is added to the tag for the field, like:

```go
type DiscountedProduct struct {
    *Product `json:"product,omitempty"`
    Discount float64 `json:"-"`
}
```

The `omitempty`keyword is separated from the field name with a comma but without any spaces. Just like:

```go
type DiscountProduct struct {
    *Product `jsont:",omitempty"`
}
```

For the `Encoder`will promot the `Product`fields if a value has been assigned tot he embedded field and omit the filed if no value has been assigned.

### Forcing Fields to be Encoded as strings

```go
type DiscountedProduct struct {
    *Product `json:",omitempty"`
    Discount float64 `json:",string"`
}
```

### Encoding interfaces

The `JSON`encoder can be used on values assigned to interface variables, but it is dynamic type that is encoded.

```go
type Named interface{ GetName() string }
type Person struct{ PersonName string }

func (p *Person) GetName() string { return p.PersonName }
func (p *DiscountedProduct) GetName() string {
	return p.Name
}
```

This file defines a simple interface and a struct that implements it -- as well as defining a method for the `DiscountProduct`struct so that it implements the interface.

```go
func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	dp := DiscountedProduct{
		&Kayak, 10.50,
	}
	nameItems := []Named{&dp, &Person{PersonName: "Alice"}}
	encoder.Encode(nameItems)
	fmt.Printf(writer.String())
}

```

No aspect of the interface is used to adapt the JSON, and ll the exported fields of each value in the slice are included in the JSON-- This can be a useful feature.

### Creating Completely Cusom JSON Encoding

The `Encoder`checks to see whether a struct implements the `Marshaler`interface -- which denotes a type that has a custom encoding and which defines a method like:

```go
func (dp *DiscountedProduct) MarshalJSON() (jsn []byte, err error) {
	if dp.Product != nil {
		m := map[string]any{
			"product": dp.Name,
			"cost":    dp.Price - dp.Discount,
		}
		jsn, err = json.Marshal(m)
	}
	return
}
```

And the `MarshalJSON()`method can generate JSON in any way that suits the proj, but find the most reliable approach is to use the support for encoding maps.

### Decoding JSON data

The `NewDecoder`ctor function creates a `Decoder`-- which can be used to decode JSON obtained froma `Reader`.

- `Decode(value)`-- the method reads and decodes data, which is used to create the specified value. The method returns an `error`that indicates problems decoding the data tot the required or `EOF`.
- `DisallowUnknownFields()`-- by default, when decoding a struct, the `Decoder`ignores any key in the JSON data for which there is no corresponding struct field. For this, just returns a `error`.
- `UseNumber()`-- by default, the JSON number values are decoded into `float64`values. Calling this method uses the `Number`type instead.

```go
func main() {
	reader := strings.NewReader(`true "Hello" 99.99 200`)
	vals := []any{}
	decoder := json.NewDecoder(reader) // reader no longer need

	for {
		var decodedVal any
		err := decoder.Decode(&decodedVal) // must be pointer note that
		if err != nil {
			if err != io.EOF {
				fmt.Printf("Error: %v\n", err.Error())
			}
			break
		}
		vals = append(vals, decodedVal)
	}
	for _, val := range vals {
		fmt.Printf("Decoded (%T): %v\n", val, val)
	}
}
```

For this, created a `Reader`that will produce data from a string containing a sequence of values, separated by spaces. The first step in decoding the data is to create the `Decoder`, which accepts a `Reader`-- want to decode multiple values, so call the `Decode`method insdie a `for`loop. The `Decoder`is able to select the appropriate Go data type for JSON values, and this is achieved by providing a pointer to an empty interface as arg.

```go
var decodedVal interface{}
err := decoder.Decode(&decodedVal)
```

And the `Decode`method returns an `error`-- which indicates decoding problems but is also used to signal the end of the data using the `io.EOF`error.

### Decoding Number Values

JSON uses a single data type to represent both float and integer values the `Decoder`decodes 3 numeric values as `float64`values, which can be seen in the output from the provious example -- the behavior can be changed by calling the `UseNumber()`on the `Decoder`object -- causes JSON number values to be decoded into the `Number` type.

- `Int64()`-- this returns the decoded value as a `int64`and an `error`that indicates if the value cannot be converted
- `Float64()`-- this returns the decoded value as a `float64`and an `error`that indicates if the value cannot be converted.
- `String()`-- this method returns the unconverted `string`from the JSON data.

The methods are used in sequence, not all JSON number values can be expressed as Go `int64`values.

```go
for _, val := range vals {
    if num, ok := val.(json.Number); ok {
        if ival, err := num.Int64(); err == nil {
            Printfln("Decoded Integer: %v", ival)
        } else if fpval, err := num.Float64(); err == nil {
            Printfln("Decoded floating point: %v", fpval)
        } else {
            Printfln("Decoded string: %v", num.String())
        }
    } else {
        Printfln("Decoded (%T): %v", val, val)
    }
}
```

### Specifying Types for Decoding

The previous examples passed an emtpy interface variable to the `Decode`method like: 

```go
var decodedVal interface{}
err := decoder.Deocde(&decodedVal)
```

This just lets the `Decoder`select the Go data type for the JSON value that is decoded.

```go
func main() {
	reader := strings.NewReader(`true "Hello" 99.99 200`)
	var bval bool
	var sval string
	var fpval float64
	var ival int

	vals := []any{&bval, &sval, &fpval, &ival}

	decoder := json.NewDecoder(reader)

	for i := 0; i < len(vals); i++ {
		err := decoder.Decode(vals[i])
		if err != nil {
			Printfln("Error: %v", err.Error())
			break
		}
	}

	for _, val := range []any{bval, sval, fpval, ival} {
		Printfln("Decoded: (%T): %v", val, val)
	}
}
```

For this, the `Decoder`will return an error if it can’t decode a JSON value into a specified type. This technique should be used only when you are confident that you understand the JSON data that will be decoded.

### Decoding Arrays

The `Decoder`processes arrays automatically, but care must be taken cuz JSON allows arrays to contain values of different types -- which conflicts with the strict type rules enforced by Go.

```go
func main() {
	reader := strings.NewReader(`[10,20,30]["Kayak", "lifejacket", 279]`)
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

The source JSON data contains two arrays, one of which contains only numbers and one of which mixes numbers and strings, the `Decoder`doesn’t try to figure out if a JSON array can be represented using a single Go type and decodes every array into an empty interface slice.

If you know the structure of the JSON data, but the type of the slice the empty inteface, if you know the structure of the JSON data in advanced and you are decoding an array containing a single JSON data type.

```go
func main() {
	reader := strings.NewReader(`[10,20,30]["Kayak", "lifejacket", 279]`)
	ints := []int{}
	mixed := []any{}
	vals := []any{&ints, &mixed}

	decoder := json.NewDecoder(reader)

	for i := 0; i < len(vals); i++ {
		err := decoder.Decode(vals[i])
		if err != nil {
			Printfln("Error: %v", err.Error())
			break
		}
	}
	Printfln("Decoded (%T): %v", ints, ints)
	Printfln("Decoded (%T): %v", mixed, mixed)
}
```

Can specify an `int`slice to decode the first array in the JSON data cuz all the values can be represented as `Go`int values. The second array contains a mix of values, which means that I have to specify the empty interface as the target type.

### Decoding Maps

Js objects are expressed as k-v pairs, which makes it easy to decode them in Go maps as show like:

```go
func main() {
	reader := strings.NewReader(`{"Kayak":279, "Lifejacket":49.95}`)
	m := map[string]any{}
	decoder := json.NewDecoder(reader)

	err := decoder.Decode(&m)
	if err != nil {
		Printfln("Error: %v", err.Error())
	} else {
		for k, v := range m {
			Printfln("Key: %v, value: %v", k, v)
		}
	}
}
```

And a single JSON object can be used for multiple data types as valus -- if know in advance that you will be decoding a JSON object that has a single value type, can be more specific when defining the map into which data will be decoded just like: `m := map[string]float64{}`

### Decoding Structs

The k-v structure of JSON objects can be decoded into Go struct values.

```go
func main() {
	readers := strings.NewReader(`
{"Name":"Kayak","Category":"Watersports","Price":279}
{"Name":"Lifejacket","Category":"Watersports" }
{"name":"Canoe","category":"Watersports", "price": 100, "inStock": true }
`)
	decoder := json.NewDecoder(readers)
	for {
		var val Product
		err := decoder.Decode(&val)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		} else {
			Printfln("Name: %v, Category: %v, Price: %v",
				val.Name, val.Category, val.Price)
		}
	}
}
```

### Disallowing Unused Keys

By default, the `Decoder`will ignore the JSON keys for which there is no corresponding struct field, this behaviro can be changed by calling the `DisallowUnknownFields`method like:

`decoder.DisallowUnknownField()`

Using the Struct tags to control Decoding -- The keys used in a JSON object don’t always align with the fields defined by the struct in a Go project -- when this happens, struct tags can be used to map between the JSON and the struct:

```go
type DiscountedProduct struct {
	*Product `json:",omitempty"`
	Discount float64 `json:"offer,string"`
}

func main() {
	reader := strings.NewReader(`
	{"Name":"kayak", "Category":"Watersports", "Price":279, "Offer":"10"}
`)
	decoder := json.NewDecoder(reader)
	for {
		var val DiscountedProduct
		err := decoder.Decode(&val)
		if err != nil {
			if err != io.EOF {
				Printfln("Error :%v", err.Error())
			}
			break
		} else {
			Printfln("Name:%v, Category: %v, Price: %v, Discount:%v",
				val.Name, val.Category, val.Price, val.Discount)
		}
	}
}

```

### Creating completely custom JSON decoders

The `Decoder`checks to see whether a struct implements the `Unmarshaler`interface -- like:

```go
unc (dp *DiscountedProduct) UnmarshalJSON(data []byte) (err error) {
	mdata := map[string]any{}
	err = json.Unmarshal(data, &mdata)

	if dp.Product == nil {
		dp.Product = &Product{}
	}
	if err == nil {
		if name, ok := mdata["Name"].(string); ok {
			dp.Name = name
		}

		if category, ok := mdata["Category"].(string); ok {
			dp.Category = category
		}
		if price, ok := mdata["Price"].(float64); ok {
			dp.Price = price
		}
		if discount, ok := mdata["Offer"].(string); ok {
			fval, fperr := strconv.ParseFloat(discount, 64)
			if fperr == nil {
				dp.Discount = fval
			}
		}
	}
	return
}
```

This implementation of the `UnmarshalJSON()`method uses the `Unmarshal`method to decode the JSON data into a map and then checks the type of each value required for the `DiscountedProduct`struct.