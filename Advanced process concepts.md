# Advanced process concepts 

signals -- `systemctl`tell web server to re-read its configuration files -- namely, how can you politely ask a process to shut down cleanly, and how can you kill a malfunctioning process immediately, -- In Unix and Linux, all of this id down with signals -- Signals are numerical messages that can be sent beteen programs. They are a way for processes to communicate with each other and with the OS, allowing processes to send and receive specifc messages -- theses messages can be used to communicate a variety of things to process.

Signals can be used to implement inter-process communications -- fore, one process can send a signal to another process indicating that it is finished wtih a particular task and that the other process can now start working. This allows processes to coordinate their actions and work together in a smooth and efficient manner.

### Trapping 

Many of the signals can be trapped by the processes that receive them. The `kill`allows to send a signal to a process by sepcifying its PID -- if the process you’d like to terminate like:

```sh
kill 2600
```

This command would send signal 15 (`SIGTERM`) to the process.

If want to explore -- `/proc`directory -- that is definitely beyond the basics -- it’s a directory that contains a filesystem subtree for every process.

Isof -- show files handles that a process has open -- `lsof`command shows all files that a process has opened for reanding and writing.

Inheritance -- except PID1 all processes are created by a parent process, which essentially makes a copy of itself and then `forks`that copy off. When process is forked, it typically inherits its parenet’s permissions, environment variables, and other attributes.

### Troubleshooting session

```sh
# top sorts processes by CPU usage
top
# if some trouble process
kill 1763
pgrep bzip2 # check to see if this still running
kill -9 1763 # kill that without allowing the process to trap
```

```python
to_drop = ['Edition Statement',
           'Corporate Author',
           'Corporate Contributors',
           'Former owner',
           'Engraver',
           'Contributors',
           'Issuance type',
           'Shelfmarks']
```

Can drop these columns in the following way like:

```python
df = df.drop(to_drop, axis=1)
```

For this, defined a `list`that contains the names of all the columns we want to drop. Next call the `drop()`function on our object, passing in the `axis=1`-- tells pandas we want the changes to be made on the columns of the object.

Alternatively, could also remove the columns by passing them to the `columns`just like:

```python
df = df.drop(columns=to_drop)
```

### Changing the index of DF -- 

A pandas `Index`extens the functionality of Numpy arrays to allow for more versatile slicing and labeling -- in many cases, it is helpful to use a uniquely valued identified filed of the data as its index.

```python
df.Identifier.is_unique
df = df.set_index('Identifier')
```

Can access each record in a straightforward with `loc[]`

Tiding up fields in the data -- Will clean specific columns and get them to a unifrom format to get a better understanding of the dataset and enforce consistency. `df.dtypes.size`

3. How to convert the index of a series into a column of df:

   ```python
   mylist = [chr(x) for x in range(ord('a'), ord('z')+1)]
   myarr = np.arange(26)
   mydict= dict(zip(mylist, myarr))
   ser = pd.Series(mydict)
   # ...
   df = ser.to_frame().reset_index()
   ```

4. How to combine many sereis to form a dataframe - 

   ```python
   ser1 = pd.Series([chr(x) for x in range(ord('a'), ord('z')+1)])
   ser2 = pd.Series(np.arange(26))
   # solution 1 & 2
   pd.concat([ser1, ser2], axis=1) #
   df = pd.DataFrame({'col1': ser1, 'col2': ser2})
   ```

5. How to assign anem to the series’ index

   ```python
   ser1.name='alphabets'
   ```

## Context(2)

Used the `context.TODO()`or `context.Background()`-- The `context.Background()`func creates an empty context like `context.TODO()`does -- designed to be used where you intend to start a known onctext -- fundamentally the two functions to the same thing -- return an empty context that can be used as `context.Context`-- the biggest difference is how yo usignal your intent to other developers -- 

### Using Data within a Context

One benefit of using `context.Context`in a program is the ability to access data stored inside a context -- by adding data to a context and passing the context from function to function -- each layer of a program can add additional info about what is happening -- fore, the first function may add a username to the context. The next may add file path to the content the user is trying to access. Using the `context.WithValue()`in the context package.

```go
func doSomething(ctx context.Context) {
	fmt.Println(ctx.Value("myKey"))
}
func main() {
	ctx := context.Background()
	ctx = context.WithValue(ctx, "myKey", "myValue")
	doSomething(ctx)
}
```

Important to know that the values stored in a specific `context.Context`are immutable, meaning that they cant be changed, when U called the `context.WithValue`-- passed in the parent context and you also received a context back. Received a context back cuz the `context.WithValue()`didn’t modify the context you provide.

```go
func doSomething(ctx context.Context) {
	fmt.Println(ctx.Value("myKey"))
	anotherCtx := context.WithValue(ctx, "myKey", "anotherValue")
	doAnother(anotherCtx)
	fmt.Println(ctx.Value("myKey")) // still myValue
}
func doAnother(ctx context.Context) {
	fmt.Println(ctx.Value("myKey"))
}
```

### Editing a Context

Another powerful tool `context.Context`provides is a way to signal to any functions using it that the context has ended and should be considered complete. By signaling to these functions that the context is done, they know to stop processing any work related to the context that they may still be working on. Using this features of a context allows your programs to be more efficient cuz instead of fully completing every func, even if the result will be thrown out, that processing time can be used for sth else. FORE, if a web page request comes to your Go web server, a user may end up hitting the stop or closing their browser before the page finishes loading.

### Determining if a Context is Done -- 

The `context.Context`type provides a method called `Done`that can be cheked to see whether a context has ended or not -- returns a `channel`that is closed *whent the context itself is done*, and any functions watching for it to be closed will know they should consider their execution context completed and should stop any processing related to the context. And the `Done`works cuz no values are ever written to its channel, and when a channel is clsoed that channel will start to return `nil`for every read attempt. By periodically checking whether the `Done`has closed and doing processsing work in-between, you are able to implement a func that can do work also knows if it should stop procesing early.

Combining this processing work, the periodic check of the `Done`channel, and the `select`statement goes even further by allowing you to send data to or receive data from other channels simultaneously.

Each `case`stement can be either a channel read or write operations, and the `select`will block until one of the case can be executed. Can add `default`that will be executed immediately note -- If **none** of the other `case`statements can be executed. Just like:

```go
ctx := context.Background()
resultCh := make(chan *WorkResult)
for{
    select {
    case <-ctx.Done():
        return
    case result:= <-resutCh:
        //process the results received
    }
}
```

Every time the `select`is run, Go will stop running the func and watch all the `case`-- whenone of the `case`of can be executed -- whether reeading or writing. For the code in the example, the `for`will continue forever until the `ctx.Done`channel is closed cuz the only `return`statement is inside that `case`.

And if the example’s `select`had a `default`clause branch without any code in it -- wouldn’t actually change how the code works -- would just cause the `select`to end right away and the `for`would start another iteration of the `select`statement to end right away and the `for`loop would start anothre iteration of the `select`statement -- this leads to the `for`loop executing very quickly cuz it will never stop and wait to read from a channel.

Since the only way to exit the `for`loop in the example code is to close the channel returned by `Done`-- and the only way to close the `Done`channel by ending the context, you will need a way to end the context. The Go `context`package provides a few ways to do this depending on your goal, and the most direct option is to call a function to `cancel`the context.

### Canceling a Context

Canceling a context is the most straightforward and controllable way to end a context. Similar to including a value in a context with `context.WithValue()`-- it’s possible to associate a cancel function with a context using the `context.WithCancel`func -- receives a parent context as a parameter and returns a new context as well as a function that can be used to cancel the returned context.

```go
func doSomething(ctx context.Context) {
	ctx, cancelCtx := context.WithCancel(ctx)
	printCh := make(chan int)
	go doAnother(ctx, printCh)
	for num := 1; num <= 3; num++ {
		printCh <- num
	}
	cancelCtx()
	time.Sleep(100 * time.Millisecond)
	fmt.Printf("doSomething: finished\n")
}
func doAnother(ctx context.Context, printCh <-chan int) {
	for {
		select {
		case <-ctx.Done():
			if err := ctx.Err(); err != nil {
				fmt.Printf("doAnother err: %s\n", err)
			}
			fmt.Printf("doAnother: finished\n")
			return
		case num := <-printCh:
			fmt.Printf("doAnother: %d\n", num)
		}
	}
}
```

In this, function acts like a function that sends work to one or more `goroutine`reading from a work channel. In this case, `doAnother`is the worker and printing the numbers is the work it’s done. Once the `doAnother`goroutine is started, `doSomething`beings sending numbers to be printed. Inside the `doAnother`the select is waiting for either the `ctx.Done`to close or for a number to be received.

Once the `doSomething`has canceled the context, it uses the `time.Sleep`func to wait a short amount of time to give `doAnother`time to process the canceled context and finish running. The `context.WithCancel()`and the cancel func it returns are most useful when you want to control exactly when the context ends.