# Wide vs. Narrow data

A wide data set increases in width, it grows out. A narrow grows down. A wide data set is ideal for seeing the aggregate picture -- the complete -- if care about is the on .. the data is easy to read and understand. But, the wide format has its share of disadvantages too.

A narrwo data set grows vertically. A narrow format makes it easier to manipulate existing data and add new records.

### Creating a pivot table from a DF

A *pivot table* aggregeates a column's values and groups the results by using other column's values -- the word aggregate describes a summary computation that just involves multiple values.

`sales.pivot_table(index="Date", values=['Expenses', 'Revenue'])` # need to note the values parameter

The method returns a regular `DataFrame`object, may be a bit -- this DF is piovt table -- the table shows average expenses and average revenue organized by the 5 unique dates in the Data Column.

Have to modify some method arguments to reach our original goal -- a sum of each data's revenue organized by salesman like: `sales.pivot_table(index="Date", values=['Expenses', 'Revenue'], aggfunc='sum')` The `values`parameter accepts the `DataFrame`column(s) that pandas will aggregate. just like:

`sales.pivot_table(index='Date', values='Revenue', aggfunc='sum')`

And to aggregate values across multiple columns, can pass values a list. One final step is communicating how much each salesman contributed to the daily total. Add a columns parameter to method invocation and pass it an argument of `Name`. like:

`sales.pivot_table(index='Date', columns='Name', values=['Revenue', 'Expenses'], aggfunc='sum')`

For this, have an aggregated sum of revenue orgnaized by dates on the row axis and salesmen on the column axis. Notice the presence of `NaN`in the data set. -- Those denotes that the salesmane did not have a row in `sales`with a Revenue values for a given date. Can just use the `fill_value`parameter to just replace all pivot table `NaN`s with a fixed value like:

```py
sales.pivot_table(index='Date', columns='Name', values='Revenue',
                  aggfunc='sum', fill_value=0)
```

May also want to see the revenue subtotals for each combination of date and salesman, like: Can just pass an argument of `True`to the `margins`parameter to add totals for each row and column like:

```py
sales.pivot_table(
    index='Date', columns='Name', values='Revenue',
    aggfunc='sum', fill_value=0, margins=True
)
```

If present of `All`in the row lables -- changes the visual representation of the dates -- which now inlcude the HMS -- Pandas need to support bot dates and string index labels -- A string is the only data type that can repreent either a date or a text value. can also use the `margins_name`to customize the subtatal labels.

```py
sales.pivot_table(
    index='Date', columns='Name', values='Revenue',
    aggfunc='sum', fill_value=0, margins=True, margins_name='Total'
)
```

### Additional options for pivot tables

A pivot table supports a variety of aggregation operations -- suppose -- interested in the number of business deals closed per day, can pass `aggfunc`an `count`to count the number of sales rows for each combination of date and employee.

```py
sales.pivot_table(
    index='Date', 
    columns='Name',
    values='Revenue',
    aggfunc='count'
)
```

A `NaN`value indicates that the salesman did not make sale on given day. `max, min, std, median, size` , note that size is just the `count`.

Can also pass a list of aggrfunc to the funtions - will create just a `MultiIndex`on the column axis and store the aggretations in its outermot level. like:

```py
sales.pivot_table(
    index='Date', 
    columns='Name',
    values='Revenue',
    aggfunc=['sum', 'count'],
    fill_value=0
)
```

Can also apply different aggregations to different columns by passing a dictionatry to the `aggfunc`parameter, using the dictionary's keys to identify `DataFrame`columns and the values to set the aggregation. just like:

```py
sales.pivot_table(
    index='Date',
    columns='Name',
    values=['Revenue', 'Expenses'],
    aggfunc=dict(Revenue='sum', Expenses='count'),
    fill_value=0
)
```

Can also stack multiple grouping on a single axis by passing the `index`parameter a list of columns -- The next aggregates the sum of expenses by salesman and date on the row axis.

```py
sales.pivot_table(
    index=['Name', 'Date'], values='Revenue', aggfunc='sum'
).head(10)
```

Switch the order of strings in the index list to rearrange the levels in the pivot table's `MultiIndex`. Like:

```py
sales.pivot_table(
    index=['Date', 'Name'], values='Revenue', aggfunc='sum'
).head(10)
```

### Stacking and unstacking index levels

Here is a remainder of what sales looks like currently -- Just pivot sales to roganize revenue by employee name and date. Place dates on the column axis and names on the row axis like:

```py
by_name_and_date= sales.pivot_table(
    index='Name', 
    columns='Date', 
    values='Revenue', 
    aggfunc='sum',
)
by_name_and_date
```

Sometimes, need to move an index level from one axis to another -- This change offers a different presentation of the data, and can decide which view we like better -- The `stack`moves an index level *from column axis to the row axis*.

`by_name_and_date.stack()`

Need to note that this returns a `Series`-- pandas kept cells with `NaNs`to just maintain the structural integrity of rows and columns -- the shape of this `MultiIndex`allows pandas to discard the `NaN`values.

And the complementary `unstack`method moves an index level from the row axis to the column axis -- consider the following pivot -- which groups revenue by customer and salesman -- the row axis has a two-level `MultiIndex`and the column axis has a regular index like:

```py
sales_by_customer= sales.pivot_table(
    index=['Customer', 'Name'],
    values='Revenue',
    aggfunc='sum'
)
sales_by_customer
```

And the `unstack`method moves the **innermost** level of row index to column index. FORE:

`sales_by_customer.unstack()`

And this returns a new `DataFrame`and column axis now has a two level `MultiIndex`, and the row axis has a regular one-level index.

### Melting a data set

A pivot table aggregates the values in the data, in this, will learn how to do the opposite. Break an aggregated of data into an unaggregated one -- Apply wide-versus-narrow framework to the sales `DataFrame`. For the `Sales`df, is a narow data set. Each row just represents a single observation of a given variable.

Often have to choose between flexibility and readibility when manipulating in a wide or narrow format. could represent the last four .. The DataFrame just stores its data in wide format. Cuz four columns store just the same data point. Want to move the values to a new Region column. Melting is the process of converting a wide data to a narrow one. The method accept two primary parameters -- 

- `id_vars`-- sets the identifier column -- the column for which the wide data set aggregate data.
- The `value_vars`-- accepts columns whose valus pandas will melt and store in a new column.

`video_game_sales.melt(id_vars='Name', value_vars='NA')`

Then melt all four of the regional sales columns, the next code sample passes the `value_vars`parameter a list of 4 regional sales columns from that. Just like:

`video_game_sales.melt(id_vars='Name', value_vars=['NA', 'EU', 'JP', 'Other'])`

```py
video_game_sales.melt(id_vars='Name', value_vars=['NA', 'EU', 'JP', 'Other'], 
                      var_name='Region', value_name='Sales')
```

Now, narrow this data is easier to aggretate than wide data, say, want t find the sum of each video game's sale across all regions, given the metled data set, can use the `pivot_table`method to accomplish this task with a few lines of code.

```py
by_region.pivot_table(
    index='Name', values='Sales', aggfunc='sum'
)
```

Just note: `id_vars`is the *identifier* column, and the `value_vars`accepts the column(s) whose values panda will melt and store in a new column. Then has name/value pair, so need to set the names -- just use the `var_name`and `value_name`.

### Exploding a list of values

sometimes, a data set stores multiple values in the same cell. May want to break up the data cluster so that row stores a single value.

```py
recipes= pd.read_csv('../pandas-in-action/chapter_08_reshaping_and_pivoting/recipes.csv')
recipes
```

Recall the `str.split`method -- This uses a delimiter to split a string into substrings. Can split each ingredients string by the presence of a comma. Pandas returns a series of lists, each list stores the ingredients for the row.

`recipes['Ingredients'].str.split(',')`
`recipes['Ingredients']=recipes['Ingredients'].str.split(',')`

Now we can spread our each list's values acorss multiple rows -- the `explode`method creates a separate row from each list element in a series. So the `explode`just to columns direction like:

`recipes.explode('Ingredients')`

## Advanced Async

Back in VanillaJS, a solution might have started off based on an event listener like:

```ts
fromEvent(searchBar, 'keyup')
.pipe(
	pluck('target', 'value'),
    switchMap(query=> ajax(endpoint+searchVal))
).subscribe(results=> updatePages(results))
```

`switchMap`works the same way as mergeMap, -- for every item, runs the inner `Observable`, waiting for it to complete before sending the results down stream. There is one big exception -- if a new value arrives *before* the inner observable initited by the previous value completes, `switchMap`unsubscribes from the observable requst.

### Skipping Irrelevant Requests

Have two more tricks up your sleeve to cut down on these superfluous requests. For `keyup`will fire on any keystroke, not jsut one that modifies the query -- in this case, making a request with an identical query isn’t useful, so want to dispose of any identical events until there is a new query, Unlike the generic `filter`operator that looks at only one value at a time, this is a *temporal* filter. Rx provides the `distinctUntilChanged`operator works just how you want it to -- it keeps track of the last value to be passed along -- and only passes on a new vlaue when it is just different from the previous value, can add this with a single line and head out for an early lunch. like:

```ts
fromEvent(searchBar, 'keyup')
.pipe
(
    pluck('target', 'value'),
    filter(query=> query.length>3),
    distinctUntilChanged(),
    debounceTime(333),
    switchMap(query=> ajax(endpoint+searchValue))
).subscribe(...)
```

### Handling the response data

for this, a single function is handling all the results, there is also no error handling -- add an error using the techniques

```ts
.subscribe(
	results=> updatePage(results),
    err => handleError(err)
)
```

This error handler just handles the error gracefully and unsubscribes from the stream, when your observable enters the errored state, it no longer detects keystorkes.

Using `catchError`-- This operator is on the surface -- it triggers whenever an error is thrown - but it provides plenty of options for how U handle the next steps. like:

```ts
catchError(err=> {throw err;})
```

This just no difference -- For the use of the `catchError`to make sense, can:

`catchError(err=> {throw 'touble getting predications from the server'})`

This still results in the observable entering the erroed state, but the error is clear. So, what if want to continue like:

`catchError((err, caught$)=>caught$;)`

Rx looks for anything that can be easily turned into an observable, array, promise, or another observable, Rx then converts the return value into an observable. Don’t want to completely ignore errors. So use the `merge`.

```ts
fromEvent(searchBar, 'keyup')
    .pipe(
        pluck('target', 'value'),
        filter((query: string) => query.length > 3),
        distinctUntilChanged(),
        debounceTime(333),
        tap(() => loadingEl.style.display = 'block'),
        switchMap(query => ajax(endpoint + query)),
        catchError((err, caught$) =>
            merge(of({err}), caught$)),
        tap(() => loadingEl.style.display = 'none')
    ).subscribe(function updatePageOrErr(results: any) {
        if (results.err) {
            alert(results.err);
        } else {
            displayResults(results.response);
        }
    },
    err => alert(err.message));
```

### Async and evented -- the browser

Node provides an event-driven and async platform for server-side Js. It’s important to understand how the browser works in order to understand how Node works -- both are just event-driven -- and non-blocking when handling I/O.

### Building a Stock Ticker

Going to build a stock market viewer -- which will display the prices of several fake stocks in real time -- the server will send data to the frontend at any time, and the code need to be ready to react to new events.

## What Redis data structures look like

STRINGs, LISTs, SETs, HASHes, and ZSETs -- each of 5 different structures have some shared commands.

| Structure type |                     What it contains                     | Structure read/write ability                                 |
| :------------: | :------------------------------------------------------: | :----------------------------------------------------------- |
|   `STRINGS`    |               Strings, integers, floating                | Operate on whole strings, parts, increment/decrement the integers and floats |
|     `LIST`     |                  Linked list of strings                  | push or pop items from both ends, trim based on offsets, read individual or multiple items, find and remove. |
|     `SET`      |               unordered of unique strings                | Add, fetch, or remove individual items checking membership, intersect, union, diffrence, fetch random items |
|     `HASH`     |                   Unordered hash table                   | Add, fetch, remove individual items                          |
|     `ZSET`     | oredered mapping of string members to float-point scores | Add, fetch..                                                 |

### Strings

`Strings`are similar to strings that -- diagram that represent keys and values, the digrams have the key name and type of the value along the top of box -- fore, hello has world. and the operation availble to STRINGs start with what’s available in other k-v stores. like:

- `GET`-- fetch at a given key
- `SET`-- sets the values stored at the given key
- `DEL`-- deletes the value stored at the given key.

### Lists

Lists in Redis store an ordered sequence of strings, and like strings, represent LISTs as a labeled box with list items inside that - operations that can be performed on LISTs are typical of what we find in almost any programming language. `LPUSH/RPUSH`, `LPOP/RPOP`. Like:

- `RPUSH`-- pushes the value onto the right end of the list.
- `LRANGE`-- Fetches a range from the list
- `LINDEX`-- fetches an item at given pis.

### Sets

`SETs`use a hash table to keep all strings unique -- cuz it’s unordered, can’t push and pop items from the end. Instead, use `SADD`, `SREM`comands, find other `SISMEMBER`, or fetch entire set with `SMEMBERS`.

### Hashes

Redis `HASHes`store a mapping of keys to values the value that can be stored in `HASHes`as the same as what can be stored as normal `STRING`.

`HSET, HGET, HGETALL HDEL`

### Sorted Sets

The keys (members) are unique, and the values are lmited to floating-point nubmers -- `ZSETs`have the unique prop in Redis of being able to be accessed by member. Just:

`zadd, zrange, zrangebyscore, zrem`

- `zrange`-- fetches items in zset from their positions in sorted order
- `zrangebyscore`-- fetches items in `zset`based on a range of scores.

```python
x = np.linspace(0, 15, 16)
y = np.logspace(.1, 2, 16)
plt.plot(x, y, 'o--')
```

### Single-line Plots

When there is only one visualization in a figure that uses the function `plot()`.

```python
x=[4,5,3,1,6,7]
plt.plot(x)
```

In this the y-axis are assumed -- another 

```python
x= np.arange(25)
plt.plot(x, [y**3+1 for y in x]  )
plt.plot(x, -x**2)
plt.plot(x, -x**3)
plt.plot(x, -2*x)
plt.plot(x, -2**x)
```

Matplotlib just automatically assigns colors to the curves separately. Can also write the same code in simple way like:

`plt.plot(np.array([[3,2,5,6],[7,4,1,5]]))`

In this example, Just generated the data in random way using the routing `np.random.randn()`.

Understandably, provide two lists their length must match like:

`plt.plot([0,1,2,3,4], [1,2,3])` # error

To plot multiple curves simply call plt.plot with as many x-y list pairs as needed.

```python
x= np.arange(7)
data= np.random.randn(2,10)
plt.plot([data[0], data[1]])
```

Since this route will generate the random data, the output will be different every time execute that.

### Ex1: Test scores

Create a series of 10 elements, random integers from 70-100, representing score on a monthly exam. Set the index to be month names, starting Sep in June.

```python
np.random.seed(0)
months = 'Sep Oct Nov Dec Jan Feb Mar Apr May Jun'.split()
s = pd.Series(np.random.randint(70, 100, 10), index=months)
print(f'Year average: {s.mean()}')
firt_half_average = s['Sep':'Jan'].mean()
second_half_average = s['Feb':'Jun'].mean()
print(firt_half_average, second_half_average)
```

The `mean`allows us to describe the middle point in a data set -- we add up all of the values, and then divide by the number of values we had. In pandas syntax -- could say `s.mean()`is the same as `s.sum()/s.count()`. On many occasions, it is just useful.

Whether we ‘re using the mean or the median to find the central point in data set, will almost certainly what to know the std deviation -- a measurement of how much the values in our data set vary from one another. To calculate teh std deviation on series do the following -- like:

- Calculate the difference between each valeu in `s`and its mean.
- Square each of these
- sum the squares
- divide by number of s.

### Scaling test scores

In py, make constant use of built-in core data type `int float string list tuple list`-- Every series has a `dtype`can always read from that to know the type of data it contains. Unlike a Py list or tuple, cannot have different types mixed together in a series.

So can override these choices by passing a value to the `dtype`when create a series like:

`s= Series([10,20,30], dtype=np.float16)`

### Coutning 10s digits

```python
s=pd.Series(np.random.randint(0,100,10))
(s/10).astype(np.int8)
```

And there is another way to do this -- which involves some more type conversion -- this time, just convert our series into a float, but rather to a `string`.

`s.astype(str).str.get(0).astype(np.int8)`

The `get`works like square brackets on a traditional Py strings - So say `s.astype(str).str.get(0)`, get the first character in each integer -- -1 ofr get the final character in each string. If have a one-digit number, then what will get(-2) return then get back a series contiaing one-character strings like:

`s.astype(str).str.get(-2).fillna('0')` # namely, it wo’t give us an error but give a NaN -- like:

`s.astype(str).str.get(-2).fillna('0').astype(np.int8)`

Selecting values with booleans -- In py and other traditional PL, can select elements from a seq using a combination of `for`and `if`. can also use a series of booleans -- and those are easy to create, need to do is use a comparison operator which return a boolean value. Fore: `s[s<=s.mean()]`

### Descriptive statistics

The mean, median, and std deviation are 3 numbers can use to get a better picture of our data. But there are other numbers that we can use to fully understand it -- there are collectively known *descriptive statistics*.

```python
np.random.seed(0)
s = pd.Series(np.random.normal(0, 100, 100000))
print(s.describe())
s[s == s.min()] = 5*s.max()
print(s.describe())
```

`np.random.normal`-- stilling get random numbers, but they are picked from the normal distribution.

### Monday temperatures

It’s just common to assume that the index in a `pandas`series is unique -- after all, the index in a py string, list, or tuple is unique. But it truns out a series index can contain repeated values. this turns out to be quite useful in many ways.

```python
days = 'Sun Mon Tue Wed Thu Fri Sat'.split()
np.random.seed(0)
s= pd.Series(np.random.normal(20,5,28), 
             index=days*4).round().astype(np.int8)
s.loc['Mon'].mean()
```

For this, means that mean is 20 and standard deviation is 5 (namely, 95% of the values will be within 10 of 20, between 10 and 20, and 5% will be -10, and 30+)

One way would be to sue `astype(np.int8)`, and that would basically work but it would truncate the fracional part. Can call `round()`first, thus getting back floats without factional porition.

Fancy indexing -- Say, have a series of integers -- can use `s.loc[[2,4]]`

### Passenger Frequencey

Going to start here by reading from a file into a series -- This is possible with workhorse `pd.read_csv`method, which normally returns a data frame but can be coerced into returning a series from a file with the `squeeze`set to `True`-- note, that this only works if each line of file contains a single value.

`s= pd.read_csv('data/taxi-passenger-count.csv', squeeze=True, header=None)`
`s.value_counts(normalize=True)[[1,6]]`

Set the `header`to None, just indicating that the first line in the file should not be taken as a column name. But rather is data to be just included in our calculation.

There is a far easier way -- `value_counts()`method -- that is one of my favorites -- get back a new series whose keys are the distinct values in `s`, and whose values are integers indicating how often each value appeared. Cuz just get a series back from the `value_counts()`method - can use all of our series tricks on it. just like:

`s.value_counts()[[1,6]]`

But, actually, interested in the percentages not in the raw values, fore, have an optional `normalize`parameter, if set to True, returns the faction. `(s.value_counts(normalize=True)*100).sum()`

# Inheritance

Another key concept in understanding how styles are applied to element is *inheritance*. Is the mechanism by which some styles are applied not only to a specified element, but also its descendants.

### The cascade

CSS is just basedon a method of causing styles to *cascade* together, which is made possible by combining inheirtance and specificity with a few rules.

### The `all`property

```css
section {color: white; background: black; font-weight: bold;}
#example {all: inherit;}
```

```html
<section>
	<div id="example">
        This is a div.
    </div>
</section>
```

URLs-- 

```css
body{background: url(http://www.pix.web/picture.jpg);}
```

Fractions -- A fraction value is a number followed by the `fr`unit label.

In CSS 1em is defiend to be the value of `font-size`for a given font. ex unit refers to the height of a lowercase x in the font being used. Fore, if two p uses text that different heights for x, then have diffrent height.

`rem`is calcualted using the font size of the document’s root element -- `<html>`or `:root`-- note, in effect, `rem`acts as a reset for font size, no matter what relative font sizing has happended to the ancestors of an element. However, given this declaration -- `rem`will always be equivalent 3/4 of the user’s default font size:

`html{font-size:75%;}`

### Viewport-relative Units

CSS provides 6 viewport-relative size units -- There are calculated with respect to the szie of the viewport. 

- `vw`-- viewport’s width /100
- `vh`-- viewport’s height/100
- `vb`-- equal to size of viewport along the block axis, /100. note `vb`will be equal to `vh`by default.
- `vi`-- equal to the size of the viewport along the inline axis, /100. equal `vw`by default.

### Calcuation values

Fore, suppose you want your paragraphs to have that is 2em less then 90% the width like:

`p {width: calc(90%-2em)}`

`calc()`can be used with any prop that permits one of the following vlaue types.

Maximum -- fore: `.fiture{width: min(25vw, 200px)}`

## Basic Visual Formatting

At its core, CSS assumes that every element generates one or more rectangular boxes -- called **element boxes**. Each element has a *content area* at its center -- this is surrounded by optional amounts of padding, borders, outlines, and margins. Are considered optional cuz they could all be set to a size of 0.

inline base direction -- *inline axis* is the direction laong which lines of text are written.

Normal flow -- default system by which elements are placed inside the browser’s viewport.

Block box -- this is a box generated by an element such as a paragraph, heading, or `div` -- these boxes generates blank spaces both before and after their boxes. Pretty much any can be made to generate block box by declaring `display:block`.

Inline box -- such as `<strong> <span>`-- laid out along the inline base direction. `dispaly:inline`

### The containing block

For a given element, the containing block forms from the conetent edge of the nearest ancestor element that generates a list item or block box.

Logical Element Sizing -- Cuz CSS recognizes and inline axes for elements, it provides properties that let you set an explicit element size along each axis. min-content applied.

And the third keyword, fit-content -- is interesting that. -- what that means in practice is that if you have only a little content, the elements inline size will be just big enough to enclose it. as if `max-content`were used.

```css
#cb1 img {max-block-size: 2em;}
#cb2 img {max-block-size: 1em;}
```

The block-size CSS property defines the horizontal or vertical size of an element's block, depending on its writing mode. **It corresponds to either the width or the height property, depending on the value of writing-mode** .

```css
div {background: silver;
	width: 400px; height: 200px;
	padding: 25px;
	border: 5px solid gray;
	background: url(i/rulers.png);}
#two {box-sizing: border-box;}
```

And the `overflow:auto`allows user agent to determine which of the previously described behaviors to use.

And this brings the true nature of `overflow`- it’s a shorthand property that brings `overflow-x`and `overflow-y`together under one roof -- the following is extactly equivalent to the previous example and will have the same result.

```css
div.one {overflow: scroll hidden;}
div.two {overflow: scroll;}  /* scroll scroll */ 
```

### Negative Margins and Collapsing

An important aspect of block-axis formatting is the *collasping of adjacent margins*. Which is a way of comparing adjacent margins in the block direction, and then using only the largest of those margins to set the distence between the adjacent block elements.

And negative margin collapsing is different -- when a neg margin participates in margin collapsing, the browser takes the absolute value of negative margins and substract it from any adjacent positive margins.

For `border-box`just subtract the padding.
