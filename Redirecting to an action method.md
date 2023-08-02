## Redirecting to an action method

You can redirect to another action method using the `RediectToAction`method or the `RedirectToActionPermanent`method -- Changes like:

```cs
[HttpGet("redirect")]
public IActionResult Redirect() {
    return RedirectToAciton(nameof(GetProduct), new {Id=1});
}
```

The acthon method is sepcified as a string, although the `nameof`expression can be used to select an action method without the risk of a typo. Any additional values required to create the route are supplied using an anonymous object. Restart ASP.NET Core and use a Powershell command prompt to repeat the command.

And, the `RedirectToRoute`and `RedirectToRoutePermanent`method redirect the client to a URL that is created by providing the routing system with values for segment variables and allowing it to select a route to use. This can be useufl for applications with complex routing configuraitons. just like:

```cs
[Httpget("redirect")]
public IActionResult Redirect() [
    return RedirectToRoute(new {
        controller="Products", action= "GetProduct", Id=1
    });
]
```

The set of values in this redirection reles on convention routing to select the controller and action method.

### Validating Data

When accept data from clients, you must assume that a lot of the data will be invalid and be prepared to filter out values that the application can't use, the data validation feaures provide for MVC framework controllers are described in detail in but for this, going to focus on only one problem -- ensuring that the client provids values for the properties that are required to store dat in the database -- like:

```cs
[Required]
public required string Name { get; set; }

[Range(1,1000)]
public decimal Price { get; set; }

[Range(1, long.MaxValue)]
public long CategoryId { get; set; }

[Range(1, long.MinValue)]
public long SupplierId { get; set; }
```

So the `Required`attribute denotes properteis for which the client must provide a value that can be applied to properties that are assigned `null`when there is no value in the request -- the `Range`attribute requires a value between upper and lower limits and is used for primitive types that will default to zero when there is no value in the request.

**NOTE** -- The `Required`attribute could be omitted form the `Name`property cuz ASP.NET core will infer the validation constraint from the `required`keyword -- this is useful feature -- But using the `Required`attribute for consistency and to make it obvious that the validaiton contraints was intentional.

Then -- Updates the `SaveProduct`action to perform validation before storing the object that is created by the model binding process -- ensuring that only object that contain values for all four properties decorated with the validation attribute are accepted.

```cs
[HttpPost]
public async Task<IActionResult> SaveProduct([FromBody] ProductBindingTarget target)
{
    if (ModelState.IsValid)
    {
        Product p = target.ToProduct;
        await context.Products.AddAsync(p);
        await context.SaveChangesAsync();
        return Ok(p);
    }
    return BadRequest(ModelState);
}
```

The `ModelState`property is inherited from the `ControllerBase`class, and the `IsValid`property returns `true`if the moddel binding process has produced data that meets the validation criteria. If the data received from the client is valid, then the action result from the `Ok`method is returend, if the data sent by the client fails the validation check then the `IsValid`property will be `fasle`, and the action result from the `BadRequest`method is ued instead. The `BadRequest`method accepts the object returned by the `ModelState`property, which is used to describe the validation errors to the client.

### Applying The API Controller attribute

The `ApiController`attribute can be applied to web service controller classes to change the behavior of the model binding and validation features. The use of the `FromBody`attribute to select data from the rquest body and explicitly check the `ModelState.IsValid`property is not required in controllers that have been decorated with the `ApiController`attribute.

### Omitting the Null properties

The final change going to make in this is to remove the `null`values from the data returned by the web service -- The data model classes contain navigation properties that are used by EF core to associate related data in complex queries --. For the simple queries that are performed in this -- no values are assigend to the navigation properties, which just means that the client receives proproties for which values are never going to be available.

The request was just handled by the `GetProduct`action method, and the `category`and `supplier`values in the response will always be `null`cuz the action doesn't ask EF core to populate these properties.

### Projecting Selected properties

The first appraoch to return just properties that the client requires, this gives you complete control over each response, but it can become difficult to manage and confusing for client developers if each action returns a different set of values.

```cs
[HttpGet("{id}")]
public async Task<IActionResult> GetProduct(long id) {
    Product? p = await context.Products.FindAsync(id);
    if (p==null){
        return NotFound();
    }
    return Ok (
        new {
            p.ProductId, p.Name, p.Price, p.CategoryId, p.SupplierId
        }
    );
}
```

The properties that the client requires are just selected and added to an object that is passed to the `Ok`method.

### Configuring the JSON serializer

The JSON serializer can be configured to omit properties when it serializes objects. One way to configure the serializer is just with `JsonIgnore`attributes like:

```cs
[JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
public Supplier? Supplier {get;set;}
```

And, this is may be difficult to manage for more complex data models -- A general policy can be defined for serializing using the options pattern like:

```cs
builder.Services.Configure<JsonOptions>(opts =>
{
    opts.JsonSerializerOptions.DefaultIgnoreCondition =
    JsonIgnoreCondition.WhenWritingNull;
});
```

The JSON serializer is configured using the `JsonSerializerOption`property of the `JsonOptions`class, and `null`values are managed using the `DefaultIgnoreCondition`prop.

### Applying a rate limit

How rate limiting feature and showd you how it is applied to individual endpoints -- This feature also works for controllers, using an attribute to select the rate limit that will be just applied.

```cs
builder.Services.AddRateLimiter(opts =>
{
    opts.AddFixedWindowLimiter("fixedWindow", fixopts =>
    {
        fixopts.PermitLimit = 1;
        fixopts.QueueLimit = 1;
        fixopts.Window = TimeSpan.FromSeconds(15);
    });
});
```

which limits requests to one every 15 seconds with no queue. Then can apply as single rate limiting policy to all controller by calling `app.MapController().RequireRateLimiting("fixedWindow")`. This policy can be overridden for specific controllers and actions, using the `EnableRateLimiting`and `DisableRateLimiting`attributes.

### Updating the Controller and Creating a View

The next step is to update the `Home`controller so there are action methods that will allow the user to select a `Prodcut`object for editing and send changes to the application.

```cs
public IActionResult UpdateProduct(long key)
{
    return View(repository.GetProduct(key));
}

[HttpPost]
public IActionResult UpdateProduct(Product product)
{
    repository.UpdateProduct(product);
    return RedirectToAction(nameof(Index));
}
```

Can see how tha action methods are mapped onto the features provided by the repository and through the dbs context class. To provide the controller with a view for the new actions, add a file called `UpdateProduct.cshtml`.

```html
@model Product

<h3 class="p-2 bg-primary text-white text-center">Upate Product</h3>

<form asp-action="UpdateProduct" method="post">
    <div class="mb-3">
        <label asp-for="Id"></label>
        <input asp-for="Id" class="form-control" readonly />
    </div>
    
    <div class="mb-3">
        <label asp-for="Name"></label>
        <input asp-for="Name" class="form-control" />
    </div>
    
    <div class="mb-3">
        <label asp-for="Category"></label>
        <input asp-for="Category" class="form-control" />
    </div>
    
    <div class="mb-3">
        <label asp-for="PurchasePrice"></label>
        <input asp-for="PurchasePrice" class="form-control" />
    </div>
    
    <div class="mb-3">
        <label asp-for="RetailPrice"></label>
        <input asp-for="RetailPrice" class="form-control" />
    </div>
    
    <div class="text-center">
        <button class="btn btn-primary" type="submit">Save</button>
        <a asp-action="Index" class="btn btn-secondary">Cancel</a>
    </div>
</form>
```

The view presents the user with an HTML form that can be used to change the properties of a Prodcut object, with the exception of the `Id`property, which is used as the PK, PK cannot be easily changed once they have been assigned, and it is simpler to delete an object and create a new one if a different key value is required. For this reason, Have added the `readonly`attribute to the `nput`element that shows the value of the `Id`property but doesn't allow it to be changed.

To integrate the update feature into the rest of the application, added a `button`element for each of the `Product`objects displayed by the `Index`view -- like:

```html
<div class="col">
    <a asp-action="UpdateProduct" asp-route-key="@p.Id"
       class="btn btn-outline-primary">
        Edit
    </a>
</div>
```

And, if examine the logging messages generated by the application, you can see how the actions you performed result in SQL commands being sent to the dbs server. Just:

```sql
UPDATE Products set Catetoery= @p0, Name= @p1, ... where Id= @p4;
```

So the `Update`method is translated into a SQL `UPDATE`command that stores the form values that have been received form the HTTP request.

### Upating only changed Properties

The basic building blocks for performing updates are in place, but the result is just inefficient cuz EF Core has no baseline against which to figure out what has changed and so has no choice but to store all of the properties. The EF core just includes a change-detection feature that can work out which properteis have changed -- For a data model calss, this is unlikely to be an issue, but for more complex data models, detectin changes can be important. 

So the change detection feature requires a baseline against which the data received from the user can be compared -- there are different ways of providing the baseline -- Easiest approach in this chapter -- which is to query the dbs for existing data -- like:

```cs
public void UpdateProduct(Product product)
{
    Product p = GetProduct(product.Id); // get the base line
    p.Name = product.Name;  // product from the Data binding through the form
    p.Category = product.Category;
    p.PurchasePrice = product.PurchasePrice;
    p.RetailPrice = product.RetailPrice;
    context.SaveChanges();
}
```

For this just :

```sql
Update Products set RetailPrice= @p0
where Id= @p1;
```

### Performing Bulk Updates

Bulk updates are often required in appliations where there are dedicated administration role that needed to make changes to multiple objects in a single operation -- The exact nature of the updates will differ, but common reasons for bulk updates include correcting data entry mistakes or reassigning objects to new categories, both of which can be time-consuming to perfgorm on individual objects.

### Updating the Views and Controller

To add support for performing bulk updates, updated the `Index`view to contain an **Edit All** button that target the `UpdateAll`action -- Need to add a `ViewBag`property called `UpdateAll`which will lead to the display of a partial view called `InlineEditor.cshtml`when `true`show like:

```html
<div class="text-center">
            <a asp-action="UpdateAll" class="btn btn-primary">Edit All</a>
        </div>
    }
else
{
@await Html.PartialAsync("InLineEditor", Model)
}
</div>
```

Need to create partial view by adding a file named `InlineEditor.cshtml`to the `Views/Home`folder with the content:

```html
@model IEnumerable<Product>

<div class="row">
    <div class="col-1 fw-bold">Id</div>
    <div class="col fw-bold">Name</div>
    <div class="col fw-bold">Category</div>
    <div class="col fw-bold">Purchase Price</div>
    <div class="col fw-bold">Retail Price</div>
</div>

@{ int i = 0; }

<form asp-action="UpdateAll" method="post">
    @foreach (Product p in Model)
    {
        <div class="row p-2">
            <div class="col-1">
                @p.Id
                <input type="hidden" name="Products[@i].Id" value="@p.Id"/>
            </div>
            <div class="col">
                <input class="form-control" name="Products[@i].Name" value="@p.Name"/>
            </div>
            <div class="col text-end">
                <input class="form-control" name="Products[@i].Category" value="@p.Category"/>
            </div>
            <div class="col text-end">
                <input class="form-control" name="Products[@i].PurchasePrice"
                       value="@p.PurchasePrice"/>
            </div>
            <div class="col text-end">
                <input class="form-control" name="Products[@i].RetailPrice"
                       value="@p.RetailPrice"/>
            </div>
        </div>
        i++;
    }

    <div class="text-center m-2">
        <button type="submit" class="btn btn-primary">Save All</button>
        <a asp-action="Index" class="btn btn-outline-primary">Cancel</a>
    </div>
</form>
```

So the partial view creates a set of form elemens whose name follows the MVC convention for a collection of objects so that the `Id`property is given the names `Products[0].Id`... and so on.

```cs
public IActionResult UpdateAll()
{
    ViewBag.UpdateAll=true;
    return View(nameof(Index), repository.Products);
}

[HttpPost]
public IActionResult UpdateAll(Product[] products)
{
    repository.UpdateAll(products);
    return RedirectToAction(nameof(Index));
}
```

The POST version of the `UpdateAll`method accepts an array of `Product`objects, which the MVC model binder will create from the form data and pass on to the repository method of the same name.

```cs
public void UpdateAll(Product[] products)
{
    context.Products.UpdateRange(products);
    context.SaveChanges();
}
```

So the `DbSet<T>`class provides methods for woking on both individual objects and collections of objects. In this example, have used the `UpdateRange`method, which is the collection counterpart of the `Update`.

### Using Change Detection for Bulk Updates

The code in this -- doesn' t use the EF core *change-detection* feature, which means that all the properties for all the `Product`objects will be updated -- to update only just changed values, need modify the `UpdateAll`method.

```cs
public void UpdateAll(Product[] products)
{
    // Id is key and object is value
    Dictionary<long, Product> data = products.ToDictionary(p => p.Id);
    var baseline = context.Products
        .Where(p => data.Keys.Contains(p.Id));

    foreach(var p in baseline)
    {
        Product requestProduct = data[p.Id];
        p.Name = requestProduct.Name;
        p.Category = requestProduct.Category;
        p.PurchasePrice= requestProduct.PurchasePrice;
        p.RetailPrice= requestProduct.RetailPrice;
    }
    context.SaveChanges();
}
```

The process for performing the update can be convoluted. Start by just creating a dictionary of the `Product`objects received from the MVC model binder, using the `Id`property for keys, use the collection of keys to query for the corresponding objects in the dbs. Just use LINQ like:

```cs
IEnumerable<Product> baseline =
    context.Products.Where(p=>data.Keys.Contains(p.Id));
```

Enumerate the query objects and copy the property values from the request objects. When the `SaveChanges`method is called, EF core just perform change-detection and updates only those values have changed. Can see the `Name`value is changed by the first command and the `RetailPrice`value is cahnged by the second command. Like:

```SQL
select p.Id, p.Catgegory, ...
from products as p
where p.id in (1,2,3)
```

The objects that are created from this data are used for change detection. EF core works out which properties have new values and sends two `UPDATE`commands to the dbs.

### Deleting Data

Deleting objects from the dbs is simple -- although it can become more involved as the data model grows, just like:

```cs
public void Delete(Product product)
{
    context.Products.Remove(product);
    context.SaveChanges();
}
```

And the `DbSet<T>`class has `Remove`and `RemoveRange`methods for deleting one or several objects from the dbs. As with operations that modify the dbs, no data will be deleted until the `SaveChanges()`method is called. Working through the appliation, add the action method to the `Home`controller that receives details of the `Product`object to delete from the HTTP request and passes them on the repository.

```go
[HttpPost]
public IActionResult Delete(Product product)
{
    repository.Delete(product);
    return RedirectToAction(nameof(Index));
}
```

For, delete operation, added a `form`element for each `Product`objects displayed, like:

```html
<input type="hidden" name="Id" value="@p.Id" />
<button type="submit" class="btn btn-outline-danger">
    Delete
</button>
```

Notice the form contains only an `input`for the `Id`property -- That is EF core uses to delete an object note even though the operation is performed on a complete `Product`. -- NOT be used, have just the PK. which the MVC model binder will use to create a `Product`type.