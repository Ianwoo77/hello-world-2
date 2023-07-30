# Git Pull&Push from&to Github

### Pulling to keep up-to-date with changes

When working as a team on a proj, it is just important that every stays up to date. Any time you start working on a proj, you should get the most recent changes to your local copy -- with Git, can do that with pull

```sh
git remote add origin https://github...
git remote set-url origin https://...
```

`pull`is just a combination of 2 different commands:

- `fetch`
- `merge`

Git Fetch -- `fetch`gets all the change history of a tracked branch/repo like:

```sh
git fetch origin
git status
git log origin/master
git diff origin/master
```

Git Merge -- `merge`just combines the current branch, with a specified branch. Fore this, can mrege our current branch with `origin/master`

```sh
git merge origin/master
git status
```

Git pull -- `pull `is just the combination of `fetch`and `merge`, it is used to pull all changes from a remote repository into the branch you are just working on.

### Push changes to Github

Try making some changes to local git and pushing them to Github -- 

```sh
git commit -a -m "updated index.html..."\
git status
# then need to push changs to remote origin
git push origin
```

As a rule of thumb, remember that slicing a large slice or array can lead to potential high memory consumption. The remaining space won’t be reclaimed by the GC, and we can just keep a large backing array despite using one a few elements. Using a slice copy is the solution to prevent such a case.

## Slice and pointers

Have seen that slicing can cause a leak **cuz of slice cap**. But what about the elements, which are still part of the backing array but outside the length range -- does the GC collect them - 

```go
type Foo struct {
    v []byte
}
```

Want to just check the memory allocations after each step as follows -- 

1. Allocate a slice of 1000 Foo elements
2. Iterate over each `Foo`, and for each one, allocate 1MB for v slice
3. Call teh `keepFiratTwoElementsOnly`, which just returns only the frist two elements using slicing. 

```go
func main(){
    foos := make([]Foo, 1000)
    printAlloc()
    for i:=0; i<len(foos);i++{
        foos[i]=Foo{
            v: make([]byte, 1024*1024),
        }
    }
    printAlloc()
    two := keepFirstTwoElementsOnly(foos)
    runtime.GC() // runs GC to force cleaning the heap
    printAlloc()
    runtime.KeepAlive(two) // keeps a reference to the two variable
}

func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    return foos[:2]
}
```



# Viewing and Editing User Details

The `IdentityUser`class defines a set of props that provides access to the stored data values for a user account – fore, there is an `Email`prop that provides access to the user’s email address – some props can be also accessed through methods defined by the `UserManager<IdentityUser>`class so that the `GetEmailAsync()`and `SetEmailAsync()`can get and set the value of the `Email`.

For, some props are read-only, so the user manager class only provides methods that read the prop value, fore, the `IdentityUser.Id`prop just provides access to unique ID for the `IdentityUser`object that cannot be changed.

And, some `IdentityUser`props do not have corresponding user manager methods at all – fore, the `NormalizedUserName`method – fore, is automatically updated when a new `UserName`value is stored and there are no user manager methods for this prop.

| prop       | Desc      | UserManger Methods                         |
| ---------- | --------- | ------------------------------------------ |
| `Id`       | Unique Id | `GetUserIdAsync()`                         |
| `UserName` | username  | `GetUserNameAsync`<br />`SetUserNameAsync` |
| //…        |           |                                            |

For searching the store:

- `FindByIdAsync(id)`– returns an `IdentityUser`representing the user with the specific unique ID
- `FindByNameAsync(name)`– return .. with the specified name
- `FindByEmailAsync(email)`

## Git Github Branch

### Create a new Branch on Github

On Github, access repository and clicke the `master`branch button. Then create a new branch -- the `branch`should now be created and *active* -- can confirm which branch you are working on by looking the branch button.

Not start working on an existing file and editing it.

### Git pull branch from github

Just continue working on the new `branch`in local git -- just `pull`from our github repository again so that code up-to-date. Just :

```sh
git pull
```

Now our main `branch`is up to date, and can see that there is a new branch availaible on Github.

```sh
git status
git branch # just master
git branch -a # can see new branch is available remotely, but not on local git. 
git checkout html-skeleton # check it out
git pull # already up to date
git branch # now under local html-skeleton
```

### Git PUsh Brnch to GitHub

Try to create a new local branch, and push that to Github

```sh
git checkout -b update-readme
git add readme.txt
git commit -m "updated readme"
git push origin update-readme
```

Go to Github, confirm that the repository has a new branch .

And in the Github, can now see the changes and merge them into the master `branch`if approve it. And if click the *compoare & pull request*, can go through the changes made and new files added like:

A pull request is how you propose chanes -- can ask some to review your changes to your contribution and merge it into their branch , since this is just your own repository, can `merge`your pull request yourself.

And, the pull request will record the changes, which means that you can go through them later to fiture out the changes made -- and the result should be somethign like this:

An to keep the repo from getting overly complicated, can delete the nw unused branch by `Deleting branch`

### Git Github Flow

Working using the Gibhub Flow -- on this page, will learn how to get the best out of working.

# Using the Identity API

There are limits to the customizatoins that can be made to the Identity UI package – minor changes can be achiveed using scaffolding – but if your app doesn’t fit into the self-service model that Identity UI expects, then you won’t be able to adapt its features to suit your proj.

Can be used to create completely custom workflows - this is the same API that Identity UI package – This is just the same API that Identity uses – but using it directly means you can create any combination of features you require and implement them exactly as needed – describe the basic features that the API provides.

- The Identity API provides access to all of the Identity features
- The API allows custom workflow to be created that perfectly match the requirements of a proj.
- Key classes are provided as services that are available through the std ASP.NET core DI feature
- The API can be complex – and creating custom workflows requires a commitment  of the time.

## User and Administrator Dashboards

```cs
string theme = ViewData["theme"] as string ?? "primary";
bool showNav = ViewData["showNav"] as bool? ?? true;
//...
```

```html
<div class="my-2">
    <div class="container-fluid">
        <div class="row">
            @if(showNav) {
            	<div class="col-auto">
            	<partial name="@navPartial" model="@((workflow, theme))" />
            </div>
            }
            <div class="col">
                @RenderBody()
            </div>
        </div>
    </div>
</div>
```

```cs
Func<string, string> getClass= (string feature)=> {
    feature != null && features.Equal(Model.workflow) ? "active":"";
}
```

### Creating the custom Base classes

Once get enough functionality in place, will use the core authorization feature to restrict access so that the user features are only available for signed-in users and administrations features are only available to designated administrators. And applying the authorization policy is simplier when all the related razor pages share a common page model base class. And to define the base class for user features, add a class file:

```cs
public class UserPageModel: PagaModel{}
public class AdminPageModel: UserPageModel{}
```

### Creating the Overview and Dashboard pages

Add a RP `index.cshtml`to the `Page/Identity`for common use:

```cs
public IndexModel: UserPageModel {
    public string Email {get;set;}
    public string Phone {get;set;}
}
```

And the page model class defines the props required by the view.

For the Admin page:

```cs
public class DashboardModel: AdminPageModel {
    public int UsersCount{get;set;}=0;
    public int UsersUnconfirmed{get;set;}=0;
    public int UsersLockedout{get;set;}=0;
    public int UsersTwoFactor {get;set;}=0;
}
```

## Using the Identity API

Two of the most important parts of the Identity API are the user manger and user class – the user manager provides access to the data that Identity manges, and the user class describes the data that Identity manges for single user account  – best approach is to jump in – like:

```cs
public DashboardModel: AdminPageModel {
    public DashboardModel(UserManager<IdentityUser> userMgr) =>
        UserManger= userMgr;
    public UserManger<IdentityUser> UserManger {get;set;}
    //...
    private readonly string[] emails = {
        //...
    };
    public async Task<IActionResult> OnPostAsync() {
        foreach(string email in emails) {
            IdentityUser userObject= new IdentityUser{
                UserName=email,
                Email=email,
                EmailConfirmed=true
            };
            await UserManger.CreateAsync(userObject);
        }
        return RedirectToPage();
    }
}
```

And, the user class is jsut declared when configuring in the `program.cs`file like:

```cs
builder.Services.AddDefaultIdentity<IdentityUser>(opts=> {
    opts.Password.RequiredLength=5;
})//...
```

And, the type of the user class is sepcified using the generic type arg to the `AddDefaultIdentity`method. The user class defines a set of properties that describe the user account and provide data values that Identity needs to implemetn its feature – like:

And, the second key class is the user manager – which is `UserManger<T>`where `T`stands specifying the user class. And the user manager is configured as a service through core DI. So can use the ctor.

The user manager class has a lot of methods – just :

- `CreateAsync(user)`
- `UpdateAsync(user)`
- `DeleteAsync(user)`

`await UserManger.CreateAsync(userObject);`

### Processing Identity Results

Usef of the `CreateAsync`assumes that everything just ok – is a level optimism that is rarely warranted. so:

- `Succeeded`– returns `true`if the operation is successful and `false`otherwise.
- `Errors`-- returns an `IEnumerable<IdentityError>`object containing an `IdentityError`object.

Fore, If the `Succeeded`true, then has worked. If `fasle`, then the `Errors`prop can be enumerated to understand the problems that arisen. When writing custom Identity workflows, a common requrement is to handle errors from the `IdentityResult`object by just adding  Just like:

```cs
public static bool Process(this IdentityResult result, ModelStateDictionary modelState) {
    foreach(IdentityError err in result.Errors?? Enumerable.Empty<IdentityError>()) {
        modelState.AddModelError(string.Empty, err.Description);
    }
    return result.Succeeded;
}
```

For this, each `IdentityError`obj in the sequence returend by the `IdentityResult.Errors`defines a `Code`prop and a `Description`prop – The `Code`is just used to unambiguously identify the error and is intended to be consumed by the app. Interested in the `Description`prop, which describes an error that can be presented to the user. Use the `foreach`just to add the value from each `IdentityError.Description`prop. Then:

```cs
public async Task<IActionResult> OnPostAsync(){
    foreach(string emal in emails) {
        IdentityUser userObject= new IdentityUser {
            UserName=email,
            Email= email,
            EmalConfirmed=true;
        };
        IdentityResult result= await UserManger.CreateAsync(userObject);
        result.Process(ModelState);
    }
    if(ModelState.IsValid){
        return RedirectToPage();
    }
    return Page();
}
```

This is not most elegant code cuz it forces together two dfferent error handling approaches – while also signaling whether there are any errors to handle at all. The final step to get the basic feature working is to adding the HTML elements to the view part of the `Dashboard`page.

`<div asp-validation-summary="All" class="text-danger m-2"></div>`

The new elements display validatoin errors and define a form that s submitted to seed the dbs. There is still work.. there is enough functionality for a simple test.

### Querying the user Data

The problem with code that it doesn’t clear out existing before storing the new `IdentityUser`objects – to provide access to the existing data, the user manager class defines a prop named `User`– which can be used to enumerate the stored `IdentityUser`objects and which can be used with LINQ perform queries.

```cs
public void OnGet(){
    UsersCount= UserManger.Users.Count();
}

public async Task<ActionResult> OnPostAsync() {
    foreach(IdentityUser existingUser in UserManager.Users.ToList()) {
        IdentityResult result = await UserManger.DeleteAsync(existingUser);
        result.Process(ModelState);
    }
}
```

The `Users`prop returns an `IQueryable<IdentityUser>`obj,  that can be enumerated or used in a LINQ query – In a `GET`handler – use the LINQ `Count`to determine how many `IdentityUser`obj have been stored and in the `POST`, use the `foreach`to enumerate the stored `IdentityUser`objects so can delete them.

### Displaying a list of Users

There is just now insight into the stored data, but not enough to be useful – would be just helpful to see a list of user accounts, – which can be obtained through the user manger’s `Users`prop - since the`Users`prop returns an `IQueryable<IdentityUser>`obj,  it is easy to create a list that can be filtered. like. The `IdnetityUser`class defines a set of properties that provides access to the stored data values for a user account.

Note that some `IdentityUser`'s methods readonly, and some of them just don’t have corresponding user manager at all – fore, the `NormalizedUserName`. Some user manger methods to more than directly update a user object prop.

And, Working directly with user object props is the simplest approach.

- `Id`-- stores the unique ID, `GetUserIdAsync()`
- `UserName`– stores user’s name – `GetUserNameAsync()`, `SetUserNameAsync()`
- `NormalizedUserName`-- stores a normalized representation of the user name that is used when searching users.
- `GetEmailAsync, SetEmailAsync`

And the `UserManager<T>`members for searching the Store

- `FindByIdAsync(id)`– returns the `IdentityUsr`obj representing the user with the specifeid unique id
- `FindByNameAsync(name)`– returns the `IdentityUser`object representing the user with the specifeid name
- `FindByEmailAsync(email) `-- returns an `IdentityUser`object representing the user wiht the email.

## Working with files

Just as with other HTML input elements, Blazor provides a component out of the box for uploading files - thiscomponetn is called `InputFile`– going to update our form to use this componet, allowing a suer to upload an image for their trail. like:

```html
<InputFile OnChange="LoadTrailImage" class="form-control-file" 
           id="trailImage" accept=".png,.jpg,.jpeg" />
```

The most important to note that is `InputFile`component doesn’t use the `bind`but – must handle the `OnChange`event it exposes – Just as with file uploading an regular HTML forms - can providea list of file types want the user to be able to upload using the `accept`attribute.

Now that have the `InputFile`– need to add the `LoadTrailImage`to the code block - like:

```cs
private IBrowserFile? _trailImage;
// other code omitted for brevity
private void LoadTrailImage(InputFileChangeEventArgs e) {
    _trailImage= e.File;
}
```

When the user selects a file, the `OnChange`event will fire and the `LoadTrailImage`method will run. This method uses the `InputFileChangeEventArgs`to assign the selected file to the `trailImage`field can acces it later, when the form is submitted.

Handling multiple files – In applications that need to allow multiple files to be selected for upload. The `multiple`attribute must be added to the `InputFile`component.
