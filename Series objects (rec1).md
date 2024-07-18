# Series objects (rec1)

One of Panda’s core data structures, the `Series`is 1D labeled array for homogeneous data. A series combines and expands the best features of Python’s native data structures.

### Populating the series with values

A constructor is a methor that builds an object from a class. When wrote `pd.Series()`, used the `Sereis`constructor to create a new `Series`object. The goal is to get comfortable with the look and can be:

```python
ice = [
    "Chocolate",
    "Vanilla",
    "Strawberry",
    "Rum Raisin",
]
pd.Series(ice)
```

#### Customizing the Series Index

```python
ice = [
    "Chocolate",
    "Vanilla",
    "Strawberry",
    "Rum Raisin",
]
days_of_week = ("Monday", "Wednesday", "Friday", "Saturday")
pd.Series(ice, index= days_of_week)
```

Even though the index consists of string labels, pandas still assigns each `Series`value an index position. In other words, can access thev value eight by the index or by index position 1. using `loc[]`or `iloc[]`. Although pandas permits duplicates, it is ideal to avoid them whenever possible. Cuz a unique index allows the library to locate index labels more quickly. 

And can create `Series`from lists of *Boolean, integer, float-pointing* values. like:

```python
lucky_numbers = [4,8,15,16,23,42]
pd.Series(lucky_numbers)
pd.Series(lucky_numbers, dtype="float") # float64 either
```

#### With missing values

When pandas sees a missing value during a file import, the library substitutes Numpy’s `nan`object -- the acronym `nan`is short for a *not a number* is a catch-all term for an undefined value. can:

```python
temp = [94, 88, np.nan, 91]
pd.Series(data=temp)
```

### Creating from Python objects

The `Series`constructor’s `data`parameter accepts various inputs, including native pyton data structures and objects from other libraries. fore:

```python
calorie_info = {
    "Cereal": 125,
    "Chocolate Bar": 406,
    "Ice Cream Sundae": 342,
}
diet = pd.Series(calorie_info)
diet
```

For this, the index is the key, and data is the dict’s value.

Note that if pass a set directly to the `Series`ctor, pandas raises a `TypeError`exception -- A set has neither the concept of order nor concept of association. using: `pd.Series(list(my_set))`to do this job. And the `data`parameter also accepts a Numpy `ndarray`object. like:

```python
random_data = np.random.randint(1,101,10)
pd.Series(random_data)
```

### Series attributes

An *attribute* is a piece of data belongling to an object. like:

```python
# values attr
diet.values # ndarray returned
diet.index
diet.dtype
# shape returns a tuple with the dimensions of a pandas data structure
diet.shape
# is_unique returns True if all unique
diet.is_unique

numbers = pd.Series([1,2,3,np.nan,4,5])
numbers.sum() # skip nan
numbers.sum(skipna=False) # nan returned
```

## Type and Interface composition

Explain how types are combined to create new features -- go doesn’t use inheritance, instead relies on an approach known as *composition* -- 

- Composition is the process by which new types are created by combining structs and interfaces
- Composition allows types to be defined based on existing types
- Existing types are embedded in new types
- Composition doesn’t woke in the same way as inheritance, and care must be taken to achieve the desired outcome.

```go
type Product struct {
	Name, Category string
	price          float64
}

func (p *Product) Price(taxRate float64) float64 {
	return p.price + p.price*taxRate
}
```

And the `Product`struct defines `Name`and `Category`fields, which are exported, and a `price`field that is not exported.

### Defining a Constructor

Cuz Go doesn’t support classes, it doesn’t support class constructor either, as explained, a common convention is to defines a  constructor function whose name is `New<Type>`-- like:

```go
func NewProduct(name, category string, price float64) *Product {
	return &Product{name, category, price}
}
```

So, Constructor functions are only a convention -- and their use is not enforced.

```go
func main() {
	kayak := store.NewProduct("Kayak", "Watersports", 275)
	lifejacket := &store.Product{Name: "Lifejacket", Category: "Watersports"}
	for _, p := range []*store.Product{kayak, lifejacket} {
		fmt.Println("Name:", p.Name, "Category:", p.Category,
			"Price:", p.Price(0.2))
	}
}
```

#### Composing Types

Go supports composition, rather than inheritance, which is done by combining struct tyeps, add a file like:

```go
type Boat struct {
	*Product
	Capacity  int
	Motorized bool
}

func NewBoat(name string, price float64, capacity int, motorized bool) *Boat {
	return &Boat{
		NewProduct(name, "Watersports", price),
		capacity, motorized,
	}
}
```

So the `Boat`struct type defines an embedded `*Product`field, and a struct can mix regular and embedded field types, but the embedded fields are an important part of the composition feature -- 

```go
func main() {
    boats := []*store.Boat{
        store.NewBoat("Kayak", 275, 1, false),
        store.NewBoat("Canoe", 400, 3, false),
        store.NewBoat("Tender", 650.25, 2, true),
    }

    for _, b := range boats {
        fmt.Println("Conventional", b.Product.Name, "Direct:", b.Name)
    }
}
// or 
for _, b := range boats {
    fmt.Println("Conventional", b.Name, b.Price(0.2))
}
```

So if the field type is a value, such as `Product`, then any methods defined with `Product`or `*Product`receivers will be promoted -- if the field type is a pointerkm, then only methods with `*Product`receivers will be promoted.

### Understanding Composition and Interfaces

Composing types makes it easy to build up specialized functionality without having to duplicate the code required by a more general type that the `Boat`type in the product, fore, can build on the functionality provided by the `Product`type.