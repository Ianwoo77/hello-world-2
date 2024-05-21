# Built-in Aggregations

```python
avg_life_exp_by_year= df.groupby('year')['lifeExp'].mean()
years= df.year.unique() # return a list of unique years in the data
y1952 = df.loc[df.year=1952, :]

# can calculate multiple summary statistics simultaneously
continent_describe = df.groupby('continent')['lifeExp'].describe()
```

### Aggregation Functions

Can also use an aggregation function that is not listed -- instead of directly calling the aggregation methods, can call the `.agg()`or `.aggregate()`method.

```python
cont_le_agg = df.groupby('continent')['lifeExp'].agg(np.mean)
```

Note: when passing in the function into `.agg()`, only need the actual function object, do not need to call the function.

#### Custom User Functions

Sometimes we may want to perform a calculation that is not provided by Pandas or another library. Can write our own function that peforms the calculation we want and use it in `agg()`as well.

```python
def my_mean(values):
    n = len(values)
    sum =0
    for value in values:
        sum+=value
    return sum/n

agg_my_mean= df.groupby('year')['lifeExp'].agg(my_mean)
```

Then, can write functions that take multiple parameters, as long as the first parameter takes the series of values from the dataframe, can pass the other arguments as keywords into `.agg()`or `aggregate()`

```python
def my_mean_diff(values, diff_values):
    n = len(values)
    sum =0 
    for value in values:
        sum+=value
    mean = sum/n
    return mean-diff_values

agg_mean_diff = (
    df.groupby('year')['lifeExp']
    .agg(my_mean_diff, df['lifeExp'].mean())
)
agg_mean_diff
```

### Multiple Functions Simultaneously

When want to calculate multiple aggregation functions, can pass the indvidual functions into `.agg()`or `.aggregate()`as a Python `list`. Like:

```python
gdf = (
    df.groupby('year')['lifeExp'].agg([np.count_nonzero, np.mean, np.std])
)
```

#### Use a dict in `agg()`and `.aggregate()`--

There are some other ways you can apply funcitons in the `agg()`and `.aggregate()`methods -- fore, can pass `agg()`a ptyhon dictionary -- the result will differ depending on whether you are aggregating directly on a `DataFrame`oon a `Series`object.

When specifying a `dict`on a grouped `DataFrame`, the keys are the columns of the `DataFrame`-- and the values are the functions used in the aggregated calculation -- this approach allows U to group one or more varaibles and use a different aggregation function on different columns.

```python
gdf_dict = df.groupby('year').agg(
    {
        'lifeExp': np.mean,
        'pop':np.median,
        'gdpPercap': np.median
    }
)

gdf_dict
```

#### On a Series

Pass a `dict`into a `Series`a `.groupby()`allowed U to directly calculate aggregate statistics as the returned value, with the key of the `dict`being the new column name. this notation is not consistent with the behaviro when `dict`s are passed into grouped `DataFrame`.

```python
gdf = (
    df.groupby('year')['lifeExp'].agg(
        [np.count_nonzero, np.mean, np.std]
    ).rename(
        columns=dict(
            count_nonzero='count',
            mean='avg',
            std='std_dev'
        )
    ).reset_index()
)
gdf
```

## Using Tempaltes to Generate Responses

There is no built-in support for using templates as responses for HTTP requests, but it is simple process to set up handler that uses the features provided by the `html/tempalte`package.

```html
<body>
<h3 class="bg-primary text-white text-center p-2 m-2">Products</h3>
<div class="p-2">
    <table class="table table-sm table-striped table-bordered">
        <thead>
        <tr>
            <th>Index</th>
            <th>Name</th>
            <th>Category</th>
            <th class="text-end">Price</th>
        </tr>
        </thead>
        <tbody>
        {{range $index, $product := .Data}}
            <tr>
                <td>{{$index}}</td>
                <td>{{$product.Name}}</td>
                <td>{{$product.Category}}</td>
                <td class="text-end">
                    {{printf "$%.2f" $product.Price}}
                </td>
            </tr>
        {{end}}
        </tbody>
    </table>
</div>
</body>
```

Then add file `dynamic.go`to the folder with the content like:

```go
type Context struct {
	Request *http.Request
	Data    []Product
}

var htmlTemplates *template.Template

func HandleTemplateRequest(writer http.ResponseWriter, request *http.Request) {
	path := request.URL.Path
	if path == "" {
		path = "products.html"
	}
	t := htmlTemplates.Lookup(path)
	if t == nil {
		http.NotFoundHandler()
	} else {
		err := t.Execute(writer, Context{request, Products})
		if err != nil {
			http.Error(writer, err.Error(), http.StatusInternalServerError)
		}
	}
}

func init() {
	var err error
	htmlTemplates = template.New("all")
	htmlTemplates.Funcs(map[string]any{
		"intVal": strconv.Atoi,
	})
	htmlTemplates, err = htmlTemplates.ParseGlob("templates/*.html")
	if err == nil {
		http.Handle("/templates/", http.StripPrefix("/templates/",
			http.HandlerFunc(HandleTemplateRequest)))
	} else {
		panic(err)
	}
}
```

The initialization function loads the templates with the `html`extension in the `templates`folder and sets up a route so that requests that start with `/templates/`are processed by the `HandleTemplateRequest`function, this function looks up the template, falling back to the `products.html`file.

#### Responding with JSON data -- 

JSON responses are widely used in web services, which provides access to an application’s data for clients.

```go
func HandleJsonRequest(writer http.ResponseWriter, request *http.Request) {
	writer.Header().Set("Content-Type", "application/json")
	json.NewEncoder(writer).Encode(Products)
}

func init() {
	http.HandleFunc("/json", HandleJsonRequest)
}
```

The initialization function creates a route, which means that requests for `/json`will be processed by the `HandlJsonRequest`function. This func uses the JSON features to encode the slice of `Product`values created.

### Handling Form Data

The `net/http`package provides support for easily receiving and procesing form data. Add a file named `edit.html`to the `templates`folder like:

#### Unintended variable shadowing

The scope of a variable refers to the places a variable can be referenced -- in other words, the part of an application where a name binding is valid, In go, a variable name declared in a block cna be redeclared in an inner block. This principle, just called *variable shadowing* -- is prone to common mistakes -- The following example shows an effect cuz of a shadowed variable -- it creates an HTTP client in two different ways -- depending on the value of :

```go
var client *http.Client
if tracing {
    // this shadowed in this block
    client, err := createClientWithTracing()
    if err != nil {
        return err
    }
    log.Println(client)
}else {
    client, err := createDefaultClient()
    if err != nil {
        return err
    }
    log.Println(client)
}
```

First declared a `client`variable, then use the short variable declaration operator `:=`in both inner blocks assign the result of the function call to the inner `client`variable, as a result, the outer variable is always `nil`. How can ensure that a value is assigned to the original `client`variable -- there are two different options -- 

```go
var client *http.Client
if tracing {
    c, err := createClientWithTracing()
    if err != nil {
        return err
    }
    client =c
}else {
    // some logic
}
```

Better option uses the assignment operatior in the inner blocks to directly assign the function results to the `client`variable -- however, this requires creating an `error`varaible cuz the assignment operator works only if a variable name has already been declared like:

```go
var client *http.Client
var err error
if tracing {
    client, err = createClientWithTracing()
    if err != nil {
        return err
    }
}else {}
```

So, instead of assigning to a temporary variable first, we can directly assign the results to `client`. Both options are perfectly valid, The main difference between the two alternatives is that we perform only one assignemnet in the second option, which may be considered easier to read. like:

```go
if tracing {
    client, err = createClientWithTracing()
}else {
    client, err = createDefaultClient()
}
if err != nil {
    //...
}
```

Variable shadowing occurs when a variable name is redeclared in an inner block, but saw that this practice is prone to mistakes. Imposing a rule to forbid shadowed variables depends on personal taste.

### Unnecessary nested code -- 

A mental model applied to software is an internal representation of a system’s behavior. While programming, need to maintain mental models. Code is qualified as readable based on multiple crtieria such as naming, consistency, formatting, ad so forth. Readable code requires less cognitive effort to maintain a mental model, hence, it is easier to read and maintain.

A critical aspect of readability is the number of nested levels, do an exercise suppose that we are working on a new project and need to understand what the following `join`function does -- like:

```go
func join(s1, s2 string, max int) (string, error) {
    if s1 == "" {
        return "", errors.New("s1 is empty")
    }else {
        if s2 == "" {
            return "", errors.New("s2 is empty")
        }else {
            concat, err := concatenate(s1, s2)
            if err != nil {
                return "", err
            }else {
                if len(concat)> max {
                    return concat[:max], nil
                }else {
                    return concat, nil
                }
            }
        }
    }
}
```

This `join`function concatenates two strings and returns a substring if the length is greater than `max`-- meanwhile, it handles checks on `s1`and `s2`and whether the call to concatenate returns an `error`. However, building a mental model encompassing all the different cases is probabley not a straight forward task like:

```go
func join(s1, s2 string, max int) (string, error) {
    if s1 == "" {
        return "", errors.New("s1 is empty")
    }
    if s2== "" {
        return "", errors.New("s2 is empty")
    }
}
```

In general, the more nested levels a function requires, the more complex it is to read and understand. see different applications of this rule of optimize our code for readability -- 

- when an `if`block returns, should omit the `else`block in all cases, fore, shouldn’t write:

  ```go
  if foo(){
      return true
  }else {...}
  // instead: 
  if foo() {
      return true
  } // the code living previously in the else block is moved to the top level
  
  // no happy path -- should flip the condition like:
  if s == "" {
      return errors.New("empty string")
  }
  ```

#### Misusing `init`functions

Sometimes we misuse init functions in Go applications, the potnetial consequences are poor error management or a code flow that is harder to understand. An `init`function is a function used to initialize the state of an application, it takes no arguments and returns no result -- like:

```go
var a = func() int {
    fmt.Println("var")  // executed first
    return 0
}()

func init(){
    fmt.Println("init") // second
}
fucn main(){
    fmt.Println("main")
}
```

So an `init`func is executed when a package is initialized - in the following example, define two packages : `main`and `redis`where `main`depends on `redis`fore

```go
func init() {}
func main() {
    err := redis.Store("foo", "bar")
}
//...
package redis
func Store(key, value string) error {
    //...
}
```

Cuz `main`depends on `redis`, the `redis`package’s `init`func is executed first, followed by the `init`of the `main`package, and then the `main`function itself.

And, can define multiple `init`per package, when do this, the execution order of the function inside the package is based on the source files’ alphabetical order. Can also define multiple `init`functions within the same source file:

```go
package main
import "fmt"
func init(){
    fmt.Println("init 1")
}
func init(){
    fmt.Println("init 2")
}
func main() {}
```

Can also use `init`functions for side effects, in the next example, define a `main`package that doesn’t have a strong dependency on `foo`. like:

```go
package main
import (
	"fmt"
    _ "foo"   // import that for side effects
)
```

In this case, the `foo`package is initialized before `main`-- the `init`functions of `foo`are executed.

#### When to use `init`-- 

look at an example where using an `init`func can be considered inappropratie -- like: Make this dbs a global variable that other functions can later use like:

```go
var db *sql.DB

func init(){
    dataSourceName := os.Getenv("MYSQL_DATA_SOURCE_NAME")
    
    d, err := sql.Open("mysql", dataSourceName)
    if err != nil {
        log.Panic(err)
    }
    err = d.Ping()
    if err != nil {
        log.Panic(err)
    }
    db = d
}
```

First, error management in an `init`func is limited -- indeed, as an `init`function doesn’t return an error, one of the only ways to signal an error is to panic, leading the application to be stopped. In our example, might be ok to stop the app anyway if opening the dbs fails. Cuz in this example, open the dbs, check whether we can ping it, and then assign it to the global variable, what should we think about this implementation.

Another important downside is related to testing -- if we add tests to this file, the `init`function will be executed before running the test cases,  Therefore, the `init`function in this example complicates writing unit tests.

```go
func createClient(dsn string) (*sql.DB, error) {
    db, err := sql.Open("mysql", dsn)
    if err != nil {
        return nil, err
    }
    if err = db.Ping(); err != nil {
        return nil, err
    }
    return db, nil
}
```

And using this func, tackled the main downside discussed -- how -- 

- The responsibility of error handling is left up to the caller.
- It’s possible to create in integration test to check that this function works
- The connection pool is encapsulated within the function.

Is it necessary to avoid `init`functions at all costs -- there are still use cases where `init`functions can be helpful.

```go
func init() {
    redirect := func(w http.ResponseWriter, r *http.Request){
        http.Redirect(w, r, "/", https.StatusFound)
    }
    http.HandleFunc("/blog", redirect)
    http.HandleFunc("/blog/", redirect)
    
    static := http.FileServer(http.Dir("static"))
    http.Handle("/favicon.ico", static)
    //...
}
```

So, in this example, the `init`function annot fail -- meanwhile, there is no need to create any globlal variables, and the fucntion will nit impact possible unit tests.

### Writing to Channels with select

Can also use the `select`statement when we need to write messages to channels -- not just when we are reading messages from channels. `Select`statements can combine read or write blocking channel operations together, selecting the case that unblocks first.

For, have to come up with 100 random prime number, in real life, we could pick a random number from a bag with a large set of number and then keep that number only if it is prime.

So in a programming, can have a primes filter that -- given a stream of random numbers, picks out any prime number it finds and outputs it on another stream. The `primesOnly()`function does exactly this -- it accepts a channel with input number and filters form prime numbers, the prime are output on the returned channel.

To prove that a number, C is non-pirme just need to find a prime number in the range from 2 to square... like:

```go
func primesOnly(inputs <-chan int) <-chan int {
    results := make(chan int)
    go func(){
        for c := range inputs {
            isPrime := c!=1
            for i:=2; i<=int(math.Sqrt(float64(c))); i++ {
                if c%i==0 {
                    isPrime = false
                    break
                }
            }
            if isPrime{
                results <-c 
            }
        }
    }()
    return results
}
```

Often, the goroutine receives a non-prime number that is thrown away, meaning no number is just output, namely, how can we feed in a stream of random number while reading the primes returned on ahnother channel in one grooutine -- the ansower is use a `select`statement to both feed in the random numbers and read the primes.

```go
func main() {
	numberChannel := make(chan int)
	primes := primesOnly(numberChannel)

	for i := 0; i < 100; {
		select {
		case numberChannel <- rand.Intn(10000000) + 1:
		case p := <-primes:
			fmt.Println("Found prime", p)
			i++
		}
	}
}
```

### Disabling select cases with nil channels

In Go, can assign `nil`values to channels -- this has the effect of blocking the channel from sending or receiving anything, ad demonstrated in the following -- the `main()`goroutine tries to send a string on a `nil`channel like:

```go
func main(){
    var ch chan string = nil
    ch <- "message"
    fmt.Println("this is never printed")
}
```

Note that, the same logic applies to `select`statements -- trying to send to receive from a `nil`channel on a `select`statement has the same effect of blocking the case using that channel.

Note that using `select`with just one nil channle is not jsut useful -- but we can use the pattern of assigning `nil`to a channel to disable a case in a `select`statement -- like:

```go
func generateAmount(n int) <-chan int {
	amounts := make(chan int)
	go func() {
		defer close(amounts)
		for i := 0; i < n; i++ {
			amounts <- rand.Intn(100) + 1
			time.Sleep(100 * time.Millisecond)
		}
	}()
	return amounts
}
```

Use a normal `select`statement to consume from both the sales and expense goroutiens, with one of the goroutines closing its channel earlier than the other. 

Another solution would be to change the channel into a `nil`channnel whenever it is closed. Reading from a channel always returns two vlaues -- the message and a flag telling us if the channel is still open. Can read the flag, and if the flag indicates that the channel has been closed, can set the channel reference to `nil`.

Assigning a `nil`value to the channel variable after the receiver detects that the channel has been closed has the effect of disabling that `case`statement. This allows the receiving goroutine to read from the remaining open channels.

```go
func main() {
	sales := generateAmount(50)
	expenses := generateAmount(40)
	endOfDayAmounts := 0
	for sales != nil || expenses != nil {
		select {
		case sale, moreData := <-sales:
			if moreData {
				fmt.Println("Sale of:", sale)
				endOfDayAmounts += sale
			} else {
				sales = nil
			}

		case expense, moreData := <-expenses:
			if moreData {
				fmt.Println("Expense of:", expense)
				endOfDayAmounts -= expense
			} else {
				expenses = nil
			}
		}
	}
}
```

Once both channels are closed and set to `nil`-- exit the `select`loop and output the end of- day balance.

# SportsStore a real appliation 

Adding packages are required for the `SportsStore`project, in addition to the core Angualr packages and build toos set up by the `ng new`command, run the command following commands to nagivate to the `SportsStore`like:

### Starting the data model 

The bset palce to start any new project is the data model -- want to get the point where U can see some Angular features at work, so rather than define the data model from end to end.

```ts
export class Product {
  constructor(
    public id?: number,
    public name?: string,
    public category?: string,
    public description?: string,
    public price?: number
  ){}
}
```

Creating the dummy data source -- To prepare for the transition from dummy to real data, going to feed the application data using a data source. The rest of the application won’t know where the data is coming from, which sill make the switch to getting data using HTTP request seamless.

```ts
@Injectable()
export class StaticDataSourceService {

  private data: Product[] = [
    new Product(1, "Product 1", "Category 1",
      "Product 1 (Category 1)", 100),
    
    //...
    ];
  
  products: Signal<Product[]>= signal<Product[]>(this.data);

}
```

The `StaticDataSource`class just defines a property named `Products`, which returns the dummy data. Signals are included in Angular16 as a preview, which means that the API may change in Angular17. Are created with the `Signal<T>`function, where `T`is the type of data contained by the signal. The type is an array of `Product`objects. The `@Injectable`decroator has been applied to the `StaticDataSource`class.

#### Creating the model repository

The data source is responsible for providing the appliation with the data it requires, but access to the data is typically mediated by a *repository* -- which is responsible for distrubuting that data to individual application building blocks so that the details of how the data has been obtained are kept hidden.

```ts
@Injectable()
export class ProductRepositoryService {
  products: Signal<Product[]>;
  categoryes: Signal<string[]>;

  constructor(private dataSource: StaticDataSourceService) {
    this.products = dataSource.products;
    this.categoryes = computed(() => {
      return this.dataSource.products()
        .map(p => p.category ?? "(None)")
        .filter((c, index, array) =>
          array.indexOf(c) === index).sort();
    })
  }

  getProduct(id: number): Product | undefined {
    return this.dataSource.products().find(p => p.id === id);
  }
}
```

Note that the computed function accepts a function argument that generates a value using one or more other signals -- in this case, the argument function reads the value of the `products`signal and uses the `map`and `filter`array methods to generate a string array contaiing the products categories. Need to note that Angular won’t recompute the value of the computed signal unless the underlying signals change.

#### Creating the feature module

Going to define an Angular feature model that will allow the data model functionality to be easily used elsewhere in the application.

```ts
@Component({
  selector: 'store',
  standalone: true,
  imports: [],
  templateUrl: './store.component.html',
  styleUrl: './store.component.css'
})
export class StoreComponent {
  products: Signal<Product[]>;
  categories: Signal<string[]>;

  constructor(private repository: ProductRepositoryService) {
    this.products = repository.products;
    this.categories = repository.categoryes;
  }
}
```

The `@Component`decorator has been applied to the `StoreComponent`class, which tells Angular that it is a component, the decorator’s properties tell Angular how to apply the component to HTML content and how to find the component’s template.

```html
<div class="container-fluid">
  <div class="row">
    <div class="bg-dark text-white p-2">
      <span class="navbar-brand m-2">SPORTS STORE</span>
    </div>
  </div>
  
  <div class="row text-white">
    <div class="col-3 bg-info p-2">
      {{categories().length}} Categories
    </div>
    <div class="col-9 bg-success p-2">
      {{products().length}} Products
    </div>
  </div>
</div>
```

Creating store feature module -- The `Injectable({providedIn:'root'})`decorator in Ng is used to configure how a service is crated and provided within your application.

- `@Injectable`-- this decorator marks a class as a service that can be injected into other componetns, directives, pipes, or even other services
- `providedIn:'root'`-- this specifies how the service is provided -- In this case, `root`indicats that the Ng framework will create a single shared instance of the service at the application’s root level injector.

Here are the key implications of using `@Injectable({providedIn:'root'})`-- 

- Singleton Service -- have a single instance of the service throughout your entire application. Any component or injectable that requests this service will receive the same instance.
- Global Availiability -- Any injectable or component in your application can request and use this service through dependency injection. This makes it a good choice for services that hold app-wide data or perform global tasks.
- Optimized Bundles -- By having a single instance, Angular can potentially removed unused parts of the service form the final build.

#### Adding store features -- 

The nature of Angular development begins with a slow start --  displaying the product details -- The obvious place to start is to display details for the products so that the customer can see what’s on offer. like:

```html
<div class="col-9 p-2 text-dark">
    <div *ngFor="let product of products()"
         class="card m-1 p-1 bg-light">
        <h4>
            {{product.name}}
            <span class="badge rounded-pill bg-primary"
                  style="float:right">
                {{product.price |
                currency:"USD":"symbol":"2.2-2"}}
            </span>
        </h4>
        <div class="card-text bg-white p-1">
            {{product.description}}
        </div>
    </div>
</div>
```

#### Adding category selection

Adding support for filtering the list of products by category requires preparing the store component so that it keeps track of which category the user wants to display and requires changing the way that data is retreived to use the category.