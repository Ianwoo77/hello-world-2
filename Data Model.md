# Data Model

```python
import collections

Card = collections.namedtuple("Card", ["rank", "suit"])


class FrenchDeck:
    ranks = [str(n) for n in range(2, 11)] + list("JQKA")
    suits = "spades diamonds clubs hearts".split()

    def __init__(self) -> None:
        self._cards = [Card(rank, suit) for suit in self.suits for rank in self.ranks]

    def __len__(self):
        return len(self._cards)

    def __getitem__(self, position):
        return self._cards[position]
```

`collections.namedtuple`to construct a simple class to represent individual cards. Builds classes of objects that are bundles of attributes with no custom methods. Just like dbs record.

For the `FrenchDeck`lass, can use `len()`func. like:

```python
deck = FrenchDeck()
len(deck) # 52
```

And reading specific cards from the deck , say the first or the last is easy to `__getitems__`.

```python
# create a method to pick like:
from random import choice
choice(deck)
```

For the `__getitem__`method -- delegates the `[]`operator. Automatically supports slicing. Can:

```python
deck[:3]
deck[12::13]
# can also iterate over the deck in reverse like:
for card in reversed(deck):
    print(card)
```

Iteration is often implicit. If a collection has no `__contains__`method, the `in`does a sequential scan just:

```python
Card('Q', 'hearts') in deck # True
```

About sorting, by rank, then by suit in spades, hearts, diamonds, and club. like:

```python
suit_values = dict(spades=3, hearts=2, diamonds=1, clubs=0)


def spades_high(card):
    rank_value = FrenchDeck.ranks.index(card.rank)
    return rank_value * len(suit_values) + suit_values[card.suit]


for card in sorted(deck, key=spades_high):
    print(card)
```

More often than not, the special method call is implicit. And if need to invoke a special method, it is usually better to call the related built-in function.

```python
import math


class Vector:
    def __init__(self, x=0, y=0) -> None:
        self.x = x
        self.y = y

    def __repr__(self):
        return f"Vector({self.x!r}, {self.y!r})"

    def __abs__(self):
        return math.hypot(self.x, self.y)

    def __bool__(self):
        return bool(abs(self))

    def __add__(self, other):
        x = self.x + other.x
        y = self.y + other.y
        return Vector(x, y)

    def __mul__(self, other):
        return Vector(self.x * other, self.y * other)
```

For the string representaion -- the `__repr__`special is called by the `repr()`to get the string representaion of the object of inspection. Note that, without a custom `__repr__`, Python’s console will display a Vector in hex. As does the `%r`placeholder in classic formatting with the `%`operator, and the `!r`conversion field in the new format string syntax used *f-string*s the `str.format`method.

The *f-string* uses `!r`to get the standard representation of the attributes to be displayed. Shows the crucial difference between like `Vector(1,2)`and `Vector('1', '2')`. And the string returned by `__repr__`should be unambiguous and if possible, match the source code necessary to re-create represented object. And the implementation inherited from the `object`class calls the `__repr__`as a fallback.

by default, if `__bool__()`is not implemented, py tries to invoke `x.__len__()`, and if that returns a zero, `bool`returns `False`. We convert the magnitude to a Boolean using `bool(abs(self))`cuz, `__bool__`is just expected to return a Boolean.

### Collection API

All the classes in the .. are **ABCs**. and the `collections.abc`module ae .. the goal of this brief to give a panoramic.

#### Container sequences

can hold items of different types, list, tuple, `collections.deque`. 

#### Flat sequences

Hold items of one simple type, `str, bytes, array.array`. The built-in concrete sequence types do not actually subclass the `Sequence`and `MultableSequence`abstract classes, but are just *virtual subclasses*.

```python
from collections import abc
issubclass(tuple, abc.Sequence)
issubclass(list, abc.MutableSequence)
```

### listcomps vs. map and filter 

listcomps do everything the `map`and `filter`functions do.

```python
symbols = '$¢£¥€¤'
beyond_ascii = list(filter(lambda c: c>162, map(ord, symbols)))
[ord(s) for s in symbols if ord(s)>162]
```

