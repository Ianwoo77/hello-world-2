# Type and Interface Composition

Instead relies an approach known as composition. Composition is the process by which new types are created by combining structs and interfaces. Composition can be used to create hierarchies of types, just in a different way.

Go doesn't support classes, it doesn't support class constructor -- A common convention is to define a constructor function whose name is `New<Type>`like:

```go
func main() {
	kayak := store.NewProduct("Kayak", "Watersports", 275)
	lifejacket := &store.Product{Name: "Lifejacket", Category: "Watersports"}

	for _, p := range []*store.Product{kayak, lifejacket} {
		fmt.Println("Name:", p.Name, "Category:", p.Category, "Price:", p.Price(0.2))
	}
}

```

Go supports composition, rather than inheritance -- like:

```go
type Boat struct {
	*Product
	Capacity  int
	Motorized bool
}

func NewBoat(name string, price float64, capacity int, motorized bool) *Boat {
	return &Boat{
		NewProduct(name, "Watersports", price), capacity, motorized,
	}
}
```

A struct can mix regular and embedded field types, but the embedded fields are important part of the compisition feature.

```go
func main() {
	boats := []*store.Boat{
		store.NewBoat("Kayak", 275, 1, false),
		store.NewBoat("Canoe", 400, 3, false),
		store.NewBoat("Tender", 650.25, 2, true),
	}

	for _, b := range boats {
		fmt.Println("Conventional", b.Product.Name, "Direct:", b.Name)
	}
}
```

The new creates a `*Boat`slice of Boat -- Go gives special treatment to struct types that have fields whose type is another struct type. In the way that the `Boat`type has a `*Product`field in the example project. Go allows the fields of the nested type to be accessed in two ways.

The `Boat`type doesn't define a `Name`field, can be treated as though it did cuz of the direct access feature. *filed promotion*.

## Creating a Chain of Nested Types

The composition feature can be used to create complex chains of nested types, whose fields and methods are promoted to the top-level enclosing type.

```go
type RentalBoat struct {
	*Boat
	IncludeCrew bool
}

func NewRentalBoat(name string, price float64, capacity int,
	motorized, crewed bool) *RentalBoat {
	return &RentalBoat{NewBoat(name, price, capacity, motorized), crewed}
}
```

```go
func main() {
	rentals := []*store.RentalBoat{
		store.NewRentalBoat("Rubber Ring", 10, 1, false, false),
		store.NewRentalBoat("Yacht", 50000, 5, true, true),
		store.NewRentalBoat("Super Yacht", 100000, 15, true, true),
	}

	for _, r := range rentals {
		fmt.Println("Rental Boat", r.Name, "Rental price", r.Price(0.2))
	}
}
```

## Using Multiple Nested Types in the Same Struct

Go can perform promotino only if there is no field or method defined with the same name on the enclosing type.

```go
type SpecialDeal struct {
	Name string
	*Product
	price float64
}

func NewSpecialDeal(name string, p *Product, discount float64) *SpecialDeal {
	return &SpecialDeal{name, p, p.price - discount}
}

func(deal *SpecialDeal) GetDetails() (string, float64, float64) {
	return deal.Name, deal.price, deal.Price(0)
}
```

For the `SpecialDeal` -- has fields with the same names. Go can promote the `Price`method, but when it is invoked, uses the `price`field from the `Product`instead of the `SpecialDeal`. And when the method is invoked through its struct field, it is just clear that the result from the calling the `Price`method isn't going to use the `price`defined in the `SpecialDeal`type.

## Promotion Ambiguity

```go
type OffBundle struct {
    *store.SpecialDeal
    *store.Product
}

bundle := OfferBundle {
    store.NewSpecialDeal("Weekend Special", kayak, 50),
    store.NewProduct ("Lifejacket", "Watersports", 48.95),
}
fmt.Println("Price:", bundle.Price(0))
```

ambigous selector 

## Understanding Composition and Interfaces

This can seem just similar to writing classes in other languages, but there is an important difference -- which is that each composed type is distinct and cannot be used where the the types from which is composed are required.

```go
products := map[string]*store.Product {
    "Kayak": strore.NewBoat(...)
    "Ball": store.NewProduct(...)
}
```

Note the Go compiler will not allow a `Boat`to be used as a value in a slice where `Product`values are required. In a Lang like C# -- this would be allowed cuz `Boat`would be a subclass of `Product`.

## Using Composition to Implemenet Interfaces

Go takes promoted methods into account when determining where a type conforms to an interface.

```go
func main() {
	products := map[string]store.ItemForSale{
		"Kayak": store.NewBoat("Kayak", 279, 1, false),
		"Ball":  store.NewProduct("Soccer Ball", "soccer", 19.50),
	}

	for key, p := range products {
		fmt.Println("Key:", key, "Price:", p.Price(0.2))
	}
}
```

## Type Switch Limitation

`case`statements that specify multiple types will match values of all those types but will not perform type assertion. This means that `*Product`and `*Boat`values will be matched by the `case`statemnt.

And an alternative solution is to define interface methods that provide acces to the property values.

```go
type Describable interface {
    GetName() string
    GetCategory() string
}

func (p *Product) GetName() string {...}
func (p *Product) GetCategory() string {...}

//...
switch item := p.(type) {
    case store.Describable:
    fmt.Println(item.GetName()..., item.(store.ItemForSale).Price(0.2))
}
```

## Composing Interfaces

```go
type Describable interface{
    GetName() string
    GetCategory() string
    ItemForSale
}
//...
switch item:= p.(type) {
case store.Describable:
    fmt.Println(..., "Price:", item.Price(.2))
}
```

```sh
go get github.com/go-sql-driver/
```

## Usage in Web app

```go
db, err := sql.open(/*connection string*/)
if err = db.Ping(); err!=nil {
    log.Fatal(err)
}
```

`sql.Open`doesn't actually create any connections -- is initialize the pool for future use. Actual connections to the dbs are established lazily.

## Designing a Dbs Model

The idea is that will encapsulate the code for working with `MySQL`in a separate package to the rest of the app.

1. There is a clean separation of concerns.
2. By creating a custom `SnippetModel` -- single, neatly encapsulated object.
3. Cuz the model actions are defined as methods on an obj, there is the opportunity to create an *interface* and mock it for unit testing.

To do this execute the following query -- like:

## Executing the Query

Go provides 3 different methods for executing dbs queries -- 

* `DB.Query()`for `SELECT`
* `DB.QueryRow()`for returning a single row
* `DB.Exec()`for `INSERT`and `DELETE`

```go
func (m *SnippetModel) Insert(title, content, expires string) (int, error) {
	stmt := `INSERT INTO snippets(title, content, created, expires) 
				values ($1, $2, now(), now()+interval '$3' day)`
	result, err := m.DB.Exec(stmt, title, content, expires)
	if err != nil {
		return 0, err
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, err
	}
	return int(id), nil
}
```

* `LastInsertId()`-- returns the integer generated by the dbs in response to a command.
* `RowsAffected()`-- returns the number of rows affected by the statement.

And, it is just perfectly acceptable to ignore the `sql.Result`. like:

```go
_, err := m.DB.Exec("Insert into...", ...)
```

## Using the Model in Handlers

And behind --

1. Creates a new *Prepared statement* on the dbs using the provided SQL statement. The dbs parses and compiles the statement, then stores it ready for execution.

## Single-record SQL Queries

How to update `SnippetModel.Get()`method so that it returns a single specific snippet based on its ID. Like:

```go
func (m *SnippetModel) Get(id int) (*models.Snippet, error) {
	stmt := `select id, title, content, created, expires from snippets
		where expires>now() and id=$1`
	row := m.DB.QueryRow(stmt, id)

	s := &models.Snippet{}

	err := row.Scan(&s.ID, &s.Title, &s.Content, &s.Created, &s.Expires)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, models.ErrNoRecord
		} else {
			return nil, err
		}
	}

	return s, nil
}
```

```go
func (app *application) showSnippet(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.URL.Query().Get("id"))
	if err != nil || id < 1 {
		app.notFound(w)
		return
	}

	s, err := app.snippets.Get(id)
	if err != nil {
		if errors.Is(err, models.ErrNoRecord) {
			app.notFound(w)
		} else {
			app.serverError(w, err)
		}
		return
	}

	fmt.Fprintf(w, "%v", s)
}
```

## Sentinel Errors and `errors.Is()`

`errors.Is()`function -- which was introduced in go 1.13 to check an error matches a specific value. In the case, wanted to check if an error matched `sql.ErrNoRows`. Typically you create them using the `errors.New()`function.

```go
if err == sql.ErrNoRows {}
else {}
```

From 1.13 like:

```go
if errors.Is(err, sql.ErrNoRows){}
else {}
```

Ability to wrap errors to add additional info.

# Understanding the Form Handling Pattern

Most HTML forms exist within a well-defined pattern. Post/Redirect/Get pattern -- and the redirection is important cuz it means the user can click the browser's reload button.

### Using Tag helpers to Improve HTML Forms

The `FormTagHelper`class is the built-in tag helper for `form`elements and is used to just mange the configuration of HTML forms. The routing system is used to generate a URL that will target the specified method, which means that changes to the routing configuration will be reflected automatically in the form URL.

```html
<form method="post" action="/Form/submitform">
    ...
</form>
<form method="post" action="/pages/form">
    ...
</form>
```

Working with `input`elements

* `asp-for`-- used to specify the view model property that the `input`element represents
* `asp-format`-- used to specify a format used for the value of the view model.

note -- `asp-for`is set to the name of a view model property, which is then used to set the `name, id, type value`attributes of the `input`element.

```html
<input class="form-control" type="text" data-val="true" id="Name" name="Name"
       value="kayak" />
```

The value of the `type`attribute is just determined by the type of the view model property specified by the `asp-for`attr. note: For `float, double, decimal`in the input tag -- just `text`, for `bool`, it's `checkbox`, for `string`, it's `text`, for `DateTime`, it's `datetime`.

And a more elegant and **reliable** approach is to apply one of the attributes just like:

`[DataType(DataType.Password)]`, or Time, or Date, 

`[HiddenInput], [Text], [Phone], [Url]`

### Displaying Values from Related Data in Input Elements

```cs
public async Task<IActionResult> Index(long id = 1)
    {
        return View("Form", await context.Products.Include(p => p.Category)
            .Include(p => p.Supplier).FirstAsync(p => p.ProductId == id));
    }
```

And the same technique is used in Razor pages, except that the properties are expressed relative to the page model.

### Working with label elements

The `LabelTagHelper`class is used to transform `label`elements so the `for`attribute is set consistently with the approach used to transform `input`elements.

### Working with `Select`and `Option`Elements

The `select`and `option`are just used to provide the user with a fixed set of choices, rather then the open data entry that is possible with an `input`element. Just note:

```html
<option value="2" selected="selected">Soccer</option>
```

And the `asp-items`attribute is used to provide the tag helper with a list sequence of `SelectListItem`objects for which option elements will be gnerated like:

`ViewBag.Categories
                = new SelectList(context.Categories, "CategoryId", "Name");`

`SelectListItem`objects can be created directly -- provides the `SelectList`class to adapt existing data seq. Pass the seq of `Category`objs obtained from the dbs to the `SelectList`ctor.

```html
<select class="form-control" asp-for="CategoryId" 
        asp-items="@ViewBag.Categories"></select>
```

## Web APIs

A type of software interface that exposes tools and services that can be used by different computer programs to interact with each other by exchanging info. The connection between these parties required to perform such exchange is established using common communication standards - JSON, XML..

### .NET SDK

The most important tool to obtain is the .NET Software development kit -- which contains the .NET Command-line interface -- .NET CLI and the .NET libraries and the 3 available runtimes:

* Core runtime -- required to run ASP.NET core apps
* Desktop runtime -- required to WPF and forms app
* .NET runtime -- hosts a set of low-level libs and interfaces required by the two runtime above.

```cs
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/error");
}
```

ExceptionHandlingMiddleware -- also handle HTTP-level exceptions.

Start with the `controller-based`approach -- from the vs' Solution Explorer like:

```cs
app.MapGet("/error", ()=>Results.Problem());
```

REST Guiding Constraints -- The whole purpose of `CORS`is to access resources using HTTP request initiated from scripts, such as .. When those resources are located on domains other than one hosting the script. Only allows them when the protocol, port and host values are the same for both the page hosting the script.

## Avoiding the Query Pitfalls

Understanding the `IEnumerable<T>`pitfalls -- EF core makes it just easy to query a dbs using LINQ -- In the `Index`View used by the `Home`controller, use the `LINQ``Count`method to determine how many.

To determine -- EF core uses a SQL SELECT statement to get all the `Product`data. Use that data to create a series of `Product`objects, and then counts them -- as soon as the counting is complete, the `Product`objects are discarded. So more effective way to do : `@model IQueryable<Product>`

Note that the `SELECT COUNT`query asks the dbs server to count the `Product`objects and doesn't retrieve data or create any objects in the application.

For `IQueryable<T>`interface, represents a dbs query, and these duplicate methods means that operations such as `Count`can be performed as easily on data stored in the dbs. This version of the method allows EF core to translate the complete query into SQL and produces the more efficient version that uses `SELECT COUNT`to get the number. This behavior also means that a fresh SQL query is sent to the dbs each time an `IQueryable<T>`is enumerated.

```css
<style>
    .placeholder {
    visibility: collapse;display: none;
    }
    .placeholder:only-child{
    visibility: visible;display: flex;}
</style>
```

### Forcing Query Execution in the Repository

And the problem with working directly with `IQueryable<T>`objects is that details of how data storge has been implemented have leaked into other parts of the application, which undermines the sense. An alternative approach is to have the repository implementation class take reposibility for dealing with the quirks of `IQueryable<T>`



```cs
public IEnumerable<Product> Products => context.Products.ToArray();
```

NOTE: The LINQ `ToArray`and `ToList`... trigger the execution of the query and produce an array or a list.

```js
let paragraph = document.createElement('p');
let emphasis = document.createElement('em');
emphasis.append('world'); // append text to the <em>
paragraph.append("hello", emphasis, '!')
```

```html
<script>
export default {
  name: 'app',
  data() {
    return {
      name: "Adam"
    };
  }
}
</script>
```

```html
<div class="row" v-for="t in tasks" v-bind:key="t.action">
    <div class="col">{{ t.action }}</div>
    <div class="col-2">{{t.done}}</div>
</div>
```

This is an example of a *directive*, which are special attributes whose names start with `v-`and that are applied to HTML elements to apply `Vue.js`functionality.

The `v-model`directive configures an `input`element so that it displays the value specified by its expression. Can see how this works by checking and unchecking one of the checkboxes.

```js
  computed: {
    filteredTasks() {
      return this.hideCompleted ?
          this.tasks.filter(t => !t.done) : this.tasks;
    }
  }
```

In this script, added this -- using a function .

The `input`element uses the `v-model`directive to create a binding with a variable called `newItemText`, and when the user edits the contents element, Vue.js will update the value of the variable. To trigger the creaton of the new data item, applied the `v-on`directive to the `button`element.

The `v-on`just used to respond to events, which are typically tirggered when the user performs an action. To support the changes in the `template`, The`v-model`binding that updates the `newItemText`value when the content of the `input`element changes works in the other direction too.

The `created`method added to the `component`is called when `Vue.JS`creates the component and it provides me with an opportunity to load the data from local storage before the app's content is presented to the user.

```html
<div class="row" v-if="filteredTasks.length==0">
        <div class="col text-center">
          <b>Nothing to do. Hurrah!</b>
        </div>
      </div>
      <template v-else>
        <div class="row">
          <div class="col fw-bold">Task</div>
          <div class="col-2 fw-bold">Done</div>
        </div>

        <div class="row" v-for="t in filteredTasks" v-bind:key="t.action">
          <div class="col">{{ t.action }}</div>
          <div class="col-2 text-center">
            <input type="checkbox" v-model="t.done" class="form-check-input"/>
            {{ t.done }}
          </div>
        </div>
      </template>
```

The `v-if`and `v-else`are used to display elements conditionally.

In the Round-trip applications, the browser requests an initial from the server -- User interactions, such as clicking a link or submitting a form -- led the browser to request and receive a completely new HTML document. All of the application logic and data resides on the server. A browser makes a series of stateless HTTP requests that the server handles by generating HTML dynamically.

SPAs take a different approach. An initial HTML document is sent to the browser, user interactions lead to Ajax for small fragments of HTML or data inserted into the existing set of elements being displayed to the user.

## Container collapsing and the clearfix

floated elements do not add height to their parent elements -- odd, goes back to the original purpose of floats. For this, only the page title contributes height to the container, leaving all the floated media elements extending below the white background of the main.

For the float's companion property -- `clear`like:

```html
<main class="main">
	...
    <div style="clear:both">
        nothing
    </div>
</main>
```

The `clear:both`just causes the element to move below the buttom of floated elements. rather beside them.

```css
.clearfix::after{
    display:block;
    content:" ";
    clear: both;
}
```

Some prefer to use a modified version of the clearfix that will contain all margins cuz it can be slightly more predictable.

```css
.clearfix::before,
.clearfix::after{
    display: table;
    content: " ";
}
.clearfix::after{
    clear:both;
}
```

This version makes use of `display:table`rather than `display:block`.

### Unexpected float catching 

target these with the `:nth-child(odd)`selector.

```css
.media:nth-child(odd){
    clear:left;
}
```

Can establlish a new block formatting context in several ways -- 

`float:left`, `overflow:auto`, `display:flow-root`. `position:absolute`or `fixed`.

```css
.row::after{
    content: " ";
    display: block;
    clear:both;
}
```

```css
[class*="column-"]{float:left;}
.column-1{width:8.3333%;}
.media-body {
    overflow:auto;
    margin-top:0;
}
```

Adding gutters -- 

```css
[class*="column-"] {
    float:left;
    padding:0 0.75em; /* add .75 left and right padding to each column element */
    margin-top:0;
}
```

# Flexbox

Begins with the `display`property -- applying `display:flexbox`to an element turns it into a `flex container`. and its **direct** children turn into *flex items*.

flex items align side by side, left to right, all in one row. The flex container fills the available width like a block element, but the flex items may not necessarily fill the width of their container. And the flex items are all the same height. To build this menu, just consider which element needs to be the flex container.

```css
.site-nav {
    display: flex;
    padding-left:0;
    list-style-type: none;
    background-color: #5f4b44;
}

.site-nav li{
    margin-top:0;  /* override the lobomized owl top margin */
}

.site-nav > li > a {
    background-color: #cc6b5a;
    color:white;
    text-decoration: none;
}
```

For this, will need to add space between the menu items -- but... flexobx allows to use `margin:auto` to fill available space between the flex items.

```css
.site-nav > li + li {
    margin-left:1.5em;
}

.site-nav > .nav-right {
    margin-left: auto;  /* auto will fill the available space */
}
```

```css
.flex {
    display: flex;
}

.tile {
    padding: 1.5em;
    background-color: #fff;
}

.flex > * + * {
    margin-top: 0;
    margin-left: 1.5em;
}
```

When comes to CSS, it's just important to consider not only the specific content you have on the page now, but also what will happen as that content changes.

The `flex`property -- applied to the flex items -- give you a number of options -- like: using `flex`to apply widths of two-thirds and one third like:

```css
.column-main {
    flex: 2;
}

.column-sidebar {
    flex: 1;
}
```

Note that the `flex`prop is shorthand for 3 different sizing prop -- 

`flex-grow, flex-shrink, flex-basis`, flex:2 is equivalent to flex 2 1 0%.