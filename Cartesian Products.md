# Cartesian Products

Listcomps can build its lists from the Cartesian product of two or more iterables.

```python
colors= ['black', 'white']
sizes= ['S', 'M', 'L']
tshirts = [(color, size) for color in colors for size in sizes]
tshirts
```

### Generator expressions

Genexps use the same syntax as listcomps, but are enclosed in `()`rather then `[]`.

```python
symbols = '$¢£¥€¤'
tuple(ord(symbol) for symbol in symbols)

import array
array.array('I', (ord(symbol) for symbol in symbols))

for tshirt in (f'{c} {s}' for c in colors for s in sizes):
    print(tshirt)
```

Tuples are NOT just Immutable Lists -- Tuples do double duty 

1. Hold records. For the quantity and the order of the items may or may not be important. Like:

```python
lax_coordinates= (33.9425, -118.408056)
city, year, pop, chg, area= ('Tokyo', 2003, 32450, 0.66, 8014)
traveler_ids=[('USA', '31195855'), ('BRA', 'CE342567'),
              ('ESP', 'XDA205856')]
for passport in sorted(traveler_ids):
    print('%s/%s' % passport)

for country, _ in traveler_ids:
    print(country)
```

### Unpacking Sequences and Iterables

Unpacking is important cuz it avoids unnecessary and error, prone use of indexes to extract elements from sequences, unpacking works. Use arg with `*`when calling a function like:

```python
q, r = divmod(*(20,8))
q, r
import os
_, filename = os.path.split('home/luciano/.ssh/id_rsb.pub')
filename
```

#### Use `*`to grab excess items

```python
etro_areas = [
    ("Tokyo", "JP", 36.933, (35.689722, 139.691667)),
    ("Delhi NCR", "IN", 21.935, (28.613889, 77.208889)),
    ("Mexico City", "MX", 20.142, (19.433333, -99.133333)),
    ("New York-Newark", "US", 20.104, (40.808611, -74.020386)),
    ("São Paulo", "BR", 19.649, (-23.547778, -46.635833)),
]


def main():
    print(f'{"":15} | {"lat":>9} | {"long":>9}')
    for name, _, _, (lat, lon) in metro_areas:
        if lon <= 0:
            print(f"{name:15} | {lat:9.4f} | {lon:9.4f}")

if __name__=='__main__':
    main()
```

1. The subject is a sequence and
2. The subject and the pattern have the same number of items
3. Each corresponding item matches, including nested items.

```python
phone = '13935253366'
match tuple(phone):
    case ['1', *rest]:
        print(*rest, sep='')
```

### Slicing

A common feature of list, tuple, str, and all sequence types in Python is the support of slicing operations.

Mordern dict syntax -- A dictcomp builds a dict instance by taking `kay:value`pairs from any iterable. like:

```python
dial_codes = [                                                  
     (880, 'Bangladesh'),
     (55,  'Brazil'),
     (86,  'China'),
     (91,  'India'),
     (62,  'Indonesia'),
     (81,  'Japan'),
     (234, 'Nigeria'),
     (92,  'Pakistan'),
     (7,   'Russia'),
   ]
country_dial = {country:code for code, country in dial_codes}
```

### Unpacking Mappings -- 

Can apply `**`to more then one arg in a function call. This work when keys are all strings and unique across all arguments. Like:

```python
def dump(**kwargs):
    return kwargs
dump(x=1, y=2, **{'z':3})
```

And, `**`can also be used inside a dict literal, also multiple times like:

```python
{'a':0, **{'x': 1}, 'y':2, **{'z':3, 'x':4}} # x:4
```

Merging with `|`like:

```python
d1= {'a':1, 'b':3}
d2= {'a':2, 'b':4, 'c':6}
d1 | d2 # often the new mapping will be the same as the type of the left operand
```

### Inserting or Updating Mutable Values

```python
import re
import sys

WORD_RE = re.compile(r"\w+")
index = {}
with open(sys.argv[1], encoding="utf-8") as fp:
    for line_no, line in enumerate(fp, 1):
        for match in WORD_RE.finditer(line):
            word = match.group()
            column_no = match.start() + 1
            location = (line_no, column_no)
            index.setdefault(word,[]).append(location)
```

Just get the list of occurrences for `word`, or set it to `[]`if not found

### Data class

Py offers a few ways to build a simple class that is just a collection of fields. `collections.namedtuple`, `typing.NamedTuple`, and `@dataclasses.dataclass` -- A class decorator that allows more customization than previous alternatives. like some like:

```python
class Coordinate:
    def __init__(self, lat, lon) -> None:
        self.lat = lat
        self.lon = lon, lat, lon
```

And built it with `namedtuple`like:

```python
from collections import namedtuple
Coordinate= namedtuple('Coordinate', 'lat lon')
issubclass(Coordinate, tuple)
```

And the newer `typing.NamedTuple`provides the same functionality, adding a type annotation to each field.

```python
import typing
Coordinate= typing.NamedTuple('Coordinate', 
                              [('lat', float), ('lon', float)])
# or
Coordinate = typing.NamedTuple('Coordinate', lat=float, lon=float)
```

Can be also used in a `class`statement like: This is obviously much more readable.

```python
from typing import NamedTuple

class Coordinate(NamedTuple):
    lat: float
    lon: float

    def __str__(self) -> str:
        ns = "N" if self.lat >= 0 else "S"
        we = "E" if self.lon >= 0 else "W"
        return f'{abs(self.lat):.1f} {ns}, {abs(self.lon):.1f} {we}'
```

For the classic Named Typles -- the `collections.namedtuple`function is a factory that builds subclasses of `tuple`enchanced with the field names.