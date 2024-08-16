# Hosting Services & Authentication

In this, will choose a hosting service and prepare the authenticaiton details U will use to connect to remote repositories on that hosting service by using either the HTTPS, or SSH (secure shell) protocol.

### Hosting Services and Remote Repositories

Local repositories are found on a computer, while remote repositories are hosted on a hosting service in the cloud. To transfer data between a local repository and a remote repository on a hosting service, must connect and authenticate using either SSH or HTTPs. -- `git push, git clone, git fetch`and `git pull`. To use these commands and conenct to the remote repostiory U want to use before hand. Need prepare authentications.

#### Setting up a Hosting Service Account

Three main hosting services are `GitHub, GitLab, Bitbucket`.

1. By logging in to the hosting service via website
2. By making changes in local repository and uploading those changes to the remote repository on the hosting service

In both cases, you will need to *authentiation* - To control how logs in your hosing service account and who uploads changes to a remote repository. The answer for 2nd question is that you will have to authenticate through the protocol U choose to use. Will cover the HTTPs and SSH protocol.

#### Using HTTPs

For this in Git, uses a username and some sort of password to allow U to securely connect to remote repositories. GitHub and Bitbucket no longer allow this -- they require U to create another authentiction credential.

In GitHub, the authentication credential is called *personal access token*. 

- BitHub -- Email -- Password is personal access token
- Bitbucket -- Email -- App password

#### Using SSH - 

The SSH protocol uses a public and private SSH key pair to allow you to securely connect to remote repositories.

1. Create an SSH key pair on computer
2. Add the *private SSH key to SSH agent*
3. Add the *public SSH key to the hosting* service account

### Creating and publishing to a remote Repository

State of the Local repository -- At the start of this -- should have 3 commits and two branches in `rainbow`. 

Starting from a local Repostiory -- To start work on a Git Project from a local repository -- must create a local repository on a computer using the `git init`command and *make at least one commit.* Next, must create a remote repository on a hosting service. Finally, may upload data from the local to the remote repository.

In Git, use the term `push`or `pushing`to refer to the process of uploading data from a local repository to a remote repository.

Starting -- Can eigher find a remote repository that you want to work on or create a new.

#### Interaction betwen local and Remote -- 

Local and remote act separately -- when it comes to working with them -- important to understand that no interaction between them happens *automatically*.. No updates from the local to the remote will happen automatically, and no updates from the remote to the local either. There is *no live* connection between the two. Any changes in either will be the result of you explicitly exuecting commands.

#### Why Do we use Remote Repositories -- 

There are 3 main reasons why remote repositories are useful and important when working on a Git project.

- Easily back up
- Access a Git proj from multiple
- Collborate with others.

#### Creating a remote Repository with Data

1. Create the remote repository on the hosting service
2. Add a connection to the remote repository in the local repository
3. Upload data from the local repository to the remote repository.

When crate a remote repository on a hosting service, will give it a *remote repository* project name and the hosting service will provide a *remote repository URL*. The remote repository URL will automatically include the remote repository Porj name.

## Using `nil`channels

A common mistake while working with Go and channels is forgetting that `nil`channels can sometimes be helpful. So what re `nil`channels -- why should we care about them -- Start wtih a goroutine that creates a `nil`channel, and waits to receive a message -- like:

```go
var ch chan int
<-ch // won't panic, block forever
ch <- 0 // send, also blocks forever
```

Then what is the purpose of Go allowing messages to be received from or sent to a `nil` channel -- like: Will implement a `func merge(ch1, ch1 <-chan int) <-chan int`to merge two. Fore:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for v := range ch1 {
            ch <-v
        }
        for v := range ch2 {
            ch <-v
        }
        close(ch)
    }()
    return ch
}
```

The main issue for this version is that we receive from `ch1`and *then we receive from ch2*- means that we won’t receive from `ch2`until `ch1`closed. This just doesn’t fit our use case, as `ch1`may be open forever, want to receive from both channels simultaneously. So:

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func() {
        for {
            select {
            case v:= <-ch1:
                ch <- v
            case v:= <-ch2:
                ch <-v
            }
        }
        close(ch)
    }()
    return ch
}
```

So the `select`statement lets a gorotuine wait on multiple operations at the same time. Cuz wrap it inside a `for`loop, should repeatedly receive messags from one or the other channel.

One problem is that the `close(ch)`-- is unreachable -- looping over a channel using the `range`breaks when the channel is closed-- however the implemented `for/select`doesn’t catch when either `ch1`or `ch2`is closed. Even worse, if at some pont `ch1`or `ch2`is closed. here is what a reeciver of the merged channel will receive when logging the value like... 000, So a receiver will repeatedly receive an integer 0. Just note that *Receiving from a closed channel is a non-blocking opreation*.

```go
ch1 := make(chan int)
close(ch1)
fmt.Print(<-ch1, <-ch1) // 0 0 
```

Whereas we may expect this code to either panic or block, instead it runs and prints.. To check whether we receive a message or a closure signal, must do this -- 

```go
ch1 := make(chan int)
close(ch1)
v, open := <-ch1
fmt.Print(v, open) // 0 false
```

Meanwhile, also assign 0 to `v`cuz it’s the zero value of an integer.

Get back to second solution -- said that it doesn’t work very well if `ch1`is closed, fore cuz the `select`case is `case v:= <-ch1`-- will keep entering this case and publishing a zero integer to the merged channel.

- `ch1`is closed first, so have to receive from `ch2`until it is closed
- //...

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    ch1Closed := false
    ch2Closed := false
    go func() {
        for {
            select{
            case v, open:= <-ch1:
                if !open {
                    ch1Closed=true
                    break
                }    
                ch <-v
                
            case v, open := <-ch2:
                if !open{
                    ch2Closed=true
                    break
                }
                ch <-v
            }
            
            if ch1Closed & ch2Closed{
                close(ch)
                return
            }
        }
    }()
    return ch
}
```

For this, defined two Boolean `ch1Closed`and `ch2Closed`-- Once we receive a message from a channel, check whether it’s colsure signal -- if so, handle it by marking the channel as closed, after both channels are closed, we close the merged channel and stop the goroutine.

There is one major issue -- when one of two channels is closed, the for loop will act as *busy* -- Waiting loop, meaning it will just keep looping even though no new message is received in the other channel. We have to keep in mind the behavior of the `select`-- say `ch1`closed, when reach `select`again, it will wait for one of these 3 conditions happen:

1. `ch1`is closed
2. `ch2`has new message
3. `ch2`closed

If the first true, `ch1`closed, will always be valid, -- therefore, as long as we don’t receive a message in `ch2`and this channel isn’t closed, will keep looping over the first case, will lead to wasting CPU cycles, and must be avoided.

Could try to enhance the state machine part and implement **sub** `for/select`loops within each case. But this would make our code even more complex and harder to understand.

So it’s the right time to come back to `nil`channels -- Receiving from a `nil`channel will block forever, for this, insted of setting a Boolean after a channel is closed, will assign this channel to `nil`.

```go
func merge(ch1, ch2 <-chan int) <-chan int {
    ch := make(chan int, 1)
    go func(){
        for ch1!=nil || ch2 !=nil {
            select{
            case v, open:=<-ch1:
                if !open{
                    ch1=nil
                    break
                }
                ch <-v
                
            case v, open := ch2:
                if !open{
                    ch2=nil
                    break
                }
                ch <-v
            }
        }
        close(ch)
    }()
    
    return ch
}
```

First, loop as long as at least one channel is still open. Then fore, if `ch1`is closed, assign it `nil`. Hence, during the next loop iteration, the `select`statement will only wait for two conditions -- 

- `ch2`has a new message
- `ch2`is closed

`ch1`is no longer part of the euqation as it’s just a `nil`-- meanwhile, keep the same logic for `ch2`. This is the implementation we’ve been waiting for -- cover all the different cases. We have seen that *waiting or sending* to a nil channel is a blocking action, and this behavior isn’t useless.

### About Channel Size

When create a channel using the `make`-- the channel can be either unbuffered or buffered, Related to this -- two mistake happen fairly frequently -- Being confused about when to use one or the other -- and if we use a buffered channel, what size to use.

First, remember the core concepts, an unbuffered channel is a channel *without* any capacity, can be created by either omitting the size or providing a 0 size.

```go
ch1 := make(chan int)
ch2 := make(chan int, 0)
```

Using an unbuffered channel, the sender will block until the receiver receives data from the channel. Conversely, a buffered channel has a capacity, and it must be created with a size greater than or equal to 1-- 

`ch3 := make(chan int, 1)`

With a buffered, a sender can send messages while the channel isn’t full, once the channel is full, it will block until a receiver goroutines receives a message.

```go
ch3 := make(chan int, 1)
ch3 <-1
ch3 <-2 // block
```

Discuss the fundamental differences between these two channel types -- Channels are a concurrency abstraction to enable communication among goroutines. But what about sync -- in concurrency, Sync means we can guarantee that multiple goroutines will be in a known state at some point -- fore, a mutex providers sync cuz it ensures that only one goroutine can be in a *critrial section* at the same time.

- An unbuffered channel enables sync -- have the guarantee that two goroutines will be in a known state -- one receiving and another sending a message.
- A unbuffere channel doesn’t provide any strong sync -- indeed, a producer goroutine can send a message and then continue its execution if the channel isn’t full. *The only guarantee is tht a goroutine won’t receive a message before it is sent*.

It’s just essential to keep in mind this fundamental distinction -- Both Channel types enable communication, but only one provides synchronization, if need synchronization, must use unbuffered channels. Unbuffered channels may also be easier to reason about -- buffered channels can lead to obscure deadlocks that would be immediately apparent with unbuffered channels.

There are other cases where unbuffered channels are preferable. FORE in the case of a notification where the notification is ahndled via a channel closure -- here, using a buffered wouldn’t bring any benefits.

except 1, here is a list possible cases where we should use another buffer size -- 

- While using a worker pooling -- Like pattern, meaning spinning a fixed number of goroutines that need to send data to a shared channel.
- When using channels for rate-limiing problems. If need to enforce resource utilization by bounding the number of requests.

Except for cases described -- usually best to start with a default channel size of 1, and when unsure -- can still measure it using benchmarks. As with any topic, exceptions can be found -- the goal of this is n’t to be exhaustive but to give directions about what size -- Sync is a guarantee with unbuffered, not buffered.

## Common Dynamic Data

In some web apps there may be common dynamic data that want to include on more than one -- might want to include the name and profile picture of the current user, or a CSRF token. Begin t by dding a new `CurrentYear`field to the `templateData`struct just like:

```go
type templateData struct {
    CurrentYear int
    //...
}
```

And the next step is to add a `newTempalteData()`helper method to our application, which will return a `templateData`struct initialized with the current year like:

```go
func (app *application) newTemplateData(r *http.Request) *templateData {
    return &templateData {
        CurrentYear: time.Now().Year()
    }
}
```

Then update `home`and `snippetView`handlers to use the `newTempalteData()`helper like:

```go
func(app *application) home(w http.ResponseWriter, r *http.Request) {
    data := app.newTempalteData(r)
    data.Snippets= snippets
    app.render(w, http.StatusOK, "home.html", data)
}
```

Update the `base.html`to display the year -- 

```html
<a href="...">Go</a> {{.CurrentYear}}
```

### Custom template functions

To illustrate this, create a custom `humanDate()`which outputs datetimes in a ...

1. Need to create a `template.FuncMap`object containing the custom `humanDate()`func 
2. Need to use the `templateFuncs()`method to register this before parsing the templates.

```go
// Create a humanDate function returns a nicely formatted string
func humanDate(t time.Time) string {
    return t.Format("02 Jan 2006 a5 15:04")
}

// initialize a `template.FuncMap`object and store it in a global variable. This is essentially a string-keyed
// map which act as a lookup between the names of our custom template functions
var functions = template.FuncMap {
    "humanDate": humanDate,
}

func newTempalteCache()(map[string]*template.Template, error) {
    cache := map[string]*template.Template{}
    //...
    for _, page := range pages {
        name := filepath.Base(page)
        
        // The template.FuncMap must be registered with the template set before U
        // call the ParseFiles() method -- means must use the template.New() to create an empty
        // template set, then use the `Funcs()`to register the FuncMap
        ts, err := template.New(name).Funcs(functions).ParseFiles("...")
        //...
    }
    return cache, nil
}
```

```html
<td>{{humanData .Created}}</td>
```

### Middlewares

A common way of organizing this shared functionality is to set it up as *middleware* -- this is essentially some self-contained code which indpendently acts on a request before after U normal app handlers.

- An idiomatic pattern for building and using custom middleware which is compatible with `net/http`and many 3rd-party packages.
- How to create middleware which sets useful security headers on every HTTP response
- How to create middleware which logs the requests received by your application.
- How to create middleware which recovers panics so that they are gracefully handled by your application.
- How to create and use composable middleware chains to help manage and organize your middleware.

The basic idea of Go middleware is to insert another handler into its chain. The middleware handler executes some logic, like logging.. 

#### Pattern

```go
func myMiddleware(next http.Handler) http.Handler {
    fn := func(w http.ResponseWriter, r *http.Request) {
        //... execute custom logic
        next.ServeHTTP(w, r)
    }
    return http.HandlerFunc(fn)
}
```

Simplifying pattern

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request)) {
        //...
        next.ServeHTTP(w,r)
    }
}
```

#### Positioning the middleware

It’s just important to explain that where U position the middleware in the chain of handlers will affect the behavior of your application. And if U position your middleware before the `servemux`in the chain then it will act on every request that your application receives. 

`mymiddleware-> servemux -> App handers`

For -- that’s typically sth you would want to do for all requests. A good example of where this would be useful is middleware to log requests -- that’s typically sth you would want to do for *all* requests.

Alternatively, you can position the middleware after the servemux in the chain -- By wrapping a specific app handler.

`servemux-> mymiddleware-> application handler`

For authorization middleware.

### Setting security headers

Put the pattern we learned in the previous to use -- make our own middleware which automatically adds the following http security headers to every response -- 

- `Content-Security-Policy` -- CSP -- Headers are used to restrict where the resources for your web page can be loaded from. Setting a strict CSP policy helps prevent a variety of cross -- site scripting, clickjacking, and code-injection attacks.
- `Referrer-Policy`-- used to control what information is included in a `Referer`header when a user naviates away from your web page. `origin-when-cross-origin`-- the full URL will be included for `same-origin requests`-- but for all other requests info like URL path and any quer string will be stripped out.
- `X-Content-Type-Options: nosniff`-- instructs to NOT MIME-type sniff the content-type of the response.
- `X-Frame-Options: deny`-- help prevent clickjacking
- `X-XSS-Protection:0`-- disable the blocking of cross-site scripting attacks. `X-XSS-Protetion: 1; mod=block;`

```go
func secureHeader(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Security-Policy",
			"default-src 'self'; style-src 'self' fonts.googleapis.com; font-src fonts.gstatic.com")
		
		w.Header().Set("Referrer-Policy", "origin-when-cross-origin")
    })
}
```

For the policy like `secureHeader-> serveMux -> application handler` for now:

```go
func(app *application) routes() http.Handler {
    mux := http.NewServeMux()
    fileServer := http.FileServer(http.Dir("..."))
    mux.Handle("/static/", http.StripPrefix("/static", fileServer))
    mux.HandleFunc("/", app.home)
    //...
    // Pass the servemux as the `next` parameter to the secureHeaders middleware
    return secureHeaders(mux)
}
```

So, just makes sure that you update the signature of the `routes()`method so that it returns a `http.Handler`.

#### Flow of control

It’s important to know that when the last handler in the chain returns, control is passed back up the chain in the reverse direction -- so when our code is being executed the flow of control actually look like:

secureHeaders-> serveMux -> app handlers -> serveMux ->secureHeaders

In any middleware handler, code which comes before `next.ServeHTTP()`will be executed on the way down the chain, and any code after `next.ServeHTTP()`or in a deferred function, will be executed on the way back up.

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // any code here will execute on the way down the chain
        next.ServeHTTP(w,r)
        // any code here will execute on the way back up the chain
    })
}
```

#### Early returns

Another thing to mentions is that if call `return`in your middleware function *before* U call `next.ServeHTTP()`-- then the chain will stop being executed and control will *flow back upstream*.

```go
func myMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // if the user isn't authorized 
        if !Authorized(r) {
            w.WriteHeader(http.StatusForbidden)
            return
        }
        
        // otherwise, call the next handler in the chain
        next.ServeHTTP(w,r)
    })
}
```

### Request Logging

Going to use the *information logger* that we created to record the IP address of the user. 

```go
func (app *application) logRequest(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResposneWriter, r *http.Request) {
        app.infoLog.printf("%s - %s %s %s", r.RemoteAddr, r.Proto, r.Method,
                           r.URL.RequestURI())
        next.ServeHTTP(w,r)
    })
}
```

This is just perfectly valid to do. Our middleware method has the same signature as before, but cuz it is a method against `application`it *also* has access to the handler dependencies including the information logger. Place the logger first just like:

```go
func(app *application) routes() http.Handler {
    mux := http.NewServeMux()
    fileServer:=...
    mux.HandleFunc("/", app.home)
    //...
    return app.logRequest(secureHeader(mux))
}
```

### Panic receovery

In the simple Go application, when your code panics it will result in the app being terminated straight away -- Go’s HTTP server assumes that the effect of any panic is *isolated* to the goroutine serving the active HTTP request.

Specially, following a panic our server will log a stack trace to the server error log, unwind the stack for the affected goroutine and close the underlying HTTP connection. But -- it **won’t** terminate the application, So importantly, any panic in your handlers won’t bring down your server.

# Flexbox

Explore the other forms of layout available -- flexbox, grid and positioning. Flexbox is a method for laying out elements on thepage -- primarily used for arranging elements in a row or clumn -- also provides a simple solution to the historically troublesome problems of vertical centering and equal-height columns.

Show you the basic principles of the flexbox layout -- 

### principles

begins with `display`prop -- `display: flex`to an element turns it into a *flex container* -- its **direct** children turn into *flex items* -- align side by side, left to right, all in one *row*. And the flex container fills the available width like a block element, but the flex items may not necessarily fill the width of their flex container.

Note -- can also use `display: inline-flex`-- creates a flex container that behaves more like an `inline-block`rather than a block. Flows inline with other inline elements, but it *won’t automatically grow to 100% width*. Flex items within it generally behave the same as with `display: flex`-- .

Flexbox is unlike fore `inline, inline-block`-- whcih affect only the elements they applied to. Instead, a flex container asserts control over the layout the elements within.

The items are placed along a line called a *main axis* -- goes from the *main start* to the *main end* -- Prependicular to the main axis is the *cross axis* -- goes from the top to bottom.

Conceptually, the main axis and cross axis are similar to inline and block directions.

```html
body>
<div class="container">
  <header>
    <h1>Ink</h1>
  </header>
  <nav>
    <ul class="site-nav">
      <li><a href="/">Home</a></li>
      <li><a href="/features">Features</a></li>
      <li><a href="/pricing">Pricing</a></li>
      <li><a href="/support">Support</a></li>
      <li class="nav-right">
        <a href="/about">About</a>
      </li>
    </ul>
  </nav>
  
  <main class="flex">
    <div class="column-main tile">
      <h1>Team collboration done right</h1>
      <p>Thousands of teams from all over the world
      trun to <b>Ink</b> to communicate and get things done.</p>
    </div>
    
    <div class="column-sidebar">
      <div class="tile">
        <form class="login-form">
          <h3>Login</h3>
          <p>
            <label for="username">Username</label>
            <input id="username" type="text" name="username" />
          </p>
          <p>
            <label for="password">Password</label>
            <input id="password" type="password" name="password" />
          </p>
          <button type="submit">Login</button>
        </form>
      </div>
      
      <div class="tile centered stack">
        <small>Starting at</small>
        <div class="cost">
          <span class="cost-currency">$</span>
          <span class="cost-dollars">20</span>
          <span class="cost-cents">.00</span>
        </div>
        <a class="cta-button" href="/pricing">
          Sign up
        </a>
      </div>
    </div>
  </main>
</div>
</body>
```

This just includes a link to the css -- like:

```css
*, ::before, ::after {
  box-sizing: border-box;
}

body {
  margin: unset;
  background-color: #709b90;
}

.stack > * + * {
  margin-block-start: 1.5em;
}

.container {
  max-inline-size: 1080px;
  margin-inline: auto;
}
```

#### Building the basic flexbox menu

For this exmaple, want the navigational menu to look like -- Should just consider which element needs to be the flex container -- keep in mind that its child elements will become the flex items -- in the case of page menu, the flex container should be the undered list. it’s child items -- should be the flex items like:

```css
.site-nav {
  display: flex;
  padding: unset;
  list-style-type: none;
  background-color: #5f4b44;
}

.site-nav > li >a {
  background-color: #cc6b5a;
  color: white;
  text-decoration: none;
}
```

#### Adding padding and spacing

Our menu -- flesh it out a bit with some padding -- like:

```css
.site-nav{
  padding:.5rem;
}

.site-nav a {
  display: inline-block; /*makes link block-level so adds to parent height */
  padding: .5em 1em;
}
```

You will notice that you made the links a display block -- if they were to reamin inline -- the height they’d contricute to their parent would be derived from their inline height. 

Need also to add space between the menu items -- can do this with margins -- but `flexbox`has a special property jsut for this called `gap`.

Additionally, flexbox allows to use the `margin:auto`to fill all available space between flex items.

```css
:root {
  --gap-size: 1.5rem;
}

.site-nav {
  gap: var(--gap-size);
}

.site-nav> .nav-right{
  margin-inline-start: auto;
}
```

Applied the `auto`margin to only one element.

### Flex item sizes

When it comes to sizing flexbox elements, can use the familar `width`and `height`properties. but flexbox provides more optoins for sizing than these properties alone can accomplish -- `flex`property -- controls the size of *flex items* along the *main axis*. Fore add the styles -- this provides a white background ...

```css
.tile{
  padding: 1.5em;
  background-color: #fff;
}

.flex {
  display: flex;
  gap: var(--gap-size);
}
```

Now your content is divided into two columns -- on the left is the larger.. Haven’t done anything yet to specify the width of the two columns -- so they size themselves *naturally* based on their content.

The `flex`prop -- is applied to the flex items -- gives U several options -- apply the most basic use case first to get familiar with it. You will use the `column-main`and `column-sidebar`classes to target the columns, using the `flex`to apply widths of the 2/3 and 1/3 like:

```css
.column-main {
  flex: 2;
}

.column-sidebar {
  flex: 1;
}
```

Now the two columns grow to fill the space, so together they are the ame width as the `nav`bar. And the `flex`property is just a shorthand for 3 different sizing properties to their default values -- for this, leaving the other two to their default values -- `1`and 0% for now just like:

```css
flex-grow:2;
flex-shrink:1;
flex-basis:0%
```

#### Flex Basis

The *flex basis* defines a sort of starting point for the size of an element -- *initial main size* -- the `flex-basis`property can be set to any value that would apply to `width`, including values in px, ems, or percentages. its initial value is `auto`-- whcih means the browser will look to see if the lemeent has a `width`decalred and if so, the browser uses that size, if not -- determines the element’s size naturally by the contents.

Once this initial main size is established for each item -- they may need to grow or shrink to fit the flex conainer along the main axis. where the `flex-grow`and `flex-shrink`come in.

#### Flex grow

Once `flex-basis`is computed for each item -- they will add up to some width. This width may not necessarily fill the width of the container. The remaining space will be consumed by the *flex items* based on their `flex-grow`values, which are always specified as non-negative integers. 0 won’t grow.

#### Flex shrink

The `flex-shrink`follows similar principles as `flex-grow`. After determining the intiial main size of the flex items, they could exceed the size available in the flex container -- without the `flex-shrink`-- this would result in overflow and the `flex-shrink`for each item indicates whether it should shrink to prevent overflow. Items with a higher than 0 will shrink until there is no overflow.

As an alternate approach to page, you could achieve similar column sizing by relying on `flex-shrink`. Fore:

```css
.column-main{
    flex: 66.67% /* 1 1 66.67*/
}
```

## Adding form data validation

At the moment, any data can be entered into the `input`elements in the form, data validation is essential in web apps cuz users will enter .. Angular provides an extensible system for validating the content -

`email rquired minlength maxlength min max pattern`

And Angular builds on these properties with some additional faturs -- 

```html
<div class="p-2">
  <div class="bg-info text-white mb-2 p-2">
    Model Data : {{jsonProduct}}
  </div>

  <form (ngSubmit)="addProduct(newProduct)">
    <div class="mb-3">
      <label>Name</label>
      <input class="form-control"
             name="name"
             [(ngModel)]="newProduct.name"
             required
             minlength="3"
             pattern="^[A-z ]+$" />
    </div>

    <button class="btn btn-primary mt-2" type="submit">Create</button>
  </form>
</div>
```

Angular requires elements being validated to define the `name`attribute -- which is used to identify the element in the validation system -- since this `input`element is being used to capture the value of the `Product.name`property, the `name`just set to `name`.

When using a `form`element, the convention is to use an event binding for a special event called `ngSubmit`like:
`<form (ngSubmit)="addProduct(newProduct)">`

The `ngSubmit`binding handles the `form`'s `submit`event -- can just achieve the same effect binding to the `click`event on the individual `button` elements within the `form`if prefer.

#### Styling elements using validatoin class

Once you have saved the changing -- can see : `ng-prinstine ng-invalid ng-touched`classes -- is assigned provide details of its validation state. There are 3 pairs of validation classes, which are -- elements will always be members of one class from each pair, for a total of 3 classes. The same classes are applied to the `form`element to show the overall validation status of all the elements it contains. At the status of the `input`element changes, the `ngControl`directive switches the classes automatically for both the individual elements and the form element.

- `ng-untouched ng-touched`-- If has not been visited or visited
- `ng-prisitine ng-dirty`-- prinstine if its content have not been changed by the user and dirty otherwise
- `ng-valid ng-invalid`-- If meet the criteria or not
- `ng-pendin`-- for async validation.

```css
input.ng-dirty.ng-invalid {
  border: 2px solid #ff0000
}

input.ng-dirty.ng-valid {
  border: 2px solid #6bc502
}
```

#### Displaying field-level Validation Messages

Using colors to provide validation feedback tells the user that sth is wrong but doesn’t provide any indication of what the user should do about it. The `ngModel`directive provides access to the validaton status of the elements it is applied to.

```html
<input class="form-control"
       name="name"
       [(ngModel)]="newProduct.name"
       #name="ngModel"
       required
       minlength="3"
       pattern="^[A-z ]+$" />

<ul class="text-danger list-unstyled mt-1"
    *ngIf="name.dirty && name.invalid">
    <li *ngIf="name.errors?.['required']">
        U must enter a product name.
    </li>
    <li *ngIf="name.errors?.['minlength']">
        Product names must be at least
        {{name.errors?.['minlength'].requiredLength}}
    </li>
    <li *ngIf="name.errors?.['pattern']">
        Product names can only contain letters and spaces.
    </li>
</ul>
```

To get the validation working, have to create a template reference variable to access the validation state in an expression, which like `#name="ngModel"`. This use of an `ngModel`value is a llittle confusing -- it is a feature provided by the `ngModel`directive to give access to the validation status -- make more sense once you have read the .

- `path`-- returns the name of the element
- `valid invalid prinstine dirty touched untouched`
- `errors`-- returns a `ValidationErrors`object whose properties correcpond to each attribute for which there is a validtion error.
- `value`-- returns the `value`of the element -- used to when defining custom validation rules.

And each property defined by the `errors`object returns an object whose properties provide details of why the content has failed the validation check for its attribute.

`email, required`and:

- `minlength.requiredLength`-- Just returns the numbe of characters required to satisfy the `minLength`attribute.
- `minlenth.actualLength`
- `min.actual min.min max.acutal max.max`
- `pattern.requiredPattern`-- returns the REGEXP that has been specified using the `pattern`attribute
- `pattern.actualValue`-- returns the content of the element.

#### Using the component to display validation messages

Defining separate elements for all possible validation errors quickly becomes verbose in complex forms. So a better approach is to add logic to the component to prepare the validation messages in a method, which can then be displayed to the user through the directive.

```ts
getMessages(errs: ValidationErrors | null, name: string): string[] {
    let messages: string[] = [];
    for (let errName in errs) {
        switch (errName) {
            case 'required':
                messages.push(`U must enter a ${name}`);
                break;
            case 'minlength':
                messages.push(`A ${name} must be at least
${errs['minlength'].requiredLength} characters`);
                break;
            case 'pattern':
                messages.push(`The ${name} contains illegal characters`);
                break;
        }
    }
    return messages;
}

getValidationMessages(state: NgModel, thingName?: string) {
    let thing: string = state.path ?.[0] ?? thingName;
    return this.getMessages(state.errors, thing);
    }
```

Just note that the `getValidationMessages()`-- using the `NgModel`object’s `path`property as the descriptive string if an argument isn’t received when the method is invoked.

```html
<ul class="text-danger list-unstyled mt-1"
    *ngIf="name.dirty && name.invalid">
    <li *ngFor="let error of getValidationMessages(name)">
        {{error}}
    </li>
</ul>
```

#### Validating the entire form -- 

Displaying validation error messages for individual fields is useful cuz it helps emphasize where problems need to be fixed. Can also be useful to validate the entire form. Care must be taken not to overwhelm the uer with error messages until they try to submit the form, at which point a summary of any problems can be useful.

```ts
formSubmitted: boolean = false;

submitForm(form: NgForm) {
    this.formSubmitted = true;
    if (form.valid) {
        this.addProduct(this.newProduct);
        this.newProduct = new Product();
        form.resetForm();
        this.formSubmitted = false;
    }
}
```

The `formSubmitted`property will be used to indicate whether the form has been submitted and will be used to prevent validation of the entire form until the user has tried to submit.