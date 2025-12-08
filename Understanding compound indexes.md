# Understanding compound indexes

Compound indexes in Mdb involve multiple fields within a document - U create these indexes by specifying several fields in the index-creation command -- Compound indexes enable execution of queries that involves all the fields in the index or the fields that prefix those in the index. like;

```js
db.<collection>.createIndex({
    <filed1>: <sortOrder>,
    <field2>: <sortOrder>,
    //...
});
```

And if app frequently runs queries involving multiple fields, setting up a comopund index on those fields can significantly enhance performance. Fore:

```js
db.movies.createIndex(
	{year:1, type:1, "imdb.rating": 1}
);
```

This command sets up the index up include these 3 key fields -- sorting each in ascending order. Compound indexes support queries on all fields in cluded in the index prefix, enabling fast, efficient retrievals. An index prefix is any subset of the indexed fields starting from the first field defined in a compound index -- Just note that cannot use this compound index to optimize queries that do not contain the -- 

```js
db.movies.find({type:'movie'});
db.movies find(
	{type: "movie", 'imdb.rating': {$gte:7.0}}
) // if do this, in the output:

  explainVersion: '1',
  queryPlanner: {
    namespace: 'sample_mflix.movies',
    indexFilterSet: false,
    //...
    winningPlan: {
      stage: 'COLLSCAN', // note, not a IDXSCAN
    },
    rejectedPlans: []
  },//...
```

The output shows that the mdb just performs a full collection scan for the `imdb.rating`query due to the lack of a suitable index.

#### Understanding the *ESR* Rule -- 

The ESR rule in Mdb is a guidline for designing compound indexes to optimize query performance. It dictates the order in *which* the query elements should be indexed. First by fields used in euqility conditions, then for sorting, and finally by fields used in euquality conditions, followed by used for sorting, finally by fields used in range conditions -- this ordering ensures that Mdb indexes efficiently by quickly narrowing down the results using equality, efficiently sorting them, and then applying the filters.

```js
db.movies.find(
	{year: 1914, 'imdb.rating': {$gte: 7}}
).sort({title: 1})
```

To enhance the efficiency of this -- should:

```js
db.movies.createIndex(
	year: 1, title: 1, 'imdb.rating': 1
)
```

#### Key Optimization strategy -- ESR rule -- 

The `ESR`is a guideline for structuring compund indexes to match the common query patterns, ensuring that the index is used efficiently by the MDB query optimizer.

##### Equality

- Index recommendation -- Matches values exactly.
- Indexing Recommendation - Place fields requiring exact matches at the beginning of the index.
- Benefit -- Exact matches are highly selective, drastically reducing the number of documents Mdb must review, which  is critical for query efficency.
- Examle queries -- 
  - `db.movies.find({year: {$eq: 1914}})`
  - `db.movies.find({year: 1917})`

##### Sort

- Indexing recommendation -- Place range filters after the equality and sort fields in the index. 
- Efficiency Tips -- 
  - Narrow the range for better performance
  - Use equality matches to reduce the overall document scan.
- Sorting Constraint -- if a range filter is applied to a field different from the sort field, MDB cannot use the index to perform an index-based sort. 
- Example Query -- `db.movies.find({year: 1914, 'imdb.rating': {$gte: 7.0}})`

The query performance summary provides detailed metrics on the query’s execution and its interaction with the dbs. It shows that two documents were returned as a result of query and two documents were examined, Indicating preciese, efficient query exuetion. The exeuction time was measured at 0 ms -- reflecting optimal performance wtih minimal processing overhead.

##### Using multikey indexes

`Multikey`indexes in MDB are B-tree indexes that enable effiicent querying of array values -- when U create an index on a field that contains an array -- MDB creates seperate index entires for each element of the array, Mdb creates spearate index entries for each element of the array -- this allows mdb quickly perform queries that involve elements of arrays -- such as checking it an array contains a specific value or if it matches certain criteria.

Suppose that the app frequently has to identify customers based on their account numbers -- which are stored the `sample_analytics`dbs within the `customers`collection. To optimize this common query, condering using a multikey index.  

##### Compound Multikey index

A *compound* multikey index is created on mutiple fields, but only one of these fields can be an array to avoid creating an overly complex index structure. If your application frequently queries `username`and `accounts`in the `customers`collection, create a compound multikey index.

##### Multikey indexes with embedded fields in an Array -- 

Can create indexes on embedded document fields within arrays - when U create an index on a field inside an array, Mdb stores that index as a multikey index. In the `sample_training`dbs, within the grades collection, U can create an index to improve the performance of queries on the `scores.score`field.

```js
db.grades.createIndex({"sores.score": 1})
db.grades.find({"scors.score": {$gt:70}})
```

This query uses the multikey index to find document efficiently. Mdb can quickly locate all documents in which any `score`field within the `scores`array is gather than 70. This elimnates the need for a full collection scan, significantly improving query performance.

```js
db.grades.sort({'scores.score': -1})
```

##### Using text indexes

In MDB, standard text index is created on the entire value of a field, which means that searches must also target the full value to use the index efficiently, resulting in fast query performance.  This type of index, however, does not support searches for partial values, such as those conducted with regular exressions. In such cases, Mdb bypases the index and performances a full collection scan, significantly slowing the search process.

- Case insensivity -- By default, the search does not consider case, making it easier to find matches regardless of text case.
- Language-specific rules -- MDB can apply lanaguage-specific rules for stemming and stop words when performing searches, improving the relevance of search results.
- Searching on multiple fileds -- can create text indexes on multiple fields, and searches using the `$text`operator can include any or all of these indexed fields.

##### Index Summary --

A MongoDB text index is specialized index that enables full-text search functionality on string fields.

- Std index Contrast -- A std index works on the full value of a field for effcient searches and cannot be used for partial value searches -- p
- Text Index Function -- It allows keyword-based searches acorss indexed string fields
- Recommendation -- the text explicitly nots that Atlas Search provides superior full-text search copabilities and is recommended approach.

