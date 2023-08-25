# Selecting Columns and Rows from a DataFrame

A `DataFrame`is a collection of `Series`objects with just column index. Multiple syntax options are available to extract one or more of these `Series`from the `DataFrame`.

Each `Series`column is available as an attribute on the `DataFrame`, use dot syntax to access object attributes. Can extract the with just the `nba.Salary`.

`nba.Salary, nba["Position"], nba["Player Position"]`

The attribute syntax would raise an exception, Python has no way of knowing this significance of the space and would assume that we're trying to access a player column.

### Selecting multiple columns from a Df

Just like: `nba[["Salary", "Birthday"]]`

Can just use the `select_dtypes`method to select columns based on their data types -- The method accepts two parameters -- `include`and `exclude`-- The parameters accept a single stirng or a list, representing the column type(s) that pandas would keep or discard. like:

`nba.select_dtypes(include="object")`
`nba.select_dtypes(exclude=["object'", "int"])`

### Selecting Rows from the DataFrame

Note that, using the `loc`extracts a rwo by label -- call attributes such as `loc`accessors cuz they access a piece of data. Type a pair of square brackets immediately after `loc`

`nba.loc[["Kawhi Leonard", 'Paul George']]`

And, Pandas organizes the rows in the order in which their index labels appear in the list. Can use the `loc`to extract a sequence of index labels, the syntx mirrors Py's list slicing syntax -- provide the starting vlaue, a colo. and the ending value, just recommanded storing the index first, as it accelerates the speed. like:

`nba.sort_index().loc["Otto Porter": "Patrick Beverley"]`

Note that the panda's `loc`accessor has some differences with Py's list-slicing syntax. For one, the `loc`accessor includes the label at the upper bound, whereas Python's list slicing syntax excludes the value at the upper bound.

Here is a quick example to remind you -- next example uses list-slicing synax to extract the elements from index 0 to index 2 in a list of three elements. like:

Can use the `loc`to pull rows from the middle of the `DataFrame`to its end. Pass the `[]`the starting index label and a colon like: `nba.sort_index().loc['Azch Collins':]` -- turning in the other can:
`nba.sort_index().loc[:'Al Horford']`

Note that Pandas will raise an `KeyError`if the index label does not exist in the `DataFrame`.

### Extracting rows by index position

The `iloc`accessor extracts rows by index position, which is helpful when the position of our rows has significance in our data set -- The syntax is similar to the one we used for `loc`. Enter a pair of square brackets aftier `iloc`-- and pass in an integer, Pandas will extract the row at that index. `nba.iloc[300]`.

The `iloc`accessor also accepts a list of index positions to target multiple records -- the next example like:

`nba.iloc[[100,200,300,400]]`

For this, the list-slicing syntax with the `iloc`-- excludes the index position after the colon. Can also provide a third number inside the `[]`to create the step sequence -- a gap between every two index position. `nba.iloc[0:10:2]`

### Extracting values from specific columns

Both `loc`and `iloc`attributes accepts a second argument representing the column(s) to extract. If are using `loc`, where have to provide the column name like: `nba.loc['Giannis Antetokounmpo', 'Team']`

To specify multiple values, can pass a list for one for both of the arguments to the `loc`accessor -- the next like:

`nba.loc['James Harden', ['Position', 'Birthday']]`

And the provide multiple row labels and multiple columns -- like:

```py
nba.loc[
    ['Russell Westbrook', 'Anthony Davis'], ['Position', 'Birthday']
]
```

Can also use list-slicing syntax to extract mutliple columns without explicitly writing out their names -- fore, have 4 columns in data set -- extract all columns -- `nba.loc['Joel Embiid', 'Position':'Salary']`

And, must pass the column names in the order in which they appear in the `DataFrame`-- the next example yields an empty result cuz the Salary column comes after the Position column like: So can:

`nba.iloc[100:104, :3]`

The `iloc`and `loc`accessors are remarkably versatile -- their `[]`can accept a single value, a list of vlaues, a list slice, and more. The disadvantage of this flexibility is that it demands extrac overhead.

can use alternative attributes -- `at`and `iat`-- when know that we want to extract a single value from a DF, The two attributes are speedier cuz can optimize tis searching algorithms when looking for a single value.

`nba.at["Austin Rivers", "Birthday"]`
`nba.iat[263, 1]`

### Extracting values from Series

The `loc`and `iloc`, `at, iat`accessor are available on `Series`objects too -- can just:
`nba.Salary.loc['Damian Lillard']`
`nba['Salary'].at['Damian Lillard']`
`nba['Salary'].iloc[234]`

### Renaming columns or rows

For the `columns`attribute, -- it exposes the `Index`object that stores the DF's column names like:

`nba.columns` -- Can rename any or all of the DF's columns by assigning a list of new names to the attribute -- like:
`nba.columns=['Team', 'Position', 'Date of Birth', 'Pay']`

And, the `rename`method is an alternative option that accomplishes the just same result , can pass to its `columns`parameter a dictionary in which the keys are the existing, and the valuess are new names like:

`nba.rename(columns={'Date of Birth':'Birthday'})`

Can also rename index labels by passing a dict to the method's `index`parameter -- and the same logic applies just. Keys are old labels, and values are the new ones. like:

`nba.rename(index={'ginnis Antetokounpo': "Greek Freak"})`

### Resetting an index

Sometimes, we need to set another column as the index of `DataFrame`, likeso, wanted to make Team of the inex of `nba`, could invoke the `set_index`method - but would lose our current index of player names. like -- To preserve the player's names, must first reintegrate the existing index as a regular oclumn in the df, the `reset_index`method moves the current index to a `DataFrame`column and replaces the former index with panda's numeric index like:

`nba.reset_index()`

Now can: `nba.reset_index().set_index('Team').head()`

One advantage of avoiding the `inplace`parameter is that we can just chain multiple method calls.

Code Challenge -- 

```py
nfl = pd.read_csv('../pandas-in-action/chapter_04_the_dataframe_object/nfl.csv', 
                  parse_dates=['Birthday'])
nfl.set_index('Name')
```

And, to count the number of players per team like:

`nfl.Team.value_counts()`

To identify the 5 highest-paid, we can use the `sort_values()`to srot like:

`nfl.sort_values('Salary', ascending=False).head(5)`

To sort by multiple columns, we will have to pass arguments to both the `by`and `ascending`paramters of the `sort_values`method and the following sorts the Team like:

`nfl.sort_values(by=['Team', 'Salary'], ascending= [True, False])`

Fore, oldest player on the New York jets roster -- like:

 `nfl.loc['New York Jets'].sort_values('Birthday').head(1)`

## Soup

- `html.parser`-- built-in parser that is decent and requires no installation
- `lxml`-- fast, but requires an extra installation
- `html5lib`-- aims to parse web page in extractly the same way as a web browser does, but slower.

Since there are small differences between these parsers, Soup warns U if you don't explicitly provide one, this might cause your code to just behave slightly different when exeuting the same script on different machines.

And BS' main task is to take HTML content and transform it into a tree-based representation -- once you have created a `BeautifulSoup`object, there are two main methods be using fetch data from the page like:

- `find(name, attrs, recurive, string, **keywords)`
- `find_all(name, attrs, recrisive, string, limit, **keywords)`

```py
html_soup.find('h1')
html_soup.find('', {'id':'p-logo'})
for found in html_soup.findAll(['h1', 'h2']):
    print(found)
```

The general idea behind these two methods should be relatively clear -- they are used to find elements inside the HTML tree -- The `attrs`argument takes a Python dictionary of attributes and matches HTML elements that match those attributes -- like:

- `recursive`argument is a Boolean and governs the depth of the search - if `True`-- also *default* -- the `find`and `findAll`methods will look into children.. and so on.. for elements that match your query, -- if it is just `False`, will only look at the direct child elements.
- The `string`arg is used to perform matching bsed on the *text content* of elements.
- The `limit`arg is only used in the `find_all`method and can be used to limit the number of elements that are retrieved, note that `find`is functionally equivalent to calling `find_all`with the `limit`set to 1. And the `find_all`just returns the list of them.
- `**keywords`is kind of a special case. Basically, this part of the method signature indicates that you can add in as many extra named arguments as like: note that which will then simply be used as attribute filters. FORE: `find(id='myid')`same as `find(attrs={'id':'myid'})`. If you define both `attrs`argument and extra keywords, all of these will be used together as filters. For this, like : `find(class_='myclass')`

Both `find`and `find_all`returns a `Tag`object -- there are number of interesting things can do:

- Access the `name`attribute to retrieve the tag name
- Access the `contents`attribute to get a python list contianing the tag's `children`as a list (direct descendant)
- `Children`attr does the same but provides an iterator, and `descendants`also returns an iterator
- when go up, also `parent`and `parents`and `next_slibing(s)`, and `previous_siblings`.
- Converting the `Tag`to a string shows both the tag and its HTML content as a string.
- Access the attrs of the elemetn through the `attrs`of the `Tag`object.
- `Text`get the contents
- Can use the `get_text`-- like `get_text(strip=True)`
- If a tag only has one child, and it is just a text node, can use `string`attribute to get the textual content.
- Not all `find`and `find_all`searches need to start from your original `BeautifulSoup`objects.

```py
import requests
import bs4
from bs4 import BeautifulSoup
url = 'https://en.wikipedia.org/w/index.php?title=List_of_Game_of_Thrones_episodes&oldid=802553687'
r = requests.get(url, proxies=dict(https='http://127.0.0.1:10811'))
html_contents = r.text
html_soup = BeautifulSoup(html_contents, 'html.parser')
first_h1= html_soup.find('h1')

print(first_h1.name)
print(first_h1.contents) # tag's children
print(str(first_h1))
print(first_h1.text)
print(first_h1.get_text())
print(first_h1.attrs)
print(first_h1.attrs['id'])
print(first_h1['id']) # dos the same
print(first_h1.get('id')) # same

cities= html_soup.findAll('cite', class_='citation', limit=5)
c: bs4.element.Tag
for c in cities:
    print(c.get_text())
    link = c.find('a')
    print(link.get('href'))
    print()
```

And, before move on with another example, there are two small remarks left to be made regarding `find`and `find_all`. if you find yourself traversing a chain of tag names as follows:

`tag.find('div').find('table').find('thead').find('tr')` -- So shorthand way like:

`tag.div.table.thead.tr`

Similary for the `find_all()`method like: `tag.find_all('h1')`==> `tag('h1')`

```py
import bs4
from bs4 import BeautifulSoup
import requests

url = 'https://en.wikipedia.org/w/index.php?title=List_of_Game_of_Thrones_episodes&oldid=802553687'

r = requests.get(url, proxies=dict(https='http://127.0.0.1:10811'))
html_contents = r.text
html_soup = BeautifulSoup(html_contents, 'html.parser')

# we'll use a list to store our episode list
episodes = []
ep_tables = html_soup.findAll('table', class_='wikiepisodetable')

table: bs4.element.Tag
for table in ep_tables:
    headers = []
    rows = table.find_all('tr')

    for header in table.find('tr').find_all('th'):
        headers.append(header.text)

    # then go through all the rows except the first one
    for row in table.find_all('tr')[1:]:
        values = []
        # and get the column cells
        for col in row.find_all(['th', 'td']):
            values.append(col.text)
        if values:
            episodes_dict = {headers[i]: values[i] for i in range(len(values))}
            episodes.append(episodes_dict)

for episode in episodes:
    print(episode)
```

### More on BS

Now that just understand the basics -- ready to explore the library a bit further -- FORE:

```py
import re
html_soup.find(re.compile('^h'))

def has_classa_but_not_classb(tag):
    cls = tag.get('class', [])
    return 'classa' in cls not 'classb' in cls
```

### Delving Deeper in HTTP

Websites provide a much better way to facilitate providing input and sending that input to a web server, one that you have no doubt already encoutnered -- web forms.

Take some time to inspect the corresponding HTML source using web browser -- will notice that some HTML attributes seem to play a particular role here. That is the `name`and `value`attributes for the form tags. Notice that upon submitting a form -- your browser filres a new HTTP request and includes the entered info in its request. In this simple form, a simple HTTP GET request is being used, basically converting the fields in the form to k-v URL parameters.

This way of submitting a form matches pretty will with our discussion from a few -- URL parameters are one way that input can be sent to a web server. However, in cases where we have to just submit a lot of information, URLs become unusable to submit information, due to their maximum length restriction.

## Using Other Template Variables

The most important template variable is the one that refers to the data object being processed, which is `item`in the previous -- but the `ngFor`directive supports a range of other values can also be assigned to variables and then refered to within the nested HTML elements -- like:

- `index`-- this number values is assigned to the position of the current object
- `count`-- this number value is assigned to the number of elements in the data source.
- `odd`-- `boolean`returns `true`if the current object has an odd-numbered position in the data source.
- `even`-- This returns `true`if the current has an even-numbered position.
- `first, last`

### Using the index and Count vlaues -- 

The `index`set to the positionof the curernt data object and is just incremented for each oject in the data source. like:

```html
<tr class="table-bordered"
    *ngFor="let item of getProducts(); let i=index; let c= count">
    <td>{{i+1}} of {{c}}</td>...
```

A new term is just added to the `ngFor`expression, separeted using a semicolon -- the new expression uses the `let`keyword to assign the `index`vlaue to a local tempalte variable called `i`and the `count`value to a local template variable named `c`like this:

### Using the `Odd`and Even values

The `odd`-- In general, you only need to use this .. like:

```html
<tr class="table-bordered"
    *ngFor="let item of getProducts(); let i=index; let c= count;
            let odd= odd"
    class="text-white" [class.bg-primary]="odd" [class.bg-info]="!odd">
```

### Using the `First`and last values

The `first`values is `true`only for the first object in the sequence provided by the data source and is `false`for all other objects. Conversely, the `last`value is `true`only for the last object in the sequence.

```html
<tr class="table-bordered"
    *ngFor="let item of getProducts(); let i=index; let c= count;
            let odd= odd; let first=first; let last=last"
    class="text-white" [class.bg-primary]="odd"
    [class.bg-info]="!odd" [class.bg-warning]="first || last">
```

For this, the new term in the `ngFor`expression assign the `first`and `last`values to template variables called `first`and `last`.

### Minimizing Element Operations

And, when tiere is a change to the data model, the `ngFor`directive evaluates its expression and updates the elements that represents its data objects. The update proces can be just expensive. FORE, the same data values are represented by new objects, -- which presents an efficiency problem for NG.

```tsx
swapProduct() {
    let p = this.products.shift();
    if (p != null) {
        this.products.push(new Product(p.id, p.name, p.category, p.price));
    }
}
```

And the `swapProduct()`method removes the first and just append to the last.

```js
model.swapProduct()
appRef.tick()
```

When the `ngFor`directive examines its data source, sees it has two operations to perform to reflect the change to the data -- The first is to destroy the HTML elements to represents the new object at the end of the array. For ng, of course has no way of knowing that the data actually the same value.

To improve the efficiency, can define a component method that will help Ng determine when two objects just represents the same data like:

```tsx
getKey(index: number, product: Product) {
    return product.id;
}
```

So, two objects will be considered equal if just have the same `id`.

`let odd= odd; let first=first; let last=last; trackBy:getKey"`

Just be done by adding `trackBy`term to the expression. With this change, the `ngFor`directive will know that `Product`that is removed from the array using the `swapProduct()`is equivalent to the one that is added to the array.

### Using the `ngTemplateOutlet`Directive

This `ngTemplateOutlet`is used to repeat a block of content at a specified location, which can be useful when need to generate some content in different places and want to avoid duplication.

```html
<ng-template #titleTemplate>
  <h4 class="p-2 bg-success text-white">Repeated Content</h4>
</ng-template>

<ng-template [ngTemplateOutlet]="titleTemplate"></ng-template>

<div class="bg-info p-2 m-2 text-white">
  There are {{getProductsCount()}} products.
</div>

<ng-template [ngTemplateOutlet]="titleTemplate"></ng-template>
```

So, the first step is just to define the template that contains the content that you want to repeat using the directives. And this is done using the `ng-template`element and assigining it a name using a `referene`variable.

`<ng-template #titleTemplate let-title="title">` When Ng encounters the reference variable, just sets its valeu to the elemnt to which it has been defined -- which is also `ng-tempalte`like:

`<ng-template [ngTemplateOutlet]="titleTemplate">`

The expression is name of the reference variable that was just assigned to the content that should be inserted.

### Providing Context Data

The `ngTemplateOutlet`directive can be used to provide the repeated content with a context object that can be used in data bindings defined within the `ng-template`elements.

```html
<ng-template #titleTemplate let-text="title">
  <h4 class="p-2 bg-success text-white">{{text}}</h4>
</ng-template>

<ng-template [ngTemplateOutlet]="titleTemplate"
  [ngTemplateOutletContext]="{title:'Header'}"></ng-template>

<div class="bg-info p-2 m-2 text-white">
  There are {{getProductsCount()}} products.
</div>

<ng-template [ngTemplateOutlet]="titleTemplate"
  [ngTemplateOutletContext]="{title:'Footer'}"></ng-template>
```

To receive the context data, the `ng-template`element that contains the repeated content defines a `let-`attribute that specifies the name of a variable, similar to the expanded syntax used for the `ngFor`directive. like:

`let-text=title`

The let-`attribute` in this creates a variable named `text`-- which is assigned a value by evaluating the expression `title`. to provide the data against which the expression is evaluated, the `ng-template`element to which in the `ngTemplateOutletContext`directive has been applied provides a map `object`like:

`[ngTempalteOutletContext]="{title: 'Footer'}"`

The target of this new binding is `ngTemplateOutletContext`, which looks like another directive but is actually an exmaple of an *input property*, which some directives use to receive data values and that I desribe in detail -- The expression for the binding is map object whose property name corresponds to `let-`attribute on the other `ng-templates`element.

Using Directives without an HTML element, which can be useful when you want to generate content without adding to the structure of the HTML document displayed by the browser. Which replaces the contents of the template.html file.

