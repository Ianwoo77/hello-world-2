# Vectorized Functions

When use `.apply()`, are able to make a function work on a column or row basis. Fore, had to write our function when wanted to apply it cuz the entire column or row was passed into th first parmeter of the function. However, there might be bimes when it is not feasible to rewirte a function in this way, can leverge the `.vectorize()`function and dectorator to vectorize any function.

```python
df = pd.DataFrame({'a': [10, 20, 30], 'b': [20, 30, 40]})
def avg_2(x, y):
    return (x+y)/2
```

`avg_2(df.a, df.b)` -- thie works cuz the actual calculations within our function are inherently vectorized -- that is if add two numeric columns together, Pandas will automatically perform element-wise addition. but if have:

```python
def avg_2_mod(x, y):
    if x==20:
        return np.NAN
    else:
        return (x+y)/2
```

if use this, will cause an error. 

### Vectorize with Numpy

want to change our function so that when it is given a vector of values, it will perform the calculcations in an element-wise manner, can do this by using the `vectorize()`function from numpy, pass `np.vectorize()`to the function we want to vectorize, to create a new func like:

```python
avg_2_mod_vec = np.vectorize(avg_2_mod)
avg_2_mod_vec(df.a, df.b)
```

This method works well if do not have the source code for an existing function. If U are writing your own function , can use a Python decorator to just automatically vectorize the function without having to create a new function. A dectorator is a function that takes another function as input -- like:

```python
@np.vectorize
def v_avg_2_mod(x,y):
    if x==20:
        return np.NAN
    else:
        return (x+y)/2
```

### Vectorize with Numba

The `numba`is designed to optimize Py code, especially calculations on arrays performing mathmatical calculations just like `numpy`, it also has a `vectorize`decorator.

```python
import numba
@numba.vectorize
def v_avg2_v(x,y):
    if int(x)==20:
        return np.NaN
    else:
        return (x+y)/2
```

Actually have to pass in the `numpy`array representation of our data using the `.values`attribute like:

`v_avg2_v(df.a.values, df.b.values)`

### Data Assembly

Focuses on various data cleaning tasks -- begin with assembling a data set for analysis by combining various data sets together -- 

- Identify when needs to be combined
- whether data needs to be concatenated or joined together
- Use the appropriate function or methods to combine multiple data sets
- Produces a single data set from multiple fiels
- Acccess whether data was joined properly

### Concatenation

One of the eaiser to combine data is with concatenation -- can be thought of as appending a row or column to your data. This approach is possible if your data was split into parts of if you perfomed a calculation that you want to append to your existing data set.

`row_concat= pd.concat([df1, df2, df3])`

Blindly stacks the df together -- fore:

```python
new_row_series = pd.Sereis(['n1', 'n2', 'n3', 'n4'])
pd.concat([df1, new_row_series])
```

For this there are `NAN`missing values, this is simply Py’s way of representing a missing value -- hoping to append our new values as a row. Think what is happening here -- series did not have matching column. To fix, need turn the series into a dataframe -- contains one row of data, and the column names are the ones the data will bind to like:

```python
new_row_df= pd.DataFrame(
	['n1 n2 n3 n4'.split()], columns= [*'ABCD']
)
import glob
total = []
for file in glob.glob('concat_*.csv'):
    total.append(pd.read_csv(file))
row_concat= pd.concat(total)
pd.concat([row_concat, new_row_df])
```

### Ignore the Index

In the last example, when added a `dict`to a df, had to use the `ignore_index`parameter. If we look closer, you can see that the row index was also incremented by 1. If simply want to concatenate or append data, can just use the `ignore_index`parameter to reset the row index after the concatenation.

`ow_concat= pd.concat(total, ignore_index=True)`

Simply want to concatnate or append data togheter.

### Adding Columns

Concatenating column is similar to concatnating rows -- main is the `axis`parameter in the `concat`-- note that the default value of `axis`is 0, so it will concatenate data in a rwo-wise fashion. The default value of axis.. like:

`col_concat = pd.concat(total, axis=1, ignore_index=True)`

And if try to subset data based on column names, you will get a similar result when we concatnated row-wise and subset by row index -- like: `col_concat.A`

Adding a single column to dataframe can be done directly without using any specific Pandas function. Simply pass a new column name for the vector you want to assigning to the new column.

`col_concat['new_col_list']='n1 n2 n3 n4'.split()`

Or use series. Finally, can reset the column indices so we do not have duplicated column names.

### Concatenate with different indices

The examples shown `df1.columns=[*'ABCD']`

If try to concatenate these dataframe, the df now do much more than the simply stack one on top of the other. Now it will be all result columns appeared. -- One way to avoid the inclusion of `NaN`values is to keep only those columns that are shared in common by the list of objects be concatenated. For this situation, parameter `join`accomplishes this. Note that by default, it has a value of `outer`-- meaning it will keep all the columns.

```python
for file in glob.glob('concat_*.csv'):
    df = pd.read_csv(file)
    df.columns=columns[n]
    print(df)
    n+=1
    total.append(df)
row_concat= pd.concat(total)
```

if: `row_concat= pd.concat(total, join='inner')`

if use the dataframes that have columns in common, only the columns that all of them share will be returend like:

`pd.concat([df1, df3], ignore_index=False, join='inner')`

### Concatnate Columns with different Rows

```python
df1.index=range(4)
df2.index=range(4, 8)
df3.index= [0,2,5,7]
```

So, when concatenate along `axis='columns'`, the new dataframes will be added in a column-wise fashion and matched against their respective row indices, missing values indicators appear in the areas where.

Just as did when concatenated in a row-wise manner, can choose to keep the results only when there are matching indices by using `join='inner'` like:

`pd.concat([df1, df3], axis=1, join='inner')`

### Observational Units Acorss Multiple Tables

This focus on techniques for quickly loading multiple data sources and assembling them together. In this: For, Can use the a pattern matching function from the built-in `pathlib`module in py to get a list of all the filenames that matches a particular pattern like:

```python
from pathlib import Path
billboard_data_fiels = (
	Path('.').glob('data/billboard-*.csv')
)
```

for the `type()`of `billboard_data_files`is a generator. so `list()`it.

### Loading multiple files uing ListComp

just like:

```python
billboard_dfs= [pd.read_csv(data) for data in billboard_data_files]
```

### Merge Multiple DataSets

The previous allueded to a few databse concepts -- fore, the `join='inner'`and the default `join='outer'`parameters come from working with dbs when we want to merge tables. And instead of simply having a row or column index that you want to use to concatenate values, sometimes may have two or more DFs that you want to combine bsed on common data values, this task is `join`. Pandas has a `.join()`that uses `.merge()`under the hood. -- `join`will merge df objects bsed on the dinex -- but the `merge`actually more explicit and flexible.

Our data is split into multiple parts, where each part is an observational unit. For these, if wanted to look at the dataset at each site along with the latitude and longitude info for that site, we would have to combine multiple dataframes. Can do this using the `.merge()`method in pandas. like:

When calling the method, the dataframe that is called will be referred to as the one on the`left`, within the `merge`, the fist parameter is the `right`df -- `left.merge(right)`-- the `how`the final merged result looks.

### One-to-One

In its simplest type of merge, have two dfs where we want to join one column to another column -- and where the columns we want to join do not contain any duplicate values. Can perform like:

```python
o2o_merge = site.merge(
    visited_subset, left_on='name', right_on='site'
)
```

Can see, have now created a new dataframe from two separate dfs where the rows were matched based on a particular set of columns, the columns used to match are called `keys`.

## Error Handling

This describes the way that the Go deals errors, describe the interface that represents errors, how to create, and explain the different ways they can be handled. Panicking, which is how unrecoverable errors are handled.

- Allows exceptional conditions and failures to be respresented and dealt with
- Provides a way to respond to those situations, when arise
- The `error`**interface** is used to define error conditions, which are typically returned as function results. the `panic`function is called when an unrecoverable error occurs.
- Care mut be taken to ensure the errors are commnuicated to the part of the app that can best decide how serious.

```go
func main() {
	categories := []string{"Watersports", "Chess"}

	for _, cat := range categories {
		total := Products.TotalPrice(cat)
		fmt.Println(cat, "Total:", ToCurrency(total))
	}
}
```

### Dealing with Recoverable errors

Go makes it easy to express exceptional conditions, which allows a function or method to indicate to the calling code that sth has gone wrong -- as an example, adds statements that produce a problematic response from the `TotlPrice`method -- like: fore:

`categories:= []string {"Watersports", "Chess", "Running"}`

The response from the `TotalPrice`method for the `Running`category is ambiguous, a zero result could mean that there are no products in the specified category, or it could mean that there are products but have a sum value of zero - the code that calls the `TotalPrice`method has no way of knowning what the zero value just represents.

In a simple -- easy to understand the result from its context -- there are no products in the `Running`category, and in a real, this sort of result can be more difficult to understand and respond to. Go just provides a predefined interface named `error`that provides one way to resolve this issue -- like:

```go
type error interface {
    Error() string
}
```

The interface requires errors to define a method named `Error`-- which returns a string.

### Generating Errors

Functions and methods can express exceptional or unexpected outcomes by producing error response like:

```go
func (slice ProductSlice) TotalPrice(category string) (total float64,
	err *CategoryError) {
	productCount := 0
	for _, p := range slice {
		if p.Category == category {
			total += p.Price
			productCount++
		}
	}
	if productCount == 0 {
		err = &CategoryError{requestedCategory: category}
	}
	return
}

type CategoryError struct {
	requestedCategory string
}

func (e *CategoryError) Error() string {
	return "Category " + e.requestedCategory + " does not exist"
}

```

So the `CategoryErro`type defines an unexported `requestCategory`field -- and there is a method that conforms to the `error`interface, the signature of the `TotalPrice`method has been updated so that it returns two results -- the original `float64`and an error. If there is no products with the speicified category, the `error`result is assigned a `CategoryError`value -- like:

```go
func main() {
	categories := []string{"Watersports", "Chess", "Running"}

	for _, cat := range categories {
		total, err := Products.TotalPrice(cat)
		if err == nil {
			fmt.Println(cat, "Total:", ToCurrency(total))
		} else {
			fmt.Println(cat, "(no such category)")
		}
	}
}
```

So the outcome from invoking the `TotalPrice`method is determined by examing the combination of the two results.

### Reporting errors via channell

If a function is being executed using a goroutine, then the only communication is through the channel, which means that details of any problems must be communicated alongside successufl operations. It is important to keep the error handling as simple as possible. Preferred approach is to create a custom type that consolidates both outomes, like:

```go
type ChannelMessage struct {
	Category string
	Total    float64
	*CategoryError
}

func (slice ProductSlice) TotalPriceAsync(categories []string,
	channel chan<- ChannelMessage) {
	for _, c := range categories {
		total, err := slice.TotalPrice(c)
		channel <- ChannelMessage{
			c, total, err,
		}
	}
	close(channel)
}

```

So the `ChannelMessage`type allows to communicate the pair of results required to accurately reflect the outcome from the `TotalPrice`-- which is executed async by the new `TotalPriceAsync`-- The result is similar to the way that sync resuts can express errors.

And, if there is only one sender for a channel, can close the channel after an errors has occurred.

```go
func main() {
	categories := []string{"Watersports", "Chess", "Running"}

	channel := make(chan ChannelMessage, 10)
	go Products.TotalPriceAsync(categories, channel)

	for message := range channel {
		if message.CategoryError == nil {
			fmt.Println(message.Category, "Total:", ToCurrency(message.Total))
		} else {
			fmt.Println(message.Category, "(no such category)")
		}
	}
}
```

### Using the Error convenience Functions

If can be awkward to have to define data types for every type of error that an application can encounter. The `errors`package, which is part of the STDLIB, just provides a `New`that returns an `error`whose content is `string`. the drawback of this approach is that it creates simple errors -- but it has the advantage of simplicity.

```go
func (slice ProductSlice) TotalPrice(category string) (total float64,
	err error) {
	// ...
	}
	if productCount == 0 {
		err = errors.New("cannot find category")
	}
	return
}

type ChannelMessage struct {
	Category      string
	Total         float64
	CategoryError error
}
```

Although have been able to remvoe the custom error type in this example, the error that is produced no longer contains details of the category was requested.

```go
if productCount == 0 {
    err = fmt.Errorf("cannot find category : %v", category)
}
```

For this, the `%v`in the to the `Errorf`function is an example of a formatting verb, its replaced with the next argument.

### Dealing with Unrecoverable Errors

Some errors are so serious, should lead to the immediate termination of the application, a process knowing as *panicking* -- like: `panic(message.CategoryError)`

Insted of printing out a message when a category cannot be found, the main function just panics -- which is done using the built-in `panic`-- is invoked with an arg, which can be any valsue that will help explain the panic.

### Recovering from Panics

Go provides the built-in function `recover`which can be called to stop a panic from working its way up the call stack and terminating the program -- the `recover`function must be called in code that is executed using the `defer`like:

```go
recoverFunc := func() {
    if arg := recover(); arg != nil {
        if err, ok := arg.(error); ok {
            fmt.Println("Error:", err.Error())
        } else if str, ok := arg.(string); ok {
            fmt.Println("Message:", str)
        } else {
            fmt.Println("Panic recovered")
        }
    }
}

defer recoverFunc()
```

This uses the `defer`to register a function, which will be executed when the `main`has completed, even if there has been no panic - Calling the `recover`function returns a value if there has been a panic, halting the progression of the panic and providing access to the argument used to invoke the `panic`. And the ytpe of the value returned by the `recover`is the empty interface -- `interface{}`-- which requires a type assertion before it can be used. -- deals with `error`and `string`are the two most common types of panic argument.

Notice that the use of the parntheses following the closing brace anonymous function.

### Panicking after a recovery

May recover from a panic only to realize that the situation is not recoverable after all. When this happens, can start a new panic, either providing a new arg or reusing the value received when the `recover`function was called.

```go
// ...
fmt.Println("Error:", err.Error()) // so, panic for error
panic(err)
```

### recovering from panics in Go Routines

A panic wirks its way up the stack only to the top of currernt goroutine, at which point it causes termination of the application. this restriction means that panics must be receovered within the code that a goroutine executes.

```go
func processCategories(categories []string, outChan chan<- CategoryCountMessage) {
	defer func() {
		if arg := recover(); arg != nil {
			fmt.Println(arg)
		}
	}()
	channel := make(chan ChannelMessage, 10)
	go Products.TotalPriceAsync(categories, channel)
	for message := range channel {
		if message.CategoryError == nil {
			outChan <- CategoryCountMessage{
				message.Category,
				int(message.Total),
			}
		} else {
			panic(message.CategoryError)
		}
	}
	close(outChan)
}

func main() {
	categories := []string{"Watersports", "Chess", "Running"}
	channel := make(chan CategoryCountMessage)
	go processCategories(categories, channel)
	for message := range channel {
		fmt.Println(message.Category, "Total:", message.Count)
	}
}
```

For this, the `main`uses a goroutine to invoke the `processCategiroes`function -- which panics if the `TotalPriceAsync`sends an error -- and the `processCategories`recovers from the panic -- but the problem is that recovering from a panic doesn’t **resume** execution of the `processCategories`func, -- the `close()`function is never called on the channel from which the `main`is receiving messages. The `main`tries to receive a message that will never be sent and blocks on the channel, triggering the Go runtime’s deadlock detection.

And the simplest approach is to call the `close`on the channel during the recovery, like:

```go
defer func() {
    if arg := recover(); arg != nil {
        fmt.Println(arg)
        close(outChan)
    }
}()
```

This just prevents the deadlock -- but it does so without indicating to the `main`that the `processCategories`was unable to complete its work. And so, a better approach is to indicate this outcome through the channel before closing it. like:

```go
defer func() {
    if arg := recover(); arg != nil {
        fmt.Println(arg)
        outChan <- CategoryCountMessage{TerminalError: arg}
        close(outChan)
    }
}()
```

The result is that the decision about how to handle the panic is passed from the goroutine to the calling code, which can elect to contiinue execution or tirgger a new panic.

Note that the goroutines operate within the same address space as each other, and simply host functions, utlizing goroutines is a natural extension to writing non-concurrent code. Go’s compiler nicely takes acare of pinning variables in memory so that goroutines don’t accidentally acces freed memory.

In the following example, just combine the fact that goroutines are not garbage collected -- The garbage collctor does nothing to collect goroutines that have beenabandoned somehow.

## The `sync`package

The `sync`contains the concurrency primitives that are most useful for low-level memory access synchronization -- Note that the difference between other languages in Go is that Go has built a new set of concurrency primitives on top of the memory access sync to provide U with an expanded set of things to work with.

### WaitGroup

is a great way to wait for a set of concurrent operations to complete when you either don’t care about the result of the concurrent operation, or have other means of collecting their results.

```go
func main() {
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("1st goroutine sleeping..")
		time.Sleep(1)
	}()

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("2nd sleeping...")
		time.Sleep(2)
	}()

	wg.Wait()
	fmt.Println("All complete")
}
```

Just think of a `WaitGroup`is like a concurrent-safe counter -- calls to `Add`increment the counter by the integer passed in, and calls the `Done`just **decrement** the counter by one. Calls to `Wait`block until the counter is zero.

Notice that the calls to `Add`are deone outside the goroutines they are helping to track. If didn’t do this, would have introduced a race condition.  Sometimes find `Add`called to track a group of goroutines all at once.

```go
func main() {
	hello := func(wg *sync.WaitGroup, id int) {
		defer wg.Done()
		fmt.Printf("Hello from %v!\n", id)
	}
	const numGreeters = 5
	var wg sync.WaitGroup
	wg.Add(numGreeters)
	for i := 0; i < numGreeters; i++ {
		go hello(&wg, i+1)
	}
	wg.Wait()
}
```

### Mutex and RWMutex

Just stands for *mutual exclusion* -- and is just a way to guard critiaal sections of your prog. A `Mutex`provides a concurrent-safe way to express exclusive access to these shared resource.

```go
func main() {
	var count int
	var lock sync.Mutex

	increment := func() {
		lock.Lock()
		defer lock.Unlock()
		count++
		fmt.Printf("Incrementing: %d\n", count)
	}

	decrement := func() {
		lock.Lock()
		defer lock.Unlock()
		count--
		fmt.Printf("Decrementing : %d\n", count)
	}

	var arithmetic sync.WaitGroup
	for i := 0; i <= 5; i++ {
		arithmetic.Add(1)
		go func() {
			defer arithmetic.Done()
			increment()
		}()
	}

	for i := 0; i <= 5; i++ {
		arithmetic.Add(1)
		go func() {
			defer arithmetic.Done()
			decrement()
		}()
	}
	arithmetic.Wait()
	fmt.Println("Arithmetic complete.")
}
```

Noticed that we always call `Unlock()`within a `defer`statement -- this is a very common idiom when utilizing a `Mutex`to ensure the call always happens.

Cirtical sections are so named cuz they can reflect a bottleneck in program. It is just somewhat expensive to enter and exit a critical section.

And one strategy for doing so is to reduce the cross-section of the critical section. There may be memory that needs to be shared between multiple concurrent processes -- the `sync.RWMutex`is conceptually the same thing as a `Mutex`-- it guards acces to memory -- `RWMutex`gives you a little bit more control over the memory. U can request a lock for reading, which case you will be granted access unless the lock is being held for writing.

```go
func main() {
	producer := func(wg *sync.WaitGroup, l sync.Locker) {
		defer wg.Done()
		for i := 5; i > 0; i-- {
			l.Lock()
			l.Unlock()
			time.Sleep(1)
		}
	}
	observer := func(wg *sync.WaitGroup, l sync.Locker) {
		defer wg.Done()
		l.Lock()
		defer l.Unlock()
	}

	test := func(count int, mutex, rwMutex sync.Locker) time.Duration {
		var wg sync.WaitGroup
		wg.Add(count + 1)
		begintesttime := time.Now()
		go producer(&wg, mutex)
		for i := count; i > 0; i-- {
			go observer(&wg, rwMutex)
		}
		wg.Wait()
		return time.Since(begintesttime)
	}

	tw := tabwriter.NewWriter(os.Stdout, 0, 1, 2, ' ', 0)
	defer tw.Flush()

	var m sync.RWMutex
	fmt.Fprintf(tw, "readers\tRWMutex\tMutex\n")
	for i := 0; i < 20; i++ {
		count := int(math.Pow(2, float64(i)))
		fmt.Fprintf(
			tw,
			"%d\t%v\t%v\n",
			count,
			test(count, &m, m.RLocker()),
			test(count, &m, &m))
	}
}
```

The `producer`function’s second paramter is of the type `sync.Locker`-- have two methods, `Lock`and `Unlock`.

### Cond

The comment for the `Cond`type really does a great job of describing its purpose -- like: A rendezvous point for goroutines waiting for or announcing the occurrence of an event. For this, an event is any arbitrary signal between two or more goroutines that carries no info other than fact that it has occcurred.

For this, over often you will want to wait for one of these signals before continuing execution on a goroutine. Naive approach to doing so like:

```go
for conditionTrue()==false {}
```

for this would consume all cycles of one core. to fix:

```go
for conditionTrue()==false {
time.Sleep(...)
}
```

better, still inefficient. So better is if there were some kind of way for goroutine to efficiently sleep until it was signaled to wake and check its condition. This is the exactly what the `Cond`does for this -- like:

```go
c := sync.NewCond(&sync.Mutex{}) // take sync.Locker interface
c.L.Lock() // lock for this condition, necessary the Wait() will automatically call the Unlock()
for conditionTrue()==false {
    c.Wait() // notified that condition occurred suspended
}
c.L.Unlock() // u
```

