# Creating Nested Packages

Packages can be defined within other packages, making it easy to break up complex features into as many units as possible.

```go
type Cart struct {
	CustomName string
	Products   []store.Product
}

func (cart *Cart) GetTotal() (total float64) {
	for _, p := range cart.Products {
		total += p.Price()
	}
	return
}
```

Just note the `package`statement is used just as with any other package, without the need to include the name of the parent or enclosing package.

```go
func main() {
	product := store.NewProduct("Kayak", "Watersports", 279)
	cart := cart.Cart{
		CustomName: "Alice",
		Products: []store.Product{*product},
	}
	fmt.Println("Name:", cart.CustomName)
	fmt.Println("Total", cart.GetTotal())
}
```

## Using Package Initialization Functions

The most common use for initialization functions is to perform calculations that are difficult to perform or that require duplication to perform, as:

```go
var categoryMaxPrices = map[string]float64{
	"Watersports": 250 + (250 * defaultTaxRate),
	"Soccer":      150 + (150 * defaultTaxRate),
	"Chess":       50 + (50 * defaultTaxRate),
}
```

The solution is to use an initialization function, which is invoked automatically when the package is loaded and where language features such as `for`can be used.

```go
func init() {
	for category, price := range categoryMaxPrices {
		categoryMaxPrices[category]=price+(price*defaultTaxRate)
	}
}
```

## Importing a Package only for Initialiation Effects

```go
import (
	//...
    _ "packages/data"
)
```

Using External Packages like:

```sh
go get github.com/faith/color@v1.10.0
```

The same pattern can be implemented using RPs -- One page is required to render and process the form data.

```cs
namespace WebApp.Pages
{
    [IgnoreAntiforgeryToken]
    public class FormHandlerModel : PageModel
    {
        private readonly DataContext context;
        public FormHandlerModel(DataContext ctx)
        {
            context = ctx;
        }

        public Product? Product { get; set; }
        public async Task OnGet(long id =1)
        {
            Product = await context.Products.FindAsync(id);
        }

        public IActionResult OnPost()
        {
            foreach(string key in Request.Form.Keys
                .Where(k=>!k.StartsWith("_"))) 
            {
                TempData[key]=string.Join(", ", Request.Form[key]!);
            }
            return RedirectToPage("FormResults");
        }
    }
}
```

```html
@page "/pages/form/{id:long?}"
@model WebApp.Pages.FormHandlerModel
@{
}

<div class="m-2">
    <h5 class="bg-primary text-white text-center p-2">HTML Form</h5>
    <form action="/pages/form" method="post">
        <div class="mb-3">
            <label>Name</label>
            <input class="form-control" name="Name"
                   value="@Model.Product?.Name" />
        </div>
        <button type="submit" class="btn btn-primary">Submit</button>
    </form>
</div>
```

```html
@page "/pages/results"

<div class="m-2">
    <table class="table table-striped table-bordered table-sm">
        <thead>
        <tr class="bg-primary text-white text-center">
            <th colspan="2">Form data</th>
        </tr>
        </thead>
        <tbody>
        @foreach (string key in TempData.Keys)
        {
            <tr>
                <th>@key</th>
                <td>@TempData[key]</td>
            </tr>
        }
        </tbody>
    </table>
    <a class="btn btn-primary" asp-page="FormHandler">Return</a>
</div>
```

# async and await

`await`takes a `Promise`and turns it back into a return value or a thrown expceiton. Given a Promise p, the expression `await p`waits until p settles.

Declaring a function `async`means that the return value of the fuction will be a Promise even if no `Promise-related`code appears.

## Awaiting Multiple Promises 

```js
async function getJSON(url) {
    let response = await fetch(url);
    let body = await response.json();
    return body;
}
let [value1, value2]= await Promise.all([getJSON(url1), getJSON(url2)]);
```

## Asynchronous Iteration

Async iterators are like the iterators -- are just `Promise-based`.

The `for/await`loop --

```js
const fs = require('fs');
async function parseFile(filename) {
    let stream = fs.createReadStream(filename, {encoding:"utf-8"});
    for await(let chunk of stream){
        parseChunk(chunk);
    }
}
// just like:
for (const promise of promises) {
    response = await promise;
    handle(response);
}
for await(const response of promises) {
    handle(response);
}
```

## Unions of Object Types

It is just reasonable in Ts code to want to be able to describe a type that can be one or more difficult object types that have slightly different properties.

Inferred Object-Type Unions -- if a variable is given an initial value that could be one of multiple object types, Ts will infer its type to be a union of object types. like:

```ts
const poem = Math.random() > 0.5
    ? { name: "The double Image", pages: 7 } : { name: "her kind", rhymes: true };
```

## Explicit Object-type Unions

Alternately, can be more explicit about your object types by being explicit with union of object types.

```js
type PoemWithPages = {
    name: string;
    pages: number;
}

type PoemWithRhyms = {
    name: string;
    rhymes: boolean;
}

type Poem = PoemWithPages | PoemWithRhyms;
const poem2: Poem = Math.random() > 0.5
    ? { name: "The double", pages: 7 } : { name: "Her kind", rhymes: true };

```

Note, if a value might be one of multiple types, properties that don't exist on all of those.

## Narrowing Object types

```js
if ("pages" in poem2) {
    poem2.pages; //ok
}
```

## Discriminated union

```js
type PoemWithPages = {
    // ...
    type: 'pages';
}

type PoemWithRhyms = {
    //...
    type: 'rhymes';
}

type Poem = PoemWithPages | PoemWithRhyms;
const poem2: Poem = Math.random() > 0.5
    ? { name: "The double", pages: 7, type:'pages' } : { name: "Her kind", rhymes: true, type:'rhymes' };

if (poem2.type === 'pages') {
    console.log(poem2.pages)
} else
    console.log(poem2.rhymes);
```

## Intersection types

TypeScript allows representing a type that is multiple types at the same time -- `&`intersection type.

```tsx
type Artwork = {
    genre: string;
    name: string;
};
type Writing = {
    pages: number;
    name: string;
};
type WrittenArt = Artwork & Writing; // {gener, name, pages} all have.
```

But it's easy to use them in ways that confuse either yourself or the Typescript compiler. 

## never

Intersection types are also esy to misuse and create an impossible type with. NOTE -- **primitive types cannot be joined together as consistuents in an intersection type**. Cuz it's impossible for a value to be multiple primities at the same time. 

```tsx
type NotPossible= number & string;
```

## Parameters

Without explicit type information declared, will consider it to be `any`type.

## Required Parameters

Ts assumes that all parameters declared on a function are just required. If a function is called with a wrong number of args, Ts will protest in the form of a type error. But, can use **Optional Parameters**. like:

```tsx
function announceSone(song:string, singer?:string){//...}
function announceSongB(song:string, singer: string | undefined) {//...}
```

Must: `announceSongB('...', undefined)`

# CSS

Unlike elements in the normal document flow, floated elements do not add height to their parent elements. One way can correct this is with the float's companion property `clear`-- If U place an element at the end of the main container and use `clear`, it causes the container to expand to the bottom of the floats.

```html
<main class="main">
    <div stype="clear: both"></div>
</main>
<!-- or use pseudo-element -->
```

```css
.clearfix::after {
    display:block;
    content: "";
    clear: both;
}
```

Cuz box 2 is shorter than box 1 -- there is room for box 3 beneath it -- instead of clearing box 1 -- box 3 catches on it. It doesn't float all the way to the left edge, but rather floats against the bottom of box 1. The exact nature of this behavior is depend on the heights of each of the floated blocks. On the other hand, if box 1 is shorter than box 2 then no edge... So need:

```css
.media:nth-child(odd) {
    clear: left;
}
```

if, havd three items per row... could: 3n+1...

## Media objects and block formatting contexts

In intended design, have an image on one side and a block of text beside it. -- This pattern can be implemented in a number of ways, Start by floating the image to the left. As can see -- merely floating the image is not enough. When the text is long enough, it wraps around the floated element.

```css
.media-image{
    float:left;
}

.media-body{
    margin-top: 0;
}

.media-body h4 {
    margin-top: 0;
}
```

To fix the behavior of the text, you will need to understand a little more about how floats work...

### Establising a block formatting context

The text inside the body wraps around the image, but once it's *clear of the bottom of the image*, Establish sth called a block formatting context for the media body. A *block formatting context* (BCF) is a region of the page in which elements are laid out. A block formatting context itself is part of the surrounding document flow, but it isolates its contents from the outside context.

1. It contains the top and bottom margins of all elements within it. Won't collapse with margins of elements outside of the block formatting context.
2. It contains all floated elements within it.
3. It doesn't overlap with floated elements outside the BFC.

Namely, the content inside a block formatting context will not overlap or interact with elements on the outside as you would normally expect.

* `float:left`or `float:right`but `none`
* `overflow:hidden, auto, scroll`, but visible
* `display:inline-block, table-cell, table-caption, flex, inline-flex, grid, inline-grid`called *block containers*.
* `position: absolute`or `fixed`.

```css
.media-body{
    display: flow-root;
    margin-top: 0;
}
```

## Exclude external floats

`display:flow-root`-- able to do this cuz an element in the normal flow that establishes a new BFC does not overlap the margin box of any floats in the same block formatting context as the element itself.

## Grid Systems

*grid system* -- this is a series of class names you can add to your markup to structure portions of the page into rows and columns. Should Provide NO visual styles -- shoud ONLY set widths and positions of containers. Usually the general principle -- **Put a row container around one or more column containers**.

A *grid system* is usually defined to hold a certain number of columns in each row -- this is usually 12, but can vary.

```html
<div class="row">
    <div class="column-4">
        4 columns
    </div>
    <div class="column-8">
        8 columns
    </div>
</div>
```

```css
:root {
    box-sizing: border-box;
}

*, 
::before, 
::after {
    box-sizing: inherit;
}

body {
    background-color: #eee;
    font-family: Helvetica, Arial, sans-serif;
}

body * + * {
    margin-top: 1.5em;
}

.row {
    margin-left: -0.75em;
    margin-right: -0.75em;
}

.row::after {
    content: " ";
    display: block;
    clear: both;
}

[class*="column-"] {
    float: left;
    padding: 0 0.75em;
    margin-top:0;
}

.column-1 {
    width: 8.3333%;
}

.column-2 {
    width: 16.6667%;
}

.column-3 {
    width: 25%;
}

.column-4 {
    width: 33.3333%;
}

.column-5 {
    width: 41.6667%;
}

.column-6 {
    width: 50%;
}

.column-7 {
    width: 58.3333%;
}

.column-8 {
    width: 66.6667%;
}

.column-9 {
    width: 75%;
}

.column-10 {
    width: 83.3333%;
}

.column-11 {
    width: 91.6667%
}

.column-12 {
    width: 100%;
}

.main {
    padding: 0 1.5em 1.5em;
    background-color: #fff;
    border-radius: .5em;
}

.media {
    padding: 1.5em;
    background-color: #eee;
    border-radius: .5em;
}

.media-image {
    float: left;
    margin-right: 1.5em;
}

.media-body {
    overflow: auto;
    margin-top: 0;
}

.media-body h4 {
    margin-top: 0;
}


.container {
    max-width: 1080px;
    margin: 0 auto;
}

.clearfix::before,
.clearfix::after {
    display: table;
    content: " ";
}

.clearfix::after {
    clear: both;
}
```

Laid out a page using floats entirely. Have their own quirks, but get the job done.
