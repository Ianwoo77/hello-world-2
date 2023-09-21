# Exercise 29 Longest taxi rides

When first started to wrok with SQL -- When want to sort a data frame in pandas, first have to decide whether we want to sort it via the index or by the values -- already seen what if we invoke `sort_index`on a data frame, get back a new frame whose rows are identical to the existing data frame. Again want to sort the rows of data frame, want to do it based on the vlaues in a particular column -- rather then the index.

And `sort_values`is also different from `sort-index`in another way, namely that can sort by any number of columns.

```python
filename = 'data/nyc_taxi_2019-01.csv'
df= pd.read_csv(filename, 
                usecols=['passenger_count', 'trip_distance',
                         'total_amount'])
```

With the dataframe in place, can start to analyze the data - the first task was to find the 20 longest taxlike:

`df.sort_values('trip_distance', ascending=False)`

Our analysis will be of the `total_amount`column -- with the data already sorted by `trip_distance`, can now retrieve just that one column like:

```python
df.srot_values('trip_distance', ascending=False)['total_amount'].iloc[:20]
```

Next, can asked you to make the same calculation -- but this time wanted you to do an `ascneding`sort, like:

`df.sort_values('trip_distance', kind='mergesort')`

`sort_values`sorts in ascending order, so don’t need to specify anything here. just like:

`df.sort_values('trip_distance', kind='mergesort')['total_amount']`

If we use longer floats, then such problems will crop up less often - fore, can instruct `pandas`to read the `total_amount`column into 128-bit floats?

```python
df = pd.read_csv(filename, 
                 usecols=['passenger_count',
                          'trip_distance', 'total_amount'],
                          dtype={'total_amount':np.float128})
```

`df.sort_values('trip_distance', *kind*='mergesort')['total_amount'].iloc[-20:].mean()`

And, pandas allows us to do this by passing a list of columns as the first argument to `sort_vaues`, then pass a list of boolean values to `ascending`, with each element in the list corresponding to one of the sort columns. like:

```python
df.sort_values(['passenger_count', 'trip_distance'],
              ascending=[True, False])
```

The code returns a new data frame with three columns, in which the rows are first sorted by ascending, then by descending.

### Beyond the exercies

In the solution, showed that we can use `iloc`or `head/trail`to retrieve the first/last, cuz the index was all scrambled after our sort operation -- but can pass `ignore_index=True`to `sort_values`, and then the resulting data frame can have a numeric index. like:

```python
df.sort_values('trip_distance', 
               ascending=False, ignore_index=True)['total_amount'].loc[-20:].mean()
```

Grouping -- Already seen how aggregate funtions, `mean`and `std`fore, allow us to better understand our data. But sometimes we want to run an aggregate function on each piece of our data. Fore, might want to know the number of sales per region, or the average cost of living per city.

`df.groupby('department')`

Notice taht the argument to `groupby`needs to be the name of a column, and the result of running result -- `DataFrameGroupBy`object -- which is useful to us cuz of the aggregate methods we can invoke on it., fore, can call `count`and thus find out how many items we have in each department -- like:

`df.groupby('department').count()`

The result of this code is a data frame, whose columns are the same as `df`-- and whose rows are the different values in the `department`column.

And, much of time, don’t want all of the columns returned to us, but rather a subset of them -- could in theory, thus use square brackets on the result of the above -- could count `product_id`.like:

`df.groupby('department').count()['product_id']`

The result is a sereis whose index contains the different values in the `department`. For this, this is unnecessarily wasteful -- the way wrote, first, applied `count`to the `DataFrameGroupBy`object, and only after removed all columns by `product_id`-- it’s far more efficient, especially with a large data frame -- to apply the square brackets:

`df.groupby('department')['product_id'] *# return a SeriesGroupBy object*`

while used `count`in my example here, can use any aggregation method when grouping, `mean, std, min, max sum`. Can actually do that by altering the syntax somewhat -- instead of calling an aggregtion directly, can apply the `agg`on the `DataFrameGroupBy`object -- that method then takes a list of methods like:

`df.groupby('department')['retail_price'].agg([np.mean, np.std])`

And need to note that the `agg`just need a list for this example.

And, what if we want to run multiple aggreations on separate -- in such case, don’t need to filter columns via the `[]`, pass multiple keyword arguments to agg like: note:

- The key to each keyword argumnet will be the name of an output column
- The value to each keyword argument is a two-element tuple.
  - The first in the tuple is a string, the name of the column in the original data frame want to analyze
  - The second in the tuple is also a string, the name of an aggregation method wich to run on that column

```python
df.groupby('department').agg(mean_price=('retail_price', np.mean), 
                             std_price=('retail_price', np.std),
                             max_sales=('sales', 'max'))
```

Normally, `groupby`sorts the group keys -- and if don’t want to see this, or if you are concerned that it’s making your query too slow, can pass `sort=Fasle`to `groupby`like:

`df.groupby('department', *sort*=False)['retail_price'].agg([np.mean, np.std])`

### Taxi Ride comparsions

The core of grouping is a simple idea -- but it has provound implications -- it means that we can just measure different parts of our data in a single query, producing a data frame that can itself then be analyzed, sorted, and displayed.

`df.groupby('passenger_count')['total_amount'].mean()`

For this, returns a series, the index in the series contains each of the unique values in the column.

```python
for i in range(df['passenger_count'].max()+1):
    print(i, df.loc[df['passenger_count']==i, 'total_amount'].mean())
```

For this, iterate over each of the values in `df['passenger_count']`, and then runs `mean`on that subset of the `total_amount`column.

Might want to sort it by value -- in ascending like:

`df.groupby('passenger_count')['total_amount'].mean().sort_values()`

and next, to create a new column -- `trip_distance_group`whose values would be `short, medium long`- corresponding to trips up to 2 miles... like:

```python
df['trip_distance_group']= pd.cut(df['trip_distance'],
                                  [df['trip_distance'].min(),2,10,
                                   df['trip_distance'].max()],
                                   labels=['short', 'medium', 'long'])
```

### Joining

Like grouping, joining a concept that you might have encountered previously, when working with relational dbs. The joining functionality in pandas is quire similar to that sort of dbs. Can combine `products_df`and `sales_df`into a new, single dataframe that contains all of the columns from both of the input data frames.

```python
products_df= products_df.set_index('product_id')
sales_df= sales_df.set_index('product_id')
```

Now that our data frames have a common reference point in the index, can create a new data create a new data frame combining the two. like: `products_df.join(sales_df)`, can now perform whatever queries we might like on this new, combined df. Fore, can just find out how many of each product were sold like:

`products_df.join(sales_df).groupby('name')['quantity'].sum()`

Or can find out how much income we got from each product, and then sort them from lowest to highest like:

`products_df.join(sales_df).groupby('name')['retail_price'].sum().sort_values()`

Can even find out how much income we had on each individual day like:

`products_df.join(sales_df).groupby('date')['retail_price'].sum().sort_index()`

And while our data set is tiny, can even find out how much each product contributed to income like:

```python
products_df.join(sales_df).groupby(['date', 'name'])[
    'retail_price'].sum().sort_index()
```

Separating your data into two or more pieces, so that each piece of info appears only a single time, is known s *normalization*. But it all boils down to keeping the info in separate places, and joining data frames when necessary. Sometimes, you will normalize your own data. but sometimes, you will receive data that has been normalized, and then separated into separate prices. -- which almost always that you will need to join two or more data frames together in order to analyze the info.

## Using Slices as Values for Variadic Parameters

```go
func printSuppliers(product string, suppliers ...string) {
	if len(suppliers) == 0 {
		fmt.Println("Products:", product, "Supplier:(none)")
	} else {
		for _, supplier := range suppliers {
			fmt.Println("Product:", product, "Supplier:", supplier)
		}
	}
}

func main() {
	names := []string{"Acme Kayaks", "Bob's Boats", "Crazy Canoes"}
	printSuppliers("kayak", names...)
}
```

### Using pointers as Function parameters

By default, Go copies the values used as arguments so that changes are limited to within the function as:

```go
func swapValues(first, second int) {
	fmt.Println("Before swap:", first, second)
	first, second = second, first
	fmt.Println(first, second)
}

func main() {
	val1, val2 := 10, 20
	fmt.Println(val1, val2)
	swapValues(val1, val2)
	fmt.Println(val1, val2)
}

```

for this, the `swapValues()`just receives two `int`values, write them out, swaps them, and writes them out again. the values passed to the function are written out before and after the function is called.

```go
func swapValues(first, second *int) {
	fmt.Println("Before swap:", *first, *second)
	*first, *second = *second, *first
	fmt.Println(*first, *second)
}

func main() {
	val1, val2 := 10, 20
	fmt.Println(val1, val2)
	swapValues(&val1, &val2)
	fmt.Println(val1, val2)
}
```

For this, the `swapValues`just still swaps two values but does so using a pointer.

### Defining and using Function results

```go
func calcTax(price float64) float64 {
	return price + price*0.2
}

func main() {
	products := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}
	for product, price := range products {
		priceWithTax := calcTax(price)
		fmt.Println("Product:", product, "price:", priceWithTax)
	}
}
```

So can just also:

```go
func swapValue(first, second int) (int, int){
    return second, first
}
```

### Using multiple Results instead of multiple meanings

Multiple function results may seem odd -- but they can be used to avoid a source of errors that are common in other languages -- like:

```go
func calcTax(price float64) (float64, bool) {
	if price > 100 {
		return price * .2, true
	}
	return 0, false
}
func main() {
	products := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}
	for product, price := range products {
		taxAmount, taxDue := calcTax(price)
		if taxDue {
			fmt.Println(product, taxAmount)
		} else {
			fmt.Println(product, "no tax due")
		}
	}
}
```

So the additional result returned by the method is a `bool`value that indicates whether tax is due. Or:

`if taxAmount, taxDue := calcTax(price); taxDue`

The two results are obtained by calling `calcTax`func.

### Using named results

A function’s results can be given names, which can be assigned values during the function’s execution. When the execution reaches the `return`, the current values assigned to the results are returned.

```go
func calcTotalPrice(products map[string]float64,
	minSpeed float64) (total, tax float64) {
	total = minSpeed
	for _, price := range products {
		if taxAmount, due := calcTax(price); due {
			total += taxAmount
			tax += taxAmount
		} else {
			total += price
		}
	}
	return
}

func main() {
	products := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}
	total1, tax1 := calcTotalPrice(products, 10)
	fmt.Println("Total 1:", total1, "Tax 1", tax1)
	total2, tax2 := calcTotalPrice(nil, 10)
	fmt.Println(total2, tax2)
}

```

### Using the Blank Identifier to Discard Results

Go requests all declared variables to be sued, which can be awkward when a function returns values that you don’t require -- to avoid compiler errors, the `_`can be used to denotes results that will not be used.

`_, total := calcTotalPrice(products)`

### `defer`keyword

the `defer`is used to schedule a function call that will be performed immediately b*efore the current function returns*.

```go
func calcTotalPrice(products map[string]float64,
	minSpeed float64) (count int, total float64) {

	fmt.Println("Func started")
	defer fmt.Println("First defer call")
	count = len(products)
	for _, price := range products {
		total += price
	}
	defer fmt.Println("Second defer call")
	fmt.Println("Func about to return")
	return
}
```

### Using Function types

Describe the way that Go deals with function types, which is useful -- if sometimes confusing -- feature that allows functions to be described consistently and in the same way as other values.

- Functions in Go have a data type, which describes the combination of paramters the function consumes and the results the function produces.
- Treating functions as data types means that they can be assigned to variables and that one function can be substitued for another.

### Understanding Function Types

Functions have a data type in Go also, 

```go
func calcWithTax(price float64) float64 {
	return price + price*.2
}

func calcWithoutTax(price float64) float64 {
	return price
}

func main() {
	products := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}

	for product, price := range products {
		var calcFunc func(float64) float64
		if price > 100 {
			calcFunc = calcWithTax
		} else {
			calcFunc = calcWithoutTax
		}
		totalPrice := calcFunc(price)
		fmt.Println(totalPrice, product)
	}
}
```

This example contains two functions, each of which defines a `float64`parameter and produces a `float64`. And function types are specified with the `func`keyword, followed by the paramter types in parentheses and then the result types. This is know as the *function signature* -- if there are multiple results, then the result types are also enclosed in parentheses -- the Once a function has been assigned to a variable, it can be invoked as though the variable’s name as the function’s name.

### Understanding the Function Comparison and the Zero type

The Go comparison operators cannot be used to compare functions, but they can be used to determine whether a function has been assigned to a varialbe. like:

`fmt.Println("Function assigned", calcFunc == nil)`

### Using Functions as Arguments

Function types can be used in the same way as any other type -- including as arguments for other functions like:

```go
func printPrice(product string, price float64, calculator func(float64) float64) {
    fmt.Println("Product:", product, "Price:", calculator(price))
}
for product, price := range products {
    if price > 100 {
        printPrice(product, price, calcWithoutTax)
    } else {
        printPrice(product, price, calcWithoutTax)
    }
}
```

### Using functions as Results

Functions can also be results, meaning that the value returned by a function is another function like:

```go
func selectCalculator(price float64) func(float64) float64 {
	if price > 100 {
		return calcWithTax
	}
	return calcWithoutTax
}

func main() {
	products := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}

	for product, price := range products {
		printPrice(product, price, selectCalculator(price))
	}
}
```

### Creating Function type Aliases

As the previous -- using function types can be verbose and reptitive, which produces code that can be hard to read and maintain -- Go supports type aliases, which can be used to assign a name to a function signature so that the parameter and result are not specified every time the function type is used.

`type calcFunc func(float64) float64`

The alias assigns the name `calcFunc`to the function type that accetps a `float64`argument and produces a `flaot64`result.

### Using the literal Function Syntax

The function literal synax allows function to be defined so they are specific to a region of code like:

```go
func selectCalculator(price float64) calcFunc {
	if price > 100 {
		var withTax calcFunc = func(price float64) float64 {
			return price + price*.2
		}
		return withTax
	}
	return func(price float64) float64 {
		return price
	}
}
```

So the lteral syntax creates a function that can be used like any other value, including assigning the function to a variable, whcih is that have done -- the type of function literals is defined by the function signature. And the Go compiler will determine the variable type using the function signature.

Functions are treated liken any other value, but the function that add tax can be accessed only through the `withTax`varaible.

### Understanding Function Closure in Go

Functions defined using the literal syntax can reference variables from the surrounding code -- a feature called `closure`.like:

```go
func main() {
	watersportsProducts := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}
	soccerProducts := map[string]float64{
		"Soccer Ball": 19.50,
		"Stadium":     79500,
	}
	calc := func(price float64) float64 {
		if price > 100 {
			return price + price*0.2
		}
		return price
	}
	for product, price := range watersportsProducts {
		printPrice(product, price, calc)
	}
	calc = func(price float64) float64 {
		if price > 50 {
			return price + price*.1
		}
		return price
	}
	for product, price := range soccerProducts {
		printPrice(product, price, calc)
	}
}
```

Two maps contain the names and prices of products in the categories.

```go
func priceFuncFactory(threshold, rate float64) calcFunc {
	return func(price float64) float64 {
		if price > threshold {
			return price + price*rate
		}
		return price
	}
}
func main() {
	watersportsProducts := map[string]float64{
		"Kayak":      275,
		"Lifejacket": 48.95,
	}
	soccerProducts := map[string]float64{
		"Soccer Ball": 19.50,
		"Stadium":     79500,
	}

	waterCalc := priceFuncFactory(100, .2)
	soccerCalc := priceFuncFactory(50, .1)
	for product, price := range watersportsProducts {
		printPrice(product, price, waterCalc)
	}
	for product, price := range soccerProducts {
		printPrice(product, price, soccerCalc)
	}
}
```

Just note that the closure feature allows function to access variables -- and parameters. A function is said to *close* on the sources of value it requires, such that the calculator function *closes* on the factory function’s `threhold`.

## Fraction units

And mixmaxes are usable on rows just as easily as columns. Like:

`grid-template-rows: 3em minmax(5em, 1fr) 2em;`

Content-aware tracks -- It’s one thing ot set up grid gracks that take up fractions of the space available to them, or that occupy fixed amounts of space, -- what if you want to line up a bunch of pieces of a page and can’t guarantee like:

```css
#gallery {
    display: grid;
}
```

For the bootstrap’s flex system-- Quickly manage the layout, alignment, and sizing of grid columns, navigations, components, and more with a full suite of responsive flexobx utilities.

### Enable flex behaviors in bootstrap 5

Apply `display`utilities to create a flexbox container and transform *direct children elements* into flex items. Flex containers and items are able to be modified further with additional flex properties. Just:

`d-flex`and `d-inline-flex`

### Direction

Set the direction of flex items in a flex container with direction utilities in most cases you can moit the horizontal class here as the browser default is `row`. May encounter situations where you need to explicitly set the value like:

```html
<div class="d-flex flex-column p-2 bd-hightlight mb-3">
    <div class="p-2 bd-highlight">Flex item1</div>
    <div class="p-2 bd-highlight">Flex item1</div>
    <div class="p-2 bd-highlight">Flex item1</div>
</div>
<div class="d-flex flex-column-reverse bd-highlight">
    <div class="p-2">Flex item 1</div>
    <div class="p-2">Flex item 1</div>
    <div class="p-2">Flex item 1</div>
</div>
```

### Justify content

use `justify-cntent`utilities on flexbox containers to change the alignment of flex items on the main-axis like:

```html
<body>
    <div class="d-flex justify-content-start">flex-item</div>"
    <div class="d-flex justify-content-end">flex-item</div>
    <div class="d-flex justify-content-center">flex-item</div>
    <div class="d-flex justify-content-between">flex-item</div>
</body>
```

And using `align-items`utilities on flexbox containers to change the alignment of flex items on the cross axis.

```html
<div class="d-flex flex-column border" style="height: 100px;">
    <div>1</div>
    <div>2</div>
    <div>3</div>
</div>
<div class="d-flex flex-column align-items-end border" style="height: 100px;">
    <div>1</div>
    <div>2</div>
    <div>3</div>
</div>
<div class="d-flex align-items-center border" style="height: 100px;">
    <div>1</div>
    <div>2</div>
    <div>3</div>
</div>
```

