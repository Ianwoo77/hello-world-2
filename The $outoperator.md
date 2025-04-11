# The `$out`operator

For this pipeline, just like:

1. First, outline the stages in your pipeline, they appear in the following order -- 
   - `$sample`the comments
   - `$group`the comments by movie for which they are targeted
   - `$sort`the result by the number of total comments
   - `$limit`the result to the top 5 movies by comments
   - `$lookup`-- the movie that matches each document
   - `$unwind`-- The movie array to keep the result documents simple
   - `$project`-- just for the movie title and rating
   - `$merge`-- the result into a new collection
   - `$out`-- to the new collection

With the `$out`stage, can store the result of our aggregations -- this allows users to explore the results quickly with normal CRUD operations and allows us to keep updating the results regularly and easily.

```js
db.getCollection('comments').aggregate(
  [
    { $sample: { size: 5000 } },
    {
      $group: {
        _id: '$movie_id',
        sumComments: { $sum: 1 }
      }
    },
    { $sort: { sumComments: -1 } },
    { $limit: 5 },
    {
      $lookup: {
        from: 'movies',
        localField: '_id',
        foreignField: '_id',
        as: 'movie'
      }
    },
    { $unwind: '$movie' },
    {
      $project: {
        'movie.title': 1,
        'movie.imdb.rating': 1,
        sumComments: 1
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

### Geting the Most from your Aggregations

Have learned about the structure of aggregations as well as the key stages required to build up complicated queries -- can search large multi-collection datasets with given critiera, manipulating that data to create new insights. There are also several other stages and patterns for getting the most out of your aggregations, 

#### Tuning your Pipelines

MDB provides us with a great way of learning exactly how it executed our requested query -- this fequre is known as `Explain`and is the usual way to examine and optimize commands. MDB does a lot of performance optimization under the hood, but these are still good patterns to follow.

#### Filter Early and Filter often

Each stage of the aggreagation pipeline will perform some processing on the input -- that means the more significatnt input -- the large processing -- And if you have designed your pipeline correctly, this processing is unavoidable for the documents you are trying to return -- the best you can do is to make sure you are processing *only* the documents you want to return.

We have already done this in our previous scenairos with `$match`and `$limit`-- A common way to ensure this is to hve the very first stage in your piepline be a `$match`-- whcih match only documents you need later in the pipeline. Fore, running query in a bad order like -- 

```js
const pipeline = [
    {$sort: {'imdb.rating': -1}}, // sort first
    {$match: {$in: ["Romance"]}, released: {$lte: new ISODate('2001-01-01')}},
    {$porject {title:1, genres: 1, released: 1, 'imdb.rating':1}},
    {$limit: 1}
];
```

Once U have correctly ordered pipeline, will look like as -- 

```js
const pipeline = [
    {$match: {}}, {$sort: {}}, 
    {$limit:1},
    {$project: {...}}
]
```

Logically, this change means that the first thing we do is get a list of all our eligible documents before sorthing them, and then we take top N and project only those five documents. Both pipelines output just the same results, but the second is much more robust and easily understood -- may not always see a significant performance increase with this change -- particularly on smaller datasets.

#### User youer Indexes

Indexes are another critical element in MongoDB query performance -- this -- covers in Ch9, and all you need to remember when creating your aggregations is that when utilizing stages such as `$sort`and `$match`-- want to make sure that you are operating on correctly indexed fields -- the concepts around using indexes will then become more apparent.

#### Think about the Desired output -- 

One of the most important ways to improve your pipeline is to play and evaluate them to ensure that U are getting the desired output that solves your business problem -- 

- Am I outputting all the data to sovle my problem 
- Am outputting only the data required to solve the problem
- Able to merge or move any intermediate steps.

Aggregation options -- Altering the pipeline is where U may spend most of your time while working with aggregations -- will likely be able to accomplish most of your goals by just writing pipelines -- Don’t delve too deeply -- The following is an example of aggregation with some of our options included like:

```js
const options = {
    maxTimeMS : 30000,
    allowDiskUse: true,
}
db.movies.aggregate(pipeline, options);
```

To speicfy these options, a second parameter is passed into the command after the pipeline array, in this array, called it `options`.

- `maxTimeMS`-- The amount of time an operation may be processed before mdb kills it.
- `allowDiskUse`-- Mdb will write temporary files to allow the handling of more data.
- `bypassDocumentValidation`-- Specifically for pipelines that will be writing out to collections using `$out`or `$merge`. If this is `true`-- document validation will not occur
- `comment`-- For just debugging and allows a string to be specified that helps identify this aggregation when parsing dbs logs.

## Sync with Mutexes

Can protect critical sections of our code with mutexes so that only one gorotuine at at ime accesses a shared resource. In this way -- eliminate rece conditions.

How to use -- Can use that to mark the beginnings and ends of our ciritical sections -- When a goroutine comes to a CS of the code protected by a mutex -- first locks this mutex explicitly as an instruction in the program code -- The goroutine then starts to execute the CS’ code, donw then locks the mutex so that another can access the CS.

DEF -- is a form of concurrency control with the purpose of perventing RC. A mutex allows only one execution, and In go, mutex functionality is provided in the `sync`-- this type gives `Lock()`and `Unlock()`.

```go
func countLetters(url string, frequency []int, mutex *sync.Mutex) {
	resp, _ := http.Get(url)
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		panic("Server returning error code:" + resp.Status)
	}
	body, _ := io.ReadAll(resp.Body)
	for _, b := range body {
		c := strings.ToLower(string(b))
		cIndex := strings.Index(allLetters, c)
		mutex.Lock()
		if cIndex >= 0 {
			frequency[cIndex] += 1
		}
		mutex.Unlock()
	}
	fmt.Println("Completed:", url)
}
```

By using mutexes in this manner, have changed our concurrent program into a sequential one. And Depending on the mutex imp -- there is usually a performance cost if we call the `Lock()`and `Unlock()`. Fore:

```go
mutex.Lock()
frequency[cIndex]+=1
mutex.Unlock()
```

Note that however, this means that we will be calling these two for eery letter in the downloaded document -- since processing the entire document is a very op -- it’s probably more performant to call `Lock`before the loop.

```go
mutex.Lock()
for _, b := range body {
    //...
}
mutex.Unlock()
```

#### Non-blocking mutex locks

In some apps, we might not want to block the goroutine, but instead perform some other work before attempting again to lock the mutex and access the CS. For this reason, Go’s mutex provides another function called `TryLock()`when call this function, can expect one of two outcomes -- 

- The lock available, in which case we acquire, function returns `true`
- Lock unavailable, return false, and the function just return immediately.

```go
if mutex.TryLock() {
    for _, b := range body {
        c := strings.ToLower(string(b))
        cIndex := strings.Index(allLetters, c)
        if cIndex >= 0 {
            frequency[cIndex] += 1
        }
    }
    mutex.Unlock()
}
```

#### Improving performance with readers-writer mutexes - 

At times, mutexes might be too restrictive, can think of mutexes as blunt tools that solve concurrency problems by blocking concurrency. *Reader-writer* mutexes give variation on std mutexes that only block concurrency when need to update a shared resource.

#### readers-writer mutex

```go
func matchRecorder(matchEvents *[]string, mutex *sync.Mutex) {
	for i := 0; ; i++ {
		mutex.Lock()
		*matchEvents = append(*matchEvents,
			"Match event "+strconv.Itoa(i))
		mutex.Unlock()
		time.Sleep(200 * time.Millisecond)
		fmt.Println("append match event")
	}
}
```

Shows a client handler function together with a function that copies all the events in the shared slice, can run the `clientHandler`function as a goroutine -- each handling a conencted user.

```go
func main() {
	mutex := sync.Mutex{}
	var matchEvents = make([]string, 0, 10000)
	for j := 0; j < 10000; j++ {
		matchEvents = append(matchEvents, "MatchEvent")
	}
	go matchRecorder(&matchEvents, &mutex)
	start := time.Now()
	for j := 0; j < 5000; j++ {
		go clientHandler(&matchEvents, &mutex, start)
	}
	time.Sleep(100 * time.Second)
}
```

Go comes with its own imp of a reader-writer lock -- in addition to offering the normal exclusive locking and unlocking functions, Go’s `sync.RWMutex`gives us extra methods to use the reader’s side of mutex. Like

```go
type RwMutex {...}
func (rw *RWMutex) Lock(), and RLock(), RUnlovck, TryLock(), TryRLock()...
```

### Sentinel Errors

Error management is at the heart of software development, -- say you try to read a file line by line -- it could be that the file doesn’t exist -- Sentinel erros are type of recognizsable errors -- in Go, errors are values -- meaning that they carry a meaning -- sentinel errors must behave like constants -- but Go will only accept primitive types as constraints, and not method calls -- The two default way to build an error are by calling `fmt.Errorf`or `erros.New()`-- And these don’t produce constant values -- produce the outout of a function -- which isn’t known at compile time, only the execution time. This implies that errors generated by `fmt.Errorf`or `errors.New`will always be variable -- 

```go
type corpusError string
func (e corpusError) Error() string {
    return string(e)
}
```

Just can declare a `corpusError`that is a constant -- and still implements the `error`interface -- wish this type were in the stdlib.

#### Testing the reading -- 

Then can test if we can actually read a file full of words into a alice of string -- just like:

```go
func TestReadCorpus(t *testing.T) {
	t.Parallel()

	tt := map[string]struct {
		file   string
		length int
		err    error
	}{
		"English corpus": {
			file:   "../corpus/english",
			length: 34,
			err:    nil,
		},
		"empty corpus": {
			file:   "../corpus/empty.txt",
			length: 0,
			err:    gordle.ErrCorpusIsEmpty,
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			words, err := gordle.ReadCorpus(tc.file)
			if !errors.Is(tc.err, err) {
				t.Errorf("expected %v, got %v", tc.err, err)
			}

			if tc.length != len(words) {
				t.Errorf("expected %d, got %d", tc.length, len(words))
			}
		})
	}
}
```

We have our corpus in a handy form, it is reading from a file that can be updated in the simplest way possible.

#### Pick a word

Go’s `math/rand`package provides a random number generator -- but there is another package that also achieves this in Go’s std packages -- the `crypto/rand`package -- the main difference is that the crypto package gurantees truly random numbers -- while the main package generates psdudo-random numbers -- and the cypto package is a lot of more expensive -- For small non-critical apps, using the `math`package is perfectly fine -- 

Both of Go’s `rand`packages expose, amongst others -- an `Intn(n int)`function that returns a number between 0 and `n`. Overriding it with sth that changes every time will ensure we get a random number out of the library. Earlier versions of Go required the `rand`package to be seeded, with a call to `rand.Seed(seed)`-- the rndom number generator is now seeded randomlly when the program starts.

`index := rand.Intn(len(corpus))`

```go
// pickWord returns a random word from the given corpus
func pickWord(corpus []string) string {
	index := rand.Intn(len(corpus))
	return corpus[index]
}
```

Know that the importance of testing the core methods to make sure they are working properly before calling them into higher methods -- `pickWord`will follow that trend, -- minor issue -- when execute tests, usually, want to compare an output to a reference -- 

```go
func inCorpus(corpus []string, word string) bool {
	for _, corpusWord := range corpus {
		if corpusWord == word {
			return true
		}
	}
	return false
}

func TestPickWord(t *testing.T) {
	corpus := []string{"HELLO", "SALUT", "ПРИВЕТ", "ΧΑΙΡΕ"}
	word := pickWord(corpus)
	if !inCorpus(corpus, word) {
		t.Errorf("word %q not in corpus", word)
	}
}
```

Now we have done the imp and covered the testing -- we are ready to wrap it up -- It’s time to replace it by calling the`pickWord`method and passing the corpus as a parameter of `New()`.

We are now also reaching the moment where `New()`does a lot -- not only does it create a `Game`, but it also initiates it. won’t push it any further, and instead consider that it might be time to split it into two distinct functions.

```go
func New(playerInput io.Reader, corpus []string, maxAttempts int) (*Game, error) {
	if len(corpus) == 0 {
		return nil, ErrCorpusIsEmpty
	}
	g := &Game{
		reader:      bufio.NewReader(playerInput),
		solution:    []rune(strings.ToUpper(pickWord(corpus))),
		maxAttempts: maxAttempts,
	}
	return g, nil
}
```

#### Play -- 

There is a very little left to do before the game is complete.

```go
const maxAttempts = 6

func main() {
	corpus, err := gordle.ReadCorpus("../gordle/corpus/english")
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "Unable to read corpus: %s", err)
		return
	}

	// create the game --
	g, err := gordle.New(bufio.NewReader(os.Stdin), corpus, maxAttempts)
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "Unable to create game: %s", err)
		return
	}
	g.Play()
}
```

#### The limit of runes -- 

Enjoyed this so much we wants to submit his list of words -- he wants to share wtih his friend -- who lives in India.

## Common dynamic Data

In some web apps there may be common dynamic data that you want to include on more than one -- fore, U might want to include the name and profile picuture of the current user, or a CSRF token in all pages with forms.

```go
type templateData struct {
    CurrentYear int
    Snippet *models.Snippet
    Snippets []*models.Snippet
}
```

#### Custom template functions -- 

1. Want to create a `template.FuncMap`containing the custom `humanDate()`function
2. Need to use the `template.Funcs()`method to register this before parsing the templates.

```go
func humanDate(t time.Time) string {
    return t.Format("02 Jan 2006 at 15:04")
}

// Initialize a template.FuncMap object and store it in a global variable
// a string-keyed map which acts as a lookup between the names of our custom template function
var functions = template.FuncMap {
    "humanDate": humanDate,
}

func newTempalteCache() (map[string]*template.Template, error ) {
    cache := map[string]*template.Template{}
    pages, err := filepath.Glob(".../*.html")
    if err != nil {
        return nil, err
    }
    for _, page := range pages {
        name := filepath.Base(page)
        
        ts, err := template.New(name).Funcs(functions).ParseFiles("./ui/html/base.html")
        if err != nil {
            return nil, err
        }
        ts, err = ts.ParseGlob("./ui/html/partial/*.html")
        if err != nil {
            return nil, err
        }
        ts, err := ts.ParseFiles(page)
        if err!= nil {
            return nil, err
        }
        cache[name]=ts
    }
    return cache, nil
}
```

Before, continue, should explain: custom template functions can accept as many parameters as they need to, but they *must* return one value only. The only exception to this is if you want to return an errors as the second value.

```html
<td>{{humanDate .Created}}</td>
```

#### Middleware

When are building a web app there is probably some shared functionality that you want to use for many HTTP requests, fore, might want to log every request, compress -- or check a cache before passing the request to your handlers -- A common way of organizing this shared functionality is to set up as *middleware* -- this is essentially some *self-contained* code which independentlly acts on a request before or after your normal app handlers.

A common way of origanizing this shared functionality is to set up as *middleware* this is essentially some self-contained code which independently acts on a request before or after your normal app handlers.

- An idiomatic pattern for *building and using custom middleware* which is compatible with `net/http`and many 3rd-party packages.
- How to create middleware which sets useful security headers on every HTTP response
- How to create middleware which sets useful secruity headers on every HTTP response.
- Create middleware which logs and requests received by your app
- How to create middleware which recovers panics so that they are gracefully handled by your application
- How to create and use composable Middleware chains to help manage and orgainzie your middleware.

The pattern -- The basic idea of middleware is to insert another handler into this chain -- The middleware handlers executes some logic, likie logging a request, and then calls the `ServeHTTP()`method of *next* handler. Fore the `http.StripPrefix()`-- 

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        // TODO: Execute our middleware logic here...
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

