# Grouping, Joining and Sorting

Analysis often requires more than just the basics, often need to break our input data apart, to zoom in on particular interesting subsets -- to combiine data from different sources, to transform the data into a new format or value, and then to sort it according to a variety of criteria -- This combination of techniques is collectively known in pandas -- split-apply-combine -- it's common to use one or more of these of these .

- `df.pct_change()`-- for a given data frame, indicates the percentage difference between each cell and corresponding cell in the pervous row.
- `df.corr`-- show the correlation between the numric columns of a data frame.

### Longest taxi rides

When want to sort a data frame in pandas, first have to decide whether we want to sort it via the index or by the values. Already seen that if invoke `sort_index`on a data frame, get back a new data frame whose rows are identical to the existing data frame. The difference between `sort_index`and `sort_values`isn't jsut technical.

`sort_values`also different from `sort_index`in another way, namely that we can sort by any number of columns.

```py
filename='../data/nyc_taxi_2019-01.csv'
df = pd.read_csv(filename, 
                 usecols=['passenger_count', 'trip_distance', 'total_amount'])
```

To sort: like: `df.sort_values('trip_distance')`

This will just return a new data frame, identical to `df`, but with the rows sorted according to `trip_distance`in ascending order, can just:

`df.sort_values('trip_distance', ascending=False)`

And the analysis will be of the `total_amount`column, with the data already sorted by `trip_disctance`. fore:

```py
df.sort_values('trip_distance', ascending=False)['total_amount']
```

Fore, are not interested in calculating the mean of all rows in `total_amount`, merely those from the 20 longest -- one way can use the `head(20)`, another which just like:

```py
df.sort_values('trip_distance', ascending=False,
              )['total_amount'].iloc[:20]
```

And having retrieved `total_amount`from 20 longest-distance taxi rides. can finally calculate the mean value. like:

```py
df.sort_values('trip_distance', ascending=False)['total_amount'].iloc[:20].mean()
```

Then fore, asked to make some cal -- `kind=mergesort`-- sort our data by values like:

`df.sort_values('trip_distance', kind='mergesort')`

By default, `sort_values`sorts in ascending order, so don't need to specify anything -- but also defaults to using quicksort as its sorting algorithm -- so if you have a need to use a different alg, like this:

`df.sort_values('trip_distance', kind='mergesort')['total_amount'].iloc[-20:]`

Just remember that in Py, simply put, is that floating-point math is a bit stance. If use longer floats, such problems will crop up less often. can use:

```py
df = pd.read_csv(filename, 
                usecols=[...],
                dtype={'total_amount': np.float128})
```

Pandas allows to do this by passing a list of columns as the first argument to `sort_values`, then pass a list of booean values to `ascending`with each element in the list corresponding to one of the sort columns like:

```py
df.sort_values(['passenger_count', 'trip_distance'], asecnding=[True, False])
```

For this returns a new dataframe with 3 columns -- in which the rows are first soted by ascending `passenger_count`, and then by `trip_distance`. The first row of the returned data frame has the longest trip for the smallest number of passengers. Then retrieve the `total_amount`column from the returned data frame -- like:

```py
df.sort_values(['passenger_count', 'trip_distance'],
               ascending=[True, False])['total_amount'].iloc[:50].mean()
```

Exercis -- 

- In which 5 rides did people pay the most per mile -- how far did people go on those trips -- 
  ```py
  df['cost_per_mile'] = df['total_amount'] / df['trip_distance']
  df.sort_values('cost_per_mile').tail()
  ```

- Assume that multi-passenger rides are split evenly mong the passengers -- In the exercise, showed that need to use `iloc`or (head/tail) to retreive the first/last 20 rows, cuz the index was all scrambled after our sort operation - but U can pass `ignore_index=True`to `sort_values`and then the resulting data frame will have a numeric index, starting 0, so:
  ```py
  df.sort_values('trip_distance',
                  ascending=False,
                ignore_index=True)['total_amount'].loc[:20].mean()
  ```

### Grouping 

Sometimes want to run an aggregate function on each peice of data -- might want to know that the number of sales per region, or the average cost of living per city -- or the std deviation for each of the age groups in a population -- The functionality, known as grouping -- should also be -- `df.groupby('department')`

Can see, get a `DataFrameGroupBy`object, which is just useful to us cuz of the aggregate methods we can invoke on it. Fore, can call `count`to find out how many items we have in **each** depertment. like: And the result for this code is a data frame, whose columns are the same as `df`and whose rows are the different values in the `deparatment`column, cuz there are three distinct departments in our store, there will thus be three rows. Much of the time, don't want all of the column returned to us. `df.groupby('department').count()['product_id']`

The result is a series whose index contains the different values in `department`.

However, this is just unnecessarily wasteful -- the way that we wrote this code, first applied `count`to the `DataFrameGroupBy`object -- and only after removed all columns by `product_id`-- like:

`df.groupby('departement')['product_id'].count()`

This is far more quicikly -- 

While used `count`in the examples, can use any aggregation method when grouping.

Fore, want to know both the mean and the std deviation of prices in store, grouped by department -- like:

`df.groupby('department')['retail_price'].agg([np.mean, np.std])`

In this case, get a data frame back with two columns, and three rows, will find out the mean and standard deviation for the retail prices in each department. And what if we want to run multiple aggregations on separate columns -- In such a case, don't need to filter columns via `[]`rather, just can pass the entire `DataFrameGroupBy`object to `agg`.

- The key to each keyword argument will be the name of the output column
- The value to each keyword arg is a two-element tuple:
  - The first element in the tuple is a string -- the name of the column in the original data frame we want to analyze
  - The second element in the tuple is also a string, the name of an aggregation method wish to run on that column.

Fore, can get the mean and std deviation of `retail_price`per department. like:

```py
df.groupby('department').agg(mean_price=('retail_price', np.mean),
                             std_price=('retail_price', np.std),
                             max_sales=('sales', np.max))
```

Normally, `groupby`sorts the group keys, if you don't want to see this, or if you are concerned that it's making your query too slow, can pass the `sort=False`to `groupby`like:

`df.groupby('department', sort=False).agg(mean_price=('retail_price', np.mean), #...`

### Exercis -- Tax ride comparisons

The core of grouping is a simple ida, but it has profound implications -- it means that we can just measure different parts of our data in a single query -- producing a data frame that can itself then be analyzed, sorted, and displayed. In this exercise, once again had to load like:

```py
df = pd.read_csv(filename,
                 usecols=['passenger_count', 'trip_distance', 'total_amount'],
                 dtype={'total_amount':np.float64})
```

`df.groupby('passenger_count')['total_amount'].mean()`

This reeturns a servies, the index in the series contains each of the unique values in the `passenger_count`column, the values in the series are the result of running `mean`on .

## Using an initialization Statement with an if statement

Go allows an `if`statement to use an initialization statement, which is executed before the `if`statement’s expression is evaluated -- the initializeation statement is restricted to a Go simple statement -- which means -- like:

```go
func main() {
	priceString := "275"
	if kayakPrice, err := strconv.Atoi(priceString); err == nil {
		fmt.Println("Price", kayakPrice)
	} else {
		fmt.Println("Error:", err)
	}
}

```

```go
func main(){
    for counter:=0; counter<=3; counter++ {
        if(counter==1) {
            continue
        }
    }
}
```

### Receiving only indices or values when enumerating Seuqences

Go will report an error if a variable is defined but not used, can omit the value like:

```go
func main() {
	product := "Kayak"
	for _, character := range product {
		fmt.Println("Character:", string(character))
	}
}
```

### Enumerating Built-in Data Structures

The `range`keyword can also be used with the built-in data structures that Go provides, arrays, slices, and maps, all of which are including examples using the `for`and `range`keywords. like:

```go
func main() {
	products := []string{"Kayak", "Lifejacket", "Soccer Ball"}
	for index, element := range products {
		fmt.Println("Index: ", index, "Element: ", element)
	}
}

```

Using `switch`statements -- A `switch`provide an alternative way to control execution flow, based on matching the result of an expression to a specific value. like:

```go
func main() {
	product := "Kayak"
	for index, character := range product {
		switch character {
		case 'K':
			fmt.Println(index)
		case 'y':
			fmt.Println(index)
		}
	}
}
```

### Matching multiple values

In some languages, `switch`just fall through -- which means that once a match is made by a `case`statement, are executed until a `break`statement is reached -- even if that means that executing statements from a subsequent `case`statement -- Falling trhough is often used to allow multiple case like:

```go
switch(character){
    case 'K', 'k':
    fmt.Println(index)
}
```

### Terminate case statement execution

Although the `break`keyword isn’t required to terminate every `case`, it can be used to end the execution of statements before the end of the `case`statement is reached. like:

```go
switch(character) {
    case 'K', 'k':
    if(character == 'k'){
        fmt.Println("Lowercase k at position", index)
        break
    }
    fmt.Println("Uppercase K at position", index)
}
```

### Forcing Falling through to the next case statement -- 

Go `switch`don’t automatically fall through, but the behavior can be enabled using the `fallthrough`keyword like:

```go
case 'K':
fmt.Println("uppercase character")
fallthrough
case 'k':
```

### Using an initialization statement

A `switch`statement can be defined with an initialization statement, which can be a helpful way of preparing the component value so that it can be referenced within `case`statement. like:

```go
func main() {
	for counter := 0; counter < 20; counter++ {
		switch counter / 2 {
		case 2, 3, 5, 7:
			fmt.Println("Prime value:", counter/2)
		default:
			fmt.Println("Non-prime value:", counter/2)
		}
	}
}
// ...
witch val := counter / 2; val {
    case 2, 3, 5, 7:
    	fmt.Println("Prime value:", counter/2)
```

The initialization statement follows the `switch`keyword and is separated from the comparison value by a semicolon, like: `switch val:= counter/2; val {...}`

The initialization statement creates a variable named `val`using the division operator. This means that the `val`can be used as the comparison value and can be accessed within the `case`statements.

### Omitting a Comparsion value

Go offers a different approach for `switch`statements, which omits the comparison value and uses expressions in the `case`statement -- this reinforces the idea that `switch`statements are a concise alternative to `if`statements.

```go
for counter := 0; counter < 20; counter++ {
    switch {
        case counter == 0:
        fmt.Println("Zero value")
        case counter < 3:
        fmt.Println(counter, "is<3")
        default:
        fmt.Println(counter)
    }
}
```

### Label statements

Lable statements allow execution to jump to a different point, giving greater flexibility than other flow control features.

```go
func main() {
	counter := 0
target:
	fmt.Println("Counter", counter)
	counter++
	if counter < 5 {
		goto target
	}
}

```

### Using Arrays, Slices, and Maps

In this, just describe the built-in Go collection types -- These reatures allow realted values to be grouped and just as other features, Go takes a different approach to collections when compared with other lanugages. 

Array types include the size of the array in `[]`, followed by the type of element that the array will contain, known as the *underlying type* -- the length and element type of an array cannot be changed -- and the type length must be specified as a constant.

### Understanding Array Types

And the type of an array is just the combination of its sizes and underlying type -- here is the statement like:

`names := [3]string {"kayak", "lifeJacket", "Paddle"}` If: 

`var otherArray [4]string = names` // error

The unerlying types of the two arrays in this example are the same, but the compiler will report an error. Go works with values, rather than references -- by default, this extends the array. Like:

```go
func main() {
	names := [3]string{"Kayak", "Lifejacekt", "Paddle"}
	otherArray := names // just a copy, not for reference
	names[0] = "Canoe"
	fmt.Println("names:", names)
	fmt.Println("otherArray:", otherArray)
}

```

In this example, assign the `names`array to a new variable named `otherArray`and then change the value at index zero of the `names`array before writing out both arrays. The code produces the following output when compiled and executed. Note can also create arrays that contain just pointers, which means that the values in the array are not copied when the array is copied.

### Comparing Arrays

The == and != just can be applied to arrays like:

```go
names := [3]string {"1", "2", "3"}
moreNames := [3]string {"1", "2", "3"}
same := names==moreNames  // true
```

### Working with Slices

And the best way to think of slics is as a variable-length array cuz they are useful when you don’t know how many vlues you need to store or when the number changes over time. like;

```go
names := make([]string, 3)
```

The `make`accepts args that specify the type and length of the slice. Appending elements to a slice -- One of the key advantages of slices is that they can be expanded to accomodate additional elements. like:

`names= append(names, "hat", "gloves")`

### Allocating Additional Slice capacity

Creating and copying arrays can be inefficient and if expect will need to append items to a slice, can specify additional capacity when using the `make`func -- like:

```go
func main(){
    names:= make([]string, 3,6)
    names[0]="Kayak"
    //...
    fmt.Println(len(names))
    fmt.Println(cap(names))
}
```

As noted, slices have a *length* and *capacity*. The caacipty will alwyas be at least the length but can be larger if additional capacity has been allocated wtih the `make`function.

And the result of the `append`is a slice whose length has increased but is still backed by the same underlying array. The original slice till exists and backed. Since the slices are backed by the same array, assiging a new value with one slice affects the other slice too.

```go
func main() {
	names := make([]string, 3, 6)
	names[0] = "kayak"
	names[1] = "Lifejacket"
	names[2] = "Paddle"

	appendNames := append(names, "Hat", "Gloves")
	names[0] = "Canoe"
	fmt.Println("names", names)
	fmt.Println("appendNames:", appendNames)
}

```

### Appending one slice to Another

The `append`function can be used to append one slice to another like:

```go
moreNames := []string {"Hat Gloves"}
appendNames := append(names, moreNames...)
```

Creating from existing arrays -- just: `someNames := products[1:3]`and `allNames:= products[:]`

### Appending elements when Using existing Arrays or Slices

The relationship between slice and the existing array can create different results when appending elements. As showed, it is possible to offset a slice so that its first index pos is not at the start. Like:

```go
func main() {
	products := [4]string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	someNames := products[1:3]
	allNames := products[:]

	fmt.Println("someNames:", someNames)
	fmt.Println("someNames len:", len(someNames), "Cap:", cap(someNames))  // 2 3
	fmt.Println("allNames", allNames)
	fmt.Println("allNames len", len(allNames), "cap:", cap(allNames))  // 4 4
}

```

Then if appending an element to a slice in the file in the collections folder.

`someNames = append(someNames, "Gloves")` For this, the slice has the capacity to accommodate the new element without resizing, but the array location that will be used to store the element is already inclued in the `allNames`alcie -- which means that the `append`operation expands the `someNames`slice and chagnes one of the vlaues that can be accessed through the `allNames`slice. For the result:

len :3 , cap: 3

If the second call to the `append`occurred - there is no further capacity when the `append`is called again, and so a new array is just created the conents are copied -- and the two slices are backed by different arrays like:

len: 4, cap: 6

The resizing process just cipies only the array elements that are mapped by the slice, which has the effect of realigning the slice and array indicies.

### Specifying Capacity when creating a slice from an Array

Ranges can include a maximum capacity, which provides some degree of control over when arrays will be dupliated -- 

```go
someNames := products[1:3:3]  // means that the max is 2
allNames := products[:]
someNames = append(someNames, "Glove")   // means resizing
```

So the slice resize means that the `Gloves`value that is appended to the `someNames`slice does not become one of the vlaues mapped by the `allNames`slices.

### Creating Slcies form other

Can also be created from other slices -- although the relationship between slices isn’t preserved if they are resized. like:

```go
allNames := products[1:]
someNames := allNames[1:3] 

allNames = append(allNames, "Gloves")
allNames[1] = "Canoe"
```

The range used t create the someNames slice is applied to `allNames`, which is also a slice like:

`someNames := allNames[1:3]`

Using one to create another is an effecitve way of carrying over offset start locations -- which is what shows -- but, remebmers that slices are essentially pointers to sections of arrays. So:

### Using the `copy`function

The `copy`function is used to copy elements between slices, This func can be used to ensure that slices have separate arrays and to create slices that combine elements from different sources. so the `copy`can be used to duplicate existing slice, selecting some or all the elemens but ensuring that the new is backed by its own array like: like:

```go
func main() {
	products := [4]string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	allNames := products[1:]
	somenames := make([]string, 2)
	copy(somenames, allNames)

	fmt.Println(somenames, allNames)
}
```

So the `copy`accepts two arguments, whcih are the destination slice and source slice. The function copies elements to the target slice. The slices don’t need to have the same length cuz the `copy`function will copy elements only *until the end of the destination* or source slice is reached. And the effect of the `copy`is that elements are copied from the `allNames`until the length of the `someNames`is exhausted.

### Understanding the Uninitialized Slice Pitfall

As explained in the previous section, the `copy`function doens’t resize the destination slice, a common pitfall is to try to copy elements into a slice that has been initialized. fore:

```go
func main(){
    //...
    var someNames []string
    copy(someNames, allNames)
}
```

Have just replaced the statement with make and an empty slice -- the result is [] just. No elements have been copied to the destination -- No elements have been copied.

### Specifying Ranges when Copying Slices

Fine-grained control over the elements that are copied can be achieved using ranges, like so:

```go
somenames := []string{"Boots", "Canoe"}
copy(somenames[1:], allNames[2:3])
```

The `range`applied to the dest slice means that the copied elements wil start at pos 1. The range applied to the source slice mans that copying will begin with the element in pos 2 and that one element will be copied.

### Copying Slices with Different Sizes

The behavior that leads to the problem described in the -- If the dest slice is larger then the source, then copying will continue until the last elements in the source has been copied. Just note that remaining elements will not be Can:

`copy(products[0:1], replacementProducts)`

### Deleting Slice elements

There is no built-in function for deleting slice element, but just performed using the ranges and the `append`like;

```go
func main() {
	products := [4]string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	deleted := append(products[:2], products[3:]...)
	fmt.Println(deleted)
}
```

To delete a value, the `append`is used to combine two ranges that conains all the elements in the slice except the one that is no longer required.

### Enumerating Slices

Slices are enumerated in the same way as arrays. For sorting, also there is no built-in and the STDLIB include `sort`package, which defines functions for sorting different types of slices -- the `sort`package is described:

```go
func main() {
	products := [4]string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	sort.Strings(products[:])  // so the original array sorted too
	for index, value := range products {
		fmt.Println(index, value)
	}
}
```

Comparing Slices -- Go restricts the use of the comparison operator so that slices can be compared only to the `nil`. And for this there is no way to compare slices, however, the STDLIB includes a package named `reflect`-- includes a convenience functin named `DeepEqual`-- the `reflect`-- and contains advanced features -- just like:

`fmt.Println("Equal:", reflect.DeepEqual(p1, p2))`

### Getting the Array underlying a Slice

For, if have a slice but need an array, typically cuz a function require that as an argument, then can perform an **explicit** conversion on the slice like:

```go
func main() {
	p1 := []string{"Kayak", "Lifejacket", "Paddle", "Hat"}
	arrayPtr := (*[3]string)(p1)
	array := *arrayPtr
	fmt.Println(array)
}

```

The first step is to perform an explicit type conversion on the `[]string`to the `*[3]string`.

### Working with Maps

Maps are built-in data structure that assocaites data values with keys -- Unlike arrays, where values are associated with sequential integer locations, maps can use other data types as keys -- like:

```go
func main() {
	products := make(map[string]float64, 10)
	products["Kayak"] = 279
	products["Lifejacket"] = 48.95
	fmt.Println("Map size", len(products))
	fmt.Println(products["Kayak"])
	fmt.Println(products["Hat"])   // 0 
}
```

### Using the Map literal syntax

Just like:

```go
products := map[string]float64 {
    "Kayak": 279,
    "Lifejacket":48.95
}
```

### Checking for Items in a Map

As noted earlier, maps return the zero value for the type when reads are performed for which there is no key -- this can make it just difficult to differentate between a stored value that happens to be zero vlaue and a nonexistent key. To solve this problem, maps produce two values when reading a value like:

```go
func main() {
	products := map[string]float64{
		"Kayak":      279,
		"Lifejacket": 48.95,
		"Hat":        0,
	}

	if value, ok := products["Hat"]; ok {
		fmt.Println(value)
	} else {
		fmt.Println("No value")
	}
}

```

### Removing from Map

`delete(products, "Hat")`

So the arguments to the `delete`function are the amp and the key to remove. No error will be reported if the specified key is not contained in the map.

May need to enumerate a map in order, fore:

```go
func main() {
	products := map[string]float64{
		"Kayak":      279,
		"Lifejacket": 48.95,
		"Hat":        0,
	}

	keys := make([]string, 0, len(products))
	for key, _ := range products {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	for _, key := range keys {
		fmt.Println("Key:", key, "Value:", products[key])
	}
}

```

### Understanding the Dual Nature of Strings

Go treats strings as arrays of bytes and supports the array index and slice range notation. FORE:

```go
func main() {
	var price string = "$48.95"
	var currency byte = price[0]
	var amountString string = price[1:]
	amount, parseErr := strconv.ParseFloat(amountString, 64)

	fmt.Println("Currency", currency)
	if parseErr == nil {
		fmt.Println("Amount", amount)
	} else {
		fmt.Println("Parse error:", parseErr)
	}
}
```

Can just: `var currency string = string(price[0])`

And just note that the `rune`type represents a Unicode point -- just `int16`.

```go
func main() {
	var price []rune = []rune("€48.95")
	var currency string = string(price[0])
	var amountString string = string(price[1:])
	amount, parseErr := strconv.ParseFloat(amountString, 64)

	fmt.Println("Currency", len(price))
	fmt.Println("Currency", currency)
	if parseErr == nil {
		fmt.Println("Amount", amount)
	} else {
		fmt.Println("Parse error:", parseErr)
	}
}
```

Apply the explicit conversion to the iteral string and assign the slice to the `price`variable. Also have to perform an explicit conversion on the slice created.

### Enumerating Strings

A `for`can be used to enumerate the contents of a string. So like:

```go
func main() {
	var price = "€48.95"
	for index, char := range price {
		fmt.Println(index, char, string(char))
	}
}
```

Note that for the the go treats string as a sequence of runes when used with the `for`loop. And the `for`loop treats the string as an array of elements. The values writtenout are the index of the current element. if just want to enumerate the underlying bytes without them being converted to characters, can perform an explicit conversion like:

```go
for index, char := range []byte(price) {
    fmt.Prinln(index, char)
}
```

### Omitting Parameter Names

An underscore `_` can be used for paramters that are defined by a function but not used in the function’s code statements -- like:

```go
func printPrice(product string, price, _ float64) {
	taxAmount := price * 0.25
	fmt.Println(product, "price:", price, "Tax:", taxAmount)
}

func main() {
	printPrice("Kayak", 275, 0.2)
}

```

### Defining variadic Parameters

A varidadic parameter accepts a variable number of values, like:

```go
func printSuppliers(product string, suppliers ...string) {
	for _, supplier := range suppliers {
		fmt.Println("Product:", product, "Supplier:", supplier)
	}
}

func main() {
	printSuppliers("Kayak", "Acme Kayaks", "bob's Boats")
	printSuppliers("Lifejacket", "sail safe co")
}

```

So the variadic parameters is defined with an `...`, followed by a type.

### Dealing with no args for variadic

Just use:

```go
if(len(suppliers)==0) {
    fmt.Println(...)
}
```

## Using Fixed-Width Grid Tracks

Don’t necessarily mean a fixed length like pixels or ems, -- percentage also count as fixed width here. -- *fixed* means length like pixels or ems, percentge also count as fixed width here. like:

```css
#grid {display: grid;
	grid-template-columns: 200px 50% 100px;
}
```

And place any grid-line name you want like:

```css
#grid {
    display: grid;
    grid-template-columns:
        [start col-a] 200px [col-b] 50% [col-c] 100px [stop]
}
```

### Using Flexible Grid Tracks Fractional units

`fr`unit is here for you- an `fr`is a flexible amount of space, representing a fraction of the `leftover`space in a grid. If want to divide up whatever space ia available by a certain fraction and distribute the . In its simplest case, can divide up the whole container by equal fractions.

In its simplest case, can divide up the whole container by equal fractions -- like:

`grid-template-columns: 1fr 1fr 1fr 1fr`

And in its very speific and limited case, that’s equivalment to saying the following:

`grid-template-columns: 25% 25% 25% 25%`

And are not required to always use 1 with your `fr`units -- suppose that you want to divide up a space into 3 columns like: `1fr 2fr 1fr`, and aren’t limited to integers like: `1fr 3.14159fr 1fr`

Can also: `15em 1fr 10%`

And if want to define a minimum or maximum size for a given track, `minmax()`can be quite useful, to extend the previous, suppose the 3rd column should never be less than 5 ems wide like:

`15em 4.5fr minmax(5em, 3rr) 10%`

And speaking of setting to 0, look at minimum value explicitly set to 0 like:

`grid-template-columns: 15em 1fr minmax(0, 500px) 10%;`

```css
.grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    gap: .5em;
}

.grid>* {
    background-color: darkgray;
    color: white;
    padding: 2em;
    border-radius: .5em;
}
```

### Anatomy of a grid

It’s just important to understand the varous parts of grid, already mentoined grid containers and grid items, which are the elements that make up the grid. Four other important terms to know -- 

- *grid line* -- these make up the structure of the grid. A line cna be vertical or horizontal and lie on either side of a row or column
- *grid track* -- is the space between two adjacent grid lines.
- *grid cell* -- a single space on the gird, where a horizaontal grid track and a vertical grid track overlap.
- *grid area* -- just rectangular area on the grid made up by one or more grid cells.

It’s important to note that the use of grid here does not render flexbox useless, When built this page using flexbox, had to nest the elements in a certain way. Used one flexbox to define columns and nested another flexbox inside it to define rows. To build this layout with grid requires a different HTML strucure like:

```html
<body>
    <div class="container">
        <header>
            <h1 class="page-heading">Ink</h1>
        </header>


        <nav>
            <ul class="site-nav">
                <li><a href="/">Home</a></li>
                <li><a href="/">Features</a></li>
                <li><a href="/">Features</a></li>
                <li><a href="/">Pricing</a></li>
                <li class="nav-right">
                    <a href="/about">about</a>
                </li>
            </ul>
        </nav>
        <main class="main tile">
            <h1>Team collaboration done right</h1>
            <p>Thousnds of teams from all over the world turn
                to <b>Ink</b> to communicate and get things done
            </p>
        </main>

        <div class="sidebar-top tile">
            <form class="login-form">
                <h3>Login</h3>
                <p>
                    <label for="username">Username</label>
                    <input id="username" type="text" name="username" />
                </p>
                <p>
                    <label for="password">Password</label>
                    <input id="password" type="password" name="password" />
                </p>
                <button type="submit">Login</button>
            </form>
        </div>

        <div class="sidebar-bottom tile centered">
            <small>Starting at</small>
            <div class="cost">
                <span class="cost-currency">$</span>
                <span class="cost-dallors">20</span>
                <span class="cost-cents">.00</span>
            </div>
            <a class="cta-button" href="/pricing">
                Sign up
            </a>

            <div class="sidebar-bottom tile centered">
                <small>Starting at</small>
                <div class="cost">
                    <span class="cost-currency">$</span>
                    <span class="cost-dallors">20</span>
                    <span class="cost-cents">.00</span>
                </div>
            </div>

        </div>
    </div>
</body>
```

```css
.root {
    box-sizing: border-box;
}

*,
::before,
::after {
    box-sizing: inherit;
}

body {
    background-color: #709b90;
    font-family: Arial, Helvetica, sans-serif;
}

.container {
    display: grid;
    grid-template-columns: 2fr 1fr;
    grid-template-rows: repeat(4, auto);
    gap: 1.5em;
    max-width: 1080px;
    margin: 0 auto;
}

header,
nav {
    grid-column: 1/3;
    grid-row: span 1;
}

.main {
    grid-column: 1/2;
    grid-row: 3/5;
}

.sidebar-top {
    grid-column: 2/3;
    grid-row: 3/4;
}

.sidebar-bottom {
    grid-column: 2/3;
    grid-row: 4/5;
}

.tile {
    padding: 1.5em;
    background-color: #fff;
}

.tile > :first-child {
    margin-top: 0;
}

.tile> :first-child {
    margin-top: 0;
}

.tile *+* {
    margin-top: 1.5em;
}
```

For the `grid-template-row: repeat(4, auto);`defines 4 horizontal grid tracks of height `auto`. Can also define a repeating pattern with the `repeat()`notatihon, fore, `repeat(3, 2fr 1fr)`defines six grid tracks by repeating the pattern three times.

### Numbering grid lines

With the grid tracks defined, the next portion of the code places each grid item into a specific location on the grid. Can use the grid numbers to indicate where to place each grid item using the `grid-column`and `grid-row`properties. FORE,if want to a grid to span from grid line 1 to 3, applying `grid-column: 1/3` to the element. 

Note: these properties are in fact shorthand properties -- `grid-column`is for short for `grid-column-start`and the `grid-column-end`, `grid-row`is short for `grid-row-start`and `grid-row-end`.

And the ruleset that positions the `header`and `nav`at the top of the page is a little bit different. Fore:

`grid-row: span 1;`-- this example uses `grid-column`as seen -- can also specify using special keyword `span`-- thes tells the browser that the item will span one grid track -- Note that didn’t specify an explicit row with which to start or end, so the grid item will placed automatically using the grid item placement algorithm. the placement algorithm will position items to fill the first available space on the grid where they fit.

### Working together with flexbox

The flexbox and grid aree complementary -- they were largely developed in conjunction -- some overlap in what each can accomplish, they ecah shine in different scenarios.

- Flexbox is basically 1-d, whereas grid is 2d
- Flexbox wroks from the content, where grid workds from the layout in.

```css
.site-nav {
    display: flex;
    margin:0;
    padding: .5em;
    background-color: #5f4b44;
    list-style-type: none;
    border-radius: .2em;
}

.site-nav > li {
    margin-top: 0;
}

.site-nav >li a {
    display: block;
    padding: .5em 1em;
    background-color: #cc6b5a;
    color:white;
    text-decoration: none;
}

.site-nav > li+li {
    margin-left: 1.5em;
}

.site-nav > .nav-right {
    margin-left: auto;
}

.login-form h3 {
    margin: 0;
    font-size: .9em;
    font-weight: bold;
    text-align: right;
    text-transform: uppercase;
}

.login-form input:not([type=checkbox]):not([type=radio]) {
    display: block;
    margin-top:0;
    width: 100%;
}

.login-form button {
    margin-top: 1em;
    border: 1px solid #cc6b5a;
    background-color: white;
    padding: .5em 1em;
    cursor: pointer;
}

.centered {
    text-align: center;
}

.cost {
    display: flex;
    justify-content: center;
    align-items: center;
    line-height: .7;
}

.cost > sapn {
    margin-top: 0;
}

.cost-currency {
    font-size: 2rem;
}

.cost-dollars {
    font-size: 4rem;
}

.cost-cents {
    font-size: 1.5rem;
    align-self: flex-start;
}

.cta-button {
    display: block;
    background-color: #cc6b5a;
    color: white;
    padding: .5em 1em;
    text-decoration: none;
}
```

### BS6 Text typography

```html
<div class="container mt-3">
    <h1>Abbrevations</h1>
    <p>The abbr element is used to markup an acronym</p>
    <p>The <abbr title="World Health organization">WHO</abbr></p>
</div>
```

And note that the `.text-lowercase`, `.text-capitalize`

```html
<body>
    <ul class="nav flex-column">
        <li class="nav-item">
            <a class="nav-link" href="#">Link</a>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link" href="#">Link</a>
            </a>
        </li>
    </ul>
</body>
```

```html
<div class="card">
    <div class="card-body">
        <h4 class="card-title">Card title</h4>
        <p class="card-text">Some example txt</p>
        <a href="#" class="card-link">Card link</a>
        <a href="#" class="card-link">Another link;</a>
    </div>
</div>
```

