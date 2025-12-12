# Time-to-Live indexes

TTL indexes are a single-field indexes in Mdb that automatically delete documents from a collection after a specified duration or at a specific time -- For managing data with a limited lifespan, such as machine-generated event data, logs, and sessoin info. Can use TTL indexes to remove flight document automatically when the flight has departed. To create, just use the `createIndex()`method.

Fore, to create a TTL index on the `date`field in the dbs and the collection -- 

```js
db.getSiblingDB('sample_analytics').transactions.createIndex(
	{'date':1},
    // Creates a TTL index on the `date` field.
    {expireAfterSeconds: 31536000}
)
```

Can expire documents as a specific clock time by creating a TTL index on a field that holds BSON date type values on an array of BSON date-typed objects and specifying `expirationAfterSeconds`value of 0.

```js
db.getSiblingDB('sample_analytics').runCommand(
    {
        collMod: "transactions",
        index: {
            keyPattern: { date: 1 },
            expireAfterSeconds: 0
        }
    } // Set the TTL index on the date field to expire documents immediately
)
```

When use the `collMod`command in the MDB to modify an existing index and set `expireAfterSeconds`to 0, then are essentialy telling MDB to *immediately and coninually* delete all documents that have a value in the indexed field. For 0s, Documents are deleted as soon as the mdb background job checkes the index.

##### Converting a Non-TTL index to a TTL index -- 

Can add the `expireAfterSeconds` option to an existing single-filed index. To change a non-TTL to a TTL, use the `collMod`dbs command like -- 

For the `collMod`-- is a powerful administrative command used to modify the configuration and options of an existing collection or view. It is executed using the `db.runCommand()`helper method and allows U to change properties that are defined at the collection level. Fore:

1. Modify TTL Indexes -- Most common use cases

   ```js
   db.getSiblingDB('sample_analytics').runCommand({
     "collMod": "transactions",
     "index": {
       "keyPattern": { "date": 1 },
       "expireAfterSeconds": 31536000 // 1 year in seconds
     }
   })
   ```

2. Managing Document validation -- used to update, or remove schema validation rules for a collection.

   - The `validator`object, contains the `$jsonSchema`rules, and `validationLevel`and `validationAction`.

     ```js
     db.runCommand({
         collMod: "users",
         validator: {
             $jsonSchema: {
                 bsonType: "object",  // actually for one row in collection
                 required: ["name"],
                 properties: {
                     name: {
                         bsonType: "string",
                         description: "must be a string and is required"
                     }
                 }
             }
         },
         validationLevel: "strict"
     })
     ```

3. Modifying views -- Can also use `collMod`to change the underlying aggretgation pipeline that defines MDB view.

   - The `pipeline`that view executes

   - Changing the view -- like:

     ```js
     db.runCommand({
         collMod: "lowStock",
         viewOn: "products",
         pipeline: [
             { $match: { quantity: { $lte: 10 } } }
         ]
     })
     ```

4. Hiding/unhiding indexes.

#### Hidden indexes

By hiding an index, can test the effects of its absence without removing it permanently -- if the results are unfavorable, can unhide he index insted of re-creating it. Hidden indexes are not visible to the query planner and are not used to support queries. Just like:

```js
db.getSiblingDB('sample_mflix').movies.hideIndex(
	{runtime: 1} // specify the index key specifcation document
)

// to unhide -- just use
db.collection.unhideIndex() // or 
db.getSiblingDB('sample_mflix').movies.unhideIndex(
    { runtime: 1 } // Specify the index key specification document
)
```

#### Understanding index builds

1. Concurrency and Locking -- 

   - Optimized construction -- Indexes builds are designed to allow read and write operations to continue throughout most of the build time.
   - Exclusive locking -- An exclusive lock is only secured on the collection at two critical points -- the beginning and the *end* of the build process.
   - Interleaving operations -- During the bulk of the construction read and write operations are pemitted to interleave with the index build process.

2. Distributed builds -- 

   Simultaneous Execution: Index builds run simultaneously on all data-bearing members (nodes) in a replica set or sharded cluster.

   Primary Node Mandate: The primary node will not mark the new index as ready for use until a minimum required number of data-bearing, voting members (including the primary itself) have successfully completed the build.

Mdb index build process summary -- 

- Locking -- the collection being indexed is exclusively locked only at the beginning and end of the build to protect metadata changes
- Access -- During a majority of the ctor phase, the build uses yielding behavior,which enhancing read-write access to the collection.

| Step                   | Primary Member Action                                        | Secondary Member Action                                      |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Initiation             | Logs a `"startIndexBuild"` oplog entry.                      | Initiates the build upon replicating the `"startIndexBuild"` oplog entry. |
| Data Indexing          |                                                              | Completes indexing of the collection's data and casts a vote to commit the build. |
| Synchronization        | Waits for a quorum of votes.                                 | While waiting for quorum confirmation, integrates any new write operations into the index. |
| Finalization (Success) | Confirms a quorum, checks for key-constraint violations (e.g., duplicate keys). If none, finalizes the build, marks the index as ready, and logs a `"commitIndexBuild"` oplog entry. | Replicates the `"commitIndexBuild"` entry and completes the index build. |
| Finalization (Failure) | If key-constraint violations occur, logs an `"abortIndexBuild"` oplog entry and halts the build. | If secondaries replicate the `"abortIndexBuild"` entry, they terminate the build and discard the task. |

## Write the test first

Going to be writing a number of tests where we pass in different values and checking the array of strings that `fn`was caled with.

```go
func TestWalk(t *testing.T) {
	cases := []struct {
		Name          string
		Input         any
		ExpectedCalls []string
	}{
		{
			"Struct with one string field",
			struct {
				Name string
			}{"Chris"},
			[]string{"Chris"},
		},
	}

	for _, test := range cases {
		t.Run(test.Name, func(t *testing.T) {
			var got []string
			walk(test.Input, func(input string) {
				got = append(got, input)
			})

			if !slices.Equal(got, test.ExpectedCalls) {
				t.Errorf("got %v, want %v", got, test.ExpectedCalls)
			}
		})
	}
}
```

Write enough code to make it pass -- 

```go
func Walk(x any, fn func(input string)) {
    // note, returns a reflect.Value struct that represents the runtime data of `x`
    // reflect.Value -- holds metaata about the underlying type and provides methods 
    // to access the data
	val := reflect.ValueOf(x) 
    
    // retreive the first field defined in the struct
    // field is just another reflect.Value represents the value of that first field
    // NOTE -- if val is not a struct, or 0 is out of bounds -- will panic
	field := val.Field(0)
	fn(field.String())
}
```

This code is very unsafe and very naive -- but goal when are in red is to write the *smallest* amount of code possible, we then write more tests.

##### Write the test first

Adding the scenairo to the cases -- like:

```go
func TestWalk(t *testing.T) {
	cases := []struct {
		Name          string
		Input         any
		ExpectedCalls []string
	}{
		{
			"Struct with one string field",
			struct {
				Name string
			}{"Chris"},
			[]string{"Chris"},
		},
		{
			"struct with two string fields",
			struct {
				Name string
				City string
			}{"Chris", "London"},
			[]string{"Chris", "London"},
		},
		{
			"struct with non string field",
			struct {
				Name string
				Age  int
			}{"Chris", 33},
			[]string{"Chris"},
		},
	}
    // ...
} // namely, added some new data.
```

Refactor the main method -- 

```go
func Walk(x any, fn func(input string)) {
	val := reflect.ValueOf(x) // get reflect.Value
	for i := 0; i < val.NumField(); i++ { // number of fields defined in the struct by val
		field := val.Field(i) // retrieve reflect.Value of the field at current index i
        
        // describes the category or fundamental kind of underlying Go type
        // fore, reflect.String, Int, Struct, Array...
		if field.Kind() == reflect.String {
			fn(field.String())
		}
	}
}
```

If adding the new case -- 

```go
type Person struct {
	Name    string
	Profile Profile
}

type Profile struct {
	Age  int
	City string
}

// And add new case just like:
{
    "nested fields",
    Person{
        "Chris",
        Profile{33, "London"},
    },
    []string{"Chris", "London"},
},  //...
```

The problem is that we are only interating on the fields on the first level of the type’s hierarchy -- Need to write enough code to make it pass again -- just like:

```go
func Walk(x any, fn func(input string)) {
	val := reflect.ValueOf(x)
	for i := 0; i < val.NumField(); i++ {
		field := val.Field(i)
		if field.Kind() == reflect.String {
			fn(field.String())
		}
		if field.Kind() == reflect.Struct {
            // Interface() -- returns an actual underlying GO values as an any type
			Walk(field.Interface(), fn)
		}
	}
}
```

Then refact that like - 

```go
func Walk(x any, fn func(input string)) {
	val := getValue(x)
	for i := 0; i < val.NumField(); i++ {
		field := val.Field(i)
		switch field.Kind() {
		case reflect.String:
			fn(field.String())
		case reflect.Struct:
			Walk(field.Interface(), fn)
		}
	}
}

func getValue(x any) reflect.Value {
	val := reflect.ValueOf(x)
	if val.Kind() == reflect.Pointer { // == reflect.Pointer
		val = val.Elem()
	}
	return val
}
```

The `val.Elem()`is used to deference a pointer represents by a `reflect.Value`.

| Condition     | Action                                                       | Result                                                       |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Input (`val`) | A `reflect.Value` whose `Kind()` is `reflect.Pointer` (i.e., it represents a pointer). | The method returns a new `reflect.Value` representing the value being pointed to. |
| Input (`val`) | A `reflect.Value` that is not a pointer (e.g., a struct, int, slice). | The method will **panic** (crash the program).               |

Refactor -- just like:

```go
func Walk(x any, fn func(input string)) {
	val := getValue(x)
	if val.Kind() == reflect.Slice {
		for i := 0; i < val.Len(); i++ {
			Walk(val.Index(i).Interface(), fn)
		}
		return
	}
	for i := 0; i < val.NumField(); i++ {
		field := val.Field(i)
		switch field.Kind() {
		case reflect.String:
			fn(field.String())
		case reflect.Struct:
			Walk(field.Interface(), fn)
		}
	}
}
```

#### Refactor -- 

This works but yucky -- No worries -- have working code backed by tests so we are free to thinker all we like.

- Each field in a struct
- Each thing in a slice

```go
func Walk(x any, fn func(input string)) {
	val := getValue(x)
	switch val.Kind() {
	case reflect.Struct:
		for i := 0; i < val.NumField(); i++ {
			Walk(val.Field(i).Interface(), fn)
		}
	case reflect.Slice:
		for i := 0; i < val.Len(); i++ {
			Walk(val.Index(i).Interface(), fn)
		}
	case reflect.String:
		fn(val.String())
	}
}
```

Still, it feels like it could be better -- there is a repetition of the operation of iterating over fields/values and then calling `Walk`but conceptually they are the same -- like:

```go
func Walk(x any, fn func(input string)) {
	val := getValue(x)
	numberOfValues := 0
	var getField func(int) reflect.Value
	switch val.Kind() {
	case reflect.Struct:
		numberOfValues = val.NumField()
		getField = val.Field
	case reflect.Slice:
		numberOfValues = val.Len()
		getField = val.Index
	case reflect.String:
		fn(val.String())
	}
	for i := 0; i < numberOfValues; i++ {
		Walk(getField(i).Interface(), fn)
	}
}
```

