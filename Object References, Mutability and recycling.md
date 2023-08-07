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
