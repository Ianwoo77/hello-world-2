# Filtering a DataFrame

Learn how to declare logical conditions that include and exclude rows from a DF. How to combine multiple conditions by `AND`and `OR`logic. Introduce some pandas utility methods that simplify the filtering process.

### Optimizing a data set for memory use

It’s important to consider whether each column stroes its data in the most optimal type. The `best`data type is the one that consumes the least memory or provides the most utility. Integers, fore, every column has missing values. The last row consists only `NaN`s. Imperfact data like this common in the real world.

```python
pd.read_csv('employees.csv', parse_dates=['Start Date']).head()
# see a list of columns, data types, count of missing values and memory consumption
employees.info()
```

Just note that the memory use currently 47KB

### Converting data types with the `astype()`

For the `Mgmt`, stores only `True`and `False`, can be more lightweight `Boolean`. And the `astype()`just converts `Series`'s values to a different data type.

```python
employees.Mgmt.astype(bool)
employees.Mgmt = employees.Mgmt.astype(bool)
employees.info() # 40.2k+
```

Have reduced `employee`'s memory use by 15%. In `employees`, pandas stores the `Salary`values at floats, to support the `NaNs`throughout the column, pandas converts their inteers to float-point. if:

```python
mployees['Salary'].astype(int) # IntCastingNaNError
# using the `fillna()`
employees['Salary'].fillna(0).astype(int).tail()
employees.Salary= employees.Salary.fillna(0).astype(int)
```

Pandas includes a special data type called a *category* -- is ideal for a column consisting of a small number of unique values relative to its total size. like gender, weekdays, blood types...
`employees.nunique()` Can see the `Gender`and `Team`columns stand out as good candidates to store categorical.

```python
employees['Gender']= employees.Gender.astype('category')
# 33.5K+
employees.info()
# also
employees['Team']= employees['Team'].astype('category')
```

### Filtering by a single condition

Extractin a subset of data is perhaps the most common operation in data analysis. A *Subset* is a portion of a larger data set the fits some kind of condition. When combine a Series with an equality  - returns a Series of Booleans.
`employees['First Name']== "Maria"`

```python
employees[employees['First Name']== "Maria"]
```

For, retreive all the managers in the series like:

```python
employees[employees['Mgmt']]
# for salary greater than...
employees[employees['Salary']>100000]
```

Fitleing by multiple conditions -- 

```python
is_female = employees['Gender']=='Female'
in_biz_dev = employees['Team']=='Business Dev'
employees[is_female & in_biz_dev]
```

Can also include any amount of `Series`within the `[]`brackets as long as..

The OR -- `employees[earning_below_40k | started_after_2015]`

Inversion with ~ -- inverts the values in the boolean Series. like: `~ pd.Series([True, False, True])`

### Condition

Some filtering operations are more complex than simple equality or inequality checks, Pandas ships with many helper methods that generate Boolean series for these types of extractions.

```python
all_star_teams = ['Sales', 'Legal', 'Marketing']
employees[employees['Team'].isin(all_star_teams)]
```

`between`method -- when working numbers of dates, often want to extract values that fall within a range fore:

```python
higher_than_80 = employees['Salary'] >= 80000
lower_than_90= employees['Salary']< 90000
employees[higher_than_80 & lower_than_90].head()
# a more clear solution like:
between_80_90= employees['Salary'].between(80000, 90000) # [)
employees[between_80_90]
```

And the `between` method also works on coluns of other data types. To filter datetimes, can pass strings for the start and end dates of our time range.

```python
eighties_folk = employees['Start Date'].between(
    left='1980-01-01',
    right='1990-01-01'
)
employees[eighties_folk]
```

Can also apply the `between` method to string columns like:

```python
name_starts_with_r = employees['First Name'].between('R', 'S')
employees[name_starts_with_r]
```

### The `isnull`and `notnull`

The employees data set includes plenty of missing values, Pandas marks missing text and missing values just with `NaN`and for datetime, `NaT`, can use several pandas methods to isolate rows with their null or present values in a given column. like:

Dealing with `null` - `dropna()`removes `DateFrame`rows that hold any `NaN`values.

```python
employees.dropna() # pandas drop all these rows having an NaN
# pass `how` parameter an arg of `all` to remove rows which all values are missing like:
employees.dropna(how='all').tail() # how, default is any
#
# can also pass the subset parameter a list of columns, remove if has a missing value in any of columns
# note that with missing values in the Start Date, the Salary, or both
employees.dropna(subset=['Start Date', 'Salary']).head()
```

### Dealing with duplicates

Missing are a common occurrence in messy data sets, methods for identifying and excluding duplicate values like; The `duplicated()`returns a boolean `Series`that identifies duplicates in a column.
`employees.Team.duplicated().head()`-- And the `duplicated`method’ `keep`parameter informs pandas which duplicate occurrance to keep. Its default arg is just `first`.

`(~employees['Team']).duplicated()` # denotes the first time pandas encounters a value.

`drop_duplicates()`-- provides a convenient shortcut for accomplishing the operation. like:
`employees.drop_duplicates()` note that by default, the method just removes rows in which all values are equal to those in prevously encountered row. So, there are no `employees`rows in which all six are equal.

So, can pass the method a `subset`parameter with a list of columns that pandas should use to determine a row’s uniqueness -- like: `employees.drop_duplicates(subset=['Team'])`. And this also accepts a `keep`parameter, can pass in of `last`.

Note, one additional option is available for the `keep` is `false`argument. Pandas will reject a row if there are any other orws with the same value so: `employees.drop_duplicates(subset=['First Name'], keep=False)`

## Error Handling

Go’s error handling allows exceptional conditions and failures to be represened and dealt with. The `error`interface is used to define error conditions, which are typically returned as function results. And the `panic`is called when unreceoverable error occurs.

```go
func ToCurrency(val float64) string {
	return "$" + strconv.FormatFloat(val, 'f', 2, 64)
}
func (slice ProductSlice) TotalPrice(category string) (total float64) {
	for _, p := range slice {
		if p.Category == category {
			total += p.Price
		}
	}
	return
}
```

This file defines a method that receives a `ProductSlice`and totals the `Price`field or those `Product`values with specified `Category`value.

```go
func main() {
	categories := []string{"Watersports", "Chess"}
	for _, cat := range categories {
		total := Products.TotalPrice(cat)
		fmt.Println(cat, "Total:", ToCurrency(total))
	}
}
```

### Dealing with Recoverable Errors -- 

Go makes it easy to exprss exceptional conditions, which allows a function or method to indicate to the calling code that sth has gone wrong. `	categories := []string{"Watersports", "Chess", "Running"}`The response from the `TotalPrice`for the `Running`is ambiguous. In real projects, this sort of result can be more difficult to understand and respond to.

Go just provides a predefined interface named `error`like:

```go
type error interface {
    Error() string
}
```

### Generating Errors

Functions and methods can express exceptional or unexpected outcomes by producing `error`response, as shown:

```go
func (slice ProductSlice) TotalPrice(category string) (total float64,
	err *CategoryError) {
	productCount := 0
	for _, p := range slice {
		if p.Category == category {
			total += p.Price
			productCount++
		}
	}
	if productCount == 0 {
		err = &CategoryError{category}
	}
	return
}

type CategoryError struct {
	requestedCategory string
}

func (e *CategoryError) Error() string {
	return "Category " + e.requestedCategory + " does not exist"
}
```

This defined an unexported `requestedCategory`, and there is a method that conforms to the `error`interface. And the signature of the `TotalPrice`has been updated so that it returns two results, the original `float64`and the `error`.

```go
func main() {
	categories := []string{"Watersports", "Chess", "Running"}
	for _, cat := range categories {
		total, err := Products.TotalPrice(cat)
		if err == nil {
			fmt.Println(cat, "Total:", ToCurrency(total))
		} else {
			fmt.Println(cat, "(no such category)")
		}
	}
}
```

### Reporting Errors via Channels

If a function is being executed using a gorotuine, then the only communication is through the channel. Which means that details of any problem must be communicated alongside successufl operations. It is just important to keep the error handling as simple as possible.

```go
type ChannelMessage struct {
	Category string
	Total    float64
	*CategoryError
}

func (slice ProductSlice) TotalPriceAsync(categories []string,
	channel chan<- ChannelMessage) {
	for _, c := range categories {
		total, err := slice.TotalPrice(c)
		channel <- ChannelMessage{
			c, total, err,
		}
	}
	close(channel)
}
```

This `ChannelMessage`allows to communicate the pair of results required to accurately reflect the outcome form the `TotalPrice()`-- which is executed async by the new `TotalPriceAsync()`method.

```go
func main() {
	categories := []string{"Watersports", "Chess", "Running"}
	channel := make(chan ChannelMessage, 10)
	go Products.TotalPriceAsync(categories, channel)
	for message := range channel {
		if message.CategoryError == nil {
			fmt.Println(message.Category, "Total:", ToCurrency(message.Total))
		} else {
			fmt.Println(message.Category, "(no such category)")
		}
	}
}
```

### Using the Error Convenience Functions -- 

It can be just awkward to have to define data types for every type of error that anapplication an encounter. The `errors`package -- which is just a part of the stdlib, provide a `New`function that returns an `error` whose content is a `string`. The drawback of this approaches is that it creates simple errors, but has the advantage of simplicity.

```go
func (slice ProductSlice) TotalPrice(category string) (total float64,
	err error) {
	productCount := 0
	for _, p := range slice {
		if p.Category == category {
			total += p.Price
			productCount++
		}
	}
	if productCount == 0 {
		err = errors.New("cannot find category")
	}
	return
}
```

And the `fmt`package is responsible for formatting strings, which it does with formatting verbs.

```go
if productCount == 0 {
    err = fmt.Errorf("cannot find category: %v", category)	
}
```

### Dealing with Unreceoverable Errors

Some errors are so serious so they should lead to the immediate termination of the application, a process known as *panicking* just like:

```go
if message.CategoryError == nil {
    ...
}else {
    panic(messge.CategoryError)
}
```

Then the output shows that a panic occurred and that it happened within the `main`function in the `main`package.

#### Recovering from Panics

Go provides the built-in function `recover()`, which can be called to stop a panic fromworiing its way up the call stack and terminating the program. The `recover()`function must be called in code that is executing using the `defer`.

```go
func main() {
	recoverFunc := func() {
		if arg := recover(); arg != nil {
			if err, ok := arg.(error); ok {
				fmt.Println("Error:", err.Error())
			} else if str, ok := arg.(string); ok {
				fmt.Println("Message:", str)
			} else {
				fmt.Println("Panic Recovered")
			}
		}
	}
	defer recoverFunc()
	categories := []string{"Watersports", "Chess", "Running"}
	channel := make(chan ChannelMessage, 10)
	go Products.TotalPriceAsync(categories, channel)
	for message := range channel {
		if message.CategoryError == nil {
			fmt.Println(message.Category, "Total:", ToCurrency(message.Total))
		} else {
			panic(message.CategoryError)
		}
	}
}
```

This uses the `defer`to register a func, which will be executed when the `main`func has completed, even if there has no panci, calling the `recover`returns a value if there has been a panic. Also can: calling the `recover()`returns a value if there has been a panic, halting the progression of the panic and providing access to the argument used to invoke the `panic`func. FORE:

```go
defer func(){
    if arg := recover(); arg != nil {
        if err, ok := arg.(error); ok {
            ...
        }else if ...{}else {
            //...
        }
    }
}()
```

### Panicking after a Recovery

May also recover from a panic only to realize that the situation is note recoverable after all. When this happens, can start a new panic, either providing a new panic, either providing a new arg or reusing the value received when the `recover`func was called.