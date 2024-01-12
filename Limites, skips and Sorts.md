# Limits, skips and Sorts

The most common query options are limiting the number of results returned, skipping a number of results, and sorting, all these options must be added before a query is sent to the dbs. To set limit, chain the `limit`function onto your call to `find`. fore, to only return 3 results -- like:

```js
db.c.find().limit(2)
```

If there are a fewer then 2, only the number of matching documents will be returned. And `skip`just similarly to `limit`
`db.c.find().skip(3)`, will skip the first 3 documents and return the rest of the matches. If there are just fewer then 3 documents, just return nothing. For `sort`takes an object -- a set of k/v pairs where the keys are key names and the values are the sort directions. The sort direction can be 1 or -1. If multiple keys are given, the result will be sorted in that order, fore, to sort the results by `username`ascending and `age`for descending :

```js
db.c.find().sort({username:1, age:-1})
```

These three can be combined, this is often handy for pagination. like:

```js
db.stock.find({desc: 'mp3'}).limit(50).sort({price:1})
```

### Comparison Order

Mongodb has a hierarchy as to how types compare, sometimes you will have a single key with multiple types, fore, integers and booleans, or strings and nulls, if you do a sort on a key with a mix of types, there is predefined order:

#1 Minimum, #2Null, #3 Numbers, #4 strings-> #maximum value

Avaoiding large skips -- Using `skip()`for a small number of document is fine. But Note for a large number of results, `skip`can be slow, since it has to find and then *discard* all the skipped results. Most dbs keep more metadata in the index to help with skips. -- but Mongodb has not yet support this.

Paginating without `Skip`-- the easiest to do pagination is to return the first page of results using `limit`and then return each subsequent pages as an offset form the beginning. fore:

```js
// do not use like this
let page1 = db.foo.find(criteria).limit(100);
let page2 = db.foo.find(criteria).skip(100).limit(100);
```

Depending on query, can usually find a way to paginate wihout skips. FORE, suppose want to display document in descending order based on `date`fore, like:

```js
var page1 = db.foo.find().sort({'date': -1}).limit(100)
```

Then, note, assuming the `date`jsut unique, can use the `date`value of the last document as their criterion for fetching the next page like:

```js
let latest=null;
while(page1.hasNext()) {
    latest = page1.next();
    display(latest);
}
let page2 = db.foo.find({date: {$lt: latest.date}});
page2.sort({date:-1}).limit(100);
```

### Finding a Random Document

One fairly common problem is how to get a random document from a collection. The navie and slow solution is to count the number of documents and then do a `find`, skipping a random number of documents between 0 and size of collection just like:

```js
// do not use this
let total = db.foo.count(); 
lset random = Math.floor(Math.random()*total)
db.foo.find().skip(random).limit(1)
```

It is just actually highly inefficient to get a random element this way -- you have to do a count, and skipping large numbers of elements can be just time-consuming. There is aslo much more efficient way to do so. The trick is to add an extra random key to each document when it is inserted, fore:

```js
db.people.insertOne({name: 'joe', random: Math.random()});
db.people.insertOne({name: 'John', random: Math.random()});
db.people.insertOne({name: 'jim', random: Math.random()});
```

Now when want to find a random document from the collection, can calculate a random number and use that as qeury criterion -- instead of using `skip`just like:

```js
let random = Math.random();
let result = db.people.findOne({random: {$gt: random}})
print(result)
```

If there aren’t any documents in the collection, this technique will end up returning `null`. This technique can be also used with arbitarily complex queries -- just amke sure to have an index that includes the random key.

## Indexes

Introduce Mongodb Indexes -- enable you to perform queries efficiently, they are an important part of application developmen and are even requried for certain types of queries -- 

- Waht indexes are and why want to use them
- choose which field as index
- enforce and evaluate index usage
- Administritive details on creating and removing indexes

A query that does not use an index is just called *collection scan*, which just means that the server has to look through the hole book to find a query’s results. This process is basically what you’d do if you were looking for info in a book without an index.

```js
for (let i = 0; i < 100000; i++) {
    db.users.insertOne(
        {
            i: i,
            username: 'user' + i,
            age: Math.floor(Math.random() * 120),
            created: new Date(),
        }
        )
}
```

For this, if do a query on this col, can use the `explain`command to see what MongoDB is doing when it executes query. And the preferred way to use the `explain`is through the cursor helper method that wraps this command.

```js
let ex= db.users.find({username: 'user101'}).explain('executionStats')
print(ex)
```

The preferred way to use the `explain`command is through the cursor helper method that wraps this command. The `explain`cursor method provides info on the execution of a variety of *CRUD* opertions.

### Creating an Index

```js
db.users.createIndex({username:1})
```

Creating the index should take no longer then a few seconds, unless made your collection especially large. If the `createIndex`call does not return after a few seconds, run the `db.currentOp()`or check log.

```js
db.users.find({username: 'user999'})
```

An index can make a dramatic difference in query times. -- Note that the indexes have their own price, write operations that modify an indexed field will take longer, this is cuz in addition to updating the document, MongoDb has to update indexes when your data changes. Typically, the tradeoff is worth it. And to choose which fields to create index for, look through your frequent queries and queries that need to be fast and try to find a common set of keys from those.

## CSV Recipes

The CSV format is a file format in which tabular data can be easily written and read in a text editor. For the Go stdlib has an `encoding/csv`package that support CSV.

Reading whole CSV -- using ghe `encoding/csv`package and `csv.ReadAll()`to read all data in the CSV file into a 2d Array of strings like: First, open the file using `os.Open()`get a `os.File`struct then use as a parameter to `csv.NewReader()`Creates a new `csv.Reader`struct that can be used to read data from the CSV. With this csv reader, can use `ReadAll()`to read all the data in the file and just returna 2D array of `[][]string`

```go
func main() {
	file, err := os.Open("users.csv")
	if err != nil {
		log.Println("Cannot open CSV file", err)
	}
	defer file.Close()
	reader := csv.NewReader(file)
	rows, err := reader.ReadAll()
	if err != nil {
		log.Println("Cannot read csv file: ", err)
	}
	fmt.Println(rows)
}
```

### Reading one row at a time

Use the `encoding/csv`package and `csv.Read()`-- Reading a CSV file all at once is -- have a very large csv file, it might be easier to read it one row at a time -- use the same CSV file -- using the `csv.NewReader()`and create a new `csv.Reader`struct like:

```go
reader := csv.NewReader(file)
for {
    record, err := reader.Read()
    if err == io.EOF {
        break
    }
    if err != nil {
        log.Println("Cannot read csv file", err)
    }
    for value := range record {
        fmt.Printf("%s\n", record[value])
    }
}
```

### Unmarshalling CSV Data into Structs

Want to unmarshal CSV data into structs instead of a 2d array of strings -- For some other formats like JSON or XML, it’s common to unmarshal the data read from files into structs, can also do this in CSV like:

```go
type User struct {
	Id                         int
	firstName, lastName, email string
}

func main() {
	file, err := os.Open("users.csv")
	if err != nil {
		log.Println("Cannot open CSV file", err)
	}
	defer file.Close()
	reader := csv.NewReader(file)

	var users []User
	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Println("Cannot read csv file", err)
		}
		id, _ := strconv.ParseInt(record[0], 0, 0)
		user := User{int(id), record[1], record[2], record[3]}
		users = append(users, user)
	}
	fmt.Println(users)
}
```

### Removing the Header line

If CSV file has a line of headers that are column labels, will get that as well in your returned 2d array of strings or array of structs, wnat to remove it.

```go
func main() {
	file, err := os.Open("users.csv")
	if err != nil {
		log.Println("Cannot open csv file", err)
	}

	defer file.Close()
	reader := csv.NewReader(file)
	reader.Read() // just remove the first line
	rows, err := reader.ReadAll()
	if err != nil {
		log.Println("Cannot read csv file", err)
	}
	fmt.Println(rows)
}
```

### Using different Delimiters

CSV doesn’t necessarily use commas as delimiters. Set the `Comma`variable in the `csv.Reader()`struct instance to the delimiter used in the file and read as before just like:

```go
file, err := os.Open("user2.csv")
if err != nil {...}
defer file.Close()
reader := csv.NewReader(file)
reader.Comma=';' // change the Comma to the delimiter in the file
//...
```

Ignoring Rows -- want to ignore certain rows when reading -- use comments in the file to indicate the rows to be ignored. Then enable coding in the `csv.Reader`and read the file as before like:

```go
//...
defer file.Close()
reader := csv.NewReader(file)
reader.Comment = '#'  // lines that strt with this will be just ignored
//...as before
```

### Writing CSV files

Want to write data from memory into a CSV file -- Use the `encoding/csv`package and `csv.Writer`to write to file.

```go
file, err := os.Create("new_users.csv")
if err != nil {
    log.Println(...)
}
defer file.Close()
data := [][]string{
    {"id", "first_name", "last_name", "email"},
    {"1", "Sausheong", "Chang", "sausheong@email.com"},
    {"2", "John", "Doe", "john@email.com"},
}

writer := csv.NewWriter(file)
err = writer.WriteAll(data)
if err != nil {
    log.Println("Cannot write to CSV file", err)

```

### Writing to File one row at a time

Instead of writing everything in your 2D string, want to write to the fiel one row at a time -- Use the `Write`method on the `csv.Writer`to write a single row like -- writing a file one row at a time is pretty much the same, except you will want to iterate the 2d array of strings to get each row and then call `Write`. just like:

```go
writer := csv.NewWriter(file)
for _, row := range data {
    err = writer.Write(row)
    if err != nil {
        log.Println("Cannot write to CSV", err)
    }
}
writer.Flush()
```

## Scaling Data Valiation

And while the approach we’v taken is fine as a one-off, if your application has many forms then you can end up with quite a lot of repetition in your code and vlidation rules. Then in the `pkg/forms`folder adding two files forms.go and errors.go files like:

```go
// define a new errors type, which we will use to hold the validation error
// messages for forms
type errors map[string][]string

// implementing an Add to add error messages for a given field to the map
func(e errors) Add(field, message string){
	e[field]=append(e[field], message)
}

// Get implements a Get() to retrieve the first error for a given field
func (e errors) Get(field string) string {
	es := e[field]
	if len(es) == 0 {
		return ""
	}
	return es[0]
}
```

Then in the `form.go`file to add the following code like:

```go
package forms

import (
	"fmt"
	"net/url"
	"strings"
	"unicode/utf8"
)

// Form Create a custom struct, annonymously embeds a url.Values
// to hold the form data and errors filed
type Form struct {
	url.Values
	Errors errors
}

// New define a new func to initialize a custom struct like
func New(data url.Values) *Form {
	return &Form{
		data,
		errors(map[string][]string{}),
	}
}

// Required then implement a required method to check that specific fields in the form
func (f *Form) Required(fields ...string) {
	for _, field := range fields {
		value := f.Get(field)
		if strings.TrimSpace(value) == "" {
			f.Errors.Add(field, "This field cannot be blank")
		}
	}
}

// MaxLength Implement a MaxLength method to check that a specific field in the form
// contains a maximum number of characters. If the check fails then add the
// appropriate message to the form errors.
func (f *Form) MaxLength(field string, d int) {
	value := f.Get(field)
	if value == "" {
		return
	}
	if utf8.RuneCountInString(value) > d {
		f.Errors.Add(field, fmt.Sprintf("This field is too long "+
			"(maximum is %d characters)", d))
	}
}

// PermittedValues Implements a PermittedValue method to check that a specific field in the form
// matches one of a set of specific permitted values.
func (f *Form) PermittedValues(field string, opts ...string) {
	value := f.Get(field)
	if value == "" {
		return
	}

	for _, opt := range opts {
		if value == opt {
			return
		}
	}
	f.Errors.Add(field, "This field is invalid")
}

// Valid implement a valid method return true if there are no errors
func (f *Form) Valid() bool {
	return len(f.Errors) == 0
}

```

Then the next step is up update the `templateData`struct so that we can pass this new `forms.Form`struct to our templates like:

```go
type templateData struct {
	CurrentYear int
	Snippet     *models.Snippet
	Snippets    []*models.Snippet

	Form *forms.Form
}
```

Then need to update it to use the `forms.Form`struct and validation methods that just created like:

```go
if len(errors) > 0 {
    app.render(w, r, "create.page.html", &templateData{
        Form: forms.New(nil),
    })
    return
}

// create a new forms.Form struct containing the POSTed data from 
// the form, then use the validation methods to check the content like:
form := forms.New(r.PostForm)
form.Required("title", "content", "expires")
form.MaxLength("title", 100)
form.PermittedValues("expires", "365", "7", "1")

// If the form isn't valid, redisplay the template passing in the 
// form.Form object as the data.
if !form.Valid() {
    app.render(w, r, "create.page.html", &templateData{Form: form})
    return
}
id, err := app.snippets.Insert(form.Get("title"), form.Get("content"),
                               form.Get("expires"))
```

And all that is left to update the `create.page.html`file to use the data contained in the `form.Form`struct:

```html
{{with .Errors.Get "expires"}}
	<label class="error">{{.}}</label>
{{end}}
```

Have now got a `forms`package with validation rules and logic that can be re-used across our application.

## Stateful HTTP

A nice touch to improve our user experience would be to display a one-time confirmation message which the user sees after they have added a new snippet. So a confirmation message like this should only show up for the user once and no other users should ever see the message. To make this work, need to start sharing data between HTTP requests for the same user. The most common way to do that is to implement a session for a user

- What *session managers* are available to help us implement sessions in Go
- How U can customize session behavior based on your app’s needs
- How to *use sessions* to safetly and securely share data between requests for a particular user.

### Installing a Session Manager

There is a lot of *security considerations* when it comes to working with sessions, and proper implementation is non-trivial - Unless U really need to roll own implementation it’s a good idea to use an existing, well-tested, and 3rd-party package -- unlike routers, there is only a few good session for Go -- like:

- `gorilla/sessions`-- will-known package -- a simple and easy-to-use API and supports a huge range 3rd-party session stores including **MYSQL, PostgreSQL**.
- `alexdwards/scs`-- another which supports a variety of server-side session sores including ..

Will use `golangcollege/sessions`-- provides a cookie-based session store using encrypted and authenticted cookeis. For html-based happy to use cookie-based sessions then using package this.

`go get github.com/golangcollege/sessions`

### Setting up the Session Manager

In this, using the `golangcollege/sessions`-- first thing to do is establish a session manager in our `main.go`find and make it available to our handlers via the `application`struct. The session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving session data.

```go
type application struct {
	//...
	session *sessions.Session
}

// ... 
secret := flag.String("secret", "some_secret_code", "secret Key")
//...
session := sessions.New([]byte(*secret))
session.Lifetime = 12*time.Hour
app := &application {
    //...
    session: session,
}
```

For this to work, also need to wrap our application routes with the middleware provided by the `Session.Enable()`method. this method loada and saves session data to and from the session cookie with every HTTP request and response as appropriate. And it’s important to note that don’t need this middleware to act on *all* our app routes. Fore, don’t need on the `/static`route. So, cuz of that, it doesn’t make sense to add the session middleware to our existing `standardMiddleware`chain. 

Instead, create a new `dynamicMiddleware`chain containing the middleware appropratie for our dynamic app routes only like: