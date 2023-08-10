## Formatted Displays

The f-strings, the `format()`built-in function, and the `str.format()`method delegate the actual actual formatting to each type by calling `.__foramt__(foramt_spec)`method -- is a formatting specifier, which is either.

- The second arg in `format(my_obj, format_spec)`or
- whatever appears after the colon in a replacement with `{}`inside an f-string or the `fmt`

A few built-in types have their own presentation codes in the Format Specification mini-language, -- among several other codes, the `int`type suports `b`and `x`for base 2 and 16 output, respectively, while `float`implements `f`for a fixed point display and % for a percentage display.

```py
format(42, 'b')
format(2/3, '.1%')
```

Fore, the classes in the `datetime`module just use the same format codes in the `strftime()`functions and in their `__format__`methods -- here are a couple of examples using the `format()`built-in and `str.format()`method.

```py
from datetime import datetime
now = datetime.now()
format(now, '%H:%M:%S')
"it's now {:%I:%M:%p}".format(now)
```

```py
def __format__(self, format_spec=''):
    components = (format(c, format_spec) for c in self)
    return '({}, {})'.format(*components)
```

And to generate polar coordinates, already have the `__abs__`method for magnitude, code a simple `angle`method using the `math.atan2()`

### A hashable Vector2d

As defined, so far our `Vector2d`instances are unhashable, can't put them in a set so. To make it hashable, must implement `__hash__`and `__eq__`is also required -- like;

```py
def __init__(self, x, y):
    self.__x = float(x)
    self.__y = float(y)

@property
def x(self):
    return self.__x

@property
def y(self):
    return self.__y

def __iter__(self):
    return (i for i in (self.x, self.y))
```

1. Use exactly two leading underscores to make an attribute private..
2. `@property`decorator marks the getter method of a property
3. The getter method is named after the public property is expose x

Now that are reasonably safe from accidential mutation, can just implement the `__hash__`method, should return an `int`and ideally take into account the hashes of the object attributes that are also used in the `__eq__`method, cuz objects that compare equal should have the same hash -- The `__hash__`special method suggests computing the hash of tuple with the components like:

```py
def __hash__(self):
    return hash((self.x, self.y))
```

### Supporting Positional Pattern Matching

So far, `Vector2d`instance are just compatible with keyword class patterns, covered -- 

```py
@classmethod
def frombytes(cls, octets):
    typecode=chr(octets[0])
    memv = memoryview(octets[1:]).cast(typecode)
    return cls(*memv)
```

### Private and Portected Attributes in Py

In py, there is just no way to create private variables like there is the `private`modifier --  to prevent this, if name an instance attribute in the form `__mood`-- Py just stores the name in the instance `__dict__`prifixed with a leading underscore and the class name, so in the `Dog`class, `__mood`just becomes the `_Dog__mood`.

### Saving Memory with `__slots__`

By default, Py stores the attributes of each instance in a `dict`named `__dict__`-- a `dict`has a significant memory overhead -- even with the optimizations mentioned in that section -- if you deine a class attribute named `__slots__`, holding a sequence of attribute names -- py uses an alternative storage model for the instance attributes. like:

```py
class Pixel:
    __slots__=('x', 'y')
p= Pixel()
p.__dict__ # attributeEror
p.x=10...
```

1. `__slots__`must be present when the class is created -- adding or changing it later has no effect -- the attribute names may be a `tuple`or `list`.
2. Create an instance of `Pixel`

```py
class ColorPixel(Pixel):
    __slots__=('color',)
cp = colorPixel()
cp.x=2
cp.color='blue'
```

1. Essentially, `__slots__`of the superclsses are added to the `__slots__`of the current class
2. `ColorPixel`instances also have no `__dict__`.
3. Can set the attributes declared in the `__slots__`of this class and superclasses.

### Overriding Class Attributes

A distinctive feature of Py is how class attributes can be used as default values for instance attributes.

## Special methods For Sequences

Will create a class to represent a multidimensional Vector class 

- Basic seq protocol -- `__len__`and `__getitem__`
- Safe representation of instance with many items
- Proper slicing support, producing new `Vector`instances.
- Aggregate hashing, taking into account every contained element value.
- Custom formatting language extension

Also implement dynamic attributes access with `__getattr__`as a replacing of the read-only properties we used in `Vector2d`

```py
class Vector:
    typecode = 'd'

    def __init__(self, components):
        self._components = array(self.typecode, components)

    def __iter__(self):
        return iter(self._components)

    def __repr__(self):
        components = reprlib.repr(self._components)
        components = components[components.find('['):-1]
        return f'Vector({components})'

    def __str__(self):
        return str(tuple(self))

    def __bytes__(self):
        return (bytes[ord(self.typecode)]) + bytes(self._components)

    def __eq__(self, other):
        return tuple(self) == tuple(other)

    def __abs__(self):
        return math.hypot(*self)

    @classmethod
    def frombytes(cls, octets):
        typecode = chr(octets[0])
        memv = memoryview(octets[1:]).cast(typecode)
        return cls(memv)
```

Use the `reprlib.repr()`to get a limited-length representation of `self._components`.

### Protocols and Duck Typing

In the context of OOP, a protocol is an information interface -- defined only in the documentation and not in code. Fore, the sequence protocol in py entails just the `__len__`and `__getitem__`methods -- any class that implements those methods with the std signature and sematntics can be used anywhere a sequence is expected. Just like: 

```py
class FrenchDeck:
    ...
    def __len__(self):
        return len(self._cards)
    def __getitem__(self, pos):
        return self._cards[pos]
```

So it just implements the seq protocol -- even if this is not just declared anywhere in the code, an experienced Py code will look at it and understand that it *is* a seq, even if it subclsses `object`. This became known as a *duck typing*.

### #2: A slicable Seq

As swas -- really esy if can delegate to a sequecne attribute in your object -- like :

```py
def __len__(self):
    return len(self._components)

def __getitem__(self, index):
    return self._components[index]
```

How slicing works -- 

```py
class MySeq:
    def __getitem__(self, index):
        return index
```

`s[1:4]`just return a` slice(1,4,None)`

1. `slice`is just a built-in type
2. Inspecting a `slice`will find the data attributes `start, stop, step`, and an `indices`method.

A slice-aware `__getitem__`-- 

```py
def __getitem__(self, index):
    if isinstance(index, slice):
        cls=type(self)
        return cls(self._components[index])
    i = operator.index(index)
    return self._components[index]
```

### Dynamic Attribute access

In the evoluation from `Vector2d`to `Vector`, lost the ability to access vector compnents by name, we are now dealing with vectors that may have a large number of components. we could write just 4 properties in `Vector`, that is tedious -- the `__getattr__`special method provides a better way -- invoked by the interpreter *when attribute lookup fails*. In simple terms, given the expression `my_obj.x`, py checks if the `my_obj`instance has an attribute named `x`-- the search goes to the class and then up the inheritance graph -- then the `__getattr__`method defined in the class of `my_obj`is called with `self`and the anme of the attributes.

```py
def __getattr__(self, name):
    cls = type(self)
    try:
        pos = cls.__match_args.index(name)
    except ValueError:
        pos = -1
    if 0 <= pos < len(self._components):
        return self._components[pos]
    msg = f'{cls.__name__!r} object has no attribute {name!r}'
    raise AttributeError(msg)
```

1. set `__match_args`to allow positional patern matching on the dynamic attributes supported by `__getattr__`.
2. Get the `Vector`for later use, then `.index(name)`raise just the `ValueError`when name is not found, so pos to -1

But, the inconsistency in this ws just introduced cuz the way of `__getattr__`works -- Py only calls that methods as a fallback, when the object does not have the named attribute -- however, after assign v.x=10 We need to customize the logic  for setting attributes in our `Vector`class in order to avoid inconsistency.

```py
def __setattr__(self, key: str, value):
    cls = type(self)
    if len(key) == 1:
        if key in cls.__match_args:
            err = 'readonly attribute'
        elif key.islower():
            err = "can't set attribute 'a' to 'z'"
        else:
            err = ''
        if err:
            msg = err.format(cls_name=cls.__name__, attr_name=key)
            raise AttributeError(msg)
    super().__setattr__(key, value)
```

The `super()`function provides a way to access methods of superclasses dynamically, a necessary in a dynamic lang supporting multiple inheritance like PY.

### Hashing and Fater ==

Once more, get to implement a `__hash__`method -- together with the existing `__eq__`, will make that hashable. The `__hash__`in `Vector2d`computed the hash of a `tuple`built with the two components. The `__hash__`computed the has of a `tuple`built with the two components, so building a `tuple`may be too costly, Instead, just will apply the `^`operator to the hashes of every component in succession.

The key is to reduces a series of values to a single value, the first arg to `reduce()`is a two-argument function and the second arg is just an iterable. like:

`functools.reduce(labmda a, b: a*b, range(1,6))`

```py
import functools
functools.reduce(lambda a, b: a^b, range(6))
```

```py
def __hash__(self):
    hashes = (hash(x) for x in self._components)
    return functools.reduce(operator.xor, hashes, 0)
```

1. No change to `__eq__`, listed it here cuz it's a good practice to keep `__eq__`and `__hash__`close in source code, cuz they need to work together.
2. Create a generator expression to lazily compute the hash of each component.

And the mapping step produces one hashes for each component, and the reduce step aggregates all hashes with the `xor`operator, using `map`instead of a `genexp`. like:

```py
def __hash__(self):
    hashes = map(hash, self._components)
    return functools.reduce(operator.xor, hashes)
```

## Interfaces Protocols and ABCs

OOP is all about interfaces -- best approach to understanding a type in py -- knowing the methods it provides -- its interface -- Depending on the programming language, have one ro more ways of defiing and using interfaces.

*Goose typing* -- The approach supported by ABCs, which relies on runtime checks of objects against ABCs, *Goose typing* is a major subject -- 

*static typing* -- the traditional approach of statically-typed language like C and Java -- supported since 3.5's `typing`module.

### Two kinds of Protocols

Fore, implementing the `__getitem__`is enough to allow retrieving items by index, and also to support iteration and the `in`operator -- the `__getitem__`special method is really the key to the sequence protocol.

- Dynamic protocol -- The informal protocols always had -- are implicit, definedin by congention, and described in the documentation.
- static protocol-- This defed since 3.8, a static has an explicit definition -- a `typing.Protocol`subclass

And there are two key differences between them -- 

- An object may implement only part of a dynamic protocol and still be useful, but to fulfill a static protocol, the object must provide every method decalred in the protocol class
- Static protocols can be verified by static type checkers.

### Goose Typing

Py doesn't have an `interface`but have ABCs-- to define interfaces for explicit type checking at runtime.

- Subclassing from ABCs to make it explicit that you are implementing a previously defined interface.
- Runtime type checking using `ABCs`instead of concerete classes as the second argument for `isinstance`and `issubclass`.

And the use of `isinstance`and `issubclass`becomes more acceptable if you are checking against ABCs instead of concrete classes -- if used with concrete classes, type checks limit polymorphism. It's usually NOT ok to have a chain of if/elif/else... with `isinstance`checks performing different actions depending on the type of object.

On the other hand, it's ok to perform an `isinstance`check against an ABC if you must enforce an API contract -- have to implement this if want to call me.

### Subclassing an ABC

Following -- leverage an existing ABC-- `collections.MutableSequence`-- like:

```py
from collections import namedtuple, abc

Card = namedtuple('Card', ['rank', 'suit'])


class FrenchDeck2(abc.MutableSequence):
    ranks = [str(n) for n in range(2, 11) + list('JQKA')]
    suits = 'spades diamonds clubs hearts'.split()

    def __init__(self):
        self._cards = [Card(rank, suit) for suit in self.suits
                       for rank in self.ranks]

    def __len__(self):
        return len(self._cards)

    def __getitem__(self, item):
        return self._cards[item]

    def __setitem__(self, key, value):
        self._cards[key] = value

    def __delitem__(self, key):
        del self._cards[key]

    def insert(self, pos, value):
        self._cards.insert(pos, value)
```

Cuz -- subclassing of `MutableSequence`forces us to implement the `__delitem__`, an abs method of that ABC. And, also need to implement the `insert`.

### ABCs in STDLIB

- `Iterable, Container, Sized`-- Every collection should either inherit from these ABCs, or implement compatible protocols, `Iterable`supports iteration with `__iter__`, Container supports the `in`opertaor with `__contains__`, and `Sized`supports `len()`with `__len__`.
- `Collection`-- This ABC has no methods of its own -- Make it just easier to subclass from `Iterable, ...`
- `Sequence, Mapping, Set`-- There are just the main immutable collection types, and each has a mutable subclass. A detailed diagram for `MutableSequence`, for MtuableMapping and MutableSet.
- `MappingView`-- In 3, the objects returned from the mapping methods `.items(), .keys()`and `.values()`implement the interfaces defined in the `ItemsView`.. and `ValuesView`, respectively.
- `Iterator`-- Iterator subclasses `Iterable`
- `Callable, Hashable`-- these are not collections, but `cllections.abc`was first package to define ABCs in the std lib, and these two were deemed important enough to be included. They support type checking objects that must be callable or hashable.

### Defining and using an ABC

To justify creating an ABC, need to come up with a context for using it as an extension point in a framework -- so there is our contet -- imagine you need to display advertisements on the website or a mobile app in random order.

```py
class Tombola(abc.ABC):
    @abc.abstractmethod
    def load(self, iterable):
        '''Add items from an iterable'''

    @abc.abstractmethod
    def pick(self):
        '''remove item at random and returning it'''

    def loaded(self):
        '''returning '`true` if there is at least 1 item'''
        return bool(self.inspect())

    def inspect(self):
        '''return a stored tuple with the items currently inside'''
        items = []
        while True:
            try:
                items.append(self.pick())
            except LookupError:
                break
        self.load(items)
        return tuple(items)
```

1. To define an ABC, subclass `abc.ABC`
2. An abstract method is mared with the `@abstractmethod`decorator, and often its body is empty except for docstring.
3. The docstring instructs implementers to raise `LookupError`if there are no items to pick.
4. An ABC may include concrete methods.

Now have just very own ABC, to witness the interface checking performed by an ABC, just try to fool -- .

```py
class Fake(Tombola):
    def pick(self):
        return 13
```

`TypeError`is raised when we try to instantiate `Fake`-- The message is very clear -- `Fake`is considered abstract cuz it failed to implement `load`.

### ABC Syntax Details

The std way to declare an ABC is to just subclass abc.ABC, or any other ABC. Besides the `ABC`base class, and the `@abstractmethod`decorator, the `abc`module defines the `@abstractclassmethod`-- `@abstractstticmethod`, and `@abstractproperty`decorators, deprecated in py 3.3, when it became possible to stack decorators on top of `@abstractmethod`make the others redundant. just like:

```py
class MyABC(abc.ABC):
    @classmethod
    @abc.abstractmethod
    def an_abstract_classmethod(cls, ...):...
```

### Subclassing an ABC

Given the ABC, now develop two concrete subclasses that satisfy its interface just. These classes were just along with the virtual subclass to be discussed in the next section -- like:

```py
import random


class BingoCage(Tombola):
    def __init__(self, items):
        self._randomizer = random.SystemRandom()
        self._items = []
        self.load(items)

    def load(self, items):
        self._items.extend(items)
        self._randomizer.shuffle(self._items)

    def pick(self):
        try:
            return self._items.pop()
        except IndexError:
            raise LookupError('pick from empty BingoCage')

    def __call__(self, *args, **kwargs):
        self.pick()
```

### A virtual Subclass of an ABC

An essential characteristic of goose typing -- and one reason why it deserves a waterfowl name -- is the ability to register a class as a *virtual subclass* of an ABC -- Even if it does not inherti from it -- when doing so, promise that the class faithfully implements the interface defined in the ABC, and Py will believe us without checking.

This is done by calling a `register`class method on the `ABC`-- the registered class then just becomes a virtual subclass of the ABC, and will be recognized as such by `issubclass`.

The `register`method is usually invoked as a plain function, but can also be used as a decorator, uset use the decorator syntax and implement.

```py
@Tombola.register
class TomboList(list):
```

TomobList is just registered as a vritual sublass of `Tombola`.

### usage of register in practice

Use the `Tobola.register`as a class decorator, prior to py 3.3, `register`could not used like -- it's just more widely deployed as a function to register classes defined elsewhere, fore, for the `collections.abc`module, the `tuple, str, range, and memoryview`are just registered as virtual subclsses of `Sequence`like:

`Sequence.register(tuple)`, str, range...

Serveral other built-in types are registered to ABCs in `_collections_abc.py`.Those registrations happen only when that module is imported, which is OK cuz you will have to import it anywhere to get the ABCs.  Subclassing an ABC or registering with an ABC are both explict ways of making your classes pass `issubclass`checks.

## Primer part 1

```sh
ng new Primer --routing false --style css --skip-git --skip-tests
```

Next, just run the command in the folder, to just add the `Bootstrap`css package to the project -- this is the package that use to manage the appearance of congent throughout the book.

```sh
npm install bootstrap
```

Then need to include the bootstrap in the project’s stylesheet files.

### Quoting Lteral values in attributes

Angular reles on HTML element attributes to apply a lot of its functionality -- mot of the attributes are evaluated as Js expressions. like:

`<td [ngSwitch]="item.complete">`

The attribute applied to the `td`element tells Anguar to read the value of a property called `complete`on an object. There will be occations when you need to provide a specific value rather than have Angular read a value from the data model, and this requires additional quoting to tell Angular that it is dealing with just a literal value like:

`<td [ngSwitch]="'Apples'">`

## SportsStore: A real Application -- 

```sh
npm install --save-dev json-server
npm install --save-dev jsonwebtoken
```

It is important to use the version numbers -- Some of the packages are installed uing the `--save-dev`arg -- indicates they are used during just development and will not be part of the appliation.

### Preparing the RESTful web services

The app will use async HTTP rquest to get model data provided by a RESTful web services -- Added the `json-server`package to the project in the previous section -- this is just an excellent package for creating web services from JSON or js code, add the statement -- like:

`"json": "json-server data.js -p 3500 -m authMiddleware.js"`

To provide the `json-server`package with data to work with, added a file called `data.js`in the folder and added the code which will ensure that same data is available whenever the `json-server `package is started.

```js
module.exports= function() {
    return {
        products:[{}],
        orders:[],
    }
}
```

Code just defines two data collections that will be represented by the RESTful web service, the `products`collection contains the products for sale to the customer, while the `orders`collection will contains the orders that customers have placed. The data stored in the RESTful serivce needs to be protected so that oridinary users can’t modify the products or change the status of orders -- the `json-server`package doesn’t include any built-in feature -- so created a file called `authMiddleware`in the folder and added the code like:

```js
const jwt = require('jsonwebtoken')

const APP_SECRET = 'myappsecret';
const USERNAME = 'admin';
const PASSWORD = 'secret';

const mappings = {
  get: ['/api/orders', "/orders"],
  post: ['/api/products', "/products", "/api/categories", "/categories"]
}

function requireAuth(method, url) {
  return (mappings[method.toLowerCase()] || [])
    .find(p => url.startsWith(p)) !== undefined;
}
```

This code just inspects HTTP requests sent to the RESTful web service and implements some basic security features -- this is server-side code -- not directly related to the Ng development.

### Preparing the HTML File

Every app reles on an HTML file that is loaded by the browser and that loads and starts the application. `index.html`file in the /src folder and:

An important part of setting an Ng is to create the folder structure -- the `ng new`command sets up just a project that puts all of the application’s files in the `src`-- with the Ng files in the `src/app`folder.

- `/model`-- will contain the code for the data model.
- `/store`-- contain the functionality for basic shopping
- `/admin`-- contain the functionality for administration

### Starting the RESTful web service

To start the RESTful web service, open a new command, and navigate to the foler just:

`npm run json`

preparing the Angualr project Features -- Every angualr project just requires some basic preparation -- In the section, replace the placehodler content build the fundation for the appliation.

### Updating the root Component

The root is the ng building block that will manage the contents of the `app`element in the HTML document. An app can contain many components, but there is aways a root component that take reposibility for the top-level content presented to the user. `app.component.ts`file like:

```tsx
@Component({
  selector: 'app',
  template: `<div class="bg-success p-2 text-center text-white">
    This is SprotsStore
  </div>`
})
```

The `@Component`decorator tells ng that the `AppComponent`class is a component, and its properties configure how the component is applied, all the component properties are but the properties in this listing are the most basic and most frequently used. the `selector`tells ng how to apply the component in the HTML document, and the `template`prop defines the HTML content the component will display.

### Inspecting the Root Module -- 

There are two types of Ng modules -- *feature moodules* and the *root* modules. Feature modules are used to group related app functionlaity to make the app easier to mange, create feature for each major functional area of the app, including the data model, the store interface presented to the users, and administration interface.

And the root module is used to describe the app to Angular -- the description includes which feature modules are required to run the app , which features should be loaded.

The conventional name of the root module file is just the `app.module.ts`, which is created in the `SportsStore/src/app`folder. The root module only really exists to provide info through the `@NgModule`decorator, the `imports`property tells Anguar that it should load the `BrowserModule`feature module, which contains the core Ng features required for a web appliation.

The `declarations`tells that it should load the root component, the `providers`tells shared bojects used by the app, and the `bootstrap`tells ng that the root is the `AppComponent`object.

### Insepcting the bootstrap File

The next piece of plumbing is the bootstrap file -- which just starts the app. The Ng platform can be just ported to different environments. The bootstrap file uses the ng browser platform to load the root module and start the app, no changes are required for the content of the `main.ts`.

### Starting the Data Model

The best place to -- Want to get ot the point where you can just see some ng features at work. going to put some basic functionality in place using dummy data.

Creating the model class -- every data model needs classes that describe the types of data that will be contained in the data model, ofre the app, this means the classe that describe the product sold in the store and the orders received form customers.

And, being able to describe products will be enough to get started with the app, create other model classes to support features created `product.model.ts`

```tsx
export class Product {
  constructor(
    public id?: number,
    public name?: string,
    public category?: string,
    public description?: string,
    public price?: number
  ) {
  }
}
```

Which correspond to the structure of the data used to populate the RESTful web service.

Creating the Dummy data source -- 

```tsx
@Injectable()
export class StaticDataSource {
    private products: Product[]=[];
    getProducts(): Observable<Product[]> {
        return from([this.products]);
    }
}
```

`getProducts()`method returns the dummy data, The result of calling the `getProducts()`method is an `Observable<Product[]>`produces arrays of `Product`objects. Just providedy by Rxjs -- is used by Angular to just handle state changes in apps. Just represents an async task that will produce a result at some point in the future. Ng exposes its use of `Observable`objects for some features, including making HTTP requests.

Note that the `@Injectable()`used to tell ng that this class will be used as a service, which allows other classes to access its functionality through feature called DI.