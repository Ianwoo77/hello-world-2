# Attrutibues and methods of a `GroupBy`Object

One way to visuallize our `GroupBy`object is as a dictionary that maps the 21 sectors to a colleciotn of fortune rows belonging to each one, the `groups`attriute stores a dictionary with these group-to-row associations.

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

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

`sectors= fortune.groupby('Sector')`

The `groups`attriute stores a dictionary with these group-to-row assications -- its keys are sector nams, and its values are `Index`objects stroring the row index positions form the fortune `DataFrame`. Can just extract like:

`fortune.loc[25, 'Sector']`

Cuz our DataFrame is sorted by revenue, the first company pulled out for each sector will be just the highest-performing company within that sector.  `sectors.first()`, And can use the `get_group()`to extract all rows in a given group. The method returns a `DataFrame`containing the rows, the next slows all companies like:

`sectors.get_group('Energy').head()`

### Aggregate operations

Can invoke methods on the `GroupBy`object to apply aggregate operations to every nested group. The `sum`fore, adds the column valus in each group, by default, pandas targets all numeric column is the original `DataFrame`. like:

`sectors.sum(numeric_only=True).head(10)`

Under the hood, the `DataFrameGroupBy`object stores a collection of `SeriesGroupBy`objects -- like:

`sectors['Revenues'].sum().head()`
`sectors['Employees'].mean().head()`
`sectors['Profits'].max().head()`

And the `agg`method applies multiple aggregate operations to different columns and accepts dict as its argument, in eahc k-v pair, the key denotes a `DataFrame`column, and the value specifies the aggregate opeation to apply to the column, and the next example like:

```py
aggregations = dict(
    Revenues='min',
    Profits='max',
    Employees='mean',
)
sectors.agg(aggregations).head()
```

For this, pandas returns a `DtatFrame`with the aggretation dictionary's keys as column headers.

### Applying a custom operation to all groups

Suppose that want to apply a custom operation to each nested group in a `GroupBy`object used the `GroupBy`object's `max`method to find each sector's maximum revenue. DF's `nlargest`method extract the rows with the greatest vlaue in a given column, like:

`fortune.nlargest(n=5, columns='Profits')`

If, invoke the `nlargest`on each nested Df in sectors, get the results -- get the company with the highest revenue in each sector like. Can use the `GroupBy`'s `apply`-- expects a fucntion as an arg, invokes the function once for each group in the `GroupBy`object, then it collects the return values from the fucntion invocations and returns then in a new `DataFrame`.

```py
sectors.apply(lambda df: df.nlargest(1, 'Revenues')).head()
```

### Grouping by multiple columns

Can create a `GroupBy`object wtih the values from multiple `DataFrame`columns -- this opreation is optimal when a combination of column values serves as the best identifier for a group. fore:

`sector_and_industry= fortune.groupby(by=['Sector', 'Industry'])`

The `GroupBy`object with values from multiple `DataFrame`columns, This operation is optmial when a combination of column values as the best identifier for a group -- the next example passes a list of two strings to the `groupby`method. Pandas groups the rows first by `Sector`column's vlaues and then by the `Industry`column's vlaues. For this, just get the unique combaination of sector and industry.

And the `get_group`method requires a tuple of values to extract a nested `DataFrame`from the `GroupBy`collection.

`sector_and_industry.get_group(('Business Services', 'Education'))`

For all aggregations, pandas returns a `MultiIndex DataFrame`with the calculations -- The next example calculates the sume of the three numeric columns in `fortune` like:

`sector_and_industry.sum().head()`

Can also target individual fortune columns for aggregation by using the same syntax as -- Enter the column in a `[]`after the `GroupBy`object, then invoke the aggregation method like:

`sector_and_industry['Revenues'].mean().head(5)`

## Merging, joining and concatenating

Following relational dbs conventions, would assign a unique numeric identifier to each record, store the values in an id column, the id column's values are cllaed *primary keys* -- To just establish a relationship between two tables, dbs administrators create a column of FK -- a FK is a reference to a record in another table for this -- and the advantge of FK is the reduction of data duplication -- the `orders`table does not need to copy..

The chapter's data sets like:

```py
groups1= pd.read_csv(
    '../pandas-in-action/chapter_10_merging_joining_and_concatenating/meetup/groups1.csv')
groups2= pd.read_csv(
    '../pandas-in-action/chapter_10_merging_joining_and_concatenating/meetup/groups2.csv')
```

For this, each group has a `category_id`FK - can find info on categories in the category dataset like: Each group also has a `city_id`fk, and the cities data set stores the city info like: and the cities data set has a samall issue -- 7093 fore, is an invalid zip code, the value in the CSV is in fact 07093.. To solve this, just can add the dtype parameter to the `read_csv`like:

```py
cities= pd.read_csv(
    '../pandas-in-action/chapter_10_merging_joining_and_concatenating/meetup/cities.csv',
    dtype={'zip':'string'})
```

### Concatenating data sets

The simplest way to combine two data sets is with *concatnation*, for the `group`1 and 2 both have the same four column names-- like to combine their rows into a single `DataFrame`-- pandas has a convenient `concat`function at the top of the level of the library. like:

`pd.concat([groups1, groups2])`

Pandas just preserves the original index labels from both `DataFrames`in the concatenation, which is why we see a final index position of 8330. As the result, the concatenated index has duplicate index labels.

Can pass the `concat`function's `ignore_index`parameter an argument of `True`to generate panda's std numeric index. Like: `pd.concat([groups1, groups2], ignore_index=True).tail()`

What if -- to create a non-duplicate index but also preserve which `DataFrame`each roe of data came from -- one solution is to add a `keys`parameter and pass it a list of strings. Pandas will associate each string in the keys list wiht the `DataFrame`at the same index pos in the objs list.

```py
pd.concat([groups1, groups2], keys=['G1', 'G2']).tail().loc['G2', 'city_id']
```

Can just extract the original DF by access the `G1`or `G2`keys on the first level of the `MultiIndex`.

`groups= pd.concat([groups1, groups1], ignore_index=True)`

### Missing values in concatenated DataFrames

When concatenating two, pandas place NaNs at intersections of row labels and column lables that the data sets do not share. Consider that: If concatenate the DFs, will create missing vlaues in the .. columns. So, by default, Pandas concatenates rows on the horizontal axis. Sometimes, want to append the rows on the vertical axis instead.

Note that the `concat`function includes an `axis`parameter, can pass that parameter an argument of either 1 or `columns`to concatenate the df across the column axis.

```py
sports_champions_A = pd.DataFrame(
    data=[
        ["New England Patriots", "Houston Astros"],
        ["Philadelphia Eagles", "Boston Red Sox"]
    ],
    columns=["Football", "Baseball"],
    index=[2017, 2018]
)
sports_champions_C = pd.DataFrame(
    data=[
        ["Pittsburgh Penguins", "Golden State Warriors"],
        ["Washington Capitals", "Golden State Warriors"]
    ],
    columns=["Hockey", "Basketball"],
    index=[2017, 2018]
)
pd.concat(objs=[
    sports_champions_A, sports_champions_C
], axis='columns')
pd.concat(objs=[
    sports_champions_A, sports_champions_C
])
```

In summary, the `concat`function combines two `DataFrames`by appending one ot the end of the other on either the horizontal axis or the vertical axis.

### Left Joins

Compared with a concatenation, a *join* uses a logical criterion to determine which rows or columns to merge between two data sets. A join can target only rows with shared values between both data sets, fore, the following sections cover three types of joins, left, inner, and outer.

`groups.merge(categories, how='left', on = 'category_id').head()`

## Read CSV

In a data frame, each column is a separate pandas series, and thus has its own `dtype`-- by invoking the `dtypes`frame, can find out what the `dtype`is of each column. When read from a CSV file, `pandas`tries its best to infer the `dtype`of each column, remember that CSV files are really text files, so pandas has to examine the data to choose the best `dtype`, will basically choose between three types.

- If the values can call all be turned into integers, then choose `int64`
- If the valus can be turned into floats, include `NaN`.
- Otherwise, choose `object`.

### Setting Column types

```python
df= pd.read_csv('data/nyc_taxi_2020-01.csv', 
                usecols=['passenger_count', 'total_amount', 'payment_type'],
                dtype=dict(passenger_count=np.float16,
                            total_amount= np.float16,
                            payment_type=np.float16))
```

`df.loc[:, 'payment_type']= df['passenger_count'].astype(np.int8)`

Regardless, if want to change those two column’s `dtype`to be `int8`, will need to remove the `NaN`vlaues, can do that with `df.dropna()`-- that method returns a new data frame, one that is identical to `df`but without the rows containing `NaN`. fore: `df=df.dropna()`

NOTE-- for pandas to create a new df -- copying all of the data from -- can’t really know -- might end up with getting the dreaded `settingWithCopyWarning`-- Since, we plan ont just to explore the `NaN`- less data, but also to modify it, would thus be wise to run the `copy`method on our new data frame -- to ensure that there isn’t any shared or surprisingly copied data. `df=df.dropna().copy()` 

And the `df.memory_usage().sum()`

Fore, want u to create a data frame from a file that wouldn’t normally think of as a CSV. But which actually fits the format just fine -- the Unix `passwd`file, this file, which is std on Unix and Linux systems -- used to contain username and passwords. over the years, it has evolved such that it no longer contains the actual passwords.

```python
df= pd.read_csv('data/linux-etc-passwd.txt',
                sep=':', comment='#', header=None,
                # names parameter is the column name
                names='username password userid groupid name homedir shell'.split())
```

Over time, will discover that a few of parameters to `read_csv`repeat themsevles, making it easier to identify what you will need to pass, you will also probably end up working with many similar files, reducing the need to scour the pandas probobaly end up working with many similar files, reducing the need to scour the pandas documentation in search of the right value.

In this case, our separator is `:`so pass sep=`‘:’, deal with the comments -- all start with characters, and extend to the end of the line -- Not many companies put comments into their passwd file, by just passing:

`comment=''`, just indicate that the parser should simply ignore such lines.

For `header`parameter -- `read_csv`assumes that the first line of the file is a header, containing column names, also uses that first line to figure out how many fields will be on each line. If a file contains headers, but not on the file’s first line, then you can set headers to an integer value, indicating on which line `read_csv`should look for them. But for this example, it definitely doesn’t have headers. tell `read_csv`that there is no header with `header=None`.

And for the blank lines -- actually got off pretty esy -- in that `read_csv`just ignores blank lines by default. If want to treat blank lines as `NaN`values, then you can pass `skip_blank_lines=False`

The final keyword arg pass is `names`-- which -- then the data frame’s columns will be just labeled with integers. There is nothing technically wrong with this -- but it’s harder to work with data in this way -- There is nothing technically wrong with this -- harder to work with data in this way.

With all of this in place, the `passwd`file can easily be turned into a data frame.

### Bitcoin Values

When think about the CSV files, it’s oftenin the context of data that has been collected once, and which now want to examine and analyze -- but there are numerous examples of computer systems that publish updated data on a regular basis, and which make their findings known via CSV file.

```python
df = pd.read_csv('https://api.blockchain.info/charts/market-price?format=csv', 
                header=None, names=['date', 'value'])
```

`df = pd.read_html('https://finance.yahoo.com/quote/%5EGSPC/history?p=%5EGSPC&guccounter=1')`

### Big Cities

There is no doubt that CSV is an important, useful, and popular foramt. In some like:

```python
df = pd.read_json('data/cities.json')
df['population'].describe()[['name', '50%']]
```

## Negative Margins

It’s possible to set negatvie margins for an element. This can cause the element’s box to stick out of its 

```css
div {border: 1px solid gray; margin: 1em;}
p {
    margin: 1em;
    border: 1px dashed silver;
}
p.one {margin: 0 -1em;}
p.two {mragin: -1em 0;}
```

Combining negative and positive margins is actually very useful, fore, can make a paragraph punch out of a parent element by being creative with positive and negative margins -- can create mondrian effect with several overlapping or randomly placed boxes. like:

```css
.punch {background: white; margin: 1em -1px 1em 25%; 
	  border: 1px solid; border-right: none; text-align: center;}
```

### Margins and Inline elements

Margins can also applied to inline elements, say you want to set block-start and block-end margins on strongly: like:

```css
strong {
    margin-block-start: 25px;
    margin-block-end: 50px;
}
```

This is allowed in the specification, but on an inline nonreplaced element, they will have absolutely no effect on the line height -- and since margins are always transparent, u won’t even be able to see that they are here. They will have no effect at all.

And note that the extra space between the end of the word just work -- 

`strong {margin:25px; background: silver;}`

And the situation gets even more interesting when apply netative margins to inline non-replaced elements. like:

`strong {margin: -25px; background: silver;}`

## Backgrounds

By default, the *background area* of an element consist of the content box, padding box, and border box. So, if want the color to extend out a little bit from the content area of the element, add some padding to the mix like:

```css
p {background-color: #AEA;}
p.padded {padding: 1em;}
```

Can set a background color for any element, from `<body>`all the way down to inline elements such as `<em>`and `<a>`-- note that the `background-color`is not inherited.

Its default value is the keyword `transparent`should make sense -- if an element doesn’t have a defined color, its background should be transparent so that the background and content of its ancestor elements will be just visible.

Most of the time, have no reason to use the keyword `transparent`-- since that is the default value -- can be useful -- Image a 3rd-party -- have no include has set all images to have a white background, but your design includes a few transparent PING:

`img.myDesign {background-color: transparent;}`

### Background and color Combinations -- 

By combining `color`and `background-color`, can create interesting effects like:

```css
h1 {
    color: white; background-color: rgb(20% 20% 20%);
    font-family: Arial, sans-serif;
}
```

### Working with background Images

Having covered the basics of background colors, turn now to the subject of background images -- like: 

`body {backgournd-image: url(b23.gif)}`

Can apply images to any element, block-level or inline-level if have more than one background image:

```css
body {
    background-image: url(hazard-red.png);
    background-repeat: no-repeat;
    background-position: center;
}
```

### Floating and positioning

values -- `left right, line-start, inline-end, none`
fore: `<img src="b4.gif" style="float:left;", alt="b4">`

Floated elements -- First, a floated element is in some ways, **removed** from the normal flow of the document, although it *still* affects the layouts of the normal flow. In manner utterly unique within CSS, floated elements exist alomost on their own plane -- yet they still have influence over the rest of the document.

This influence arises cuz when an element is floated, other normal-flow content `flow-aournd` it, this is famlar behavior with floated images, but the same is true if you float a para.

```css
.aside {float: right; width: 15em; margin: 0 1em 1em; padding: 0.25em; border: 1px solid;}
```

One of the first facts to notice about floated elements is that *margins around floated elements do not collapse*. If you float an image and give it 25-pixel margins, there will be at least 25 pixels of space around that img. If other elements adjacent to the image, and that means that adjacent horizontally and vertically, also have margins. Those margins will not collapse wtiih the margins one the floated image.

`p img {float: inline-start; margin: 25px;}`

`inline-start`and `inline-end`just useful when you want to float an element toward the start or end of the inline axis, reagardless the direction that axis is pointing.

No Floating at all -- CSS has one other value for `float`besides the one we’ve discussed, `float:none`is used to prevent an element from floating at all. First of all, the default value of `float`is `none`-- in other wrods, the value has to exist in order for normal, non-floating behavior to be possible.

### The Details

*Containing block* -- a floated element’s containing block is the **closest block-level** ancestor element. therefore, in the following markup, the floated element’s containing block is the paragraph element that conains it Like:

```html
<p>
    <img src=... class=...>
</p>
```

Furthermore, a floated element generates a block box -- regardless of the kind of element it is. Thus, if you float a linke, even though the element is inline and would ordinarily generate an inline box, it generates a block box -- It will be laid out and act asif it was fore -- a `<div>`-- but it not unlike declaring the `display:block`for the floated element, although it is not necessary to do so.

A series of specific rules govern the placement of a floated element, so cover before diggint into applied behavior. These rules are vaguely similar to those that govern the evaluation of margins and widths and have the same initial appearance of common sense -- follows:

1. left or right outer edge of a floated element may not be to the left of the inner edge of tis containing block.
2. To prevent overlap with other floated, the left outer edge of a floated must be to the right of the right outer edge.. This is that all your floated content will be visible, since U don’t have to worry about one floated element obsuring another.