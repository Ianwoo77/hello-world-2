# Multiple table joins

Understand the use of the various joins, use them to join multiple tables so that U explore complex relationships and retrieve comprehensive data from your dbs.

```sql
SELECT b.title AS book_title
FROM Books b
INNER JOIN Borrowings br ON b.book_id = br.book_id
INNER JOIN Borrowers bw ON br.borrower_id = bw.borrower_id
WHERE bw.name = 'John Smith';
```

Can add an `Order By`statement to the query like:

```sql
SELECT bw.name AS borrower_name, b.title AS book_title
  FROM Borrowings br
  INNER JOIN Books b ON br.book_id = b.book_id
  INNER JOIN Borrowers bw ON
  br.borrower_id = bw.borrower_id
  ORDER BY bw.name, b.title;
```

#### Aggregating data

Aggregation in SQL refers to the process of summarizing or aggregating multiple rows of data into a single value.

```sql
SELECT bw."name" as borrower_name, count(br.book_id) as books_borrowed
  FROM Borrowings br
  inner JOIN Borrowers bw on br.borrower_id= bw.borrower_id
  GROUP BY bw."name"
  ORDER BY bw."name";
```

It uses the `COUNT`function to count the number of `book_id`entries in the Borrowings table and create an alias named `books_borrowed`, groups and sorts the result by the `name`column of the `Borrowers`table. Can also use the `COUNT`function to find which book is the msot borrowed -- like:

```sql
SELECT b.book_id, b.title AS book_name, COUNT(*) AS num_borrowings
FROM Borrowings br
INNER JOIN Books b ON br.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY num_borrowings DESC
LIMIT 1;
```

The `ORDER BY num_borrowings DESC`line orders the results in descending order based on the number of borrowings, so the book with the number. 

Out of curiosity, might want to known the average age of all the authors...just like:

```sql
select avg(YEAR(current_date)-birth_year) as average_age_authors
  FROM Authors;
```

Using the `AVG`, can also find the average publication year of all the books.

#### Analytics

To find out how many days the returned was overdue, can use the `DATEDIFF`function to calculate the difference between the return date and borrowing date -- 

```sql
SELECT bw."name" as borrower_name, b.title AS book_title, 
	br.borrow_date, br.return_date, DATEDIFF('day',br.borrow_date, br.return_date) - 14 AS overdue
  FROM Borrowings br
  INNER JOIN Books b ON br.book_id = b.book_id
  INNER JOIN Borrowers bw ON br.borrower_id = bw.borrower_id
  WHERE br.return_date IS NOT NULL AND DATEDIFF('day', br.borrow_date, br.return_date)>14;
```

For this SQL statement could be saved as a view so that users can reference it later if it were a table.

```sql
CREATE VIEW overdue_borrowings AS 
SELECT -- preceding content
```

The view created is presisted to the DuckDB dbs, can now quickly see how returned their books lat using this view 

```sql
select * from overdue_borrowings;
```

And, cuz we are calculating from the current date, the values in the column are quite large. Can replace the `CURRENT_DATE()`function with specific date like:

```sql
SELECT b.book_id, b.title, bw.name AS borrower_name, br.borrow_date,
DATEDIFF('day', br.borrow_date, '2022-06-10') - 14 AS overdue
-- ...
```

Find out which is the most borrowed book, want to show the title, who borrowed it, when it was loaned out, and when it was returnd -- 

```sql
SELECT b.book_id, b.title AS book_name,
    bw.name AS borrower_name,
    br.borrow_date AS loan_date, br.return_date
FROM Borrowings br
INNER JOIN Books b ON br.book_id = b.book_id
INNER JOIN Borrowers bw ON br.borrower_id = bw.borrower_id
WHERE b.book_id IN (
    SELECT book_id
    FROM Borrowings
    GROUP BY book_id
    HAVING COUNT(*) = (
        SELECT MAX(num_borrowings)
        FROM (
        SELECT COUNT(*) AS num_borrowings
        FROM Borrowings
        GROUP BY book_id
        ) AS counts
	)	
)
GROUP BY b.book_id, b.title, br.borrower_id, bw.name, br.borrow_date,
br.return_date;
```

## The fuzz target

In Go, a fuzz target is the specifc function that fuzzing engine calls repeatedly to find bugs. While standard tests us hard-coded inputs, fuzzing uses the target to explore a vast range of computer-generated data.

- Structure - pass the fuzz target into `f.Fuzz()`, the engine then takes over, executing that target function over and over with different random values.
- Signature -- target must always start with `*testing.T`, followed by the arguments U want to fuzz.

```go
func FuzzGuess(f *testing.F) {
	f.Fuzz(func(t *testing.T, n int) {
		guess.Guess(n)
	})
}
```

Call its `Fuzz`method, passing it a certain function, passing functions to functions is very Go-like. Just like:

```go
func(t *testing.T, input int)
```

Note that this isn’t the *test* function, it’s the function we *pass* to the `f.Fuzz`-- and although it must make a *testing.T* as its first argument, it can also take any number of other arguments. These extra arguments to the fuzz target represent your inputs, whch the fuzzer is oging to randomly generate.

1. Fuzz as a Regaression Tool -- When a fuzzer finds an input that causes a failure, it dosn’t just report it, it saves that input into a file within a `testdata/fuzz` directory.
2. Automatic Inclusion -- when run `go test`without `-fuzz`, Go automatically iterate through these saved files and runs them against your fuzz target.
3. The benefit - this ensures that once a bug is found nad fixed, can never accidentally reintroduced.

| **Command**          | **Mode**       | **Input Source**                                             |
| -------------------- | -------------- | ------------------------------------------------------------ |
| `go test`            | **Regression** | Uses only "seed" values and previously discovered failing inputs in `testdata`. |
| `go test -fuzz=Fuzz` | **Discovery**  | Actively generates millions of random inputs to find new bugs. |

##### The Oracle Pattern

To find bugs in function like `FristRune`, the text introduce the Oracle testing pattern -- 

1. Generate Input, the fuzzer creates a random string `s`
2. The Subject -- call your custom function `got := runes.FirstRune(s)`
3. The Oracle -- Call a trusted, known-correct function -- `want := utf8.DecodeRuneInstring(s)`

### The BGP history

- BGP-3 -- introduced the BGP identifer, used to resolve *connection collisions*
- BGP-4 -- A major milestone that added CIDR (Classless Inter-Domain Routing) route aggregation, and local Preference attribute, and per-connection hold times.

Unlike most routing protocols that use IP or UDP to facilitate neighbor discovery via broadcast, BGP operates using TCP on port 179, cuz BGP does not require broadcast discovery, using TCP allows it to offload complex transport functions.

| Characteristic         | TCP (e.g., BGP)                          | UDP/IP Direct Encapsulation (e.g., OSPF, RIP) |
| :--------------------- | :--------------------------------------- | :-------------------------------------------- |
| **Communication Mode** | Strict Point-to-Point (1:1)              | Supports Broadcast/Multicast (1:N)            |
| **Connectivity**       | Connection-oriented (Handshake required) | Connectionless (Direct transmission)          |
| **Neighbor Discovery** | Relies on manual specification           | Automatic discovery                           |
| **Reliability**        | High (Built-in error correction)         | Low (Upper-layer protocol must handle it)     |

The comparison highlights the trade-offs between BGP’s use of TCP versus other protocols’ use of UDP or IP. Cuz TCP is connection-origented and strictly point-to-point(1:1), it offers high reliability but requires neighbors to be manually configured.

And when BGP neibors establish a TCP session, they start exchanging BGP information in the form of messages -- each messages starts with a header, followed by the contents of the messages.

| **Field Name** | **Length**     | **Description**                                  |
| -------------- | -------------- | ------------------------------------------------ |
| **Marker**     | 16 bytes       | Used for synchronization and security validation |
| **Length**     | 2 bytes        | Total length of the message (including header)   |
| **Type**       | 1 byte         | Code for the message type                        |
| **Contents**   | 0 - 4077 bytes | The actual operational data                      |

1. Marker usually filled with al 1s -- Used to verify it the sender and receiver are styll synchronized. If the receiver detects an unexpected value in this field, it indicates a protocol error; the receiver will send an error notification and immediately close The TCP connection.
2. Length -- Indicates the total number of bytes in the message
   - Range -- the mimimumis 19 and maximum is 4096 byts.
3. Type -- 1 open, 2 Update, 3 Notification, 4 Keepalive

So the BGP header is designed to be very concise, totaling only 19 bytes, Most of this space is dedicated to the `Marker`fied to ensure the robustness and sync of the connection.

#### Oepn Message

The first step in establishing a BGP connection -- the Open Message -- it serves as the foundation for neighbors to negotiate rules and estabilish trust -- 

Immediately after the TCP 3-way handshake is completed, both sides send an Open message. The primary purpose of this message is to exchange configuration info and negotiate session parameters -- 

| **Field Name**          | **Length**  | **Description**                                             |
| ----------------------- | ----------- | ----------------------------------------------------------- |
| **Version**             | 1 byte      | BGP version number (normally 4)                             |
| **My AS**               | 2 bytes     | The Autonomous System number of the sender                  |
| **Hold Time**           | 2 bytes     | Max seconds the session can stay idle before timing out     |
| **Identifier**          | 4 bytes     | The BGP ID of the sender (usually an IP address)            |
| **Par Len**             | 1 byte      | Total length of the optional parameters                     |
| **Optional Parameters** | 0-255 bytes | Extensions for authentication, multi-protocol support, etc. |

##### Core Summary points -- 

1. Parameter Negotiation -- 
   - Hold time -- both sides compare the hold times sent in their respective open messages and adopt the lower value -- A value of zer means the session will never time out.
   - BGP Identifier - This is the ID card of the router, it must be unique and consistent across all BGP sessions on that specific router.
   - Optional Parameters -- These are used to enable advanced features. such as authentication, multiprotocol Exensions, and route refresh capabilities.
2. The Establishment Process -- 
   - Confirmation
   - Data Exchange
   - Ongoing Maintenance

