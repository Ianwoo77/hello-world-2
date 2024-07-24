# Similarities between Series and DFs

Many `Series`attributes and methods are also available on DF. Their imp can vary, pandas must account for multiple columns and two separate *axes* now. Before assign the `DataFrame`object to a variable, make one optimization -- Pandas imports the `Birthday`column values as strings rather than as datetimes.

`nba = pd.read_csv('nba.csv', *parse_dates*=['Birthday'])`

### Shared and exclusive attributes of Series and DataFrames

Attributes and methods may differ between `Series`and `DataFrame`. A `Series`has a `dtype`attribute that reveals the data type of its values. A `DataFrame`can hold heterogenous data -- mixed or varied.

```python
nba.dtypes # columns dtypes
nba.dtypes.value_counts()
# consists of several smaller objects 
nba.index # RangeIndex object returned
nba.columns # columns attribute
nba.ndim # 2
nba.shape # (450, 5)
nba.sie # 2250 calculates the total number of values

# exclude missing values
nba.count()
nba.count().sum() # 2250

# can acces nan as a top-level attribute
data = {
    "A": [1, np.nan],
    "B": [2,3]
}
df = pd.DataFrame(data)
df.size # 4
df.count() # A 1 - B 2
df.count().sum() # 3 columns that contains nan ignored
```

#### Shared methods of Series and DFs

have methods in common too -- can use the `head`fore:

```python
nba.head(2)
nba.tail(n=3)
nba.smaple(3) # extract random rows from the DataFrame
nba.nunique() # count number of unique values in a Series
nba.max() # returns series with the maximum from each column
nba.nlargest(n=4, columns="Salary") # pass the number and columns , must use columns parameter
nba.sum(numeric_only=True)
nba.mean(numeric_only=True)
```

### Sorting a DataFrame

```python
# The two equivalent
nba.sort_values("Name")
nba.sort_values(by="Name") # ascending default to True
nba.sort_values("Name", ascending=False).head()
nba.sort_values("Birthday", ascending=False).head()
```

#### Sorting by multiple columns

Can also sort multiple columns in a DF by passing a list to the `sort_values()`method’s `by`parameter. Pandas will sort the `DataFrame`'s columns consecutively in the order in which they appear in the list.

```python
nba.sort_values(by=['Team', 'Name'])
# pass a single Boolean to the ascending or passing multiple booleans
nba.sort_values(by=['Team', 'Name'], ascending=[True, False])
```

### Sorting by Index

Our DF still has its numeric index -- if could sort the data set by index positions rather then by column values, could return it to its original shape. The `sort_index()`does just like:
`nba.sort_index(ascending=False).head()` nba= nba.sort_index()

#### Sorting by column index

```python
nba.sort_index(axis='column').head()
nba.sort_index(axis=1, ascending=False).head()
```

### Setting a new index

At its core, our data set is just a collection of players. Therefore, it seems fitting to use the `Name`column’s values as the `DataFrame`index labels. The `set_index()`returns a new DF with a given column set as the index.

```python
nba.set_index(keys='Name')
```

### Selecting Columns and rows from a DF -- 

A `DataFrame`is a collection of `Series`objects with a common index. Each `Series`column is available as an attribute on the `DataFrame`-- use dot can `nba.Salary`, can also `nba['Position']`.

Selecting multiple columns froma DF -- To extract multiple columns like:
`nba[['Salary', 'Birthday']]`

Note, can also use the `select_dtypes()`method to select columns based on their data types -- the method accepts two parameters -- `include`and `exclude`-- the parameters accept a single string or a list, representing the column types. Like: `nba.select_dtypes(include='object')` or `nba.select_dtypes(exclude=['object', 'int'])`

## Functional options Pattern

When designing an API, one question may arise -- how do we deal with *optional* configuration -- Solving this problem efficiently can improve how convenient our API will become -- This goes through a concrete example and convers different ways to handle optional configurations -- Fore, design a library that exposes a function to create an HTTP Server, this function would accept different inputs -- an address and a port -- 

`func NewServer(addr string, port int) (*http.Server, error)`

The clients of lib have started to use this func -- at some point, our clients begin to complain that this func is somewhat limited and lacks other parameters. However, noticed that adding new function parameters breaks the compability.

### Config Struct

Note, Go doesn’t support optional parameters in function signatures, the first possible approach is to use a configuration struct to convey what’s mandatory and what is optional. FORE, the mandatory parameters could live as function parameters, whereas the optional parameters could be handled in the `Config`struct like:

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config) {...}
```

This approach doesn’t solve our requirement related to port management. In our case, need to find a way to distinguish between a port purposely set to 0 and a missing port. In Go, the functional optional pattern is a way to handle values that may or may not be present, just similar to the `Optional`type in languages like Java. Since Go doesn’t have built-in support for this pattern, developers often use custom types and functions to acheive similar behavior.

```go
type Optional[T any] struct {
	value     T
	isPresent bool
}

// New creates a new Optional containing the given value
func New[T any](value T) Optional[T] {
	return Optional[T]{value, true}
}

// Empty creates an empty Optional
func Empty[T any]() Optional[T] {
	var zero T
	return Optional[T]{zero, false}
}
```

Methods to handle the optional value -- implements methods to interact with the optional value. And for the previous, perhaps one option might be to handle all the parameters of the configuration struct as pointers in this way like:

```go
type Config struct {
    Port *int
}
```

Using an integer pointer here, semantically, can highlight the difference between the value 0 and a missing value. This option works, but -- not handy for clients to provide an integer pointer like:

```go
port := 0
config := httplig.Config{
    Prot: &port, // provides an integer pointer
}
```

Overall API beomes a bit less convenient to use. Andalso a client using our lib with the default configuration will need to pass an empty struct this way -- like:

`httplib.NewServer("localhost", httplib.Config{})`

#### Builder Pattern

Originally part of the Gang of Four design patterns - the builder pattern provides a flexible solution to various object -- creation problems, the constuction of `Config`is separated from the struct itself. It requires an extra struct, `ConfigBuilder`which receives methods to configure and build a `Config`.

Is a creation design pattern used to construct complex objects step by step. It separates the consturction of an object from its representation, allowing the same construction process to create different representations. This pattern is particularly useful when the creation of an object involves multiple steps or configurations.

Components -- 

1. Product -- The complex object being constructed
2. Builder Interface -- An interface that defines the methods for creating different parts of the `Product`
3. Concrete builder -- Imp the Builder interface and provides specific imp for cton process.
4. Director -- constructs the object using builder interface.

See a concrete example and how it can help us in designing a friendly API that tackles all our requirements -- 

```go
type Config struct {
	Port int
}

type ConfigBuilder struct { // config builder struct holding an optional port
	port *int
}

func (b *ConfigBuilder) Port(port int) *ConfigBuilder {
	b.port = &port
	return b
}

func (b *ConfigBuilder) Build() (Config, error) {
	cfg := Config{}
	if b.port == nil {
		cfg.Port = 0
	} else {
		if *b.port == 0 {
			cfg.Port = rand.Intn(65536)
		} else if *b.port < 0 {
			return Config{}, errors.New("port should be positive")
		} else {
			cfg.Port = *b.port
		}
	}
	return cfg, nil
}
```

For the `ConfigBuilder`struct holds the client configuration, it exposes a `Port`method to set up the port. Usually, such a configuration method returns the builder itself so that we an use method chaining. Also exposes a `Build`method that holds the logic on initializing the port value and returns a `Config`struct once created.

A client would use our builder-based API in the following manner like:

```go
builder := httplib.ConfigBuilder{}
builder.Port(8000)
cfg, err := builder.Build()
if err != nil {
    return err
}
server, err := httplib.NewServer("localhost", cfg)
if err != nil {
    return err
}
```

This approach makes port management handier. It’s not required to pass an integer pointer, as the `Port`method accepts an integer. However, still need to pass a config struct that is empty if client want to use default:

`server, nil := httplib.NewServer("localhost", nil)`

And another downside, in some situations, is related to error management -- in programming languages where exceptions are thrown, builder methods such as `Port`can raise exceptions if the input is invalid.

### Functional options pattern

In go is a design pattern that provides an idiomatic way to set optional parameters for structs or functions, especially when they have numerious optional configurations. It leverages first-class functions and colosures to configure objects in a flexible and readable manner.

1. Options Type -- typically a struct that holds configuration values.
2. Option Functions -- take a pointer to the Options type and modify it.
3. Functional Options -- Functions that return an Option function.

```go
type Server struct {
	Hostname, Protocol string
	Port, Timeout      int
}

type Option func(*Server)

func WithHostname(hostname string) Option {
	return func(s *Server) {
		s.Hostname = hostname
	}
}

func WithPort(port int) Option {
	return func(s *Server) {
		s.Port = port
	}
}

func WithProtocol(protocol string) Option {
	return func(s *Server) {
		s.Protocol = protocol
	}
}

func WithTimeout(timeout int) Option {
	return func(s *Server) {
		s.Timeout = timeout
	}
}

func NewServer(options ...Option) *Server {
	server := &Server{
		Hostname: "localhost", Port: 8080, Protocol: "http", Timeout: 30,
	}
	for _, option := range options {
		option(server)
	}
	return server
}

func main() {
	server := NewServer(
		WithHostname("example.com"),
		WithPort(443),
		WithProtocol("https"))
	fmt.Println(server)
}
```

- An unexported struct holds the configuration `options`
- Each option is a function that returns the same type `type Option func(options *options) error`

## Decoder

The first step in decoding the data is to create the `Decoder`which accepts a `Reader`-- want to decode multiple values, so call the `Decode`inside a `for`.

```go
var decodedVal any
err := decoder.Decode(&decodedVal)
```

And the `Decode`method returns an error, which indicates decoding problems but is also used to signal the end of the data using the `io.EOF`error. like:

```go
for {
    var decodedVal any
    err := Decode(&decodeVal)
    if err != nil {
        if err != io.EOF {
            Printfln("error: %v", err.Error())
        }
        break
    }
    vals = append(vals, decodedVal)
}
```

### Decoding Number Values

JSON uses a single data type to represent both float-point and integer values. The `Decoder`decodes these numeric values as `float64`value, which can be seen in the output from the previous example.

This behavior can be changed by calling `UseNumber()`on the `Decoder`, which causes JSON number values to be decoded into `Number`type, defined in the `encoding/json`package.The `Number`type defines the methods like:

- `Int64()`-- returns the decoded value as a `int64`and an `error`that indicates if the vlaue cannot be converted.
- `Float64()`-- returns the decoded value as a `float64`
- `String()`-- returns the unconverted `string`

```go
func main() {
	reader := strings.NewReader(`true "Hello" 99.99 200`)
	vals := []any{}
	decoder := json.NewDecoder(reader)
	decoder.UseNumber() // note that
	for {
		var decodedVal any
		err := decoder.Decode(&decodedVal)
		if err != nil {
			if err != io.EOF {
				fmt.Printf("Error: %v\n", err.Error())
			}
			break
		}
		vals = append(vals, decodedVal)
	}

	for _, val := range vals {
		if num, ok := val.(json.Number); ok {
			if ival, err := num.Int64(); err == nil {
				fmt.Printf("Decoded Integer: %v\n", ival)
			} else if fpval, err := num.Float64(); err == nil {
				fmt.Printf("Decoded floating point: %v\n", fpval)
			} else {
				fmt.Printf("Decoded string: %v\n", num.String())
			}
		} else {
			fmt.Printf("Decoded (%T): %v\n", val, val)
		}
	}
}
```

#### Sepcifying Types for Decoding

The previous example passes an empty interface variable to the `Decode`method like: 
`_ := decoder.Decode(&decodedVal)`

This lets the Decoder select the Go data type for the JSON value that is decoded. And if U know the structure of the JSON data you are decoding, U can direct the `Decoder`to use specific Go types by using variables like:

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
			fmt.Printf("Error: %v\n", err.Error())
			break
		}
	}

	fmt.Printf("Decoded (%T): %v\n", bval, bval)
	fmt.Printf("Decoded (%T): %v\n", sval, sval)
	fmt.Printf("Decoded (%T): %v\n", fpval, fpval)
	fmt.Printf("Decoded (%T): %v\n", ival, ival)
}
```

#### Decoding Arrays

The `Decoder`processes arrays automatically, but care must be taken cuz JSON allows arrays to contain values of different types, which conflicts with the strict type rules.

```go
func main() {
	reader := strings.NewReader(`[10,20,30]["kayak","Lifejacket",279]`)
	vals := []any{}
	decoder := json.NewDecoder(reader)
	for {
		var decodedVal any
		err := decoder.Decode(&decodedVal)
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

For this, the source JSON data contains two arrays, one of which contains only numbers and one of which mixes numbers and strings. The `Decoder`doesn’t try to figure out if a JSON array can be represented using a single Go type. Each value is typed based on the JSON value, but the type of the slice is the empty interface. If U know the structure of the JSON data in advantage you are decoding an array containing a single JSON data type, can:

```go
func main() {
	reader := strings.NewReader(`[10,20,30]["kayak","Lifejacket",279]`)

	ints := []int{}
	mixed := []any{}
	vals := []any{&ints, &mixed}
	decoder := json.NewDecoder(reader)
	for i := 0; i < len(vals); i++ {
		err := decoder.Decode(vals[i])
		if err != nil {
			fmt.Printf("Error: %v\n", err.Error())
			break
		}
	}

	fmt.Printf("Decoded (%T): %v\n", ints, ints)
	fmt.Printf("Decoded (%T): %v\n", mixed, mixed)
}
```

#### Decoding Maps

Js objects are expressed as k-v pairs, which makes it easy to decode them in Go maps, as like:

```go
func main() {
	reader := strings.NewReader(`{"Kayak": 279, "Lifejacket": 49.95}`)
	m := map[string]any{}
	decoder := json.NewDecoder(reader)
	err := decoder.Decode(&m)
	if err != nil {
		fmt.Printf("Error: %v\n", err.Error())
	} else {
		fmt.Printf("Map: %T, %v\n", m, m)
		for k, v := range m {
			fmt.Printf("Key: %v, value: %v\n", k, v)
		}
	}
}
```

And, a single JSOn object can be used for multiple types as values. Like:
`m := map[string]float64{}`

#### Decoding structs

The k-v structure of JSON objects can be decoded into Go struct values.

```go
unc main() {
	reader := strings.NewReader(`
	{"Name":"Kayak","Category":"Watersports","Price":279}
	{"Name":"Lifejacket","Category":"Watersports" }
	{"name":"Canoe","category":"Watersports", "price": 100, "inStock": true }
`)

	decoder := json.NewDecoder(reader)
	for {
		var val Product2
		err := decoder.Decode(&val)
		if err != nil {
			if err != io.EOF {
				fmt.Printf("Error: %v", err.Error())
			}
			break
		} else {
			fmt.Printf("Name: %v, Category: %v, Price: %v\n",
				val.Name, val.Category, val.Price)
		}
	}
}
```

#### Disallowing Unused Keys

By default, the `decoder`will ignore JSON keys for which there is no corresponding struct field. this can be changed by calling the `DisallowUnknownFields()`method like:

```go
decoder := json.NewDeoder(reader)
decoder.DisallowUnknownFields() // Error: json: unknown field "inStock"
```

#### Using struct tags for controling Decoding

The keys used in a JSON object don’t always with the fields defined by the structs in a Go project.

```go
type DiscountProduct2 struct {
	*Product2 `json:",omitempty"`
	Discount float64 `json:"offer,string"`
}
```

The tag applied to this tells the `Decoder`that the value for this field should be obtained from the JSON key named `offer`and that the value will be parsed from a string.

#### Completely Custom JSON Decoders

The `Decoder`checks to see whether a struct implements the `Unmarshaler`interface, which denotes a type that has a custom decoding -- 

- `UnmarshalJSON(byteslice)` -- is invoked to decode JSON data contained in the specified byte slice.

```go
func (dp *DiscountProduct2) UnmarshalJSON(data []byte) (err error) {
	mdata := map[string]any{}

	// parse data and store to mdata
	err = json.Unmarshal(data, &mdata)
	if dp.Product2 == nil {
		dp.Product2 = &Product2{}
	}
	if err == nil {
		if name, ok := mdata["name"].(string); ok {
			dp.Name=name
		}
	}
	//...
	return 
}
```

This IMP of the `UnmarshalJSON()`uses the `Unmarshal`method to decode the JSON data into a map and then checks the type of each value required for the struct.