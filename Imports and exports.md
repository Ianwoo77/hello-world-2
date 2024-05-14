# Imports and exports

Data sets come in a variety of file formats - csv, tsv, xlsx and more. Some data formats do not store data in tabular format, instead, they just nest collections of related data inside k-v store. And Py’s dictionary is just an example of a k-v data structure -- Pandas ships with utility functions to manipulate k-v data into tabular data and vice versa. When we have the data in a `DataFrame`, can apply all our favorite techniques to it.

### Reading from and writing to JSON files

For a JSON response consists of k-v pairs in which a key serves as a unqieu identifier for a value, Keys must be strings, values can be of any data type, including strings, numbers, and booleans.

There is just no technical difference between code samples -- but the later is more readable -- the JSON response holds 3 k-v pairs --  A key can also point to an array, an orderd collection of elements equivalent to a Py list. Note that Json can store additional k-v pairs within nested objects

#### Loading a JSON file

For the JSON, that consists of a top-level `prizes`key that maps to an array  of dictionaries, one for each combination of year and category -- the `year`and `category`keys are present for all winners.. Import functions in pandas have a consistent naming scheme -- each one consists of a `read`prefix followed a file type -- used `read_csv`function -- to import JSON, use the complementary `read_json`function -- first arg is the file path. like:

`nobel = pd.read_json('nobel.json')`For this, not in a fomat that’sideal for analysis -- pandas set the JSON’s top-level prizes key as the column name and created a Py dictioanry for each k-v pair it parsed from JSON.

```python
# just return a dictionary
nobel.loc[2, 'prizes']
type(nobel.loc[2, 'prizes']) # dict returned
```

Our goal is to convert the data to tabular format, to do so, need to extract the JSON’s top-level k-v pairs to separate DF columns. the process of moving nested records of data into a single, one-dimensional list is called *flattening* or *normalizing* - built-in `json_normalize`function 

```python
pd.json_normalize(nobel.loc[0, 'prizes'], record_path='laureates')
# one step forward, one step back
# pandas expandded the nested laureates into new columns. but:
pd.json_normalize(
    data=nobel.loc[0, 'prizes'],
    record_path='laureates',
    meta=['year','category']
) # to preserve these top-level k-v pairs, pass a list with their names to a parameter called meta
```

That is exactly the `DataFrame`want. Normalization strategy has worked successfully on a single dictionary from the prizes column -- the `json_normalize()`is smart enough to just accept a series of dictionaries and repeat the extraction logic for each entry. If:

```python
pd.json_normalize(
    data=nobel['prizes'],
    record_path='laureates',
    meta=['year', 'category']
)
```

Pandas will raise -- some dictionaries in the prizes `Series`do not have a `laureates`key -- the `json_normalize`function is unable to extract nested lauteates info  One way we can solve this problem is to identify the dictionaries that lack a *laureates* key and manually assign them the key. The `setdefault`method assigns a k-v pair to a dictionary, but only if the dictionary does not have the key. So just:

```python
nobel.prizes.apply(lambda entry: entry.setdefault('laureates', []))
```

So the `setdfault`method mutates the dictionaries with prizes, so there is no need to overwrite the original series. Now that all nested dictionaries have a `laureates`key, can reinvoke the `jons_normalize()`func -- like:

```python
nobel['prizes'].apply(lambda dt: dt.setdefault('laureates', [])),
winners = pd.json_normalize(
    data= nobel['prizes'],
    record_path='laureates', 
    meta=['year', 'category']
)
```

For this, normalized the JSON data, converted it to tabular format, and stored it in a 2D `DataFrame`.

Attempt to process in reverse -- converting a DataFrame to a JSON representation and writing it to a JSON file. The `to_json`creates a JSON string from a pandas DS. its `orient`customize the format in which pandas returns the data.

```python
# arg of records returns a JSON array of k-v
winners.head(2).to_json(orient='records')
# also can pass `split` return a dict with separate columns like:
winners.to_json('winner.json', orient='records')
```

## Define Templates

A named template can invoke other named templates. And nested named templates can exacerbate whitespce issue. Nested named templates can exacerbate whitespace issue cuz the whitespace around the templates. Can:

```html
{{define "mainTemplate" -}}
<h1>
    ...
</h1>
{{- end}}
```

Using the `define`and `end`keywords for the main template content excludes the whitespace used to separate the other named templates. like:

```go
func main(){
    allTemplates, err := template.ParseGlob("templates/*.html")
    if err == nil {
        selectedTemplate := allTemplates.Lookup("mainTemplate")
    }
}
```

So, any named templates can be executed directly, but have selected `mainTemplate`.

### Defining Template Blocks

Template blocks are used to define a template with default content that can be overridden in another template file.

```html
{{define "mainTemplate" -}}
    <h1>This is the layout header</h1>
    {{- block "body" .}}
        <h2>There are {{len .}} products in the source data.</h2>
    {{- end}}
    <h1>This is the layout footer</h1>
{{- end}}
```

The `block`action is used to assign a name to a template, unlike a `define`the `template`will e included in the output wihtout needing to use a `tempalte`action. And when used alone, the ouptut from the template file includes the content in the block -- But this content can be re-defined by another template file.

```html
{{define "body"}}
    {{range .}}
        <h2>Product: {{. Name}} ({{printf "$%.2f" .Price}})</h2>
    {{end -}}
{{end}}
```

```go
func main(){
    alltemplates, err := template.ParseFiles("templates/template.html", 
                                            "templates/list.html")
    //...
}
```

So the template must be loaded so that the file that contains the block action is loaded before the file that contains the `define`action that redefines the template.

## Performing concurrent computations on the default case-- 

A useful scenario is to use the default select case for concurrent computations and then use a channel to a signal when we need to stop. like:

```go
func toBase27(n string) string {
    result := ""
    for n>0 {
        result = string(alphabet[n%27])+result
        n /= 27
    }
    return result
}
```

To find our password faster, can just divide the range of our guesses among several goroutines. goroutine A would try guesses from string enumerations 1 to 10 million... To avoid unnecessary computations, want to stop the execution of each gorotuine when any goroutine makes a correct guess. To achieve this, can use a channel to notify all other goroutines when one execution discovers the password, once a goroutine finds the matching password, it closes a common channel, this has the effect of interrupting all participating goroutines and stopping the processing.

So, How can we implement the logic to stop processing in all goroutines after a common channel is closed -- one solution is to perform the necessary computation in the `select`'s statement’s `default`case and then have another cae waiting on the common channel. can call our `toBase27()`func and try to guess passwords in the default case, each time guessing just one password, can have logic to stop generating and trying passwords in separate select case.

Shows a func that accept this common channel, called `stop`-- In the func, we generate all password guesses from the give range, represented by the `from`and `up`to integer variable. Each time we generate the next password guess, truy to match it against the `passwordToGuess`constant. This simulates the program trying to access a resource that is pwd protected -- once pwd matches, the function loses the channel, resulting in all the goroutines receiving a close message on their won select case and stopping their processing cuz of the `return`statement.

```go
func guessPwd(from int, upto int, stop chan int, result chan string) {
	for guessN := from; guessN < upto; guessN++ {
		select {
		case <-stop:
			fmt.Printf("Stopped at %d [%d,%d]\n", guessN, from, upto)
			return
		default:
			if toBase27(guessN) == passwordToGuess {
				result <- toBase27(guessN)
				close(stop)
				return
			}
		}
	}
	fmt.Printf("Not found between [%d, %d]\n", from, upto)
}
```

Can now create several goroutines executing the prevous listing -- each goroutine will try to find the correct pwd within a certain range.

```go
func main() {
	finished := make(chan int)
	passwordFound := make(chan string)

	for i := 1; i <= 387420488; i += 10_000_000 {
		go guessPwd(i, i+10_000_000, finished, passwordFound)
	}
    // waits for the pwd to be found
	fmt.Println("password found", <-passwordFound)
	close(passwordFound)
	// time.Sleep(5*time.Second)
}
```

Aftering startin up all the goroutines, the `main()`function waits for an output message on the `passwordFound`channel.

#### Timout on channels -- 

Another useful scenario is blocking for only a specified amount of time, waiting for an operation on a channel. Just like in the previous two examples, want to check to see whether a message has arrived on a channel, but we want to wait for a few seconds to see if a message arrives. Instead of unblocking immediately and doing sth else. -- this is useufl in many situations when channel operations are time sensitive.

Can implement this behaivor by using a separate goroutine that sends a message on an extra channel after a speecified timeout. Can then use this extra channel in our `select`statement, together with the other channels.

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		time.Sleep(seconds)
		messages <- "Hello"
	}()
	return messages
}

func main(){ 
    t, _ := strconv.Atoi(...)
    messages := sendMsgAfter(3*time.Second)
    fmt.Printf("Waiting for message for %d seconds...\n", t)
    select {
    case msg := <-messages:
        //...
    case tNow := <-time.After(timeoutDuration):
        fmt.Printf("Timeout, wait until:", tNow.Format("15:04:05"))
    }
}
```

#### Waiting to channels with select

Can also use the `select`statement when we need to write messages to channels, not just when we are reading messages from channels. `Select`statement can combine read or write blocking channel operations together, selecting the case that unblocks first. As in the prevous -- can `select`to implement non-blockning channel sending or sending on a channel with a timeout. FORE:

```go
func primesOnly(inputs <-chan int) <-chan int {
	results := make(chan int)
	go func() {
		for c := range inputs {
			isPrime := c != 1
			for i := 2; i <= int(math.Sqrt(float64(c))); i++ {
				if c%i == 0 {
					isPrime = false
					break
				}
			}
			if isPrime {
				results <- c
			}
		}
	}()
	return results
}
```

Notice that our goroutine outputs a subset of the numbers it receives on the input channel. Often, the goroutine receives a non-prime number that is thrown away, meaning no number is output. How can we feed in a stream of random numbers while reading the primes returned on another channel in one goroutine.

```go
func main() {
	numberChannel := make(chan int)
	primes := primesOnly(numberChannel)

	for i := 0; i < 100; {
		select {
		case numberChannel <- rand.Intn(100000000) + 1:
		case p := <-primes:
			fmt.Println("Found prime:", p)
			i++
		}
	}
}
```

#### Disalbing select cases with nil channels 

In Go, can assign `nil`values to channels -- This has the effect of blocking the channel from sending or receiving anytihng. fore:

```go
func main(){
    var ch chan string = nil
    ch <- "message" // block execution as it tries to send message on the nil channel
    fmt.Println("This is never printed")
}
```

When run `Println`command, never gets executed cuz the execution blocks on the message sending. Go also has a deadlock detection, so when Go noteices that hte program is stuck with no hope of recovering, giving message fatal error. The same logick applies to `select`statements. Trying to send or receive from a `nil`channel on a `select`statement has the same effect of blocking the case using that channel.

Using `select`with just one `nil`channel isnot that useful -- can use the pattern of assigning `nil`to a channel to disable a case in a `select`statement. Just consider a scenario where we are consuming messages from two separate goroutine on two separate channels.

FORE, might be developing accounting software that receives sales and expense amount form various sources. At the close of business, we want to output the total proift or loss for that day -- can model this by having a goroutine outputting sales details on one channel and another goroutine doing the same on another channel for expenses. Can then collate the two sources in another goroutine.