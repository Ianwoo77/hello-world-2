# Merge Conflicts (2)

Should have two local repositories called `rainbow`and `friend-rainbow`and one remote repostiory. All three of these should be in sync, with the same commits and branches. Recommend that you use two separate text editor windows and command line windows for working with the rainbow and the friend-rainbow repository.

### Merge Conflicts

Merge conflicts arise when U merge two branches where different changes have been made to the same parts in the same files -- or if in one branch a file was deleted that was edited in the other branch.  Merge conflicts can arise during the process of merging as well as the process of *rebasing*.

Bear in mind that is just normal for merge conflicts to arise, and if they do, it does not mean that someone did sth wrong while working on a project. Resolving merge conflicts is a regular part of working on Git projects.

#### How to resolve merge conflicts -- 

These markers -- called *conflict markers* -- consist of 7 < 7= and 7>, as well as reference to the branches involved in the merge. There are two steps to resolveing merge conflicts -- 

1. Decide what to keep
2. Add the files you have edited to the staging area and commit your changes.

#### Setting Up a merge Conflict scenario -- 

To set up 3-way merge with merge conflicts -- make different changes to the same part in the same file like:

```sh
git add readme.md
git commit -m "indigo"
git push
```

Now to create a situation where you will have a merge conflict -- in the `friend-rainbow`like:

```sh
git add readme.md
git commit -m "violet"
git log
```

What to notice -- 

- In the `friend-rainbow`repository, the local `main`branch points to the violet commit
- In the `rainbow`, the local `main`proints to the `indigo`commit

Friend will need to fetch changes from the remote repository and integrate them before can push their changes to the remote repository.

```sh
git fetch
git status
git log --all
```

In the `git status`states *your branch and `oiring/main`have diverged, 1 and 1different commits each.* And in the `firend-rainbow`, the `origin/main`remote-tracking branch points to the indigo commit. Next, firend is going to carry out a 3-way merge to integrate the latest changes on the remote `main`into their local `main`branch.

Next friend is going to carry out a 3-way merge to integrate the latest changes on the remote `main`into their local `main`branch so they can push the updated `main`to the remote repository.

#### The Merge conflict Resolution process

There are two steps to resolving merge conflits -- The first step is to decide what to keep, edit the content, and remove the conflict markers, and the second is to add all the changes to the staging area and commit it.

STEP 1 -- After execute the `git merge`command in a situation where a merge conflict arises, Git will identify the conflict and will insert conflict markers indicating the locaiton(s) of the conflicting content. The first step in resolving merge conflicts is to decide what to keep, edit content in the file(s) wehre the conflicts occur, and remove the conflict markers. To resolve the merge conflict in the Rainbow proj, your friend will keep both the sentence about the indigo color and the sentence about the violet color.

Next, your friend will need to remove the conflict markers from the readme.md file.

STEP 2 -- After has finished editing, they are ready for the second step -- adding the updated file(s) to the staging area and making a commit.

### Aborting a Merge

If at any point during a merge with conflicts you decide that you don’t want to continue integrating two branches, u can choose stop or abort the merge by using the `git merge --abort`option.

#### Resolving merge conflict in practice -- 

```sh
git merge origin/main # Auto-merging -- merge conflict in readme.md
git status # both modified readme.md
```

Then carry out the step 1 of resovling merge conflicts. Which is to choose what to keep, edit the content, and remove the conflict markers.

```sh
git add readme.txt
git status # modified
git commit -m "merge commit 2"
git log
```

The `git log`shows -- 

- The local `main`points to `merge commit 2`
- The two parent commits of merge commit 2.

For now, successfully carried out the 3-way merge and resovled the merge conflicts.

### Syncing the Repositories -- 

For all the repositoires to be in sync, will need to push the new commits on their local `main`to the remote repository.

```sh
git push
git log # Merge...
# then go to the repository rain-bow
git pull
git log # merge commit 2
```

## Using `nil`channels

A common mistake while working with Go and channels is forgetting that `nil`channels can sometimes be helpful. When we create a channel using the `make`built-in function, the channle can be either unbuffered or buffered.

Using an unbuffered channel -- the sender will block until the receiver receives data from the channel. Conversely, a buffered channel has cap -- must be created with a szie greater 0. 
`ch3 := make(chan int, 1)`

With a buffered onse, a sender can send messages while the channel isn’t full. *Once the channel is full,* it will block until a receiver goroutines recieves a message.

```go
ch3 := make(chan int, 1)
ch3 <- 1 // not block
ch3 <- 2 // blocking
```

Discuss the fundamental differences between these two channel types -- Channels are a concurrency abstraction to enable communication among goroutiens -- but what about sync -- Sync means that we can guarantee that multiple goroutines will be in a known state at some point. Regarding channels -- 

- An unbuffered enables synchronization -- have guarantee that two goroutines will be in a known state -- one receiving and another sending a mesage
- A buffered doesn’t provide any strong synchronization -- A producer can send a message and continue its execution if the channel isn’t full.

Namely, both channel types enable communication, but only one provides sync -- if need sync, we must use unbuffered. 

And there are other cases where unbuffered channels are prefearable. Fore in the case of a notification channel where the notificaiton is handled via a channel closure -- here using a buffered channel wouldn’t bring any benefits.

What if need a buffered channel -- what size would provide -- The default value should use for buffered is minimum: 1, may approach the problem from this standpoint. If there any good readon *not* to use a vlaue of 1-- 

- While using a worker pooling -- like pattern, meaning spinning a fixed number of goroutines that need to send data to a shared channel.
- When using channel for rate -- limiting problems -- fore if need to enforce resource utilization by bounding the number of requests.

If outside of these cases, using a different channel size should be done cautiously.

### Don’t Create data races with `append`

Look at slices and whether adding an element to slice using `append`is data-race-free -- In the following example, will initialize a slice and create two goroutines that will use `append`to create a new slice with additional element like:

```go
// 1L and 1C already full
s := make([]int, 1)
go func() {
    s1 := append(s, 1) // doesn't mutate original
    print(s1)
}()
go func() {
    s2 := append(s, 2)
    print(s2)
}()
```

For this example, there is no data race. Fore, a slice is backed by an array and has two properties -- Length and Capacity -- the length is the number of available elements in the slice, whereas the capacity is the total number of elements in the backing array. When using `append`, the behavior depends on whether the slice is full (C==L). If it is, Go runtime creates a new backing array to add the new element.

Then, create a alice with `make([]int,0,1)` Data race occurred. So how can we prevent the data race if we want both goroutines to work on a slice containing the initial elements of `s`plus an extra element -- like:

```go
s := make([]int, 0, 1)
go func() {
    sCopy := make([]int, len(s), cap(s))
    copy(sCopy, s)
    s1 := append(sCopy, 1)
    print(s1)
}()
```

While working with slices in concurrent contexts, must recall using `append()`on slices isn’t always race-free.

### Using Mutexes accurately with slices and maps

While working in concurrent contexts where data is both mutable and shared, often have to implement protected accesses aournd data structure using mutexes. A common mistake is to use mutexes inaccurately when working with slices and maps. Will implement a `Cache`struct used to handle caching for customer balances - this struct will contain a map of balances per customer ID and a mutex to protecte concurrent accesses -- like:

```go
type Cache struct {
    mu sync.RWMutex
    balance map[string]float64
}
```

next, add an `AddBalance`method that mutates the `blanaces`map  -- the mutation is done in a critical section:

```go
func (c *Cache) AddBalance(id string, balance float64) {
    c.mu.Lock()
    c.balance[id]= balance
    c.mu.Unlock()
}
```

Meanwhile have to implement a method to calculate the average fore

```go
func (c *Cache) AverageBalanc() float64 {
    c.mu.RLock()
    balances := c.balances // creates a copy of map
    c.mu.RUnlock()
    
    sum := 0
    for _, balance := range balances {
        sum += balance
    }
    return sum/float64(len(balances))
}
```

There is a data race - Internally, a map is a `runtime.hmap`struct containing mostly metadata, and pointer referening data buckets. For the `AverageBalance()`-- `balances := c.balances`doesn’t copy the actual data, it’s the same principle with a slice. We just addigned to balances a new map referencing the same data buckets as `c.balances`. Meanwhile, the two goroutines perform operations on the same data and one of them mutates.

If the iteration operation isn’t heavy, should protect the whole func like:

```go
func (c *Cache) AverageBalance() float64 {
	c.mu.RLock()
	defer c.mu.RUnlock() 
	
	sum := 0.
	for _, balance := range c.balances {
		sum += balance
	}
	return sum / float64(len(c.balances))
}
```

Another option, if the iteration opertion isn’t lightweight, just work on an actual copy of the data and protect only the copy like -- 

```go
c.mu.RLock()
m := make(map[string]float64, len(c.balances))
for k, v := range c.balances {
    m[k] = v
}
c.mu.RUnlock()
```

For this, once we have made a deep copy, release the mutex.

## A brief introduction to `bcrypt`

If dbs is ever compromised by an attacker, it’s hugely important that it doesn’t conain the plain-text version of your passwords. To store a *one-way* hash of the pwd, derived with a computationally expensive key -- derivation function such as bcrypt -- Go has implementaitons of all 3 algorithems.

```go
hash, err := brcypt.GenerateFromPassword([]byte("some"), 12)
```

This func will return a 60-character long hash, and 12 for *cost* which is represented by an integer between 4 and 31. On the flip side, can check that a plain-text pwd matches a particualr hash using the `brcypt.CompareHashAndPassword()`func like so:

```go
hash := []byte("...")
err := brcypt.CompareHasAndPassword(has, []byte("some"))
```

This function will return `nil`if matches.

#### Storing the user details

The next stage of our app is to update the `UserModel.Insert()`method so taht it creates a new record in our `users`table containing the validated name, email and hashed pwd. First want to store the bcrypt hash of the pwd and second, also need to manage the potential error caused by a duplicate email violating the `UNIQUE`constraint that added to the table.

An errors returned by MySQL has a particular code -- which can use to triage what has caused the error like: In the case of a duplocate email, error code used will be 1062 (``ERR_DUP_ENTRY`).

```go
type UserModel struct {
    DB *sql.DB
}
func (m *UserModel) Insert(name, email, password string) error {
    // Create a bcrypt hash of the plain-text pwd
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 12)
    if err != nil {
        return err
    }
    stmt := `INSERT INTO users (...) VALUES (?, ?, ?, UTC_TIMESTAMP())`
    
    _, err = m.DB.Exec(stmt, name, email, string(hasedPassword))
    if err != nil {
        var mySQLError *mysql.MySQLError
        if errors.As(err, &mySQLError) {
            //...
            if mySQLError.Number == 1062 && strings.Contains(mySQLError.Message, 
                                                             "users_uc_email"){
                return ErrDupliateEmail
            }
        }
        return err
    }
    return nil
}
```

Then in the handlers.go file just like:

```go
func (app *application) userSignupPost(w http.ResposneWriter, r *http.Request) {
    var form userSignupForm
    err := app.decodePostForm(r, &form)
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    // ...
    form.CheckField(validator.Matches(form.Email, validator.EmailRX), "email", 
                   "The field must be a valid format")
    form.CheckFiled(validator.MinChars(form.Password, 8), "password", 
                   "The field must be at least 8 characters long")
    
    if !form.Valid() {
        data := app.newTemplateData(r)
        data.Form= form
        app.render(w, http.StatusUnprocessableEntity, "signup.html", data)
        return
    }
    
    // Try to create a new user record in the dbs, if the email already exists then add an error
    // message to the form and re-display it.
    err = app.users.Insert(form.Name, form.Email, form.Password)
    if err != nil {
        if errors.Is(err, models.ErrDuplicateEmail) {
            form.AddFieldError("email", "... in use")
            data := app.newTemplateData(r)
            data.Form=form
            app.render(w, http.statusUnprocessableEntity, "signup.html", data)
        }else {
            app.serveError(w, err)
        }
        return
    }
    app.sessionManger.Put(r.Context(), "flash", "your signup successufl, login")
    http.Redirect(w, r, "/user/login", http.StatusSeeOther)
}
```

### User Login

In this going to focus on creating the user login page for our app -- `internal/validator`package - and update it to validation errors which are not associated with one specifc form field. We will use this later to show wrong email or pwd. Just like:

```go
// Add a new NonFieldErrors []string field use to hold 
// validation errors which are not related to a specific form field
type Validator struct {
	NonFieldErrors []string
	FieldErrors    map[string]string
}

func (v *Validator) Valid() bool {
	return len(v.FieldErrors) == 0 && len(v.NonFieldErrors) == 0
}

// AddNonFieldError for adding error message to the new slice
func (v *Validator) AddNonFieldError(message string) {
	v.NonFieldErrors = append(v.NonFieldErrors, message)
}
```

Then create a new `login.html`containing the markup for our login page like:

```html
{{define "title"}}Login{{end}}

{{define "main"}}
    <form action="/user/login" method="post" novalidate>
        {{range .Form.NonFieldErrors}}
            <div class="error">{{.}}</div>
        {{end}}

        <div>
            <label>Email:</label>
            {{with .Form.FieldErrors.email}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="email" name="email" value="{{.Form.Email}}">
        </div>

        <div>
            <label>Password:</label>
            {{with .Form.FieldErrors.password}}
                <label class="error">{{.}}</label>
            {{end}}
            <input type="password" name="password" value="{{.Form.Password}}">
        </div>

        <div>
            <input type="submit" value="Login">
        </div>
    </form>
{{end}}
```

Then in the `handlers.go`file and create a new `userLoginForm()`struct represent and hold the form data. like:

```go
// Create a new userLoginForm struct
type userLoginForm struct {
	Email               string `form:"email"`
	Password            string `form:"password"`
	validator.Validator `form:"-"`
}

func (app *application) userLogin(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form = userLoginForm{}
	app.render(w, http.StatusOK, "login.html", data)
}
```

#### Verifying the user details

The next step is the interesting part -- how do we verify that the email and pwd submitted by a user are correct -- like: The core part of this verification logic will take place in the `UserModel.Authenticate()`method of our user model -- Specifically, need it to do two things -- 

1) First it should retrieve the hashed password associated with the email address from our MySQL `users`table, Andif the email doesn’t exist in the dbs, or it’s for a user that has been deactivated, return `ErrInvalidCredentials`.
2) Otherwise, want to compare the hashed password from the `users`table with a plain-text pwd that the user provided when logging in.

In the `users.go`file:

```go
func (m *UserModel) Authenticate(email, password string) (int, error) {
	var id int
	var hashedPassword []byte
	stmt := "SELECT id, users.hashed_password from users where email=?"
	err := m.DB.QueryRow(stmt, email).Scan(&id, &hashedPassword)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return 0, ErrInvalidCredentials
		} else {
			return 0, err
		}
	}

	// Check whether the hashed pwd and plain-text pwd match
	err = bcrypt.CompareHashAndPassword(hashedPassword, []byte(password))
	if err != nil {
		if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
			return 0, ErrInvalidCredentials
		} else {
			return 0, err
		}
	}
	return id, nil
}
```

Then updating the `userLoginPost`handler so that it parses the submitted login form data and calls this `UserModel.Authentiate()`method. If the login details are just valid, thenwant to add the user’s `id`to their session data so that for future requests.

```go
func (app *application) userLoginPost(w http.ResponseWriter, r *http.Request) {
	// Decode the form data into the struct
	var form userLoginForm

	err := app.decodePostForm(r, &form)
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// Do some validation checks on the form
	form.CheckField(validator.NotBlank(form.Email), "email", "This field cannot be blank")
	form.CheckField(validator.Matches(form.Email, validator.EmailRX), "email", "This field must be a valid email address")
	form.CheckField(validator.NotBlank(form.Password), "password", "This field cannot be blank")

	if !form.Valid() {
		data := app.newTemplateData()
		data.Form = form
		app.render(w, http.StatusUnprocessableEntity, "login.html", data)
		return
	}

	// check whether the credentials are valid
	id, err := app.users.Authenticate(form.Email, form.Password)
	if err != nil {
		if errors.Is(err, models.ErrInvalidCredentials) {
			form.AddNonFieldError("Email or password is incorrect")
			data := app.newTemplateData(r)
			data.Form = form
			app.render(w, http.StatusUnprocessableEntity, "login.html", data)
		} else {
			app.serverError(w, err)
		}
		return
	}

	// Use the `RenewToken` method on the current session to change the session ID
	// it's good practice to generate a new session ID when the authenticate state
	// or privilege levels changes for the user
	err = app.sessionManager.RenewToken(r.Context())
	if err != nil {
		app.serverError(w, err)
		return
	}

	// Add the ID of the current user to the session so they are now "logged in"
	app.sessionManager.Put(r.Context(), "authenticatedUseID", id)

	// redirect the user to create page
	http.Redirect(w, r, "/snippet/create", http.StatusSeeOther)
}
```

