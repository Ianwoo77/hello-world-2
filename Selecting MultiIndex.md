# Selecting MultiIndex

Extracting DF rows and columns gets tricky when multiple levels are involved. The key question to ask before writing any code is what we want to pull out.

### Extracting one or more columns

If pass a single value in square brackets, pandas will look for it in the *outermost* level of the column’s `MultiIndex`. just like: `neighborhoods['Services']`, and note that the new df does not have a `Category`level, it has a plain `Index`with .. Note that pandas will raise, if the values doesn’t exist in the *outermost* level of the columns.

If want to target a specific Category and then a `Subcategory`-- to specify -- can pass them inside a tuple so the next example targets the column with a value of `Services`in the Category level. just like:
`neighborhoods[('Services', 'Schools')]`

Note that the method just returns a Series. And to extract multiple DF columns, need to pass the `[]`a list of tuples. just like: -- the order of tuples within the list sets the order of columns in the resulting DF. like:
`neighborhoods[[('Services', 'Schools'), ('Culture', 'Museums')]]`

### Extracting one or more with loc and iloc

For the example DF -- has 3 levels -- `State City Address`-- when provide a vlaue for a level, remove the need for the level to exist in the result. Can:
`neighborhoods.loc[('TX', 'Kingchester', '534 Gordon Falls')]`

And if pass a single label, pandas looks for it in the outermost `MultiIndex`level. And pandas returns a `DF`with a two-level `MultiIndex`. Usually, the second arg to the `[]`should denotes the columns. but can be a index name. so:
`neighborhoods.loc[('CA', 'Dustinmouth')]`

This syntax is more straightforward and more consistent, and can:
`neighborhoods.loc[('CA', 'Dustinmouth'), ('Services',)]`
so, pandas distinguishes between list and tuple arguments to accessors. Can pass a tuple as the second arg to the `loc`to provide values for levels in the column. 
`neighborhoods.loc[('CA', 'Dustinmouth'), ('Services', 'Schools')]`

And selecting sequential rows -- can use python’s list-slicing syntax, place a colon between our starting point and our ending point like:
`neighborhoods['NE':'NH']`

Can also combine list-slicing syntax with tuple argument like:
`neighborhoods.loc[('NE', 'Shawnchester'):('NH', 'North Latoya')]`

Can pull out multiple rows by wrapping their index position in a list like:
`neighborhoods.iloc[[25,30]]`

So, if list, just multiple selecting the rows, and if tuple, just select one row with specified index. Can also:
`neighborhoods.iloc[25:30, 1:3]`

### Cross-sections

The `xs`method allows to extract rows by providing a value for one multiIndex level. Just like:

```python
neighborhoods.xs(key='Lake Nicole', level=1) # or level='City'

# can apply the same tech to column by passing the axis columns like:
neighborhoods.xs(axis='columns', key='Museums', level='Subcategory').head()

# can also provide the xs with keys across nonconsecutive levels like:
neighborhoods.xs(
    key=('AK', '238 Andrew Rue'), level=['State', 'Street'] # or level=[0,2]
)
```

### Manipulating the index

Resetting the index -- The df now has State as its outermost followed by City and Street like: The `reorder_levels`method arragnes the `MultiIndex`levels in a specified order like:

```python
new_order= ['City', 'State', 'Street']
neighborhoods.reorder_level(order=new_roder)
```

Can also pass the `order`parameter a list of integers -- the number must just represent the current index pos of the `MutltiIndex`. Can:
`neighborhoods.reorder_levels(order=[1,0,2]).head()`

And if want to get rid of the index just, using the `reset_index`and:
`neighborhoods.reset_index().tail()`
notice that the 3 new columns become values in Category, if want to become the `Subcateogyr`:
`neighborhoods.reset_index(col_level=1) # or 'Subcategory'`

For now, pandas will default to an empty string for `Category`, so can give it one with `col_fill`parameter like:
`neighborhoods.reset_index(col_fill='Address', col_level='Subcategory')`

And the std invocation of `reset_index`transforms all index levels into regular columns. Can also move a single index level by its name to the `level`parameter like:

```python
neighborhoods.reset_index(level='Street').tail()
# can move multiple levels by passing a list
neighborhods.reset_index(level=['Street', 'City'])

# removing a level from the multiindex -- like:
neighborhoods.reset_index(level='Street', drop=True)
```

### Setting the Index

The `set_index()`method sets one or more DF columns as the new index, can pass the column to use its `keys`parameter like:
`neighborhoods.set_index(keys='City').head()`

And want to one of the last four to serve as the index like:
`neighborhoods.set_index(keys=('Culture', 'Museums'))` # pass a tuple

To create a `MultiIndex`on the row axis, can pass a list with multiple columns to `keys`parameter like:
neighborhoods.set_index(keys=[‘State’, ‘City’])

## Concurrency Patterns in Go

Lexical confinement involves using lexical scope to expose only the correct data and concurrency primitives for multiple concurrent processes to use. Like:

```go
func main() {
	chanOwner := func() <-chan int {
		results := make(chan int, 5)
		go func() {
			defer close(results)
			for i := 0; i <= 5; i++ {
				results <- i
			}
		}()
		return results
	}

	consumer := func(results <-chan int) {
		for result := range results {
			fmt.Printf("Received: %d\n", result)
		}
		fmt.Println("Done receiving")
	}
	results := chanOwner()
	consumer(results)
}

```

Instantiate the channel within the lexical scope of the `chanOwner`function this limits the scope of the write aspect of the `results`channel to the closure defined below it. In other words, it confines the write aspect of this channel to prevent other groutines from writing it.

### The for-select loop

Sth will see.. in Go program is the `for-select`loop it’s just nothing than sth like this:
`for {select{}}`

There are a couple of different scenarios where you will see in this pop up -- 

- Sending iteration variables out on a channel -- Oftentime you will want to convert sth that can be iterated over into values on a channel -- this is nothing fancy, usually looks like:

  ```go
  for _, s := range []string{"a", "b", "c"} {
      select {
      case <-done:
          return
      case stringStream <-s:
      }
  }
  ```

- Looping infintely waiting to be stopped -- very common to create goroutines that loop infintely until stopped, there are just a couple variations of this one but just like:

  ```go
  for {
      select {
      case <-done:
          return
      default:
      }
      // do non-preemtable work
  }
  // the second variation like:
  for {
      select {
      case <-done:
          return
      default:
          // do non-preemtable work
      }
  }
  ```

### Preventing Goroutines Leaks

The goroutines *do* cost resources, and the goroutine are **not** garbage collected by the runtime. Why could a goroutine exist -- established that goroutine just represent units of work that may or may not run in parallel with each other.

- When it has completed its work
- When it cannot continue its work due to unrecoverable error
- when it’s told to stop working

if begun a goroutine, it’s most likely cooperating with several other goroutines in some sort of organized fashion, could even represent this interconnectedness as a graph - whether or not a child goroutine should continue executing might be predicated on knowledge of the state of many *other* goroutines. like:

```go
func doWork(string <-chan string) <-chan any {
    completed:= make(chan any)
    go func() {
        defer fmt.Println("dowork exited")
        defer close(completed)
        for s:= range strings {
            //... do sth
        }
    }()
    return completed
    
    // leak
    doWork(nil)
}
```

Therefore the `strings`channel will never actually gets any strings written on it, and the goroutine contaiing `doWork`will remain in memory for the lifetime of this process. The way to successfully mitgate this is to establish a signal between parent and its children that allows the parent to signal cancellation to its children. fore:

```go
doWork := func(
	done <-chan any,
    strings <-chan string,
)<-chan any {
    terminated := make(chan any)
    go func() {
        defer fmt.Println(...)
        defer close(terminated)
        for{
            select {
            case s:= <-strings:
                //...
            case <-done:
                return
            }
        }
    }()
    return termiated
}

done := make(chan any)
terminated := doWork(done, nil)
go func(){
    time.Sleep(time.Second)
    close(done)
}()

<-terminated // Join the goroutine spawned from doWork
```

### The or-channel

At times you may find youself wanting to combine one or more `done`channels into a single `done`channel that closes if any of its component channels close -- it is perfectly accetable. to Write a `select`that perform this coupling, sometimes you can’t know the number of `done`channels. Just like:

```go
func or(channels ...<-chan any) <-chan any {
	switch len(channels) {
	case 0:
		return nil
	case 1:
		return channels[0]
	}

	orDone := make(chan any)
	go func() {
		defer close(orDone)

		switch len(channels) {
		case 2:
			select {
			case <-channels[0]:
			case <-channels[1]:
			}
		default:
			select {
			case <-channels[0]:
			case <-channels[1]:
			case <-channels[2]:
			case <-or(append(channels[3:], orDone)...):
			}
		}
	}()
	return orDone
}
```

Cuz of how we are recuring, every recursive call to `or`will at least have 2 channels. As an optimization to keep the number of goroutines constrained, we place a special case here for calls to `or`with only two channels. use this:

```go
func sig(after time.Duration) <-chan any {
	c := make(chan any)
	go func() {
		defer close(c)
		time.Sleep(after)
	}()
	return c
}
func main() {
	start := time.Now()
	<-or(
		sig(2*time.Hour),
		sig(3*time.Minute),
		sig(4*time.Second),
		sig(5*time.Hour),
	)
	fmt.Printf("done after %v", time.Since(start))
}
```

### Error Handling -- 

In concurrent programs, error handling can be just difficult to get right. Sometimes, we spend -- Cuz a concurrent process is operating independently of its parent or siblings, it can be difficult for it to reason about what the right thing to do with the error is. Like:

```go
func checkStatus(done <-chan any, urls ...string) <-chan *http.Response {
	responses := make(chan *http.Response)
	go func() {
		defer close(responses)
		for _, url := range urls {
			resp, err := http.Get(url)
			if err != nil {
				fmt.Println(err)
				continue
			}
			select {
			case <-done:
				return
				case responses <- resp:
			}
		}
	}()
	return responses
}
//...
func main() {
	done := make(chan any)
	defer close(done)

	urls := []string{"https://www.google.com", "python://badhost"}
	for response := range checkStatus(done, urls...) {
		fmt.Printf("Response: %v\n", response.Status)
	}
}
```

Here can see that the goroutine has been given no choice in the matter - it can’t simply swallow the error, and so it does the only sensible thing -- prints the error and hopes sth is paying attention. Don’t put your goroutines in this awkward position -- separate your concerns -- in general, your concurrent processes should send their errors to another part of your program that has complete info about the state of your program. So just like:

```go
type Result struct {
	Error    error
	Response *http.Response
}

func checkStatus(done <-chan any, urls ...string) <-chan Result {
	results := make(chan Result)
	go func() {
		defer close(results)
		for _, url := range urls {
			var result Result
			resp, err := http.Get(url)
			result = Result{err, resp}
			select {
			case <-done:
				return
			case results <- result:
			}
		}
	}()
	return results
}

//...
func main() {
	done := make(chan any)
	defer close(done)

	urls := []string{"https://www.google.com", "python://badhost"}
	for response := range checkStatus(done, urls...) {
		if response.Error != nil {
			fmt.Printf("Error: %v", response.Error)
			continue
		}
		fmt.Printf("Response: %v\n", response.Response.Status)
	}
}
```

Can see that cuz errors are returned from `checkStatus()`and not handled internally within the goroutine, error handling follows the fmailiar Go pattern.

## Creating named Nested Templates

The `define`action is used to create a nested template that can be executed by name, which allows content to be defined once and used repeatedly with the `template`action.

```html
{{define "currency"}} {{printf "$%.2f" . }} {{end}}

{{define "basicProduct" -}}
    Name: {{.Name }}, Category: {{.Category }}, Price,
    {{- template "currency" .Price }}
{{- end}}

{{define "expensiveProduct" -}}
    Expensive product {{.Name }} ({{template "currency" .Price}})
{{- end}}

<h1>There are {{len .}} products in the source data.</h1>
<h1>First product {{index . 0}}</h1>
{{range . -}}
    {{if lt .Price 100.00 -}}
        <h1>{{template "basicProduct" .}}</h1>

    {{ else if gt .Price 1500.00 -}}
        <h1>{{template "expensiveProduct" .}}</h1>
    {{ else -}}
        <h1>Midrange Product: {{.Name}} ({{printf "$%.2f" .Price}})</h1>
    {{end -}}
{{end}}
```

The `define`keyword is followed by the template name in quotes, and the template is terminated by the `end`keyword, the `template`keyword is used to execute a anmed template, specifying the template name and a data value like:
`{{- template “currency” .Price}}`
and the action executes the template *named* currency and uses the value of the `Price`field as the data value, which is acessed within the named template using the period like:
`{{define "currency"}} {{printf "$%.2f" .}}{{end}}`

Nested named templates can exacerbate whitespace issues cuz the whitespace around the templates, which for clarity, is included in the output from the main template -- one way to resolve this is to define the named templates in the separate file but the issue can also be addressed by using only named templates.

```html
{{define "mainTemplate"}}
    <!--... -->
{{end}}
```

Using the `define`and `end`keywords for the main template content excludes the whitespace used to separate 

```go
func main() {
	allTemplates, err := template.ParseGlob("templates/*.html")
	if err == nil {
        // can use the named template's name
		selectedTemplated := allTemplates.Lookup("mainTemplate")
		err = Exec(selectedTemplated)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

### Defining Template Blocks

Template blocks are used to define a template with default content can be overridden in another template file, which requires multiple templates to be loaded and executed together. like:

```html
{{define "mainTemplate" -}}
    <h1>This is the layout header</h1>
    {{- block "body" .}}
        <h2>There are {{len .}} products in the source data.</h2>
    {{- end}}
    <h1>This is the layout footer</h1>
{{ end }}
```

When used alone the output from the tempalte file includes the content in the block. But this content can be just *redefined* by another template file -- Add a file named `list.html`to the `templates`folder with the content like:

```html
{{define "body"}}
    {{range .}}
        <h2>Product: {{.Name}} ({{printf "$%.2f" .Price}}</h2>
    {{end}}
{{end}}
```

Then to use this, just loaded in order like:

```go
allTemplates, err := template.ParseFiles("templates/template.html",
		"templates/list.html")
```

### Defining Tempalte functions

The built-in template functions described -- can be supplementedy by custom functions that specific to the `Tempalte`, meaning they are defined and set up in code. Fore:

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
// ...
func main() {
	allTemplates := template.New("allTemplates")
	allTemplates.Funcs(map[string]any{
		"getCats": GetCategories,
	})
	allTemplates, err := allTemplates.ParseGlob("templates/*.html")
	//...
}
```

The `GetCategories`func receives a `Product`and returns the set of unique `Category`values. And to set up the `GetCategories`function so that it can be used by a `Template`, the `Funcs`method is called, passing a map to functions. Like:

`allTemplates.Funcs(map[string]any {"getCats":GetCategories})`The map specifies that the `GetCategories`func will be invoked using the name `getCats`-- t**he `Funcs`must be called before template files are parsed -- note that**.

And within the templates, the custom functions can be called using the same syntax as the built-in functions like:

```html
{{define "mainTemplate" -}}
    <h1>There are {{len .}} products in the source data.</h1>
    {{range getCats . -}}
        <h1>Category: {{.}}</h1>
    {{end}}
{{- end }}
```

And the `range`keyword is used to enumerate the categories returned by the custom functions. Which are included in the template output.