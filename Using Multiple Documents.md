# Updating Multiple Documents

`updateOne`just updates only the first documetn found that matches the filter criteria. If there are more matching documetns, will remain unchanged. To modify all of the documents matching a filter, use `updateMany`. `updateMany`just follows the same semantics as `updateOne`and takes the same parameters. Note that `updateMany`provides a powerful tool for performing 

```js
db.users.insertMany([
    {birthday: "10/13/1978"},
    {birthday: "10/13/1978"},
    {birthday: "10/13/1978"},
])

db.users.updateMany({birthday: "10/13/1978"},
    {$set: {gift: "Happy Birthday!"}})
```

For this, the call to `updateMany()`just adds a gift filed to each of the three documents we inserted into the `users`collection immediately before.

### Returning Updated Documents

`findOneAndDelete, findOneAndReplace, findOneAndUpdte`-- to accept an aggregtion pipeline for the update. The pipeline can consist of the following stags -- `$addFileds`and its alias `$set, $project`and `$unset`, and `$replaceRoot`and `$replaceWith`. fore:

```js
{
    _id: "someid",
    status: "state",
    priority: N
}
```

fore, need to find the job with the highest priority in the `ready`state. like:

```js
let cursor = db.processes.find({...:...});
ps= cursor.sort({priority:-1}).limit(1).next();
db.processes.updateOne({_id:...}, {$set: {status: "running"}});
//...
db.processes.updateOne({_id: ...}, {$set: {sttus: "done"}})
```

This, subject to a race condition -- can avoid this by checking the result as part of update query.

```js
let result = db.users.updateOne({birthday: "10/13/1978"},
    {$set: {gift: "Happy Birthday one!"}})

console.log(result.modifiedCount)
```

Situations like this are perfect for `findOneAndUpdate()`-- can return the item and updte it in a single operation.

```js
db.processes.findOneAndUpdate({'status': 'ready'},
                             {$set: {'status': 'Running'}},
                             {sort: {priority:-1}})
```

Just noticed that the status is still `READY`in the returned document cuz the `findOneAndUpdate`method defaults to returning state of the document before it was modified. An option can be passed:

```js
db.processes.findOneAndUpdate({status: 'Ready'},
                             {$set: {status: 'Running'}},
                             {sort: {priority: -1}, returnNewDocument: true})
```

## Querying

In this loks at querying in detail -- 

- Can query for ranges, set inclusion, inequalities, and more by using `$`conditionals
- Queries return a dbs **cursor**, which lazily returns batches of document as you need them
- There are a lot of meta-operations you can perform on a cursor, including skipping a certain of results, limiting the nubmer of results returned, and sorting results.

Introduction to find -- the `find`method is used to perform queries In MongoDB, querying returning a *subset of documents* in a collection, from no documents at all to entire collection. Which documents get returned id just determined by the first arg to `find`which is a document specifying the query criteria.

`db.c.find()`-- matches every document in the collection. When start adding k/v pairs to the query document, begin restricting our search -- this works for most types, number, booleans, and strings. Querying for a simple type is as easy as specifying the value that you are looking for. `db.users.find({age:27})`

```js
db.users.find({username: 'joe'})
// multiple conditions
db.users.find({username: 'joe', age: 27}) // AND
```

Specifying which key to return -- can pass a second arg to `find`or `findOne`. Like, if have a user collection and only insterested in the `username`and `email`keys like:

```js
db.users.find({}, {username:1, gift:1})
```

Can see, the `_id`keys is returned by default, Can also use this second to exclude specific like:
`db.users.find({}, {username:0})`

Limitations -- There are some restrictions on queries. The vlaue of a query document must be a **constant** as far as the dbs is concerned. Cannot refer to the value of another key in the document.

### Query Criteria

They can match more complex criteria, such as ranges, OR-clauses, and negation., `$lt, $lte, $gt, $gte`:
`db.users.find({age:{$gte:30, $lte: 33}})`This would find all documents where the `age`field. 18<age<=33. These types of range documents where the `age`field was greater then or equal.
`db.users.find({birthday: {$lt: start}})`

To query for documents where a key’s value is not equal to a certain value, U must use another operator -- `$ne`.
`db.users.find({username: {$ne: 'joe'}})`

OR queries -- And there are two ways to do an `OR`-- `$in`can be used to query for a variety of values for a single key, and `$or`is more general -- can be uesd to query for any of the given values acorss multiple keys. FORE:

```js
db.raffle.find({ticket_no: {$in: [725,452]}})
```

And `$in`is flexible and allows to specify criteria of different types as well as values. FORE, if gradually migrating to use usernames instead of user ID, can query for either by using:

```js
db.users.find({user_id: {$in: [12345, 'joe']}})
```

And the `$in`is given an array with just a single value, it behaves the same as directly matching the value like:

```js
{ticket_no: {$in:[725]}} => {ticket_no: 725}
```

And the opposite of `$in`is `$nin`-- which returns documents that don’t match any of the criteria in the array. Like:

```js
db.raffle.find({ticket_no: {$nin: [123,456]}})
```

And the `$in`just gives you an `OR`query for a single key, but for the multiple keys, need to use the `$or`conditional. Like:

```js
db.raffle.find({$or: [{ticket_no: 725}, {winner: true}]})
```

`$or`can contain other conditionals, fore, want to match any of the 3 `ticket_no`values or the `winner`like:

```js
db.raffle.find({$or: [{ticket_no: {$in: [725,523,390]}}, {winner: true}]})
```

With a normal AND-type query, want to narrow down your results as far as possible in as fiew arguments as possible. OR-type queries are the opposite.

`$not`-- is a metaconditional -- can applied on top of any criteria. like:

```js
db.users.find({id_num: {$mod: [5,1]}}) // devide by 5 and rem 1, 1, 6, 11, 16...
db.users.find({id_num: {$not: {$mod: [5, 1]}}}) // 2,3,4,5,7...
```

So `$not`can be particularly useful in conjunction with regular expressions to find all documents.

## Data Types

Logging is the act of recording events that occur during the running of a program. And it is often an undervalued activity in programming cuz it is additional work that has little immediately payback.

Go provides a `log`package in the stdlib that can use to log events while the program is running -- has default implemetnation that writes to std error and adds a timestamp. This means that you can use it out of the box of logging without configuration or setup -- 

- `Print`-- prints the logs to the logger
- `Fatal`-- Prints and calls `os.Exit`
- `Panic`-- Prints the logger and calls `panic`

And each set comes in a triple of functiosn, `Printf`

```go
func main(){
    str := "abc"
    num, err := strconv.ParseInt(str, 10, 64)
    if err != nil {
        log.Println(..., err)
    }
}
```

See this doesn’t stop and continues to the final statement of the program. Can use `Fatal`like:

```go
func main() {
	str := "abc"
	num, err := strconv.ParseInt(str, 10, 64)
	if err != nil {
		log.Fatalln("Cannot parse string", err)
	}
	fmt.Println(num)
}
```

For this time, the final statement isn’t executed, and the program ends.

And, can also use `Panic`--, call the `panic`built-in func, will halt, 

```go
if err != nil {
    log.Panicln("Cannot parse string", err)
}
```

### Change what is being logged by the std logger

Want the change what the std logger logs -- Use the `SetFlags`function to set flags... like:
`log.SetFlags(log.ldate | log.Lshortfile)`

Logging to File -- can:

```go
file, err := os.OpenFile("app.log", os.O_APPEND | OS.O_CREATE | os.O_WRONLY, 0644)
if err != nil {
    log.Fatal(err)
}
defer file.Close()
// can call `SetOutput`wtih the file as the parameter like:
log.SetOutput(file)
```

```go
func main() {
	file, err := os.OpenFile("app.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalln(err)
	}
	defer file.Close()
	writer := io.MultiWriter(os.Stderr, file)
	log.SetOutput(writer)
	log.Println("Something wrong")
}

```

Write to the screen and the file simultaneously -- could reset the log output each time... instead, just using the `io.MultiWriter()`method, and log.SetOutput(writer)

### Using Log Levels

Want to log events according to log levels -- Use the `New`function to create a logger, one for each log level, and then use those loggers accordingly. Log data is usually pretty large -- Can use log levels to make it more manageable and determine the priority of the events. Log levels indicate the event’s severity -- indicating the event’s importance. 

`Fatal Error Warn Info Debug`

To set up log levels for logs, can add the level to each line of the log. The most straightforward way of doing this is to use `SetPrefix`function like:

```go
log.SetPrefix("INFO ")
log.Println("some event happened")
```

Another method is to create new logger upfront, with each logger representing a single log level like:

```go
var (
	info *log.Logger
    debug *log.Logger
)
func init(){
    info = log.New(os.stderr, "INFO\t" log.LstdFlags)
}
```

## Data Validation

We are not validting the user input from the form in any way -- should do this to ensure that the form data is present, of the correct type and meets any business rules that we have -- 

- Check empty
- check is not more than 100 characters long
- check date value is permitted.

```go
/ initialize a map to hold any validation errors
errors := make(map[string]string)

// check for title field
if strings.TrimSpace(title) == "" {
    errors["title"] = "this field cannot be blank"
} else if utf8.RuneCountInString(title) > 100 {
    errors["title"] = "This field is too long"
}

// check that the content field
if strings.TrimSpace(content) == "" {
    errors["content"] = "this field cannot be blank"
}

if strings.TrimSpace(expires) == "" {
    errors["expires"] = "this field cannot be blank"
} else if expires != "365" && expires != "7" && expires != "1" {
    errors["expires"] = "this field is invalid"
}

// if the map has any values, dump them in a plain HTTP response and
// just return
if len(errors) > 0 {
    fmt.Fprint(w, errors)
    return
}
```

### Displaying Validation Errors and Repopulating Fields

Now that the `createSnippet`handler is validating the data the next stage is to manage these validation errors gracefully -- if there are any validation errors want to re-display the form, highlighting the fields which failed valiation and automatically re-populating any previously submitted data like:

```go
type templateData struct {
	CurrentYear int
	Snippet     *models.Snippet
	Snippets    []*models.Snippet

	FormData   url.Values
	FormErrors map[string]string
}
```

`url.Values`-- is the same underlying type as `r.PostForm`map held the data sent in the request body.

```go
if len(errors) > 0 {
    app.render(w, r, "create.page.html", &templateData{
        FormErrors: errors,
        FormData: r.PostForm,
    })	
    return
}
```

The underlying type of `FormErrors`field is a `map[string]string`-- And for maps, it’s possible to access the value for a given key by simply postfixing dot with the key name. And don’t have to be capitalized. like:
`{{.FormErrors.title}}`

And the underlying type of the `FormData`is just `url.Values`can use its `Get()`method to retreive the value for a field.
`{{.FormData.Get "title"}}`

```html
<div>
    <label>Delete in:</label>
    {{with .FormErrors.expires}}
    <label class="error">{{.}}</label>
    {{end}}
    {{$exp := or (.FormData.Get "expreis") "365"}}
    <input type="radio" name="expires" value="365"
           {{if (eq $exp "365")}}checked{{end}}>One year
    <input type="radio" name="expires" value="7"
           {{if (eq $exp "7")}}checked{{end}}>One week
    <input type="radio" name="expires" value="1"
           {{if (eq $exp "1")}}checked{{end}}>One day
</div>
```

For: `{{$exp := or (.FormData.Get "expires") "365"}}` -- creating a new `$exp`template variable which uses the `or`function to set the variable to the value yielded by the `.FormData.Get "expires"`or if empty set to “365”. Noticed here how used the `()`to group the `.FormData.Get`method and its parameters in order to pass its ouput.

And then use this variable in conjunction with the `eq`function to add the `checked`attribute to the appropriate radio.

### Scaling Data Validation

Now in the position where our app is valiating the form data according to our business rules and gracefully handling any validation errors. If application has many forms then can end up with quite a lot of repetition in your code and vlidation rules. Address this by creating a `forms`package to abstract some of this behavior and reduce the boilerplate code in our handler.

And while the approach we’ve taken is fine as a one-off, if has many forms then can ed up with quite a lot of repetition in your code and validation rules.

Address this by creating a `forms`package to abstract some of this behavior and reduce the boilerplate code in the handler -- won’t actually change how the app works for the user at all. In the errors.go file create a new `errors`type, which will use to hod the validation error messages for forms like:

```go
type errors map[string][]string

// Add implements an `Add()` to add error messages for a given field to map
func (e errors) Add(field, message string) {
	e[field] = append(e[field], message)
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

And then in the `form.go`file to ad