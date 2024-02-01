# Git Security SSH

Up to this point, have used HTTPs to connect your remote repository -- HTTPs will usually work just fine, but should use SSH if you work with unsecured networks. And sometimes, a project wil requre that you use SSH.

### What is SSH

SSH is just a secure shell network protocol that is used for network managment -- remote transfer, and remote system access -- uses a pair of SSH keys to establish an authenticated and encrypted security network protocol -- it allows for secure remote communication on unsecured open networks -- SSH keys are used to initiate a secure handshake -- when generating a set of keys, you will generate a public and private key -- 

The *public* is the one you just share with the remote party -- think of this more as the lock -- the *private* key is one you keep for yourself in a secure place. Think of this more as the key to lock.

And, ssh keys are generated through a security algorithm -- it is very complicated -- but uses just **PRIME** number, and large random numbers to make the public and private key.

### Generating an SSH key pair

```sh
ssh-keygen -t rsb -b 4096 -C 
```

Now add this SSH key pari to the SSH-agent like:

```sh
ssh-add /home/ian/.ssh/id_rsa
```

Git Github add SSH -- Copy the ssh public key like:

```sh
ssh-keygen -t ed25519 -C "dtwy77@gmail.com"
```

Test ssh connection to github -- new can test your connection to Github like:

```sh
ssh -T git@github.com
```

For this, if the last line contains your username on Github, you are just successfully authenticated.

Add new Github SSH Remote -- Now can add a new remote via SSH to our Git.

```sh
git remote add ssh-origin git@github.com:Ianwoo77/test.git
```

## Concat and Merge

`concat()`just makes a full copy of data, and iteratively reusing `concat()`can create unnecessary copies. Collect all `DataFrame`or `Series`objects in a list before using `concat()`. 

```python
frames = [process_your_file(f) for f in files]
result = pd.concat(frames)
```

Joining logic of the resulting axis -- The `join`keyword specifies how to handle axis values that don’t exist in the first DF. fore, `join='outer'`takes the union of all axis values

```python
pd.concat([df1, df4], join='inner', axis=1)
```

And, to perform an effecitve `left`join using can reindexed like:

```python
result = pd.concat([df1, df4], axis=1).reindex(df1.index)
```

### Ingoring indexes on the concatenation axis

For DF objects which don’t have a meaningful index, the `ignore_index`ignore overlapping indexes. Like:

```python
result = pd.concat([df1, df4], ignore_index=True, sort=False)
```

### Resulting keys

The `keys`arg adds another axis level to the resulting index or column note that -- 

```python
result = pd.concat(frames, keys=['x', 'y', 'z'])
```

Appending rows to a df -- if have a series that you want to just append as a single row to df, can convert to DF and then use `concat()` like:

```python
s2 = pd.Series(["X0", "X1", "X2", "X3"], index=["A", "B", "C", "D"])
result = pd.concat([df1, s2.to_frame().T], ignore_index=True)
```

```python
groups1= pd.read_csv('meetup/groups1.csv')
groups2= pd.read_csv('meetup/groups2.csv')
categories= pd.read_csv('meetup/categories.csv')
cities = pd.read_csv('meetup/cities.csv', dtype=dict(zip='string'))
```

And note that for `concat()`, pass the parameters an argument of either 1 or `columns`to concatenate the DF across the column axis - namely, expand on column axis.

Execute a left join on groups to just add categories info for each group -- `merge()`method to merge on DF into another -- the method’s first parameter -- `right`just accepts another DF -- the terminology comes from the previous diagram. like:

```python
groups.merge(categories, how='left', on='category_id')
```

Pandas pulls in the categories table’s columns whenver it finds a match for the `category_id`value in groups.

### Merge types -- 

`merge()`implements common SQL type joining operations -- 

- `one-to-one`-- joining two DF objects on their indexes which must contain unique values
- `many-to-one`-- joining a unique index to one or more columns in a different DF
- `many-to-many`-- joining columns on columns

```python
left = pd.DataFrame(
    {
        "key": ["K0", "K1", "K2", "K3"],
        "A": ["A0", "A1", "A2", "A3"],
        "B": ["B0", "B1", "B2", "B3"],
    }
)
right = pd.DataFrame(
    {
        "key": ["K0", "K1", "K2", "K3"],
        "C": ["C0", "C1", "C2", "C3"],
        "D": ["D0", "D1", "D2", "D3"],
    }
)
left.merge(right, on='key')
```

For many to may -- if a key combination appears more then once in both tables, the `DF`will have the Cartesian product of the associated data. And the `how`argumnet to `merge()`specifies which keys are included in the resulting table. If a key combination doces not appear in either the left or right tables, the values in the joined table will be NA.

```python
result= pd.merge(left, right, how='left', on=['key1', 'key2'])
```

### outer joins

An `outer join`combines all records across two data sets -- exclusively does not matter with an outer join. 

```python
groups.merge(cities, how='outer', left_on='city_id', right_on='id')
```

For this, the final DF has all city IDs from both data sets -- if pandas finds a values match between the `city_id`and `id`columns, it merges the columns from the two DF in a single row. Can see some example in the first 5. Can also pass True to the `merge`'s `indicator`to identify which Df a value belongs to. Just add a `_merge`column.

Merging on index labels -- Imagine -- like to join stores its PK in its index. Can invoke the `set_index()`method on `cities`to set its id column as its `DF`index.

```python
cities= cities.set_index('id')
groups.merge(cities, how='left', left_on='city_id', right_index=True)
```

The method also supports a complementary `left_index`parameter.

### DataFrame.join()

`DataFrame.join()`combines the columns of multiple, potentially diffrently-indexed DF into a single result DF.

```python
left = pd.DataFrame(
    {"A": ["A0", "A1", "A2"], "B": ["B0", "B1", "B2"]}, index=["K0", "K1", "K2"]
)
right = pd.DataFrame(
    {"C": ["C0", "C2", "C3"], "D": ["D0", "D2", "D3"]}, index=["K0", "K2", "K3"]
)
result= left.join(right)
result
```

## The go memroy model

Buffered and unbuffered channels offer just *differ* guarantees -- to avoid unexpected races caused by a lack of understanding of the core specifications the language -- look at the Go memory model -- The Go memory model is a specification that defines the conditions under which a read from a variable in one goroutine can be guaranteed to happen after a write to the same variable in a diffrent goroutine -- in other words, it provides guarantees that developers should keep in mind to avoid data races and force **deterministic** output. Use the notation `A<B`denote that event A happens before event B -- 

- Creating a goroutine happens before the grouptine’s execution begins -- therefore, reading a variable and then spinning up a new goroutine that writes to this variable doesn’t lead to a data race.

A send on a channel happens before the corresponding recevie from that channel completes. Closing a channel happens before a receive of this closure -- the next example is similar like:

```go
i := 0
ch := make(chan struct{})
go func(){ 
	<-ch
    fmt.Println(i)
}()
i++
close(ch)
```

For this , leading a data race -- can see like:

```go
i :=0
ch := make(chan struct{}, 1)
go func() {
    i=1
    <-ch
}()
ch <- struct{}{}
fmt.Println(i)
```

Changing the channel type make this example data-race-free -- here we can see the main difference -- the write is guaranteed to happen before the read -- note that the arrow don’t represent causaility -- they represent the ordering guarantees of the Go memory model -- cuz a receive form an unbuffered channel before a send. like:

```go
ch := make(chan struct{}) // un-buffered channel
```

### Understanding the concurrency impacts of a workload type

Looks at the impacts of a workload type ina concurrent implementation -- depending on whether a workload is CPU - or I/O-bound, may need to tackle the problem differently.

- *The speed of the CPU* -- fore, runnign a merge sort algorithm - the workload is called CPU-bound
- *The speed of I/O* -- fore, making a RET call or a dbs query -- the workload is called I/O bound
- The amount of available memory -- called memory-bound.

The following example implements a `read`function that accepts an `io.Reader`and reads 1024 from it repeatedly fore:

```go
func read(r io.Reader) (int, error) {
	count := 0
	for {
		b := make([]byte, 1024)
		_, err := r.Read(b)
		if err != nil {
			if err == io.EOF {
				break
			}
			return 0, err
		}
		count += task(b)
	}
	return count, nil
}
```

Now, if want to run all the task functions just in a parallel manner -- one option is use the so-called worker-pooling pattern - doing so involves creating workers of a fixed size that poll tasks from a common channel.

Fort his, first spin up a fixed pool of goroutine, then we create a shared ahnel to which we publish tasks after each read to the `io.Reader` -- Each from the pool receives from this channel.

```go
func read(r io.Reader) (int, error) {
	var count int64
	wg := sync.WaitGroup{}
	var n = 10
	ch := make(chan []byte, n)
	wg.Add(n)
	for i := 0; i < n; i++ {
		go func() {
			defer wg.Done()
			for b := range ch {
				v := task(b)
				atomic.AddInt64(&count, int64(v))
			}
		}()
	}

	for {
		b := make([]byte, 1024)
		// read from r to be
		if (...){
			break
		}
		ch <- b
	}
	close(ch)
	wg.Wait()
	return int(count), nil
}

```

Concurrency is a fundamental aspecto fo Go programming and effectively managing concurrent operations is curcial for building robust and efficient applications -- one of the key feature that adis in achieving this is the context package in Golang -- provides a mechanism to control lifecycle, cancellation, and propagation of requests *across multiple goroutines* -- In this will delve into the depth of context in go lang -- exploring purpose, usage, and the best practie with real-world examples from the software industry.

What is that -- Is a built-in package in the Go stdlib that provides a powerful toolset for managing concurrent operations it enables the propagation of cancellation signals, deadlines, and values across gorotuines -- ensuring that related operations can gracefully terminiate when necessary. With that, can create a hierarchy of goroutines and pass important info down the chain.

Example -- managing concurrent API requests -- like: