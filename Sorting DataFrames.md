# Sorting DataFrames

Can sort a `DataFrame`by one or more columns by using `sort_values()`. The `sort_values`first parameter, `by`, accepts the columns that pandas should use to sort `DataFrame`-- pass the `Name`column as a string like:

`nba.sort_values("Name")`

And this just `ascendin`parameter determiens the sort order, it has a default argument of `True`, so can:

`nba.sort_values("Name", ascending=False).head()`

Can sort the `Birthday`in reverse order by using the method with `ascending`set to `False`and then take 5 rows off the top with the `head()`method.

`nba.sort_values("Birthday", ascending=False).head()`

### Sorting by mutliple columns

Can sort multiple columns in `DataFrame`by passing a list to method's `by` -- Pandas will sort consecurively in the order, appear in the list - like:

`nba.sort_values(["Team", "Name"])`

Can pass a single Boolean to the `ascending`parameter to apply the same sort order to each eolumn. The next example passes `False`, so pandas first sorts the Team column in ascending order and then the Name Column in dsecending order. And, what if want to sort each column in a different order.

Can pass the `ascending`a list of Boolean values. Pandas will use shared index positions between the two lists to match just each column with its associated sort roder.

`nba.sort_values(by=['Team', 'Salary'], ascending=[True, False])`

And make some sort permanent -- the `sort_values()`method supports the `inplace`parameter -- explicit and reassing the returned `DataFrame`to the `nba`variable like:

`nba= nba.sort_values(...)`

### Sorting by index

With permanent sort, our DF is in a different order from when it arrived like: Just still havs its numeric index, if could sort the data set by index positions rather by column values, could return it to its original shape.

`nba.sort_index(ascending=False).head()`

`nba = nba.sort_index()`

### Sorting by column index

A `DataFrame`is a 2D data structure, can sort additional axis -- the vertical axis -- To srot the `DF`columns in order, again rely on the `sort_index`method -- need to add an `axis`parameter and pass it an argument of *column*. like:

`nba.sort_index(axis=1)`

And how about sorting the columns in reverse alphabetical order -- that task is a simple one -- can pass the `ascending`parameter an argument of `False`-- The next example invokes the `sort_index`method, targets the columns with the `axis`parameter, and sorts in descending order with the ascending parameter. just like:

`nba.sort_index(axis=1, ascending=False)`

### Setting a new index

At its core, data set is just a collection of players -- Therefore, it seems fitting to use the Name column's values as the `DataFrame`'s index labels -- Name also has the benefit of being the only column with unique values. the `set_index()`method returns a new `DataFrame`with a given column set as the index. Its first parameter, `keys`-- accepts the column name as a string.

`nba.set_index(keys="Name"); nba.set_index("Name")`

As a side note, can set the index when importing a data set -- pass the column name as a string to the `read_csv`function's `index_col`parameter. just like:

`nba= pd.read_csv("nba.csv", parse_dates=["Birthday"], index_col="Name")`

### Selecting columns and rows from a DataFrame

Each Series column is available as an attribute on the `DataFrame`-- use dot syntax to access object attributes, can extract the Salary column with `nba.Salary`-- fore, like: `nba.Salary`, and can also use the `nba["position"]`And the advantge of the square-bracket syntax is that it suports column names with spaces -- if our column was -- could extract it only via .. 

Selecting multiple columns -- To extract multiple columns, declare just a pair of opening and closing square bracket like:

`nba.[["Salary", "Birthday"]]`

The result will be a new `DataFrame`whose columns are the same order as the list elements. Pandas will extract the columns based on their order in the list like: -- Can also use the `select_dtypes`method to select columns based on their data types-- The method accepts parameters -- `include`and `exclude`. like:

`nba.select_dtypes(include="object")`
`nba.select_dtypes(exclude=["object", "int"])`

### Selecting rows from a DataFrame

Now that practiced extracting columns, learn how to extract `DataFrame`rows by index label or position like: The `loc`attribute extracts a row by lable, call attributes such as `loc`accessor cuz they access a piece of data -- type a pair of square brackets immediately after `loc`and pass in the target index label.

`nba.loc["LeBron James"]`

Can pass list in between the square brackets to extract mutliple rows, when the results are includes multiple records, pandas stores the results in a `DataFrame`. like:

`nba.loc[["Kawhi Leonard", "Paul George"]]`

Pandas organizes the rows in the order in which their index labels appear in the list -- The next example swaps the string order from the previous example like: Can also use `loc`to extract a sequence of index labels -- The syntax mirrors Py's list slicing syntax -- provide the string with a colon, and the ending value. like:

`nba.sort_index().loc["Otto Porter": "Patrick Beverley"]`

Note that the pandas' `loc`accessor has some differences with Python's list-slicing syntax, for one the *`loc`accessor includes the label at the upper bound*, whereas Py's list slicing syntax excludes the value at the upper bound.

Here is a quick example to remind that -- next example uses list-slicing syntx to extract the elements from index 0 to index 2 in a slit of three elements. like:

```py
nba.sort_index().loc['Zach Collins':]
nba.sort_index().loc[:'Al Horford']
```

Note that Pandas will just raise an exception if the index label does not exist in the DF -- like:

`nba.loc["Bugs Bunny"]` -- `KeyError`raised

### Extrcting rows by index position

And the `iloc`accessor extracts rows by index position, which is helpful when the position of our rows has significance in our data set. The syntax is similar to the one used for `loc`. Enter a pair of square brackets after `iloc`, and pass in an integer, pandas will extract the row at that index like:

`nba.iloc[300]`

The `iloc`accessor also accepts a list of index position to target mutliple records -- The next example pulls out the players at index position like:

`nba.iloc[[100,200,300,400]]`

can use list-slicing syntax with the `iloc`accessor as well, however, that pandas **excluseds** the index position after the colon. Like: `nba.iloc[400:404]`, just not includes 404.

Can leave out the number before the colon to pull from the start of the `DataFrame`-- target rows from the beginning of `nba`up to index position 2. LIke: `nba.iloc[:2]`

Simiarly, can remove the number after the colon to pull to the end of the `DataFrame`-- here, target the rows from index to the end of `nba` like: `nba.iloc[447:]`, note can also pass negative numbers for either value or both values -- the next example extracts rows from like; `nba.iloc[-10: -6]` . Can provide a 3rd number inside the sequare brackets to create just the step sequence like: `nba.iloc[0:10:2]`

### extracting vlaues from specific columns

Both `loc`and `iloc`attributes accept a second argument representing the colum(s) to extract -- if using `loc`, have to provide the column name. If are using `iloc`, have to provide the column position. like:

`nba.loc["Giannis Antetokounmpo", 'Team']`

To specify multiple values, need pass a list for one or both of the arguments to the `loc`accessor. And the next example extracts the row with index label and the values from the Position and Birthday columns like :

`nba.loc["James Harden", ['Position', 'Birthday']]`

And the next provides multiple row lables and multiple columns like:

```py
nba.loc[
    ['Russell Westbrook', 'Anthony Davis'],
    ['Team', 'Salary']
]
```

can also use list-slicing syntax to extract mutliple columns without explicitly writing out their names. Have four columns in the data set, just extract all columns from Position to Salary, Pandas includes both endponits in a `loc`slice.

`nba.loc['Joel Embiid', 'Position': 'Salary']`

Must pass the column names in the order in which they appear in the `DataFrame`. if note -- pandas is unable to identify which columns to pull out just.

Wanted to target columns by their order rather by their name, Remember that pandas assigns an index positoin to each `DataFrame`column -- Team column has an index 0, and Position has an index 1.. can pass a column has .. like:

`nba.ilic[57,3]`

Can use list-slicing syntax here as well, the next example pulls all rows from index positoin 100 up to but not including the index position 104. Just like:

`nba.iloc[..., :3]`

so the `iloc`and `loc`accessor are remarkably versatile, their square brackets can accept a single value, a list of values, a list slice, and more.

can also use two alternative attributes, `at` and `iat`-- when we know that we want to extract a single value from a `DataFrame`-- The two attributes are speedier cuz pandas can optimize its searching algorithm when looking for a single value. like:

```py
nba.at['Austin Rivers', 'Birthday']
nba.iat[263,1]
```

And just note that the `Jupyter`Notebook includes several magic methods to help enhance our developer experience. -- Declare magic methods with `%%`prefix and enter them alongside our regular Py code. like: `%%timeit`, which just runs the cess up to 100,000 times.

### Extracting values from Series

The `loc`, `iloc`and `iat`accessors are availabe on `Sereis`objects as well, can practice on a sample `Series`from our `DataFrame`just like: `nba['Salary'].loc['Damian Lillard']`

`nba['Salary'].iloc[345]`

Can change the index by assigning to the `index`attribute like:

```py
np.random.seed(0)
s= pd.Series(np.random.randint(70,101,10))
s.index='Sep Oct Nov Dec Jan Feb Mar Apr May Jun'.split()
np.random.seed(1)
months= 'Sep Oct Nov Dec Jan Feb Mar Apr May Jun'.split()
first_half_average=s['Sep':'Jan'].mean()
second_half_averge=s['Feb':'Jun'].mean()
first_half_average, second_half_averge
```

### Views and Copy

Numpy arrays return `views`when slice them. This means that you are working with a subset of the original array without copying the data.

A request message consists of the following:

- A Request line;
- A number of request headers, each on their own line
- An emtpy line
- An optional message body, which can also take up multiple lines.

And Ech line in the HTTP message must end with the `<CR><LF>` `0D0A`

And the HTTP std includes some headers that are standardized and which will be utilized by just proper web browser, through you are free to include additional headers as well -- 

```py
import requests
url = 'http://www.webscrapingfordatascience.com/basichttp/'
requests.get(url).text
```

Expand upon this example a bit further to see what is going on under the hood like:

```py
print(r.status_code)
print(r.reason) # what is the code
print(r.headers) # response header
print(r.request)
print(r.request.headers) # request header
print(r.text)
```

Just note that the `headers`attribute of the `request.Response`object returns a dictionary of the headers the server included in its HTTP reply. Servers can be pretty chatty, this server reports its data, version, and also `Content-Type`., And to get info regarding the HTTP request that was fired off, you can access the `request`of the `request.Response`, Since the `Request`message also includes headers, can access the `headers`attribute for this object to get a dictioanry representing the headers that were included by requests.

```py
url = 'http://www.webscrapingfordatascience.com/paramhttp/?query=A query with whitespace'
r= requests.get(url)
print(r.request.url)
print(r.text) # some error message
```

For this, properly resolve this -- A first method is to use just the `urllib.parse()`functions `quote`and `quote_plus`. The former is meant to encode special characters in the path section of URLs and encodes special characters using percent `%XX`encoding, including spaces.

```py
from urllib.parse import quote, quote_plus

raw_string= 'a query with /, space and ?&'
print(quote(raw_string))
print(quote_plus(raw_string))
```

```py
raw_string= 'a query with /, space and ?&'
url = 'http://www.webscrapingfordatascience.com/paramhttp/?query='
r= requests.get(url + quote_plus(raw_string))
print(r.url)
print(r.text)
```

And all this encoding juggling can quickly lead -- so for this problem just:

```py
parameter={
    'query':'A query with /, space and ?&'
}
r=requests.get(url, params=parameter)
r.text
```

Just note that the usage of the `params`argument in the `requests.get`method -- can simply pass a Python dictionary with your non-encoded URL parameters and requests will take care of encoding them for u.

```py
def calc(a, b, op):
    url ='http://www.webscrapingfordatascience.com/calchttp/'
    params= dict(a=a, b=b, op=op)
    r = requests.get(url, params=params)
    return r.text

calc(4, 6, '/')
```

### CSS Soup

- selector1~selector2 -- select all elements matching `selector2`that are placed after the `selector1`
- It is also possible to add more fine-tuned selection rules based on attribute of elements. `tagname[attributename]`selects all `tagname`elements where an attribute named `attriutename`is just present.
- `[attributename=value]`checks the actual value of an attriutes as well.
- `[attributename ~= value]`-- checks a space-separted list of class. 

```py
from bs4 import BeautifulSoup
url = 'https://en.wikipedia.org/w/index.php?title=List_of_Game_of_Thrones_episodes&oldid=802553687'
r = requests.get(url, proxies=dict(https='http://127.0.0.1:10811'))
html_contents = r.text
html_soup = BeautifulSoup(html_contents, 'html.parser')
```

```py
print(html_soup.find('h1'))
print(html_soup.find('', {'id':'ltr'}))
for found in html_soup.findAll(['h1','h2']):
    print(found)
```

## Using the Attribute Binding

There are some oddities in the HTML and DOM specifications that mean not all HTML element attributes have equivalent properties in the DOM API. ng provides the *attribute binding* -- which is used to set an attribute on the host element rather than setting the value of the Js object that represents in the DOM.

The most often used without a corresponding is `colspan`-- which is used to set the number of columns that a `td`will occupy in a table. like:

```html
<table class="table mt-2">
    <tr>
    	<th>1</th><th>2</th>...
    </tr>
    <tr>
    	<td [attr.colspan]="model.getProducts().length">
        	{{model.getProduct(1)?.name??'None'}}
        </td>
    </tr>
</table>
```

### Setting Classes and Styles

Ng provides special support in property bindings for assigning the host element to classes and for configuring individual style properties.

- `<div [class]="expr">`
- `<div [class.myClass]="expr">` -- evaluates the expression and uses the result to set the element’s member of  `MyClass`.

```tsx
getClasses(key:number):string {
    let product = this.model.getProduct(key);
    return 'p-2 '+ ((product?.price??0)<50 ? 'bg-info': 'bg-warning');
}
```

### Setting individual Classes using the special Class binding

The special class binding provides finer-grained control then the std prop binding and allows membership of a single class to manged using an expression.

```html
<div class="p-2"
     [class.bg-success]="(model.getProducts(2)?.price??0)<50"...
```

So the speical class bindings is specified with a target that combines the term `class`.

### Setting Classes using the `ngClass`Directive

The `ngClass`directie is more flexible alternative to the std and special prop bindings and behaves based on the type of data that is returned the expression. like:

- `String` -- This is added to the classes specified by the string.
- `Array`-- each object in the array is the name of a class that the host element will be added to.
- `Object`-- each is the name of the one or more classes.

```tsx
getClassMap(key:number) : Object {
    let product = this.model.getProduct(key);
    return {
        'text-center bg-danger': product?.name==='Kayak',
        'bg-info': (product?.price??0)<50,
    };
}
```

So for this, just the `Object{‘classname’:boolean}`

```html
<div class="p-2" [ngClass]="getClassMap(2)">
    ...
</div>
```

### The Styles Bindings

There are 3 different ways in which Can use data bindings to set style properteis of the host element like:

- `<div [style.myStyle]="expr">`
- `<div [sytle.myStile.units]="expr">`

```html
The <span [style.fontSize]="fontSzieWithUnits">First</span>
The <span [style.fontSize.px]="fontSzieWithoutUnits">Second</span>
```

### Setting styles using the `ngStyle`Directive

The `ngStyle`directive allows multiple style properties to be set using a map object, similar to the way that the `ngClass`works -- like:

```tsx
getStyles(key: number) {
    let product = this.model.getProduct(key);
    return {
        fontSize: "30px",
        //...
    }
}
```

```html
The <span [ngStyle]="getStyles(1)">First</span>
```

### Updating the Data in the Application

Binding are worth understanding cuz their expresions are re-evaluated when the data they dpend on changes. To provide a demonstration, take manual control of the updating proces.

```ts
constructor(ref: ApplicationRef) {
    (<any>window).appRef = ref;
    (<any>window).model = this.model;
}

getProductByPosition(position: number): Product {
    return this.model.getProducts()[position];
}

getClassesByPosition(position: number): string {
    let product = this.getProductByPosition(position);
    return 'p-2 ' + ((product?.price ?? 0) < 50 ? 'bg-info' : 'bg-warning');
                     }
```

Note, when Ng performs the bootstraping process, it creates an `ApplicationRef`object to represent the app. So can used as a ctor parameter. Within the ctor, two statement -- 

`(<any>window).appRef=ref;`

These statements define variables in the glboal namespace and assign the `ApplicationRef`and `Model`objects to them. It is good practice to keep the global namespace as clear as possible, but exposing these objects allows them to be manipulated through the browser’s Js console.

The other methods adds to the ctor allow a `Product`object to be retrieved from the repository based on its postion, rather than by its key.

```html
<div class="text-white">
  <div [ngClass]="getClassesByPosition(0)">
    The first product is {{getProductByPosition(0).name}}
  </div>

  <div [ngClass]="getClassesByPosition(1)">
    The second is {{getProductByPosition(1).name}}
  </div>
</div>

```

Then can just use the console to shift like:

`model.products.shift();`
`appRef.tick()`

The `tick`starts the Ng change detection process, where the Ng looks at the data in the app and expressions in the data binding and processes any changes.

## Using the Built-in Directives

Describe the bult-in directives that are reponsible for some of the most commonly required functionality for creating web applications -- Selectively including content, choosing between different fragments of content, and repeating content.

- The built-in directives described in this are reponsible for selectively including content, selecting between fragments of content, and repeating content for each item in an array.
- The tasks that can be just performed with these are most common and just fundamental in web apps.
- These are applied to HTML elemetns in templates.

```ts
getProduct(key: number): Product | undefined {
    return this.model.getProduct(key);
}

getProducts(): Product[] {
    return this.model.getProducts();
}

getProductsCount(): number {
    return this.getProducts().length;
}

targetName: string = "Kayak";
```

- `<div *ngIf="expr">`-- used to include an element and its content in the HTML document if the expression evaluates as `true`. The `*`just indicats this is a microtempalte directive
- `<div [ngSwitch]="expr"><span *ngSwitchCase="expr"><span *ngSwitchDefault>`-- used to choose between multiple elements to include in the HTML document based on the result of an expression, which then compared to the result of the individual expressions defined using the `ngSwitchCase`directives.
- `<div *ngFor="#item of expr">`-- is used to generate the same set of elements for each object in an array. `*`before the directive name indicates that this is a micro-tempalte
- `<div ngClass="expr">`
- `<ng-template [ngTemplateOutlet]="myTempl">`-- The `ngTemplateOutlet`is used to repeat a block of the content in the template.

### `*ngIf`Directive

`ngIf`is the simplest of the built-in directives and is used to include a fragment of HTML in the document like:

```html
<div class="text-white">
  <div class="bg-info p-2">
    There are {{getProductsCount()}} products.
  </div>

  <div *ngIf="getProductsCount()>4" class="bg-info p-2 mt-1">
    There are more than 4 products in the model
  </div>

  <div *ngIf="getProductByPosition(0).name!='Kayak'" class="bg-info p-2 mt-1">
    The first product isn't a Kayak
  </div>
</div>

```

Like all directives, the exprssion used for `ngIf`will be just re-evaluated to reflect changes in the data model. like:

### Using the `ngSwitch`Directive

The `ngSwitch`selects one of several elements based on the expression result, similar to a Js switch just like:

```html
<div class="bg-info p-2 mt-1" [ngSwitch]="getProductsCount()">
    <span *ngSwitchCase="2">There are Two products</span>
    <span *ngSwitchCase="5">There are five products</span>
    <span *ngSwitchDefault>This is the default</span>
</div>
```

And each of the inner elements, which are used as `span`elements in this example, is a micro-template, and the directives that specify the target expression result are prefixed with the `aterisk`.

### Avoiding literal Value problems

A common problem arises when using the `ngSwitchCase`directive to specify literal string values -- And care must be taken to get the right result like:

```html
<div class="bg-info p-2 mt-2" [ngSwitch]="getProduct(1)?.name">
    <span *ngSwitchCase="targetName">Kayak</span>
    <span *ngSwitchCase="'Lifejacket'">Lifejacket</span>
    <span *ngSwitchDefault>Other product</span>
</div>
```

### Using the `ngFor`directive

The `ngFor`just repeats a section of content for each object in an array -- proiding the template equivalent of a `foreach`loop just like:

```html
<div class="p-1">
    <table class="table table-sm table-bordered text-dark">
        <tr><th>Name</th><th>Category</th><th>Price</th></tr>
        <tr *ngFor="let item of getProducts()">
            <td>{{item.name}}</td>
            <td>{{item.category}}</td>
            <td>{{item.price}}</td>
        </tr>
    </table>
</div>
```

This eample specifies the component’s `getProducts()`as the source of data, which allows content to be for each of the `Product`objects in the model.

### Using other Template variables

The most important template variable is the one that refers to the data object being processd, which is `item`int the previous -- but `ngFor`directive supports a range of other valus that can also be assigned to the variables and then referred to wihtin the nested HTML elements like:

- `index`-- The `number`value is assigned to the position of the current object.
- `count`-- is assigned to the number of elements in the data source
- `odd`-- return `true`if the current has an odd-numbered position
- `even`-- boolean returns `true` if the current object has an even-numbered positoin 
- `first`-- `boolean`return `true`if the current object is the first one in the data source
- `last` -- `boolean`return `true`if the current object is the last one.

