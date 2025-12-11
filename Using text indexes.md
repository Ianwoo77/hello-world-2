# Using text indexes

In MDB, a standard text index is created on the entire value of a values, which means that searches must also target the full value to sue the index efficiently, resulting a fast query performance. However, does not support search for *partial* values, fore, conducted with regular expressions.

Conversely, a search index, in Atlas, requires more data storage but enables partial searches, commonly referred to as a *full-text* searches -- Using Atlas search is the recommended approach is much better than relying on traditional Mdb text indexes -  just like:

```js
db.<collection>.createIndex(
	{
        <filed1>: "text",
        <field2>: "text",
    }
)
```

And the `$text`operator in MDB performs text search queries on content within a collection that has a text index. This operator can search for words and phrases within string fields that are indexed with a text index.

- Case insensitivity -- by default, does not consider case
- Language-specific -- For stemming and stop words fore *and*...
- Searching on multiple fields -- can create text indexes on multiple fields, and searches using `$text`operator can include any all of these indexed fields.
- Text scoring and sorting -- Results can be scored based on relevance to the search, allowing you to sort by how well search result meaches the search criteria.

```js
{
    $text: {
        $search: <string>,
        $language: <string>,
        $caseSensitive: <boolean>,
        $diariticsSensitive: <boolean>,
    }
}
```

Suppose that an app frequently searches for speicifc movies based on titles and plots, setting up a text index on these fields enhances search capability with flexible, keyword-based queries. This type of index is useful for users who remember parts of the plot but not exact titles. Can `createIndex`like:

```js
db.movies.createIndex({
    title:"text",
    fullplot: "text",
})
```

After that the app can handles searches that include that partial and keyword-based terms -- the following query users the text to search for movies involving any title or plot containing the words *Zone* and *drinks* like:

```js
db.movies.find(
	{$text: {$search: 'Zone drinks'}},
    {score: {$meta: 'textScore'}}
).sort({score: {$meta: 'textScore'}})
.limit(3)
```

For this the role of `$meta`operator -- asking about the role of the `$meta`operator in MDB query, specifically when calculating and using the `textScore`-- `$meta`is a projection `Operator`used to access `metadata`about the query procesing or the document itself.

Besides `textScore`, `$meta`can be used for other types of metadat, though less frequently -- 

| **Metadata Name** | **Description**                                              |
| ----------------- | ------------------------------------------------------------ |
| **`"textScore"`** | The relevance score from a text search (as you used).        |
| **`"indexKey"`**  | Returns the index key used to match the query.               |
| **`"sortKey"`**   | Returns the key used to sort the documents.                  |
| **`"dataSize"`**  | Returns the approximate size of the document (only in the `aggregate` command). |

Can execute more nuanced queries, such as those that search for movies that explicitly exclude certain terms. This query searches for movies and do not include `Zone`in the title or full or plot but include the word drinks -- 

```js
db.movies.find({$text: {$search: "-Zone drinks"}})
```

#### Creaeting wildcard indexes

MDB supports creating wildcard indexes on a field or a set of fields -- wildcard indexes on a single field allow queries on any subfield of the indexed field, making them useful for querying fields with unknown or varying names between documents -- 

Wildcard indexes can be compound starting in 7.0 -- A compound wildcard index includes one wildcard term and one or more additional index terms -- allowing for more complex queries acorss multiple fields.

```js
db.collection.createIndex({"fieldName.$**": <sortOrder>})
```

A compound wildcard index includes wildcard term along one or more additional index terms -- Use wildcard indexes when fields to be indexed are unpredictable or subject to change. If your collection has unpredictable field names, consider redesigning your schmea for consistency. Use wildcast indexes in these scenarios -- 

Suppose that your application frequently queries various subfields within the `tomatoes`field in the `movies`collection of the `sample_mflix`.

```js
db.getSiblingDB('sample_mflix').movies.createIndex(
	{'tomatoes.$**':1} // create a wildcard index on all subfields of the tomatoes field
)
```

## Go test concurrency

```go
func mockWebsiteChecker(url string) bool {
	if url == "waat://furhurterwe.geds" {
		return false
	}
	return true
}

func CheckWebSites(t *testing.T) {
	websites := []string{
		"http://google.com",
		"http://blog.gypsydave5.com",
		"waat://furhurterwe.geds",
	}

	want := map[string]bool{
		"http://google.com":          true,
		"http://blog.gypsydave5.com": true,
		"waat://furhurterwe.geds":    false,
	}

	got := CheckWebsites(mockWebsiteChecker, websites)
	if !maps.Equal(want, got) {
		t.Fatalf("Wanted %v, got %v", want, got)
	}
}

// WebsiteChecker checks a url, returning a bool.
type WebsiteChecker func(string) bool

func CheckWebsites(wc WebsiteChecker, urls []string) map[string]bool {
	results := make(map[string]bool)

	for _, url := range urls {
		go func() {
			results[url] = wc(url)
		}()
	}

	time.Sleep(2 * time.Second)
	return results
}

type WebsiteChecker func(string) bool

func CheckWebsites(wc WebsiteChecker, urls []string) map[string]bool {
	results := make(map[string]bool)

	for _, url := range urls {
		go func() {
			results[url] = wc(url)
		}()
	}

	time.Sleep(2 * time.Second)
	return results
}
```

#### Chanells

Can solve this data race by coordinating our gorotuines using *channels* -- Channels are a Go data structure that can both receive and send values -- these operations.

# Creating wildcard indexes

Wildcard indexes in Mdb allow U to support queries on fields with `unknown`or `varying names`with documents.

#### Key features and usages - 

- Single-Field wildcard index -- supports queries on subfield of a speicified field

```js
db.collection.createIndex( { "fieldName.$**": <sortOrder> } )
db.getSiblingDB('sample_mflix').movies.createIndex( { "tomatoes.$**": 1 } )
```

This allows efficient querying on subfields like `tomatoes.viewer`or `tomatoes.critic`even if they vary across documents.

- Compound wild index -- Mdb 7.0+ -- includes one wildcard term `$**`and one more more additional index terms -- this enables more complex queries involving a mix of consistent and unpredictable fields.

- Indexing all Fields -- (except `_id`), can create a wildcard index to convert all fields in a document.

  ```js
  db.<collection>.createIndex({'$**': <sortOrder>})
  ```

- When to use -- 

  - Varying field names -- when field names are inconsistent among documents.
  - Inconsistent Embedded subfields -- when subfields within an embedded document are unpredictable or change over time.
  - Share characteristics -- Use a compound wildcard index to efficiently cover queries acorss multiple fields. Including a set of common, predictble fields.

NOTE -- *Targeted indexes* on specific, known fields generally offer *better* performance, wildcard indexes are best used as a flexible solution when field names are truly unpredictabl or for dynamic schema evolutions.

#### Geospatial indexes -- 

In Mdb are specified indexes used to efficiently store, retreive, an query dta based on geographic location. Note they are mandatory for specific query operations like `$near, $nearSphere`and `$geoNear`aggregation stage.

1. `2dsphere`indexes -- on the *earthlike* spherical surface.

   ```json
   // if has json document
   { "type": "Point", "coordinates": [40.7128, -74.0060] } // [Longitude, Latitude]
   ```

2. Finding points within a radius, calculting ... create index just like:

   ```js
   db.collection.createIndex({ coordinates: "2dsphere" })
   db.shipwrecks.find({
     coordinates: {
       $near: {
         $geometry: { type: "Point", coordinates: [-79.9081268, 9.3547792] },
         $maxDistance: 5000 // In meters
       }
     }
   })
   ```

##### `2d`indexes

are designed for queries that interpret geometry on a flat, two-dimensional plane.

```json
db.collection.createIndex({ coordinates: "2d" })
db.shipwrecks.find({
  coordinates: {
    $near: [-79.9081268, 9.3547792],
    $maxDistance: 0.1 // In degrees/units
  }
})
```

#### Hashed Indexes

Hashed indexes in Mdb store hash values of the indexed field’s values, their primary function is to support hashed sharding -- a strategy for distributing data evenly across a shareded cluster.

- Sharding support -- are primarily used to define a hashed shard key
- Ideal for fields that change momontically, such as `ObjectId`values or timestamps.

##### Creating hashed indexes -- 

To ccreate a shahed index in a field, you specify *hashed* as the index key’s value.

```js
db.<collection>.createIndex (
	{<field>:"hashed"}
)
```

compound hashed index -- can include a hashed term in a compound index, though only one index key can be set to

```js
db.<collection>.createIndex(
   { <field1>: "hashed", <field2>: 1 }
)
```

### Dropping indexes

To drop an index in MDB, can use the `db.collection.dropIndex(index)`helper mthod, which removes a specified index from a collection. The `index`parameters specifis the index to drop and can be provided as either the index name or the index specification document -- `object`.

#### Partial indexes

Allow U to index only a subset of the documents in a collection, specifically thos that match a defined filter expression.

- Lower storage requirements -- by indexing fewer documents, the size of index on disk is significantly reduced
- Reduced performance costs -- there are lower performance overheads associated with index creation and ongoing maintenance.

```js
db.collection.createIndex(
   { <index_key_specification> },
   { partialFilterExpression: { <filter_condition> } }
)
```

The `<filter_condition>`document can various query operators to specify which documents to include in the index. These operators include -- 

| Operator Category | Examples                     |
| ----------------- | ---------------------------- |
| Equality          | `field: value`, `$eq`        |
| Existence         | `$exists: true`              |
| Comparison        | `$gt`, `$gte`, `$lt`, `$lte` |
| Type              | `$type`                      |
| Logical           | `$and`, `$or`, `$in`         |

Fore, can see the compound index used eariler in this would like a partial index with `$eq`operator - 

```js
db.getSiblingDB('sample_mfilx').movies.createIndex(
	{
        year:1,
        type:1,
        'imdb.rating': 1,
    },
    {partialFilterExpression: {type: {$eq: 'movie'}}} // create a partial index on the movie coll
)
```

For this, creates a partial index on the `movies`collection, indexing only the documents in which the type of fields is `movie`-- by using the `$eq`operator, the filter ensures that only documents with type equal to `movie`are indexed. And cuz the index includes only documents with type equal to `movie`are indexed.

#### Sparse indexes -- 

*Sparse* indexes include entires only for documents that have the indexed field, even if the filed contains a `null`value. Documents that are missing the indexed field are completely ignored by the index.

- `Sparsity`-- the index does not cover all documents in the collection, hence the name `sparse`
- Nonsparse index contrast -- By default, nonsparse indexes includes all documents, storing a `null`value for documents that are missing the indexed fields.

```js
db.collection.createIndex(
   { <field>: <sortOrder> },
   { sparse: true }
)

// only indexe document that have runtime field
db.movies.createIndex(
    { "runtime": 1 },
    { sparse: true } // Only indexes documents that have the runtime field
)
```

It is generally recommended to use partial indexes over indexes.

|        Feature        | Sparse Indexes                                               | Partial Indexes                                              |
| :-------------------: | ------------------------------------------------------------ | ------------------------------------------------------------ |
|    Indexing Basis     | Only based on field existence                                | Based on a specified filter expression (`partialFilterExpression`) |
|  Included Documents   | Only includes documents where the indexed field exists (even if the value is `null`). | Only includes documents that satisfy the filter condition.   |
| Filtering Flexibility | Low. Can only check for field presence.                      | High. Can use complex filtering conditions with operators like `$eq`, `$gt`, `$exists: true`, `$type`, `$and`, `$or`. |
|       Use Case        | When certain fields in the collection are optional and you only query documents that possess that field. | When you need to index a subset of the collection that satisfies any complex condition (e.g., `status: "active"` AND `score > 50`). |
|     Simulability      | Partial indexes can simulate the behavior of sparse indexes. | Sparse indexes cannot simulate the complex filtering behavior of partial indexes. |
|    Recommendation     | Lower. Official documentation recommends prioritizing partial indexes. | Higher. Provides wider, more precise functional control.     |
|   Creation Example    | `db.coll.createIndex({ "fieldA": 1 }, { sparse: true })`     | `db.coll.createIndex({ "fieldA": 1 }, { partialFilterExpression: { "fieldB": { $gt: 5 } } })` |

Core difference summary -- 

1. Sparse indexes are Existence Filters -- They only index documents that contain the speciric field. If a document is missing this field, it is not indexed, regardless of the document’s other content.
2. Partial indexes are conditional Fitlers -- must satisfiy any Boolean logical condition U specify in the `partialFilterExpresion`, this condition can invove the indexed filed or other fileds in the collectin.

#### Time-to-live indexes

Are specified single-field indexes designed to provide automated data expiration -- automatically delete documents from a collection after a specified duration or at a specific time -- 

##### purpose and Use cases

Are essential for managing data that ahs a limited lifespan, helping to converse dbs storage and keep data current.

- Logs and Event Data 
- Session information -- Fore, expiring user session data after a period of inacrivity or logout
- Temporpary data -- deleting temporary files.

To creat a TTL index on `data`field fore, just like:

```js
db.getSiblingDB("sample_analytics").transactions.createIndex (
	{'data': 1},
    {expirationAfterSeconds: 31536000}
)
```

##### Setting expire after seconds to 0

Can expire documents at a specific clock time by creating a TTL index on a field that holds BSON date type values or an array of BSON date-typed objects and specifying an `expireAfterSeconds`value of 0.

```js
db.getSiblingDB('sample_analytics').runCommand(
    {
        collMod: "transactions",
        index: {
            keyPattern: { date: 1 },
            expireAfterSeconds: 0 
        }
    } 
    // Sets the TTL index on the date field to expire documents at the exact time specified in the date field.
)
```

- The mening of `expireAfterSeconds:0`-- When set to a positive number
- Mdb treats the timestamp in the document’s date field as the precise point in time when it should expire.

The basis for Expiration -- 

- Mdb compares the value in the document’s date field (fore --12-10:16:00:00) against the server’s current system time -- 
- if <= current time -- then is determined expired

Mdb will wait until the server time reaches or passes that date before marking the document as expired and deleting it. Therefore, the command is to achieve deletion immediately upon reaching the specified date.

- `.runCommnd(...)`-- tells Mdb to execute the document passed within the parenheses as a core data command
- `collMod: <collName>`
- In this case, you are modifying the collection’s `index`configuration.
  - `index`-- specifies the index to be created or modified.
  - `keyPattern`--  diefine the index key

## Select

For the test just like:

```go
func TestRacer(t *testing.T) {
	slowServer := makeDelayedServer(20 * time.Millisecond)
	fastServer := makeDelayedServer(0 * time.Millisecond)

	defer slowServer.Close()
	defer fastServer.Close()

	slowURL := slowServer.URL
	fastURL := fastServer.URL

	want := fastURL
	got := Racer(slowURL, fastURL)

	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}
func makeDelayedServer(delay time.Duration) *httptest.Server {
	return httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			time.Sleep(delay)
			w.WriteHeader(http.StatusOK)
		}),
	)
}

func Racer(a, b string) (winner string) {
	aDuration := measureResponseTime(a)
	bDuration := measureResponseTime(b)
	if aDuration < bDuration {
		return a
	}
	return b
}
func measureResponseTime(url string) time.Duration {
	start := time.Now()
	http.Get(url)
	return time.Since(start)
}
```

For this, the `http.NewServer`takes an `http.HandlerFunc()`which we are sending in via an anonymous function. `http.HandlerFunc`is a type that looks like this `type HandlerFunc func(ResponseWriter, *Request)`. Really saying just that it needs a function that takes a `ResonseWriter`and a `Request`, which is not too surprising for an HTTP Server in Go - The only difference is we are wrapping it in an `httptest.NewServer`which makes it easier to use with testing, as it finds an open port to listen to and then U can close it when you are done wtih your test.

Inside our two servers, we make the slow one have a short `time.Sleep()`when we get a request to make it slower than the other one. Both servers then write an `OK`response with `w.WriteHeader(http.StatusOK)`back to the caller. 

Sync processes - 

- Testing the speeds of the websites one after another when Go is great at concurency, should be able to check both at the same time.
- Don’t really care aobut the exact response times of the requests -- just want to know which one comes back first.

```go
func ping(url string) chan struct{} {
	ch := make(chan struct{})
	go func() {
		http.Get(url)
		close(ch)
	}()
	return ch
}
```

