# Three-way merges

All of the merges have done up until this point in the `Rainbow`have been *fast-forward* merges -- in this chapter, will learn how to carray out a three-way merge -- in the process, you will also go over an eample of defining upstream branches and you will learn about what happens when U edit files *multiple* times in your working directory between commits. Finally, learn about pulling from a remote repository.

#### State of Local and remote repositories

Have two local repositories called `rainbow`and `friend-rainbow`and one remote repository called `rainbow-remote`. All three for now should be in sync -- should contain just the same *commits and branches*.

### Why are e-way merges Important

3-way merges are more complicated than fast-forward merges cuz they create merge commits and they may lead to *merge conflicts* -- It arises when you merge commits and they may lead to merge conflicts. -- where different changes have been made to the same parts in the same files.

Fore, working on the `Book`proj, co-author and I both decide to make a branch off the `main`at the same time, to work on different , make a `chapter_five`branch and coauthor makes `chapter_six`-- Work independent on chapter, coauthor finishes work on `chapter_six`first and proceeds to merge work into `main`and pushed.

And when I finish work on `five`branch -- which I will represent as commit D, also want to merge. But coauthor lets me know that they have already added work to the remote `main`-- so first need to update the `main`with the work that my coauthor added to the remote `main`. For this, can see ABC<-main, and ABCD<-five. Since it is not possible to follow the development history of the five to reach the `main`. This means the development histories of these branches have diverged. One option is to merge local `five`into the local `main` -- which will be just a 3-way merge, and then push the updated main to the remote.

Another option is to carry out a merge in the remote through a hosting service -- `pull request`-- assume decide to go ahead with the first option. As can see, 3-way merges produce merge commits, which are commits that can have *more than one parent commit*.

Next, you will set up a situation in the `Rainbow`proj where U will hae to do a 3-way merge.

### Setting up a 3way merge scenario

First, to start listing color are not part of the rainbow in a new file called othercolors.txt in the `rainbow`.

```sh
git add othercolors.tt
git commit -m "brown"
git log
```

Next, before push to remote, learn about defining upstream branches.

### Defining upstream branches

When U push work from a local branch to a remote, Git needs a way to know which remote branch U want to push the work to. If no upstream branch is defined for the local branch U are working on, U will need to specify which remote branch to push to when U enter the `git push`command. And if a local branch has an upstream branch defined, can just use the `git push`with no argumetns and Git will automatically push the work to that branch.

The upstream branches are automatically set up when clone a repository, but *not* when a repostiory is initialized locally. The `rainbow`repository was initialized locally, and U have not defined any upstream yet. To avoid specifying the remote short name and branch every time can define an upstream branch for the `main`and thereafter simply use the `git push`with no arguments.

Also learned that upstream branches are automatically set up when U clone a repository, but *not* when a repository is initialized locally.

NOTE -- Once an upstream branch has been defined for a local, can also use other commands, such as `git pull`-- without arguments.

To set up the upstream branch u will use the `git branch`with `-u`option -- short for `--set-upstream-to`. You will pass in the name of the remote branch as an argument, sepcifying remote repostiory shortname, fore `origin/main`.

```sh
git branch -u <shortname>|<branch_name>
# ... fore
git branch -vv
git branch -u origin/main
git branch -vv
```

1. In step 1, `git branch -vv`shows that here is no upstream set for local
2. step 2, comand output explicitly states that an upstream branch has been set
3. `git branch -vv`shows the `main`from the remote repository with shortname `origin`has been set for the local.

Then can:

```sh
git push
git log # HEAD-> main, origin/main
```

Have just learned how to define upstream branches in a local repository, and you have made the brown commit in the `rainbow`repository and pushed it to the remote repository. To end up in a situation where U will have to carray out a 3-way merge, there must be divergent development histoires between two branches. Next, your friend will continue working on the local `main`in their local repisotiry *without* fetching the changes U pushed to the remote `main`, which will cause the local `main`in the `friend-rainbow`repository and the `main`in the `rainbow-remote`to diverge.

## For Channels

See a concrete example based on iterating over a channel using a `range`-- create just two goroutines, both sending elements to two distinct channels. Fore:

```go
ch1 := make(chan int, 3)
go func() {
    ch1 <-0
    ch1 <-1
    ch1 <-2
    close(ch1)
}()
ch2 := make(chan int,3)
go func() {
    ch2<-10; ch2<-11;ch2<-12
    close(ch2)
}()
ch := ch1
for v := range ch {
    fmt.Println(v)
    ch = ch2
}
```

In this example, the same logic applies regarding how the `range`expression is evaluated. The expression provided to `range`is a `ch`chnnel to `ch1`, `range`just evaluates `ch`, performs a copy to a temporary variable, and iterates over element from this channel. Despite the `ch=ch2`statement, `range`keeps iterating over `ch1`not `ch2`.

And the `ch=ch2`statement isn’t without effect -- cuz assigned `ch`to the second variable, call the `close(ch)`will close the second channel.

#### Array

What’s the impact of using a `range`loop with an array -- Cuz the `range`expression is *evaluated before the beginning of the loop*, what is assigned to the temporary loop variable is a copy of the array. Fore:

```go
a := [3]int{0,1,2}
for i, v := range a {
    a[2]=10 // loop doesn't update the copy
    if i==2 {
        fmt.Println(v)
    }
}
```

### The impacts of using pointer elements in range loops

This looks at a specific mistake when using a `range`loop with pointer elements. If we are not cautions enough, can lead us to an issue where we reference the wrong elements. There are 3 main cases -- 

- In terms of semantics, storing data using pointer implies sharing the element -- 

  ```go
  type Store struct {
      m map[string]*Foo
  }
  func (s Store) Put(id string, foo *Foo) {
      s.m[id]=foo
  }
  ```

  Using the poitner implies the `Foo`element is shared by both the caller of `Put`and the `Store`.

- Sometimes we already manipulate pointers, it can be handy to store pointers directly in our collection instead of values.

- If store large structs, and these are frequently mutated, can use poitners instead to avoid a copy an insertion for each mutation -- like:

  ```go
  func updateMapValue(mapValue map[string]LargeStruct, id string){
      value := mapValue[id]
      value.foo = "bar"
      mapValue[id]=value // insert
  }
  func updateMapPointer(mapPointer map[string]*LargeStruct, id string) {
      mapPointer[id].foo="bar"
  }
  ```

Discuss common mistake with pointer elements in `range`loops, will consider the following two structs -- 

- A `Customer`
- A `Store`that holds a map of `Customer`pointers

```go
type Customer struct {
    ID string
    Balance float64
}
type Store struct {
    m map[string]*Customer
}
```

And the following method will iterate over a slice of `Customer`like:

```go
func (s *Store) storeCustomers(customers []Customer) {
    for _, customer := range customers {
        s.m[customer.ID]= &customer // stores the customer pointer in the map
    }
}
```

For this, iterate over the input slice using the `range`and store `Customer`pointers in the map. If:

```go
s.storeCustomers([]Customer {
    {ID: "1", Balance: 10},
    //...10, 0 2, 3
})
```

Here the result of the code just ouput the last item. Iterating over the `customers`using the `range`, regardless of the number of elements, create a single customer variable with a *fixed* address -- Can just verify this by.. print its address.

At the end of the iterations, have stored the same pointer in the map three times. This pointer’s last assignement is a reerence to the slice’s last element. Just creating a local variable. Like:

```go
func (s *Store) storeCustomers(customers []Customer) {
    for _, customer := range customers {
        current := customer
        s.m[current.ID]=&current
    }
}
```

Don’t store pointer referencing `customer`-- instead, store a pointer referencing `current`.

### Making wrong assumptions during map iterations

Iterating over a map is a common source of misunderstanding and mistakes -- 

- *Ordering*
- *Map update during iteration*

#### Ordering 

Regarding ordering -- just need to understand a few fundamental behabaviors of the map structure -- 

- It doesn’t keep the data stored by key
- Doesn’t preserve the order in which the data was added

Furthermore, when iterating over a map, shouldn’t make any ordering assumptions at all -- will consider -- Each index of the bcking array references a given bucket. In Go the iteration order over a map is *not specified*. There is also no guarantee that the roder will be same from one iteartion to the next.

#### Map insert during iteartion

In Go, updating a map during an iteration is **allowed**. It will not lead to a compilation error or a run-time error, -- there is another aspect we should consider when adding an entry in a map during iteration.

```go
m := map[int]bool {
    0: true,
    1: false,
    2: true,
}
for k, v := range m {
    if v {
        m[10+k] = true
    }
}
```

Note that the result of this code is *un-predictable*. If a map entry is created during iteration -- it may be produced during iteration or skipped. The choice may vary for each entry created and from one iteration to the ntext.

It’s essential to keep this behavior in mind to ensure that our code doesn’t produce unpredictable outputs -- 

```go
m := map[int]bool{
    //... same
}
m2 := copyMap(m)
for k, v := range m {
    m2[k]=v
    if v {
        m2[10+k]=true
    }
}
```

In this example, disassociae the map being read from the map being updated. Keep iterating over `m`, but the updates are done on `m2`. This new version creates predictable and repeatable output. To summarize -- **Shouldn’t**

- The data being ordered by keys
- Preservation of insertion order
- A deterministic iteration order
- An element being produced during the same iteration in which it’s added.

### How `break`statement works

```go
for i:=0; i<5; i++ {
    fmt.Printf("%d", i)
    switch i {
    default:
    case 2:
        break // break switch
    }
}
```

so:

```go
loop:
for ... {
    switch i {
    default:
    case 2:
        break loop
    }
}
```

### `defer`inside a loop 

The `defer`delays a call’s execution until the surrounding function returns. It’s mainly used to reduce boilerplate code -- fore, if a resource has to be closed eventually, can use the `defer`to avoid repeating the closure calls before every single `return`. One common mistake is to be unware of the consequence of using `defer`-- 

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        file, err := os.Open(path)
        if err != nil {
            return err
        }
        defer file.Close()
    }
    return nil
}
```

For this, there is a significant problem with this IMP -- `defer`schedules a function call when the *surrounding* function returns -- in this case, the defer calls are executed not during each loop iterationbut when the `readFiles()`returns. If `readFiles()`doesn’t return, the file descriptors will be kept open forever, causing leaks.

For this, have to create another surrounding functions around the `defer`that is called during each iteration. Fore, can implent a `readFile`holding the logic for each new file path -- 

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        if err := readFile(path); err != nil {
            return err
        }
    }
    return nil
}
func readFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()
    //..
    return nil
}
```

And another approach could use a closure -- 

```go
func readFiles(ch <-chan string) error {
    for path := range ch {
        err := func() err {
           //...
            defer file.Close()
        }()
        if err != nil {
            return err
        }
    }
    return nil
}
```

## Setting up a HTML form

Begin by making a new `create.html`file to hold the HTML for the form - 

```html
{{define "title"}}Create a New Snippet {{end}}

{{define "main"}}
  <form action="/snippet/create" method="post">
    <div>
      <label>Title:</label>
      <input type="text" name="title">
    </div>
    <div>
      <label>Content:</label>
      <textarea name="content"></textarea>
    </div>
    <div>
      <label>Delete in:</label>
      <input type="radio" name="expires" value="365" checked> One Year
      <input type="radio" name="expires" value="7"> One Week
      <input type="radio" name="expires" value="1"> One Day
    </div>
    <div>
      <input type="submit" value="Publish snippet">
    </div>
  </form>
{{end}}
```

For this, there is nothing particular special -- Then add  new `Create snippet`linke in the nav: Finally, update the `snippetCreateForm()`handler so that it renders our new page like so -- 

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	app.render(w, http.StatusOK, "create.html", data)
}
```

### Parsing form data

Any `POST /snippets/create`requests are already being dispatched to our `snippetCreatePost`handler. now update this handler to process and use the form data when it’s submitted. At a high-level can break this down into two distinct steps -- 

1. Need to use the `r.ParseForm()`to parse the request body -- this checks that the request body is well-formed -- and then stores the form data in the request’s `r.PostForm`map. And if there are any errors encountered when parsing the body, will return an error.
2. Can then get to the form data contained in `r.PostForm`by using the `r.PostForm.Get()`like: `r.PostForm.Get("title")`if there no matching field name will return an *empty string*. like:

```go
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	// first we call r.ParseForm() which adds any data in POST request bodies
	// to the r.PostForm map. This is also works in the same way for PUT and PATCH
	// if error, call app.ClientError() to send a 400
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// use the `r.PostForm.Get()` to retrieve the title and content from the map
	title := r.PostForm.Get("title")
	content := r.PostForm.Get("content")

	// The Get() always return the form data as a string
	expires, err := strconv.Atoi(r.PostForm.Get("expires"))
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOther)
}
```

#### The `r.Form`map

In the code -- we accessed the form values via the `r.PostForm`map -- but an alternative approach is to use the `r.Form`map -- The `r.PostForm`is pupulated only for *POST PATCh PUT* requests, in contrast, the `r.Form`contains for all requests and contains the form data from any request body *and* any query string parameters. fore: `/snippet/create?foo=bar`, could also get the value of the `foo`parameter by calling `r.Form.Get("foo")`. Also note that in the event of a conflict -- the request body value will take precedent over the query string parameter.

Using `r.Form`map can be useful if your app sends data in a HTML form and in the URL, or have an app that is agnostic about how parameters are passed.

#### The `FormValue`and `PostFormValue`methods

The `net/http`package also provides the methods `r.FormValue()`and `r.PostFormValue()`-- these are essentially shortcut function that call `r.ParseForm()`then fetch the appropriate field values. Recommend avoiding using these.

#### Multiple-value fields

Strictly, the `r.PostForm().Get()`only return just the *first* value for a specific form field. this means that can’t use with form fields which potentially send multiple values like a checkbox -- 

```html
<input type="checkbox" name="items" value="foo"> Foo
<input type="checkbox" name="items" value="bar"> Bar
```

In the case you will need to wrok with the `r.PostForm`map directly, not using `Get()`method. The underlying type of the `r.PostForm`map is **`url.Values`**. Which in turn has the underlying type just `map[string][]string`.

```go
for i, item := range r.PostForm["items"] {
    fmt.Fprintf(w, "%d: item: %s\n", i, item)
}
```

#### Limiting form size

Unless U are sending multipart data -- `enctype="multipart/form-data"`Then `POST PUT PATCH`request bodies are limited to 10M. Can:

```go
// limit the request body size
r.Body = http.MaxBytesReader(w, r.Body, 4096)
```

### Validating form data

Right now there is a glaring problem with our code -- not validating the user input from the form in any way. Should do this to ensure that the form data is present for:

- Check that the `title`and `content`fields are not empty
- Check that the `title`is not more than 100 characters long
- Check the `expires`exactly matches one for our permitted values.

```go
// Initialize a map to hold any validation errors for the form fields
fieldErrors := make(map[string]string)

// Check that the title...
if strings.TrimSpace(title) == "" {
    fieldErrors["title"] = "This field cannot be blank"
} else if utf8.RuneCountInString(title) > 100 {
    fieldErrors["title"] = "This field cannot be more than 100 characters"
}

// check the Content value isn't blank
if strings.TrimSpace(content) == "" {
    fieldErrors["content"] = "This field cannot be blank"
}

// Check the expires value
if expires != 1 && expires != 7 && expires != 365 {
    fieldErrors["expires"] = "This must be 1, 7 or 365"
}

if len(fieldErrors) > 0 {
    fmt.Fprint(w, fieldErrors)
    return
}
```

### Dispalying errors and repopulating fields 

Now that the `snippetCreatePost()`handler ia validating the data, the next stage is to manage these validation errors gracefully. If there are any validation errors, we want to just re-display the HTML form, highlighting the fields which failed validatoin and automatically re-populating any previously submitted data. So, Begin adding a new `Form`field to the `templateData`struct like:

```go
type templateData struct {
	CurrentYear int
	Snippet     *models.Snippet
	Snippets    []*models.Snippet
	Form        any
}
```

This this `Form`field to pass the validation errors and prevoulsy submitted data back to the tempalte. In the `handlers.go`define a new `snippetCreateForm`struct to hold the form data and any validation errors.

```go
type snippetCreateForm struct {
	Title       string
	Content     string
	Expires     int
	FieldErrors map[string]string
}
// ...
func (app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// The Get() always return the form data as a string
	expires, err := strconv.Atoi(r.PostForm.Get("expires"))
	if err != nil {
		app.clientError(w, http.StatusBadRequest)
		return
	}

	// Create an instance of the snippetCreateForm
	form := snippetCreateForm{
		Title:       r.PostForm.Get("title"),
		Content:     r.PostForm.Get("content"),
		Expires:     expires,
		FieldErrors: map[string]string{},
	}

	// Update the validation checks so that they operate on form instance
	if strings.TrimSpace(form.Title) == "" {
		form.FieldErrors["title"] = "This field cannot be blank"
	} else if utf8.RuneCountInString(form.Title) > 100 {
		form.FieldErrors["title"] = "This field cannot be more than 100 characters"
	}

	// check the Content value isn't blank
	if strings.TrimSpace(form.Content) == "" {
		form.FieldErrors["content"] = "This field cannot be blank"
	}

	// Check the expires value
	if expires != 1 && expires != 7 && expires != 365 {
		form.FieldErrors["expires"] = "This must be 1, 7 or 365"
	}

	// If there are any validation errors re-display the template
	// passing in the instance as dynamic data in the Form field
	if len(form.FieldErrors) > 0 {
		data := app.newTemplateData(r)
		data.Form = form
		app.render(w, http.StatusUnprocessableEntity, "create.html", data)
		return
	}

	// also need to update to pass the data from the instance
	id, err := app.snippets.Insert(form.Title, form.Content, form.Expires)
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOther)
}
```

Ok, now when there are any valiation errors we are re-displaying the `create.html`.

#### Updating the HTML template

Then the next thing that we need to do is update our `create.html`to display the validation errors and re-populate any previous data -- Re-populating the form data is -- render this in the templates using tags like: `{{.Form.Title}}`

For the validation errors, the underlying type is `map[string]string`-- for maps, it’s possible to access the value for a given key by simply chaining the key name. Just like:

```html
{{define "title"}}Create a New Snippet {{end}}

{{define "main"}}
    <form action="/snippet/create" method="post">
        <div>
            <label>Title:</label>
            {{with .Form.FieldErrors.title}}
                <label class="error">{{.}}</label>
            {{end}}
            <!-- re-populate the title data -->
            <input type="text" name="title" value="{{.Form.Title}}">
        </div>
        <div>
            <label>Content:</label>
            {{with .Form.FieldErrors.content}}
                <label class="error">{{.}}</label>
            {{end}}
            <textarea name="content">{{.Form.Content}}</textarea>
        </div>

        <div>
            <label>Delete in:</label>
            {{with .Form.FieldErrors.expires}}
                <label class="error">{{.}}</label>
            {{end}}


            <input type="radio" name="expires" value="365"
                    {{if (eq .Form.Expirs 365)}} checked {{end}}> One year
            <input type='radio' name='expires' value='7' {{if (eq .Form.Expires 7)}}
            checked{{end}}> One Week
            <input type='radio' name='expires' value='1' {{if (eq .Form.Expires 1)}}
            checked{{end}}> One Day
        </div>
        <div>
            <input type="submit" value="Publish snippet">
        </div>
    </form>
{{end}}
```

Then fix the problem by updating the `snippetCreate()`so work for this new html:

```go
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
	data := app.newTemplateData(r)
	data.Form= snippetCreateForm{Expires: 365}
	app.render(w, http.StatusOK, "create.html", data)
}
```

After submission U should see the form re-displayed, with the correctly re-poulated snippet content and expiry option.