# Merge Conflict Scenario

To set up a 3-way merge with merge conflicts -- have to make different changes to the same part in the same file.

```sh
# in the rainbow, rainbowcolors.txt modify
git add rainbowcolors.txt
git cimmit -m "indigo"
git push

# in the friend repository directory
git add rainbowcolors.txt 
# ... not push just commit

# then fetch
git fetch
git status # your branch and origin/main have diverged
```

In the step2, the output of the `git status`command states -- *have diverged*, and have 1 and 1 different commits each, respectively.

#### The merge conflict resolution process

Fore, to resolve the merge conflict in the Rainbow project, will keep both the sentences fore. After that, ready for second step -- note that also need to update file(s) to the staging area and making a commit. In the Rainbow project there is only one file with a merge.

#### Aborting a Merge

If any point during a merge with conflicts you dicide that you don’t want to continue integrating two branches, can choose or stop or *abort* the merge by uaing the `git merge --abort`.

```sh
git merge origin/main
git status
# carry out setp1 of resolving conflicts, which is jsut to choose what to keep, edit the conent
# are going to keep all of the content
git add rainbowcolors.txt # must do
git status
git commit -m "merge commit 2"
```

#### Staying up to Date with a remote repostiory

In the Rainbow proj, there was only one file with a small merge conflict. Whenever U create a new branch, it is recommanded that you base it off the most up-to-date version of teh relevant remote branch in the remote repository. The syncing that like:

```sh
git push
git log # HEAD->main, origin/main, origin/HEAD
# then in the rainbow
git pull
```

### Rebasing

Up until now, have focused on merging as a way of integrating changes in Git. Can see that up until the green commit you had a linear project history, but after the green commit the commit history is nonlinear due to the merge commits created by the 3-way merges. Can use the process of rebasing to avoid 3-way merges and merge commits and maintain a linear project history.

Rebasing takes all the work you have done in the commits on one branch and reapplies the work on another branch, creating entirely new commits.

To carryout a rebase, need to be on the branch you want to rebase, use the `git rebase`command and pass in the name of the branch that you want to rebase onto like: `git rebase <branch_name>`, and given that rebasing createds *entirely* new commits, means it changes the commit history.

Fore, when decide my changes to CH5 fore, are ready to be merged into local `main`, now have a couple of options, one is to fetch chagnes on the remote `main`then do a 3-way mrege to merge ch5 into `main`.

Another option is to pull the changes from the remote, which means will update to commit C. With the intent of rebasing my branch afterward. Next, can *rebase* ch5 on top of the updated `main`branch. *Rebasing* will take all the commits have made on the CH5 -- in this example, the only commit that I made on the ch5 since it diverged from the `main`branch is D. When the branch is rebased, a new D’ commit will be created. Note that the D’ represents the new version of commit D that was created during the rebase process. It includes all the changes made in the original D commit, but it’s entirely a new commit with new commit hash.

After have rebased branch, can merge it into `main`with a simple FF-merge. Now `main`and `ch5`point the D’. So, by rebasing my branch, I’m able to maintain a linear commit history and avoid making additional merge commits.

#### Setting up the rebasing Example

To practice, need to create divergent histories. Going to make one commit in the `rainbow`and push it to the remote repository. For friend, wihtout fetching from remote, is going to make two commits in their repository. After have made commits, they will fetch the changes from the remote repository and decide to rebase their branch, fore:

```sh
# open othercolors.txt in the rainbow directory
git add othercolors.txt
git commit -m "gray"
git push
git log
```

For this, just made the gray commit and pushed it to the remote repository. Next, your friend will add some work in the `friend-rainbow`on the same branch, which will lead to divergant histories between `main`branch and your friend’s `main`.

#### Unstaging and Staging Files -- 

going to make changes to both of the files in the firend repository, and add them both to the staging area. Then will realize they want to make two separate commits for the different pieces of work. Will have to *unstage* file. Fore, current versions of the `rainbowcolors.txt`and `othercolors.txt`file that are in the working directory and staging area are represented as version A. 

## Handling `defer`errors

Not handling errors in `defer`statements is a mistake that is frequently made by Go developers. Fore:

```go
const query ="..."
func getBalance(db *sql.DB, clientID string) (float32, error) {
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    defer rows.Close()
}
```

For this, `rows`is a `sql.Rows`type-- it also implements the `Closer`interface. like:

```go
type Closer interface {
    Close() error
}
```

This interface contains a single `Close`method that returns an error, mentioned in the previous that errors should always be handed --  Fore:

`defer func() {_ = rows.Close()}()`

But, in such as case, instead of blindly ignoring all errors from `defer`, should ask ourselves whether that is the best approach -- calling `Close()`returns an error when it fails to free a `DB`connection from the pool. Hence, ignoring this error is probably not what we want to do. Fore:

```go
defer func() {
    err := rows.Close()
    if err != nil {
        log.Printf("...", err)
    }
}()
```

And, if instead of handling the error, prefer to propagating it to the caller of `getBalance()`so that they decide how to handle it -- fore:

```go
defer func() {
    err := rows.Close()
    if err != nil {
        return err
    }
}()
```

This imp doesn’t compile -- the `return`is associated with the anonymous `func()`. If want to tie the error returned by `getBalance`to the error caught in the `defer`, must use named result parameter -- like:

```go
func getBalance(db *sql.DB, clientID string) (balance float32, err error) {
    rows, err := db.Query(query, clientID)
    if err != nil {
        return 0, err
    }
    // ...
    defer func() {
        closeErr := rows.Close()
        if err != nil {
            if closeErr != nil {
                log.Printf(...)
            }
            return
        }
        err = closeErr
    }()
}
```

### Communication using Message passing

A Go `channel`lets two or more goroutines exchange messages, conceptually, can think of a channel as being a direct line between our goroutines. Using `make()`built-in function, can then pass it onward as an argument whenever create goroutines.

```go
func main() {
	msgChannel := make(chan string)
	go sender(msgChannel)
	fmt.Println("Reading from channel...")
    // block
	msg := <-msgChannel
	fmt.Println(msg)
}

func sender(message chan string) {
	time.Sleep(5 * time.Second)
	fmt.Println("Sender slept for 5s")
}
```

By default, Go’s channels are *Synchronous*. A sender will block if there isn’t a goroutine consuming its message, and receiver will block if there isn’t a goroutine sending a message.

#### Buffering with channels

Can configure them so that they store a number of messages before they block, when use a buffered channel, the sender goroutine will not block as long as there is space available in the buffer. When create a channel, can specify its buffer capacity. Means that as long as there is space in the buffer, our sender does not block. And, the channel will keep on storing messages as long as capacity remains in the buffer.

Once a receiver goroutine is availbel to consume the message, the messages are fed to the receiver in the same order they were sent. This happens even if the sender goroutine is no longer sending any new messages. This happens even if the sender goroutine is no longer sending any new messages -- as long as there are messages in the buffer, a receiver goroutine will not block.

Once the receiver goroutine consumes all messages and buffer is empty, the receiver goroutine will again block. When the buffer is empty, a receiver will block if we don’t have a sender or if the sender is producing message at a slower rate than the receiver can read them. Fore:

```go
func main() {
	msgChannel := make(chan int, 3)
	wGroup := sync.WaitGroup{}
	wGroup.Add(1)
	go receiver(msgChannel, &wGroup)
	for i := 1; i <= 6; i++ {
		size := len(msgChannel)
		fmt.Printf("%s sending: %d, buffer size: %d\n",
			time.Now().Format("15:04:05"), i, size)
		msgChannel <- i
	}
	msgChannel <- -1
	wGroup.Wait()
}

func receiver(message chan int, wGroup *sync.WaitGroup) {
	msg := 0
	for msg != -1 {
		time.Sleep(time.Second)
		msg = <-message
		fmt.Println("Received:", msg)
	}
	wGroup.Done()
}
```

For this, get a faster sender that is trying to send 6 messages, since have a much slower receiver, the `main`will fill the channel buffer with 3 messages and then block. The receiver will consume a message every second, then freeing a space in the buffer that the sender will quickly fill.

#### Assigning a direction to channels

Go’s channels are *bidirctional* by default -- means that a goroutine can act as bot a receiver and a sender of messages, Can asslign a direction to a channel so that the goroutine using the cahnnel can only send or receive messages. Fore, when declare a func’s parameters, can specify the direction of the channel. In the receiver, when declare the channel as being `messages <-chan int` saying that is a receive-only channel. `chan<- int`is send only.

```go
func main() {
	msgChannel := make(chan int)
	go receiver(msgChannel)
	go sender(msgChannel)
	time.Sleep(5 * time.Second)
}

func receiver(messages <-chan int) {
	for {
		msg := <-messages
		fmt.Println(time.Now().Format("15:04:05"), "received:", msg)
	}
}

func sender(messages chan<- int) {
	for i := 1; ; i++ {
		fmt.Println(time.Now().Format("15:04:05"), "sending", i)
		messages <- i
		time.Sleep(time.Second)
	}
}
```

### Closing Channels

DEF -- in development, a *senientel value* is a predefined value that signals to an execution, a process, or an algorithm that it should terminate. In the context of multithreading and a distributed system, this is sometimes refereed to as a poison pill message -- Go allows to close a channel -- can do this by calling `close(channel)`-- once closed, shouldn’t send any more messages to it cuz doing so *raise*. If try to receive messages from a closed, will get messages containing the **default value** from the channel’s data type. Fore:

```go
func main() {
	msgChannel := make(chan int)
	go receiver(msgChannel)
	for i := 1; i <= 3; i++ {
		fmt.Println(time.Now().Format("15:04:05"), "sending", i)
		msgChannel <- i
		time.Sleep(time.Second)
	}
	close(msgChannel)
	time.Sleep(3 * time.Second)
}
```

Using the default value is not ideal cuz the default value might be a valid value for our use case. Go just gives a couple of ways to handle closed channels -- whenever we consume from a channel, an additional flag is returned, telling us the status of the channel. This flag is set to `false`only when the channel has been closed. Like:

```go
func receiver(messages <-chan int) {
	for {
		msg, more := <-messages
		fmt.Println(time.Now().Format("15:04:05"), "received:", msg, more)
		time.Sleep(time.Second)
		if !more {
			return
		}
	}
}
```

Can use a cleaner syntax to stop a receiver from reading on a closed channel. like:
`for msg := range messages`

```go
func receiver(messages <-chan int) {
	for msg := range messages {
		fmt.Println(time.Now().Format("15:04:05"), "Received", msg)
		time.Sleep(time.Second)
	}
	fmt.Println("Receiver finished")
}
```

## Transactions and other details

The `database/sql`package -- essentially provides a standard interface between your Go app and the world of SQL database. This means that your app isn’t so tightly coupled to the dbs that you are currently using, and the theory is that can swap dbs in the future.

Managing null values -- One thing that Go doesn’t do very well is managing `NULL`values in the dbs records. Very roughly the fix for this is to change the field that you are scanning into from a `string`to a `sql.NullString`. As a rule the eaiest thing to do is simply avoid `NULL`values altogether.

#### Working with transactions

It’s important to realize that calls to `Exec(), Query(), QueryRow()`can use any *connection* from the `sql.DB`pool. Note that if you have two calls to `Exec()`immediately next to each other in code, there is no guarantee that they will use the same dbs connection. And, to guarantee that the same connection is used can wrap multiple statements in the *transaction* -- basic pattern like:

```go
type ExampleModel struct {
    DB *sql.DB
}
func (m *ExampleModel) ExamleTansaction() error {
    tx, err := m.DB.Begin()
    if err != nil {
        return nil
    }
    // call that to ensure it is always called before the function returns
    // if transaction succeeds will be committed, making this no-op
    // error occurred, will rollback the changes
    defer tx.Rollback()
    
    // Call Exec(), passing in statement and any parameters
    // Exec() called on the transaction, not pool
    _, err = tx.Exec("INSERT INTO ...")
    if err != nil {
        return err
    }
    
    // Carry out another transaction fore:
    _, err = tx.Exec("Update...")
    if err != nil {
        return err
    }
    
    // if no errors
    err = tx.Commit()
    return err
}
```

And, Transactions are also super-useful if want to execute mutliple SQL statements as a *single* atomic action. So long as you use the `tx.Rollback()`in the event of any errors, the transaction ensures that either -- 

- All statements are executed successfully
- or NO statements are executed at all.

#### Prepared statements

For, `Exec(), Query(), QueryRow()`all use prepared statements behind the scenes to help prevent SQL injection attacks. They set up a prepared statement on the dbs connection, run it with the parameters provided, and then close the prepared statement. This might rather inefficient cuz are creating and re-creating the same prepared statements every single time. 

A better approach could be to make use of the `DB.Prepare()`to create our own prepared statement once, and re-use that instead. This is particularly true for complex SQL statements and are prepared very ofen insert of tens of thousands -- fore:

```go
// need somewhere to store the prepared statement for the lifetime of our web app.
// A neat way to embed in the model alongside connection pool 
type ExampleModel struct {
    DB  	 *sql.DB
    InsertSmt *sql.Stmt
}

// Create a constructor for the model, in which we set up the prepared statement
func NewExampleModel(db *sql.DB) (*ExampleModel, error) {
    // use the prepared method to create a new prepared statement for the 
    // current connection pool -- this is a sql.Stmt object which represents the 
    // prepared statement
    insertStmt, err := db.Prepare("INSERT INTO ...")
    if err != nil {
        return nil, err
    }
    return &ExampleModel{db, insertStmt}, nil // store it in the object
}

// Any methods implemented against the ExampleModel object will have access to the preapred
func (m *ExampleModel) Insert(args...) error {
    // how call the `Exec` against the prepared statement
    _, err := m.InsertStmt.Exec(args...)
    return err
}

// in the main, need to initialize a new `ExampleModel` struct using the ctor function
func main(){
    db, err := sql.Open(...)
    if err != nil {
        errorLog.Fatal(err)
    }
    defer db.Close()
    
    // Create a new ExampleModel object, which includes the prepared statement
    exampleModel, err := NewExampleModel(db)
    if err != nil {
        errorLog.Fatal(err)
    }
    
    // Also defer a call to Close() on the prepared statement to ensure that it is 
    // properly closed before main terminated
    defer exampleModel.InsertStmt.Close()
}
```

So, prepared statement exist on dbs connections. So, cuz Go uses a pool of many dbs connections, what actually happens is that the first time a prepared steament is used it gets created on a particular dbs connection. Note that the `sql.Stmt`then remembers which connection in the pool was used. The next time, the `sql.Stmt`will attempt to use the same dbs connection again. If that connection is closed or in use the statement will be re-prepared on another conenction.

### Dynamic HTML templates

- Pass dynamic data to your HTML templates in a simple scalable and type-safe way.
- Use the various actions and functions in Go’s `html/template`to control the display of dynamic data
- Createa template cache so that your templates aren’t being read from disk for each HTTP request
- Gracefully handle template rendering errors at runtime
- Implement a pattern for passing common dynamic data to your web pages without repeating code.
- Create your own *Custom function*.

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
	// ...
	files := []string{
		"./ui/html/base.html",
		"./ui/html/pages/view.html",
		"./ui/html/partials/nav.html",
	}
	
	ts, err := template.ParseFiles(files...)
	if err != nil {
		app.serverError(w, err)
		return
	}
	
	// use the ExecuteTemplate method to dynamically
	// insert the snippetView template into the base template.
	err = ts.ExecuteTemplate(w, "base", snippet)
	if err != nil {
		app.serverError(w, err)
	}
}
```

So, need to create a `view.html`file containing the HTML markup for the page. Just like:

```html
{{define "title"}}Snippet #{{.ID}}{{end}}

{{define "main"}}
    <div class="snippet">
        <div class="metadata">
            <strong>{{.Title}}</strong>
            <span>#{{.ID}}</span>
        </div>
        <pre><code>{{.Content}}</code></pre>
        <div class="metadata">
            <time>Created: {{.Created}}</time>
            <time>Expires: {{.Expires}}</time>
        </div>
    </div>
{{end}}
```

#### Rendering multiple pieces of data

An important thing to explain is that Go’s `html/template`package allows U to pass in one-and only one- item of dynamic data when rendering a template. Within your HTML templates, any dynamic data that you pass in is represented by the `.`character -- in this specific case the underlying type of dot will be a `models.Snippet`struct. When the underlying type of dot is a struct, can render the value of any exported field in your templates by postfixing dot with field name.

And a lightweight and type-safe way to achieve this is to wrap your dynamic data in a struct which acts like a single *holding structure* f