# Designing a MDB schmea

In dbs management, Mdb stands out due to its flexible schema nature -- offering a flexible, dynamic approach to data organization. Unlike traditional REL-DBS, whcih require a pre-defined schema to structure data, Mdb allows documents within a collection to have different fields and data types -- this flexible schmea not only handles evolving requirements smoothly but alo easily accommodates structured, unstructured, and semistructured data, as each document inherently carries its own schema.

Designing an effecive Mdb schema is crucial for optimizing the performance, scalability, and maintainability of appliations. Proper schmea design involves understanding the relationships beteen data entries, considering query patterns that efficiently support apps, and anticipating how data will evolve -- by carefully modeling a schmea in MDB, you can ensure efficient data retrieval and use the full potential of the dbs’ capabilities, ultimately leading to robust, scalable, and efficient applications.

Mdb is built to let U adjust your schema on the flywithout downtime, making it highly adaptable as your data needs evolve -- still advise U to design your data model before deploying at production scale, 

1. Determine the workload of your app
2. Map the rels among object in the collections
3. Implement design patterns
4. Create indexes to optimize query performance.

#### Determining the workload of the application -- 

Focusing on the most common operations it performs -- this understanding enables U to tailor your schmea to support these operations efficiently by using multiple performance optimization strategies -- such as optimizing index use, applying proven schema design patterns, avoiding common antipatterns, and refiningn queries - to reduce unnecessary database cells.

Construct a table listing the essential queries your app must execute, considering the following aspects -- 

- Action -- the user action that triggers the query
- Query type -- wheter the query is ready or write op
- Information -- document fields involved in the query
- Frequency -- how often the query is executed
- Priority -- the criticality of the query to the app’s functionality.

##### Differentiating Between REL and Document Databases

When desigining a schema for a document dbs like MDB, It’s important to understand the differences compared to traditional rel-dbs, with Mdb, Have the freedom to add and change the data structure on the fly.

- Rel-DBS -- 
  - Define the schema of the table before inserting data.
  - Data from multiple tables needs to be joined to meet the requirements of your app
  - Updating the schema if necessary can be a painful process, involving potential downtime and complex migrations.
- Document-DBS -- 
  - The schema can evolve as your app’s needs change
  - The flexible data model lets U store data in in a way that matches the way your app accesses it, reducing the need for joins, this approach improves performance and reduces the strain on your system.

Also important to emphasize that in NoSQL databases like MDB, the data model should be designed based on how the data will be displayed and accessed rather than how it is logically connected. 

##### Mapping the schema relationship -- 

Fore, in the airline route management system, U need to determine the best ways to organize and access data related to airlines, airports, and flights, begin understnding the frequent queries and operations your app manages. Also one-one, one-many, and many-to-many -- For many-to-many REL -- can model this rel by using arrays of references in each related document, allowing multiple documents to be associated with multiple other documents.

Note that in MDB, the preferred strategy for managing related data is embedding it in a subdocument -- Embedding allows your app to retreive necessary info through a single read operation, avoiding unnecessary `$lookup`operations -- in some cases, however, using a reference to linke to related data in a different collection may be more appropriate.

- Airline-to-routes relationship -- one-to-many -- each airline operates mutliple routes, establishing a clear one-to-many REL
- Airports-to-routes REL -- many-to-many Airports serve as both departure and arrival points for various routes.
- Embedding -- Airline info can be embedded in route documents when one airline operatoes many routes. For airline witin routes, cuz airline data is typically small and frequently accessed with route info, embedded this data directly in route documents can reduce read operations.
- References -- Each airport serves as the departure and arrival point for multiple routes,  Creating a many-many REL -- handling this REL using references is effecitve due to the complex interconnections between airports and multiple routes.

## Array and slices

Create new folder to work in, create a new file called `sum_test`and insert the following.

```go
func TestSum(t *testing.T) {
	numbers := [5]int{1, 2, 3, 4, 5}
	got := Sum(numbers)
	want := 15
	if got != want {
		t.Errorf("got %d want %d given, %v", got, want, numbers)
	}
}
```

Note that according to common practice, package main will only contain integration of other packages and not unit-testable code and hence Go will not allow U to import a package with name `main`.

```go
func Sum(numbers [5]int) int {
	sum := 0
	for _, number := range numbers {
		sum += number
	}
	return sum
}
```

##### Write the test first

Will now use the `slice`type whcih allows us to have collections of any size -- the syntax is very similar to arrays, U just omit the size when declaring them -- 

```go
t.Run("collection of any size", func(t *testing.T) {
    numbers := []int{1, 2, 3}
    got := Sum(numbers)
    want := 6
    if got != want {
        t.Errorf("got %d want %d given, %v", got, want, numbers)
    }
})
```

*Cannot use numbers as type [5]int in arg* to the `Sum`.

Write the minimal amount of code for the test to run and check the failing test output -- And the problem here is can eigher -- 

- Break the existing API by changing the argument to `Sum`to be a slice rather than an array, when do this, will potentially ruin someone’s day cuz..
- Create a new function -- so

```go
t.Run("Collection of 5 numbers", func(t *testing.T) {
    numbers := []int{1, 2, 3, 4, 5}
    got := Sum(numbers)
    want := 15
    if got != want {
        t.Errorf("got %d want %d given, %v", got, want, numbers)
    }
})
```

It is imortant to question the value of your tests -- should not be a goal to have as many tests as possible, but rather to have as much confidence as possible in your code base. Having too many tests can turn in to a real problem and it just adds more overhead in maintenance. **Every test has a cost**.

Can see that having two tests in this function is redundant. If it works for a slice of one size it’s very likely it will work for a slice of any size  -- Go’s built-in testing toolkit features a *coverage tool* - Whilst striving for 100% coverage should not be your end goal -- the coverage tool can help identify areas of your code not covered by tests, if you have been strict with TDD, it’s qute likely you will have close to 100% coverage anyway.

```sh
go test -cover # pass, coverage 100.0% of statements
```

Then delete one of the tests and check the coverage again -- also outputs that -- need a new function called `sumAll`which will take a varying number of slices, returning a new slice containing the totals for each passed in.

##### Write the test first

```go
func TestSumAll(t *testing.T) {
	got := SumAll([]int{1, 2}, []int{0, 9})
	want := []int{3, 9}
	if got != want {
		t.Errorf("got %d want %d", got, want)
	}
} // for this, the syntax is just an error!!!
```

Write the minimal amount of code for the test to run and check the failing test output -- 

```go
func sumAll(numbersToSum ...[]int) []int {
	lenOfNumbers := len(numbersToSum)
	sums := make([]int, lenOfNumbers)
	for i, numbers := range numbersToSum {
		sums[i] = Sum(numbers)
	}
	return sums
}
```

Also is important to note that `reflect.DeepEqual`is not type safe - the code will compile even if you did sth a bit silly.

```go
func TestSumAll(t *testing.T) {
	got := SumAll([]int{1, 2}, []int{0, 9})
	want := []int{3, 9}
	if !reflect.DeepEqual(got, want) {
		t.Errorf("got %d want %d", got, want)
	}
}
```

For now, should use `slices`package, using the generic function `slices.Equal(s1, s2)`to chack if two slices have the same length and all corresponding elements are equal using the element type’s built-in `==`operator.

```go
func TestSumAll(t *testing.T) {
	got := SumAll([]int{1, 2}, []int{0, 9})
	want := []int{3, 9}
	if !slices.Equal(got, want) {
		t.Errorf("got %d want %d", got, want)
	}
} // need go.mod using go 1.25.0
```

```go
module arrays
go 1.25.0
```

Note that there is also `slices.EqualFunc()`-- if the slice elements are complex types, or you need a custom comparison logic -- use `slices.EqualFunc()`.

##### Refactor -- 

As mentioned, slices have a capacity, if you have a slice with a capacity of 2 and try to do fore, `mySlice[10]=1`then you will get a *runtime* error.

However, can use the `append`func which takes a slice and a new value, then returns a new slice with all the items in it

```go
func SumAll(numbersToSum ...[]int) []int {
	var sums []int
	for _, numbers := range numbersToSum {
		sums = append(sums, Sum(numbers))
	}
	return sums
}
```

Our next requirement is to change `sumAll`to `sumAllTails`where it will calculate the totals of the tails of each slice the tail of a collection is all items in the collection except the first one -- just like:

```go
func TestSumAllTails(t *testing.T) {
	got := SumAllTails([]int{1, 2}, []int{0, 9})
	want := []int{2, 9}
	if !slices.Equal(got, want) {
		t.Errorf("got %d want %d", got, want)
	}
}

func SumAllTails(numbersToSum ...[]int) []int {
	var sums []int
	for _, numbers := range numbersToSum {
		tail := numbers[1:]
		sums = append(sums, Sum(tail))
	}
	return sums
}
```

Write the minimal amount of code for the test to run and check the failing test output - 

#### Refactor

What do you think would happen if you passed in an empty slice into our function -- what is the `tail`of an empty slice, what happens when you tell Go to capture all elements from myEmptySlice[1:] -- write the test -- first: