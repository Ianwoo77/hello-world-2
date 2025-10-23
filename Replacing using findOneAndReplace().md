# Replacing using `findOneAndReplace()`

The `findOneAndReplace()`to perform the same operations -- it provides more options -- 

- If more than one document is found matching the query, the first one will be replaced
- Also a `sort`option can be used to influence which document gets replaced if more than one document is matched.
- If the `{returnNewDocument: true}` is set, the newly added document will be returned
- Field projection can be used to include only speicifc fields in the document returned in response.

```js
db.new_movies.insertMany([
    { "_id": 1011, "title" : "Macbeth" },
    { "_id": 1513, "title" : "Macbeth" },
    { "_id": 1651, "title" : "Macbeth" },
    { "_id": 1819, "title" : "Macbeth" },
    { "_id": 2117, "title" : "Macbeth" }
])
```

All have the same `title`, were released and inserted in different calendar years, when these records were originally inserted, the field for the year of release wan’t added. As a result, to find the latest movie with this `title`, need to use the incremental `_id`field, where the movie with the largest `_id`value is the lastest one. Fore:

```js
db.new_movies.findOneAndReplace(
    {'title': 'Macbeth'},
    {'title': 'Macbeth', 'latest': true},
    {sort: {'_id': -1}, projection: { title: 1, latest: 1}}
)
```

And Uf you are required to get the updated document int he resp, can make use of the `returnNewDocument`flag in the command -- setting this flag to `true`will return the replaced document from the collection like:

#### Replace vs. Delete and Re-Insert

As have seen in the previoues sections, there are dedicated functions to find and replace documents in a collection -- it is also possible to replace a document using a combination of delete and insert. To perform the two-step, replace op using delete and `insert`, use the same example -- in the `findOneAndReplace()`section -- 

```js
db.new_movies.deleteMany({})
db.new_movies.find()
```

```js
const deletedDocument = db.new_movies.findOneAndDelete(
    {title: 'Macbeth'},
    {sort: {_id: -1}}
)
deletedDocument
db.new_movies.insertOne({_id: deletedDocument._id, title:'Macbeth', latest:true} )
db.new_movies.deleteMany({latest:true})
db.new_movies.find()
```

## Using mutexes accurately with slices and maps

while working in concurrent contexts where data is both mutable and shared, often have to implement protected accesses around data structures using mtexes - a common mistake to use mutexes inaccurately when working with slices and maps. Fore, implement a `Cache`struct used to handle caching for customer balances -- 

```go
type Cache struct {
    mu sync.RWMutex
    balance map[string]float64
}
```

Add an `AddBalance`method that mutates the `balance`map -- the mutation is done in a critical section like:

```go
func (c *Cache) AddBalance(id string, balance float64) {
    c.mu.Lock()
    c.blances[id]= balance
    c.mu.Unlock()
}
```

Meanwhile, have to implement a methd to calculate the average balance for all the customers -- one idea is to hande a minimal critical section in this way -- 

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    balances := c.balances
    c.mu.Runlock()
    sum :=0
    for _, balance := ange balances {
        sum += balance
    }
    return sum/float64(len(balances))
}
```

For this, if run a tes tuing the `-race`flag with two concurent goroutines, one calling `AddBalance`and aother call `AverageBalance`-- data race occurs -  Intally, a map is a `runtime.hmap`struct containing mostly metadata and a pointer referencing data buckets -- so, `balances := c.balances`doesn’t copy the actual data, it’s the same principle with a slice -- like:

```go
s1 := []int{1,2,3}
s2 := s1
s2[0]=42
fmt.Println(s1) // [42, 2, 3]
```

The reason is that s2 := s1 creates a new slice `s2`has the same length and the same capacity and backed by the same array as `s1`. Meanwhile, the two goroutines perform operations on the same data set, and one of them mutates, hence, it’s a data race. So just like:

```go
func (c *Cache) AverageBalance() float64 {
    c.mu.RLock()
    defer c.mu.RUnlock()
    sum := 0
    //...
}
```

### Using `sync.WaitGroup`

`sync.WatiGroup`is a mechanism to wait for *n* operations to complete, generally, use it to wait for `n`goroutines to complete and first recall the public API, when will look at a pretty frequent mistake leading to non-deministric behavior --  `wg := sync.WaitGroup{}`

Internally, a `sync.WaitGroup`holds an internal cunter initialized by default to 0, we can increment this counter using the `Add(int)`method and decrement using the `Done()`or `Add()`with a negative value -- if want to wait for the counter to be equal to 0, have to use the `Wait()`method that is blocking. Fore;

```go
wg := sync.WaigGroup{}
var v uint64
for i:=0; i<3; i++ {
    go func() {
        wg.Add(1)
        atomic.AddUnit64(&v, 1)
        wg.Done()
    }()
}
wg.Wait()
fmt.Println(v)
```

For this, if run, will get a non-deterministic value -- the code can print any value from 0 to 3 -- And if enable the `-race`flag, Go will even catch a data race -- The problem here is that `wg.Add(1)`is just called within the newly created goroutine, not in the parent goroutine,  Hence, there is no guarantee that we have indicated to the wait group that we want to wait for 3 before calling `Wait()`. 

And, the CPU has to use a *memory fence* also called a memory barrier -- to ensure order. So just like:

```go
wg : = sync.WaitGroup{}
var v uint64
wg.Add(3)
for i:=0; i<3; i++ {
    go func() {
        //...
    }()
}
```

Or second, can all `wg.Add()`during each loop iteration before spinning up the child goroutines -- like:

```go
wg := sync.WaitGroup{}
var v uint64
for i:=0; i<3; i++ {
    wg.Add(1)
    go func() {
        //...
    }()
}
```

### Using `sync.Cond`

Among the sync primitivess in the `sync`, `sync.Cond`is least used and understood -- it just provides features that we can’t achieve with channels -- An app that raises alerts whenever specific goals are reached,  Fore, have one goroutine in charge of incrementing a balance, in contrast, other goroutines will receive updates and print a message whenever a specific goal is reached -- fore, one goroutine is waiting for a `$10`dontation goal -- whereas another is waiting for a $15 denoation goal -- 

```go
// usng mutexes
type Donation struct {
    mu sync.RwMutex
    blanace int
}
donation : = &Donation{}

// Listener gorotuines
f := func(goal int) {
    donation.mu.RLock()
    for donation.balance< goal {
        donation.mu.RUnlock()
        donation.mu.RLock()
    }
    fmt.Printf(..., donation.balance)
    donation.mu.RUnlock()
}

go f(10)
go f(15)

go func() {
    for {
        time.Sleep(time.Second)
        dotation.mu.Lock()
        dotation.balance++
        donation.mu.Unlock()
    }
}()
```

For this, the main issue - and what makes this a terrible imp -- is the busy loop -- each listener goroutine keeps looping until its donation goal is met.