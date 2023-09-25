# Tourist spending per country

Before the pandemic used to travel internationally on a very regular basis, both for work and also for pleasure. The pandemic, has changed all of that, with many countries restrcting who can enter and liave -- Certainly a series problem for corporeate py trainers.

Created two separate data frames, then joined them together, so doing were able to create a report that used countries’ full names. like:

```python
filename = 'data/oecd_tourism.csv'
tourism_df= pd.read_csv(filename, 
                        usecols=['LOCATION', "SUBJECT", 'TIME', 'Value'])
```

This data frame -- contains info about the total amount spent, and the total amount received by a number of countries, over aboutt a decade. fore, what if want to find out the average amount of income that countries received in data set -- 

`tourism_df[tourism_df['SUBJECT']=='INT_REC']['Value'].mean()`

Selected those rows in which `SUBJECT`was `INT_REC`for received tourism funds, grouped by LOCATION, can get one result per value of `LOCATION`, aka country -- asked for only the `Value`column, invoked the `mean`method on each location’s values.

```python
tourism_df.loc[tourism_df['SUBJECT']=='INT_REC'].groupby('LOCATION')[
    'Value'].mean().sort_values(ascending=False).head()
```

Beyond the difference in string that we are matching in `SUBJECT`, also reversed the call to `sort_values`. And with the initial queries out of the way, can now use `join`to make an easier-to-read resport from created -- created a *two-column* csv file that you can read, however, quickly discover that this CSV file needs a bit of massaging if are going to use it. there isn’t a header now, so both need to state that and provdie our own names. Can use:

```python
filename='data/oecd_locations.csv'
locations_df=pd.read_csv(filename,
                         header=None,
                         names=['LOCATION', 'NAME'],
                         index_col='LOCATION')
```

now bring this all together - create a new dat frame, the result of joining `locations_df`and `tourism_df`-- the problem is that while the 3-letter abbre is the index of `locations_df`-- it’s just a plain. Can:

`fullname_df=locations_df.join(tourism_df.set_index('LOCATION'))`

The index of `fullname_df`is the 3-character country codes -- `NAME SUBJECT TIME Value`. And by using the `NAME`for grouping operations, will be able to get a report that displays each country’s full name, rather than the 3-letter abbre. so can just get 5 like:

```python
fullname_df.loc[fullname_df.SUBJECT=='INT_REC'].groupby('NAME')[
    'Value'].mean().sort_values(ascending=False).head()
```

reset the index on `locations_df`such that it has a default numeric index, and two columns -- now run the `join`on `locations_df`specifying that you want to use the `LOCAITON`column on the caller, rather than its index like:

### Multi-city temperatures

One of the important things tell newcomers to programming is that your choice and design of data structure has a huge impact on the programs you write, when are working with py -- you should think carefully about whether you will use a list, tuple, dict, or some combination of those -- like: The `pandas`analog to this advice is that you should design your data frames such that they include all of the information you need in order to simplify your queries.

So, how can creat that list of 8 data frames, reading from 8 separate files -- use the for over a list of filenames like:

```python
import glob
all_dfs=[]
for one_filename in glob.glob('data/*,*.csv'):
    print(f'Loading {one_filename}')
    city, state = one_filename.removeprefix('/data/').removesuffix(
        '.csv').split(',')
    one_df= pd.read_csv(one_filename)
    one_df['city']=city.replace('+', ' ').title()
    one_df['state']=state.upper()
    all_dfs.append(one_df)

df= pd.concat(all_dfs)
```

```python
one_df= pd.read_csv(one_filename, 
                    usecols=[0,1,2],
                    names='date_time max_temp min_temp'.split(),
                    header=0)
```

First, asked whether the data for each city and states start at roughly the same time, how can we know such a thing -- each rows has a `date_time`column indicating when the temperature reading were taken. Also, groupby by both state and city ensures that we get a nece report of our data.

`df.groupby(['state', 'city'])['date_time'].min().sort_values()`

In the code, tells `pandas`that want to get the minimum value of `date_time`for each distinct combination of `state`and `city`then want to sort the values, so that can easily find the earliest one -- can similarly run `max`on the vlaues like:

`df.groupby(['state', 'city'])['date_time'].max().sort_values()`

- Run `describe`on the minimum and maximum tempature for each state-city combination --

  `df.groupby(['state', 'city'])[['min_temp', 'max_temp']].apply(pd.DataFrame.describe)`

- Running `describe`works, but only wee the first and last few rows from each results, can use the `set_option`to chaneg the value of `display_max_rows`-- like:
  `pd.set_option('display.max_rows',1000)`

- what is the average difference in tempature, for each of the cities in dataset -- 

```python
pd.set_option('display.max_rows',1000)
df.groupby(['state', 'city'])[['min_temp', 'max_temp']].apply(lambda g: np.mean(
    g.max()-g.min()
))
```

What if want to find out how much sold, togal, through the current quarter -- want to know how much sold in Q1. To perform this kind of operation, `pandas`provides us with *window function* -- there are several different types of window functions, but the basic idea i they allow use to run an aggregate function, like `mean`. fore:

`df['sales'].expanding().sum()`-- this returns a series whose values are cumulative sum of value in `sales`up that point. And since the first 4 values, hen the resust. is 100, 250, 450.. can also:

`df['sales'].expanding().mean()`

Can also use the `rolling`window function -- determine how many rows will be considered to be part of the window -- fore if the window size is 3, then run the aggregation function on row index 0-2, 1-3, then 2-4... like:

`df['sales'].rolling(3).mean()`

And the 3rd type of window function is `pct_change()`-- when run this on a sereis, get back a new series, wtih `NaN`at row index 0, and the remaining rows indicate the percentage change from the prrevous row to current one like:

`df['sales'].pct_change()` # -- (150-100)/100  (200-150)/150...

### SAT scores revisited

There have long been accusations that the SAT isn’t a fair test -- Can we conclude that wealthier do indeed -- Were able to use data to gain some insight into a real-world issue -- need to load data from csv into a df -- was only interested in the math scores fore, was actually more interested in math scores when broken down by family incomes.

```python
df = pd.read_csv('data/sat-scores.csv',
                 usecols=['Year', 'State.Code', 'Total.Math',
                          'Family Income.Less than 20k.Math',
                          'Family Income.Between 20-40k.Math',
                          'Family Income.Between 40-60k.Math',
                          'Family Income.Between 60-80k.Math',
                          'Family Income.Between 80-100k.Math',
                          'Family Income.More than 100k.Math'])
```

## Performing Type Assertions

Packages can be defined within other packages, making it easy to break up complex features into as many units as possible, like:

```go
package cart
import "packages/store"

type Cart struct {
    CustomerName string
    Products []store.Product
}

func (cart *Cart) GetTotal() (total float64) {
    for _, p := range cart.Products {
        total+=p.Price()
    }
    return
}
```

So the `package`statement is used just as with any other package, without the need to include the name of the parent of enclosing package. like:

```go
cart := cart.Cart {
    CustomerName: "Alice",
    products: []stroe.Product{*product},
}
fmt.Println(cart.CustomerName)
```

### Using package initialization Functions

Each code file can contain an initialization function that executed only when all packages have been loaded and all other initialization -- such as defining constants and variables has been done -- the most common use for initialization function is to perform calculations that are difficult to perform or that require duplication to perform.

The most common use for initliazation function is to perform calcualations that are difficult to perform or that require duplication to perform like: The Go allows loops only inside of functions, and need to perform these calculations tat the top level o the code file -- the solution is to use an initialization function, which is invoked automatically when the package is loaded and where language features like:

```go
var categoryMaxPrices = map[string]float64 {
    "Watersports":250,
    "Soccer":150,
    "Chess":50,
}

func init() {
    for category, price := range categoryMaxPrices {
        categoryMaxPrice[category]= price+ price*defaultTaxRate
    }
}
```

### Importing a package only for initialization effects

Go prevents packages from being imported but not used -- which can be a problem if you rely on the effect of an initialiation function but don’t need to use any of the features and package exports. fore: creates the `packages/data`and add to it a file name called `data.go`with the content like:

```go
func init() {
    fmt.Println("data.go init() invoked")
}
func GetData() []string{
    return []string {...}
}
```

If need the effect of the initialization function, but don’t need to use the `GetData`function in the package exports, can just import package using the blank identifier as an alias for the package name like:

```go
import(
	"fmt"
    //....
    _ "package/data"
)
```

### Using External Packages

Projs can be extended using just packages developed by 3rd parties - are downloaded and installed use the `go get`command like:

`go get github.com/faith/color@v.10.0`

And, the `go get`command is sophisticated and knows that the path specified is a GitHub url. The specified version of the module is downloaed. Examine the `go.mod`file once the `go get`command has finished, and will :

```go
require (
	github.com/....
)
```

And the `require`statemens notes the dependency on the `github.com/faith/color`module and the other modules it needs. the `indirect`comment is added automatically cuz the packages are not used by the code in the proj.

### Managing External Package

The `go get`adds dependency to the `go.mod`-- but these are not removed automatically if the external package is no longer required -- can changes the contents of the `main.go`file to remove the use of the pakcage like: Then to update the go.mod file to reflect the change, just run the command -

`go mod tidy`

this just examines the project code, determines that there is no longer a dependency on any of the packages from teh require module. and just remove the `require`statement from the `go.mod`file.

### Type and Interface Composition

Expplain how types are combined to create new features -- go doesn’t use inheritance, which you may be-- and instead relies on an approach known as *composition*. this can be just difficult to understand -- 

- Composition is the process by which new types are created by combining structs and interfaces
- Composition allows types to be defined based on existing types
- Existing types are embedded in new types
- Composition doesn’t work in the same way as inheritance.

### Understanding Type composition

Go doesn’t support classes or inheritance and focuses on *composition* instead. Defining the Base type -- The starting point is to define a struct type and a method -- which will use to create more specific types in later -- like:

```go
type Product struct {
	Name, Category string
	price          float64
}

func (p *Product) Price(taxRate float64) float64 {
	return p.price + p.price*taxRate
}

```

### Defining a ctor

Cuz Go doesn’t support classs, it doesn’t support class ctor -- a common convention is to define a ctor function whose name is `New<Type>`such as `NewProduct`-- allows values to be provided for all fields, even those that have not been exported, as with other feature featurs, the capitalization of the first letter of the ctor function name determines whether it is exported outside of the package.

```go
func NewProduct(name, category string, price float64) *Product {
	return &Product{name, category, price}
}
```

CTOR functions are only a convention, and their use is not enforced, which means that exported types can be created using the literal syntax, just as long as no values are assgined to the unexported fields.

```go
import (
	"composition/store"
	"fmt"
)

func main() {
	kayak := store.NewProduct("Kayak", "Watersports", 275)
	Lifejacket := &store.Product{Name: "Lifejacket", Category: "Watersports"}
	for _, p := range []*store.Product{kayak, Lifejacket} {
		fmt.Println("Name:", p.Name, "Category", p.Category, "Price:", p.Price(.2))
	}
}
```

### Composing Types

Go supports composition, rather than inheritance, which is done by combining struct types - add a file named `boat.go`to the `store`with the contents like:

```go
type Boat struct {
	*Product
	Capacity  int
	Motorized bool
}

func NewBoat(name string, price float64, capacity int, motorized bool) *Boat {
	return &Boat{
		NewProduct(name, "Watersports", price), capacity, 
		motorized,
	}
}
```

And the `Boat`struct type defiens the embedded `*Product`.-- so a struct can just mix regular and embedded field types, but the embedded fields are an important part of the composition feature -- 

```go
func main() {
	boats := []*store.Boat{
		store.NewBoat("Kayak", 275, 1, false),
		store.NewBoat("Canoe", 400, 3, false),
		store.NewBoat("Tender", 650.25, 2, true),
	}
	for _, b := range boats {
		fmt.Println("Conventional:", b.Product.Name, "Direct:", b.Name)
	}
}

```

For this, go just gives special treatment to struct types that have fields whose type is another struct type in the way that the `Boat`type has a `*Product`field in the example field. The `Boat`type doesn’t define a `Name`field, but it can be treated as through it did cuz of the direct access feature.

### Creating a Chain of Nested Types

The composition feature can be used to create complex chains of nested types, whose fileds and methods are pormotied to the top-level enclosing type -- add a file named `rentalboats.go`to the `store`and like:

```go
type RentalBoat struct {
	*Boat
	IncludeCrew bool
}

func NewRentalBoat(name string, price float64, capacity int,
	motorized, crewed bool) *RentalBoat {
	return &RentalBoat{NewBoat(name, price, capacity, motorized), crewed}
}
// ...
func main() {
	rentals := []*store.RentalBoat{
		store.NewRentalBoat("Rubber Ring", 10, 1, false, false),
		store.NewRentalBoat("Yacht", 50000, 5, true, true),
		store.NewRentalBoat("Super yacht", 100000, 15, true, true),
	}
	for _, r := range rentals {
		fmt.Println("Rental Boat:", r.Name, "Rental Price", r.Price(.2))
	}
}
```

### Using multiple Nested types in the same struct 

Types can define multiple struct fields, and wo will promote the fields for all of them -- defines a new type that describes a boat crew and uses it as the type for a field in another struct like:

```go
type RentalBoat struct {
	*Boat
	IncludeCrew bool
	*Crew
}

type Crew struct {
	Captain, FirsOfOfficer string
}

func NewRentalBoat(name string, price float64, capacity int,
	motorized, crewed bool,
	captain, firstOfOfficer string) *RentalBoat {
	return &RentalBoat{NewBoat(name, price, capacity, motorized), crewed,
		&Crew{captain, firstOfOfficer}}
}

```

### Understanding when promotion cannot be performed

Go can perform promotion only if there is no field or method defined within the same name on the enclosing type. 

### Gorotuines and Channels

Go has excellent support for writing concurrent applications, using fetures that are impler and more intitive - 

- Groutines are lightweight threds created and managed by the go runtime, channels are *pipes* that carry values of a specific type.
- Goroutine allow functions to be executed concurrently, without needing to deal with the complications of OS threads. Channels allow goroutines to produce results async.
- Goroutines are created using the `go`, channels are defined as data types.
- Care must be taken to manage the direction of channels.
- Goroutines and channels are the built-in Go concurrency features, but some apps can rely on a single thread of execution.

```go
type Product struct {
	Name, Category string
	Price          float64
}

var ProductList = []*Product{
	{"Kayak", "Watersports", 279},
	{"Lifejacket", "Watersports", 49.95},
	{"Soccer Ball", "Soccer", 19.50},
	{"Corner Flags", "Soccer", 34.95},
	{"Stadium", "Soccer", 79500},
	{"Thinking Cap", "Chess", 16},
	{"Unsteady Chair", "Chess", 75},
	{"Bling-Bling King", "Chess", 1200},
}

type ProductGroup []*Product

type ProductData = map[string]ProductGroup

var Products = make(ProductData) // note the map

func ToCurrency(val float64) string {
	return "$" + strconv.FormatFloat(val, 'f', 2, 64)
}

func init() {
	for _, p := range ProductList {
		if _, ok := Products[p.Category]; ok {
			Products[p.Category] = append(Products[p.Category], p)
		} else {
			Products[p.Category] = ProductGroup{p}
		}
	}
}
```

This field defines a custom type named `Product`, along with type aliases that used to create a map that organizes products by category. Use the `Product`type in a slice and a map, and rely on an `init`function, described to populate the map from the contents of the slice, which is itself populated using the literal syntax.

```go
func (group ProductGroup) TotalPrice(category string) (total float64) {
	for _, p := range group {
		total += p.Price
	}
	fmt.Println(category, "subtotal:", ToCurrency(total))
	return
}
func CalcStoreTotal(data ProductData) {
	var storeTotal float64
	for category, group := range data {
		storeTotal += group.TotalPrice(category)
	}
	fmt.Println("Total:", ToCurrency(storeTotal))
}

```

This file defines methods that operate on the type aliases created -- methods can be defined only on types that are created in the same package.

## Fixed Positioning

Fixed positoning, although not as common as some of the other types of positioning, is probably the simplest to understand, -- applying `position: fixed`to an element lets you position the element arbitrarily within the viewport. This is done with 4 companion properties, top, right, bottom, and left. The values you assign to these properties specify how far the fixed element should be from each edge of the browser viewport.

```html
<div class="modal">
    <div class="modal-backdrop">
    </div>
    <div class="modal-body">
        <button class=...></button>
        <h2>
            Wombat
        </h2>
        <p>
            Sign up
        </p>
        <form>
            ...
        </form>
    </div>
</div>
```



```css
.modal-backdrop {
    position: fixed;
    top:0;
    right:0;
    bottom:0;
    left:0;
    background-color: rgba(0,0,0,0.5);
}
.modal-body{
    position: fixed;
    top:3em;
    bottom: 3em;
    right: 20%;
    left: 20%;
    padding: 2em 3em;
    background-color: white;
    overflow: auto; /* allows the modal body to scroll if necessary */
}
```

In this css, you have used fixed positioning twice, first on the `modal-backdrop`with each of the four-sides set to 0. This makes the backgrop fill the entire viewport, you ‘ve given it a background color -- this rgba(0,0,0,0.5). This color notation specifies .. which evaluates to black, but the fourth value is alpha channel-- which specifies its transparency -- a value of 0 is completely transparent. 0.5 is half transparent.

Second plce you use the fixed ositioning is in the modal-body -- positioned each of its four sides inside the viewport, 3em from the top and bottem edges and 20% from the left and right sides.

Load the page and you will see a pale yellow banner across the top of the screen with a button.

### Controlling the size of positioned elements

When positioning an element, are not required to specify values for all 4 sides, you can specify only the sides you need and then use `width`and/or `height`to help determine its size.

### Absolute positioning - 

Fixed positioning -- lets you position an element relative to the viewport, this is called its *containing block* -- the declarations -- `left:2em`fore, places the left edge of positioned element 2em from the left edge of the contaiing block. Absolute positioning workds the same way -- except it has a different contaiing block.

Absolute has a different containing block instead of its position being bsed on the viewport, its position is just based on the *closest positioned ancestor element*. As with a fixed , the properties `top, right, bottom, left`place the edges of the element within its contiaing block.

To see how just like:

```css
.modal-close {
    cursor: pointer;
    position:absolute;
    top:.3em;
    right:.3em;
    padding: .3em;
}
```

This listing places the button 0.3em from the top and from the right of the `modal-body`-- Typeically, as in this example, the containing block will be the element’s parent. In cases where the parent element is not positioned, then the browser will look up the DOM hierarchy at the grandparent... and so on until a positioned elements is found.

### Positining a pseudo-element

You’ve positioned the Close button where you want it -- it’s rather spartan -- for a close button -- your first tempation may te to moreve word `close`from your markup and replace it with an x -- but this would introduce an accessibility problem -- Assistive screen readers read the text of the button, so it should give some meaningful indicaiton of the button’s purpose. Instead, cna use CSS to hide the word `close`and display X -- accomplish by doing -- 

1. Push button’s text outside the button and hide the overflow
2. use the *content* prop to add the x to the button’s `::after`pseudo-element and absolute positioning to center it within the button.

```css
.modal-close {
    cursor: pointer;
    position: absolute;
    top: .3em;
    right: .3em;
    padding: .3em;
    font-size: 2em;
    width: 1em;
    height: 1em;
    text-indent: 10em;
    overflow: hidden;
    border: 0;
}

modal-close::after {
    position: absolute;
    line-height: .5;
    top: 0.2em;
    left:0.1em;
    text-indent: 0;  /* this is inherited */
    content: "X";
}
```

