# Github Flow

On this, will learn how to get the best out of working with Github. The Github flow is a workflow designed to work well with git and github. like this:

1. Create a new branch
2. Make change and add commits.
3. Open a pull request
4. Review
5. Deploy
6. Merge

### Create a new Branch

Branching is the key concept in Git, and it works around the rule that the master branch is ALWAYS deployable. That means if U want to try sth new or experiment -- create a new branch -- Branching gives U an environment where you can make changes without affecting the main branch. And when your new branch is reqdy, it can be reviewsed, discussed, and merged with the main when ready.

Make changes and add commits -- After branch created, get to work, and make changes by adding, editing, and deleting filew. Whenvever you readh a smaill milestone, add the changes to your branch by commit. And adding commits keep tracks of your work. Each commit should have a message explaining what has changed and why.

Open a Pull request -- are key parts of Githu. Pull notifies people you have changes ready for them to consider or review. When request is made can be reviewd by whoever has the proper access to the branch.

### Host page on github

Create a new -- needs a *special* name to function as a git page. It needs to be your github username, then Push local repository to github pages -- then as a remote for your local repository -- calling it `gh-page`. Then in the local git, add: `git remote add gh-page https://github.com/...git`then like:

```sh
git push gh-page master
```

### Git Github fork

Add to someone else’s repository -- at the heart of Git is collaboration. Git does not allow you to add code to someone else’s repository without access rights. In this, show how to copy a repository, make changes, and suggest those changes to be implemented to the original repository.

Fork a repository -- A `fork`is a copy of a repository. This is just useful when want to contribute to some else’s project or start your own proj based on theirs.

Note that `fork`is just not a command in Git, but something offered in github and other repository hosts.

### Clone a Fork from Github

Now have our own `fork`, only on Github, also want a `clone`on our local Git to keep working on it.

Configuring remotes -- Basically, have a full copy of a repostiory, whose `origin`we are not allowed to make changes to. but can write:

```sh
git remote -v # displayed the origin
```

Saw that `origin`is set up the original `w3schools-test`repostiory, also want to add our own `fork`just like:

```sh
# rename the original origin remote
git remote rename origin upstream
git remote -v
# then fetch the URL from own fork like:
git remote add origin https://github.com/Ianwoo77/w3schools-test.github.io.git
git remote -v # display four
```

Now have 2 remotes -- note that!!!

- `origin`-- our own fork, where we have read and write access
- `upstream`-- the true original, where we have read-only access

## Reshaping and pivot tables

Pandas provides method for manipulating a `Series`and `DataFrame`to alter the representation of the data for further data processing or data summarization.

- `pivot, pivot_table()`-- grouping unique values within one or more discrete categories.
- `stack(), unstack()`-- privat a column or row level to the *opposite axis* respectively.
- `melt(), wide_to_long()`-- unpivot a wide DF to a long format

### Pivot

Data is just often stored in `so-called`stacked or record format -- a record or *wide* format, typically there is one row for each subject, in a stacked or long format, there are multiple rows for each subject where applicable. like:

```python
data = {
   "value": range(12),
   "variable": ["A"] * 3 + ["B"] * 3 + ["C"] * 3 + ["D"] * 3,
   "date": pd.to_datetime(["2020-01-03", "2020-01-04", "2020-01-05"] * 4)
}
df = pd.DataFrame(data)

# To perform time series operations with each var, columns are the unique variable and index of dates
# identifies individual observations
df.pivot(index='date', columns='variable', values='value') # also on top level
```

If `values`arg omitted, and the input Df has more than one column of values, then resulting pivoted have hierarchical columns like:

```python
df['value2']=df.value*2
pivoted
pivoted= df.pivot(index='date', columns='variable')
# then select subsets from the pivoted
pivoted['value2']
```

### `pivot_table`

While `pivot()`just provides general purpose pivoting with various data types, pandas also provides `pivot_table()`with aggregation of numeric data -- The func `pivot_table()`can be used to create spread-style pivot tables -- like:

```python
import datetime
df = pd.DataFrame(
    {
        "A": ["one", "one", "two", "three"] * 6,
        "B": ["A", "B", "C"] * 8,
        "C": ["foo", "foo", "foo", "bar", "bar", "bar"] * 4,
        "D": np.random.randn(24),
        "E": np.random.randn(24),
        "F": [datetime.datetime(2013, i, 1) for i in range(1, 13)]
        + [datetime.datetime(2013, i, 15) for i in range(1, 13)],
    }
)
df.pivot_table(values='D', index=['A', 'B'], columns='C')
df.pivot_table(values='D', index=['A', 'B'], columns='C', aggfunc=np.sum)
pd.pivot_table(df, values='E', index=['B', 'C'], columns=['A'],
               aggfunc=[np.sum, np.mean])
```

For this, result DF potentially having a `MultiIndex`on the index or column. If the values column name is not given, the pivot table will include of the data in an additional level of hierarchy in the columns. Note that:

```python
df['A B C D E'.split()].pivot_table(index=['A', 'B'], columns='C')
```

Adding margins -- Passing `margins=True`to `pivot_table()`will add a row and column with an `All`label like:

```python
df.pivot_table(index=['A', 'B'], columns='C', margins=True, aggfunc=np.sum, 
               values=['D', 'E'])
```

Additionally, can all `DataFrame.stack()`to display a pivoted DataFrame as having a multiple-level index like:

```python
table.stack() # move column to index?
```

Closely related to the `pivot()`method are the related `stack()`and `unstack()`methods avaiable on `Series`and DF. These methods are designed to work together with `MultiIndex`objects.

- `stack()`-- pivot a level of column lables, returning with an index added to a new inner-most level of row labels
- `unstack()`-- row into the column axis -- producing a reshpaed `DataFrame`with a new inner-most level of column labels.

```python
tuples = [
   ["bar", "bar", "baz", "baz", "foo", "foo", "qux", "qux"],
   ["one", "two", "one", "two", "one", "two", "one", "two"],
]
index = pd.MultiIndex.from_arrays(tuples, names=['first', 'second'])
df = pd.DataFrame(np.random.randn(8,2), index=index, columns=['A', 'B'])
df2 = df[:4]
df2
type(df2.stack()) # Series returned
stacked.unstack() # inner-most unstacked to column
stacked.unstack(0) # 1st index to column
stacked.unstack(1) # 2nd index to column or unstack('second')
```

Noticed that the `stack`and `unstack() `methods implicitly.

## Don’t thinking concurrency is always faster

A misconception among many developers is believing that a concurrent solution is always faster then a sequential. This couldn’t be more wrong. The overall performance of a solution depends on many factors, such as the effiency of our structure which parts can be tackled in parallel, and the level of contention among the computation untis.

### Go Scheduling

A thread is the smallest unit of processing that the OS can perform -- if a process wants to execute multiple actions simultaneously, it spins up mutiple threads, these trreads can be -- 

- `Concurrent`-- Two mre more threads can start, run and omplete in overlapping time periods, like the waiter thread and the coffee machine thread in the pervious
- `Parallel`-- The same task can be executed mutliple times at once -- like multiple watier threads.

The os is just responsible for scheudling the thread’s processes optimally so that -- 

- all the threads can onsume PCU cycles without being starved for too much
- The workload is distribued as evenly as possible among the different cpu cores.

A CPU core executes different threads, when it switches from one to another, it just executes an operation called *context switching* -- the active thread consuming CPU cycles was in an executing state and moves a *runnable* state, meaning it’s ready to e executed pending an availale fore. Context switching is consdered an *expensive* op cuz the OS needs to save the current execution state of a thread before the switch.

As Go developers, can’t create threads directly, can generate goroutines -- which can be thought of as *application-level threads*. However, whereas an OS thread is context-switched and off a CPU core by the os, a goroutine is a context-switched on and off an OS thread by the Go runtime -- Also compared to an OS thread, a goroutine has a smaller memory footprint -- 2kb for goroutines from Go. An os thread depends on the OS, but fore, size is 2MB on linux...

Internally, the Go scheduler uses the following terminology -- 

- `G`for Goroutine
- `M`for OS thread (machine)
- `P`for CPU core (processor)

Each M is assigned to a P by the OS scheduler, then each goroutine runs on an M. In go the `GOMAXPROCS`variable defines the limit of Ms in charge of executing user-level code simultaneously.

A goroutine just has a simpler lifecycle than an OS thread, it can be doing one of the following -- 

- `Executing`-- the goroutine is scheduled on an M and executing its instructions
- `Runnable`-- the goroutine is waiting to be in an executing state
- `Waiting`-- the goroutine is stopped and pending something completing.

When a goroutine is created but cannot be executable, fore, all the other M are already executing a G.

Being puzzled about when to use channels or mutexes -- Given a concurrency problem. it may not always be clear whether can implent a solution using channels or mutexes -- cuz Go promotes sharing memory by communcation. Should see the two options as complementary.