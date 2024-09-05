# git merge, git fetch

```sh
git push
git status
```

`git log`output indicates that in the `firend-rainbow`repository, the `origin/main`remote-tracking branch has updated to point to the green commit.

### Incorporating changes from the remote repository

The reason the local `main`branch and `origin/main`remote-tracking branch in the `rainbow`repostiory still point to the yellow commits is cuz local repository do not automatically update with new data from remote repostiories. Just as U need to take explicit actions to update a remote repostiory with changes in a local repostiory, need to take explicit actions to update local branches and remote-tracking branches.

Incorporating changes from a remote branch into a local branch is a two-step proecss -- 

1. fetch changes from the remote repository
2. integrate those changes into the local branch.

#### Fetching changes from remote repository

In Git, use the term `fetch`or `fetching `to refer to the process of downloading data from a remote repository to local repository -- and the command we we to do this is `git fetch`

```sh
git fetch <shortname> # down data from the <shortname>
git fetch # from with shortname origin
```

Note that the `git fetch`command affects only remote-tracking branches -- it does not affect local branches.

```sh
git log --all
git fetch
git log --all # HEAD-> feature
```

The local `main`branch and `origin/main`remote-tracking branch are pointing to the yellow commit. For this, `origin/main`point to the Green, but, `main, origin/feature HEAD`to yellow. For now need the second step in the process integrating

#### Integrating changes into a local branch

Once have fetched the changes from a remote repository and updated the remote-trcking branches in a local repository, ready to update a local branch. Git provides two ways to integrate changes -- `merging`and `rebasing`. And also there are fast-forward merges and thee-way merges -- in this section, going to merge `origin/main`remote tracking branch into the local main branch in the `rainbow`repository. The types of branches involved in the merge are different, but the *process of executing the merge is the same*. Just switch to `main`and executing the merge like:

```sh
git switch main
git merge origin/main
git log
```

In the `git log`, the output indicates the local `main`points to the green commit.

### Deleting branches

In the `rainbow`repository, still have the local `feature`and the `origin/feature`remote-tracking branch -- for simplicity, moving forward U will work on the `main`-- so want to delete these two -- can use the `git push <shortname> -d <branch_name>`to delete the remote `feature`and the and the `origin/feature`remote-tracking branch in the `friend-rainbow`repository in one go.

Now here is no remote `feature`any more, so to delet the `origin/feature`in the `rainbow`should use the `git fetch`command with `-p`(prune). will delete any remote-tracking branches that corresponds to remote branches that have been deleted in the remote repository.

```sh
git fetch -p # remove remote-trcking that correspond to deleted remote branches and download from the remote
```

And to delete the local `feature`branch, will use the command used earlier like:

```sh
git branch --all # *main feature remote/origin/feature
git fetch -p # delete origin/feature
git branch --all # *main feature remotes/origin/main
git branch -d feature
git branch --all
```

- In step 2, deleted the `origin/feature`remote-tracking branch
- in step 4, deleted the local `feature`
- at last the `git branch --all`ouptut indicates that you no longer have local `feature`or an `origin/fature`.

## Maps and memory leaks

When working with maps in Go, need to understand some important characteristis of how a map grows and shrinks -- delve this to prevent an issue that can cause memory leaks -- 

`m := make(map[int][128]byte)`-- each value of `m`is an array of 128 bytes, will do the following map like:

1. Allocate an empty map
2. add 1M elements
3. Remove all the elements and run a GC

```go
n := 1000000
m := make(map[int][128]byte)
for i:=0; i<n; i++ {
    m[i]=randBytes()
}
for i:=0; i<n; i++ {
    delete(m, i)
}
runtime.GC()
runtime.KeepAlive(m)
```

At first, the heap size is minimal -- then it grows significantly after having added 1M elements to the map, but if we expected the heap size to decrease after removing all the elements -- this isn’t how maps work in Go.  In the end, even though the GC has collected all the elements, the heap size is still 293MB.

Discussed -- a map is just composed of 8-element buckets under the hood, a Go map is a pointer to a `runtime.hmap`struct -- the struct contains multiple fields, include a `B`field, giving the number of buckets in the map:

```go
type hmap struct {
    B uint8
}
```

When we remove 1M elements, -- B is till 18 -- hence the map still contains the same number of buckets. The reason is that the number of buckets in a map cannot shrink -- Therefore, removing elements from a map doesn’t impact the number of existing buckets, it just zeroes the slots of the buckets. Shrink to 293MB cuz the elements were collected.

What are the solutions if we don’t want to manually restart our serivce to clean the amount of memory consumed by the map -- One solution could be to re-create a copy of the current map at a reglar pace. Fore, every hour, can build a new map, copy all, and release the previous one.

Another is just to `map[iint]*[128]byte`.

### Comparing Values correctly

Comparing values is a common operation in software development -- our first instinct might be to use the `==`. This shouldn’t always be the case -- When is it appropriate to use ==, and what are the alternatives --  fore:

```go
type customer struct {
    id string
}
func main(){
    cust1 := customer{id:"x"}
    cust2 := customer{id:"x"}
    cust1 == cust2 // true
}
```

But, what happens if we make a slight modification to the `customer`struct like a slice inside -- 

```go
type customer struct {
    id string
    operations []float64
}
//...
cust1== cust2 // invlalid operation
```

The problem relates to how the == and != operators work -- these two doesn’t work with slices or maps. It’s essentially to understand how to use `==`and `!=`to make comparisons effectively.

- *Channels* -- Compare two channes were created by the same call to `make`or if both are `nil`.
- *interfaces* -- Compare have identical dynamic types and equal valus or both `nil`
- *pointers* -- same value in memory or if both `nil`
- *structs and arrays* -- compare are composed of similar types

Also need to know the possible issues of using `==`and `!=`with `any`types -- fore:

```go
var a any =3
var b any =3
a==b // true

// but if two customer types
var cust1 any= customer {id:"x", operations: []float64{1.}}
var cust2 any= customer {id:"x", //same}
cust1==cust2 // painc runtime error uncomparable type
```

*Reflection* is a form of metoprogramming -- and it refers to the ability of an application to introspect and modify its structure and behavior. In Go, can use `reflect.DeepEqual`-- this function reports whether two elements are *deeply equal* by recursively traversing two values. The element it accepts are basic types plus `arrays, structs, slices, maps, pointers, interfaces, functions`.

NOTE -- `reflect.DeepEqual`has specific behavior depending on the type we provide, before using, like:

```go
cust1 := customer{...} cust2:= customer{...}
fmt.Println(reflect.DeepEqual(cust1, cust2))  // True
```

There are two things to keep in mind when using `reflect.DeepEqual`-- 

1. Makes the distinction between an empty and a `nil`collection
2. Which introspects value at *runtime* to discover how they are formed. It has a performance penalty. Should do a few benchmarks locally with structs of different sizes, generally, is about 100 times slower than `==`.

And if performance is a crucial factor, another option might be to implement our own comparison method -- fore:

```go
func (a customer) equal (b customer) bool {
    if a.id != b.id{
        return false
    }
    if len(a.operations) != len(b.operations) {
        return false
    }
    for i:=0; i<len(a.operations); i++ {
        if a.operations[i]!=b.operations[i] {
            return false
        }
    }
    return true
}
```

### Elements are copied in range loops

Just is a convenient way to iterate over various data structures -- we don’t have to handle an index and the termination state -- Go developers may forget or be unaware of how a `range`loop assigns values, leading to common mistakes.

A `range`loop allows iterating over different data structures -- `string Array PointerToArray Slice Map Channel` -- 

#### Value copy

Understanding how the value is handled during each iteration is criticial for using a `range`loop effectively -- see how it works with a concrete example like:

```go
type account struct {
    balance float32
}
// create a slice
accouns := []account {
    {balance: 100.},
    {balance: 200.},
    {balance: 300.},
}
for _, a := range accounts {
    a.balance+=1000
}
```

Answer is still `[{100}, {200}, {300}]`-- in this example, the `range`loop does not affect the slice’s content. In Go, everything we assign is a copy -- 

- If assign the result of a function returning a `struct`-- it performs a copy of that struct.
- If assign the result of a function returning a pointer, it performs a copy of the memory address.

Iterating over each `account`element results in a struct copy being assigned to the variable `a`- therefore incrementing the balance with `a.balance+=1000`just mutates only the value variable (a) not an element in the slice. Fore:

```go
for i := range accounts {
    accounts[i].balance += 1000
}
for i :=0; i<len(accounts); i++ {
    accoutns[i].balance +=100
}
```

Updating slice elements -- third option -- 

```go
accounts := []*account {
    {balance:100}
    //...
}
```

### How arguments are evaluated in `range`loops

The `range`loop syntax requires an expression -- fore `for i, v := range exp`. Fore:

```go
s := []int {0,1,2}
for range s {
    s = append(s, 10)
}
```

The provided expression is evaluated only once, before the beginning of the loop, in this context, evaluated means the provided expression is copied to a temporary variable, and then `range`iterates over this variable. The `range`loop uses this temporary variable, the original slice `s`also updated during each iteration. 

Each step results in appending a new element -- however, after 3 steps, have gone over all the elements, indeed, the *temporary slice used by `range`remains 3-length slice*, hence, the loop completes after 3 iterations.

And the behavior is different with a classic `for`

```go
s := []int{0,1,2}
for i:=0; i<len(s); i++ {
    s=append(s,10) // never terminate.
}
```

## Handlers.go

Now that’s done, there are a few changes we need to make to our `handlers.go`file like: Cuz the `httprouter`matches the `/`path exactly, can now remove the manual check.

```go
func (app *application) snippetView(w http.ResponseWriter, r *http.Request) {
	// When httprouter is parsing a request, the values of any named parameters will be
	// stored in a request context
	params := httprouter.ParamsFromContext(r.Context())
	
	id, err := strconv.Atoi(params.ByName("id"))
	if err != nil || id < 1 {
		app.notFound(w) // Use the notFound() helper.
		return
	}

	//...
}

// for this, just a placehodler for now
func (app *application) snippetCreate(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Create a new snippet..."))
}

func(app *application) snippetCreatePost(w http.ResponseWriter, r *http.Request) {
	// check if the request method is a POST is now superfluous and can be
	// removed, cuz this is done automatically by httprouter
	title := "O snail"
	content := "O snail\nClimb Mount Fuji,\nBut slowly, slowly!\n\n– Kobayashi Issa"
	expires := 7
	id, err := app.snippets.Insert(title, content,expires)
	if err != nil {
		app.serverError(w, err)
		return
	}
	// update the redirect path to see the new URL
	http.Redirect(w, r, fmt.Sprintf("/snippet/view/%d", id), http.StatusSeeOther)
}
```

Finally need to update the tble in the home.page file like:

`<td><a href="/snippet/view/{{.ID}}">{{.Title}}</a></td>`

### Custom error handlers

Might also like to try making the forllowing two requests -- fore `http://localhost:9999/snippet/view/99`and `http://localhost:9999/missing`, can see a bit strange -- both requests results a 404, but they slightly different. This is happening cuz the first request ends up calling to our `app.notFound()`whereas the second is returned automatically by the `httprouter`when no matching found.

`httprouter`makes it easy to set a custom handler for dealing 404 like:

```go
// create a handler function which wraps our `notFound` helper
// and then assign it as the customer handler for 404 not found
router.NotFound=http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    app.notFound(w)
})
```

#### Additional Information

Conflicting route patterns -- It’s important to be aware that `httprouter`doesn’t allow conflicting route patterns which potentially match the same request. Fore `GET /foo/:name`or `GET /foo/*name`

Customizing `httprouter`behavior -- The `httprouter`package provides a few configuraiton options that you can use to customize the behavior of your application further, including enabling *trailing slash redirects* and enable *automatic URL path cleaning*.

#### Handler naming

Also like to emphasize that there is no right or wrong way to name your handlers in Go --  In this project, we will follow the convention of postfixing the names of any handlers that deal with `POST`requsts with the word POST. FORE:

- `GET`- `/snippet/create` - `snippetCreate`-- display HTML form for creating a new snippet
- `POST`- `/snippet/create` - `snippetCreatePost`- Create a new snippet

Alternatively, could postfix the names of any handlers that dispaly forms wtih the word like:

- `GET`-- `/snippet/create`-- `snippetCreateForm`
- `POST`- `/snippet/create` - `snippetCreate`

### Processing forms

In this section of the book we are going to focus on allowing users of our web application to create new snippets via a HTML form which -- the high-level workflow of processing this form will follow a std `POST-Redirect-GET`pattern:

1. The user is shown the blank form when they make a `GET`request
2. The user completes the form and it’s submitted to the server via a `POST`request to `/snippet/create`
3. The form data will be valiated by our `snippetCreatePost`handler -- if there are any validation failures the form will be re-displayed with the appropriate form fields highlighted. And if it passes our validation checks, the data for the new snippet will be added to the dbs and then we will redirect the user to `/snippet/view/:id`.

As part of this you will learn -- 

- How a parse and access from data sent in a `POST`request.
- Some techniques for performing common *validation checks* on the form data
- A user-friendly pattern for altering the user to validation failures and re-populating form fields
- How to keep your handlers clean by using helpers for form processing and validation.