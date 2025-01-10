# Hosting Services and Authentication

Two types of repositories -- Local repositories and remote repositories -- Local repositories are found on a computer, while remote repositories are hosted on a hosting service in the cloud. Using commands such as `git push, git clone, git fetch`and `git pull`. First will choose a hosting service, then will set up authentication details to connect to remote repositories over HTTPs or SSH.

### Setting up Authentication Credentials

When create a remote repository, there will be two wyas to make changes to it.

1. By logging into the hosting service via its website and making changeks there directly.
2. By making changes in local and uploading those changes to the remote repository on the hosting service.

Both need to *authentication*. Using HTTPs -- uses a username and some sort of password to allow you to securely connect to remote repositories. In GitHub, the authentication credential is called a *personal access token*. Namely, PASSWORD is just the Personal access token.

### Creating and Pushing to a remote Repository -- 

Can start working on a project using Git from either a local or a remote repository. This is the approach you are going to take with the Rainbow project in this -- 

1. Create a local repository
2. Create a remote repository and upload data to it
3. Work with local and remote repositories.

#### Starting from a remote repository -- 

To start to work on a git project from a remote repository, can either find a remote or create a new remote on a hosting service.

1. Find or create a remote
2. Clone(copy) the remote to your computer
3. Working with local and remote.

#### The Interaction Between Local and Remote Repositories -- 

Local repositories and remote ones act *Separately*. When it comes to working with them -- it’s just important to undersand that no interaction between them happens automatically. There is no *live connection* between the two.

#### Creating a remote Repository with Data

Fore, your friend wants to see what you have been working on. Need to create a remote repository and upload some data to it.

1. Create the remote repository on the hosting service
2. Add a connection to the remote repository in the local repository
3. Upload data from the local to the remote

Also will have to choose whether the remote repostiory will be public or private. This is a setting you can adjust on a hosting service for each repository. *Public* is visible to anyone on the internet, and *private* just only to the individuals given access to it. In both, can contribue to the repository only if are provided with access.

#### Adding a connection to the remote repository

A local repository can communicate with a remote repository when the local repository has a connection to the remote repository stored within it. This connection will have a name, and which we refer to as the *remote repository shortname* -- *shortname*. To do this use the `git remote add`command -- passing the shortname followed by the remote repository URL like:

```sh
git remote add <shortname> <URL> # add connectoin to a remote repostiory named <shortname> at <URL>
```

For this the rainbow repository was initialized locally, so are going to have to add a connection to the remote repository in the local repository explicitly. To see the list of connection to remote repositories stored in a local repository by shortanme, may use the `git remote`command, `-v`for *verbose*.

```sh
git remote # list the remote repostiory connections
git remote -v # with shortnames and URLs
# for now in the `.git/config` will see no connections to remote.
git remote # nothing displayed
git remote add origin https://github.com/Nil-None/rainbow-remote.git
git remote # origin
git remote -v # origin: https://... (fetch) (push)
```

Can see that represents the shortname stored in the `rainbow`that relates to the `rainbow-remote`is going in only one direction.

#### Remote Branches and Remote-Tracking Branches

When U push a local branch to a remote repository, create a *remote branch*. Do not *automatically* update when make more commits on local branches. Have to explicitly push commits from a local to remote. Note that *every* remote branch also has a *remote-tracking* branch -- is a reference in a local to the commit a remote branch pointed at the last time any network communication happened with the remote repository like a *bookmark* That a local repository knows about it. Can set up a tracking rels between a local and a remote by defining which rmote a local should track. Referred to as the *upstream branch*. Cuz, when push, Git needs to know which remote U want to push to. If has an upstream, just using `git push`with no args.

#### PUshing to a remote repo -- 

To push, will use the `git push`and pass the shortname for the remote repository and the name of the branch that U want to push. like:

```sh
git push <shortname> <branch_name>
# in this example
git push origin main
git branch --all # add a remotes/origin/main, represents the new origin/new remote-tracking
git log
```

At the moment, the `main`and `feature`have the same commits. In the real-world projs, your branches will often have different development histories and consists of different commits. So:

```sh
git switch feature
git push origin feature
git branch --all # added an origin/feature remote-tracking branch
```

Have now created a remote repository with data.

## Restricting Behavior

The use case can be pretty counterintutitive -- It’s about restricting a type to a specific behavior -- Imagine implement a custom configuration package to deal with dynamic configuration. Create a specific container for `int`via an `IntConfig`struct also exposes two methods -- like:

```go
type IntConfig struct {}
func (c *IntConfig) Get() int {
    // retrieve
}
func (c *IntConfig) Set(value int) {
    // upate
}
// suppose receive an `IntConfig` holds some specific configuration
// only interested in retrieving, read-only
// By creating an abstraction that restricts the behavior to retrieving only a config vlaue
type intConfigGetter interface {
    Get() int
}

// can rely `intConfigGetter` interface just
type Foo struct {
    threhold intConfigGetter
}
func NewFoo(threhold intConfigGetter) Foo {
    return Foo {...}
} // injects the configuration getter
func (f Foo) bar() {
    // reads configuration
    threhold := f.threhold.Get()
}
```

#### Interface pollution

Interfaces are made to create abstractions -- Main caveat when programming meets abstractions is remembering the abstractions *should be discovered* not *created*. Means shouldn’t start creating abs in our code if there is no immediate reason to do so. We shouldn’t design with interfaces but wait for a concrete need.

### Interface on the Producer Side

Go developers often misunderstand one question -- where should an interface live -- 

- *producer side* -- defined in the same package as the concrete imp.
- *consumer side* -- An interface defined in an external package where it’s used.

The *producer side* mode in Go in most cases this is **NOT** what we should do. Fore:

```go
type CustomerStorage interface {
    StoreCustomer(customer Customer) error
    GetCustomer(id string) (Customer, error)
    UpdateCustomer(customer Customer) error
    GetAllCustomers() ([]Customer, error)
    GetCustomersWithoutContract() ([]Customer, error)
    GetCustomersWithNegativeBalance() ([]Customer, error)
}
```

Interfaces are satisfied implicitly in Go -- Tends to be a game-changer. This means that it’s not up to the producer to force a given abstraction for all the clients. -- *abactractions should be discovered, not created*. Maybe another client wants to decouple its code but is only interested in the `GetAllCustomers`method, so in this case, this client can create an interface with a single method, referencing the `Customer`struct from the external package like:

```go
package client

type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

From a package organization -- A couple of things to note like:

- Cuz the `customerGetter` is only used in `client`, so unexported
- There is no dependency from `store`to `client`cuz the interface is satisfied implicitly.

### Returning Interfaces

While designing a function signature, May have to return either an interface or a concrete imp -- Understand why returning an interfaces -- in many cases, considered a bad practie in Go. Will consider two packages fore -- 

- `client`-- which contains a `Store`interface
- `store`-- which contains an imp of `Store`.

Fore, in the `store`, define an `InMemoryStore`imp the `Store`interface -- Create a `NewInMemoryStore`func to return a `Store`interface -- there is a dependency from the imp package to the client package in this design. In general, returning an interface restricts flexibility cuz force all the clients to use one particular type of abstraction.

- Returning structs instead of interfaces
- Accepting interfaces if possible

Also there are some exceptions. The most relevant one concerns the `error`type. And another like stdlib `io`

```go
func LimitReader(r Reader, n int64) Reader {
    return &LimitedReader {r, n}
}
```

Here, the func returns an exported struct `io.LimitReader`, the function signature is an interface `io.Reader`. In most cases, shouldn’t return interfaces but concrete imp.

### `any`syas nothing

In Go, an interface type that specifies zero methods is known as the *empty interface* -- `interface{}`-- With 1.18, the predeclared type `any`became an alias -- An `any`type can hold any *value* type -- 

```go
func main() {
    var i any
    i = 42
    i = "foo"
    i = struct {s string} {
        s: "bar"
    }
    i = f
   	_ = i
}
func f() {}
```

Lose all type information -- which requires a type assertion to get anything useufl out of the `i`variable.

## URL Query Strings

While are subject of routing, update the `snippetView`handler so that it accepts an `id`query string parameter like:
`/snippet/view?id=1`Later will use `id`parameter to select a specific snippet from a dbs and show it to the user.

1. needs to retrieve the value of the `id`from the URL query string, which can do using the `r.URL.Query().Get()`method -- will always return a string value for a parameter, or empty string.
2. Should validate it.

```go
func snippetView(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}
	fmt.Fprintf(w, "Display a specifc snippet with ID %d", id)
}
```

Then request http://localhost:4000/snippet/view?id=123. For all requests can’t be validated, 404 response returend

#### The `io.Wrtier`interface

The code introduced another new thing behind the scenes fore:
`func Fprintf(w io.Writer, format string, a ...any) (n int, err error)`We are albel to do this cuz the `io.Writer`is an interface. And the `http.ResponseWriter`object satisfies the interface cuz it has a `w.Write()`.

### Project Structure and organization

It’s important to explain upfront that there is no single right - or even recommended way to structure web applications. A *popular* and *tried-and-tested* approach. Fore:

- The `cmd`directory will contain the app-specific code for the executable apps in the project.
- The `internal`will conain the ancillary non-app-speicific code used in the proj. Fore hold potentially reusable code like validation helpers and the SQL dbs models for the proj.
- The `ui`contain the user-interface assets used by the web application. And the `ui/html`will contain HTML templates, and the `ui/static`will contain static files like CSS and images.

#### Refactoring your existing code

Quickly port the code already written to use this new structure like: It’s important to point out that the.

### HTML Templating and inheritance

Inject a blit of life into the project and develop a proper home page for our web app. Fore:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<header>
    <h1><a href="/">Snippetbox</a></h1>
</header>
<main>
    <h2>Latest Snippets</h2>
    <p>There's nothing to see here yet</p>
</main>
<footer>Powered by <a href="https://golang.org/">Go</a></footer>
</body>
</html>
```

For this need to use Go’s `html/template`package, which provides a family of functions for safely parsing and rendering HTML templates, can use the functions in this package to *parse* the template and then *execute* the template. like:

```go
func snippetView(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	ts, err := template.ParseFiles("./ui/html/pages/home.html")
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "internal server error", 500)
		return
	}

	// the last parameter to `Execute()` represents any dynamic data
	// that we want to pass in
	err = ts.Execute(w, nil)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "internal server error", 500)
	}
}
```

It’s important to point out that the file path pass to the `template.ParseFiles()`function must either be relative to your current working directory, or an absolute path.

#### Template Composition

As add more pages to this web app there will be some shared, biolerplate, HTML markup that want to include on every page -- like the header, navigation, and metadata inside the `<head>`. It’s just a good idea to create a *base* template which contains this shared content, can then *compose* with the page-specific markup for individual pages.

```html
{{define "base"}}
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>{{template  "title" .}} - Snippetbox</title>
    </head>
    <body>
    <header>
        <h1><a href="/">Snippetbox</a></h1>
    </header>
    <main>{{template "main" .}}</main>
    <footer>Powered by <a href="https://golang.org">Go</a></footer>
    </body>
    </html>
{{end}}
```

It’s essentially just regular HTML with some extra actions in {{}} -- fore the `{{define “base”}} ... {{end}}`action to define a distinct *named template called `base`*-- which contain the content want to appear on every page.

Inside that use the `{{template “title” .}}`.. action to denote that we want to *invoke* other named templates, called `title`and `main`at a particular point in the HTML. Then go back to the `home.html`and update it to define `title`and `main`.

```html
{{define "title"}}Home{{end}}
{{define "main"}}
    <h2>Latest Snippets</h2>
    <p>There is nothing to see here yet!</p>
{{end}}
```

Once done, the next step is to update the code in your `home`handler so that it parses both template files like:

```go
files := []string{
    "./ui/html/base.html",
    "./ui/html/pages/home.html",
}

ts, err := template.ParseFiles(files...)
if err != nil {
    log.Println(err.Error())
    http.Error(w, "Internal Server Error", 500)
    return
}

// use the ExecuteTemplate method to dynamically
// insert the snippetView template into the base template.
err = ts.ExecuteTemplate(w, "base", nil)
if err != nil {
    log.Println(err.Error())
    http.Error(w, "Internal Server Error", 500)
}
```

Now, instead of containing HTML directly, template set contains 3 named templates, use the `ExecuteTemplate()`method to tell Go that we specifically want to respond using the content of the `base`template.

#### Embedded partials

For some apps might want to break out certain into partials that can be reused in different pages or layouts. Create a partial containing the primary navigation bar for app.

```html
{{define "nav"}}
    <nav>
        <a href="/">Home</a>
    </nav>
{{end}}
```

Then update the `base`template so that it invokes the navigation partial using the `{{template “nav” .}}`