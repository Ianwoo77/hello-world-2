# Rebasing --- Rec(1)

A 3-way merge creates a merge commit that ties the development historieis of the source branch and the target branch together -- If look at the state of the various repsoitories, can see that up until the commit had a linear project history -- Some teams and individual prefer to maintain a linear proj history cuz find it is more *organized* and simpler. And to carry out a rebase, need to be on a branch you want to rebase, use the `git rebase`command and pass in the name of the branch that you want to rebase onto.

Given that rebasing creates entirely new commits, this means that it changes the commit history. To practice, need to create *divergant histories* -- going to make one commit in the `rainbow`repository and push it to the remote repository, then without fetching the changes from the remote repository, make two commits in their friend repository. Fore:

```sh
git add othercolors.txt
git commit -m "gray"
git push

# then in the friend repository, change some txt file
git status
git add rainbowcolors.txt othercolors.txt
git status
```

Fore, decides they want to make separate commits for the work they didi adding the color black to the list of non-rainbow colors and work they did commenting on the rainbow.

`git restore --staged <filename>`

```sh
git restore --staged rainbowcolors.txt
git status
```

For this, the `git status`output shows that the updated version of the othercolors.txt file is still in the staging area.

```sh
git commit -m "black"
git status
# add another:
git add rainbowcolors.txt
git commit -m "rainbow"
```

#### Preparing to Rebase

To rebase a branch you first have to fetch all the work that has been done on the branch that you want to reabase to.

1. Find the common ancestor -- Git will identify the common ancestor of the two branches involved in the reabase.
2. Store info about the branches involved in the rebase -- Git will save the changes introduced by each commit of the branch you are on to a temporary are.
3. Reset HEAD -- reset `HEAD`to point to the same commit as the branch you are rebasing onto.
4. Apply and commit the changes
5. Switch onto the rebased branch

#### Rebasing and merge conflicts

Git will carry out the entire rebase process independently, unless it encounters merge conflicts -- in this case, must step in and resolve them. The process of resolving merge conflicts where rebasing is similar to the process when doing a 3-way merge. All the merge conflicts are presented to you at the same time -- once resolved all the conflicts and added all the updated files to the staging area, make the final merge commit.

```sh
git rebase --continue # continue with the rebase process after having resolved merge conflicts
git rebase --abort # stop rebase process and go back to the state before the rebase
```

#### In Practice

```sh
git rebase origin/main # in the friend directory # cuz in m2
git status  # here some err
# then carry out of resolving merge conflicts.
git add othercolors.txt
git status
git rebase --continue
```

#### Pull Request

is a feaure offered by a hosting service that allow U to share work you have done on a bracnch with your collaborators, potentially gather feedback on that work.

## Concurrent computations on the default case

A useful scenario is to use the default select case for concurrent computaitons and then use a channel to signal when we need to stop. Fore:

```go
func toBase27(n int) string {
    result := ""
    for n>0 {
        result = string(alphbet[n%27])+result
        n/= 27
    }
}
```

To avoid unnecessary computations, want to stop the execution of each goroutine when any goroutine makes a correct guests -- can use the `close()`operation on a channel to act like a signal being broadcast to all consumers.

```go
func guessPassword(from int, upto int, stop chan int, result chan string) {
    for guessN := from; guessN<upto; guessN ++ {
        select {
        case <-stop:
            //...
            return
        default:
            if toBase27(guessN) == passwordToGuess {
                result <- toBase27(guessN)
                close(stop)
                return
            }
        }
    }
    // print
}
```

#### Timing out on channels

Another scenario is blocking for only a specified amount of time, waiting for an operation on a channel. Want to check to see whether a message has arrived on a channel, want to wait for a few seconds to see if a message arrives, instead of unblocking immediately and doing sth else. This is useufl in many situations when channel operations are time sensitive. Can implement this behavior by using a separate goroutine that sends a message on an extra channel after a specified timeout. The `time.Timer`-- create one of these timers by calling `time.After(duration)`-- this will return a channel on which a message is sent after the duration time elapses.

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		time.Sleep(seconds)
		messages <- "Hello"
	}()
	return messages
}
func main() {
	t, _ := strconv.Atoi("1")
	messages := sendMsgAfter(3 * time.Second)
	timeoutDuration := time.Duration(t) * time.Second
	fmt.Printf("Waiting for message for %d seconds...\n", t)
	select {
	case msg := <-messages:
		fmt.Println("Message received", msg)
	case tNow := <-time.After(timeoutDuration):
		fmt.Println("Timeout!", tNow.Format("15:04:05"))
	}
}
```

#### Writing to channels with `select`

Can also use the `select`when we need to write messages to channels, not just when we are reading messages from channels -- `select`can combine read or write blocking channel operations together, selecting case that unblocks first. As in prevoius scenarios, can use `select`to implement non-blocking channel sending or sending on a channel with a timeout. Fore, 100 random prime numbers -- In programming, can have a primes filter that given a stream of random numbers, picks out any prime number it finds and outputs it on another stream.

```go
func primesOnly(inputs <-chan int) <-chan int {
	results := make(chan int)
	go func() {
		for c := range inputs {
			isPrime := c != 1
			for i := 2; i <= int(math.Sqrt(float64(c))); i++ {
				if c%i == 0 {
					isPrime = false
					break
				}
			}
			if isPrime {
				results <- c
			}
		}
	}()
	return results
}
```

Our goroutine outpus a subset of the number it receives on the input channel. Often, the goroutine receives a non-prime number that is thrown away, meaning no number is ouput. Then how can feed in a stream of reandom numbers while reading the primes returned on another channel in one goroutine -- To use a `select`statement to *both feed in the random numbers and read the primes*. This is shown in the following like:

```go
func main() {
	numberChannels := make(chan int)
	primes := primesOnly(numberChannels)

	for i := 0; i < 100; {
		select {
		case numberChannels <- rand.Intn(1000000) + 1:
		case p := <-primes:
			fmt.Println("Found prime:", p)
			i++
		}
	}
}
```

#### Disabling `select`cases with `nil`channels

In Go, can assign `nil`values to channels -- this has the effect of blocking the channel from sending or receiving anything -- as demonstrated in the following -- the `main()`tries to send a string on a `nil`channel, and the operation blocks, stopping any further statements from executing.

```go
func main(){
    var ch chan string = nil 
    ch <-"message" // block deadlock
}
```

The same logic applies to `select`statements -- trying to send or receive from a `nil`channel on a `select`statement has the same effect of blocking the case using that channel. 

Using `select`just one `nil`is not that useful -- can use the pattern of assigning `nil`to a channel to disable a `case`in a `select`statement. Consider a scenario where we are consuming messages from two separate goroutines on two separate channels. Fore, simulates expense and sals application -- func will create `n`random transaction amounts and send them on an output channel. like:

```go
func generateAmounts(n int) <-chan int {
	amounts := make(chan int)
	go func() {
		defer close(amounts)
		for i := 0; i < n; i++ {
			amounts <- rand.Intn(100) + 1
			time.Sleep(100 * time.Millisecond)
		}
	}()
	return amounts
}
```

And if were to use a normal `select`to consume from both the sales and expense goroutine, with oneo of the goroutines closing its channel earlier than the other, would end up always executing on the closed case. Note that every time we consumes from a closed channel, it will return the default data type without blocking. This also applies to `select`. If used a `select`statement to consume from both sources, would end up needlessly looping on the closed channel `select`case.

The solution would be to change the channel into a `nil`channel whenever it is closed. Reading from a channel always returns two values -- the message and a flag that telling us if the channel is still open. Assigning a `nil`value to the channel variable after the receiver detects that the channel has been closed has the effect of disabling that `case`statement -- this allows the receiving goroutine to read from the remaining open channels.

```go
func main() {
	sales := generateAmounts(50)
	expenses := generateAmounts(40)
	endOfDayAmount := 0
	for sales != nil || expenses != nil {
		select {
		case sale, moreData := <-sales:
			if moreData {
				fmt.Println("Sales:", sale)
				endOfDayAmount += sale
			} else {
				sales = nil
			}

		case expense, moreData := <-expenses:
			if moreData {
				fmt.Println("Expenses:", expense)
				endOfDayAmount -= expense
			} else {
				expenses = nil
			}
		}
	}
	fmt.Println("End of day profit and loss:", endOfDayAmount)
}
```

Once *both* channels are closed and set to `nil`, exit the `select`loop and output the end-of-day balance.

#### Choosing between message passing and memory sharing

We can decide whether to use memory sharing or message passing for our concurrent apps depending on the type of solution we are trying to implement. Concurrent programming using message passing tends to produce code containing well-defined modules, each module running its won concurrent execution that passes messages to other executions. In contrast, memory sharing means that we need to use a more primitive way of managing concurrency.

#### Designing tightly vs. loosely coupled systems

Tightly coupled software means that when change one component, it will have a *ripple* effect on many other parts of the software, which usually require changes as well. And in loosely coupled software, components tend to have clear boundaries and few dependencies on other modules.

Concurrent programming using memory sharing typically produces more tightly coupled sorftware. And the inter-thread communiation uses a common block of memory, and the boundaries of each execution are not clearly defined. Any execution can read and write to the same location.

In contrast, with message passing, execution can have clearly defined input and ouput contracts, which means we know exactly how a change in one execution will affect another.

### Go contexts

Sometimes misunderstand the `context.Context`type despite it being one of the key concepts of the language and a foundation of concurrent code in Go.  A Context carries a *deadline, cancellation signal* and other values across API boundaries.

#### Deadline

A deadline refers to a speicifc point in time determined with one of the following -- 

- A `time.Duration`from now
- A `time.Time`

The semantics of a deadline convey that an ongoing activity should be stopped if this deadline is met. Fore receives flight position from a radar every 4 seconds -- once receive a position, want to share it with other apps that are only interested in the last position like:

```go
type publisher interface {
    Publish(ctx context.Context, position flight.Position) error
}
```

This method accepts a context and a position. Assme that the concrete imp calls a function to publish a message to a broker -- this function is *context aware* -- meaning it can cancel a request once the context is canceld. Fore, don’t receive an existing context, what should we provide to the `Publish`for the context -- like:

```go
type publishHandler struct {
    pub publisher
}
func (h publishHandler) publishPosition(position flight.Position) error {
    // will timeout after 4s
    ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
    defer cancel()
    return h.pub.Publish(ctx, position)
}
```

Passing the context created to the `Publish()`should make it return in at most 4 seconds. Internally, `context.WithTimout`creates goroutine that will be retained in memory for 4s ***or** until `cancel`is called*. Therefore, calling `cancel`as a `defer`function means that when exit the parent function, the context will be canceled, and the goroutine created will e stopped.

#### Cancellation signals

Another use case for Go Context is to carry a cancellation signal -- Fore, calls `CreateFileWatcher(ctx, filename)`with another goroutine -- this func creates a specific file watcher that keeps reading from a file and catches updates. When the provided context expires or is canceled, this func handles it to close the file descriptor.

```go
func main(){
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    go func() {
        CreateFileWatcher(ctx, "foo.txt")
    }()
}
```

When the `main`returns, want things to be handled gracefully by closing file descriptor. When the `main`returns, it calls the `cancel`to cancel the contxt passed to the `CreateFileWatcher`, so, file descriptor is closed gracefully.

#### Context values

The last use case for context is to carry a key-value list -- `ctx := context.WithValue(parentctx, “key”, “value”)`Just like `context.Timeout`-- is created from a parent context, in this case, create a new `ctx`context containing the same characteristics as `parentCtx`but also conveying k-v.

```go
ctx := context.WithValue(context.Background(), "key", "value")
```

Note that the `key`and `value`s provided are `any`type. That could lead to collisions -- two functions from different packages could use the same string values as a key. Consequently, a best practice while handling context keys is to create an unexported custom type. LIke:

```go
type key string
const myCustomKey key = "key"
func f(ctx context.Context) {
    ctx = context.WithValue(ctx, "myCustomKey", "foo")
}
```

So the `myCustomKey`constant is unexported -- hence, there is no risk that another package using the same context could override the value that is already set. Even if another package creates the same based on a `key`, it will be a different key.

#### Catching a context cancellation

The `context.Context`type exports a `Done`method that returns a *receive-only* channel : `<-chan struct{}`. This channel is closed when the work associated with the context should be canceled. Fore:

- The `Done`related to a context created with `context.WithCancel`is closed when the `cancel`is called.
- `Done`channel related to a context with `context.WithDeadline`is closed when the deadline is expired.

One thing to note that the internal should be closed when a contxt is canceled or has met a deadline, instead of when it receives a specific value. This way, all the consumers will be notified once a context is canceled or a deadline is reached.

```go
func handler(ctx context.Context, ch chan Message) error {
    for {
        select{
        case msg:= <-ch:
            //...
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

## Early returns

Another thing to mention is that if you call `return`in your middlewre *before* u call `next.ServeHTTP`, then the chain will stop being executed and control will flow back upstream. A common use case for early return is authentication middleware which only allows execution of the chain to continue if a particular check is passed -- like:

```go
func myMiddleware(next http.Handler) http.Handler{
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if !isAuthorized(r) {
            w.WriteHeader(http.StatsForbidden)
            return
        }
        // otherwise, call the next handler in the chain
        next.ServeHTTP(w,r)
    })
}
```

### Request logging

Continue in the same vein and add some middleware to log HTTP requests -- Specifically, going to use the *information logger* that we created to record the IPAddress. Fore:

```go
func (app *application) logRequest(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		app.infoLog.Printf("%s - %s %s %s", r.RemoteAddr, r.Proto, r.Method,
			r.URL.RequestURI())
		next.ServeHTTP(w, r)
	})
}
```

It is a method against the `application`it also has access to the handler dependencies including the info logger. In the `routes()`method : `return app.logRequest(secureHeaders(mux))`

#### Panic Recovery

In a simple Go, when your code panics it will result in the applicaiton being terminated straight away. Go’s HTTP server assumes that the effect of any panic is isolated to the goroutine saving the active HTTP request. Specifically, following a panic our server will log a stack trace to the server err log. Unwind the stack for the affected goroutine, and close the underlying HTTP connection. `panic("oops, sth went wrong")`for this all we get is an emtpy response due to Go closing the underlying HTTP connection following the panic. so, this isn’t great experisence for the user, would be more appropriate and meaningful to send them a proper HTTP resposne with a *500 internal server error*. A neat way of doing this is to create some middleware which *recovers* the panic and calls our `app.serverError()`helper method.

```go
func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				app.serverError(w, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
```

- Setting the `Connection:Close`on the response acts a trigger to make Go’s HTTP server automatically close the current connection after a response has been sent. Also informs the user that the connection will be closed. And if the protocol being used is HTTP/2, Go will automatically strip the `Connection: Close`and send a `GOAWAY`frame.
- Note that the value returned by the built-in `receover()`has the type `any`.. we normalize this into an `error`by using the `fmt.Errorf()`function to create a new `error`object containing the default textual representation of the `any`value, and then pass this `error`to the `app.serverError()`helper method.

`return app.recoverPanic(app.logRequest(secureHeaders(mux)))`

#### Panic recoery in other background goroutines -- 

It’s important to realise that our middleware will only recover panics that happens in the *same goroutine* that execute the `recoverPanic()`middleware. So, if are spinning up additional goroutines from within your web app and there is any chance of an panic, must make sure that you recover any panics from withhin those too.

```go
func myHandler(w, r) {
    go func() {
        defer func() {
            if err := receover(); err != nil {
                log.Println(...)
            }
        }()
        doSomebackgroundProcessing()
    }()
    w.Write([]byte("OK"))
}
```

