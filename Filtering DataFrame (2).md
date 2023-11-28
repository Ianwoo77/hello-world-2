# Filtering DataFrame (2)

Using `loc`and `iloc`*accessor* -- when know the index lables and positions of the rows/columns we want to target. Sometimes, may want to target rows not by an idientifer but by a condition or a criterion. How to declare a logical conditions that include and exclude rows from a `DataFrame`-- how to combine multiple conditions by using `AND`and `OR`logic -- introduce some pandas utility methods that simplify the filtering process.

### Optimizing a data set for memory use

For the *best* data type is the one that consumes the least memory or privdes the most utility. So if data set includes whole numbers, it’s just ideal to import them as integers rather than float. Or, if datat set includes dates, it’s also ideal to import them as datetimes rather than as strings, which allows for datetime-specific operations.

`pd.read_csv('../pandas-in-action/chapter_05_filtering_a_dataframe/employees.csv')`here, notice the `NaN`s scattered throughout the output. Every columns has missing values and the last row consists only of `Nan`.

`employees.info()`

Converting data types with the `astype`method -- Noticed that pandas imported the `Mgmt`column’s values as strings. And the column just stores only two values `True`and `False`, can reduce memory by using converting values tot he more lightweight boolean data type like: -- the `astype()`converts a `Series`values to diferent data type. Like:

`employees['Mgmt'].astype(bool)`

Can just over-write the existing column in employees -- updating a `DataFrame`column works similarly to setting a k-v pair in a dictionary. If a column with the specified name exists, pandas creates a new `series`and appends it to the right of the `DataFrame`. just like:

`employees['Mgmt']=employees['Mgmt'].astype(bool)`

have reduced the `employees'`memory use. Next, transition to the `Salary`-- open raw -- can see the value store as whole numbers -- by default, pandas stores the Salary values as floats. 

Note that following example -- `employees["Salary"].astype(int)`-- ValueError raised -- Cuz pandas is unable to convert the `NaN`value to integers. Can solve this problem by replacing the NaN values with a constant value., using the `fillna()`method replaces a Series’ null values.
`employees['Salary'].fillna(0).tail()` So:

`employees['Salary']=employees['Salary'].fillna(0).astype(int)`

And, can make one additional optimizaiton -- pandas includes a special data type called a *category* -- which is ideal for a column just consisiting of a small number of unique values relative to its totoal size. Some everyday examples of data points with a limited number of values include gender .. so: first:
`employees.nunique()`

Use the `astype`again -- conert the `Gender`column’s value to categories by passing an argument of `category`like:
`employees['Gender']=employees['Gender'].astype('category')`then repeat the same process for the `Team`column-- like: `employees['Team']=employees['Team'].astype('category')`

### Fitlering by a single condition

Extracting a subset of data is perhaps the most common op in data analysis -- a *subset* is a porition of a larger data set that fits some kind of condition. like:
`employees[employees['First Name']=='Maria']`

And, if use of multiple square bracket is confusing, just assign a `Boolean`series.

Filtering by multiple conditions -- Can filter a `DataFrame`with just multiple conditions by creating two independent series and then declaring the logic criterion that pandas should apply between them. Like:

```python
is_female = employees['Gender']=='Female'
in_biz_dev = employees['Team']=='Business Dev'
employees[is_female & in_biz_dev].head()
```

The OR condition -- can also extract rows if they fit one of several conditions -- not all conditions have to be true. Just like: `employees[enrning_below_40k | started_after_2015]`

Inversion with ~ -- `~`inverts the values in a Boolean Series, All `True`values become `False`. Like:
`employees[~(employees['Salary']>=100000)].head()`

Methods for Booleans -- Pandas provides an alternative syntax for analysts who perfer methods over operators. the following table displays the method alternatives -- eq, ne, lt, le, gt, ge.

### Filtering by condition

The `isin`-- what if want to isolate the employees who belong to either the `Sales..`, A better solution is to use the `isin`method -- which accepts an iterable of elements. like:

```python
on_all_star_teams=employees['Team'].isin(['Sales', 'Legal', 'Marketing'])
employees[on_all_star_teams]
```

The `between`accepts a lower bound and an upper bound -- returns a `Boolean`series where `True`denotes that a row’s value falls between the specified interval
`employees[employees.Salary.between(80000,90000)].head() # [) scope`

The `between` also works on columns of other data types. To filter datetimes, can pass strings for the start and end dates of time range like:

```python
eighties_folk= employees['Start Date'].between(
    left='1980-01-01', 
    right='1990-01-01'
)
employees[eighties_folk].head()
```

Can also apply `between`to string columns, extract all employees whose first name starts with the letter `R`, and non-inclusive upper bound `S`like:
`employees[employees['First Name'].between('R', 'S')]`

The `isnull`and `notnull`methods -- the data set includes plenty of missing values. -- Pandas marks missing text value and mising numeric with a `NaN`and datetime values with `NaT`. Can use several pandas methods to isolate rows with either null or present values in a given column.

```python
employees['Team'].isnull().head()
# considers the `NaT`and `None`values to be null as well
employees['Start Date'].isnull().head()

employees['Team'].notnull().head()
# produce like:
(~employees['Team'].isnull()).head()

# use Series to extract specific DF rows
no_team = emploees['Team'].isnull()
```

Dealing with `null`-- The `dropna()`method removes DF rows that hold an `NaN`values. It doesn’t matter how many values a row is missing -- the method excludes the row if a single `NaN`is present. Fore:
`employees.dropna()`

Can pass the `how`parameter an argument of `all`to remove rows in which **all** values are missing.
`employees.dropna(how='all').tail()` note that the default value of how is `any`. Also, can use `subset`parameter to target rows with a missing value in a specific column. 
`employees.dropna(subset=['Gender']).tail()`

Can also pass the `subset`a list of columns. For this, Pandas will remove a row if it has a missing value **in any** of the specified columns. like:
`employees.dropna(subset=[“Start Date’, ‘Salary’]).head()`

And the `tresh`parameter specifies a minimum threhold of non-null value that a row must have for pandas to keep it.
`employees.dropna(how='any', thresh=4)`-- The `thresh`is **great** when a certain number of missing values renders a row useless for analysis.

## Decoding Structs

The k-v structure of JSON objects can be decoded into Go struct values.

```go
func main() {
	reader := strings.NewReader(`
	{"Name":"Kayak","Category":"Watersports","Price":279}
	{"Name":"Lifejacket","Category":"Watersports" }
	{"name":"Canoe","category":"Watersports", "price": 100, "inStock": true }
`)
	decoder := json.NewDecoder(reader)

	for {
		var val Product
		err := decoder.Decode(&val)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		} else {
			// note that the field must be export
			Printfln("Name: %v, Category: %v, Price: %v",
				val.Name, val.Category, val.Price)
		}
	}
}
```

So the `Decoder`decodes the JSON object and uses the kwys to set the vlaues of the **exported** struct fields. Note that the capitalization of the fields and JSON keys don’t have to match, and the `Decoder`will ignore any JSON key for which there isn’t a struct filed and ignore any struct field for which there is no JSON keys.

### Disallowing Unused Keys

By default, the `Decoder`will ignore JSON keys for which there is no corresponding struct field. This can be changed by calling the `DisallowUnknownFields()`-- like:

```go
decoder := json.NewDecoder(reader)
decoder.DisallowUnknownFields()
```

Error raised for this call.

Using struct Tags to control Decoding -- The keys used in a JSON object don’t always align with the fields defined by the struct in a Go project. like:

```go
type DiscountProduct struct {
	*Product `json:",omitempty"`
	Discount float64 `json:"offer,string"`
}
```

This tag applied to the `Discount`field, tells the `Decoder`will be obtained from the JSON keys named `offer`.

```go
func main() {
	reader := strings.NewReader(`
	{"Name":"Kayak","Category":"Watersports","Price":279, "offer": "10"}
`)
	decoder := json.NewDecoder(reader)

	for {
		//...
		} else {
			// note that the field must be export
			Printfln("Name: %v, Category: %v, Price: %v, Discount:%v",
				val.Name, val.Category, val.Price, val.Discount)
		}
	}
}
```

### Creating completely custom JSON Decoders

The `Decoder`checks to see whether a struct implements the `Unmarshaler`interface -- which denotes a type that has a custom encoding, and which defines the method like:

- `UnmarshalJSON(byteSlice)`-- This method is invoked to decode JSON data contained in the specified byte slice, the resul tis an `error`indicating encoding problem.

```go
func (dp *DiscountProduct) UnmarshalJSON(data []byte) (err error) {
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
			fpval, fperr := strconv.ParseFloat(discount, 64)
			if fperr == nil {
				dp.Discount = fpval
			}
		}
	}
	return
}
```

Just note in the reader, the `Offer`must be captilized. And this implementation of the `UnmarshalJSON`method to decode the JSON data into a map and then checks the type of each value required for the `DiscountedProduct`.

## Working with Files

Describe the features that the Go stdlib provides for working with files and directories. 

### Reading Files

Key package when dealing with files is the `os`pacakge-- this provides access to operating system features -- including file system -- in a way that hides most of the implementation details.

- `ReadFile(name)`-- Opens the specified and reads its contents -- results are a `byte`slice, containing the file content and an `error`indicating problems opening or reading the file.
- `Open(name)`-- Result is a `File`struct and an `error`

Add a file named `config.json`like:

```json
{
  "Username": "Alice",
  "AdditionalProducts": [
    {
      "name": "Hat",
      "category": "Skiing",
      "price": 10
    },
    //...
  ]
}
```

One of the most common reasons to read a file is to load configuration data. The JSON formats is well-suited for configuration files cuz it is simple to process, has a good support in the Go stdlib.

### Using the Read convenience Function

The `ReadFile`func provides a convenient way to read the complete contents of a file into a byte slice in a single step.

```go
func LoadConfig() (err error) {
	data, err := os.ReadFile("config.json")
	if err == nil {
		Printfln(string(data))
	}
	return
}

func init() {
	err := LoadConfig()
	if err != nil {
		Printfln("Error loading Config: %v", err.Error())
	}
}
```

Decoding the JSON data - For the example configuration file, receiving the contents of the file as a string is just not ideal -- and a more useful approach would be to parse the contents as JSON -- which can be easily done by wrapping up the byte data so that it can be accessed through a `Reader` like:

```go
type ConfigData struct {
	UserName           string
	AdditionalProducts []Product
}

var Config ConfigData

func LoadConfig() (err error) {
	data, err := os.ReadFile("config.json")
	if err == nil {
		decoder := json.NewDecoder(strings.NewReader(string(data)))
		err = decoder.Decode(&Config)
	}
	return
}

func init() {
	err := LoadConfig()
	if err != nil {
		Printfln("Error loading Config: %v", err.Error())
	} else {
		Printfln("Username: %v", Config.UserName)
		Products = append(Products, Config.AdditionalProducts...)
	}
}

```

### Using the File struct to read a file

The `Open`func opens a file for reading and returns a `File`struct value, which represent the open file, and an error, which is used to indicate problems opening the file -- and the `File`struct implements the `Reader`-- which makes it simple to read and process the example json data -- without reading the entire file into a byte slice.

```go
func LoadConfig() (err error) {
	file, err := os.Open("config.json")	
	if err == nil {
		defer file.Close()
		decoder := json.NewDecoder(file)
		err = decoder.Decode(&Config)
	}
	return 
}
```

So the `File`also implement the `Closer`interface -- which defines a `Close`-- the `defer`can be used to call the `Close`method when the enclosing function completes.

### Reading from a specific Location

The `File`defines methods beyond those required by the `Reader`interface and allows reads to be peformed as a specific location in the file like:

- `ReadAt(slice, offset)`-- is defined by the `ReaderAt`interface and performs a read into the specific slice at the specified position offset in the file.
- `Seek(offset, how)`-- defined by the `Seeker`interface -- moves the offset into the file for the next read. For the `how`-- 0 for start, 1 for current, 2 for end

```go
func LoadConfig() (err error) {
	file, err := os.Open("config.json")
	if err == nil {
		defer file.Close()

		nameSlice := make([]byte, 5)
		file.ReadAt(nameSlice, 17)
		fmt.Println(string(nameSlice))
		Config.UserName = string(nameSlice)

		file.Seek(50, 0)
		decoder := json.NewDecoder(file)
		err = decoder.Decode(&Config)
	}
	return
}
```

### Verifying the test

it’s just helpful to think about ways the test could be *wrong* -- and see if we can work out how to catch them -- one major way the test could be wrong is that it might not fail when it’s supposed to. test in Go pass by default. Fore:

`func TestAlwaysPasses(t *testing.T){}`

But htere are more subtle ways to accidentally write a useless test. Fore:

```go
if want != want {
    t.Errorf("want %q, got %q", want, got)
}
```

Until you have seen the test fail as expected -- otherwise, don’t really have a test. So can’t be sure that the test doesn’t contain logic bugs unless seen it fail when it’s supposed to. When *should* the test fail.

Goroutines -- Are one of the most basic units of organization in a Go program -- so important we understand what they are and how they work. Every Go program has at least one gorouine -- *main*-- automatically created and started when the process begin.

Goroutines are unique to Go -- they are not OS threads -- and they are not exactly green threads. They are just higher level of abstraction known as coroutines. Are a simple concurrent subroutines that are nonpreemptive. Canot be interrupted. And what makes goroutines unique to Go are their deep integration with Go’s runtime.