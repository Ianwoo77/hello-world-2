# State SAT Scores

Setting the index can make it just easier to create queries about our data. But sometimes our data is hierarchical in nature - that is where the pandas concept of a multi-index comes into play. With a multi-index, can set the index not just to a single column but rather to multiple columns -- Imagine -- fore, a data frame containing sales data, may want sales broken down by year and then further broken doen by region.

Fore, look at a summary of scores from the SAT -- standardized university test -- 

```python
df = pd.read_csv(
    "sat-scores.csv",
    usecols=["Year", "State.Code", "Total.Math", "Total.Test-takers", "Total.Verbal"],
)
df = df.set_index(['Year', 'State.Code'])
```

Remember that the `read_csv`also has an `index_col`parameter -- if pass an argument to that parameter, can tell `read_csv`to do it all in one step -- reading in the data fram and setting the index as the column we request. can just pass a list of column s the argument to the `index_col`-- thus, creating the multi-index as the data frame is collected.

`df = pd.read_csv(‘...’, usecols=[...], index_col=[‘Year’, ‘State.Code’])`

Fore, first, we want to know how many people took the `SAT`in 2005, this means that finding all rows from 2005 and the column `Total.Test-takes`-- which tells us how many people took the test in each year -- like:

```python
# how many people take the test in each year like:
df.loc[2005, 'Total.Test-takers'].sum()
# determine the man math score for students in 4 states like: 2010, NY, NJ, MA IL
# retrieving from a multi-index need to put the parts together inside a tuple like:
df.loc[(2010, ['NY', 'NJ', 'MA', 'IL'],), 'Total.Math'].mean()
```

So, this query retreives rows with a year of 2010 coming from of those 4 states. We only get the `Total.Math`column, on which we then calculate the `mean()`.

Then the next question asks for similar calcuation but on several years and several states. like:

```python
df.loc[(slice(2012,2016), ['AZ', 'CA', 'TX']), 'Total.Math'].mean()
```

Can then explore -- 

```python
# what were the average math and verbal scores for ..
df.loc[(slice(None), ['FL', 'IN', 'ID']), ['Total.Math', 'Total.Verbal']].mean()

# Which state recevied the highest verbal score and in which year
f.loc[df['Total.Verbal'] == df['Total.Verbal'].max()]

#was the average math score in 2015 higher or lower tha that in 2015
df.loc[2005, 'Total.Math'].mean() - df.loc[2015, 'Total.Math'].mean()
```

#### Sorting by Index

When talk about sorting in pandas, usually referencing to sorting the data -- Fore, may want the rows in our data frame sorted by price or regional sales code -- But Pandas also lets Us sort data frames based on the index. Can do that with the `sort_index()`method. like: `df= df.sort_index()`-- And if your data frame contains a multi-index, the sorting will be done primaliy along the first level, then along the second and so forth.

In addition to having some aesthetic benefits, sorting a data frame by index can make certain tasks easiler or possible.

Olympic games -- In the prievous -- initially looked and using a multi-index. A multi-index doesn’t have to stop ast just two levels, pandas will in theory, allow us to set as many as we want.

## Strings

In Go, a string is an immutable data structure holding the following -- 

- A pointer to an immutable byte sequence
- Tht total number of bytes in this sequence

Will see in this that Go has a pretty unique way to deal with strings. Go just introduces a concept called *runes*. Essential to understand and may confuse new -- once understand, can avoid common mistakes while iterating on a string -- will also look at common mistakes made by Go developers while using or producing strings. Will see also that sometimes can wok directly with `[]byte`-- avoiding extra allocations. Will discuss how to avoid a common mistake that can create leaks from substrings.

### Understanding the concept of a `rune`

This concept is key to understand how strings are handled and avoiding common mistakes. Should understand the distinction between a charset and and an encoding -- like:

- A charset -- is a set of characters -- 
- An encoding is the translation of a character’s list in binary. FORE `UTF-8`is an encoding std capable of encoding all the Unicode in a varible number of bytes. from 1 to 4 bytes

Mentioned characters to simplify the char set to simplify the charset definition -- But in Unicode, we use the concept of a *code point* to refer to an item represented by a single value -- a `rune`is just Unicode code point.

Meanwhile, mentioned that `UTF-8`encodes characters into 1 to 4 bytes -- up to just 32 bits -- this is why in Go, a `rune`is an alias of `int32`. `type rune = int32`. fore `s:="hello"`-- assign a string literal to `s` -- in Go, a source code is endoced in `u8`-- all string literals are encoded into a sequence of bytes using `UTF-8`.

NOTE in `golang.org/x`-- repository that provides extensions to the stdlib -- contains package wo work with u16 and u32.

### Accurate string iterition

Iterating on a string -- want to just perform an operation for each rune in the string or implement a custom function to search for a specific substring -- have to iterate on the different runes of a string.

```go
func main() {
	s := "hêllo"
	for i := range s {
		fmt.Printf("Position %d: %c\n", i, s[i])
	}
	fmt.Printf("len=%d\n", len(s))
}
```

Cuz just assigned a string literal to s. For this example, printing `s[i]`doesn’t print the `ith`rune. have to use the value element of the `range`operator just like:

```go
func main() {
	s := "hêllo"
	for i, r := range s {
		fmt.Printf("Position %d: %c\n", i, r) // still %c used
	}
	fmt.Printf("len=%d\n", len([]rune(s)))
}
```

### Using `trim`functions

One common mistake mad by Go developers when using the `strings`package is to mix `TrimRight`and `TrimSuffix`-- for this, both serve a similar purpose, and can be farily easy to confuse them. fore:

`fmt.Println(strings.TrimRight("123oxo", "xo"))` // 123 output, if not using `TrimSuffix()`.

`TrimRight`removes **all** the trailing runes contained in a given set. We passed as a set `xo`- which contains two runes, So, `TrimRight`iterates backward over each rune - if a rune is part of provided set, the func removes it, the func stops its iteation and returns the remaining string. So:

`fmt.Println(strings.TrimSuffix(“123oxo”, “xo”))`-- just returns 123o.

Note that the same principle -- `TrimLeft`and `TrimPrefix`functions.

### Optimized string concatenation

When comes to concatenating strings, there are two main approaches -- like:

```go
func concat(values []string) string{
    s := ""
    for _, value := range values{
        s+=value
    }
    return s
}
```

Here, each iteration doesn’t update `s`-- just re-allocates a new string in memory, which is significantly impacts the performance of this function. so just using the `strings.Builder`struct like:

```go
func concat(valus[] string) string {
    sb := strings.Builder{}
    for _, value := range values {
        _, _ = sb.WriteString(value) // append a string
    }
    return sb.String()
}
```

For this, creates a `strings.Builder`using its zero value, during each, constructed the reulsting string by alling the `WriteString()`that appensds the content of `value`to internal buffer. Builder implements the `io.StringWriter`interface, which contains a single method -- `WriteString(s string) (n int err error)`

Note that using `strings.Builder`can also append -- 

- A byte slice using `Write`
- A single byte using `WriteByte`
- A singe rune using `WriteRune()`

Note that internally, `strings.Builder`just holds a byte slice. Each call to `WriteString()`results in a call to `append`on this slice. There are two impacts -- 

1. This struct shouldn’t be used concurrently
2. Inefficient slice initialization

```go
func concat(values []string) string {
	total := 0
	for i := 0; i < len(values); i++ {
		total += len(values[i])
	}
	sb := strings.Builder{}
	sb.Grow(total) // calls Grow() with this total
	for _, value := range values {
		_, _ = sb.WriteString(value)
	}
	return sb.String()
}
```

For this, before the iteration, compute the total number of bytes the final string will contain and assign the result to `total`-- Now that we are not interested in the number of runes but the number of bytes, so use the `len`.

So, `strings.Builder`is the recommended solution to concatenate a list of strings. As a general rule, can remember that performance-wise, the `strings.Builder`solution is faster from the moment we have to concatenate more tha about 5 strings.

### string conversions

When choosing to work with a string or a `[]byte`-- most tend to favor strings for convenience -- but, most I/O is actually done with `[]byte`-- fore, `io.Reader, io.Writer, io.ReadAll`work with `[]byte`, not strings. Hence, working with strings means extra conversions, although the `bytes`package contains many of the same operations as the `string`package.

See an example of what *shouldn’t* do -- will implement a `getBytes()`functin that takes an `io.Reader`as an input, reads from it and calls a `sanitize`-- will be done by trimming all the leading and trailing white space like:

```go
func getBytes(reader io.Reader) ([]byte, error){
	b, err := io.ReadAll(reader) // b is just []byte
	if err != nil {
		return nil, err
	}
	// Call santize
}
```

When call `ReadAll()`and assign the byte slice to `b`-- So, how can implement the `sanitize`fore:

```go
func sanitize(s string) string {
    return string.TrimSpace(s)
}
```

Then back to -- Then have to convert the results back into a `[]byte`cuz `getByte()`returns a byte slice. Just:

`return []byte(sanitize(string(b))), nil`

For this -- have to pay the extra price of converting a `[]byte`into a string and then converting a string into a `[]byte`. Memory-wise, each of these conversions requires an extra allcoation. just:

```go
func sanitize(b []byte) []byte {
    return bytes.TrimSpace(b)
}
```

So, the `bytes`package also has a `TrimSpace`function to just trim all the leading and trailing whitespace. just:
`return sanitize(b), nil`-- most I/O is done with `[]byte`not strings.

### Substrings and memory leaks

Saw how slicing a slice or array may lead to memory leak situations -- also applies to string and substring operations.

```go
s1 := "Hello, World!"
s2 := s1[:5]
```

`s2`is just constructed as a substring of `s1`-- this just creates a string from the first five, not the first runes. for:

```go
s1 := "Hêllo, World!"
s2 := string([]rune(s1)[:5]) // cuz should not use s1[:5] directly cuz multiple bytes
```

UUID -36characters Want to store these UUID in memory -- to keep cache of the latest n uuids like:

```go
func (s store) handlelog(log string) error {
    if len(lo) < 36 {
        return errors.New("...")
    }   
    uuid := log[:36]
    s.Store(uuid)
}
```

Note, when doing a substring op, the *Go specification doesn’t specify* whether the resulting string and one involved in the substring op should share the same data. But the std Go compiler **does** let them share the same backing array.

Mentioned that log messages can be quite heavy -- `log[:36]`will create anew string referening the same backing array -- therefore, each `uuid`string that we store in memory will contain not just 36 bytes but the number of bytes in the initial `log`string. So, by making a **deep** copy of the substring like:

```go
func (s store) handleLog(log string) error {
    if len(log) < 36{
        return errors.New("...")
    }
    uuid := string([]byte(log[:36])) // performs a []byte and then a string conversion
    s.store(uuid)
}
```

Note that the copy is performed by converting the substring into a `[]byte`first and then into a string again. By doing this, we prevent a memory leak from occurring. The `uuid`string is backed by an array consisting 36 bytes now. And also note some IDEs -- warn that redundant type conversion -- but for this situation, this operation has an actual effect. As of Go 18, the stdlib just includes with a `strings.Clone()`-- just like:

`uuid := strings.Clone(log[:36])` // aslo preventing a memory leak

## Caching Templates

It’s a good time to make some optimizations to codebase -- there are two main issues -- 

1. Each time render a page, app reads and parses the relevant template files using the `template.ParseFiles()`, could avoid this duplicated work by parsing the files once
2. There is duplicated code in the `home`and `showSnippet`handlers.

Takle the first -- create an in-memory map with the type `map[string]*template.Tempalte`to cache the parsed templates. like:

```go
func newTemplateCache(dir string) (map[string]*template.Template, error) {
    cache := map[string]*template.Template{}
    pages, err := filepath.Glob(filepath.Join(dir, "*.page.html"))
    if err != nil {
        return nil, err
    }
    
    // loop through the page one-by-one
    for _, page := range pages {
        name := filepath.Base(page) // extract the file name 
        ts, err := template.ParseFiles(page)
        if err != nil {
            return nil, err
        }
        
        // use `ParseGlob` to add
        ts, err = ts.ParseGlob(filepath.Join(dir, "*.layout.html"))
        if err != nil {
            return nil, err
        }
        
        ts, err = ts.ParseGlob(filepath.Join(dir, "*.partial.html"))
        if err != nil {
            return nil, err
        }
        
        cache[name]=ts
    }
    return cache, nil // returh the map
}
```

The next step is to initialie this cache in the `main()`and make it available to our handlers as a dependency like:

```go
type application struct {
    errorLog      *log.Logger
    infoLog       *log.Logger
    snippets      *mysql.SnippetModel
    templateCache map[string]*template.Template  // add this field
}

//... in the main()
templateCache, err := newTemplateCache("./ui/html/")
app := &application{
    errorLog, infoLog, &mysql.SnippetModel{db,},
    templateCache,
}
```

So, at this point, got an in-memory cache of the revelant template set for each of our pages. And our handlers have access to this cache just via the `application`struct.

Then tackle the second issue of duplicated code, and create a helper method so that can easily render the templates from the cache -- like:

```go
func (app *application) render(w http.ResponseWriter, r *http.Request,
	name string, td *templateData) {
	// retrieve the appropriate template set from the cached based on page name
	// if no entry exists in the cache with the provided name, call serveError()
	ts, ok := app.templateCache[name]
	if !ok {
		app.serverError(w, fmt.Errorf("the template %s does not exist", name))
		return
	}

	// execute the template set, passing in any dynamic data
	err := ts.Execute(w, td)
	if err != nil {
		app.serverError(w, err)
	}
}
```

at this complete, now get to see pay-off from these changes and can dramatically simplify the code.
`app.render(w, r, "home.page.html", &templateData{Snippets: s})`
`app.render(w, r, "show.page.html", &templateData{Snippet:s})`

### Catching Runtime Errors

As soon as we begin adding dynamic behavior to HTML templates there is a risk of encounting runtime eorros. Just add some delibrerate error `{{len nil}}`

This is bad -- our application has thrown an error, but the user has wrongly been sent a 200. To fix this need to make the template render a two-stage process -- should make a *trial* render by writing the template into a buffer. if fails, can respond to teh user with an error message. But if works, can then write the contents to the buffer to `http.ResponseWriter`.

```go
// Initialize a new buffer
buf := new(bytes.Buffer)

// write the template to the buffer, instead of straight to the
// http.ResponseWriter.
err := ts.Execute(buf, td)
if err != nil {
    app.serverError(w, err)
    return
}

// ok, writes the contents of the buffer to the ResponseWriter
buf.WriteTo(w)
```

### Common Dynamic Data

In some web apps there may be common dynamic data that you want to include on more than one -- On every -- might want to include the name and profile picture of the current user, or a `CSRF`token in all pages wtih forms.

```go
type templateData struct {
	CurrentYear int
	Snippet     *models.Snippet
	Snippets    []*models.Snippet
}
```

Then the next step is to create a new just `addDefaultData()`helper method to our app, which will inject the current year into an instance of a `templateData`struct.
`err := ts.Execute(buf, app.addDefaultData(td, r))`

```go
// Create a helper addDefaultData -- this takes a pointer to a templateData
// adds current year
func (app *application) addDefaultData(td *templateData, r *http.Request) *templateData {
	if td == nil {
		td = &templateData{}
	}
	td.CurrentYear = time.Now().Year()
	return td
}
```

### Custom template Functions

In the last part of this section about templating and dynamic data, Like to explain how to create your own custom functions to use in Go templates -- create a custom `humanDaet()`function which just outputs datetimes in a nice `humanized`format like instead of outputting dates in the default format like we are currently.

There are two main steps to doing this -- 

1. need to create a `template.FuncMap`object containing the custom `humanDate()`function.
2. Need to use the `template.Funcs()`method to just register this before parsing the templates.

In the `templates.go`file -- 

```go
// humanDate returns nicely formatted string representation
func humanDate(t time.Time) string {
    return t.Format("02 Jan 2006 at 15:04")
}

// initialize the template.FuncMap object and store it in a global variable
var functions = template.FuncMap{
    "humanDate": humanDate,
}

// .. 
// The template.FuncMap() must be registered with the template set before you
// call the `ParseFiles()` -- need to use the `template.New()` to create an 
// empty template set
ts, err := template.New(name).Funcs(functions).ParseFiles(page)
if err != nil {
    return nil, err
}
```

Custom template functions like `humanDate()`can just accepts *as many as parameters* as they need to, but *must* return one vlaue only.
`<td>{{humanDate .Created}}</td>`

```html
<div class="metadata">
    <time>Created: {{humanDate .Created}}</time>
    <time>Expires: {{humanDate .Expires}}</time>
</div>
```

#### Pipelining -- 

An alternative approach is to use the `|`character to *pipeline* values to a function -- this works a bit like pipelining outputs from one command to anthoer in Unix. like:

`<time>Created: {{.Created | humanDate}}</time>`

And a nice feature of pipelining is that you can make an arbitrarily long chain of template func like:

`<time>{{.created | humanDate | printf “created: %s”}}</time>`

