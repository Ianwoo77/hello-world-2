# Three-way merges

First, note that in the `rainbow`repository, still have the local `feature`branch and the `origin/feature`remote-tracking branch -- moving forward you will work on the main branch. 

```sh
# delete the remote feature and `origin/feature`
git push origin -d feature

# now there is no remote feature cuz fetch from friend
git fetch -p # remote remote-tracking that correspond to delete remote branches

# delete local branch
git branch -d feature
```

### Why are Three-way Merges Important -- 

Three-way merges are bit more complicated then FF merges cuz they create merge commits and they may lead to merge conflicts. *Merge conflicts* arise when you merge two branches where different changes hanve been made to the same parts in the same file, or if one branch a file was deleted that was just edited in the other branch.

Fore, each work independently on chapters, coauthor finishes their work on the fore Ch6 branch first and proceeds to merge their work into the `main`. When finish working on ch5, D commit, also want to merge work into main. But not coauthors let me know they’ve already added work to the remote `main`. 

For the `Book`repository, ABC(ch5) and ABD(main) -- since it is not possible to follow the development history of the ch5 to reach `main` -- This means that the development histories of these branches have *diverged*. For this, one is to merge local ch5 into the local main -- which will be a 3-way merge, and then push the updated main to the remote.

Note that the other option is to carryout a merge in the remote through a hosting service feature called *pull request*.

### Setting up a 3-way merge scenario

```sh
# in the rainbow, create othercolors.txt Type
git add othercolors.txt
git commit -m "brown"
```

Next, before push your commit to the remote repository, define upstream branches -- When U push work from a local branch to a remote, Git needs a way to know which remote branch you want to push the work to. Need to know that upstream branches are automatically set up when clone a repository.

To avoid specifying the remote repository shortname and the branch every time U use the `git push`command on the `main`, can define an upstream branch for the main branch and therefore simply use the `git push`with no arg.

Note that to set up the upsteam branch will use the `git branch`with the `-u`option. note that which is the short for 
`--set-upstream-to`, you will pass in the name of the remote branch as an argument, specifying the remote repository shortname, fore `origin/main`. Like:

```sh
git branch -u <shortname>/<branch_name>
git branch -vv # check whether there is an upstream branch
git branch -u origin/main
git branch -vv # now main ahead 1 brown
```

For this, the last `git branch -vv`output shows that the `main`from the remote repository with shortname `main`has been set as the upstream for the local `main`branch.

Now that have defined an upstram branch for your local main, then:

```sh
git push
git log
git branch -vv
```

U pushed your local `main`branch to the remote repository. To end up in a situation where you will have to carry out a 3-way merge, there must be diverged development histories between two branches. Next, friend will continue working on the local `main`in their local *without* fetching the changes U pushed to the remote `main`, which will cause the local `main`in the `friend-rainbow`and `main`in the `rainbow-remote`to diverged.

#### Editing the same file multiple times betwen commits

It is important to understand that if you add a file to the staging area and then make *another* change to the file, Git will interpret this as a new version of the file and it will mark the file as modified. If want the latest version of the file to be included in next commit, have to add the updated version of the file to the staging area again.

To see this, your friend is going to add the color blue to the list of colors in `rainbowcolors.txt`file and edited file to their staging area. In the `friend-rainbow`like: Then:

```sh
# in the friend-rainbow, edit rainbowcolors.txt add some typo
git status
```

Note that -- 

- The version of the `rainbowcolors.txt`file in the staging area is still A, has not changed
- The version of the `rainbowcolors.txt`in the file directory has been changed, B. fore. Then:

```sh
git add rainbowcolors.txt
```

- The version of the `rainbowcolors.txt`file in the staging area has changed from A to B
- The version of the txt file in the staging area is the same as the one in the working directory.

Then just validate the typo. The `git status`output modified.

```sh
git add rainbowcolors.txt
```

Then the version of the `rainbowcolors.txt`in the staging area has changed from B to C. Indicating that the latest version of the `rainbowcolors.txt`has been added to the staging area.

## Comparing Values incorrectly

Comparing values is just a common operation -- The `==`shouldn’t always be the case. To answer these, start with a concrete example, create a basic `customer`and use the `==`to compare like:

```go
type customer struct {
    id string
}
func main(){
    cust1 := customer{id:"x"}
    cust2 := customer{id:"x"}
}
```

Note that comparing these two structs is a valid operation in Go, and `cust1==cust2`is `ture`. But:

```go
type customer struct {
    id string
    operations []float64
}
cust1 := customer{id:"x", operations: []float64{1.}}
cust2 := customer{id:"x", operations: []float64{1.}}
```

Then `cust1==cust2`doesn’t even compile -- the problem relates to how the `==`and `!=`operators work -- these operators don’t work with slices or maps -- cuz the `customer`struct contains a slice, can’t compile. It’s essential to understand how to use `==`and `!=`to make comparisons effectively, can use these operators on operands that are *comparable* -- 

- Booleans Numerics, Strings
- *Channels* -- compare whether two were created by the same call to `make`or both are `nil`.
- *interfaces* -- has identical types or if both `nil`.
- *Pointers* -- Compare whether two pointers to the same value in memory or if both `nil`
- Structs and Arrays -- Compare whether they are composed of similar type.

So, our code failed to compile as the struct was composed on a non-comparable type `slice`.

*Reflection* is a form of metaprogramming, and it refers to the ability of an application to introspect and modify its struct and behavior. fore, in Go, can use the `reflect.DeepEqual`-- this reports whether two elements are *deeply equal* by recursively traversely two values. like:

```go
cust1 = customer{id:"x", operations:[]float64{1.}}
cust2 = customer{id:"x", operations:[]float64{1.}}
fmt.Println(reflect.DeepEqual(cust1, cust2)) // true
```

Cuz this function uses reflection, which introspects values at runtime to discover how they are formed. It has a perforance penalty. If performance is a crucial factor, another option might to be implement our comparison method.

```go
func (c customer) equal(b customer) bool {
    if a.id != b.id{
        return false
    }
    if len(a.operations) != len(b.operations) {
        return false
    }
    for i:=0; i<len(a.operations); i++ {
        if a.operations[i]!= b.operations[i] {
            return false
        }
    }
    return true
}
```

### Elements are copied in `range`loops

A `range`is a conenient way to iterate over all the elements of the one of these data structures.

Value copy -- Understanding how the value is handled during each iterations is critical for using a `range`loop effectively -- like:

```go
type account struct {
    balance float32
}
accounts := []accounts {
    {balance: 100,},
    {balance: 200,},
    {balance: 300,},
}
for _, a := range accounts {
    a.balance += 1000
}
```

In this example, the `range`loop does *Not* affect the slice’s content -- In Go, everything we assign is a copy -- 

- If assign the result of a function returning a *struct*, perform a copy of that struct
- If returning a *pointer*, then performs a copy of the memory address.

So, it’s crucial to keep this in mind to avoid common mistakes, including those related to `range`loops, indeed, when a `range`loop iterates over a data structure, it performs a copy of each element to the value variable. There are two main options -- to access the element using slice index, can be achieved with like:

```go
for i := range accounts {
    accounts[i].balance += 1000
}
for i:=0; i<len(accounts); i++ {
    accounts[i].balance += 1000
}
```

### Arguments evaluating in `range`

The `range`loop syntax requires an expression, fore, in `for i, v := range exp`, exp is the expression. It can be a string, an array, a pointer, to an array, a slice, map or channel.. When using a `range`loop, this is an essential point to avoid common mistake -- 

```go
s := []int {0,1,2}
for range s {
    s= append(s,10)
}
```

When using a `range`, the provided expresion is evaluated *only once* -- before the beginning of the loop, the provided expression is evaluated only once -- *evaluated* just means the provided expression is copied to a temporary variable, and then `range`iterate over this variable. In this, when the `s`is evaluated, the result is a slice copy. The `range`loop uses this temporary variable. The original slice `s`is also updated during each iteration.

For this, each step results in appending a new element, however, after 3 steps, we have gone over all the elements. Indeed, the temporary slice used by `range`remains 3-len. note that the behavior is different with a classic `for`:

```go
s := []int{0,1,2}
for i:=0; i<len(s); i++ {
    s= append(s, 10)
}
```

For this, the loop never ends, the `len(s)`expression is evaluated during each iteration, and cuz we keep adding elements, will never reach a termination.

#### Channels

See a concrete example based on iterating over a channel using a `range`-- create two goroutines, both sending elements to two distinct channel. Then in the parent goroutine, we implement a consumer on one channel using a `range`loop that tries to switch to theother channel during the iteration.

```go
cha := make(chan int, 3)
go func() {
    ch1 <- 0
    ch1 <- 1
    ch1 <- 2
    close(ch1)
}()

ch2 := make (chan int, 3)
// same logic with ch1
ch := ch1
for v := range ch {
    fmt.Println(v)
    ch = ch2
}
```

In this example, the same logic applies regarding how the `range`expression is evaluated, the expression provided to `range`is a `ch`channel pointing to `ch1`. Hence, `range`evaluates `ch`, performs a copy to a temporary variable, and iterates over elements from this channel. And the `ch=ch2`isn’t without effect, though, cuz assigned `ch`to the second variable.

#### Array

Cuz the `range`expression is evaluated before the beginning of the loop, what is assigned to the temporary loop variable is a copy of the array -- like:

```go
a := [3]int{0,1,2}
for i, v := range a {
    a[2]=10
    if i==2 {
        fmt.Println(v)
    }
}
```

For this cuz the copy semantics, it does not print 10, just 2. Can:

```go
a := [3]int{0, 1, 2}
for i:= range a {
    a[2]= 10
    if i==2 {
        fmt.Println(a[2])
    }
}
// or
for i, v := range &a { // range over &a instead of a
    //...
}
```

Just asign a copy of the array pointer to the temporary variable used by the `range`. Cuz both pointers reference the same array, accessing `v`also returns 10.

## Installing a dbs driver

To use MySQL from our Go web app, need to install a dbs driver. The essentially acts as a middleware. Just like:

```sh
go get github.com/go-sql-driver/mysql
```

### Modules and repoducible builds

Now that the MySQL direver is installed, take a look at the `go.mod`file, should see a new `require`liine contaiing the package path and exact version number. This makes it easy to have multiple projects on the same machine where different versions of the same package are used.

- If run the `go mod verify`command from your terminal, this will verify that the checksum of the downloaded packages on your machine match the entries in `go.sum`.

Upgrading packages -- once package has been downloaded and added your `go.mod`file the package and version.

```sh
go get -u github.com/foo/bar
go get -u github.com/foo/bar@v2.0.0 # specific version
```

#### Removing unused packages -- 

Sometimes you might `go get`a package only to realzie later that you don’t need it anymore, when this happens you have got two choices. Could either run `go get`and postfix the package with `@none`like so:

```sh
go get github.com/foo/bar@none
# or if you've removed all references to the package in code
go mod tidy -v
```

### Creating a dbs connection pool

Now that the MySQL dbs is all set up and got a driver installed, the natrual next step is to conenct to the dbs from our web application. To do this need to use `sql.Open()`function like this:

```go
db, err := sql.Open("mysql", "web:pass@/snippetbox?parseTime=true")
if err != nil {
    //...
}
```

- First parameter to the `sql.Open()`is the driver name and the seond parameter is the *data source* name
- The format of the data source name will depend on which database and dirver you are testing. Typically.
- The `parseTime=true`parat of the DSN above is a driver-specific parameter which instructs your direver to convert SQL `TIME`and `DATE`to Go `time.Time`objects.
- And the `sql.Open()`func returns a `sql.DB`object, this isn’t a dbs connection -- it’s a *pool of many connections* -- this is an important difference to understand. Go just manages the connections in this pool as needed, automatically opening and closing connections to the database via the driver.
- The connection pool is safe for *Concurrent* access.
- The connection pool is intended to be long-lived. In a web app it’s normal to initialize the connection pool in your `main`and then pass the ppol to your handlers.

#### Usage in web app

```go
// To keep the main() tidy, just put the code for creating a connection
// pool into the separate openDB() function like:
dsn := flag.String("dsn", "root:root@/snippetbox2?parseTime=true", 
                   "MySQL data source name")

db, err := openDB(*dsn)
if err != nil {
    errorLog.Fatal(err)
}

func openDB(dsn string) (*sql.DB, error) {
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, err
	}
	if err = db.Ping(); err != nil {
		return nil, err
	}
	return db, nil
}
```

- Noticed how the import path for our driver is prefixed with an underscore.

  ```go
  import (
  	// ... others
  	_ "github.com/go-sql-driver/mysql"
  )
  ```

  This is cuz our `main.go`file doesn’t actually use anything in the `mysql`package, so if try to import it normally the Go compiler will raise an error. The `sql.Open()`function doesn’t actually create any connections, all it does is initliaze the pool for future use. Actual connection to the dbs are established lazily. Our app is only ever terminated by a signal interrupt or by `errorLog.Fatal()`.