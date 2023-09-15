# Adding and subtracting durations of time

Can add or subtrct consistent durations of time with the `DateOffset`object -- its ctor is available at the top level of pandas. The ctor just accepts parameter for `years, months, days`-- like:

`pd.DateOffset(years=3, months=4, days=5)`

Here is a reminder of the first five rows of `disney['Date']+pd.DateOffset(days=5)`, when paired with a `DateOffset`, the minus sign - subtracts a duration from each date in the datetime `Series`, the minus sign means -- the example moves each date back 3 days like: `disney['Date']-pd.DateOffset(days=3)`

### Date offsets

The `DateOffset`object is optimal for adding or subtracting a consistent amount of time to or from each date. Real-world analyses often demand a more dynamic calculation -- want to round each date to the end of its current month like:

`disney['Date']+pd.offsets.MonthEnd()`

Note that the **pandas cannot round a date to the same date**. And the complemtary `MonthBegin`offset rounds the first date of a month like:

`disney[~disney['Date'].dt.is_month_start]['Date']-pd.offsets.MonthBegin()`

### The Timedelta object

May recall Py's native `timedelta`object from eariler in the chapter -- A time-delta mdels duration -- the distance between two times -- a duration such as one hour represents a length of time -- it does not have a specific date or time attached -- Pandas models a duration with its own `Timedelta`object. Is available at the top level of pandas, it accepts keyword parametters for units of time such as `days hours minutes`and `seconds`like:

```py
duration = pd.Timedelta(
    days=8, hours=7, minutes=6, seconds=5
)
duration
```

Can also pass an integer to the `to_timedelta`functin along with a `unit`parmeter. The `unit`parameter declare the unit of time that the number represents. Accepted arguments include `hour, day`and `minute`. like:

`pd.to_timedelta(5, unit='hour')`

can pass an iterable object such as a list to the `to_timedelta`function to convert its values to `Timedeltas`, Pandas will store the `Timedeltas`in `TimedelataIndex` -- So a pandas index for storing durations like:

`pd.to_timedelta([5,10,15], unit='days') *# return TimedeltaIndex object*`

Usually, Timedelta objects are derived rather than created from scratch, the subtraction of one `Timestamp`from another, fore, returns a `Timedelta`automatically like:

`pd.Timestamp("1999-02-05")- pd.Timestamp("1998-05-24")`

Just practice converting the values in the two column to datetimes -- can use the parse_dates -- but try to another approach, one option is invoking the `to_datetime`function like:

`deliveries['order_date']=pd.to_datetime(deliveries['order_date'])`

But, a more scalable solutin is to iterate over the column names with the `for`loop for this problem, can reference a deliveries column dynamically,  use `to_datetime`to creae a `DateTimeIndex`of `Timestamps`from it.

```py
for column in ['order_date', 'delivery_date']:
    deliveries[column]= pd.to_datetime(deliveries[column])
```

Then for this, calculate the duration of each shipment, with pandas, this calcuation is as simple as subtracting the `order_date`column from the `delivery_date`column like:

`(deliveries['delivery_date']-deliveries['order_date']).head()`

For this, pandas returns a `Series`of `timedeltas`-- attch new series to the end of the this:

`deliveries['duration']=(deliveries['delivery_date']-deliveries['order_date'])`

Can add or subtract `Timedelta`s from `Timestamp`objects, the next example subtracts each row's duration from the `delivery_date`column like:

`(deliveries['delivery_date']-deliveries.duration).head()`

And a plus symbol adds, say wanted to find the date of delivery if each package took twice as long to arrive like:

`(deliveries['delivery_date']+deliveries.duration).head()`

And the `sort_values`method works with `Timedelta`Series -- the next example sorts the duration column in ascending order -- like: `deliveries.sort_values('duration')`

Mathmatical methods are also available on `Timedelta`series -- The next few examples highlight 3 methods we are used throughout the book `max`for the largest value, `min`for smallest like:

`deliveries['duration'].max(), min(), mean()`

Fiter the `DataFrame`for packages that took more than a year to deliver -- use the `>`to do "365" days like:

`deliveries['duration']>"365 days"`or:

`deliveris['duration']> pd.Timedelta(days=365)`

### Coding challange

Here is your chance to practice the concepts -- For this DF, jsut entries in the `start_time`and `stop_time`columns insdide the year, month, day ... and microsecond, can use the `info`first, to print a summary like:

1) just convert the data type like:
   ```py
   for column in ['start_time', 'stop_time']:
       citi_bike[column]=pd.to_datetime(citi_bike[column])
   ```

2) Have to take two steps to count the nubmer of bike rides per weekday. like:
   `citi_bike['start_time'].dt.day_name().head()`, then can invoke the tursty `value_counts`on that like: `citi_bike['start_time'].dt.day_name().value_counts()`

3) Next challenge requires us to group each date into its corresponding week bucket -- can do so by rounding the date to its previous or current `Monday` -- there is a clever solution -- can use the `dayofweek`attribute to return a `Series`of numbers -- 0 denotes `Monday`, 1 denotes... like: Note that the weekday number also represents the disnance in days from the cloest Monday.. So, can save this to a new variable: `days_away_from_monday = citi_bike['start_time'].dt.dayofweek`. If then subtract a date's `dayofweek`vlaue from the date itself, effectively round each date to its previous Monday. Can pass the `dayofweek`into the `to_timedelta`function to convert it to a `Series`of durations. `citi_bike['start_time']-pd.to_timedelta(days_away_from_monday, unit='day')`, then save the new `Series`to a `dates_rounded_to_monday`varaible like:
   ```py
   dates_rounded_to_monday = citi_bike[
       'start_time'
   ]-pd.to_timedelta(days_away_from_monday, unit='day')
   ```

   half way here -- rounded the dates to the correct Mondays, but the `value_counts`won't work, so use the `dt.date`attribute to just return a `Series`with the dates just:
   `dates_rounded_to_monday.dt.date.value_counts()`

4) To calculate each ride's duration, can subtract the `start_time`column from the `stop_time`column. Pandas will return a `Series`of `Timedelta`s -- need to save this `Series`for next.
   `citi_bike['duration']=citi_bike['stop_time']-citi_bike['start_time']`

5) Have to find the average duration of all bike riders, this process is a simpe, can invoke the `mean`method on the new duration column for the calcuation -- the average ride like: `citi_bike['duration'].mean()`

6) The final question asks to identify the 5 longest bike rides in the data set -- one solution is to sort the duration column values in descending order with the `sort_values`method and then use the `head`method to view the first 5 rows. `citi_bike['duration'].sort_values(ascending=False).head()` And, anohter option is to use the `nlargest()`method can call this on the df: `citi_bike.nlargest(n=5, columns='duration')`

## Cleaning data

Often heard data scientists say tht 80 percent of their job involves cleaning data, what does mean to -- 

- Rename columns
- rename the index
- remove irrelevnt columns
- split one column into two
- Combine two or more columns into one
- remove non-data rows
- remove repeat rows
- remove rows with missing data
- Replace `NaN`data with a single value
- replace `NaN`via interpolation
- Standardize strings
- fix typos
- remove white space from strings
- correct the tpes used for columns
- identify and remoove outliers

`s.isnull, df.isnull, df.repalce, s.map, df.fillna, df.dropna, s.str, df.srot_index, pd.read_excel, s.value_counts`

In the form of the `isnull()`, if  call `isnull`on a column, it reeturns a boolean series -- one that has `True`where there is a `NaN`value, and `False`in other places -- can then apply the `sum`method to the series -- which will return the number of `True`. s.isnull().sum() -- and if run `isnull()`on a df, then will get a new df back -- with `True`and `False`indicating whether therei s a null value in that particluar row-column combination.

Instead of that, can also use the `any`and `all`methods, any will return `True`for each row in which at leat one of the values is `True`. like: `df[df.isnull().all()]` -- show only the rows with no NaN.

Finally, `df.info`method returns a wealth of info about the data frame on which it’s run, including the name and type of each column, a summary of how many columns there are of each type, and the estimated memory usage -- if the data frame is small enough, then it will also show you how many null values there are in each column.

`df.info(*show_counts*=True)`

NOTE : -- Pandas defines both `isna`and `isnull`for both series and df. Actually -- there is ***no difference***. Can also  use the `notnull`methods, for both series and DF.

### Parking cleanup

In this, going to identify missing values, one of the most common problems that you will encounter. It’s reasonable to think that we jsut toss out imperfact data -- if sth is missing, then hope -- load the CSV then:

```python
filename = 'data/nyc-parking-violations-2020.csv'
df = pd.read_csv(filename,
                 usecols=['Plate ID', 'Registration State',
                          'Vehicle Make', 'Vehicle Color', 'Violation Time', 'Street Name'])

```

The `count`method might seem like a better way to get the number of rows -- note that `count`just ignores any NaN values. Moreover, count will retrurn a separate vlaue for each column in the data frame. it can useful if want to compare the number of `non-Nan`values in each column. like:

`df.shape[0], df.count()`

With that data frame in place, can start to make a few queries, looking for tickets that could ponentially be dismissed for lack of data -- first query will apply the native approach, in which we remove any rows that have any missing data.

`all_good_df = df.dropna()`

Just how many rows used `dropna`like: `df.shape[0]-all_good_df.shape[0]`

Get quite a large number, that represent about 3.5 P of the data in the original data rame --  This works, but the better way to do that is using `dropna`, normally, `dropna`removes **any** rows that contains any `NAN`value -- can tell it to look only in a subset of the columns, ignoring `NaN`values in any other columns -- the result is a much cleaner query:

```python
semi_good_df=df.dropna(subset=['Plate ID', 'Registration State', 
                               'Vehicle Make', 'Street Name'])
```

`df.shape[0]-semi_good_df.shape[0]`

According to my calcualation, are the result .. Still a fair amount of. Once agina, can use the `df.dropna`method along with its subset parmeter to remove only those rows that lack all three of these columns.

- how many rows would eliminate if we require at least 3 non-null values from the 4 columns like:

  ```python
  at_least_two_df = df.dropna(subset=['Plate ID', 'Registration State', 
                                      'Vehicle Make', 'Street Name'],
                             thresh=3)
  ```

- But there is plenty of non-null bad data, too, fore, many cars with as a plate ID were ticketed, turn these can:

  ```python
  no_blankplate_df = df.replace({'Plate ID':'BLANKPLATE'}, NaN).
  	dropna(subset=['Plate ID', 'Registration State', 'Vehicle Make', 'Street Name'],  
                                  thresh=3)
  df.shape[0] - no_blankplate_df.shape[0]
  ```

And one common aspect of data cleaning involves creating one new column from several existing columns.

Celebrity -- Sometimes, only a small fraction of the data is unredable, missing, or corrupt, a much larger proportion is problematic -- and if want to use the data set, then you will need to not only remove bad data, but masssage and salvage the good data. NOTE: can find which rows in a column can be successuflly turned into integers by applying the `isdigit`method via the `str`accessor like: `df[‘column’].str.isdigit()`

### Discussion

In this, create and then clear up two-column data frame -- each of these columns needs to be cleaned in a different way -- in roder for us to be able to answer the question --  Cuz we’re only interested in celebrity deaths during months, need like: `df['month']= df.dateofdeath.str.slice(5,7)`

Notice that we aren’t turning the column into an integer, we could do that, but the leading 0 onthe wo..

```python
df['age']=df['age'].astype(np.int64)
```

This will fail -- it’ll actually fail for two different reasons, first, some of the values contain characters other than digits, second, some of the values are `NaN`, which as flaoting-point values. So, before removing the NaN vlaues, should probably check to see how many there are - like: `df['age'].isnull().sum()/df['age'].shape[0]` and like:

`df = df.dropna(subset=['age'])`

So how can I remvoe the rest of the troublesome data -- that is how can remove those rows that contain non-digit characters -- realy the `str.isdigit`method which returns `True`if a string contains only digits.

`df = df[df['age'].str.isdigit()]`

As these complete, can convert our `age`column into an integer type like: `df['age']=df['age'].astype(np.int64)`

- Add a new column, `day`from the day of the month in which the celebrity died. The create a multi-index like:

  ```python
  df = df.set_index('day', append=True)
  ```

- Now replace any `NaN`values in that column with the string `unknown`like:

  ```python
  df['causeofdeath']= df['causeofdeath'].fillna('unknown')
  df.causeofdeath.value_counts()
  df.causeofdeath.value_counts().head(10)
  ```

### Titanic interpolation

When we have NaN values, have a few options -- remove them, leave them, replace them with sth else The answer -- it depends, if you are getting your date ready to feed into a machine-learning model, then you will likely to get ride of the `NaN`valus, either by removing those rows or by replacing them with sth else.

## Opening Gaps Between Flex Items

Flex items are by default, just rendered with no space held open bteween them. Space can appear between items `justify-content`or by adding margins to flex items -- but these appraoches are not always ideal. In essence, `row-gap`acts as if it were called `block-axis-gap`, so, note that there ae gaps only between rows, there are no gaps placed between the flex items and the block-start and -end edges of the flex cntainer.

Note that if were to change the value of the `justify-cntent`to `space-btween`, then in any flex line with leftover space, the gaps between flex items will be increased by an equal amount, meaning they will be separated by more than 15 pixels. and gaps are inserted between the outer margin edges of adjacent flex items, so if you add margins to your flex items, the actual visible space between two flex items will be the width of the gap **Plus** the widths of the margins.

And any percentage value used for a gap is taken to be a percentage of the container’s size along the relevant axis. Thus, given `column-gap: 10%`the gaps will be 10% the inline size of the flex container.

### Flex Items

Create flex containers by adding display: flex and display: inline-flex to an element that has child nodes. The children of those flex containers are called flex items -- When it comes to text-node children of flex containers, if the text node is not empty, it will be wrapped in an anonymous flex item.

### Features

The `flaot`and `clear`don’t have an effect on flex items and do not take a flex item out of the flow. While `float`will not actually float a flex item, setting `position: absolute`is a different -- the absolutely positioned children or flex containers, just like any other absolutely positioned element, are taken out of the flow of the document. More to the point, they do not participate in flex layout and are not part of the document flow. 

And the absolutely positioned child of a flex container is affected by both the `justify-content`value of the flex container and its own `align-self`value.

### minimum Widths

You will note that the flex line inside the container with the `nowrap`default `flex-wrap`value overflows its flex container. This is cuz when it comes to flex items, the implied vlaue of `min-width`is `auto`. And if you set the `min-width`to a width narrower than the computed value of `auto`, if you declare `min-width:0`, the flex items in `nowrap`example will shrink to be narrower than their actual content.

### Flex item specific properties

While flex item’s alignmnet, oreder, and flexibility are to some extent controllable via properties set on their container, several propertie can be applied to individual flex items for more granular control. For the `flex`shorthand property, along with its component properties -- `flex-grow, flex-shrink, flex-basis`-- controls the flexibility of the flex items. Declaring the flex shorthand prop on a flex item -- or defining the individual propertires that make up the shorthand, enables you to define the grow and shrink factors. If there is excess space, can tell the flex to grow.

`flex: 0 1 auto`

The *flex basis* determines how the flex growth and shrink factors are implemented -- as its name suggests -- `flex-basis`component of the flex shorthand is the basis on which the flex item determines how much it can grow to fill available space or how much i should shrink to fit all the flex items when there isn’t enough space. like:

```css
.flexItem {
    width : 50%;
    flex 0 0 200px;
}
```

### The `flex-grow`property

This defines whether a flex item is allowed to grow when space is available. And if so, how much it will proportionally relative to the growth of other flexitem siblings. -- Warning -- declaring the growth factor via the `flex-grow`is *strongly* discouraged by the authors of the specification itself. -- should declare the growth as part of the `flex`shorthand.

Fore the declaration we gavie it is `flex-grow: 1`, but it could be any positive number the browser can understand -- in this case. Then, with the `width`values as well as different growth factors - have flex items tht are 100, 250, and 100.

### The `flex-shrink`property

Specifies shorthand property specfies the `flex shrink`factor -- like: determines how much a flex item will shrink relative to the rest of its flex-item siblings when isn’t enough space for them all to fit.

The last flex item is thus forced to dl all the shrinking necessary to enable all the flex items to just fit within the flex container, with 900 pixels of content needint to fit 750 pixel container. So the two flex items with no shrink factor stay at 300 pixels wide, the 3rd, with a positive value for the shrink factor -- just shrinks 150 pixels.

### The `flex-basis`property

The flex item’s size impacted by its content and box-model properties and can be reset via the 3 components of the `flex`property. And the `flex-basis`of the `flex`defines the initial or default size of flex items, before extra or negatie space is distributed. fore:

```cs
.flex-item {flex-basis: 25%; width: auto;}
.flex-item.fit {flex-basis: fit-content;}
```

So in the first flex line, the flex basis of the flex items is set to 25%, meaning each flex item starts out with 25% the width of the flex line as its sizeing basis -- and is flexed from there at the browser’s discreation.

This is a good illustration of one of the strength of flexbox, can give a general direction to the layout engine and have it do the rest of the work. For the `fit-content`-- equialent of declaring :

`flex-basis: auto; inline-size: auto;`