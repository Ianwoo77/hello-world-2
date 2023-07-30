# Source code into Docker Image

There is one other thing need to know to package your own applications -- can also run commands inside Dockerfiles. Commands execute during the build, and any filesystem changs from the command are saved in the image layer.

## Who needs a build server when have a Dockerfile

Can write a Dockerfile that scripts the deployment of all your tools, and build that into an image. Start with a very simple example -- basic workflow like:

```dockerfile
FROM diamol/base as build-stage
RUN echo 'Building...' > /build.txt

FROM diamol/base as test-stage
COPY --from=build-stage /build.txt /build.txt
RUN echo 'Testing...' >> /build.txt

FROM diamol/base
COPY --from=test-stage /build.txt /build.txt
CMD cat /build.txt
```

This is called a *multi-stage* Dockerfile -- cuz there are several  stages to the build. Each stage starts with a `FROM` instruction -- and you can just optionally give stages a name with the `AS`parameter.

Each stage runs independently -- can copy files and directories from previous stage -- using the `COPY`instruciton with the `--from`argument which tells Docker to copy files from an eariler stage in the Dockerfile, rather than from the filesystem of the host computer.

And a new instruction here - `RUN`using to write files. Executes a command inside a container during the build, and any *output from that command is saved in the image layer*. Can execute anything -- but the commands you want to run need to **Exist** in the Docker image that you are using in the `FROM`instruction. Just used the `diamol/base`as the base, note that it just contains the `echo`commmand.

It’s just important to understand that the individual stage are **isoloated**. Can use different base images with different sets of tools installed and run whatever commands you like. And run:

```sh
docker image build -t multi-stage .
```

- stage 1 : downloads dependencies and builds the app
- stage 2: copies the built app folder and runs the tests
- final stage -- copies the tested app

## Node.js source code

Going to another -- multi-stage Dockerfile -- this time for a node.js app -- organiation are increasingly using diverse technology stacks -- so it’s good to have an understanding -- but Node js uses Js, interpreted lang -- like:

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
COPY --from=builder /src/node_modules/ /app/node_modules/
COPY src/ .
```

The base image for both stages is `diamol/node`, which has the Node.js runtime and npm installed. The build stage in the Dockerfile copies in the package.json files -- just describe all the app’s dependencies. Then just run npm install to download the dependencies.

```sh
docker image build -t access-log .
```

Will see a whole lot of output from npm.. The Node.js app you’ve just built is not at all -- but you should still run it to check that it’s packaged correctly. like:

Note, Containers access each other acorss a virtual network -- using the virtual IP address that Docker allocates when it creates the container, can also create and manage virtual Docker networkds through the command line like:

```sh
docker network create nat
# then run :
docker container run --name accesslog -d  -p 8000:80 --network nat access-log
```

# Go outline

Feature-wise, Go has just no type inheritance, no exceptions, no macros, no partial functions, no support for lazy variable evaluation or immutablity.

## Unintended variable shadowing

The *scope* of a variable refers to the places a variable can be referenced -- in other words, the part of an app where a name binding is valid. In go, a variable name declared in a block can be *redeclared* in an inner block. This called -- *variable shadowing* -- is prone to common mistakes -- like: The shows an unintended side effect cuz of a shadowed variable -- create an HTTP client in two different ways, just depending on the value of a `tracing` boolean:

```go
var client *http.Clinet
if tracing {
    client, err := createClientWithTracing()
    if err != nil {
        return err
    }
    log.Println(client)
}else {
    client, err := createDefaultClient()
    if err != nil {
        return err
    }
    log.Println(client)
}
```

In this, first declared a `client`, then use := in both inner block to just assign the result of the function call to the *inner* `client`var - not the outer one -- as the result, the outer value is always `nil`. This code will compile cuz the inner `client`are used in calls.

And, how can ensure that a variable is assigned to the original `client`-- there are two different options - 

```go
var client *http.Client
if tracing {
    c, err := createClientWithTracing()
    if err != nil {
        return err
    }
    client = c
}
// same logic ...
```

just assign the result to a temporary variable `c`--.. And the second is to use = in the inner to directly assign the func.

```go
var err error
if tracing {
    client, err = create...()
}
```

Note that both are perfectly valid -- main difference is we perform only one assignment in the second. can organize:

```go
if tracing {
    client, err = create...()
}else {
    client, err= createDefault...()
}
if err != nil {
    // handle error
}
```

## Unnessary nested code

Code is qualified as readable based on multiple criteria such as naming, consistency, formatting ... A critical aspect of readability is the number of nested leels, -- like:

```go
func join(s1, s2 string, max int) (string, error) {
	if s1 == "" {
		return "", errors.New("s1 is empty!")
	}else {
		if s2=="" {
			return "", errors.New("s2 is empty")
		}else {
			concat, err := ....
		}
	}
}
```

This func concatenates two strings and just returns a substring. From the implemenation.. correct, however, building a mental model -- cuz of the number of nested levels. So:

```go
func join(s1, s2 string, max int) (string, error) {
    if s1=="" {
        return ...
    }
    if s2=="" {
        return ...
    }
    if len(concat)>max{
        return ...
    }
    return concat, nil
}
```

In general, the more nested levels a function requires, the more complex it is to read and understand.

## Misusing init functions

Sometimes we misuse `init`in Go -- the potential consequences are poor error management or a code flow that is harder to understand.

### concepts

An `init`just used to **initialize the state** of an application. It takes no args and returns no result. And, when a package is initialized, all the *constant and variable decalaration in the package* are evaluated. NOTE: Then the `init`executed

```go
var a = func() int {
   ... // executed first 
}()

func init() {
    ... // executed second
}
```

And an `init`is executed when a package is initialized like:

```go
// in the main.go
func init() {/*... */}
func main() {
    err := redis.Store("foo", "bar")
}
// in the redis.go
func init() {}
func Store(key, value string) error {...}
```

For this, cuz `main`depends on `redis`, the `redis`'s `init`is executed first, Followed the `init`of `main`. And then the `main`itself. So, can define multiple `init()`per package - when do -- the execution order of multiple `init`s inide the package is based on the source file’s **alphabetical order**. FORE, a.go and b.go file -- both have `init`, and a.go `init`executed first.

Shouldn’t rely on the orderying of `init`witihin a package -- it can be dangerous as source files can be renamed, potentially impacting the execution order.

Can aslo define mutliple `init`within the same source file. Can also use init for side effects. FORE, define main that doesn’t have strong dependency on `foo`-- however, fore, the exaple requries `foo`'s package to be initialized, so this by using the `_`operator:

```go
import (
    //...
    _ "foo"  // imports foo just for side effects
)
```

For this, the `foo`package is initiazlied before `main`. And another of an `init`is that it can’t be invoked directly. fore:

`func main() {init()} // error`

### When to use `init`func

Fore, holding a dbs connection pool -- in the `init`in the example, open dbs using `sql.Open`like:

```go
var db *sql.DB
func init(){
    dataName=...
    d, err := sql.Open("mysql", dataSourceName)
    if err != nil {
        log.Panic(err)
    }
    err = d.Ping()
    if err!= nil {
        log.Panic(err)
    }
    db = d // assigns the Db Conn to the global db variable.
}
```

In this example, open the dbs, check whether we can ping it -- and then assign it to the global variable.

1. *error management in an `init`is limited* -- as an `init`doesn’t return an error -- one of the only way to signal an error is to panic.
2. If add tests to the file, the `init`will be executed *before runing the test cases*.
3. This example requires assigning the dbs connection pool to a global variable. Global vars have drawbacks like:
   - Any functions can alter that
   - Unit tests can be more complicated

For these reasons, the previous should probably be handled as part of a plain old function. Just like:

```go
func createClinet(dsn string) (*sql.DB, error) {
    db, err := sql.Open(...)
    if err != nil {
        return nil, err
    }
    if err = db.Pint(); err!=nil {
        return nil, err
    }
    return db, err
}
```

And using this, tackled the main downside  -- 

- The responsibility of error handling is left up to the caller.
- It’s posible to create an integrate test to check that this function works.
- The connection pool is encapsulated within the func.

But, there are still use cases where `init`can be helpful. Like some static HTTP configurations fore:

```go
func init() {
    redirect := func(w http.ResponseWriter, r *http.Request) {
        http.Redirect(w, r "/", http.StatusFound)
    }
    //...
    //... some http.HandleFunc()
}
```

Cuz in this example, the `init`function cannot fail -- for `http.HandleFunc`-- can panic, but only if the handler is `nil`-- Meanwhile, there is no need to create any global variables.

# Configuring HTTPs Settings

To change the default TLS settings we just need to do two things -- 

- need to create a `tls.config`struct which contains the non-default TLS settings that want to use.
- need to add this to `http.Server`struct before start the server.

```go
// in the main.go
// initialize a tls.Config struct to hold the non-defaults TLS settings we want
tlsConfig := &tls.Config{
    // PreferServerCipherSuites: true,  // for now ignored
    CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
}

srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  app.routes(), // calling the new method,
    TLSConfig: tlsConfig,
}
```

The `tls.Config.CurvePreferences`field specifh which elliptic curves should be given during TLS handshake.

## Connection Timeouts

Take a moment to improve the resiliency of by adding timeouts -- 

```go
srv := &http.Server{
   //...
    // add Idle, read and write timeouts to the server
    IdleTimeout:  time.Minute,
    ReadTimeout:  time.Second * 5,
    WriteTimeout: 10 * time.Second,
}
```

All three of these -- `IdleTimeout ReadTimeout WriteTimeout` -- are server-wide settings which act on the underlying connection and apply to all requests.

### IdleTimeout

Go enables `keep-alives`on all accepted connections by default -- This just helps reduce latency (especially for HTTPs) cuz a client can just reuse the same connection for multiple requests without having to repeat the handshake. Also by default, go will automatically close keep-alive after 3 minutes of inactivity -- helps to clear-up connections where the user has unexpectedly disappeared.

### ReadTimeout

Means that if the request headers or body are still being read 5s after the request is first accepted, then go will close the underlying connection. Setting a short `ReadTimeout`helps to mitigate the risk from *slow-client attacks* -- such as **Slowloris**.

### WriteTimeout

The `WriteTimeout`setting will close the underlying connection if our server attempts to write to the conenction after a given period -- 

- For HTTP conn, if some data is written to the connection more than 10 seconds, go will close
- For HTTPs, if some... more than 10s after the requests is *first accepted* -- Go will close. This means that if you are using HTTPs -- it’s **sensible** to set `WriteTimeout`

### MaxHeaderBytes

The `http.Server`also provides a `MaxHeaderBytes`which can use to control the maximum number of *bytes* the server will read when parsing request headers. By default is **1MB**. can limit fore:

```go
srv := &http.Server{
    //...
    MaxHeaderBytes: 524288,
}
```

And if this field is exceeded then the user will automatically be sent a **431** error. But for go programming, there is also *4096 bytes* of headroom.

# User Authentication

For app, only registered, logged-ins can create new, non-logged-in will still be able to view the snippets.

1. register by visiting at `/user/signup`and entering their name.. just store this info in a new `users`dbs table
2. A user will log in by visiting at `/usr/login`
3. check the dbs to see if the email and password they entered match one of the users in the `users`dbs. If has authenticated, add the relevant id for the user to their session data -- using the key `authenticatedUserID`
4. When receive any subsequent requests, can check the user’s session data for a `authenticatedUserID`value, if exists, known it logged in.

NOTE:

- A secure approach to encrypting and *storing user password securely* in dbs using `Bcrypt`
- A solid and straightforward approach to **verifying that a user is logged in** is using middleware and sessions.
- how to prevent **CSRF**

## Routes Setup

- `GET /user/login`-- loginUserForm
- `POST /user/login`-- loginUser
- `POST /user/logout` -- logoutUser
- `GET /user/signup`-- signupUserForm
- `POST /user/signup` -- signupUser

First, defining some handlers, and then create the routes in the `routes.go`file like:

```go
// add the five new routes:
mux.Get("/user/signup", dynamicMiddleware.ThenFunc(app.signupUserForm))
mux.Post("/user/signup", dynamicMiddleware.ThenFunc(app.signupUser))
mux.Get("/user/login", dynamicMiddleware.ThenFunc(app.loginUserForm))
mux.Post("/user/login", dynamicMiddleware.ThenFunc(app.loginUser))
mux.Post("/user/logout", dynamicMiddleware.ThenFunc(app.logoutUser))
```

Also, need to update the `base.layout.html`file to add nav items like:

```html
<nav>
    <!-- update the nav to include signup, login and logout -->
    <div>
        <a href="/">Home</a>
        <a href="/snippet/create">Create snippet</a>
    </div>
    <div>
        <a href="/user/signup">Signup</a>
        <a href="user/login">Login</a>
        <form action="/user/logout" method="post">
            <button>Logout</button>
        </form>
    </div>
</nav>

```

# Working with Keys

```cs
builder.Services.AddScoped<ICacheService, CacheService>();
builder.Services.AddDbContext<DbContextClass>(opts =>
opts.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

Then perform Migration and Dbs update for DB creation using the following commands in the package manager:

Finally, run the app and add the data using swagger UI and then check how caching works inside the products and product endpoint.

Basically, added cache into the product and products endpoints in the controller,  Then use remove method to remove data of product key which is present inside the cache. So, there are many scenarios and use of memeory caches you can use as you need and requirements.

## JWT Token Authentication using the .NET core 6

Basically, JWT is used for the AuthC and AuthZ of different users.

### AuthC

- send the username and password to the authentication server
- Authentication server will validate those credentials and store them somewhere on the browser sesssion and cookies and sent the ID to the end-user.

### AuthZ

- just check whatever credential entered by the user during the AuthC process, and that same user will have granted access to the resource using credentials which we store in the Authentication process and then authorize that particular user.

When should use JWT – 

- AuthZ – most common use scenario for using JWT – once the user is logged in, each *subsequent request* will include the JWT, allowing the user to access routes, services, and resources that are permitted with that token. Single Sign on is a feature that widely uses JWT nowadays, cuz of its small overhead and its ablitity to be easily used across different domains.
- Info Exchange – JWT are a good way of securely transmitting info between parties. Cuz it can be **signed**, using public/private pairs – can be sure that the senders are who they say they are. Additionally, as the signature is calculated using the header and the payload, can also verify the content hasn’t been tampered with.

## What is the JWT structure

- Header
- Payload
- Signature

### Header

*typically* consists of two parts – type of the token, which is JWT, and the signing algorithm being used, fore, HMAC SHA256, or RSA like:

```json
{
    "alg": "HS256",
    "type": "JWT"
}
```

Then, this JSON is `Base64URL`encoded to form the first part of the JWT.

### Payload

The second part of the token is the payload, which  contains the claims – Claims are statements about an entity and additional data. There are three types of claims - *registered*, *public* and *private* claims.

- Registered claims – a set of predefiend claims which are not mandatory but recommaned. Some of them are iss, exp, sub, aud..
- Public claims - can de defined at will by those using JWTs.
- Private claims - custom claims created to share info between parties. fore:

```json
{
    "sub":"123",
    "name": "Bender",
    "admin":true
}
```

Also, the payload is then `Base64Url`encoded form the second part of the JWT.

### Signature

To create the signature part have to take the encoded header, the encoded payload, the *algorithm specified in the header and sign that*. Fore, if want to use the HMAC SHA256 algorithm, the signature will be created as:

```sh
HMACSHA257(base64UrlEncoded(header) + "." +
	base64UrlEncoded(payload), secret)
```

### Puting all together

The ouptut is three `Base64-URL`strings separeated by dots can be easily passed in HTML and HTTP environments while being more compact when compared to XML-based std such as SAML.

## How do JWT Work

In AuthC, when the user successfully logs in using their credentials, a JWT will be returned. since tokes are credentials, greate care must be taken to prevent security issues, in generally, should not keep token longer then required. 

Whenever the user wants to access a protected route or resource – the user agent should send the JWT. Typically in the AuthZ header using the `Bearer`schema. The content of the header look like:

`Authorization: Bearer <token>`

The server’s protected routes will check for a valid JWT in the `Authorization`header – and if it’s present, the user will be allowed to access protected resources – If the JWT contains the necessary data, the need to query the dbs for certain operations may be reduced.

Note that if send JWT through HTTP headers, should try to prevent them from getting too big. FORE:

1. App or client requests authorization to the authentication server – this is performed through one of the different authroziation flows – FORE, a typical OpenID connect will go through the `/oath/authorize`endpoint
2. When the authorization is granted, server returns an access token to the app
3. The app just uses the access token to access a protected resource, FORE, API

### Client-server scenario with JWT

- 1, the user sends a req to the AuthC server with fore, username…
- 2, validte that info and .. then Auth server will be correct and successfully auth.. then issue JWT to the user.
- 3, Users sends the req to bckend with a valid token, and server will provide resonse.
- //…some variation?

# Defining NoSQL

stand for *not only SQL* – regardless of any disagreement over.. NoSQL is just a robust set of technologies. And the following .. 

- Key/value – data uses keys.
- Column – data is arranged by column rather then row
- Document – uses a key as the basis for item retrieval. FORE, MongoDB
- Graph – use graph theory to store data relations in a sereis of vertices with edges.

### Deciding when to use NoSQL

NoSQL excels when fast access to large amount of data is needed. Also, enable developers to work with a flexible data model, as is frequently the case with modern apps. Sharding is a means to partition or split data into just smaller pieces othat are distributed to different computing resources.

### Seeing where Redis Fits

Is a NoSQL, also much more – is a multi-model dbs, enabling search, messaging, streaming, graph, and other.

### Caching

Providing fast response time is more imporatnt then ever – Redis can be used as a means to cache data between apps and back-end data store.

## First Identity Application

```cs
public class TodoItem
{
    public int Id { get; set; }
    public string Task { get; set; } = default!;
    public bool Complete { get; set; }
    public string Owner { get; set; } = default!;
}
```

Usually should keep the Identity data in a separate dbs, going to focus on simplicify and use the same dbs for all the data in the project. like: Then just creating and applying the dbs migrations – 

### Configuring Core Identity

A configuration change is just required to prepare core Identity like:

```cs
builder.Services.AddDefaultIdentity<IdentityUser>(options => options.SignIn.RequireConfirmedAccount = false)
    .AddEntityFrameworkStores<ApplicationDbContext>();
```

So, Identity is added to the app just using the `AddDefaultIdentity()`extension method – and the default configuration created by the proj sets the configuration so the user accounts cannot be used until they are confirmed.

## Setting up the dbs Context

With our entities set up and configured, can turn to the dbs context – just named `BlazingTrailsContext`– is a combination of the Repository pattern and the Unit of the Work pattern. Essentially define collections of our entities using properties with a type of `DbSet<T>`– can then just inject it into our app.

```cs
public class BlazingTrailsContext: DbContext
{
    public DbSet<Trail> Trails => Set<Trail>();
    public DbSet<RouteInstruction> RouteInstructions => Set<RouteInstruction>();

    public BlazingTrailsContext(DbContextOptions<BlazingTrailsContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfiguration(new TrailConfig());
        modelBuilder.ApplyConfiguration(new RouteInstructionConfig());
    }
}
```

1. DbContext class provides all the base functionality for the context – all dbs contexts must inherits from this.
2. Each entity is represented as a collection with the `DbSet<T>`
3. By overriding the `OnModelCreating()`, can hookup entity configuration classes.

### Connection strings and Service Configuration

The last step of configuration is to add a connection string to the appsettings.json and add the required services to the service container – just like:

```cs
builder.Services.AddDbContext<BlazingTrailsContext>(opts =>
opts.UseSqlServer(builder.Configuration.GetConnectionString("BlazingTrailsContext")));
```

### Creating the first migration and creating the dbs

With the configuraiton done, can now create the initial migration - A migration contains two methods just called `Up`and `Down`, `Up`contains the desired state of the dbs on new changes, and the `Down`contains the instruction on how to reverse the `Up`in case need to revert the migration.

## Setting up the Endpoint

So, the dbs is ok – then in the Server project, need to set up `ApiEndpoint`fore:

```sh
Install-Package Ardalis.ApiEndpoints
```

Will continue with our feaure folder’s theme in the server, so next create a folder called.. just `AddTrailEndpoint.cs`with the code like:

```cs
public class AddTrailEndpoint : EndpointBaseAsync
    .WithRequest<AddTrailRequest>
    .WithResult<int>
{
    private readonly BlazingTrailsContext _database;
    public AddTrailEndpoint(BlazingTrailsContext database)
    {
        _database = database;
    }

    // the route for the endpoint is defined using template on the Request
    // and this method must be overrdden.
    [HttpPost(AddTrailRequest.RouteTemplate)]
    public override async Task<int> HandleAsync(AddTrailRequest request, 
        CancellationToken cancellationToken = default)
    {
        var trail = new Trail
        {
            Name = request.Trail.Name,
            Description = request.Trail.Description,
            Location = request.Trail.Location,
            TimeInMinute = request.Trail.TimeInMinutes,
            Length = request.Trail.Length,
        };

        await _database.Trails.AddAsync(trail, cancellationToken);

        var routeInstructions = request.Trail.Route
            .Select(x => new RouteInstruction
            {
                Stage = x.Stage,
                Description = x.Description,
                Trail = trail,
            });
        await _database.RouteInstructions.AddRangeAsync(routeInstructions, cancellationToken);

        // trail id is sent back as the response.
        return trail.id;
    }
}
```

As going to be writing to the dbs, need to inject an instance of the `BlazingTrailsContext`which is done in the ctor. The `HandleAsync()`jsut where all the work is done. The method takes the request type we specified when inheriting the `BaseAsyncEndpoint`and returns the response type. Inside the method, just create instances of the dbs entities `Trail`and `RouteInstruction`using the incoming request.

```cs
// builder.Services.AddMediatR(typeof(Program).Assembly);
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(Assembly.GetExecutingAssembly()));
```

# Using the Forms API Part II

In this, continue to describe the Ng forms API, explaining how to create form controls dynamically and how to create custom validation – 

- Use a `FormArray`object
- Use a control’s position in tis enclosing `FormArray`as identification during the validation process.
- Override the methods defined by the `FormArray`
- Create a func that returns an implementation of the `ValidationFn`interface, performs validation on a control’s value.
- Create a directive that calls the validator Func
- Perform validation on a `FormGroup`or `FormArray`
- Create an async validator.

## Creating Form Components Dynamically

The `FormGroup`is useful when the structure and number of elements in the form are known in advance. For app that need to dynamically add and remove elements, Ng provides the `FormArray`– note  that this also derived from the `AbstractControl`and provide the same feature for managing `FormGroup`objects. The main difference is that the `FormArray`allows `FormControl`objects to be created without specifying names and stores its controls as an array.

```ts
export class Details {
    constructor(public supplier?: string,
                public keywords?: string[]) {
    }
}
```

Then, updating the data – like:

```ts
new Product(1, "Kayak", "Watersports", 275,
    {supplier: "Acme", keywords:["boat, small"]}),
```

### Using a Form Array

Using the `FormArray`stores its child controls in an array and provides the props and methods – like:

- `controls`– returns an array returns children
- `length`-- return the number of `FormArray`
- `at(index)`– returns the control at the specified index
- `push(control)`– adds a control to the end of the array
- `insert(index, control)`– inserts a control
- `setControl(index, control)`– replace
- `removeAt(index)`– removes at the specified index
- `clear()`– removes all

And the `FormArray`also provides methods for setting values of the controls using arrays, rather then name-value maps like:

- `setValue(values)`– accept an array of values and uses them to set the values of the child controls based on the order, note that the number of elements in the values must match the number of controls.
- `patchValue(values)`– not have to match the number of controls in the `FormArray`.
- `reset(values)`– resets the control and sets values using the *optional* array arg.

```ts
this.product.details?.keywords?.forEach(val=> {
    this.keywordGroup.push(this.createKeywordFormControl());
})
```

For this, defined a `FormArray`prop so that can access it in the template, which is important cuz there are no built-in directives that export the `FormArray`.

```ts
keywordGroup = new FormArray([
        this.createKeywordFormControl()
    ]);
```

The `FormArray`is initialized with the initial set of controls it will manage – expressed as an array. Noticed that the controls are not given names. Consistency is important when creating controls – so define the `createKeywordFormControl`– just creates the `FormControl`.

Within the new component, can manage the array of controls in the `FormArray`to match the selected `Product`object. like:

```html
<ng-container formGroupName="keywords">
    <div class="mb-3" *ngFor="let c of keywordGroup.controls; let i= index">
        <label>Keyword {{i+1}}</label>
        <input class="form-control" [formControlName]="i" [value]="c.value" />
    </div>
</ng-container>
```

It is important to reflect the structure of the `FormGroup`and `FormArray`when creating HTML elements, ensuring that each is correctly configured with the `formGroupName`directive. And note each `input`must be configured with the `formControlName`directive – using an array position as its value instead of a name:

`<input class="form-control" [formControlName]="i" [value]="c.value" />`

The result is that the number for the form controls displayed to the user varies based on Product value.

### Adding and Removing Form controls

To complete the support for multiple keywords, going to allwo the user to add and remove controls.

```ts
addKeywordControl() {
    this.keywordGroup.push(this.createKeywordFormControl());
}

removeKeywordControl(index: number) {
    this.keywordGroup.removeAt(index);
}
```

And the new methods use the `FormArray`feature to add and remove `FormGroup`objects , in the template, adds elements to that will invoke the new component methods and allow the user to manage the number of keywords:

```html
<ng-container formGroupName="keywords">
    <button class="btn btn-sm btn-primary my-2"
            (click)="addKeywordControl()" type="button">
        Add keyword
    </button>
    <div class="mb-3" *ngFor="let c of keywordGroup.controls; let i= index let count=count">
        <label>Keyword {{i+1}}</label>
        <div class="input-group">
            <input class="form-control" [formControlName]="i" [value]="c.value" />
            <button class="btn btn-danger" type="button" *ngIf="count>1"
                    (click)="removeKeywordControl(i)">
                Delete
            </button>
        </div>
    </div>
</ng-container>
```

For this use the `count`variable exported by the `ngForm`directive to display a `Delete`directive only when there are multiple controls in the form array.

## Validating Dynamically created Form Controls

Validation for controls in a `FormArray`is similar to validating the controls in the `FormGroup`. Can:

```ts
createKeywordFormControl(): FormControl {
    return new FormControl("", {validators: Validators.pattern("^[A-z]+$")});
}
```

Then in the template just write:

```html
<ul class="text-danger list-unstyled mt-1">
    <li *validationErrors="productForm; control:'details.keywords.' + i;
    label: 'keyword'; let err ">
        {{err}}
    </li>
</ul>
```

## Playing with an injector

Fore, *manually use the injector* in component to resolve and create a service. Like:

```ts
export class UserDemoInjectorComponent{
    // UserSerivce is an @Injectable() decoratored class
    const injector: any = ReflectiveInjector.resolveAndCreate([UserService]);
	// use the injector to get the instance
	this.userService= injector.get(UserService);
}
```

This starts as a basic component – have a selector, template, and CSS. In our component’s ctor, using a *static* method from `ReflectiveInjector`called `resolveAndCreate()`– responsible for creating a new **injector**. And the parameter we pass in is an array with all the *injectable thing* we want this new injector to *know*.

### Providing Dependencies with *NgModule*

While it’s interesting to see how an `injector`is created – but that isn’t the typical way use injections. Instead, normally do is – 

- Use `NgModule`to *register* what we will inject – called *providers* and
- Use decorators to specify what we are injecting.

By doing these two steps, `Angular`will manage creating the injector and resolving the dependencies. Let’s convert our `UserService`to be *injectable* a a singleton across our app like:

```ts
@NgModule({
	imports: [CommonModule],
	providers: [UserService],
	declarations: [],
})
export class UserDemoModule {
}
```

Now we can inject `UserService`into our component like this:

### Providers are the Key

It’s important to know that when put the `UserService`on the ctor for the `UserDemoComponent`, Angular knows what to inject – cuz we listed `UserService`int he **providers** key of our NgModule.

## Providers

There are several ways can configure resolving injected dependencies in Angular – fore:

* Inject a instance of a class
* Inject a value
* Call any function and jinect the return value of the function.

### Using a Class

As discussed, injecting a singleton instance of a class is probably the most common type of injection. When put the class itself into the list of *providers* like this:

`providers: [UserService]`

This tell Ng that we ant to provide a singleton *instance* of `UserService`whenever `UserService`is injected. Cuz this pattern is so common – the class by itself is actually shorthand notation for the following – like:

```ts
providers: [{provide: UserService, useClass: UserService}]
```

`provide`is the *token* that we use to identify the injection, and the second `useClass`is how and what to inject. This is just the common case – but need to know that the token and the injected thing aren’t required to have the same name. As seen – in this case the injector will create a **singleton** behind the scenes and return the just same instance every time we inject it. When just creating the `UserService`instance for the first time, the DI system will trigger the class’s ctor method.

### Using a Value

Injecting a singleton instance of a class is probably the most common type of injection like:

`providers: [UserService]`

This just tells Ng that we want to provide a singleton instance of `UserService`.. Another way can use DI is to provide a value – much like might use a global constant – fore, might configure an API endpoint URL depending on the environment – to do this, in `NgModule`providers – use the key `useValue`like:

```ts
providers: [{provide:"API_URL", useValue: "http://myapi.com/v1"}]
```

Above, for the `provide`token we are just using a *string* of `API_URL`if use a string for the `provide`value,  angular can’t infer which dependency we’re resolving by the tpe, FORE, **can’t** write:

```ts
constructor(apiURL: "API_URL")...
```

For this case, must use the `@Inject()`decorator like this:

```ts
constructor(@inject("API_URL") apiurl: string) {//...}
```

Now that we know how to do simple values with `useValue`and singletion classes with `useClass`, ready to talk about more advanced case – writing configurable services using **factories**.
