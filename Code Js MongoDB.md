# Code Js MongoDB

How to read, understand, and create simple MDB applications using the Node.JS driver. These app will help U to programtically fetch, update, and create data in your MDb collections, as well as to handle errors and users inputs.

To connect your sofware with dbs, will typically use a library known as a driver. This will help U connect, analyze, readn and write to your dbs without having to write multiple lines of code for simple actions, it provides functions and abstractions for common use cases, as well as framewokds for working with data extracted form the dbs.

### Connecting to the driver

At a high level, the process of using the Node.JS dirver with MDB is similar to connecting directly with the shell. The eaiest way to install the Mdb driver for Node.JS is to use npm -- just like:

```sh
npm install mongodb
```

Then jsut write like:

```js
const Mongo = require('mongodb').MongoClient;
const driver = 'mongodb+srv://abc:abc123+-*@cluster0.hti4s.mongodb.net/'
const mogo = new Mongo(driver);
mogo.connect(function(err){
    const dbs = mogo.db('sample_mflix');
    const collection = dbs.collection('movies');
    mogo.close()
})
```

The database and collection object express the same concept as if you were do this so jsut need to use `promise`

```js
const {MongoClient} = require("mongodb");
const driver = 'mongodb+srv://abc:abc123+-*@cluster0.hti4s.mongodb.net/'

async function run() {
    const client = new MongoClient(driver);
    try {
        await client.connect();
        console.log('connected to mdb');
        const dbs = client.db('sample_mflix');
        const collection = dbs.collection('movies');
        (await collection.find({title: 'A Corner in Wheat'}).toArray()).forEach(
            m=>console.log(m)
        );
    } catch (err) {
        console.error(err);
    }
}

run().catch(console.dir);
```

## Disabling select cases with `nil`channels

In Go, can assign `nil`values to channels -- this has the effect of *blocking* the channel from sending or receiving anything -- as demonstrated in the following listing -- the `main()`goroutine tries to send a string on a `nil`fore:

```go
func main() {
    var ch chan string = nil
    ch <- "message" // blocks executions as it tries to send message on the `nil`
    print(...) // never executed
}
```

When we run this command never gets executed cuz the execution blocks on the message sending. When Go notices that the program is stuck with no hope of recovering, it gives us the following message like: And the same logic applies to `select`statements, trying to send to or receive from a `nil`channel on a `select`statement has the same effect of blocking the case using that channel -- like -- using `select`with just one `nil`is not that useful -- can use the pattern of assigning `nil` to a channel to disable a case in the `select`statement.

```go
func generateAmounts(n int) <-chan int {
	amounts := make(chan int)
	go func() {
		defer close(amounts)
		for i := 0; i < n; i++ {
			amounts <- rand.Intn(100) + 1
			time.Sleep(100 * time.Millisecond)
		}
	}()
	return amounts
}
```

 If were to use a normal `select`statement to consume from both the sales and expense goroutines, with one of the goroutine closing its channel earlier than the other, would end up always executing on the closed channel case. Every time we consume from a closed channel, will return the just *default* data type without blocking -- this also applies to the select cases.

One solution would be change the channel into a `nil`channel whenever it is closed. Assigning a `nil`value to the channel variable after the receiver detects that the channel has been closed has the effect of disabling that `case`clause.

```go
func main() {
	sales := generateAmounts(50)
	expenses := generateAmounts(40)
	endOfDayAmount := 0
	for sales != nil || expenses != nil {
		select {
		case sale, moreData := <-sales:
			if moreData {
				fmt.Println("Sale of:", sale)
				endOfDayAmount += sale
			} else {
				sales = nil
			}
		case expense, moreData := <-expenses:
			if moreData {
				fmt.Println("Expense of:", expense)
				endOfDayAmount -= expense
			} else {
				expenses = nil
			}
		}
	}
	fmt.Println("End of day profit and loss", endOfDayAmount)
}
```

Once both channels has closed and set to `nil`, we exit the `select`loop and ouput the end-of-day balance.

### Choosing between message passing and memory sharing

Can decide whether to use memory sharing or message passing for our concurent apps depending on the type of solution we are trying to implement -- in this section, will examine the factors and implications that should keep in mind when deciding which of the two approaches to use.

#### Desigining tightly vs. loosely coupled systems

The term *tightly* and *loosely* coupled software refer to how dependent different modules are on each other. *Tightly* coupled means that when chanage one, will have a ripple effect on many other parts of the software, which usually require changes as well. And in loosely coupled software, components tend to have *clear boundaries* and few dependences on other modules.

Concurrent programming using *memory sharing* typically produces more tightly coupled software. The inter-thread communication uses a common block of memory, and the boundaries of each execution are not clearly defined.

In contrast, with message passing, executions can have clearly defined input and output contrast. Which means that we know exactly how a change in one execution will affect another.

#### optimizing memory consumption

With message passing, each goroutine has its own isolated state stored in memory -- when pass messages from one to another, each organizes the data in its memory to compute its task. Could change the letter-frequency app to use message passing by having each goroutine build a local instance of a slice with the frequentices encountered while downloading its web page.

```go
func counterLettersChan(url string) <-chan []int {
	result := make(chan []int)
	go func() {
		defer close(result)
		frequency := make([]int, 26)
		resp, _ := http.Get(url)
		defer resp.Body.Close()
		if resp.StatusCode != 200 {
			panic("Server returning error code:" + resp.Status)
		}
		body, _ := io.ReadAll(resp.Body)
		for _, b := range body {
			c := strings.ToLower(string(b))
			cIndex := strings.Index(allLetters, c)
			if cIndex >= 0 {
				frequency[cIndex] += 1
			}
		}
		fmt.Println("Completed:", url)
		result <- frequency
	}()
	return result
}
```

Now can add a `main()`that starts a goroutine for each web page and waits for messages from each output channel -- once we start receiving messages containing the slices, can just merge the final slice.

```go
func main() {
	results := make([]<-chan []int, 0)
	totalFrequencies := make([]int, 26)

	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		results = append(results, counterLettersChan(url))
	}
	for _, c := range results {
		freqResult := <-c
		for i := 0; i < 26; i++ {
			totalFrequencies[i] += freqResult[i]
		}
	}

	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, totalFrequencies[i])
	}
}
```

In converting our program to use message passing, have avoided using mutexes to control acecss to shared memory since each goroutine is now only working on its own data. However, in doing so, we have increased the memory use since we have allocated a slice for each web page.

### Validate result

Cuz we have so many limitations in the supported values, it seems wise to check that the output is sth expected. Contrary to the conversion logic, this can be the responsibility of the `Amount`structure -- can be valid or not, and it should know about it.

```go
// validate returns an error if and only if an Amount is unsafe to use
func (a Amount) validate() error {
    switch {
    case a.quantity.subnits > Decmimal:
        return ErrTooLarge
    case a.quantity.precision > a.currency.precision:
        return ErrTooPrecise
    }
    return nil
}
```

For the `convert.go`file just like:

```go
// Convert applies the change rate to convert an amount to a tag
func Convert(amount Amount, to Currency) (Amount, error) {
    // Conver to the target currency applying the fetched change
    convertedValue := applyExchangeRate(amount, to, 2)
    // Validate the converted amount is the handled bounded
    if err := convertedValue.validate(); err != nil {
        return Amount{}, err
    }
    return convertedValue, nil
}
```

### Command-Line interface

In this section, will write the main function -- We are not writing a library, just writing a CLI -- this means that we will parse input, validating them and passing them onto the `Convert`function like:

Flags and Arguments -- fore `change -from EUR -to USD 413.98`

Currency flags -- In order to read flags from a command line, -- Go has the quite explicit `flag`package -- after importing it in our `main.go`file, can start with the first few lines that will ensure we properly read form the command line. `flag.String`takes an arg the name of the flag, Returns the contents of the `flag`.

```go
func main() {
	// read currencies form the input
	from := flag.String("from", "", "source currency, required")
	to := flag.String("to", "EUR", "target currency")
	flag.Parse()
	fmt.Println(*from, *to)
}
```

#### Value argument

The next step in implementing our command-line interface to retreive the value that we have to convert. If it’s absent from the command line, we’ll exit with error -- 

Retrieving arguments from the command-line -- When running an executable, most of the time, need to specify the input, the behavior, the output, etc. These parameters can be provided either explicitly, via the command line, or implicitly, iva pre-set environment variables, or configuration files at know locations. When it comes to explicit settings, there are two ways of passing user-defined values to the program -- arguments, or flags. For the Flag parameters -- aren’t sorted, the can appear in any order in the command-line without altering the behaviour of the program -- they can have default values -- an example of a flag that controls behaviour that you might have been using is the `-o`option of the `go build`.

In Go, the parameters of the command line can be retrieved with `os.Args`or with the `flag`package. 

`convert -from ERU -to JPY 15.23`

Depending on which information we want to access, using the `flag.Args`or `os.Args`is more meaningful. In the case, only want to access the command-line parameters. Like:

```go
func main() {
	// read currencies form the input
	from := flag.String("from", "", "source currency, required")
	to := flag.String("to", "EUR", "target currency")
	flag.Parse()
	value := flag.Arg(0)
	if value == "" {
		// value, is the first parameter that is not the part of a flag
		_, _ = fmt.Fprintln(os.Stderr, "missing amount to convert")
		flag.Usage()
		os.Exit(1)
	}
	fmt.Println(*from, *to, value)
}
```

#### Parse into business types

The `Convert`function is taking as parameters values that are already typed for its usage, and the package exposes way to build them. This strategy optimises flexibility in the consumer’s logic. As `main`is just free to use the type through any other logic that is could add.

```go
func main() {
	// read currencies form the input
	from := flag.String("from", "", "source currency, required")
	to := flag.String("to", "EUR", "target currency")
	flag.Parse()

	fromCurrency, err := money.ParseCurrency(*from)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr,
			"unable to parse source currency %q: %s.\n", *from, err.Error())
		os.Exit(1)
	}

	// parse the target currency
	toCurrency, err := money.ParseCurrency(*to)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr,
			"unable to parse target currency %q: %s.\n", *to, err.Error())
		os.Exit(1)
	}

	value := flag.Arg(0)

	if value == "" {
		_, _ = fmt.Fprintf(os.Stderr,
			"no value provided.\n")
		os.Exit(1)
	}

	// transform value into an amount with its currency
	quantity, err := money.ParseDecimal(value)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr,
			"unable to parse value %q: %s.\n", value, err.Error())
		os.Exit(1)
	}

	// transform that
	amount, err := money.NewAmount(quantity, fromCurrency)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr,
			"unable to create amount %q: %s.\n", value, err.Error())
		os.Exit(1)
	}

	convertedAmount, err := money.Convert(amount, toCurrency)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr,
			"unable to convert %q: %s.\n", value, err.Error())
		os.Exit(1)
	}
	fmt.Println("Amount", amount, "converted to", convertedAmount)
}
```

For someone who doesn’t know the structure we use, this is hard to understand it.

## Setting up a HTML form

Then making a new `create.html`file to hold the HTML for the form like:

```html
{{define "title"}}Create a new snippet{{end}}

{{define "main"}}
    <form action="/snippet/create" method="post">
        <input type="hidden" name="csrf_token" value="{{.CSRFToken}}">
        <div>
            <label>Title:</label>
            {{with .Form.FieldErrors.title}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="text" name="title" value="{{.Form.Title}}">
        </div>

        <div>
            <label>Content:</label>
            {{with .Form.FieldErrors.content}}
                <label class="error">{{.}}</label>
            {{end}}
            <textarea name="content">{{.Form.Content}}</textarea>
        </div>
        //...
        <div>
            <label>Delete in:</label>
            <input type="radio" name="expires" value="365" checked> One Year
            <input type="radio" name="expires" value="7"> One Week
            <input type="radio" name="expires" value="1"> One Day
        </div>
        <div>
            <input type="submit" value="publish snippet">
        </div>
</form>
{{end}}
```

In the `/partials/nav.html`file -- 

```html
<nav>
	<a href="/">Home</a>
    <a href="/snippet/create">Create snippet</a>
</nav>
```

In the handlers.go file just like:

```go
func(app *appliction) snippetCreate(w http.ResponseWriter, r *http.Request) {
    data := app.newTemplateData(r)
    app.render(w, http.StatusOK, "create.html", data)
}
```

### Parsing form data

At a high-level wen can break this down into two distinct steps -- 

1. First, need to use the `r.ParseForm()`method to parse the request body, checks that the request body is well-formed, and then stores the form data in the request’s `r.PostForm`map. Note that the `r.ParseForm()`method is also *idempotent* -- can be called multiple times on the same request without any side-effects.
2. Can then get to the form data contained `r.PostForm`by using the `r.PostForm().Get()`method. Can use the `r.PostForm.Get(“title”)`. Fore in the `snippetCreatePost`like:

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        //...
        return
    }
    
    // use the r.PostForm.Get() method to retreive the title and content
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    
    expires , err := strconv.Atoi(r.PostForm.Get("expreis"))
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        //...
    }
    http.Redirect(w, r, fmt.Sprintf("...", id), http.StatusSeeOther)
}
```

For this, give this -- the `r.Form`map -- in the code, accessed the form data via the `r.PostForm`map, but an alternative approach is to use the `r.Form`map -- 

Note that the `r.PostForm`is populated only for `POST, PATCH, PUT`, and contains the form data from the request body -- in contrast, the `r.Form`map is populated for all requests -- and contains the form data *from any request body and any query string parameters*. fore `/snippet/create?foo=bar`then can also get a value of `foo`by calling the `r.Form.Get(“foo”)`. Also note that in the event of a conflict, the request body will take precendent over the query string parameter. 

And using the `r.Form`map can be useful if your app sends data in a HTML form and in the URL, or have an app that is agnostic about how parameter are passed.

#### The `FormValue`and `PostFormValue`methods

The `net/http`package also provides the methods `r.FormValue`and `r.PostFormValue()`-- these are essentially shortcut functions that just call `r.ParseForm`for you. Recommend avoiding these shortcuts cuz they *silently ignore any errors* returned by the `r.ParseForm()`.

#### Multiple-value fields

The `r.PostForm.Get()`method only returns the *first* value for a specific form field. This means that you can’t use it with form fields with potentially send multiple values. Fore:

```html
<input type="checkbox" name="items" value="foo"> Foo
<input type="checkbox" name="items" value="bar"> Bar
<input type="checkbox" name="items" value="baz"> Baz
```

In this case you will need to work with the `r.PostForm`map directly -- the underlying type of the `r.PostForm`map is `url.Values`, which in turn has the underlying type `map[string][]string`like:

```go
for i, item := range r.PostForm["items"] {
    fmt.Printf(w, "%d, item%s\n", i, item)
}
```

#### Limiting the form size

Unless U are sending multipart data, like `entype=“multipart/form-data”`, then `POST, PUT`and `PATCH`are just limited to 10M -- if this is exceeded then `r.ParseForm()`will return an error. And if U want to change this limit, can use the `http.MaxBytesReader()`method like -- 

```go
// limit the request body size to 4096 bytes
r.Body = http.MaxBytesReader(w, r.Body, 4096)
err := r.ParseForm()
if err != nil {
    http.Error(w, "bad request", http.StatusBadRequest)
    return
}
```

With this cose only the first 4096 bytes of the request body will be read during the `r.ParseForm`method.

For the `multipart/form-data`-- this is a specific encoding type -- parimarily used when -- 

- Uploading files -- this is just the most common use cases, when you have an `<input type="file">`-- element in your form, must use the `enctype=“multipart/form-data”`-- this encoding allows the browser to break down the form data, including the file content, into mulpart parts and send them to the server.
- Submitting complex data - while less common than file uploads.

#### Why is it necessary for file uploads -- 

Standard form encoding `application/x-www-form-urlencoded`-- which is the *default* encodes form data into a single string of key-value pairs -- this works fine for simple text inputs but is not suitable for sending the raw binary data of a file. So need to use the `multipart/form-data`creates a separate *part* for each form control -- each with its own headers describing the data within that part.

```html
<form action="/upload" method="post" enctype="multipart/form-data">
  <label for="file">Select a file:</label>
  <input type="file" id="file" name="myFile">
  <br><br>
  <input type="submit" value="Upload File">
</form>
```



