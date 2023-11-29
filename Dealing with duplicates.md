# Dealing with duplicates

Missing values are a common occurrence in messy data sets, and so are duplicate values.

### The `duplicated`method

The `dupliated()`returns a Boolean `Series`that identifies duplicates in a column -- Pandas returns `True`any time it sees a value that it previously encountered in the series. Consider the next -- the `duplicated()`method marks the first occcurrence of `Finance`in the Team clolumn as a nonduplicate with `False`.

`employees["Team"].duplicated().head()`

And the `duplicated()`has `keep`parameter informs pandas which duplicate occurrence to keep -- it’s default `first`keeps the first occurrence of each duplicate value. Can also ask pandas to mark the last occurrence of a value in a column as the non-duplicate -- pass `last`to `keep`like:
`employees["Team"].duplicated(keep='last')`

Say, want to extract one employees from each team -- one strategy could use is pulling out the first row for each unique team in the column. `True`indicates all duplicate values after the first encounter.
`(~employees["Team"].duplicated()).head()`

Now can extract one employee per team by passing the `Boolean`series inside square bracket -- Pandas will include the rows with the first occurrence of a value in the Team -- like:

```python
first_one_in_team = ~employees["Team"].duplicated()
employees[first_one_in_team]
```

This output tells us that .. is the first employee on the Marketing team.

### `drop_duplicates()`method

DF’s `drop_duplicates()`provides a convenient shortcut for accomplishing the operation -- by default, the method removes rows in which all values are equal to those in a *previously* encounted row. But, there are no rows in which all six row values are equal -- so the method doesn’t accomplish much for us with the std invocation. Can pass the method `subset`param with a list of columns that pandas should use to determine a row’s uniqueness.
`employees.drop_duplicates(subset=["Team"])`

Also accepts a `keep`parameter -- can pass it an arg `last`to keep the rows with each duplicate value’s last occurrence. like:
`employees.drop_duplicates(subset=["Team"], keep="last")`

Note, one additional option is availlable for `keep`parameter -- can pass it an arg of `False`to exclude all rows with dupliate values, pandas will reject a row if there are any other rows with the same value. fore, these first names occur only once in the DF: `employees.drop_duplicates(subset=['First Name'], keep=False)`

Say, want to identify duplicates by a combination of values across multiple columns. Fore, may want the first occurrence of each employe with a unique combination of `First Name`and `Gender`in the data set. Can pass a list of columns to the `drop_duplicates()`'s `subset`parameter -- Pandas will use the columns to determine the presence of duplicates. `employees.drop_duplicates(subset=["Gender", "Team"]).head()` -- The row at index 0 holds just the first occurrence of the name -- and gender in the employees dataset -- Pandas will exclude any other rows with the same two values from the results set.

### Code -- 

```python
netflix= pd.read_csv('../pandas-in-action/chapter_05_filtering_a_dataframe/netflix.csv',
                     parse_dates=['date_added'])
netflix.info()
netflix.nunique()
netflix['type']=netflix['type'].astype('category')

# equality to compare each title with the `Limitless`
netflix[netflix['title']=='Limitless']

directed_by_robert_rodriguez = (
    netflix['director']=='Robert Rodriguez'
)
is_movie= netflix['type']=='Movie'
netflix[directed_by_robert_rodriguez & is_movie]

# next asks all for all titles with date_added of 2019-07-31 like:
added_on_july_31 = netflix['date_added']== '2019-07-31'
directed_by_altman= netflix['director']=='Robert Altman'
netflix[added_on_july_31 | directed_by_altman]

# entries with a director of `Orson Welles`, ... create 3 boolean , but 
# a more concise and scalable way is to generate by isin
directors= ['Orson Welles', 'Aditya Kripalani', 'Sam Raimi']
target_directors= netflix['director'].isin(directors)
netflix[target_directors]

# Then the most concise way to find all rows with the date_added value between like:
may_movies=netflix['date_added'].between(
    '2019-05-01', '2019-06-01'
)
netflix[may_movies]

# dropna removes df rows with missing values, have to include the `subset` parameter like:
netflix.dropna(subset=['director']).head()

# the final asks to identify the days when Netflix added only one movie just:
netflix.drop_duplicates(subset=['date_added'], keep=False)
```

## Working with text data

Can get quite messy -- Real-world data sets are riddle with incorrect characters, improper letter casings, whitespace, and more. The process of cleaning data is called *wrangling* or *munging* -- majority of our data analysis is dedicated to munging.

### Letter casing and whitespace

Name column, inconsistency in letter casing -- most row vlaues are uppercase, some are lowercase, and some are noraml -- The preceding ouput does not show another problem hiding in inspections. Can use `vlaues`attribute on the `Series`to get the underlying `Numpy`ndarray storing the values like:
`inspections['Name'].head().values`

The `Series`object’s `str`attribute exposes a `StringMethos`object -- a powerful toolbox of methods of working with strings -- like: `inspections['Name'].str` And some methods work like py’s native string methods, whereas other methods are exclusive to pandas. Just like:
`inspections['Name'].str.lstrip().values`

Now can just overwrite our existing `Series`with the new one that has no extra whitespace -- on the right side of an eual use the `strip`code to create a new series. like:
`inspections['Name'] = inspections['Name'].str.strip()`

This one-line is suitable for a small data set may quickly become tedious for one with a large number of columns. Like:

```python
for column in inspections.columns:
    inspections[column]=inspections[column].str.strip()
```

All of Python’s character casing methods are available on the `StringMethods`object -- fore, the `lower`like:

`inspections['Name'].str.lower().head()`

And the complementary `str.upper`returns a series with uppercase strings. And the `str.capitalize`, and next step the `str.title`method -- which capitalizes each word’s first letter.

### String Slicing

Turn to the `Risk`column -- each row’s value includes both a numeric and categorical representation of the risk -- here is a reminder of what the column looks like -- `inspections['Risk'].head()` `inspections['Risk'].unique()`

Have to account for two additional values -- missing `NaNs`and the `All`string. like:

```python
inspections= inspections.dropna(subset=['Risk'])
inspections= inspections.replace(
    to_replace='All', value='Risk 4 (Extreme)'
)
```

## Writing to Files

The `os`package also includes functions for writing files -- like:

- `WriteFile(name, slice, modePerms)`-- creates a file with the specified name, mode, and permissions and wirtes the content of the specified `byte`slice. If the file already exists, its contents will be just replaced -- and the result is an `error`reports any problems
- `OpenFile(name, flag, modePerms)`-- opens the file with the specified name, using the flags to control how the file is opened. Result is a `File`provides access to the file contents and an `error`indicates problems opening.

### Using the Write Convenience Function

`WriteFile`provides a convenient way to write an entire file in a single step and will create the file if it does not exist.

```go
func main() {
	total := 0.0
	for _, p := range Products {
		total += p.Price
	}
	dataStr := fmt.Sprintf("Time: %v, Total: $%.2f\n",
		time.Now().Format("Mon 15:04:05"), total)

	err := os.WriteFile("output.txt", []byte(dataStr), 0666)
	if err == nil {
		fmt.Println("output file created")
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

Using the File struct to write to a File -- the `OpenFile`opens a file and return a `File`value -- Unlike `Open`, the `OpenFile`accepts one more flags that specify how the file should be opened. The flags are defined as constants in the `os`package -- care maut be taken with these flags. like:

```go
/ write only, create and append to the end
// if not exist, 
file, err := os.OpenFile("output.txt",
                         os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0666)

if err == nil {
    defer file.Close()
    file.WriteString(dataStr)
} else {
    Printfln("Error: %v", err.Error())
}
```

Combined the `O_WRONLY`to open the file writing, the `O_CREATE`file to create if it doesn’t already exist, and the `O_APPEND`flag to append any written data to the end of the file. And the `File`struct defines the methods to write data to a file once it has been opened -- like:

- `Seek(offset, how)`-- sets the location for subsequent operations
- `Write(slice)`-- writes the contents of the specified byte slice to the file
- `WriteAt(slice, offset)`-- writes the data in the slice at the specified location couterpart of `ReadAt`
- `WriteString(str)`-- writes a string to the file. This is a convenience method that converts the string to byte slice.

Writing JSON data to a File-- The `File`implements the `Writer`interface too -- which allows a file to be used with the functions for formatting and processing strings like:

```go
func main() {
	cheapProducts := []Product{}
	for _, p := range Products {
		if p.Price < 100 {
			cheapProducts = append(cheapProducts, p)
		}
	}

	file, err := os.OpenFile("cheap.json", os.O_WRONLY|os.O_CREATE, 0666)
	if err == nil {
		defer file.Close()
		encoder := json.NewEncoder(file)
		encoder.Encode(cheapProducts)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

This example selects the `Product`values with a `Price`value of less than 100, places them into a slice, and uses a `JSON``Encoder`to write that slice to a file.

### Using the Convenience Functions to create New Files

Although it is possible to use the `OpenFile`func to create new files, the `os`package also provides some useful convenience functions like:

- `Create(name)`-- equivalent to calling `OpenFile`with `O_RDWR O_CREATE O_TRUNC`-- results are `File`which can be used for reading and writing.
- `CreateTemp(dirname, filename)`-- creates a new file in the directory with the specified name. Note that if the name is the empty string, then the system temporary directory is used. Obtained using the `TempDir` 

Demonstrates the use of the `CreateTemp`function and shows how the location of the randomized component of the name can be controlled. like:

```go
file, err := os.CreateTemp(".", "tempfile-*.json")
```

If the empty string used, then the file will be created in the default temporary directory.

Working with File Paths -- The example so far in this have used files that are in the current working directory, which is just typically the locaiton from which the compiled exectuable is started. And if want to read and write files in other locations, then must specify file paths. Just like:

- `Getwd()`-- returns the current working directory
- `UserHomeDir, UserCacheDir, UserConfigDir, TempDir`methods.

## Using HTML and Text Templates

describe std lib packages that are used to produce HTML and text content from templates -- These template packages are useful when generating large amount of content and have extensive support for generating dynamic content.

- These allow HTML and text content to be generated dynamically from Go data values
- are useufl when large amounts of content are requried.
- The templates are HTML or text files, which are annotated with instructions for the template processing engine.
- The tempalte syntax is counterintuitive and is not checked by the go compiler, this means that the care must be taken to use the correct syntax.
- Tempalte are optional

```go
func (p *Product) AddTax() float64 {
	return p.Price * 1.2
}

func (p *Product) ApplyDiscount(amount float64) float64 {
	return p.Price - amount
}
```

### creating HTML Templates

The `html/template`package provides support for creating templates that are processed using a data structure to generate dynamic HTML output. Create the `html/tempaltes`folder and add it to a file -- `template.html`:

`<h1>Template value: {{.}}</h1>`

Templates contain static content mixed with expressions that are enclosed in {{}} -- known as *actions* -- the template uses the simplest action, which is period and which prints out the data used to execute the template.

Loading and executing Templates -- Using templates is just a **two-step** process, first, the template files are loaded and processed to create `Template`values -- 

- `ParseFiles(...files)`-- loads one or more, which are specified by name, the result is a `Template`that can be used to generate content and an `error`that reports problems loading the templates.
- `ParseGlob(pattern)`-- loads one or more -- selected by a pattern -- result is also a `Tempalte`that can be used to generate content and an `error`reports problems.

Once the templates files are loaded, the `Template`value returned by the function is used to select a template and execute it to produce content.

- `Templates()`-- returns a slice containing pointers to the `Template`values that have been loaded.
- `Lookup(name)`-- `*Template`for the specified loaded template
- `Name()`-- returns the name of the `Template`
- `Execute(writer, data)`-- executes the `Tempalte`, using the specified data and writers
- `ExecuteTemplate(writer, templateName, data)`-- executes the template with the specified name and data and writes to the writer.

```go
func main() {
	t, err := template.ParseFiles("templates/template.html")
	if err == nil {
		t.Execute(os.Stdout, &Kayak)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

used the `ParseFiles`to load a single template, the result from the `ParseFiles`is a `Template`, on which called the `Execute`method, specifying the std output as the Writer and a `Product`as the data for the tempalte to process.

Loading Multiple Templates -- there are just two approaches to working with multiple templates -- like:

```go
func main() {
	t1, err1 := template.ParseFiles("templates/template.html")
	t2, err2 := template.ParseFiles("templates/extras.html")

	if err1 == nil && err2 == nil {
		t1.Execute(os.Stdout, &Kayak)
		os.Stdout.WriteString("\n")
		t2.Execute(os.Stdout, &Kayak)
	} else {
		Printfln("Error: %v, %v", err1.Error(), err2.Error())
	}
}
```

Using separate `Template`values is the simplest, but the alternative is to load multiple files into a single `Tempalte`value and then specify the name of the template you want to execute like:

```go
func main() {
	allTemplates, err1 := template.ParseFiles("templates/extras.html",
		"templates/template.html")
	if err1 == nil {
		allTemplates.ExecuteTemplate(os.Stdout, "template.html", &Kayak)
		os.Stdout.WriteString("\n")
		allTemplates.ExecuteTemplate(os.Stdout, "extras.html", &Kayak)
	} else {
		Printfln("Error: %v %v", err1.Error())
	}
}
```

### Goroutines

Are unique to Go -- theya re not OS threads, and note exactly green threads too. What makes goroutines unique to Go are their deep integration with Go’s runtime -- Goroutines don’t define their own suspension or reentry points. Go’s runtime observes the runtime behaivior of goroutines and automatically suspends them when they block and then resumes them when they become unblocked.

```go
func main() {
	var wg sync.WaitGroup
	sayHello := func() {
		defer wg.Done()
		fmt.Println("Hello")
	}
	wg.Add(1)
	go sayHello()
	wg.Wait()
}
```

This will deterministically block the `main`until the goroutine hosting `sayHello`terminates. Closures close around the lexical scope they are created in, thereby capturing variables, if run a closure in a goroutine, does the closure operate on a copy of these variables or original?...

```go
var wg sync.WaitGroup
salutation := "Hello"
wg.Add(1)
go func() {
    defer wg.Done()
	salutation="Welcome"
}()
wg.Wait()
fmt.Println(salutation)
```

Goroutines execute within the same address space they were creted in.

```go
func main() {
	var wg sync.WaitGroup

	for _, sal := range []string{"hello", "greetings", "good day"} {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Println(sal)
		}()
	}
	wg.Wait()
}
```

And for this, 3 “good day” printed -- cuz the goroutines being scheduled may run at any point in time in the future, it is undertermined that values will be printed from within the goroutine. For this, there is high probability the loop will exit before the goroutines are begun. for the sal, falls out of scope.

The Go runtime is observant enough to know that a reference to the `sal`variable is still being held. So just copy that into the `go func()`as a parameter like:

```go
or _, sal := range []string{"hello", "greetings", "good day"} {
    wg.Add(1)
    go func(sal string) {
        defer wg.Done()
        fmt.Println(sal)
    }(sal)
}
```

In the following, combine the fact that goroutines are not garbage collected with the runtime’s ability to introspect upon itself and measure the amount of memory alloated.

### The `sync`package

The `sync`contains the concurrency primitives that are most useful for low-level access sync -- if worked in The difference between these language in go is that go has built a new set of concurrency primitives on top of the memory access sync primitives to provide you with an expanded set of things to work with.

`WaitGroup`-- is a great way to wait for a set of concurrent operations to complete when you eightr *don’t care about* the result of the concurrent operation, or have other means of collecting their results. If nether of those are true, suggest using channels and `select`instead. Basic use case:

```go
var wg sync.WaitGroup
wg.Add(1)  // indiate that one goroutine is beginning
go func() {
    defer wg.Done()  // ensure before exit the closure
    // ...
}()
wg.Wait()  // block the main until all have indicated exited.
```

It’s customary to couple calls to `Add`as closely as possible to the goroutines they are helping to track but sometimes you will find `Add`called to track a group of goroutines all at once. like.

