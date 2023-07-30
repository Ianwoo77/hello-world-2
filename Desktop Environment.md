# Desktop Environment

Is a set of components that provide std GUI elements such as icons.

## Different Desktop environments in Linux

GNOME -- uses plenty of system resouces but ..

Working on the Command Line -- Debian-based distros provide many ways to manage software installation. At their root, they all use Debian’s world-renowned *Advanced Package Tool* (APT) – A person posting on Slashdot.com. APT was designed to automatically find and download dependencies for your package.

## Day-to-Day APT Usage

To enable you to search for packages both quickly and thoroughly, ATP uses a local cache of the available package like:

```sh
sudo apt update
```

`apt update` command instructs APT contact all the server it is configured to use and download the latest list of file updates. And if your lists are outdated, takes a minute for APT to download the updates.

After the latest package info has been downloaded – now ask APT to automatically download any software that has been updated. 

```sh
sudo apt upgrade
```

And it’s important to understand that a basic `apt upgrade`never removes or adds new. Occasionally, will see the 0 not upgraded status change – means sth cannot be upgraded – happens when some must be installed or removed to satisfy the dependencies of the updated package. – need to use `apt dist-upgrade`– designed to allow users to upgrade from one version of Ubuntu to a new version.

This will change everything, including removing obsolete soft…

`apt install`is responsible for adding new software – fore:

```sh
sudo apt install mysql-server
```

Internally, APT queries `mysql-server`against its list of software and finds that it matches the .. package. This time, can see that APT has picked up and selected all the dependencies required to install..

```sh
sudo apt remove -purge firefix
# or
sudo apt purge firefox
```

Finding software – The general search tool `apt-cache`like:

```sh
apt-cache search kde
apt-cache -n search kde # just package names
```

## Using `apt-get`instead of apt

Note that, both versions work – like:

`apt-get install` == `apt install`

## Compiling software from source

Compiling applications from source is not difficult, there are two ways to do that – you can use source code provided by upstream developer .. need to install the `build-essential`package to ensure that you have the tools you need to compilation.

Tarball – Most source code that is not in the repositories is availble from the original writer from a company’s website as compressed source *tarballs* – `tar`fles that have been compressed using `gzip`or `bzip`. like:

```sh
tar zxvf packgename.tgz -C ~/source
```

And when your configure script succeeds like:

```sh
./configure # runs a script to check whether are met and correct.

make
# finally
sudo make install

# if fails, check the error messages
make clean
# uninstall
sudo make uninstall
```

# Formatting and Scanning Strings

Formatting is the process of composing values into a string, Scanning is the process of parsing a string for the values it contains. `fmt`package just like:

`Fprintf(writer, t, ...vals)`– this creates a string by processing the template `t.`and the remaining args are used as values for the template verbs.

```go
func getProductName(index int) (name string, err error) {
	if len(Products) > index {
		name = fmt.Sprintf("name of product: %v", Products[index].Name)
	} else {
		err = fmt.Errorf("error for index %v", index)
	}
	return
}
func main() {
	name, _ := getProductName(1)
	fmt.Println(name)

	_, err := getProductName(10)
	fmt.Println(err.Error())
}
```

## Understanding the Formatting verbs

`%#v`, `%T` – #v – displays a value in a format that could be used to re-create the value in the Go code file. for a struct, will produce the filed name just. and `%+v`.

And just note that the `String`method specified by the `Stringer`interface – like:

```go
func (p Product) String() string {
	return fmt.Sprintf("Product: %v, Price: $%4.2f", p.Name, p.Price)
}

```

Note that the `String()`will be invoked automatically when a string representation of a `Product`value is required.

## Formatting Arrays, Slices and Maps

When arrays and slices are represented as strings, a set of brackets displayed. note that there is no commas are displayed. And for map, like : `map[1:Kayak 2:Lifejacket...]`

`%G`this verb adapts to the value it displays.

`%s`displays a string – This is just the default format, applied when the `%v`is used.

`%c`displays a character

`%U`displays a character in the Unicode format so that the output begins with `U+`. like `U+004B`

`%t`format `bool`value, true or false.

`%p`displays a hex representation of pointer’s storage location.

## Scannig strings

`Scan(...vals), Scanln(...vals), Scanf(template, ...vals), Fscan(reader, ...vals)`

`Fscanln(reader, ...vals), Fscanf(reader, template, ...vals), Sscan(str, ...vals)`

`Sscanf(str, template, ...vals), Sscanln(str, template, ...vals)`

```go
func main() {
	var name string
	var category string
	var price float64

	fmt.Print("Enter text to scan:")
	n, err := fmt.Scan(&name, &category, &price)

	if err == nil {
		Printfln("Scanned %v values", n)
		Printfln("Name: %v, Category: %v, Price: %.2f", name, category, price)
	} else {
		Printfln(err.Error())
	}
}
```

## Dealing with Newline characters

By default, scanning treats newline in the same way as speaces. Just note that if:

`n, err := fmt.Scanln(&name, &category, &price)`, and if wrong enter, then error.

## Using a different string source

```go
source := "lifejacket watersp, 48.95"
n, err := fmt.Sscan(source, &name, &category, &price)
```

### Using a scanning template

A template can be used to scan for values in a string that contains characters that are not required. like:

```go
source := "Product Lifejacket Watersports 48.95"
template := "Product %s %s %f"
n, err := fmt.Sscanf(source, tempalte, &name, &category, &price)
```

```go
func main() {
	rand.NewSource(time.Now().UnixNano())
	for i := 0; i < 5; i++ {
		Printfln("Value: %v: %v", i, rand.Int())
	}
}
```

```go
Printfln(i, rand.Intn(10))

func IntRange(min, max int) int {
    return rand.Intn(max-min)+min
}
```

Shuffling – `Shuffle`function is used to randomly recorder elements.

```go
func main() {
	rand.NewSource(time.Now().UnixNano())
	names := []string{"Alice", "Bob", "Charlie", "Dora", "Edith"}

	rand.Shuffle(len(names), func(first, second int) {
		names[first], names[second] = names[second], names[first]
	})

	for _, name := range names {
		Printfln(name)
	}
}

```

## Sorting Custom Data types

To sort custom data types – `sort`defines an interface – `Interface`. Just:

`Len(), Less(i,j) bool, Swap(i,j)`

When a type defines the methods, it can be sorted using the functions in `sort`package like:

`Sort(data), Stable(data)`

## Project Structure and Organization

- The `cmd`directory will contain the app-specific code for the executable apps in the project
- The `pkg`will contain the ancillary 

```go
func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)
	mux.HandleFunc("/snippet", showSnippet)
	mux.HandleFunc("/snippet/create", createSnippet)

	log.Println("Starting server on : 4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}

```

## HTML Templating and inheritance

Just inject a bit of life into the proj and develop a proper home page like:

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	ts, err := template.ParseFiles("./ui/html/home.page.html")
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal Server error", http.StatusInternalServerError)
		return
	}

	err = ts.Execute(w, nil)
	if err != nil {
		log.Println(err.Error())
		http.Error(w, "Internal server error", 500)
	}
}

```

## Template Composition

To save us typing and prevent duplication, just good idea to create a layout template which contains this shared content.  `{{define "base"}}.. {{end}}`action just define a distinct named template called `base`which contains the content we want to appear on every page.

Inside the `{{template "title" .}}`.. to denote that want to invoke other named template, and the dot represents any dynamic data that you want to pass to the invoked template, called `title`and `main`at a particular point in the html.

Now change the home.page.html file like:

```html
{{template "base" .}}

{{define "title"}} Home {{end}}

{{define "main"}}
	<h2>Latest Snippet</h2>
	<p>There is nothing to see here yet</p>
{{end}}
```

So now, instead of containing HTML directly, template set contain 3 named templats. `base, title`and `main`and instruction to invoke the `base`template.

## Embedding Partials

For some app you might want to break out certain of HTML into partials.

```html
{{define "footer"}}
	<footer>Powered by <a href="https://golang.org">Go</a></footer>
{{end}}
```

## Additional Info

The block Action – In the code used the `{{template}}`action to invoke one template form another.

Go also provides `{{block}}...{{end}}`action which can use instead. like:

```html
{{define "base"}}
<h1>
    An exmaple
</h1>
    {{block "sidebar" .}}
    <p>
        default content
    </p>
    {{end}}
{{end}}
```

The block allows you to specify some default content if the template being invoked does not exist in current template set. Don’t need to include any default between the `{{block}}`and `{{end}}`actoins. If the `sidebar`exists, then will be rendered.

## Serving Static Files

Add just some static CSS and image files to the project. 

The `http.FileServer`Handler – Go’s `net/http`package ships with a built-in `http.FileServer`handler which can use to serve files over HTTP from a specific directory.

`fileServer := http.FileServer(http.Dir("./ui/static/"))`

When this handler receives a request, it will remove the leading slash from the Path, and search `./ui/static`directory. So, for correctness, must strip the leading `/static`from the URL path *before* passing it to the http.FileServer.

```go
fileServer := http.FileServer(http.Dir("./ui/static/"))
mux.Handle("/static/", http.StripPrefix("/static", fileServer))
```

# Updating to Specific Migration

Can just update the dbs to a specific migration, which can be useful 

```sql
select COLUMN_NAME, DATA_TYPE from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='products'
```

```sh
update-base migratoinName
```

When the name of migration is used wtih the `update-database`command – EF core just examines the dbs to see which migrations have been applied and starts working toward the target migration, and calling `Up`and `Down`to perform upgrades or downgrades as required to get the target state.

### Removing a Migration

```sh
Remove-migration
```

Command remove the latest migration.

### Restting the dbs

```powershell
dotnet ef database update 0 # reset dbs
dotnet ef database drop --force
```

The drop – dorps the dbs completely, including the `__EFMigrationsHistory`table.

## Working with multiple Dbs

All the examples – assumed that the project reles on only one dbs. When a project reles on multiple dbs, which might be cuz there is one dbs for product data and another for user data, then the context class that the migration operation affects must be specified as part of the command line.

### Extending the Data-Model

The starting point for adding a second dbs to the example is to create a new entity, a new repository, and implementation. fore:

```cs
public class EFCustomerContext : DbContext
{
    public EFCustomerContext(DbContextOptions<EFCustomerContext> options) : base() { }

    public DbSet<Customer> Customers => Set<Customer>();
}
```

Just follows the std pattern for a context. Fore, provides some method…

Note: in the appsettings.json file add the connection:

```cs
builder.Services.AddDbContext<EFDatabaseContext>(opts =>
opts.UseSqlServer(builder.Configuration["ConnectionStrings:DefaultConnection"]));

builder.Services.AddDbContext<EFCustomerContext>(opts =>
opts.UseSqlServer(builder.Configuration["ConnectionStrings:CustomerConnection"]));

builder.Services.AddScoped<IDataRepository, EFDataRepository>();
builder.Services.AddScoped<ICustomerRepository, EFCustomerRepository>();
```

Then need to create and applying migrations – just:

```sh
Get-DbContext
Add-Migration Customer_Initial -Context EFCustomerContext
Update-Database -Context EFCustomerContext
```

Seeding Databases – …

## Creating Data Relationships

The foundation of EF core is the way that it represents instances of .NET classes as rows in a relational dbs table. And when U create relationships between classes, EF core responds by creating corresponding relationships in the dbs.

Relationships are just created by adding props to data model classes and then using a migration to update the dbs. And Relationships are complicated cuz the way that dbs manage data assocations doesn’t always reflect the natrual behavior of .NET objects.

## Creating a Relationship

just add to class `Product`

```cs
public Supplier? Supplier { get; set; }
```

The new, creates a relationship so that each `Product`can be associated with one `Supplier`. A `Product`obj’s Supplier prop can be null.

### Query and Displaying..

When the `Add`and `SaveChanges()`called successfully, a few things happen - the entity instances that have been inserted into the dbs are now **tracked** By EF Core, and their `State`is set to `Unchanged`. Cuz are using a relational dbs, and cuz the two entity classes, `Book`and `Review`have PK that are type of `int`, expect the dbs to create the pk by using the `IDENTITY`keyword. There, the SQL commands created by EF core read back the PK into the appropriate pks in the entity class instances to make sure entity class match the dbs.

Also, knows about the relationships by the navigational properties in the entity classes.

Examples that has one instance Already in the dbs – The other situation is creating a new entity containing a navigational prop that uses another entity already in the dbs.

So, if want to create a new `Book`entity that has an `Author`entity that you want to add to new `Book`entity, the following:

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var foundAuthor = context.Authors
	.SingleOrDefault(author => author.Name == "Future Person");
	if (foundAuthor == null)
		throw new Exception("Author not found!");

	var book = new Book
	{
		Title = "test book2",
		PublishedOn = DateTime.Today
	};

	book.AuthorsLink = new List<DataLayer.EfClasses.BookAuthor>{
		new DataLayer.EfClasses.BookAuthor{
			Book=book, Author=foundAuthor
		}
	};
	
	context.Add(book);
	context.SaveChanges();
}
```

## Updating dbs rows

Updating a dbs row is achieved in three stages:

1. Read the data, possibly with some relationships
2. Change one or more props
3. Write the changes back to the dbs.

Just load the entities, change prop, call `SaveChanges()`.

```cs
var book = context.Books.SingleOrDefault(...);
book.PublishOn=new DateTime(...);
context.SaveChanges();
```

Note, when the `SaveChanges()`is called, it runs a method called `DetectChanges`, compares the tracking snapshot against the entity class instance it handed to the app when the query was originally executed.

## Handling disconnected Updates in a new App

Uppers is just in the same `DbContext`– For a RESTful, using the same instance of `DbContext`is impossible cuz in web apps, each HTTP request typically is a new – with no data held over from the last http request.

Can handle this in several ways.

- send only the data you need to update back from the first stage. FORE, send back only the `Id`. in the second, using the PK to relaod the entity with tracking and update the specific props.
- Send all to re-create – in the second, just re-build the entity – by using the data from the first and tell core to update the whole entity – when call `SaveChnages()`, EF core will know.

Fore, with Reload - send only the Id and the `PublicationDate`back from the first stage. And, for web app, the approach of returning only a limited amount of data to the web server is a common way of handling EF core updates. A general approach is referred to as a `DTO`or `ViewModel`class. FORE:

```cs
public class ChangedPubDateDto_test
{
	public int BookId { get; set; }
	public string Title { get; set; }

	[DataType(DataType.Date)]
	public DateTime PublishedOn { get; set; }
}

```

For the `PublishedOn`prop, send out the current date and get back the changed one. Then just like:

```cs
var book = _context.Books.SingleOrDefault(...);
book.PublishedOn= dto.PublishedOn;
_context.SaveChanges();
```

The advantages of this *reload-then-update* is that it’s more secure.

## Disconnected Update, Sending All the Data

In some cases, all the data may be sent back – there is no reason to reload the original data. In some RESTful APIs, or process-to-process communications. Like:

```cs
string json;
using (var context = new EfCoreContext(optionBulder.Options))
{
	var author = context.Books
	.Where(p => p.Title == "test book2")
	.Select(p => p.AuthorsLink.First().Author)
	.Single();

	author.Name = "Future Person # 2";
	json = JsonConvert.SerializeObject(author);
}

using (var context = new EfCoreContext(optionBulder.Options))
{
	var author = JsonConvert.DeserializeObject<Author>(json);
	context.Authors.Update(author);
	context.SaveChanges();
}
```

U call the `Update`with the `Author`instance as a parameter, which marks as modified all the properties of the `Author`entity. The `Upate`command – new in EF core.

## Handling Relationships in updates

This just covers updates for the three types of relational linking that EF core uses and gives examples of both connected and disconnected updates. 

### Principal and dependent relationships

- *Principal entity* — Contains a PK that the dependent relationship refer to via a FK.
- *Dependent entity* — Contains the FK that refers to the principal entity’s pk.

Can the dept part of a REL exist without the PRIN – namely, if the PRIN is deleted – in many cases, doesn’t make sense without the PRIN REL. But in a few – should exist.

Namely, if the FK in the dbs is non-nullable, the dept can’t exist. Then if delete the book that like `BookLog`entity, `int?`type.

Updating one-to-one – Adding a PriceOffer to a book – fore:

```cs
public class PriceOffer {
    public int BookId {get;set;}
}
//...
book.Promotion = new PriceOffer{
    NewPrice = book.Price/2,
    PromotionalText= "Half price today!";
}
```

For the disconnected state update, just add it to the program.cs, and provide a interface and implementation class.

Alternatively, creating a new row directly – like:

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var book = context.Books.First(p => p.Promotion == null);
	context.Add(new PriceOffer
	{
		BookId = book.BookId,
		NewPrice = book.Price / 2,
		PromotionalText = "half price today!",
	});
	context.SaveChanges();
}

```

Should note that – didn’t have to set the `BookId`prop in the `PriceOffer`class.

Updating one-to-many relationships – like:

```cs
public class Review {
    //...
    public int BookId{get;set;}
}
//...
var book = context.Books.Include(p=>p.Reviews).First();
book.Reviews.Add(new Review{...});
context.SaveChanges();
//... or replace all the one-to-many relationships
book.Reviews= new List<Review>{new Review{...}};
```

Updating a Many-to-many — But this doesn’t directly implement many-to-many. dealing with two one-to-many. Note it’s : *relational database doesn’t directly implement many-to-many relationshps.*

Have two ways to create this between two entity classes

- link to a linking table in each entity, have an `ICollection<LeftRight>`in `Left`, then right elsewhere.

Updating M-t-M via a linking entity class – 

- create an entity called `BookAuthor`contains both the PK and the PK of `Author`entity class.
- Add a navigational prop called `AuthorsLink`of type `ICollection<BookAuthor>`to `Book`and `Author`entity class.

Fore, add the author to an exist book via the `BookAuthor`linking entity class:

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var book = context.Books
	.Include(p => p.AuthorsLink)
	.Single(p => p.Title == "test book2");

	var existingAuthor = context.Authors
	.Single(p => p.Name == "Stephen Giles");

	book.AuthorsLink.Add(new DataLayer.EfClasses.BookAuthor
	{
		Book = book,
		Author = existingAuthor,
		Order = (byte)book.AuthorsLink.Count
	});

	context.SaveChanges();
}
```

# Forms and Data

The `EditForm`component is used as a parent for individual form field components.

## Using Form Components

Provides a set of built-in components that are used to render from elements, and ensuring that the server-side properties are updated after user-interaction and intergrating validation.

- `EditForm` – readers a `form`that is wried up for data validation
- `InputText`– renders an `input`that is bound to a C# `string`.
- `InputCheckbox`– renders an input element whose type attr is `checkbox`and that is bound to a C# bool prop.
- `InputDate`-- renders an input element type is `date`and bound to C# `DateTime`or `DateTimeOffset`
- `InputNumber`— renders an input number, bound to `int, float, double, decimal`
- `InputTextArea`– renders a `textarea`bound to C# `string`.

NOTE: The `EditForm`must be used for any of the other components to work.

## Creating Custom Form components

But for now, there is actually a true `InputSelect`

```html
<div class="mb-3">
    <label>Dept ID</label>
    <InputSelect TValue="long" @bind-Value="PersonData.DepartmentId" class="form-control">
        <option selected disabled value="0">Choose a Department</option>
        @foreach (var dept in Context!.Departments)
        {
            <option value="@dept.DepartmentId">@dept.Name</option>
        }
    </InputSelect>
</div>

<div class="mb-3">
    <label>Location ID</label>
    <InputSelect TValue="long" @bind-Value="PersonData.LocationId" class="form-control">
        <option selected disabled value="0">Choose a Location</option>
        @foreach (var loc in Context!.Locations)
        {
            <option value="@loc.LocationId">@loc.City, @loc.State</option>
        }
    </InputSelect>
</div>
```

## Validating Form Data

Blazor provides components that perform validation using the std attributes like:

- `DataAnnotationsValidator`-- this integrates the validation attributes applied to the model class into the Blazor form features.
- `ValidationMessage`– displays validation error messages for a single prop
- `ValidationSummary`-- displays validation error messages for entire model model object.
- `validation-errors`-- ul element that is assigned to this class
- `validation-message`– summary component its `ul`with `li`assigned to this class.

And, The `Input*`components add the HTML elements they generate to the classes described.

`modified, valid, invalid` can:

```html
<link href="/css/site.css" rel="stylesheet" />
<h4 class="bg-primary text-white text-center p-2">Edit</h4>

<EditForm Model="PersonData">
    <DataAnnotationsValidator />
    <ValidationSummary />

    <div class="mb-3">
        <label>FirstName</label>
        <ValidationMessage For="@(()=>PersonData.Firstname)" />
        <InputText class="form-control" @bind-Value="PersonData.Firstname"/>
    </div>
</EditForm>
```

Just note that `DataAnnotationValidator`and `ValidationSummary`components are applied without any configuration attributes. And the `ValidationMessage`attribute is confgiured using the `For`attr – which receives a **function** that return the prop the component represents. fore:

`<ValidationMessage For= "@(()=> PersonData.FirstName)" />`

## Handling Form Events

The `EditForm`component defines events that allow an application to respond to user action – 

- `OnValidSubmit()`– This event is triggered when the form is submitted and the form data passes validation.
- `OnInvalidSubmit()`-- fails validation
- `OnSubmit`-- just submitted and *before validation is performed*.

These are triggered by adding a conventional submit button within the content contained by the `EditForm`component.

```html
<EditForm Model="PersonData" OnValidSubmit="@(()=>FormSubmitMessage="Valid data Submitted")"
    OnInvalidSubmit="@(()=>FormSubmitMessage="Invalid Data Submitted")">
```

# Creating Structural Directives

Changes the layout of the HTML document by adding and removing elements. 

- Uses micro-templates to add content to the HTML document
- Allow content to be added conditionally based on the result of an expression
- Applied to an `ng-template`element, contains the content and bindings that comprises its micro-template.
- Can make a lot of unnecessary changes to document.

## Creating a Simple Structural Directive

Re-create `ngIf`directive – simple and easy to understand fore:

`<ng-template [paIf]="showTable">`The expression for this binding uses the value of a property called `showTable`.

Implementing the Structgural Directive Class –

```ts
@Directive({
	selector: "[paIf]"
})
export class PaStructureDirective implements OnChanges {
	constructor(private container: ViewContainerRef,
				private template: TemplateRef<Object>) {
	}

	@Input("paIf")
	expressionResult?: boolean;

	ngOnChanges(changes: SimpleChanges) {
		let change = changes["expressionResult"];
		if (!change.isFirstChange() && !change.currentValue) {
			this.container.clear();
		} else if (change.currentValue) {
			this.container.createEmbeddedView(this.template);
		}
	}
}
```

Used to match host elements that have the `paIf`attribute, this corresponds to the template additions. There is an input prop called `expressionResult`– uses to receive the results of the expression from the template. The directive just implments the `ngOnChanges`method.

`constructor(private container: ViewContainerRef, private template: TemplateRef<Object>)`

`ViewContainerRef`manage the contents of the *view content*– part of HTML document where the `ng-template`appears. Managing a collection of *views*. and a view is a region of HTML elemetns that contains directives, bindings, and expressions. 

`element`– returns an `ElementRef`represents the container element.

`createEmbeddedView(template)`, create a new view. `TemplateRef`represents the content of the `ng-template`element. Ng determines that it needs to create a new instance of the `PaStructureDirective`class. note:

`ViewContainerRef`represents the place in the HTML document occupied by the `ng-template`element. And `TemplateRef`represents the `ng-template`'s content.

For its `ngOnChanges()`– uses `SimpleChanges`obj it receives to show or hide the contents of `ng-template`element.

## Using the Concise Structural Directive Syntax

Can just like:

```html
<table *paIf="showTable" class="table table-bordered table-striped">
```

## Creating Iterating Directives

Ng provides special support for directives that need to iterate over a data source like:

```html
<ng-template [paForOf]="getProducts()" let-item>
    <tr><td colspan="4">{{item.name}}</td> </tr>
</ng-template>
```

Just note the `let-item`– define the *implicit value*, allows the currently processed object to be referred to within the `ng-template`element as the directive iterates.

```ts
@Directive({
	selector: "[paForOf]"
})
export class PaIteratorDirective implements OnInit {
	constructor(private container: ViewContainerRef,
				private template: TemplateRef<Object>) {
	}

	@Input("paForOf")
	dataSource: any;

	ngOnInit() {
		this.container.clear();
		for (let i = 0; i < this.dataSource.length; i++) {
			this.container.createEmbeddedView(this.template,
				new PaIteratorContext(this.dataSource[i]));
		}
	}
}

class PaIteratorContext {
	constructor(public $implicit: any) {
	}
}
```

The `ngOnInit()`will be called once the value of the input prop has been set. Note that the second parameter – provides the data for the implicit value, using a property called $implicit

```html
<tr *paFor="let item of getProducts()">
    <td></td>
    <td>{{item.name}}</td>
    <td>{{item.category}}</td>
    <td>{{item.price}}</td>
</tr>
```

# Understanding Components

Components are just **directives** that have their own templates – rather then relying on content provided from elsewhere. Components have access to all the directive feaures – also define their own content using templates.

Can be easy to understimate the importantace of the template – Directives don’t have much insight into the elements they are just applied to. Directives are most useful when are general-purpose tools.

Components – are closely tied to the contents of their templates. Components provide the data and logic that will be used by the data bindings that are applied to the HTML elements in the template.

The `@Component`decorator is applied to a class,which is just registered in the app’s Angular Module. An Ng app must contain at least one component – used in the bootstrap process.

## Creating new Components

```ts
@Component({
	selector: "paProductTable",
	template: "<div>This is the table component</div>"
})
export class ProductTableComponent {
}
```

Note that the naming convention for the files that define component is to use descriptive name that suggests the purpose of the component, followed by a period.

- `encapsulation`– used to change the view encapsulation settings, how styles are isolated form the rest of HTML.
- `template`– used to specify inline template
- `providers`-- used to create a loal provdiers for services
- `viewProviders`-- create a local providers for services.

## Understanding the New App structure

Now, there are just three components – and responsibility for some HTML content has been delegated to the new additions.  Then begins processing the body of the `index.html`and finds the `app`element – which is specified by the `selector`of the `ProductComponent`– Angular populates the `app`with the component’s template – which is contained in the `template.html`. and recursively this process.

The `ProductComponent`is now the parent component to the `ProductFormComponent`and.. A relationship that is formed by the fact that the host elements for the new components are defined in the `template.html`file.

## Defining External Templates

Are just defined in a different file from the rest of the component. The best way to do that is to just follow a consistent file naming strategy.

### Using Data Binding in Component Templates

A component’s template can contain the full range of data bindings and target any of the built-in directives or custom directives that have been registered in the app’s module. By default, each component is just isolated from the others.

## Using `Input` prop to coordinate Between Components

Fiew components exist in isolation and need to share data with other parts of the app. like:

```html
<div class="col p-2 bg-primary text-white">
    <!-- [model] is input field, and model is ProductModel's field -->
    <paProductTable [model]="model"></paProductTable>
</div>
```

# Pattern Libraries

After start writing CSS in a modular way – begin to shift the way you approach the task of authoring web pages and web applications. It’s becoming std practice on large projects to put together a set of documentation that provides this inventory. This set of documentation is called a *pattern library* on a *style guide*.

## KSS

```sh
npm init -y
npm install --save-dev kss
```

Add the Kss Configuration

KSS will need a configuration file – this file gives KSS the paths to some directories and files that it will use to build pattern library. Create a file named kss-config.json:

```json
{
    "title": "My pattern library",
    
    // path to CSS source files directory (which KSS will scan)
    "source":["./css"],  
    
    // path to where the generated pattern will be written
    "destination": "docs/",
    
    // path to stylesheet, relative to dest directory
    "css":[
        "../css/style.css"
    ],
    
    // path to any js , relative to dest directory
    "js":[
        "../js/docs.js"
    ]
}
```

The source tells KSS where to find CSS source, which it scans for documentation comments. Add a command to the package.json that tells KSS to build the pattern like:

```json
  "scripts": {
    "build": "kss --config kss-config.json",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
```

This adds the build command to package. Then run:

```sh
npm run build
```

## Writing KSS documentation

KSS looks for comments in stylesheet follow a particular pattern. includes a title, some descriptive text, some example html and a `Styleguide`annotation indicating where the module belongs in the table of the contents. And a blank line separates each of these items for KSS.

```css
body{
    font-family: Arial, Helvetica, sans-serif;
}

/*
Media

Displays an image on the left and body content
on the right.

Markup:
<div class="media">
    <img class="media__image" src="https://place-hold.it/150x150" />
    <div class="media__body">
        <h4>Strength</h4>
        <p>Strength training is an important part of
            injury prevention. Focus on your core&mdash;
            especially your abs and glutes.</p>
    </div>
</div>

Styleguide Media
*/
.media {
    padding: 1.5em;
    background-color: #eee;
    border-radius: 0.5em;
}
```

Then run:

```sh
npm run build
```

KSS generates a doc directory that includes a `section-media.html`file

```sh
/*
Media

Displays an image ...
```

After these, is a `Markup:`, this is followed by a block of HTML code that illustrates the use of the module. KSS renders this HTML into the pattern. And the exact text and images used in the example are not important, they illustrate to the developer how the module works just.

For this, the final line of the KSS comment must include the `Styleguide`annotation just:

```sh
Styleguide Media
*/
```

This must be the last line of the comment. Without that, KSS will ignore the entire comment block.

### Documenting module variants

The documentation comment for this will be similar to the last, but, add a new section after the markup to indicate each of the modifier. Also add the annotation – `{{modifler_class}}`to the markup example like.. KSS …



Advanced Topics – 

# Backgrounds, shadows, and blend modes

A CSS preprocessor is a program that lets generate from the preprocessor’s own unique syntax. Like nesting, mixins, inheritances.. the most directy to make this happen – once sass is installed, can compile your Sass to CSS using sass command. like:

```sh
sass input.scss output.css
```

Can also watch individual or directories using `--watch`flag. tells Sass to watch your source files for changes, and re-compile each time you save.

```sh
sass --watch input.scss output.css # watch insted of manually build
```

Can watch and output to dirs by using folder paths as input and output, separating with a colon:

```sh
sass --watch app/sass:public/stylesheets # watch all in app/sass folder, compile css to public/stylesheets folder
```

```scss
$font-stack: Helvetica, sans-serif;
$primary-color: #333;

body {
    color: $primary-color;
    font: 100% $font-stack;
}
```

When the Sass is processed, it takes the variables define for .. and outputs normal CSS with variable values placed in the CSS.

## Nesting

When writing HTML, probably noticed that it has a clear nested and visual hierarchy, Sass will let you nest your CSS selectors in a way that follows the same visual hierarchy of your HTML. like:

```scss
nav {
    ul {
        margin: 0;
        padding: 0;
        list-style: none;
    }

    li {
        display: inline-block;
    }

    a {
        display: block;
        padding: 6px 12px;
        text-decoration: none;
    }
}
```

Just noticed that the `ul, li, a`are nested inside the `nav`– this is a great way to organize your css and make it more readable.
