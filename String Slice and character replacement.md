# String Slice and character replacement

Can use the `slice`on the `StringMethods`object to extract a substring from a string by index position. The method accepts a starting index and an ending index as args. fore:

```python
insepctions = insepctions.replace(
	to_replace="All", value="Risk 4 (Extreme)"
)
```

Fore, starts at index position 5 in each string, the next example pulls the characters from index position 5 up to index position 6 just like: `inspections['Risk'].str.slice(5, 6).head()`, can also replace the `slice()`with python’s list-slicing syntax -- just like: `inspections['Risk'].str[5:6].head()`

This challenge is made difficult by the different length of the words, cannot extract the same number of characters from a starting index position -- just like:
`inspections['Risk'].str.slice(8).head()`--> `.str[8:]`

Pass a negative arg to the `str.slice()`method, just like:
`inspections['Risk'].str.slice(8,-1).head()`

And each `str`method returns a new `Series`object with its own `str`attribute -- this accept allows us to chain multiple string methods in sequence -- as long as we reference the `str`attribute in each method invocation. like:
`inspections['Risk'].str.slice(8).str.replace(")", "", regex=False).head()`

### Boolean methods

Other methods available on the `StringMethods`object return a `Series`of Booleans, these methods can prove to be particularly helpful for filtering a DataFrame -- Suppose that we want to isolate all establishments with the word -- str’s `contatins`method checks for a substring’s inclusion in each `Series`value.
`inspections['Name'].str.lower().str.contains('pizza').head()`

```python
has_pizza= inspections['Name'].str.lower().str.contains('pizza')
inspections[has_pizza]
```

Noticed that pandas preserves the original letter casing of the values in Name. The DF is never mutated. and the `lower`method returns a new `Series`, and the `contains()`returns another new `Series`. Can also:

```python
inspections['Name'].str.lower().str.startswith('tacos').head()
ends_with_tacos= (
	inspections['Name'].str.lower().str.endswith('tacos')
)
inspections[ends_with_tacos]
```

Splitting strings -- Our next set is a collection of fictional customers -- each row includes the customer’s Name and Address, import the customer.csv like: `customers.Name.str.len().head()`-- Suppose want to isolate each customer’s first and last names in two separate columns, may be familiar with `split()`which separates a string by using a specified delimiter -- methods returns a list consisting of all substrings after the split. Next example splits: The `str.split()`performs the same operation on each row in a `Series`-- its return value is a `Series`of lists. like:
`customers.Name.str.split(' ')` # or using `pat`parameter name...

Then can invoke the `str.len`-- Some names have more than two words -- can see an example at index position 3. The next passes an arg of 1 to the `split`method’s `n`parameter like: Then use the `get()`to pull out a value from each row’s list based on its index position. like:
`customers.Name.str.split(' ', n=1).str.get(0).head()`

And the `get`method also supports negative arguments. And we have used two separate `get`method calls to extract the first and last names in two separate `series`-- nice to perform the same logic in a single method call. like:

```python
customers['Name'].str.split(
    pat=' ', n=1, expand=True
)
```

`str.split`method accepts an `expand`parameter, and when pass it an argument of `True`, the method returns a new `DF`instead of a `Series`of lists. After this, got a new DF. Cuz did not provide a custom names for the columns. Pandas defaulted to a numberic index.

And be careful in these -- if do not limit the number of splits with the `n`parameter, pandas will place `None`. For now, need to attach the new two-column df to the existing customers `DataFrame`. So just use:

```python
customers[['First Name', 'Last Name']]= \
	customers['Name'].str.split(' ', n=1, expand=True)
```

Then can just drop the `Name`column like:
`customers= customers.drop(labels='Name', axis=1)`

Coding -- Using the `Customers`'s' address column then test this like: First is splitting the address strings with a delimitr, using the `split`method like:
`customers['Address'].str.split(',').head()`
`customers['Address'].str.split(', ').head().values` Then expand this.
`customers['Address'].str.split(', ', expand=True).head()`

Then assign name to it like:

```python
new_cols= 'Street City State Zip'.split()
customers[new_cols]=customers.Address.str.split(', ', expand=True)
```

And the last step is deleting the original `Address` like:
`customers=customers.drop(labels='Address', axis='columns')`
`del customers['Address']`

### A note on regular expressions

Any discussion of working with text daa is incomplete without mentioning regular expression -- declare regular expressions with a special syntax consisting of symbols and character `\d`.

Can think of a `WaitGroup`like a concurrent-safe counter, calls to `Add`increment the counter by the integer passed in. and calls to `Done`decrement the counter by one. Fore:

```go
func main() {
	hello := func(wg *sync.WaitGroup, id int) {
		defer wg.Done()
		fmt.Printf("Hello from %v\n", id)
	}
	const numGreeters = 5
	var wg sync.WaitGroup
	wg.Add(numGreeters)
	for i := 0; i < numGreeters; i++ {
		go hello(&wg, i+1)
	}
	wg.Wait()
}
```

### Mutex and RWMutex

A `Mutex`provides a concurrent-safe way to express exclusive access to these shared resources. just like:

```go
unc main() {
	var count int
	var lock sync.Mutex

	increment := func() {
		lock.Lock()
		defer lock.Unlock()
		count++
		fmt.Printf("Incrementing: %d\n", count)
	}

	decrement := func() {
		lock.Lock()
		defer lock.Unlock()
		count--
		fmt.Printf("Decrementing: %d\n", count)
	}

	var arithmetic sync.WaitGroup
	for i := 0; i <= 5; i++ {
		arithmetic.Add(1)
		go func() {
			defer arithmetic.Done()
			increment()
		}()
	}

	// decrement
	for i := 0; i <= 5; i++ {
		arithmetic.Add(1)
		go func() {
			defer arithmetic.Done()
			decrement()
		}()
	}

	arithmetic.Wait()
	fmt.Println("Arithmetic complete")
}
```

Can notice that always call `Unlock`within a `defer`statement -- this is just a very common idiom when utlizing a `Mutex`to ensure the call always happens. And the `sync.RWMutex`is conceptually the same thing as a `Mutex`-- it guards acces to memory, gives you a little bit more control over the memory.

### Cond

Very often you will want to wait for one of these signals before continuing execution on a goroutine. That carries no information other than the fact that it has occurred. Like:

```go
for conditionTrue()== false {}
// this would consume all cycles of one core so:
for conditionTrue()==false {
    time.Sleep(time.Millisecond)
}
```

This is better -- still inefficient -- have to figure out how long to sleep for. So, it would be better if there were some kind

 of way for goroutine to efficiently sleep until it was signaled to wake and check its condition. can:

```go
// introduce a new Cond
c := sync.NewCond(&sync.Mutex{})
c.L.Lock() // lock the locker necessary cuz the call to Wait automatically call Unlock on Locker
for conditionTrue()==false{
    c.Wait() // block and goroutine blocked
}
c.L.Unlock() // necessary
```

Expand this example like:

```go
func main() {
	c := sync.NewCond(&sync.Mutex{})
	queue := make([]any, 0, 10)

	removeFromQueue := func(delay time.Duration) {
		time.Sleep(delay)
		c.L.Lock()
		queue = queue[1:]
		fmt.Println("Removed from queue")
		c.L.Unlock()
		
		// let goroutine waiting on the condition
		c.Signal()
	}

	for i := 0; i < 10; i++ {
		c.L.Lock()
		for len(queue) == 2 {
			c.Wait()
		}
		fmt.Println("Adding to queue")
		queue = append(queue, struct{}{})
		go removeFromQueue(time.Second)
		c.L.Unlock()
	}
}
```

### Once

```go
var count int
increment := func(){
    count++
}

var once sync.Once
var increments sync.WaitGroup
increments.Add(100)
for i:=0; i<100; i++ {
    go func(){
        defer increments.Done()
        once.Do(increment)
    }()
}
increments.Wait()
fmt.Print(count) // 1
```

As the name implies, `sync.Once`is just a type that utlizes some `sync`primtives internally to just ensure that only one call to `Do`ever calls the function passed in. And there are a few things to note about -- take a look another example:

```go
var count int
increment := func() {count++}
decrement := func() {count--}

var once sync.Once
once.Do(increment)
once.Do(decrement)
fmt.Println(count) // 1
```

Cuz `sync.Once`only counts the number of times `Do`is called, not how many times unique functions passed into `Do`are called. Recommended that you formalize this coupling by wrapping any usage of `sync.Once`in a small lexical block.

## Channels

R one of the synchornization promitives in Go derived form CSP. Channel erves as a conduit for a stream of info -- values may be passed along the channel, and then read out downstream. When using, pass a value into a `chan`variable, and then read it off the channel. When using channels, pass a value into a `chan`-- the disparate parts of your program don’t require knowledge of each other, only a reference to the same place in memory where the channel resides. like:

```go
var dataStream chan any // declare
dataStream = make(chan any) // instantiate
```

To declare a unidirectional, simply include the `<-` -- And keep in mind channels are typed. like:
`intStream := make(chan int)`

```go
stringStream := make(chan string)
go func() {
    if 0!=1{
    	return
    }
    stringStream <- "hello"
}()
fmt.Println(<-stringStream)
```

This causes deadlock. And the receiving form of the `<-`operator can also optionally return two values like:

```go
stringStream := make(chan string)
go func() {
    stringStream <- "hello"
}()
sal, ok := <-stringStream
fmt.Printf("(%v): %v", ok, sal)
```

The second return value is a way for a read operation to indicate whether the read off the channel was a value generated by a write elsewhere in the process -- or a default value generated from a closed channel. In programs it’s *very useful* to be able to indicate that no more values will be sent over a channel. `close`keyword like:

```go
valueStream := make(chan any)
close(valueStream)
//...
intStream := make(chan int)
close(intStream)
integer, ok := <-intStream
fmt.Printf("%v, %v", ok, integer)  // false 0
```

Just noticed that never placed anything on this channel, we closed it immediately. We were still able to perform a read opreation, could continue performing reads on this channel indefinitely despite the channel remaiing closed. This is to allow support for multiple downstream reads from a single upstream writer on the channel.

This opens up a few new patterns for us -- first is *ranging* -- over a channel -- The `range`used in conjunction with the `for`supports channels as arguments -- and will automatically break the loop when a channel is **closed**.

```go
intStream := make(chan int)
go func(){
    defer close(intStream)
    for i:=1; i<=5; i++{
        intStream <- i
    }
}()
for integer := range intStream {
    fmt.Println(integer)
}
```

Notice that how the loop doesn’t need an exit criteria, and the `range`does not return the second boolean value -- The specifiecs of handling channel are manged for you to keep the loop concise. Closing a channel is also one of the ways U can signal multiple goroutines simultaneously -- have `n`waiting on a single channel, instead of writing n times to the cahnnel to unblock each, can simply close the channel. like:

```go
func main() {
	begin := make(chan any)
	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			<-begin
			fmt.Printf("%v has begun\n", i)
		}(i)
	}
	fmt.Println("Unblocking goroutines...")
	close(begin)
	wg.Wait()
}
```

## Loading Multiple Templates

There are two approaches to working with multiple templates -- the first is to create a separate `Template`value for ech of them and execute them separately like:

```go
t1, err1 := template.ParseFiles("templates/template.html")
if err1 == nil {
    t1.execute(os.Stdout, &Kayak)
}else {
    Printfln("Error: %v, %v", err1.Error(), err2.Error())
}

// or
allTemplates, err1 := tempalte.ParseFiles("templates/template.html", 
                                         "templates/extras.html")
if err1 == nil {
    allTemplates.ExecuteTemplate(os.Stdout, "template.html", &Kayak)
    allTemplates.ExecuteTemplate(os.Stdout, "extras.html", &Kayak)
}
```

### Enumerating Loaded Templates

Can be useful to enumerate the templates that have been loaded, especially when using the `ParseGlob()`to make sure that all the expected files have been discovered, uses the `Templates`method to get a list of templates and the `Name()`get the name of each one like:

```go
func main() {
	allTemplates, err := template.ParseGlob("templates/*.html")
	if err == nil {
		for _, t := range allTemplates.Templates() {
			Printfln("Template name: %v", t.Name())
		}
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

Looking up a Specifc Template -- An alternative to specifying a name is to use the `Lookup`method to select a template, which is useufl when you want to pass a template as an argument to a function like:

```go
func Exec(t *template.Template) error {
	return t.Execute(os.Stdout, &Kayak)
}

func main() {
	allTemplates, err := template.ParseGlob("templates/*.html")
	if err == nil {
		selectedTemplated := allTemplates.Lookup("template.html")
		err = Exec(selectedTemplated)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

### Understanding Template Actions

Go templates support a wide range of actions, which can be used to generate content from the data that is passed to the `Execute`or `ExecuteTemplate`method. like:

- `{{value}}`-- inserts a data value or the result of an expression into the template, `.`used to refer to the data value passed to the `Execute`or `ExecuteTempalte`function.
- `{{value.fieldname}}`-- inserts the value of a struct field
- `{{value.method arg}}`-- invokes a method and inserts the result into the template output.
- `{{func arg}}`-- invokes a func and inserts the ressult intot the output. And there are built-in funcs for common tasks.
- `{{expr | value.method}}`-- chained together using a pipe.
- `{{range value}}`-- iterates through the specified slice and adds the content
- `{{end}}`
- `{{if expr}} {{with epxr}}`
- `{define "name"}`
- `{{template "name" expr}}` -- executes the template with the specified anme
- `{{block "name" expr}}`-- defines a template with the specified name and invokes it with specified data.

### Inserting Data Values

The simplest task in a tempalte is to insert a value into the output generated by the template. `., .Field, .Method, .Method arg, call .Field arg`

Fore, used just the period in the -- effect of inserting a string representation of the data value used to execute the template. like:

```html
<h1>Name: {{.Name}}</h1>
<h1>Price: {{.Price}}</h1>
<h1>Tax: {{.AddTax}}</h1>
<h1>Discount price {{.ApplyDiscount 10}}</h1>
```

The new actions contain expressions that write out the value of the `Name...`.

Formatting Data Values -- Templates supports built-in functions for common tasks, including formatting data values that are inserted into the output.

- `print`-- alias to the `fmt.Sprint`
- `printf, println`
- `html js urlquery` -- encodes a value for safe inclusion in an HTML, JS, URL query string.

```html
<h1>Price: {{printf "$%.2f" .Price}}</h1>
<h1>Tax: {{printf "$%.2f" .AddTax}}</h1>
```

Chaining and parenthesizing template expressions -- Changing expressions creates a pipeline for values, which allows the output from one method or function to be used *as the input for another*.

```html
<h1>Discount price: {{.ApplyDiscount 10 | printf "$%.2f"}}</h1>
```

Just are chained using pipe character -- with the effect that the result of one expression is used as the final argument to the next expression. As an alternative approach like:

```html
<h1>
    Discount Price {{printf "$%.2f" (.ApplyDiscount 10)}}
</h1>
```

Trimming whitespace - By default, the content of the template are rendered exactly as they are defined in the file, including any whitespace between actions. But whitespace can still cause problems for text content and attribute values, especially when want to structure the content of a template to make it just easy to read like:

```html
<h1>
    Name: {{.Name}}, Category: {{.Category}}, Price,
    {{printf "$%.2f" .Price}}
</h1>
```

The `minus`sign can be used to trim whitespace, applied immediately after or before braces just like:

```html
<h1>
    {{- "" -}}Name: {{.Name}}, Category: {{.Category}}, Price, {{- " " -}}
    {{- printf "$%.2f" .Price -}}
</h1>
```

The whitespace around the final action has been removed, but there is still a newline character after the opening. Even with these -- it can also be hard to control whitespace while writing templates that are wasy to understand.

### Using Slices in Templates

Template actions can be used to generate content for slices like:

```html
{{range . -}}
    <h1>Name: {{.Name}}, Category: {{.Category}}, Price, {{- " " -}}
    {{- printf "$%2.f" .Price}}</h1>
{{end}}
```

```go
func Exec(t *tempalte.Template) error {
    return t.Execute(os.Stdout, Products)
}
```

Just wanted the template content within the `range`and `end`actions to be visually distinct by putting it on a new line and add indentation.

Using the Built-in Slice Functions -- Go text templates support the built-in functions like:

- `slice`-- creates a new slice, like py’s
- `index`-- returns the element
- `len`-- returns the length

```html
<h1>There are {{len .}} products in the source data.</h1>
<h1>First product {{index . 0}}</h1>
{{range slice 3 5 -}}
    <h1>Name: {{.Name}}, Category: {{.Category}}, Price, {{- " " -}}
        {{- printf "$%2.f" .Price}}
    </h1>
{{end}}
```

### Conditionally Executing Template Content

Actions can be used to conditionally insert content into the output based on evaluation of their expression.

```html
{{range . -}}
    {{if lt .Price 100.00 -}}
        <h1>Name: {{.Name}}, Category: {{.Category}}, Price,
            {{- printf "$%.2f" .Price}}</h1>
    {{end -}}
{{end}}
```

The `if`keyword is followed by an expression that determines whether the nested template content is executed. like:

- `eq arg1 arg2`
- `ne, lt, le, gt, ge, and` all `arg1 arg2`parameters
- `not arg1`-- returns `true`if arg1 is `false`, and false if it is `true`.

The syntax for these function is just consistent the rest of the template features. like:

`{{if lt .Price 100.00 -}}`

And the `if`keyword indicates a conditional action and the `lt`performs a less-than comparison, and the remaining args specify the `Price`field of the current vlaue in the `range`expression and a literal vlaue of 100.00-- The `range`action enumerates the values in the `Product`slice and executes the nested `if`action.