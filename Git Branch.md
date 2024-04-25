# Git Branch

In Git, a `branch`is a new/separate version of the main repository.

- with a new branch, edit the code directly without impacting the main branch
- FORE, there is an unrelated error somewhere else in the proj that needs to be fixed ASAP
- Create a new branch from the main proj called small-error-fix
- Fix the unrelated error and merge the small-error-fix branch with main.

```sh
# add some new features to index.html
git branch hello-world-images # create a new branch
git branch # confirm and show, * beside the master now
git checkout hello-world-images # switched to branch newly created
# then modify or add some new file under current direct
git status # changes not staged for commit, has some untracked files
git add --all
git status 
git commit -m "Added image to hello world" # for now, have a new branch, different from the master note
# using -b option on checkout will create a new branch, 
```

### Switching between Branches -- 

Are currently on the branch `hello-world-images`.

```sh
git checkout -b emergency-fix # switched to a new branch 'emergency-fix'
# make some changes to index.html
git add index.html
git commit -m "updated index.html with emergency fix" # note that, must do 
```

### Merge

Have the emergency fix ready, merge the master and emergency-fix branches -- need to change to the master first.

```sh
git checkout master # for now, can't checkout to others other than master
git merge emergency-fix # since the emergency-fix came directly from master
```

And, no other changes had been made to master while we were working, git sees this as a continuation of master. And a master and emergency-fix are essentially the same now, can delete emergency-fix:

```sh
git branch -d emergency-fix
```

### Merge Conflict

Now can move over to hello-world-images and keep working.

```sh
git checkout hello-world-images
git add --all
git commit -m "added new image"
```

See that `index.html`file has been changed in both branches, now are ready to merge into master.

## Series methods

```python
pd.read_csv(filepath_or_buffer='pokemon.csv')
```

Note that the `read_csv`function always imports the data into a `DataFrame`-- a 2D pandas data structure that supports multiple rows and columns. First issue is that the data set has two columns, but a `Series`supports only one column of data. One simple solution is setting one of the data set’s columns as the `Series`index.

```python
# still a DataFrame object imported
pd.read_csv('pokemon.csv', index_col='Pokemon')
pd.read_csv('pokemon.csv', index_col='Pokemon').squeeze()
```

When importing a dataset, pandas infers the most suitable data type for each column. Sometimes, the library plays it safe and making assumptions about our data.

```python
pd.read_csv('google_stocks.csv', parse_dates=['Date'], index_col='Date').squeeze().head()
pd.read_csv('revolutionary_war.csv',
            index_col='Start Date', parse_dates=['Start Date']).tail()

battles = pd.read_csv(
    "revolutionary_war.csv",
    index_col="Start Date",
    parse_dates=["Start Date"],
    usecols=["State", "Start Date"],
).squeeze()
```

### Sorting a Series

Can sort a `Series`by its values or its index, in ascending or descending order. Just using `sort_values`or `sort_index`methods. like:

```python
google.sort_values()
pokemon.sort_values()
# sort uppercase before lowercase like:
pd.Series(['Adam', 'adam', 'Ben']).sort_values()
```

The `ascending`parameter sets the sort order, and it has a default argument of `True`, To sort `Series`values in descending order, pass the parameter an arg of `False`.

```python
google.sort_values(ascending=False).head()
```

And the `na_position`parameter configures the placement of `NaN`value is the returned `Series`and has a default argument of `last`.

```python
battles.sort_values(na_position='last')
```

Remove `NaN`-- The `dropna`method returns a `Series`with all missing values removed.

```python
battles.dropna().sort_values()
```

### Sorting by index with `sort_index`method -- 

With this option, the value move alongside their counterparts.

`pokemon.sort_index()`And, when sorting a collection of datetimes in ascending order. Pandas sorts from the earliest date to the latest.

#### Retrieving smallest and largest values with nsmallest and nlargest methods

`google.nlargest(n=5)`

And the `nsmallest`returns the smallest values from a `Series`.

### Counting values with `value_counts`method

How can find out the most common types of pokemon -- need to *group* the values into buckets and count the number of elements in each bucket. `pokemon.value_counts()`, returns a new `Series`object -- the index labels are the pokemon Series’ values. And the length of the `value_counts`series is equal to the number of unique values in the `pokemon`series. `len(pokemon.value_counts())`

Also can: `pokemon.value_counts(ascending=True`)`

```python
google.max()
# have a range between the smallest and largest values -- 
buckets= [0,200,400,600,800,1000,1200,1400]
google.value_counts(bins=buckets)
#
# for the last, pandas sorted the previous in descending order by the number of values
google.value_counts(bins=buckets).sort_index()
```

### Invoking a func on every Series with `apply`method -- 

```python
google.apply(func=round)
google.apply(round)
```

Also accepts custom functions.

```python
pokemon.apply(lambda pt: 'Multi' if '/' in pt else 'Single')
pokemon.apply(lambda pt: 'Multi' if '/' in pt else 'Single').value_counts()
```

## Understanding Function Types

Functions have a data type in Go, which means that they can be assigned to variables and used as function parameters, arguments, and results.

```go
func calcWithTax(price float64) float64 {
	return price + (price * .2)
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
		fmt.Println("product:", product, "Price", totalPrice)
	}
}
```

### Go function and the Zero Type

The go comparison operators cannot be used to compare functions, can be used to determine whether a function has been assigned to a variable. `fmt.Println("Function assigned:", calcFunc==nil)`

Using as Arguments -- Can be used in the same way as any other type, including as arguments for other functions.

```go
func printPrice(product string, price float64,
	calculator func(float64) float64) {
	fmt.Println("product:", product, "price;", calculator(price))
}
```

#### Using as results -- 

Functions can also be results, meaning that the value returned by a function is another function.

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

### Creating Function Type Aliases

```go
func selectCalculator(price float64) calcFunc {
	//...
}

type calcFunc func(float64) float64
```

Using the Literal Syntax -- The function literal syntax allows functions to be defined so they are specific to a region of code like:

```go
func selectCalculator(price float64) calcFunc {
	if price > 100 {
		var withTax calcFunc = func(price float64) float64 {
			return price + price*.2
		}
		return withTax
	}
	return calcWithoutTax
}
```

Also can:

```go
return func(price float64) float64 {
    return price
}
```

### Closures

Functions defined using the literal syntax can reference variable from the surrounding code.

```go
func priceCalcFactory(threshold, rate float64) calcFunc {
    return func(price float64) float64 {
        if price>threshold {
            return price+price*rate
        }
        return price
    }
}

// ...
waterCalc := priceCalcFactory(100, .2)
soccerCalc := priceCalcFactory(50, .1)
printPrice(product, price, waterCalc)
printPrice(product, price, soccerCalc)
```

### Defining Structs

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}

	kayak := Product{
		name:     "Kayak",
		category: "Watersports",
		price:    275,
	}
	fmt.Println(kayak.name, kayak.category, kayak.price)
	kayak.price = 300
	fmt.Println(kayak.price)
}

```

Values do not have to be provided for all fields when creating a struct value.

Using Field positions to create struct values -- Struct values can be defined without using names. Embedded fields like:

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}

	type StockLevel struct {
		Product
		count int
	}

	stockItem := StockLevel{
		Product{"Kayak", "Watersports", 275.00},
		100,
	}

	fmt.Println(stockItem.category)
}
```

Defining a named additional field:

```go
type StockLevel struct {
    Product
    Alternate Product
    count int
}
stockItem := StockLevel {
    Product {...}, 
    Alternate: Product {...}
}
```

And, if all their fields are equal, the struct value are equal. Note that structs cannot be compared if the struct type defines fields with *incomparable* types.

### Converting between Struct types

Note that a struct type can be converted into any other struct type that has the same fields, meaning all the fields have the same name and type and are defined in the same order.

Anonymous struct types are defined without using a name, like:

```go
func writeName(val struct {
    name, category string
    price float64
}) {
    fmt.Println(val.name)
}

func main() {
    type Item struct {
        name string
        category string
        price float64
    }
    item := Item {...}
    writeName(item)
}
```

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}

	prod := Product{
		"Kayak",
		"Watersports",
		275.00,
	}
	var builder strings.Builder
	json.NewEncoder(&builder).Encode(struct {
		ProductName  string
		ProductPrice float64
	}{
		ProductName:  prod.name,
		ProductPrice: prod.price,
	})
	fmt.Println(builder.String())
}
```

### Creating Arrays, slices, Maps containing struct values 

```go
type StockLevel struct {
    Product
    Alternate Product
    count int
}
array := [1]StockLevel {
    {
        Product: Product {...},
        Alternate: Product {...},
        count: 100,
    },
}
```

Understanding Structs and pointers -- Assigning a struct to a new variable or using struct as a function parameter creates a new value that *copies* the field values.

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}

	p1 := Product{
		"Kayak",
		"Watersports",
		275.00,
	}
	p2 := p1
	p2.name = "Original Kayak"
	fmt.Println(p1.name)
	fmt.Println(p2.name)
}
```

If using pointers like:

```go
//...
p2 := &p1
p1.name = "Original Kayak"
fmt.Println((*p2).name) // also original kayak
```

convenience Syntax -- So, accessing like this is awkward -- Which is an issue cuz are commonly used as a function arguments and results. To simplify this typ of code, jsut follow pointers to struct fields like:

```go
func calcTax(product *Product) {
    if(product.price>100) //...
}
```

Pointers to Values -- There is no need to assign a struct value to a variable before creating a pointer, and the address operator can be used directly with the literal struct syntax.

```go
func calcTax(product *Product) {
    //...
}
func main() {
    kayak := &Product {...}
    calcTax(kayak)
}
```

Also:

```go
func calcTax(product *Product) *Product {
    return product
}
func main(){
    kayak := calcTax(&Product {...})
}
```

### Struct Constructor Functions

A ctor function is responsible for creating struct values using values received through parameters.

```go
func newProduct(name, category string, price float64) *Product {
	return &Product{name, category, price}
}

func main() {
	products := [2]*Product{
		newProduct("Kayak", "Watersports", 275),
		newProduct("Hat", "Skiing", 42.50),
	}
	for _, p := range products {
		fmt.Println(p.name, p.category, p.price)
	}
}
```

So the benefit of using ctor functions is consistency.

Using Pointer types for Struct Fields -- Pointers can be used for `struct`fields, including pointers to other struct types.

```go
type Supplier struct {
	name, city string
}

func newProduct(name, category string, price float64, supplier *Supplier) *Product {
	return &Product{name, category, price, supplier}
}
```

Pointer Field Copying -- Care must be taken when copying structs to the effect on pointer fileds. For *shallow copy*, where pointers are copied but not the values to which they point, Go doesn’t have built-in support for performing a `deep`copy.

```go
func copyProduct(product *Product) Product {
	p := *product
	s := *product.Supplier
	p.Supplier = &s
	return p
}

func main() {
	acme := &Supplier{"Acme Co", "New York"}
	p1 := newProduct("Kayak", "Watersports", 275, acme)
	p2 := copyProduct(p1)
	p1.name = "Original kayak"
	p1.Supplier.name = "BoatCo"

	for _, p := range []Product{*p1, p2} {
		fmt.Println(p.name, p.Supplier.name, p.Supplier.city)
	}
}
```

To ensure the `Supplier`is duplicated, the `copyProduct`function assign it to a separate variable and then creates a pointer to that variable.

Zero value for structs and pointers to structs - The zero value for struct type is a struct value whose field are just assigned their zero type. The zero value for a pointer to a struct is `nil`. And there is a pitfall, which encounter often , when a struct defines a field with a pointer to another struct type. So:

```go
var prod Product = Product {Supplier: &Supplier{}}
```

