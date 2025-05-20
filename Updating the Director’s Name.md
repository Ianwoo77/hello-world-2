# Updating the Director’s Name

People can find movies by their title or by name of actors or directors -- ask for this is to connect to update the name of one of these directors fore -- Like:

```js
db.movies.updateMany(
	{'directors': 'H.C. Potter'},
    {$set: {
        'directors.$[hcPotter]': 'H.C. Potter (henry)'
    }},
    {
        // note that this is an array
        arrayFilters: [{hcPotter: 'H.C. Potter'}]
    }
)
```

#### Adding an actor’s name to the cast

An error in the dbs came to your attention -- the actor played the chacter -- the cast field fore find in the and the output shown in the preceding -- confirm that the actor’s name is missing -- Your task for this is to add to the cast of this movies and sort this array by actor names -- as a best practice, you should also ensure that the `cast`array has unique values -- 

1. Add to this using the `$addToSet`opertor
2. Need to sort the array 
3. lastly, create another update command and sort all the arrays

### Data Aggregation

In the previous, learned the fundamentals of interacting with MDB, with these basic operations, now begin exploring and manipulating our data would with any other dbs -- also observed how -- by fully leveraing the `find`command options, can use operators to answer more specific questions about our data.

The *aggregation pipeline* does precisely what the name implies -- it allows U to define a sereis of stages that filter, merge, and organize data with much more control than the std `find`.

#### `aggregate`is a new find --

The `aggregate`in Mdb is similar to the `find`command -- can provvide the crtieria for your queryu in form of JSON -- and it outputs a `cursor`containing the search result.

syntax -- `aggregate`command operates on a collection like other `Create, Read, Update, Delete`commands. Fore

```js
use sample_mflix;
const pipeline = [];
const options = {};
const cursor = db.movies.aggregate(pipeline, options);
```

The pipeline contains all the logic to find, sort, project, limit, transform, and aggregate our data -- the `pipeline`parameter itself is passed in as an array of JSON documents - can think of this as a series of instructions to be sent to the dbs, and then the resulting data after the final stage is stored in a `cusor`to be returned to you.

#### The pipeline -- 

As mentioned, the key element in aggregation is the pipeline, which is a series of instructions to perform on the initial collection -- can think of the data was water flowing through this pipeline -- being transformed and filtered at each steage until it is finally poured out the end of the pipeline as a result.

Sth to note about aggregations is that -- although the pipeline always begins with one collection, using certain stages, can add collections further in the pipeline -- will cover joining -- The syntax of an aggregation pipeline is very simple -- much like `aggregate`command itself, the pipeline is an array -- each item in the array being an object like:

```js
var pipeline = [
    {}, {}, {}
]
```

Conventional Block Format -- this hyphen+space to begin a new item in a specified list.

```yaml
--- # Favorite movies
- Casablanca
- North by Northwest
- The Man who Wan't there
```

#### Indentation -- 

a YAML file relies on whitespace and nesting is visible through a Py-like indentation -- like:

```yaml
turtorial: # nesting level 1
  - yaml:  # nesting level 2 (2 spaces used for indentation)
  	  name: "YAML An't markup" # string [literal] # nesting level 3 4 spaces
  	  type: awesome # string
  	  born: 2001 #number
```

#### Mapping

Is used to associate k/v pirs are unordered -- maps in YAML files can be nested by increading the indentation.

Sequences -- in YAML are represented by using the `-`and space -- like:

```yaml
language:
  - YAML
  - JAVA
  - XML
  - Python
  - C
```

#### Literals - strings

String literals in YAML do not need to be quoted -- it’s only import to quote them when they contain a value that can be mistaken for a specifal character -- 

```yaml
message: YAML & JSON # breaks as a & is a special character
message2: "YAML & JSON"
```

Folding strings  -- Can also be written in blocks and be interpreted without th enew line characters using the fold operator -- `>`like:

```yaml
message : >
  even though
  it looks like
  this is...
```

Block strings -- Can be also interpreted as blocks using pipe character:

```yaml
message: | 
  this is
  a real multiline
  message
```

Chomp characters -- Multiple strings may end with whitespace -- Preserve + and strip chomp operators can be used either to preserve or strip the whitespace -- like:

```yaml
message : >+
  this block line will be 
  interpreted as a single line with a 
  newline at the end
  
message : >-
  this without a newline
```

#### Documents

The above YAM snippet is called a document -- A single YAML file can have more than one document -- each document can be interpreted as a separte YAML file which means multiple documents can contain the same duplicate keys.

```yaml
---
# docment 1
codename: YAML
name: ...
release: 2001
---
#deocument 2
uses:
  - configuration languages
  - data persistence
  - internet messaging
  - cross-languate data sharing
---
# document 3
company: spacelift
domain: 
  - devops
  - devseopes
tutroial:
  - name: yaml
  - type: awesome
  - rank: 1
  - born: 2001
author: ...
published: true
```

Schmeas and Tags -- fore:

```yaml
literals: 
  - true
  - random
```

The way the `true`is resolved is determined by the YAML schmea that the parser has implemented.

#### YAML schemas -- 

Schmeas can be thought of as the way a parser resolves or understands nodes present in a YAML file. There are primarily 3 default schmeas in YAML -- 

- *FailSafe Schmea* understands only maps, sequences, and strings and is guaranteed to work with any YAML
- *JSON schema* understands all types supported with JSON, including boolean, null, int, and float
- *Core schema* is an exension of the JSON schmea -- making it more human-readable supporting the same types but in multiple forms.

Note that it is also possible to create you own custom schemas based on above 3 default schmeas. For the `true`-- if the parser suports only the basic schema -- `FailSafe`-- the first item will be evaluated as a string. Otherwise, it will be evaluated as a boolean.

#### YAML tags

What if we explicitly want a value to be parsed in a specific way -- say from the same example that we want the first `true`value to be parsed as a string instead of a boolean, even when the parser uses the JSON or the core schema. This is where tags comes into the picture -- can be should of *types in YAML*.

```yaml
company: !!str spacelift
domain:
  - !!str devops
  - !!str devesecopes
tutorial:
  - name: !!str yaml
  - rank: !!int 1
  - born: !!int 2001
published: !!bool true
```

We can use these tags to explicitly specify a type -- 

```yaml
scalars: 
  - !!str true
  - random
```

## Broadcasting to multiple goroutines

What if we want to find more stats from our download -- for this scenairo, let’s say that in addition to finding the longest words, want to find which words occur most frequently -- 

Need to feed the output of `extractWords()`to two goroutines -- the existing ones and an additional one called `frequentWords`-- In the previous, used the *fan-out* pattern when needed to feed the output of one computation to multiple concurrent goroutins, load-balanced the messages, with each goroutine receiving a distinct subset of the output data -- that pattern will not work -- want to send a *copy* of each output message to both the `longestWords`and `frequentWords()`.

For this, instead of fan-out, can use a broadcast-pattern -- one that replicates messages to a set of output channels -- Need to create a list of output channels and then use a goroutine that writes every received message to each cahnnel.

```go
func Broadcast[K any](quit <-chan struct{}, input <-chan K, n int) []chan K {
    outputs := createAll[K](n)
    go func() {
        defer closeAll(outputs...)
        var msg K
        moreData := true
        for moreData {
            select {
            case msg, moreData = <-inputs:
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

func createAll[K any](n int) []chan K {
    channels := make([]chan K, n)
    for i, _ := range channels {
        channles[i] = make(chan K)
    }
    return channels
}

func closeAll[K any](channels ...chan K) {
    for _, output := range channels {
        close(output)
    }
}
```

For now, can write our `frequentWords()`function -- which will identify the top 10 most frequently occuring words in our downloaded pages -- the implementation in the following is similar to the `longestWords()`func -- like:

```go
func frequentWords(quit <-chan struct{}, words <-chan string) <-chan string {
    mostFrequentWords := make(chan string)
    go func() {
        defer close(mostFrequentWords)
        freqMap := make(map[string]int)
        freqList := make([]string, 0)
        moreData, word := true, ""
        for moreData {
            select {
            case word, moreData = <-words:
                if moreData{
                    if freqMap[word]==0 {
                        freqList = append(freqList, word)
                    }
                    freqMap[word] += 1
                }    
            case <-quit:
                return
            }
        }
        sort.Slice(freqList, func(a, b int) bool {
            return freqMap[freqList[a]] > freqMap[freqList[b]]
        })
        mostFrquentWords <- strings.Join(freqList[:10], ", ")
    }()
    return mostFrequentWords
}
```

For now, can write the `frequentWords()`unit with the broadcast utility we developed -- like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	words := extractWords(quit, FanIn(quit, pages...))
	wordsMulti := Broadcast(quit, words, 2)
	longestResults := longestWords(quit, wordsMulti[0])
	frequentResults := frequentWords(quit, wordsMulti[1])
	fmt.Println("Longest words:", <-longestResults)
	fmt.Println("Frequent words:", <-frequentResults)
}
```

#### Closing channels after a condition

Havn’t really used the quit channels that we have wired into every goroutin in our app -- These quit channels can be used to stop parts of the pipeline on certain conditions -- In the app, are reading a fixed number of web pages and then processing them -- what if we wanted to process only the first 10, 000 words that download --  The `Take(n)`goroutine will only terminate pats of the pipeline by calling `close()`on the `quit`channel -- Need a goroutine that simply forwards the messages received from the input to the output channel while keeping a countdown -- like:

```go
func Take[K any](quit chan struct{}, n int, input <-chan K) <-chan K {
    output := make(chan K)
    go func() {
        defer close(output)
        moreData := true
        var msg K
        for n>0 && moreData {
            select {
            case msg, moreData = <-input:
                if moreDta {
                    output <-msg
                    n--
                }
            case <-quit:
                return
            }
        }
        if n==0 {
            close(quit)
        }
    }()
    return output
}
```

Now can add this new component to the pipeline, and make it stop the processing when it reaches a specific word count -- like:

```go
func main() {
    quitWords := make(chan struct{})
    quit := make(chan struct{})
    // ...
    words := Take(quitWords, 10000, extractWrods(...))
}
```

#### Adopting Channels as first-class objects

The prime algorithm is based on the sieve of -- which is just a simple method for checking whether a number is a prime -- The improvement available in Go over the CSP language that was defined in the original paper is that channels are first-class objects -- means that a channel can be stored as a variable and passed around to other functions -- in Go, a channel can also be passed on another channel -- This allows us to improve on the original solution by using a dynamic linear pipeline -- 

For this pipeline -- can have a goroutine generate candidate sequential numbers starting from 2, each filtering out the multiples of a prime number. In the logic -- when a number passes through all the existing goroutines and is not discarded, that manes we have found a new prime number. This new goroutine will become the new tail of the pipeline -- having this pipeline grow dynamically with the number of primes shows the advantage of treating channels as first-class objects.

```go
func primeMultipleFilters(number <-chan int, quit chan<- int) {
    var right chan int
    p := numbers
    fmt.Println(p)
    for n := range numbers {
        if n%p !=0 {
            if right == nil {
                right = make(chan int)
                go primeMultipleFitler(right, quit)
            }
            right <-n
        }
    }
    if right == nil {
        close(quit)
    }else {
        close(right)
    }
}
```

### Interface Pollution

The main caveat when programming meets abstractions is remembering that *abstractions should be discovered*, not *created*. It means that we shouldn’t start creating abstractions in our code -- if there is no immediate reason to do so -- we shouldn’t design with interfaces but wait for a concrete need. Means that we shouldn’t design with interfaces but wait for a concrete need. Should just create an interface when needed, not when we *foresee* what we could need it. 

Make sure the terms we use throughout this section -- 

- *Producer side* -- an interface defined in the same package as the concrete imp
- *consumer side* -- an interface defined in an external package where it’s used.

Common to see developers creating interfces on the producer side -- alongside the concrete imp. Fore create a specific package to store and retreive customer data -- fore:

```go
type CustomerStorage interface {
    StoreCustomer(customer Customer) error
    GetCustomer(id string) (Customer, error)
    UpdateCustomer(customer Customer) error
    GetAllCustomers() ([]Customer, error)
    GetCustomersWithoutContract() ([]Customer, error)
    GetCustomersWithNegativeBalance() ([]Customer, error)
}
```

Might -- should create and expose this interface on the producer side... whatever the reason -- this is not the best practice in Go -- Interfaces are just satisfied implicitly in Go -- tends to be a game-changer -- *Abstractions should be discovered* -- means that it’s not up to the client to decide whether it needs some form of abstraction and then determine the best abstraction level for its needs.

This means that it’s not up to the producer to foce a given abstraction for all the clients -- instead, it’s up to the celint to decide whether it needs some form of abstraction and then determine the best abstraction levels for its needs. 

```go
package client
type customerGetter interface {
    GetAllCustomers()([]store.Customer, error)
}
```

For package organization -- shows the result -- 

- Cuz the `customerGetter`interface is nly used in the `client`, can remain unexported.
- There will be no dependency from `store`to `client`cuz the interface is satisfied implicitly.

But interfaces on the producer side -- is sometimes used in the stdlib -- fore the `encoding`package defines interface implemented by other sub-packages such as `encoding/json`or `encoding/xml`. Is the `encoding`package wrong about this -- In this case, the abstractions defined in the `encoding`are used across the stdlib -- and the language designer knew that creating these abstractions up front was valueable.

In interface should live on the consumer side in most cases. However in particular contexts, may want to have it on the producer side.

## Setting up the session manager

In this, will run through the process of setting up and using the `alexedwards/scs`package -- need to create a `sessions`table in the dbs -- like:

```sql
use snippetbox;
CREATE TABLE sessions (
	token CHAR(43) PRIMARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTAMP(6) NOT NULL
);
CREATE INDEX session_expiry_idx on sessions(expiry);
```

The `data`field will contain the actual session data that U want to share betwee HTTP requests -- this is stored as *binary data* in a `BLOB`type. Like:

```go
// add a new sessionManger field to the application struct.
type application struct {
    sessionManager *scs.SessionManger
}

func main() {
    //...
    // use the scs.New() to initialize a new session manager - 
    sessionManager := scs.New()
    sessionManager.Store = mysqlstore.New(db)
    sessionManager.Lifetime = 12*time.Hour
    
    app := &application {
        //...
        sessionManager: sessionManager,
    }
    
    srv := &http.Server{
        //...
    }
}
```

For the sessions to work, also need to wrap our app routes with the middleware privded by the `SessionManager.LoadAndSave()`method. This middleware automatically loads and saves session data with every HTTP request and response. It’s important to note that we don’t need this middleware to act on *all* our app routes. Specially, don’t need it on the `/static/*filepath`route - Insted, create a new `dynamic`middleware chain containing the middleware appropriate for our dynamic app routes only -- like:

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    router.NotFound = http.HandlerFunc(func(w , r) {
        app.notFound(w)
    })
    //...
    // Create a new middleware chain containing the middleware specific to our dynamic app routes
    dynamic := alice.New(app.sessionManager.LoadAndSave)
    
    // update these routes to use the new dynamic middleware chain followed by the appropriate
    // handler function -- 
    router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
    router.Handler(http.MethodGet, "/snippet/view/:id", dynamic.ThenFunc(app.snippetView))
    //...
    standard := alice.New(app.recoverPanic, app.logRquest, secureHeaders)
    return standard.Then(router)
}
```

#### Without using slice

If are not using the `justinas/alice`to help manage your middleware chains, then you’d need to use the `http.HandlerFunc()`adapter to convert your handler functions like `app.home`to an `http.Handler`.

```go
router := httprouter.New()
router.Handler(http.MethodGet, "/", app.sessionManger.LoadAndSave(http.HandlerFunc(app.home)))
router.Handler(http.MethodGet, "/snippet/view/:id", 
               app.sessionManager.LoadAndSave(http.HandlerFunc(app.snippetView)))
```

#### Working with session data

In this put the session functionality to work and use it to persist the confirmation flash message between HTTP requests -- begin in the `handlers.go`file and update our `snippetCreatePost`so that a flash message is added to the user’s session data if -- and only if the snippet was created successuflly -- 

```go
func(app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    var form snippetCreateForm
    err := app.decodePostForm(r, &form)
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    form.checkField(validator.NotBlank(form.Title), "title", "this field cannot be blank")
    //...
    if !form.Valid() {
        data := app.newTemlateData(r)
        data.Form = form
        app.render(w, http.StatusUnprocessableEntity, "create.html", data)
        return
    }
    
    id, err := app.snippets.Insert(form.Title, form.Content, form.Expires)
    if err != nil {
        app.serverError(w, err)
        return
    }
    
    // use the Put() method to add a string value 
    // and the corresponding key flash to the session data
    app.sessionManger.Put(r.Context(), "flash", "Snippet successuflly created!")
    http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOther)
}
```

That’s nice and simple, but there are a couple of things to point out -- 

- The first parameter pass to the `app.sessionManger.Put()`is the *current request context* -- talk about the request context and how to use it later -- for now just think of it as somewhere that the session manager temporarily stores information while your handlers are dealing with the request.
- Second is the *key* for the specific message that we are adding to the session data -- subsequently retreive the message from the session data using this key too.
- If there is no existing session for the current user then a new empty, session for them will automatically be created by the session middleware.

Next we want our `snippetView`handler to retreive the flash message and pass it to the HTML template or subsequent display -- want to display message once only -- retreive and remove the message from the session data.

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    params := httprouter.ParamsFromContext(r.Context())
    id, err := strconv.Atoi(params.ByName("id"))
    if err != nil || id < 1 {
        app.NotFound(w)
        return
    }
    snippet, err := app.snippet.Get(id)
    if err != nil {
        if errors.Is(err, models.ErrNoRecord) {
            app.NotFound(w)
        }else {
            app.serverError(w, err)
        }
        return
    }
    
    // Then use the PopString() method to retreive the value for the flash key
    // PopString() also deletes the key and value from the session data
    flash := app.sessionManager.PopString(r.Context(), "flash")
    
    data := app.newTemplateData(r)
    data.Snippet = snippet
    
    // pass the flash message to the template
    data.Flash = flash
    app.render(w, http.StatusOK, "view.html", data)
}
```

And if want to retreive a value from the session data only, can use the `GetString()`method instead -- the `scs`package also provides methods for retreiving other command data types -- including `GetInt`... And if try run the app now the compiler gurmble that the `Flash`field isn’t defined in our `templateData`struct -- like:

```go
type templateData struct {
    //...
    Flash string
}
```

Then in the `base.html`file to display the flash -- like;

```html
<body>
    //...
    <main>
    	{{with .Flash}}
        <div class="flash">
            {{.}}
        </div>
    </main>
</body>
```

So for this the `{{with .Flash}}`block will only be executed in the value of the `.Flash`is not the empty string.

#### Auto-displaying flash messages

A little improvement can make is to automate the display of flash messags -- so that any message is automatically included in the next time -- like: Can do this by adding any flash message to implement data via the `newTemplateData()`helper message that -- 

```go
func(app *application) newTemplateData(r *http.Request) *templateData {
    return &templateData{
        CurrentYear: time.Now().Year(),
        // add the flash message to the template data, of one exists
        Flash := app.sessionMeanager.PopString(r.Context(), "flash")
    }
}
```

Making that change means that we no longer need to check for the flash message within the `snippetView`handler, and the code can be reverted to look like this -- 

```go
func(app *application) snippetView(w, r) {
    //...
    data := app.newTempalteData(r)
    data.Snippet= snippet
    app.render(w, http.StatusOK, "view.html", data)
}
```

#### Behind-the-scenes of session management

Like to take a moment to unpack some fo the *magic* behind the sesssion -- Can see the cookie named `session`in the request data - For the *session cookie*, also sometimes know as the session ID -- the session token is high-entropy random string -- which in my case is the value ...

It’s important to emphasize that the session token is just a random string. It doesn’t carry or convey any session data.