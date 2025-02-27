# Query Arrays and Nested Documents

It’s extremely important to have a mechanism to easily search for and retrieve the information stored in such complex structures. First, will learn how to run queries on the array elements, and then will learn how to run them on nested object fields.

#### Finding an array by an element

```js
// find jsut by name in array
db.movies.find({cast: {$regex: 'charles chaplin', $options: 'i'}})
```

When execute this and project only the `cast`field, 

```js
db.movies.find({$and:[
    {cast: 'Charles Chaplin'},
    {cast: 'Edna Purviance'}]},
    {cast: 1, _id: 0})
```

#### Finding an Array by an array

Just searching for arrays using the value of an element - similarly, array fields also be searched using array values. However, when you search an array field using an array value, the elements and their order must match.

```js
db.movies.find({languages: ['English', 'German']})
```

The preceding output shows that when search by using an array, the value is matched exactly. When array fields are searched using an array value, the value is matched using an equality check. Any two arrays only pass the equality check if they have the same elements in the same order.

#### With the `$all`operator

The `$all`operator finds all those documents where the value of the field contains all the elements, irrespective of their order or size. Fore:

```js
db.movies.find(
    {languages: {$all: ['English', 'French']}},
    {languages: 1, _id: 0}
)
```

The ouput indicates that the `$all`operator has matched arrays, irrespective of the order and size of the element.

#### Projecting Array elements

There are a few ways to limit how many elements of an array are returned in the qeury output. Similar to elements in an array can also be *projected* -- in this, will learn how to limit the result set when we search with an array field.

Using `$`to exclude but the first *matching* element of the array.

```js
db.movies.find(
    {languages: {$all: ['English', 'French']}},
    {'languages.$':1, _id:0}
) // display only `French`
```

The array field in the output only contains the matching element, the rest of the elements are skipped.

#### Projecting mathching elements by their index position `$slice`

The `$slice`operator is used to limit the array elements based on their index position -- This can be used with any array field, irrespective of the field being queried or not.

```js
db.movies.find(
    {title: 'Youth Without Youth'},
    {languages: {$slice: 3}, _id:0},
)
```

The output will show that the `languages`fild only contains the first 3 elements. And the `$slice`also be passed with two arguments, the first indicates the number of elements to be skipped and the second one indicates the number of elements to be returned.

### Querying Nested Objects

Similar to arrays, nested or embedded objects can also be represented as values of fields -- Hence, fields that have other objects as their values can be searched using the complete object as a value. In the `movies`collection, there is a field named `awards`whose value is a nested object -- the following shows object for a random movie in the collection:

```json
"awards" :{
    "wins":1
    "nominations": 0,
    "text": "1 win."
}
```

So the following query finds the `awards`object by providing the complete object as value like:

```js
db.movies.find(
    {awards: {wins:1, nominations: 0, text: '1 win.'}}
)
```

When nested object fields are searched with object values, must be *exact match*. This means that all the filed-value pairs, along with the *order* of the fields, must match exactly.

#### Querying Nexted object Fields

Saw that fields of nested objects can be accessed using `.`-- Similarly, can be used to search nested objects by providing the values of its fields. Just like:

```js
db.movies.find(
    {'awards.wins': 4}
)
```

The `.`notation on the field and refers to the nested field named `wins`And the nested field seaerch is performed indpendently on the given fields, irrespective of the order of elements.  Can search by multiple fields and use any of the conditional or logical query operators -- fore:

```js
db.movies.find(
    {'awards.wins': {$gt: 5}, 'awards.nominations':6},
    {awards:1}
)
```

This query uses a combination of two conditions on two different nested fields.

## Using `defer`inside a loop

The `defer`statement delays a call’s execution until the surrounding function returns -- It’s mainly used to reduce boilerplate code -- Fore, if a resource has to be closed eventaully, can use `defer`to avoid repeating the closure calls before every single `return`. One common mistake is to be unware of the consequences of using `defer`inside a loop .

Fore, will implement a func that opens a set of files where the file paths are recevied via a channel -- iterate over this channel , open, and handle the closure like:

```go
func readFile(ch <-chan string) error {
    for path := range ch {
        file, err := os.Open(path)
        if err != nil {
            return err
        }
        defer file.Close()
        //...
    }
    return nil
}
```

There is a significant problem with this implementation. Have to recall the `defer`schedules a function call when *surrounding function returns*. In this case, the defer calls are executed not during each loop iteration, but when the `readFiles()`returns. So, if `readFiles`doesn’t return, the file descriptors will be kept open forever.

What are the options to fix this problem -- For this, have to create another surrounding function around the `defer`that is called during each iteration. Just add another function like:

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        if err := readFile(path); err != nil {
            return err
        }
    }
    return nil
}

func readFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()
    //... do sth for file
    return nil
}
```

And in this imp, the `defer`function is called when `readFile`returns, meaning at the end of each iteration. Therefore, we do not keep file descriptors open until the parent `readFile`function returns.

Another approach could be make the `readFile`just a closure -- 

```go
func readFile(ch <-chan string) error {
    for path := range ch {
        err := func() error{
            //... do sth
            defer file.Close()
        }()
        if err != nil {
            return err
        }
    }
    return nil
}
```

Intrinsically, this just remains the same solution.

### Knowing which type of receiver to use

Choosing a receiver type of a method isn’t always straightforward -- Only scratch the surface in terms of performance. Also, in many contexts, using a value or pointer receiver should be discated not by performance but rather by other conditions that we will discuss. Fore:

```go
type customer struct {
    balance float64
}
func (c customer) add(v float64) {
    c.balance += v
}
```

Cuz we use a value receiver, incrementing the balance in the `add`doesn’t mutate the `balance`. So:

```go
func (c *customer) add(operation float64) {...}
```

A receiver must be a pointer -- 

- If the method needs to mutate the receiver, note that the rule is also **valid** if the revceiver is a slice and the method needs to *append* elements.

  ```go
  type slice []int
  func(s *slice) add(element int) {
      *s = append(*s, element)
  }
  ```

- If the method receiver contains a field that cannot be copied -- fore, type of part of `sync`package

Should be a pointer -- 

- If receiver is a large object.

Must be a value -- 

- If have to enforce a receiver’s immutability
- If receiver is a *map, function, channel* -- otherwise, a compilation error occurs

Should be a value -- 

- If the receiver is a slice that doesn’t have to be mutated
- is a small array or struct , fore `time.Time`fields, namely, without mutable fields
- If the receiver is a basic type such as `int...`

And, one case needs more discussion -- say that we design a different `customer`struct like: Its mutable fields aren’t part of the struct directly but are inside another struct -- like:

```go
type customer struct {
    data *data
}
type data struct {
    balance float64
}
func (c customer) add (operation float64) {
    c.data.balance += operation
}
func main() {
    c := customer {data: &data {balance:100}}
    c.add(50.)
    print(c.data.balance) // 150 even though the receiver is a value
}
```

In this case, don’t need the receiver to be a pointer to mutate `balance`.

### Using named result parameters

Named result parameters are an infrequently used option in Go. When is it recomended that use named result parameters -- consider the following interface like:

```go
type locator interface {
    getCoordinates(address string)(float32, float32, error)
}
```

Cuz this interface is unexported, documentation is not mandatory -- But need to guess the usecase of the `float32`s. In this case, should probably use named result parameters to make the code easier to read like:

```go
type locator interface {
    getCoordinates(address string) (lat, lng float32, err error)
}
```

With this, can understand the meaning of the method signature by looking at the interface. Then -- should we also use named result parameters as part of the implementation of method -- 

```go
func (l loc) getCoordinates(address string) (lat, lng float32, err error) {...}
```

In this sepcific case, having an expressive method signature can also help code readers. Hence, we propably want to use named result parameters as well.

Consider another function signagure that allows us to store a `Customer`in a dbs -- 

```go
func StoreCustomer(customer Customer) (err error) {...}
```

For this, naming the `error`parameter isn’t helpful and doesn’t help readers. So, when to use named result parameters depends on the context. In most cases, if it’s not clear whether using them makes our code more readable, shouldn’t.

Also need to note that having the result parameter already initialized can be quite handy in some contexts.

### Broadcasting to multiple goroutines --

What if we want to find out more stats from our download pages -- for this scenario, say that in addition to finding the longest words, want to find which words occur most frequently -- for this scenario, feed the output of `extractWords()`to two goroutines -- the exising one and an additional one called `frequentWords()`-- the pattern of the new func will be the sme as that of `longestWords()`-- it will store the frequency of each unique word, and then the input closes, it will output the top 10 most often-occurring words.

Used the `fan-out`pattern when needed to feed the output of one computation to multiple concurrent goroutines. We load-blanced the messages, which each goroutine receiving a distinct subset of output data. That pattern will not work here -- want to send a copy of each output message to both `longestWords`and `frequentWords()`goroutine.

Instead of fan-out, can use the broadcast pattern -- one that replicates messages to a set of output channels. To implement -- just need to createa  list of output channels and then use a goroutine that writes every received to each channel -- Just like;

```go
func Broadcast[K any](quit <-chan int, input <-chan K, n int) []chan K {
    outputs := CreateAll[K](n)
    go func() {
        defer CloseAll(outputs...)
        var msg K
        moreData := true
        for moreData {
            select {
            case msg, moreData = <-input:
                if moreData {
                    for _, output := range outputs {
                        output <-msg
                    }
                }
            case <-quit:
                return
            }
        }
    }()
    return outputs
}
```

In the broadcast imp, read the next message only after the current has been sent to all the channels.

```go
func CreateAll[K any](n int) []chan K {
    channels := make([]chan K, n)
    for i, _ := range channesl {
        channels[i] = make(chan K)
    }
    return channels
}

func CloseAll[K any] (channels ...chan K) {
    for _, output := range channels {
        close(output)
    }
}
```

Now write the `frequentWords()`func -- which will identify the top 10 most frequently occuring words in our pages.

```go
func frequentWords(quit <-chan int, words <-chan string) <-chan string {
    mostFrequentWords = make(chan string)
    go func() {
        defer close(mostFrequentWords)
        freqMap := make(map[string]int)
        freqList := make([]string, 0)
        moreData, word = true, ""
        for moreData {
            select {
            case word, moreData = <-words:
                if moreData {
                    if freqMap[word]==0 {
                        freqList = append(freqList,word)
                    }
                    freqMap[Word]+=1
                }
            case <-quit:
                return
            }
        }
        sort.Slice(freqList, func(a, b int) bool {
            return freqMap[freqList[a]] > freqMap[freqList[b]]
        })
        mostFrequentWords <- strings.Join(freqList[:10], ", ")
    }()
    return mostFrequentWords
}
```

Then just like:

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    urls := generateUrls(quit)
    pages := make([]<-chan string, downloaders)
    for i:=0; i<downaloaders; i++ {
        pages[i]= downloadPage(quit, urls)
    }
    words := extractWords(quit, FanIn(quit, pages...))
    wordsMulti := Broadcast(quit, words, 2)
    longestResults := longestWords(quit, wordsMulti[0])
    frequentResults := frequentWrods(quit, wordsMulti[1])
    print(<-longestResults)
    print(<-frequentResults)
}
```

#### Closing channels after a condition

Haven’t really used the quit channels that we have wired into every goroutine in our application. These quit channels can be used to stop parts of the pipeline on certain conditions. In app, are reading a fixed number of web pages and then processing them. But, what if we want to process only the first 10000 words that we download -- The solution is to add another execution that stops a section of our pipeline after it has consumed a specified number of messages. If insert a new goroutine -- called `Take(n)`-- just after the `extractWords()`goroutine, can insert it to close the `quit`channel after receiving a specified number of messages. The `Take(n)`will only terminte parts of the pipeline by calling `close()`on the `quit`channel.

To implement, need a goroutine that simply forwards the messages received from the input to the output chanenl while keeping a countdown, with every message forwarded reducing this by 1. It will close the `quit`channel only if the countdown hits 0 like:

```go
func Take[K any](quit chan struct{}, n int, input <-chan K) <-chan K {
	output := make(chan K)
	go func() {
		defer close(output)
		moreData := true
		var msg K
		for n > 0 && moreData {
			select {
			case msg, moreData = <-input:
				if moreData {
					output <- msg
					n--
				}
			case <-quit:
				return
			}
		}
		if n == 0 {
			close(quit)
		}
	}()
	return output
}
```

Then just like:
`words := Take(quitWords, 10000, extractWords(quit, FanIn(quit, pages...)))`

## Working with session data

In this chapter put the session functionality to work and use it to perist the confirmation flash message *between HTTP requests* that we discussed earlier -- 

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    var form snippetCreateForm
    err := app.decodePostForm(r, &form)
    if err != nil {...}
    form.CheckField(validator.NotBlank(form.Title), ...)
    //...
    if !form.Valid() {
        data := app.newTempalteData(r)
        data.Form= form
        app.render(w, http.StatusUnprocessableEntity, "create.html", data)
        return
    }
    id, err := app.snippets.Insert(form.Title, form.Content, form.Expires)
    if err != nil {
        //...
    }
    
    // Use the `Put()` method to add a string value
    app.sessionManger.Put(r.Context(), "flash", "snippet successuflly created!")
    http.redirect(...)
}
```

The session like:

```go
sessionManager := scs.New()
sessionManager.Store = mysqlstore.New(db)
sessionManager.Lifetime= 12*time.Hour
```

Configure it to use our mySQL dbs as the session store. For the sessions to work also need to wrap our app routes with the middleware provided by the `SessionManager.LoadAndSave()`method. This middleware automatically loadas and saves session data with *every HTTP request and response*.

```go
func (app *application) routes() http.Handler {
    //...
    dynamic := alice.New(app.sessionManger.LoadAndSave)
    router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
    //...
}
```

Then need to use the `http.HandlerFunc()`adapter to convert your handler functions like `app.home`to a `http.Handler`-- and then wrap that with session middleware instead.

- The first parameter passed to the `app.sessionManager.Put()`, is the *current request context* -- Can just think of it as somewhere the session manager temporarily stores info while your handlers are dealing with the request.
- The second parameter -- is the *key* for the specific message that we are adding to the session data.
- If there is no existing session for the current user, then a new, empty, session for them will automatically be created by the session middleware.

Next up we want our `snippetView`handler to retrive the flash message -- and pass it to the HTML template for subsequent display -- cuz want to display the flash message once only, actually want to retreive and remove the message from the session data.

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    //...
    // use the `PopString()` method to retreive the value for the flash key
    // PopString() also deletes the key and value from the session data.
    flash := app.sessionManager.PopString(r.Context(), "flash")
    data := app.newTemplateData(r)
    data.Snippet = snippet
    data.Flash = flash
    app.render(w, http.StatusOK, "view.html", data)
}
```

Then if try to run the application now, the compiler will grumble that the `Flash`field isn’t defined in our `templateData`struct, Go ahead and add in like so:

```go
type templateData struct {
    //...
    CurrentYear   int
    Snippet 	 *models.Snippet
    Snippets 	 []*models.Snippet
    Form 		any
    Flash 		string
}
```

Then render for that like:

```html
<main>
	{{with .Flash}}
    <div class="flash">
        {{.}}
    </div>
    {{end}}
    {{template "main" .}}
</main>
```

`{{with .Flash}}`block will only be executed if the value of `.Flash`is *not the empty string*. If you refreshing the page, can confirmation flash message is no longer shown.

#### Auto-displaying flash messsages

A little improvment we can make is to automate the display of flash messages, so that any message is automatically included the next time any *page* is rendered. `newTemplateData()`helper method that we made eariler.

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
	return &templateData{
		CurrentYear: time.Now().Year(),
		Flash: app.sessionManager.PopString(r.Context(), "flash"),
	}
}
```

Mkaing that change means that no longer need to check for the flash message within the `snippetView`handler.

#### Behind-the-scenes of session mangement -- 

Like to take a moment to unpack some of the magic behind session management and explain how it works behind the scenes -- If like open up the developer tools in web. This is the *session cookie* and it aill be sent back to the `Snippetbox`application with every request that your browser makes. The session cookie contains the *session token* -- also sometime know as the *session ID*.

Each and every time we make change to our session data, this `data`value will be updated to reflect the changes.

