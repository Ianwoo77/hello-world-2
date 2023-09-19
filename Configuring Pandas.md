# Configuring Pandas

The library exposes many of its internal settings for us to alter. In this, learn how to configure options such as row and column limits, floating-point precision, and value rounding.

### Getting and setting pandas options

Pandas stores its settings in a single `options`object at the *top level* of the lib -- each option belones to a parent category, and the top-level `describe_option`returns the documentation for a given settings. Can pass it a string with the setting's name fore, `max_rows`option -- nested within the `display`parent category, and the `max_rows`setting configures the maximum number of rows that pandas prints before it truncaes a DF. Just like:

`pd.describe_option("display.max_rows")`

Pandas will print all library options that match the string argument. The library uses regexp to compare `describe_option`'s arg with its available settings. As a remainder, a *regular expression* is a search pattern for text.

`pd.describe_option('max_col')`

### Precision

The next example sets the precision to 2, the setting affects values in all 4 of the floating-point column like:

```py
pd.set_option('display.precision', 2)
pd.options.display.precision=2
```

And the `precision`setting alters only the presentation of floating-point numbers. Pandas just preserve the original values within the DF.

Maximum column width -- The `display.max_colwidth`setting sets the maximum number of characters pandas print before truncating a cell's text.

## Visualization

By default Notebook renders each `Matplotlib`visualization in a separate browser window. The windows can be a bit jarring,  for the `%matplotlib inline`-- to force Jupyter to render visualizations directly below the code in a cell. To render a visualization, invoke the `plot()`method on a pandas data structure -- By default, Matplotlib draws a line graph like: `space['Cost'].plot()`.

Can also invoke the `plot()`method on the sapce `DatFrame`itself, in the scenario, pandas produces the same output like: `df.plot()`-- and if a `DataFrame`just holds multiple numeric columns, Matplotlib will draw a separate line for each one. if there is a large gap in the magnitude of values between columns, the larger values can easily dwarf the smaller ones like:

```py
data=[
    [2000, 30000],
    [5000, 500000],
]
df = pd.DataFrame(data, columns=['small', 'large'])
df.plot()
```

when plot this, Matplotlib adjusts the graph scale to accomodate the large's values. And `plot()`method accepts a `y`parameter to identify the `DataFrame`column whose values, Matplotlib should plot. like: `space.plot(y='Cost')`, can also use the `colormap`parameter to alter the visualization like:

`space.plot(y='Cost', colormap='gray')`

To see a list of valid inputs for `colormaps`parameter just invoke the `colormaps()`method on the pyplot lib like:

`plt.colormaps()`

### Bar graphs

The `plot`'s `kind`parameter alters the type of chart that `Matplotlib`renders. A bar graph is an choice to display the counts of unique values in a data set.  fore: `space['Company Name'].value_counts().plot(kind='bar')`, can also change the `kind`argument to `barh`-- to render a horizontal br graph instead. like: 

`space['Company Name'].value_counts().plot(kind='barh')`

### Pie charts

A pie chart is a visualizaiton in which colored slices add up to form a whole circular pie fore:

`space['Status'].value_counts().plot(kind='pie')`

And to add a legend to a vidualizaiton like this one, can pass the `legend`parameter like:

`space['Status'].value_counts().plot(kind='pie', legend=True)`

## Grouping, joining and Sorting

`s.isnull, sort_index, sort_values, transpose(), T, pct_change()`

`df.pct_change()`-- for a given data frame, indicates the percentage difference between each cell and the corresponding cell in the preiovus row.

### Defining multiple variables with a single statement

```go
func main() {
	var price, tax = 275.00, 27.50
	fmt.Println(price + tax)
}

```

### Converting, parsing, and formatting values

Go doesn’t allow types to be mixed in operaitons and will not automatically convert types, except in the case of untped constans, to show how the compiler responds to mixed data types, contains a statement that applies the addition operator to values of different types. like:

```go
func main(){
    kayak := 275
    soccerBall := 19.50
    total:= kayak+soccerBall
    fmt.Println(total) // error, mismatched types int and float64
}
```

### Peroforming explicit type conversions -- 

An explicit conversion transforms a value to change its type as shown like:

```go
func main(){
    //...
    total := float64(kayak)+ soccerBall
}
```

### Understanding the limiations of explicit conversions

Explicit conversions can be used when the value can be *represented* in the target type. This means that you can convert between numeric types and between strings and runes. FORE:

`fmt.Println(int8(total))`

When converting from floating to an integer -- the fractional part of the value is discarded.

Converting to integers -- `Ceil(), Floor(), Rond(), RoundToEven()`

```go
func main() {
	kayak := 275
	soccerBall := 19.50

	total := kayak + int(math.Round(soccerBall))
	fmt.Println(total)
}

```

`math.Round()`will round the var from 19.5 to 20.

### Parsing from Strings

The Go stdlib includes the strconv package, which provide functions for converting `string`values to other basic data type, like:

- `ParseBool(str)`
- `ParseFloat(str, size)`-- parses a string into a floating-point value
- `ParseInt(str, base, size)`
- `ParseUint(str, bse, size)`
- `Atoi(str)`-- parses a string into a base 10 `int`and equivalent to call `ParseInt(str, 10, 0)`

```go
func main(){
	val1 := "true"
	val2 := "false"
	val3 := "not true"

	bool1, b1err := strconv.ParseBool(val1)
	bool2, b2err := strconv.ParseBool(val2)
	bool3, b3err := strconv.ParseBool(val3)

	fmt.Println(bool1, b1err)
	fmt.Println(bool2, b2err)
	fmt.Println(bool3, b3err)	// parse invlalid syntax

}
```

Care must be taken to inspect the error result cuz the other result will default to the zero value when the string cannot be parsed. If U don’t chek the error result, will not be able to differentiate between a `false`value that has been correctly parsed from a string and the zero value that has ben used cuz parsing failed. like;

```go
if b1err == nil {
    fmt.Println("parsed value": bool1)
}else{
    fmt.Println("Cannot parse", val1)
}
```

Just like:

```go
if bool1, b1err := strconv.ParseBool(val1); b1err == nil {
    fmt.Println("parsed value:", bool1)
}else {
    fmt.Println("Cannot parse", val1)
}
```

### Parsing integers

The `ParseInt()`and `ParseUnit`requrie the **base** of the number represented by the string and the size of the data type that will be used to represent the parsed value like:

```go
func main() {
	val1 := "100"

	// base for number, 0 to let function to detect
	// size 8 data type allocated
	int1, int1err := strconv.ParseInt(val1, 0, 8)
	if int1err == nil {
		fmt.Println("parsed value", int1)
	} else {
		fmt.Println("Cannot parse", val1)
	}
}
```

Here, if the val1 is “1000”, then the `int1err`will indicate that the error is value out of range.

### Parsing Binary, Octal, and Hexadecimal integers

The `base`argument received by the `Parse<Type>`functions allows non-decimal number like:

`int1, int1err := strconv.ParseInt(val1, 2, 8)`

For this, the int1 is 4. the `100`is parsed with base 2. Or reverse like:

```go
func main() {
	val1 := "0b1100100"
	int1, int1err := strconv.ParseInt(val1, 0, 8)
	if int1err == nil {
		fmt.Println("parsed value", int1)
	} else {
		fmt.Println("Cannot parse", val1, int1err)
	}
}
```

The base `0b, 0o, 0x`

### Using the integer convenience Function

For many projs, the most common parsing task is to create `int`values from strings that contain decimal like:

`int1, int1err := strconv.Atoi(val1)`

### Parsing Floating Numbers

The `ParseFloat`function is used to parse things containing float-point numbers like:

```go
func main() {
	val1 := "48.95"
	float1, float1err := strconv.ParseFloat(val1, 64)
	if float1err == nil {
		fmt.Println("Parsed value", float1)
	} else {
		fmt.Println("Cannot parse", val1, float1err)
	}
}

```

And also can parse expressed with an expression like `val1: = "4.895e+01"`.

### Formatting values as Strings

The Go stdlib also provides functionally for converting basic data values into strings, which can be used directly or composed with other strings. Just like:

- `FormatBool(val)`-- the function returns the string `true`for `false`based on value of the `bool`.
- `FormatInt(val, base)`-- the func returns a string representation of the specified `int64`value, expressed in the specified base.
- `FormatUnit(val, base)`
- `FormatFloat(val, format, precision, size)`-- returns a string reprsentation of the specified `float64`
- And `Itoa(val)`

Fore:

```go
val := 275
fmt.Prinln("Base 2", strconv.FormatInt(int64(val), 2))
```

### Using the integer Convenience Function

Integer values are most commonly represented using the `int`type and are converted to strings using base 10.

`base10String := strconv.Itoa(val)`

### Formatting Floating-point values

```go
func main() {
	val1 := 48.95

	// 2 for prec, fraction bit
	Fstring := strconv.FormatFloat(val1, 'f', 2, 64)
	Estring := strconv.FormatFloat(val1, 'e', -1, 64)
	fmt.Println(Fstring)
	fmt.Println(Estring)
}

```

## Gird Layout

Gird layout is a *generalized* layout system -- with its emphasis on rows and colukmns -- it might at first feel like a return to table layout, grid allows pieces of the design to be laid out independently of their document source order, and even overlap pieces of the layout. Css provides powerfully flexible methods for defining repeating patterns of grid lines, attaching elements to those grid lines.

### Creating a Grid Container

The first step to creating a grid is defining a grid container -- this is much like a containing block is positioning, or a flex container in flexible-box layout. At the basic level, grid layout is quite reminiscent of flexobx. CSS has two kinds of grids, regular girds and inline grids -- these are created with special values for `display: gird`and `display: inline-grid`-- the first gnerates a block-level box, and the second an inline-level box.

These are very similar to the `block`and `inline-block`for `display`. Although the `display:grid`creates a block-level grid, the specification is careful to explicitly state that gird containers are not block containers. First off, floated elements do not intrude into the grid container.

### Basic Grid

Can think of it like the way an element set to `display: table`creates a table-formatting context within it. like:

```css
#warning {
    display: grid;
    background: #FCC;
    padding: 0.5em;
    grid-template-rows: 1fr;
    grid-tempalte-columns: repeat(7, 1fr);
}
```

And note that -- grid with a top margin, the grid itself also has a top margin -- the two margins do not collapse.

*Grid track* - A continuous run between two adjacent grid lines -- in other words, a *grid column* or a *grid row* -- it goes from one edge of the grid container to the other. The size of a grid track is dependent on the placement of the grid lines that define it.

*Grid cell* - Any space bounded by four grid lines.

*Grid area* -- any rectangular area bounded by 4 gird lines and made up of one or more grid cells, An area can be as small as single cell or as large as all the cells in the grid.

### Creating Grid lines

It turns out that creating grid lines can get farily complex, that is not so much cuz the concept is difficult. CSS just provides many ways to get it done. Note that a grid line can have more than one name. Can use any of them to refer to a given grid line, though you can’t combine them the way you can multiple class names.

### Using Fixed-width Grid tracks

Don’t necessarily mean a fixed length like pixels or ems -- percentages also count as filxed width here, in this context, *fixed width* means the grid lines are placed such that the distance between them does not change cuz of content changes within the grid tracks. FORE:

```css
#grid {
    display: grid;
    grid-template-columns: 200px 50% 100px;
}
```

If want to name grid lines like: Just place any grid-line name you want, and as many as you want in:

```css
#grid {
    display: grid;
    grid-temlate-columns;
    [start col-a] 200px [col-b] 50% [cal-c] 100px [stop end last]
}
```

What’s nice ist that adding the names makes clear that each value is actually specifying a gird track’s width, which means three is always a grid line to either side of a width value. Thus, for the tree widehs have, four grid lines are actually created.

### Using Flexible Grid Tracks

Thus far, all our grid tracks have been inflexible, their size determined by a length measure or the grid container’s dimensions. but unaffected by any other considerations.