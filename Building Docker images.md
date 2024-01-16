# Building Docker images

ran some containers in the last -- use Docker to manage them. Containers provdie a consistent experience acorss applications, no matter what technology stack the app uses.

### Using a container image from Docker Hub

How it’s been designed to work well with Docker. The try-now exercises all use a simple applicaiton called web-ping. Pull the container image for the web-ping -- like:

```sh
docker image pull diamol/ch03-web-ping
```

Stored on Docker Hub, which is the default location where Docker looks for images, image servers are called *registries* -- and docker hub is a public registry you can use for free. Docker hub also has a web interface, and you will find details bout... interesting output from the `docker image pull`-- which shows you how images are stored. A docker image is just logically one thing -- can think of it as a big zip that contains the whole application stack.

Note that during the pull don’t see one single file downloaded, you see lots of downloads in progress. Those are called image layers. A docker image is physically stored as lots of small files, and Docker just assemblies them together to create the containe’s filesystem. Now run it: like:

```sh
docker container run -d --name web-ping diamol/ch03-web-ping
```

`-d`just for `--detach`, so this container will run in the background -- the app run like a batch job with no user interface. for the `--name`flag -- also give containers a friend name.

For this app, just runs in an endless loop, and can see what is doing using the `docker container logs`

```sh
docker container logs web-ping
```

And an app that makes web requests and logs how long the response took is fairly useful. The applicaiton can actually be configured to use a different URL, a different interval between requests, and even a different type.

*Environment variables* are just k/v pairs that the OS provides, they wrok in the same way on Win or Linux. The web-ping image has some default values set for environment variables. When run a container, those environment variables are populated by Docker. Try -- remove existing, and run a new with `TARGET`environment variable like:

```sh
docker rm -f web-ping
docker container run --env TARGET=baidu.com diamol/ch03-web-ping
```

This container is doing sth different -- first, it’s running interactively cuz U didn’t use the `--detach`flag, so the output from the app is shown on you console. The container will keep sunning until you end the app.

Docker images may be packaged with default set of configuration values for the app, but you should be able to provide different configuration settings when you run a container. And the `web-ping`app code looks for an environment vairable with the key `TARGET`-- that key is set with a value of .. in the image, can provdie a different value with the:
`docker container run`command by using the `--env`flag.

And the host computer has its won set of environment variables too. but are *separate form the container*. Each container only has the environment variables that Docker populates. The important thing is that the `web-ping`apps are the same in each continer, they use the same image -- so the app is running the exact same set of binaries, they use just the same image, so the app is running the exact same set of binaries.

### Writing the first Dockerfile 

Is just simple script you write to package up an application -- it’s set of instructions, and a docker image is just the ouput. Can package up any kind of app using a Dockerfile. A scripting languages - like:

```dockerfile
FROM diamol/node

ENV TARGET="blog.sixeyed.com"
ENV METHOD="HEAD"
ENV INTERVAL="3000"

WORKDIR /web-ping
COPY app.js .
CMD ["node", "/web-ping/app.js"]
```

The Dockerfile instructions are `FROM ENV WORKDIR COPY CMD` -- They are in captials-- just a convention.

- `FROM`-- every image has to start from another image -- in this case, the `web-ping`will use the `diamol/node`image as its starting point. For this has `node.js`installed.
- `ENV`-- sets values for environment variables `[key]=[value]`-- there are 3 `ENV`variables.
- `WORKDIR`-- creates a directory *in the container image filesystem*, and sets that to be the current working directory. 
- `COPY`-- copies files.. from the local into the container image. For now, `COPY app.js .`just copid.
- `CMD`-- specify the command to run when the Docker starts a container from the image.

### Building own container image

Docker needs to know a few things before it can build an image from a Dockerfile -- needs a name for the image, and it needs to know the locaiton for all the files that it’s going to package into the image. Fore:

```sh
docker image build --tag web-ping .
```

the `--tag`arg is the name for the image, and the final arg is just directory where the docker and related files are. In Docker, calls this directory the `context`.

If get any errors from the `build`-- first need to check that the `Docker`engine is started. Can:

```sh
docker image ls 'w*'
```

Can jus see we-ping image listed -- Then can use this image in exactly the same way as the one you downloaded from `Docker Hub`.

```sh
docker container run -e TARGET=baidu.com -e INTERVAL=5000 web-ping
```

for this, container is just running in the foreground, so will need to stop with. 

### Understanding Docker images and image layers

The docker image contains all the files you packaged, which become the container’s filesystem. And it also contains a lost of metadata about the image itself. Can check the history of image:

```sh
docker image history web-ping
```

Then, the `CREATED BY`commands are the `Dockerfile`intructions -- there is a one-to-one relationship, so each line in the Dockerfile creates an image layer. A Docker image is logical collection of image layers. Layers are the files that are physically stored in the Docker cache. Image layers can be ***shared*** between different images and different containers. If you have lots of containers all running fore, `node.js`apps, will all share the same set of image layers that contain the `Node.js`runtime.

For the `diamol/node`-- has a slim OS layer, and the the `node.js`runtime. For this, `web-ping`image is based on `diamol/node`-- so starts with all the layers from that image.

```sh
docker system df # show exactly how much space docker is using
```

One last of that -- if image layers are shared around, they can’t be edited -- otherwise a change in one image would cascade to all the other layers read-only.

## JSON Recipes

```go
func unmarshal() (person Person){
    file, err := os.Open("...json")
    if err != nio {
        ...
    }
    defer file.Close()
    
    data, err := io.ReadAll(file) // note
    if err != nil {}
    err = json.Unmarshal(data, &person)
    if err != nil {...}
    return
}

// or:
func unmarshalAPI() (person Person){
    r, err := http.Get(".../people/1")
    if err != nil {...}
    defer r.Body.Close()
    data, err := io.ReadAll(r.Body)
    //... like upper
}
```

### Parsing Unstructured Json data

Obviously from the JSON, the keys are not consistent and can change with the addition of a character. For such cases, how do you unmarshal the JSON -- Instead of predefined structs, can use a map of strings to `any` like:

```go
func unstructured() (output map[string]any) {
    //...
    defer file.Close()
    err = json.Unmarshal(data, &output)
    //...
    return
}
```

Just note that it’s a lot easier to retrieve data from structs than froma map cuz you know for sure what fields are available. Also, need to do *type assertion* to get the data out of an interface. Fore, want to get the films that featured:

```go
unstruct := unstructured()
vader := unstruct["Darth Vader"]
first := vader[0] // error
vader, ok := unstruct["Darth Vader"].([]any)
if !ok {
    ...
}
first := vader[0]
```

Parsing into structs -- want to parse JSON data from a stream -- create structs to contain the JSON data. create a decoder using `NewDecoder`like: If want to get a stream of JSON objects lke:{}{}{}... Notice that this is not a single JSOn object but 3 consecutive JSON objects. This is no longer a valida JSON file. Fore:

```go 
func decode(p chan<- Person) {
    file, err := os.Open(".json")
    //...
    defer file.Close()
    decoder := json.NewDecoder(file)
    for{
        var person Person
        err = decoder.Decode(&person)
        if err == io.EOF {
            break
        }
        if err != nil {
            ...
            break
        }
        p <- person
    }
    close(p)
}
```

Can just see that 3 `Person`struct are being printed here, one after another, opposed to the eariler. So, `Unmarshal`is just easier to use for a single JSON object, but it *won’t work when you have a stream* of them coming in from a reader. Also, it simplicity means it’s not as flexible -- just get the whole JSON data at a go.

`Decode`-- works well for both single JSON objects and streaming JSON data. Also, with `Decode`can do stuff with the JSON at a finer level without needint to get the entire JSON data out first.

### Creating JSON Data Byte arrays from a structs

Want to create JSON data from a struct -- Create the struct then use just `json.Marshal`package to marshal the data into a JSON slice of bytes. Create the structs then use just the `json.Marshal`package to marshal the data into a JSON slice of bytes -- 

1. Create structs that you wil use to marshal data from.
2. Marshal the data into a JSON string using `json.Marshal`or `json.MarshalIndent`

```go
func main() {
	resp, err := http.Get("https://swapi.dev/api/people/14")
	if err != nil {
		log.Println("Cannot read", err)
	}
	defer resp.Body.Close()
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Println("Error reading json data:", err)
	}
	var person Person
	json.Unmarshal(data, &person)
	fmt.Println(person)
	err = os.WriteFile("han.json", data, 0644)
	if err != nil {
		log.Println("Cannot write", err)
	}
}
```

### Creating JSON data streams from Structs

Want to create streaming JSOn data from structs -- Create an encoder using `NewEncoder`in the `encoding/json`package, passing it an `io.Writer`-- then call `Encode` on the encoder to encode structs data to a stream like: The `io.Writer`interface has a `Write`method that writes bytes to underlying data stream. like;

```go
func get(n int) (person Person) {
	r, err := http.Get("https://swapi.dev/api/people/" + strconv.Itoa(n))
	if err != nil {
		log.Println("Cannot get from URL", err)
	}
	defer r.Body.Close()
	data, err := io.ReadAll(r.Body)
	if err != nil {
		log.Println("Error reading json data:", err)
	}
	json.Unmarshal(data, &person)
	return person
}

func main() {
	encoder := json.NewEncoder(os.Stdout)
	for i := 1; i <= 4; i++ {
		person := get(i)
		encoder.Encode(person)
	}
}

```

As seen, using the `os.Stdout`as the writer. Actually, the `os.Stdout`is just an `os.File`struct instance but a `File`is also a write. Note that if are annoyed by the untidy output here just using:

`encoder.SetIndent("", " ")`

And `Encode`, is also **faster** then `Marshal`.

### Omitting Fileds in structs

Whan marshaling JSON structs as JSON encoding, sometimes there is no data for some of the struct variables. U want to create JSON encoding that leaves out the variables without any data. Using the `omitempty`tag to define struct variable that can be omitted when marshaling -- If you don’t want to show some .. can use:

```go
type Person struct {
    //...
    Species   []string  `json:"species,omitempty"`
	Vehicles  []string  `json:"vehicles,omitempty"`
	Starships []string  `json:"starships,omitempty"`
}
```

## Working with Session Data

Put the session functinality to work and use it to persist the confirmation flash message between HTTP requests. To add the confirmation message to the session data for a user we should use the `*Session.Put()`method -- the second parameter to this ks the *key* for the data. like:

`app.session.Put(r, “flash”, “Snippet successfully created!”)`And to retreive data from the session we have two choices - using the `*Session.Get()`like:

```go
flash, ok := app.session.Get(r, "flash").(string)
if !ok {
    app.serverError(w, errors.New("..."))
}
```

Or, alternatively, just use the `*Session.GetString()`which takes care of the type conversion for us. like:

`flash := app.session.GetString(r, "flash")`

Note that the package also provides similar helpers for retrieving `bool []byte, float64...`

Also, need to *remove* the message from the session data after retrieving it. Could use the `*Session.Remove()`to do, but a better option is the `*Session.PopString()`method -- retrieve and deletes it from the session data.

`flash:= app.session.PopString(r, "flash")`

### Using the session data in practice

Update the `createSnippet`handler like:
`pp.session.Put(r, "flash", "Snippet successfully created!")`

Next up want our `showSnippet()`to retreive the confirmation message like:

```go
flash := app.session.PopString(r, "flash")
	app.render(w, r, "show.page.html", &templateData{Snippet: s, 
		Flash: flash})
```

And, can update our `base.layout.html`file to display the flash message like:

```html
{{with .Flash}}
<div class="flash">{{.}}</div>
{{end}}
```

Auto-displaying Flash Messages -- A little imporvement we can make is to automate the display of flash messages, so that any message is automatically included the next time *any page is rendered*.

## Security Improvements

In this section, going to make some improvements to our application so that our data is ketp secure during transit and our server is better able to deal with some common types of *denial-of-service* attacks -- 

- how to quickly and easily create a *self-signed* TLS ceritificate
- the fundamental of setting up your app to that all requests and responses are served securely over HTTPs.
- Some sesnsible tweaks to the default TLS settings to help keep our info secure and our server performing quickly
- How to set connection timeouts to migrate and other attacks.

### Generating a self-signed TLS certificate

HTTPs is essentially HTTP sent across a TLS connection. Cuz it’s sent over a TLS connection the data is encrypted and signed, which helps ensures its priavcy and integrity during transit.

Before our server can start using HTTPs, jsut need to generate a TLS certificate first -- jsut recommand using *Let’s Encrypt* to create TLS criteriates, but for development purposes the simplest thing to do is to generate your own *self-signed* certificate.

For this, is the same as a normal TLS certificate -- isn’t cryptographically signed by a trusted authority, this means that your web browser will raise just a warning the first time it’s used.

Handily, the `crypto/tls`package in Go’s stdlib includes a `generate_cert.go`tool that you can use easily create your own self-signed certificate -- like: Creating a new `tls`directory in the root of your project and: To run the `generate_cert.go`need to know the place on your computer where the source code for the Go stdlib is installed. Can run the tool like:

```sh
go run generate_cert.go --rsa-bits=2048 --host=localhost
```

1. First generates a 2048-bit RSA key pair, which is a cryptographically secure public key and private key.
2. It then stores the private key in `key.pem`, and the self-signed TLS certificate for host `localhost`ceartinaing the public key -- stores in the `cert.pem`file.

### Running a HTTP server

Now that have the self-signed TLS and corresponding private key, starting a HTTPs web server is simple, just open the `main.go`file and swap the method like:

```go
err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")
```

HTTP/2 connections -- A big plus using HTTPs is that - if a client supports HTTP/2 connections, Go’s HTTPs server will automatically upgreade the connection to use HTTP/2 -- This just good cuz it means that ultimately, our pages will load faster for users.

It’s important to note that the user that U are using to run your Go must have read permission for both the `cert.pem`and the `key.pem`, otherwise, `ListenAndServeTLS()`return a permission denied error.

### Configuring HTTPs settings

Go has jsut pretty good default settings for its HTTPs server, but there are a couple of improvements and optimizations that U can make -- 

U can think of TLS connection happening in two stages -- the first is the handshake -- in which the client veritifies that the server is trusted and generates some TLS session keys. The second is the actual transmission of the data, in which the data is encrypted and signed using the TLS session keys generated during the handshake.

And to change the default TLS settings, we need to do two things -- 

- Need to create a `tls.Config`struct which contains the non-default TLS settings that want to use.
- Second, need to add this to our `http.Server`struct before start the server.

```go
// Initialize a tls.Config to hold non-defaults TLS settings 
tlsConfig := &tls.Config{
    // PreferServerCipherSuites: true,
    CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
}

srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errLog,
    Handler:  app.routes(),
    TLSConfig: tlsConfig,
}
```

### Connection Timeouts

Take a moment to improve the resillency our server by adding some timeout settings like:

```go
srv := &http.Server{
    // ... other configurations
    // add idle, read, and write timeouts to the server
    IdleTimeout:  time.Minute,
    ReadTimeout:  time.Second * 5,
    WriteTimeout: time.Second * 10,
}
```

- `IdleTimeout`-- by default, go just enables keep-alives on all accepted connections, this helps reduce latency cuz a client can reuse the same connection for multiple requests without having to repeat handshake.
- `ReadTimeout`-- if the request headers or body are still being read 5 secondds, after the request is first accepted, The go will close the underlying connection, need to note that setting a short `ReadTimeout`helps to mitigate the risk from slow-client attacks.
- `WriteTimeout`-- will close the underlying connection if our server attempts to write to the connection after a given period. Different from HTTP and HTTPs.