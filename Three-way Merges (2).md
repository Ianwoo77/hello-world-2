# Three-way Merges (2)

Learn how to carry out a 3-way merge -- in the process, you will also go over an example of defining upstream branches and you will learn about what happens when you edit files *multiple* times in your working directory between commits.

### 3-way merges is important

They create merge commits and they may lead to merge conflicts -- *merge conflicts* arise when U merge two bracnhes where different changes have been made to the same parts of the same file(s), or if in one branch a file was just deleted that was edited in the other branch.

Fore, each work independently on our chapters, my coauthor finish their work on the fore `chapter_6`branch first and proceeds to merge their work into the `main`branch and push updated `main`to remote repository.

When fnish working on the 5 branch, which will present as commit D, also want to merge my work into the `main`. But coauthor lets me know that they have already added work to the remote `main`, first need to update my local `main`with the work that my coauthor added to the remote `main`. Fore, since it is not posible to follow the development history of the 5 branch to reach the `main`, this means that development histories of these branches have diverged.

Want to merge local 5 branch into the local main branch, which will be a 3-way merge, and then push updated `main`to the remote repository.

The other option is to carray out a merge in the remote through a hosting service feature called *pull request*. First, start lising colors that are *not* part of the rainbow in a new file called `othercolors.txt`in the `rainbow`directory like:

```sh
# nano a new file called othercolors.txt, and carry out
git add othercolors.txt
git commit -m "brown"
git log
```

Have made a brown commit in the `rainbow`repository.

### Defining upstream Branches

Mentioned that when U push work from a local branch to a remote, Git needs s way to know which remote branch you want to pus the work to. If no upstream branch is defined for the local branch you are just working on -- you will need to specify which remote branch to push to when you enter the `git push`command. If  a local branch has an upstream branch defined for it, can use `git push`directly.

Also know that upstream branches are *automatically* set up when U clone a repository, but *not* when a repostiory is initialized locally. The `rainbow`was initialized locally, and you have not defined any upstream branches yet.

To avoid specifying the remote repository shortname the branch every time u use the `git push`command on the `main`branch in your `rainbow`repository, can define an upstream branch for the `main`and thereafter simply use the `git push`command with not argument.

To set up the upstream branch U will use the `git branch`with the `-u`option -- which is short for the `--set-upstream-to`.

```sh
git branch -u <shortname>/<branch_name>
git branch -u origin/main
git push
git log
```

For this, have just learned how to define upstream branches in a local repository, and you have made the brown commit in the `rainbow`repository and pushed it to the remote repository. To end up in a situation where you will have to carry out a 3-way merge, there must be divergent development histories between two branches. Fore, next, friend will continuing working on the local `main`in their own local repository *without* fetching the changes U pushed to the remote `main`branch -- which will cause the local `main`in the `friend-rainbow`repository and the `main`branch in the `rainbow-remote`repository to diverge. while friend is working on the local `main`, you are also going to learn bout some characteristics of modified files in the working directory and what happens when you edit a file multiple times between commits.

## Under-optimized String concatenation

When it comes to concatenating strings, there are two main approach in Go -- fore: During iteration, the `+=`operator concatenates strings. With this imp, forget one of the core characteristics of a string -- its immutability. Therefore, each iteration doesn’t update s-- note -- *reallocate* a new string in memroy, which significantly impacts performance of this function. like:

```go
func concat(values []string) string {
    sb := strings.Builder{}
    for _, value := range values {
        _, _ = sb.WriteString(value)
    }
    return sb.String()
}
```

Need to note that `WriteString()`returns an error as the second -- purposely ignores that. `(int, error)`actually. Indeed, *this method will never return a non-nil*. `strings.Builder`just implements the `io.StringWriter`interface, which contains a single -- `WriteString(s string)(n int, err error)`-- to comply with this, must return an error. Using this `strings.Builder`we can also append:

- A byte slice using `Write`
- A single byte using `WriteByte`
- A single rune using `WriteRune`

Internally, `Strings.Builder`holds a byte slice -- each call to `WriteString`results in a call to `append`on this slice. And there will be two results -- First this struct shouldn’t be used concurrently -- as the calls to `append`would lead to race conditions. -- And if the future length of a slice is already known, should preallcoate it.

```go
func concat(values []string) string {
	var builder strings.Builder
	totalLen := 0
	for _, s := range values {
		totalLen += len(s)
	}
	builder.Grow(totalLen)

	for _, s := range values {
		_, _ = builder.WriteString(s)
	}
	return builder.String()
}
```

Note that if the future length of a slice is already known -- should preallcoate it -- for that purpose, `strings.Builder`exposes a method `Grow(n int)`to guarantee space for another `n`bytes. And `strings.Builder`is the recommended solution to concatenate a list of strings -- usually, this solution should be used within a loop.

### Unless string conversions

When choosing to work with a string or a `[]byte`-- But most I/O is actually done with `[]byte`-- fore, `io.Reader`.. Hence, working with strings means extra conversions. 

Fore, will implement a `getBytes()`function that takes an `io.Reader`as an input -- reads from it, and calls `sanitize`function -- the sanitization will be done by trimming all the leading.. space.

```go
func getBytes(reader io.Reader) ([]byte, error) {
    b, err := io.ReadAll(reader)
    if err != nil {
        return nil, err
    }
    // call sanitize
}
func snaitize(s string) string {
    return strings.TrimSpace(s)
}
```

So the good way is:

```go
func sanitize(b []byte) []byte {
    return bytes.TrimSpace(b)
}
```

So the `bytes`package also has a `TrimSpace`function to trim all the leading and trailing hite space.

### Substrings and memory leaks

Fore, will receive log messages as trings -- Each log will first be formatted with universally (UUID) followed by the message itself. want to just store these UUIDs in memory -- fore, to keep a cache of the latest `n`, should also note that these log messages can potentially be quite heavy.

```go
func (s store) handleLog(log string) error {
    if len(log)<36 {
        return errors.New("Log is not correctly formatted")
    }
    uuid := log[:36]
    s.store(uuid)
}
```

The std Go compiler does let them share the same backing array -- which is probably the best solution memory-wise and performance-wise as it prevents a new allocation and a copy.

`log[:36]`will create a new string referencing the same backing array -- therefore, each `uuid`string in memory not just 36 bytes but the number of bytes in the initial `log`string. Can fix this making a *deep* copy like;

```go
func (s store) handleLog(log string) error {
    if len(log)<36 {
        return errors.New("...not correctly formatted")
    }
    
    // performs a []byte and then a string conversion
    uuid := string([]byte(log[:36]))
    s.store(uuid)
}
```

So the copy is just performed by converting the substring into a `[]byte`and then into a `string`again. And after Go 1.18, the stdlib also includes a solution with `strings.Clone()`that returns a fresh copy of a string:
`uuid := strings.Clone(log[:36])`-- calling this also makes a copy of `log[:36]`into a new allocation, preventing a memrory leak.

### which type of reciever to use

When should we use value receiver -- when should be a pointer -- In many contexts, using a value or pointer receiver should be dictated not by performance but rather by other conditions that will discuss -- In Go, can attach either a value or a pointer receiver to a method -- With a value receiver, Go just makes a copy of the vluae and passes it to the method, any changes to the object just remain local to the method. The original object remains unchanged.

```go
type customer struct {
    balance float64
}
func (c customer) add(v float64) {
    c.balance += v
}
func (c *customer) add(operation float64) {
    c.balance += operation
}
func main() {
    c := customer {balance:100.0}
    c.add(50.)
}
```

A receiver *must* be a pointer -- 

- If the method needs to mutate the receiver -- note that this rule is also `true`if the receiver is a slice and a method needs to `append`lements like:

  ```go
  type slice []int
  func (s *slice) add(element int) {
      *s = append(*s, element)
  }
  ```

- If the method reciever contains a field that cannot be copied. Fore, a type part of the `sync`package.

And a receiver *should* be a poitner -- 

- If the receiver is a large object, using a pointer can make the call more efficient.

*Must* be a value -- 

- if we have to enforce a receiver’s immutability.
- If the receiver is a **map, func, or channel**

*Should* be a value

- If the receiver is a slice itself doesn’t have to be mutated
- If the receiver is just a small array or struct that is naturally a value type without mutable field like `time.Time`.
- If the reciveris a basic type such as `int...`

One case needs more discussion -- fore, design a different `customer`struct -- its mutable field aren’t part of the struct directly but are inside another struct like:

```go
type customer struct {
    data *data
}
type data struct {
    balance float64
}
func (c customer) add (operation float64) {
    c.data.balance += opreation
}

func main(){
    c := customer{data: &data {balance:100}}
    c.add(50.)
    // 150
}
```

Note that for this example, even though the receiver is a value, calling `add`changes the actual balance in the end.

### Using name result parameters

Named result parameters are an infrequently used option in Go -- When it considered appropriate to use named result parameters to make our API more convenient -- Refresh our memory about how they work -- When return parameters in a function or a method -- can attach names to these parameters and use them as regular variables. When a result parameter is named, it’s initialized to its zero value when the function/method begins. With named result parameters, can also call a naked return statement.

Consider the following interface -- which contains a method to get the cooridinates from a given address like:

```go
type locator interface {
    getCoordinates(address string) (float32, float32, error)
}
```

Cuz this is unexported, documentation isn’t mandatory. Just by reading this code, can U guess what these two `float32`results are -- Depending on the convention, latitude isn’t always the first element -- therefore, we have to check the implementation to understand the results.

In this case, should probably use named result parameters to make the code easier to read like:

```go
type locator interface {
    getCoordinates(address string) (lat, lng float32, err error)
}
```

With this new version, can understand the meaning of the method signature by looking at the interface.

Then pursue the question of when to use named result parameters with the method IMP -- should we also use named result parameters as part of the imp itself -- 

```go
func (l loc) getCoordinates(address string) (lat, lng float32, err error) {...}
```

In this specific case, having an expressive method signature can *also* help code readers.

Then -- another function signature that allows us to store a `Customer`type in a dbs -- like:

```go
func StoreCustomer(customer Customer) (err error) {...}
```

For this, naming the `error`parameter isn’t helpful and doesn’t help readers -- should not favor that. So, when to use named result parameters depends on the contet -- in most cases, if it’s not clear whether using them makes our code more readable, shouldn’t use named result parameters.

Also note that having the result parameters already initialized can be quite handy in some contexts. Fore:

```go
func readFull(r io.Reader, buf []byte) (n int, err error) {
    for len(buf)>0 && err == nil {
        var nr int
        nr, err := r.Read(buf)
        n += nr
        buf= buf[nr:]
    }
    return
}
```

Cuz both `n`and `err`are initialized to their 0 value, the implementation is just shorter.

## Creating validation Helpers

Are now in the position where our app is validating the form data according to our business rules and gracefully handling any validation errors -- And while the approach we’ve taken is fine as a one-off -- if your app has *many forms* then can end up with quite a lot repetition in your code and validation rules.

To help with validation throughout the rest -- create our small `internal/validator`package to abstract some of this behavior and reduce the boilerplat code in the handlers.

#### Adding a validator package

```go
package validator

import "strings"

// Validator Define a new
// Validator type which contains a map of validation errors.
type Validator struct {
	FieldErrors map[string]string
}

// Valid returns true if the FieldErrors map doesn't contain any entries
func (v *Validator) Valid() bool {
	return len(v.FieldErrors) == 0
}

// AddFieldError adds an error msg to the map
func (v *Validator) AddFieldError(key, message string) {
	// NOTE: need to initialize the map first
	if v.FieldErrors == nil {
		v.FieldErrors = make(map[string]string)
	}
	if _, exists := v.FieldErrors[key]; !exists {
		v.FieldErrors[key] = message
	}
}

// CheckField adds an error msg to the map only if not ok
func (v *Validator) CheckField(ok bool, key, message string) {
	if !ok {
		v.AddFieldError(key, message)
	}
}

// NotBlank returns true if a value is not an empty string
func NotBlank(value string) bool {
	return strings.TrimSpace(value) != ""
}

func MaxChars(value string, n int) bool {
	return utf8.RuneCountInString(value) <= n
}

// PermittedInt returns true if a value is a list of permitted integers
func PermittedInt(value int, permittedValues ...int) bool {
	for i := range permittedValues {
		if value == permittedValues[i] {
			return true
		}
	}
	return false
}
```

In the code defined a custom `validator`type which contains a map of errors -- the `Validator`type just provide a `CheckField()`method for conditionally adding errors to the map, and the `Valid()`method returns whether the errors map is empty or not.

#### Using helpers

Just putting the `Validator`to use -- in the `handlers.go`file -- 

```go
// Remove the explicit FieldErrors struct field and instead embed the Validator type
type snippetCreateForm struct {
    Title, Content string
    Expires        int
    validator.Validator
}

// in the handlers.go:
// Create an instance of the snippetCreateForm
form := snippetCreateForm{
    Title:   r.PostForm.Get("title"),
    Content: r.PostForm.Get("content"),
    Expires: expires,
}

// Cuz the Validator type is embedded by the struct, can call directly on it
// to execute our validation checks.
form.CheckField(validator.NotBlank(form.Title), "Title",
                "This field cannot be blank")
form.CheckField(validator.MaxChars(form.Title, 100), "Title",
                "This field cannot be more than 100 characters long")

form.CheckField(validator.NotBlank(form.Content), "Content",
                "This field cannot be blank")
form.CheckField(validator.PermittedInt(form.Expires, 1, 7, 365), "Expires",
                "This field must equal 1, 7 or 365")

// Then use the Valid() method to see if any of the checks failed
if !form.Valid() {
    data := app.newTemplateData(r)
    data.Form=form
    app.render(w, http.StatusUnprocessableEntity, "create.html", data)
    return
}
```

For now got an `internal/validator`pacakge with validation rules and logic that can be reused across our app.

### Automatic form parsing -- 

Another thing we can do to simplify our handlers is use a 3rd-party package like `go-playground/form`or `grilla/schema`to automatically decode the form data into `createSnippetForm`struct. Using an automatic decoder is *totally* optional -- but it can help to save you time and typing -- especially if your app has lots of forms, or need to process a very large form. Using the `go-playgroudn/form`package. Just like:

```sh
go get github.com/go-playground/form/v4
```

#### Using the form decoder

To get this working, the first thing that we need to do is initialize a new `*form.Decoder`in the main and make it avaiable to handlers as a denpendency like:

```go
type application struct {
	errorLog      *log.Logger
	infoLog       *log.Logger
	snippets      *models.SnippetModel
	templateCache map[string]*template.Template
	formDecoder   *form.Decoder
} // Add a formDecoder field to hold a pointer to a `form.Decoder`
```

Then in the `main()`func --

```go
//.. in main
// initialize a decoder instance...
formDecoder := form.NewDecoder()

app := &application{
    errorLog:      errorLog,
    infoLog:       infoLog,
    snippets:      &models.SnippetModel{DB: db},
    templateCache: templateCache,
    formDecoder: formDecoder,
}
```

Then in the `handlers.go`file and update it to use this new decoder like:

```go
type snippetCreateForm struct {
    Title               string `form:"title"`
    Content             string `form:"content"`
    Expires             int    `form:"expires"`
    validator.Validator `form:"-"`
}
// declare a new empty instance of the `snippetCreateForm`
var form snippetCreateForm

// Call the `Decode()` method of the form decoder, passing in the current
// request and *pointer* to our snippetCreateForm struct. this will essentially
// fill our struct the relevant values from the HTML form.
err = app.formDecoder.Decode(&form, r.PostForm)
if err != nil {
    app.clientError(w, http.StatusBadRequest)
    return
}
```

For this, can use simple struct tags to define a mapping between our HTML form and the *destination* data fields, and unpacking the form data to the destination now only requries us to write a few lines of code. Importantlly, type conversions are handled automatically too. Can see in the code above.

When call the `app.formDecoder.Decode()`it requires a *non-nil* as the target decode destination. If try to pass in sth that isn’t a non-nil pointer, the `Decode()`will return a `form.InvalidDecodeError`.