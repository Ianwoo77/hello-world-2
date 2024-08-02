# Reshaping and pivoting

A data set can arrive in a format unsuited for the analysis that we’d like to perform on it. Sometimes, issues are confined to a specific column, a data set may have larger structural problems that extend byeond the data. *Reshaping* a data set means manipulating it into a different shape.

### Wide vs. narrow data

a narrow is a long or tall data set. grows vertically, makes it easier to manipulate existing data and add new records.

```python
pd.read_csv('sales_by_employee.csv', parse_dates=['Date'])
```

#### `pivot_table`method

aggregates a column’s values and groups the results by using other column’s values. *aggregate* means a summary computation data involves multiple values.

1. Select column(s) whose values want to aggregate
2. Choose aggregation operation
3. Select columns whose values will group the aggregated data into categories.
4. Determine whether to place the groups on the row axis, column axis, or both axes. The simplest way like:

```python
sales.pivot_table(index='Date',values=['Expenses', 'Revenue'])
sales.pivot_table(index='Date',values=['Expenses', 'Revenue'], columns='Name',
                  aggfunc='sum')
```

Use the `Name`column’s unique values as the column column, For this, have an aggregated sum of values organized by dates on the row axis and salesmeen on the column axis. For this, have some `Nan`values, can use the `fill_value`parameter to replace all pivot table `NaNs`with a fixed value like:

```python
sales.pivot_table(
    index="Date",
    values=["Expenses", "Revenue"],
    columns="Name",
    aggfunc="sum",
    fill_value=0,
    margins=True,
    margins_name="Total",
)
```

#### Additional options for pivot tables -- 

A pivot table supports a variety of aggregation operations -- fore, are interested in the number of business deals closed per day, pass `aggfunc`an argument of `count`fore:

```python
sales.pivot_table(
    index='Date',
    columns='Name',
    values='Revenue',
    aggfunc=np.count_nonzero
)
```

Once again, a `NaN`value indicates that the salesman did not make a sale on a given day. can also use: `max min std median size`, can also pas a list of aggregation functions to the `pivot_table`function’s `aggfunc`parameter. The pivot table will create a `MultiIndex`on the column axis and store the aggregation in its outermost level. fore:

```python
sales.pivot_table(
    index='Date',
    columns='Name',
    values='Revenue',
    aggfunc=[np.count_nonzero, np.sum],
    fill_value=0
)
```

Can apply different aggregations to different columns by passing a dictionary to the `aggfunc`parameter,  use the dictionary’s keys to identify `DataFrame`columns and the values to set the aggregation.

```python
sales.pivot_table(
    index='Date',
    columns='Name',
    values=['Revenue', 'Expenses'],
    aggfunc= {'Revenue': np.min, 'Expenses': np.max},
    fill_value=0
)
```

Can also stack multiple grouping in a single axis by passing the `index`parameter a list of columns. The next example, aggregate the sum of expenses by salesman and date on the row axis -- pandas returns a DF wtih a two-level:

```python
sales.pivot_table(
    index=['Name', 'Date'],
    values='Revenue',
    aggfunc=np.sum,
)
```

And, note that switching the order in the `index`list to rearrange the levels in the pivot-table’s `MultiIndex`. The next just swaps th positions of Name and `Date`like:

```python
sales.pivot_table(index=['Date', 'Name'], values='Revenues', aggfunc=np.sum)
```

The pivot table first organizes and sorts the Date values, and then organizes and sorts the Name values.

## Functions and Methods

- When to use value or pointer receivers
- When to use named result parameters and their potential side effects
- Avoiding a common misttake while returning a `nil`receiver
- Why using functions that accept a filename is not the best practice
- Handling `defer`arguments.

### Knowing which tpe of receiver to use

Choosing a receiver type for a method isn’t always straightforward -- When should use value, or pointer. In many contexts, using a value or pointer receivers should be dicated not by perfomance but rather by other conditions that -- In Go, can attach either a value or a pointer receivers to a method.

With a value receiver, Go makes a copy of the value and pases it to the method. Any changes to the object remain local to the method. so the original object remains unchanged.

```go
type customer struct {
    balance float64
}

func (c customer) add(v float64) {
    c.balance += v
}
```

On the other hand, with a pointer receiver, Go passes the address of on object to the method -- Only copy the pointer, 

```go
func (c *customer) add(operation float64) {
    c.balance += operation
}
```

Cuz use a pointer receiver, incrementing the balance mutates the `balance`field.

For the conditions that a receiver *must* be a pointer -- 

- If the method needs to mutate the receiver
- If the method receiver contains a field *that cannot be copied*. Fore, a type of part of `sync`package

For the condition that a receiver *should* be a pointer --

- If the receiver is a large object 

For the condition it *must* be a value -- 

- If we have to enforce a receiver’s immutability
- If the receiver is a `map, func, channel`-- otherwise, comipliation error occurred.

And, a receiver *should* be a value

- If the receiver is a slice that doesn’t have to be mutated
- Is a small array or struct that is naturally a value type
- If receiver is a basic type such as `int...`

One case needs more discussion -- like:

```go
type customer struct {
    data *data
}
type data struct {
    balance float64
}
func(c customer) add(operation float64) [
    c.data.balance+=operation
]
func main(){
    c := customer{data: &data{balance:100}}
    // even though the receiver is a value, 
    // call add changes the actual balance
    c.add(50.) 
    println(c.data.balance)
}
```

For this, balance isn’t part of the customer directly but is a struct referenced by a pointer field. In this case, don’t need the receiver to be a pointer to mutate `balance`.

### Using named result parameters

Named result parameters are an infrequently used option in Go -- this looks at when it’s considered appropraite to use named result parameters to make our API more convenient. When, return parameters in a function or a method, can attach names to these parameters and use them as regular variables. When a result parameter is names, it’s initialized to its zero value when the func/method begins.

```go
func f (a int) (b int) {
    b =a
    return
}
```

So, when is it recommended that we can use named result parameter -- Consider the following interface -- which contains a method to get the coordinates from a given address like:

```go
type locator interface{
    getCoordinate(address string) (float32, float32, error)
}
```

Cuz this is not unexported -- documentation isn’t mandatory. In that case, should probably use named result parameters to make the code easier to read like:

```go
type locator interface {
    getCoordinates(address string) (lat, lng float32, err error) 
}
```

So, with this new, can understand the meaning of the method signature by looking at the interface. When to use named result parameters with the method implementation -- like:

```go
func (l loc) getCoordainates(address string) (lag, lng float32, err error){
}
```

With this new, can understand -- having an expressive method signature can *also* help code readers. Then consider another function signature that allows to store `Customer`type in a dbs -- like: 

```go
func StoreCustomer(customer Customer) (err error) {...}
```

For this, naming the `error`parameter `err`isn’t helpful and doesn’t help readers. 

So -- in most cases, if it’s not clear whether using them makes our code more readable, shouldn’t use named result parameters. Also note that having the result paramters already initialized can be quite handy in some contexts.

```go
func ReadFull(r io.Reader, buf []byte) (n int, err error) {
    //..
    return
}
```

For this, having named result parameters doesn’t really increase readability -- both `n`and `err`are initialized to their zero value, the imp is shorter.

### Side effects with named parameters

As these result parameters are initialized to their zero value -- using them can sometimes lead to subtle bugs. Fore:

```go
func (l loc) getCoordainates(ctx context.Context, address string) (
    lat, lng float32, err error) {
    isValid:= l.ValidateAddress(address)
    if !isValid {
        return 0, 0, errors.New(...)
    }
    if ctx.Err()!= nil {
        return 0, 0, err
    }
    //...
}
```

For this, the error returned in the `if ctx.Err()!=nil`scope is just `err`-- `nil`. Havn’t assigned any value to the `err`variable, it is still assigned to the zero value of an `error`type. Furthermore, this code compiles cuz `err`was initialized to its zero value due to named result parameters.

One possible fix is to assign `ctx.Err()`to `err`like -- 

```go
if err := ctx.Err(); err!=nil {
    return 0, 0, err
}
```

### Don’t return a `nil`receiver

This mistake is probably one of the most widespread in Go -- cuz it may be considered coutnerintuitive -- like:

```go
type MultiError struct {
    errs []string
}
func (m *MultiError) Add(err error) {
    m.errs = append(m.errs, err.Error())
}
func (m *MultiError) Error() string {
    return strings.Join(m, errs, ";")
}
```

Using this struct, can implement a `Customer.Validate`in the following manner to check the customer’s age and name. like:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age<0 {
        m= &MultiError{}
        m.Add(...)
    }
    if c.Name="" {
        //...
        m.Add(...)
    }
    //  note taht:
    return m
}
```

In this IMP, `m` is just initialized to the zero value of `*MultiError`== `nil`. When sanity check fails -- allocate a new `MultiError`if needed and then append an error. If:

```go
customer := Customer{Age:33, Name: "John"}
if err := customer.Validate(); err != nil {
    log.Fatal(..., err)
}
```

Need to know that a pointer receiver can be `nil`. Cuz in go, a method is just syntactic sugar *for a fucntion whose first parameter is a receiver.* NOTE for :

```go
func (c Customer) Validate() error {
    var m *MultiError
    //...
    return m
}
```

m is not `nil`but a pointer -- `nil`-- then if all checks are valid, the argument provided to the `return`isn’t `nil`directly but a `nil`*pointer*. Cuz a `nil`pointer is a valid receiver, converting the result into an interface won’t yield a `nil`value. In other words, the aller of `Validate()`will always get a non-nil error.

Remember in Go -- an interface is a dispatch wrapper -- there the wappee is `nil`, whereas the wrapper isn’t. Therefore, regardless of the `Customer`provided, the caller of this function will always receive a non-nil error.

```go
func (c Customer) Validate() error {
    var m *MultiError {
        //..
        if m!=nil {
            return m
        }
        return nil // need to return a nil directly
    }
}
```

So, at the end of the method, just check whether `m`is not `nil`-- if `true`return `m`otherwise, return `nil`explicitly.

## Reading Multipart Forms

Forms encoded as `multipart/form-data`to allow binary data, such as files, to be safely sent to the server. To create a form that allows the sever to recevie a file, create a file named `upload.html`like:

```html
<body>
<div class="m-1 p-2 bg-primary text-white h2 text-center">
    Upload File
</div>
<form method="post" action="/forms/upload" class="p-2" enctype="multipart/form-data">
    <div class="mb-3">
        <label class="form-label">Name</label>
        <input class="form-control" type="text" name="name">
    </div>
    
    <div class="mb-3">
        <label class="form-label">City</label>
        <input class="form-control" type="text" name="city">
    </div>
    
    <div class="mb-3">
        <label class="form-label">Choose Files</label>
        <input class="form-control" type="file" name="files" multiple>
    </div>
    
    <button type="submit" class="btn btn-primary mt-2">Upload</button>
</form>
</body>
```

For this, the `enctype`attribute on the `form`element creates a multiplart form, and the `input`element whose type is `file`creates a form control that allows the user to select a file.

```go
func HandleMultipartForm(writer http.ResponseWriter, request *http.Request) {
	fmt.Fprintf(writer, "Name: %v, City: %v\n", request.FormValue("name"),
		request.FormValue("city"))
	fmt.Fprintln(writer, "------")
	file, header, err := request.FormFile("files")
	if err == nil {
		defer file.Close()
		fmt.Fprintf(writer, "Name: %v, Size: %v\n", header.Filename, header.Size)
		for k, v := range header.Header {
			fmt.Fprintf(writer, "key: %v, value: %v\n", k, v)
		}
		fmt.Fprintln(writer, "------")
		io.Copy(writer, file)
	} else {
		http.Error(writer, err.Error(), http.StatusInternalServerError)
	}
}

func init() {
	http.HandleFunc("/forms/upload", HandleMultipartForm)
}
```

Note that the `FormValue`and `PostFormValue`methods can be used to access string values in the form, but the file must be accessed using the `FormFile`method. like:

`file, header, err := request.FormFile("files")`

Note that the first result is a `File`defined in the `mime/multipart`package, which is an interface that just combines the `Reader, Closer, Seeker`-- and `ReadAt`interfaces. The second is `FileHeader`-- this defines some:

- `Name`-- name of the file
- `Szie`-- `int64`
- `Header`-- `map[string][]string`cotnains the headers from the MIME part that contains the file.
- `Open()`-- returns a `File`that can be used to read the content.

#### Receiving Multiple Files in the form

The `FormFile`method returns only the first file with the specified name, which means that it can’t be used when the user is allowed to select multiple files for a single form element, so:

```go
func HandleMultipartForm(writer http.ResponseWriter, request *http.Request) {
	request.ParseMultipartForm(100000000)
	fmt.Fprintf(writer, "Name: %v, City: %v\n",
		request.MultipartForm.Value["name"][0],
		request.MultipartForm.Value["city"][0])
	fmt.Fprintf(writer, "------")

	for _, header := range request.MultipartForm.File["files"] {
		fmt.Fprintf(writer, "name: %v, size: %v\n", header.Filename, header.Size)
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

For this, must ensure that the `ParrseMutlipartForm`is called before using the `MultipartForm`field.

- `Value`-- returns a `map[string][]string`that contains the form values
- `File`-- returns a `map[string][]*FileHeader`contains the files.

### Reading and setting Cookies

The `net/http`package defines the `SetCookie`which adds a `Set-Cookie`header to the response sent to the client.

- `SetCookie(writer,cookie)`-- adds `Set-Cookie`header to the specified `ResponseWriter`, the cookie is described using a pointer to a `Cookie`struct.

Cookies are described using the `Cookie`-- which is defined in the `net/http`package and defines :

`Name, Value, Path, Domain, Expires, MaxAge, Secure, HttpOnly, SameSite`

And the `Cookie`struct is also used to get the set of cookies that a client sends, which done using the `Request`methods:

- `Cookie(name)`-- pointer to the `Cookie`value
- `Cookies()`-- returns a slice of `Cookie`pointers.

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
			fmt.Fprintf(writer, "Cookie name: %v, Value: %v", c.Name, c.Value)
		}
	} else {
		fmt.Fprintln(writer, "Request contains no cookies")
	}
}

func init() {
	http.HandleFunc("/cookies", GetAndSetCookie)
}
```

This example sets up a `/cookies`route, for which the `GetAndSetCookie`func sets a cookie. When a request contains the cookie, the cookie value is read, parsed to an `int`, and incremented so that it can be used to set a new cookie value.

### Don’t use a filename as a fuction input

When creating a new function that need to read a file, passing a filename isn’t considered a best practice and can have negative effects -- such as making unit tests harder to write. Suppose want to implement a function to count the number of empty lines in a file just like:

```go
func countEmptyLinesInFile(filename string) (int, error) {
    file, err := os.Open(filename)
    if err != nil{
        return 0, err
    }
    scanner := bufio.NewScanner(file)
    for scnner.Scan() {
        //...
    }
}
```

But, if want to implement unit tests to cover the following cases -- 

- A nominal case
- an Empty file
- A file containing only empty lines

Each unit test will require creating a file in Go proj, the more complex the func is, the more case we want to add.

Furthermore, this isn’t resuable. FORE, if had to implement the same logic but count the number of empty lines with an HTTP requst, would have to duplicate the main logic.

One way to overcome these might be make the func to accept a `*bufio.Scanner`, so write a new one like:

```go
func countEmptyLines(reader io.Reader) (int, error) {
    scanner := bufio.NewScanner(reader)
    for scanner.Scan() {//...}
}
```

First, the func abstracts the data source, another is related to testing. Fore:

```go
func TestCountEmptyLines(t *testing.T) {
    emptyLines, err := countEmptyLines(strings.NewReader(...))
}
```

So, in the test, create an `io.Reader`using `strings.Newreader`.