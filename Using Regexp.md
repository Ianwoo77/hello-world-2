Building String

The `strings`package provide the `Builder`type, which has not exported fileds but does provide a set of methods that can be used to effeciently build string gradually. like:

- `WriteString(s)` -- this just appends the string,
- `WriteRune(r), WriteByte(b), String(), Rest(), Len(), Cap()`
- `Grow(size)`-- this increases the number of bytes used allocated by the builder to store the string that is being built.

```go
func main() {
	text := "It was a boat, a small boat."

	var builder strings.Builder

	for _, sub := range strings.Fields(text) {
		if sub == "small" {
			builder.WriteString("very ")
		}
		builder.WriteString(sub)
		builder.WriteRune(' ')
	}
	fmt.Println("String:", builder.String())
}
```

So, creating the string using the `Builder`is more efficient than using just the concatenation operator on regular `string`values, especially the `Grow`method is used to allocate storage in advance.

### Using Regexp

The `regexp package`provides support for regexp, which allow complex pttern to be found in strings. `Compile(pattern)`-- this function returns a `Regexp`that can be used to perform repeated pattern matching with the specified pattern. And the `MustCompile()`which provides the same feature as `Compile()`but panics. And the `MatchString`is the simplest way to determine whether a string is just matched by a regular expression like:

```go
match, err := regexp.MatchString("[A-z]oat", desc)
if (err == nil) {
    fmt.Println("Match")
}else {
    fmt.Println(err)
}
```

`match`is a bool, which will be `nil`if there have been no issues performing the match.

### Compile

```go
pattern, compileErr := regexp.Compile("[A-z]oat")
desc := "A boat for one person"
question := "Is that a goat"
preference := "I like oats"
if compileErr==nil {
    fmt.Println("desc:", pattern.MatchString(desc))
    fmt.Println("Question:", pattern.MatchString(question))
    fmt.Println("Preference:", pattern.MatchString(preference))
}else {
    fmt.Println("error:", compileErr)
}
```

The result of the `Compile`function is an instance of the `RegExp`type, which the `MatchString`function -- .

NOTE, Compiling a pattern also provides access to methods for using REGEXP features, the most useful of which are described as:

- `MatchString(s)` -- This method returns `true`if the string `s`matches the compiled pattern
- `FindStringIndex(s)`-- this method returns an `int`**slice**-- containing the location for the left-most match made by the comipled pattern in the string. `nil`-- no match made.
- `FindAllStringIndex(s, max)`
- `FindString(s)`-- returns a string containing the left-most match
- `FindAllString(s, max)`-- Returns a string slice containing the matches made by the compiled pattern.
- `Split(s, max)`-- Splits the string using matches from the compiled pattern as separator and returns a sliice.

```go
func getSubString(s string, indices []int) string {
	return string(s[indices[0]:s[indices[1]]])
}

func main() {
	pattern := regexp.MustCompile("K[a-z]{4}|[A-z]oat")
	desc := "Kayak. A boat for one person"
	firstIndex := pattern.FindStringIndex(desc)
	allIndices := pattern.FindAllStringIndex(desc, -1)

	fmt.Println(getSubString(desc, firstIndex))

	fmt.Println(allIndices)
}
```

### Splitting strings using a regexp

The `Split()`splits a sring using the matches made by a regexp, which can provide a more flexible alternative to the splitting functions described earlier in the chapter.

```go
func main() {
	pattern := regexp.MustCompile(" |boat|one")
	desc := "Kayak, A boat for one person."
	split := pattern.Split(desc, -1)
	for _, s := range split {
		if s != "" {
			fmt.Println(s)
		}
	}
}
```

## Formatting and Scanning strings

- Formatting is the process of composing vlaues into a string, Scanning is the process of parsing a string for the valus it contains.
- Formatting a string is a common requirement and is ued to produce strings for everything from logging and debugging to presenting the user with info.

The first verb `%v`, and it specifies the default representation for a type.

- `%v`-- this verb displays the default format for the value. Modifying the verb with the `%+v`includes field names when writing out *struct* vlaues.
- `%#v`-- this displays a value in a format that could be used to re-create the value in a Go code file.
- `%T`-- displays the Go type of a values.

```go
func Printfln(tempalte string, values ...interface{}) {
	fmt.Printf(tempalte+"\n", values...)
}

func main() {
	Printfln("Go syntax: %#v", Kayak)
}

```

And the `String`method specified by the `Stringer`interface will be used to obtain a string representation of any type that defines it.

```go
func (p Product) String() string {
	return fmt.Sprintf("Product: %v, Price: $%4.2f", p.Name, p.Price)
}
```

```go
type Stringer interface {
    String() string
}
```

The `String()`specified by the `Stringer`interface will be used to obtain a string representation of any type that defines it. `%t`-- this verb formats bool value and displays `true`or `false`.

### Using the Pointer Formatting Verb

The verb --

- `%p`-- this displays a hexadecimal representaiton of the pointer’s storage location.

### Scanning strings

The `fmt`just provides functions for scanning strings, which is the process of parsing strings that contain values separated by spaces.

- `Scan(...vals), Scanln(...vals), Scanf(template, ...vals), Fscan(reader, ...vals)`

Just note ths `Fscan(reader, ...vals)`-- this function reads space-separated values from the specified reader, which is described -- Newlines are treated as spaces, and the function returns the number of values that have been read and an error the describes any problems.

- `Fscanln(reader, ...vals)`-- works in the same way as `Fscan`but stops reading when it encounters a newline character.
- `Fscanf(reader, template, ...vals)`-- this works in the same way as `Fscan`but uses a template to select the values from the input it receives.
- `Sscan(str, ...vals)`-- this function scans the specified string for space-separated values, which are assigned to the remaining arguments. The result is the number of values scanned and an error that describes any problems.
- `Sscanf(str, template, ...vals)`-- this function works in the same way as `Sscan`but uses a template to select values from the string.
- `Sscanln(str, template, ...vals)`-- works in the same way as `Ssanf`but stops scanning the string as soon as a newline character is encountered.

```go
func main() {
	var name string
	var category string
	var price float64

	fmt.Print("Enter text to scan:")
	n, err := fmt.Scan(&name, &category, &price)

	if err == nil {
		Printfln("Scanned %v values", n)
		Printfln("Name: %v, category: %v, Price: %.2f", name, category, price)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

### Dealing with NewLine characters

By default, scanning threats newlines in the same way as spaces, acting as separators between values. To see this, execute the project and when prompted for input, like: Note the `Scan`function doesn’t stop looking for values until after it has received the number it expects and the first press of the `Enter key`is treated as a separator and not terminataion of the input. Just like:

```go
n, err := fmt.Scanln(&name, &category, &price)
```

If you first press the `Enter`key, the newline will terminate the input, leaving the `Scanln`function with fewer values than it requires.

### Using different String Source

```go
source := "Lifejacket Watersports 48.95"
n, err := fmt.Sscan(source, &name, &category, &price)
```

### Using a Scanning Template

A template can be used to scan for values in a string contains characters that are not required. FORE:

```go
source := "Product Lifejacket Watersports 48.95"
template := "Product %s %s %f"
n, err := fmt.Sscanf(source, tempalte, &name, &category, &price)
```

## Math Functions and Data Sorting

The `math/rand`provides supports for generating random numbers. `Seed(s), Float32(), Int(), Intn(max), UInt32(), Uint64(), Shuffle(count, func)`

`rand.Seed(time.Now().UnixNano())`

`Printfln(rand.Intn(10))`

```go
func IntRange(min, max int) int {
    return rand.Intn(max-min)+min
}
```

```go
rand.Shuffle(len(names), func(first, second int) {
    names[first], names[second]=names[second], names[first]
})
```

### Sorting Data

- `Float64s(slice)`-- sorts a slice of `float64`values -- the elements are sorted in place
- `Float64sAreSorted(slice)`-- returns `true`if in order
- `Ints(slice)` -- note that also in-place sorting.
- `IntsAreSorted(slice)`-- this returns `true`if sorted
- `Strings(slice)`-- sorts a slice of `string`.
- `StringsAreSorted(slice)`

```go
func main(){
	ints := []int {9, 4, 2, -1, 10}
	Printfln("Ints: %v", ints)
	sort.Ints(ints)
	Printfln("Ints sorted: %v", ints)
}
```

Need to note that the functions sort the elements in place, rather than creating a new slice, if you want to create a new, sorted slice, then you must use the built-in `make`and `copy`functions like:

```go
sortedInts := make([]int, len(ints))
copy(sortedInts, ints)
sort.Ints(sortedInts)
```

### Searching Sorted Data

The `sort`package defines the functions for searching sorted data for a specific value.

`SearchInts(slice, val)` -- this just searches the **sorted** slice for the specified `int`value -- the result is the index of the specified value or if the values is not found, the index at which the value can be inserted while maintaining the sorted order. And the `Float, String`

`Search(count, testFunc)`-- This function invokes the test function for the specified number of elements. The result is the index for which the fucntion returns `true`-- if there is no match, then the result is the index at which the specified value can be inserted to maintain the sorted order.

```go
indexof4 := sort.SearchInts(sortedInts, 4)
indexof3 := sort.SearchInts(sortedInts, 3)
```

### Sorting Custom Data types

To sort custom data types, the `srot`package define an interface confusingly named just `Interface`. Which specifies the methods like:

- `len`-- this method returns the number of items that will be sorted
- `Less(i,j)`-- this returns `true`if the element at index i should appear in the sroted sequence before the element j.
- `Swap(i,j)`-- just swaps the elements at the specified indices.

When a type defines the methods -- can sorted using the functions like:

`Sort, Stable, IsSorted, Reverse`-- which is defined just by the `sort`package. Just like:

```go
type Product struct {
	Name  string
	Price float64
}

type ProductSlice []Product

func ProductSlices(p []Product) {
	sort.Sort(ProductSlice(p))
}

func ProductSliceAreSorted(p []Product) {
	sort.IsSorted(ProductSlice(p))
}

func (products ProductSlice) Len() int {
	return len(products)
}

func (products ProductSlice) Less(i, j int) bool {
	return products[i].Price < products[j].Price
}

func (products ProductSlice) Swap(i, j int) {
	products[i], products[j] = products[j], products[i]
}

```

The `ProductSlice`is just an alias for a `Product`slice and is the type for which the interface methods have been imlemented. In addition to the methods, have a `ProdcutSlices`functin, which accepts a `Product`slice, converts it to the `ProductSlice`type, and pases it as an argument to the `Sort`function there is also a `ProducatSlicesAreSorted()`function, which calls the `IsSorted`function. just like:

```go
func main() {
	products := []Product{
		{"Kayak", 279},
		{"Lifejacket", 49.94},
		{"Soccer Ball", 19.95},
	}

	ProductSlices(products)

	for _, p := range products {
		Printfln("Name: %v, price: %.2f", p.Name, p.Price)
	}
}

```

### Sorting Using Different Fields

Type composition can be used to support sorting the same struct type using different fields, as known as:

```go
type ProductSliceName struct {ProductSlice}
func ProductSliceByName(p []Product) {
    sort.Sort(ProductSliceName{p})
}
func(p ProductSliceName) Less(i, j int) bool {
    return p.ProductSlice[i].Name < p.ProductSlice[j].Name
}
```

Note that a Struct type is defined for each struct field for which sorting is required, with an embedded `ProductSlice`field like this. just:

`type ProductSliceName struct {ProductSlice}`

The type compsition feature means that the methods defined for the `ProductSlice`type are just **promoted** to the enclosing type, a new `Less`method is defind for enclosing type, which will be used to sort the data using just a different filed like:

### Specifying the Comparsion Function

An alternative approach is to specify the expression used to compare elements outside the `sort`function like:

```go
type ProductComparsion func(p1, p2 Product) bool 

type ProductSliceFlex struct {
    ProductSlice
    ProductComparsion
}

func (flex ProductSliceFlex) Less(i, j int) bool {
    return flex.ProductComparsion(flex.ProductSlice[i], flex.ProductSlice[j])
}
func SortWith(prods []Product, f ProductComparsion) {
    sort.Sort(ProductSliceFlex{prods, f})
}
```

In the main() just like:

```go
SortWith(products, func(p1, p2 product) bool ) {
    return p1.Name < p2.Name
});
```

## Docker

The application insdie the box can’t see anything outside the box, but the box is running on a computer, and that computer can also be running lots of other boxes. The application in those boxes ahve their own separate environments, but they all share the CPU and memory of the computer.

It fixes two conflicting problem in computing, isloation, and density. Density means that running as many application on your computer as possible, to utilize all the processor and memory that you have.

- The first thing need is a handler, Can think of handlers as being a bit like controllers. They are responsible for executing your application logic and for writing HTTP response headers and bodies.
- And the second is a router, this stores a mapping between the URL patterns for your application and the corresponding handlers, usually you have one serveMux for your application containing all your routes.
- The last thing need a web server. One of the great things about Go is that you can establish a web server and listen for incoming requests *as part of your applicaiton itself*. For Go, don’t need external 3rd-party server like Nginx.

```go
// define a home handler function which writes a byte slice containing
// as a response body
func home(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello from Snippetbox2"))
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)

	log.Println("Starting server on : 4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}
```

When run the code, should start a webe server listening on port 4000 of your local machine, each time the server receives a new HTTP request will pass the request on to the servemux and - in turn, the serveMux will check the URL it will pass the request on to the servemux and in turn the servemux will check the URL path and dispatch the request to the matching handler.

Note that the TCP network address that you pass to `http.ListenAndServe()`should be in format `host:port`, if you omit the host then the server will listen on all your computer’s available network interfaces.

### Routing Requests

Having a web application with just one route isn’t -- add a couple more routes so that the application starts to shape up like this -- 

- `/`-- home -- Display home page
- `/snippet`-- showSnippet -- Display a specific.

### Fixed Path and subtree Patterns

Go’s ServeMux supports two different types of URL patterns -- *fixed paths* and *subtree paths*. Fixed **don’t** end with trailing slash, whereas subtree paths do end with a trailing slash.

In contrast, our pattern `/`is an example of a subtree path -- another example would be sth like `/static/`. subtree path patterns are matched -- if it helps your understanding, can think of subtree paths as acting a bit like they have a wildcard at the end like /** and `/static/**`

### Restricting the Root URL pattern

Fore, in the application we ‘re building we want the home page to be displayed if and only if the request URL path exxactly matches `/` otherwise, want the user to receive a 404 page not found -- and it’s not possible to change the behavior of Go’s ServeMux to do this, but can include a simple check in the `home`handler which ultimately has the same effect. Just like:

```go
func home(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/" {
        http.NotFound(w, r)
        return
    }
    w.Write([]byte("Hello form snippets"))
}
```

### The `DefaultServeMux`

Might have come across the `http.Handle()`and `http.HandleFunc()`functions, these allow you to register routes *without* declaring a servemux just like:

```go
func main() {
    http.HandleFunc("/", home)
    http.HandleFunc("/snippet", showSnippet)
    http.HandleFunc("/snippet/create", createSnippet)
    
    err := http.ListenAndServe(":4000", nil)
    log.Fatal(err)
}
```

Behind the scenes, these functions register their routes with sth called the `DefaultServeMux`-- there is nothing special about this -- it’s just regular servemux just like already been using -- but which is initialized by default and stored in a `net/http`**global variable**. like:

`var DefaultServeMx = NewServeMux()`

Cuz `DefaultServeMux`is just a global variable, any package can just access it and register a route -- including any 3rd-aprty packages that your appliation imports. Could use `DefaultServeMux`to expose a malcious handler to the web. So, for the sake of security, it’s generally a good idea to avoid `DefaultServeMux`and the corresponding helper functions.

- In Go’s servemux, longer URL patterns always take precedence over shorter ones -- so, if a servemux contains multiple patterns which match a request, it will always dispatch the request to the handler corresponding to the longest pattern.
- Request URL paths are automatically sanitized -- if the request path contains any `.`... elements or repeated slashes, the user will automatically be redirected to an equivalent clean URL. `/foo/bar/..//baz`fore, just redirect to the `/foo/baz`instead.
- If a subtree path has been registered and a request is received for that subtree path without a trailing slash, then the user will automatically be sent a 301.

### RESTful Routing

Important to acknoledge that the routing functionality provided by Go’s servemux is pretty lightweight -- doesn’t support routing based on the request method. doesn’t support semantic URLs with variables in them, and doesn’t support regexp-based patterns.

Making this change is important cuz later -- requests to the `/snippet/create`route will result in a new snippet being creted in a dbs -- creating a new snippet in a dbs is a non-idempotent action that changes the state of our server.

Begin with updating `createSnippet()`so that it sends a 405 like:

```go
func createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(405)
		w.Write([]byte("Method not allowed"))
		return
	}
	w.Write([]byte("create new snippet..."))
}

```

Although this change looks straightforward there are a couple of should explain -- 

- it’s only possible to call `w.WriteHeader`once per response, and after the status code has been written, it can’t be changed. If try to call it a second time go will log warning.
- If don’t call `WriteHeader`then the `Write()`will automatically send a 200 ok status code t the user.

### Customizing Headers

Another improvement we can make is to include an `Allow:Post`hder with every 405 method not allowed response to let the user know which request mthods are supported for that particular URL. Just like:

```go
if r.Method != http.MethodPost {
    w.Header().Set("Allow", http.MethodPost)
    w.WriteHeader(405)
    w.Write([]byte("Method not allowed"))
    return
}
```

### The `http.Error`shortcut

If want to send a non-200 status code and a plain-text response body, then it’s a good opportunity to use the `http.Error()`shortcut -- this is just a lightweight helper function which takes a given message and status code, then calls the `w.WriteHeader()`and `w.Write()`methods behind the scenes for us.

```go
if r.Method != http.MethodPost {
    w.Header().Set("Allow", http.MethodPost)
    http.Error(w, "Method not allowed", 405)
    return
}
```

In terms of functionality this is almost exactly the same - -the biggest difference is that we’re now passing our `http.ResponseWriter`to another function , which sends a respsone to the user for us.

## Event Handler Invocation

Once registered event handler, the web browser will invoke it automatically when an event of the specified type occurs on the specified object. This section describes event handler invocation in detail, explaining event handler arguments.

### Event handler argument

Event handlers are invoked with an `Event`object as their single argument. The properties of the Event object provide details about the event -- 

- `type`-- the type of the event occurred
- `target`-- The object on which the event occurred.
- `currentTarget`-- For events that propagate, this property is the object on which the current event handler was registered.
- `timeStamp`-- a timeStamp that represents when the event occurred but that does not represent an abs time.
- `isTrusted`-- will be `true`if the event was dispatched by the web browser.

After the Event handlers registered on the target element are invoked, most events `bubble`up the DOM tree -- the event handlers of the target’s parent are just invoked. Then the handlers registered on the target’s grandparent are invoked. This continues up to the `Document`object, and then `Window`.

For the `{capture: true}`-- then the event handler is registered as a capturing event handler for invocation during this first phase of event propagation. The capturing phase of event propagation is like the bubbling phase in reverse. The capturing handlers of the Window object are invoked first, then the capturing handlers of the `Document`object, then of the body object, and so on down the DOM tree until the capturing event handlers registered on the event target itself are not invoked.

Event capturing provide an opportunity to peek events before they are delivered to their target. A capturing event handler can be used for debugging, or it can be used events so that the target event handlers are never actually invoked.

### Dispatching Custom Events

Client-side js’ event API is relatively powerful one, and you can use it to define and dispatch your own events. Suppose, fore, that your program periodically needs to perform a long calcuation or make a network request and that. While this op is pending, other ops are not possible. You want to let the user know about by this dispatching spinners to indeicate that the app is busy. But the module that is busy should not need to know where the spinners should be displayed. Instead, that module might just dispatch an event to announce that it is busy and then dispatch another event when it is no longer busy.

```js
// detail: represents the content of your content
document.dispatchEvent(new CustomEvent('busy', { detail: true }));

fetch(url)
    .then(handleNetworkResponse)
    .catch(handleNetworkError)
    // after the netwrok request has succeeded or failed, dispatch
    // another event to let the UI know that we are no longer busy
    .finally(() => {
        document.dispatchEvent(new CustomEvent("busy", { detail: false }));
    
    });
document.addEventListener('busy', e => {
    if (e.detail) {
        showSpinner();
    } else {
        hideSpinner();
    }
});
```

## Scripting Documents

Client-side Js exists to turn static HTML document into interactive web applications, so scripting the content of web pages is really the central purpose of Js.

Need to note every `Window`object has a `document`property that refers to a `Document`object. the `Document object`represents the content of the window, and it is the subject of this section. The `Document`object doe not stand alone, however, it is the central object in the DOM for representing and manipulating document content.

For the `querySelectorAll()`-- it returns all matching elements in the document rather than just returning the first:

`let titles= document.querySelectorAll("h1, h2, h3")`;

Just note that the return value of `querySelectorAll()`is not an array of `Element`objects, instead, it is an array-like object known as a NodeList, `NodeList`objects have a `length`prop and can be indexed like arrays, so can loop over them with a traditional `for`loop. Note that the `NodeLists`are laso iterable, so can use them with `for/of`loops as well -- Simple pass it to `Array.from()`method.

Another CSS-based element selection method is `closet()`which is defined by the `Element`class and takes a selector as its only argument. If the selector matches the element it is invoked, it returns that element.

If the selector matches the element it is invoked on, it returns that element. otherwise, it returns the closest ancestor element that the selector matches, or return `null`if none matched. `closet()`starts at an element and looks for a match above it in the tree. fore

```js
// find the closest enclosing <a> tag that has an href attribute
let hyperlink = event.taget.closest('a[href]');

// return true if the element e is inside of an HTML list element
function insideList(e) {
    return e.closest('ul, ol, dl')!==null;
}

// Returns true if e is an HTML heading element
function isHeading(e) {
    return e.matches("h1...")
}
```

### PreSelected elements

The `Document`class defines shortcut properties to access certain kinds of nodes, The `images, forms, links`properties, fore, provide easy access can:

`document.forms.address;` `<form id="address">`

### Structure and Traversal

- `parentNode`-- refers to the parent of the element
- `children`-- contains the `Element`children of an element.
- `childElementCount`-- The number of `Element`children, returns the same value as `children.length`.
- `firstElementChild, lastElementChild`
- `nextElementSibling, previousElementSibling` -- refer to the sibling Elements immediately before or immediately after an `Element`, or `null`if there is no such sibling.

### Documents as trees of nodes

If want to traverse a document or some portion of a document and do not want to ignore the `Text`nodes -- can use a different set of properties defined on all `Node`objects.

- `childNodes`-- a read-only NodeList that contains all children
- `firstChild, lastChild`-- first and last child
- `nodeType`-- A number that specifies what kind of node this is -- Document node 9, element node 1..
- `nodeValue`-- the textual content
- `nodeName`-- The HTML tag name of an Element.

## Attributes

The `Element`class defines general `getAttribute(), setAttrbute(), hasAttribute(), removeAttribute()`methods for querying, seting, testing, and removing the attributes of an element.

`innerHTML`, `textContent`.

### Creating, inserting, and deleting Nodes

how to uery and alter document content using strings of HTML and of plain text -- Create just with the `createElement()`method of the `Document`class and append strings of text or other elements to it with its `append()`and `prepend()`methods. fore:

```js
let paragraph = document.createElement('p');
let emphasis = document.createElement('em');
emphasis.append(...); // add text to
```

## Functions in Ts

### Function parameters

Take the following `sing`function that takes in a `song`parameter and logs it like: As with variables, Ts allows you to decalre the type of funciton parameters with a type annotation, use `a: string`to tell Ts that the `song`parameter is of type `string`.

### Required parameters

Unlike js, which allows functions to be called with any number of arg -- Ts just assumes that all paameters declared on a function are required. If a function is called with a wrong number of arguments, Ts will protest in the form of a type error. Fore, the `singTwo`requires two parameters, like:

```tsx
function singTwo(first:string, second:string) {
    console.log(`${first}/${second}`)
}
// undefined
singTwo('ball and chain');
```

Enforcing that requried parameters be provided to a function helps enforce type safety by making sure all exptected argument values inside the function.

### Optional Parameters

Recall -- if a func parameter is not provided, its argument value inside -- 

```js
function announceSong(song:string, sing?:string) {
    console.log(`song: ${song}`);
    if(singer) {
        console.log(`singer: ${singer}`);
    }
}
```

Note optional parameters are not the same as parameters with union types that happen to include `| undefined`. Parmeters that aren’t marked as optional with a `?`must always be provided, even if the value is explicitly `undefined`.

```js
function announceSongBy(song:string, singer : string | undefined) {}
announsceSongBy("abc"); // error
```

Any optional parameters for a function must be the last parameters, Placing an optional parameter before a required parameteter would trigger a TypeScript Synatx error:

### Default Parameters

Optional parameters in Js may be given a default value with an = and a value in their declaration. FORE, in the following `rateSong`function, rating is inferred to be of type `number`, but is an optional `number | undefined`in the code that calls the function.

```js
function rateSong(song: string, rating=0)
```

### Rest Parameters

The `...`in TS just like:

```tsx
function singAlltheSongs(singer: string, ...songs: string[]) {}
```

### Return Types

Ts is preceptive, if it understands all the possible values returned by a function like: Can:

```tsx
function singSongs(songs: string[]) {
    for(const song of songs) {
        console.log(`${song}`);
    }
    return songs.length;
}

// for this, will infer to return a string | undefined cuz its two possible returned values are typed string
function getSongAt(songs: string[], index:number) {
    return index < songs.length? songs[index]: undefined;
}
```

### Explicit Return Types

As with variables, generally recommend not borthering to explicitly declare the return types. Just like:

```tsx
function singSongRecursive(songs: string[], count = 0): number {
    return songs.length ? singSongRecursive(songs.slice(1), count + 1) : count;
}
```

For the arrow functions, that falls just before the `=>`operator just like:

```tsx
const singSongRecursive = (songs: string[], count=0): number => {...}
```

Fore, this function returns `Date | undefined` like:

```tsx
function getSongRecordingDate(song:string): Date | undefined {
    switch(song){
        case "strange fruit":
            return new Date('...');
        case "Greensleeves":
            return "unknown";
        default:
            return undefined;
    }
}
```

### Function types

Js allows us to pass functions around as valus -- that mens we need a way to declare type of a parameter or variable meant to hold a function. Looks like to an arrow function, but with a type instead of the body. like:

```tsx
let nothingInGivesString: ()=>string;
```

This just describes a function with a `string[]`parameter, an optional `count`parameter, and a returned `number`value. And function type are frequently used to describe callback parameters like:

And this `inputAndOutput`variable’s type descirbes a function with a `string[]`parameter, an optional `count`parameter, and a returned `number`value -- like:

```tsx
let inputAndOutput: (songs: string[], count?:number)=> number;
```

```TSX
const songs = ["Juice", "Shake it off", "What's up"];

function runOnSongs(getSongAt: (index: number) => string) {
    for (let i = 0; i < songs.length; i += 1) {
        console.log(getSongAt(i));
    }
}

function getSongAt(index: number) {
    return `${songs[index]}`;
}

runOnSongs(getSongAt);
```

### Function type Parenthese

Function types may be placed anywhere that another type would be used. That includes union types -- In untion types, parenthses may be ued to indicate which part of annotaion is the function return or the surrounding type.

### Parameter Type Inferences

It would be cumbersome if we had to declare parameter types for every function we write, including inline functions used as parameters. Fortunately, Ts can infer the types of parameters in a function provided to location with a declared type. 

```tsx
let singer:(song: string) => string;
singer = function(song) {
    return `singing: ${song.toUpperCase()}!`;
};
```

Functions passed as arguments to parameters with funciton parameter types will have their parameter types inferred as well. For example, the `song`and `index`parameters here are inferred by Ts to be `string`and `number`repeatively:

```tsx
type NumberToString = (input: number)=> string;
function usesNumberToString(numberToString: NumberToString) {
    console.log(`The string is : ${numberToString(1234)}`);
}
usesNumberToString(input)=> `${input}! Hooray!`);
usesNumberToString(input=> input*2);
```

Type aliases are particularly useful for function types. They can save a lot of horizontal space in having to repeatedly write out parameters and/or return types.

### More Return Types

Let’s look at two more return types : `void`and `never`. 

### void Returns

Some functions aren’t meant to return any value. This `logSong`function is declared as returning `void`. So it’s not allowed to return a value:

```tsx
function longSong(song: string | undefined) : void {
    if(!song){
        return;
    }
    console.log(`${song}`);
    return true;
}
```

`void`can be useful as the return type in a funciton type declaration. When used in a function type declaration, `void`indicates that any returned value from the function would be ignored.

```tsx
function returnVoid() {
    return;
}
let lazyValue: string | undefined;
lazyValue = returnsVoid();
```

### Never Returns

Some functions not only don’t return a value, but aren’t meant to return at all.

