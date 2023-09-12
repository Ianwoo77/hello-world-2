# Left Joins

Compared with a concatenation, a join uses  a logical criterion to determine which rows or columns to merge between two data sets -- A join can target only rows with shared values between both data sets, fore, the following sectins cover three types of 3 types of joins -- left, inner, and outer.

### MIssing values in concatnated DF

When concatnating two DFs, pandas places `NaN`at intersections of row lables and column labels that the data sets do not share -- like: Can pass `concat`function's `ignore_index`parameter an arg of `True`to generate panda's std numeric index, the concatenated `DF`will discard the original index lables :

`pd.concat(objs=[groups1, groups2], ignore_index=True)`

And what if we wanted the best of both worlds -- to create a nonduplicate index but also preserve which DF each row of data came from -- like: Add `keys`parameter and pass it a list of strings like:

`pd.concat(objs=[groups1, groups2], keys=["G1", "G2"])`

Can extract the original `DF`by accessing the G1 or G2 keys on the first level of the `MultiIndex`, like:

`groups= pd.concat(objs=[groups1, groups2], ignore_index=True)`

By default, pands concatenates rows on horizontal axis -- sometimes, we want to append the rows on the vertical axis instead -- consider the dataframe, which has the same two index labels as like:

```py
# the result is not what want -- like to align the duplicate index lables so
# need pass the axis=1 to do that
pd.concat(objs=[sprotA, SportC])
pd.concat([sportA, sprotC], axis=1)
```

In summary, the `concat`combines two Df by appending one to the end of the other on either the horizontal axis or the vertical axis like-- 

### Left joins

*join* uses a logic criterion to determine which rows or columns to merge between two data sets -- A join can target only rows with shared valued between both data sets -- fore, the following sections cover 3 types of joins *left join* uses keys from one data set to pull in values from another -- it is equivalent to a VLOOKUP operation.

For the `groups`, the FK in the `category_id`column referecne the IDs in the categories data set like: Will use the `merge`method to merge one Df into another -- the method's firest parameter, `right`-- accept another DF, the right is the circle on the right -- the `second`data set. And pass a string denoting the type of join to the method `how`parameter. Also must tell pandas which columns to sue to match values between 2 DFs. `on`parameter with a value of `category_id`.

`groups.merge(categories, how='left', on='category_id').head()`

There is it -- Pandas just pulls in categories table's columns whenever it finds a match for the category_id value in groups. The one exception is the `category_id`column -- note that when the lib does not find a category_id in categories, it displays a NaN.

### inner joins

An *inner join* targets values that exist across two `DataFrames`-- In an inner join, Pandas exclueds values that exist only in the first, and only in the first. so like:

`groups.merge(categories, how='inner', on='category_id').head()`

The merged includes all columns from both the groups and categories -- The values in the `category_id`column appear, and the merged creates one row for each group_id match across the two DFs.

### Outer jions

An outer jion combines all records across two data sets, Exclusivity does not matter with an outerjoin. just like: Note so far used only shared column names to merge the data sets -- When *column names differ* -- must pass different parameters to the `merge`method -- instead of the `on`, can use the `merge`method's `left_on`and `right_on`parameters, pass the `left_on`the column names in the left `DF`andt `right_on`on the column name in the right `DataFrame`.

`groups.merge(cities, how='outer', left_on='city_id', right_on='id')`

Note that the final has all city `IDs`from both data sets -- and if pandas finds a value match between the `city_id`and `id`-- merges the column from two in a sngle row. If one have value that the other does not, pandals places a `NaN`value in the `city_id`column. And can pass `True`to the `merge`method's `indicator`parameter to identify which `DataFrame`a value belongs to. like:

`groups.merge(cities, how='outer', left_on='city_id', right_on='id', indicator=True)`

Then can use the `_merge`column to filter rows that belong to either of the `DataFrame`-- fore, can use:

```py
in_right_only=outer_join['_merge']=='right_only'
outer_join[in_right_only].head()
```

### Merging on index lables

Imagine that a DF we'd like to join stores its PKs in tis index -- simulate this scenarios -- can invoke the `set_index`method on citiies to set its id column as its DF index like:

`groups.merge(cities, how='left', left_on='city_id', right_index=True)`

To look for matches in the index of the right `DataFrame`, can provide a different parameter, `right_index`, and set it to `True`-- the arg tells pandas to look for city_id matches the right `DataFame`'s index like: The method also supports a complementary -- `left_index`parameter, pass that parameter an argument of `True`also tells Pandas to look for the matches in the left Df's index.

### Code Challenge

The `week1.csv week2.csv`files hold lists of weekly transactions. For this, the Customer ID columns hold FKs that refernece values in the ID column in customer.csv -- each record includes a customer's first name.. just:

```py
customers = pd.read_csv('../pandas-in-action/chapter_10_merging_joining_and_concatenating/restaurant/customers.csv', 
                        index_col='ID')
foods = pd.read_csv('../pandas-in-action/chapter_10_merging_joining_and_concatenating/restaurant/foods.csv',
            index_col='Food ID')
```

`pd.concat(objs=[week1, week2], keys=['Week 1', 'Week 2'])`

Then, need to identify customers who visited the restaurant both weeks -- Just need to find the Customer IDs presents in both the week 1 and week2 DFs. A inner join is what looking for here -- invoking the `merge`on week1 and pass in week2 as the rgith DF. like:

`week1.merge(right=week2, how='inner', on= 'Customer ID').head()`

Remember that the inner join shows all matches of customer IDs across the week1 and week2  Dfs, thus there are duplicates in the result -- if wanted to remove duplicates, could invoke the `drop_duplicates`method like:

```py
week1.merge(right=week2, how='inner', on= 'Customer ID', 
            ).drop_duplicates(subset=['Customer ID']).head()
```

Asks to find the customers who visited the restaurant both weeks and ordered the same item.

`week1.merge(right=week2, how= 'inner', on= ['Customer ID', 'Food ID'])`

Have to pass the `on`paremeter a list with two columns. the value in the both Customer ID and Food ID columns must match between week1 and week1.

And to identify the customers who came in only one week is to use an outer join. like:

```py
week1.merge(right=week2,
            how='outer',
            on='Customer ID',
            indicator=True).head()
```

The final challange asks to pull customer info into the week1 table, And a left join is optimal solution -- Invoke the `merge`method on the week1 , passing in the customers `DataFrame`as the right set. like:

```py
week1.merge(
    right=customers,
    how='left',
    left_on='Customer ID',
    right_index=True
).head()
```

## Indexes

Every data frame has an index and a list of columns, indexes in Pandas are extremely flexible and powerful, an index can even be hierarchical, allowing us to query our data in sophisiticated ways -- understanding how we can create, replace, and use indexes is a crucial part of working with Pandas. in this, we will practice working with indexes in a variety of ways, also see how cna change a data frame’s index, and how we can use it to summarize our data.

### Useful references

`pd.set_index pd.reset_index df.loc s.value_counts s.isin`

- Set the index to column
- what were the 3 most commonly ticket car makes to be issued tickets on January 2nd 2020
- Set the index to be color
- What was the most common make were either red or color

```python
usecols = ['Date First Observed', 'Registration State', 'Plate ID',
           'Issue Date', 'Vehicle Make', 'Street Name', 'Vehicle Color']
df = pd.read_csv('data/nyc-parking-violations-2020.csv',
                 usecols=usecols)
```

Once the data frame was loaded, were going to perform several queries based on the parking ticket’s issue date.

`df.set_index('Issue Date', *inplace*=True)`

Note that the `set_index`returns a new data frame, based on the original one, which assign back to df. As of this point, if make queries that involve the index -- it will be based on the value of issue date.

As of this writing, the `set_index`method supports the `inplace`parameter, and will modify the dataframe, the core pandas developers have warned that this is a bad idea -- cuz it makes incorrect assumptions about memory and performance. There is no benefit to using `inplace=True`-- as a result, the `inplace`likely can retrieve all of those rows with: `df.loc['01/02/2020 12:00:00 AM']`

`df.loc['01/02/2020 12:00:00 AM', 'Vehicle Make']`

Once again, see that the two argument form of the `loc`means the first describing the rows that we want, then the `column(s)`that we ant, in this case, only interrested in a single column.

Still not quite done: how can we find the 3 most commony ticketed vehicle makes -- `value_counts()`method

`df.loc['01/02/2020 12:00:00 AM', 'Vehicle Make'].value_counts()`

Returning a series in which the index contains the different vehicle makes, and the values 

`value_counts(ascending=True)`  # default is False

fore, want to make queries against the other column, thus want to remove `Issue Date`from being the index, like:

```py
df=df.reset_index()
df=df.set_index('Vehicle Color')
```

Can also like:

`df = df.reset_index().set_index(‘Vehicle Color’)`

The info in our data frame hasn’t changed, but the index has, thus giving us easier access to data from this perpective.

`df.loc[['BLUE', 'RED'], 'Vehicle Make'].value_counts().head(1)`

```pyhton
df.loc['01/02/2020 12:00:00 AM':'01/10/2020 12:00:00 AM', 'Vehicle Make'].value_counts().head(3)
```

But that won’t give me any special access to the month data, which would like to have part of my index, can create a multi-index by passing a list of columns to `set_index`-- like:

`df= df.set_index(['year', 'month'])`

Remember, when are creating a multi-index, want the most general part to be on the outside, and thuse be mentioned first, if were to create a multi-index . With this inplace, can now retrieve in a variety of different ways, fore, can get all the sales data, for all products in 2018 like `df.loc[2018]` can get all sales data for just products A and C in 2018 like:

`df.loc[2018, ['A', 'C']]`

Notice that I’m still applying the same rule as always used with `loc`-- the first argument describes the rows, want, the second for columns. Got a multi-index on this data frame, which means that can break the dat down not just by year, but month.

## Floats

Several consequences fall out of the rules -- Clearing -- Want to set the first element of each section to just prohibit floating elements from appearing next to it -- if the first element might otherwise be placed next to floated element, it will be pushed down until it appears below the floated image. And all subsequent content will appear after that.

`h3 {clear: left}`

To avoid this sort of thing, and make sure that `<h3>`elements do not coexist on a line with any floated elements, use the value of `both`-- `h3 {clear: both}`

As with float, can give the `clear`with valus `inline-start`or `inline-end`-- if are floating with those values, clearing with them make sense. Finally, `clear: none`allows elements to float to either side of an elements.

### Flexible Box layout

With flexobx, don’t need a CSS framework -- learn how to use just a few lines of CSS to create almost any features -- *flexbox* is a simple and powerful way to lay out page components by dicating how space is distributed, content is aligned, and elements are visually ordered, Content can easily be arranged vertically or horizontally.

With flexbox, the appearance of content can be independent of source order. With works very well with responsive sites, as content can increase and decrease in size when the space provided is increased or decreased.

Flexbox works off of a parent-and-child relationship -- Flexbox layout is activated by declaring `display:flex`or display: inline-flex on an element. This element becomes a *flex container* -- arranging its children with the space provdied and controlling their layout -- the child of this flex container become *flex items*.

```css
div#one {display: flex;}
div#two {display: inline-flex;}
div {border 1px dashed; backgroudn: silver;}
```

Within a flex container, items line up on the main-axis -- the main-axis can be either horizontal or veritcal. If can arrange items into columns or rows, the main-axis takes on the directionality set via the writing mode, this main-axis cncept -- flex container will flex only its immediate children, and not further descendants.

As with demonstrates - when the flex items don’t fill up the entire main-axis of the container, they will leave extra space, contain properties dictate how to handle that extra space, which will explore later -- you can group the children to the left, right, or centered, or can spread them out.

Furthermore, the children can be aligned with respect to their container or to each other -- to the bottom, top, or center of the container, or stretched out to fill the container. Like:

```css
nav { display: flex;}
```

property to `flex`-- the `nav`element it turned into a flex container, and its child links are all flex items then -- these links are still hyperlinks - but are now also flex items. -- which also means they are no longer inline-level boxes -- rather, they participate in their contianer’s flex formatting context. therefore, the whitespace between teh `<a>`elements in the HTML is completely ignored in layout terms.

By design, flexbox is just direction-agnostic -- this is different from block or inline layouts -- which are defined to be vertically and horiztonally biased -- 

### Flex containers

The first important concept to fully understand is the `flex`container -- also known as the *container box* -- on which `display: felx`or `display: inline-flex`is applied become the flex continer and genertes a *flex formatting context* for its child nodes.

These children are *flex items* -- whether they are DOM nodes, text nodes, ore generated-content psuedo-elements, absolutely positioned children of flex containers are also flex items, but each is sized and positioned as though it is the only item in its container.

### Using the flex-direction Property

If want your layout to go from top to botto, left to right, or even bottom to top -- can use the `flex-direction`to control the main-axis along with the flex items get laid out - like:

`row row-reverse column column-reverse`

default value - `row`-- specified left-to-right -- cuz the direction of the main-axis for `row`the direction that the flex items are laid out -- is the direction of the current writing mode. 

The `column`value set sthe flex container’s main-axis to be the same orientation as the block axis of the current writing mode. This is just vertical axis in horizontal writing modes like Eng, like:

```css
nav {
    display: flex;
    flex-direction: column;
    border-right: 1px solid #ccc;
}
```

Thus, by simply writing a few CSS properties, can create a nice sidebar-style navigation for the list of links we like: Like:

```css
* {
    outline: 1px #ccc solid;
    margin: 10px;
    padding: 10px;
}
body, nav, main, article {
    display: flex;
}
body, article{
    flex-direction: column;
}
```

Elements can be flex items while also being flex containers, as you can see with the navigation, main, and article elementsin this case. And the `<body>`and `<article>`elements have `column`set as their flex directions.

### Working with other writing Directions

Using the `flex-direction: row`arranges the flex items in the same direction as the text direction, also known as the *writing mode* -- whether the language is `RTL`or `LTR`.

If all the flex items don’t fit into the main-axis of the flex container, the flex items will not wrap by default, nor will they necessarily resize, rather, the flex items may shrink if allowed to do so via the flex item’s `flex`property. Can affect-- the `flex-wrap`prop sets whether a flex container is limited to a single lineo r is allowed to become multiline when needed. `nowrap | wrap | wrap-reverse`, and default is `nowrap`.

So when `flex-wrap`prop set, the cross-axis is the same as the block axis for `flex-direction: row`and `row-revese`, and is the same as the inline axis of the language for `flex-direction: column`and `column-reverse`.

### Defining the Flexible flows

The `flex-flow`lets define the wrapping directions of the main- and cross-axes. 

values -- `flex-direction || flex-wrap` initial is `row nowrap`

like `flex-flow: row nowrap`

First, flex items are laid out along the main-axis -- flex lines are added in the direction of the cross-axis.

- Main-axis -- the axis along which content flows -- this is the direction in which flex items are flowed.
- Main-size -- total length of the content along the main
