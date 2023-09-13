# Working with dates and times

A `datetime`is a datat type for storing date and time, can model a specific data, a particular time, or both. Fore, a financial anayst may use datetimes to determinme the weekdays when a stock performs best. Fore, review py's built-in datetime objects and see how pandas improves them with its `Timestamp`and `Timedelta`objects, also learn how to use the library to convert strings to dates, andd an substract offsets of time, calculate durations, and more.

### How py works with datetimes

To reduce the memory consumption, py does not autoload its std lib modules by default. For a `date`models a single day in history -- the object does not store any time -- the `date`class ctor accepts just `year month day`parameters. like:

`dt.date(1991,4,12)`-- The `date`object saves the ctor's args as object attributes. can access their values . like:

`bir.year`, And the `date`is just *immutable*-- cannot change its internal state after we create it. Py will raise an `AttributeError`exception if attempt to overwrite any `date`attributes:

`bir.month=10` # AttributeError

And the complementary `time`class models a specific time of day -- the date is irrelevant -- the `time`ctor's first 3 parameters accept integer arguments for `hour, minute second`-- like a `date`object, a `time`object is immutable.

`dt.time(6,43,25)`, and just note that the default argument for all 3 parameter is 0 -like `dt.time()` And note that the `time`ctor uses a 24-hour clock. And the `time`object saves our ctor as object attributes. can:

`alarm_clock.hour`

For the `datetime`object, which holds both a date and a time -- its first 6 parameters are the `year month day hour minute `and `second`. Note that the year, month, and day paremters are required.

For the `timedelta`-- which models a duration -- a length of time -- its ctor's parmeters include `weeks, days`and `hours`, All the parameters are optional and default to 0. The ctor adds the time lengths to calcualte the total duration. fore: `dt.timedelta(weeks)

`dt.timedelta(weeks=8, days=6, hours=3, minutes=58, seconds=12)`

### How pandas works with datetimes

Py's `datetime`module has had its share of criticism -- some common complaints inlcude:

- A large number of moduels to keep track of -- introduced only `datetime`in this - but additional modules are available for clendars, time conversions, utlity functions and more
- A large number of classes to remember
- Complex difficulat object APIs

So, Pandas introduces the `Timestamp`object as a replacement for the py's `datetime`object. Can view the `Timestamp`and `datetime`as siblings. -- they are often **interchangeable** in the pd ecosystem, such as when being passed as method arguments -- Much as the `Sereis`expands on Py list, the `Timestamp`adds features to the more primitive `datetime`object.

The `Timestamp`ctor is available at the top level of pandas, it accepts the same parameters as a `datetime`ctor, the 3 data-related parameters are required. The 3 date-related parameters are required *year,month day* like:

```py
pd.Timestamp(1991, 4, 12)
pd.Timestamp(year=1991,month=4, day=12)
```

Pandas considers a `Timestamp`to be **equal** to `date/datetime`if the two objcts stores the same information. Can use the `==`symbols to compare object equality.

`pd.Timestamp(1991,4,12)==dt.datetime(1991,4,12)`

Note, must be `datetime`object.

And the `Timestamp`ctor is remarkably flexible and accept a variety of inputs, the next example passes the ctor a string instead of a sequence of integeres, the text stores like: `pd.Timestamp("2015-03-31")`

And, Pandas recognizes many std datetime string formats, the next example replaces the dashes in the date string with:

`pd.Timestamp('03/31/2015')` Can also include the `time`in a variety of written fomrats -- like:

`pd.Timestamp('2021-03-08 09:32:12')`

`pd.Timestamp('2021-03-08 6:13:29 PM')`

Finally, the `Timestamp`ctor accepts Py's native `date, time`and `datetime`objects, the next example parses data from a `datetime`object like: `pd.Timestamp(dt.datetime(2000,2,3,21,34,22))`

And the `Timestamp`object implements all `datetime`attributes, such as `hour, minute, second`... like:

```py
my_time=pd.Timestamp(dt.datetime(2000,2,3,21,35,22))
my_time.year, my_time.month
```

Pandas does it s best to ensure that its datetime objects work similarly to py's built in once.

### Storing multiple timestamps in a `DateTimeIndex`

An `index`in the collection of labels attached to a pandas data structure -- the most common index we've encountered is the `RangeIndex`, a sequence of ascending or descending numeric vlaues. can access the index of a `Series`of a `DataFrame`via the `index`attribute. Pandas uses `Index`obj to store a collection of string labels just like:

`pd.Series ([1,2,3], index=['A', 'B', 'C']).index`

And the `DateTimeIndex`is an index for string `Timestamp`objects, if we pass a list of `Timestamp`s to the Series like:

```py
timestamps=[
    pd.Timestamp('2020-01-01'),
    pd.Timestamp('2020-02-01'),
    pd.Timestamp('2020-03-01'),
]
pd.Series([1,2,3], index=timestamps).index
```

Pandas will also use a `DatetimeIndex`if we just pass a list of Python's `datetime`object like:

```py
datetimes = [i.to_pydatetime() for i in timestamps]
pd.Series([2,3,4], index=datetimes).index
```

Can also create `DatetimeIndex`from scratch -- Its ctor is available at the top level of pandas -- the Ctor's `data`parameter accepts any iterable collection of dates -- can pass the dates as strings, datetimes, `Timestamps`.

```py
string_dates = ['2018/01/02', '2016/04/12', '2008/09/07']
pd.DatetimeIndex(data=string_dates)
mixed_dates = [
    dt.date(2018, 1, 2),
    '2016/04/12',
    pd.Timestamp(2009, 9, 7)
]
dt_index = pd.DatetimeIndex(mixed_dates)
dt_index
```

Now that have a `DatetimeIndex`assigned to a `dt_index`variable, attach it to a panda data structure, the next example connects the index to a sample `Series`like:

`s= pd.Series(data=[100,200,300], index=dt_index)`

Date- and time-related operations become possible in pandas only when we store our values as `Timestamp`rather than strings. Pandas can't reduce a day of the week from a string like `2018-01-02`, cuz it views it as beging a collection of digits and dashes, not an actual date. `s.sort_index()`-- pandas accounts for both date and time when sorting or comparing datetimes. if two `Timestamp`s use the same date, pandas will compare their hours, minutes, seconds. A variety of sorting and comparison operations are available for `Timestamp`s out of the box. fore, checks whether one `Timestamp`occurs eariler than another like:

`morning = pd.Timestamp('2020-01-01 11:23:22 AM')`
`evening= pd.Timestamp('2020-01-01 11:23:22 PM')`

### Converting column or index values to datetimes

Our first data set for this holds nearly 60 year's worth of stock prices for Company -- one of the world's most recognized entertainment brands -- each row includes a date, the stock's highest and lowest value throughout that day, and its opening and closing prices -- like: The `read_csv`defaults to importing all values in non-numeric columns as strings.

Besides using the `parse_dates=["Date"]`parameter, an alternative solution is the `to_datetime()`conversion function at the top level of pandas -- the function accepts an iterable object, converts its value to datetimes, and returns the new values in the `DatetimeIndex`.

```py
string_dates= ['2015-01-01', '2016-02-02', '2017-03-03']
dt_index=pd.to_datetime(string_dates)
dt_index
```

Pass the `Date`Series from the disney to the `to_datetime`functin like:

`pd.to_datetime(disney['Date']).head()`

We've got a `Series`of datetimes, so overwrite the original `DataFrame`, the next code sample replaces the original Date column with the new datetime `Series`, remember that Py evaluates the right side of an equal sin ifrst like:

```py
disney.Date= pd.to_datetime(disney.Date)
disney.Date
```

### Using the `DatetimeProperties`object

A datetime `Series`holds a special `dt`attribute that exposes a `DatetimeProperties`object like:

`disney['Date'].dt` -- can access attributes and invoke methods like:

```py
china_date = ['2019年6月27日10时']
pd.to_datetime(china_date, format='%Y年%m月%d日%H时',errors='coerce')
```

Begin our exploration of the `DatetimeProperties`object with the `day`attrbiute, which pulls out the day from each date.

`disney['Date'].dt.day.head(3)`# note that this returns a int32

And the `month`attribute just returns a `Series`with the month numbers, fore Jan is 1. It's important to note that this is different from how we typically count in python/pandas, where we assign the first item a value of 0.

`disney.Date.dt.month.head(3)`

One example is the `dayofweek`attribute -- which returns a `Series`of numbers for each date's day of the week. 0 denotes .. `disney.Date.dt.dayofweek.head()`-- and what if just wanted the weekday's name instead of its number, the `day_name`method does the trick like: `disney.Date.dt.day_name().head(3)`.

Canpair these `dt`attributes and methods with other pandas features for advanced analyses. like:

```py
disney["Day of Week"]=disney['Date'].dt.day_name()
group= disney.groupby('Day of Week')
group.mean(numeric_only=True)
```

And, some attributes on the `dt`object return `Booleans`, suppose that want to explore `Disney`stock performance at the start of each quarter in its history -- the four quarters of a business year start on . 1/1, 1/4, 1/7, 1/10, -- the `is_quarter_start`attribute returns a `Boolean`sereis which `True`denotes theat the row's date fell on the quarter:

`disney.Date.dt.is_quarter_start.tail()`

Can use the Boolean `Series`to extract the disney rows that fell at the beginning of a quarter. like:

`disney[disney.Date.dt.is_quarter_start].head()`

Can also use the `is_quarter_end`attribute to pull out dates that fell at the end of a quarter. And the complentary `is_month_start`and `is_month_end`attriutes confirm that a date fell at the beginning or the end of a month.

`disney[disney['Date'].dt.is_month_start].head()`

And the `is_year_start`returns `True`if a date fells at the start of year. and `is_year_end`, 12-31..

### Adding and subtracting durations of time

Can add or subtract consistent durations of time with the `DateOffset`object, its ctor is available at the top level of pandas, the ctor accepts parameters for years, months, days, and more.

`pd.DateOffset(years=3, months=4, days=5)`

For the sake of example, just imagine that our recordkeeping system malfunctioned, and the dates in the Date column are off by five days, can add a consistent amount of time to each dae in a datetime like:

`(disney['Date']+ pd.DateOffset(days=5)).head()`

When paired with a `DateOffset`, minus sutracts a duration from ach date in a datetime `Series`. like:

`(disney["Date"]-pd.DateOffset(days=3)).head()`

Although the previous output does not show, The `Timestamp`object *do* store a time internally. When we converted the Date column's values to datetimes, pandas assumed a time of midnight for each date. the next example adds an `hours`parameter to the `DateOffset`ctor to add a consistent time to each datetime in Date.

`(disney['Date']+ pd.DateOffset(days=10, hours=6)).head()`

Pandas applies the same logic when substrcting a duration, the next example subtract one year, three months, .. like:

`(disney['Date']- pd.DateOffset(years=1, months=3, hours=6, minutes=3)).head()`

## State SAT scores

As have seen, setting the index cna make it easier for us to create queries about our date. Sometimes, our data is hierarchical in nature -- concept of a *multi-index* come into play. Look at a summary of scores from the SAT In this, started to discover the power and flexibility of a multi-ndex -- asked u to load the CSV file and create a multi-index based on the `year`and `state code`columns. like:

`df = df.set_index(['Year', 'State.Code'])`

Notice that, as always, the result of the `set_index`is a new data frame, one which we assign back to the df. Notice that as always, the result of `set_index`is a new data frme, one which we assign back to `df`. However, you might remember that `read_csv`also has a `index_col`parameter, if pass an arg to that parameter, can tell `read_csv`to do it all in one step - reading in the data frame and setting the index to be the column that we request.

```py
df = pd.read_csv('data/sat-scores.csv', index_col=['Year', 'State.Code'],
                 usecols=['Year', 'State.Code', 'Total.Math', 'Total.Test-takers', 'Total.Verbal'])
```

And remember that when are receiving from a multi-index, need to put the parts together inside of a tuple, moreover, can indicate that we want more than one value by using a list -- like:

`df.loc[(2010, ['Ny', 'Nj']), 'Total.Math'].mean()`

The query retrieves row wiht a year of 2010, and coming from any of those four states.

### Solution

`df.loc[(2010, ['NY', 'NJ', 'MA', 'IL']), 'Total.Math']`

- What were the average math and verbal scores, for Florida, Indiana, just across all years like:
  `df.loc[(slice(None), ['FL', 'IN', 'ID']), ['Total.Math', 'Total.Verbal']]`
- Retreive rows from 2012-2015 with thow 3 states and the column `TotaolMath`then get the average like:
  `df.loc[(slice(2012,2015), ['AZ', 'CA', 'TX']), ...]`

### Olympic Games

A multi-index doesn’t have to stop at just two levels, pands will , in theory, allow us to set as many as we want. Consider a large corporation that has broken down sales reports by region, country, and department; a multi-index would make it posible to retrieve that data in a variety of different ways.

```python
filename = 'data/olympic_athlete_events.csv'
df = pd.read_csv(filename,
                 index_col=['Year', 'Season', 'Sport', 'Event'],
                 usecols=['Age', 'Height', 'Team', 'Year', 'Season', 'City', 'Sport',
                          'Event', 'Medal'])
df= df.sort_index()
```

Note, can just invoke `set_index`with `inplace=True`, if do this, then `set_index`will modify the existing data frame object, and will return `None`. The core developers strongly recommend agsinst doing this -- should invoke this regurlarly -- and then assign the result to a variable.

`df.loc[(slice(1936, 2000), 'Summer'), :]`

`df.loc[(slice(1936, 2000), 'Summer'), 'Age'].mean()`

Next, asked to find which team has won the greatest number of medals for all archery events.

`df.loc[(slice(1936, 2000), 'Summer', 'Archery'), `

`		'Team'].value_counts(*ascending*=False).head(1)`

Next, asked U to find the average height of athletes on one specific event, namely `Table Tennis Woman's Team`, once again, can consider all of the parts of our multi-index like:

```python
df.loc[(slice(None), 'Summer', slice(None), "Table Tennis Women's Team"), 'Height'].mean()
# or:
df.xs(['Summer', "Table Tennis Women's Team"], level=[1,3])['Height'].mean()
```

```python
df.xs((slice(1980, 2020), 'Summer', 'Tennis'), level=[0, 1, 2])['Height'].max()
df.loc[(slice(1980, 2020), 'Summer', 'Tennis'), 'Height'].max()
```

Cuz multi-indexed data frames are both common and important, pandas just provides a number of ways to retrieve data from them -- `xs`-- lets us accomplish what did -- namely find matches for certain levels within a multi-index, fore, one question for:

`df.xs(('Summer' "Table Tennis Women's Team"), level=['Season', 'Event']).mean()`

`xs`is a method, and is tuhs invoked with `()`, by contrast, `loc`is just an accessor attribute, is invoked with `[]`.

And a more general way to retreive from a multi-index is known as `IndexSlice`-- for the `slice(None)`problem, use:

```python
from pandas import IndexSlice as idx
df.loc[idx[1980:2016, : , 'Swimming':'Table tennis'], ...]
```

The above allows us to select a range of values for each of levels of the multi-index. No longer do we need to call the `slice`function. The result of calling `IndexSlice`is a tuple of python slice objects like:

`(slice(1980, 2020, None), slice(None, None, None), slice(...))`

`df.reset_index('Season').loc[(slice(1980, 2020), 'Tennis'), 'Height'].max()`

`df.loc[(slice(1980), 'Gold'), 'City'].value_counts(*ascending*=True).index[-1]`

```python
np.random.seed(0)
df = pd.DataFrame(np.random.randint(0, 100, [36, 3]),
columns=list('ABC'))
df['year'] = [2018] * 12 + [2019] * 12 + [2020] * 12
df['month'] = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split() * 3
```

```python
df.pivot_table(index='month', columns='year', values='A')
```

And U can certainly understand the data, if you look at in a certain way. but what if we were interested in seeing sales figures for product A -- it might make more sense, and be easier to parse. And notice that the months are sorted in a order, so just like:

```python
df.pivot_table(index='month', columns='year', values='A', sort=False)
```

Now pandas won’t change the order of our rows, resulting in a pivot table that is quite useful.

## Making sense of floats

At the end of the part1, covered some fundamenal of element sizing and spacing -- build on these concepts by looking closer at the primary methods for layout out the page. Look at the 3 most important methods to alter document flow -- *floats, flexbox, and grid layout.* 

### Purpose of floats

Just pulls an element to one side of its container, allowing the document flow to wrap around it. This layout is common in newspapers and mazines. A floated element is removed from the normal document flow and *pulled to the edge of the container.* The document flow then resumes, but it will wrap around the sapce where the floated now resides.

```css
:root {
    box-sizing: border-box;
}

*, ::before, ::after{
    box-sizing: inherit;
}

body {
    background-color: #eee;
}

body * + * {
    margin-top: 1.5em;
}

header {
    padding: 1em 1.5em;
    color: #fff;
    background-color: #0072b0;
    border-radius: .5em;
    margin-bottom: 1.5em;
}

.main {
    padding: 0 1.5em;
    background-color: #fff;
    border-radius: .5em;
}
.container{
    max-width: 1080px;
    margin: 0 auto;
}
```

By using the `max-length`instead of width, the element just shirinks to below 1080 if the screen’s viewport is smaller.

### Container collapsing and the clearfix

In the past, browser bugs have plagued the behavior of floats.

```css
.media {
    float:left;
    width: 50%;
    padding: 1.5em;
    background-color: #eee;
    border-radius: .5em;
}
```

The problem is that -- unlike element in the normal document flow, *floated elements do not add height to their parent*. This goes back the original purpose of floats. Floats are intended to allow text to wrap around them. When float an image inside a paragrpah, does not grow to contain the image. This means -- if the image is taller then the text of the paragrpah, the next will start immediately below the text of the first, and the text in both paragraph will wrap around the float. In page -- 

everything inside the main is floated except for the page title, so only the page title contributes height to the container. Leaving all the floated media elements extending below the white background of the main. The main should extend down to the contain the gray boxes.

```css
.main::after{
    display: block;
    content: ' ';
    clear:both;
}
```

The `clear:both`declaration causes this element to move below the bottom of floated elements. rather beside them. This elmeent itself is not floated, the container will extend to encompass it.

It is important to know that the clearfix is applied to the element that contains the floats, a common mistake is to apply it to wrong element.

One inconsistency with this clearfix remains -- Margins of floated elements inside won’t collapse to the oustside of the clearfixed container. But, margins of non-floated elements will collapse as normal. Some developers prefer to use a modified version of the clearfix that will contain all margins cuz it can be slightly more predictable.

### Unexpected float catching

Now that the white container contains the floated media elements on page - The four media boxes are not laying out in two even rows like want. But the thrid is on the right -- beneath the second box. This leaves a large gap below the first box, which happens cuz the browser places floats high as possible. Cuz box 2 is shorter than 1 -- there is room for box 3 beneath it. It doesn’t float all the way to the left edge, but rather floats against the bottom corner of box 1.

The exact nature of this behavior is dependent on the heights of each of the floated blocks. Even a 1px difference in element heights can cause problems.

To fix -- the third needs to *clear the float above it*. Or, more generally, the first of each row needs to clear the float above it. U know have two boxes per row -- need the odd numbered elements to each clear the row above. Cuz the browser places floats as high as possible.

```css
.media:nth-child(odd){
    clear: left;
}
```

Also, add margins to our media elements to provide a gutter between them like:

```css
.media {
    float:left;
    margin: 0 1.5em 1.5em 0;
    width: calc(50% - 1.5em);
    padding: 1.5em;
    background-color: #eee;
    border-radius: .5em;
}
```

### Media object and block formatting contexts

```css
.media-image {
    float:left;
}

.media-body{
    margin-top: 0;
}

.media-body h4 {
    margin-top:0;
}
```

Establishing the BFC -- Will see that its box extends all the way to the left -- so it envelops the floated image. A BFC itself is part of the surrounding document flow -- but it isolates its contents from the outside context. This isolation does 3 things for the element that establishes the BFC like:

1) contains the top and bottom margins of all elements within it. They won’t collapse with margins of elements outside the block formatting context.
2) It contains all floated element witin it.
3) Doesn’t overlap with floated elements outside theBFC.

```css
.media-image {
    float:left;
    margin-right:1em;
}

.media-body{
    margin-top: 0;
    overflow: auto;
}
```

Building a grid system -- like:

```css
.row::after{
    content:'';
    display: block;
    clear:both;
}

[class*="column-"]{
    float:left;
}

.column-6{width: 50%}
```

For this, a *attribute selector* targeting elements based on their `class`attribute, this allows you to do sth a little more complex than what you can do with a normal class selector.

```css
:root {
    box-sizing: border-box;
}

*, ::before, ::after {
    box-sizing: inherit;
}

body * + * {
    margin-top: 1.5em;
}

.row::after {
    content: '';
    display: block;
    clear: both;
}

[class*="column-"] {
    float: left;
    padding: 0 .75em;
    margin-top: 0;
}

.row {
    margin-left:-.75em;
    margin-right: -.75em;
}

.container {
    max-width: 1080px;
    margin: 0 auto;
}

.column-6 {
    width: 50%
}

.media-image {
    float: left;
    margin-right: 1.5em;
}

.media-body {
    overflow: auto;
    margin-top: 0;
}

.media {
    padding: 1.5em;
    background-color: #eee;
    border-radius: 1.5em;
}

.media-body h4 {
    margin-top: 0;
}

.clearfix::before,
.clearfix::after {
    display: table;
    content: " ";
}

.main {
    padding: 0 1.5em 1.5em;
    background-color: #fff;
    border-radius: .5em;
}
```

## Fetching Data as Streams

```ts
@Injectable({
  providedIn: 'root'
})
export class RecipesService {

  constructor(private http: HttpClient) { }
  getRecipes(): Observable<Recipe[]> {
    return this.http.get<Recipe[]>('http://localhost:3001/api/recipes');
  }
}
```

Inject and subscribing to the service in your component -- 

```ts
@Component({
  selector: 'app-recipe-list',
  templateUrl: './recipe-list.component.html',
  styleUrls: ['./recipe-list.component.scss']
})
export class RecipeListComponent implements OnInit{
  recipes!: Recipe[];
  
  constructor(private service: RecipesService) {
  }
  
  ngOnInit():void {
    this.service.getRecipes().subscribe(result=> {
      this.recipes=result;
    })
  }
}

```

Have a `getRecipes()`memthod that gets the list of recipes over HTTP and returns a strongly typed HTTP response: `Observabel<Recipe[]>`-- this `Observable`notifier represents the data stream that will be created when you issue the HTTP get reuests.

### Managing unsubscriptions

There are two commonly used ways to mange unsubscriptions -- the imperative pattern and the declarative and reactive patterns -- imperative unsubscription mangement -- the imperative unsubscription just means that we manually call the `unsubscribe()`method on the subscription object that we manage ourselves. -- the following code snippet illustrates this -- simply store the subscription inside a variable. Just like:

you should handle the ussubscription of the observable, as this code manages usbscriptions manually.

```ts
export class RecipeListComponent implements OnInit, OnDestroy{
  recipes!: Recipe[];
  subscription!: Subscription;
  constructor(private service: RecipesService) {
  }

  ngOnInit():void {
    this.subscription =
    this.service.getRecipes().subscribe(result=> {
      this.recipes=result;
    })
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }
}
```

### Declarative unsubscription management

The second way is far more declarative and cleaner -- it uses the RXJS `takeUntil`operator -- before dive into this pattern, gain an understanding of the role of `takeUntil`. For this, takes vaues from the source observable, until the `Observable`notifier, which is given as input. For this the `takeUntil()`opertor will hlep keep the subscription alive for a period that we define -- want it to be alive until the component has been destroyed.

```ts
export class RecipeListComponent implements OnInit, OnDestroy{
  recipes!: Recipe[];
  destroy$ = new Subject<void>();
  constructor(private service: RecipesService) {
  }

  ngOnInit():void {
    this.service.getRecipes()
      .pipe(
        takeUntil(this.destroy$),
      )
      .subscribe(result=> {
      this.recipes=result;
    })
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

The first thing might noteice here is that it’s less code than the first -- furthermre, when call `unsubscribe()`on a returned subscription object, there is no way wen can be notified that the unsubscription happened. Additionally, you can use other operators that manage the unsubscription for you in a more reactive way - fore, take a look like:

- `take(X)` -- this emits x values and then completes
- `first() last()`- emit the first and last value and then completes.

### Exploring the reactive pattern for fetching data

The idea behind the reactive pattern is to keep and use the observable as a stream throughout the application.

```ts
export class RecipesService {

  constructor(private http: HttpClient) { }
  recipes$ = this.http.get<Recipe[]> (
    'http://localhost:3001/api/recipes'
  );
}

```

### Defining the stream in component

Now in `RecipeListComponent`, going to do the same thing did in the classic pattern, that is, declaring a variable holding the stream returned form service -- like:

```ts
export class RecipeListComponent{
  recipes$ = this.service.recipes$;
  constructor(private service: RecipesService) {   
  }
}
```

Then, using the `async`pipe in your template -- the `async`pipe makes rendering values emitted from the observable easier, it automatically subscribes to the input observale.

`<div *ngIf="recipes$ | async as recipes" class="card">`

By doing so, don’t need the `ngOnInit`life cycle, and will not subscribe to the `Observable`notifier in `ngOnInit()`and unsubscribe from `ngOnDestroy()`.

### Using the declarative approach

What is wrong with `subscribe()`-- subscribing to a stream inside our component means we are allowing imperative code to leak into our functional and reactive code. Using the RxJS observables does not make your code reactive and declarative systematically.

- *Declarative* refers to the use of declarated functions to perform actions, you rely upon pure functions that can define an event flow.
- A *pure* function is a function that will always return identical outputs for identical inputs.

### Using the change detection strategy of `OnPush`

The other really cool thing is that we can use the `changeDetection`-- `OnPush`-- Change detection is one of the powerful featurs of Ng, it is about detecting when the component’s data changes and then automtically re-rendering the view or updating the DOM to replect that change -- the default is of *check always*.

With `OnPush`strategy, Angular will only run the change detector when the following occurs -- 

1) A component’s `@Input`prop reference changes -- bear in mind that when the input property object is mutated dirctly then the refrence of the object will not change and consequently the change detector will not run.
2) A component event handler is emitted or gets triggered.
3) A bound observable via the `async`pipe emits a new value.

### Error Handling

- completion status -- when the stream has ended without errors and will not emit any further values, `SHUT DOWN`
- Error status -- when stream has ended with an error and will not emit any further values after the error is thrown.

The first classic pattern will learn for handling errors is based on the `subcribe()`method -- takes as input the object Observer, which has three callbacks -- 

- A success - called every time the stream emits a value and receives as input the value emitted.
- An error callback -- called when an error and receives as input the error itself.
- A completion callback -- when the stream completes.

```ts
stream$.subscribe({
    next: res=> console.log(res),
    error: err=> console.log(err),
    complete: ()=> console.log('Stream completed'),
})
```

### Handling errror operators

`catchError`operator -- according to the RxJS official -- catches errors on the observable to be handled by returning a new observable or throwing an error.

Subscribes to the source `Observable`object that might error out and emits values to the observer until an error occurs. When that happens, the `catchError`operator executes a callback function, passing in the error. like:

```ts
stream$.pipe(
	catchError(error=>{
        // handle the error received
    })
).subscribe()
```

- A replace strategy
- A rethrow
- A retry

### Replace strategy

The error handling function returns an `Observable`, which is going to be a replacement Observable for the stream that just errored out. This replacement `Observable`is then going to be subscribed to, and its value are going to be used in place of the errored-out input. like:

```ts
import { catchError, from, map, of } from "rxjs";

const stream$ = from('5 10 6 Hello 2'.split(' '));
stream$.pipe(
    map(value => {
        if (isNaN(value as any)) {
            throw new Error('This is not a number');
        }
        return parseInt(value);
    }),
    catchError(error => {
        console.log('Caught error', error);
        return of();
    })
).subscribe({
    next: res => console.log('value emitted', res),
    error: err => console.log('error occurred', err),
    complete: () => console.log('stream completed'),
});
```

