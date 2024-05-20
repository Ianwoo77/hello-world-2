# Data Normalization

The final point in the original -- Each type of observational unit forms a table.

### Multiple observational Units in a Table (Normalization

One of the simplest ways of knowing whether multiple observatinal units are represented in a table is by looking at each of the rows and taking note of any cells or values that are being repeated from row to row.

Melt -- The top-level `melt()`function and the corresponding `DataFrame.melt()`are useful to massage a DataFrame into a format where one or more columns are *identifier variables*, while all other columns, considered measured variable. are *unpivoted* to row axis, leaving just two non-identifer columsn.

```python
cheese.melt(id_vars=['first', 'last'], var_name='quantity')
billboard_long= billboard.melt(
    id_vars='year artist track time date.entered'.split(),
    var_name='week',
    value_name='rating'
)
billboard_long[billboard_long['track']=='Loser']
```

Can see this table actually holds two types of data -- the track info and the week ranking, it would be better to store the track info in separate table. Can then place the ... in a new dataframe, with each unique set of values being assigned a unique ID, then can use this unique ID in a second df that represents a date entered..

```python
billboard_songs = billboard_long[
    'year artist track time'.split()
]
# then , know there are just duplicate entries in this df, need to drop the dupliate rows like:
billboard_songs= billboard_songs.drop_duplicates()
# then, can assign a unique value to each row of data -- there are many ways U could do this:
billboard_songs['id']=billboard_songs.index+1
# then have a separate df about songs then :
billboard_ratings = billboard_long.merge(
    billboard_songs, on='year artist track time'.split()
)
# finally, subset the columns to the ones we want in rating dataframe like:
billboard_ratings= billboard_ratings[
    'id date.entered week rating'.split()
]
```

### Groupby operations -- 

1. Data is split into separate parts based on key(s)
2. A func is applied to each part of the data
3. The results from each part are combined to create a new dataset.

Pandas `.groupby()`works just like the SQL `GROUP BY`-- The split-apply-combine concept is also used in big data systems that use distributed computing. The techniques -- 

- Aggregation can be done ussing conditional subsetting on a dataframe
- Transformation can be done by passing a column into a separate function
- Filtering can be done with conditional subsetting.

#### Aggregate

Aggregate is just the process of taking multiple values and returning a *single value*. Calculating an arithmetic mean is an example. Aggregation may sometimes be referred to as summarization. like:

```python
df = pd.read_csv('gapminder.tsv', sep='\t')
# calculate the average life expectancy for each year
avg_life_exp_by_year = df.groupby('year')['lifeExp'].mean()
```

So the `groupby`statements can be thought of as creating a subset of each unique value of a column. Column, fore, could gat a list of unique values in the column like:

```python
years = df.year.unique() # return a array list
# can go through each of the years and subset of data like:
y1952= df.loc[df.year==1952, :]
# can perform a function on the subset data
y1952_mean = y1952['lifeExp'].mean()
```

So the `groupby()`method essentially repeats process for every year column, calculates the mean value and conventiently returns all the results in a single dataframe.

## Creating a simple HTTP Server

The `net/http`package makes it easy to create a simple HTTP server, which can then be extended to add more complex and useful features -- like:

```go
type StringHandler struct {
	message string
}

func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {
	io.WriteString(writer, sh.message)
}

func main() {
	err := http.ListenAndServe(":5000", StringHandler{message: "Hello world"})
	if err != nil {
		Printfln("Error: %v", err.Error())
	}
}
```

### Creating the HTTP Listener and Handler

The `net/http`provides a set of convenience functions that makes it easy to create an HTTP server without needing to specify too many details -- like:

- `ListenAndServe(addr, handler)` -- The function starts listening for HTTP requests on a specified address and passes requests onto the specified handler.
- `ListenAndServeTLS(addr, cert, key, handler)`-- This starts listning for HTTPs requests.

The `ListenAndServe()`starts listening for HTTP requests on a specified network address. And the `ListenAdnServeTLS`does the same for HTTPs.

Just note when a request arrives, it is passed onto a *handler* which is responsible for producing a response. Handlers must implement the `Handler`interface which -- 

- `ServeHTTP(writer, request)`-- This process a HTTP request -- request is described by a `Request`value, and the response is written using a `ResponseWriter`.

#### Inspecting the Request

HTTP requests are represented by the `Request`struct, defined in the `net/http`package -- Fore: `Method(GET POST)... URL(returns the requestd URL)`.

- `Proto`-- returns a `string`that indicuates the version of HTTP used for the request
- `Host`-- This returns a `string`containing the requested host.
- `Header`-- returns a `Header`value, which is an alias to `map[string][]string`and contains the requested headers.

#### Filtering Requests and generating Respones

And the HTTP server responds to all requests in the same way, whcih is not ideal, to produce different responses, need to Inspect the URL to figure out what is being requested and use the functions provided by the `net/http`to send an approprtiate response. fore;

- `RawQuery`-- returns the query string from the URL, and use the `Query()`to process the query string into a map.
- `Path`-- returns the path component of the URL
- `Hostname()`-- returns the hostname as a string
- `Port()`-- returns the port component
- `Query(), User(), String()`

Note that the `ResponseWriter`interface defines the methods that are available when creating a response. like:

- `Header()`-- returns a `Header`is an alias to `map[string][]string`
- `WriteHeader(code)`-- sets the status code for the response
- `Write(data)`-- writes data to the response body and implements an `Writer`interface.

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {

	if request.URL.Path == "/favicon.ico" {
		Printfln("Request for icon detected - returning 404")
		writer.WriteHeader(http.StatusNotFound)
		return
	}
	Printfln("Request for %v", request.URL.Path)
	io.WriteString(writer, sh.message)
}
```

#### Using the response Convenience Functions

The `net/http`package provides a set of convenience functions that can be used to create common responses to HTTP requests -- like:

- `Error(writer, message, code)`-- Sets the header to the specified code, sets the `Content-Type`header to `text/plain`and writes the error message to the response. The `X-Content-Type-Options`header is also set to stop browsers from interpreting the response as anything other than text.
- `NotFound(writer,request)`-- This function calls `Error`and specifies a 404
- `Redirect(writer, request, url, code)`-- This function sends a redirection responst to the specified URL and with the sepcified status code.
- `ServeFile(writer, rquest, filename)`-- sends a response containing the contents of the specified file.

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {

	Printfln("Request for %v", request.URL.Path)
	switch request.URL.Path {
	case "/favicon.ico":
		http.NotFound(writer, request)
	case "/message":
		io.WriteString(writer, sh.message)
	default:
		http.Redirect(writer, request, "/message", http.StatusTemporaryRedirect)
	}
}
```

#### Using the convenience Routing handler

The process of inspecting the URL and selecting a response can produce complex code that is difficult to read and maintain. like:

```go
func (sh StringHandler) ServeHTTP(writer http.ResponseWriter,
	request *http.Request) {

	Printfln("Request for %v", request.URL.Path)
	io.WriteString(writer, sh.message)
}

func main() {
	http.Handle("/message", StringHandler{"Hello World"})
	http.Handle("/favicon.ico", http.NotFoundHandler())
	http.Handle("/", http.RedirectHandler("/message", http.StatusTemporaryRedirect))

	err := http.ListenAndServe(":5000", nil)
	if err != nil {
		Printfln("error: %v", err.Error())
	}
}
```

- `HandleFunc(pattern, handlerFunc)`-- This function creates a rule that invokes the specified function for request that match the pattern. The function is invoked with `ResponseWriter`and `Request`arguments.

To set up the routing rules, the `net/http`provides the func like;

- `FileServer(root)`-- create a `Handler`that produces responses using the `Servefile`func.
- `NotFoundHandler()`-- creates a `Handler`that produces responses using the `NotFound`function
- `RedirectHandler(url, code)`-- creates a `Handler`that produces responses using the `Redirect`function.
- `StripPrefix(prefix, handler)`-- creates a handler that remove the specified prefix from the request URL
- `TimeoutHandler(handler, duration, message)`-- passes on the request to the specified handler.

#### Supporting for HTTPS

The `net/http`provides integrated support for HTTPs, where the additional arguments specify the certificate and private key files. Which named `certificate.cer`and `certificate.key`in proj.

```go
go func() {
    err := http.ListenAndServeTLS(":5500", "ian.cer",
                                  "ian.pkey", nil)
    if err != nil {
        Printfln("HTTPS Error: %v", err.Error())
    }
}()
err := http.ListenAndServe(":5000", nil)
if err != nil {
    Printfln("error: %v", err.Error())
}
```

The `ListenAndServeTLS()`and `ListenAndServe()`block -- used a gorotuine to support both HTTP and HTTPs requests, with HTTP handled on port 5000 and HTTPs for 5500. both have been invoked with `nil`as the handler, which means that both HTTP and HTTPs will be handled using the same set of routes.

#### Redirecting HTTP to HTTPs

A common requirement when creating web servers is to redirect HTTP requests to the HTTPs prot can be done by creating a custom handler - -like:

```go
func HTTPSRedirect(writer http.ResponseWriter, request *http.Request) {
	host := strings.Split(request.Host, ":")[0]
	target := "https://" + host + ":5500" + request.URL.Path
	if len(request.URL.RawQuery) > 0 {
		target += "?" + request.URL.RawQuery
	}
	http.Redirect(writer, request, target, http.StatusTemporaryRedirect)
}

func main() {
	// ...
	err := http.ListenAndServe(":5000", http.HandlerFunc(HTTPSRedirect))
	if err != nil {
		Printfln("error: %v", err.Error())
	}
}
```

#### Creating a Static HTTP Server

The `net/http`package includes built-in support for responding to requests with the contents of files. To prepare for the static HTTP server, create the `httpserver/static`folder and add it to a file named `index.html`with the content like -- 

```html
<body>
<div class="m-1 p-2 bg-primary text-white h2">
    Hello world
</div>
</body>

<body>
<div class="m-1 p-2 bg-primary text-white h2 text-center">
    Products
</div>
<table class="table table-sm table-bordered table-striped">
    <thead>
    <tr><th>Name</th><th>Category</th><th>Price</th></tr>
    </thead>
    <tbody>
    <tr><td>Kayak</td><td>Watersports</td><td>$279.00</td></tr>
    <tr><td>Lifejacket</td><td>Watersports</td><td>$49.95</td></tr>
    </tbody>
</table>
</body>
```

### Creating the static File route

Now that there are HTML and CSS files to work with, it is time to define the route that will make them available to request using HTTP like:

```go
fsHandler := http.FileServer(http.Dir("./static"))
http.Handle("/files/", http.StripPrefix("/files", fsHandler))
```

So the `FileServer`function creates a handler that will serve files, the directory is specified using the `Dir`function. The support for serving files has some useful features, first, the `Content-Type`header of the response is set automatically based on the file extension. Second, requests that don’t specify a file are handled using `index.html`.

# Floating and Positioning

`<img src="b5.gif" alt="B4" align="right">` this causes an image to float to the right adn allows other content to flow around the image. Fore:

```css
p.aside {
    float: inline-end;
    width: 15em;
    margin: 0 1em 1em;
    padding: 0.25em;
    border: 1px solid;
}
```

Just note that floated elements is that margins around floated elements do not callapse -- If float an image, and gives it 25-px margins, there will be at least 25 pixels of space around that image. If other elements adjacent to the image, and that means adjacent horizontally and vertically -- also have margins.

```css
p img {float: inline-start; margin: 25px;}
```

No floating at all -- CSS has other value for `float`besides the ones -- `float:none`is used to prevent an element from floating at all.

The details -- A floated element’s containing bock is the nearest block-level ancestor element. A floated element’s containing block the neatest block-level ancestor. Furthermore, a floated element generates a block box regardless of the kind of element it is.

1. The left (or right) outer edge of floated element may not be the left of the inner edge of its containing block.
2. To prevent overlap with other floated elements, the left outer edge of a floated element must be to the right of the right outer edge of a left-floating element that occurs earlier in the document source.

### Clearing

Won’at always want your content to flow past a floated element -- in some cases, specifically want to prevent it. Prohibit floating elements from appearing next to it. To make sure all `<h3>`elements are not placed to the right of left-floating elements, you would declare `h3{clear:left;}`-- this can be translated as make sure that the left side of an `<h3>`is clear of floating eemetns and pseduo-elements. `h3 {clear: left}`-- while this will push the `<h3>`past any left-floating elements, it will allow floated elements to appear on the right side of `<h3>`elements.

And `clear:none`allows elements to float either to either side of an element. Like:

```html
<h3 style="clear:none;">
    What's with all the Neo?
</h3>
```

### Positioning -- 

Can choose one of 5 types of positioning, which affect how the element’s bix is generated, by using the `position`property -- like: `static relative sticky absolute fixed` -- initial value is `static`

- `static`-- The element’s box is generated as normal. Bloak-level elements generates a Rectangle box that is part of the document’s flow, and inline-level boxe cause the creation of one or more line boxes that are flowed within their parent element.
- `relative`-- The element’s box is offset by a certain distance, `0px`by default. Note that the element retains the shape it would have had were it is not positione, and the space that the element would ordinarily have occupited is preserved.
- `absolute`-- Note -- box is completed **removed** from the flow of the document and positioned relative to its closest positioned ancestor.
- `fixed`-- The element’s box behavies as through it was set to `absolute`, but contaiing bock is jsut the viewport itself.
- `sticky`-- is left in the normal flow, until the conditions that trigger its stickness come to pass.

For nonroot element whose `positin`value is `relative`or `static`-- its containing block is frmed by the conent edge of the nearest block-level, table-cess, or inline-block ancestor box.

For a nonroot element that has a `position`value of `absolute`, its containing block is set to the nearest ancestor that has a `position`value *other than `static`*.

- if the ancestor is block-level, the containing block is set to be that element’s padding edge.
- If inline, set to the content edge of the ancestor.

#### Offset properties -- 

Four of the positioning schemes described in the -- It is important to remember that the offset properties define an offset from the analogous side -- defines the offset from the block-end side -- of the containing block not from the upper-left corner of the containing block. just like:

```css
#contain {position: relative; background: rgba(0,128,216,0.33);
  height: 300px; width: 500px;}
#example {position: absolute; background: rgba(216,128,0,0.67);
   top: 50%; bottom: 0; left: 50%; right: 0;}
```

Note that the background area of positioned element -- has no margains, but if it deid, would create blacnk space between the borders and the offset edge.

```css
#example {position: absolute; background: rgba(216,128,0,0.67);
  top: 50%; bottom: -2em; left: 75%; right: -7em;}
```

By using negative offset values, can position an element outside its containing block, fore, the following like:

`inset`shorthands -- In addition to the logical inset properties mentinoed in the previous section, CSS has a few inset shorthand -- two logicl and one physical. like `inset-block: 10px`just use 10 px of insert for both the block-start and block-end edges.

#### Setting width and Height

After determining where you are going to position an element, you will often want to declare how wide and how high tha the element should be. Note that although it is sometimes important to set the `width`and `height`of a positioned element, it is not always necessary, fore, if the placement of the 4 sides of the element is declared using `top..`then the `height`and `width`of the element are implicitly determined by the offsets. like:

```css
elem {inset: 0 50% 0 0; width: 50%; height: 100%;}
```

## Introducing Rx Concepts --

Observabales are like arrays in that they represent a *collection* of events, but are also like promises in that they are async -- each event in the collection arrives at some indeterminate point in the future. This is distinct from a collection of promises in that an observable can handle an arbitrary number of events, and a promise can only track one thing. An observable can be used to model clicks of a button, represents all the clickcs that will happen some point in the future that we can’t predict.

```ts
let myObj$ = clicksOnButton(myButton);
myObj$.subscribe(
	clickEvent => console.log("The button was clicked");
)
```

### Building a stopwatch

This timer will need to track the total number of seconds elapsed and emit the latest value every 1/10th of a second. When the stop button is pressed, the interval should be cancelled.

```ts
let tenthSecond$ = new Observable(
    observer => {
        let counter = 0;
        observer.next(counter);
        let interval = setInterval(() => {
            counter++;
            observer.next(counter);
        }, 100);
        return function unsubscribe() {
            clearInterval(interval);
        };
    }
);
```

Technically, an `observer`is any object that has the following -- `next(sth)`and `error(someError)`and `complete()`. Then insde the ctor function -- there is an internal state in the `couter`variable that tracks the number of tens-of-a-second since the start -- Immediately, `observer.next`is called with the initial value of 0. Then there is an interval that fires every 100 ms, incrementing the counter and calling the `observer.next(counter)`.

Finally, the inner function returns yet another function like:

`return function unsubscribbe(){clearInterval(intval);};`

Returns another function -- this inner function runs whenever a listener unsubscribes from the soruce observable, in this case, the interval is no longer needed. This just save CPU cycles.

All of thise work has already been implemented in the Rx library in the form of *creation* operator - like:

`let tenSecond$ = interval(100);`

```ts
tenthSecond$.subscribe(console.log);
```

Piping data through operators -- An operator is a tool provided by RxJS that allows U to manipulate the data in the observable as it streams through.

```sh
export NODE_OPTIONS=--openssl-legacy-provider
```

```ts
interval(100)
.pipe(
	exmapleOperator()
)
```

Manipulating data in the flight with Map -- have a colleciton of a almost data that needs just one little tweak -- 

```ts
function trackClickEvents(element){
    return new Observable(observer => {
        let emitClickEvent= event=> observer.next(event);
        element.addEventListener('click', emitClickEvent);
        return()=> elemnt.removeEventListener(emtiClickEvent);
    })
}
```

```ts
let tenthSecond$ = interval(100);
let startClick$ = fromEvent(startButton, 'click');
let stopClick$ = fromEvent(stopButton, 'click');

startClick$.subscribe(() => {
    tenthSecond$.pipe(
        map(item => item / 10),
        takeUntil(stopClick$)
    ).subscribe(num => resultsArea.innerText = num + 's');
});
```

So when the start button is clicked, the subscribe function is triggered. The actual click event is ignored, as this implementation doesn’t care about the specifics of the click, just it happened, immediately, `tenthSecond$`runs its ctor cuz there is a subscribe call at the end of the inner chain.

`takeUntil`is an operator that attaches itself to an observable stream and takes values from the stream *until* the observable that is passed in as an argument emits a value.

#### Drag and Drop

Another example of RXjs’s power is drag-and-drop -  Adding to the confusion, a flick of the user’s wrist can generate just thousands of mousemove events.

```ts
let draggable = <HTMLElement>document.querySelector("#draggable");
let mouseDown$ = fromEvent(draggable, 'mousedown');
let mouseMove$ = fromEvent(document, 'mousemove');
let mouseUp$ = fromEvent(document, 'mouseup');

mouseDown$.subscribe(() => {
        mouseMove$.pipe(
            map((event: MouseEvent) => {
                event.preventDefault();
                return {
                    x: event.clientX,
                    y: event.clientY
                };
            }),
            takeUntil(mouseUp$)
        ).subscribe(pos => {
            draggable.style.left = pos.x + 'px';
            draggable.style.top = pos.y + 'px';
        })
    }
)
```

At the start are the same bunch of variable declarations that you saw in the stopwatch example. The code tracks a few events on the entire HTML document, though if only one element is a valid area for dragging, that could be passed in. The initiating observable, `mouseDown$`is subscribed, in the subscription, each `mouseMove$`is mapped, so that the only data passed on are the current coordinates of the mouse.

#### Using a Subscription

There is one more vocabulary word before -- *subscription* while piping through an *operator* returns an observabe. This means whenever the program no longer needs the values from that particular observable stream, can use the subscirption to unsubscribe from all future events like:

`aSubscription.unsubscribe();`

And some operators, like `takeUntil`above, handle subscriptins internally, most of the time your code manages subscriptions manually. Can :

```ts
// combine multiple subscriptions
aSubscription.add(bSubscription);
aSubscription.add(cSubscription);
aSubscription.add(()=>console.log('Custom unsubscribe function'))
// Calls all three unsubscribes and the custom function
aSubscription.unsubscribe();
```

