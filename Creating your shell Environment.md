# Creating your shell Environment

Can tune your shell to help you work more efficiently. Can set aliases to create shortcuts to your favorite command lines and environment varaibles to store bits of information.

### Configuring Shell

Several configuration files support how your shell behaves. Some of the files are executed for every user and every shell, whereas others are specific to the user who creates the configuration file.

- `/etc/profile`-- sets up user environment for every user.
- `/etc/bash.bashrc`-- every user who run the Bash shell each time a Bash shell is opened. It sets the default prompt and add one or more aliases.
- `~/.profile`-- used by each user to enter info that is just specific to use of the shell. By default, it just sets a few environment variables and executes the user’s `.bashrc`file.
- `~/.bashrc`-- contains the info that is specific to your Bash shells.

So, to change the `/etc/profile`or `/etc/bashrc`files, must be the root user.

Setting prompt -- consisits of a set of characters that appear each time the shell is ready to accept a command. Like: `PS1`environment variable sets what the prompt contains.. like `PS2...`

Adding environment variables -- Might want to consider adding a few environment variables to your `.bashrc`file. These can help make working with the shell more efficiently and effectively. FORE: `PATH`-- sets the directories that are searched for the commands that you use. Fore, if often use directories of commands that are not in your path, can permantently add them. Add a `PATH`variable to your `.bashrc`file. Add a directory called `/getstuff/bin`then:

`PAHT=$PATH:/getstuff/bin; export PATH`

Custom environment variabbles -- can create your own environment to provide shortcut like:

```sh
M= /work/time/files/info/memos ; export M
# .. then make 
cd $M
```

Using the `man`command, to learn more about a particular command, `man command` fore:

```sh
man -k passwd
```

`/var`-- contains directories of data used by various applications.

### Listing Files and Dirs

If own a file, can use the `chmod`to change the permission on it. r=4, w=2, x=1 just like:

```sh
chmod 777 file
chmod 755 file #
```

Chaning with letters -- can also turn file permissions on and off using + and - signs. user(u), group(g), and other(o) and *all users (a)*. fore:

```sh
chmod a-w file # r-xr-xr-x
chmod o-x file
chmod go-rwx file
```

Setting default file permission with `umask`-- When create a file as a regular user, givn `rw-rw-r--` by default. And a directory is given the permission `rwxrwxr-x`. These default values are determined by the value of `umask`. 

```sh
umask # 0022 fore, ignore first 0, then 755
```

Changing file ownership-- As a regular, you cannot change ownership of files or directories to have them belong to another use. as the root user, can do:

```sh
chown joe /home/joe/memo.txt
```

Moving, copying and removing -- 

```sh
mv abc def
mv ghi ~ 
# by default using the same names, -i option to prompt before overwriting

cp abc def # -r recusively 0a for archive option, the date and permissiongs are maintained by the copy

rm abc
rm *
rmdir /home/joe/nothing/ # for empty directory
```

### Finding files

can use the commandas such as `locate`, `find`, and `grep`, `locate`searches by name, `find`to find based on lots of different attributes, and `grep`to search whtin text files find lines in files..

- There are advantages and disadvantages for using `locate`to find filenames instead of `find` -- A `locate`finds files much faster -- searches a dbs instead having to search filesystem. A disadvantage is that the `locate`cannot find any files added to the system since the previous time the dbs was updated.
- Not every file in filesystem is stored in the dbs.
- As a regular user, can’t see any files from the locate dbs.
- When search for a string, string can appear anywhere in a file’s path.

```sh
locate .bashrc
```

And the `find` is the best one for searching your filesystem when need to filter your results by a variety of attributes.

```sh
find $HOME -ls # long listing
```

Finding by name -- using `-name`or `-iname`options.

```sh
find /etc -name passwd # find by name
find /usr/share/ -size +10M # find by size
find -user chris -ls # find by user
```

Finding files by permission -- Searching for files by permission is an excellent way to turn up security issues on your system or recover access issues. Remember that the 3 number os represent permissions for the *user, group, other*.

```sh
find /usr/bin -perm 755 -ls
find /home/chris/ -perm -222 -type d -ls # -type d, only for directoires
```

Finding by date and time -- Date and timestamps are stored for each file when it is created, when it is accessed, when its content is modified, or when its metadata is changed, -- including *Owner, group, time stamp, size, permissions* and other information stored in the file’s node.

```sh
# find what was changed in past 60 mins:
find /etc/ -mmin -60

# ownership or premissions changed in the past 3 days
find /bin /usr/bin /sbin /usr/bin -ctime -3
```

-atime, -ctime, -mtime search basedon the number of days since was `accessed, changed, metadata-changed`

Using `not`and `or`when finding files -- With the `-not`and `-or`options, can further refine your searches.

Finding files and executing commands -- One of the most powerful features of the `find`is the capability to execute commands on any files that you find. The advantage of using `-ok`-- if doing sth destructive, can make sure that you okay each file individually. Like:

```sh
sudo find /etc -iname passwd -exec echo "i Found {}" \; # note that the space, and \; characters
```

The following command finds every file under the `/usr/share`directory that is more than 5MB in size. like:

```sh
find /usr/share -size +tM -exec du {} \; | sort -nr
```

And the `-ok`option enables you to choose, one at a time, whether each file found is acted upon by the comamnd you enter.

Searching with `grep`-- And if want to search for files that **contain** a certain search term -- can use the `grep`command, with this, can search a single file or search a whole directory structure of files recursively.

```sh
grep network /etc/services
grep -i network /etc/services

# search for lines that don't contain a selected text string, -v option like:
grep -vi tcp /etc/services

# to do recursive searches, use the -r option like:
grep -rli peerdns /usr/share/doc/

# to search the output of a command for a term, pipe the output to the `grep`
ip addr show | grep inet
```

## Using Templates to Generate Responses

There is just built-in support for using templates as responses for HTTP requests, but it is simple process to set up a handler that uses the features provided by the `html/template`packae.

### Responding with JSON data -- 

JSON responses are widely used, which provide access to an application’s data for clients that don’t want to receive HTML, such as Angular and React.. It is for now enough to understand that the same features that allowed me to serve static and dynamic HTML content can be used to generate JSON responses as well.

Add a file named `json.go`to the httpserver folder.

```go
func HandleJsonRequest(writer http.ResponseWriter, request *http.Request) {
	writer.Header().Set("Content-Type", "application/json")
	json.NewEncoder(writer).Encode(Products)
}

func init(){
	http.HandleFunc("/json", HandleJsonRequest)
}

```

And the initialization function creates a route, which mans that requests for `/json`will be processed by the `HandleJsonRequest()`func.

### Handling Form Data

The `net/http`package provides support for easily receiving and processing form data, add like `edit.html`to the `templates`folder like:

```html
<body>
{{$index := intVal (index (index .Request.URL.Query "index") 0)}}
{{if lt $index(len .Data)}}
{{with index .Data $index}}
    <h3 class="bg-primary text-white text-center p-2 m-2">Product</h3>
    <form method="post" action="/forms/edit" class="m-2">
        <div class="mb-3">
            <label>Index</label>
            <input name="index" value="{{$index}}" class="form-control" disabled/>
            <input name="index" value="{{$index}}" type="hidden"/>
        </div>

        <div class="mb-3">
            <label>Category</label>
            <input name="category" value="{{.Category}}" class="form-control"/>
        </div>

        <div class="mb-3">
            <label>Price</label>
            <input name="price" value="{{.Price}}" class="form-control"/>
        </div>

        <div class="mt-2">
            <button type="submit" class="btn btn-primary">Save</button>
            <a href="/templates/" class="btn btn-secondary">Cancel</a>
        </div>
    </form>
{{end}}
{{else}}
<h3 class="bg-danger text-white text-center p-2">
    No product at Specified index!
    {{end}}
</h3>
</body>
```

This template makes use of template variables, expressions, and functions to get the query string from the reuest and select the first `index`value, which is converted to an `int`and used to retreive a `Prodcut`value from the data provided to the template. And for the : `<form method="POST" action="/forms/edit" class="m-2">`

These expressions are more complex than generally like to see in a template. The `FormValue`and the `PostFormValue`methods are the most convenient way to access form data id you know the structure of the form being processed.

### Reading From Data from Requests

Now that have added a `form`to the proj, can write the code that receives the data it contains. And the `Request`struct defines the fields and methods for orking with form data.

- `Form`-- This field returns a `map[string][]string`containing the parsed form data and the query string parameters. The `ParseForm`must be called before this field is read.
- `PostForm`-- similar to `Form`but excludes the query string parameters so that only data from the request body is contained in the map. The `ParseForm`method must be called before the field is read.
- `MultipartForm`-- returns a multipart form represented using the `Form`struct defined in the `mime/multipart`package. The `PaseMultipartForm`must be called first.
- `FormValue(key)`-- returns the first value for the specified form key and returns the empty string if ther is no value. The source of data for this method is the `Form`field, and calling the `FormValue`will automatically calls `ParseForm`or `ParseMultipartForm`to parse the form.
- `PostFormValue(key)`-- returns the first value for the specified form key..
- `FormFile(key)`-- first file with the specified key in the form
- `ParseForm()`-- parses a form and populates the `Form`and `PostForm`fields.
- `ParseMultipartForm(max)`-- parses a MIME multipart form and populates the `MultipartForm`field.

```go
func processFormData(writer http.ResponseWriter, request *http.Request) {
	if request.Method == http.MethodPost {
		index, _ := strconv.Atoi(request.PostFormValue("index"))
		p := Product{}

		p.Name = request.PostFormValue("name")
		p.Category = request.PostFormValue("category")
		p.Price, _ = strconv.ParseFloat(request.PostFormValue("price"), 64)
		Products[index] = p
	}
	http.Redirect(writer, request, "/templates", http.StatusTemporaryRedirect)
}

func init() {
	http.HandleFunc("/forms/edit", processFormData)
}
```

The `init`function just sets up a new route so that the `ProcessFormData()`handles requests whose path is `/forms/edit`-- within the `ProcessFormData()`, the request mehod is checked, and the form data in the request is used to create a `Product`struct and replace the existing data value.

## Template Composition

```html
{{template "base" .}}
{{define "title"}}Home{{end}}

{{define "main"}}
<h2>
    Latest Snippet
</h2>
<p>
    there is nothing to see yet
</p>
{{end}}
```

In the source code:

```go
func home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path!= "/" {
        http.NotFound(w, r)
        return
    }
    
    files := []string {
        "./ui/...",
        "./ui/...",
    }
    
    // use the tempalte.ParseFiles() function to read the files and store the template
    ts, err := template.ParseFiles(files...)
    if err != nil {
        htt.Error(w, "Internal server error", 500)
        return
    }
    
    err = ts.Execute(w, nil)
    if err != nil {
        log.Println(err.Error())
        http.Error(w, "internal server error", 500)
    }
}
```

### Embedding partials

For some applications you might want to break out certain bits of HTML into partials that can be just reused in different pages or layouts like:

```html
{{define "footer"}}
<footer>Powered by...</footer>
{{end}}
```

Then update the base like:
`{{template "footer" .}}`

The Block action -- in the code used `{{template}}`action to invoke one template from another. Go also provides a `{{block}}...{{end}}`action which you can use instead, this like the `{{template}}`, except it allows you to specify some default content if the template being invoked doesn’t exist in the current. Syntactically set:

```html
{{define "base"}}
<h1>
    An example
</h1>
{{block "sidebar" .}}
<p>
    default content
</p>
{{end}}
{{end}}
```

Don’t need to include any default content between the `{{block}}`and `{{end}}`actions.

### Serving static files 

The `http.FileServer`handler -- Go’s `net/http`packages ships with a built-in `http.FileServer`handler which you can use to serve files over HTTP from a specific directory. To create a new handler, just like:

`fileServer := http.FileServer(http.Dir(“/ui/static”))`

When this handler receives a request, will remove the leading slash from the URL path and then search for `./ui/static`directory for the corresponding file to send to the user. For this to work correctly, must strip the leading `/static`form the URL path before passing to the `http.FileServer`.

`mux.Handle("/static/", http.StripPrefix("/static", fileServer))`// static -> some other names, both

Additional info -- Go’s file server has a few really nice features that are worth mentioning. FORE, the `Content-Type`is automatically set from the file extension using the `mime.TypeByExtension()`.

Serving Single Files -- Sometimes you might want to serve a single file from within a handler, for this instance:

```go
func downloadHandler(w http.ResponseWriter, r *http.Request){
    http.ServeFile(w, r, "./ui/static/file.zip")
}
```

### The http.Handler interface

Handler functions -- Creating an object just so can implement a `ServeHTTP`method on it is long-winded and a bit confusing -- which is why in practice it’s far more common to write your handlers as a normal function. fore:

```go
func home(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte(...))
}

mux := http.NewServeMux()
mux.Handle("/", http.HandlerFunc(home))
```

And throughout the proj using the `HandleFunc()`to do that, just a shortcut:

```go
mux := http.NewServerMux()
mux.HandleFunc("/", home)
```

Chaining Handers -- The `http.ListenAndServe()`takes a `http.Handler`object as the second parameter like:
`func ListenAndServe(addr string, handler Handler) error`

Do this is cuz the serveMux also has a `ServeHTTP()`.

## Configuration and Error Handling

In this, going to do some -- won’t actually add much new -- but instead of focus on improvements that’ll make it easier to manage as it grows -- 

- Set configuration settings for your app at runtime in an easy and idiomatic way using command-line flags.
- Improving your application log messages to include more info, and manage them differently depending on the type of log message
- Make dependencies available to your handlers in a way that is extensible, type-safe, and doesn’t get in the way it comes to writing tests.
- Centrialize error handling so that you don’t need to repeat yourself when writing code.

