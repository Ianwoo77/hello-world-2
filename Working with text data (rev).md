# Working with text data (rev)

Real-world data sets are riddled with incorrect characters, imporper letter casing, whtespaces, and more. The process of cleaning data is cassed wrangling or *munging*. Often, the majority of our data analysis is dedicated to munging. One of the primary motivations behind pandas was easing the difficulity of cleaning up improperly formatted text values.

### Letter casing and whitespace

For the CSV, includes only two columns -- one with an establishment’s name and the other with its risk rnaking -- and the four risk levels are High, Medium, and Low -- and special all for the offenders like: For the inconsistency in letter casing -- most row values are uppercase, some are just lowercase -- and some are nomal case.

`insepctions.Name.head().values`

And use the `values`attribute on the `Series`to get the underlying Numpy `ndarray`storing the values. The whitespace is present at the ends and the beginning of the values. The `Series`object’s `str`exposes a `StringMethods`object, just like: `inspections["name"].str`. And any time we’d like to perform string manipulations, we invoke a method on the `StringMethods`object rather then the `Series`itself.

Can use the `strip`family of methods to remove whitespace from a string, the `lstrip`and `rstrip`for this: Each one returns a new `Series`object with the operation applied to every column value like:

`insepctions.Name.str.lstrip().head().values`

Can just overwrite our existing `Series`with the new one that has no extra whitespacel ike:

`insepctions['Name']= insepctions.Name.str.strip()`

This one-line solution is sutable for a small data set, but it may quickly become tedious for one with a large of columns, apply the same logic to all `DataFrame`column.

Can just use the `for`loop to iterate over each column, and extract it dynamically from the `DF`.

```python
for column in insepctions.columns:
    insepctions[column]=insepctions[column].str.strip()
```

For, the `str.upper`, and `str.lower`, and `str.capitalize`methods, to do that job. That is a step in the right direction, perhaps the best method available is `str.title`-- which capitalizes each world’s first letter.

### string Slicing

turn our focus to the `Risk`column -- like: Want to extrct the numeric risk value from each row, this operation may appear -- given the seemingly consistent format of each row, have to tread -- like:

`insepctions['Risk'].unique()`

Can see, have to account for two additional values - missing values and the `All`string -- how deal with these values is ultimately up the analyst and the business.  Want to remove the missing `NaN`and replace the `All`to the `Risk 4`, pick this approach to ensure that all Rsik values have a consistent format.

Can remove missing -- pass its `subset`parameter a list of the `DataFrame`columns in which pandas would looks for. Just like: note: `insepctions=insepctions.dropna(subset=["Risk"])` Need to note that the `subset`parameter.

`insepctions.Risk.unique()`

Can also use the `DataFrame`helpful `replace`method to replace all occurrences of one value with another. The methods’ first parameter - `to_replace`, sets the value to search for, and its second parameter, `value`, just specifieds what to replace each occurrence. like:

```python
insepctions=insepctions.replace(to_replace="All", 
                                value="Risk 4 (Extreme)")
```

Now we have a consistent format for all values like:

### String Slicing and Character replacement

Can now use the `slice`method in the `StringMethods`object to extract a substring from a string by index position. The method just accepts a starting index and an ending index as arguments -- the lower bound is inclusive, whereas the upper bound is exclusive -- Our risk number starts at index position 5 in each string. The next like:

`insepctions['Risk'].str.slice(5,6).head()`
Also: `inspections['Risk'].str[5:6].head()`

And, what if want to extract the categorical ranking -- from each row-- this challenge is made difficult by the different lengths of the words -- cannot extract the same number of characters from a starting index position.

And the next example pulls the characters from index position 8 to the end string -- The character at index position 8 is the first letter in each risk type -- like: `insepctions['Risk'].str.slice(8).head()`, And still have to deal with the pskey closing parentheses -- here is a cool -- pass a negative argument to the `str.slice`method -- A neg argument sets theindex bound relative to the end of the string -1 extracts up the last -2 extacts.

`insepctions['Risk'].str.slice(8,-1).head()`
Also: `inspects['Risk'].str[8:-1].head()`

Another strategy use to remove the closing partheses is the `str.replace`method, an just **replace** each closing partheses wtih an empty -- a string without characters -- just like:

```python
insepctions['Risk'].str.slice(8).str.replace(')', '', regex=False).head()
```

### Boolean methods

Introduced method such as `upper`and `slice`that return a `Series`of strings -- other methods available on the `StringMethods`object return a `Series`of Booleans -- These methods can prove be particularly helpful for filtering a `DataFrame`. Fore, want to isolate all establishments with the word `Pizza`in their names like: And the `contains`method checks for a substring’s inclusion in each `Series`value.

`insepctions['Name'].str.lower().str.contains('pizza').head()`

We have a Boolean `Series`, which an use to extract all establishments with `Pizza in their names`fore like:

```python
has_pizza= insepctions.Name.str.lower().str.contains('pizza')
insepctions[has_pizza]
```

Notice that pandas preserves the original letter casing of the values in Name -- The `inspections DataFrame`is never mutated. The `lower`method just return a new `Series`and the `contains()`invoke on it returns another new `Series`which pandas uses to filter rows from the original `DataFrame`.

`insepctions['Name'].str.lower().str.startswith('tacos').head()`

```python
starts_with_tacos = (
    insepctions["Name"].str.lower().str.startswith('tacos')
)
insepctions[starts_with_tacos]
```

And the complementary `str.endwith()`method checks for a substring at the end of each `Series`string like:

```python
ends_with_tacos=(
    insepctions.Name.str.lower().str.endswith('tacos')
)
insepctions[ends_with_tacos]
```

### Splitting strings

Next data set is a collection of fictional customers -- Each row includes the customer’s `Name`and `Address`, import the customer.csv file with the `read_csv`function and assign the `DataFrame`to a `customers`variable like: Can use the `len()`to return the length of each row’s string, like:

`customers.Name.str.len().head()`

Just want to isolate each customer’s first and last names in two separate columns , may be for the `split()`method, which separates a string by using a specified delimiter -- the methos returns a list consisting of all the substrings after the split -- splits fore: `str.split()`method just performs the same operation on each row in a `Series`-- return value is a `Series`.

And the `str.split`method performs the same operation on each row in a `Series`-- its return value is a `Series`of lists. pass the delimiter to the method’s first parameter. `pat`named.

`customers['Name'].str.split(' ').head()`

We pass the delimiter to the method’s first parameter -- can also invoke the `str.len`method on this new `Series`of lists to get the length of each list, pandas reacts dynamically to whatever data type is storing -- like:

`customer['Names'].str.split(' ').str.len()`

Have a small issue, due to suffixes such as `MD`and `Jr`, some names have more than two words -- can see an example at index position . `n`parameter, which set the maximum number of splits -- like:

```python
customers['Name'].str.split(' ', n=1).head()
```

Now our lists have equal lengths - can use the `str.get`to pull out a value from *each* rows list based on its index position -- can target index 0, fore, to pull out the first element of each list.

`customers['Name'].str.split(*pat*=' ', *n*=1).str.get(1).head()`

And the `get`method also supports negative arguments, an argumetn of -1 extracts the last element from each row’s list, regardless of how many elements the list holds. The following code just produces the same result as the preceding code and is a bit more versatile in scenarios in which the lists have different lengths.

```python
customers['Name'].str.split(
    pat=' ', n=1, expand=True
).head()
```

Got a new `DataFrame`-- we did not provide custom names for the columns -- can:

`customers[['First Name', 'Last Name']]=customers['Name'].str.split(' ', 1, *expand*=True)`

Now that extracted the customer’s names to separate columns, can delete the original Name column, one way is to use the `drop`method on our customers `DataFrame`-- pass the column’s name to the `labels`parameter and an argument of `columns`to the `axis`parameter.

`customers=customers.drop(labels='Name', axis=1)`

