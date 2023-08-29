# DataFrame filters rec

```py
high_earners= employees["Salary"]>100000
high_earners.head()
employees[high_earners].head()
is_female = employees["Gender"]=="Female"
in_biz_dev = employees["Team"]=="Business Dev"
employees[is_female & in_biz_dev].head()
my_sereis = pd.Sereis([True, False, True])
~my_series
employees[employees["Salary"]<10000].head()
empolyees[~(empolyees["Salary"]>=10000)].head()
```

### Filtering by condition

Better solution is the `isin`method, which accepts an iterable of elements -- and returns a `Boolean`Series for each condition is laborious. like:

```py
all_star_teams= ['Sales', 'Legal', 'Marketing']
on_all_star_teams= employees['Team'].isin(all_star_teams)
employees[on_all_star_teams]
```

When working with numbers of dates, often want to extract values that fall within a range -- like:

```py
high_then_80 = employees['Salary']>=80000
lower_then_90= employees['Salary']<90000
employees[high_than_80 & lower_than_90].head()
between_80k_and_90k = employees['Salary'].between(80000, 90000)
employees[between_80k_and_90k].head()
```

The `between`method also works on columns of other data types, to filter datetimes, can pass strings for the start and end dates of our time range -- the keyword parameters for the first and second arguments of the method are `left`and `right`?

```py
eighties_folk = employees['Start Date'].between(
    '1980-01-01', '1990-01-01'
)
employees[eighties_folk]
name_starts_with_r = employees['First Name'].between('R', 'S')
employees[name_starts_with_r]
```

As always, can use these Boolean `Series`to just extract specific `DataFrame`rows -- like:

```py
no_team= employees['Team'].isnull()
employees[no_team].head()
has_name = employees['First Name'].notnull()
employees[has_name].head()
```

### Dealing with null values

While are on the topic of missing values, some options for dealing with them -- just learned how to use the `fillna`method to replace `NaNs`with a constant value can also remove them.

The `dropna`method removes `DataFrame`rows that hold any `NaN`values. It doesn't matter hwo many values a row is missing, the method just excludes the row if a single `NaN`is present -- The employees has a missing value at index 0 of the Salary column. `employees.dropna()` .

can pass the `how`parameter an argument of `all`to remove rows in which all values are missing like:

`employees.dropna(how='all')`

And, the `how`parameter's default argument is `any`-- removes a row if any of its values is absent. Can use the `subset`parameter to target rows with a missing value in a specific column. just like:

`employees.dropna(subset=['Gender']).tail()`

Can also pass the `subset`a list of columns -- Pandas will remove a row if it has a missing value in any of the specified columns -- just like:

`employees.dropna(subset=['Gender', 'Start Date']).head()`

And the `thresh`parameter just specifies a minimum treshold of non-null values that a row must have for pandas to keep it. Like: `employees.dropna(thresh=4).head()`# at least 4 present values. And the `thresh`parameter is great when a certain number of missing values renders a row unless for analysis.

### Dealing with duplicates

Missing values are a common occurrence in messy data sets, and so are duplicate values. The `duplicated`method returns a Boolean `Series`that identifies duplicates in a column. Pandas returns `True`any time it sees a value that it previously encountered the `Series`. just like: `employees["Team"].duplicated().head()` The `duplicated`method's `keep`parameter informs pandas which duplicate occurrence to keep. `first`keeps the first occurrence of each duplicate value. like: `employees['Team'].duplicated(kee='first').head()`

`employees['Team'].duplicated(keep='last')`

Say, want to extract one employee from each team -- one strategy we could use is pulling out the first row for each unique team in the `Team`column - our existing `duplicated`method returns a `Series`. `True`identifies all duplicates values after the first. If invert that, get a `Series`in which `True`denotes the first time pandas encounters  a value like:

`(~employees['Team'].duplicated()).head()`

Now can extract one employee per team by passing the `Series`inside `[]`-- pandas will include the rows with the first occurrence of a value in the Team column like:

```py
first_one_in_team = ~employees['Team'].duplicated()
employees[first_one_in_team]
```

### The `drop_duplicates()`method

`drop_duplicates()`provides a convenient shortcut for accomplishing the op -- by default, the method removes rows in which all values are equal to those a previously encountered row. In the `employees`dataframe, there is no row which all values are equal, so no effect: `employees.drop_duplicates()`

Can pass the method a `subset`parameter with a list of columns that pandas should use to determine a row's uniqueness -- the next example finds the first occurrence of each unique value in the Team column -- in other words, pandas keeps a row only if it has the first occurrence of a Team Value like:

`employees.drop_duplicates(subset=['Team'])`

And the `drop_duplicates()`also accepts a `keep`- can pass it an `last`to keep the rows with each duplicate values's last occurrence. like: `employees.drop_duplicates(subset=['Team'], keep='last')`

Note, one additional option is available for the `keep`parameter, can pass an argument of `False`to exclude all rows with duplicate values. Pandas will reject a row if there are any other rows with the same value. like:

`employees.drop_duplicates(subset=['First Name'], keep=False).sort_values('First Name')`

These first names occur only once in the `DataFrame`.

Say, want to identify duplicates by a combination of values across multiple columns, may want the first occurrence of each employee wiht a unique combination of First Name and Gender -- for reference, here is a subset of all employee like

```py
name_is_douglas = employees['First Name']=='Douglas'
is_male= employees['Gender']=='Male'
employees[name_is_douglas & is_male]
```

Pass a list of columns to the `drop_duplicates()`subset parmeter will use the columns to determine the precence of duplicates, just like: uses a combination of values across the Gender and Team columns to identify duplicates like:

`employees.drop_duplicates(subset=['Gender', 'Team']).head()`

### Coding

1. Optimize the data set for limited memory use and maximum utility
2. Find all rows with a title
3. Find all with director
4. Find all with added of "2019-07-31".
5. drop all with `NaN`value in the director colun
6. Identify days when `Netflix`added only one movie to its catalog.

```py
netflix= pd.read_csv('../pandas-in-action/chapter_05_filtering_a_dataframe/netflix.csv', 
                     parse_dates=['date_added'])
netflix.info()
```

Fore, if want to convert any column's values to a different data type -- how about categorical values -- use the `nunique`method to count the number of unique values per column like:

```py
netflix['type']=netflix['type'].astype('category')
```

Then, need to use the equality operator to compare each title column value with the string `Limitless`like:

```py
netflix[netflix['title']=='Limitless']
```

Then, to extract movies directed by .. like:

```py
direct= netflix['director']=='Robert Rodriguez'
is_move=netflix['type']=='Movie'
netflix[direct & is_move]
```

And the next challenge asks for entries with a director of .. or -- one option is to create 3 Boolean Series, one for each of the 3 directors, and then use the | operator like:

```py
directors = ["Orson Welles", "Aditya Kripalani", "Sam Raimi"]
target_directors = netflix['director'].isin(directors)
netflix[target_directors]
```

The most concise way to find all rows with data_added value between is to use the `between()`.

```py
may_movies= netflix['date_added'].between(
    '2019-05-01', '2019-06-01'
)

netflix[may_movies]
```

The `dropna`method removes `DataFrame`rows with missing values, have to include the `subset`parameter to just limit the columns in which pandas should look for `null`vlaues.

`netflix.dropna(subset=['director']).head()`

Finally, identify the days when Netflix added only one movie to the service, one solution is to recognize that the date_added column holds the duplicate date values for titles added on the same day. just like:

`netflix.drop_duplicates(subset=['date_added'], keep=False)`

## Scrapping

From the listing, there are just two topics that warrant a closer look, redirection and authentication-- In browser, you will see that you are just immediately sent to another page -- now do the same in the python:

```py
import requests
url = 'http://www.webscrapingfordatascience.com/redirect/'
r = requests.get(url)
print(r.text)
print(r.headers)
```

In most cases, this default behavior is quite helpful -- requst is smart enough to follow redirects on its own when it receives 3xx status code. What if we want to just see the contents of the `Location`and **SECRET_CODE** headers manually -- can simply turn off requests default behavior of the following redirects through the `allow_redirects`arg:

`r = requests.get(url, allow_redirects=False)`

Simply turn off requests default behavior of the upper case.

Just take a closer look at the 401 `Unauthorized`status code, which seems to indicate the HTTP provides some sort of authentication mechanism.

- Browser performs a normal GET request to the page, and no authentication info is included
- Website responds with a 401 reply and a `WWW-authenticate`header
- your browser will take this as an opportunity to ask for a username and password, if cancel pressed, 401 shown

```py
url = 'http://www.webscrapingfordatascience.com/authentication/'
r = requests.get(url, auth=('a', 'a'))
```

### Dealing with Cookies

HTTP is just a rather simple networking protocol-- it is text based and follows a simple request-and-reply-based communication scheme -- in the smplest case, every request-and-reply-based communication scheme -- in the smplest case, every request-reply cycle in the HTTP involves setting up a fresh new underlying network connection as well. The simple request-reply-based approach poses some problms for websites -- from a web server's point of view, every incoming request is completely independent of any previous ones and can be handled on its own.

To tackle this issue in a more robust way, two headers were standardized in HTTP in order to set and send `cookies`-- small textual bits of info, the way how this works is relatively straightforward, when sending an HTTP response, a web **server** can include `Set-Cookie`headers as like:

```sh
Set-Cookie : sessionToken=...; Expires=...
```

Note that the server is sending two headers here with the same name -- Alternatively, the full header can be provided as a single line as well, where each cookie will be separated by a comma like:

The value of the `Set-Cookie`headers follows a well-defined std:

- A cookie name and cookie value are provided, separated by an equals =
- Additional attributes can be just specified, seaprated by a semicolon.
- `Domain`and `Path`can be set as well to define the sceop of the cookie. The essentially tell the browser what website the cookie belongs and hence in which cases to inlcude the cookie info in subsequent requests. Cookies can only be set on the current resource's top domain and its subdomains.
- Finally, also the `Secure`and `HttpOnly`attributes. - The `Secure`indicates that the browser should limit communication of this cookie to encrypted transmissions (HTTPs).

So, when browser receives a `Set-Cookie`header, it will store its information in its memory and will include the cookie information in all following HTTP requests to the website. To do so, another header is used, this time *in HTTP request*, just named `Cookie`like:

Note that here, the cookie names and values are simple included in one header line, and are separated by a semicolon; not a comma as is the case for other multi-valued headers. The web *server is then able to parse these cookies* on its end, and can then derive that this request belongs to the same session as a previous one, or do other things with the provided info. For some situations, need to set and inlcude a cookie, to do so, use a new argument -- called `cookies`, note that could use the `headers`argument to include a `Cookie`header.

```py
r = requests.get(url, cookies={'PHPSESSID':'5b9ibngblsdlbhrp1hfg07vk0k'})
print(r.text)
```

Hence, need to resort to a more robust system as follow, first perform a POST request simulating a login, get out the cookie value from the HTTP response, and use it for the rest of our session like:

```py
url = 'http://www.webscrapingfordatascience.com/cookielogin/'
r = requests.post(url, data=dict(username='a', password='b'))
my_cookies= r.cookies # get the cookies

r= requests.get(url+'secret.php', cookies=my_cookies)
print(r.text)
```

This works, though here are some real-life cases where you have to deal with more complex login.

## Using the Event Binding

The *event binding* is used to respond to the events sent by the host element -- demonstrates the event binding, which allows a user to interact with the Ng application.

`<td (mouseover)="selectedProduct=item.name">{{i+1}}<td>`

An event binding has these four parts -- 

1. The *host* element is the source of events for the binding
2. The *round brackets* tell Ng that this is an event binding, which is a form of one way binding where data flows from the element to the rest of the appliation.
3. The *event* specifies which event binding is for.
4. The *expression* is evaluated when the event is triggered.

The expression that displays the selected product uses the nullish coalecing operator to ensure that the user alwyas sees a message, even when no product is seleced, a neater is to define a method that perform this check like:

```ts
getSelected(product: Product) : boolean {
    return product.name== this.selectedProduct;
}
```

### Using Event Data

The previous example used the event binding to connect two pieces of data provided by the component -- when the `mouseevent`is triggered, the binding’s expression sets the `selectedProduct`prop using a data value was provided to the `ngFor`directive by the component’s `getProducts()`method.

The event binding can also be used to introduce a new data into the app from the event itself.

```html
<input class="form-control"
       (input)="selectProduct=$any($event).target.value" />
```

For this, when the browser triggers an event, it provides an `Event`object that describe it. there are different types of event objects for different categories of events -- mouse events, keyboard events, form events, and so on.

- `type`-- returns a `string`that identifies the type of event that has been triggered.
- `target`-- returns an `object`that triggered the event, which will generally be the object that presents the HTML element in the DOM.
- `timeStamp`-- returns a `number`that contains the time that the event was triggered.

For this, when the `input`is triggered, the browser’s DOM API creates an `InputEvent`object, and it is object that is assigned to the `$event`variable, the `InputEvent.target`prop returns an `HTMLInputElment`object, which is how the DOM represents the `input`element that triggered the event. `value`prop returns the content of the `input`element.

Note that the Ng assumes that the `$event`variable is always assigned an `Event`object, which defines the features common to all events -- the `Event.target`prop returns an `InputTarget`object, which defines just the methods requires to set up event handlers and doesn’t provide access to element-specific features.

So, ts was designed to accommodate this sort of problems using type assertions -- but in the View -- Angular doesn’t allow the use of the `as`keyword in template expressions. Angular do support the special `$any`function, which disables type checking treating a value as the special `any`type like:

`<input class="form-control" (input)="selctedProdcut=$any($event).target.value" />`

### Handling events in Component

Although type assertions cannot be performed in template, but can be used in the component class :

```ts
handleInputEvent(ev: Event){
    if(ev.target instanceof HTMLInputElement) {
        this.selectedProduct=ev.target.value;
    }
}
```

The `handleInputEvent()`receives an `Event`object and uses the `instanceof`operator to determine if the event’s `target`prop returns an `HTMLInputElement`.

```html
<input class="form-control"
           (change)="handleInputEvent($event)"/>
```

### Using Template Reference Variables

*Tempalte reference variables* are a form of template variable that can be used to refer to elements *within* the template.

```html
<div class="bg-info text-white p-2">
    Selected product: {{product.value ?? '(none)'}}
</div>
<table class="table table-sm table-bordered">
    <tr>
        //...
    </tr>
    <tr *ngFor="let item of getProducts(); let i= index"
        [class.bg-info]="product.value==item.name">
        <td (mouseover)="product.value=item.name??'' ">{{i + 1}}</td>
        //...
    </tr>
</table>

<div class="mb-3">
    <label>Product Name</label>
    <input #product class="form-control" (input)="false"/>
</div>
```

Reference variables are defined using the `#`character, followed by the variable name, defined a variable called `product`just like: 

`<input #product class="form-control" (input)="false" />`

When Ng encounters a reference variable in template, it sets its value to the element to which it has been applied. For this,  the `product`reference variable is assigned to the object that represents the `input`in the DOM. For this the `HTMLInputElement`object -- Reference variables can be used by other bindings in the same template.

This binding displays the `value`property defined by the `HTMLInputEement`that has been assigned to the product varaible or the string if the `value`property returns `null`or `undefined`.

The event binding responds to the `mouseover`event by setting the `value`prop on the `HTMLInputElement`that as been assigned to the `product`variable.

For the `(input)=false`-- Angular won’t update the data bindings in the template when the user edits the contents of the `input`unless there is an event binding on the element.

### Using Two-Way Data Bindings

Bindings can be combined to create a two-way flow of data for a single element -- allowing the HTML document to respond when the application model changes and also allowing the app to respond when the element emits an event.

```html
<div class="mb-3">
    <label>Product Name</label>
    <input class="form-control"
           (input)="selectedProduct=$any($event).target.value"
           [value]="selectedProduct ?? ''"/>
</div>
```

Each of `input`elements has an event binding and a property binding. The event binding responds to the `input`event by updating the component’s `selectedProduct`property. The property binding ties the value of the `selectedProduct`property to the element’s `value`property. 

And the event binding for the `mouseover`event still takes effect, which means that as you move the mouse pointer over the first row in the table, the changes to the `selectedProduct`value will cause the `input`elements to display the product name.

### Using the `ngmModel`Directive

The `ngModel`is just used to simiplify two-way bindings so that you don’t have to apply both an event and a property binding to the same element.

```html
<input class="form-control"
       [(ngModel)]="selectedProduct" />
```

Using the `ngModel`directive requires combining the syntax -- The target for the binding is the `ngModel`directive, which is included in Ng to simplify creating two-way bindings on form elements. So When the contents of the `input`elemetn change, the new content `selectedProduct`value changes, it will update the contents of the element.

And the `ngModel`knows the combination of events and properties that the std HTML elements define. Behind the scenes, an event binding is applied to the `input`event, and a property binding is applied to the `value`prop.

### Working with Forms

And most web apps rely on forms for receiving data from users, and the two-way `ngModel`bindign described provides the foundation for using forms in Ng applications. Create form that allows new products to be created and added to the app’s data model and then describe some of the more advanced features:

```ts
ewProduct: Product = new Product();

get jsonProduct() {
    return JSON.stringify(this.newProduct);
}

addProduct(p: Product) {
    console.log("New product: " + this.jsonProduct);
}
```

The listing adds a new prop called `newProduct`, which will be used to store the data entered into the form by the suer. There is also a `jsonProduct`prop with a getter that returns a JSON representation of the `newProduct`property and that will be usd in the template to show the effect of the two-way bindings.

```html
<div class="p-2">
  <div class="bg-info text-white mb-2 p-2">Model Data: {{jsonProduct}}</div>
  <div class="mb-3">
    <label>Name</label>
    <input class="form-control" [(ngModel)]="newProduct.name" />
  </div>
  <div class="mb-3">
    <label>Category</label>
    <input class="form-control" [(ngModel)]="newProduct.category" />
  </div>
  <div class="mb-3">
    <label>Price</label>
    <input class="form-control" [(ngModel)]="newProduct.price" />
  </div>
  <button class="btn btn-primary mt-2" (click)="addProduct(newProduct)">
    Create
  </button>
</div>
```

For this, each `input`elementis grouped with a `label`and contained a `div`element, which is styled using the `mb-3`