## Usage of resgiter in practice

`register`could not be used like that -- had to called as a plain function after the clas definition. It's more widely deployed as a fucntion to register classes defined elsewhere -- like:

`Sequence.register(tuple); Sequence.register(str)`

Subclassing an ABC or registering with an ABCs are both explicit way of making our classes pass `issubclass`checks, as well as `isinstance`check, which also rely on `issubclass`.

### Structural Typing with ABCs

ABCs are mostly used with nominal typing -- when a class `Sub`explicitly inherits from `AnABC`, or is **registered** with `AnABC`, then the name of `AnABC`linked to the `Sub`class, and that is how at runtime, `issubclass(AnABC, Sub)`return `True`. In contrast, structural typing is just about looking at the structure of an object's public interface to determine its type -- an object is consistent-with a type if implement the methods defined in the type. like:

```py
class Struggle:
    def __len__(self) : return 23
from collections import abc
isinstance(Struggle(), abc.Sized)
issubclass(Struggle, abc.Sized)
# both True
```

Here, class `Struggle`is considered a subclass of `abc.Sized`by the `issubclass`function, cuz `abc.Sized`implments a special class method named `__subclasshook__`-- for `Sized`check whether the class argument has an attribute just named `__len__`like:

```py
class Sized(metaclass=ABCMeta):
    __slots__=()
    @abstractmethod
    def __len__(self): return 0
	@classmethod
    def __subclasshook__(cls, C):
        if cls is Sized:
            if any("__len__" in B.__dict__ for b in C.__mro__):
                return True
        return NotImplemented
```

### Static Protocols

When introducing Py to programmers more used to statically typed languages, one of favorite examples is the simple `double`function like:

```py
def double(x) : return x*2
```

Before static protocols were introduced, there was no partical way to add type hints to `double`without limiting its possible uses. 

For the duck typing, `double`works even with types from the future, like: The name of a type in an annotation had to match the nme of the type of the actual arguments -- or the name of one of its suplerclasses -- since possible to name all types that implement a protocol by supporting the required opertions, duck typing could not described by type hints before 3.8.

```py
from typing import TypeVar, Protocol

T = TypeVar('T')


class Repeatable(Protocol):
    def __mul__(self: T, repeat_count: int) -> T: ...


RT = TypeVar('RT', bound=Repeatable)


def double(x: RT) -> RT:
    return x * 2
```

1. Using `T` in the `__mul__`signature.
2. `__mul__`is the essence of the `Repeatable`protocol, the `self`is usually not annotated, it's type is assumbed to be the class -- here, use `T`to just make sure the result type is same as the type of `self`.
3. The `RT`is bounded by the `Repeatable`protocol, the type checker will require that the actual type implements `Repeatble`.

In the typing Map, `typing.Protocol`appears in the static checking area -- the bottom half of the diagram. Can use the `@runtime_checkable`decorator to make the protocol support `isinstance/issubclass`checkes at runtime.

As of 3.9, the `typing`module includes 7 ready-to-use protocols that are runtime checkable -- fore:

`typing.SupportComplex`and `typing.SupportsFloat`-- these are designed to check numeric for convertibility, if an object o implements `__complex__`then should be able to get a `complex`by invoking `complex(O)`-- cuz the `__complex__`special method exists to support the `complex()`built-in function like:

```py
@runtime_checkable
class SupportsComplex(Protocol):
    __slots__=()
    
    @abstractmethod
    def __complex__(self)-> complex:
        pass

from typing import SupportsComplex
import numpy as np
c64= np.complex64(3+4j)
isinstance(c64, complex) # False
isinstance(c64, SupportsComplex) #True
```

## Inheritance -- For better or for Worse

- The `super()`func
- The pitfalls of subclassing from built-in types
- multiple inheritance and method resolution order
- Mixin classes

### The `super()`

Is essential for maintainable OOP like: When a subclass overrides a method of a superclas, the overriding method usually needs to call the corresponding method of the superclass, there is the recommanded way do it like:

```py
class LastUpdatedOrderedDict(OrderedDict):
    def __setitem__(self, key, value):
        super().__setitem__(key, value)
        self....
```

1. Use the `super().__setitem__`to call that method on the superclas

And, invoking an overridden `__init__`method is particularly important to allow superclasses to their part in initializing the instance.

```py
def __init__(self, a, b):
    super().__init__(a,b)
```

If:

```py
def __setitem__(self, key, value):
    OrderedDict.__setitem__(self, key, value)
    ...
```

This alternative works in this particular case, but is not recommended for two reasons -- 

1. it hardcodes the base cass.
2. `super`implements logic to handle class hierarchies wiht *multiple* inheritance.

Whether you or compiler provdes those arguments, the `super()`call returns a dynamic proxy object that finds a method in a superclass of the type parameter, and binds it to the `object_or_type`.

### Subclassing Built-in Types is Tricky

The built-ins (written in C) usually does not call mehods overridden by user-defined classes. FORE:

```py
class DoppelDict(dict):
    def __setitem__(self, key, value):
        super().__setitem__(key, [value]*2)
```

1. This class's `__setitem__`duplicates values when storing just to have a viible effect, it works by delegating to superclass.
2. The `__init__`method inherited from the `dict`clearly ingored the `__setitem__`was overridden, the value is not duplicated.
3. The `[]`operator calls the `__setitem__`and works as expected, `two`maps to the dupliated value [2,2]
4. and the `update`method from the `dict`does not use new version of the `__setitem__`either.

This built-in behavior is a violation of a basic rule of OOP the search for methods should always start from the class of the receiver, even when the call happens inside a method implemened in a superclass. The problem is not limited to calls with an instance, whether `self.get()`calls `self.__getitem__()`but also happens with overridden methods of other classes that shoud be called by the built-in methods.

```py
class AnswerDict(dict):
    def __getitem__(self, key):
        return 42
 
ad= AnswerDict(a='foo')
ad['a'] # 42
d= {}
d.update(ad)
d['a'] 'foo'
```

And if subclass `collections.UserDict`instead of `dict`, the issues exposed in:

```py
import collections

class DoppedDict2(collections.UserDict):
    def __setitem__(self, key, value):
        super().__setitem__(key, [value]*2)
```

### Multiple Inheritance and method resolution order

Any language implementing multiple inheritance needs to deal with potential naming conflicts when superclasses implement a mehdo by the same name. -- this is called diamond problem -- like:

```py
class Root:
    def ping(self):
        print(f'{self}.ping() in Root')
        
    def pong(self):
        print(f'{self}.pong() in Root')
        
    def __repr__(self):
        cls_new = type(self).__name__
        return f'<instance of {cls_new}'
    
    
class A(Root):
    def ping(self):
        print(f'{self}.ping() in A')
        super().ping()
        
    def pong(self):
        print(f'{self}.pong() in A')
        super().pong()
        
class B(Root):
    def ping(self):
        print(f'{self}.ping in B')
        super().ping()
        
    def pong(self):
        print(f'{self}.pong in B')
        
class Leaf(A, B):
    def pint(self):
        print(f'{self}.ping in leaf')
        super().ping()
        
```

- The method resolution order of the `Leaf`class
- The use of the `super()`in each method.

Need to note that every class has an attribute called `__mro__`holding a tuple of references to the super-classes in method resolution order, from the current class all the way to the `object`. like:

Leaf, A, B, Root, Object..

So the `MRO`only determines the activation order, but whether a particular method will be activated in each of the classes depends on whether each implementation calls `super()`or not. For thie `pong()`method, the `Leaf`class does not override it, therefore calling .pong() activates the implementation in the next class of the `Leaf.__mro__`, A, So there, A's Super class is just B, so the activation sequence ends there.

The MRO takes into account not only the inheritance graph but also the order in which superclasse are listed in a subclass declaration.

When a method calls `super()`it is a *cooperative method* -- Cooperative methods enable *cooperative multiple inhertiance* -- this terms are intentional.

Cooperative methods must hae compatible signatures -- cuz you never know whether A.ping will be called before or after the `B.ping`.

### Mixins

A mixin is designed to be subclassed together with at least one other class in a multiple inheritance arrangement.

```py
import collections

def _upper(key):
    try:
        return key.upper()
    except AttributeError:
        return key
    
class UppeCseMixin:
    def __setitem__(self, key, value):
        super().__setitem__(_upper(key), value)
    def __getitem__(self, key):
        return super().__getitem__(_upper(key))
    def get(self, key, default=None):
        return super().get(_upper(key), default)
    def __contains__(self, item):
        return super().__contains__(_upper(item))
```

Since every method to `UppercaseMixin`calls `super()`, this mixin depends on a sibling class that implements or inherits methods with the same signature.

```py
class UpperDict(UppeCaseMixin, collections.UserDict): pass
```

1. `UpperDict`needs no implemenation of its own, but the `UpperCaseMixin`must be the first base class, otherwise the methods from `UserDict`would be called instead.
2. UpperCaseMixin also works with Counter

```py
d= UserDict([('a', 'letter A'), (2, 'digit two')])
list(d.keys())
```

The `Observable`class is provided by the `Rxjs`package, which is used by Angular to handle state changes in applications, an `Observable<Product[]>`, which is an `Observable`that produces arrays of `Product`objects. Which is used by Angular to handle state changes in app -- an `Obsevable`just represents an acync task that will produce a result at some point in the future.

The `@Injectable`decorator has been applied to the `StaticDataSource`class, this decoartor is used to tell Angular that this class will be used as a service, which allows other clases to access its functionality through a feature called DI.

### Creating the Model Repository

The data source is responsilble for providing the app with the data it requires, but access to the data is typically mediated by the repostiory, which is responsible for distributing that data to individual app building blocks so that the details of how thed data has been obtained are kept hiddn.

```tsx
@Injectable()
export class ProductRepository {
    private products: Product[] = [];
    private categories: string[] = [];

    constructor(private dataSource: StaticDatasource) {
        dataSource.getProducts().subscribe(data => {
            this.products = data;
            this.categories = data.map(p => p.category ?? "(None)")
                .filter((c, index, array) =>
                    array.indexOf(c) == index).sort();
        });
    }

    getProducts(category?: string): Product[] {
        return this.products
            .filter(p => category == undefined || category == p.category);
    }

    getProduct(id: number): Product | undefined {
        return this.products.find(p => p.id == id);
    }

    getCategories(): string[] {
        return this.categories;
    }
}
```

When Angular needs to create a new instance of the repository, it will inspect the class and see that it needs a `StaticDataSource`object ot invoke the `ProductRepository`ctor and create a new object, the Repository ctor calls the data source’s `getProducts()`method and then uses the `subscribe`method on the `Observable`that is returned to receive the product data just.

### Creating the Fetaure Module

Going to define an Ng feature model that will allow the data model functionality to be easily used elsewhere in the application -- just add:

```tsx
import {NgModule} from "@angular/core";
import {ProductRepository} from "./product.repository";
import {StaticDatasource} from "./static.datasource";

@NgModule({
    providers: [ProductRepository, StaticDatasource]
})export class ModelModule{}
```

The `@NgModule`decorator is used to create feature modules, and its properties tell Angular how the module should be sued, there is only one property in this module -- `providers`-- it tells Angulare which classes should used as **services** for the DI feature.

### Starting the Store

Now that the data model is inplace, can start to build out the store functionality, which will let the user see the products for sale and place orders for them.

Creating the Store Component and Template -- Try to introduce some variety into the project to showcase some important Angualr features -- going to keep things simpe for the mmment in the interest of being able to get the project just started quickly.

The starting point for the store functionality will be a new component, whcih is a class that provides data and logic to an HTML template, which contains data binding that generate some data dynamically.

```tsx
@Component({
    selector: "store", 
    templateUrl: "store.component.html",
})export class StoreComponent {
    constructor(private repository: ProductRepository) {
    }
    get products(): Product[] {
        return this.repository.getProducts();
    }
    
    get categories(): string[] {
        return this.repository.getCategories();
    }
}
```

The `@Component`decorator has been applied to the `StoreComponent`class, which tells Angular that it is a component, the decorator’s properties tell ng how to apply the component to HTML content, and how to find the component’s template. This just provides the logic will support the template content. The ctor receives a `ProductRepository`as arg, provided through the DI feature -- the component defines props that will be used to generte HTML content in the template.

```html
<div class="container-fluid">
    <div class="row">
        <div class="bg-dark text-white p-2">
            <span class="navbar-brand ml-2">SPORTS STORE</span>
        </div>
    </div>
    
    <div class="row text-white">
        <div class="col-3 bg-info p-2">
            {{categories.length}} categories
        </div>
        <div class="col-9 bg-success p-2">
            {{products.length}} Products
        </div>
    </div>
</div>
```

Just note most of the template elements provide the structure for the store layout are apply some bootstrap css classes.

### Creating the Store feature module

```tsx
@NgModule({
    imports:[ModelModule, BrowserModule, FormsModule],
    declarations:[StoreComponent],
    exports:[StoreComponent]
})export class StoreModule{}
```

The `@NgModule`decorator configures the module, using the `imports`prop to tell Ng that the store module depends on module as well as the `BrowserModule`and `FormModule`, which contain the std Angular features for web applications and for working with HTML elements.

### Updating The root component and Root Module

Applying the basic module and store functionality requires updating the app’s root module to import the two feature modules and also requires updating the root module’s template to add the HTML element to which the component in the store module will be applied like:

```tsx
@NgModule({
  declarations: [
    AppComponent
  ],
    imports: [
        BrowserModule,
        StoreModule
    ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

### Adding store features the Product Details

Once the fundation of the project good, new features can be created relatively easily -- 

Displaying the Product Details-- The obvious place to start to display details for the products so that the customers can see what’ s on offer -- adds HTML elements to the component’s template with data binding that generte conetnt for each product provided by the component like:

```html
<div class="col-9 p-2 text-dark">
    <div *ngFor="let product of products" class="card m-1 p-1 bg-light">
        <h4>
            {{product.name}}
            <span class="badge rounded-pill bg-primary" style="float:right;">
                {{product.price | currency: "USD": "symbol":"2.2-2"}}
            </span>
        </h4>
    </div>
</div>
```

Most of the elemens control the layout and appearance of the content. The most important change is like:

`<div *ngFor="let product of products" class="...">`

This is an example of a directive, which transforms the HTML element if it is applied to. This specific directie is called `ngFor`, and it is transforms the `div`element by duplicating it for each object returned by the componetn’s `products`property -- Ng includes a range of built-in directives that performs the most ommonly required tasks.

### Working with Reactive Extensions -- 

ng relies on packae Rxjs, -- provides a simple and unambigious system for sending and receiving notifications. `Observable<T>`-- represents the observable sequence of **events** that occur over a period of time. This is most often encountered when using Ng support for making HTTP requests, where the outcome of the requests is presented through an `Observable<T>`object -- And the generic type argument `<T>`just denotes the type of the event that the observable produces so that an `Observable<string>`..

And, an object can subscribe to an `Observable`and receives a noficiation each time an event occurs, allowing it to respond only when the event has been observed. In the case of the HTTP request, fore, the use of the `Observable`allows response to be handled when it just arrives, without the handler code needing to periodically check whether the request has completed.

Fore, the basic method provided by an `Observable`is `subscribe`, which accepts an object whose properties are set to functions that respond to the sequence of events. 

- `next`-- is invoked when a new event occurs
- `error`-- invoked when an error occurs
- `complete`-- invoked when ends.

```tsx
function receiveEvents(observable: Observable<string>) {
    observable.subscribe({
        next: str=> console.log(...);
    }, 
                        complet:()=> console.log(...);)
}
```

And the `Observer<T>`class provides the mechanism by which updates are updated, using methods like:

`next(value), error(errorObject), complete()`.

```tsx
function sendEvents(observer: Observer<string>){
    let count=5;
    for(let i=0; i<count; i++) {
        observer.next(`${i+1} of ${count}`)
    }
    obsever.complete();
}
```

### Understanding Subjects

The Rxjs provides the `Subject<T>`class, which implements both the `Observer`and `Observable`functionality, a `Subject`is useful when you are working with RxJS in your own code, rather then using an `Observable`.. provided through the Angular API. Have created a `Subject<string>`and used as arg to invoke the functions defined:

```tsx
let subject = new Subject<string>();
recieveEvents(subject);
sendEvents(subject);
```

This specific directive is called `ngFor`, and it transform the `div`element by duplicating it for each object returned by the component’s `products`property, Ng includes a range of built-in directives that perform the most commonly required tasks -- just duplicates 5 element, the current object is asigned to a variable called `product`, which allows it to be referred to `in`other data bindings, such as this one.

Not all data in an app’s data model can be displayed directly to the user -- Ng includes a feature called *pipes* which are classes used to transform or prepare a data value for its use in a data binding. There are several built-in pipes included with Angular, including the `currency`-- formats number values as currencies like:

`{{product.price | currency:”USD”:”symbol”:”2.2-2”}}

### Adding Category selection

Adding support for filtering the list of products by category requires preparing the store component so that it keeps track of which category the user wants to display and requires changing the way that data is retrieved to use that category: Changes are simple cuz build on the fundation that look so long to create at the start of the chapter.

```html
<div class="col-3 p-2">
    <div class="d-grid gap-2">
        <button class="btn btn-outline-primary" (click)="changeCategory()">
            Home
        </button>
        <button *ngFor="let cat of categories"
                class="btn btn-outline-primary"
                [class.active]="cat==selectedCategory"
                (click)="changeCategory(cat)">
            {{cat}}
        </button>
    </div>
</div>
```

There are two new -- first is Home button, it has an event binding that invokes the component’s `changeCategory()`when the button is clicked. Select `null`and just selecting all the products. And the `ngFor`binding has been applied to the other `button`, with an expression that will repeat a `click`event binding whose expression calls the `changeCategory()`method to select the current category, which will filter the products displayed to the user.

### Adding Product pagination

Filtering the products by category has helped make the product list more manageable -- a more typical apprach is to just like: