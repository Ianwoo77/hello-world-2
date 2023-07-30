# Working with Files

Describe the featues that the Go stdlib provides for working with files and directories – Go runs on multiple platforms, and the stdlib takes just *platform-neutral* approach so that code cna be written without needing to understanding the file system used by different operating system.

## Reading Files

The key package when dealing with files is the `os`package – provides access to os features – including the file system,  The netural approach adopted by the `os`package leads to some compromises and leans toward **UNIX/Linux**.

- `ReadFile(name)`-- opens the specified and reads content, return `byte`slice
- `Open(name)`– open for reading – `File`struct returned and an `error`.

```go
func loadConfig() (err error) {
	data, err := os.ReadFile("./config.json")
	if err == nil {
		Printfln(string(data))
	}
	return
}
```

The contents of the file are returned as a `byte`slice.

### Decoding the JSON data

For the example configuration file, receiving the contents of the file as a string is not ideal, and a more useful approach would be to parse the contents as JSON – which can be easily done by wrapping up the byte data so that it can be accessed through a `Reader`.

```go
func init() {
	err := loadConfig()
	if err != nil {
		Printfln("Error loading config: %v", err.Error())
	} else {
		Printfln("username: %v", Config.UserName)
		Products = append(Products, Config.AdditionalProducts...)
	}
}

type ConfigData struct {
	UserName           string
	AdditionalProducts []Product
}

var Config ConfigData

func loadConfig() (err error) {
	data, err := os.ReadFile("./config.json")
	if err == nil {
		decoder := json.NewDecoder(strings.NewReader(string(data)))
		err = decoder.Decode(&Config)
	}
	return
}

func main() {
	for _, p := range Products {
		Printfln("Product: %v, Category: %v, Price: $%.2f",
			p.Name, p.Category, p.Price)
	}
}
```

key is `decoder := json.NewDecoder(strings.NewReader(string(data)))`

## Using the File struct to Read a File

And the `Open`function opens a file for reading and returns a `File`value, which represents the open file, and an error, which is used to indicate problems opening the file. And the `File`implements the `Reader`interface.

```go
func loadConfig() (err error) {
	file, err := os.Open("./config.json")
	if err == nil {
		defer file.Close()
		decoder := json.NewDecoder(file)
		err = decoder.Decode(&Config)
	}
	return
}
```

### Reading from a Specific Location

The `File`struct defines methods beyond those required by the `Reader`interface that allows reads to be performed at a specific location in the file.

- `ReadAt(slice, offset)`-- by the `ReaderAt`and perform a read into the slice at the specified pos
- `Seek(offset, how)`– by the `Seeker`and moves the offset into the file for the next read.

## Writing to Files

The `os`just includes functions for writing files.

- `WriteFile(name, slice, modePerms)` – creates a file with specified name, mode, and permissions and writes the contents of the specified `byte`slice.
- `OpenFile(name, flag, modePerms)`– opens with the specified using the flags to control how the files is opened. The result is a `File`and provides access to the file contents. FORE:

```go
func main() {
	total := 0.0
	for _, p := range Products {
		total += p.Price
	}

	dataStr := fmt.Sprintf("Time: %v, Total: $%.2f\n", time.Now().Format("Mon 15:04:05"), total)

	err := os.WriteFile("output.txt", []byte(dataStr), 0666)
	if err == nil {
		fmt.Println("output file created")
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

### Using the File Struct to write to a File

The `OpenFile`opens a file and returns a `File`value – Unlike the `Open`, the `OpenFile`accepts one or more flags to specify how the file should be opened. The flags are defined as constants in the `os`package.

### Writing JSON data to a File

The `File`implements the `Writer`also, which allows a file to be used with the function for fomatting and processing strings like:

```go
func main() {
	cheapProducts := []Product{}
	for _, p := range Products {
		if p.Price < 100 {
			cheapProducts = append(cheapProducts, p)
		}
	}

	file, err := os.OpenFile("cheap.json", os.O_WRONLY|os.O_CREATE, 0666)
	if err == nil {
		defer file.Close()
		encoder := json.NewEncoder(file)
		encoder.Encode(cheapProducts)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

# Installing a Dbs Driver

Use the popular `go-sql-driver/mysql`driver. Just:

```sh
go get github.com/go-sql-driver/mysql
```

- If run the `go mod verify`command from terminal, this will verify that the checksums of the downloaded packages on your machine.

Can run: 

```sh
go get -u github.com/... # just update
```

## Creating a Dbs connection Pool

Now that the dbs is all set up and got a driver installed, the natrual like:

```go
db, err := sql.Open("mysql", "web:pass@snippebox?parseTime=true")
```

`dsn := flag.String("dsn", "root:root@tcp(localhost:3306)/snippetbox", "mySQL")`

```go
func openDB(dsn string) (*sql.DB, error) {
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, err
	}
	if err = db.Ping(); err != nil {
		return nil, err
	}

	return db, err
}

```

## Designing a Dbs Model

In this, going to sketch out a dbs model for the project.

For the `pkg`dir is being used to hold ancillary non-application-specific code.

```go
var ErrNoRecord = errors.New("models: no matching record found")

type Snippet struct {
	ID               int
	Title            string
	Content          string
	Created, Expires time.Time
}

```

Now move on to the `snippets.go`file will contain the code specifcally for working with the snippets.

```go
type SnippetModel struct {
	DB *sql.DB
}

// Insert This will insert a new snippet into the dbs
func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	return 0, nil
}

func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	return nil, nil
}

// Latest will return the 10 most recent created
func (m  *SnippetModel) Latest() ([]*models.Snippet, error) {
	return nil, nil
}
```

### Using the SnippetModel

To usethis, need to establish a new `SnippetModel`struct in the `main`and then inject it as a DI via the applcation struct.

## Executing SQL Statements

Just update the `SnippetModel.Insert()`method like:

```sql
INSERT into snippets(title, content, created, expires)
values( ?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAPM(), INTERVAL ? DAY)))
```

### Executing the query – 

Go provides 3 differernt to executing – 

- `DB.Query()`-- is used to select queries which return multiple rows
- `DB.QueryRow()`-- select for rturns a single row
- `DB.Exec()`is used for statements which don’t return rows.

```go
// Insert This will insert a new snippet into the dbs
func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	stmt := `INSERT INTO snippetbox.snippets(title, content, created, expires)
		values (?, ?, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY ))`

	result, err := m.DB.Exec(stmt, title, content, expires)
	if err != nil {
		return 0, err
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, err
	}

	return int(id), nil
}
```

For the `DB.Exec()`-- this provides two methods – 

- `LastInsertId()`which returns the integer generted by the dbs in response to a command. Typically this will be from an *auto increment* column when inserting a newrow.
- `RowAffected()`– returns the number ofrows affected by the statement.

### Using the Model in our handlers

bring this back to sth  more concrete demonstrate how to call this new code from handlers. like:

```go
func (app *application) createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		// ...
	}

	// create some variables holding dummy data
	title := "0 snail"
	content := "0 snail\nClimb Mount Fuji,\nBut slowly!\n\n- Kobayashi Issa"
	expires := "7"

	// Then pass the data to the Insert() method
	id, err := app.snippets.Insert(title, content, expires)
	if err != nil {
		app.serverError(w, err)
		return
	}

	http.Redirect(w, r, fmt.Sprintf("/snippet?id=%d", id), http.StatusSeeOther) // 303
}
```

## Additional Info

Placeholder parameters – In the code for the `mysql`, where `?`acted as a placeholder for the data we want to insert. The reason for using placeholder parameters to construct our query is to help avoid SQLinjection attacks from untrusted…

Behind the scenes – the `DB.Exec()`works in 3 steps:

1. Creates a new prepared statement on the dbs using the provided SQL.
2. In the second, `Exec()`just passes the parameter values to the dbs. The dbs then executes the prepared statement using these  parameters. Cuz the parametrs are just transmitted later, after the statement has been compiled, the dbs treats them as just **pure data**. They can’t change the *intent* of the statement.
3. It then closes( or deallocates ) the prepared statement on the dbs.

## Single-record SQL Queries

And the pattern for the `SELECT`ing is a single record from the dbs is a little more complicated.So, how do by updating the `Get()`method so that it returns a single specific snippet based on its ID.

```sql
select id, title, content, created, expires from snippets
where expires> UTC_TIMESTAMP() and id = ?
```

Cuz our `snippets`table uses the `id`column as its PK this query will only ever return exactly one row. So in the MySQL, just like:

```go
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	stmt := `select id, title, content, created, expires from snippetbox.snippets 
		where expires> UTC_TIMESTAMP() and id = ?`
	row := m.DB.QueryRow(stmt, id)

	s := &models.Snippet{}

	err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, models.ErrNoRecord
		} else {
			return nil, err
		}
	}

	return s, nil
}
```

### Type Conversions

`rows.Scan()`will automatically convert the raw output from the dbs to the requried native GO types.

### Using the Model in handlers

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}

	s, err := app.snippets.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w)
		} else {
			app.serverError(w, err)
		}
		return
	}
	fmt.Fprintf(w, "%v", s)
}
```

Need to add to the connection string like:

```go
dsn := flag.String("dsn", "root:root@tcp(localhost:3306)/snippetbox?parseTime=true", 
                   "mySQL")
```

# Qurying using the Fixing up feature

EF core supports a feature called *fixing up*– where the data retreived by a dbs context object is **cached** and used to populate the nav props of objects that are created for subsequent queries. This is a feature that – can allow complex queries to be created that obtain related data *more efficiently* than just explicit loading or following nav using the `Include` – like:

```cs
public IEnumerable<Supplier> GetAll() {
    context.Products.Where(p=>p.Suppler!=null && p.Price>50).Load();
    return context.Suppliers;
}
```

`Product`objects that are just related to the `Supplier`and … The sole purpose of this is to populate the EF core cache with data objects. Used `Load()`.

The second uses the context object’s `Suppliers`prop to retrieve the `Supplier`objs - will be executed when the object is enumerated in the Razor so `Load`isn’t required. When the second executed – EF core will automatically examine the data cached from the first request and use that data to populate the `Supplier.Products`.

Understanding the `Fixing up`pitfall – The fixing up means EF core just will populate nav props with objects that it has previously created.  fore, View receives a `Supplier`as its model and follows the `Products`nav props to create a simple table of related `Products`. just like:

Will figure shows the `Products`in the `Soccer` – can see that the related data is just different for each time. This happens cuz have followed NAV props beyond the related data specified in the query.

## Working with Related in a OneMany REL

To prepare – just:

```cs
public IEnumerable<Supplier> GetAll()
{
    return context.Suppliers.Include(s => s.Products);
}
```

And to separate this from the others, add the `SuppliersController`

### Updating Related Objects

Can also make changes by starting with a `Supplier`obj to perform edits via a nav prop.

```html
@model Supplier

@{ int counter = 0; }

<form asp-action="Update" method="post">
    <input type="hidden" asp-for="Id"/>
    <input type="hidden" asp-for="Name"/>
    <input type="hidden" asp-for="City"/>
    <input type="hidden" asp-for="State"/>

    @foreach (Product p in Model.Products!)
    {
        <div class="row">
            <input type="hidden" name="Products[@counter].Id" value="@p.Id"/>

            <div class="col">
                <input name="Products[@counter].Name" value="@p.Name" class="form-control"/>
            </div>
            <div class="col">
                <input name="Products[@counter].Category" value="@p.Category" class="form-control"/>
            </div>Category
            <div class="col">
                <input name="Products[@counter].Price" value="@p.Price" class="form-control"/>
            </div>
            @{ counter++; }
        </div>
    }
    <div class="row">
        <div class="col text-center m-1">
            <button class="btn btn-sm btn-danger" type="submit">Save</button>
            <a class="btn btn-sm btn-secondary" asp-action="Index">Cancel</a>
        </div>
    </div>
</form>
```

To incorporate the `Editor`view into the app, added like:.. To see how the editing process works. When click the `save`the browser sends HTTP req that contains the values required by the MVC model binders to create a `Supplier`object and a collection of `Product`objects.

## Creating new Related Objects

The technique that I described in the previous section can easily adapted to create new related objects. When EF core processes the collection of the `Product`– any object with `Id=0`will be added to the dbs as a new obj. This is a convenient way of creating new objects that will automatically be associated with a new object. This is also a convenient way of creating new objs that will automatically be associated with a `Supplier`.

```html
@model Supplier

@{
    int counter = 0;
}

<form asp-action="Update" method="post">
    <input type="hidden" asp-for="Id" />
    <input type="hidden" asp-for="Name" />
    <input type="hidden" asp-for="City" />
    <input type="hidden" asp-for="State" />
    
    @foreach (Product p in Model.Products!)
    {
        <input type="hidden" name="Products[@counter].Id" value="@p.Id" />
        <input type="hidden" name="Products[@counter].Name" value="@p.Name" />
        <input type="hidden" name="Products[@counter].Category" value="@p.Category" />
        <input type="hidden" name="Products[@counter].Price" value="@p.Price" />
        counter++;
    }
    <div class="row">
        <div class="col">
            <input name="Products[@counter].Name" class="form-control" />
        </div>
        <div class="col">
            <input name="Products[@counter].Category" class="form-control" />
        </div>
        <div class="col">
            <input name="Products[@counter].Price" class="form-control" />
        </div>
    </div>
    <div class="row">
        <div class="col text-center m-1">
            <button class="btn btn-sm btn-danger" type="submit">Save</button>
            <a class="btn btn-sm btn-secondary" asp-action="Index">Cancel</a>
        </div>
    </div>
</form>
```

For this – cuz must take care to include all the existing objects in the HTML form.

# Creating User Management Tools

Create the tools that manage users through ASP.NET core – Users are just managed throught the `UserManager<T>`where `T`stands for representing users in the dbs – here is the `IdentityUser`class. When created the EF core context class, just specified `IdentityUser`as the class to represent users in the dbs. This is just the built-in class that is provided by Core identity – and it provides cure features that are required by most app.

- `Id`– unique ID for the user.
- `UserName`– returns the username.
- `Email`– email address

And this describe the `UserManagement<T>`members – like:

- `Users`– a seq contains the users stored in the dbs
- `FindByIdAsync(id)`– queries the dbs for the user object with specified Id.
- `CreateAsync(user, password)`– stores a new user
- `UpdateAsync(user)`– modifies an existing
- `DeleteAsync(user)`– removes specified.

## Preparing for User Managment Tools

To use, add some namespaces like:

```cs
@using System.ComponentModel.DataAnnotations
@using Microsoft.AspNetCore.Identity
@using Advanced.Pages
```

And, create the `Page/Users`folder in the proj add it to Razor Layout named `_Layout`to the `Page/Users`folder. Then add: `public class AdminPageModel: PageModel{}`-- this will be the base for the page model classes defined. A common base class is just useful when it comes to **Securing** the app.

### Enumerating User Accounts

The dbs is currently empty – going to start by creating a RP that will enumerate user account for future.

```cs
public class ListModel : PageModel
{
    public UserManager<IdentityUser>? UserManager;

    public ListModel(UserManager<IdentityUser>? userManager)
    {
        UserManager = userManager;
    }

    public IEnumerable<IdentityUser> Users { get; set; } = default!;

    public void OnGet()
    {
        Users = UserManager.Users;
    }
}
```

```html
@page
@model Advanced.Pages.Users.ListModel

<table class="table table-sm table-bordered">
    <tr><th>ID</th><th>Name</th><th>Email</th><th></th></tr>
    @if (Model.Users.Count() == 0)
    {
        <tr><td colspan="4" class="text-center">No users Accounts</td></tr>
    }
    else
    {
        foreach (var user in Model.Users )
        {
            <tr>
                <td>@user.Id</td>
                <td>@user.UserName</td>
                <td>@user.Email</td>
                
                <td class="text-center">
                    <form asp-page="List" method="post">
                        <input type="hidden" name="Id" value="@user.Id" />
                        <a class="btn btn-sm btn-warning" asp-page="Editor"
                           asp-route-id="@user.Id" asp-route-mode="edit">Edit</a>
                        <button type="submit" class="btn btn-sm btn-danger">
                            Delete
                        </button>
                    </form>
                </td>
            </tr>
        }
    }
</table>

<a class="btn btn-primary" asp-page="Create">Create</a>
```

The `UserManager<IdentityUser>`class is set up as a service so that it can be consumed via DI. 

## Creating Users

Add a RPs named `Create.cshtml`in the `Users`folder like:

```cs
public class CreateModel : PageModel
{
    public UserManager<IdentityUser> UserManager;
    public CreateModel(UserManager<IdentityUser> usrMgr)
    {
        UserManager=usrMgr;
    }

    [BindProperty]
    public string UserName { get; set; }=string.Empty;
    [BindProperty][EmailAddress]
    public string Email { get; set; }
    [BindProperty]
    public string Password { get; set; }=string.Empty;

    public async Task<IActionResult> OnPostAsync()
    {
        if (ModelState.IsValid)
        {
            IdentityUser usr = new IdentityUser { UserName = UserName, Email = Email };
            IdentityResult result =
                await UserManager.CreateAsync(usr, Password);
            if (result.Succeeded)
            {
                return RedirectToPage("List");
            }
            foreach (IdentityError err in result.Errors)
            {
                ModelState.AddModelError("", err.Description);
            }
        }
        return Page();
    }
}
```

```html
@page
@model Advanced.Pages.Users.CreateModel

<h5 class="bg-primary text-white text-center p-2">Create User</h5>
<form method="post">
    <div asp-validation-summary="All" class="text-danger"></div>
    <div class="mb-3">
        <label>User Name</label>
        <input name="UserName" class="form-control" value="@Model.UserName"/>
    </div>
    <div class="mb-3">
        <label>Email</label>
        <input name="UserName" class="form-control" value="@Model.Email"/>
    </div>
    <div class="mb-3">
        <label>Password</label>
        <input name="UserName" class="form-control" value="@Model.Password"/>
    </div>
    <div class="py-2">
        <button type="submit" class="btn btn-primary">Submit</button>
        <a class="btn btn-secondary" asp-page="List">Back</a>
    </div>
</form>
```

New users are created using the `CreateAsync`– data is managed through the methods provided by the `UserManger<T>`class – Defines 3 props that are subject to model bindign. The RP defines 3… `Username`and `Email`just used to configure the `IdentityUser`, which is combined to the `Password`.

Errors – Returns a seq of `IdentityError`objs.

Click the create and enter the same details into the form – using the values same, can see an error.

# Working with Blazor’s Component Model

The fundamental building blocks of Blazor apps are components. Components define a piece of UI. They encapsulate any data that a piece of UI requires to function. They allow a piece of UI to be reused across an app or even *shared across multiple apps*.

Data can just passed into a component using `Parameter`– define the public API of a component. The syntax for passing data into a component using parameters is the same as defining attributes on a std HTML element – with k-v pair. Key just name, value is data wish to pass to the component.

The data component contains is more commonly referred to as its *state*. Methods on a component define its logic. These manipulate and control that state via the handling of events.

Componnets can be styled via traditional global styling or via *scoped styles*. Scoped allows the component to define its own CSS classes without fear of colliding with other styles in the app.

## Structing Components

Just like when creating regular C# classes – should try to keep your components focused, with a single purpose. Fore, one arg that often aginst this – is that markup and logic should be separated.

## Component Life cycle methods

1. `OnInitialized(Async)`
2. `OnParametersSet(Async)`
3. `OnAfterRender(Async)`

Parent Component Reders – `SetParameterAsync()`–This sets the Component’s parameters and cascading parameters from the `ParameterView`object received from the parent component. If first time, `InInitialized`called, otherwise, `OnParametersSet`called.

And, `OnParametersSet(Async)`run every time the incoming parameters of the component change

And if async version returned a non-completed tsk - the the result of the task will be awaited and then another call to `StateHasChanged()`will be made.

Code handling built-in events will trigger the rendering process – such as `onclick`. Using the `EventCallback<T>`type will trigger it as well.

User-defined events with the type of `Action<T>`or `Func<T>`can also trigger the rendering process via a manual call to the `StateHasChanged()`.

The life-cycles are provided by the `ComponentBase`class.

### The first Render

During the first render, all the component’s life cycle method will be called. for the `SetParametersAsync`-- (only one need to call the base)–

- Sets the value for any parameters the component defines. This happens both the first time and para changed.
- Calls the correct life cycle methods. depends on whether the component is running for the first time.

And the final methos to run are `OnAfterRender(Async)`– both take a boolean indicating if this is the frist time the component has been rendered. So, allows one-time operations to be performed when a component is first rendered. Primary used for Perform Js interop and other DOM-related operations. note that.

### The `async`

One key point about the render is that it ran sync – in the lifecycle, there are no awaited calls in any `async`methods. If:

```cs
protected override async Task OnInitializedAsync(){
    Console.WriteLine("begin");
    await Task.Delay(300);
    Console.WriteLine("End");
}
```

While Blazor was awaiting the `async`call, the component was rendered. It was then rendered second time after the `OnParametersSet`called. Cuz Blazor checks to see if an awaitable task is returned from `OnIintializedAsync`. If there is called `StateHasChanged()`to render the component with the result.

### Dispose – extra life cycle method

There is another – `Dispose()`is used for same purposes in Blazor in .. to clean up – like:

```cs
@implement IDisposable
<h1>
    lifecycle
</h1>
<p>
    Check...
</p>
@code{
	public void Dispose()=>Console.WriteLine(...)
}
```

So, Blazor understands the `IDisposable`interface – when using – useful when using Js iterop.

## Working with Parent and Child Components

Component parameters are declared on a child component – which forms that component’s API. A parent component can then pass data to the child using that API. But component parameters can also be used to define events on the child that the parent can handle.

### The `TrailDetails`Component

Will display the selected trail – passed in via a component parameter like:

```html
<div class="drawer-wrapper @(_isOpen ? "slide" : "")">
    <div class="drawer-mask"></div>
    <div class="drawer">
        @if (_activeTrail is not null)
        {
            <div class="drawer-content">
                <img src="@_activeTrail.Image" />
                <div class="trail-details">
                    <h3>@_activeTrail.Name</h3>
                    <h6 class="mb-3 text-muted">
                        <span class="oi oi-map-marker"></span>
                        @_activeTrail.Location
                    </h6>
                    
                    <div class="mt-4">
                        <span class="mr-5">
                            <span class="oi oi-clock mr-2"></span>
                            @_activeTrail.Length km
                        </span>
                    </div>
                    <p class="mt-4">@_activeTrail.Description</p>
                </div>
            </div>
            
            <div class="drawer-controls">
                <button class="btn btn-secondary" @onclick="Close">Close</button>
            </div>
        }
    </div>
</div>
```

```cs
@code {
    private bool _isOpen;
    private Trail? _activeTrail;
    
    [Parameter, EditorRequired]
    public Trail? Trail { get; set; }

    protected override void OnParametersSet()
    {
        if (Trail != null)
        {
            _activeTrail = Trail;
            _isOpen = true;
        }
    }

    private void Close()
    {
        _activeTrail = null;
        _isOpen = false;
    }

}
```

Using the `OnParametersSet()`method to trigger the drawer sliding into view.

```css
.drawer-mask{
    visibility: hidden;
    position: fixed;
    overflow: hidden;
    top:0;
    right:0;
    left:0;
    bottom:0;
    z-index: 99;
    background-color: #000;
    opacity: 0;
    transition: opacity .3s ease, visibility 0.3s ease;
}

.drawer-wrapper.slide > .drawer-mask {
    opacity: .5;
    visibility: visible;
}

.drawer {
    display: flex;
    flex-direction: column;
    position: fixed;
    top:0;
    bottom:0;
    width: 35em;
    overflow-y: auto;
    overflow-x:hidden;
    background-color: white;
    border-left: 0.063em solid gray;
    z-index: 100;
    transform: translateX(110%);
    transition: transform 0.3s ease, width 0.3s ease;
}

.drawer-wrapper.slide > .drawer {
    transform: translateX(0);
}

.drawer-content {
    display: flex;
    flex:1;
    flex-direction: column;
}

.trail-details {
    padding: 20px;
}

.drawer-controls {
    padding: 20px;
    background-color: #fff;
}
```

The `translateX(110%)`moves the drawer off the right-hand side of the screen.

Need to define the event as a delegate of type `Action<Trail>`– allows us to pass the trail that this Card is displaying back to the parent.

# Observables

Fore, the array represents a *collection* values – An array also contains its data at the moment of creation. Fore a `Promise`just represents data that has been requestsed but not arrived. To do anything with that data, need to *unwrap* the promise using the `.then`method. like:

```js
let userRequest = getUserFromAPI();
userRequest.then(data=>...)
```

A `Promise`allows the core process to go on doing things elsewhere, while the backend rustles various dbs indexes looking fro our user. Once the request returns, our process peeks inside the `.then`to see what to do. Observables are like arrays in that they are async – eacn event in the collection arrives at some indeterminate point in the future. This is just distinct from a collection of promises (like `Promise.all`). 

## Running a Timer

```ts
import {Observable} from 'rxjs';
let tenSecond$ = new Obversable(observer=> {
    let counter=0;
    observer.next(counter);
    let interv = setInterval(()=> {
        counter++;
        observer.next(counter);
    }, 100);
    return function unsubscribe() {clearInterval(interv);};
});
```

Technically, an `observer`is just any obj that has the `next, error, and complete.`

The `next()`method is how an observable announces to the subscriber that it has a new value available for consumption. This just run when someone subscribe to it. This return another function – this inner function runs whenever a listener unsubscribes from the srouce observable. 

Remember – each subscriber gets their own instance of the ctor.

```js
import {interval} from 'rxjs';
let tenthSecond$= interval(100);
tenthSecond$.subscribe(console.log);
```

### Piping Data through Opertors

An operator is a tool provided by `RxJS`that allows you to manipulate the data in the observable as it strems through.

```js
interval(100).pipe(exampleOperator());
```

For the RxJS, there is also a `map`func – is `sync`– even though new data arrives over time,  this map immediately modifies the data and passes it on. Like:

```js
tenthSecond$.pipe(map(num=> num/10)).subscribe(console.log);
```

### For User Input

```js
function trackClickEvents(element) {
    return new Observable(ob=> {
        let emitClickEvent= ev=>observer.next(ev);
        element.addEventListener('click', emitClickEvent);
        return ()=> element.removeEventListener(emitClickEvent);
    })
}
```

Just use the ctor to build an observable that streams click events from an arbitrarty element. note that Rx provides a `fromEvent`creation *operator* for extractly this case. Takes a DOM element.., or other event-emitting object, and an event name as parameters and returns a stream that firs whenever the event fires on the element. like:

```js
let startClick$= fromEvent(startButton, 'click');
let stopClick$ = fromEvent(stopButton, 'click');
startClick$.subscirbe(()=> {
    tenthSecond$.pipe(map(item=>item/10),
                     takeUntil(stopClick$))
    .subscribe(num=>resultArea.innerText=num+'s');
});
```

When the Start clicked – `tenthSecond$`runs its ctor – cuz there’s a subscribe call at the end of the inner chain. `takeUntil`is an operator that attaches itself to an observable stream and *takes* values from that stream *until* the observable that is passed in as an arg emits a value. When Stop pressed, `Rx`cleans up both the interval and the Stop click handler.

### Drag and Drop

The difficult part of dealing with a dragged element comes in tracking all of the events that fire, maintaining state and order without devolving into a horrible garbled mess of code.

Rx’s lazy subscription model just means that we are not tracking any `mousemove`events until the user actually drags the element – Additionally, `mousemove`are fired sync.

```ts
import { fromEvent, map, takeUntil } from "rxjs";

let draggable = <HTMLElement>document.querySelector('#draggable');
let mouseDown$ = fromEvent<MouseEvent>(draggable, 'mousedown');
let mouseMove$ = fromEvent<MouseEvent>(document, 'mousemove');
let mouseup$ = fromEvent<MouseEvent>(document, 'mouseup');

mouseDown$.subscribe(() => {
    mouseMove$
        .pipe(
            map(event => {
                event.preventDefault();
                return {
                    x: event.clientX,
                    y: event.clientY,
                };
            }),
            takeUntil(mouseup$)
        ).subscribe(pos => {
            draggable.style.left = pos.x + 'px';
            draggable.style.top = pos.y + 'px';
        });
});
```

The initiating observable, `mouseDown$`is subscribed – in the subscription, each `mouseMove$`is mapped, so that the only data passed on are the current coordinates of the mouse. and `takeUntil`is used so that once the mouse button is released, everything cleaned up.

## Using a Subscription

There is just one more vocabulary word – while piping through an *operator* returns an observable. A call to `.subscribe()`returns a `Subscription`– are not a subclass of `Observable`-- is used to keep track of a specific subscription to that `Observable`.

This means that whenever the program no longer needs the values from the particular observable stream – it can use the subscription to *unsubscribe from all future events*.

`aSubscription.unsubscribe();`

```ts
of('hello', 'world', '!').subscribe(console.log);
// easy creation of an observable out of a unknown data source
```

So, it’s the simplesst way to crate an observable of arbitrary data. If you are just struggling with the `map`

```ts
of('foo', 'bar', 'baz').pipe(
    map(word => word.split(''))
).subscribe(console.log);
```

The `take`-- The `take`is related to do with `takeUntil`– simplifies things – passed a single integer arg, and takes that many events from observable before it unsubscribes.

```ts
interval(100)
    .pipe(
        map(n => n + 1), take(3)
    ).subscribe(console.log);
```

The `delay`operator – is passed an integer arg and delays all event coming through the observable chain by ms.

```ts
interval(1000)
    .pipe(
        take(5),
        map(val => val * 5),
        delay(5000)
    )
    .subscribe(console.log);
```

## Using universal border-box sizing

Can do this with the universal selector `*`which targets all elements on the page and:

```css
:root {
    box-sizing: border-box;
}
*, ::before, ::after {
    box-sizing: inherit;
}
```

CSS table layouts – like:

```css
.container {
    display: table; /* make the container resemble a table */
    width : 100% ; /* fill its container's width */
}
.main {
    display: table-cell;
    //...
}
.sidebar {
    display: table-cell;
}
```

`table`just not expand to 100%. and margin is not useful, so add `border-spacing`.

### Collapsed Margins

When top and/or bottom margins are adjoining – they overlap, combining to form a single margin.

### Spacing element within a container

The first button’s top-margin plus the container’s top padding – producing that’s uneven , so fixing this in :

```css
.button-link + .button-link {
    margin-top: 1.5em;
}
/* or use */ 
body * + * {
    margin-top: 1.5em;
}
```

## BFC

To achieve the layout, need to establish sth called a block formatting context for the media body. is a region of the page in which elements are laid out. Can just using:

```css
.media-body{
    display: flow-root;  /* for BFC */
    margin-top: 0;
}
```

Or using `overflow: auto;`, create a BFC.

## Sass @import and Partials

Transpiled directly.

```scss
@import "colors";
body {
    font-family:...;
    color: $myBlue;
}
```

## @mixin and @include

The `@mixin`lets you create css code that is be reused through the website, and the `@include`is created to let you use the `mixin`. like:

```scss
@mixin important-text {
    color: red;
    font-size: 25px;
    font-weight: bold;
    border: 1px solid blue;
}
.danger {
    @include important-text
}
// ...
@mixin bordered($color, $width) {
    border: $width solid $color;
}

.myArticle {
    @include bordered(blue, 1px);
}
```

### Default Values for a Mixin 

```scss
@mixin bordered($color:blue, $width: 1px) {//...
}
```

## @Extend and inheritance

The `@extend`lets you share a set of css properties from one selector to another. like:

```scss
.button-basic{
    border: none;
    padding: 15px 30px;
    //...
}

.button-report{
    @extend .button-basic;
    background-color: red;
}
```

# Modules

The root module descries the app to Ng – setting up essential features such as components and services. Feature module are useful for adding structure to complex projects, making them eaxier to manage and maintain.

Modules are classes to which the `@Ngmodule`decorator has been applied. The properties used by the decorator have different meaning for root and feature modules. There is no model-wide scope for providers – which means that the providers defined by a feature module will be available as though they had been defined by the root module. Every app must have a root module, but the use of feature modules is entirely optional.

## Root Module

Conventionally defined in a file named `app.module.ts`in the `src/app`folder. There can be multiple modules in a project, but the root module is the one used in the bootstrap file.
