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

## Supporting the HTTP `PATCH`method

For simple data types, edit operations can be handled by replacing the existing object using the `PUT`-- which is the approach -- even if you need to change a single property value in the `Product`, and it isn't too much trouble to use a `PUT`Method and include the values for all the other `Product`properties too.

### Understanding JSON patch

Core has support for working with JSON patch std, which allows changes to be specified in a uniform way -- the JSON patch std allows for a complex set of changes to be described, but for this chapter, going to focus on just the ability to change the value of a property. A HTTP patch request like:

```json
[
    {"op":"replace", "path":"Name", "value":"Surf Co"},
    {"op":"replace", "path":"City", "value":"Los Angeles"}
]
```

And, A json patch document is expressed as an array of operations, each operation has an `op`property, which specifies the type of operation, and a `path`property, whcih specifies where the operation will be just applied. For the example app, for most apps, only the `replace`op is required.

### Installing and configuring the JSON Patch package

Support for JSON PAtch isn't installed when a project is created with the tempalte -- to instll just like:

```sh
install-package Microsoft.AspNetCore.Mvc.NewtonsoftJson
```

The ms implementaion of JSON patch relies on 3rd-party serializer. just add the satement like:

`builder.Services.AddControllersWithViews().AddNewtonsoftJson();`

```cs
builder.Services.Configure<MvcNewtonsoftJsonOptions>(opts =>
{
    opts.SerializerSettings.NullValueHandling =
    Newtonsoft.Json.NullValueHandling.Ignore;
});
```

The `AddNewtonsoftJson`method enables the `JSON.NET`serializer, which replaces the std ASP.NET core serializer, the JSON.NET serializer has its own configuration class.

### Defining the action method

To add support for `PATCH`method, add the action method to the `SupplierController`class.

```cs
[HttpPatch("{id}")]
public async Task<Supplier?> PatchSupplier(long id, 
                                           JsonPatchDocument<Supplier> pathDoc)
{
    Supplier? s = await context.Suppliers.FindAsync(id);
    if(s!=null)
    {
        pathDoc.ApplyTo(s);
        await context.SaveChangesAsync();
    }
    return s;
}
```

The action method is decorated with the `HttpPatch`attribute, which denotes that it will handle `HTTP PATCH`requests, the model binding feature is used to process the JSON patch document through a `JsonPatchDocument<T>`method parameter -- the class defines a `ApplyTo`method, which applies each op to an object. The action method retrieves a `Supplier`object from the dbs.

Just note that the URL is `http://localhost:5193/api/suppliers/1`.

## Understanding Content Formatting

The web service examples have produced JSON results, but this is not the only data format that action methods can produce -- the Content format selected for an action result depens on 4 factors -- The formats that the client will accept, the formats that the application can produce, the content policy specified by the action method, and the type returned by the default policy works just fine for most applications.

The best way to get acquainted with content formatting is to understand what happens when neither the client nor the action method applies any restrictions to the formats that can be used.

1. If the action method returns a `string`then the string is sent unmodified to the client -- and the `Content-Type`is just set to `text/plain`.
2. For all other data types, including other simple types such as `int`, the data is formatted as JSON, and the `Content-type`Header of the response is set to `application/json`.

Strings just get special treatment cuz they cause problems when are encoded as JSON, when you encode other simple types, such as C# `int`value 2 -- then result is a quoted string. When encode a string just becomes ""hello"". FORE:

```cs
[HttpGet("string")]
public string GetString() => "This is a string response";

[HttpGet("object")]
public async Task<Product> GetObject() {
    return await context.Products.FirstAsync();
}
```

### Content negotiation

Most clients include an `Accept`header in a request, which just specifies the set of formats that hey are willing to receive in the response -- expressed as a set of MIME types. like:

`Accept: text/html, application/xhtml+xml; q=0.9,image/avif,image/webp,image/apng...`

This header indicates that Chrome can handle the HTML... The `q`values in the header specify relative preference, where the value is 1.0 by default -- specifying a `q`value of 0.9 for `application/xml`just tells the server that chrome will accept XML data but prefers to deal with HTML or XHTML. The `*/*`item tells the server that Chrome will accetp any format, but its `q`value specifies that is the lowest.

### Enabling XML formatting

For content negotiation to work, the app must be configured so there is some choice in the formats that can be used. like:

```cs
builder.Services.AddControllers()
    .AddNewtonsoftJson()
    .AddXmlDataContractSerializerFormatters();
```

### Specifying an action result format

The data formats that the MVC framework can sue for an action method result can be constrained using the `Produces`attribute just like:

```cs
[Produces("application/json")]
public...
```

## Caching output

This allows caching policies to be defined and applied to endpoints and controller. Just like:

```cs
builder.Services.Configure<MvcOptions>(opts=> {
    opts.RespectBrowserAcceptHeader = true;
    opts.ReturnHttpNotAcceptable= true;
});

// ... 
app.UseOutputCache();

//...
[HttpGet("string")]
[OutputCache(PolicyName="30sec")]
public string...
```

The `OutputCache`attribute can be applied to the entire controller, which causes the responses for all action methods, or applied to individual actions.

## Using Controllers With Views Part I

Razor view engine, which is just responsble for generating HTML responses that can be displayed.

### Creating HTML controller

Controllers for HTML apps are similar used for web services but some important differences -- To create an HTML controller, add a class named `HomeController`to the `Controllers`folder like:

### Creating a Razor View -- 

```html
<h6 class="bg-primary text-white text-center m-2 p-2">
    Product Table
</h6>
<div class="m-2">
    <table class="table table-sm table-striped table-bordered">
        <tbody>
        <tr><th>Name</th><td>@Model.Name</td></tr>
        <tr>
            <th>Price</th>
            <td>@Model.Price.ToString("c")</td>
        </tr>
        </tbody>
    </table>
</div>
```

### Selecting a View by name

The action method relies entirely on convention, leaving Razor to select the view that is used to generate the resonse. Action methods can select a view by providing a name as an argument to the `View`. FORE:

```cs
public async Task<IActionResult> Index(long id =1)
{
    Product? prod= await context.Products.FindAsync(id);
    if (prod?.CategoryId==1) 
    {
        return View("Watersports", prod);
    }
    else
    {
        return View(prod);
    }
}
```

The action method selects the view based on the `CategoryId`prop of the `Product`object that is retrieved from the dbs, 

`View("Watersports", prod)`specifies the file extension or the location for the view. Just notice that the action method doesn't specify the file extension or the location for the view -- it is the job of the view engine to translate `Watersports`into a view file.

### Using Shared Views

When the Razor view engine locates a view, it looks the `Views/[controller]`folder and then the `View/Shared`folder, this search pattern means that views that contain common content can be shared between controllers, avoiding duplication.

And the `Categories`controller receives a respository to access category data through its ctor and defines actions that support querying the dbs creating, updating, deleting.

```html
@model IEnumerable<Category>

<h3 class="p-2 bg-primary text-white text-center">Categories</h3>

<div class="container-fluid mt-3">
    <div class="row">
        <div class="col-1 fw-bold">Id</div>
        <div class="col fw-bold">Name</div>
        <div class="col fw-bold">Description</div>
        <div class="col-3"></div>
    </div>
    
    @if (ViewBag.EditId == null)
    {
        <form asp-action="AddCategory" method="post">
            @await Html.PartialAsync("CategoryEditor", new Category())
        </form>
    }
    
    @foreach (Category c in Model)
    {
        @if (c.Id == ViewBag.EditId)
        {
            <form asp-action="UpdateCategory" method="post">
                <input type="hidden" name="Id" value="@c.Id" />
                @await Html.PartialAsync("CategoryEditor", c)
            </form>
        }
        else
        {
            <div class="row p-2">
                <div class="col-1">@c.Id</div>
                <div class="col">@c.Name</div>
                <div class="col">@c.Description</div>
                <div class="col-3">
                    <form asp-action="DeleteCategory" method="post">
                        <input type="hidden" name="Id" value="@c.Id" />
                        <a asp-action="EditCategory" asp-route-id="@c.Id"
                           class="btn btn-outline-primary">Edit</a>
                        <button type="submit" class="btn btn-outline-danger">
                            Delete
                        </button>
                    </form>
                </div>
            </div>
        }
    }
</div>
```

This view provides an all-in-one interface for managing categories and delegates creating, and editing objects to partial view -- To create the partial view, just added a file called `CategoryEditor.cshtml`to the `Views/Categories`folder. like:

```html
@model Category

<div class="row p-2">
    <div class="col-1"></div>
    <div class="col">
        <input asp-for="Name" class="form-control" />
    </div>
    <div class="col">
        <input asp-for="Description" class="form-control" />
    </div>
    <div class="col-3">
        @if (Model.Id == 0)
        {
            <button type="submit" class="btn btn-primary">Add</button>
        }
        else
        {
            <button type="submit" class="btn btn-outline-primary">Save</button>
            <a asp-action="Index" class="btn btn-outline-secondary">Cancel</a>
        }
    </div>
</div>
```

So, to make it easier to move around the app, added the elements to the shared layout -- 

```html
<div class="container-fluid">
    <div class="row p-2">
        <div class="col-2">
            <a asp-controller="Home" asp-action="Index"
               class="@GetClassForButton("Home")">
                Prodcuts
            </a>
                
            <a asp-controller="Categories" asp-action="Index"
               class="@GetClassForButton("Categories")">
                Categories
            </a>
        </div>
        <div class="col">
            @RenderBody()
        </div>
    </div>
</div>
```

### Populating the dbs with Categories

It will be helpful to have some data to work with while completing the data relationship. Start the app using `dotnet.run`click the `Categories`button, and use the form to add:

## Using a Data Relationship

The part of the app that deals with `Product`object must be updated to reflect the new relationship in the dbs. There are two parts of this process -- including the category data when querying the dbs and allowsing the user to select a category when creating or editing a product.

### Working with Related Data

EF core just ignores relationships *unless U explicitly* include them in queries . This means that navigation properties such as `Category`defined by the `Product`class will be left `null`by default. The `Include`extension method is used to tell EF core to populate a navigation property with related data is called on the `IQueryable<T>`object that represents a query.

```cs
public void AddProduct(Product product)
{
    context.Products.Add(product);
    context.SaveChanges();
}

public Product GetProduct(long key) => context.Products
    .Include(p => p.Category).First(p => p.Id == key);

public void UpdateProduct(Product product)
{
    Product p = GetProduct(product.Id); // get the base line
    p.Name = product.Name;  // product from the Data binding through the form
    // p.Category = product.Category;
    p.PurchasePrice = product.PurchasePrice;
    p.RetailPrice = product.RetailPrice;
    p.CategoryId= product.CategoryId;
    context.SaveChanges();
}
```

So the `Include`just is defined in the namespace, and it accepts a lambda that selects the navigation property you want EF core to include in the query. And the `Find`method that used for the `GetProduct`method cannot be used with the `Include`method.

### Selecting a Category for a Product

Updated the `Home`controller so that it has access to the `Category`data through the repository and passes on the data to its view. This will allow the view to select from the complete set of categories when editing.

```cs
public IActionResult UpdateProduct(long key)
{
    ViewBag.Categories = categoryRepository.Categories;
    return View(key==0?new Product { Name=default!, Category=default!} : repository.GetProduct(key));
}
```

To allow the user to choose just need a `select`control:

EF core uses the FK to query for the data it needs to create the `Category`objects related to each `Product`and uses an inner join to combine data from the `Products`and `Categories`tables. So once you have created all the three -- for the editing the category, and change the value of name. 

### Adding Support for Orders

To demonstrate a more complex relationship , add support for creating and storing orders and use them to just represent the `Product`selections made by customers.

Creating The dataModel -- Just adding a file called `Order.cs`to the `Models`folder and using:

```cs
public class Order
{
    public long Id { get; set; }
    public required string CustomerName { get; set; }
    public string? Address { get; set; }
    public string? State { get; set; }
    public string? ZipCode { get; set; }
    public bool Shipped { get; set; }

    public IEnumerable<OrderLine> Lines { get; set; }
}

public class OrderLine
{
    public long Id { get; set; }
    public long ProductId { get; set; }
    public Product? Product { get; set; }

    public int Quantity { get; set; }

    public long OrderId { get; set; }
    public Order? Order { get; set; }
}
```

Each `OrderLine`object is related to an `Order`and a `Product`and has a property that indicates how many of that product the customer requires. To make it convenient to access the `Order`data, added the properties like:

```cs
public DbSet<Order> Orders => Set<Order>();
public DbSet<OrderLine> OrderLines => Set<OrderLine>();
```

### Creating the Repository and Preparing the Dbs

To provide consistent access to the new data to the rest of the app, added a file called `IOrderRepostiory`to the Models

```cs
public interface IOrderRepository
{
    IEnumerable<Order> Orders { get; }
    Order GetOrder(long key);
    void AddOrder(Order order);
    void UpdateOrder(Order order);
    void DeleteOrder(Order order);
}

public class OrderRepository: IOrderRepository
{
    private DataContext context;
    public OrderRepository(DataContext context)=> this.context = context;

    public IEnumerable<Order> Orders => context.Orders
        .Include(o => o.Lines!).ThenInclude(l => l.Product);

    public Order GetOrder(long key)=> context.Orders
        .Include(o=>o.Lines).First(o=>o.Id==key);

    public void AddOrder(Order order)
    {
        context.Orders.Add(order);
        context.SaveChanges();
    }

    public void UpdateOrder(Order order)
    {
        context.Orders.Update(order);
        context.SaveChanges();
    }

    public void DeleteOrder(Order order)
    {
        context.Orders.Remove(order);
        context.SaveChanges();
    }
}
```

This repository implementation follows the pattern established for the other repositories and forgoes change detection in favor of simplicity.

## Functions

Recall that in Js, if a function parameter is not provided, its argument value insdie the function defaults to `undefined`. Sometimes function parameters are not necessary to provide, and the intended use of the function is for that `undefined`value. Wouldn't want Ts to report type errors for failing to provide arguments to those optional parameters. Ts just allows annotating a paramter as optional by adding `?:`like:

```tsx
function announceSong(song: string, singer?: string) {
    console.log(`song: ${song}`);
    if (singer) {
        console.log(`Singer: ${singer}`);
    }
}
```

### Default Parameters

Optional parameters in js may be given a default value with an `=`and a value in their declaration. For those optional parameters, cuz a value is provided by default, their Ts type does not implicitly have the `|`and `undefined`union added on inside the function.

```tsx
function singAllTheSong(singer: string, ...songs: string[]) {
    for(const song of songs){
        //..
    }
}
```

### Return Types

Ts is percepitive -- if it understands all the possible values returned by a function, it will know what type the function returns-- in this example -- 

```tsx
function singSongs(songs: string[]) {
    //...
    return songs.length;
}
```

So, if a func contains multiple `return`statements with different values, Ts will just infer the return type to be a union of all the possible returned types. FORE:

```tsx
function getSongAt(songs: string[], index:number){
    return index<songs.length
    ? songs[index]
    :undefined;
}// return string | undefined
```

### Explicit Return types

Generally recommand not borthering to explicitly declare the return types of functions with annotations -- there are a few cases where it can be useful specifically for functions -- 

- You might want to enforce functions with many possible types of recursive function.
- Ts will refer to try to reason through return types of recursive functions.
- Can speed up ts type checking in very large projects.

```tsx
function singSongRecursive(songs: string[], count=0): number {
    return songs.length? singSongRecursive(songs.slice(1), count+1): count;
}
```

### Function types

Js allows us to pass functions around as values -- that means we need a way to declare the type of a parameter or variable meant to hold a function. Function syntax looks similar to an arrow function, but with a type instead of the body -- the `nothingInGivesString`type describes a function with no parameters and a returned `string`value like:

`let nothingInGivesString: ()=> string;`
`let inputAndOutput: (songs: string[], count?:number) => number;`

So, function types are frequently used to describe callback parameters and returned `string`value. FORE, the following runOnSongs snippet declares the type of its `getSongAt`parameter to be a function that taks in an `index:number`and returns `string`-- Passing `getSongAt`matches that type, but `longSong`fails for taking in a `string`as its paramter instead of a `number`.

```tsx
const songs = ["Juice", "Shake it off", "What's up"];
function runOnSongs(getSOngAt: (index: number) => string) {
    for (let i = 0; i < songs.length; i += 1) {
        console.log(getSOngAt(i));
    }
}

function getSOngAt(index: number) {
    return `${songs[index]}`;
}

runOnSongs(getSOngAt);  //ok
```

The error message for `runOnSongs`is an example of an assignability error that includes a few levels of details -- when complaining that two function types aren't assignable to each other, Ts will typically give three levels of detail:

### Parameter Type Inferences

It would be cumbersome if we had to declare parameter types for every function we write -- including inline functions used as parameters -- Js can infer the types of parameters in a function provided to a location with the declared type. FORE, This `singer`variable is known to be a function that takes in a parameter of type `string`.

```tsx
let singer: (song:string) => string;
singer = function(song) {
    // type of song: string
    return...
}
```

Functions passed as arguments to parameters with function paramters types wil have their parameter type inferred as well. FORE the `song`and `index`parameters are inferred by Ts to be `string`and `number`.

```tsx
const songs = ["..."];
songs.forEach((song, index)=> {
    console.log(`${song} is at index ${index}`);
})
```

### Function type Aliases

FORE, this `usesNumberToString`function has a single parameter which is itself the `NumberToString`aliased function type like:

```tsx
type NumberToString = (input:nubmer)=>string;
function useNumberToString(numberToString: NumberToString) {...}
```

### More Return Types

Some funcs aren't meant to return any value -- they eigher have no return or only have don't return a value. Ts allows using a `void`keyword to refer to the return type of such a fucntion that returns nothing.

Functions whose return type is `void`may not return a value, This `longSong`function is declared as returning `void`.

```tsx
function longSong(song:string | undefined): void {
    if(!song){
        return ; //ok
    }
    return true; // error -- byte boolean is not assignable to type void
}
```

`void`can be useful as the return type in a fucntion type declartion. When used in a function type declaration, `void`indicates that any returned from the funciton would be ignored.

FORE, this `songLogger`variable represents a function that takes in a `song:string`and doesn't return a value.

```tsx
let songLogger: (song:string)=> void;
songLogger= (song)=> {
    console.log(`${songs}`);
};
songLogger("heart of Glass");
```

And, note that although Js functions all return `undefined`default if no real value is returned, `void`is not the same as `undefined`-- void means that the return type of a function will be just ignored. Trying to assign a value of type `void`to a value whose type instead includes `undefined`is a type error like:

```tsx
function returnsVoid() {
    return;
}
let lazyValue: string | undefined;
lazyValue = returnsVoid(); // error
```

And the distinction between `undefined`and `void`is particluar useful for ignoring any return value from a function passed to a location whose type is declared as returning `void`. Fore, the `forEach`method on arrays takes a callback that just returns `void`-- Funcitons provided to `forEach`can return any value they want. `records.push(record)`

```tsx
const records: string[]=[];
function saveRecords(newRecords: string[]) {
    newRecords.forEach(record=> records.push(record));
}
```

### Never Returns

Some functions not only don't return a value, but aren't meant to return at all. Never returning functions are those that always throw an error or run in infinite loop -- If a function is meant to never return, adding an `explict:never` type.

```tsx
function fail(message: string) never {
    throw new...
}
    
function workWithUnsafeParm(parm: unknown) {
    if(typeof param !== "string"){ // unknown need type checking
        fail(...)
    }
}
```

### Function overloads

Some js functions are able to be called with drasitcally different sets of parameters that can't be represented just by optional and/or rest parameters -- these functions can be described with a ts syntax called overload signatures. Declaring different versions of the function's name..

When determining whether to emit a syntax error for a call to an overloaded function, Ts will only look at the function's overload signatures. FORE:

```tsx
function createDate(timestamp: number): Date;
function createDate(month: number, day: number, year: number): Date;
function createDate(monthOrTimestamp: number, day?: number, year?: number) {
    return day === undefined || year === undefined
        ? new Date(monthOrTimestamp)
        : new Date(year, monthOrTimestamp, day);
}
createDate(554356800)
```

Overload signatures, as with other type system syntaxes, are erased when compiling Ts output js.

### Call-signature Compability

The implementation signature used for an overloaded funciton's implemenation is what the function's implementation uses for parameter types and return type. Thus, the return type and each parameter in a function's overload signagures must be assignable to the parameter at the same index in tis implemantion signature.

## String and REGEXP

### Checking for an Existing, NonEmpty String

Wan to verify a variale is defined, is a string, and is not empty before use it. Before you start working with a string, often need to validate that it's safe to use, when do, there are different questions -- 

`if(typeof unknownVariable === 'string')`
`if(typeof unknownVariable==='string' && unknownVariable.length>0)`
`if(typeof unknownVariable==='string' && unknownVariable.trim().length>0)`

The order of this is just important-- js uses *short-circuit* evaluation. If:

`const unknownVariable= new String('test')`-- now the `typeof`operator will return `object`-- If you need to handle that:

```js
if(typeof unknownVariable === 'string' || 
  String.prototype.isPrototypeOf(unknownVariable)) {
    // it's a string or String
}
```

### Converting a Numeric value to a Formatted String

Want to create a string representation of a number -- Js is just a loosely typed language, and it will automatically convert any value to a string -- And, every js object has a built-in `toString()`method, including `Number`object, and can call like:

```js
const someNumber=42;
const someString= someNumber.toString();
```

```py
import collections

Card = collections.namedtuple('Card', ['rank', 'suit'])


class FrenchDeck:
    ranks = [str(n) for n in range(2, 11)] + list('JQKA')
    suits = 'spades diamonds clubs hearts'.split()

    def __init__(self) -> None:
        self._cards = [
            Card(rank, suit) for suit in self.suits for rank in self.ranks
        ]

    def __len__(self):
        return len(self._cards)

    def __getitem__(self, position):
        return self._cards[position]
```

```py
from random import choice
choice(deck)
```

- Users of your class don't have to memorize arbitrary method names for std operations.
- It's easier to benefit from the rich stdlib and avoid reinventing the wheel.

Cuz `__getitem__`delegates to the `[]`operator of `self._cards`, our deck automatically supports slicing -- here is how we look at the top 3 cards from brand-new deck, and then pick just the aces like:

Just by implementing the `__getitem__`sepcial method, our deck is also iterable like:

```py
for card in deck:
    print(card)
```

Can also iterate over the deck in revcerse like:

```py
for card in reversed(deck):
    print(card)
```

Iteration is often implicit -- if a collectin has no `__contains__`method -- the `in`operator does a sequential scan. Case in point, `in`works with our `FrenchDeck`class cuz it is iterable. like:

```py
Card('Q', 'hearts') in deck
```

And how about shorting -- A common system of ranking cards is by rank -- then by suit in the order of spades, hearts... here is a function that ranks cards by that rule, returning 0 for the 2 of clubs and 51 for the ace of spades.

```py
suit_values = dict(spades=3, hearts=2, diamonds=1, clubs=0)

def spades_high(card):
    rank_value = FrenchDeck.ranks.index(card.rank)
    return rank_value * len(suit_values) + suit_values[card.suit]

for card in sorted(deck, key=spades_high):
    print(card)
```

Although `FrenchDeck`implicitly inherits from the `object`class, most of its functionality is not inherited, but comes from leveraging the data model and composition. By implementing the special methods `__len__`and `__getitem__` Thanks to composition, the `__len__`and `__getitem__`implementation can delegate all the work to a `list`object.

The first thing thing to know about special methods is that they are meant to be called by the PY interpreter -- not by U, don't write `my_object.__len__()`, and the interpreter takes a shortcut when dealing for built-in types like `list,str,bytearray`.

More often than not, the special method call is implicit, fore the statement `for i in x:`actually cause the invocation of `iter(x)`-- which in turn may call `x.__iter__()`if that is available, or use `x.__getitem__()`. Normally, your code should not have many direct calls 