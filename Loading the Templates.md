# Loading the Templates

```go
var templates = make(map[string]*template.Template, 3)
```

The key type for this map is `string`and the value is `*template.Template`, which means a pointer to the `Template`struct defined in the `template`package. When import a package, accessed using the last part of the package name.

```go
func loadTemplate() {
	templateNames := [5]string{"welcome", "form", "thanks", "sorry", "list"}
	for index, name := range templateNames {
		t, err := template.ParseFiles("layout.html", name+".html")
		if err == nil {
			templates[name] = t
			fmt.Println("Loaded template", index, name)
		} else {
			panic(err)
		}
	}
}
```

`ParseFiles`is used to load and process HTML files -- return multiple result values. The `ParseFiles`is. just so , t is the type of `*template.Template`.

## Creating the HTTP handlers and Server

invoked when the user requests the default URL path for the app, .. 

```go
func welcomeHandler(writer http.ResponseWriter, request *http.Request) {
	templates["welcome"].Execute(writer, nil)
}

func listHandler(writer http.ResponseWriter, request *http.Request) {
	templates["list"].Execute(writer, responses)
}

func main() {
	loadTemplate()
	http.HandleFunc("/", welcomeHandler)
	http.HandleFunc("/list", listHandler)
}
```

The first arg is an example of an interface..and the second just the pointer to an instance of the `Request`. The second arg is a data value that can be used in the expressions contained in the template.

```go
err := http.ListenAndServe(":5000", nil)
if err != nil {
    fmt.Println(err)
}
```

## Form handling Function 

```go
type formData struct {
	*Rsvp
	Errors []string
}

func formHandler(writer http.ResponseWriter, request *http.Request) {
	if request.Method == http.MethodGet {
		templates["form"].Execute(writer, formData{
			Rsvp: &Rsvp{}, Errors: []string{},
		})
	}
}
```

There is no data to use when responding to GET requests. But need to provide the template with the expected data structure. Just default values for these. Values are created using braces, with default values being used for any field for which a value is not specified. The `&`created a pointer to a vlaue.

## Handling the form data

Now need to handle `POST`request and read the data from the user.

```go
func formHandler(writer http.ResponseWriter, request *http.Request) {
	if request.Method == http.MethodGet {
		templates["form"].Execute(writer, formData{
			Rsvp: &Rsvp{}, Errors: []string{},
		})
	}else if request.Method==http.MethodPost {
		request.ParseForm()
		responseData := Rsvp {
			Name: request.Form["name"][0],
			Email: request.Form["email"][0],
			Phone: request.Form["phone"][0],
			WillAttend: request.Form["willattend"][0]=="true",
		}
		responses = append(responses, &responseData)
		
		if responseData.WillAttend{
			templates["thanks"].Execute(writer, responseData.Name)
		}else {
			templates["sorry"].Execute(writer, responseData.Name)
		}
	}
}
```

The `ParseForm`processes the form data contained in an HTTP request and populates a map, which can be accessed through the `Form`field.

## Adding Data validation

```go
errors := []string{}
if responseData.Name == "" {
    errors = append(errors, "Please enter your name")
}
if responseData.Email == "" {
    errors = append(errors, "Please enter your email address")
}
if responseData.Phone == "" {
    errors = append(errors, "Please enter your phone number")
}
if len(errors) > 0 {
    templates["form"].Execute(writer, formData{
        Rsvp: &responseData, Errors: errors,
    })
}
```

# Web App Basics

* The first is a handler, can think of handlers as being a bit like controllers.
* Second is a router (servemux in go). Stores a mapping between the URL patterns for app and corresponding handlers.
* Last is a web server. NOTE: don't need an external third-party server like Nginx or Apache. Like

```go
func home(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello from Snippetbox"))
}

func main() {
	// Use the http.NewServeMux() to initialize a new servemux
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)

	log.Println("Starting server on: 4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}

```

## Requests

Go's servemux supports two different types of URL patterns, fixed or subtrees. Pattern "/" is just an example of a subtree path. Another is like "/static/", can think like "/**".. This just helps explain why the "/" pattern is acting like a catch-all. So need Restricting the root URL pattern.

```go
func home(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	w.Write([]byte("Hello from Snippetbox"))
}
```

## DefaultServeMux

For: `http.HandleFunc("/", home)...`behind, routes with sth  called DefaultServeMux -- There is nothing special -- just regular servemux like already using -- is initialized by default and stored in `net/http`global variable.

```go
var DefaultServeMux= NewServeMux()
```

Cuz, `DefaultServeMux`is a global variable, any package can access it and register a route. malicious maybe.

## Host Name Matching 

Possible to include host names in URL patterns. fore, want to redirect all requests to a canonical url. Any host-specific patterns will be checked first, and if there is a match the request will be dispatched to the corresponding handler.

Go's servemux is pretty lightweight. doesn't support routing  based on the request method, doesn't support semantic URLs. regexp-based patterns.

## Customizing HTTP headers

`/snippet/create`changed to POST.. HTTP status codes. update like:

```go
func createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed) // 405
		w.Write([]byte("Method Not Allowed"))
		return
	}
	w.Write([]byte("Creating a new snippet..."))
}
```

Another imporvement we can make is to include an `Allow: post`header with every 405 method not Allowed response to let the user know which request methods are supported for that particular URL. 

Can do this by using the `w.Header().Set()` method to add a new header to the response header map.

## The `http.Error`shortcut

If want to send a non-200 status code and just plain-text response body then it's just good opportunity to use the `http.Error()` *shortcut*. lightweight helper function which takes a given message and status code.

```go
func createSnippet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.Header().Set("Allow", http.MethodPost)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	w.Write([]byte("Creating a new snippet..."))
}
```

The biggest difference is that we're now passing our `http.ResponseWriter`to another function, which sends a response to the user for us. The pattern of passing `http.ResponseWriter`to other function is super-common in Go.

## Additional Info

Also, `Add(), Del(), Get()`, `Set()`for existing, Add,Del, `Get()`for retrieving.

When sending a response Go will automatically set 3 system-generated headers for U -- `Date`, `Content-Length`and `Content-Type`. The `http.DetectContentType()`function generally works, can:

```go
w.Header().Set("Content-Type", "application/json")
w.Write([]byte(`{"name": "Alex"}`))
// Cuz by default, json responses will be sent with text/plain
```

Suppressing Systtem-Generated Headers -- `Del()`method doesn't remove system-generated headers. so:

```go
w.Header()["Date"]=nil
```

## URL Query Strings

To make this work.. fore, retrieve the value of the `id`parameter from the URL query string. like: `/snippet?id=1`. id is untrusted user input, validate it to make sure. `strconv.Atio()`func.

```go
func showSnippet(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		http.NotFound(w, r)
		return
	}
	fmt.Fprintf(w, "Display a specific snippet with ID %d", id)
}
```

For all other, should get a 404.

# The `catch`clause

`System.Exception` Can specify an *exception filter* in a `catch`clause. like:

```cs
catch(WebException ex) when (ex.Status == WebExceptionStatus.Timeout)
```

## `using`declarations

if omit the brackets and statement block from C# 8 like:

```cs
if (File.Exists("file.txt")) {
    using var reader= File.OpenText("file.txt");
    Console.WriteLine(reader.ReadLine());
}
```

The resource is then disposed when execution falls outside the *enclosing* statement block.

## Rethrowing an exception

For this, lets you just log an error without *swallowing* that. The most important props of `System.Exception`are the following -- `StackTrace`-- A string representing all the methods , `Message`, and `InnerException`.

## `TryXXX`Method Pattern

like:

```cs
public return_type XXX(input-type input) {
    return_type returnValue;
    if(!TryXXX(input, out returnValue))) throw new YYYException();
    return returnValue;
} // like:
public int Parse(string input);
public bool TryParse(string input, out int returnValue)
```

## Enumeration and Iterators in C#

1. public parameterless method named `MoveNext`and property called `Current`
2. Implements `IEnumerator<T>`and non-generic edition

```cs
class Enumberable {
    public Enumerator GetEnumerator();
}
```

Whereas a foreach statement in a consumer of an enumerator, an iterator is a *producer* of an enumerator. fore:

```cs
IEnumerable<int> Fibs(int fibCount)
{
    for (int i=0, prevFib=1, curFib=1; i < fibCount; i++)
    {
        yield return prevFib;
        int newFib = prevFib + curFib;
        prevFib = curFib;
        curFib=newFib;
    }
}

Fibs(6).ToList().ForEach(x => { Console.Write(x.ToString() + ' '); });
```

Here is the value asked to return from this method -- on each `yield`, control is returned to the caller, but the callee's state is maintained so that the method can continue executing as soon as the caller enumerates the next element. And a `yield return`statement cannot appear in a `try`block that has a `catch`. But `finally`ok.

## Nullable Reference Types

Whereas nullable value types bring nullability to value types, nullable reference types **do the opposite**. When enabled, they bring *non-nullability* to reference types. Help to avoid `NullReferenceExceptions`. If want a reference type to accept nulls without the warning, must apply the `?`to indicate a nullable reference type.

```cs
public static T First<T> (this IEnumerable<T> sequence) {
    foreach(T element in sequence) 
        return element;
    throw new...
}
```

## Tuples

provide a simple way to store a set of values.

```cs
var bob = ("Bob", 23);
bob.Item1; bob.Item2; // Tuples are value types
```

```cs
(string, int) bob = ("Bob", 23);
// Naming tuple
var tuple= (name:"Bob", age:23);
tuple.name; tuple.age;
(string name, int age) GetPerson()=> ("Bob", 23);
```

## Records

Is a special kind of class or struct, read-only data. Records give you structural equality by default. Means that two instances are the same if their data is the same.

```cs
record Point{}
record struct Point{}
```

```cs
record Point
{
    // A simple record contain just a bunch of init-oinly props and ctor perhaps
    public double X { get; init; }
    public double Y { get; init; }
    public Point(double x, double y) => (X, Y) = (x, y);
}
```

C# just transforms the record definition into a class and performs the following:

1. protected copy ctor, nondestructive mutation
2. override the equality-related funcs
3. override the `ToString()`. like:

```cs
protected Point(Point orig){
    this.X=orig.X; this.Y=orig.Y
}
```

## parameter list

```cs
record Point(double X, double Y) {
    // can define additional class members
}
// writes an init-only prop per parameter
// writes a primary ctor to populate the properties
// writes a deconstructor
```

like:

```cs
public void Deconstruct(out double X, out double Y) {
    X=this.X; Y=this.Y;
}
```

Note that can be subclassed:

```cs
record Point3D(double X, double Y, double Z) : Point(X,Y);
```

## Nondestructive Mutation

performs all records is to write a copy ctor, and hidden Clone. like:

```cs
Point p1= new Point(3,3);
Point p2= p1 with {Y=4};
```

## Records and Equality Comparsion

```cs
var p1= new Point(1,2);
var p2= new Point(1,2);
p1.Equals(p2); //True
p1==p2; // True
```

## Patterns

property pattern like:

```cs
if(obj is string {Length:4})
```

### var pattern

variation of the type pattern.

The constant pattern is useufl when working with the `object`type like:

```cs
void Foo(object obj) {
    if (obj is 3)...
}
// ...
if (x is > 100)..;
string GetCategory(decimal bmi) => bmi switch{
        <18.5m => "underweight",
        <25m => "normal",
        _ => "obese"
}
```

From 9, can use `and, or, not`.like:

```cs
bool isJohn(string name)=>name.ToUpper() is "JANET" or "JOHN";
```

```cs
// Convert to hertz like:
public static implicit operator double(Note x) =>
    440*Math.Pow(2, (double)x.value/12);
public static explicit operator Note(double x) =>
    new Note(...);

public struct SqlBoolean {
    public static bool operator true(SqlBoolean x) =>
        x.m_value==True.m_value;
    public static readonly SqlBoolean True = new SqlBoolean(2);
    private byte m_value;
    private SqlBoolean(byte value) {m_value=value;}
}
```

# Using a Mocking package

A better is to use a mocking package, which makes it easy to create fake or mock objects for tests. 

```cs
public class HomeControllerTests
    {
        [Fact]
        public void IndexActionModelIsComplete()
        {
            // Arrange
            Product[] testData = new Product[]
            {
                new Product { Name = "P1", Price = 75.10M },
                new Product { Name = "P2", Price = 120M },
                new Product { Name = "P3", Price = 110M },
            };

            var mock = new Mock<IDataSource>();
            mock.SetupGet(m=>m.Products).Returns(testData);
            var controller = new HomeController();
            controller.dataSource = mock.Object;

            // Act
            var model = (controller.Index() as ViewResult)?.ViewData.Model
                as IEnumerable<Product>;

            // assert
            Assert.Equal(testData, model, 
                Comparer.Get<Product>((p1,p2)=>p1?.Name== p2?.Name && p1?.Price==p2?.Price));
            mock.VerifyGet(m=>m.Products, Times.Once);
        }
    }
```

The purpose of the Core platform to receive HTTP requests and send response to them. Dependency injection , for this are objects that are managed by the Core platform can be shared by middleware component.

## Creating custom middleware

The routing middleware is added using two separate methods. `UseRouting`and `UseEndpoints`.

## Using Configuration Data with the Options Pattern

Which is useful way to configure middleware components.

```cs
string city = builder.Configuration.GetSection("Location")["CityName"];
app.MapGet("/", async context=>
{
    await context.Response.WriteAsync($"Hello world from {city}");
});
```

Using the `IAsyncEnumerable<T>`response, which will prevent the request thread from blocking while results are generated.

Most RESTful  web services format the response data using the JSON format.

Creating a web service using a Controller... The drawback of using individual endpoints..

The model binding features can also be used on the data in the request body, which allows clients to send data that is easily received by an action method.

# Creating Objects with `new` 

Almost every js object has a second Js object associated with it. Note created by object literals, `Object.prototype`. Created using `new`using constructor function.

A `delete`expression only deletes own properties. To check, `hasOwnProperty()`and `propertyIsEnumerble()`.

```js
o.hasOwnProperty('toString'); // false. is an inherited property
```

`Object.keys()`returns an array of the names of enumerable own properties of an object.

## Serializing Objects 

Process of converting an object's state to a string from. 

`JSON.stringify`and `JSON.parse()`, serialize and restore Js objects. like: toJSON(), just called toString().

`Array.of()`-- just from its parameters. `Array.from()`is factory -- expects an *iterable* or *array-like* object. works like `[...iterator]`.

`forEach(), map(), ` 

```js
let a = [1,2,3];
a.map(x=>x*x);
a.filter(x=>x<3);
a.every(x=>x<10);
a.every(x=>x%2==0);
```



`spilce()`, delete, delete number, insert from the delete, and return the deleted. `join`method converts all the elements of an array strings and concatenates them. Most Js array methods are purposely defined be generic so they work correctly when applied to array-like objects in addition to true arrays.

```js
const port = (process.argv[2] || process.env.PORT || 3000),
    http = require('http');
http.createServer((req, res) => {
    console.log(req.url);
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/html');
    res.end('<p>Hello world</p>');
}).listen(port);
console.log(`server running at http://localhost:${port}/`);
```

```js
exports.myDateTime = function () {
    return Date();
};
```

```js
const http = require('http');
const url = require('url');

http.createServer((req, res) => {
    res.setHeader('Content-Type', 'text/html');
    res.statusCode = 200;
    const q = url.parse(req.url, true).query;
    console.log(q);
    const txt = q.year + " " + q.month;
    res.end(txt);
}).listen(8080);
```

```js
const http = require('http');
const fs = require('fs');
const path = require('path');

http.createServer((req, res) => {
    let filepath = path.resolve(__dirname, './demofile1.html')
    fs.readFile(filepath, function (err, data) {
        res.setHeader('Content-Type', 'text/html');

        res.statusCode = 200;
        res.write(data);
        return res.end();
    });
}).listen(8080);
```

Ems, the most common relative length unit, are a measure used in typography. 1em means the font size of the current element.

```css
.padded {
    font-size: 16px;
    padding: 1em;
}
```

One way can accomplish this is with the code -- sets the font size of the first .8em as before. like:

```css
ul {
    font-size: .8em;
}
ul ul{
    font-size: 1em;
}
```

And the root node is the ancestor of all other elements in the document. has a special pseudo-class. `:root` , and `rem`is short for root em.

The `calc()`function lets you do basic arithmetic with two or more values. like:

```css
:root {
    font-size: calc(0.5em+1vw);
}
```

custom property -- 

```css
:root {
    --main-font: roboto /* for whole page */
}
p{
    font-family: var(--main-font)
}
```

The `var()`accepts a second, fallback value. fore:

```css
p {
    color: var(--secondary-color, blue);
}
```

```css
:root {
    --main-bg: #fff;
    --main-color: #000;
}

.panel {
    font-size: 1rem;
    padding: 1em;
    border:1px solid #999;
    border-radius: 0.5em;
    background-color: var(--main-bg);
    color: var(--main-color)
}

.panel > h2 {
    margin-top: 0;
    font-size: 0.8em;
    font-weight: bold;
    text-transform: uppercase;
}

.dark {
    margin-top: 2em;
    padding:1em;
    background-color: #999;
    --main-bg:#333;
    --main-color:#fff;
}
```

When the panel uses these, resolve e.g. first on the root, and then on the dark c
