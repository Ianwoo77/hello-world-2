# Working with large DataSets

The first step in learning how to deal with large datasets is unstanding `$sample`-- this stage is simple yet useful, the only parameters to `$sample`is the desired size of your sample. Just like:

```js
{$sample: {size:100}}
db.getCollection('movies').aggregate(
  [
    { $sample: { size: 100 } },
    {
      $match: {
        plot: { $regex: RegExp('around') }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

U may be wondering why you wouldn’t just use a `$limit`command to achieve the same result of reducing the number of documents at some stage in your pipeline -- the primary reason is that `$limit`always respects the order of the document and thus returns the same documents every time -- it is important to note that in some cases -- where U do not require the pseudo-random selection of `$sample`.

#### Joining collection with `$lookup`

Sampling may assist you when developing queries against extensive collections -- but in production queries, may sometimes need to write queries that are operating across multiple collections -- like:

```js
db.getCollection('users').aggregate(
  [
    {
      $match: {
        $or: [
          { name: 'Catelyn Stark' },
          { name: 'Ned Stark' }
        ]
      }
    },
    {
      $lookup: {
        from: 'comments',
        localField: 'name',
        foreignField: 'name',
        as: 'comments'
      }
    },
    { $limit: 2 }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

- `from`-- the collection we are joining to our current aggregation -- in this case, joining comments to `users`.
- `localField`-- The field name that we are going to use to join our documents in the local collection.
- `foreignField`-- the field that links to `localField`in the form collection.
- `as`-- this is how our new joined data will be labeled.

In this example, users have made many comments, so the embedded array becomes quite substantial and challenging to view. This issue presents an excellent place to introduce the `$unwind`operator, as these joins can often result in large arrays of related documents. `$unwind`is a relatively simple stage. It deconstructs an array field from an input document to output a new document for each element in the array.

The `$lookup`and `$unwind`operators are commonly used together in MDB’s aggregation pipeline to join data from different collections and then flatten array fields resulting from the join. The `$unwind`operator deconstructs an array field from the input documents to output a document for each element in the array. Each outoput is the input document with the value of the array field replaced by the element.

```js
db.getCollection('users').aggregate(
  [
    {
      $match: {
        $or: [
          { name: 'Catelyn Stark' },
          { name: 'Ned Stark' }
        ]
      }
    },
    {
      $lookup: {
        from: 'comments',
        localField: 'name',
        foreignField: 'name',
        as: 'comments'
      }
    },
    { $unwind: '$comments' },
    { $limit: 3 }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

Can see multiple documents per user with a single document for each comment instead of one embedded array, with the new format, can add more stages to operate on our new set of documents. Our comments -- this combination of `$lookup`and `$unwind`is a powerful combination for answering complex questions across multiple collections in a single aggreagation.

Could run the query and export the results into a new format, however, this would mean re-importing the results if wanted to run subsequent analysis on the result set.

#### Outputting your results with `$out`and `$merge`

Both stages allow us to take the output from our pipeline and write it into a collection for late use -- importantly, this whole process takes place on the server, meaning that all the data never needs to be transferred to the client acorss the network -- it’s not hard to imagine that after creating a complicated aggregation query.

```js
// available from v 2.6
{$out: "myoutputCollection"}
// available from v 4.2
{
    $merge: {
        into: "myOutputCollection",
    }
}
```

`$out`is simple, the only parameter to specify is the desired output collection -- will either create a new collection completely replace an existing collection -- `$out`also has several constraints not shared with `$merge`.

```js
db.getCollection('movies').aggregate(
  [
    { $sort: { 'imdb.rating': -1 } },
    {
      $match: {
        genres: { $in: ['Romance'] },
        released: {
          $lte: ISODate(
            '2001-01-01T00:00:00.000Z'
          )
        }
      }
    },
    { $limit: 5 },
    {
      $project: {
        title: 1,
        genres: 1,
        released: 1,
        'imdb.rating': 1
      }
    }
      {
      $out: 'movie_top_romance' // collection name
      }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

By running this pipeline, will receive no output -- this is cuz the output has been redirected to our desired collection. By placing our results into a collection, can store, share, and update new complex aggregation results.

#### Listing the most user-commented Movies

Some additional info you have gathered is that they wish for the result to be a simple as possible and they wish to know the movie title and rating -- additionally, they would like to see the top 5 most commented-on movies. Fore the codebase like:

```js
const pipeline = [
    {$sample:{}},
    {$group:{}},
    {$sort:{}},
    {$limit: {}},
    {$unwind:},
     {$project: {}},
    {$out: {}}
]
```

For this just first:

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
    { $sort: { sumComments: -1 } }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

When building pipelines, it’s important to periodically run them partically completed to make sure you see the results you are expecting. Then need to perform a lookup into the `movies`collection to match your comment groups with the movie documents.

## Interface Pollution

Abusing them is generally not a good idea -- Interface pollution is about overwhelming our code with unncessary abstractions -- making it harder to understand -- it’s a common mistake made by developers coming from another language with different habits.

To understand what makes interfaces so powerful -- will dig into popular ones from stdlib -- `io.Reader`and `io.Writer`-- -- The `bufio`package in Go provides buffered input/ouput operations -- it is designed to improve the efficiency of reading and writing data by reducing the number of system calls made to the underlying I/O devices. And the `Scanner`-- provides a convenient interface for reading data that is split into tokens -- 

- `NewScanner(r io.Reader) *Scanner`-- Creates a new `Scanner`to read from an `io.Reader`by default, it uses the `ScanLines`at the splitting function.
- `Split(split splitFunc)`-- sets the split function for the `Scanner`-- the split function defines how the input is tokensized. `ScanLines, ScanBytes, ScanRunes, ScanWords`fore
- `Scan() bool`-- advances the `Scanner`to the next token. Returns `true`if a token was successfully scanned and is available through the `Bytes()`or `Text()`methods.
- `Bytes() []byte`-- returns the most recent token as a byte slice
- `Text() string`-- returns the most recent token as a newly allocated string
- `Err() error`-- return the first non-EOF error

```go
func main() {
    file, err := os.Open("example.txt")
    if err != nil {
        fmt.Println("Error opening file:", err)
        return
    }
    defer file.Close()
    for scanner.Scan() {
        line := scanner.Text()
        fmt.Println(line)
    }
    if err := scanner.Err(); err!= nil {
        println(...)
    }
}

// write a fiel
func main() {
    file, err := os.Create("output.txt")
    if err != nil {
        fmt.Println("error creating file:", err)
        return
    }
    defer file.Close()
    
    writer := bufio.NewWriter(file)
    _, err = writer.WriteString("Hello\n")
    if err != nil {
        //...
    }
    err = writer.Flush() // ensure all buffered is written to the file
    if err != nil {
        fmt.Println("Error flushing buffer:", err)
        return
    }
}
```

#### Concepts -- 

To understand what makes interface so powerful -- will dig into two pupular ones from the stdlib -- `io.Reader`and `io.Writer`-- Fore, writing a unit test for this -- 

### Thread communications using memory sharing

This is what is known as *inter-thread* communication ITC or *inter-process* communciation IPC. This type of communication falls under two main classes, memory sharing and message passing. Memory sharing is similar to having all our executions share a large empty canvas.

#### Updating shared variables from multiple goroutines

```go
const allLetters = "abcdefghijklmnopqrstuvwxyz"

func countLetters(url string, frequency []int, mutex *sync.Mutex) {
	resp, _ := http.Get(url)
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		panic("Server returning error code:" + resp.Status)
	}
	body, _ := io.ReadAll(resp.Body)
	mutex.Lock()
	for _, b := range body {
		c := strings.ToLower(string(b))
		cIndex := strings.Index(allLetters, c)
		if cIndex >= 0 {
			frequency[cIndex] += 1
		}
	}
	mutex.Unlock()
	fmt.Println("Completed:", url)
}

// sync version like:
func main() {
	var frequency = make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		countLetters(url, frequency)
	}
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, frequency[i])
	}
}
```

In the `main`, The program calls our `countLetters()`function sequentially to download and process each web page. need to improve the speed of our program by using concurrent programming -- 

```go
for i := 1000; i <= 1030; i++ {
    url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
    go countLetters(url, frequency)
}
time.Sleep(10 * time.Second)
```

The problem is in the result -- when compare the character counts of the sequential run against the concurrent one, notice -- most characters have a lower count in the concurrent version. This is the result what’s known as a *race condition* -- when have multiple threads sharing a resource and they step over each other, giving us unexected results.

Race conditions are what happens when your program is trying to do many things at the same time.

#### Proper sync and communication elimination race conditions 

Go gives us a tool detect race conditions in the code -- can run the Go compiler with the `-race`command-line flag. This this, the compiler adds special code to all memory accesses to *track when differenet goroutines are reading from and writing to memory*. Fore:

```sh
go run -race stingyspendy.go
```

For this, To’s race detector found our race condition, it points to critical sections in the code.

```go
func (g *Game) Play() {
	fmt.Println("Welcome to Gordle")
	for currentAttempt := 1; currentAttempt <= g.maxAttempts; currentAttempt++ {
		guess := g.ask()

		// check it
		fb := computeFeedback(guess, g.solution)

		// print the feedback
		fmt.Println(fb.String())

		if slices.Equal(guess, g.solution) {
			fmt.Printf("🎉 You've won! The solution was: %s. \n", string(g.solution))
			return
		}
	}
	fmt.Printf("😞 You've lost! The solution was: %s. \n", string(g.solution))
}
```

### Corpus

in Linguistics, a corpus is a collection of sequences or words assumed to be representative of and used for lexical, grammatical, or other linguistic analysis -- our will be a list of words with the same number of characters. 

Create a list of words -- fore

`func ReadFile(name string) ([]byte, error)`-- `os.ReadFile`function. It’s gookd to keep in mind that files when written on disk -- are nothing but a chunk of bytes. Nice characters, spaces, tabulation, tables -- are rendered by file editors. Manipulating an array of bytes in our case is not very practical, so will convert it to a string in order to split on any whitespace, including the new line characters -- the `strings`package exposes a `Split`and its siblings `SplitAfterN, SplitN`, `Cut`, and `Fields`-- These functions come in handy when the need to split strings arises -- in our case, the basic `Fields`is enough -- as it will split the string into a slice of its substrings delimited by all default whitespaces.

```go
// ErrCorpusIsEmpty is returned when we cannot find any valid solution
const ErrCorpusIsEmpty = corpusError("corpus is empty")

// ReadCorpus reads the file located at the given path
// and returns a list of words
func ReadCorpus(path string) ([]string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("unable to open %q for reading %w", path, err)
	}
	if len(data) == 0 {
		return nil, ErrCorpusIsEmpty
	}

	// expect the corpus to be a line - or space-separated list of words
	words := strings.Fields(string(data))
	return words, nil
}
```

#### Sentinel errors

Error management is at the heart of software development, whenever your chosen language and whatever application you are making -- say you try to read a file line by line -- it coud be that the file doesn’t exist, or might be missing the adequate rights to read it. Or it could be empty in incomplete -or, finally, accessible, and you could read it to the end -- in all these cases, you get an error back -- your program’s reaction will be different depending on which error case you fall into. Would like to check the error that was returned with a line of code such as `err == ErrNoSuchFile`or `err== EOF`.

Sentinel errors are a type of recognisable errors -- in Go, errors are values -- meaning that they carry a meaning -- Sentinel errors must behave like constants -- but Go will only accept primitive types as constants, and not method calls. The two default way to build an error are by calling `fmt.Errorf`or `errors.New`-- and these don’t produce constant values -- produce the output of a function, which isn’t known at compile time -- only at execution time.

This implies that errors generated by `fmt.Errorf`or `errors.New`will always be variable. 

```go
// corpusError defines a sentinel error
type corpusError string

// Error is the implementation of th error interface by corpusError
func (e corpusError) Error() string {
	return string(e)
}
```

Here, declare a `corpusError`that is a constant and still implments the error interface. Wish this type were in the.

## Catching runtime errors

As soon as we begin adding dynamic behavior to our HTML templates there is a risk of encounting runtime errors -- In the template, add a line `{{len nil}}`-- which should generate an error at runtime cuz in Go the value `nil`does not have a length. But if curl to the request -- get a response which looks a bit like this -- output all the template. This is bad, for app has thrown an error, but the user has wrongly been sent a 200 ok resposne -- So:

```go
func (app *application) render(w http.ResponseWriter, status int, page string,
                               data *templateData) {
    ts, ok := app.templateCache[page]
    if !ok {
        err := fmt.Errorf("the template %s does not exist", page)
        app.serverError(w, err)
        return
    }
    
    // initialize a new buffer
    buf := new(bytes.Buffer)
    
    // Write the template to the buffer, instead of straight to the 
    // http.ResponseWriter -- if there is an error, call our serverError() helper
    err := ts.ExecuteTemplate(buf, "base", data)
    if err != nil {
        app.serverError(w, err)
        return
    }
    
    w.WriteHeader(status)
    buf.WriteTo(w)
}
```

#### Common dynamic data

In some web apps where may be common dynamic data that you want to include on more than one -- webpage -- fore, might want to include the name and profile picture of the current user -- or a CSRF token in all pages with forms -- 

```go
type templateData struct {
    CurrentYear int
    Snippet *models.Snippet
    Snippets []*models.Snippet
}

func (app *application) newTemplateData(r *http.Request) *templateData {
    return &templateData {
        CurrentYear: time.Now().Year(),
    }
}

func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id < 1 {
        app.notFound(w)
        return
    }
    snippet, err := app.snippets.Get(id)
    if err != nil {
        if errors.Is(err, models.ErrNoRecord) {
            app.notFound(w)
        }else {
            app.serverError(w, err)
        }
        return
    }
    
    data := app.newTemplateData(r)
    data.Snippet= snippet
    app.render(w, http.StatusOK, "view.html", data)
}
```

Then the final thing need to do is update the `base.html`file to display the year in the footer.

```html
Powered by <a href="https://golang.org/">Go</a> in {{.Currentyear}}
```

#### Custom template functions

To illustrate this, create a custom `humanDate()`function which outputs datetimes in a nice format -- instead of outputting dates in the default format like are currently -- 

There are two main steps to doing this -- 

- Need to create a `template.FuncMap`object containing the custom `humanDate()`function
- need to use the `template.Funcs()`method to register this before parsing the templates.

```go
// create a humanDate function which returns a nicely formatted string
func humanDate(t time.TIme) string {
    return t.Format("02 Jan 2006 at 15:04")
}

var functions = template.FuncMap{
    "humanDate": humanDate,
}

func newTemplateCache()(map[string]*template.Template, error) {
    cache := map[string]*template.Template{}
    pages, err := filepath.Glob("./ui/html/pages/*.html")
    // err handle
    
    for _, page := range pages {
        name := filepath.Base(page)
        
        ts, err := template.New(name).Funcs(functions).ParseFiles(".../base.html")
        // handle error
        ts, err = ts.ParseGlbo(".../*.html")
        if err != nil {
            return nil, err
        }
        ts, err = ts.ParseFiles(page)
        // handle error
        cache[name]= ts
    }
    return cache, nil
}
```

Then in the html use this like:

```html
<td>{{humanDate .Created}}</td>
```

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
    return &tmeplateData {
        CurrentYear: time.Now().Year(),
    }
}
```

