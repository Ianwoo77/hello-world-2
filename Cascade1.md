# Cascade1

When two or more rules target the same element on your page, the rules may provide conflicting declarations.

1. Stylesheet origin - where the styles come from. Your styles are applied in conjunction with the browser’s default styles.
2. Inline styles -- whether a declaration is applied to an element via the HTML *style* attribute or a CSS selector.
3. Layer -- can be defined in layers
4. Selector specificity -- when take precedence over with.
5. Scope proximity -- Whether the styles are scoped to a portion of the DOM
6. Source order -- order in which styles are declared in the stylesheet.

#### Stylesheet Origin

The styles you add to your page are called *author* styles. Also *user* styles -- customizations added by the *end user*, and the *user-agent* styles -- are the browser’s *default* styles.

##### User-Agent Styles

Fore, a `list-style-type`of `disc`to produce the bullets.

```css
#main-nav {
    margin-top: 10px;
    list-style: none;
}

#main-nav li {
    display: inline-block;
}

#main-nav a {
    color: white;
    text-decoration: none;
}
```

`color: red !important;`

##### inline styles

```html
<li>
	<a href="specials" class="featured"
       style="background-color: orange;">
    	Specials
    </a>
</li>
```

##### Selector Specificity

*Specificity* is a feature of CSS that is often not readily apparent. IDs - classes - most tag names. Note the *pseudo-class* selectors and attribute selectors each have the same specificity as a class selector. Fore `[type=“input”]`, and the universal selector `*`and the combinators `>, +, ~`have no effect on specificity.

Fore, when tied to apply the orange background using the `.featured`selector, it didn’t work, the selector `#main-nav`has an ID that overrides the class selector. The quickest fix is to add an `!important`to the declaration you want to favor. so:

```css
#main-nav a {
    color: white;
    background-color: #13a4a4;
    ...
}

.featured {
    background-color: orange !important; /* make the declaration imporant, now higher-priority */
}
```

Or:

```css
#main-nav .featured {
    background-color: orange; /* now increases the specificity to 1,1,0 */
}
```

##### Source order

If all the other criteria are the same, then the declaration that appears later, or appears in a stylesheet included later on the page, takes precedence.

Link styles -- Should go in a certain order -- cuz source order affects the cascade -- 

```css
a:link {
    background-color: blue;
}
a:visited {
    background-color: purple;
}
a:hover {
 	//...
}
a:active{
    color: red;
}
```

Note, can use the `:any-link`to target links that match either `:link`or `:visited`, like:

```css
a:any-link {
    color: blue;
    text-decoration: underline;
}
```

This styles all hyperlinks `<a>`tags with `href`.

#### Inheritance

If an element has no cascaded value for a given property, it may inherit one from an ancestor element. Not all properties are inherited. By default, only certain ones are. They are primarily properties pertaining to *text* -- `color, font, font-family, letter-spacing, word-spacing`...

#### Special values 

`inherit, initial, unset, revert`.

1. `inherit`-- want inheritance to take place when a cascaded value is preventing it. Fore:

   ```html
   <footer class="footer">
   	&copy; 2023...
       <a href="/tems-of-use">Terms of use</a>
   </footer>
   ```

   ```css
   .footer {
       color: #666;
       //...
   }
   .footer a {
       color: inherit;
   }
   ```

   For this, inherits the color from its parent `<footer>`, for this, the benefit is the footer link will change along with the rest of the footer should anything alter it.

2. The `initial`-- Every CSS property has an initial, or *default* value.

   ```css
   .footer a {
       color: inherit;
       background-color: initial; /* resets the background color */
   }
   ```

   Fore, if want to remove a border from an element -- `border: initial`

3. The `unset`-- The `unset`is a combination of the two. Using this makes it a little simpler and helps U avoid using the wrong keyword by mistake. Fore:

   ```css
   .footer a {
       color: unset; /* set an inherited property */
       background-color: unset; /*set a non-inherited property to initial */
       text-decoration: underline;
   }
   ```

   For the `color:unset`, Removes any explicitly set `color`for the links, reverting to the inherited or default color.

4. The `revert`keyword -- Fore, revert all the way back to a blue link with an underline -- browser’s default styles.

   ```css
   .footer a {
       color: unset;
       background-color: unset;
       text-decoration: revert; /* Reverts to user-agent styles */
   }
   ```

#### The order of shorthand values

Shorthand tries to be lenient when it comes to the order of the values you specify. Can set `border: 1px solid black`or `border: black 1px solid`. Note the order `Top, Right, Bottom, Left`, fore:

```css
.nav a {
    padding: 10px 15px 0 5px;
}
```

Feature queries using `@supports()`-- Relying on the mentioned techniques -- fore:

```css
@supports (display: grid) {...}
```

Fore, targets only browsers that understand grid layout -- like:

```css
@supports (display: grid) {
    .coffee {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 10px;
    }
    .coffee a {
        margin: unset;
        min-width: unset;
    }
}
```

## Overusing getters and setters

There is no automatic support for getters and setters as some languages. Fore:

```go
timer := time.NewTimer(time.Second)
<-timer.C
```

Could even modify `C`directly. The STD Go library doesn’t enforce using getters and/or setters even when we shouldn’t modify a field. Fore, the getter method should be named `Balance`not `Get...`, and the setter method should be named `SetBalance`. Fore:

```go
currentBlance := customer.Balance()
if currentBalance < 0 {
    customer.SetBalance(0)
}
```

### Interface pollution

Interface pollution is about overwhelming our code with *unncessary* abstractions, making it harder to understand. It’s a common mistake made by developers coming from another language with different habits.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

`io.Reader`should accept a slice of bytes, filling it with its data and returning either the number of bytes or an error.

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

Write the data coming from a slice to a target and returning the number of bytes wirtten or an error. 

- `io.Reader`reads data from a source
- `io.Writer`writes data to a target

Fore, Need to implement a func that should copy the content of one file to another. `*os.File`s

```go
func copySourceToDest(source io.Reader, dest io.Writer) error {
    //...
}
```

`*os.File`parameters implements both `io.Reader`and `io.Writer`and any other type that would implement these interfaces -- could create our own `io.Writer`that writes to a dbs, and the code test -- 

```go
func TestCopySourceToDest(t *testing.T) {
    const input = "foo"
    source := strings.NewReader(input)
    // Creates a new bytes.Buffer
    dest := bytes.NewBuffer(make([]byte, 0))
    
    err := copySourceToDest(source, dest)
    if err != nil {
        // terminiate the test
        t.FailNow()
    }
    got := dest.String()
    if got != input {
        t.Errorf(...)
    }
}
```

##### Common Behavior -- 

- Retrieving the number of elements in the collection
- Reporting whether one element must be sorted before another
- Swapping two elements

The following interface was added to the `sort`package:

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}

func IsSorted(data Interface) bool {
    n := data.Len()
    for i:= n-1; i>0; i-- {
        if data.Less(i, i-1){
            return false
        }
    }
    return true
}
```

##### Decoupling

If rely on an abstraction instead of a concrete imp -- the imp itself can be replaced with another without even having to change our code. For testing -- 

```go
type CustomerService struct {
    store mysql.Store
}

func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.store.StoreCustomer(customer)
}
```

Should *decouple* `CustomerService`from the actual implementation -- 

```go
type customerStorer interface {    // creates a storage abstraction
    StoreCustomer(Customer) error
}

type CustomerService struct {     // Decouples CustomerService from the actual imp
    storer customerStorer
}

func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id: id}
    return cs.storer.StoreCustomer(customer)
}
```

##### Restricting Behavior

Fore, create a specific container for `int`configuration via an `IntConfig`struct that also exposes two methods. `Get`and `Set`.

```go
type IntConfig struct {
    //...
}

func (c *IntConfig) Get() int {
    // retrieve configuration
}
func (c *IntConfig) Set(value int) {
    // Update configuration
}
```

Enforce semantically this configuration is *read-only* -- 

```go
type intConfigGetter interface {
    Get() int
}
```

Then in code, can rely on `intConfigGetter`instead of the concrete imp -- 

```go
type Foo struct {
    threshold intConfigGetter
}
func NewFoo(threshold intConfigGetter) Foo {
    return Foo{threshold: threshold}
}

func (f Foo) Bar() {
    threshold := f.threshold.Get()
}
```

### Interface on the Producer side (should not)

- Producer side -- An interface defined in the same package as the concrete imp
- Consumer side -- An interface defined in an external package where it’s used

In Go, in most cases, this is not what should do -- should use *Consumer* side. Interfaces are satisfied implicitly in Go, which tends to be a game-changer compared to languages with an explicit imp. *Abstraction* should be discovered, not *created*. Fore, the client can create an interface with a single method, referencing the `Customer`struct from the external package like:

```go
package client
type customersGetter interface {
    GetAllCustomers() ([]store.Customer, error)
}
```

So the imp and struct in the Package store, and the Package client has `customersGetter`interface.

### What is so special about goroutines -- 

```go
func main() {
    for i:=0; i<5; i++ {
        go doWork(i)
    }
    time.Sleep(2 * time.Second)
}
```

Go’s runtime determines how many kernel-level threads to use based on the number of *logical* processors. Environment variable called `GOMAXPROCS`-- if not set, Go populates this by querying the operating system to determine how many CPUs your system has.

The `runtime.Gosched()`-- this call tells the Go scheduler to temporarily pause the main goroutine and check if other goroutine are ready to run. Concurrency vs. parallelism -- Concurrency is about planning how to do many tasks at the same time, Parallelism is about performing many tasks at the same time.

