# String Process and Regular Expressions

In this describe the stdlib feature for processing `string`values, which are needed by almost every project and which many langauges provides as methods defined on the built-in types.

`Contains, EqualFold, Has*`function, `ToLower, ToUpper, Title, or ToTitle`functions, 

Splitting -- Using the `Fields, `Splits`function .

`Trim*`, `Join`or , `Repeat`, `Replace`, use a `Replacer`...

## Inspecting strings with Custom Functions

The `IndexFunc`and `LastIndexFunc`functions use a custom function to just inspect strings, using custom functions like:

```go
func main() {
	desc := "A boat for one person"
	isLetterB := func(r rune) bool {
		return r == 'B' || r == 'b'
	}
	fmt.Println("IndexFunc:", strings.IndexFunc(desc, isLetterB))
}
```

## Splitting Strings

`Fields(s)`, `FieldsFunc(s, func)`, Split, SplitN, SplitAfter..

## Triming Strings

The process of trimming removes leading and trailing characters from a string and is most often used to remvoe whitespace characters. FORE:

```go
func main() {
	text := "It was a boat. A Small boat."
	replacer := strings.NewReplacer("boat", "kayak", "small", "huge")
	replaced := replacer.Replace(text)
	fmt.Println("replaced", replaced)
}

```

`joined := strings.Join(elements, "--")`

And the `strings`package provides the `Builder`type, which has note exported fields, but provide a set of methods that can be used to efficiently build strings gradually.

`Writestring(s)`, WriteRune(r), WriteByte(b), String(), Reset(), Len(), Cap(), Grow()...

```go
func main() {
	text := "It was a boat. A Small boat."
	var builder strings.Builder
	for _, sub := range strings.Fields(text) {
		if sub == "Small" {
			builder.WriteString("very ")
		}
		builder.WriteString(sub)
		builder.WriteRune(' ')
	}
	fmt.Println("String:", builder.String())
}
```

## Regular Expressions

The `regexp`package provides support for regular expressions, which allow complex patterns to be found in strings. like:

`Match(pattern, b)`, Match

```go
func home(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello from Snippetbox"))
}

func main() {
	// use the http.NewServeMux() function to initialize a new servemux, then
	// register the home function as the handler for the "/" url pattern.
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)

	log.Println("Starting server on: 4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}

```

## Routing Requests

`/snippet`-- showSnippet-- Display a specific snippet

`/snippet/create`-- createSnippet -- Create a new snippet.

```go
func showSnippet(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Display a specific snippet..."))
}

func createSnippet(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("create a new snippet..."))
}
```

## Fixed path and subtree patterns

Go’s serveMux supports two different types of URL patterns, *fixed paths* and *subtree paths*. Note that the Fixed paths don’t end with a trailing slash, whereas subtree paths *do* end with a trailing slash.

In contrast, “/” is an example of a subtree path, another example would be something like “/static/”, subtree patterns are matched, like `/**`, or `/static/**`.

Helps explain why the `/`pattern is acting like a catch-all. The pattern essentially means match a single slash.

Restricting the Root URL pattern -- Can include a simple check in the `home`handler which ultimately has the just same effect just like:

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	w.Write([]byte("Hello from Snippetbox"))
}
```

## The DefaultServeMux

If working,,, some across the `http.Handler()`and `http.HandleFunc`functoins -- These allow you to register routes *without* declaring a serveMux, like:

```go
func main(){
    http.HandleFunc("/", home)
    http.HandleFunc("/snipet", showSnippet)
    //...
    err := http.ListenAdndServe(":4000", nil)
}
```

Behind the scenes, these functions register their routes with sth called `DefaultServemux`, There is nothing special -- it’s just regular servemux. just like:

`var DefaultServeMux= NewServeMux()`// in the http module

# Storing New Data

The next step to add the ability to store new objects in the dbs. FORE:

```cs
public void CreateProduct(Product newProduct)
{
    newProduct.Id = 0;
    context.Products.Add(newProduct);
    context.SaveChanges();
}
```

There are two sources of `Product`objects in the example - MVC model binding process and the dbs context oobject. The model binding creates `Product`objects when it just receives an POST, and the context object creates `Product`when it reads data from the dbs.

So, EF core is responsible for the `Product`that are created by the dbs context but has no visibility of the ones created by the MVC model binder. `Add`, called on the `DbSet<T>`and makes EF core aware of a `Product`that has been created elseware in the app so that it can be written to the dbs.

## Understanding Key Assignment

`CreateProduct`explicitly sets the value of the `Id`of the `Product`to zero.

The PK for new objects are allocated by the dbs server when new rows in the table are created -- And an exception will be thrown if the value for the `id`is not 0.

Note, when EF core stores a new object -- immediately perform a SQL query to discover the value that the dbs has assigned to the `Id`of the new row.

```sql
insert into ... values(...);

select [Id]
From [Products]
where @@ROWCOUNT=1 and [Id]=scope_identity();
```

note that the `select`queries the value for the `Id`column that has been used to create a new row. The vlaue is returned is used to **update the product object**, just ensuring that the object is just consistent with its representation in the dbs.

## Updating Data

The process for modifying existing data is similar to storing data but requires a little work -- just get it efficiently.

```cs
context.Poducts.Update(changedProduct);
context.SaveChanges();
```

The advantage of this is simplicity. -- But, fore the EF core -- doesn't have enough info to determine that only one property has been changed. so:

```sql
Update Products set category=@p0, Name= @p1, ...where...
```

### Querying the Existing before Updating

EF core has the ability to work out exactly which prop is an object have been modified. like:

```cs
public void UpdateProduct(Product product)
{
    Product origProduct = context.Products.Find(product.Id)!;
    origProduct.Name = product.Name;
    origProduct.Category = product.Category;
    origProduct.Price = product.Price;

    context.SaveChanges();
}
```

For this, there are two `Product`objects in the example. product object is received as the action method parameter and has been created by the MVC model binder using the `HTTP post`request data.

Cuz -- EF core keeps track of the objects it creates using data from the dbs and works out when the value of prop has changed. And EF core will inspect the property values of the `origProduct`object to see whether they have changed since the object was created and will update only the ones that are different.

```sql
Update product set name = @p0 where...
```

## Understanding Change Detection

Note-- the base class for the context class, `DbContext`defines the method returns an `EntityEntry`obj -- this is used by EF core to **detect changes** in the objects that it creates. like:

`State`-- returns a value from the `EntityState`enum to indicate the state of the object. `Added, Deleted, Detached, Modified, Unchanged`.

`OriginalValues`-- returns a collection of the original prop values

`CurrentValues`-- returns a collection of the current prop values.

Just like:

```cs
EntityEntry entry = context.Entry(origProduct);
    Console.WriteLine($"Entity state {entry.State}");
    foreach(string name in new string[]
    {
        "Name", "Category", "Price"
    })
    {
        Console.WriteLine($"{name} - old: " +
            $"{entry.OriginalValues[name]}, "+
            $"New: {entry.CurrentValues[name]}");
    }
```

## Updating a single Dbs operation

Each HTTP request received by the app is processed by a new instance of the `Home`Controller. And each controller object gets a new repository object, and a new dbs object, cuz. AddTransient()..

The third for performing updates is to take advantage of that orig read operation by including the data it obtained in the response sent to the client. In the form:

```html
<input name="original.Id" value="@Model?.Id" type="hidden" />
<input name="original.Name" value="@Model?.Name" type="hidden" />
<input name="original.Category" value="@Model?.Category" type="hidden" />
<input name="original.Price" value="@Model?.Price" type="hidden" />
```

For this, the `name`are prefixed with the `original`tells the MVC model binder that these elemetns should be used as props for an action method parameter whose name is just the `original`. So, to receive data, edit the `Home`.

```cs
if (orig == null)
{
    orig = context.Products.Find(product.Id);
}
else {
    context.Products.Attach(orig);
}
```

For this, if the `UpdateProduct`receives an `orig`, it placed under the management of EF core using the `DbSet<T>`.`Attach`method. -- Which sets up the ef core change tracking process and sets the associated EntityEntry.State to `Unmodified`. Then the prop is chagned by tracked object.

## Deleting Data

The final data operation to implement is deletion -- which is a relativlely simple..

```cs
public void DeleteProduct(long id)
{
    Product? p = context.Products.Find(id);
    context.Products.Remove(p!);
    context.SaveChanges();
}
```

For this, there is also the problem - uses the `Find`to query the dbs to get the `Product`that should deleted. Works but it results in a dbs operation that can be avoided by just create a new `Product`directly like:

```cs
public void DeleteProduct(long id)
{
    context.Products.Remove(new Product { Id = id });
    context.SaveChanges();
}
```

For this only the key is used to identify the row in the dbs that will be deleted.

## Understanding Migrations

How EF core ensures the dbs reflects that the data model in the app -- even as that model chagnes. This is just called code first.

1. Migrations are groups of commands -- prepare dbs for use with EF core application. -- Used to create the dbs and then keep it sync with changes in the data model.

If there is not the `Update-Database`command run, -- Dbs hasn't been prepared for the application. For this -- SQL Server doesn't know anything about the `DataAppDb`-- so when app tried to read, error occurred.

`<timestamp>_Initial.cs`-- part of the `Initial`class, first migration to the dbs,creat schema
`<timestamp>_Initial.Designer.cs`-- part of the `Initial`, Applies the first mig to dbs, create model objects
`EFDatabaseContextModelSnapshot`-- contains the entire classes used in mig, detect changes for creating further migrations.

This part of the `Initial`class contains the methods that will be called to update the dbs.

* `Up()`-- contains statements upgrade the dbs to store entity data.
* `Down()`-- downgrade the dbs to original state.

The `Up()`is an instance -- The methods are translated into dbs commands by dbs provider. The `Down`is used to return the dbs to its previous state, undoing the effect of the `Up`. like:

`migrationBuilder.DropTable(name: "Products");`

And just note that a Migration doesn't take effect until it is applied to the dbs.

## Explicit Loading 

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var firstBook = context.Books.First();
	context.Entry(firstBook).Collection(book=> book.AuthorsLink).Load();
	context.Entry(firstBook).Reference(book=>book.Promotion).Load();
}
```

And explicitly loading has method like `Query`to obtain the count of reviews like:

```cs
context.Entry(firstBook).Collection(book=> book.AuthorsLink).Query().Count().Dump();
context.Entry(firstBook).Collection(book=>book.Reviews).Query()
    .Select(review=>review.NumStars).Dump();
```

### Select Loading -- Loading specific parts of Primary entity class and any relationships

```cs
var books = context.Books
    .Select (book => new {
        book.Title, book.Price,
        NumReviews= book.Reviews.Count,
    }).ToList();
```

## Lazy Loading -- Loading as required

Makes writing queries easy -- Lazy loading requires some changes to your `DbContext`or entity classes, after making those, reading is easy.

- Adding the Proxies library when configuring your DbContext.
- Injecting a Lazy loading method into the entity class via its ctor

The first option is simple, but locks into setting up lazy loading for all relationships. NOTE that avoid it cuz its performance issues.

### Using Client vs. Server Evaluation -- Adapting data at the last stage of q query

Fore, the list display of the books in the Book App, need a extra all the author's names.. fore.

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var firstBook = context.Books
	.Select(book => new
	{
		book.BookId,
		book.Title,
		AuthorsString = string.Join(", ",
		book.AuthorsLink
		.OrderBy(ba => ba.Order)
		.Select(ba => ba.Author.Name))
	}).First();
	firstBook.Dump();
}
```

For this, just maybe two authors, -- would cause AuthorsString to contain the string you need. Some parts of the query are converted to SQL, and Run in the server, another part, `string.Join`has to be done client-side by EF core before the combined result is handled back to the code.

Just need to be careful how you use a prop created by client vs. server evaluation. For this example, if you tried to sort or filtered on the `AuthorString`, would get an error.

The `NavigationManger`class is provided as a srevice and received by Razor componetn using the `Inject`attribute, which provides access to the dependency injection feature.

```html
<button class="btn btn-primary" @onclick="HandleClick">
    People
</button>
```

```cs
[Inject]
public NavigationManager? NavManger{get;set;}
public void HandleClick=> NavManager?.NavigateTo("/people");
```

# Receiving Routing Data

Components can receive segment variables by decorating a prop with `Parameter`. like:

```html
@page "/person"
@page "/person/{id:long}"

<h3>Editor for Person: @Id</h3>

<NavLink class="btn btn-primary" href="/people">Return</NavLink>
@code {
    [Parameter]
    public long Id { get; set; }
}
```

This for now just do nothing more than displaying value it receives from the routing data.

## Defining Common Content using layouts

Layouts are template components that provide common content for Razor Components. To create a layout, like:

```cs
@inherits LayoutComponentBase

<div class="container-fluid">
    <div class="row">
        <div class="col-3">
            <div class="d-grid gap-2">
                @foreach (string key in NavLinks.Keys)
                {
                    <NavLink class="btn btn-outline-primary"
                             href="@NavLinks[key]"
                             ActiveClass="btn-primary text-white"
                             Match="NavLinkMatch.Prefix">
                        @key
                    </NavLink>
                }
            </div>
        </div>
    </div>
</div>

@code {
    public Dictionary<string, string> NavLinks =
        new Dictionary<string, string>
        {
        ["people"]="/people", ["Departments"]="/depts", ["Details"]="/person"
        };
}
```

So, Laouts use the `@inherits`expression to just specify the `LayoutComponentBase`class as the base for the class generated from the Razor Component. For this, the layout component creates a grid laoyout that displays a set of `NavLink`for each of the componetns in the app.

* `ActiveClass`-- specifies one or more CSS classes that the anchor element rendered.

* `Match`-- specifies how the current URL is matched to the href. `NavLinkMatch`enum.

  

## Applying a Layout

There are three ways that a layout can be applied. `@layout`expressoin, a parent can use by wrapping in the built-in `LayoutView`compoennt., A layout can be applied by setting the `DefaultLayout`attriute of `RouteView`componetn.\

`RouteView RouteData="@context" DefaultLayout="typeof(NavLayout)"/>`

```html
<div class="col">
    @Body
</div>
```

## Understanding he Component Lifecycle methods

Razor components has a well-defined lifecycle, which is represented with methods that componetns can implement to receive notifications of key transition.

- `OnInitialized()`--  invoked when the component is first initialized

- `OnParametersSet()`-- after the values for properties decorated with the `Parameter`has been applied.

- 

  

  `ShouldRender()`-- called before the component's content is rendered to update the content presented to the user. If returns `false`, then component's content will not be rendered. -

  

  

  

  

  

  

`OnAfterRender`-- invoked after the component's content is rendered.

```cs
@inject NavigationManager? NavManager

<a class="@">@</a>

@code {

    [Parameter]
    public IEnumerable<string> Href { get; set; } = Enumerable.Empty<string>();

    [Parameter]
    public string Class { get; set; } = string.Empty;

    [Parameter]
    public string ActiveClass { get; set; } = string.Empty;
    
    [Parameter]
    public NavLinkMatch? Match { get; set; }

    public NavLinkMatch ComputedMatch
    {
        get => Match ?? (Href.Count() == 1 ? NavLinkMatch.Prefix : NavLinkMatch.All);
    }
    
    [Parameter]
    public RenderFragment? ChildContent { get; set; }

    public string ComputedClass { get; set; } = string.Empty;

    public void HandleClick()
    {
        NavManager?.NavigateTo(Href.First());
    }

    private void CheckMatch(string currentUrl)
    {
        string path = NavManager!.ToBaseRelativePath(currentUrl);
        path = path.EndsWith("/") ? path.Substring(0, path.Length - 1) : path;
        bool match = Href.Any(href => ComputedMatch == NavLinkMatch.All
            ? path == href : path.StartsWith(href));
        ComputedClass = match ? $"{Class} {ActiveClass}" : Class;
    }

    protected override void OnParametersSet()
    {
        ComputedClass = Class;
        NavManager!.LocationChanged += (sender, arg) => CheckMatch(arg.Location);
        Href = Href.Select(h => h.StartsWith("/") ? h.Substring(1) : h);
        CheckMatch(NavManager!.Uri);
    }

}
```

This works in the same way as a regular `NavLink`but accepts an array of paths to match. The component relies on the `OnParametersSet`cuz some initial setup is required.

## Using the LifeCycle methods for Async Tasks

Are also useful for performing tasks that may complete after the initial content from the componetn.

```cs
@page "/person"
@page "/person/{id:long}"
@inject DataContext? Context
@inject NavigationManager? NavManager

@if (Person == null)
{
    <h5 class="bg-info text-white text-center p-2">Loading...</h5>
}
else
{
    <table class="table table-striped table-bordered">
        <tbody>
        <tr><th>Id</th><td>@Person.PersonId</td></tr>
        <tr><th>SurName</th><td>@Person.Surname</td></tr>
        <tr><th>Firstname</th><td>@Person.Firstname</td></tr>
        </tbody>
    </table>
}

<button class="btn btn-outline-primary" @onclick="@(()=>HandleClick(false))">Previous</button>
<button class="btn btn-outline-primary" @onclick="@(()=>HandleClick(true))">Next</button>

@code {

    [Parameter]
    public long Id { get; set; }

    public Person? Person { get; set; }

    protected async override Task OnParametersSetAsync()
    {
        await Task.Delay(100);
        if (Context != null)
        {
            Person = await Context.People.FirstOrDefaultAsync(p => p.PersonId == Id)
                     ?? new Person();
        }
    }

    public void HandleClick(bool increment)
    {
        Person = null;
        NavManager?.NavigateTo($"/person/{(increment ? Id + 1 : Id - 1)}");
    }

}
```

The component can't query the dbs until the parameter values have been set and so the vlaue of the `Person`prop is obtained in the `OnParametersSetAsync`.

## Managing Component Interaction

And, Most components work together through parameters and events. Blazor also provides advanced optoins for managing interaction with components.

### Using References to Child Components

A parent component can obtain a reference to a child componetn and use it to consume the properties and methods it defines.

```html
<MultiNavLink class="btn btn-outline-primary"
         href="@NavLinks[key]"
         ActiveClass="btn-primary text-white"
         DisabledClasses="btn btn-dark text-light disabled"
         @ref="Refs[key]">
    @key
</MultiNavLink>
```

References to componetns are created by adding `@ref`and specifying the name of field or prop to which the component should be assigned. In this, the component `MultiNavLink`is a dict, so, also dict used. As each `MultiNavLink`is created, it is added to the `Refs`dict.

# Creating Custom Events

*output properties* are the Ng feature that allows directives to add custom events to their host elements. just:

```ts
constructor(private element: ElementRef){
    this.element.nativeElement.addEventListener("click", ()=> {
        if(this.product != null) {
            this.click.emit(this.product.category);
        }
    });
}

@Input("pa-attr")
bgClass : string|null = "";

@Input("pa-product")
product: Product = new Product();

@Output("pa-category")
click = new EventEmitter<string>();
```

The `EventEmitter<T>`interface, provides the event mechansims for directives. `string`indicates that listeners to the event will receive just a `string`. Common, `string` and `number`. 

When the mouse click the `pa-attr`'s element, `click`will emit the string. 

```html
<tr ... (pa-category)="newProduct.category=$event"></tr>
```

The term `$event`is used to access the value the click triggered and the variable `click`emited value.

## Creating HOST Element Bindings

Note that the Ng is intended to be run in a range of different execution environments. Rather than using the DOM to add and remove classes, a class binding can be used on th
