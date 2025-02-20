# Returning Updated Documents

For some use cases it is important to return the document modified. Mdb3.2 introuced3 new collection methods to the shell to accommodate the functionality of `findAndModify`-- fore: `findOneAndDelete`, `findOneAndReplace`, and `findOneAndUpdate`. And from 4.2, `findOneAndUpdate`to accept an aggregation pipeline for the udpate. The pipeline can consists of the following -- `$addFileds`and its alias `$set`, `$project`and its alais `$unset`. And `$replaceRoot`and its alias `$replaceWith`. Fore, has:

```json
{
    "_id": ObjectId(),
    "status": "state",
    "priority": N,
}
```

Fore, may want to find the job with the highest priority in the `READY`, run the process function, and then update the status to `DONE`, might try query for the ready, sorting, and update the status.

```js
var cursor = db.processes.find({'status': 'READY'});
ps = cursor.sort({priority:-1}).limit(1).next();
db.processes.updateOne({_id: ps._id}, {$set: {status: 'RUNNING'}})
do_sth();
db.processes.updateOne({_id: ps._id}, {$set: {status: 'DONE'}})
```

This algorithm isn’t great cuz it is subject to a race condition.  In Mdb, a cursor is a fundamental concept for working with query results -- 

- Pointer to Results -- when execute a `find()`, it doesn’t immediately load all matching dcoument into memory, instead, it returns a cursor.
- Iterating through Documents -- The cursor allows U to iterate through the documents in the result set one by one or in batches.
- Server-side Control -- the cursor resides on the MDB server, and the client retreives documents as needed.

Methods -- 

- `hasNext()`- check if here are more documents to retrieve.
- `next(), limit(), skip(), sort()`
- `batchSize`-- controls the number of documents returned in each batch
- `close()`closes the cursor and releases server resources.

Situations like this are perfect for `findOneAndUpdate`-- return the item and updateit in a single operation. fore:

```js
ps = db.processes.findOneAndUpdate({status: 'READY'},
                             {$set: {status: RUNNING}},
                             {sort: {'priority': -1}, 
                             'returnNewDocument': true}) // specified return a new one
do_sth(ps)
db.processes.updateOne({_id: ps_id}, {$set: {'status': 'Done'}})
```

### Querying

- Can query for range, set inclusion, inequalities, and more by using `$`conditions.
- Queries return a dbs cursor, which *lazily* returns batches of documents as you need them
- There a lot of metaoperations you can perform on a cursor.

#### Specifying which keys to return

Sometimes U need all of the k/v pairs in a document returned. like:

```js
db.users.find({}, {username:1, email:1})
```

`_id`is returend by default, so can also use:

```js
db.users.find({}, {username:1, _id:0})
```

Limiations -- There are some restriction queries, the value of query document must be a constant as far as the dbs is concerned. like:

```js
// doesn't work
db.stock.find({in_stock: 'this.num_sold'})
```

#### Query criteria

Queries can go beyond and extract matching described in the previous -- they can match more complex criteria, such as ranges, or-clauses, and negation -- `$lt, $lte, $gt, $gte`are all comparison operators, can be like:

```js
db.users.find({age: {$gt: 18, $lte: 30}})
```

These types of range queries are often useful for dates -- like:

```js
start = new Date('01/01/2007')
db.users .find({registered: {$lt: start}})
```

And, depending on how you create and store dates, an exact match might be less useful. And to query for documents where a key’s value is not equal to a certain value, must use another conditional operator -- `$ne`

```js
db.users.find({username: {$ne: 'joe'}})
```

#### OR queries

There are two ways to do an OR query in MDB -- `$in`can be used to query for a variety of values for a single key, `$or`is just more general -- like:

```js
db.raffle.find({'tricket_no': {$in: [725,542,300]}})
```

`$in`is just flexible and allows U to specify criteria of different types as well as values. Like:

```js
db.users.find({'user_id': {$in: {12345, 'joe'}}})
```

This maches document with a `user_id`equal 12345, and document with a `user_id`equal to `joe`. If `$in`is given an array with a single value -- behaves the same as directly matching the value. The opposite of `$in`is `$nin`-- returns documents that don’t match any of the criteria in the array. like:

```js
db.raffle.find('ticket_no': {$nin: [725, 542, 300]})
```

## Confused about `nil`vs empty slices

Go developers frequent mix `nil`and emtpy slices -- may want to use one over the other depending on the use case. Meanwhile, some libraries make a distinct between the two. 

- A slice is empty if its length is equal to 0
- A slice is `nil`if it equals `nil`.

```go
func main(){
    var s []string // nil
    s = []string(nil) // nil
    s = []string{} // empty
    s = make([]string, 0) // empty
}
```

All of these are empty -- meaning the lengh equals 0, therefore, a `nil`slice is also an empty slice, however, only the first two are `nil`slice -- if we have multiple ways to initialize a slice -- which option favor -- there are two things to note -- 

- One of the main differences between a `nil`and an empty regards allocations -- initializing a `nil`doesn’t require any allocation
- *Regardless of wheter a slice is `nil`*, calling `append`works.

```go
var s1 []string
append(s1, "foo") // works
```

Consequently, if a function returns a slice, we shouldn’t do as in other languages and return a non-nil collection for diverse reasons.

```go
func f() []string {
    var s []string
    if foo() {
        s= append(s, "foo")
    }
    if bar() {
        s = append(s, "bar")
    }
    return s
}
```

For this, if both `foo`and `bar`false, will get an empty slice. In case where we have to produce a slice with a known length, should use option 4-- `s := make([]string, length)`as this 

```go
func intsToStrings(ints []int) []string {
    s := make([]string, len(ints))
    for i, v := range ints {
        s[i]= strconv.Itoa(v)
    }
    return s
}
```

Need to set the length, or capacity in such a scenaior to avoid extra allocations and copies. It’s can be helpful as a syntactic sugar cuz can pass a `nil`slice in a single inle fore -- `append`like:

`s = append([]int(nil), 42)`

Should also mention that some libraries distinguish between `nil`and empty selices -- like:

```go
var s1 []float32
customer1 := customer {
    ID: "foo",
    Operations: s1,
}
b , _ := json.Marsharal(customer1)
fmt.Println(string(b))

s2 := make([]float32, 0)
customer2 := customer {
    ID: "bar",
    Operations: s2,
}
b := json.Marshal(customer2)
fmt.Println(string(b))
```

Here, a `nil`slice is marshaled as a `null`element, where as a non-nil empty slice is marshaled as an emtpy array. And the `encoding/json`package isn’t the only pacakge from the stdlib to make this distinction -- fore, `reflect.DeepEqual`returns `false`if we compare a `nil`and a `non-nil`empty slice.

### Communicating efficiently

Message passing will degrade the performance of our app if we are spending too much time passing messages around. Since we pass *copies* of messages from one to another, will suffer the performance penalty of spending time copying the data in the messge.

Programming with Channels -- Working with channels requires a different way of programming than when using memory sharing. The idea is to have a set of goroutines, each with its own internal state, exchanging info with other goroutine by passing messages on Go’s channels.

### Reusing common patterns with Channels

When use message passing with channels in Go, there are two main guidelines to follow -- 

- Ty to only pass *copies* of data on channels -- implies that you shouldn’t pass direct pointers on channel in most cases -- Passing pointers can result in multiple goroutines sharing memory, which can create RC. If you have to pass pointer references, use data structures in an immutable fashion.
- As much as possible, try not to mix message passing patterns with memory sharing.

#### Quitting channels

What should we do if our goroutine is consuming from more than one channel -- One solution is to use q quit channel together -- with the `select`statement -- shows -- 

```go 
func printNumbers(numbers <-chan int, quit chan int) {
    go func() {
        for i:=0; i<10; i++ {
            fmt.Println(<-numbers)
        }
        close(quit)
    }()
}

func main() {
    numbers := make(chan int)
    quit := make(chan int)
    printNumbers(numbers quit)
    next := 0
    for i:=1;; i++ {
        next += i
        select {
        case numbers <- next:
        case <-quit:
            return
        }
    }
}
```

#### Pipelining with channels and goroutines -- 

The first step in app is to generate URLs of web pages that can download later, can have a goroutine generate several URLs and send them on a channel to be consumed, for starter, can simply print out the URLs. Fore the `generateUrls()`-- which creates a goroutine that generate URL strings on an output channel, the output channel is returned by the function. Trhe function also accepts a quit channel, which listens to in case it needs to stop generating URLs earliler. Will adopt a common pattern where pass the input channel as a function argument and return the output channel.

```go
func generateUrls(quit <-chan struct{}) <-chan string {
	urls := make(chan string)
	go func() {
		defer close(urls)
		for i := 100; i <= 130; i++ {
			url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
			select {
			case urls <- url:
			case <-quit:
				return
			}
		}
	}()
	return urls
}
```

Next, complete our simple app by writing the `main`-- in the `main()`-- create the `quit`channel and then call `generateUrls()`, which returns the goroutine’s output channel, then listen to both the output and the `quit`channel -- will continue writing messages from the output channel to the console until the `quit`channel is closed. 

Next will write the logic to download the contents of these pages, just need a goroutine that accepts a stream of URLs and outputs the text contents into another output stream. This can be plugged into the output of the `generateUrls`and the input of the `main`. `downloadPages()`func -- accepts both the `quit`and `urls`channels and returns an output channel contianing the downloaded pages. Creates a goroutine that uses the `select`to download each page until the `urls`channel or the `quit`channel is closed. fore:

```go
func downloadPages(quit <-chan struct{}, urls <-chan string) <-chan string {
	pages := make(chan string)
	go func() {
		defer close(pages)
		moreData, url := true, ""
		for moreData {
			select {
			case url, moreData = <-urls:
				if moreData {
					resp, _ := http.Get(url)
					if resp.StatusCode != 200 {
						panic("Server's error:" + resp.Status)
					}
					body, _ := io.ReadAll(resp.Body)
					pages <- string(body)
					resp.Body.Close()
				}
			case <-quit:
				return
			}
		}
	}()
	return pages
}
```

For this, we are passing a copy of the web document on the channel, can do this since the web pages are only a few kb of size -- using message passing for large objects, such as images or video. Can now connect this new goroutine to our pipeline easily since it accepts the same channel datatypes as the output of the `generateUrls()`function. It also returns the same output channel datatypes.

Following this pattern of accepting the input channel as a function parameter and returning the output channel makes building pipeline easy. Then `extractWords`func -- same pattern for `downloadPages()`is used. It extracts the words from the document by using regular expres-sions. Like:

```go
func extractWords(quit <-chan struct{}, pages <-chan string) <-chan string {
	words := make(chan string)
	go func() {
		defer close(words)
		wordRegex := regexp.MustCompile(`[a-zA-Z]+`)
		moreData, pg := true, ""
		for moreData {
			select {
			case pg, moreData = <-pages:
				if moreData {
					for _, word := range wordRegex.FindAllString(pg, -1) {
						words <- strings.ToLower(word)
					}
				}
			case <-quit:
				return
			}
		}
	}()
	return words
}
```

Then modify the `main`to include this new goroutine like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	results := extractWords(quit, downloadPages(quit, generateUrls(quit)))
	for result := range results {
		fmt.Println(result)
	}
}
```

This pipeline pattern gives us the ability to easily plug executions together, each execution is represented by a function that starts a goroutine accepting input channels as arguments and returning the output channels as return values. Fanning in and out -- 

DEF -- in Go, a *fan-out* concurrency pattern is when multiple goroutines read from the **same channel**, can distribute the work among a set of goroutines. Soc an *fan out* the URLs to multiple `downloadPage()`gorotuines, each doing a different download, in this example, the concurrent goroutines are load-balancing the URLs sent from the `generateURLs()`goroutine.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, 20)
	for i:=0; i<20; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	// ...
}
```

So, need a Fan-In.

## The `r.Form`map

In the code, accessed the form values via the `r.PostForm`map, But an alternative approach is to use the `r.Form`map - the `r.PostForm`map is populated only for `POST, PATCH, PUT`requests, and contains the form data from the requst body. In contrast, `r.Form`map is populated for all requests and contains the form data from any request body and query string parameters.

#### The `FormValue`and `PostFormValue`methods

And the `net/http`package also provides the methods -- `r.FormValue()`and `r.PostFormValue()`-- these are essentially shortcut functions that call `r.ParseForm()`for U, and then fetch the appropriate field value from `r.Form`or `r.PostForm`respectively.

Recommend avoiding these shortcuts cuz they *silently ignore* any errors returned by `r.PostForm()`.

Multiple-value fields -- Strictly speaking, the `r.PostForm.Get()`method that we have used above only returns the *first value* for a specific form field. This means that you can’t use it with form fields which potentially send mutliple values, such as group of checkboxes -- like:

```html
<input type="checkbox" name="items" vlaue="foo">Foo
<input type="checkbox" name="items" value="bar">Bar
```

In this case, U will need to work with the `r.PostForm`map *directly* -- the underlying type of the `r.PostForm`map is `url.Values`-- which in turn has the underlying type `map[string][]string`like:

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprintf(w, "%d: item:%s\n", i, item)
}
```

Limiting form size -- Unless U are sending multipart data `enctype=“multipart/form-data”`, then `POST.. `request bodies are limited to 10M. If exceeded, then `r.ParseForm()`will return an error. Fore:

```go
// limit the request body size to 4096 butes
r.Body = http.MaxBytesReader(w, r.Body, 4096)
err := r.ParseForm()
if err != nil {
    http.Error(w, "bad request", http.StatusBadRequest)
    return
}
```

With this code, only the first 4096 bytes of the request body will be reading during the `r.ParseForm()`.

### Validating form data

Should do validation to ensure that the form data is present, of the correct type and meets any business rules that we have -- specifically for this form we want to -- update the `snippetCreatePost`like:

```go
// ...
// initialize a map to hold any validation errors for the form data.
fieldErrors := make(map[string]string)

// Check that the title value is not blank and not more than 100 characters long.
if strings.TrimSpace(title) == "" {
    fieldErrors["title"] = "This field cannot be blank"
}else if utf8.RuneCountInString(title)>100 {
    fieldErrors["title"] = "This field cannot be more than 100 characters long"
}

// then Check that the content value isn't blank
if strings.TrimSpace(content) == "" {
    fieldErrors["content"] = "This field cannot be blank"
}

// check the expires 
if expires != 1 && expires != 7 && expires != 365 {
    fieldErrors["expires"] = "This field must be either 1, 7 or 365"
}

// If there are any errors, dump them in a plain text HTTP response
if len(fieldErrors) > 0 {
    fmt.Fprint(w, fieldErrors)
    return
}
// ... others
```

### Displaying errors and re-populating fields

Now that the `snippetCreatePost`handler is validating the data, the next stage is to manage these validation errors gracefully -- If there are any validation errors we want to re-display the HTML form, highlighting the fields which failed validation and automatically re-populating any previously submitted data.

Begin by adding a new `Form`field in the `templateData`struct like:

```go
type templateData struct {
	CurrentYear int
	Snippet     *models.Snippet
	Snippets    []*models.Snippet
	Form        any
}
```

Will use this field to pass the validation errors and prevously submitted data back to the template when we re-display the form. Then head back to our file and define a new `snippetCreateForm`type to hold form data and any validation errors -- and update our `snippetCreatePost`handler to use this.

```go
// define a struct to represent the form data and validation errors
type snippetCreateForm struct {
	Title       string
	Content     string
	Expires     int
	FieldErrors map[string]string
}
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}
	// use the r.PostForm.Get() to retrieve the form data
	expires, err := strconv.Atoi(r.PostForm.Get("expires"))
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}
	
	// create a instance of the snippetCreateForm containing values 
	// from the form and an empty map for validation errors
	form := snippetCreateForm{
		Title:       r.PostForm.Get("title"),
		Content:     r.PostForm.Get("content"),
		Expires:     expires,
		FieldErrors: map[string]string{},
	}
	
	if strings.TrimSpace(form.Title) == "" {
		form.FieldErrors["title"] = "This field cannot be blank"
	}else if utf8.RuneCountInString(form.Title) > 100 {
		form.FieldErrors["title"] = "This field cannot be more than 100 characters long"
	}
	
	if strings.TrimSpace(form.Content) == "" {
		form.FieldErrors["content"] = "This field cannot be blank"
	}
	
	if form.Expires!=1 && form.Expires!=7 && form.Expires!=365 {
		form.FieldErrors["expires"] = "This field must be either 1, 7 or 365"
	}
	
	// if there are any validation errors
	if len(form.FieldErrors) > 0 {
		data := app.newTemplateData(r)
		data.Form= form
		app.render(w, http.StatusUnprocessableEntity, "create.html", data)
		return
	}

	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOther)
}
```

So, now when there are any validation errors, we are re-displaying the `create.html`template. Just passing in the previous data and validation errors in a `snippetCreateForm`struct via the template data’s `Form`field.

#### Updating the HTML template

So the next thing that we need to do is to update `create.html`template to display the validation errors and re-populate any previous data -- just render this in the templates like `{{.Form.Title}}`and `{{.Form.Content}}`. For the validation errors, the underlying type of our `FieldErrors`is `map[string]string`-- which uses the form field names as kays. Just like: `{{.Form.FieldErrors.Title}}`in the template. With this like:

```HTML
<div>
    <label>Title:</label>
    {{with .Form.FieldErrors.title}}
    <label class="error">{{.}}</label>
    {{end}}
    <input type="text" name="title" value="{{.Form.Title}}">
</div>
```

