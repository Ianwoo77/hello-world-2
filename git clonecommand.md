# `git clone` command

```sh
git clone <URL> <directory_name> # clone a remote repository
```

The `git clone`command does the following -- 

1. Create a project directory inside the current directory
2. Create the local repository
3. Download all the data from the remote repository
4. Add a conenction to the remote repository that was cloned by default it will have the shortname `origin`in the new local repository

```sh
 git clone https://github.com/gitlearningjourney/rainbow-remote.git friend-rainbow
```

For this:

- Cloned the remote repository onto your computer and created a second local repository called `friend-rainbow`
- Are not in the directory in the command line -- cuz cloning a Git repository does not mean U automatically navigate into it.

```sh
cd friend-rainbow
git remote -v
git branch --all
git log
```

- `git remote`output -- the `origin`remote repository shortname is already listed
- `git branch`shows a pointer called `origin/HEAD`that points to the `origin/main`remote-tracking branch.

Will dive deeper into what happens during the cloning process and answer -- 

- What is the `origin/HEAD`pointer
- Why is there no local `feature`in the new local repository
- Why was the `origin`shortname automatically created fro the new local repository.

#### What is `ORIGIN/HEAD`

When clone a repository, Git needs to know which branch it should be on when it’s done cloning. The `origin/HEAD`pointer determines which branch this is. In the Rainbow project, `origin/HEAD`points to the `main`branch -- which is why cloned the repository is on the `main`in the `friend-rainbow`repository.

By contrast, noticed that in the `rainbow`repository you are currently on the `feature`branch -- but in the `friend-rainbow`repository, the local `feature`branch doesn’t even exist.

#### Cloning Repositories and Different Types of Branches

In the `git log`output -- can see that in the `friend-rainbow`repostiory there is no reference to the local `feature`branch -- there is a reference to the `origin/feature`remote-tracking branch.

```sh
git branch -all
git switch feature
git branch --all # *feature
```

In the step 3, can wee that there is a new local `feature`branch and your friend is on it. NOTE -- Why the `friend-rainbow`repository already has the `origin`shortname assigned to the connection to the `Remote`repostiory. Recall you learned that for a local repository to communicate with a remote repository -- the local repository must have a connection with a shortname to the remote repository stored within it.

#### The ORIGIN shortname

Learned that for a local repository to communicate with a remote repository, the local repository must have a connection with a shortname to the remote repository stored within it. To work with the remote repository, U had to explicitly associate its URL with a shortname using the `git remote add <shortname> <URL>`command. This is cuz U created the `rainbow`repository locally using the `git init`command, and it had not yet any interaction with the remote repository. 

If run the `git remote`-- can see have the `origin`shortname listed -- means that the `friend-rainbow`repository already has the remote repository URL associated with the shortname `origin`. This is cuz your friend’s local repository did not cloning the remote repository URL was associated with a shortname in the local repository, and `origin`is the default shortname Git associates with a remote repository when clone it.

### Deleting Branches

The main reason to delete branches is to keep a Git project organized and uncluttered. Before deleting -- should always make sure that either U have merged it into another or U are sure don’t want to use any of the work that is found only on that branch.

Note -- When delete a branch with commits that are not part of any other branch, *you don’t delete the commits that are part of that branch.* The commits **still** exist in your commit history. However, they are no longer easy to reach.

To fully delete a branch, U need to delete the remote branch, the remote-tracking branch, and the local branch.

To delete a remote branch and a remote-tracking branch, use the `git push <shortname> -d <branch_name>`command, with this, essentially upload a deletion to the remote repository.

`git push <shortname> -d <branch_name>`
Delete a remote branch and the associated remote-tracking branch

NOTE -- Can also delete a remote branch directly on the website of a hosting service, but keep in mind that this will not delete the remote-tracking branch.

So to delete a local branch, u use the `git branch`with the `-d`option, passing in the name of the branch U want to delete. `git branch -d <branch_name>`

```sh
git branch --all
git push origin -d feature # in the remote, also no longer be there
git branch --all
git switch main
git branch -d feature
git branch --all
```

In the step2, deleted the remote `feature`branch and the `origin/feature`remote-tracking branch, in 3, see there is no remote in the repository.

As can see, in the rainbow there still a feature and an `origin/feature`. The fact that your friend deleted the `feature`and the `origin/feature`in his respository does not affect your repository.

## Using `nil`channel

A common mistake while working with Go and channel is forgetting that `nil`channels can sometimes be helpful. So what are `nil`channels, and why should we care about them -- like:

```go
var ch chan int
<-ch // block forever, not panic

var ch chan int
ch <- 0 // same
```

Fore, implement a `func merge(ch1, ch2 <-chan int) <-chan int`to merge two channels into a single channel. By merging them -- we mean each message received in either `ch1`or `ch2`will be sent to the channel returned.

```go
// naive imp
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for v := range ch1 {
            ch <- v
        }
        for v := range ch2 {
            ch <- v
        }
        close(ch)
    }()
    return ch
}
```

The main issue with this -- receive from both channels, and each message ends up being published in `ch`-- received from `ch1`and **then** we receive from `ch2`-- it means that we won’t receive from `ch2`until `ch1`is closed. This doesn’t fit our use case, as `ch1`may be open forever  -- so we want to receive fromboth simutaneously.

```go
func merge(ch1, ch2 <- chan int) <-chan int {
    ch := make(chan int, 1)
    go func(){
        for {
            select {
            case v := <-ch1:
                ch <- v
            case v := <ch2:
                ch <- v
            }
        }
        close(ch)
    }()
    return ch
}
```

The problem with this is `close(ch)`is unreachable. Looping over a channel using the `range`operator breaks when the channel is closed. However, the way we implemented a `for/select`doesn’t catch when either `ch1`or `ch2`is closed.

```go
ch1 := make(chan int)
close(ch1)
v, open:= <-ch1
fmt.Print(v, open)   // 0 false
```

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    ch1Closed := false
    ch2Closed := false
    go func(){
        for {
            select {
            case v, open := <-ch1:
                if !open {
                    ch1Closed= true
                    break
                }
                ch <-v
                
            case v, open := <-ch2:
                if !open {
                    ch2Closed= true
                    break
                }
                ch <-v
            }
            
            if ch1Closed && ch2Closed{
                close(ch)
                return
            }
        }
    }()
    return ch
}
```

For this, defined two boolean values -- once we receive a message from a channel, check whether it’s a  closure signal, if so, handle it by marking the channel as closed -- After both channels are closed, close the merged channel and stop the goroutine.

What is the problem with this code, apart from the fact that it’s starting to get complex -- there is no marjor isue, when one of the two channels is closed, the `for`loop will act as a **busy -- waiting loop**, meaning it will keep looping even though no new message is received in the other channel. Have to keep in mind the behavior of the `select`statement in our example -- say `ch1`is closed, when reach `select`again, it will wait for one of these 3 conditions to happen -- 

- `ch1`is closed
- `ch2`has a new message
- `ch2`closed.

As long as don’t receive a message in `ch2`and this channel isn’t closed, will keep looping over the first case. Could try to enchance the state machine part and implement sub- `for/select`loops within each case. This would make our code even more complex and harder to understand -- it’s the right time to come back to `nil`channels. Receiving from a `nil`channel will block forever -- how about using this idea in our solution -- instead of setting a Boolean after a channel is closed -- assign this channel to `nil`-- like:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for ch1 != nil || ch2 != nil { // continues if at least on is not nil
            select {
            case v, open := <-ch1:
                if !open {
                    ch1 = nil
                    break
                }
                ch <- v
                
            case v, open:= <-ch2:
                if !open {
                    ch2 = nil
                    break
                }
                ch <- v
            }
        }
        close(ch)
    }()
    return ch
}
```

First, loop as long as least one channel is still open. Then fore, if `ch1`is closed, we assign `ch1`to `nil`-- hence, during the next loop iteration, the `select`statement will only wait for two conditions.

- `ch2`has a new message
- `ch2`is closed

`ch1`is no longer part of the equation as it’s `nil`channel -- Meanwhile, keep the same logic for `ch2`and assign it to `nil`after it’s closed.

In summary -- have seen that waiting or sending to a `nil`channel is just blocking action. And this behavior isn’t useless.

### about channel size

When create a channel using the `make`built-in, the channel can be either unbuffered or buffered. And related to this topic, two mistakes happen fairly frequently -- being confused about when to use one or the other, and if we use a buffered, what size to use -- 

```go
ch1 := make(chan int)
ch2 := make(chan int, 0)
```

Using an unbuffered channel the sender will block until the recevier receives data from the channel. Conversely, a buffered channel has a capacity, and it must be created with a size greater then or equal 1.

Conversely, with a buffered, a sender can send messages while the channel isn’t full. For the fundamental differences between these two channel types -- Channels are a concurrency abstraction to enable communication among goroutines -- but what about synchornization -- in concurrency, sync means that we can guarantee that mutliple goroutines will be in a known state at some point. Fore, a mutex provides sync cuz it ensures that only one goroutien can be in a critical section at the same time.

- An unbuffered channel enables *synchronization* -- Have the guarantee that two will be in a known state -- one receiving and another sending a message
- A buffered doesn’t provide any strong synchronization -- indeed -- a producer can send a message and then continue its execution if channel isn’t full. The only guarantee is that a goroutine won’t receive a message before it is sent.

Both channel types enable communication , but only one provides sync -- if need sync, must use unbuffered channels. Unbuffered channels may also be easier to reason about -- buffered can lead to obscure deadlocks that would be immediately apparent with unbuffered channels.

And there are other cases where unbuffered channels are prefearable -- fore, in the case of a notification channel where the notification is handled via a channel closure (`close(ch)`), here, using a buffered channel wouldn’t bring any benefits.

May approach the problem from this -- is there any good readon *not* to use a value of 1 -- list of possible cases where we should use another size -- 

- While using a worker pooling
- When using channels for rate-limiting problems.

### Possible side effects with string formatting

Formatting string is a common operation for developers -- It’s just pretty easy to forget the potential side effects of string formatting while working in a concurrent app.

#### *etcd* data race

`etcd`is -- distributed key-value store imp in Go, used in many projects -- to store all cluster data. Provides an API to interact with a cluster...

## Processing forms

Going to focus on allowing users of app to create new snippets via a HTML. The high-level workflow for processing this form will follow a std POST-Redirect-Get pattern and look like this -- 

1. The user is shown the blank form when they make a `GET`requst to `/snippet/create`.
2. The user completes the form and it’s submitted to the server via a `POST`request to `/snippet/create`.
3. The form data will be validated by our `snippetCreatePost`handler -- if there are any valiation failures the from will re-displayed with the appropriate form fields highlighted.

### Setting up a HTML form

```html
{{define "title"}}Create a new Snippet{{end}}
{{define "main"}}
<form action="/snippet/create" method="POST">
    <div>
        <label>Title</label>
        <input type="text" name="title">
    </div>
    <div>
        <label>Content</label>
        <textarea name="content"></textarea>
    </div>
    <div>
        <label>Delete in</label>
        <input type="radio" name="expires" value="365" checked> One Year
        <input type="radio" name="expires" value="7">One week
        <input type="radio" name="exipirs" value="1">One day
    </div>
    <div>
        <input type="submit" value="publish snippet">
    </div>
</form>
{{end}}
```

Then add a `Create snippet`link to the navigation bar for our app...

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
    data := app.newTempalteData(r)
    app.render(w, http.StatusOk, "crate.html", data)
}
```

### Parsing form data

Any `POST /snippets/create`requests are already being dispatched to our `snippetCreatePost`handler, now update this handler to process and use the form data when it’s submitted. At a high-level can break this down into two distinct steps -- 

1. First, need to use the `r.ParseForm()`method to *parse* the request body. This checks that the request body is well-formed, and then stores the form data in the request’s `*r.PostForm`map*. If there are any errors encountered when parsing the body -- then will return an error. The `r.ParseForm()`method is also idempotent. It can safely be called multiple times on the same request without any side-effects.
2. Then get to the form data contined in `r.PostForm`by using the `r.PostForm.Get()`method. Fore, can retreive the value of the `title`field with `r.PostForm.Get("title")`-- and if there is no matching field name in the form this will return the empty string “”, similar to the way that the query string parameters worked earlier in the book.

```go
// in the handler.go file
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    // this also works in the same way for PUT and PATCH requests
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    // Use the r.PostForm().Get() method to retreive the title and content
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    
    expires, err := strconv.Atoi(r.PostForm.Get("expires"))
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    id, err := app.snippets.Insert(title, content, expires)
    if err != nil {
        app.serveError(w, err)
        return
    }
    
    http.Redirect(w, r, fmt.Sprintf("/snipet/view/%d", id), http.StatusSeeOther)
}
```

#### Additional Info

Accessed the form values via the `r.PostForm`map -- but an alternative approach is to use the `r.Form`map -- The `r.PostForm`map is populated only for `POST PATCH PUT`-- and contains the form data from the request body.

In contrast, the `r.Form`map is populated for all requests -- and contains the form data from any request body and any query string paameters -- fore, if submitted to `/snippet/create?foo=bar`, could also get the value of the `foo`parameter by calling `r.Form.Get("foo")`-- note that in the event of a conflict, the request body will *take precedent* over the query string.

Using the `r.Form`map can be useful if your application sends data in a HTML form and in the URL, or you have an application that is agnositic about how parameters are passed.

#### The `FormValue`and `PostFormValue`methods

Note that the `net/http`package also provides the methods `r.FormValue()`and `r.PostFormValue()`-- essentially shortcut functions that call `r.ParseForm()`and then fetch the appropriate field value from `r.Form`or `r.PostForm`. Note that don’t use these cuz they *silently ignore any errors*.

#### Multiple-value fields

Strictly speaking, the `r.PostForm.Get()`method that we’ve used above only return the *first* value for a specific form field. This means that we can’t use it with form fields which potentially send multiple values.

```html
<input type="checkbox" name="items" value="foo">Foo
<input type="checkbox" name="items" value="bar">Bar
```

In this case, you will need to work with the `r.PostForm`map directly. The underlying type of the `r.PostForm`is `url.Values`-- which in trun has the underlying type `map[string][]string`-- So, for fields with multiple values can loop over the underlying map to access them like -- 

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprintf(w, "%d: Item %s\n", i, item)
}
```

#### Limiting form size -- 

Unless U are sending multipart data -- like `enctype="multipart/form-data"`then POST, PUT and PATCH request bodies are limited to 10MB -- if this is exceeded then `r.ParseForm()`will return an error. And if U want to change this limit can use the `http.MaxBytesReader()`like:

```go
// Limit the request body size to 4096 bytes
r.Body = http.MaxByteReader(w, r.Body, 4096)
err := r.ParseForm()
if err != nil {
    http.Error(w, "Bad Request", http.StatusBadRequest)
    return
}
```

With this code only the first 4096 bytes of the request body wll be read during the `r.ParseForm()`.

### Validating form data

- Check the `title`and `content`fields are not empty
- Check that the `title`field is not more than 100 characters long
- Check that the `expires`value exactly matches one of the permitted values.

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
    err := r.ParseForm()
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    title := r.PostForm.Get("title")
    content := r.PostForm.Get("content")
    expires, err := strconv.Atoi(r.PostForm.Get("expires"))
    if err != nil {
        app.clientError(w, http.StatusBadRequest)
        return
    }
    
    // Then initialize a map to hold any validation errors for the form fields
    fieldErrors := make(map[string]string)
    
    if strings.TrimSpace(title)=="" {
        fieldErrors["title"]="this field cannot be blank"
    }else if utf8.RuneCountInString(title) > 100 {
        fieldErrors["title"]="this field cannot be more than 100 characters long"
    }
    
    // Check that the content isn't black
    if strings.TrimSpace(content)=="" {
        fieldErrors["content"]= "this field cannot be blank"
    }
    
    // Check the expires value matches one of the permitted values 
    if expires != 1 && expires !=7 && expires != 365 {
        fieldErrors["expires"]= "this field must equal 1 7 or 365"
    }
    
    // if there are any errors, dump them in a plain text HTTP response and return from the handler
    if len(fieldErrors)>0 {
        fmt.Fprint(w, fieldErrors)
        return
    }
    id , err := app.snippets.Insert(...)
    if err != nil {
        app.serveError(w, err)
        return
    }
    http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOther)
}
```

Just note that using the `utf8.RuneCountInString()`-- no Go’s `len()`func -- cuz we want to count the number of *Characters* in the title rather than the number of bytes.