# Variations of dict

In this section is an overview of mapping types included in the stdlib.

### collections.OrderedDict

The most common reason to use `OrderedDict`is writing code that is backward compatable with earlier Py versions, Having said that -- py's documentaiton lists some remaining differences between `dict`and `OrderedDict`is writing code that is backward compatible with earlier Python versions -- Having said that -- py's documentation lists some remaining differences between `dict`and `OrderedDict`.

`collections.ChainMap`-- A `ChainMap`just holds a list of ampping that cna be searched as one. The lookup is performed on each input mapping in the order it appears in the ctor call,  like:

```py
d1 = dict(a=1, b=3)
d2 = dict(a=2, b=4, c=6)
from collections import ChainMap

chain = ChainMap(d1, d2)
chain
```

Note that the `ChainMap`instance does not copy the input mappings, but holds references to them. Updates or insertions to a `ChainMap`only affect the first mapping. fore:

```py
chain['c']=-1
d1 ==> 'c':-1
d2 ==-> 'c':6
```

`collections.Counter`-- A mapping that holds an integer count for each key. Updating an existing key adds to its count, this can be used to count instances of hashable objects or as a multiset. `Counter`just implements the + and - operators to combine tallies. Most useful is `most_common([n])`which returns an ordered list of tuples like:

```py
import collections
ct = collections.Counter('abracadabra')
print(ct)
ct.update('aaaaazzzzz')
print(ct)
ct.most_common(3)
```

Which returns an ordered list of tuples with the `n`most common items. like `[('a', 10), ('z', 3)]`...

### Subclassing `UserDict`instead of `dict`

It's just better to create a new mapping type by extending `collections.UserDict`rather than `dict`. Realize that when try to extend our `StrkeyDict0`from -- Main reason why it's just better to subclass `UserDict`is that the built-in has some implementation shortcuts that end up forcing us to override methods can just inherit from `UserDict`with just no problem. Note that the `UserDict`does not inherit from `dict`-- but uses *composition* -- It has an internal `dict`instance, called `data`, which just holds the actual items. This avoid undesried recursion when codeing special methods like `__setitem__`and simplifies the coding of `__contains__`. FORE:

```py
class StrKeyDict(collections.UserDict):
    def __missing__(self, key):
        if isinstance(self, str):
            raise KeyError(key)
        return self[str(key)]

    def __contains__(self, item):
        return str(item) in self.data

    def __setitem__(self, key, value):
        self.data[str(key)] = value
```

For the `__setitem__`, just converts any `key`to a `str`first.

Cuz `UserDict`extends `abc.MutableMapping`, the remaining methods that make `StrKeyDict`a full-fledged mapping are inherited from `UserDict`, `MutableMapping`, or `Mapping`.

## Immutable Mappings

The mapping types provided by the stdlib are all mutable, may need to prevent users from changing a mapping. The `types`module provides a wrapper class called `MappingProxyType`-- which, given a mapping, returns a `mappingproxy`instance that is just read-only, but dynamic proxy for the original mapping. like:

```py
from types import MappingProxyType
d = {1: 'A'}
d_proxy = MappingProxyType(d)
d_proxy
d_proxy[1] # A
# d_proxy[2]= 'Z'  # error - doesn't support item assignment
d[2]='B'
d_proxy[2]
```

### Dictionary Views

The `dict`methods `.keys(), vlaues(), items()`return  instances of classes called `dict_keys, dict_values, dict_items`. -- These are just read-only projections of internal data structures used in the `dict`implemenation.

- Keys must be hashable objects, must just implement proper `__hash__`and `__eq__`methods.
- Item access by key is just very fast -- A `dict`may have M of keys
- Key ordering is preserved as a side effect of a more compact memory layout for `dict`.
- Despite its now compact laoyut, dicts inevtiably have a significant memory overhead.

## Set Theory

Sets are not new in Python -- the `set`type and its immutable sibling `frozenset`first appeared as modules in Py 2.3. A set is a collection of unique objects like: If you want to remove duplicates but preverse the order:

`dict.fromkeys(['spam', 'spam', 'eggs', 'spam']).keys()`

Set elements must also be hashable, and the `set`type is not hashable.

a | b for union, a & b for intersection, a - b for difference, a^b for symmetric difference

## Unicode Text Vs. Bytes

Py 3 just introduced a sharp dictinction between strings of human text and sequences of raw bytes -- Implicit conversion of byte sequences to Unicode text is a thing of the past. Depending on the kind of work you do with Python, may think that understanding Unicode is not important. That is unlikely, but anyway there is no escaping the `str`vs `byte`divide.

### Character issues

The Unicode std explicitly separtes the identity of characters from specific byte representations -- 

- The identityof character -- its *code point*
- The actual byte that represent a character depend on the *encoding* in use. And an encoding is an algorithm that converts code points to byte sequences and vice versa.

```py
s = 'café'
len(s)
b= s.encode('utf8')
b
b.decode('utf8')
```

1. The `str`hs 4 unicode characters
2. Encode str to `bytes`using `UTF-8`encoding
3. `bytes`literals have `b`prefix
4. bytes b has five bytes
5. Decode `bytes`to `str`using decode.

### Byte Essentials in py

The new library sequence types are unlike the Py2 `str`in many regards. The first thing to know is that there are two basic built in types for binary sequences. The immutable `bytes`type introduced in Py 3 and the mutable `bytearray`. For *byte string* just refer `bytes`or `bytearray`. fore:

```py
cafe= bytes('café', encoding='utf8')
cafe[:1]

cafe_arr = bytearray(cafe)
cafe_arr
cafe_arr[-1:]
```

1. `byts`can be built from a `str`, given an encoding
2. Each item is an integer in range
3. A slice of `bytearray`also itself.

### Basic Encoders and Decoders

The py distribution bundles more than 100 codecs for next to byte conversion and vice versa. like:

```py
for codec in ['latin_1', 'utf8', 'utf_16']:
    print(codec, 'El Nino'.encode(codec), sep='\t')
```

Understanding Encode/Decode Problems -- Although there is a generic `UnicodeError`exception, the error reported by Py is just usually more specific, either a `UnicodeEncodeError`or `UnicodeDecodeError`.

Coping with `UnicodeEncodeError`-- Most non-UTF codes handle only a small subset of the Unicode characters, when converting text to bytes, if a charcter is not defined in the target encoding, `UnicodeEncodeError`will be raised.

FORE:

```py
city.encode('cp437', errors='ignore')
city.encode('cp437', errors='replace')
city.encode('cp437', errors='xmlcharrefreplace')
```

1. `error='ignore'`handler skips characters that cannot be encoded. But, This is usually a very bad idea, leading just silent data loss.
2. When endoding `error='replace'`substitutes unencodable, with `?`, also lost
3. `xmlcharrefreplace`-- replaces with XML entity.

### Coping with `UnicodeDecodeError`

Not every byte holds a valid ASCII character, and not every byte sequence is valid U8 or U16 -- on the other hand, many legacy 8-bt encodings like `cp1252`.. are just able to decode any stream of bytes, including random noise, without reporting errors, therefore, if your program assumes the wrong 8bit encoding, it will silently decode garbage.

```py
octets = b'Montr\xe9al'
octets.decode('cp1252')
octets.decode('utf8')  # raise
```

## Handling Text Files

The best practice for handling text I/O is the *Unicode sandwich* -- this means that bytes should be decoded to `str`as early as possible on input, and the flling of the sandwich is the business logic of your program, where text handling is done exclusively on `str`objects. U should never be encoding or decoding in the middlew of other processing. On output, the `str`are endoded to `bytes`as late as possible. Most web frameworks work like that.

PY 3 makes it easier to follow the advice of the Unicode sandwich, cuz the `open`built-in does the necessary decoding when reading and encoding when writing files in the text mode, so, all you get from the `my_file.read()`and pass to `my_file.write(text)`just are `str` objects.

```py
open('cafe.txt', 'w', encoding='utf8').write('cafe')
open('cafe.txt').read() #cafe
```

The bug...

Specified U8 encoding when writing the file but failed to do so when reading it. So Py assumed Window default file encoding -- *code page 1252*.

And a curious detail is that the `write`function in the first statement just reports four characters were written.

```py
fp= open('cafe.txt', 'w', encoding='utf8')
fp.write('cafe')
fp.close()
import os
os.stat('cafe.txt').st_size
fp= open('cafe.txt')
fp2.encoding # cp1252
fp2.read()
fp3 = open('cafe.txt', 'rb')
fp3.read()  # BufferedReader not a TextIoWrapper
```

### Sorting Unicode text

Py sorts sequences of any type by comparing the items in each sequences on e by one. FOR strings, this means comparing the code prints.

## Data Class Builders

Py offers a few ways to build simple class that is just a collection of fields, with little or no extra functionality -- that pattern is known as *data class* -- and *data classes* is one of the packages that supports this pattern. This covers 3 different class builders that you may use as shortcuts to write data class -- 

`collections.namedtuple`-- 2.6 form.
`typing.NamedTuple`-- an alternative that requires type hints on the fields
`@dataclasses.dataclass`-- A class decorator that allows more customize than previous alternatives.
`pydantic`-- most widely used data validation lib for py.

### Overview of Data Class Builders

```py
from collections import namedtuple
Coordinate = namedtuple('Coordinate', 'lat lon')
issubclass(Coordinate, tuple)   # True
moscow= Coordinate(55.756, 37.617)
moscow
moscos == Coordinates(..., ...) # True
```

Can use the `__eq__`directly.

And the newer `typing.NamedTuple`provides the same functionality, adding a type annotation to each field. like:

```py
import typing
Coordinate=typing.NamedTuple('Coordinate', 
                             [('lat', float), ('lon', float)])
issubclass(Coordinate, tuple) # True
typing.get_type_hints(Coordinate)
```

Since py 3.6, the `typing.NamedTuple`can also be used in a `class`statement, with the type annotations written -- much more readable, and makes it easy to override methods or add noew ones like:

```py
from typing import NamedTuple

class Coordinate(NamedTuple):
    lat: float
    lon: float

    def __str__(self):
        ns = 'N' if self.lat >= 0 else 'S'
        we = 'E' if self.lon >= 0 else 'W'
        return f'{abs(self.lat):.1f} {ns}, {abs(self.lon):.1f} {we}'
```

In the `__init__`method generated by the `typing.NamedTuple`, the fields appear as parameters in the same order they appear in the `class`statement.

And, like `typing.NamedTuple`, the `dataclass`decorator syntax to declare instance atributes -- The decorator reads the variable annotations and automatically generates methods for your class like:

```py
from dataclasses import dataclass

@dataclass(frozen=True)
class Coordinate:
    lat: float
    lon: float
    def __str__(self):
        ns = 'N' if self.lat>=0 else 'S'
        # ...
```

Note that the body of the classes are just identical.

### Main Features

The different data class builders have a lot common -- like:

- Mutable instances -- A key difference between these class builders is that `collections.namedtuple`and `typing.NamedTuple`build `tuple`subclasses, therefore the instances are **immutable**. By default, the `@dataclass`produces mutable classes, but the decorator accepts a keyword argument `frozen`, when `frozen=True`then class will raise exception if try to assign value to a filed
- class statement syntax -- Only the `typing.NamedTuple`and `dataclass`support the regular `class`statements
- Construct dict -- Both named tuple variants provide an instance method -- `_asdict`-- to construct a `dict`object from the fields in a data class instance. And the `dataclasses`just provides a function `asdict`.
- Get field naems and default values -- All 3 builders let you get the filed names and default values that may be configured for them. In named tuple classes, that metadata is in the `._fields`and `._fields_default`class attributes.
- Get field types -- Classes defined with the help of `typing.NamedTuple`and `@dataclass`have a mapping of field names to type the `__annotations__`class attribute, use the `typing.get_type_hints`can read that.
- New instance with changes -- Given a named tuple instance x -- the call `x._replace(**kwargs)`returns a new instance with some attribute values replaced according the keyword args given, and the `dataclasses.replace(x, **kwargs)`module-level func does the same thing.
- New class at runtime -- Although the `class`more readable, it is hardcoded. A framework may need to build data classes on the fly, for that, can use the default function call syngax of `collections.namedtuple`which is likewise supported by `typing.NamedTuple`, and the `dataclasses`module provides a `make_dataclass`func for same.

### Classic Named Tuples

is a factory that builds subclasses of `tuple`enhanced with field names, class name, and informative `__repr__`. FORE:

```py
City= namedtuple ('City', 'name country population coordinates')
```

Just note that as a `tuple`subclass, `City`just inherits useful methods such as `__eq__`and the special methods for comparsion operators -- `__lt__`. And a named tuple offers a few attributes and methods in addition to those niherited from the tuple like: `_fields, _make(iterable), _asdict()` FORE:

```py
Coordinate = namedtuple('Coordinate', 'lat lon')
City = namedtuple('City', 'name country population coordinates')
delhi = ('Delhi', 'IN', 21.935, Coordinate(28.51, 77.22))
delhiCity= City._make(delhi)
delhiCity._asdict()

import json
s = json.dumps(delhiCity._asdict())
json.loads(s)
```

Since py 3.7, `namedtuple`accepts the `defaults`keyword-only arg providing an iterable of `N`default values for each of the N rightmost fields of the class. like:

`Coord = namedtuple('Coord', 'lat lon reference', defaults=['WGS84'])` # reference = WGS84

### Typed Named Tuple

The `Coordainate`with a default field can be written using `typing.NamedTuple`like:

```py
from typing import NamedTuple

class Coordinate(NamedTuple):
    lat: float
    lon: float
    reference: str = "WGS84"
```

### Type Hints 101

a.k.a Type annotations, are ways to declare the expected type of function arguments, return values, and attributes. the first thing need to know is that they are not enforced at all by the py bytecode compiler and interpreter.

No Runtime effect -- Type hints have no impact on the runtime behavior of Py programs. The type hints are just intended promarily to support 3rd-party type checkers.

### Variable annotation Syntax

`var_name: some_type`

In the context of defining a data class, these types are more likely to be useful -- 

- A concrete class
- A parameterized collection type like `list[int], tuple[str, float]`
- Typing optional -- fore, `Optional[str]`, means it can be `str`or `None`.

And, can also initialize with a value : `var_name: some_type= a_value`

### The meaning of Variable Annotations

At import time, when a module is loaded, Py does read them to build the `__annotations__`dictionary that the `typing.NamedTuple`and `@dataclass`then use the enhance the class.

### More about the `@dataclass`

Only-- This is its signature like:

`@dataclass(*, init=True, repr=True, eq=True, order=False, Unsafe=False, frozen=False)`

- `init`-- Generate an `__init__`
- `repr`-- generate an `__repr__`
- `order`-- generates , `__lt__`...
- `unsafe_hash`-- Generate `__hash__`
- `forzen`-- Make instance immutable.

### Field Options

Already seen the most basic field option -- a default value wiht the type hint - The instance fields you declare will become parameters in the generated `__init__`. If:

```py
@dataclass
class ClubMember:
    name:str
    guests: list= [] # error
```

The `ValueError`-- must be:

```py
from dataclasses import dataclass, field

@dataclass
class ClubMember:
    name:str
    guests: list = field(default_factory=list)
    
c = ClubMember('a', ['b', 'c'])
c.guests
```

In this, the default value is set by calling the `dataclasses.field`with `default=list`

Or, just like:

`guests: list[str]= field(default_factory=list)`

Means that the `guests`must be a `list`in which every item is a `str`.

For the `field`function --

- `default`-- default value foe the field
- `init`-- include filed in parameters to `__init__`
- `compare, hash, metadata`

Fore the `default`exists cuz the `field`call takes the place of the default value in the field annotation like:

`athlete: bool = field(default=False, repr=False)`

```py
from enum import Enum, auto
from dataclasses import dataclass, field
from typing import Optional
from datetime import date


class ResourceType(Enum):
    BOOK = auto()
    EBOOK = auto()
    VIDEO = auto()


@dataclass
class Resource:
    identifier: str
    title: str = '<undefined>'
    creators: list[str] = field(default_factory=list)
    date: Optional[date] = None
    type: ResourceType = ResourceType.BOOK
    description: str = ''
    language: str = ''
    subjects: list[str] = field(default_factory=list)
```

- `Enum`will provide type-safe values for the `Resource.type`field.
- `identifier`is the only required field

And the `__repr__`generated by is ok, but can make it more readable like:

```py
def __repr__(self):
    cls = self.__class__
    cls_name = cls.__name__
    ident = ' ' * 4
    res = [f'{cls_name}(']
    for f in fields(cls):
        value = getattr(self, f.name)
        res.append(f'{ident}{f.name}={value!r},')
    res.append(')')
    return '\n'.join(res)
```

## Understanding Action results in RPs

Although it is not obvious, Rps handler methods use the same `IActionResult`interface to control the responses they generate -- To make page model classes easier to develop, handler methods have an implied result that displays the view part of page. 

The `Page()`is inherited from the `PageModel`class and creates a `PageResult`object, which tells the framework to render the view part of the page. Unlike the `View()`used in MVC action methods-- the RPs `Page()`doesn't accept arguments and always renders the view part of the page that has been selected to handle the request. like:

```cs
public async Task<IActionResult> OnGetAsync(long id =1) {
    Product = await context.Products.FindAsync(id);
    return Page();
}
```

Instead of using the `NotFound`method when requested data cannot be found, fore, a better approach is to redirect client to another URL that can display an HTML message for the user. The `@page`directive overrides the route convention so that this RP will handle the `/noid`URL path. like:

```cs
public async Task<IActionResult> OnGetAsync(long id=1) {
    Product = ...;
    if(Proudct == null) {
        return RedirectToPage("NotFound");
    }
    return Page();
}
```

### Handling multiple HTTP methods

RPs can define handler methods that respond to different HTTP methods -- most common combination is to support the `GET`and `POST`methods that allow users to view and edit data.

```cs
public class EditModel : PageModel
{
    private DataContext context;
    public Product? Product { get; set; }

    public EditModel(DataContext ctx) => context = ctx;

    public async Task<IActionResult> OnPostAsync(long id, decimal price)
    {
        Product? p = await context.Products.FindAsync(id);
        if(p!=null)
        {
            p.Price = price;
        }
        await context.SaveChangesAsync();
        return RedirectToPage();
    }

    public async Task OnGet(long id)
    {
        Product = await context.Products.FindAsync(id);
    }
}
```

```html
@page "{id:long}"
@model WebApp.Pages.EditModel

<div class="bg-primary text-white text-center m-2 p-2">Editor</div>

<div class="m-2">
    <table class="table table-sm table-striped table-bordered">
        <tbody>
        <tr><th>Name</th><td>@Model.Product?.Name</td></tr>
        <tr><th>Price</th><td>@Model.Product?.Price</td></tr>
        </tbody>
    </table>
    
    <form method="post">
        @Html.AntiForgeryToken()
        <div class="mb-3">
            <label>Price</label>
            <input class="form-control" name="price"
                   value="@Model.Product?.Price" />
        </div>
        <button class="btn btn-primary mt-2" type="submit">Submit</button>
    </form>
</div>

```

The `@Html.AntiFogeryToken()`expression adds a hidden form field to the HTML form that ASP.NET core uses to guard against cross-- site request forgery (CSRF) attacks. And the page model class defines two handler methods, and the name of the method just tells the RPs framework which HTTP method each handles. The `OnGetAsync()`method is used to handle GET.

The `OnPostAsync`is used to handle POST requests, which will be sent by the browser when the user submits the HTML form. The parameters for the method are obtained from the requests so that the `id`value is obtained from the URL route.

### Selecting a handler method

The page model class can define multiple handler methods -- allowing the requests to select a method using a `handler`query string parameter or routing segment variable. To demonstrate this feature, add a RP file named `HandlerSelector.cshtml`like:

```cs
public class HandlerSelectorModel : PageModel
{
    private readonly DataContext context;
    public Product? Product { get; set; }

    public HandlerSelectorModel(DataContext context)
    {
        this.context = context;
    }

    public async Task OnGetRelatedAsync(long id=1)
    {
        Product = await context.Products
            .Include(p=>p.Supplier)
            .Include(p=>p.Category)
            .FirstOrDefaultAsync(p=>p.ProductId == id);

        if(Product != null && Product.Category != null)
        {
            Product.Category.Products = null;
        }
    }

    public void OnGet(long id =1)
    {
        Product = context.Products.Find(id);
    }
}
```

```html
@page
@model WebApp.Pages.HandlerSelectorModel
@{
    Layout = "_Layout";
}

<div class="bg-primary text-white text-center m-2 p-2">Selector</div>
<div class="m-2">
    <table class="table table-sm table-striped table-bordered">
        <tbody>
        <tr><th>Name</th><td>@Model.Product?.Name</td></tr>
        <tr><th>Price</th><td>@Model.Product?.Price</td></tr>
        <tr>
            <th>Category</th>
            <th>@Model.Product?.Category?.Name</th>
        </tr>
        <tr>
            <th>Supplier</th>
            <td>@Model.Product?.Supplier?.Name</td>
        </tr>
        </tbody>
    </table>
    <a href="/handlerSelector" class="btn btn-primary">Std</a>
    <a href="/handlerselector?handler=related" class="btn btn-primary">related</a>
</div>
```

So the page model class in this example defines two handler methods -- the `OnGet`is used by default. Just:

`<a href=/handlerselector?handler=related...`

Note that the name of handler method is specified without Prefix and Suffix so that the method is selected.

### Understanding the RP view

The view part of a RP uses the same syntax and has the same features as the views used with controllers. fore, layouts in the `Pages/Shared`folder can.

### Using Partial views in RPs

RPs can also use partial views so that common content isn't duplicated. The example in this section relies on the tag helpers feature, which describe in detail -- for this chapter, add the directive to the view imports file.

`@addTagHelper *, Microsoft.AspNetCore.MVC.TagHelpers`

Then, add a Razor view `_ProductPartial.cshtml`like:

```html
@model Product

<div class="m-2">
    <table class="table table-sm table-striped table-bordered">
        <tbody>
        <tr><th>Name</th><td>@Model?.Name</td></tr>
        <tr><th>Price</th><td>@Model?.Price</td></tr>
        </tbody>
    </table>
</div>
```

Here just like the MVC mode -- Partial views use the `@model`directive to receive a view model object and do not use the `@page`directive or have page models, both of which are specific to RPs. This allows RPs to share partial views with MVC controllers.

Partial views receie a view model through their `@model`directive and not a page model, it is for this reason that the value of the model attribute is `Model.Product`and not just `Model`.

`@await Html.PartialAsync("_ProductPartial", Model.Product)`

### Creating RPs without Page models

If a Rp is simply presenting data to the user, the result can be page model class that simply declares a ctor dependency to set prop that is consumed in the view.

```html
<h5 class="bg-primary text-white text-center m-2 p-2">Categories</h5>
<ul class="list-group m-2">
    @foreach (var c in Model.Categories)
    {
        <li class="list-group-item">@c.Name</li>
    }
</ul>
```

```cs
public class DataModel : PageModel
{
    private readonly DataContext context;
    public IEnumerable<Category>? Categories { get; set; }
    public DataModel(DataContext context) => this.context = context;
    public void OnGet()
    {
        Categories = context.Categories;
    }
}
```

This page doesn't transform data, perform calculations, or do anything other than giving the view access to the data trhough DI. To avoid this pattern, where a page model class is used only to access a service, the `@inject`directive can be used to obtain the service in the view.

Can be:

```html
@page
@inject DataContext context;

<h5 class="bg-primary text-white text-center m-2 p-2">Categories</h5>
<ul class="list-group m-2">
    @foreach (Category c in context.Categories)
    {
        <li class="list-group-item">@c.Name</li>
    }
</ul>
```

## Using View Component

- View components are classes that provide app logic to support partial views or to inject small fragments of HTML or JSON data into a parent view.
- Without this, it is hard to create *embedded* functionality such as shopping basket, or login panels
- Typically derived from the `ViewComponent`class are applied in a parent view using the `vc`or `@await Component.InvokeAsync`expression.

### Using the built-in tag helpers

ASP.NET core provides a set of built-in tag helpers that apply the most commonly required element transformations. explain those tag helpers that deal with anchor, script, link, and image, as well as features for caching content and selecting content based on the environment.

- Perform commonly required transformations on HTML elements
- The tag helpers are applied using attributes on std HTML elements or thropugh custom HTML elements

Then , make changes to the `_RowPartial.cshtml`like:

```html
@model IEnumerable<Product>

<h6 class="bg-secondary text-white text-center m-2 p-2">Products</h6>
<div class="m-2">
    <table class="table table-sm table-striped table-bordered">
        <thead>
        <tr>
            <th>Name</th><th>Price</th>
            <th>Category</th><th>Supplier</th>
        </tr>
        </thead>
        <tbody>
        @foreach (var p in Model)
        {
            @await Html.PartialAsync("_RowPartial", p)
        }
        </tbody>
    </table>
</div>
```

### Enabling the built-in tag helpers

These are all defined in the `Microsoft.AspNetCore.Mvc.TagHelpers`namespace and are enabled by adding an `@addTagHelpers`directive to individual views or pages.

## Handling requests with the middleware pipeline

The middleware pipeline is one of the most important parts of configuration for defining how your app behaves and how it responds to requests. Understanding is key to adding functionality to your apps.

### Defining middleware

In core, *middleware* is C# classes that can handle an HTTP request or response, can:

- Handling an imcoming HTTP request by generating an HTTP *response*.
- Process an incoming, modify it, pass it onto another
- Process an, modify, and pass it onto another piece of middleware or to the web server.

Can use middleware in a multitude of ways in won applications. A piece of logging middleware, fore, might note when a request arrived and then pass it on to another piece of middleware. Meanwhile, a static-file middleware component might spot an incoming request for an image with a specific name, load the image from disk, and send it back to the user wthout passing it on.

The most important piece of middleware in most ASP.NET core apps is the `EndpointMiddleware`class. This class normally generates all your HTML and Js object Notation (JSON) responses. and is the focus of most of this -- it typically receives a request, and generates a responses, and then sends it back to the user.

One of the most common use cases for middleware is for cross-cutting concerns of app -- these aspects of your application need to occur for every request, regardless of the specific path in the request or the resource requested.

- Logging each request
- Adding std security to the response
- Associating a request with the relevant user
- Setting the lang for the current request

DEF -- When a middleware component short-circuit the pipeline and returns a response, called *terminal middleare*. And a key point to glean from this is that the pipeline is *bidirectional*. The request passes through the pipeline in one direction until a piece of middleware generates a response. At which point the response passes back through the pipeline, passing through each piece of middleware a *second* time. In reverse order. -- until it gets back to the first piece of middleware.

All middleware has access to the `HttpContext`for a request, can just use this object to determine whether the request contains any user credentials, to identify which page the request is attempting to access, and to featch any posted data, fore, then it use these details to determine how to handle the request.

The addition of middleare to `WebApplication`to form the pipeline should be -- serveral points are worth in :

- Middleware is added with `Use*()`methods
- `MapGet()`defines an *endpoing*, not middleware, it defines the endpoints that the routing and endpoint middleare can use.
- `WebApplication`automatically adds some middleware to the pipeline, such as `EndpointMiddleware`.
- The order of the `Use*()`method calls is important and defines the order of the middleware pipeline.

NOTE, it's important to understand that the `MapGet()`does not add middleware to the pipeline, it just defines an *endpoint* in your app -- these are used by the routing and endpoint middleware. Can define the endpoints for your app by using `MapGet()`anywhere in the `Program.cs`file before the call to `app.Run()`, but the calls are typically placed after the middleware pipeline definition.

## Creating a JSON API with Minimal APIs

Client-side single-page apps have become just popular -- with development such as.. These typically use Js running a web browser to generate the HTML that users see and interact wth. The server sends this initial js to the browser when the user first reaches the app. The user's browsers loads the Js and initialize the SPA before loading any app data from the server.

Once the SPA is loaded in the browser, communiation with a server will still occurs over HTTP, but instead of sending HTML directly to the browser in response to requests, the server-side app sends data -- normally, in the ubiquitous JSON format -- to the client-side application.

Similar to client-side SPAs, a mobile app typically communicates with a server app by using an HTTP API. One final use case for an HTTP API is where your app is designed to be partially or solely consumed by other backend services. One selling point for using an HTTP API is that it can serve as a generalized backend for all your client apps.

NOTE -- Although there has been an industry shift toward client-side frameworks, server-side rendering using Razor is still relevant -- which approach you choose depends largely on your preference for building HTML apps in the traditional manner vs. using Js on the client.

### Defining Minimal API endpoints

```cs
var people = new List<Person>
{
    new("Tom", "Hanks"),
    new("Denzel", "Washington"),
    new("AL"),
    new("Morgan", "Freeman"),
};

app.MapGet("/person/{name}", (string name) =>
    people.Where(p => p.FirstName.StartsWith(name)));
app.Run();

internal record Person(string FirstName, string? LastName=null);
```

By default, minimal APIs serialize C# objects to JSON. The ASP.NET core system is quite powerful, explore it in more detail in ch6.

### Mapping verbs to endpoints

So far in this defined all our minimal API endpoints using the `MapGet()`func -- this matches requests use the `GET`is the most -- used verbs. Should use `GET`only to `get`data from the server. Can define endpoints for other verbs with minimal APIs by using the appropriate `Map*`functions, to map a `POST`, fore, use the `MapPost()`like:

- `MapPost(path, handler)`-- POST -- Create a new resource
- `MapPut(path, handler)`, `MapDelete(path, handler)`, `MapPatch`, and
- `MapMethods(path, methods, handler)`-- map multiple operations
- `Map(path, handler)`-- all verbs
- `MapFallback(handler)`-- useful for SPA fallback routes.

RESTful apps typically stick close to these verb uses where possible, but some of the actual implemenations can differ, and people can easily caught up in pedantry.

### Defining route handlers with functions

For basic examples, using a lambda as the handler for an endpoint is often the simplest approach, but you can take many approaches. like:

```cs
app.MapGet("/fruit", () => Fruit.All);
var getFruit = (string id) => Fruit.All[id];
app.MapGet("/fruit/{id}", getFruit);
app.MapPost("/fruit/{id}", Handlers.AddFruit);
Handlers handlers = new();
app.MapPut("/fruit/{id}", handlers.ReplaceFruit);
app.MapDelete("/fruit/{id}", DeleteFruit);

app.Run();

void DeleteFruit(string id)
{
    Fruit.All.Remove(id);
}

record Fruit(string Name, int Stock)
{
    public static readonly Dictionary<string, Fruit> All = new();
}

class Handlers
{
    public void ReplaceFruit(string id, Fruit fruit)
    {
        Fruit.All[id]= fruit;
    }

    public static void AddFruit(string id, Fruit fruit)
    {
        Fruit.All.Add(id, fruit);
    }
}

```

Just demonstrates the various ways you can pass handlers to an endpoint by simulating a simple API for interacting with a collection of Fruit items.

- A lambda expression
- A `Func<T, TResult>`variable
- A static method
- A method on an instance variable
- A local function.

So Minimal APIs leave you free to organize your endpoints any way you choose, that flexiblity is often cited as a reason to not use them.

## Populating the Dbs

To populate the dbs with some initial data, just:

```sql
insert into Products(...) values 
(...)
```

### Implementing the Repository Pattern

And, the `Home`controller in the example app works diretly with the `EFdatabaseContext`object to access the data in the dbs. This is a functional approach, but can be improved upon by implementing the repository pattern.

A *repository* consists of an interface that defines the data operations that can be performed in an app and an implementation class that does the actual work. The MVC parts of the application only use the interface, while, behind the scenes, the implementation class performs the data operations using the dbs context.

Using a respository maakes it easier to isolate MVC components and consolidates the code that deals with EF core, whcih makes it easier to unit test the different parts of the appliation and to switch to a different dbs.

### Defining the Repository Interfaces and Implementation Class

```cs
public interface IDataRepository
{
    IEnumerable<Product> Products { get; }
}
public class DataRepository: IDataRepository
{
    private readonly EFDatabaseContext context;
    public DataRepository(EFDatabaseContext context) {  this.context = context; }
    public IEnumerable<Product> Products => context.Products;
}
```

So the implementation class receives an `EFDatabaseContext`object through its ctor, which it uses to implement the `Products`prop required by the interface.

```cs
public class HomeController : Controller
{
    private IDataRepository repository;
    public HomeController(IDataRepository repo)=>repository= repo;

    public IActionResult Index()
    {
        return View(repository.Products);
    }
}
```

Then just change the `IEnumerable`to `IQueryable`.

```cs
public IActionResult Index()
{
    var products = repository.Products.Where(p => p.Price > 25).ToArray();
    ViewBag.ProductCount = products.Count();
    return View(products);
}
```

The `ToArray()`here forces evaluation of the query and produces a collection of objects that can be processed further without triggering additional queries, which means that the `Count`method operate on the data that has already been received from the dbs.

### Hiding the Data Operations

A knock-on problem with using the `IQueryable<T>`interface is that exposes details of how the data is manged to the rest of the application -- this means that every time a new action method is written, fore, must pay attention to wheather the `IQueryable<T>`interface is being used and make sure you are reqquesting only the data require using the only essential number of queries.

Just replaced the `Products`prop defined by the interface with a method that performs the query that was being done by the controller. like:

```cs
public IEnumerable<Product> GetProductsByPrice(decimal price)
{
    return context.Products.Where(p => p.Price >= price).ToArray();
}
```

The context class's `DbSet<Product>`implements the `IQueryable<Product>` -- simply have returned the result from the LINQ query without any kind of casting or convention.

### Completing the Example MVC application

To finish this, going to complete the MVC part of the application by adding action methods and views for the most common operations that an app requires. Just: retrieving a single, retrieve all, create a new, update an existing.

```cs
public interface IDataRepository
{
    Product GetProduct(long id);
    IEnumerable<Product> GetAllProducts();
    void CreateProduct(Product newProduct);
    void UpdateProduct(Product changedProduct);
    void DeleteProduct(long id);
}
```

The `GetProduct`and `DeleteProduct`methods define parameters that accepts a PK value for a stored object, corresponding to the `Id`property, and the `CreateProduct`.. like:

### Adding the Action methods

To add the action that will use the new data operations, edit the `Home`controller to add methods -- these use the Core MVC conventions and feaures for handling requests, including POST-only methods and model binding.

```cs
public class HomeController : Controller
{
    private IDataRepository repository;
    public HomeController(IDataRepository repo)=>repository= repo;

    public IActionResult Index()
    {
        return View(repository.GetAllProducts());
    }

    public IActionResult Create()
    {
        ViewBag.CreateMode = true;
        return View("Editor", new Product { Name = default!, Category = default! });
    }

    [HttpPost]
    public IActionResult Create(Product product)
    {
        repository.CreateProduct(product);
        return RedirectToAction("Index");
    }

    public IActionResult Edit(long id)
    {
        ViewBag.CreateMode = false;
        return View("Editor", repository.GetProduct(id));
    }

    [HttpPost]
    public IActionResult Edit(Product product)
    {
        repository.UpdateProduct(product);
        return RedirectToAction("Index");
    }

    [HttpPost]
    public  IActionResult Delete(long id)
    {
        repository.DeleteProduct(id);
        return RedirectToAction("Index");
    }
}
```

## Sorting an Array of Objects by Property Value

Want to sort an array that contains objects, based on one of its properties -- The `Array.sort()`method recorders an array, fore, it arranges an array of numbers from the smallest to largest. Or it puts an array of strings in aplhabetical order. like:

```js
people.sort((a, b) => {
    return a.age - b.age;
});
```

### Transforming Every element of an array

want to convert every element in an array using the same transformation, and use the changed value to build a new array. -- `Array.map()`method -- supply a function that just perform the change. The `map()`method goes through the entire array, applying your function to each element and building a new array with the return values.

Could iterate over the array in a loop, a more streamlined solution -- using the `Array.reduce()`method like:

```js
const reduceFunction = (accumulator, element) => {
    const newTotal = accumulator + element;
    return newTotal;
};

const number = [12, 255, 12, 5, 16, 99];
const total = number.reduce(reduceFunction, 0);
total
```

When the reducer func is called on the last tiem, it just makes its final calculation. That return value becomes the result that's returned from the `reduce()`method.

### Valiating Array Contents

Want to ensure that array contents meet certain criteria -- Use the `Array.every()`method to check that elements passes a given test like:

```js
['cc', 'aa', 'aaa', 'abc'].every(e=>/^[A-z]+$/.test(e))
```

Unlike many other array methods that use callback functions, the `every()`and `some()`methods do not work against all array elements. Instead, they only process as many array elements as necessary to fulfill their functionality.

### Creating of Nonduplicated Values

Want to create an array-like object that never contains more than one copy of the same value -- just the `Set`object, it quitely ignores attempts to add the same item more than once.

The `Map`has a `set`method, just note that: like:

```js
const products = new Map();
products.set('RU007', {name:..., price:...})
```

## Building a basic Flexbox menu

To build this menu, should consider which element needs to be the flex container -- keep in mind that its child elements will become the flex items -- in this case of our page manu, the flex container should be unordered list `<ul>`.

```css
.site-nav {
    display: flex;
    padding-left: 0;
    list-style-type: none;
    background-color: #5f4b44;
}

.site-nav > li {
    margin-top:0;
}

.site-nav > li > a {
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
}
```

Note that you are just working with three levels of elements here -- the `site-nav`list, the list items and the acnhor tags within them -- used direct dessendant combinator > to ensure you only target direct child elements. This is probably not strictly necessary.

### Adding Padding and spacing

It's important to note how to do this -- you will apply the menu item padding to the internal `<a>`elemetns, not the `<li>`elements, need to entire area that looks like a menu link to behave like a linek when the user clicks. Just update like: Need to note you don't want to turn the `li`into a big nice-looking buton, only have a small clickable `a`.

```css
.site-nav{
    padding: .5em;
}
.site-nav li {
    margin-top:0;
}
.site-nav a {
    display:block; /* make block add to the parent's height*/
    padding: .5em 1em;
}
```

just notice that you made the link a display `block`. If you were to remain inline, the height they'd contribute to their parent would be derived from their line height -- not their padding and content. Cuz every li just has one a.

Next, need to add space between the menu items -- Regular old margins will do the trick -- even better, flexbox allows you to use `margin:auto`to fill available space between the flex items. Can also use this to move the final menu item to the right side. For this, using margin between each, but not to the outside edges. so:

```css
.site-nav li+li {
    margin-left: 1.5em;
}
.site-nav .nav-right {
    margin-left:auto; /*fill the available space */
}
```

Just applied the auto margin to only one element, could apply it to the support menu item instead to shift both it and the about item to the right.

Margins work well here cuz you want different space between these items. If wanted equal spacing between the items, need the `justify-content`prop would be better.

### Flex item sizes

The previous listing used margins for spacing between the flex items. To define their size, need to use the familar `width`and `height`props, but flexbox provides more options for sizing and spacing than the `margin..`-- the flex prop controls the size of the flex items along the **main axis**-- Apply a flex layout to the main area of the page, then you will use the `flex`prop to control the size of the columns -- initially, your main area like: Need to add the css like:

```css
.tile {
    padding: 1.5em;
    background-color: #fff;
}

.flex {
    display: flex;
}

.flex > * + * {
    margin-top:0;
    margin-left: 1.5em;
}
```

Now your content is divided into two columns, on the left is the larger area for the primary content of the page, and on the right is a login form and a small pricing box.

When it comes to CSS -- it's important to consider not only the specific content you have on the page now, but also what will happen as that content changes -- or as the stylesheet is applied to similar pages.

The `flex`prop, which is applied to the flex items, just gives you a number of options -- apply just the most basic use case first to get familar with it.

```css
.column-main {
    flex:2;
}
.column-sidebar{
    flex:1;
}
```

Now the two columns grow to fill the space, so together they are the same width as the `nav`, with the main column twice as wide as the sidebar. Flexbox was just kind enough to take care of math for you.

The `flex`prop is just a shorthand for 3 different sizing props -- `flex-grow`, `flex-shrink`, and `flex-basis`. FOR this example, just only supplied `flex-grow`-- and leaving the other two props to their default values. 

so, `flex:2`==> `flex: 2 1 0%`

These shorthand declarations are generally preferred, can also declare just individually.

```css
flex-grow: 2;
flex-shrink: 1;
flex-basis: 0%;
```

### Using the `flex-basis`prop

The `flex basis`defines a sort of starting point for the size of an element -- an initial `main size`. The `flex-basis`can be set to any value that would apply to `width`, including values in px, ems, or percentages. Its initial is `auto`-- means that the browser will look to see if the element has a `width`declared. if so, use, if not, determines naturally by the contents.

Once this initial size is established for each flex item, they will just add up to some width. The remaining space will be consumed by the flex items based on the `flex-grow`values. If an item won't 0, won't grow past its flex basis. NOTE: **non-negative**.

So , take the flex-grow:2 will grow twice as much as an item with `flex-grow:1`.

### Using the `flex-shrink`

The `flex-shrink`prop follows similar principles as `flex-grow`. after determning the initial main size of the flex items, could exceed the size available in the flex container. Without the `flex-shrink`, this would result in an overflow.

The value for each item just indicates whether it should shrink to prevent overflow -- if an item has a value of 0, will not shrink, items with a value greater than 0 will shrink **until there is no overflow**. An tiem with a higher value will shrink more than an item with a lower value.

So, as an alternate approach to your page, could achieve sizing by relying on `flex-shrink`, just:

```css
.column-main{
    flex: 66.67% /* 1 1 66.67% */
}
.column-sidebar {
    flex 33.33%
}
```

### Some practical uses

Can make use of `flex`in countless ways, can define proportional column using `flex-grow`values or `flex-basis`percentages as you did on your page. Can define fixed width columns and fluid columns that scale with the viewport.

### Flex direction

Another important option in flexbox is the ability to shift the direction of the axes -- The `flex-direction`prop -- applied to the flex container, controls this -- its initial value causes the items to flow left-to-right, as you've done. Specifying the 

`flex-direction: column`causes the flex items to stack vertically instead. Flexbox also support `row-reverse`to flow right to left, and `column-reverse`likewise.

### Changing the flex direction

What you need is for the two columns to grow if necessary to fill the container's height. To do so, turn the right column into a flex container with `flex-direction: column`then apply a non-zero `flex-grow`to both tiles within.

```css
.column-sidebar{
    display: flex;
    flex-direction: column;
}

.column-sidebar .tile {
    flex:1; /* apply flex-grow to items within */
}
```

Now have *nested flexbox* -- the element `<div class="column-sidebar">`is a flex item for the outer flexobx, and it's the flex container for the inner flexbox. And the inner flexbox here has a flex direction of `column`so the main axis is rotated. It flows from top to bottom. this means that for those flex items, -- `flex-basis, grow, shrink`now apply to the elemetn height.

When working with a vertical flexbox, the same general concepts for rows apply -- but there is one difference to keep in mind -- in CSS, working with height is just fundamentally different than working with widths. The height is just determined by its contents. This behavior does not change when rotate the main axis. The flex container's height is determined by its flex items, they fill it perfectly, in a vertical flexbox, flex-grow and shrink applied to the items wil have no effect unless sth else forces the height of the flex container to a specific size.

### Call Signatures

Interfaces and object types can declare call signatures, which is just a type system description of how a value may be called like a function. Only values that may be called in the way the call signature declares will be assignable to the interface. A call signature looks similar to a function type, but with : colon.

```tsx
type FunctionAlias = (input: string) => number;
interface CallSignature {
    (input: string): number;
}

// Type => number
const typedFunctionAlias: FunctionAlias = (input) => input.length; // ok

// interface
const typedCallSignature: CallSignature = (input) => input.length; //ok 
```

Call signatures can be used to describe functions that additionally have some user-defined prop on them. Ts will recognize a prop added to a function declaration as addint to that function declaration's type.

```tsx
interface FunctionWithCount{
    count: number;
    (): void;
}

let hasCallCount: FunctionWithCount;

function keepTrackOfCalls() {
    keepTrackOfCalls.count += 1;
    console.log(`${keepTrackOfCalls.count}`);
}
keepTrackOfCalls.count = 0;

hasCallCount = keepTrackOfCalls; //ok

function doesNotHaveCount() {
    console.log("no idea");
}
hasCallCount = doesNotHaveCount; // error missing count
```

