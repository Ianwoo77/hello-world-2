# CSS box model

The CSS box model is a fundamental concept that defines how elements are structured and rendered in a web page’s layout -- it represents each element as a rectangular box with the following components-- 

1. Content -- The innermost part, contining the actual content
2. Padding , border and margin

Box-sizing property -- 

- `content-box`-- `width/height`only includes content, padding and border add to total size
- `border-box`-- `width/heigh`includes content, padding, and border.

```css
.page-header h1 {
    max-inline-size: var(--column-width);
    margin-inline: auto;
    padding-inline: 1.5rem;
}
```

This is cuz of the default behavior of the *box model* -- According to the box model, each element on the page in made up of 4 overlapping rectangles. The padding area contains the content area plus any padding.

##### Adjusting the box model

The default box model tends to cause problems with the sizing and alignment of element on the page -- instead, want your specified widths to include the padding and borders -- CSS allows U to adjust the box model behavior with its `box-sizing`property.

##### Using universal border box sizing

U have made box sizing more intuitive for this one element, but you will be sure run into other elements with the same problem -- would be nice to fix it once -- universally for all elements -- so you won’t have to think about this adjustment again.

```css
*, 
::before,
::after {
    box-sizing: border-box;
}
```

- `::before`and `::after` -- these pseudo-elements allow stying of content inserted before or after an element’s content.
- `box-sizing: border-box`-- this property changes the box model so that the width and height of an element include its padding and border, not just the content.

If have:

```css
div {
    width: 100px;
    padding: 10px;
    border: 5px solid;
}
```

With `box-sizing: border-box`-- the total width remains 100px, and the content shrinks to accommodate padding and border.

#### Element height

Working with the height (block size) of elements can be a tricky, normal document flow is designed to work wtih a constrainted width and unlimited height. The height of a container is originally determined by its content.

##### Controlling overflow behavior

When explicitly set an element’s height, run the risk of its content *overflowing* the container. This happens when the content doesn’t fit the specified constraint and renders outside the parent element. Can control the exact behavior of the overflowing content with the `overflow`property -- 

- `visible`-- The default value
- `hidden`-- Content that overflows the container’s padding area is clipped and won’t be visible
- `scroll`-- Added to container so the user can scroll to see the remaining content
- `auto`-- Scrollbars are added to the container only if the content overflow.

#### Negative margins

Unlike padding and border width -- you can assign a negative value to margins -- this has some peculiar uses, such as allowing elements to overlap or stretch wider than their containers.

The exact behavior of a negative margin depends on which side of the element you apply to it -- can see this -- Although negative margins can be used to cause an overlap between multiple elements, can be tricky to keep track of anyting complicated.

On a block-level element, a negative right margin pulls the edge of the element right, making the element wider.

```css
.container {
    max-width: 1080px;
    margin-inline: auto;
}
.expanded-child {
    margin-inline: -2em;
}
```

#### Collasped margins

Continue building your page, notice something stange going on with margins -- haven’t applied any margin to header or the conainer, yet there is also a gap between them -- when top and/or bottom margins are adjoining, they overlap -- combining to form a single margin -- this is referred to as *collapsing* -- The space below the header in figure is the result of collapsed margins. This is just referred to as *collapsing* -- the space below the headers in figure is the result of collapsed margins -- like:

Since no margin-related CSS is provided, the margin are likely coming from *browser default styles* for `<h1>`and `<header>`elements.

And the `header`element itslef typically does not have default margins in most browsers. If the `h1`margin extends outsde the `header`-- due to margin collapsing.

- In CSS, vertical margins of adjacent block-level elements can collapse, if the `<h1>`has a default bottom margin and the `<div class="container">`has not top margin, so the h1’s bottom may create visible spacing between the `header`and `div`.
- And the main reason for collapsed margins had to do with the spacing of blocks of text.

```html
<main class="main">
	<h2>Come join us!</h2>
    <div>
        <p>
        The Franklin Running club meets at 6:00pm
        every Thursday at the town square. Runs
        are three to five miles, at your own pace.
        </p>
    </div>
</main>
```

For this, three different margins are collapsing together -- the bottom margin of the h2, the top of div, and top of p. The computed values of these are just 19.92 px, 0px, and 16px, respectively, so the space between element is still 19.92px, the *largest* one of the three. In fact, can nest the paratraph inside several divs, and it will still render the same -- all the margins collapse together.

##### Collapsing outside a container -- 

The way 3 consecutive margins collaps might catch you off guard. An element’s margin collapsing ouside its container typically produces an undesrivable effect if the container has a background. This is what’s causing the gap below the header on your page -- the page title is an `h1`-- default 0.67em bottom margin applied by the user-agent styles. That title is inside a `header`with no margins -- the bottom margins of both elements are adjacent -- so they collapse, also resulting in a 21.44 px bottom margin on the header. And the same thing happens with the top margins of the two elements as well.

This is a little strange -- In this case, if want the blue of the `<header>`to be taller -- Margins don’t always collapse exactly to the spot where U want -- number ways to prevent this -- fore, applied a padding. Notice that the `margin`above come join us doesn’t collapse upward.

So if add top and bottom padding to the header, then the margins inside it won’t collapse to the outside -- this means that both the margins of the h1 and the padding of the heder would contribute space around the text. Just like:

```css
.page-header h1 {
    max-inline-size: var(--column-width);

    margin: 0 auto;
    padding: 1em 1.5rem;
}
```

So, any time you see unexpected space above or belwo containers, or see text pressed up against the top or bottom of its container, margin collapsing is just the most likely the cause.

- Applying: `overflow:auto`to a container
- Adding a border or padding
- Margins won’t collapse to the outside of the container that is an inline block, floated, or fixed position
- When using a flexbox or grid, margin won’t collapse between elements that are part of the flex layout
- `table-cell`display don’t have margin, `table, table-inline`...

## Map

Saying that the `Map`function takes some *arbitrary* function as a parameter, along with a slice -- and applies the fucntion to each element, returning the resulting slice. And Cuz it transforms an element of type `E`to another element of type `E`its signature would be `func(E) E`-- like:

```go
type mapFunc[E any] func(E) E
```

Now can write a function as parameter -- along with `slice`-- say - and applies the function to each element, returning the resulting slice. Can be:

```go
func Map[S ~[]E, E any](s S, f mapFunc[E]) S {
	result := make(S, len(s))
	for i := range s {
		result[i] = f(s[i])
	}
	return result
}
```

Note that, like the `Identity`function in a previous -- `Map`takes two type parameters -- the slice and the element type -- that is cuz like `Identity`, it needs to return a result of the same type as whatever it was passed. Fore:

```go
s := []string {"a", "b", "c"}
fmt.Println(Map(s, strings.ToUpper))
```

#### Type Inference

So, waht can we get away with here -- try to map the `strings.ToUpper`over a slice of some totally inappropratie --

```go
s := []int {1,2,3}
fmt.Println(Map(s, strings.ToUpper)) // does not match, error
```

Knew this wouldn’t work natrually -- but often the best way to learn about sth is to use it wrong on purpose. In this case, the error message is worth to parsing carefuly, cuz it shows how go *type interference* -- working out what `E`is in this instance -- Recall the `Map`declares a parameter of type `[]E`-- and in this case that is `[]int`then Go can correctly infer that `E`is `int`here. Then the type of the function must be `func(int) int` , and the signature of the one we actually passed, though, is `func(string)string`-- that is straightforward type mismatch -- 

#### Func to funky

Building a simple *dynamic dispatch* system in Go -- sound -- always call functions by name in some cases, usually have to give the game explicitly in our program -- dynamic dispatcher will decide which function to call based on the value of some string that is not known until run-time.

```go
type FuncMap[T, U any] map[string]func(T) U

// go method defined on the FuncMap[T, U any] type from message
func (fm FuncMap[T, U]) Apply(name string, val T) U {
	return fm[name](val)
}
```

##### Test this -- 

```go
func TestFuncMap_AppliesDoubleTo2AndReturn4(t *testing.T) {
	t.Parallel()
	fm := dups.FuncMap[int, int]{
		"double": func(i int) int {
			return i * 2
		},
		"addone": func(i int) int {
			return i + 1
		},
	}
	want := 4
	got := fm.Apply("double", 2)
	if got != want {
		t.Errorf("Apply(%v, %v): want %v, got %v", "double", 2, want, got)
	}
}

func TestFuncMap_AppliesUpperToUppsercaseInput(t *testing.T) {
	t.Parallel()
	fm := dups.FuncMap[rune, bool]{
		"upper": unicode.IsUpper,
		"lower": unicode.IsLower,
	}
	got := fm.Apply("upper", 'A')
	if !got {
		t.Errorf("Apply(%v, %v): want true, got false", "upper", 'A')
	}
}
```

#### Filtering and recudction

Look at another popular funcational pattern on slices -- *filtering* -- `Filter`is a conventional name for a function that like `Map`-- takes an arbitrary function and applies to each element of a slice. However, where `Map`uses the supplied function to *transfrom* each element, `Filter`use it to decide which elements to keep and which to discard -- the result of `Filter`is a slice containing only the elements that satisfied the `keep`function like: `Filter`takes an arbitrary slice, and also an arbitrary function that decides which to discard -- then like:

```go
type keepFunc[E any] func(E) bool

func Filter[S ~[]E, E any](s S, f keepFunc[E]) s {
	result := S{}
	for _, v := range s {
		if f(v) {
			result = append(result, v)
		}
	}
	return result
}
```

Again, there is nothing very complicated about the imp here. Range over the input slice checking whether `f`is `true`for each element.

#### Filter functions

What kind of `keepFunc`could we use in real programs, then -- suppose we want to filter a slice of integers to find only the even values, fore. In this case, our `keepFunc`would need to take an integer, and return `true`if it’s even.

```go
func(v int) bool {
    return v%2 ==0
}

s := []int {1,2,3,4}
fmt.Println(Filter(s, func(v int) bool {
    return v%2 == 0
}))
```

##### Generic filter functions

Are not limited to passing only function literals to `Filter`-- could certainly pass some existing *named* function -- There is another interesting option -- what if wanted to pass a *generic* `keepFunc`-- another parameterised on some type -- like:

```go
func IsEven[T any] (v T) bool {
    return v%2 == 0
}
```

Go’s `%`operator only works with integers, which is an even smaller type set so -- 

```go
func IsEven[T constrints.Interger] (v T) bool {
    return v%2 == 0
}

fmt.Println(Filter(s, IsEven[int]))
```

#### Implementing `Reduce`

This makes sense, so now let’s try to write `Reduce`-- 

``` go
func Reduce[E any](S []E, init E, f reduceFunc[E]) E {
    cur := init
    for _, v := range s {
        cur = f(cur, v)
    }
    return cur
}
```

The first parameter is the slice to operate on -- the second is some starting value for the reduction, And the third is the `reduceFunc`to apply. The implementation is pretty straightforward, set `cur`equal to the initialsing value `init`-- then for each slice element, call the `reduceFunc`with the current value of `cur`and the element. 

```go
func (cur, next int) int {
    return cur + next
}
```

#### Other considerations

Might be wondering why it’s Okay to use the `any`contraint in our reduction function. Seen in some privous examples that `any`is too broad a constraint for some functions -- cuz operators like + are not defined on every possible type.

##### Constraints

Let’s think about what would happen if we tried to `Reduce`a slice of things that don’t support that operator -- a struct fore, you can’t add two structs together, 

#### Concurrency

We’ve used pretty simple-minded implementation of `Map`, `Filter`and `Reduce`in this chapter, just to make it easy to see what is going on. In practice, it would be useful to make these imp a bit smarter. Fore, could imagine adding concurrency -- if had large slices to deal with, and if the map, reduce, or filter operations on them were relatively expenseive, making them concurrent would help a lot.

Fore, suppose we had a slice of strings representing web URLs, and we wanted to filter them to extract only those URLs which respond with OK status -- we can imagine using our existing `Filter`and `Reduce`in this chapter, just to make it easy to see what’s going on. In practice, though, it would be useful to make these imps a bit smarter. Fore, could imagine adding concurrency. If we had large slices to deal with.

Fore, suppose we had a slice of strings representing web URLs, and wanted to filter them to exact only those URLs which respond with OK status. We can imagine using our existing `Filter`imp on this slice with some function that uses `http.Get`to call the URL and check the response status.

Suppose each request takes about 250ms to complete.

#### Config struct

Because Go doesn’t support optional parameters in function signatures, the first possible approach is to use a configuration struct to convey what’s mandatory and what is optional.

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config) {
    //...
}
```

### Creating a users model

Now that the routes are set up -- we need to create a new `users`database table and a dbs model to access it.

```sql
CREATE TABLE user (
	id INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password CHAR(60) NOT NULL,
    created DATETIME NOT NULL
);
ALTER TABLE users ADD CONSTRAINT users_uc_email UNIQUE(email);
```

- The `id`field is an autoincrementing integer field and the primary key for the table. This means that the user ID values guaranteed to be unique prositive integers..
- The type of the `hashed_password`field is `CHAR(60)`-- this is cuz we’ll be storing hashes of the user passwords in the dbs -- not the passwords themsevles, and the hashed versions will always be exactly 60 character long.
- Added a `UNIQUE`constraint on the `email`column and named it `users_uc_email`.

#### Building the model in Go

Next setup a model so that can easily work with the new `users`table -- follow the same patterh that we used earlier in the book for modeling access to the `snippets`table -- like:

```go
var ErrNoRecord = errors.New("models: no matching record found")

// ErrInvalidCredentials Add a new ErrInvalidCredentials error
// use this if a user tries to login with an incorrect email address or pwd
var ErrInvalidCredentials = errors.New("models: invalid credentials")

// ErrDuplicateEmail Add a new ErrDuplicateEmail error
var ErrDuplicateEmail = errors.New("models: duplicate email")
```

The final stage is to add a new field to our `application`struct so that we can make this model avaialble to our handlers -- update the `main.go`file as -- 

```go
type application struct {
    //...
    users *models.UserModel
}
// ... 
app := &application {
    //...
    users: &models.UserModel{DB: db},
}
```

#### User signup and password encryption

Before can log in any users to our `Snippetbox`application we first need a way for them to sign up for an account.

```html
{{define "title"}}Signup{{end}}
{{define "main"}}
<form action="/user/signup" method="POST" novlidate>
    <div>
        <label>Name:</label>
        {{with .Form.FieldErrors.name}}
        	<label class="error">{{.}}</label>
        {{end}}
        <input type="text" name="name" value='{{.Form.Name}}'>
    </div>
    <div>
        <label>Email:</label>
        {{with .Form.FieldErrors.email}}
        	<label class="error">{{.}}</label>
        {{end}}
    </div>
    <div>
        <label>Password:</label>
        {{with .Form.FieldErrors.password}}
        <label class="error">{{.}}</label>
        {{end}}
        <input type="password" name="password">
    </div>
</form>
{{end}}
```

Hopefully this should feel familar so far. For the sginup form we are using exactly the same form structure that used earlier in the book.

```go
func(app *applicaiton) userSignup(w http.ResponseWriter, r *http.Request) {
    data := app.newTemplateData(r)
    data.Form = userSignupForm{}
    app.render(w, http.StatusOK, "signup.html", data)
}
```

