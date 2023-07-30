# Redis Data Models

Using a data store of any kind requires making decisions about how to represent the data within the data store. A value can be added to the dbs with the `set`command -- like:

`set user "steve"`

```sh
set logincount 1
incr logincount
get logincount
```

And the largest size of single string value is 512MB.

### Lists

Are a wy to store *related* data. In some contexts, lists are called *arrays*. -- in Redis, a list is a linked list , which means that operations to write to the list are fast.

```sh
lpush users steve bob
lindex users 0
lindex uers 1
lrange users 0 -1
```

### Sets

*sets* are somewhat like lists, in that you use a single key to store multiple values. Unlike lists, set are not retrieved by index number and are not stored. Instead, you query to see if a member exists in the set. Also unlike lists, sets can’t have repeating members within the same key.

```sh
sadd fruit apple
smembers fruit
sismember fruit apple
```

### Hashes

are used to store collection of k/v pairs -- contrast -- there is one vlaue corresponding to one key fore;

```sh
hset house:5150 numBedrooms 3 squareFeet 2700 hvac "foced air"\
hget house:5150 numBedrooms
```

### sorted sets

used to sture data that needs to be **ranked**, such as a leaderbord.

```sh
zadd userFollowers 31 steve 2 owen 13 jakob
zrange userFollowers 0 -1
zrange userFollowers 0 -1 withscores
zrevrange userFollowers 0 -1 withscores
zincrby userFollowers 20 jakob
```

### HyperLogLog

used to keep an estimated count of unique items. like:

```sh
pfadd visitors 127.0.0.1
```

## Patterns and Data structures

### `pub/sub`

Redis can also act as a fast and efficient means to exchange messages in `pub/sub`pattern. When used in such a way, a publisher creates a k-v pair, and zero or more clients subscribe to receive messages. like:

`PUBLISH weather temp:85f`

The message is published to the channel called `weather`regardless whether any clients are subscribed. For client, will receive a message like “message, weather, temp:85f”

## Git turorial

Git is a version control system. helps you keep track code chagnes, is used to collaborate on code. Git and GitHub are just different things -- in this will understand what Git is and how to use it on the remote repository platoforms, like Github.

- Tracking code changes
- Tracking who made chagnes
- Coding collaboration

### What does Git do -- 

- Manage project with repositories
- Clone a project to wok on a local copy
- Control and track changes with staging and committing
- Branch and Merge to allow for work on different parts and versions of a project
- Pull the latest version of the proj to local copy
- Push local updates to the main project

### Working with Git

- Initialize Git on a folder, making it a Repository
- Git now creates a hidden folder to keep track of changes in that foloder.
- When a file changed, added or deleted, considered *modified*
- Select the modified files U want to **stage**
- The **staged** files are **Committed** -- which promts Git to store a permanent snapshot of the files.
- Git allows to see the full history of every commit
- Can revert back to any previous commit
- Git does not store a separate copy of every file in every commit, but just keeps track of changes made in each commit.

### Configure Git

```sh
git config --global user.name "Ianwoo77"
git config --global user.email "dtwy77@gmail.com"
```

Note -- using the `global`just for every repository on computer -- and if want to set the username/email for just the current, just removing the `global`

### Creating a Git Folder

```sh
git init
git status
```

Files in the Git folder can be in one of 2 states:

- `Tracked`-- knows about and are added to the repository
- `Untracked`-- files are in your working dir, but not added to the repository

### Git Staging Environment

One of the core functions of Git is the concepts of the Staging environment -- and the Commit -- May be adding, editing and removing files. *Staged* files that ready to be **committed** to the repo you are working all.

```sh
git add Dockerfile
```

Adding more than one -- Can also stage more than one ..

```sh
git add --all
```

Using `--all`instead of individual filenames will `stage`all changes.

### Git Commit

Since have just finished work are ready move from `stage`to `commit`for our repo. Adding commits keep track of our progess and changes as work. Git considers each `commit`change point or `save point`. It is just a point in the proj you can go back to if you find a bug...

```sh
git commit -m "First release of Dockerfile"
```

`-m`just stand for *message* adds a message.

Git commit without Stage -- Sometimes, when make small changes, using the staging environment seems like a waste of time. It is just possible to commit changes directly. Skipping the staging environment, using th `-a`option will automatically stage every changed.

```sh
# using the --short to see the changes in a more compact way like
git status --short
```

Just see the file we expected is modified, commit it directly like:

```sh
git commit -a -m "updated index.html with a new line"
```

Git Commit Log -- 

```sh
git log
```

# Project misOrganization

Organizing a Go proj is not an easy task -- cuz the Go language provides a lot of freedom in designing packages and modules -- the best practices are not quite as ubiquuitous as they should be.

### Project structure

The Go maintainer has no stronger convention about structuring a proj in Go -- however, one layout has emerged.. If proj is just small enough -- or if has already created its std -- may not be worth using or migrating to project-layout. Just look at this layout and see what the main dirs are:

- `/cmd`-- main source files, the `main.go`should just live in `/cmd/foo/main.go`
- `/internal`-- private code that just don’t want other importing for their app or libs.
- `/pkg`-- public code that want to expose to others
- `/test`-- additional external tests and test data. Unit test in Go live in the same package as the source files, public API tests or integration tests, shouod be here.
- `/configs`, `/docs`, `/examples`
- `/api`-- API contract files, fore, `Swagger, Protocol buffers`
- `/web`-- web app-specfic assets, static files fore
- `/build`-- packaging and conginuous integration files
- `/scripts`-- 
- `/vendors`

Note that, there is no `/src`dir like in some other langs. this just layout such as `/cmd`, `/internal`or `/pkg`

### Packaging Organization

note that in go, there is no concept of sub-packages. Can decide to organize packages within subdirectories.

### Creating Utility packages

Package collisions occur when a variable name collides with an existing package name. just like:

```go
import redisapi "mylib/redis"  // creates an alias for redis package
//...
redis := redisapi.NewClient()
v, err := redis.Get("foo")
```

## Data Types - creating confusion with octal literals

In go, an integer literal starting with 0 is considered an octal. Octal integers are just useful in different scenarios. Used to opena file use `os.OpenFile()`this func requires passing a permission as a `uint32`, fore, linux permission, can pas an octal number for readability instead of base 10 number. like:

```go
file, err := os.OpenFile("foo", os.O_RDONLY, 0644)
```

*0644* just represents a specific Linux permission -- also possible to add an `o`character.

## Neglecting integer overflows

Not understanding how integer overflows ar handled in Go can lead to critical bugs.

### Concepts

Go provides a total of 10 integer types -- four signed integer types and four unsigned types like:

`int8 int16 int32 int64`and it’s unsigned editions. The other most commonly used for `int uint`which have a size that just depends on the system: 32bits, on 32-bits systems... fore if:

```go
var counter int32 = math.MaxInt32
counter++
```

And, this jsut compiles and doesn’t panic at runtime - however, generated an integer overflow .. An integer overflow in go occurs when an arithmetic op creates a vlaue outside the range that can be represented with a given number of bytes. In Go, an integer overflow that can be just detected at compile time generates a compile error. However, at runtime, an integer overflow or underflow is just silent.

### Detecting integer overflow when incrementing

If want to detect an integer overflow during an increment op with a type based on a defined size, can check the value against the `math`constants. like:

```go
func Inc32(counter int32) int32 {
    if counter== math.MaxInt32 {
        panic("Overflow")
    }
    //...
}
```

Function just checks whether the input is already equal to `math.MaxInt32`, for now, the `math.MaxInt`and `math.MinInt`, and `math.MaxUint`are part of the `math`package.

### Detecting integer overflows during addtion

```go
func AddInt(a, b int) int {
    if a > math.MaxInt-b {
        panic("int overflow")
    }
    //...
}
```

### Detecting during multiplication

Have to perform checks against the minimal integer -- `math.MinInt` like:

```go
func MultiplyInt(a, b int) int {
    if a==0 || b==0 {
        return 0
    }
    result := a*b
    if 1==a || 1==b {
        return result
    }
    if a== math.MinInt || b==math.MinInt {
        panic("overflow")
    }
    if result/b != a{
        panic("overflow")
    }
    //...
}
```

In summary, integer overflows *are silent operations in go*, just note that.

# Testing

In go, like structing and organizing your app code, there is no single *right* way to to structure and origanize your tests in Go - but, there are *some conventions, patterns* and can just follow like:

- How to create and run table-driven **unit tests and sub-tests**
- how to unit test your HTTP handlers and middlewares
- how to perform *end-to-end* testing of routes, middlewares and handlers
- how to *create mocks* of dbs module and use then in unit tests.
- A pattern for just testing **CSRF-protected** html form submissions
- how to use a testing instand of `MYSQL`to perform integration tests
- how to easily calculate and profile **Code coverage** of tests

## Unit testing and sub-tests

Create a unit test to just make sure that our `humanDate()`function -- is just outputting `time.Time`values just like:

```go
func humanDate(t time.Time) string {
    return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

### Creating a unit test

In go, its std practice to create your tests in `*_test.go`files which live *directly along side* code you are testing. So in this cse, the first thing that going to do is create a new `/cmd/web/templates_test.go`file hold that test. Then need to create a new unit test for the `humanDate()`like:

```go
func TestHumanDate(t *testing.T) {
	// initialize a new time.Time ob and pass it to the humanDate()
	tm := time.Date(2020, 12, 17, 10, 0, 0, 0, time.UTC)
	hd := humanDate(tm)

	// just check that the output is the format we expect -- if isn't we expect, use the
	// t.Errorf() to indicate the test has failed and log the expected and actual values
	if hd != "17 Dec 2020 at 10:00" {
		t.Errorf("Want %q; got %q", "17 Dec 2020 at 10:00", hd)
	}
}
```

This pattern is the basic one that U will use for nearly all tests that U writes in Go.

- The test is just regular Go code
- unit tests are contined in a normal Go func with `func(*testing.T)`
- To be a valid unit test -- the name of this function *must* begin with `Test`
- Can use the `t.Errorf()`to mark a test as *failed* and log a description message.

jsut:

```sh
go test ./cmd/web
```

And if want more details, can see exactly which tests are being run by using the `-v`to get `verbose`output.

```sh
go test -v ./cmd/web
```

### Table-driven Tests

Just expand function to cover some additional test caes -- specially, going to update it to also check: If the input is the zero time -- and the output from the func always uses the UTC time zone. 

In to an *idiomatic* way to run multiple test cases is to use table-driven tests like: Behind that, is to create a *table* of test cases containing the inputs and expected outputs, and then loop over these, running each test case in a sub-test.

```go
unc TestHumanDate(t *testing.T) {
	// create a slice of anonymous struct like:
	tests := []struct {
		name string
		tm   time.Time
		want string
	}{
		{
			name: "UTC",
			tm:   time.Date(2023, 5, 9, 10, 0, 0, 0, time.UTC),
			want: "09 May 2023 at 10:00",
		},
		{
			name: "Empty",
			tm:   time.Time{},
			want: "",
		},
		{
			name: "GET",
			tm: time.Date(2020, 12, 17, 10, 0, 0, 0,
				time.FixedZone("CET", 1*60*60)), // seconds
			want: "17 Dec 2020 at 09:00",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hd := humanDate(tt.tm)
			if hd != tt.want {
				t.Errorf("Want %q; got %q", tt.want, hd)
			}
		})
	}
}
```

Can see that we get individual output for each of our sub-tests -- might have guessed, our first test case passed. Worth pointing out that when use the `t.Errorf()`to mark a test as failed, it doesn’t cause the `go test`to immediately exit. As a side note, can use the `-failfast`flag to stop the tests funning after the first failure like:

```sh
go test -failfast -v ./cmd/web
```

So, need to head back to the `humanDate()`func and update it to fix these two problems.

```go
func humanDate(t time.Time) string {
	// return the empty string if zero value
	if t.IsZero(){
		return ""
	}
	return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

### Running all tests

To run *all* tests for a proj, instead of just those in a specific package, you can use the **`./...`**wild like:

```sh
go test ./...
```

## Testing HTTP Handlers

All the handlers that written for `Snippetbox`are a bit complex to test, and to introduce things prefer to start off with sth a bit simpler. Just create a new `ping`handler function which  just simply returns a `200`.

```go
func ping(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("ok"))
}

```

In this, jsut create a new `TestPing`which:

- checks that the response status code is 200
- checks body is `ok`

### Recording Responses

NOTE: to assist in testing your HTTP handlers Go provide the `net/http/httptest`package which contains a suits of useful tools -- One of these is the `httptest.ResponseRecorder`type -- essentially an implementation of `http.ResponseWriter`which records the response status code, headers and body instead of actually writing them to a HTTP connection.

So an easy way to unit test your handler is to just create a new `httptest.ResponseRecorder`object, pass it to the handler function, and then examine it again after the handler returns. New a `handler_test`in the /web:

```go
func TestPing(t *testing.T) {
	rr := httptest.NewRecorder() // return a ResponseRecorder

	r, err := http.NewRequest(http.MethodGet, "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	// then just call the ping
	ping(rr, r)

	// call the Result() on the http.ResponseRecorder
	rs := rr.Result()

	// examine the http.Response to check the status code
	if rs.StatusCode != http.StatusOK {
		t.Errorf("Want %q; got %q", http.StatusOK, rs.StatusCode)
	}

	// and check the response body
	defer rs.Body.Close()
	body, err := ioutil.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}

	if string(body) != "ok" {
		t.Errorf("Want body to equal %q", "ok")
	}
}
```

In this code used the `t.Fatal()`in a couple places to handle situations where there is an unexpected error in test code. when called, `t.Fatal()`will mark this test as failed, then completely stop execution of further tests.

### Google Oauth

Register in https://console.developers.google.com and sign in. Just the `OAuth Consent Screen`. 

1. Three scopes - `openid, auth/userinfo.email, auth/userinfo.profile`, check these 
2. Click the *public App button*
3. click the **Credentials** link – create Credentials. Oauth client Id from list options.
4. Web-app, then add url in the authrized redirct URIs enter https://localhost:44350/singin-google

```sh
dotnet user-secrets init
dotnet user-secrets set "Google:ClientId" "<client-id>"
dotnet user-secrets set "Google:ClientSecret" "<client-secret>"
```

Then install the Google package like:

```sh
install-package Microsoft.AspNetCore.Authentication.Google -Version 6.0.16
```

Finally:

```cs
buider.Services.AddGoogle(opts=> {
    opts.ClientId=builder.Configuration["Google:ClientId"];
    opts.ClientSecret= builder.Configuration["Google:ClientSecret"];
})
```

# Adapting Identity UI

- Adaptations allow the files in the Identity UI package to be added to the proj so can be modified, allowing features to be created, customized, or disabled.
- RPs, views, and other files are added to the proj using a process known as *scaffolding* – are given precedence over thos in the Identity UI pacakge, which means that changes made to the scaffolded files.
- Can customize individual features, cannot adjust the underlying approach taken by the Identity UI package, which means there are limits to extend of the changes U can make.

## Understanding Idnetity UI Scaffolding

The `Identity` UI package uses the core **areas** feature – which allows RPs defined in the proj to override those in the UI package – just *as long as* they are in a specific folder. which is in the `Areas/Identity/Pages`. This folder aready exists in the proj, and it contains the Razor View Start file created to enforce a consistent layout.

### Preparing for Identity UI Scaffolding

```sh
Install-Package Microsoft.VisualStudio.Web.CodeGeneration.Design -Version...
```

Then add an element in the `_CustomIdentityLayout.cshtml`file like:

```html
@model Microsoft.AspNetCore.Authentication.AuthenticationScheme

<button type="submit"
    class="btn btn-primary" name="provider" value="@Model.Name">
    @Model.DisplayName
</button>
```

The model for the partial view is an `AuthenticationScheme`object - which is how ASP.NET core describes an *authentication option* – with `Name`and `DisplayName`props. And the partial view renders an HTML button that has an icon 

```html
<form id="external-account" asp-page="./ExternalLogin" 
      asp-route-returnUrl="@Model.ReturnUrl" method="post" class="form-horizontal">
    <div>
        <p>
            @foreach (var provider in Model.ExternalLogins!)
            {
                @await Html.PartialAsync("_ExternalButtonPartial", provider)
            }
        </p>
    </div>
</form>
```

The content in the Login RPs – it can take a litle effort for figure out which section of HTML relates to a specific feature. And some changes to be applied in multiple places – also need change the `Account/Register`page, cuz that also presents buttons for the configured services. This is also need to be scaffolded. Also using this partial view just like:

### Using Scaffolding to Modify C# code

Scaffolding doesn’t just override the view part of a RP, it also creates a page model class contaiing the C# code that implements the  like:

```cs
if (ModelState.IsValid)
{
    // This doesn't count login failures towards account lockout
    // To enable password failures to trigger account lockout, set lockoutOnFailure: true
    var result = await _signInManager.PasswordSignInAsync(Input.Email, 
        Input.Password, Input.RememberMe, lockoutOnFailure: true);
```

So, by default, the `Login`page signs users into the app so taht failed attempts do not lead to lockouts – the changes for that will lockout.

### Configuring the Account Management Pages

The Identity UI package uses a layout and partial view to present the navigation links for the self-management features. To see the default layout – signin to the application using.. 

In addition to the RPs for specific feature, the list contains two files are useful in their own right – `Account.Mange._layout`and `Account.Manage._ManageNav`, the `_Layout`file is the Razor Layout used by the management RPs, and the `_MangeNav`is a partial view that generates the links on the left of the layout.

## Adding an Account Mangement Page

In this, going to demonstrate the process of adding a new management RP, which requires a little additional effort to integrate it into the rest of the management layout. Make the changes for a new page `StoreData`like: To add a new page to management interface, First is to modify the `ManageNavPages`class – which is used to track of the selected page so that the appropriate link is just *highlighted* in the layout.

`public static string StoreData => "StoreData";`

```cs
public static string StoreDataNavClass(ViewContext viewContext)
{
    return PageNavClass(viewContext, StoreData);
}
```

First part of the `ManageNavPages`class is just a set of read-only `string`props for each of the RPs for which links are displayed. These props makes it easy to replace the default pages without breaking the way the links are displayed.

Next section is a set of methods used by the `_ManageNav`to set the clases for the link element just using the `private` `PageNavClass()`to return the `string`active if the page they represent has been selected.

### Adding the Nav link

The `_ManageNav`partial view that was scaffolded by command presents the nav links for individual management RPs. The `Index`page in the `Areas/Identity/Pages/Account/Mange`is presented by default, .. So the next is to add link to the `_ManageNav.cshtml`for the new RPs.

```html
<li class="nav-item">
    <a class="nav-link @ManageNavPages.StoreDataNavClass(ViewContext)"
    id="person-data" asp-page="./StoreData">Store data</a>
</li>
```

The anchor provides a link to the `StoreData`page.

### Defining the new RP

Add new RP named `StoreData.cshtml`on the `Areas/Identity/Pages/Account/Manage`folder like:

```html
@page
@inject UserManager<IdentityUser> UserManager
@{
    ViewData["ActivePage"] = ManageNavPages.StoreData;
    IdentityUser user = await UserManager.GetUserAsync(User);
}

<h4>Store Data</h4>

<table class="table table-sm table-bordered table-striped">
    <thead>
    <tr>
        <th>Property</th><th>Value</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <td>Id</td><td>@user.Id</td>
    </tr>

    @foreach (var prop in typeof(IdentityUser).GetProperties())
    {
        if (prop.Name != "Id")
        {
            <tr>
                <td>@prop.Name</td>
                <td class="text-truncate" style="max-width: 250px">
                    @prop.GetValue(user)
                </td>
            </tr>
        }
    }
    </tbody>
</table>
```

For this, uses the `UserManager<IdentityUser>`class, which provides access to the data in the `IdentityUser`store.

`IdentityUser user = await UserManager.GetUserAsync(User)`

The user is represented by the `IdentityUser`obj – use the reflection features to generate an HTML table containing each prop defined by the `IdentityUser`class.

Just notice that the first statement in the code block defined by the `StoredData`page like:

`ViewData["ActivePage"]= ManageNavPages.StoreData;`

This statement just sets the `ActivePage`view data prop that the `ManageNavPages.PageNavClass`method uses to determine which page has been selected.

### Overriding the Default Layout in an Account Management Page

And the Razor layout this is scaffolded for the account management pages allows PRs to override the default layout by setting a view data property named `ParentLayout`. Just add `_InfoLayout.cshtml`to the Views/Shared folder add:

Then in the `StoreData.cshtml`add:

`ViewData["ParentLayout"] = "_InfoLayout";`

### Blazor Server

Just uses `singalR`to communiate between the client and the server. Is an open-source, real-time communiation library that will create a connection between the client and the server. SignalR can use many – means for transproting data and automatically select the best trasport protocol bsed on your server and client capabilities. 

Note that `SingalR`will just always try to use `WebScokets`- is a transport protocol built into HTML5. And if websockets is not enabled, it will gracefully fall back to another protocol.

Blazor is just built within reusable UI called components – C# code, and markup and can even include another component. And the components are rendered into a render tree - a binary representation of the DOM containing object states and any props or values. And the render tree will keep track of any changes compared to the previous render tree, and then send only things that changes over SignalR using a binary format to update the DOM.

JavaScript will receive the changes on the client-side and update the page accordingly.

- Need to always be connected to the server since the rendering is done on the server.
- There is no Offline mode
- Every click or page upate must do a round trip to the server.
- Load on the server increases and make scaling difficult.

Can just run it inside your web browser using WASM. MS just taken the mono runtime and compiled that into WASM.

A render tree is still created, and *instead of running the RPs on the sever*, now running inside our web browser. Note that the mono runtime that’s compiled into WASM is called `dotnet.wasm`-- the page contains a small piece of Js that will make sure to load the `dotnet.wasm`. Then will download `blazor.boot.json` – containing all the files the app needs to run – as well as the app’s entry point.

# Working with Files

`InputFile`– going to update form to use this – like:

```html
<FormFieldSet>
	<label for="trailImage" class="..." >
    	<InputFile OnChange=... class=... id=... accept=".png,.jpg,.jpeg" />
    </label>
</FormFieldSet>
```

For the most important point to notice is that the `InputFile`component doesn’t use the `bind`directive as the other input components do. Instead must handle the `OnChange`event it expose.

Now that we have the `InputFile`in place, need to add the `LoadTrailImage`method to the code block – like:

```cs
private IBrowserFile? _trailImage;
private void LoadTrailImage(InputFileChangeEventArgs e) 
    => _trailImage=e.File;
```

So, when the user just selects a file, the `OnChange`will fire and the `LoadTrailImage`called.

### Handling multiple Files

`multiple`attribute needed – The `FileCount`prop can be used to check how many files have been selected by the user.

### Uploading files when the form is submitted

Starting with the `SubmitForm`, going to update the existing code to:

```cs
private async Task SubmitForm()
{
    var response = await Mediator.Send(new AddTrailRequest(_trail));
    if (response.TrailId == -1)
    {
        _errorMessage = "There was just a problem saving your trail";
        _submitSuccessful = false;
        return;
    }

    if (_trailImage is null)
    {
        _submitSuccessful = true;

        // if no selected, just reset and return
        ResetForm();
        return;
    }
    await ProcessImage(response.TrailId);
}

private void ResetForm()
{
    _trail = new TrailDto();
    _editContext = new EditContext(_trail);
    _editContext.SetFieldCssClassProvider(
        new BootstrapCssClassProvider()
    );
    _trailImage = null;
}
```

The logic for restting the form is now in its own method. And if a trail has been selected, then call the `ProcessImage()`takes the ID returned from the `AddTrailRequest()`fore:

```cs
private async Task ProcessImage(int trailId)
{
    var imageUploadResponse = await Mediator
    .Send(new UploadTrailImageRequest(trailId, _trailImage));

    if (string.IsNullOrWhiteSpace(imageUploadResponse.ImageName))
    {
        _errorMessage = "your trail was saved, but there a problem uploading the image";
        return;
    }
    _submitSuccessful = true;
    ResetForm();
}
```

### Building the Req and Handler

Now, need to add the `UploadTrailImageRequest`to the `Shared`proj first – a handler for the request in the `Client`proj.

```cs
// in the shared proj:
public record UploadTrailImageRequest(int TrailId, IBrowserFile File):
    IRequest<UploadTrailImageRequest.Response>
{
    public const string RouteTemplate =
        "/api/trails/{trailId}/images";
    public record Response(string ImageName);
}
```

In this case, defining the `TrailId`prop and the `File`prop using the positional construction. Now that have the request in place, can add a handler for it back in the Client proj – new class will go in the `ManageTrails`feature like:

```cs
public class UploadTrailImageHandler :
    IRequestHandler<UploadTrailImageRequest, UploadTrailImageRequest.Response>
{
    private readonly HttpClient _httpClient;

    public UploadTrailImageHandler(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<UploadTrailImageRequest.Response> Handle(UploadTrailImageRequest request,
        CancellationToken cancellationToken)
    {
        var fileContent = request.File
            .OpenReadStream(request.File.Size, cancellationToken);

        using var content = new MultipartFormDataContent();
        content.Add(new StreamContent(fileContent), "image", request.File.Name);

        var response = await _httpClient
            .PostAsync(UploadTrailImageRequest.RouteTemplate
            .Replace("{trailId}", request.TrailId.ToString()),
            content, cancellationToken);

        if (response.IsSuccessStatusCode)
        {
            var fileName = await response.Content
                .ReadAsStringAsync(cancellationToken: cancellationToken);
            return new UploadTrailImageRequest.Response(fileName);
        }
        else
        {
            return new UploadTrailImageRequest.Response("");
        }

    }
}
```

1. The `IBrowserFile`type includes a helper method that allows the file to be read as a stream.
2. A `MultipartFormDataContent`type is created, and the file is added to it.
3. The file is posted to the API
4. If successfuly, API response is deserialized and return

Start by reading the selected file into a stream using the `OpenReadStream()`-- which is just provided by the `IBrowserFile`type – once have the file to upload as a stream, can create a new `MultipartFormDataContent`object and add the file to it. Here, we are including the file’s name when adding to content – but won’t use it in the API – cuz the filename could be used for mailcious purposes and must be considered a security concern. In the API endpoint, just give that a new name - must include a name at this point.

Once, constructed the content we want sent to API, use the `HttpClient`to post it.

### Adding API endpoint

The final piece to add is the API endpoint. This will go in API proj under `MangeTrails`. The package is called *ImageSharp* – use this package to resize the uploaded image to the correct dimensions for our app. …

```sh
Install-Package SixLabors.ImageSharp ... # just not.
```

Second, create a new folder in the root of the API proj called `Images`

then just amke a small update int the API ‘s `program.cs` that will enable the API to serve the images in the new Image folder to the Blazor app as the static files – NOTE THAT: After the existing call to `app.UseStaticFiles()`:

```cs
app.UseStaticFiles(new StaticFileOptions()
{
    FileProvider = new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), @"Images")),
    RequestPath = new Microsoft.AspNetCore.Http.PathString("/Images")
}) ;
// need to note, also need to add:
app.UseStaticFiles();
```

With the admin tasks complete, go and add endpoint to the code base.

```cs
//... Image upload endpoint
public class UploadTrailImageEndpoint : EndpointBaseAsync
    .WithRequest<int>.WithResult<ActionResult<string>>  // note, cannot use interface here
{
    private readonly BlazingTrailsContext _database;
    public UploadTrailImageEndpoint(BlazingTrailsContext database)
    {
        _database = database;
    }

    [HttpPost(UploadTrailImageRequest.RouteTemplate)]
    public override async Task<ActionResult<string>> HandleAsync([FromRoute] int trailId,
        CancellationToken cancellationToken = default)
    {
        var trail = await _database.Trails
            .SingleOrDefaultAsync(x => x.id == trailId, cancellationToken);
        if (trail is null)
        {
            return BadRequest("Trail does not exist");
        }

        var file = Request.Form.Files[0];
        if (file.Length == 0)
        {
            return BadRequest("no image found!");
        }

        var filename = $"{Guid.NewGuid()}.jpg";
        var saveLocation = Path.Combine(Directory.GetCurrentDirectory(), "Images", filename);

        var resizeOptions = new ResizeOptions
        {
            Mode = ResizeMode.Pad,
            Size = new Size(640, 426)
        };

        using var image = Image.Load(file.OpenReadStream());
        image.Mutate(x => x.Resize(resizeOptions));
        await image.SaveAsJpegAsync(saveLocation, cancellationToken);

        trail.Image = filename;
        await _database.SaveChangesAsync(cancellationToken);
        return Ok(trail.Image);
    }
}
```

Start by attempting to laod the trail from the dbs that matches the supplied `trailId`. Create a safe filename and specify where the file should be saved on the server.

# Managing Async Events

Fore, build a progress bar – 

### Making AJAX requests

`ajax`is just another helper constructor, this one preforms an `AJAX`requeste – returns an observable of a single value, like:

```ts
import {ajax} from 'rxjs/ajax';
ajax("/api/mangingAsync/ajaxExample").subscribe(console.log);
```

### Handling errors

Just provide a conceret way to gracefully handle errors as arise – Errors are handled in the `subscribe`call – like:

```ts
.subscribe(
	function next(val) {/ * new value has arrived */}
    function error(err) {/ * error occurred * /}
	function done() {// is done
    }
)
```

for `next()`it’s just called on every new value passed down the observable - this is the option been using. The second `error`just called when error occurs at some point in the observable stream. Once error happens, no further data is sent down. `done()`called when the observable finishes. – fore, not all observables will finish. so for the `ajax`–

```ts
ajax("...")
.subscribe(
	result=> console.log(result),
    err => alert(err.message)
);
```

### promises vs AJAX

A question that always comes up – Promises are simpler in concept – but the real complicates. fore:

```ts
let request$ = interval(5000)
.pipe(
	mergeMap(()=> 
        ajax('/some.json').pipe(retry(3))
));
let carStatus = request$.subscribe(updateMap, displayError);
cartStatus.unsubscribe();
```

This example just shows that observables can be used for much smarter error handling and for just better user experience without sacrificing code simiplicity.

### Loading with Progress Bar

Just start out with 100 requests from the `ajax`ctor, all collected together just in an array. The core is just:

```ts
let request$ = ajax({
    url: endpoint,
    responseType: 'blob'
}).pipe(
	map(res=>({
        blob: res.response,
        x, y
    }))
);
requests.push(request$);
```

So at any time, there will always be a large number of requests to track – even in a singleplayer game. To track the overall state.– There is a `merge`ctor takes any number of parameters and returns a single observable that will emit a value whenever any of the source observables emit. So:

```ts
merge(...requests)
.subscribe(
	val => drawToPage(val),
    err => alert(err),
);
```

Here is a `scan`in action, tracking how many requests have finished and emitting the total percentage on every event:

```ts
merge(...arrayOfRequests)
.pipe(scan(prev=>prev+(100/arrayOfRequests.length), 0))
.subscribe(perdone=>{
    //...
})
```

Just like `reduce`, `scan`also has two params – reducer func and initial value.

# Dealing with Direct Data Access

In the Model class:

```ts
@Injectable() 
export class Model {
    private products: Product[];
    constructor(private datasource: RestDataSource) {
        //..
        this.replaySubject = new ReplaySubject<Product[]>(1);
        this.dataSource.getData()
        .subscribe(data=> {
            this.products=data;
            this.replaySubject.next(data);
            this.replaySubject.complete();
        })
    }
    //...
    getProductObservable(id: number): Observable<Product | undefined> {
        let subject = new ReplaySubject<Product | undefined>(1);
        this.replaySubject.subscribe(productrs=> {
            subject.next(products.find(p=>this.locator(p, id)));
            subject.complete();
        })
        return subject;
    }
}
```

This just changes rely on the `ReplaySubject`to ensure that individual `Product`objects can be received even if the call to the new `getProductObservable`method is made before the data requested by the ctor has arrived. For this, the `ReplaySubject`is useful for this cuz it allows subsequent calls to the `getProductObservable()`to benefit from the data already produced.

Then, for the form component – 

```ts
constructor(private model: Model, activeRoute: ActivateRoute) {
    this.editing = ...;
    let id = ...;
    if(id != null ) {
        model.getProductObservable(id).subscribe(p=> {
            Object.assign(...);
            this.productForm.patchValue(this.product);
        })
    }
}
```

### Using optional Route parameters

Optional route parameters allow URLs to include info to provide hints or guidance to the rest of the app – the form like:

http://localhost:4200/form/edit2;name=lifejacket;price=28.25

just like:

```html
<button class="..." (click)="..."
        [routerLink]="['/form', 'edit', item.id, 
                      {name:item.name, category:item.category, price: item.price}]">
    Edit
</button>
```

The opt values are expressed as literal objects – where property names idientify the opt parameters. in the ctor:

```ts
//...
if(id != null){
    model.getProductObservable(id).subscribe(p=>{
        Object.assign(this.product, p || new Product());
        this.product.name=activeRoute.snapshot.params["name"]??this.product.name;
        this.product.category=activeRoute.snapshot.params["category"]
        	?? this.product.category;
        let price = activeRoute.snapshot.params['price'];
        if (price!=null) {
            this.product.price= Number.parseFloat(price);
        }
        this.productForm.patchValue(this.product);
    })
}
```

### Navigating in Code

Using the `routerLink`attribute makes it just easy to set up navigation in templates – but apps will often need to initiate nav on behalf of the user within a component or directive.

To give access to the routing system to building blocks such as .. Ng provides the `Router`class – is just available as s service through DI and whose most useful methods and properties like:

`navigated, url, isActive(url, exact), events, navigateByUrl(url, extras), navigate(commands, extras)`

```ts
submitForm() {
    if (this.productForm.valid) {
        Object.assign(this.product, this.productForm.value);
        this.model.saveProduct(this.product);
        this.router.navigateByUrl("/");
    }
}
```

### Receiving Navibation Events

In many, there will be components or directives that are not directly involved in the app’s nav but that still need to know when navigation occurs. The `events`defined by the `Router`returns an `Observable<Event>`– which emits a seq of `Event`obj – like:

`NavigationStart, RoutesRecognied, NavigationEnd, NavigationError, NavigationCancel,` FORE:

```ts
constructor(messageService: MessageService, router: Router) {
    messageService.messages.subscribe(msg => this.lastMessage = msg);
    router.events.subscribe(e=> {
        if(e instanceof NavigationEnd || e instanceof NavigationCancel){
            this.lastMessage=undefined;
        }
    })
}
```

## Filesystem layers

Linux containers are made up of stacked filesystem layers – each identified by a unique hash – where each new set of changes made ruing the build process is laid on top of the previous changes. When do a new build, you only have to rebuild the layers that follow the change you re deploying. This just saves time and bandwidth cuz containers are shipped around as layers – don’t have to ship layers that a server already has stored.

To just simplify this a bit – remember that a Docker image contains everything required to run the app – if change on eline of the code, certainly don’t want to waste time rebuilding every dept.

### Images tags

The second kind of revision control offered by Docker – makes it easy to answer an important question – what was the previous version of the app that was deployed – Docker has a built-in mechanism for handling this – image tagging a std build step – can easily leave multiple revisions of your app on the server so that performing a rollback is trivial.

### Building

The Docker command-line tool conains a `build`will consume a `Dockerfile`and produce a Docker image. Each command in a Dockerfile just generates a new layer in the image. Modern multistage Docker builds also means that tracking changes to the build is simplified.

Many Docker builds are a single invocation of the `docker image build`command and generate a single artifact.

### Testing

While Docker itself does not include a built-in framework for testing, the way containers are built lends some advantages to testing with Linux containers.

### Packaging

Docker builds produce an image that can be treated as a single build artifact.

### Deploying

Deployments are handled by so many kinds of tools in different shops that it would be impossible to list them here.

## Ubuntu linux 22.04

```sh
sudo apt-get remove docker docker.io containerd runc
sudo apt-get remove docker-engine
# these two ensure aren't running older version of Docker
```

### Testing the setup

```sh
docker container run --rm -it docker.io/ubuntu:latest /bin/bash
```

For this, using `docker container run`is functionlity the same as using `docker run`.

### Anatomy of a Dockerfile

to create a custom Docker image with the default tools, will need to become familar with the Dockerfile – this file describes all the steps that are required to create an image and is usually conained within the root directory of the source code repository for your appliation. like:

```dockerfile
FROM node:18.13.0
ARG email="anna@example.com"
LABEL "maintainer"=$email

USER root

ENV ap /data/app
ENV SCPATH /etc/...

RUN apt-get -y update

# the daemons
RUN apt-get -y install supervisor
RUN mkdir -p /var/log/supervisor

# supervisor configuration
COPY ./supervisord/conf.d/* $SCPATH/

# app code
COPY *.js* $AP/

WORKDIR $AP
RUN npm install

CMD ["supervisord" "-n"]
```

Each line in a Dockerfile creates a new image layer that is stored by Docker – this layer contains all the changes will only need to build layers that deviate from previous builds.

The `ARG`parameter provides a way for you set vairables and their default vlaues, which are **only** available during the image build process –

`ARG email="anna@example.com"`

And, Applying labels to images and containers allows you to add metadata via k/v pairs that can later be used to search for and identify Docker images and containers. Can see the labels applied to any image using the `docker image inspect`command.

```sh
LABEL "maintainer"=$email
LABEL "rating"="Five starts" "class"="First class"
```

