# Joining Sidebar

Like grouping, joining is a concept that you might have encountered, when working with relational dbs, the joining functionality in pandas is quite similar to that sort of dbs.

- One data frame will describe each of the products 
- A second data frame will describe each sale what we made

```python
products_df = products_df.set_index('product_id')
sales_df = sales_df.set_index('prodcut_id')
```

Note that data frames for now have a common reference point in the index, can just create a data frame combining the two like: `products_df.join(sales_df)`

Can now perform whatever queries we might like on this new -- combined data frame, fore, can find out how many of each product were sold like:

```python
products_df.join(sales_df).groupby('name')['retail_price'].sum().sort_values()
```

And while data set is just tiny, can even find out how much each product contributed to ncome per day like:

```python
products_df.join(sales_df).groupby(['date', 'name'])[
    'retail_price'].sum().sort_index()
```

So, separating your data into two or more pieces, so that ech piece of info appears only a single time -- is known as *normalization* -- there are all sorts of formal theories and descpritions of normalization -- but it all biols down to keeping the info in separate palces, and joining data frame when necessary.

Sometimes -- you will normalize your own data -- but sometimes, you will receive data that has been normalized, and then separated into separate pieces -- fore, many data sets are distributed in separate CSV file.

One final point, the point that shown you here is known as a *left join*.

Tourist spending per country -- Writing -- before thepandemic used to -- In this, will create two separate data frames, and then joined them together -- were able to create a report that used countries’ full name, rather than 3-letter abbre.

```python
filename="data/oecd_tourism.csv"
tourism_df= pd.read_csv(filename,
                        usecols=['LOCATION', 'SUBJECT', 'TIME', 'Value'])
```

This contains info about the total amount spent, and the total amount received by a number of countries, over about a decade -- fore, want to find out how much money the received -- Can look at the row in which ..

`tourism_df.loc[tourism_df['SUBJECT']=='INC_REC']['Value'].mean()`

But this isn’t useful -- czu countries are almost certainly quite different in how much tourist income they recieve.

```python
tourism_df.loc[tourism_df['SUBJECT']=='INT_REC'].groupby(
    'LOCATION')['Value'].mean()
```

- Selected those rows in which `SUBJECT`was `INT_REC`, fro received tourism funds
- Grouped by the `LOCATION`, meaning that we will get one result per value of `LCOATION`.
- Asked for only the `Value`column
- invoked the `mean`on each location’s values.

Then asked to find the 5 counties that received the most from tourism -- like:

```python
tourism_df.loc[tourism_df['SUBJECT']=='INT_REC'].groupby(
    'LOCATION')['Value'].mean().sort_values(ascending=False).head()
```

Then, perform a second, similar query, finding the countries that had spent the least amount on tourism -- now interested in the `INT-EXP`value from `SUBJECT`-- want to look the 5 lowest-spending tourism countries -- like:

```python
tourism_df.loc[tourism_df['SUBJECT']=='INT-EXP'].groupby(
    'LOCATION')['Value'].mean().sort_values().head()
```

With these initial queries out of the way, can now use `join`to make an easier-to-read report from we’re created, to help created two-column csv file that you can read-- however, will quickly discover that this CSV file needs messaging, like:

```python
locations_filename = "data/oecd_locations.csv"
locations_df= pd.read_csv(locations_filename,
                          header=None,
                          names=['LOCATION', 'NAME'],
                          index_col='LOCATION')
```

Now, can briing this together -- will create a new data frame, the result of joining `locations_df`and `trouism_df`. The problem is that while 3-letter abbre is the index of `locations_df`, it’s just a plain `trouism_df`. do:

Do the following:

- Create a new data frame based on `tourism_df`, but whose index is set to `LOCATION`.
- I’ll then run `join`on `location_df`and the new, `LOCATION-`indexed version of tourism_df.

```python
fullname_df = locations_df.join(tourism_df.set_index('LOCATION'))
```

So by using `NAME`for our grouping operations, be able to get a report that displays each countery’s full name, rather than the 3-letter.

```python
fullname_df.loc[fullname_df['SUBJECT']=='INT_REC'].groupby(
    'NAME')['Value'].mean().sort_values(ascending=False).head()
```

1. Create a data frame from 4 columns in the trouism data
2. Choose rows where `SUBJECT`is `INT_REC`for each location, gt the mean `value`in the data, sort those values in descending order, and take the top five values.

Reset the index on `locations_df`, such that it has a number index -- and two columns, now run `join`and `locations_df`, specifying that yo uwan to use the `LOCATION`column in the caller, rather that its index like:

```python
tourism_df.set_index('LOCATION', inplace=True)
lcoation_df.join(tourism_df, on='LOCATION')
```

### Columns contain values not variables

Data can have columns that contain values instead of variables, this is usually a convenient format for data collection and presentation. Keep one column fixed -- use data on income and religion in the from .. like:

`pew.iloc[:, 0:5]`

This view of the data is also known as *wide* data , and to turn it into the *long* tidy data format, wil have to **unpivot/melt/gather** our dataframe.

Pandas have a method called `.melt()`that will reshape the df into a tidy format and it takes a few parameters --

- `id_vars`-- is a container that represents the variables that will **remain** as is.
- `value_vars`-- identifies the columns you want to melt down -- `unpivot`-- will melt all the columns if not specified in the `id_vars`
- `var_name`-- is a string for a new column name
- `value_name`-- string for new column name represents the values from the `var_name`.

`pew_long = pew.melt(*id_vars*='religion')`

And note that the `.melt()`method also exists as pandas function, `pd.melt()`-- the below two lines of code, can change the defaults so that the melted/unpivoted columns are named like:

```python
pew_long = pew.melt(id_vars='religion', value_vars=['<$10k', '$20-30k'], 
                                                    var_name='income', value_name='count')
```

### Keep multiple Columns Fixed

Not every data set have one column to hold still while you unpivot rest of the columns. like: `billboard.iloc[0:5, 0:16]`Can just see here that each week hs its own column -- there is nothing wrong for this form of data -- it may be easy to etner -- like: 

```python
billboard_long= billboard.melt(
    id_vars=['year', 'artist', 'track', 'time', 'date.entered'],
    var_name='week',
    value_name='rating'
)
```

### Columns contain multiple variables

Sometimes column in a data set may represent multiple variables, this format is commonly see when working with health data fore, to illustrate this -- look at:

```python
ebola= pd.read_csv('country_timeseries.csv')
ebola.columns
ebola.iloc[:5, [0, 1, 2, 10]]
```

Just melt a wide format like:

`ebola_long= ebola.melt(*id_vars*=['Date', 'Day'])`

Conceputally, the column of interest can be split based on the underscore in the column name, the first part will be the new status column, and the second part will be the new country column- this will require some string parsing and splitting in py -- In python, a string is an object. String just have methods suchas `.split()`method and “splits” it up based on a given delimiter, by default, `.split()`method that takes a string -- and to get access to the string methods, use the `.str`on the `series`, Pandas calles an *accessor* cuz it can access string methods.

## Understanding Colusure Evaluation

The variables on which a function closes are evaluated each time the func is invoked, which means that changes amde outside a fucntion can affect the results it produces like:

```go
func priceFuncFactory(threshold, rate float64) calcFunc {
    return func(price float64) float64 {
        if prizeGiveaway {
            return 0
        } else if price > threshold {
            return price + price*rate
        }
        return price
    }
}

// ...
prizeGiveaway = false
waterCalc := priceFuncFactory(100, .2)
prizeGiveaway = true
soccerCalc := priceFuncFactory(50, .1)
for product, price := range watersportsProducts {
    printPrice(product, price, waterCalc)
}
for product, price := range soccerProducts {
    printPrice(product, price, soccerCalc)
}
```

The calculator func closes the `priceGiveaway`variable, which causes the prices to drop to zero. the `prizeGiveaway`is set to false before the function for the category is created and set to `true`before the func for the `soccer`category is created.

But, since coloures are evaluated when the function is invoked, it is the current value of the `prizeGiveaway`that is used, not the value at the time the function was created. so, all of these are 0.

### Forcing Early Evaluation

Evaluating closures when the func is invoked can be useful, but if you want to use the value that was current when the function was created, then copy the value like:

```go
func priceFuncFactory(threshold, rate float64) calcFunc {
	fixedPrizeGiveaway := prizeGiveaway
	return func(price float64) float64 {
		if fixedPrizeGiveaway {
			return 0
		} else if price > threshold {
			return price + price*rate
		}
		return price
	}
}
```

### Closing on a pointer to Prevent Early Evaluation

Most problems with closure caused by changes made to variables after a function has been created, which can be addressed using the techniques in the previous section -- on occasion, may find encounter the contrary issue.

### Defining structs

In this, describe structs, which is how custom data types are defined in Go, show you how to define new struct types, describe how to create values from those types, and explain what happens when values are copied -- 

- Structs are data types, comprised of fields
- allow custom data types to be defined
- The `type`and `struct`are used to define a type
- Care must be taken to avoid unintentionally duplicating struct values and to ensure the fields and store pointers are iniitialzied before are used
- simple app can use just the built-in

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
	fmt.Println(kayak)
}

```

### Partially Assigning struct values

Values do not have to be provided for all fields when creating a struct values -- like:

```go
kayak := Product {
    name: "Kayak",
    category: "Watersports",
}
```

For this, no initial value is provided for the `price`field for the struct assigned to the `kayak`variable. When no field is provided, the zero value for the field’s type is used.

### Using Field positions to create struct values

Struct values can be defined wihtout using names -- as long as the types of the values corresponding to the order in which fileds are defined by the struct type like:

`var kayak = Product {"Kayak", "Watersports", 275.00}`

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
		Product: Product{"Kayak", "Watersoprts", 275.00},
		count:   100,
	}
	fmt.Println("Name:", stockItem.Product.name)
	fmt.Println("Count:", stockItem.count)
}
```

Embedded fileds are accesed just using the name of the field type, which is why this feature is most useful for fields whose type is a struct -- in this casse, the embedded field is defined with the `Product`type, which means it is assigned and read using `Product`as the field name like:

As noted -- field names must be just unique with the struct type -- which means that you can define only one embedded field for a specific type -- if need to define two fields of the same type, will need to assign a name like:

```go
type StockLevel struct {
    Product
    Alternate Product
    count int
}
```

### Comparing Struct values

Struct values are comparable *if all their fields can be compared*-- like, and structs cannot be compared if the struct type deifnes fields incomparable types like:

```go
type Product struct {
    name, category string
    price float64
    otherNames []string
}
```

For this, the Go comparison operator canont be applied to slices -- which means that `Product`values cannot be compared.

### Converting between Struct types

A struct type can be converted into any other struct type that has the same fields -- meaning all the fields have the just same name and type and are defined in the same order like:

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}
	type Item struct {
		name     string
		category string
		price    float64
	}

	prod := Product{name: "Kayak", category: "Watersports", price: 275.00}
	item := Item{name: "Kayak", category: "Watersports", price: 275.00}

	fmt.Println("prod==item", prod == Product(item)) // true
}

```

So, values created from the `Product`and `Item`struct types can be compared.

### Defining Anonymous Struct types

Anonymous struct types are defined without using a name just like:

```go
func writeName(val struct {
	name, category string
	price          float64
}) {
	fmt.Println("Name", val.name)
}
```

for this, don’t find this feature particularly useful -- but there is a variation that do use -- which is to define an anonymous struct and assigne it a value in a single step. Just like:

```go
prod := Product{name: "Kayak", category: "Watersports", price: 275.00}

var builder strings.Builder
json.NewEncoder(&builder).Encode(struct {
    ProductName  string
    ProductPrice float64
}{
    ProductPrice: prod.price,
    ProductName:  prod.name,
})
fmt.Println(builder.String())
```

This example just demonstrates how an anonymous struct can be defined and assigned a value in a single step.

### Creating arrays, slices, and maps containing struct values

The `struct`type can be omitted when populating arrays, slices, and maps with struct values like:

```go
array := [1]StockLevel{
    {
        Product:   Product{"Kayak", "Watersports", 257.00},
        Alternate: Product{"Lifejacket", "Watersports", 48.95},
        count:     100,
    },
}
fmt.Println("Array", array[0].Product.name)

slice := []StockLevel{
    {
        Product{"Kayak", "Watersports", 275.00},
        Product{"Lifejacket", "Watersports", 48.95},
        100,
    },
}
fmt.Println("Slice:", slice[0].name)

kvp := map[string]StockLevel{
    "kayak": {
        Product{"Kayak", "Watersports", 275.00},
        Product{"Lifejacket", "Watersports", 48.95},
        100,
    },
}
fmt.Println("Map", kvp["kayak"].Product.name)

```

### Understanding Structs and Pointers

Assigining a struct to a new variable or using a struct as a function parameter creates a new value that copies the field values, as demonstrated -- like:

```go
func main() {
	type Product struct {
		name, category string
		price          float64
	}
	p1 := Product{"Kayak", "Watersports", 275}
	p2 := p1
	p1.name = "Original Kayak"
	fmt.Println(p1.name, p2.name)
}

```

For this, the `name`field of the first struct value is changed, and then both `name`values are written out.

```go
p2 := &p1
p1.name = "Original Kayak"
fmt.Println(p1.name, (*p2).name)  // both Original
```

The effect is that the change made to the `name`field is read through both `p1`and `p2`-- producing the output.

### Understanding the Struct Pointer Convenience Syntax

Accessing struct fields through a pointer is just awkward which is an issue cuz structs are commonly used as function arguments and results. Like:

```go
type Product struct {
    name, category string
    price float64
}

func calcTax(product *Product) {
    if((*product).price>100) {
        (*product).price += (*product).price*0.2
    }
}
```

Code works, but it is hard to read, especially when there are multiple references in the same block of code. To just simplify this type of code, Go will follow pointers to struct fields without needing an * characters like:

```go
func calcTax(product *Product) {
    if(product.price>100){
        product.price += product.price*0.3
    }
}
```

Note that the * and the partntheses are not required actually, allowing a pointer to a struct to be treated as though it were a struct value.

### Understanding pointers to Values

```go
func calcTax(product *Product) {
	if product.price > 100 {
		product.price += product.price * .2
	}
}

type Product struct {
	name, category string
	price          float64
}

func main() {
	kayak := &Product{
		"Kayak", "Watersports", 275,
	}
	calcTax(kayak)
	fmt.Println(kayak)
}
```

For the code only uses a ponter to a `Product`value, which means that there is no benefit in creating a regular variable and then using it to create the pointer -- Being able to create pointers directly from values can help make code more concise.

```go
func calcTax(product *Product) *Product {
	if product.price > 100 {
		product.price += product.price * .2
	}
	return product
}

func main() {
	kayak := calcTax(&Product{
		"Kayak", "Watersports", 275,
	})
	fmt.Println(kayak)
}

```

Just altered the `calcTax`function so that it produces a result, which allows the function to transform a `product`value through a pointer. In the `main`, used to address operator with the literal syntax to create a `Product`value and passed it to the `calcTax`.

### Understanding ctor Functions

A ctor is responsbile for creating struct values using values received through parameters like:

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
		fmt.Println(p)
	}
}
```

So, CTOR functins are used to create sturct values consistently.’

### aria-label

The `aria-label`attribute defines a string value that lables in interactive element. Should be used to provide a text alternative to an element that has no visible text on the screen. --Is an attribute defined in the `WAI-ARIA`. this specification extends the native HTML. fore:

```html
<button>
    Send
</button>
<button aria-lable="send email">
    send
</button>
```

The initial value of the `position`is `static`-- everything done in is with `static`-- when you change this value ot anything else, the element is said to be *positioned* -- an element wtih static positioning is thus *not positioned*. The layout method covered do various things to manipulate the way document flow behaves.

### Fixed Positioning

Not as common as some of the other types of positioning, is probably the simplest to understand, -- Applying `position: fixed`to an element just let position the element arbitrary within the viewport. This is done with `top, right, bottome`and `left`. Just like:

```html
<body>
    <header class="top-banner">
        <div class="top-banner-inner">
            <p>Find out what is going on at :
                <button id="open">Sign up</button>
            </p>
        </div>
    </header>
    <div class="modal" id="modal">
        <div class="modal-backdrop"></div>
        <div class="modal-body">
            <button class="modal-close" id="close">Close</button>
            <p>sign up for monthly newsletter, no spam.</p>
            <form>
                <p>
                    <label for="email">Email address</label>
                    <input type="text" name="email" />
                </p>
            </form>
        </div>
    </div>

    <script>
        let button = document.getElementById('open');
        let close = document.getElementById('close')
        let modal = document.getElementById('modal');

        button.addEventListener('click', event => {
            event.preventDefault();
            modal.style.display = 'block';
        });

        close.addEventListener('click', event => {
            event.preventDefault();
            modal.style.display = 'none';
        })
    </script>
</body>
```

```css

button {
    padding: 0.5em 0.7em;
    border: 1px solid #8d8d8d;
    background-color: white;
    font-size: 1em;
}

.top_banner {
    padding: 1em 0;
    background-color: #ffd698;
}

.top_banner-inner {
    width: 80%;
    max-width: 1000px;
    margin: 0 auto;
}

.modal {
    display: none;
}
.modal-backdrop {
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    background-color: rgba(0, 0, 0, 0.5);
}
.modal-body {
    position: fixed;
    top: 3em;
    bottom: 3em;
    right: 20%;
    left: 20%;
    padding: 2em 3em;
    background-color: white;
    overflow: auto;
}
.modal-close {
    cursor: pointer;
}
```

