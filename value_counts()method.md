# `value_counts()`method

```python
pokemon.value_counts()
```

Counts the number of occurrences of each `Series`value, solves the problem perfectly. And the `value_counts()`method returns a new `Series`object. The index labels are the pokemon `Series`'s values, and the value are their respective counts. So:

```python
len(pokemon.vlaue_counts())
pokemon.nunique() # both 159
```

Note that the `value_counts()`'s `ascending`parameter has a default argument of `False`.

May be more interested in the ratio of type relative to all the types. `normalize`parameter to `True`to return the frequencies of each unique value. like:

```python
pokemon.value_counts(normalize=True).head()*100
```

And, wanted to limit the precision of the percentages -- can round a `Series`'s values with the `round`method. The method’s first parameter -- `decimals`sets the number of digits to leave after the decimal point.

```python
(pokemon.value_counts(normalize=True).head()*100).round(2)
# to identify trends in numeric data sets, can be more benefitical to group values into predefined 
# intervals like max and min
google.max()
google.min()
```

Say, have a range can define these intervals values in a *list* and pass the list to the `value_counts()`, `bins`parameter: like:

```python
buckets = [0, 200, 400, 600, 800, 1000, 1200, 1400]
google.value_counts(bins=buckets) # note that the (first, last]
```

Note that pandas sorted the previous in descending order by the number values. So can:

```python
google.value_counts(bins=bucket).sort_index()
google.value_counts(bins=bucket, sort=False)
# bins parameter also accepts an integer argument, automatically calculate the difference between max and min
google.value_counts(bins=6, sort=False)
```

Pandas will exclucde the `NaN`values from the `value_counts`Series by default, Pass the `dropna`parameter an argument of `False`to count `null`values as a distinct category like:

```python
battles.value_counts(dropna=False).head()
battles.index.value_counts() # dates had the most battles during war
```

### Invoking a function on every Series value with the `apply`

The `apply`method expects the function it will invokes as its first parameter, `func`, like:

```python
google.apply(round)
# accepts custom functions
# accepts a single parameter return the value pandas to store
pokemon.apply(lambda pt: "Multi" if "/" in pt else "Single").value_counts()
```

## The `DataFrame`objects

Two-dimensional table of data with rows and columns. 

#### Creating from a dictionary

The ctor’s first parameter, `data`expects the data that will populate the `DataFrame`. One suitable input is a Python dictionary in which the keys are column names and the values are column values. like;

```python
city_data = {
    "City": ["New York City", "Paris", "Barcelona", "Rome"],
    "Country": ["United States", "France", "Spain", "Italy"],
    "Population": [8600000, 2141000, 5515000, 2873000],
} # str: list str is column names and list is row
cities= pd.DataFrame(city_data)
```

Pandas generated a numeric one starting at 0. The logic operates the same way as series. A DataFrame can hold multiple columns of data.

```python
cities.transpose()
cities.T
```

For this, as a reminder that pandas can store index labels of different data types.

#### Creating a DF from a Numpy ndarray

The DF ctor’s `data`can also accept a NumPy `ndarray`-- can generate an `ndarray`of any size with the `randint`func:

```python
import numpy as np
random_data = np.random.randint(1, 101, [3, 5])
pd.DataFrame(random_data)
```

Can manually set the row labels with the `DataFrame`ctor’s `index`parameter, accepts any iterable object, including a list, tuple, ndarray. like:

```python
row_labels=['Morning', 'Afternoon', 'Evening']
temp = pd.DataFrame(random_data, index=row_labels)
temp
# can also set the column names with `columns` parameter like:
column_labels = ["Monday", "Tuesday", "Wednesday", "Thursday" ,"Friday"]
temp = pd.DataFrame(random_data, index=row_labels, columns=column_labels)
temp
```

And, pandas permists duplicates in the rwo and column indicies.

## Being confused about when to use generics

Go 1.18 adds generics to the language -- in a nutshell, this allows writing code with types that can be specified late and instantiated when needed. However, it can be confusing about when to use generics when not to.

#### concepts

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k := range m {
        keys=append(keys, k)
    }
    return keys
}
```

If want to use a similar feature for another map type such as a `map[int]string`-- fore: using like:

```go
func getKeys(m any) ([]any, error) {
    switch t := m.(type) {
    default:
        return nil, fmt.Errorf("Unknown type: %T", t)
    case map[string]int:
        var keys []any
        for k:= range t {
            keys= append(keys, k)
        }
        return keys, nil
    case map[int]string:
        // copy the enxternal logic
    }
}
```

With this example, start to notice few issues -- increases bolierplate code, it requires duplicating the `range`loop. Meanwhile, the function now accepts an `any`type, which means that lose some of the benefits of go as a typed language. Indeed, checking whether a type is supportd is done at run time instead of compile time.

Type parameters are generic types that can use with functions and types, fore, the following function like:

`func foo[T any](t T){//...}`

When calling `foo()`need to pass a type argument of `any`type. Supplying a type argument is called *instantiation*. Can:

```go
func getKeys[K comparable, V any](m map[K]V) []K {
	var keys []K
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
```

To handle the map, define two kinds of type parameters, first the values can be of the `any`type `V`, in Go, the map keys can’t be of the `any`type. We are obliged to restrict type arguments so that the key type meets specific requirements, here the requirement is that the key type must be comparable.

Restricting type arguments to match specific requirements is called a *constraint* -- 

- A set of behaviors (methods)
- Arbitrary types

Fore, want to restrict it to either `int`or `string`types like:

```go
type customConstraint interface {
    ~int | ~string
}
func getKeys[K customConstraint, V any](m map[K]V) []K {...}
```

First, define a `customConstraint`interface to restrict the types to be either `int`or `string`using the union operator. The signature of `getKeys`enforces that can call it with a map of any value type, but the key types has to be an `int`or a `string`like: `~int`restricts all the types whose underlying type is `int`.

Can also use generics with data structures, fore, can create a linked list containing values of any type. like:

```go
type Node[T any] struct { // using a type parameter
    Val T
    next *Node[T]
}
func (n *Node[T]) Add(next *Node[T]) { // instantiates a type receiver
    n.next= next
}
```

In this example, use type parameters to define `T`and use both fields in `Node`. Regarding the method, the receiver is instantiated. Indeed, cuz `Node`is just generic, it has to follow the defined type parameter as well.

One last thing to note about type parameter is that they *can’t be used with method arguments*, only with function arguments or method receivers.

#### Common uses and misuses

When are generics useful -- 

- *Data Structures* -- can use generics to factor out the element type if we implement a binary tree fore

- *Function working with slices, maps, channels of any type* -- A function to merge two channels fore, can:

  ```go
  func merge[T any](ch1, ch2 <-chan T) <-chan T {...}
  ```

- *Factoring out behavior instead of types* -- The `sort`package, fore, contains `Interface`interface, and this is used by different functions such as `sort.Ints`or `sort.Float64s`using type parameters, could factor out the sorting behavior like:

  ```go
  type SliceFn[T any] struct {
  	S       []T
  	Compare func(T, T) bool
  }
  
  func (s SliceFn[T]) Len() int {
  	return len(s.S)
  }
  func (s SliceFn[T]) Less(i, j int) bool {
  	return s.Compare(s.S[i], s.S[j])
  }
  func (s SliceFn[T]) Swap(i, j int) {
  	s.S[i], s.S[j] = s.S[j], s.S[i]
  }
  
  func main() {
  	s := SliceFn[string]{
  		S: []string{"Fry", "Bender", "Leela"},
  		Compare: func(a, b string) bool {
  			return a < b
  		},
  	}
  	sort.Sort(s)
  	fmt.Println(s.S)
  }
  ```

Conversely, when it is recommended that not use generics -- 

- When calling a method type argument -- Consider a func that receives an `io.Writer`and calls the `Write`

  ```go
  func foo[T io.Writer](w T) {
      //...
  }
  ```

  In this case, using generics won’t bring any value to our code whatsoover, we should make the `w`an `io.Writer`directly

- When it makes our code more complex -- Generics are never mandatory, and as a Go Developers.

### Not being aware of the possible problems with type embedding

When creating a struct, Go offers the option to embed types, but this can sometimes lead to unexpected behavior if don’t understand all implications of type embedding. In go, a struct is called *embedded* if it’s declared without a name.

```go
type Foo struct {
    Bar
}
type Bar struct {
    Baz int
}
```

Use embeddeing to *promote* the fields and methods of an embedded type, 

```go
foo = Foo{}
foo.Baz=42
```

#### Interfaces and embedding

Embeddingis also used within interfaces to compose an interface with others. Fore:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

But, an example of a wrong usage -- in the following, implement a struct that holds some in-memory data, want to protecte it against concurrent accesses using mutex like:

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem{
    return &InMem{m: make(map[string]int)}
}
```

For this, decided to make the map unexported so that client can’t interact with it directly but only via exported methods. Meanwhile the mutex filed is embedded. Like:

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

Cuz the mutex is embedded, can directly access the `Lock`and `Unlock`methods for the `i`receiver. Since `sync.Mutex`is an embedded type, the `Lock`and `Unlock`will be promoted, therefore, both methods become visible to external clients using `InMem`. like:

```go
m := inmem.New()
m.Lock() //??
```

This promotion is probably not desired, a mutex is in most cases, sth that we want to encapsulate within a struct and make invisible to external clients. Shouldn’t make it embedded:

```go
type InMem struct {
    mu sync.Mutex
    m map[int]string
}
```

For this, cuz the mutex isn’t embedded and is unexported, it can’t be accessed from external clients. For another example, this time where embedding can be considered a correct approach like: Want to write a custom logger that contains an `io.WriteCloser`and exposes `Write`and `Close`like:

```go
type Logger struct {
    writeCloser io.WriteCloser
}
func (l Logger) Write(p []byte) (int, error) {
    return l.writeCloser.Write(p)
}//...
```

Here, `Logger`would have to provide both a `Write`and a `Close`method that would only forward the call to `io.WriteCloser`. However, if the field is now becomes embedded, can remove these forwarding methods like:

```go
type Logger struct {
    io.WriteCloser
}
func main(){ 
    l := Logger {WriteCloser: os.Stdout}
}
```

It just remains the same for clients with two exported `Write`and `Close`methods.

If we decide to use type-embedding, need to keep two main constraints in mind -- 

- It shouldn’t be used solely as some syntactic sugar to simplify accessing a field.
- It shouldn’t promote data or a behavior we want to hide from the outside.

Using type embedding concisously by keeping these constraints in mind can help avoid boilerplate code.

## Creating Completely Custom JSON encodings

The `Encoder`checks to see whether a struct implements the `Marshaler`interface, which denotes a type that has a custom encoding and which defines the method like:

`MarshalJSON()`-- this invoked to create a JSON representation of a value and returns a type slice containing the JSOn and an `error`indicting encoding problems.

```go
type DiscountProduct struct {
    *Product `json:",omitempty"`
    Discount float64 `json:",string"`
}
func (dp *DiscountProduct) MarshalJSON() (jsn []byte, err error) {
    if(dp.Product != nil) {
        m := map[string]any {
            "product": dp.Name,
            "cost": dp.Discount
        }
        jsn, err = json.Marshal(m)
    }
    return
}
```

So the `MarshalJSON()`method can generate JSON in any way that suits the project.

### Decoding JSON data

The `NewDecoder()`ctor function creates a `Decoder`which can be uesd to decode JSON data obtained from a `Reader`, using the methods like:

- `Decode(value)`-- reads and decodes data, which is used to create the specified value, the method returns an `error`that indicates problems decoding the data to the required type or `EOF`.
- `DisallowUnknownFields()`-- When decoding a struct, the `Decorder`ignores any key in the JSON data for which there is no corresponding struct field. Calling this method causes the `Decode`to return an `error`, rather than ignoring the key
- `UseNumber()`-- by defult, JSON number values are just decoded into `float64`values, calling this method uses the `Number`type instead.

```go
func main() {
	reader := strings.NewReader(`true "Hello" 99.99 200"`)
	vals := []any{}
	decoder := json.NewDecoder(reader)
	for {
		var decodedVal any
		err := decoder.Decode(&decodedVal)
		if err != nil {
			if err != io.EOF {
				fmt.Printf("error: %v\n", err.Error())
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

Created a `Reader`that will produce data from a string containing a sequence of values, separated by spaces - The JSON specification allows values to be separated *by spaces or newline*,note that. The first step in decoding the data is to create a `Decoder`-- which accepts a `Reader`-- want to decode multiple values, so call the `Decode`insdie a `for`, The `Decoder`is able to select the appropriate Go data type for JSON vlaues, and this is achieved by providing a pointer to an empty.