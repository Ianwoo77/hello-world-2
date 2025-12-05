# Converting an existing index to unique

A *unique index* ensures that the indexed fields in a dbs do not store duplicate values, enforcing data uniqueness. This is beneficial cuz it guarantee data inegrity, improves search performance by allowing faster retrievial of unique entries, and optimizes uses of space by eliminating redudant data entries. To create a unique index, use the `.collection.createIndex(<key and index types specification>, {unique: true})`method with the `unique`option set to `true`.

And if collection already has a non-unique index, and U want to convert it to a unique, can use the `collMod`comamnd.

- `db`: This variable holds the reference to the currently selected database
- `getSiblingDB(name)`-- This is a method avilable on the `db`object, pass it the `name`of the dbs you want to switch to.
  - It returns a new DB object that refers to the specified dbs name.
  - It does not change your current shell context, you typically assign the returned object a new variable to work with the other dbs.

##### Comparison to `use`-- 

| Feature        | .`getSiblingDB('name')`                         | use name                                      |
| -------------- | ----------------------------------------------- | --------------------------------------------- |
| Context Change | The current `db`object is unaffected            | Changes the shell’s active `db`boject/context |
| output         | Returns a `DB`object for the target dbs         | Does not return a value.                      |
| Usage          | Ideal for scripting or running one-off commands | Return a valu                                 |

Fore- 

```js
db.getSliblingDB('sample_mflix').users.getIndexes()
// { v: 2, key: { email: 1 }, name: 'email_1' }
```

First, use the `collMod`command with the prepareUnique option -- this command looks like this -- 

```js
db.runCommand({
  collMod: 'users',
  index: {
      // specifies the specific index to modify -- targets the index that was previously created on the `email` field
    keyPattern: {email:1},
// crucial part -- setting this option to `true` initiates the preparation for turning the identifid index into unique index
    prepareUnique: true
  }
})
```

After set the `prepareUnqiue`to `true`, Mdb prevents any new insertions or updates that would result in a duplicate email value in the users collection -- if Try to insert a document with an email that already exists in the dbs, Mdb throws a duplicate-key error. 

`db.users.getIndexes()`

