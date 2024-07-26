# Filtering a DataFrame

Learn how to declare logical conditions that include and exclude rows from `DataFrame`. See how to combine multiple conditions by using `AND`and `OR`logic, and utility methods simplify the filtering process.

### Optimizing a data for memory use

Quickly reducing memory in pands -- whenever importing a dataset, it’s important to consider whether each column stores its data in the most optimal type. The best is the one that consumes the least memory or provides the most utility.

```python
employees= pd.read_csv("...", parse_date=['Start Date'])
employees.info()
```

#### Converting data types with the `astype()`-- 

The `astype()`converts a `Series`'s values to a different data type. It accepts a single argument, the new datatype.
`employees.Mgmt.astype(bool)`

Updating a DataFrame column works similarly to setting a k-v pair in a dictionary. If a column with the specified name exist, pandas overwrites it with the new Series. If does not, pandas creates a new `Series`. like:

```python
employees.Mgmt = employees.Mgmt.astype(bool)
```

And in `employees`, pandas stores the `Salary`values as floats -- To support the `NaN`throughout the column, pandas converts the integers to float-pointing numbers. A technique requirement of the lib that we observed. if:

`employees['Salary'].astype(int)`-- `ValueError`raised

So, pandas is unable to convert the `NaN`values to integers, can solve this by replacing the `NaN`with a constant. The `fillna`replaces a `Series`null values with the argument.

```python
employees.Salary= employees.Salary.fillna(0).astype(int)
```

The `nunique()`method can reveal the number of unique values in each `DataFrame`column. Note that it *excludes* missing vlues from the count by default.

```python
employees.nunique()
```

So the `Gender`and `Team`stand out as good candidates to store categorical values. Just like;

```python
employees['Gender']=employees['Gender'].astype('category')
employees.Team = employees.Team.astype('category')
```

### Filtering by a single condition

Extracting a subset of data is perhaps the most common operation in data analysis. A *subset* is a portion of a larger data set that fit some kind of condition. Just like:

```python
employees['First Name']=='Maria'
employees[employees['First Name']=='Maria']
```

What if want to extract a subset of employees who are not on the Finance team -- like:

```python
employees[employees['Team'] != 'Finance']
# fore boolean series
employees[employees['Mgmt']]
```

### Filtering by multiple conditions

Can filter a DF with multiple conditions by creating two independent Boolean Series and then 

```python
is_female= employees.Gender=='Female'
in_biz_dev= employees.Team=='Business Dev'
employees[is_female & in_biz_dev]
```

Can include any amount of `Series`within the square brackets.

The `or`condition -- 

```python
enrning_below_40k = employees.Salary<40000
started_after_2015 = employees['Start Date']> '2015-01-01'
employees[enrning_below_40k | started_after_2015]
```

Inversion with `~`
The tilde inverts the values in the boolean Series, All `True`values become False, and `False`become `True`.

`employees[~(employees.Salary>=100000)]`

### Filtering by condition

Some filtering operations are more complex than simple equility or inequility checks -- 

The `isin`method -- 

```python
all_start_teams = ['Sales', 'Legal', 'Marketing']
on_all_start_team= employees['Team'].isin(all_start_teams)
employees[on_all_start_team].head()
```

The `between`method -- When working with numbers of dates, often want to extract values that fall within a range:

```python
higher_than_80 = employees.Salary>=80000
lower_than_90=employees.Salary<90000
employees[employees['Salary'].between(80000, 90000)] # [) range
```

#### The `isnull`and `notnull`methods

The employees data set includes plenty of missing values, can see a few missing values in like: the `dropna`method removes rows that hold any `NaN`values. Note that the `how`parameter’s default value is `any`-- an argument of `any`removes a row if any values is absent.

```python
employees.dropna().tail()
employees.dropna(subset=['Gender']).tail()
employees.dropna(subset=['Start Date', 'Salary']).head()
# and the thresh specifies a minimum threshold
employees.dropna(thresh=4).head()
```

## Data Types

- Common mistakes related to the basic types
- Fundamental concepts for slices and maps to prevent possible bugs, leaks, or iaccuracies.
- For Comparing

### Creating confusion with octal literals

Fore the `os.OpenFile`-- requires passing a permission as a `unit32`-- like:
`file, err := os.OpenFile("foo", os.O_RDONLY, 0644)`

### Neglecting integer overflows

Go provides a total of 10 integer types. At runtime, an integer overfolw or underflow is *silent* -- this does not lead to an application panic.

#### Detecting integer overflow when incrementing

Fore, want to detect an integer overflow during an increment operation with a type based on a defined size, can check the value against the `math`like:

```go
func Inc32(counter int32) int32 {
    if counter== math.MaxInt32 {
        panic("int32 overflow")
    }
    return counter+1
}

// about the int and unit types -- fore:
func Int32(counter uint) uint {
	if counter == math.MaxUint {
		panic("int overflow")
	}
	return counter + 1
}
```

Detecting integers overflow during addition

Multiplication is a bit more complex to handle.

```go
func MultiplyInt(a, b int) int {
	if a == 0 || b == 0 {
		return 0
	}
	result := a * b
	if a == 1 || b == 1 {
		return result
	}
	if a == math.MinInt || b == math.MinInt {
		panic("integer overflow")
	}
	if result/b != a { // check if overflow
		panic("integer overflow")
	}
	return result
}
```

### Understanding floating points

In Go, there are two floating-point types: `float32`and `float64`. The concept of a floating point was invented to solve the major problem with integers: their inability to represent factional values. To avoid bad surprises. need to know that floating-point arithmetic is an approximation of real arithmetic. 

### Understanding slice length and capacity

It’s pretty common for Go developers to mix slice length and capacity or not understand them thorouthly. In Go, a slice is backed by an array -- means that the slice’s data is stored contiguously in an array data structure. Internally, a slice just holds a pointer to the backing arrays plus a length and a capacity.

`s := make([]int, 3, 6)`

Creates an array of 6 elements -- cuz the length was set to 3, Go initilalize only the firste 3 elements. Accessing an element outside the length range is just forbidden. Fore: `s= append(s, 2)`-- The length of the slice is updated from 3 to 4 cuz the slice now contains 4,  If then `s = append(s, 3, 4, 5)`, cuz an array is a fixed-size structure, can store the new elements until element 4 When we want to insert element 5, the array is alreayd full, Go internally creates another array doubling the capacity, copying all the elements, and then inserting.

Note that the slice now references the new backing array  -- for the previous backing array -- no longer referenced, it’s eventually freed by the garbage collector (GC) if allocated on the heap, and we look at how the GC works in mistake. if:

```go
s1 := make([]int, 3, 6)
s2 := s1[1:3] // cap is 6, 6-1
s2 = append(s2, 2)
```

If : s2= append(s2, 3), .. repeated 3 times -- s1 and s2 now reference two different arrays. To summarize, the *slice length* is the number of available elements in the slice, whereas the *slice capacity* is the number of elements in the backing array.

### Slice initialization effectively

Fore, 

```go
func convert(foos []Foo) []Bar {
    bars := make([]Bar, 0)
    for _, foo := range foos {
        bars = append(bars, fooBar(foo))
    }
    return bars
}
```

Used `append`to add the `Bar`elements, `bars`first is empty, so adding the first element allocates a bcking array of size 1. For this every time the backing array is full, Go creates another array by doubling its capacity. The logic of creating another array cuz the current one is full is repeated multiple times.. There is no good reason not to give the Go runtime a helping hand. Like:

```go
func convert(foos []Foo) []Bar {
    n := len(foos)
    bars := make([]Bar, 0, n) // zero length and given capacity
    for _, foo := range foos {
        bars = append(bars, fooToBar(foo))
    }
    return bars
}
```

Internally, Go preallocates an array of `n`elements. The second is just preallocate to n length
`bars := make([]Bar, n)`

Fore, a function called `collectAllUserKeys`needs to iterate over a slice of structs to format particular byte slice. The resulting slice will be twice the length of the input slice.

```go
func collectAllUserKeys(cmp Compare,
	tombstones []tombstonWithLevel) [][]byte {
	keys := make([][]byte, 0, len(tombstones)*2)
	for _, t := range tombstones {
		keys = append(keys, t.Start.UserKey)
		keys = append(keys, t.End)
	}
}
//...
```

### `nil`vs *empty* slices

May want to use one over the other depending on the use case. Meanwhile, some libraries make a distinction between the two. To be proficient with slices, need to make sure we don’t mix these concepts.

```go
func main() {
	var s []string
	log(1, s) // true true

	s = []string(nil)
	log(2, s) // true true

	s = []string{} // empty: true, nil false
	log(3, s)

	s = make([]string, 0) // empty true, nil false
	log(4, s)
}

func log(i int, s []string) {
	fmt.Printf("%d: empty=%t\nnil=%t\n", i, len(s) == 0, s == nil)
}
```

All thes slices are empty, meaning the length equals 0, therefore, a nil slice is also an empty slice.

- One of the main differences between a `nil`and an empty slice regards allocations
- Regardless of whether a slice is `nil`, calling `append`works.

Consequently, if a func returns a slice, we shouldn’t do as in other languages and return a non-nil collection for defensive reasons. Cuz a `nil`slice doesn’t require any allocation, should favor returning a `nil`slice instead of an emtpy slice. Fore:

```go
func f() []string {
    var s []string  // nil true
    if foo(){
        s = append(s, "foo")
    }
    if bar(){
        s = append(s, "bar")
    }
    return s
}
```

Two options remain from the example that looks at different ways to initialize a slice like:

- `s := []string(nil)`
- `s := []string{}`

## Using HTML and Text Templates

The `html/template`provides support for creating multiple templates that are processed using a data structure to generate dynamic HTML output. Add `template.html`wtih the content -- 

```html
<h1>Tempalte Value: {{.}}</h1>
// ...
<h1>Extra template Value: {{.}}</h1>
```

Contain static content mixed with expressions that are enclosed in double curly braces, known as action.

### Loading and executing Templates

Using templates is a two-step process -- first, the template files are loaded and processed to create `Template`values.

- `ParseFiles(...files)`-- loads one and more files, which are specified by name. The result is a `Template`that can be used to generate content and an `error`that reports problems loading the templates.
- `ParseGlob(pattern)`-- This loads one or more files -- selected with a pattern. `Template`and `error`also.

Once the template files loaded, the `Template`value returned by the functions is used to select a template and execute it to produce content.

- `Templates()`-- returns a slice containing pointers to the `Template`values that has been loaded
- `Lookup(name)`-- return a `*Template`for the specified loaded template.
- `Name()`-- returns the name of the `Template`
- `Execute(writer, data)`-- Executes the `Template`, using the specified data and writes the output to the specified `Writer`.
- `ExecuteTemplate(writer, templateName, data)`- this function executes the template with the specified name and data and writes the output to the specified `writer`.

```go
func main() {
	t, err := template.ParseFiles("./templates/template.html")
	if err == nil {
		t.Execute(os.Stdout, &Kayak)
	} else {
		Printfln("Error: %v\n", err.Error())
	}
}
```

Used the `ParseFiles`function to load a single template. The result from the `ParseFiles`function is a `Template`.

#### Loading Multiple Templates

There are two approaches to working with multiple templates -- the first is to create a separate `Template`value for each like: 

```go
func main(){
    t1, err1 := template.ParseFiles("./template/template.html")
    t2, err2 := tempalte.ParseFiles("./template/extras.html")
    if (err1 == nil && err2== nil){
        t1.Execute(os.Stdout, &Kayak)
        os.Stdout.WriteString("\n")
        t2.Execute(os.Stdout, &Kayak)
    }else {
        ...
    }
}
```

And, using separate values is the simplest approach, but the alternative is to load multiple files into a single `Template`value then specify the name of the template you want to execute like:

```go
func main() {
	alltemplates, err1 := template.ParseFiles("./templates/template.html",
		"./templates/extras.html")
	if err1 == nil {
		alltemplates.ExecuteTemplate(os.Stdout, "template.html", &Kayak)
		os.Stdout.WriteString("\n")
		alltemplates.ExecuteTemplate(os.Stdout, "extras.html", &Kayak)
	} else {
		Printfln("Error: %v, %v\n", err1.Error())
	}
}
```

So when multiple files are loaded with the `ParseFiles`, the result is a `Template`value on which the `ExecuteTemplate`method can be called to execute a specified template. The filename is used as the template name, which means that the templates in this example are named `template.html`...

#### Enumerating loaded Templates

It can be useful to enumerate the templates that have been loaded, especially when using the `ParseGlob()`to make sure that all the expected files have been discovered -- like:

```go
func main() {
	alltemplates, err1 := template.ParseGlob("./templates/*.html")
	if err1 == nil {
		for _, t := range alltemplates.Templates() {
			Printfln("template name: %v", t.Name())
		}
	} else {
		Printfln("Error: %v", err1.Error())
	}
}
```

The pattern passed to the `ParseGlob()`selects all files with the `html`file extension in the `templates`folder.

#### Looking up a specific Template

An alternative to specifying a name is to use the `Lookup()`method to select a template like:

```go
func Exec(t *template.Template) error {
	return t.Execute(os.Stdout, &Kayak)
}

func main() {
	alltemplates, err1 := template.ParseGlob("./templates/*.html")
	if err1 == nil {
		selectedTemplated := alltemplates.Lookup("template.html")
		err1 = Exec(selectedTemplated)
	}
	if err1 != nil {
		Printfln("Error: %v", err1.Error())
	}
}
```

This example uses the `Lookup`method to get the template loaded from the `tempalte.txt`.