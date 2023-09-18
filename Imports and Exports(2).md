# Imports and Exports(2)

Data sets come in a variety of file formats,  csv, tsv, xlsx and more, and some data formats do not store data in tabular format, they nest collections of related data inside a k-v store. Pandas ships with utility functions to manipulate k-v data into tabular data and vice versa.

### Reading from and writing to JSON files

A JSON reponse consists of k-v pairs, in which a key serves a a unique identifier for a value. A key can also point to an *array*, an order collection of elements equivalent to a py list. Json can store any additional k-v pairs within nested objects, such as address in the following example.

For, goal, is to convert the data to tabular format, to do so, need to extract the JSON's top-level k-v pairs, to separate DF columns, also need to iterate over each dictioanriy in the "laureates" list -- The process of moving nested records of data into a single, one-dimensional list is called *flattening* or *normalizing* -- The pandas lib includes a built-in `json_normalize`function to take care of the heavy lifting. if directly:

`pd.json_normalize(nobel['prizes'])`

Use the `json_normalize()`'s data parameter -- tand use its `record_path`parameter to normalize the nested records.

```py
pd.json_normalize(nobel.loc[0, 'prizes'], record_path='laureates',
                  meta=['year','category']) 
```

Some of the `laurates`key lost in the original json file so need:

```py
nobel['prizes'].apply(lambda d: d.setdefault('laureates', [])) # inplace method
pd.json_normalize(nobel['prizes'],
                  record_path='laureates',
                  meta=['year','category']) 
```

The `setdefault`method just mutatess the dictionaries with prizes, so, there is no need to overwrite the original series. now that all nested dicts have a `lautreates`key, can revoke the `json_normalize`.

### Exporting a dataFrame to a JSON file

Converting a `DataFrame`to JSON representation and writing it to a JSOn file, and the `to_json`method creates a JSON string from a pandas data structure -- note htat its `orient`parameter customizes the format in which pandas returns the data. The next example uses an argument of `records`to returns a JSON array of k-v objects. like:

`winners.head(2).to_json(orient='records')`

Others is `index, columns, values, and table`

### Reading from CSV files

Can just exclude the index by passing `index`parameter an argument of `False`like:

```py
url= "https://data.cityofnewyork.us/api/views/25th-nujf/rows.csv"
baby_names= pd.read_csv(url)
baby_names.head()
```

By default, pandas includes the `DataFrame`index in the CSV string, notice the comma at the beginning of the string and numeric vlaues after each `\n`symbol. `baby_names.to_csv(index=False)`

And, by default, pandas write all Df columns to the CSV file, can choose which columns to export by passing a list of names to the `columns`parameter. The next example creates a `CSV`with the Gender, Child's First Name, and Count Like:

```py
baby_names.head(10).to_csv('NYC.csv', index=False,
                           columns=['Gender', "Child's First Name", 'Count'])
```

### Reading from and writing to Excel

Note that pandas needs the `xlrd`and `openpyxl`library to interact with Excel.

`pip install xlrd openpyxl`

And the `read_excel`function supports many of the same parameters as `read_csv`, including `read_col`to set the index columns, `usecols`select the column and squeeze to coerce a one-column `DataFrame`into a `Series`object. the next example sets the City column as the index and keeps only 3 of the data set's four columns like:

```py
pd.read_excel(io='../pandas-in-action/chapter_12_imports_and_exports/Single Worksheet.xlsx',
              usecols=['City', 'First Name', 'Last Name'],
              index_col='City')
```

And the `read_excel()`func supports many of the same parameter as `read_csv`, including `index_col`, `usecols`.. And the complexity increases slightly when a workbook contains multiple worksheets -- the multiple workbook holds 3 worksheets. like; During the import, pandas assigns each worksheet an index positoin starting 0, can just import a specific by passing the worksheet's index position or its name to the `sheet_name`parameter. The parameter's default argument is 0, therefore the following two statements return the same `DataFrame`.

```py
pd.read_excel(io='../pandas-in-action/chapter_12_imports_and_exports/Multiple Worksheets.xlsx',
              sheet_name=['Data 1', 'Data 2'])
pd.read_excel(io='../pandas-in-action/chapter_12_imports_and_exports/Multiple Worksheets.xlsx',
              sheet_name=[1, 2])
```

Note that these return a dict.

### Exporting Excel Wrokbooks

Return the `DataFrame`that downlaod, Writing to an Excel workbook requires a few more steps than writing to a CSV. The `ExcelWriter`ctor is available as a top-level attribute of the pandas library. Its first parmeter, path, accepts the new workbook's filename as a string. If do not provide a path to a diectory, pandas will create the `Excel`in the sme workbook. 

`excel_file= pd.ExcelWriter('babies.xlsx')`

A DF includes a `to_excel`method for writing to an Excel workbook, like:

```py
for t in groups.head(50):
    df:pd.DataFrame = groups.get_group(t[0])
    df.to_excel(excel_file, sheet_name=t[0], index=False,
                columns=["Child's First Name", 'Count', 'Rank'])
excel_file.close()
```

### Coding Challenge

The tv_shows.json file is an aggregate collection of TV show episodes pulled from the com API. The JSON includes data for three TV shows, The files, lost and buffery like:

```py
tv_shows_json['shows'].apply(lambda d: d.setdefault('episodes', []))
tv_shows= pd.json_normalize(tv_shows_json['shows'], record_path='episodes',
                            meta=['show', 'runtime', 'network'])
```

And write to three DataFrames to an excel workbooks. like:

```py
episodes= pd.ExcelWriter('episodes.xlsx')
for t in groups:
    df: pd.DataFrame= groups.get_group(t[0])
    df.to_excel(episodes, sheet_name=t[0], index=False)
episodes.close()
```

```python
filename= 'data/celebrity_deaths_2016.csv'
df = pd.read_csv(filename, usecols=['dateofdeath', 'age'])
df['month']=df['dateofdeath'].str[5:7]
df = df.set_index('month')
df=df.sort_index()
```

```python
df= df.dropna(subset=['age'])
df= df[df['age'].str.isdigit()]
df['age']=df['age'].astype(np.int64)
df.loc['02':'07', 'age'].mean()
```

### Titanic interpolation

When have `NaN`values, have a few poptions -- 

- remove them
- leave them
- replace them with sth else

```python
filename= 'data/titanic3.xls'
df=pd.read_excel(filename)
df.columns[df.isnull().sum()>0]
```

Notice that the column names are stored in an `Index`object, which works similarly to series objects.

`df.isna().sum()`

Deciding what we should do with each `NaN-containing`column depends on a variety of factors, including the type of data that the column contains, another factor is just how many rows have null values. In two cases, fare and 

```python
df= df[df['fare'].notnull()]
df= df[df['embarked'].notnull()]
```

When it comes to the `age`column, might want to just consider steps carefully, inclined to use the `mean`here -- but you could use the mode, could also use a more sophisticated technique -- using the `mean`from within a particular cabin, could even try to get the complete set of ages on the `Titanic`, and choose from a random distribution built from that. Using the `mean`age has some -- it won’t affect the man age, alghough it will reduce the std divaiation. like:

```python
df['age']=df['age'].fillna(df['age'].mean())
```

Finally, want to set the `home.dest`column similarly to what I did with the `age`column, but insted of using the mean, use the mode -- do this for two reasons.

`df['home.dest']=df['home.dest'].fillna(df['home.dest'].mode())`

### Beyond the exercise

Missing data is a common issues that you will need to deal with when importing data sets, but equally common is inconsistent data, when the same value.. Before can fix up the colors, first need to understand what we are dealing with. like:

`df['Vehicle Color'].value_counts().head(30)`

Can already seen that there is little or no std here, and that the people giving tickets are widely inconsistent in how they describe colors. To clean up, create a regular Py dictionary, could also use a series, but a dict seems like the eaiest and most solution like:

`df['Vehicle Color']=df['Vehicle Color'].replace(colormap)`

## The flex-basis Property

As have already seen, a flex item’s size is impacted by its content and box-model properties and can be reset via the 3 components of the `flex`property, the `flex-pasis`component of the `flex`prop defines the initial or default size of flex items. And the flex basis determing the size of a flex item’s element box, as set by `box-sizing`.

And the flex basis can be defined using the same length value types as `width`and `height`properties, fore, 5vw, 12%, 300px -- the universal keyword `initial`resets the flex bais to initial value of `auto`.

### The `content`keyword

In addition to lengths and percentges, `flex-basis`supports `min-content, max-content, fit-content`and `content`keywords. note:

When using `fit-content`as the value for `flex-basis`, the browser will do its best to balance all the fix items in a line so that theya re similar in block size. And using the `content`keyword has results generally similar to `fit-content`, though some differences exist. A `content`basic is the size of the flex item’s content, that is -- the length of the main-axis size of the logner line of the content or widest media object.

And for the `min-content`flex basis, the reverse happens.

### Flexbox principles

`flex`to elemen turns it into a *flex container*, and its **direct** children turn into *flex items* -- by default, flex items align side by side, left to right, all in one row. the flex container fills the available width like a block element, but the flex items may not necessarily fill the width of their flex container.

Can also use `display: inline-flex`, this creates a flex container that behaves more like an inline-block element rather than a block, it flows inline with other inline elements -- but won’t automatically grow to 100% width. Flex items within it generally behave the same s with display: flex. Partically speaking, won’t need t use this very often.

```html
<body>
    <div class="container">
        <header>
            <h1>Ink</h1>
        </header>
        <nav>
            <ul class="site-nav">
                <li><a href="/">Home</a></li>
                <li><a href="/">Features</a></li>
                <li><a href="/">Pricing</a></li>
                <li><a href="/">Support</a></li>
                <li class="nav-right">
                    <a href="/about">About</a>
                </li>
            </ul>
        </nav>

        <main class="flex">
            <div class="column-main tile">
                <h1>Team collaboration done right</h1>
                <p>Thousnds of tems from all over the world
                    turn to <b>Ink</b> to communicate 
                    and get things done.
                </p>
            </div>
            <div class="column-sidebar">
                <div class="tile">
                    <form class="login-form">
                        <h3>Login</h3>
                        <p>
                            <label for="username">Username</label>
                            <input id="username" type="text"
                            name="username" />
                        </p>
                        <p>
                            <label for="password">Password</label>
                            <input id="password" type="password"
                            name="password" />
                        </p>
                        <button type="submit">Login</button>
                    </form>
                </div>

                <div class="tile centered">
                    <samll>Starting at</samll>
                    <div class="cost">
                        <span class="cost-currency">$</span>
                        <span class="cost-dollars">20</span>
                        <span class="cost-cents">.00</span>
                    </div>
                    <a class="cta-button" href="/pricing">
                        Sign up
                    </a>
                </div>
            </div>
        </main>
    </div>
</body>
```

To get your stylesheet started, just like:

```css
:root {
    box-sizing: border-box;
}

*, ::before, ::after{
    box-sizing: inherit;
}

body {
    background-color: #709b90;

}

body * + * {
    margin-top: 0;
}

.container {
    max-width: 1080px;
    margin: 0 auto;
}
```

first, building a basic flexbox menu - for this, you will want the navigational menu to llok like most -- should just consider which element nees to be the flex container, keep in mind its child elements become the flex items. In the case of our page menu, the flex container should be the ul.

```css
.site-nav {
    display: flex;
    padding-left: 0;
    list-style-type: none;
    background-color: #5f4b44;
}

.site-nav > li {
    margin-top: 0;
}

.site-nav > li a {
    background-color: #cc6b5a;
    color: white;
    text-decoration: none;
    display: block;
}
```

Note that working with 3 levels of elements -- the `site-nave`, the list, and the anchor tags within them. Used direct descendant to ensure.

```css
.site-nav li+li {
    margin-left:1.5em;
}

.site-nav > .nav-right {
    margin-left: auto;
}

```

Can achieve this layout by using the margin-left property and an adjacent sibling combinator.

### Flex item sizes

The lising used margins for spacing between the flex items. To define their size, could use the `width`and `height`, but flexbox provides more options for sizing and spacing than the familar `margin width height`properties alone can accomplish.

```css
.tile {
    padding: 1.5em;
    background-color: white;
}

.flex {
    display: flex;
}

.flex > *+* {
    margin-top: 0;
    margin-left: 1.5em;
}
```

Now the content is just divided into two columns, NOTE, when it comes to CSS, it’s important to consider not only the specific content you have on the page now, but also what will happen as that content changes.

And the `flex`property, which is applied to the felx items, gives you a number of options like:

```css
.column-main{
    flex:2;
}

.column-sidebar {
    flex:1;
}
```

And the `flex`property is shorthand for 3 different sizing properties, `flex-grow, flex-shrink`, and `flex-basis`, in this listing, you’ve only supplied `flex-grow`, leaving the other two properties to their default values. Just==

`flex-grows:2; flex-shrink:1; flex-basis: 0%`

`flex-basis`-- defines a sort of starting point for the size of an element, an initiial `main size`-- can be set to any value that would apply to `width`, including px, or percentages, initial is `auto`. Note that once `flex-basis`is computed for each flex item, they will add up to some widht, this width may not necessarily fill the width of the flex container, leaving some remainders. And these remaining spaces will be consumed by the flex items based on their `flex-grow`values, which is always specified as a non-negative integer.

So, declaring a higher `flex-grow`gives the element more “weight”.

The `flex-shrink`follows similar principles as `flex-grow`-- the `flex-shrink`value for each item indicates whether it should shrink to prevent overflow.

### Changing the direction

For now, need is for the two columns to grow if necessary to fill the container’s height. To so this, just trun the right column into a flex container with the `flex-direction:column`.

```css
.column-sidebar {
    flex:1;
    display:flex;
    flex-direction: column;
}

.column-sidebar > .tile {
    flex:1;
}
```

Now, have a *nested flexboxes* -- is a flex item for the outer flexobx. finally, just styling the login form.

```css
.login-form h3 {
    margin:0;
    font-size: .9em;
    font-weight: bold;
    text-align: right;
    text-transform: uppercase;
}

.login-form input:not([type=checkbox]):not([type=radio]) {
    display: block;
    width: 100%;
    margin-top:0;
}

.login-form button {
    margin-top: 1em;
    border: 1px solid #cc6b5a;
    background-color: white;
    padding: .5em 1em;
    cursor: pointer;
}
```

Used `text-align`to shift the text. And note that the `not()`and `[type=radio]`used.

### Alignment, spacing and other details

```css
.centered {
    text-align: center;
}

.cost {
    display: flex;
    justify-content: center;
    align-items: center;
    line-height: .7;
    ;
}

.cost > span{
    margin-top: 0;
}

.cost-currency {
    font-size: 2rem;
}

.cost-dollars{
    font-size: 4rem;
}

.cost-cents {
    font-size: 1.5rem;
    align-self: flex-start;
}

.cta-button {
    display: block;
    margin: .5em auto;
    width: 50%;
    background-color: #cc6b5a;
    color: white;
    padding: .5em 1em;
    text-decoration: none;
}
```

