# How pandas works with datetimes

`TimeStamp`ctor is available at the top level of pandas, can justview the `Timestamp`and `datetime`objects as being siblings -- often interchangeable in the pandas ecosystem, such as when being passed as method arguments. like:

```python
pd.Timestamp(1991, 4, 12)
pd.Timestamp(year=1991, month=, day=12)
```

Considers a Timestampe to be equal like:

```py
pd.Timestamp(year=1991, month=4, day=12)==dt.date(year=1991,month=4,day=12) # False note that
pd.Timestamp(year=1991, month=4, day=12)==dt.datetime(year=1991,month=4,day=12) # True
```

`Timestamp`ctor also accepts Py's native `date, time`and `datetime`objects.

Note that the `Timestamp`object implements all `datetime`attributes, such as `hour, minute second`

### Storing multiple timestamp in `DatatimeIndex`

The most common index encountered so far is the `RangeIndex`. And pandas uses an `Index`object to store a collection of string labels. like:

```py
timestamps=[
    pd.Timestamp(x) for x in ['2020-01-01', '2020-02-01', '2020-03-01']
]
pd.Series([1,2,3], index=timestamps).index
```

And pandas will also use a `DatetimeIndex`if pass a list of Python `datetime`objects -- fore:

```py
datetimes= [
    dt.datetime(2000, 1, 1),
    dt.datetime(2000, 2, 1),
]
pd.Series([1,2,3], index=datetimes).index
```

And also can create `DatetimeIndex`from scratch -- its ctor is available at the top level of pandas - the ctor's data parameter acceps any iterable collection of dates, can pass the dates as strings, datetimes, `Timestamps`.

`pd.DatetimeIndex(data=['2018/01/02', '2016/04/13'])`

Date- and time- related operations become possible in pandas only when we store our values as `Timestamps`rather than strings -- Pandas can't reduce a day of the week from a string cuz it views it as being a collection of digits and dashes. can use the `srot_index`method to sort a `DatetimeIndex`in ascending or descending order like:

```py
mixed_dates = [
    dt.date(2018, 1, 2),
    "2016/04/12",
    pd.Timestamp(2009, 9, 7)
]
dt_index = pd.DatetimeIndex(mixed_dates)
s = pd.Series([100, 200, 300], index=dt_index)
s.sort_index()
```

Pandas accounts for both date and time when sorting or comparing datetimes -- if two timestamps use the same date, pandas will compare their hours... A variety of sorting and comparison operations are available for `Timestamp`s out of the box -- the `<`fore.

### Converting column or index values to datetimes

```py
string_dates=['2015-01-01', '2016-02-02', '2017-03-03']
dt_index = pd.to_datetime(string_dates)
dt_index
```

Can pass the `Date`Series from the disney like:

`pd.to_datetime(disney["Date"]).head()`
`disney['Date']=pd.to_datetime(disney['Date'])`

### Using the `DatetimeProperties`Object

A datetime `Series`holds a special `dt`attribute that exposes a `DatetimeProperties`object like: Can access attrbitues and invoke methods on the `DatetimeProperties`object to extract info from the column's datetime values. the `dt`attribute is to datetimes what the `str`attribute is to strings.

Can extract such as `dt.day`, `dt.month`, `dt.year`-- and the previous can ask pandas to extract more-interesting pieces of info -- like `dayofweek`*attribute* like: -- and the `day_name()`method does the trick like:

`disney['Date'].dt.day_name().head()`

Can pair these `dt`attribute and methods with other pandas features for advanced analyses -- like: Begin by attching the `Series`returned the `dt.day_name`method to the disney `DataFrame`like:

`disney['Day of week']= disney['Date'].dt.day_name()`

Can also group the rows based on the values in the new `Day Of Week`column like:

```py
group= disney.groupby('Da of week')
group.mean(numeric_only=True)
```

Come back -- also has `month_name`method returns a `Series`with the date's month names Some attribute on the `dt`object return `Booleans`-- suppose that we wan to explore Disney's stock performance at the start of each quarter in its history. 

`disney['Date'].dt.is_quarter_start.head()`

So, can use the Boolean `Series`to extract the disney rows that fell at the beginning of a quarter, the next example like:

`disney[disney["Date"].dt.is_quarter_start].head()`
`disney[disney['Date'].dt.is_quarter_end].head()`

Also, `is_month_start`and `is_month_end`attributes confirm that a date fill at the beginnig or end of a month. Also the `is_year_end`-- 12-31 each year.

### Adding and substracting durations of time

Can add or subtract consistent durations of time with the `DateOffset`object -- its ctor is available at the top level of pandas. The ctor accepts parameters for `years, months, days`and more.like:

`pd.Dataoffset(years=3, months=4, days=5)`

Just imagine that recordkeeping system malfunctioned -- and the dates in the Date column are off 5 days like:

`(disney['Date']+pd.DateOffset(days=5)).head()`

When paired with `Dateoffset`the - just substrcts a duration from each date in a datetime `Series`- the minus sign means -- the next example moves each date back three days -- 

`(disney['Date']-pd.DateOffset(days=3)).head()`

Although the previous output does not show it, the `Timestamp`object *do* store a time internally, when converted the `Date`Column's values to datetimes -- pandas assumed a time of midnight for each date. like:

`(disney['Date']+ pd.DateOffset(days=10, hours=6)).head()`

So, pandas applies the same logic hwne subtracting a duration. like:

```py
(
    disney['Date']
    - pd.DateOffset(
        years=1, months=3, days=10, hours=6, minutes=3,
    )
).head()
```

### Date offsets

The `DateOffset`object is just optimal for adding or subtracting a consistent amount of time to or form each date. Real-world analyses often demand a more dynamic calculation -- fore, want round each date to the end of its current month. each date is a different number of days from the end of its month, so a consistent `DateOffset`additoin won't suffice.

Pandas ships with prebuilt offset objects for dynamic time-based calculations. These objects are defined in `offsets.py`-- a module within the library -- have to prefix these offses with complete path: `pd.offsets`LIke:

```py
(disney['Date']+pd.offsets.MonthEnd()).tail()
```

There has to be some movement in the intened directoin. Pandas *cannot round a date to the same date*. Thus if a date falls at the end of a month, the lib rounds it to the end of the following month. Pandas rounds 2020-06-30 at index pos to 2020-07-31, the next available month-end.

`(pd.Timestamp('2020-06-30')+pd.offsets.MonthEnd())` # return 7-31.. note that.

So, the next example uses the `MonthEnd`offset to round the dates to the prevoius month-end, pandas rounds the first three. like:

```py
(pd.Series([pd.Timestamp('2020-06-30'),
    pd.Timestamp('2020-06-29')])-pd.offsets.MonthEnd()+pd.offsets.MonthEnd())
```

And the complementary `MonthBegin`offset rounds to the first date of month -- the next example uses a + sign to round each date to the next month's beginning. Pandas rounds the first 3 dates like:

```py
disney['Date'].tail()
(disney['Date']-pd.offsets.MonthBegin()).tail()
```

A special group of offsets is available for business time calculations, their names begin with `B`-- the `Business Month End`offset -- fore, rounds to the month's last business day.

And the `BMonthEnd`offset returns a different set of results -- the last business day of `May 2020`is just Friday, so like:

```py
my_dates=['2020-05-28', '2020-05-29', '2020-05-30']
end_of_my= pd.Series(pd.to_datetime(my_dates))
end_of_my+ pd.offsets.BMonthEnd()
```

For 28, round to 29, and for 29 and 30, round to 6-30. And the `pd.offsets`module includes additional offsets for rounding to the starts and ends of quarters, business quarters, years, business years, and more.

### The Timedelta object

May recall python's native `timedelta`object from earlier in the chapter, A `time-delta`models duration - the distance between two times -- A duration such as one hour represents a length of time -- it does not have a specific date or time attached. Pandas models a duration with its own `Timedelta`object.

And the Pd's `Timedelta`ctor is just available at the top level of pandas, it accepts keyword parameters for units of time such as `days, hours, minutes, and seconds`.

```py
duration = pd.Timedelta(
    days=8,
    hours=7,
    minutes=6, 
    seconds=5
)
```

And the `to_timedelta`func at the top of level of pandas convert its argument to a `Timedelta`object.

`duration = pd.to_timedelta("3 hours, 5 minutes, 12 seconds")`
`pd.to_timedelta(5, unit='hour')`

Can pass an iterable object such as a list to the `to_timedelta`func to convert its value to `Timedeltas`.

`pd.to_timedelta([5, 10, 15], unit='day')` # return a `TimedeltaIndex`object

Also can pass in iterable such as a list to the `to_timedelta`func to convert its values to the `Timedeltas`. Usually, `Timedelta`objects are derived rather than created from scratch. like:

`pd.Timestamp('1999-02-05')-pd.Timestamp('1998-05-24')` # return a `timedelta`Object.

## Solution

```python
df.loc[(slice(1936, 2000), 'Summer'), 'Age'].mean()
df.loc[(slice(None), 'Summer', 'Archery'), 'Team'].value_counts()
```

Start with `xs`method -- which lets U accomplish what we did -- namely find matches for certain levels within a multi-index, fore, one question in the previous exercise asked U to find the mean height of participants in event from all years of Olympics -- using `loc`, had to tell pandas to accepts all values for year. like:

```python
df.loc[(slice(None), 'Summer', slice(None), 'Table Tennis Women\'s Team'), 
       'Height'].mean()
```

Using `xs`, just like:

```python
df.xs(('Summer', 'Table Tennis Women\'s Team'), level=[1, 3])
```

Just note that the `xs`is a method, and is thus invoked with round parentheses. and `loc`is just an accessor attribute. A more general way to retrieve from a multi-index is known as `IndexSlice`-- like:

`df.loc[idx[1980:2020, :, 'Swimming': 'Table tennis'], :]`

### Pivot tables

but the questions have been asking have all had a single answer, in many cases, want to apply a particular aggregate funtion to many different combinations of columns and rows. One of the most common and powerful ways to accomplish this is with a pivot table -- allows us to create a new table from a subset of an existing data frame.

- DF contains two columns that have categorical, repeating, non-hierarchical data.
- Our data frame has a 3rd column that is numeric
- When then create a new dataframe from those 3 columns -- 

```python
np.random.seed(0)
df= pd.DataFrame(np.random.randint(0, 100, [36,3]),
                 columns=list('ABC'))
df['year']=[2018]*12 + [2019]*12 + [2020]*12
df['month']='Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split() * 3
```

`df.pivot_table(*index*='month', *columns*='year', *values*=['A', 'B'])`

And, noticed that the months in our resulting table are sorted order -- which is unlikely to be the most useful way to present them- can fix by telling `pivot_table`not to sort the rows, passing `sort=False`in our method call like:

`df.pivot_table(*index*='month', *columns*='year', *values*=['A', 'B'], *sort*=False)`

```python
df.pivot_table(index='month', columns='year', values='A', sort=False, 
               aggfunc=np.sum, margins=True)
```

### Olympic pivots

In this, going to examine the Olympic data one more time -- going to do it suing pivot tbles, so that can examine and compare more information at a time than we could do before. Notice that didn’t set the index, that is cuz we are basically going to ignore the index in this exercise, focusing instead on our pivot tables, since the pivot tables are constructed based on actual columns, not index -- stick with the default, numeric index with that `pandas`.

Can use th `isin`method, which allows us to pass a list of possibilities -- and get a `True`value whenever the `Team`column is equal to one of those possible strings.

```python
df = df[df['Team'].isin([
    'Great Britain', 'France', 'United States',
    'Switzerland', 'China', 'India'
])]
```

And, will remove any rows in which the `Year`is before 1980, like:

`df[df.year>=1980]`

Now that can then create our pivot table as follows like:

`df.pivot_table(*index*='Year', *columns*='Team', *values*='Age', *sort*=True)`

Next, asked to find how many medals each country received at each of the games. Once again, do bit of planing:

- The rows will be the unique values from the `Year`column
- The columns will be the unique vlues from the `Team`

```python
dfgold.pivot_table(index='Year', columns='Team', values='Medal', aggfunc=np.size)
```

Finally, wanted to find the tallest players in each sport form each year -- Given that we are looking at ta large number of sport, and a relatively small number of years, thought htat it would be wise to use the years in the columns.

```python
df.pivot_table(index='Sport', columns='Year', values='Height', aggfunc=np.max)
```

```python
pd.pivot_table(df, index=['Year', 'Season'], columns='Team', values='Medal', aggfunc=np.size)
```

## Defining Flexible Flows

The `flex-flow`property lets you deifne the wrapping directions of the main- and cross-axes. And whether the flex items can wrap to more than one line if needed.

So the `flex-flow`just the shorthand prop sets the `flex-diection`and `flex-wrap`properties to define the flex container’s wrapping and main and cross axes.

### Understanding Axes

First, flex items are laidout along the main-axis -- Flex lines are added in the direction of the cross-axis - up until introduced `flex-wrap`-- all the examples had a single line of flex items, in that single line, the flex were laid out along the main-axis, in the *main-axis.*

### Arrangement of Flex Items

The flex items are all grouped toward the main-start on the main-axis -- Flex items can be flush against the main-end instead, centered, or even spaced out in various ways across the main-axis. The `justify-content`prop controls how flex items within a flex line are distribued along the main-axis -- the `align-items`prop defines the default distribution of the flex items along the cross-axis of each flex line.

These global defines can be individually overridden with flex item `align-self`prop, when there is more than one flex line and wrapping is enabled, the `align-content`prop defines how flex lines are distributed along the cross-axis.

### justifying - Content

enables us to direct the way flex items are distributed along the main-axis of the flex container with each flex line, and how to handle situations where info might be lost.

If flex items are not allowed to wrap to multiple lines and overflow their flex line, the vlaue of `justify-content`influences the way that the flex items will overflow the flex container. Setting `justify-content:start`, explicitly sets the default behavior of grouping the flex toward main-start Each subsequent item then gets placed flush with the preceding item’s main-end side.

Setting the `justify-content: space-between`just puts the first flex item flush with main-strat and the last flex item on the line flush with man-end.

### Example

Look advantage of the default of `justify-content`, creatinga left aligned navigation bar. By changing the default value to `justify-content: flex-end`, we can right-align the navigation bar in English like:

```css
nav {
    display: flex;
    justify-content: flex-start;
}
```

### Aligning Items

whereas `justify-content`defines how flex items are aligned along the flex container’s main-axis, the `align-items`prop defines how flex items are aligned along its flex line’s cross-axis -- as with `justify-content`, `align-items`is applied to flex containers, not for individual flex items.

Just note that the normal behaves as `stretch`for flexbox.

With `baseline`, the flex item’s first baselines are aligned with one another when they can do so, which is to say, when the `flex-direction` is row or `row-reverse`-- cuz the font size of each flex item differs, the baseline of each line in every flex item differs, the flex item that has the greatest distance between its first baseline and its cross-start side will flush against the corss-start edge of the line.

### Flex item margins and alignment

Now you have a general idea how each value behaves, but there is a bit more to it than that -- in the mutiline `align-items`figures that follow, the following styles have been applied :

```css
flex-container {
    display: flex;
    flex-flow: row wrap;
    gap: 1em;
}
flex-item{border: 1px solid;}
.C, .H {margin-top: 1.5em;}
.D, .I {margin-bottom: 1em;}
.J {font-size: 3em;}
```

### Safe and unsafe alignment

In all the previous examples, let the flex container be whatever size they needed to be to contain the flex lines, left them at `block-size: auto`.

If `safe`specified, then anytime a flex item would overflow the container, the flex item is treated as through its `align-self`set to start. On the other hand, if `unsafe`set, the alignment of flex item is honored no matter what that. Neither is the answer, when neigher safe nor unsafe alignment has been declared, browser should default to `unsafe`unless htis would cause flex items to overflow the scrollbar area.

### The `align-self`property

If you want to chagne the alignment of one or more flex items, but not all, can include the `align-self`property on the flex items would like to align differently. This property takes the same values as `align-items`and is used to override the `align-items`prop value n a per-flex-item basis.

Can override the `cross-axis`alignment of individual flex item with the `align-self`prop. As long as it’s represented by an element or pseudo-element. Cannot override the alignment for anonymous flex items -- their `align-self`always matches the value of `align-items`of their parent flex container.

Had the cross-size of the container been set to specific size, there may have been extra space at the cross-end. Or not enough space to fit the content -- CSS allows us to control the overall palcement of flex lines with the `align-content`prop. With the values `normal stretch center start flex-start end and flex-end`, thiss act in the same ways as they do for `align-items`.

### Using the `place-content`property

CSS offers a shorthand prop that collapses `align-content`-- which just covered, and `justify-content`, just: the `place-content`property like: U can supply either one or two like:

```css
.gallery {place-content: center;} ==> 
.gallery {align-content: center; justify-content: center;}
```

And the exception to this behavior occurs if the value is baselined-related. like:

```css
.gallery {place-content: last baseline;}
.gallery {align-content: last baseline; justify-content: start;}
```

### Opening Gaps between Flex Items

Flex items are by default, rendered with no space held open between them -- space an appar between items for the values of the `justify-content`or by adding margins to flex items -- but these approaches are not always iedal -- fore, margins can lead to the flex line wraping when isn’t actually needed, so `gap row-gap column-gap`come to play.

Each of these props inserts sapace of the declared size between adjacent flex items. This space is often referred to as a *gutter* -- like:

```css
.gallery {display: flex; flex-wrap: wrap; row-gap: 15px;}
```

No margins are set on the flex items -- exactly 15 pixels of space is between each flex line. Note that there are gaps only beteen rows, there are no gaps placed between the flex items and the block start and end edges of the flex container. If you want to open gaps of the same size along. Here.