# Merge Conflict

Can move over to hello-world-images and keep working. When modified on master also hello, so:

```sh
git checkout master
git merge hello-world-images # merge failed there is a conflict between the versions.
```

Then can see the differences between the versions and edit it like we want.

```sh
# then edit
#
git add index.html
git status
git commit -m "merged with hello and master"
git branch -d hello-world-images
```

## The DF object

2d table of data with rows and columns. Also assigns an index label and an index position to each `DataFrame`row.

creating from a dict -- The ctor’s first parameter, `data`expects the data that will populate the `DataFrame`. And one suitable input is a Py dictionary in which the keys are columns names and the values are column values.

```python
city_data = {
    "City": ["New York City", "Paris", "Barcelona", "Rome"],
     # ...
}
cities = pd.DataFrame(city_data)
cities
```

Did not provide the ctor a custom index, so starting at 0

```python
cities.transpose()
cities.T
```

Serves as a remainder that pandas can store index lables of different data types. `transpose()`or `T`attribute.

### Creating from a Numpy ndarray

Can create an `ndarray`of any size with the `randint`func.

```python
random_data= np.random.randint(1, 101, [3,5])
random_data
pd.DataFrame(random_data)
# manually set the row label with the ctor's `index` parameter
row_label = ['Morning','Afternoon', 'Evening']
tempatures = \
pd.DataFrame(random_data, index=row_label)
tempatures
#
# can set the column names with the ctor's `columns` parameter like:
column_labels = [datetime.date(2024, 4, day).strftime("%A") for day in range(1, 6)]
tempatures = pd.DataFrame(random_data, index=row_label, columns=column_labels)
#
# also, permists duplicates in the row and column indicies -- in the next like:
row_labels = ["Morning", "Afternoon", "Morning"]
```

### Similarities between Series and DataFrames

Many `Series`attributes and methods are also available on `DataFrame`. Before assigning the `DataFrame`to a variable, let’s make one optimization -- pandas imports the `Birthday`as strings rather than a datetimes -- `parse_date`parameter to coerce the values into datetimes.

```python
nba = pd.read_csv('nba.csv', parse_dates=['Birthday'])
```

#### Shared and exclusive attributes of Series and DataFrames -- 

May differ between `Series`and `DataFrames`-- both in name and implementation. Here is an example -- `Series`has a `dtype`attribute that revels the data type of its values.

```python
pd.Series([1,2,3]).dtype # int64
# DataFrame can hold heteogeneous data -- mixed and varied
nba.dtypes
# can also invoke the `value_counts` method on the `Series`to count the number of columns storing 
nba.dtypes.value_counts()
# index expose index of the df
nba.index # get a RangeIndex object, has start, stop, and step.
#
# can also use columns attribute get columns
nba.columns # Index object returned uses this when an index consists of text
#
# ndim returns the number of dimensions in pandas object
nba.ndim
nba.shape # (450, 5)
# 
# size calcuates the total number of values in the dataset
nba.size
#
# exclude missing values, using count()
nba.count()
```

Fore, illustrating the differences between the `size`and the `count`method like:

```python
data = {
    "A": [1, np.nan],
    "B": [2, 3]
}
df = pd.DataFrame(data)
print(df.size)  # 4
print(df.count().sum()) # 3
```

#### Shared methods of Series and DataFrames -- 

DF and Series have methods in common too. Can use the `head`to extract rows from the top of a `DF`.

```python
nba.sample(3)
nba.nunique()
nba.max()
nba.min
#
# nlargest and nsmallest need `columns` parameter like:
nba.nlargest(n=4, columns=['Salary'])
nba.nsmallest(n=3, columns='Birthday')
#
# calculate the sum of all salaries
nba.sum(numeric_only=True)
nba.mean(numeric_only=True)
```

### Sorting a DataFrame

Our data set’s row arrived in jumbled, random order -- can sort -- 

```python
# The two lines below equ
nba.sort_values('Name')
nba.sort_values(by='Name')
# descending sort
nba.sort_values('Name', ascending=False).head()
```

#### Sorting by multiple columns 

Can sort multiple columns in a Df by passing a list of `sort_values`method’s `by`parameter. Pandas will sort the DF’s columns consecurtively in the order in which they appear in the list.

```python
nba.sort_values(by=["Team", "Name"])
nba.sort_values(["Team", "Name"], ascending = False)
# sort each column in different order like:
nba.sort_values(['Team', 'Salary'], ascending=[True, False])
```

### Sorting by Index

With permanent sort, the index -- could sort the data set by index position rather than by column values, could return it to its original shape. Using `sort_index()`method does just that like:

```python
nba.sort_index()
nba.sort_index(ascending=False).head()
```

#### Sorting by column index -- 

A DF is 2D data structure, can sort an additional axis - the vertical aixs -- `axis`parameter set to `columns`or `1`.

```python
nba = nba.sort_index(axis='columns')
nba.sort_index(axis=1, ascending = False).head()
```

### Setting a new index

At its core, our data set is a collection of of players. `set_index`method returns a new DF with a given column set as the index. `nba.set_index('Name')`

```python
nba = pd.read_csv('nba.csv', parse_dates=["Birthday"], index_col='Name')
```

### Selecting columns and rows from a DF

```python
nba.Salary
nba['Position']
```

#### Selecting multiple columns from DF -- 

To extract multiple DF columns, declare a pair of opening and closing square brackets. Just like:

```python
nba[['Salary', 'Birthday']]
```

Can also use the `select_dtypes`method to select columns based on their data types. `include`and `exclude`parameters - accept a single string or a list. like:

```python
nba.select_dtypes(include='object')
nba.select_dtypes(exclude=['object', 'int'])
```

### Selecting Rows from a DF

The `loc`**attribute** practiced extracting columns. Call attributes as `loc`accessors cuz they access a piece of data.

`nba.loc['LeBron James']`Can pass a lsit in between the `[]`to extract multiple rows, when the results set include multiple records, pandas stores the result in a DF like: `nba.loc[['Kawhi Leonard', 'Paul George']]`
Can also

```python
nba.sort_index().loc["Otto Porter": "Patrick Beverley"]
```

Just note that the panda’s `loc`has some differences with the list-slicing syntax. Including.

## Using Mehtods and Interfaces

### Defining and using methods -- 

```go
func printDetails(product *Product) {
	fmt.Println("Name:", product.name, "Category:", product.category,
		"price:", product.price)
}
func (product *Product) printDetails() {
	fmt.Println("Name:", product.name, "Category:", product.category,
		"price:", product.price)
}
```

Methods are defined as functions, using the same `func`but have the addition of a `receiver`. Which can be used within the method just like any normal function parameters.

#### Defining Method Parameters and Results -- 

Methods can define parameters and results, just like regular functions -- 

```go
func (product *Product) calcTax(rate, threshold float64) float64 {
	if product.price > threshold {
		return product.price + (product.price * rate)
	}
	return product.price
}
```

#### Method overloading -- 

Go does not support method overloading. Instead, each combination of method name and receive type must be just unique, regardless of the other paramters that are defined.

### Understanding Pointer and Value receviers#

A method whose receiver is a pointer type that can also be invoked through a regular value of the underlying type. Go just takes care of the mismatch and invokes the method seamlessly. Fore:

```go
func (product Product) printDetails() {...}
func main(){
    kayak := &Product {...}
    kayak.printDetails() // ok
}
```

Defining for Type Aliases -- Methods can be defined for any type defined in the current pacakge.

```go
func (products *ProductList) calcCategoryTotals() map[string]float64 {
	totals := make(map[string]float64)
	for _, p := range *products {
		totals[p.category] = totals[p.category] + p.price
	}
	return totals
}

func main() {
	products := ProductList{
		{"Kayak", "Watersports", 275},
		{"Lifejacket", "Watersports", 48.95},
		{"Soccer Ball", "Soccer", 19.50},
	}

	for cat, total := range products.calcCategoryTotals() {
		fmt.Println("Category:", cat, "Total:", total)
	}
}
```

### Putting Types and Methods in separate Files

```go
type Service struct {
	description    string
	durationMonths int
	monthlyFee     float64
}
```

Defining and using Interfaces -- It is just esy to imagine a scenario where the `Product`and `Service`types defined in the previous section are used together. Like:

```go
type Expense interface {
	getName() string
	getCost(annual bool) float64
}
```

For this, descries two methods, `getname()`and `getCost()`.

Implementing -- To implement -- specified by the interface must be defined for a struct type.

```go
func (p Product) getName() string {
	return p.name
}

func (p Product) getCost(_ bool) float64 {
	return p.price
}
func (s Service) getName() string {
	return s.description
}
// ..
func (s Service) getCost(recur bool) float64 {
	if recur {
		return s.monthlyFee * float64(s.durationMonths)
	}
	return s.monthlyFee
}
//. ...
func main() {
	expenses := []Expense{
		Product{"Kayak", "Watersports", 275},
		Service{"Boat Cover", 12, 89.50},
	}
	for _, expense := range expenses {
		fmt.Println("Expenses:", expense.getName(), "Cost:", expense.getCost(true))
	}
}
```

Variables whose type is an interface have two types, the *static* and *dynamic* type. The static type is the interface type, and the dynamic type is the type of value assigned to the variable that implements the interface, fore, `Product`or `Service`in that case.

### Using an interface in a Function

Interface types can be used for variables, function parameters, and function results, like:

```go
func calcTotal(expenses []Expense) (total float64) {
	for _, item := range expenses {
		total += item.getCost(true)
	}
	return
}
```

#### Using an interface for Struct Fields -- 

Interface types can be used for struct fields, which means that fields acna be assigned values of any type that implements the methods defined by the interface.

```go
type Account struct {
	accountNumber int
	expenses      []Expense
}

func main() {
	account := Account{
		accountNumber: 12345,
		expenses: []Expense{
			Product{"Kayak", "Watersports", 275},
			Service{"Boat Cover", 12, 89.50},
		},
	}
	for _, expense := range account.expenses {
		fmt.Println("Expenses:", expense.getName(), "Cost:", expense.getCost(true))
	}
	fmt.Println(calcTotal(account.expenses))
}
```

#### Understanding the Effect of Pointer Method receivers -- 

The methods defined by the `Product`and `Service`type have value receivers, which means that the methods will be invoked with copies of the `Product`or `Service`value.

```go
func main() {
	product := Product{"Kayak", "Watersports", 275}
	var expense Expense = product
	product.price = 100
	fmt.Println(product.price)
	fmt.Println(expense.getCost(false))  // 275 still
}
```

So, the `Product`value was copied when it was assigned to the `Expense`variable, which means that the change to the `price`field does not affect the result from the `getCost`method. Just: `var expense Expense = &product`Using a pointer means that the reference to the `Product`value is assigned to the `Expense`variable.

Can just force the use of references by specifying pointer receivers when implementing the interface methods like:

```go
func (p *Product) getName() string {
    return p.name
}
```

Means that the `Product`type no longer implemens the `Expense`interface cuz the required methods are no longer defined. It is the `*Product`type that implements the interface.

### Comparing Interface Values

Can be compared with Go comparison operators. Care must be taken when comparing interface values, and inevitably, some knowledge of the dynamic is required -- like:

```go
func main() {
    var e1 Expense = &Product {name: "Kayak"}
    var e2 Expense = &Product {name: "Kayak"} // e1 != e2
    // cuz the dynamic type for these is a pointer
    
    var e3 Expense = Service {...}
    var e4 Expense = Service {...} // e3==e4
}
```

Interface equality checks can also cause runtime errors if the dynamic type is not comparable. fore:

```go
type Service struct {
    //...
    features []string // slices are not comparable.
}
```

### Performing Type Assertions

Interfaces can be useful, can present problems. It is often useful to be able to access the dynamic type directly. Which is known as a *type narrowing*. Fore:

```go
func main() {
    expenses = []Expense {
        Service {...}
        Service {...}
    }
    for, expense := range expenses {
        s := expense.(Service)
        fmt.Println(s.description)
    }
}
```

#### Testing before performing a Type Assertion -- 

When a type assertion is used, the compiler trusts that the programmer has more knowledge and knows more about the dynamic types in the code than infer. The Go runtime has tried like:

```go
for _, expense := range expenses {
    if s, ok := expense.(Service); ok {
        ...
    }else {
        fmt.Println(expense.getName())
    }
}
```

#### Switching on Dynamic Types -- 

Go `switch`can be used to access dynamic types like:

```go
for _, expense := range expenses {
    switch value := expense.(type) {
    case Service:
        fmt.Println(value.description)
    case *Product:
        fmt.Println(value.price)
    default:
        fmt.Println(expense.getName())
    }
}
```

Each `case`specifies a type and a block of code that will be executed when the value evaluated by the `switch`has the specified type.

### Using Empty interface -- 

Go allows of the empty interface -- which just an interface that defines no methods. FORE:

```go
data := []interface{} {
    expense,
    Product {...},
    100,
    true,
}
for _, item : = range data {
    switch value := item.(type) {
    case Product:
        fmt.Println("Product")
    case Service:
        fmt.Println("Service")
    case string, bool, int:
        fmt.Println("Built-in type")
    default:
        fmt.Println("Unknown type")
    }
}
```

Using for Function Parameters -- The empty can be used as the type for a function parameter, allowing a function to be called with any value.

```go
func processItem(item interface{}) {
    switch value := item.(type) {
        case ...
    }
}
```

And the empty interface can also be used for variadic:

```go
func processItems(items ...interface{}) {
    for _, item := range items {
        switch value := item.(type) {
            
        }
    }
}
processItems(data...)
```

