# Merge Conflicts

U carried out a 3-way merge in which you did not experience any merge conflicts -- In this, going to learn about merge conflicts, how hey arise, and how to resolve them by walking through a hands-on example of a 3-way merge with a merge conflict.

### State of the Local and Remote Repositories

All three of these repositories should be in sync,  with the same commits and branches. Covered what happens when U work on a project at the same time as someone else but you each make changes to different files. Edited the `othercolors.txt`while friend edited the `rainbowcolors.txt`-- Merge conflics arise when U merge two branches where different changes have been made to the sem parts in the same file(s), or if one branch a file was deleted what wad edited in the other branch. 

Conflicts can arise during the process of merging as well as the process of rebasing. For this chap, just cover an example of a merge conflict in the `Rainbow`proj while merging. Bear in mind that it is just normal for merge conflicts to arise -- and if do, it does not means that someone did sth wrong.

Fore, primary line of developmentis the `main`branch -- decided together with my editor and my coauthor that whenever I work. Whenever work on a chapter will make a branch off the `main`-- then after they have both approved the work, Have don that branch. I can merge the branch back into the `main`. Fore both decide to edit chapter 3 at the same time, and we both make branches off the `main`to work on this chapter at the same time. Fore, I made the `chap_3`and coauthor makes the `chap_3_coauther`. Both edit the same file fore `chapter_three.txt`.

Assume that coauther merges their work on the `chap_3_author`into the `main`first. When go to merge my own into the most up-to-date of the main, not only have to carry out a 3-way merge, will also have to resolve merge conflicts. 

This is one scenario may experience merge conflicts -- occurs when the same file has been edited in different ways in the two branches involed in the merge.

Another, I will delete that txt file and coauthor just will edit that to make it better fore. Again, he merges their branch into the main first. Also conflicts.

### How to resolve Merge Conflicts

Will see a set of special markers in each of the files. The markers called *conflict markers* -- Consists of 7 `<`and 7 `=`and 7 `>`. Like:

```tex
<<<<<<<HEAD
{Content of target branch}
=======
{Content of source branch}
>>>>>>>refs/remote/origin/main
```

There are two steps to resolving merge conflicts -- 

1. Decide what to keep, edit the content, and moreve the conflict markers
2. Add the file(s) U have edited to the staging area and commit your changes

Need to create a situation with divergant development histories in your local repositories.

### Setting up merge conflicts scenario

U and your friend have to make different changes to the same part in the same file.

```sh
# in the rainbow edit then save.
git add readme.md
git commit -m "indigo"
git push
git log
```

Noticed that in the `rainbow`and in the rainbow-remote -- there is an indigo commit.

Now need to create a situation where you will have a merge conflict -- add the color violet to the same line in the readme.md and make a commit *without pulling* from remote repostiory like:

```sh
# in the friend-rainbow repostiory made some change
git add readme.md
git commit -m "violet"
git log
```

At this point, your friend will need to fetch your changes from the remote repository and integrate them before they can bpush their changes to the remote.

```sh
git fetch
git status # your branch and `origin/main` have diverged
git log --all
```

For this -- in step 2, the output of the `git status`command states that diverged. So for now -- Next, your friend is going to carry out a 3-way merge to integrate the lastest changes on the remote `main`into their local `main`branch so can push the updated `main`to the remote repository.

### The Merge Conflict resolution Process

There are 2 steps to resolving merge conflicts -- The first step is to decide what to keep, edit the content, and remove the conflict markers, and the second is to add all the changes to the staging area and commit.

#### Step 1

After U execute the `git merge`command in a sitation where a merge conflict arises - -Git will identify the conflict and will insert conflict markers indicating the location(s) of the conflicting content. The first step in resolving merge conflicts is to decide what to keep, edit content in the file(s)...

## Concurrency Practice

- Preventing common mistake with goroutines and channels -- 
- Understanding the impacts of using std data structures alongside concurrent code
- Using the sandard lib and some extensions
- Avoiding data races and deadlocks

### Propagating an appropriate context

Contexts are omnipresent when working with concurrency in Go -- and in many situations, it may be recommended to propagate them -- however, context propagation can simetimes lead to subtle bugs -- preventing subfunctions from being correctly executed. Don’t want to penalize the HTTP consumer latency-wise, so want to publish action to be handled async within a new goroutine.

```go
func handler(w http.ResponseWriter, r *http.Request) {
    // performs some task to compute the http response
	response, err := doSomeTask(r.Context(), r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	go func() { // creates a goroutien to publish
		err := publish(r.Context(), response)
		// do something with err
	}()
	writeResponse(response)
}
```

Just note when calling the `publish()`we propagate the context attached to the `http.Requst`. Have to know that the context attacted to the HTTP request can cancel in different conditions -- 

- When the client’s connection closes
- In the case of an Http/2 request, when the request is canceled
- When the response has been written back to the client.

For the last one -- when the response has been written to the client, the context associated with the request will be canceled -- therefore, we are facing a race condition.

If the response is written **before** during the publication -- the message shouldn’t be published. In this calling `publish`is not propatage the parent context -- instead, we would `publish`with an empty context. -- 
`err := publish(context.Background(), resposne)`

But -- if the context contained useful values -- if the context contained a correlation ID used for distributed tracing, we could correlate the HTTP request and the publication. Would like to have a new context hat is detched from the potential parent but still conveys the values. Note that the STDLIB doesn’t provide an immediate solution to this problem -- a possible solution is to implement our Own Go context similar to the context provided -- except it dosn’t carry the cancellation signal -- A `context.Context`is an interface that containing four methods -- 

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key any) any
}
```

The context’s deadline is managed by the `Deadline()`and the cancellation signal is managed via the `Done()`and `Err()`. When a deadline has passed or the context has been canceled -- `Done`should return a closed channel, whereas `Err`should return an error. 

Create a custom context that detaches the cancellation signal from a parent context.

```go
type detach struct {
	ctx context.Context // just act as a wrapper on top of the initial context
}

func (d detach) Deadline() (deadline time.Time, ok bool) {
	return time.Time{}, false
}

func (d detach) Done() <-chan struct{} {
	return nil
}

func (d detach) Err() error {
	return nil
}

func (d detach) Value(key any) any {
	return d.ctx.Value(key)  // delegates the get value call to parent context
}
```

For this note that except for the `Value()`that calls the parent context to retrieve a value, the other methods return a default value so the context is never considered expired or canceled.

Now can call `publish`and detach the cancellation signal like:
`err := publish(detach{ctx: r.Context}, response)`

### Starting a goroutine wihtout knowing when to stop it

Goroutines are easy and cheap to start -- so easy and cheap that may not necessarily have a plan for when to stop a new goroutine -- which can lead to leaks. Not knowing when to stop a goroutine is a design issue and a common concurrency mistake in Go.

In terms of memroy,  a goroutine starts with a minimal stack size of 2K -- can grow and shrink as needed. A goroutine can also hold variable references alocaed on the heap. So if a goroutine is leaked, these kinds of resources will also be leaked. Look at an example in which the point where a goroutine stops is unclear. here a parent goroutine calls a func that returns a channel and then creates a new goroutine that will keep receiving messages from this channel. like:

```go
ch := foo()
go func() {
    for v := range ch {
        //...
    }
}()
```

For this, goroutine will exit when `ch`closed -- but do we know exactly when this channel will be closed -- it may not be evident -- cuz `ch`is ceated by the `foo`-- if the channel never closed -- leak. So should always be cautions about the exit points of a goroutine and make sure one is eventaully reached.

Fore, disign an app that needs to watch some external configuraiton -- like:

```go
func main(){
    newWatcher()
    // ...
}
type watcher struct {...}
func newWatcher() {
    w := watcher{}
    go w.watch()
}
```

For this, when main closed, the app is stopped, hence, the resource created by `watcher`aren’t closed gracefully. fore:

```go
func main() {
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    newWatcher(ctx)
    // run the app
}
func newWatcher(ctx contxt.Context) {
    w := watcher{}
    go w.watch(ctx)
}
```

For this, when the context is canceled, the `watcher`struct should close its resource. For this -- the problem is that we used signaling to convy that a goroutine had to be stopped -- we didn’t block the parent goroutine until the resources had been closed.

```go
func main(){
    w := newWatcher()
    defer w.close()
    //... run
}

func newWatcher() watcher {
    w := watcher{}
    go w.watch()
    return w
}
func (w watcher) close() {
    // close the resource
}
```

For this just has a new method `close`-- instead of signaling now just call this `clsoe()`using the `defer`to guaratee that the resoruces are closed before the app exits. Whenever a goroutine is started, we should have a clear plan about when it will stop. Whenever a goroutine is started, should have a clear plan abut when it will stop. It’s probably safer to wait for this goroutine to complete before exiting the application.

## Validating the user Input

When this form is submitted the data will end up being posted to the `userSignupPost()`that made easier -- The first task of this handler will be to valiate the data to make sure that is sane and sensible before insert it into the dbs. Head over to your `handlers.go`file and add some code to process the form and run the valiation checks like -- 

```go
func (app *application) userSignupPost(w http.ResponseWriter, r *http.Request) {
	// Declare a zero-based instance of our struct
	var form userSignupForm

	// parse the form data into the userSignupForm struct
	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// validate the form contains using our helper functions
	form.CheckField(validator.NotBlank(form.Name), "name",
		"this field cannot be blank")
	form.CheckField(validator.NotBlank(form.Email), "email",
		"this field cannot be blank")
	form.CheckField(validator.Matches(form.Email, validator.EmailRX), "email",
		"this field must be valid format")
	form.CheckField(validator.NotBlank(form.Password), "password",
		"this field cannot be blank")
	form.CheckField(validator.MinChars(form.Password, 8), "password",
		"This field must be at least 8 characters")

	// If there are any errors, redisplay the signup form along with a 422
	if !form.Valid() {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, http.StatusUnprocessableEntity, "signup.html", data)
		return
	}

	// otherwise send the placeholder
	fmt.Fprintln(w, "Create a new user...")
}
```

#### A brief instruction to bcrypt 

If your dbs is ever compromised by an attacker -- it’s hugely important that it doesn’t contain the plain-text versions of your user’s passwords. It’s just practice -- essential, really to store a one-way hash of the pwd, derived with a computationlly expensive key -- derivation functin. Go has implemention of all 3 algorithms in the `golang/org/x/crypto`package.

```sh
go get golang.org/x/crypto/bcrypt
```

There are two functions that we will use in this book -- is `bcrypt.GenerateFormPassword()`function which lets us create a hash of a given plain-text password like:

`hash, err := bycrypt.GenerateFromPassword([]byte("my pwd"), 12)`

And also note that this function will return a 60-charcter long hash which -- `12`indicates the  *cost* -- which is represented by an integer between 4 and 31. And the higher the cost, the more expensive the hash will be for an attacker to crack. On the flip side, can check that a plain-text pwd matches a particular hash using the `bcrypt.CompareHashAndPassword()`func like so: 

```go
hash := []byte("$2a...")
err := brcypt.CompareHashAndPassword(hash, []byte("my pwd"))
```

Will return a `nil`if the pwd matches a particular hash, or an error if they don’t match.

#### Storing the user details -- 

The next stage of our build is to update the `UserModel.Insert()`method so that it creates a new record in our `users`table containing the validated name, email and hashed pwd. This will be interesting for two reasons -- first want to store the bcrypt hash of the password and second, also need to manage the potential error caused by a duplicate email violating the `UNIQUE`constraint that we added to the table.

All errors returned by MySQL have a particular code, which we can use to triage what has caused the error.

```go
func (m *UserModel) Insert(name, email, password string) error {
	// Create a bcrypt hash of the plain-text pwd
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	if err != nil {
		return err
	}

	stmt := `INSERT INTO users (name, email, hashed_password, created) 
		VALUES(?, ?, ?, UTC_TIMESTAMP())`
	_, err = m.DB.Exec(stmt, name, email, string(hashedPassword))
	if err != nil {
		// if this returns an error, then need to use the errors.As() function to check
		// whether the error has the type -- if it dow, the err will be assigned to the variable
        // can then check whether or not the error relates to our users_uc_email key by checking
        // if the error code equals 1062 and the contents of the error message string.
		var mySQLError *mysql.MySQLError
		if errors.As(err, &mySQLError) {
			if mySQLError.Number == 1062 && strings.Contains(mySQLError.Message,
				"users_uc_email") {
				return ErrDuplicateEmail
			}
		}
		return err
	}
	return nil
}
```

In the handlers.go file:

```go
// If there are any errors, redisplay the signup form along with a 422
if !form.Valid() {
    data := app.newTemplateData(r)
    data.Form = form
    app.render(w, http.StatusUnprocessableEntity, "signup.html", data)
    return
}

// Try to create a new user record in the dbs, if email already
// exists then add an error message to the form and re-display it
err = app.users.Insert(form.Name, form.Email, form.Password)
if err != nil {
    if errors.Is(err, models.ErrDuplicateEmail) {
        form.AddFieldError("email", "Email address is already in use")
        data := app.newTemplateData(r)
        data.Form= form
        app.render(w, http.StatusUnprocessableEntity, "signup.html", data)
    }else {
        app.serverError(w, err)
    }
    return
}

// Otherwise add a confirmation flash message 
app.sessionManager.Put(r.Context(), "flash", "your signup was successful")
http.Redirect(w, r, "/user/login", http.StatusSeeOther) // to login
```

#### Using dbs bcrypt implementations

Some dbs provides built-in functions that U can use for pwd hasing and verification instead of implementing your own in Go -- like have in the code above. It’s probably a good idea to avoiding using these for two reasons -- 

- They tend to be vulnerable to side-channel timing attacks due to string compairson time not being constant.
- Unless U are carefully, sending a plain-text pwd to your dbs risks the pwd being accidentally recorded in one or your dbs logs.