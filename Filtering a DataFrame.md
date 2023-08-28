# Filtering a DataFrame

Learned how to extract rows, columns, and cell values from a `DataFrame`by using the `loc`and `iloc`accessors. These work well when we know the labels and positions of the rows/columns we just want to target. Sometimes, we may want to target rows not by an identifier but by a condition or a criterion

### Optimizaing a data set for memory use

Whenever importing a data set, the "best" data type is the one that consumes the least memory or provides the most utility. -- Integers occupy less memory than floating-point numbers on most compusters. FORE, if your data set includes whole numbers, it's ideal to import them as integers rather then floating points -- If your data set includes them as integers rather then just float-points. And if data set includes dates, fore, it's just ideal to import them as datetimes rather than as strings -- which allows for datatime-specific operations.

```py
pd.read_csv('../pandas-in-action/chapter_05_filtering_a_dataframe/employees.csv', 
            parse_dates=["Start Date"])
empolyees.info()
```

This DF with 1001 rows, starting at index 0 to index 1000 -- There are four string columns, one datetime, and one floating-point column, 

### Converting data types with the `astype`method

For column -- The `astype()`converts a `Series`values to a different data type -- it accepts a single argument, the new data type -- can pass either the data type or a string with its name. So for the next example, just like:

`empolyees['Mgmt'].astype(bool)`

Can overwrite the existing `Mgmt`column in `empolyees`-- Updating a `DataFrame`column works similarly to setting a k-v pair in dictionary -- if a column with the specified name exists, pandas just overwirtes it with the new `Series`-- And if the column with the name does not exist, pandas creates a new `Series`and appends it to the right of the `DataFrame`. So the next code sample overwirtes the Mgmt column with our new `Series`of Booleans -- like:

`empolyees.Mgmt= empolyees.Mgmt.astype(bool)`

Next, transition to the `Salary`column -- like: In this, pandas stores the `Salary`values at floats -- To support `NaNs`throughout the column, pandas also converts the integers to floating numbers. Also use `astype`method like:

`employees.Salary.astype(int)`

For this An error raised -- Pandas is unable to convert the `NaN`values to integers -- can solve this problem by replacing the `NaN`values with a constant value -- the `fillna`method replaces a series's null value with the argument we pass in. like: `empolyees['Salary'].fillna(0).tail()` so just like:

`empolyees['Salary'].fillna(0).astype(int).tail()`
`empolyees.Salary = empolyees['Salary'].fillna(0).astype(int)`

And pandas has identified two unique categoreis -- `Female`and `Male`for the column `Gender`. For the Gender and the `Team`columns stand out as good candidates to store categorical values -- like:

`empolyees.Gender.astype('category')`

For this, pandas has identified two unique categories -- `Female`and `Male`-- good to overwrite our existing Gender like:

`empolyees.Gender= empolyees.Gender.astype('category')`
`employees.Team = employees.Team.astype('category')`

### Filtering by a single condition

Extracting a subset of data is perhaps the most common operation in data analysis. A *subset* is just a portion of a larger data set that fits some kind of condition. Fore, want to generate a list of all employees named "Maria". So, to compare every `Series`entry with a constant value, place the `Series`on one side of the equality operator and the value on the other like: `Series==value`. Pandas just smart enough to recognize that we want to just compoare the equality of each `Series`value qith the specified string -- not for the `Series`itself.

`empolyees['First Name']=='Maria'`

And, if could only the rows with `True`from the employees just like:

`empolyees[empolyees['First Name']=='Maria']`

And, if the use of the multiple square bracket is confusing - -can assign the `Boolean`sereis to a descriptive varaible. like:

```py
maris= employees['First Name']=='Maria'
employees[maris]
```

The most common mistakes -- when comparing the equality of values is using one equal sign instead of two. Remebmer that a single equal sign assigns an object to a variable -- and two equal signs check for equality between objects.

If want to extract a subset of employees who are not on the `Finance`-- just like:

`empolyees.Team!= 'Finance'`

`empolyees[empolyees['Team']!='Finance']`

And, note that the results includes rows with missing values -- can see an example at index 1000. So in this scenario, Pandas just considers a `NaN`to be unequal to the string `Finance`.

And, what if we want to retreive all the managers in the company -- Managers have a value of `True`in the `Mgmt`column -- could execute `empolyees['Mgmt']==True`like:

`empolyees[empolyees['Mgmt']].head()`

Can also use arithmetic operands to filter columns based on mathematical conditions -- the next example like:

```py
high_earners = empolyees['Salary']>100000
empolyees[high_earners].head()
```

### Filtering by multiple conditions

Can also filter a DataFrame with multiple conditions by creating two independent boolean `Series`and then declaring the logical criterion that pandas should apply between them. Fore, must look for conditions to select a row -- value of `Female`in the Gender and a value of `Business Dev`in the team column like:

```py
is_female= empolyees['Gender']=='Female'
in_biz_dev= empolyees['Team']=='Business Dev'
empolyees[is_female & in_biz_dev]
```

Pass both series into the square brackets, and place an `&`between them -- the ampersand decalres an `AND`logical criterion and the, And, can just include any amount of `Series`within the square brackets as long as we separate every subsquent two with a `&`symbol. like:

```py
is_manager = empolyees['Mgmt']
empolyees[is_female & is_manager & in_biz_dev]
```

### The OR condition

Can also extract rows if they fit one of several conditions - Not all conditions have to be true -- at least one does. Fore, suppose that want to identify all employees wtih a Salary below .. like:

```py
earning_below_40k = empolyees['Salary']<40000
started_after_2015= empolyees['Start Date']>'2015-01-01'
empolyees[earning_below_40k | started_after_2015]
```

And the rows at index postion -- 

### Inversion with ~

The tilde -- inverts the values in a *Boolean* `Series`-- All `True`values become `False`..like:

```py
my_series= pd.Series([True, False, True])
print(my_series)
print(~my_series)
```

Inversion is helpful when we'd like to reverse a condition, like:

```py
print(empolyees[empolyees['Salary']<100000].head())
empolyees[~(empolyees['Salary']>=100000)].head()
```

The syntax ensures that pandas generates the `Boolean`series before inverting its values.

### Methods of Booleans

Pandas provdies an alternative syntax for analysts who perfer methods over operators. like:

- Equality -- `employees['Team'].eq('Marketing')`
- And the `ne, lt, le, gt, ge`methods.

### Filtering by conditions

Ans some filtering operations are more complex than simple equality or inequality checks -- pandas ships many helper methods that generate Boolean Series for these types of extractions.

`isin`-- What if want to just isolate the employees who belong to either the .. could 3 separate boolean `Series`inside the square brackets and add the `|`symbol to declare `OR`criteria.

Although this solution works, but isn't scalable -- A better is the `isin`method -- which accepts an iterable of elements, and returns a Boolean `Series`-- `True`denotes that pandas found the row's value among the iterable's values, and `False`denotes that it did not. like:

```py
all_star_teams= ['Sales', 'Legal', 'Marketing']
on_all_star_teams= empolyees['Team'].isin(all_star_teams)
empolyees[on_all_star_teams]
```

### The `between`method

When wroking with numbers of dates, we often want to extrct values that fall within a range, suppose that we want to identify all employees with a salary between $8000.. Could create two `Boolean`Series, one to declare the lower bound and one to declare the upper bound -- then we could use the & operator to mandate that both condition are `True`.

```py
higher_than_80 = empolyees['Salary']>=80000
lower_than_90= empolyees['Salary']<90000
empolyees[higher_than_80 & lower_than_90].head()
```

So can just using the `between()`-- which accepts a lower bound and upper bound, and returns a `Boolean`, note that for the `between` -- the lower bound -- is inclusive, and the second, the upper bound, is exclusive. Namely: [80000, 90000),

```py
between_80k_and_90k= empolyees['Salary'].between(80000, 90000)
empolyees[between_80k_and_90k]
```

And the `between()`also works on columns of other data types -- to filter datetimes, can pass strings for the start and end dates of our time ranger -- fore:

```py
eighties_folk = empolyees['Start Date'].between(
    left='1980-01-01',
    right='1990-01-01',
)
empolyees[eighties_folk]
```

For this, the keyword parameters for the first and second parameters are `left`and `right`. Can also apply the `between()`method to string columns, can extract all employees whose first names start with the letter `R`, like:

```py
name_starts_with_r = empolyees['First Name'].between('R', 'S')
empolyees[name_starts_with_r].head()
```

### The `isnull`and `notnull`methods

The employees data set includes plenty of missing values, can see a few missing values in our first 5 rows-- Pandas marks missing text values and missing numeirc values just `NaN`-- it marks missing datetime value with a `NaT`designation -- can see an example in the `Start Date`column at index position 2. 

Can use several pandas methods to isolate rows with either null or present values in a given column. The `isnull`method returns a Boolean `Series`in which `True`denotes that a row's value is missing.

`empolyees['Team'].isnull().head()`

Pandas considers the `NaT`and `None`values to be null as well -- and the next invokes the `isnull()`on the `Start Date`:

`employees['Start Date'].isnull.head()`

And the `notnull`method returns the inverse series, one in which `True`just indicates that a row's value is present. like:

`empolyees['Team'].notnull().head()`

And can also produce the same result set by inverting the `Series`returned by the `isnull`method. like:

`(~employees['Team'].isnull()).head()`

Slao, can use these Boolean to extract specific `DataFrame`rows -- like:

```py
no_team = empolyees['Team'].isnull()
empolyees[no_team].head()
has_name= empolyees['First Name'].notnull()
empolyees[has_name].tail()
```

The `isnull`and `notnull`are the best way to quickly filter for present and missing vlaues in one or more rows.

## Working with Forms and `POST`requests

In cases where we have to submit a lot of info -- URLs become unusable to submit info, due to their maximum length restriction -- even if URLs should be unbounded in terms of length, they would still not care to a fully appropriate mechanism to submit info. If copy-paste such a URL in an e-mail and .. 

HTTP protocol also provides a number of different methods other than the GET method been working with so far. More specially, apart from a GET request, there is another type of requrest that your browser will often be using in case you wish to submit some info to a web server -- like:

Note that the default value for the method attribute is `get`, basically instructing your broser that the contents of this particular form should be submitted through an GET -- set to post, your browser will be instructed to send the info through an POST requst -- instead of including all the form info as URL parameters.

And the last page works in exactly the same way as the one before -- though with one notble differecen -- when you submit the form the server dosn't send back the same conrents as before, but provides an overview of the info that was just submitted.

Finally, there is one more thing that we just need to mention regarding web forms -- The data submitted to the form was send to the form was sent to the web server by constructing an HTTP rquest containing the same URL as the page the form was on.

Before moving on to other HTTP request methods, see how we can execute POST requests using Python -- In case a web form is using a GET request to submit information -- already seen how U can handle this use case simply by using the `request.get`method with the `params`args to embed the info as the URL parameters -- for a POST request, just need to use a new method -- `request.post`and a new `data`argument like:

```py
import requests
url = 'http://www.webscrapingfordatascience.com/postform2/'

r= requests.get(url) # first perform a get request

# followed by a POST request like:
formdata = dict (
    name='Seppe',
    gender = 'M', 
    pizza='like',
    haircolor='brown',
    comments=''
)
r= requests.post(url, data=formdata)
print(r.text)
```

So, just like `params`, the `data`argument is supplied as a Python dictionary object representing name-value pairs, Take some time to play aound with this URL in your web browser to see how data for the various input elements is actually submitted. in particular, note that for the radio -- all bear same `name`attribute.

Also need to note that in this, are still polite in this sense that we first execute a normal `GET`first. -- for this, this is not required -- can simply comment out the `get`. 

For the 3, The answer lies on one additional form element that is now present in the HTML source code like:

`<input type="hidden" name="protection" value=".....">`

So, this form incorporates a new hidden filed that will be submitted with the rest of the for data.

```py
import requests
from bs4 import BeautifulSoup
url = 'http://www.webscrapingfordatascience.com/postform3/'

r = requests.get(url)
soup= BeautifulSoup(r.text, 'html.parser')
p_val= soup.find('input', attrs=dict(name='protection')).get('value')

# followed by a POST request like:
formdata = dict (
    name='Seppe',
    gender = 'M', 
    pizza='like',
    haircolor='brown',
    comments='',
    protection=p_val
)
r= requests.post(url, data=formdata)
print(r.text)
```

The example illustrates a protective measure that you will encounter from time to time in real-life situations -- Website administartors do not necessarily include such extra measures as a means to prevent web scaping, but mainly for easons of safety and improving the user experiences.

And there are a few more things worth mentioning before can wrap up this -- no doubt have noticed that new uses `params`and `data`-- fore this, if `GET`use URL parameters, and `POST`send data as part of the HTTP rquest body, by using either the `requests.get`or `requests.post` -- answers lies in the fact that is perfectly fine for an HTTP POST to include both a request URL with parameters. fore, if encounter like:

```html
<form action="submit.html?type=student" method="post">
    //...
</form>
```

Will have to write like:

`r = requests.post(url, params={'type':'student'}, data = formdata)`

And, there is also one type of form element havn't discussed -- sometimes, you will encounter forms that allow you to upload files from your local machine to a web server like:

```html
<form action="upload.php" method="post" enctype="multipart/form-data">
    <input...
</form>
```

As well as the `enctype`parameter now present in the `form`tag -- Need to talk a little bit about the form encoding -- put simiply, web forms will first encode the information contained in the form before embedding it in the HTTP post request body -- currently, the HTML std foresees 3 ways how this encoding can be done -- like:

- `application/x-www-form-urlencoded`-- default -- the request body is formatted similarly to seen with the URL parameters -- & and = to separate data fields and name/value pairs.
- `text/plain`-- HTML5 generally only used for debugging purpose.
- `multipart/form-data`-- is more complicated but allows us to include a file's contents in the request body, which might be in the form of bindary, no textual data, hence need for a separate encoding mechanism.

### More on Headers

Now that finished with an overview of HTTP requrest methods, it's time to take a -- like:

```py
url = 'http://www.webscrapingfordatascience.com/usercheck/'
r = requests.get(url)
print(r.text)
```

Now that the website responds with .. how does it know - when just open the same page in a normal browser.. The requests library ties to be polite and includes a `User-Agent`heder to announce itself -- websites that want to prevent scrapers from accessing its contents can build in a simple check to block particular user agenets from accessing their contents. Will have to modify our request headers to blend in -- like:

```py
url = 'http://www.webscrapingfordatascience.com/usercheck/'
my_headers= {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'
}
r = requests.get(url, headers=my_headers)
print(r.text)
```

Just note that the `headers`argument does not completely overwrite the default headers completely, but updates it instead, keeping around the default entires too.

And, Apart from the `User-Agent`, here is another header -- the `Referer`header -- Browsers will include this header to indicate the URL of the web page that linked to the URL being requested. Some websites will check this to prevent deep links from working  -- try inspecting the requests your browser is making using this referer will be different or not included in the request headers.

```py
url = 'http://www.webscrapingfordatascience.com/referercheck/secret.php'
my_headers={
    'Referer': 'http://www.webscrapingfordatascience.com/referercheck/'
}
r= requests.get(url, headers=my_headers)
print(r.text)
```

Should also take a closer look at the HTTP reply headers, starting with the different HTTP response status codes like:

- 1XX -- informational status codes, indicating that a request was received and understood, 
- 2XX-- success status code, fore, 204 -- No Content - server will not return any content
- 3XX -- redirection status codes. Indicating that the client must take additional action to complete the request. fore 301 -- indicates that this and all future requests should be directed to the given URL, and 302 and 303(see other) indicates that the responses to the request can be found under another URL. 307, 308 -- indicates that a request shoud be repeated with another URL.

## Using `ngTemplateOutlet`directive

The `ngTemplateOutlet`directive is used to repeat a block of content as a specified location, which can be useful when you need to generate the same content in different places and want to avoid duplidation. Like:

```html
<ng-template #titleTemplate>
	<h4 class="p-2 bg-success text-white">
        Repeated content
    </h4>
</ng-template>

<ng-template [ngTemplateOutlet]="titleTempalte"></ng-template>
```

So the first step to define the template that contains the content that you want to repeat using the directive. This is done using the `ng-template`element and assignment it a name using a *reference variable*, like this:

`<ng-template #titleTemplate let-title="title">`

Then Ng encounters the reference variable, it sets its value to the element to which it has been defined, which is the `ng-template`element in this case, the second step is to insert the content into the HTML document like:

`<ng-template [ngTemplateOutlet]="titleTemplate">`

### providing Context Data

And the `ngTemplateOutlet`directive can be used to provide the repeated content object that can be used in data bindings defined within the `ng-template`like:

```html
<ng-template #titleTemplate let-text="title">
	{{text}}
</ng-template>

<!-- use that -->
<ng-template [ngTemplateOutlet]="titleTemplate"
             [ngTemplateOutletContext]="{title:'Header'}"></ng-template>
```

So to receive the context data, the `ng-template`element that contains the repeated content defines a `let-`attribute that specifies the name of a variable, similar to the expanded syntax used for the `ngFor`

### Using Directies without an HTML element

The `ng-container`element can be used to apply directives without using an HTML -- which can be useful when you want to generate content without adding to the structure of the HTML document displayed by the browser like:

```html
<div class="bg-info p-2 text-white">
  Product Names:
  <ng-container *ngFor="let item of getProducts(); let last= last">
    {{item.name}}<ng-container *ngIf="!last">,</ng-container>
  </ng-container>
</div>

```

So the `ng-container`element doesn’t appear in the HTML displayed by the browser, which means that it can be used to just generate content within elements -- in this, the `ng-container`elements is used to apply the `ngFor`directive, and the content it produces contains a second `ng-container`that aplies the `ngIf`directive.

### Understanding one-way binding Restrictions

Can’t use all the js or Ts language features -- Unsing Idemptent expressions -- One-way binding must be *idempotent* just meaning that they can be evaulated repeatedly without changing the state of the appliation. like:

As the messages show, Ng evaluates the binding expression several times before displaying the content in the browser. If an expression modifies the state of the app, such as removing obj from a queue.. won’t get the results you expect by the time the template displayed to the user.

```tsx
@Component({...})export class ProductComponent {
            //...
            counter: number=1;
           }
```

```html
<div class="bg-info p-2">
    counter: {{counter=counter+1}}
</div>
```

Ng will report an error if a data binding expression contains an operation that can be used to perform +=, =.. In addition, when Ng is running in development moe, it performs an additional check to make sure that one-way data bindings have not been modfieid after the expressions are evaluated.

```ts
get nextProduct(): Product | undefined {
    return this.model.getProducts().shift();
}
```

```html
<div class="bg-info p-2 text-white">
  next product is {{nextProduct?.name}}
</div>
```

When the browser reloads, will see the following error.

### Understanding the Expression Context

And, when Ng evaluates an expression, it does so in the context of the template’s component -- `{{nextProduct?.name}}`-- when Ng processes these, which Ng incorporates into the HTML document. The component is said to provide the template’s *expression context*.

The **expression context** means that you can’t access objects defined outside of the template’s component. And in particular, templates can’t access the global namespace -- the global namespace is used to define common utilities, such as `console`object, which defines the `log`. The global namespace also includs `Math`object, provides access to some useful arithmetic methods, `min, max`... FORE:

```html
<div>
    The rounded price is {{Math.floor(getProduct(1)?.price)}}
</div>
```

When Ng proceses this, will produce the error.

So, if want to access functionality in the global namespace, then it must be provided by the component, acting on behalf of the template, in the case of the example, the component could just define a `Math`prop that is assigned to the global object -- but template expressions should be as clear as simple.

```tsx
getProductPrice(index:number):number {
    return Math.floor(this.getProduct(index)?.price??0);
                      }
```

```html
<div class="bg-info p-2 text-white">
  The rounded is {{getProductPrice(2)}}
</div>
```

## Using events and Forms

In this, just continue describing the basic Ng functionality -- focusing on features that respond to user interaction -- Explain how to create event bindings and how to use two-way bindings to manage the flow of data between model and the template. One of the main forms -- HTML forms some:

- Event bindings evaluate an expression when an event is triggered, such as user pressing..
- These feaures allow the user to change the state of the app, changing or adding to the data in the model.
- In common with Ng bindings, the main pitfall is using the wrong kind of bracket to denote a binding.

### Importing the Forms Module

The features demonstrated in this rely on the Ng forms module, must be imported to the Ng module like:

```ts
@NgModule({
    ...,
    imports: [
    BrowserModule,
    FormsModule // need to note
    ]
})
```

The `imports`prop of the ng decorator specifies the dependencies of the app.

```html
<div class="p-2">
  <table class="table table-sm table-bordered">
    <tr><th></th><th>Name</th><th>Category</th><th>Price</th></tr>
    <tr *ngFor="let item of getProducts(); let i= index">
      <td>{{i+1}}</td>
      <td>{{item.name}}</td>
      <td>{{item.category}}</td>
      <td>{{item.price}}</td>
    </tr>
  </table>
</div>
```

### Using the Event Binding

The *event binding* is used to respond to the events sent by the host element -- like:

```html
<div class="p-2">
    <div class="bg-info text-white p-2">
        Selected product: {{selectedProduct??'(none)'}}
    </div>
    <table class="table table-sm table-bordered">
        <tr><th></th><th>Name</th><th>Category</th><th>Price</th></tr>
        <tr *ngFor="let item of getProducts(); let i= index">
            <td (mouseover)="selectedProduct=item.name">{{i+1}}</td>
```

Can just test the binding by moving the mouse over the first column in the HTML table.

- *host element* `td`is the source of events for the binding.
- The `(mouseover)`tell Ng that this is an event binding - which is a form of one-way binding where data flows from the element to the rest of the application.
- The *expression* just evaluated when the event is just triggered.

Unlike the one-way bindings, the expressions in event bindings can make changes to the state of the application and can contain assignment operators -- such as `=`, the expression for the binding assigns the value of the `item.name`prop to a variable called `selectedProduct`-- is used in a string interpolaiton binding. The value displayed by the string interpolatio binding is updated when the value of the `selectedProduct`is chagned by the event binding. For this, uses the *nullish coalescing* opretor to ensure that the user always sees a message. like:

```ts
getSelected(product: Product): boolean {
    return product.name == this.selectedProduct;
}
```

```html
<tr *ngFor="let item of getProducts(); let i= index"
    [class.bg-info]="getSelected(item)">
```

The result is that `tr`elements are added to the `bg-info`class when the `selectedProudct`property valeu matches the `product`object used to create them.

### Using Event Data

The previous example used the event binding to connect two pieces of data provided by the componetn -- when the `mouseevent`is triggered, the binding’s expression sets the `selectedProduct`property using a data value that was provided to the `ngFor`directive by the component’s `getProducts`method.

Note that the event binding can also be used to introduce new data into the app from the event itself -- using details that are provided by the browser, adds an `input`elemetn to the template and uses the event binding to listen like:

```html
<div class="mb-3">
    <label>Product Name</label>
    <input class="form-control"
           (input)="selectedProduct=$any($event).target.value" />
</div>
```

When the browser triggers an event, provides an `Event`object that describes it. there are different types of event objects for different categories of events -- 

- `type`-- returns a `string`that identifies the type of event that has been triggered
- `target`-- returns the `object`that triggered the event, which will generally be the oject that represents the HTML element in the DOM.
- `timestamp`-- returns a nubmer that contains the time that the event was triggered. ms from 1970.

Note that the `Event`object is assigned to a tmeplate variable called `$event`-- which binding expression like:

When the `input`element is triggered, the DOM API creates an `InputEevent`object, and that is ssigned to the `$event`variable -- the `InputEvent.target`returns an `HTMLInputElement`object, has a value prop. Ng just assumes that the `$event`variable is always assigned to an `Event`, whcih defines the features common to all events. so, `Event.target`returns an `InputTarget`object, doesn’t provide access to element-specific features.

So can use the Ng template attribute like `$any($event).target.value`expression. Using diffrent binding?