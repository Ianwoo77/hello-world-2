# Working with text data

Text data can get quite messy. Real-world data sets are just riddled with incorrect charcters, improper letter casing... The process of cleaning data is called *wrangling* or *munging*-- often, the majority of our data analysis is dedicated to munging. may know the insight we want to dervie early on, but the difficulty lies in arranging the data in a suitable shape for manipulation.

### Letter casing and whitespace

Fore csv is a modified version of a data set available from the city. And there are typos and inconsistencies within the data; have preserved them so that you can see the data irregularities-- Consider how you can optmize this data with the techniques you will learn -- immediately see , Most row values are uppercase, some are lowercase, and some are normal case. The Name's column's values are sorrounding by whitespaces. Can spot the extra spacing more easily if we isolate the `Name`series with square-bracket syntax like:

The `Series`has `str`attr exposes a `StringMethods`object, just a powerful toolbox of methods for working with strings.

`inspections['Name'].str`

Can invoke a method on the `StringMethods`object rather then the `Series`itself -- some methods work like py's native string methods, whereas other methods are exclusive to pandas -- For a comprehensive review of Py's string methods. Can use the `strip`family of methods to remove whitespace from a string, the `lstrip`fore:, and the py string's 3 `strip`s methods also in the `str`object like:

`inspections['Name'].str.lstrip().head()` # also `rstrip`and `strip`

Now can overwrite our existing `Series`with the new one that has no extrac whitespace -- will use the `strip`code to create the new `Series`. On the left side, will use `[]`syntax to denote the column we'd like to overwrite. Py processes the right side of the equal sign first. like:

`inspections['Name']= inspections['Name'].str.strip()`

Recall the `columns`attribute -- exposes the iterable `Index`object that holds the `DF`Column names. Can use py for loop to iterate over each column invoke the `str.strip`method to return a new `Series`. like:

```py
for column in inspections.columns:
    inspections[column]=inspections[column].str.strip()
```

All of Python's character casing methods are available on the `StringMethods`object -- the `lower`method, lowercases all string characters -- like:

`inspections['Name'].str.lower().head()` # and complementary `upper`returns a `Series`with uppercase strins.

Suppose that want to get the establishments's names in a more standardized, readable foramt, can use the `str.capitalize`method to capitalize the first letter of each string in the `Series`:

`inspections['Name'].str.captilize().head()`

That is a step in the right direction, but perhaps the best method avaiable is `str.title`, which capitalizes ech word's first letter, Pandas uses spaces to identify where one word ends and the next begins like:

`inspections['Name'].str.title().head()`

### String Slicing

Trun our focus to the Risk column, each row's value includes both a numeric and categorical representation of the risk, here is a remainder of what the column looks like:

`inspections['Risk'].unique()`

For this, have to account for two additional values -- missing `NaN`s and the `All`string. Howe deal with these values is ultimately up to the analyst and the business.  Just propose a compromise, remove the missing `NaN`values and replace the `All`values with `Risk 4`-- so, can remove missing values from a `Series`with the `dropna`method -- pass its subset parameter a list of the `Df`columns like:

`inspections=inspections.dropna(subset=['Risk'])`

Then can use the `DataFrame`helpful `replace`method to replace all occurrences of one value with another. The mehod's first parameter, `to_replace`, sets the value to search for, and its second parameter, value, specifies what to replace each occurrence of it with. -- Just replaces the `All`string values with `Risk 4`like:

```py
inspections=inspections.replace(
    'All', 'Risk 4 (Extreme)'
)
```

Now have a consistent format for all values in the `Risk` column like: 

`inspections.Risk.unique()`

### String slicing and character replacement

Can use the `slice`method on `StringMethods`object to extract a substring from a string by index position. The method accepts a starting index and an ending index as arguments. The lower bound is inclusive, whereas the upper is exclusive. And our risk number starts at index position 5 in each string, the next example pulls the characters from the index position 5 up to index position 6 like:

`inspections['Risk'].str.slice(5,6).head()`

Can also replace the `slice`method with py's list-slicing syntax -- the following code returns the result as:

`inspections['Risk'].str[5:6].head()`

What if want to extract the categorical ranking -- This challenge is made difficult by the different lengths of the words, cannot extract the same number of characters from a starting index position -- and a few solutions are avaiable. For now, attack the problem step by step -- can start by using the `slice`method to extract each row's risk category -- pass the `slice`method a single value, pandas will use it as the lower bound and extract until the end of the string.

The next example pulls the characters from index 8 to the end of each string like:

```py
inspections['Risk'].str.slice(8).head()
inspections['Risk'].str[8:].head()
```

Still have to deail with the pesky closing parentheses -- coll solution -- pass a negative argument to the `str.slice`method. A negative argument sets the index bound relative to the end of the string -- -1 extacts up to the last character, -2 extracts up to the second-to-last characters. like:

```py
inspections['Risk'].str.slice(8, -1).head()
inspections['Risk'].str[8:-1].head()
```

Another strategy can use to remove the closing parentheses is the `str.replace()`method, can replace each closing parenthese with an empty string.

`inspections['Risk'].str.slice(8).str.replace(')', '').head()`

### Boolean methods

Other methods are available on the `StringMethods`object just return a `Series`of Booleans, these methods can prove to be particularly helpful for filtering a `DataFrame`. The biggest challenge in string matching is case sensitivity. Py will not find the string. To solove the Cap problem, need to ensure consistent casing across all column values before check for the presence of a substring.

The `contains`method checks for a substring's inclusion in each `Series`value. The method returns `True`when pandas finds the method's argument within the row's string and `False`when it does not.

```py
has_pizza = inspections['Name'].str.lower().str.contains('pizza')
inspections[has_pizza]
```

Just notice that pandas preserves the original letter casing of the values in Name. The `inspections` is never mutated. And the `lower()`method returns a just new `Series`-- and the `contains`method also returns another new.

The `str.startswith`method solves the problem, returns `True`if a string begins with its argument --

`inspections['Name'].str.lower().str.startswith('tacos').head()`

```py
start_with_tacos = inspections['Name'].str.lower().str.startswith('tacos')
inspections[start_with_tacos]
```

And there is also the complementary `str.endswith`method checks for a substring at the end of each `Series`:

```py
ends_with_tacos = \
	inspections['Name'].str.lower().str.endswith('tacos')
```

### Splitting strings

Next data set is a collection of fictional customers -- each row in cludes the customer's `Name`and `Address`. like: Can use the `str.len`method to return the length of each row's string like:

`customers['Name'].str.len().head()`

Suppose want to just isolate each customer's first and last names in two separate columns -- may be famililar with Python's `split`method, which separates a string by using a specified delimilter -- And the method returns a list consisting of all the substrings after the split. The next splits a phone number into a list of three strings by using a hyphen delmiter -- like: -- performs the same operation on each row in `Series`like:

`customers['Name'].str.split(' ').head()`

now re-invoke the `str.len`method on this new `Series`of lists to get the length of each list. like:

`customers['Name'].str.split(' ').str.len().head()`

Which just returns the array length.

And the next example, passes an arg of 1 to the `split`'s `n`parameter -- sets the maximum number of splits.

`customers['Name'].str.split(' ', n=1).head()`

Now all our lists have equal lengths - -can use the `str.get`method to pull out a value from each row's list based just on the index position.

`customers['Name'].str.split(' ', n=1).str.get(0).head()`

Note that the `get`also supports negative arguments -- An arg of -1 extracts the last element from each row's list, regardless of how many elemetns the list holds.

NOTE: we have used two separate `get`method calls to extract the first and last names in two separate `Series` -- the `str.split`method accepts an `expand`parameter, and when pass it an argument of `True`, the method returns a new `DataFrame`instead of a `Series`. like:

`customers['Name'].str.split(' ', n=1, expand=True).head()`

For this, got a new `DataFrame`-- Cuz did not provide custom names for the columns, pandas just defaulted to a numeric index on the column axis. And be careful in these scenarios, if do not limit the number of splits with the `n`parameter, pandas will place `None`values in rows that do not have sufficient elements.

The next example adds two columns, `First Name`and `Last Name`populates them with the `DataFrame`returned by the `split`method like:

```py
customers[['First Name', 'Last Name']]= customers['Name'].str.split(
    " ", n=1, expand=True
)
customers.drop(labels='Name',inplace=True, axis=1)
```

or: `customers.drop(labels='Name', inplace=True, axis='columns')`

## Cookie login

```py
import requests

url = 'http://www.webscrapingfordatascience.com/cookielogin/secret.php'
r=requests.get(url)
print(r.text)
```

We henced need to resort to a more robust system as follows -- will first perform a POST request simulating a login, get out the cookie value from the HTTP response, and use it for the rest of our session, can do this as follows:

```py
import requests

url = 'http://www.webscrapingfordatascience.com/cookielogin/'
r= requests.post(url, data=dict(username='dummy', password='1234'))
my_cookies= r.cookies
my_cookies['PHPSESSID']=r.cookies.get('PHPSESSID')
r= requests.get(url+'secret.php', cookies=my_cookies)
print(r.text)
```

For this, you are not able to log in correctly and that the cookies being returned from the POST requeste are empty. The reason behind this is related to sth -- rquests will automatically follow HTTP redirect status code. But the `Set-Cookie`response header is the response following the HTTP POST request, and not in the response for the redreicted page. Hence need to use the `allow_redirects`argument once again.

```py
import requests

url = 'http://www.webscrapingfordatascience.com/redirlogin/'
r = requests.post(url, data=dict(username='dummy', password='1234'),
                  allow_redirects=False)
print(r.cookies)
r = requests.get(url+'secret.php', cookies=r.cookies)
print(r.text)
```

And the trickylogin -- this site works in more or less the same way -- like:

```py
import requests

url = 'http://www.webscrapingfordatascience.com/trickylogin/'
r = requests.post(url, params=dict(p='login'), data=dict(username='dummy', password='1234'),
                  allow_redirects=False)
print(r.cookies)
r = requests.get(url, params=dict(p='protected'), cookies=r.cookies)
print(r.text)
```

The reason for this is that this particular example also checks whether we have actually visited the login page, and are hence not only trying to directly submit the login information, need to add in another `GET`requrest first.

```py
import requests

url = 'http://www.webscrapingfordatascience.com/trickylogin/'

proxies = dict(http='http://127.0.0.1:10809')

r = requests.get(url, proxies=proxies)  # first perform a normal get

# then perform the post request
r = requests.post(url, params=dict(p='login'), data=dict(username='dummy', password='1234'),
                  allow_redirects=False, cookies=r.cookies, proxies=proxies)
r = requests.get(url + 'index.php', params=dict(p='protected'),
                 cookies=r.cookies, proxies=proxies)
print(r.text)
```

This just shows a simple truth about dealing with cookies, which should not shound surprising now that you now how they work *every time an HTTP response comes in, should update our client-side cookie information accordingly*. In addition, need to be careful when dealing with redirects, -- as the `Set-Cookie`header might be `hidden`the original HTTP response. This is quite troublesome and will indeed quickly lead to messy scraping code.

### Using sessions with Requests

Immediately just in an introduce mechanism like:

```py
url = 'http://www.webscrapingfordatascience.com/trickylogin/'

my_session = requests.session()

proxies = dict(http='http://127.0.0.1:10809')

r = my_session.get(url, proxies=proxies)  # first perform a normal get

# then perform the post request
r = my_session.post(url, params=dict(p='login'), data=dict(username='dummy', password='1234'))
r = my_session.get(url + 'index.php', params=dict(p='protected'))
print(r.text)
```

First, creating a `requests.Session`object and using it to perform HTTP requests, using the same methods (get and post) as above. This is extractly what the request's session mechanims aims to offer, basically, it specfiies that varous requests belong together -- to the same session, and that requests should hence deal with cookies automatically behind the scenes. This is just a huge benefit in terms of user friendiness, and makes requests shine compared to other HTTP lisbraries in Python.

```py
my_session = requests.session()
my_session.headers.update({'User-Agent':'Chrome!'})

proxies = dict(http='http://127.0.0.1:10809')

r = my_session.get(url, proxies=proxies)  # first perform a normal get
print(r.request.headers)

# then perform the post request
r = my_session.post(url, params=dict(p='login'), data=dict(username='dummy', password='1234'))
print(r.request.headers)
r = my_session.get(url + 'index.php', params=dict(p='protected'))
print(r.request.headers)
print(r.text)
```

```py
import requests
url = 'http://www.webscrapingfordatascience.com/files/kitten.jpg'
r = requests.get(url)
with open('image.jpg', 'wb') as f:
    f.write(r.content)
```

## Using the ngModel Directive

The `ngModel`directive is used to simplify two-way bindings so that you don’t have to apply both an event and a property binding to the same element. like:

```html
<input class="form-control" [(ngModel)]="selectedProduct" />
```

The target for the binding is the `ngModel`directive, which is included in Ng to simplify creating two-way data bindings on form elements. the expression for a two-way binding is the name of a property, whcih is used to set up the individual bindings behind the scenes.

Need to note that must rememer to use both brackets and parentheses with the `ngModel`binding -- if u use just like `(ngModel)`then you are setting an event binding for an event called `ngModel`-- which just doesn’t exist. Can just use the `ngModel`just `[ngModel]`-- and Ng will set the initial value of the element but won’t listen for events.

### Working with Forms

Most web apps rely on forms for receiving data from users. and the two-way `ngModel`binding descried in the previous section provides the foundation for using forms in Angular appliations.

```ts
newProduct: Product = new Product();

get jsonProduct() {
    return JSON.stringify(this.newProduct);
}

addProduct(p: Product) {
    console.log(..)
}
```

Just like in the template file:

```html
<input class="form-control" [(ngModel)]="newProduct.category" />
```

And, each `input`element is grouped with a `label`and contained in a `div`element, which is styled using the `mb-3`class, individual -- the `ngModel`binding has been applied to each `input`element to create a two-way bindigns

`<input class="form-control" [(ngModel)]="newProduct.name" />`

### Adding form Data Validation

At the moment, any data acn be entered into the `input`elements in the form. Data validation is essential in web applications cuz users will enter a surprising range of data values, either in error or cuz they want to get to the end of the process as quickly as possible and enter garbage values to proceed. like:

- `email`-- well-formatted email
- `requird, minlength, maxlength, min, max`
- `pattern`-- Used to specfiy a regular expression that the value provided by the user must match.

```html
<form (ngSubmit)="addProduct(newProduct)">
    <div class="mb-3">
        <label>Name</label>
        <input class="form-control" 
               name="name"
               required
               minlength="5"
               pattern="^[A-z]+$"
               [(ngModel)]="newProduct.name"/>
    </div>
</form>
```

And Ng requires elements being valiated to define the `name`attribute, which is used to identify the element in the validation system -- since this `input`is being used to capture the value of the `Product.name`property, the `name`attribute on the element has set to `name`.

And when using the `form`element, the convention is to use an event binding for a special event called `ngSubmit`:

`<form (ngSubmit)="addProduct(newProduct)">`

The `ngSubmit`binding handles the `form`element’s `submit`event, can achieve the same effect bindign to the `click`event on individual `button`elements within the `form`you prefer.

### Styling Elements using Validation Classes

Once U have saved tempalte changes -- and the browser has reloaded the HTML,  -- `ng-pristine ng-invlid ng-touched`added to the HTML element.

The classes to which an `input`element is assigned provided details of its validation state. There are three pairs of validation clases. like:

- `ng-untouched` & `ng-touched`-- If class has not been visted by the user
- `ng-pristine` & `ng-dirty`-- ng-pristine have not been changed, otherwise `ng-dirty`
- `ng-invalid` & `ng-valid`-- contents meet the criteria or not.
- `ng-pending`-- Elements are assigned to the `ng-pending`class when their contents are being validated async.

For this, can just add some stylesheet like:

```css
input.ng-dirty.ng-invalid {border: 2px solid #ff0000;}
input.ng-dirty.ng-valid{border: 2px solid #6bc502}
```

These styles set green and red borders for `input`elements whose content has been edited and is valid.

### Displaying Filed-level Validation Messages

Using colors to provide validation feedback tells the user that sth is wrong but doesn’t provide any indication of what the user shoud do about it - -the `ngModel`directive provides access to the validation sttus of the elements it is applied to, which can be used to displayed guidance to the user.

```html
<input class="form-control"
       name="name"
       required
       minlength="5"
       pattern="^[A-z]+$"
       #name="ngModel"
       [(ngModel)]="newProduct.name" />

<ul class="text-danger list-unstyled mt-1"
    *ngIf="name.dirty && name.invalid">
    <li *ngIf="name.errors?.['required']">
        U must enter a product name
    </li>
    <li *ngIf="name.errors?.['pattern']">
        products names can only contain letters and spaces
    </li>
    <li *ngIf="name.errors?.['minlength']">
        Product's names must be at least
        {{name.errors?.['minlength'].requiredLength}} characters
    </li>
</ul>
```

So, first, to get the validation working, have to create a template reference variable to access the validation state in expressions like `#name="ngModel"`-- Create a template reference variable called `name`and set the value to the `ngModel`-- this use of `ngModel`value is a little confusing -- NOTE: it is just a feature provided by the `ngModel`directive to give access to the validation status -- this will make more sense once you have read -- how to create custom directives and you see how they provide access to their features.

Just need to create a templte reference variable and assign it `ngModel`to access the validation data for the `input`element. The object that is assigned to the tempalte reference variable defines the properties that are described -- like:

- `path`-- returns the name of the element
- `valid`-- returns `true`if the element’s contents R valid and `false`otherwise
- `invalid, pristine, dirty, touched, untouched`
- `errors`-- this returns a `ValidationErrors`object whose proeprties correspond to each attribute for which there is a validation error.
- `value`-- returns the `value`of the element, which is used when defining custom validation rules.

And, for this, just like:

`<ul class="text-danger list-unstyled mt-1" *ngIf="name.dirty && name.invalid">`

Within the `ul`, here is an `li`that corresponds to each validation error that can occur. Just like:

`<li *ngIf="name.errors?.['required']">`

The `errors.[required]`property will be defined only if the element’s contents have failed the `required`validation check -- which ties the visibility of the `li`element to the outcome of that validation check.

- `minlength.rquiredLength, .actualLength`.
- `min.actual`-- returns the number of characters entered by the user.
- `min.min`-- returns the minimum value required to satisfy the `min`
- `pattern.requiredPattern`-- returns the regular expression that has specified using the `pattern`.

So these properties are not displayed directly to the user, who is unlikely to understand an error message that includes a regular expression. like:

`{{name.errors?.['minLength'].requiredLength}}`

# Using the Components to display Valiation Messages

Including separate elements for all possible validation errors quickly becomes verbose in complex forms. A better approach is to add logic to the component to prepare the validation mesages in a method, which can then be displayed to the user through the `ngFor`directive in the template.

```ts
getMessages(errs: ValidationErrors | null, name: string): string[] {
    let messages: string[] = [];
    for (let errorName in errs) {
        switch (errorName) {
            case 'required':
                messages.push(`U must enter a ${name}`);
                break;
            case 'minlength':
                messages.push(`A ${name} must be at least
${errs['minlength'].requiredLength} characters`);
                break;
            case 'pattern':
                messages.push(`The ${name} contains illegal characters`);
                break;
        }
    }
    return messages;
}

getValidationMessages(state: NgModel, thingName?: string) {
    let thing: string = state.path?.[0] ?? thingName;
    return this.getMessages(state.errors, thing);
}
```

The `getValidationMessages`and `getMessages`use the properties to produce validation messages for each error, returning them in a string array. The `getValidationMessages()`deaults to using the `path`prop as the descriptive string if an argument isn’t received when the method is invoked. like:

`let thing: string= state.path?.[0]??thingName;`

```html
<ul class="text-danger list-unstyled mt-1"
    *ngIf="name.dirty && name.invalid">
    <li *ngFor="let error of getValidationMessages(name)">
        {{error}}
    </li>
</ul>
```

For this, there is no visual change, but the same method can be used to produce validation messages for multiple elements.

### Validating the entire Form

Displaying validation error messages for individual fields is useful cuz it helps emphasize where problems need to be fixed -- can also be useful to validate the entire form. Care must be taken not to overwhelm the user with error messages until they try to submit the form like:

```ts
formSubmitted = false;

submitForm(form: NgForm) {
    this.formSubmitted = true;
    if (form.valid) {
        this.addProduct(this.newProduct);
        this.newProduct = new Product();
        form.resetForm();
        this.formSubmitted = false;
    }
}
```

Note that the `formSubmitted`prop will be used to indicate whether the form has been submitted and will be used to prevent validation of the entire form until the user has tried to submit.

The `submitForm`method will be invoked when the user submits the form and receives an `NgForm`object as its argument. This object represents the form and defines the set of validation properties. Thses properties are used to just describe the overall validation status of the form -- fore the `invalid`will be `true`if there are any errors. Also, provides the `resetForm()`method, which resets the validation status of the form and returns it to its original and pristine state.

The effect is that the whole form will be validated, when the user performs a submit, and if there are no valiation errors, a new object will be added to the data model before the form is reset . and add:

```html
<form #form="ngForm" (ngSubmit)="submitForm(form)">
    <div class="bg-danger text-white p-2 mb-2"
         *ngIf="formSubmitted && form.invalid">
```

### Displaying summary Validation Messages

in a complex form, it can be helpful to provide the user with a summary of all the validation errors that have to be resolved -- The `ngForm`object assigned to the `form`template reference variable provides access to the individual elements through a property named `controls`. This prop returns an object that has props for each of the individual elements in the form -- FORE, the `name`represents the `input`element in the example. So:

```ts
getFormValidationMessages(form: NgForm): string[] {
    let messages: string[] = [];
    Object.keys(form.controls).forEach(k => {
        this.getMessages(form.controls[k].errors, k)
            .forEach(m => messages.push(m));
    });
    return messages;
}
```

The `getFormValidationMessages`method builds its list of messsages by calling the `getMessages()`method for each control in the form -- the `Object.keys()`method creates an array from the properties defined by the object returned by the `controls`prop.

```html
<ul>
    <li *ngFor="let error of getFormValidationMessages(form)">
        {{error}}
    </li>
</ul>
```

### Disabling the Submit Button

The next step is to disalbe the button once the user has sumitted the form, preventing the user from clicking it again until all the validation errors have been resolved, this is commonly used technique even though it has little bearing on the example application. Which won’t accept the data from the form while it contains invalid values but provides useful reinforcement to the user that they cannot preceed until the validation problems have been resolved.

```html
<button class="btn btn-primary mt-2" type="submit"
        [disabled]="formSubmitted && form.invalid"
        [class.btn-secondary]="formSubmitted && form.invalid">
    Create
</button>
```

### Completing the Form

Now that the valiation features are done, can just complete the from, restores the input elements for the `category`and `price`fields, which removed earlier -- like:

```html
<div class="mb-3">
    <label>Category</label>
    <input class="form-control" name="category" [(ngModel)]="newProduct.category" required/>
</div>

<div class="mb-3">
    <label>Price</label>
    <input class="form-control" name="price" [(ngModel)]="newProduct.price"
           required type="number"/>
</div>
```

## Getting Type System

Ts generates code, but the type system is the main event. through the nuts and bolts of Ts’ type system, how to think about that, how to use that, choices you will need to make, and features you should avoid.

### Thinks of Types as Sets of Values

At runtime, every variable has a single value chosen from Js’ universe of values like. Depending on `strictNullChecks`, `null`and `undefined`may or may not be part of the set. 

```ts
const x: never = 12; // 12 is not assignable to type never
type A = 'A'; // literal types in ts, also known as unit types
type Twelve =12;
type AB= 'A' | 'B'
type AB12 = 'A' | 'B' | 12;
```

And so on, union types correspond to unions of sets of values. The word assignable appears in many errors -- In the context of sets of values, it means either *member of* or *subset of*.

```ts
const a: AB= 'A'; //ok
const c: AB= 'C'; //error

const ab: AB= Math.random()<0.5 ? 'A': 'B';
const ab12: AB12 = ab;  // also ok
declare let twelve: AB12;
const back: AB= twelve ; // error not assignable
```

Thinking of types as set of values helps you reason about operations on them FORE:

```ts
interface Person{
    name:string;
}
interface Lifespan {
    birth: Date;
    death?: Date;
}
type personSpan= Person & Lifespan;
```

The `&`operator computes the *intersection* of two types -- what sorts of values belong to the `PersonSpan`type, but the type operations *apply to the sets of values* -- not to the properties in the interfaces. Just remember that values with additional properties still belong to a type. So a value that has the properties of *both* `Person`and `LifeSpan`will belong to the intersection type.

```ts
const ps: PersonSpan = {
    name: 'Alan Truing',
    birth: new Date('1912/06/23'),
}
```

But for the *union* of two interfaces, rather then their intersections.

```ts
type K= typeof(Person | LifeSpan); // never
```

### Creating Observables

Observables are like arrays in that they represent a *collection* of events, but are also like promises in that they are async-- each event in the collection arrives at some interminate point in the future -- this is just distinct from a collection of promises -- like `Promise.all`in that an observable can handle an arbitrary number of events, and a promise can only track one thing. An observable can be used model clicks of button, -- represents the clicks that wil happen over the lifetime of the application. like:

`let $myObs$= clickOnButton(myButton);`

For the `$`sign that is an convention in the Rx world that indicates that the variable in question is an observable. much like a promise, need to unwrap our observable to access the values it contains, the observable unwrapping method is just called `subscribe` -- this function passed into subscribe *is called every time the observable emits a value*. fore:

```ts
let myObs$= clicksOnButton(myButton);
myObs$.subscribe(clickEvent=> console.log('The button clicked'));
```

One thing to note here is that the observable under RxJs are *lazy* -- this means that if there is no subscribe call on the `myObs$`, no click event handler is created.

Building A timer -- This timer wil need to track the total number of seconds elapsed and emit the last value every 1/10th a second,  When the stop button pressed interval should be cancelled.

```ts
import { Observable } from 'rxjs'

let tenthSecond$ = new Observable(observer => {
    let counter = 0;
    observer.next(counter);
    let interv = setInterval(() => {
        counter++;
        observer.next(counter);
    }, 100);

    return function unsubscribe() {
        clearInterval(interv);
    }
});
```

Which tkes a single argument -- a fucntion with a single parameter -- `observer`-- an `observer`is any object that has the following -- `next(someItem)`-- called to pass the latest value to the observable stream, `error(someError)`-- called when sth goes wrong, and `complete()`called once the data source has no more invo to pass on. In the case of the observable constructor function, Rx just creates the observer for U and passes it ot the inner function.

Inside the ctor functin, things get just interesting -- there is an internal state in the counter variable that traks the number of since the start. Immediately, `observer.next`is called with the internal value of 0. And the `.next`method on the observer is how an observable announces to the subscriber that it has a new value for consumption.

And in the Rx land, this ctor will only run when someone subscribes to it. but, if there is a *second* subscriber, all of this will run a second time.

And finally, the inner function returns another function like:

`return function unsubscribe() {clearInterval(interv)}`

In this case, the interval is no longer needed, so clear it, this save CPU cycles, which keeps fans from spinning up on the desktop, and mobile users will -- Remember, each subscriber gets their won instance of the ctor, and so.

Speaking of mental overhead, that was a lot of info in just a few lines of code, there are a lot of new concepts.

```ts
import {interval} from 'rxjs';
let .. = interval(100);
```

so, Rx ships with a whole bunch of these creation operators for common tasks. Can find the complete.

```ts
import { interval } from 'rxjs'
let tenth$ = interval(1000);
tenth$.subscribe(console.log);
```

When there is a subscribe call, numbers start being logged to the console.

### Piping data through Operators

An operator is tool provided by RxJS that allows you to manipulate the data in the observable as it streams through.

```ts
import {exampleOperator} from "rxjs/operators"

interval(1000)
.pipe(
	exampleOperator()
);
```

### Manipulating data in flight with Map

Right, have a collection of almost right data -- a `map` is a function that takes two parameters, applies the function to each item, and returns a new collection containing the results. Like:

```ts
function map(oldArr, someFunc){
    let newArr=[];
    for(let i=0; i<oldArr.length; i++ ) {
        newArr.push(someFunc(oldArr[i]))
    }
    return newArr;
}
```

And, observables are just such collection and `Rx`provides a `map`operator of its own. It’s piped through a source observable, take a func, and returns a new observable that emits the result of the pass-in function. like:

```ts
tehthSecond$
.pipe(
	map(num=>num/10)
).subscribe(console.log);
```

### Handling the user Input

Next, manage clicks on the start and stop buttons, just grabs like:

```ts
function trackClickEvent(element:HTMLElement) {
    return new Observable(observer => {
        let emitClickEvent = event => observer.next(event);
        element.addEventListener('click', emitClickEvent);
        return () => element.removeEventListener(emitClickEvent);
    })
}
```

But, much like `interval`, let the lib do all the work for us, Rx provides a `fromEvent`creation operator for extactly this case -- It takes a DOM element and an event name as parameters, and returns a stream that fires whenever the elementusing the button from above.

```ts
let startButton = document.querySelector('#start-button');
let stopButton = document.querySelector('#stop-button');

let startClick$ = fromEvent(startButton, 'click');
let stopClick$ = fromEvent(stopButton, 'click');
```

```tsx
import { fromEvent, interval } from 'rxjs'
import { map, takeUntil } from 'rxjs/operators'

let startButton = document.querySelector('#start-button');
let stopButton = document.querySelector('#stop-button');
let resultArea = document.querySelector<HTMLElement>('.output');

let startClick$ = fromEvent(startButton, 'click');
let stopClick$ = fromEvent(stopButton, 'click');
let tenthSecond$ = interval(100);


startClick$.subscribe(() => {
    tenthSecond$
        .pipe(
            map(item => item / 10),
            takeUntil(stopClick$)
        ).subscribe(num => resultArea.innerText = num + 's');
});
```

What is `<HTMLElement>`mean -- This books uses Ts for all the examples, this just denotes the speicifc return type for `querySelector`-- knows that `querySelector`will return some kind of `Element`, but for this case, know specifically what we are querying for an element of the HTML -- so use this syntax to override the generic `element`.

So when the `Start`clicked, the subscribe() is triggered, the actual click event is ignored. At this implementation doesn’t  care about the specific of the click, jsut that it happend, `tenthSecond$`runs its ctor, cuz there is a subscribe call at the end of the inner chain. Every event fired by `$tenthSecond`runs through the `map`function, dividing each number by 10.

`takeUntil()`is an op that attaches itself to an observable stream and *takes* values from that stream until the observable that is passed in an argument emits a value. at that point, `takeUntil()`unsubscribes from both. So, when the Stop is pressed, Rx cleans up both the interval and the stop button click handler.

## Fetching remote data

The ability to receive and proess data in the browser, without refresing a page, is one of Js’ super power.

```js
const url = 'https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY'
fetch(url)
    .then(resp => resp.json())
    .then(console.log);
```

Or can just use `async/await`with `fetch`function like:

```js
async function fetchRequest(){
    const resp = await fetch(url);
    const data = await resp.json();
    console.log(data);
}
await fetchRequest();
```

- `url`(required) -- The URL to which want to make a request
- `options`-- an object of options when making the request
- `body`-- The body content of a request
- `cache`-- The cache mode of the requst
- `credentials`-- `omit, same-origin, include`
- `headers`-- include with the request
- `integrity`-- used for verify resources
- `method, mode`
- `redirect, referrer, referrerPolicy, signal`

FORE:

```js
const resp = await fetch(url, {
    method: 'GET', 
    mode: 'cors', 
    credentials: 'omit',
    redirect: 'follow',  // follow, error or manual
    referredPolicy: 'no-referrer'
})
```

`fetch`makes use of js promise, the initial promise returns a `Response`object, which contains the full HTTP response, including the body.. U can just use an additional parsing method to parse the body of the request. Possible methods:

- `arrayBuffer()`-- parse the body as an `ArrayBuffer`
- `blob()`-- Parse the body as a `Blob`
- `json()`-- Parse the body as JSON
- `text()`-- as a UTF-8 string
- `formData()`-- parse the body as a `FormData()`object.

And, when using `fetch`, can handle errors based on the server’s status response, in `async/await`like:

```ts
async function fetchRequestWithError() {
    const resp = await fetch(url);
    if (resp.status >= 200 && resp.status < 400) {
        const data = await resp.json();
        console.log(data);
    } else {
        console.log(error);
    }
}
```

And for more robust error handling, you can wrap the entire `fetch`request in a `try/catch`block, will:

```ts
async function fetchRequestsWithError() {
    try{...}
    catch(error){
        console.log(error)
    }
}
    
// or using the then() and catch() method like:
fetch(url)
    .then(resp=>...)
          .then(data=>console.log(data)).catch(error)=>{console.log(error);}
```

