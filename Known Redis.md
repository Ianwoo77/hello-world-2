# Known Redis

Redis is a very fast non-relational dbs that stores a mapping of keys to 5 different types of values. Just supports in-memory persistent storage on disk, replication to scale read performance, and client-side sharding to scale write performance. -- 

**sharding** is a method by which U partition your data into different pieces. U just partition your data based on IDs embedded in the keys, on some combination of the two. Can store and fetch data from multiple machines.

Redis supports the writing of its data to disk automatically in two different ways, can store data in 4 structures inaddition to plain string keys as memcached does. These and other differences allow Redis to solve a wider range of problems.

## What Redis data structures look like

`STRINGs, LISTs, SETs, HASHes, ZSETs`:

- ``STRING`-- strings, integers, or floating-point -- operate on the whole string, parts, increment and decrement
- `LIST`-- linked list of strings -- Push or pop items from both ends, trim based on offsets read individual or multiple items find or remove items by value.
- `SET`-- Unordered collectoin of strings - Add, fetch, or rmove individual items, check membership, intersect, union, difference, fetch random items.
- `HASH`-- unordered hash table of keys to values -- add, fetch, or remove individual items, fetches the whole hash.
- `ZSET(stored set)`-- ordered mapping of string members to floating-point scores, ordered by scores.

### strings in Redis

`STRINGs`are similar to strings -- or other k-v stores. The operations available to `STRINGS`start with what’s available in other k-v stores. Can `GET`, `SET`and `DEL`values.

### Lists in Redis

Supports a linked-list structure, `LISTs`in Redis just store an ordered sequence of strings,  represent like strings -- the operations that can be performed on `LISTs`are typical of what find in almost any programming language, can `push`to the front and the back of the `LIST`with `LPUSH/RPUSH`, pop from that using `LPOP/RPOP`, fetch that with `LINDX`, can fetch a range of that with `LRANGE`. FORE:

```react
rpush list-key item
rpush list-key item2
lrange list-key 0 -1
lindex list-key 1
lpop list-key
```

### Sets in Redis

In Redis, `SETs`are similar to `LISTs`in that they are a seq of strings -- but unlike -- `SETs`uses a hash table to keep all strings unique -- cuz Redis `SETs`are unordered, can’t push or pop items from the end like `LISTs`, add and remove by value with the `SADD`and `SREM`commands, can also find out whether an item is in the `SET`quicily with `SISMEMBER`, or fetch the entire set with `SMEMBERS` ( for this, is slow in large sets ). can follow along with listing in your redis client console to get a feel for how `SETs`work -- 

- `SADD`-- adds the item to the set
- `SMEMBERs`-- returns the entire set of items
- `SISMEMBERS`-- checks if an item in the set
- `SREM`-- Removes the item from the set, if it exists note that

```sh
sadd set-key item
sadd set-key item2
smembers set-key
sismember set-key itemr # 0
sismember set-key item #1 
srem set-key item2 # 1
srem set-key item2 # 0
smembers set-key
```

as can probably guress based on the `STRINGs`and `LISTs`sections, `SETs`have many other uses. three commonly used operations with `SETs`include intersection, union, and difference ( `SINTER SUNION SDIFF`).

### Hashes in Redis

Redis `HASHes`store a mapping of keys to vlaues. The values that can be stored in `HASHes`are the same as stored as normal `STRINGS`. fore:

```sh
hset hash-key sub-key1 value1
hset hash-key sub-key2 value2
hset hash-key sub-key1 value1 # 0
hgetall hash-key
hdel hash-key sub-key2
hdel hash-key sub-key2 # 0
hget hash-key sub-key1
hgetall hash-key
```

### Stored sets in redis

Like `HSAHes`, `ZSET`s also hold a type of key and value -- and the keys (called members) are unique, and the values (srores) are lmited to the *floating-point nubmers*. have a unique property in Redis of being able to be accessed by members -- but itmes can also be accessed by the stored order and values of the scores.

`ZADD, ZRANGE, ZRANGEBYSCORE, ZREM`

```sh
zadd zset-key 728 member1
zadd zset-key 982 member0
zrange zset-key 0 -1 withscores
zrangebyscore zset-key 0 800 withscores
zrem zset-key member1 # 1
zrem zset-key member1 # 0
zrange zset-key 0 -1 withscores
```

## Generics -- Common uses and misuses

When are generics useful -- discuss a few common uses where generics are just recommended -- 

- Data structures -- can use generics to factor out the element type if implement a binary tree, linked list...
- Functions working with slices, maps, and channels of *any types* -- A function to merge two channels would work with any channel type -- fore, could use type parameters to factor out the channel type.

```go 
func merge[T any](ch1, ch2 <-chan T) <-chan T {}
```

- Factoring out behaviors instead of types -- fore, the `sort`package contains a `sort.Interface`
  This jsut is used by different functions such as `sort.Ints`or `sort.Float64`... Using type parameters, could factor out the sorting behavior. like:

```go
type sliceFn[T any] struct {
    s []T
    Compare func(T, T) bool
}
// then can factor the interface:
func (s SliceFn[T]) Len() int {return len(s.S)}
func (s SliceFn[T]) Less(i, j int) bool {return s.Compare (s.S[i], s.S[j])}
func (s SliceFn[T]) Swap(i, j int) {s.S[i], s.s[j]= s.S[j], s.S[i]}
```

So, cuz the `sliceFn`struct just implemetns the `sort.Interface`, then can sort the provided slice using the `sort.Srot(sort.Interface)`function like:

```go
func main() {
	s := SliceFn[string] {
		S: []string {"Fry", "Bender", "Leela"},
		Compare: func(a, b string) bool {
			return a<b
		},
	}
	sort.Sort(s)
	fmt.Println(s.S)
}
```

Confersely, when is it recommended that no use generics -- 

- When calling a method of type arg -- Consider a function that receives an `io.Writer` FORE:

  ```go
  func foo[T io.Writer] (w T) {
      b := getBytes()
      _, _ = w.Write(b)
  }
  ```

  In this case, using generics won’t bring any value to code whatsoever. we should just using the `io.Writer`directly.

- When it makes our code more *complex*.

## Not being aware of the possible problems with type embedding

When creating a sturct, Go just offers the option to embed types, but this can sometimes lead to unexpected behaviors if don’t understand all the implementations of type embedding.

In go, a struct field is called embedded if it’s declared without a name. 

```go
type Foo struct {
    Bar
}
```

In the `Foo`, the `Bar`type is just declared without an assicoated name -- hence, it’s an embedded field. Use embedding to *promote* the fields and methods of an embedded type -- cuz `Bar`just contains a `Baz`maybe -- this field jsut is promoted to `Foo` -- 

```go
foo := Foo{}
foo.Baz=42
```

For this, also note that the `Baz`is available from two different paths -- either from the promoted one using `Foo.Baz`or from the nominal one var `Bar`. or via `Foo.Bar.Baz`

### Interfaces and embedding

Embedding is also used within interfaces to compose an interface with others -- in the following, `io.ReadWriter`is composed of an `io.Reader`and an `io.Writer`. like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

In the following, implement a struct that holds some in-memory data, want to protect it against concurrent access.

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem {
    return &InMem{m: make(map[string]int)}
}
```

And decide to make the map unexported so that clients can’t interact wtih it directly but only via exported methods. fore:

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, container := i.m[key]
    i.Unlock()
    return v, contains
}
```

Cuz the mutex is just embedded, can directly access the `Lock()`and `Unlock()`.

For this -- promotiion is probably not desired -- A mutex - is want to just encapsulate within a struct and *make invisible to external clients*. Therefore, shouldn’t make ita an embedded field in this case. should be:

```go
type InMem struct {
    mu sync.Mutex
    m map[string]int
}
```

Cuz the mutex isn’t embedded and is unexported, can’t be accessed from external -- Want to write a custom logger that contains an `io.WriteCloser`.

So, what should we conclude about type embedding -- first -- note that it’s rarely a necessity -- and it just means that whatever the use case -- can probably solve it as will without type embedding. Type embedding is mainly used for convenience -- in most cases, to promote behaviors -- 

- It shouldn’t be used solely as some syntactic sugar to simplify accessing a field -- if this is the only rationale, not embed the inner type and use a filed instead.
- It shouldn’t promote data or a behavior want to hid from the outside.

# CSRF protection

**CSRF**-- jsut a form of cross-domain attack where a malicious 3rd-party web site sends a state-changing HTTP requests to your website -- A great explanation of the basic CSRF can be found -- 

- A user logs into our app.
- Then goes to malicious website -- which contains some code that sends a request to `POST /snippets/create`to add a new..
- Since the user is still just logged in the app, the request is just processed with privileges.

### SameSite Cookies

One mitigation that can take to prevent CSRF attacks is to make sure that the `SameSite`attribute is set on our session cookie -- By default, the `glangcollege/session`package, that we are using always set `SameSite=Lax` on the session cookie -- this means that the session cookie won’t be sent by the user’s browser for cross-site usage. If:

```go
session := sessions.New([]byte(*secret))
// ...
session.SameSite= http.SameSiteStrictMode
```

This set to `SameSite=Strict`instead U can. Using this just block the session cookie sent by the user’s browser for all cross-site usage -- includes when a user click on an external link to your appliation - meaning that after that clicking the link they will initially be treated as `not logged`.

### Token-based Mitgation

To just mitigate the risk of CSRF for all users also need to imlement some form of `token check`. Like session management and password hashing, when it comes to this there is a lot that can get wrong so it’s probably safer to use a tried-and-tested third-party package instead of rolling your own implementation.

Two most popular packages for stopping CSRF attacking in Go web apps are `gorilla/csrf`and `justinas/nosurf`. They both do roughly the same thing -- using the `Double submit cookie pattern`.

In this pattern, a random token is generated and sent to the user in a CSRF cookie -- this token is then added to a hidden field in each form that is vulnerable to CSRF. When the form is submitted, both packages use some middleware to check that the hidden field value and cookie value match.

Out of these, opt to use `justinas/nosurf`in this book -- prefer it primarly cuz it’s self-contained and doesn’t have any additional dependencies.

### Using the `nosurf`package

Open up `middleware.go`file to create `noSurf()`function like:

```go
// noSurf create a NoSurf middleware function which uses a customized CSRF cookie with
// the secure, Path and HttpOnly flags set.
func noSurf(next http.Handler) http.Handler {
	csrHandler := nosurf.New(next)
	csrHandler.SetBaseCookie(http.Cookie{
		HttpOnly: true,
		Path:     "/",
		Secure:   true,
	})
	return csrHandler
}

```

One of the forms that need to protect from CSRF attack is our logout -- which is just included in the `base.layout.html`file and could potentially appear on any page of our appliation -- so, cuz of this, need to use our `noSurf()`on all our app routes -- except `/static/`

so, update the routes.go file to add this `noSurf()`to the `dynamicMiddleware`chain -- 

`// and use the noSurf on all our dynamic routes.
dynamicMiddleware := alice.New(app.session.Enable, noSurf)`

To make the form submissions work, need to use the `nosurf.Token()`to get the CSRF token and add it to a hidden `csrf_token`field in each of our forms. Need to add a new `CSRFToken`field to the `templateData`struct like:

```go
type templateData struct {
    CSRFToken string
    //...
}
```

And, cuz the logout form can potentially appear on every page, it just makes sense to add the `CSRF`token to the template data via the `addDeafultData()`helper. This will means it’s automatically available to our templates each time we render a page.

```go
// add the CSRF token to the templateData struct
td.CSRFToken = nosurf.Token(r)
```

Finally, just update all the forms in app to use this token like:

```html
<!-- include the CSRF token -->
<input type="hidden" name="csrf_token" value="{{.CSRFToken}}" >
```

# Using Request Context

At the moment our logic for authenticating a user consists of simply checking whether a `authenticatedUserID`value exists in their session data -- like:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
    return app.session.Exists(r, "authenticaedUserID")
}
```

could make this more robust by checking our `users`dbs table to make sure that the `authenticatedUserID`value is just valid - and that the suer account it relates to is still active. 

For this, `isAuthenticatedUser()`helper can be called multiple times in each requests cycle -- currently use it twice -- once in the `requireAuthentication()`and again in the `addDefaultData()`. So if check the dbs, not efficient.

And a better approach would be just carry this check just in some middleware to determine whether the current request is from an *authenticated-and-active* user or not -- and then pass this info down to all subsequent handlers.

## How Request Context Works

Every `http.Request`has a `context.Context`obj embedded in it -- which can use to store info during the lifetime of the request. In a web app, a common use-case for this is to pass info between your pieces of middleware and other handlers. Want to check if a user is authenticated-and-active once in some middleware.

### The Request Context Syntax

The basic code for adding info to a request’s context looks like just:

```go
ctx := r.Context() // r just the *http.Request of course
ctx = context.withValue(ctx, "isAuthetnicated", true)
r = r.withContext(ctx)
```

# Displaying QR Codes

Identitiy just provides support for two-factor authentication – where the user has to present additional credentials to sign in the app – the identity UI package supports a specific type of additional credential.

```sh
libman install qrcodejs -d wwwroot/lib/qrcode
```

```js
let element = document.getElementById("qrCode"); // note that, hardcoded by ASP.NET core
if (element != null) {
    new QrCode(element, {
        text: document.getElementById("qrCodeData").getAttribute("data-url"),
        width: 150, height: 150
    })
    element.previousElementSibliing?.remove();
}
```

## Using the Identity UI workflows

The basic configuration of the UI package is complete – how to customize the Identity UI package, but before doing that, describe the featues of the UI package provides by default and the detail the RPs that each relies on, which is just useful when it comes to customization.

Use the term *workflow* in this book to refer to the process that can be performed using Identity – Each workflow combines multiple features to support a task, such as creating a new account or changing a password.

### Registration

The Identity UI package just supports self-registeration – means that anyone create new and then just use sign into the app. Identity can be configured to require the user to click the confirmation link before signing into the app.

### Signing In an dout of the App

`/Account/Login, ExternalLogin, SetPassword, Logout, Lockout`

### Using Two-factor Authentication

And if a user has forgotten pwd, can go through a recovery process to generate a new one. Password recovery works only if a user confirmed their email address follow registration. Password recovery works only if a user confirmed their email address following registration.

## Configuring Identity

For this, explain how to configure Identity, including how to support 3rd-party services from google…

## Creating Observables

`let userRequest= getUserFromAPI();`

Like a variable, `userRequest`just contains a single value, but it doesn’t immediately have that value – a `Promise`represents data that has been requested but isn’t there yet. To do anything with that data, need to *unwrap* the promise using the `.then`method. like:

```js
let userRequest= getUserFromAPI();
userRequest.then(userData=> {
    processUser(userData);
});
```

A promise just allows the core process to go in doing things elsewhere, while the backend rultles – once the request returns, our process peeks inside the `.then`to see what to do, executing whatever function we passed in. 

Observables are just like arrays in that they represent a *collection* of events, but are also like promises they are just **asynchronous** – each event in the collection arrives at some indeterminate point in the future. This is distinct from a collection of promises in that an observable can handle an arbitrary number of events, and a promise just can only track **one** thing.

An observable can be used to model clicks of a button – *represents all the clicks that will happen over the lifetime* of the application.  These clicks will happen over the lifetime of the application – much like a promise – need to unwrap our observable to acces the values it contains. – The observable unwrapping method is just called `subscribe`. The function passed into subscribe is *called every time the observable just emits a value*. like:

```ts
let myObs$= clickOnButton(myButton);
myObs$
	.subscribe(clickEvent=> console.log("The button clicked"));
```

And one thing to note here is that observables under RxJS are **lazy**. This means that if there is no subscribe call on the `myObs$`, no click event handler is created.

## Building a Stopwatch app

Just think about how you’d implement this without Rx – couple of click handlers for the start and stop buttons. At some point, the program would create an interval to count the seconds – For this – has two different categories of observables - and the interval timer has its own internal state and outputs tot he DOM.

### Running the Timer – 

This timer will need to track the total number of seconds elapsed and emit the latest value every 1/10th of second. When the stop button is pressed – the interval should be just cancelled. Just like: #1:

```ts
import {Observable} from 'rxjs';

let tenthSecond$ = new Observable(observer => {
    let counter = 0;
    observer.next(counter);
    let interv = setInterval(()=> {
        counter++;
        observer.next(counter);
    }, 100);
    return function unsubscribe() {clearInterval(interv);};
});
```

Just walk through – 

`let tenthSecond$ = new Observable(observer=> {...})`

In this case of the observable ctor function – Rx creates the observer for you and passes it to the inner function. And inside the ctor function – there is an internal state in the `counter`that tracks the number of .. since the start. Immediately, `observer.next`is just called with the initial value of 0 – then here is an interval that fires every 100ms – incrementing the counter and calling the `observer.next(counter)` – this `.netxt`on the observer is how an observable announces to the subscriber that it has a new value available for consumption.

And nothing appears in the console – the ctor appears to never actually run – cuz this is the lazy observable at work. In Rx land – this ctor function will only run when just someone subscribes to it. Not onlyh that – but if there is a *second* subscriber. All of this will run a second time – creating just an *entirely* separate stream. Just for now remember that each subscription creates a new stream.

Finally, the inner function returns yet another function like:

`return function unsubscribe() {clearInterval(interv);}`

If the ctor jsut returns another function – this inner function *runs whenever a listener unsubscribes* from the source observable. Wo just clear it – saves CPU cycles – and keeps fans from .. All of the setup and teardown logic is just *located in the same place*, so it requires less mental overhead to just remember to clean up all the objects that get created.

All of this work has already been implemenated in the Rx lib in the form of a *creation operator*. like:

```ts
import {interval} from 'rxjs';
let tenthSecond$ = interval(100);
```

Rx ships with a whole bunch of these creation operators for common tasks Can find the complete.. `interval(100)`just is similar to big ctor function. FORE:

`tenthSecond$.subscribe(console.log)`

When there is a *subscribe* call, numbers start being logged to the console – the numbers that are logged are slightly off from what you want –  The current implementation counts the number of tenths-of-a-second like:

### Piping data through Operators

An operator is just a tool provided by RXjs that allows you to manipulate the data in the observable as it streams thorugh. Can import operators from `rxjs/operators`to use.. pass it into the `.pipe`method of an observable. like:

```ts
interval(100)
	.pipe(someOperator());
```

### Manipulating Data in Flight with map

Have a collection of almost-right data that needs just one little tweak for it to be correct – `map`opreator – takes two parameters – collection, and another func – applies the function to each time, and returns a *new* collection contianing the result – A simle implementation looks sth like:

```ts
function map(oldArr, someFunc) {
    let newArr=[];
    for (let i=0; i<oldArr.length; i++ ) {
        newArr.push(someFunc(oldArr[i]));
    }
    return newArr;
}
```

Js jsut provides a built-in map for arrays … Fore only wroks with sync arrays - conceptually, map works on just any type of collection – `Observable`s are just such a collection and Rx provides a `map`operator of its won – it’s piped through a source observable, takes a function, and returns a new observable that emits the result of the passed-in function. Importantly, the modification is to divide the incoming number by 10. like:

```js
tenSecond$
	.pipe(map(num=>num/10))
	.subscribe(console.log);
```

### Handling User input

The next step is just to manage clicks on the start and stop button. First grab the elements off the page with `querySelector`. Now have the buttons, need to fiture out when the user clicks them – could use the ctor covered in the last section to build an observable that streams click events from an arbitrary element like:

```ts
function trackClickEvents(element) {
    return new Observable(observer=> {
        let emitClickEvent = event=> observer.next(event);
        element.addEventListener('click', emitClickEvent);
        return ()=> element.removeEventListerner(emitClickEvent);
    });
}
```

Can also use the library to do all the work – Rx provides a `fromEvent`creation operator for exactly this case. It takes a DOM element and an event name as parameters and returns a stream that fires whenever the event fires on the element. Using the buttons from above – like:

```ts
let startButton = document.querySelector('#start');
//...
let startClick$ = fromEvent(startButton, 'click');
let stopClick$ = fromEvent(stopButton, 'click');
```

Everytime you click, should see a click event object logged to the console.

### Assembling the Stopwatch

All three observables have been created – so assembly everything into an actual program like:

```ts
//...
startClick$.subscribe( ()=> {
   tenthSecond$
   .pipe(
   	map(item=>item/10),
       takeUnitl(stopClick$),
   ).subscribe(num=>resultArea.innerText=num + 's');
});
```

There is a few new concepts – there are … three elements from the page and 3 observables., just the interval, start and stop observables. The first of business logic is a subscription to `startClick$`, which creates a click event handler on that element – at this point, no one’s clicked the Start – so Rx hasn’t created the interval … 

And when the Start is clicked – the subscribe is triggered – The actual click event is ignored, as this implementation doesn’t care about the specifics of the click, just that it happened – immediately, `tenthSecond$`runs its ctor cuz there is a subscribe call at the end of the inner chain. Every event fired by the `tenthSecond$`runs through the map function – dividing…

Just note that the `takeUntil()`operator – that attaches itself to an observabe steam and takes values from the stream, **until** the observable that’s passed in as an *arg emtis a value*. And at that point, `takeUntil`unsubscribes from both - in this case, want to continue listening to new eents from the timer observable until the user clicks the `Stop`button. When that pressed, Rx cleans up both the interval and unsubscribe calls for `stopClick$`happen at the library level.

Finally, put the latest value from `tenthSecond$`on the page.

## How does this just apply externally

U should start to see how Rx can just simplify our complicated fronted codebases – each call is cleanly separted, and the view update has a single location – while it provides a neat demo..

### Drag and Drop

Another of Rxjs is drag and drop – The difficult part of dealing with a dragged element comes in tracking all the events that fire – maintaining state and order without devolving into a horrible grabled mess of code. The code also must be performant – Rx’s lazy subscription actually drags the element – additionally – aren’t tackling any `mousemove`until the user actually drags the elements – additionally `mousemove`events are just fired sync – so Rx will guarantee that they just *arrive in order* to the next step in the stream. Like:

```ts
let draggable = <HTMLElement>document.querySelector('#draggable');
let mouseDown$ = fromEvent<MouseEvent>(draggle, 'mousedown');
let mouseMove$ = fromevent<MouseEvent>(document, 'mousemove');
let mouseUp$ = fromEvent<MouseEvent>(document, 'mouseup');

mouseDown$.subscribe(()=> {
    mouseMove$.
    pipe(
    	map(event=> {
            event.preventDefault();
            return {
                x: event.clientX,
                y: event.clientY,
            };
        }),
        takeUntil(mouseUp$),
    ).subscribe(pos=> {
        draggable.style.left=pos.x+'px';
        draggable.style.top= pos.y+ 'px';
    });
});
```

For this, just at the start are the same bunch of variable declarations that you .. In this case, the code tracks a few events on the entire HTML *document*. though if only one element is a valid area for gragging, that could be passed in. The initiating observable, `mouseDown$`is subscribed.  And in the subscription, each `mouseMove$`event is mapped, so that the only dat passed on are the current coordinates of the mouse. And `takeUntil()`is used – once the mouse button is released, everything is cleanedup. Finally, the inner subscribe updates the position of the dragged element acorss the page.

### Loading Bars

Instead of trying to track lots of glboal states, let Rx to do – how to add a single function here to handle cases when a bit of your app didn’t load like:

```ts
startLoad$.subscribe(()=> {
    assetPipeline$.pipe(
    	takeUntil(stopLoad$)
    	)
    .subscribe(item=> updateLoader(item));
});
```

### Chat Rooms

Both know just how much programmers chat rooms - use the power of Rx to track only the rooms that the user has just joined – you will use some of these techniques to build an entire chat app like:

```ts
loadRoom$.subscribe(()=> {
    chatStream$
    .pipe(takeUntil(roomLeave$))
    .subscribe(msg=>addMsgToRoom(msg));
});
```

### Using a Subscription

There is one more vocabulary – subscription – while piping through an `operator`returns an observable. like:

`let someNewObservable$= anObservable$.pipe(map(x=>x*2));`

A call to .`subscribe`returns a *Subscription*.

`let aSubscription= someNewObservable$.subscribe(console.log);`

note that Subscriptions are not a subclass of observables – so there is no `$`sign for that. Rather, a subscription is used to just keep track of a specific subscription to that observable – this means whenever the program no longer needs the values from the particular observable stream, can use the subscription to just unscribe from all future events like:

`aSubscription.unsubscribe()`

And, some operators, like `takeUntil()`, handle subscriptions internally – and, Most of the time – code just manually.

## Experimenting with Observables

The section covers the `of`and the `take`and `delay`operators – they are just included in the – cuz all three are useful for hands-on experimentation with observables.

### `of`

The `of`ctor allows for easy creation of an observable our of a known data source. Takes any number of args and just returns an observable containing each argument as a spearate event – the following logs the 3 things passed in:

```ts
of('hello', 'world', '!').subscribe(console.log);
```

This just can be handy when try to learn a new operator – It’s the simplest way to create an observable of arbitrary data. Fore, if your are struggling with the `map`operator, may be elucidating 

### `take`

It’s just passed a single integer arg – and takes the many events from the observable *before it unsubscribes*.

```ts
interval(1000).pipe(
	// take transforms into an observable of only 3 items
    take(3)
).subscribe(console.log);
```

So, it’s useful when only what the first slice of observable’s dat.

### `delay`

is passed an integer arg and delays events coming through the observable chain by that ms. like:

```ts
of(1,2,3)
.pipe(delay(1000)).subscribe(console.log);
```

And the `delay`operator is also helpful when connecting mutiple streams together. for:

```ts
let oneSecond$ = of('one').pipe(delay(1000));
let twoSecond$ = of('two').pipe(delay(2000));
//...
merge(oneSecond$, twoSecond$).subscribe(console.log);
```

# What Problems does Docker solve?

Using software is complex – have to consider the OS you are using, and the resources the software requires.. Package managers such as APT, brew, YUM, and NPM attempts to manage this – but few of those provide any degree of isolation. Most Computers have more than one app installed an running. And most apps have dependencies on other software – 

### Getting organized

Without Docker, a computer can end up looking like a junk drawer. Apps have all sorts of dependencies – some apps depend on specific sytem libs for common things like sound, networking, graphics, and so on.

### Runining software in containers

- A container created from the nginx image, which depends on network port 80
- A container created from the maler image, depends on port 33333
- Created from the wather image, depends on nginx conainer and mailer container.

*Detached* means that the container will run in background, without being attached to any input or output stream. A third wather will run as a monitoring agent – 

- create detached and interactive containers.
- List containers on system
- View container logs
- Stop and restart
- Reattach a terminal to a container
- Detach from an atached container.

### Creating and starting a new container

Docker calls the collection of files and instructions needed to run a softwoare program an *image*. When install with Docker, are really using Docker to download or create an image - there are just a few different ways to install. Docker Hub is the public registry provided by inc. the NGINX is calls *trusted repository*. like:

```sh
docker run --detach --name web nginx:latest
```

The blob of characters is the unique id of the container that was just created to run NGINX – every time U run `docker run`and create a new conainer, that new container will get a unique id.

Running detached containers is perfect fit for programs that sit quietly in the background. That type of program is called a daemon – or a service. A daemon generally interacts with other progrmas or humans over a network or some other communication channel – when launch a daemon or other program in a container that you want to run in the background, remember to use either the `–-detach`or `-d`

Another that needs in this is a mailer, 

```sh
docker run -d --name mailer dockerinaction/ch2_mailer
```

### Running interactive containers 

Then a terminal-based is – is jsut a great example of a program that requires an attached terminal fore:

```sh
docker run --interactive --tty --link web:web --name web_test busybox:1.29 /bin/sh
```

This command uses two flags on the `run`, `--interactive`(`-i`)and `--tty` (`-t`) – `–-interactive` tells Docker to keep std input stream open for the container even if no terminal is attached. `-t`tells to allocate a virtual terminal for the container.

```sh
wget -O - http://web:80
```

This just uses s program called `wget`to make an HTTP request to the web server, and then display the contents of the web page. It’s just possible to create an interactive container, manually start a process inside that container, and then detach your terminal. 

```sh
docker run -it --name agent --link web:insideweb --link mailer:insidemailer dockerinaction/ch2_agent
```

