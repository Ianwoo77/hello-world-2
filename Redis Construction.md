# Redis Construction

`STRING LIST SET HASH ZSET`

### Strings in Redis

`GET SET DEL`-- are similar to strings that in other langs -- key-value pairs.

### LIST in Redis

`LPUSH/RPUSH, LPOP/RPOP`, can fetch an item in a given position with `LINDEX`, fetch a range with `LRANGE`

### Sets in Redis

similar to `LISTs`that they are a seq of strings -- uses a hash table to just keep all unique just, and unordered.

`SADD, SMEMBERS, SISMEMBER, SREM`

### HASHes in Redis

Store a mapping of keys to values. Can just think of `HASHes`in redis as miniature version of redis itself.

`HSET HGET HGETALL HDEL`

### ZSETs in Redis

Like HASHes, `ZSET`also hold a type of key and value -- values are limited to floating-point numbers.

`ZADD, ZRANGE, ZRANGEBYSCORE, ZREM`

## Real problem

When dealing with scores that go down over time, need to make the posting time, current time, or both relevant to the overall score. To actually build -- need to start thinking of structures of using Redis -- For starters need to store article info like the title, link, posted, time, votes number... Can just use a `HASH`to store this info and an example article can.

To store a sorted set of articles, use a `ZSET`which keeps items ordered by the item scores. Can just use article ID as the member, create anotehr ZSET with the score...

And, in order to prevent users from voting for the same article more than once, need to store a unique listing of users who voted -- use a `SET`for each article -- and store the member IDs of all users who have voted on the given.

First, handle voting -- when someone tries to vote on, we first vertify that the article was posted within the last week by checking the article’s post time with ZSCORE. like:

```python
ONE_WEEK_IN_SECONDS= 7*86400
VOTE_SCORE=432

def articule_vote(conn, user, article):
    cutoff= time.time()- ONE_WEEK_IN_SECONDS
    if conn.zscore('time:', article) < cutoff: # check if can still be voted
        return
    article_id = article.partition(':')[-1] # get the id porition
    if conn.sadd('voted:' + article_id, user):
        conn.zincrby('score', article, VOTE_SCORE)
        conn.hincrby(article, 'votes', 1)
```

## Strings and bitmaps

The simplest value type in Redis is a `string`. A value can be added to the dbs with the `SET`command. When using the `SET`, a key and a value are the minimum requirements in order to create the entry. Fore, a common way to use simple string vlaues is as a counter -- in these cases, commands like `INCR`can be used like:

```sh
set logincount 1
incr logincount
get logincount
```

Can manipulate numerous other commands and work with string an string-like data in Redis, and closely related to strings are *bitmaps* -- are a form of string storage. Using this, can represent many data elements that are simply 0 or 1 -- this is useful for operations where you need to know thos two possible values.

### Lists

Are a way to store related data -- called arrays, but in Redis -- is a linked list, means operations to write to the list are very fast -- depending on where in the list the item is located -- its performacne is not as fast for reading.

For Lists, use o*ne key holding several ordered values*, and vlaues are stored as strings. to the head or tail Can push a value onto a list using `PUSH, RPUSH`

```sh
lpush users steve bob # hold 2 items
```

Indexed beginning at 0 -- an individual item can be retrieved using the `LINDEX`command.

```sh
lindex users 0
lrange users 0 -1
```

### Sets

*sets* like lists - and are not retrieved by index and are not sorted. Instead, you query to see if a member exists in the set. Redis manages the internal storage for sets, the result is that you don’t work with set vlaues in the same way that you do lists.

```sh
SADD fruit apple
SMEMBERS fruit
SISMEMBERS fruit apple
```

### Hashes

Are used to store collections of k/v pairs -- Contrast a hash with a simple string data type where there is one value corresonding to one key. A hash has one key, and then within that structure are more fields and values. Might use a hash to store the current state of an object in an application. can:

houseID:5150
numberBedrooms:3
sequeareFeet:2700
hvac: forced Air

Can represent this structure with a Redis hash looks like:

```sh
HSET house:5150 numBedRooms 3 squareFeet 2700 hvac "forced air"
# then can get some value
HGET house:5150 numBedRooms
```

### sorted Sets

*sorted set* are used to store data that needs to be ranked, such as a leaderboard, like a hash, a single key stores several members -- *to store for each of the member is a number.*

Fore, there is some struct like:

User Followers:
steve: 31
owen:2
jakob:13

Within Redis, this data can be re-created as a sorted set with the following:

```sh
zadd userFollowers 31 steve 2 owen 13 jakob
```

And the `zrange`command is used to just retrieve the resulting sorted set. Just like the `lrange`command, which is used to retrieve values from a list -- `zrange`accepts the beginning and ending number for retrieval. fore:

```sh
zrange userFollowers 0 -1
# for this, members sre retrieved, not corresponding scores

zrange userFollows 0 -1 WITHSCORES # list the scores
```

As can see from the output -- can also retrieve the members and scores in reverse order.

```sh
zrevrange userFollowers 0 -1 withscores
zincrby userFollowers 20 jakob
```

### HyperLogLog

Is a specialized but highly useful data type in redis --this is used to keep an estimated count of unique items. Might use this for tracking an overall count of unique visitors to a website. This maintains an internal hash to determine whether it has seen the value already. like:

```sh
PFADD visitors 127.0.0.1
```

## Type embedding

Type embedding is mainly used for convenience -- in most cases, to promote behaviors. And if decide to use type embedding, need to just keep two constraints in mind -- 

- It shouldn’t be used solely as some syntactic sugar to simplify accessing a field, if this is the only reationale, not do that.
- It shouldn’t promote data or a behavior want to hide.

## Not using the functional options pattern

When designing an API, one question -- how do we deal with optional configuration -- fore, have to design a lib that exposes a function to create an http server. like:

```go
func NewServer(addr string, port int) (*http.Server, error) {}
```

And, the clients of our lib -- limited and lacks other parameters -- however, noticed that adding new parameters may break the compatibility -- forcing the clients to modify the way call `newServer`. In the meantiime, would like to enrich the logic related to the port -- 

- if port isn’t set, uses the default
- if is neg, error
- if 0, uses a random
- otherwise, using user’s

### Config struct

Cuz Go doesn’t support optional parameters in function signatures -- the approach.. to use a configuration struct to convey what is mandatory and what is optional. fore:

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config)
```

This, doesn’t solve port management problem -- if not provided, just 0 value provided, `nil`for slices..

therefore, in the following -- need to find a way to distinguish between a port purposely to 0 and just missing... one option might be :

```go
type Config struct {
    Port *int
}
```

work, but has a couple of downsides. 1) not handy 2) client using will need to pass empty value. like:

`httplib.NewServer("lcoalhost", httplib.Config{})`

Another opt is to use the classic builder pattern -- 

### Builder pattern

Originally part of the -- the *builder pattern* provides a flexible solution to various object-creation problems -- for the struct `Config`-- rquries an extra struct, named `ConfigBuilder`, which receives methods to config and build a `Config` - like:

```go
type Config struct {
	Port int
}

type ConfigBuilder struct {
	port *int
}

func (b *ConfigBuilder) Port(port int) *ConfigBuilder {
	b.port = &port
	return b
}

func (b *ConfigBuilder) Build() (Config, error) {
	cfg := Config{}
	if b.port == nil {
		cfg.Port = 80
	} else {
		if *b.port == 0 {
			cfg.Port = rand.Intn(65536)
		} else if *b.port < 0 {
			return Config{}, errors.New("port should be positive")
		} else {
			cfg.Port = *b.port
		}
	}
	return cfg, nil
}
```

For this, the `ConfigBuilder`struct holds the client config, exposes a `Port`to set up the port. Usually, such a configuration method returns the builder itself so that can use method chaining -- also exposes a `Build`that hods the logic on initializing the port value.

Then client would use builder-based API in the following manner.

```go
builder := httplib.ConfigBuilder{}
builder.Port(8080) // sets the port
cfg.err := builder.Build() // builds the Config struct
if err != nil {
    return err
}
server, err := httplib.NewServer("localhost", cfg)
if err != nil {
    return err
}
```

First, the cilent creates a `ConfigBuilder`and uses it to set up an opt field, then need to call the `Build`method and checks for errors. But, there is also another approach called the **function optional pattern**

### Functional options pattern

The last approach we will discuss is the *functional options pattern*. Although there are different implemenation with minor variations -- main idea -- 

- An unexported struct holds the configuration -- `options`fore
- Each option is a function that returns the same type like: `func(options *Options) error`FORE:

```go
type options struct {
	port *int
}

type Option func(options *options) error

func WithPort(port int) Option {
	return func(options *options) error {
		if port < 0 {
			return errors.New("Port must be positive")
		}
		options.port = &port
		return nil
	}
}
```

For this, the Go implemenation for the `options` -- `WithPort`returns a closure. A *closure*just function that references variables from outside its body, for this, is `port`. in the main:

```go
func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options Options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    var port int
    if options.port == nil {
        port=8000
    }else{
        port= *options.port
    }
}
```

This is the functional options pattern -- provides a handy and API-friendly way to handle options.

# How Request Context Works

Every `http.Request`that our handlers process has a `context.Context` object embedded in it, which can use to store info during the lifetime of the request.

In a web app a common use-case for this is to pass info between your pieces of middleware and other handlers. Want to use it to check if a user is *authenticated-and-active* once in some middleware, and if are, then make this info available to all our other middleware and handlers.

### The request context Syntax

The basic code for adding info to a request’s context looks like this:

```go
// where r is a *http.Request
ctx := r.Context()
ctx = context.WithValue(ctx, "isAuthenticated", true)
r = r.WithContext(ctx)
```

- ust the `r.Context()`get existing context from a request and assign it to the variable.
- Then use the `ctx.WithValue()`to create a new *copy* of the existing context, containing `isAuthenticated`and value of `true`.
- Then use the `r.WIthContext()`to create a *copy* of the request containing new context.

IMPORTANT -- don’t actually update the context for a request directly -- what doing is just create a *new* copy of the `http.Request`object with new context in it.

Should also point out -- for clarity, made that code snippet a bit more verbose than it needs to be. shorten like:

```go
ctx = context.WithValue(r.Context(), "isAuthenticated", true)
r= r.WitContext(ctx)
```

The important to explain is -- behind the scenes, request context values are stored with the type `interface{}`. And that means that, after retrieving them from the context, need to assert them to their original type before use them.

To retrieve just using the `r.Context().Value()`like:

```go
isAuthenticated, ok := r.Context().Value("isAuthenticated").(bool)
if !ok{
    return errors.New(...)
}
```

### Avoiding Key Collisions

In the code sample -- using the string `isAuthenticated`as the key for storing and retrieving the data from a request context -- this isn’t recommended -- cuz there is risk that other 3rd-party packages -- also want to store data using the same string..

To avoid, just to create your **own custom type** which U can use for your context keys.

```go
type contextKey string
const constKeyIsAuthenticated = contextKey("isAuthenticated")

//...
ctx := r.Context()
ctx = context.WithValue(ctx, contextKeyIsAuthenticated, true)
r = r.withContext(ctx)

isAuthenticated, ok := r.Context().Value(constKeyIsAuthenticated).(bool)
if !ok {...}
```

## Request context for AuthC/AuthZ

So, with those explanations out of the way let’s use the request context functionality in our application. begin by heading back to our users.go file and update the `UserModel.Get()`-- that retrieves the details of a specific user from the dbs like so:

```go
func (m *UserModel) Get(id int) (*models.User, error) {
	u := &models.User{}

	stmt := `select id, name, email, created, active from users where id=?`
	err := m.DB.QueryRow(stmt, id).Scan(&u.ID, &u.Name, &u.Email, &u.Created, &u.Active)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, models.ErrNoRecord
		} else {
			return nil, err
		}
	}
	return u, nil
}

```

Then open the `cmd/web/main.go`file and defineyour own custom `contextKey`type and `contextKeyIsAuthenticated`variable, so that we have a unique key can use to store and retrieve the user details.

```go
type contextKey string
const contextKeyIsAuthenticated = contextKey("isAuthenticated")
```

Create a new `authentiate()`middleware which fetches the user’s ID from session data, checks the dbs to see if the ID is valid and for an active user, and then updates the requeset context to include this info.

```go
func (app *application) authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// check if a authenticatedUserID exists in the session
		// if not present, then call next handler
		exists := app.session.Exists(r, "authenticatedUserID")
		if !exists {
			next.ServeHTTP(w, r)
			return
		}

		// fetch the details of the current user from the dbs, if no matching
		// remove (invalid) authenticationUserID from the session and call the next
		// handler in the chain as normal.
		user, err := app.users.Get(app.session.GetInt(r, "authenticatedUserID"))
		if errors.Is(err, models.ErrNoRecord) || !user.Active {
			app.session.Remove(r, "authenticatedUserID")
			next.ServeHTTP(w, r)
			return
		} else if err != nil {
			app.serverError(w, err)
			return
		}

		// otherwise, know the request is authenticated, create a new copy of request, with true
		// value added to the request context to indicate that.
		ctx := context.WithValue(r.Context(), contextKeyIsAuthenticated, true)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
```

The important thing to emphasize here is:

- when don’t have an authenticated and active user, pass the original and **unchanged** `*http.Request`to the next hander in the chain.
- When have an authenticated, create a copy of the request with a `contextKeyIsAuthenticated`and `true`value.

Just include the `authenticate()` to dynamic middleware chain like:

```go
func (app *application) isAuthenticated(r *http.Request) bool {
	isAuthenticated, ok := r.Context().Value(contextKeyIsAuthenticated).(bool)
	if !ok {
		return false
	}
	return isAuthenticated
}
```

It’s just important to point out that if there is not a value in the context with the `contextKeyIsAuthenticated`key, or the underlying value isn’t a `bool`, then this type assertion will just fail.

# Using 2FA

Once have set up an authenticator, will be redirect to the `TwoFactorAuthentication `page.

- `Account/Manager/TwoActorAuthentication`– displayed when the user clicks the 2fa link in the self-management freature.
- `../EnableAuthenticator`– displays the QR code and setup key required to configure an authenticator.
- `../ResetAuthenticator`– allows the user to generate a new authetnicator set up code.
- `../GenerateRecoverCodes`– generates a new set of recovery codes and then redirects to the `ShowRecoveryCodes`page to display them.
- `Account/ForgotPassword`– prompts the user for their email address and sends the confirmation email
- `../ForgotPasswordConfirmation`– displayed once the confirmation email has been sent.

### Changing Account Details

The self-managment feature support for changing user’s details. the UI page – 

- `Account/Manage/Index`– allows set a phone
- `../ChangePassword`– new password
- `../Email`-- a new email
- `../ConfirmEmailChange`-- targeted by the URL in the confirmation email.

### Personal Data

`Account/Manage/PersonalData`-- presents theuser with the buttons for downloading and deleting data.

### Denying Access

The final workflow is used when the user is denied access to an action or PRs – this is just known as *forbidden response* – it is the counterpart to the challenge response that the promts for user credentials.

- `Account/AccessDenied`-- displays a warning to the user.

# Configuring Identity

How to configure Identity including how to support 3rd-party services from Google…

- The Identity configuration options are a set of properties whose values are used by the classes that implement the Identity API - which can be used directly or consumed through the Identity UI package.
- let U change the way that Identity behaves.
- using the std ASP.NET core options pattern.
- Important to ensure that configuration changes do not cause problems for existing user accounts.

## Configuring Identity

Identity is configured using the std core options pattern – using the settings defined by the `IdentityOptions`class defined in the `Identity`namespace. Useful Identity props – 

`User, Password, SignIn, Lockout`

### Configuring User Options

The `IdentityOptions.User`is assigned to a `UserOptions`object - 

- `AllowedUserNameCharacters`
- `RequireUniqueEmail`

### Configuring Password Options

The `IdentityOptions.Password`prop is assigned to a `PasswordOptions`obj, which is used to configure the:

- `RequiredLength`-- specifies a minimum number of characters
- `RequireUniqueChars`
- `RequieNoAlphanumeric`
- `RequireLowercase, RequireUppercase, RequireDigit`

Fore, the `IdentityUI`package only uses email adress to identity users, to which the `UserOptions.AllowUserNameCharacters`does not apply. can:

```cs
builder.Services.AddDefaultIdentity<IdentityUser>(opts=>
{
    opts.Password.RequiredLength = 8;
    opts.Password.RequireDigit = false;
    opts.Password.RequireLowercase = false;
    opts.Password.RequireUppercase = false;
    opts.Password.RequireNonAlphanumeric = false;
}).AddEntityFrameworkStores<IdentityDbContext>();
```

### Configuring Sign-in Confirmation requirements

And the `IdentityOptions.SignIn`property is assigned a `SignInOptions`object, which is used to configure the conifrmation requirements for account using the properties – 

- `RequireConfirmationEmail, RquireConfirmedPhoneNumber`
- `RequireCoinfirmedAccount`– when `true`, only accounts that pass verification by the `IUserConfirmation<T>`interface can sign in .

And it is just a good idea to set the `RquireConfirmedAccount`prop to `true`. like:

```cs
builder.Services.AddDefaultIdentity<IdentityUser>(opts=> {
    //...
    opts.SignIn.RequireConfirmedAccount= true;
}).AddEntityFrameworkStores<IdentityDbContxt>();
```

For this, if attempt to sign in using the new account, but not confirmation link, then presented the generic attempt error.

### Configuring Lockout Options

The `IdentityOption.Lockout`prop is assigned a `LockoutOptions`object – which is used to configure lockouts, that prevent sign-ins – even if the correct password is used, after a number of failed attempts. fore:

- `MaxFailedAccesAttempts`– specifies the number of failed attempts allowed before an account is lock out 5
- `DefaultLockoutTimeSpan`– specifeis the duration for lockouts, 5minutes
- `AllowedForNewUsers`-- dettermines whether the lockout feature is enabled for new accounts, default `true`

## Configuring External Authentication

Extenal authenC delegte the process of authenticating users to a third-party service. Which allows multiple applications to authenticate users from the same set of accounts.

External authentication generally uses the `OAuth`protocol – A registration process is just required for each external service. During which the app is described and the level of access to user data, declared.

During the registration, will usually have to specify a *redirection URL*. During the authC process, the external service will send the user’s browser an HTTP redirection to this URL, which triggers a request to core, providing the app with data required to complete the sign-in.

### Configuring Google AuthC

To just register the example, Run the commands to store the client ID and secret using the `.NET`secret features, which ensures that these values won’t be included when the source code is commited into a repository.

```powershell
dotnet user-secrets init
dotnet user-secrets set "Google:ClientId" "<client-id>"
dotnet user-secrets set "Google:ClientSercret" "<client-secret>"
```

For this, the first command initializes the sercret store – the other commands just store the data values so they can be accessed in the appliation using the ASP.NET core configuration system. And also, need to install the Google authentication package to the app.

```sh
install-package Microsoft.AspNetCore.Authentication.Google -Version 6.0.16
```

Then, to configure the app, add the statement in the program.cs like:

```cs
builder.Services.AddAuthentication()
    .AddGoogle(opts =>
    {
        opts.ClientId = builder.Configuration["Google:ClientId"];
        opts.ClientSecret = builder.Configuration["Google:ClientSecret"];
    });
```

The `AddGoogle()`sets up the Google authenC handler and is configured using the options pattern with the `GoogleOptions `class.

# Customizing validation CSS classes Recovery

Css frameworkds such as bootstram… all have predefined classes for jsut valid and invalid input states. Blazor just allow use to use these classes – instead of the default ones it provides – by sepcifying them in a custom `FieldCssClassProvider`. like:

```cs
public class BootstrapCssClassProvider: FieldCssClassProvider {
    public override string GetFieldCssClassField(EditContext editContext,
                                                in FieldIdentifier fieldIdentifier)
    {
        var isValid= !editContext
            .GetValidationMessages(fieldIdentifier).Any();
        if(editContext.IsModified(fieldIdentifier)) {
            return isValid? "is-valid": "is-invalid";
        }
        return isValid? "" : "is-invalid";
    }
}
```

When deriving from this `FieldCssClassProvider`, just need to override the `GetFieldCssClass`method - this takes an `EditContext`and a `FieldIdentifier`that represents the field in the form we are getting CSS classes. The `EditContext`jsut the brain of the form and keeps track of the state of each field in the form.

Using this – add following:

```html
<EditForm EditContext="_editContext"...></EditForm>
```

```cs
private EditContext _editContext = default!;

protected override void OnInitialized() {
    _editContxt = new EditContext(_trail);
    _editContext.SetFieldCssClassProvider(
    new BootstrapCssClassProvider());
}
```

## Building custom input components with InputBase

While Blazor just provides us all the basic input components – need to build a form – at some point we will need sth a little more complex – or a little more tailored to our needs.

To help get started with building a custom input component, the team has included a base type that is going to do a lot of – `InputBase<T>`-- this type is going to handle the integration with `EditContext`class. This means that our componetn will automatically be registered wtih the validation system and have its state tracked.

All we need to do is provide the UI and implemenation of the method `TryParseValueFromString()`. like:

```html
<div class="input-time">
    <div>
        <input class="form-control" type="nubmer" min="0"/>
    </div>
</div>
```

```cs
protected override bool TryParseValueFromString(
string? value, out int result, out string validationErrorMessage) {
    throw new NotImplemeantionExecption();
}
```

This method jsut must be implemented – but, its job is to convert a string value to the type that the component is bound to on the form model. However - may be never get called. And this will be the case in our app. cuz the base class provide two props to update the model value –

`CurrentValueAsString, CurrentValue`

If were writing app only require a single input element, could bind that input directly to the `CurrentValueAsString`prop. And when a value was entered in the input, it would set `CurrentValueAsString`and would then call `TryParseValueFromString()`.

Here have two – can’t bind them to one prop. So need to create our own fields to bind them jsut. then need to take those individual values and convert them into a single integer value can update the model with. – then need to take those individual values and convert them into a single integer can update the model with.

`CurrentValue`is a generic prop and will adopt the type specified when inheriting from `InputBase<T>`. like:

```cs
private int _hours;
private int _minutes;

private void SetHourValue(ChangeEventArgs args) {
    int.TryParse(args.Value?.Tostring(), out _hours);
    SetCurerentValue;
}
//...
private void SetCurrentValue(){
    CurrentValue= (_hours*60) + _minutes;
}
```

```html
<input class = "form-control" type="nubmer"...
       @onchange="SetHourValue" value= "@_hours" />
```

Instead – using fields to set the value of the inputs and then handling the `onchange`event of each one so can perform some logic. And the final piece to the component involves loading an existing value – when the component is being used to edit an existing record – just using the `OnParametersSet()`– 

```cs
protected override void OnParametersSet() {
    if(CurrentValue>0){
        _hours=CurrentValue/60;
        _minutes=CurrentValue%60;
    }
}
```

### Using the custom input component

Styling need to configure for validation – Another nice feature of using `InputBase<T>`is that it provides a property called `CssClass`outputs the correct validation classes based on our field’s state. like:

```html
<input class="form-control @CssClass"...
```

```html
<InputTime @bind-Value="_trail.TimeInMinutes" id=...
```

Also add some vlaidation for the `TimeInMinutes`to class. just in the `Shared`proj, add to the validation rule like:

`RuleFor(x=>x.TimeInMinutes).GreaterThan(0).WithMessage("Please enter a positive value")`

## Working with files

Just as with other HTML input elements, Blazor provdies a component out of the box for uploading files – `InputFile`. Going to changing our form to make two calls to the API. The first is just JSON, The second is goging to upload the image.

### Configuring the `InputFile`component

```html
<FormFieldSet>
    <label for="trailImage" class="fw-bold text-secondary">
        Image
    </label>
    <InputFile OnChange="LoadTrailImage" class="form-control-file"
               id="trailImage" accept=".png,.jpg,.jpeg"></InputFile>
</FormFieldSet>
```

For this, the most important point to just notice that the `InputFile`component doesn’t use the `bind`directive as the other input component do. for this, must handle the `OnChange`event it exposes – Just as file uploading in regular HTML forms, can provide a list of file types we want the user to be able to upload using the `accept`.

Now hat have the `InputFile`component in place, need to add the `LoadTrailImage`method just like:

```cs
private IBrowserFile? _trailImage;

private void LoadTrailImage(InputFileChangeEventArgs e)
{
    _trailImage = e.File;
}
```

#### Handling multiple files

In app, that need to allow multiple files to be selected for upload – the `multiple`must be added to the `InputFile`. This will allow the user to select more than one file in the selection dialog, and some addiional functionality on the `InputFileChangeEventArgs`also can be used. And the `FileCount`can be used to check how many files. By default, just 10, more will throw. Can change.

# Manipulating Streams

The Rx lib has many other operators for working with the in-stream data. In fact, most Rx work is about manipulating the data as it comes down the sream.

- `mergetMap`combines flattening and mapping into a single operation.
- `filter`allows a stream to be picky about the values are allowed.
- `tap`is a unique case that doesn’t manipulate the stream’s value directly, allows a developer to tap into the stream.

Can use the `fromEvent()`and `map()`to connection this func to a textbox that prints out a translation.

```js
function pigLatinify(word) {
    if (word.length<2) {
        return word;
    }
    return word.slice(1)+'-'+word[0].toLowserCase()+'ay';
}
```

Can use this from – 

```js
let keyup$= fromEvent(textbox, 'keyup')
.pipe(
	map(event=>event.target.value),
    map(wordString=> wordString.split(/\s+/)),
    map(wordArray=>wordArray.map(pigLatinfy))
)
.subscribe(translated=>console.log(translated));
```

Cuz, every keyup event is sent down the stream by the `fromEvent()`– this is only one of many possible ways to just implement a real-time translator.

### Flattening And Reducing

Instead of intermingling two different streams, can create an *inner* observable to represent the stream of individual words. `mergeMap`makes this easy – If `mergeMap`'s func returns an observabe, `mergeMap()`just subscribes to it. So the programmer only needs to be concerned about the business logic.

NOTE: Any values emitted by the innenr observable are then passed on to the outer observable – This inner neatly completes cuz there is a finite amount of data to process. The inner observable here uses the `from`ctor – which takes any unwrappable value (arrays…) unwraps that value, and passes each resulting item along as a spearate event like:

```ts
of("Bender", "Fry", "Leela").pipe(
    mergeMap((wordString: string) =>
        from(wordString.split(/\s+/))
            .pipe(
                map(s => s.toUpperCase()),
                reduce((bigString, newWord) => bigString + ' ' + newWord, '')
            )
    )).subscribe(console.log);
```

### Typehead

Tackle a diffrent problem – typehad – Can do:

```ts
fromEvent<any>(typeheadInput, 'keyup')
.pipe(
    map((e):string => e.target.value.toLowerCase()),
    tap(()=> typeheadContainer.innerHTML=''),
    mergeMap(val=>
            from(usStates)
            .pipe(filter(state=>state.includes(val)),
                 map(state=> state.split(val).join('<b>'+val+'</b>')),
                 reduce((prev:any, staate)=>prev.contact(state),[])))
)
.subscribe(
    // just handle the HTMLelement.
)
```

## Completing the Routing Implementation

Adding routing to app is good stat – but lots of the app features just don’t work – fore, .. Need to:

### Handling route Changes in Components

For now the form component isn’t wroking properly cuz it isn’t being notified that the user has clicked a button to edit a product. This eads to a timing issue in the way that the product component and the table componetn communicate, via the `Subject`– but a `Subject`only passes events to subscribers that arrive **after** the `subscribe()`has been called.

Could be solved by replacing the `Subject`with a `BehaviorSubject`, which sends the most recent event to subscribers when they call the `subscribe()`– but, a more elegant approach, is just to use the URL to collaborate between components.

For ng, provides a service that components can receive to get details of the current route. The relationship between the service and the types that it provides access to may – 

The class on which components declare a dept is called `ActivatedRoute`which defines one important prop – 

`snapshot`-- returns an `ActivatedRouteSnapshot`obj that describes the current route.

The `snapshot`prop returns an instance of the `ActivatedRouteSnapshot`class, provides information aobut the route that led to the current component being displayed to the user using the props like:

- `url, params, queryParams, fragment`

And the `url`is the one of the most important for this example – allows the component to inspect the segments of the current URL and extract the info from them that is requied to perform an opreation.

`path, parameters`

So, to determine what route has been activated by the user, the form component can declare a dependency on `ActivatedRoute`and then use the object it receives to inspect the segments of the URL like:

```ts
// in the FormComponent:
constructor(private model: Model, activateRoute: ActivatedRoute) {
    this.eidting= activateRoute.snapshot.url[1].path==='edit';
}
```

So, the component no longer uses the sahred state service to receive events – instead, inspects the second segment of the active route’s URL to set the value of the `editing`.

### Using Route Parameters

When set up the routing configuration for the app, defined two routes that targeted the form component like: 

```ts
{path: "form/edit", component: FormComponent}...
```

When ng is trying to match a route to a URL, looks at each segment in turn and checks to see that it matches the URL that is being navigated to. For this, just the *static* segments, which just means that they have to match the navigated URL exactly before Angular will activate the route.

Ng routes can be just more flexible and include *route parameters* – which allow any value for a segment to match the corresponding segment in the nav URL. just:

```ts
{path: "form/:mode", component: FormComponent}
```

The second segment of the modified URL defines a route parameter, denoted by the colon followed by name. Note that the number of the segments must match.

```ts
contstruct(private model: Model, activeRoute: ActivatedRoute) {
    this.editing = activeRoute.snapshot.params["mode"]==="edit";
}
```

### Using multiple Route Parameters

To tell the form component which product has been selected when the user clicks an Edit - need to use a second route parameter – like:

`{path: “form/:mode/:id”, component: FormComponent}`

Note that the new route will match any URL that has 3 segments where the first segment is `form`. Just like:

```html
<button class="..." (click)="editProduct(item.id)"
        [routerLink]="['/form', 'edit', item.id]">
    edit
</button>
```

Just note that the `routerLink`is now enclosed in `[]`telling Angualr that it should treat the attribute value as a *data binding expression*. And the expression is set out as an array, with ech element containing the vlaue for one segment. And note that the first two are literal string, but the third will be evaluated to include the `id`prop.

And need to modify the ctor to get the data like:

```ts
constructor(private model: Model, activeRoute: ActivatedRoute) {
    this.editing= activeRoute.snapshot.params["mode"]=="edit";
    let id = activeRoute.snapshot.params["id"];
    if(id!=null) {
        Object.assign(this.product, model.getProudct(id) || new Product());
        this.productForm.patchValue(this.product);
    }
}
```

So, when the user clicks an `edit`, the routing URL that is activated tells the form component that an edit operation is reured and specifies the product is to be modified.

### Dealing with Direct Data Access

And the introduction of routing has revealed a problem with the way that data is obtained from the web service. But, if the user just navigates dirctly to the URL for editing a product – then the form is never populated with data – cuz the `RestDataSource`has been written to assume that individual `Product`will be accessed only by clicking `Edit`. For now, just use the `ReplaySubject`to handle this situation.

```ts
@Injectable()
export class Model{
    private replaySubject: ReplaySubject<Product[]>;
    //...
    constructor(private dataSource: RestDataSource) {
        //...
        this.replaySubject = new ReplaySubject<Product[]>(1);
        this.dataSource.getData().subscribe(data=> {
            this.products=data;
            this.replaySubject.next(data);
            this.replaySubject.complete();
        })
    }
}
//... other methods
getProductObservable(id: number) : Observable<Product | undefined> {
    let subject = new ReplaySubject<Product | undefined> (1);
	this.replaySubject.subscribe(products=> {
        subject.next(products.find(p=>this.locator(p, id)));
        subject.complete();
    });
	return subject;
}
```

The changes rely on the `ReplaySubject`to ensure that individual `Product`objects can be received even if the call to the new `getProductObservable`method. So just:

```ts
constructor(private model: Model, activeRoute: ActivatedRoute){
    this.editing = activateRoute.snapshot.params['mode']=='edit';
    let id= ...;
    if (id!=null) {
        model.getProductObservable(id).subscribe(p => {
            Object.assign(this.product, p || new Product());
            this.productForm.patchValue(this.prodcut);
        });
    }
}
```

### Using Optional Route Parameters

Optional route parameters allow URLs to include info to provide *hints or guidance* to the rest of the application, but this is not essential for the app to work – this type of route parameter is expressed using URL matrix notation, which is not part of the specification for URLs but which browsers support nonetheless. FORE:

```html
<button class="btn btn-warning btn-sm" (click)="editProduct(item.id)"
    [routerLink]="['/form', 'edit', item.id,
    {name:item.name, category:item.category, price:item.price}]">
```

The optional values are expressed as literal objects, where property names identify the optional parameters. So, the form component need to receive this information like:

`http://localhost:4200/form/edit/5;category=Bender`

```ts
constructor(private model: Model, activeRoute: ActivatedRoute) {
    //...
    if (id != null) {
        model.getProductObservable(id).subscribe(p => {
            Object.assign(this.product, p || new Product());
            this.product.name = activeRoute.snapshot.params['name']
                ?? this.product.name;
            this.product.category = activeRoute.snapshot.params['category']
                ?? this.product.category;
            let price = activeRoute.snapshot.params['price'];
            if (price != null) {
                this.product.price = Number.parseFloat(price);
            }
            this.productForm.patchValue(this.product);
        });
    }
}
```

## Navigating in Code

Using the `routerLink`attribute makes it just easy to set up navigation in templates, but apps will often need to initiate nav on behalf of the user within a compontent or directive. To give access to the routing system to building blocks such as directives and componetns, Ng provides the `Router`class which is availalbe *as a service* through 

- `navigated`-- `boolean`returns `true`if there has been at least one navigation event and `false`otherwise
- `url`– returns the active URL
- `isActive(url, exact)`-- returns `true`if the specified URL defiined by the active route. The `exact`specified whether all the segment in the specified URL must match the current URL for the method to return `true`.D