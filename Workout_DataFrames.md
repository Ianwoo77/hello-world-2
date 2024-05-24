# Workout_DataFrames

Cuz each column contains one attribute or category, it typically contains just one type of data. However, each row may contain several different types of data cuz it cuts across several columns. Each column in a data frame is a pandas series object. the data frame has a single index shared by all of its columns. 

A dataframe typically contains more info than we need -- before can answer any questions, first need to pare our data down to a subset of its original rows and columns. Retrieving only the rows and columns we want based on criteria appropriate for our query.

Will also practice creating, modifying, and updating data frames. Sometimes we will do that cuz we have new info and want the data frame to reflect that change.

#### Brackets or dots

Using `[]`are equivalent to `loc`for simple cases. When work with data frames, must use `loc`or `iloc`to retrieve rows.

```python
df= pd.DataFrame(np.arange(10,121,10).reshape(3,4), index=[*'xyz'],
                 columns=[*'abcd'])
```

There is an exception to the `[]`means columns rule -- if we use a slice, pandas will look at the dat frame’s rows, rather than its columns, this means that can retrieve rows form x through y with `df['x':'y']`-- the slice tells pandas to use the row rather than the columns -- the slice will return rows up to and including the endpoint.

And another way to work with columns is to use `.`. Columns with spaces and other illegal-in python identifier characters don’t work. And it’s confusing to try to remember whether `df.whatwver`is a column named `whatever`or an attribute named `whatever`.

Want U to create a data frame that represents a company’s inventory of 5 products - each product has a unique ID number, name ...

#### work it out -- 

The first part of this task involved creating a new data frame by passing values to the `DataFrame`class -- 

- Pass a list of lists, each inner list representes one row. The inner lists must all be the same length and fill the columns positionallly.
- Pass a list of dictionaries -- each dict represents one row.
- pass a 2d numpy array

One advantage of a list of dicts is that we don’t need to pass column names. Pandas can infer their names from the dict keys. And the index is the default positional index.

`((df.retail_price-df.wholesale_price)*df.sales).sum()`

#### Beyond the exercise

- For what product is the retail price more than twice the wholesale price -- 
  `df.name[df.retail_price*.5>df.wholesale_price]`

Tax Planning -- IN the previous, created a data frame representing your store’s products and sales. In this exercise, will extend that data frame -- it’s pretty common to add columns to an existing data frame, either to add new info you’ve acquired or to store the results of per-row calculations. If two series share an index, can perform various arithmetic operations on them.

1. An alternative tax plan would charge a 25% tax, but only on products from which you would net more than 20000.

   ```python
   df['current_net']=(df.retail_price-df.wholesale_price)*df.sales
   df.current_net.apply(lambda c: c*.75 if c >20000 else c).sum()
   ```

2. Another alternative tax paln would charge 25% tax on products whose retail price is greater than 80.

   ```python
   df['after_tax']=pd.cut(df.retail_price,
                          bins=[0,30,80,df.retail_price.max()],
                          labels=[1,0.9,0.75]).astype(np.float64)
   # note the format
   pd.options.display.float_format= '{:,.2f}'.format
   ```

#### Retrieving and assigning with loc

It’s pretty straightforward to retreive an entire row from data frame or even replace a row’s values with new ones.

## Reading Multipart Forms

Forms encoded as `multiplart/form-data`to allow binary data, such as files, to be safety sent ot the server. To create a form that allows the server to retreive a file, create a file named `upload.html`like:

```html
<form method="POST" action= "/forms/upload" class="p-2"
      enctype="multipart/form-data">
    <div class="mb-3">
        <label class="form-label">Name</label>
        <input lass="form-control" type="text" name="name">
    </div>
    <div class="mb-3">
        <label class="form-label">City</label>
        <input class="form-control" type="text" name="city">
    </div>
    <div class="mb-3">
        <label class="form-label">Choose File</label>
        <input class="form-control" type="file" name="filse" multiple>
    </div>
    <button type="submit" class="btn btn-primary mt-2">
        Upload
    </button>
</form>
```

The `enctype`attribute on the `form`element creates a multipart form, and the `input`element whose `type`is `file`creates a form control that allows the user to select a file. The `multiple`attribute tells the browser to allow the user to select multiple files. Like:

```go
func HandleMultipartForm(writer http.ResponseWriter, request *http.Request) {
    fmt.Fprintf(writer, "Name: %v, City: %v\n", request.FormValue("name"),
                request.FormValue("city"))
    fmt.Fptinfln(writer, "------")
    file, header, err := request.FormFile("files")
    if err == nil {
        defer file.Close()
        fmt.Fprintf(writer, "Name: %v, size: %v\n", header.Filename, header.size)
        for k, v := range header.Header {
            fmt.Fprintf(writer, "Key: %v, Value: %v\n", k,v)
        }
        fmt.Fprintln(writer, "-----")
        io.Copy(writer,file)
    }else {
        http.Error(writer,err. Error(), http.StatusInternalServerError)
    }
}
```

`Header`-- this field returns a `map[string][]string`-- which contains the headers from the MIME part that contains the file. `Open()`-- Returns a `File`that can be used to read the content associated with the header.

### Receiving Multiple Files in the Form

The `FormFile`method returns only the first file with the specified name, which means that it can’t be used when the user is allowed to select multiple files for a single form element, which is the case with the example form.

```go
func HandleMultipartForm(writer http.ResponseWriter, request *http.Request) {
	request.ParseMultipartForm(10000000)
	fmt.Fprintf(writer, "Name: %v, City: %v\n",
		request.MultipartForm.Value["name"][0],
		request.MultipartForm.Value["city"][0])

	fmt.Fprintln(writer, "------")

	for _, header := range request.MultipartForm.File["files"] {
		fmt.Fprintf(writer, "Name: %v, Size: %v\n", header.Filename, header.Size)

		// This method returns a `File` that can be used to
		// read the content associated with the header
		file, err := header.Open()
		if err == nil {
			defer file.Close()
			fmt.Fprintln(writer, "------")
			io.Copy(writer, file)
		} else {
			http.Error(writer, err.Error(), http.StatusInternalServerError)
			return
		}
	}
}
```

#### Receiving Multiple Files in the Form

The `FormFile`method returns only the first file wiht the specified name, which means that it can’t be used when the user is allowed to select multiple files for a single form element,-- Must eensure that the `ParseMultipleForm()`method is called before using the `MultiplartForm`field. The `MultipartForm`field returns a `Form`struct, which is defined in the `mime/multipart`package.

- `Value`-- this field returns a `map[string][]string`that contains the form values
- `File`-- this returns a `map[string][]*FileHeader`which contains the files.

### Reading and Setting Cookies

The `net/http`package defines the `SetCookie`function, which add a `Set-Cookie`*header* to the response sent to the client -- like:

- `SetCookie(writer, cookie)`-- this adds a `Set-Cookie`header to the specified `ResponseWriter`. The cookie is described using a pointer to a `Cookie`struct.

The fields defined by the `Cookie`struct like:

- `Name`-- this field represents the name of the cookie, expressed as a `string`
- `Value`-- this represents the cookie value, string
- `Path`-- this optional field specifies the cookie path
- `Domain`-- This optional fields specifies the `host/domain`to which the cookie will be set
- `Expires`-- this specifies the cookie expiry, `time.Time`
- `MaxAge`-- specifies the number of *seconds* until the cookie `int`
- `Secure`-- when this `bool`is `true`, the client will only send cookie over HTTPs
- `HttpOnly`-- `true`will prevent Js code from accessing the cookie
- `SameSite`-- specifies the cross-origin policy for the cookie using the `SameSite`.

And the `Cookie`struct is also used to get the set of cookies that a client sends, which is down using the `Request`method -- 

- `Cookei(name)`-- returns a pointer to a `Cookie`value with the specified name and an `error`that indicates when there is no matching cookie.
- `Cookies()`-- returns a slice of `Cookie`pointer.

```go
func GetAndSetCookie(writer http.ResponseWriter, request *http.Request) {
	counterVal := 1
	counterCookie, err := request.Cookie("counter")
	if err == nil {
		counterVal, _ = strconv.Atoi(counterCookie.Value)
		counterVal++
	}
	http.SetCookie(writer, &http.Cookie{
		Name: "counter", Value: strconv.Itoa(counterVal),
	})

	if len(request.Cookies()) > 0 {
		for _, c := range request.Cookies() {
			fmt.Fprintf(writer, "Cookie Name: %v, Value: %v", c.Name, c.Value)
		}
	} else {
		fmt.Fprintln(writer, "Request contains no cookies")
	}
}

func init() {
	http.HandleFunc("/cookies", GetAndSetCookie)
}
```

### Decoupling

Another important use case is about decoupling our code from an implemenration. If we rely on an abstraction instead of a concrete implemernation, the implementation itself can be replaced with another without even having to change our code. And one benefit of decoupling can be related to unit testing -- assume want to implement a `CreateNewCustomer`method that creates a new customer and stores it.

```go
type CustomerService struct {
    store mysql.Store
}
func (cs CustomerService) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.Store.StoreCustomer(customer)
}
```

Then, what if we want to tst this method -- cuz `customerService`reles on the just actual implementation to store a `Customer`-- are obliged to test it through integration tests, which requires spinning up a `MySQL`instance. To give more flexibility, should decouple `CustomerService`from the actual implemenration -- 

```go
type customerStore interface {
    StoreCustomer(Customer) error
}

type CustomerService struct {
    storer customerStore
}
func (cs CustomerSrevice) CreateNewCustomer(id string) error {
    customer := Customer{id:id}
    return cs.storer.StoreCustomer(customer)
}
```

For this, cuz storing a customer is now done via an interface, this gives us more flexibility in how we want to test the method can -- 

- Use the concrete implementation via integration tests
- Use a mock
- or both

#### Restricting Behavior

Create a specific container for `int`configurations via an `IngConfig`struct that also exposes two method `Get`and `Set`.

```go
type IntConfig struct {}
func (c *IntConfig) Get() int {}
func (c *IntConfig) Set(value int) {}
```

Suppose receive an `IntConfig`that holds some specific configuration -- fore, are only interested in retrieving the configuration value, want to prevent updating it. like:

```go
type intConfigGetter interface {
    Get() int
}
type Foo Struct {
    threshold intConfigGetter
}

// injects the configuration getter
func NewFoo(threshold intConfigGetter) Foo {
    return Foo {...}
}

// read the configuration
func (f Foo) Bar() {
    threhold := f.threshold.Get()
}
```

`NewFoo`factory -- it doesn’t impact a client of this function cuz it can still pass an `IntConfig`struct as it implements `IntConfigGetter`-- Can only read the configuration in the `Bar`, not modify it.

### Interface Pollution -- 

And the main caveat when programming meets abstractions is remembering that abstractions *should* be discovered, not created. What does this -- it means that we shouldn’t start crating abstractions in our code if there is no immediate reason to do so. We shouldn’t design with interfaces but wait for a concrete need. We should create an interface when need it, not when foresee that could need it.

What is the main problem if we overuse interfaces -- the answer is that they make the code flow more complex -- adding a useless level of indirection doesn’t bring any value-- it creates a worthless abstraction making the code more difficult to read. Understand, and reason about.

In summary, should be cautious when creating abstractions in our code -- abastractions should be discovered, not created. This process should be avoided cuz in most cases, it pollutes our code with unnecessary abstractions.

*Don’t design with interfaces, discover them*

## Communicating efficiently

Message passing will degrade the performance of our application if we are spending too much time passing messages around. Since we pass copies of messages from one goroutine to another, we suffer the performance pentaly of spending time copying the data in the message -- this extra performance cost is noticeable if the messages are large or numerous.

One scenario is when the message size is too large, consider -- fore, an image or video processing application applying various filters on the images concurrently. Copying huge blocks of memory containing images or videos just to pass them on channels might greatly reduce our performance.

Fore, to calculate the weather forecast in each grid square, a goroutine might need info from calculations in all the other grids, each goroutine might need to send and receive partial calcuation results from all the other goroutines, and this process might have to be repeated multiple times until the forecasting calculations coverage.

1. Calculate partial results for the goroutine’s grid square
2. Send partial results to all other goroutines, each working on it own grid square
3. receive partial results from every other, and include them in the next calcuation

### Programming with Channels

Working with channels requires a different way of programming than when using memory sharing. The idea is to have a set of goroutines, each with its own internal state, exchanging info with other goroutines by passing messages on Go’s Channels.