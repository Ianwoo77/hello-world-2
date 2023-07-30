# Automating Tasks and Shell ScriptingHere is a list of the most commonly found shells fore:

- Almquist Shell – Written as BSD-licensed replacement for the Bourne shell.
- Bash
- dsh…

By default, Ubuntu uses the Bourne-again SHELL (bash), it is also aliased to `/bin/sh`, so whenever you run a shell script using `sh`notation, you are just using `bash`unless you have just chosen to use a different shell.

## Basic Shell control

Ubuntu includes a rich assortment of capable– shells, Can run multiple commands on a single command line by using a semicolon to separate commands.

```sh
w; free; df
```

## Writing and executing a shell script

```sh
#!/bin/sh
alias ll= 'ls -L'
alias ldir='ls -aF'
alias copy='cp'
```

This just creates comand *aliases*, or convenient shorthand forms of commands. The `ll`provides a long directory listing, and `lidr`ls but prints indicators. in the shell:

`./myenv`

## Sotring Shell scripts for system-wide access

After u can execute the command, should be use `ldir`from the command line to get a list of files under the current directory and `ll`to get a list of files. Can make these commands available for everyone on your system by putting htem in the `/etc/bashrc`.

### Interpreting Shell scripts through Specific Shells

The majority of shell scripts use a `#!`at the beginning to control the type of shell used to run the script. #! tells the Linux kernel that a specific command is to be uesd to interpret the contents of the file. Using a shebang line.

### Using Variables in Shell Scripts

When writing shell scripts for Linux, work with three types of variables – 

- Environment variables – can use these, which are just part of the system environment - can define new variables, can also modify some of them
- Built-in variables – such as options used on the command are provided by the Linux. Unlike environment, cannot modify built-in
- User variables – Are defined within a script when U write a shell script, can use and modify them.

Assigning –  like `lcount=0`, To store a string: `myname=Ian`, If string has embedded spaces, use “”.

Accessing – just can access the variable of .. by prefixing the variable name with a dollar sign. like: `lcount=$var`

### Positional Parameters

Passing options from the command line or from another shell to your shell program is possible. $1, $2 fore. If a shell fore `mypgm`expects two parameters, can invoke the shell program woith only one parameter, the first name – fore:

```sh
#!/bin/sh
#Name display program
if [ $# -eq 0 ]; then
    echo "Name not Provided"
else
    echo "Ur name is "$1
fi

```

So the special `$#`stores the total number of the arguments.

using positional parameters to access and retrieve variables from the command line – Using positional parameters in scripts can be helpful if you need to use command lines with piped commands.

## Built-in Variables

- `$#`-- The number of positional parameters passed to the shell program
- `$?`– The completion code of the last command or shell program
- `$0`– The name of the shell program
- `$*`– single string of all args

## bash Expressions

For strings test, just use `=`, and `!=`.

For numeric comparsion – `-eq, -ge, -le, -ne, -gt, -lt`.

For file operators – `-d, -f, -r, -s, -w, -x`.

Logical operators – use logical like `!, -a, -o`, -a logical and, -o, logical or

### For statement

Use the `for`to execute a set of commands once each time a specified condition is `true`.

## Loading the Linux Kernel

In a general sense, the kernel manages the system resources – As theuser, do not often interact with the kernel. Linux just refers to each appliation as a *process*, and the kernel assisns each proces a number called Process ID (PID). Traditionally the Linux kernel loads and runs a process named *init*– which is also known as the **ancestor of all process**.

### Starting and Stopping Services with `systemd`

Ubunut uses `systemd`as a modern replacement for `init`. It was created by red hat and has seen new-universal adoption across distributions. The job of it is to manage services that run on the system and is comprised of a set of basic building blocks.

Note that `systemd`is the mother of all processes and is reponsible for bringing the Linux kernel up to a state where work can be done. To do this, it strats by mouting the file systems that are defined in `/etc/fstab`, including swap files or partitions.

# Creating HTTP Clients

Describe the stdlib features for making HTTP requests, allowing apps to make use of web servers. The features of the `net/http`package are used to create and send request and procss reponses.

```go
func init() {
	http.HandleFunc("/html", func(writer http.ResponseWriter, request *http.Request) {
		http.ServeFile(writer, request, "./index.html")
	})

	http.HandleFunc("/json", func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json")
		json.NewEncoder(writer).Encode(Products)
	})

	http.HandleFunc("/echo",
		func(writer http.ResponseWriter, request *http.Request) {
			writer.Header().Set("Content-Type", "text/plain")
			fmt.Fprintf(writer, "Method: %v\n", request.Method)
			for header, vals := range request.Header {
				fmt.Fprintf(writer, "Header: %v: %v\n", header, vals)
			}
			fmt.Fprintln(writer, "-----")
			data, err := io.ReadAll(request.Body)
			if err == nil {
				if len(data) == 0 {
					fmt.Println(writer, "No Body")
				} else {
					writer.Write(data)
				}
			} else {
				fmt.Fprintf(os.Stdout, "Error reading body : %v\n", err.Error())
			}
		})
}
```

This `init()`in creates routes that generate HTML and JSON responses.

## Sending Simple HTTP Requests

The `net/http`package provides a set of convenience functions that make just basic HTTP requests. just:

- `Get(url)`– this sends a get requests to the specified HTTP or HTTPs URL. results is a `Response`and an `error`that reports problems
- `Head(url)`- this sends a `HEAD`request to the specified HTTP.. Also, a `Response`and an `error`.
- `Post(url, contentType, reader)` - sends a post – with a specified `Content-Type`, the content for the form is provided by the specified `Reader`-- result also.
- `PostForm(url, data)`– with the `Content-Type`set to `application/x-www-form-urlencoded`. The content for the form is provided by a `map[string][]string`.

```go
func main() {
	Printfln("Starting HTTP Server")
	go http.ListenAndServe(":5000", nil)

	response, err := http.Get("http://localhost:5000/html")
	if err == nil {
		response.Write(os.Stdout)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

For this, the server is started in a goroutine to prevent it from blocking and allow the HTTP request to be sent within the same app. And the `Response`struct describes the response sent by the HTTP server and defines the fields and methods: 

- `StatusCode, Status, Proto, Header, Body`
- `Trailer`– returns a `map[string][]string`contains trailer
- `Close`– bool returns `true`if the response contains a `Connection`header to set to `close`, which indicates that HTTP connection should be closed.
- `Uncompressed`– `ture`if server sent a compressed response that was decompressed
- `Request`– returns the `Request`that was used to obtain the response.
- `TLS`– details of the HTTPs
- `Cookies()`– return a `[]*Cookie`, contains `Set-Cookie`in the repsonse
- `Location()`-- returns the `URL`from the response `Location`header
- `Write(writer)`-- writes a summary of the response to the specified writer.

For, this, the `Writer`is convenient when just want to see the response, but most will check the status code like:

```go
response, err := http.Get("http://localhost:5000/html")
if err == nil && response.StatusCode == http.StatusOK {
    data, err := io.ReadAll(response.Body)
    if err == nil {
        defer response.Body.Close()
        os.Stdout.Write(data)
    }
    response.Write(os.Stdout)
} else {
    Printfln("Error: %v, status code: %v", err.Error(), response.StatusCode)
}
```

Used the `ReadAll()`defined in the `io`to read the response `Body`into a `byte`slice.

And, when responses contain data, such as JSON, can be parsed into Go values like:

```go
response, err := http.Get("http://localhost:5000/json")
if err == nil && response.StatusCode == http.StatusOK {
    defer response.Body.Close()
    data := []Product{}
    err = json.NewDecoder(response.Body).Decode(&data)
    if err == nil {
        for _, p := range data {
            Printfln("name: %v, Price: $%.2f", p.Name, p.Price)
        }
    } else {
        Printfln("Decode error: %v", err.Error())
    }
}...
```

## Sending POST requests

The `Post`and `PostForm`functions are used to send `POST`– and the `PostForm`encoded a map of vlaues form data.

```go
formData := map[string][]string{
    "name":     {"Kayak"},
    "category": {"Watersports"},
    "price":    {"279"},
}
response, err := http.PostForm("http://localhost:5000/echo", formData)

if err == nil && response.StatusCode == http.StatusOK {
    io.Copy(os.Stdout, response.Body)
    defer response.Body.Close()
} else {
    Printfln("Error: %v, Status code : %v", err.Error(), response.StatusCode)
}
```

So, HTML forms support multiple values for each key – which is shy the vlaues in the map are slices of strings.

### Parsing a Form using a Reader

The `post`sends a `POST`to the server and creates the request body by reading content from a `Reader`.

```go
var builder strings.Builder
err := json.NewEncoder(&builder).Encode(Products[0])
if err == nil {
    response, err := http.Post("http://localhost:5000/echo",
                               "application/json", strings.NewReader(builder.String()))
    if err == nil && response.StatusCode == http.StatusOK {
        io.Copy(os.Stdout, response.Body)
        defer response.Body.Close()
    } else {
        Printfln("Error: %v", err.Error())
    }
} else {
    Printfln("Error: %v", err.Error())
}
```

## Sentinel erros and `errors.Is()`

To check whether an error matches a specific value – `sql.ErrNoRows`is just an example is known as **sentinel error** can roughly define as an `error`stored in an global variable. Typically create them using the `errors.New()`func. In older Go the idiomatic way to check if an error matched – 

```go
if err == sql.ErrNoRows {}
```

From 1.13, onwards it is better to use the `errors.Is()`instead like:

```go
if errors.Is(err, sql.ErrNoRows) {}
```

Go 1.13 intoduced the ability to *wrap* errors to add additiona info. And if an sentinel error is just wrapped, then the old style of checking for a match will cease to work. `errors.Is()`works by *unwrapping* errors.

### Short-hand single-record Queries

In practice, can just shorten the code, by leveraging the fact that errors from `DB.QueryRow()`, are defined.

```go
err := m.DB.QueryRow("Select ...", id).Scan(&s.ID, ...)
```

## Multiple-record SQL Queries

Loot at the pattern for executing SQL which return multiple rows. Updating the `SnippetModel.Latest()`method.

```sql
select id, title, content, created, expires from snippets
where expires> UTC_TIMESTAMP() Order by created DESC limit 10
```

```go
// Latest will return the 10 most recent created
func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	stmt := `select id, title, content, created, expires from snippetbox.snippets
		where expires > utc_timestamp() order by created limit 10`

	// use the Query() to execute:
	rows, err := m.DB.Query(stmt)
	if err != nil {
		return nil, err
	}

	// defer Close() ensure the sql.Rows results is always properly 
    // closed before the method returns
	defer rows.Close()

	snippets := []*models.Snippet{}

	for rows.Next() {
		s := &models.Snippet{}
		err = rows.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
		if err != nil {
			return nil, err
		}
		snippets = append(snippets, s)
	}

	// when the Rows.Next() finished, call rows.Err() to retrieve any error, it's important!
	if err = rows.Err(); err != nil {
		return nil, err
	}

	return snippets, nil
}
```

Using the Model in handlers – 

## Transactions and other Details

The `database/sql`essentially provides a std interface between Go app and the world of the SQL dbs.

### Managing NULL values

Very roughly, the firx of this is to change the field you are scanning into from a `string`to a `**sql.NullString**`type. But as a rule, the easiest thing to do is simply avoid `NULL`altogether. Set `NOT NULL`constraints.

### Working with Transactions

Important to realize that calls to `Exec(), Query(), QueryRow()`… Can use any *connection* from the pool. So, even if you have two call to `Exec()` – there is no guarantee that they will use the same dbs connection.

Sometimes this isn’t acceptable. FORE, lock the tble. 

To guarantee the same connection is used, Can wrap multiple statements in a transaction. Like:

```go
type ExampleModel struct {
    DB *sql.DB
}
func (m *ExmapleModel) ExampleTransaction() error {
    tx, err := m.DB.Begin()
    if err != nil {...}
    
    // call Exec() on the trasaction, passing statement and any parameters
    _, err := tx.Exec("insert into...")
    if err != nil {
        tx.Rollback() // abort the transaction
        return err
    }
    
    // carry out others... and commit if no errors occur
    err = tx.Commit()
    return err
}

```

The transaction just ensures that eigher:

- All statements are executed successfully or
- No statements are eecuted and the dbs remains unchanged.

## Managing Connections

The `sql.DB`connection pool is made up of connections which are either *idle* or *in-use*…

### Prepared Statements

The `Exec, Query, QueryRow`all use prepared statements behind the scenes to help prevent SQL injection attacks. They set up a prepared on the dbs connection, run it with the parameters provided.. – Inefficient – cuz are creating and re-creating the same prepared statements every single time.

In theory – use of the `DB.Prepare()`to create own prepared statement once, and reuse that instead. fore:

```go
insertStmt, err : = db.Prepare("insert into...")
if err != nil {...}
return ...

//.. in other func
_, err := m.InsertStmt.Exec(...)
```

Cuz Go uses a pool of *many dbs connection* – first time a prepared is used it gets created on a partcular connection. The `sql.Stmt`object then remembers which connection in the pool was used. The next time, the `sql.Stmt`will attempt to use the same dbs connection again. if closed, re-prepared on another connection. For most cases, using regular `Query,...`without preparing statements.

## Dynamic HTML Templates

- Pass dynamic data to HTML templates
- Use various **actions and functions** in Go’s `html/template`package
- Create a *template cache* so aren’t reading from disk for each HTTP request

Just add some code to render a new `show.page.html`template.

# Creating New Related Objects

When EF core processes the collection of like `Product`objects that have been created by the MVC model binder, Any whose `Id`is zero will be added to the dbs. And just note that must include from data vlaues for all of the existing data as well as creating elemetns.

## Changing Relationships

A little more work is just required when it comes to changing the `Supplier`that a `Product`is related to.

```html
<div class="col">
    <select name="Products[@counter].SupplierId">
        @foreach (Supplier s in Model.Item2)
        {
            if (p.Supplier == s)
            {
                <option selected value="@s.Id">@s.Name</option>
            }
            else
            {
                <option value="@s.Id">@s.Name</option>
            }
        }
    </select>
</div>
```

Receiving two data objects as thew view model just makes it easier to generate HTML elements that allow the user to make changes.

```cs
else if (ViewBag.SupplierRelationshipId == s.Id)
{
    @await Html.PartialAsync("RelationshipEditor", (s, Model))
}
```

The new element add a Change button – targets the `Change`action on the controller.

```cs
[HttpPost]
public IActionResult Change(Supplier supplier)
{
    IEnumerable<Product> changed = supplier.Products!
        .Where(p => p.SupplierId != supplier.Id);
    if(changed.Count() > 0)
    {
        var allSuppliers = supplierRepo.GetAll().ToArray();
        var currentSupplier = allSuppliers.First(s=>s.Id==supplier.Id);
        foreach(var p in changed)
        {
            Supplier newSupplier = allSuppliers.First(s => s.Id == p.SupplierId);
            newSupplier.Products = newSupplier.Products!
                .Append(currentSupplier.Products!.First(op => op.Id == p.Id)).ToArray();
            supplierRepo.Update(newSupplier);
        }
    }

    return RedirectToAction("Index");
}
```

### Simplifying the Change Code

There is a simpler way – The `Product`has a `SupplierId`– store the value – The `Products`is for convenient nav only, and when the rel for a `Product`cahnged – EF core has to update the `Products`table to reflect the change.

```cs
[HttpPost]
public IActionResult Change(long id, Product[] products)
{
    dbContext.Products.UpdateRange(products.Where(p => p.SupplierId != id));
    dbContext.SaveChanges();

    return RedirectToAction("Index");
}
```

Changing the parameters for the action method tells MVC *model binder* that **I now require the `Id` value for the `Supplier` whose relationships the user is changing and `Products`related to the `Supplier`**.

Just using LINQ to filter out those `Product`objects that have not changed and pass those that have to the `DbSet<T>.UpdateRange()`– allows to update several objects at once. Call the `SaveChanges()`to send the changes to the dbs and then redirect the browser to the `Index`.

## Creating User Management Tools

Users are managed through the `UserManager<T>`class – `T`is the class chosen to represent users in the dbs. Specified the `IdentityUser`as the class to represent users in the dbs. `Id, UserName, Email`.

- `Users`– returns a seq containing the users stored in the dbs.
- `FindByIdAsync(id)`– queries the dbs for the user object with specified ID
- `CreateAsync(user, password)`, and `UpdateAsync, DeleteAsync`, user as param.

And the `AdminPageModel`just inherited from `PageModel`and represent to securing the app. Then the `ListModel`inherited from the `AdminPageModel`. Just defined the `UserManger`

## Validating Passwords

One of the most common requirements, especially for corporate app - is to enforce a password policy. like:

```cs
builder.Services.Configure<IdentityOptions>(opts =>
{
    opts.Password.RequiredLength = 6;
    opts.Password.RequireNonAlphanumeric = false;
    opts.Password.RequireLowercase = false;
    opts.Password.RequireUppercase = false; // uppercase
    opts.Password.RequireDigit = false;
});
```

### Validating User Details

Validation is also performed on usernames and e-mail addresses when accounts are created. And Validation can be configured with the options pattern, just using `User`prop defined by the `IdentityOptions`class.

- `AllowedUserNameCharacters`
- `RequireUniqueEmail`– bool fore:

### Editing Users

To add support for editing users, add a RPs named `Editor.cshtml`like:

```cs
public class EditorModel : AdminPageModel
{
    public UserManager<IdentityUser> UserManager;
    public EditorModel(UserManager<IdentityUser> userManager)
    {
        UserManager = userManager;
    }

    [BindProperty]
    public string? Id { get; set; }
    [BindProperty]
    public string? UserName { get; set; }
    [BindProperty]
    [EmailAddress]
    public string? Email { get; set; }
    [BindProperty]
    public string? Password { get; set; }

    public async Task OnGetAsync(string? id)
    {
        IdentityUser user= await UserManager.FindByIdAsync(id);
        Id=user.Id;
        UserName=user.UserName;
        Email=user.Email;
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if(ModelState.IsValid)
        {
            IdentityUser user = await UserManager.FindByIdAsync(Id);
            user.UserName = UserName;
            user.Email = Email;
            IdentityResult result= await UserManager.UpdateAsync(user);

            if(result.Succeeded && !string.IsNullOrEmpty(Password))
            {
                await UserManager.RemovePasswordAsync(user);
                result = await UserManager.AddPasswordAsync(user, Password);
            }

            if(result.Succeeded)
            {
                return RedirectToPage("List");
            }

            foreach(IdentityError error in result.Errors)
            {
                ModelState.AddModelError("", error.Description);
            }
        }
        return Page();
    }
}
```

The `Editor`uses the `UserManger<T>.FindByIdAsync`to locate the user, querying the dbs with the `id`value received through the routing system, and received an arg to the `OnGetAsync`method. And, when the users submit the form the `FindByIdAsync()`is used to query the dbs for the `IdentityUser`object– which is updated with the binder. then:

```cs
await UserManger.RemovePasswordAsync(user);
result = await UserManger.AddPasswordAsync(user, Password);
```

The `Editor`page changes the password only if the form contains a `Password`value and if the updates for the `UserName`and Email field..

### Deleting Users

The last feature need for basic user management is the ability to delete users. Just:

```cs
public async Task<IActionResult> OnPostAsync(string id)
{
    IdentityUser user = await UserManager!.FindByIdAsync(id);
    if (user != null)
    {
        await UserManager.DeleteAsync(user);
    }
    return RedirectToPage();
}
```

The `List`page already displays a `Delete`button.

# Handling DOM Events

Blazor has its own events system that was wraps the std DOM events, allowing us to work with them natively.

`@onEVENTNAME="Handler"`

With the `TrailCard`updated, all left to do is handle the event in the `HomePage`.

```cs
private void HandleTrailSelected(Trail trail) {
    _selectedTrail= trail;
    StateHasChanged();
}
```

Note there are just some cases where this *manual* control over re-reners is – Use a different type to define our event on the `TrailCard`using `EventCallback`– Blazor just will **automatically** call the `StateHasChanged()` on the component that handles the event.

```html
<button class="btn btn-primary" @onclick="@(async() => await OnSelected.InvokeAsync(Trail))">
    View
</button>
```

```cs
[Parameter]
public EventCallback<Trail> OnSelected {get;set;}
```

When using `EventCallback`, a null check is not required. And the componetn parameter is now typed.

```html
<TrailCard Trail="trail" OnSelected="trail=>_selectedTrail=trail" />
```

## Styling Components

The styling is an important element to building – 

- Global styling
- Scoped styling

Scoped styles are the opposite – A stylesheet is created for a specific component, and any classes defined in it are made unique to that componetn using a unique identifier produced during the building process. 

NOTE – it is possible to combine it with CSS preprocessors.

Glboal is the default method when building apps – This is how have been styling – Can cause some issues when developing larger apps. And making changes to global styles can also be cumbersome.

### Scoped Styling

Allows a developer to create styles that affect only a certain component in the application. In app, this is done by creating a stylesheet with the same name as the component. To do this, just *same name as the component*.

When using like this, there will be a lot of stylesheets dotted around the app. Adding each and every one of them to the host page would be tedious and difficult to maintain. What Blazor does as part of the build process is *bundle all the styles* from the various into a single. Just named `[ProjectName].style.css`. fore:

`BlazingTrails.Client.styles.css`.

In the index.html:

```html
<link href="BlazingTrails.Client.style.css" rel="Stylesheet" />
```

Now for components, has a unique attribute applied to it. just like `b-[uniqueID]`.

### Global Styles can still have an effect

If use scoped styles and nothing else in your app – then what about .. Using scoped doesn’t make components immune from the std behavior of CSS.

## Using CSS preprocessor in Blazor

Whether choose to use global styles – scoped, or mix – can still leverage the preprocessors. For these, provides similar feature sets, – 

- Mixins
- Variables
- Nesting
- Importing

### Intergating a CSS preprocessor

Using js tools or using .NET tools. Will use a tool called `Dart SASS`-- which can install an NPM package called `SASS`, then going to use MSBuild to call this tool during the build process. For the new `scss`just using nesting.

Note: in the root of proj, create a new file called `package.json`and add:

```json
{
  "scripts": {
    "sass": "sass"
  },
  "devDependencies": {
    "sass": "1.62.0"
  }
}
```

The first target will check NPM… 

## Routing

In more modern server-based frameworks such as MVC or Razor pages, those pages are dynamically compiled on the server before being sent to the client.

Fore the app, just adding a search function to the app, this is going to allow the user to search for a trail by name or a location.

# Understanding the Root Module

Every Ng has at least one module – known as the root module – The root is conventionally defined called `app.module.ts`in the `src/app`, contains a class to which the `@NgModule`decorator has been applied. Just note that the Angular App can be run in different environments – such as web browsers and native app containers.

The job of the bootstrap file is to select the platform and identify the root module. – `main.ts`file.

```ts
platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));
```

When defining the root module, the `@NgModule`used , and props:

- `imports`– specifies the modules that are required to support directives, components, pipes
- `declarations`– Specify the directives, components, and pipes in the app.
- `providers`– defines the service provides that will be used by the module’s injector.
- `bootstrap`-- root component for the app.

## Understanding the imports prop

`imports`used to list the other modules that the app requires. Fore, the `BrowserModule`provides the functionality required to run the Ng apps in web browsers… The `imports`is also used to declare depednencies on custom modules.

### `declaration`prop

is used to provide Ng with a list of directives, components ,and pipes.

And the `providers`is used to define the service providers that will be ued to resovle dependenceis when there are no suitable providers available.

And the `bootstrap`specifies the root component or components for the app. When Ng processes the main HTML document – `index.html`– inspects the root components and applies them using the value of the `selector`prop.

Also can specify multiple Root components in the `app.module.ts`file like:

```ts
bootstrap: [ProductFormComponent, ProductTableComponent]
```

Then in the index.html file:

```html
<paProductTable></paProductTable>
<pa-productform></pa-productform>
```

## Creating Feature Modules

The root module has become increasingly complex – with a long list of `import`statements to load `JS`modules and a set of classes in the `declarations`prop of `@ngModule`.

For this, *Feature modules* are used to group related functionality so that it can be *used as a single entity* – Just like Ng modules such as `BrowserModule`. For this, don’t have to `import`and `declarations`for each individual directive, component and pipes.

When create – can choose to focus on an app function  or elect to group a set of related building blocks that provide your app infrastructure. Feature module use the same `@NgModule`decorator but with an overlapping set of configuration props – 

- `imports`– used to import the modules
- `providers`– define the module’s providers – when feature module is loaded – these are combined with those in the root .
- `declarations`– specify the directives, components, and pipes…
- `exports`– used to define the public exports from the module – contains some or all of the directives, compnents, and pipes from the `declarations`property.

### Creating a Model Module

For the next step is to define a module that brings together the functionality in the files that have been moved to the new dir.

```ts
@NgModule({
	providers:[Model, SimpleDataSource]
})export class ModelModule{}
```

The purpose of a feature module is to selectively expose the contents of the folder to the rest of the app. Use providers to export the services.

### Updating the other classes in the application

The next is to update the `import`to point to the new module.

```ts
imports: [
		BrowserModule,
		FormsModule,
		ModelModule
	],
```

## Creating a Utility Feature Module

A model module is good place to start – The next set up in complexity is a utility feature module– which groups together all of the common functionality in the app – such as pipes and directives, and in a real proj, might be more selective about how group these types of building blocks.

Then create the Module Definition – The next is to define a module that brings together the functionality in the files that have been moved to the new folder like..

## Using the Class Provider

This provider is the most commonly used and applied and adding the class names to the module’s `providers`prop.

```ts
providers: [DiscountService, ..., 
           {provide: LogService, useClass: LogService}],
```

Providers are defined as classes, but can be specified and configured using object literal format like:

`{provide: LogService, useClass: LogService}`

- `provide`– used to specify the token – identify the provider and the dependency will be resolved.
- `useClass`– specify the class will be instantiated to resolve the dependency
- `multi`– used to deliver an array of service objects to resolve the dependencies.

### Understanding the Token

All providers rely on a token – Ng uses to identify the DEP that the provider can resolve. The simplest is to use a class as a token. 

Can just use any objects as the token, which allows the DEP and the type of the object to be separated. FORE:

```ts
providers: [DiscountService...
           {provide:"logger", useClass: LogService}]
```

In this, the `provide`is set to `logger`. For Ng, using it like:

```ts
constructor(@Inject("logger") private logger: LogService) {}
```

The `@Inject`is applied to the ctor arg and used to specify the token that should be used to resolve the DEP. When need to create an instance, will inspect the ctor and use the `@Inject`to select provider that will be used to resolve the dep.

### Opaque Token

There ia a chance that two different parts of the app will try to use the same token to identify different services, which means may be an error occur.

`InjectionToken`class – provides an object wrapper around a `string`and can be used to create unique token values. FORE:

```ts
export const LOG_SERVICE= new InjectionToken("logger");
//...
providers: [{provider: LOG_SERVICE, useClass: lgoService}]
//...
constructor(@Inject(LOG_SERVICE) private logger: LogService) {}
```

### Understanding the `useClass`

The most common way to change classes is to use different subclasses. FORE:

```ts
@Injectable()
export class SpecialLogService extends LogService {
    constructor() {
        super()
        this....= ;
    }
    override logMessage(...)
}
```

In the `app.module.ts`:

```ts
providers : [{provide: LOG_SERVICE, useClass: SpecialLogService}]
```

### Resolving with mutliple objects 

like:

```ts
providers: [
    {provide: LOG_SERVICE, useClass: logService, multi: true},
    {provide: LOG_SERVICE, useClass: SpecialLogService, multi: true},
]
```

For this, the DEP injection system will resolve on the `LOG_SERVICE`token by creating `LogService`and `SpecialLogService`objects – placing them in an array, and passing them to the dep class’s ctor. like:

```ts
constructor(@Inject(LOG_SERVICE) loggers: LogService[]) {
    this.logger = loggers.find(...);
                               }
```

### Using the Value Provider

Is used when you want to take responsibility for creating the service objects yourself, rather than leaving it to the class provider. FORE:

```ts
let logger = new LogService();
//...
providers : [
    {provide: LogService, useValue: logger}
]
//...
constructor(private logger: LogService){}
```

### Using the Factory Provider

Uses a function to create the object to resilve. new prop - `deps`-- specifies an array of provider token that will be resovled and passed to the function.

```ts
providers : [
    {
        provide: logService, useFactory: ()=> {
            let logger = new LogService();
            logger.minimumLevel= LogLevel.DEBUG;
            return logger;
        }
    }
]
```

## Manipulating Streams

In fact, most Rx work is about manipulating the data as it comes down the stream. This change can be in the form of manipulating the data directly fore (`map`), expands of the types that fore:

- `mergeMap`combines flattening and mapping into a single operation.
- `filter`to be picky what values are allowed
- `tap`is a unique case allows developers to tap into the stream and debug.

```ts
import { from, fromEvent, map, mergeMap, reduce } from "rxjs";

let textbox = <HTMLAreaElement>document.querySelector('#text-input');
let results = <HTMLElement>document.querySelector('#results');
function pigLatinify(word:string) {
    if (word.length < 2) {
        return word;
    }
    return word.slice(1) + "-" + word[0] + 'ay';
}

fromEvent<any>(textbox, 'keyup')
    .pipe(
        map((event) => event.target.value),
        mergeMap((wordString: string) =>
            from(wordString.split(/\s+/))
                .pipe(
                    map(pigLatinify),
                    reduce((bigString, newword) => bigString + ' ' + newword, '')
                ))
    ).subscribe(translateWords => results.innerText = translateWords);
```

The high-order observable is just a fancy name for observable that emits observable. Fore:

```ts
const clickToInterval$ = click$.pipe(
	map(event=>interval$);
); // interval$, also an Observable
```

`mergeAll`when the inner observable emits, just like:

```ts
clickToIntervals$.mergeAll().subscribe(num=>console.log(num));
```

## Flexbox principles

begins with `display`– its direct children turn into *flex items*.

NOTE: Can also use the `display: inline-flex` – creates a flex container that behaves more like an inline-block. A flex container asserts control over the layout of the elements within.

The items are placed along a line called the *main axis*.

```css
.site-nav {
    display: flex;
    padding: .5em;
    background-color: #5f4b44;
    list-style-type:none;
}
```

```css
.flex {
    display: flex;
}
.flex > * + * {
    margin-top: 0;
}
```

### Using the flex-basis property

The *flex basis* defines a sort of starting point for the size of an element – an initial **main size**, the `flex-basis`prop can be set to any value that would apply to width. initial is `auto`, means that the browser will look to see if the element has a `width`declared. If so, use it, otherwise, determines the element – namely: `flex`prop which is applied to the flex items – `flex-grow, flex-shrink, flex-basis`

### Using `flex-grow`

Note that the `width`may be ignored for elements that have any `flex-basis`set other than `auto`. If any items have a non-zero growth factor, those items will grow until all the remaining space is used up. And declaring a higher `flex-grow`value just gives that element more **weight**.

### Using `flex-shrink`

follows similar principles as `flex-grow`. After determine the initial main size of flex items, they would exceed the size available in the flex container. The `flex-shrink`value for each item indicates whether they should shrink to *prevent overflow*.

### Some practical uses

Specifying the `flex-direction:column`causes the flex items to stack vertically instead. Also supports `row-reverse`to flow items right to left.

## Alignment, spacing and other details

Several properties can be applied to a flex container to control the layout of its flex items.

- `flex-wrap`– specifies whether items will wrap on to a new row inside the container.
- `flex-flow`–shorthand for `flex-direction` `flex-wrap`
- `justify-content`-- controls items are positioned along the main axis.
- `align-items` – controls how items are positioned along the cross axis.
- `align-content`– if `flex-wrap`enabled, controls the spacing of the rows along the cross axis.

### Understanding item properties

`align-self`and `order`-- `align-self`controls a flex item’s alignment along its container’s cross axis. lets you align individual flex items differently.

`order`– By using this, can change the order the items are stacked.

```css
.cost {
    display: flex;
    justify-content: center;
    align-items: center;
}
.cost-cents {
    align-self: flex-start;
}
```

## For grid

```css
.grid {
    display: grid; /* make the element a grid container */
    grid-template-columns: 1fr 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    grid-gap: 0.5em;
}
```

The container behaves like a block display element, filling 100% of the available width. Note that can also use the `inline-grid`, element will flow inline and will only be as wide as is necessary to contain its children.

- Grid line – make up the structure of the grid
- Grid track – is the space between two adjacent grid lines
- Grid cell – single space on the grid.
- Grid area – rectangular area on the grid made up by one or more grid cells.

```css
.container {
    display: grid;
    grid-template-columns: 2fr 1fr;
    grid-template-rows: repeat(4, auto); /* 4 horizontal grid tracks of size auto */
    grid-gap: 1.5em;
}

header, nav {
    grid-column: 1/3;
    grid-row: span 1; /* spans exactly one horizonal grid track */
}
```

- Flexbox is basically 1D, where as grid is 2D.
- Flexbox works from the content, grid works from the layout in.

### Naming grid lines

Two other alternate syntaxes. Named lines and named areas.

`grid-template-columns: [start] 2fr [center] 1fr [end];`
`grid-column: strart/end`

### Naming grid areas

```css
.container {
    display: grid;
    grid-template-areas: "title title"
        "nav nav"
        "main aside1"
        "main aside2"
}
header {
    grid-area: title;
}
```

When use the `grid-template-*`props to define grid tracks, creating an *explicit grid*, but can still be placed outside of these explicit tracks – in which case, implicit tracks will be automatically generated.
