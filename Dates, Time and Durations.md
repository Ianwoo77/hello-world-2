## Dates, Time and Durations

- The features provided by the `time`packae are used to represent specific moments in time and intervals or durations.
- These features are useful in any app that needs to deal with calendaring or alarm and for the development of any feature that requires delays or notifications in the future.
- The `time`package defines data types for representing dates and individual units of time and functions for manipulating them

`Format, Parse, ParseDuration, Sleep, AfterFunc, After`functions.

### Working with Dates and Times

The `time`package provides features for measuring durations and expressing dates and times

- `Now()`Current moment
- `Date(y,m,d,h,min,sec,nsec,loc)`
- `Unix(sec,nsec)` -- create a `Time`value from the number of seconds and naoseconds.

```go
func Printfln(tempalte string, values ...interface{}) {
	fmt.Printf(tempalte+"\n", values...)
}

func PrintTime(label string, t *time.Time) {
	Printfln("%s: Day: %v:Month: %v; Year: %v", label, t.Day(), t.Month(), t.Year())
}

func main() {
	current := time.Now()
	specific := time.Date(1995, time.June, 9, 0, 0, 0, 0, time.Local)
	unix := time.Unix(1433228090, 0)

	PrintTime("Current", &current)
	PrintTime("Speific", &specific)
	PrintTime("UNIX", &unix)
}

```

### Formatting Times as Strings

The `Format`method is used to create formated strings from `Time`values. The format of the string is specified by providing a layout string, which shows which components of the `Time`are required and the order and precision with which thy shoud be expressed

```go
func PrintTime(label string, t *time.Time) {
	layout := "Day: 02 Month: Jan Year:2006"
	fmt.Println(label, t.Format(layout))
}
```

The layout string uses a reference time, which is 15:04:05 on Monday, in the MST time zone, which is 7 hours behind Greenwich mean time. Also like:

```go
func PrintTime(label string, t *time.Time) {
    fmt.Println(label, t.Format(time.RFC822Z))
}
```

### Parsing Time values from Strings

The `time`packge provides support for creating `Time`values from strings like:

- `Parse(layout, str)`-- this parses a stirng using the specified layout to create a `Time`value. An `error`is returned to indicate problems parsing the string.
- `ParseInLocation(layout, str, location)`-- This function prses a string, using the specified layout and using the Location if no time zone is included in the string. An `error`is returned to indicate problems parsing the string.

The function use a reference time -- which is used to specify the format of the string to be parsed, the reference time is 15:04:05 -- The compnents of the reference date are arranged to specify the layout of the date string that is to be parsed. Like:

```go
func main() {
	layout := "2006-Jan-02"
	dates := []string {
		"1995-Jun-09",
		"2015-Jun-02",
	}
	for _, d := range dates {
		time, err := time.Parse(layout, d)
		if err == nil {
			PrintTime("parsed", &time)
		}else {
			Printfln("Error: %s", err.Error())
		}
	}
}
```

The layout used in this includes a 4-digit year, 3-letter month, and 2-digit day, all separated with hyphens, the layout is passed to the `Parse`function along with the string to parse, and the function returns a time value and error that will detail any parsing problems.

### Using the Local Location

If the place name used to create a `Location`is `Local`-- then the time zone setting of the machine running the application is used just like:

```go
func main() {
    local, _ := time.LocalLocation("Local")
}
```

### Manipulating Time Values

The time package defines methods for working with `Time`values -- some of these methods rely on the `Duration`type, which describe -- 

- `Add(duration)`-- this adds the specific `Duration`to the `Time`and returns the result.
- `Sub(time)`-- this returns a `Ducation`that expresses the difference between the `Time`on which the method has been called and the `Time`provided as the argument.
- `AddDate(y, m, d)`-- this adds the specified number of yeard, months, and days to the `Time`and returns the result.
- `After(time)`-- returns `true`if the `Time`on which the method has been called occurs after the `Time`provided as the argument.
- `Before(time)`-- returns `true`if the `Time`on which the method has been called occurs before the `Time`provided as the argument.
- `Equal(time)`-- returns `true`if the `Time`on which the method has been called is equal to the `Time`provided as the argument.
- `IsZero()`returns `true`if the `Time`on which the method has been called represents the zeo-time instant.

```go
Printfln("After: %v", t.After(time.Now())
```

### Representing Durations

The `Duration`type is an alias to the `int64`type and is used to repreent a specific number of milllisecionds -- Custom `Duration`values are composed from constant `Duration`values defined in the `time`package like:

```go
func main() {
	var d time.Duration = time.Hour+(30*time.Minute)
	Printfln("hours: %v", d.Hours())
}

```

### Creating Durations Relative to a Time

The `time`package defines two functions that can be used to create `Duration`values that represent the amount of time between a specific `Time`and current `Time`-- as described as:

`Since(time)`-- returns a `Duration`expressing the elapsed time since the specified `Time`value

`Until(time)`-- Returns a `Duration`expressing the elapsed time until the specified time value

Creating Durations from strings -- The `time.ParseDuration()`parses strings to create `Duration`values. like:

`d, err := time.ParseDuration("1h30m")`

### Using the Time features for goroutines and Channels

The `time`package provides a small set of functions that are useful for working with goroutins and channels, as:

`Sleep(duraiton)`-- pause the current goroutine
`AfterFunc(duration, func)`-- executed the specified func in its own goroutine after the specified duration. The result is a `Timer`whose `Stop`method can be used to cancel the execution of the func before duration elapses.

- `After(duraiton)`-- returns a channel that blocks for sepcified duration and then yields a `Time`value.
- `Tick(duration)`-- returns a channel periodically sends a `Time`value.

### Deferring Execution of a Function

The `AfterFunc()`is used to defer the execution of a function for a specified period like:

```go
func writeToChannel(channel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
	}
	close(channel)
}

func main() {
	nameChannel := make(chan string)
	time.AfterFunc(time.Second*5, func() {
		writeToChannel(nameChannel)
	})
	for name := range nameChannel {
		Printfln("read name: %v", name)
	}
}
```

### Receiving Timed Notification

The `After`funciton waits for a specified duration and then sends a `Time`value to a channel, which is useful way of using a channel to receive a notification at a given future time.

```go
unc writeToChannel(channel chan<- string) {
	Printfln("Waiting for initial duration...")
	<-time.After(time.Second * 2)
	Printfln("initial duration elapsed.")
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
		time.Sleep(time.Second)
	}
	close(channel)
}

func main() {
	nameChannel := make(chan string)
	go writeToChannel(nameChannel)
	for name := range nameChannel {
		Printfln("read name: %v", name)
	}
}
```

So the result from the `After`function is a channel that carries `Time`values, the channel blocks for the specified duration, when a `Time`value is sent, indicating that duration has passed -- In this example, the value sent over the channel acts as a signal and is not used directly, which is why it is assigned to the.

This use of `After`function introduces an initial delay in `writeToChannel`funcitn, compile like: So the effect in this example -- The effect in this example is the same as using the `Sleep`function, but the difference is that the `After`function returns a channel that *doesn’t block until a value is read*, which means that a direction can be specified, additional work can be performed.

### Using notifications as Timeouts in Select statements

The `After`can be used with `select`statements to provide a timeout just like:

```go
func main() {
	nameChannel := make(chan string)
	go writeToChannel(nameChannel)
	channelOpen := true

	for channelOpen {
		Printfln("Starting channel read")
		select {
		case name, ok := <-nameChannel:
			if !ok {
				channelOpen = false
			} else {
				Printfln("read name : %v", name)
			}
		case <-time.After(time.Second * 2):
			Printfln("Timeout")
		}
	}
}
```

### Stopping and Resetting Timers

The `After`function is useful when you are sure that you will always need the timed notification.

- `NewTimer(duration)`-- This function returns a `*Timer`with the specified period.

The result of the `NewTimer`function is a pointer to a `Timer`struct, which defines the methods describes:

- `C`-- this field returns the channel over which the `Time`will send its `Time`value.
- `Stop()`-- this stops the timer, the result is a `bool`that will be `true`if the timer has been stopped and `false`if the timer has already sent its message.
- `Reset(duration)`-- this stops a timer and resets it so that its internal is the specified `Duration`.

```go
func writeToChannel(channel chan<- string) {
	timer := time.NewTimer(time.Minute * 10)

	go func() {
		time.Sleep(time.Second * 2)
		Printfln("Resetting timer")
		timer.Reset(time.Second)
	}()
	Printfln("Waiting for initial duration...")
	<-timer.C
	Printfln("initial duration elapsed.")
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
	}
	close(channel)
}
```

### Reciving Recurring Notifications

The `Tick`function returns a channel over which `Time`values are sent at a specifid interval, as demonstrated like:

```go
func writeToChannel(nameChannel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}

	tickChannel := time.Tick(time.Second)
	index := 0
	for {
		<-tickChannel
		nameChannel <- names[index]
		index++
		for index == len(names) {
			index = 0
		}
	}
}
```

So the `Tick`function is useful when an indefinite sequence of signals is required, if a fixed series of values is required, then the function can be used instead.

- `NeTicker(duration)`-- this function returns a `*Ticker`with specified period.

The result of the `NewTicker`function is a pointer to a `Ticker`struct, which defines the field and methods described like

- `C`-- this returns the channel over which the `Ticker`will send its `Time`values.
- `Stop()`-- this stops the ticker
- `Reset(duration)`-- stops a ticker and reset it so that its interval is the specified `Duration`.

```go
func writeToChannel(nameChannel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}

	ticker := time.NewTicker(time.Second/10)
	index := 0
	for {
		<-ticker.C
		nameChannel <- names[index]
		index++
		for index == len(names) {
			ticker.Stop()
			close(nameChannel)
			break
		}
	}
}
```

## reading and Writing Data

Describe two of the most important interfaces defined by the stdlib the `Reader`and `Writer`interfaces. These interfaces are used wherever data is read or written, which means that any source or destination for data can be treated in much the same way so that writing data to a file... This approach means that just about any data source can be used in the same way, while still allowing specilized features to be defined using the compisition features.

The `io`package defines these interfaecs -- but the implementations are available from a range of other packages. And these interfaces don’t entirely hide the details of sources or destinations for data and additional methods are often required, provdied by interfaces that build on `Reader`and `Writer`. The use of thse interfaces is optional.

### Understanding Readers and Writers

The `Reader`and `Writer`interfaces are defined by the `io`package and provide abs ways to read and write data, without being tied to where the data is coming from or going to.

Understanding Readers -- The `Reader`interface defines a single method, which like:

`Read(byteSlice)`-- this reads data into the specified `[]byte`. the mthod returns the number of bytes that were read.

```go
func processData(reader io.Reader) {
	b := make([]byte, 2)
	for {
		count, err := reader.Read(b)
		if count > 0 {
			Printfln("Read %v bytes: %v", count, string(b[:count]))
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

Each type of `Reader`is created differently. To create a reader basd on a `string`, the `strings`package just provides a `NewReader`ctor function which acepts a `string`. like:

`r:= strings.NewReader("Kayak")`

And to emphasize the use of the interface, use the result from the `NewReader`function as an argument to a function taht accepts an `io.Reader`-- within the functin, use the `Read`method to read bytes of data. Specify the maximum number of bytes that want to receive by setting the szie of the `byte`slice that is passed to the `Read`function -- the results form the `Read`function indicate how many bytes of data have been read and whether there has been an error.

The `io`package defines a special error just named `EOF`-- which is used to signal when the `Reader`reaches the end of the data -- if the `error`result from the `Read`function is equal to the `EOF`error, then just break.

### Understanding Writers

The `Writer`interface defines the method like:

`Write(byteSice)`-- this writes dat from the sepcified slice -- method returns the number of bytes have been written, and an `error`-- will be non-nil if the number of bytes less than the length of the slice. like:

```go
func processData(reader io.Reader, writer io.Writer) {
	b := make([]byte, 2)
	for {
		count, err := reader.Read(b)
		if count > 0 {
			writer.Write(b[:count])
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

So the `strings.Builder`struct -- implements the `io.Writer`interface, which means that can write bytes to a `Builder`and then call its `String()`method get the string. 

Writers will return an `error`if they are unable to write all the data in the slice. As a general rule, the `Reader`and `Writer`methods are implemented for pointers so that passing a `Reader`or `Writer`to a function doesn’t create a copy.

### Additional Info

In the code used the `w.Header().Set()`to just add new header to the response heder **map**.There is also `Add(), Del()`and `Get()`methods that you can use to read and manipulate the header map too.

```go
// Set a new cache-control header, if an existing "Cache-Control" header exists
w.Header().Set("Cache-Control", "public, max-page=3156000") // if exists, overwrite

w.Header().Del("Cache-Control")
w.Header().Get("Cache-Control")
```

### Header Canonicalization

When are using the `Add, Get, Set, Del`methods on the header map, the header name will always be canonicalized using some function. If need to avoid this canonicalization can edit the underlying header map directly like:

`map[string][]string` just like:

`w.Header()["X-XSS-Protection"]=[]string{"1; mode=block"}`

### Suppressing System-Generated Headers

The `Del()`method doesn’t remove system-generated headers -- to suppress these, need to access the underlying header map directly and set the value to `nil`.

`w.Header()["Date"]=nil`

### URL Query Strings

To make this work, need to update the `showSnippet`handler function to do two things -- 

1. It needs to retrieve the value of the `id`parameter from the URL query string, which an do using the `r.URL.Query().Get()`method. This will always return a string value for a parameter. Or the empty string “” is no matching parameter exists.
2. Cuz the `id`parameter is untrusted user input, should validate it to make sure its sane and sensible. FORE, want to check that it contains a positive integer value, can do by trying to converting the string to integer using the `strconv.Atoi()`func.

```go
// Add a showsnippet handler function
func showSnippet(w http.ResponseWriter, r *http.Request) {
	// Extract the value of the id parameter from the query string and try to
	// convert it to an integer using the strconv.Atoi() func
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	// Then use the fmt.Fprintf() function to interpolate the id value with responses
	// and write it to the http.ResponseWriter
	fmt.Fprintf(w, "Display a specific snippet with ID %d", id)
}
```

### The `io.Writer`interface

The code introduced another new thing behind-the scenes, if you take a look at the documentaiton for the `fmt.Fprintf()`notice that it takes an `io.Writer`as the first -- Able to do this cuz the `io.Writer`type is just an interface, and the `http.ResponseWriter`object satisfies the interface cuz it has a `w.Write()`method.

## Project Structure and Organization

It’s just important to explain -- Way to structure web app in go -- have freedom and flexibily over how you organize your code.

- `cmd`will contain the app-specific code for executable apps in the project.
- The `pkg`will contain the ancillary non-app-specific code used tin the project
- The `ui`will contain the user-interface assets used by the web application.

### HTML templating and Inheritance

```html
<!doctype html>
<html lange="en">
<head>
    <meta charset="utf-8">
    <title>Home - Snippetbox</title>
</head>

<body>
<header>
    <h1><a href="/">Snippetbox</a></h1>
</header>

<nav>
    <a href="/">Home</a>
</nav>

<main>
    <h2>Latest snippets</h2>
    <p>There is nothing to see here yet</p>
</main>
</body>
</html>
```

Fo this, just need to import Go’s `html/template`package, which provides a family of functions for safely parsing and rendering HTML templates. can use the functions in this pacakge to parse the template file and then execute the template demonstrate -- just like:

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	// just use the template.ParseFiles() function to read the template file into a
	// template set -- if there is an error, log the detailed error message and use
	// the http.Error() to send a generic 500 Internal Server Error
	ts, err := template.ParseFiles("./ui/html/home.page.html")
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal server error", 500)
		return
	}

	err = ts.Execute(w, nil)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal server error!", 500)
	}
}
```

It’s important to point out that the file path that you pass to the `template.ParseFiles()`function must either be relative to your *current working directory*, or an abs path. In the code made the path relative to the root of the project directory.