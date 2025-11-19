# Bypassing Schema validation

In certain cases, may have to override a collection’s schema validation rules, when you are restoring data from a backup into a collection that is governed by validation rules, fore, there is a chance that older documents from the backup won’t comply with the newer validation criteria.

Bypassing schema validaiton can be managed on a per-operation basis -- if choose to bypass schema validation when inserting an invalid document, any subsequent updates to the document *must also bypass schema validation* or ensure that the document meets the existing validaiton criteria. Can bypass validation using the following commands and methods --- 

- `findAndModify()`
- `insert, update`
- And `$out`, `$merge`aggregation stages

Fore, suppose that want to insert a document that does not comply with schmea requirements, Perhaps the `flight_id`does not start with `FL`or the `airline.id`less than 1 -- instead of modifying the document to meet the schema criteria, can bypass the validation as -- just like:

```js
db.routes.insertOne(
    {
        flight_id: "12345", // does not meet schema
        airline: {
            id:0 // also does not meet
        },
        src_airport: {
            code: "JFK"
        },
        dst_airport: {
            code: "LAX",
        }
    },
    // bypass the schema validation
    {bypassDocumentValidation: true}
)
```

Again, this command worked only on MongoDB shell. By using this option, temporarily disable validaiton for this paritucular option -- bypassing these rules in necessary sometimes, although it carries the risk of introducing invalid documents into the collection.

#### Schema antipatterns

Should avoid antipattern when working with MDB, recognizing anitpatterns can help U to prevent performance problems and maintain the efficiency of your dbs. here are some key antipatterns -- 

- Massive Arrays -- storing large, unbounded arrays in documents can cause inefficient queries and performance degradation.
- Bloated documents -- Overloading document with excessive data that is not frequently accessed together can slow read operations.
- Massive number of collections -- creating too many collections, especially if many are rerely used, degrade performance.
- Unnecesssay inexes -- maintaining indexs that are rarely used or redundant consumes memory and can slow write operations.
- Separating data accessed together -- sorting related data in separate documents or collections can lead to frequent joins and complex queries.

##### Building aggregation pipelines -- 

The Mdb aggregation framework is a powerful tool for processing and analyzing data within MDB, it allows U to create complex data transformation and aggregation pipelines to perform operations such as filtering, grouping, and transformation data efficiently. This framework is essential for extracting meaningful insights from large data sets, making it a crucial component for developers and data analysts working with Mdb -- The aggregation framework supports full-text search and vector search cababilities in Atlas.

With the aggregation framework, can construct multi-stage pipelines that process data in a sequence of steps, Each stage performs an operation on the data and passes the result to the nex stage. This approach allows sophiticated data manipulation and anaysis, providing flexibility and performance beyond simple queries. Fore, calculating average, sum, organize data by categories, or generate reports..Another benefit is that when a complex transformation is broken into mre manageable parts, the entire process become easier to understand, maintain, and debug. The framework support a wide range of operators and expiressions, enabling to perform complex calculations and transformations.

## Write the test First

```go
func TestWallet(t *testing.T) {
	t.Run("Deposit", func(t *testing.T) {
		wallet := Wallet{}
		wallet.Deposit(Bitcoin(10))
		got := wallet.Balance()
		want := Bitcoin(10)
		if got != want {
			t.Errorf("got %d want %d", got, want)
		}
	})
	t.Run("Withdraw", func(t *testing.T) {
		wallet := Wallet{balance: 20}
		wallet.Withdraw(Bitcoin(10))
		got := wallet.Balance()
		want := Bitcoin(10)
		if got != want {
			t.Errorf("got %d want %d", got, want)
		}
	})
}
```

Then write enough code to make it pass -- 

```go
func (w *Wallet) Withdraw(amount Bitcoin) {
	w.balance -= amount
}
```

##### Refactor 

Also, there is some duplication in our tests, lets refactor that out -- 

```go
func TestWallet(t *testing.T) {
	assertBalance := func(t *testing.T, wallet Wallet, want Bitcoin) {
		t.Helper()
		got := wallet.Balance()
		if got != want {
			t.Errorf("got %d want %d", got, want)
		}
	}
	t.Run("Deposit", func(t *testing.T) {
		wallet := Wallet{}
		wallet.Deposit(Bitcoin(10))
		assertBalance(t, wallet, Bitcoin(10))
	})
	t.Run("Withdraw", func(t *testing.T) {
		wallet := Wallet{balance: 20}
		wallet.Withdraw(Bitcoin(10))
		assertBalance(t, wallet, Bitcoin(10))
	})
}
```

But, what should happen if U try to `Withdraw`more than is left in the account -- for now, our requirement is to assume there is not an overdraft facility-- So, how do we signal problem when using `Withdraw`-- In Go, if want to indicate an error it is idiomatic for your func to return an `err`just like:

```go
func (w *Wallet) Withdraw(amount Bitcoin) error {
	w.balance -= amount
	return nil // just for testing
}
t.Run("Withdraw insufficient funds", func(t *testing.T) {
    startingBalance := Bitcoin(20)
    wallet := Wallet{startingBalance}
    assertBalance(t, wallet, startingBalance)
    err := wallet.Withdraw(Bitcoin(100))
    if err == nil {
        t.Error("Wanted an error but didn't get one")
    }
})
```

Then write enough code to make it pass -- just like -- 

```go
func (w *Wallet) Withdraw(amount Bitcoin) error {
	if amount > w.balance {
		return errors.New("oh no")
	}
	w.balance -= amount
	return nil
}
```

#### Continue refactoring -- 

Make a quick test helper for our error check to improve the test’s readability -- just like:

```go
assertError := func(t testing.TB, err error) {
    t.Helper()
    if err == nil {
        t.Error("got an error but didn't want one")
    }
}

t.Run("Withdraw insufficient funds", func(t *testing.T) {
    startingBalance := Bitcoin(20)
    wallet := Wallet{startingBalance}
    assertBalance(t, wallet, startingBalance)
    assertError(t, wallet.Withdraw(Bitcoin(100)))
})
```

##### Write the test first

Update our helper for a `string`to compare against -- 

```go
assertError := func(t testing.TB, got error, want string) {
    t.Helper()
    if got == nil {
        t.Fatal("didn't get an error but wanted one")
    }
    if got.Error() != want {
        t.Errorf("got %q, want %q", got, want)
    }
}

t.Run("Withdraw insufficient funds", func(t *testing.T) {
    startingBalance := Bitcoin(20)
    wallet := Wallet{startingBalance}
    assertError(t, wallet.Withdraw(Bitcoin(100)),
                "cannot withdraw, insufficient funds")
    assertBalance(t, wallet, startingBalance)
})
```

We have introduced `t.Fatal`which will stop the test if it is called. This is cuz we don’t want to make any more assertions on the error returned if there isn’t one aournd. Just refactor like:

```go
func (w *Wallet) Withdraw(amount Bitcoin) error {
	if amount > w.balance {
		return errors.New("cannot withdraw, insufficient funds")
	}
    //...
}
```

##### Refactor -- 

Have duplication of the error message in both the test code and the `Withdraw`code -- would be really annoying for the test to fail if someone wanted to re-word the error and it’s just too much detail for our test. Don’t really care waht the exact word is -- just some kind of meaningful error around withdrawing is returning given a certain condition. In Go, errors are values, so can refactor it out into a variable and have a single souce of truth for it.

```go
func (w *Wallet) Withdraw(amount Bitcoin) error {
	if amount > w.balance {
		return ErrInsufficientFunds
	}
	w.balance -= amount
	return nil
}

func (b Bitcoin) String() string {
	return fmt.Sprintf("%d BTC", b)
}

// ErrInsufficientFunds means a wallet does not have enough Bitcoin to perform
var ErrInsufficientFunds = errors.New("cannot withdraw, insufficient funds")
//...
// for test file
func assertNoError(t testing.TB, got error) {
	t.Helper()
	if got != nil {
		t.Fatal("got an error but didn't want one")
	}
}

// in the test file internally
t.Run("Withdraw insufficient funds", func(t *testing.T) {
    wallet := Wallet{Bitcoin(20)}
    err := wallet.Withdraw(Bitcoin(10))
    assertBalance(t, wallet, Bitcoin(10))
    assertNoError(t, err)
})
```

#### Unchecked errors -- 

Whilst the Go compiler hleps U a lot, sometimes there are things you can still miss and error handling can sometimes be tricky -- There is one scenario we have nto tested -- run the following in a terminial to install `errcheck`

```sh
go install github.com/kisielk/errcheck@latest
/pointers$ errcheck .
# outut: wallet_test.go:28:18:   wallet.Withdraw(Bitcoin(10))
```

What this is telling us is that we have not checked the error being returned on that line of code. That line of code on my computer corresponds to our normal withdraw scenario cuz we have not checked that if the `Withdraw`is successful than an error not returned.

```go
func TestWallet(t *testing.T) {
	t.Run("Withdraw insufficient funds", func(t *testing.T) {
		wallet := Wallet{Bitcoin(20)}
		err := wallet.Withdraw(Bitcoin(10))
		assertBalance(t, wallet, Bitcoin(10))
		assertNoError(t, err)
	})

	t.Run("Deposit", func(t *testing.T) {
		wallet := Wallet{}
		wallet.Deposit(Bitcoin(10))
		assertBalance(t, wallet, Bitcoin(10))
	})
	t.Run("Withdraw with funds", func(t *testing.T) {
		wallet := Wallet{balance: 20}
		err := wallet.Withdraw(Bitcoin(10))
		assertNoError(t, err)
		assertBalance(t, wallet, Bitcoin(10))
	})
}
```

## Build tags

The most common way to classify tests is using building tags -- a build tag is a special comment at the beginning of a Go file -- 

```go
//go:build foo

package bar
```

This file contains the `foo`tag, Note that one package may contain multiple files with different build tags. Build tags are used for two primary use cases, first can use as a conditional option to build an application, fore, if want a source file to be included only if `cgo`is enabled, can add `//go:build cgo`build tags. Second, if want to categorize a test as in integeration test, can add a specific build tag. For an example `db_test`file just like:

```go
//go:build integration 

package db

import "testing"

func TestInsert(t *testing.T) {
    //...
}
```

If run `go test`insdie this package without any options, it will run only the test files without build tags -- 

```sh
go test -v .
```

If run the `go test`inside this package without any options, will run only the test files without building tags. However, if we provide the integration tag, running `go test`will also include `db_test.go`-- just like:

```sh
go test --tags=integration -v .
```

So, running tests with speicifc tag include both the files without tags, and the files matching this tag, what if we want to run *only* integration tests -- A possible way is to add a negation tag on the unit test files, fore, using `!integration`means we want to include the test file only if the integration is *not* enabled -- like:

```go
//go:build !integration

package db

import "testing"

func TestContract(T *testing.T) {...}
```

- Running `go test`with the `integration`flag runs only the integration tests
- Running `go test`without the `integration`runs only the unit tests

