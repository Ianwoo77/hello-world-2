# Projecting Array Elements

There are a few ways to limit how many elements of an array are retuend in the query output -- have practiced projecting fields in the resulting documents -- Using `$`-- can search an array by an element value and use projection to exclude all but the first matcing element of the array using the `$`operator.

```js
db.movies.find(
    {languages: 'Syriac'},
    {languages:1}
)
```

For this, although the query is intended to find Syriac-language movies, but the ouput contains other languages -- 

```js
// in the projection object
db.movies.find(
    {languages: 'Syriac'},
    {'languages.$':1}
)
```

So the `$`operator in Mdb projection is used to limit the contents of an array field in the output document to only the first element that matched the query condition. 

1. Query matching -- execues the query document
2. It identifies which array elements satisfy the query critera.

#### Projecting Matching elements by their index position - 

The `$slice`operator is used to limit the array elements based on index position.

```js
db.movies.find(
    {title: {$regex: /youth without youth/i}},
    {languages: {$slice:3}}
)
db.movies.find(
    {title: {$regex: /youth without youth/i}},
    {languages: {$slice:3}}
).toArray().map(doc=>doc.languages) // or use forEach
db.movies.find(
    {title: {$regex: /youth without youth/i}},
    {languages: {$slice:3}}
).forEach(doc=>console.log(doc.languages))
```

And the `$slice`operator can be used in few more ways, the following projectin expresion will return the last two elements of array -- like:

```js
db.movies.find(
    {title: {$regex: /youth without youth/i}},
    {languages: {$slice:-2}}
).forEach(doc=>console.log(doc.languages))
// can be passed with two element -- first - to be skipped, second numbers
db.movies.find(
    {title: {$regex: /youth without youth/i}},
    {languages: {$slice:[2, 4]}}
).forEach(doc=>console.log(doc.languages))
```

#### Querying Nesed Objects

Similar to arrays, nested or embedded objects can also be represented as values of a field. Hence, fields that have other objects as their values can be searched using the complete object as a value. Fore:

```json
"awards": {
    "wins": 1,
    "nominations":0,
    "text": "1 win."
}
```

The following query finds the `awards`object by providing the complete object as its value like:

```js
db.movies.find(
    {'awards': {wins:1, nominations:0, text: "1 win."}}
)
```

Note that when nested fields are searched with object values, there must be an exact match - this means that all the field-value pairs -- along with the order of the fields, must match exactly.

#### Querying Nested Object Fields

Saw that the fields of nested objects can be accessed using `.`notation -- Similarly, dot notation can be used to search nested objects by providing the values of its fields.

```js
db.movies.find(
    {"awards.wins": 4}
)
```

For this, refers to the nested field named `wins`. The nested filed search is performed independently on the given fields, irrespective of the order of the elements, can search by multiple fields and use any of the condition or logical query operators -- 

```js
db.movies.find(
    {
        "awards.wins": {$gte: 5},
        "awards.nominations": 6
    },
    {awards:1}
)
```

##### Projecting Nested Object Fields

```cs
db.movies.find(
    {},
    {
        'awards.wins': 1,
        'awards.nominations': 1,
        _id:0
    }
)
```

#### Limiting, skipping, and sorting documents

`cursor`provides a function called `limit`-- accepts an integer and returns the same number of records. Just like:

```js
db.movies.find(
    {cast: 'Charles Chaplin'},
    {title:1, _id: 0}
).limit(3)
```

Note that setting the limit to 0 is equivalent to not setting any limit at all. If set to negative number -- Note that in Mongodb, a negative szie limit is considered equivalent to the limit of a positive number.

## Starting a goroutine knowing when to stop it

Gorotuines are easy and cheap to start, may not necessarily have a plan for when to stop a new goroutine, which can lead to leaks --  A goroutine starts with a minimum stack size of 2K, which can grow and shrink as needed. Memory-wise, a goroutine can also hold variable references allocated to the heap -- a goroutine can hold resource such as HTTP or dbs connections, open files, and network sockets.

Look at an example in which the point where the goroutine stops is unclear -- 

```go
ch := foo()
go func() {
    for v := range ch{
        //...
    }
}()
```

The created goroutine will exit when `ch`is closed. If the channel is never closed, it’s a leak -- Fore, design an app that needs to watch some external configuration -- 

```go
func main() {
    newWatcher()
}
type watcher struct{
    // some resources
}
func newWatcher() {
    w := watcher{}
    go w.Watch()
}
```

When call `newWatcher`-- creates a `watcher`struct and spins up a goroutine in charge of watching the configuration. And when `main`exits, the app is stopped, the resources created by `watcher`aren’t closed gracefully. One option could be to pass to a context -- 

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    
    newWatcher(ctx)
}

func newWatcher(ctx context.Context) {
    w := watcher{}
    go w.watch(ctx)
}
```

For this, propagate the context created to the `watch`method. When the context is canceled, the `watcher`should close its resources. 

And the problem is that we used signaling to convey that a goroutine had to be stopped, we didn’t block the parent until the resources had been closed.

```go
func main(){
    w := newWatcher()
    defer w.close()
    // run the app
}

func newWatcher() watcher{
    w := watcher{}
    go w.watch()
    return w
}
func (w watcher) close() {
    // close the resource
}
```

### Careful with goroutines and loop variables

Mishandling goroutines and loop variables is probably one of the most common mistakes made by Go developers when writing concurrent app. If:

```go
s := []int{1,2,3}
for _, i := range s {
    go func() {
        fmt.Print(i)
    }
}
```

However, the output of this code isn’t deterministic -- In this, create new goroutines from a closure. A closure is a function value that references variables from outside its body. Here the `i`-- have to know that when a closure goroutine is executed, it *doesn’t capture the values when the goroutine is created*. Instead, all the goroutines refer to the exact same variable. When runs, it prints `i`at the time `fmt.Print()`executed. Using another variable -- 

```go
for _, i := range s {
    val := i
    go func() {
        fmt.Print(val)
    }()
}
```

In each iteration, create a new local `val`varaible, this captures the current value of `i`before the goroutine is created. The second is just no longer relies on a closure and instead uses an actual function -- 

```go
for _, i := range s {
    go func(val int) {
       //... 
    }(i)
}
```

Still execute anonymous function wthin a new goroutine, but this time isn’t a closure any more. So, have to be cautious with goroutines and loop variables.

### Don’t expect deterministic behavior using `select`and Channels

One common mistake made by Go developers while working with channels is to make wrong assumption about how `select`behaves with mutliple channels --  Imagine that we want to implement a goroutine that needs to receive from two channels -- 

- `messageCh`for new messages to be processed
- `disconnectCh`to receive notifications conveying disconnections.

Of these two channels, we want to prioitize `messageCh`-- if a disconnection occurs, want to ensure that have received all the messages before returning -- 

```go
for {
    select {
    case v := <-messageCh:
        fmt.Println(v)
    case <-disconnectCh:
        fmt.Println("disconection, return")
        return
    }
}
```

Used `select`to receive from multiple channels -- cuz want to prioritize `messageCh`-- might assume that should write the `messageCh`case first and the `disconnectCh`case next.

```go
for i:=0; i<10; i++ {
    messageCh <- i
}
disconnectCh <- struct{}{}
```

For this, instead of consuming the 10 messages, only received 5 of them. What is the -- it lies in the specification of the `select`statement with multiple channels.

If one or more of the communication can proceed, a single one that can proceed is chosen via a uniform pseudo-random selection. 

Unlike a `switch`statement, where the first case with a match wins, the `select`statement selects randomly if multiple options are possible. This behavior might look odd at first -- there is a good reason for it, to prevent possible starvation -- suppose the first possible communication chosen is based on the source order. Even though `case v:= <-messageCh`is first in source order -- if there is a message in both `messageCh`and `disconnectCh`-- 

If there is a single producer goroutine, have two options -- 

- Make `messageCh`an unbuffered channel instead of a buffered channel.
- Use a single channel instead of two channels.

If fall into the case where we have multiple producer goroutines, may be impossible to guarantee which one writes first. Hence, whether we have an unbuffered `messageCh`-- 

1. Receiving from either `messageCh`or `disconnectCh`.
2. Then return

```go
for {
    select {
    case v:= <-messageCh:
        fmt.Println(v)
    case <-disconnectCh:
        for{
            select {
            case v:= <-messageCh:
                fmt.Println(v)
            default:
                fmt.Println("disconnection, return")
                return
            }
        }
    }
}
```

For this, the solution uses an inner `for/select`with two cases, one on `messageCh`and a `default`case. Using `default`in a `select`statement is chosen only if none of the other case match.

For the first case, if `messageCh`is *unbuffered*, the loop will block until the receiver is ready -- but in this case, you are sending all messags before the loop starts receiving, so it must be buffered or the program would deadlock. If unbuffered, the loop will block until the receiver is ready.

Updated code is better than the previous version in terms of handling the disconnect signal and draining the `messagech`. The use of the default in the inner `select`ensures that you exit once `messageCh`is emtpy, avoiding a potential deadlock.

Then complete the `extractWords()`function -- same pattern as for `downloadPages()`used.

```go
func extractWords(quit <-chan struct{}, pages <-chan string) <-chan string {
	words := make(chan string)
	go func() {
		defer close(words)
		wordRegex := regexp.MustCompile(`[a-zA-Z]+`)
		moreData, pg := true, ""
		for moreData {
			select {
			case pg, moreData = <-pages:
				if moreData {
					for _, w := range wordRegex.FindAllString(pg, -1) {
						words <- strings.ToLower(w)
					}
				}
			case <-quit:
				return
			}
		}
	}()
	return words
}
```

Again, can modify the `main()`func to include this new goroutine in our pipeline -- each function in this pipeline is a goroutine that takes the `quit`channel and an input channel and returns an output channel that results are sent to.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	results := extractWords(quit, downloadPages(quit, generateUrls(quit)))
	for result := range results {
		fmt.Println(result)
	}
}
```

This pipeline pattern gives us the ability to easily plug executions together. Each execution is represented by a function that starts a goroutine accepting input channels as arguments and returning the output channels as return values. When returning the web pages are downloaded sequentially.

#### Fanning in and out

In the app, wane to speed things up -- can perform the downloads concurrently by load-balancing the URLs to multiple goroutins -- can create a fixed number of goroutines, each reading from the same URL input channel. Each one of the goroutines will receive a separate URL from the `generateUrls()` goroutine, and they can perform the downloads concurrently.

In Go -- a fan-out concurrency pattern when multiple goroutines read from the same channel, can distribute the work among a set of goroutines. 

Can fan out URLs to multiple `downloadPage()`goroutines, each doing a different download. In this example, the concurrent goroutines are load-balancing the URLs. Since concurrent processing is non-deterministic, some messages will be processed quicker than others.