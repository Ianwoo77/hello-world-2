# Grouping data -- 

might be curious which studio had the highest total grosses across all films. is that the Gross column’s values are stored as text rather than as numbers. Can just covert the column’s values to decimal numbers like:

```python
movies['Gross'].str.replace(
    "$", '', regex=False
).str.replace(',', '',)
```

now convert the Gross column’s values from text to float like:

`.astype(float)`
And these operations are temporary and do not modify the original Gross `Series`. Pandas just created a copy of the original data structure, perfored the operation, and returned a new object. The new example explicitly overwrites the Gross column in movies.

```python
movies['Gross'] = movies['Gross'].str.replace(
    "$", '', regex=False
).str.replace(',', '',).astype(float)
```

`movies['Gross'].mean()`

For the original problem -- calculating the aggregate box-office grosses per film studio -- need to identify the studios and bucket the movies -- This process is called *grouping* -- in the net, like:
`studios = movies.groupby("studio")`
`studios['Gross'].count().sort_values(ascending=False)`

Can ask pandas to count the number of filems per studio. Then add the values of the Gross column per studio.
`studios['Gross'].sum().sort_values(*ascending*=False)`

So with a few lines of code, can derive some fun insights from this complex data set.

## The Series object

Pandas assigns each `Series`value a *label*-- an identifier can use to locate the value. The `Series`is a 1D data structure cuz need one reference point to access a value, either a label or a position.

### Populating with values

The 1st arg to the `Series`is an iterable object whose values will populate the `Series`. like:

```python
ice_cream_flavors= [
    'Chocolate', 'Vanilla', 'Strawberry', 'Rum Raisin'
]
pd.Series(ice_cream_flavors)
```

Can connect parameters and arguments explicitly with keyword arguments like:
`pd.Series(data= ice_cream_flavors)`

### Customizing the Series index

Can pass objects of different data types to the `data`and `index`parameters. But must have the same length so that pandas can associate their values. like:

```python
day_of_week = ('Mon', 'Wed', 'Fri', 'Sat')
pd.Series(ice_cream_flavors, index=day_of_week)
```

Then, create `Series`objects from lists of Boolean, integer, and float values like:

```python
bunch_of_bools= [True, False, False]
pd.Series(bunch_of_bools)
```

and the `float64`and `int64`data type indicate that each float-point/inteer value in the `Series`just occupies of PC’s RAM. For this problem, Pandas does its best to infer an appropriate data type for the `Series`fro mthe data parameter’s values. like:

```python
lucky_numbers= [4,8,15,16,23,42]
pd.Series(lucky_numbers, dtype='float')
```

The previous just used both both positional and keyword arguments.

### Creating a Series with missing values

In the real world, data is a lot missier. nan object -- *not a number* -- is a catch-all term for an undefined value. FORE

```python
temperatures= [94,88,np.nan, 91]
pd.Series(temperatures)
```

Noticed that the `Series`dtype is `float64`, pandas automatically converts numeric values from integers to float-pointings whe it spots a `nan`.

### Creating a sereis from Py objects

Fore, a *dict* is a collection k-v pairs, so can be used like:

```python
calorie_info = {
    'Cereal':125,
    'Chocolate Bar': 406,
    'Ice Cream Sundae':342
}
diet = pd.Series(calorie_info)
diet
```

So the ctor sets each key as a corresponding index label in the Series.

And a *tuple* is an immutable list, can add, remove, or replace elements in a tuple after creating that, when passed a tuple, the ctor populates the `Series`in an expected manner like:
`d.Series(data=('red', 'Green', 'Blue'))`

And to create a `Series`that stores tuples, wrap the tuples i a list just like:
`pd.Series(((120,41,26),(25,30)))`

note that if pass a set to the `Series`ctor, pandas will throw. So if your program involves a set, transform it to an ordered data structure before passing it to the `Series`ctor. Cuz a set is unordered, cannot guarantee the order of list elemens.

```python
random_data= np.random.randint(1,101,10)
random_data
pd.Series(random_data)
```

As with all other inputs, pandas preserves the order of the `ndarray`'s values in the `Series`.

### Series Attributes

is a piece of data belonging to an object. And a `Series`just is composed of several smaller objects. And the `Series`just uses the `Numpy`'s `ndarray`object to store the calorie counts and the pandas lib’s `Index`object to store the food names in the index.
`diet.index`-- The `index`attribute, fore, returns the `Index`object that stores the `Series`lables.

And some attributes reveal helpful details about the object. `dtype`fore, returns the data type of the `Series`values. `dtype`returns the type and the `size`attr returns the number of values in the `Series`. And the `shpae`attr returns size like: `diet.shape`returns (3,) and the `is_unique`attribute returns `True` if all `Series`values are just unique.
`pd.Series([3,3]).is_unique`returns `False`

The first verb is `%v`and it just specifies the default representation for a type. For a `string`value, fore, `%v`simply includes the string in the output. The `%4.2f`

```go
func getProductName(index int) (name string, err error) {
	if len(Products) > index {
		name = fmt.Sprintf("Name of prodcut : %v",
			Products[index].Name)
	} else {
		err = fmt.Errorf("error for index %v", index)
	}
	return
}
func main() {
	name, _ := getProductName(1)
	fmt.Println(name)
	_, err := getProductName(10)
	fmt.Println(err.Error())
}

```

Both of the formatted strings in this example use the `%v`value, which writes out values in their default form.

## Understanding the formatting Verbs

The functions described.. General-purpose Formatting verbs like:

- `%v`-- displays the default format for the value.
- `%#v`-- displays a value in a format that could be used to re-create the value in a Go code file.
- `%T`-- displays the Go type of a value.

```go
func Printfln(template string, values ...any) {
	fmt.Printf(template+"\n", values...)
}

func main() {
	Printfln("Value: %v", Kayak)
	Printfln("Go syntax: %#v", Kayak)
	Printfln("Type: %T", Kayak)
}

```

### Controlling Struct Formatting

Go has a default format for all data types that the `%v`verbs relies on -- for structs, the default value lists the field values within `{}`. Can be modified with a `+`sign to include the field names in the output. Like:

`Printfln("Value with fields: %+v", Kayak)`

And the `fmt`package supports custom struct formatting through an interface named `Stringer`that is defined like:

```go
type Stringer interface{
    String() string
}
func (p Product) String() string {
	return fmt.Sprintf("Product: %v, Price: %4.2f", p.Name, p.price)
}
```

The `String()`will be invoked automatically when a string representation of a `Product`is required.

### Using the Integer formatting verbs

`%b, %d, %o, %O, %x, %X`

```go
func main() {
	number := 250
	Printfln("Binary: %b", number)
	Printfln("Octal: %o, %O", number, number)
}
```

### Floating-pointing formatting verbs

`%b, %e %E, %f %F, %g %G, %x %X`

- `%U`-- this displays a character in the Unicode format, so that the output begins with U+.
- `%t`-- this formats bool values and displays `true`or `false`.
- `%p`-- this displays a hexadecimal representation of the pointer’s storage location.

```go
func main(){
    name := "Kayak"
    Printfln("Pointer: %p", &name)
}
```

### Scanning Strings

The `fmt`provides functions for scanning strings, which is the process of parsing strings that contain values separated by spaces -- like:

- `Scan(...vals)`-- reads from std and the space-separated values into specified args. Note that the function reads until it has received values for all of its arguments.
- `Scanln(...vals)`-- stops reading when encounter newline
- `Scanf(template, ...vals)`-- works the same way, uses a template string to select the value
- `Fscan(reader, ...vals)`-- reads space-separetd from specireid reader
- `Fscanln(reader, ...vals)`-- same way stop new line
- `Fscanf(reader, template, ...vals)`
- `Sscan(str, ...vals)`-- scans the specified string.
- Also: `Sscanf(str, template, ...vals)`and `Sscanln(str, template, ...vals)` FORE:

```go
func main() {
	var name string
	var category string
	var price float64

	fmt.Print("Enter a text to scan:")
	n, err := fmt.Scan(&name, &category, &price)
	if err == nil {
		Printfln("Scanned %v values", n)
		Printfln("Name: %v, Category: %v, Price: %.2f", name, category, price)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

And, if need to scan a series of values with the same type, the natural approach is to scan into a slice or an array just like this -- need to covert that to pointer first like:

```go
func main() {
	vals := make([]string, 3)
	iVals := make([]any, 3)
	for i := 0; i < len(vals); i++ {
		iVals[i] = &vals[i]
	}
	fmt.Print("Enter text to scan: ")
	fmt.Scan(iVals...)
	Printfln("Name: %v", vals)
}
```

### Dealing with Newline

```go
func main(){
    //...
    n, err := fmt.Scanln(&name, &category, &price)
}
```

The function like: `Sscan` like:

```go
func main() {
	var name, category string
	var price float64
	source := "Lifejacket Watersports 48.95"
	n, err := fmt.Sscan(source, &name, &category, &price)
	if err == nil {
		Printfln("Scanned %v values", n)
		Printfln("Name: %v, Category: %v, price: %.2f", name, category, price)
	}
}
```

Need to note that the first argument to the `Sscan`is the string to scan, but in all other respects, the scanning process is the same.

Using a Scanning Template like:

```go
source := "Product Lifejacket Watersports 48.95"
template := "Product %s %s %f"
n, err := fmt.Sscanf(source, template, &name, &category, &price)
```

### Generating Random Numbers

The `math/rand`:

```go
func main() {
	for i := 0; i < 5; i++ {
		Printfln("Value %v: %v", i, rand.Int())
	}
}
```

For this, will always produce the same set of numbers, which happens cuz the initial seed value is always the same. To avoid this just like:

```go
func main() {
	rand.New(rand.NewSource(time.Now().UnixNano()))
	for i := 0; i < 5; i++ {
		Printfln("Value %v: %v", i, rand.Int())
	}
}
```

For this, using the current time as the seed value, which is done by invoking the `Now()`provided an `int64`value that can be passed to the `rand.New()`and can use:

```go
func main() {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	for i := 0; i < 5; i++ {
		Printfln("Value %v: %v", i, r.Int())
	}
}
```

### Generating a Random Number within a Specific Range

The `Intn()`func can be used to generate a number with a specified value like:

```go
func main() {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	for i := 0; i < 5; i++ {
		// note:  less than 10
		Printfln("Value %v: %v", i, r.Intn(10))
	}
}
```

There is no function to specify a minimum value, but it is easy to shift values generated by the `Intn`like:

```go
func IntRange(min, max int, r *rand.Rand) int {
	return r.Intn(max-min) + min
}

func main() {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	for i := 0; i < 5; i++ {
		// note:  less than 10
		Printfln("Value %v: %v", i, IntRange(10, 20, r))
	}
}
```

### Shuffling Elements

The `Shuffle()`is used to randomly reorder elements -- which it does with the use of a custom function, as shown as:

```go
func main() {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	r.Shuffle(len(names), func(first, second int) {
		names[first], names[second] = names[second], names[first]
	})
	for i, name := range names {
		Printfln("Index %v: Name: %v", i, name)
	}
}
```

The args to the `Shuffle`are the number of elements and a function that will swap two elements -- which are identified by index -- The function is called to swap elements randomly.

### Sorting Data

To arrange elements into more predictable sequence, which is just responsibleity of the function provided by the `sort`package -- like:

- `Float64s(slice), Float64sAreSorted(slice)`
- `Ints(slice), IntsAreSorted(slice)`
- `Strings(slice), StringsAreSroted(slice)`

```go
func main() {
	ints := []int{9, 4, 2, -1, 10}
	sort.Ints(ints)
	Printfln("Ints sroted: %v", ints)

	strings := []string{"Kayak", "Lifejackets", "Stadium"}
	if !sort.StringsAreSorted(strings) {
		sort.Strings(strings)
		Printfln("Strings are sorted: %v", strings)
	} else {
		Printfln("strings are already sorted")
	}
}
```

Need to note that the function sort elements in place, rather than creating a new slice. And if want to create a new, sorted, must use the built-in `make`and `copy`like:

```go
func main() {
	ints := []int{9, 4, 2, -1, 10}
	sortedInts := make([]int, len(ints))
	copy(sortedInts, ints)
	sort.Ints(sortedInts)
	Printfln("Sorted: %v", sortedInts)
}
```

For sorted data, just means *Searching* -- like:

`SearchInts(slice, val), SearchFloat64s, SearchStrings`and `Search(count, testFunc)`and this function invokes the test function for the specified number of elements. like:

```go
indexOf4 := sort.SearchInts(sortedInts, 4)
```

### Sorting Custom Data Type

To sort custom data types, the `sort`package defines an interface named `Interface`note -- and 3 methods:

- `Len(), Less(i,j), Swap(i,j)`

When a type defines the methods in this three, it can be sorted using the functions described like:

- `Sort(data), Stable(data), IsSroted(data), Reverse(data)`

Note that the `Reverse(data)`this function reverses the order of the data.

```go
type ProductSlice []Product

func ProductSlices(p []Product) {
	sort.Sort(ProductSlice(p))
}
func ProductSlicesAreSorted(p []Product) {
	sort.IsSorted(ProductSlice(p))
}

func (products ProductSlice) Len() int {
	return len(products)
}

func (products ProductSlice) Less(i, j int) bool {
	return products[i].price < products[j].price
}

func (products ProductSlice) Swap(i, j int) {
	products[i], products[j] = products[j], products[i]
}
```

This `ProductSlice`type is an alias for a `Product`slice and is the type for whcih 