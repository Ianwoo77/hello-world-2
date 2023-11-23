# Retrieving the first and last rows

A Py object has both attributes and methods. And for an *attribute* is a piece of data belonging to an object -- a characteristic or detail that the data structure can reveal about itself. By comparison, a *method* is a function that belongs to an object. Attributes defines an object’s *state* just, and methods defines *behavior*.

### Statistical operations

By creating a `Series`from a list of ascending numbers, sneaking in an `np.nan`value in the middle -- Remebmer that if a data source has even a single missing value, pandas will coerce the integers to floating. like:

```python
numbers = pd.Series([1,2,3,np.nan,4,5])
numbers
# the count() counts the number of NON-NULL values
numbers.count()
# the sum() adds the Series' value together
numbers.sum()
# if skipna=False
numbers.sum(skipna=False) # nan returned

# if threshold is unmet:
numbers.sum(min_count=6) # nan

# product() multiples all Series values together
numbers.product()
numbers.product(skipna=False)
```

### Arithmetic Operations

```python
s1= pd.Series([5, np.nan,15], index=[*'ABC'])
# Treat the Series as a regular operand on one side of mathematical operator
s1+3 # 8.0 NaN 18.0
s1.add(3) # same

s1-5
s1.sub(5)
s1.subtract(5)

s1*5
s1.mul(5)
s1.multiply(5)

s1/2
s1.div(2)
s1.divide(2)

# The two lines below are eq
s1//4  # removes any digits after the decimal point in the result
s1.floordiv(4)

s1%3
s1.mod(3)
```

### Broadcasting

Recall that pandas just stores its `Series`in a Numpy `ndarray`under the hood. When use syntax such as s1+3 or s1-5... pandas delegates the mathmatical calculations to Numpy. And broadcasting also describes mathmatical operations between multiple series objects.

Broadcasting also describes mathmatical operations between multiple `Series`objects. As a rule of thumb. Uses shared index labels to align values across different data structures. like:

```python
s1= pd.Series([3,6,np.nan,12])
s2= pd.Series([2,6,np.nan, 12])
s1==s2 # nan is not equal to nan

# Comparison operations between Series become tricker when the indices differ like:
s1= pd.Series(
    [5,10,15], index=[*'ABC']
)
s2 = pd.Series(
    [4,8,12,14],[*'BCDE']
)
s1+s2
```

### Passing the Series to Python’s built-in functions

Py’s developer likes to rally around certain design principles to ensure consistency across codebase.

```python
cities= pd.Series(
    ["San Francisco", 'Los Angeles', 'Las Vegas', np.nan]
)
print(len(cities)) # returns the number of rows
print(type(cities)) # Series
print(dir(cities)) # a list of object's attributes
print(list(cities)) # return native python ds
print(dict(cities)) # built-in dict function create a dict
print('Las Vegas' in cities) # false default in checks for index
print('Las Vegas' in cities.values) # true
print(100 not in cities) # True
print(heros.nunique()) # 5
print(heros.mean())
print(heros.max(), heros.min())
print(heros*2)
```

## Series methods

A CSV is a plain-text file that separates each row of data with a line break and each row value with a comma. But a Series supports only one column of daa, can use the `index_col`parameter to set the index column. Be mindful of cse sensitivity -- the string must match the header in the data set.

```python
pd.read_csv('../pandas-in-action/chapter_03_series_methods/pokemon.csv',
            index_col='Pokemon')
```

Just a `DataFrame`returned -- Need to add another parameter called `dqueeze`and pass it an argument of `True`like:

```python
type(pd.read_csv('../pandas-in-action/chapter_03_series_methods/pokemon.csv',
            index_col='Pokemon').squeeze())
```

And the ouput tells some important details -- 

- Pandas has assigned the `Series`a name of Type
- The `Series`has 809 values
- `dtype:object`-- tells us that it’s a `Series`of string values.

And the `read_csv`'s `parse_dates`parameter accepts a **list** of strings denoting the columns whose text values pandas should convert to datetimes.

```python
pd.read_csv('../pandas-in-action/chapter_03_series_methods/google_stocks.csv', 
            parse_dates=['Date']).head()
```

There is no visual difference in the output - but pandas is storing a different data type for the Date column under the hood. Can:

```python
pd.read_csv('../pandas-in-action/chapter_03_series_methods/google_stocks.csv', 
            parse_dates=['Date'],
            index_col='Date').squeeze().head()
```

Can also use the `index_col`and `parse_dates`to do:

```python
pd.read_csv(
	"revolutionary_war.csv",
    index_col='Start Date',
    parse_dates=['Start Date']
)
```

And by default, the `read_csv`just imports all columns from a CSV, have to limit the import to two column so that can get a `Series`. just like:

```python
pd.read_csv(
    '../pandas-in-action/chapter_03_series_methods/revolutionary_war.csv',
    index_col='Start Date',
    parse_dates=['Start Date'],
    usecols=['State', 'Start Date'],
).squeeze().tail()
```

### Sorting a Series

Can sort a `Series`by its values or its index, in ascending or descending order like:

```python
google.sort_values() # ascending sort values
```

Pandas sorts uppercase characters before lowercase -- and the `ascending`parameter sets the sort order. like:

`pokemon.sort_values(ascending=False).head()`
and note the `na_position`parameter configures the placement of `NaN`values in the returned `Series`and has a default argument of `last`. like: By default, the pandas places mising values at the end of a sorted `Series`like:

`battles.sort_values(na_position="last")` # or `first`

And what if we wanted to remove `NaN`values -- the `dropna`method returns a `Series`with all missing values removed. Note that the method targets only `NaNs`in he `Series`values -- not the index.

`battles.dropna().sort_values()`

## Sorting Custom Data Types

To sort custom data types, the `sort`package defines an interface confusingly named `Interface`.

- `Len()`-- this method returns the number of items
- `Less(i,j)`-- returns `true`if the element at index i should 
- `Swap(i,j)`-- this swaps the elements at the specified indicies.

And when a type defines the methods, it can be sorted using the functions described:

- `Sort(data)`
- `Stable(data)`-- uses the methods to sort the specified data
- `IsSroted(data)`-- returns `true`if the data is in sorted order
- `Reverse(data)`-- reverse the order of the data

```go
type ProductSlice []Product
func ProductSlice(p []Product) {
    sort.Sort(ProductSlice(p))
}
```

```go
func main() {
	products := []Product{
		{"Kayak", "Watersports", 279},
		{"Lifejacket", "Watersports", 49.95},
		{"Soccer Ball", "Watersports", 19.50},
	}
	ProductSlices(products)
	for _, p := range products {
		Printfln("Name: %v, Price: %.2f", p.Name, p.price)
	}
}
```

### Sorting using different Fields

Type composition can be used to support sorting the same struct type using diferent fields -- like:

```go
type ProductSliceName struct{ ProductSlice }

func ProductSlicesByName(p []Product) {
	sort.Sort(ProductSliceName{p})
}
func (p ProductSliceName) Less(i, j) bool {
	return p.ProductSlice[i].Name < p.ProductSlice[j].Name
}
```

A struct type is defined for each struct field for which sorting is required-- with an embedded `ProductSlice`field:

`type ProductSliceName struct {ProductSlice}`

The type composition feature means that the methods for the `ProductSlcie`type are **promoted** to the enclosing type. A new `Less`method is defined for enclosing type, which will be used to sort the data using a different field like:

```go
func (p ProductSliceName) Less(i, j int) bool {
    return p.ProductSlice[i].Name <= p.ProductSlice[j].Name
}
```

And the final step is to define a function that will perofrm a conversion from a `Product`slice to the new type and invoke the `Sort`function.

```go
products := []Product{
    {"Kayak", "Watersports", 279},
    {"Soccer Ball", "Watersports", 19.50},
    {"Lifejacket", "Watersports", 49.95},
}
ProductSlicesByName(products)
```

### Specifying the Comparison Function

An alternative approach is to specify the expression used to compare elements outside the `sort`function.

```go
type ProductComparison func(p1, p2 Product) bool
type productSliceFlex struct {
	ProductSlice
	ProductComparison
}

func (flex productSliceFlex) Less(i, j int) bool {
	return flex.ProductComparison(flex.ProductSlice[i], flex.ProductSlice[j])
}

func SortWith(prods []Product, f ProductComparison) {
	sort.Sort(productSliceFlex{prods, f})
}
```

A new type named `ProductSliceFlex`is created that combines the data and the comparison function, which will allow this approach to fit within the structure of the functions defined by the `sort`package. The `Less()`method just use the specified function like:

```go
SortWith(products, func(p1, p2 Product) bool {
    return p1.Name > p2.Name
})
```

The data is sorted by comparing the `Name`field descending order.

## Dates, Times and Durations

`time`package -- which is the part of the stdlib responsible for representing moments in time and durations. The `time`package provides features for measuring durations and expressing dates and times -- in the section:

- `Now()`-- creates a `Time`representing the current 
- `Date(y,m,d,h,min,sec,nsec,loc)`-- creates a `Time`representing a specified moment in time.
- `Unix(sec,nsec)`-- creates a `Time`from the number of s and ns since Jan 1, 1970

And the components of a `Time`are accessed through the methods described like:

- `Date()`-- returns the year, month, and day
- `Clock()`-- returns the hour,minutes and seconds
- `Year(), YearDay(), Month(), Day(){for month}, Weekday()`
- `Hour(), Minute(), Second(), Nanosecond()`

And two types are defined to help describe the components of a `Time`value -- 

- `Month`-- type represents a month -- and the `time`package defines constant values for the English-language name
- `Weekday`-- represents a day of the week.

```go
func PrintTime(label string, t *time.Time) {
	Printfln("%s: Day: %v: Month: %v Year: %v",
		label, t.Day(), t.Month(), t.Year())
}

func main() {
	current := time.Now()
	specific := time.Date(1995, time.June, 9,
		0, 0, 0, 0, time.Local)
	unix := time.Unix(1433228080, 0)
	PrintTime("Current", &current)
	PrintTime("Specific", &specific)
	PrintTime("UNIX", &unix)
}
```

The statements in the `main`create 3 different `Time`values using the functions. Just note that the last arg to the `Date`function is a `Location`-- which specifies the location whose time zone will be used for the `Time`value.

### Formatting Times as Strings

The `Format`method is used to create formated strings from `Time`values -- the format of the string is specified by providing a layout string -- which shows how which components of `Time`are required and the order and precision.

`Format(layout)`-- note, the layout string uses a reference time, which is **15:04:05** on **Monday, Jan 2nd, 2006** In MST time zone. just like:

```go
func PrintTime(label string, t *time.Time) {
	layout := "Day: 02 Month: Jan Year: 2006"
	fmt.Println(label, t.Format(layout))
}
```

so the layout can mix date components with fixed strings, and in the template, have used a layout to re-create the format used in eariler. And the `time`package also defines a set of constants for common time and date formats.

`ANSIC UnixDate RubyDate`... fore:

```go
func PrintTime(label string, t *time.Time) {
	fmt.Println(label, t.Format(time.RFC822Z))
}
```

### Parsing Time values from a String

The `time`package also provides support for creating `Time`values from strings. like:

- `Parse(layout, str)`-- parses a string using the specified layout to create a `Time`value
- `ParseInLocation(layout, str, location)`

Both -- An `error`is returned to indicate problems.

```go
func main() {
	layout := "2006-Jan-02"
	dates := []string{
		"1995-Jun-09",
		"2015-Jun-02",
	}

	for _, d := range dates {
		time, err := time.Parse(layout, d)
		if err == nil {
			PrintTime("parsed", &time)
		} else {
			Printfln("Error: %s", err.Error())
		}
	}
}
```

### Manipulating Time values

The `time`defines methods for working with `Time`values. like:

- `Add(duration), Sub(time), AddDate(y, m, d)`
- `After(time)`-- returns `true`if the `Time`on which the method has been called occurs after the `Time`provided.
- `Before(time)`-- like upper
- `Equal(time)`
- `IsZero()`
- `Round(duration)`
- `Truncate(duration)`

### Durations

The `Duration`is just an alias to the `int64`type and is used to represent a specific number of milliseconds.

`Hour, Minute, Second...`, and once a `Duration`object has been created, can be inspected using the methods:
`Hours(), Minutes()...`

```go
func main() {
	var d time.Duration = time.Hour + (30 * time.Minute)

	Printfln("hours: %v", d.Hours())
	Printfln("minutes: %v", d.Minutes())
	Printfln("Seconds: %v", d.Seconds())
	Printfln("Milliseconds: %v", d.Milliseconds())
}
```

### Creating Durations Relative to a Time

The `time`defines two functions that can be used to create `Duration`values that represent the amount of time between specific `Time`and current `Time`. like:

- `Since(time)`-- returns a `Duration`since...
- `Unitl(time)`-- until the specified `Time`value.

Creating Durations from Strings -- `ParseDuration(str)`-- `h m s ms...`

```go
func main() {
	d, err := time.ParseDuration("1h20m")
	if err == nil {
		Printfln("hours: %v", d.Hours())
	} else {
		fmt.Println(err.Error())
	}
}
```

### Using the Time Features for Goroutines and Channels

The `time`package also provides a small set of functions that are useful for working with goroutines and channels.

- `Sleep(duration)`-- pauses current goroutine
- `AfterFunc(duration, func)`-- The func executes the specified function in **its own** goroutine after the specified duration and the result is a `*Timer`-- whose `Stop()`can be used to cancel the execution of the function before the duration elapsed.
- `After(duration)`-- returns a channel that blocks for the specified duration and then yields a `Time`value
- `Tick(duration)`-- returns a channel that periodically sends a `Time`, where the period is specified as a duration.

The `Sleep`pauses execution of the current goroutine for a specified duration like:

```go
func writeToChannel(channel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
		time.Sleep(time.Second)
	}
	close(channel)
}

func main() {
	nameChannel := make(chan string)
	go writeToChannel(nameChannel)
	for name := range nameChannel {
		Printfln("Read name: %v", name)
	}
}
```

And the duration specified by the `Sleep`is the minimum amount of time for which the goroutine will be paused.

### Deferring Execution of a Function

The `AfterFunc()`is used to defer the execution of a function for a specified period, like:

```go
time.AfterFunc(time.Second*5, func() {
    writeToChannel(nameChannel)
})
```

The argument is the delay period, which is 5s.

Receiving Timed Notification -- The `After()`waits for a specified duration and then sends a `Time`value to a channel.

```go
func writeToChannel(channel chan<- string) {
	Printfln("Waiting for initial duration...")
	<-time.After(time.Second * 2)
	Printfln("Initial duration elapsed")
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
		time.Sleep(time.Second)
	}
	close(channel)
}

func main() {
	nameChannel := make(chan string)
	go writeToChannel(nameChannel)
	for name := range nameChannel {
		Printfln("Read name: %v", name)
	}
}
```

The result from the `After()`is a channel that carries `Time`values -- the channel blocks for the specified duration, when a `Time`value is sent, indicating the duration has passed. And the effect of the `After`in this case is the same as using the `Sleep`function.

### Using Notifications as Timeout in `select`statements

The `After`can be used with `select`statements to provide a timeout like:

```go
func main() {
	nameChannel := make(chan string)
	go writeToChannel(nameChannel)
	channelOpen := true

	for channelOpen {
		Printfln("Starting Channel read")
		select {
		case name, ok := <-nameChannel:
			if !ok {
				channelOpen = false
				break
			} else {
				Printfln("Read name: %v", name)
			}
		case <-time.After(time.Second * 2):
			Printfln("Timeout")
		}
	}
}
```

So the `select`will block until one of the channels is ready or until the timer expires. This works cuz the `select`will block until one of its channel is ready and cuz the `After()`creates a channel that blocks or specified period.

### Stopping and Resetting Timers

The `After`is useful when are sure that you will always need the timed notification -- if you need the option to cancel the notification, then the function can be used instead.

`NewTimer(duration)`-- returns a `*Timer`with the specified period.

- `C`-- returns the channel over whcih the `Time`will send its `Time`value.
- `Stop()`-- stops the timer
- `Reset(duration)`-- stops a timer and reset it so its interval is the specfied Duration

```go
func writeToChannel(channel chan<- string) {
	timer := time.NewTimer(time.Minute * 10)
	go func() {
		time.Sleep(time.Second * 2)
		Printfln("Resetting timer")
		timer.Reset(time.Second)
	}()

	Printfln("Waiting for initial duration...")
	<-timer.C
	Printfln("initial duration elapsed")

	names := []string{"Alcie", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
	}
	close(channel)
}

func main() {
	nameChannel := make(chan string)
	go writeToChannel(nameChannel)
	for name := range nameChannel {
		Printfln("Read name: %v", name)
	}
}
```

In this, the `Timer`is created with a duration of ten minutes, but sleeps for 2s and then resets the timer so just two seconds, then `<-timer.C`just trigger that.