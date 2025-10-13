# Regular Expressions MongoDB

In the mongodb queries, regular expressions can be used with `$regex`operator -- just like:

```js
db.movies.find(
    {'title': {$regex: 'Opera'}}
)
mongodb+srv://abc:abc123+-*@cluster0.hti4s.mongodb.net/
db.movies.find(
    {'title': {$regex: '^Opera'}},
    {'title': 1}
)
```

#### Case-insensitive Search

Searching with regular expression is case-sensitive by default -- just like:

```js
db.movies.find(
    {title: {$regex: 'the', $options: 'i'}}
)
// or just:
db.movies.find(
    {title: {$regex: /the/i}}
)
```

#### Query Arrays and Nested Documents -- 

Querying over an array is just similar to querying any other field. Imagine the user wants to serach for movies with actors .. using the `$and`operator.

```js
db.movies.find(
    {$and: [
            {cast: 'Charles Chaplin'},
            {cast: {$regex: /Paulette/i}}
        ]}
)
```

Can conclude that when an array field is queried using a value, all those documents are returned where the array field contains at least one element that satisfies the query.

#### Finding an Array by an Array -- 

Similarly, array fields can also be searched using array values. When sarch an array field using an array value, the elements and their order must match. Fore, the document in the `movies`collection have an array to indicate how many languages the movies  is available. Like:

```js
db.movies.find(
    {languages: ['English', 'Spanish']},
    {languages: 1}
)
```

The output shows that when serach by using an array, the value is matched exactly. And when changing the order of the elements in the array, different records have been matched. When array fields are searched using an array value, the value is matched using an equality check. Any two arrays only pass the equality check if they have the same elements in the same order.

##### Searching an array with the `$all`operator

The `$all`operator finds all those documents where the value of the field contains all the elements, irrespective of their order or size.

```js
db.movies.find(
    {languages: {$all: ['English', 'Spanish']}},
    {languages: 1}
)
```

The preceding query uses the `$all`to find all the movies available in the array.

## Go context

Sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the languages and a foundation of concurrent code in Go. A context carries a deadline, a cancellation signal, and other values across API boundaries.

- `time.Duration`from now
- `time.Time`

```go
type publisher interface {
    Publish(ctx context.Context, position flight.Position) error
}
```

Assume that the concrete imp calls a function to publish a message to a broker -- this func is *context aware* meaning it can cancel a request once the context is canceled. Assuming don’t rececive an existing context -- 

```go
type publishHandler struct {
    pub publisher
}

func (h publishHandler) publishPosition(position flight.Position) error {
    ctx, cancel := context.WithTimeout(context.Background(), 4* time.Second)
    defer cancel()
    return h.pub.Publish(ctx, position)
}
```

This code just creates a context using the `context.WithTimeout`function. This function accepts a timeout and a context. Create one from an empty contxt with `context.Background()`.

Should use `context.Background()`as the *root context* for your main function, initialization, or tests, and use the `context.TODO()`only when U are unsure which context to use or if the function’s requirements are not yet clear, and U intend to replace it later.

The `context.TODO()`also returns a non-nil, empty `Context`-- Identical to `context.Background()`. Difference is purely semantic. When to use `TODO`-- as placeholder. And as a Flag. In the production code, you should ideally replace all instances of `context.TODO()`before code is considered complete.

#### Cancellation signals

Another use case for Go context is to carray a cancellation signal -- Fore, `CreateFileWatcher(ctx context.Context, filename string)`-- creates a specific file watcher and keeps reading from a file and catches updates - when the provided context expires or is canceled, this func handles it to close the descriptor.

```go
func main() {
    ctx, cancel := context.WithCancel(context.Backgound())
    defer cancel()
    go func() {
        CreateFileWatcher(ctx, "foo.txt")
    }()
}
```

For this when `main`returns, it calls the `cancel()`to cancel the context passed to `CreateFileWather`.

#### Context Values

```go
ctx := context.WithValue(parentCtx, "key", "value")
```

`context.WithValue`is created from a parent context -- in this case, create a new `ctx`context containing the same characteristics as `parentCtx`but also conveying a key and a vlaue.

```go
ctx := context.WithValue(context.Background(), "key", "value")
fmt.Println(ctx.Value("key")) // value
```

Note that the `key`and `value`provided are `any`types -- Leading some collisions -- two functions from different packages could use the same string value as a key. Just like:

```go
package provider
type key string
const myCustomKey key= "key"
func f(ctx context.Context) {
    ctx = context.WithValue(ctx, myCustomKey, "foo")
}
```

So the `myCustomKey`constant is unexported -- here is no risk that another package using the same context could override the value that is already set.

Another example is if we want to implement an HTTP middleware -- 

```go
type key string
const isValidHostKey key = "isValidHost"
func checkValid(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
        validHost := r.Host == "acme"
        ctx := context.WithValue(r.Context(), isValidHostKey, validHost)
        next.ServeHTTP(w, r.WithContext(ctx)) // WithContext used
    })
}
```

For this, first, define a specific context key called `isValidHostKey`-- then the `checkValid`middleware checks whether the source host is valid. This information is conveyed in a new context, passed to the next HTTP setup.

#### Catching a context cancellation

The `context.Context`type exports a `Done()`method that returns a *receive-only* notification channel. `<-chan struct{}`. This channel is closed when the work associted with the context should be canceled. Fore:

- The `Done`channel related to a context created with the `context.WithCancel`is closed when the `cancel()` is called.
- The `Done`related to a context created with `context.WithDeadline`is closed when the deadline has expired.

One thing to note that the internal channel should be closed when a context is canceled or has met a deadline, instead of when it receives a specific value, cuz the closure of a channel is the only channel action that all the consumer goroutines will receive. This way, all the consumers will be noticed once a context is canceled or a deadline is reached. Furthermore, `context.Context`reports an `Err()`method that returns `nil`if the `Done()`isn’t yet closed. otherwise, it returns a non-nil error explaining why the `Done`channel was closed -- 

- `context.Canceled`if the channel was canceled
- `context.DeadlineExceeded`if the context’s deadline passed.

```go
func handler(ctx context.Context, ch chan Message) error {
    for {
        select {
        case msg := <-ch:
            // sth with msg
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

For this, create a `for`and use `select`with two cases.

### Propagating an inappropratie context

Contexts are omnipresent when working with concurrency in Go, and in many situations, it may be recommended to propagate them. However, context propagation can sometimes lead to subtle bugs, preventing subfunctions from being correctly executed.

Fore, expose an HTTP handler that performs some tasks and returns a response -- Just before returning the resp, also want to send it a Kafka topic -- don’t want to penalize the HTTP consumer latency-wise, so want the publish action to be handled async within a new goroutine. Assume that have at our disposial a `publish`function that accepts a context so the actoin of publishing message can be interrupted if the context is canceled fore -- 

```go
func handler(w http.ResponseWriter, r *http.Request) {
    resp, err := doSomeTask(r.Context(), r)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    go func() {
        err := publish(r.Context(), resp)
        // do sth with err
    }()
    writeResponse(resp)
}
```

When calling `publis()`-- propagate the context attached to the HTTP request. For this, have to know that the context attached to an HTTP request can cancel in different conditions -- 

- When the client’s connection closes
- In the case of an HTTP/2 request, when request is canceled.
- When the resp has been written back to the client.

And for the last -- when the resp has been written to the client, the context associated with the request will be canceled. Facing a *race condition* -- 

- If the resp is written after the Kafka publication, both return a resp and publish a message successfully.
- If the resp is written before during the kafka, the message shouldn’t be published.

For this, can:

`err := publish(context.Background(), resp)`

But, for this, if the context contained just useful values -- Ideally, would like to have a *new context* that is detached from the potential parent cancellation but still conveys the values. Hence, a possible solution is to implement our own Go context similar to the context provided -- In the stdlib:

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key any) any
}
```

So, the context’s deadline is managed by the `Deadline()`and the cancellation signal is managed via the `Done()`and `Err()`methods. When a deadline has passed or the context has been canceled, `Done`should return a closed channel, whereas `Err`should returns an error -- Finally, the values are carried via the `Value()`. So can create a custom context and detaches the cancellation signal from a parent -- 

```go
type detach struct {
    ctx context.Context
}
func (d detach) Deadline() (time.Time, bool) {
    return time.Time{}, false
}
func (d detach) Done() <-chan struct{} {
    return nil
}
func (d detach) Err() error {
    return nil
}
func (d detach) Value(key any) any {
    return d.ctx.Value(key)
}
```

For this use case, except for `Value()`method that calls the parent context to retreive a value, the other methods returns a default value so the contxt is never considered expired or canceled.

`err := publish(detach{ctx: r.Context()}, resp)`

Now the context passed to `publish`will never expire or be canceled.

### Concurrent programming with CSP -- 

CSP for *communicating sequential processes* -- formal language used to describe concurrent systems. Instead of using memory sharing, it is based on message passing via channels. In CSP processes communicate with each other by exchaning copies of values. 

The key difference when using the CSP model is that executions are not sharing memory. Intead, they pass copies of data to each other. Go implements this model with the use of goroutines and channels -- just like in the CSP model, Go’s channels are sync and unbuffered by default.

#### Quitting Channels

The first pattern will examine is having a common channel that instructs goroutines to stop processing messages. Saw how can use Go’s `close(channel)`call to notify a goroutine that no more messages are coming. Should we terminate execution when we receive the first `close()`call or when all the channels are closed -- 

To use a `quit`channel together with the `select`statement -- 

```go
func printNumbers(numbers <-chan int, quit chan struct{}) {
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-numbers)
		}
		close(quit)
	}()
}
```

Then, have the `main()`creating the numbers and `quit`channels and calling the `printNumbers()`.

```go
func main() {
	numbers := make(chan int)
	quit := make(chan struct{})
	printNumbers(numbers, quit)
	next := 0
	for i := 1; ; i++ {
		next += i
		select {
		case numbers <- next:
		case <-quit:
			fmt.Println("Quitting number generation")
			return
		}
	}
}
```

##### Piplining with channels and goroutines

The first step in app is to generate URLs of web pages that we can download later -- can have a goroutine generate several URLs and send them on a channel to be consumed. Fore, imp of the `generteUrls()`func, which creates a goroutine that generates URL strings on an output channel. The output channel is retuend by the function, the function also accepts a quit channel, which it listens to in case it needs to stop generating URLs earlier.

```go
func generateUrls(quit <-chan struct{}) <-chan string {
	urls := make(chan string)
	go func() {
		defer close(urls)
		for i := 100; i <= 130; i++ {
			url := fmt.Sprintf("https://https://rfc-editor.org/rfc/rfc%d.txt", i)
			select {
			case urls <- url:
			case <-quit:
				return
			}
		}
	}()
	return urls
}
```

Next, complete this simple app by writing the `main()`-- just like:

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	for result := range urls {
		fmt.Println(result)
	}
}
```

Then write the logic to download the contents of these pages -- for this -- just need a goroutine that accepts a stream of URLs and ouputs the text contents into another output stream -- This goroutine can be plugged into the output of the `generateUrls()`goroutine and the input of the `main()`like -- Shows an imp of the `downloadPages`function.

```go
func downloadPages(quit <-chan struct{}, urls <-chan string) <-chan string {
	pages := make(chan string)
	go func() {
		defer close(pages)
		moreData, url := true, ""
		for moreData {
			select {
                // update the url and moreData variables
			case url, moreData = <-urls:
				if moreData {
					resp, _ := http.Get(url)
					if resp.StatusCode != 200 {
						panic("Server returning error code:" + resp.Status)
					}
					body, _ := io.ReadAll(resp.Body)
					pages <- string(body)
					resp.Body.Close()
				}
			case <-quit:
				return
			}
		}
	}()
	return pages
}
```

Can now connect this new goroutine to our pipeline easily since it accepts the same channel datatypes as the output of the `generateUrls()`function -- also returns the same outptu channel datatype as the one that our `main()`can use.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	results := downloadPages(quit, generateUrls(quit))
	for result := range results {
		fmt.Println(result)
	}
}
```

Again, can modify our `main()`to include this new goroutine in our pipeline -- each function in the pipeline is a goroutine that takes a `quit`channel and an input channel and returns an output channel. When run the `main()`, get the text from the web pages and are printed on the console. Following this pattern of accepting the input channel as a function input parameter and returning the output channel makes building pipelines easy.