# Where Variables Come From

Fore, variables like `USER`and `HOME`are predefined by the shell. Their valeus are set automatically when you log in.

```sh
work=$HOME/Projects
cd $work
pwd
echo $HOME
```

### Shortening Commands with Aliases

A variable is a name that stands for a value -- the shell also has names that stand in for commands.

```sh
alias g=grep
alias ll="ls -l"
```

Can also define an alias that has the same name as an existing commend. This practice is called *shadowing* the command. like:

```sh
alias less="less -c"
alias # shows all alias
unalias g # delete an alias
```

#### Redirecting Input and Output -- 

```sh
grep Perl animals.txt > outfile
cat outfile
```

Have just redirected stdout to the file `outfile`instead the display.

```sh
echo There was just one match >> outfile
cat outfile
```

Many Linux commands that accept filename as a argument like: An example is `wc`for counting lines..

```sh
wc < animals.txt # reading from redirected stdin 
```

Sometimes, need the shell to treat whitespace as significant. To force the shell to treat spaces as part of a filename, using single or double quotes, or backslashes.

Double quotes tell the shell treat all charactes literally exept for certain dollar signs, and a few others.

```sh
echo "Notice that $HOME is evaluated"
echo 'Notice that $HOME is not'
```

And Backslashes acts as escape charactrs even within double quotes. fore:

```sh
echo "The value of \$HOME is $HOME"
```

And just note that *A leading backslash before an alias escapes the alias*.

#### Locating Programs to be Run --

When the shell first encounters a simple command -- Quick as a flash, the shell splits the string, like: `ls *.py`-- `ls`and `*.py`-- in this case, the first word is he name of a program on disk, and the shell must locate the program to run it.

So, how dows the shell locate `ls`in the `bin`directory -- behind the scenes, the shell consults a pre-arranged list of directoris that it holds in memory. Called *search path*. This list is stored as value of the shell:

```sh
echo $PATH
```

Directories in a search path are separated by colons. fore, `tr`command -- translates one character into another:

```sh
echo $PATH | tr : "\n"
```

So the shell consults directories in your search path from first to last when locating a program like ls. 

And to locate a program in your search path, using `which`command.

```sh
which cp
which which
```

Or the more powerful `type`command -- a shell builtin that also locates aliases, functions, and shell builtins.

```sh
type cp
type ll
```

### Environments and initializaion Files

A running shell holds a bunch of important information in variables: the search path, current directories. It would be tedious to define every shell’s environment by hand. The solution is to define the environment once, in shell scripts called *startup files* and *initialization files*. It’s located in your `home`directory and anmed `.bashrc`.

If does not exist, create it. And any changes you make to the `$HOME/.bashrc`do not affect any *running* shells, only future shells. can force a running shell to reread an execute `$HOME/.bashrc`.

## Git and the Command Line

Technology that can be used to track changes to a project and thelp multiple people to collaborate on a project. At a basic level, a project version controlled by Git consists of a folder with files in it, and Git tracks the changes that are made to the files in the proj.

#### Initializing a locl Repository

Is represented by a hidden directory called `.git`that exists within a proj directory. It contains all the data on the changes that have been made to the files in a proj. And, to trun a proj into a local repository, have to *initialize* , or create the repository.

```sh
git init # by default create a branch called master
git init -b main # main branch name
```

Inside the `.git`directory are various files and directories -- some of them represent the areas of Git that you are going to learn -- 

#### The areas of Git

There are 4 important areas to be aware of when you are working with Git -- 

- Working directory
- Staging area
- Commit history
- Local repository

Working directory -- contains files and directories in the porj directory that represent one version of a proj.

Staging area -- The *staging area* is similar to a rough draft space. It is where U can add and remove files. The staging area is represented by a file in `.git`called `index`.

Introducing the `commit`history -- It is represented by the objects directory inside the `.git`. Every commit has a commit hash -- *commit ID*.

For now, even thought the `readme.md`is in the working dirctory, it is not part of repostiory yet. so, an *untracked* file is a file in the working directory that Git is not version controlling -- therefore, it is not part of the repository. Once U add a file to the staging area and include it in a commit, the file becomes a *tracked* file.

## Checking an error Type

The previous just introduced a posible way to wrap errors using `%w`directive,  It’s also essential to change our way of checking for a specific error type. Otherwise, may handle errors inaccurately. fore, will write an HTTP handler to return the transaction amount from an ID. Our handler will parse the request to... 

1. If ID invalid
2. if querying the DB fails.

Former 400, latter, want to return `ServiceUnavailable(500)`. To do, create a `transientError`to mark that an error is just temporary.

```go
func getTransientAmount(transientID string) (float32, error) {
	if len(transientID) != 5 {
		return 0, fmt.Errorf("id is invalid: %s", transientID)
	}

	amount, err := getTransientAmountFromDB(transientID)
	if err != nil {
		return 0, transientError{err: err}
	}
	return amount, nil
}
```

Then write the HTTP handler that checks the error type to return the appropriate HTTP status code -- 

```go
func handler(w http.ResponseWriter, r *http.Request) {
	transientID := r.URL.Query().Get("transaction")
	amount, err := getTransientAmount(transientID)
	if err != nil {
		switch err:=err.(type) {
		case transientError:
			http.Error(w, err.Error(), http.StatusServiceUnavailable)
		default:
			http.Error(w, err.Error(), http.StatusBadRequest)
		}
		return
	}
	// write response
}
```

For this, using a `switch`on the error type, return the appropriate HTTP status code, 400 or 503. But, want to perform a small refactoring of the `getTransactionAmount`-- The `transientError`will be returned -- Using `getTransactionAmount`now wraps this error using the `%w`directive like:

```go
amount, err := getTransientAmountFromDB(transientID)
if err != nil {
    // wraps the error intead of returning a transientError directly
    return 0, fmt.Errorf("failed to get transactionID: %s: %w",
                         transientID, err)
}

func getTransactionAmountFromDB(transactionID string) (float32, error) {
    //...
    if err != nil {
        // the func now returns the transientError
        return 0, transientError{err:err}
    }
}
```

If run the code -- always returns a 400 regardless of the error case.

What `getTransactionAmount`returns isn’t a `transientError`directly, it’s an *error wrapping `transientError`*. Go 1.13 came with a direcive to wrap an `error`and a way to check whether the wrapped `error`. Rewrite our imp of the caller using `errors.As()`-- like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        if errors.As(err, &transientError{}) {
            http.Error(..., http.StatusServiceUnavailble)
        }else {
            http.Error(w, err.Error(), http.StatusBadRequest)
        }
        return
    }
}
```

For this, got rid of the `switch`case type in this new version, now use `errors.As()`-- this requires the second argument to be a pointer -- otherwise, the function will compile but panic at runtime. 

`errors.As()`returns `true`-- indicate that the handler will return 503. If rely on Go 1.13+ wrapping, must use `errors.As()`to check whether an error is a specific type. This way, regardless of whether the error is returned directly by the function we call or wrapped inside an error, `errors.As()`will be able to **recursivley** unwrap our main error is a specific type.

### Checking an error value

With sentinel errors -- First will define what a sentinel error conveys -- like: how to compare an error to a value --

```go
import "errors"
var ErrFoo = errors.New("foo")
```

In general, the convention is to start with `Err`followed by the error type -- just a sentinel error conveys an *expected error* -- Fore, want to design a `Query`method that allows us to execute a query to a database. This method returns a slice of rows -- 

- Retuerns a sentinel value, fore, a `nil`slice
- Returns a specific error.

Fore, our method can return a specific error if no rows found, can classify this as an *expected error* -- cuz passing a request that returns no rows is allowed.

- `sql.ErrNoRows`-- returned when a query doesn’t return any rows
- `io.EOF`-- returned by an `io.Reader`when no more input is available.

That’s the general principle behind the sentinel errors -- they convey an expected error that clients will export to check.

- Expected errors should be designed as error values `var ErrFoo= errors.New("foo")`
- Unexpected errors should be designed as error types fore `type BarError struct {...}`, With `BarError`implementing the error interface.

```go
err := query()
if err != nil {
    if err == sql.ErrNoRow {
        //...
    }else {
        //...
    }
}
```

Call a `query`and get an error, checking whether the error is an `sql.ErrNoRows`is done using `==`. However, just as discussed -- a sentinel error *can also be wrapped*.  Go 1.13 provides -- Using `errors.Is()`like:

```go
if err != nil {
    if errors.Is(err, sql.ErrNoRow) {
        //...
    }
}
```

Here, using the `errors.Is()`instead of the `==`operator allows the comparsion to work even if the error is just wrapped with the `%w`. In smmary, if use error wrapping in our application with the `%w`directive and `fmt.Errorf`, checking an error against specific value should be done using `errors.Is()`instead of `==`.

## Customizing HTTP headers

Now need to update our app so that the `/snippet/create`route only responds to HTTP requests which use the `POST`method like -- 

### HTTP status codes

updating our snippetCreate handler function so that it sends a 405 (not allowed) unless the request is *POST*. fore:

```go
func snippetCreate(w http.ResponseWriter, r *http.Request) {
    // use r.Method to check whether the request is using POST or not
    if r.Method != "POST" {
        // if it's not, use the w.WriteHeader() to send 405
        w.WriteHeader(405)
        w.Write([]byte("Method not allowed"))
        return
    }
    //...
}
```

- It’s only possible to call `w.WriteHeader()`once per response, and after the status code has been written, it an’t be changed.
- And if don’t call `w.WriteHeader()`explicitly, then the first call to `w.Write()`will automatically send a 200.

#### Customizing headers

Another improvement we can make is to include an `Allow`header with the *405 Method Not Allowed* response. Using the `w.Header().Set()`method to add a new header to the response like:

```go
func snippetCreate(w http.ResponseWriter, r *http.Request) {
    if r.Mehod != "POST" {
        // using the `Header().Set()` to add an header
        w.Header().Set("Allow", "POST")
        w.WriteHeader(405)
        w.Write([]byte("Method not Allowed"))
        return
    }
    //...
}
```

#### The `http.Error`shortcut

If want to send a non-200 status code and a plain-text response body -- then it’s a good opportunity to use the `http.Error()`shortcut -- this is a lightweight helper func which takes a given message and status code. Then calls the `w.WriteHeader()`and `w.Write()`methods behind the scenes for us.

```go
func snippetCreate(w http.ResponseWriter, r *http.Request) {
    if r.Method!="POST" {
        w.Header().Set("Allow", "POST")
        //... just use http.Error() shorthand
        http.Error(w, "Method not Allowed", 405)
        return
    }
    //...
}
```

in terms of functionality this is almost exactly the same.

The `net/http`constants -- Specially, can use the constant `http.MethodPost`instead of the string `POST`, and the constant `http.StatusMethodNotAllowed`instead of the integer 405.

```go
if r.Method != http.MethodPost {
    w.Header.Set("Allow", http.MethodPost)
    http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
    return
}
```

System-generatted headers and content sniffling -- When sending a response Go will attempt to set the correct one for you by content sniffling the response body with the `http.DetectContentType()`. A common gotcha for web developer new to go -- By default JSON responses will be just sent with `Content-Type: text/plain`, can prevent from writing:

```go
w.Header.Set("Content-Type", "application/json")
w.Write([]byte(...))
```

Manipulating the header map -- For `w.Header()`, there are also some .. `Add, Del`and `Value`

### Using Query strings

1. It need to retreive the value of the `id`parameter form the URL query string, which we can do using the `r.URL.Query().Get()`method -- will always return a string value for a parameter.
2. Cuz the `id`parameter is untrusted user input, should validate it make sure it’s sane and sensible.

```go
func snippetView(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(r.URL.Query().Get("id"))
    if err != nil || id< 1 {
        http.NotFound(w, r)
        return
    }
    
    // use the Fprintf
}
```

### Proj structure and organization

```sh
mkdir -p cmd/web internal ui/html ui/static
touch cmd/web/main.go
touch cmd/web/handler.go
```

- The `cmd`directory will contain the *application-specific* code for executable apps in the proj.
- The `internal`will conain the ancillary non-app-specific code
- The `ui`directory will contain the user-interface assets used by the web app.

```go
func main(){
    mux := http.NewServeMux()
    mux.HandleFunc("/", home)
    //...
    err := http.ListenAndServe(":4000", mux)
}
```

```go
// handlers.go
func snippetCreate(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        w.Header().Set("Allow", http.MethodPost)
        http.Error(w, "method not allowed", http.StatusMethodNoteAllowed)
        return
    }
    w.Write([]byte(...))
}
```

### HTML Templating and inheritance

```go
ts, err := template.ParseFiles("./ui/html/pages/home.html")
if err != nil {
    //...
    return
}
err = ts.Execute(w, nil)
if err != nil {
    //...
}
```

#### Template composition

```html
{{define "base"}}
<html lang='en'>
    <head>
        <title>{{template "title" .}} - snippetbox</title>
    </head>
    <body>
        <main>{{template "main" .}}</main>
    </body>
</html>
{{end}}
```

Using the `{{define "base"}}... {{end}}`action to define a distinct named template called `base`. Inside the use of the `{{template "title" .}}`.. action to denote that we want to *invoke* other named templates at a particular point in the HTML.

```html
<!-- home.html -->
{{define "title"}}Honme{{end}}
{{define "main"}}
<h2>
    Latest snippet
</h2>
<p>
    There is nothing to see here yet
</p>
{{end}}
```

Once it’s done, the next is to just update the code in `home`handler so that it parses both template files like:

```go
// handlers.go
files := []string {
    "./ui/html/base.html",
    "./ui/html/pages/home.html",
}
ts, err := template.ParseFiles(files...)
if err != nil {
    log.Printfln(err.Error())
    //...
    return
}
err := ts.ExecuteTemplate(w, "base", nil) // base is a defined block
```

Our template set contains 3 named tempaltes -- `base, title, main`-- use the `ExecuteTemplate()`to tell that Go we specifically want to respond using the content of the `base`template.

#### Embedding partials

For som apps might want to break out certain bits of HTML into *partials* that can be reused in different pages or layouts.

```html
{{define "nav"}}
    <nav>
        <a href="/">Home</a>
    </nav>
{{end}}
```

Update the `base`tempalte so that it invokes the navigation partial using `{{template "nav"}}`action.

`ts, err = ts.ParseFiles(filepath.Join(dir, "/partials/nav.html"))`

#### The block action

Go also provides a `{{block}}...{{end}}`action which you can use instead -- this acts like the `{{template}}`, except it allows U to specify some default content if the template being invoked doesn’t exist in the current template set. In the context of a web app, this is useful when U want to provide some default content which individual pages can override a case-by-case basis if they need to.

```html
{{block "sidebar" .}}
<p>
    My default sidebar content
</p>
{{end}}
```

If U want, don’t need to include any default content between the `{{block}}`and `{{end}}`actions. And note that after Go 1.16 introduced the `embed`package which amkes it possible to embed files into your Go program.

### Serving static files

Go’s `net/http`ships with a built-in `http.FileServer`handler which can use to serve files over HTTP from a specific directory like: `fileServer := http.FileServer(http.Dir(".ui/static/"))`

It will remove the leading slash from the URL path and then search the `./ui/static`directory for the corresponding file to send to the user. So for it work correctly, must strip the leading `/static`from the URL path before passing it to the `http.FileServer`. like:

```go
//...
fileServer := http.FileServer(http.Dir("./ui/static/"))
mux.Handle("/static/", http.StripPrefix("/static", fileSever))
```

#### Serving single files -- 

Sometimes u might want to serve a single file from within a handler -- fore `http.ServeFile`like:

```go
func downloadHandler(w http.ResposneWriter, r *http.Request) {
    http.ServeFile(w,r, "./ui/static/file.zip")
}
```

#### disalbing directory listings

If want to disable directory listings -- Add a blank `index.html`. Or a more complicated is to create a custom imp of the `http.FileSystem`. Have it return an `os.ErrNoExist`error for any directories.