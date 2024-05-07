# Readers-Writer mutexes

Only one goroutine at a time can execute our mutex-protected critical section. What if had an app serving mostly static data to many concurrent clients -- So on average, get a few of these events every second. At the other end, have a large set of goroutines serving the entire list of game events to a huge number of connected users.

Write two different types of goroutines, starting with the match-recorder function. In code, simulating an event happening every 200ms by adding a astring containig *Match Event i* -- The goroutine would be listening to a sports feed or periodically polling an API.

```go
func matchRecorder(matchEvents *[]string, mutex *sync.Mutex) {
	for i := 0; ; i++ {
		mutex.Lock()
		*matchEvents = append(*matchEvents,
			"Match event "+strconv.Itoa(i))
		mutex.Unlock()
		time.Sleep(200 * time.Millisecond)
		fmt.Println("Appended match event")
	}
}
```

Shows a client handler function together with a function that cipies all the events in the shared slcie. Run this as a goroutine, each handling a connected user. And the function locks the shared slice contining the game events and amkes a copy of every element in the slice.

```go
func clientHandler(mEvents *[]string, mutex *sync.Mutex, st time.Time) {
	for i := 0; i < 100; i++ {
		mutex.Lock()
		allEvents := copyAllEvents(mEvents)
		mutex.Unlock()

		timeTaken := time.Since(st)
		fmt.Println(len(allEvents), "events copied in", timeTaken)
	}
}

func copyAllEvents(matchEvents *[]string) []string {
	allEvents := make([]string, 0, len(*matchEvents))
	for _, e := range *matchEvents {
		allEvents = append(allEvents, e)
	}
	return allEvents
}
```

Connect everything together and start our goroutines in a `main`. In this main, after create a normal mutex, prepopulate the match event slice with many match events.

```go
func main() {
	mutex := sync.Mutex{}
	var matchEvents = make([]string, 0, 10000)
	for j := 0; j < 10000; j++ {
		matchEvents = append(matchEvents, "Match Event")
	}
	go matchRecorder(&matchEvents, &mutex)
	start := time.Now()
	for i := 0; i < 5000; i++ {
		go clientHandler(&matchEvents, &mutex, start)
	}
	time.Sleep(100 * time.Second)
}

```

Acutally, in comparison to the number of read queries, the data changes very slowly, when use normal mutex locks, every time a goroutine reads the shared data, it blocks all the other serving gorotuines until it’s finished.

So, it would be better if all clients handler goroutines had non-exclusive acess to the slice so that they could read the list at the same time if needed. Would only block access to the shared data if there was a need to update that. This is just the *readers-writer* lock give us. Just need to read a shared recource without updating it, the readers-writer lock allow multiple concurrent goroutines to execute the read-only critrical section part.

```go
func (rw *RWMutex) Lock()
func (rw *RWMutex) RLock() // locks read part
func (rw *RWMutex) RLocker() Locker // returns read part
// and RUnlock, TryLock(), TryRLock() and Unlock
```

The Locking and unlocking that have a `R`in the function name, gives us the reader’s side `RWMutex`. Everything, such as `Lock()`let’s operate the **write** part. Can now modify our application serving updates to use thse new functions.

```go
mutex := sync.RWMutex{}
//...
func matchRecorder(matchEvents *[]string, mutex *sync.RWMutex) {
	for i := 0; ; i++ {
		mutex.Lock() // also Lock
        //...
    }}
func clientHandler(mEvents *[]string, mutex *sync.RWMutex, st time.Time) {
	for i := 0; i < 100; i++ {
		mutex.RLock()
        //...
        mutex.RUnlock()
        //...
    }}
```

## Conditional Variables and semaphores

Mutexes are not only the sync tool that we have available, condition variables gives us extra controls that complement exclusive locking. Give us the ability to wait for a certain condition to occur before unblocking the execution. Semaphores allows us to control how many concurrent goroutine can execute a certain section at the same time.

### Condition variables

What if try to create an *imbalance* where where `Spendy`is spending at a faster rate than `Stingy`. Since we are now spending at a faster rate than we are earning, the bank might also have additional costs when go into a negative balance. When the bank account goes negative, print a message and exit the program. In both funcs, the value earned and spent is the same.

```go
func stingy(money *int, mutex *sync.Mutex) {
	for i := 0; i < 1000000; i++ {
		mutex.Lock()
		*money += 10
		mutex.Unlock()
	}
	fmt.Println("Stringy Done")
}

func spendy(money *int, mutex *sync.Mutex) {
	for i := 0; i < 200000; i++ {
		mutex.Lock()
		*money -= 50
		if *money < 0 {
			fmt.Println("Money is negative")
			os.Exit(1)
		}
		mutex.Unlock()
	}
	fmt.Println("Spendy Done")
}

func main() {
	mutex := sync.Mutex{}
	var money int = 100
	go stingy(&money, &mutex)
	go spendy(&money, &mutex)
	time.Sleep(10 * time.Second)
}
```

Ideally, want a system that doesn’t spend money we don’t have. Can try to have the `spendy()`function check if there is enough money before it goes ahead and spends. If there isn’t enough, can just have the goroutine sleep for some time.

```go
for *money < 50 {
    mutex.Unlock()
    time.Sleep(10 * time.Millisecond)
    mutex.Lock()
}
```

This solution will work for our use case -- it’s not ideal. Just choose the arbitrary sleep vlaue of 10 ms. But there would be the optimal number to choose ? -- Can choose not to sleep at all. This ends up just wasting CPU resources. This is where condition variables come in play.  Fore, if condition is note met, gorotuine A calls the `Wait()`func on the condition variable -- and the `Wait()`performs two ops *atomically*. -- it releases the mutex, blocks the current execution effectively putting the goroutine to sleep. Since the mutex is now just available, another goroutine acquires it to update the shared state. After updating the shared state, goroutine B calls `Signal()`or `Broadcast()`on the condition variable and then *unlocks* the mutex.

Upon receiving `Signal()`, A wakes up and automatically reacquires the mutex.

```go
type Cond
func NewCond(l Locker) *Cond
func (c *Cond) Broadcast()
func (c *Cond) Signal()
func (c *Cond) Wait()
```

```go
func stingy(money *int, cond *sync.Cond) {
	for i := 0; i < 1000000; i++ {
		cond.L.Lock()
		*money += 10

		// signals on the cond variable every time add the shared money
		cond.Signal()
		cond.L.Unlock()
	}
	fmt.Println("Stringy Done")
}

func spendy(money *int, cond *sync.Cond) {
	for i := 0; i < 200000; i++ {
		cond.L.Lock()
		for *money < 50 {
            // waits while we don't have enough money
            // releasing mutex and suspending execution
			cond.Wait()
		}
		*money -= 50
		if *money < 0 {
			fmt.Println("Money is negative!")
			os.Exit(1)
		}
		cond.L.Unlock()
	}
	fmt.Println("Spendy Done")
}

func main() {
	money := 100
	mutex := sync.Mutex{}
	cond := sync.NewCond(&mutex)
	go stingy(&money, cond)
	go spendy(&money, cond)
	time.Sleep(2 * time.Second)
	mutex.Lock()
	fmt.Println("Money in bank account:", money)
	mutex.Unlock()
}
```

## Encoding Structs

The `Encoder`express struct values as JSON objects, using the exported struct field anmes as the object’s keys and the field values as the object’s values. 

```go
func main() {
    var writer strings.Builder
    encoder := json.NewEncoder(&writer)
    encoder.Encode(kayak)
    fmt.Print(writer.String())
}
```

### Understanding the effecto of Promotion of JSON in Encoding

When a struct defines an *embedded* field that is also a struct,  the fields of the embedded struct are prmoted an encoded as though they are defined by the enclosing type.

```go
type DiscountProduct struct {
	*Product
	Discount float64
}

var kayak = Product{Name: "Kayak", Category: "Watersports", Price: 279}

func main() {
	dp := DiscountProduct{
		&kayak, 10.50,
	}
	result, err := json.Marshal(dp)
	if err == nil {
		fmt.Println(string(result))
	}
}
```

Notice that encodes to the `struct`value, and the `Encode`function follows the pointer and encodes the value as its location, which means that the code 

#### Customizing the JSON encoding of Structs

How a struct is encoded can be cuztomized using *struct* tags, which are string lterals that follow fields. Struct tags are part of the Go support for reflection. So:

```go
type DiscountProduct struct {
	*Product `json:"product"`
	Discount float64
}
```

A tag specifies the name `product`for the embedded field. Compiled and execute:

#### Omitting a Field

And the `Encoder`skips fields decorated with a tag that specifies a hyphen `-`for the name like:

```go
type DiscountProduct struct {
	*Product `json:"product""`
	Discount float64 `json:"-"`
}
```

#### Omitting unassigned Fields

By default, the JSON `Encoder`includes struct fields, even when they have not been assigned a value.

```go
func main() {
	var writer strings.Builder
	encoder := json.NewEncoder(&writer)
	dp := DiscountProduct{
		&kayak, 10.50,
	}
	encoder.Encode(&dp)
	dp2 := DiscountProduct{Discount: 10.50}
	encoder.Encode(&dp2)
	fmt.Println(writer.String()) // {"product":null}
}
 // 
// if:
type DiscountProduct struct {
	*Product `json:"product,omitempty""`
	Discount float64 `json:"-"`
} 
// then the output is `{}`
```

#### Forcing Fields to be Encoded as strings

Struct tags can be used to force a field value to be encoded as a string just like:

```go
type DiscountProduct struct {
	*Product `json:"product,omitempty""`
	Discount float64 `json:",string"`
}
```

#### Encoding Interfaces

The JSON encoder can be used on values assigned to interface variables, but it is the dynamic type that is encoded.

```go
type Named interface {
	GetName() string
}

type Person struct{ PersonName string }

func (p *Person) GetName() string          { return p.PersonName }
func (p *DiscountProduct) GetName() string { return p.Name }
```

For this, defines a simple interface and a struct that implements it. Just:

```go
namedItems := []Named{&dp, &Person{"Alice"}}
encoder.Encode(namedItems)
fmt.Println(writer.String())
```

#### Creating completely Custom JSON Encoding

The `Encoder`checks to see whether a struct implement the `Marshaler`interface, denotes a type that has a custom encoding and which defines the method like:

- `MarshalJSON()`-- invoked to create a JSON representation of a value and returns a byte slice containing the JSON and an `error`indicating encoding problem.

```go
func (dp *DiscountProduct) MarshalJSON() (jsn []byte, err error) {
	if dp.Product != nil {
		m := map[string]any{
			"product": dp.Name,
			"cost":    dp.Price - dp.Discount,
		}
		jsn, err = json.Marshal(m)
	}
	return
}
```

The `MarshalJSON()`can just generate JSON in any way that suites the project.

### Decoding JSON data -- 

And the `NewDecoder`constructor function just creates a `Decorder`, which can be used to decode JSON data obtained from a `Reader`, using the methods like:

- `Decode(value)`-- reads and decodes data, used to create the specified value.
- `DisallowUnknownFields()`-- by default, when decoding a struct type, the `Decoder`ignores any key in the JSON data for which there is no corresponding struct field. Calling this method causes the `Decode`to return an `error`.
- `UseNumber()`- by default, JSON number value are decoded into `float64`. Calling this method uses the `Number`type instead.

```go
func main() {
	reader := strings.NewReader(`true "hello" 99.99 200`)
	vals := []any{}
	decoder := json.NewDecoder(reader)
	for {
		var decodeVal any
		err := decoder.Decode(&decodeVal)
		if err != nil {
			if err != io.EOF {
				fmt.Printf("error: %v\n", err.Error())
			}
			break
		}
		vals = append(vals, decodeVal)
	}
	for _, val := range vals {
		fmt.Printf("Decode (%T): %v\n", val, val)
	}
}
```

The first step in decoding the data is to create the `Decoder`which accepts a `Reader`. For this, want to decode multiple values, call the `Decode()`inside the `for`, and is able to select the appropriate Go data type for JSON values, and this is achieved by providing a pointer to an empty interface as the argument to the `Decode`.

```go
var decodedVal any
err := decoder.Decode(&decodedVal)
```

#### Decoding Number -- 

This behavior can be changed by calling the `UserNumber`on the `Decoder`, which causes JSON number values to be decoded into the `Number`type. just like: `Int64()`... and `String()`.

```go
//...
decoder.UseNumber()
//...
for _, val := range vals {
    if num, ok := val.(json.Number); ok {
        if ival, err := num.Int64(); err == nil {
            fmt.Printf("Decoded Integer: %v\n", ival)
        }
    }
}
```

#### Specifying Types for Decoding -- 

Lets the `Decoder`select the Go data type for the JSON value that is decoded. Just like:

```go
func main() {
	reader := strings.NewReader(`true "hello" 99.99 200`)
	var bval bool
	var sval string
	var fpval float64
	var ival int

	vals := []any{&bval, &sval, &fpval, &ival}
	decoder := json.NewDecoder(reader)
	for i := 0; i < len(vals); i++ {
		err := decoder.Decode(vals[i])
		if err != nil {
			fmt.Printf("Error: %v\n", err.Error())
			break
		}
	}
	fmt.Printf("Decoded (%T): %v\n", fpval, fpval)
	fmt.Printf("Decoded (%T): %v\n", ival, ival)
}
```

## Melt a data set

A pivot table aggregates the values in a data set. In this section, learn how to do the opposite, break an aggregated collection of data into an unaggregated one. Often have to choose between flexibility and readibility when manipulating data in a wide or narrow format. For the `sales`DF -- is std narrow ones.

Have to choose between flexibility and readability when maniupulating data in a wide or narrow format. But there is no real benefit cuzt he four variables are just distinct and separate. `videw`stores its data in wide foramt -- four columns just store the same data point. Cuz if added more regional sales columns, the data set would grow horizontally.

In a way, we are *unpivoting* the DF -- are converting an aggregate, summary view of the data to one in which each column stores one variable piece of information. Melting is just process of converting a wide set to a narrow one.

- `id_vars`set the identifier column -- for which the data set aggregated data.
- `value_vars`accepts the column(s) whose values pandas will melt and store in a new column.

```python
video.melt(id_vars='Name', value_vars='NA') # stores the former column name in a new variable column
video.melt(id_vars='Name',
           value_name='cost', 
           value_vars= 'NA EU JP Other'.split(), 
           var_name='Region')
```

So the variable column just holds the 4 regional column names from the original df. So:

- The `id_vars`parameter specifies which columns we want to keep as is
- The `value_vars`specifies which columns want to melt
- `var_name`gives a name to the new column that holds the original column names
- `value_name`gives a name to the new column that holds the values.

### Exploding a list of values

Sometimes a data set stores multiple values in the same cell. May want to break up the data cluster so that each row stores a single vlaue. For the `str.split()`-- uses a delimier to split a string into substrings. Can split each by the presence of a comma. `recipes.Ingredients.str.split(',')`, overwrite the original column with new one like:
`recipes.explode('Ingredients')`

#### `melt()`and `wide_to_long()`

The `melt()`are useful to massage a DF into a foramt where one or more columns are *identifier variables*, while all other columns considered measured variables, are just unpivoted to the row axis.

```python
cheese = pd.DataFrame(
    {
        "first": ["John", "Mary"],
        "last": ["Doe", "Bo"],
        "height": [5.5, 6.0],
        "weight": [130, 150],
    }
)
cheese.melt(id_var)
```

