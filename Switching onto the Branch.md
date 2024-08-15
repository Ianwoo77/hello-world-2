# Switching onto the Branch

The first step of doing a merge is to switch onto the target branch. For this, you are going to merge `feature`into `main`, so need to switch onto the `main`branch.

1. It changes the `HEAD`pointer to the branch you are switching onto
2. Populates the staging area with all files and directories that are part of the commit you are switching onto.
3. Copies the contents of the staging area into the working directory.

#### Git protects U from losing uncommitted changes

If Git *detects* that switching branches will cause U lose uncommitted changes in working directory, will stop U from switching brances and present U with an error message

If Git had allowed U to switch branches, then the version of the file in the working directory that mentions .. And the `git status`command indicates that your working directory no longers has any modified files.

#### Switching branches changes files in the working directory

For now, the version of the file in the working directory and staging area is the one that mentions ... If `git switch main`executed:

- The version of the file in code before U switched onto the `main`..
- On the `main`and it points to the orange commit v2
- v3 of file has been replaced by v2 of the file.,

Viewing a list of all commits

`git log --all` shows a list of commits in reverse order for **all** branches.

#### Using the `git merge`to execute a merge

1. Make sure your text editor is open next to command line, see both of them when execute the upcoming commands
2. `git merge feature` executing
3. `git log`

Note:

- The `git merge`output mentions Updating <Hash> and *Fast-forward* -- This tells the Git updated the commit the `main`branch points to.
- The `git log`shows that `main`points to the last commit.
- U merged the `feature`branch into the `main`.

U merged feature into the `main`-- but in `Git`, merging a branch does not delete the branch. Must explicitly delete a branch if you no longer want to use it.

### Checking our Commits

One of the other things u can do with `git checkout`commandis to *check out commits*. What if U want to look at an *older* version of your proj. There is currenty no branch pointing to the orange commit. But:

```sh
git checkout <commit_hash> # checkout a commit
```

When U do this, the `git checkout`will carry out 3 actions that are similar to the ones-- 

1. Changes the `HEAD`to point to the *commit* U are switching to.
2. It populates the staging area with all the files and directories that are part of the commit U are switching onto.
3. It copies the contents of the staging area into the working directory.

For this, the main difference is that in (1) the `HEAD`will pont directly to a commit instead of pointing to a branch.

```sh
git checkout 20e3dff
```

This means that you will be in sth that Git calls **detached HEAD steate** -- allows to look any commit - or in otherwords, any version of your project.

```sh
git log --all
```

What to notice is-- 

- In step 2 -- the `git checkout`output tells U that *U are in `Detached Head`state*. The output also refers to a modification of the `git switch`command
- `git log --all`output shows u that `HEAD`now points to the orange commit.
- The version of the file in working directory is the version that is part of the `orange` commit.
- The *staging area* is V2. -- orange for the proj

U just observed what is like to check out a commit directly instead of checking out a branch.

```sh
git switch main
git log
```

- The version of the file in working directory is the version that is part of `yellow`
- Back on the `main`.

### Creating a branch and switch onto it on One Go

If U want to create a new branch to retain commits U crate, using `-c`with the switch. This is because it is actually possible to use `git switch`or `git checkout`to create a branch and switch onto it in one go.

```sh
git switch -c <new_branch_name>
git checkout -b <new_branch_name> # if use the old checkout command
```

## Goroutines and loop variables

Mishandling goroutines and loop variables is probably one of the most common mistakes made by Go developers when writing concurrent apps. like:

```go
s := []int{1,2,3}
for _, i := range s {
    go func() {
        fmt.Print(i)
    }()
}
```

As a remainder, a closure is a *function value* that references variables from outside its body. It doesn’t capture the values when the goroutine is created, instead, all the goroutines refer to the exact same variable. Cuz there is no guarantee when each goroutine will start and complete, the result varies.

So, what are the solution if want each closure to access the value of `i`when the gorotuine is created -- the first option -- if want to keep using a closure, involves creating a new variable -- 

```go
for _, i := range s{
    var := i
    go func(){
        fmt.Print(val)
    }()
}
```

In each iteration, create a new local `val`variable. This captures the current value of `i`before the goroutine is created.

```go
for _, i := range s {
    go func(val int){
        fmt.Print(val)
    }(i)
}
```

The func doesn’t reference `val`as a variable from outside its body. `val`now part of the func input.

### behavior using select and channels 

One common mistake made by Go developers while working with channels is to make wrong assumption about how `select`behaves with multiple channels. Fore, imagine that want to implement a goroutine that needs to receive from two channels -- 

- `messageCh`for new messages to be processed
- `disconenctCh`to receive notifications coveying disconnects.

Of these, want to priortize `messageCh`-- if a disconnection occurs, want to ensure that we have received all the messages before returning.

```go
for{
    select{
    case v:= <-messageCh:
        fmt.Println(v)
    case <-disconnectCh:
        //...
        return
    }
}
```

If one or more of the communications can proceed, a single one that can proceed is chosen via unifom *pseudo-random* selection. Note that unlike the `switch`-- where the first case with a match wins -- the `select`selects *randomly* if multiple options are just possible.

To prevent *possible starvation* -- supose the first possible communiation chosen is based on the source order, May fill into a situation where we only recevie from one channel cuz of the faster sender -- to prevent this, the language designers decided to use a random selection.

And there are different possibilities if want to receive all the messages before returning in case of a disconnection.

- Making `messageCh`a unbuffered channel -- cuz the *sender goroutine blocks* until the receiver is ready

  ```go
  for i:=0; i<10; i++ {
      messageCh<-i // blocks if case v:= messageCh: not ready
  }
  disconnectCh <-struct{}{} // so guarantee the order
  ```

- Using a single channel.

And if fall into the case where we have multiple producer gorotuines, May be impossible to guarantee which one writes first. Whether we have unbuffered or single channel. It will lead to race condition among the producer goroutines. 

1. Receive from either `messageCh`or `disconnectCh`
2. If a disconnection is received - Read all existing messages in `messageCh`if any, then return

```go
for {
    select {
    case v:= <-messageCh:
        print(v)
    case <-disconnectCh:
        for {
            select {
            case v:= <-messageCh:
                print(v)
            default:
                print("return")
                return
            }
        }
    }
}
```

This solution uses an inner `for/select`with two cases -- one on `messageCh`and a `default case`. Using `default`is chosen *only if* none of the other cases match. In this case, it means that we will return only after we have received all the remaining messages in `messageCh`. Here, as long as messages remain in `messageCh`, `select`will always prioritize the first case over `default`. Once we have received all the messages from `messageCh`, `select`does not block and choose the `default`case, hence, we return and stop the goroutine.

This is a way to *ensure* that we receive *all* the remaining messags from a channel with a receiver on multiple channels. If a `messageCh`is sent after goroutine has returned -- missing of course -- when using the `select`with multiple channels, must remember that if multiple options are possible, the first case in the source order doesn not automatically win. Instead, Go selects randomly -- so there is no guarantee about which option will be chosen. To overcome this behavior, in the case of a single producer goroutine, we can use either unbuffered channels or a single channel.

### Using Notification Channels

Channels are a mechanism for communiating acorss goroutiens via signaling. A singal can be either with or without data -- but for Go programmers, it’s not always straightforward how to tackle the latter case. Fore, create a channel that will notify us whenever a certain disconnection occurs, one idea to handle it as a `chan bool`.

`disconnectCh := make(chan bool)`

Interact with an API that provides us with such a channel -- It’s a channel of Booleans -- can receive either `true`or `false`messages. So, the idiomatic way to handle it is a channel of empty structs `chan struct{}`. In Go, an empty struct is a struct without any fields -- Regardless of the architecture, it occupies *zero bytes of storage*.

```go
var s struct{}
fmt.Println(unsafe.Sizeof(s))
```

Note -- for this, why not use an empty interface `any`or `interface{}`-- cuz an empty interface *isn’t free* -- it occupies 8 bytes on 32-bit architecture and 16 bytes on 64-bit architecture.

An empty struct is a *de facto* std to convey an absence of meaning -- fore, if we need a hash set structure, we should use an empty struct as value `map[K]struct{}`-- Applied to channels, if want to create a channel to send notifications without data, the appropriate wya to do so in Go is a `chan struct{}`. One of the best-known utilizations of a channel of empty structs come with Go Context.

A channel ccan be with or without data. If we want to design an idiomatic API in regard to Go standards, remainder that a channel without data should be expressed with a `chan struct{}`type.

## Template actions and functions

In this -- going to look at the tempalte actions and fucntion that Go provides. Three which can use to control the display of dynamic data -- `{{if}} {{with}} {{range}}`. All have a `{{else}}`clause and `{{end}}.`

- For all three actions the `{{else}}`clause is optional
- The `empty`values are `false`, 0, any `nil`pointer or interface value, and any array, slice, map, or string of length zero.
- It’s important to grasp the `with`and `range`actions change the value of `dot`.

And the `html/template`package also provides some template functions which U can use to add extra logic to your templates and control what is renedered at runtime.

- `eq, ne, not, or` like `{{eq .Foo .Bar}}`
- `{{index .Foo i}}`-- yields the value of `.Foo`at index `i`, the underlying type of `.Foo`must map slice array.
- `{{$bar := len .Foo}}`-- assign the length of `.Foo`to the template variable $bar

The final row is an example of declaring a template `variable`-- Template variables are particularly useful if you want to store the result from the function and use it in multiple places.

#### Using the `with`action

```html
{{define "title"}}Snippet #{{.Snippet.ID}} {{end}}

{{define "main"}}
	{{with .Snippet}}
	<div...>
		<strong>{{.Title}}</strong>
	</div...>
{{end}}
{{end}}
```

#### Using the `if`and `range`

```html
{{if .Snippets}}
<table>
    <tr>
    	<th>Title</th>
        <th>Created</th>
        <th>ID</th>
    </tr>
    {{range .Snippets}}
</table>
```

Controlling loop behavior -- note that within a `{{range}}`action can use the `{{break}}`and `{{continue}}`

```html
{{range .Foo}}
    {{if eq .ID 99}}
    {{continue}}
    {{end}}
{{end}}
```

### Caching templates

It’s a good time to make some optimizations to our codebase, there are two main issues -- 

1. Each and every time render a web page, our app reads and parses the relevant templates using the `template.ParseFiles()`function, could avoid this duplicated work by parsing the file once -- when starting the app, and storing the parsed templates in an in-memory *cache*.
2. There is duplicated code.

Tackle the first point -- create an in-memory *map* with the type `map[string]*template.Template`to cache the parsed templates. like:

```go
func newTempalteCache()(map[string]*template.Template, error) {
    // Initialize a new map act as the cache
    cache := map[string]*template.Template{}
    
    // ussing the `filepath.Glob()`to get a slice of all filepaths that match the patern
    // will give a slice of all filepaths for our app `page` template
    pages, err := filepath.Glob("./ui/html/pages/*.html")
    if err != nil {
        return nil, err
    }
    
    for _, page := range pages {
        // extract the file name from the full filepath
        name := filepath.Base(page)
        
        // Create a slice containing the filepaths for our base template
        files := []string{
            //.. file names for partial and base
            page,
        }
        
        // parse the files into a template set
        ts, err := template.ParseFiles(files...)
        if err != nil {
            return nil, err
        }
        
        // add the template set to the map
        cache[name]=ts
    }
    // return the map.
    return cache, nil
}
```

Then the next step is to initialize this cache in the `main`and make it available to our handlers as a DI.

```go
// Add a templateCache field to the app struct
type application struct {
    errorLog *log.Logger
    infoLog *log.Logger
    snippets *models.SnippetModel
    templateCache map[string]*template.Template
}

func main(){
    //...
    // initialize a new template cache...
    templateCache, err := newTempalteCache()
    if err != nil {
        errorLog.Fatal(err)
    }
    
    // And add it to the application dependencies
    app := &application {
        //...
        templateCache: templateCache,
    }
    //...
}
```

At this point, we just got an in-memory cache of the relevant template set for each of our pages, and our handlers have access to this cache via the `application`struct.

For the duplicated code, create a helper method so that can easily render the templates from the cache.

```go
func (app *application) render(w http.ResponseWriter, status int, page string, 
                               date *templateData) {
    ts, ok := app.templateCache[page]
    of !pk {
        err := fmt.Errorf(...)
        app.serveError(w, err)
        return
    }
    
    // Write out the provided HTTP
    w.WriteHeader(status)
    
    err := ts.ExecuteTemplate(w, "base", data)
    if err != nil {
        app.serveError(w, err)
    }
}
```

For the `home`handler like:

```go
func (app *application) home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/"{
        app.notFound(w)
        return
    }
    
    snippets, err :=app.snippets.Latest()
    if err != nil {
        app.serverError(w, err)
        return
    }
    
    // use the new render helper
    app.render(w, http.StatusOK, "home.html", &templateData {Snippets: snippets})
}
```

#### Automatically parsing partials

Before move on, make the new `newTemplateCache()`-- so that it automatically parses all template in the `partials`folder.

```go
// Calls ParseGlob() on this template set to add any partials
ts, err := template.ParseFiles("...html")
if err != nil {
    return nil, err
}
ts, err = ts.ParseGlob(".../partials/*.html")
if err != nil {
    return nil, err
}

// Then call the ParseFiles() on this template set to add the page template
ts, err = ts.ParseFiles(page)
if err != nil {
    return nil, err
}

//... Add the mteplates set as normal
```

### Catching runtime errors

As soon as begin adding dynamic behavior to HTML templates there is a risk of encountering runtime errors. For in the view template add `{{len nil}}`, whish should generate an error at runtime, cuz in Go the value `nil`does not have a length prop. If not be handled, our app has thrown an error, but the user has wrongly been sent a 200OK response. They have received a half-complete HTML page.

To fix this, need to make the template render a *two-stage* process. First, should make a *trial* render by writing the template into a *buffer* -- if this fails, Can respond to the user with an error message. But if it works, can then write the conetnts of the buffer to our `http.ResponseWriter`. 

#### Creating a `bytes.Buffer`

Can create a `bytes.Buffer`either by using its zero value or `NewBuffer`or `NewBufferString`.

```go
func (app *application) render(w http.ResponseWriter, status int, page string, data *templateData){
    ts, ok := app.templateCache[page]
    if !ok{
        //...
        return
    }
    
    // Initialize a new buffer
    buf := new(bytes.Buffer)
    
    // Write the template to the buffer, instead of straight to the w, 
    // if there is an error, call helper
    err := ts.ExecuteTemplate(buf, "base", data)
    if err != nil {
        app.serveError(w, err)
        return
    }
    
    w.WriteHeader(status)
    buf.WriteTo(w)
}
```

Restarting the app and trying making the same requset -- should now get a proper error message and 500 Internel Server Error response.

# Box Model

DEF -- the *box model* refers to the parts of an element and the size they contribute to their element. NOTE Top and bottom margins and padding behave a little unusually on *inline* elements -- they will still increase the height of the element, but they will not increase the height that the inline element contricutes to its container.

#### outline -- the other type of border

Similar to a border, can also add an `outline`to an element -- this behaves much like a border but does not add the element’s size and is not part of the box model. It is placed ouside the border, *overlapping the margin*. It will not change the size or position of the element. `outline`is shorthand for `outline-color, outline-style`and `outline-width`-- fore, `outline: orange solid 2px`.

#### Avoiding magic numbers

Sometimes when encounter problems like this, the temptation can be filldel with the values until it works. fore, 66% is known as *magic number* -- instaed of using a desried value, found it by making haphazard changes to the styles until U got the result U wanted.

#### Adjusting the box model

The default box model tends to cause problems with the sizing and alignment of element on the page. Instead, you will want your specified widths to include the padding and borders. CSS allows U to adjust the box model behavior with its `box-sizing`property.

By default, the `box-sizing`is set to the `content-box`-- Any height or width U sepcify sets the size of only the content box - can assign a value of the `border-box`to the box sizing instead. That way, the `width, height, inline-size, block-size`properties set the combined size of the content, padding and border.

```css
.page-header h1 {
  box-sizing: border-box;
}
```

#### Using universal border box sizing

Have made box sizing more intuitive for this one element, -- will surely run into other elements with the same problem. It should be nice to fix it once, universally for all elements, so won’t have to think about this adjustment again. like:

```css
*, 
::before,
::after {
    box-sizing: border-box;
}
```

After applying this to the page, `height`and `width`will always specify the actual height and width of an element.

### Element Height

Working with the hegiht (default block size) of elements can be tricky -- normal document flow is designed to work with a constrined width and unlimited height. The height of a container is organically determined by its content, not the container itself.

#### Controlling overflow behavior

When explicitly set an element’s height, U run the risk of its contents *overflowing* the container. This happens when the content doesn’t fit the specified constraint and renders outside the parent element.

Can control the exact behavior of the overflowing content with the `overflow`property -- 

- `visible`-- default
- `hidden`-- Content that overflows is clipped and won’t be visible.
- `clip`-- similar to `hidden`but programmic scrolling is also disabled.
- `scroll`-- Scollbars are jsut added to the container so the user can scroll to see the remaining content.
- `auto`-- added to the container only if overflow.

### Negative Margins

Note that unlike the padding and border, can assign a negative value to margins.  The exact behavior of a negative margin depends on which side of the element you apply it to. Like:

```css
.container {
    max-width: 1080px;
    margin-inline: auto;
}

.expanded-child {
    margin-inline: -2em; /*cause the element to widen beyond its container in both directions*/
}
```

### Collapsed margins

When top/bottom are adjoining, they overlap -- combining to form a single margin -- this is referred to as *collpasing*. The space below the header in this is the result of callapsed margins.

#### Collapsing between text

The main reason for collapsed margins has to do with the spacing of blocks of text. Fore some, applied by the user-agent stylesheet. And the size of the collapsed margin is equal to the largest of the joined margins. In this case, the heading has a bottom margin of 19.92px and the paragraph hs a top margin of 16px.

#### Callapsing multiple margins

Elements don’t have to be adjacent siblings for their margins to collapse, even if U wrap the paragraph inside an extra `div`-- as in the following listing, the visual result will be the same. fore:

```html
<main class="main">
	<h2>
        Come join us!
    </h2>
    <div>
        <p>
            //...
        </p>
    </div>
</main>
```

In this case, 3 different margins are colapsing together. The bottom margin of the `h2`and the top margin of the `div`, and the top margin of the `p`. The computed values of these are 19.92, 0, and 16px, respectively.

Margin collapsing occurs with only top and bottom margins -- left and right margins don’t collapse. Collapsed margins act as a sort of person space bubble -- if two people standing at a .. 

#### Collapsing outside a container

An element’s margin collpsing outside its container typically produces an undesirable effect if the *container has a backgournd*. For this, margins don’t always collapse exactly to the spot where U want. Fortunately, there are a number of ways to prevent this. 

Note, -- if add top and bottom *padding* to the header, the margins inside it won’t collapse to the outside.

```css
page-header h1 {
  max-inline-size: var(--column-width);
  margin: 0 auto;
  padding: 1em 1.5em;
}
```

So, *any time* u see unexpected spaces above or below containers, or you see text pressed up against the top or bottom of its container, margin collapsing is most likely the cause.

- Applying `overflow: auto`-- or others other than `visible`-- to the container prevents margins insdie the container from collapsing with those outside the container.
- Adding border or padding between two margins stop them from collapsing.
- margins won’t collapse to the outside of a container that is an inline block, floated, or absolute fixed position.
- If using `flexbox`-- margins won’t collapse between elements that are part of the flex part.

### Spacing elements within a container

```css
.social-links {
  max-inline-size: 25em;
  padding: 1em 1.5rem;
  background-color: #fff;
  border-radius: 0.5em;
}

.button-link {
  display: block;
  padding: .5em;
  color: #fff;
  background-color: var(--brand-color);
  text-align: center;
  text-decoration: none;
  text-transform: uppercase;
}
```

Still need to figure out the spacing between them -- without margins, they will stack directly atop one another. U have options -- could give them separate top and bottom margins or both, where margin collapsing would occur between the two buttons.

For this still a problem -- the margin needs to work in conjunction with the container’s padding. Margin plus padding creates too much space -- Can fix this a mumber of ways -- can just:

```css
.button-link + .button-link {
  margin-block-start: 1.5em;
}
```

Using the `+`combinator like this is a helpful pattern that U can use in a variety of scenarios to space a series of elements within a container.

#### Considering changing content

```html
<a href="/xxx" class="sponsor-link">
    Become a sponsor
</a>
```

```css
.sponsor-link {
  display: block;
  color: var(--brand-color);
  font-weight: bold;
  text-decoration: none;
}
```

#### Creating a more general solution

*Lobotomized owl selector* -- just like `* + *` fore: `<aside class="social-links stack">`

```css
.stack > * + * {
  margin-block-start: 1.5em;
}
```

## Using events and forms

- Using bindings to respond to events
- Using template references
- Using two-way bindings to sync component properties and HTML elements
- Validating form data and displaying validation error messages

```html
<div class="p-2">
  <table class="table table-sm table-bordered">
    <tr><th></th><th>Name</th><th>Category</th><th>Price</th></tr>
    <tr *ngFor="let item of products() let i = index" >
      <td>{{i+1}}</td>
      <td>{{item.name}}</td>
      <td>{{item.category}}</td>
      <td>{{item.price}}</td>
    </tr>
  </table>
</div>
```

### Using the event binding

The event binding is used to respond to the events sent by the host.

```html
<div class="bg-info text-white p-2">
    Selected Product {{selectedProduct()??'(None)'}}
</div>
//...
<td (mouseover)="selectedProduct.set(item.name)">{{i+1}}</td>
```

So, an event binding has these 4 parts -- 

- The host element is the source of events for the binding
- The `round brackets`tell angualr that this is an event binding, which is a form of one-way binding where data flows from the element to the rest of the application.
- The *event* specifeis which event the binding is for.
- The *expression* is evaluated when the event is triggered.

Unlike one-way, the expressions in event bindings can make changes to the state of the app and can contain the `=`.fore. 

```ts
getSelected(product: Product): boolean {
    return product.name === this.selectedProduct();
}
```

Have defined a method called `getSelected()`that accepts a `Product`object and compares its name to the value of the `selectedProduct`signal.

```html
<tr *ngFor="let item of products() let i = index"
      [class.bg-info]="getSelected(item)">
```

The result is that `tr`elements are added to the `bg-info`class when the `selectedProduct`signal value matches `name`of the `Product`object used to create them, which is changed by the event binding when the `mouseover`event is triggered.

#### Using event data

The event binding can also be used to introduce new data into the application form the event itself.

```html
<div class="mb-3">
    <lable>Product Name</lable>
    <input class="form-control"
           (input)="selectedProduct.set($any($event).target.value)" />
</div>
```

All events share the three properties described in -- 

- `type`-- returns a `string`that identifies the type of event that has been triggered.
- `target`-- returns `object`that triggered the event
- `timeStamp`

When `input`element is triggered, the DOM API creates an `InputEvent`object, and it is this object that is assigned to the `$event`variable. Also, the `InputEvent.target`returns an `HTMLInputElement`, but this element’s `value`returns the value of the `$event.target.value`. 

The template of Angular assmes that the `$event`variable is always an `Event`object. so need conversion.

#### Handling events in the component

Although type assertions cannot be performed in templates, they can be used in the component class.

```ts
handleInputEvent(ev: Event) {
    if (ev.target instanceof HTMLInputElement) {
        this.selectedProduct.set(ev.target.value);
    }
}
```

```html
<input class="form-control"
           (input)="handleInputEvent($event)" />
```

#### Using template reference variables

Template reference variables are a form of template variable that can be used to refer to elements *within* the template.

```html
<input class="form-control" #product
           (input)="handleInputEvent($event)" />
```

### Using the two-way data bindings

Bindings can be combined to create a two-way flow of data for a single element, allowing the HTML document to respond when the application model changes and also allowing the application to respond when the element emits an event.

```ts
get selectedProductProp() {return this.selectedProduct();}
set selectedProductprop(val) {this.selectedProduct.set(val);}
```

```html
<div class="mb-3">
    <label>Product Name</label>
    <input class="form-control"
           (input)="selectedProduct.set($any($event).target.value)"
           [value]="selectedProduct() ?? ''" />
</div>

<div class="mb-3">
    <label>Product Name</label>
    <input class="form-control" [(ngModel)]="selectedProductProp" />
</div>
```

Using the `ngModel`directive requires combining the syntax of the property and event bindings. A combination of `[()]`is used to denote a two-way data binding. The target for the binding is the `ngModel`directive, which is included an Angular to simplify creating a two-way data bindings on from elements.

For this, the expression for a two-way data binding is the name of a property, which is used to set up the individual bindings behind the scenes. When the contents of the `input`element change, the new content will be used to update the value of the `selectedProductProp`property. Which will update the value of the `selectedProduct`signal.

### Wroking with forms

And the two-way `ngModel`binding in the section provides the fundation for using forms in Angualr applications.

```ts
newProduct: Product = new Product();

get jsonProduct() {
    return JSON.stringify(this.newProduct);
}

addProduct(p: Product) {
    console.log("New Product: " + this.jsonProduct);
}
```

```html
<div class="p-2">
  <div class="bg-info text-white mb-2 p-2">
    Model Data : {{jsonProduct}}
  </div>

  <div class="mb-3">
    <label>Name</label>
    <input class="form-control" [(ngModel)]="newProduct.name" />
  </div>

  <div class="mb-3">
    <label>Category</label>
    <input class="form-control" [(ngModel)]="newProduct.category" />
  </div>

  <div class="mb-3">
    <label>Price</label>
    <input class="form-control" [(ngModel)]="newProduct.price" />
  </div>
  
  <button class="btn btn-primary mt-2" (click)="addProduct(newProduct)" >
    Create
  </button>
</div>

```

When the create button clicked, the JSON representation of the component’s `newProduct`prop is written to the browser’s Js console.