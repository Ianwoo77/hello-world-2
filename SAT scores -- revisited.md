# SAT scores -- revisited

Were able to use data to gain some insight into a real-world issue -- need to load data from csv into df. like: For this for now didn’t assign any index-- while it’s often useful to set an index-- decided that the analysis going to do here will all use grouping -- while can still use `groupby`on a column you’v set to be the index, there is no added value there.

Also asked U to change the names of the columns from these long, unweildy names to sth a bit easier to type and read. Could have done by giving a value to the name parameter, but if give names to clumns, then need to use integers to indicate which columns should be imported from CSV. Then can change the column names like:

```python
df.columns=['Year', 'State.Code', 'Total.Math',
'income<20k',
'20k<income<40k',
'40k<income<60k',
'60k<income<80k',
'80k<income<100k',
'income>100k',
]
```

Now that data frame has the rows and columns that want, that the columns have easy-to-understand names. First, asked U to find the average SAT -- then sorted by year. like:

`df.groupby('Year').mean().sort_index()`

Note cuz we’re grouping by the `Year`column, it won’t be included in our output -- Cuz grouped by `Year`-- the index of the resulting data frame had an index of `Year`-- It so happens that cuz the data set some sored by `Year`that the results appear to be sorted.

Pandas privides with `pct_change`method -- when run it on data frame, get back a data frame with the same columns and indexes as the input data frames.

Fore, want to compare the scores by year and income brackets -- `pct_change`work on rows, not on columns and right now, our data frame has the brackets as columns, thus need to flip the data on its side, such that the years will be the columns and the income brackets will be the columns. -- ths solution is to use the `transpose`method, more easily abbreviated `T`-- which returns a new data frame in which the rows and columns have exchaned places.

```python
df.groupby('Year')[['income<20k',
'20k<income<40k',
'40k<income<60k',
'60k<income<80k',
'80k<income<100k',
'income>100k']].mean().T
```

### Fitlering and transforming

already seen how can use `groupby`to run aggregate methods on each portion of data, so that can get the averge rainfll per city or the total sales fitures per quarter.

Split and add Columsn individually -- Pandas `DataFrame`have a method called `.melt()`that will reshpe the dataframe into a tidy format and it takes a fe parameters -- 

- `id_vars`is a container that represents the variables that will remain as is
- `value_vars`identifies the columns you want to melt down, it will melt all the columns not specified in the id_vars.
- `var_name`-- is a string for the new column name when the `value_vars`is melted down `variable`by default
- `value_name`-- string for the new column name that represents the values for the `var_name`

`pew_long= pew.melt(*id_vars*='religion')`

Just note that the `.melt()`method also exists as pandas function, `pd.melt()` Can change the defaults so that the melted/unpivoted columns are named.

```python
pew_long= pew.melt(
    id_vars="religion", var_name='income', value_name='count'
)
```

### Keep multiple columns Fixed

Not every set will have one column to hold still while you unpivot the rest of the columns.

```python
billboard= pd.read_csv('billboard.csv')
billboard.iloc[0:5, 0:16]
```

Can be melted like:

```python
billboard_long= billboard.melt(
    id_vars='year artist track time date.entered'.split(),
    var_name='week', value_name='rating'
)
```

### Columns Contain multiple Variables

Sometimes columns in a data set may represent multiple variables -- this format is commonly seen when working with health data, forre, to illustrate this situation, look at the Ebola data set -- like:

```python
ebola = pd.read_csv('country_timeseries.csv')
ebola.columns
```

Print the fancy index like: `ebola.iloc[:5, [0, 1, 2, 10]]`

The column names and actually contain two varaibles, The individual status  like:

`ebola_long = ebola.melt(*id_vars*='Date Day'.split())`

Conceptually, the column of interest can be split based on the underscore in the column name -- the first part will be the new status column, and the second part will be the new coountry column.

### Split and Add columns individually

Can use the `.str`accessor to make a call to the `.split()`method and apss in the underscore like:

`variable_split= ebola_long.variable.str.split('_')`

and this will be an array column, can just split on the underscore, the values are returned in a list. And, note, now that the column has been split into various pieces -- the next step is to assign those pieces to a new column, first, need to extract all the 0-index elements for the *status* column like:

`status_values= variable_split.str.get(0)`

Single step - Can acually do the above in a single step -- just:

```python
variable_split= ebola_long.variable.str.split('_', expand=True)
ebola_long[['status', 'country']]=variable_split
```

### Variables in both Rows and Columns

What is left to show is what happens if a column of data actually holds two variables insted of one variable, in this case, will have to pivot the varaiable into separate columns, like:

```python
weather= pd.read_csv('weather.csv')
weather.iloc[:5, :11]
```

For the weather data include minimum and maximum temperatures recorded for each day of the month. can melt this like:

```python
weather_melt = weather.melt(
    id_vars= 'id year month element'.split(),
    var_name='day',value_name='temp'
)
weather_tidy= weather_melt.pivot_table(
    index='id year month day'.split(),
    columns='element',
    values='temp'
)
```

And looking at the pivot table, notice that each value in the `element`column is now a separate column, can leave this table in its current state, can also flatten the hierarchical columns.

```python
weather_tidy_flat = weather_tidy.reset_index()
weather_tidy_flat
```

Likewise, can apply these mehods without intermediate datarame like:

```python
weather_tidy=(
    weather_melt.pivot_table(
        index='id year month day'.split(),
        columns='element',
        values='temp'
    ).reset_index()
)
```

### Apply Functions

Learning about the `.apply()`is fundamental in the data cleaning process -- it also encapsulates key concepts in programming, mainly writing functions.

Apply over Series -- subset  a single column or row using a single pair of square -- the `type()`of the object get back in pandas `Series`.

`df['a'].apply(lambda x : x**2)`

Can built on this example by writing a function that takes two parameters -- like:

```python
def my_exp(x, e):
    return x**e

import functools
my_exp= functools.partial(my_exp, e=3)
df.a.apply(my_exp)
```

### Applying over a DataFrame

See hwo the syntx changes when we are working with DF -- there is the example `DF`like: So for the DF, typically hve at least two dimensions, thus, when apply a function over a dataframe, first need to specify which axis to apply the function over-for exmaple, column-by-column or row-by-row.

Column-wise Operations -- use the `axis=0`parameter in `.apply()`when working with functions in a column-wise manner like: `df.apply(lambda s: print(s), axis=0)`-- when apply a function across a df, then entire axis is passed into the first argument of the function -- to illustrate this further, write a function.

`df.apply(lambda s: s.mean(), axis=1)`

### Row-Wise operations

Row-wise operations work just like column-wise opreations -- the part that differs is the axis. axis=1, and axis=0.

Vectorized Functions -- When use the `.apply()`, are able to make function work on a column-by-column or row-by-row basis -- had to rewrite our function when wanted to apply it cuz the entire column or row -- however, there might be times when it is not feasilbe to rewirte the fun in this way, can leverage the `.vectorize()`and decorator to vectorize any function. like:

`avg_2(df.a, df.b)`this approach works cuz the actual calculations within our function are inherently vectorized. If add two numeric columns together, pandas - and Numpy just will automatically perform element-wise addition. Fore, change the function and perform a non-vectorizable calculation -- like:

```python
def avg_2_mod(x, y):
    if x==20:
        return np.NaN
    else:
        return (x+y)/2
avg_2_mod(df.a, df.b) # ValueError raised
```

So want to change our func so that when it is given a vector of values, will perform the calcuations in an elem-wise manner, can do this by using the `vectorize()`to do this.

```python
avg_2_mod_vec= np.vectorize(avg_2_mod)
avg_2_mod_vec(df.a, df.b)
```

This works well if do not have the source code for an existing function - however, if you are writing your own func, can use a Py decorator to automatically vectorize the function without having to create a new function.

```python
@np.vectorize
def avg_2_mod(x, y):
    if x==20:
        return np.NaN
    else:
        return (x+y)/2
```

## Understanding How Go Executes Code

The key building block for executing Go program is the *goroutine* -- which is a lightweight thread created by the Go runtime -- All go program use at least one goroutine cuz this is how Go executes the code the `main`. When compilied Go code is executed, the runtime creates a goroutine that starts executing the statements in the entry.

The *goroutine* executes each statement in the main *sync* -- which means that it waits for the statement to complete before moving on to the next statement. the statement in the `main`can call other functions, uses the `for`loops, 

### Creating Additional Goroutines

Go allows the developer to create additional goroutines, which execute code at the same time as the `main`goroutine. Go makes it easy to create new gorotuiens -- like:

`go group.TotalPrice(category)`

This statement tells the runtime to execute the statement in the `TotalPrice`method using a new goroutine. The runtime doesn’t wait for the goroutine to execute the method and immediately moves onto the next statement. This is the entire point of goroutines cuz the `TotalPrice`will be invoked async.

### Returning Results from Goroutines

When created goroutine, changed the way the `TotalPrice()`was called, originally, the code looked like:

`storeTotal += group.TotalPrice(category)`

To address this issue, Go provides *channels* -- which are conduits through which data can be sent and received.

`var channel chan float64 = make(chan float64)`

And Channels are strongly typed, which means that they will carray values for a specified type or interface.

### Sending a Result using a Channel

Update the `TotalPrice`so that it sends its result through the channel like:

```go
func (group ProductGroup) TotalPrice(category string, 
	resultChannel chan float64) {
	var total float64
	for _, p := range group {
		fmt.Println(category, "product:", p.Name)
		total += p.Price
	}
	fmt.Println(category, "subtotal:", ToCurrency(total))
	resultChannel <- total	
}
```

Just sends the `total`value through the `resultChannel`channel, which makes it avaiable to the received elsewhere in the application.

Receiving the result -- 

```go
func CalcStoreTotal(data ProductData) {
	var storeTotal float64
	var channel chan float64 = make(chan float64)
	for category, group := range data {
		go group.TotalPrice(category, channel)
	}
	for i := 0; i < len(data); i++ {
		storeTotal += <-channel
	}
	fmt.Println("Total:", ToCurrency(storeTotal))
}
```

### working with Channels

The previous section demonstrated the basic use of channels-- 

Coordinating channels -- By default, sending and receiving through a channel are blocking operations -- this means that a goroutine that sends a value will not execute any further statements until another goroutine receives the value from the channel. And if a second goroutine sends a value, will be lbocked until the channel is cleared. 

### Using a Buffered Channel

The default channel behavior can lead to bursts of activity as goroutines do their work -- followed by a long idle period waiting for messages to be received -- this doesn’t have an impact on the example application cuz the goroutines finish once their messages are received.

Buffered makes sending a message a nonblocking op -- allowing a sender to pass its value to the channel and continue working without having to wait for a receiver.

`var channel chan float64 = make(chan float64, 2)`

channle has `len`and `cap`

### Sending and receiving an Unknown Number of values

```go
type DispatchNotification struct {
	Customer string
	*Product
	Quantity int
}

var Customers = []string{"Alice", "Bob", "Charlie", "Dora"}

func DispatchOrders(channel chan DispatchNotification) {
	rand.Seed(time.Now().UTC().UnixNano())
	orderCount := rand.Intn(3) + 2
	fmt.Println("Order cont:", orderCount)
	for i := 0; i < orderCount; i++ {
		channel <- DispatchNotification{
			Customers[rand.Intn(len(Customers)-1)],
			ProductList[rand.Intn(len(ProductList)-1)],
			rand.Intn(10),
		}
	}
}

```

For this, there is no way to know in advance how many `DispatchNotification`values the `DispatchOrders`function will create. -- can:

```go
func main() {   // deadlock
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)
	for {
		details := <-dispatchChannel
		fmt.Println("dispatch to", details.Customer, ":", details.Quantity,
			"x", details.Product.Name)
	}
}

```

For this the `for loop`doesn’t work cuz the receiving code will try to get values from the channel after the sender has stopped producing them. The Go runtime will terminate the program if all the groutine are blocked.

### Closing a Channel

The solution for this problem for the sender to indicate when no further values are coming through the channel -- which is done by **closing** the channel. Just at the last of the `DispatchOrders`: `close(channel)`

```go
func main() { 
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)
	for {
		if details, open := <-dispatchChannel; open {
			fmt.Println("dispatch to", details.Customer, ":", details.Quantity,
				"x", details.Product.Name)
		} else {
			fmt.Println("Channel has been closed")
			break
		}
	}
}
```

Just note that the receive operator can be used to obtain two values -- the first is assigned the value received from the channel, and the second value indicates whether the channel is closed, and if the channel is open, then the closed indicator will be `false`.

### Enumerating Channel Values

A `for`can be used with `range`to enumerate the values sent through a channel -- allowing the values to be received more easily and terminating the loop when the channel is closed.

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)
	for details := range dispatchChannel {
		fmt.Println("Dispatch to ", details.Customer, ":", details.Quantity,
			"X", details.Product.Name)
	}
	fmt.Println("Channel has been closed")
}
```

And the `range`expression produces one value per iteration, which is the value received from the channel. The `for`will continue to receive values until the channel is just closed.

### Restricting Channel Direction 

By default, channels can be used to send and receive data, but this can be restricted when using channels as arguments, such that only send or receive operations can be performed -- find this feature useful to avoid mistakes where I intended to send a message but performed a receive instead cuz the syntax for these operations is similar.

So the output reports that 4 values will be just sent through the channel -- but only 3 are received. So, this problem will be resolved by using the direction of channel like:

`func DispatchOrders(channel chan<- DispatchNotification) {`

The direction of the channel is specified alongside the `chan`keyword like upper.

### Restricting Channel Argument Direction

The changes in the previous section allow the `DispatchOrders`function to declare that it nees to only send messages through the channel and not receive them. This is useful -- Directional channels are also types so that the type of the function parameter is `chan<-`allows bidirectional channels to be assigned to unidirectional channel variables.

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)

	var sendOnlyChannel chan<- DispatchNotification = dispatchChannel
	var receiveOnlyChannel <-chan DispatchNotification = dispatchChannel
	go DispatchOrders(sendOnlyChannel)
	receiveDispatches(receiveOnlyChannel)
}

func receiveDispatches(channel <-chan DispatchNotification) {
	for details := range channel {
		fmt.Println("Dispatch to ", details.Customer, ":", details.Quantity,
			"X", details.Product.Name)
	}
	fmt.Println("channel has been closed")
}

```

Restriction on channel direction can also be created through explicit conversion, like:

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)

	go DispatchOrders(dispatchChannel)
	receiveDispatches(dispatchChannel)
}
```

### Using `select`statements

And the `select`used to group operations that will send or receive from channels, which allows for complex arrangements of groutines and channels to be created, there are several uses for `select`statements, so start wtih the basics with the basics and work trhough the more advanced options.

### Receiving without Blocking

The simplest use for `select`statement is to receive from a channel without blocking, just ensuring a goroutine won’t have to wait when the channel is empty.

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)

	go DispatchOrders(dispatchChannel)
	for {
		select {
		case details, ok := <-dispatchChannel:
			if ok {
				fmt.Println("Dispatch to", details.Customer, ":",
					details.Quantity, "X", details.Product.Name)
			} else {
				fmt.Println("Channel has been closed")
				goto alldone
			}
		default:
			fmt.Println("-- no message ready to be received")
			time.Sleep(time.Millisecond * 600)
		}
	}
alldone:
	fmt.Println("All values received")
}
```

Note that the `select`evaluates its `case`statements once, which is why have also used a `for`loop the loop continue to execute the `select`statement, which will receive values from the channel when they become avaiable. The `case`statement channel operation checks to see whether the channel has been closed and if it has, uses the `goto`.

### Receiving from multple channels

A `select`statement can be used to receive without blocking, as the preivous -- become more useufl when there are multiple channels -- through which values are sent at different rates. A `select`statement will allow the receiver to obtain values from whichever channel has them.

```go
func main() {
	dispatchChannel := make(chan DispatchNotification, 100)
	go DispatchOrders(dispatchChannel)

	productChannel := make(chan *Product)
	go enumerateProducts(productChannel)
	openChannels := 2
	for {
		select {
		case details, ok := <-dispatchChannel:
			if ok {
				fmt.Println("Dispatch to", details.Customer, ":",
					details.Quantity, "X", details.Product.Name)
			} else {
				fmt.Println("Channel has been closed")
				dispatchChannel = nil
				openChannels--
			}
		case product, ok := <-productChannel:
			if ok {
				fmt.Println("Product:", product.Name)
			} else {
				fmt.Println("Product channel has been closed")
				productChannel = nil
				openChannels--
			}
		default:
			if openChannels == 0 {
				goto alldone
			}
			fmt.Println("-- no message ready to be received")
			time.Sleep(time.Millisecond * 600)
		}
	}
alldone:
	fmt.Println("All values received")
}

func enumerateProducts(channel chan<- *Product) {
	for _, p := range ProductList[:3] {
		channel <- p
		time.Sleep(time.Millisecond * 800)
	}
	close(channel)
}
```

In this, the `select`statement is used to receive values from two channels, one that carries `DispatchNotification`values and one that carries `Product`values. Care must be taken to manage closed channels, cuz they will provide a `nil`value for every receive operation that occurs after the channel has been closed.

And managing closed channels requires two measures, the first is to prevent the `select`statement from choosing a channel once it is closed, this can be done by assigning `nil`to the channel variable.

`dispatchChannel=nil`

A `nil`channel is never ready and will not be chosen -- allowing the `select`to move onto other case statement note that. And the second measure is to break out of the `for`when all the channels are closed.

### Sending without blocking

A `select`can also be used to send a channel without blocking, like:

```go
func enumerateProducts(channel chan<- *Product) {
	for _, p := range ProductList {
		select {
		case channel <- p:
			fmt.Println("Sent product:", p.Name)
		default:
			fmt.Println("Discarding product:", p.Name)
			time.Sleep(time.Second)
		}
	}
	close(channel)
}

func main() {
	productChannel := make(chan *Product, 5)
	go enumerateProducts(productChannel)

	time.Sleep(time.Second)

	for p := range productChannel {
		fmt.Println("Received product:", p.Name)
	}
}
```

For this, created with a small buffer, and values are not received from the channel until after a small delay. This means that the `enumerateProducts`can send values through the channel without blocking until the buffer is full.

### Sending to Multiple Channels

If there are mutliple channels available, a `select`can be used to find a channel for which sending will not work.

```go
func enumerateProducts(channel1, channel2 chan<- *Product) {
	for _, p := range ProductList {
		select {
		case channel1 <- p:
			fmt.Println("sending via channel 1")
		case channel2 <- p:
			fmt.Println("Sending via channel 2")
		}
	}
	close(channel1)
	close(channel2)
}

func main() {
	c1 := make(chan *Product, 2)
	c2 := make(chan *Product, 2)
	go enumerateProducts(c1, c2)
	time.Sleep(time.Second)
	for p := range c1 {
		fmt.Println("Channel1 received product", p.Name)
	}
	for p := range c2 {
		fmt.Println("Channel 2 received product:", p.Name)
	}
}
```

This example has two channels, with just small buffers, as with receiving, the `select`statement builds a list of othe channels through which a value can be sent without blocking and then picks one at random fromt that list.

The chunks of our program may *appear* to be running in parallel, but really they are executing in a sequential manner faster than is distinguishable.

### Go’s concurrency building Blocks

Goroutines are one of the most basic units of organization in a Go program, -- it’s important understand what they are and how they wrok -- every Go program has at least one goroutien -- which is automatically created and started when the process begins. Goroutines are unique to Go, -- are not OS thread, and are not exactly green -- they are just a higher level of abstraction known as *cororutine*. Actually, Coroutines are simply concurrent subroutines -- that are nonpreemptive -- that cannot be interrupted.

Goroutines don’t define their own suspension or re-entry points. Go’s runtime observes the runtime behavior of goroutines and automatically suspends them when they block and then resumes them when become unblocked. In a way this makes them preemptble -- but only at points where the goroutine has become blocked. CGoroutines -- are implicitly concurrent -- but concurrency is not a property *of* a coroutine.

And, Go’s mechanism for hosting goroutines is an implementation of what’s called an M:N scheduler. And note that Go follows a model of concurrency called the *fork-join* model -- for the *fork* -- refers to the fact at any point in the program, it can split off a *child* branch of execution to be run concurrently with its *parents*. The goroutine will be created and scheudled with Go’s runtime to execute, but it may not actually get a chance to run befreo the main goroutine exits.

In this, in order to create a jion point, synchronize the main and the `sayHello()`goroutine like:

```go
func main() {
	var wg sync.WaitGroup
	sayHello := func() {
		defer wg.Done()
		fmt.Println("Hello")
	}
	wg.Add(1)
	go sayHello()
	wg.Wait()
}
```

This just will deterministically block the main until the goroutine hosting the `sayHello`terminates.

```go
var wg sync.WaitGroup
salutation := "hello"
wg.Add(1)
go func() {
    defer wg.Done()
    salutation = "welcome"
}()
wg.Wait()
fmt.Println(salutation)
```

It turns out that goroutines execute within the same address space they were created in, and so program prints out the word -- 

```go
func main() {
	var wg sync.WaitGroup
	for _, sal := range []string{"hello", "greeting", "Good day"} {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Println(sal)  // all good day
		}()
	}
	wg.Wait()
}
```

Cuz the goroutines being scheduled may run at any point in time in the future, it is underminded what values will be pointed from within the goroutine. So, for this, here is a high probability the loop will exit before the goroutine are begun. So just add: changed to:

```go
go func(sal string) {
    defer wg.Done()
    fmt.Println(sal) // all good day
}(sal)
```

