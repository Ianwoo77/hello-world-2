# Git Github Branch

Start working on an existing file in the branch. After you have finihed editing the file, can click the `Preview changes`to see the change you made highlighted.

### Git Pull branch from github

```sh
git pull
git status
git branch # confirm which branches we have, where are working at the moment
git branch -a
git branch -r # for remote branches only
# can see the branch html-skeleton is available remotely can check out:
git checkout html-skeleton
# and then chek it is up to date
git pull
# now check where working from
git branch
```

### Push a Branch to GitHub

Try to create a new branch, and push that to Github

```sh
git check -b update-readme
# just switch to a new branch
git status
# then just modify README.md 
git add README.md
git status
# then commit that to the branch
git commit -m "updated readme for GIT branches"
# now puh the branch from our local GIT repository
git push origin update-readme
# on the GitHub, can see the new branch
# In github, changes and merge them
```

This comparison shows both the changes from update-readme and html-skeleton cuz we created the new branch from html-skeleton Create pull request.

### Git GitHub Flow

Working using the GitHub flow -- On this will learn how to get the best out of working with Github - The GitHub flowis a workflow designed to work will with Git and GitHub. It focuses on branching and makes it possible for teams to experiment freely -- and make deployments regularly -- 

The Github flow works like this:

- Get a new branch
- Make changes and add commits
- Opan a Pull request
- Review
- Deploy
- Merge

Create a new Branch -- Branching is the key concept in Git -- and it works around the rule that the master branch is always deployable.

Just means -- if you want to try sth new or experiment -- create a new branch always -- Branching gives you an environment where you can make changes without affecting the main branch. And when new branch is ready, can be reviewed, discussed, and merged with the main when ready. -- when you make a new branch, will want to make it from the master branch.

Make changes and Add commits - After the new branch is created, it is just time to get to work. Make changes by adding, editing and deleting files wherever you reach a small milestone, add the changes to your branch by commit. Adding commits keeps track of your work -- each commit should have a message explaining what has changed and why, and each commit becomes a part of the *history of the branch*.

Open a Pull request -- Pull requests are a key part of **GitHub** -- a pull request notifieds people you have changes ready for them to consider or review. Can ask others to review your changes or pull your contribution and merge it into their branch.

Review -- Whan a pull request is made, it can be just reviewed by whoever has the proper access to the branch. This is where good discussions and review of the changes happen.

Deploy -- And, when the pull request has been reviewed and everything good -- it is time for the inal testing, Github allows you to deploy from a branch for final tesing in production before merging the master branch.

Merge -- After testing, can merge the code into the main branch.

### Git GitHub pages

Host your page on Github. Then create a new Repository -- and , the repository needs a specifal name to function as a Github page -- needs to be your GitHub username, followed by the `.github.io`.

Push local Repo to Github pages -- Add this new repo as a remote for local repository, can calling it gh-page...

```sh
git remote add gh-page https://...git
git push gh-page master
```

### Git Github Fork

Add to someone else’s Repository -- At the heart of Git is collaboration, however, Git does not allow you to add code to someone else’s repository without access rights -- show you how to copy a respository, make changs to it, and suggest those changes be implemented to the origin repository.

# Slice and Pointers

Have seen that slicing can cause a leak cuz of the slice cap -- But -- what about the elements, which are still part of the backing array but outside the length range -- does the `GC`collect them -- fore:

```go
type Foo struct {
    v []byte
}
```

For this, want to check the memory allocations after each step as follows -- 

1. Allocate a slice of 1,000 `Foo`elements.
2. Iterate over each `Foo`element, and for ach one, allocate 1MB for the `v`
3. Call `KeepFirstTwoElementsOnly`, which just returns only the first two elements using slicing.

Want to see how memory behaves following the all `keepFirstTwoElementsOnly`and a GC.

```go
func main(){
	foos := make([]Foo, 1000)
	printAlloc()
	for i:=0; i<len(foos); i++ {
		foos[i]=Foo{
			v: make([]byte, 1024*1024),
		}
	}
	two := keepFirstTwoElementsOnly(foos)
	runtime.GC()
	printAlloc()
	runtime.KeepAlive(two)
}

func keepFirstTwoElementsOnly(foos []Foo) []Foo {
	return foos[:2]
}
```

For this:, allocate the `foos`slice -- allocate a slice of 1M for each elemetns, and then call `keepFirstTwoElemetns`and a `GC`, in the end, using the `runtime.KeepAlive`to just keep a reference to the `two`variable after the GC so that it won’t be collected.

may expect the GC to collect the 998 remaining `Foo`elemetns and the data allocated for the slice cuz these elemetns can no longer be accessed.

keep in minds -- **if the elemetn is a pointer or a struct with pointer fields -- the element won’t be reclaimed by the GC**.

Cus `Foo`contains a slice -- the remaining 998 `Foo`and their shice aren’t reclaimed.

So, what are the options to ensure that we don’t leak the remaining `Foo`element -- the first is create a copy like:

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo{
    res := make([]Foo, 2)
    copy(res, foos)
    return res
}
```

Cuz we copy the first two elements of the slice, the GC knows that the 998 elements won’t be referenced any more and can now be collected. And for the second option if want to keep the underlying cap of 1000 elements, which is to mark the slices of the remaining elemetns explicitly as just `nil`.

```go
func keepFirstTwoElementsOnly(foos []Foo) []Foo {
    for i:=2; i<len(foos); i++ {
        foos[i].v = nil
    }
    return foos[:2]
}
```

In this, saw two potential memory leak problems. If handle large slices and reslice them to keep only a fraction -- a lot of memory will remain allocated but unused.

## Inefficient map Initialization

This just discusses smilar to one saw with the slice initliazation -- but using maps -- need to know the basis regarding how maps are implemetned in the Go to understand why tweaking map initialization is important.

### Concepts

A `map`just provides an unordered collection of k-v pairs in which all the keys are distinct. In Go, a map is based on the *hash table* data structure -- Internally, a hash table is an array of buckets, and each bucket is a pointer to an array of k-v pairs. Fore, any array of 4 elements backs the hash table -- one bucket consisting of a sinle k-v pair.

### Initialization

And, to understand the problem related to inefficient map initialization-- create a `map[string]int`like:

```go
m:= map[string]int {
    "1":1,
    "2":2,
    "3":3,
}
```

Internally, this map is backed by an array consisting of a single entry -- hence, a single bucket. And when a map grows, it *doubles* its number of buckets -- So, waht are the condistions for a map to grow -- 

1) The average number of items in the buckets is greater than a constant value -- this constant equals 6.5
2) Too many buckets have overflowed.

Fore, if want to initialize a map that will contain 1M elemetns like:

`m:= make(map[string]int, 1000000)`

Note that with the map, can give the built-in `make`just an initial sie and not a cap. And if specifying the size, provide a **hint** about the number of elements expected to go into the map -- internally, the map is just created with an appropriate number of buckets to store 1 m elements. This saves a lot of computation time cuz the map won’t have to create buckets on the fly and handle rebalancing buckets.

Also, specifying a size doesn’t mean making a map with a maximum number of `n`elements. We can just still add more than `n`elements if needed. Instead, it just means that asking the Go runtime to allocate a map with room for at least n elemetns, which is just helpful if we alaredy know the size up front.

# Testing

## Unit testing and Sub-tests

Fore, for the `HumanDate()`function -- just looks like:

```go
func humanDate(time.Time) string{
    return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

And the reason that want to start by testing this cuz it’s simple function -- 

### Creating a unit test

In Go, `*_test.go`named file live *directly* alongside code that you are testing -- so in this case, the first thing going to do is jsut create `templates_test.go`file to hold the test like under `cmd/web/`dir.

Then just create a new unit test like:

```go
func TestHumanDate(t *testing.T) {
    // initialize
    tm := tem.Date(...., time.UTC) // note that the UTC
    hd := humanDate(tm)
    if hd!= "17 Dec..." {
        t.Errorf("want %q, got %q", "...", hd)
    }
}
```

For this pattern -- is the basic one that you will use for nearly all tests write in go.

- The test is jsut regular Go code, which calls `humanDate()`and checks that the result matches what we expect.
- unit tests are contained in a normal Go function with the signature `func(*testing.T)`
- To be a valid unit test -- the name of the func must begain with the word `Test`.
- Can use the `t.Errorf()`to make a test *failed* and log a descrptive message.

```sh
go test ./cmd/web
```

### Table-Driven Tests

Now expand to cover some additional test cases -- also check -- 

1. If input to this, just return empty string
2. the output from the `humanDate()`func always uses the UTC time zone like

In go -- idiomatic way to run multiple test cases is to use table-driven tests -- esentially, the idea behind a table-driven tests is to create *table* of test cases containing the inputs and expected outputs. And then loop over these, running each test case in a sub-test -- there are a few ways you could set this up -- but a common approach is to define your test cases in an slice of *anonymous structs*.

```go
func TestHumanDate(t *testing.T) {
    tests := []struct {
        name string
        tm time.Time
        want string
    }{
        {name:...,
         tm:...,
         want:...},
        {/*... */},
    }
    
    for _, tt := rang tests {
        t.Run(tt.name, func(t *testing.T) {
            hd := humanDate(tt.tm)
            if hd!=tt.want{
                t.Errorf(...)
            }
        })
    }
}
```

Can just see that get individual output for each of our **sub-tests**. As might have guessed -- first.. failed - get the relevant failure message and filename and line - also, pointing out that use the `t.Errorf()`to mark a test as failed. It doesn’t cause `go test`to immediately exit -- all the other tests and sub-tests will **continue** to be run after a failure.

As a side note - can use the `-failfast`flag to stop the tests funning after the first failure, can:

```sh
go test -failfast -v ./cmd/web
```

And fix the errors like:

```go
func humanDate(t time.Time) string {
    // return the empty string if time has 0 value
    if t.IsZero() {
        return ""
    }
    return t.UTC().Format("...")
}
```

### Running all Tests

To run all the tests for a proj, instead of just those in a specific package, can just using `./...`wildcard pattern.

## Testing HTTP handlers

Move on and discuss some speicific tech for unit testing -- for handlers. Write a new `ping`like:

```go
func ping(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("OK"))
}
```

Create a new `TestPing`unit test which -- 

- Checks that the response status code written by the `ping`is 200
- checks that the response body written by `ping`is “OK”

### Recording Responses

Note -- To assist in testing your HTTP handlers Go just provides the `net/http/httptest`package -- which contains a suite of useful tools like: `httptest.ResponseRecorder`type -- which is essntially an *implementation* of `http.ResponseWriter`which records the response status code.

So an esy to unit test your handlers is to create a new `httptest.ResponseRecorder`obj, pass it to the handler func, and then examine it again after the handler returns.

```go
func TestPing(t *testing.T) {
    // initialize a new httptest.ResponseRecorder
    rr := httptest.NewRecorder()
    
    // intialize a new dummy http.Request
    r, err := http.NewRequeste(http.MethodGet, "/", nil)
    if err!= nil {
        t.Fatal(err)
    }
    
    // Call the ping handler function, passing in the ResponseRecorder and Request
    ping(rr, r)
    
    // Call the Result() on the `http.ResponseRecorder` and get the Response
    rs := rr.Result()
    
    // can then examine the Response to check that the status code
    if rs.StatusCode != http.StatusOK {
        t.Errorf("Want %d; Got %d", http.StatusOK, rs.StatusCode)
    }
    
    // and can just check the response body written by ping
    defer rs.Body.Close()
    body, err := io.ReadAll(rs.Body)
    if err != nil {
        t.Fatal(err)
    }
    if string(body)!= "OK"{
        t.Errorf("want body to equal %q", "OK")
    }
}
```

NOTE -- in the code use the `t.Fatal()`in a couple of places to just handle situations where there is an unexpected error in the test code. When called, `t.Fatal()`just amke the test as failed. Can again with the verbose:

```sh
go test -v ./cmd/web/
```

### Testing Middleware

Also, possible to use the same general tech to unit test your middleware -- demonstrate by creating a `TestSecureHeaders`test for the `secureHeaders`middleware that . As part of the test:

- The middleware sets the `X-Frame-Options: deny`header
- sets the `X-XSS-Protection: 1; mode=block`header
- The middleware correctly calls the next handler in the chain.

```go
func TestSecureHeader(t *testing.T) {
    // initialize a new httptest.ResponseRecorder and dummy http.Request
    rr := httptest.NewRecorder()
    
    r, err := http.NewRequest(http.MethodGet, "/", nil)
    if err != nil {
        t.Fatal(err)
    }
    
    // create a mock http handler that can pass to secureHeaders middleware
    next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("OK"))
    })
    
    // then pass the mock http handler to our secureHeaders middleware
    secureHeaders(next).ServeHTTP(rr, r)
    
    // calling the Result() on the http.ResponseRecorder
    rs := rr.Result()
    
    // then check the middleware has correctly set the header on the responses
    frameOptions := rs.Header.Get("X-Frame-Options")
    if frameOptions != "deny" {
        t.Errorf("want %q, got %q", frameOptiosn)
    }
    
    // and check the middleware has correctly set the X-XSS-Protection header
    xssProtection := rs.Header.Get("X-XSS-Protection")
    if xssProtection != "1; mode=block" {
        t.Errorf("want %q, got %q", "1; mode=block", xssProtection)
    }
    
    // then check the middleware has correctly called the next handler line
    if rs.StatusCode != http.StatusOK {
        t.Errorf("want %d, got %d", http.StatusOK, rs.StatusCode)
    }
    
    defer rs.Body.Close()
    body, err := io.ReadAll(rs.Body)
    if err != nil {
        t.Fatal(err)
    }
    if string(body)!= "OK" {
        t.Errorf("Want body to equal %q", "OK")
    }
}
```

### Running Specific Tests

Also, possible to run only specific tests by using the `-run`flag -- this allows you to pass in a Regular expression -- and only tests with a name that matches the regular expression wil be run like:

```sh
go test -v -run="^TestPing$" ./cmd/web/
```

Can even use the `-run`flag to limit testing to some specific sub-tests like:

```sh
go test -v -run="^TestHumanDate$/^UTC|CET$" ./cmd/web
```

### Parallel Testing

By default, the `go test`comamnd executes all tests in a serial manner -- one after the another -- when have a small number -- is fast -- abosolutely fine -- but if have 100 ..1000 may save your time by running your tests in parallel. Can just indicate that it’s ok for a test to be run in concurrently alongside other tests by calling the `t.Parallel()`like:

```go
func TestPing(t *testing.T) {
    t.Parallel()
    // ...
}
```

It’s just important to note -- 

- Tests marked with `t.Parallel()`will be run in parallel with -- *and only with* -- other parallel tests.
- By default, the maximum number of tests that wil be run just simultaneously is the current value of the `GOMAXPROCS`, can override via the `-parallel`flag like:

```sh
go test -parallel 4 ./...
```

- Not all tests are suitable to be run in paralle -- fore, if you have an integration tst which requires a dbs table to be in a specific known state, then wouldn’t want to run it in parallel with other test manipulate the same dbs table.

### Enabling the Race Detector

And the `go test`command includes a `-race`flag which enables Go’s `race detector`when running tests. Note that if the code you are testing leverages concurrency, or you are running tests in parallel, enabling this can be a good idea to help to flag up race condition that exists in your app.

It’s important to point out that the race detector is just a tool that flags the data race -- if and when they occur at runtime.

# Edituing User Details

The previous demonstrated the basic ops for creating, reading and deleting `IdentityUser`objects – note that which are three of the four classic data operations – demonstrate how these features can be used to create custom workflow in later – but there is one additional op that creates the classic set – performing an update – 

```cs
public class EditBindingTarget
{
    [Required]
    public string UserName { get; set; } = default!;

    [Required]
    [EmailAddress] public string Email { get; set; } = default!;

    [Phone]
    public string PhoneNumber { get; set; } = default!;
}


public class EditModel : AdminPageModel
{
    public UserManager<IdentityUser> UserManager { get; set; }
    public EditModel(UserManager<IdentityUser> userManager)
    {
        UserManager = userManager;
    }

    public IdentityUser IdentityUser { get; set; }

    [BindProperty(SupportsGet = true)]
    public string Id { get; set; } = default!;

    public async Task<IActionResult> OnGetAsync()
    {
        if (string.IsNullOrEmpty(Id))
        {
            return RedirectToPage("Selectuser",
                new { Label = "Edit User", Callback = "Edit" });
        }
        IdentityUser = await UserManager.FindByIdAsync(Id);
        return Page();
    }

    public async Task<IActionResult> OnPostAsync(
        [FromForm(Name = "IdentityUser")] EditBindingTarget userData)
    {
        if (!string.IsNullOrEmpty(Id) && ModelState.IsValid)
        {
            IdentityUser user = await UserManager.FindByIdAsync(Id);
            if (user != null)
            {
                user.UserName = userData.UserName;
                user.Email = userData.Email;
                if (!string.IsNullOrEmpty(userData.PhoneNumber))
                {
                    user.PhoneNumber = userData.PhoneNumber;
                }
            }

            IdentityResult result = await UserManager.UpdateAsync(user!);
            if (result.Process(ModelState))
            {
                return RedirectToPage();
            }
        }
        IdentityUser = await UserManager.FindByIdAsync(Id);
        return Page();
    }
}
```

When the user submits the form, the core model binding feature assings the form values to the properteis to an instance of the `EditBindingTarget`class.

```html
@page "{id?}"
@model IdentityApp.Pages.Identity.Admin.EditModel
@{
    ViewBag.Workflow = "Edit";
}

<div asp-validation-summary="All" class="text-danger m-2"></div>

<form method="post">
    <input type="hidden" asp-for="Id"/>
    <div class="mb-3">
        <label>UserName</label>
        <input class="form-control" asp-for="IdentityUser.UserName"/>
    </div>

    <div class="mb-3">
        <label>Normalized UserName</label>
        <input class="form-control" asp-for="IdentityUser.NormalizedUserName"
               readonly/>
    </div>

    <div class="mb-3">
        <label>Email</label>
        <input class="form-control" asp-for="IdentityUser.Email"/>
    </div>

    <div class="mb-3">
        <label>Normalized Email</label>
        <input class="form-control"
               asp-for="IdentityUser.NormalizedEmail" readonly/>
    </div>

    <div class="mb-3">
        <label>Phone Number</label>
        <input class="form-control" asp-for="IdentityUser.PhoneNumber"/>
    </div>

    <div>
        <button type="submit" class="btn btn-success">Save</button>
        <a asp-page="Dashboard" class="btn btn-secondary">Cancel</a>
    </div>
</form>
```

The view  part of the page displays an HTML form with just fields. Can use the model binding directly with an instance of the user class – but this approach allows to selective about the fields that interstead.

And the POST handler method uses the `Id`prop, which is set using model binding, so  search the user store with the `FindByIdAsync()`and update the props of the resulting `IdentityUser`object with the form data values. like:

```cs
if (user != null) {
    user.UserName= userData.Username;
    user.Email= userData.Email;
    user.EmailConfirmed=true;
    //...
}
```

Notice that just set the `EmailConfirmed`to true - as a general rule, email addresses set by administrators should not require the user to go through confirmation process. And changes to an `IdentityUser`object are not added to the store until the user manger’s `UpdateAsync()`method is called like:

`IdentityResult result = await UserManger.UpdateAsync(user);`

This mehod updates the user store and returns `IdentityResult`object – and to integrate the new work flow.

```html
<a class="btn btn-success d-block mt-2 @getClass("Edit")" asp-page="Edit"
   asp-route-id="">
    Edit Users
</a>
```

And noticed that normalized username prop is automatically updated – this is done by the user manager’s `UpdateAsync`method and it helps  ensure consistency in the user store. And the `UpdateAsync`also performs validation, which can see by editing the `Alice`account and entering the .. existed email.

### Fixing the Username and Email problem 

Identity supports different values for a user’s username and email address, which are stored using the `IdentityUser`class `Username`and `Email`properties. This just means that a user can sign with a username that is not their email address.

For other apps, it makes more sense to use the meail address as the username and keep both `IdentityUser`fields sync. Like:

`user.UserName= userData.Email;`

## Understanding the UserStore

The `UserManager<IdentityUser>`class doesn’t store data itself, instead, it depends on **dept injection** to obtain an implemetnation of the `IUserStore<IdentityUser>`interface. This interface defines the opts required to store and retreive `IdentityUser`data. And there also additional interfaces that can be implemetned by user stores that support additional features.

Instead, for now just have to know to set up the user store to understand which features it implemetns – the user store in the example app is th eone that Ms provides for storing dat in a SQL dbs using EF core. like:

```cs
builder.Services.AddDefaultIdentity<IdentityUser>(opts=> {
    opts.Password.RequiredLength=5;
    //...
}).AddEntityFrameworkStores<IdentityDbContxt>();
```

And the `AddEntityFrameworkStores()`just set up the user store, and the generic type arg specifies the EF core context that will be used to access the dbs.

Separating the user manager from the user store means that sets up the user store, and the generic – it is relatively simple to change the user store if the nees of the proj changes. As long as new user store can work with your chosen user class, there should be litle difficulty in moving from one to another.

Add a razor pages named `Features.cshtml`to the `Pages/Identity/Admin`folder with the content like:

Just like:

```cs
public class FeaturesModel: AdminPageModel {
    public FeaturesModel(UserManger<IdentityUser> mgr) {
        UserManger=mgr;
    }
    public UserManger<IdentityUser> UserManger{get;set;}
    public IEnumerble<(string,string)> Features {get;set;}
    
    public void OnGet(){
        Features = UserManger.GetType().GetProperties()
            .Where(prop=>prop.Name.StartsWith("Supports"))
            .OrderBy(p=>p.Name)
            .Select(prop=>(prop.Name, prop.GetValue(UserManger)
                          .ToString()));
    }
}
```

### Changing the Identity Configuration

And will notice that the user store doesn’t support roles. This is cuz the Identity UI package doesn’t support roles, and the method used to set up Identity and Identity UI doesn’t include the configuration infor for role support.

Going to need role feature. like:

```cs
builder.Services.AddIdentity<IdentityUser, IdentityRole>(opts=>
{
    //...
}).AddEntityFrameworkStores<IdentityDbContext>();
```

The user store set up the `AddEntityFrameworkStores`method does support roles, but only when role class has been selected.

## Signing In and Out and Managing Passwords

- These API features are used to create workflows for signing the user into the application with password and signing them out again when have finished the session. These features are also used to manage passwords, both to set password administratively and perform self-service password changes and password receovery.
- Passwords are not the only way to authenticate with an Identity app, but they are the most widely used and are required by most projects.
- Passwords re managed using methods provided by the `UserManager<IdentityUser>`class, which allows passwords to be added and remove from a user account. Users sign into and out of the app using methods defined by the sign-in manger class `SingInManager<T>`
- The sign-in process can be complex, especially if the proj supports two-factor authentication and external authentication.
- The featuers are built on the underlying Core platform – which could use directly to achieve the same result – however, doing so would undermine the purpose of using `Identity`to mangage users.

## Adding Passwords to the Seed Data

The user accounts used to seed the user store won’t be able to sign into the app cuz they have no credentials. Identity supports a range of authentication mechansim and doesn’t require `IdentityUser`objects to be created with any specific authentication data. The basic authentication model uses a password, and that is where will start.

- `HasPasswordAsync(user)`– returns `true`if the specified `IdentityUser`object has been assigned a pwd.
- `AddPasswordAsync(user, password)`-- This adds a password to the store for the specified `IdentityUser`

### Configure the `InputFile`Component

```cs
private IBrowserFile? _trailImage;
private void LoadTrailImage(InputFileChangeEventArgs e) {
    _trailImage= e.File;
}
```

Just note that the important point to notice that the `InputFile`component doesn’t use the `bind`directive as the other input components do. Instead, must handle the `OnChange`method.

When the user selects a file, the `OnChange`event will fire and the `LoadTrailImage`will run. This just uses `InputFileChangeEventArgs`to assign the selected file to the `trailImage`field.

### Uploading files when the form is just submitted 

When submit the form, the data entered is packaged into an `AddTrailRequest`and dispatched to the API via `MediatR`. Going to extend this logic to check if an image has been selected and make an additional call to upload it. FORE:

```cs
private async Task SubmitForm() {
    var response= await Mediator.Send(new AddTrailRequest(_trail));
    if(response.TrailId==-1){
        _errorMessage = "There was a problem saving your trail.";
        _submitSuccessful = false;
        return;
    }
    
    if(_trailImage is null) {
        _submitSuccessful = true;
        ResetForm();
        return;
    }
    await ProcessImage(response.TrailId);
}

private void ResetForm() {
    _trail = new TrailDto();
    _editContext= new EditContext(_trail);
    _editContext.SetFiledCssClassProvdier(
    new BootstrapCssClassProvdier());
    _trailImage = null;
}
```

The first change is a check to see if a trail image has been selected, if an image hasn’t been selected, then we reset the from as the method did originally. FORE:

```cs
private async Task ProcessImage(int trailId) {
    var imageUploadresponse= await Mediator
        .Send(new UplaodTrailImageRequest(trailId, _trailImage));
    if (string.IsNullOrWhiteSpace(imageUplaodResponse.ImageName)) {
        _errorMessage = "your trail was saved, but there was a problem";
        return;
    }
    _submitSuccessful = true;
    ResetForm();
}
```

For this, the method first attempts to upload the image, this is done using an `UploadTrailImageRequest`, dispatchd via `MediatR`– the request takes the trail ID the image is for. – If there is a problem uploading the image, just an error message is shown to the user.

### Building The Request and Handler

That is just all the changes we need to make in the form component. Now need to add the `UploadTrailImageRequest`to BlazingTrails.Shared. just creating `record`like:

```cs
public record UploadTrailImageRequest(int TraiId, IBrowserFile File):
	IRequest<UploadTrailImageRequest.Response>{
        public const string RouteTempalte = 
            "/api/trails/{trailId}/images";
        public record Response(string ImageName);
    }
```

Will notice that as add more requests that their formats are largely uniform – the properties that make up the request are defined using positional construction.

In this case, defining the `TrailId`prop and the `File`prop using positional construction – the `record`also defines a route tempalte, which is used in both the endpoint and handler – as well as a response, which defines the data returned from the request – like:

```cs
public class UploadTrailImageHandler:
	IRequestHandler<UploadTrailImageRequest, UploadTrailImageRequest.Response>
    {
        private readonly HttpClient _httpClient;
        public UploadTrailImageHandler(HttpClient httpClient) {
            _httpClient= httpClient;
        }
        
        public async Task<UplaodTrailImageRequest.Response>
            Handle(UploadTrailImageRequest request, Cancellationtoken token) {
            var fileContent = request.File
                .OpenReadStream(request.File.Size, token);
            
            // the file is added to it
            using var content= new MultipartFormDataContent();
            content.Add(new StreamContent(fileContent),
                        "image", request.File.Name);
            var response = await _httpClient
                .PostAsAsync(UploadTrailImageRequest.RouteTimeplate
                            .Replace("..."), 
                            content, token); // note that content is used here
            if(response.IsSuccessStatusCode) {
                // If the upload was successful, then response is deserialzied and returned.
                var fileName= await 
                    response.Content.ReadStringAsync(cancellationToken: token);
                return new UploadTrailImageRequest.Response(fileName);
            }else {
                return new UplaodTrailImageRequest.Response("");
            }
        }
    }
```

Start by reading the selected file into a stream using the `OpenReadStream`– Which is just provided by the `IBrowserFile`type – once have the file to upload as a stream, can create a new `MultipartFormDataContent`object - and add the file to it.

### Adding the API endpoint

The final piece to add this api endpoint, this will go in the API project under .. First, will add package from Nuget.. The package is called – using this package to resize the uploaded image to the correct dimensions for app – like that.