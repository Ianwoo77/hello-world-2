# Git Branch -- recovery

In Git, a `branch`is just new/separate version of the main repository. With Git:

- With a new branch called `new-design`, edit the code directly without impacting the main branch
- Fore, *EMERGENCY* -- there is an unrelated error somewhere else in the proj that neds to be fixed ASAP
- Create a new branch *from the main proj* called small-error-fix
- Fix the unrelated error and merge the small-error-fix branch with the main branch
- Got back to the new-design, and finish the work here.
- Merge the new-design branch with the main.

### New Git Branch

Add some new feature to the index.html page, need to note every stage here -- first, are working in the local repository, and do not to disturb or possibly wrreck the main proj. first create a new `branch`like:

```sh
git branch hello-world-images
git branch # now under master

# then checkout is a command used to check our branch like
git checkout hello-world-images
git status
git add --all
git commit -m "Added image to Hello World"
```

Switching between branches

```sh
git checkout master
```

The added files are no longer under the directory, and if open the html, can see the code reverted to what it was befreo the alteration.

Emergency Branch -- Now imagine that we are not yet done with images -- but need to fix an error on master. Don’t want to mess with master directly, and dont’ want to mess with hello-world-images branch either, since it is not done yet. Create a new branch to deal with the emergency like:

```sh
git checkout -b emergency-fix
git status
git add index.html
```

### Merge Branches

Have the emergency fix ready, so just merge the master and emergency-fix branches:

```sh
git checkout master
git merge emergency-fix
git branch -d emergency-fix # delete this branch
```

Now can move over to the hello-world-images keep working adding another mages file.

```sh
git checkout hello-world-images
git add --all
git commit -m "added new image"

# then checkout back master
git checkout master
git status
```

This confirms there is a conflict in index.html, but the image files are ready and staged to be committed. just edit that.

## packaging apps from source code

Building Docker images is easy, learned that just like:

```dockerfile
FROM diamol/node

CMD ["node", "/web-ping/app.js"]

ENV TARGET="blog.sixeyed.com" \
	METHOD="HEAD" \
	INTERVAL="3000"
	
WORKDIR /web-ping
COPY app.js .
```

```sh
cd ../web-ping-optmizied
docer image build -t web-ping:v3 .
```

Won’t notice too much difference from the previous build. There are now jsut 5 steps instead of 7, but the end result is the same. Can run a container from this image, and it behaves just like the other versions.

### Who need build server

If work in a tea, -- there is a shared source control system like GitHub fore, every pushes their code changes. And there is typically a spearate server that builds the software when changes get pushed. If fore, s developer forgets to add a file when push code, the build will fail on the build server. It would be much cleaner to package the build toolset once and share it. which is exactly what you can do with Docker. Like:

```dockerfile
FROM diamol/base AS build-stage
RUN echo 'Building...' > /build.txt

FROM diamol/base as test-stage
COPY --from=build-stage /build.txt /build.txt
RUN echo 'Testing...' >> /build.txt

FROM diamol/base
COPY --from=test-stage /build.txt /build.txt
CMD cat /build.txt
```

This is just called a multi-stage Dockerfile, cuz there are several stages to the build. Each stage starts with a `FROM`instruction, and you can opitonally give sitages a name with the `AS`parameter. Just 3 stages here, `build-stage`, `test-stage`and the final unnamed stage.

Each stage just runs independently, Can copy files and directories from previous stages. Using the `COPY`instruction with the `--from`arg -- tells Docker to copy files from an earlier stage in the `Dockerfile`. and the `RUN`instruction executes a command inside a container during the build, and any output from that command inside a container during the build. Can execute anything in a `RUN`instruction, but the commands you want to run need to just exist in the Docker image that you are using the `FROM`instruction.

NOTE that the individual stages re *isolated* -- can use different base images with different sets of tools installed and run whatever commands you like.

```sh
docker image build -t multi-stage .
```

In the build stage, just use a base image that has your app’s build tools installed. Copy the source code from your host machine and run `build`command.

### Node.js source code

For Java app, must be compiled, so the source code gets copied into the build stage, and that generates a JAR. For node.js, just -- there is no compilation step, Dockerized Node.js apps just need the Node.js runtime and the source code in the application image.

And there is a need for a multi-stage Dockerfile -- it optmizes denepdency loading.. Node.js uses a tool called npm to mange dependencies.

```dockerfile
FROM diamol/node as builder

WORKDIR /src
COPY src/package.json .

RUN npm install

# app
FROM diamol/node

EXPOSE 80
CMD ["node", "server.js"]

WORKDIR /app
COPY --from=builder /src/node_modules/ /app/node_modules
COPY src/ .
```

To package and run the app with only Docker installed, without having to install any other tools. The base image for both stage is `diamol/node`which has the Node.js runtime and npm installed. And in the builder stage, caopies in the `packae.json`files, which describe all the application’s dependencies. Then it runs `nmp install`to download the dependencies. This app is another REST API. Then run:

```sh
docker image built -t access-log .
```

Then just changed to :

```dockerfile
FROM diamol/node as builder

WORKDIR /src
COPY src/package.json .

COPY src/node_modules/*.* .
# app
FROM diamol/node

EXPOSE 80
CMD ["node", "server.js"]

WORKDIR /app
COPY --from=builder /src/node_modules/ /app/node_modules/
COPY src/ .
```

## Knowing which type should use

Choose a recevier type for a method isn’t always straightforward. When should use value recevier and when to use pointer -- look at the conditions to make the right decision. will thoroughly discuss values versus pointers. So this section will only scratch the surface in terms of peformance. Also, in many contexts, using a value or pointer recevier should be dictated not by performance but rather by other conditions that we will discuss.

And in go, can attach either a value or a pointer receiver to a method. With a value receiver, Go makes a copy of the value and passes it to the method. Any changes to the object remain local to the method. The original object remains unchanged. 

On the other hand, with a pointer receiver, Go passes the address of an obj to the method. Intrinsically, it remains a copy, but we only copy a pointer, not object itself, any modifications to the receiver are done on the original object.

A receiver *must* be a pointer -- 

- If the method needs to mutate the receiver, this rule **NOTE** is also valid if the recevier is a slice and a method needs to append elements like:

  ```go
  type slice []int
  func (s *slice) add(element int) {
      *s = append(*s, element)
  }
  ```

- If the method receiver contains a field that connot be copied, fore, a type part of tye `sync`.

A receiver *should* be a pointer -- 

- If the receiver is a larg object, using a pointer can make the call more efficient just. As doing so prevents making an extensive copy, when in doubt about how large is large, benchmarking can be solution.

A receiver *MUST* be a value -- 

- If we have to enforce a receiver’s immutability
- If the receiver is a `map, function, channel`

A receiver *should* be a value

- If receiver is a slice that doesn’t have to be mutated
- If the receiver is a small array or structure is naturally a value type without mutable fields.
- If the receiver is a basic type such as `int float64 string`

One case needs more discussion -- say design a different `customer`struct , its mutable fields are not part of the struct directly but are inside another struct like:

```go
type customer struct {
    data *data
}
type data struct {
    balance float64
}
func (c customer) add(operation float64) {
    c.data.balance+=operation
}
func main(){
    c := customer{data: &data {balanc:100}}
    c.add(50.)
    fmt.Printlnc(c.data.balance) // 150
}
```

In this case, don’t need the receiver to be a pointer to mutate `balance`-- for clarity, may favor using a pointer receiver to highlight that `customer`as a whole object is mutable.

### result parameters named

Having the result parameters already initialized can be quite handy in some contexts, even though they don’t necessarily help readability -- the following example proposed like:

```go
func readFull(r io.Reader, buf []byte) (n int, err error) {
    for len(buf)>0 && err == nil {
        var nr int
        nr, err = r.Read(buf)
        n+=nr
        buf= buf[nr:]
    }
    return
}
```

In this, doesn’t really increase readability, however, cuz both `n`and `err`are just initilaized to their zero value, the implementation is shorter.