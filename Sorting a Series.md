# Sorting a Series

Can sort a `Series`by its values or its index, in ascending or descending order. The `sort_values()`just returns a new `Series`with the values sorted in ascending order.  The `na_position`parameter configures the placement of `NaN`values in the returned `Series`and has a default arg of `last`. And to display the missing values first, just pass the `na_position`an arg of `first`. like:
`battles.sort_values(na_position="first")`

Remove `NaN`-- the `dropna()`returns a series with all missing removed like:
`battles.dropna().sort_values()`

### Sorting by index wiht the `sort_index`

Focus may lie in the index rather than the values. Can sort a `Series`by index as well with the `sort_index()`method. Also accepts an `ascending`parameter, and its default arg is also `True`.

```python
pokemon.sort_index()
pokemon.sort_index(ascending=False)
```

When sorting a collection of datetimes in ascending orer, pandas sorts from the earliest date to the latest. like:

`battles.sort_index()`

Pandas uses another `NaT`which expresses the missing date values -- The `NaT`object maintains data integrity with the index’s datetime type. The `sort_index()`also includes the `na_position`parameter for altering the palcement of `NaN`values.

### Retrieving the smallest and largest values with the smallest and nlargest methods

`google.sort_values(ascending=False).head()`-- the operation common -- so Offers a helper method to save us a few characters -- the `nlargest()`returns the largest values from a `Series` -- its first parameter - `n`sets the number of records to return like:
`google.nlargest(5)`and `google.nsmallest(5)`

Overwriting with inplace parameter -- like:
`battles.sort_values(inplace=True)`

The short answer is that immutable data structures tend to lead to fewer bugs. Can copy an immutable object and manipulate the copy, can’t alter the original object. So the pandas development team has discussed removing the `inplace`parameter.

### Counting values wiht the `value_counts()`

Find out the fore, most common types -- Need to group the values into buckets and count the number of elements in each bucket. The `value_counts()`-- which counts the number of occurrences of each `Series`value, solves the problem perfectly.  `pokemon.value_counts()`returns a new `Series`object -- the index labels are the pokemon Series’ values and the values are their respective counts. So the lenght of the value_counts Series is equal to the number of unique values in the `pokemon`Series.

```python
len(pokemon.value_counts())
pokemon.nunique()
```

Also `ascending`parameter has a default arg of `False`, so if want to sort that ascendingly, just:
`pokemon.value_counts(ascending=True)`

May be more interested in their ratio of type relative to all the types.
`pokemon.value_counts(normalize=True).head()*100`
`(pokemon.value_counts(normalize=True)*100).round(2)`

The `value_counts`operates identically on a numeric `Series`-- the next example counts the occurrences of each unique stock price like:

```python
buckets= [0, 240, 400, 600, 800, 1000, 1200, 1400]
google.value_counts(bins=buckets)
# note that the (] 
```

Also note that pandas sorted the `Series`in descending order by the number of values in each bucket. What if wanted to sort the results by the interval instead -- simply have to mix and match a few pandas methods. like:
`google.value_counts(bins=buckets, sort=False)`

### Invoking a func with `apply`

A function is first-class object in python -- which means that the language treats it like any other data type. fore:

- Store a function in a list
- Assign func as a value for dict key
- Pass a func into another func as an arg
- Return a func from another func

```python
funcs = [len, max, min]
for current_func in funcs:
    print(current_func(google))
```

Wouldn’t it be great if we could apply this `round`function to every value in series -- Called `apply`that invokes a function once for each `Series`value and returns a new `Series`consisting of the return values of the function invocations. like: `google.apply(round)`.

Just note that the `apply`method also accetps custom functions -- Define the function to accet a **single** parameter and have it return the value that you’d like pandas to store in the aggregated series. A func is an ideal container for encapsulating the logic. Fore:

```python
pokemon.apply(lambda pokemon_type: "Multi" if 
              '/' in pokemon_type else "Single")
```

### Problems

If have a single datetime object, can invoke the `strftime`method on it with an argument of `%A`to return the day of a week a date falls on -- like:

```python
import datetime as dt
today= dt.datetime.now()
today.strftime('%A')
```

reimport the revolutionary_war.csv data set and remind ourselves of its original shape like:

```python
days_of_war = pd.read_csv(
    "../pandas-in-action/chapter_03_series_methods/revolutionary_war.csv",
    usecols=['Start Date'],
    parse_dates=['Start Date'],
).squeeze()
```

Next challenge is extracting the day of week for each date. One solution is to pass each `Series`valeu to a function that will return the date’s day of the week -- declare that function like:

```python
days_of_war.dropna().apply(lambda date: date.strftime('%A'))
```

## Using Notifications as Timeout in `select`statements

The `After`func can be used with `select`statements to provide a timeout like:

```go
func writeToChannel(channel chan<- string) {
    //...
    <- time.After(time.Second*2)
    names := []string{...}
    for _, name := range names {
        channel <- name
        time.Sleep(time.Second*3)
    }
    close(channel)
}

func main(){
    nameChannel := make(chan string)
    go writeToChannel(nameChannel)
    channelOpen := true
    for channelOpen {
        select {
            case name, ok := <-nameChannel:
            if !ok {
                channelOpen=false
                break
            }else {
                Printfln("Read name: %v", name)
            }
            case <- time.After(time.Second*2):
            Printfln("timeout")
        }
    }
}
```

The `After`func creates a channel that blocks for a specified period.

### Stopping and Resetting Timers

The `After`is useful when are sure that you will always need the timed notification. And, if need the option to cancel the notification -- then the func `NewTimer(duration)`used instead. Like:

`NewTimer(duration)`-- this returns a `*Timer`with specified period.

And for the result `*Timer`struct which defines the methods described:

- `C`-- returns the channel over which the `Time`will send its Time value
- `Stop`-- stops the timer
- `Reset(duration)`-- stops a timer and resets it so that its interval is the specified `Duration`.

```go
func writeToChannel(channel chan<- string) {
    timer := time.NewTimer(time.Minute*10)
    go func() {
        time.Sleep(time.Second*2)
        Printfln(...)
        time.Reset(time.Second)
    }()
    
    <- timer.C // first, after 10m, but reset to 1s
    ...
}
```

### Receiving Recurring Notifications

The `Tick`function returns a channel over which `Time`values are sent at a specified interval like:

```go
func writeToChannel(channel chan<- string) {
	names := []string{"Alcie", "Bob", "Charlie", "Dora"}
	tickChannel := time.Tick(time.Second)
	index := 0
	for {
		<-tickChannel
		channel <- names[index]
		index++
		if index == len(names) {
			index = 0
		}
	}
}
```

And the `Tick`function is useful when an indefinite sequence of signals is required. If a *fixed series of values* is required, then the function described is used instead like:

`NewTicker(duration)`-- returns a `Ticker`with the specified period. Also has:

- `C`-- returns the channel over which the `Ticker`will send its `Time`values
- `Stop()`-- stops the ticker
- `Reset(duration)`-- stops a ticker and resets it so that its interval is the specified `Duration`.

```go
func writeToChannel(channel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	ticker := time.NewTicker(time.Second / 10)
	index := 0
	for {
		<-ticker.C
		channel <- names[index]
		index++
		if index == len(names) {
			ticker.Stop()
			close(channel)
			break
		}
	}
}
```

So the approach is useful when an application needs to create multiple tickers without leaving those that are no longer required sending messages.

## Reading and Writing Data

Describe two of the most important **interfaces** defined by the stdlib - the `Reader`and the `Writer`interfaces -- these are used wherever data is read or written.

- Defines the basic methods required to read and write data
- Means that jsut about any data source can be used in the same way -- while still allowing specilized features to be defined using the composition features.
- The `io`package defines these interfaces -- but the implementations are available from a range of other packages.

### Understanding Readers and Writers

Are defined by the `io`package and provide abstract ways to read and write data -- without being tied to where the data is coming from or going to.

- `Read(byteSlice)`-- reads data into the specified `[]byte`-- returns the number of bytes were read. expressed as an `int`and an `error`.

Doesn’t include any detail about where data comes from or how it is obtained -- just defines the `Read`method. FORE:

```go
func processData(reader io.Reader) {
	b := make([]byte, 2)
	for {
		count, err := reader.Read(b)
		if count > 0 {
			Printfln("Read %v bytes: %v", count, string(b[0:count]))
		}
		if err == io.EOF {
			break
		}
	}
}

func main() {
	r := strings.NewReader("Kayak")
	processData(r)
}
```

Each type of `Reader`is created differently. Fore the `strings.NewReader("Kayak")`-- Use the result from the `NewReader`function as an argument to a function that accepts an `io.Reader`-- within the func -- use the `Read`to read bytes of data.

Just note that the `io`package defines a special `error`named `EOF`-- which is used to signal when the `Reader`reaches the end of the data -- if the `error`result from the `Read`is equal to the `EOF`error - then just break out of the `for`.

### Writers

- `Write(byteSlice)`-- writes the data from the specified byte -- returns the number of bytes. Write to itself.

```go
func processData(reader io.Reader, writer io.Writer) {
	b := make([]byte, 2)
	for {
		count, err := reader.Read(b)
		if count > 0 {
			writer.Write(b[0:count])
			Printfln("Read %v bytes: %v", count, string(b[0:count]))
		}
		if err == io.EOF {
			break
		}
	}
}

func main() {
	r := strings.NewReader("Kayak")
	var builder strings.Builder
	processData(r, &builder)
	Printfln("String builder contents: %s", builder.String())
}

```

Which means that can write bytes to a `Builder`and then calls its `String()`to create a string from thsoe bytes. And just note that used the address operator to pass a pointer to the `Builder`to the `processData`. Like:

`processData(r, &builder)`-- As a general rule, the `Reader`and `Writer`methods are implemented for pointers so that passing a `Reader`or `Writer`to a func doesn’t create a copy. And the `NewReader()`is just a pointer.

### Using the Utility Functions for Readers and Writers

And the `io`package contains a set of funcs that provide additional ways to aread and write data like:

- `Copy(w,r)` -- copies data from a `Reader`to a `Writer`
- `CopyBuffer(w, r, buffer)`-- same like before but reads into the buffer before passed to writer
- `CopyN(w, r, count)`
- `ReadAll(r)`-- reads from Reader until EOF is reached.
- `ReadAtLeast(r, byteslice, min)`read from `r`, placing them into byteSlice.
- `ReadFull(r, byteSlice)`fills the specified byteSlice.
- `WriteString(w, str)`-- Writes the specified `string`to a writer.

```go
func processData(reader io.Reader, writer io.Writer) {
	count, err := io.Copy(writer, reader)
	if err == nil {
		Printfln("read %v bytes", count)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

### Using the specialized Readers and Writers

In addition to the basic `Reader`and `Writer`interface, the `io`provides some specialized implementation that are described and demonstrated in the sections that follow.

- `Pipe()`-- returns a `PipeReader`and `PipeWriter`-- used to connect functions
- `MultiReader(), MultiWriter(), LimitReader()`

The `PipeReader`and `PipeWriter`structs implement the `Closer`interface, defines the method like:

- `Close()`-- closes the reader or writer -- in general, any subsequent reads from a closed `Reader`will return 0 bytes, and EOF error, and any subsequent writes to closed will return an error.

### Buffering Data

Note that the `bufio`package provides support for adding buffers to readers and writers -- to see how data is processed without a buffer, add a file named `custom.go`to the like:

```go
package main

import "io"

type CustomReader struct {
	reader    io.Reader
	readCount int
}

func NewCustomReader(reader io.Reader) *CustomReader {
	return &CustomReader{reader, 0}
}

func (cr *CustomReader) Read(slice []byte) (count int, err error) {
	count, err = cr.Read(slice)
	cr.readCount++
	Printfln("Custom Reader : %v bytes", count)
	if err == io.EOF {
		Printfln("Total reads: %v", cr.readCount)
	}
	return
}

```

The code defined a struct type named `CustomReader`that acts as a wrapper around a reader -- The implemenation of the `Read`method generates outpout that reports much data is read and how many read operations are performed overall.

```go
func main() {
	text := "it was a boat. A small boat."
	var reader io.Reader = NewCustomReader(strings.NewReader(text))
	var writer strings.Builder
	slice := make([]byte, 5)
	for {
		count, err := reader.Read(slice)
		if count > 0 {
			writer.Write(slice[0:count])
		}
		if err != nil {
			break
		}
	}
	Printfln("read data : %v", writer.String())
}
```

The `newCustomeReader()`is used to create a `CustomReader`that reads from a string and uses a `for`loop to consume the data using a byte slice. In this case, the size of the slice is 5 -- which means that a maximum of 5 bytes is read produced 3 bytes.

Reading small amount of data can be problematic when there is a large amount of overhead associated with each operation. Like-- this isn’t an issue when just reading a string stored in memory -- but reading data from other data sources -- files... can be more expensive.

This is done by introducing a buffer  into which a large amount of data is read to service several smaller requests for data.

- `NewReader(r)`-- returns a buffered `Reader`with the default buffer size 4096bytes
- `NewReaderSize(r, size)`-- with the specified buffer size.

And the result produced by the `NewReader`and `NewReaderSize`implement the `Reader`interface but introduce a buffer.

```go
var writer strings.Builder
slice := make([]byte, 5)
reader = bufio.NewReader(reader)
```

Used the `NewReader`function which creates a `Reader`with the default buffer size -- the buffered `Reader`fills its buffer and uses the data it contains to respond to calls to the `Read`method.

### Using the Additional Buffered Reader Methods

Both return `bufio.Reader`-- which implement the `io.Reader`interface and which can be used as drop-in wrappers for other types of `Reader`methods.

- `Buffered()`-- returns an `int`indicates the number of bytes that can be read from the buffer.
- `Discard(count)`-- discards the specified number of bytes
- `Peek(count)`-- returns the specified number of bytes without removing from the buffer
- `Reset(reader)`-- discards the data and peroforms subsequent reads
- `Size()`-- returns the size of the buffer.

```go
buffered := bufio.NewReader(reader)
// reader = bufio.NewReader(reader)
for {
    count, err := buffered.Read(slice)
    if count > 0 {
        Printfln("Buffer size: %v, buffered: %v",
                 buffered.Size(), buffered.Buffered())
        writer.Write(slice[0:count])
    }
    if err != nil {
        break
    }
}
```

### performing Buffered Writes

The `bufio`package also provides support for creating writer that use a buffer, using the functions described like:

- `NewWriter(w)`-- returns a buffered `Writer`with the default buffer size.
- `NewWriterSize(w, size)`-- returns a buffered `Writer`with the specified buffer size.

The Methods like:

- `Available()`-- returns the number of available bytes in the buffer
- `Buffered()`
- `Flush()`-- Writes the contents of the buffer to the underlying `Writer`
- `Reset(writer)`-- discards the data in the buffer and performs subsequent writes to the specific writer.
- `Size()`