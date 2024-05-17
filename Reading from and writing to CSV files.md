# Reading from and writing to CSV files

Each row includs the name, birthday, gender.. Can access the website in browser and download the CSV files. Then writing the DF to a plain CSV file just with the `to_csv`method, without an arg, the method outputs the CSV string directly in our Notebook. Following the CSV conventions, pandas separates rows with line breaks and row vlaues commas. `baby_names.head(10).to_csv(index=Fasle)`. To write the string to a CSV file, can pass the desired filename as the first argument to the `to_csv`method. The method just produces no output below the Notebook cell.

And by default, pandas jsut writes all `DataFrame`columns to the CSV file, can choose which columns to export by passing a list of names to the columns parameter. Then just like:

```python
baby_names.to_csv(
    "NYC_baby_names.csv", 
    index=False,
    columns=["Gender", "Child's First Name", "Count"]
)
```

### Reading form and writing to Excel workbooks

Excel is just..  Pandas makes it easy to read from and write to Excel workbooks and even specific worksheets. need to do a little housekeeping to integrate the two pieces of software.

Need installing `xlrd`and `openpyxl`libraries in an Anaconda environment. For a more in-depth overview:

```sh
conda create -n pandas_in_action
conda info --envs # base...
conda activate pandas_in_action
conda install xlrd openpyxl
```

#### Importing Excel workbooks

The `read_excel()`functin at the top level of pandas imports an Excel workbook into a `DataFrame`, `io`accepts a string with the workbook’s path, make sure to include the `xlsx`ext in the filename.

```python
pd.read_excel(r'Single Worksheet.xlsx')
```

The `read_excel()`supports many of the same parameters as `read_csv`, including `index_col`to set the index columns, `usecols`to select the columns, and `squeeze()`to cocerce a non-column DataFrame into a `Sereis`object.

```python
pd.read_excel(r'Single Worksheet.xlsx',
              usecols=['City', 'First Name', 'Last Name'],
              index_col='City')
```

And the complexity increases slightly when a workbook contains multiple worksheets, the multiple worksheets.xlsx workbook holds 3 worksheets -- by default, pandas imports only the first worksheet in the workbook.

During import, pandas assigns each worksheet an index positon starting at 0, can import a specific worksheet by passing the worksheet’s index position or its name to the `sheet_name`parameter.

```python
pd.read_excel(r'Multiple Worksheets.xlsx', sheet_name=0) # or sheet_name="sheetname"
```

To import all worksheets, can pass an argument of `None`of the `sheet_name`parameter, pandas will store each worksheet in a separate `DataFrame`.

```python
pd.read_excel(r'Multiple Worksheets.xlsx', sheet_name=None) # return a dict
```

To specify a subset of worksheets to import, can pass the `sheet_name`parameter a list of index position or worksheet names. like:

```python
pd.read_excel(r'Mul...', sheet_name= ['Data1', 'Data 3'])
```

#### Exporting excel workbooks

Return to.. Say want to split the data set into two `DataFrames`, one for each gender. Then like to write each DataFrame to a separate worksheet in a new Excel workbook.

```python
girls= baby_names[baby_names['Gender']=='FEMALE']
boys = baby_names[baby_names['Gender']=='MALE']
```

Then, writing to an Excel workbook requires a few more steps than writing to a csv. First up, need to create an `ExcelWriter`object -- this object serves as the fundation of the workbook. This `ExcelWriter`ctor is available as a top-level attribute of the pandas library. 

```python
excel_file= pd.ExcelWriter('Baby_names.xlsx')
excel_file
```

Then need to connect our DataFrames to individual workshets in the workbook. A DF includes a `to_excel()`method for writing to an Excel workbook. the method’s first parameter, `excel_writer`, accepts an `ExcelWriter`object. just:

```python
boys.to_excel(excel_writer=excel_file,
              sheet_name='Boys',
              index=False,
              )
excel_writer.close()
```

Should:

```python
with pd.ExcelWriter('output.xlsx', engine='openpyxl') as writer:
	df.to_excel(writer, sheet_name="Sheet1")
    df.to_excel(writer, sheet_name="Sheet2")
```

## Selecting Channels

Namely, how can we have one goroutine respond to messages coming from different gorotuines over multiple channels -- Go’s `select`statement les us specify multiple channel operations as separate cases and then execute a case depending on which channel is ready.

### Combining multiple channels

How canhave one goroutine respond to messages coming from different goroutines over multiple channels -- Go’s `select`statement lets us specify multiple channel operations as separate cases and then execute a case depending on which channel is ready.

Once a message arrives on any of the channels, the gorotuine is unblocked, and a code handler for that channel is run. Can then decide what else to do -- either continue with our execution, or go back and wait for the next message by using `select`statement again.

Have a func that creates an anonymous goroutine that periodically sends a message on a channel. The period is specified by the `seconds`input variable. Can do this cuz Go channels are *first-class* objects.

```go
func writeEvery(msg string, seconds time.Duration) <-chan string {
    messages := make(chan string)
    go func(){
        for {
            time.Sleep(seconds)
            messages <- msg
        }
    }()
    return messages
}
```

DEF -- Channels are *first-class* objects, which means that we can store them as variables, pass or return them from functions, or even send them on a channel. Can demonstrate the `select`statement by calling `writeEvery()`func. If sepcify a different message and sleep period, end up with two channels and two goroutines sending messages at a different times.

```go
func main(){
    messagesFromA := writeEvery("Tick", time.Second)
    messagesFromB := writeEvery("Tock", 3* time.Second)
    for{
        select {
        case msg1 := <-messageFromA:
            fmt.Println(msg1)
        case msg2 := <-messageFromB:
            fmt.Println(msg2)
        }
    }
}
```

Note, when using `select`, if the multiple cases are ready, a case is chosen at random, your code should not rely on the order in which the cases are specified.

#### Using `select`for non-blocking channel operations -- 

Another use case for `select`is when we need to use channels is in a *non-blocking* manner -- Go provides a non-blocking `tryLock()`operation. This function call tries to acquire the lock, but if the lock is being used, it will return immediately with a `false`return value.

So the `select`statement gives us the `default`case for exactly this scenario -- The instructions under the default case will be executed if none of the other case is availabe. This lets us try to access one or more channels, but if none is ready, can do sth else.

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
    messages := make(chan string)
    go func(){
        time.Sleep(seconds)
        messages <- "Hello"
    }()
    return messages
}

func main(){
    messages := sendMesgAfter(3* time.Second)
    for {
        select {
        case msg := messages:
            fmt.Println("Message received:", msg)
            return
        default:
            fmt.Println("No message waiting")
            time.Sleep(time.Second)
        }
    }
}
```

In this previous listing, since have the `select`statement in loop, the default case will be executed over and over again until receive a message.

#### Performing concurrent computations on the default case

A useful scenario is to use the default select case for concurrent computations and then use a channel to signal when need to stop -- suppose we have a sample application that will discover a forgotten pwd by blute force. just Like:

```go
const(
	passwordToGuess = "go far"
    alphabet = " abc..."
)
func tobase27(n int) string {
    result := ""
    for n>0 {
        result = string(alphabet[n%27]) + result
        n/=27
    }
    return result
}
```

And, to find our pwd faster, just can divide the range of our guess among several goroutines, To avoid unnecessary computations, want to stop the execution of each goroutine when any goroutien makes a correct guess. how can implement the logic to stop processing in all goroutines after a common channel is closed. Shows a function that accept this common channel called `stop`-- generate all pwd guesses from the given range, represented by the `from`and `upto`integer variables.

```go
func guessPassword(from int, upto int, stop chan int, result chan string) {
    for guessN := from; guessN < upto; guessN++ {
        select {
        case <-stop:
            fmt.Printf("Stopped at %d [%d,%d]\n", guessN, from, upto)
            return
        default:
            if toBase27(guessN)==passwordToGuess {
                result <- toBase27(guessN)
                close(stop)
                return
            }
        }
    }
    fmt.Printf(...)
}
```

Can then create several goroutines executing the listing. each goroutine will try to find the correct pwd within a certain range. like:

```go
func main(){
    finished := make(chan int)
    passwordFound := make(chan string)
    for i:=1; i<=387420488, i+=10000000 {
        go guessPassword(i, i+10000000,finished,passwordFound)
    }
    fmt.Println("password found:", <-passwordFound)
    close(passwordFound)
    time.Sleep...
}
```

#### Timing out on Channels

Another useful scenario is blocking for only a specified amount of time -- waiting for an operation on a channel, just like in the previous two examples, want to check to see whether a message has arrived on a channel. Can IMP this behaviro by using a separate goroutine that sends a message on an extra channel after a specified timeout. Like:

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
    messages := make(chan string)
    go func(){
        time.Sleep(seconds)
        messages <- "Hello"
    }()
    return messages
}
func main() {
    t, _ := strconv.Atoi(os.Args[1])
    messages := sendMsgAfter(3*time.Second)
    timeoutDuration := time.Duration(t)*time.Second
    fmt.Printf(...)
    select {
    case msg:= <-messages:
        fmt.Println("message received:", msg)
    case tNow:= <-time.After(timeoutDuration):
        fmt.Println("Timeout")
    }
}
```

#### Writing to channels with `select`

Can also use the `select`statement when need to write messages to channels. Not just when we are reading messages from channels, `Select`can combine read or write blocking channel opreations togehter, Selecting the case that unblocks first.

```go
func primesOnly(input <-chan int) <-chan int {
    results := make(chan int)
    go func(){
        for c:= range inputs {
            isPrime := c!=1
            for i:=2 ; i<int(math.Sqrt(float64(c))); i++ {
                if c%i == 0 {
                    isPrime =false
                    break
                }
            }
            if isPrime {
                resuts <-c
            }
        }
    }()
    return result
}

func main(){
    numberChannls := make(chan int)
    primes := primesOnly(numbersChannel)
}
```

Often, the goroutine receives a non-prime number that is thrown away, meaning no number is output, how can we feed in a stream of random numbers while reading the primes returned on another channel in one goroutine-- The ansower is to use a `select`statement to both feed in tha random numbers and reads the primes.