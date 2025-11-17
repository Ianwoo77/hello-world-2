# Schema Validations

To prevent uninteded schmea changes, Can create schema validation rules -- in MDB, the schema is flexible -- allowing documents within a collection to vary in terms of fields and data types. After U set up a schmea for your application, can implment schmea validation to prevent unexpected schmea modificaionts and incorrect data types.

Schmea validation is extremely useful for established apps with well-defined data structures -- 

- User collectoin (`users`) validation -- Goal -- Ensure password must be stored as a string -- 

  ```js
  db.runCommand({
      collMod: "users",
      validator: {
          $jsonSchema: {
              // Ensure the password field exists and is of type string
              required: ["password"],
              properties: {
                  password: {
                      bsonType: "string",
                      description: "The password field must be a string, preventing storage in unexpected formats (like an image)."
                  }
              }
          }
      },
      validationLevel: "strict", // Strictly enforce validation rules
      validationAction: "error"  // Reject write operations if validation fails
  })
  ```

- For the Flight routes collection validation -- 

  - `flight_id`follows a specific format `FL`followed by numbers
  - `airline.id`is a positive integer
  - `src_airport.code`and `dst_airport.code`are valid-looking 3-level airports code

  ```js
  db.runCommand({
      collMod: "flight_routes",
      validator: {
          $jsonSchema: {
              required: ["flight_id", "airline", "src_airport", "dst_airport"],
              properties: {
                  flight_id: {
                      bsonType: "string",
                      description: "Flight ID must start with 'FL' followed by numbers.",
                      // Regex validation: ^FL\d+$ matches 'FL' followed by one or more digits, and nothing else.
                      pattern: "^FL\\d+$"
                  },
                  airline: {
                      bsonType: "object",
                      required: ["id"],
                      properties: {
                          id: {
                              bsonType: "int",
                              description: "Airline ID must be an integer greater than 0.",
                              minimum: 1 // Ensures it is a positive integer
                          }
                      }
                  },
                  src_airport: {
                      bsonType: "object",
                      required: ["code"],
                      properties: {
                          code: {
                              bsonType: "string",
                              description: "Source airport code must be a three-letter uppercase code (e.g., IATA code).",
                              // Regex validation: ^[A-Z]{3}$ matches exactly three uppercase letters.
                              pattern: "^[A-Z]{3}$"
                          }
                      }
                  },
                  dst_airport: {
                      bsonType: "object",
                      required: ["code"],
                      properties: {
                          code: {
                              bsonType: "string",
                              description: "Destination airport code must be a three-letter uppercase code (e.g., IATA code).",
                              // Regex validation: ^[A-Z]{3}$
                              pattern: "^[A-Z]{3}$"
                          }
                      }
                  }
              }
          }
      },
      validationLevel: "strict",
      validationAction: "error"
  })
  ```

- `airport`Validation -- Ensure `total_flights`field is maintianed exclusively as in integer -- 

  ```js
  db.runCommand({
      collMod: "airport",
      validator: {
          $jsonSchema: {
              // Ensure the total_flights field exists and is of type int
              required: ["total_flights"],
              properties: {
                  total_flights: {
                      bsonType: "int", // Use 'int' type for accurate representation
                      description: "The total_flights field must be an integer to accurately represent the total number of flights."
                  }
              }
          }
      },
      validationLevel: "strict",
      validationAction: "error"
  })
  ```

These commands use `db.runCommand({collMode:...})`to modify the validation rules of an existing collection. If the collections do not exist yet, can replace `collMod`with `createCOllection`.

For the `\\`-- The Regex Layer -- the second layer is just the Regular Expression engine itself. Namely:

`\\d` - > The string processor reads `\\`and passes `\d` to the regex Engine. 

#### Sepcifying JSON schema validation

The JSON schema is a std format for defining the structure, data types, and constraints of JSON documents, it ensures data consistency and validity be enfocing rules on the fields stored in a collection. Fore, can specify a collection schema validaitong using the `validator`object during the creation of a collection using the `db.createCollection()`method, as well as to an existing collection using the `collMod`command. To modify an existing `routes`collection to include schmea validation, use the `collMod`command --

```js
db.runCommand({
    collMod: 'routes',
    validator: {
        // matches documents that satisfy the specific JSON schmea
        $jsonSchema: {
            bsonType: 'object',
            
            // document must include specific fields ...
            required: ['flight_id', 'airline', 'src_airport', 'dst_airport'],
            properties: {
                flight_id: {
                    bsonType: 'string',
                    pattern: "^FL\\d+$",
                    description: 'must be a string and is required'
                },
                airLine: {
                    bsonType: 'object',
                    properties: {
                        id: {
                            bsonType: "int",
                            minimum: 1,
                            description: "must be a positive integer"
                        }
                    }
                },
                src_airport: {
                    bsonType: 'object',
                    properties: {
                        code: {
                            bsonType: "string",
                            description: "must be a valid airport code"
                        }
                    }
                },
                dst_airport: {
                    bsonType: 'object',
                    properties: {
                        code: {
                            bsonType: "string",
                            description: "must be a valid airport code"
                        }
                    }
                }
            }
        }
    },
    
    // `moderate` means this validation applies to new document and to update
    // on existing documents that alredy comply with the validation rules.
    // means, existing documents that do not match the rules, are NOT required to 
    // pass validation unless they are modified.
    // means without disrupting existing data may not compy
    validationLevel: 'moderate',
    
    // Mdb will reject any insert or update operation that does not meet the defined 
    // validation rules, if fails validation, the op is not executed.
    validationAction: 'error'
})
```

##### Testing schmea a validation rule

Attempt to add an invalid document to the `routes`collection, to which recently added shcmea validation rules

```js
db.routes.insertOne({
    flight_id: "xyz123", // error should start with FL
    airline: {
        id: -410, // should be a positive integer
        name: "Delta Airlines",
        alias: "2B",
        iata: "ARD"
    },
    src_airport: {
        code: "JFK",
        name: "JFK International Airport"
    },
    dst_airport: {
        code: "999", // dst_airport.code must be a valid code
        name: "Unknown Airport"
    },
    airplane: "CR2",
    stops: 0
})
```

## Testing interfaces and methods

```go
type Shape interface {
    Area() float64
}
```

We are just creating a new `type`just like we did with `Rectangle`and `Circle`but this time that is an interface rather than an `struct`. -- 

#### Decoupling -- 

Notice that how our helper does not need to concern itself with whether the shape is a `Rectangle`or `Circle`or a `Triangle`. By declaring an interface, the helper is *decoupled* from the concrete types and only has the method it needs to do its job. This kind of approach of using interfaces to declare only what U need is very important in software design and will be covered in more detail in later -- 

Further refactoring -- *Table driven tests* are useful when U want to build a list of test cases that can be tested in the same manner -- like:

```go
func TestArea(t *testing.T) {
	areaTests := []struct {
		shape Shape
		want  float64
	}{
		{Rectangle{12, 6}, 72.0},
		{Circle{10}, 314.1592653589793},
	}
	for _, tt := range areaTests {
		got := tt.shape.Area()
		if got != tt.want {
			t.Errorf("got %g want %g", got, tt.want)
		}
	}
}
```

The only new syntax here is creating an *anonymous struct* --- `areaTests`-- we are declaring a slice of structs by using `[]struct`with two fields, the `shape`and the `want`-- then we fill the slice with cases. We then iterate over them just like we do any other slice, using the struct fields to run our tests. Can see how it would be very easy for a developer to introduce a new shape, implement `Area`and then add it ot the test cases -- in addition, if a bug is found with `Area`it is very easy to add a new test case to exercise it before fixing it. *Table driven tests* can be a great item in your toolbox -- but be sure that U have a need for the extra noise in tests. They are just great fit when U which to test various imp of an interface, of if the data being passed in to a function has lots of different requirements that need testing.

##### Writeh the test first

Actually, just add a new `Shape`-- `Triangle`just like:

```go
// under areaTests := []{...}
{Triangle{12,6}, 36.0}
```

Then just define the struct and the method just like:

```go
type Triangle struct {
	Base   float64
	Height float64
}

func (t Triangle) Area() float64 {
	return t.Base * t.Height * 0.5
}
```

##### Refactor

Again, the imp is fine but our tests could do with some improvement -- fore `{Triangle{12,6}, 36.0}`is not immediately clear what all the numbers represent and U should be aiming for your tests to be easily understood. Can also optionally name the fields just like:

```go
func TestArea(t *testing.T) {
	areaTests := []struct { // note that []struct is a slice of structs
		name    string
		shape   Shape
		hasArea float64
	}{
		{name: "Rectangle", shape: Rectangle{Width: 12, Height: 6}, hasArea: 72.0},
		{name: "Circle", shape: Circle{Radius: 10}, hasArea: 314.1592653589793},
		{name: "Triangle", shape: Triangle{Base: 12, Height: 6}, hasArea: 36.0},
	}
	for _, tt := range areaTests {
		t.Run(tt.name, func(t *testing.T) {
			got := tt.shape.Area()
			if got != tt.hasArea {
				t.Errorf("%#v got %g want %g", tt.shape, got, tt.hasArea)
			}
		})
	}
}
```

Here, changed the error message into `%#v got %g want %g`-- the `%#v`format string will print out our structure with the values in its field. Tip with table tests is to use the `t.Run()`and name the test cases. By Wrapping each case in a standalone `t.Run`and to name the test cases.

#### Wrapping up - 

Iterating over our solutions to basic mathematic problems and learning new language features motivated by our tests. -- 

- Declaring structs to create our own data types which lets U bundle related data together and make the intent of your code clearer
- Can define functions that can be used by different types -- defining interfaces.
- Add methodoes imp interfaces
- Table driven tests make your assertions clear and your test suites easier to extend and maintain.

### Poiners & errors

At some point, U may wish to use structs to manage state, exposing methods to let users change the state in a way that you can control. Make a `Wallet`struct which lets us deposit bitcoin.

Write test first -- like:

```go
func TestWallet(t *testing.T) {
	wallet := Wallet{}
	wallet.Deposit(10)
	got := wallet.Balance()
	wang := 10
	if got != wang {
		t.Errorf("got %d want %d", got, wang)
	}
}
```

Write the minimal amount of code for the test to run and check the failing test ourput, and then write enough code to make it pass -- 

```go
type Wallet struct {
	balance int
}

func (w *Wallet) Deposit(amount int) { // have been changed to pointers
	w.balance += amount
}
func (w *Wallet) Balance() int {
	return w.balance
}
```

Then write enough test-code just like -- Current directory creating a go.work file:

```go
go 1.25.0

use (
	./pointers
)
```

And in Go, when U calls a function or a method the argument are just *copied* -- so just changed to pointer, the the test is passed.

##### Refactor

For this, seems a bit overkill to create a `strurct`for this `.int`-- create a new types from *existing* ones -- like:

```go
type Bitcoin int
type Wallet struct {
	balance Bitcoin
}

func (w *Wallet) Deposit(amount Bitcoin) {
	w.balance += amount
}
func (w *Wallet) Balance() Bitcoin {
	return w.balance
}

func TestWallet(t *testing.T) {
	wallet := Wallet{}
	wallet.Deposit(Bitcoin(10))
	got := wallet.Balance()
	wang := Bitcoin(10)
	if got != wang {
		t.Errorf("got %d want %d", got, wang)
	}
}
```

That is can be useful when U want to add some domain specific functionality on top of existing types. Then continuing to write the test.

### Categorizing Tests

The *testing pyrmid* is a model that groups tests into different categories -- occupy the base of the pyramid.

##### Base - unit tests-- 

- Most numerous -- unit tests form the foundation of the pyramid, and most tests should be unit tests
- Characteristics -- cheap to write, fast to execute, and highly deterministic
- Purpose -- test smallest, independent parts of the code

##### Ascending layers --

- More complex
- Slower to run
- More difficult to guarantee deerminism

A common technique is to explicit about which kind of tests to run, fore, depending on the project lifecycle stge, many want to run only unit tests or run all the tests in the proj. Not categorizing tests means potentially wasting time and effort and losing accuracy about the scope of a test -- 

#### Bulding tags

The most common way to classify tests is using building tags -- A build tag is a special comment at the beginning of a Go file, followed by an empty line -- like:

```go
//go:build foo

package far
```

For this, contains the `foo`tag, Note that one package may contain multiple files with different build tags. First can use a build tag as a conditional option to build an app -- fore, if want a source file to be included only if `cgo`is enbled, can add the `//go:build cgo`buld tag, and if want to categorize a test as an integration test, can add a specific build tag, such as `integration`. Fore: file `db_test.go`file

```go
//go:build integration

package db

import(
    "testing"
)

func TestInsert(t *testing.T) {...}
```

#### Custom Tags for Testing and Environments -- 

One of the most valuable uses of build tags is to categorize code for testing or specific environment configuraitons. Fore --

1. Excluding slow tests

   ```go
   //go:build integration
   
   package main
   
   func TestDatabaseConnection(t *testing.T) {
       // slow test logic...
   }
   ```

   - Default, `go test`-- this test file is *skipped* by default

   - Run integration tests -- U **MUST** explicitly enable the tag

     `go test -tags=integration ./...`

2. General Exclustion (Ingoring Files) To completely exclude a file from any std build or test process.

   ```go
   //go:build ignore
   
   package main // this file is always ignored by the Go toolchain.
   ```

3. Custom environment configuration -- Can define tags to swap out configuration files for different environments -- 

   ```go
   //go:build prod
   
   package config
   
   const DatabaseURL = "prod_db_url"
   ```

   Another file `config_dev.go`

   ```go
   //go:build dev
   
   package config
   
   const DatabaseURL = "localhost:5678"
   ```

   - Build for products -- `go build -tags=prod`
   - Build for development -- `go build -tags=dev`

