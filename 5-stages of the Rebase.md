# 5-stages of the Rebase

This will walk you through the five stages of the rebase process. To provide a visual illustration -- 

1. Find the *common ancestor* -- Git will identify the common ancestor of the two branches involved in the rebase. In the rainbow, the branch your friend will be on is the local `main`in the friend repository and the branch they will be rebasing onto will be the `origin/main`. For this, the common ancestor will be the `M2`merge commit.
2. Store info about the branches involved in the rebase -- Git will save the changes introduced by each commit of the branch you are on to a temporary area. It will also save additional info in this temporary area, such as which branch you are rebasing onto and where it was pointing when initiating the rebase.
3. Will reset `HEAD`to point to the same commit as the branch you are rebasing onto. For this, the `origin/main`remote-tracking branch.
4. Apply and commit the changes -- Git will apply the set of changes from each commit in turn. First it will apply the changes introduced by the `black`commit, then apply the changes by the `rainbow`commit. And both make a new commit on it.
5. At last, Git will make the branch you rebased point to the last commit. `main`and `HEAD`point to this.

#### Rebasing and Merge Conflicts

Note that Git will carry out the entire rebase process independently, unless it encounters merge conflicts, in this case, must step in and resolve them. In the process of rebasing, as git applies changes from each commit one by one, it will pause the process if it encounters merge conflicts in any reapplied commit.

Once done, need to add the updated files to the staging area and then instruct Git to resume the rebase process by entering the `git rebase`with the `--continue`option. As with a merge, if at any point during the process of resolving merge conflicts in a reabase you decide you don’t want to continue the rebase:

```sh
git rebase --continue # continue with rebase process after having resolved merge conflicts
git rebase --abort # stop the rebase process and go back state before the rebase
```

#### In practice

```sh
# in the friend-rainbow, make a note of the commit hashes for the black commit and rainbow commit
# rainbow: ee52c453
# black: 08d0c72
git rebase origin/main # error could not apply black...and othercolors.txt file
git status #
```

- The rebase operation was interrupted cuz when Git was applying the changes that were included in the black, it encountered a merge conflict
- `git status`shows you info about the rebase and which file you need to resolve. So:

```sh
# carry out step 1 of resolving merge conflicts, which is to choose what to keep. then:
git add othercolors.txt
git status
git rebase --continue # accpet the default commit message in the vim
git log
```

For this, the `git status`output informs you all conflicts are fixed. run `git rebase --contsinue`, and in step 6, the `git log`indicaets that the rebase process created a new rainbow commit and a new black commit. For this:

- Represent the new black commit and the new commit as Bl’ and Ra’
- In the friend repository, the gray commit, the new black and new rainbow from a linear proj history.

#### The Golden Rule of rebasing

Reabasing creates entirely new commits, this means that rebasing changes the commit history. U *MUST* always be careful when U change the commit history cuz it can lead to complications in your project. And the golden rule of rebasing states that you *should not* rebase branch that other people may have based work on.

States that -- *you should not rebase a branch that other people may have based work on* -- if have pushed a branch to the remote, then it is considered a public branch -- This means other collaborators may also be working on this branch in their local repositories.

#### Syncing the Repositories

To make sure the repositories in the Rainbow proj are in syc, your friend will have to push their changes to the remote repository and you will have to pull the changes down into the `rainbow`like:

```sh
# in the friend:
git push
# then in the rainbow
git pull
git log
```

Rebasing -- is the second way of integrating changes from one branch to another in Git -- and how it can be used to avoid 3-way merges and merge commits. Also leaned about the 5-stages of the rebase process that Git carries out,. Note that rebasing rewrites the commit history, Golden rule of rebasing -- which states that you **should not** rebase braches that other collborators have based work on. Additionally, you learned how to unstage files, or moreve modified files from the staging area.

## Channels

The last guarantee -- a receiver from an unbuffered channel happens before the sned on that channel completes.

```go
i := 0
ch := make(chan struct{})
go func(){
    i = 1 // 1
    <-ch  // 2
}()
ch <- struct{}{} // 3
fmt.Println(i) // 4
```

For this, the write is guaranteed to happen before the read. Here is why a receive from an unbuffered channel happens before the send that channel completes -- 

- Unbuffered are sync -- Cuz -- have no capacity to hold any values -- thie means that both the sender and receiver must be *ready* at the exact same time for communication to occur.
- Blocking behavior -- When a goroutine tries to send a value on an unbuffered, blocks, until another recieve.

### Concurrency impacts of a workload type

Looks at the impacts of a workload type in a concurrent imp -- Depending on whether a workload is CPU - or I/O bound, may need to tackle the problem differently -- In programming, the execution time of workload is limited by one of the following -- 

- *The speed of the CPU* -- running a merge sort alg fore
- *The speed of I/O*
- *The amount of available memory* -- called *memory-bound* fore this

Why is it important to classify a worload in the context of a concurrent app -- Worker pooling -- Fore:

```go
func read(r io.Reader) (int, error) {
    count := 0
    for {
        b := make([]byte, 1024)
        _, err := r.Read(b)
        if err != nil {
            if err == io.EOF {
                break
            }
            return 0, err
        }
        count += task(b)
    }
    return count, nil
}
```

For now, what if we want to run all the `task`func in a parallel manner -- One option is to use *worker-pooling* pattern. Doing so involves creating workers of a fixed size that poll tasks from a common channel. First, spin up a fixed pool of goroutines -- Then, create a shared channel to whcih publish tasks after each read to the `io.Reader`.

```go
func reader(r io.Reader) (int, error) {
    var count int64
    wg := sync.WaitGroup{}
    var n = 10
    ch := make(chan []byte, n)
    wg.Add(n)
    for i:=0; i<n; i++ {
        go func() {
            defer wg.Done()
            for b := range ch {
                v := task(b)
                atomic.AddInt64(&count, int64(v))
            }
        }()
    }
    
    for {
        b:= make([]byte, 1024)
        ch <-b // read from r to b
    }
    close(ch)
    wg.Wait()
    return int(count), nil
}
```

### Combining multiple channels

How can we have one goroutine respond to messages, coming from different goroutines over multiple channels -- Go’s `select`statement lets us specify multiple channel operations as separate cases and then execute a case depending on whcih channel is ready.

#### Reading from multiple channels

Don’t know on which channel the next message will be received -- the `select`statement lets us group read operations on multiple channels together, blocking the goroutine until a message arrives on any one of the channels. Once a message arrives on any of the channels, the goroutine is unblocked -- and a code handler for that channel is run, can then decide what else to do. Fore, have a function that creates an anonymous goroutine that periodically sends a message on a channel. The period is specified by the `seconds`input variable like:

```go
func writeEvery(msg string, seconds time.Duration) <- chan string {
    messages := make(chan string)
    go func() {
        for{
            time.Sleep(seconds)
            messages <- msg
        }
    }()
    return messages
}
```

And, channels are *first-class* objects, which means that we can store them as variables, pass or return them. Then demonstrate the `select`by calling the `writeEvery()`twice. End up with two channels and two goroutines sending messages at different times -- like:

```go
func main(){
    messagesFromA := writeEvery("Tick", 1*time.Second)
    messagesFromB := writeEvery("Tock", 3*time.Second)
    
    for {
        select {
        case msg1:= <-messagesFromA:
            print(msg1)
        case msg2:= <-messagesFromB:
            print(msg2)
        }
    }
}
```

Note -- when using `select`, if multiple cases are ready, a case is chosen *at random*.

#### Using select for non-blocking channel operations

Another use case for `select`is when we need to use channels in a non-blocking manner. Go provides a *non-blocking* `tryLock()`operation -- this func will tries to acqure the lock, but if the lock is being used, it will return immediately with a `false`return value. For this, can adopt this pattern for channel operations -- try to read a message from a channel, then if no messages are available, instead of blocking, can we have the current execution work on a default set of instruction -- like: The `select`gives us the *default* cases for exactly this scenario -- the instructions under the default case will be executed if none of the other cases is available. Fore:

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
    messages := sendMsgAfter(3* time.Second)
    for {
        select {
        case msg:= <-messages:
            fmt.Println(msg)
            return
        default:
            fmt.Println("no messages waiting...")
            time.Sleep(time.Second)
        }
    }
}
```

Since we have the `select`in a loop, the default case will be executed over and over again...

#### Performing concurrent computations on the default case

A useful scenario is to use the default select case for concurrent computations and then use a channel to signal when we need to stop.

```go
const (
	passwordToUse = "go far"
	alphabet      = " abcdefghijklmnopqrstuvwxyz"
)

func toBase27(n int) string {
	result := ""
	for n > 0 {
		result = string(alphabet[n%27]) + result
		n /= 27
	}
	return result
}
```

Every time, would check to see whether it matched with the variable `passwordToGuess`-- in a real-life scenario, wouldn’t have the value of the pwd, would try to gain access to our resource using each string enumeration as the pwd. And to find our pwd faster, divdie the range of our guresses among several goroutines. And to avoid unnecssary computations, want to stop the execution of each goroutine when any goroutine makes a correct guess. To achieve this, can use a channel to notify all other goroutines when one execution discovers the pwd -- can use the `close()`operaiton on a channel to act like a signal being broadcast to all consumers.

So, how can we implement the logic to stop processing in all goroutines after a common channel is closed -- one solution is to perform the necessary computation in the `select`'s default case and then have another case waiting on the common channel. In the example, call the `toBase27()`and try to guess pwds in the default case, each time guessing just one, can have the logic to stop generating and trying pwds in a spearate `select`'s `case`.

```go
func guessPassword(from int, upto int, stop chan int, result chan string) {
	for guessN := from; guessN < upto; guessN++ {
		select {
		case <-stop:
			fmt.Printf("Stopped at %d [%d,%d]\n", guessN, from, upto)
			return
		default:
			if toBase27(guessN) == passwordToUse {
				result <- toBase27(guessN)
				close(stop)
				return
			}
		}
	}
	fmt.Printf("Not found between [%d,%d]\n", from, upto)
}
```

Can now create severall goroutines executing the previous -- each goroutine will try to find the correct pwd within a certain range -- the `main()`creates the necessary channels and starts all the goroutines with their input ranges in steps of 10M. like:

```go
func main() {
	finished := make(chan struct{})
	passwordFound := make(chan string)
	for i := 1; i <= 387420488; i += 10000000 {
		go guessPassword(i, i+10000000, finished, passwordFound)
	}
	fmt.Println("Pwd found:", <-passwordFound)
	close(passwordFound)
	time.Sleep(5 * time.Second)
}
```

After starting up all the goroutines, the `main()`waits for an output message on the `passwordFound`channel. Once a goroutine discovers the correct pwd, it will send the pwd on its `result`to the `main()`.

## Custom template functions

In the last part of this section about templating and dynamic data -- like to explain how to create our own custom functions to sue in Go templates -- Fore, create a custom `humanDate`which outputs datetimes in a nice format. There are two main steps to doing this -- 

1. need to create a `template.FuncMap`object containing the custom function
2. need to use the `template.Funcs()`method to register this **before parsing** the templates.

```go
func humanDate(t time.Time) string {
	return t.Format("02 Jan 2006 at 15:04")
}

// Initialize a template.FuncMap object and store it in a global variable. 
// a string-keyed map which acts as a lookup between the names of our custom
var functions = template.FuncMap{
	"humanDate": humanDate,
}
// ...
ts, err := template.New(name).Funcs(functions).ParseFiles(
			"./ui/html/base.html")
```

Custom template functions can accept as many parameters as they need to, but they *must* return one value only. The only execption to this is if you want to return *an error* as the second value.

Now we can use the `humanDate()`function in the same way as the built-in template funcs like:

```html
<tr>
    <td><a href="/snippet/view?id={{.ID}}">{{.Title}}</a></td>
    <td>{{humanDate .Created}}</td>
</tr>
```

#### Pipelining

In the code, just called our custom template functions like:

```html
<time>Created: {{humanDate .Created}}</time>
```

An alternative approach is to use the `|`character to pipeline values to a function -- this works as a bit like pipelining outputs from one command to another like:

```html
<time>Created: {{.Created | humanDate}}</time>
```

And a nice feature of pipelining is that you can make an arbitrary long chain of template functions which use the output from one as the input for the next.

```html
<time>{{.Created | humanDate | printf "Created: %s"}</time>
```

### Middleware

When are building a web app there is probably some shared functionality that U want to use for many HTTP requests, fore, might want to log every request, compress every, or check a cache. A common way of *organizing this shared functionality* is to set it up as *middleware* -- That is essentially some self-contained code which indpendently acts on a request before or after your normal app handlers.

- An idiomatic pattern fro building and using custom middleware which is compatible with `net/http`and many 3rd-party packages
- How to create a middleware which sets useful security headers on every HTTP response.
- Logs the requests
- Recovers panics
- Composable middleware chains

How middleware works -- You can just think of a Go web app as a chain of `ServeHTTP()`methods based called one after another. The basic idea of Go middlewre is to insert another hander into the chain. The middleware handler executes some logic, like logging.. then calls the `ServeHTTP()`of the next handler in the chain.

Fore the `http.StripPrefix()`func, which removes a specific prefix from the request’s URL path.

#### The pattern

The std pattern for creating your own middleware like this -- 

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        // todo: execute logic of middleware
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

- The `myMiddleware()`is essentially a wrapper around the `next`
- It establishes a function `fn`which closes over the `next`handler to form a closure. And when `fn`is run it executes our middleware logic and then transfers control to the `next`by calling it’s `ServeHTTP()`.
- Regardless of what you do with a closure, will always be able to access the variables that are local to the scope it was created in .

Simplifying the middleware -- just like:

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
        //... Todo
        next.ServeHTTP(w,r)
    })
}
```

#### Positioning the middleware

It’s important to explain that were you position the middleware in the chain of handlers will affect the behavior of your application -- If position your middleware before the `servemux`in the chain then it will act on every request that your app receives. fore `myMiddleware`-> servemux -> application handler. Alternatively, can also position the middleware after the servemux in the chain. `servemux`-> myMiddleware -> handler

### Setting security headers

Put the pattern -- make our own middleware which automatically adds the following HTTP security headers to every response -- like: current OWASP guidance.

- `Content-Security-Policy`-- CSP -- restrict where the resources for web apge can be loaded from. Setting a strict CSP policy prevent a variety of cross-site scripting. clickjacking, and other code-injection attacks. CSP headers and how they work is a big topic, recommand reading
- `Referring-Policy`-- is used to control what information is included in a `Referer`header when a user navigates away from your web page. In the case, set the value to the `origin-when-cross-origin`-- which means that the full URL will be included for `same-origin`requests, but for all other like URL path and any query string values will be stripped out.
- `X-Content-Type-Options: nosniff`instructs browsers to not MIME-type sniff the content-type of the response, which in turn helps to prevent attacks.
- `X-Frame-Options: deny`-- is used to help prevent clickjacking attacking.
- `X-XSS-Protection:0`-- is used to disable the blocking of cross-site scripting attacks.

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

Cuz we want this middleware to act on every request that is received, need it to be executed before a request hits our servemux. Want the flow of control through our application to look like:

secureHeaders-> servemux -> app handler, So to do this need the `secureHeaders`middleware to *wrap our servemux* -- update the `routes.go`file to do exactly that like:

```go
func (app *application) routes() http.Handler {
	mux := http.NewServeMux()
	// ...fore, fileServver...
	
	// pass the servemux as the next parameter to the secureHeaders() middleware.
	return secureHeaders(mux)
}
```

Flow of control -- It’s important to know that when the last handler in the chain returns -- control is passed back up the chain in the reverse diretion. just like:

secure->mux->handler->mux->secure.