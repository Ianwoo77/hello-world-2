# Addming Multiple Elemments(II)

`$push`just can add one element at a time -- to add multiple elements to an array in a single update command, have to use the `$push`along with the `$each`-- Just like:

```js
db.movies.findOneAndUpdate(
    {_id: 111},
    {
        $push: {
            genre: {
                $each: ['History', 'Action']
            }
        }
    },
    {returnNewDocument: true}
)
```

The preceiding update operation finds and update a document by its `_id`field and uses `$push`to add element to the `genre`field.

#### Sort array

Arrays in Mdb -- in general, are an ordered but unsorted collection of elements -- the elements of the array will always remain in the order in which they were inserted -- 

```js
db.movies.findOneAndUpdate(
    {_id: 111},
    {
        $push: {
            genre: {$each: [], $sort: 1}
        }
    },
    {returnNewDocument: true}
)
```

In this use the `$push`in the `genre`fielld, one thing to note is that this query is not pushing any element to the array cuz there are no elements provided to the `$each`operator.

```js
db.items.findOneAndUpdate(
    {_id: 11},
    {
        $push: {
            items: {
                $each: [],
                $sort: {price: -1}
            }
        }
    },
    {returnNewDocument: true}
)
```

The update command finds one document and sorts the array field.

#### An array as a set

An array is an ordered collection of elements that can be iterted over or accessed using its specific index position. The `$addToSet`-- like:

```js
db.movies.findOneAndUpdate(
    {_id: 111},
    {$addToSet: {'genre': {$each: ['History', 'Action']}}},
    {returnNewDocument: true}
)
```

As can see, the `Action`element was not pushed to the array cuz the array already contains it. -- The same behavior evident even when we `$push`to push multiple.

#### New Category of Classic Movies

Fore, taks is to put a filter on the meter filed in both of the `viewer`and `critci`sub-objects find classic movies and assign them the new genre -- the following steps will help U to complete like:

```js
db.movies.updateMany(
    {
        'tomatoes.viewer.meter': {$gt: 95},
        'tomatoes.critic.meter': {$gt: 95}
    },
    {$addToSet: {genres: 'Classic'}}
)
```

#### Removing Array Elements

The `$pop`operator -- used in an update command, allows U to remove the first or last element in an array -- it removes one element at a time and can only be used with the values 1 or -1. -f for the first element.

```js
db.movies.findOneAndUpdate(
    {_id: 111},
    {$pop: {'genre': 1}},
    {returnNewDocument: true}
)
```

Removing all elements -- when you only need to remove certain elements from an arraly -- can use the `$pullAll`operator -- provides one or more elements to the operator, which then removes all occurrences of those elements from the array like:

```js
db.movies.findOneAndUpdate(
    {_id: 111},
    {$pullAll: {'genre': ['Action']}},
    {returnNewDocument: true}
)
```

#### Removing matched Elements

Can use the `$pullAll`to remove specific elements from an array, in this will use another operator -- called `$pull`to write a query condition, using various logic and conditional opeators, and the array elements that match the query will be removed -- like:

```js
db.items.findOneAndUpdate(
    {_id: 11},
    {
        $pull: {
            items: {
                quantity: 3,
                name: {$regex: /ck$/}
            }
        }
    },
    {returnNewDocument: true}
)
```

In this update command the `$pull`opeator is provided with a query condition in the array field `items`-- the conditions filter the array elements, where the `quantity`is 3 and the `name`end with `ck`.

#### Updating Array Elements

In an array, each element is bound to a specific index position -- these index position start at zero, when using the `[]`, with the respecitvie index position to refer to an element from the array -- Using such a pair of `[]`with the `$`allows U to update elements of an array -- like:

```js
db.movies.findOneAndUpdate(
    {_id: 111},
    {$set: {'genre.$[]': 'Action'}},
    {returnNewDocument: true}
) // set all values to `Action`
```

In this operation, use `$set`in the `genres`field -- the field is referred to by using the expression `generes.$[]`expression and provided with the value of `Action`-- the `$[]`operator refers to all the elements contained by the given array and the update expression will be applied to all of them.

Similarily, can also update specific elements from an array - to do so, first need to find such elements and identify them -- to derive an element identifier -- use the update operation of `arrayFilters`to provide query condition and assign it a variable. Fore:

```js
db.items.findOneAndUpdate(
    {"_id": 11},
    {"$push": {"items": {"name": "it"}}},
    {returnNewDocument: true}
)
```

Updating the precieding `update`command, have added a new element to the array, notice that the newly added element doesn’t have the `price`and `quantity`field -- so can add to it:

```js
db.items.findOneAndUpdate(
    {_id: 11},
    {
        $set: {
            'items.$[myElement]': {
                'quantity': 7,
                price: 4.5,
                name: 'marker'
            }
        }
    },
    {
        returnNewDocument: true,
        arrayFilters: [{'myElement.quantity': null}]
    }
)
```

In the preceding update operation, ust the `$set`to update the elements to the `items`array. The array element to be updated is referredn to by an expression of `$[myElements]`and assigned a new value, whcih is nested object. The identifer of `myElements`is defined using `arrayFitlers`based on a query conditoin. All of the elements that match the given condition are idenfied by `myElements`-- which are then updated using `$set`. The query condition of `{quantity:null}`is matched by the last element of the array and has been updated with the new document.

#### Updating the Director’s Name

```js
db.movies.find(
    {'directors': 'H.C. Potter'},
    {_id:0, title: 1, directors: 1}
)
```

For this, the `find`command finds all the movies by the director’s abbreviated name and prints the movie title, followed by the director’s name -- 

```js
db.movies.find(
    {'directors': {$regex: /^H.C Potter/}},
    {_id: 0, title: 1, directors: 1}
)

db.movies.updateMany(
    {'directors': 'H.C. Potter'},
    {
        $set: {
            "directors.$[hcPotter]": 'H.C Potter(Henry Codman Potter)'
        }
    },
    {
        arrayFilters: [
            {'hcPotter': 'H.C. Potter'}
        ]
    },
)
```

The ouptut indicates that U have correctly updated the director’s name in all records - in this exercise, you practiced using array fitlers to modify only the matching elements in an array.

## Fanning in and out

In the example, if want to speed thing up, can perform the downloads concurrently by load-balancing the URLs to multiple gorouteins -- can create a fixed number of goroutines, each reading from the same URL input channel. Each one oft the goroutines will receive a separate URL from the `generateUrls()`goroutine, and they can perform the downloads concurrently.

Eah one of the goroutines will receive a separate URL from the `generateUrls()`goroutine -- and tney can perform the downloads concurrently.

Shows how we can fan out the URLs to multiple `downloadPage()`goroutine -- each doing a different download -- since concurrent processing is non-deterministic -- some messages will be processed than others -- resulting in messages being processed in an unpredictable order -- the *fan-out* pattern makes sense only if we don’t care about the order of the incoming messages.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	results := extractWords(quit, FanIn(quit, pages...))
	for result := range results {
		fmt.Println(result)
	}
}
```

The *fan-out* pattern in our app has created a problem -- the ouputs of our download goroutiens are in separate channels, namely, how can we connect them to the single input channel of our next stage -- for the `extractWords`, one solution is to change the `downloadPages()`and make them all output on the same channel. To keep pattern,  need a mechanism that merges the output messages from the different channels into a single output channel -- In Go, called the *fan-in* pattern -- In Go, a fan-in concurrency pattern occurs when we merge the content from mutliple channels into one -- Since goroutines are just very lightweight, just can implement this by :

And havin multiple goroutines all feeding into a single common channel creates a problem -- when have a one-to-one output channel goroutines, the channel-closing strategy is simple, close the output after the input channel has been closed, when have many-to-one fan-in scenario -- must make a decision about when to close the common channel. The solution is only close common channel when *all* the goroutines have noticed that the channels from which they are consuming have been closed.

```go
func FanIn[K any](quit <-chan struct, allChannels ...<-chan K) chan K {
    wg := sync.WaitGroup{}
    wg.Add(len(allChannels))
    output := make(chan K)
    for _, c := range allChannels {
        go func(channel <-chan K) {
            defer wg.Done()
            for i:= range channel {
                select {
                case output <- i:
                case <-quit:
                    return
                }
            }
        }(c)
    }
    go func() {
        wg.Wait()
        close(output)  // waits for all the goroutines to finish and then closes the output channel
    }()
    return output
}
```

Can now connect our fan-in pattern to our application and include it in the pipeline -- modifies our `main()`to include the `fanIn`function from -- the `fanIn()`function accepts the list of channels containing the web pages and returns a common aggregated channel - like:

```go
const downloaders = 20
func main() {
    quit := make(chan int)
    defer close(quit)
    // fan out -- 
    urls := generateUrls(quit)
    pages := make([]<-chan string, downloaders)
    for i:=0; i<downloaders; i++ {
        pages[i]= downloadPages(quit, urls)
    }
    resutls := extractWords(quit, FanIn(quit, pages...))
    for result := range results {
        println(result)
    }
}
```

#### Flushing results on close

Havn’t really done anything with our URL download app -- apart from extracting -- what if we use the downloaded web pages for sth useful -- this task is easy if we continue to follow our pipeline-building pattern -- just need to add a new goroutine that accepts an input channel and returns an output one. For the new `longestWords()`is slightly different from the toher goroutines we have developed in the pipeline -- it accumulates a set of unique words in its memory, once it has read all the words from the web pages and receive the close message, will review this set and output the 10 longest ones -- The imp uses a map to store the set of unque words -- like:

```go
func longestWords(quit <-chan int, words <-chan string) <-chan string {
    longWords := make(chan string)
    go func() {
        defer close(longWords)
        uniqueWordsMap := make(map[string]bool)
        uniqueWorks := make([]string,0)
        moreData, words := true, ""
        for moreData {
            select {
            case word, moreData = <-words:
                if moreData && !uniqueWordsMap[word] {
                    uniqueWordMap[word]=true
                    uniqueWords = append(uniqueWord, word)
                }
            case <-quit:
                return
            }
        }
        sort.Slice(uniqueWords, func(a, b int) bool {
            return len(uniqueWords[a]) > len(unqieWords[b])
        })
        longWords <- strings.Join(uniqueWords[:10], ", ")
    }()
    return longWords
}
```

For this the goroutine stores all unique words on a map and a list, once the input channel closes, meaning there are no more messages, the goroutine sorts the list of unique words by length -- Then on the output channel, it sends the first 10 iems on the list, which are the 10 longest words -- like -- 

```go
results := longestWords(quit, extractWords(quit, FanIn(quit, pages...)))
fmt.Println(<-results)
```

#### Broadcasting to multiple goroutines -- 

What if want to find out fore stats from our downlaod pages -- for this scenario, say that in additoin to finding the longest words, want to find which words occur most frequesly -- 

For this, will need to feed output of `extractWords()`to two goroutines -- the existing `longestWords`-- Feed the output of `extract`to two goroutines -- the existing and an additional one called `frequentWords()`-- the patternof the new function will be the same as that of `longestWords()`-- it will store the frequency of each unique word, and then the input channel closes, it will output top 10 most often-occurring -- 

For the prevoius -- used the fan-out pattern when needed to feed the output of one computation to multiple concurrent goroutiens -- load-balanced the messages -- with each goroutine recieving a distinct subset of the output data -- that pattern will not work there -- since want to send a *copy* of each output message to both of the `longestWords()`and `frequentWords()`goroutines.

Instead of the *fan-out* -- can use a broadcast pattern -- one that replicates messages to a set of output channels -- To implement this utility -- just need to create a list of output channels and then use a goroutine that writes every received message to each channel -- Fore -- 

```go
func Broadcast[K any](quit <-chan struct{}, input <-chan K, n int) []chan K {
    outputs := CreateAll[K](n)
    go func() {
        defer CloseAll(outputs...)
        var msg K
        moreData := true
        for moreData {
            select {
            case msg, moreData = <-input:
                if moreData {
                    for _, output := range outputs{
                        output <-msg
                    }
                }
            case <- quit:
                return
            }
        }
    }()
    return outputs
}

func createAll[K any](n int) []chan K {
    channels := make([]chan K, n)
    for i, _ := range channels {
        channels[i] = make(chan K)
    }
    return channels
}

func claoseAll[K any](channels []chan K) {
    for _, output := range channels {
        close(output)
    }
}
```

### Interface pollution

Interfaces are one of concernstones of the Go lanaguage when designing and structing our code -- like many other concepts, abusing them is generally not a good idea - interface pollution is about *overwhelming* our code with unncessary abstractions -- making it harder to understand -- it’s a common *mistake* made by developers coming from another language with different habits.

#### Concepts -- 

Fore need to implement a func that should copy the content of one to another -- could create a specific function that would take as input two `*os.Files* -- like:

```go
func copySourceToDest(source io.Reader, dest io.Writer) error {//...}
```

This func would work with `*os.File`and any other type that would implement these interfaces -- could create our own `io.Writer`that will write to dbs.. Furthermore, writing a unit test for this is easier -- 

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    // create a new Reader for reading from a string
    // *strings.Reader implements the io.Reader..
    source := strings.NewReader(input)
    
    // creates a new Buffer initialize with a given byte slice
    // implements io.Reader...
    // it is growable, in-memory byte buffer
    // but doesn't shrink unless explicitly reset or turncated
    // reutrn a *bytes.Buffer
    dest := bytes.NewBuffer(make([]byte, 0))
    
    er := copySourceToTest(source, dest)
    if err != nil {
        t.FatalNow()
    }
    got := dest.String()
    if got != input {
        t.Errorf(...)
    }
}
```

Indeed, adding methods to an interface can decreases its level of reusability -- `io.Reder`and `io.Writer`are powerful abstractions cuz they cannot get any simpler.

#### When to use interfaces

When should we create interfaces -- 

- Common behavior
- Decoupling
- Restrict behavior

Common behavior -- When multiple types implement a common behavior -- In such a case, can factor out the behavior inside an interface -- 

- Retrieving the number of elements in the collection
- Reporting whether one element must be stored before another
- Swapping two elements

```go
type Interfaec interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}
```

Decoupling -- Another important use case is about decoupling -- If rely on an abstraction instead of a concrete imp- the  imp tiself can be replaced with another without even having change our code -- like:

```go
type CustomerService struct {
    store mysql.Store
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id: id}
    return cs.store.StoreCustomer(customer)
}
```

Now -- what if we want to test this method -- cuz `customerService`relies on the actual imp to store a `Customer`-- we are obliged to test it through integration tests -- which requires spinning up a MySQL instance -- Although integration tests are helpful -- to give more flexibity, should decouple `CustomService`from the actual imp -- chan be done -- 

```go
type CustomerStorer interface {
    StoreCustomer(Customer) error
}

type CustomerService struct {
    storer CustomerStorer
}
// ... create.
```

#### Restricting Behavior

It’s about restricting a type to a specific behavior -- image we implmeent a custom configuration package to deal with dynamic configuration -- create a specific container for `int`via an `IntConfig`struct that also exposes two methods.

```go
type IntConfig struct{}
func (c *IntConfig) Get() int {
    //...retrieve
}
func (c *IntConfig) Set(value int) {
    // update configuration
}
```

Now, suppose we receive an `IntConfig`that holds some specific configuration, such as a threshold -- we are only interested in retrieving the configuration value -- want to prevent updating it.

```go
type intConfigGetter interface {
    Get() int
}
```

Then in the code, can just rely on `intConfigGetter`instead of the concrete imp like:

```go
type Foo struct {
    threshold intConfigGetter // just has a getter interface
}
func NewFoo(threshold intConfigGetter) Foo {
    return Foo{threshold: threshold}
}
func (f Foo) Bar() {
    threshold := f.threshold.Get() // threshold is just a IntConfig
}
```

The `NewFoo`factory -- doesn’t impact a client of this can still pass an `IntConfig`struct as it implements `intConfigGetter`-- then only read configuration in the `Bar`. Then, they can *only read*  the configuration.

### Choosing a session manager

There are a lot of security considerations when it comes work with sessions -- And proper imp is not traival -- Fore `gorilla/sessions`and `alexedwards/scs`-- 

HTTP is just stateless, so session management is used to maintain user state across requests -- In Go, sessions are typically implemented using cookies to store a session ID on the client side -- while session data is stored sever-side. For the `gorialla/sessions`-- it doesn’t provide a mechaism to renew session IDs -- which is necessary to reduce risks *associated with session fixation attacks* --

`alexedwards/scs`-- store session data server-side only -- supports automatic loading and saving of session data via middleware -- has a nice interface or type-safe manipulation of data. Also supports a variety of dbs.

In summary, if want to store session data client-side in a cookie then `gorilla/sessions`is good choice -- but otherwise `alexedwards/scs`is generally the better optoin due to the ability to renew session IDs. For this project got just a MySQL -- so opt to use the `alexedwards/scs`and store the session data server-side in MySQL.

```sh
go get github.com/alexedwards/scs/v2@v2
go get github.com/alexedwards/scs/mysqlstore
```

#### Setting up the session manager

Using the `alexedwards/scs`package - The first thing we need to do is create a `sessions`table in the MySQL dbs to hold the session data for our uses -- like:

```sql
USE snippetbox;

CREATE TABLE sessions (
	token CHAR(43) PRIMARY KEY,
    data BLOB not NULL,
    expiry TIMESTAMP(6) NOT NULL
);

CREATE INDEX sessions_expiry_idx ON sessions (expiry);
```

For this a MYSQL BLBO is a data type used to store binary data, serialized object, files... It is ideal for storing variable-length binary data. For this -- the `token`field will contain a unique, randomly-generated, identifier for each session, and the `data`will contain the actual session data that you want to share between HTTP requsts-- stored as *binary dta* in a BLOB type. And the `expiry`will contain an expiry time for the session. Note that the `scs`package will automatically delete expired sessions from the `sessions`table so that it doesn’t grow too large.

In the `main.go`just like:

```go
type application struct {
    //...
    sessionManager *scs.SessionManager
}

func main() {
    //...
    // Use the scs.New() to initialize a new manager
    sessionManger := scs.New()
    
    // also the new package installed using go get
    sessionManager.Store = mysqlStore.New(db)
    sessionManager.Lifetime = 12*time.Hour
    app := &application {
        //...
        sessionManager:sessionManager,
    }
    // ...
}
```

Note that the `scs.New()`function just returns a pointer to a `SessionManager`struct which holds configuration settings for your sessions -- For these to work, need to wrap our application routes with the middleware provided by the `SessionManager.LoadAndServe()`method. This automatically loads and saves session data with every HTTP request and response. It’s important to note that don’t need this middleware to act on *all* our app routes -- don’t need it on the `/static/*filepath`route. Fore:

```go
func (app *application) routes() http.Handler {
    router := httprouter.New()
    // create new middleware pecific to dynamic app routes
    // only contains the `LoadAndSave()`session middleware.
    dynamic := alice.New(app.sessionManager.LoadAndSave)
    // Create a new routers to use the new dynamic chain
    router.Heandler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
    //... other route function
    standard := alice.New(...)
    return standard.Then(router)
}
```

And for general usecase -- can

```go
// Wrap handlers with SCS LoadAndSave middleware
log.Fatal(http.ListenAndServe(":8080", sessionManager.LoadAndSave(mux)))
```

Just need to note that we don’t need this middleware to act on all our app routes -- specifially, don’t need it on the `/static/*filepath`route -- all this done is serve static files and there is no need for any stateful behavior.

