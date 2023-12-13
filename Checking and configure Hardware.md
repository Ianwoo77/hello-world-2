# Checking and configure Hardware

Alhough Linux systems have become quite good at detecting hardware, sometimes, you must just tkae special steps to get your computer hardware working -- the growing use of removable usb devices...

- Effectively manage hardward that comes and oes
- look at same piece of hardware in different ways

Checking hardware -- when system boots, the kernel detects your hardeware and loads drivers that allow linux to work wtih that hardware -- cuz messages about hardware detection scroll quickly off the screen when boot.

Note, there are just a few ways to view kernel boot messages after Linux comes up. fore `dmesg`command to see what hardwre was detected and which drivers were loaded by the kernel at boot time. And a second way to see boot messages is the `journalctl`command to show the messages associated with a particular boot instance.

And if sth goes wrong detecting your hardware or loading drivers, you can refer to this info to see the name and model number of hardware that is not working. Then can search linux forums or documentation to try to solve the problems.

`lspci`lists PCI buses on your computer and devices connected to them.

### Managing removable hardware 

Linxu systems which support full `GNOME`desktop environments include simple graphical tools for configuring what happens when you attach popular removable devices to the computer.

```sh
lsmod # listing loaded modules
```

This output shows a variety of modules that have been loaded on the Linux system. including one for network interface.

Linux Partitions -- Use this option to create a partition for na ext2... filesystem type that is added directly to a parition on your hard disk.

### Getting and managing Software

Don’t need to know much about how software is packaged and manged to get the software you want. This begins by describing hot wo install software in Ubuntu, using the new software graphical installation tool.

Linux software packaging -- The package format could be a Tarball containing executable files, documentation, configuration files and libraries. When install software forma Tarball, the files from the Tarball might be spread acorss your linux system in appropriate directories like `/usr/share/man, /etc, /bin and /lib`.Although it is easy to create a Tarball and just drop a set of software onto system. the method of installing software makes it difficult to do these things -- 

- Satisfy software dependencies.
- List the software
- Remove the software
- Update the software

To deal with, packages progressed from simple Tarballs to more complex packaging -- with ony a few exceptions.

- `DEB`packaging -- The Debian GNU/Linux project created `.deb`packaging -- which is used by Debian and other distributions based on Debian, using tools such as `apt-get`, and `dpkg`
- `RPM`(.rpm) packing -- Red Hat package -- RPM is referred package format for SUSE, RED HAT... 

APT basics -- The Ubuntu software Center is fairly intutive for finding and installing packages. And the most basic of all commands within the Debian `sudo apt update`-- to apply the latest updates to all the package currently installed on your system using a single command, run `apt upgrade`.

In the market for some new software but don’t know what is called -- Suppose you are worried about heat buiding up inside your computer’s case and want sth to monitor tempeature changes -- 

`apt search sensor` And this will probably return too many... then:

```sh
apt show psensor
apt depends psensor
sudo apt install psensor
# need to remove fore
sudo apt remove psensor
# apt revmoe will delete all the related program files that has been installd
# If don't want anything remaining from the program, just
sudo apt purge psensor
```

### Managing Disks and Filesystems

Instead of drive letters for each local disk, network files... Everything fits neatly into the linux directory structure. Some drivers are connected automatically into the filesystem when insert removable medi.

Partitioning hard disks -- Provides several tools for managing your hard disk partitiions, need to know how to partition your disk if you want to add a disk to your system or change your existing disk configuration.

Viewing disk partitions -- To view disk partitions, use `parted`command with the `-l`option like:

```sh
parted -l /dev/sdb
```

The linux file system -- It’s often said that everything in Linux works through plain text files, so it probably makes the most sense to start by understanding the Linux file system -- before -- Can think of it as data table that creates apparent connections between individual files and groups of files wiht identifiable locations on a disk.

All the files in a disk partition are kept in directories beneath the root directory -- which is represented by the `/`-- This way are arranged is largely goverened by the `UNIX`FHS. And *top-level* directories -- those locaed directly beneath the root, include `/etc/`which contains configuration files that define the way individual programs and services function. `/var/`-- contains variables files belong to the sysytem or individual apps whose content changes frequently through the course of normal system activities.

- `/etc`-- program configuration
- `/var`-- Frequently changing content -- like log
- `/home`-- user accuont files
- `/sbin`-- system binary
- `/bin`-- user binary
- `/lib`-- shared libraries
- `/usr`-- Third-party binaries.

`ls -R /etc` # displays subdirectories rescurely

Pseudo file systems -- A normal file is a collection of data that can be reliable accessed over and over again, even after a system reboot. by contrast, the content of a linux pseudo file, like those might exist in the `/sys/`and `/proc/`directories, don’t really exist in the normal sense. A pseudo file’s contents are dynamically generated by the OS itself to represent specific values. FORE:

`cat /sys/block/sdb/size`

sda probably stood for SCSI Device A, and fore `/dev/hda`, `/dev/sr0`:

```sh
cd /sys/block
ls # loop0...
```

For this, among it scontents, you will probably see files with names .. All the currently avaliable block devices -- a *loop* device iis just a pseudo device that allows a file to be used as though it’s actual physical device. Then just:

```sh
ls /sys/block/sdb
```

Among its contents, you will see files with name like sdb1... each of these represents one of the partitions created by linux to better organize the data on your device.

## Sending Simle HTTP requests

The `net/http`package provides a set of convenience functions that make basic HTTP requests. Like:

- `Get(url)`-- sends a GET to the specified HTTP or HTTPs URLs. And the results are a `Response`and an `error` that just reprots problems with the request.
- `Head(url)`-- sends a HEAD reuests to the specified HTTP or HTTPs URL. And a `HEAD`request returns the headers that would be returned for a `GET`request.
- `Post(url, contentType, header)`-- sends a POST request to the specified HTTP or HTTPs URL.
- `PostForm(url, data)`-- sends a POST to the specified HTTP .. With the content-type to the `application/x--www-form-urlencoded`.

And the `Write()`is convenient when you just want to see the response, but most projects will check the status code to just ensure the request was successful and then read the response body like: `ReadAll()`defined in the `io`package to read the response `Body`into a `byte`slice, which write to the std output. And when response contain data, fore JSON, they can be parsed into `Go`values like:

```go
func main() {
	Printfln("Starting HTTP server")
	go http.ListenAndServe(":5000", nil)

	time.Sleep(2 * time.Second)

	resp, err := http.Get("http://localhost:5000/json")
	if err == nil && resp.StatusCode == http.StatusOK {
		defer resp.Body.Close()
		data := []Product{}
		err = json.NewDecoder(resp.Body).Decode(&data)
		if err == nil {
			for _, p := range data {
				Printfln("Name: %v, price: $%.2f", p.Name, p.Price)
			}
		} else {
			Printfln("Decode error: %v", err.Error())
		}
	} else {
		Printfln("error:%v, status code: %v", err.Error(), resp.StatusCode)
	}
}
```

The JSON data is decoded using the `encoding/json`package.

Sending POST requests -- The `Post`and `PostForm`functions are used to send POST requests. The `PostForm`function encodes a map of values like:

```go
func main() {
	Printfln("Starting HTTP server")
	go http.ListenAndServe(":5000", nil)

	time.Sleep(2 * time.Second)

	formData := map[string][]string{
		"name":     {"Kayak"},
		"category": {"Watersports"},
		"price":    {"279"},
	}
	resp, err := http.PostForm("http://localhost:5000/echo", formData)
	if err == nil && resp.StatusCode == http.StatusOK {
		io.Copy(os.Stdout, resp.Body)
		defer resp.Body.Close()
	} else {
		Printfln("Error: %v, Status code: %v", err.Error(), resp.StatusCode)
	}
}
```

HTML forms support multiple values for each key, which is why the values in the map are slices of strings. Send oly one value for each key in the form, but still have to enclose the value in braces to create a slice. The `PostForm`function encodes the map and adds the data to the request body and sets the `Content-Type`header to the `application/x-www-form-urlencoded`. And in the echo:

```go
if err == nil {
    if len(data) == 0 {
        fmt.Fprintln(w, "NO body")
    } else {
        w.Write(data)
    }
} else {
    fmt.Fprintf(os.Stdout, "Error reading body %v\n", err.Error())
}
```

Just note that the `w.Write(data)`. `category=Watersports&name=Kayak+&price=279`

### Posting a Form Using a Reader

And, the `Post`function sends a POST request to the server and creates the request body by reading content from a `Reader`. Unlike the `PostForm`-- the data doesn’t have to encoded as a form. Namely, `map[string][]string`

```go
func main() {
	Printfln("Starting HTTP server")
	go http.ListenAndServe(":5000", nil)

	time.Sleep(2 * time.Second)

	var builder strings.Builder
	err := json.NewEncoder(&builder).Encode(Products[0])
	if err == nil {
		resp, err := http.Post("http://localhost:5000/echo",
			"application/json", strings.NewReader(builder.String()))
		if err == nil && resp.StatusCode == http.StatusOK {
			io.Copy(os.Stdout, resp.Body)
			defer resp.Body.Close()
		} else {
			Printfln("Error: %v", err.Error())
		}
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

This example encodes the first element in the slice of `Products`value as JSON.

### Configuring HTTP client requests

The `Client`struct is used when controls is required over an HTTP request and defines the fields and methods. And the `net/http`package defines the `DefaultClient`variable, which provdies a default `Client`that can be used to use the fields and methods -- and it is this variable that is used when the functions described are used. Just like: And the simplest way to create a URL value is to use the `Parse`function provided by the `net/url`package, which parses a string, and which like:

`Parse(string)`-- this parses a `string`into a URL, the result are the `URL`value and an `error`that indicates problems parsing the `string`. FORE:

```go
func main() {
	Printfln("Starting HTTP server")
	go http.ListenAndServe(":5000", nil)

	time.Sleep(2 * time.Second)

	var builder strings.Builder
	err := json.NewEncoder(&builder).Encode(Products[0])
	if err == nil {
		reqURL, err := url.Parse("http://localhost:5000/echo")
		if err == nil {
			req := http.Request{
				Method: http.MethodPost,
				URL:    reqURL,
				Header: map[string][]string{
					"Content-Type": {"application/json"},
				},
				Body: io.NopCloser(strings.NewReader(builder.String())),
			}
			resp, err := http.DefaultClient.Do(&req)
			if err == nil && resp.StatusCode == http.StatusOK {
				io.Copy(os.Stdout, resp.Body)
				defer resp.Body.Close()
			} else {
				Printfln("Request error: %v", err.Error())
			}
		} else {
			Printfln("Parse Error: %v", err.Error())
		}
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

## Dependency Injection

There is one more problem with our logging that we need to address -- if open up your `handlers.go`file you will notice tht the `home`handler function is still writing error messages using the go std logger. not the `errLog`. Namely, how can we make our new `errLog`logger available to our `home`function from the `main()`--  Most web apps will have multiple dependencies that their handlers need to access, such as a dbs connection pool, centralized error handlers, and template caches.

For apps where all your handlers are in the same package -- a neat way to inject dependencies is to put them into a cuatom `application`struct, and then define your handler functions as methods against application. In the `main.go`file just add:

```go
type application struct {
	errLog *log.Logger
	info   *log.Logger
}
```

Then in the `handlers.go`update your handler functions so that they become methods against the struct like:

```go
unc (app *application) home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	// initialize a slice containing the paths to the two files like:
	files := []string{
		"./ui/html/home.page.html",
		"./ui/html/base.layout.html",
		"./ui/html/footer.partial.html",
	}

	ts, err := template.ParseFiles(files...)
	if err != nil {
		// cuz the home handler is now a method against application
		// it can access -- like:
		app.errLog.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
		return
	}

	err = ts.Execute(w, nil)
	if err != nil {
		app.errLog.Println(err.Error())
		http.Error(w, "Internal Server Error", 500)
	}
}

// also change the signature of the showSnippet handler
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	// Extract the value of the id parameter from query string and try to
	// covert to integer.
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}

	// use the fmt.Fprintf() to interpolate the id value with our response
	fmt.Fprintf(w, "Displaying a specific snippet with id %d", id)
}

// change the signature like:
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)
		http.Error(w, "Method not allowed", 405)
		return
	}
	w.Write([]byte("Create a new snippet..."))
}
```

And finally, write things together in the `main.go`file like:

```go
app := &application{
    errLog:  errLog,
    infoLog: infoLog,
}
mux := http.NewServeMux()
mux.HandleFunc("/", app.home)
mux.HandleFunc("/snippet", app.showSnippet)
mux.HandleFunc("/snippet/create", app.createSnippet)
```

Understand that this approach might feel a bit complicated..

### Adding a Deliberate Error -- 

Then, try this out by quickly adding a delibrate error to our application -- Open the terminal and just: Additional info -- the pattern that we are using to inject dependencies won’t work if your handlers are spread across multiple packages. In that case, an alternative approach is to create a `config`package just exporting an `Application`struct. And:

```go
func main(){
    app := &config.Application{
        ErrorLog: log.New(...)
    }
    mux.Handle("/", handlers.Home(app))
}
```

Centralized Error Handling -- Neaten up our app by moving some of the error handling code into helper methods. This will help separate our concerns and stop us repeating code as we progress through the build.

## Centralized Error Handling

neaten up our application by moving some of the error handling code into helper methods. This will help *separte our concerns* and stop us repeating code as we progress through the build.

```go
package main

import (
	"fmt"
	"net/http"
	"runtime/debug"
)

// The serverError helper writes an error message and stack trace to the errLog.
// then sends a generic 500 internal server error response to the user.
func(app *application) serverError(w http.ResponseWriter, err error) {
	trace := fmt.Sprintf("%s\n%s", err.Error(), debug.Stack())
	app.errLog.Println(trace)
	
	http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

// And the clientError helper sends a specific status code and corresponding description
// to the user 400 like
func (app *application) clientError(w http.ResponseWriter, status int) {
	http.Error(w, http.StatusText(status), status)
}

// for consistency
func (app *application) notFound(w http.ResponseWriter) {
	app.clientError(w, http.StatusNotFound)
}
```

There is nothing huge amount of new code here, but it dow introduce new features.

- `serverError()`helper we use the `debug.stack()`func to get a stack trace for the current goroutine and append it to the log message. Being able to see the execution path of the application via the stack trace can be helpful when trying to debug errors
- `clientError()`uses the `http.statusText()`to automatically generate a human-readable.
- Started using the `net/http`package’s named contstants for HTTP status codes.

After, in the `handlers.go` and update it:

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		app.notFound(w)
		return
	}

	// initialize a slice containing the paths to the two files like:
	files := []string{
		"./ui/html/home.page.html",
		"./ui/html/base.layout.html",
		"./ui/html/footer.partial.html",
	}

	ts, err := template.ParseFiles(files...)
	if err != nil {
		app.serverError(w, err)
		return
	}

	err = ts.Execute(w, nil)
	if err != nil {
		app.serverError(w, err)
	}
}
```

### Isolating the Applications Routes

While we are refactoring our code there is one more change worth making -- `main()`is beginning to get a bit crowded. so to keep and focused like to move the route declarations for the application into a standalone routes.go file like:

```go
func (app *application) routes() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/", app.home)
	mux.HandleFunc("/snippet", app.showSnippet)
	mux.HandleFunc("/snippet/create", app.createSnippet)

	fileServer := http.FileServer(http.Dir("./ui/static/"))
	mux.Handle("/static/", http.StripPrefix("/static", fileServer))

	return mux
}
```

Then just modify the main.go like:

```go
//...
srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errLog,
    Handler:  app.routes(),
}
```

The routes for our application are now isolated and encapsulated in the `app.routes()`method. And the responsibilities of our `main()`function are limited to: 

- Parsing the runtime configuration settings fro the application
- Establishing the dependencies for the handlers, and 
- Running the HTTP server.

Dbs -driven responses -- For web app to be just truly we need somewhere to store the data entered by users -- and the ablitiy to query this data store dynamically at runtime.