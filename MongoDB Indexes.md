# MongoDB Indexes

Indexes enable U to perform queries efficiently -- An important part of applicaiton development and are even rquired for certain types of queries -- 

### Introduction to Indexes

A dbs index is similar to a book’s index -- The dbs takes a shortcut and just looks at an ordered list with references to the content. This allows MongoDB to query orders of magnitude faster.

A query that does not use an index is called a *collection scan* -- Fore:

```js
for (i=0; i<1000000; i++) {
    db.users.insertOne(
    	{'i': i, 'username': 'user'+i, 'age': Math.floor(Math.random()*123),
        'created': new Date()}
    )
}
```

Can use the `explain`command to see what MDB is doing when it executes the query. To enable MDB queries efficiently, all query patterns in you app should be supported by an index. Like:

```js
db.users.createIndex({'username': 1})
```

#### Introduction to Compund Indexes

The purpose of an index is to make your queries as efficient as possible. For many query pattern it is necessary to build indexes based on two or more keys -- fore, an index keeps all of its values in a sorted order.

```js
db.users.find().sort({'age':1, 'username':1})
```

This sorts by `age`then by `username`, for this a strict sorting by `username`isn’t terribly helpful -- An index can only help with sorting if it is a prefix of the sort. To optimize this sort, could make an index on `age`and `username.`

```js
db.users.createIndex({'age':1, 'username': 1})
```

Then suppose have a *user* collection that looks sth like this, if run a query with no sorting. like:

```js
db.users.find({}, {'_id':0, 'i':0, 'creted':0})
```

Then if index collection by `{‘age’:1, ‘username’:1}`, the index will have a form we represent like;

`[0, ‘username10020’]->8623` Each index entry contains an age an a username and points to a record identifier. And each index entry contains an age and a username and points to a record identifier -- A record identifier is used internally by the storage engine to locate the data for a document.

The way MongoDB uses this index depends on the type of query U are doing -- there are 3 most common ways:

```js
db.users.find({'age':21}).sort({'username': -1})
db.users.find({'age': {$gte: 21, $lte: 30}})
```

This is a range query, looks for documents matching multiple values, MongoDB will use the first key in the index, to return the matching documents.

```js
db.users.find({"age": {$get:21, $lte:30}}).sort({'username': 1})
```

This means that need to sort the results in memory before returning them, rather than simply traversing an index in whcih the documents are alreayd sorted in the desired order. One other index can use the last exmample is the same keys in reverse order.

How MongoDB selects an index -- When a query comes in, Mdb looks at the query’s *shape*, the shape has to do with what fields are being searched on and additional information -- the system identifier a set of candidate indexes that it might able to use in satisfiying the query.

For this, will use a student dataset containing approximately 1M records. Fore:

```json
{
    "_id": ObjectId("..."),
    "student_id": 0,
    "scores": [
        {
            "type": "exam",
            "score": 38
        },
        {
            //...
        },
    ],
    "class_id": 127
}
```

For this, will begin with 2 indexes and look at how MongoDB uses these indexes like:

```js
db.students.createIndex({'class_id': 1})
db.students.createIndex({'student_id':1, class_id: 1})
```

In working with this dataset, we will consider the following query, cuz it illustrates several of issues that we have to think about in disigning our indexes like:

```js
db.students.find({'student_id': {$g5:50000}, class_id:54})
	.sort({student_id:1}).explain('executionStats')
```

### Choosing Key directions

All our index entries have been sorted in ascending -- To optmizie compound sorts in different directions, need to use an index with matching directions, -- could use `{age:1, username:1}`

fore, if we have an index that looks like `{‘a’: 1, ‘b’:1}`, effcitively have indexes on `{a:1}`, and so on.

## `sync.Cond`

`sync.Cond`is propably the least used and understood -- it just provides features that can’t acheive with channels. like: An application that raises alerts whenever specific goals are reached. fore:

```go
func main() {
	donation := &Donation{}
	// listen goroutines
	f := func(goal int) {
		donation.mu.RLock()
		for donation.balance < goal {
			donation.mu.RUnlock()
			donation.mu.Lock()
		}
		fmt.Printf("$%d goal reached\n", donation.balance)
		donation.mu.RUnlock()
	}
	go f(10)
	go f(15)

	// update goroutine
	go func() {
		for {
			time.Sleep(time.Second)
			donation.mu.Lock()
			donation.balance += 1
			donation.mu.Unlock()
		}
	}()
}

```

We protect the accesses to the shared `donation.balance`variable using the mutex -- The main issue and what makes this a terrible imp -- is the *busy loop* -- each listener goroutine keeps looping until its denotation goal is met, which wastes a lot of CPU cycles and make the usage gigantic.

Using channels-- 

```go
func main() {
	donation := &Donation{ch: make(chan int)}
	// listener goroutines
	f := func(goal int) {
		for balance := range donation.ch {
			if balance >= goal {
				fmt.Printf("Goal reached: %d\n", goal)
				return
			}
		}
	}
	go f(10)
	go f(15)

	for {
		time.Sleep(time.Second)
		donation.balance++
		donation.ch <- donation.balance
	}
}

```

For this, each listener goroutine receives from a shared channel -- meanwhile, the updater goroutine sends messages whenever the balance is updated. The default distribution mode with multiple goroutines receiving from a shared channel is round-robin -- can change if one goroutine isn’t ready to receive messages -- in that case, Go distributes the message to the next available goroutine.

And there is another issue with using channels in this situation -- the listener goroutines return whenever their donation goal is met. Hence, the updater goroutine has to know when all the listeners stop receiving messages to the channel. And-- 

#### Ranging over a non-closed channel -- a potential Deadlock

When use a `range`loop on a channel, it will continue to receive values from the channle until the channel is just closed -- if the channel is never closed, the `range`will block idefinitely.

So need to find a way to repeatedly broadcast notification whenever the banalce is updated to multiple goroutine -- `sync.Cond`-- *Cond imp* implements a condition variable, a rendezvous point for goroutines waiting for announcing the occurrence of an event -- is a container of threads -- waiting for certain condition. Furthermore, reileas a `sync.Locker` just like:

```go
type Donation struct {
    cond *sync.Cond
    balance int
}
func main() {
	donation := &Donation{
		cond: sync.NewCond(&sync.Mutex{}),
	}

	f := func(goal int) {
		donation.cond.L.Lock()
		for donation.balance < goal {
            donation.cond.Wait()
        }
		fmt.Printf("%d$ goal reached\n", donation.balance)
		donation.cond.L.Unlock()
	}
	go f(10)
	go f(15)

	for {
		time.Sleep(time.Second)
		donation.cond.L.Lock()
		donation.balance++
		donation.cond.L.Unlock()
		donation.cond.Broadcast() // broadcasts the fact that a cond is met
	}
}
```

The call to `Wait`must happen within a critical section, which may odd -- Won’t the lock pervent other goroutines from waiting for the same condition -- 

1. Unlock the mutex
2. suppend the goroutine, and wait for a notification
3. lock the mutex when the notification arrives.

So the listener goroutine have two critical sections -- 

- When accessing `donation.balance`in `for donation.blancee<goal`
- when accessing `donation.blance`in the `fmt.Printf`

The balance update is done within a CS to prevent data races. Then call the `Boradcast()`which wakes all the goroutine waiting on the condition each time the balance is upated.

Also need to note one possible drawback when using `sync.Cond`-- when send a notificaiton, fore, to a `chan struct`-- Using `sync.Cond`with `Broadcast()`wakes all goroutines currently waiting on the condition. note that if here are none, the notification will be *missed*.

What happens -- if a goroutine calls `Signal()`or `Broadcast()`-- and there is no exuection waiting for it. Will be missed. So to ensure that we don’t miss any signals and broadcasts, need to use them in conjunction with mutexes. 

```go
func doWork(cond *sync.Cond) {
    fmt.Println("work started")
    fmt.Println("work finished")
    cond.L.Lock()
    cond.Signal()
    cond.L.Unlock()
}
```

TIP -- always use `Signal(), Broadcast(), Wait()`when holding the mutex lock to avoid sync problems.

## Delete a Movie

In this add our final CRUD endpoint so that a client can *delete* a specific movie from the system.
`DELETE /v1/movies/:id`-- 

- If `id`provided in the URL exists in the dbs, want to delete the corresponding record
- if doesn’t, 404 returned.

#### Adding a new endpoint

```go
// internal/data/movies.go
func (m MovieModel) Delete(id int64) error {
    if id < 1 {
        return ErrRecordNotFound
    }
    query = `Delete from movies where id = $1`
    result, err := m.DB.Exec(query, id)
    if err != nil {
        return err
    }
    rowsAffected, err := result.RowsAffected()
    if err != nil {
        return err
    }
    if rowsAffected==0 {
        return ErrRecordNotFound
    }
    return nil
}
```

Head back to the `cmd/api/movies.go`file and add a new `deleteMovieHandler`method -- call the `Delete()`that we just made, and based on the retrurned value from the `Delete`-- like:

```go
func (app *application) deleteMovieHandler(w http.ResponseWriter, r *http.Request) {
    id, err := app.readIDParam(r)
    if err != nil {
        app.notFoundResonse(w,r)
        return
    }
    
    // Delete the movie from the dbs sending a 404
    err = app.models.Movies.Delete(id)
    if err != nil {
        switch {
        case errors.Is(err, data.ErrRecordNotFound):
            app.notFoundResponse(w,r)
        default:
            app.serverErrorResponse(w, r, err)
        }
        return
    }
    
    // returns a 200
    err = app.writeJSON(w, http.StatusOK, envelope{"message": "movie successfully deleted"}, nil)
    if err != nil {
        app.serverErrorReponse(w, r, err)
    }
}
```

`router.HandlerFunc(http.MethodDelete, "/v1/movies/:id", app.deleteMovieHandler)`

### Advanced CRUD operations

In this going to look at a few advanced patterns that you might want to use for the CRUD endpoints that your API provides -- 

- How to support *partial* updates to a resource
- How to optimisitc concurrency control to vaoid conditions when two clients try to update the same resource at the same time
- How to use *context* timeouts to terminates long-running dbs queries and prevent unncessary resource use.

Handling partial updates -- In this going to change the behavior of the `updateMovieHandler`so that it supports *partial updates* of the movies records. Conceptualy this is a little more complicated then making a *complete replacement* -- As an example, say that we notice that the release year is wrong in dbs -- it would be nice if we could send a JSON request containing only the change that needs to be applied, instead of all the movie data. When decoding the request body any fields in `input`struct which don’t have a corresponding JSON k/v pair will retain their zero value, happen to check for these zero-values during validation and return the error messages.

In theory, we could change the fields in our `input`struct to be pointers. In the context of partial update this cuases a problem, -- tell the diference between -- 

- A client providing a k/v pair which has a zero-value 
- A client does not providing a k/v pair in ther JSON at all.

Could change the fields in our `input`struct to be pointers -- like:

```go
var input struct {
    Title *string `json:"title"`
    // likewise...
    Genres []string `json:"genres"` // don't need to change this cuz a slice already have zero-value
}
```

#### Performing the partial update

Put this into practice -- edit the method so it supports partial updates as follows like:

```go
// Use pointers for the Title, Year and Runtime fields
var input struct {
    Title   *string       `json:"title"`
    Year    *int32        `json:"year"`
    Runtime *data.Runtime `json:"runtime"`
    Genres  []string      `json:"genres"`
}
// if the input.Title is nil when we know no corresponding k/v pair was provided
if input.Title != nil {
    movie.Title= *input.Title
}

if input.Year != nil {
    movie.Year = *input.Year
}

if input.Runtime != nil {
    movie.Runtime = *input.Runtime
}

if input.Genres != nil{
    movie.Genres= input.Genres
}
```

To summarize this -- just have changed our `input`struct so that all the fields now have the zero-value `nil`-- afeter parsing the JSON request, then go through the `input`struct fields and only updates the movie record if the new value is not `nil`. In addition to this, for API endpoints perform *partial updates* -- it’s appropriate to the use the HTTP method `PATCH`rather than `PUT`.

Before a try, quickly quickly update our `cmd/api/routes`file sot that our `updateMovieHandler`is only used for `PATCH`requests. Just like:

`router.HandlerFunc(http.MethodPatch, "/v1/movies/:id", app.updateMovieHandler)`

#### Demonstration

With that set up -- check that this functionality works by correcting the release like: PATCH - `{“year” : 1985}`Can see that the `year`value has been correctly updated, and the `version`number has been incremented.

Null Values in JSON -- One special-case to be aware of is when the client explicitly supplies a field in the JSON request with the value `null`-- in this case, our handler will ignore the field and treat it like it hasn’t been supplied. like:

```json
{
    "title": null,
    "year": null
}
```

If do this, result in no changes to the movie record. In an ideal world this type of request would return some kind of validation error.

### Optimistic concurrency Control

Have noticed a small problem in our `updateMovieHandler`-- there is a RC if two clients to update the same movie record at exactly the same time -- To illustrate this -- pretend that we have two clients using our API -- now imagine that two customers send these two update requests at *exactly* the same time -- *Go’s `http.Server`handles each HTTPO requst in its own goroutine* -- so when this happens the code in our codebase will be runing concurrently in two different goroutines.

Despite making two separate updates, only Bob’s update will be reflected in the in the dbs at the end cuz the two goroutines were racing each other to make the change. Alice’s update to the movie runtime will be lost when Bob’s update overwirtes -- it with the old runtime value. And there is nothing to inform either Alice or Bob of the problem.

Preventing the data race -- there are a couple of options, but the simplest and cleanest approach in this case is to use a form of *optimisitc locking* based on the `version`number in the movie record.

Alice and Bob’s goroutines both call `app.models.Movie.Get()`to retrieve a copy of the movie record. Then make their respective changes -- Call the `Update()`with their copies of the movie record -- but the update is only executed if the verion number in the dbs is still `N`. if it has changed, we don’t exuecte the update and send the client an error message instead. This means that the first update that reaces our dbs will succeed, and whoever is making the second will receive an error message instead of having their change applied. like:

```sql
UPDATE movies
set Title = $1, -- ...
WHERE id = $5 and versin = $6
RETURNING version
```

