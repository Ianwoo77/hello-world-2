# A recommended organizatino for cascade layers

```css
@layer reset, theme, global, layout, modules, utilities;
```

##### Reset layer

Some user-agent styles differed quite a bit between different browsers. In this example, any styles that are sdded to the global layer will override conflicting declarations that exist in the reset layer. Fore:

```css
@layer theme {
    .blog-content a:any-link {
        all: revert-layer;
    }
}
```

### Install anywhere (npm)

if use node.js, using `npm`by running -- 

```sh
npm install -g sass
```

Note that will install the pure Js implementation of Sass, which runs somewhat slower than the other options listed.

Examples n each -- like;

```scss
$bgcolor: lightblue;
$textcolor: darkblue;
$fontsize: 18px;

body {
    background-color: $bgcolor;
    color: $textcolor;
    font-size: $fontsize;
}
```

- Syntactically Awesome stylesheet
- is an extension to CSS
- Sass is a CSS pre-processor
- completely compatible with all verions of CSS
- reduce repetition of CSS

```scss
$mycolor: red;
$myFontSize: 18px;
$myWidth: 680px;

body {
    font-size: $myFontSize;
    color: $mycolor
}

#container {
    width: $myWidth;
}
```

#### Sass variable scope

Sass variables are only available at the lever of nesting where they are defined -- 

```scss
$myColor: red;
h1 {
    $myColor: green;
    color: $myColor;  // green
}
p {
    color: $myColor;
}
```

##### Using Sass `!glboal`

The default behavior for variable scope can be overriden by using the `!global`switch -- indicates that a variable is global, which means that it is accessible on all levels. Fore:

```scss
$myColor: red;
h1 {
    $myColor: green; !global;
    color: $myColor;
}
p {
    color: $myColor; // green, note that
}
```

#### Sass Nested rules and properties

Sass Nested rules -- Sass lets U just nest CSS selectors in the same way as HTML -- fore:

```scss
nav {
  ul {
    margin: 0;
    padding: 0;
    list-style: none;
  }

  li {
    display: inline-block;
  }

  a {
    display: block;
    padding: 6px 12px;
    text-decoration: none;
  }
}
```

```html
<body>
    <h1>Hello World</h1>
    <p>This is a paragraph.</p>
    <div id="container">This is some text inside a container.</div>
    <nav>
  <ul>
    <li><a href="#">HTML</a></li>
    <li><a href="#">CSS</a></li>
    <li><a href="#">SASS</a></li>
  </ul>
</nav>

</body>
```

##### Sass nested properties

Many CSS properties have the same prefix -- like font-family, font-size and font-weight or `text-align`, `text-transform`and `text-overflow`...

#### `@import`and Partials

Sass keeps the CSS code DRY -- one way to write DRY code is to keep related code in separate files. Can create small files with CSS snippets to include other Sass files. The CSS `@import`directive has a major drawback due to performance issues -- create an extra HTTP request each time you call it.   And the Sass `@import`directive includes the file in the CSS, no extra http call is required.

```scss
html,
body,
ul,
ol{
    margin:0;
    padding:0;
}
```

Now, want to import this `reset.scss`file into another file just like:

```scss
@use "reset";
```

#### Mixins -- 

Some things in CSS a a bit tedious to write, especially with CSS3 and many vendor prefixes that exist. And the Sass partials -- by default, Sass transpiles all the `.scss`file directly, want to import a file. If start the file name with an underscore -- Sass will not transpile it.

```scss
// _colors.scss
$myPink: #EE82EE;
$myBlue: #4169E1;
$myGreen: #8FBC8F; 
```

Then if import the partial file, just omit the underscore like:

```scss
@use "reset";
@use "colors";

body {
    font-size: $myFontSize;
    color: colors.$myBlue; // note that the prefix
}
```

The `@mixin`directive lets U create CSS code that is to be reused throughout the website, and the `@include`directive is created to let U use the mixin. 

## Handling an error twice

Handling an error multiple times is a *mistake* made frequently by developers, not specifically in Go. Understand why this is a problem and how to handle errors efficiently. Fore write a `GetRoute`function to get the route form a pair of sources to a pair of target coordinates.

```go
func GetRoute(srcLat, srcLng, dstLat, dstLng float32) (Route,error) {
    err := validateCoordinates(srcLat, srcLng)
    if err != nil {
        log.Println("failed to validate")
        return Route{}, nil
    }
    err = validateCoordinates(dstLat, dstLng)
    if err != nil {
        log.Println("failed to validate target coordinates")
        return Route{}, err
    }
    return getRoute(...)
}

func validateCoordinates(lag, lng float32) error {
    if lat>90.0 || lat < -90.0 {
        // repeat the invalide...
        log.Printf(...)
        return fmt.Errorf(...)
    }
    //...
    return nil
}
```

Having two log lines for a single error is a problem -- cuz it makes debugging harder --  Fore, if this function is called multiple times concurrently, the two messages may not be one after the other in the logs, making the debugging process more complex. As a rule of thumb, an error should be handled only once -- logging an error is handling an error, so is retrurning an error. Hence, should eigher log or return an error, never both.

```go
func GetRoute(...) (Route, error) {
    err := validateCoordinate(srcLat, srcLng)
    if err != nil {
        return Route{}, err
    }
    err = validateCoordinates(dstLat, dstLng)
    if err != nil {
        return Route{}, err
    }
    return getRoute(...)
}

func validateCoordinates(lat, lng float32) error {
    //...
    if lng>180.0 || lng<-180.0 {
        return fmt.Errorf(...)
    }
    return nil
}
```

In this version, each error is handled only once by being returned directly. Then assuming the caller of `GetRoute`is handling the possible errors with logging, the code will output the following message --  And rewrite the latest version of our code using error wrapping like:

```go
func GetRoute(...) (Route, error) {
    err := validateCoordinates(srcLat, srcLng)
    if err != nil {
        return Route{},
        fmt.Errorf("failed to validate the source : %w", err)
    }
}
```

### Handling an error

In some cases, we may want to *ignore* an error returned by a function. There should be only one way to do this in Go

```go
func f() {
    //...
    notify()
}
func notify() error {
    //...
}
```

Cuz we want to ignore the error, in this example, just call `notify`without assigning its output to a classic `err`variable. however, from a maintainability perspective, the code can lead to some issues. Consider a new reader looking at it -- this reader notices that `notify`returns an error but that error is not handled by the parent function -- So, how can they know the previous developer forget to handle it or did it purposely? For that in Go, there is only one way to write it like:

```go
_ = notify()
```

Instead of not assigning the error to a variable, assign it to the blank identifier. This new version makes explicit that we aren’t interested in the error.

And a comment can also accompany such code -- 

```go
// Ignore the error
_ = notify()
```

### Disabling `select`case with `nil`channels

In Go, can assign `nil`values to channels -- this has the effect of blocking the channel from sending or receiving anyting -- like:

```go
func main() {
    var ch chan string = nil 
    ch <-"message" //block
    fmt.Println("this is never printed")
}
```

The same logic applies to `select`statements -- trying to send or receive from a `nil`channel on a `select`has the same effect of blocking the case using that channel.

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

This pattern of merging channel data into one stream is referred to as a *fan-in* pattern, using the `select`statement to merge different sources only works when have a fixed number of sources.

#### Choosing between message passing and memory sharing

Can decide whether to use memory sharing or message passing for our concurrent applications depending on the type of solution are trying to implment.

##### Balancing code simplicity -- 

Producing simple, readable, and easy-to-maintain software code is ever more important with today’s complex business requirements and large development teams. 

The term *tightly* and *loosely* coupled software refer to how dependent different modules, are on each other. Tightly coupled software means that when we change one component, will have a ripple reflect -- Concurrent programming using memory sharing typically produces more tightly coupled software.

With message passing, each goroutine has its own isolated state stored in memory. When pass messages from one to another, each organizes the data in its memory to compute its task.

