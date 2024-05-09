# Applying a custom operations to all Groups

Want to apply a custom operation to each nested group in `GroupBy`object, say want to identify the company with the highest revenue in each section. Sovled this problem -- now assume that fortune is unordered. Fore, a `DataFrame`' `nlaregest()`method extracts the rows with the greatest value in a given column, here is a quick like:

```python
fortune.nlargest(n=5, columns='Profits')
```

Could invoke the `nlargest`method on each nested `DataFrame`in `sectors`, and can use the `GroupBy`'s `apply`method -- the method expects a function as an argument, it invokes the function once for each group in the `GroupBy`object. Then it collects the return values from the function invocations and returns then in a new DF.

```python
def get_largest_row(df):
    return df.nlargest(1, 'Revenues')
sectors= fortune.groupby('Sector')
sectors.apply(get_largest_row).head()
```

For this, Pandas invokes `get_largest_row`once for each sector and returns a `DataFrame`with the companies with the highest revenue in this sector.

### Grouping by multiple columns

Can create a `GroupBy`object with values from multiple `DataFrame`columns. This operation is optimal when a combination of column vlaues serves the bet identifier for a group. Fore:

```python
sector_and_industry = fortune.groupby(by=['Sector', 'Industry'])
sector_and_industry.size()
```

now the `size()`method returns a `MultiIndex Series`with a count of rows for each internal group. 82 lines means that the fortune has 82 unique *combination* of sector and industry. Then the `get_group()`method requires a tuple of values to extract a nested `DataFrame`from the `GroupBy`collection -- the next example targets rows with a sector of .

```python
sector_and_industry.get_group(('Business Services', 'Education'))
```

And, for all aggregations, pandas returns a MultiIndex `DataFrame`with the calculations. like:

```python
sector_and_industry.sum(numeric_only=True).head() # also multiIndex df
```

Can target individual fortune columns for aggretation by using the same syntax. fore:

```python
sector_and_industry['Revenues'].mean().head()
```

Grouped operations are a powerful way to just aggregate, transform, and filter data. They rely on the mantra of *split-apply-combine*.

1. Data is split into separate parts based on key(s)
2. A function is applied to each part of the data.
3. The result from each part are combined to create a new data set.

### Aggregate

Aggreataion is the process of taking multiple values and returning a *single value*. Aggregation may sometimes be referred to as summarization.

```python
avg_life_exp_by_year = df.groupby('year')['lifeExp'].mean()
```

So, Groupby statements can be thought of as creating a subset of each unque of column (or pairs from columns).

```python
y1952 = df[df.year==1952]
# can perform a function on the subset data like:
y1952_mean=y1952['lifeExp'].mean()
y1952_mean
```

And the `.groupby()`method essentially repeats this process for every year column, calculates the mean value, and conveniently returns all the results in a single df.

#### Built-in Aggregation methods

`count(), size, mean, std, max, sum, sem, describe... frist, last, nth.`

```python
df.groupby('continent')['lifeExp'].describe()
```

Can also use an aggregation function that is not listed -- can call `.agg()`or `aggregate()`. like:

```python
df.groupby('year')['lifeExp'].agg(np.mean)
```

#### Custom User functions

Sometimes we may want to perform a calculation that is not provided by pandas or another library just like:

```python
def my_mean(values):
    n= len(values)
    sum =0
    for value in values:
        sum+=value

    return sum/n

df.groupby('year')['lifeExp'].agg(my_mean)
```

Can also write functions that take multiple parameters, along as the first parameter takes the series of values from the dataframe.

```python
def my_mean_diff(values, diff_value):
    n = len(values)
    sum =0
    for value in values:
        sum+=value
    mean = sum/n
    return (mean-diff_value)

agg_mean_diff=df.groupby('year')['lifeExp'].agg(my_mean_diff, df['lifeExp'].mean())
```

*Starvation* is a situation where an execution is blocked from gaining acess to a shared resource because the resource is made unavailble for a long time by other greedy executions.

## readers-writer Lock

So, need a different design for a readers-writer lock that is not ready-preferred. Could block new readers from acquiring the read lock as soon as a writer calls the `WriteLock()`function. Instead of having the goroutines block on a mutex, could have them suspeded using a condition variable. With a condition variable, can have different conditions on when to block readers and writers. Just like:

- `Reader`'s counter -- initially 0 tells how many readers are actively accessing shared
- *writer’s waiting counter* -- set 0, tells how many writers are suspeded
- *writer’s active indicator* - tells the resouece is currently *being updated* by a writer
- *Condition variable with mutex* -- allow us to set various conditions on the preceding properties.

Go’s `RWMutex`-- The `RWMutex`bundled with Go is write-preferring.

Can implement the writer active indicator as a Boolean flag that is set to `true`when the writer acquires access to the lock. Also know that no writers are waiting to acquire the lock, cuz the writer’s waiting count is set to 0 either.

Then second scenario -- increment the reader’s counter -- indicates to any writers wanting to acquire the writer’s lock that resource is busy being read. If tries to acquire, wait on condition variable, it must also update the writer’s waiting counter by incrementing it.

The writer’s waiting counter just ensures that any newcomer reader will know there are waiting writers. The reader will then give priority to the writer by blocking until the writer’s waiting counter is 0. Like:

```go
type ReadWriteMutex struct {
	readersCounter int
	writerWaiting  int
	writerActive   bool
	cond           *sync.Cond
}

func NewReadWriteMutex() *ReadWriteMutex {
	return &ReadWriteMutex{cond: sync.NewCond(&sync.Mutex{})}
}
```

Then just implement the read-locking function -- like:

```go
func (rw *ReadWriteMutex) WriteLock() {
	rw.cond.L.Lock()
	rw.writerWaiting++
	for rw.readersCounter > 0 || rw.writerActive {
		rw.cond.Wait()
	}
	// once the wait over, decrements the waiting counter
	rw.writerWaiting--
	// once wait is over, marks waiter active flag
	rw.writerActive = true
	rw.cond.L.Unlock()
}
```

For this, set the `writeActive`flag to `true`so that no other goroutine tries to access the lock at the same time.

Then, what we do our goroutine release the lock -- when the last reader releases the lock, can notify any suspended writer by broadcasting on the conditional variable. For this, a goroutine know that it’s the last reader cuz the reader’s counter will b 0 after it decrements it. like

```go
func (rw *ReadWriteMutex) ReadUnlock() {
	rw.cond.L.Lock()
	rw.readersCounter--
	if rw.readersCounter == 0 {
        // send the broadcast if the groutine is the last reader
		rw.cond.Broadcast()
	}
	rw.cond.L.Unlock()
}
```

The writer’s unlock func is simpler, since there can be ever be one writer active at any point in time, can just send a broadcast every time we unlock. Just like:

```go
func (rw *ReadWriteMutex) WriteUnlock() {
	rw.cond.L.Lock()
	rw.writerActive = false
	rw.cond.Broadcast()
	rw.cond.L.Unlock()
}
func main() {
	rwMutex := NewReadWriteMutex()
	//...
}
```

So, with this new writer-preferred implementation, we can rerun our code.

### Couting semaphores -- 

Semaphores give us a different type of concurrency control -- in that can specify the number of concurrent executions that are permitted, can also be used as building blocks for developing more complex concurrency tools.

Mutexes give us a way to allow only one execution to happen at a time. Namely, what if we need to allow a variable number of executions to happen concurrently. Semaphores allow a fixed number of permits that enable concurrent executions to access the shared resources. Once all the permits are used, further requests for access will have to wait until a permit is freed again.

Note: although a mutex is a special case of semaphore with one permit, there is a slight difference in how they are expected to be used -- when using mutexes, the execution that is holding a mutex should *also be one to release it*. But when using semaphores, this is not always the case.

#### Building a Semaphore

Go does not come with a semaphore type in its bundled libraries -- but here is an extension `sync`contaiing an implementation. Custom one -- need to record how many permits we have left, and we can also use a condition variable to help us wait when we don’t have enough permits.

```go
type Semaphore struct {
	permits int
	cond    *sync.Cond
}

func NewSemaphore(n int) *Semaphore {
	return &Semaphore{n, sync.NewCond(&sync.Mutex{})}
}
```

For now, need to implement the `Acquire()`-- need to call `wait()`on a condition variable whenever the permits are 0, if there are enough permits, simply subtract 1 from the permit count. the `Release()`does the opposite, increases the permit count by 1 and signals that a new permit is available. just like:

```go
func (rw *Semaphore) Acquire() {
	rw.cond.L.Lock()
	for rw.permits <= 0 {
		rw.cond.Wait()
	}
	rw.permits--
	rw.cond.L.Unlock()
}

func (rw *Semaphore) Release() {
	rw.cond.L.Lock()
	rw.permits++
	rw.cond.Signal()
	rw.cond.L.Unlock()
}

```

```go
func doWork2(semaphore *Semaphore) {
	fmt.Println("Work started")
	fmt.Println("Work finished")
	semaphore.Release()
}
func main() {
	semaphore := NewSemaphore(0)
	for i := 0; i < 50000; i++ {
		go doWork2(semaphore)
		fmt.Println("Waiting for child goroutine")
		semaphore.Acquire()
		fmt.Println("Child goroutine finished")
	}
}
```

If the `Release()`is called first, the semaphore stores this release permit, and when the `main()`calls `Acquire()`will immediately return without blocking.

## Using File struct to Read a File

```go
func loadConfig() (err error) {
    data, err := os.ReadFile("Config.json")
    if err == nil {
        decoder := json.NewDecoder(strings.NewReader(string(data)))
        err = decoder.Decode(&Config) // var Config ConfigData
    }
    //...
}
```

The `Open`function opens a file for eading and return `File`value, which represents the open file, and an `error`, which is used to indicate problems opening the file.

```go
func LoadConfig() (err error) {
	file, err := os.Open("config.json")
	if err == nil {
		defer file.Close()
		decoder := json.NewDecoder(file)
		err = decoder.Decode(&Config)
	}
	return
}
```

So the `File`struct also implement the `Closer`interface. `defer file.Close()`-- can simply call the `Close()`at the end of the function if perfer.

#### Reading from sepcific location -- 

And the `File`struct defines methods beyond those required by the `Reader`that allows reads to be performed at a specific location -- 

- `ReadAt(slice, offset)`-- defined by the `ReaderAt`interface and performs a read into the specific slice at the specified position offset in the file.
- `Seek(offset, how)`-- Defined by the `Seeker`and mores the offset into the file for the next read.

```go
func LoadConfig() (err error) {
	file, err := os.Open("config.json")
	if err == nil {
		defer file.Close()

		nameSlice := make([]byte, 5)
		file.ReadAt(nameSlice, 20)
		Config.UserName = string(nameSlice)
		fmt.Println(Config.UserName)
		file.Seek(55, 0)
		decoder := json.NewDecoder(file)
		err = decoder.Decode(&Config.AdditionalProducts)
	}
	return
}
```

### Writing to Files

And the `os`package also includes functions for writing files -- 

- `WriteFile(name, slice, modePerms)`-- creates a file with the special name, mode, and permissions and writes the conent of the specified byte slice.
- `OpenFile(name, flag, modeperms)`- Opens the file with the specified name.

#### Using Convenience Function -- 

The `WriteFile`provides a convenient way to write an entire file in a single step and will create the file if it dow not exist. just like:

```go
func main() {
	total := 0.0
	for _, p := range Products {
		total += p.Price
	}

	dataStr := fmt.Sprintf("Time: %v, Total: $%.2f\n",
		time.Now().Format("Mon 15:04:05"), total)
	err := os.WriteFile("output.txt", []byte(dataStr), 0666)
	if err == nil {
		fmt.Println("Output file created")
	} else {
		fmt.Printf("Error: %v\n", err.Error())
	}
}
```

So the frist two arg to the `WriteFile`are the name of the file and a byte slice containing the data to write. And the 3rd argument combines two settings for the file -- the filemode and the file permissions -- like: -- used to specify special characteristics for the file, but the value of `zero`is used for regular files. each digit is the sum of the permission that should be granted -- where read of 4, write of 2, and execute of 1. For this, for all users.

#### Using the File struct to write to a File

The `OpenFile`opens a file and returns a `File`value, unlike the `Open`-- accepts one or more flags that specify how the file should be opened. and the flags are defined as constants in the `os`. like:

`O_RDONLY, O_WRONLY, O_RDWR, O_APPEND, O_CREATE, O_EXCL`

- `O_SYNC`-- enables sync writes, such that data is written to the storge device before the writer returns
- `O_TRUNC`-- truncates the existing content in the file.

```go
file, err := os.OpenFile("output.txt",
                         os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0666)
if err == nil {
    defer file.Close()
    file.WriteString(dataStr)
} else {
    fmt.Printf("Error: %v\n", err.Error())
}
```

#### Writing JSON data to a file

And the `File`struct implement the `Writer`interface, which allows a file to be used with the functions for formatting and processing strings.

```go
func main() {
	cheapProducts := []Product{}
	for _, p := range Products {
		if p.Price < 100 {
			cheapProducts = append(cheapProducts, *p)
		}
	}
	file, err := os.OpenFile("cheap.json", os.O_WRONLY|os.O_CREATE, 0666)
	if err == nil {
		defer file.Close()
		encoder := json.NewEncoder(file)
		encoder.Encode(cheapProducts)
	} else {
		fmt.Println(err.Error())
	}
}
```

This example selects the `Product`values with `Price`value of less then 100.