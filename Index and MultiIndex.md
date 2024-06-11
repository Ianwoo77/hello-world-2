# Index and MultiIndex

This returns all the rows in the data frame that have blue or red car like:

```python
(
	df.loc[['BLUE', 'RED'], 'Vehicle Make']
    .value_counts()
    .head(1)
)
```

### Working with multiple-indexes

Every data frame has an index, giving labels to the rows, have already seen that can use the `loc`accessor to retrieve one or more rows using the index. fore, `df.loc['a']`to retrieve all the rows with the index value `a`-- the index doesn’t necessarily contain unique values.

The workd is full of hierarhcical information -- or information that is easier to process if make it hierarchical. Fore, create some random sales data for 3 products like:

```python
g = np.random.default_range(0)
df = pd.DataFrame(g.integers(0, 100, [36,3]), columns=[*'ABC'])
df['year']=[2018]*12+[2019]*12+[2020]*12
df['month']='''Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'''.split()*3
```

could set the index, based on the `year`like: `df.set_index('year')`, but that wouldn’t give us any special access t the month data -- which would like to hav part of our index, could create a multi-index by pasing a list of columns to to `set_index()`like: `df= df.set_index(['year', 'month'])`, just remember that when creating a multi-index, want the most general part to be on the outside and thus be mentioned first, if create a multi-index with dates, like that.

With this in place, can retrieve one or mre parts of the data frame in a variety of different ways -- fore, can get the sales data for all products in like: `df.loc[2018]`, can get all sales data for just products A and C fore:
`df.loc[2018, ['A', 'C']]`

For this, have a multi-index on this data frame, which means we can break the data down ont just by year can also by month -- fore, like `df.loc[(2018, 'Jun')]`-- using tuple -- Tuples are typically used in a multi-index situation when want to specify a specific combination of index levels and values. like:

`df.loc[(2018, 'Jun'), ['A', 'C']]`

And what if we want to see more than one year at a time fore can:

`df.loc[[2018, 2020]]`

And if want all data for like: `df.loc[[2018, 2020], ['B', 'C']]`

What if want to get all the data from June 2018 and June 2020 -- like:
`df.loc[[(2018, 'Jun'), (2020, 'Jun')], ['A', 'C']]`

What if want to look at all values from Jun, Jul or Aug across 3 years -- that using the Slice() like:
`df.loc[([2018, 2019, 2020], ['Jun', 'Jul', 'Aug']), :]`

For all columns using a colon by itself -- like:
`df.loc[([2018,2019,2020], ['Jun', 'Jul', 'Aug']), :]`

Assuming the index is sorted, can select year using a slice -- 

```python
# doesn't work
df.loc[(:, ['Jun', 'Jul', 'Aug']), ['A', 'B']]
df.loc[(slice(None), ['Jun', 'Jul', 'Aug']), ['A', 'B']] # right
```

Cuz Python only allows the `:`within the `[]`-- tried to use the colon within a tuple -- which uses reuglar, .. Can use the built-in `slice`function with just `None`as an Argument for the same result. Can just think of `slice(None)`as a way of indicating to pandas that you are willing to have all values as a wildcard.

## About map Iterations

Iterating over a map is a common source of mis-understanding and mistakes, mostly cuz developers amke wrong *assumpitons* in this discuss two different cases -- 

- Ordering
- Map update during an iteration

#### Ordering

Regarding ordering, need to understanding a few fundamental behaviors of the map data structure -- 

- Doesn’t keep the data sorted by key
- It *doesn’t preserve the order* in which the data was added.

Furthermore, when iterating over a map, shouldn’t make any ordering assumptions at all fore:

```go
for k := range m {
    fmt.Print(k)
}
```

In Go, the iteration order over a map is not specified -- there is also no guranteee that the order will be the same from one iteration to the next. For the Go developers -- wanted to ad some form of randomness to make sure developers never rely on any ordering assumptions while working with maps. 

When the `encoding/json`package marshals a map into JSON, reorders the data alphabetically by keys -- regarding of the inserttion order.

#### Map insert during iteration

In Go, updating a map during an iteration is allowed, it doesn’t lead to a complication error or a run-time error, however, there is another aspect we should consider when adding an entry in a map during an iteration -- like:

```go
func main() {
	m := map[int]bool{
		0: true,
		1: false,
		2: true,
	}

	for k, v := range m {
		if v {
			m[10+k] = true
		}
	}
	fmt.Println(m)
}
```

If a *map* entry is created during iteration, it may be produced during the iteration or skipped -- the choice may just vary for each entry created and from one iteration to the next. Hence, when an element is added to a map during an itration, it may be produced during a follow-up iteration -- or it may not.

So, it’s essential to keep this in mind to ensure that our code doesn’t produce unpredictable outputs -- if want to update a map while iterating over it and make sure the added entires aren’t part of the iteration, just make a copy. like:

```go
m2 := copyMap(m)
for k,v := range m {
    m2[k]=v
    if v {
        m2[10+k]= true
    }
}
```

### How `break`works

a `break`is commonly used to terminate the execution of a loop take a look at:

```go
for i:=0; i<5; i++ {
    fmt.Printf("%d", i)
    switch i {
    default:
    case 2:
        break
    }
}
```

For this, it doesn’t do what we expect -- the `break`just doesn’t terminate the `for`-- just terminate the `switch`statement instead. So, one essential rule to keep in mind is that a `break`statement terminates the execution of the inner-most `for switch select`statements. just like:

```go
loop:
for i:=0; i<5; i++ {
    fmt.Printf("%d", i)
    switch i {
    default:
    case 2:
        break loop
    }
}
```

### Don’t using `defer`inside a loop

The `defer`statement delays a call’s execution until the sorrounding function returns. It’s mainly used to reduce boilerplate code -- fore, if a resource has to be closed eventually, can use the `defer`to avoid repeating the clousre calls before every singe `return`. However, one common mistake is to be unware of the consequences of using `defer`inside the loop -- like -- IMP func that opens a set of files where the file paths are received via a channel. Hence, have to iterate over this channel, open the files, and handle the closure like:

```go
func readFile(ch <-chan string) error {
    for path := range ch {
        file, err := os.Open(path)
        if err != nil {
            return err
        }
        
        defer file.Close() // in the loop
    }
    return nil
}
```

For this, there is a significant problem with this implementation -- we have to recall that `defer`scheudles a function call when the *sorrounding function returns* -- so, the `defer`calls are executed not during each loop iteration but when the `readFiles`returns. In this case, the `defer`calls are executed not during each loop iteration but when the `readFiles`function returns -- if `readFiles`doesn’t return the file descriptors will be kept open forever, causing leaks.

One might just get rid of `defer`and handle the closure manually, for this problem, have to just create another sorrounding function aroudn the `defer`that is called during each iteration.

Fore, can implement a `readFile`func holding the logic just for each new file path received -- like:

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        if err := readFile(path); err != nil {
            return err
        }
    }
    return nil
}

func readFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()
    // do sth
    return nil
}
```

In this IMP, the `defer`func is called when `readFile`returns -- meaning at the end of each iteartion. Another:

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        err := func() error {
            //...
            defer file.Close()
        }()
        if err != nil {
            return err
        }
    }
    return nil
}
```

## Displaying Dynamic Data

Currently our `showSnippet()`handler fetches a `models.Snippet`object from the dbs and then dumps the contents out in a plain-text HTTP response. Update this so that the data is displayed in a proper HTML webPage.

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id < -1 {
        app.notFound(w)
        return
    }
    s, err := app.snippets.Get(id)
    if err != nil {
        if errors.Is(err, models.ErrNoRecord) {
            app.notFound(w)
        }else {
            app.serveError(w, err)
        }
        return
    }
    
    // Initialize a slice containing the paths to the show.page.html file
    files := []string {
        "./ui/html/show.page.html",
        "./ui/html/base.layout.html",
        "./ui/html/footer.partial.html",
    }
    
    // parset the template
    ts, err := template.ParseFiles(files...)
    if err != nil {
        app.serveError(w, err)
        return
    }
    
    // and then execute them
    err = ts.Execute(w, s)
    if err != nil {
        app.serveError(w, err)
    }
}
```

Next up need to create the `show.page.html`file containing the HTML markup for the page. Within your HTML templates, any dynamic data that you pass in is represented by the `.`character-- the underlying type of dot will be a `models.Snippet`struct. When the underlying type of dot is a struct, can render or *yield* the value of any exported field by postfixing dot with the field name. Just like:

```html
{{template "base" .}}
{{define "title"}}Snippet # {{.ID}} {{end}}

{{define "main"}}
    <div class="snippet">
        <div class="metadata">
            <strong>{{.Title}}</strong>
            <span># {{.ID}}</span>
        </div>
        <pre><code>{{.Content}}</code></pre>
        <div class="metadata">
            <time>Created: {{.Created}}</time>
            <time>Expires: {{.Expires}}</time>
        </div>
    </div>
{{end}}
```

#### Rendering multiple Pieces of data

An important thing to explain is that go’s `html/tempalte`package allows u to pas in one and only one item of dynamic data when rendering a template. But in a real-wold there are often multiple pieces of dynamic data that you want to display in the same page -- a lightweight and type-safe way to achieve this is to just wrap your dynamic data in a struct which acts like a single data source -- 

```go
// Define a templateData type to act as the holding structure for
// any dynamic data that we want to pass to our HTML templates
type templateData struct {
	snippet *models.Snippet
}
```

Then just update the `showSnippet`handler to use this new struct when executing our templates like:

```go
// create an instance of a templateData struct holding the data
data := &templateData{snippet: s}
```

For now, the snippet data is contained in a `models.Snippet`: Like:

```html
<div class="metadata">
    <time>Created: {{.Snippet.Created}}</time>
    <time>Expires: {{.Snippet.Expires}}</time>
</div>
```

#### Additional Information

Escaping -- The `html/template`package automatically escapes any data that is yielded between `{{}}`tags -- this behvior is hugely helpful in avoiding XSS attacks. If the dynamic data you want to yield like:

```html
<span>{{"<script>alert('xss attack')</script>"}}</span>
```

Would just rendered harmlessly.

#### Nested Templates

It’s really important to note that when you are invoking one template from another template -- dot needs to be explicitly passed or pipelined to the template being invoked - do this by including it at the end of each template being invoked. like:

```html
{{template "base" .}}
{{block "sidebar" .}}{{end}}
```

And as a rule, is to get into the habbit of always pipelining dot when you invoke a template with the `{{template}}`or `{{block}}`actions.

#### Calling Methods

If the object that you are yielding has methods defined against it, can call them (so long as the are exported and they return only a single value - (or a value and an error)). If `.Snippet.Created`has the underlying type `time.Time`U could render the name of the weekday by calling its `Weekday()`method like:

```html
<span>{{.Snippet.Created.Weekday}}</span>
```

Also, can pass parameters to methods -- could us the `AddDate()` just like:

```html
<span>{{.Snippet.Created.AddDate 0 6 0}}</span>
```

Just note that the parametes *are not* surrounded by () and separated by a single space character, not comma.

#### HTML comments -- 

The `html/template`package always strips out any HTML comments you include in templates. Avoid XSS attacks when rendering dynamic content.

### Template Actions and Functions

In this, going to look at the template actions and functions that Go Prodvides -- There are three more which -- dynamic data -- {{if}}, {{with}} and {{range}}

`{{with .Foo}} C1 {{else}} C2 {{end}}`-- If `.Foo`is not empty, then set dot to the value of `.Foo`and render the content `C1`, otherwise render content C2.

`{{range .Foo}} C1 {{else}} C2 {{end}}` -- if length of `.Foo`is greater then 0 then loop over each element, setting dot to the value of teach element and rendering the content C1. If the length of `.Foo`is zero then render the content of C2. Note that the underlying type of `.Foo`must be an array slice map channel.

- For all three, `{{esle}}`clause is optional
- The *empty* values are `flase 0 nil`pointer or interface, and any array slice map or string of lengh of 0.
- It’s just important to grasp that the `with`and `range`actions change the value of the `dot`.

And the `html/template`also provides some template functions which U can use to add extra logic to templates and control what is rendered at runtime -- like:

`{{eq .Foo .Bar}}`, and `ne`.

`{{not .Foo}}`... `{{or .Foo .Bar}}`yields `.Foo`if `.Foo`is not empty, otherwise `.Bar`yielded.

`{{index .Foo i}}` -- yields the value of the `.Foo`at index `i`. Map, slice or array

`{{printf "%s-%s" .Foo .Bar}}`-- yeilds a formatted string contaiing the `.Foo`and `.Bar`values, was `Sprintf`

`{{$bar := len .Foo}}`-- assign the length of `.Foo`to the *template variable* `$bar`

Template variables are particular useful if u want to store the result from a function and use it in multiple places in your templates -- and variable names must be prefixed by a `$`and can contain alphanumeric characters only.

Using the `with`action -- like:

```html
{{with .Snippet}}
<div class="snippet">
    <div class="metadata">
        <strong>{{.Title}}</strong>
        <!-- ... -->
        ...
{{end}}
```

#### Using the `if`and `range`

Also use the `{{if}}`and `{{range}}`actions in the concrete example and update your home page like:

```go
type templateData struct {
	Snippet *models.Snippet
	Snippets []*models.Snippet
}
```

Then just update the `home`handler function that it fetches the latest snippets from our dbs model and passes them to the template like:

```go
// Just crate an instance of a templateData struct
data := &templateData{Snippets: s}
files := []string{
    "./ui/html/home.page.html",
    "./ui/html/base.layout.html",
    "./ui/html/footer.partial.html",
}
//
// use the template.ParseFiles() to read template file
ts, err := template.ParseFiles(files...)
if err != nil {
    app.serverError(w, err)
    return
}

err = ts.Execute(w, data)
if err != nil {
    app.serverError(w, err)
}
```

Now, just head over to the `ui/html/home.page.html`file and update it to display these snippets in a table using `{{if}}`and `{{range}}`actions like:

- If it’s empty, want to display a `There is nothing to display`
- Use the `{{range}}`action to iterate voer all snippets in the slice.

```html
{{if .Snippets}}
<table>
    <tr>
        <th>Title</th>
        <th>Created</th>
        <th>ID</th>
    </tr>
    {{range .Snippets}}
    <tr>
        <td><a href="/snippets?id={{.ID}}"></a></td>
        <td>{{.Created}}</td>
        <td>#{{.ID}}</td>
    </tr>
    {{end}}
</table>
{{else}}
	<p>There's nothing to see here...yet!</p>
{{end}}
```

### Caching Templates

Before add any more functionality to our HTML -- good time to make some optimizations to codebase -- there are two main issues at the moment -- 

1. Each and every time render a web apge, our application reads and parses the relevant template files using the `template.ParseFiles()`-- could avoid this duplicated work by parsing files only once, when starting the app, and storing the parsed templates in an in-memory cahce.
2. And there is duplicated code in the `home`and `showSnippet`handlers -- and could reduce this duplication by creating a helper function.

Tackle the first option -- create an in-memory *map* wtih the type `map[string]*template.Template`to cache the parsed templates -- in the `templates.go`file add:

```go
func newTemplateCache(dir string) (map[string]*template.Template, error) {
	// Initialize a new map act as the cache.
	cache := map[string]*template.Template{}

	// use the filepath.Glob() to get a slice of all filepath with the extension
	// page.html -- this essentially gives us a slice of all the htmls
	pages, err := filepath.Glob(filepath.Join(dir, "*.page.html"))
	if err != nil {
		return nil, err
	}

	// loop through the pages one-by-one
	for _, page := range pages {
		// extract the file name from the full file path
		// and assign it to the name variable
		name := filepath.Base(page)

		// parse the page template file in a template set.
		ts, err := template.ParseFiles(page)
		if err != nil {
			return nil, err
		}

		// use the `ParseGlob` to add templates to the template set
		ts, err = ts.ParseGlob(filepath.Join(dir, "*.layout.html"))
		if err != nil {
			return nil, err
		}

		// parse the partial.html like:
		ts, err = ts.ParseGlob(filepath.Join(dir, "*.partial.html"))
		if err != nil {
			return nil, err
		}

		cache[name] = ts
	}
	// return the map.
	return cache, nil
}
```

