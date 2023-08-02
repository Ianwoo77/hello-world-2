## Model binding from the request body

The model binding feature can also be used on the data in the new request body, which allows clients to send data that is easily received by an action method.

### Adding additional Actions

Now that the basic features are in place, can just add actions that allow client to replace and delete `Product`objects just using PUT, DELETE mthod. like:

```cs
[HttpPut]
public void UpdateProduct([FromBody] Product product)
{
    context.Products.Update(product);
    context.SaveChanges();
}

[HttpDelete("{id}")]
public void DeleteProduct(long id)
{
    context.Products.Remove(new Product
                            {
                                ProductId = id,
                                Name = string.Empty,
                            });
    context.SaveChanges();
}
```

Cuz the `Name`property has `required`keyword as been applied , so needed.

```js
async function putData(url, data = {}) {
    const resp = await fetch(url, {
        method: "PUT",
        mode: "cors", // no-cors, *cors, same-origin
        cache: "no-cache",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
    });
    return resp.json();
}
data = {productId:1, name:"Green Kayak", price: 275, categoryId:1, supplierId:1};
await putData("http://localhost:5000", data);

async function deleteData(url, id) {
    const resp = await fetch(url+'/'+id, {
        method: "DELETE",
        mode: "cors", // no-cors, *cors, same-origin
        cache: "no-cache",
    });
    return resp.json();
}
```

## Improving the Web service

The controller re-createds the functionality by the separate endpoints, but there are still improvements that can made -- If you are supporting 3rd-party js, may need to enable support for cross-origin requests -- Browsers protect users by only allowing Js code  CORs just loosens this restriction by performing an initial HTTP request to check that the server will allow requests originating from a specific URL, helping prevent mailcious code using your service without the user's consent -- `builder.Services.AddCors()`.

### Using async actions

Note that core platform processes each request by assiging a thread from a pool. The number of reuests that can be processed concurrently is limited to the size of the pool, and a thread can't be used to process any other request while it is waiting for an action to produce a result.

And, actoins that depend on external resources can cause a request thread to wait for an extended period. A dbs server may have its own concurrency limits and may queue up queries until they can be executed. The core request thread is unavailable to process any other requests until the dbs produces a result for the action, which then produces a response that can be sent to the HTTP client.

This problem can be addressed by defining async actions -- whcih allow Core threads to process other requests when they would otherwise be blocked, increasing the number of HTTP requests that the app can process simultaneously.

```cs
[HttpGet]
public IAsyncEnumerable<Product> GetProducts()
{
    return context.Products.AsAsyncEnumerable();
}

[HttpGet("{id}")]
public async Task<Product?> GetProduct(long id)
{
    return await context.Products.FindAsync(id);
}

[HttpPost]
public async Task SaveProduct([FromBody] Product product)
{
    await context.Products.AddAsync(product);
    await context.SaveChangesAsync();
}

[HttpPut]
public async Task UpdateProduct([FromBody] Product product)
{
    context.Products.Update(product);
    await context.SaveChangesAsync();
}

[HttpDelete("{id}")]
public async Task DeleteProduct(long id)
{
    context.Products.Remove(new Product
                            {
                                ProductId = id,
                                Name = string.Empty,
                            });
    await context.SaveChangesAsync();
}
```

For some operations, -- The `IAsyncEnumerable<T>`interface can be used, which denotes a sequence of objects that should be enumerated async and prevents the core request thread from waiting for each object to be produced by the dbs.

### Preventing Over-Binding

Some of the action methos use the model binding feature to get data from the response body so that it can be used to perform database operation. Fore, a POST used to test -- `ProductId`-- SqlException occurred. By default, EF core just configures the dbs to assign PK valus when new object are stored. This mans the application doesn't have to worry about keeping track of which key values have already been assigned and allows multiple applications to share the same dbs without need to coordinate key allocation.

The `Product`just needs a `ProductId`prop, but model binding process don't understand the significance of the property and adds any values that the client provides to the objects it creates.

This is known as *over-binding*. And it can cause serious problems when a client provides values that the developer didn't expect. So the safest way to prevent over-binding is to create separate data model classes that are used only for receiving data through the model binding process. So, adding a proxy class like:

```cs
public class ProductBindingTarget
{
    public required string Name { get; set; }
    public decimal Price { get; set; }
    public long CategoryId { get; set; }
    public long SupplierId { get; set; }

    public Product toProduct => new Product
    {
        Name = this.Name,
        Price = this.Price,
        CategoryId = this.CategoryId,
        SupplierId = this.SupplierId
    };
}
```

This `ProdcutBindingTarget`class defines only the properties that the app was to receive form the client when storing a new object -- the `ToProduct()`creates a `Product`that can be used with the rest of the application, Just ensuring that the client can provide properties only for `Name, Price,  CategoryId, SupplierId`props. just like:

```cs
[HttpPost]
public async Task SaveProduct([FromBody] ProductBindingTarget target)
{
    await context.Products.AddAsync(target.ToProduct);
    await context.SaveChangesAsync();
}
```

### Using the Action results 

Core setst the status code for responses automatically, But won't always get the result you desire, in part cuz there are no firm rules for RESTFUL web services, and the assumptions that can just: The `ControllerBase`just provides a set of methods that are used to create action result objects -- which can be returned from action methods -- 

- `Ok`-- Returned by this produces a 200OK status 
- `NoContent`-- 204 NO CONTENT
- `BadRequest`-- 400 -- The method accepts an optional model state
- `File`-- 200ok, and `Content-Type`is set to specified type
- `NotFound`-- 404
- `Redirect`and `RedirectPermanent`-- redirects the client to a specified URL
- `RedirectToRoute`(`Permanent`)-- redirects the client to a specified URL that is created using the routing system.
- `LocalRedirect`-- local to the application.
- `RedirectToAction`-- Action methods
- `RedirectToPage`-- to a Razor Page
- `StatusCode`-- returned by this produces a response with a specific status code.

```cs
[HttpGet("{id}")]
public async Task<IActionResult> GetProduct(long id)
{
    Product? p = await context.Products.FindAsync(id);
    if(p == null)
    {
        return NotFound();
    }
    return Ok(p);
}

[HttpPost]
public async Task<IActionResult> SaveProduct([FromBody] ProductBindingTarget target)
{
    Product p = target.ToProduct;
    await context.Products.AddAsync(p);
    await context.SaveChangesAsync();
    return Ok(p);
}
```

 ```js
 data = { name:"Boot Laces", price: 19.99, categoryId:2, supplierId:2};
 await postData('http://localhost:5193/api/products', data);
 VM46:2 Fetch finished loading: POST "http://localhost:5193/api/products".
 {productId: 16, name: 'Boot Laces', price: 19.99, categoryId: 2, category: null, …}
 ```

### Performing Redirections

Many of the action result methods realted to redirections, which redirect the client to another URL -- note that the `LocalRedirect`and `LocalRedirectPermanent`methods throw an exception if a controller tries to perform a redirection to any URL that is not local. This is just useufl when are redirecting to URLs provided by users -- where an *open redirection attack* is attempted to redirect another user to an untrusted site.

```cs
[HttpGet("redirect")]
public IActionResult Redirect()
{
    return Redirect("/api/products/1");
}
```

```js
fetch("http://localhost:5193/api/products/redirect")
    .then(resp=>resp.json())
    .then(json=>console.log(json));
```

### Rediecting to an Action method

Can redirect to another action method using the `RedirectAction`method -- or the `RedirectToActionPermanetn`:

```cs
[HttpGet("redirect")]
public IActionResult Redirect() {
    return RedirectToAction(nameof(GetProduct), new {Id=1});
}
```

Just note that the action method is specified as a string, although the `nameof`can be used to select an action method without the risk of a typo.

### Redirecting using Route values

`RedirectToRoute`and `RedirectToRoutePermanent`methods redirect the client to a URL that is created by providing a routing system with values for segment variables and allowing it to select a route to use. This can be useful for apps with complex routing configurations like:

```cs
[HttpGet("redirect")]
public IActionResult Redirect() {
    return RedirectToRoute(new {
        controller="Products",
        action = "GetProduct",
        Id=1
    });
}
```

The set of values in this redirection reles on convention routing to select the controller and action method.

## Modifying and Deleting Data

### Modifying Objects

EF core supports a number of differnt ways of updating objects. LIke:

```cs
public Product GetProduct(long key) => context.Products.Find(key)!;
public void UpdateProduct(Product product)
{
    context.Products.Update(product);
    context.SaveChanges();
}
```

The `DbSet<product>`returned by the dbs context's `Products`property provides the feature taht need to implement the new methods. The `Find`method accepts a PK value and quereis the dbs for the object it corresponds.

When an event occurs on an object, all of the handlers registered for that type of event are invoked in the order in wihich they were registered. Note that invoking `addEventListener`more thanonce on the same object with the same arguments has no effect -- The handler func remains registered only once, and the repeated invocation does not alter the order in which handlers are invoked.

And `addEventlistener`is paired with a `removeEventListener`method that expects the same two arguments but removes an event handler function from an event rather than adding it. like:

```js
document.removeEventListener("mousemove", handleMouseMove);
document.removeEventListener("mouseup", handleMouseUp);
```

there is the optional arg to `addEventListener()`is a boolean value or **object** -- if pass `true`, then handler function is registered as a *capturing* event handler and is invoked at a different phase of event dispatch. for *object* -- 

```js
document.addEventListener('click', handleClick, {
    cpature:true,
    once: true,  // auto removed
    passive: true, // never all preventDefault to cancel default action
});
```

### Container collapsing and the clearfix

A few behaviors of floats still might catch you off guard -- there are not bugs. White background behinds page title, but it stops there instead of extending down to encompass the mdeida boxes. Just like:

```css
.media {
    float: left;
    width : 50%;
    padding: 1.5em;
    background-color: #eee;
    border-radius: 0.5em;
}
```

Unlike elements in the normal document flow -- *floated elements do not add height to their parent elements*. Just goes back to the original purpose of floats. 

Floats are intended to allow text to wrap around them - when float an image insde a paragraph, the paragraph does not grow to contain the image -- if the image is taller than the text of the paragraph, the next paragraph will start immediately below the text of the first. 

In page, everything inside the main elemetn is floated except for the page title -- So only the page title will contributes heght to the container -- leaving all the floated meida elements extending below the white background of the main.

One way can correct this just with the float's companion property `clear`-- If place an element at the end of the main container and use `clear`, it causes the container to *expand to the bottom of the floats*. Just like:

```html
<main class="main">
    ...
	<div stype="clear:both">
    </div>
</main>
```

The `clear:both`decalration causs this element to move below the bottom of floated elements, rather than beside them.

Instead of adding an extra markup, use *pseudo-element* -- using the `::after`selector, can effectively insert an element into the DOM at the end of the container, without adding it ot the markup.

```css
.clearfix::after {
    display: block; /* need to be non-inline */
    content: ""; 
    clear: both; /* makes the pseudo-element clear all floats in the container */
}
```

It's just important to know that the clearfix is just applied to the element that contains the floats; And a common mistake is to apply it to the wrong element.