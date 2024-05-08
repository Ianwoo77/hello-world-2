# The GroupBy Object

`GroupBy`object is a storage container for grouping `DataFrame`rows into buckets. It provides a set of methods to aggregate and analyze each independent gourp in the collection. It allows us to extract rows at specific index positioning *within each group*.

```python
import requests
res= requests.get('https://raw.githubusercontent.com/realpython/python-data-cleaning/master/Datasets/BL-Flickr-Images-Book.csv',
                  proxies=dict(https='http://localhost:7890'))
import io
df = pd.read_csv(io.StringIO(res.text))
```



### Creating object from Scratch

`Type`column identifies the group to which an item belongs. The `GroupBy`object organizes `DataFrame`rows into buckets based on shared values in column. Fore, interested in the average price of a fruit and the rows into separate groups, it could isolate the `Fruit`and `Vegetable`rows into separate groups.

```python
groups = supermarket.groupby('Type')
groups # pandas.core.groupby.generic.DataFrameGrouBy object
# 
# the column Type has two unique values like:
roups.get_group('Vegetable')
# and the GroupBy object excels at aggregate operations like:
groups.mean(numeric_only=True)
```

### Creating from a data set

```python
fortune = pd.read_csv('fortune1000.csv')
#
# A sector can have many companies, Fore And an industry is a subcategory within a sector
# if extract:
in_retailing = fortune.Sector=="Retailing"
retail_companies= fortune[in_retailing]
retail_companies.head()
# then can pull out the Revenues column like:
retail_companies.Revenues.head()
retail_companies['Revenues'].mean()
```

`GroupBy`object just offers the best solution out of the box, the pandas developers have already solved -- The method accepts the column whose values pandas will use to group the rows, a column is a good candidates for grouping.

```python
sectors = fortune.groupby('Sector')
# note that DataFrameGroupBy is a bundle of DataFrames
len(sectors)
fortune.Sector.nunique() # also 21
sectors.size() # can tell a Series with an alphabetical list of groups
```

### Attributes and methods of a `GroupBy`object

The `groups`attribute stores a dictionary with this grou-to-row associations.
`sectors.groups`-- values and `Index`object storing the row index positions from the fortune `DataFrame`.
`fortune.loc[26, 'Sector'] `and:

```python
sectors.first() #extracts the first row listed for each sector in fortune
# cuz has been sorted by revenue.
```

And the `head()`method extract multiple rows from each group.

```python
sectors.head(2) # 42 returned, cuz 21 for every
# can use the `get_group`method to extract all rows in the given group
sectors.get_group('Energy').head()
```

### Aggregate operations

Can invoke methods on the `GroupBy`object to apply aggregate operations to every *nested* group. By default, pandas targets **all** numeric columns in the original Df. Like:

```python
sectors.sum(numeric_only=True).head(10)
# double-check
sectors.get_group('Aerospace & Defense').loc[:, 'Revenues'].head()
```

Values are equal -- Pandas is correct -- with a single `sum()`call, the library applied the calculation logic to each nested `DF`in the `sectors`object.

Can target a single column by passing its anme inside `[]`after the `GroupBy`object. Under the hood, the `DataFrameGroupBy`object stores a collection of a `SeriesGroupBy`objects. The `SeriesGroupBy`objects can perform aggregate operations on individual columns from fortune.

```python
sectors['Revenues'].sum(numeric_only=True).head()
# for the Employees per sector like:
sectors['Employees'].mean()
# max, min...
```

And there is an `agg`method applies muliple aggregate operations to different columns and accepts a dictionary as its argument. like:

```python
aggregations = dict(Revenues=np.min, Profits=np.max, Employees=np.mean)
sectors.agg(aggregations).head()
```

Pandas returns a `DataFrame`with the aggregation dictionary’s keys as column headers.

## Condition variables

```go
func spendy(money *int, mutex *sync.Mutex) {
    for i:=0; i<200000; i++ {
        mutex.Lock()
        for *money<50 {
            mutex.Unlock()
            time.Sleep(10*time.Millisecond)
            mutex.Lock()
        }
        *money-=50
        //...
    }
}
```

The Condition variables work together with mutexes and give us the ability to suspend the current execution until have a single that a particular condition as changed. Fore:

```go
func stringy(money *int, cond *sync.Cond){
    for i:=0; i<1000000; i++ {
        cond.L.Lock()
        *money+=10
        cond.Signal() // signals the condition variable everytime add money
        cond.L.Unlock()
    }
    //...
}

func spendy(money *int, cond *sync.Cond) {
    for i:=0; i<200000; i++ {
        cond.L.Lock()
        for *money<50 {
            cond.Wait() // waits while don't have enough money
        }
        *money -= 50
        //...
        cond.L.Unlock()
        //...
    }
}
```

Note -- whenever a waiting goroutine receives a signal or broadcast, it will try to re-acauire the mutex.

### Missing the signal

So, What happens if a goroutine calls `Signal()`or `Broadcast()`and there is no executing waiting for it. If there is no gorotuine in a waiting state, the `Signal()`.. call will be **missed**. So far, have been using `time.Sleep()`in our `main()`to wait for our goroutines to complete. So, instead of using `Sleep()`, can have our `main()`wait on a condition variable and then have the child goroutine send a signal when just ready. like:

```go
func doWork(cond *sync.Cond) {
	fmt.Println("Work started")
	fmt.Println("Work finished")
	cond.Signal()
}

func main() {
	cond := sync.NewCond(&sync.Mutex{})
	cond.L.Lock()
	for i := 0; i < 50000; i++ {
		go doWork(cond)
		fmt.Println("Waiting for child goroutine")
		cond.Wait()
		fmt.Println("Child goroutine finished")
	}
	cond.L.Unlock()
}
```

For this, will panic dead-lock. The problem in this is that we might end up signaling when the `main()`goroutine is not waiting on the condition variable. When this happens, we miss the signal. Then there will be some time, waiting in vain since there are no other goroutines that might call the signal function, throw. So: Need to ensure that when we call the signal or broadcast fuction, there is another goroutine waiting for it.

To ensure that don’t miss any signals and broadcasts, need to use them in conjunction with mutexes. Should call these functions only when are holding the associated mutex.

```go
func doWork(cond *sync.Cond) {
	fmt.Println("Work started")
	fmt.Println("Work finished")
	cond.L.Lock()
	cond.Signal()
	cond.L.Unlock()
}
```

#### Synchronizing mutliple goroutines with waits and broadcasts

Whenwe have multiple goroutines suspended on a condition variable’s `Wait()`, `Signa()`will arbitrarily wake up one of these -- and the `Broadcast()`call, will wake up all goroutines that are suspended on a `Wait()`.

To simulate the goroutines handling 4 players, with each player conncting to the game at a different time, can have a `main`creating each of the goroutines at a time interval. like:

```go
func main() {
	cond := sync.NewCond(&sync.Mutex{})
	playersInGame := 4
	for playId := 0; playId < 4; playId++ {
		go playerHandler(cond, &playersInGame, playId)
		time.Sleep(time.Second)
	}
}
```

Can make use of condition variables by having more than one gorotuine wait on the same condition. Can use the same condition variable to check if the players are connected, and if not, just call `Wait()`. The difference here is that a goroutine will call `Broadcast()`if it finds out that there are no more players remanining to connect.

```go
func playerHandler(cond *sync.Cond, playersRemaining *int, playerId int) {
	cond.L.Lock()
	fmt.Println(playerId, ": connected")
	*playersRemaining--
	if *playersRemaining == 0 {
		// send broadcast when all connected
		cond.Broadcast()
	}
	for *playersRemaining > 0 {
		fmt.Println(playerId, ": waiting for more players")
		cond.Wait()
	}
	cond.L.Unlock()
	fmt.Println("All players connected, ready player", playerId)
}
```

#### Revising readers-writer locks using condition variables

Used mutexes to develop our own implementation of a readers-writer lock. A writer goroutine can only acquire the lock if all the readers have released their locks. In technical-speaking , call this scenario *write-starvation* -- we can’t update our shared data structures cuz the reades parts of the execution are continuously accessing them.

```go
func main() {
	rwMutex := ReadWriteMutex{}
	for i := 0; i < 2; i++ {
		go func() {
			for {
				rwMutex.ReadLock()
				time.Sleep(time.Second)
				fmt.Println("read done")
				rwMutex.ReadUnlock()
			}
		}()
	}
	time.Sleep(time.Second)
	rwMutex.WriteLock() // tries to acquire the writer's lock from main()
	fmt.Println("Write finished")
}
```

For this, even though we have an infinite loop in our goroutine, expect that eventually the `main`goroutine will acquire a hold on the writer’s lock.. Our two goroutines constantly hold the reader part of our mutex, which prevents our `main`goroutine from ever acquiring the writer’s part of the lock. So:

**DEF**: Starvationis a situation where an execution is blocked from gaining access to a shared resource cuz the resource is made unavailable for a long time by other *greedy* executions.

So, need a different design for a readers-writer lock that is not read-preferred. Could block new readers from acquiring the read lock as soon as writer calls the `WriteLock()`function. To achieve this, instead of having the goroutines block on a mutex, could have them suspended using a condition variable. With a condition variable, can have different conditions on when to block readers and writers. 

To design a write-preferred lock, need a few properties -- 

- Readers’ counter -- Initial 0, tells us how many reader goroutines are actively accessing the shared resources
- Writer’s waiting counter -- 0 inintial, how many writer goroutines are suspended waiting to access the shared
- Writer active indicator -- `false`initial, tells us if the resoruce is currently being updated by a writer goroutine
- Condition variable with mutex -- allows us to set various conditions on the preceding properties.

## Decoding JSON data

`NewDecoder`creates a `Decorder`-- can be used to decode JSON data obtained from a `Reader`.

- `DisallowUnknownFields()`-- when decoding, the `Decoder`ignores any key in the JSON data
- `UseNumber()`-- by default, JSON number values are decoded into `float64`, calling uses the `Number`type instead.

#### Decoding Number type 

```go
//...
decoder := json.NewDecoder(reader)
decoder.UseNumber()
//...
for _, val := range vals {
    if num, ok := val.(json.Number); ok {// note that, json.Number type
        if ival,err := num.Int64(); err == nil {
            // ... int type
        }
    }
}
```

#### Specifying Types for Decoding

If know the structure of the JSON data, can just direct the `Decoder`to use specific Go types like:

```go
// ...
var ival int
vals := []any {&ival}
for i:=0; i<len(vals); i++ {
    err := decoder.Decode(vals[i])
    if err != nil {
        break
    }
}
```

#### Decoding Arrays

The `Decoder`processes arrays automatically, but care must be taken cuz JSON allows arrays to contain values of different types -- which conflicts with the strict type rules.

```go
func main() {
	reader := strings.NewReader(`[10,20,30]["Kayak", "Lifejacket", 279]`)
	vals := []any{}
	decoder := json.NewDecoder(reader)
	for {
		var decodedVal any
		err := decoder.Decode(&decodedVal)
		if err != nil {
			if err != io.EOF {
				fmt.Printf("Error: %v\n", err.Error())
			}
			break
		}
		vals = append(vals, decodedVal)
	}

	for _, val := range vals {
		fmt.Printf("Decoded: (%T): %v\n", val, val)
	}
}
```

The type of the slice is the empty interface. And if U know the structure of the JSON data in advance, just like:

```go
ints := []int{}
mixed := []any{}
vals := []any{&ints, &mixed}
decoder := json.NewDecoder(reader)
for i := 0; i < len(vals); i++ {
    err := decoder.Decode(vals[i])
    if err != nil {
        fmt.Printf("Error: %v\n", err.Error())
        break
    }
}
```

#### Decoding Maps

Js objects are expressed as k-v pairs, which make it just easy to decode them into Go maps just like:

```go
func main() {
	reader := strings.NewReader(`{"kayak":279, "lifejacekt":49.95}`)
	m := map[string]any{}
	decoder := json.NewDecoder(reader)
	err := decoder.Decode(&m)
	if err != nil {
		fmt.Println(err.Error())
	} else {
		fmt.Printf("Map: %T, %v\n", m, m)
		for k, v := range m {
			fmt.Printf("Key: %v, Value: %v\n", k, v)
		}
	}
}
```

And a single JSON object can be used for multiple data types as values, but, if U know in advance that U will be decoding a JSON object that has a single value type, then U can be more specific when defining the map into which the data will be decoded just: `m := map[string]float64{}`

#### Decoding Structs

The k-v structure of JSON objects can be decoded into Go struct values just like:

```go
//...
decoder := json.NewDecoder(reader)
for {
    var val Product
    err := decoder.Decode(&val)
    if err != nil {
        if err != io.EOF {
            fmt.Println(err.Error())
        }
        break
    } else {
        fmt.Printf("Name: %v, Category: %v, Price: %v\n",
                   val.Name, val.Category, val.Price)
    }
}
```

#### Disallowing Unused Keys

By default, the `Decoder`will ignore JSON keys for which there is no corresponding struct field. This behavior can be changed by calling the `DisallowUnknownFields()`-- which triggers an error when such a key is encountered.

```go
decoder := json.NewDecoder(reader)
decoder.DisallowUnknownFields()
```

#### Using struct Tag to control Decoding 

The keys used in JSON object don’t always align with the fields defined by the struct in go Proj. Fore:

```go
type DiscountedProduct struct {
    *Product `json:",omitempty"`
    Discount float64 `json:"offer,string"`
}
```

#### Creating Compltely Custom JSON Decoders

The `Decoder`checks to see whether a struct implements the `Unmarshaler`interface, which denotes a type that has a custom encoding, and which defines the method:

- `UnmarshalJSON(byteSlice)`-- invoked to decode JSON data contained in the specified byte slice.

```go
func (dp *DiscountProduct) UnmarshalJSON(data []byte) (err error) {
	mdata := map[string]any{}
	err = json.Unmarshal(data, &mdata)
	//...
}
```

### Working with Files

The key package when dealing with files in the `os`-- provides access to OS featurs, including the file system. The netural approach adopted by the `os`leads to some comprmises and leans towards Unix/Linux.

- `ReadFile(name)`-- opens the specified file and reads its contents, the result are the byte slice containing the file content and an `error`indicating problems.
- `Open(name)`-- opens the specified, the result is `File`struct and an `error`.

Using the read Convenience Function -- The `ReadFile()`provides a convenient way to read the complete contents of a file into a byte slice in a single step.

```go
func LoadConfig() (err error) {
	data, err := os.ReadFile("config.json")
	if err == nil {
		fmt.Println(string(data))
	}
	return
}

func init() {
	err := LoadConfig()
	if err != nil {
		fmt.Printf("Error loading Config: %v\n", err.Error())
	}
}
```

The contents of the file are returned as a `byte`slice, which is converted to a `string`and written out.

Decoding the JSON data -- for the example configuration file, Receiving the contents of the file as a string is not ideal, and a more useful approach would be to parse the contents as JSON.

```go
type ConfigData struct {
	UserName           string
	AdditionalProducts []*Product
}

var Config ConfigData

func LoadConfig() (err error) {
	data, err := os.ReadFile("config.json")
	if err == nil {
		decoder := json.NewDecoder(strings.NewReader(string(data)))
		err = decoder.Decode(&Config)
	}
	return
}
```

