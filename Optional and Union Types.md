## Optional and Union Types

Saw the `Optional`special type -- it solves the problem of having `None`as a default, as in this example like:

```python
from typing import Optional
def show_count(count:int, singular:str, plural: Optional[str]=None) -> str:
```

The construct `Optional[str]`is just actually a shortcut for `Union[str, None]`, which means the type of `plural`may be `str`or `None`. fore, the `ord`built-in function's signature is a simple example of `Union`-- it accepts `str`or bytes, and returns an `int`. like:

```py
def ord(c: Union[str, bytes]) -> int: ...
```

here is an example, takes `str`, but many return a `str`or `float`like:

```py
def parse_token(token:str) -> Union[str, float]:
    try:
        return float(token)
    except ValueError:
        return token
```

And, if possible, avoid creating funtions that return `Union`types, as they put an extra burden on the suer -- forcing them to check the type of the returned value at runtime to know what to do with it.

And, `Union[]`requires at least two types -- Nested `Union`types have the just same effect as a flattened `Union`. 

`Union[A, B, Union[C,D]]`==>` Union[A, B, C, D]` completely same

### Generic Collections

Most Py collections are heterogeneous -- fore, can put any mixture of different types in a `list`, in practice that is not very useful -- if you put objects in a collection, likely to want to operate on them later, and usually this mens they must share at least one common method.

For, Generic types can be declared with type parameters to specify the type of the items they can handle -- fore, a `list`can be parameterized to constrain the type of the elements in it as can see:

```py
def tokensize(text:str) -> list[str]:
    return text.upper().split()
```

In Py >= 3.9, it means that `tokenize`returns a list where every item is of type `str`. The annotations `stuff:list`and `stuff: list[Any]`mean the same thing -- `stuff`is a list of objects of any type.

Lists collections from the stdlib accpting generic type hints -- the following list just shows only those collections that use the simplest form of generic type hint --> `container[item]`.

`list, collections.deque, abc.Sequence, abc.MutableSequence, set, abc.Contaienr, abc.Set`
`abc.MutableSet, frozenset, abc.Collection`

### Tuple Types

There are 3 ways to annotate tuple types -- 

- As records
- as records with named fields
- as immutable sequences

```py
def goehash(lat_lon: tuple[float, float]) -> str:
    return ...
```

### Tuples as records with named fields

To annotate a tuple with many fields, or specific types of tuple your code -- just using the `typing.NamedTuple`.

```py
class Coordinate(NamedTuple):
    lat: float
    lon: float
    
def geohash(lat_lon: Coordinate) -> str:
    return...
```

### Tuples as immutable sequences

To annotate tuples of unspecified length that are used as immutable list, msut specify a single tpye, followed  ... like:

`tuple[int, ...]`is a tuple just with `int`items. The ellipsis indicates that any number of element >=1 is acceptable, there is no way to specify fields of different types for tuples of arbitrary length. fore:

```py
from collections.abc import Sequence

def columnize(sequence: Sequence[str],
              num_columns: int = 0) -> list[tuple[str, ...]]:
    if num_columns == 0:
        num_columns = round(len(sequence) ** 0.5)
    num_rows, reminder = divmod(len(sequence), num_columns)
    num_rows += bool(reminder)
    return [tuple(sequence[i::num_rows]) for i in range(num_rows)]
```

## Generic Mappings

Generic mapping types are annotated as `MappingType[keyType, valueType]`. The built `dict`and the mapping types in `collections`and `collections.abc`accept that notation in >=3.9. For eariler versions, U must use `typing.Dict`and others. Given starting and ending .. `name_index`returns a `dict[str, set[str]]`, which is an inverted index mapping each word to a set of characters that have that word in their names.

```py
import sys, re, unicodedata
from collections.abc import Iterator

RE_WORD = re.compile(r'\w+')
STOP_CODE = sys.maxunicode + 1


def tokenize(text: str) -> Iterator[str]:
    for math in RE_WORD.finditer(text):
        yield math.group().upper()


def name_index(start: int = 32, end: int = STOP_CODE) -> dict[str, set[str]]:
    # the local variable index is annotated
    index: dict[str, set[str]] = {}
    for char in (chr(i) for i in range(start, end)):
        if name := unicodedata.name(char, ''):
            for word in tokenize(name):
                index.setdefault(word, set()).add(char)
    return index
```

For `tokenize`is a generator function -- The local variable `index`is annotated, without the hint. Note that used the `:=`operator in the `if`condition -- it just assigned the result of the unicodedata.name() call to name.

### Abs Base Classes

Ideally, a function should accept args of those abs types -- or their `typing`equivalent before 3.9 fore:

```py
from collections.abc import Mapping
def name2hex(name: str, color_map: Mapping[str, int]) -> str:
```

Using `abc.Mapping`allows the caller to provide an instance of `dict, defaultdict, ChainMap, UserDict`subclass.

`def name2hex(name:str, color_map: dict[str, int])-> str:`

Now the `color_map`must be a `dict`or one of its subtypes, such as `defaultDict`or `OrderedDict`. Therefore, in general it's better to use `abc.Mapping`or `abc.MutableMapping`in parameter type hints, instead of `dict`.

### The fall of the numeric tower

The `numbers`package just defines the so-called *numeric tower* -- like:

`Number, Complex, Real, Rational, Integral`

In practice, if want to just annotate numeric args for static type checking have few options -- 

1. Use one of the concrete types `int, float`...
2. Declare a untion type like `Union[float, Decimal Fraction]`

### Iterable

The `typing.List`-- quoted recommens `Sequence`and `Iterable`for function parameter type hints. One example of the `Iterable`arg appears in the `math.fsum`like:

`def fsum(__seq: Iterable[float])-> float:`

```py
from collections.abc import Iterable

FromTo = tuple[str, str]  # type alias


def zip_replace(text: str, changes: Iterable[FromTo]) -> str:
    for from_, to in changes:
        text = text.replace(from_, to)
    return text
```

### Parameterized Generics and TypeVar

A parameterized generic is a generic type, written as `list[T]`, where `T`is a type variable that will be bound to a specific type with each usage. This allows a parameter type to be refelected on the result type. FORE:

```py
from collections.abc import Sequence
from random import shuffle
from typing import TypeVar

T = TypeVar('T')


def sample(population: Sequence[T], size: int) -> list[T]:
    if size < 1:
        raise ValueError('size must be >=1')
    result = list(population)
    shuffle(result)
    return result[:size]
```

Here are two examples of why used a *type variable* in `sample` -- 

- If called with a tuple of type `tuple[int, ...]`-- which is consitent-width `Sequence[int]`
- If called with `str`, return is just `list[str]`

For the `typing.TypeVar`, to introduce the variable name in the curerent namespace, Language such as java.. don't require the name of type variable to be declared beforehand.

```py
from collections import Counter
from collections.abc import Iterable


def mode(data: Iterable[float]) -> float:
    pairs = Counter(data).most_common(1)
    if len(pairs) == 0:
        raise ValueError('no mode for empty data structure')
    print(pairs)   # [(3,4)]
    return pairs[0][0]


mode([1, 1, 2, 3, 3, 3, 3, 4])
```

Many uses of `mode`involve `int`or `float`values, but Py has other numerical typs. And it is just desirable that the return type follows the element type of the given `Iterable`, can improve the signature using `TypeVar`:

```py
from collections.abc import Iterable
from typing import TypeVar

T= TypeVar('T')
def mode(data: Iterable[T])-> T:
    '''like upper'''
```

When it first appears in the signature, the type parameter `T`can be any type -- The second time it appears, it will just mean the same type as the first. Therefore, every iterable is *consistent-with* `Iterable[T]`, including iterables of unhashable types that `collections.Counter`cannot handle.

### Restricted TypeVar

And `TypeVar`accepts extra positional arguments to restrict the type parameter, can improve the signature of `mode`to accept specifc number types like:

```py
from collections.abc import Iterable
from decimal import Decimal
from fractions import Fraction
from typing import TypeVar

NumT = TypeVar('NumT', float, Decimal, Fraction)
def mode(data : Iterable[NumT]) -> NumT: #...
```

That is just better -- and it was the signature for `mode`in .. In hurray, can add `str`tot the `NumberT`definition like:

`NumT = TypeVar('NumT', float, ... str)`

### Bounded TypeVar

like:

```py
from collections.abc import Iterable, Hashable
def mode(data: Iterable[Hashable]): Hashable:
```

The problem is that the type of the returned item was -- `Hashable`-- Just an ABC that implements the `__hash__`method, sot the type checker will not let us do anything with the return value except call `hash()`on that.

The solution is another optional parameter of `TypeVar`-- the `bound`keyword parameter -- it sets an upper boundary for the acceptable types. have `bound=Hashable`-- which means that the type parameter may be `Hashable`or any *subtype* of that. like:

```py
from collections import Counter
from collections.abc import Iterable, Hashable
from typing import TypeVar

HashableT = TypeVar('HashableT', bound=Hashable) # may be Hashable or subtype of it


def mode(data: Iterable[HashableT]) -> HashableT:
    paris = Counter(data).most_common(1)
    if len(paris) == 0:
        raise ValueError('no mode for empty data')
    return paris[0][0]
```

To summarize -- 

- A restricted type variable will be set to one of the types anmed the `TypeVar`declaration
- A bound type variable will be set to the inferred type of the expression. As long as the inferred type is just consistent-with the boundary delcared in the `bound=keyword`argument of `TypeVar`.

The `typing.TypeVar`constructor has other optional parameters -- .

### The AnyStr predefined type variable

The `typing`module just includes a predefined `TypeVar`named `AnyStr`-- it's defined like:

`AnyStr= TypeVar('AnyStr', bytes, str)`

## Static Protocols

In oop, the concept of "protocol" as an informal interface is as old as .. and is an essential part of Py from the beginning, in the context of type hints -- a protocol is a `typing.Protocol`subclass defining an interface that a type checker can verify -- So the `Protocol`type -- is similar to interfaces in Go -- A protocol type is defined by specifying one or more methods, and the type checker verifies that those methods are implemented where the protocol type is required. 

And in Py, a protocol definition is written as `typing.Protocol`subclass. Howver, classes that implement a protocol don't need to inherit, register, or declare any relationship with the class that define that `protocol`. It's just up to type checker to find the available protocol types and enforce their usage.

Here is a problem that can be solved with the help of the `Protocol`and `TypeVar`. Fore, suppose U want to create a function `top(it, n)`-- returns largest n of the iterable it.

```py
def top(series: Iterable[T], length: int) -> list[T]:
    ordered = sorted(series, reverse=True)
    return ordered[:length]
```

The problem is that how to contain that `T`-- It cannot just be `Any`or `object`. Cuz the `Series`must work with `sorted` -- the built-in `sorted`actually accepts `Iterable[Any]`, but that is cuz the optional parameter `key`takes a function that computes an arbitrary sort key from each element. So, what happens if you give `sorted`a list of plain objects but don't provide a `key` -- The error message shows that `sorted`uses the `<`operator on the elements of the iterable.

That comfirms -- Can sort a list of `Spam`cuz `Spam`implements `__lt__`-- the special method that supports the `<`operator.

```py
from typing import Protocol, Any
class SupportLessThan(Protocol):
    def __lt__(self, other: Any)-> bool :...
        
LT = TypeVar('LT', bound=SupportLessThan)


def top(series: Iterable[LT], length: int) -> list[LT]:
    ordered = sorted(series, reverse=True)
    return ordered[:length]
```

Note that a protocol is just subclass of `typing.Protocol`, and the body of the protocol has one or more method definitions, whth ... in their bodies.

### Callable

To annotate callback parameters or callable objects returned by the high-order functions, the `collections.abc`module just provides the `Callable`type -- availble in the `typing`module for those not yet using 3.9. Like:

`Callable[ParameterType1, ParamType2], ReturnType]`

```py
from collections.abc import Callable
def repl(input_fn: Callable[[Any], str]= input) -> None:
```

And, if need a type hint to match a func with a flexible signature, replace the whole parameter list like:

`Callable[..., ReturnType]`

### Variance in Callable Types

Image a temperature control system with a simple `update`function -- 

```py
from collections.abc import Callable


def update(
        probe: Callable[[], float],
        display: Callable[[float], None]
) -> None:
    temperature = probe()
    display(temperature)


def probe_ok() -> int:
    return 42


def display_wrong(temperature: int) -> None:
    print(hex(temperature))


update(probe_ok, display_wrong)


def display_ok(temperature: complex) -> None:
    print(temperature)


update(probe_ok, display_ok)
```

Formally, say that `Callable[[], int]`is *subtype-of* `Callable[[], float]`-- as `int`just is `subtype`of `float`.

### NoReturn

This is a special type used only to annotate the return type of functions that never return like:

```py
def exit(__status: object=...) -> NoReturn ...
```

### Annotating Positional only and Variadic Parameters

like:

```py
def tag(
	name: str,
    /, 
    *content: str,
    class_: Optional[str]=None,
    **attrs: str
) -> str:
```

Note the type hint `*content:str`for the arbitrary positional parameters -- this just means all those arguments must be type `str`. And the `**attrs:str`-- therefore the type of `attrs`inside the function will be `dict[str, str]`. fore, 

`**attrs: float`-> `dict[str, float]`.

## Building your own Docker Images

Ran some containers in the last and Uses Docker to mange them -- Containers provide a consistent experience across applications, no matter what technoligy stack the app uses. Up till now you’ve used `Docker`images see how to build your own images -- this is where you will learn about the `Dockerfile`syntax, and some of the key patterns you will always use when U containerize your own apps.

### Using a certainer image from Docker Hub

U know from that `docker container run`will download the container image locally if isn’t already in your machine - cuz software distrubution is just built into the `Docker`platform, can leave Docker to manage this for you , pulls image when they are needed, or can just explicitly pull images using the Docker CLI -- 

```sh
docker image pull diamol/ch03-web-ping
```

And the image name is .. and it’s stored on Docker hub, which is the default location where Docker looks for images -- Image servers are called *registries* -- Docker Hub is a public registry you can use for free. Docker Hub also has a web interface.

There is some interesting output from the `docker image pull`command which shows you how images are stored-- A Docker image is logically one thing -- can think of it as a big zip file -- contains the whole app stack. This image has the `node.js`runtime together with app code.

During the pull don’t see one single sfile downloaded -- see lots of in progress -- those are called **image layers**.

```sh
docker container run -d --name web-ping diamol/ch03-web-ping
```

-d for `--deatch`, so this container will run in the background. The app runs like a batch job with no user interface. One new is `--name`which stands a *friend name*. This container is called `web-ping`, can use the name to refer to the container instead of using random ID.

The apps runs just in an endless loop, and can see just using the same `docker container`commands like:

```sh
docker container logs web-ping
```

Except -- the app can actually be configured to use a different URL, a different interval between requests, and even a different type of HTTP call. And 

*Environment variables* are just k/v pairs that the Os provides, they work in the same way on Windows and Linux. The `web-ping`just has some default values set for environment variables. When run a container, those environment variables are just populated by Docker, and that what the app uses to configure the website’s URL. Can specify different values for environment variables when create the container.

```sh
docker rm -f web-ping
docker container run --env TARGET=baidu.com diamol/ch03-web-ping
```

So this container is just doing sth different -- Didn’t use the `--detach`flag -- so the output from the app is shown on your console -- the container will keep runing until you end the app by pressing..

Environment variables are a very simple way to acheive that -- the web-ping app code looks for an environment variables with the key `TARGET`-- That key is set with a value in the image.. but can provide a different value with the `docker container run`command by just using the `--env`flag.

### Writing Dockerfile

the `Dockerfile`is a imple script you write to package up and application -- it’s a set of instructions, and a docker image is just the output. Dockerfile syntax is simple to learn,  As scripting languages go, common tasks have their own commands, and for anything custom you need to do , can use std shell commans - like:

```dockerfile
FROM diamol/node

ENV TARGET="baidu.com"
ENV METHOD="HEAD"
ENV INTERVAL="3000"

WORKDIR /web-ping
COPY app.js .

CMD ["node", "/web-ping/app.js"]
```

- `FROM`-- every image has to start from another, in this case, the `web-ping`will just use the `diamol/node`as starting point.
- `ENV`-- Set environment variables
- `WORKDIR`-- Creates a dir in the container image filesystem, and sets that to be the current working dirctory. Will create `/web-ping`.
- `COPY`-- Copies files .. from the local filesystem into the container image.
- `CMD`-- Specificies the command to run when `Docker`starts a container from the image.

### Building your own container image

Docker needs to know a few things before it can build an image from a `Dockerfile`-- It needs a name for the image, and it needs to know the location for all the files that it’s going to package into the image. like:

```sh
docker image build --tag web-ping .
```

The `--tag`just the name for the image and the final argument is the directory where the Dockerfile and related files are. Docker calls this dirctory the `context`-- and the period just use current directory.

```sh
docker image ls w*
```

Can use this image in exactly the same way as the one U just downloaded from the Docker hub. And the contents of the app are the saem. Can:

```sh
docker container run -e TARGET=docker.com -e INTERVAL=5000 web-ping
```

That container is running in the foreground, so need to stop that -- you have packaged a simple app to run in Docker, and the process is exactly the same for more complicated apps.

### Understanding the Docker images and Image layers

Get a better understanding of how images work, and the relationship between images and containers -- The docker image contains all the files you packaged, which *become the container’s filesystem*. And it also contains a lot of metadata about the imageitself.

```sh
docker image history web-ping
```

Output just for each image layer, there are the first fiew lines from the image. And the `Created by`commands are the `Dockerfile`creates an image layer -- going to dip into a little more -- understanding image layers is your key to making the most efficient use of Docker.

A Docker image is a logical collection of image layers -- Layers are just the files that are physically stored in the `Docker`Engine’s Cache -- images **can be shared between different images and different containers**. And, if you have lots of containes all runnign in the Node.js, will all share the same set of image layers that contain the `node.js`runtime.

For this, the `diamol/node`just has a slim os layer -- then `Node.Js`runtime. And the Linux image taks up about 75MB of disk -- `docker image ls`, Can use the `docker system df`shows just exactly how much disk space docker is using.

One last -- if image layers are shared around, can’t be edited -- otherwise a change in one image would cascade to all the other images.

### Optimizing Dockerfile to use the image layer cache

there is a layer of web-ping image that contains the app’s Js file - make change that file get a new layer. Docker just assumes the layers in a docker image follows a defined sequence, so change a layer in the middle, doesn’t assume it can reuse the later layers.

```sh
docker image build -t web-ping:v2 .
```

Step 2 through 5 use layers from the cache, and step 6, 7 generates new.

If there is no match for the hash in the existing image layers, Docker executes the instruction and that breaks the cache, As soon as the cache is broken, Docker executes all the instructions that follow. For this, the `app.js`file has changed since the last build, so the `COPY`in step 6 needs to be run.

NOTE -- there are only 7 instructions in the Dockerfile, but can still be optimized. The `CMD`doesn’t need to be at the end of the Dockerfile -- Can be anywhere after the `FROM`. Can move nearer to the top. Like:

`docker image build -t web-ping:v2`

Won’t notice too much difference from the previous build -- there are just now five steps instead of 7. Can see the Dockerfile syntax and the key instructions you need to know -- how to build and work with images from CLI.