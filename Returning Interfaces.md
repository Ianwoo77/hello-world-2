# Returning Interfaces (don’t)

While designing a function signature -- may have to return either an interface or a concrete imp. Will consider two packages -- 

- `client` -- which contains a `Store`interface
- `store`-- contains an implementation of `Store`.

In the store `InMemoryStore`struct that implement the `Store`interface -- Meanwhile, create a `NewInMemoryStore`func to returns a `Store`interface.

```go
// in the package store
func NewInMemoryStore() Store {...}
```

If, `client`can’t call `NewInMemoryStore`anymore, otherwise, would be a cycle denepdnencies. So:

- Returning a struct instead of interfaces.
- Accepting interfaces if possible.

### `any`sasys nothing

In Go, an interface type that specifies zero methods is known as the empty interface -- `interface{}`-- the predeclared type `any`became an alias for an empty interface -- all `interface{}`occcurrences can be replaced by `any`-- In many cases, `any`can be considered an over-generalzation.

By using `any`, lose some of the benefits of Go as a statically typed language, instead, should avoid `any`type and make our signatures explicit as much as possible. There are cases when `any`is helpful -- `encoding/json`package -- 

```go
func Marshal(v any) ([]byte, error) {//...}
```

Another is in the `database/sql`-- like:

```go
func (c *Conn) QueryConnect(ctx context.Context, query string, args ...any) (*Rows, error) {...}
```

The parameter could be any kind.

### When to use generics

It can be confusing about when to use generics and when not ot -- 

#### concepts

Fore, from a `map[string]int`type like:

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k := range m {
        keys= append(keys, k)
    }
    return keys
}
```

What if want to use a similar feature for another map type before Go 1.18, just like:

```go
func getKeys(m any) ([]any, error) {
    switch t := m.(type) {
    default:
        return nil, fmt.Errorf("unknown type: %T", t)
    case map[string]int:
        var keys []any
        //...
    }
}
```

So Type parameters are generic types that we can use with functions and types, fore, the following function accepts a type parameter -- like:

```go
func foo[T any](t T) {...}
```

when calling `foo`, just pass a type argument of `any`type, supplying a type argument is called *instanatiation*. So:

```go
func getKeys[K comparable, V any](m map[K]V) []K {
    var keys []K
    for k := range m {
        keys= append(keys, k)
    }
    return keys
}
```

And the restricting type arguments to match specific requirements is called a *constraint* -- a constraint is an interface type that can contain like -- 

- A set of behaviors
- Arbitrary type 

```go
type customConstraint interface {
    ~int | ~string
}
func getKyes[K customConstraint, V any] []K {
    //...
}
```

For this, first define a `customConstraint`interface to restrict types to be eigher `int`or `string`using the union `|`operator -- `K`is now a `customConstraint`instead of a `comparable`as before,  and the signature of `getKeys`just encorfces that we can call it with a map of `any`value type -- but the key type has to be `int`or `string`. For another example like:

```go
type Node[T any] struct {
    Val T
    next *Node[T]
}
func (n *Node[T]) Add(next *Node[T]) {
    n.next = next
}
```

Used the type parameters to define `T`and use both fields in `Node`-- regarding the method, the receiver is instantiated -- cuz `Node`is generic, it has to follow the defined type parameter as well.

One last thing to note that is they can’t be used with method arguments. like:

```go
type Foo struct {}
func (Foo) bar[T any] (t T) {...} // error
```

#### Common uses and misuses

When are generics useful -- discuss a few common uses where generics are recommended -- 

- Data structures -- can use generics to factor out the elememt type if we implement a binary tree...

- *Functions working with slices, maps, channels* of any type -- 

  ```go
  func merge[T any](ch1, ch2 <-chan T) <-chan T {...}
  ```

- Factoring out behaviors instead of types -- fore the `store`package.

Conversely, when is it recommended that **NOT** use generics -- 

- When calling a method of the *type argument* like:

  ```go
  func foo [T io.Writer] (w T) {
      b := getBytes()
      _, _ = w.Write(b)
  }
  ```

  for this using generics won’t bring any value.

- When it makes code more compex.

## Flushing results on close

Haven’t really done anything interesting with our URL download app -- apart from extracting the words now. This new `longestWords()`goroutine is slightly different from the other goroutines we have developed in our pipeline -- it accumulates a set of unique words in its memory. Once it has read **all** the words from the web pages and retreives the close mesage, will review this set and output 10 longest ones -- like:

```go
func longestWords(quit <-chan struct{}, words <-chan string) <-chan string {
	longWords := make(chan string)

	go func() {
		defer close(longWords)
		uniqueWordsMap := make(map[string]bool)
		uniqueWords := make([]string, 0)
		moreData, word := true, ""
		for moreData {
			select {
			case word, moreData = <-words:
				if moreData && !uniqueWordsMap[word] {
					uniqueWordsMap[word] = true
					uniqueWords = append(uniqueWords, word)
				}
			case <-quit:
				return
			}
		}
		// still in this goroutine
		sort.Slice(uniqueWords, func(a, b int) bool {
			return len(uniqueWords[a]) > len(uniqueWords[b])
		})

		longWords <- string.Join(uniqueWords[:10], ", ")
	}()
	return longWords
}
```

For this, the goroutine stores all the unique words on a map and a list -- once the input channel closes, meaning there are no more messages, the goroutine srots the list of unique words by length. Then, on the output channel, it sends the first 10 items on the list.

Can now connect this new component to our pipeline in the `main()`function like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)

	urls := generateUrls(quit)
	pages := make([]<-chan string, 20)
	for i := range pages {
		pages[i] = downloadPages(quit, urls)
	}
	results := longestWords(quit, extractWords(quit, FanIn(quit, pages...)))
	fmt.Println("Longest words", <-results)
}
```

#### Boardcasting to multiple goroutines

What if we want to find out more stats from our download pages -- for this scenario, say that in addition to finding the longest words, want to find which words occur most frequently -- For this, feed the output of `extractWords()`to two goroutiens -- the existing `longestWords`and an in additional one  called `frequentWords()`.

Note that the pattern of the new function will be the same as that of `longestWords()`-- store the frequency of each unique word, and when the input closes,  it will store the frequency of each unique word.

For this scenairo, we can use a boardcast pattern -- one that *replicates* messages to a set of output channels. We can use a separate goroutine that boardcasts to multiple channels.

To implement this, just create a list of output channels and then use a goroutine that writes *every* received message to each cahnnel -- Specifying the number of outputs that are needed. The function then returns thse `n`output channels in a slice. In this imp, using generics like:

```go
func Broadcast[K any](quit <-chan struct{}, input <-chan K, n int) []chan K {
	outputs := createAll[K](n)
	go func() {
		defer closeAll(outputs)
		var msg K
		moreData := true
		for moreData {
			select {
			case msg, moreData = <-input:
				if moreData {
					for _, output := range outputs {
						// if input hasn't been closed, send msg to all outputs
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

func createAll[K any](n int) []chan K {
	channels := make([]chan K, n)
	for i, _ := range channels {
		channels[i] = make(chan K)
	}
	return channels
}

func closeAll[K any](channels []chan K) {
	for _, output := range channels {
		close(output)
	}
}
```

Then write the `frequentWords()`first, which will identify the top 10 most frequently occuring words in our download pages -- the imp in the following listing is simialr to the `longestWords()`function like:

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
		// also in this goroutine
		sort.Slice(freqList, func(a, b int) bool {
			return freqMap[freqList[a]] > freqMap[freqList[b]]
		})
	}()
	return mostFrequentWords
}
```

For now, can wire the `frequentWords()`unit with the broadcast utility we developed previously -- call the `Broadcast()`to create two output channels and make it consume from `extractWords`like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)

	urls := generateUrls(quit)
	pages := make([]<-chan string, 20)
	for i := range pages {
		pages[i] = downloadPages(quit, urls)
	}
	words := extractWords(quit, FanIn(quit, pages...))
	wordMulti := Broadcast(quit, words, 2)
	longestResults := longestWords(quit, wordMulti[0])
	frequentResults := frequentWords(quit, wordMulti[1])
	fmt.Println("Longest words:", <-longestResults)
	fmt.Println("Frequent words:", <-frequentResults)
}
```

#### Closing a channels after a condition

Haven’t really used the `quit`channels that have wired into every goruotine in our application. These quit channles can be used to stop parts of the pipeline on certain conditions. Are just reading a fixed number of web pages and then processing them -- what if wanted to process only the first 10,000 words that we downloads -- The solution is to add another execution that stops a section of our pipeline after it has consumed. `Take(n)`-- after the `extractWords()`goroutine, can instruct it to close the `quit`channel after receiving a specified number of messages. Implement the `Take(n)`-- need  goroutine that simply fowrads the message received from the input to the output channel while keeping countdown -- like, with every message forward reducing the coundown by 1. Once the countdown is 0, the goroutine closes the `quit`and output channels. like:

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

When now add this new component to our pipeline and make it stop the processing when it reaches a specific word count, the following listing shows we can modify our `main()`to include the `Take(n)`-- like:

```go
urls := generateUrls(quitWords)
pages := make([]<-chan string, 20)
for i := range pages {
    pages[i] = downloadPages(quitWords, urls)
}
words := Take(quitWords, 100, extractWords(quitWords, FanIn(quitWords, pages...)))
```

#### Adopting channels as *first-class* objects 

In this CSP language paper, uses an example of generating prime numbers up to 10,000 with a list of communicating sequential processes -- the algorithm is based on the -- which is a simple method for checking whether a number is prime -- the approach of the CSP uses a static linear pipeline where each process in the pipeline filters the multiple of prime number and then passes it on to the next process. This means that a channel can be stored as a variable and passed around to other functions. In Go, a channel can also be passed on another channel.

```go
func (app *application) readIDParam(r *http.Request) (int64, error) {
	params := httprouter.ParamsFromContext(r.Context())
	id, err := strconv.ParseInt(params.ByName("id"), 10, 64)
	if err != nil || id < 1 {
		return 0, errors.New("invalid id parameter")
	}
	return id, nil
}
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Request) {
    id, err := app.readIDParam(r)
    if err != nil {
        http.NotFound(w, r)
        return
    }
    
    movies := data.Movie {
        ID : id, 
        //...
    }
    err := app.writeJSON(w, http.StatusOK, movie, nil)
    if err != nil {...}
}

func (app *application) writeJSON(w http.ResponseWriter, status int, data any, 
                                  headers http.Header) error {
    js, err := json.Marshal(data)
    if err != nil {
        return err
    }
    js = append(js, '\n')
    for key, value := range headers {
        w.Header()[key] = value
    }
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    w.Write(js)
    return nil
}
```

#### Using `json.encoder`

At the start of this, mentioned that it’s also possible to use Go’s `json.Encoder()`type to perform the encoding, this allows you to encode an object to JSON and <u>write that JSON to an output stream</u> in a single step.

```go
func (app *application) exampleHandler(w http.ResponseWriter, r *http.Request) {
    data := map[string]string {
        "hello": "wordl",
    }
    w.Header().Set("Content-Type", "application/json")
    err := json.NewEncoder(w).Encode(data)
    if err != nil {
        app.logger.Print(err)
        http.Error(w, "The server encountered a problem", http.StatusInternalServerError)
    }
}
```

This pattern works, and it’s neat and elegant -- but there is a slightly problem -- when call
`json.NewEncoder(w).Encode(data)`the JSOn is created and written to the `http.ResposeWriter`in a single step, whichmeans there is no opportunity to set HTTP response header conditionally based on whether the `Encode`method returns an error.

Want to set a `Cache-Control`fore, on a successful rsponse, but not aset a `Cache-Control`if the JSON encoding fails and you have to return an error response.

Fore, want to set a `Cache-Control`header on a successful response, but not set a `Cache-Control`if the JON -- implementing thet cleanly using the `json.Encoder`pattern is just quite difficult -- *could* set the `Cache-Control`header and then *delete* it from the header map again in the event of an error. 

Another option is to write the JSON to an interim `bytes.Buffer`instead of directly to the `http.ResponseWriter`-- can then checnk for any errors, before setting the `Cache-Control`and copying the JSON from the `bytes.Buffer`to the `http.ResponseWriter`.

## Encoding structs

Instead of encoding a map to create this JSON object this time we are going to encode a custom `Movie`-- need to begin by defining a custom `Movie`struct -- do this inside a new `internal/data`package -- which later will grow to encapsuate **all** the custom data types for our proj . like:

```go
func (app *application) showMovieHandler(w http.ResponseWriter, r *http.Reuest) {
    id, err := app.readIDParam(r)
    if err != nil {
        http.NotFound(w, r)
        return
    }
    movie := data.Movie {
        ID: id, 
        //...
    }
    // encode the struct to JSON and send it as the http response
    err = app.writeJSON(w, http.StatusOK, movie, nil)
    if err != nil {
        app.logger.Print(err)
        http.Error(...)
    }
}
```

#### Chaning keys in the JSON object -- 

One of the nice things about encoding structs in Go is that you can customize the JSON by annotating the fieds with *struct tags*. -- the most common use of struct tags is to change the key names that appera in the JSON object. This can be useful when your struct field names aren’t appropriate for public-facing response. Like:

```go
type Movie struct {
	ID        int64     `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	Title     string    `json:"title"`
	Year      int32     `json:"year"`
	Runtime   int32     `json:"runtime"`
	Genres    []string  `json:"genres"`
	Version   int32     `json:"version"`
}
```

#### Hiding struct fields in the JSON object

also possible to contril the visibility of individual struct fields in the JSON by using the `omitempty`and `-`struct tag directives -- the `-`directive can be used when you *never* want a particualr struct filed to appear in the JSON output.

```go
type Movie struct {
    ID int64 `json:"id"`
    CreatedAt time.Time `json:"-"`
    Runtime int32 `json:"runtime,omitempty,string"`
}
```

Also note that the `string`directive will only work on fields which have `int*, unit* float* bool`types.

### Formatting and enveloping Responses

If U try making some requests using curl, Can make these easier to red in terminals by using the `json.MarshalIndent()`function to encode our response data,  instad of regular `json.Marshal()`.
`js, err := json.MarshalIndent(data, "", "\t")`, perfiex and indent

#### Relative performance

While using `json.MarshalIndent()`-- is positive from a readability and user-experience point of view, it unfortunately doesn’t come for free. As well as the fact that the responses are now slightly larger, the extra work that Go deos to add the whitespace has a notable impact on performance. If your API is operating a very resource-constrained environment, or needs to manage extremely high level of traffic, then this is worth being aware of and you may prefer to stick with using `json.Marshal()`instead like:

#### Enveloping responses

Next -- work on updating our responses so that the JSON data is always *enveloped* in a parent JSON object like:

```json
{
    "movie": {
        "id": 123,
        "title": "...",
        //...
    }
}
```

For this, just noticed that how the movie data is nested under the key `movie`here -- rather than being the top-level JSON object itself -- enveloping response data like this isn’t strictly necessary, and whehter U choose to do so is partly a matter of style and taste. But there are just a few tangible benefits -- 

1. Including a key name like `movie`at the top-lvel of the JSON helps make the response more *self-documenting*.
2. It reduces the risk of errors on the client side, cuz it’s harder to accidentally process one response thinking that it is sth different.
3. If always envelope the data returned by our API, then mitigate a *security vulnerability* in older browsers.

And there are a couple of techniques that could use to envelope our API responses, but going to keep things simple and do it by creating a custom envelope map with the underlying type `map[string]any`

```go
type envelope map[string]any
func (app *application) writeJSON(w http.ResponseWriter, status int, data envelope,
                                  headers http.Header) error {...}
```

Then also needs to update our `showMovieHandler`to create an instance of the `enevelope`map containing the movid data, and pass this onwards to our `writeJSON()`helper instead of passing the movie data directly.

```go
err = app.writeJSON(w, http.StatusOK, envelope{"movie": movie}, nil)
if err != nil {
    app.logger.Print(err)
    http.Error(w, "The server encounter a problem", http.StatusInternalServerError)
}
```

Also need to update the code in the `healthcheckHandler`so that passes an `envelope`type to `writeJSON()`.

```go
func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	env := envelope{
		"status": "available",
		"system_info": map[string]string{
			"environment": app.config.env,
			"version":     version,
		},
	}
	err := app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		app.logger.Print(err)
		http.Error(w,
			"The server encountered a problem and could not process your request",
			http.StatusInternalServerError)
	}
}
```

It’s important to emphasize that thereis no single right or wrong way to structure your JSON responses. There are some popular formats fore `JSON:API`and `jsend`that might like to follow.