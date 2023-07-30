# Building Own docker Images

How it’s been designed to work well with Docker – fore:

```sh
docker image pull diamol/ch03-web-ping
docker container run -d --name web-ping diamol/ch03-web-ping
```

`-d`just is a short form of `–detach`– so this will run in the background. The application runs like a batch job with no user interface. Unlike the website container we can detected – this one doesn’t accept incoming traffic. 

For the `--name`-- know that you can work with containers using the `ID`and Docker generates – but can also give them a *friendly* name.

```sh
docker -rm -f web-ping # remove the named container
```

Then run this with some parameter:

```sh
docker container run --env TARGET=baidu.com diamol/ch03-web-ping
```

This container just doing sth different – first it’s runinng interactively cuz you didn’t use the `--detach`flag, so the output from the app is shown on your console.

Docker images may be just packaged with a default set of configuration values for the app , but should be able provide different configuration settings when run it.

Environment are simple to achieve that -- TARGET jsut set with a blog.sixyed.com in the image. Can provide different value with that.

## Writing your own Dockerfile

The `Dockerfile`is a simple script you write to package up an appliction -- it’s set of instruction, and a Docker image is just the output -- Dockerfile syntax just simple -- can package up any kind of ap using a Dockerfile. Like:

```dockerfile
FROM diamol/node

ENV TARGET="baidu.com"
ENV METHOD="HEAD"
ENV INTERVAL="3000"

WORKDIR /web-ping
COPY app.js .

CMD ["node", "/web-ping/app.js"]
```

The Dockerfile instructs are `FROM, ENV, WORKDIR, COPY` and `CMD` -- in capitals -- just a convention.

- `FROM`-- every image **has to start from another image**. In this case, the `web-ping`image will use the `diamol/node`imag as its starting point - That image has `node.js`installed
- `ENV`-- Sets values for environment variables. `[key]="[value]"`.
- `WORKDIR`-- creates a directory *in the container image filesystem*, and sets that to be the current working directory -- the forward-slash works for Linux and Windows containers.
- `COPY`-- Copies files or directories from the local filesytem into the container image. For `.`, just the working directory in the image.
- `CMD`-- specifies the command to run when Docker starts a container from the image. For, this, run `Node.js`, starting the application code in the `app.js`.

Should see that you have 3 files -- 

- Dockerfile
- app.js
- README.md

## Building your won container image

Docker needs to know a few things before it can build an image from a `Dockerfile`-- it needs a name for the image, and the location for all the files that it’s going to package into the image. just like:

```sh
docker image build --tag web-ping .
```

For the `--tag`arg is the **name for the image.** And the final arg is the directory where the `Dockerfile`and related files are. Docker call this directory the *context* -- and the period means just use the current directory. Will just se the output from the `build`command, executing all the instructions in the `Dockerfile`. Then the image will be in your image cache 

```sh
docker image ls 'w*'
```

Can just use this image in exactly the same way as the one you downloaded from Hub. like:

```sh
docker container run -e INTERVAL=5000 web-ping
```

For this, the container is running in the foreground, you you will need to stop it with Ctrl-c.

## Understanding Docker images and image layers

The Docker image just contains all the files you packaged, which become the **container’s filesystem**. And it also contains a lot of metadata about the image itself. That includes a brief history of how the image was built -- you can use that to see each layer of the image and the command that built the layer.

```sh
docker image history web-ping
```

And a Docker image is a logical collection of image layers -- Layers are the files that are physically stored in the `Docker`engine’s cache -- here is why that is important -- image layers can be shared between different images and different containers. If have lots of containers all running `Node.js`apps, the will all share the same set of image layers that contain the `Node.js`runtime.

Fore, the `node`image ahs just a minimal OS layer and the `node.js`runtime installed. And the web-ping image use the `node`image as its base, and it shares the os and runtime layers.

the `diamol/node`image has a slim OS layer -- then the `node.js`runtime -- the Linux image takes up about 75MB. Ur web-ping is based on `diamol/node`, so it starts with all the layers from that image.

```ls
docker image ls
```

For the `SIZE`field -- It looks like all the `node.js`image take up the same amount like 75M -- there are.. not exactly -- the size column you see is just the **Logical** size of the image -- that is just how much space the image would use if you didn’t have any other images on your system. And if you do other... the disk space docker uses is much smaller.

```sh
docker system df
```

If image layers are shared around, they can’t be edited -- otherwise a change in one image wourld cascade to all the other images that share the changed layer. Docker enforces that by making image layer just read-only. Once U create a layer by building an image -- that layer can be shared by other images -- but it can’t be changed.

# Writing a command-line Tool

1. Parse the flags
2. Validates the flags
3. Use the lib
4. shows the result

## Printing a usage message

In go, whenwant to make a command-line tool, just add the main package and `main`func.

### Channels

Allow goroutines to share memory by communicating, as opposed to coummunicating by sharing memroy. When are working with channesl, have to keep in mind that channels are two things combined together -- sync tools, and are conduits for data. Fore:

```go
// Don't do this
if len(ch)>0 {
    x := <-ch
}
```

For this, code checks whether the channel ahs some data in it, and seeing that it does -- reads it - this code just has a RC -- Even though the channel may have data in it when its length is checked, another goroutine may receive it by the time this goroutine just attempts to do so.

A channel, is actually *a pointer to data structure* that contains its internal state, so the zero-value of a channel variable is `nil`. Cuz of that, channles must be initialized using the `make`keyword -- if you forget that, will never be ready to accept a value, or provide a value. And the Go garbage collector will collect channels that are no longer in use -- if there are no goroutines that directly or indirectly reference a channel,  the channel will be garbage collected even its buffer has elements in it. So don’t need to close channels to make them eligible for garbage collection -- closing a channel has more significance than just cleaning up resources.

Note, it is not possible to send data that will be received by many goroutines using one channel. However, **closing a channel is a one-time broadcast** to all receiving groutines. In fact, this is the only way to notify multiple goroutines at once. In fact, this is just the only way to notify multiple goroutines at once.

This is just a very useful feature, especially when developing servers. An instance of `context.Context`is passed to each request handler that contains a `Done()`channel -- fore, the client just closes the connection before the request handler can prepare the response -- the handler can check to see whether the `Done()`channel is closed and just terminate processing permaturely.

Note, receiving from a closed channel is valid -- a *receive from a closed will always succeed with zero value of the channel type*. But, wirting to a closed is a bug, always **panic**.

For a receiver, it’s usually important to know whether the channel was closed when the read happened. So:

`y, ok := <-ch`

This form of channel receive operation will return the received value and whether or not the value was a real receive or whether the channel is closed. If `ok==true`then received.

# Setting up the Session Manager

run through the process of setting up and using the `golangcollege/sessions`package -- but if  you are going to use it in a production application -- The first thing need to do is to establish a session manager in `main.go`and make it just available to our handlers via the `application`struct -- The session manager holds the configuration settings for sessions, and also provides some middleware and helper methods to handle the loaidng and saving of session data.

And, the other thing will need is a *32-byte* long secret key for **encrypting** and **authenticating** the session cookies. Update the app so that it can accept this secret via a new command-ling flag. just like:

`session       *sessions.Session`

```go
// use the session.New() to initialize a new session manager,
// passing in the secret key as parameter
session := sessions.New([]byte(*secret))
session.Lifetime=12*time.Hour

app := &application{errorLog: errorLog, infoLog: infoLog, snippets: &mysql.SnippetModel{db},
                    templateCache: templateCache, session: session}
```

Note: the `sessions.New()`func returns a `Session`struct  which holds the configuration settings for the session. In the code above set the `Lifetime`field of this so that sessions expires.

For the sessions to work also need to wrap our app routes with the middleware provided by the `Session.Enable()`-- this loads and save session data to and from the session cookie with every HTTP requestand response as appropriate.

And, it’s important to note that we don’t need this middleware to act on *all* our app routes -- fore, don’t need it on the `/static/`route -- cuz all this does is serve static files and there is no need for any stateful behavior.

so, cuz of  that, it doesn’t make sense to add the session middleware to our app routes -- specfically, don’t need it on the `/static/`route -- all this does is serve static files -- no need for any stateful behavior. So, it doesn’t make sense to add the session middleware to our existing chain.

Just create a new `dynamicMiddleware`chain containing the middleware appropriate for our dynamic app routes only.

```go
// create a new middleware chain containing the middleware specific to our dynamic app routes.
// will only contain the session middleware for now
dynamicMiddleware := alice.New(app.session.Enable)
mux := pat.New()
mux.Get("/", dynamicMiddleware.ThenFunc(app.home))
mux.Get("/snippet/create", dynamicMiddleware.ThenFunc(app.createSnippetForm))
mux.Post("/snippet/create", dynamicMiddleware.ThenFunc(app.createSnippet))
mux.Get("/snippet/:id", dynamicMiddleware.ThenFunc(app.showSnippet))
```

If are not using Alice, then simply need to wrap handler functions just with the session  middleware instead like:

```go
mux := pat.New()
mux.Get("/", app.Session.Enable(http.HandlerFunc(app.Home))) //...
```

## Working with Session Data

Put the session functionality to work and use it to persist the confirmation flash message between HTTP requests. To add confirmation message to the session data for a user we should use the `*Session.Put()* -- the second to this is the key for the data. like:

`app.session.Put(r, "flash", "snippet successfully created!")`

And to retrieve the data from the session -- could use the `*Session.Get()`and type assert the value to a string:

```go
flash, ok := app.Session.Get(r, "flash").(string)
if !ok {
    app.ServerError(...)
}
```

Or can use the `Session.GetString()`method. like:

`flash := app.session.GetString(r, "flash")`

And the package also provides similar helpers for `bool, []byte, float64, int` and `time.Time`

However, cuz want our confirmation message to be just displayed once -- need to *remove the message* from the session data after retrieving it. `*Sessin.Remove()`to do so -- but a better option is `*Session.PopString()`, which retrieves a string value for a givenkey and then deletes it from session data in one step.

`flash := app.session.popString(r, "flash")`

That is very quick roudown of the basic.. but need to read documenation.

### Using the Session Data in Practice

Just update the `createSnippet()`handler -- so that it adds a confirmation message to the current’s session data like:

```go
// use the Put() method to add a string value and the corresponding key to session data
// note if there is no existing one, a new empty session will be automatically created by middleware
app.session.Put(r, "flash", "Snippet successfully created!")
```

Next up want our `showSnippet`handler to retrieve the confirmation message and pass it to the template for subsequent.

```go
// use the PopString() to retrieve the value for the flash key -- also delete the kay and the value
// from the session data
flash := app.session.PopString(r, "flash")
app.render(w, r, "show.page.html", &templateData{
    Flash: flash,
    Snippet: s,
})
```

And now, can update the template to display the flash message like:

```html
{{with .Flash}}
	<div class="flash">{{.}}</div>
{{end}}
```

Just need to remember that the `{{with .Flash}}`block will only be evaluated if the value of the `.Flash`is not empty string -- so if there is no `flash`key in the current user’s session, the result is that the chunk not displayed.

# Using the Fluent API to override Model Conventions

The Fluent API used to override the data model conventions by describing parts of the data model programmatically. Attributes are suitable for making simple changes – but eventually you will have to deal with a situation for which there is no suitable attribute.

```cs
public class ShoeWidth {
    public long UniqueIdnet {get;set;}
    public string? WidthName {get;set;}
}
//...
public class ManualContext: DbContext {
    //...
    public DbSet<ShoeWidth> ShoeWidths {get;set;}
    
    protected override void OnModelCreating(ModelBuilder builder) {
        builder.Entity<ShoeWidth>().ToTable("Fittings");
        builder.Entity<ShoeWidth>().HasKey(t=> t.UniqueIdent);
        builder.Entity<ShoeWidth>()
            .Property(t=>t.UniqueIdent)
            .HasColumnName("Id");
        buidler.Entity<ShoeWidth>()
            .Property(t=>t.WidthName)
            .HasColumnName("Name");
    }
}
```

Note that the `Endity<T>`method returns an `EntityTypeBuilder<T>`object, which defines a series of methods that are used to describe the data model to EF core:

- `ToTable(table)`– used to sepcify the table for the entity class, `[Table]`attr just
- `HasKey(selector)`-- specify the key prop for an entity class, `[Key]`attr
- `Property(selector)`– select a prop so that it can be described in more detail.

And the `ToTable()`and `Haskey()`are used on their own to specify the dbs table and the PK property for the `ShoeWidth`class. And the `Property`is used to select a prop for **further configuration** and returns a `PropertyBuilder<T>`. For now:

- `HasColumnName(name)`-- used to select the column that will provide values for the selected prop. `[Column]`

## Modeling Relationships

Defining the relationships between classes – adding nav and FK props just. Add the props:

```cs
public class Shoe {
    //...
    public long ColorId {get;set;}
    public Style? Color {get;set;}
}
```

The most important prop is one that maps to the FK column in the dbs table used to store the DEPT entity, which is the `Shoes`class in this example. The convention for the name of the NAV prop is to drop the column name from the FK prop so that the NAV prop for the REL stored in the `ColorId`will be `Color`. For this, the returned type by the `Color`is `Style?`; EF core applies the changes applied to the data model consistently – means that the attributes used to specify the `Sytle`as the respresentation of the data in the `Colors`table continues even when defining REL.

```cs
// in the Style:
[Table("Colors")]
public class Styel {
    //...
    public ICollection<Shoe> Shoes {get; set; }
}
```

### Overriding The relationship conventions using Attributes

One drawback with overriding the data model conventions – once start, need to keep going and work the changes all the way through.

```cs
public class Shoe
{
    public long Id { get; set; }
    public string? Name { get; set; }
    public decimal Price { get; set; }

    [Column("ColorId")]
    public long StyleId { get; set; }

    [ForeignKey("StyleId")]
    public Style? Style { get; set; }
}
```

These two are required to create a REL with properties that are consistent with the rest of the data model. The `Column`tells EF core that the `StyleId`should be mapped to the `ColorId`column. Whereas the `ForeignKey`attr is used to specify the `StyleId`is the FK for Style nav prop.

Note that the prop added to the `Styles`doesn’t require attr cuz it follows regular rel conventions – However, if you can’t use the convention name for this type of prop, then can use the `InverseProperty`attr to tell EF core which clas the prop relates to.

```cs
[InverseProperty(nameof(Shoe.Style))]
public ICollection<Shoe>? Products { get; set; }
```

- `ForeighKey(prop)`– used to identify the FK prop for a nav prop
- `InverseProperty(name)`-- used to specify the name of the prop at the other end of the REL. Note this.

### Overriding the REL Convention using the Fluent API

If prefer using the Fluent API, can use the `Entity<T>`to select an entity class, followed by the `Property`method, which allows to select and configure individual props.

```cs
// in the class Shoe:
public long WidthId { get; set; }
public ShoeWidth? Width { get; set; }
```

To complete the REL, added the inverse nav prop to ShoeWidth just like:

`public ICollection<Shoe> Products {get;set;}`

Then in the `DbContext`:

```cs
modelBuilder.Entity<Shoe>()
    .Property(s => s.WidthId).HasColumnName("FittingId");

modelBuilder.Entity<Shoe>()
    .HasOne(s => s.Width).WithMany(w => w.Products)
    .HasForeignKey(s => s.WidthId).IsRequired(true);
```

Tell EF core that the values for the `Shoe.WidthId`prop should be read from the `FittingId`column, and the second statement uses the methods that the Fluent API provides specifically for describing RELs –

- `HasOne(PROP)` – is used to start describing a REL where the selected entity class has a REL with a single object of another type. The argument selectes the *NAV prop*, either by name or by using Lambda.
- `HasMany(prop)`– used to start describing a REL where the selected entity chass has a REL with many objects of another type.

Start with one of the methods shown the table and describe the **other end** of the REL using one of the methods – which tells EF core whether this is ***one-to-one** or **one-to-many*** rel.

- `WithMany(prop)`-- used to select the inverse NAV prop in a one-to-many
- `WithOne(prop)`– used to select inverse in a one-to-one REL.

And, once you have selected the NAV props  for both ends of the REL, can just configure the REL by *chaining* calls to the methods – like:

- `HasForeignKey(prop)`– this used to select the FK prop for the REL
- `IsRequired(required)`-- used to specify whether the REL is required or optonal.

The combinatoin of models – teslls EF core that the `Shoe`class is the *DEPT* entity, and in a required one-to-many REL with the `ShoeWidth`class and that the `WidthId`prop is the FK prop. Combined with the statement that maps the `WidthId`prop to the FK column in the dbs, EF core has all of the info it needs to understand the REL and how the entity classes are mapped to the dbs tables.

# JWT Token Authentication using the Core web API

Basically, JWT is used for the AuthC and AuthZ of different users.

### Authentication

- Send the username and password to the *authentication server*.
- Authentication server will valiate those credentials and store them on the browser session and cookies and send the ID to the end-user.

### Authorization

Check whatever credential entered during the Authentication process and that the same user will have granted access to the resource using the credentials which we store in the AuthC process, and then AuthorZ then particular.

## Introduction of JWT Token

JSON Web Token is the open standard way that will be used to transmit the data securely over the different environments as a JSON object. JWT is the trusted way of authC cuz it is digitally signed and secrt using **HMAC** algorithm or sometimes using public/private key using **RSA.**

HMAC stands for *Hashed-based* message AuthC code. Also, JWT is a part of great AuthC and AuthZ framework like **OAuth** and **OpenID** which will provide a great mechanism to transfer data securely.

### Structrure of JWT token

Consists of 3 parts which are used to store user info in the Token separated by `.`, for: `Header`**.**`PayLoad`**.**`Signature`.

- Header – stores the info about the JWT token like the type of the otken and whatever algorithm used for creating the JWT 
  ```json
  {
      "alg": "HS256",
      "type": "JWT"
  }
  ```

- Payload - Is the second part of the JWT token which is used to sture info about users like claims, role, subject..
  ```json
  {
      "sub": "123",
      "name": "Ian",
      "admin": "true"
  }
  ```

- Signature – is used to check user info that is present in the Header and Payload and validates things with Secret Key and data is present in `Base64Url`Encoded string.

### Client-Server Scenario with JWT Token

- First the user sends a request to the AuthC Server with credentials like UserName and Password.
- Then the AuthC Server will validate that info and whatever info provided by the user that will be correct and successfully authenticate then Auth server will issue the JWT valid Access token to the user.
- The User Sends the first req to the backend server with a Vlaid JWT access token and the Server will provide the requested resource to the user.
- Sometime – if the token is expired, then the server responds to the end-user.
- Finally, user again needs to be login and send the user credential to the authC server to get a new JWT valid Access Token and stores it somewhere on the client-side in the Local storage, or some URL.

### Client-Server Scenaio with JWT refresh Token

- First, will send request to AuthC…
- Next, the AuthC validates the user info and credentials – provide JWT valid access Token and Refresh Token.
- Later– request and respone 
- Then the backend server checks the roles and permissions of the user..

# Submitting data to the Server

Have a form that allows us to capture data from the user, and we have valiation in place to stop invalid data getting into the system – the last thing need to do is to persist that data to our new API – to do this, need employ a couple  of libraries – 

*MediatR* – is an in-process messaging library that implements the mediator pattern – Essentally, requests are constructed and pased to the mediator, which then passes them to a handler, *request* uses **DI** to connect mediator, which then passes them to a handler.  The main advantage of using `MediatR`is the ability to have loose coupling between components and server interactions.

*ApiEndpoints* – Solve the controllers problem – Allowing to define an endpoint as a class *with a single method* to handle the incoming request – this allows us to avoid all the issues that surround controllers and build clear and easy-to-maintain endpoints in APIs.

- A request is created by calling code
- The request is dispatched to MediatR, where the appropriate handler is found to deal with the request.
- The handler makes the call to the API and awaits the response.

For Server:

- The API endpoint receives the request and processes it, then returns the response.
- Depending on the request, data is either read from or written to the dbs.

Finally

- the response is returned to the calling code.

Taking our form as the example – create a request to post the data to the API and pass this request to MediatR. Which will route our request to a handler, will process the request and make the API call. On the server, an API endpoint will receive the request and proces it.

### Adding MediatR to the Blazor Project

To add to blazor, need add two Nuget to the project – BlazingTrail.Client, fore:

```sh
Install-package MediatR
Install-package MediatR.Extensions.Microsoft.DependencyInjection
```

After, need to add to the service collection – add a line into the Program.cs :

```cs
using MediatR;
// ...
builder.Services.AddMediatR(typeof(Program).Assembly);
```

This line adds *MediatR* to the service collection, can inject it into our components and services. It also tells MediatR to **scan** the current assembly for request handlers. The final piece of the configuration just in the `_Import.razor`

`@using MediatR`

### Creating a request and handler to post the form data to the API

going to start by creating a request that will contain the data collected by our form. Once this is done, can create a handler for the requset – this will be responsble for posting the data up to the API. All of our requests are going to live in the `Shared`proj – this will allow to use them in both API and Client projects. Also need add package `MediatR`.

Now need to create a `record`– 

```cs
public record AddTrailRequest(TrailDto Trail):
    IRequest<AddTrailRequest.Response> // interface represent request
{
    public const string RouteTemplate = "/api/trails";
    public record Response(int TrailId);
}

public class AddTrailRequestValidator:
    AbstractValidator<AddTrailRequest>
{
    public AddTrailRequestValidator()
    {
        RuleFor(x => x.Trail)
            .SetValidator(new TrailValidator());  // #5
    }
}
```

1. Just is defined as C# `record`as opposed to a class – `record`s are considered perfearable for data transfer due to their *immutable* and *value type* qualities. This `record`implements the `IRequest<T>`defined in `MediatR`– is used by MediatR when locating a handler. `T`defines the resppnse type of the request.
2. `RouteTemplate`just defines the address of the API endpoint for the request.
3. nested C# record defines the response data for the request jsut.
4. And a validator for the request – will be executed by the API to make sure the request is valid.
5. Specifies the `TrailValidator`as the validator for the `Trail`prop. Reuse the validation rules.

For C# 9, `record`s are considered the preferable option for DTOs, and the reason for this is that records can be immutable, meaning once the props have been set, they can’t be changed. If need to be changed, just a new copy is made with the updated values. `with{...}`

And ahother advantage of using records is that the use *value-based* equality – Two are considered equal when all the values of their props match.

But – the biggest benefit is how succinct they are – just for:

```cs
public record AddTrailRequest(TrailDto Trail)
```

This code is just a syntactic sugar for the following definition – like:

```cs
public record AddTrailRequest {
    public TrailDto Trail {get; init;}
}
```

Also, defines a route template as a constant – this will be used later when create the API endpoint – the benefit is that if we want to change the endpoint’s address further down the road, can do it in a single place.

Finally, have a validator for the request – this is going to be executed by the server when receiving the requeset to make sure its contents are valid – don’t want to duplicate all the .. so using the `TrailDto`type in the request, can assign the validator already created. `RuleFor(...).SetValidator(new...)`used.
