# Managing Running Processes

In addition to being a multiuser OS, Linux also a multitasking system, means that many programs can be running at the same time. An instance of a running program is referred to as a process.

### Understanding Linux Processes

A process is just a running instance of a command, fore, there may be one vi -- by run 15 different users, that command is represented by 15 different running processes.

A process is identified on the system by what is referred as a PID -- is a *unique* for the current system. In other words, no other process can use that number as its process ID while that first process is still running. Along with this, other attributes are just associated with a process. when it is run -- is associated with a particular user account and group account. That account info helps determine what system resources that process can access.

Listing -- The Linux version of `ps`contains a variety of options from the old Unx and BSD system. fore:

```sh
ps u # equ -u, asks username be shown.
```

The processes shown are just associated with the current terminal -- tty1-- The concept of a terminal comes from the old days. So a terminal typically represented a single person at a single screen.

*VSZ* -- shows the size of the image process in k. And RSS (resident set size) shows the size of the program in memory. The vsz and RSS sizes may be different cuz VSZ is amount of memory allocated for the process. Note that many processes running on a computer are not associated with a terminal. Many processes running in the background -- perform such tasks as logging system activity or listening for data coming in from the network. are often strated when linux boots up and run continuously until the system shuts down.

```sh
ps ux | less
```

The page through all processes runing for all users on system. use `ps aux`for `q`to quite.

And the `ps`command can be customized to display selected columns of info and to sort info by one of those columns. like `-o`indicate the column want to list.

```sh
ps -eo pid,user,uid | less
```

If want to sort, just by specific column, `sort=`option like:

```sh
ps -eo pid,user,group,gid,vsz --sort=-vsz | head
```

### Listing and changing processes with top

The `top`command provides a screen-oriented means of displaying proceses running on your system. with `top`the default is to display processes based on how much CPU time they are currently consuming. A common practice is to use `top`to find processes that are consuming too much memory or processing prower and then act on those processes.

Killing a process -- note that the process ID of the process you want to kill and press `k`.

Managing backgournd and foreground processes -- Although `Bash`shell doesn’t include GUI for running many programs at once, does let you move active programs between background and foreground. Can place an active program in the background in several ways. `&`to the end of command line, also can use `at`to run. And to stop a running command and put it in the background, ctrl+z. Can either bring it back to run `fg command`or starting in background `bg command`. fore:

```sh
#starting background processes
find /usr > /tmp/allusrfiles & #prints filenames then save
```

To check which commands have running in the background, using the `jobs`like:

Using foregrouand and background commands -- Can bring any of the commands on the jobs list to the foregournd, like: `fg %1` -- % refers to the most recent command put into the background. `%string`-- referst where the command begins with a particular string of char. `%?string`-- where the command line contains any point. `%--`-- stopeed before the one most recently stopped.

### Killing and renicing Processes

Can use command-line tools to kill a process or change its CPU priority. The `kill`can send a `kill`signal to any process to end it. Besides telling a process to end, a signal might tell a process to reread configuration files, pause, or continue. like:

```sh
kill 10432
kill -15 10432  # 15 termination eq upper
kill -SIGKILL 10432
```

On occasion, a `SIGTERM`doesn’t kill a process, may need a `SIGKILL`to just kill it.

Note that, another useful signal is `SIGHUP`-- fore, something on desktop were just corrupt, could sand a `SIGHUP`signal to reread its configuration files and restart the desktop like:

```sh
kill -1 1833
kill -HUP 1833
```

Using `killall`to signal processes by name -- Can signal processes by name instead by ID. like:
`killall bash`

Setting priority with `nice`and `renice` -- When the kernel tries to decie which running processes get access to the CPUs on your system, one of the thing it takes into account is the nice vlaue set on the process -- Every process running on the system has a `nice`value between -20 to 19 -- by default the nice value is 0-- 

- The lower the nice value, the more access to the CPUs the process has. So, -20 nice value just gets more attention than a process with a 19 nice value
- A regular can set nice form 0 to 19 -- no neg values are allowed.
- And a regular user can set to higher, not lower.
- A regular can set nice value only on the user’s own procesess
- A root user can set on any process to any valid value, up or down.

Can use the `nice`command to run a command with a particular nice value. When a process is running, can change the nice value using just the `renice`command, along with the process id of the process.

```sh
nice -n +5 updatedb &
```

So the `updatedb`is used to generate the locate dbs manually by gathering names of files.. just wanted `updatedb`to run in background and not interrupt work.. Then can see `NI`column -- the nice value set to 5.

```sh
# as root user
renice -n -5 20284
```

Limiting Processes with cgroups -- Cgroups can be used to identify a process as a taks, belonging to a particular contorl group.

## Writing Simple Shell Scripts

is a group of commands, functions, variables, or just about anything else you can use from a shell. These items are typed into a plain text file. can then be run as a command.

Shell scripts ae the equivalent of batch files in Windows, contain long lists of commands.. Complex flow control.. 

Executing and debugging -- One of the primary advantages of shell scripts is that you can read the code by simply opening it in any text editor. executes in two basic ways -- 

- The filename is used as arg to the shell.
- The shell script may also have the name of the interpreter placed in the first line of the script by `#!`-- fore: `#!/bin/bash`and have the execute bit of the file contining the script set. Can then run script just as you would any other program by typing the name of the script on the command line.

And when scripts are executed in either manner, options for the program may be specified on the command line.

- In some cases, can place an `echo`statement at the beginning of the lines with the body of a loop and sorrounding the command with quotes.
- Can place dummy `echo`throughout the code.
- Can use `set -x`beginning of the script to display each command that is exuected like:
  `$bash -x myscript`
- Cuz useful have a tendency to grow over time. Keeping code readable.

Using variables is a great way to get info that can change from computer to computer or from day to day.

```sh
MACHINE = `uname -n`
NUM_FILES=$(/bin/ls | wc -l)
```

And variables can also contain the value of other variables. This is useful when you have to preserve a value that will cahnge to so that you can use it later in the script.

```sh
#! /bin/bash
# acript to echo out command-line arguments
echo "The first arg is $1, The second is $2."
echo "The command itself is called $0."
echo "There are $# parameters on your command line."
echo "There are all the arguments : $0."
```

And, assume that the script is executable and located in a directory in `$PATH`. just.

## Rading Form Data from Requests

JSON responses are just widely used in web services, which provdie access to an application’s data for clients that don’t want to recevie HTML. Just like:

```go
func HandleJsonRequest(writer http.ResponseWriter, request *http.Request) {
    writer.Header().Set("Content-Type", "application/json")
    json.NewEncoder(writer).Encode(Products)
}

func init(){
    http.HandleFunc("/json", HandleRsonRequest)
}
```

Just note have explicitly set the `Content-Type`header.

### Handling Form Data

The `net/http`package provides support for easily receiving and processing form data. Add a file like:

```html
<body>
    {{$index := intVal (index (index .Request.URL.Query "index") 0)}}
    {{if lt $index (len .Data)}}
    {{with index .Data $index}}
    <h3 class="...">
        Product
    </h3>
    <form method="POST" action="/forms/edit" class="m-2">
        <div class="mb-3">
            <label>Index</label>
            <input name="index" vlaue="{{$index}}"
                   class="form-control" disabled />
            <input name="index" value="{{$index}}" type="hidden" />
        </div>
    </form>
    {{end}}
    {{else}}
    <h3>
        some error message
    </h3>
    {{end}}
</body>
```

Reading Form data from Requests -- Now that have a `form`to the project, write the code that receives the data it contains, the `Request`struct defines the fields and methods like:

- `Form`-- `map[string][]string` containing the parsed form data
- `PostForm`-- similar to `Form`but excludes the query string parameters
- `MultipartForm`-- returns a multipart form represented using the `Form`struct defined in the `mime/multipart`package. `ParseMultipartForm()`called first.
- `PostFormValue(key)`-- returns first value for the specified form key
- `FormFile(key)`-- access to the first file with the specifeid key in the form.
- `ParseForm()`-- parses a form and populates the `Form`and `PostForm`fields.
- `ParseMultipartForm(max)`-- parses a MIME multiplart form and populates the `MultipartForm`field.

Like:

```go
func ProcessFormData(writer http.ResponseWriter, request *http.Request) {
    if(requst.Method== http.MethodPost) {
        index, _ := strconv.Atoi(requst.PostFormValue("index"))
        p:= Product{}
        p.Name=request.PostFormValue("name")
        p.Price, _ = strcovn.ParseFloat(request.PostFormValue("price"), 64)
        products[index]=p
    }
    http.Redirect(writer, requeset, "/templates", http.StatusTemporaryRedirect)
}
```

### Reading Multipart Forms

And note that forms encoded as `multipart/form-data`allow binary data, such as files, to be just safely sent to the server, to create a form that allows the server to receive a file, created like `upload.html`in the `static`folder:

```html
<body>
<div class="m-1 p-2 bg-primary text-white h2 text-center">
    Upload file
</div>

<form method="post" action="/forms/upload" class="p-2"
      enctype="multipart/form-data">
    <div class="mb-3">
        <label class="form-label">Name</label>
        <input class="form-control" type="text" name="city">
    </div>
    
    <div class="mb-3">
        <label class="form-label">Choose Files...</label>
        <input class="form-control" type="file" name="files" multiple>
    </div>
    <button type="submit" class="btn btn-primary mt-2">Upload</button>
</form>
</body>
```

The `enctype`attribute on the `form`element creates a mutlipart form, and the `input`element whose type is `file`creates a form control that allows the user to select a file, the `multiple`attriute tells the browser to allow the user to select multiple files. Just like:

```go
func HandleMultipleForm(writer http.ResponseWriter, request *http.Request) {
	fmt.Fprintf(writer, "Name: %v, City: %v\n", request.FormValue("name"),
		request.FormValue("city"))
	fmt.Println(writer, "------")
	file, header, err := request.FormFile("files")
	if err == nil {
		defer file.Close()
		fmt.Fprintf(writer, "Name: %v, Size: %v\n", header.Filename, header.Size)
		for k, v := range header.Header {
			fmt.Fprintf(writer, "Key: %v, value: %v\n", k, v)
		}
		fmt.Fprintln(writer, "------")
		io.Copy(writer, file)
	} else {
		http.Error(writer, err.Error(), http.StatusInternalServerError)
	}
}

func init() {
	http.HandleFunc("/forms/upload", HandleMultipleForm)
}
```

Receiving Multiple Files in the Form -- And the `FromFile`method returns just only the first file with the specified name, which means that it can’t be used when the user is allowed to select multiple files for a single form element. the `Request.MultipartForm`field provides complete access to the adata in a multipart form like:

```go
func HandleMultipleForm(writer http.ResponseWriter, request *http.Request) {
	request.ParseMultipartForm(1024 * 1024)
	fmt.Fprintf(writer, "Name: %v, City: %v\n",
		request.MultipartForm.Value["name"][0],
		request.MultipartForm.Value["city"][0])
	fmt.Fprintln(writer, "-------")
	for _, header := range request.MultipartForm.File["files"] {
		fmt.Fprintf(writer, "Name: %v, size: %v\n", header.Filename, header.Size)
		file, err := header.Open()
		if file == nil {
			defer file.Close()
			fmt.Fprintln(writer, "------")
			io.Copy(writer, file)
		} else {
			http.Error(writer, err.Error(), http.StatusInternalServerError)
			return
		}
	}
}
```

