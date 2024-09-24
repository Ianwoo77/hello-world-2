# Syncing the Repositories

For all the repositories to be in sync, your friend will need to push the new commits on their local `main`branch to the remote repository, and you will need to pull down all the changes in your local `main`branch in the `rainbow`.

```sh
git push
git log
# then switch to the rainbow
git pull
git log
```

For now, all three repositoies in the `Rainbow`project are now in sync.

## Rebasing 

Git offers two main ways to integrate chagnes from one branch to another, merging and rebasing -- Will learn about the rebasing and walk through an example -- introduce the *5 stages* of the rebase process and shows you how ot resovle merge conflicts during this process. Look at how merging and rebasing differ, and in which cases you may prefer to rebase instead of merge. Also introduce the golden rule of rebasing, which will help U determine when not to rebase.

### Integrating changes in Git

Can see that up until the green commit you had a liner project history, and after the green commit the commit history is non-linear dut to the merge commits created by the 3-way merges. Some teams and individuals prefer to maintain a linear project history cuz they find it is more organzied and simpler. Can use the process of rebasing to a*void 3-way merges* and merge commits and maintain a *linear* project history.

Rebasing takes all the work you have done in the commits on one branch and reapplies the work on another branch, creating *entirely new commits*. This can make it appear as though U have created a branch from an entirely different commit than the original commit U created it from.

To carry out a rebase, you need to be on the branch you want to rebase. Use the `git rebase`command and pass in the name of the branch that you want to rebase onto.

```sh
git rebase <branch_name> # reapply commits on top of *another* branch
```

Given that rebasing creates *entirely* new commits, this means it changes the *commit history*.

#### Why is Rebasing helpful

To illustrate how rebasing can help you avoid the 3-way merges and maintain a linear project history -- When decide that my changes to CH5 are ready to be merged into my local `main`branch, now have a couple of options. For the `book`repository -- fetch the changes on the remote `main`from the remote repository and then do a 3-way merge to merge ch5 into the main.

Another option is to pull the changes from the remote repository, which means my local `main`will update to point to the commit C with the intent of rebasing my branch afterward. Next, can *rebase* my ch5 branch on top of the updated `main`branch -- rebasing will take all the commits have made on the ch5 branch and reapply them onto the `main`. When the branch is rebased, a new `D`commit will be just created. A<-B<-C-D’ -- C from remote repostiory.

The D’ commit just represents the new version of the commit D that was creted during the rebase process. It includes all the changes I made in the original D comit, it is an entirely new commit with a new commit hash. After have rebased CH5 branch, then merge main into main with a simple fast-forward.

So by rebasing my branch I am able to maintain a linear commit history and avoid making additional merge commits. Need to note that the original D commit still exists in the commit history, However, it is no longer part of any of the branches in the `book`repository. Rebasing a branch doesn’t delete the commits on the branch. It simply re-creates them. The old commits still exist in the commit history.

### Setting up the Rebasing Example

To practice rebasing, you will need to create divergent histoires, are going to make one commit in the `rainbow`repository and push it to the remote repository -- then your friend, without fetching the changes from the remote repository, is going to make two commits in their `friend-rainbow`repository.

```sh
# edit the readme.md file
git add readme.md
git commit -m "gray"
git push
git log # gray commit
```

Next, your friend will add some work in his own repository on the same branch, which will lead to divergant histories between your `main`and your friend’s `main`.

#### Unstaging and staging files

In this section, your friend is going to make changes to both of the files in the `friend-rainbow`and add them both to the staging area. Then they will realize they want to make two separate commits for the different pieces of work. Fore, want only the changestaht I made in ch2 to be included in my next commit.

Have an idea of why it is important to know how to unstage a file from the staging area.

For the friend repository -- the current versions of the `readme.md`and othercolors.txt that are in working directory and staging area are represented as versionA. If U want to unstage a specific file that has been added to the staging aread, can use the `--staged`option like:

```sh
git restore --staged <file_name>
```

## Using `sync.WaitGroup`correctly

This is a mechanism to wait for `n`operations to complete -- generally, we use it to wait for `n`goroutiens to complete. First recall the public API, when will look at a pretty frequent mistake leading to non-deterministic behavior. 

`wg := sync.WaitGroup{}`

Internlly, a `sync.WaitGroup`holds an internal counter initialized by default to 0, can increment this counter using the `Add(int)`method and decrement is using `Done()`or `Add(-1)`. If want to wait for the counter to equal to 0, have to use the `Wait()`that is blocking.

```go
wg := sync.WaitGroup{}
var v int64
for i:=0; i<3; i++ {
    go func() {
        wg.Add(1)
        atomic.AddUnit64(&v, 1)
        wg.Done()
    }()
}
wg.Wait()
print(v)
```

Note -- if run this, will get non-deterministic value -- 0~3 any value. Cuz the `wg.Add(1)`called within the newly created goroutine -- not in the parent goroutine -- hence, there is no guarantee that we have indicated to the wait group that want to wait for 3 goroutines before calling `wg.Wait()`.

When dealing with goroutines, it’s just crucial to remember that the execution isn’t deterministic without sync. The CPU has to use a *memory fence* -- to ensure the order. Go provides different sync techniques for implementing memory fences. fore, `sync.WaitGroup()`enables a happens-before relationship between `wg.Add`and `Wait`. 

```go
wg := sync.WaitGroup{}
var v uint64
wg.Add(3)
for i:=0; i<3; i++ {
    go func(){...}()
}
// or call wg.Add during each loop iteration
for i:=0; i<3; i++ {
    wg.Add(1)
    go func()...
}
```

### About the `sync.Cond`

Among the synchronization promitives in `sycn`, `sync.Cond`is probabley the least used and understood - it provide features that we can’t achieve with channels.

An app that raises alerts whenever specific goals are reached -- we will have one goroutine in charge of incrementing a balance. In contrast, other gorouines will receive updates and print a message *whenever a specific goal is reached*. Fore, one goroutine is waiting for a $10 goal -- one first naive solution uses mutexts -- the updater goroutine increments the balance every second, on the other side, the listener goroutiens loop until their donation goal is met.

```go
func main() {
	type Denation struct {
		mu      sync.RWMutex
		balance int
	}
	denotaion := &Denation{}

	// listener goroutines
	f := func(goal int) {
		denotaion.mu.RLock()
		for denotaion.balance < goal {
			denotaion.mu.RUnlock()
			denotaion.mu.RLock()
		}
		fmt.Printf("$%d goal reached\n", denotaion.balance)
		denotaion.mu.RUnlock()
	}
	go f(10)
	go f(15)
	go func() {
		for {
			time.Sleep(time.Millisecond)
			denotaion.mu.Lock()
			denotaion.balance++
			denotaion.mu.Unlock()
		}
	}()
	time.Sleep(time.Second)
}
```

For this the main issue - and what make this terrible implementation -- the the busy loop -- Each listener goroutine keeps looping unti its donation goal is met -- which wastes a lot fo CPU cycles and makes the CPU usage gigantic, need to find a better solution -- For this, have to find a way to signal from the updater goroutine whenevr the balance is updated. If think about the signaling in Go -- should consider channels -- so can be:

```go
func main() {
	type Denation struct {
		ch      chan int
		balance int
	}
	donation := &Denation{ch: make(chan int)}

	f := func(goal int) {
		for balance := range donation.ch {
			if balance >= goal {
				fmt.Printf("$%d goal reached\n", balance)
				return
			}
		}
	}
	go f(10)
	go f(15)
	go func() {
		for {
			time.Sleep(time.Millisecond)
			donation.balance++
			donation.ch <- donation.balance
		}
	}()
	time.Sleep(time.Second)
}
```

For this, each listener goroutine receives from a shared channel. Meanwhile, the updater goroutine sends messages whenever the balance is updated -- Each listener goroutine receives from a shared channel -- meanwhile, the updater goroutine sends messages whenever the blanace is updated. 

A message sent to a channel is *received by only one goroutine*, in our example, if the first goroutine receives from the channel before the second on. And the default distribution mode with multiple goroutines. But here we don’t want to close the channel.

Ideally, need to find a way to repeatedly broadcast notifications whenever the balance is updated to multiple gorouines. Go has a solution -- `sync.Cond`-- Cond implements a condition variable, a rendezvous point for goroutines waiting for or announcing the occurence of an event.

A condition variable is a container of threads -- waiting for a certain condition -- In the example, the condition is just a balance update -- the update goroutine broadcsts a notifcation whenever a balance is updated. Furthermore, `sync.Cond`relies on a `sync.Locker`, to *prevent data races*. like:

```go
func main() {
	type Denation struct {
		cond    *sync.Cond
		balance int
	}
	donation := &Denation{cond: sync.NewCond(&sync.Mutex{})}

	f := func(goal int) {
		donation.cond.L.Lock()
		for donation.balance < goal {
			// waiting between Lock
			donation.cond.Wait()
		}
		fmt.Printf("%d goal reached\n", donation.balance)
		donation.cond.L.Unlock()
	}
	go f(10)
	go f(15)
	go func() {
		for {
			time.Sleep(time.Millisecond)
			donation.cond.L.Lock()
			// increment between lock
			donation.balance++
			donation.cond.L.Unlock()
			//broadcast balance updated
			donation.cond.Broadcast()
		}
	}()
	time.Sleep(time.Second)
}
```

For this, create a `*sync.Cond`using `sync.NewCond()`and provide a `*sync.Mutex`-- what about the listener and updater goroutines -- The listener goroutine loop until the donation balance is met. wtihin the loop, use the `Wait()`that blocks until the condition is met. Note that hte call of the `Wait()`must happen with a *Critical section*. Cuz the implementation of the `Wait`is 

1. Unlock the mutex
2. Suspend the goroutine and wati for a notification
3. Lock the mutex when notificatino arrives.

This way, all the accesses to the shared `donatation.balance`should also be protected. Then call the `Broadcast()`method -- which wakes all the goroutines waiting on the condition each time the balance is updated.

So in our implementation, the condition variable is based on the blanace being updated. Therefore, the listener variagbles wake each time a new donation is made, to check whether their donation goal is met. Can wake just one goroutine using the `Signal()`method.

### Using errgroup

Regardless of the programming language, reinventing the wheel is rarely a good idea, it’s also pretty common for codebases to reimpelment how to spin up mutliple goroutines and aggregate the errors. But a package in the Go ecosystem is designed to support this frequent use case-- look at ti and understand why it should be part of the toolset of Go developers -- 

The `golang.org/x`is a repository providing extensions to the stdlib -- the `sync`sub-repository contains a handy package named `errgroup`-- fore, have to handle a function, receives as an arg some data that want to use to call an external service. Due to constraints, can’t make a single call, make multiple calls with a different subset each time.

In case of one error during a call, want to return it -- in case of multiple errors, we want to return ony one of them, write the skeleton of the imp using only the std concurrency primitives like:

## User Logout

This brings us nicely to logging out a user. Implementing the user logout is straightfoward in comparision to the sigup and login -- essentially all we need to do is remove the `autheitcateUserID`from their session. At the same time, it’s good practice to renew the session ID again, also add a flash message to the session dta to confirm to the user that logged out.

```go
func (app *application) userLogoutPost(w http.ResponseWriter, r *http.Request) {
	// Use the RenewToken() no the current session to change the session ID again
	err := app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, err)
		return
	}

	// Remove the authenticationUserId from the session data so that the user is loggedout
	app.sessionManager.Remove(r.Context(), "authenticationUserID")

	// Add a flash message to the session to confirm to the user that they logged out.
	app.sessionManager.Put(r.Context(), "flash",
		"Your have been logged out successfully!")

	http.Redirect(w, r, "/", http.StatusSeeOther)
}
```

### User Authroization

Being able to authenticate the users of our app is all well and good, but now need to do sth useful with that infor -- introduce some *authorization* checks so that -- 

- Only authentiated users can create a new snippet and
- The contents of the navigation bar changes depending on whether a user is authenticated or not.

As mentioned, Can check whether a request is being made by an authenticated user or not by checking the existing on an `authenticatedUserID`value in their session data.

In the `helpers.go`file add `isAuthenticated()`helper function to return the authentication state like so: 

```go
// isAuthenticated return true if the current request is from an authenticated user
func(app *application) isAuthenticated(r *http.Request) bool {
	return app.sessionManager.Exists(r.Context(), "authenticatedUserID")
}
```

Now can check whether or not the request is coming from an authentiated user by simply calling `isAuthenticated()`helper like:

```go
type templateData struct {
	//...
	IsAuthenticated bool
}
```

Then add the second is to update the `newTemplateData()`helper s that this info is automatically added to the `templateData`every time we render a template like so:

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
	return &templateData{
		CurrentYear: time.Now().Year(),
		Flash:       app.sessionManager.PopString(r.Context(), "flash"),
		IsAuthenticated: app.isAuthenticated(r),
	}
}
```

Once that is done, can just update the `nav.html`file to toggle the navigation links like:
`{{if .IsAuthenticated}}`action like so:

```html
{{define "nav"}}
    <nav>
        <div>
            <a href='/'>Home</a>
            {{if .IsAuthenticated}}
                <a href="/snippet/create">Create snippet</a>
            {{end}}
        </div>
        <div>
            {{if .IsAuthenticated}}
                <form action="/user/logout" method="POST">
                    <button>Logout</button>
                </form>

            {{else}}
                <a href="/user/signup">Signup</a>
                <a href="/user/login">Login</a>
            {{end}}

        </div>
    </nav>
{{end}}
```

#### Restricting access

At it stands, hiding the *Create snippet* navigation link for any user that isn’t logged in--  Note that but an unauthenticated user could still create a new snippet by visiting the page directly, `snippet/create`fore. For fixing this, so that if an unauthentited user tries to visit any routes with the URL path `/snippet/create`, the are just redirected to the `/user/login`instead -- so the simplest way to do this is via some middleware, just in the `middlewrae.go` file and create a new `requireAuthentication()`middleware function like:

```go
func (app *application) requireAuthentication(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// if the user is not authenticated, redirect them to the login page and
		// return from the middleware chain so that no subsequent handlers in the chain
		// are executed
		if !app.isAuthenticated(r) {
			http.Redirect(w, r, "/user/login", http.StatusSeeOther)
			return
		}

		// otherwise, set the Cache-Control: no-store header so the pages
		// require authentication are not stored in the browser cache
		w.Header().Add("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}
```

In our case, wan to protect the `/create`and POST `/create`routes, and there is not much point logging out a suer if they are logged in. Re-arrange our app routes into two groups like: the first group will contain our unprotected routes and uses existing `dynamic`middleware chain, and the second will contain our `protected`routes and use a new `protected`middleware chain like:

```go
protected := dynamic.Append(app.requireAuthentication)
router.Handler(http.MethodGet, "/snippet/create", protected.ThenFunc(app.snippetCreate))
router.Handler(http.MethodPost, "/snippet/create", protected.ThenFunc(app.snippetCreatePost))
router.Handler(http.MethodPost, "/user/logout", protected.ThenFunc(app.userLogoutPost))
```

### CSRF protection -- 

Inthis, look at how to protect our app from *cross-site request forgery* attacks -- it is just a type of attck where a malicious 3rd-party website sends state-changing HTTP request to your website.

The main risk is:

- A user logs into app, our session cookie is set to persist for 12 hours, so they will remain logged in even if they navigate away from the app.
- The user then goes to a malicious website which contains some code that sends a cross-site request to the `POST /snippet/create`endpoint add a new snippet to our dbs. The session cookie will be sent along with this requset
- cuz the reuest includes the session cookie, our app will interpret the request as coming from a logged-in user and will proess the requset with that user’s privileges. So completely unknown to the user, a new snippet will be added to our dbs.

#### SameSite cookies

One mitigation that we can take to prevent CSRF attacks is to make sure that the `SameSite`attribute is appropraitely set on our session cookie. 

fore, by default `scs`package using always sets `SameSite=Lax`on the session cookie. This means that the session cookie won’t be sent by the user’s browser for any *unsafe* cross-site requests, `POST PUT DELETE`... So long as our app uses the `POST`method for any state -- changing HTTP requests it means that the session cookie won’t be sent for these request are cross-site.

For this, maybe `SameSite`attribute is still relatively new and only fully supported by 90% of browsers.