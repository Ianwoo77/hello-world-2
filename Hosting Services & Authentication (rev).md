# Hosting Services & Authentication (rev)

Have worked only on the `rainbow`repository, which is just a local repository, this marks the start of the second part of this -- in which U will work with hoting services and remote repositories -- 

### Hosting services and Remote Repostiories

Mentioned two types of repositories: local and remote -- Locals are found on a computer, while remotes are hosted on a hosting service in the cloud. Also mentioned that hosting services are companies that provides hosting for projects using Git. Commands such as `git push, git clone, git fetch, git pull`.

#### Setting up a Hosting Service Account 

Will cover the HTTPs protocol first. Just uses a username and some sort of pwd to allow U to securely connect to remote repositories. All hosting services allowed U to use the pwd to use to log in to your account on the hosting service for HTTPs authentication as well. 

GitHub -- Email address or username -- Person access token

#### Using SSH

The SSH protocol uses a public and private SSH key pair to allow U to securely connect to remote repositories.

1. Create an SSH key pair on your computer
2. Add the private SSH key to the SSH agent
3. Add the public SSH key to the hosting service account.

### Creating and pubing to a Remote repository

Look at the different ways U can use either local or remote repositories to start working on a Git project and why remote repositories are useful.

#### State of the Local Repository

At the start-- To start to work on a Git proj from a local repository, must first create a local repository on a computer using the `git init`and *make at least one commit*. Next, must create a remote repository on a hosting service.

```sh
git push # upload data to a remote repository
```

#### Start from a remote repository

To start to work on a Git project from a remote repository, can either find a remote repository that U want to work on or create a new remote repository on a hosting service. Then *clone* the remote repository to your computer.

#### The interaction between local and remote repositories

Act separately -- when it comes to working with them, it’s important to understand that no interaction between them happens *automatically*. No updates from the local repository to the remote repository will happen automatically, and conversely verse vice.

Note that a *private repository* is visible only to the invididuals given access to it, and a *public repository* is visiable to anyone on the internet.

#### Adding a connection to the remote repository

A local repository can communicate with a remote repository when the local repository has a conenction to the remote repository stored within it. This connection will have a name, which we refer to as the *remote repository shortname* or just *shortname*.

```sh
git remote add <shortname> <URL>
git remote # alist the remote repository connections stored in the local repository
git remote -v # with shortnames

# using:
git remote # for now, empty
git remote add origin https://github.com/../...git
git remote # origin
git remote -v # (fetch) and (push) both origin https://...
```

- The `rainbow`repository has a shortname associated with the remote repository URL, called `origin`
- The `rainbow-remote`repository still does not have any data in it.

### Remote branches and remote-Tracking Branches

Remote branches *do NOT* automatically update when U make commits on local branches. U have to explicitly push commits from a local branch to a remote branch. Every remote branch also has a *remote-tracking* branch. This is a reference in a local repository to the commit a remote branch pointed at the last time any network communiation happended wtih the remote repository.

Can set up a tracking relationship between a local branch and a remote branch by defining *which remote branch a local branch should track.* This is referred to as the *upstream branch*. There are some cases where Git will set the upstream branch automatically, but on other cases have to set it explicitly.

And, when push work from a local to a remote, Git needs to know which remote branch you wan to push to. If the local has an upstream branch defined for it, can use `git push`with no arguments, and Git will automatically push the work to that branch. However, if no upstream branch is defined for the local, need to specify which remote branch to push to when enter the `git push`command.

#### Pushing to a remote Repository

To push a local branch to your remote repository, will use the `git push`and pass in the shortname for the remote repository and the name of the branch that you want to push.

```sh
git push <shortname><branch_name>
```

After executed that, two things will happen -- 

1. A remote branch will be *created* in remote repository
2. A remote-tracking branch will be *created* in your local repository.

```sh
git branch --all # list local branches and remote-tracking branches
```

```sh
git push origin main
git branch --all # *main remote/origin/main feature
git log # (HEAD->main, origin/main, feature)
```

Noticed that when push a specific branch to a remote repository, only the data from that branch is uploaded to the remote repository, pushed the `main`branch to the remote repository, but the `feature`was not pushed to the remote repository.

At the moment, in rainbow, the `main`and `feature`have the same commits. In other words, their development histories, which can be traced by following the commiits and the paents links backward.

```sh
git swithch feature
git push origin feature
git branch --all # *feature main remote/origin/feature remote/origin/main
```

- Can see that in the repository there are two remote-*tracking branches*, `origin/main`and `origin/feature`.
- `rainbow-remote`, there are two *remote branches* -- `main`and `feature`.

And, there are two ways to make changes to a remote repository:

1. Logging in to the hosting service making changes directly.
2. By making changes in your local repository and uploading those changes to the remote repository.

## Interface on the producer side

Saw in the previous when interfaces are considered valuable. But Go developers often misunderstand one question -- where should an interface live -- Before delving into this -- make sure the terms we use throughout this section are clear -- 

- *Producer side* -- An interface defined in the same packae as the concrete implementation. Fore, package foo has interface and its implementation also, then package bar uses that.
- *Consumer side* -- An interface defined an external package where it’s used, Package bar defines the interface and use it, package foo implements that interface.

It’s common to see developerss creating interfaces on the producer side, along side the concrete imp. But in Go, in most cases this is **NOT** what we should do.

Fore, create a specific package store and retreive customer data, meanwhile, still in the same package, decide that ll the calls have to go through the following interface -- 

```go
package store
type CustomerStorge interface {
    StoreCustomer(customer Customer) error
    GetCustomer(id string) (Customer, error)
    UpdateCusomer(customer Customer) error
    GetAllCustomers() ([]Customer, error)
    GetAllCustomersWithoutContract() ([]Custtomer, error)
    GetCustomersWithNegativeBalance() ([]Customer, error)
}
```

Might think have some excellent reasons to create and expose this interface on the produce side. It’s a good way to decouple the client code from the actual implementation. Perhaps can *foresee* that it will help clients in creating test doubles. Is not best pracitce in Go.

Interfaces are satisfied implicitly in Go, which tens to be a game-changer compared to languages with an explicit implementation. *Abstractions should be discovered, not created* -- It’s not up to the producer to forece a given abstraction for all the clients. It’s up to the client to decide whether it needs some form of abstraction and then determine the best abstraction level for its needs.

Perhaps one client won’t be interested in decoupling its code, maybe another just wants to decouple its code but is only interested in the `GetAllCustomers()`method.

```go
package client
type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

In this case, this client can create an interface with a single method, referencing the `Customer`from external package.

- Cuz this interface is only used in the `client`, an remain unexported
- It looks like circular dependencies. Thiere is no dependency from `store`to `client`cuz the interface is satisified implicitly.

### Don’t Return interfaces

While design a func signature, may have to return either an interface or a concrete imp -- In many cases, considered it’s a bad practice in Go to return an interface.

- `client`-- which contains a `Store`interface
- `store`-- which contains an implementation of `Store`.

Fore, in the `store`, define an `InMemoryStore`struct that implements the `Store`interface -- created a `NewInMemoryStore`to return a `Store`interface -- there is a dependency from the implemenation package to the client package in this deign, and that may already odd.

- Returning structs instead of interfaces
- Accepting interfaces if possible.

There are some exceptions -- The most relevant one concerns the `error`type, Can also:

```go
func LimitReader(r Reader, n int64) Reader {
    return &LmitedReader{r, n}
}
```

### `any`says nothing

In Go, an interface type that specifies zero methods is known as the empty interface, `interface{}`. The predeclared type `any`became an alias for an empty interface -- all the `interface{}`occurrences can replaced by `any`, `any`can be considered an overgeneralization -- like:

```go
func main(){
    var i any
    i = 42
    i = "foo"
    i = struct {
        s string
    }{
        s: "bar",
    }
    i=f
    _ = i
}
```

In assigning a value to an `any`type, lose all type information, which requires a type assertion to get anything useful out of the `i`variable.

```go
package store
type Customer struct {}
type Contract struct {}
type Store struct{}
func (s *Store) Get(id string) (any, error) {} // returns any
func (s *Store) Set(id string, v any) error {} // accepts any
```

Cuz we accept and return `any`arguments, the methods lack expressiveness. If future developers need to use the `Store`struct, they will probabley have to dig into the documentation or read the code to understand.

By using `any`, we lose some of the benefits of Go as a statically typed language. Instead,  Should avoid `any`types and make our signatures explicit as much as possible.

```go
func (s *Store) GetContract(id string) (Contract, error) {}
func (s *Store) SetContract(id string, contract Contract) error {}
```

In this version, the methods are expressive, reducing the risk of incomprehension.

What are the cases when `any`is helpful -- take a look at the stdlib and see two examples where functions or methods accept `any`arguments -- the first is `encoding/json`-- like:

```go
func Marshal(v any) ([]byte, error) {}
```

Another is the `database/sql`-- if the query is parameterized -- the parameters could be any kind like:

```go
func (c *Conn) QueryContext(ctx context.Context, query string, args ...any) (*Rows, error){}
```

`any`can be helpful if there is a genuine need for accepting or returning any possible type.

### Being confused about when to use generics

Go 1.18 adds generics to the language, in a nutshell, this allows writing code with types that can be specified later and instantiated when needed. Like:

```go
func getKeys(m map[string]int) []string {
    var keys []string
    for k:= range m {
        keys= append(keys, k)
    }
    return keys
}
```

What if we want to use a similar feature for another map type fore `map[int]string`--  Before generics, Using code generation, reflection, or duplicating code... Like:

```go
func getKeys(m any) ([]any, error) {
    switch t := m.(type) {
    default:
        return nil, fmt.Errorf("unknown type: %T", t)
    case map[string]int:
        var keys []any
        for k := range t {
            keys = append(keys, k)
        }
        return keys, nil
    case map[int]string:
        //... same logic
    }
}
```

First, it increases boilerplate code -- when want to add case, it requires duplicating the `range`loop, meanwhile, the function now accepts an `any`type, which means we lose some of the benefits of Go as a typed language.

Second, Checking whether a type is supported is done at just **run time** instead of the compile time. 

Cuz the key type can be either `int`or `string`, we are obliged to run a slice of `any`type to factor out key types. This approach increases the effort on the caller side cuz the client may also need to perform a type check of the keys or an extra conversion.

----

Type parameters are generic type that can use with functions and types, fore, the following:

```go
func foo[T any](t T) {}
```

T is a type parameter -- when calling `foo`, we pass a type argument of `any`type, supplying a type argument is called *instantiation* -- and the work is done at compile time. This keeps type safety as part of the core language featurs and avoids run-time overhead.

```go
func getKeys[K comparable, V any](m map[K]V) []K {
    var keys []K
    for k := range m {
        keys= append(keys, k)
    }
    return keys
}
```

Note that in Go, the map keys can’t be of the `any`type. Otherwise leads to a compile error. Restricting type argumetns to match specific requirements is called *constraint* -- 

- A set of behaviors
- Arbitrary types

Checkout a concrete example -- Imagine don’t want to accept `any`and `comparable`type for the `map`key type.

```go
type customConstraint interface {
    ~int | ~string
}
func getKeys[K customConstraint, V any](m map[K]V) []K {
    //... same
}
```

#### Common uses and misuses

When are generics are useful -- 

- *Data structures* -- can use generics to factor out the element type if we implement a binary tree
- *Functions working with slices maps and channels* -- A function to merge two channels would work with any channel type. like:

```go
func merge[T any](ch1, ch2 <-chan T) <-chan T {}
```

- Factoring out behaviors instead of types - -fore the `sort`

```go
type SliceFn[T any] struct { // struct uses a type parameter
    s []T
    Compare func(T, T) bool
}
func (s SliceFn[T]) Len() int {return len(s.S)}
func (s SliceFn[T]) Less(i,j int) bool {return s.Compare(s.S[i], s.S[j])}
//...
// Then use this like:
s := SliceFn[int] {
    S: []int {3,2,3}
    Compare: func(a, b int) bool {
        return a<b
    },
}
sort.Sort(s)

```

Conversely, when is it recommended that we not use generics -- 

- When calling a method of type argument -- fore:

  ```go
  func foo[T io.Writer](w T) {
      //...
  }
  ```

  In this case, using generics won’t bring any value to our code.

- When making code more complex.

## Nested templates

It’s really important to note that when you are invoking one template from another template. dot needs to be explicitly passed or pipelined to the template being invoked -- like:

```html
{{template "main" .}}
{{block "sidebar" .}}{{end}}
```

As a general rule, just get into the habit of always pipelining dot whenever u invoke a template with the `{{template}}`or `{{block}}`actions.

#### Calling methods

If the type that you are yielding between {{}} tags as methods defined against it. Fore, if `.Snippet.Created`has the underlying type `time.Time`-- could render the name of the `weekday`by calling its `WeekDay()`method like:

`<span>{{.Snippet.Created.Weekday}}</span>`

Note that Can also pass parameters to methods like:

`<span>{{.Snippet.Created.AddDate 0 6 0}}</span>`

### Template actions and functions

In this going to look at the template *actions* and *functions* that Go provides -- NOTE:

- `{{with .Foo}} C1 {{else}} C2 {{end}}`- `else`for Foo empty
- `{{range .Foo}} C1 {{else}} C2 {{end}}`-- The underlying type of the `.Foo`must be an array slice, map or channel, and else for length is zero.

Just note that grasp that the `with`and `range`actions change the value of dot. Once U start using them, what `dot`represents can be different depending on where U are in the tempalte and what U are doing.

- `{{or .Foo .Bar}}`-- yields .Foo if .Foo is not empty, otherwise .Bar
- `{{index .Foo i}}`-- Yields the value of the .Foo at index i.

#### Using the `with`action

The good start to use the `{{with}}`like:

```html
{{with .Snippet}}
<div class="snippet">
    <div class="metadata">
        <strong>{{.Title}}</strong>
        <span>#{{.ID}}</span>
    </div>
    <pre><code>{{.Content}}</code></pre>
    <div class="metadata">
        <time>Created: {{.Created}}</time>
        <time>Expired: {{.Expires}}</time>
    </div>
</div>
{{end}}
```

#### Using the `if`and `range`actions

First update the `templateData`struct so that it contains a `Snippets`field for holding a slice of snippets like:

```go
type templateData struct {
	Snippet  *models.Snippet
	Snippets []*models.Snippet
}
```

Then update the `home`handler so that it fetches the latest snippets from our dbs model like:

```go
ts, err := template.ParseFiles(files...)
if err != nil {
    app.serverError(w, err) // Use the serverError() helper.
    return
}

// then create an instance of a templateData struct holding the slice of snippets
data := &templateData{Snippets: snippets}

// pass in the struct when executing the template
err = ts.ExecuteTemplate(w, "base", data)
if err != nil {
    app.serverError(w, err)
}
```

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
                    <td>#{{.ID}}</td>
                </tr>
            {{end}}
        </table>
    {{else}}
        <p>There is nothing to see here... yet</p>
    {{end}}
{{end}}
```

#### Additional info -- 

It’s possible to combine multiple functions in your template tags, using the `()`to surround the functions and their arguments as necessary -- like: `{{if (gt (len .Foo) 99)}} C1 {{end}}`

Controlling loop behavior -- Within a `{{range}}`action you can use the `{{break}}`command to end the loop early, and `{{continue}}`to immediately start the next loop iteration

```html
{{range .Foo}}
	{{if eq .ID 99}}
	{{continue}}
	{{end}}
{{end}}
```

### Caching templates

It’s a good time to make some optimizations to our codebase, there are two main issues at the moment -- 

1. Each and every time we render a web page, our appliation reads and parses the relevant template files using the `template.ParseFiles()`function, could avoid this duplicated work by parsing the files once-- When starting the app and storing the parsed templates in an in-memory *cache*
2. There is also duplicated code in the `home`and `snippetView`handlers, and we could reduce this duplication by creating a helper function.

Tackle the first point -- create an in-memory map with the type `map[string]*template.Template`to cache the parsed templates -- like:

```go
func newTemplateCache() (map[string]*template.Template, error) {
	cache := map[string]*template.Template{}

	// Use the filepath.Glob() to get a slice of all file paths that match the pattern
	// ".ui/html/pages/*.html" -- this will essentially gives us a slice of all
	pages, err := filepath.Glob("./ui/html/pages/*.html")
	if err != nil {
		return nil, err
	}

	// Loop through the page
	for _, page := range pages {
		// Extract the file name from the full file path
		name := filepath.Base(page)

		// Create a slice containing the filepaths for html
		files := []string{
			"./ui/html/base.layout.html",
			"./ui/html/partials/nav.html",
			page,
		}

		// parse the files into a template set.
		ts, err := template.ParseFiles(files...)
		if err != nil {
			return nil, err
		}

		// Add the template set to the map
		cache[name] = ts
	}

	return cache, nil
}
```

Then the next step is to initialize this cache in the `main()`function and make it available to our handlers as dependency via the `application`struct like:

```go
type application struct {
    //...
    templateCache map[string]*template.Template
}
//...
// initialize a new template cache...
templateCache, err := newTemplateCache()
if err != nil {
    errorLog.Fatal(err)
}

app := &application{
    errorLog: errorLog,
    infoLog:  infoLog,
    snippets: &models.SnippetModel{DB: db},
    templateCache: templateCache,
}
```

At this point, got an in-memory cache of the relevant template set for each of our pages, and our handlers have access to this cache via `application`struct.

```go
func (app *application) render(w http.ResponseWriter, status int,
	page string, data *templateData) {

	// Retrieve the appropriate template set from the cache based on the page name
	// if no entry exists in the cache with the provided name, then create a new error
	// and call the serverError() helper method that made eariler and return
	ts, ok := app.templateCache[page]
	if !ok {
		err := fmt.Errorf("the template %s does not exist", page)
		app.serverError(w, err)
		return
	}

	// Write out the provided HTTP status code
	w.WriteHeader(status)

	// Execute the template set and write the response body
	err := ts.ExecuteTemplate(w, "base", data)
	if err != nil {
		app.serverError(w, err)
	}
}
```

Got to see pay-off from these changes and can dramatically simiplify the code like:

```go
app.render(w, http.StatusOK, "home.html", &templateData{
    Snippets:snippets,
})

app.render(w, http.StatusOK, "view.html", &templateData{Snippet: snippet})
```

Finally, make the func a bit more flexible so that it automatically parses all templates in the `ui/html/partials`.

```go
//...
ts, err := template.ParseFiles("./ui/html/base.layout.html")
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
//...
```

