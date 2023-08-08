## Object References, Mutability and recycling

Presenting a metaphor for variables in Py, variables are labels, not boxes, if referecne variables are old news to you, the analogy may still be handy if you need to exlain aliasing issues to others.

### Variables are not boxes

```python
class Gizmo:
    def __init__(self) -> None:
        print(f'gizmo id : {id(self)}')

x= Gizmo()
y= Gizmo()*10
```

### Identity, Equality, and Aliases

```python
chars = {'naem': 'chales', 'born':1934}
lew = chars
lew is chars # True
# ids are same
```

### Choosing between == and `is`

The `==`operator compares the values of objects, while `is`compares identities. `==`just appears more frequently -- if you are coming a variable to a singleton, then it just makes sense to use `is`-- the most common case is checking whether a variable is bound to `None`. This is the recommanded way to do it like:

`x is None`; `x is not None`

### Deep and Shallow Copies of Arbitrary Objects

Working with shallow copies is not always a problem -- sometimes you just need to make deep copies -- The `copy`module provides the `deepcopy`and `copy`functions that return deep and shallow copies of arbitrary objects -- 

```py
import copy
bus1 = Bus(['Alice', 'Bill', 'Claire', 'David'])
bus2 = copy.copy(bus1)
bus3 = copy.deepcopy(bus1)
id(bus1), id(bus2), id(bus3)
```

```py
class Bus:
    def __init__(self, passengers=None):
        if passengers is None:
            self.passengers = []
        else:
            self.passengers = list(passengers)

    def pick(self, name):
        self.passengers.append(name)

    def drop(self, name):
        self.passengers.remove(name)
```

1. Using the `copy`and `deepcopy`, we just create 3 distinct Bus instances.
2. After `bus1`drops `Bill`, he is also missing from bus2
3. Inspection of passengers attributes shows that `bus1`and 2 share the same list object, cuz `bus2`is a just share the ame list object, buz `bus2`is shallow copy of `bus1`.
4. `bus3`is just a deep copy of `bus1`, so its `passengers`attribute refers to another list.

Note that making deep copies is not simple matter in the general case, objects may have cyclic references that would cause a naive algorithm to enter an infinite loop -- the `deepcopy`function remembers the objects already copied to handle cyclic references gracefully.

### Function Parameters as References

The only mode of paramter passing in Py is called by sharing. The result of this scheme is that a function may change any mutable object passed as a parameter, but it cannot change the identity of those objects -- shows a simple function using += on one of its paramters.

### Mutable types as Parameter Defaults -- Bad Idea

Optional parameters with default values are a great featur of Py function definitions --  just:

```py
class HauntedBus:
    def __init__(self, passengers=[]):
        self.passengers = passengers

    def pick(self, name):
        self.passengers.append(name)

    def drop(self, name):
        self.passengers.remove(name)
```

1. When the `passengers`arg is not passed, this paramter is bound to the default list object, which is initially empty

The problem is that each default value is evaluted when the function is defined -- usually when the module is loaded, and the default values become attributes of a function object.

### Defensive Programming with Mutable Parameters

When are coding a function that just receives a mutable parameter, you should carefully consider whether the caller expects the argument passed to be changed.

Fore, if function receives a `dict`and needs to modify it while processing it, should this side effect be visible outside of the function of the coder of the function and that of the caller. So just like:

```py
class TwilighBus:
    def __init__(self, passengers=None):
        if passengers is None:
            self.passengers=[]
        else:
            self.passengers=passengers
            
    def pick(self, name):
        self.passengers.append(name)
    
    #...
```

For this, here are careful to crate a new emtpy list when `passengers`is `None`. This assignment makes `self.passengers`an alias for `passengers`, whcih is itself an alias for the actual argument passed to `__init__`. When the methods `.remove()`and `.append()`are used with `self.passengers`, we are actually mutating the original list recived as an argument to the ctor.

And the problem here is that the bus is just aliasing the list that is passed to the ctor. Instead should keep its won passenger list -- fix is simple -- `__init__`-- when the passengers is provided, `self.passengers`should be initialized with a copy of it.

```py
def __init__(self, passengers=None):
    if passengers is None:
        self.passengers=[]
```

### del and Garbage Collection

The first strange fact about the `del`-- not a funciton just a statement -- write `del x`-- `del`just deletes references -- not objects -- py's garbage collector may discard an object from the memory as an indirect result of `del`, if the deleted variables was the last reference to the object. Rebinding a variable may also czuse the number of references to an object to reach zero -- causing its destruction.

In CPtyhon, the primary algorithm. As soon as that `refcount`reches zero, the object is immedately destroyed. CPython calls the `__del__`method on the object and then frees the memory allocated to the object.

## Functions as First-Class Objects

- Created at runtime
- Assigned to a variable or element in a DS
- Passed as an argument to a function
- Returned as the result of a function

Integers, strings, and dictionaries are other examples of first-class objects in Py -- nothing fancy here. Having functions as first-class objects is essential feature of function languages.

```py
def fact(n):
    '''return n!'''
    return 1 if n<2 else n*fact(n-1)
fact.__doc__
type(fact)
```

### Higher-order Functions

A function that takes a function as an argument or returns a func as the result is higher-order function. In Py, fore, any one-argument function can be used as a key - -fore, to create a rhyme dictionary it might be useful to sort each word spelled backward.

### Modern Replacements for `map, filter, reduce`

Function languages commonly offer the `map, filter`and `reduce`-- but since the listcomp -- not useful for these.

```py
list(map(fact, range(6)))
[fact(n) for n in range(6)]
list(map(fact, filter(lambda n: n%2, range(6))))
[fact(n) for n in range(6) if n %2]
```

Note that in py 3, `map`and `filter`just return generators. The `reduce`ws demoted from the built-in 2 to the `functools`module in 3. like:

```py
from functools import reduce
from operator import add
reduce(add, range(100))
```

### Anonymous Functions

```py
sorted(fruits, key=labmda word: word[::-1])
```

### The 9 flavors of Callable Objects

The `call`operator `()`may be applied to other objects besides functions -- to determine whether an object is callable, use the `callable()`built-in function. user-defined functions, built-in functions, built-in methods, methods, classes, class instances, generator functions, native coroutine functions (`async def`), async generator function -- just the `async def`that have a `yield`in their body.

### User-defined Callable Types

Not only are python functions real objects, but arbitrary Py objects may also be made to behave like functions, implementing a `__call__`instance method is all it takes. like:

```py
class BingoCage:
    def __init__(self, items):
        self._items = list(items)
        random.shuffle(self._items)

    def pick(self):
        try:
            return self._items.pop()
        except IndexError:
            raise LookupError('pick from empty')

    def __call__(self, *args, **kwargs):
        return self.pick()
```

For this, Here is a simple demo -- note how a `bingo`instance can be invoked as a func, and the `callable()`built-in recognizes it as a callable object like:

```py
bingo = BingoCage(range(3))
bingo()
```

So a class implementing `__call__`is an easy way to create function-like objects that have some internal state that must be kept acorss invocations -- like the remining items.

### From Positional to Keyword-only Parameters

One of the best features of Py functions is the extremely flexible paramter handling mechanism -- Closely related are the use of `*`and `**`to unpack iterables and mappings into separate arguments when call a function.

```py
def tag(name, *content, class_=None, **attrs):
    '''generate one or more HTML tags'''
    if class_ is not None:
        attrs['class'] = class_
    attr_pairs = (f' {attr}={value}' for attr, value in
                  sorted(attrs.items()))
    attr_str = ''.join(attr_pairs)
    if content:
        elements = (f'<{name}{attr_str}>{c}</{name}>'
                    for c in content)
        return '\n'.join(elements)
    else:
        return f'<{name}{attr_str} />'
```

```py
my_tag = dict(name='img', title='sunset', src='sun.jpg', class_='framed')
tag(**my_tag)
```

- the `class_`parameter can only be passed as a keyword argument
- The first positional argument can also be passed as a keyword.

Keyword-only arguments are a feature of py 3. The `class_`parameter can only be given as a keyword argument -- will never capture unnamed positional arguments. To specify keyword-only arguments when defiing a function, name them just after the argument prefixed with `*`.

And prefixing the `my_tag`dict with `**`passes all its items as separate arguments, which are then bound to the named parameters, with the remaining caught by `**attrs`.

### Positional-Only Parameters

Since 3.8, user-defined function signatures may specify positional-only parameters. This feature always existed for built-in functions, such as `divmod(a,b)`like -- 

```py
def divmod(a, b, /):
    return (a//b, a%b)
```

need to note that all args to the left of the `/`are positioned-only, after the `/`, may specify other argumetns, which works as usual. FORE, consider the `tag`if want the `name`parameter to be positioned, can add `/`after it in the function signature like this -- 

`def tag(name, /, *content...)

### Packages for Functional Programming

Often in the functional programming -- it is just convenient to use an arithmetic operator as a function -- FORE, suppose you want to multiply a sequence of numbers to calculate factorials without using recursion -- To perform summation, can use... Fore `itemgetter`and `attrgetter`are fact. If you pass multiple index arguments to `itemgetter`, the function it builds will return tuples with the extracted values like:

```py
cc_name= itemgetter(1,0)
for city in metro_data:
    print(cc_name(city))
```

### Freeing with `functools.partial`

And the `functools`module provdies several higher-order functions -- `reduce`-- another is `partial`-like:

```py
from operator import mul
from functools import partial
triple= partial(mul, 3)
triple(7)
list(map(triple, range(1,10)))
```

## Type hints in Functions

Type hints are the bigest change in the history of Py since -- 2.2 -- released in 2001 -- type hints do not benefit all Py users equally -- that is why they should always be optional.

### Using `None`as Default

```py
def test_irregular() -> None:
    got=...
```

In other contexts `None`is a better default. If the optional parameter expects a mutable type, then `None`is the only sensible default, -- to have `None`as the default for the `plural`parameter, there is what the signature would look like:

```py
from typing import Optional
def show_count(count: int, singular: str, plural: Optional[str]=None) -> str:
```

For this:

- `Optional[str]`means that `plural`may be a `str`or `None`.
- U must explicitly provide the default value = `None`.

Note, if don't assign a default value to the `plural`, then the py runtime will treat it as a required parameter.

### Types are Defined by Supported Operations

In practice, it's more useful consider that the set of supported operations as the defining characteristic of a type. FORE:

```py
def double(x):
    return x*2
```

Here, the `x`parameter type may be numeric, also can be a seq -- an ND array.. Howver, consider this annotated `double`, like:

```py
from collections import abc
def double(x: abc.Sequence):
    return x*2
```

A type checker will just reject that code -- if you tell -- `abc.Sequence`-- it will flag `x*2`as an eror cuz does not implement or inherit the `__mul__`method.

### Types usable in Annotations

Pretty type can be used in type hints -- but there are restrictions and recommendations -- in addition, the `typing`module introduced special constructs with just semantics that are sometimes surprising.

- `typing.Any`
- Simple types and classes
- `typing.Optional`and `typing.Union`
- Generic collections, including tuples and mappings
- ABCs
- Generic iterbles
- Parameterized generics and `TypeVar`
- `typing.Protocols`
- `typing.Callable`
- `typing.NoReturn`-- a good way to end

```py
def double(x: Any)-> Any:
    return x*2 # ok

def double(x: object)-> object:
    return x*2 # error
```

The problem is that `object`does not support the `__mul__`operation, this is what reports. The `object`class just implements fewer operations then `abc.Sequence`-- which just implements fewer operations than `abc.MutableSequecne`.

But, `Any`is just a magic type that sits at the top and the bottom of the type hierarchy -- `Any`just accepts values of every type -- and the most specialized type, supporting every possible operation. Of couse -- no type can support just every possible operation, so using `Any`just prevents the type checker from fulfilling its core mission: detecting potentially illegal operations before your program crashes.

### Subtype -of vs. consistent-with

`Optional`solves the problem of having `None`as a default, as in this example from that section.

```py
from typing import Optional
def show_count(count: int, singular: str, plural: Optional[str]=Noen)-> str:
```

Namely, the construct of `Optional[str]`actually a shortcut for `Union[str, None]`, which means type `plural`may be `str` or `None`. Can use:

```py
def ord(c: Union[str, bytes])-> int:...
```

Fore, there is an example of a function that takes a `str`, but may return a `str`or a `float`.like:

```py
from typing import Union
def parse_token(token:str) -> Union[str, float]:
    try:
        return float(token)
    except ValueError:
        return token
```

Note, `Union[]`requires at least two types, nested types have the same effect as a flattened `Union`. 

## Container

A Docker container is the same idea as a physical container -- think of it like a box with an application in it. Inside the box, the appliation seems to have a computer all to itself.

Those things are all virtual resources -- the hostname, IP, and filesystem are created by Docker -- logical objects that are just managed by Docker, and they are all joined together to create an environment where an app can run. The application inside the box can’t see anything outside the box, but the box is runing on a computer -- and that computer can also be running lots of other boxes.

The apps in those boxes have their own separate environments -- but they all share the CPU and memory of the computer. Fixes the *isolation* and *density* -- means running as many apps on your computers as possible.

Containers give you both -- Each container shares the operating system of the computer running the container, and that makes them extremely lightweight -- Containers start quickly and run lean, can run many more containers than VMs on the same hardware -- typically 5 to 10 times as many.

### Connecting to a container like a remote computer

Can work with containers in other ways too -- see how you can run a container and connect to a terminal insde the container, just s if you were connecting to a remote machine -- use the `docker container run`command, pass some additional flags to run an interactive container with a connected terminal session.

```sh
docker container run --interactive --tty diamol/base
```

The `--interactive`tells Docker want to set up a connection to the container, and the `--tty`means want to connect to a terminal session inside the container. The output will show `Docker`just pulling the image, and then you will be left with a command prompt.

U will need some familarity with command. remember that the container is sharing your computer’s operating system, which is why U see a Linux shell if you are running Linux and a Windows command line if using Windows.

```sh
docker container ls
```

The output shows you info about each container -- including the image it’s using, the container ID, and command Docker ran inside the container when it started.

## Hosting a website in a container

The first couple ran a task that printed some text and then exited -- the next used interactive flags and connected us to a termnial session in a container, which stayed running until exited the session -- `docker container ls`show you have no containers -- only shows running containers.

```sh
docker container ls --all
```

The containers have the status `Exited`-- there are a couple of key things to understand here -- Containers are running only while the app inside the container is running. Exited containers don’t use any CPU time or memroy. Containers just don’t disppear when they exit -- Containers in the exited state still exist, which means that you can start them again.

So, actually the main use case for Docker -- running server applications like websites, batch processes and dbs:

```sh
docker container run --detach --publish 8088:80 diamol/ch02-hello-diamol-web
```

That image includes the Apache web server and a simple HTML page.

- `--detach`-- starts the container in the background and shows the container ID
- `--publish`-- publishes a prot from the container to the computer

The app in this container keeps running indefinitely - -so the container will keep running too, can laso use the `docker container`commands -- and `docker container stats`is another -- shows a live veiw of how much cpu, memory, network and disk container is using.

```sh
docker container stats ebe
```

When are done working with a container, can remove it with `docker container rm`and the container ID, using the `--force`flag -- to force remove if the container is still runnig like:

The `$()`syntax sends the output from one command into another command -- work jsut as well on the Linux and Mac

```sh
docker container rm --force $(docker container ls --all --quiet)
```

### Understanding How Docker runs Containers

This workflow makes it very easy to distribute software -- built all the sample container images and shared them, knowing you can run them in Docker and they will work the same for you as they do for .. 

- The *Docker engine* is just the mangement component of Docker -- It looks after the local cache, downloading images when you just need them, and reusing them if they are already downloaded. Also works with the OS to create containers, vitual networks, and all the other Docker resources. The Engine is a background process that is always runinng.
- The Docker Engine makes all the features available through the *docker API* -- which is jsut a std http-pased REST API.
- The *docker command-line interface* is a client of the Docker API. When run Docker commands, the CLI actually sends them to the Docker API, and the Docker Engine does the work.

## Enabling the built-in tag helpers

The built-in tag helpers are all defined in the `Microsoft.AspNetCore.Mvc.TagHelpers`namespace and are enabled by adding an `@addTagHelpers`directive to individual views or pages or, as in the case of the example project, to the view imports file.

### Transforming anchor elements

The `a`element is the basic tool for navigating around an application by sending `GET`to the app. The `AnchorTagHelper`class is just used to transform the `href`of `a`so target URLs generated using the routing system, which means that hard-coded URLs are not required and a change in the routing configuraiton will be just automatically reflected in the app's anchor elements.

- `asp-action`-- specifies the action method that the URL will target
- `asp-controller`-- specifies the controller that the URL will target
- `asp-page`
- `asp-page-handler`-- specifies which RPs handler function will process the request
- `asp-fragment`-- used to specify URL fragment
- `asp-route`-- specifis the name of the route that will be used to generate the URL
- `asp-route-*`-- whose name begins -- specify additional values for the  URL id segment to the routing system.

And the `AnchorTagHelper`just is simple and predictable and makes it easy to just generate URLs in `a`elements that use th app's routing configuration. like:

```html
<a asp-action="Index" asp-controller="Home"
   asp-route-id="@Model?.ProductId"
   class="btn btn-sm btn-info text-white">
    Select
</a>
```

So the `asp-action`and `asp-controller`attriutes specify the name of the action method and the controller that defines it -- values for segment variables are defined using `asp-route-[name]`attriutes.

### Using anchor elements for Razor Pages

The `asp-page`attribute is just used to specify a RPs as the target or an anchor element's `href`attribute, the path to the page is prefixed the `/`character like:

`<a class="btn btn-secondary" href="/lists/suppliers">Suppliers</a>`

So the tag helper generates URLs only in the anchor elements.

## Using Js and CSS tag helpers

Core provides tag helpers that are used to manage Js file and CSS stylesheets through the `script`and `link`element. And the `ImageTagHelper`class is used to provide cache busting for images throuhg the `src`attribute of `img`elements, allowing an app to take advantage of caching while ensuring that modifications to images are reflected immediately. And the `ImageTagHelper`just operates in `img`that define the `asp-append-version`attriute. Like:

### Using the Data cache

And, the `CacheTagHelper`class allows fragments of content to be cached to speed up rendering of views or pages. The content to be cached is denoted using the `cache`element. Like:

```html
<div class="m-2">
    <img src="/image/city.png" asp-append-version="true"
         class="m-2"/>
</div>

<div class="m-2">
    <h6 class="bg-primary text-white p-2">
        Uncached timestamp: @DateTime.Now.ToLongTimeString()
    </h6>
    <cache>
        <h6 class="bg-primary text-white m-2 p-2">
            Cached timestamp: @DateTime.Now.ToLongTimeString()
        </h6>
    </cache>
</div>
```

The `cache`element is used to denote a region of content that should be cached and has been applied to one of the elements that contains a timestamp.

### Setting the cache expiry

The `expries-*`attributs allow you to specify when cached content will expire. Expressed either as an absolute time or as a time relative to the current time, or to specify a duration during which the cached content isn't requested.

`<cache expires-after="@TimeSpan.FromSeconds(5)">`

`<.. expires-on= "@DateTime.Parse("2100-01-01")">`

### Using the hosting environment tag helper

The `EnvironmentTagHelper`class is just applied to the custom `environment`element and determines whether a region of content is included in the HTML sent to the browser-based on hosting environment -- which describe. like:

`<environment names="development">`

## Using the forms tag helpers

This just uses the project to prepare for this, in the project.

### Understanding the form handling pattern

Most HTML forms exist within a well-defined pattern -- first the browser sends an `HTTP GET`requeset, which results in an HTML response containing a form, making it possible for the user to provide the application with data. The user just clicks a button that submits the form data with an HTTP POST request, which allows the app to receive and process the user's data -- once the data has been processed, a response is sent that redirects the browsers to a URL that confirms the user's actions.

This is just known as the **POST/Recirect/Get** pattern and the redirect is important cuz it means that the user can click the reload without sending another POST.

Creating a controller to handle forms -- Just:

```cs
public class FormController : Controller
{
    private readonly DataContext context;
    public FormController(DataContext context)=> this.context = context;


    public async Task<IActionResult> Index(long id=1)
    {
        return View("Form", await context.Products.FindAsync(id)
                    ?? new() { Name = string.Empty });
    }

    [HttpPost]
    public IActionResult SubmitForm()
    {
        foreach (string key in Request.Form.Keys.Where(k => !k.StartsWith("_")))
        {
            TempData[key] = string.Join(", ",
                                        (string?)Request.Form[key]);
        }
        return RedirectToAction(nameof(Results));
    }

    public IActionResult Results()
    {
        return View();
    }
}
```

The `Index`selects a view named `Form`will render an HTML form to the user. When the user submits the form, it will be received by the `SubmitForm`action, which has been decorated with the `HttpPost`attribute so that can only receive `HTTP POST`requests -- processes the HTML form data available through the `HttpRequest.Form`prop so that can be stored usnig the temp data feature. note that temp data can be used to pass data from one request to another but can be used only to store simple data types. Each form data value is represented as a string value.

Then provides the controller with view -- 

```html
<form action="/controllers/form/submitform" method="post">
    <div class="mb-3">
        <label>Name</label>
        <input class="form-control" name="Name" value="@Model.Name"/>
    </div>
    <button type="submit" class="btn btn-primary mt-2">Submit</button>
</form>
```

Just add the `Results.cshtml`.

```html
<table class="table table-striped table-bordered table-sm">
    <thead>
    <tr class="bg-primary text-white text-center">
        <th colspan="2">Form Data</th>
    </tr>
    </thead>
    <tbody>
    @foreach (string key in TempData.Keys)
    {
        <tr>
            <th>@key</th>
            <td>@TempData[key]</td>
        </tr>
    }
    </tbody>
</table>
<a class="btn btn-primary" asp-action="Index">Return</a>
```

### Creating a RP to handle forms

The same pattern can be implemented using RPs -- one page is required to just render and process the form data, and a second page displays the results. Add a rp named `FormHandler`like:

```cs
public class FormHandlerModel : PageModel
{
    private readonly DataContext context;
    public FormHandlerModel(DataContext context)
    {
        this.context = context;
    }

    public Product? Product { get; set; }

    public async Task OnGetAsync(long id =1)
    {
        Product=await context.Products.FindAsync(id);
    }

    public IActionResult OnPost()
    {
        foreach(string key in Request.Form.Keys
                .Where(k=>!k.StartsWith("_")))
        {
            TempData[key]=string.Join(", ",
                                      (string?)Request.Form[key]);
        }
        return RedirectToPage("FormRequest");
    }
}
```

```html
@page "/pages/form/{id:long?}"
@model WebApp.Pages.FormHandlerModel

<div class="m-2">
    <h5 class="bg-primary text-white text-center p-2">Html Form</h5>
    <form action="/pages/form" method="post">
        <div class="mb-3">
            <label>Name</label>
            <input class="form-control" name="Name"
                   value="@Model.Product?.Name" />
        </div>
        <button type="submit" class="btn btn-primary mt-2">Submit</button>
    </form>
</div>

```

Then the page `FromResults`need to be decorated with the `IgnoreAntiForgeryToken`attribute -- 

```html
@page "/pages/results"

<div class="m-2">
    <table class="table table-striped table-bordered table-sm">
        <thead>
            <tr class="bg-primary text-white text-center">
                <th colspan="2">Form Data</th>
            </tr>
        </thead>
        <tbody>
            @foreach (string key in TempData.Keys)
            {
                <tr>
                    <th>@key</th>
                    <td>@TempData[key]</td>
                </tr>
            }
        </tbody>
    </table>
    <a class="btn btn-primary" asp-page="FormHandler">Return</a>
</div>
```

## Using tag helpers to improve HTML forms

The example in the previous section show the basic mechanism for dealing with HTML forms, but core includes tag helpers that transform form elements -- describe the tag helpers and demonstrate their use.

### Working with form elements

The `FormTagHelper`class is the built-in tag helper for `form`element and is used to manage the configuration of HTML form so that they target the right action or page handler without the need to hard-code URLs.

- `asp-controller`-- To specify the `controller`value to the routing system for the `action`attribute URL.
- `asp-action, asp-page, asp-page-handler`
- `asp-route-*`-- used to speify additional values for the action attribute URL so that the `asp-route-id`is used to provide a vlaue for the `id`segment to the routing system.
- `asp-route`-- used to specify *the name of the route* that will be used to generate the URL for the `action`attribute.
- `asp-antiforgery`-- controls whether anti-forgery info is added to the view.
- `asp-fragment`-- specifies a fragment for the generated URL.

So the `FormTagHelper`class just transforms `form`element so they target an action method or RP without need for hard-coded URLs -- The attributes supported by this tag helper work in the same way as for anchor elements. 

And, if a `form`element is defined without a `method`-- then the tag helper will add one with the `POST`value, meaning that the form will be submitted using just the `HTTP post`request.

## Generating responses with IResult

Seen the basics of minimal APIs, but - looked only at the happy path-- where you can handle the request successfully and return a response -- In this, look at how to handle bad requests and other errors by returning different status code. Fore, request a bad URL, resulting a 500 error -- so a better approach is to return a status indicating the problem -- such as 404, or 400.

There is just one other type of object you can return from an endpoint, -- `IResult`implementation -- the endpoint middleware handles each return type as follows:

- `void`or `Task`-- endpoint returns 200
- `string`or `Task<string>`-- returns 200 with the string serialized to the body as `text/plain`
- `IResult`-- Executes the `IResult.ExecuteAsync`method -- Depending on the implementation, this type can customize the response, returning any status code.
- `T `-- All other types, such as POCO classes, are seriazlied to JSON and returned in the body of 200.

Returning status code with `Results`and `TypedResults` -- For the Core exposes the simple `static`helper types `Results`and `TypedResult`in the namespace `AspNetCore.Http`, can use these to create a response with common status codes, optionally including a JSON body.

`Results`and `TypedResults`perform the same function -- for generating common status codes -- whereas the `TypedResults`return a concrete generic type, like `Ok<T>`. Ther eis no difference in terms of fucntionality, but the generic types are easier to use in unit tests and in OpenAPI documentation.

```cs
var _fruit = new ConcurrentDictionary<string, Fruit>();
app.MapGet("/fruit", () => _fruit);

app.MapGet("/fruit/{id}", (string id) =>
_fruit.TryGetValue(id, out var fruit) ? 
    TypedResults.Ok(fruit) : Results.NotFound());

app.MapPost("/fruit/{id}", (string id, Fruit fruit) =>
_fruit.TryAdd(id, fruit)
? TypedResults.Created($"/fruit/{id}", fruit) : Results.BadRequest(new
    { id = "A fruit with this id already exists" }));

app.MapPut("/fruit/{id}", (string id, Fruit fruit) =>
{
    _fruit[id] = fruit;
    return Results.NoContent();
});


app.MapDelete("/fruit/{id}", (string id) =>
{
    _fruit.TryRemove(id, out _);
    return Results.NoContent();
});

app.Run();
```

- 200 ok -- The std successful response
- 201 created -- Often returend when you successfully created an entity on the server. the `Created`result in listing also includes a `Location`header to describe the URL where the entity can be found, as well as the JSON entity itself in the body of the response.
- 204 no content -- Similar to 200 but without any content in the response body
- 400 -- indiceates that the requests was invalid in some way.
- 404 -- indicates the requested entity could not be found.

`Results`and `TypedResult`include methods for all the common status code results you could need, but if you don't want to use them for some reason - can alwyas set the status code youself directly on the `HttpResonse`.

```cs
app.MapGet("/teapot", resp=> {
    resp.StatusCode=418;
    resp.ContentType=MediaTypeNames.Text.Plain;
    return resp.WriteAsync("i teapot!");
});
```

### Returning Useful Errors with Problem details

In the `MapPost`endpoint, checked to see whether an entity with the given `id`already existed -- if it did, just returned a 400 repsonse with a description of the error. The problem with this approach is that the client -- typically, a mobile app or SPA. Problem details is a web specification for providing machine-readable errors for HTTP APIs.

Core includes two helper methods for generating Problem Details responses from minimal APIs. `Results.Problem()`and `Results.ValidationProblem()`-- both of thse return **Problem Details JSON**. The only difference is that `Problem`defaults to a 500 status code, whereas `validationProblem()`to a 400 status. Like:

```cs
app.MapGet("/fruit/{id}", (string id) =>
_fruit.TryGetValue(id, out var fruit) ? 
    TypedResults.Ok(fruit) : Results.Problem(statusCode:404));

app.MapPost("/fruit/{id}", (string id, Fruit fruit) =>
_fruit.TryAdd(id, fruit)
? TypedResults.Created($"/fruit/{id}", fruit) : Results.ValidationProblem(
    new Dictionary<string, string[]>
    {
        ["id"] = new[] { "A fruit with this id already exists" }
    }));
```

### Converting exceptions to Problem Details

Could add the middleware to your pipeline with an error-handling path of `/error`. like:

`app.UseExceptionHandler("/error")`

### Returning other data types

The methods on `Results`and `TypedResults`are convenient way of returning common responses, so it's only natural that they include helpers for other common scenarios, such as returning a file or binary data.

- `Results.File()`-- Pass the path of the file to return
- `Results.Byte()`-- returning binary data, can pass this a `byte[]`to return
- `Results.Stream()`-- can send data to the client async by using a `stream`.

### Running common code with endpoint filters

Will first learn how to use filters to extract common code that executes before or after an endpoint executes. Fore, adds an additional check to the `MapGet`endpoint to ensure that the provided `id`isn't empty and that it starts letter `f`.

```cs
app.MapGet("/fruit/{id}", (string id) =>
{
    if (string.IsNullOrEmpty(id) || !id.StartsWith('f'))
    {
        return Results.ValidationProblem(new Dictionary<string, string[]>
        {
            ["id"] = new[] { "Invalid format, id must start with f" }
        });
    }
    return _fruit.TryGetValue(id, out var fruit)
    ? TypedResults.Ok(fruit) : Results.Problem(statusCode: 404);
});
```

Even though this check is just basic, it starts to clutter our endpoint handler, making it harder to read what endpoin is doing. It's just common to perform various cross-cutting activities for every endpoint -- already mentioned -- other cross-cutting including logging.. Asp.Net core has just built-in support for some of these features.

Core includes a feature in minimal APIs for running these tangential concerns -- endpoint filters -- you can specify a filter for an endpoint by just calling `AddEndpointFilter`on the result of a call to `MapGet()`. Can even calls to `AddEndpointFilter()`multiple times -- which builds up an *endpoint filter pipeline*.

And, each endpoint filter has two parameters -- `context`and the `next`. -- `next`represents the filter pipeline.

## Read objects

Properties like this -- the first role is to tell EF core that the `Product`class is an *entity class* -- meaning that the `Product`objects will be stored in the dbs.

```cs
public Product GetProduct(long id)
{
    return context.Products.Find(id)!;
}
```

### Querying All objects

To retreive all the data objects stored in the dbs, can read the value of the context class's `Products`prop, which returns a `DbSet<Product>`-- implements the `IQueryable<T>`and `IEnumerable<T>`interfaces, which just means can enumerate the sequence of `Product`objects read from the dbs using `foreach`loop.

### Querying for sepcific objects

The `DbSet<T>`defined by context objects also allow more complex queries to be created using the LINQ to EF feature -- The class implements the `IQueryable<T>`interface, which is used to create queries that select objects from the dbs. This allows the use of LINQ to Query and process data. like: in the `Index.cshtml`file:

```cs
public IEnumerable<Product> GetFilteredProducts(string category=null,
                                                decimal? price=null)
{
    IQueryable<Product> data = context.Products;
    if(category != null)
    {
        data = data.Where(p=>p.Category == category); 
    }
    if (price != null)
    {
        data = data.Where((p)=>p.Price >= price);
    }
    return data;
}

// ...
public IActionResult Index(string category=null,
                           decimal? price=null)
{
    var products = repository.GetFilteredProducts(category, price);
    ViewBag.category = category;
    ViewBag.price = price!;
    return View(products);
}
```

```html
@using Microsoft.EntityFrameworkCore.Metadata.Internal
@model IEnumerable<Product>

@{ViewData["Title"]="Products";}

<div class="m-1 p-2">
    <form asp-action="Index" method="get" class="d-inline">
        <label class="m-1">Category:</label>
        <select name="category" class="form-control">
            <option value="">All</option>
            <option selected="@(ViewBag.category == "Watersports")">
                Watersports
            </option>
            <option selected="@(ViewBag.category=="Soccer")">Soccer</option>
            <option selected="@(ViewBag.category=="Chess")">Chess</option>
        </select>
        
        <label class="m-1">Min Price:</label>
        <input class="form-control" name="price" value="@ViewBag.price" />
        <button class="btn btn-primary m-1">Filter</button>
    </form>
</div>

<table class="table table-sm table-striped">
    <thead>
    <tr><th>Name</th><th>Category</th><th>Price</th></tr>
    </thead>
    <tbody>
    @foreach (var p in Model)
    {
        <tr>
            <td>@p.Name</td>
            <td>@p.Category</td>
            <td>$@p.Price.ToString("F2")</td>
            <td>
                <form asp-action="Delete" method="post">
                    <a asp-action="Edit" class="btn btn-sm btn-warning"
                       asp-route-id="@p.Id">Edit</a>
                    <input type="hidden" name="id" value="@p.Id" />
                    <button type="submit" class="btn btn-danger btn-sm">
                        Delete
                    </button>
                </form>
                
            </td>
        </tr>
    }
    </tbody>
</table>
<a asp-action="Create" class="btn btn-primary">Create new Product</a>
```

The implementation of this method just starts by reading the value of the context's `Product`prop and assigning it to an `IQueryable<Product>`variable. for some css:

```html
<form asp-action="Index" method="get" class="d-flex">
<label class="my-auto mx-1">Category: </label>
```

### Storing New Data

The next step is to add the ability to store new objects in the dbs, Edit the class to implement the `CreateProduct`method as shown as:

```cs
public void CreateProduct(Product newProduct)
{
    newProduct.Id = 0;
    context.Products.Add(newProduct);
    context.SaveChanges();
}
```

There are two source of `Product`objects in the example -- The MVC model binding process and the dbs context object. The model binding process just creates `Product`objects when it receives an HTTP post request, and the conteext object creates `Product`when it read from the dbs.

EF core is just responsible for the `Product`objects that are created by the dbs context object but has no visibiity of the ones created by the MVC model binder -- The `Add`, which is just called on the context's `DbSet<T>`prop, makes EF core aware of a `Product`object that has been created elsewhere in the app so that it can be written to the dbs.

And the `SaveChanges`method saves outstanding changes made to the `Product`that are being manged by EF core to the dbs. This includes any `Product`objects that have been passed to the `Add`method-- the effect of the code is to make EF core aware of a `Product`object and store in the dbs.

```html
@model Product

@{
    ViewData["Title"] = ViewBag.CreateMode ? "Create" : "Edit";
}

<form asp-action="@(ViewBag.CreateMode ? "Create" : "Edit")" method="post">
    <div class="mb-3">
        <label asp-for="Name"></label>
        <input asp-for="Name" class="form-control" />
    </div>
    
    <div class="mb-3">
        <label asp-for="Category"></label>
        <input asp-for="Category" class="form-control" />
    </div>
    
    <div class="mb-3">
        <label asp-for="Price"></label>
        <input asp-for="Price" class="form-control" />
    </div>
    
    <div class="text-center">
        <button class="btn btn-primary" type="submit">Save</button>
        <a asp-action="Index" class="btn btn-secondary">Cancel</a>
    </div>
</form>
```

### Understanding Key Assignment

Notice that the `CreateProduct()`just explicitly sets the value of the `Id`property of the `Product`object to zero -- the PK values for new objects are allocated by the dbs server when new rows in the table are created, and an exception will be thrown if the value for the `Id`property isn't zero. OVER-BINDING just.

```SQL
INSERT INTO Products(...)
values(...);
-- ....
Select Id from Products
where @@ROWCOUNT==1 AND Id= scope_identity();
```

So the `INSERT`tells the dbs server to just create a new row in the `Product`table and provides values for .. Then `SELECT`statement queries the value for the `Id`that has been used to create a new row. The value is returned to **update** the object, ensuring that the objects is consistent with its resprenation in the dbs.

## Functions

Functions are just the building blocks that you use to assemble a program out of discrete, reusable code routines -- Are also genuine *objects* in Js -- `Function`type -- the can be assigned to variables and passed around your code. Can be declared in an expression, without a function name, and optionally using a streamlined *arrow syntax*. Can even wrap one function in anoter to create a private package that includes the function's state (*closure*).

### Passing a Function as Argument to Another Function

Many functions in js accept or even require, a function that's passed as an arg -- some operations ask for the callback function that will be triggered when a task is complete -- there are several different approaches you can use when supplying a function as an arg -- 

- Provide a reference
- Declare the function in a *funciton expression*.
- Declare the function inline.

Start with a simple page that has this button -- 

`<button id="runTest">Run Test</button>`like:

```js
function buttonClicked() {
    setTimeout(showMessage, 2000);
}

function showMessage() {
    alert('U clicked the button 2 seconds ago');
}
```

### Arrow Functions

Want to use js' arrow to declare an inline function in the most compact way possible -- 

In recent years, js has shifted to emphasize functional programming patterns -- like:

`const squares = numbers.map(number=> number **2);`

Unlimited arguments -- 

```js
function sumRounds(...numbers){
    for (let number of numbers)...
}
```

### Uing Named Function Parameters

`someFunction(arg1, arg2, {optionalArg1: val1, optionalArg2: val2})`

In your func, can use *destructuring assignment* to quickly copy the values out of the object literal and into separte variables. like:

```js
function dateDiffInSecions (
newDate, oldDate, {discardTime, discardYears, precison}={}) {
    if(discardTime){
        //...
    }
    if(discardYears){
        //...
    }
}
difference = dateDiffInSecions(
newDate, oldDate, {discardYears:true, precision:2});
//...
function diff(newDate, oldDate, { discardTime, discardYear, precision } = {}) {
    if (discardTime)
        console.log(newDate);
    if (discardYear)
        console.log(oldDate);
    console.log(precision);
}

diff('123', 'abc', {discardTime:true, discardYear:false, precision:2})
```

### Creating a function that stores its state with closure

Want to create a function that can remember data, but without having to use global varaibles and without repeatedly sending the same data with each function call -- Wrap the function that needs to preserve its state in *another* function. The outer function resturns the inner like:

```js
function outer(){
    function inner(){...}
    return inner;
}
```

The outer 's parameters live as long as you have a reference to the inner. Can call the inner as many times as you want, and the data from the outer persists.

often, will find need a way to store data that's used across several function calls.

### Creating Generator

just like: `function* generateValue()` Generators allow to create functions that can be paused and **resumed**. Js manages their state automatically, which means that you don't need to write any code to preserve values in-between calls to `next()`. Cuz generators have a lazy-execution model. A good choice for time-consuming data creation or retrieval operations. Can be used spread operater.

### Partial Application

Your func is attempting to use keyword `this`, but it is not bound to the right object -- Use the `Function.bind()`method to **change the context** of your function and the meaning of the `this`reference.

```js
window.onload = function () {
    window.name = 'window';
    const newObject = {
        name: 'object',
        sayGreeting: function () {
            console.log(`Now this is easy, ${this.name};`);
            const nestedGreeting = function (greeting) {
                console.log(`${greeting} ${this.name}`);
            }.bind(this);
            nestedGreeting('hello');
        },
    };
    newObject.sayGreeting();
}
```

The keyword `this`refers to owner or parent of a func. the challange associted with `this`-- Can't always guarantee what parent object will apply `this`in js.

And, an older alternative is to using `bind()`, and one still in use, is to assign `this`to a variable in the outer, which can then be accessible to the inner. just like:

```js
// ...
const newObject = {
    sayGreeting: function(){
        const self=this;
        //...
        nestedGreeting= function(greeting){
            alert(self.name);
        }
    }
}
```

## Changing the flex direction

What you need is for the two columns to grow if necessary to fill the container's height -- to do so, turn the right column into a flex container,  `flex-direction: column;`Then , apply non-zero flex-grow value to both tiles within. the next listing shows the code for this, update your stylesheet to match -- 

```css
.column-sidebar {
    flex:1;
    display: flex;
    flex-direction: column;
}

.column-sidebar > .tile {
    flex:1;
}
```

now, have *nested flexboxes* -- `column-sidebar`class is a flex-item for the outer flexbox, and it's the flex container for the inner. And NOTE:

when working with a vertical flexbox, the same general concepts for rows apply, but there is one difference -- in css, working with height is fundamentally different than working with widths -- A flex container will be 100% the available width, but the height is determined **naturally** by its contents. And this behavior does not change when rotate the main axis. And the flex container's height is just determined by its flex items.

### Styling the login form

The login form and signup link -- The form has class of `login-form`, so will use that to target in CSS. Add the code in this listing to your stylesheet, will style the login form in three parts -- 

```css
.login-form h3 {  
    margin:0;
    font-size: .9em;
    font-weight: bold;
    text-align: right;
    text-transform: uppercase;
}

.login-form 
input:not([type=checkbox]):not([type=radio]) {
    display:block;
    width:100%;
    margin-top:0;
}

.login-form button{
    margin-top:1em;
    border: 1px solid #cc6b5a;
    background-color: white;
    padding: .5em 1em;
    cursor: pointer;
}
```

First is the heading. Just using the `text-align`to shift the text to the right...

The second ruleset styles the input boxes, the selector here is just peculiar, mainly cuz the `<input>`element is just pecular. Just combined the `:not()`pseudo-class with the attribute selector `[type=checkbox]`and `[type=radio]`-- this targets all input elements except checkboxes and radio buttons.

Inside the ruleset, make the inputs display `block`-- so they appear on their own line.Also, had to specify a width of 100%, Normally, display block elements automatically fill the available widht, but `<input>`is just different. Its width is determined by the `size`attribute, which indicates rougly the number of characters it should contain without scrolling. SO force a specific width with the CSS `width`property.

### Alignment, spacing and other details

should now have a solid graps of the most essential parts -- In general, you will begin a flexbox with the method already covered -- 

- Identify a container and its items and use `display:flex`on the container.
- If necessary, set the `flex-direction`
- Declare margins and/or `flex`values.

### Understanding flex container properties

Several properties can be applied to a flex container to just control the layout of its flex items -- 

- `flex-direction`: row, column, row-reverse, column-reverse
- `flex-wrap`-- specifies whether flex itmes will wrap on to a new row inside the flex container column on a new column . -- nowrap, wrap, wrap-reverse
- `flex-flow`-- shorthand for `direction, wrap`.
- `justify-content`-- control how positioned along main axis -- **flex-start**, flex-end, center, space-between, space-around.
- `align-items`-- controls how are positioned along the cross axis. flex-start, **stretch**, flex-end, baseline, center.
- `align-content`-- if flex-wrap is enabled, this controls the spacing of the flex rows long the corss axis.

### Understanding flex item properties

- `align-self`-- this controls how the item is aligned on the cross axis. will override the container's align-itmes value for the speciifc item(s). Ignored if set to `auto`.
- `Order`-- By using the `order`prop, can change the order the items are stacked. May specify any integer, positive or negative.

### Using alignment properteis

just use a couple of these properties to finish your page -- the final tile like:

```css
.centered {
    text-align: center;
}

.cost {
    display: flex;
    justify-content: center;
    align-items: center;
    line-height: .7;
}

.cost > span{
    margin-top: 0;
}

.cost-currency{
    font-size: 2rem;
}
.cost-dollars {
    font-size: 4rem;
}
.cost-cents{
    font-size: 1.5rem;
    align-self: flex-start;
}

.cta-button {
    display:block;
    background-color: #cc6b5a;
    color:white;
    padding: .5em 1em;
    text-decoration: none;
}
```

### A couple of things to be ware of -- 

Flexbox is a huge step forward for CSS -- once familar with that , might be tempted to start using it for everything in the page -- caution to trust the normal document flow and only add flexobx where you 'll just need it.

## Read-only Properties

May sometimes wish to block users of your interface from reassigning props of objects adhering to an interface. Ts allows you to add `readonly`modifier before a prop name to just indicate that **once set**, that prop should note be set to a different value. FORE:

```tsx
interface Page {
    readonly text: string;
}
function read(page: Page) {
    page.text+='!'; //error
}
```

Note that the `readonly`modifiers exist only in the type system.

### Functions and Methods

It's very common in js for object members to be functions. Ts therefore allows declaring interface members as being the function types previously -- provide two ways of declaring interface members as function like:

- Mehtod syntax -- declaring that a member fo interface is a function intended to be called as a member of the object just like : member(): void
- Property -- member: ()=> void

And, both can receive the `?`optional modifier to indicate they don't need to be provided like:

```tsx
interface OptionalReadonlyFunctions {
    optionalProperty?: ()=>string;
    optionalProperty?(): string;
}
```

Methods cannot be declared as readonly.

### Call Signatures

interfaces and object types can decalre *call signatures* -- type system, declare how a value may be called like a function. fore:

```tsx
type FunctionAlias = (input:string)=> number;

interface CallSignature {
    (input:string): number;
}

const typedCallSignature: CallSignature = (intput)=> input.length;
```

Call signatures can be used to describe functions that additionally have some user-defined prop on them. Ts will recognize a prop added to a function declarations' type like -- given a `count`prop of type `number`so, apply:

```tsx
interface FunctionWithCount {
    count: number;
    (): void;
}

let hasCallCount: FunctionWithCount;
// for the func, has a prop named count, and is ():void signature
```

### Index Signatures

Ts provides a syntax called an *index signature* to indicate that an interface's objects are allowed to take in any key and give back a certain type under the key -- Mostly used with string keys cuz js object peroperty looks convert keys to strings implicilty. like:

```tsx
interface WordCounts{
    [i: string]: number;
}

const counts: WordCounts = {};
counts.apple = 0;
counts.banana = 1;
counts.cherry = false; // error
```

So, index signatures are just convenient for assigning values to an object but aren't completely type safe. They indicate that an object should give back a value no matter what prop is being accessed. Fore:

```tsx
interface DatesByName {
    [i: string]: Date;
}
const publishDates: DatesByName = {
    Frank: new Date("1 January 1818"),
}
publishDates.Frank;
```

### Numeric index signatures

It is sometimes Js describe to only allow numbers as keys for an obj like:

```tsx
interface MoreNarrowNumbers {
    [i: number]: string;
    [i: string]: string | undefined;
}

const mix: MoreNarrowNumbers = {
    0: '',
    key1: '',
    key2: undefined,
};
```

### Nested Interfaces

Just like object types can be nested as props of other object types, interface types can also have props that are interface types.

```tsx
interface Novel {
    author:{
        name:string;
    };
    setting: Settings;
}
interface Setting {
    place: string;
    year: number;
}
let myNovel: Novel;
myNovel= {author: {name:...}, setting: ...}
```

## Interface Extensions

Ts just allows an interface to *extend* another interface, which declares it as copying all the members of another. like:

```tsx
interface Writing {
    title: string;
}
interface Novella extends Writing {
    pages: number;
}

let myNovella: Novella= {
    pages: 195,
    title: "ethan frome",
}
```

### Overridden Properties

Derived interface may overridden -- or just replace -- Props from their base interface by declaring the prop again with a just different type. Most derived interfaces that redeclare props do so either to make those properties a more specific subset of a type union to make the props a type that extends from the base:

```tsx
interface WithNullable {
    name: string | null;
}
interface WithNonNull extends WithNullableName {
    name: string;
}
interface ErrorOne extends WithNullableName {
    name: number | string; // error
}
```

### Extending multiple interfaces

In Tsc, allowed to be declared as extending multiple interfaces like

```tsx
interface GivenNumnber {
    giveNumber():number;
}
interface GiveString {
    giveString(): string;
}
interface GivesBoth extends GivenNumber, GiveString{
    giveEither(): number | string;
}
```

### Interface Merging

One of the important features of interfaces is their ability to merge with each other. Means if two are declared in the same scope with the same name, join into one bigger interface under the name with all declared fields. This snippet declares a Merged interface with two props -- `fromFirst`and `fromSecond`.

```tsx
interface Merged{
    fromFirst: string;
}
interface Merged{
    fromSecond:number;
}
```

### Member naming Conflicts -- 

Merged interfaces may not declare the same name of a prop multiple times with different types. And, if a prop is already declared in an interface, a later merged must use the same type.

```tsx
interface mergedprops {
    different: (input: string) => string;
}
interface mergedprops {
    different: (input:number)=>string; // error!
}
```

However, can define a method with the same name and a different signature. Doing so creates a function overloaded for the *method* -- note not for properties just like:

```tsx
interface Mergedmethods {
    different(input: string): string;
}
interface Mergedmethods {
    different(input:number): string; // just ok
}
```

