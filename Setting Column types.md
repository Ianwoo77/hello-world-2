# Setting Column types

Want to create a data frame based on New York taxi data from -- want to just ensure the data in the most appropraite and compact from it can be and will use as little memory as possible when being loaded.

- Specify the `dtype`for each column as you read it in.
- Idenitfy rows containing `NaN`values -- which columns are `NaN`and why -- 
- Remove any rows containing any `NaN`values
- Set the `dtype`for each column to the smallest, most appropratie value.

If try to set the `dtype`for `passenger_count`and `payment_type`to `int8`-- quickly discover a problem -- pandas raises an error -- indicating that there are `NaN`values in those columns -- cuz `NaN`is a float that cannot be converted into an integer -- need to keep those columns as floats -- first use `float32`and then switch it back to `int8`when are done removing `NaN`values.

Regardless, to change those two column’s `dtype`to be `int8`-- need to remove the `NaN`values -- can do that with `df.dropna()`-- which returns a new data frame identical to `df`but without rows containing `NaN`. like:

`df = df.dropna()`

Even though `df.dropna()`returns a new data frame, its data may be shared with other data frames for the sake of efficiency -- Modifying our data frame may thus result in a `SettingWithCopyWarnning`. like:
`df = df.dropna().copy()`

If have removed all the `NaN`values, 

```python
df['passenger_count']=df['passenger_count'].astype(np.int8)
df['payment_type']=df['payment_type'].astype(np.int8)
# === solution
df = pd.read_csv('../...', 
                usecols=['...'], 
                dtype={'passenger_count': float32, 
                      'total_amount': flaot32,
                      'paymetn_type': float32})
df.count()
df = df.dropna().copy()
# ...
df.isnull().sum().sum()
```

```python
df['VendorID'] = df['VendorID'].fillna(3)
df['VendorID'] = df['VendorID'].astype(np.int8)
```

### Passwd to df

CSV is just a very flexible format -- many files that wouldn’t necessarily think of as being CSV files can be imported into pandas with `read_csv`--  For this, want to create a dataframe from a file that you wouldn’t normally think of as a CSV, but that fits the format fine -- Unix `passwd`file -- which is std on Unix and `Linux`systems. -- Contains usernames and passwords.

Specifically, do the following -- 

1. Create a data frame based on linux-etx-passwd.txt -- notice that this file contains comment lines -- and blank lines -- 
2. Add column names -- 
3. Make the username column the data frame’s index

Need to review each keyword argument that pass to `read_csv`-- look at what it does, and see how the value we pass allows us to read `passwd`into a data frame -- For starters -- CSV files are named for the default field separator. By default pandas assumes that we have comma-spearated values, it’s just fine if we want to use another character. But when need to specify that in the `sep`keyword argument, in this case, our separator is `sep=':'`to the `read_csv()`.

Next, deal the fact that this `passwd`file contains comments, comments all start wtih # characters and extend to the end of the line -- `read_csv`does this -- specify the string that marks the start of comment line. `comment='#'`-- indicate that the parser should ignore such lines.

Next, the `header`-- by default `read_csv`assumes that the first line of the file is a header containing column names, also uses that first line to figure out how many fields will be on each line. If a file contains headers but not on it sfirst line, can se `header`to an integer value, indicating which line `read_csv`should look for them -- If has not a header, just like `header=None`.

Next, for blank linkes -- get off easy there -- cuz `read_csv`just ignores blank lines by default -- if want to treat blank lines as `NaN`-- can pass `skip_blank_lines=False`rather than accepting the default line of `True`. When this in place, the passwd file can easily be truned into a data frame like

Finally, `names`-- if don’t give any names, the data frame’s columns will be labled with integers starts with 0 -- there is nothing technically wrong -- but it’s harder to work with data. Column-names, namely.

```python
df= pd.read_csv('linux-etc-passwd.txt',
                sep=':',
                comment='#',
                header=None,
                names='username password userid groupid name homedir shell'.split())
```

## Using the functional options Pattern

When designing an API, one question may arise, how do we deal with optional configurations -- Solving this problem efficiently can improve how convenient our API will become -- This section goes through a concrete example and covers different ways to handle optional configurations.

For this, say we have to design a lib that exposes a func to create an HTTP server. For this func would accept different inputs, an address and a port. like:

```go
func NewServer(addr string, port int) (*http.Server, error) {
    //...
}
```

Noticed that adding new function parameters breaks the compatibility, forcing clients to modify the way they call `NewServer`-- like:

- If the prot isn’t set, it uses the default one
- If the prot is negative, it returns an error
- If the port equal 0 random used
- it uses the port provided by the client.

Note, Go doesn’t support optional parameters in fucntion signatures -- the first possible approach is to use a configuration struct to convey what is mandatory and what is optional. Fore the mandatory could live as function parameters, whereas the optional parameters could be handled in the `Config`struct like:

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Config) {}
```

For this -- if add new options, it will not break on the client side. This approach doesn’t solve our requirement related to port management. Note in our caes, need to find a way to distinguish between a port purposely set to 0 and a missing port -- Perhaps one option might be to handle all the parameters of the configuration struct as pointers.

```go
type Config struct {
    Port *int
}
```

So, using a pointer, semantically, can highlight the difference between the value 0 and a missing value (nil pointer). This option would work but it has a couple of downside -- fore:

```go
port := 0
config := httplib.Config{
    Port: &port,
}
```

It’s not showstopper as such, but the overall API beomes a bit less convenient to use. Also the more options we add, the more complex the code beomes

The second downside is that a client using our library with the default configuation will need to pass an empty struct :

`httplib.NewServer("localhost", httplib.Config{})`

For this, doesn’t look great -- readers will have to understand what this magical struct’s meaning is. So another option is to use the classic builder pattern, as presented in the next section.

#### Builder Pattern

Originally part of the Gang of Four design patterns -- the builder patern provides a flexible solution to various object - creation problems. The constuction of `Config`is separated from the struct itself. It requries an extra struct, `ConfigBuilder`which receives methods to configure and build a `Config`.

See a concrete example and how it can help us in designing a friendly API that tackle all our requirements, including:

```go
type Config struct {
    Port int
}
type ConfigBuilder struct {
    port *int
}

func (b *ConfigBuilder) Port (port int) *ConfigBuilder{
    // public method to set up the port
    b.port = &port
    return b
}

// build method to create the config struct
func (b *ConfigBuilder) Build() (Config, error) {
    cfg := Config{}
    // main logic related to port managment
    if b.port == nil {
        cfg.Port = defaultHTTPPort
    }else {
        if *b.port==0 {
            cfg.Port = randomPort()
        } else if *b.port<0 {
            return Config{}, errors.New("port should be positive")
        } else {
            cfg.Port = *b.port
        }
    }
    return cfg, nil
}
```

The `ConfigBuilder`struct holds the client configuration -- it exposes a `Port`method to set up the port, usually, such a configuraiton method returns the builder itself so that we can use method chaining -- it also exposes a `Build()`that holds the logic on intializaing the port value and returns a `Config`struct once created.

Then a client would use our builder-based API in the following manner -- like:

```go
builder := http.ConfigBuilder{}
builder.Port(8080)
cfg, err := builder.Build()
if err != nil {
    return err
}
server, err := httplib.NewServer("localhost", cfg)
if err != nil {
    return err
}
```

#### Additional Information -- 

Go’s file server has a few really nice features that are worth mentioning -- 

- It sanitizes all request paths by running them through the `path.Clean()`function before searching for a file. -- removes any `.`and `..`elements from the URL path, which helps to stop directory traversal attacks.
- *Range Requests* are fully supported.
- The `Last-Modified`and `If-Modified-Since`headers are transparently supported. If a file hasn’t changed since the user last requested it - then `http.FileServer`will send a 304 Not Modified status code instead of the file itslef. This helps reduce latency and processing overhead for both the client and the server.
- The `Content-Type`is automatically set from the file extension using the `mime.TypeBeExtensible()`func, can add your own custom extensions and content types using the `mime.AddExtenstionType()`func if necesssary.

#### Serving Single Files -- 

Sometimes you might want to serve a single file from within a handler -- For this there is the `http.ServeFile()`function, which can use like -- 

```go
func downloadHandler(w http.ResponseWriter, r *http.Request) {
    http.ServeFile(w, r, "./ui/static/file.zip")
}
```

#### Disabling Directory listings

If want to disable directory listings there are a few different approaches you can take. The simplest way -- add a blank `index.html`file to the specific directory that you want to disable listings for.

## The `http.Handler`interface

Before go any further there is a little theory that we should cover -- it’s a bit complicated -- Strictly speaking, what we mean by handler is *an object* is an object which satisfies the `http.Handler`interface like:

```go
type Handler interface {
    ServeHTTP(responseWriter, *Request)
}
```

In simple terms, this bascially means that to be a handler an object *must* have a `ServeHTTP()`method with the exact signature -- like `ServeHTTP(http.ResponseWriter, *http.Request)`. so in its simplest form a handler might look sth like this -- 

```go
type home struct {}
func(h *home) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("this is my home page"))
}
// can then register this with a servemutex using then Handle like:
mux := http.NewServMux()
mux.Handle("/", &home{})
```

#### Handler Functions -- 

For now, creating an object just so we can implement a `ServeHTTP()`method on it is long-winded and a bit confusing. which is why in practive it’s far more common to write your handlers as a normal function fore:

```go
func home(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("this is my home page"))
}

// instead to transform it into a handler using the `http.HandlerFunc()`adapter like:
mux := http.NewServeMux()
mux.Handler("/", http.HandlerFunc(home))
```

The `http.HandlerFunc()`adapter works by automatically adding a `ServeHTTP()`method to the `home`function, when executed, this `ServeHTTP()`method then simply calls the content of the origin `home`fnction -- it’s a rounabout but convenient way of coercing a normal function into satisfiying the `http.Handler`interface.

Throughout this project so far been using the `HandleFunc`method to register our handler functions with the servemux, this is just some syntactic sugar that transforms a function to a handler and registers it on one step, instead of having to do it manually. The code above is functionality equivalent to this -- 

```go
mux := http.NewServeMux()

```

