# Importing and Exporting data

`df.corr`-- shows the correlations among the columns.
`df.read_html()`-- return a list of data frames basd on HTML input
`s.value_counts()`-- returns a *sorted* series counting how many times each value appears in s
`s.round`-- returns a new series based on `s`in which the values are rounded to the specified number of decimals

Rather than take a stand on how CSV files should be formatted, pandas tries to be open and flexible. When read from a CSV or write a data frame to CSV, can choose from many, many parameters, each of which can affect how it is written, among the most common are these -- 

- `sep`-- Field separator, `\t`
- `header`-- whether there are headers describing column names and on which line of the file they appear
- `index_col`-- which column, if any should be set to the index of our data frame
- `usecols`-- which columns from the file should be included in the data frame.

```python
pd.read_csv('mydata.csv', sep='\t', index_col='w', usecols=[*'wxz'], header=0)
```

In this, the `header=0`just indicates that the file’s first line contains the column names.

### Working it out -- 

To solve this problem, first need to create a new data frame from the CSV file. Fortuntely, the data is formatted in such a way that `pd.read_csv`works fine with its defaults, returning a data frame wtih named columns. But this file contains a lot of data. The `use_cols`parameter to the `pd.read_csv`allows to select which columns form the CSV file will be kept around.

```python
df = pd.read_csv('../data/nyc_taxi_2019-01.csv',
                usecols=['passenger_count', 'trip_distance',
                        'total_amount', 'payment_type'])
df.loc[df['passenger_count']>8, 'passenger_count'].count()
df.loc[df['passenger_count']==0, 'passenger_count'].count()
df.loc[(df['payment_type']==2) & (df['total_amount']>1000), 
       'passenger_count'].count()
```

#### Pandemic taxis -- 

Want to create a data frame from two different CSV files containing New York taxi data -- The data frame should contain 3 columns from the files.

## `any`says nothing

In Go, an interface type that specifies zero methods is known as the empty interface -- `interface{}`-- In go 1.18, the predeclared type `any`became an alias for an emtpy interface -- hence, all the `interface{}`occurrences can be replaced by any -- in many cases, `any`can be considered an overgeneralization. And:

```go
func main(){
    var i any
    i = 42
    i = "foo"
    i = struct {s string} {s: "bar"}
    i = f
    _= i
}
```

Note that in assigning a value to an any type, lose all info, which requires a type assertion to get anything useful out of the `i`variable -- as in the previous example -- where using `any`isn’t accurate -- in the following, implement a `Store`struct and the skeleton of two methods fore, `Get`and `Set`use these methods to store the different struct types.

```go
package store

type Customer struct {}
type Contract struct {}
type Store struct {}
func (s *Store) Get(id string) (any, error) {}
func (s *Store) Set(id string, v any) error {}
```

Note, although there is nothing wrong wiht the `Store`compilation -- should take a minute to think about signatures -- Cuz -- accept and return `any`arguments, the methods lack expressiveness -- Hence, accepting or returning an `any`type doesn’t convey meaningful information. like:

```ts
s := store.Store{}
s.Set("foo", 42)
```

So, by using `any`lose some of the benefits of Go as a statically typed language -- instead should avoid `any`types and make our signagures explicit as much as possible. Regarding our example, this could mean duplicating the `Get`and `Set`method per type.

```go
func (s *Store) GetContract(id string) (Contract error) {}
func (s *Store) SetContract(id string, contract Contract) error {}
//...
```

In this version, the methods are expressive, reducing the risk of incomprehension. Having more methods isn’t necessaryliy a problem cuz clients can also create their own abstraction using an interface.

```go
type ContractStorer interface {
    GetContract(id string) (store.Contract, error)
    SetContract(id string, contract store.Contract) error
}
```

And, what are the cases when `any`is helpful -- take a look at the stdlib and see two example where functions or methods accept `any`arg -- The first is in the `encoding/json`-- cuz can marshal any type, the `Marshal`accepts an `any`argument like:

```go
func Marshal(v any) ([]byte, error) {}
```

And, another is the `dtabase/sql`package -- namely, if the query is parameterized, the parameters could be any kind -- hence it also uses `any`arguments like:

```go
func (c *Conn) QueryContext(ctx context.Context, query string, args ...any) (*Rows, error){}
```

In Summary, `any`can be helpful if there is a genuine need for accepting or returning any **possible** type -- in general, we should avoid over-generalizing the code we write at all costs.

### Being Confused about when to use generics

Go 1.18 adds generics to the language, in a nutshell, this allows writing code with types that can be sepcified later and instantiated when needed, However, it can be confusing about when to use generics and when not to.

#### Concepts 

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k := range m {
        keys=append(keys, k)
    }
    return keys
}
```

`map[int]string`fore -- and before generics, Go developers has a few options, using code functions, one for each map type, or try to extend `getKeys()`to accept different map types like:

```go
func getKeys(m any) ([]any, error) {
    switch t:= m.(type) {
    default:
        return nil, fmt.Errorf("Unknown type: %T", t)
    case map[string]int:
        //...
    case map[int]string:
        //...
    }
}
```

but, first, it increases boilerplate code -- want to add a case it requires duplicting the `range`loop. Meanwhile, the function now accepts an `any`type, which means lose some of the benefits of Go as a typed language. Indeed, checking whether a type is suported is done at run time instead of compile time. Hence, also need to return an error if the prodvided type is unknown -- finally cuz the key type can be either `int`or `string`.

The type parameters are generic types that we can use with functions and types -- fore, the following like:

```go
func foo[T any](t T) {//...
}
```

For this, calling `foo`, pass a type argument of `any`type -- supplying a type argument is called `instantiation`. like:

```go
func getKeys[K comparable, V any](m map[K]V) []K {
	var keys []K
	for k := range m {
		keys= append(keys, k)
	}
	return keys
}
```

To handle the map, define two kinds of type parameters, first the values can be of the `any`type `V`, in Go, the map keys can’t be of the `any`type -- cannot use slices -- `var m map[[]byte]int`

This code leads to a complication error -- invalid `map`key type `[]byte`-- therefore, instead of accepting any key type, care obliged to *restrict* type arguments so that the key type meets sepcific requirements -- Here the requirement is that the key type must be comparable -- hence, we defined `K`as `comparable`instead of `any`. Restricting type arguments to match specific requirements is called a *constraint* -- A constraint is an interface type can contain.

- A set of behavior
- Arbitrary types

Check out a concrete example for the latter -- don’t want to accept any `comparable`type for the `map`key type, fore, want to restrict it to eigher `int`or `string `types -- can define a custom constraint this way -- like:

```go
type customConstraint interface {
    ~int | ~string
}

func getKey[K customConstraint, V any](m map[K]V) []K {
    // same IMP
}
```

For this, defined a `customConstraint`interface to just restrict the types to be either `int`or `string`suing the union operator `|`-- K is now a `customContraint`instead of a `comparable`as before.

`keys := getKeys[string](m)`

#### ~int vs. int

Whereas `~int`restricts all the types whose **underlying** type is an `int`. To illustrate -- imagine a constraint where we would like to restrict a type to any `int`type IMP the `String()`string method.

```go
type customConstraint interface {
    ~int
    String() string
}

type customInt int
func (i customInt) String() string {
    return strconv.Itoa(int(i))
}
```

For this, the `customInt`is just an `int`and just implements the `String()`method -- the `customInt`types just satisfies the defined constraint. If just change the constraint to contain an `int`instead of an `~int`-- using `customInt`leads to a compliation error cuz `int`type doesn’t implement `String()`string.

#### Common uses and misuses

When are generics useful -- 

- *Data Structure* -- can use generics to factor out the element type if we implement a binary tree...

- *Function working with slices, maps, and channels of any type* -- A function to merge two channels would work with any channel type, fore, we could use type parameters to factor out the channel type. like:

  ```go
  func merge[T any] (ch1, ch2 <-chan T) <-chan T {...}
  ```

- Factoring out behaviors instead of types - the `sort`package, fore, contains a `sort.Interface`with three like:

  ```go
  type Interface interface {
      Less() int
      Less(i, j int) bool
      Swap(i, j int)
  }
  ```

  Using type parameters, could factor out the sorting behavior lke:

  ```go
  func getKeys[K comparable, V any](m map[K]V) []K {
  	var keys []K
  	for k := range m {
  		keys = append(keys, k)
  	}
  	return keys
  }
  
  type SliceFn[T any] struct {
  	S       []T
  	Compare func(T, T) bool
  }
  
  func (s SliceFn[T]) Len() int {
  	return len(s.S)
  }
  
  func (s SliceFn[T]) Less(i, j int) bool {
  	return s.Compare(s.S[i], s.S[j])
  }
  
  func (s SliceFn[T]) Swap(i, j int) {
  	s.S[i], s.S[j] = s.S[j], s.S[i]
  }
  
  func main() {
  	s := SliceFn[string]{
  		[]string{"1", "2", "1"},
  		func(a, b string) bool {
  			return a < b
  		},
  	}
  	sort.Sort(s)
  	fmt.Println(s.S)
  }
  ```

Conversely, when is it recommended that not use generics -- 

- When calling a method of the type argument -- consider a func that receives an `io.Writer`and calls the `Writer`method fore:

  ```go
  // using generics won't bring any value to code
  func bool[T io.Writer](w T) {
      //...
  }
  ```

- When it makes our code more cplex -- Generics are never mandatory, and as go developers, have lived wihtout them for more than a decade.

## Template Composition

As we add more pages to this app there will be some shared, boilerplate, HTML markup that we want to include on every page -- like the reader, navigation and metadata inside the `<head>`HTML element.

To save typing and prevent duplication, it’s good idea to create a *layout* templte which contains this shared content, then compose with the page-specific markup for the individual pages.

```html
{{define "base"}}
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>{{template "title" .}} - Snippetbox</title>
    </head>
    <body>
    <header>
        <h1><a href="/">Snippetbox</a></h1>
    </header>
    <nav>
        <a href="/">Home</a>
    </nav>
    <main>
        {{template "main" .}}
    </main>
    </body>
    </html>
{{end}}
```

Here we are using the `{{define "base"}}... {{end}}`action to define a distinct named tempalte called `base`, which contains the content we want to appear on every page. And inside this use the `{{template "title" .}}`and `{{template "main" .}}`action to denote that we want to invoke other named templates.

```html
{{template "base" .}}

{{define "title"}}Home {{end}}

{{define "main"}}
    <h2>Latest Snippets</h2>
    <p>There is nothing to see yet!</p>
{{end}}
```

Right at the top of this file is arguably the most important part -- the `{{template "base" .}}`action. This informs Go that when the `home.page.tmpl`file is executed, that we want to *invoke* the named template `base`. In turn, the `base`template contains instructions to invoke the `title`and `main`named templates.

```go
files := []string{
    "./ui/html/home.page.html",
    "./ui/html/base.layout.html",
}

// use the template.ParseFiles() to read template file
ts, err := template.ParseFiles(files...)
if err != nil {
    log.Println(err.Error())
    http.Error(w, "Internal Server Error", 500)
    return
}
```

### Embedding Partials -- 

For some applications you might want to break out certain bits of HTML into partials that can be used in different pages or layouts -- to illustrate, create a partial containing some footer content for our web application.

```html
{{define "footer"}}
    <footer>Powered by <a href="https://golang.org">Go</a></footer>
{{end}}
```

Then update the `base`template so that it will invoke the footer using the `{{template "footer" .}}`action.

### Additional Information

The `Block`action -- in the code above used the `{{tempalte}}`action to invoke one template from another, but Go also provdies a `{{block}}...{{end}}`action which can use instead. This acts like the `{{template}}`action, except it allows U to specify some default content if the template being invoked *doesn’t exist in the current template set*.

In the context of a web application, this is useful when you want to provide some default content which individual pages can overriden a case-by-case basis if they need to. like:

```html
{{define "base"}}
<h1>
    An example template
</h1>
{{block "sidebar" .}}
<p>
    My default sidebar content
</p>
{{end}}
```

If U ant -- don’t need to include any default content between the `{{block}}`and `{{end}}`actions. in that case, The invoked template acts like it’s optional.

### Serving Static Files

Improve the look and feel of the home page by adding some static CSS and image files to our proj -- along with a tiny bit of Js to highlight tha active navigation item -- like:

#### The `http.FileServer`handler -- 

Go’s `net/http`package ships with a built-in `http.FileServer`handler which you can use to serve files over HTTP from a specific directory -- like-- add a new route to our app so that all requests which begin with `/static/`are handled using this like: -- ANY- `/static/`using `http.FileServer`-- Serve a specific static file. 

 To create a new `http.FileServer`handler, need to sue the `http.FileServer()`function like this:

`fileServer := http.FileServer(http.Dir("./ui/static/"))`

When this handler receives a request, it will remove the leading slash from the URL path and then search the `./ui/static`directory.