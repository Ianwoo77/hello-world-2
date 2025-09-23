# Fluid layouts

The 3rd and the final principle of responsive design is *fluid layout* -- refers to the use of containers that grow and shrink according to the width of the viewport. This is in contrast to a fixed layout -- where columns are defined using pixels or ems. In a fluid layout, the main page container typically doesn’t have an explicit width, May have left and right padding or `auto`left and right margins to add breathing room between edges and the edges sof the viewport.

Inside the main containers, any columns are designed using a percentage. Also note that a web page is responsive by default.

#### Add styles for large viewport

Note the padding along the left and right edges has been increased from 1 to 4em. Just like:

```css
media(min-width: 800px) {
    .page-header {
        padding: 1em 4em;
    }
}

@media(min-width: 800px) {
    .hero {
        padding: 7em 6em;
    }
}

@media (min-width: 800px) {
    main{
        padding: 2em 4em;
    }
}

@media (min-width: 800px) {
    .nav-menu{
        padding-inline: 4em;
    }
}
```

#### Dealing with tables -- 

This layout is made up of `<table>`...but the declaration `display:block`has been applied, overriding their normal table.

### Cascade layers and nesting

fore, most stylesheets apply a basic link styles like:

```css
a:any-link { // for this, 0,1,1
    color: var(--brand-blue);
    font-weight: bold;
}
```

```html
<a class="button" href="/about">Read me</a> for this, 0, 1, 0
```

So the problem arises when try to style that button with a simple `.button`selector, which is lower.

#### Defining layers -- 

A better way to manage this with modern CSS using *cascade layers* -- allows U to *partition* your styles into a series of groups called *layers*. Any styles in a higher-priority *layer* will override those from a lower-priority layer, regardless of selector specificity.

Layers are defined using the `@layer`at-rule -- fore:

```html
<!doctype html>
<html lang="en-US">
  <head>
    <style>
      @layer global {
        :root {
          --brand-blue: #0063cc;
        }

        a:any-link {
          color: var(--brand-blue);
          font-weight: bold;
        }
      }

      @layer theme {
        .button {
          display: inline-block;
          padding: 0.5rem;
          color: white;
          background-color: var(--brand-blue);
          font-weight: normal;
          text-decoration: none;
        }
      }
    </style>
  </head>
  <body>
    <p><a href="#">normal link</a></p>
    <p><a href="#" class="button">Button link</a></p>
  </body>
</html>
```

Note that in this case, `<a class="button">`would have a normal font weight and white text on a blue background.

In terms of the cascade, layers are considered after origin and inline styles but before specificity. WIhtin the same layer, all the normal rules of specificity still apply.

#### Anonymous layers

U are not required to name your layers. Can crete anonymous layers by omitting the layer name -- just like:

```css
@layer {
    :root {
        --brand-blue: #0063cc;
    }
    a:any-link {
        color: var(--brand-blue);
        font-weight: bold;
    }
}

@layer {
    .button {
        display: inline-block;
        //...
        font-weight: normal;
    }
}
```

For this, the second layer will takes precedence over the first cuz it is defined later in the stylesheet.

#### Layer order and priority

Layers provide us with means of indicating the priority of various parts of our stylesheet. A stylesheet typically starts with some general styles for the page as whole, like, fore, font settings and colors. Well-named layers help document the intent of a set of styles.

Cascade layers are prioritized based on the *order* layers first apper in the stylesheet. Fore:

```css
@layer global {
    :root {
        --brand-blue: #0063cc;
    }
}
@layer theme {
    .button {
        //...
    }
}
@layer global {
    // adds more styles to the global layer
    a:any-link {
        //...
    }
}
```

Note that if you reference a layer twice like upper, its priority is not changed by the second reference. When have a such paln, you can declare multiple layers up front -- This is done by comma separating each layer name in a single `@layer`at-rule. Fore, the following line of CSS declares 4 layers in increasing order of precedence:

```css
@layer reset, global, theme, components;
```

Any styles that are added to the declarations that exists in the reset layer ... finally, styles in the components layer will override all 3 prior layers.

Highly recommend declaring all your layers like at the very beginning of your styles.

##### `!important`in layers

If have `@layer reset, global, theme, components`-- in the case styles on the components will take precedence over styles on the others, but important styles on the global will just take priority over important styles on the componetns layers.

And the `revert`keyword allows U to remove any values applied to a property in the author styles. Similarly, the `revert-layer`allows U to remove any values applied in the current layer.

```css
@layer global, theme;
@layer global {
    :root {
        //...
    }
}

.blog-content: a:any-link {
    display: revert-layer; // reverts to the global styles.
}
```

## When to wrap an error

- Adding additional context to an error
- Marking error as a specific error

See different ways in Go to return an error we receive -- like:

```go
func Foo() error {
    err := bar()
    if err != nil {
        //...?
    }
}
```

For the first option to return this error directly -- , and before Go 1.13, wrap an error, the only option wihtout using an external lib was to create a custom error type like:

```go
type BarError struct {
    Err error
}
func (b BarError) Error() string {
    return "b failed "+ b.Err.Error()
}
```

For this, insted of returning `err`directly, wrapped the error into a `BarError`like:

```go
if err != nil {
    return BarError {Err: err}
}
```

So to overcome the cumbersome --

```go
if err != nil {
    return fmt.Errorf("bar failed: %w", err)
}
```

This code wraps the source error and add additional context without having to create another error type. For this, cuz the source error remains available, a client can unwrap the parent error and then check whether the source error was of a specific type or value.

The last option is to use the `%v`directive like:

```go
if err != nil {
    return fmt.Errorf("bar failed: %v", err)
}
```

The difference is that the error itself isn’t wrapped. For this, we transformed it into another error to add context. note that the info about the source of the problem remains availble, however, a caller can’t unwrap this error and check whether the source was `bar error`.

Wrapping an error makes source error available for callers -- it means introducing potential coupling. To make sure the clients don’t rely on sth that consider implementation details, -- the error returned should be transformed, not wrapped, in such case, using `%v`.

### Checking error type accurately

When use the `%w`approach, also essential to change our way of checking for a specific error type. Fore, design a DB system, our implementation can fail in two cases -- 

- If the `ID`invalid -- 400, BadRequest
- If querying fails -- 503 - ServiceUnavailable.

```go
type transientError struct {
    err error
}
func(t transientError) Error() string{
    return fmt.Sprintf("transient error: %v", t.err)
}
func getTransactionAmount(transactionID string) (float32, error) {
    if len(transactionID) != 5{
        return 0, fmt.Errorf("id is invalid: %s", transactionID)
    }
    amount, err := getTransactionAmountFromDB(transactionID)
    if err!= nil {
        return 0, transientError{err:err}
    }
    return amount, nil
}
```

For the `getTransactionAmount`returns an error using `fmt.Errorf`if the identifier is invalid. however, if getting the transaction amount from the DB fails, `getTransactionAmount`wraps the error into a `transientError`type.

```go
func handler(w http.ResponseWriter, r *http.Request) {
    transactionID := r.URL.Query().Get("transaction")
    
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        switch err := err.(type) {
        case transientError:
            http.Error(w, err.Error(), http.StatusServiceUnavailable)
        default:
            http.Error(w, err.Error(), http.StatusBadRequest)
        }
        return
    }
    // write resp
}
```

For this, just valid, however, if want to perform a small *refactoring* of `getTransactionAmount`, The `transientError`will be returned by `getTransactionAmountFromDB`instead of `getTransactionAmount`. Just like:

```go
func getTransactionAmount(transactionID string) (float32, error) {
    // check the transaction ID validity
    amount, err := getTransactionAmountFromDB(transactionID)
    if err != nil {
        // wraps instaed of returning directly
        return 0, fmt.Errorf("failed to get transaction %s: %w", transactionID, err)
    }
    return amount,nil
}

func getTransactionAmountFromDB(transactionID string) (float32, error) {
    //...
    if err != nil {
        return 0, transientError{err: err}
    }
}
```

If run this code, just returns a 400 regardless of the error case -- Cuz `transientError`was returned by `getTransactionAmount`, after the refactoring, `transientError`is now returned by `getTransactionAmountFromDB`. What `getTransactionAmount`returns isn’t a `transientError`directly, it’s an error just wrapping `transientError`-- there fore `case transientError:`now false.

For that exact purpose, Go 1.13, came with a directie to wrap an error and a way to check whether the wrapped error is of a certain type with `errors.As`-- Just like:

```go
func handler(w http.ResponseWriter, r *http.Request) {
    amount, err := getTransactionAmount(transactionID)
    if err != nil {
        if errors.As(err, &transientError{}) {
            http.Error(w, err.Error(), http.StatusServiceUnavailable)
        }else {
            http.Error(w, err.Error(), http.StatusBadRequest)
        }
        return
    }
}
```

Got tid of the `switch`caset type in this new ersion -- use `error.As()`-- requires the second arg to be a *pointer*. Otherwise, the function will compile but **panic**.

### Checking an error value accurately

This is similar to the previous -- but with *sentinel* errors -- namely, error values.

```go
import "errors"
var ErrFoo = errors.New("foo")
```

For this, in general, the convention is to start with `Err`followed the error type. Note that a sentienl error conveys an *expected* error. Fore, want to design a `Query`that allows us to execute a uery to a dbs. And this method returns a slice of rows -- how should handle the case when no rows are found -- 

- Return a sentinel value -- fore, a `nil`slice
- Return a specific error that a client can check.

Can classify this as an *expected* error, cuz passing a request that returns no rows is allowed. Conversely, situations like network issues and connection polling errors are *unexpected* errors. And in the stdlib, can find:

- `sql.ErrNoRows`-- returned when a query doesn’t return any rows
- `io.EOF`-- by an `io.Reader`when no more input is available.

And -- 

- Expected errors should be designed as error values, like `ver ErrFoo= errors.New("foo")`
- And unexpected ones should be designed as error types -- `type BarError struct{}`, implementing `error`

```go
err := query()
if err != nil {
    if err == sql.ErrNoRows {
        //...
    }
}
```

Just as discussed, If an `sql.ErrNoRows`is wrapped using the `fmt.Errorf()`and the `%w`directive, `==`will fail. So

```go
err := query()
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {
        //...
    }
}
```

Using `errors.Is()`instead of the `==`allows the comparison to work even if the `error`is wrapped using `%w`.

## Performing concurrent computations on the `default`case

A useful scenario is to use the `default`select case for concurrent computations and then use a channel to signal when we need to stop. To avoid unncessary computation, want to stop the execution of each goroutine when any goroutine makes a correct guess. To achiee, can use a channel to notify all other goroutines when one execution discovers the pwd. Can just use the `close()`operation on a channel to act like a signal being *broadcast* to all consumers. 

In the function, generate all pwd guesses from the given range, represented by the `from`and `upto`.

```go
func guessPassword(from int, upto int, stop chan struct{}, result chan string) {
	for guessN := from; guessN < upto; guessN++ {
		select {
		case <-stop:
			return
		default:
			if toBase27(guessN) == passwordToGuess {
				result <- toBase27(guessN)
				close(stop)
				return
			}
		}
	}
	fmt.Printf("Not found betwen [%d, %d]\n", from, upto)
}
```

Now can create several goroutines executing the previous listing -- each will try to find the correct pwd within a certain range. Fore:

```go
func main() {
	finished := make(chan struct{})
	passwordFound := make(chan string)
	for i := 1; i <= 387420488; i += 10000000 {
		go guessPassword(i, i+10000000, finished, passwordFound)
	}
	fmt.Println("password found:", <-passwordFound) // block until password found
	close(passwordFound)
	time.Sleep(1 * time.Second)
}
```

#### Timout out on Channels

Another useful scenairo is blocking for only a specified amount of time, waiting for an operation on a channel. Just like in the previous, want to check to see whether a message has arrived on a channel. This is useful in many situations when channel operations are time sensitive.

Can implement by using a separate goroutine that sends a message on an extra channel after a specified timeout. This will give us the effect of blocking on the `select`until any of the channels becomes available or the timout occurs. The `time.Timer`type in Go provides us with this. Fore:

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		time.Sleep(seconds)
		messages <- "Hello"
	}()
	return messages
}

func main() {
	t, _ := strconv.Atoi("6")
	messages := sendMsgAfter(3 * time.Second)
	timeoutDuration := time.Duration(t) * time.Second
	fmt.Printf("waiting for message for %d seconds...\n", t)
	select {
	case msg := <-messages:
		fmt.Println(msg)
	case tNow := <-time.After(timeoutDuration):
		fmt.Println("timeout", tNow.Format("15:04:05"))
	}
}
```

#### Writing to a channels with `select`

Can also use the `select`when we need to write messages to channels -- not just when we are reading messages from channels -- `Select`can combine read or write blocking channel operations together-- for 100 random prime numbers. Fore, giving a stream of random numbers, picks out any prime number finds and outputs it on another stream.

```go
func primesOnly(inputs <-chan int) <-chan int {
	results := make(chan int)
	go func() {
		for c := range inputs {
			isPrime := c != 1
			for i := 2; i < int(math.Sqrt(float64(c))); i++ {
				if c%i == 0 {
					isPrime = false
					break
				}
			}
			if isPrime {
				results <- c
			}
		}
	}()
	return results
}
```

The answer is to use a `select`statement to both feed in the random numbers and read the primes -- like:

```go
func main() {
	numbersChannel := make(chan int)
	primes := primesOnly(numbersChannel)
	for i := 0; i < 100; {
		select {
		case numbersChannel <- rand.Intn(10000000) + 1:
		case p := <-primes:
			fmt.Println(p)
			i++
		}
	}
}
```

#### Disalbing `select`cases with `nil`channels

In Go, can assign `nil`values to channels, this has the *effect of blocking the channel from sending or receiving anyting*.

```go
func main() {
    var ch chan string = nil 
    ch <- "Message" // block forever
}
```

The same logic applies to `select`statements -- trying to send or receive from a `nil`on a `select`has the same effect of blocking the case using that channel. Developing accounting software that receives sales and expense amounts from various sources -- At the close of business, want to output the toal profit or loss for that day.

```go
func generateAmounts(n int) <-chan int {
	amounts := make(chan int)
	go func() {
		defer close(amounts)
		for i := 0; i < n; i++ {
			amounts <- rand.Intn(100) + 1
			time.Sleep(100 * time.Millisecond)
		}
	}()
	return amounts
}
```

Every time we consume from a *closed* channel, will eturn the *default* dta type without blocking. This is also applied to `select`cases. One solution to this problem is to have both the sales and expense goroutine output onto the same channel and then close the channel only when both goroutines are done.

Another solutin would to change the channel into `nil`whenever it is closed. Reading from a channel alwys returns two values -- message and flag telling us if the channle is *still open*. So in the `main`:

```go
func main() {
	sales := generateAmounts(50)
	expenses := generateAmounts(40)
	endOfDayAmount := 0
	for sales != nil || expenses != nil {
		select {
		case sale, moreDate := <-sales:
			if moreDate {
				fmt.Println("sale of:", sale)
				endOfDayAmount += sale
			} else {
				sales = nil
			}
		case expense, moreData := <-expenses:
			if moreData {
				fmt.Println("expense of:", expense)
				endOfDayAmount -= expense
			} else {
				expenses = nil
			}
		}
	}
	fmt.Println("end of day profit and loss:", endOfDayAmount)
}
```

In this, once both channels are closed and set to `nil`, exit the `select`loop and output the `end-of-day`balance.