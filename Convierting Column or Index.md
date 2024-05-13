# Converting Column or Index

```python
disney = pd.read_csv('disney.csv', parse_dates=['Date'])
# or
disney['Date']= pd.to_datetime(disney['Date'])
```

### Using `DatetimeProperties`object

A `datetime`series holds a special `dt`attribute that exposes a `DatetimeProperties`object like:

```python
disney['Date'].dt # returns a DatetimeProperties object
# can access attributes and invoke methods on this obj to extract information from it
disney['Date'].dt.day # month year...
# can extract more-interesting pieces of info like:
disney['Date'].dt.dayofweek # prop
disney['Date'].dt.day_name() # method
# Then can pair these `dt`attribute methods with other pandas features for advanced use:
disney['Day of week'] = disney.Date.dt.day_name()
group = disney.groupby('Day of week')
group.mean(numeric_only = True)
```

Come back to `dt`object methods the complementary `month_name`method returns a `Series`with the `date`month: Some attributes on the `dt`object return Booleans -- Fore, explore stock performance at the start of each quarter in history -- the four quarters of a business year start.. fore: 1.1, 4.1.. The `is_quarter_start`attribute returns a Boolean `Series`in which `True`denotes that the row’s date fell on a quarter start day just like:

```python
disney['Date'].dt.is_quarter_start
# User series to extract the disney rows that fell at the beginnig of a quarter like:
disney[disney['Date'].dt.is_quarter_start]
# and complentary is_quarter_end
# and is_month_start, is_month_end, is_year_start, is_year_end
```

### Adding and subtracting durations of time

Can add or subtract consistent durations of time with the `DateOffset`object, its ctor is available at the top level of pandas. Like:

```python
pd.DateOffset(years=3, months=4, days=5)
# can use + operator like:
(disney['Date']+pd.DateOffset(days=5)).head()
# can use - to subtract a duration from each date in the datetime series like:
(disney['Date'] - pd.DateOffset(days=3)).head()
# Timestamp object do store a time internally
# so can convert the Date column's values to datetimes
disney['Date']+pd.DateOffset(days=10, hours=6)
# also applies the same logic when subtracting a duration like:
(disney['Date']-pd.DateOffset(years=1, months=3, days=6, hours=6, minutes=3)).head()
```

So the `DateOffset`ctor supports additional keyword parameters for seconds, ms, and ns. can also apply the addition and subtraction syntax to pandas’ offset objects.

```python
(disney.Date+pd.offsets.MonthEnd()).tail()
```

Note, there has to be some movement in the intended direction. Thus, if a date falls at the end of a month, the library rounds it to the end of the following month. For minus, just like

```python
(disney.Date + pd.offsets.MonthBegin()).tail()
```

So there is a special group of offsets is available for business time calculation -- their names begins with a captial `B`

### The `Timedelta`object

Py’s native `timedelta`-- the distance between two times -- A duration such as one hour represents a length of a time, it does not have specific date or time attached. Is available at the top level of pandas, it accepts keyword for units of time -- like:

```python
duration = pd.Timedelta(
	days=8, hours=7...
)
```

And there is a `to_timedelta`at the top level of pandas. Fore:

```python
pd.to_timedelta('0 days 05:00:00')
pd.to_timedelta(5, unit='hour')
# can pass an interable object like:
pd.to_timedelta([5,10,15], unit='day')
# usually, Timedelta are derived rather than created from scratch
pd.Timestamp('1999-02-05')- pd.Timestamp('1998-05-24')
#
deliveries.order_date=pd.to_datetime(deliveries.order_date)
deliveries.delivery_date= pd.to_datetime(deliveries.delivery_date)
# can just use for loop
deliveries['delivery_date']-deliveries['order_date'] # return a series of timedelta
deliveries['duration']= deliveries['delivery_date']-deliveries['order_date']
# math methods are also available to this:
deliveries['duration'].max()
# can:
deliveries['duration'] > pd.Timedelta(days=365)
deliveries['duration'] > '356 days'  # ea
# or:
deliveries[deliveries['duration']> "356 days"].head()
long_time=(
	diliveries['duration']> '2000 days, 8hours, 4minutes'
)
```

## Using the built-in slice functions -- 

```html
<h1>There are {{len .}} products in the source data.</h1>
<h1>First product: {{index . 0}}</h1>
{{range slice . 3 5 -}}
    <h1>Name: {{.Name}}, Category: {{.Category}}, price,
        {{- printf "$%.2f" .Price}}</h1>
{{end}}
```

```go
func Exec(t *template.Template) error {
	return t.Execute(os.Stdout, Products)
}

func main() {
	allTemplates, err := template.ParseGlob("templates/*.html")
	if err == nil {
		selectedTemplate := allTemplates.Lookup("template.html")
		err = Exec(selectedTemplate)
	}
	if err != nil {
		fmt.Printf("Error: %v", err.Error())
	}
}
```

### Conditionally Executing Template Content

Actions can be used conditionally insert content into the output based on the evaluation of expressions - like:

```html
{{ range . -}}
    {{if lt .Price 100.00 -}}
        <h1>Name: {{.Name}}, Category: {{.Category}}, Price,
            {{- printf "$%.2f" .Price}}</h1>
    {{end -}}
{{end}}
```

The `if`indicates a conditional action, and the `lt`function performs a less-than comparison, and the remaining args specify the `Price`field of the current value in the `range`expression and the lital value of 100.00.

#### Using the Optional Conditional Actions

The `if`action can be used with optional `else`and `else if`keywords, fore:

```html
{{ range . -}}
    {{if lt .Price 100.00 -}}
        <h1>Name: {{.Name}}, Category: {{.Category}}, Price,
            {{- printf "$%.2f" .Price}}</h1>
    {{ else if gt .Price 1500.00 -}}
        <h1>Expensive Product {{.Name}} ({{printf "$%.2f" .Price}})</h1>
    {{else -}}
        <h1>Mid-range product: {{.Name}} ({{printf "$%.2f" .Price}})</h1>
    {{end -}}
{{end}}
```

#### Creating Named Nested Templates

The `define`action is just used to create a nested template that can be executed by name, which allows content to be defined once and used repeatedly with the `template`action like:

```html
{{define "currency"}} ({{printf "$%.2f" .}} {{end}}
{{define "basicProduct" -}}
    Name: {{.Name}}, Category: {{.Category}}, Price,
    {{- template "currency" .Price}}
{{- end}}
{{define "expensiveProduct" -}}
    Expensive Product {{.Name}} ({{template "currency" .Price}})
{{- end}}

<h1>There are {{len .}} products in the source data.</h1>
<h1>First product: {{index . 0}}</h1>
{{ range . -}}
    {{if lt .Price 100.00 -}}
        <h1>{{ template "basic" .}}</h1>
    {{ else if gt .Price 1500.00 -}}
        <h1>{{template "expensiveProduct" .}}</h1>
    {{else -}}
        <h1>Mid-range product: {{.Name}} ({{printf "$%.2f" .Price}})</h1>
    {{end -}}
{{end}}
```

So the `define`keyword followed by the template name in quotes, and the template is terminted by the `end`keyword. The `template`keyword is used to execute a named template, specifying the template name and a data value.

` {{- tempalte “currency” .Price}}` This action executes the template *named* currency and uses the value of the `Price`field as the data value. which is accessed within the named template using the period. And nested named template can exacerabate whitespace isues cuz the whitespace around the templates. like:

```html
{{define "mainTemplate" -}}
    //...
{{- end}}
```

Using the `define`and `end`keywords for the main template content excludes the whitespace used to separate the other named templates. Use this directly in the code:

`selectedTemplate := allTemplates.Lookup("mainTemplate")`

## Assigning a direction to channels

Go’s channes are just *bidirectional* by default, this means that a goroutine can act as both a receiver and a sender of messages -- however, we can assign a direction to a channel so that the goroutine using the channel can only send or recevie messages. When declare a function’s parameters, can specify the direction of the channel.

```go
func receiver(message <-chan int) {
	for {
		msg := <-message
		fmt.Println(time.Now().Format("15:04:05"), "received", msg)
	}
}

func sender(message chan<- int) {
	for i := 1; ; i++ {
		fmt.Println(time.Now().Format("15:04:05"), "sending", i)
		message <- i
		time.Sleep(time.Second)
	}
}
func main() {
	msgChannel := make(chan int)
	go receiver(msgChannel)
	go sender(msgChannel)
	time.Sleep(5 * time.Second)
}

```

### Closing channels

Instead of using this *sential* value message, Go allows us to close a channel. Can do this in code by calling the `close(channel)`function -- once we close a channel, we shouldn’t send any more messages to it cuz doing so raises errors. If try to receive messages from a closed channel, will get messages contining the default value for the channel’s data type. For the syntax `value, boolean := <-messages`, this syntax is useful in certain situations, such as when it’s combined with the `select`statement.

```go
func receiver(messages <-chan int) {
	for msg := range messages {
		fmt.Println(time.Now().Format("15:04:05"), "Received", msg)
		time.Sleep(time.Second)
	}
	fmt.Println("receiver finisthed")
}

func main() {
	msgChannel := make(chan int)
	go receiver(msgChannel)
	for i := 1; i <= 3; i++ {
		fmt.Println(time.Now().Format("15:04:05"), "sending", i)
		msgChannel <- i
		time.Sleep(time.Second)
	}
	close(msgChannel)
	time.Sleep(3 * time.Second)
}

```

#### Recieving function results with channels

Can execute functions concurrently in the background and then collect their results via channels once they finish. Typically, in normal sequential programming, call a function and expect it to return a result. In concurrent programming, can call functions in separate goroutines and later just pick up their return values from an output channel.

```go
func findFactors(number int) []int {
	results := make([]int, 0)
	for i := 1; i <= number; i++ {
		if number%i == 0 {
			results = append(results, i)
		}
	}
	return results
}
```

For this if have multiple cores available, executing the first `findFactors()`call in parallel with the second will speed up our program. Just how do we wait and collect the results from first call -- could use sth like a shared variable and waitgroup -- but just using channels -- like:

```go
func main() {
	resultCh := make(chan []int)
	go func() {
		resultCh <- findFactors(3419110721)
	}()
	fmt.Println(findFactors(4033836233))
	fmt.Println(<-resultCh)
}
```

#### Selecting Channels

Used channels to implement message passing between two goroutines -- see how to use Go’s `select`statement to read and write messages on multiple channels and to implement timeouts and non-blocking channels. Also examine a technique for excluding channels that have been closed and consuming only from the remaining open channels.

### Combining multiple channels

Can have one goroutine respond to messages coming from different goroutines over multiple channels -- Go’s `select`statement lets us specify multiple channel operations as separate cses and then execute a case depending on which channel is ready.

A simle scenario where a goroutine is expecting messages from separate channels -- but don’t know which channel the next message will be received -- the `select`statement lets us group read operations on multiple channels together, blocking the goroutine until a message arrives on any one of the channels. Once a message arrives on any of the channel, the groutine is unblocked, and a code handler for that channel is run -- can then decide what else to do either continue with our execution, or go back and wait for the next message by using the `select`statement again.

Fore, have a function that creates an anonymous goroutine that periodically sends a message on a channel. The period is specified by the `seconds`input variable. like:

```go
func writeEvery(msg string, seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		for {
			time.Sleep(seconds)
			messages <- msg
		}
	}()
	return messages
}
```

Note- Channels are just *first-class* objects, which means that we can store them as variables, pass or return them from functions, or even send them on a channel. Can demonstrate the `select`by calling `writeEvery()`-- specify a different mesage and sleep period -- end up with two channels and two goroutines sending messages at different times. the following listing reads from the two channels in a `select`-- with each as a separate select case like:

```go
func main() {
	messageFromA := writeEvery("Tick", time.Second)
	messageFromB := writeEvery("Tock", 3*time.Second)
	for {
		select {
		case msg1 := <-messageFromA:
			fmt.Println(msg1)
		case msg2 := <-messageFromB:
			fmt.Println(msg2)
		}
	}
}
```

Get the `main`goroutine looping and blocking each time until a message arribes from either channel. When we get a message, the `main()`goroutine executes the code underneath the `case`statement. When using `select`, if multiple cases are ready, *a case chosen at random*. So, code should not rely on the order in which the cases are specified.

### Using select for non-blocking channel operations

Another use case for `select`is when we need to use channel in a non-blocking manner -- Recall that when were discussing mutexes, -- The function call tries to acquire the lock -- but used, return immediately with a `false`. Fore, `tryLock()`operation. Namely, can try to read a message from a channel -- then if no messages are available, instead of blocking have the current execution work on a default set of instruction -- The `select`gives us the *default* case for exactly this scenario -- the instructions under the default case will be executed if none of the other cases is available. This lets us try to access one or more channels, but if none is ready, can do sth else.

```go
func sendMsgAfter(seconds time.Duration) <-chan string {
	messages := make(chan string)
	go func() {
		time.Sleep(seconds)
		messages <- "Hello"
	}()
	return messages
}

func main() {
	messages := sendMsgAfter(3 * time.Second)
	for {
		select {
		case msg := <-messages:
			fmt.Println("Message received!", msg)
			return
		default:
			fmt.Println("No message waiting")
			time.Sleep(time.Second)
		}
	}
}
```

For this, since have the `select`in a loop, the default case will be executed over and over again until receive a message. When this happens, print the message and return on the `main()`function.

#### Performing concurrent computations on the default case

A useful scenario is to use the default `select-case`for concurrent computations and then use a channel to signal when need to stop. For this the number of possible strings. just like:

```go
func toBase27(n int) string {
	result := ""
	for n > 0 {
		result = string(alphabet[n%27]) + result
		n /= 27
	}
	return result
}
```

