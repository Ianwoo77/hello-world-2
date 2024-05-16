# Reading from and writing to JSON files

A JSON response consists of k-v pairs, in which a key serves as a unique identifier for a value. Keys must be strings, and values can be of any data type, including strings, numbers, and booleans. 

### Loading a JSON file into a DataFrame

JSON can be stred in a plain-text file wiht a `.json`fore: The JSON consists of top-level `prizes`that maps to an array of dictionaries one for each combination of year and category. The `year`and `category`fore. For the `laureates`key just connects to an array of dictionaries, each with its own `id`... Goal is to convert the data to tabular format. need to extract the JSON’s top-level, key-value pairs to seaprate `DataFrame`columns. Also need to iterate over each dictionary in the list.

The process of moving nested records of data into a single 1D list is called *flattening* or *normalizing*.

```python
# json_normalize, top-level
pd.json_normalize(nobel.loc[0, 'prizes'])
# `record_path` parameter to normalize the nested records like:
pd.json_normalize(nobel.loc[0, 'prizes'], record_path='laureates')
# and, for now, pandas expanded the nested dict into new columns, lost the original year and category so:
pd.json_normalize(nobel.loc[0, 'prizes'], record_path='laureates',
                  meta=['year', 'category'])
```

For now, that is exactly the `DataFrame`we want, our strategy has worked successfully on a single dictionary from the column, then:

```python
pd.json_normalize(nobel.loc[:, 'prizes'], record_path='laureates',
                  meta=['year', 'category'])
```

`KeyError`raised -- cuz some dictionaries in the prizes `Series`do not have a `Laureates`key -- the `json_normalize`function is unable to extract nested laureates info from a non-existent list. So for this, just need to set the original dict’s default value using `setdefault`method like:

```python
nobel.loc[:, "prizes"].apply(lambda dt: dt.setdefault("laureates", []))
pd.json_normalize(
    nobel.loc[:, "prizes"], record_path="laureates", meta=["year", "category"]
)
```

For this, just normalized the JSON data, converted it to tabular format, and store it in a 2D `DataFrame`.

#### Exporting a DataFrome to a JSON file

Attempt the process in reverse, converting a `DataFrame`to a SJON representation and writing it to a JSON file. The `to_json`method creates a JSON string from a pandas data structure, its `orient`parameter customizes the format in which pandas returns a data. The next uses like: Fore, an pass arugment of `split`to return a dictionary with separate `columns`. this option prevents the duplication of column names.

```python
winner.head(2).to_json('winner2.json', orient='split')
```

When JSON format fits your expectations, pass the JSON file name as the first argument to the `to_json`method.

### Reading from and Writing to CSV files

Next data set is a collection of baby names in NewYork city. Each row includes the name, birthday, gender, .. Can acess the website in our web browser and download the CSV file to our computer for local storage. As an alternative, can pass the URL as the first argument to the `read_csv`function. Pandas will automatically fetch the data set and import it into a `DataFrame`. Hardcorded URLs are helplful when we have real-time data that changes frequetnly cuz they save us the manual work of downloading the data set each time we return our analysis.

```python
url = "https://data.cityofnewyork.us/api/views/25th-nujf/rows.csv"
baby_names = pd.read_csv(url)
baby_names.head()
```

Try writing the baby_names `DataFrame`to a plain CSV file with the `to_csv`method, without an argument, the method outputs the CSV string directly in our . For `\n`just marks line brek in Python.

```python
print(baby_names.head(10).to_csv())
```

And, by default, pandas includes the `DataFrame`index in the CSV string. Notice the comma at the beginning of the string and the numeric value after each `\n`symbol. Can just exclude the index by passing the `index`parameter an argument of `False` -- like:

```python
print(baby_names.head(10).to_csv(index=False))
```

Then, to write the string to a CSV file, can pass the desired filename as the first argument to the `to_csv`method. like:

```python
baby_names.to_csv('NYC_baby_names.csv', index=False)
```

By default, pandas writes all `DataFrame`columns to the csv file, can choose which columns to export by passing a list of names to the `columns`parameter. The next creates a CSV with only the .. like:

```python
baby_names.to_csv(
    "NYC_baby_names.csv", 
    index=False,
    columns=["Gender", "Child's First Name", "Count"]
)
```

## Defining Template Blocks

Template blocks are used to define a template with default content that can be overriden in another template file, which requires multiple templates to be laoded and executed together. This is often used to common content like:

```html
{{define "mainTemplate" -}}
    <h1>This is the layout header</h1>
    {{- block "body" .}} 
<!-- -->
```

So the `block`action is used to assign a name to a template, but unlike the `define`action the `template`will be included in the output without needing to use a `template`action, which can see like: When be used alone, the output from the template file includes the content in the block. But this content can be *re-defined* by another template file.

```html
{{define "body"}}
    {{range . -}}
        <h2>Product: {{ .Name}} ({{printf "$%.2f" .Price}})</h2>
    {{end -}}
{{end}}
```

### Defining Template Functions 

The built-in template functions desctibed in earlier sections can be supplemented by custom functions that are specific to a `Template`, meaning they are defined and set up in code like:

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

func main() {
	allTemplates := template.New("allTemplates")
	allTemplates.Funcs(map[string]any{
		"getCats": GetCategories,
	})
	allTemplates, err := allTemplates.ParseGlob("templates/*.html")
	if err == nil {
		selectedTemplate := allTemplates.Lookup("mainTemplate")
		err = Exec(selectedTemplate)
	}
	if err != nil {
		fmt.Printf("Error: %v", err.Error())
	}
}
```

The `GetCategories`function receives a `Product`slice and return the set of unique `Category`values. To set up the `GetCategories`func so that it can be used by a `Template`, the `Funcs`method is called, passing a map of names to functions like this:

```go
allTemplates.Funcs(map[string]any {}{
    "getCats": GetCategories,
})
```

The map specifies that the `GetCategories`func will be invoked using the name `getCats`, the `Funcs`method must be called before template files are parsed, which means that creating a `Tempalte`using the `New`function.

The map sepcifies that the `GetCagegories`func will be invoked using the name `getCats`, *the `Funcs`method must be called before template files are parsed*, which means creating a `Template`using `New`function, which then allows the custom functions to be registered before the `ParseFiles`or `ParseGlob`methods is called.

```go
allTemplates := template.New("allTemplates")
allTemplates.Funcs(map[string]any) {
	"getCats" : GetCaregories,
})
allTemplates, err := allTemplates.ParseGlob("templates/*.html")
```

```html
{{define "mainTemplate" -}}
    <h1>There are {{ len .}} products in the source data.</h1>
    {{range getCats . -}}
        <h1>Category: {{.}}</h1>
    {{end}}
{{- end}}
```

There are `range`keywords is used to enumerate the categories returned by the custom function, which are included in the template output, compile and execute the proj.

### Disabling Function Result Encoding

The result produced by functions are encoded for safe inclusion in an HTML document, which can present a problem for functions that generate HTML, Js, CSS fragments -- like:

`categories = append(categories, "<b>p.Category</b>")`

And like: `<h1>... b&gt;p.Category...` This is just a good practice -- cuz it causes problem when functions are used to generate content that should be inclued in the template wihout encoding. the `html/template`package defines a set of `string`type aliases that are used to denote that the result from a function requires special handling like:

`HTML`-- This type just denotes a fragment of HTML just change to:

`func GetCategories(products []Product) (categories []template.HTML) {`

#### Providing Access to STDLIB Functions

Template functions can also be used to provide access to features provided by the stdlib like:

```go
allTemplates.Funcs(map[string]any{
    "getCats": GetCategories,
    "lower": strings.ToLower,
})
```

The new mapping just provides access to the `ToLower`, which transforms strings to lowervcase just like then:

```html
<h1>Category: {{lower .}}</h1>
```

#### Defining Template variables

Actions can define variables in their expressions, which can be accessed within embedded template content like:

```html
{{define "mainTemplate" -}}
    {{$length := len .}}
    <h1>There are {{$length}} products in the source data.</h1>
    {{range getCats . -}}
        <h1>Category: {{lower .}}</h1>
    {{end}}
{{- end}}
```

So the template variable names are prefixed wtih the `$`character and are created wtih the short variable declaration syntax. The first action creates a variable named `length`, which is used in