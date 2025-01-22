# Setting up the Rebasing

Need to create divergant histories -- are going to make one commit in the `rainbow`and push it to the remote repository. Then your friend, without fetching the changes from the remote repository, is going to make two commits in their repository, then made commits.

#### Unstaging and Staging Files -- 

Your friend is going to make changes to both of files in the `friend-rainbow`repository and add them to both to the staging area. Then they will realize they want to make two separate commits for the different pieces of work. For now, the current versions of `rainbowcolors`and `othercolors`file are in the working directory and staging area A.

```sh
# add both to othercolors and rainbowcolors
git status
git add rainbowcolors.txt othercolors.txt
git status
```

For this, firend added both the modified files to the staging area B. For now, assume that your friend decides they want to make separate commits for the work they did adding the color black to the list of non-rainbow colors and the work they did commenting on the rainbow.

```sh
git restore --staged <filename> # restore a file to another version of the file in staging area
```

Note that if you have a version of Git that is older than 2.23, don’t have access to the `git restore`-- your output may suggest you use the `git reset`command, which is another command that can unstage a file. Fore:

```sh
git reset HEAD rainbowcolors.txt
```

```sh
git restore --staged rainbowcolors.txt
git status # modified rainbowcolors.txt not staged
```

So the `git status`output shows that the updated version of the `othercolors.txt`file is still in the staging area, whereas the updated version of the `rainbowcolors.txt`has been unstaged and is no longer in the staging are. 

```sh
git commit -m "black"
git status
```

For this, made the black commit and `git status`output mentions that the `rainbowcolors`is a modified file in the working directory. Then fill add the changes made to the `rainbowcolors.txt`:

```sh
git add rainbowcolors.txt
git commit -m "rainbows"
```

Note that the version of the `rainbowcolors.txt`file in the staging area is now B, which the the version that is part of the rainbow commit. Just saw your friend was able to add files to and remove from the staging area in order to craft exactly the commits they wanted. The local `main`branch in the `rainbow`repo and the local `main`in the friend repo now have divergant development histories. Before your friend continues with the rebasing, need to make sure to fetch all the work you have pushed to the remote `main`from the remote.

#### Preparing to Rebase

U first have to fetch all the work that has been done on the branch that you want to rebase onto. Fore: 

```sh
git fetch
git log --all
```

Now fetched the gray commit from the remote repo, and the `origin/main`remote-tracking branch was updated to point to it. For now the `origin/main`remote-tracking in the friend represents the latest version of the remote `main`. friend is now ready to rebase their local `main`onto the `origin/main`remote-tracking branch.

#### The Five Stages of Rebase process -- 

To initiate the rebase, you use the `git rebase`cmd, Git will then carry out the 5 stages of the process itself. The only time you have to actively get involved is if there are any merge conflicts.

1. Find the common ancestor -- Git will identify the common ancestor of the two branches involved in the rebase: the branch you are on and the branch you are rebasing onto. The branch they will be rebasing onto will be the `origin/main`remote-tracking branch, common ancestor is just the `M2`commit.
2. Store info about the Branches involved in the rebase -- In the stage 2, Git will save the changes introduced by each commit of the branch you are onto a temporary area. Will also save additional info in the temporary area, such as which branch you are rebasing onto and where it was pointing when initiated the rebase.
3. Stage 3-- Reset HEAD -- Git will reset `HEAD`to point to the same commit as the branch you are rebasing onto. HEAD-> origin/main.
4. Git will apply the set of changes from each commit in turn, making a commit after it applies each set.
5. Switching onto the rebased branch -- Git will make the branch you rebased point to the last ocmmit it reapplies, and it will check out that branch so that HEAD points to it. `head->main->Ra’`

Git carries out the entire process itself, all you need to do is initiate it with `git rebase`command.

#### Rebasing and Merge Conflicts

Git will carry out the entire rebase process independently, unless it encounters merge conflicts, in this case, must step in and resolve them. The process for resolving merge conflicts while rebasing is similar to the process when doing a 3-way merge, with a few small differences. As Git applies the changes for each commit one by one, it will pause the process if it encounters merge conflicts in any re-applied commit. Once you are done resolving the merge conflicts in a specific commit, you need to add the updated files to the staging area and then instruct Go resume rebase process by entering the `git reabase`with `--continue`.

As with a merge, if at any point the process of resovling merge conflicts in a rebase U decide U don’t want to continue the rebase process, can choose to stop or abort the process by using the `git rebase`with `--abort`.

## Receiving function results with Channels

Can execute functions concurrently in the background and then collect their results via channels once they fiinsh. In Concurrent programming, can call functions in separate goroutines and later pick up their return values from the output channel. Fore:

```go
func findFactors(number int) []int {
	result := make([]int, 0)
	for i := 1; i <= number; i++ {
		if number%i == 0 {
			result = append(result, i)
		}
	}
}
```

But what if we want to call the function with the first number, and while it’s computing those factors, we call the function a second time with the second number -- `go findFactors(3419110721)`-- How do we wait and collect the results from the first call -- would use sth like a shared variable and a waitgroup fore -- there is a easy way -- using channels -- like:

```go
func main() {
	resultCh := make(chan []int)
	go func() {
		resultCh <- findFactors(341910721)
	}()
	fmt.Println(findFactors(4033836233))
	fmt.Println(<-resultCh)
}
```

Use this anonymous goroutine to collect the results of the `findFactors()`function and write them on a channel.

### Selecting Channels

used channels to implement message passing between two -- will see how to use Go’s `select`statement to read and write messages on multiple channels and to implement timeouts and non-blocking channels. Will also examine a technique for excluding channels that have been closed and consuming only fromt he remaining open channels.

#### Combining multiple channels

Don’t know on which channel the next message will be recieved -- the `select`statement lets us group read operations on multiple channels together, blocking the groutine until a message arrives on any one of the channels.

Given a concurrency problem -- may not always be clear whether can implement a solution using channels or mutexes. Internally, a channel is a pipe we can use to sned and receive values and that allows us to *connect* concurrent goroutines -- 

- *unbuffered* -- The sender blocks until the receiver is ready
- *Buffered* -- blocks only when the buffer is full

1. `G1`and `G2`are parallel goroutines -- They may be two goroutines executing the same func that keeps receiving messages from a channel, or two executing the same HTTP handler
2. G1 and 3 are concurrent -- All the goroutines are part of overall concurent structure, 1, 2, 3.

For this scenario, in general, parallel goroutines have to *synchroinzie*. When need to access or mutate a shared resource such as a slice. Synchronization is enforced with mutexex but not with any cahnnel types, in general, synchronization between parallel goroutines should be achievied via mutexes -- Conversely, concurrent goroutine have to *coordinate* and *orchestrate*. Fore, G3 needs to aggregate results from both G1 and G2.. Channels.

### Race problems

Race problems can be among the hardest and most insidious bugs as a a programmer can face -- must understand crucial aspects such as data races and race conditions -- their possible impacts, and how to avoid them.

#### Data races vs race conditions

A data race occurs when two or more goroutines simultaneously accesss the same memory location and at least one is writing. Fore, there is no guarantee that the first goroutine will either start or complete before the second one in the previous example. Can also face the case of an interleaved execution where both goroutines run concurrently and compete to access. This is a possible impact of a data race -- if two goroutines simultaneously access the same memory location with at least one writing that location -- the result can be hazardous. 

```go
var i int64
go func() {
    atomic.AddInt64(&i, 1)
}()
go func() {
    atomic.AddInt64(&i, 1) 
}()
```

Both goroutines update `i`atomatically -- an atomic operation can’t be interrupted, thus preventing two access at the same time -- Regardless of the goroutine’s execution order. Another is to synchronize the two with an ad hoc data structure like a mutex. Or using channels like:

```go
i := 0
ch := make(chan int)
go func() {
    ch <-1
}()
go func(){
    ch <-1
}()
i += <-ch
i += <-ch
```

For this it’s only goroutine writing to `i` -- also free of data races. Sum up -- Data races occur when multiple goroutines access the same memory location simultaneously, and at least one of them is writing.

And, instead of having two goroutines increment a shared variable, now each one makes an assignment fore:

```go
i := 0
mutex := sync.Mutex{}
go func(){
    mutex.Lock()
    defer mutex.Unlock()
    i = 1 // or =2 another goroutine
}()
```

For this time -- both goroutine access the same variable -- but not at the same time -- as the mutex protects it -- but is the example deterministic -- no -- Depending on the execution order, It has a *race condition*. A race condition occurs when the behavior depends on the sequence or the timing of events that can’t be controlled.

#### The Go memory model

There are some core principles we should be aware -- buffered and unbuffered offer just differ guarantees. To avoid unexpected race caused by a lack of understandning of the core specification of the language -- The Go memory model is a specification that defines the conditions under which a read from a variable in one goroutine can be guaranteed to happen *after* a write to the same variable in a different goroutine. It provides guarantees that developers should *keep in mind* to avoid data races and force deterministic output.

Within a single goroutine, there is no chance of unsynchoronized access. With multiple goroutines, should bear in mind some for these guarantees will use the notaion `A<B`to denote event A happens before event B.

- The exit of a goroutine isn’t guaranteed to happen before any event:

  ```go
  i := 0
  go func() {i++}()
  fmt.Println(i) // not guarantee, has a data race
  ```

- A send on a channel happens before the corresponding receive from the channel completes.

  ```go
  i := 0
  ch := make(chan struct{})
  go func() {
      <-ch //  (3)
      fmt.Println(i) //  (4)
  }()
  i++ // increment before a send (1)
  ch <- struct{}{} // (2)
  ```

  by transitivity, can ensure that access to `i`are sync and hence free from data races.

- Closing a channel happens before a receive of this closure -- 

  ```go
  i := 0
  ch := make(chan struct{})
  go func() {
      <-ch // 3
      fmt.Println(i) // 4
  }()
  i++  // 1
  close(ch) // (2)
  ```

- The last guaratee regarding channels. A receive from an unbuffered happens *before* send.

  ```go
  // buffered version
  i := 0
  ch := make(chan struct{}, 1)
  go func() {
      i=1
      <-ch
  }()
  ch<-struct{}{}
  fmt.Println(i)
  ```

  This leads to data race. For this, will both the read and write happen.

  ```go
  ch := make(chan struct{})
  go func() {
      i = 1
      <-ch // receive from unbuffered happens before a send
  }()
  ch <-struct{}{}
  fmt.Println(i)
  ```

## Rendering multiple pieces of data

An important thing to explain is that Go’s `html/template`allow to pass in one -- and *only one* item of dynamic data when rendering a template. But in a real-world app there are often multiple pieces of dynamic data that you want to display in the same page. A lightweight and type-safe way to achieve this is to wrap your dynamic data in a struct which acts like a singe *holding structure* for your data.

Create new `template.go`file, containg a `templateData`like:

```go
type templateData struct {
	Snippets *models.Snippet
}
```

Then just update the handler like:

```go
data := &templateData{Snippet: snippet}
err = ts.ExecuteTemplate(w, "base", data)
```

#### Nested templates -- 

It’s really important to note that when you are invoking one template from another, *dot* needs to be explicitly passed or pipelined to the template being invoked.

### Template actions and functions

In this going to look at the template actions and functions that Go provides. For `{{if}}`, the empty values, are `false, 0, nil`... And it’s important to grasp that the `with`and `range`actions change the value of dot. Fore:

- `{{index .Foo i}}`-- yields the value of `.Foo`at index `i`-- the underlying type of `.Foo`must be a `map slice array`and `i`must be an integer value.
- `{{bar := len .Foo}}`-- Assign the lengh of `.Foo`to the template variable `$bar`.

using `with`-- A good like;

```html
{{define "main"}}
    {{with .Snippet}}
        <div class="snippet">
            <div class="metadata">
                //...
```

Using `if`and `range`actions -- First update the `templateData`so that it contains a `Snippets`field for holding a slice of snippet, like:

```go
type templateData struct {
	Snippet  *models.Snippet
	Snippets []*models.Snippet
} // inlcude a slice
```

Update the `home`that it fetches the latest snippets from our dbs model and passes them to the `home.html`.

```go
data := &templateData{Snippets: snippets}

// use the ExecuteTemplate method to dynamically
// insert the snippetView template into the base template.
err = ts.ExecuteTemplate(w, "base", data)
if err != nil {
    app.serverError(w, err)
}
```

Lead over to the `home.html`just using `{{if}}`and `{{range}}`actions like

- Want to use `{{if}}`to check whether the slice of snippets is empty or not
- Use the `{{range}}`to iterate over all snippets in the slice.

```html
{{define "title"}}Home{{end}}
{{define "main"}}
    <h2>Latest Snippets</h2>
    {{if .Snippets}}
        <table>
            <tr>
                <th>Title</th>
                <th>Created</th>
                <th>ID</th>
            </tr>
            {{range .Snippets}}
                <tr>
                    <td><a href="/snippet/view?id={{.ID}}">{{.Title}}</a></td>
                    <td>{{.Created}}</td>
                    <td># {{.ID}}</td>
                </tr>
            {{end}}
        </table>
    {{else}}
        <p>There is nothing to see here...yet</p>
    {{end}}
{{end}}
```

#### Combining functions - 

It’s possible to combine multiple functions in tags -- using the parentheses `()`to surround the functions and their arguments as necessary -- Fore, the following tag will render the content `C1`if len is greater than 99 like:

`{{if (gt (len .Foo) 99)}} C1 {{end}}`

Controlling loop behavior -- Within a `{{range}}`, can use the `{{break}}`command to end the loop early. and the `{{continue}}`to immediately start the next loop iteration. Like:

```go
{{range .Foo}}
    {{if eq .ID 99}}
    	{{continue}}
    {{end}}
{{end}}
```

### Caching templates

Before add any more functionality to HTML -- good time to make some optimizations to codebase -- there are two main issues at the moment -- 

1. Each and every time we render a web page, our application reads and parses the relevant template files using the `template.ParseFiles()`function, could avoid this duplicated work by parsing the files once, when starting the app, and storing the parsed templates in an in-memory *cache*.
2. There is duplicated code in the `home`and `snippetView`handlers, and we could reduce this duplication bgy creating a helper function.

Create an in-memory map with the type `map[string]*template.Template`to cache parsed templates like:

```go
func newTemplateCache() (map[string]*template.Template, error) {
	cache := map[string]*template.Template{}

	// use the filepath.Glob() func to get a slice of all filepaths
	// match the pattern `./ui/html/pages/*.html`. This will essentially
	// gives a slice of all the filepaths for our app
	// fore: [ui/html/pages/home.html ui/html/pages/view.html]
	pages, err := filepath.Glob(".ui/html/pages/*.html")
	if err != nil {
		return nil, err
	}

	// Loop through the page one-by-one
	for _, page := range pages {
		// extract the file name from the full file path
		// and assign it to the name variable
		name := filepath.Base(page)

		files := []string{
			"./ui/html/base.html",
			"./ui/html/partials/nav.html",
			page,
		}

		ts, err := template.ParseFiles(files...)
		if err != nil {
			return nil, err
		}

		cache[name] = ts
	}
	return cache, nil
}
```

Then the next step is to initialize this cache in the `main`function and make it available to our handlers.

```go
type application struct {
    errorLog      *log.Logger
    infoLog       *log.Logger
    snippets      *models.SnippetModel
    templateCache map[string]*template.Template
}
// ... in the main():
templateCache, err := newTemplateCache()
if err != nil {
    errorLog.Fatal(err)
}

app := &application{
    errorLog, infoLog,
    &models.SnippetModel{DB: db},
    templateCache,
}
```

At this point, got an in-memory cache of the relevant template set for each of our pages, and our handlers have access to this cache via the `application`struct. Then in the `helpers.go`add `render()`like:

```go
func (app *application) render(w http.ResponseWriter, status int,
	page string, data *templateData) {
	ts, ok := app.templateCache[page]
	if !ok {
		err := fmt.Errorf("the template %s does not exist", page)
		app.serverError(w, err)
		return
	}

	w.WriteHeader(status)

	err := ts.ExecuteTemplate(w, "base", data)
	if err != nil {
		app.serverError(w, err)
	}
}
```

Then get to see the pay-off from these changes and can dramatically simplify the code. Fore:

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	snippets, err := app.snippets.Latest()
	if err != nil {
		app.notFound(w)
		return
	}

	app.render(w, http.StatusOK, "home.html", &templateData{
		Snippets: snippets,
	})
}
```

#### Automatically parsing partials

Before move on-- make our `newTemplateCache()`a bit more flexible so that it automatically parses all templates in the `ui/html/partial`folder like:

```go
for _, page := range pages {
    // extract the file name from the full file path
    // and assign it to the name variable
    name := filepath.Base(page)

    // Parse the base template file into a tempalte set.
    ts, err := template.ParseFiles("./ui/html/base.html")
    if err != nil {
        return nil, err
    }

    ts, err = ts.ParseGlob("./ui/html/partials/*.html")
    if err != nil {
        return nil, err
    }

    ts, err = ts.ParseFiles(page)
    if err != nil {
        return nil, err
    }

    cache[name] = ts
}
```

#### Catching runtime errors -- 

As soon as begin adding dynamic behavior to our HTML templates, there is a risk of encountering runtime errors. Fore, add a deliberate error to the `view.html`template and see what happens - like: `{{len nil}}`For this, our app has thrown an error, but the user has wrongly been sent a 200 OK response.

To fix this, need to make the template render a two-stge process -- should make a trial render by writing the template into a buffer. If this fails, can respond to the user with an error message. In the `render`handler like:

```go
// initialize a new buffer
buf := new(bytes.Buffer)

// Write the template to the buffer
err := ts.ExecuteTemplate(buf, "base", data)
if err != nil{
    app.serverError(w, err)
    return
}

w.WriteHeader(status)
buf.WriteTo(w)
```

### Common dynamic data

In some web app there may be common dynamic data that you want to include on more than one -- every webpage fore. Might want to include the name and profile picture of the current user, or a CSRF token in all pages with forms.

```go
type templateData struct {
	CurrentYear int
	Snippet     *models.Snippet
	Snippets    []*models.Snippet
}
```

Then add a `newTemplateData()`helper method to the app, which will return a `templateData`initialized with the current year like:

```go
func (app *application) newTemplateData(r http.Request) *templateData {
	return &templateData{
		CurrentYear: time.Now().Year(),
	}
}
```

Then update `home`and `snippetView`handlers to use this like:

```go
data := app.newTemplateData(r)
data.Snippet = snippet
app.render(w, http.StatusOK, "view.html", data)
```

Then just display to the template like:

```html
<footer>Powered by <a href="https://golang.org">Go</a>
    in {{.CurrentYear}}
</footer>
```

#### Custom template functions

The last part of this section about tmeplating and dynamic data, like to explain how to create your own custom functions to use in Go templates -- To illustate -- craete a custom `humanDate()`which outputs datetimes in a nice format. There are two main steps to doing this -- 

1. Need to create a `template.FuncMap`object containing the custom function
2. Need to use the `template.Funcs()`method to register this *before* parsing the templates.