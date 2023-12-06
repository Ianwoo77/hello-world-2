# Understanding Linux Desktop

Nearly every major linxu distribution that offers desktop interfaces is just based on the X Window system from the `X.ORG`foundation -- X works in sort of backward client/server model.

- Linux desktop environments are not required to run a linux system.
- For more robust computers, can choose powerful desktop environments GNOME or KDE that can do things.

GNOE3 -- Is currently the default desktop environment for Ubuntu. And K, Xfce, and LXDE.

## Using the Shell

The default prompt for a regular user is simply a `$`sign, and the default prompt for th root user is a `#`. Fore, if a login prompt for the user named `jake`on computer named `pine`with `/usr/share/`as current directory would:

```sh
[jake@pine share]$
```

Choose your shell -- In most linux system, your default shell is the `Bash`shell -- to find out just like:

```sh
(base) ian@bender:~$ whoami
ian
(base) ian@bender:~$ grep ian /etc/passwd
ian:x:1000:1000:ian,,,:/home/ian:/bin/bash
```

The `grep`command just shows the definition of your user account in the `/etc/passwd`file.

Running commands -- The simplest way to run a command is just like: Most commands has one or more *options*. fore:

```sh
# -l (long listing) -a(show all), -t list by age
ls -lat
```

And some commands include options that are represented by a whole word. To tell a command to use a whole word as an option, typically preceded it with double hyphen `--`. And many commands also acept arguments after certain options are entered or at the end of the entire command line. For full-word options, the arguments oftern follows an =.

```sh
ls --hide=Desktop # DON'T display the file or directory named `Desktop`

tar -cvf backup.tar /home/chris # create(c), file(f) and v(verbose message)
```

And when yo log in to a Linux system, Linux views you as having a particular identity, which includes your username, group name, user ID, and group ID.

```sh
id #uid = 1000(ian)...
```

Which have a user id 1000, it is normal for ubuntu users to have the same primary group name as their username. And can see info about your current login session by using the `who`command like:

```sh
who -uH # -H asks a header be printed, -u says to add info about idle time
```

The output from this `who`command shows that the user `chris`is logged in on `tty1`-- which is the first virtual console on the monitor connected to the computer. And the `IDLE`time shows how long the shell has been open wihtout any command being typed.

### Locating Commands

To find commands you type, the shell look sin what is referred to as your *path*. For commands that are not in your path, you can type the complete identity of the location of the command. So the better way is have commands stored in well-known directories and then add those directories to your shell’s `PATH`environment variable. By default the path consists of a list of directories that are checked sequentially for the commands you enter.

```sh
echo $PATH
```

Note that unlike some other OS, Linux does not by default check the current directory an an executable before searching the path -- It immediately begins searching the path, and executable in the current directory are run only if they are in the `PATH`or you give their absolute or relative location.

So the path directory order is just important, and Directories are checked from left to right. Not all of the commands you ran are located in directories in your `PATH`variable. Some commands are just built into the shell. Other commands can be overriden by creating aliases that define any commands and options that you want the command to run. There are also ways of defining a function that consists of a stored series of commands -- Here is the order -- 

1) Aliases - type `alias`to see what aliases are set.
2) Shell reserved word
3) Function
4) Built-in command
5) Filesystem command

To determine the location of a particular command, can type the `type`command like:
`type bash`

And try some fiew with the `type`command to see other locations of commands -- `which case return` And if a command is not in your `PATH`variable, U can sue the `locate`command to try to find it. `locate`can search any part of the system that is accessible to you. Noticed that `locate`not only found the `chage`also found a variety man pages associted with `chage`for different language.

Recalling using History -- The *shell history* is a list of commands that you can have entered before.  By default, the Bash shell uses command-line editing that based on emacs text editor -- `man emacs`, Fore to do the editin, use a combination of controls keys, meta keys, and arrow-keys. fore ctrl+F..

```sh
# lists content, sorts by alhabetical order, and pipe the output to less
ls /usr/bin | sort -f | less
```

Command-line recall -- After you type a command, the entire command line is saved in your shell’s history list. The list is stored in the current shell until you exit the shell. After that, it is written to a *history file*. Canalso recall one of those use `!`like:

```sh
!n # run command number
!!-!! # run previous command
!?dat? 
```

Connecting and expanding Commands -- A truly powerful feature of the shell is the capability to redirect the input and output of commands to and from other commands and files. Including `| & ; ) ( <)`

Piping between commands -- 

```sh
cat /etc/passwd | sort | less
```

Pipes are just an excellent illustratio of how Unix, was created as an OS.

Squential commands -- Sometimes, may want to sequence of commands to run, with one command completing before the next command begins. Can so with the `;`

```sh
date ; troff -me verylaregedocument | lp ; date
```

Background commands -- Some commands can take a while to complete. May not want to tie up your shell waiting for a command to finish -- can have the commands run in the background by using the ampersand `&`

Expanding commands -- With command subsitution, can have the output of a command interpreted by the shell instead of by the command itself. Fore: $(command) and `command`

```sh
# the command subsitutaion is done before the naon is run
nano $(find/home | grep xyzy)
```

`grep`jsut filters out all files except for those include the string xyzy.

Expanding arithmeitc expressions -- sometimes want to pass arithmetic results to a command using `$[expression]`like:

```sh
echo "I am $[2019-1957] years old"
```

The shell interprets the arithmetic. And here is an example of another way to do:

```sh
echo "There are $(ls | wc -w) files in this directory"
```

Expanding variables -- Variables that store info within the shell can be expanded using the `$`. Just like:
`ls -l $BASH`

## Using the Reponse Convenience Functions

The `net/http`package provides a set of convenience functions that can be used to create common responses to HTTP requests -- like:

- `Error(writer, message, code)`-- Sets the heder to the specified code, sets the `Content-Type`header to `text/plain`, and writes the error message to the response.
- `NotFound(writer, request)`-- This function calls `Error`and specifies 404 error code.
- `Redirect(writer, request,url, code)`-- This sends a redirection response to the specified URL and with the specified status code.
- `ServeFile(writer, request, fileName)`-- sends a response containing the contents of the specified file. The `Content-Type`heder is set based on the file name but can be overridden by explicitly setting the header before calling the function.

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {
	Printfln("Request for %v", request.URL.Path)
	switch request.URL.Path {
	case "/favicon.ico":
		http.NotFound(writer, request)
	case "/message":
		io.WriteString(writer, sh.message)
	default:
		http.Redirect(writer, request, "/message", http.StatusTemporaryRedirect)
	}
}
```

### Using the Convenience Routing Handler -- 

The process of inspecting the URL and selecting a response can produce complex code that is difficult to read and maintain -- to simplify the process, the `net/http`package provides a `Handler`implementation that allows matching the URL to be separeted from producing a request.

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {
	Printfln("Request for %v", request.URL.Path)
	io.WriteString(writer, sh.message)
}

func main() {
	http.Handle("/message", StringHandler{"Hello, World"})
	http.Handle("/favicon.ico", http.NotFoundHandler())
	http.Handle("/", http.RedirectHandler("/message", http.StatusTemporaryRedirect))

	err := http.ListenAndServe(":5000", nil)
	if err != nil {
		Printfln("Error: %v", err.Error())
	}
}
```

This enables the default handler -- `http.ListenAndServe(":5000", nil)`, which routes requests to handlers based on the rules set up the functions like:

`HandleFunc(pattern, handlerFunc)`-- This function creates a rule that invokes the specified function for requests that match the pattern. This function is invoked with `Responsewriter`and `Request`arg. To help set up the routing rules, the `net/http`package provdies the functions like:

- `FileServer(root)`-- creates a `Handler`that produces responses using the `ServeFile`func.
- `NotFoundHandler(), RedirectHandler(url, code)`
- `StripPrefix(prefix, handler)`--removes the specified prefix from the request URL.
- `TimeoutHandler(handler,duration,message)`-- Specified Handler but generates an error response if the response hasn’t been produced with the specified duration.

### Supporting HTTPs Requests

The `net/http`provides integrated support for HTTPs, will need to add two files in Go -- a certificte and a private key.

Getting Certificates for HTTPs in Go -- a good way to start is with the `self-signed`-- can be used for development and test. Two files are required to use HTTPs, regardless of whether you certificate is self-signed or not. The first is the certificate file, which usually has a `cert`or `cert`file extension,, the second is the private key file. and the `ListenAndServeTLS()`is used to enable HTTPs, where the additional arguments sepcify the certiicate and private key files. like:

```go
go func() {
    err := http.ListenAndServeTLS(":5500", "./ian-2023-12-06-013256.cer",
                                  "./ian-2023-12-06-013256.pkey", nil)
    if err != nil {
        Printfln("HTTPS error: %v", err.Error())
    }
}()
```

The `ListenAndServeTLS()`and `ListnAndServe()`functions **block**, so, have used a goroutine to support both HTTP and HTTPs requests. The `ListenAndServeTLS()`and .. have been ivoked with `nil`as the handler -- means that both HTTP and HTTPs requests will be handled using the same set of routes.

Redirect HTTP to HTTPs-- A common requirement when creating web servers to redirect HTTP requests to the HTTPs port, this can be done by creating a custom handler like:

```go
func HTTPSRedirect(writer http.ResponseWriter, request *http.Request) {
	host := strings.Split(request.Host, ":")[0]
    target := "https://" + host + ":5500" + request.URL.Path
	if len(request.URL.RawQuery) > 0 {
		target += "?" + request.URL.RawQuery
	}
	http.Redirect(writer, request, target, http.StatusTemporaryRedirect)
}
//... in the main()
err := http.ListenAndServe(":5000", http.HandlerFunc(HTTPSRedirect))
```

Creating a Static HTTP server -- The `net/http`package includes built-in support for responding to requests with the contents of files. Just create the `httpserver/static`folder and add to it a file named `index.html`like:

```html
<body>
<div class="m-1 p-2 bg-primary text-white h2 text-center">
    Products
</div>
<table class="table table-sm table-bordered table-striped">
    <thead>
    <tr><th>Name</th><th>Category</th><th>Price</th></tr>
    </thead>
    <tbody>
    <tr><td>Kayak</td><td>Watersports</td><td>$279.00</td></tr>
    <tr><td>Lifejacket</td><td>Watersports</td><td>$49.95</td></tr>
    </tbody>
</table>
</body>
```

Creating the static file route -- like:

```go
fsHandler := http.FileServer(http.Dir("./static"))
http.Handle("/files/", http.StripPrefix("/files", fsHandler))
```

The `FileServer()`creates a handler that will serve files -- and the directory is specified using the `Dir`function -- note that it is possible to serve files directly, but caution is required cuz it is easy to allow requests to select files outside of the target folder. Going to serve the content in the `static`with URL paths that start with `files`so that a request for the `/files/stores.html`-- Have to use `StripPrefix`-- creates a **handler** that remove a path prefeix and passes the request onto another handler to service.

## The `http.Error`shortcut

If want to send a non-200 status code and a plain-text response body then it’s a good oppotunity to use the `http.Error()`shortchut, this is a lightweight helper function takes a given message and status code. Then just calls the `w.WriteHeader()`and `w.Write()`behind the scenes for us. fore:

```go
func createSnippet(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodPost {
        w.Header().Set("Allow", http.MethodPost)
        http.Error(w, "Method not allowed", 405)
        return
    }
    w.Write([]byte("Create a new snippet..."))
}
```

In terms of functionaity this is almost exactly the same. The biggest difference is that we’ve now passing our `http.ResponseWriter`to another function, which sends a response to the user for us. The pattern of passing `http.ResponseWriter`to other functions is super-common in Go, and something we will do a lot.

manipulating the header map -- In code, used `w.Header().Set()`to **add** a new header to the response header map, but there is also `Add, Del, Get`methods that u can use to read and manipulate the header map too. Like:

`w.Header().Add("Cache-Control", "public")`

System-Generated Headers and Content sniffing -- When sending a response Go will automatically set three system-generted headers for you `Date`and `Content-Length`and `Content-Type`. The `Content-Type`-- will attempt to set the correct one for you by content sniffing the response body with the `http.DetectContentType()`function.

Suppressing System-Generated Headers -- The `Del()`doesn’t remove system-generated headers, To suppress these, need to access the underlying header map directly and set it to `nil`. Like:
`w.Header()["Date"]=nil`

### URL Query Strings

While are on the subject of routine, just using like: `/snippet?id=1`format --  To make this work correctly need to update the `showSnippet`handler functoin to do two things -- 

- Needs to retrieve the value of the `id`parameter from the URL query string, which we can do using the `r.URL.Query().Get()`method. This will always return a string value for a parameter, or the empty string.
- Cuz the `id`is untrusted user input, should validate it to make sure it’s sane and sensible. Can use the `strconv.Atoi()`function and then checking the vlue is greater then zero. FORE:

```go
func showSnippet(w http.ResponseWriter, r *http.Request) {
	// Extract the value of the id parameter from query string and try to
	// covert to integer. 
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id<1 {
		http.NotFound(w,r)
		return
	}
	
	// use the fmt.Fprintf() to interpolate the id value with our response
	fmt.Fprintf(w, "Displaying a specific snippet with id %d", id)
}
```

Might also like to try visiting some URLs which have invalid values for the `id`parameter, or no parameter at all.

The `io.Writer`interface -- The code above introduced another new thing -- if take a look at the documentation -- `io.Writer`as the first parameter.

### Proj Structure and Organization

And make sure that you are in root of repository and rutn the Bash like:

- The `cmd`directory will contain the app-specific coded for the executable apps in the project. 
- the `pkg`directory will contain the ancillary non-application-specific code used in the proj.
- The `ui`directory will contain user-interfaces.

There are two big benefits -- 

1. It gives a clean separation between Go and non-go assets, All the Go code write will live exclusively under the `cmd`and `pkg`directories.
2. It scales really nicely if want to add another executable app to your project.

### HTML templating and inheritance

To do this, first create a new template file in the `ui/html`directory: For this we need to import Go’s `html/tempalte`package, which provides a family of functions for safely parsing and rendeing HTML templates.

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	ts, err := template.ParseFiles("./ui/html/home.page.html")
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
		return
	}

	err = ts.Execute(w, nil)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal server Error", 500)
	}
}
```

It’s important to point out that the file path that you pass to the `template.ParseFiles()`function must either be relateive to your currenct working directory, or an absolute path.

Template Composition -- As add more pages to this web application there will be some shared, boilerplate, HTML markup that we want to include on every page. Just create a new HTML like://...