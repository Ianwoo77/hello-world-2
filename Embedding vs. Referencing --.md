# Embedding vs. Referencing -- 

In Mdb, you have the option to embed related data within a single document or structure. These schmeas are typically referred to as denormalized models.

Embedded data models enable applications to store related data in the same document structure, Consequently, applications might perform fewer queries and updates to carry out routine operations.

- Entities have a *contains* REL -- such as a contacts document that include an address
- Entities have a one-to-many REL -- in which the many (child) documents are consisitently accessed or displayed within the context of the one (parent) document.

Generally, embedding enhances the performance of read operations by allowing the retrieval of related data in a single dbs operation. Embedded data model also enable the updating of related data through a single atomic wirte opeation.

Embedding large documents or multiple documents may result in bloated document with loads of information that is unlikely to be accessed together, which may end up exceeding the max Binary JSON size -- in MDB, documents must be smaller thant the max BSON document size, 16MB.

And in certain situations, it is advisable to store related info in separate documents, usually in different collections or dbs -- Generally, opt for normalized data models in the following scenairos - 

- The reference entity is frequently accessed on its own.
- Embedding could lead to data duplication withouth offering significant read-performance benefits that justify duplication. 
- Need to represent complex many-to-many relationships accurately.

And to join collections, Mdb offers the following aggregation stages -- providing sophisticated methods for integrating data across collections - 

- `$lookup`-- perform a **left outer** join to another collection in the same dbs, allowing U to combine documents based on a join condition similar to REL dbs.
- `$graphLookup`-- For complex aggregations, this stage facilitates recursive lookups, enabling the exploration of REL within data sets that have a hierarchical or grpahlike structure.

And MDB apps can relate documents using either of two methods, which cater to different data management needs.

- Manual references -- Storing the `_id`field of one document in another document as a reference. The app must execute a second query to fetch the related data. This approach is simple and effecitve for many scenairos.
- `DBRef`-- These references link one document to another using the `_id`field of the first document, the collection name, and optionally, the database name, among other fields. They are particularly useful for referecing documents spread across multiple collections or dbs. Resolving `DBRFs`requires using additional queries to retreive the linked documents, ensuring data consistency across complex structures.

```json
{
  "_id": ObjectId("56e9b39b732b6122f877fa35"),
  "flight_id": "FL123",
  "src_airport": {
    "$ref": "airports", // collection name
    "$id": "JFK",   // referenced _id
    "$db": "airportData", // optional dbs name
     "YourExtraField" : "Can be anything"
  },
  "airline": "Delta Airlines",
  "airplane": "Boeing 737",
  "stops": 0
}
```

#### Schema design patterns - 

Every schema design pattern comes with its won set of use cases and tradeoffs in terms of data consisitency, performance, and complexity, Certain schmea design pattern are geared toward enhancing write performance.

| **Row** | **Catalog** | **Content Management** | **Internet of Things** |
| ------- | ----------- | ---------------------- | ---------------------- |
| **1**   | ✓           |                        | ✓                      |
| **2**   | ✓           |                        |                        |

//... other content

##### Approximation pattern

Estimating values instead of computing them *exactly* each time can improve efficiency and reduce write-intensive operations. Tracking page views on a website. Instead of updating the view count in the dbs with every page load, whcih can ben highly write-intensive, the app can *estimate* this number using techniques such as sampling.

```json
{
  "page_id": "12345",
  "estimated_views": 1500,
  "sampling_rate": 0.05,
  "last_updated": "2024-04-20T12:00:00Z"
  // This document estimates page views to reduce database writes.
}
```

Advantages are - 

- Reduces dbs write ops
- Maintain statistically valid figures.

Disadvantages -- 

- Does not represent precise numbers
- Require applications to implement the pattern

##### Archive pattern

Is useful for managing large volumes of data -- separates active data from historical data that does not need to be accessed frequently, improving the performance and manageability of database by reducing the size of the collection. This pattern involves moving *older* data to a separate or an external storage.. Fore Amazon S3... Consider an app that logs user activities -- 

```json
{
  "log_id": "abc123",
  "user_id": "98765",
  "activity": "login",
  "timestamp": ISODate("2024-05-12T10:00:00Z"),
  "status": "active"
}
```

The `logs`collection records all activeities, but over time, old logs can be archived to keep the active collection performant.

- Remain small and performant by offloading older data
- Archived data can be stored in less expensive storage solutions, reduces overall costs
- Index sizes are reduced

Atlas *Online Archive* can be very useful for implementing the archive pattern.

##### Attribute pattern

Useful when you are handling documents that have many similar fields and subset of fields is rare, appearing in only a few document. This involves creating an array of objects, each of which contains two attributes - K/V -- enabling the construction of efficient indices for these unique fields fore:

```json
{
  "product_id": "98765",
  "name": "Laptop",
  "price": 1200,
  "in_stock": true,
    
    // rare attributes
  "special_offer": "10% off",
  "warranty_years": 3,
  "processor_generation": null,
  "custom_rgb_lighting": null,
  "touchscreen_support": null,
  "military_grade_certification": null
}
```

For this, when apply the Attribute pattern, rare attributes are stored as an array of k/v objects, mking the document structure more flexible and reducing the need for multiple indexes. This approach helps U manage attributes that appear infrequently across documents without *inflating* the schema -- like:

```json
{
  "product_id": "98765",
  "common_attributes": {
    "name": "Laptop",
    "price": 1200,
    "in_stock": true
  },
    // archive to rare_attributes
  "rare_attributes": [
    {"key": "special_offer", "value": "10% off"},
    {"key": "warranty_years", "value": 3},
    {"key": "processor_generation", "value": "13th Gen"},
    {"key": "custom_rgb_lighting", "value": true},
    {"key": "touchscreen_support", "value": false},
    {"key": "military_grade_certification", "value": "MIL-STD-810G"}
  ]
}
```

- Reduced number of required indexes
- Simplified query writing and generally faster query execution.

## Refactor testing

If re-write the function like:

```go
func SumAllTails(numbersToSum ...[]int) []int {
	var sums []int
	for _, numbers := range numbersToSum {
		tail := numbers[1:]
		sums = append(sums, Sum(tail))
	}
	return sums
}
```

Writeh the test first like:

```go
func TestSumAllTails(t *testing.T) {
	t.Run("Make the sumes of some slices", func(t *testing.T) {
		got := SumAllTails([]int{1, 2}, []int{0, 9})
		want := []int{2, 9}
		if !slices.Equal(got, want) {
			t.Errorf("got %d want %d", got, want)
		}
	})

	// this will panic
	t.Run("Safely sum empty slices", func(t *testing.T) {
		got := SumAllTails([]int{}, []int{3, 4, 5})
		want := []int{0, 9}
		if !slices.Equal(got, want) {
			t.Errorf("got %d want %d", got, want)
		}
	})
}
```

So, need to write enough code to make it pass -- just like:

```go
func SumAllTails(numbersToSum ...[]int) []int {
	var sums []int
	for _, numbers := range numbersToSum {
		if len(numbers) == 0 {
			sums = append(sums, 0)
		} else {
			tail := numbers[1:]
			sums = append(sums, Sum(tail))
		}
	}
	return sums
}
```

##### Refactor -- 

Our tests have some repeated code around the assertions again, so let’s extract those into a function just like:

```go
func TestSumAllTails(t *testing.T) {
	checkSums := func(t testing.TB, got, want []int) { // note that TB is not pointer
		t.Helper()
		if !slices.Equal(got, want) {
			t.Errorf("got %d want %d", got, want)
		}
	}
	t.Run("Make the sumes of some slices", func(t *testing.T) {
		got := SumAllTails([]int{1, 2}, []int{0, 9})
		want := []int{2, 9}
		checkSums(t, got, want)
	})

	// this will panic
	t.Run("Safely sum empty slices", func(t *testing.T) {
		got := SumAllTails([]int{}, []int{3, 4, 5})
		want := []int{0, 9}
		checkSums(t, got, want)
	})
}
```

### Structs, methods and Interfaces

Suppose need some geometry code to calculate the perimeter of a reactangle given a height and width... where `float64`is for floating-point numbers like 123.45...

##### Write the test first

```go
func TestPerimeter(t *testing.T) {
	got := Perimeter(10.0, 10.0)
	want := 40.0

	if got != want {
		t.Errorf("got %.2f want %.2f", got, want)
	}
}
```

Write enough code to make it pass -- just like -- 

```go
func Perimeter(width, height float64) float64 {
	return 2 * (width + height)
}
```

Try do it following the TDD cycle just like -- 

```go
// test
func TestArea(t *testing.T) {
	got := Area(12.0, 6.0)
	want := 72.0
	if got != want {
		t.Errorf("got %.2f want %.2f", got, want)
	}
}
// refactor
func Area(width, height float64) float64 {
	return width * height
}
```

#### Refactor

Our code does the job, but it doesn’t contain anything explicit about reactangles. An unwary develoer might try to supply widt and height of a triangle to these func without realising them will retrun the wrong answer.

Can create a simple type using a `struct`- is just a named collection of fields where you can just store data. Fore:

```go
type Rectangle struct {
	Width  float64
	Height float64
}
// then refactor the test files first -- 
func TestPerimeter(t *testing.T) {
	rectangle := Rectangle{10.0, 10.0}
	got := Perimeter(rectangle)
	want := 40.0
	if got != want {
		t.Errorf("got %.2f want %.2f", got, want)
	}
}

func TestArea(t *testing.T) {
	rectangle := Rectangle{12.0, 6.0}
	got := Area(rectangle)
	want := 72.0
	if got != want {
		t.Errorf("got %.2f want %.2f", got, want)
	}
}

// Then need to refactor the method like
func Perimeter(rectangle Rectangle) float64 {
	return 2 * (rectangle.Width + rectangle.Height)
}

func Area(rectangle Rectangle) float64 {
	return rectangle.Width * rectangle.Height
}
```

Next requirement is to write an `Area`function for circles -- first write tests -- like:

```go
func TestArea(t *testing.T) {
	t.Run("rectangles", func(t *testing.T) {
		rectangle := Rectangle{12.0, 6.0}
		got := Area(rectangle)
		want := 72.0
		if got != want {
			t.Errorf("got %.2f want %.2f", got, want)
		}
	})

	t.Run("Circle", func(t *testing.T) {
		circle := Circle{10}
		got := Area(circle)
		want := 314.1592653589793
		if got != want {
			t.Errorf("got %g want %g", got, want)
		}
	})
}
```

As can see, the `f`has been replaced by `g`, with good reason -- use of `g`will print a more precise decimal number in the error message.

Write the minimal amount of code for the test to run and check -- and using methods.

```go
type Rectangle struct {
	Width  float64
	Height float64
}

type Circle struct {
	Radius float64
}

func (r Rectangle) Area() float64 {
	return r.Width * r.Height
}

func (c Circle) Area() float64 {
	return math.Pi * c.Radius * c.Radius
}
```

Refactor -- There is also some duplication in our tests -- all we ant to do is take a collection of *shapes* -- call the `Area()`method on them and then checnk the results -- want to be able to write some kind of `checkArea`function that we can pass both `Rectangles`and `Circles`to, but fail to compile if we try to pass in sth that isn’t a shape.

Introducing this by refactoring our tests -- just like:

```go
func TestArea(t *testing.T) {
	checkArea := func(t testing.TB, shape Shape, want float64) {
		t.Helper()
		got := shape.Area()
		if got != want {
			t.Errorf("got %g want %g", got, want)
		}
	}
	t.Run("rectangles", func(t *testing.T) {
		rectangle := Rectangle{12.0, 6.0}
		checkArea(t, rectangle, 72.0)
	})

	t.Run("Circle", func(t *testing.T) {
		circle := Circle{10}
		checkArea(t, circle, 314.1592653589793)
	})
}
```

We are just creating a helper function like we have in other exercises but this time asking for a `Shape`to passed in.

```go
type Shape interface{
	Area() float64
}
```

For this,  are creating a new `type`just like we did with `Rectangle`and `Circle`but this time it is just an interface rather than a struct.

### Broadcasting to multiple goroutines

In the previous section, used the fan-out pattern when we needed to feed the output of one computation to multiple concurrent goroutines, load-balanced the messages, with each goroutine receiving a distinct subset of the output data. that pattern will not work here, since want to send a copy of each output message to both the `longestWords()`and `frequentWords()`goroutines.

Instead of fan-out, can use a *broadcast* pattern, one that replicates messages to a set of outptu channels, shows how can we use a separaete goroutine that broadcaasts to multiple concurrent goroutines -- we load-balanced the messages, with each goroutine receiving a distinct subset of the output data -- the pattern will not work here, since want to send a copy of each output messages to both the `longestWords()`and `frequentWords()`goroutine.

And to implemnet this broadcast utility, we just need to create a list of output channels and then use a goroutine that writes every received message to each channel -- the broadcast function accepts the input channel and an integer, `n`-- specifying the number of outputs that are needed -- just like:

```go
func Broadcast[K any](quit <-chan struct{}, input <-chan K, n int) []chan K {
	outputs := CreateAll[K](n)
	go func() {
		defer CloseAll(outputs...)
		var msg K
		moreData := true
		for moreData {
			select {
			case msg, moreData = <-input:
				// if hasn't been closed, writes the message to each output
				if moreData {
					for _, output := range outputs {
						output <- msg
					}
				}
			case <-quit:
				return
			}
		}
	}()
    return outputs
}

func CreateAll[K any](n int) []chan K {
	// note that this is a slice of channels
	outputs := make([]chan K, n)
	for i := range outputs {
		outputs[i] = make(chan K)
	}
	return outputs
}

func CloseAll[K any](channels ...chan K) {
	// close all channels
	for _, c := range channels {
		close(c)
	}
}
```

Can now write our `frequentWords()`func -- which will identify the top 10 most frequently occurring words -- 

```go
func frequentWords(quit <-chan struct{}, words <-chan string) <-chan string {
	frequentWords := make(chan string)
	go func() {
		defer close(frequentWords)
		wordCounts := make(map[string]int)
		freqList := make([]string, 0)
		moreData, word := true, ""
		for moreData {
			select {
			case word, moreData = <-words:
				if moreData {
					if wordCounts[word] == 0 {
						freqList = append(freqList, word)
					}
					wordCounts[word]++
				}
			case <-quit:
				return
			}
		}

		sort.Slice(freqList, func(a, b int) bool {
			return wordCounts[freqList[a]] > wordCounts[freqList[b]]
		})
		frequentWords <- strings.Join(freqList[:10], ", ")
	}()
	return frequentWords
}
```

Now can write in the `frequentWords()`unit with the broadcast utility we developed previously.

```go
func main() {
	quit := make(chan struct{})
	defer close(quit)
	urls := generateUrls(quit)
	pages := make([]<-chan string, downloaders)
	for i := 0; i < downloaders; i++ {
		pages[i] = downloadPages(quit, urls)
	}

	words := extractWords(quit, FanIn(quit, pages...))
	wordsMulti := Broadcast(quit, words, 2)
	longestResults := longestWords(quit, wordsMulti[0])
	frequentResults := frequentWords(quit, wordsMulti[1])
	fmt.Println("Longest words: ", <-longestResults)
	fmt.Println("Frequent words: ", <-frequentResults)
}
```

Since both the `longestWords()`and `frquentWords()`goroutines output only one message containing the results, our `main()`function can just consume one message from each and print it on the console.