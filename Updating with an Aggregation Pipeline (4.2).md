# Updating with an Aggregation Pipeline (4.2)

Add the following records to the collection like:

```js
db.users.insertMany([
    {_id: 1, full_name : "Arya Stark"},
    {_id: 2, full_name : "Khal Drogo"}
])

db.users1.updateMany(
    {},
    [
        {$set: {'name_array': {$split: ['$full_name', ' ']}}},
        {
            $set: {
                'first_name': {$arrayElemAt: ['$name_array', 0]},
                'last_name': {$arrayElemAt: ['$name_array', 1]}
            }
        },
        {$project: {
            'first_name':1,
                'last_name':1,
                'full_name':{
                $concat: [{$toUpper: '$first_name'}, ' ', '$last_name']
                }
            }}
    ]
)
db.users1.find()
```

Here the `updateMany()`operation is updating all the documents in the `users`collection -- the second argument to the func is an array containing stages -- `$set, $set, $project`.

### Updating Array Fields

To try some basic update operation on array fields, will insert the following document into the `movies`collection: Using the `findOneAndUpdate`method -- like:

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$set: {'genre':['Unknown']}},
    {returnNewDocument: true}
)
```

Fore, will remove the fields from the document -- like:

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$unset: {'genre':''}},
    {returnNewDocument: true}
)
```

The output indicates that the field is correctly removed from the document.

#### Adding elements to Arrays

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$push: {'genre': 'unknown'}},
    {returnNewDocument: true}
)
```

The update operation in the preceding snippet finds a document by its `_id`value and pushes an element to the `genre`array -- this field is currently absent in the document.

#### Adding multiple elements

`$push`can add one element at a time, to add multiple elements to an array in a single update command, have to use `$push`along with `$each`-- the following is the syntax for this:

`$push: {<field_name>: {$each: [<element1>]}}`just like:

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$push: {'genre': {$each: ['History', 'Action']}}},
    {returnNewDocument: true}
)
```

Sort -- Are an ordered but unsorted collection of elements -- like:

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$push: {'genre': {$each: [], $sort: 1}}},
    {returnNewDocument: true}
)
```

For this, just use `$push`in the `genre`-- one thing to note that is this query is not pushing any element to the array.

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$push: {'genre': {$each: ['Crime'], $sort: -1}}},
    {returnNewDocument: true}
)
```

Then for the array of object just like:

```js
db.items.insertOne({_id : 11, items: [
        {"name" : "backpack", "price" : 127.59, "quantity" : 3},
        {"name" : "notepad", "price" : 17.6, "quantity" : 4},
        {"name" : "binder", "price" : 18.17, "quantity" : 2},
        {"name" : "pens", "price" : 60.56, "quantity" : 3},
    ]})
```

For this the `itmes`field is an array of 4 objects, each containing 3 fields -- will sort the arry by price now like:

```js
db.items.findOneAndUpdate(
    {_id: 11},
    {$push: {'items': {$each: [], $sort: {price: -1}}}},
    {returnNewDocument: true}
)
```

So the update command finds one document and sorts the array field.

#### An Array as a set

An array is an ordered collection of elements that can be iterated over or accessed using its specific index position. A set is a collection of unique elements whose order is not guaranteed -- Mdb supports only plain arrays, can use `$addToset`operator -- like `$push`-- with the only difference being that an element will be pushed only if it is not present already.

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$addToSet: {'genre': 'Action'}},
    {returnNewDocument: true}
)
```

Here the update operation uses `$addToSet`to push an element of `Action`in the `genres`array. As can be seen in the preceding screenshort, the `Action`element was not pushed to the array cuz the array already contains it.

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$addToSet: {'genre': {$each: ['History', 'Thriller', 'Drama']}}},
    {returnNewDocument: true}
)

db.movies.updateMany(
    {
        'tomatoes.viewer.meter': {$gt: 95},
        'tomatoes.critic.meter': {$gt: 95}
    },
    {$addToSet: {'genre': 'Classic'}}
)

db.movies.find(
    {
        'tomatoes.viewer.meter': {$gt: 95},
        'tomatoes.critic.meter': {$gt: 95}
    },
    {'_id':0, title:1, genres:1}
)
```

### Removing Array Elements -- 

Removing the first **or** last element `$pop`-- when used in an update command, allow U to remove the first or last element in an array -- removes one element at a time and can only be used with the values 1 or -1.

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$pop: {'genre': 1}}, // remove the last element
    {returnNewDocument: true}
)
```

And the modified document indicates that the last element has been successuflly removed from the array.

#### Removing all elements -- 

When only need to remove certain elements from an array, can use the `$pullAll`operator -- to do so, provide one or more elements to the operator, which then removes all occurrences of those elements from the array.

```js
db.movies1.findOneAndUpdate(
    {_id: 111},
    {$pullAll: {'genre': ['Action', 'Crime']}}, // remove the last element
    {returnNewDocument: true}
)
```

In this update operation, use the `$pullAll`in the `genre`field, provides two `Action`and `Crime`.

Removing matched elements -- use the `$pullAll`to remove specific elements from an array.

```js
db.items.findOneAndUpdate(
    {_id: 11},
    {$pull: {'items': {quantity: 3, name: {$regex:/ck$/}}}},
    {returnNewDocument: true}
)
```

In this update command, the `pull`operator is provide with a query condition in the array field `items`-- the condition filter the array elements, where the `quantity`is 3 and the `name`ends with `ck`.

## Condition variables and Semaphores

Condition variables give us extra functionality on top of mutexes -- can use them in situation where a goroutine needs to block and wait for a particular condition to occur. Fore shows the modified `spendy()`function to show this scenario -- when the bank account goes netative, print a message and exit the program. Fore:

```go
func stringy(money *int, mutex *sync.Mutex) {
    for i:=0; i<1000000; i++ {
        mutex.Lock()
        *money+=10
        mutex.Unlock()
    }
    //...
}
// func spendy similar, but i:=0, i<200000; i++
func spendy(money *int, mutex sync.Mutex) {
    for i:=0; i<200000; i++ {
        mutex.Lock()
        *money-=50
        if *money<0 {
            fmt.Println("money is netative!")
            os.Exit(1)
        }
        mutex.Unlock()
    }
    fmt.Println("Spendy done")
}
```

So, it there anything can do to stop the balance from going into the netative -- ideally, we want a system that doesn’t spend money we don’t have. So for this, can try to have the `spendy()`function check if there is enough money before it goes ahead and spends it. like:

```go
func spendy(money *int, mutex *sync.Mutex) {
    for i:=0; i<20000; i++ {
        mutex.Lock()
        for *money<50 {
            mutex.Unlock()
            time.Speep(10*time.Millisecond)
            mutex.Lock()
        }
        *money -= 50
        if *money < 0 {
            //...
            os.Exit(1)
        }
        mutex.Unlock()
    }
    //...
}
```

For this, the solution will work for use case -- not ideal, in the example, choose the arbitrary sleep value of 10m -- At one extereme, can choose not to sleep at all. This ends up wasting CPU resources. This is where condition variables come in. Condition variables work together with mutexes and gives us the ability to suspend the current execution until we have a single that a particular condition has changed.

1. While holding a mutex, A checks for particular condition on some shared state. Fore, the condition would be *Is there enough money in shared bank account*.

2. if not met, A calls the `Wait()`

3. The `Wait()`actually performs two operations *automatically* -- 

   a. Releases the mutex

   b. it blocks the current execution, effectively putting the goroutine to sleep.

4. Since, released, so the mutex is just available, then another goroutine B fore, acquires it to update the shared state. Fore, B increases the amount of funds available in the shared bank account variable.

5. After updating the shared state, b calls `Signal()`or `Broadcast()`on the condition variable, unblocks the mutex.

6. Upon receiving `Signal`, A wakes up and automatically reacquire the mutex.

7. Condition is eventually met.

8. The goroutine continues executing its logic.

```go
type Cond
func NewCond(l Locker) *Cond
func (c *Cond) Broadcast()
func (c *Cond) Signal()
func (c *Cond) Wait()
```

And a new condition vairable requires a `Locker`-- defines two functions like;

```go
type Locker interface {
    Lock()
    Unlock()
}

func main() {
	money :=100
	mutex := sync.Mutex{}
	cond := sync.NewCond(&mutex)
	go stingy(&money, cond)
	go spendy(&money, cond)
	time.Sleep(time.Second * 2)
	fmt.Println("Main done", money)
}
func stingy(money *int, cond *sync.Cond) {
	for i := 0; i < 1000000; i++ {
		cond.L.Lock()
		*money += 10
		cond.Signal()
		cond.L.Unlock()
	}
	fmt.Println("stringy done")
}
```

Every time we add money to our shared `money`, send a signal by calling the `Signal`functon on the condition variable. The other change is that we are using the mutex present on the condition variable to protect to our critical section. Then can modify the `spendy()`so that it waits until have enough in variable. like:

```go
func spendy(money *int, cond *sync.Cond) {
	for i := 0; i < 200000; i++ {
		cond.L.Lock()
		for *money < 50 { // note that use the for not if
			cond.Wait()
		}
		*money -= 50
		if *money < 0 {
			os.Exit(1)
		}
		cond.L.Unlock()
	}
	fmt.Println("Spendy Done")
}
```

Whenever a waiting goroutine receives a signal or boradcast, will try to re-acquire the mutex -- if another execution is holding on the mutex, the goroutine will remain suspend until the mutex becomes available.

#### Missing the signal

What happens if a goroutine calls `Signal()`or `Broadcast`and there is no execution witing for it. If there is no goroutine in a waiting state, the `Signal`will be missed. Fore:

```go
func doWork(cond *sync.Cond) {
    println("started")
    println("finished")
    cond.Signal()
}
func main() {
    cond := sync.NewCond(&sync.Mutex{})
    cond.L.Lock()
    for i:=0; i<50000; i++ {
        go doWork(cond)
        println("waiting for child goroutines")
        cond.Wait() // unlock and block
        println(...)
    }
    cond.L.Unlock()
}
```

Can just modify the `doWork`function so that it locks the mutex before calling `signal()`-- this ensures the main() goroutine is in a waiting state.

```go
func doWork(cond *sync.Cond) {
    println(...)
    cond.L.Lock()
    cond.Signal() // always in block mode. cuz using Lock, so be sure that the `Wait()`called
    cond.L.Unlock()
}
```

### Money Converter CLI aournd and HTTP Call

- Writing a CLI
- Making an HTTP call to an external URL
- Mocking an HTTP call for unit tests
- Grasping floating-point precision errors
- Parsing XML- structured string
- Inspecting errors types.

#### `money.Convert`convers money

While the `main`is responsible for running the executable in a terminal, reading input and writing output, most of the logic will reside inside a subpackage. Like:

```go
// convert applies the change rate to convert an amount to a targ
func Convert(amount Amount, to Currency) (Amount, error) {
    return Amount{}, nil
}
```

Need to define two custom types -- `Amount`and `Currency`-- can already anticipate that they will hold a few methods.

#### Currency -- 

Standard associates a 3-letter code to every currency used out there in the real world `USD`or `EUR`.

```go
// Currency defines the code of a currency
type Currency struct {
	code string // nolint: unused
}
```

The ISO-4217 standard associates a 3-letter code to every currency used out there is the real world, for example USD or EUR -- as this will be our input, can start by using the 3-letter code to define our `Currency`type that will represent the currency code with a field of type `string`.

The code string is hidden inside the struct for any external user. will continue building all of our types so that they stay immutable, meaning that once they are constructed, they cannot be changed. Do that to make the code more secure for the package’s users -- have 10 euros, will not suddenly become -- makes the objects inherently thread-safe.

#### Amount and Decimal

As our tool will convert money, need to be able to represent a quantity of money in a given currency to convert.

```go
//Decimal is capable of string a decimal value 
type Decimal struct {
}
// Amount defines a quantity of money in a given Currency
type Amount struct {
	quantity Decimal
	currency Currency
}

// Convert applies the change rate to convert an amount to a target currency
func Convert(amount Amount, rate float64) (Amount, error) {
	return Amount{}, nil
}
```

#### Testing Convert

Testing a function that does nothing is pretty preposterous -- might think -- would like to argue that if you can’t write a test that is easy to understand and maintain -- your architectural choice are on the wrong path.

```go
func TestConvert(t *testing.T) {
	tt := map[string]struct {
		amount   money.Amount
		to       money.Currency
		validate func(t *testing.T, got money.Amount, err error)
	}{
		"34.98 USD to EUR": {
			amount: money.Amount{},
			to:     money.Currency{},
			validate: func(t *testing.T, got money.Amount, err error) {
				if err != nil {
					t.Errorf("unexpected error: %v", err)
				}
				expected := money.Amount{}
				if !reflect.DeepEqual(got, expected) {
					t.Errorf("expected %v, got %v", expected, got)
				}
			},
		},
	}

	for name, tc := range tt {
		t.Run(name, func(t *testing.T) {
			got, err := money.Convert(tc.amount, tc.to)
			tc.validate(t, got, err)
		})
	}
}
```

## how middleware works

Currently, in the app, when server receives a new HTTP request it calls the servermux’s `ServeHTTP`-- this looks up the revelant handlers based on the request URL path, and turn calls that handler’s `ServeHTTP()`method. The basic idea of middleware is to insert another handler into this chain. 

#### The pattern

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.RespsoneWriter, r *http.Request) {
        // ... execute our middleware logic
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

And the code itself is pretty -- 

- `myMiddleawre`is essentially a wrapper around the `next`handler
- Establishes a func `fn`which *closes over* the `next`handler to form a closure. When `fn`is run it executes our middleware logic and then transfers control to the `next`handler by calling its `ServeHTTP`.

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        //... todo execute our middleware logic here
        next.ServeHTTP(w, r)
    })
}
```

This pattern is just very common in this wild -- 

#### Positioning the middleware

It’s important to explain that where U position the middleware in the chain of the handlers will affect the behavior of your application -- like:

```sh
myMiddleware -> serveMux -> application handler
```

A good example of where this would be useful is middleware to log requests -- that’s typically sth you would want to do for *all* requests.

Alternatively, can position the middleware after the servemux in the chain -- by wrapping a specific application handler -- this would cause your middlware to only be executed for specific route like:

```sh
serveMux-> myMiddleware-> application handler
```

### Setting Security headers

Quickly explain what they do -- 

- `Content-Security-Policy`-- Headers are used to restrict where the resources for your web page can be loaded from. Setting a strcit CSP policy helps prevent a variety cross-site scripting..
- `Referrer-Policy`-- control what info is included in a `Referer`header when a user navigates away from your web page. WIll set the value to `origin-when-cross-origin`.
- `X-Content-Type-Options: nosniff`-- instructs browsers to not MIME-type sniff the conent-type of the response.
- `X-Frame-Options: deny`-- is used to help prevent clickjacking attacks
- `X-XSS-Protection:0`.

```go
func secureHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// note: this is split across multiple lines for readability
		w.Header().Set("Content-Security-Policy",
			"default-src 'self'; style-src 'self' fonts.googleapis.com; font-src fonts.gstatic.com")
		w.Header().Set("Referrer-Policy", "origin-when-cross-origin")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "deny")
		w.Header().Set("X-XSS-Protection", "0")
		next.ServeHTTP(w, r)
	})
}
```

Cuz wants this middleware to act on every request that is received, need it to be executed *before* a request hits our servemux. like:

```go
func (app *application) routes() http.Handler {
    mux := http.NewServeMux()
    fileServer := http.FileServer(http.Dir("./ui/static/"))
    mux.Handle("/static/", http.StripPrefix("/static", fileServer))
    //...
    // Pass the servemux as the next parameter to the secureHeaders middleware
    return secureHeaders(mux)
}
```

Go ahead and give this a try. It’s important to know when the last handler in the chain returns -- control is passed back up the chain in the reverse direction. In any middleware handler, code which comes before `next.ServeHTTP`will be executed on the way down chain, and any code after `next.ServeHTTP()`-- 

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
        // any code here will execute on the way down the chain
        next.ServeHTTP(w, r)
        // any code here will execute the way back up the chain.
    })
}
```

#### Earily returns

Another thing to mention is that if you call `return`in your middleware function *before* you call `next.ServeHTTP`. Then the chain will stop being executed and control will flow back upstream. As an example, a common use-case for early returns is authentication middleware which only allows execution of the chain to continue if a particular check is passed fore -- 

```go
func MyMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if !isAuthorized(r) {
            w.WriteHeader(http.StatusForbidden)
            return
        }
        // otherwise, call the next handler in the chain.
        next.ServeHttp(w, r)
    })
}
```

Later in the book to restrict access to certain parts of our application.