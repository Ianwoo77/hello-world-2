# Selecting Values with Booleans

In python and other traditional programming languages, select elements from a sequence using a combination of `for`and `if`-- although can do that in pandas -- Mask indexes are useful and powerful, but their syntax can take some getting used to. First, consdier like:

```python
s= pd.Series([10,20,30,40,50])
s.loc[3]
# instead of passing a single integer, can also pass a list like:
s.loc[[True, True, False, False, True]] # notice that double []
```

Wherever we pass `True`, the value from `s`is returned, and wherever pass `False`, the value is ignored. This is called a mask index cuz we’re using the list of booleans as a type of sieve. An explicitly defined list of boolean isn’t very useful or common, can also use a series of booleans -- and those are easy to create. like: `s.loc[s<30]`, Or:
`s.loc[s<=s.mean()]`

#### Exercise 4 - Descriptive statistics

The `mean`, median, and std deviation are 3 numbers can use to get a better picture of our data, Adding a few other numbers can give us an event more complete -- These *descriptive statics*-- Like:

```python
g = np.random.default_rng(0)
s = pd.Series(g.normal(0, 100, 1000000))
s.describe()
s.loc[s==s.min()]=5*s.max()
```

#### Passenger frequency

```python
s = pd.read_csv('data/taxi-passenger-count.csv', header=None).squeeze()
s.loc[s==1].count()
s.loc[s==6].count()
# asked you to give the proportion of elements in s
s.loc[s==1].count()/s.count()
s.loc[s==6].count()/s.count()
s.value_counts()
```

Note, cuz we get back a series from `value_counts()`, can also use all our series tricks on it. Can invoke `head`on it to get the most common elements like: `s.value_counts()[[1,6]]`, and, there also an optional `normalize`parameter that returns the fraction if set to `True` like:

`s.value_counts(normalize=True)[[1,6]]`

```python
s.quantile([.25, .50, .75])
s.value_counts(normalize=True)[[3,4,5,6]].sum()
```

#### For , long medium and short taxi rides

```python
categories.loc[:]='medium'
categories.loc[s<=2]='short'
categories.loc[s>10]='long'
categories.value_counts()
```

Can use `cut`like:

```python
pd.cut(s, bins=[0,2,5,s.max()],
       include_lowest=True, # ensures that the lowest passed to bins are included
       labels=['short', 'medium', 'long'])
```

Can directly pass to `value_counts()`method like:

```python
pd.cut(s, bins=[0,2,5,s.max()],
       include_lowest=True, # ensures that the lowest passed to bins are included
       labels=['short', 'medium', 'long']).value_counts()
```

## Go Templates

This template makes use of template variables, expressions and functions go get the query string from the reuest and select the first `index`, which is converted to an `int`and used to retrieve a `Product`value from the data provided to the template like:

```html
{{$index := intVal(index (index .Request.URL.Query "index"}), 0)}}
{{ if lt $index (len .Data)}}
	{{with index .Data $index}}
```

These expressions are more complex than generally like to see in a template -- show you can approach that find more robust -- for this, it allows me to generate an HTML form that presents `input`elements for the fields defined by the `Product`struct.
`<from method="POST" action="/forms/edit" class="m-2">`

### Rading Form data from Requests

Now that have added a `form`to the proj, can write the code that receives the data it contains. The `Request`defines the fields and methods for working with the form data like:

- `Form`-- this field returns a `map[string][]string`containing the pased from data and the query string parameters. The `ParseForm()`must be called before this field is read.
- `PostForm`-- similar to the `Form`but excludes the query string parameters so that only *data* from the request body is just contained in the map -- must be called before this field is read
- `MultipartForm`-- returns a multipart form represented using the `Form`struct defined in the `mime/multipart`package. And the `ParseMultipartForm`method must be called before this field is read.
- `FormValue(key)`-- This method returns the first value for the specified form key and returns the empty string if there is no value.
- `PostFormValue(key)`-- Returns the first value for the specified form key and return the empty string if there is no value. The source of data for this is the `Form`field, and calling `FormValue`method automatically calls `ParseForm`or `ParseMultipartForm`to parse the form.
- `FormFile(key)`-- provides access to the first file with the specified key in the form. The results are a `File`and `FileHeader`.
- `ParseForm()`-- parses a form and populates the `Form`and `PostForm`fields.

```go
func ProcessFormData(writer http.ResponseWriter, request *http.Request) {
	if request.Method == http.MethodPost {
		// automatically calls the `ParseForm`
		index, _ := strconv.Atoi(request.PostFormValue("index"))
		p := Product{}
		p.Name = request.PostFormValue("name")
		p.Category = request.PostFormValue("category")
		p.Price, _ = strconv.ParseFloat(request.PostFormValue("price"), 64)
		Products[index] = p
	}

	http.Redirect(writer, request, "/template", http.StatusTemporaryRedirect)
}

func init() {
	http.HandleFunc("/forms/edit", ProcessFormData)
}
```

The `init`function sets up a new route so that the `ProcessFormData`function handles requests whose path is `/forms/edit`-- within the `ProcessFormData`func, the request method is checked, and the form data in the request is used to create a `Product`struct and replace the existing data value.

### Reading forms data from Requests

Now that have added a `form`to the project -- can write the code that receives the data it contains. The `Request`struct defines the fields and methods for working with form data.

The `FormValue`and `PostFormValue`methods are the most convenient way to access form data if you know the structure of the form being processed -- add a file named `forms.go`to the `httpserver`folder with the content like:

#### Reading Multipart Forms

Forms encoded as `multpart/form-data`to allow binary data, such as files, to be safely sent to the server. To create a form that allows the server to receive a file, create a file named `upload.html`in the static folder like:

```html
<body>
<div class="m-1 p-2 bg-primary text-white h2 text-center">
    Upload File
</div>

<form method="post" action="/forms/upload" class="p-2"
      enctype="multipart/form-data">
    <div class="mb-3">
        <label class="form-label">Name</label>
        <input class="form-control" type="text" name="name">
    </div>

    <div class="mb-3">
        <label class="form-label">City</label>
        <input class="form-control" type="text" name="city">
    </div>
    <div class="mb-3">
        <label class="form-label">Choose Files</label>
        <input class="form-control" type="file" name="files" multiple>
    </div>

    <button type="submit" class="btn btn-primary mt-2">Upload</button>
</form>
</body>
```

For this, the `enctype`attribute on the `form`element creates a multipart form, and the `input`element whose type is `file`creates a form control that allows the user to select a file, the `multiple`attribute tells the browser to allow the user to select multiple files.

```go
func HandleMultipartForm(writer http.ResponseWriter, request *http.Request) {
	fmt.Fprintf(writer, "Name: %v, City: %v\n", request.FormValue("name"),
		request.FormValue("city"))
	fmt.Fprintln(writer, "--------")
	file, header, err := request.FormFile("files")
	if err == nil {
		defer file.Close()
		fmt.Fprintf(writer, "Name: %v, Size: %v\n", header.Filename, header.Size)
		for k, v := range header.Header {
			fmt.Fprintf(writer, "key: %v, value: %v\n", k, v)
		}
		fmt.Fprintln(writer, "------")
		io.Copy(writer, file)
	} else {
		http.Error(writer, err.Error(), http.StatusInternalServerError)
	}
}

func init() {
	http.HandleFunc("/forms/upload", HandleMultipartForm)
}
```

The `FormValue`and `PostFormValue`methods can be used to access string values in the form, but the file must be accessed using the `FormFile`method like:

`file, header, err := request.FormFile("files")`

`file`from the `FormFile()`is a `File`-- defined in the `mime/multipart`package, which is an interface that combines the `Reader, Closer, Seeker`-- and `ReadAt`interfaces that are described.

- `Name`-- returns a `string`containing the name of the file
- `Size`-- returns size
- `Header`-- `map[string][]string`which contains the headers for the MIME part contains the file.
- `Open()`-- returns a `File`can be used to read th content assocaited with the header.

## Disabling `select`cases with `nil`channels

In Go, can assign a `nil`values to channels -- this has the effect of blocking the channel from sending or receiving anything, as demontrated in the following listing. The `main`gorotuine tries to send a string on a `nil`channel, and the operation blocks, stopping any further statements from executing. Like:

```go
func main(){
    var ch chan string = nil 
    ch <- "message"
    fmt.Println("This is never printed")
}
```

Go has deadlock detection, so when Go notices that the program is stuck with no hope of recovering, it gives us the following message -- like: Note that the same logic applies to the `select`statements. And using `select`with just one `nil`channel is not that useful -- can use the pattern of assigning `nil`to a channel to disable a `case`in a `select`statement. Fore:

```go
func generateAmounts(n int) <-chan int {
    amounts := make(chan int)
    go func(){
        defer close(amounts)
        for i:=0; i<n; i++ {
            amounts <- rand.Intn(100)+1
            time.Sleep(100* time.Millisecond)
        }
    }()
    return amounts
}
```

Fore, if were to sue a nomal `select`statement to consume from both the sales and expense goroutines, with one of the goroutines closing its cahnel earlier than the other, would end up always executing on the closed channel case. And every time we consume from a closed channel, will return the default data type without blocking. This is also applies to select cases. 

One solution to this problem is to have both the salses and expense goroutines output onto the same channel and thne claose the channel only when both gorotuines are done. However, this might not always be an option, since it requires us to change the goroutine function’s signature so we can pass the same output channel to both sources.

So, another solution would be to cahnge the channel into a `nil`channel whenever it is closed. And reading from a channel actually always returns two values, the message and a flag telling us if the channel is still open. Can read the flag, and if the flag indicates that the channel has been closed, can just set the channel reference to `nil`. And assigning a `nil`value to the channel variable after the recevier detects that the cahnnel has been closed has the effect of disabling that `case`statement. This allows the receiving goroutine to read from the remaining open channels.

```go
func main(){
    salses := generateAmoutn(50)
    expenses := generateAmount(40)
    endOfDayAmount := 0
    for sales != nil || expenses != nil {
        select {
        case sale, moreData := <-sales:
            if moreData {
                fmt.Println9("sale of:", sale)
                endOfDayAmount+= sale
            }else {
                sales = nil
            }
            
        case expense, moreData := <-expenses:
            if moreData {
                fmt.Println("Expense of :", expenses)
                endOfDayMount -= expense
            }else {
                expenses = nil
            }
        }
    }
    fmt.Println("End of", endOfDayAmount)
}
```

### Choosing between message passing and memory sharing

In contrast, memory sharing means that need to use a more primitive way of manaing concurrency. Code that uses concurency primitives tends to be harder to follow. Concurrent programming using memory sharing typically produces more tightly coupled software. Hte inter-thread communication uses a common block of memroy. In contrast, with message passing, executions can have clearly defined input and output contracts, which means we know exactly how a change in one execution will affect another. 

Fore, can easily cahnge the inside logic of a goroutine if the input and output cntracts through our channels are maintained. How could implement a goroutine that downloads a web document and counts the occurrences of each letter in the alphabet.

```go
func countLetters(url string) <-chan []int {
	results := make(chan []int)
	go func() {
		defer close(results)
		frequency := make([]int, 26)
		resp, _ := http.Get(url)
		defer resp.Body.Close()
		if resp.StatusCode != 200 {
			panic("Server returning error code:" + resp.Status)
		}

		body, _ := io.ReadAll(resp.Body)
		for _, b := range body {
			c := strings.ToLower(string(b))
			cIndex := strings.Index(allLetters, c)
			if cIndex >= 0 {
				frequency[cIndex] += 1
			}
		}

		fmt.Println("Completed:", url)
		results <- frequency
	}()

	return results
}

func main() {
	results := make([]<-chan []int, 0)
	totalFrequencies := make([]int, 26)
	for i := 1000; i <= 1030; i++ {
		url := fmt.Sprintf("https://rfc-editor.org/rfc/rfc%d.txt", i)
		results = append(results, countLetters(url))
	}
	for _, c := range results {
		freqResult := <-c
		for i := 0; i < 26; i++ {
			totalFrequencies[i] += freqResult[i]
		}
	}
	for i, c := range allLetters {
		fmt.Printf("%c-%d", c, totalFrequencies[i])
	}
}
```

In converting our program to use message passing, have avoided using mutexes to control access to shared memory since each goroutine is now only working on its own data.