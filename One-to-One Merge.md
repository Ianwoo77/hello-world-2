# One-to-One Merge

In the simplest type of merge, have two dfs where want to join one column to another column, and where the columns we want to join do not contain any duplicate values. Will modifty the `visited`dfs so there are no duplicated site values like: `visited_subset= visted.loc[[0, 2, 6], :]`

```python
# get a count of the value in the site column 
visited_subset['site'].value_counts()
o2o_merge= site.merge(
	vistied_subset, left_on="name", right_on="site"
)
```

Have now created a new df from two separate dfs where the rows were matched on a particular set of columns.

### Mang-to-One Merge

If choose to do the same merge, but this time without using the substted `visited`, could just perfrom a many-to-one merge -- in this kind of merge, one of the dfs has key values that *repeat*.

`visited['site'].value_counts()`

The dataframes that contain the single observations will then be duplicated in the merge like:

```python
m2o_merge=site.merge(visited, left_on='name', right_on='site')
```

Just note that the site information were duplicated and matched to the `visited`data.

### Many-to-Many merge

Lastly, there iwll be times when we want to perform a match basd on multiple columns. As an example, suppose that have two dataframes that come from `person`merged with `survey`-- and anothter df that comes from `visited`merged with `survey`.

All the code for performing a merge uses the same method -- `merge`-- the only thing that makes the results differ is whether or not the left/or right dataframe *has duplicate keys*.

```python
ps=person.merge(survey, left_on='ident', right_on='person')
vs = visited.merge(survey, left_on='ident', right_on='taken')
```

Know there is a many-to-many merge happening cuz there are duplicate values in these keys for `both`the left and right dataframe. Can perform a many-to-many merge by passing the multiple columns to match on in a py list.

```python
ps_vs=ps.merge(
    vs, left_on='quant',
    right_on=['quant']
)
```

For this, pandas will automatically add a suffix to a column name if there are collisions in the name.

### Check Your work with Assert

A simple way to check your work before and after a merge is by looking at the number of rows of our data before and after the merge -- if you endup with *more* rows than either of the dataframes you are merging together - that means a many-to-many merge occurred. 

One way you can check your work is by having your code fail when you know a bad condition exists.

### Data Normalization

The final point in the - Usually, need to combine multiple data sets together so we can do an analysis -- but when we think about how to store and manage data in a way where we reduce the amount of duplication and potential for errors, we should try to normalize our data into separate tables so a single fix can propagate when we combine the data together again -- 

### Multiple Observational Units in a Table -- Normazliation

One of the simplest ways of knowing whether multiple observational units are represented in a table is by looking at each of the rows and taking note of any cells or values that are being repeated from row to row. this is just very common in education -- data. fore, student demographics are reported for each student for each year the student is enrolled.

```python
billboard= pd.read_csv('billboard.csv')
billboard_long= billboard.melt(
    id_vars='year artist track time date.entered'.split(),
    var_name='week',
    value_name='rating'
)
```

Supoose just subset the data based on a particluar track:

`billboard_long.loc[billboard_long.track=='Loser']`

Can see that this table actually holds two types of data, the track information and the weekly ranking. It would be better to store the track information in a separate table -- this way, the information stored in .. would not be repeated in the data set. This consideration is particular important if the data is manually entered.

Can place the ... in a new dataframe, -- with each unique set of value being assigned a unique ID, can then use this unique ID in a second dataframe that represents a date entered. This entire process can be thought of as reversing the steps in concatenating and merging data like:

Can assign a unique value to each row of data -- there are many ways you could do this, there we take the index and add 1 so it doens’t start with 0. like:

```python
billboard_songs['id']=billboard_songs.index+1
billboard_songs=billboard_songs.drop_duplicates()
billboard_songs
```

Now that have a separte df about songs, can use the newly created `id`column to match a song to its weekly ranking -- 

```python
billboard_ratings= billboard_long.merge(
    billboard_songs, on='year artist track time'.split()
)
```

## String Processing and REGEXP

In this, describe the stdlib features for processing `string`values, which are needed by almost every project and which many languages provide as methods defined on the built-in types -- but even though Go defines these features in the stdlib -- a complete set of functions is available -- 

- String processing includes a wide range of operations, from trimming whitespace to splitting a string into componetns. REGEXP are patterns that allow string matching rules to be concisely defined.
- Useful when an app needs to process `string`values. A common example is procesing HTTP requests.
- These are contained in the strings and `regexp`packages.

### processing strings

`Contains(s, substr), ContainsAny(s, substr)`-- returns `true`if the sting s contains any of the characters contianed in the string `substr`. ContainsRune(s, rune)-- returns `true`if the sting s contains a specific rune. `EqualFold(s1, s2)`-- performs a *case-insenstive* comparsion and returns `true`of string s1 and s2. And `HasPrefix(s, prefix)`and `HasSuffix(s, suffix)`-- returns `true`if the string ends with the string.

- `ContainsRune(product, 'K')`
- `strings.EqualFold(product, "KAYAK")`
- `strings.HasPrefix(product, 'Ka')`
- `strings.HasSuffix(product, "yak")`

### Converting string Case

The `strings`package provides the function for changing the case of the string like:

`ToLower, ToUpper, Title(str)`

- `ToTitle(str)`-- this returns a new string containing the characters in the specified string.

The `unicode`packate provides functions that can be used to determine or change the case of individual characters-- 

`IsLower(rune), ToLower(rune), IsUpper(rune), ToUpper(rune), `

`IsTitle(rune), ToTitle(rune)`

### Inspecting Strings

`Count(s, sub), Index(s, sub), LastIndex(s, sub)`.. `IndexFunc(s, func), LastIndex(s, func)`

Using custom functions -- the `IndexFunc()`and `LastIndexFunc()`uses a custom function to inspect strings like:

```go
func main() {
	description := "A boat for one person"
	isLetterB := func(r rune) bool {
		return r == 'B' || r == 'b'
	}
	fmt.Println("IdxFunc", strings.IndexFunc(description, isLetterB))  // 2
}
```

Custom functions receives a `rune`and return a `bool`result indicates if the character meets the desired condition.

### Manipulating Strings

The `strings`package provides useful functions for editing strings, including support for replacing some or all characters or removing whitespace. Splitting -- the first set of functions like:

`Field(s)`-- on whtespace characters and returns a slice, `FieldFunc(s, func)`, `Split(s, sub)`-- This splits the string on every occurrence of the specified substring, returning a `string`slice. , `FplitN(s, sub, max)`-- is similar to `Split`-- accepts an additional `int`argument that specifies the maximum number of substrings. `SplitAfter(s, sub)`-- similar to the `Split`includes the substring used in the results.

### Splitting using a Custom Functoin to Split strings

The `FieldFunc`function splits a string by passing each character to a csutom function like:

```go
func main() {
	description := "A boat      for one     person   spaced"
	splitter := func(r rune) bool {
		return r == ' '
	}
	splits := strings.FieldsFunc(description, splitter)
	for _, x := range splits {
		fmt.Println("Field>>" + x + "<<")
	}
}
```

### Trimming with custom Functions

```go
trimmer := func(r rune) bool {
    return r == 'A' || r=='n'
}
trimmed := strings.TrimFunc(description, trimmer)
fmt.Println("trimmed", trimmed)
```

### Altering strings

The functaions are provided by the `strings`package for altering the content of strings -- 

- `Replace(s, old, new, n)`-- alters the string s by replacing occurrences of the string `old`with the string `new`. The maximum number of occurrences that will be replaced is specified by the `int`argument `n`
- `Map(func, s)`-- generates a string by invoking the custom function for each character in the string s and concatenating the results.

```go
func main() {
	text := "It was a boat. A small boat."
	mapper := func(r rune) rune {
		if r == 'b' {
			return 'c'
		}
		return r
	}
	mapped := strings.Map(mapper, text)
	fmt.Println("Mapped", mapped)
}
```

### Using a String Replacer

The `strings`package exports a struct type named `Replacer`that is used to replace strings, providing an alternative to the functions described like:

```go
func main() {
	text := "It was a boat. A small boat."
	replacer := strings.NewReplacer("boat", "Kayak", "small", "huge")
	replaced := replacer.Replace(text)
	fmt.Println(replaced)
}
```

### Building and Generating Strings

The `strings`package provides two functions for generating strings and a struct type whose methods can be ued to efficiently build strings gradually -- like:

- `Join(slice, sep)`-- this combines the elements in the specified string slice, 
- `Repeat`-- this function generates a string by repeating the string s for specified number of times.

```go
elements := strings.Fileds(text)
joined := strings.Join(elements, "--")
```

Buidling -- The `strings`provides the `Builder`type, which has not exported fields but does provide a set of methods that can be used to **efficiently** build strings gradually -- like:

- `WriteString(s)`-- appends the string `s`to the string being built
- `WriteRune(r)`-- appends character
- `WriteByte(b)`-- appens the byte `b`
- `String()`-- returns the string that has been created by the builder
- `Reset()`-- resets the string
- `Len(), Cap()`-- returns the number of bytes, and allcoated by the buider, for `Cap()`method.

### Using Regexp in Go

The `regexp`support for regular expressions like:

- `Match(pattern b)`-- returns a bool indicates a pattern by byte slice `b`
- `MatchString(pattern s)`-- matched by the string `s`.
- `Compile(pattern)`-- returns a Regexp that can be used to perform repeated pattern matching with the specified pattern.
- `MustCompile(pattern)`-- provides the same feature as `Compile`but panics.

```go
func main() {
	text := "It was a boat. A small boat."
	match, err := regexp.MatchString("[A-z]oat", text)
	if err == nil {
		fmt.Println(match)
	} else {
		fmt.Println(err)
	}
}
```

### Compiling and reusing Patterns

The `MatchString`is simple -- but the full power of regexp is accessed through the `Compile`-- which compiles a regular expression pattern so that it can be reused lke:

```go
func main() {
	text := "It was a boat. A small boat."
	pattern, compileErr := regexp.Compile("[A-z]oat")
	question := "Is tht a goat"
	preference := "I like oats"

	if compileErr == nil {
		fmt.Println("Desc", pattern.MatchString(text))
		fmt.Println("Question", pattern.MatchString(question))
		fmt.Println("Preference", pattern.MatchString(preference))
	} else {
		fmt.Println(compileErr)
	}
}

```

`Regexp`type also provides methods that are used to process byte slices and methods that deal with readers, which are part of the go support for I/O and which are described -- like:

`MatchString(s), FindStringIndex(s), FindAllStringIndex(s, max)`

### Splitting using regexp

```go
func main() {
	text := "It was a boat. A small boat."
	pattern := regexp.MustCompile(" |boat|one")
	split := pattern.Split(text, -1)
	for _, s := range split {
		if s != "" {
			fmt.Println(s)
		}
	}
}

```

### Formatting and Scanning strings

Describe the stdlib features for formatting and scanning strings. like:

- `%v`-- this displays the *default* format for the value. Modifiying the verb with a `%+v`includes the field names
- `%#v`-- displays a value in a *format that could be used to re-create the value* in Go code file.
- `%T`-- displays the Go type of a value

```go
func Printfln(template string, values ...interface{}) {
	fmt.Printf(template+"\n", values...)
}

func main() {
	Printfln("%v", Kayak)
	Printfln("%+v", Kayak) // show key
	Printfln("%#v", Kayak) // show package name
	Printfln("%T", Kayak)
}
```

And the `fmt`package supports custom custom formatting through an interface named `Stringer`like:

```go
type Stringer interface{
    String() string
}
```

So the `String`method specified by the `Stringer`interface will be used to obtain a string representation of any type that defines it. like:

```go
func (p Product) String() string {
	return fmt.Sprintf("Product: %v, Price: $%4.2f", p.Name, p.Price)
}

func main() {
	fmt.Printf("%v", Kayak)
}
```

### Using the Integer Formatting Verbs

`%b, %d, %o, %O, %x, %X`

and for the Float -- `%g`-- adapts to the value it displays-- the `%`format is used for values wtih large exponents. -- `%G`-- this also adpats to the value it displays. The `%E`format is sued for values with large expontens.

### Using the String and Character Formtting Verbs

`%s, %c, %U`, %U for the Unicode format so that the output begins with `U+`followed by a hex. The boolean using the `%t`-- this formats `bool`values and displays `true`for `false`.

For the pointer value -- `%p`-- displays a hex represrentation of the pointer’s storage location.

### Scannig strings

The `fmt`provides functions for scanning strings, which is just the process of parsing strings that contain values spearted spaces. like:

- `Scan(...vals)`-- reads text from the stdin and stores the space-seprated into specified args. -- Newline are treated as spaces
- `Scanln(..vals)`-- Stops reading when it encounters a \n
- `Scanf(template, ...vals)`-- uses a tempalte string to select the values form the input receives
- `Fscn(reader, ...vals)`-- reads space-separted values from the specifeid reader.
- `Fscanln(reader, ...vals)`-- works in the same way as `Fsacn`
- `Fscanf(reader, template, ...vals)`-- select the values from the input it receives.
- `Sscan(str, ...vals)`-- scans the specified string for space-separated values.
- `Sscanf(str, template, ...vals)`-- function works in the same way as `Sscan`but uses a template to select values from the string
- And `Sscanln()`

```go
func main() {
	var name string
	var category string
	var price float64

	fmt.Print("Enter text to scan")
	n, err := fmt.Scan(&name, &category, &price)
	if err == nil {
		Printfln("Scanned %v values", n)
		Printfln("Name: %v, category: %v, price: %.2f", name, category, price)
	} else {
		Printfln("error: %v", err.Error())
	}
}
```

And the `Scan`has to convert the substrings it receives into Go values and will report an error if the string cannot be porcessed.

### Scanning into a Slice

If need to scan a series of values with the same type, the natural approach is to scan into a slice or an array like:

```go
vals := make([]string, 3)
fmt.Scan(vals...) // error
```

Won’t compile cuz the string slice can’t be propertly decompoesd for use with the variadic parameter like: Additional step is just requird like:

```go
ivals := make([]interface{},3)
for i:=0; i<len(vals); i++ {
    ivals[i]=&vals[i]
}
fmt.Scan(ivals...)
```

### deailing with NewLine characters

By default, scanning treats nielines in the same way as spaces, acting as separtors between values. The newLine will terminate the input, leving the `Scanln`with fewer values than it requires.

The funtions scan strings from 3 sources, the std input, a reader and value provided as an argument. Providing a string as the arg is the most flexible cuz it means the string can arise from anywhere.

```go
source := "Lifejacket Watersports 48.95"
n, err := fmt.Sscanln(source, &name, &category, &price)
```

So the first argument to the `Sscan`is the string to scan, but in all other respects, the scanningprocess is the same.

### using a Scanning Template

A template can be used to scan for values in a string that contains characters that are not required, like:

```go
source := "Product Lifejacket Watersports 48.95"
template := "Product %s %s %f"
n, err := fmt.Sscanf(source, template, &name, &category, &price)
```

## Cond

The command for the `Cond`type really does a great job of describing its purpose. A rendezvous point for goroutines waiting for or announcing the occurrence of an event.

It would be better if there were some kind of way for a goroutine to efficiently sleep until it was signalized to wake and check its condition -- This is exactly whtat the `Cond`type does -- using a `Cond`could write:

```go
func main() {
	c := sync.NewCond(&sync.Mutex{})
	c.L.Lock()
	for conditionTrue()==false {
		c.Wait()
	}
	c.L.Unlock()
}
```

1) The `newCond`takes in a type that satifsifes the `sync.Locker`interface, this is what allows the `Cond`type to facilitate coordination with other goroutines in a concurrent-safe way.
2) There we lock the `Locker`for this condition, this is necessary cuz the call to `Wait`automatically calls `Unlock`on the `Locker`when entered.
3) Then wait to be notified that the condition has occurred. This is a blocking call and the goroutine will be suspended.
4) Then could unlock the `Locker`for this condition.

This approach is *much more* effciient -- call to `Wait`doesn’t just block -- it `suspends`the current goroutine, allowing other to run on the OS threads. A few other things happen when call `Wait`-- upon entering `Wait`, `Unlock`is called on the `Cond`Locer -- upon exiting `Wait`, `Lock`is called.

```go
func main() {
	c := sync.NewCond(&sync.Mutex{})
	queue := make([]interface{}, 0, 10)
	removeFromQueue := func(delay time.Duration) {
		time.Sleep(delay)
		c.L.Lock()
		queue = queue[1:]
		fmt.Println("Removed from queue")
		c.L.Unlock()
        // just let know sth happened
		c.Signal()
	}
	for i := 0; i < 10; i++ {
		c.L.Lock()
		// check the len of the queue in a loop
		// waiting for has occurred
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
func main() {
	var count int
	increment := func() {
		count++
	}
	var once sync.Once

	var increments sync.WaitGroup
	increments.Add(100)
	for i := 0; i < 100; i++ {
		go func() {
			defer increments.Done()
			once.Do(increment)
		}()
	}
	increments.Wait()
	fmt.Print(count) // 1
}
```

Noticed that the `sync.Once`variable -- and what we’re somehow wrapping the call to increment within the `Do()`method of `once`. And as the name implies, `sync.Once`is a type that utlizes some `sync`primitives internally to ensure that only one call to `Do`ever calls the fucntions passed in.

### Pool

Is a concurrent-safe implementation of the objct pool pattern. A complete expan-- Since `Pool`resides in the `sync`-- At its high level, a the pool pattern is a way to create and make available a fixed number, or pool, of things for use.

### Channels

Are one of the sync primitives in Go CSP -- A channel serves as a conduit of a strem of info -- values may be passed along the channel, and then read out downstream. Usually end my `chan`names with `Stream`. When using channels, U’ll pass a value into a `chan`varaible, and thensomwhere else red it off the channel. Note that the disparate parts of your progam don’t require knowledge of each other, only a reference to the same palce in memory where the channel resides. This can be done by passing references of channels around the program.

Creating a channel is very simple, here is an example that expands the creation of a channel out into its declaration and subsequent instantiation so that you can see what both look like:

```go
var dataStream chan interface{}
dataStream = make(chan interface{})
```

Upon which any value can be written or read -- Cahnnels can also be declared to only support a unidirectional flow of data -- this is can define a channel that only supports sending or receiving info.

To decalre a unidirectional channle, simply include the `<-`operator, to both declare and instantiate a channel that can only read, place the `<-`operator on the left-side.

Just keep in mind that channels are typed -- in the example, create a `chan interface{}`variable, which means that you can palce any kind of data onoto it. can also give it a stricter type to constain the type of data it could pass along.

```go
func main() {
	stringStream := make(chan string)
	go func() {
		stringStream <- "Hello"
	}()
	fmt.Println(<-stringStream)
}
```

This is just part of Go’s type system that allows to type-safety even when dealing with concurrency primitives -- Recall that eariler in the chapter we highlighted the fact just cuz a goroutine was scheduled. This example works cuz channels in Go are said to be blocking -- this means that any goroutine that attempts to write to a channel that is full will wait until the channel has been empited.

So, this can cause deadlocks if you don’t structure your program correctly, take a look at the following example --which introduces a nonsensical conditional to prevent the anonymous goroutine from placing a value on the channel like:

```go
stringStream := make(chan string)
go func(){
    if 0!=1{
        return
    }
    stringStream <- "Hello"
}()
fmt.Println(<-stringStream)
```

For this, the main is waiting for a value to be placed onto the `stringStream`channel, and cuz of our conditional will never happen. like:

```go
stringStream := make(chan string)
go func(){
    stringStream <- "Hello"
}()
sal, ok := <-stringStream
```

So the second return value is a way for a read operation to indicate whether the read off the channel was a value generated by a write elsewhere in the progress - or a default value generated from a closed channel. This helps downstream processes know when to move on...  We could accomplish this with a special sentienl value for each type, this would duplicate the effort for all developers really a function of the channel and not the data type -- so closing a channel is like a universal sentinel that says - upstream isn’t going to be writing any more values. like:

```go
valueStream := make(chan interface{})
close(valueStream)
```

```go
intStream := make(chan int)
close(intStream)
integer, ok := <-intStream
fmt.Printf("(%v): %v", ok, integer) // (false) 0
```

Noticed that never placed anything on this channel, closed it immediately, were still able to perform a read operation, and in fact, could continue performing reds on this channel indefinitely despite the channel remaining closed. This opens up a few new patterns for us, -- *ranging* over a channel -- the `range`like:

```go
func main() {
	intStream := make(chan int)
	go func() {
		defer close(intStream)
		for i := 1; i <= 5; i++ {
			intStream <- i
		}
	}()
	for integer := range intStream {
		fmt.Println(integer)
	}
}
```

