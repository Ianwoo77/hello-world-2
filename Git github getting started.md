# Git github getting started

### Push local repository to GitHub

Copy the git url, and type:

```sh
git config --get remote.origin.url
git remote -v
git remote set-url origin https://github.com/Ianwoo77/hello-world-2.git
git push --set-pstream origin master
```

### Git Github Edit code

In addition to being a host for Git content, GitHub has a very good code editor.

### Git pull from Github

when working as a team on a proj, it is just important that everyone stays up to date. Any time you starting working on a proj ,should get the most recent chnges to your local copy, with Git, just using `pull`.

`pull`is just a combination of 2 different commands -- 

- `featch`
- `merge`

Git Fitch -- `fetch`just gets all change history of a tracked branch/repo, so on local Git, featch updates to see what has changed on GitHub.

```sh
git fetch origin
```

Now that have the recent chagnes, can just check our status

```sh
git status
```

For this , are beind the `origin/master`by 1 commit, should update local file, first, double check by viewing the log:

```sh
git log origin/master
git diff origin/master
```

Then Git merge -- `merge`just combines the current branch, with the remote specifeid branch, have confirmed that the updates are expected, can merge our current branch with `origin/master`

```sh
git merge origin/master
git status
```

Git Pull -- But what if you just want to update your local repository, without going through al those.. `pull` is just a combination of `fetch`and `merge`-- is used to pull all changes from a remote repository into the branch you are working on.

```sh
git pull origin # not that no need for origin/master
```

### Git push to github

Push changes to Github -- try making some changs to local git and pushing them to github like:

```sh
git commit -a -m "updated index.html"
git status
git push origin
```

# Not making slices copies correctly

The `copy`built-in function allows copying elements from a souce slice into a distination slice. Although it is a handy built-in function, Go developers sometimes misunderstand it -- look at a common mistake the results in copying wrong number of lements -- in the following create a slice and copy its elements to another slice should be ?

```go
src := []int {0,1,2}
var dst []int
copy(dst, src)
fmt.Println(dst)
```

For this, just prints [], not [0,1,2] -- To use `copy`effectrively, it’s essential to understand that the number of elements copied to the dest slice corresponding to the minimum between -- 

- the source slice’s length
- the dest slice’s length

In the previous example, `src`is a 3-length slice, but `dst`is zero-len -- cuz it is initialized .. Therefore, the `copy`func copeis the minimum number of elements -- 0 in this case. just:

```go
src := []int {0, 1, 2}
dst := make([]int, len(src))
copy(dst, src)
```

Also, mention that using the `copy`bult-in isn’t the only way to copy -- just like:

```go
src := []int{0,1,2}
dst: = append([]int(nil), src...)
```

For, this append the elemetns from the source to a nil slice. However, using `copy`is more idiomatic and easier to understand.

## Unexpected side effects using slice `append`

This discusses a common mistake when using `append`-- which may have some unexpected side effects in some situations -- in the following, like:

```go
s1 := []int{1,2,3}
s2 := s1[1:2]
s3 := append(s2, 10)
```

For this, initialize an `s1`slice contaiing  3 elems -- and s2 created from s1 -- Then call `append`on s3 -- after var s2 created, shows the state of both slices in memory. s1 is just 3-len, 3 cap slice, and s2 is a one-length, two-cap, both backed by the same array we already mentioned -- Adding an element using `append`checks whether the slice is full -- namely : **length==capacity** -- if not, the `append`just adds the element by updating the backing array and returning a slice having a length incremented by 1.

So, for this example, `s2`jsut is not full - can accept one more element -- so in the backing array, update the last element to store 10.

`s1=[1,2,10]`, s2=[2], s3=[2,10]

The s1’s content just modified -- even though not upldate directly.

And see one impact of this principle by passing the result of a slicing operation to a func -- in the following, initialize a slice with 3 elements and call a func with only first two -- like:

```go
func main(){
    s:= []int {1,2,3}
    f(s[:2])
    // use s
}
func f(s []int) [
    // update s
]
```

In this implementation -- if `f`updates the first two elements, the changes are visible to the slice in `main`, however, if `f`calls `append`, the 3rd  element of the slice, even though pass only two elements - like:

```go
func main(){
    s := []int {1,2,3}
    f(s[:2])
    fmt.Println(s)  // 1, 2, 10
}

func f(s []int){
    _ = append(s, 10)
}
```

For this, if want to *protect* the third element for defensive reasons, meaning to ensure the `f`doesn’t update it, have two options -- the first is to pass a copy of the slice and then construct the resulting slice. like:

```go
func main(){
    s := []int {1,2,3}
    sScopy := make([]int, 2)
    copy(sCopy, s)
    f(sCopy)
}
```

Cuz just pasing a copy to `f`-- even if this func calls the `append`, it will not lead to a side effect outside of the range of the first two elements -- This option involves the so-called *full slice expression* -- `s[low:high:max]`-- this statement creates a slice similar to the one created with `s[low:high]`.expect that the result slice’s cap is equal to **max-low** fore:

```go
func main(){
    s := []int {1,2,3}
    f(s[:2:2]) // passing a subslice using the full expr
}
```

For this, the slice passed to `f`isn’t `s[:2]`but `s[:2:2]`-- hence, the slice’s cap is just 2-0=2 -- when passing like this, we can limit the range of effects to the first two elements -- Doing so also prevents us from having to perform a slice copy. And when using slicing, must remember that we can face a situation leading to unintended side effects. If the resulting slice has a length smaller than its cap -- `append`can just mutate the original slice, and if want to restrict the range of posible side effects, can use either a slice copy or a *full slice expr*.

## Slices and memory leaks

This just shows that slicing an existing slice or array can lead to memory leaks in some conditions -- 

### Leaking capacity

fore, implementing a custom binary protocol For, a message can just contain 1M bytes, and the first 5 represent the message type -- in this code, consume these messages, and for auditing , want to store the latest 1000 message types in memory -- this is like:

```go
func consumeMessages() {
    for{
        msg := receiveMessage()
        // ... some code
        storeMessageType(getMessageType(msg))
    }
}

func getMessageType(msg []byte) []byte{
    return msg[:5]
}
```

The `getMessateType`func computes the message type by slicing the input slice. test this implementation, and everything is fine. However, when deploy app, notice that our app consumes about 1GB of memory.

For this, the slicing op on `msg`using just `msg[:5]`creates a 5-len slice -- however, *its cap remains the same as the initial slice*. And the ramaining elements are still allocated in memory - even if eventually msg is not referenced. So the backing array of slice still contains 1M bytes after the slicing op. Hence, if keep 1000 messages in memory, instead of stroing about 5K, hold 1GB. -- so -- 

```go
func getMessageType(msg []byte) []byte {
    msgType := make([]byte, 5)
    copy(msgType, msg)
    return msgType
}
```

Cuz perform a `copy`-- `msgType`is 5-len, 5-cap slice regardless of the size of the message received, hence, only store 5 bytes per message type.

Full slice expr and cap leakage -- if:

```go
func getMessagetType(msg []byte) []byte {
    return msg[:5:5]
}
// NOTE, the whole backing array still lives in memory
```

As a rule of thumb, remember that slicing a large slice or array can lead to potential high memory consumption. And the **remaining space won’t be re-claimed by the GC**, and we can keep a large backing array desptite using only a few elements.

# Mocking Dependencies

Now that explained some general patterns for testing your web app, in this, going to get a bit more serious and write some tests for our `showSnippet`handler and `GET /snippet/:id`route like: Thoughout this proj, just injected dependencies into handlers via the `application`struct.

When testing, it sometimes makes sense to mock these dependencies instead of using *extactly* the same ones that you do in your product environment.

Fore, mocked the `errorLog`and `infoLog`DI with loggers that write messages to the `io.Discard`, instead of the `io.Stdout`and `io.Stderr`

The reason for mocking these and writing to the `io.Discard`is just avoid clogging up our test output with unnecessary messages.

## Mocking the dbs Models

Can create: Begin by creating a mock of `mysql.SnippetModel`-- going to create a simple struct which just implements the same methods as our product `mysql.SnippetModel`, but have the methods return some fixed dummy data instead like:

```go
var mockSnippet = &models.Snippet{
	ID:      1,
	Title:   "an old silent pond",
	Content: "an old silent pond",
	Created: time.Now(),
	Expires: time.Now(),
}

type SnippetModel struct{}

func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	return 2, nil
}

func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	switch id {
	case 1:
		return mockSnippet, nil
	default:
		return nil, models.ErrNoRecord
	}
}

func (m *SnippetModel) Latest() ([]*models.Snippet, error) {
	return []*models.Snippet{mockSnippet}, nil
}
```

And just do the same for the `mysql.UserModel`like:

```go
var mockUser = &models.User{
	ID:      1,
	Name:    "Alice",
	Email:   "alice@example.com",
	Created: time.Now(),
	Active:  true,
}

type UserModel struct{}

func (m *UserModel) Insert(name, email, password string) error {
	switch email {
	case "dupe@example.com":
		return models.ErrDuplicateEmail
	default:
		return nil
	}
}

func (m *UserModel) Authenticate(email, password string) (int, error) {
	switch email {
	case "alice@example.com":
		return 1, nil
	default:
		return 0, models.ErrInvalidCredentials
	}
}

func (m *UserModel) Get(id int) (*models.User, error) {
	switch id {
	case 1:
		return mockUser, nil
	default:
		return nil, models.ErrNoRecord
	}
}
```

### Initializing the Mocks

For the next step -- head back to the `testutils_test.go`file and update the `newTestApplication()`so it creates an `appliation`struct with all the necessary dependencies for testing. like:..  And need to just change the program like:

```go
type application struct {
	//...
	snippets interface {
		Insert(string, string, string) (int, error)
		Get(int) (*models.Snippet, error)
		Latest() ([]*models.Snippet, error)
	}
	//...
	users         interface {
		Insert(string, string, string) error
		Authenticate(string, string) (int, error)
		Get(int) (*models.User, error)
	}
}
```

Then write :

```go
func newTestApplication(t *testing.T) *application {
	// create an instance of the template cache
	templateCache, err := newTemplateCache("./../../ui/html")
	if err != nil {
		t.Fatal(err)
	}

	// create a session manager instance, with the same settings as production
	session := sessions.New([]byte("3dSm5MnygFHh7XidAtbskXrjbwfoJcbJ"))
	session.Lifetime = 12 * time.Hour
	session.Secure = true

	// initialize the di, using the mocks
	return &application{
		errorLog:      log.New(io.Discard, "", 0),
		infoLog:       log.New(io.Discard, "", 0),
		session:       session,
		snippets:      &mock.SnippetModel{},
		templateCache: templateCache,
		users:         &mock.UserModel{},
	}
}
```

For this, have updated the `application`struct so that instead of `snippets`and `users`fields having the concrete types `*mysql.SnippetModel`and `*mysql.UserModel`they are just interfaces instead. So long as an obj has the necessary methods to satisfy the interface, can just use them in our `application`struct.

### Testing the `showSnippet`handler

With that all now -- get stuck into writing an end-to-end testing for `GET /snippet/:id`route which uses these mocked dependencies -- As part of this test, the code in our `showSnippet`handler will call the `mock.SnippetModel.Get()`- just -- this mocked model method returns an `models.ErrNoRecord`unless the snippet ID is 1. So specially, want to test that:

- For the request `GET /snippet/1`, receive a `200 ok`response with the revelant mocked snippet in the HTML body.
- For all other requests to `GET /snippet/*`should receive 400 not found

So, in the `handlers_test`, create new `TestShowSnippet()`like:

```go
func TestShowSnippet(t *testing.T) {
	// create a new instance of our app struct uses the mocked DI
	app := newTestApplication(t)

	ts := newTestServer(t, app.routes())
	defer ts.Close()

	// set up some table-dirven tests to check the response send by the user
	tests := []struct {
		name     string
		urlPath  string
		wantCode int
		wantBody []byte
	}{
		{"Valid ID", "/snippet/1", http.StatusOK, []byte("an old silent pond")},
		{"Non-existent ID", "/snippet/2", http.StatusNotFound, nil},
		{"Negative ID", "/snippet/-1", http.StatusNotFound, nil},
		{"Decimal ID", "/snippet/1.23", http.StatusNotFound, nil},
		{"String ID", "/snippet/foo", http.StatusNotFound, nil},
		{"Empty ID", "/snippet/", http.StatusNotFound, nil},
		{"Trailing slash", "/snippet/1/", http.StatusNotFound, nil},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			code, _, body := ts.get(t, tt.urlPath)
			if code != tt.wantCode {
				t.Errorf("Want %d, got %d", tt.wantCode, code)
			}
			if !bytes.Contains(body, tt.wantBody) {
				t.Errorf("want body to contain %q", tt.wantBody)
			}
		})
	}
}
```

There is one new thing to point out -- notice how the names of the sub-test have been cononicalized... Any spaces in the sub-test name have been replaced with just the *underscore*.

# Using the Identity API

Two of the most important parts of the Identity API are the usermanager and the user class. The user manager provides access to the data that Identity manages, and the user class describes the data that Identity manages for a single user account – the best approach is to jump in and write some code that uses the API – going to start with a Razor page that will create instances of the user class and ask the user manager to store them in the dbs. like:

```cs
public class DashboardModel: AdminPageModel {
    public UserManager<IdentityUser> UserManager {get;set;}
    // ctor to initialize the `UserManager`
    // some props
    private readonly string[] emails = {
        // some email addresses
    }
    public async Task<IAsyncReult> OnPostAsync(){
        foreach(string email in emails){
            IdentityUser userObject = new IdentityUser{
                UserName=email,
                Email=email,
                EmailConfirmed=true
            };
            await userManger.CreateAsync(userObject);
        }
        return RedirectToPage();
    }
}
```

Identity is agnostic about the the user class – can create a custom user class – and there is just a default class named `IdentityUser`which is the class – is declared when configuring identity in the program.cs, like:

`builder.Services.AddDefaultIdentity<IdentityUser>(opts=>)`

The type of theuser class is specified using the generic type arg to the `AddDefaultIdentity()`-- and the user class defines a set of properties that describe the user account and provide the data values that `Identity`needs to implement its features.

Second key class is the `UserManager<T>`– `T`is the user class. And the user manager is configured as s service through the core DI – like:

`public DashboardModel(UserManger<IdentityUser> usrMgr)=> UserManger=userMgr;`

### Processing Identity Results

Fore, use of the `CreateAsync`assumes that everythings works as expected – which is a level of optimism that is rarely warranted in software development. fore, the methods return an `IdentityResult`objects that describe the outcome of operations using the props – like:

- `Succeeded`– this returns `true`if the op is successful and false otherwise
- `Errors`– return an `IEnumerable<IdentityError>`containing an `IdentityError`for each error that has occurred.

Then, if `Succeeded`is true, workd, otherwise, `Errors`prop can be just enumerated to understand the errors. To demonstrate, just add an `IdentityExtensions.cs`to the `Identity`folder and use it to define the extension method like:

```cs
public static class IdentityExtensions
{
    public static bool Process(this IdentityResult result, 
        ModelStateDictionary modelState)
    {
        foreach(var error in result.Errors
            ??Enumerable.Empty<IdentityError>()) {
            modelState.AddModelError(string.Empty, error.Description);
        }
        return result.Succeeded;
    }
}
```

For this, each `IdentityError`obj in the seq returned by the `IdentityResult.Errors`defines a `Code `prop and a `Description`prop.

Then modify the RPs – like:

```cs
public async Task<IActionResult> OnPostAsync()
        {
            foreach(string email in emails)
            {
                //...
                IdentityResult result= await UserManager.CreateAsync(userObject);
                result.Process(ModelState);
            }
            if (ModelState.IsValid)
            {
                return RedirectToPage();
            }
            return Page();
        }
```

for this, update the view just:

```html
<div asp-validation-summary="All" class="text-danger m-2"></div>
<form method="post">
    <button class="btn btn-secondary" type="submit">Seed Database</button>
</form>
```

On the second attempt to seed the dbs, the calls to the `CreateAsyc`produces errors cuzt the first seeding stored with the same user name…

### Querying the user Data

The problem with the code that it doesn’t clear out existing data before storing the new `IdentityUser`objects – to provide access to the existing data, the usermanager class defines a prop named `Users` – which just be used to enumerated the stored `IdentityUser`objects and which can be used wtih LINQ.

- `Users`– this prop returns an `IQueryable<IdentityUser>`object that can be used to enumerate the stored `IdentityUser`and can be used with LINQ to perform queries.

```cs
public void OnGet()
{
    UserCount = UserManager.Users.Count();
}

public async Task<IActionResult> OnPostAsync()
{
    foreach(var existingUser in UserManager.Users)
    {
        IdentityResult result= await UserManager.DeleteAsync(existingUser);
        result.Process(ModelState);
    }
    //...
}
```

### Displaying a list of Users

There is now some insight into the stored data, but not enough to be useful – It would be helpful to see a list of user accounts - -which can be obtained through the user manager’s `Users`prop. FORE, new a `SelectUser` RP:

```cs
public class SelectUserModel : AdminPageModel
{
    public UserManager<IdentityUser> UserManager { get; set; }
    public SelectUserModel(UserManager<IdentityUser> userManager) 
        => UserManager = userManager;

    public IEnumerable<IdentityUser> Users { get; set; }

    [BindProperty(SupportsGet =true)]
    public string Label { get; set; }

    [BindProperty(SupportsGet =true)]
    public string Callback { get; set; }

    [BindProperty(SupportsGet =true)]
    public string Filter { get; set; }

    public void OnGet()
    {
        Users = UserManager.Users
            .Where(u => Filter == null || u.Email.Contains(Filter))
            .OrderBy(u => u.Email).ToList();
    }

    public IActionResult OnPost() => RedirectToPage(new { Filter, Callback });
}
```

The page model uses the `UserManger`obj to receives via DI to query the user store with LINQ.

```html
@page "{label?}/{callback?}"
@using Microsoft.AspNetCore.Identity
@model IdentityApp.Pages.Identity.Admin.SelectUserModel
@{
    ViewBag.Workflow = Model.Callback ?? Model.Label ?? "List";
}

<form method="post" class="my-2">
    <div class="row mb-3">
        <div class="col">
            <div class="input-group">
                <input asp-for="Filter" class="form-control"/>
            </div>
        </div>

        <div class="col-auto">
            <button class="btn btn-secondary">Filter</button>
        </div>
    </div>
</form>

<table class="table table-sm table-striped table-bordered">
    <thead>
    <tr>
        <th>User</th>
        @if (!string.IsNullOrEmpty(Model.Callback))
        {
            <th/>
        }
    </tr>
    </thead>
    @if (Model.Users.Count() == 0)
    {
        <tr>
            <td colspan="2">No matches</td>
        </tr>
    }
    else
    {
        @foreach (IdentityUser user in Model.Users)
        {
            <tr>
                <td>@user.Email</td>
                @if (!string.IsNullOrEmpty(Model.Callback))
                {
                    <td class="text-center">
                        <a asp-page="@Model.Callback"
                           asp-route-id="@user.Id"
                           class="btn btn-sm btn-secondary">
                            @Model.Callback
                        </a>
                    </td>
                }
            </tr>
        }
    }
</table>

@if (!string.IsNullOrEmpty(Model.Callback))
{
    <a asp-page="Dashboard" class="btn btn-secondary">Cancel</a>
}
```

Then just add this RP to the Admin home:

```html
<a class="btn btn-success d-block mt-2 @getClass("List")" asp-page="SelectUser">
	List users
</a>
```

### Viewing and Editing User Details

Some props can be accessed through methods defined by the `UserManger<IdentityUser>`class, so that the `GetEmailAsync()`and `SetEmailAsync()`methods.. and some are read-only– so the user manager class only provides methods that read, fore, `Id`. Some props do not have corresponding manager methods at all. fore, the `NormalizedUserName()`which is automatically updated when a new `UserName`is stored… And some do more than directly update a user object - Fore, `SetEmailAsync()`just updates the `Identity.Email`but also sets `EmailConfirmed`to `false`. Others:

`EmailConfirmed, PasswordHash, PhoneNumber, TwoFactorEnabled, LockOutEnabled, AccessFailedCount`
`LockoutEnd, SecurityStamp, ConcurrencyStamp`

Just adding RP `View`to:

```cs
public class ViewModel : AdminPageModel
{
    public UserManager<IdentityUser> UserManager { get; set; }
    public ViewModel(UserManager<IdentityUser> userManager)=> this.UserManager = userManager;

    public IdentityUser IdentityUser { get; set; }

    [BindProperty(SupportsGet =true)]
    public string Id { get; set; }

    public IEnumerable<string> PropertyNames =>
        typeof(IdentityUser).GetProperties()
        .Select(prop => prop.Name);

    public string GetValue(string name) =>
        typeof(IdentityUser).GetProperty(name)!
        .GetValue(IdentityUser)?.ToString()!;

    public async Task<IActionResult> OnGetAsync()
    {
        if (string.IsNullOrEmpty(Id))
        {
            return RedirectToPage("Selectuser",
                new { Label = "View User", Callback = "View" });
        }
        IdentityUser = await UserManager.FindByIdAsync(Id);
        return Page();
    }
}
```

To identify the user account to be edited, the `GET`handler page will perform a redirection to the `SelectUser`rp if the requeste URL doesn’t include an `Id`. For the `Find...Async()`, all return `IdentityUser`objects.

# Updating the form to allow editing

The final piece of work going to do is refactor our form so it can handle both adding and editing of trails – to do this, extract the form from `AddTrailPage.razor`and make it just into a standalone component. Can share it with and a new page called `EditTrailPage.Razor`.

For this, the overall `MangeTrails`feature has been divided into subfeatures.

### Separating the tril form into a standalone component

The first task tackle is separating out the tril from the `AddTrailPage`and make it into its own componetn, capable of handling both adding and editing – As part of this, start to create new feature folder structure.

Start by creating `Shared`folder – in this, will create a new component falled `TrailForm`, move he `FormFieldSet..`and the classes into the `Shared`folder. And will just compy the entire `EditForm`component from `AddTrailPage`and paste it into the `TrailForm.razor`

```cs
@code {
    private TrailDto _trail = new TrailDto();
    private IBrowserFile? _trailImage;
    private EditContext _editContext = default!;

    [Parameter]
    public Func<TrailDto, IBrowserFile?, Task> OnSubmit { get; set; }

    public void ResetForm()
    {
        _trail = new TrailDto();
        _editContext = new EditContext(_trail);
        _editContext.SetFieldCssClassProvider(
        new BootstrapCssClassProvider());
        _trailImage = null;
    }

    protected override void OnInitialized()
    {
        _editContext = new EditContext(_trail);
        _editContext.SetFieldCssClassProvider(new BootstrapCssClassProvider());
    }

    private void LoadTrailImage(InputFileChangeEventArgs e) => _trailImage = e.File;

    private async Task SubmitForm()
    {
        await OnSubmit(_trail, _trailImage);
    }
}
```

The various private fields are lifted straight from the `AddTrailpage`along with the entire `EditForm`component.

Added a component parameter that define a component event – `OnSubmit()`– When the `EditForm`'s `OnValidSubmit`is invoked the `SubmitForm`method is run, and If one has been selected, it’s worth nothing here that not using the.

### Refactoring AddTrailPage

Now have the initial logic in place for our form component we can refactor the `AddTrailPage`to use it.

```cs
<TrailForm @ref="_trailForm" OnSubmit="SubmitNewTrail" />

@code {
    private bool _submitSuccessful;
    private string? _errorMessage;
    private TrailForm _trailForm = default!;

    private async Task SubmitNewTrail(TrailDto trail, IBrowserFile? image)
    {
        var response = await Mediator.Send(new AddTrailRequest(trail));
        if (response.TrailId == -1)
        {
            _submitSuccessful = false;
            _errorMessage = "There was a problem saving your trial.";
            StateHasChanged();
            return;
        }

        if(image is null)
        {
            _submitSuccessful = true;
            _trailForm.ResetForm();
            StateHasChanged();
            return;
        }

        _submitSuccessful = await ProcessImage(response.TrailId, image);
        if (_submitSuccessful)
        {
            _trailForm.ResetForm();
        }
        StateHasChanged();
    }

    private async Task<bool> ProcessImage(int trailId, IBrowserFile trailImage)
    {
        var imageUploadResponse = await Mediator.Send(
            new UploadTrailImageRequest(trailId, trailImage));
        if(string.IsNullOrWhiteSpace(imageUploadResponse.ImageName))
        {
            _errorMessage = "Your trail was saved, but ther was a problem uploading the image";
            return false;
        }
        return true;
    }
}
```

We’ve added a component parameter that defines a component – So not using the `EventCallback<T>`, which we’ve used previously – cuz want to manually control when `StateHasChanged()`called.

1. If there was an error saving the trail, manually call `StatehasChanged()`to upload the UI with the error message.
2. If the trail was saved successfuly, reset the `TrailForm`via the reference by `_trailForm`field.
3. Sows a manual call to `StateHasChanged()`to trigger an update of the UI.

### Adding the Edit trail feature

Before start making any changes in the Client project to enabling editing, need to make some changes to the `Shared`project – there are just a few jobs for us to do:

1. Must updae the `TrailDto`class –specially, to handle updating the trail image.
2. Need to update the folder structure so it mirrors the feature folder structure in the client proj.
3. Need to add two new requests for our edit functionality – `EditTrailRequest`and `GetTrailRequest`.

### Updating the `TrailDto`class

When editing a trail, we will need to be able to display the trail’s current image - if it has one, will also need to give the user the ability to remove the image, updating, or leave it unchanged. To enable these, update the class with two additioanl properties and new `enum`just like:

```cs
    public class TrailDto
    {
       //...
        public string? Image { get; set; }
        public ImageAction ImageAction { get; set; }
    }

    public enum ImageAction
    {
        None, Add, Remove
    }
```

When just add the editing functionaity to the client - need to load the trail to edit from the API. At this point need to know if the trail has an image – this is where the new `Image`prop comes in. If has an name – will contain the filename of that image so can display it to the user.

## Adding Debounce to the Typeahead

One of the ways to determine the quanlity of code si to see how resilient the code is to change. like:

```ts
let lastQuery;
searchBar.AddEventListener('keyup', debounce(event=> {
    ...
}));
fromEvent(searchBar, "keyup")
    .pipe(
	pluck('target', 'value'),
    debounceTime(333),
    switchMap(query=>ajax(endpoint+searchVal))
)
```

### Using `catchError`

The `catchError`operator is simple on the surface – triggers whenever an error is thrown. Provides a plenty of options for how you handle the next steps. `catchError()`take two parameters – the error that was thrown and the current observable that’s being run. Can:

```ts
catchError(err=>throw err;)
```

For the use of `catchError`operation is simple on the surface – triggers whenever an error is thrown. Can :

```ts
catchError(err=>{
    throw "touble from the server"
})
```

So, what if we want to continue on instead of entering the errored state – need to tap into the second parameter passed to `catchError` – like:

```ts
catchError((err, caught$)=> {
    return caught$;
})
```

For this, doesn’t throw a new error – Rx takes a took at what it has returned – looks for anything that just can be easily turned into an observable – an array, promise, or another observable. Rx then converts the return value into an observable, and now the rest of the observable chain can subscribe the new, returned observable.

However, generally, don’t want to completely ignore errors – it’d be nice if could note the error somehow without completely breaking the typeahead. Can:

```ts
catchError((err, caught$)=> {
    return merge(of({err}), cautght$);
})
```

For this, add `addError`right after the `switchMap()`, it can just catch any AJAX errors, want the `typeahead`to keep working even then things go wrong, so borrow the merge pattern like:

# Routing and Nav 2

- Use routing wildcards
- Use a redirection route
- use a relative URL
- Use the `Observable`objects provided by the `ActivatedRoute`class.
- Use the `routerLinkActive`attribute.
- Define child routes and use the `router-outlet`element.

```ts
getNextProductId(id?:number): Observable<number> {
    let subject = new ReplaySubject<number>(1);
	this.replaySubject.subscribe(products=> {
        let nextId=0;
        let index = products.findIndex(p=>this.locator(p, id));
        if (index>-1){
            nextId=...;
        }else{
            nextId= id || 0;
        }
        subject.next(nextId);
        subject.complete();
    });
	return subject;
  }
```

For these methods, accepts an ID value, locate the corresponding product, and return observables that produce the IDs of the next and previous objects in the array that the repo uses to collect the data model objects.

Then add Components to the Project – just like diff component:

```ts
export class ProductCountComponent {
    private diff?: keyValueDiff<any, any>;
    count: number =0;
    constructor(private model: Model,
                private keyValueDiffers: KeyValueDiffers,
                private changeDetector: ChangeDetectorRef) {}
    ngOnInit() {
        this.differ = this.keyValueDiffers
        .find(this.model.getProducts())
        .create();
    }
    
    ngDoCheck(){
        if(this.differ?.diff(this.model.getProducts())!=null) {
            this.updateCount();
        }
    }
    
    private updateCount(){
        this.count= this.model.getProducts().length;
    }
}
```

This `component`uses an inline template to display the number of products in the data model, which is updated when the data model changes. Added a file called categoryCount.component.ts just like this. This component uses a differ to track changes in the data model and count the number of unique categories, which is displayed using a simple inline template, for the final componetn, added a file called `notFound.Component.ts`

## Using Wildcards and Redirections

The routing configuration in an app can quickly become complex and contain redundancies and oddities to cater to the structure of an app – Angular provides two useful tools taht can help simplify routes and also deal problems when they arise – 

### using wildcards in routes

The Angular routing system supports a special path denoted by ** – that allows routes to match any URL – the basic use of the wildcard path is to deal with navigation that would otherwise create a route error. fore:

```html
<button class="btn btn-danger m-1" routerLink="/does/not/exist">
    Generate routing error
</button>
```

Can add:

```ts
{path:"**", componetn: NotFoundComponent}
```

### Using redirections in Routes

Routes do not have to select components .. can be used as aliases that redirect the browser to a different url – redirections are defined using the `redirectTo`prop in a routes.

```ts
{path:"does", redirectTo:"/form/create", pathMatch:"prefix"},
{path:"table", component: TableComponent},
{path:"", redirecTo:"/table", pathMatch:"full"},
```

The `redirectTo`prop is used to specify the URL that the browser will be redirected to. When defining redirections, the `pathMatch`prop **must** also be specified using one of the values described in table.

- `prefix`-- This value configures the route so that it matches URLs that start with the specific path.
- `full`-- this configures the routes so that it matches only the URL specified by the `path`.