# Logical Operators MDB-- 

In practical scenarios, you may need to write more complex queries, Mdb provides 4 logical operator to help you build logical combinations of multiple critiera in the same query.

#### `$and`operator

Can have any number of conditions wrapped in an array and the operator will return only the document satisfy all conditions. Note that when fails a condition check, the next are skipped. Short-circuit operator for.

```js
db.movies.countDocuments(
    {$and: [{rated: 'UNRATED'}, {year:2008}]}
)
db.movies.countDocuments(
    {$and: [{rated: 'PASSED'}, {year: 1920}]}
)
```

Note that in MDB queries, the `$and`operator is implicit and included by default if a query document has more then one condition -- 

```js
db.movies.countDocuments(
    {rated: 'PASSED', year: 2000}
)
```

#### `$or`operator 

Can pass multiple conditions wrapped in an array and the documents satisfying either. like:

```js
db.movies.find(
	{$or: [
        {'rated': "G"},
        {'rated': 'PG'}
    ]}
)
```

Note that this is different to `$in`-- `$in`is used to determine whether a given field has last one of the value provided in an array, `$or`is just not bound to any specific fields and accepts multiple expressions.

#### `$nor`operator

Is just syntically like `$or`, not satisfy any of the given conditions -- 

`$not`-- represents the logical NOT operation that negates the given condition. like:

```js
db.movies.find(
	{'num_mfilex_comments': {$not: {$gte:5}}}
)
```

#### Ex 3 -- Combining multiple Queries

Your task for this exercise is to find the titles and release years of drama or crime movies in the production of which .. have collaborated -- 

```js
// 1. using $and
db.movies.find (
    {cast: 'Leonardo DiCaprio',
    directors: 'Martin Scorsese'}
)
// 2. there is one more AND condition to be added, which is the movies like:
db.movies.find (
    {cast: 'Leonardo DiCaprio',
    directors: 'Martin Scorsese',
    $or:[{'genres': 'Drama'}, {genres: 'Crime'}]}
)
// 3. if only are interested in the title and release year -- like:
db.movies.find (
    // ... same
    {title:1, year:1, _id:0}
)
```

### Regular Expressions

In a real movie service, you will want to provide auto-completion search boxes where as soon as the user type in a few characters of the movie title, the search box suggests all the movies whose titles match the characer sequence typed in. This is implemented using REGEXP -- is a special string that defines a character pattern.

In MDB, regular expressions can be used with the `$regex`opreator -- like:

```js
db.movies.find(
    {title: {$regex: 'Opera'}}
)
```

Using the caret `^`oeprator -- To find only the srings that start with the given regular expression, `^`can be used -- like:

```js
db.movies.find(
    {title: {$regex: '^Opera'}}
)
// and the dollar operator -- like:
db.movies.find(
    {title: {$regex: 'Opera$'}}
)
```

#### Case-Insenstive search -- 

Searching with regular expression is cas-sensitive by default, the casing of the characters in the provided search pattern is matched exactly -- however, quite often, you will want to provide a word or pattern to the REGEXP and find documents irrespectie of their casing. MDB provides the `$options`operator for this, which can be used for case-insensitve regexp searches.

```js
db.movies.find(
    {title: {$regex: 'the', $options: 'i'}}
) // note that the `$options`is an operator too
```

### Query arrays and nested Documents

MDB documents supports complex object structures such as arrays, nested objects, array of objects, and more. The arrays and nested documents help store self-contained info -- it’s extremely important to have mechanism to easily search for and retreive the info stored in such complex structures.

#### Finding an Array by an element

Querying over an array is similar to querying any other field. IN the `movies`, there are sereval arrays, and the `cast`field is one of them -- consider that -- in movies service, the user wants to find movies starring the actor fore:

```js
db.movies.find(
    {cast: 'Charles Chaplin'},
    {cast: 1, _id:0}
)
```

Imagine wants to find for movies with the actors CC and EP, will fore, using the `$and`.

```js
db.movies.find(
    {cast: 'Charles Chaplin', cast: 'Edna Purviance'},
    {cast: 1, _id:0}
)
```

#### Finding an Array by an array --

In the previous examples, searching for arrays using the value of an element.  When U want to search an array field using an array value, the elements and their order must *match*. Fore:

```js
db.movies.find(
    {languages: ['English', 'German']},
    {languages:1}
) // just return [e,g] only
```

The preceding output shows that when search by using an array, the value is matched exactly. If changing the order, different records have been matched. So when array fields are searched using an array value, the value is matched using an equality check.

#### Searching an array with the `$all`operator

The `$all`operator finds all those documents where the value of the field contains all the elements, *irrespective* of their order or size like:

```js
db.movies.find(
    {languages: {$all: ['English', 'French', 'Cantonese']}},
    {languages:1}
)
```

For this query, `$all`to find all the movies available in `English...`

#### Projecting Array elements

There are a few ways to limit *how many* elements of an array are returned in the query output. Namely, how to limit the result set when we search with an array field.

Projecting mathcing elements using `$`-- Can search an array by an element value and use projection to exclude all but the first matching element of the array using the `$`operator.

```js
db.movies.find(
    {languages: 'Syriac'},
    {'languages.$':1}
)
```

For this, just for output projection.

## Cmparing values 

Start with a concrete example -- create a basic `customer`and use `==`to compare two instance -- like:

```go
type customer struct {
    id string
}
func main(){
    cust1 := customer{id:"x"}
    cust2 := customer{id:"x"}
    print(cust1==cust2)
}
```

Note that compare two `customer`structs is a valid operation, will print `true`here. However, what happens if we make a slight modification to the `customer`struct to add a slice field -- like:

```go
type customer struct {
    id string
    operations []float64
}
//...
```

There shows doesn’t compile - the problem relates to how the `==`and `!=`operators work -- these operators don’t work with slices or maps -- hence, cuz the `customer`struct contains slice, doesn’t compile.

- Channels -- Compare whether two were create by same call to `make`or both are just `nil`.
- Interfaces -- Have identical dynamic types and equal dynamic vlaues or both `nil`
- Pointers -- same value in memory or if both are `nil`.
- *Structs and arrays* - compare whether they are composed of smilar types.

Also need to know the possible issues of using `== `and `!=`with `any`types -- fore, comparing two integers assigned to `any`types is allowed -- 

```go
var a any = 3
var b any = 3
print(a==b) // true

var cust1 any = customer{id:"x", operations: []float64{1.}}
var cust2 any = customer{id:"x", operations: []float64{1.}}
print(cust1 == cust2) // runtime error
```

One option is to sue run-time reflection with the `reflect`package -- is a form of metaprogramming, and it refers to the ability of an app to introspect and modify its structure and behavior. like;

```go
cust1 := customer{id: "x", operations: []float64{1.}}
cust2 := customer{id:"x", operations: []float64{1.}}
print(reflect.DeepEqual(cust1, cust2))
```

For this, However, there are two things to keep in mind when using `reflect.DeepEqual`-- it makes the distinction between an empty an a `nil`collection, as discussed. And the other catch is sth pretty std in most language, Cuz this function uses reflection-- which introspects values at run time to discover how they are formed,  And if performance is a cricual factor -- like:

```go
func (a customer) equal (b customer) bool {
    if a.id != b.id {
        return false
    }
    if len(a.operations) != len(b.operations) {
        return false
    }
    for i:=0; i<len(a.operations); i++ {
        if a.operations[i]!= b.operations[i] {
            return false
        }
    }
    return true
}
```

### Flushing results on close

Havnt’ really done anything interesting with our URL download application -- Fore, 10 longest words -- This task is easy if continue to follow pipeline-building pattern -- just need to add a new goroutine that accepts an input channel and returns an output one. This new longest is slightly different from the other goroutines we have developed -- 

```go
func longestWords (quit <-chan int, words <-chan string) <-chan string {
    longwords := make(chan string)
    go func() {
        defer close(longWords)
        uniqueWordsMap := make(map[string]bool)
        uniqueWords := make([]string, 0)
        moreData, word := true, ""
        for moreData {
            select {
            case word, moreData = <-words:
                if moreData && !uniqueWordsMap[word] {
                    uniqueWordsMap[word]=true
                    uniqueWords = append(uniqueWords, word)
                }
            case <-quit:
                return
            }
        }
        sort.Slice(uniqueWords, func(a, b int) bool {
            return len(uniqueWrods[a]> len(uniqueWords[b]))
        })
        longWords <- strings.Join(uniqueWords[:10], ", ")
    }()
    return longWords
}
```

The goroutine stores all the unique words on a map and a list. Once the input channel closes, meaning there are no more messages, the goroutine stores the list of unique words by length. Then on the output, it sends the first 10 items on the list, which are the 10 longest words.

Can now conenct this new component to our pipeline in the `main`-- like:

```go
func main() {
    //...
    results = longestWords(quit, extractWords(quit, FanIn(quit, pages...)))
}
```

### Broadcasting to multiple goroutines

Say that in addition to finding the longest words, want to find which words occur most frequently. For this scenario, will feed the output of the `extractWords()`to two goroutines -- the existing `longestWords`and an additional one may be called `frequentWords()`-- the pattern of the new function will be the same as that of `longestWords()`.

Fore, used the *fan-out* pattern when we need to feed the output of one computation to multiple concurent goroutines. We load-blanaced the messages, with each goroutine receiving a distinct subset of the output data. The pattern will not work here -- since want to send a copy of each message to both the `longestWords`and `frequentWords()`goroutines.

Instead of the fan-out, can use a *broadcast* pattern -- one that *replicates* messages to a set of output channels. To implement this utility , need to *create a list of output channels* and then use a goroutine that writes every received message to each channel. Fore, the `boradcast`function will accept the input channel and an *interger* specifying the number of the ouput that are needed. The func then return these `n`output channels in a slice.

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
					// outputs is an array of channels
					// sends input to all outputs
					for _, output := range outputs {
						output <- msg
					}
				}
			case <-quit:
				return
			}
		}
	}()
    return outputs
}

func CreateAll[K any](n int) []chan K {
	channels := make([]chan K, n)
	for i, _ := range channels {
		channels[i] = make(chan K)
	}
	return channels
}

func CloseAll[K any](channels ...chan K) {
	for _, output := range channels {
		close(output)
	}
}
```

Note that in the broadcast imp -- read the next message only after the current message has been sent to all the channels.  A slow consumer from this broadcast implementation would slow all the consumers to the same rate. Now can write our `frequentWords()`-- which will just identify the top 10 most frequently occuring words in the downloaded pages. The imp in the following listing is similar to the `longesetWords`function this time using a map, called `mostFrequentWords`to count each world’s occurrence -- like:

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
				if moreData {
					if freqMap[word] == 0 {
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
        mostFrequentWords <- strings.Join(freqList[:10], ", ")
	}()
	return mostFrequentWords
}
```

Now can wire the `frequentWords()`unit with the broadcast utility we developed previously.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, 20)
	for i := 0; i < 20; i++ {
		pages[i] = downloadPages(quit, urls)
	}
	words := extractWords(quit, FanIn(quit, pages...))
	wordsMulti := Broadcast(quit, words, 2)
	longResults := longestWords(quit, wordsMulti[0])
	frequentResults := frequentWords(quit, wordsMulti[1])
	fmt.Println("longest words", <-longResults)
	fmt.Println("frequent words", <-frequentResults)
}
```

Since both the `longestWrods()`and `frequentWords()`only one message containing the results, our `main()`can just consume one message from each and point it on the console.

## Setting up the session manager

Run through the process of setting up and using the `alexedwards/scs`package -- but if you are going to use it in a production application recommend reading but for now the first thing we need to do is create a `sessions`table in the dbs to hold the session data for our users -- Start by connect to MySQL from your terminal window as the `root`user and execute the SQL:

```sql
use snippetbox;
CREATE TABLE sessions (
	token CHAR(43) PRIMARY KEY,
    data BLOB NOT NULL,
    expiry TIMESTAMP(6) NOT NULL
);
CREATE INDEX session_expiry_idx ON sessions(expiry);
```

- The `token`field will contain a unique, random-generated, idenfier for each session.
- The `data`field will contain the actual session data that U want to share between HTTP requests, this is stored as *binary data* in a `BLOB`type.
- The `expriy`will contain an expiry time for the session. the `scs`package will automatically delete expired sessions from the `sessions`table so that it doesn’t grow too large.

And the next thing need to do is establish a *session manager* in our `main.go`file and make it available to our handlers via the `application`struct. The session manager holds the configuration settings for our sessions, and also provides some middleware and helper methods to handle the loading and saving of the session data.

```go
type application struct {
	errorLog      *log.Logger
	infoLog       *log.Logger
	snippets      *models.SnippetModel
	templateCache map[string]*template.Template
	formDecoder   *form.Decoder
	sessionManager *scs.SessionManager
}

func main() {
    //...
    formDecoder := form.NewDecoder()
	
	// use the scs.New() function to initialize a new session manager.
	// then we configure it to use our dbs as the session store
	sessionManager := scs.New()
	sessionManager.Store = mysqlstore.New(db)
	sessionManager.Lifetime = 12 * time.Hour

	app := &application{
		errorLog, infoLog,
		&models.SnippetModel{DB: db},
		templateCache,
		formDecoder,
		sessionManager,
	}
    //...
}
```

The `scs.New()`returns  a pointer to a `SessionManager`struct which holds the configuration settings for your sessions. For the sessions to work, also need to wrap our app routes with the middleware provided by the `SessionManager.LoadAndSave()`method. This middleware automatically loads and saves session data with every http request and response.

It’s important to note that we don’t need this middleware to act on *all* our app routes, specifically, don’t need it on the `/static/*filepath`route. -- So cuz of this, it doesn’t make sense to add the session middleware to our existing `standard`middleware chain.

Instead, create a new `dynamic`middleware chain containing the middleware appropriate for our dyanmic app routes only like:

```go
router.Handler(http.MethodGet, "/static/*filepath",
               http.StripPrefix("/static", fileServer))

dynamic := alice.New(app.sessionManager.LoadAndSave)

// update the routes to use the new dynamic middleware chain followed by 
// the appropraite handler function -- note that cuz the alice `ThenFunc()`
// returns a http.Handler, also need to switch to registering the routes using router.Handler()
router.Handler(http.MethodGet, "/", dynamic.ThenFunc(app.home))
router.Handler(http.MethodGet, "/snippet/view/:id", 
               dynamic.ThenFunc(app.snippetView))
router.Handler(http.MethodGet, "/snippet/create", 
               dynamic.ThenFunc(app.snippetCreate))
router.Handler(http.MethodPost, "/snippet/create", 
               dynamic.ThenFunc(app.snippetCreatePost))
```

Without using `alice`-- If are not using the `justinas/alice`package to help manage your middleware chains, then you’d need to use the `http.HandlerFunc()`adapter to convert your handler functions like `app.home`...

```go
router := httprouter.New()
router.Handler(http.MethodGet, "/", app.sessionManager.LoadAndSave(http.HandlerFunc(app.home)))
```

### Working with session data

The put the session functionality to work and use it to perist the confirmation flash message between HTTP requests -begin in the `handles.go`file and update the `snippetCreatePost`.

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    //...
    // at last, use the `Put` method to add a string value
	// fore, Snippet created! and the corresponding key to the session data
	app.sessionManager.Put(r.Context(), "flash", "Snippet created successfully!")
	http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOther)
}
```

Just nice and simple, but there are a couple of things to point out -- 

- `app.sessionManager.Put()`is the *current request context* -- `r.Context`-- take properly about what the request context is and how to use it. For now just think of it as somewhere that the session manager temporarily stores info while your handler are dealing with the request.
- `“flash”`-- is the key for specific message that are adding to the session data. We aill subsequently retrieve the message from the session data using this key too.
- If there is no existing session for the current user then a new empty session for them will automatically be created by the session middleware.

Next up, want our `snippetView`handler to retreive the flash message and pass it to the HTML template.

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    //...
    // use the PopString() method to retrieve the value for `flash` key
	// also deletes the key and value from the session data
	// so just like a one-time fetch
	flash := app.sessionManager.PopString(r.Context(), "flash")

	data := app.newTemplateData(r)
	data.Snippet = snippet
	data.Flash= flash
	app.render(w, http.StatusOK, "view.html", data)
}
```

Then just add the field like:

```go
type templateData struct {
    //...
    Flash string
}
```

Then update the `base.html`to display the flash message like:

```html
<main>
    <!-- display the flash message if exists -->
    {{with .Flash}}
    <div class="flash">{{.}}</div>
    {{end}}
    {{template "main" .}}
</main>
```

Just remember that the `{{with .Flash}}`block will only be executed in the value of `.Flash`is not empty string.