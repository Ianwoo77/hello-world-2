# Using Shell Variables

The shell itself stores info that may be useful to user’s shell session in what are called *variables*. Fore, `$SHELL`-- idientifies the shell you are using, `$PS1`-- defines your shell prompt, and `$MAIL`-- location of your mailbox. Can see all variables set for your current shell by typing the `set`command. A subset of your lcoal variables is referred to as *environment variables* -- are variables that are exported to any new shells opened from the current shell. 

`echo $VALUE`-- VALUE is name of a particular environment variable you just want to list. Can also type `declare`to get a list of the current environment variables and their values along with a list of shell functions. Besides.. System files set variables that store thrings such as locations of configuraiton files. like:

```sh
echo $USER
BASH HOME EUID MAIL OSTYPE PATH PPID PS1 PWD RANDOM TIMEOUT...
```

### Creating and using aliases 

Can effectievely create a shortcut to any command and options that you want to run later. Just like:

```sh
alias p= 'pwd; ls -CF'
alias rm='rm -i' # ask before deletion
```

Creating shell environment -- Can tune your shell to help you work more efficiently. Can set aliases to ceate shortcuts to your favorite command lines.  Several configuration files support how your shell behaves.

- `etc/profile`-- this sets up environment info for every user.
- `etc/bash.bashrc` -- executes every user who run the Bash shell each time. in ``~/.bashrc`file.
- `~./profile`-- used by each user to enter info that is specified to its use of the shell.
- `~/.bashrc`-- contains info that is specific to your Bash shells. It is read when you log in and also each time you open a new Bash Shell.

To change the `/etc/provile`or `/etc/brashrc`files, must be the root user. It is better to create a new file to add system-wide settings instead of editing those files directly. Can just use a simple editor to edit.. like:

`nano $HOEM/.bashrc`

Setting prompt -- Your prompt consists of a set of characters that appear each time the shell is ready to accept a command. For the `PS1`environment variable.

Adding environment variables -- Might want to consider adding a few environment variables to your `.bashrc`file. this can help make working with the shell more efficient and efficitive -- FORE:

`TIMEOUT`-- sets how long the shell can be inactive before Bash automatically exits.

`PATH`-- sets the directories, that are searched for the commands that you use. FORE:
`PATH=$PATH:/getstuff/bin;export PATH`
This example first reads all of the current path into athe new PATH, adds the new directory, and exports new PATH.

***The `export` command in Linux is a built-in shell command that exports environment variables from the shell to child processes. It's a key tool for managing and configuring the Linux system's environment***

Custom env variable - can create your own environment variables to provide shortcuts in your work. Fore:

```sh
M=/work/time/files/info/memos; export M
```

Could make that your current directory by just `cd $M`-- could run a program from that directory called ..

Getting info about Commands -- When first start using the shell, Here are some places you can look to supplement what you learn -- 

- Check the PATH, type `echo $PATH`
- Using the `help`-- some commands are just built into the shell, so they do not appear in a directory.
- `info`comand -- is another tool for displaying info about commands from the shell.
- Use the `man`command -- a description of the command and appears.

Options of the `man`enable you search the man page dbs or display man page on the screen. Using the `-k`option, can search the name and summary sections of all **man pages** installed on the system.

## Moving around the FileSystem

The Linux filesystem is the structure in which all of the information on your computer is stored. In fact, one of the deining properties of the Unix system on which linux is based is that nearly everything you need to identify on your system is represented by items in the filesystems. In linux, files are organized wihtin a *hierarchy* of directories.

Some of these Linux directories -- 

- `/bin`-- contains common Linux user commands, `ls, sort, date...`
- `/boot`-- bootable Linux kernel, initial RAM disk, and bootloader configuration files (RGUB)
- `/dev`-- contains files representing access points to devices on system. terminal devices (tty*), disks (hd* or sd*), RAM... can access these devcies directly through these device files.
- `/etc`-- administractive configuration. means **and so on**. Most of these files are plain text file that givent the user has proper permission.
- `/home`-- directores assigned to each regular use with login account
- `/media`-- std loction for automounting devices (removalbe meida in particular).
- `/lib`-- shared libraries needed by apps in `/bin`and `/sbin`.
- `/mnt`-- A common mount point for many devices before it was supplanted by the std `/media`. Some bootable systems still use this.
- `/opt`-- store add-on app software
- `/proc`-- info about system resources
- `/root`-- represents the root user’s home directory.
- `/sbin`-- adminmistrative commands and daemon processes
- `/sys`-- parameters for such things as tuning block stroage and managing `cgourps`
- `/tmp`
- `/usr`-- user documentation, games, graphical files..
- `/var`-- directories of data used by various apps.

VS. Windows -- 

- In Win,.. drive letters represent different storage devices. In Linux, all storge devices are connected to filesystem hierarchy. So, the fact that all of `/usr`may be on a separate hard disk.
- Filename .. In Linux, don’t necessarily.
- Every file and dir in a Linux has permissions and ownership associated with it.

Using the basic Filesystem commands -- Fore the `/usr/share`represents the *absolute* path to a directory on the system. Cuz it begins a slash.

### Using Metacharacters and Operators -- 

Try out some of these file-matching like:

```sh
touch apple banana grape
```

Note that the `touch`command updates the modification time stamp of an existing file, or if no file of that name currently exists, will create empty. File-redirection metacharacters -- Commands receive data from std input and send it to std output. Can just direct std outoutp from one command to the std input of another. With files, can use less < and greater > sins to direct data to and from files. FORE:

`<` directs the contents of a file to the command, like: `less < bigfile`
`>`std output to a file
`2>` driect std error to the file
`&>`both std output and error to the file
`>>`-- output of a command to a file, adding the output to the end, append, just.

Using brace expansion characters -- By using `{}`, can expand out a set of characters across filenames. FORE:

```sh
touch memo{1,2,3,4,5}
ls # memo1, memo2 ...
# are expanded don't have to be numbers. fore:
touch {John,Bill,Sally}-{Breakfast,launch,Dinner}
touch {a..f}{1..5}
```

## Creating the static File Route

Now that there are just HTML and cass files to wrok with, it is time to define the route that will make them available to request using HTTP like: 

```go
fsHandler := http.FileServe(http.Dir("./static"))
http.Handle("/files/", http.StripPrefix("/files", fsHandler))
```

The `FileServer`function creates a handler that will serve files, and the directory is specified using the `Dir()`-- Going to serve the content in the `static`folder with URL, paths just start wtih files so that a requst for /files/store.html -- will be handled using the `static/store.html`. For this, have to use `StripPrefix`-- creates a handler that removes a path prefix and passes the request onto another handler to service.

### Using Templates to Generte Responses -- 

There is no built-in support for using templates as responses for HTTP requests, but it is a simple process to set up a handler that uses the features provided by the `html/templates`package. Like:

```html
<body>
<h3 class="bg-primary text-white text-center p-2 m-2">Products</h3>
<div class="p-2">
    <table class="table table-sm table-stripped table-bordered">
        <thead>
        <tr>
            <th>Index</th>
            <th>Name</th>
            <th>Category</th>
            <th class="text-end">Price</th>
        </tr>
        </thead>
        <tbody>
        {{range $index, $product := .Data}}
            <tr>
                <td>{{$index}}</td>
                <td>{{$product.Name}}</td>
                <td>{{product.Category}}</td>
                <td class="text-end">
                    {{printf "$%.2f $product.Price"}}
                </td>
            </tr>
        {{end}}
        </tbody>
    </table>
</div>
</body>
```

Then add a file named `dynamic.go`to the `httpserver`folder like:

```go
type Context struct {
	Request *http.Request
	Data    []Product
}

var htmlTemplates *template.Template

func HandleTemplateRequest(writer http.ResponseWriter, request *http.Request) {
	path := request.URL.Path
	if path == "" {
		path = "products.html"
	}
	t := htmlTemplates.Lookup(path)
	if t == nil {
		http.NotFound(writer, request)
	} else {
		err := t.Execute(writer, Context{request, Products})
		if err != nil {
			http.Error(writer, err.Error(), http.StatusInternalServerError)
		}
	}
}

func init() {
	var err error
	htmlTemplates = template.New("all")
	htmlTemplates.Funcs(template.FuncMap{
		"intVal": strconv.Atoi,
	})
	htmlTemplates, err = htmlTemplates.ParseGlob("templates/*.html")
	if err == nil {
		http.Handle("/templates/", http.StripPrefix("/templates/",
			http.HandlerFunc(HandleTemplateRequest)))
	} else {
		panic(err)
	}
}
```

The initialization function loads all the templates with the `html`extension in the templates folder and sets up a route so that requests that start with `/templates/`are processed by the `handleTemplateRequest`function. This function looks up the template, falling back to the `products.html`file if no file path is specified.

## Template Composition

As add more pages to this web application there will be some shared, bolierplate, html markup that we want to just include on every page -- like the header, navigation and metadata insdie the `<head>`HTML element. To just save us typing and prevent duplication, it’s good idea to create a *layout* or *master* template which contains this shared content:

```html
{{define "base"}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{template "title" .}} - Snippetbox</title>
</head>
<body>
<header>
    <h1><a href="/">Snippetbox</a></h1>
</header>
<nav>
    <a href="/">Home</a>
</nav>
<main>
    {{template "main" .}}
</main>
</body>
</html>
{{end}}
```

Used the `{{define "base"}} .. {{end}}`action to define a distinct named tempalte named `base`which then contains the content we wnat to appear on every page. And inside that use the `{{template "title" .}}`.. action to denote that we want to invoke other named templates (`title`and `main`) at a particular point in the html.

Then go back to the `home.page`and update it to deifne the `title`and `main`named templates containing the specific content for the home page like:

```html
{{template "base" .}}

{{define "title"}}Home{{end}}

{{define "main"}}
    <h2>Latest Snippet</h2>
    <p>There is nothing to see</p>
{{end}}

```

Right at the top of this file is arguably the most important part -- the `{{template "base" .}}`action, this informs Go that when the `home.page.html` file is executed, that want to *invoke* the named template `base`. In turn, the `base`template contains instructions to invoke the `title`and `main`named templates. Done then to update the code in handler so that it parses *both* template files like:

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	
	// initialize a slice containing the paths to the two files like:
	files := []string {
		"./ui/html/home.page.html",
		"./ui/html/base.layout.html",
	}
    
    ts, err := template.ParseFiles(files...)
    if err != nil {...}
    //...
}
```

So now, instead of containing HTML directly, our template set contain 3 named templates and an instruction to invoke the `base`tempalte.  The big benefit of using this pattern to compose tempaltes is that you’re able to cleanly define the page-specific content individual files on disk.

### Embedding Partials 

For some applications you might want to break out certain bits of HTML into partials that can be just reused in different pages or layouts -- to illustrate, create a partial containing some footer content for our web application. Just create a new `footer.partial.html`like:

```html
{{define "footer"}}
<footer>Powered by <a href="https://golang.org">Go</a></footer>
{{end}}
```

Then just applying this to the main html like: `{{template "footer" .}}`

Additional Information -- The `Blcok` Action -- In the code used the `{{template}}`action to invoke one template from another -- but go also provides a `{{block}}..{{end}}`action which you can use instead. This acts like the `{{template}}`, except it allows to *specify some default content* if the template being invoked doesn’t exist in the current template set -- in the context of a web application, this is just useful when you want to provide some default content which inidividual pages can override on a case-by-cae basis of they need to. Use this:

```html
{{define "base"}}
    <h1>
        An example
    </h1>
    {{block "sidebar" .}}
        <p>
            My Default sidebar
        </p>
    {{end}}
{{end}}
```

If don’t need to include any default content between the `{{block}}..{{end}}`, the invoked template acts like it’s optional. andif the template exists in the template set, then it will be rendered.

### Serving Static Files

Add some static CSS and image files to the proj -- and the content like: To create a new `http.FileServer`handler, need to use the `http.FileServer()`function like this:
`fileServer := http.FileServer(http.Dir("./ui/static/"))`

so when this handler receives a request, it will remove the leading slash fromt the URL path and then search the `./ui/static`directory for the corresponding file to send to the user. So, for correctness, need to strip the leading `/static`from the path *before* passing it to `http.FileServer`. Just like:

```go
// Create a file sever which files out of the `./ui/static` directory
// note that the path given to the http.Dir is relative to the app
fileServer := http.FileServer(http.Dir("./ui/static"))

// use the mux.Handle() to register the file server as the handler for
// all URL paths that starts with `/static`.
mux.Handle("/static/", http.StripPrefix("/static", fileServer))
```

Feel free to have a play around.

```css
* {
    box-sizing: border-box;
    max-resolution: 0;
    padding:0;
    font-size: 18px;
    font-family: "Ubuntu Mono", monospace;
}

html, body {
    height: 100%;
}

body {
    line-height: 1.5;
    background-color: #F1F3F6;
    color: #34495E;
    overflow-y:scroll;
}

header, nav, main, footer {
    padding: 2px calc((100% - 800px) / 2) 0;
}

main {
    margin-top: 54px;
    margin-bottom: 54px;
    min-height: calc(100vh - 345px);
    overflow: auto;
}
/* ... */
```

Using the static Files -- With the file server working properly, can now update the `base.layout.html`to make the use:

```html
<link rel="stylesheet" href="/static/css/main.css">
<link rel="shortcut icon" href="/static/img/favicon.ico" type="image/x-icon">
```

Additional info -- Features and Functions -- Go’s file server has a few really nice feature that are worth mentioning: The `Content-Type`is automatically set from the file extension using functions.

### The http.Handler interface

Before go any further there is a little theory that should cover -- It’s a bit complicated.. Strictly speaking, what we mean by handler is an object which satisfies the `http.Handler`interface -- like:

```go
type Handler interface{
    ServeHTTP(ResponseWriter, *Request)
}
```

In simple terms, this basically means that to be a handler an object *must* have a `ServeHTTP()`. Like:

```go
type home struct {}
func (h *home) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("this is my home page"))
}

// then could register this with a `ServeMux`using then `Handle()`
mux := http.NewServeMux()
mux.Handle("/", &home{})
```

Handler Functions -- Now, creating an object just so we can implement a `ServeHTTP()`method on it is long-winded and a big confusing -- which is why in practice it’s far more common to write your handlers as a normal function. Like:

```go
func home(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("This is my home page"))
}
```

But, for this is just a normal function, it doesn’t have a `ServeHTTP()`. The `http.HandlerFunc()`*adapter* works by automatically adding a `ServeHTTP()`method to the `home`function when executed, this `ServeHTTP()`method then simply calls the *content of the original function*. And, throughout this have been using the `HandleFunc()`method to just register our handler functions with the ServeMux - This is just some syntactic sugar that transforms a function to a handler and registers it in one step, instead of having to do it manually just like:

```go
mux := http.NewServeMux()
mux.HandleFunc("/", home)
```

