# Wildcard and TTL Indexes

The index deined on a strin field or an array of string elements is called a text index -- Text indexes are not sorted, meaning that they are faster than normal indexes.

```js
db.collectionName.createIndex({fieldName: "text"});
```

And the following is an example of a text index to be created on the `users`collection on the `name`field like:

```js
db.users.createIndex({name: "text"})
```

#### Indexes on Nested Documents -- 

A document can contain nested objects to group a few attributes -- fore the `theaters`collection in the `sample-mflix`dbs contains the `location`field -- which has a nested object like:

```json
"location": {
    "address": {
        "street1": "340 W Market",
        //...
        "state":"MN"
    },
    "geo": {
        //...
    }
}
```

Using a `dot`notation, can create an inddex on any of the nested document fields just like any other field in the collection - like:

```js
db.theaters.createIndex({'location.address.zipcode': 1})
```

Can also create an index on the embedded document -- fore, u can create an index on the `location`field instead of its attribute -- as follows -- like:

```js
db.threaters.createIndex({'location': 1})
```

#### Wildcard indexes-- 

MDB supports flexible schema, and different documents can have fields of varying types and quantities -- it can be difficult to create and maintain indexes on *non-uniform* fields that are not present in all documents. Can:

```js
db.products.createIndex(
	{'specifications.$**':1}
)
```

This uses special wildcard characters `$**`to create indexes on the `specifications`field. Can also -- 

```js
db.products.createIndex(
	{"$**": 1}
)
```

Can also select or *omit* specific fields from the wildcard indexes by passing a `wildcardProjection`option:

```js
db.products.createIndex(
	{"$**":1},
    {
        "wildcardProjection": {"name": 0}
    }
)
```

This preceding query just creates a wildcard index on all the fields of a collection, excluding the `name`field -- the explicitly include the `name`, and excluding all the others can:

```js
{"wildcardProjection": {"name": 0}}
```

#### Unique indexes

A unique index property restricts duplication of the index key -- this is useful if U want to maintain the uniqueness of a field in a collection -- 

```js
db.collection.createIndex(
	{field: type},
    {unique: true},
)
db.theaters.find({theaterId: 1012})
db.theaters.insertOne({theaterId: 1012})

db.theaters.findOneAndDelete(
    {theaterId: 1012},
    {sort: {_id: -1}}
)
```

#### TTL indexes -- 

`TTL`indexes put an expiry on documents, once the documents have expired, they are just deleted. This can only be created on a field of the data type.

```js
db.reviews.createIndex(
	{reviewDate: 1},
    {expireAfterSeconds:60}
)
```

#### Sparse Indexes

When an index is created on a field, all the values of that field from all documents are maintained in the index registry. And if the field does not exist in a document, a `null`value is registered for the document. Conversely, if an index is mared as `sparse`-- then only those documents are registered in which the given field exists with some value including `null`. A sparse index will not have entires from the collection where the indexed field does not exist.

```js
db.reviews.createIndex(
    {review:1},
    {sparse: true}
)

// insert some document
db.reviews.insert(
	{"reviewer" : "Jamshed A" , "movie" : "Gladiator"}
)
// 
```

## Representing money

Fore, anything smaller than 0.01 CAD must be rounded one way or another -- want to prevent this nonsense from happening by *design* -- this means that the way we build this `Decimal`struct should prevent it from ever happening -- but cuz of safeguards that we may accidentally remove.

To present an amount of money -- it’s always prefearable to default to a fxied precision -- unless U know for ceratain that the floating point won’t cause any harm.

Implementing decimals -- There are number of different possibilities for implementing this `Decimal`struct -- Chose to split the integer and decimal parts -- Hiding the internal detals behind a custom type is generally a good idea -- could start with imprecise floats and refactor later.

### Calling the bank

More concretely, the `money`package shouldn’t know where the exchange rate is coming from -- and this is beyond its scope -- another package will be responsible for calling the bank when needed -- dealing with the bank-speicifc logic, and returning the requried info.

#### Object dependency

The first option requires the consumers to have in hand a variable of a type that implements an interface -- if know any OO, in Go, just like:

```go
type ratesFetcher interface {
    FetchRates(from, to Currency) (ExchangeRage, error)
}

func Convert(..., rates ratesFetcher) {
    rate, err := rates.FetchRates(from,to)
}
```

#### ECB package

Create a new package that will be responsbile for the call to the bank’s API -- there is no point in trying to make it generic -- the package will only know how to call this one API from the ECB. It just takes two currencies and return the rate or an error -- It shouldn’t return a `Decimal`cuz `Decimal`just represents money values and has the asscociated constraint that nothing exists below the cent.

```go
// Client can call the bank to retreive exchange rates
type Client struct{}

// FetchExchangeRate fetches the `ExchangeRate` for the day and returns it
func(c Client) FetchExchangeRate(source, target money.Currency) (money.ExchaneRate, error) {
    //...
}
```

For this, the `FetchExchangeRate`method will build the request for the API, call it, check whether it workd, and if it did, read the response and return the exchnge rate between the give currencies. The whole logic.

#### HTTP call -- easy version

The `Eurpoean`exposes an endpoint that lists daily exchange rates -- first:

```sh
curl "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
```

It returns a large XMl response -- have to parse it and find the desired value.

Can declare the constant just before the function, but can also reduce its visibility and prevent anything else inside the package from reaching the constant by declaring it inside the function like:

```go
const path = "...xml"
resp, err := http.Get(path) 
if err != nil {
    //...
}
```

#### Errors

Keeping in mind that the consumer -- shouldn’t have to deal with implementation details -- we shouldn’t directly propagate the `net/http`package’s error to our consumer -- if the consumer wants to check what type of `error`is returned, would also have to rely on the `net/http`package.

```go
// ecbankError defines an error
type ecbankError string

func (e ecbankError) Error() string {
	return string(e)
}
```

We then declare our constant and exposed errors close to where they can be returned -- this list will be enriched as we add more code -- like:

```go
const (
    ErrCallingServer = ecbankError("error calling server")
)
```

Then the `http.Get`function returns an `http.Response`-- exposed is `Body`-- implements the `io.ReadCloser`-- 

```go
const (
	clientErrorClass = 4
     serverErrorClass = 5
)

// CheckStatusCode returns a diffrent error
// depending on the returned status code
func checkStatusCode(statusCode int) error {
    switch {
    case statusCode == http.StatusOK:
        return nil
    // other case for 400 and 500.
    }
}
```

#### XML Parsing 

To parse XML, need to use the `encoding/xml`package of Go,  there is just a good list of different encodings supported by Go’s STDLIB’s packages -- including JSON, CSV, and Base64.

Decoding and Encoding XML or JSON - Both the `encoding/json`and `encoding/xml`packages offer two ways of decoding a message -- both expose an `Unmarshal`that can convert a `[]byte`into an object. They also both allow for the creation of a `Decoder`through a function callled `NewDecoder`-- this constructor takes an `io.Reader`as its parameter -- from which calls to `Decoder`will read and convert data to the desired object.

The decision of which function U should use is simple -- if have an `io.Reader`use a `Decoder`if have a `[]byte`, then use the `Unmarshal()`or `NewDecoder`is fine.

Similarly, when encoding JSON or XML, have access to an `io.Writer`use an `Encoder`, otherwise, use `Marshal`.

```go
type person struct {
    Age int `json:"age"`
    Name string `json:"name"`
}
data := []byte(`{"age":23, "name": "Yoko"}`)

p := Person{}
err := json.Unmarsal(data, &p)
if err != nil {
    panic(err)
}

// or using the `NewDecoder`
p := person{}
dec := json.NewDecoder(bytes.NewReader(data)) // use an io.Reader
err := dec.Decode(&p)
if err != nil {
    panic(err)
}
```

The `response.Body`is of type `io.Reader`-- it therefore makes complete sense to use a `Decoder`here -- can then `Decode`into the right structure -- to do this, first define a type and pass a pointer to a variable of that type to the decoder -- Declaring the variable will allow it to exist in memory, and the decoder will access it various fields to fill them with what can be found in the `Reader`. Fore:

```go
decoder := xml.NewDecoder(resp.Body)
var xrefMessage theRightStructure
err := decoder.Decode(&xrefMessage)
```

So, what exactly is this *right* structure -- it’s the structure just matches the response format and specifies how each XML field should map to a Go -- using tags Can just keep the name of the response and create structure called `envelope`-- For this, the `Cube`is not enough -- so use the `currencyRateS`. The way Go tells the `encoding/*`packages how to encode or decide each field is by defining a tag at the end of the line declaring this field’s name in the structured language.