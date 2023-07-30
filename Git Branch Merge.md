# Git Branch Merge

For now, have the emergency fix ready... In Git, a `branch`is a new/separate version of the main repo. With a new branch called new-design -- edit the code directly without impacting the main branch.

- There is an unrelated errors somewhere else in the project that needs to be fixed
- Create a new branch from the main proj called fore `small-error-fix`
- Just fix the unrelated error and merge the `small-error-fix`branch with the main branch
- go back to the new-design branch, and finish work
- **Merge** the new-design branch with main.

### New Branch

```sh
git branch hello-world-images
git branch # show all
```

When see the new branch with the name -- but the `*`just beside the master just specifies currently branch.

`checkout`is the command used to check out a branch. like:

```sh
git checkout hello-world-images
```

first, added a new file and modify the file, then :

```sh
git status
git add --all
git status
git commit -m "Added image to the hello world"
```

Just note: using th `-b`option on the `checkout`will create a new branch, and move to it, if doesn’t exist.

### Swtiching between Branches

See jsut how quick and easy it is to work with different branches -- and how will it works -- currently on the branch, now added an image to this branch, list the files in the current. Can see new files. then change the branch to `master`

```sh
git checkout master
```

NOTE: for now, the new image is no longer there.

### Emeregency Branch

Don’t want to mess with master directly, and do not want to mess with `hello-world-images`. Don’t want to mess with master directly, and do not want to mess with `hello-world-images`branch -- since it is not done yet.

Can create a new branch to deal with emergency:

```sh
git checkout -b emergency-fix
```

For now, create a new branch from master, and changed to it. can just safely fixt the error without disturbing the other branches.

```sh
git status
git add index.html
```

### For now merge branches

```sh
git checkout master
```

Now need to merge the current branch with the `emergency-fix`branch:

```sh
git merge emergency-fix
# updating ... 
```

Since the emergency-fix branch came directly from master, and no other changes had been made to master while we were working - `git`sees this as a continuation of master. So can **Fast-forward**.

For now, as master and emergency-fix essentially the same now, can delete emergency-fix branch, cuz no longer needed like:

```sh
git branch -d emergency-fix
```

### Merge Conflict

Now can move to the `hello-world-images`and keep working -- add other image file and change the `index.html`:

```sh
git add -all
git commit -m "add new image"
# then see that index.html has been changed in both
# now are ready to merge
git checkout master
git merge hello-world-images
# auto-merging -- conflict: failed...
```

The merge just failed, as there is conflict between the versions for `index.html`.

For this, need to fix that conflict. Just can see the difference between the versions and edit it:

```sh
git add index.html
git status
git commit -m "merged after fixing conflicts"
# then delete hello-world-images branch
git branch -d hello-world-images
```

# Being confused abou `nil`vs. empty slices

Go developers fairly frequently mix `nil`and empty slice -- may want to use one over the other depending on the use case, Meanwhile, some libraries make a distinction between the two. To be proficient with slices, need to just make sure don’t mix these concepts

- A slice is empty if its length 0
- A slice is `nil`if equals `nil`

```go
func log(i int, s []string) {
	fmt.Printf("%d: empty=%t\tnil=%t\n", i, len(s) == 0, s == nil)
}

func main() {
	var s []string
	log(1, s)  // nil = true

	s = []string(nil)
	log(2, s) // nil = true

	s = []string{}
	log(3, s)

	s = make([]string, 0)
	log(4, s)
}
```

For this, all the slices are empty -- meaning that the length jsut 0, therefore, a `nil`is also an empty -- only the first two are nil slices -- if have multiple ways to initialize a slice -- which option favor -- two things to note:

- One of the main differences bwtween a `nil`and an `emtpy`regards alloations -- Initializing a `nil`doesn’t require any allocation, which isn’t the case for an empty slice.
- Regardless of whether a slice is `nil`, calling the append built-in **works**.

Consequently, if a func returns a slice -- shouldn’t do as in other langs and return a non-nil collection for defensive reasons. Cuz a `nil`slice doesn’t requrie any allocation -- should **favor** returning a `nil`. Like:

```go
func f() []string {
    var s []string
    if foo() {
        s= append(s, "foo")
    }
    if bar(){
        s= append(s, "bar")
    }
    return s
}
```

for this, if both `foo`and `bar`false, get just an empty slice. If in other langs, can use option 4 `make([]string,0)`with a just zero-length string. -- but doing so doesn’t bring any value compared to option 1.

Howerver, in the case where have to produce a slice with a just known length, should use option 4 like:

```go
func intsTostring(ints []int) []string {
	s := make([]string, len(ints))
	for i, v := range ints{
		s[i]=strconv.Itoa(v)
	}
	return s
}
```

Now, two options remain from the example and looks at diffrent ways to initialize a slice :

- `s:= []string(nil)`
- `s:= []string{}`

Option 2 isn’t the widely used -- can be helpful as sync sugar, fore, pass a `nil`slice in a single line fore `append`:

`s := append([]int(nil), 42)`

And if had used option 1, it would have required two lines of code. This is probabley not the most importnat readability optimiation of all time.

But for `s:= []string{}`which is recommended to create a slice with initial elements.

Should also mention that some libraries distinguish between `nil`and *empty* slices. This is the case, fore, with the `encoding/json`package -- the following examples marshal two structs, one containing a nil slice and the second non-nil empty slice like:

```go
var s1 []float32
customer1 = customer{
    ID:"foo",
    operations:s1,
}
b, _ := json.Marshal(customer1)
fmt.Println(string(b))

s2 := make([]float32,0)  // non-nil, just empty
customer2 := customer{
    ID: "Bar", 
    operations: s2,
}
b, _ = json.Marshal(customer2)
fmt.Println(string(b))
```

For this, noticed :

The first is just `Operations: null`and the second just `{operations:[]}`

Here, a nil slice is marshaled as a `null` whereas a non-nil, empty slice is marshled as an empty one. And the `encoding/json`isn’t the only from the STDLIB to just make this distinction -- FORE, `relect.DeepEqual`returns `false`if compare a nil and an empty.

In Go, there is a distinction between `nil`and empty -- a `nil`equals `nil`, whereas an empty slice has a length of zero. and a nil is empty, but an empty isn’t necessary `nil`.

- `var s []string`just aren’t sure about the final length and slice can be empty
- `[]string(nil)`just as a syntactic sugar to create a `nil`and empty
- `make([]string, length)`if future length is known.

### Not properly checking if a slice is empty

Namely, what is the idiomatic way to check if a slice contains elements -- like:

```go
// check for that contains elements
func handleOperations(id string) {
	operations := getOperations(id)
	if operations != nil {
		handle(operations)
	}
}

func getOperations(id string) []float32 {
	operations := make([]float32, 0)
	if id == "" {
		return operations
	}
	return operations
}
```

For this, determine whether a slice has elements by checking if the `operations`slice isn’t `nil`but there is a problem -- `getOperations()`never returns a nil slice -- instead, it just returns an empty maybe. and the `opeations!=nil`jsut returns true always. fore:

`operations := make([]float32, 0)`

This way, the check we implement about testing the slice nullity matches - however, this approach doesn’t work in all stiuations - cuz we are not alwys in a context where change the callee.

How check -- the solution is just check the length:

```go
func handleOperations(id string) {
    operations := getOperations(id)
    if len(operations)!=0 {
        handle(operations)
    }
}
```

- If the slice is `nil`, `len(opeations)`is false
- if `nil`but empty, also works

Hence, checking the length the **best** option to follow. When desigining interfaces, we should always avoid distinguishing `nil`and *empty slices.*

# End-to-End Testing

But, in most of the ime, HTTP handlers aren’t actually used in isolation -- so in this going to explain how to run *end-to-end* tests on your web apps that encompass your routing, middlwe and handlers.

*end-to-end* testing should give you more confidence that your app is working correctly then just unit-testing in isolation. Will adapt `TestPing`func so that it runs an end-to-end test on our code. Want the test to ensure that a `GET /ping`request to our app -- calls the `ping`handler and results a 200 ok.

Essentally, want to just test our app has a route like: 

`GET /ping ping()`

### Using httptest.Server

The key to end-to-end testing our app is the `httptest.NewTLSServer()`func -- which spins up a `httptest.Server`interface that can make HTTP requests to. in the `handlers_test.go`file and:

```go
func TestPing(t *testing.T) {
	// create a new instance of our app -- contains a couple of mock loggers
	app := &application{
		errorLog: log.New(io.Discard, "", 0), // just doing nothing
		infoLog:  log.New(io.Discard, "", 0),
	}

	// use the httptest.NewTLSServer() to create a new test server, passing in the value returned
	// by app.routes() method -- this start up a HTTPs server which listens on a randomly-chosen port
	// of local machine
	ts := httptest.NewTLSServer(app.routes())
	defer ts.Close()

	// The network address that the server is listening on is contained
	// in the field. Can use the ts.Client().Get() to make a GET /ping
	rs, err := ts.Client().Get(ts.URL + "/ping") // returns a http.Response
	if err != nil {
		t.Fatal(err)
	}

	// now check the value of the response status code
	if rs.StatusCode != http.StatusOK {
		t.Errorf("Want %d, got %d", http.StatusOK, rs.StatusCode)
	}

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}
	if string(body) != "OK" {
		t.Errorf("want body to equal %q", "OK")
	}
}
```

There are few about this code to point out -- 

- The `httptest.NewTLSServer()`accepts a `http.Handler`as parameter, and this handler gets called each time the test server receives a HTTPs request -- on case passed in the return vlaue from the `app.routes()`as the handler. Doing this gives us a test server that exactly mimics our app routes -- middleware and handlers, and is a big upside of the work did.
- If testing a HTTP, using the `httptest.NewServer()`instead
- loggers are needed by some middlewares, which are used by app on every route -- without these, panic.

For now, cuz havn’t actually registered a `GET /ping`route with our route yet.

in the `routes.go`file add:

```go
// just add a new GET /ping route here
mux.Get("/ping", http.HandlerFunc(ping))
```

### Using Test Helpers

For our `TestPing()`is now working nicely -- there is a good opportunity to break out some of this code into some helper functions -- which can reuse as we add more end-to-end tests

There is no hard-and-fast rules about where to put helpers for tests -- if a helper is only used in a specific `*_test.go`file then it probably makes sense to include it inline in that file alongside your tests. At the other end of spectrum, if are going to use a helper in tests across multiple packages, then might want to put it in a reusable package just called `/pkg/testutils`which can be imported by test files. FORE:

```go
// create a new helper with returns an instance of
// app struct contains mocked dependencies
func newTestApplication(t *testing.T) *application {
	return &application{
		errorLog: log.New(io.Discard, "", 0),
		infoLog:  log.New(io.Discard, "", 0),
	}
}

// define a custom testServer type which anonymously embeds a http.Server instance
type testServer struct {
	*httptest.Server
}

// create a newTestServer helper which initializes and returns a new instance
func newTestServer(t *testing.T, h http.Handler) *testServer {
	ts := httptest.NewTLSServer(h)
	return &testServer{ts}
}

// implement a get method on custom testServer type -- makes a GET request to a given
// url path on the test server, and returns the response status code
func (ts *testServer) get(t *testing.T, urlPath string) (int, http.Header, []byte) {
	rs, err := ts.Client().Get(ts.URL + urlPath)
	if err != nil {
		t.Fatal(err)
	}

	defer rs.Body.Close()
	body, err := io.ReadAll(rs.Body)
	if err != nil {
		t.Fatal(err)
	}

	return rs.StatusCode, rs.Header, body
}
```

Then just headback the `TestPing`handler and update these new helpers like:

```go
func TestPing(t *testing.T) {
	app := newTestApplication(t)
	ts := newTestServer(t, app.routes())
	defer ts.Close()

	code, _, body := ts.get(t, "/ping")
	if code != http.StatusOK {
		t.Errorf("Want %d, got %d", http.StatusOK, code)
	}
	if string(body) != "OK" {
		t.Errorf("Want body to equal %q", "OK")
	}
}
```

This is -- now have a neat pattern in palce for spinning up a tests server and making request to it.

### Cookies and Redirections

Been using the `ts.Client().Get()`method to make requests against our test server. The `ts.Client()`just returns a configurable `http.Client`. Which can change to make these request work slightly differently.

And, there is couple of chagnes -- 

- Don’t want the client to automatically follow redirects -- want to just return the first HTTPs response sent by our server so can test the response for that specific request.
- Want the client to *automatically store any cookies sent in a HTTPs response*. So that can include them in any subsequent requests back to the test server. This will come in handy later.

To make this -- just like:

```go
func newTestServer(t *testing.T, h http.Handler) *testServer {
	ts := httptest.NewTLSServer(h)

	// initialize a new cookie jar
	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	// add the cookie jar to the client, so that response cookies are stored and then
	// sent with subsequent requests
	ts.Client().Jar = jar

	// disable redirect-following for the client, Essentially, this function is called after
	// a 3XX response is received by the client.
	ts.Client().CheckRedirect = func(req *http.Request, via []*http.Request) error {
		return http.ErrUseLastResponse
	}
	return &testServer{ts}
}
```

# Using the Identity API

There are just limits to the customization that can be made to the Identity UI package. Minor changes can be achieved using scaffolding, but if app doesn’t fit into the self-service model that Identity UI expects – won’t be able do that.

In this - describe the API that Core Identity provides, which can be used to create completely custom workflows. This is the same API Identity UI uses, but using it directly means that you can create any combination of features U require and impelment them exactly as needed.

- The Identity API provides acces to all of the Identity features.
- The API allows custom workflows to be created that perfectly match the requirements of a proj, which may not be what the Identity UI package provides.
- Key classes are provdied as services that are available through the std Core DI feature.

## Creating the User and Administrator Dashboards

Going to create custom workflows for the operations commonly required by most apps – in versions that can be used by administrators and by *self-service* users.

Create two dashboard -style layouts – one for administrator functions , and one for self-service. New a `_Layout.cshtml`in the `Pages/Identity`folder like:

```html
<body>
@if (showHeader)
{
    <nav class="navbar navbar-dark bt-@theme">
        <a class="navbar-brand text-white">IdentityApp</a>
        <div class="text-white">
            <partial name="_LoginPartial"/>
        </div>
    </nav>
}

<h4 class="bg-@theme text-center text-white p-2">@banner</h4>
<div class="my-2">
    <div class="container-fluid">
        <div class="row">
            @if (showNav)
            {
                <div class="col-auto">
                    <partial name="@navPartial" model="@((workflow, theme))"/>
                </div>
            }
            <div class="col">
                @RenderBody()
            </div>
        </div>
    </div>
</div>
</body>
```

Just using the `ViewData`values to the Bootstrap theme to determine. Then need to add view named `_Workflow`folder, in the `Pages/Identity`with the content like:

```html
@model (string workflow, string theme)

@{
    Func<string, string> getClass = feature =>
        feature != null && feature.Equals(Model.workflow) ? "active" : "";
}

<a class="btn btn-@Model.theme btn-block @getClass("Overview")" asp-page="Index">
    Overview
</a>
```

NEXT, create the 

```cs
@{
    Layout = "_Layout";
    ViewData["theme"] = "success";
    ViewData["banner"] = "Administration Dashboard";
    ViewData["navPartial"] = "_AdminWorkflows";
}

@RenderBody()
```

Use these, only need to set the view data props to differentiate the administration view from the user view. Then:

```cs
@model (string workflow, string theme)

@{
    Func<string, string> getClass = (string feature) =>
        feature != null && feature.Equals(Model.workflow) ? "active" : "";
}

<a class="btn btn-@Model.theme d-block @getClass("Dashboard")"
   asp-page="Dashboard">
    Dashboard
</a>
```

Then add the `_ViewStart.cshtml`to the `Pages/Identity/Admin`with the content like:

### Creating the Custom Base classes

Will use the Core authorization feature to just restrict access to the user features are only avaiable for signed-in users and administration features are only available to designated adminstrators.

```cs
public class UserPageModel : PageModel
{
    // no methods required
}
```

To create the common base class for the administration features, add class file anmed `AdminPageModel.cs`like:

```cs
public class AdminPageModel : UserPageModel
{
    //... nothing
}
```

### Creating the Overview and Dashboard pages 

Add a razor page named `index.cshtml`like:

```html
@page
@model IdentityApp.Pages.Identity.IndexModel
@{
    ViewBag.Workflow = "Overview";
}

<table class="table table-sm table-striped table-bordered">
    <tbody>
    <tr><th>Email</th><td>@Model.Email</td></tr>
    <tr><th>Phone</th><td>@Model.Phone</td></tr>
    </tbody>
</table>
```

```cs
public class IndexModel : UserPageModel
{
    public string Email { get; set; } = default!;
    public string Phone { get; set; } = default!;
}
```

And the page model class defines the properties required by its view – added the code to retrieve the data. Next add the RP named `Dashboard.cshtml`to the `Pages/Identity/Admin`folder with the content like:

```cs
public class DashboardModel : AdminPageModel
{
    public int UserCount { get; set; } = 0;
    public int UserUnconfirmed { get; set; } = 0;
    public int UserLockedout { get; set; } = 0;
    public int UsersTwoFactor { get; set; } = 0;
}
```

The final change is to just update the link that allows users to manage their accounts like:

```html
<table class="table table-sm table-striped table-bordered">
    <tbody>
    <tr><th>User in Store:</th><td>@Model.UserCount</td></tr>
    <tr><th>Unconfirmed accounts:</th><td>@Model.UserUnconfirmed</td></tr>
    <tr><th>Locked out users:</th><td>@Model.UserLockedout</td></tr>
    <tr>
        <th>Users with two-factor enabled:</th>
        <td>@Model.UsersTwoFactor</td>
    </tr>
    </tbody>
</table>

```

## Using the Identity API

Two of the most important parts of the Identity API are the *user manager and the user class*– the user manager provides access to the data and Identity manges, and the user class describes the data that Identity manages for a single user account. The best approach is to jump in and write some code that uses the API – going to start with a Rps that will create instances of the *user class and user manager to store them in the dbs*.

In the `Dashboard.cshtml.cs`file just add:

```cs
public class DashboardModel : AdminPageModel
{
    //...

    public UserManager<IdentityUser> UserManager { get; set; }
    public DashboardModel(UserManager<IdentityUser> userMgr)
    {
        UserManager = userMgr;
    }

    private readonly string[] emails =
    {
        "alice@example.com", "bob@example.com", "charlie@example.com"
    };

    public async Task<IActionResult> OnPostAsync()
    {
        foreach(string email in emails)
        {
            IdentityUser userObject = new IdentityUser
            {
                UserName = email,
                Email = email,
                EmailConfirmed = true,
            };
            await UserManager.CreateAsync(userObject);
        }
        return RedirectToPage();
    }
}
```

There are only a few statements, but a lot to understand cuz this is the first that deals directly with the Identity API. Start with the user class. Identity is agnostic about the user class. Can create a custom user class, which… there is just the default class named `IdentityUser`which is the class – Is declared when configuring Identity in the `Program.cs`:

```ts
builder.Services.AddDefaultIdentity<IdentityUser>(opts=>...)
```

The type of the user class is specified using the generic type arg to the `AddDefaultIdentity`-- The user class defines a set of props that describe the user account and provide the data values the Identity needs to implements its features.

```cs
Identity userObject = new IdentityUser {
    UserName=...,
    Email=...,
    EmailConfirmed=...
};
```

And the second KEY class is the user manager, named `UserManager<T>` – the generic type arg `T`is jsut used to specify the user class – since the example uses the just built-in user clas, so `UserManager<IdentityUser>`used.

And, the user manager is configured as a service through the CORE dependency injection feature – to access the user manager in the RP model class, added a ctor with a `UserManager<IdentityUser>`parameter.

When the page model class is instantiated, the ctor receives a `UserManger<IdentityUser>`object, which assigned to a prop named `UserManager`so that it can be used by the page handler methods.

And the user manager class has a lot of methods, but there ae 3 that are used to manage the stored data. These methods are all async – as are many of the methods – 

- `CreateAsync(user)`-- stores a new instance of the user class.
- `UpdateAsync(user)`– methods updates a stored instance of the user class.
- `DeleteAsync(user)`– This removes a stored instance of the user class.

And to store the test `IdentityUser`objects, call the `CreateAsync`method like:

`await UserManger.CreateAsync(userObject);`

The `CreateAsync`just stores the `IdentityUser`objects.

# Working with files recover

Blaozr just as with other HTML input elements, Blazor also provides a component of the box for uploading files – `InputFile`-- Uploading files isn’t simple – going to change our form making two calls to the API - the first is current call, which just uploads the trail details as JSON – the second is going to upload the image – if present – as multipart form data. Happens cuz there is currently no-built support in core for mixing JSON and multipart requests. The overhead of the additional request isn’t much.

### Configuring the `InputFile`component –

```html
<FormFieldSet>
	<InputFile OnChange="LoadTrailImage" class="form-control-file"
               id="trailImage" accept=".png,.jpg,.jpeg" />
</FormFieldSet>
```

The most important point to notice that that the `InputFile`component doesn’t use the `bind`directive as the other input components do – instead must handle the `OnChange`event it exposes. Just as with file uploading in regular HTML forms, Can provide a list of file types we want to use to be able to upload using the `accept`. Under the hood, the `InputFile`component renders an HTML input element with a type of file.

Now that have the `InputFile`, add :

```cs
private IBrowserFile? _trailImage;
private void LoadTrailImage(InputFileChangeEventArgs e) {
    _trailImage=e.File;
}
```

This method uses the `InputFileChangeEventArgs`to assign the selected file to the `trailImage`field, so can access it later, when the form is submitted.

### Uploading files when the form submitted

Currently, when submit the form the data entered is packaged into an `AddTrailRequeste()`and dispatched to the API via `MediatR`. going to extend htis logic to check if an image has been selected and make an additional call to upload it.

```cs
private async Task SubmitForm() {
    var response = await Mediatr.Send(...);
    //...
    
    if(_trailImage is null) {
        _submitSuccessful= true;
        ResetForm();
        return;
    }
    await ProcessImage(response.TrailId);
}

private void ResetForm(){
    _trail = new TrailDto();
    _editContext= new EditContext(_trail);
    _editContext.SetFieldCssClassProvider(...);
    _trailImage=null;
}
```

Fore, if an image just hasn’t been selected, jsut reset the form like originally. The logic for resetting the form is now in its own method – this is cuz it will be called in multiple places and refactoring it into its own method.

And, if a trail has been selected, then call the `ProcessImage`-- takes the ID returned from the `AddTrailRequest()`.

```cs
private async Task ProcessImage(int trailId) {
    var imageUploadResponse = await Mediator
        .Send(new UploadTrailImageRequest(trailId, _trailImage));
    if (string.IsNullOrWhiteSpace(imageUploadresponse.ImgaeName)) {
        _errorMessage="...";
        return;
    }
    _submitSuccessful= true;
    ResetForm();
}
```

The trail image is uploaded via the `UploadTrailImageRequest()`-- takes the trail ID and the images as an ` IBrowserFile`. – Dispatched via MediatR.

### Building the Request and Handler

That is all change in the form just, now need to add the `UploadTrailImageRequest()`to the `Shared`proj – And the following listing shows the code for the `UploadTrailImageRequest()`class – which just the `record`too.

```cs
public record UploadTrailImageRequest(int TrailId, IBrowserFile File):
	IRequest<UploadTrailImageRequest.Response> {
        public const string RouteTempalte="/api/trails/{trailId}/images";
        public record Response(string ImageName);
    }
```

- The record is defined with two properties for trailid and the file to be uploaded.

Will notice as add more requests that their formats are largely uniform The properties that make up the request are defined using *positional construction*.

In this, case, defining the `TrailId`and the `File`using positional construction – the properties that make up the request are defiend – The record also define a route template.

Now that have the request in place, can just add a *handler* for it back in the `Client`project. like:

```cs
public class UploadTrailImageHandler:
	IRequestHandler<UploadTrailImageRequest, UploadTrailImageRequest.Response>
{
    private readonly HttpClient _httpClient;
    //ctor...

    public async Task<UploadTrailImageRequest.Response> Handle(
        UploadTrailImageRequest request, CancellationToken token
    ){
        // the IBrowserFile includes a helper method allows the file be read as a stream
        var fileContent= request.File
            .OpenReadStream(request.File.Size, token);
        
        // created, and the file is added
        using var content = new MultipartFormDataContent();
        content.Add(new StreamContent(fileContent), "image", request.File.Name);
        
        var response = await _httpClient
            .PostAsync(Upload..RouteTemplate.Replace(...)), 
        	content, token);
        if(response.IsSuccessStatusCode){
            var fileName= await ...;
            return new UploadTrailImageRequest.Response(fileName);
        }else {
            return new UploadTrailImageRequest.Respones("");
        }
    }
}
```

Cuz of used the `PostAsync()`, just adding the API Endpoint.

```cs
[HttpPost(UploadTrailImageRequest.RouteTempalte)]
public override async Task<ActionResult> HandleAsync([FromRoute]
                                                    int trailId,
                                                    CancellationToken token = default)
{
    var trail = await _dbs.Trails
        .SingleOrDefaultAsync(x=> x.Id==trailId, token);
    if (trail is null) {
        return BadRequest("...");
    }
    
    // Using object like:
    var file = Request.Form.Files[0];
    if (file.Length==0 ){
        return BadRequest("...");
    }
    var filename = $"{Guid.NewGuid()}.jpg";
    //...
    
    await image.SaveAsJpegAsnc(...);
    trail.Image=filename;
    await _database.SaveChangesAsync(token);
    return Ok(trail.Image);
}
```

Start by attempting to load the trail from the dbs that matches the supplied `trailId`.If that fails, return a bad request. Then load the submitted image using the `Request`– availabe in every endpoint and allows access to all the info regarding the current HTTP. So, if no image found, return a bad request.

After, known have a valid trail and valid image. Next task is just to create a safe filename, and save the file name in the dbs.

# Advnaced Async

### The Spec

Fore, build a search box that *automatically* searches for the user without them needing to press enter – Need to avoid overloading the backend servers – means the code need sto prevent unnecessary requests.

### Preventing Race conditions with `switchMap`

A typeahead race condition bug typically manifests itself like – 

1. user type `a`
2. get/render response for `a`
3. user types `ab`
4. user types abc
5. get/render response for abc
6. get/render response fro ab

Whatever, users now have the wrong results in the front of them. For the observable solution like:

```ts
fromEvent(searchBar, 'keyup')
.pipe(
	pluck('target', 'value'),
    switchMap(query=> ajax(endpoint+searchVal))
).subscribe(...)
```

For the `switchMap`, works the same way as `mergeMap`-- for every item, it runs the inner observable, waiting for it to complete before sending the results downstream. – If a new value arrives *before* the inner – `switchMap`unsubsribes from the observable requst – and fires off a new one.

for the example, `abc`would be passed to `switchMap`before the query for `ab`finished – `ab`'s result would be thrown away with a care. One way to think about that is that `switchMap`switches to the new request.

types ab => sM sees, makes a a note => abc => sees, makes a not, **replace** the ab with abc
=> handle abc => remove abc notes => get response for ab => sees for ab, but discards it cuz replaced notes.

### Debouncing Events

There comes a time when several events fire in a row – fore, don’t want to do sth on every event. For the typeahead, only want to make requests when the user stops typing – A function set up in this way is known as *debounced* function. Pass a func into `debounce`then returns another func that wrap the original func. like:

```ts
let logPause = ()=> console.log("...");
let logPausedDebounced= debounce(logPause);
input.addEventListener('keydown', logPauseDeboundced);
```

### Throttoling Events

Sometimes a debounce is more complicaed – the `throttle`opeator acts as a time-based filter – after it allows a value through, it won’t allow a new value – until a preset amount of time passed. All other values are just thrown away. This can be useful when U connect to a noisy websocket that sends a lot more data than you need. FORE, migth be building a dashboard to keep the ops folks informed all of their systems, and the monitoring backend sends updates on CPU usage several dozen times a second, fore – DOM updates are slow, and the level of granularity just isn’t helpful fore – can:

```ts
cpuStatusWebsocket$ 
.pipe(throttle(500))
.subscribe(...)
```

### Adding Debounce to the Typeahead

One of the way to deterine the quality of code is to see how resilent :

```ts
fromEvent(searchBar, 'keyup')
.pipe(
	pluck('target', 'value')
    debounceTime(333),
    switchMap(query=>ajax(endpoint+searchValue))
)
```

## Navigating in code

Using the `routerLink`attribute makes it easy to set up navigation in templates - but applications will often need to initiate nav on behalf of the user within a component or directive.

To give access to the routing system to building blocks such as directives and compoentns, Ng provides the `Router`class – which is available as a service through DI and whose most useful methods are:

`navigated, url, isActive, events, navigateByUrl, navigate`

So, the `navigate`and `navigateByUrl`methods make it easy to perform the navigation inside a building block fore, a component.

```ts
constructor(private model: Model, activeRoute: ActivateRoute,
           private router: Router){//...
}

submitForm(){
    //...
    this.router.navigateByUrl("/");
}
```

So, this component receives the `Router`obj as a ctor arg and uses it in the `submitForm`method to navigate back to the home url.

### Receiving Navigation Events

In many apps, there will be components or idrectives that are not directly involvled in the app’s navigation, but that still need to know when nav occurs – The example app contains an example in the message component, which displays notifications and errors to the user.

The `events`of `Router`returns an `Observable<Event>`emits a sequence of `Event`objects describing changes from the routing system. 

`NavigationStart, RoutesRecognized, NavigationEnd, NavigationError, NavigationCancel`
`NavigationError`

Note that all the classes defined an `id`prop returns a number that is incremented for each navigation. fore:

```ts
constructor(messageService: MessageService, router: Router) {
    messageService.messages.subscribe(msg=> this.lastMessage=msg);
    router.events.subscribe(e=> {
        if(e instanceof NavigationEnd || e instanceof NavigationCancel) {
            this.lastMessage=undefined;
        }
    })
}
```

## Preparing the Example Project

For this, Adding methods in the repository.model.ts file like:

```ts
getNextProductId(id?: number): Observable<number> {
    let subject = new ReplaySubject<number>(1);
    this.replaySubject.subscribe(products => {
        let nextId = 0;
        let index = products.findIndex(p => this.locator(p, id));
        if (index > -1) {
            nextId = products[products.length > index + 1
                ? index + 1 : 0].id ?? 0;
        } else {
            nextId = id || 0;
        }
        subject.next(nextId);
        subject.complete();
    });
    return subject;
}

getPreviousProductId(id?: number): Observable<number> {
    let subject = new ReplaySubject<number>(1);
    this.replaySubject.subscribe(products => {
        let nextId = 0;
        let index = products.findIndex(p => this.locator(p, id));
        if (index > -1) {
            nextId = products[index > 0
                ? index - 1 : products.length - 1].id ?? 0;
        } else {
            nextId = id || 0;
        }
        subject.next(nextId);
        subject.complete();
    });
    return subject;
}
```

These new methods accept an ID value, locate the corresponding product, and then return observables that produce the IDs of the next and previous objects in the array that the repository uses to collect the data model objects.

### Adding Components to the Project

And need to add some components to the application to demonstrate some of the features – these components are simple cuz focusing on routing system. `productCount.component.ts`like:

```ts
@Component({
    selector: "paProductCount",
    template: `
        <div class="bg-info text-white p-2">
            There are {{count}} products
        </div>`
})
export class ProductCountComponent implements OnInit, DoCheck {
    private differ?: KeyValueDiffer<any, any>;
    count: number = 0;

    constructor(private model: Model,
                private keyValueDiffers: KeyValueDiffers,
                private changeDetector: ChangeDetectorRef) {
    }

    ngOnInit() {
        this.differ = this.keyValueDiffers
            .find(this.model.getProducts())
            .create();
    }

    ngDoCheck() {
        if (this.differ?.diff(this.model.getProducts()) != null) {
            this.updateCount();
        }
    }

    private updateCount() {
        this.count = this.model.getProducts().length;
    }
}
```

DoCheck interface – A lifecycle hook that invokes a custom change-detection function for a directive. In addition to the check performed by the default change-detector.

If the model reference doesn’t change, but some property of the `Input`model changes, may implement the `ngDoCheck`lifecycle hok to construct change detection logic manually.

Fore, have an array of `Employee`class and want to detect changes in the array whenever an item is added or removed.

So, for our example, this componetn uses a differ to track changes in the data model and count the number of unique categories – which is displayed using a simple inline template. Then just same as this code create `categoryCount.component.ts`file in the `core`folder like:

```ts
@Component({
    selector: "paCategoryCount",
    template: `
        <div class="bg-primary p-2 text-white">
            There are {{count}} categories
        </div>`
})
export class CategoryCountComponent {
    private differ?: KeyValueDiffer<any, any>;
    count: number = 0;

    constructor(private model: Model,
                private keyValueDiffers: KeyValueDiffers,
                private changeDetector: ChangeDetectorRef) {
    }

    ngOnInit() {
        this.differ = this.keyValueDiffers
            .find(this.model.getProducts()).create();
    }

    ngDoCheck() {
        if (this.differ?.diff(this.model.getProducts()) != null) {
            this.count = this.model.getProducts()
                .map(p => p.category)
                .filter((category, index, array) =>
                    array.indexOf(category) == index).length;
        }
    }
}
```

This also uses a differ to track changes in the data model and count the number of **unique** categories. Then just added a file called `notFound.component.ts`in the core and used it to define the component like:

```ts
@Component({
    selector: "paNotFound",
    template: `<h3 class="bg-danger text-white p-2">
        Sorry, something went wrong
    </h3>
    <button class="btn btn-primary" routerLink="/">Start over</button>`
})
export class NotFoundComponent {
}
```

## Using wildcards and Redirections

The routing configuration in app can quickly become complex and contain redundancies and oddities to carter to structure of app. Angular provides two useful tools that can help just simplify routes and also deal with problems when they arise – 

### using Wildcards in Routes

The ng routing system supports a sepcial path, denoted by `**`-- that allows routes to match just **ANY** URL. The basic use of the wildcard path is to deal with navigation that would otherwise create a routing error. Like in the `table.component.html`file:

```html
<button class="btn btn-danger m-1" routerLink="/does/not/exist">
    Generate routing error
</button>
```

Clicking the button will ask the app to navigate to the URL `/does/not/exist`, for which there is no route configured. For this, isn’t a useful way to deal with an unknown route cuz the user won’t know waht routes are and may not realize that the app was trying to navigate to the problem URL. So a better approach is to use the wildcard route to handle navigation for URLs that have not been defined and select a component will present more useful message to the user like:

`{path: "**", component: NotFoundComponent}`

### Using redirections in Routes

Routes do not have to select components – can also be used as aliases that redirect to the browser to a different URL. And the redirections are defined using the `redirectTo`prop in a route like:

```ts
{path: "does", redirectTo: "/form/create", pathMatch: "prefix"},
{path: "table", component: TableComponent},
{path: "", redirectTo: "/table", pathMatch: "full"},
```

So, the `redirectTo`prop is used to specify the URL that the browser will be redirect to.

- `prefix`-- configures the route so that it matches URLs that starts with the specified path, ignores any subsequent
- `full`– just matches only the URL specfied by the `path`prop.

## Packaging Applications from source code into Docker Images

Commands execute during the build, and any filesystem changes from the command are saved in the image layer. That amkes Dockerfiles about the most flexible packaging format there is – you can expand zip files… run installers, and do pretty much anything else.
