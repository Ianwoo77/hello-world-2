# Command-Line Beginner’s Class

The Linux command line is one of the most powerful tools available for computer system administration and maintenance. Using the command line is an efficient way to perform complex tasks accurately and much more easily than it would seem at a first glance. Many of the commands were created by the GNU project…

1. Routine tasks
2. Basic file management
3. Basyc system management

## Reading Document

```sh
man rm
whereis fdisk
```

## Understanding File system Hierarchy

Linux has inherited from Unix – is generally logical and mostly consistent.

`/bin`– essential commans

`/boot`-- Boot loader files, Linux kernel

`/dev`– device files

`etc`– system configuration files

`/home`- user home dir

`/lib`– shared libraries, kernel modules

`/lost+found`– recovered files

`/media` - Mount point 

`/mnt`– usual mount point for local, remote file systems, file systems that are additional to the std.

`/opt`– Add-on software packages

`/proc`-- kernel info, process control

`/root`-- super user home

`/sbin`– System commands

`/sys`– Real-time info on devices used by the kernel

`/tmp`– Temporary files

`/usr`-- Software not essential for system operation

`/var`-- Variable files relating to services that run on system.

## Essential Commands in `/bin`and `/sbin`

`/bin`dir contains essential commands used by the system for running and booting the system. – in general, only the root operator uses the commands in the `/sbin`dir.

Configuration Files in `/etc`

- `fstab`– file sytem table is a text file that lists each hard drive
- `modprobe.d`- holds all instrcutions to load kernel modules
- `passwd`-- holds the list of users for the system
- `sudoers`– holds a list of users with super access.

```sh
cat /proc/meminfo
# or
free
```

Shared Data in the `/usr`dir, temp in the `/tmp`dir

variable data files in the `/var`– contains subdirectories used by various system services for spooling and logging.

## ls

By default, the `ls`shows just a list of names – some are files, some dirs. – Hidden files use filenames that start with a `.`as the first character. Often used for configuration of specific programs and not accessed frequently.

```sh
ls -al
```

The listing is given with one item per line but with multiple columns.Just filetype-permissions-link count-owner-group-file size - last access date/time and file name.

```sh
ls -R
```

Scans and lists all the contents of the subdirs of the current dir. might to redirect the output to a text file like:

```sh
ls -alR > listing.txt
```

## Working with Permissions

Under linux – every in the file system – **including directories and devices** – is a file. And every file on system has an accompanying of permissions based on owership.

`touch`just quickly creates a file and the `ls`then reports on the file.

1. The type of file created – Common indicators of the type of file are in the leading letter in the output. Blank designates a plain file – `d`for dir, `c`for character device (fore, /dev/ttys0), `l`for symbolic link, `b`for block device.
2. Permisions – Read, write and execute
3. Number of hard links to the file, A hard-linked file is just a pointer to the original file.
4. owner – the account that owns the file, it is just creator, can change this using the `chown`command
5. The group – group of users allowed to access, `chgrp`
6. File size…

`x`indicates permission for an owner, a mebmer of the owner’s group, or other to execute the file (or read a dir)

octal – 4 indicates read, 2 indicates write, 1 indicates execute

## Dir permissions

```sh
mkdir directory
ls -ld directory
```

`-ld`is used to show the permission and other info about the dir. 755. cuz the execute permission – also list the dir’s contents. for `d`specifies that this file is jsut a dir.

```sh
#show all block
sudo lsblk
sudo fdisk -l
```

Could also notice that the `ls`command’s output shows a leading `d`in the permissions field. like:

`ls -l /dev/ttyS0`

Altering File Permissions with `chmod` – Can use the `chmod`to alter permissions.

`u`for user rwx, `g`for group, `o`for others, `a`for all, `r w x` for read, write and execution

```sh
chmod a-w readme
chmod u+rw readme
chmod 600 readme # use octal form, just -rw for user, group and other nothing
```

# Dates Times and Durations

The `Format`method is used to create formatted strings for `Time`values.

```go
func PrintTime(label string, t *time.Time) {
	layout := "Day: 02 Month: Jan Year: 2006"
	fmt.Println(label, t.Format(layout))
}

func main() {
	current := time.Now()
	specific := time.Date(1995, time.June, 9, 0, 0, 0, 0, time.Local)
	unix := time.Unix(1488228090, 0)

	PrintTime("current:", &current)
	PrintTime("specific:", &specific)
	PrintTime("UNIX", &unix)
}
```

Can just use the predefined Layout like:

`fmt.Println(label, t.Format(time.RFC822Z))`

Parsing Time values from Strings – The `time`package support for creating `Time`values from strings like:

`Parse(layout, str)`, and `ParseInLocation(layout, str, location)`

## Manipulating Time Values

The `time`defines methods for working with `Time`values, 

`Add(duration)`, `Sub(time)`, 

`AddDate, After(time), Before(time)`

`Round(duration)`– rounds `Time`to the nearest interval represented by a `Duration`

## Using the features for Goroutines and Channels

provides a small set of functions are useful with goroutines and channels like:

`AfterFunc(duration, func)`– executes the specified function in its own goroutine

`After(duration)`, returns a channel that blocks for the specified duration and then yields a `Time`

`Tick(duration)`– returns a channel periodically sends a `Time`value.

```go
func writeToChannel(channel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
		time.Sleep(time.Second)
	}
	close(channel)
}

func main() {
	nameChannel:= make(chan string)
	go writeToChannel(nameChannel)
	for name := range nameChannel {
		Printfln("Read name: %v", name)
	}
}
```

The duration specified by the `Sleep`is the minimum amount of time.

## Deferring Execution of a Function

The `AfterFunc`is used to defer the execution of a function for a specified period as shown like:

```go
func main() {
	nameChannel:= make(chan string)

	time.AfterFunc(time.Second*5, func() {
		writeToChannel(nameChannel)
	})
	// go writeToChannel(nameChannel)
	for name := range nameChannel {
		Printfln("Read name: %v", name)
	}
}
```

## Receiving Timed Notifications

The `After`function waits for a specified duration and then sends a `Time`value to a channel. fore:

```go
func writeToChannel(channel chan<- string) {
	Printfln("Waiting for initial duration...")
	<- time.After(time.Second*2)
	Printfln("Initial duration elasped")

	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names{
		channel <- name
		time.Sleep(time.Second)
	}
	close(channel)
}
```

## Using Notifications as Timeouts in `select`statements

```go
func main() {
	nameChannel := make(chan string)

	go writeToChannel(nameChannel)

	channelOpen := true
	for channelOpen {
		Printfln("Starting channel read")
		select {
		case name, ok := <-nameChannel:
			if !ok {
				channelOpen = false
				// break
			} else {
				Printfln("Read name: %v", name)
			}
		case <-time.After(time.Second * 2):
			Printfln("Timeout!")
		}
	}
}
```

## Stopping and Resetting Timers

The `After`function is useful when you are sure that you will always need the timed notification. If you just need the option to cancel the notification, then the func – 

`NewTimer(duration)`

`C, Stop(), Reset(duration)`

```go
func writeToChannel(channel chan<- string) {
	timer := time.NewTimer(time.Minute * 10)
	go func() {
		time.Sleep(time.Second * 2)
		Printfln("Resetting timer")
		timer.Reset(time.Second)
	}()

	Printfln("Waiting for initial duration")
	<-timer.C
	Printfln("initial elapsed")

	names := []string{"Alice", "Bob", "Charlie", "Dora"}
	for _, name := range names {
		channel <- name
	}
	close(channel)
}
```

## Receiving Recurring Notifications

The `Tick`function returns a channel over which `Time`values are sent at a specified interval just like:

```go
func writeToChannel(channel chan<- string) {
	names := []string{"Alice", "Bob", "Charlie", "Dora"}

	tick := time.NewTicker(time.Second)
	index := 0

	for {
		<-tick.C
		channel <- names[index]
		index++
		if index == len(names) {
			tick.Stop()
			close(channel)
			break
		}
	}
}
```

Using static Files

```html
<link rel="stylesheet" href="/static/css/main.css" />
<link rel="shortcut icon" href="/static/img/favicon.ico" type="image/x-icon" />
```

## The http.Handler interface

```go
type Handler interface{
    ServeHTTP(ResponseWriter, *Request)
}
```

So in its simplest form a handler might look like this:

```go
type home struct {}
func(h *home) ServeHTTP(w http.ResponseWriter, r *http.Request){
    w.Write([]byte(...))
}
```

## Handler Functions

Now creating an object just so we can implement a `ServeHTTP()`method on it is long-winded.

# Creating and Updating Related Data

The process for creating and updating related data is performed through the navigation properties and done using std. There are just different scenarios in which a `Supplier`object is stored in the dbs or an existing object.

- News are created at the same time
- A new with existing `Product`
- A new with exsiting`Supplier`

Note that the model for the view is just a `Product`– Then edit the Editor like:

When Save, the browser sent an HTTP POST request to the server that contained values from the `input`. The model binder uses the values in the HTML form to create `Product`and `Supplier`object, which is assigned to the `Product`object’s `Supplier`navigation prop. NOTE, for now, EF core inspects the `Product` object and sees that `id`value is zero, which indicates that it is a new object to inspects the `Product`object and sees that this `Id`value is zero, then Create a new. And also follows the `Product.Supplier`navigation prop to inspect the `Supplier`

## Updating a Supplier when Updating a product

And, a change is required to the context class to create or update a `Supplier`object when the `Product`object it is related to has previously stored in the dbs. Add:

```html
<input name="original.Supplier.Id" value="@Model.Supplier?.Id" type="hidden" />
```

These hidden `input`elements are the counterparts to the ones in the `Editor.cshtml`view. To ensure that changes made by the user are written to the dbs, edit the `UpdateProudct`

```cs
origProduct!.Supplier!.Name = product.Supplier!.Name;
origProduct!.Supplier!.City = product.Supplier!.City;
origProduct!.Supplier!.State = product.Supplier!.State;
```

These statements copy the .. values to the object that being tracked by the EF core to just ensure that changed values will be stored in the dbs.

# Deleting Related Data

By default, EF core won’t follow a nav prop to remove related data from the dbs. For this relationship, Supplier may be related other `Product`object.

Can tell EF core to delete related data – dbs server will cause an exception. LIke:

```cs
public void DeleteProduct(long id)
{
    Product p = this.GetProduct(id);
    context.Products.Remove(p);
    if(p.Supplier != null)
    {
        context.Remove<Supplier>(p.Supplier);
    }
    context.SaveChanges() ;
}
```

For this: `Context.Remove<Supplier>(p.Supplier)`. For this, there is no direct access to the `Supplier`data, but the context object’s `Remove<T>`method can do that.

## Creating a Required Relationship

The `Product`and `Supplier`classes have an optional relationship, reflecting the fact that a `Product`doesn’t have to be related to a `Supplier`.

Some relationships need to be more formal, Creating a required relationship means telling EF core how it should create the FK column that tracks the rel in the dbs. Just - `nullable: true`

### Creating a FK property

Overriding the defaults is done by creating a prop that provides EF core with details about how the FK should be created. *This is a FK property*, and it is defined in the same class that contains the nav prop. Just in the `Product`entity add: `public long SupplierId {get;set;}`, The name of the prop tells EF core which nav it relates to by combining the nav prop name or the related class name with the pk. Used the `long`as the prop type – tells ef core to create a **required** relationship since long values cannot be set to `null`. 

Note that for this, need to re-migrate. And the `AlterColumn()`– `nullable: false`. And drop the dbs, then Update the getter for the `Products`defined in the `SeedData`so that all `Product`are stored related to a `Supplier`.

```cs
Supplier s2 = new Supplier
{
    Name = "Chess Kings",
    City = "Seattle",
    State = "WA"
};
// products.First().Supplier = s1;

foreach (var p in products)
{
    if (p == products[0])
    {
        p.Supplier = s1;
    }else if(p.Category=="Chess")
    {
        p.Supplier = s2;
    }
    else
    {
        p.Supplier = acme;
    }
}
```

Then update the dbs.

## Updating a M-t-M REL

In EF core, talk about mtm with Direct access to other entity – EF core 5 added the ability to access another entity class directly in a mtm REL. FORE, A book can have 0 to many categories, … to help a customer find the right, these are held in a `Tag`entity with a direct mtm REL to a Book. This allows the `Book`to show its categories in the book list.

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var book = context.Books
	.Include(p => p.Tags)
	.Single(p => p.Title == "Quantum Networking");

	var existingTag = context.Tags
	.Single(p => p.TagId == "Microsoft .NET");

	book.Tags.Add(existingTag);
	context.SaveChanges();
}
```

## Updating relationships via FKs

In many situations, you can cut out the loading of the entitiy classes and sets the FKs instead. The following carries out the update after the user types the request – The code assumes that the `ReviewId`of the `Review`the user wants to change and the new `BookId`that they want to attach the review to are returned in a variable.

```cs
var reviewToChange= context.Find<Review>(dto.ReviewId);
reviewToChange.BookId=dto.NewBookId; // changes the fk
context.SaveChanges();
```

For this,don’t have to load the `Book`entity class or use an `Include`.

## Deleting entities

The final to change the data in the dbs is to delete a row from a table.

### Soft-delete

1. Add a `bollean`prop to the `Book`. if `true`then `Book`is soft-deleted
2. Add a *global query filter* via **fluent configuration commands**. The effect is to apply an extra `Where`filter.

like:

`public bool SoftDeleted{get;set;}`

Adding the global to the `DbSet<Book>`prop means adding an EF configuration command to the app’s `DbContxt`.

```cs
protected override void OnModelCreating(ModelBuilder modelBuilder) {
    //...
    modelBuilder.Entity<Book>()
        .HasQueryFilter(p=>!p.SoftDeleted);
}
```

Just need to set the `SoftDeleted`prop to `true`then call `SaveChanges()`. Then any query on the entities will exclude the `Book`that have the `true`prop.

### Deleting a dependent-only entity with no relationships

Chosen the `PriceOffer`to show – it’s a dependent entity just. Like:

```cs
var promotion = context.PriceOffers.First();
context.Remove(promotion);
context.SaveChanges();
```

### Deleting a Principal that has relationships

Relational dbs needs to keep *referential integrity*. So, if delete a row in a table that other rows are pointing to via FK, something to stop integrity. This is a rel dbs concept indicating that table relationships must always be consisitent.

Following are three ways that U can set a dbs to keep referential integrity when you delete a principal entity with dept entities – 

- Tell the dbs server to delete the dept entities that rely on the prin entity, called *cascade deletes*.
- Can tell the dbs server to set the FKs of the dept entities to `null`.
- if neither set up, db server will raise exceptions.

### Deleting a book with its dependent rels

For its `Promotion, Reviews, AuthorsLink`. These three can’t exist without the `Book`-- a non-nullable FK links these dept entities to a specific `Book`row.

note, by default, EF core uses **cascade deletes** for dept relationships with non-nullable FKs. This uses just the cascade delete approach. like:

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var book = context.Books
	.Include(p => p.Promotion)
	.Include(p => p.Reviews)
	.Include(p => p.AuthorsLink)
	.Include(p => p.Tags)
	.Single(p => p.Title == "test book2");
	
	context.Books.Remove(book);
	context.SaveChanges();
}

```

Note that the 4 **`Include()`**just make sure that the 4 dependent rels are loaded with the `Book`. Also note, in fact, the `SaveChanges()`calles `DetectChanges()`which find a tracked Book entity marked as `deleted`. If you didn’t incorporate the `Includes`in your code, EF core wouldn’t know about the dependent entities and couldn’t delete the 3 depednent entities.

## Using EF core with Blazor

The Blazor model changes the way that EF core behaves – which can lead to unexpected results if you used to writing conventional Core applications.

### Understanding the ef core scope issue

To see, In a conventinal Core, written using controllers or RPs, clicking a button just triggers a new HTTP request – each requrest is handled in isolation. And each request receives its own EF core context object – configured as a scoped service.

In Blazor, the routing system responds to URL changes without sending new requests – which means that multiple components are displayed using only the persistent HTTP connnection that Blazor maintains the server. This results in a single dependency injection scope being shared by multiple components. Changes made by one component will affect other components even if the changes are not written to the dbs.

### Discarding Unsaved Data Changes

If sharing a context between components is appealing – will be for some applications, then can embrace the approach and ensure that componetns *discard any changes* when are destroyed.

```cs
public void Dispose()
{
    if(Context!=null)
    {
        Context.Entry(PersonData).State = EntityState.Detached;
    }
}
```

`@implements IDisposable`

### Creating New Dependency Injection Scopes

Must create new dependency injection scopes if want to preserve the model used by the rest of core and have each component just receive its own EF core context object. 

Done by using `@inherits`to set the base class for the componetn `OwningComponentBase`or `<T>`. like: Add:

```cs
@inherits OwningComponentBase
@using Microsoft.Extensions.DependencyInjection
DataContext? Context => ScopedServices.GetService<DataContext>();
```

In this, just use non-generic edition – And the `OwningComponentBase<T>`class defines an additional convenience prop that just provides access to a scoped service of type `T`and that can be useful if a compoent requires only a single scoped service.

```cs
@inherits OwningComponentBase<DataContext>
DataContext? Context => Service;
```

## Understanding the Repeated Query Issue

Blazor responds to changs in state as efficiently as possible but still has to render a component’s content to determine the changes that should be sent to the browser.

```html
<button class="btn btn-primary" @onclick="@(()=>Counter++)">Increment</button>
<span class="h5">Counter: @Counter</span>

@code {
    public int Counter { get; set; } = 0;
//...
}
```

Each time the component is rendered – EF Core sends two identical requests to the dbs, even when the `Increment`just no for data performed. Blazor and EF core are both working the way they should, Blazor must re-render the component’s output to figure out what HTML changes need to be sent to the browser. It has no way of knowing what effect..

### Managing Queries in a Component

This is not a problem for all projs – but – then the best approach is to query the dbs once and re-query only for operations where the user might expect an update to occur. Some apps may need to present the user with an explicit option to re-load the data.

```cs
private async Task UpdateData()
{
    if (Context != null)
    {
        People = await Context.People.Include(p => p.Department)
            .Include(p => p.Location).ToListAsync();
    }
    else
    {
        People = Enumerable.Empty<Person>();
    }
}
```

Performs just the same query but applies the `ToListAsync()`method – which just forces evaluation of the EF core query. The results are assigned to the `People`prop and can be read repeatedly without triggering additional queries.

```cs
private async Task UpdateData(IQueryable<Person>? query=null)
{
    People = await (query ?? Query).ToListAsync();
}

public async Task SortWithQuery()
{
    await UpdateData(Query.OrderBy(p => p.Surname));
}

public void SortWithoutQuery()
{
    People = People.OrderBy(p => p.Firstname).ToList();
}

private IQueryable<Person> Query =>
    Context!.People.Include(p => p.Department)
        .Include(p => p.Location);
```

## Performing Create, Read, Update, and Delete Operations

For, the `List`component contains the basic functionality – just like:

```html
<td class="text-center">
    <NavLink class="btn btn-sm btn-info"
             href="@GetDetailsUrl(p.PersonId)">
        Details
    </NavLink>
    <NavLink class="btn btn-sm btn-warning"
             href="@GetEditUrl(p.PersonId)">
        Edit
    </NavLink>
    <button class="btn btn-sm btn-danger"
            @onclick="@(() => HandleDelete(p))">
        Delete
    </button>
</td>
```

```cs
public async Task HandleDelete(Person p)
{
    if (Context != null)
    {
        Context.Remove(p);
        await Context.SaveChangesAsync();
        await UpdateData();
    }
}
```

### Creating the Details Component

The details component just displays a read-only view of the data, which doesn’t require the Blazor form feature.

## Extending the Blazor Form Features

The Blazor form features are effective but have rough edges – Blazor makes it easy to enhance the way that forms work. Defines a cascading `EditContext`object that provides access to form validation and makes it easy to create custom form components through the events, props..

### Creating a Custom Validation Constraint

Can create components that apply custom validation constraints if the built-in attributes are not sufficient.

# Using Blazor Web Assembly

is a virtual machine running inside the browser. High-level languages are compiled into low-level language-neutral assembler format that can be executed at close to native performance. WebAssembly provides access to the APIs available to Js applications, which mans that WebAssembly applications can access the domain object model. Can access the DOM, use CSS, and initiate async HTTP requests.

Is an implementation of Blazor that runs in the WebAssembly virtual machine. Blazor WebAssembly breaks the dependency on the server and executes the Blazor application entirely in the browser. The result is a true client-side app, with access to all the same features of Blazor server but without need for persistent HTTP connection.

Blazor WebAssembly applications are restricted to the set of APIs the browser provides, which means that not all .NET feature can be used in a WebAssembly application. This doesn’t disadvantage Blazor when compared to client-side frameworks like Angular. But it does mean that feature such as EF core are not available.

## Using Input props to coordinate between components

```ts
export class ProductTableComponetn{
    @Input("model")
    dataModel: Model | Undefined;
}
```

```html
<paProductTable [model]="model"></paProductTable>
```

The child component’s host element acts just as the bridge between the parent and child components, and the input prop allows the component to provide the child with the data it needs.

### Using Directives in Child Component Template

Once the input prop has been defined, the child component can use the full range of data bindings and directives, either by using the data provided through parent or by defining its own. Like:

```html
<table class="table table-sm table-bordered table-striped">
	<thead class="table-light">
	<tr>
		<th></th>
		<th>Name</th>
		<th>Category</th>
		<th>Price</th>
		<th></th>
	</tr>
	</thead>
	<tbody>
	<tr *ngFor="let item of getProducts(); let i = index; let odd=odd;
		let even=even" [class.bg-info]="odd" [class.bg-warning]="even"
		class="align-middle">
		<td>{{i + 1}}</td>
		<td>{{item.name}}</td>
		<td>{{item.category}}</td>
		<td>{{item.price}}</td>
		<td class="text-center">
			<button class="btn btn-danger btn-sm"
					(click)="deleteProduct(item.id!)">
				Delete
			</button>
		</td>
	</tr>
	</tbody>
</table>
```

### Using the Output props to Coordinate between Components

Child components can use output props that define custom events that signal important changes and that allow the parent component to respond when they occur.

just adding an external template and an output prop that will be triggered when the user create a new object.

```ts
@Component({
	selector:"paProductForm",
	templateUrl:"productForm.component.html"
})export class ProductFormComponent{
	newProduct:Product = new Product();
	
	@Output("paNewProduct")
	newProductEvent = new EventEmitter<Product>();
	
	SubmitForm(form:any) {
		this.newProductEvent.emit(this.newProduct);
		this.newProduct=new Product();
		form.resetForm();
	}
}

```

The output prop is called `newProductEvent`and the component triggers when the `submitForm`called.

```html
<form #form="ngForm" (ngSubmit)="SubmitForm(form)">
	<div class="mb-3">
		<label>Name</label>
		<input class="form-control"
			   name="name" [(ngModel)]="newProduct.name"/>
	</div>

	<div class="mb-3">
		<label>Category</label>
		<input class="form-control"
			   name="category" [(ngModel)]="newProduct.category"/>
	</div>

	<div class="mb-3">
		<label>Price</label>
		<input class="form-control"
			   name="price" [(ngModel)]="newProduct.price"/>
	</div>

	<button class="btn btn-primary mt-2" type="submit">Create</button>
</form>
```

The form just contains the std elements, configured using two-way bindings. In the `template.html`need:

```html
<paProductForm (paNewProduct)="addProduct($event)"></paProductForm>
```

The new binding handles the custom event by passing the event obj to the `addProduct`. When the data just passes, the custom event is triggered, and the data binding is evaluated in the context of the parent component. So `$event`just is the `this.newProduct`cuz it’s a form, it’s event is just `submit`, submit triggers the event.

## Projecting Host Element Content

If the host element for a component contains content, can be included in the template using the special `ng-content`element. This is known as *content projection*. It allows components to be created that combine the content in their tempalte within the content in the host element.

```ts
@Component({
	selector: "paToggleView",
	templateUrl: "toggleView.component.html"
})
export class PaToggleView {
	showContent = true;
}
```

defines a `showContent`that will be used to determine whether the host element’s content will be displayed whthin the template just:

```html
<div class="form-check">
	<label class="form-check-label">Show Content</label>
	<input class="form-check-input" type="checkbox" [(ngModel)]="showContent" />
</div>
<ng-content *ngIf="showContent"></ng-content>
```

Then in the template.html file:

```html
<paToggleView>
    <paProductTable [model]="model"></paProductTable>
</paToggleView>
```

### Completing the Component Restructure

So, cuz using the Component combination.

## Using Component Styles

Components can define styles that apply only to the content in their templates, which allows content to be styled by a component without it being affected by the styles defined by its parents or other antecedents, and without affecting the conent in its child and other descendant components.

```ts
styles: ["div {background-color: lightgreen;}"]
```

The `sytles`jsut set to an array, where each item contains a CSS selector and one or more properties.

Or can also use `styleUrls: ["productForm.component.css"]`

## Using Advanced Style Features

Defining styles in components is a useful feature, but you won’t always get the results you expect.

### Setting View Encapsulation

By default, component-specific styles are implemented by writing CSS that applied to the component so that it targets special attributes. 

Known as the component’s *view encapsulation* behavior and what Angular is doing is emulating a feature as the *shadow DOM*, which allows sections of the DOM to be isolated.

## Querying Template Content

Components can query the content of their templates to locate instances of directives or components, which is known as *view children*.

# Using and Creating Pipes

Pipes are small fragments of code that transform data values so they can be displayed to the user in templates. Allow transformation to be defined in self-contained classes.

* Pipes are classes that are used to prepare data for dispaly to the user.
* Allow preparation logic to be defined in a single class that can be used throughout an app, ensuring that data is presented consistently.
* `@Pipe`is applied to a class and used to specify a name by which the pipe can be used in a template.

Pipes are classes that **transform data** before it received by a directive or component. Just look at the built-in pipe:

```html
<td>{{item.price | currency:"USD":"symbol"}}</td>
```

The syntax for applying a pipe is similar to the style used by command prompts. `currency`pipe, formats numbers into currency values – Args to the pipe are separated by colons. `symbol`specifies whether the currency symbol, rather than its code.

## Custom Pipe

Added a file called `addTax.pipe.ts`fore:

```ts
@Pipe({
	name: "addTax"
})
export class PaAddTaxPipe {
	defaultRate = 10;

	transform(value: any, rate?: any): number {
		let valueNumber = Number.parseFloat(value);
		let rateNumber = rate == undefined ?
			this.defaultRate : Number.parseInt(rate);
		return valueNumber + (valueNumber * (rateNumber / 100));
	}
}
```

Pipes are classes to which the `Pipe`decorator has been applied and that implement a method called `transform`.

- `name`-- specifies the name by which the pipe is applied in templates.
- `pure`-- when `true`, is reevaluated only when its input value or its arg are changed. This is default.

Just note that the `transform()`must accept at least one arg, which Ng uses to provdie the data value that pipe formats. The pipe does its work in the `transform`and its result is used by Ng in the binding expression.

### Registering a Custom Pipe

Also in the module’s `declarations`segment.

```html
<div class="my-2">
	<label>Tax Rage:</label>
	<select class="form-select" [value]="taxRate || 0"
			(change)="taxRate=$any($event).target.value">
		<option value="0">None</option>
		<option value="10">10%</option>
		<option value="20">20%</option>
		<option value="50">50%</option>
	</select>
</div>
<!-- .. -->
<td>{{item.price | addTax:(taxRate || 0)}}</td>
```

In applying the custom pipe, have used the `|`character, followed by the value specified by the `name`prop in the pipe’s decorator.

# Partials

Can create partial Sass files that contain little snippets of CSS that you can include in other Sass files. This is a great way to modularize your cass and help keep things easier to maintain. A partial is a Sass file named with a leading underscore – `_partial.scss`fore.

## Modules

Don’t have to write all in a single file, can split it up however you want with the `@use`rule. This rule loads another Sass file as a *module*. – means U can refer to its variables, mixins, and functions in your Sass file with a namespace based on the filename. like:

```scss
@use 'base';

.inverse {
    background-color: base.$primary-color;
    color: white;
}
```

## Mixins

Something in CSS are a bit tedious to write.. A mixin lets you make group of css declarations that you want to reuse throughout your site. Just like:

```scss
@mixin theme($theme1: DarkGray) {
    background: $theme1;
    box-shadow: 0 0 1px rgba($theme1, .25);
    color: #FFF;
}

.info {
    @include theme;
}
.alert{
    @include theme($theme1:DarkRed);
}
.success{
    @include theme($theme1:Darkgreen);
}
```

To create a mixin, just use the `@mixin`directive and give a name – also using the variable `$theme1`inside the {}, can pass in a `theme`of what ever.

## Extend/Inheritance

Using the `@extend`lets you share a set of CSS properties from one selector to another. Just going to create a simple series of messaging for errors… – A placeholder class is a special type of class that only prints when it is extended.

```scss
%message-shared {
    border: 1px solid #ccc;
    padding: 10px;
    color: #333;
}

// this will never print, cuz not extended
%equal-heights {
    display: flex;
    flex-wrap: wrap;
}

.message {
    @extend %message-shared;
}

.success {
    @extend %message-shared;
    border-color: green;
}

.error {
    @extend %message-shared;
    border-color: red;
}

.warning {
    @extend %message-shared;
    border-color: yellow;
}
```

## Operators

Doing math in CSS is helpful, Sass has a handful of std math operators like `+, - * math.div()`and `%`. like:

```scss
@use "sass:math";

.container {
    display: flex;
}

article[role="main"] {
    width: math.div(600px, 960px)*100%;
}

aside[role="complentary"] {
    width: math.div(300px, 960px)*100%;
    margin-left: auto;
}
```

## Attribute Selectors

With both class and ID. like:

`h1[class]{color:silver}`

In HTML, can use this in a number of creative ways – like:

`img[alt]{outline: 3px solid red}`

`a[href][title]{font-weight: bold}`

### Based on extract value

```css
a[href="https://www.google.com"]{font-weight: bold;}
```

`[foo~="bar"]`– select any with an attr contains `bar`in space-separated
`[foo*="bar"]`– select whose value contains the substring
`[foo^="bar"]`-- begin with
`[foo$="bar"]`– end with
`[foo|="bar"]`– equal or begins with en

Fore, has a file name like `figure-1` and `figure-2`, can match all of these fore:

```css
img[src|="figure"]{border: 1px solid gray;}
```

## The case insensitivity identifier

fore: `a[href$='.PDF' i]`, little `i`means the selector will match any `a`element whose ends in `.pdf`

### Selecting Adjacent Sibling Elements

`h1+p {margin-top:0}`

following `h1~p`

## Pseudo-class and element selectors

All without excception, are word or hyphenated phrase preceded by a single colon.

```css
a:link:hover {color:red;}
a:visited:hover{color: maroon;}
a:link:hover:lang(de) {color: gray;}
```

Pseudo class `:root`selects the root element of the document – note that in the HTML – this is **always** the `html`element.

For empty elements like: 

```css
*:empty {display: none}
```

Only child – `:only-child`like:

```css
img:only-child {border: 1px solid black;}
a[href] img:only-child{border: 2px solid black;}
```

only-of-type selection – fore, match images that are the only images inside hyperlinks like:

```css
a[href] img:only-of-type {border:...}
```

`only-of-type`will match any that is the only of its type among all its siblings.

The `:has()`class – `div:has(img) {...}`

## Grid system

uses a series of containers – built with **flexbox** and is fully responsive.

- supports six responsive breakpoints. 
- center and horizontally pad content.
- Rows are wrappers for columns.
- Columns are flexible.
- Gutters are also responsive and customizable.
- Sass variables.

### Variable width content

`col-{breakpoint}-auto`classes to szie columns based on natural width on their content. Like:

Reponsive Classes – Row columns, use responsive `.row-cols-*`to quickly set the number of columns. just like:

```html
<div class="row row-cols-2">
    <div class="col">Column</div>
    <div class="col">Column</div>
    <div class="col">Column</div>
    <div class="col">Column</div>
</div>
```

Columns alignment – use flexbox alignment utilties to vertically and horizontally align columns.

`align-items-start`, center, end.

`justify-content-start`, center, end

```html
<label for="exampleColor" class="form-label">Color picker</label>
<input type="color" class="form-control form-control-color" id="exampleColor" >
```

Datalists – allow you to create a group of `<option>`can accessed fore:

```html
<input class="form-control" list="dataListOptions" placeholder="type to search...">
<datalist id="dataListOptions">
    <option>San</option>
    <option value="new york">New Work</option>
</datalist>
```

