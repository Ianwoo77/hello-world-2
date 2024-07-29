# Dealing with duplicates

Missing values are a common occurrence in messy data sets, and so duplicate values.

`duplicated()`method -- like:

```python
employees['Team'].duplicated().head()
```

The `duplicated()`method marks the first occurrence in the `Team`column as a non-duplicate with `False`, marks all subsequent occurrences as duplicates as `True`.

```python
employees['Team'].duplicated(keep='first').head()
employees['Team'].duplicated(keep='last').head()
```

Want to extract one employee from each team.
`(~employees['Team'].duplicated()).head()`

Now can extract one employee per team by passing the `Boolean`series inside like:

```python
first_one_in_team = ~employees['Team'].duplicated()
employees[first_one_in_team]
```

#### `drop_duplicates`method

provides a convenient shortcut for accomplishing the operation -- by default, the method removes rows in which all values are equal to thsoe in a previously encounted row.

```python
employees.drop_duplicates()
# can pass the parameter subset with a list of columns that pandas should use to determine a row's uniqueness
employees.drop_duplicates(subset=['Team'])
```

And also accepts a `keep`parameter, can pass it an argument of `last`to keep the rows with each duplicate value’s last occurrence. `employees.drop_duplicates(subset=['Team'], keep='last')`

And one additional option is available for the `keep`-- can pass an argument of `False`to exclude all rows with duplicate values. Pandas will reject a row if *there are any other rows with the same value*. like:

```python
employees.drop_duplicates(subset=['First Name'], keep=False)
```

And, say want to identify duplicates by a combination of values acorss multiple columns, may want the first occurrence of each employee with a unique combination of `First Name`and `Gender`in the data set. fore:

```python
name_is = employees['First Name']=='Douglas'
is_male= employees.Gender=='Male'
employees[name_is & is_male]
```

And, can also pass a list of columns to the `drop_duplicate()`subset parameter. Fore:
`employees.drop_duplicate(subset=["Gender", 'Team'])`

### Working with text -- 

We can use the `values`attribute on the `Series`to get the underlying Numpy `ndarray`storing the values:
`inspections['Name'].head().values`

The `Series`str attribute exposes a `StringMethods`object,  a powerful toolbox of methods for working with strings:
`inspections['Name'].str`

Any time like to perform string manipulations, invoke a method on the `StringMethods`object rather than the `Series`itself. Some methods work like py’s native string methods. Fore:

```python
inspections['Name']= inspections.Name.str.strip()
```

Can use Python’s for loop to iterate over each column, extract it dynamicallyh from the `DataFrme`like:\

```python
for col in inspections.columns:
    inspections[col]=inspections[col].str.strip()
```

All of Py’s character casing methods are available on the `StringMethods`object like the `lower`fore:

```python
inspections.Name.str.lower() # also upper(), capitalize(), title()
```

### String slicing

```python
inspections['Risk'].unique()
# can remove missing values from a series with the dropna then.
inspections= inspections.dropna(subset=['Risk'])
# then can use the str replace() method:
inspections= inspections.replace(to_replace='All', value='Risk 4 (Extreme)')
```

#### String slicing and character replacement

Can now use the `slice`method on the `StringMethods`object to extract a substring from a string by index pos -- the method accepts a starting index and an ending index as arguments. fore:

```python
inspections['Risk'].str.slice(5,6).head()
inspections['Risk'].str[5:6].head()
```

## Making slice copies correctly

The `copy`built-in allows copying elements from a source slice into a destination -- although it is a handy bult-in, Go developers sometimes misunderstand it.

```go
src := []int {0, 1, 2}
var dst []int
copy(dst, src) // nothing copied
```

To use the `copy`effectively, it’s essential to understand that the number of elements copied to the destination slice corresponds to the minmum between -- 

- The source slice’s length
- The destination slice’s length

Therefore, the `copy`function just cipies the minimum number of elements, 0 in this case. So want to perform a complete copy, the destination slice must have a length greater then or equal to the source’s length.

```go
dst := make([]int, len(src))
copy(dst, src)
```

`copy`func is used to copy elements from one slice to another, works at the slice level and can be based for copying elements between slices of the same type.

`io.Copy()`is used to copy data from an `io.Reader`to an `io.Writer`. commonly used for copying data between files, network connections, or other I/O streams.

```go
sourceFile, err := os.Open("source.txt")
if err != nil {
    log.Fatalf(...)
}
defer sourceFile.Close()

// Create the destination file
destinationFile, err := os.Create("destination.txt")
if err != nil {
    //...
}
defer destinationFile.Close()

byteCopied, err := io.Copy(destinationFile, sourceFile)
if err != nil {
    //...
}
```

Also mention that using the `copy`built-in func isn’t the only way to copy slice elements. There are different alternatives, the best known being probably the following -- like:

```go
src := []int{0, 1, 2}
dst := append([]int(nil), src...)
```

### Side effects using slice append

```go
s1 := []int {1, 2, 3}
s2 := s1[1:2]
s3 := append(s2, 10)
```

If it is not full, the `append()`functions just adds the element by updating the backing array and returning a slice having a length incremented by 1. For this, in the backing array, updated the last element to store 10. So:

```go
func main(){
    s := []int {1,2,3}
    sCopy := make([]int, 2)
    copy(sCopy, s)
    f(sCopy)
    result := append(sCopy, s[2])
}
```

Cuz pass a copy to `f`, even if this func calls `append`, will not lead to a side effect outside of the range of the first two elements. Second optoin can be used to limit the range of potential side effects to the first two elements only. This option involves the so-called *full slice expresion* -- like:

```go
func main(){
    s := []int {1,2,3}
    f(s[:2:2]) // cap = 2-0=2
}
```

So when passing `s[:2:2]`, can limit the range of effects to the first two elements.

### Slices and memory leaks

This shows that the slicing an existing slice or array can lead to memory leaks in some conditions. Discuss two cases one where the capacity is leaking and another that is related to pointers.

#### Leaking capacity

Imagine implementing a custom binary protocol -- A message can contain fore, 1M bytes, and the first 5 bytes represent the message type, fore consuem these messages, and for auditing purposes, want to store the latest 1000 in the memory -- fore:

```go
func consumeMessages() {
    for {
        msg := receiveMessage()
        // do sth with msg
        storeMessageType(getMessageType(msg))
    }
}

func getMessageType(msg []byte) []byte {
    return msg[:5]
}
```

fore, the `getMessageType()`computes the message type by slicing the input slice. However, when deploy, notice that our app consumes about 1GB of memory.

The slicing operation on msg using `msg[:5]`-- creates a 5-len slice. its capacity remains the same as the initial slice. The remaining elements are still allocated in memory. So the backing array of the slice still contains 1M bytes after the slicing operation. Hence, if keep 1000 messages in memory, instead of storing about 5K, 1G just hold, can do:

```go
func getMessageType(msg []byte) []byte{
    msgType := make([]byte, 5)
    copy(msgType, msg)
    return msgType
}
```

#### Full slice expressions

```go
func getMessageType(msg []byte) []byte {
    return msg[:5:5]
}
```

But -- would the GC be able to re-claim the inaccesible space from byte 5 -- The Go specification doesn’t officially specify the behavior.

As a rule of thumb, remember that slicing a large slice or array can lead to pontential high memory consumption. The remaining space won’t be reclaimed by the GC.

#### Slice and Pointers

Which ar still part of the backing array but outside the length range -- fore:

```go
type Foo struct {
    v []byte
}
```

Want to check the memory allocations after each step as -- 

1. Allocate a slice of 1000 `Foo`elements
2. Iterate over each `Foo`, and for each one, allocate 1MB for the `v`
3. Call `KeepFirstTwoElementsOnly()`returns only the first two elements using slicing, and then call `GC`

```go
func main() {
    foos := make([]Foo, 1000)
    printAlloc()  // 1MB
    for i:=0; i<len(foos); i++ {
        foo[i]=Foo {
            v: make([]byte, 1024*1024)
        }
    }
    
    two := keepFirstTwoElementsOnly(foos)
    runtime.GC()
    runtime.KeepAlive(two)
}

func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    return foos[:2]
}
```

Noticed that the `GC`did not collecth the remaining 998 elements after the last step. Note that *if the element is a pointer or struct with pointer fileds*, the element won’t be reclaimed by the GC. There fore, eventhough these 998 elements can’t be accessed, they stay in memory as long as the varaible returend. Just:

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    res := make([]Foo, 2)
    copy(res, foos)
    return res
}

// the second option like:
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    for i:=2; i<len(foos); i++ {
        foos[i].v=nil // gc on collect backing arrays
    }
    return foos[:2]
}
```

### Map initialization

A *map* provides an unordered collection of K-V pairs in which all the keys are distinct. In Go, a map is based on the hash table data structure. Internally, a hash table is an array of buckets, and each bucket is a pointer to an array of k-v pairs. Each operation is done by associating a key to an array index. this function is stable on a hash function.

Note that in the case of insertion into a bucket that is already full -- Go creates another bucket of 8 elements and links the previous bucket to. Regarding reads, updates, and deletes, Go must calculate the corresonding array index. Then Go iterates sequentially over all the keys until it finds the provided one.

#### Initialization

```go
m := map[string]int {
    "1":1, "2": 2, "3": 3,
}
```

This map is just backed by an *array* consisting of a single entry. Hence, a single bucket. In the worst case, going over thousands of buckets. When a map grows, it doubles its number of buckets. This is why a map should be able to grow automatically to cope with the number of elements. And when a map grows, it doubles its number of buckets.

- The average number of items in the buckets is greater than a constant value, 6.5.
- Too many buckets have overflowed.

Idea is smilar for maps, can use the `make`also:
`m := make(map[string]int, 1000000)`

Therefore, just like with slices, if know up front the number of elemetns a map will contain, could create it by providing an initial size.

## Looking up a Specific Template

```go
func Exec(t *template.Tempalte) error {
    return t.Execute(os.Stdout, &Kayak)
}

func main(){
    allTemplates, err := template.ParseGlob("/templates/*.html")
    if err == nil {
        selectedTempalted := allTemplates.Lookup("template.html")
        err = Exec(selectedTempalted)
    }
    if err != nil {
        Printfln("Error: %v, %v" err.Error())
    }
}
```

### Understanding Template Actions

Supports a wide range of actions, can be used to generate content from the data that is passed to the `Execute`or `ExecuteTempalte`method.

- `{{func arg}}`-- invokes a func and inserts the result into the output.
- `{{expr | value.method}}`-- chained together using a vertical bar
- `{{range value}}`iterates through the specified slice and adds the content between the `range`and `end`keyword
- `{{define “name”}}`-- defines a template with the specified name
- `{{template "name" expr}}`-- executes the template with the specified name and data and inserts the result into the output.
- `{{block "name" expr}}... {{end}}`-- defines, and invokes it with the specified data. Used to define a template that can be replaced by one loaded from another file.

#### Inserting Data Values

```html
<h1>Tempalte Value: {{.}}</h1>
<h1>Name: {{.Name}}</h1>
<h1>Category: {{.Category}}</h1>
<h1>Price: {{.Price}}</h1>
<h1>Tax: {{.AddTax}}</h1>
<h1>Discount price: {{.ApplyDiscount 10}}</h1>
```

#### Formatting Data Values

Templates support built-in functions for common tasks, including formatting data values that are inserted into the output -- like -- `print printf println html js urlquery`

```html
<h1>Price: {{printf "$%.2f" .Price}}</h1>
<h1>Tax: {{.AddTax | printf "$%.2f"}}</h1>
```

#### Trimming --

By default, the contents of the template are rendered exactly as they are defined in the file, including any whitespace between actions. HTML isn’t sensitvie to the whitespace between elements, but whitespace can still cause problems for text content and attribute values. like:

```html
<h1>
    Name: {{.Name}}, Category: {{.Category}}, Price, 
    {{printf "$%.2f" .Price}}
</h1>
```

The minus sign can be used to trim whitespace, applied immediately after or before the braces hat open or close an action. And the whitespace around the final action has been removed, but there is still a newline character after the tag

`{{- "" -}} Name: {{.Name}}, Category: {{.Category}}, Price,`

#### Using Slices in Templates

Tempalte actions can be used to generate content for slices, like:

```html
{{ range . -}}
    <h1>Name: {{.Name}}, Category: {{.Category}}, Price,
        {{- printf "$%.2f" .Price -}}
    </h1>
{{end}}
```

#### Using Built-in Slice functions

Go text templates support the built-in functions for working with slices -- like:

- `slice`-- this creates a new slice, its arguments are the original slice, start index, and the end index
- `index`-- returns the element at the specified index
- `len`-- This returns the length of the specified slice.

```html
<h1>There are {{len .}} products in the source data.</h1>
<h1>First product: {{index . 0}}</h1>
{{range slice . 3 5 -}}
    <h1>Name: {{.Name}}, Category: {{.Category}}, Price,
        {{- printf "$%.2f" .Price -}}
    </h1>
{{end}}
```

#### Conditionally Executing Template Content

Actions can be used conditionally insert content into the output based on the evaluation of their expressions like:

```html
<h1>There are {{len .}} products in the source data.</h1>
<h1>First product: {{index . 0}}</h1>

{{range . -}}
    {{if lt .Price 100.00 -}}
        <h1>Name: {{.Name}}, Category: {{.Category}}, Price,
            {{- printf "$%.2f" .Price -}}
        </h1>
    {{end -}}
{{end}}
```

#### Using the optional Conditional Actions

The `if`also can be used with optional `else`and `else if`.

### Creating Named Nested Templates

The `define`action is used to create a nested template that can be executed by name, which allows content to be defined once and used repeatedly with the `tempalte`action like:

```html
{{define "currency"}} {{printf "$%.2f" .}}{{end}}

{{define "basicProduct" -}}
    Name: {{.Name}}, Category: {{.Category}}, Price,
    {{- template "currency" .Price}}
{{- end}}

{{define "expensiveProduct" -}}
    Expensive product {{.Name}} ({{template "currency" .Price}})
{{- end}}

<h1>There are {{len .}} products in the source data.</h1>
<h1>First product: {{index . 0}}</h1>
{{range . -}}
    {{if lt .Price 100.00 -}}
        <h1>{{template "basicProduct" .}}</h1>
    {{else if gt .Price 1500.00 -}}
        <h1>{{template "expensiveProduct" .}}</h1>
    {{else -}}
        <h1>Midrange product: {{.Name}} ({{printf "$%.2f" .Price}}</h1>
    {{end -}}
{{end}}
```

A named template can invoke other named templates. And nested named templates can exacerbte whitespace cuz the whitespace around the tempaltes.

```html
{{define "mainTemplate"}}
    <h1>There are {{len .}} products in the source data.</h1>
    <!-- .... -->
{{end}}
```

Then in the program just like: `selectedTemplated := alltemplates.Lookup("mainTemplate")`, So using the `define`and the `end`keywords for the main template content excludes the whitespace used to separate the other named templates.

#### Defining Template Blocks

Themplate blocks are used to define a template with default content that can be overridden in another template file, which requires multiple templates to be loaded and executed together. This is often used to common content.

```html
{{define "mainTemplate" -}}
    <h1>This is the layout header</h1>
    {{block "body" . -}}
        <h2>There are {{len .}} products in the source data.</h2>
    {{- end}}
    <h1>this is the layout footer</h1>
{{end}}
```

Fore, when used alone, the output from the template file includes the content in the block. But this content can be redefined by another template file.

```html
{{define "body"}}
    {{range .}}
        <h2>Product: {{.Name}} ({{printf "$%.2f" .Price}})</h2>
    {{end -}}
{{end}}
```

```go
alltemplates, err1 := template.ParseFiles("templates/template.html",
    "templates/list.html")
```

The templates must be loaded so that the file that contains the block action is loaed before the file that contains the `define`action that redefines the template.

#### Defining Template Functions

The built-in template functions described can be supplemented by custom functions that specific to a `Template`, meaning that they are efined and set up in code.

```go
func GetCategories(products []Product) (categories []string) {
	catMap := map[string]string{}
	for _, p := range products {
		if catMap[p.Category] == "" {
			catMap[p.Category] = p.Category
			categories = append(categories, p.Category)
		}
	}
	return
}
```

```go
allTemplates := template.New("allTemplates")
allTemplates.Funcs(map[string]any{
    "getCats": GetCategories,
})

alltemplates, err1 := allTemplates.ParseGlob("templates/template.html")
```

So the `GetCategories`receives a `Product`slice and returns the set of unique `Categories`. To set tup the `GetCategories`function so that it can be used by a `Template`, the `Funcs`method is called, passing a map like:

```go
allTemplates.Funcs(map[string]any{
    "getCats": GetCategories,
})
```

The map specifies that the `GetCategories`func will be invoked using the anme `getCats`. Note that the `Funcs`method must be called before template files are parsed, which means creating a `Template`using the `New`func, which then allows the custom functions to be registered before the `ParseFiles`or `ParseGlob()`is called.

```html
{{define "mainTemplate" -}}
    <h1>There are {{len .}} products in the source data.</h1>
    {{range getCats . -}}
        <h1>Category: {{.}}</h1>
    {{end}}
{{- end}}
```

So the `range`keyword is used to enumerate the categories returned by the custom function, which are included in the template output.