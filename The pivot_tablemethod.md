# The `pivot_table`method

Aggregates a column's values and groups the results by using other column's values. The same salesmen closed multiple deals on the same date.

1. Select the column(s) whose values want to aggregate
2. Choose the aggration operation to apply to the column(s)
3. select the column(s) will group the aggregated data into categories
4. Determine whether to place the groups on the row axis.

`sales.pivot_table(index='Date', values=['Expenses', 'Revenue'])`

Declare the aggregation function with `aggfunc`. like:

`sales.pivot_table(index='Date', values=['Expenses', 'Revenue'], aggfunc='sum')`

Just noticed that the presence of `NaN`s in the data set. A `NaN`denotes that the salesman did not have a row sales with a `Revenue`value for a given date. Can use the `fill_value`parameter like:

```py
sales.pivot_table(index='Date', values=['Expenses', 'Revenue'], aggfunc='sum', 
                  columns='Name', fill_value=0)
```

May also want to see the revenue subtotals for each combination of date and salesmen.

```py
sales.pivot_table(index='Date', values=['Expenses', 'Revenue'], aggfunc='sum', 
                  columns='Name', fill_value=0, margins=True, margins_name='Total')
```

### Additional options for pivot

A pivot supports a variety of aggregation operations. -- `max min std median size` -- So can also pass a list of aggregation function to the `pivot_table`function's `aggfunc`parameter -- the pivot table will take a `MultiIndex`. like:

```py
sales.pivot_table(index='Date', values=['Revenue', 'Expenses'], aggfunc=['sum','count'] ,
                  columns='Name', fill_value=0, margins=True, margins_name='Total')
```

Note can also apply different aggreations to different columns by passing a dictionaty to the `aggfunc`parameter, use the dictionary's keys to identify `DataFrame`columns and the values to set the aggregation.

```py
sales.pivot_table(
    index='Date',
    columns='Name',
    values=['Revenue', 'Expenses'],
    fill_value=0,
    aggfunc={'Revenue': 'min', 'Expenses': max},
)
```

Can also stack multiple grouping on a single axis by passing the `index`parameter a list of columns -- The next example just aggregates the usem of expenses by salesman and date like:

```py
sales.pivot_table(
    index=['Name', 'Date'],
    values=['Revenue', 'Expenses'],
    aggfunc=dict(Revenue='max', Expenses='min'),
    fill_value=0
)
```

### Stacking an unstacking index levels

Sometimes, we may want to move an index level from one axis to another. This change offers a different presentation of the data. The `stack()`moves an index level from the column axis to row axis. like:

`by_name_and_date.stack().head()`

Returns a series, and also note that the `DF`NaNs are absent from the series. Pandas kept cells with `NaNs`in the `by_name_and_date`pivot table to maintin the structural integrity.

So there is a complementary `unstack`method moves an index level from the row axis to the column axis. like:

```py
sales_by_customer= sales.pivot_table(
    index=['Customer', 'Name'],
    values='Revenue',
    aggfunc='sum'
)
print(sales_by_customer)  # this is a Series
sales_by_customer.unstack() # move the innermost level of row to column, here, `Name`
```

### Melting a data set

pivot aggregates, and on the opposite, break an aggregated collection of data into an unaggregated one. like: Often need to choose between flexibility and readability. Fore the `melt`method -- The process of converting data set to narrow one. the method accepts two primary parameters -- 

- The `id_vars`-- sets the identifer column -- the column for which the wide data set aggregate data. So for this the `Name`is just the ideal identifier column.
- `value_vars`-- parameter accepts the column whose value pandas will melt and store in a new column.

`video_game_sales.melt(id_vars='Name', value_vars='NA').head()`

Then just melt all of the regional sales columns code pass the `value_vars`a slit of the 4 regional sales column from that. fore:

```py
region_sales_columns='NA EU JP Other'.split()
video_game_sales.melt(id_vars='Name', value_vars=region_sales_columns)
```

The variable column holds the 4 regional column names from this.. The value column holds the values from those 4 sales columns -- In the previous -- the data. Can customize the melted DF's columns names by passing arguments like: `var_name`and `value_name`parameters. like:

```py
video_game_sales.melt(id_vars='Name', value_vars=region_sales_columns,
                      var_name='Region', value_name='sales')
```

Narrow data is just easiler to aggregate then wide data -- fore, want to find the sum of each sales acorss all region, just:

```py
video_games_sales_by_region.pivot_table(
    index='Name', values='sales', aggfunc='sum'
)
```

### Exploding a list of values

Sometimes, a data set stores multiple values in the same cell. May want to break up the data cluster so that each row stores a single value. Explode is to column direction -- like:

```py
recipes['Ingredients']=recipes['Ingredients'].str.split(',')
recipes.explode('Ingredients')
```

For this also, translate to columns, but using the list style.

### Code Challenging

1. Aggregate the sum of car prices.
   ```py
   cars.pivot_table(values='Price', index='Fuel', aggfunc='sum')
   ```

2. Can also use the method to count by manfacturer and transmission type like:
   ```py
   cars.pivot_table(values='Price', 
                    index='Manufacturer',
                    columns='Transmission',
                    aggfunc='count',
                    margins=True)
   ```

3. To organize average car pices by year and fuel type on the pivot table's row axis, can pass a list of strings.
   ```py
   cars.pivot_table(values='Price', 
                    index=['Year', 'Fuel'],
                    columns='Transmission',
                    aggfunc='mean')
   ```

4. The next exercise is to move transmission type from the column index to the row index. The `stack`just does the trick the method returns a `MultiIndex`Series -- has 3 levels -- Year, Fuel and Transmission.

   `report.stack()` # just move the Transmission to the column.

5. Next like to convert the `min_wage`data set from the wide format to narrow format. 8 columns store the same variable - the `wages`themsevles.
   ```py
   year_columns=[str(x) for x in range(2010,2018)]
   min_wage.melt(id_vars='State', value_vars=year_columns)
   ```

   For this, can remove the `value_vars`parameter from the `melt`method invocation and still get the same DF. By default, Pandas melts data from all columns expcet we explicitly pass a parameter.

   And, can also customize the column names with the `var_name`and value_name parameters. like:
   `min_wage.melt(id_vars='State', var_name='Year', value_name='Wage')`

## Long, medium and short Rides

`s = pd.read_csv('data/taxi-distance.csv', squeeze=True, header=None)`

```python
pd.cut(s, bins=[s.min(), 2, 10, s.max()],
       labels='sort medium long'.split())
```

For this, result is a `category` This task for this wan’t turn the ride length into categories, but to see the number of riders in each category. can then use the `value_counts()`like:

```python
pd.cut(s, bins=[s.min(), 2, 10, s.max()],
       labels='sort medium long'.split()).value_counts()
```

### Net revenue

For many people who use `pandas`-- it’s rare to create a new data frame from scratch. You will create it from a CSV file, or you perform some transformations.

```python
df = pd.DataFrame([{'product_id': 23, 'name': 'computer', 'wholesale_price': 500,
                    'retail_price': 1000, 'sales': 100},
                   {'product_id': 96, 'name': 'Python Workout', 'wholesale_price': 35,
                    'retail_price': 75, 'sales': 1000},
                   {'product_id': 97, 'name': 'Pandas Workout', 'wholesale_price': 35,
                    'retail_price': 75, 'sales': 500},
                   {'product_id': 15, 'name': 'banana', 'wholesale_price': 0.5,
                    'retail_price': 1, 'sales': 200},
                   {'product_id': 87, 'name': 'sandwich', 'wholesale_price': 3,
                    'retail_price': 5, 'sales': 300},
                   ])
```

There are a member of ways to do this including:

- List of lists/series, in which each inner list represents one row, and the column names are taken positionally.
- List of dicts, in which the dict keys indicate which columns are set to each row
- dict of list/series
- 2d Numpy Array

### Tax planning

In this, goting to extend the data frame -- If two series share an index, then can perform a variety of arithmetic operations on them. The result will be a new series, with the same index as each of the two inputs to the operation. Often as the previous exercise, perform the operation on two of the columns in our data frame and view the result.

Adding new produces -- Want to create a new data frame containing 3 new products just like:

```python
new_products = pd.DataFrame([{'product_id': 24, 'name': 'phone', 'wholesale_price': 200,
                              'retail_price': 500},
                             {'product_id': 16, 'name': 'apple', 'wholesale_price': 0.5,
                              'retail_price': 1},
                             {'product_id': 17, 'name': 'pear', 'wholesale_price': 0.6,
                              'retail_price': 1.2}], index=range(5, 8))
df= pd.concat([df, new_products])
```

This new data frame needed to have all of the same values as the prevous one did, except for the `sales`column. Except for the `sales`column. The `pd.concat()`method does this -- it works a bit differently than you might expect, it’s a top-level `pandas`function -- and takes a list of data frames you would like to concatenate. By default, `pd.concat`assumes that you want to join them top-to-bottom, but can do side-to-side if you want to by setting the index parameter.

`df=pd.concat([df, new_products])` if: `df.loc[[5,6,7], 'sales']`

One way is to use our `loc`-- based retrieval to set values like:

`df.loc[[5,6,7], 'sales']=[100, 300, 500]`

- `df.loc`accesses one or more rows from our data frame.
- In this case, using the fancy indexing, retrieving 3 rows basd on their indexes
- If were to stop here, then would get all of the columns for these 3 rows.
- Note that the `dtype`does not automatilly be set to `np.int64`.

`df['sales']= df['sales'].astype(np.int32)`
`df.sales.apply(lambda x : x+x*.1 if x>100 else x).sum()`
`pd.options.display.float_format = '{:,.2f}'.format`

### The `query`method

The traditional way to select rows from a data frame, as have seen, is via a boolean index, -- there is another way -- namely the `query`method -- might just used SQL and relational dbs. The basic idea is just simple -- provide a string that pandas turns into a full-fledged query, get back a filtered set of rows from the original data frame.

`df[df['v']>300]`==> `df.query('v>300')`

These two just return the same results. Can combine like:

`df.query('v>300 && w%2==1')` For the string: `df.query('department=="food"')['sales']`

## Replaced Elements

Are a bit simpler to manage. All the rules given for nonreplaced hold true -- one exception -- if `inline-size`is auto, the `width`of the element is the content’s instrinsic width. -- original size.

### List Items

have a few special ruls of their own. Typically preceded by a marker. `list-style-position`keyword used.

Want to size an element by its aspect ratio -- its block and inline size exist in a specific ratio. *inline formatting*

Inline-block elements -- As befits the hybrid look of the value name `inline-block`-- are indeed a hybrid of block-level and inline elements -- relates to other elements and contents as inline box just as an image. Inside the inline-block element, the content is formatted a though the element were block-level. The `width`and `length`apply to the element -- as the do any block-level or inline replaced elemnet.

For the second `<div>`just formattted as normal inline content, wihich means that `width`and `text-align`get ignored, for the 3rd -- the `inline-block`used -- since it is formatted as a block-level element. And if the `width`is not defined or explicitly declared to `auto`then the element box will shrink to fit the content.

`div#three p {display: inline-block; block-size:4em;}`

### Flow Display

The `display`values `flow`and `flow-root`deserve a momnent -- Declaring an element to laid out using `display: flow`means that it should use `block-and-inline`layout-- unless it’s combined with inline, generates an inline box.

Content display -- When `display:contents`applied to an element causes the element to be removed from page formatting, and effectively evaluates its child elements to its level-- The list items are still list items, and act like them, but visually, the `<ul>`is gone.

### Element visibility

In addition to everything discussed -- can also control the visibility of an entire element like:

`visible hidden collapse`

If have `visible`-- if hidden, it is made inviible -- but the element still affects the document’s layout through it were visible. -- Just ntoe that the difference this and `display:none`-- in the latter case, the element is not displayed and is removed from the document altogether so that it doesn’t have any effect on the document layout. fore, shows a document in which an inline lement inside a paragrap has been set to `hidden`. Everything visible about a hidden element, such as content, background, and borders is made invisibile. The spaice is still there cuz the element is stil part of the document‘s layout.

Can just set the descendant element of a `hidden`to be `visible`-- this causes the element to appar wherever it normally would. to do so, explicitly declare the descendant element visiable -- since the `visibility`is inherited.

```css
p.clear {visibility: hidden}
p.clear em {visibility: visible;}
```

For the `visibility:callapse`-- used in CSS table rendering and flexbox box layout, where it has an effect very similar to `display:none`. The difference is that in table rendering, a row or a column that’s benn set to `hidden`is hidden and the space it would have *occupied is removed.*-- but any cells in the hidden row or column are used to determine the layout of interesting columns or rows. This allows you to quickly hide or show rows and columns wihtout forcing the browser to recalculate the layout of the whole table.

### Basic element Boxes

All document elements generate a rectangular box called the *element box*, which describes the amount of space that an element occupies in the layout of the document.

By default, elements have no padding -- the separation between p, fore,has traditionaly been enforced with margins alone -- on the other hand, without padding, the border of an element will come very close.

`padding: top right bottom left`

### Logical Padding

Physicial properties have logical counterparts, with names that follow a consistent pattern, fore, `height`and `width`just have `block-size`and `inline-size`-- for padding, have a set of 4 props that correspond to the padding at the start and the end of the direction and inline direction. fore:

```css
p {
    padding-block-start: .25em;
    padding-block-end: .25em;
    padding-inline-start: 1em;
    padding-inline-end: 1em;
}
```

With this shorthand props, can set block padding in one go like:

```css
p{
    padding-block: .25em;
    padding-inline: 1em;
}
```

And, every prop accepts one or two values, if there are two, they’re always in the order *start end*.
