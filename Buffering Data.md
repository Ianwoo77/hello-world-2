# Buffering Data

The `bufio`package provides support for adding buffers to readers and writers.

```go
func (cr *CustomReader) Read(slice []byte) (count int, err error) {
    count, err = cr.reader.Read(slice)
    cr.readCount++
    Printfln(...)
    if err==io.EOF {
        Printfln(...)
    }
    return
}
```

`CustomerReader`as a wrapper around a `Reader`. The implementation of the `Read`method generates output that reports how much data is read and how many read operations are performed.

The final read returned zero, for `EOF`error.

`reader = bufio.NewReader(reader)`

## Performing Buffered Writes

`bufio`also provides support for creating writes that use a buffer.

`NewWriter(w), NewWriter(w, size)`

`Available(), Buffered(), Flush(), Reset(writer), Size()`

```go
func (cw *CustomWriter) Close() (err error) {
	if closer, ok := cw.writer.(io.Closer); ok {
		closer.Close()
	}
	Printfln("Total writes : %v", cw.writeCount)
	return
}
```

```go
func main() {
	text := "It was a boat. A small boat."

	var builder strings.Builder
	var writer = bufio.NewWriterSize(NewCustomeWriter(&builder), 20)

	for i := 0; true; {
		end := i + 5
		if end > len(text) {
			writer.Write([]byte(text[i:]))
			writer.Flush()
			break
		}
		writer.Write([]byte(text[i:end]))
		i = end
	}
	Printfln("Written data: %v", builder.String())
}
```

The transition to buffered `Writer`-- Call the `Flush`to ensure that all data is just written out.

## Formatting and Scanning with Readers and writers

Scanning from a Reader -- The `fmt`provides functions for scanning values from a `Reader`..

```go
func main() {
	reader := strings.NewReader("Kayak Watersports $279.00")
	var name, category string
	var price float64
	scanTemplate := "%s %s $%f"

	_, err := scanFromReader(reader, scanTemplate, &name, &category, &price)
	if err != nil {
		Printfln("Error: %v", err.Error())
	} else {
		Printfln("Name: %v, \nCategory: %v, \nPrice: %2.f", name, category, price)
	}
}
```

A useful technique when using a `Reader`is just to scan data grdually using a loop.

```go
func main() {
	reader := strings.NewReader("Kayak Watersports $279.00")
	for {
		var str string
		_, err := scanSingle(reader, &str)
		if err != nil {
			if err != io.EOF {
				Printfln("Error: %v", err.Error())
			}
			break
		}
		Printfln(str)
	}
}
```

## Writer Formatted Strings

Also, provides functions for writing formatted strings to a Writer.

Using a Replacer -- The `strings.Replacer`can be used to perform replacement on a `string`and output the modified result to a `Writer`.

```go
func writeReplaced(writer io.Writer, str string, subs ...string) {
	replacer := strings.NewReplacer(subs...)
	replacer.WriteString(writer, str)
}

func main() {
	text := "It was a boat. A small boat."
	subs := []string{"boat", "kayak", "small", "huge"}

	var writer strings.Builder
	writeReplaced(&writer, text, subs...)
	fmt.Println(writer.String())
}
```

# Working with JSON

The `encoding/json`package provides support for encoding and decoding JSON data.

`NewEncoder(writer)`-- returns an `Encoder`can be used to encode JSON data and write to the `writer`

`NewDecoder(reader)`-- returns a `Decoder`, can be used to read JSON from `Reader`

And need to note that also provides functions without `Reader`and `Writer`. like:

`Marshal(value), Unmarshal(byteSlice, val)`

`Unmarshal(byteslice, val)` -- Parses json data contained in the slice and assigns the result to val.

### Encoding

`Encode(val)`, `SetEscapeHTML(on)`, `SetIndent(prefix, indent)`

Need to note that the JSON `Encoder`adds a `\n`after each value is encoded automatically.

### Encoding Arrays and Slices

Go slice and arrays are encoded as JSON array, with the exception that `byte slices`are expressed as `base64-encoded`string. Byte arrays, are encoded as an array of JSON numbers.

`Encoder`expresses each array in JSON -- except the byte slice, note that not for byte array.

### Encoding Maps

Just JSON objects -- keys used as object keys...

### Encoding Structs

The `Encoder`expresses struct values as JSON objects too. note that *unexported fields are ignored*.

`encoder.Encode(Kayak)`

Understanding the Effect of Promotion in JSON in Encoding

```go
type DiscountedProduct struct {
	*Product
	Discount float64
}

func main(){
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	dp := DiscountedProduct {
		&Kayak, 10.50,
	}
	encoder.Encode(dp)
	fmt.Println(writer.String())
}
```

## Customizing the JSON Encoding of Structs

Using **struct tags** -- are string literals that follow fields. Note that they ae part of the Go support for reflection.

```go
type DiscountProduct struct {
    *Product `json:"product"`
    Discount float64
}
```

### Omitting a Field

The `Encoder`skips fields decorated with a tag that specifies a hyphen like:

```go
type DiscountedProduct struct {
    //...
    Discount flaat64 `json:"-"`
}
```

Omit nil -- 

`*Product: ``json:"product,omitempty"`

Can also skip the name:

```go
type DiscountedProduct struct {
    *Product `json:",omitempty"`
    Discount float64 `json:"-"`
}
```

Forcing to be encoded as Strings

```go
type DiscountedProduct struct {
    //...
    Discounted float64 `json:",string"`
}
```

For the new Load_balance, read sqlite dbs:

```go
func main() {
	dbPath := `E:\download\softwareInitial\v2rayN-Core\v2ray-Core\guiConfigs\guiNDB.db`
	db, err := sql.Open("sqlite3", dbPath)

	if err != nil {
		log.Fatal(err)
	}

	defer db.Close()
	rows, err := db.Query(`select p.indexId, configType, configVersion, address, port, id,
        alterId, security, network, remarks, headerType, requestHost,
        streamSecurity, allowInsecure, subid, isSub, flow, sni,
        delay, speed, sort
       from ProfileItem as p join ProfileExItem as ex
    on p.indexId = ex.indexId where (speed > 5 or speed='') and (delay <> -1 or delay='')`)
	checkErr(err)
	defer rows.Close()

	gs := []guiOrg{}
	for rows.Next() {
		gSingle := guiOrg{}
		err = rows.Scan(&gSingle.IndexId, &gSingle.ConfigType, 
                        &gSingle.ConfigVersion, &gSingle.Address,
			&gSingle.Port, &gSingle.Id, &gSingle.AlterId, &gSingle.Security, 
                        &gSingle.Network,
			&gSingle.Remarks, &gSingle.HeaderType, 
                        &gSingle.RequestHost, &gSingle.StreamSecurity,
			&gSingle.AllowInsecure, &gSingle.Subid, &gSingle.IsSub,
                        &gSingle.Flow, &gSingle.Sni,
			&gSingle.Delay, &gSingle.Speed, &gSingle.Sort)

		if err != nil {
			log.Fatal(err)
		}
		gs = append(gs, gSingle)
	}
    //...
}
```

# Completing the Example MVC Application

There are just 5 core data operations that are required by most MVC applications. just: retrieving a single, retrieving all, create a new, updating an existing, and deleting an item. Updating an existing item, and deleting an item.

## Adding the Action methods

To add the actions..

## Updating and Adding Views

```html
@model IEnumerable<Product>

@{
	ViewData["Title"] = "Products";
}

<table class="table table-sm table-striped">
	<thead>
	<tr><th>ID</th><th>Name</th><th>Category</th><th>Price</th></tr>
	</thead>
	<tbody>
	@foreach(var p in Model)
	{
		<tr>
			<td>@p.Id</td>
			<td>@p.Name</td>
			<td>@p.Category</td>
			<td>$@p.Price.ToString("F2")</td>
				
			<td>
				<form asp-action="Delete" method="post">
					<a asp-action="Edit"
					   class="btn btn-sm btn-warning" asp-route-id="@p.Id">
						Edit
					</a>
					<input type="hidden" name="id" value="@p.Id" />
					<button type="submit" class="btn btn-danger btn-sm">
						Delete
					</button>
				</form>
			</td>
		</tr>
	}
	</tbody>
</table>

<a asp-action="Create" class="btn btn-primary">Create a new Product</a>
```

## Eager Loading: Loading relationships with the Primary entity class

The first is loading related data is *eager loading*, which entails telling EF core to load the relationship in the same query that loads the P entity class.

`context.Books.Include(book=>book.Reviews).FirstOrDefault().Dump();`

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	context.Books.Include(book=>book.AuthorsLink)
	.Include(book=>book.Reviews)
	.Include(book=>book.Tags)
	.Include(book=>book.Promotion).Dump();
}
```

These relationships are first-level relationship -- refered to directly from the entity class you are loading. the  `ThenInclude`to load the second-level.

EF Core added the ability to sort or filter the related entities when U use the `Include`... methods.

```cs
var firstBook = context.Books
    .Include(book=>book.AuthorsLink)
    	.ThenInclude(bookAuthor=>bookAuthor.Author)
    .Include(book=>book.Reviews
    	.Where(review=>NumStars==5))
    .Include(book=>book.Promotion).First();
```

## Explicit Loading -- Loading rel after the primary entity class

The second approach to loading data is explicit loading -- After loaded the PC, can explicitly load any other relationships U want. like:

```cs
using (var context = new EfCoreContext(optionBulder.Options))
{
	var firstBook = context.Books.First();
	context.Entry(firstBook)
	.Collection(book=>book.AuthorsLink).Load(); // explicit loads
	
	foreach(var authorLink in firstBook.AuthorsLink){
		context.Entry(authorLink)
		.Reference(bookAuthor=>bookAuthor.Author).Load();
	}
	
	context.Entry(firstBook).Collection(book=>book.Tags).Load();
	context.Entry(firstBook).Reference(book=>book.Promotion).Load();
	
	firstBook.Dump();
}
```

Alternatively, explicit loading can be used to apply a query to the relationship instead of loading the relationship.

```cs
var firatBook = context.Books.First();
var numReviews = context.Entry(firstBook)
    .Collection(book=>book.Reviews)
    .Query().Count(); // execute a query to count.
//...or
.Query().Select(review=>review.NumStars)
    .ToList();
```

The advantage of explicit loading is can load a relationship of an entity class later. Use this loads only the pC, and need one of its relationships. For this technique, more dbs round trips.

## Select Loading

```cs
// Use LINQ Select method to pick out the data you want
using (var context = new EfCoreContext(optionBulder.Options))
{
	context.Books
	.Select(book=>new {
		book.Title, book.Price, 
		NumReviews= book.Reviews.Count,
	}).Dump();
}
```

The `CascadingValue`element makes a value available to the componetns it **encompasses** and their **descendent**. And the `Name`attribute specifies the name of the parameter, and the `Value`attribute specifeis the vlaue, and the `isFixed`is used to specify whether the value will change. Fore:

```html
<CascadingValue Name="BgTheme" Value="Theme" IsFixed="false"></CascadingValue>
<SelectFilter Values="Themes" @bind-SelectedValue="Theme" />
```

```cs
@code {
    //...
    public string Theme {get;set;} = "info";
    public string[] Themes = new string[] {"primary", "info", "success"};
}
```

Then using this in the descendent component like:

```cs
[CascadingParameter(Name="BgTheme")]
public string Theme {get;set;} = "";
```

The `CascadingParameter`attribute's name is just used to specify the name of the cascading parameter.

# Styling Elements using Validation Classes

The classes to which an `input`element is assigned provide details of its validation state. There are like:

* `ng-untouched, ng-touched`-- if it has not been visited by the user, which is typically done by tabbing 
* `ng-pristine ng-dirty`-- whether its contents have been changed.
* `ng-valid ng-invalid`-- `ng-valid`if its content meet the criteria defined by the validation rules.
* `ng-pending`-- elements are assigned to the `ng-pending`when their contents are being validated async.

Defining some validation feedback styles in the styles.css file -- 

## Displaying Filed-level validation messages

The `ngModel`directive provides access to the validation status of the elements it is applied to. like:

```html
<div class="mb-3">
    <label>Name</label>
    <input class="form-control" name="name" [(ngModel)]="newProduct.name"
           #name="ngModel"
           required minlength="5" pattern="^[A-Za-z ]+$" />

    <ul class="text-danger list-unstyled mt-1"
        *ngIf="name.dirty && name.invalid">
        <li *ngIf="name.errors?.['required']">
            U must enter a product name
        </li>
        <li *ngIf="name.errors?.['pattern']">
            Product names can only contain letters and spaces
        </li>

        <li *ngIf="name.errors?.['minlength']">
            Product names must be at least
            {{name.errors?.['minlength'].requiredLength}} characters.
        </li>
    </ul>
</div>
```

Create a template reference variable called `name`and its value is `ngModel` -- This use of an `ngModel`value is confusing -- To display validation messages, need to create a tempalte reference variable and assign it .

`path` -- returns the name of the elem.

`errors`-- returns a `ValidationErrors`obj whose props correspond to each attribute for which there is a validation error. And for the errors:

`email, required, minlength.requiredLength`, `min.min, max.max...`

## Using the Component to Display Validation Messages

Including separate elements for all possible validation errors quickly become verbose -- So a better approach is to add logic to the component to prepare the validation messages in a method.

```ts
getMessages(errs: ValidationErrors | null, name: string): string[] {
    let messages: string[] = [];
    for (let errorName in errs) {
        switch (errorName) {
            case 'required':
                messages.push(`U must enter a ${name}`);
                break;
            case 'minlength':
                messages.push(`A ${name} must be at least
                ${errs['minlingth'].requiredLength} characters`);
                break;
            case 'pattern':
                messages.push(`The ${name} contains illegal characters`);
                break;
        }
    }
    return messages;
}

getValidationMessages(state: NgModel, thingName?: string) {
    let thing: string = state.path?.[0] ?? thingName;
    return this.getMessages(state.errors, thing);
}
```

The state.path?[0]??thingname -- default ot using the `path`prop as the description string if an argument isn't received when the method is invoked.

```html
<ul class="text-danger list-unstyled mt-1"
    *ngIf="name.dirty && name.invalid">
    <li *ngFor="let error of getValidationMessages(name)">
        {{error}}
    </li>
</ul>
```

## Validating the Entire Form

Displaying validation error messages for individual is useful -- can also be useful to validate the entire form.

```ts
formSubmitted = false;

submitForm(form: NgForm) {
    this.formSubmitted = true;
    if (form.valid) {
        this.addProduct(this.newProduct);
        this.newProduct = new Product();
        form.resetForm();
        this.formSubmitted = false;
    }
}
```

```html
<form #form="ngForm" (ngSubmit)="submitForm(form)">
		<div class="bg-danger text-white p-2 mb-2"
			 *ngIf="formSubmitted && form.invalid">
			There are problems with the form.
		</div>
```

And the `form`element now defines a reference variable called form -- has been assigned to `ngForm`. This is just how the `ngForm`directive provides access to its functionality.

## Displaying Summary Validation Messages

NOTE: the `ngForm`obj assigned to the `form`template reference variable provides access to the individual elements through a property named `controls`. This prop returns an object that has props for each of the individual elements in the form. like:

```ts
getFormValidationMessages(form: NgForm): string[] {
    let messages: string[] = [];
    Object.keys(form.controls).forEach(k => {
        this.getMessages(form.controls[k].errors, k)
            .forEach(m => messages.push(m));
    });
    return messages;
}
```

This method builds its list of messages by calling the `getMessages`method.

## Disabling the Submit Button

The next is to disable the button once the user has submitted the form, just preventing the user from clicking.

## Creating Attribute Directives

How custom directives can be used to supplement the functionality provided by the built-in ones of Ng.

- They are classes can modify the behavior or appearance of the element type they are applied to.
- built-in cover the most common tasks but not all. Custom directives allow app to be defined.
- Are classes to which the `@Directive`decorator has been applied. They are enabled in the `directives`property of the component.
- Ng supports two others -- structural and components.

## Creating a Simple Directive

`attr.directive.ts`file like:

```ts
import {Directive, ElementRef} from "@angular/core";

@Directive({
	selector:"[pa-attr]",
})export class PaAttrDirective{
	constructor(element:ElementRef) {
		element.nativeElement.classList.add("table-success", "fw-bold");
	}

}
```

`@Directive`decorator has been applied -- The decorator requires the `selector`property, which is used to specify how the directive is applied to the elements, expressed using a std CSS style selector. The selector just used is `[pa-attr]`, which will match any element that has an attribute called `[pa-attr]`. Which will match. for `Pa`reflecting the title of book..

In the `constructor`, defines a `ElementRef`-- provides when it creates a new instance of the directive and which returns the obj used by the browser to represent the element in DOM. The obj provides access to the methods and props that manipulate the elem and its contents. so can be used as: 

```js
element.navtiveElement.classList.add("table-success", "fw-bold");
```

Applying that -- Applying a directive is to change the configuraiton of the Ng Module -- Need to note that in the module file -- 

```ts
@NgModule({
	declarations: [
		ProductComponent, PaAttrDirective
	],
```

```html
<tr *ngFor="let item of getProducts(); let i = index" pa-attr>
```

## Accessing Application Data in a Directive

Reading Host Element attributes -- 

```ts
constructor(element: ElementRef, @Attribute("pa-attr-class") bgClass: string) {
    element.nativeElement.classList.add(bgClass || "bg-success", "fw-bold");
}
```

```html
<td pa-attr pa-attr-class="table-warning">...</td>
```

To receive the value of the `pa-attr-class`, can add a new ctor parameter called `bgClass`to which the `@Attribute`decorator has been applied. it specifies the name of the attr that should be used to provide a value for the ctor parameter when a new instance of the directive class is created.

# Media Queries

Allows you to write a set of styles that only apply to the page **under certain conditions**. Lets u tailor your style differently -- based on the screen size. Can define a set of styles that apply to small device.. fore:

```css
@media (min-width:560px) {
    .title > h1 {
        font-size: 2.25rem;
    }
}
```

The rules inside a media query still follow the normal rules of the cascade. FORE, can override rules outside of the media query. Note: Should use `ems`for media query breakpoints -- 

For this, used px in the example -- better idea to use `ems`in media queries.

## Understanding types of media query

Can further refine a media query by joining the two clauses with `and`. like:

```css
@media (min-width: 20em) and (max-width:35em) {...} /* meet both */
@media (max-width: 20em) , (min-width: 35em) {...}  /* meet any */
```

## `min-width, max-width`.. 

Can also use a number of other types of media features fore:

`min-height`, `orientation:landscape`, `min-resolution: 2dppx`.

## Adding breakpoints to the page

Practically, a mobile-first approach means the type of media query you will use the most should be `min-width`. You will write your own mobile styles first. Then you will work your way up to **larger** breakpoints. This just follows the general structure like:

```css
.title{...}  /* for mobile */
@media (min-width: 35em) {
    .title{...} /*override select mobile */
}
@media (min-width: 50em) {
    .title {...}
}
```

So, just add the rest of the styles for the medium breakpoint.

```css
@media (min-width:35em) {
    .page-header{
        padding: 1em;
    }
}
@media (min-width:35em) {
    .menu-toggle{
        display: none;
    }

    .menu-dropdown{
        display:block;
        position:static;
    }
}

@media (min-width:35em){
    .nav-menu{
        display: flex;
        border:0;
        padding: 0 1em;
    }

    .nav-menu > li {
        flex: 1;
    }
    .nav-menu > li + li {
        border:0;
    }
    .nav-menu > li > a {
        padding: 0.3em;
        text-align: center;
    }
    
    .row{
        display: flex;
        margin-left: -.75em;
        margin-right: -.75em;
    }

    .column{
        flex: 1;
        margin-right: 0.75em;
        margin-left: 0.75em;
    }
}
```

## Adding responsive columns

The final cahnge to amke for the medium is the introduction of multiple columns. And a lot of responsive design will come down to this sort of approach. When your design calls for items side-by-side, only place them beside each other on large screens.

## Fluid Layouts

The third and final principle of responsive design is *fluid layout* -- refers to the use of containers that grow and shrink according to the width of the viewport. This is in contrast to a fixed layout, where columns are defined using pixels or ems.

In a fluid, the main page container typically doesn't have an explicit widht, or it has one defined using a percentage. Have left and right padding -- or `auto`left and right margins to add breathing room.

And inside the main container - any columns are defined using a %..

A web page is responsive by default -- It's your job to maintain the responsive nature of the page.

## Adding styles for a large viewport

```css
@media (min-width:50em) {
    .page-header{
        padding: 1em 4em;
    }

    .hero {
        padding: 7em 6em;
    }

    main {
        padding: 2em 4em;
    }

    .nav-menu{
        padding: 0 4em;
    }

    :root{
        font-size: 1.125em;
    }
}
```

## Dealing with tables

Tables are particular problematic for fluid layout on mobile devices. Cuz, if a table has more han a handful of columns, it can just easily overflow.

One approach you can take is to force the table to display as normal block elements. The layout is made up of `<table>`, .. elements, but the declaration `display:block`applied, overridding the normal table. Just like:

```css
table {
    width:100%;
}

@media (max-width:30em) {
    table, thead, tbody, tr, th, td {
        display:block;
    }

    thead tr {
        position: absolute; /*hides the heading row by moving it off the screen */
        top: -9999px;
        left: -9999px;
    }
    
    tr {
        margin-bottom: 1em;
    }
}
```

This causes each cell to stck atop one another. Then just adds a margin between each `<tr>`.

## Responsive images

Images also need special attention -- must also consider the bandwidth limitations of .. Should also ensure they are not any higher resolution then necessary.

### Using multiple images for different viewport sizes

The best practie is to create a few copies of an image -- each at different resolution.

### Using srcset to serve the correct image

Media queries solve the problem when the image is included via the CSS,  For inlined images, a different approach is necessary -- the `srcset`attribute --for `source set`.

This attr is a newer -- It allows you to specify multiple image URLs for one `<img>`tag, just specifying the resolution of each. The browser will then figure out which image it needs and download that one like:

```css
<img alt="..."
	src = "...jpg"
	srcset="small.jpg 560w, media.jpg 800w, large.jpg 1280w">
```

Most browsers now support -- This allows you to optimize for multiple screen sizes. Even better, the browser will make adjustments for higher resolution screens.

# CSS At Scale -- Modular CSS

Note, when make changes to an existing stylesheet, those changes can affect any number of elements on any number of pages across your site.

Discuss these problems -- look at the architecture of CSS focusing less on the declarations, and more on the selectors you choose and the HTML U pair those with -- How you structure your code determiens whether you can safely make changes in the furture without unwanted side effects.

Modular CSS just means breaking the page up into its **component** parts. These parts should be reusable in multiple contexts -- they shouldn't directly depend upon one another. The end goal is that changes to one part of your CSS will not produce unexpected effects in another.

So with modular css, instead of building one giant web page, build each part of the page in a way that stands alone. Instead of a stylesheet where any selector can do anything anywhere on the page, modular styles allow you to impose order -- Each part of stylesheet -- call a *module*, which will be reponsible for its own styles, and no module should interfere with the styles of another.
