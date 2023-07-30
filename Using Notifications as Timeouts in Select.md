# Using Notifications as Timeouts in Select

The `After`function can be used with `select`.

```go
channelOpen := true
for channelOpen {
    Printfln(...)
    select {
    case name, ok := <-nameChannel:
        if !ok {
            channelOpen=false
        }else{
            Printfln(...)
        }
    case <-time.After(time.Second*2):
    	...    
    }
}
```

## Stopping and Resetting Timers

So the `time.After()`is useful when are sure that you will always need the timed notification.

`NewTimer(duration)`-- returns a `*Timer`with the specified period. The result of the `NewTimer`is a pointer to a `Timer`defines:

`C`-- returns the channel over which the time .. `Stop()`-- Stops the timer.. `Reset()`

```go
func writeToChannel(channel chan<- string) {
	timer := time.NewTimer(time.Minute * 10)
	go func() {
		time.Sleep(time.Second * 2)
		Printfln("Resetting timer")
		timer.Reset(time.Second)
	}()

	Printfln("Waiting for initial duration...")
	<-timer.C
	Printfln("Initial duration elapsed.")

	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
	}
	close(channel)
}
```

A goroutine sleeps for 2s and then resets the timer.

## Receiving Recurring Notifications

The `Tick`func returns a channel over which `Time`values are sent at a specified interval. Fore:

```go
func writeToChannel(nameChannel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	tickChannel := time.Tick(time.Second)
	index := 0
	for {
		<-tickChannel
		nameChannel <- names[index]
		index++
		if index == len(names) {
			index = 0
		}
	}
}
```

Just note that the `Tick`usefule when an indefinite of signals is required.

`NewTicker(duration)`-- returns a `*Ticker`with specified period. Also, C, Stop(), and Reset(duration).

```go
names := []string{"Alice", "Bob", "Charlie", "Dora"}
ticker := time.NewTicker(time.Second/10)
index := 0
for {
    <-ticker.C
    nameChannel <- names[index]
    index++
    if index == len(names) {
        ticker.Stop()
        close(nameChannel)
        break
    }
}
```

# Reading and Writing Data

Two of the most important interfaces defined -- The `Reader`and `Writer`intterfaces. This approach means that just about any source can be just used in the same way. `io`defines this -- the implementations are available from a nrange of others.

defined in the `io`provides abstract ways to read and write data.

`Read(byteSlice)`-- reads data into the specified `[]byte`. returns the bytes number were read, `int, error`.

```go
func processData(reader io.Reader) {
	b := make([]byte, 2)
	for {
		count, err := reader.Read(b)
		if count > 0 {
			Printfln("Read %v bytes: %v", count, string(b[0:count]))
		}
		if err == io.EOF {
			break
		}
	}
}

func main() {
	r := strings.NewReader("Kayak")
	processData(r)
}
```

`strings.NewReader("Kayak")`, and specify the maximum number of bytes that want to receive by setting the size of bytes slice. The `io`defined `EOF`-- used to signal when the `reader`reaches the end of the data.

And, The `Writer`just :

`Write(byteSlice)`-- Write from the slice.

```go
var builder strings.Builder
processData(r, &builder)
Printfln("String builder contents: %s", builder.String())
```

`strings.Builder`just implements the `io.Writer`, and note that the Writers will return an `error`if are unable to write all the data in the slice.

Writers will return an `error`-- so check the error result and `break`.. and this example, the Writer just building an in-memory string.

## Using the Utility Functions for Readers and Writers

And the `io`defines a set of functions -- 

`Copy(w, r), CopyBuffer(w, r, buffer)`, same as `Copy`but reads into special buffer first.

CopyN(w, r, count),

`ReadAll(r)`-- read until EOF

`ReadAtLeast(r, byteSlice, min)`

`ReadFull(r, byteSlice)`-- fills the byte slice with data. result is the number of bytes and an error.

`WriteString(w, str)`-- writes `string`to a writer.

```go
func processData(reader io.Reader, writer io.Writer) {
	count, err := io.Copy(writer, reader)
	if err==nil {
		Printfln("Read %v bytes", count)
	}else{
		Printfln("Error: %v", err.Error())
	}
}
```

## Buffering Data

The `bufio`package, provides support for adding buffers to readers and writers. like:

```go
type CustomReader struct {
	reader    io.Reader
	readCount int
}

func NewCustomeReader(reader io.Reader) *CustomReader {
	return &CustomReader{reader, 0}
}

func (cr *CustomReader) Read(slice []byte) (count int, err error) {
	count, err = cr.reader.Read(slice)
	cr.readCount++
	Printfln("Custom Reader: %v bytes", count)
	if err == io.EOF {
		Printfln("Total reads: %v", cr.readCount)
	}
	return
}
// ...
func main() {
	text := "It's was a boat, A small boat."
	var reader io.Reader = NewCustomeReader(strings.NewReader(text))
	var writer strings.Builder
	slice := make([]byte, 5)

	for {
		count, err := reader.Read(slice)
		if count > 0 {
			writer.Write(slice[0:count])
		}
		if err != nil {
			break
		}
	}

	Printfln("Read data: %v", writer.String())
}
```

Reading small amounts of data can be problematic when there is a large amount of overhead . It can be preferable to make a smaller number of larger reads. For the `bufio`functions:

`NewReader(r)`-- returns a buffered `Reader`with default(4096 bytes)

`NewReaderSize(r, size)`-- returns a buffered `Reader`with specified buffer size.

Result by these implemented the `Reader`but, also, introduced a buffer.

```go
reader = bufio.NewReader(reader) // changed the Read() method
```

## Using the additional Buffered Reader Methods

implements the `io.Reader`can be as drop-in wrappers for other types of `Reader`, seamlessly just:

`Buffered()`-- the number of bytes can be read from the buffer

`Discard(count)`-- discards the specified number of bytes

`Peek(count)`-- returns specified without removing from the buffer

`Reset(reader)`-- discrds the data

`Size()`-- returns size of the buffer.

```go
Printfln("Buffer size: %v, buffered: %v", buffered**.**Size(), buffered**.**Buffered())
```

## Performing Buffered Writes

And the `bufio`also provides support for creating writers that use a buffer.

# Stateful HTTP

A nice touch to improve our user experience would be to display a one-time confirmation message which the user see after added a new snippet. Say -- **Flash Message**.

Sharing data (or state) between HTTP requests for the same user.

- Session managers
- Customize session behavior
- use sessions.

fore, `gorilla/sessions`, golangcollege/sessions.

## Setting up the Session Manager

1. establish a session manager in `main.go`file, and make it just available to handler. For the sessions to work, also need to wrap. `Session.Enable()` like:

   ```go
   dynamicMiddleware := alice.New(app.session.Enable)
   
   mux := pat.New()
   mux.Get("/", dynamicMiddleware.ThenFunc(app.home))
   ```

   

## Working with Session Data

To add confirmation to the session data -- use the `*Session.Put()`like:

```go
app.session.Put(r, "flush", "snippet successfully created!")
```

to retrieve that:

```go
flash, ok := app.session.Get(r, "flash").(string)
if !ok {...}
```

or use the `*Session.GetString()`

Then, could use the `*Session.Remove()`to do. better is the `*Session.PopString()`.

```go
flash := app.session.PopString(r, "flash")
```

Remember, the `{{with .Flash}}`block will only the evaluated is not the empty string.

## Security Improvements

Going to make some improvements to app.

- create a self-signed TLS certificate
- Served securely over HTTPs
- Some sensible tweaks
- set connection timeouts

TLS is essentially HTTP sent across a TLS connection. And before our server can starting using HTTPs, need to generate a TLS certificate.

For development purposes, the simplest thing to do is to generate your own *self-signed* certificate. It's the same thing as a normal TLS certificate, except that it isn't cryptographically signed by a trusted authority. This just means that your web browser will raise a warning.

The `crypto/tls`package in Go's STDLIB includes a `generate_cert.go`tool, can use it. Behind this:

1. generates a 2048-bit RSA key pair, which is a cryptographically secure public key and private key.
2. It then stores the private key in a `key.pem`file, and generates a self-signed TLS certificate for the host `localhost`containing the public key. stores in a `cert.pem`file.

## Running a HTTPs Server

Now just need open the `main.go`and swap the `srv.ListenAndServe()`for `srv.ListenAndServeTLS()`instead.

`err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")`

## Certificate Permissions

It's just important to note that the user that must have the permissions for both `cert.pem`and `key.pem`files. Otherwise, using `ListenAndServeTLS()`will return `permission denied`error.

And, by default, the `generate_cert.go`file grants read permission to *all users* but for only read to the owner of the file `key.pem`.

# Avoiding Circular References

Actually, the best solution for avoiding endless loops of related data is to set the navigation property to `null`before it reaches the JSON serializer.

```cs
public object GetProduct(long id)
        {
            return context.Products
                .Include(p => p.Category)
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.PurchasePrice,
                    p.RetailPrice,
                    p.Description,
                    p.CategoryId,
                    Category = new
                    {
                        p.Category.Id,
                        p.Category.Name,
                        p.Category.Description,
                    }
                }).FirstOrDefault(p => p.Id == id)!;
        }
```

## Querying for Multiple Objects

When handling queries for multiple objects -- it is important to restrict the amount of data. just like:

```cs
public object GetProducts(int skip, int take)
        {
            return context.Products
                .Include(p => p.Category)
                .OrderBy(p => p.Id)
                .Skip(skip).Take(take)
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.PurchasePrice,
                    p.Description,
                    p.RetailPrice,
                    p.CategoryId,
                    Category = new
                    {
                        p.Category.Id,
                        p.Category.Name,
                        p.Category.Description,
                    }
                });
        }
[HttpGet]
public object Products(int skip, int take)
{
    return repository.GetProducts(skip, take);
}
```

## Completing the service

```cs
[HttpPost]
public long StoreProduct([FromBody] Product product) // note that [FromBody]
{
    return repository.StoreProduct(product);
}

[HttpPut]
public void UpdateProduct([FromBody] Product product)
{
    repository.UpdateProduct(product);
}

[HttpDelete("{id}")]
public void DeleteProduct(long id)
{
    repository.DeleteProduct(id);
}
```

Need to note after C# 6: `public Category? Category { get; set; }`

## EF core 2 in Detail

The Controller for now works directly with an DbContext to access the data in the dbs, This is just ok, but can be improved upon by implementing the repository pattern.

A *repository* consists of an interface that defines the data operations that can be performed in an app and an implementation class that does the actual work.

The MVC part of the application only use the interface -- while, Behind the scenes, 

```cs
public interface IDataRepository
{
    IEnumerable<Product> Products { get; }
}

public class EFDataRepository: IDataRepository
{
    private EFDatabaseContext context;
    public EFDataRepository(EFDatabaseContext context)
    {
        this.context = context;
    }
    public IEnumerable<Product> Products => context.Products;
}
```

## Hiding the Data Operations

A knock-on problem with using the `IQueryable<T>`interface is that it exposes details of how the data is managed to the rest of the application.

An alternative better approach is to hide away the detail of how the data is acquired ..

```cs
public IEnumerable<Product> GetProductsByPrice(decimal minPrice)
{
    return context.Products.Where(p => p.Price >= minPrice).ToArray();
}
```

## Using Generic Type Parameters in Template Components

The template component created in previous is useful. It is also limited it reles on the parent component to take responsibility for generating the rows for the table body. And the template component doesn't have any insight into the content it presents.

Template components can be made data-aware with the use of *generic type parameter*. Also limited cuz it reles .. Becomes responsible for generating the content for each data object and, consequently, provide more useful functionality.

```cs
@typeparam RowType

<table class="table table-sm table-bordered table-striped">
	@if (Header != null)
	{
		<thead>@Header</thead>
	}
	<tbody>
	@if (RwoData != null && RowTemplate != null)
	{
		@foreach (RowType item in RwoData)
		{
			<tr>@RowTemplate(item)</tr>
		}
	}
	</tbody>
</table>

@code {
	[Parameter]
	public RenderFragment? Header{ get; set; }

	[Parameter]
	public RenderFragment<RowType>? RowTemplate { get; set; }
	
	[Parameter]
	public IEnumerable<RowType>? RwoData { get; set; }
}

```

So, the generic type parameter is specified using the `@typeparam`attribute, and in the `RowData`-- its type is just `IEnumerable<RowType>`-- the content the component will display for each object is just received using the `RenderFragment<T>`

NOTE: when a component receives a content section through a `RenderFragment<T>`prop, it can render it for a single object by invoking the section as a method and using the object as the argument.

`@RowTemplate(item)`

Using this -- 

```html
<TableTemplate RowType="Person" RowData="People">
    <Header>
        <tr>
            <th>ID</th><th>Name</th><th>Dept</th><th>Location</th>
        </tr>
    </Header>
    <RowTemplate Context="p">
        <td>@p.PersonId</td>
        <td>@p.Surname, @p.Firstname</td>
        <td>@p.Department?.Name</td>
        <td>@p.Location?.City, @p.Location?.State</td>
    </RowTemplate>
</TableTemplate>
```

## Adding Features to the Generic Template Component

Giving the template component insight into the data it handles sets the foundation for adding features. Like:

```cs
@typeparam RowType

<div class="container-fluid">
	<div class="row p-2">
		<div class="col">
			<SelectFilter Title="@("Sort")" Values="@SortDirectionChoices"
				@bind-SelectedValue="SortDirectionSelection" />
		</div>

		<div class="col">
			<SelectFilter Title="@("Highlight")" Values="@HighlightChoices()"
				@bind-SelectedValue="HighlightSelection" />
		</div>
	</div>
</div>

<table class="table table-sm table-bordered table-striped">
	@if (Header != null)
	{
		<thead>@Header</thead>
	}
	<tbody>
	@if (RowTemplate != null)
	{
		@foreach (RowType item in SortedData())
		{
			<tr class="@IsHighlighted(item)">@RowTemplate(item)</tr>
		}
	}
	</tbody>
</table>

@code {
	[Parameter]
	public RenderFragment? Header{ get; set; }

	[Parameter]
	public RenderFragment<RowType>? RowTemplate { get; set; }

	[Parameter]
	public IEnumerable<RowType>? RowData { get; set; }
		= Enumerable.Empty<RowType>();

	[Parameter]
	public Func<RowType, string> Highlight { get; set; } = row => string.Empty;

	public IEnumerable<string> HighlightChoices() =>
		RowData!.Select(item => Highlight(item)).Distinct();

	public string? HighlightSelection { get; set; }

	public string IsHighlighted(RowType item) =>
	Highlight(item) == HighlightSelection ? "table-dark table-white" : "";

	[Parameter]
	public Func<RowType, string> SortDirection { get; set; } = row => String.Empty;

	public string[] SortDirectionChoices =
	new string[] { "Ascending", "Descending" };

	public string SortDirectionSelection { get; set; } = "Ascending";

	public IEnumerable<RowType> SortedData() =>
	SortDirectionSelection == "Ascending"
	? RowData!.OrderBy(SortDirection) : RowData!.OrderByDescending(SortDirection);
}
```

In the Peoplelist.razor file:

```html
<TableTemplate RowType="Person" RowData="People"
    Highlight="@(p=>p.Location?.City)" SortDirection="@(p=>p.Surname)">
```

## Reusing a Generic Template Component

So can create a component named `DepartmentList.razor`, reuse this pattern: just like:

```html
@inject DataContext? Context
<TableTemplate RowType="Department" RowData="Departments"
	Highlight="@(d=>d.Name)"
	SortDirection="@(d=>d.Name)">
	<Header>
		<tr><th>ID</th><th>Name</th><th>People</th><th>Location</th></tr>
	</Header>
	
	<RowTemplate Context="d">
		<td>@d.DepartmentId</td>
		<td>@d.Name</td>
		<td>@(string.Join(", ", d.People!.Select(p=>p.Surname)))</td>
		<td>
			@(string.Join(", ", d.People!.Select(p=>
				p.Location!.City)))
		</td>
	</RowTemplate>
</TableTemplate>


@code {
	public IEnumerable<Department>? Departments =>
		Context?.Departments?
		.Include(d => d.People!).ThenInclude(p => p.Location);
}
```

## Cascading Parameters

Can be useful for a component to provide configuration data to descendants deep in the hierarchy of components. This can be done by having each component in the chain .. error-prone.

Blazor just provides a solution to this -- by supporting *cascading parameters* -- Component provides values that are available directly to any of its descendants, without being relayed by intermediate components.

Just defined using `CascadingValue`component, used to wrap a section of content. The `CascadingValue`makes a value available to the component it encompasses and their descendant.

Cascading parameters are received directly by the components that require them with the `CascadingParameter`attribute. They are in the component defined `CascadingValue`.. 's child component. With this, can do.. Just need to note that. The child can modify this value.

# Think of Types as Sets of Values

At runtime, every variable has a single value chosen from js' universe of values. Before code runs, when Ts is checking it for errors -- just has a *type*. This is just best thought of as a *set of possible values*.

`never`< single values ...

Think of interface :

```ts
interface Identified {
    id: string;
}
```

The & operator computes the interaction of two types. Type operations apply to the sets of values, not to the properties in the interface.

`type k = keyof (Person | LifeSpan)`// for interface, Type is never.

## Declaration Files

```ts
export interface Character {
    catchphrase?: string;
    name:string;
}
// in other file:
import {Character} from "./types"
export const character: Character = {
    ...
}
```

## Declarting Runtime Values

Using Idempotent Expressions -- One-way data bindings must be idempotent -- meaning that they can be **evaluated repeatedly** without changing the state of the app.

Angular evaluates binding expression *several times* before displaying the content in the browser. If an expression modifies the state of an application, such as removing an object from a queue -- won't get the results you expects.

Angular will report an error if a data binding expression contains an operator that can be used to perform an assignment. In addition, when Ng is running in development mode - performing an additional check to make sure that one-way bindings have not been modified. If:

```ts
get nextProduct(): Product | undefined {
    return this.model.getProducts().shift();
}
```

```html
<div>
    Next is {{nextProduct?.name}}
</div>
```

ERROR occurred.

## Understanding the Expression Context

Note that the templates can't access the global namespace -- is used to define common utilities, fore, console.

```html
<div>
    {{Math.floor(...)}}
</div>
```

Angular has tried to evaluate the expression using the component as the context and failed to find a `Math`. So if want to access functionality in the global, must be **Provided by the component **.

## Using Events and Forms

Explain how to create event bindings and how to use two-way bindings to manage the flow of data between model and the template. 

`imports [..., FormsModule]`

Adding `FormsModule`to the list of dependencies enables the form features and makes them available for use throughout the application.

## Using the event Binding

The *event binding* is used to *respond to the events* sent by the host element.

`<td (mouseover)="selectedProduct=item.name">{{i+1}}</td>`

So an event binding has 4 parts -- 

1. The *host* element is the source of events for the binding.
2. The `round brackets`tell Ng that this is an event binding
3. event specifies which event the binding is for.
4. The *expression* is evaluated when the event is triggered.

```html
<tr *ngFor="let item of getProducts(); let i= index"
    [class.bg-info]="getSelected(item)">
```

This shows how user interaction drives new data into the application and starts the change-detection process.

## Using Event Data

```html
<input class="form-control"
       (input)="selectedProduct=$any($event).target.value" />
```

When the browser triggers an event, it just provides an `Event`object that describes it -- There are different..

3 properties of all events -- 

`type`-- returns a string that identifies the type

`target`-- returns the `object`that triggered the event

`timeStamp`-- a number contains the time that the event was triggered.

For this, when the `input`element is triggered, the browser's DOM API creates an `InputEvent`obj, And it is just this obj that is assigned to the `$event`variable. Note the `target`returns an `HTMLInputElement`obj, value returns the content of the input element.

Ts was designed to accommodate this using type assertions.

Angular templates do support the special `$any`function, which disables type checking by treating a value as the special `any`type. `(input)="selectProduct=$any($event).target.value"` This can avoid the Ts' type checking.

## Handling Events in the Component

```ts
handleInputEvent(ev: Event) {
    if (ev.target instanceof HTMLInputElement) {
        this.selectedProduct = ev.target.value;
    }
}
```

```html
<input class="form-control" (input)="handleInputEvent($event)" />
```

## Using Template Reference Variables

Template reference variables are a form of template variable that can be used to refer to element within the template like:

```html
<input #product class="form-control" (input)="false" />
```

Reference variables are defined using the `#`followed by the variable name. Ng sets its value to the element to which it has been applied. The `product`just reference variable is assigned the object that represents the `input`element. So the `HTMLInputElement`object.

And the event binding responds to the `mouseover`by setting the `value`property on the ..

Ng won't update the data bindings in the template when the user edits the contents of the `input` -- unless there is an event binding on that element. Give `false`just lets Angular evaluate -- 

```html
<input #product class="form-control"
       (keyup.enter)="..." />
<!-- or -->
<input... (change)="..." /> when change the focus.
```

## Using Two-Way Data Bindings

Bindings can be combined to create a two-way flow for a single element -- allowing the HTML document to respond when the app model changes and also allowing the app to respond when the element emits an event.

```html
<div class="mb-3">
    <label>Product Name</label>
    <input class="form-control" (change)="selectedProduct=$any($event).target.value"
           [value]="selectedProduct??''"/>
</div>
```

## Using the `ngModel`Directive

The `ngModel`directive is used to simplify two-way bindings to that don't have to apply both an event and a property binding to the same element.

`<input class="form-control" [(ngModel)]="selectedProduct" />`

`[()]`just denote a two-way data binding. The expression for a two-way is the name of a property -- which is used to set up the individual bindings behind the scenes.

The `ngModel`directive knows the combination of events and properties that the std html elements defines.

## Working with Forms

Adds a new prop called `newProduct`which will be used to store the data entered into the form.

```html
<div class="mb-3">
    <label>Price</label>
    <input class="form-control" [(ngModel)]="newProduct.price" />
</div>
```

## Adding Form data Validation

```html
<form (ngSubmit)="addProduct(newProduct)">
    <div class="mb-3">
        <label>Name</label>
        <input class="form-control" name="name" [(ngModel)]="newProduct.name"
               required minlength="5" pattern="^[A-Za-z ]+$" />
    </div>
    <button class="btn btn-primary mt-2" type="submit">Create</button>
</form>
```

## Styling Elements using Validation Classes...

IMPORTANT -- when writing the HTML for a responsive design, it's important to ensure it has everything you need for each screen size. Can apply different CSS for each instance, but they must share the same HTML.

Just note that the `text-shadow`prop in the image might be new -- it consists of several values that together define a shadow to add behind the text.

## Creating a mobile menu

```css
.menu {
    position: relative;
}

.menu-toggle {
    position: absolute;
    top: -1.2em;
    right: 0.1em;
    border: 0;
    background-color: transparent;

    font-size: 3em;
    width: 1em;
    height: 1em;
    line-height: 0.4;
    text-indent: 5em;
    white-space: nowrap;
    overflow: hidden;
}

.menu-toggle::after {
    position: absolute;
    top: 0.2em;
    left: 0.2em;
    display: block;
    content: "\2261";
    text-indent: 0;
}

.menu-dropdown {
    display: none;
    position: absolute;
    right: 0;
    left: 0;
    margin: 0;
}

.menu.is-open .menu-dropdown {
    display: block;
}
```

```js
(function () {
    let button = document.getElementById('toggle-menu');
    button.addEventListener('click', event => {
        event.preventDefault();
        let menu = document.getElementById('main-menu');
        menu.classList.toggle('is-open');
    })
})();
```

So, `.nav-menu`need some styling -- like:

```css
.nav-menu {
    margin:0;
    padding-left: 0;
    border: 1px solid #ccc;
    list-style: none;
    background-color: #000;
    color: white;
}

.nav-menu > li + li {
    border-top: 1px solid #ccc;
}

.nav-menu >li > a{
    display:block;
    padding: 0.8em 1em;
    color: #fff;
    font-weight: normal;
}
```

An important thing to note here is the padding on the menu item links. Key clickable areas should be large and easy to tap with a finger just.

## Adding the Viewport meta tag

For the viewport *meta tag* -- this is just an HTML tag tells mobile devices you've intentionally designed for small screens -- without this, a mobile browser assumes your page is not responsive, and it will attempt to emulate a desktop browser. Just update the `<head>`to:

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

The meta tag's `content`indicates two things -- 

1. Tells the browser to use the device width as the assumed width when interpreting the CSS.
2. `initial-scale`set the zoom level at 100% when page loads.

## Media queries

The second component of responsive design is the use of media queries -- allow to write a set of styles that only apply to the page under certain conditions. This lets u tailor your style differently, just based on the screen size.

Use the `@media`at-rule to target devices that match a specified feature like:

```css
@media (min-width: 560px) {
    .title > h1 {
        font-size: 2.25rem;
    }
}
```

The `@media`rule is a conditional check that must be true for any of these styles to be applied to the page. In this case, the browser checks for a min-width: 560px -- The padding will only be applied to a `page-header`if the user's device has a viewport width of 560px or greater.

```css
@media(min-width:35em) {
    .title > h1 {
        font-size:2.25em;
    }
}
```

It's better idea to use ems in media queries, just based on the browser's default font size. usually 16px. instead 560px, can use 35em. Now the title just has two different font sizes. Just depends on the viewport size.

Can test these by resizing the width. This point, where the window is 560px wide, is known as a *breakpoint*, most often, you will re-use the same few breakpoints in multiple media queries throughout your stylesheet.