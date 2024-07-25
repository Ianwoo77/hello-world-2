# Selecting rows from a DataFrame

The `loc`attribute extracts a row by label, call attributes such as `loc`accessors cuz they access a piece of data. Type a pair of square brackets immediately after `loc`like;

```python
nba.loc['LeBron James']
```

Can also pass a list in between the `[]`to extract multiple rows, when the result set includes multiple records, pandas stores the results in a `DataFrame`. like: `nba.loc[['Kawhi Leonard', 'Paul George']]`, can also use `loc`to extract a sequence of index labels.

```python
nba.sort_index().loc['Otto Porter': 'Patrick Beverley']
```

Note that the Panda’s `loc`accessor has some differences with python’s list-slicing syntax -- For one, the `loc`accessor includes the label at the upper bound, whereas Python’s list slicing syntax excludes the value at the upper bound.

Can also use `loc`to pull rows from the middleware of the DataFrame to its end. like:
`nba.sort_index().loc['Zach Collins':]`
`nba.sort_index().loc[:'Al Horford']`

Note that pandas will raise if the index does not exist.

### Extracting rows by index position

The`iloc`accessor extracts rows by index position, which is helpful when the position of our rows has signifiance.
`nba.iloc[300]`

Also, accepts a list of index positions to target multiple records. like:
`nba.iloc[[100,200,300,400]]`

Can also use list-slicing syntax with the `iloc`accessor as well, note that the pandas excludes the index position after the `colon`.

#### Extracting values from specific columns

Both the `loc`and `iloc`attributes accept a second argument representing the columns to extract. If using `loc`, have to provide the column name, and `iloc`for positions. Like:

`nba.loc["Giannis Antetokounmpo", 'Team']`, and to specify multiple values, can pass a list for one or both of the arguments to the `loc`accessor. fore:
`nba.loc['James Harden', ['Position', 'Birthday']]` And the next example provides multiple row labels and multiple columns like:
`nba.loc[["Russell Westbrook", "Anthony Davis"], ['Team', 'Salary']]`

can also use list-slicing syntax to extract multiple column without explicitly writing out their names.
`nba.loc['Joel Embiid', 'Position': 'Salary']`

Note that must pass the column in the order in which *they appear in the DataFrame*.
`nba.iloc[57, 3]`

Can also use list-slicing syntax -- the next example pulls all rows from index position 100 up to but *not including* index position 104 like: `nba.iloc[100:104, :3]`, the `iloc`and `loc`accessors are remarkably versatile. Their `[]`can accept a single value, a list of values...

Can use two alternative attributes -- `at`and `iat`-- when know that want to extract a single value from a DF, The two attributes are *speedier*. just like: 

```python
nba.at['Austin Rivers', 'Birthday']
nba.iat[263, 1]
```

#### Extracting values from Series

The `loc, iloc`and `at iat`accessors are also available on `Series`object as well, can practice on a sample `Series`from our DataFrame like: `nba['Salary'].loc['Damian Lillard']`

#### Renaming columns or rows

Can rename any or all of a DataFrame’s columns by assigning a list of new names to the attribute, like:
`nba.columns=['Team', 'Position', 'Date of Birth', 'pay']` or :
`nab.rename(columns= {'Date of Birth': 'Birthday'})`

Note that the `rename()`method also returns a new DF, so:
`nba = nba.rename(columns= {...})`

#### Resetting an index

Sometimes, want to set another column as the index of our DF-- like:
`nba.set_index('Team').head()`-- lose our current index. so:
`nba.reset_index().set_index('Team')`

## Builder Pattern

```go
type Config struct {
    Port int
}
type ConfigBuilder struct {
    port *int
}
func (b *ConfigBuilder) Port (port int) *ConfigBuilder {
    b.port=&port
    return b
}
func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    if b.port==nil {
        // using default
    }else {
        if *b.port==nil {
            //...
        }else {
            //...
        }
    }
    return cfg, nil
}
```

### Functional Options pattern

The last approach will discuss is using functional pattern -- 

```go
type options struct {
    port *int
}
type Option func(options *options) error
func WithPort(port int) Option{
    return func(options *options) error {
        if port < 0 {
            return errors.New(...)
        }
        options.port=&port
        return nil
    }
}

func NewServer(addr string, opts ...Option) (*http.Server, error) {
    var options options
    for _, opt := range opts {
        err := opt(&options)
        if err != nil {
            return nil, err
        }
    }
    var port int
    if options.port == nil {...}
}

//.. use it
server, err := httplib.NewServer("localhost", httplib.WithPort(8080),
                                 httplib.WithTimeout(time.Second))
```

### Project Misorganization

Cuz the Golang provides a lot of freedom in designing packages and modules, the best practices are not quite as ubiquitous as they should be.

#### Project structure

The go language maintiner has no strong convention about structuring a project in Go, However, one layout has emerged over the years -- project-layout -- if proj is small enough, or if organization has already created its std.

- `/cmd`-- main source files, fore, the `main.go`of a `foo`app should be lived in `/cmd/foo/main.go`.
- `/internal`-- private code
- `/pkg`-- public code want to expose to others
- `/test`-- Additional external tests and test data. Unit tests in Go live in the same pacakges at the source files.
- `/configs`-- Configuration files
- `/docs`-- Design and user documents

And so on, note that there is no `/src`diectory.

### Don’t Create a utility package

Creating shared packages such as `utils common base`-- Fore, Implementing a set data structure -- the *idiomatic* way to do this in go is to handle it via a `map[K]struct{}`type with `K`that can be any type allowed in a map as a key.

```go
package util
func NewStringSet(...string) map[string]struct{} {}
func SortStringSet(map[string]struct{}) [] string {}
// use case
set := util.NewStringSet("a", "b", "c")...
```

Problem here is that `util`is *meaningless*. Could call it other names. So instead of a `utilty`name, should create an expresive name such as `stringset`, fore:

```go
package stringset
..
// instead of exposing utility functions create a specific type expose Sort as a method like:
type Set map[string]struct{}
func New(...string) Set {...}
func (s Set) Sort() []string {...}
```

This change just makes the client even simpler -- there would only be one reference to the `stringset`package.

### Package name Collisions

Package collisions occur when a variable name collides with an existing package name, preventing the package from being re-used. Fore:

```go
package redis
type Client struct {...}
func NewClient() *Client {...}
func (c *Client) Get(key string) (string, error) {...}
```

It’s just perfectly valid in Go to also create a variable named `redis`-- 

```go
redis := redis.NewClient()
v, err := redis.Get("foo")
```

Here, the `redis`variable name collides with the `redis`package name. Even though this is just allowed-- but should be avoided. For this, throughout the scope of the `redis`variable, the `redis`package won’t be accessible. Suppose that a qualifier references both a variable and a package name throughout a function. In that case, it might be ambiguous for a code reader to know what a qualifier refers to. What are the options to avoid such a collision -- first optoin is to use adifferent variable name like:

```go
redisClient := redis.NewClient()
v, err := redisClient.Get("foo")
```

This the most straightfoward approach. However, for some reason, we prefer to keep our variable named `redis`just, can play with package `import`s. just like:

```go
import redisapi "mylib/redis"
//...
redis := redisapi.NewClient()
v, err := redis.Get("foo")
```

Also note that we should avoid naming collisions between a variable and a built-in function, fore, could do this:
`copy := copyFile(src, dst)`

### Code documentation

Documentation is an important aspect of coding. In Go, should follow some rules to make our code idiomatic.

First, every exported element *must* be documented -- whether it is a structure, an interface, a function, or sth else. The convention is to add comments, starting with the name of the exported element fore:

```go
// Customer is a customer representation
type Customer struct {}
// ID returns the customer identifier.
func(c Customer) ID() string {...}
```

Note that as a convention, each comment should be a complete sentence that ends with punctuation. Also bear in mind that when document a function should highlight what the function intends to do.

*deprecated elements* -- It’s possible to deprecate an exported element using `// Deprecated: comment`:

```go
// Deprecated: This func uses a deprecated way to compute
// ComputePath returns the ...
func ComputePath {...}
```

And, when it comes to documenting a variable or a constant, might be interested in conveying two aspects, its purpose and its content.

```go
// DefaultPermission is the default permision used by the storage engine.
const DefaultPermission = 0o644 // Need read and write accesses
```

And, to help clients and maintainers understand a package’s scope, should also document each package. The convention is to start the comment wtih `// Package`followed by the package name:

```go
// Package math provide basic constants ...
//
// This package does not guarantee bit-identical results
// across architectures
package math
```

## Working with Files

The key package when dealing with files is the `os`package, this provides access to OS features, including the file system -- in a way that hides most of the IMP details, meaning that the same functions can be used to achieve the same results regardless of the OS being used. The neutral approach adopted by the `os`package leads to some compromises and .. like:

- `ReadFile(name)`-- This func opens the specified and read its contents. Results are a `byte`slice containing the file content and an `error`
- `Open(name)`-- opens for reading, result is a `File`struct and `error`

### Using the `Read`convenience Function

The `ReadFile`provides a convenient way to read the complete contents of a file into a byte slice in single step.

```go
func LoadConfig() (err error) {
	data, err := os.ReadFile("config.json")
	if err == nil {
		Printfln(string(data))
	}
	return
}

func init() {
	err := LoadConfig()
	if err != nil {
		Printfln("Error Loading Config: %v", err.Error())
	}
}

```

So the `LoadConfig`function uses the `ReadFile`function to read the contents of the `config.json`.

#### Decoding the JSON data

For the example configuration file, receiving the content of a file a string is not ideal, and a more useufl approach would be to parse the contents as JSON like:

```go
type ConfigData struct {
	UserName           string
	AdditionalProducts []Product
}

var Config ConfigData

func LoadConfig() (err error) {
	data, err := os.ReadFile("config.json")
	if err == nil {
		decoder := json.NewDecoder(strings.NewReader(string(data)))
		err = decoder.Decode(&Config)
	}
	return
}

func init() {
	err := LoadConfig()
	if err != nil {
		Printfln("Error Loading Config: %v", err.Error())
	} else {
		Printfln("Username: %v", Config.UserName)
		Products = append(Products, Config.AdditionalProducts...)
	}
}
```

#### Using the File struct to read a File

The `Open`function opens a file for reading and returns a `File`value -- which just represents the open file, and an error, which is used to indicate problems opening the file. The `File`struct implements the `Reader`interface, which makes it simple to read and process the example JSON data, without reading into byte slice, And the `os`package defines 3 `*File`variables, named `Stdin Stdout Stderr`-- that provide access to the std input.

```go
func LoadConfig() (err error) {
	file, err := os.Open("config.json")
	if err == nil {
		defer file.Close()
		decoder := json.NewDecoder(file)
		err = decoder.Decode(&Config)
	}
	return
}
```

Note that the `File`struct implements the `Closer`interface also. so: `defer file.Close()`.

Reading from a specific Location -- 

- `ReadAt(slice, offset)`
- `Seek(offset, how)`- 0 relative start, 1 current read, 2 offset to end of file.

### Writing To Files

The `os`also include functions for writing, these functions are more complex to use than their read-related counterparts cuz more configuration options are required.

- `WriteFile(name, slice, modePerms)`
- `OpenFile(name, flag, modePerms)`-- result is a `File`provides access to the file content and error

#### Using the Write convenience Function -- 

The `WriteFile`provides a convenient way to write an entire file in a single step and will create the file if it does not exist -- like:

```go
func main() {
	total := 0.0
	for _, p := range Products {
		total += p.Price
	}

	dataStr := fmt.Sprintf("Time: %v, Total: $%.2f\n",
		time.Now().Format("Mon 15:04:05"), total)
	err := os.WriteFile("output.txt", []byte(dataStr), 0666)
	if err == nil {
		fmt.Println("Output file created")
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

#### Using the `File`struct to Write to a File

The `OpenFile`function opens a file and returns a `File`value, Unlike the `Open`-- the `OpenFile`accepts one or more *flags* that specify how the file should be opened. The flags are defined constants in the `os`package. 

`O_RDONLY O_WRONLY O_RDWR O_APPEND O_CREATE O_EXCL`

```go
file, err := os.OpenFile("output.txt",
                         os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0666)
if err == nil {
    defer file.Close()

    // writes a string to the file
    _, _ = file.WriteString(dataStr)
} else {
    Printfln("Error: %v", err.Error())
}
```

#### Writing JSON data to a File

The `File`struct also implements the `Writer`interface, which allows a file to be used with the functions for formatting and procesing strings -- like:

```go
func main() {
	cheapProducts := []Product{}
	for _, p := range Products {
		if p.Price < 100 {
			cheapProducts = append(cheapProducts, p)
		}
	}

	file, err := os.OpenFile("cheap.json", os.O_WRONLY|os.O_CREATE, 0666)
	if err == nil {
		defer file.Close()
		encoder := json.NewEncoder(file)
		_ = encoder.Encode(cheapProducts)
	} else {
		Printfln("Error: %v", err.Error())
	}
}
```

#### Using the convenience Func to create new Files

Although it is possible to use the `OpenFile`to create a new, but there are also in the `os`package like:

- `Create(name)`-- equivalent to calling `OpenFile`with the `O_RDWR, O_CREATE, O_TRUNC`flags.
- `CreateTemp(dir, fileName)`-- creates a new file in the directory with the specified name.

`file, err := os.CreateTemp(“.”, “tempfile-*.json”)`

### Working with paths

- `Getwd()`-- returns the current working directory
- `UserHomeDir()`-- user’s home directory
- `UserCacheDir(), UserConfigDir(), TempDir()`

Once have obtained a path, can treat it like a string and simply append additional segments to it or to avoid mistakes, use the functions provided by the `path/filepath`package for manipulating paths.

`Abs(path), IsAbs(path), Base(path), Clean(path)..`

#### Managing Files and dirs

`Chdir(dir), Mkdir(name, modeperms), MkdirAll(name, modeperms)`

#### Exploring the File system

- `ReadDir(name)`-- reads the specified directory and returns a `DirEntry`slice.which defines the methods like:

`Name(), IsDir(), Type(), Info()`, note that the `Info()`also return a `FileInfo`, which -- `Name(), Size(), Mode(), ModTime()`. And the `os`package also defines a `IsNotExist()`accepts an error, returns `true`if it denotes that the error indicates that a file not exist. fore:

```go
func main(){
    targetFiles := []string {"no-suc.txt", "config.json"}
    for _, name := range targetFiles {
        info, err := os.Stat(name) // return a FileInfo
        if os.IsNotExist(err) {
            // file not exist
        }
    }
}
```

#### Locating Files using a pattern

And the `path/filepath`defines the `Glob()`which returns all the names in the directory that match a specified pattern.

```go 
func main(){
    path, err := os.Getwd()
    if err == nil {
        matches, err := filepath.Glob(filepath.Join(path, "*.json"))
        if err == nil {
            for _, m := range matches {
                Printfln("match: %v", m)  // return the file name
            }
        }
    }
}
```

#### Processing All files in a directory

Under the `path/filepath`, there is a:

`Walkdir(dir, func)`-- calls the specified func for each file and directory in the specified dir.

```go
func callback(path string, dir os.DirEntry, dirErr error) (err error) {
    info, _ := dir.Info()
    Printfln("Path: %v, Size: %v", path, info.Size())
    return
}

func main(){
    path, err := os.Getwd()
    if err == nil {
        // note the callback's signature
        err = filepath.WalkDir(path, callback)
    }else {
        Printfln(...)
    }
}
```

Ths uses the `WalkDir()`to enumerate the contents of the current working directory and writes out the path and size of each file that is found. Descried the convenience features of reading and writing files, explained the use of the `File`struct, and demonstrate how to explore and manage the file system.