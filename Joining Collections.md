# Joining Collections

Sometimes, you have to combine data different collections, and the `$lookup`operator proves to be helpful in such cases. Suppose that you have a `transactions`collection that stores account info, and a `customers`colleciton, All those collections are in the same dbs. Using `$lookup`, can join these collections to include detailed account and customer info directly within each transaction document. This approach is useful for generating comprehensive financial reports tht display not only transaction details, such as amounts and dates, but also the associated account features and customer profiles.

`$lookup`operation conducts a *left join* witin the same dbs, brining in documents from a joined collection for processing. This operation enhances each input document with a new array field. populatged with matching documents from the oined collection.

The `$lookup`stage in Mdb employs this syntax to conduct an equality match between a field in the input documents and a field in the documents of the joined collection -- fore:

```js
{
   $lookup:
     {
       from: <collection to join>,
       localField: <field from the input documents>,
       foreignField: <field from the documents of the "from" collection>,
       as: <output array field>
     }
}
```

#### Creating Mdb view using `$lookup`

Can use `$lookup`to create mdb view -- create a *view* by applying a specified aggregation pipeline to the source collection or view. Views function as read-only collections and are computed in real time during read operations. Views must be established within the same dbs as the source collection -- when performing read operations on views, mdb runs them as part of these base aggregation pipeline.

In the dbs named `sample_analytics`, have collections named `transactions`and `customers`, can create a view that enriches transaction data with customer details -- defined as follows just like:

```js
db.createView(
    // view name
    "enriched_transactions", 
    
    // original collection
    'transactions',
    
    // pipeline
    [
        {
            $lookup: {
                from: 'customers',
                localField: 'account_id',
                foreignField: 'accounts',
                as: 'customer_details'
            }
        },
        {
            $set: {
                'Customer Name': {
                    $arrayElemAt: [
                        '$customer_details.name',
                        0
                    ]
                },
                'Customer Email': {
                    $arrayElemAt: [
                        '$customer_details.email',
                        0
                    ]
                },
                'Customer Address': {
                    $arrayElemAt: [
                        '$customer_details.address',
                        0
                    ]
                },
                'Customer Tier and Benefits': {
                    $arrayElemAt: [
                        '$customer_details.tier_and_details',
                        0
                    ]
                }
            }
        },
        {$unset: 'customer_details'}
    ],
    
    // ... the view options here
)
```

For this the `$lookup`stage joins the `transactions`collection within the customers collection based on matching `account_id`,  storing the result as an array in `custom_details`. cuz each transaction should have at most one matching customer, the `$set`stage extracts the relevant customer fields using `arrayElementAt`, selecting the first element from the customer_details array, then the `$unset`stage removes the temporary `customer_details`fleld to keep the view streamlined. And to read from the view you have created in Mdb, can use the `find()`method, similar to the way you would query a regular collection just like:

```js
db.enriched_transactions.find().limit(5);
```

## Write enough code to make it pass

```go
var ErrNotFound = errors.New("could not find the word you were looking for")

func (d Dictionary) Search(word string) (string, error) {
	definition, ok := d[word]
	if !ok {
		return "", ErrNotFound
	}
	return definition, nil
}
```

In order to make this pass, we are using an interesting property of the map lookup -- it can return 2 values, the second value is a boolean which indicates if the key was found successfully.

```go
func TestSearch(t *testing.T) {
	dictionary := Dictionary{"test": "this is just a test"}

	t.Run("known word", func(t *testing.T) {
		got, _ := dictionary.Search("test")
		want := "this is just a test"

		assertStrings(t, got, want)
	})

	t.Run("unknown word", func(t *testing.T) {
		_, got := dictionary.Search("unknown")

		assertError(t, got, ErrNotFound)
	})
}

func assertStrings(t testing.TB, got, want string) {
	t.Helper()

	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}

func assertError(t testing.TB, got, want error) {
	t.Helper()

	if got != want {
		t.Errorf("got error %q want %q", got, want)
	}
}
```

##### Write the test first -- 

We have a great way to search the dictionary. Howeer, we have no way to add new words to our dictionary.

```go
func TestAdd(t *testing.T) {
	dictionary := Dictionary{}
	dictionary.Add("test", "this is just a test")
	want := "this is just a test"
	got, err := dictionary.Search("test")
	if err != nil {
		t.Fatal("Should find added word: ", err)
	}
	if got != want {
		t.Errorf("got %q want %q", got, want)
	}
}
```

##### Write enough code to make it pass

```go
func (d Dictionary) Add(word, definition string) {
	d[word] = definition
}
```

##### Pointers, copies, et al

An interesting property of maps is that you can modify them without passing an address to it -- fore &myMap. This may make them feel like a reference type -- So when U pass a map to a function -- A map value is a poitner to a runtime `.hmap`structure -- so when you pass map to a function/method, you are indeed copying it, but just the pointer part, not the underlying data structure that contains the data.

A gotcha with maps is that they can be a `nil`value -- a `nil`map behaves like an empty map when reading, but attempts to write to a `nil`will cause a runtime panic -- can read more -- therefore, should never initialize an empty map variable -- `var m map[string]string`, instead, U can initialize an empty map like we were doing or using the `make`keyword to create a map just like:

```go
var dictionary = map[string]string{}
var dictionary = make(map[string]string)
```

##### Refactor

there isn’t much to refactor in our imp but the test could use a little simpliifcation -- 

```go
func TestAdd(t *testing.T) {
	dictionary := Dictionary{}
	word := "test"
	definition := "this is just a test"
	dictionary.Add(word, definition)
	assertDefinition(t, dictionary, word, definition)
}

func assertDefinition(t testing.TB, dictionary Dictionary, word, definition string) {
	t.Helper()

	got, err := dictionary.Search(word)
	if err != nil {
		t.Fatal("should find added word:", err)
	}

	if definition != got {
		t.Errorf("got %q want %q", got, definition)
	}
}
```

For this, we made variables for word and definition, and moved the definition assertion into its won helper function. Our `Add`is looking good, except, didn’t consider what happens, when the value we are trying to add already exists. Map will not throw if the value already exists, insted, they will go ahead and overwrite the value with the newly provided value. This can be convenient in practice.

##### Write the test first

```go
func TestAdd(t *testing.T) {
	t.Run("new word", func(t *testing.T){
		dictionary := Dictionary{}
		word := "test"
		definition := "this is just a test"
		err := dictionary.Add(word, definition)
		assertError(t, err, nil)
		assertDefinition(t, dictionary, word, definition)
	})
	
	t.Run("existing word", func(t *testing.T){
		word := "test"
		definition := "this is just a test"
		dictionary := Dictionary{word: definition}
		err := dictionary.Add(word, "new test")
		assertError(t, err, ErrWordExists)
		assertDefinition(t, dictionary, word, definition)
	})
}
```

Need to modfy the `Add`to return an error, which we are validating against a new error variable, `ErrWordExists`, also mofity the previous test to check for a `nil`error, as well as the `assertError`function.

##### Write enough code to make it pass

```go
var ErrWordExists = errors.New("cannot add word because it already exists")

func (d Dictionary) Add(word, definition string) error {
	_, err := d.Search(word)
	switch err {
	case ErrNotFound:
		d[word] = definition
	case nil:
		return ErrWordExists
	default:
		return err
	}
	return nil
}
```

Here, we just use a `switch`statement to match on the error, having a `switch`like this provides an extra safety net, in case `Search`returns an error other then ErrNotFound.

##### Reactor

Don’t have too muchu to refactor, but as our error usage grows can make a few modifications -- 

```go
type DictionaryErr string
func (e DictionaryErr) Error() string {
	return string(e)
}
```

For this, made the errors constant, this required us to create our own `DictionaryErr`type which implements the `error`interface, can read more about the details -- makes the errors more reusable and immutable.

##### Write the test first

```go
func TestUpdate(t *testing.T) {
	word := "test"
	definition := "this is just a test"
	dictionary := Dictionary{word: definition}
	newDefinition := "new definition"
	dictionary.Update(word, newDefinition)
	assertDefinition(t, dictionary, word, newDefinition)
}
```

`Update`is very closely related to `Add`and will be our next imp -- 

##### Write enough code to make it pass -- 

Have already seen how to do this when fixed issue with `Add`-- so implement something really similar to `Add`-- 

```go
func (d Dictionary) Update(word, definition string) {
	d[word] = definition
}
```

##### Refactor

```go
func TestUpdate(t *testing.T) {
	t.Run("existing word", func(t *testing.T) {
		word := "test"
		definition := "this is just a test"
		newDefinition := "new definition"
		dictionary := Dictionary{word: definition}
		err := dictionary.Update(word, newDefinition)
		assertError(t, err, nil)
		assertDefinition(t, dictionary, word, newDefinition)
	})

	t.Run("new word", func(t *testing.T) {
		word := "test"
		definition := "this is just a test"
		dictionary := Dictionary{}
		err := dictionary.Update(word, definition)
		assertError(t, err, ErrWordDoesNotExist)
	})
}
```

Then refactor the main program -- just like:

```go
var ErrWordDoesNotExist = DictionaryErr("cannot perform operation on word because it does not exist")

func (d Dictionary) Update(word, definition string) error {
	_, err := d.Search(word)
	switch err {
	case ErrNotFound:
		return ErrWordDoesNotExist
	case nil:
		d[word] = definition
	default:
		return err
	}
	return nil
}
```

At last, write the `Delete`a word in the dictionary -- just like -- 

```go
func TestDelete(t *testing.T) {
	word := "test"
	dictionary := Dictionary{word: "test definition"}
	dictionary.Delete(word)
	_, err := dictionary.Search(word)
	if err != ErrNotFound {
		t.Errorf("Expected %q to be deleted", word)
	}
}
```

##### Write enough code to make it pass

```go
func (d Dictionary) Delete(word string) {
	delete(d, word)
}
```

Go has a built-in function `delete`that works on maps, it takes two arguments, the first is the map and the second is the key to be removed -- the `delete`function returns nothing, and we based our Delete method on the same notion, since deleting a value that is not there has no effect, unlike our `Update`and `Add`methods, don’t need to complicate the API with errors.