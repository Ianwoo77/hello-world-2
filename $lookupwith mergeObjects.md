# `$lookup`with `mergeObjects`

Sometimes, have to combine and streamline information from separate mbd documents into a single document for each record -- using `$lookup`followed `$mergeObjects`achieve this goal. Fore

```js
db.getCollection('transactions').aggregate(
  [
    {
      $lookup: {
        from: 'accounts',
        localField: 'account_id',
        foreignField: 'account_id',
        as: 'account_details'
      }
    },
    { $unwind: { path: '$account_details' } },
    {
      $replaceRoot: {
        newRoot: {
          $mergeObjects: [
            '$account_details',
            '$$ROOT'
          ]
        }
      }
    },
    { $unset: 'account_details' }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
```

The `$replaceRoot`aggregation pipeline operator in Mdb replaces the input document with a specified embedded document. This is particular useful when have data nested within a document and want to elevate that nested document to become new top-level document.

```js
{ $replaceRoot: { newRoot: <expression> } }
```

- `newRoot`-- an expression that resolves to the document
- Use *field path* -- `$fieldName`to promote an embedded document
- Also can be a *newly constructed document* using operators like `$mergeObjects`.

##### Aggregation pipeline

```js
// if have a document:
{
  "_id": 1,
  "item": "A",
  "details": {
    "price": 10,
    "quantity": 5
  },
  "location": "Warehouse 1"
}

// If only want the contents of the details field to be the new top-level document
db.inventory.aggregate([
  {
    $replaceRoot: { newRoot: "$details" }
  }
])

// the output document like:
// the original `_id, item`and `location` are just gone, now the root
{
  "price": 10,
  "quantity": 5
}

// combining with `$mergeObjects`
// fore, keeping the original _id
db.inventory.aggregate([
  {
    $replaceRoot: {
      newRoot: {
        $mergeObjects: [
          "$details",      // Start with the embedded 'details'
          { "_id": "$_id" } // Add the original '_id' field
        ]
      }
    }
  }
])
```

##### Resulting Document 

```js
{
  "_id": 1,
  "price": 10,
  "quantity": 5
}
```

The pipeline uses `$lookup`stage to join the `transactions`and `accounts`collections based on the `account_id`field, then it employs `$mergeObjects`in the `replaceRoot`stage to combine the joined documents into a single document. This process enhances the resulting document.