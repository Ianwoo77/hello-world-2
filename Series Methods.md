# Series Methods

```python
pd.read_csv('pokemon.csv')
```

The `read_csv`function always imports the data into a `DataFrame`-- a 2D pandas DS. Issue is that the data set has two columns -- but a Series only supports one column of data. One simple sultion is that setting one of the data set’s columns as the `Series`index. Use the `index_col`parameter to set the index column. like:

```python
pd.read_csv('pokemon.csv', index_col='Pokemon') # also a DataFrame
# using the squeeze parameter coerces it
pd.read_csv('pokemon.csv', index_col='Pokemon').squeeze()
```

The output below the values reveals some important details -- 

- Pandas has assigned the `Series`a anme of Type, the column’s name from the CSV file
- `dtype:object`tells us tha it’s a `Series`of string values.

```python
pokemon = pd.read_csv('pokemon.csv', index_col='Pokemon').squeeze()
# the remaining two data sets carry some dadditional complexity like:
pd.read_csv('google_stocks.csv').head()
```

When importing a data set, pandas just infers the most suitable data type for each column. And sometimes, the library plays it safe and avoids making assumptions about our data. Can explicitly tell pandas to convert the values in the Date column to datetimes. just like:

```python
pd.read_csv('google_stocks.csv', parse_dates=['Date']).head()
```

There is no visual difference in the output, but pandas is stroing a different data type for the `Date`column under the hood. Then like:

```python
pd.read_csv('google_stocks.csv', parse_dates=['Date'], 
            index_col='Date').squeeze().head()
pd.read_csv('revolutionary_war.csv', index_col='Start Date', 
           parse_dates=['Start Date']).squeeze().tail()
```

By default, the `read_csv`imports all columns from a CSV -- will have to limit the import to two columns, if we want a `Sereis`-- The `squeeze()`is insufficient in this scenario. 

```python
# read_csv's usecols parameter accepts a list of columns that pandas should import like:
pd.read_csv(
    "revolutionary_war.csv",
    index_col="Start Date",
    parse_dates=["Start Date"],
    usecols=["State", "Start Date"],
).squeeze().tail()
```

### Sorting a Series

Can store a series by its value or its index -- like -- `sort_values()`method -- the `sort_values`returns a new `Series`with the values sorted in ascending order. 

```python
google.sort_values()
pokemon.sort_values(ascending=False).head()
```

The `ascending`sets the sort order. A descending will arrange a `Series`of strings in reverse alphabetical order. Note that the `na_position`parameter configures the placement of `NaN`values in the returned `Series`and has a default argument of `last`. can: `battles.sort_values(na_position='first')`

Also remove the `NaN`values -- like: `battles.dropna().sort_values()`

#### Sorting by index with `sort_index()`

Like `sort_values()`, the `sort_index()`accepts an `ascending`parameter like:

```python
pokemon.sort_index()
pokemon.srot_index(ascending=True)
# also includes the na_position parameter like:
battles.sort_index(na_position="first").head()
```

#### Retrieving the smallest and largest values with the nsmallest and nlargest methods

```python
google.nlargest(n=5) # google.nlargest()
```

### Couting values with the `value_counts()`method

How can find out the most common types of Pokemon -- Need to *group* the values into buckets and count the number of elements in each bucket -- The `value_counts()`method -- which counts the number of occurrences of each `Series`value -- solve the problem like:  `pokemon.value_counts()`

The `value_counts()`returns a new `Series`object -- the index labels are the pokemon Series’ values, and the values are their repective counts. And the length of the `value_counts()`is equal to the number of unique values in the Series. `len(pokemon.value_counts())`=== `pokemon.nunique()`

Note that the `value_counts()`'s `ascending`has a default argument of `False`-- Can also:

```python
pokemon.value_counts(ascending=True)
```

## Interface on the producer side

- *Producer side* -- An interface defined in the same package as the concrete IMP
- *Consumer side* -- An interface defined in an external package where it’s used.

It’s common to see developers creating interfaces on the producer side, alongside the concrete IMP. This design is perhaps a habit  from developers having a C# background. But in Go, in most cases this is not what we should do. fore:

```go
package store
type CustomerStorage interface {
    StoreCustomer(customer Customer) error
    Get Customer(id string) (Customer, error)
    UpdateCustomer(customer Customer) error
    GetAllCustomers() ([]Customer, error)
    //...
}
```

Interfaces are satisfied implicitly in Go -- which tends to be a game-changer compared to language with an explicit IMP -- In most cases, the approach to follow is similar to what desired in the previous -- *abstractions should be discovered, not created*. This means that it’s not up to the producer to force a given abstraction for all the clients. Instead, it’s up to the client to decide whether it needs some form of abstraction and then determine the best abstraction leel for its needs. Fore: Another client wants to decouple its code but is only interested in the `GetAllCustmoers()`-- this client can create an interface with a single method:

```go
package client
type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

- Cuz the `customersGetter`is only used in the `client`package, can remain unexported.
- There is no dependency from `store`to `client`cuz the interface is satisfied implicitly.

The main point is that the `client`package can now define the most *accurate* abstraction for its need -- it relates to the concept of the *Interface-Segregation* principle. Which states that no client should be forced to depend on methods it doesn’t use. Therefore, in this case, the best approach is to expose the concrete IMP on the producer side and let the client decide how to use it and whether an abstraction is needed.

Fore, the `encoding`package defines interfeaces and implemented by the other sub-packages such as `encoding/json`or `encoding/binary`. In this case, the abstractions defined in the `encoding`package are used across the stdlib, and the language designer knew that creating these abs up front was valuable.

### Returning Interfaces

While designing a function signature, may have to return either an interface or a concrete IMP -- Understand why returning an interface is -- in many cases, *considered a bad practice* in Go -- just presented why interfaces live -- in general on the consumer side. FORE:

- `client`-- contains a `Store`interface
- `store`-- contains the IMP of `Store`

Fore, in the `store`package, define an `InMemoryStore`struct that just implements the `Store`interface, meanwhile, create a `NewInMemoryStore`func to return a `Store`interface. So there is a dependency from the IMP package to the client package in this design.

The `client`package can’t call the `NewInMemoryStore()`anymore -- there would be a cycle dependency. A possible solution could be to call this function from another package and to inject a `Store`imp to `client`. What happens if another client uses the `InMemoryStore`struct. Would like to move the `Store`to another package, or back to the imp.

In general, returning an interface restricts flexibility cuz force all the clients to use one particular type of abstraction. So:

- Returning structs instead of interfaces
- Accepting interfaces if possible.

### `any`says nothing

In Go, an interface type that specifies zero methods is known as the empty interfce `interface{}, any`. An `any`type can hold any value type like:

```go
func main(){
    var i any
    i = 42
    i = "foo"
    i = struct {
        s string
    }{
        s: "bar"
    }
    i = f
    _ = i
}
```

Note that in assigning a value to an `any`type, we lose all type info -- which requires a type assertion to get anything useful out of the `i`variable. fore:

```go
type Customer struct{...}
type Contract struct {...}
type Store struct {}
func (s *Store) Get(id string) (any, error) {...} // returns any
func (s *Store) Set(id string, v any) error {...} // accepts any
```

Cuz accept and return `any`arguments, the methods lack expressiveness. Hence, accepting or returning an `any`type doesn’t convey meaningful info. By using `any`lose some of benefits of Go as a statcially language. 

Then, what are the cases when `any`is just helpful -- For stdlib, the `encoding/json`package -- like:

```go
func Marshal(v any) ([]byte, error) {...}
// another in the database/sql package.
func(c *Conn) QueryContext(ctx context.Context, query string, args ...any) (*Rows, error) {...}
```

In summary, `any`can be helpful if there is a genuine need for accepting or returning any possible type.

## Working with JSON Data

The `encoding/json`package provides support for encoding and decoding JSON data -- as demonstrated -- 

- `NewEncoder(writer)`-- This function returns a `Encoder`, which can be used to encode JSON data and write it to the specified `writer`
- `NewDecoder(reader)`-- returns a `Decoder`-- which can be used to read JSON data from the specified `Reader`and decode it.

And the `encoding/json`also provides 

- `Marshal(value)`-- encodes the specified value as JSON, the results are the JSON content
- `Unmarshal(byteSlice, val)`-- parses JSON data contained in the specified slice of bytes and assigns the result to the specified value.

### Encoding JSON data -- 

The `NewEncoder`ctor is used to create an `Encoder`, which can be used to write JSON data to a writer, then using the method on it like: `Encode(val)`-- encodes the specified value as JSON.

- `float32 float64`-- expressed as JSON numbers
- byte, rune, unit, int -- numbers
- `nil`-- expressed as the JSON `null`value
- `Pointers`-- encoder follows pointers and encodes the value at the pointer’s location.

```go
func main() {
	var b bool = true
	var str string = "Hello"
	var fval float64 = 99.99
	var ival int = 200
	var pointer *int = &ival // also 200

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	for _, val := range []any{b, str, fval, ival, pointer} {
		encoder.Encode(val)
	}
	fmt.Println(writer.String())
}
```

#### Encoding Arrays and Slices

Go slices and arrays are encoded as JSON arrays, with the exception that `byte`slices are expressed as base64-encoded string. Byte Arrays, are encoded as an array of JSON numbers. like:

```go
func main() {
	names := []string{"kayak", "lifejacket", "soccer ball"}
	numbers := [3]int{10, 20, 30}
	var byteArray [5]byte
	copy(byteArray[0:], []byte(names[0]))
	byteslice := []byte(names[0])

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)

	encoder.Encode(names)
	encoder.Encode(numbers)
	encoder.Encode(byteArray)
	encoder.Encode(byteslice) // base64 encoded string
	fmt.Println(writer.String())
}
```

#### Encoding Maps

Go maps are encoded as JSON objects, with the map keys used the object keys, the values contained in the map are encoded based on their type. like:

```go
func main(){
    m := map[string]float64 {
        "Kayak": 279,
        "Lifejacket": 49.95,
    }
    var writer strings.Builder
    encoder := json.NewEncoder(&writer)
    encoder.Encode(m)
    fmt.Print(writer.String())
}
```

#### Encoding Structs

The `Encoder`expresses struct values also as JSON objects, using the **exported** struct field names as the object’s keys and the field values as the object’s values.

```go
func main(){
    var writer strings.Builder
    encoder := json.NewEncoder(&writer)
    encoder.Encode(Kayak)
}
```

### The Effect of Promotion in Json in Encoding

When a struct defines an embedded field that is also a struct, the fields of embedded struct are promoted an encoded as though they are defined by the enclosing type. Like:

```go
type DiscountedProduct struct {
    *Product
    Discount float64
}

func main() {
    var writer strings.Builder
    encoder := json.NewEncoder(&writer)
    dp := DiscountProduct {
        Product: &Kayak,
        Discount: 10.50,
    }
    encoder.Encode(&dp) // follows the pointer and encodes the value at its location
}
```

And, if there is not promotion, just:

```go
type product struct {
	Name string
}

type DiscountProduct struct {
	Product  *product
	Discount float64
}

func main() {
	dp := DiscountProduct{
		Product:  &product{Name: "kayak"},
		Discount: 10.50,
	}

	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	encoder.Encode(&dp)
	fmt.Println(writer.String()) // {"Product":{"Name":"kayak"},"Discount":10.5}
}
```

### Customizing the JSON Encoding of Structs -- 

How a struct is encoded can be customized using *struct tags* -- whcih are string literals that follow fields. Struct tags are part of the Go support for reflection. Like:

```go
type DiscountProduct struct {
	*product `json:"product"`
	Discount float64
}
```

So the struct tag follows a specific format, the term `json`followed by a colon, followed by the name that should be ued when the field is encoded, enclosed in double quotes.

Omitting a Field -- like:

```go
type DiscountedProduct struct {
    Discount float64 `json:"-"`
}
// omitting unassigned fields
type DiscountedProduct struct {
    *Product `json:"product,omitempty"` // or ",omitempty"
}
// forcing to be encoded as strings
type DiscountedProduct struct {
    Discount float64 `json:",string"`
}
```

#### Encoding Interfaces

The JSON encoder can be used on values assigned to interface variables, but it is dynamic type that is encoded.

```go
type Named interface {
	GetName() string
}

type Person struct{ PersonName string }

func (p *Person) GetName() string          { return p.PersonName }
func (p *DiscountProduct) GetName() string { return p.Name }

func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	dp := DiscountProduct{
		&product{"kayak"},
		10.50,
	}
	namedItems := []Named{&dp, &Person{PersonName: "Alice"}}
	encoder.Encode(namedItems)
	fmt.Println(writer.String())
}
```

The slice of `Named`values contain different dynamic types, which can be seen. All the exported fields of each value in the slice are included in the JSON.

### Creating Completely Custom JSON encoding

The `Encoder`checks to see whether a struct implements the `Marshaler`interface -- which denotes a type that has a custom encoding and which defines the method -- `MarshalJSON()`-- invoked to create a JSON representation of a value and returns a byte slice containing the JSON and an `error`indicating encoding problems.

```go
func (dp *DiscountProduct) MarshalJSON() (jsn []byte, err error) {
	if dp.product != nil {
		m := map[string]any{
			"product": dp.Name,
			"cost":    dp.Discount,
		}
		jsn, err = json.Marshal(m)
	}
	return
}
```

The `MarshalJSON()`method can generate JSON in any ways that suits the proj. Most reilable approach is to use the support for encoding maps.