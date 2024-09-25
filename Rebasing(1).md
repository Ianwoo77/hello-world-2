# Rebasing(1)

The D’ commit represents the new version of commit D that was created during the rebase process, it includes all the changes I made in the original D commit, but it has an entrely new commit with a new commit hash. By rebasing my branch I’m able to maintain a linear commit history and avoid making additional merge commits. Also note that the original D commit still exists in the commit history -- it is no longer part of any the branches in the `book` -- which is why it is not shown.

```sh
# make same change in the `rainbow` proj
git add readme.md
git commit -m "gray"
git push
git log
```

Next, friend will add some work in the `friend-rainbow`repository on the same branch, which will lead to divergant histories between your main branch and your friend’s main branch.

### Unstaging and Staging files -- 

In this, your friend is going to make changes to both of the files in the friend repository and add them both to the staging area. They will realize they want to make two separate commits for the different pieces of work.

In Git, you can use the unstage feature to remove files from the staging area without losing the changes made to the file -- this is useful if you accidentally stage a file or decide you don’t want to commit it yet.

When it comes to git and vesion control, one of the most common challenge is how to revert an action. In this, you are going to learn how to add and remove files from the staging area consequently preventing them from being committed. Adding files to staging area is also referred to as *staging* while *unstaging* is also another term for removing files from the staging area.

#### What is the staging Area

Is like a temporary stroage which sits between your working directory and committed history. In order to commit changes to the commit history, files have to be added to the staging area first. And in Git, the working dirctory -- or working area is the directory on your *local* file system where U actively make changes to files in your project before staging and committing them.

#### Why reverting a `git add`may be Necessary

1. Accidental staging -- may have inadvertently staged changes U didn’t intend to commit
2. Selective commits -- to ensure that only specific changs or files are included in your commit
3. re-evaluation -- sometimes, U may want to re-consider whether certain change should be part of the next commit before finalizing your decision.
4. Collaboration and Oranisation -- when collaborating with others, you can unstage changes to avoid pushing unintended chaneges to a shared repository.

Now hat have an ieda of why it is important to know how to unstage a file from the staging area, ready to practice unstaging a file in the `Rainbow`proj. Focus on the `friend-rainbow`repository in the visualize it diagrms.

For the `friend-rainbow`repository, the current version of the `readme.md`and `othercolors.txt`file that are in the working dirctory and staging area represented as vA.

```sh
# edit the friend-rainbow's othercolors.txt
git status
```

For now, edited both files.

## Using errgroup

`golang.org/x`is a repository providing extensions to the stdlib -- the `sync`contains a handy package `errgroup`-- for this, suppose we have to handle a function, and we receive as arg some data that we want to use to call an external service -- Due to constraints, can’t make a single call. Make multiple calls with a different subset each time. Also, make them in parallel.

```go
func handler(ctx context.Context, circles []Circle) ([]Result, error) {
	results := make([]Result, len(circles))
	wg := sync.WaitGroup{}
	wg.Add(len(results))
	for i, circle := range circles {
		i := i
        // for these, creates a new variable used in the for loop about the goroutine
		circle := circle
		go func() {
			defer wg.Done()
            // Simulate heavy computation
            result, err := foo(ctx, circle)
			if err!= nil {
				//?
			}
			results[i] = result
		}()
	}
	wg.Wait()
	// ...
}
```

For this, decided to use a `sync.WaitGroup`to wait until all the goroutiens are completed and handle the aggregations in a slice. What if the `foo()`returns an error -- how should we handle it.

- Just like the `results`slice, could have a slice of errors shared among the goroutines -- each goroutine would write to this slice in case of an error. We could have to iterate over this slice in the parent goroutine to determine whether an error occurred.
- could have a single error variable accessed by the goroutine via a shared mutex fore
- could think about sharing a channel of errors, and the parent goroutine would receive and handle these errors.

Regardless of the option chosen, it starts to make the solution pretty complex -- for that reason, `errgroup`package was designed and developed -- It exports a single `WithContext()`returns a `*Group`struct given a context. This struct provides synchronization, error propagation, and context cancellation for a group of goroutines and exports only two methods -- 

- `Go`trigger a call in a new goroutine
- `Wait`to block until all the goroutines have completed.

```go
func handler(ctx context.Context, circles []Circle) ([]Result, error) {
    results := make([]Result, len(circles))
    g, ctx := errgroup.WithContext(ctx)
    for i, circle := range circles {
        i := i
        circle := circle
        g.Go(func() error {
            result, err := foo(ctx, circle)
            if err != nil {
                return err
            }
            results[i]=result
            return nil
        })
    }
    if err := g.Wait(); err != nil {
        return nil, err
    }
    return results, nil
}
```

```go
func main() {
	g, _ := errgroup.WithContext(context.Background())
	tasks := []func() error{
		func() error {
			fmt.Println("Task 1")
			return nil
		},
		func() error {
			fmt.Println("Task 2")
			return nil
		},
		func() error {
			fmt.Println("Task 3")
			return fmt.Errorf("Task 3 failed")
		},
	}

	// launch each task in a separate goroutine
	for _, task := range tasks {
		task := task
        // use g.Go() to launch each task in a separate goroutine
		g.Go(func() error {
			return task()
		})
	}

	// wait for all tasks to finish
	if err := g.Wait(); err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("All tasks completed successfully.")
	}
}
```

This solution is inherently more straightworward than the first -- don’t have to rely on extra concurrency primitives, and the `errgroup.Group`is sufficient to tackle our use case.

And another benefit what we haven’t tackled yet is the shared context -- fore, imagine we have to trigger 3 parallel calls-- 

- The first returns an error in 1 ms
- The 2nd and 3rd calls return a result or an error in 5s

Want to return an error -- there is no point in waiting until the 2nd and 3rd calls are completed. So, using `errgroup.WithContext`creates a shared context used in all the parallel calls.

### Don’t Coying a `sync`type

The `sync`packae provides basic synchronization primitives such as mutexes, condition variables, and wait groups -- For all these types, there is a *hard* rule to follow -- **they should never be copied** -- 

Create a thread-safe data structure to store counters -- will just contain a `map[string]int`reresenting the current value for each counter, will also use a `sync.Mutex`cuz the accesses have to be protected, like:

```go
type Counter struct {
    mu sync.Mutex
    counters map[string]int
}

func NewCounter() counter {
    return Counter {counters: map[string]int{}}
}
func (c Counter) Increment (name string){
    c.mu.Lock()
    defer c.mu.Unlock()
    c.counters[name]++
}
```

For this, the increment logic is done in a CS. if:

```go
counter := NewCounter()
go func() {
    counter.Increment("foo")
}()
go func() {
    coutner.Increment("bar")
}()
```

If run with `-race`, raises a data race -- The problem in our `Counter`imp is that the *mutex is copied*. Cuz the receiver of `Increment`is a value, whenever we call the `Increment`, it performs a copy of the `Counter`struct, which also copie the mutex, therefore, the increment isn’t done in a shared CS.

`sync`types shouldn’t be copied -- this rule applies to the following types -- `sync.Cond, Map, Mutex, RWMutex, Once, Pool, WaitGroup`-- therefore, the increment isn’t done in a shared critical section.

Therefore, the mutex shouldn’t have been copied -- what are the alternatives -- first is to modify the receiver type for the `Increment()`method -- 

```go
func (c *Counter) Increment(name string) {...}
```

Changing the receiver type avoids copying when `Increment() `is called; And if we want to just keep a value receiver, the second option is to change the tpye of the `mu`field fore:

```go
type Counter struct {
    mu *sync.Mutex
    ...
}
func NewCounter() Counter  {
    return Counter {
        mu: &sync.Mutex{}
        counters: map[string]int{},
    }
}
```

May face the issue of unintentionally copying a `sync`field in the following conditions -- 

- Calling a method with a value receiver
- Calling a function with  `sync`argument
- Calling a function wtih an argument that contains a `sync`field.

As a rule of thumb, whenever multiple goroutines have to access a common `sync`, must ensure that they all rely on same instance. this rule applies to all the types defined in the `sync`package.

## CSRF protection

In this, look how to protect our app from *cross-site request forgery* attacks -- A great explanation of the basic CSRF -

- A user logs into our app, our session cookies is set to persists for 12 hours fore, so remain logged.
- The user got to a malicious website fore -- which contains some code that sends a cross-site request to our `POST /snippet/create`endpoint add a new snippet to our dbs. the session cookie will be sent along with this request.
- Cuz the request includes the session cookie, our app will interpret the request as coming form a logged-in user.

To protect generally -- 

1. CSRF Tokens -- Include a unique unpredictable token with each request that modifies state. this token is tied to the user’s session and must be validated by the server like:

   ```html
   <form method="post" action="/transfer">
       <input tpye="hidden" name="csrf_token" value="unique_token_here">
       <input type="submit" value="transfer">
   </form>
   ```

2. `SameSite`cookies -- use the `SameSite`attribute for cookies to prevent them from being sent along with requests:
   `Set-Cookie`: sessionId=abc123; SameSite=Strict

3. Custom Request headers -- fore APIs, use custom headers that are not automatically sent by browsers

   ```js
   fetch('.../endpoint' , {
       method: 'POST',
       headers : {
           'X-CSRF-Token', 'unique_token_here'
       },
       body: JSON.stringify(data)
   });
   ```

And the `SameSite=lax`attribute for cookies is a secruity measure that helps mitigate CSRF attcks -- when a cookies is set with `SameSite=lax`-- will only be sent with request initiated from the same site.

### Token-based mitigation

To mitigate the risk of CSRF for all users we will also need to implement some form of *token check* -- like session management and password hashing, when it comes to this there is a lot that you an get wrong so it’s probably safer to use a tried-and-tested 3rd-party package instead of rolling your own imp.

The two most popular packages for stopping CSRF attacks in Go web apps are `gorilla/csrf`and `justinas/nosurf` -- they both do roughly the same thing, using the *double-submit cookie* -- pattern to prevent attacks. In this pattern a random CSRF token is generated and sent to the user in a CSRF cookie -- this CSRF token is then added to a hide field in each HTML form that is vulnearble to CSRF. When the form is submitted, both packages use some middleware to check that the hidden filed value and cookie value match.

Out of the packages -- opt ot use `justinas/nosurf`in this -- perfer it primarily cuz it is self-contained and doesn’t have additional dependencies -- like:

```sh
go get github.com/justinas/nosurf
```

#### Using the nosurf pacakge

To use this, open and create a new `nosurf()`middleware func like:

```go
func noSurf(next http.Handler) http.Handler {
	csrfHandler := nosurf.New(next)
	csrfHandler.SetBaseCookie(http.Cookie{
		HttpOnly: true,
		Path: "/",
		Secure: true,
	})
	return csrfHandler
}
```

One of the forms that we need to protect from CSRF attacks is our logout form, which is included  in our `nav.html`partial and could potentially appear on any page of our application. So cuz of this, need to use our `nosurf()`middleware on all of our app routes -- like:
`dynamic := alice.New(app.sessionManager.LoadAndSave, noSurf)`

At this point, might like to fire up the applicaton and try submitting one of the forms, when so, the request should be intercepted by the `noSurf()`middleware and you should receive a 400. When submitting forms, 400 returned.

To make the form submissions work, need to use the `nosurf.Token()`function to get the CSRF token and add it to a hidden `csrf_token`field in each of our forms. So the next step is to add a new `CSRFToken`to our `templateData`like:

```go
type templateData struct {
	//...
	CSRFToken       string
}
```

And, cuz the logout form can potentially appear on every page, it makes sense to add the CSRF token to the tempalte data automatically via `newTemplateData()`helper -- this will mean that it’s avaialble to our templates each time we render a page -- like:

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
	return &templateData{
		//...
		CSRFToken:       nosurf.Token(r),
	}
}
```

Finally, need to update all the forms in our app to include this CSRF token in a hidden filed like:

```html
<!-- include the CSRF token -->
<input type="hidden" name="csrf_token" value="{{.CSRFToken}}">
```

And in the `login.html`, `signup`and `nav`html files.
`<input type="hidden" name="csrf_token" value="{{.CSRFToken}}">`

#### SameSite Strict setting

If u want, can change the session cookie to use the `SameSite=Strict`setting instead of the default `sameSite=lax`. But it’s important to be aware that using `SameSite=Strict`will block the session cookie being sent by the user’s borwser for all *cross-site* usage.

### Using request context

At the moment our logic for authenticating a user consists of simply checking whether a `authenticatedUserID`value exists in their session data, like -- 

```go
func (app *application) isAuthenticated(r http.Request) bool {
    return app.sessionManager.Exists(r.Context(), "authenticatedUserID")
}
```

We could make this check more robust by querying our `users`database table to make sure that the `authenticatedUserID`value is a real, valid, value.

But there is a slight problem with doing this additional dbs check -- our `isAuthenticated()`helper can potentially be called multiple times in each request cycle -- For now, twice -- so, if query the dbs from the `isAuthenticted()`directly, could end up making duplicated round-trips to the dbs during every request. And that is not efficient -- A better approach would be to carry out this check in some middleware to determine whether the current reques is from an authenticated user or not, and then pass that info down to all subsequent handlers in the chain.

- What request context is, how to use it, and when it is appropriate to use it
- How to use request context in practice to pass information about the current user between your handlers.

#### How request context works

Every `http.Request`that our middleware hand handlers process has a `context.Context`object embedded in -- which can use to *store info* furing the lifetime of the request. In a web app a common use-case for this is to pass info between your pieces of middleware and other handlers.

Want to use it to check if a user is authenticated once in some middleware, and if they are, then make this info avaiable to all our other middleware and handlers. Start with some theory and explain the syntax for working with request context. Then in thenext get a bit more concrete again and demonstrate how to practically use it.

#### The request context syntax

The basic code for adding info to a request’s context like:

```go
ctx := r.Context() // r is a *http.Request
ctx = context.WithValue(ctx, "isAuthenticated", true)
r = r.WithContet(ctx)
```

