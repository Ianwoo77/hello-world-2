# Using Array as sets

Might want to treat an array as a set, only adding values if they are not present. Fore:

```js
// use $ne
db.users.updateOne({'author cited': {$ne: 'Riche'}},
                  {$push: {'author cited': 'Riche'}}
);
// or can use $addToSet 
db.users.updateOne({_id: ObjectId("...")},
                  {$addToSet: {'emails': 'Joe@gmail.com'}})

//Can also use in conjunction with $each to add multiple unique values like
db.users.udpateOne({_id: ObjectId(...)},
                                 {$addToSet: {'email': {$each: [...]}}})
```

Removing elements -- there are a few ways to remove elements from an array -- treat the array like a queue or stack, can use `$pop`, like `{$pop: {key: 1}}`remove from end, and -1 remove from the beginning. And sometimes an lement should be removed based on specific criteria, rather than its position in the array, `$pull`is used to remove elements of an array that match the given criteria -- like:

```js
db.lists.updateOne({}, {$pull: {todo: 'laundry'}})
```

#### Poistional array modification

Array manipulation becomes a little trickier when you have multiple values in an array and want to modify some of them -- there are two ways to manipulate values in arrays -- by position or by using position operator `$`character: For arrays use 0-based indexing, and elements can be selected *as though their index were a document key*.

```js
db.blog.updateOne({'post': post_id},
                 {$inc: {'comments.0.votes':1}}) // increment votes for first comment

// to modify without querying for the document first and examining it.
// positional operator $ figures out which element of the array the query matched
db.blog.updateOne({'comments.author': 'John'},
                 {"$set": {'comments.$.author', "jim"}}) // only updates first match
```

Updates using array filters -- 3.6 introduced -- like:

```js
db.blog.updateOne(
	{post: post_id},
    {$set: {'comments.$[elem].hidden': true}},
    {arrayFilters: [{'elem.votes': {$let: -5}}]}
)
```

### Upsert

An *upsert* is a special type of update - if no document is found that matches has a filter, a new document will be created by combining the criteria and updated documents. If a matching document is found, will be updated normally. Upserts can be handy cuz they can eliminate the need to seed you collection. Canoften have the same code created and update documents. Without an upsert might try to find the URL and increment the number of views or create a new document if the URL doesn’t exist. fore:

```js
blog = db.analytics.findOne({url:'/blog'})
if(blog) {
    blog.pageViews++;
    db.analytics.save(blog);
}else {
    db.analytics.insertOne({url: 'blog', pageviews: 1})
}
```

Note that means we are making a round trip to the dbs, plus sending an update or insert, every time someone visits a page. ALso subject to a race condition where more than one document can be inserted for a given URL. Can:

```js
db.analytics.updateOne({url:'/blog'},
    {$inc: {pageviews:1}}, {upsert:true});
```

This line does exactly what the previous code block does, except it’s safer and **atomic**. The new document is created by using the criteria document as a base and applying any modifier documents to it.

```js
db.users.updateOne({'rep': 25}, {$inc: {rep: 3}}, {upsert:true});
db.users.find() // rep: 28
```

So the `upsert`creates a new document with a `rep`of 25 and then increment that by 3 -- giving us a document where `rep`is 28, if the upsert option were not specifid, would not match any documents, so nothing would happen. And, if run this statement again, it will create another new document -- cuz the criteria does not match the only document in the collection.

Sometimes a field needs to be set when a document is created, but not changed on the subsequent updates. `$setOnInsert`operator -- sets the value of a field when document is being inserted. like:

```js
db.users.updateOne({},
    {$setOnInsert: {createdAt: new Date()}}, {upsert:true});
```

If run this again, will match the existing document, nothing will be inserted.

#### The `save`shell helper

`save`is just a shell func that lets U insert a document if it doesn’t exist and update it if it does. fore:

```js
var x = db.testcol.findOne()
x.num=42
db.testcol.save(x)
```

#### Updating multiple documents

To modify all of the documents matchin a filter, using `updateMany`-- follows the same semantics as `updateOne`and takes the same parameters.

```js
db.users.insertMany(
    [
        {birthday: '10/13/1978'},
        {birthday: '01/01/1970'},
        {birthday: '02/02/1980'},
        {birthday: '10/13/1978'}
    ]
)

db.users.updateMany({birthday: '10/13/1978'},
    {$set :{gift: 'happy birthday'}})

db.users.find()
```

## Project organization

Go language provides a lost of freedom in designing packages and modules. 

- `/cmd`-- main source files, the `main.go`of fore a `foo`app should live in `/cmd/foo/main.go`
- `/internal`-- private code don’t want other importing for their app or libs
- `/pkg`-- public code want to expose to others
- `/test`-- additional external tests and test data.
- `/configs`, `/docs`, `/examples`

### Creating Utility packages

**Bad** practice -- creating shared packages such as `utils, common, baase`... will examine the problems with such an approach and learn how to improve our organization. Fore implementing a `set`data structure -- handle it via `map[K]struct{}`type with `K`can be any type allowed in a map as a key, represents that aren’t interested in the value itself. -- like:

```go
package util
func NewStringSet(...string) map[string]struct {}
func SortStringSet(map[string]struct{}) []string {}
// will use this package like:
set := util.NewStringSet("c", "a", "b")
fmt.Println(util.SortStringSet(set))
```

The problem here is that `util`is meaningless -- could call it `common`... but it remains meaningless name that doesn’t provide any insight about what the package provides. So, instead of a `utility`, can:

```go
package stringset
func New(...string) map[string] struct{} {...}
//...
```

Removed the suffix for `NewStringSet`so just use like:

```go
set := stringset.New("c", "a", "b")
```

Could even go a step further, instead of exposing utility functions, could create a specific type and expose `Sort`:

```go
package stringset

type Set map[string]struct{}
func New(...string) Set {...}
func (s Set) Sort []string {...}
```

This change makes the client even simpler, there would only one reference to the `stringset`package like:

```go
set := strings.New("c", "a", "b")
fmt.Println(set.Sort())
```

### Package name Collisions

Occur when a variable name collides with an existing package name fore:

```go
package redis

type Client struct {...}
func NewClient *Client {...}
func (c *Client) Get(key string) (string, error) {...}

// ... use like
redis := redis.NewClient()
v, err := redis.Get("foo")
```

Note that here the `redis`variable name collides with the `redis`package name. Even though this is *allowed*, it should be avoided - indeed, throughout the scoep of the `redis`variable, the `redis`package won’t be accessible. For this problem, using package imports -- can use an alias to change the qualifier to reference the `redis`package like:

```go
import redisapi "mylib/redis"
```

Also just note that should avoid naming collision between a variable and a built-in function.

### Code documentation

Documentation is an important aspect of coding -- simplifies how clients can consume an API but can also help in maintaining a project in Go. 

First *every* exported element *Must* be documented -- whether it is a structure, an interface, a funcion... The convention is to add commetns, starts with the *name* of the exported element like:

```go
// Customer is a customer representation. 
type Customer struct{}
```

Comments should be a complete senstences and end with punctuation. Also bear in mind that when document a function should highlight what the function intends to do.

When a variable or a constant, -- two aspects -- purpose and content, the former live as code docmentation to be useful for external clients, the latter shouldn’t necessarily be public fore:

```go
// DefaultPermission is the default permission used by store engine
const DefaultPermission = 0o644 // Need read and write accesses
```

And, to help clients and maintainers understand a package’s scope, should also document each package -- like: Start the comment with `//`Package followed by the package name:

```go
// Package math provides basic constants and mathematical functions
//
// This package does not guarantee bit-identical results
// across architectures.
package math
```

Notet hat documentation is that comments not adjacent to the declaration are omitted.

### Writing to channels with `select`

Can also use`select`when need to write messages to channels -- not just when are reading messages from channels. Select statements can combine read or write blocking channel operatiosn together -- selecting case that unblocks first. In programming, can have a primerss filter -- given a stream of random numbers like:

```go
func primesOnly(inputs <-chan int) <-chan int {
	results := make(chan int)
	go func() {
		for c := range inputs {
			isPrime := c != 1
			for i := 2; i <= int(math.Sqrt(float64(c))); i++ {
				if c%i == 0 {
					isPrime = false
					break
				}
			}
			if isPrime {
				results <- c
			}
		}
	}()
	return results
}

```

For this, our goroutine outputs a subset of the number it receives on the input channel. Often, the goroutine receives a non-prime number that is thrown away. How can we feed in a stream of random numbers while reading the primes returned on another channel in one goroutien -- use `select`statement to both feed in and read primes. like:

```go
func main() {
	numbersChannel := make(chan int)
	primes := primesOnly(numbersChannel)

	for i := 0; i < 100; {
		select {
		case numbersChannel <- rand.Intn(1000000) + 1:
		case p := <-primes:
			fmt.Println(p)
			i++
		}
	}
}
```

#### Disabling select cases with `nil`channels

In go, can assign a `nil`to channel -- this has the effect of blocking the channel from sending or receiving anything like:

```go
func main() {
    var ch chan string = nil
    ch <- "message" // block
}
```

And Go has deadlock detection, so when Go notices that the program is stuck, give error message. And tryying to send to or receive from a `nil`channel on a `select`statement has the same effect of blocking the case using that channel. Using `select`with just one `nil`is not that useful, but can use the pattern of assigning `nil`to a channel to disable a case in a `select`statement.

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

For this, if use a normal `select`to consume from both the `salses`and `expense`goroutine, with one of the goroutine closing its channel earlier than the toher, would end up always executing on the closed channel case. 

Just change the channel into a `nil`channel whenever it is closed. Reading from a channel always returns two values -- the message and a flag telling us if the channel is still open. Can read the flag, and if the flag indicates that the channel has been closed, set the channel reference to `nil`.

Assigning a `nil`value to the channel variable after the receiver detects that the channel has been closed has the effect of disabling the case statement. This allows the receiving goroutine to read from the remining open channels.

```go
func main() {
	salses := generateAmounts(50)
	expenses := generateAmounts(40)
	endOfDayAmount := 0
	for salses != nil || expenses != nil {
		select {
		case sale, moreData := <-salses:
			if moreData {
				fmt.Println("sale of", sale)
				endOfDayAmount += sale
			} else {
				salses = nil
			}
		case expense, moreData := <-expenses:
			if moreData {
				fmt.Println("expense of", expense)
				endOfDayAmount -= expense
			} else {
				expenses = nil
			}
		}
	}
	fmt.Println("End of day profit and loss:", endOfDayAmount)
}
```

For this, once both channels are closed and set to `nil`, we exit the `select`loop and output the balance.

### Choosing between message passing and memory sharing -- 

We can decide whether to use memory sharing or message passing for our concurrent apps depending on the type of solution we are trying to implement.

Concurrent programming using memory sharing typically produces more tightly coupled software -- the inter-thread communication uses a common block of memory, and the boundaries of each execution are not clearly defined. In contrast, with message passing, executions can have clearly defined input and output contracts.

#### Optimizing memory consumptions -- 

With message passing, each goroutine has its own isolated state stored in memory.

```go
const allLetters = "abcdefghijklmnopqrstuvwxyz"

func countLetters(url string) <-chan []int {
	results := make(chan []int)
	go func() {
		defer close(results)
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
		results <- frequency
	}()
	return results
}
```

Can now add a `main()`that starts a goroutine for *each web page* and waits for messages from each output channel.

```go
func main() {
	results := make([]<-chan []int, 0)
	totalFrequencies := make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		results = append(results, countLetters(url))
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

In converting our program to use message passing, have avoided using mutexes to control access to shared memory since each is now only working on its own data.

## Customizing `httprouter`behavior

The `httprouter`package provides a few configuration options that you can use to custmize the behavior of your app further -- including enabling *trailing slash redirects* and enabling automatic URL path cleaning.

#### Restful routing

`GET /snippets/:id` the first reason is that `GET /snippets/:id`and `GET /snippets/new`routes *conflict* with each other -- a HTTP request to `/snippet/new`potentially matches both routes.

### Processing forms

```html
{{define "title"}}Create a new snippet{{end}}

{{define "main"}}
    <form action="/snippet/create" method="post">
        <div>
            <label>Title:</label>
            <input type="text" name="title">
        </div>

        <div>
            <label>Content:</label>
            <textarea name="content"></textarea>
        </div>

        <div>
            <label>Delete in:</label>
            <input type="radio" name="expires" value="365" checked>One year
            <input type="radio" name="expires" value="7">One Week
            <input type="radio" name="expires" value="1">One day</input>
        </div>

        <div>
            <input type="submit" value="Publish snippet">
        </div>
    </form>
{{end}}
```

contains a std HTML form which sends 3 form values, the only thing to really point out is the form’s `action`and `method`attribute -- set these up so that the form will `POST`the data to the URL.

Add a new `Create snippet`link -- like:

```html
{{define "nav"}}
    <nav>
        <a href="/">Home</a>
        <a href="/snippet/create">Create a new Snippet</a>
    </nav>
{{end}}
```

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	app.render(w, http.StatusOK, "create.html", data)
}
```

### Parsing form data

Any `POST /snippets/create`requests are already being dispatched to our `snippetCreatePost`handler. We will now update this handler to process and use the form data when it’s submitted. At a high-level, can break this down into two distinct steps -- 

1. Need to use the `r.ParseForm()`to parse the request body, this checks that the request body is well-formed, and then stores the form data in the request’s `r.PostForm`map. And if there are any errors encountered when parsing the body, the `r.ParseForm`is also idempotent.
2. Can get to the form data, contained in `r.PostForm`by using the `r.PostForm.Get()`. Fore, can retreive the value of the `title`with `r.PostForm.get(“title”)`.

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}
	// use the r.PostForm.Get() to retrieve the form data
	title := r.PostForm.Get("title")
	content := r.PostForm.Get("content")
	expires, err := strconv.Atoi(r.PostForm.Get("expires"))
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
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

#### The `r.Form`map -- 

In the code, we accessed the form values via the `r.PostForm`map, but an alternative approach is to use the `r.Form`map -- the `r.PostForm`map is populated *only* for POST, PATCH, PUT requests, and contains the form data from the request body.

In contrast, the `r.Form`map is populated for all requests irrespective of their HTTP method, and contains the form data from any request body and any query string parameters -- so, if our form was submitted to `/create?foo=bar`then get the value of the `foo`parameter by calling `r.Form.Get(“foo”)`Also note that in the event of a conflict, the request body value will take precedent over the query string parameter.

Using `r.Form`can be useful if your app sends data in a HTML form and in the URL.

#### The `FormValue`and `PostFormValue`methods

The `net/http`package also provides methods `r.FormValue()`and `r.PostFormValue()`-- these are essentially shortcut functions that call `r.ParseForm`for you. Then fetch the appropriate field value from the `r.Form`or `r.PostForm`respectively. recommend avoiding these shortcuts cuz they *sliently ignore any errors returned by `r.ParseForm()`*.