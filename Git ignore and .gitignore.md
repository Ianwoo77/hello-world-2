# Git ignore and .gitignore

When starting your code with others, there are often files or parts of your project, you do not want to share. Fore:

log files, temporary, hidden, personal -- Git can specify which files or parts of your project should be ignored by Git using a `.gitignore`file, will not track files and folders specified in the .gitignore, however, the `.gitignore`file itself ***IS*** tracked by git.

### Create .gitignore

To create a `.gitignore`, go to the root of your local git, and create it like:

```sh
touch .gitignore
```

Are just going to add two simple rules -- 

- Ignore any files with the `.log`extension
- Ignore everything in any directory named temp

```sh
# ignore ALL .log files
*.log

# ignore all files an any directory named TEMP
temp/
```

Now all .log files and anything in `temp`folders will be ignored by Git.

Local and personal Git ignore rules -- it is also possible to ignore files or folder but not show it in the distributed file. These kind of ignores are specified in the `.git/info/exclude`file, works same as `.gitignore`but are not shown to anyone else

### Git Security SSH

HTTPs will usually work just fine, but should use SSH if you work with unsecured networks. SSH is a secure shell network protocol that is used for network management, remote file transfer, and remote system access. SSH uses a pair of SSH keys to establish an authenticated and encrypted secure network protocol. It allows for secure remote communication on unsecured open networks.

Are used to initiate a secure handshake, when generating a set of keys, will generate a public and private key.

The *public* key is that one you share with the remote party, think of this more as the lock, and the private is the one you keep for yourself in a secure palce, think the key to lock. SSH are generated through a security algorithm, it is all very complicted, but it uses prime numbers, and large random numbers to make the public and private key.

### Generating an SSH key pair -- 

In the command line for linux ,and in the git Bash for windows, can generate an ssh key like:

```sh
ssh-keygen -t rsa -b 4096 -C "test@w3schools.com"
```

Now add this ssh key pair to the SSH-agnet

```sh
ssh-add /home/ian/.ssh/id_rsa
```

now will use the `clip<`command to copy the public key to clipboard like:

## Merge, join, concatenate and compare

Pandas provides various methods for combining and comparing `Series`and `DataFrame`-- 

- `concat()`-- merge multiple series or DataFrame objects along a shared i*ndex or column*
- `join()`-- Merge multiple Df objects along the columns
- `combine_first()`-- updating missing values with non-missing values in the same locaion.
- `merge()`-- combining two or DF objects with SQL-style joining
- `merge_ordered()`-- combine two objects along an ordered axis
- `merge_asof()`-- combine two or .. by near instead of exact maching keys

`concat()`makes a full copy of the data, and iterately reusing `concat()`can create unncessary copies.

```python
groups1= pd.read_csv('meetup/groups1.csv')
groups2= pd.read_csv('meetup/groups2.csv')
```

Each group has a `category_id`FK, can find info on categories in the categories.csv file -- each row in this file stores the category’s ID and name like:

```python
categoreis = pd.read_csv('meetup/categories.csv')
# zip code can start with a heading zero.
cities = pd.read_csv('meetup/cities.csv', dtype={'zip': 'string'})
```

### Concatenating data sets

The simplest way to combine two data is with *concatnation* -- appending one `DataFrame`to the end of another. The groups1 and groups2 `DataFrame`both have the same four column names. Assume that  -- like to combine their rows into a single DataFrame -- pandas has a convenient `concat`at the top level of the lib. just:

`pd.concat([groups1, groups2])`

Its length is equal the sume of the lengths of the groups1 and groups2 DataFrames. And Pandas perserves the original index lables from both DF in the concatenation -- which is why se see a final index position of 8330 in the concatenated DF even though it has more than 16000 rows. Pandas does not care that the same index number appears in both groups.

Can pass the `concat()`'s `ignore_index`parameter an argument of `True`generate :
`pd.concat([groups1, groups2], ignore_index=True)`

If wanted the best of both worlds, to create a non-duplicate index but also perserve which DataFrame each row of data came from -- one solution is to add a `keys`parameter and pass it a list of strings. Pandas will associate each string in the `keys`list with the `DataFrame`at the  same index position in the `objs`list.

```python
# note that for this `ignore_index` need to be False
pd.concat([groups1, groups2], ignore_index=False, keys=['G1', 'G2']).loc['G1']
```

Can extract the original DF by accessing the `G1`or `G2`keys on the first level of the `MultiIndex`- becore proceed, assign the concatnated DF to a `group`variable like:

`groups= pd.concat([groups1, groups2], ignore_index=True)`

Missing vlues in this -- when concatenating two DFs, pandas places `NaN`at intersections of row labels and column lables that the data sets do not share -- consider the following: When we concatenate , pandas appends the rows of the second df to the end of the first just like:

```python
pd.concat(objs=[sports_champions_A, sports_champions_C])
```

Note that the `concat`function includes an `axis`parameter, can pass that parameter an argument either 1 or `column`to concatenate the DataFrame across the column axis:

`pd.concat(objs=[sports_champions_A, sports_champions_C], axis=1)`for this, for the `concat()`method, jsut append the columns to the dataframe.

Left joins -- 

`result = pd.concat([df1, df4], join='inner', axis=1)`The `join`keyword specifies how to handle axis valus that don’t exist in the first.

#### Concatenating Series and DF together

Can concatenate a mix of Series and DataFrame objects, the Series will be transformed to `DataFrame`with the column name as the name of the `Series`-- 

```python
s1 = pd.Series(["X0", "X1", "X2", "X3"], name="X")
pd.concat([df1, s1], axis=1) # name used as column name
```

And, unnamed `Series`will be numbered consecutively like: 

```python
s2= pd.Series(["_0", "_1", "_2", "_3"])
result= pd.concat([df1, s2,s2,s2], axis=1) # just named 0, 1, 2...
result= pd.concat([df1, s1], axis=1, ignore_index=True) # 0, 1, 2...
```

Resulting Keys -- The `keys`argument just add another axis level to the resulting index or column like -- note `ignore_index`always be false for this.

```python
result = pd.concat(frames, keys=['x', 'y', 'z']) # used as outer-most index
pd.concat([s3,s4,s5], axis=1, keys=['red', 'blue', 'yellow'])
```

Also pass a dict to `concat()`in which case the dict keys will be used for the `keys`argument unless other keys arg is specified -- just like:

```python
pieces = dict(x=df1, y=df2, z=df3)
pd.concat(pieces, axis=1)
pd.concat(pieces, keys=['z', 'y'])
```

And the `MultiIndex`created has levels that are constructed from the passed keys and the index of the DF pieces

### Appending rows to a DF -- 

If have a `Series`that you want to append as a single row to a DataFrame, U can convert the row into a DF and use `concat()` like:

```python
s2 = pd.Series(["X0", "X1", "X2", "X3"], index=["A", "B", "C", "D"])
pd.concat([df1, s2.to_frame().T],ignore_index=True) # for series, T has no effect
```

## Race conditions

Race problems can be among the hardest and most insidious bugs a programmer can face. As go Developers, must understand crucial aspects such as data races and race conditions -- Their possible impacts, and how to aovid them. For atomic operations can be done in Go using the `sync/atomic`package like:

```go
func main() {
	var i int64
	go func() {
		atomic.AddInt64(&i, 1)
	}()
	go func() {
		atomic.AddInt64(&i, 1)
	}()
}

```

And another goroutines update `i`automatically, can’t be interrupted, thus preventing two acceses at the same time, regardless of the gorourine’s execution order, will do:

```go
func main() {
	i := 0
	mutex := sync.Mutex{}
	
	go func(){
		mutex.Lock()
		i++
		mutex.Unlock()
	}()
}

```

Another possible is to prevent sharing same memory location and instead favor communication across goroutines. FORE, can create a channel that each goroutine uses to produce the value of the increment like:

```go
func main() {
	i := 0
	ch := make(chan int)
	go func() {
		ch <- 1
	}()

	go func() {
		ch <- 1
	}()
	i += <-ch
	i += <-ch
}
```

Each goroutine sends a notification via the channel implement increment.

- Using atomic operations
- Protecting a critical section with a mutex
- Using communication and channels to ensure that a variable is updated only one goroutine.

With these approaches, the result of i will envntually be set to 2. Instead of having two goroutines increment a shared variable, now each one makes an assignment will follow the approach of using mutex to prevent data races -- like: FORE:

```go
i:=0
mutext := sync.Mutex{}
go func(){
    mutex.Lock()
    defer mutex.Unlock()
    i =1
}()
go func() {
    mutex.Lock()
    defer mutex.Unlock()
    i=2
}
```

Is there data race -- no -- both goroutines access these same variable, but not at the same time -- as the mutex protects it-- but is this example deterministic -- it isn’t. This example doesn’t lead to data race, but it has a *race condition* -- occurs when the behavior depends on the sequence or the timing of events that *can’t be controlled*. And ensuring a specific execution sequence among goroutines is a question of coordination and orchestration. So should find a way to guarantee that the goroutines are executed in order.

Ensuring a specific execution sequence among goroutines is a question of coordination and orchestration. In summary, when work in concurrent app -- it’s essential to undertand that a data race is different from race condition. A data race occurs when multiple goroutines simultaneously access the same memory location and at least one of them is writing.

### The Go memory model

Fore, buffered and unbuffered channels offer different guarantees -- to avoid unexpected races caused by a lcak of understanding of the core specifications of language, have to look at the Go memory model like: Whthin a single goroutine, there is no chance of unsynchronized access, indeed, the happens-before order is guaranteed by the order expressed by our program.

However, within multiple goroutines, should bear in mind some of these -- we will use the ..

- Creating a goroutine happens before the goroutine’s execution begins -- therefore, reading a variable and then spinning up a new goroutine that writes to this variable doesn’t lead to a data race

  ```go
  i := 0
  go func(){i++}()
  ```

- Conversely, the exit of a goroutine isn’t guaranteed to happen before any event. following has data race 

  ```go
  i:=0
  go func() {i++}()
  fmt.Println(i)
  ```

- A send on a channel happens before the corresponding receive form that channel completes like:

  ```go
  i:=0
  ch := make(chan struct{})
  go func(){
      <-ch // receive
      fmt.Println(i) // read
  }
  i++ // increment
  ch <- struct{}{} // channel sned
  ```

  For this , the order is: increment< channel send < chennel receive <variable read -- A parent goroutine increments a variable before a send, while another goroutine reads it after a channel read.

- Then Closing a channel happens before receives this closure -- The next is similar to the previous: but instead of sneding, closing -- like:

  ```go
  i:=0
  ch := make(chan struct{})
  go func(){
      <-ch
      fmt.Println(i)
  }()
  i++
  close(ch)
  ```

- Regarding chennesl -- *a receive from an unbuffered happens before the send on the chennel completes*.

```go
// buffered channel
i := 0
ch := make(chan struct{}, 1)
go func(){
    i=1
    <-ch // cuz this happens first, so i=1 must be executed first
}
ch <- struct{}{}  // lead to a data race -- both read and write to i occur simultanously
fmt.Println(i)
```

If change it to the unbuffered one to illustrate the memroy model like:

```go
ch := make(chan struct{})
```

For this, make it data-race free -- here can see the main difference -- the write is guaranteed to happen before the read. Cuz a r**eceive from an unbuffered channel happens before a send**, the write to i occur befreo the read.

## Testing

And finally come to the topic of testing -- Like structuing and organizing your app code, there is no single right way to structure and organize your tests in go-- but there are some conventions, patterns, and good-pracitces that you can follow -- in this section were going to add tests for a selection of the code in our app, with the goal of demonstrating the general syntax for creating tests and illustrating some patterns that you can just reuse in wide-variety of apps.

- How to create and run *table-driven* unit tests and sub-tests in go
- Test HTTP handlers and middleware
- Perform end-to-end tesing or your web app routes, middleware and handlers
- How to create mocks of dbs models and use them in unit tests
- A pattern for testing CSRF
- How to use a test instance of MySQL to perform integration tests
- how to easily calculate the provile code coverage for your tests...

### Unit Testing and sub-tests

Create a unit test to make sure that our `humanDate()`func made back in the app is outputting `time.Time`values in the exact format that we want. Just like:

```go
func humanDate(t time.Time) string {
    return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

The reason that i want to start by testing this is cuz it’s a simple func.

Creating a Unit test -- In go, its std practice to create your tests in a `*_test.go`files which live directly along side code you are testing -- in this case, the first thing that we are going to do is create a new `cmd/web/tempaltes_test.go`file like:

```go
func TestHumanDate(t *testing.T) {
	// initialize a new time.Time and pass it to an humanDate() func
	tm := time.Date(2020, 12, 17, 10, 0, 0, 0, time.UTC)
	hd := humanDate(tm)

	// check that the output form the func is in the format we expect
	if hd != "17 Dec 2020 at 10:00" {
		t.Errorf("Want %q: got %q", "17 Dec 2020 at 10:00", hd)
	}
}

```

This pattern is just the basic one that you will use for nearly all tests that you write in go. The important things take away are -- 

- The test just regular Go code -- calls the `humanDate()`and checks that the result matches what we expect.
- To be a valid unit test the name of this must *must* begin iwth the word `Test`. Typically ths is then followed by the name of the func.
- Can use the `t.Errorf()`to mark *failed* and log a descriptive message about the failure.

### Table - driven tests

Expand the func to cover some additional test cases -- specifically, going to update it also check that -- 

1) if the input to func is zero time, return string “”
2) then from the func always uses UTC time zone.

In go, an idiomatic way to run multiple test cases is to use the table-driven tests -- essentially, the idea behind the table-dirven tests is to create a *table* of test cases containing the inputs and expected outputs, and to then loop over thse, running each test case in a sub-test, there are a few ways you could set this up, but a common approach is to define your *test cases in an slice of anonymous structs*.

```go
func TestHumanDate(t *testing.T) {
	tests := []struct {
		name string
		tm   time.Time
		want string
	}{
		{
			"UTC",
			time.Date(2020, 12, 17,
				10, 0, 0, 0, time.UTC),
			"17 Dec 2020 at 10:00",
		},
		{"Empty",
			time.Time{},
			""},
		{"CET",
			time.Date(2020, 12, 17, 10, 0,
				0, 0, time.FixedZone("CET", 1*60*60)),
			"17 Dec 2020 at 09:00",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hd := humanDate(tt.tm)
			if hd != tt.want {
				t.Errorf("Want %q: got %q", tt.want, hd)
			}
		})
	}
}
```

Can see that we get individual output for each of our sub-tests -- as you might have guessed, our first test case passed by the `empty`and `GET`tests both failed. For this, just note that when use the `t.Errorf()`to mark a test as failed, it doesn’t cause `go test`to immediately exist, all the other tests and sub-tests will continue to be run after a failure. Also worth pointing out that when we use the `t.Errorf()`func to mark a test as failed, doesn’t cause.

As a side note, can use the `-failfast`flag to stop the tests running after the first failure like:

```sh
go test -failfast -v ./cmd/web
```

head back to the code and update it to fix these two problems like:

```go
func humanDate(t time.Time) string {
	if t.IsZero(){
		return ""
	}
	return t.UTC().Format("02 Jan 2006 at 15:04")
}
```

Running all tests -- To run *all* the tests for a project, instead of just those in the specific package, can use the `./...`wildcard pattern like so:

```sh
go test ./...
# for the output: ok for /cmd/web, others.. ? [no test files]
```

