# 5-Stage of the Rebase Process

```sh
git restore --staged readme.md
git status # 1 modified and 1 modified (red)
```

- The `git status`output shows that the updated version of the `othercolors.txt`file is still in the staging area, whereas the updated versino of the `readme.md`file has been unstaged and is no longer in the staging area.
- Friend unstaged the `readme.md`-- so the version in the staging area went back 
- The udpated version of the `readme`is still in the staging area
- the version of `readme`is in the working directory

```sh
git commit -m "black"
git status # modified readme.md (read)
```

Now, friend add the changes that they made to the `readme.md`

```sh
git add readme.md
git commit -m "rainbow"
git log
```

The version of the `readme.md`file in the staging area is now vB, which is the version that is part of the `rainbow`commit. Just saw how your friend was able to add files to and remove them from the staging area in order to craft exactly the commits they wanted -- the local `main`in the `rainbow`repository and the local `main`in the `friend-rainbow`repository now have divergent development histories.

### Preparing to Rebase

To rebase a branch U first have to fetch all the work that has been done on the branch that you want to rebase onto.

```sh
# still in friend repository
git fetch
git log --all
```

For this, friend fetched the `gray`commit from the remote repository, and the `origin/main`remote-tracking branch and updated to point ot it. For now, the `origin/main`remote-tracking branch in the `friend-rainbow`repository represents the lastest version of the remote `main`.

#### 5-stages

To initiate the rebase proces, use the `git rebase`command -- git will then carry out the 5 stages of the process itself - the only time you have to actively get involved is if there are any merge conflicts -- 

1. Find the common ancestor -- The common ancestor fore will be M2 mrege commit
2. Store info about the branches involed in the Rebase -- Save the changes introduced by each commit of the branch you are on to a temporary area. It will also save additional info in this temporary area.
3. Reset HEAD -- Git will reset `HEAD`to point to the same commits as the branch you are rebasing onto. For this example, will reset `HEAD`to the same commit that the `origin/main`remote-tracking branch is pointing to.
4. Apply and commit the changes - Git will apply the set of changes from each commit in turn, making a commit after it applies each set. First it will apply the changes introduced by the BI and then the RA.
5. Switch onto the rebase Branch -- At last, Git will make the branch you rebased point to the last commit it reapplies, and will check out that brnch so the HEAD points to it.

*Git carries out the entire process itself*, all U need to do is initiate it with the `git rebase`command -- Also mentioned that the only time you will need to get involved in the rebase proces if Git encounters merge conflits.

### Rebasing and Merge Conflicts

When U integrate two branches where different changes have been made to the smae parts in the same file(s), or if in one branch a file was deleted that was edited in the other branch. Git will carry out the entire rebase process independently -- unless it encounters merge conflicts. In this case, must stp in and resolve them, and the process for resolving merge conflicts while rebasing is similar to the process when doing 3-way merge.

When resolving merge conflicts in a 3-way merge, all the merge conflicts are presented to U at the same time -- once U have resolved all the conflicts and added all the updated files to the staging area,  U make the final merge comit. By contrast, in the process of rebasing, As Git applies the changes from each commit one by one, it will pause the rpocess if it encounters merge conflicts in any reapplied commit. This means that *have to* resolve merge conflicts several times when rebasing, depending on how many commits contain merge conflicts.

Once U are done resolving the mrege conflicts in a specific commit, need to add the updated files to the staging and then instruct Go to resume the base process by entering `git rebase --continue`. Git will then continue rebasing the rest of the commits. As with a merge, if at any point during the process of resolving merge conflicts in a rebas U decide you don’t want to continue the rebase process, can choose to stop or abort the process by using the `git rebase --abort`. this will return al your files to the state they were in before the rebase.

```sh
git rebase --continue # continue with the rebase process having resovled merge conflicts
git rebase --abort # stop the rebase process and go back to the state before the rebase.
```

### Rebasing a Branch in Practice

```txt
a378d48a2e52d6b25e6b63ac317fd5e386828fc7 # rainbow
054d98f68ad9c9e15914be8237112b00cbc0a1ca # black
```

```sh
git rebase origin/main # could not apply ... black
git status # interactive rebase in progress -- both modified oreadme.md
```

- The rebase operation was interrupted cuz when Git was applying the changes that were included in black commit
- The `git rebase`command hints to you that u must *reslove all conflicts* manually.
- `git status`command also shows U info about the rebase and which files U need to resovle merge conflicts in.

using *code* to accept both and :

```sh
# accept all changes then
git add readme.md
git status
git rebase --continue
# then accept the commit message then quit
git log
```

For this - 

- `git status`output informs U *all conflicts fixed* then run the `git rebase --continue`
- `git log`ouput indicates that the rebase process created a new rainbow commit and a new black commit.

The commit it hashes in your repositoies will be different from the onces in this. Cuz commit are just unique.

## JSON and the monotonic clock

When marshaling or unmarshaling a struct that contains a `time.Time`type, can sometimes face unexpected comparison erors -- it’s helpful to examine `time.Time`to refine our assumptions and prevent possible mistakes.

#### map of `any`

When unmarshaling data, can provide a map instead of a struct -- the rationale is that when the keys and values are uncertain, passing a map give us some flexibility instead of a static struct -- there is a rule to bear in mind to avoid wrong assumptions and possible panics. like:

```go
func main() {
	b := []byte(`{"id":32, "name": "foo"}`)
	var m map[string]any
	err := json.Unmarshal(b, &m)
	if err != nil {
		panic(err)
	}
	fmt.Println(m)
}
```

For this, cuz use a generic `map[string]any`-- it parses all the different fields automatically. However, there is an important gotcha -- to remember if we use a map of `any`-- any numeric vlaue, regardless of whether it contains a decimal, is converted into `float64`type.

### Common SQL mistakes

The `database/sql`package provdies a generic interface around SQL - and SQL-like dbs, also fairly common to see some patterns or mistakes while using this package.

#### Forgetting that `sql.Open`doesn’t necessarily establish connections to a dbs

When using the `sql.Open`, one common misconception is mosconceptio is expecting this func to establish connections to the dbs. Useness like;

```go
func main(){
    dsn := "user:password@tcp(localhost:3306)/testdb"
    db, err := sql.Open("mysql", dsn)
    if err != nil {
        log.Fatal(err) // does not return but calls os.Exit(1) determinates the app immediately
    }
    err = db.Ping()
    if err != nil {
        log.Fatal(err)
    }
}
```

When using `sql.Open()`, one common misconception is expecting this function to establish connection to a dbs -- 

```go
db, err := sql.Open("mysql", dsn)
if err != nil {
    return err
}
```

The docmentation -- *Open may just validte its arguments without creating a connection to the dbs.*

Actually, the behavior depends on the SQL driver used -- *for some drivers*, `sql.Open`does not establish a connection, it’s ony a preparation for later use. Therefore, the first connection to the dbs may be established lazily.

In some cases, want to make a service ready only after we know that all the dependencies are correctly set up and reachable. If we don’t know this, the service may acept traffic despite an erroneous configuration. If we want to ensure that the function that uses `sql.Open`also guarantees that the underlying dbs is just reachable, use the `Ping()`

```go
if err := db.Ping(); err != nil {return err}
```

`Ping()`just *forces* the code to establish a connection that ensures that the data source name is valid and the dbs is reachable. Note that an alternative to `Ping`is `PintContext`-- which asks for an additional context.

#### Forgetting about connection pooling

Just as the default HTTP client and server provdie default behaviors that may not be effective in production, It’s essential to understand how dbs conenctions are handled in Go. `sql.Open()`returns an `*sql.DB`struct -- this struct doesn’t represent a single dbs connection, instead it represents a pool of connections. A conenction in the pool can have two states -- 

- Already used
- Idle

It’s also important to remember that creating a pool leads to 4 available config paameters that we may want to *override* -- each of these parameters is an exported method of `*sql.DB`. Fore -- `SetMaxOpenConns`, `SetMaxIdleConns`, `SetConnMaxIdleTime`and `SetConnMaxLifeTime`.

#### Using Prepared statements

A prepared statement is a feature implemented by many *SQL dbs* to execute a repeated SQL statement -- Internally, the SQL statement is precompiled and separated from the data provided -- two main benefits -- 

- *Efficiency* -- the statement doesn’t have to be recompiled
- *security* -- this approach reduces the risks of SQL injection attacks.

Therefore, if a statement is repeated, we should use prepared statements -- whould also use prepared statements in untrusted context. To use prepared statements, instead of calling `Query()`of `*sql.DB`call the `Prepare`method like:

```go
stmt, err := db.Prepare("SELECT * FROM ORDER WHERE ID=?")
if err != nil {
    return err
}
rows, err := stmt.Query(id)
```

We prepare the statement and then execute it while providing the arguments - the first output of the `Prepare`method is na `*sql.Stmt`-- which can be reused and run concurrently, when the statement is no longer needed, must be cloaed using the `Close()`method.

#### Handling `null`values

The next mistake is to mishandling `null`values with queries -- like:

```go
rows, err := db.Query("SELECT DEP, AGE from EMP where ID=?", id)
if err != nil {
    return err
} 
// defer close the rows
var (
	department string
    age int
)
for rows.Next(){
    err := rows.Scan(&departement, &age)
    if err != nil {
        return err
    }
}
```

Use `Query()`to execute a query, then iterate over the rows and use `Scan()`to copy the column into the values pointed to by the `department`and `age`pointers. Fore -- *Scan error on column index 0 name `DEPARTMENT`*-- NULL string is not supported -- Here the SQL driver raises an error cuz the department value is equal to `NULL`-- if a column can be nullable, there are two options to prevent `Scan`from returning an error. First, declare `department`as pointer:

```go
var (
	department *string
    age int
)
for rows.Next(){
    err := rows.Scan(&departements, &age)
}
```

For this, provide `scan`with the address of a poitner. When the value is `NULL`, then `departement`will be `nil`. and the other approach is to use one of the `sql.NullXXX`types fore `sql.NullString`like:

```go
var (
	department sql.NullString
	)
```

For this, `sql.NullString`is a wrapper on top of a string, It contains two exported fields -- `String`contains the string value, and `Valid`conveys whether the string isn’t `NULL`. The following wrappers are accessible like:

`sql.NullString, NullBool, NullInt32, NullInt64, NullFloat64, NullTime`

Both approaches work -- with `sql.NullXXX`expresing the intent more clearly. And there is no *effecitve difference*, thought people might want to use *NullString* cuz it is so command and perhaps expresses the intent more clearly.

#### Handling row interation errors

Another common mistake is to miss possible errors from iterating over rows -- like:

```go
func get(ctx context.Context, db *sql.DB, id string) (string, int, error) {
	rows, err := db.QueryContext(ctx, "SELECT DEP, AGE FROM EMP"+
		"WHERE ID=?", id)
	if err != nil {
		return "", 0, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.Printf("Falied to close row %v\n", err)
		}
	}()

	var (
		department string
		age        int
	)
	for rows.Next() {
		err := rows.Scan(&department, &age)
		if err != nil {
			return "", 0, err
		}
	}
	return department, age, nil
}
```

This is not enough-- have to know that the `for rows.Next(){}`loop can break either when there are no more rows or when an error happens while preparing the next row -- following a row iteration -- should call `rows.Err`to distinguish between the two cases -- like:

```go
func get(...) (string, int, error) {
    //...
    for rows.Next() {
        //...
    }
    if err := rows.Err(); err != nil {
        return "", 0, err // if rows.Next() loop stopped cuz of an error
    }
    return department, age, nil
}
```

This is the best practice to keep in mind -- cuz `rows.Next()`can stop either when we have iterated over all the rows or when an error happens while preparing the next row, should check `rows.Err()`following the iteration.

## Using embedded files

One of the headline features of the Go 1.16 release was the `embed`package -- which makes it possible to embed external files into your Go program itself. This feature is really nice cuz it makes it possible to create. Go program that are complete self-contained and have everything that the need to run as part of the binary executable Just like:

```go
package ui
import "embed"

//go embed "html" "static"
var Files embed.FS
```

And the important line here is the comment `//go:embed "html" "static"`

Actually is a special *comment directive* -- When app cimplied, this comment directive instructs Go to store the files from the `ui/html`and `ui/static`folders in an `embed.FS`embedded filesystem referenced by the global variable `Files`.-- There are a few details -- Can only use the `go:embed`directive on global variables at package level. If want to include these files u should use the `all:`prefix like `go:embed "all:static"`

#### Using the static files

```go
func (app *application) routes() http.Handler {
    //...
    fileServer := http.FileServer(http.FS(ui.Files))
    
    // no longer need to strip the prefix from the request URL
    router.Handler(http.MethodGet, "static/*filepath", fileServer)
}
```

#### Embedding HTML templates

Next, update the `cmd/web/templates.go`file so that our template cache uses the embedded HTML template files from the `ui.Files`instead of the ones on disk like-- 

- `fs.Glob()`returns a slice of filepaths mathching a global pattern, it’s effectively the same as `filepath.Glob()`function that we used
- `Template.ParseFS()`can be used to parse the HTML templates from an embedded filesystem into a template set. This is effectively a replacement for both the `Template.ParseFiles()`and the `Template.ParseGlob()`methods that u used earlier.

```go
func newTemplateCache() (map[string]*template.Template, error) {
	cache := map[string]*template.Template{}

    // Use of fs.Glbo() to get a slice of all filepaths in the ui.Files embedded filesytem which match the 
    // pattern 'html/pages/*html'
	pages, err := fs.Glob(ui.Files,"html/pages/*.html")
	if err != nil {
		return nil, err
	}

	// Loop through the page
	for _, page := range pages {
		// Extract the file name from the full file path
		name := filepath.Base(page)
		
		// Create a slice containing the filepath patterns for the templates
		patterns := []string {
			"html/base.layout.html",
			"html/partials/*.html",
			page,
		}

		ts, err := template.New(name).Funcs(functions).ParseFS(ui.Files, patterns...)

		if err != nil {
			return nil, err
		}
		
		cache[name] = ts
	}

	return cache, nil
}
```

### Using Generics

Go 1.18 is the first version of the language to support *generics* -- also known by the more technical name of *parametric polymorphism*. With generics, it’s possible to write a single `contains`function that will work for `string`and `int`and all other *comparable* type like:

```go
func contains[T comparable](v T, s []T) bool {
    if i := range s {
        if v== s[i]{
            return true
        }
    }
    return false
}
```

#### When to use generics -- 

For now at least -- should aim to use generics judiciously and cautiously -- I know that might sound a bit boring -- but generics are new language feature and best-practices aound writing generic code are still being established. If U work on a tem, or write code in public -- it’s also work keeping in mind that not all Go developers will necessarily be familar with how generic code workd yet -- Writing generic code can be really useful in certain scenarios -- 

- Writing repeated biolerplate code for different types.
- Writing code and find yourself reaching for the `any`type. An example of this might be when are creating a DS.

Don’t want to use generics when -- 

- If it makes your code harder to understand or less clear.
- If all the types that you need to work with have a common set of methods. For this should use `interface`.
- Insted default to writing simple `non-generic`.

#### Using in our App

Perhaps the only thing in our code -- `validator.go`file -- just like the `PermittedValue()`function -- can use each time that we want to check that a user-provided value in a set of allowed values. Just like:

```go
// PermittedValue Replaces PermittedInt() with a generic function
func PermittedValue[T comparable](value T, permittedValues ...T) bool {
	for i := range permittedValues {
		if value == permittedValues[i] {
			return true
		}
	}
	return false
}
```

Then can update our `snippetCreatePost`handler to use the new `PermittedValue()`.

Testing --  Like structing and organizing your app code, there is no single *right* way to structure and organize your tests in Go-- But there are some conventions -- patterns and good-practices that you can follow. going to add tests for a selection of the code in our app, with the goal of demonstrating general syntax for creating tests and illustrting some patterns that you can reuse in wide-variety of applications.

- How to create and run table-driven unit tests and sub-tests in Go.
- How to unit test your HTTP handlers and middleware
- How to perform *end-to-end testing* of your web app routes, middleware and handlers.
- How to create *mocks* of your dbs models and use them in unit tests
- A pattern for test *CSRF-protected HTML* form submissions
- A pattern for test instance of the MySQL to perform integration tests
- How to easily calculate and profile *code coverage* for your tests.

