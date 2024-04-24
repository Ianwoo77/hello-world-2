# Git Commit

Adding commits keep track of our progress and changes as we work. Git considers each `commit`change point or *save point*. It is a point in the project you can go back to if you find a bug. And when we `commit`, should always include a **message**.

```sh
git commit -m "First Release of ..." # -m adds a message
```

### Without Stage

When make just small change, using the staging environment seems like a waste of time. Possible to commit changes directly, skipping the staging environment. `-a`option -- 

```sh
git status --short # use the --short to see the changes in a more compact way.
# ?? - untracked files
# A - Files added to stage
# M - Modified files
# D - Deleted Files
#
# Then commit it directly
git commit -a -m "updated index.html with a new line"
#
# git commit log -- view the history
git log
```

### Git Help

```sh
# See all available options for sepcific command
git *command* -help # *command* for command name
git help --all # see all possible commands
# 
git commit -help
git help --all
```

### Git Branches

A `branch`is a new/separate **version** of the main repository. Fore, have a large proj, need to update the design on it. would that work without and with git. With git -- 

- With a new branch called fore new-disign, edit the code directly without impacting the main branch.
- FORE, there is an unlated error somewhere else
- Create a new branch *from the main*.
- Fix the unrelated error and merge with the main
- go back to new-design branch, finsh the work
- Merge the new-design with main

New Git branches -- like:

```sh
git branch hello-world-images
git branch # can see two, but the * beside master specifies we are currently on the master branch
#
# checkout is the command used to check out a branch.
# moving us from the current
git checkout hello-world-images
```

For added an image to the working folder and a line of code in the `index.html`file like:

```html
<div>
    <img src="hello-world.jpg" alt="Hello world from Space"
         style="width: 100%;max-width: 960px;">
</div>
```

```sh
git add --all
git status #
git commit -m "Added image to the project"
```

#### Switching between Branches

Note, after committing, The direcory’s content changed. 

#### Emergency Branch -- 

Fore, are not yet done with hello-world-images, need to fix an error on master. And don’t want to mess with master directly, do not want to mess with hello. Like:

```sh
git checkout -b emergency-fix
# have created a new branch from master, can sefely fix the error without distinct the other.
# then make some change
git stauts # changes not staged for commit
git add index.html
```

## Series object

One of pandas’ core DS, 1d labeled array for *homogeneous data*. means that the values are the same data type. Each `Series`value a *label*, and identifier can use to locate the value. The library also assigns each an *order* - position in line. Combines and expands the best feature of Python’s native DS.

### Populating with values

The first arg to the `Series`is an iterable object will populate the `Series`. like:

```python
ice_cream_flavors = [
    "Chocolate",
    "Vanilla",
    "Strawberry",
    "Rum Raisin",
]
pd.Series(ice_cream_flavors) # pd.Series(data= ice_cream_flavors)
```

Customizing index -- The term *index* describes both the collection of identifiers and an individual identifier. And ctor’s second parameter, `index`-- sets the index labels of the `Series`-- construct a `Series`with a custom index:

```python
day_of_week=('Monday', 'Wednesday', 'Friday', 'Saturday')
pd.Series(ice_cream_flavors, day_of_week) # index = day_of_week
```

Note that, even though the index consists of string labels now, pandas will assign each `Series`an index position.

```python
bunch_of_bools = [True, False, False]
pd.Series(bunch_of_bools)
stock_prices = [985.32, 950.44]
time_of_day = ["Open", "Close"]
pd.Series(data=stock_prices, index=time_of_day)
lucky_numbers = [4, 8, 15, 16, 23, 33]
pd.Series(lucky_numbers)
```

The `float64`and `int64`indicates that each floating-point/integer value in the series occupies 64 bits. Can:

`pd.Series(lucky_numbers, dtype='float')`passed the `dtype`explicitly.

Change a series with missing values -- When pandas sees a missing value during import, the library substitutes Numpy’s `nan`object. Fore:

```python
temp = [94, 88, np.nan, 91]
pd.Series(data=temp)
```

### Creating from Python object

`data`parameter accepts various inputs, including native DS and objects from other libraries. Like Dict:

```python
calorie_info = {
    "Cereal": 125,
    "Chocolate Bar": 406,
    "Ice Cream Sundae": 342,
}
diet = pd.Series(calorie_info)
```

A *tuple* is an immutable list. `pd.Series(data=('red', 'green', 'blue'))`just note if pass a set to the `Series`, then `TypeError`exception. Fore:

```python
my_set = {"Ricky", "Bobby"}
pd.Series(my_set) # TypeError
```

For the `ndarray`object -- use Numpy arrays.

```python
random_data = np.random.randint(1,101,10)
pd.Series(random_data)
```

### Attributes

Is a piece of data belonging to an object. Reveal info about the object’s internal state.

```python
diet.values # array([...])
type(diet.values) # numpy.ndarray
diet.index # return `Index` object
type(diet.index) # pandas.core.indexes.base.Index
diet.dtype # returns the data type of the Series' values
diet.size
diet.size
diet.is_unique # if all Series values are unique
diet.is_mnontonic # greater than the previous one
```

### Mathematical operations

```python
numbers = pd.Series([1,2,3,np.nan, 4,5])
numbers.count() # counts the number of non-null values
numbers.sum()
numbers.sum(skipna=False) # Nan
# sample selects a random assortment of values
numbers.sample(3)
```

And `unique`returns of unique values from the `Series`. And `nunique`returns the number of unique values in the series:

### Passing to the built-in functions

`len, type, dir`, and `dict(cities)`fore, Can pass Series to the built-in `dict`func to create a dict. And `list()`also can be used. Note that to check 

```python
cities = pd.Series(data=["San Francisco", "Los Angeles", "Las Vegas", np.nan])
'Los Angeles' in cities.values
2 in cities # true
100 not in cities # reverse not in
```

## Checking for items in a Map

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
		fmt.Println("no stored")
	}
}
```

#### Removing items from a Map

Items are removed from a map using the built-in `delete`function. `delete(products, "Hat")`

Enumerating the Content -- 

```go
for key, value := range products {
    fmt.Println("Key:", key, "Value:"value)
}
```

Enumerating a Map in roder -- like:

```go
keys := make([]string, 0, len(products))
for key, _ := range products {
    keys = append(keys, key)
}
sort.Strings(keys)
for _, key := range keys {
    fmt.Println("Key:", key, "Value:", products[key])
}
```

### Dual nature of Strings

Go treats strings as arrays of bytes and supports the array index and slice range notation like:

```go
func main() {
	var price string = "€48.95"
	var currency byte = price[0]
	var amountString string = price[1:]
	amount, parseErr := strconv.ParseFloat(amountString, 64)
	fmt.Println("Currency:", string(currency))
	if parseErr == nil {
		fmt.Println(amount)
	} else {
		fmt.Println(parseErr)
	}
}
```

The problem is that the array and range notation select bytes, but not all characters are expressed as just one byte. For this problem, need to convert a string to Runes.

```go
var price string = "€48.95"
var priceRune []rune = []rune(price)
var currency rune = priceRune[0]
var amountString []rune = priceRune[1:]
amount, parseErr := strconv.ParseFloat(string(amountString), 64)
```

For this, can apply the explicit conversion to the literal string and assign the slice to the `price`. `rune`is an alias for `int32`, means that printing out a `rune`value will display the numeric value used to represent the character.

```go
var price = "€48.95"
for index, char := range price {
    ...
}
// if want to enumerate the underlying bytes without being converted to characters like:
for index, char := range []byte(price) {
    //...
}
```

### Omitting Parameter Types

The type can be omitted when adjacent parameters have the same type. like:

```go
func printPrice(product string, price, taxRate float64) {...}
```

Omitting Parameter names -- An `_`can be used for parameters are defined by a func, but not used in the func’s code.

```go
func printPrice(product string, price, _ float64) {
    taxAmount := price*0.25
    //...
}
```

The underscore called *blank identifier* Can also omit all parameter names:

```go
func printPrice(string, float64, float64) {
    fmt.Println("No parameters")
}
func main(){
    printPrice("kayak", 275, 0.2) 
}
```

### Variadic Parameters

Accepts a variadic numbers of values, which can make functions easier to use. Can first:

```go
func printSuppliers(product string, suppliers []string) {
    for _, supplier := range suppliers {
        ...
    }
}
func main(){
    printSuppliers("kayak", []string {...})
}

// and variadic:
func printSuppliers(product string, suppliers ...string) {
	for _, supplier := range suppliers {
		fmt.Println("Product:", product, "Supplier:", supplier)
	}
}
func main() {
	printSuppliers("Kayak", "Acme Kayaks", "Bob boats")
	printSuppliers("Lifejacket", "Sail safe co")
}
```

Dealing with No args for a variadic parameter -- Go allows arguments for variadic to be omitted entirely.

`printSuppliers("Soccer Ball")` -- the new does not provide any arguments. Can:

```go
if len(suppliers)==0 {
    fmt.Println("Suppliers:": "(none)")
}
```

Using Slices as Values for Variadic Parameters -- `printSuppliers("Kayak", names...)`

Using pointers as Function parameters -- By default, Go copies the values used as arguments so that changes are limited to within the function. Go allows functions to receive pointers, which changes the behavior:

```go
func swapValues(first, second *int) {
	*first, *second = *second, *first
}
func main() {
	val1, val2 := 10, 20
	swapValues(&val1, &val2)
	fmt.Println(val1, val2)
}
```

Defining and using Fuction Results -- Functions define results, which allow functions to provide their callers with the output from operations.

```go
func calcTax(price float64) float64 {
    return price + price*0.2
}
```

Returning multiple results -- an unusual feature of Go functions is the ability to produce more than one result, like:

```go
func swapValues(first, second int) (int, int) {
	return second, first
}
func main() {
	val1, val2 := 10, 20
	val1, val2 = swapValues(val1, val2)
	fmt.Println(val1, val2)
}
```

Using Multiple results instead of Multiple meanings -- Can be used to avoid a source of errors that are common in other langs.

```go
func calcTax(price float64) (float64, bool) {
    if price>100 {
    	return price*0.2, true
    }
    return 0, false
}
func main(){
    //...
    if taxDue {
        fmt.println...
    }
}
```

or using:

```go
if taxAmount, taxDue := calcTax(price); taxDue {...}
```

Named Results -- just like:

```go
func calcTotalPrice(products map[string]float64,
                    minSpend float64) (total, tax float64) {
    total = minSpend
    for _, price := range products {
        if taxAmount, due := caclTax(price); due {
            total += taxAmount
            tax += taxAmount
        }else {
            total += price
        }
    }
    return // note
}
```

Blank identifer to discard results -- To avoid compiler errors, the blank identifier can be used to denotes results that will not be used just like:

```go
func calcTotalPrice(products map[string]float64) (count int, total float64) {
    count = len(products)
    //... return
}
func main(){
    _, total := calcTotalPrice(products)
    fmt.Println("Total:", total)
}
```

### `defer`keyword

schedule a function call that will be performed immediately before the current function returns.

```go
func calcTotalPrice(products map[string]float64) (count int, total float64) {
    fmt.Println("Function started")
    defer fmt.Println("First defer call")
    //...
    defer fmt.Println("Second defer call")
}
```

The main  use for the `defer`is to call functions that release resources..