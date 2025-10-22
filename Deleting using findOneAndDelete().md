# Deleting using `findOneAndDelete()`

Apart from the two delete methods we saw previously, there is nother function named `findOneAndDelete()`, which, as the name indicates, finds and deletes one document from the collection. Although it behaves similarly to the `deleteOne()`-- it provides a few more options -- 

- It finds and document and deletes it
- If more than one document is found, only the *first one* will be deleted.
- Once deleted, it returns the deleted document as a response.
- In the case of mulitple document matches, the `sort`option can e used to influence with document gets deleted.
- Projection can be used to include or excludes fields from the document in response.

```js
db.new_movies.insertMany([
    { "_id" : 11, "title" : "movie_11" },
    { "_id" : 12, "title" : "movie_12" },
    { "_id" : 13, "title" : "movie_13" },
    { "_id" : 14, "title" : "movie_14" },
    { "_id" : 15, "title" : "series_15" }
])

db.new_movies.findOneAndDelete(
    {title:{'$regex':'^movie'}},
    {sort: {'_id':-1}, projection:{_id:0, title:1}}
)
db.new_movies.find(
```

#### Deleting a low-rated Movie

Fore, ask to remove a movie with a high number of IMDB votes, a low averge rating, and the least awards won from the list of low-rated movies.

1. `deleteOne()`or `findOneAndDelete()`function and prepare a query filter using the IMDB rating and votes. Fore, the first condition is to find movies with less than  two-pint rating in IMDB -- like:
   (‘imdb.rating’: {$lt:2})

2. Just add a projection option to return only the `_id`and `title`filed of the deleted movie just like:

   ```js
   db.movies.findOneAndDelete(
       {'imdb.rating': {$lt: 2}, 'imdb.votes':{$gt: 50000}},
       {
           'sort': {'awards.won':1},
           'projection': {'title': 1}
       }
   )
   ```

As seen in the preceding ouput, the command was executed successfully, the document returned in the response correctly includes the `_id`and `title`of the deleted movie.

#### Replacing Documents

Learn how you can completely replace the document in the collection -- Simetimes U may want to replace an incorrectly inserted document in a collection, or consider that, often, the data sorted in document is changed over time. or to support your product’s new requirements.

```js
db.users.insertMany([
    {"_id": 2, "name": "Jon Snow", "email": "Jon.Snow@got.es"},
    {"_id": 3, "name": "Joffrey Baratheon", "email": "Joffrey.Baratheon@got.es"},
    {"_id": 5, "name": "Margaery Tyrell", "email": "Margaery.Tyrell@got.es"},
    {"_id": 6, "name": "Khal Drogo", "email": "Khal.Drogo@got.es"}
])
```

Can see that the command is successful, and 4 users are added -- before going any furhter, quick use the `find()`to ensure no other documents are present in the collection except for newly inserted ones.

``js

```js
db.users.replaceOne(
    {_id: 5},
    {name: "Margaery Bartheon", email: "bender@got.es"}
)

db.users.find({_id:5})
```

##### `_id`fields are Immutable

In the previous, will have noticed that there was no `_id`field in the replacement document -- think Mdb must have added and autognerated a PK -- `_id`fields are just immutable in Mdb -- immutable fields are like normal fileds, however, once assigned with a value, their value cannot be changed again.

#### Upsert using replace

In the previous -- learned that can find an existing document in a collection and replace it with a new document -- however, there iwll be times U want to replace an existing document with a new document - however, there will be times u want to replace an existing with a new one and if document *does not* already exist, insert the new document -- this operation is called an update (if found) or insert (if not found).

In readl-world scenarios, will mostly be doing these operations in large nubmers -- fore, system receives daily updates from a user server, where the server sends U all the documents that were modified during the day -- these daily updates might include records of the new users signed up with the server as well as changes to the existing user’s profiles. Fore:

```js
db.new_users.replaceOne(
    {name:'Margery Baratheon'},
    {name:'Margery Tyrell', 'email': 'Margery.tryell@got.es'}
)

db.new_users.find()

db.new_users.replaceOne(
    {'name': 'Tommen Baratheon'},
    {'name': 'Tommen Baratheon', 'email': 'Tommen.Bartheon@got.es'},
    {upsert: true}
)
```

## Being puzzled about channel size

When create a channel using the `make()`built-in function, the channel can be either unbuffered or buffered. Related to this, two mistakes happen fairly frequently: being confused about when to use one or the other, and if use a buffered channel, what size to use -- examine these points -- 

```go
ch1 := make(chan int)
ch2 := make(chan int, 0)
```

Using an unbuffered channel, the sender will block until the receiver recevies data from the channel -- conversely, a buffered channel has a capacity, and it must be created with a size greater than to equal to 1 -- like:

```go
ch3 := make(chan int, 1)
```

Wit a buffered channel, a sender can send messages while the channel isn’t full, once the channel is full, will block until a receiver goroutine recieves a message fore -- 

```go
ch3 := make(chan int, 1)
ch3 <- 1
ch3 <- 2 // blocking
```

Channels are just a concurency abstraction to enale communication among goroutines, but what about sync -- in concurrency, sync means we can guarantee that multiple goroutines will be in a known state at some pont, fore, a mutex provides sync cuz it ensures that only one goroutine can be in a critical section at the same time -- regarding channels -- 

- An unbuffered channel enables sync -- have the guarantee that two goroutines will be in a known state. One receiving and anothe sending a message.
- A buffered channel doesn’t provide any strong sync -- indeed, a producer goroutine can just send a message and then continue its execution if the channel isn’t full. The only guarantee is that goroutine won’t receive a message before it is sent.;

So, it’s essential to keep in mind this fundamental distinction -- both channel types enable communication, but only one provides sync -- if we need sync, we must use *unbuffered* channels, Unbuffered may also be easier to reason about -- buffered can lead to obscure deadlocks that would immediately apparent with unbuffered channels.

But, there are also other cases where unbuffered channels are preferable -- in the case of a notification channel where the notification is handled via channel closure (`close(ch)`), here, using a buffered one won’t bring any benefits.

But, what if we need a buffered one, -- namely, what size should we provide -- The default value should use for is its minimum 1 -- so we may approach the problem from this -- is there any good readon not to use a value of 1. here is a a list of possible cases where we should use another sie -- 

- While using a worker pool fore, spinning a fixed number of goroutines that need to send data to a shared channel
- When using channels for rate-limitinmg problems.

### Data races with `append`

Fore, will initialize a slice and create two goroutines that will use `append`to a new slice with an additional element -- 

```go
s := make([]int, 1)
go func() {
    s1 := append(s, 1)
    fmt.Println(s1)
}()
go func() {
    s2 := append(s, 1)
    fmt.Println(s2)
}()
```

Fore, a slice is backed by an array and has two properties, length and capacity -- the length is the number of available elements in the slice, whereas the capacity is the total number of elements in the backing array. when using `append`, the behavior depends on whether  the slice is full or not -- if it is, the Go runtime creates a new backing array to add the new element -- otherwise, the runtime adds it to the existing backing array.

For the `make([]int, 1)`-- the code creates a 1L and 1C slice -- cuz the slice is full, using `append`in each goroutine returns a slice backed by a new array. For this, it doesn’t mutate the existing array, hence, it doesn’t lead to a data race. But if:

```go
s := make([]int, 0, 1)
// same code
```

The answer is that there is a data race -  For this, we create a slice with `make([]int, 0, 1)`-- the array isn’t full, both goroutines attempt to update the same index of the backing array, which is a data race. And how can we prevent the data race if want both goroutines to work on a slice containing the initial elements of `s`plus an extra element -- 

```go
s := make([]int, 0, 1)
go func() {
    sCopy := make([]int, len(s), cap(s))
    copy(sCopy,s)
    s1 := append(sCopy, 1)
    fmt.Println(s1)
}()
// ...same code for s2
```

Both makes a copy of the slice, then they use `append`on the slice copy. While working with slices in concurrent contexts, must recall thatusing `append`on slice issn’t always reace-free,depending on the slice and whether it’s full the behavior will change. In general, shouldn’t have different imp depending on *whether the slice is full*.

## Fanning and out

If want to speed things up, can perfrom the downloads concurrently by load-balancing the URLs to multiple goroutines -- can create a fixed number of goroutines, ech reading from the same URL input channel - each on eo f the goroutines will recieve a sepaate URL from the `generateURLs()`goroutine -- and they can perform the downloads concurrrently.

DEF -- In Go, a *fan-out* concurrency pattern is when multiple goroutines read from the same cahnnel. Can fan out the URLs to multiple `downloadPage()`goroutines, each doing a different download, in this example, the concurrent goroutines are load-balancing the URLs snet from the `generateUrls()`goroutine, when a `downloadPage()`is free, will read the next URL from the shared input channel.

Also note that since concurrrent procesing is non-deterministic, some messages will be processed quicker than others, resulting in messages being processed in an *unpredictable* order. Fore:

```go
func main() {
    quit := make(chan struct{})
    defer close(quit)
    urls := generateUrls(quit) // note, urls is just a channel, 
    pages := make([]<-chan string, downloaders)
    for i:=0; i<downloades; i++ {
        pages[i]= downloadPages(quit, urls) // so can be uesd as 
    }
}
```

For this, the `fan-out`pattern in the app has created a problem -- the outputs of our download goroutines are in separate channels, how can we connect them to the single input channel of our next stage -- the `extractWords()`-- Just need a mechanism that merges the output messages from the different channels into a single output channel. This is what called the *fan-in* pattern -- 

DEF -- in Go, an *fan-in* concurrency pattern occurs when we merge the content from multiple channels into one. Also note that having multiple goroutines all feeding all into a single common channel creates a problem -- when have a one-to-one input-to-output channel -- the channel-closing strategy is simple -- but when have a many-to-one fan-in scenairo, must make a decision about when to close the common channel -- The solution is only close the common channel when all the goroutines have noticed that the channels from which they are consuming have been closed.

```go
func FanIn[K any](quit <-chan struct{}, allChannels ...<-chan K) chan K {
    wg := sync.WaitGroup{}
    wg.Add(len(allChannels))
    output := make(chan K)
    for _, c := range allChannels {
        go func(channel <-chan K) {
            defer wg.Done()
            for i:= range channel {
                select {
                case output <-i:
                case <-quit:
                    return
                }
            }
        }(c)
    }
    go func() {
        wg.Wait()
        close(output)
    }()
    return output
}
```

For this, the `wg.Wait()`call is placed in a separate gorotuine to prevent a deadlock and ensure the `FanIn`function returns immediately wihtout blocking the caller.

1. Preventing Deadlock - if `wg.Wait()`were called directly in the `main`FanIn() function -- The problem is tha tht goroutine reading from the input channels will only finish when their respective input channels are closed.
2. And the caller would therefore never start reading from the `output`channel
3. The worker goroutrines would eventually block indefinitiely trying to write to the unread output

For now, can connect our fan-in pattern to our app and include it in the pipeline -- modifies our `main()`include the `fanIn()`function from listing.

```go
func main() {
    //...
    pages := make([]<-chan string, downloaders)
    for i:=0; i<dlownloades; i++ {
        pages[i]= downloadPages(quit, urls)
    }
    results := extractWords(quit, FanIn(quit, pages...))
    for result := range results {
        fmt.Println(result)
    }
}
```

##### Flushing results on close

We haven’t really down everything interesting with the URL download app, apart from extracting the words, what if the downloaded web pages for sth useful -- how about trying to find the 10 longest words in the text documents -- 

This task is easy if we continue to follow our pipeline-building pattern, just need to add a new goroutine that accepts an input channel and returns an output one -- And the new `longestWords()`goroutine is just slightly different from the other goroutines we have developed in the pipeline -- it accumulates a set of unique words in its memeory.

```go
func longestWrods(quti <-chan int, words <-chan string) <-chan string {
    longWords := make(chan string)
    go func() {
        defer close(longWords)
        uniqueWordMap := make(map[string]bool)
        uniqueWords := make([]string,0)
        moreData, word := true, ""
        for moreData {
            select {
            case word, moreData = <-words:
                if moreDate && !uniqueWordsMap[word] {
                    uniqueWordsMap[word]= true
                    uniqueWords = append(uniqueWords, word)
                }
            case <-quit:
                return
            }
        }
        sort.Slice(uniqueWords, func(a, b int) bool {
            return len(uniqueWords[a] > len(uniqueWords[b]))
        })
        longWords <-strings.Join(uniqueWords[:10], ", ")
    }()
    return longWords
}
```

For this, can now connnect this new component to our pipeline in the `main()`function -- 

```go
func main()  {
    //...
    results := longestWords(quite,
                            extractWords(quit, FanIn(quit, pages...)))
}
```

#### Broadcasting to multiple gorotuines

What if we want to find out more stats from our download pages -- for this scenario, say that in addition to finding the longest words, want to find which words occur most frequently -- For this scenario, will feed the output of the `extractWords()`to two gorotuines -- the existing `longestWords()`and an additional one called `frequentWords()`-- the pattern of the new function will be the same as that of `longestWords()`-- will store the frequency of each unqiue word, and when the input channel closes, will outout the top 10 most often-occurring words.

For this, instead of fan-out, can use a broadcast-pattern -- one that replicates messages to a set of output channels, shows how we can use a separate goroutine that broadcasts to mutliple channels -- can connect the outputs of the broadcast to the inputs of both the `frequentWords()`and the `longestWords()`goroutines.
