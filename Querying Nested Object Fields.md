# Querying Nested Object Fields

We saw that fields of nested objects can be accessed using `.`notation. Similarly, dot notation can be used to search objects by providing the values of its fields -- fore, to find movies that have won -- like;

```js
db.movies.find(
	{'awards.wins': 4},
    {'awards:':1, _id:0}
)
```

The preceding query uses `.`notation on the `awards`field and refers to the nested field named `wins`-- when execute the query and project only the `awards`. And the nested field search is performed idependently on the given fields, irrespective of the order of the elements -- can search by multiple fields and uses any of the conditional or logical query opeators fore:

```js
db.movies.find(
    {
        'awards.wins': {$gt:5},
        'awards.nominations': 6
    }
)
```

This query uses a combination of two conditions on two different nested fields -- upon executing the query while excluding thre rest of the fields.

#### Exercise - projecting nested Object fileds

For this, will learn how to project only certain fields from nested objects -- the following will help U implement this.

```js
// 1.
db.movies.find({},
    {
        awards: 1,
        _id: 0
    })
//2. The project only specific fields from the embedded objects, can refer a field of an embedded object using dot notation
db.movies.find(
    {},
    {
        'awards.wins':1,
        'awards.nominations':1,
        _id:0
    }
)
```

For the last query, shows that only two of the nested fields are included in the response.

### Limiting, skipping, and Sorting

Learn how to control the number and oreder of documetns returned by a query -- 

#### Limiting the Result

To limit the number of records a query returns, the resulting cursor provides a function called `limit()`-- this accepts an integer and returns the same number of records, if available -- Mdb recommends the user of this func as it reduces the numbers of records that result from the cursor and improves the speed. Fore:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {'title': 1, _id: 0}
)
```

Then  will use the limit func to restrict result size to 3 like:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {'title': 1, _id: 0}
).limit(3)
```

For this, when the limit size is larger than the actual records with the cursor, all the records will be returned. And note that set it to 0 is equivalent to not setting any limit at all. And if set it to a negative -- is just be considered to its absolute value.

#### Limit and Batch Size

When a query is executed in Mdb, the result are processed and returned in the form of one or more batches. The batches are alotted internally, and the results will be displayed all at once. It keeps the connection between the client and server active, cuz of which timeout errors are avoided. For large queries, when the dbs takes longer to find and return the result, the client just keeps on waiting, After a certain threshold value for waiting is reached, the connection between the client and server is broken and the query is failed with a timeout.

Different MDB drivers can have different batch sizes -- for a single query, the batch size can be set like:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {'title': 1, _id:0}
).batchSize(5)
```

For this, the query uses the `batchSize()`on the cursor provide a batch of 5. Just when limit is negative...

#### Skipping Documents

Skipping is used to exclude some documents in the result set and return the rest. Mdb just provides the `skip()`function, which accepts an integer and skips the specified number of documents from the cursor, returning the rest, in the previous -- prepared queries to find the titles of movies starring. Like:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {'title': 1, _id:0}
).skip(2) // first two will be excluded
```

Note that the neg value is not allowed for `skip()`.

#### Sorting Documents

Sroting is used to return documents in a specified order. Without using explicit sorting - MDB *does not guarantee the order in which the documents will be returned*, which may vary -- even if the same query is executed twice. So having a specific sort order is just important, especially during pagination.

The Mdb *cursor* provides a `sort()`func that accepts an arg of the document type, where the document defines a sort order for specific fields. Like:

```js
db.movies.find(
    {'cast': 'Charles Chaplin'},
    {'title': 1, _id:0}
).sort({title:1})
```

Just are calling the `sort()`function on the resulting cursor -- and pass -1 to the `sort`in descending order. Note that sorting can be performedon multiple fields, and each field can have a different sorting order -- like:

```js
db.movies.find()
.limit(50).sort({'imdb.rating': -1, year:1})
```

It is also worthing nothing that any number other than a positive or negative integer, including zero, is just considered invalid for sorting.

#### Finding Movies by Genre and Paginating results

Fore create a JS func on the mongo shell -- the func should accept genere of the user’s choice and print all the matching titles -- where the titles with the highest IMDB ratings should appear at the top.

## Side Effects with named result parameters

Fore, the new imp of the method like:

```go
func (l loc) getCoordinate(ctx context.Context, address string)
(lat, lng float32, err error){
    isValid := l.validateAddress(address)
    if !isValid {
        return 0, 0, errors.New("invalid address")
    }
    if ctx.Err() != nil {
        return 0, 0, err
    }
    // get and return coordinates.
}
```

If this, if `ctx.Err()`executed -- haven’t assigned any value to the `err`variable. It’s still assigned to the 0 value of an `error`type -- `nil`-- hence, this code will always return `nil`error. Furthermore, this code compiles just `cuz`err was initialized to its zero value due to named result parameters. Then just:

```go
if err := ctx.Err(); err != nil {
	return 0, 0, err // shadows the result variable
}
```

Using a naked return statement -- Another option is to use naked return statement -- 

```go
if err = ctx.Err(); err!= nil {
    return
}
```

However, doing so would break the rule stating -- shouldn’t mix naked returns and returns with arguments.

### Returning a `nil`receiver

In this section, discuss the impact of returning an interface and why doing so may lead to errors in some conditions. This mistake is propably one of the most widespread in Go cuz it may be considered counterintutive. Fore: `Customer`struct implement a `Validate()`method to perform sanity checks -- and instead of returning the first error, want to return a list of errors -- like:

```go
type MultiError struct {
    errs []string
}
func (m *MultiError) Add(err error) {
    m.errs = append(m.errs, err.Error())
}
func (m *MultiError) Error() string {
    return strings.Join(m.errs, ";")
}
```

Also, `MultiError`satisifes the `error`interface cuz it implements the `Error() string`-- it exposes an `Add`method to append an error. Using this, can implement a `Customer.Validate`in the following manner to check the age and name -- like:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age < 0 {
        m = &MultiError{}
        m.Add(errors.New("age is negative"))
    }
    if c.Name == "" {
        if m == nil {
            m= &MultiError{}
        }
        m.Add(errors.New("name is nil"))
    }
    return m
}
```

For this, `m`is initialized to the zero vlaue of  `*MultiError`-- `nil`-- when a sanity check fails, we allocate a new `MultiError`if need and then append an error. Fore:

```go
customer := Customer {Age: 33, Name: "John"}
if err := customer.Validate(); err != nil {
    log.Fatal("customer is invalid: %v", err)
} // -output: customer is invalid...
```

In go, have to know that a pointer receiver can be `nil`-- 

```go
type Foo struct{}
func (foo *Foo) Bar() string {
    return "bar"
}
func main() {
    var foo *Foo
    fmt.Println(foo.Bar())
}
```

For this `foo`is iniitalized to the zero value of a pointer `nil`, but code compiles. Using a `nil`pointer as a receiver is also valid. For the `Customer.Validate()`method -- `m`is initialized to the zero value of a pointer `nil`-- then if the checks are valid, the arg provded to the return isn’t `nil`directly, but **`nil`pointer**. And cuz a `nil`pointer is just a valid receiver, converting the result into an interface *won’t yield a `nil`value*. In other words, the caller of `Validate`will always get a non-nil error. So fix that:

```go
func (c Customer) Validate() error {
    var m *MultiError
    if c.Age <0 {
        //...
    }
    if c.Name == ""{
        //...
    }
    if m!= nil {
        return m
    }
    return nil // otherwise, just return nil directly
}
```

### Filename as a function input

When creating a new function that needs to red a file, passing a filename isn’t considered a best practice and can have some negative effects, such as making unit tests harder to write -- Fore, want to implement a function to count the number of empty lines in a file -- using the `bufio.NewScanner`like:

```go
func countEmptyLinesInFile(filename string) (int, error) {
    file, err := os.Open(filename)
    if err != nil {
        return 0, err
    }
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        //...
    }
}
```

For this, Open a file from the filename, Then use the `bufio.NewScanner`to scan every line -- this func will do what we expect it to do. Want to implement unit tests to cover the following cases -- 

- A nomical case
- an empty file
- file containing only empty lines

Each unit test will require creating a file in Go project -- the more complex the function is, the more cases we may want to add, and the more files we will create. Furthermore, this func isn’t reusable, fore, if we had to implement the same logic but count the number of empty lines with an HTTP request, would have to duplicate the main logic.

One way to overcome these limitations might be to make the function accept a `*bufio.Scanner` - but in Go, the idiomatic way to start from the reader’s abstraction. Just write a new version of the function accept a `*bufio.Scanner` -- both functions have the same logic from the moment create the `scanner`variable.

```go
func countEmptyLines(reader io.Reader) (int, error) {
    scanner := bufio.NewScanner(reader)
    for scanner.Scan() {
        //...
    }
}
```

So the benefits of this approach is this function abstracts the data source. Another benefit is related to testing.

```go
func TestCountEmptyLines(t *testing.T) {
    emptyLines, err := countEmptyLines(strings.NewReader(
    	`foo
    		bar
    		
    		baz
    	`
    ))
}
```

For this, can create an `io.Reader`using the `strings.NewReader`fromt the stdlib. So, accepting a filename as a function input to read from a file should in most cases, be consdiered a code smell.

### Adopting Channels as first-class objects

The improvement available in Go over the CSP language that was defined in the original paper is that channels are first-class objects -- This means that a channel can be stored as a variable and passed around to other functions. In Go, a channel can also be passed on another channel.

Shows how can generate prime using a concurrent pipeline -- The algorithm is -- for `c`if prime is not a mutiple of all the primes less than `c`. For the pipeline, can have a goroutine generate candidate sequential numbers starting from 2 -- the output of this goroutine will feed into a pipeline that consists of a chain of goroutines -- each filtering out the multiples of a prime number.

So in the pipeline, when a number passes through all the existing goroutines and is not discarded, that just means we have found a new prime. The last goroutine in the pipeline will then initialize a new goroutine at the tail of the pipeline and connect to it.This new goroutine will become the new tail of the pipeline, and will fiter out the multiples of the newly found prime.

Having this pipeline grow dynamically with the number of primes shows the advantage of treating channels as first-class objects, compared to the original channel in the CSP. Just like:

```go
func primeMultipleFilter(numbers <-chan int, quit chan<- struct{}) {
	var right chan int
    
    // reecives the first message containing the prime number p
	p := <-numbers
	fmt.Println(p)
	for n := range numbers { // reads next numbers from channel
		if n%p != 0 { // discard any number that a multiple of p
            
            // if current goroutine has no right, starts a new and connects to with a channel
			if right == nil {
				right = make(chan int)
				go primeMultipleFilter(right, quit)
			}
			right <- n
		}
	}
	if right == nil {
		close(quit)
	} else {
		close(right)
	}
}
// ...
func main() {
	numbers := make(chan int)
	quit := make(chan struct{})
	go primeMultipleFilter(numbers, quit)
	for i := 2; i < 100000; i++ {
		numbers <- i
	}
	close(numbers)
	<-quit
}
```

### Concurrency patterns

Once have decomposed our problem using a mixture of task and data decomposition, can apply common concurrent patterns for our implementation.

#### Loop-level parallelism 

When have a collection data that need to perform a task on-- can use concurrency to perform multiple tasks on different parts of the collection at the same imt -- a serial program might have a loop to preform the task on each item of the collection -- the loop-level parallelism pattern transforms each iteration task into a concurrent task so it can be performed in parallel. Fore have:

```go
func FHash (filepath string) []byte {
    file, _ := os.Open(filepath)
    defer file.Close()
    sha := sha256.New()
    io.Copy(sha, file) // calculates the hash code using the crypto
    return sha.Sum(nil)
}
```

Instead of processing each file in the directory one after the other sequentially, could use loop-level parallelism and feed each file to a separate goroutine -- 

```go
func main() {
    dir := os.Args[1]
    files := os.ReadDir(dir)
    wg := sync.WaitGroup{}
    for _, file := range files {
        if !file.IsDir() {
            wg.Add(1)
            go func(filename string) {
                fPath := filepath.Join(dir, filename)
                hash := FHash(fPath)
                fmt.Println(..)
                wg.Done()
            }(file.Nmae())
        }
    }
    wg.Wait()
}
```

In this, can easily use the loop-level parallelism pattern cuz there is no dependence between the tasks. The result of computing the hash code for one file does not affect the hash code computation for the next file.

## Session management

For the *session cookie* it will be sent back to the `Snippetbox`application with every request that your browser makes. The session cookie contains the session token -- also known as the session ID. It’s important to emphasize that the session token is just a random string here.

### Security improvements

Going to make some improvements to our application so that our data is kept secure during transit and our server is better able to deal with some common types of denial-of-service attacks -- 

- How to quickly and easily create a self-signed TLS ceriticaficate -- using only Go.
- The fundamentals of setting up your app so that all requests and responses are served secrurely over HTTPs
- Some sensible tweaks to the default TLS settings to help keep user info secure and over server performing quicily
- How to set connection timeouts on our server to mitigate slow-client attacks.

Generating a self signed TLS ceritifiate-- HTTP is just essential HTTP sent across a TLS conenction -- cuz it’s sent over a TLS connection the data is encrypted and signed, which helps ensure its privacy and integrity during transit. And before our server can start using HTTPs, need to generate a TLS ceritificate -- For production, can use *Let’s Encrypt* to create our TLS, but for development purposes, the simplest thing to do is to generate your own *self-signed* certificate -- is the same as a normal -- expcet it isn’t cryptographically signed by a *trusted certifcate autority* -- This means that you web browser will raise a warning the first time its’ used -- will nonetheless encrypt HTTPs traffic correctly and is fine for development and testing purposes.

in the `crytpo/tls`includes a `generate_cert.go`file just like:

```sh
go run generate_cert.go --rsa-bits=2048 --host=localhost
```

Behind the scenes, the `generate_cert.go`tool works in the two stages -- 

1. first, it gerenates a 2048-bit RSA key pair, whcih is a cryptographically secure public key and private key
2. It then stores the private key in the `key.pem`file, and generates a sefl-signed TLS ceritircate for the host `localhost`containing the public key, which it store in a `cert.pem`file. Both the private key and certiciate are the PEM encoded, which is the std format used by most TLS implementations.

#### Running a HTTPS server

Now that we have a self-signed TLS certificate and corresponding private key, starting a HTTPs web server is simple:

```go
sessionManager := scs.New()
sessionManager.Store = mysqlstore.New(db)
sessionManager.Lifetime = 12 * time.Hour

// Make sure that the secure attribute is set on our session cookies
// setting this means that the cookie will only be sent by a user's web
// browser when a HTTPs connection is being used
sessionManager.Cookie.Secure = true

// ...
// Use the ListenAndServeTLS() method to start the HTTPs server
err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")
```

#### HTTP requests

It’s important to note that our HTTPs server only support HTTPs now, if try making a regular HTTP request to it, the server will send the user a 400 bad request -- status and the message.

#### HTTP/2 connections

A Big plus of using HTTPs is that -- if a client supports HTTP/2 -- go’s HTTPs server will automatically upgrade the connection to use the http/2. This is good cuz it means that ultimately, our pages will just load faster for users,.

Certificate permissions -- it’s improtant to note that the user that you are using to run your Go app must have read permission for both the `pem`s files. By default, `generate_cert.go`file grants read permission to all users for the cert but read only to the owner of the `key.pem`.

#### Configuring HTTP settings -- 

Go has a good default settings for its HTTPs server, but it’s also possible to optimize and customize how the server behaves -- One change, which is almost always a good idea to make is to restrict the *elliptic curves* that can potentially be used during the TLS handshake.

To make this tweak, can create a `tls.Config`struct containing our non-default TLS settings, and add it to our `http.Server`struct before start the server.

```go
// Initialize a tls.Config to hold the non-default TLS 
// settings we want the server to use.
tlsConfig := &tls.Config{
    CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
}

srv := &http.Server{
    Addr:     *addr,
    ErrorLog: errorLog,
    Handler:  app.routes(),
    TLSConfig: tlsConfig,
}
```

TLS versions -- are also defined as constants in the `crypto/tls`package, and Go’s HTTPs server supports TLS version 1.0 to 1.3. Can configure the minimum and maximam TLS version via the `tls.Config.MinVersion`and `MaxVersion`fields. Go will automatically choose *which* of these cipher suites is actually used at runtime based on the ciper security, performance, and client/server hardward support.