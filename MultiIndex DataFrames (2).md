# MultiIndex DataFrames (2)

So far, explored the 1d Series and the 2d Dataframe. The number of dimensions is the number of reference points we need to extract a vlaue from a DS. Fore, need two reference points to locate a value in DF. A label/index for rows and label/index for the columns. Pandas supports data set with any number of dimensions through use of a `MultiIndex`

A `MultiIndex`is an index object that holds multiple levels. Each level stores a value for a row. It is also optimal to use a `MultiIndex`when a combination of values provides the best identifier for a row of data. And a `MultiIndex`is also ideal for *hierarchical* data.  FORE, want to model a street address, an address typically includes a street name, city, town, and zip code, could store these four elements in a tuple.

And Series and Df indices can hold various data types, all these objects can store only one value per index position, now imagine tuples serving as a DF’s index labels,  Can create a `MultiIndex`object independently of `Series`and `DataFrame`-- This class is available as a top-level attribute on the pandas library. It includes a `from_tuples`class method that instantiates a `MultiIndex`from a list of tuples.
`pd.MultiIndex.from_tuples(addresses)`

Not have our `MultiIndex`-- which stores three tuples of 4 elements each. The collection of tuple values as the same position forms a *level* of the `MultiIndex`. Can also assign each `MultiIndex`level a name by passing a list of `from_tuples`names parameter.

```python
pd.MultiIndex.from_tuples(addresses, 
                          names=['Street', 'City', 'State', 'Zip'])
```

A `MultiIndex`is just a storge container in which each label holds multiple values -- A level consists of the vlaues at the same position across the labels. Now have this `MultiIndex`attach it to a DF -- the eaiest way is to use the DF ctor’s `index`parameter -- passed this parameter a list of strings in earlier -- also accepts any valid index object.

```python
data=[
    ['A', 'B+'],
    ['C+', 'C'],
    ['D-', 'A'],
]
columns = ['Schools', 'Cost of living']
area_grades= pd.DataFrame(
    data=data, index=row_index, columns=columns
)
area_grades
```

For this, have a Df with a `MultiIndex`on its row axis -- each row’s label holds 4 values. Pandas currently stores the two column names in a single-level `Index`object, fore, next invokes the `from_tuples()`pass a list of 4 tuples.

```python
column_index = pd.MultiIndex.from_tuples(
    [
    ("Culture", "Restaurants"),
    ("Culture", "Museums"),
    ("Services", "Police"),
    ("Services", "Schools"),
]
) 
column_index
```

Can attach both of our `MultiIndexes`to a DF -- The `MultiIndex`for the row axis requirs the data hold 3 rows, and the `MultiIndex`for the column axis require 4 columns like:

`pd.DataFrame(data= data, index=row_index, columns=column_index)`

### MultiIndex DataFrames -- 

For the csv, is similar to the one -- Here is a comma separates every two subsequent values in a row data. just: If a header slot does not have a value, pandas assigns a title of `Unnamed`to the column, the library tries to avoid dupliate column names. And to distinguish between multiple missing headers, the library adds a numerical index to each. Thus, we have 3 Unnamed column, And the CSV file has the same value of `Culture`, so just `Culture.1`named.

And in row 0, each of the first 3 columns holds a `NaN`- The issue is that the csv is trying to model a multi-level row index and a multilevel column index -- but the default arguments to the `read_csv`function’s parameters don’t recognize it.

First, have to tell pandas that the 3 leftmost columns should serve as the index of the DF. Can do this by passing the `index_col`a list of numbers, each one representing the index of a column that should be in the DataFrame’s index. And also note the index of a column should in the DF’s index -- the index starts counting from 0. Thus, the first three columns will have index position 012-- like:

```python
neighborhoods = pd.read_csv('../pandas-in-action/chapter_07_multiindex_dataFrames/neighborhoods.csv',
                            index_col=[0,1,2])
neighborhoods
```

Next, need to tell pandas which data set rows we’d like to use for our DF’s headers -- (columns) -- the `read_csv`*assumes* that only the first row will hold the headers. In this, but the first two will hold the **headers**, we can use the `header`parameter -- which accepts a list of integers representing the *row* that pandas should set as column headers.

```python
neighborhoods = pd.read_csv('../pandas-in-action/chapter_07_multiindex_dataFrames/neighborhoods.csv',
                            index_col=[0,1,2],
                            header=[0,1])
neighborhoods
```

As mentioned - the data set groups 4 characteristics of in two categories. When have a parent category encompassing smaller child categories, creating a `MultiIndex`is an optimal way to enable quick slicing. And notice that pandas prints each column’name as a 2-element tuple. Can can also access the DF’s `MultiIndex`object with the familar `index`attribute. `neighborhoods.index`, can also : `neighborhoods.columns`, also returns a multiIndex. 

Under its hood, pandas composes a `MultiIndex`frrom multiple `Index`objects.
`neighborhoods.index.names`

Can access the list of index names with the `names`attribute on the `MultiIndex`object. Note that pandas assigns an order to each nested level within the `MultiIndex`--the `get_level_values()`extracts the `Index`at a given level.

`neighborhoods.index.get_level_values(0)`

And the column’s level do not have any names cuz CSV did not provide any. Can access the column’s `MultiIndex`with `columns`attribute, can assign a new list of column names to the `names`attribute of the `MultiIndex`object -- like: `neighborhoods.columns.names=['Category', 'Subcategory']`

The level names will appear to the left of the column.

And a `MultiIndex`will carry over to new objects derived form a data set.
`neighborhoods.nunique()` -- 13 A+To F.

### Sorting a multiindex

Pandas can find a value in an ordered collection much quicker than in jumbled one. When invoke `sort_index`on a `MultiIndex DataFrame`-- pandas sorts all levels in ascending order and proceeds from the outside in.

And the `sort_values()`includes an `ascending`can pass the parameter a Boolean to apply a consisitent sor torder to all `MultiIndex`levels. And suppose want to vary the sort order for different levels. Just like:

```python
neighborhoods.sort_index(ascending=[True, False, True]).head()
# can also sort by itself, using the level parameter like:
neighborhoods.sort_index(level=1) # level = "city"

#level also accepts a list of levels like:
neighborhoods.sort_index(level=[1,2])

# can also combine the ascending and level like:
neighborhoods.sort_index(level=['City', 'Street'], ascending=[True, False])
```

Closing a channel is also one of the ways can signal multiple goroutines simultaneously. If have n goroutines waiting on a single channel, instead of writing `n`times to channel to unblock -- can simply close the channel. Since a closed channel can be read from an infinite number of times, it doesn’t matter how many goroutines are waiting on it. FORE:

```go
begin := make(chan any)
var wg sync.WaitGroup
for i:=0; i<5; i++ {
    wg.Add(1)
    go func(i int) {
        defer wg.Done()
        <- begin
        fmt.Printf(...)
    }(i)
    Printfln(...)
    
    // signal to continue
    close(begin)
    wg.Wait()
}
```

Can also create *buffered* channels, which are channels that are given a capacity when are instantiated. This means that even if no reads are performed on the channel, a goroutine can still perform `n`writes, where `n`is the capacity of the buffered channel. like:

```go
var dataStream chan any
dataStream = make(chan any, 4)
```

This means that we can place 4 things onto the channel regardless of whether it’s being read from. Unbuffered channels are also defined in terms of buffered channels -- an unbuffered channel is simply a buffered channel created with a capacity of 0. When discussed blocking, said that writes to a channel block if a channel is full, and reads from a channel block if the channel is empty.

It also bears mentioning that if a buffered channel is empty and has a receiver, the buffer will be bypassed and the value will be passed directly from the sender to the receiver. Buffered can be useful in certain situations -- but should create them with care. Can easily become premature optimazation and also hide deadlocks. FORE:

```go
func main() {
	var stdoutBuffer bytes.Buffer
	defer stdoutBuffer.WriteTo(os.Stdout)

	intStream := make(chan int, 4)
	go func() {
		defer close(intStream)
		defer fmt.Fprintln(&stdoutBuffer, "Producer Done.")
		for i := 0; i < 5; i++ {
			fmt.Fprintf(&stdoutBuffer, "Sending %d\n", i)
			intStream <- i
		}
	}()
	for integer := range intStream {
		fmt.Fprintf(&stdoutBuffer, "Received %v.\n", integer)
	}
}
```

created an in-memory buffer to help mitigate the non-deterministic nature of the output. This is an example of an optimiazaiotn that can be useful under the right condition -- if a goroutine making writes to a channel has knowledge of how many writes it will make, can be useful to create a buffered channel whose cap is the number of writes to be made.

```go
var dataStream chan any
<-dataStream // panics
```

Namely, reading from a `nil`will block a program and:

```go
var dataStream chan any 
dataStream <- struct{}{}
```

Also, deadlock -- wirtes to a `nil`will also block.

And close a `nil`also panics FORE:

```go
func main() {
	chanOwner := func() <-chan int {
		resultStream := make(chan int, 5)
		go func() {
			defer close(resultStream)
			for i := 0; i <= 5; i++ {
				resultStream <- i
			}
		}()
		return resultStream
	}
	resultStream := chanOwner()
	for result := range resultStream {
		fmt.Printf("Recieved: %d\n", result)
	}
	fmt.Println("Done Receiving")
}
```

Look at an example to help clarily these - create a goroutine that clearly owns a channel, and a consumer that clearly handles blocking and closing a channel.

And notice how the lifecycle of the `resultStream`channel is encapsulated within the `chanOwner`func.

### The `select`statement

The `select`is the glue that binds channels together -- it’s how we are able to compose channels together in a program to form larger abstrction. If channels are the glue that binds goroutines together, that does that say about the `select`-- Can find `select`statements binding together channels locally, within a single functoin or type. As:

```go
func main() {
	var c1, c2 <-chan any
	var c3 chan<- any

	select {
	case <-c1:
	// do sth
	case <-c2:
	// do sth
	case c3 <- struct{}{}:
		// do sth
	}
}
```

Just like a `switch`-- a `selet`block encompasses a series of `case`statements that guard a series of statements -- however, that is where the similarties end. Unlike `switch`, `case`statements in a select blocks aren’t tested sequentially, and execution won’t automatically fall through if none of the criteria are met.

Instead, all channel reads and writes are considered simultantously to see if any of them are ready. Populated or closed channels in the case of reads, and channels that are not at capacity in the case of writes.

```go
func main() {
	start := time.Now()
	c := make(chan any)
	go func() {
		time.Sleep(5 * time.Second)
		close(c)
	}()

	fmt.Println("Blocking on read...")
	select {
	case <-c:
		fmt.Printf("unblocked %v later. \n", time.Since(start))
	}
}
```

As can see, unblock roughly 5 seconds after entering the `select`block. This is a simple and efficient way to block while are waiting for sth to happen. But if we reflect for a moment we can come up with some questions -- 

- what happens when multiple channels ahve sth to read.
- What if there are never any channels that become ready
- What if we want to do sth but no channels are currently ready.

for 1st question -- try:

```go
func main() {
	c1 := make(chan any)
	close(c1)
	c2 := make(chan any)
	close(c2)

	var c1Count, c2Count int
	for i := 0; i < 1000; i++ {
		select {
		case <-c1:
			c1Count++
		case <-c2:
			c2Count++
		}
	}
	fmt.Printf("c1Count: %d\nc2Count: %d\n", c1Count, c2Count)
}
```

Roughly half the time the `select`statement read from c1 and c2. The Go runtime will perform a psedudo-random uniform selection over the set of case statements. The Go runtime cannot know anything about the intent of your `select`statement -- cannot infer your problem space or why you placed a group of channels together into a `select`statement.

And what happens if there are never any channels that become ready -- if there is nothing useful you can do when all the channels are blocked -- but also can’t block forever, may want to timeout. Fore, Go’s `time`package provides an elegant way to do this with channels that fits nicely within the paradigm of the `select`statement like:

```go
var c <-chan int
select {
case <-c:
    case <-time.After(time.Second):
    fmt.Println("Time out")
}
```

So the `time.After`takes in a `time.Duration`and returns a channel that send the current time after the duration you provide it. This offers a concise way to time out in `select`. And like this:

```go
start:= time.Now()
var c1, c2 <-chan int
select {
    case <-c1:
case <-c2:
default:
    fmt.Printf("In default after %v\n\n", time.Since(start))
}
```

Can see it ran the `default`statement almost instanteously -- this allows you to exit a select block without blocking. This allows you to exit a `select`without blocking. And usually you will see a `default`clause used in conjunction with a `for-select`loop, this allows a goroutine to make progress on work while waiting for another goroutine to report a result, here is an example like:

```go
func main() {
	done := make(chan any)
	go func() {
		time.Sleep(5 * time.Second)
		close(done)
	}()

	workCounter := 0
loop:
	for {
		select {
		case <-done:
			break loop
		default:
		}
		workCounter++
		time.Sleep(time.Second)
	}
	fmt.Printf("Achieved %v cycles\n", workCounter) // 5
}

```

And there is a special case for empty `select`-- with no `case`-- `select {}`will simply block forever.

## Using the Optional Conditional Actions

The `if`can be used with optional `else`and `else if`like:

```html
{{range . -}}
    {{if lt .Price 100.00 -}}
        <h1>Name: {{.Name}}, Category: {{.Category}}, Price,
            {{- printf "$%.2f" .Price}}</h1>

    {{ else if gt .Price 1500.00 -}}
        <h1>Expensive product {{.Name}} ({{printf "$%.2f" .Price}})</h1>
    {{ else -}}
        <h1>Midrange Product: {{.Name}} ({{printf "$%.2f" .Price}})</h1>
    {{end -}}
{{end}}
```

### Creating Named Nested Templates -- 

The `define`action is used to create a nested template that can be executed by name, which allows content to be defined once and used repeatedly like that...