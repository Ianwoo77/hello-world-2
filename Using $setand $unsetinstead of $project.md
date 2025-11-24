# Using `$set`and `$unset`instead of `$project`

The primary method for specifying which fileds to include in or exclude from Mdb’s aggregation framework has traditionally been the `$project`stage. The `$project`stage presents several significant challenges, however, including the following - 

- Nonintuitive use -- Can include or exclude fields in a single stage but not both, except for the `_id`field, can be excluded while including other fields.
- Verbosenss and inflexibility -- the `$poject`tends to verbose.

```js
db.getCollection('routes').aggregate(
  [{ $unset: ['codeshare', 'stops'] }],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

For this, the `$unset`operator removes specified fields from documents during aggregation, allowing other fileds to psass through unchanged. This operator is more intutive for retaining most fileds while excluding specific ones, like $project, which includes fields explicitly.

And if want to enhance the document by adding an `isDirect`filed to indicate whether a flight is direct and remove the `codeshare`field, which is not needed for analysis, run the following pipeline like -- 

```js
db.getCollection('routes').aggregate(
  [
    {
      $set: {
        isDirect: { $eq: ['$stops', 0] },
        codeshare: '$$REMOVE'
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

The `$set`operator adds a new `isDirect`field to each document. It also uses a conditional expresion to check whether the `stops`field is 0. If it is, `isDirect`is set to `true`, otherwise, it’s set to `false.` The 

When U set a field’s value to `$$REMOVE`in an aggregation stage like `$set`-- it instructs MDB to remove that filed from the output documents. So suing `$$REMOVE`in `$set`is equivalent to using the `$unset`stage for that specific field. like:

```js
db.getCollection('routes').aggregate(
  [
    {
      $set: {
        isDirect: { $eq: ['$stops', 0] }
      }
    },
    {
      $unset: 'codeshare' // Separate stage to remove the field
    }
  ]
  // ... options
);
```

The benefit of using `$$REMOVE`within `$set`is that you can just add or modify fields ANd remove fields, efficient stage. like to see another example of how `$$REMOVE`is used to clean up documents during an aggregation.

##### Scenario for the `$porject`operator -- 

The `$project`stage is most effective when U need the output documents to have a significantly different structure from that of the input documents, and you usually should use it last to specify what fields to return to the client. So the `$project`stage is will suited to this task cuz it reshapes the output documents to contain only the necessary fields -- `src_airport`and `dst_airport`-- this structure significantly differs from the structure of the input documents, which contain multiple additional fields. This approach allows for a focused view of the data.

##### Saving the results of aggregation pipelines

MDB offers two stages for saving aggregation pipeline results to a collection -- `$out`and `$merge`-- these stages provide different ways to store and update documents in the target collection with varying levels of flexibility and control.

The `$out`stage -- Takes the documents returned by the aggreation pipeline and writes them to a specified collection, with the option to specify the output database. The `$out`stage must be final stage in the pipeline -- this operator allows the aggregation framework to handle result sets of any size.

```js
db.routes.aggregate([
  {
    $match: { airplane: "CR2" } // Filter documents where the airplane is "CR2"
  },
  {
    $project: {
      src_airport: 1,  // Include the source airport field
      airplane: 1      // Include the airplane field
    }
  },
  {
    $out: { db: "output_db", coll: "projected_routes" } 
      // Write the results to specified collection
  }
])
```

##### The `$merge`stage

The `$merge`stage writes the results of the aggregation pipeline to a specified collection and must be the last stage in the pipeline -- this can outoput to a collection in the same dbs or a different one -- and it can output to the same collection that is being aggregated.

Note that pipelines with the `$merge`stage can run on replica set secondaries, read operations forr the `$merge`stage are sent to secondary nodes, whereas write operations occur ony on the primary node. The `$merge`stage creates a new collection if collection if the output collection does not already exist -- also, it can incorporate results into an existing collection by inserting new documents, merging documents, replacing documents, keeping existing documents, failing the operations, or porcessing documents with a custom update pipeline.

```js
db.routes.aggregate([
  {
    $match: { airplane: "CR2" }
  },
  {
    $group: {
      _id: "$_id",
      src_airport: { $first: "$src_airport" },
      dst_airport: { $first: "$dst_airport" },
      airline_name: { $first: "$airline.name" }
    }
  },
  {
    $merge: {
      into: "routes",
      on: "_id",
      whenMatched: "merge",
      whenNotMatched: "insert"
    }
  }
])
```

This aggregation pipeline demonstrates how to selectively update documents in the `routes`collection in which the `airpline`field `CR2`-- the pipeline consists of three stages - 

1. `$match`stage filters the documents to include only those in which the `airplane`is `CR2`.
2. `$group`stage processes the filtered documents by grouping them based on `_id`.
3. The `$merge`stage writes the results back to the same route collection. Existing documents that match on `_id`are updated with the new fields, a new documents are inserted if no match found.

## Write the test first

The basic search was very easy to implement,  what will happen if we supply a word that is not in our dictionary -- 

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
```

#### Write enough code to make it pass -- 

```go
type Dictionary map[string]string

// ErrNotFound is returned when a word cannot be found in the dictionary.
var ErrNotFound = errors.New("could not find the word you were looking for")

func (d Dictionary) Search(word string) (string, error) {
	definition, ok := d[word]
	if !ok {
		return "", ErrNotFound
	}
	return definition, nil
}
```

This property allows us to differentiate between a word that doesn’t exist and a word that just does not have a definition.

