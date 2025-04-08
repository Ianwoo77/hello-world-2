# Selecting the Title

- Match movies that were released before 2001
- Find the average popularity of each genre
- Sort the genres by popularity
- Output the adjusted runtime of each movie
- Project the adjusted runtime as `total_runtime`

Just like:

```js
const pipeline = [
    {$match: {}},
    {$group: {}},
    {$sort: {}},
    {$project: {}}
];
```

Just like:

```js
db.getCollection('movies').aggregate(
  [
    {
      $match: {
        released: {
          $lte: ISODate(
            '2001-01-01T00:00:00.000Z'
          )
        }
      }
    },
    {
      $group: {
        _id: { $arrayElemAt: ['$genres', 0] },
        popularity: { $avg: '$imdb.rating' },
        top_movie: { $max: '$imdb.rating' },
        longest_runtime: { $max: '$runtime' }
      }
    },
    { $sort: { popularity: -1 } },
    {
      $project: {
        _id: 1,
        popularity: 1,
        top_movie: 1,
        adjusted_runtime: {
          $add: ['$longest_runtime', 12]
        }
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

For the `$group`stage -- groups the documents based on a specified key and perform aggregation operations on each group -- 

- `_id`- this defines the grouping key, It takes the first element of the `genres`array for each movie and use that as the `_id`for the group.
- `populartiy: {$avg: ‘imdb.rating’}`-- calculates the average of `imdb.rating`field across all movies in that group and names the resulting field. Note that for each group -- for `genre`in this example.

#### Selecting the title from each movie -- 

Under the `$group`stage, just add: However, this result won’t adi them in picking a specific movie -- must execute a different query go get a list of movies in each genre and pick the best movie to show form the list. So, first do `$match`then do the `$sort`, and for `$group`stage just like:

```js
/**
 * query: The query in MQL.
 */
{
  released: {$lte: new ISODate('2001-01-01')},
  runtime: {$lte:218},
  'imdb.rating': {$gte: 7.0}
} // change the $match stage first
```

Then to get the remcommended title for each category, use the `$first`accumulator in our group stage to get the top document for each genre. Just like:

```js
/**
 * _id: The id of the group.
 * fieldN: The first field name.
 */
{
  _id: { $arrayElemAt: ["$genres", 0] },

  'recommended_title': {$first: '$title'},
  'recommended_rating': {$first: '$imdb.rating'},
  'recommended_runtime': {$first: '$runtime'},
  popularity: { $avg: "$imdb.rating" },
  top_movie: { $max: "$imdb.rating" },
  longest_runtime: { $max: "$runtime" }
}
```

Can see that with a fiew addition to your pipeline, have extracted the movies with the highest ratings and longest runtime to create extra value for your client.

### Working with Larger Datasets 

The `movies`collection has roughly 23500 documents, May be working on a scale of millions instead of thousands. The first step in learning how to deal with large datasets is understanding `$sample`-- this stage is imple yet useful -- the only parameter to the `$sample`is the desired size of your sample -- this randomly select documents and passes them through to the next stage like: `{$sample: {size:100}}`-- will reduce the scope to 100 random docs.

By doing this, can significantly reduce the number of documents going through your pipeline. The first reason is to speed up the execution time when running aginast enornous datasets -- Mainly while you are fine-tuning or building your aggregation -- the second is for queries where the use case can tolerate documents missing from the result.

The primary reason is that `$limit`always respects the order of the documents and thus returns the same documents every time. Fore:

```js
db.getCollection('movies').aggregate(
  [
    {
      $match: {
        plot: { $regex: RegExp('around') }
      }
    },
    { $limit: 3 }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

### Joining collections with `$lookup`

Sampling may assist U when developing queries against extensive collections, but in production queries, you may sometimes need to write queries that are operating acorss multiple collections -- in MDB, these collection joins are done using the `$lookup`aggregation step -- like:

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

First, are running the `$match`against the `users`collections to get only two users named... once we have these two records, perform our lookup -- the 4 parameters of `$lookup`are as follows -- 

- `from`-- the *collection* we are joining to our current aggregation -- we are joining `comments`to `users`.
- `localField`-- the field name that we are going to use to join our documents in the local collection.
- `foreignField`-- field that links to `localField`in the `from`. the may have different names
- `as`-- This is how our new joined data will be labeled

Purpose -- this stage performs a left outer join with another collection. And adds any comments with the same name into a new array field for the original user document. And the new array is called `comments`. In this example, cuz uers have made many comments, so the embedded array becomes quite substantial and challenging to view. This issue presents an excellent place to introduce the `$unwind`operator. Like:

`${unwind: ‘$comments’}`Then also `$limit` this. Can see multiple documents per use with a single document for each comment instead of one embedded array.

## `return`statement after replying to an HTTP request

While writing an HTTP handler, it’s easy to forget the `return`after replying to an HTTP request --  This may lead to an odd situation where we should have stopped a handler after an error. Can observe fore:

```go
func handler(w http.ResponseWriter, req *http.Request) {
    err := foo(req)
    if err != nil {
        http.Error(w, "foo", http.StatusInternalServerError)
    }
}
```

For this, if has an error, handle it using the `http.Error`which replies to the request with the `foo`error message and a 500 internal server error. The problem with this code is that the app will continue its execution, cuz the `http.Error`doesn’t stop the handler’s execution. The problem is -- suppose we had completed the previous HTTP handlers by adding step to write a successful HTTP respsone body and status code like:

```go
func handler(w http.ResponseWriter, req *http.Request) {
    err := foo(req)
    if err != nil {
        http.Error(w, "foo", http.StatusInternalServerError)
    }
    _, _ = w.Write([]byte("all good"))
    w.WriteHeader(http.StatusCreated)
}
```

In this case, `err!=nil`-- the http response will continue execute. For this exampke, would return only the first HTTP status code in the previous -- 500. However, Go would also log a warning. -- means that we tried to write status code multiple times and doing so was superfluous. Just add the `return`. This error is probably not the most complex.

### Don’t use default HTTP client and server

The `http`package provdies HTTP client and server imps -- it’s all too easy for developers to make a common mistake -- relying on the default imp in the context of apps that are eventually deployed in production.

#### HTTP Client

Fore, use a `GET`as an example -- like;

```go
client := &http.Client{}
resp, err := client.Get("https://golang.org/")
// or use the `http.Get`directly
resp, err := http.Get("https://..")
```

in the end, both approaches are the same -- Note that the `http.Get()`uses `http.DefaultClient`-- like:

```go
// DefaultClient is the default client and used by Get, Head, Post
var DefaultClient = &Client{} // in the http package
```

First the default client doesn’t specify an timeouts -- this absence of timeout is not sth we want for production it can lead to many issues, such as never-ending requests that could exhaust system resources. In Go, There are 5 steps involved in an HTTP request like:

1. Dail to establish a TCP connection
2. TLS handshake
3. Send req
4. Read the resp headers
5. Read the resp Body

The 4 main timeouts are the following -- like:

1. `net.Dialer.Timeout`-- specifies the maximum amount of time a dail will wait for a connection to complete.
2. `http.Transport.TLSHandshakeTimeout`-- the maximum amount of time to wait for the TLS handshake
3. `http.Transport.ResponseHeaderTimeout`-- The amount of time to wait for a server’s resp headers
4. `http.Client.Timeout`-- specifies the time limit for a requst request. It includes all the steps, from step 1 to step 5.

##### Http client timeout --

May have encountered the following error when specifying `http.Client.Timeout`like: `net/http`-- request canceled (`Client.Timeout`exceed while awaiting headers) -- this error means the endpoint failed to respond on time. Like:

```go
client := &http.Client {
    Timeout: 5*time.Second,
    Transport: &http.Transport {
        DailContext: (&net.Dialer {
            Timemout: time.Second,
        }).DialContext,
        TLSHandshakeTimeout: time.Second,
        ResponseHeaderTimeout: time.Second,
    },
}
```

And to configure the number of connection in the pool, must override `http.Transport.MaxIdleConns`-- This value is set to 100 by default -- but there is sth important to not -- the `http.Transport.MaxIdleConnesPerHost`limit per host.

#### Http Server

Shold also be careful while implementing an HTTP server -- a default server can be created using the 0 value of `http.Server`-- like:

```go
server := &http.Server{}
server.Serve(listner)
```

Or can use a function such as `http.Serve`, `http.ListenAndServe`or `http.ListenAndServeTLS`that also relies on the default `http.Server`-- Also, once a connection is accepted, an http response is divided into 5 steps like:

1. Wait for client to send the request
2. TLS handshake (if enabled)
3. Read the request headers
4. Read the request body
5. Write the response

Following this, these relate to the main server timeouts -- the 3 main timeouts are the following -- 

- `http.Server.ReadHeaderTimeout`-- field that specifies the maximum amount of time to read req headers
- `http.Server.ReadTimeout`-- maximum amount of time to read entire request
- `http.TimoutHandler`-- A wrapper func that specifies the maximum amount of time for handler to complete.

So, while exposing our endpoint to understand clients, the best practice is to set at least the `http.Server.ReadHeaderTimeout`field and use the `http.TimeoutHandler`wrapper function like:

```go
s := &http.Server {
    Addr: ":8080",
    ReadHeaderTimeout: 500*time.Millisecond,
    ReadTimeout: 500*time.Millisecond,
    Handler: http.TimeoutHandler(handler, time.Second, "foo")
}
```

### Testing and benchmark for the string op

```go
func (fb feedback) Equal(other feedback) bool {
	if len(fb) != len(other) {
		return false
	}
	for i, v := range fb {
		if v != other[i] {
			return false
		}
	}
	return true
}
```

Then the test for the string -- 

```go
func Test_feedback_String(t *testing.T) {
	testCases := map[string]struct {
		fb   feedback
		want string
	}{
		"three correct": {
			fb:   feedback{correctPosition, correctPosition, correctPosition},
			want: "💚💚💚",
		},
		"one of each": {
			fb:   feedback{correctPosition, wrongPosition, absentCharacter},
			want: "💚🟡⬜️",
		},
		"different order for one of each": {
			fb:   feedback{wrongPosition, absentCharacter, correctPosition},
			want: "🟡⬜️💚",
		},
		"unknown position": {
			fb:   feedback{404},
			want: "💔",
		},
	}

	for name, testcase := range testCases {
		t.Run(name, func(t *testing.T) {
			if got := testcase.fb.String(); got != testcase.want {
				t.Errorf("got %q, want %q", got, testcase.want)
			}
		})
	}
}

func BenchmarkStringConcat1(b *testing.B) {
	fb := feedback{absentCharacter}
	for n := 0; n < b.N; n++ {
		_ = fb.StringConcat()
	}
}

func BenchmarkStringConcat2(b *testing.B) {
	fb := feedback{absentCharacter, wrongPosition}
	for n := 0; n < b.N; n++ {
		_ = fb.StringConcat()
	}
}

func BenchmarkStringBuilder1(b *testing.B) {
	fb := feedback{absentCharacter}
	for n := 0; n < b.N; n++ {
		_ = fb.String()
	}
}

func BenchmarkStringBuilder2(b *testing.B) {
	fb := feedback{absentCharacter, wrongPosition}
	for n := 0; n < b.N; n++ {
		_ = fb.String()
	}
}
```

Then the main execution logic like:

```go
func computeFeedback(guess, solution []rune) feedback {
    feedback := make([]hint, len(guess))
    used := make([]bool, len(solution))

    if len(guess) != len(solution) {
       _, _ = fmt.Fprintf(os.Stderr,
          "Internal error! Guess and solution have different lengths: %d vs %d",
          len(guess), len(solution))
       // return a feedback full of absent characters
       return feedback
    }

    // then check for correct letters
    for posInGuess, character := range guess {
       if character == solution[posInGuess] {
          feedback[posInGuess] = correctPosition
          used[posInGuess] = true
       }
    }

    // look for letters in the wrong position
    for posInGuess, character := range guess {
       if feedback[posInGuess] == correctPosition {
          // already has been marked, ignore it
          continue
       }
       for posInSolution, solutionCharacter := range solution {
          if used[posInSolution] {
             continue
          }
          if character == solutionCharacter {
             feedback[posInGuess] = wrongPosition
             used[posInSolution] = true
             break
          }
       }
    }
    return feedback
}
```

#### Testing the `computeFeedback()`-- 

To properly test the method `computeFeedback`-- we need to provide a guess, a solution and the expected feedback, Once have these, can call `computeFeedback`and verify that the received feedback is the expected one.

```go
func Test_computeFeedback(t *testing.T) {
	tt := map[string]struct {
		guess            string
		solution         string
		expectedFeedback feedback
	}{
		"nominal": {
			guess:            "HERTZ",
			solution:         "HERTZ",
			expectedFeedback: feedback{correctPosition,
                     correctPosition, correctPosition, correctPosition, correctPosition},
		},
		"double character": {
			guess:            "HELLO",
			solution:         "HELLO",
			expectedFeedback: feedback{correctPosition, correctPosition, correctPosition, correctPosition, correctPosition},
		},
		"double character with wrong answer": {
			guess:            "HELLL",
			solution:         "HELLO",
			expectedFeedback: feedback{correctPosition, correctPosition, correctPosition, correctPosition, absentCharacter},
		},
		"five identical, but only two are there": {
			guess:            "LLLLL",
			solution:         "HELLO",
			expectedFeedback: feedback{absentCharacter, absentCharacter, correctPosition, correctPosition, absentCharacter},
		},
		"two identical, but not in the right position (from left to right)": {
			guess:            "HLLEO",
			solution:         "HELLO",
			expectedFeedback: feedback{correctPosition, wrongPosition, correctPosition, wrongPosition, correctPosition},
		},
		"three identical, but not in the right position (from left to right)": {
			guess:            "HLLLO",
			solution:         "HELLO",
			expectedFeedback: feedback{correctPosition, absentCharacter, correctPosition, correctPosition, correctPosition},
		},
		"one correct, one incorrect, one absent (left of the correct)": {
			guess:            "LLLWW",
			solution:         "HELLO",
			expectedFeedback: feedback{wrongPosition, absentCharacter, correctPosition, absentCharacter, absentCharacter},
		},
	}
	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
            // call the computeFeedback using test data
			got := computeFeedback([]rune(tc.guess), []rune(tc.solution))
			if !slices.Equal(tc.expectedFeedback, got) {
				t.Errorf("expected %v, got %v", tc.expectedFeedback, got)
			}
		})
	}
}
```

## Cominbing functions

It’s possible to combine multiple functions in your template tags -- using the parentheses `()`to surrounding the functions and their arguments as necessary -- fore, the following tag will render the content `c1`if the length of `Foo`is greater than 99 fore:

```html
{{if (gt (len .Foo) 99)}} C1 {{end}}
```

Or as another example, the following tag will render the content like:

```html
{{if (and (eq .Foo 1) (le .Bar 20))}} C1 {{end}}
```

#### Controlling loop behavior -- 

Within a `{{range}}`action, can use the `{{break}}`commend to end the loop early, and `{{continue}}`to immediately start the next loop iteration -- like: 

```jsx
{{range .Foo}}
	{{if eq .ID 99}}
		{{continue}}
	{{end}}
{{end}}
```

### Caching templates

Before add more functionality to our HTML tempaltes, it’s a good time to make some optimization to the codebase.

1. Each and every time render a web page our app reads and parses the relevant template files using the `template.ParseFiles()`function. Could avoid this duplicated work by parsing the files once. When starting the app, and storing the parsed templates in an in-memory cache.
2. And, there is duplicated code in the `home`and `snippetView`handlers, we could reduce this duplication by creating a helper function.

Create an in-memory map with the type `map[string]*template.Template`to cache the parsed templates like:

```go
func newTemplateCache() (map[string]*template.Template, error) {
    // Initiazlie a new map to act as the cache
    cache := map[string]*template.Template{}
    
    // use the filepath.Glob() function to get a clie of all filepath that 
    // match the pattern -- will essentially gives us a slice of the filepaths for our app
    pages, err := filepath.Glob("./ui/html/pages/*.html")
    if err != nil {
        return nil, err
    }
    // Loop through the page filepaths one-by-one
    for _, page := range pages {
        // Extract the file name from the full filepath
        name := filepath.Base(page)
        
        // then create a slice contiaing the filepaths for our template
        files := []string{
            "./ui/html/base.html",
            "./ui/html/partials/nav.html",
            page,
        }
        
        // parse the files into a tempalte set
        ts, err := template.ParseFiles(files...)
        if err != nil {
            return nil, err
        }
        
        cache[name] = ts
    }
    return cache, nil
}
```

And the next step is to initialize this cache in the `main()`and make it available to our handlers as a dependency via the `application`struct like:

```go
type application struct {
    errorLog *log.Logger
    //...
    templateCache map[string]*template.Template
}

func main(){
    // ...
    // Initialize a new template cache...
    templateCache, err := newTempalteCache()
    if err != nil {
        errorLog.Fatal(err)
    }
    
    // And add it to the application dependencies
    app := &application {
        //...
        templateCache: templateCache,
    }
    srv := &http.Server{
        Addr: &addr,
        ErrorLog: errorLog,
        Handler: app.routes(),
    }
    // ...
    err = srv.ListenAndServe()
    //...
}
```

At this point, got an in-memory cache of relevant template set for each of our pages -- and our handlers have access to this cache via the `application`struct -- 

```go
func (app *application) render(w http.ResponseWriter, status int, page string,
                               data *templateData) {
    // Retreive the appropriate template set from the cache based on the page name
    ts, ok := app.templateCache[page]
    if !ok {
        err := fmt.Errorf("the template %s does not exist", page)
        app.serverError(w, err)
        return
    }
    w. WriterHeader(status)
    
    err := ts.ExecuteTemplate(w, "base", data)
    if err != nil {
        app.serverError(w, err)
    }
}
```

Can now get to see the pay-off from these chanages and can dramatically simplify the code like:

```go
// for the home handler just like:
func (app *application) home (w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        app.notFound(w)
        return
    }
    snippets, err := app.snippets.Latest()
    if err != nil {
        app.serverError(w, err)
        return
    }
    app.render(w, http.StatusOK, "home.html", &templateData{
        Snippets: snippets,
    })
}
```

#### Automatically parsing partials

Then make the `newTemplateCache()`function a bit more flexible so that it automatically parses *all templates* in the `ui/html/partials`folder, rather than only for `nav.html`file. 

```go
func newTemplateCache() (map[string]*template.Template, error) {
    cache := map[string]*template.Template{}
    
    pages, err := filepath.Glob("./ui/html/page/*.html")
    if err != nil {
        return nil, err
    }
    
    for _, page := range pages {
        name := filepath.Base(page)
        
        // parse the base file into a template set.
        ts, err := template.ParseFiles("./ui/html/base.html")
        // handle err
        ts, err = ts.ParseGlob("./ui/html/partials/*.html")
        // handle err
        
        // call ParseFiles()* on this set
        ts, err = ts.ParseFiles(page)
        // handle err
        
        cache[name]=ts
    }
    return cache, nil
}
```

