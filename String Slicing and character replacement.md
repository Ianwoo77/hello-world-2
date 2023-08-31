# String Slicing and character replacement

Can use the `slice`method on the `StringMethods`object to extract a substring from a string by index position. The lower bound is inclusive, and the upper bound is exclusive. like:

`inspections['Risk'].str.slice(5,6).head()`

Aslo can replace the `slice`with py's list-slicing syntax - the following returns the just same result as the preceding code:

`inspections['Risk'].str[5:6].head()`

```py
inspections['Risk'].str[8:-1].head()
inspections['Risk'].str.slice(8).str.replace(')', '').head()
```

### Boolean methods

Need to ensure consistent casing across all column values before check for the presence of a substring. Can look for a lowercase -- the `contains()`method checks for a substring's inclusion in each `Series`value. The method returns `True`when pandas find the method's argument within the rows's string and `False`when it does not. like:

```py
has_pizza= inspections['Name'].str.lower().str.contains('pizza')
inspections[has_pizza]
```

And also a `str.startswith`method returning the `True`if a string begins with its argument. like:

`ends_with_tacos= inspections['Name'].str.lower().str.endswith('tacos')
inspections[ends_with_tacos]`

### Splitting strings

```py
customers['Name'].str.split(pat=' ').head()
customers['Name'].str.split(' ', n=1).str[0].head()
customers['Name'].str.split(' ', n=1).str.get(-1).head()
```

Have used two separate `get`method to extract the first and last names in two separate `Series`--  Just note that the `str.split`method accepts an `expand`parameter, and when pass it an argument of `True`, the method returns a new `DataFrame`instead of a `Series`of lists like:

```py
customers[['First Name', 'Last Name']]=customers['Name'].str.split(
    ' ', n=1, expand=True
)
customers= customers.drop(labels='Name', axis=1)
```

### Coding challange

Our customers data set includes an Address column, each address consists of a street, a city, a state and a zip code, is to separte these four values, assign them to a new columns.

```py
customers['Address'].str.split(',').head()
```

This split just keeps the spaces after the commas, would perfrom additional cleanup by using a method such as `strip`, but a better solution is available, if think about that -- each portion of the address is separated by a comma and a space. Therefore, can pass the `split`method a delimeter of both character like:

`customers['Address'].str.split(', ').head()`

And, by default, the `split`method returns a `Series`of lists, can make the method return a `DataFrame`by passing the `expand`parameter an arugmnet of `True`.

`customers['Address'].str.split(', ', expand=True).head()`

Have a couple more steps left -- add the new four-column `DataFrame`to our existing customer -- define a list with a new column names, -- assign the list to a variable to just simplify readability. Pass the list in square brackets before an equal sign -- right side of the equal sign, use the preceding code to create the new `DataFrame`. like:

```py
new_cols= 'Street City State Zip'.split()
customers[new_cols]=customers['Address'].str.split(', ', expand=True)
```

The last step is deleting the original Address column, and the `drop`method is a good solution here, -- to alter the `DataFrame`permantently, make sure to overwirte customers with the returned DataFrame.

```py
customers.drop(labels='Address', axis='columns').head()
# another option is to use Py's built-in del keyword like:
del customers['Address']
```

### A note on regular expressions

Note that any discussion of working with text data is incomplete without mentioning regular expressions, also known as RegEx -- A *regular expression* is a search pattern that looks for a sequence of characters with a string. We just declare regular expressions with a special syntax consisting of symbols and characters. `\d`fore. like:

```py
customers['Street'].head()
customers['Street'].str.replace("\d{4}", "*", regex=True).head()
```

So, Regular expressions are highly specialized technical topic.

## MultiIndex DataFrames

The number of dimensions is the number of reference points we need to extact a value from a data structure, Need only one label or one index position to locate a value from a data structure, need only one label or one index position to locate a value in a `Series` -- need two reference points to locate a value in a DF. Pandas also supports data sets with **any number** of dimensions through the use of `MultiIndex`-- is an index object that holds multiple levels, Each level stores a value for a row. It is optimal to use a `MultiIndex`when a combination of values provide the best identifier for a row of data. Suppose want to find just a uniqie identifier for each price -- neigher a stock's name nor its date is sufficient by itself. But the combination is good.

So a `MultiIndex`is just also ideal for *hierarchical* data -- data in which one column's valuses are subcategory of another column's values. Fore, The Item column's values are subcategories of the Group column's values. The `MultiIndex`is an obscure feature. 

### The MultiIndex object

`Series`and `DataFrame`indices can hold various data types -- strings, numbers.. Can create a `MultiIndex`object independently of a `Series`or `DataFrame`-- The `MultiIndex`class is just available as a top-level attribute on the pandas library, includes a `from_tuples`class method that instantiates a `MultiIndex`from a list of tuples. Like:

```py
addresses = [
    ("8809 Flair Square", "Toddside", "IL", "37206"),
    ("9901 Austin Street", "Toddside", "IL", "37206"),
    ("905 Hogan Quarter", "Franklin", "IL", "37206"),
]
pd.MultiIndex.from_tuples(addresses)
```

Have our own `MultiIndex`-- which stores three tuples of 4 elements each- and there is a consistent pattern to ech tuple's elements -- 

- The first value is the address
- Second is city...

In pandas terminology, the collection of tuple vlaues at the same position forms a *level* of `MultiIndex`-- in the example, the first `MultiIndex`level consists of the value -- Can assign each `MultiIndex`level a name by passing a list to `from_tuples`method's `names`parameter.

`pd.MultiIndex.from_tuples(addresses, names='Street City State Zip'.split())`

To summarize - -a `MultiIndex`is a storage container in whcih each lable holds multiple values. Now that have this, attach to a `DataFrame`-- The eaiest way is to use the `DataFrame`'s ctor's `index`parameter, just passed this parameter a list `MultiIndex`we just assigned to the `row_index`variable like:

```py
data = [
    ['A', 'B+'],
    ['C+', 'C'],
    ['D-', 'A']
]
columns = ['Schools', 'Cost of Living']
area_grades = pd.DataFrame(data, index=row_index, columns=columns)
area_grades
```

For this, have a `DataFrame`with a `MultiIndex`on its row axis -- and each row's label holds 4 values, a street, a city.. Turn our focus to the column axis, pandas stores a `DataFrame`'s column headers in an index object as well. Can just access that index via the `columns`attribute.

`area_grades.columns` # also `Index`object

Pandas currently stores the two column names in a single-level `Index`object -- create a second `MultiIndex`and attach it to the column axis -- The next example invokes the `from_tuples`class method again, passing it a list of 4 tuples. Then attach both of our `MultiIndexes`to a `DataFrame`. Like:

```py
column_index = pd.MultiIndex.from_tuples([
    ("Culture", "Restaurants"),
    ("Culture", "Museums"),
    ("Services", "Police"),
    ("Services", "Schools"),
])
data = [
    ["C-", "B+", "B-", "A"],
    ["D+", "C", "A", "C+"],
    ["A-", "A", "D+", "F"]
]
pd.DataFrame(data, index=row_index, columns=column_index)
```

For this, are ready to put the pieces together and create a `DataFrame`with a `MultiIndex`on both the row and column axes.

### MultiIndex DataFrames

```py
neighborhoods = pd.read_csv(
    '../pandas-in-action/chapter_07_multiindex_dataFrames/neighborhoods.csv')
neighborhoods
```

Something is off here, have 3 Unnamed columns, each one ending in a different number, when importing a CSV, pandas assumes that the file's *first row holds the column names*, also known as a headers. If a header slot does not have a value, pandas assigns a title just of `Unnamed`to the column.

The four columns to the right have the same naming issue. And noticed that pandas assigns a title of `Culture`to the column at index 3 and Culture 1 to the one after that. 

And.. in row 0, each of the first three columns holds a `NaN`value, and in row 1, have `NaN`values present in the last four columns. The issue is that the CSV is trying to model a multilevel row index and a multilevel column index, but the default argumnets to the `read_csv`function's parameters don't recongnize it.

So, first, have to tell pandas that the three leftmost columns should serve as the index of the `DataFrame`, can do this by passing the `index_col`parameter a list of numbers, each of representing the index of a column that should be in the `DatFrame`'s index. And the index starts ounting from 0. like:

```py
neighborhoods = pd.read_csv(
    '../pandas-in-action/chapter_07_multiindex_dataFrames/neighborhoods.csv',
    index_col=[0,1,2])
neighborhoods.head()
```

## Binary JSON and Other Forms of Content

```py
import requests
url = '...jpg'
r= requests.get(url)
with open('image.jpg', 'wb') as my_file:
    my_file.write(r.content)
```

However, note that when using this method, Py will store the full file contents in memory before wirting to file. So, when tackle this, requests allow to stream in a response by stting the `stream`arg to `True` like:

`r = requests.get(url, stream=True)`

Once you have indicated that you want to stream back a response, can work with the following attributes and methods like:

- `r.raw`provides a file-like object representaiton of the response, this is not often used directly and is included for advanced purpose
- `iter_lines`- allows you to iterate over a content body line by line
- `iter_content`method deos the ame for the binary data.

```py
r = requests.get(url, stream=True)
with open('image.jpg', 'wb') as f:
    for byte_chunk in r.iter_content(chunk_size=4096):
        f.write(byte_chunk)
```

And, there is another form of content you will encounter a lot of when working with websites, JSON -- a lightweight textual data interchange format that is both relatively easy for humans to red and write and easy for machines to parse and generate. It is based on a subset of the Js programming language. But its suage has become so widespread that virtually every programming language is able to red and generate that.

- POST requests are being made to results.php
- The `Content-type`header is set to `application/x-www-form-urlencoded`.
- An `api_code`is submitted in the POST request body
- The HTTP response has a `Content-Type`header set to `application/json`.

And working with a JSON-formatted replies in request is easy just use `text`-- then to the json module to do -- but the requests also provides a helpful `json()`to do this in one go:

```py
url ='http://www.webscrapingfordatascience.com/jsonajax/results.php'
r=requests.post(url, data=dict(api_code='C123456'))
print(r.json())
r.json().get('results')
```

There is one important remark here, some APIs and sites will also use an `application/json`content-type for formatting the request and hence submit the POST data as plain JSON. Using a request's `data`arg will not work in this case.

```py
url ='http://www.webscrapingfordatascience.com/jsonajax/results2.php'
r=requests.post(url, json=dict(api_code='C123456'))
print(r.json())
r.json().get('results')
```

### Dealing with Js

Together with HTML and CSS, js forms the 3rd and final core building block of the mdern web. Just take a look at how we can deail with this use case using requests and BS4 like:

```py
r= requests.get(url)
soup= BeautifulSoup(r.text, 'html.parser')
ul_tag=soup.find('ul')  # no found
print(ul_tag)
script_tag=soup.find('script', attrs={'src':None})
print(script_tag)
```

no `<ul>`tag will be found on the page, can take a look at the `<script>`tag -- but to BS, this will look at any other HTML tag with a bunch of text inside.

```py
r= requests.get(url, cookies={'jsenabled':'1'})
print(r.json())
```

### Scraping with Selenium

Is a powerful web scraping tool that was originally developed for the purpose of automated webstie testing-- works by automating browsers to load a web site, retrieve its content.

```python
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By

url = 'http://www.webscrapingfordatascience.com/complexjavascript/'
service = Service(executable_path=r'C:\Windows\System32\chromedriver.exe')
driver = webdriver.Chrome(service=service)

# set an implicit wait
driver.implicitly_wait(10)
driver.get(url)
for quote in driver.find_elements(By.CLASS_NAME, 'quote'):
    print(quote.text)
    
input('press enter to close the browser')
driver.quit()
```

## Creating Attribute Directives

in this, describe how custom directives can be used to supplement the functionality provided by the built-in ones of Angular -- The focuse of this is *attribute* directives -- which are just simplest type that can be created and that change the appearance of behavior of a single element. Explain how to create *structurual* directives.

- Attribute directives are classes that can modify the behaivor or appearance of the element they are applied to.
- The built-in directives conver the most common tasks reuired in web app
- Attribute directives are classes to which the `@Directive`decorator has been applied.

```html
<div class="row p-2">
  <div class="col-6">
    <form class="m-2" (ngSubmit)="submitForm()">
      <div class="mb-3">
        <label>Name</label>
        <input class="form-control" name="name" [(ngModel)]="newProduct.name" />
      </div>

      <div class="mb-3">
        <label>Category</label>
        <input class="form-control" name="category" [(ngModel)]="newProduct.category" />
      </div>

      <div class="mb-3">
        <label>Price</label>
        <input class="form-control" name="price" [(ngModel)]="newProduct.price" />
      </div>

      <button class="btn btn-primary" type="submit">Create</button>
    </form>
  </div>

  <div class="col">
    <table class="table table-sm table-bordered table-striped">
      <tr><th></th><th>Name</th><th>Category</th><th>Price</th></tr>
      <tr *ngFor="let item of getProducts(); let i= index">
        <td>{{i+1}}</td>
        <td>{{item.name}}</td>
        <td>{{item.category}}</td>
        <td>{{item.price}}</td>
      </tr>
    </table>
  </div>
</div>

```

```ts
getProduct(key: number): Product | undefined {
    return this.model.getProduct(key);
}

getProducts(): Product[] {
    return this.model.getProducts();
}

newProduct: Product = new Product();

addProduct(p: Product) {
    this.model.saveProduct(p);
}

submitForm() {
    this.addProduct(this.newProduct);
}
```

### Creating a simple Attribute Directive

The best place to jump and create a directive to see -- just like:

```ts
import {Directive, ElementRef} from "@angular/core";

@Directive({
  selector: "[pa-attr]",
})
export class PaAttrDirective {
  constructor(element: ElementRef) {
    element.nativeElement.classList.add('table-success', 'fw-bold');
  }
}
```

Directives are classes to which the `@Directive`decorator has been applied, the decorator requires the `selector`prop, which is used to specify how the directive is applied to elemens, expressed using a std CSS style selector. The selector used is `[pa-attr]`-- which will match *any element* that has an attribute called `pa-attr`-- regardless of the elemetn type or the value assigned to the attribute.

Custom directives are given a distinctive prefix so they can be easily recognized. The prefix can be anything meaningful to your application -- have chsen the `pa`.

Note that the directive ctor defines a single `ElementRef`parameter - is privded when it creates a new instance of the directive and which *represents the host element*. The `ElementRef`class defines a single property, `nativeElement`which returns the object used by the browser to represent the element in the DOM. This object provides access to the methods and properties that manipulate the element and its contents, including the `classList`property, which can be used to manage the class membership of the element.

`element.nativeElement.classList.add('...')`

To summarie, the class is a directive that is applied to elements that have a `pa-attr`attribute and adds those elements to the `table-success`and `fw-bold`classes

### Applying a custom Directive

There are two steps to apply a custom directive, the first is to update the tempalte so that there are one or more elements that match the `selector`that the directive uses.

```ts
declarations: [
    ProductComponent,
    PaAttrDirective,
],   // in the module file
```

Note that the `declarations`prop of the `NgModule`decorator declares the directives and components that the app wil use -- Once both steps have been completed.

### Accessing App Data in a Directive

The example in the previous section shows the basic structure of a directive, but it doesn’t do anything that couldn’t be performed just by using a `class`prop binding on the `tr`element. Directives become useful when they can interact with the host element and wtih the rest of the application.

### Reading Host Element Attributes

The simplest way to make a directive more useful is to configure it using attributes applied to the host element, which allows each instance of the directive to be provided with its own configuration info and to adapt its behavior accordingly.

FORE, just applies the directive to some of the `td`elements in the template table and adds an attribute that specifies the class that the host should be added to. And the directive’s selector means that it will match any element that has the `pa-attr`attribute, regardless of the tag type, and will work as well on `td`elements as it does on `tr`elements.

```html
<td pa-attr pa-attr-class="bg-warning">{{item.category}}</td>
<td pa-attr pa-attr-class="bg-info">{{item.price}}</td>
```

The `pa-attr`attribute has been applied to two of the `td`elements, along with a new attribute alled `pa-attr-class`, which has been used to specify the class to which the directive should add the host element. The changes is required:

```ts
export class PaAttrDirective {
  constructor(element: ElementRef, @Attribute("pa-attr-class") bgClass:string) {
    element.nativeElement.classList.add(bgClass || 'bg-success', 'fw-bold');
  }
}
```

So, to receive the value of the `pa-attr-class`attribute, added a new ctor parameter called `bgClass`which the `@Attribute`decorator has been applied -- This decorator is defined -- and it specifies the name of the attribute that should be used to provide a vlaue for the ctor parameter when a new instance of the directive class is created. Ng creates a new instance of the decorator for each element that matches the selector and uses that element’s attributes to provide the values for the directive ctor arguments that have been decorated with `@Attribute`.

And, within the ctor, the value of the attribute is passed to the `classList.add`, with a default value that allows the directive to be applied to elements that have the `pa-attr`attribute but not the `pa-attr-class`. Uses the `||`operator but not `??`to do that.

### Using a single Host Element Attribute

Using one attribute to apply a directive and another to configure it is redundant. And it makes more sense to make a single attribute just do double duty.

`constructor(element: ElementRef, @Attribute("pa-attr") bgClass:string) {`

The `@Attribute`decorator now specifies the `pa-attr`as the source of the `bgClass`parameter value.

```html
<tr *ngFor="let item of getProducts(); let i= index" pa-attr>
    <td>{{i+1}}</td>
    <td>{{item.name}}</td>
    <td pa-attr="bg-warning">{{item.category}}</td>
    <td pa-attr="bg-info">{{item.price}}</td>
</tr>
```

There is no visual change in the result produced by this example, has simiplifed the way that the directive is applied in the HTML template.