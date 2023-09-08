# The GroupBy Object

The pandas library's `GroupBy`object is a storage container for grouping `DataFrame`rows into buckets -- it provides a set of methods to aggregate and analyze each independent group in the collection. Allows us to extract rows at specific index positions within each group, also offers a convenient way to iterate ofer the groups of rows.

### Creating a Groupby object from scratch

```py
food_data = {
    "Item": ["Banana", "Cucumber", "Orange", "Tomato", "Watermelon"],
    "Type": ["Fruit", "Vegetable", "Fruit", "Vegetable", "Fruit"],
    "Price": [0.99, 1.25, 0.25, 0.33, 3.00]
}
supermarket= pd.DataFrame(food_data)
supermarket
```

For the `Type`column identifies the group to which an Item belongs -- there are just two groups of items in the data set. Can use terms such as *groups, buckets clusters* interchangeably to describe the same idea. Multiple rows fall into the same category -- The `GroupBy`object just organizes `DataFrame`rows into buckets based on shared values in a column. Suppose that are just interestedin the average prices of fruit and average price of vegetable.

For this, if could isolate the `Fruit`and `Vegetable`into separate groups, could easiler to perform the calcuation. Begin by invoking the `groupby`method on the supermarket DF. need to pass it the column whose vlaues pandas will use to create the groups. like:

```py
groups=supermarket.groupby('Type')
groups
```

Can see, the `Type`column has two unique, values, so the `GroupBy`object  is separte and distinct from a `DataFrame`object. The `Type`columns -- so `GroupBy`object will store two groups, the `get_group`method accepts a group name and returns a `DataFrame`with the corresponding rows like: `groups.get_group('Fruit')`

The `GroupBy`object just excels at aggregate opertions, our orginal goal was to calculate the average price of the fruits and vegetables in supermarket. Can invoke `mean`on `groups`to calculate the average price like:

`groups['Price'].mean()`

### Creating a `GroupBy`object from a data set

1000 largest comanies in the US. by revenue, the list is updated annually by the business magazine Fortune. For, a sector can just have many companeis, Apple .. fore -- An industry is a subcategory within a sector.. Fore.  For the Sector column holds 21 unique sectors, fore, want to find the average revenue across the companies within esch sector -- Before using the `Groupby`, solve the problem by taking an alterntive approach, like:

```py
in_retailing = fortune['Sector']=='Retailing'
retail_companies= fortune[in_retailing]
retail_companies.head()
```

Can then pull out the `Revenues`column from the subset by using the `[]`like: `retail_companies['Revenues'].mean()`

for this, is suitable for calculating the averge revenue of one sector. Need to write a lot of additinal code, to apply the same logic to the other 20 sectors in `fortune`-- the code is not particularly scalable. Python can just automate some of the repetition,  but the `GroupBy`obj offers the best solution out of the box.

Invoke the `GroupBy`method on the fortune `DataFrame`-- the method accepts the column whose values pandas will use to group the rows. A column is a good candidate for a grouping if it stores categorical data for the rows. A column is a good candidate for a grouping if it stores categorcial data for the rows. fore:

`sectors= fortune.groupby('Sector')`

Returns a `DataFrameGroupBy`object -- is a bundle of `DataFrame`s. Behind the scenes, pandas repeated the extraction process used for the `Retailing`-- but for all 21 values in the `sector`column.

Can just count the number of groups in sectors by pasing into `len` -- `len(sectors)` -- So, the `sectors`Groupby object just has 21 `DataFrame`s -- the number is equal to the number of unique values in Sector column. just like:

`fortuine['sector'].nunique()` # also 21 -- Fore, what are the 21 sectrs, and how many companis from the fortune group belong to each one -- the `size()`on the `GroupBy`returns a `Series`with alphabetical list of groups and their own counts like: `fortune.size()`.

### Attributes and methods of `GroupBy`object

One way to visualize our object is as a dictionary that maps 21 sectors to a collection of fortune rows belonging each one. The `groups`attribute stores a dictionary with these *group-to-row* associations. keys are sector names, and values are `Index`objects storing the row index positions from the fortune `DataFrame`. FORE: `sectors.groups`. The output tells us that rows with index positions and, so on have a value ..

`loc`and `iloc`accessor for extracting DF ros and columns by index label -- its first arg is the row index label, its second arg is the column index label, just extract a sample fortune row to configir that pandas is pulling it into the correct sector group, like: `fortune.loc[26, 'sector']`

And, what if we want to find the highest-performing company-- by revenue within each sector -- The `GroupBy`obj's `first`method extracts the *first row listed for each sector in fortune* -- cuz our DF is sorted by reveue. The complmentary `last()`extracts the last company from fortune that belones to each sector.

The `GroupBy` obj assigns index position to the rows in each sector group. And the first now in sector has an index pos of 0 within its group. So, here is an `nth`method -- extracts the row at a given index position within its group -- if invoke the `nth`method with an arg of 0, get the first company within each sector.

Notice that can confirm the output is correct by filtering for rows in fortune like: 

`fortune[fortune['Sector']=='Apparel'].head()`

And the groupy's `head()`method extracts multiple rows from each group -- just like:

`sectors.head(2)`

And also a complementary `tail`method extracts the last rows from each group -- `tail(3)`pulls the last three rows for each sector. Can also use the `get_group`to extract all rows in a given group. like:

`sectors.get_group('Energy').head()`

## The `query`method

The traidtional way to select rows from a data frame -- via boolean index -- there is just another way to do it, namely the `query`method -- `df.query("product_id==23")`And if want to just have a more complex query, such as where column is greater and be a odd like:

### best sellers

Fore, going to use store’s products for one final exercise, this time, want to just finde the `IDs`and names of the products that have sold more than the average number of units like:

`df.loc[df['sales']>df['sales'].mean(), ['product_id', 'name']]`

So -- Pandas is all about analyzing data, and a major part of the analysis that we do in pandas can be prahsed as that. When work with `loc`accessor, you are by definition starting with the rows. Can also use the boolean operation on the `loc`accessor.

### Finding outliers

Data analysis -- another useful perspective to look at the unusual elements of our data like:

- Which of our users had an unusually high number of login attempts
- Which of that are most popular
- at which days and times are sales low.

### Interpolation

When data contaiing missing values, have a few possible ways to handle this, can remove rows with missing vlaues, but that might remove a large number of otherwise useful rows. A std alternative is interpolation -- in which you replace `NaN`with values that are likely to be close to the original ones.

```python
df.loc[(df['hour']==3) | (df['hour']==6), 'temp']=np.nan
```

`df.interpolate()`-- which returns a new data frame -- in theory, all of the columns will be interpolated -- there is only missing data in the temp column.

### Selective updating

Want to just create the same two-column frame then, update in the temp column such that any value that is <0 is to set to 0 just == `df.loc[df['temp']<0, 'temp']=0`.

### Importing and exporting data

At its heart, CSV just assumes that our data can be described as a 2d table, the rows are represented as rows in the file, and the columns are separated by .. commas or other declared by the `sep`parmeter. like:

- `sep` -- the field separator, which is a comma by default, but can often be a `\t`
- `header`-- whehter there are headers describing clumn names, and on which line of the file they appear, which can be controlled by the `header`parameter
- `indexcol`-- whcih column, if any
- `usecol`-- which columns from the file should be included in the data frame.

```python
df = pd.read_csv('data/nyc_taxi_2019-01.csv', 
                 usecols=['passenger_count', 'trip_distance',
                          'total_amount', 'payment_type'])
```

First need to do to solve this problem is create a new data frame from the CSV file -- the data is formatted in such a way that `pd.read_csv`will work just fine with its defaults, returning a data frame with named columns. The `usecols`parameter to `pd.read_csv`allows us to select which columns from the CSV file will be kept around. The parameter takes a list as an argument, and that list can either contain integers or strings representing the column names.

### Pandemic taxis

In this, wan to create a data frame from two different CSV files containing New Youk data -- one from 2018, and one from 2020-- The data frame should contain 3 columns from the files Also include a fifth column year, which should be set either 2019 or 2020-- just depending on the file from which the data loaded. Just like:

```python
df_2019_jul= pd.read_csv('data/nyc_taxi_2019-07.csv', 
                         usecols=['passenger_count', 
                                  'total_amount', 'payment_type'])
df_2019_jul['year']=2019
df_2020_jul = pd.read_csv('data/nyc_taxi_2019-07.csv',
                          usecols=['passenger_count', 
                                  'total_amount', 'payment_type'])
df_2020_jul['year']=2020
```

`df= pd.concat([df_2019_jul, df_2020_jul])`

### Df and dtypes

Saw that the every series has an `dtype`describing the type of data that it contains, can retrieve this data using the `dtype`attribute, and can tell `pandas`what `dtype`to use whencreating a sereies using the `dtype`argument when invoke the `Series`class.

In frame, each columnis a separate pandas series -- and thus has its own dtype -- by invoking `dtypes`-- method onthe data frame, can find out what the `dtype`is of each column -- this info, along with additional details about the data frame, is also available by invoking the `info`metho on the data frame.

And when read data from a CSV , pandas tries its best to infer the `dtype`of each column.

- If the values can all be turned into integers, then chooses `int64`
- If can all be into flosts, which includes NaN(note that), then choose `float64`
- other, object

If `pandas`is to correctly guess the dtype for a column, then it needs to examine all of the values in that column -- but if you have millions of rows in a column then that process can use huge amount of memory. For this reason, `read_csv`reads thef ile into memory in pieces -- examining each piece in turn and then creating a single data frame from all of them.

Can potentally lead to problem if it finds values that look like integers at the top of the file, and the values that look like strings at the bottom of the file -- in such case, you end up with a `dtype`of `object`.

One way to avoid mixed-type problem is to tell not to skimp on memory -- Can passing a False to the `low_memory`in `read_csv`. Can do that by passing a `dtype`parameter to `read_csv`method.

## Percentge Values and Padding

`p{padding: 10%; background-color: silver}` Not only did their side padding change according to the width of their parent elements, but so did their top and bottom padding. That is the desired behavior in CSS. Refer back to the prop definition -- percentage values are defined to be relative to the *width* of the parent element.

By contast, consider elements without a declared width -- In such cases, the overall width of the element box is dependent on the width of the parent element. This leasds to the possiblity of *fluid* pages. Where the padding on elements enlarges or reduces to match the actual sie of the parent element.

Also can mix percentage and actual values.

### Padding and Inline Elements

`strong {padding-top:25px; padding-bottom: 50px}`

It will have absolutely **No Effect** on the *line height* -- since padding is just transparent when there is no visible background, the preceding will no have visual effect. And be careful, an inline nonreplaced element with a background color and padding can have a background that extens above and below the element. Note that the line height isn’t changed, but since the background color does extend into the padding, each line’s background ends up overlapping the lines that come before it.

And for this, only true for the top and bottom sides of inline -- non-replaced element, and the left and right side are just different story -- start by considering the case of small, inline nonreplaced element within a single line. Just like:

`strong {padding-left:25px; background: silver}`

Note that the extra space between the end of the word just before the inline nonreplaced element and the edge of the inline element’s background, can add that extra space to both ends of the inline if you want.

### Padding and replaced Elements

It is also possible to apply padding to replaced elements - the most surprising case for most is that you can apply a padding to an image like:

Reglardless of whether the replaced element is *block-level* or inline -- the padding will surround its content. that Stuff about how padding on inline non-replaced elements doesn’t affect the hegiht of the line of text -- can just throw it out for the `replaced`-- cuz *they have a different set of rules*.

### Borders

The *border* of an element is just one or more lines that surround the content and padding of an element. By default, the background of the element stops at the outer border edge -- since the background doesn’t extend into the margins, and the *border is just insdie the margin* -- duwn underneath the border.

Every has 3 aspects - width, thinkness; style,appearance, and color. The default color border color is `currentcolor`-- the foreground color of element itself.

Boders with style --  `border-style`is the most important of a border.

### outlines

Css defines a special sort of element decoration called an *outline* -- In practice, are often drawn just beyond the borders -- 

- Outlines are visible but do not take up layout space.
- User agents often render outlines on element in the `:focus`state-- precisely cuz they do not take up layout space
- Outlines may be non-rectangular.

styles -- Much as with `border-style`can set a style for your outlines, in fact the values will seem familar to border. And the two major differences are that outlines cannot have a *hddien* style -- as border can. and the outlines can have the `auto`style -- allows the user agent to get extra-fancy with the appearance of the outline. The `auto`just permits the user agent to render a custom outline style -- typically a style which is either a user interface default for the platform.

`span {outline: 2px dotted gray;}`

How they are diffrent -- the first major difference betweenborders and outlines is that outlines -- like outset borderimages, don’t afect layout at all -- in any way purely presentational.

```css
body {width: 30em;}
h1 {padding: 10px; border: 10px solid green;
    outline: 10px dashed #9AB; margin: 10px;}
```

### Margins

The separation between most normal-flow elements occurs cuz of element margins -- setting a margin creates extrac blank space around an element. Blank space generally refers to an area in which other elements cannot also exist and in whchh the parent element’s background is visible.

### Margin Collapsing

An interesting and often overlooked aspect of the block-start and block-end margins on block boxes is that they *collapse* in normal-flow layout. This is the process by which two (or more) margins that interact long the block axis will collapse to the largest of the interacting margins. 

The example shows the separation distance between the contents of the two paragraph, it’s 60 pixels, cuz that is the wider of the two margins that are interacting. the 30-px block-start margin of the second para is collapsed.