# Docker platform -- 

For running application in lightweight units called containers -- Containers have hold in software everywhere, form serverless functions in the cloud to strategic planning in the enterprise. Start using Docker for development tools, source code and build servers -- then gained confidence and started running the APIs in containers for test environment -- By the end of the project, every environment was powered by Docker, including production. 

The only requirement for building, deploying, and managing the app -- was Docker. Docker centralizes the *toolchain* and makes everything so much easier for everybody that thought one day every proj would have to use containers.

### Migrating apps to the cloud

Moving apps to the cloud is top of mind for many organizations. Host apps across global datacenters with practically limitless potential to scale. Docker offers option without the compromises. Migrate each part of your app to a container, and then you can run the whole app in containers using Azure Kubernetes Service.. Or on own Docker cluster in the datacenter. Namely, the problem is run a distributed app like this in container.

It does take some investment to migrate to containers, need to build your existing installation steps into scripts called `Dockerfiles`and your deployment documents into descriptive applicaiton manifest using docker compose or kubernetes format.

Modernizing legacy apps -- Can run pretty any app in the cloud in a container. Containers run in their own vitual network, so can communicate with each other without being exposed to the outside world. Can start breaking your app up, moving features into their own containers.

### Remembering the cleanup commands

Docker doesn’t automatically cleanup, when quit, all your containers stop and they don’t use any CPU or memory, but if want to, can clean up at the end of every like:

```sh
docker container rm -f $(docker container ls -aq)
# reclaim disk space 
docker image rm -f $(docker image ls -f reference='diamol/*', -q)
```

## Running in a container

Started with Docker at the same way would with any new -- going to:

```sh
docker container run diamol/ch02-hello-diamol
```

There is just a lot in -- `docker container run`command tells Docker to run an app in a container. Has been published on a public site that anyone con access. Docker needs to have a copy of the image locally before it can run a container using the image. The very first time you just run this command, won’t have a copy of the image, and Can see *unable to find image locally* -- then docker downloads the image.

Now start a container using that image. The image contains all the content for the app, along with instruction telling Docker how to start the app. This just shows the core Docker workflow. Someone just packages their app to run in a container, and then publishes it so it’s available to other users. Then anyone with access can run the app in a container. Docker calls -- `build, share, run`.

### What is a container

A docker container is just the same idea of a physical container -- like a box with an application in it. Inside the box, the app seems to have a computer all to itself, it has its own machine name and IP address, and it also has its own disk drive. For those things -- are all virtual resources -- hostname, ip, and filesystem are created by Docker. They are logical objects that are managed by Docker.

And the app inside the box can’t see anything outside the box. But the box is running on a computer, and that computer can also be running lots of other boxes. They all share the CPU and memory of the computer. It just fixes two conflicting problem in computing -- isolation and density. Apps may **NOT** work nicely with other apps. Might use diffrerent version of Java or .net.

For VM -- nddes own OS -- doesn’t share the OS of the computer where the VM is running. For every VM nddes its own os, and that os can be gigbytes of memory..

For containers -- each shares the os of the computer running the container, and that makes them extremely lightweight.

### Connecting like a remote computer

There are just plenty of situations where one thing is all you want to do. Those scripts needs a specific set of tools to run, so can’t jsut share the scripts with a collegue. Also need to share a document that describes setting up all the tools, and your colleage.. Run a container and connect to a terminal inside the container.

```sh
docker container run --interactive --tty diamol/base
```

The `--interactive` tells Docker that want to set up a connection to the container. And the `--tty`means want to connect to a terminal session inside the container.

Remember that -- the container is sharing your computer’s OS -- which is why you see a linux shell if running on Ubuntu. And can use:

```sh
docker container ls
```

For this shows info about each container, including the image, container id, and command docker run inside the container when it started. And fore:

```sh
# lists the processes running in the container
docker container top <NAME>
```

And if have multiple processes running in the container, Docker will show them all. That will be the case for Windows container.  And:

```sh
# shows all the details of a container
docker container inspect <NAME>
```

### Hosting a website in a container

```sh
docker container ls --all
```

First, containers are running only while the app inside the container is running. As soon as the app process ends, the container goes into the exited state. -- Exited don’t use any CPU or memory. Second, note that containers don’t disappear when they just exit -- Containers in the exited state still exist, which means U can start them again.

What about starting containers that stay in the background and just keep running like:

```sh
docker container run --detach --publish 8088:80 diamol/ch02-hello-diamol-web
```

The image you have just used is `diamol/ch02-hello-diamol-web`-- includes the Apache web server.-- 

- `--detach`-- starts the container in the background and shows the container ID
- `--publish`-- publishes a port form the container to the computer.

Running a detached container just puts the container in the background so it start up and stays hidden. When install docker, it injects itself into your computer’s networking layer. Traffic coming into your computer can be intercepted by Docker, and then Docker can send that traffic into a container. 

Need to note that the containers are not exposed to the outside world by default. Each has its own IP address. The container is not attahed to the *physical* network of a computer -- Publishing a container port means Docker listens for network traffic on the computer port, and then sends it into the container.

FORE, conainer has ip 172.0.5.1 -- is assigned by Docker for a vritual network managed by Docker. Can send traffic to the local computer. The web content is packaged with the web server, so the docker image has everything it needs. A web developer can run a single container on their laptop, and the whole application.

```sh
docker container stats <NAME>
```

Shows a live view of how much CPU, memory, network, and disk the container is using. When you are done working with a container, can remove it with `docker container rm`and the container ID, and using the `--force`flag to force removal if still running.

```sh
docker container rm --force $(docker container ls --all --quiet)
```

The `$()`sends the output from one command into another. `--quiet`, only for numeric IDs.

### Understanding how Docker runs containers

- The *Docker Engine* is the management component of Docker -- looks after the local image cache, downloading images when need them, and reusing them if already downloaded.
- The Docker engine makes all the features available through the *Docker API*.

## Json Recipes

JSON is just a lightweight data-interchange text formats -- it’s meant to be read by humans but also easily read by machines and is based on a subset of JS. Is popular with RESTful web services.

### Parsing JSON data byte arrays to Structs

1. Create structs to contain the JSON data
2. Unmarshal the JSON string into the structs.

For s complicated json file, just store the data in JSON, create a struct first:

```go
type Person struct {
	Name      string    `json:"name"`
	Height    string    `json:"height"`
	Mass      string    `json:"mass""`
	HairColor string    `json:"hair_color"`
	SkinColor string    `json:"skin_color"`
	EyeColor  string    `json:"eye_color"`
	BirthYear string    `json:"birth_year"`
	Gender    string    `json:"gender"`
	Homeworld string    `json:"homeworld"`
	Films     []string  `json:"films"`
	Species   []string  `json:"species"`
	Vehicles  []string  `json:"vehicles"`
	Starships []string  `json:"starships"`
	Created   time.Time `json:"created"`
	Edited    time.Time `json:"edited"`
	URL       string    `json:"url"`
}
```

For this the string literal after the definition in each field in the struct is called a `struct tag`- Go determines the mapping between the struct fileds and the JSON elements using these struct tags -- Don’t need them if your mapping is exactly the same. -- JSON normally use snake case - variables with speaces replaced by underscores, with lowercase characters. As can see, can define string slices to store arrays in the JSON and use sth like `time.Time`as the data type as well. Can use most Go data types.. like:

```go
func unmarshal() (person Person) {
	file, err := os.Open("skywalker.json")
	if err != nil {
		log.Println("Error opening json file", err)
	}
	defer file.Close()

	data, err := io.ReadAll(file)
	if err != nil {
		log.Println("Error reading json file", err)
	}

	err = json.Unmarshal(data, &person)
	if err != nil {
		log.Println("Error unmarshalling json data:", err)
	}
	return
}
```

In this code, after reading the data from the file, you create a `Person`struct instance and then unmarshal the data into it using `json.Unmarshal`.

```go
func unmarshalAPI() (person Person) {
	r, err := http.Get("https://swapi.dev/api/people/1")
	if err != nil {
		log.Println("Cannot get from URL", err)
	}
	defer r.Body.Close()
	data, err := io.ReadAll(r.Body)
	if err != nil {
		log.Println("Error reading json data", err)
	}
	err = json.Unmarshal(data, &person)
	if err != nil {
		log.Println("Error unmarshalling json", err)
	}
	return
}
```

### Parsing unstructured JSON data

Want to just parse some JSON data but you don’t know the json’s data structure or properties in advance enough. -- for this, just using the same before but instead of predefined structs, using just a map of strings to `any`to store data.

```go
func unstructured() (output map[string]any) {
	file, err := os.Open("unstruct.json")
	if err != nil {
		log.Println("Error opening json file", err)
	}
	defer file.Close()

	data, err := io.ReadAll(file)
	if err != nil {
		log.Println("error reading json data", err)
	}

	err = json.Unmarshal(data, &output)
	if err != nil {
		log.Println("error unmarshaling json data", err)
	}
	return
}
```

Cuz, using structs has its advantages, using `any`essentially makes the data structure untyped.

```go
func main() {
	unstruct := unstructured()
	vender, ok := unstruct["Darth Vader"].([]any)
	if !ok {
		log.Println("Cannot type assert")
	}
	fmt.Println(vender[0])
}

```

### Parsing JSON data streams into Structs

Want to parse JSON data from a stream -- Create structs to contain the JSON data, create a decoder using `NewDecoder`in the `encoding/json`package, then call `Decode`on the decoder to decode data into the structs like: Using `Unmarshal`is simple and strarighforward -- for JSON files or API data. But for the streaming data -- Can no longer use cuz `Unmarshal`needs to read the while file at once.

Fore, has a 

```go
func unmarshalStructArray() (people []Person) {
	file, err := os.Open("People.json")
	if err != nil {
		log.Println("Error opening json file", err)
	}
	defer file.Close()

	data, err := io.ReadAll(file)
	if err != nil {
		log.Println("Error reading json data", err)
	}

	err = json.Unmarshal(data, &people)
	if err != nil {
		log.Println("Error unmarshaling json data", err)
	}
	return
}
```

This will get an array of `Person`structs, whch you get after unmarshaling a single JSON array. Then this is not a valid JSON format. Somthing you can get when read the `Body`of the `http.Response`fore.

Can parse it by decoding it using a Decoder like:

```go
func decode(p chan<- Person) {
	file, err := os.Open("not_good_json.json")
	if err != nil {
		log.Println("Error opening json file", err)
	}
	defer file.Close()

	decoder := json.NewDecoder(file)
	for {
		var person Person
		err = decoder.Decode(&person)
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Println("Error when decoding json data", err)
			break
		}

		p <- person
	}
	close(p)
}

func main() {
	p := make(chan Person)
	go decode(p)
	for {
		person, ok := <-p
		if ok {
			fmt.Printf("%#v\n", person)
		} else {
			break
		}
	}
}
```

Can see that 3 `Person`structs are being printed here, one after another.

## Setting up the Session Manager

In this, run through the process of setting up and using the session package.

```go
type application struct {
    errorLog *log.Logger
    infoLog *log.Logger
    session *session.Session
    snippets *mysql.SnippetModel
    templateCache map[string]*template.Template
}

//...
session := sessions.New([]byte(*secret))
	session.Lifetime = 12 * time.Hour
	app := &application{
		errLog:        errLog,
		infoLog:       infoLog,
		snippets:      &mysql.SnippetModel{DB: db},
		templateCache: templateCache,
		session:       session,
	}
```

For the sessions to work, 

- Waht session managers are available to help us implement sessions in Go
- How can customize session bahavior based on app’s need.
- How to use sessions to safelty and securely share data between requests for a particular user.

Also need to wrap our app routes with the middleware provided by the `Session.Enable()`method -- this loads and save session data to and from the session cookie every HTTP request and response as appropraite.

Instead, create a new `dynamicMiddleware`chain containing the middleware appropriate for our dynamic application routes only.

```go
// Creates a new middleware chain containing the middleware specific to
// dynamic app routes
dynamicMiddleware := alice.New(app.session.Enable)
mux := pat.New()
mux.Get("/", dynamicMiddleware.ThenFunc(app.home))
mux.Get("/snippet/create", dynamicMiddleware.ThenFunc(app.createSnippetForm))
mux.Post("/snippet/create", dynamicMiddleware.ThenFunc(app.createSnippet))
mux.Get("/snippet/:id", dynamicMiddleware.ThenFunc(app.showSnippet))
```

If just run the app, now should find it compiles ok, and your app routes continue to work as normal like: -- Without using Alice -- if you are not using the `alice`package to help your middleware chains, then simply need to wrap your handler functions with the session middleware instead. Just like:

```go
mux := pat.New()
mux.Get("/", app.session.Enable(http.HandlerFunc(app.home)))
mux.Get("/snippet/create", app.session.Enable(http.HandlerFunc(app.createSnippetForm)))
```

