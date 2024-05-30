# Working it out

There are countless ways to measure the pandemic’s effect on our lives.. For starters, wanted to take info from two different files and join them into a single data frame. Can use `pd.concat`to combine two existing series objects into a single series. like:

```python
df= pd.read_csv("...", usecols=['...'])
df2 = pd.read_csv("...")
df= pd.concat([df, df2])
```

Fore, if were only interested in getting aggregate answers, would be enough -- if want to separate the answers by year via a `year`column -- solution is to add a new column to each of the file-based data frames and then concatenate them 

```python
df_2019_jul= pd.read_csv('nyc_taxi_2019-07.csv',
                         usecols=['passenger_count',
                                  'total_amount',
                                  'payment_type'])
df_2019_jul['year']=2019
df_2020_jul= pd.read_csv('nyc_taxi_2020-07.csv',
                         usecols=['passenger_count',
                                  'total_amount',
                                  'payment_type'])
df_2020_jul['year']=2020
df= pd.concat([df_2019_jul, df_2020_jul])
```

Once have done that, have a single data frame `df`to ask question -- want to know how many riders were taken in 19 vs 20. fore: like:

```python
(df.loc[df['year']==2019, 'total_amount'].count()-
 df.loc[df['year']==2020, 'total_amount'].count())
```

For how much less money did taxi drviers make as a result -- instead of using `count`, use the `sum`to total the numbers before subtract them like;

```python
(
    df.loc[df['year']==2019, 'total_amount'].sum()-
    df.loc[df['year']==2020, 'total_amount'].sum()
)
```

It makes sense that the number of trips declined during the pandemic. Fore the next question asked you to compoare the proportion of multiperson taxi rides in 19 with those in 20.

```python
df.loc[
    (df['year']==2019) &
    (df['passenger_count']>1), 'passenger_count'].count() / df.loc[df.year==2019, 'payment_type'].count()
```

Show, with a single command, the difference in descriptive statistics for `total_amount`between 2019 and 2020

```python
(
    df.loc[df['year'] == 2020, 'total_amount'].describe().round(2) - 
    df.loc[df['year'] == 2019, 'total_amount'].describe().round(2)
)
f.loc[(df['year'] == 2020) & 
       (df['passenger_count'] == 0), 'passenger_count'].count() / df['passenger_count'].count()
```

### DF frames and dtype -- 

In data frame, each column is a separate pandas series and thus has its own `dtype`-- by retreiving the `dtypes`attributes from a data frame, can determine the `dtype`of each column. This information and additional details about the data frame are also available by inovking the `infor`method on the data frame.

And, when read data from a CSV file, pandas tries to infer each column’s `dtype`, and remember that CSV files are reality text files, so pandas has to examine the data to choose the best `dtype`.

There are several problems with letting pandas analyze and choose the data this way -- although these default choices aren’t bad, they can be overly large, and the seoncd problem is -- if pandas is to correctly guess the `dtype`for a column, must examine all the values in the column -- and, if a column has m-rows -- Fore, if pandas finds values that look like integers -- and then strings at the bottoem -- End up with a `dtype`of `object`and with values of different types. Fore, using `lowe_memory`parameter -- but a potentially big problem if your data set is too large.

A better solution is to tell pandas that you don’t want it to guess the `dtype`and that you would rather tell it explicitly. Can do that by passing the `dtype`and that U would rather tell it explicitly. With a python `dictionary`. Like:

```python
df_2019_jul = pd.read_csv('nyc_taxi_2019-07.csv',
                          usecols='passenger_count total_amount payment_type'.split(),
                            
                            dtype=dict(
                                passenger_count=np.int8,
                                total_amount=np.float32,
                                payment_type=np.int8
                            ))
```

And, remember that if the column contains `NaN`-- it cannot be defined as an integer `dtype`-- need to read the column as floating-point data, remove or interpolate the `NaN`values.

## Possible problems with type embedding

Like when are generics useful -- 

- *Data Structure* -- can use generics to factor the element type if we implement a binary tree, a linked list..
- *Functions working with slices..* -- For A func to merge two channels would work with any channel type...

```go
func merge[T any](ch1, ch2 <-chan T) <-chan T {...}
```

- Factoring out behaviors instead of types -- fore, `sort`package, 

Conversely, when is it recommended that not use generics -- 

- When calling a method of the tyep argument -- consider  function that receives an `io.Writer`like:

  ```go
  func foo[T io.Writer](w T) {
      b:= getBytes()
      _, _ = w.Write(b)
  }
  ```

  For this, using generic won’t bring any value to our code whatsoever. we sould make the `w`an `io.Writer`directly.

- When it makes our code more complex.

When creating a struct, Go offers the option to embed types -- Can sometimes lead to unexpected behavior if don’t understand all the implications of type embedding.

```go
type Foo struct {
    Bar
}
type Bar struct {
    Baz int
}
```

In Go, use embedding to *promot* the fields and methods of an embedded type. Use embedded to *promote* fields and methods of an embedded type -- cuz `Bar`contains a `Baz`field -- this field is promited to `Foo`. Fore:

```go
foo := Foo{}
foo.Baz=42
```

Note that the `Baz`is available from two different paths -- either from the promoted one using `Foo.Baz`from the nominla one via `Bar`, Note: Interfacses and Embedding -- Embedding is also used within interfaces to compose an interface with others -- like:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

```go
type InMem struct {
    sync.Mutex
    m map[string]int
}
func New() *InMem {
    return &InMem {m: make(map[string]int)}
}
```

And note that we decided to make the map unepxorted so that clients can’t interact with it directly but only via exported methods. Meanwhile the mutex field is embedded. There fore:

```go
func (i *InMem) Get(key string) (int, bool) {
    i.Lock()
    v, contains := i.m[key]
    i.Unlock()
    return v, contains
}
```

Cuz the mutext is embedded, can directly access the `Lock`and `Unlock`methods from the receiver. Since `sync.Mutex`is an embedded type the `Lock`and `Unlock`methods will be promoted. Both methods become visible to extenal clients using `InMem`. like:

```go
m := inmem.New()
m.Lock() //??
```

In most cases, something that we wnat to encapsulate within a struct and make invisibiel to external clients. like:

```go
type InMem struct {
    mu sync.Mutex
    m map[string]int
}
```

For this, the mutex isn’t embedded and is unexported yet -- it can’t be accessed from external clients -- And if want to write a custom logger that contains an `io.WriteCloser`and exposes two method, if `io.WriteCloser`wasn’t embedded, would need to write it like -- 

```go
type Logger struct {
    writeCloser io.WriteCloser
}
func(l Logger) Write(p []byte) (int, error) {
    return l.writeCloser.Write(p)
}
func(l Logger) Close() error {
    return l.writeCloser.Close()
}
func main() {
    l := logger{writeCloser: os.Stdout}
    _, _ := l.Write([]byte("foo"))
    _ = l.Close()
}
```

First -- means that whatever the use case, can probabley solve it as well without the type embedding. Type embedding is mainly used for convenience -- in most case, to promote behaviros -- if decide to use type embedding, need to keep two main constraints in mind -- 

- Shouldn’t be used solely as some syntactic sugar to simplify accessing fiedl.
- It shouldn’t promote data or a behavior we want to hid from the outside.

### Not using the functional Options pattern

When designing an API -- One question may arise -- how do we deal with optional configuration -- Solving this problem efficiently can improve how convenient our API will become. Like:

```go
func NewServer(addr string, port int) (*http.Server, error) {...}
```

For this, may, our clients begin to complain that this function is somewhat limited and lacks other parameters -- However, noticed that adding new function parameters breaks the compability -- forcing the clients to modify the way they call the `NewServer()`. In the meantime, would like to enrich the logic realted to port management.

#### Config Struct 

Cuz Go doesn’t support optional parameters in function signagures -- note that. The first possible approach is to sue a configuration struct to convey what is mandatory and what is optional. Fore, the mandatory parameters could live as function parameters -- whereas the optional parameters could be handed in the `Config`struct like:

```go
type Config struct {
    Port int
}
func NewServer(addr string, cfg Confgi) {}
```

For this solution, fixes the compatibilty issue -- indeed if we add new options, it will not break on the client side, this approach doen’t solve our requirement related to the port managment. Should bear in mind what if a struct field isn’t provided -- it’s initialized to its zero value.

In the case, need to find a way to distinguish between a port purposely set to 0 and missing port.

## The `http.FileServer`Handler

Go’s `net/http`package ships with a built-in `http.FileServer`handler which U can use to serve files over HTTP from a speccific directory. To create a new `http.FileServer`handler, need to use the `http.FileServer()`function like -- `fileServer := http.FileServer(http.Dir("./ui/static/"))`

When this handler receives a request, it will remove the leading slash form the URL path and then search `./ui/static`directory for the corresponding file to send to the user. So for this to work correctly, must strip the leading `/static`from the URL path before passing it to `http.FileServer`-- otherwise it will be looking for a file which doesn’t exist and the user will receive a not found.

```go
func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", home)
	mux.HandleFunc("/snippet", snippetView)
	mux.HandleFunc("/snippet/create", createSnippet)

	// note that the path given to the http.Dir is relative to the project
	fileServer := http.FileServer(http.Dir("./ui/static/"))

	// Then use the mux.Handle() func to register the file server as the handler
	// for all URL paths that start with `/static/`. For matching paths, strip the
	// `/static/`prefix before the request reaches file server
	mux.Handle("/files/", http.StripPrefix("/files/", fileServer))

	log.Println("Starting server on :4000")
	err := http.ListenAndServe(":4000", mux)
	log.Fatal(err)
}
```

Feel free to have a play around the browser through the directory listing to view individual files.

```css
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    font-size: 18px;
    font-family: "Ubuntu Mono";
}

html, body {
    height: 100%;
}

body {
    line-height: 1.5;
    background: #f1f3f6;
    color: #34495e;
    overflow-y: scroll;
}

header, nav, main, footer {
    padding: 2px calc((100% - 800px) / 2) 0;
}

main {
    margin-top: 54px;
    margin-bottom: 54px;
    min-height: calc(100vh - 345px);
    overflow: auto;
}

h1 a {
    font-size: 36px;
    font-weight: bold;
    background-image: url("/static/img/logo.png");
    background-repeat: no-repeat;
    background-position: 0px 0px;
    height: 36px;
    padding-left: 50px;
    position: relative;
}

h1 a:hover {
    text-decoration: none;
    color: #34495e;
}

h2 {
    font-size: 22px;
    margin-bottom: 36px;
    position: relative;
    top: -9px;
}
```

#### Using the static files -- 

just in the `ui/html/base.layout.html`file like:

```html
<head>
    <meta charset="UTF-8">
    <title>{{template "title" .}} - Snippetbox</title>

    <link rel="stylesheet" href="files/css/main.css">
    <link rel="shortcut icon" href="files/img/favicon.ico"
          type="image/x-icon">
</head>
```

