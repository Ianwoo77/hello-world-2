# `$regex`Operator

```js
{field: {$regex: /pattern/, $options: 'options'}}
{"field": {"$regex": "pattern", "$options": "options"}}
{field: {$regex: /pattern/options}}
```

Available options for additional operators are -- 

- `i`-- Case insensitivity
- `m`-- Muliline matching, treating start and end `^$`anchor to match line beginnings and ends
- `x`-- Extended regex to ignore whitespace within the regex pattern
- `s`-- Allow the dot `.`to match newline characters
- `u`-- Unicode support.

Suppose that U want to find all routes within the `routes`collection that are operated by airlines with `Air`in their names -- irrespective of case sensitivity. Can accomplish this by extending the following Mdb query -- 

```js
db.routes.find(
	{'airline.name': {$regex: 'ari', $options: 'i'}}
)
```

This query matches any airline name that include `Air`.. Or maybe need to identify all routes departing from airports whose codes starts with `B, C`fore:

```js
{'src_airport': {$regex: '[^BC]', $options: 'i'}}
```

Fore, distinguish by 3-letter code ending in x -- fore:

```js
{'dst_airport': {$regex: 'X$', $options: 'i'}}
```

Can also use `$size`operator to query for arrays by numbers of elements -- the following l

```js
db.customers.find({
    accounts: {$size: 6}
})
```

Using the `$elemMatch`to define multiple conditions for the elemens of an array, ensuring that at least one element within the array meets all these conditions.

```js
db.customers.find({
    accounts: { $elemMatch: { $gt: 300000, $lt: 400000 } }
})
```

This query will return all documents from the `customers` collection where the `accounts` field is an **array** that contains **at least one element** that is **both** greater than $300,000 **and** less than $400,000.

And, if U want to find a particular item in the array, you can do by indicating its index using this -- 

```js
db.customers.find{
    'accounts.1': 324287
}
```

For this, just corresponds to the second item in the array, as array indexes start counting from 0. Can also combine several conditions in q query to find documents that meet all criteria -- using `.0`targets the first one

```js
db.customers.find({
  "tier_and_details.0df078f33aa74a2e9696e0520c1a828a.active": true,
  "accounts.0": { $gte: 300000 }
})
```

#### Querying embedded/nested documents

Offers two methods for querying embedded documents. The first method using `.`to query fields wihtin nested documents. And the second requires matching the entire embedded or nested document. Fore: `routes`collection:

```js
[
    {
        _id:'...',
    	airline: {
            id: 413,
            name:...
        }
    }
]
```

##### Querying on a nested field with `.`notation -- 

```js
use sample_training
db.routes.find({"airline.name": "American Airlines", "airline.id": 413})
```

It uses dot notation to access the nested `name`and `_id`fields within the `airline`object -- Dot notation is used cuz the ariline is an embeddd document within the `routes`collection. The approch effectively narrows the search to entries that match the specified criteria exactly. Can also use dot notation to target the `price`field nested within each `prices`document of the route records -- like:

```js
db.routes.find({'prices.price': {$lt: 3000}})
```

##### Matching the embedded/nested document

The second method to query embedded or nested documents -- matching the entire embedded document exactly -- this method uses an query filter in whcih U specify the field and the complete nested documents as the value.

```js
db.routes.find({
    'airline': {
        id: 413,
        name: 'American Airlines',
        'alias': 'AA',
        iata: 'AAL',
    }
})
```

This query returns documents with an airline embedded document that exactly matches the *provided structure and field order*.

##### Querying an array of embedded documents

Can concatenate the name of array with a `.`followed by the name of the field inside the nested documents -- 

```js
db.routes.find({
    "prices.price": {$gte: 1000}
})
```

Then the following example selects all in whcih the first element in the prices array meets specific condition on the `price`field.

```js
db.routes.find(
{
    'prices.0.pice': {$gte: 650}
}
)
```

And to use the `$elemMatch`to specify multiple critiera on an array of embedded dcouments so that at least one embedded document satisfies all the specified criteria, can construct a query like -- 

```js
db.routes.find({
    prices: {
        $elemMatch: {
            class: 'business',
            price: {$lt: 3000}
        }
    }
})
```

The query uses the `$elemMatch`operator to find documents in which at least one element of the `prices`array is a business class with a price below 3000.

#### Sorting, skiping and limiting -- 

In mdb, using the `sort, skip, limit`operations to manage and navigate results efficiently. Like:

```js
// can be set to ascending or descending
db.routes.find().sort({'stops': -1})
// skip first 5
db.routes.find().skip(5);
// restricts the number of documents returned by the query
db.routes.find().limit(10)

// These are often combind to facilitate detailed data retreival strategies -- like;
db.routes.find().sort({'stops': -1}).skip(10).limit(5)
```

## Testing

Testing is a crucial aspect of a project’s lifecycle, if offers countless benefits -- building confidence in an app, acting as code documenation,  and making refactoring easier, compared to some other languages, Go has strong primitives for writing tests, throughout this -- look at common mistkes that make the testing process brittle.

### Categorizing tests -- 

The testing pyramid is a model that groups tests into different categories -- Unit tests occupy the base of pyramid -- most tests should be unit tests - cuz they are cheap to write, fast to execute, and highly deterministric. A common technique is to be explicit about which kind of tests to run -- fore, depending on the project lifecycle stage, may want to run only unit tests or run all tests in the project, not categorzing tests menas potentially wasting time and effort and losing accuracy about the scope of a test.

#### Build tags

The most common way to classify tests is using build tags -- a build tag is a special comment at the beginning of a Go file -- followed by an empty line -- like:

```go
//go: build foo

package bar
```

Note that one package may contain multiple files with different build tags.

1. Use a build tag as a conditional option to build an app, fore, want a source file to be included only if `cgo`is enabled, can add the `//go:build cgo`build tgs
2. Want to categorize a test as an integration test -- for as an integration test like:

```go
//go:build integration

package db 
func TestInsert(t *testing.T) {
    //...
}
```

The benefit of using building tags is that we can select which kinds of tests to exectue -- fore, Assume a package contains two test files -- 

- The file just created `db_test.go`
- Another doesn’t build tg named `contract_test.go`.

If run `go test`insdie this package -- will run only the test files without build tags

```sh
go test -v .
```

However, if provide the `integration`tag -- running will *also* include the `db_test`file --

```sh
go test --tags==integration -v .
```

And, what if we want to run *only* integration test -- Possible way to do is to add *negative* tag -- like:

```go
//go:build !integration

package db
//...
```

Using this -- 

- Running `go test`with the `integration`flag runs only the integration tests
- Running `go test`without the `integration`runs onlyh the unit tests.

#### Environment variables

Fore, can implment the `TestInsert`test by checking a specific environment variable and potentially skipping the test:

```go
func TestInsert(t *testing.T) {
    if os.Getenv("INTERRATION")!= "true" {
        t.Skip("skiping integration test")
    }
    // ...
}
```

#### short mode

Related to their speed -- may have to dissociate short-running from long-running tests -- fore, would like to categorize the slow test so don’t have to run it every time -- just like:

```go
func TestLongRunning(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping long-running test")
    }
}
```

Using the `testing.Short`, mcan retreive whether short mode was enabled while running the test. Then we Skip to skip the test -- And to run tests using short mode, have to pass `-short`flag like:

```sh
go test -short -v .
```

For the result, the `TestLongRunning`is explicitly skipped when the tests was executed.

- Using build tags at the test file level
- Using environment variables to mark the specific test
- Based on the test pace using short mode.

### An example in Go

Here is a func which greets `name`in particular language like:

```go
func Hello(name, language string) string {
	if language == "es" {
		return "Hola, " + name
	}

	if language == "fr" {
		return "Bonjour, " + name
	}

	// imagine dozens more languages
	return "Hello, " + name
}

// having dozens of if not good
// so refactor the code like:
var greetings = map[string]string {
	"es":"Hola",
	"fr": "Bonjour",
	// ... etc
}
func Hello(name, language string) string {
	return fmt.Sprintf(
		"%s, %s",
		greeting(language),
		name,
	)
}

func greeting(language string) string {
	if greeting, ok := greetings[language]; ok {
		return greeting
	}
	return "hello"
}

```

#### When refactoring code U must not be changing behavior - 

This is very important -- If are changing behavior at the same time U are doing two things at once, Learn to break systems up into different files/packges/functions/etc cuz know trying to understand a big blob of stuff is hard. Those who choose not to write tests will typically be reliant on manual testing -- for anything than a small proj this will be a tremendous time - So in order to safely refactor you need unit tests cuz they provide -- 

- Confidence U can reshape code without worrying aobut changing behavior
- Documentation for humans as to how the system should behavie
- Much faster and more reliable feedback then manual testing

```go
func TestHello(t *testing.T) {
	got := test1.Hello("Chris", "es")
	want := "Hola, Chris"
	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}
```

Just ask yourself, how often do you hve to change your tests when refactoring -- over the years -- many projects with very good test ooverage and yet the engineers are reluctant to refactor cuz of the perceived effort of changing tests.

#### Bringing these concepts together -- 

- Refactoring
- Unit tests
- Unit design

What we can start to see is that these facets of software design reinforce each other.

- Refactoring -- If we have to do manual checks, we need more tests.
- Unit tests -- give a safety net to refactor, verify and document the behavior of our units.

#### Why TDD -- 

We need to work interactively, starting small and evolving the software so that we get fast, feedback on the design of our softwre and how it works with real users -- TDD enforces this approach -- TDD addresses the laws that -- other lessions hard learned through hishory by encouraging a methodology of constantly refactoring and delivering interativey. 

##### Small steps

- Writes a small tests for a small amount of desired behvior
- Check the test fals wtih a clear error
- Write the minimal amount of code to make the test pass
- Refactor
- Repeat

#### Go modules-- 

The next step is to run the tests -- enter `go test` in the terminal, if the tests pass, then are probably using an eariler using an eariler version of Go, however, if you are using 1.16.. like  Fore `go mod init hello`in the terminal. For the go module file -- tells the `go`tools essential info about your code.

##### Declaring variables -- 

`t.Errorf`-- Calling `Errorf()`on our `t`which print out a messsage and fail the test. The `f`stands for format allows us to build a string with values inerted into the placeholder value `%q`.

##### go doc

Another quality of life feature of Go is documentation -- Can launch the docs locally by running the `godoc -http:8000`.

```sh
go install golang.org/x/tools/cmd/godoc@latest
godoc -http:8000
```

##### Constants -- 

Constants are defined like:

```go
const englishHelloPrefix = "Hello, "

func Hello(name string) string {
	return englishHelloPrefix + name
}
// start by a new failing test like:
func TestHello(t *testing.T) {
	t.Run("Saying hello to people", func(t *testing.T) {
		got := test1.Hello("Chris")
		want := "Hello, Chris"
		if got != want {
			t.Errorf("got %q want %q", got, want)
		}
	})
	t.Run("Say 'Hello, World' when an empty string is supplied",
		func(t *testing.T) {
			got := test1.Hello("")
			want := "Hello, World"
			if got != want {
				t.Errorf("got %q want %q", got, want)
			}
		})
}
```

Here are introducing another tool in our testing arsenal, subtests -- simetimes it is useful to group tests a thing and then have subtests describing different scenarios. It is just important that your tests are clear specifications of what the code needs to do -- 

```go
func TestHello(t *testing.T) {
	assertCorrectMessage := func(t testing.TB, got, want string) {
		t.Helper()
		if got != want {
			t.Errorf("got %q want %q", got, want)
		}
	}
	t.Run("Saying hello to people", func(t *testing.T) {
		got := test1.Hello("Chris")
		want := "Hello, Chris"
		assertCorrectMessage(t, got, want)
	})
	t.Run("Say 'Hello, World' when an empty string is supplied",
		func(t *testing.T) {
			got := test1.Hello("")
			want := "Hello, World"
			assertCorrectMessage(t, got, want)
		})
}
```

For this, have refactored our assertion into a func, this reduces duplication and improves readability of our tests. For helper functions -- it’s a good idea to accept a `testing.TB`which is an interface that `*testing.T`and `*testing.B`both satisfy. So can call helper functions from a test, or bechmark.

The `t.Helper()`is needed to tell the test suite that this method is a helper. By doing this, when it fails the line nunber reported will be in our function call rather inside our testing helper. This will help other developers track down probelm easiler. Now that we have a well-written failing test, fix the code using an `if`like:

```go
func Hello(name string) string {
	if name == "" {
		name = "World"
	}
	return englishHelloPrefix + name
}
```

