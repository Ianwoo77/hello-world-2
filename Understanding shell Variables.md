# Understanding shell Variables

Often within a shell script, want to reuse certain items of information. During the course of procesing shell script, the name or number representing this info may change. To store info used by a shell script in such a way that can be easily reused, can set *variables* -- Variable names within shell scripts are case **sensitive** and can be defined in the following manner `NAME=value`

Variables can contain the ouput of a command or command sequence. Can accomplish thisy by preceding the command with a `$`and open parenthesis, `MYDATE=$(date)`assigns the output from the `date`command to the variable. And encloding the command in back-ticks can just have the same effect.

Escaping special shell characters -- Keep in mind that characters such as the dollar sign, ` *, !, and some other special meaning to the shell. On some occasions, want the shell to use these characters’ special meaning and other times you don’t. If wanted literally to show fore 

`$HOME`-- need escape the `$`, just like: ‘$HOME, or `\$HOME`. Using variables is a great way to get info that can chinge from computer to computer or from day to day. FORE:

```sh
MACHINE=`uname -n`
NUM_FILES=$(/bin/ls | wc -l)
```

Special shell positional parameters -- There are special variables that the shell assigns for U. Called *positional parameter or command-line argumetns* - it is referenced as $0, $1... ${10}... $0 is special assigned the name used to invoke your script. and others are assigned the values.

Reading in parameters -- using the `read`command, can prompt the user info and store that info to user later in the scrpit.

```sh
read -p "Type in an adjective, noun and verb: " adj1 noun1 verb1
echo "He signed and $verb1 to the elixir, then ate the $adj1 $noun1"
```

After prompting for an adj, noun, and verb, expects the user to enter words that are then assigned to the `adj1, noun1, and ver1`varaibles.

### Parameter expansion in Bash

As mentioned earlier, if you want the value of a variable, you precede it with `$`-- this is really just shorthand for the notaion. shorthand for `${CITY}`-- `{}`are used when the value of the paramter needs to be expand the vlaue of variable in different ways. like:

- `${var:-value}:`if variable is unset or empty, expand to `value`
- `${var#pattern}`-- chop the shortest match for pattern
- `${var##pattern}`-- chop the longst match for pattern from the front of var’s value.

```sh
THIS="Example"
THIS=${THIS:-"NOT SET"}
THAT=${THAT:-'NOT SET'}
echo $THIS
echo $THAT
```

### Performing arithmetic in shell scripts 

Bash uses *untyped* varaiables -- meaning that you are not required to specify.. It normally treats variables as strings or text, so unless you tell it otherwise with `declare` -- variable are just a bunch of letters to bash. Integer arithmetic can be performed using the built-in `let`command or through the external `expr`or `bc`commands.

```sh
#!/bin/bash
BIGNUM=1024
let RESULT=$BIGNUM/16
RESULT=`expr $BIGNUM/16`
echo $RESULT
# bc - calculator application
RESULT=`echo "$BIGNUM/16" | bc`
echo "$RESULT"
let foo=$RANDOM; echo $foo
```

Another way to grow a variable use $(()) notation with ++I added. l.ike:

```sh
I=0
echo "The value of I after increment is $((++I))"
echo "The vluae of I before and after increment is $((++I)) and $I"
```

using programming constructs in shell scripts...

## Learning System Administration -- 

Separating the role of system administrator from that of other users has several effects. FOr a system that has many people using it -- limiting who can manage it enables you keep it more secure -- A separate administrattive role also prevents other from casually harming you system when they are just using it write a document.

- `su` -- `su`is used to open a shell as root user
- `sudo`-- a regular user is given root privileges. After that, the user is immediately returned to a shell and acts as the regular user again -- Ubuntu by default assigns `sudo`privilege to the first user account created when the system is installed.
- `Cockpit`-- browser-based administaration -- Ubuntu has committed to Cockpit as its primary browser-based system administration facility.

Following is a list of common feature that as system adminstrator is expected to manage -- 

- *Filesytems* -- the directory structure is set up to make the system usable. If uers later want to add extra storage or change the filesystem layout outside of their home directory, they need administrative privileges.
- *Software Installation* -- Cuz malicious software can harm your system or make is just insecure, need to privilege to install software using a primary software package manager -- `APT`or `Snap` Note,regular users can still install some softeware in their won directories and can list information about installed software.
- *User accounts* -- Only the root user can add and remove user and group accounts
- *Network interfaces* -- In the past, the root user had to configure and stop and start network interfaecs. Many linux desktips allow regular users to start and stop..
- *Servers* - configuring web servers, file servers, domain name servers, mail servers..

### Using Cockpit administartion

*Cockpit* brings together a range of Linux administative activities into one interfaec and taps into a diverse set of Linux APIs useing cockpit-bridge.

The Ubuntu installation process prompts U to create a primary user account that will, be given membership in the `sudo`user group -- A root user exists, but it won’t have a password and Ubuntu doesn’t recommend you ever log in to that account. The root account will have its own home directory `/root`-- The home directory and other info associated wiht the root user acount are located in the `/etc/passwd`file. FORE:

`root:x:0:0:root:/root:/bin/bash`

This shows that for the user named `root`-- the user ID is set to 0, the groupID is set to 0, the home directory is `/root`-- and the shell for that user is `/bin/bash`. Linux uses the `/etc/shadow`file to store encrypted password data.

Becoming root from the shell -- It can be done using `sudo su`-- when prompted, you will enter your user’s password.
`sudo su` After successfully entering yuor password, note that your prompt will now read `root`.

Gaining temporary admin access with `sudo`-- Regular users can also be given administrative permissions for individual tasks by typing `sudo`.

Exploring Administrative commands, Configuration files, and log files -- Can expect to find many commands, configuration files, and log files in the same places in the filesystem.

Administrative commans - NOTE, when you are acting as root, your `$PATH`variable is set to include some directories that contain commands for the root user. Like:

- `/sbin`-- contains commands needed to boot your system, including commands for checking filesystems, `fsck`and turning on swap devices (swapon).
- `/usr/sbin`-- contains commands for such things as managing user accounts, and checking processes that are holding files open...

## Receiving Multiple Files in the Form

The `FormFile`method returns only the first file with the specified name, which means that it can’t be used when the user is allowed to select multiple files for a single form element, which is the case with the example form. Fore, the `Request.MultipartForm`field provides complete access to the data in the multipart form like:

```go
func HandleMultipartForm(writer http.ResponseWriter, request *http.Request) {
    request.ParseMultipartForm(100000)
    fmt.Fprintf(writer, "Name: %v, city: %v\n", 
               request.MultipartForm.Value["name"][0],
               request.MultipartForm.Value["city"][0])
    
    for _, header := range request.MultipartForm.File["files"] {
        fmt.Fprintf(writer, "Name: %v, size: %v\n", header.Filename, header.Size)
        file, err := header.Open()
        if err == nil {
            defer file.Close()
            fmt.Fprintln(writer, "-----")
            io.Copy(writer,file)
        }else {
            http.Error(...)
            return
        }
    }
}
```

For this, must ensure that the `ParseMultipartForm`method is called before using the `MultipartForm`field. And this returns a `Form`struct, whcih is defined in the `mime/multipart`package which defines:

- `Value`-- Returns a `map[string][]string`that contains form values.
- `File`-- This field returns a `map[string][]*FileHeader`that contains the files.

First, use the `Value`field to get the `Name`and `City`values from the form, Use the `File`field to get all files in the form with the name `fiels`which are represented by `FileHeader`values. using: `file, err := header.Open()`

### Reading and setting Cookies

The `net/http`package defines the `SetCookie()`which adds a `Set-Cookie`header to response sent to the client. like:

- `SetCookie(writer, cookie)`-- This func adds a `Set-Cookie`header to the specified **`ResponseWriter`**-- The cookie is described using a pointer to a `Cookie`struct. 

So, Cookies are described using the `Cookie`struct, which is defined in the `net/http`package and defines the fields.

`Name Value Path Domain Expires MaxAge Secure HttpOnly SameSite`

For the `SameSite`-- sepcifies the cross-origin policy for the cookie using the `SameSite`constants. And the `Cookie`struct is also used to get and set of cookies that a client sneds -- 

- `Cookie(name)`-- returns a pointer to the `Cookie`value with the sepcified name and an error that indicates when there is no matching cookie
- `Cookies()`-- returns a slice of `Cookie`pointers

```go
func GetAndSetCookie(writer http.ResponseWriter, request *http.Request) {
	counterVal := 1
	counterCookie, err := request.Cookie("counter")
	if err == nil {
		counterVal, _ = strconv.Atoi(counterCookie.Value)
		counterVal++
	}
	http.SetCookie(writer, &http.Cookie{
		Name: "counter", Value: strconv.Itoa(counterVal),
	})

	if len(request.Cookies()) > 0 {
		for _, c := range request.Cookies() {
			fmt.Fprintf(writer, "Cookie Name: %v, Value: %v", c.Name, c.Value)
		}
	} else {
		fmt.Println(writer, "Request contains no cookies")
	}
}

func init() {
	http.HandleFunc("/cookies", GetAndSetCookie)
}

```

This just sets up a `/cookies`route, for which the `GetAndSetCookie()`func sets a cookie named `counter`with an initial value of zero. So, when a request contains a cookie, the cookie value is read, parsed to an `int`, and incremented so that it can be used to set a new cookie value. The function also enumerates the cookies in the request and writes the `Name`and `Value`fields to the response.

## Creating HTTP Clients

In this, just describe the stdlib features for making http requests -- allowing apps to make use of web servers.

```go
func init() {
	http.HandleFunc("/html",
		func(writer http.ResponseWriter, request *http.Request) {
			http.ServeFile(writer, request, "./index.html")
		})
	http.HandleFunc("/json",
		func(writer http.ResponseWriter, request *http.Request) {
			writer.Header().Set("Content-Type", "application/json")
			json.NewEncoder(writer).Encode(Products)
		})

	http.HandleFunc("/echo",
		func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "text/plain")
			fmt.Fprintf(w, "Method: %v\n", r.Method)
			for header, vals := range r.Header {
				fmt.Fprintf(w, "header: %v: %v\n", header, vals)
			}

			fmt.Fprintln(w, "-----")
			data, err := io.ReadAll(r.Body)

			if err == nil {
				if len(data) == 0 {
					fmt.Fprintln(w, "NO body")
				} else {
					w.Write(data)
				}
			} else {
				fmt.Fprintf(os.Stdout, "Error reading body %v\n", err.Error())
			}
		})
}
```

The initialization function in this code file creates routes that generate HTML and JSON responses. There is also a route that echoes details of the request in the response.

### Sending Simple HTTP requests

The `net/http`package provides a set of convenience functions that make basic HTTP requests just:

- `Get(url)`-- sends a `GET`request to the specified HTTP or https url. The results are a `Response`and an `error`that reports problems with the request.
- `Head(url)`-- Sends a `HEAd`request ot the specified HTTP or HTTPs url. Just returns the headers what would be returned for a GET
- `Post(url, ContentType, reader)`-- Post -- with the specified `Content-Type`header value, the content for the form is provided by the speifieid `Reader`.
- `PostForm(url, data)`-- sends a POST requests to the speicified HTTP or HTTPs url, note, with the `Content-Type`header set to `application/x-www-form-urlencoded`

```go
func main() {
	Printfln("Starting HTTP server")
	go http.ListenAndServe(":5000", nil)

	time.Sleep(2 * time.Second)
	resp, err := http.Get("http://localhost:5000/html")
	if err == nil {
		resp.Write(os.Stdout)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

The argument to the `Get`function is a string that contains the URL to request, and the results are a `Response`value and an `error`that reports any problems sending the request.

- `Proto`-- returns a `string`containing the response http protocol
- `Location()`-- returns the URL from the response `Location`header and an `error`that indicates the response does not contain this header.

And, the `Write`method is convenient when you just want to see the resp.

```go
resp, err := http.Get("http://localhost:5000/html")
if err == nil && resp.StatusCode == http.StatusOK {
    data, err := io.ReadAll(resp.Body)
    if err == nil {
        defer resp.Body.Close()
        os.Stdout.Write(data)
    }
} else {
    Printfln("Error: %v, status code : %v", err.Error(), resp.StatusCode)
}
```

For this, used the `ReadAll()`function defined in the `io`package to read the response body into a `byte`slice, whcih rite to the std output.

## Configuration and Error Handling

going to do some housekeeping -- won’t actually add much few functionality to application, but instead of focus on making improvements that will make it easier to manage as it grows.

- Set configuration settings for your application at runtime in an easy and idiomatic way using command-line flags.
- Improve your app log messages to include more info, and manage them differently depending on the type.
- Make dependencies available to your handlers in a way that’s extensible, type-safe, and doesn’t get in the way when it comes to writing tests.
- *Centralize error handling* so that don’t need to repeat yourself when writing code.

### Managing Configuration settings

Command-line flags -- In go, a common and idiomatic way to manage configuration settings is to use command-line flags when starting an app. The eaiest to accept and parse a command-line flag from app is with a line of code like:

`addr := flag.String("addr", ":4000", "Http network address")`

just use this like:

```go
// define a new command-line with the name 'addr', default to 4000
// and some short help text explaining that
addr := flag.String("addr", ":4000", "Http network address")
flag.Parse()
```

Type Conversions -- In the code -- `flag.String()`function to define the command-line flag. this has the benefit of converting whatever value the user provides at runtime to a `string`type. Go also has a range of other functions including `flag.Int()`...

### Leveled Logging

At the moment, are outputting log messages just using the `log.Printf()`and `log.Fatal()`functions -- both of these output messages via Go’s std logger, which - by default - prefixes messages with the local date and time and writes them to the std error stream. The `log.Fatal()`also will call `os.Exit(1)`after writing the message, causing the app to immediately exit. Cal :

```go
log.Printf("Starting server on %s", *addr)
err := http.ListenAndServe(*addr, mux)
log.Fatal(err)
```

Improve this by adding some *leveld logging capability* -- so that information and error messages are managed slightly differently specially -- 

- We will prefix info messages with `INFO`and output the message to std out
- will prefix error messages with `ERROR`and output them to standard error, (stderr). Along with the relevant file name and line number that called the logger. Just like:

```go
// Then use log.New() to create a logger for writing info messages.
// 3 params - dest to write to; string prefix; flags to indicate
// what additional info to include
infoLog := log.New(os.Stdout, "INFO\t", log.Ldate|log.Ltime)
errLog := log.New(os.Stdout, "ERROR\t", log.Ldate|log.Ltime)
//...
infoLog.Prinf(..., *addr)
errLog.Fatal(err)
```

Decoupled Logging -- And a big benefit of logging you messages to the std streams like we are is that your app and logging are decoupled. In staging or production environments, can redirect the streams to the final destionation for viewing and archival. -- like:

```sh
go run ./cmd/web >> /tmp/info.log>>/tmp/error.log
```

The http.Server Error log -- And there is one more change we need to make to our application, by default, if Go’s HTTP server encounters an error it will log it using the std logger, for consistency, it’d be better to use our new `errorLog`logger instead.

```go
srv := &http.Server{
    Addr: *addr,
    ErrorLog: errLog,
    Handler: mux,
}
infoLog.Printf("Starting server on %s", *addr)
err := srv.ListenAndServe()
errLog.Fatal(err)
```

Logging to a file -- general recommendatoin is to log your output to std streams and redirect the output to a file at runtime. *dont* want to do this. Can also:

```go
f, err := os.OpenFile("/tmp/info.log", os.O_RDRW|os.O_CREATE, 0666)
if err != nil {
    log.Fatal(err)
}
defer f.Close()

infoLog := log.New(f, "INFO\t", log.Ldate | log.Ltime)
```

### Dependency Injection

There is one more problem with our logging that need to address -- if openup your go file you will notice that the `home`handler function is still writing error messages using Go’s std logger, not the `errorLog`logger that we want to be using. So, how can we make our new `errorLog`logger available to our `home`function from `main()`--  there are a few different ways to do this -- the simplest is put the dependencies in global variables, but in general, it is good practice to *inject* dependencies into your handlers.