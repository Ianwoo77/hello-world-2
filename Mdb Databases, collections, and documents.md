# Mdb Databases, collections, and documents

Mdb structures data into a hierarchy consisting of 3 levels, have databases , inside databases and collections, which hold documents -- Documents contina different types od data.

#### Working with dynamic schema - 

Mdb’s dynamic schema approach approach offers a flexible way to store data, allowing the structure of documents within a collection to evolve -- unlike traditional REL dbs that requires predefined schmeas before data insertion,  Mdb adapts to data’s natural diversity.

- Queries on collections with heterogeneous document structures can be slower cuz Mdb has to scan a wider variety of document shapes, making indx use less efficient
- MDB allows for allows for schema validation at the collection lelve. If a collection contains various types of documents, applying comprehensive validation rules becomes complex or imporssible.
- Handling diverse document within a single collection comlicates app logic
- Aggregation pipelines that operate on collections with mixied document types can become unnecessarily complex.

So, to avoid these -- 

- Separate docuements by types. Just storing document with similar structures in the same collection.
- Consider the document structure carefully during the schmea design phase
- Use Mdb’s schema validation features at the collection level.
- Periodically review database schmea.

And, some dbs are created during the cluster creation process and are reserved for mdb’s internal use -- 

- `admin`-- the primary function of a admin dbs is to house system collections along with userr authentication and authorization info
- `local`-- Each instance of `mongod`-- The mdb server process, maintains a unique local dbs containing data essential for replication and other data specific to that instance
- `config`-- the `config`dbs is primarily used internally.

#### Working with collections

Collections are analogous to tables in REL dbs -- and if not exist, Mdb creates when U first store data for that collection. Also, offers the `db.createCollection()`for explicitly creating a colection with different options, such as capped or time-series, defiing the maximum size or document validation rules. Cannot -- 

- Start with the `system`prefix
- Contian the `null`character
- Contains the `$.`or be an empty string.

And, to display the colections from the dbs, use the command `show collections`-- and to display more detailed info about a collection, use the `db.getCollectionInfos()`fore -- 

```js
use sample_mflix
db.getCollectionNames()
```

And as an alternative, to display the collections from the dbs, use the command `show collections`.

```js
db.getCollectionInfos({name:'sessions'})
```

Note that htere is also a namespace, which is a combination of the databasename and the collection name, separated by a dot. like `sample_mflix.embedded_movies`

## About `sync.cond`

Among the sync primitive in the `sync`package, `sync.Cond`is probably the least used and understand -- however, it provides features that we can’t achieve with channels -- this section goes through a concrete example to show when `sync.Cond`can be helpful and how to use it --  Fore, implemens a donation goal mechanism -- an application that raises alerts whenever specific goals are reched -- fore:

```go
type Donation struct {
    mu sync.RWMutex
    balance int
}
donation := &Donation{}

f := func(goal int) {
    donation.mu.RLock()
    for donation.balance < goal {
        donation.mu.RUnlock()
        donation.mu.RLock()
    }
    fmt.Printf("$%d goal reached\n", donation.balance)
}
go f(10)
go f(15)

go func() {
    for{
        time.Sleep(time.Second)
        donation.mu.Lock()
        donation.balance++
        donation.mu.Unlock()
    }
}()
```

For this, the main issue and what makes this a terrible im -- is the busy loop - Each listener goroutine keeps looping until its donation goal is met --which wastes a lot of CPU cycles and makes the CPU uage gigantic. Fore:

```go
type Donation struct {
    balance int
    ch chan int
}

donation := &Dnoantion{ch: make(chan int)}

f := func(goal int) {
    for balance := range donation.ch {
        if balance >= goal {
            fmt.Printf(...)
            return
        }
    }
}
```

A message sent to a channel is received by only one goroutine, in the example, if the first goroutine receives from the channel before the second one -- shows what chould happen. For this, the default distribution mode with multiple goroutines receiving from a shared channel is round-robin.

Each message is received by a single goroutine -- therefore, the first goroutine didn’t receive in this exmple. It can change if one goroutine isn’t ready to receive messages -- in that case, Go distiributes the message to the next available goroutine -- each message is received by a single goroutine, therefore, the first goroutine didn’t receive the $10 message in this example.

There is anonther isue with suing channels in this situation. The listener goroutines return whenever their donation goal is met.

Ideally, need to find a way to repeatedly broadcast notifications whenever the balance is updated to multiple goroutines -- go has a socoutin -- `sync.Cond`-- -- Cond implements a condition variable, a rendezvous point for goroutine waiting for or annoncing the occurrence of an event. A dondition variable is a container of threds waiting for a certain condition -- the condistion is a balance update fore:

```go
type Donation struct {
    cond *sync.Cond
    balance int
}
donation := &Donation {
    cond: sync.NewCond(&sync.Mutex{}),
}

// Listener goroutines
f := func(goal int) {
    donation.cond.L.Lock()
    for donation.balance < goal {
        // lock the mutex when the notification arrives
        donation.cond.Wait()
    }
    fmt.Println(...)
    donation.cond.L.Unlock()
}
go f(10)
go f(15)
```

For this, create a *sync.Cond* using `sync.NewCond`and provide a `sync.Mutex`-- The listener goroutines loop until the donation blanace is met, within the loop, use the `Wait`methd that blocks until the conditions is met. Note that the call to `Wait()`must happen within a crtiical section, which may odd - Cuz, the imp of `Wait`is the following -- 

- Unlock the mutex
- Suspend the goruotine, and wait for a notification
- Lock the mutex when the notification arrives

```go
for {
    time.Sleep(time.Second)
    donation.cond.L.Lock()
    donation.blanace++
    donation.cond.L.Unlock()
    donation.cond.Broadcast()
}
```

In the imp, the condition viriable is based on the balance being updated. Therefore, the listener variables wake each time a new donotation is made, to check whehter their dontaion goal is met

Also note that one possible drawback when using `sync.Cond`-- when send a notification, fore, to a `chan struct`, the message id buffered, which guarantees that this notification will be received eventually.

### Condition vairables

Condition viriables give us extra functionlaity on top of mutexes -- can use them in situations where a goroutine needs to block and wait for a particular condition to occur. If have:

```go
func stingy(money *int, mutex *sync.Mutex) {
    for i:=0; i<100000; i++ {
        mutex.Lock()
        *money += 10
        mutex.Unlock()
    }
    //...
}

func spendy(money *int, mutex *sync.Mutex) {
    for i:=0; i<200000; i++ {
        mutex.Lock()
        *money -=50
        if *money <0 {
            fmt.Println("Money is negative")
            os.Exit(1)
        }
        mutex.Unlock
    }
    fmt.Println("done")
}
```

For this, is there anything we can do to stop the balance from going into the netative - ideally, we want a system that doesn’t spend money don’t have, can try to have the `spendy()`function check if there is enough before it goes ahead and spends it.

```go
func spendy(money *int, mutex *sync.Mutex) {
    for i:=0; i< 20000; i++ {
        mutex.Lock()
        for *money < 50 {
            mutex.Unlock()
            time.Sleep(10* time.Millisecond)
            mutex.Lock()
        }
        *money-=50
        if *money <0 {
            fmt.Println("...")
            os.Exit(1)
        }
        mutex.Unlock()
    }
    fmt.Printl("spendy done")
}
```

This solution will work for our usecase, but it’s not ideal, in the example, choose the arbitrary sleep value of 10 milliseconds, but what would be the optimal number to choose -- can choose not to sleep at all. This ends up *wasting* CPU resources, as the CPU would be cycling needlessly, checking the `money`variable iven if it doesn’t change.

This is where condition variables come in -- Condition variables work totegher with mutexes and give us the ability to suspend the current execution tuntil we have a singla that a particular condition has changed.

1. While holding a mutex, A checks for a particular condition on some shared state.
2. If cond is not met, A calls `Wait()`on the condition
3. The `Wait()`function performs two operations atomically -- 
   - Release the mutex
   - blocks the current execution, effectively putting the goroutine to sleep.
4. Since is now available, another acquires it to update the shared state
5. Aftering updating the shared state, B calls `Signal()`or `Broadcast()`on the condition vairaible.

```go
type Cond interface {
    func NewCond(l Locker) *Cond
    func (c *Cond) Broadcast()
    func (c *Cond) Signal()
    func (c *Cond) Wait()
}

type Locker interface {
    Lock()
    Unlock()
}
```

Changing the Stingy is simpler cuz only need to signal -- like:

```go
func strintgy(money *int, cond *sync.Cond) {
    for i:=0 ; i<100000; i++ {
        cond.L.Lock()
        *money+=10
        cond.Signal() // signals on the cond every time add to the shared money variable
        cond.L.Unlock()
    }
}

func spendy(money *int, cond *sync.Cond) {
    for i:=0; i<200000; i++ {
        cond.L.Lock()
        for *money < 50 {
            cond.Wait() // shen acquire, check for money's value
        }
        *money -=50
        if *money < 0 {
            //...
        }
        cond.L.Unlock()
    }
}
```

#### Missing the signal -- 

What happens if goroutine calls `Signal()`or `Broadcast()`and there is no execution waiting for. If there is no goroutine in a waiting state, the `Signal`or `Broadcast()`call will be missed.

NOTE -- we need to ensure that when we call the Signal or broadcast function, there is antoher goroutine waiting for it, othewise, the signal or broadcast is not receivced by any goroyutine. So need put it in the Lock and Unlock like:

```go
fund doWork(cond *sync.Cond) {
    fmt.Println("...")
    cond.L.Lock()
    cond.Signal()
    cond.L.Unlock()
}
```

So, always use `Signal()`, `Broadcast()`and `Wait()`when holding the mutex lock to avoid sync problems.